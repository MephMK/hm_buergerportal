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

function AntragService.Einreichen(spieler, standortId, formularId, antworten, delegation)
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

  -- -------------------------------------------------------
  -- Delegation: Im-Auftrag-Einreichung (PR3)
  -- -------------------------------------------------------
  -- delegation = { typ, ziel_source, ziel_identifier, ziel_name }
  -- typ: 'submit_for_citizen' | 'submit_for_company' | 'justice_create_for_citizen'
  -- ziel_identifier + ziel_name: Zielperson (Bürger/Firma)

  local actorIdentifier  = spieler.identifier
  local actorName        = spieler.name or spieler.identifier
  local delegationType   = nil
  local citizenIdentifier = spieler.identifier  -- Standard: einreichender Spieler = Bürger

  if delegation and type(delegation) == "table" and delegation.typ then
    -- Feature-Guard
    if not (Config.Module and Config.Module.Delegation) then
      return nil, {
        code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG,
        nachricht = "Delegation ist nicht aktiviert.",
      }
    end

    local delTyp = delegation.typ

    -- Permission check
    local permAktion = nil
    if delTyp == "submit_for_citizen" then
      permAktion = HM_BP.Shared.Actions.DELEGATE_SUBMIT_FOR_CITIZEN
    elseif delTyp == "submit_for_company" then
      permAktion = HM_BP.Shared.Actions.DELEGATE_SUBMIT_FOR_COMPANY
    elseif delTyp == "justice_create_for_citizen" then
      permAktion = HM_BP.Shared.Actions.DELEGATE_JUSTICE_CREATE_FOR_CITIZEN
    else
      return nil, {
        code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
        nachricht = "Ungültiger Delegations-Typ.",
      }
    end

    local okPerm, errPerm = HM_BP.Server.Dienste.PermissionService.Hat(spieler, permAktion, {})
    if not okPerm then
      return nil, errPerm or {
        code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG,
        nachricht = "Keine Berechtigung für diesen Delegations-Typ.",
      }
    end

    -- Ziel-Spieler: Identifier und Name aus der source auflösen (nur online erlaubt)
    local zielSource = tonumber(delegation.ziel_source)
    if not zielSource or zielSource <= 0 then
      return nil, {
        code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
        nachricht = "Ziel-Spieler muss online sein (Quell-ID fehlt oder ungültig).",
      }
    end

    local zielSpieler = nil
    if HM_BP.Server.Dienste.DelegationService then
      zielSpieler = HM_BP.Server.Dienste.DelegationService.SpielerDurchSource(zielSource)
    end

    if not zielSpieler then
      return nil, {
        code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN,
        nachricht = "Ziel-Spieler ist nicht (mehr) online oder konnte nicht aufgelöst werden.",
      }
    end

    -- Vollmacht prüfen (nur Typen A+B, nicht C)
    if delTyp == "submit_for_citizen" or delTyp == "submit_for_company" then
      local vollmachtTyp = delTyp == "submit_for_citizen" and "buerger_anwalt" or "firma_vertreter"
      local okVm = HM_BP.Server.Dienste.DelegationService.VollmachtPruefen(
        vollmachtTyp,
        zielSpieler.identifier,
        spieler.identifier
      )
      if not okVm then
        return nil, {
          code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG,
          nachricht = "Keine gültige Vollmacht für diese Delegation vorhanden.",
        }
      end
    end

    -- Delegation übernehmen: actor = einreichender Spieler, citizen = Ziel
    actorIdentifier  = spieler.identifier
    actorName        = spieler.name or spieler.identifier
    citizenIdentifier = zielSpieler.identifier
    -- Bürger-Name aus Delegationsfeld überschreiben (Anzeigename des Ziels)
    citizenName      = zielSpieler.name
    delegationType   = delTyp
  end

  -- Öffentliche ID
  local publicId, errId = HM_BP.Server.Dienste.OeffentlicheIdService.NaechsteAntragsNummerErzeugen()
  if not publicId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER, nachricht = ("Öffentliche ID konnte nicht erzeugt werden: %s"):format(tostring(errId)) }
  end

  local status = (fConfig and fConfig.standardStatus) or "submitted"
  local prioritaet = (fConfig and fConfig.standardPrioritaet) or (kConfig and kConfig.standardPrioritaet) or "normal"
  local frist = fristBerechnen(fConfig, kConfig)

  -- Gebühr aus Schema ermitteln (PR14)
  local feeEur = tonumber(schema.formular and schema.formular.fee_eur) or 0
  if feeEur < 0 then feeEur = 0 end
  -- Fallback: Config-Formular gebuehren
  if feeEur == 0 and fConfig and fConfig.gebuehren and fConfig.gebuehren.aktiv then
    feeEur = math.max(0, math.floor(tonumber(fConfig.gebuehren.betrag) or 0))
  end

  -- Gebührenbefreiung prüfen (PR4)
  local befreit = false
  local originalFeeEur = feeEur
  if feeEur > 0 and HM_BP.Server.Dienste.PaymentService then
    befreit = HM_BP.Server.Dienste.PaymentService.BefreiungPruefen(spieler, {
      category_id = fConfig.kategorieId,
      form_id     = formularId,
    })
    if befreit then feeEur = 0 end
  end

  -- Zahlungsmodus: "bei_einreichung" → sofort abbuchen; "bei_entscheidung" → unbezahlt bis Terminal
  local zahlungModus = (Config.Zahlung and Config.Zahlung.Modus) or "bei_entscheidung"
  local zahlungStatus = feeEur > 0 and "unbezahlt" or "bezahlt"

  local flags = {
    eingereichtAm = utcJetztIso(),
    standortId = standortId
  }

  -- Insert Antrag
  local inserted = HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submissions
      (public_id, citizen_identifier, citizen_name, actor_identifier, actor_name, delegation_type,
       category_id, form_id, form_version, status, priority, deadline_at, due_state, location_id, flags, fee_eur, zahlung_status)
    VALUES
      (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'normal', ?, ?, ?, ?)
  ]], {
    publicId,
    citizenIdentifier,
    citizenName,
    actorIdentifier,
    actorName,
    delegationType,
    fConfig.kategorieId,
    formularId,
    schema.formular.version or 1,
    status,
    prioritaet,
    frist,
    standortId,
    json.encode(flags),
    feeEur,
    zahlungStatus
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
    fee_eur = feeEur,
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
  local timelineText = "Antrag wurde eingereicht."
  if delegationType then
    local typLabel = {
      submit_for_citizen          = "Im Auftrag eines Bürgers",
      submit_for_company          = "Im Auftrag einer Firma",
      justice_create_for_citizen  = "Hilfsantrag (Justiz/Admin)",
    }
    timelineText = ("Antrag wurde eingereicht von %s. %s"):format(
      actorName,
      typLabel[delegationType] or ""
    )
  end
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId,
    actorIdentifier,
    actorName,
    json.encode({
      text = timelineText,
      public_id = publicId,
      status = status,
      prioritaet = prioritaet,
      delegation_typ = delegationType,
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
    actorIdentifier,
    actorName,
    "Eingereicht"
  })

  -- Audit
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  ]], {
    delegationType and "antrag.im_auftrag_eingereicht" or "antrag.eingereicht",
    actorIdentifier,
    actorName,
    spieler.job.name,
    spieler.job.grade,
    "submission",
    tostring(antragId),
    json.encode({
      public_id       = publicId,
      formular_id     = formularId,
      kategorie_id    = fConfig.kategorieId,
      standort_id     = standortId,
      fee_eur         = feeEur,
      zahlung_status  = zahlungStatus,
      delegation_typ  = delegationType,
      buerger_name    = citizenName,
      befreit         = befreit,
    })
  })

  -- SLA-Frist initialisieren (PR7 WorkflowService)
  if HM_BP.Server.Dienste.WorkflowService then
    pcall(function()
      HM_BP.Server.Dienste.WorkflowService.SlaInitialisieren(antragId, fConfig.kategorieId)
    end)
  end

  -- Gebührenbefreiung: Ledger-Eintrag (PR4, Modus "bei_entscheidung" und Befreiung greift)
  -- Bei Modus "bei_einreichung" wird das Ledger innerhalb von GebuehrAbbuchen beschrieben.
  if befreit and originalFeeEur > 0 and zahlungModus ~= "bei_einreichung"
    and HM_BP.Server.Dienste.LedgerService then
    local formTitel = schema.formular and schema.formular.titel or formularId
    pcall(function()
      HM_BP.Server.Dienste.LedgerService.Eintragen({
        antrag_id          = antragId,
        public_id          = publicId,
        citizen_identifier = citizenIdentifier,
        actor_name         = spieler.name,
        typ                = "exempt",
        betrag_eur         = originalFeeEur,
        status             = "success",
        metadata           = { form_id = formularId, formular_titel = formTitel, modus = zahlungModus },
      })
    end)
    if HM_BP.Server.Dienste.WebhookService then
      pcall(function()
        HM_BP.Server.Dienste.WebhookService.Emit("antrag_payment_befreit", {
          public_id      = publicId,
          spieler_name   = spieler.name,
          citizen_name   = citizenName,
          betrag_eur     = originalFeeEur,
          formular_titel = formTitel,
          form_id        = formularId,
          zeitpunkt      = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        })
      end)
    end
    if HM_BP.Server.Dienste.AuditService then
      pcall(function()
        HM_BP.Server.Dienste.AuditService.Log(
          "zahlung.befreit",
          spieler,
          "submission",
          tostring(antragId),
          { betrag_eur = originalFeeEur, public_id = publicId, form_id = formularId, formular_titel = formTitel },
          { actor_source = "antrag_service" }
        )
      end)
    end
  end

  -- Zahlung bei Einreichung (PR4: Modus "bei_einreichung")
  local zahlung_bei_einreichung_ergebnis = nil
  if zahlungModus == "bei_einreichung" and feeEur > 0 and HM_BP.Server.Dienste.PaymentService then
    local formTitel = schema.formular and schema.formular.titel or formularId
    local payResult = HM_BP.Server.Dienste.PaymentService.GebuehrAbbuchen(
      spieler,
      feeEur,
      {
        antrag_id      = antragId,
        public_id      = publicId,
        form_id        = formularId,
        formular_titel = formTitel,
        citizen_name   = citizenName,
        spieler_name   = spieler.name,
        category_id    = fConfig.kategorieId,
      }
    )
    zahlung_bei_einreichung_ergebnis = payResult
    if payResult and (payResult.abgezogen or payResult.befreit) then
      zahlungStatus = "bezahlt"
      HM_BP.Server.Datenbank.Ausfuehren(
        "UPDATE hm_bp_submissions SET zahlung_status = 'bezahlt', charged_at = UTC_TIMESTAMP() WHERE id = ?",
        { antragId })
    elseif payResult and not payResult.ok then
      zahlungStatus = "fehlgeschlagen"
      HM_BP.Server.Datenbank.Ausfuehren(
        "UPDATE hm_bp_submissions SET zahlung_status = 'fehlgeschlagen' WHERE id = ?",
        { antragId })
    end
  end

  -- Zahlungshinweis für den Bürger (deutsch, PR4)
  local zahlung_hinweis = nil
  if befreit then
    zahlung_hinweis = "Gebührenbefreiung aktiv – für diesen Antrag werden keine Gebühren erhoben."
  elseif feeEur > 0 then
    local origFeeEur = tonumber(schema.formular and schema.formular.fee_eur) or 0
    if origFeeEur == 0 and fConfig and fConfig.gebuehren and fConfig.gebuehren.aktiv then
      origFeeEur = math.max(0, math.floor(tonumber(fConfig.gebuehren.betrag) or 0))
    end
    if zahlungModus == "bei_einreichung" then
      zahlung_hinweis = ("Für diesen Antrag wird eine Gebühr von %d € erhoben. Die Zahlung erfolgt sofort bei Einreichung."):format(origFeeEur)
    else
      zahlung_hinweis = ("Für diesen Antrag wird eine Gebühr von %d € erhoben. Die Zahlung erfolgt nach Bearbeitung Ihres Antrags."):format(origFeeEur)
    end
  end

  return {
    id = antragId,
    public_id = publicId,
    status = status,
    prioritaet = prioritaet,
    frist = frist,
    fee_eur = feeEur,
    zahlung_status = zahlungStatus,
    delegation_typ = delegationType,
    buerger_name   = citizenName,
    befreit        = befreit,
    zahlung_hinweis = zahlung_hinweis,
    zahlung_modus  = zahlungModus,
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

-- ----------------------------------------------------------------
-- AntragService.MeineSucheAusfuehren
-- Bürger kann eigene Anträge gefiltert/paginiert suchen.
-- Sieht nur eigene Einträge (WHERE citizen_identifier = ?).
-- ----------------------------------------------------------------
-- payload-Felder:
--   query      (string: public_id LIKE ODER form_id LIKE, min 2 Zeichen)
--   status     (string oder table)
--   formular_id (string)
--   dateFrom   (YYYY-MM-DD)
--   dateTo     (YYYY-MM-DD)
--   sortBy     (created_at|updated_at)
--   sortDir    (ASC|DESC)
--   page       (number, min 1)
--   perPage    (number, max 100)
-- ----------------------------------------------------------------
function AntragService.MeineSucheAusfuehren(spieler, payload)
  payload = payload or {}

  if Config.Suche and Config.Suche.Aktiviert == false then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Suche ist deaktiviert." }
  end

  local cfgStd = (Config.Suche and Config.Suche.StandardProSeite) or 25
  local cfgMax = (Config.Suche and Config.Suche.MaxProSeite)      or 100

  local function clampN(n, mn, mx)
    n = tonumber(n)
    if not n then return mn end
    if n < mn then return mn end
    if n > mx then return mx end
    return n
  end

  local perPage = clampN(payload.perPage or cfgStd, 1, cfgMax)
  local page    = clampN(payload.page or 1, 1, 10000)
  local offset  = (page - 1) * perPage

  -- Sortierung (nur eigene Anträge: created_at/updated_at)
  local sortBy  = tostring(payload.sortBy or "created_at")
  if sortBy ~= "created_at" and sortBy ~= "updated_at" then sortBy = "created_at" end
  local sortDir = tostring(payload.sortDir or "DESC"):upper()
  if sortDir ~= "ASC" and sortDir ~= "DESC" then sortDir = "DESC" end

  -- WHERE aufbauen – Bürger sieht NUR eigene nicht-gelöschten Anträge
  local whereParts = { "citizen_identifier = ?", "deleted_at IS NULL" }
  local params     = { spieler.identifier }

  -- Status-Filter
  if payload.status and tostring(payload.status) ~= "" then
    if type(payload.status) == "table" then
      local platzhalter = {}
      for _, s in ipairs(payload.status) do
        if s and tostring(s) ~= "" then
          table.insert(platzhalter, "?")
          table.insert(params, tostring(s))
        end
      end
      if #platzhalter > 0 then
        table.insert(whereParts, "status IN (" .. table.concat(platzhalter, ",") .. ")")
      end
    else
      table.insert(whereParts, "status = ?")
      table.insert(params, tostring(payload.status))
    end
  end

  -- Formular-Filter
  if payload.formular_id and tostring(payload.formular_id) ~= "" then
    table.insert(whereParts, "form_id = ?")
    table.insert(params, tostring(payload.formular_id))
  end

  -- Zeitraum (created_at)
  if payload.dateFrom and tostring(payload.dateFrom):match("^%d%d%d%d%-%d%d%-%d%d$") then
    table.insert(whereParts, "DATE(created_at) >= ?")
    table.insert(params, payload.dateFrom)
  end
  if payload.dateTo and tostring(payload.dateTo):match("^%d%d%d%d%-%d%d%-%d%d$") then
    table.insert(whereParts, "DATE(created_at) <= ?")
    table.insert(params, payload.dateTo)
  end

  -- Freitextsuche (public_id | form_id)
  if payload.query and tostring(payload.query):gsub("%s+", "") ~= "" then
    local maxLen = (Config.Suche and Config.Suche.MaxSuchtextLaenge) or 64
    local q = tostring(payload.query):gsub("%%", ""):gsub("_", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #q > maxLen then q = q:sub(1, maxLen) end
    if #q >= 2 then
      local likeTerm = "%" .. q .. "%"
      table.insert(whereParts, "(public_id LIKE ? OR form_id LIKE ?)")
      table.insert(params, likeTerm)
      table.insert(params, likeTerm)
    end
  end

  local whereSql = table.concat(whereParts, " AND ")

  local queryParams = {}
  for _, v in ipairs(params) do table.insert(queryParams, v) end
  table.insert(queryParams, perPage)
  table.insert(queryParams, offset)

  local rows = HM_BP.Server.Datenbank.Alle(([[
    SELECT id, public_id, category_id, form_id, status, priority,
           created_at, updated_at, archived_at, zahlung_status
    FROM hm_bp_submissions
    WHERE %s
    ORDER BY %s %s
    LIMIT ? OFFSET ?
  ]]):format(whereSql, sortBy, sortDir), queryParams)

  local total = HM_BP.Server.Datenbank.Skalar(
    ("SELECT COUNT(*) FROM hm_bp_submissions WHERE %s"):format(whereSql),
    params
  ) or 0
  total = tonumber(total) or 0

  local gesamtSeiten = math.max(1, math.ceil(total / perPage))

  return {
    liste        = rows or {},
    total        = total,
    page         = page,
    perPage      = perPage,
    gesamtSeiten = gesamtSeiten,
    sortBy       = sortBy,
    sortDir      = sortDir,
  }, nil
end

HM_BP.Server.Dienste.AntragService = AntragService