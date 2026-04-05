HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ============================================================
-- NachreichungService
-- Bürger darf Formular-Antworten nachreichen, wenn der Status
-- dies erlaubt (konfigurierbar über `erlaubtNachreichung` in
-- Config.Status.Liste; Standard-Fallback: question_open).
-- Nur leere Felder dürfen gefüllt werden – bestehende Antworten
-- dürfen NICHT überschrieben werden.
-- ============================================================
local NachreichungService = {}

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function istLeer(v)
  if v == nil then return true end
  if type(v) == "string" and trim(v) == "" then return true end
  return false
end

-- Prüft anhand der Status-Metadaten (Config) ob Nachreichen erlaubt ist
local function statusErlaubtNachreichung(kategorieId, status)
  local statusListe = HM_BP.Server.Dienste.StatusService.StatusListeFuerKategorie(kategorieId)
  for _, s in ipairs(statusListe) do
    if s.id == status then
      return s.erlaubtNachreichung == true
    end
  end
  -- Fallback auf question_open, falls kein Metadatum gefunden
  return status == "question_open"
end

-- Prüft ob ein bestimmter Status für diese Kategorie in erlaubteStatus ist
local function kategorieErlaubtStatus(kategorieId, status)
  local k = Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]
  if not k or type(k.erlaubteStatus) ~= "table" then return true end
  for _, s in ipairs(k.erlaubteStatus) do
    if s == status then return true end
  end
  return false
end

-- Parst einen JSON-Wert sicher (String oder bereits Table)
local function jsonParsen(wert)
  if type(wert) == "table" then return wert end
  if type(wert) == "string" and wert ~= "" then
    local ok, parsed = pcall(json.decode, wert)
    if ok and type(parsed) == "table" then return parsed end
  end
  return nil
end

-- ===========================================================
-- Hauptfunktion: Nachreichung eines Bürgers einreichen
-- spieler     : authentifiziertes Spieler-Objekt
-- antragId    : interne numerische ID der Submission
-- neueAntworten: Table { feldKey = wert, ... }
-- Gibt bei Erfolg { ok, felderCount, statusGeaendert, statusNeu,
--                   public_id, category_id, form_id } zurück.
-- ===========================================================
function NachreichungService.NachreichungEinreichen(spieler, antragId, neueAntworten)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  if type(neueAntworten) ~= "table" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Felder fehlen oder sind ungültig." }
  end

  -- Rate-Limit (Anti-Spam)
  local okRL, errRL = HM_BP.Server.Dienste.AntiSpamService.PruefeRateLimit(spieler, "nachreichung")
  if not okRL then return nil, errRL end

  -- Antrag laden
  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, citizen_identifier, citizen_name,
           category_id, form_id, status, archived_at
    FROM hm_bp_submissions
    WHERE id = ? AND deleted_at IS NULL
  ]], { antragId })

  if not a then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  -- Nur eigene Submissions (außer Admin)
  if a.citizen_identifier ~= spieler.identifier and not HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf diesen Antrag." }
  end

  -- Archivierte Submissions sperren
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  -- Status muss Nachreichung erlauben
  if not statusErlaubtNachreichung(a.category_id, a.status) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Nachreichen ist im aktuellen Status nicht erlaubt." }
  end

  -- Payload laden (Snapshot + aktuelle Antworten)
  local payload = HM_BP.Server.Datenbank.Einzel([[
    SELECT form_snapshot, fields_snapshot, answers
    FROM hm_bp_submission_payloads
    WHERE submission_id = ?
  ]], { antragId })

  if not payload then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antragsdaten nicht gefunden." }
  end

  -- Bestehende Antworten und Felder-Snapshot parsen
  local bestehendeAntworten = jsonParsen(payload.answers) or {}
  local felderSnapshot = jsonParsen(payload.fields_snapshot) or {}

  -- Lookup-Tabelle der erlaubten Felder aus dem Snapshot (Snapshot ist Referenz!)
  local feldLookup = {}
  for _, feld in ipairs(felderSnapshot) do
    if feld.key then
      feldLookup[feld.key] = feld
    end
  end

  -- Validierung der eingehenden Felder:
  -- 1. Nur Felder aus fields_snapshot akzeptiert
  -- 2. Nur leere/fehlende Felder dürfen gefüllt werden (kein Überschreiben)
  -- 3. Typvalidierung via FeldValidierungService
  local geprufteFelder = {}
  local feldFehler = {}

  for key, wert in pairs(neueAntworten) do
    local feld = feldLookup[key]
    if not feld then
      feldFehler[key] = "Feld nicht im Formularschema vorhanden."
      goto weiter
    end

    -- Bestehenden Wert prüfen – darf NICHT überschrieben werden
    if not istLeer(bestehendeAntworten[key]) then
      feldFehler[key] = "Feld ist bereits ausgefüllt und darf nicht überschrieben werden."
      goto weiter
    end

    -- Wenn neuer Wert ebenfalls leer, überspringen (keine Aktion nötig)
    if istLeer(wert) then
      goto weiter
    end

    -- Typvalidierung über bestehenden Service (einzelnes Feld)
    local okV, errV = HM_BP.Server.Dienste.FeldValidierungService.ValidiereSchemaUndAntworten(
      { felder = { feld } },
      { [key] = wert }
    )
    if not okV then
      if errV and errV.feldFehler and errV.feldFehler[key] then
        feldFehler[key] = errV.feldFehler[key]
      else
        feldFehler[key] = "Ungültiger Wert."
      end
      goto weiter
    end

    geprufteFelder[key] = wert
    ::weiter::
  end

  -- Bei Validierungsfehlern sofort abbrechen
  if next(feldFehler) ~= nil then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Eingaben prüfen.",
      feldFehler = feldFehler
    }
  end

  -- Mindestens ein Feld muss nachgereicht werden
  local anzahlFelder = 0
  for _ in pairs(geprufteFelder) do
    anzahlFelder = anzahlFelder + 1
  end

  if anzahlFelder == 0 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Keine neuen Felder zum Nachreichen angegeben." }
  end

  -- Antworten zusammenführen und speichern
  for key, wert in pairs(geprufteFelder) do
    bestehendeAntworten[key] = wert
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submission_payloads SET answers = ? WHERE submission_id = ?
  ]], { json.encode(bestehendeAntworten), antragId })

  -- Label-Liste der nachgereichten Felder für den Timeline-Eintrag
  local feldLabels = {}
  for key, _ in pairs(geprufteFelder) do
    local feld = feldLookup[key]
    table.insert(feldLabels, feld.label or key)
  end

  -- Timeline: citizen_supplement (für Bürger sichtbar)
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'citizen_supplement', 'citizen', ?, ?, ?)
  ]], {
    antragId,
    spieler.identifier,
    spieler.name,
    json.encode({
      felder_count = anzahlFelder,
      felder_labels = feldLabels
    })
  })

  -- Statuswechsel: question_open -> in_review (sofern erlaubt)
  local statusVon = a.status
  local statusZu = "in_review"
  local statusGeaendert = false

  if statusVon ~= statusZu and kategorieErlaubtStatus(a.category_id, statusZu) then
    HM_BP.Server.Datenbank.Ausfuehren("UPDATE hm_bp_submissions SET status = ? WHERE id = ?", { statusZu, antragId })

    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_status_history
        (submission_id, old_status, new_status, changed_by_identifier, changed_by_name, comment)
      VALUES (?, ?, ?, ?, ?, ?)
    ]], {
      antragId, statusVon, statusZu,
      spieler.identifier, spieler.name,
      "Bürger hat Daten nachgereicht"
    })

    -- System-Timeline (intern, nicht für Bürger)
    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_timeline
        (submission_id, entry_type, visibility, author_identifier, author_name, content)
      VALUES (?, 'system', 'internal', ?, ?, ?)
    ]], {
      antragId, spieler.identifier, spieler.name,
      json.encode({ text = "Status automatisch auf 'in_review' gesetzt (Bürger hat nachgereicht)." })
    })

    statusGeaendert = true
  end

  -- Audit-Log
  local feldKeys = {}
  for k in pairs(geprufteFelder) do table.insert(feldKeys, k) end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.nachgereicht",
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    tostring(antragId),
    json.encode({
      felder_count = anzahlFelder,
      felder_keys = feldKeys,
      status_auto_from = statusVon,
      status_auto_to = statusZu,
      status_geaendert = statusGeaendert
    })
  })

  return {
    ok = true,
    felderCount = anzahlFelder,
    statusGeaendert = statusGeaendert,
    statusNeu = statusGeaendert and statusZu or statusVon,
    public_id = a.public_id,
    category_id = a.category_id,
    form_id = a.form_id
  }, nil
end

HM_BP.Server.Dienste.NachreichungService = NachreichungService
