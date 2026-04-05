HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AntragService = {}

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function istLeer(s)
  return trim(s) == ""
end

local function fristBerechnen(formular, kategorie)
  local stunden = nil
  if formular and formular.fristen and formular.fristen.fristStunden then
    stunden = tonumber(formular.fristen.fristStunden)
  elseif kategorie and kategorie.standardFristStunden then
    stunden = tonumber(kategorie.standardFristStunden)
  end
  if not stunden or stunden <= 0 then return nil end

  local nun = os.time(os.date("!*t"))
  local deadline = nun + (stunden * 3600)
  return os.date("!%Y-%m-%d %H:%M:%S", deadline)
end

function AntragService.Einreichen(spieler, standortId, formularId, antworten)
  -- AntiSpam: globaler Cooldown
  local okCd, errCd = HM_BP.Server.Dienste.AntiSpamService.PruefeGlobalenCooldown(spieler)
  if not okCd then return nil, errCd end

  -- Formularschema serverseitig holen (enthält citizen_name Pflichtfeld)
  local schema, errSchema = HM_BP.Server.Dienste.FormularService.FormularSchemaHolen(spieler, formularId)
  if not schema then return nil, errSchema end

  local fConfig = Config.Formulare.Liste[formularId]
  local kConfig = fConfig and Config.Kategorien.Liste[fConfig.kategorieId] or nil

  -- Validierung serverseitig (niemals UI vertrauen)
  local okVal, errVal = HM_BP.Server.Dienste.FeldValidierungService.ValidiereSchemaUndAntworten(schema, antworten)
  if not okVal then return nil, errVal end

  -- Bürgername kommt jetzt bewusst aus dem Formular (Pflichtfeld)
  local citizenName = trim(antworten.citizen_name)
  if citizenName == "" then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Name ist ein Pflichtfeld.",
      feldFehler = { citizen_name = "Pflichtfeld" }
    }
  end
  if #citizenName < 2 then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Name ist zu kurz.",
      feldFehler = { citizen_name = "muss mindestens 2 Zeichen haben" }
    }
  end
  if #citizenName > 60 then
    return nil, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Name ist zu lang.",
      feldFehler = { citizen_name = "darf maximal 60 Zeichen haben" }
    }
  end

  -- Öffentliche ID
  local publicId, errId = HM_BP.Server.Dienste.OeffentlicheIdService.NaechsteAntragsNummerErzeugen()
  if not publicId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER, nachricht = ("Öffentliche ID konnte nicht erzeugt werden: %s"):format(tostring(errId)) }
  end

  local status = (fConfig and fConfig.standardStatus) or "submitted"
  local prioritaet = (fConfig and fConfig.standardPrioritaet) or (kConfig and kConfig.standardPrioritaet) or "normal"
  local frist = fristBerechnen(fConfig, kConfig)

  local flags = {
    eingereichtAm = utcJetztIso(),
    standortId = standortId
  }

  -- Insert Antrag
  local inserted = HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submissions
      (public_id, citizen_identifier, citizen_name, category_id, form_id, form_version, status, priority, deadline_at, due_state, location_id, flags)
    VALUES
      (?, ?, ?, ?, ?, ?, ?, ?, ?, 'normal', ?, ?)
  ]], {
    publicId,
    spieler.identifier,
    citizenName,
    fConfig.kategorieId,
    formularId,
    schema.formular.version or 1,
    status,
    prioritaet,
    frist,
    standortId,
    json.encode(flags)
  })

  if not inserted or inserted < 1 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER, nachricht = "Antrag konnte nicht gespeichert werden." }
  end

  -- Submission ID holen
  local row = HM_BP.Server.Datenbank.Einzel("SELECT id FROM hm_bp_submissions WHERE public_id = ?", { publicId })
  if not row or not row.id then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER, nachricht = "Antrag wurde gespeichert, konnte aber nicht geladen werden." }
  end
  local antragId = row.id

  -- Payload Snapshot
  local formSnapshot = {
    id = schema.formular.id,
    titel = schema.formular.titel,
    beschreibung = schema.formular.beschreibung,
    kategorieId = schema.formular.kategorieId,
    version = schema.formular.version,
  }

  local okPayload = HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_payloads (submission_id, form_snapshot, fields_snapshot, answers)
    VALUES (?, ?, ?, ?)
  ]], {
    antragId,
    json.encode(formSnapshot),
    json.encode(schema.felder),
    json.encode(antworten)
  })

  if not okPayload or okPayload < 1 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER, nachricht = "Antragsdaten konnten nicht gespeichert werden." }
  end

  -- Timeline Systemeintrag
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId,
    spieler.identifier,
    citizenName,
    json.encode({
      text = "Antrag wurde eingereicht.",
      public_id = publicId,
      status = status,
      prioritaet = prioritaet
    })
  })

  -- Status-Historie
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_status_history
      (submission_id, old_status, new_status, changed_by_identifier, changed_by_name, comment)
    VALUES (?, NULL, ?, ?, ?, ?)
  ]], {
    antragId,
    status,
    spieler.identifier,
    citizenName,
    "Eingereicht"
  })

  -- Audit
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  ]], {
    "antrag.eingereicht",
    spieler.identifier,
    citizenName,
    spieler.job.name,
    spieler.job.grade,
    "submission",
    tostring(antragId),
    json.encode({
      public_id = publicId,
      formular_id = formularId,
      kategorie_id = fConfig.kategorieId,
      standort_id = standortId
    })
  })

  -- SLA-Frist initialisieren (PR7 WorkflowService)
  if HM_BP.Server.Dienste.WorkflowService then
    pcall(function()
      HM_BP.Server.Dienste.WorkflowService.SlaInitialisieren(antragId, fConfig.kategorieId)
    end)
  end

  return {
    id = antragId,
    public_id = publicId,
    status = status,
    prioritaet = prioritaet,
    frist = frist
  }, nil
end

function AntragService.MeineAntraegeAuflisten(spieler, limit)
  limit = tonumber(limit or 25) or 25
  if limit < 1 then limit = 1 end
  if limit > 100 then limit = 100 end

  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, public_id, category_id, form_id, status, priority, created_at, updated_at, archived_at, deleted_at
    FROM hm_bp_submissions
    WHERE citizen_identifier = ? AND deleted_at IS NULL
    ORDER BY created_at DESC
    LIMIT ?
  ]], { spieler.identifier, limit })

  return rows or {}
end

HM_BP.Server.Dienste.AntragService = AntragService