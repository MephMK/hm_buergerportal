-- =============================================================
-- server/dienste/admin_ops_service.lua
--
-- Admin-Operative Verwaltung: Verschieben, Wiederherstellen,
-- Hartlöschen, Status-Überschreiben, Im-Auftrag-Erstellen,
-- Admin-übergreifende Suche.
--
-- Alle Funktionen schreiben Audit-Einträge und senden Webhooks.
-- Identifiers werden NICHT in Webhooks oder Fehlernachrichten
-- an den Client weitergegeben.
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AdminOpsService = {}

-- ----------------------------------------------------------------
-- Lokale Hilfsfunktionen
-- ----------------------------------------------------------------

local function utcJetzt()
  return os.date("!%Y-%m-%d %H:%M:%S")
end

local function istLeer(s)
  return s == nil or tostring(s):gsub("%s+", "") == ""
end

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function clamp(n, min, max)
  n = tonumber(n)
  if not n then return min end
  if n < min then return min end
  if n > max then return max end
  return n
end

local function normalizeLike(s)
  s = tostring(s or "")
  s = s:gsub("%%", ""):gsub("_", "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  local maxLen = (Config.Suche and Config.Suche.MaxSuchtextLaenge) or 64
  if #s > maxLen then s = s:sub(1, maxLen) end
  return s
end

local function validateSort(sortBy, sortDir)
  local erlaubt = {
    created_at = true, updated_at = true,
    priority = true,   status = true, sla_due_at = true,
  }
  sortBy = tostring(sortBy or "updated_at")
  if not erlaubt[sortBy] then sortBy = "updated_at" end
  sortDir = tostring(sortDir or "DESC"):upper()
  if sortDir ~= "ASC" and sortDir ~= "DESC" then sortDir = "DESC" end
  return sortBy, sortDir
end

local function validateDate(dateStr)
  if istLeer(dateStr) then return nil end
  dateStr = tostring(dateStr)
  if not dateStr:match("^%d%d%d%d%-%d%d%-%d%d$") then return nil end
  return dateStr
end

--- Timeline-Eintrag einfügen (intern, kein Sicherheitsfehler = nur log)
local function timelineEinfuegen(antragId, entryType, spieler, text)
  pcall(function()
    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_timeline
        (submission_id, entry_type, visibility, author_identifier, author_name, author_role, content)
      VALUES (?, ?, 'internal', ?, ?, 'admin', ?)
    ]], {
      antragId,
      tostring(entryType),
      spieler.identifier,
      spieler.name or spieler.identifier,
      json.encode({ text = text })
    })
  end)
end

--- Audit-Log-Eintrag schreiben
local function auditLog(aktion, spieler, targetId, daten)
  local as = HM_BP.Server.Dienste.AuditService
  if not as or not as.Log then return end
  pcall(function()
    as.Log(aktion, spieler, "submission", tostring(targetId), daten, {})
  end)
end

--- Webhook senden
local function webhookSenden(event, daten)
  local ws = HM_BP.Server.Dienste.WebhookService
  if not ws or not ws.Emit then return end
  pcall(function()
    ws.Emit(event, daten)
  end)
end

--- Antrag laden (ohne deleted Check)
local function antragLaden(antragId)
  return HM_BP.Server.Datenbank.Einzel(
    "SELECT id, public_id, category_id, form_id, status, archived_at, deleted_at FROM hm_bp_submissions WHERE id = ?",
    { antragId }
  )
end

-- ----------------------------------------------------------------
-- AdminOpsService.Verschieben
-- Ändert Kategorie und/oder Formular eines Antrags.
-- ----------------------------------------------------------------
function AdminOpsService.Verschieben(spieler, antragId, neuKategorieId, neuFormularId, grund)
  -- Validierung
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end
  if istLeer(neuKategorieId) and istLeer(neuFormularId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Neue Kategorie oder neues Formular muss angegeben werden." }
  end
  if istLeer(grund) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Begründung ist Pflichtfeld." }
  end

  local antrag = antragLaden(antragId)
  if not antrag then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if antrag.deleted_at then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Dieser Antrag wurde gelöscht und kann nicht verschoben werden." }
  end

  -- Update aufbauen
  local setParts = {}
  local params   = {}

  if not istLeer(neuKategorieId) then
    table.insert(setParts, "category_id = ?")
    table.insert(params, trim(neuKategorieId))
  end
  if not istLeer(neuFormularId) then
    table.insert(setParts, "form_id = ?")
    table.insert(params, trim(neuFormularId))
  end
  table.insert(setParts, "updated_at = UTC_TIMESTAMP()")
  table.insert(params, antragId)

  HM_BP.Server.Datenbank.Ausfuehren(
    "UPDATE hm_bp_submissions SET " .. table.concat(setParts, ", ") .. " WHERE id = ?",
    params
  )

  -- Timeline
  local detail = {}
  if not istLeer(neuKategorieId) then table.insert(detail, "Kategorie: " .. trim(neuKategorieId)) end
  if not istLeer(neuFormularId)  then table.insert(detail, "Formular: " .. trim(neuFormularId)) end
  timelineEinfuegen(antragId, "admin_verschieben", spieler,
    "Antrag verschoben: " .. table.concat(detail, ", ") .. ". Grund: " .. trim(grund))

  -- Webhook (kein Identifier)
  webhookSenden("antrag_verschoben", {
    public_id    = antrag.public_id,
    aktenzeichen = antrag.public_id,
    akteur_name  = spieler.name or "Administrator",
    category_id  = not istLeer(neuKategorieId) and trim(neuKategorieId) or antrag.category_id,
    form_id      = not istLeer(neuFormularId)  and trim(neuFormularId)  or antrag.form_id,
    text         = trim(grund),
  })

  -- Audit
  auditLog("admin.antrag.verschoben", spieler, antragId, {
    public_id       = antrag.public_id,
    neu_kategorie   = not istLeer(neuKategorieId) and trim(neuKategorieId) or nil,
    neu_formular    = not istLeer(neuFormularId)  and trim(neuFormularId)  or nil,
    alt_kategorie   = antrag.category_id,
    alt_formular    = antrag.form_id,
    grund           = trim(grund),
  })

  return true, nil
end

-- ----------------------------------------------------------------
-- AdminOpsService.Wiederherstellen
-- Hebt die Archivierung eines Antrags auf (archived_at = NULL).
-- ----------------------------------------------------------------
function AdminOpsService.Wiederherstellen(spieler, antragId, grund)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end
  if istLeer(grund) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Begründung ist Pflichtfeld." }
  end

  local antrag = antragLaden(antragId)
  if not antrag then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if not antrag.archived_at then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Dieser Antrag ist nicht archiviert und kann nicht wiederhergestellt werden." }
  end
  if antrag.deleted_at then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Dieser Antrag wurde gelöscht und kann nicht wiederhergestellt werden." }
  end

  HM_BP.Server.Datenbank.Ausfuehren(
    "UPDATE hm_bp_submissions SET archived_at = NULL, updated_at = UTC_TIMESTAMP() WHERE id = ?",
    { antragId }
  )

  timelineEinfuegen(antragId, "admin_wiederherstellen", spieler,
    "Antrag aus dem Archiv wiederhergestellt. Grund: " .. trim(grund))

  webhookSenden("antrag_wiederhergestellt", {
    public_id    = antrag.public_id,
    aktenzeichen = antrag.public_id,
    akteur_name  = spieler.name or "Administrator",
    category_id  = antrag.category_id,
    form_id      = antrag.form_id,
    text         = trim(grund),
  })

  auditLog("admin.antrag.wiederhergestellt", spieler, antragId, {
    public_id = antrag.public_id,
    grund     = trim(grund),
  })

  return true, nil
end

-- ----------------------------------------------------------------
-- AdminOpsService.HartLoeschen
-- Löscht einen Antrag unwiderruflich (Hard Delete, CASCADE).
-- ----------------------------------------------------------------
function AdminOpsService.HartLoeschen(spieler, antragId, grund)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end
  if istLeer(grund) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Begründung ist Pflichtfeld." }
  end

  -- Feature-Guard
  local archivCfg = Config.Archiv and Config.Archiv.HartLoeschen
  if archivCfg and archivCfg.Aktiviert == false then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Hartlöschen ist in der Konfiguration deaktiviert." }
  end

  local antrag = antragLaden(antragId)
  if not antrag then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  -- Audit ZUERST schreiben (vor dem Löschen)
  auditLog("admin.antrag.hartgeloescht", spieler, antragId, {
    public_id   = antrag.public_id,
    category_id = antrag.category_id,
    form_id     = antrag.form_id,
    status      = antrag.status,
    grund       = trim(grund),
  })

  webhookSenden("antrag_hartgeloescht", {
    public_id    = antrag.public_id,
    aktenzeichen = antrag.public_id,
    akteur_name  = spieler.name or "Administrator",
    category_id  = antrag.category_id,
    form_id      = antrag.form_id,
    status       = antrag.status,
    text         = trim(grund),
  })

  -- Hard Delete (CASCADE löscht Timeline, Payload, Anhänge usw.)
  HM_BP.Server.Datenbank.Ausfuehren(
    "DELETE FROM hm_bp_submissions WHERE id = ?",
    { antragId }
  )

  return true, nil
end

-- ----------------------------------------------------------------
-- AdminOpsService.StatusUeberschreiben
-- Setzt den Status eines Antrags direkt, ohne Workflow-Regeln.
-- ----------------------------------------------------------------
function AdminOpsService.StatusUeberschreiben(spieler, antragId, neuerStatus, grund)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end
  if istLeer(neuerStatus) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Neuer Status fehlt." }
  end
  if istLeer(grund) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Begründung ist Pflichtfeld." }
  end

  -- Status validieren
  if Config.Status and Config.Status.Liste then
    if not Config.Status.Liste[neuerStatus] then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiger Status." }
    end
  end

  local antrag = antragLaden(antragId)
  if not antrag then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if antrag.deleted_at then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Dieser Antrag wurde gelöscht." }
  end

  local alterStatus = antrag.status

  HM_BP.Server.Datenbank.Ausfuehren(
    "UPDATE hm_bp_submissions SET status = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?",
    { neuerStatus, antragId }
  )

  timelineEinfuegen(antragId, "admin_status_override", spieler,
    ("Status manuell überschrieben auf '%s'. Grund: %s"):format(neuerStatus, trim(grund)))

  -- Status-Historie
  pcall(function()
    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_submission_status_history
        (submission_id, old_status, new_status, changed_by_identifier, changed_by_name, comment)
      VALUES (?, ?, ?, ?, ?, ?)
    ]], { antragId, alterStatus, neuerStatus, spieler.identifier, spieler.name or spieler.identifier, trim(grund) })
  end)

  webhookSenden("admin_status_override", {
    public_id    = antrag.public_id,
    aktenzeichen = antrag.public_id,
    akteur_name  = spieler.name or "Administrator",
    alter_status = alterStatus,
    neuer_status = neuerStatus,
    category_id  = antrag.category_id,
    form_id      = antrag.form_id,
    text         = trim(grund),
  })

  auditLog("admin.antrag.status_ueberschrieben", spieler, antragId, {
    public_id    = antrag.public_id,
    alter_status = alterStatus,
    neuer_status = neuerStatus,
    grund        = trim(grund),
  })

  return true, nil
end

-- ----------------------------------------------------------------
-- AdminOpsService.ImAuftragErstellen
-- Erstellt einen Antrag für einen online befindlichen Bürger.
-- Suche NUR per Ingame-Name – kein Identifier in Rückgaben.
-- ----------------------------------------------------------------
function AdminOpsService.ImAuftragErstellen(spieler, zielIngameName, formularId, antworten, grund)
  if istLeer(zielIngameName) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ingame-Name des Bürgers fehlt." }
  end
  if istLeer(formularId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID fehlt." }
  end
  if type(antworten) ~= "table" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antworten fehlen." }
  end
  if istLeer(grund) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Begründung ist Pflichtfeld." }
  end

  -- Bürger per Ingame-Name unter allen online Spielern suchen
  local zielSource = nil
  local sucheNach  = trim(zielIngameName):lower()

  local players = GetPlayers()
  if not players then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER, nachricht = "Spielerliste konnte nicht abgerufen werden." }
  end

  for _, src in ipairs(players) do
    local srcNum = tonumber(src)
    if srcNum then
      local okN, name = pcall(GetPlayerName, srcNum)
      if okN and name and name:lower() == sucheNach then
        zielSource = srcNum
        break
      end
    end
  end

  if not zielSource then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Bürger nicht gefunden oder nicht online." }
  end

  -- Spieler-Objekt über AuthService laden
  local zielSpieler, errLaden = HM_BP.Server.Dienste.AuthService.SpielerLaden(zielSource)
  if not zielSpieler then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Bürger nicht gefunden oder nicht online." }
  end

  -- Antrag im Namen des Bürgers einreichen
  local result, errEinreichen = HM_BP.Server.Dienste.AntragService.Einreichen(
    zielSpieler,
    nil,
    formularId,
    antworten,
    nil
  )

  if not result then
    return nil, errEinreichen
  end

  -- Audit (kein Bürger-Identifier – nur Admin-Identifier + Aktionsinfo)
  auditLog("admin.antrag.im_auftrag_erstellt", spieler, result.id or 0, {
    form_id    = formularId,
    public_id  = result.public_id,
    grund      = trim(grund),
  })

  -- Webhook (nur Anzeigenamen, kein Identifier)
  webhookSenden("antrag_im_auftrag_erstellt", {
    public_id    = result.public_id,
    aktenzeichen = result.public_id,
    akteur_name  = spieler.name or "Administrator",
    buerger_name = zielSpieler.name or zielIngameName,
    form_id      = formularId,
    text         = trim(grund),
  })

  return {
    public_id  = result.public_id,
    status     = result.status,
    form_id    = formularId,
  }, nil
end

-- ----------------------------------------------------------------
-- AdminOpsService.AdminSuchen
-- Adminübergreifende Suche ohne Kategorieeinschränkung.
-- ----------------------------------------------------------------
function AdminOpsService.AdminSuchen(spieler, payload)
  payload = payload or {}

  if Config.Suche and Config.Suche.Aktiviert == false then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Suche ist deaktiviert." }
  end

  local cfgStd = (Config.Suche and Config.Suche.StandardProSeite) or 25
  local cfgMax = (Config.Suche and Config.Suche.MaxProSeite)      or 100

  local perPage = clamp(payload.perPage or cfgStd, 1, cfgMax)
  local page    = clamp(payload.page or 1, 1, 10000)
  local offset  = (page - 1) * perPage

  local sortBy, sortDir = validateSort(payload.sortBy, payload.sortDir)

  -- WHERE aufbauen
  local whereParts = { "deleted_at IS NULL" }
  local params     = {}

  -- Kategoriefilter (optional)
  if not istLeer(payload.kategorie_id) then
    table.insert(whereParts, "category_id = ?")
    table.insert(params, trim(payload.kategorie_id))
  end

  -- Formularfilter (optional)
  if not istLeer(payload.formular_id) then
    table.insert(whereParts, "form_id = ?")
    table.insert(params, trim(payload.formular_id))
  end

  -- Archiv/Queue-Filter
  local nurArchiv = payload.archiv == true or payload.archiv == "true"
  if nurArchiv then
    table.insert(whereParts, "archived_at IS NOT NULL")
  else
    table.insert(whereParts, "archived_at IS NULL")
  end

  -- Status
  if not istLeer(payload.status) then
    if type(payload.status) == "table" then
      local platzhalter = {}
      for _, s in ipairs(payload.status) do
        if not istLeer(s) then
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

  -- Zahlungsstatus
  if not istLeer(payload.zahlungStatus) then
    local zs = tostring(payload.zahlungStatus)
    if zs == "bezahlt" or zs == "unbezahlt" or zs == "befreit" then
      table.insert(whereParts, "zahlung_status = ?")
      table.insert(params, zs)
    end
  end

  -- Zeitraum
  local dateFrom = validateDate(payload.dateFrom)
  local dateTo   = validateDate(payload.dateTo)
  if dateFrom then
    table.insert(whereParts, "DATE(created_at) >= ?")
    table.insert(params, dateFrom)
  end
  if dateTo then
    table.insert(whereParts, "DATE(created_at) <= ?")
    table.insert(params, dateTo)
  end

  -- Freitextsuche (citizen_name | public_id | form_id)
  if not istLeer(payload.query) then
    local q = normalizeLike(payload.query)
    if #q >= 2 then
      local likeTerm = "%" .. q .. "%"
      table.insert(whereParts, "(citizen_name LIKE ? OR public_id LIKE ? OR form_id LIKE ?)")
      table.insert(params, likeTerm)
      table.insert(params, likeTerm)
      table.insert(params, likeTerm)
    end
  end

  -- Flags
  if payload.eskaliert == true or payload.eskaliert == "true" then
    table.insert(whereParts, "escalated_at IS NOT NULL")
  end
  if payload.ueberfaellig == true or payload.ueberfaellig == "true" then
    table.insert(whereParts, "sla_due_at IS NOT NULL AND sla_due_at < NOW()")
  end

  -- SQL-Sortierung
  local sortMap = {
    created_at = "created_at", updated_at = "updated_at",
    priority   = "priority",   status     = "status", sla_due_at = "sla_due_at",
  }
  local sortSql = sortMap[sortBy] or "updated_at"

  local whereSql = table.concat(whereParts, " AND ")

  local queryParams = {}
  for _, v in ipairs(params) do table.insert(queryParams, v) end
  table.insert(queryParams, perPage)
  table.insert(queryParams, offset)

  local rows = HM_BP.Server.Datenbank.Alle(([[
    SELECT id, public_id, citizen_name, category_id, form_id, status, priority,
           created_at, updated_at, assigned_to_name, archived_at,
           escalated_at, sla_due_at, zahlung_status, due_state
    FROM hm_bp_submissions
    WHERE %s
    ORDER BY %s %s
    LIMIT ? OFFSET ?
  ]]):format(whereSql, sortSql, sortDir), queryParams)

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

HM_BP.Server.Dienste.AdminOpsService = AdminOpsService
