HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local JustizAntragService = {}

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function statusErlaubt(kategorieId, neuerStatus)
  local k = Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]
  if not k or type(k.erlaubteStatus) ~= "table" then return true end
  for _, s in ipairs(k.erlaubteStatus) do
    if s == neuerStatus then return true end
  end
  return false
end

local function prioritaetErlaubt(prio)
  if not (Config.Prioritaeten and Config.Prioritaeten.Aktiviert and type(Config.Prioritaeten.Liste) == "table") then
    return true
  end
  for _, p in ipairs(Config.Prioritaeten.Liste) do
    if p.id == prio then return true end
  end
  return false
end

local function sperreNoetigUndSetzen(spieler, antragId)
  -- Setzt/verlängert Sperre. Wenn ein anderer Bearbeiter die Sperre hält:
  --   - Leitung (grade >= LeitungMinGrade) und Admin dürfen ohne Übernahme schreiben.
  --   - Alle anderen bekommen einen Konflikt-Fehler.
  if not (Config.Workflows and Config.Workflows.Sperren and Config.Workflows.Sperren.Aktiviert) then
    return true, nil
  end

  HM_BP.Server.Dienste.SperrService.AblaufeneSperrenAufraeumen()
  local lock = HM_BP.Server.Dienste.SperrService.SperreHolen(antragId)

  if lock then
    -- Eigene Sperre → verlängern
    if lock.locked_by_identifier == spieler.identifier then
      return HM_BP.Server.Dienste.SperrService.Sperren(spieler, antragId)
    end

    -- Leitung / Admin → darf auch ohne Übernahme schreiben
    local istLeitung = HM_BP.Server.Dienste.WorkflowService
      and HM_BP.Server.Dienste.WorkflowService.IstLeitung(spieler)
    local istAdmin = HM_BP.Server.Dienste.AuthService.IstAdmin(spieler)
    if istLeitung or istAdmin then
      return true, nil
    end

    -- Fremde Sperre → Konflikt
    return false, {
      code     = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT,
      nachricht = ("Dieser Antrag wird gerade von %s bearbeitet."):format(
        lock.locked_by_name or "einem Bearbeiter"),
      sperre = {
        von        = lock.locked_by_name or "Unbekannt",
        identifier = lock.locked_by_identifier,
        expires_at = lock.expires_at,
      }
    }
  end

  -- Keine Sperre → setzen
  return HM_BP.Server.Dienste.SperrService.Sperren(spieler, antragId)
end

function JustizAntragService.EingangListe(spieler, kategorieId, limit)
  limit = tonumber(limit or 50) or 50
  if limit > 200 then limit = 200 end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, kategorieId)
  if not regeln or regeln.erlaubt ~= true or regeln.sehen.eingang ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf Eingang dieser Kategorie." }
  end

  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, public_id, citizen_name, citizen_identifier, category_id, form_id, status, priority,
           created_at, updated_at, assigned_to_name
    FROM hm_bp_submissions
    WHERE category_id = ?
      AND deleted_at IS NULL
      AND archived_at IS NULL
    ORDER BY created_at DESC
    LIMIT ?
  ]], { kategorieId, limit })

  return rows or {}, nil
end

function JustizAntragService.ZugewiesenListe(spieler, kategorieId, limit)
  limit = tonumber(limit or 50) or 50
  if limit > 200 then limit = 200 end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, kategorieId)
  if not regeln or regeln.erlaubt ~= true or regeln.sehen.zugewiesen ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf zugewiesene Anträge dieser Kategorie." }
  end

  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, public_id, citizen_name, citizen_identifier, category_id, form_id, status, priority,
           created_at, updated_at, assigned_to_name
    FROM hm_bp_submissions
    WHERE category_id = ?
      AND assigned_to_identifier = ?
      AND deleted_at IS NULL
      AND archived_at IS NULL
    ORDER BY updated_at DESC
    LIMIT ?
  ]], { kategorieId, spieler.identifier, limit })

  return rows or {}, nil
end

function JustizAntragService.AlleKategorieListe(spieler, kategorieId, limit)
  limit = tonumber(limit or 50) or 50
  if limit > 200 then limit = 200 end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, kategorieId)
  if not regeln or regeln.erlaubt ~= true or regeln.sehen.alleKategorie ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf alle Anträge dieser Kategorie." }
  end

  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, public_id, citizen_name, citizen_identifier, category_id, form_id, status, priority,
           created_at, updated_at, assigned_to_name, archived_at
    FROM hm_bp_submissions
    WHERE category_id = ?
      AND deleted_at IS NULL
    ORDER BY created_at DESC
    LIMIT ?
  ]], { kategorieId, limit })

  return rows or {}, nil
end

function JustizAntragService.DetailsHolen(spieler, antragId)
  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT *
    FROM hm_bp_submissions
    WHERE id = ? AND deleted_at IS NULL
  ]], { antragId })

  if not a then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf diese Kategorie." }
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
    ORDER BY created_at ASC
    LIMIT 200
  ]], { antragId })

  local lock = HM_BP.Server.Dienste.SperrService.SperreHolen(antragId)

  local gesperrtVonAnderem = false
  if lock and lock.locked_by_identifier and lock.locked_by_identifier ~= spieler.identifier then
    gesperrtVonAnderem = true
  end

  return {
    antrag = a,
    payload = payload,
    timeline = timeline,
    sperre = lock,
    gesperrtVonAnderem = gesperrtVonAnderem,
    regeln = regeln
  }, nil
end

function JustizAntragService.Uebernehmen(spieler, antragId)
  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, assigned_to_identifier, archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.antragUebernehmen ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst Anträge in dieser Kategorie nicht übernehmen." }
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET assigned_to_identifier = ?, assigned_to_name = ?
    WHERE id = ?
  ]], { spieler.identifier, spieler.name, antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({ text = "Antrag wurde übernommen.", bearbeiter = spieler.name })
  })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.uebernommen",
    spieler.identifier, spieler.name, spieler.job.name, spieler.job.grade,
    tostring(antragId),
    json.encode({ zeit = utcJetztIso() })
  })

  return { ok = true, public_id = a.public_id }, nil
end

function JustizAntragService.Zuweisen(spieler, antragId, zielIdentifier, zielName)
  if type(zielIdentifier) ~= "string" or zielIdentifier == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ziel-Identifier fehlt." }
  end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, assigned_to_identifier, assigned_to_name, archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.zuweisen ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst keine Zuweisungen durchführen." }
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  local alterName = a.assigned_to_name
  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET assigned_to_identifier = ?, assigned_to_name = ?
    WHERE id = ?
  ]], { zielIdentifier, zielName or zielIdentifier, antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({ text = "Zuweisung geändert.", von = alterName or "-", nach = zielName or zielIdentifier })
  })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.zugewiesen",
    spieler.identifier, spieler.name, spieler.job.name, spieler.job.grade,
    tostring(antragId),
    json.encode({ von = a.assigned_to_identifier, nach = zielIdentifier })
  })

  return { ok = true, public_id = a.public_id }, nil
end

function JustizAntragService.PrioritaetSetzen(spieler, antragId, prio)
  if type(prio) ~= "string" or prio == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Priorität fehlt." }
  end
  if not prioritaetErlaubt(prio) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültige Priorität." }
  end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, priority, archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.prioritaetAendern ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst die Priorität nicht ändern." }
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  HM_BP.Server.Datenbank.Ausfuehren("UPDATE hm_bp_submissions SET priority = ? WHERE id = ?", { prio, antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({ text = "Priorität geändert.", alt = a.priority, neu = prio })
  })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.prioritaet",
    spieler.identifier, spieler.name, spieler.job.name, spieler.job.grade,
    tostring(antragId),
    json.encode({ alt = a.priority, neu = prio })
  })

  return { ok = true, alt = a.priority, neu = prio, public_id = a.public_id }, nil
end

function JustizAntragService.Archivieren(spieler, antragId, grund)
  grund = grund or ""
  if type(grund) ~= "string" then grund = tostring(grund) end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist bereits archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.archivieren ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst nicht archivieren." }
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  HM_BP.Server.Datenbank.Ausfuehren("UPDATE hm_bp_submissions SET archived_at = UTC_TIMESTAMP(), status = 'archived' WHERE id = ?", { antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({ text = "Antrag archiviert.", grund = grund })
  })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'submission', ?, ?)
  ]], {
    "antrag.archiviert",
    spieler.identifier, spieler.name, spieler.job.name, spieler.job.grade,
    tostring(antragId),
    json.encode({ grund = grund })
  })

  return { ok = true, public_id = a.public_id }, nil
end

function JustizAntragService.InterneNotiz(spieler, antragId, text)
  if type(text) ~= "string" or text:gsub("%s+", "") == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Notiztext ist leer." }
  end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, form_id, archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.interneNotizSchreiben ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst keine internen Notizen schreiben." }
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'internal_note', 'internal', ?, ?, ?)
  ]], { antragId, spieler.identifier, spieler.name, json.encode({ text = text }) })

  return { ok = true, public_id = a.public_id, category_id = a.category_id, form_id = a.form_id }, nil
end

function JustizAntragService.OeffentlicheAntwort(spieler, antragId, text)
  if type(text) ~= "string" or text:gsub("%s+", "") == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antworttext ist leer." }
  end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, form_id, citizen_identifier, archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.oeffentlicheAntwortSchreiben ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst keine öffentlichen Antworten schreiben." }
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'public_message', 'citizen', ?, ?, ?)
  ]], { antragId, spieler.identifier, spieler.name, json.encode({ text = text }) })

  -- SLA Erste-Bearbeitung: Zeitstempel des ersten Justiz-Kommentars setzen (PR13)
  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET first_staff_comment_at = UTC_TIMESTAMP()
    WHERE id = ? AND first_staff_comment_at IS NULL
  ]], { antragId })

  return { ok = true, public_id = a.public_id, category_id = a.category_id, form_id = a.form_id,
           citizen_identifier = a.citizen_identifier }, nil
end

function JustizAntragService.StatusAendern(spieler, antragId, neuerStatus, kommentar)
  if type(neuerStatus) ~= "string" or neuerStatus == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Neuer Status fehlt." }
  end

  local a = HM_BP.Server.Datenbank.Einzel([[
    SELECT id, public_id, category_id, form_id, status, citizen_identifier, citizen_name,
           archived_at, deleted_at
    FROM hm_bp_submissions WHERE id = ?
  ]], { antragId })
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.archived_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Antrag ist archiviert." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, a.category_id)
  if not regeln or regeln.erlaubt ~= true or regeln.aktionen.statusAendern ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst den Status nicht ändern." }
  end

  if not statusErlaubt(a.category_id, neuerStatus) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Dieser Status ist für die Kategorie nicht erlaubt." }
  end

  -- Statusübergang-Prüfung (erlaubteFolgeStatus)
  if HM_BP.Server.Dienste.WorkflowService then
    if not HM_BP.Server.Dienste.WorkflowService.UebergangErlaubt(a.category_id, a.status, neuerStatus) then
      return nil, {
        code     = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
        nachricht = ("Ungültiger Statusübergang: %s → %s"):format(tostring(a.status), tostring(neuerStatus))
      }
    end
  end

  local okS, errS = sperreNoetigUndSetzen(spieler, antragId)
  if not okS then return nil, errS end

  HM_BP.Server.Datenbank.Ausfuehren(
    "UPDATE hm_bp_submissions SET status = ?, last_status_change_at = UTC_TIMESTAMP() WHERE id = ?",
    { neuerStatus, antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_status_history (submission_id, old_status, new_status, changed_by_identifier, changed_by_name, comment)
    VALUES (?, ?, ?, ?, ?, ?)
  ]], { antragId, a.status, neuerStatus, spieler.identifier, spieler.name, kommentar or "" })

  return { ok = true, alt = a.status, neu = neuerStatus,
           public_id = a.public_id, category_id = a.category_id, form_id = a.form_id,
           citizen_name = a.citizen_name, citizen_identifier = a.citizen_identifier }, nil
end

-- NEU: Sperre verlängern (Heartbeat). Nur wenn Spieler Lock-Owner ist.
function JustizAntragService.SperreVerlaengern(spieler, antragId)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  local lock = HM_BP.Server.Dienste.SperrService.SperreHolen(antragId)
  if not lock then
    return { ok = true, info = "Keine Sperre vorhanden." }, nil
  end

  if lock.locked_by_identifier ~= spieler.identifier then
    -- kein Fehler: nur ignorieren (jemand anderes sperrt)
    return { ok = true, info = "Nicht Sperr-Inhaber." }, nil
  end

  local okS, errS = HM_BP.Server.Dienste.SperrService.Sperren(spieler, antragId)
  if not okS then
    return nil, errS
  end

  return { ok = true }, nil
end

HM_BP.Server.Dienste.JustizAntragService = JustizAntragService