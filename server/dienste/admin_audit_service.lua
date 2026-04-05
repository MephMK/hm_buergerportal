-- =============================================================
-- server/dienste/admin_audit_service.lua
--
-- Schreibt Admin-Audit-Einträge in data/admin_audit.log (JSONL).
-- Jede Zeile ist ein JSON-Objekt.
--
-- Felder:
--   timestamp      ISO-8601 UTC
--   request_id     Zufällige Korrelations-ID (8 Zeichen hex)
--   aktion         z.B. "sektion.speichern"
--   sektion        z.B. "Standorte"
--   actor_identifier, actor_name, actor_job, actor_grade
--   grund          Pflichtfeld – warum die Änderung
--   diff_alt       JSON-String des alten Werts (oder leer)
--   diff_neu       JSON-String des neuen Werts (oder leer)
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AdminAuditService = {}

local AUDIT_FILE    = "data/admin_audit.log"
local RESOURCE_NAME = GetCurrentResourceName()
local MAX_EINTRAEGE = 2000   -- maximale Zeilen im Memory-Puffer

-- In-Memory-Puffer der Einträge (wird beim Start aus Datei befüllt)
local eintraege = {}
local initialisiert = false

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

local function nowIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function requestId()
  local t = os.time()
  local r = math.random(0, 0xFFFF)
  return string.format("%08x%04x", t, r)
end

local function safeEncode(val)
  if val == nil then return "" end
  local ok, res = pcall(json.encode, val)
  return ok and (res or "") or ""
end

-- Lädt bestehende Einträge aus der Log-Datei
local function logLaden()
  local raw = LoadResourceFile(RESOURCE_NAME, AUDIT_FILE)
  if not raw or raw == "" then return {} end

  local liste = {}
  for zeile in raw:gmatch("[^\n]+") do
    zeile = zeile:match("^%s*(.-)%s*$")  -- trim
    if zeile ~= "" then
      local ok, entry = pcall(json.decode, zeile)
      if ok and type(entry) == "table" then
        table.insert(liste, entry)
      end
    end
  end
  return liste
end

-- Schreibt alle Einträge in die Log-Datei (JSONL)
local function logPersistieren()
  local zeilen = {}
  for _, e in ipairs(eintraege) do
    local ok, zeile = pcall(json.encode, e)
    if ok and zeile then
      table.insert(zeilen, zeile)
    end
  end
  local inhalt = table.concat(zeilen, "\n")
  if #inhalt > 0 then inhalt = inhalt .. "\n" end
  SaveResourceFile(RESOURCE_NAME, AUDIT_FILE, inhalt, #inhalt)
end

-- ----------------------------------------------------------------
-- Öffentliche API
-- ----------------------------------------------------------------

---Initialisiert den AdminAuditService: lädt vorhandene Einträge.
function AdminAuditService.Init()
  if initialisiert then return end
  initialisiert = true
  eintraege = logLaden()
  if Config and Config.Kern and Config.Kern.Debugmodus then
    print(("[AdminAuditService] %d bestehende Audit-Einträge geladen."):format(#eintraege))
  end
end

---Schreibt einen Audit-Eintrag.
---@param aktion  string   z.B. "sektion.speichern"
---@param spieler table    Spieler-Kontext
---@param grund   string   Pflicht-Begründung
---@param sektion string?  Betroffene Sektion (optional)
---@param altDaten any?    Alter Wert (optional, wird als JSON-String gespeichert)
---@param neuDaten any?    Neuer Wert (optional, wird als JSON-String gespeichert)
---@return boolean ok
function AdminAuditService.Log(aktion, spieler, grund, sektion, altDaten, neuDaten)
  if not aktion or aktion == "" then return false end
  if not grund  or grund  == "" then return false end

  local eintrag = {
    timestamp        = nowIso(),
    request_id       = requestId(),
    aktion           = tostring(aktion),
    sektion          = sektion and tostring(sektion) or nil,
    actor_identifier = spieler and tostring(spieler.identifier or "system") or "system",
    actor_name       = spieler and tostring(spieler.name      or "system") or "system",
    actor_job        = spieler and spieler.job and spieler.job.name  or nil,
    actor_grade      = spieler and spieler.job and spieler.job.grade or nil,
    grund            = tostring(grund),
    diff_alt         = (altDaten ~= nil) and safeEncode(altDaten) or nil,
    diff_neu         = (neuDaten ~= nil) and safeEncode(neuDaten) or nil,
  }

  table.insert(eintraege, eintrag)

  -- Puffer begrenzen (älteste Einträge entfernen)
  while #eintraege > MAX_EINTRAEGE do
    table.remove(eintraege, 1)
  end

  -- Asynchron in Datei schreiben (kein Blockieren)
  SetTimeout(0, function()
    logPersistieren()
  end)

  if Config and Config.Kern and Config.Kern.Debugmodus then
    print(("[AdminAudit] %s von %s – %s"):format(
      tostring(aktion),
      eintrag.actor_identifier,
      tostring(grund)
    ))
  end

  return true
end

---Gibt die letzten N Einträge zurück.
---@param limit number? Maximale Anzahl Einträge (Standard: 100)
---@return table[]
function AdminAuditService.Holen(limit)
  limit = tonumber(limit) or 100
  if limit > MAX_EINTRAEGE then limit = MAX_EINTRAEGE end

  local start = math.max(1, #eintraege - limit + 1)
  local result = {}
  for i = start, #eintraege do
    table.insert(result, eintraege[i])
  end
  -- Neueste zuerst
  local rev = {}
  for i = #result, 1, -1 do
    table.insert(rev, result[i])
  end
  return rev
end

HM_BP.Server.Dienste.AdminAuditService = AdminAuditService
