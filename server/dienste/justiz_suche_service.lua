HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local JustizSucheService = {}

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

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
  -- LIKE-Wildcards und Sonderzeichen entfernen (Missbrauch/Performance-Schutz)
  s = s:gsub("%%", ""):gsub("_", "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  local maxLen = (Config.Suche and Config.Suche.MaxSuchtextLaenge) or 64
  if #s > maxLen then s = s:sub(1, maxLen) end
  return s
end

local function validateSort(sortBy, sortDir)
  local erlaubt = {
    created_at = true,
    updated_at = true,
    priority   = true,
    status     = true,
    sla_due_at = true,
  }

  sortBy = tostring(sortBy or "updated_at")
  if not erlaubt[sortBy] then sortBy = "updated_at" end

  sortDir = tostring(sortDir or "DESC"):upper()
  if sortDir ~= "ASC" and sortDir ~= "DESC" then sortDir = "DESC" end

  return sortBy, sortDir
end

local function validateQueue(queue)
  queue = tostring(queue or "eingang")
  if queue ~= "eingang" and queue ~= "zugewiesen" and queue ~= "alle" and queue ~= "archiv"
     and queue ~= "genehmigt" and queue ~= "abgelehnt" then
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
    -- wenn nicht konfiguriert -> globale Statusliste; zulassen
    return true
  end
  for _, s in ipairs(k.erlaubteStatus) do
    if s == status then return true end
  end
  return false
end

-- Baut WHERE-Teil abhängig von Queue (eingang/zugewiesen/alle/archiv/genehmigt/abgelehnt)
local function queueWhere(queue, spieler)
  if queue == "eingang" then
    return "archived_at IS NULL AND deleted_at IS NULL AND status NOT IN ('approved','rejected','withdrawn','closed','archived')", {}
  end

  if queue == "zugewiesen" then
    return "archived_at IS NULL AND deleted_at IS NULL AND assigned_to_identifier = ? AND status NOT IN ('approved','rejected','withdrawn','closed','archived')", { spieler.identifier }
  end

  if queue == "alle" then
    return "deleted_at IS NULL", {}
  end

  if queue == "archiv" then
    return "archived_at IS NOT NULL AND deleted_at IS NULL", {}
  end

  if queue == "genehmigt" then
    return "deleted_at IS NULL AND status = 'approved'", {}
  end

  if queue == "abgelehnt" then
    return "deleted_at IS NULL AND status = 'rejected'", {}
  end

  return "archived_at IS NULL AND deleted_at IS NULL AND status NOT IN ('approved','rejected','withdrawn','closed','archived')", {}
end

-- ----------------------------------------------------------------
-- JustizSucheService.Suchen
-- ----------------------------------------------------------------
-- payload-Felder:
--   kategorieId    (string, Pflicht)
--   queue          (string: eingang|zugewiesen|alle|archiv)
--   query          (string: citizen_name ODER public_id ODER form_id LIKE-Suche, min 2 Zeichen)
--   status         (string oder table: ein oder mehrere Status-IDs)
--   prio           (string)
--   dateFrom       (YYYY-MM-DD)
--   dateTo         (YYYY-MM-DD)
--   sortBy         (created_at|updated_at|priority|status|sla_due_at)
--   sortDir        (ASC|DESC)
--   page           (number, min 1)
--   perPage        (number, 1–MaxProSeite aus Config.Suche)
--   bearbeiter     ("" = alle | "unbearbeitet" = kein Bearbeiter |
--                   "zugewiesen" = hat Bearbeiter | sonstiger Text = Name LIKE)
--   eskaliert      (boolean/truthy)
--   ueberfaellig   (boolean/truthy)
--   zahlungStatus  (string: "bezahlt"|"unbezahlt"|"befreit"|"" = alle)
-- ----------------------------------------------------------------
function JustizSucheService.Suchen(spieler, payload)
  payload = payload or {}

  -- Suche global deaktiviert?
  if Config.Suche and Config.Suche.Aktiviert == false then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Suche ist deaktiviert." }
  end

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
  if queue == "genehmigt" and regeln.sehen.genehmigt ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf genehmigte Anträge." }
  end
  if queue == "abgelehnt" and regeln.sehen.abgelehnt ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Kein Zugriff auf abgelehnte Anträge." }
  end

  -- Seitenparameter aus Config.Suche
  local cfgStd = (Config.Suche and Config.Suche.StandardProSeite) or 25
  local cfgMax = (Config.Suche and Config.Suche.MaxProSeite) or 100

  local perPage = clamp(payload.perPage or cfgStd, 1, cfgMax)
  local page    = clamp(payload.page or 1, 1, 10000)
  local offset  = (page - 1) * perPage

  local sortBy, sortDir = validateSort(payload.sortBy, payload.sortDir)

  -- Status: erlaubt einzeln oder als Tabelle (Mehrfachauswahl)
  local statusFilter = {}
  if not istLeer(payload.status) then
    if type(payload.status) == "table" then
      for _, s in ipairs(payload.status) do
        if not istLeer(s) and statusErlaubtFuerKategorie(kategorieId, tostring(s)) then
          table.insert(statusFilter, tostring(s))
        end
      end
    else
      local s = tostring(payload.status)
      if statusErlaubtFuerKategorie(kategorieId, s) then
        table.insert(statusFilter, s)
      else
        return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiger Status für diese Kategorie." }
      end
    end
  end

  local prio = payload.prio
  if not istLeer(prio) and not prioritaetErlaubt(prio) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültige Priorität." }
  end

  -- Suche: citizen_name ODER public_id ODER form_id via LIKE
  local suchText = nil
  if not istLeer(payload.query) then
    local q = normalizeLike(payload.query)
    if #q >= 2 then
      suchText = q
    end
  end

  local dateFrom = validateDate(payload.dateFrom)
  local dateTo   = validateDate(payload.dateTo)

  -- Bearbeiter-Filter:
  --   ""              = alle
  --   "unbearbeitet"  = kein Bearbeiter zugewiesen
  --   "zugewiesen"    = hat Bearbeiter (egal wer)
  --   sonstiger Text  = Bearbeitername LIKE-Suche (min. 2 Zeichen)
  local bearbeiterFilter = nil
  if not istLeer(payload.bearbeiter) then
    bearbeiterFilter = tostring(payload.bearbeiter):gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- Flags
  local nurEskaliert    = payload.eskaliert == true or payload.eskaliert == "true"
  local nurUeberfaellig = payload.ueberfaellig == true or payload.ueberfaellig == "true"

  -- Zahlungsstatus-Filter
  local zahlungStatusFilter = nil
  if not istLeer(payload.zahlungStatus) then
    local zs = tostring(payload.zahlungStatus)
    if zs == "bezahlt" or zs == "unbezahlt" or zs == "befreit" then
      zahlungStatusFilter = zs
    end
  end

  -- ----------------------------------------------------------------
  -- WHERE-Klausel aufbauen
  -- ----------------------------------------------------------------
  local whereParts = { "category_id = ?" }
  local params = { kategorieId }

  -- Queue filter
  local qWhere, qParams = queueWhere(queue, spieler)
  table.insert(whereParts, qWhere)
  for _, p in ipairs(qParams) do table.insert(params, p) end

  -- Status (Mehrfachauswahl mit IN)
  if #statusFilter == 1 then
    table.insert(whereParts, "status = ?")
    table.insert(params, statusFilter[1])
  elseif #statusFilter > 1 then
    local platzhalter = {}
    for _, s in ipairs(statusFilter) do
      table.insert(platzhalter, "?")
      table.insert(params, s)
    end
    table.insert(whereParts, "status IN (" .. table.concat(platzhalter, ",") .. ")")
  end

  -- Priorität
  if not istLeer(prio) then
    table.insert(whereParts, "priority = ?")
    table.insert(params, prio)
  end

  -- Zeitraum (created_at)
  if dateFrom then
    table.insert(whereParts, "DATE(created_at) >= ?")
    table.insert(params, dateFrom)
  end
  if dateTo then
    table.insert(whereParts, "DATE(created_at) <= ?")
    table.insert(params, dateTo)
  end

  -- Suche: citizen_name ODER public_id ODER form_id via LIKE
  if suchText then
    local likeTerm = "%" .. suchText .. "%"
    table.insert(whereParts, "(citizen_name LIKE ? OR public_id LIKE ? OR form_id LIKE ?)")
    table.insert(params, likeTerm)
    table.insert(params, likeTerm)
    table.insert(params, likeTerm)
  end

  -- Bearbeiter-Filter
  if bearbeiterFilter == "unbearbeitet" then
    table.insert(whereParts, "assigned_to_identifier IS NULL")
  elseif bearbeiterFilter == "zugewiesen" then
    table.insert(whereParts, "assigned_to_identifier IS NOT NULL")
  elseif bearbeiterFilter and #bearbeiterFilter >= 2 then
    local bLike = normalizeLike(bearbeiterFilter)
    table.insert(whereParts, "assigned_to_name LIKE ?")
    table.insert(params, "%" .. bLike .. "%")
  end

  -- Flags
  if nurEskaliert then
    table.insert(whereParts, "escalated_at IS NOT NULL")
  end
  if nurUeberfaellig then
    table.insert(whereParts, "sla_due_at IS NOT NULL AND sla_due_at < NOW()")
  end

  -- Zahlungsstatus-Filter
  if zahlungStatusFilter then
    table.insert(whereParts, "zahlung_status = ?")
    table.insert(params, zahlungStatusFilter)
  end

  -- Formular-ID-Filter (exakter Match, wenn gesetzt)
  if not istLeer(payload.formularId) then
    local fid = tostring(payload.formularId):gsub("^%s+", ""):gsub("%s+$", "")
    if fid ~= "" then
      table.insert(whereParts, "form_id = ?")
      table.insert(params, fid)
    end
  end

  -- ----------------------------------------------------------------
  -- SQL ausführen
  -- ----------------------------------------------------------------
  local whereSql = table.concat(whereParts, " AND ")

  local sortSql = "updated_at"
  if sortBy == "created_at" then sortSql = "created_at" end
  if sortBy == "updated_at" then sortSql = "updated_at" end
  if sortBy == "priority"   then sortSql = "priority" end
  if sortBy == "status"     then sortSql = "status" end
  if sortBy == "sla_due_at" then sortSql = "sla_due_at" end

  -- queryParams = params + LIMIT + OFFSET (nur für SELECT benötigt).
  -- params bleibt unverändert und wird für das COUNT-Query wiederverwendet.
  local queryParams = {}
  for _, v in ipairs(params) do table.insert(queryParams, v) end
  table.insert(queryParams, perPage)
  table.insert(queryParams, offset)

  local rows = HM_BP.Server.Datenbank.Alle(([[
    SELECT id, public_id, citizen_name, citizen_identifier, category_id, form_id, status, priority,
           created_at, updated_at, assigned_to_name, assigned_to_identifier, archived_at,
           escalated_at, sla_due_at, needs_leitung, due_state
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
    queue        = queue,
    sortBy       = sortBy,
    sortDir      = sortDir,
  }, nil
end

HM_BP.Server.Dienste.JustizSucheService = JustizSucheService
