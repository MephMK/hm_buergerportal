HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local JustizSucheService = {}

local function clamp(n, min, max)
  n = tonumber(n)
  if not n then return min end
  if n < min then return min end
  if n > max then return max end
  return n
end

local function istLeer(s)
  return s == nil or tostring(s):gsub("%s+", "") == ""
end

local function normalizeLike(s)
  s = tostring(s or "")
  -- LIKE-Wildcards entfernen (Missbrauch/Performance)
  s = s:gsub("%%", ""):gsub("_", "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if #s > 64 then s = s:sub(1, 64) end
  return s
end

local function validateSort(sortBy, sortDir)
  local erlaubt = {
    created_at = true,
    updated_at = true,
    priority = true,
    status = true
  }

  sortBy = tostring(sortBy or "updated_at")
  if not erlaubt[sortBy] then sortBy = "updated_at" end

  sortDir = tostring(sortDir or "DESC"):upper()
  if sortDir ~= "ASC" and sortDir ~= "DESC" then sortDir = "DESC" end

  return sortBy, sortDir
end

local function validateQueue(queue)
  queue = tostring(queue or "eingang")
  if queue ~= "eingang" and queue ~= "zugewiesen" and queue ~= "alle" and queue ~= "archiv" then
    queue = "eingang"
  end
  return queue
end

local function validateDate(dateStr)
  if istLeer(dateStr) then return nil end
  dateStr = tostring(dateStr)
  -- akzeptiere YYYY-MM-DD
  if not dateStr:match("^%d%d%d%d%-%d%d%-%d%d$") then return nil end
  return dateStr
end

local function prioritaetErlaubt(prio)
  if istLeer(prio) then return true end
  if not (Config.Prioritaeten and Config.Prioritaeten.Aktiviert and type(Config.Prioritaeten.Liste) == "table") then
    return true
  end
  for _, p in ipairs(Config.Prioritaeten.Liste) do
    if p.id == prio then return true end
  end
  return false
end

local function statusErlaubtFuerKategorie(kategorieId, status)
  if istLeer(status) then return true end
  local k = Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]
  if not k or type(k.erlaubteStatus) ~= "table" or #k.erlaubteStatus == 0 then
    -- wenn nicht konfiguriert -> Statusliste global; wir lassen es zu
    return true
  end
  for _, s in ipairs(k.erlaubteStatus) do
    if s == status then return true end
  end
  return false
end

-- Baut WHERE-Teil abhängig von Queue (eingang/zugewiesen/alle/archiv)
local function queueWhere(queue, spieler)
  if queue == "eingang" then
    return "archived_at IS NULL AND deleted_at IS NULL", {}
  end

  if queue == "zugewiesen" then
    return "archived_at IS NULL AND deleted_at IS NULL AND assigned_to_identifier = ?", { spieler.identifier }
  end

  if queue == "alle" then
    return "deleted_at IS NULL", {}
  end

  if queue == "archiv" then
    return "archived_at IS NOT NULL AND deleted_at IS NULL", {}
  end

  return "archived_at IS NULL AND deleted_at IS NULL", {}
end

function JustizSucheService.Suchen(spieler, payload)
  payload = payload or {}

  local kategorieId = payload.kategorieId
  if istLeer(kategorieId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Kategorie-ID fehlt." }
  end

  local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, kategorieId)
  if not regeln or regeln.erlaubt ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf diese Kategorie." }
  end

  local queue = validateQueue(payload.queue)

  -- Queue-Recht erzwingen
  if queue == "eingang" and regeln.sehen.eingang ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf Eingang." }
  end
  if queue == "zugewiesen" and regeln.sehen.zugewiesen ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf zugewiesen." }
  end
  if queue == "alle" and regeln.sehen.alleKategorie ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf alle Anträge." }
  end
  if queue == "archiv" and regeln.sehen.archiv ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf Archiv." }
  end

  local limit = clamp(payload.limit or 50, 1, 100)
  local offset = clamp(payload.offset or 0, 0, 5000)

  local sortBy, sortDir = validateSort(payload.sortBy, payload.sortDir)

  local status = payload.status
  if not istLeer(status) and not statusErlaubtFuerKategorie(kategorieId, status) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiger Status für diese Kategorie." }
  end

  local prio = payload.prio
  if not istLeer(prio) and not prioritaetErlaubt(prio) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültige Priorität." }
  end

  -- Suche: NUR Bürgername (citizen_name)
  local suchText = nil
  if not istLeer(payload.query) then
    local q = normalizeLike(payload.query)
    if #q >= 2 then
      suchText = q
    end
  end

  local dateFrom = validateDate(payload.dateFrom)
  local dateTo = validateDate(payload.dateTo)

  local whereParts = { "category_id = ?" }
  local params = { kategorieId }

  -- Queue filter
  local qWhere, qParams = queueWhere(queue, spieler)
  table.insert(whereParts, qWhere)
  for _, p in ipairs(qParams) do table.insert(params, p) end

  -- Status/Priorität
  if not istLeer(status) then
    table.insert(whereParts, "status = ?")
    table.insert(params, status)
  end

  if not istLeer(prio) then
    table.insert(whereParts, "priority = ?")
    table.insert(params, prio)
  end

  -- Date range (created_at)
  if dateFrom then
    table.insert(whereParts, "DATE(created_at) >= ?")
    table.insert(params, dateFrom)
  end
  if dateTo then
    table.insert(whereParts, "DATE(created_at) <= ?")
    table.insert(params, dateTo)
  end

  -- Query: NUR citizen_name
  if suchText then
    table.insert(whereParts, "(citizen_name LIKE ?)")
    local like = "%" .. suchText .. "%"
    table.insert(params, like)
  end

  local whereSql = table.concat(whereParts, " AND ")

  -- Sort mapping
  local sortSql = "updated_at"
  if sortBy == "created_at" then sortSql = "created_at" end
  if sortBy == "updated_at" then sortSql = "updated_at" end
  if sortBy == "priority" then sortSql = "priority" end
  if sortBy == "status" then sortSql = "status" end

  local rows = HM_BP.Server.Datenbank.Alle(([[
    SELECT id, public_id, citizen_name, citizen_identifier, category_id, form_id, status, priority,
           created_at, updated_at, assigned_to_name, assigned_to_identifier, archived_at
    FROM hm_bp_submissions
    WHERE %s
    ORDER BY %s %s
    LIMIT ? OFFSET ?
  ]]):format(whereSql, sortSql, sortDir), (function()
    local p = {}
    for _, v in ipairs(params) do table.insert(p, v) end
    table.insert(p, limit)
    table.insert(p, offset)
    return p
  end)())

  local total = HM_BP.Server.Datenbank.Skalar(("SELECT COUNT(*) FROM hm_bp_submissions WHERE %s"):format(whereSql), params) or 0

  return {
    liste = rows or {},
    total = tonumber(total) or 0,
    limit = limit,
    offset = offset,
    queue = queue,
    sortBy = sortBy,
    sortDir = sortDir
  }, nil
end

HM_BP.Server.Dienste.JustizSucheService = JustizSucheService