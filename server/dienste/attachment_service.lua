-- =============================================================
-- server/dienste/attachment_service.lua
-- Bild-Anhänge als URL-Links (kein lokaler Upload).
-- Whitelist: Imgur + Discord CDN (konfigurierbar).
-- PR8
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AttachmentService = {}

-- ---------- Helpers ------------------------------------------

local function cfg()
  return (Config and Config.Anhaenge) or {}
end

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function stringLower(s)
  return type(s) == "string" and s:lower() or ""
end

-- Parst scheme und host aus einer URL.
-- Gibt scheme (string), host (string) zurück.
-- Einfache Implementierung ohne externe Bibliotheken.
local function parseUrl(url)
  if type(url) ~= "string" then return nil, nil end
  -- schema://host[/path...]
  local scheme, rest = url:match("^([a-zA-Z][a-zA-Z0-9+%-.]*)://(.+)$")
  if not scheme or not rest then return nil, nil end
  -- host ist alles bis zum ersten / ? # oder Ende
  local host = rest:match("^([^/?#]+)")
  if not host then return nil, nil end
  -- Port abtrennen falls vorhanden
  host = host:match("^([^:]+)") or host
  return stringLower(scheme), stringLower(host)
end

-- Prüft ob eine URL ein direkter Bildlink ist (endet mit Bilddatei-Endung).
local function istDirektbild(url)
  if type(url) ~= "string" then return false end
  -- Query-String und Fragment abschneiden für die Endungs-Prüfung
  local pfad = url:match("^([^?#]+)") or url
  pfad = stringLower(pfad)
  local endungen = cfg().DirektlinkEndungen or { ".png", ".jpg", ".jpeg", ".webp", ".gif" }
  for _, ext in ipairs(endungen) do
    if pfad:sub(-#ext) == stringLower(ext) then
      return true
    end
  end
  return false
end

-- mime_hint aus URL ableiten (für direkte Bilder)
local function mimeHintAusUrl(url)
  local pfad = (url:match("^([^?#]+)") or url):lower()
  if pfad:sub(-4) == ".png"  then return "image/png"  end
  if pfad:sub(-4) == ".jpg"  then return "image/jpeg" end
  if pfad:sub(-5) == ".jpeg" then return "image/jpeg" end
  if pfad:sub(-5) == ".webp" then return "image/webp" end
  if pfad:sub(-4) == ".gif"  then return "image/gif"  end
  return nil
end

-- ---------- Validierung --------------------------------------

-- Validiert eine URL gegen Whitelist und Schema.
-- Gibt true oder nil, err zurück.
local function urlValidieren(url)
  if type(url) ~= "string" or url == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "URL fehlt oder ist leer." }
  end
  if #url > 2048 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "URL ist zu lang (max. 2048 Zeichen)." }
  end

  local scheme, host = parseUrl(url)
  if not scheme or not host then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiges URL-Format." }
  end

  -- Scheme-Prüfung
  local erlaubteSchemes = cfg().ErlaubteSchemes or { "https" }
  local schemeOk = false
  for _, s in ipairs(erlaubteSchemes) do
    if scheme == stringLower(s) then schemeOk = true; break end
  end
  if not schemeOk then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = ("URL-Scheme '%s' ist nicht erlaubt. Erlaubte Schemes: %s"):format(scheme, table.concat(erlaubteSchemes, ", "))
    }
  end

  -- Host-Whitelist
  local erlaubteHosts = cfg().ErlaubteHosts or {}
  local hostOk = false
  for _, h in ipairs(erlaubteHosts) do
    if host == stringLower(h) then hostOk = true; break end
  end
  if not hostOk then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = ("Host '%s' ist nicht auf der Whitelist. Erlaubte Hosts: %s"):format(
        host, table.concat(erlaubteHosts, ", ")
      )
    }
  end

  return true, nil
end

-- ---------- Status-Prüfung für Bürger ------------------------

-- Prüft ob ein Bürger in gegebenem Status Anhänge hinzufügen darf.
local function buergerDarfInStatus(status)
  local erlaubt = cfg().BuergerErlaubteStatus or { "submitted", "question_open" }
  for _, s in ipairs(erlaubt) do
    if tostring(status) == s then return true end
  end
  return false
end

-- ---------- Public API ---------------------------------------

--- Listet alle aktiven (nicht gelöschten) Anhänge eines Antrags.
--- Justiz/Admin sieht alle; Bürger sieht nur Anhänge eigener Anträge.
--- @param spieler table
--- @param antragId number
--- @return table|nil, table|nil
function AttachmentService.Liste(spieler, antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "antragId fehlt." }
  end

  local a = HM_BP.Server.Datenbank.Einzel(
    "SELECT id, citizen_identifier, deleted_at FROM hm_bp_submissions WHERE id = ?",
    { antragId }
  )
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  -- Bürger darf nur eigene Anträge sehen
  if spieler.rolle == "buerger" and a.citizen_identifier ~= spieler.identifier then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung." }
  end

  local liste = HM_BP.Server.Datenbank.Alle([[
    SELECT id, submission_id, created_at, created_by_identifier, created_by_role,
           url, title, mime_hint, is_direct_image
    FROM hm_bp_submission_attachments
    WHERE submission_id = ? AND deleted_at IS NULL
    ORDER BY created_at ASC
  ]], { antragId })

  return liste or {}, nil
end

--- Fügt einen URL-Anhang zu einem Antrag hinzu.
--- Bürger: nur in erlaubten Status; Justiz/Admin: immer.
--- @param spieler table
--- @param antragId number
--- @param url string
--- @param titel string|nil
--- @return table|nil, table|nil
function AttachmentService.Hinzufuegen(spieler, antragId, url, titel)
  local anhangCfg = cfg()
  if not anhangCfg.Aktiviert then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Anhänge sind deaktiviert." }
  end

  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "antragId fehlt." }
  end

  -- URL validieren
  local ok, err = urlValidieren(url)
  if not ok then return nil, err end

  -- Titel-Länge prüfen
  if titel ~= nil and type(titel) == "string" and #titel > 128 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Titel ist zu lang (max. 128 Zeichen)." }
  end
  local titelSauber = (type(titel) == "string" and titel ~= "") and titel or nil

  -- Antrag laden
  local a = HM_BP.Server.Datenbank.Einzel(
    "SELECT id, citizen_identifier, category_id, status, deleted_at FROM hm_bp_submissions WHERE id = ?",
    { antragId }
  )
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  -- Bürger: nur eigener Antrag + Status-Prüfung
  if spieler.rolle == "buerger" then
    if a.citizen_identifier ~= spieler.identifier then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung." }
    end
    if not buergerDarfInStatus(a.status) then
      local erlaubt = anhangCfg.BuergerErlaubteStatus or { "submitted", "question_open" }
      return nil, {
        code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT,
        nachricht = ("Im Status '%s' kannst du keine Anhänge hinzufügen. Erlaubt in: %s"):format(
          tostring(a.status), table.concat(erlaubt, ", ")
        )
      }
    end
  end

  -- Max-Anhänge prüfen
  local max = tonumber(anhangCfg.MaxProAntrag) or 10
  local anzahl = HM_BP.Server.Datenbank.Einzel(
    "SELECT COUNT(*) AS n FROM hm_bp_submission_attachments WHERE submission_id = ? AND deleted_at IS NULL",
    { antragId }
  )
  if anzahl and tonumber(anzahl.n or 0) >= max then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT,
      nachricht = ("Maximale Anzahl Anhänge (%d) erreicht."):format(max)
    }
  end

  -- Direktbild-Erkennung
  local isDirekt = istDirektbild(url) and 1 or 0
  local mimeHint = isDirekt == 1 and mimeHintAusUrl(url) or nil

  -- Einfügen
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_attachments
      (submission_id, created_by_identifier, created_by_role, url, title, mime_hint, is_direct_image)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  ]], {
    antragId,
    spieler.identifier,
    spieler.rolle or "buerger",
    url,
    titelSauber,
    mimeHint,
    isDirekt
  })

  local neuerEintrag = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, submission_id, created_at, created_by_identifier, created_by_role,
           url, title, mime_hint, is_direct_image
    FROM hm_bp_submission_attachments
    WHERE submission_id = ? AND created_by_identifier = ? AND deleted_at IS NULL
    ORDER BY id DESC LIMIT 1
  ]], { antragId, spieler.identifier })

  -- Timeline-Eintrag
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'public', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({
      text = ("Anhang hinzugefügt: %s"):format(titelSauber or url),
      url = url,
      titel = titelSauber,
      is_direct_image = (isDirekt == 1),
    })
  })

  -- Audit
  HM_BP.Server.Dienste.AuditService.Log(
    "anhang.hinzugefuegt", spieler, "submission", tostring(antragId),
    { url = url, titel = titelSauber, is_direct_image = (isDirekt == 1) }
  )

  -- Webhook
  if HM_BP.Server.Dienste.WebhookService then
    HM_BP.Server.Dienste.WebhookService.Emit("anhang_hinzugefuegt", {
      submission_id = antragId,
      citizen_identifier = a.citizen_identifier,
      category_id = a.category_id or nil,
      url = url,
      titel = titelSauber,
      hinzugefuegt_von = spieler.name,
      hinzugefuegt_von_rolle = spieler.rolle,
    })
  end

  return neuerEintrag or { ok = true }, nil
end

--- Entfernt (soft-delete) einen Anhang.
--- Nur Justiz/Admin darf Anhänge entfernen. Begründung ist optional.
--- @param spieler table
--- @param anhangId number
--- @param grund string|nil
--- @return table|nil, table|nil
function AttachmentService.Entfernen(spieler, anhangId, grund)
  if not anhangId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "anhangId fehlt." }
  end

  local anhang = HM_BP.Server.Datenbank.Einzel([[
    SELECT a.id, a.submission_id, a.url, a.title, a.deleted_at,
           s.citizen_identifier, s.category_id, s.deleted_at AS sub_deleted
    FROM hm_bp_submission_attachments a
    JOIN hm_bp_submissions s ON s.id = a.submission_id
    WHERE a.id = ?
  ]], { anhangId })

  if not anhang or anhang.sub_deleted ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Anhang oder Antrag nicht gefunden." }
  end
  if anhang.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Anhang wurde bereits entfernt." }
  end

  local grundSauber = (type(grund) == "string" and grund ~= "") and grund:sub(1, 255) or nil

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submission_attachments
    SET deleted_at = NOW(), deleted_by_identifier = ?, delete_reason = ?
    WHERE id = ?
  ]], { spieler.identifier, grundSauber, anhangId })

  -- Timeline-Eintrag
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    anhang.submission_id, spieler.identifier, spieler.name,
    json.encode({
      text = ("Anhang entfernt: %s"):format(anhang.title or anhang.url),
      url = anhang.url,
      grund = grundSauber,
    })
  })

  -- Audit
  HM_BP.Server.Dienste.AuditService.Log(
    "anhang.entfernt", spieler, "submission", tostring(anhang.submission_id),
    { anhang_id = anhangId, url = anhang.url, grund = grundSauber }
  )

  -- Webhook
  if HM_BP.Server.Dienste.WebhookService then
    HM_BP.Server.Dienste.WebhookService.Emit("anhang_entfernt", {
      submission_id = anhang.submission_id,
      citizen_identifier = anhang.citizen_identifier,
      category_id = anhang.category_id or nil,
      url = anhang.url,
      entfernt_von = spieler.name,
      grund = grundSauber,
    })
  end

  return { ok = true }, nil
end

HM_BP.Server.Dienste.AttachmentService = AttachmentService
