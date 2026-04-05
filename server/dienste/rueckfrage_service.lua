HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local RueckfrageService = {}

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function istLeer(s)
  return trim(s) == ""
end

local function statusErlaubt(kategorieId, status)
  local k = Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]
  if not k or type(k.erlaubteStatus) ~= "table" then return true end
  for _, s in ipairs(k.erlaubteStatus) do
    if s == status then return true end
  end
  return false
end

local function antragHolen(antragId)
  return HM_BP.Server.Datenbank.Einzel([[
    SELECT *
    FROM hm_bp_submissions
    WHERE id = ? AND deleted_at IS NULL
  ]], { antragId })
end

local function offeneRueckfrageExistiert(antragId)
  local a = HM_BP.Server.Datenbank.Einzel("SELECT status, category_id FROM hm_bp_submissions WHERE id = ? AND deleted_at IS NULL", { antragId })
  if not a then return false end

  -- Status-Metadaten als Quelle der Wahrheit für erlaubtBuergerAntwort
  local statusListe = HM_BP.Server.Dienste.StatusService.StatusListeFuerKategorie(a.category_id)
  for _, s in ipairs(statusListe) do
    if s.id == a.status then
      return s.erlaubtBuergerAntwort == true
    end
  end

  -- Fallback: Legacy-Verhalten, falls kein Metadatum gefunden
  return a.status == "question_open"
end

function RueckfrageService.JustizRueckfrageStellen(spieler, antragId, text)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  text = trim(text)
  if istLeer(text) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Rückfragetext ist leer." }
  end
  if #text > 2000 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Rückfragetext ist zu lang (max. 2000)." }
  end

  local a = antragHolen(antragId)
  if not a then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.rueckfrageStellen ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst keine Rückfragen stellen." }
  end

  -- Sperre (Bearbeitungsschutz)
  local okS, errS = HM_BP.Server.Dienste.SperrService.Sperren(spieler, antragId)
  if not okS then return nil, errS end

  -- Timeline Eintrag: request_info, visibility citizen (Bürger soll es sehen)
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'request_info', 'citizen', ?, ?, ?)
  ]], { antragId, spieler.identifier, spieler.name, json.encode({ text = text }) })

  -- Statuswechsel auf question_open (1A)
  local neuerStatus = "question_open"
  if not statusErlaubt(a.category_id, neuerStatus) then
    return { ok = true, statusGeaendert = false, info = "Status question_open ist für diese Kategorie nicht erlaubt." }, nil
  end

  if a.status ~= neuerStatus then
    HM_BP.Server.Datenbank.Ausfuehren("UPDATE hm_bp_submissions SET status = ? WHERE id = ?", { neuerStatus, antragId })

    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_status_history
        (submission_id, old_status, new_status, changed_by_identifier, changed_by_name, comment)
      VALUES (?, ?, ?, ?, ?, ?)
    ]], { antragId, a.status, neuerStatus, spieler.identifier, spieler.name, "Rückfrage gestellt" })

    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_timeline
        (submission_id, entry_type, visibility, author_identifier, author_name, content)
      VALUES (?, 'system', 'internal', ?, ?, ?)
    ]], { antragId, spieler.identifier, spieler.name, json.encode({ text = "Status automatisch auf 'question_open' gesetzt." }) })
  end

  -- Audit
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.rueckfrage",
    spieler.identifier,
    spieler.name,
    spieler.job.name,
    spieler.job.grade,
    tostring(antragId),
    json.encode({ text = text, status_to = neuerStatus })
  })

  return { ok = true, statusGeaendert = true, neuerStatus = neuerStatus,
           public_id = a.public_id, category_id = a.category_id, form_id = a.form_id,
           citizen_identifier = a.citizen_identifier, citizen_name = a.citizen_name }, nil
end

function RueckfrageService.BuergerDetailsHolen(spieler, antragId)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, citizen_identifier, citizen_name, category_id, form_id, status, priority,
           created_at, updated_at, archived_at
    FROM hm_bp_submissions
    WHERE id = ? AND deleted_at IS NULL
  ]], { antragId })

  if not a then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  if a.citizen_identifier ~= spieler.identifier and not HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf diesen Antrag." }
  end

  local payload = HM_BP.Server.Datenbank.Einzel([[
    SELECT form_snapshot, fields_snapshot, answers
    FROM hm_bp_submission_payloads
    WHERE submission_id = ?
  ]], { antragId })

  local timeline = HM_BP.Server.Datenbank.Alle([[
    SELECT id, entry_type, visibility, author_name, content, created_at
    FROM hm_bp_submission_timeline
    WHERE submission_id = ?
      AND visibility IN ('citizen')
    ORDER BY created_at ASC
    LIMIT 200
  ]], { antragId })

  -- rueckfrageOffen / nachreichungErlaubt: Status-Metadaten als Quelle der Wahrheit
  local rueckfrageOffen = false
  local nachreichungErlaubt = false
  local statusListe = HM_BP.Server.Dienste.StatusService.StatusListeFuerKategorie(a.category_id)
  for _, s in ipairs(statusListe) do
    if s.id == a.status then
      rueckfrageOffen = (s.erlaubtBuergerAntwort == true)
      nachreichungErlaubt = (s.erlaubtNachreichung == true)
      break
    end
  end
  if not rueckfrageOffen then
    -- Fallback: Legacy
    rueckfrageOffen = (a.status == "question_open")
  end
  if not nachreichungErlaubt then
    -- Fallback: Legacy
    nachreichungErlaubt = (a.status == "question_open")
  end

  return {
    antrag = a,
    payload = payload,
    timeline = timeline,
    rueckfrageOffen = rueckfrageOffen,
    nachreichungErlaubt = nachreichungErlaubt
  }, nil
end

function RueckfrageService.BuergerAntwort(spieler, antragId, text)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  text = trim(text)
  if istLeer(text) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antwort ist leer." }
  end
  if #text > 2000 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antwort ist zu lang (max. 2000)." }
  end

  local a = antragHolen(antragId)
  if not a then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  if a.citizen_identifier ~= spieler.identifier and not HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf diesen Antrag." }
  end

  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  -- 2A: Bürger darf nur antworten, wenn Rückfrage offen ist
  if not offeneRueckfrageExistiert(antragId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Es ist keine Rückfrage offen." }
  end

  -- Timeline Eintrag: public_message, visibility citizen
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'public_message', 'citizen', ?, ?, ?)
  ]], { antragId, spieler.identifier, spieler.name, json.encode({ text = text }) })

  -- STEP 2.5: Status automatisch zurück auf in_review (wenn erlaubt)
  local statusVon = a.status
  local statusZu = "in_review"

  local statusGeaendert = false
  if statusVon ~= statusZu and statusErlaubt(a.category_id, statusZu) then
    HM_BP.Server.Datenbank.Ausfuehren("UPDATE hm_bp_submissions SET status = ? WHERE id = ?", { statusZu, antragId })

    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_status_history
        (submission_id, old_status, new_status, changed_by_identifier, changed_by_name, comment)
      VALUES (?, ?, ?, ?, ?, ?)
    ]], { antragId, statusVon, statusZu, spieler.identifier, spieler.name, "Bürger hat auf Rückfrage geantwortet" })

    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_timeline
        (submission_id, entry_type, visibility, author_identifier, author_name, content)
      VALUES (?, 'system', 'internal', ?, ?, ?)
    ]], { antragId, spieler.identifier, spieler.name, json.encode({ text = "Status automatisch auf 'in_review' gesetzt (Bürgerantwort erhalten)." }) })

    statusGeaendert = true
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.buerger_antwort",
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    tostring(antragId),
    json.encode({
      text = text,
      status_auto_from = statusVon,
      status_auto_to = statusZu,
      status_geaendert = statusGeaendert
    })
  })

  return { ok = true, statusGeaendert = statusGeaendert, statusNeu = statusZu }, nil
end

HM_BP.Server.Dienste.RueckfrageService = RueckfrageService