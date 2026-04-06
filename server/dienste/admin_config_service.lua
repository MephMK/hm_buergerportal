-- =============================================================
-- server/dienste/admin_config_service.lua
--
-- Verwaltet die effektive Config:
--   - Basisconfig aus config.lua (wird beim Init einmalig gesnapshott)
--   - Overrides aus data/admin_overrides.json
--   - Effektive Config = tiefes Merge(Basis, Overrides)
--
-- Beim Start  : Init() → Snapshot → Overrides laden → Config anwenden
-- Bei Änderung: SektionSpeichern() → Override-Datei schreiben → Config neu mergen
-- Neuladen    : Neuladen() → liest Datei neu und wendet an
--
-- Alle Dienste lesen weiterhin aus der globalen Config-Tabelle
-- (keine Refaktorierung der Dienste notwendig).
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AdminConfigService = {}

local OVERRIDES_FILE  = "data/admin_overrides.json"
local RESOURCE_NAME   = GetCurrentResourceName()

-- Verwaltete Config-Sektionen (werden gemergt)
local MANAGED_SECTIONS = {
  "Kern", "Module",
  "Standorte", "Kategorien", "Formulare", "Permissions", "Status", "Webhooks", "Workflows", "Anhaenge",
  "Suche", "JobSettings", "Integrationen"
}

-- In-Memory-Snapshot der originalen Basis-Config (vor jedem Merge)
local baseConfigSnapshot = {}

-- Aktuell in der Datei persistierter Override-Stand
local currentOverrides = {}

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

-- Tiefes Merge: overlay-Werte überschreiben/ergänzen base-Werte rekursiv.
-- Nicht-Tabellen-Werte im overlay überschreiben einfach den base-Wert.
local function tiefMerge(base, overlay)
  if type(overlay) ~= "table" then return overlay end
  if type(base)    ~= "table" then base = {} end

  local result = {}
  for k, v in pairs(base) do
    result[k] = v
  end
  for k, v in pairs(overlay) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = tiefMerge(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

-- Tiefe Kopie einer Tabelle über JSON-Runde (verliert keine primitiven Typen).
-- vector3 wird dabei zu {x,y,z}-Tabelle – das ist für den Snapshot gewollt,
-- weil wir später beim Anwenden sowieso konvertieren.
local function tiefKopie(tbl)
  if type(tbl) ~= "table" then return tbl end
  local ok, copy = pcall(function()
    return json.decode(json.encode(tbl))
  end)
  if ok and type(copy) == "table" then return copy end
  return tbl
end

-- Maximale Rekursionstiefe beim Traversieren verschachtelter Tabellen (Schutz vor zyklischen
-- Referenzen oder extrem tiefen Strukturen in Konfigurationsdaten).
local MAX_VEKTOR_TIEFE = 12

-- Wandelt JSON-deserialisierte Koordinaten-Tabellen zurück in vector3/vector4.
-- FiveM serialisiert vector3 als {"x":..,"y":..,"z":..}; nach json.decode
-- brauchen wir native vector3-Werte für koordinaten, startPosition etc.
local function fixVektoren(tbl, tiefe)
  tiefe = tiefe or 0
  if tiefe > MAX_VEKTOR_TIEFE then return tbl end
  if type(tbl) ~= "table" then return tbl end

  -- Ist diese Tabelle selbst ein {x,y,z[,w]}-Objekt?
  local function istVektor(t)
    if type(t) ~= "table" then return false end
    local n = 0
    for k in pairs(t) do n = n + 1 end
    -- genau x,y,z oder x,y,z,w
    if (n == 3 and t.x ~= nil and t.y ~= nil and t.z ~= nil) then return "v3" end
    if (n == 4 and t.x ~= nil and t.y ~= nil and t.z ~= nil and t.w ~= nil) then return "v4" end
    return false
  end

  local result = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      local vt = istVektor(v)
      if vt == "v3" then
        result[k] = vector3(tonumber(v.x) or 0, tonumber(v.y) or 0, tonumber(v.z) or 0)
      elseif vt == "v4" then
        result[k] = vector4(tonumber(v.x) or 0, tonumber(v.y) or 0, tonumber(v.z) or 0, tonumber(v.w) or 0)
      else
        result[k] = fixVektoren(v, tiefe + 1)
      end
    else
      result[k] = v
    end
  end
  return result
end

-- ----------------------------------------------------------------
-- Dateizugriff
-- ----------------------------------------------------------------

local function overridesLaden()
  local raw = LoadResourceFile(RESOURCE_NAME, OVERRIDES_FILE)
  if not raw or raw == "" then return {} end

  local ok, data = pcall(json.decode, raw)
  if not ok or type(data) ~= "table" then
    print(("[AdminConfigService] WARN: %s ungültig/korrumpiert – Overrides ignoriert."):format(OVERRIDES_FILE))
    return {}
  end
  return data
end

local function overridesSpeichern(overrides)
  local ok_enc, encoded = pcall(json.encode, overrides, { indent = true })
  if not ok_enc or not encoded then
    return false, "JSON-Encode fehlgeschlagen"
  end

  -- Backup der bestehenden Datei
  local oldRaw = LoadResourceFile(RESOURCE_NAME, OVERRIDES_FILE)
  if oldRaw and oldRaw ~= "" then
    SaveResourceFile(RESOURCE_NAME, OVERRIDES_FILE .. ".bak", oldRaw, #oldRaw)
  end

  local ok_save = SaveResourceFile(RESOURCE_NAME, OVERRIDES_FILE, encoded, #encoded)
  if not ok_save then
    return false, "SaveResourceFile fehlgeschlagen (Verzeichnis 'data/' muss vorhanden sein)"
  end
  return true, nil
end

-- ----------------------------------------------------------------
-- Merge auf globale Config anwenden
-- ----------------------------------------------------------------

local function configAnwenden(overrides)
  for _, sek in ipairs(MANAGED_SECTIONS) do
    local base    = baseConfigSnapshot[sek]
    local overlay = overrides[sek]
    if overlay ~= nil then
      -- Merge von Basisconfig + Override
      local merged = tiefMerge(base or {}, overlay)
      -- Koordinaten-Objekte zurück in native vector-Typen konvertieren
      Config[sek] = fixVektoren(merged)
    elseif base ~= nil then
      -- Kein Override: trotzdem den gesnapshoteten Basiswert zurückschreiben
      -- (schützt vor versehentlichem Verschlucken durch einen früheren Merge)
      Config[sek] = fixVektoren(tiefKopie(base))
    end
  end
end

-- ----------------------------------------------------------------
-- Öffentliche API
-- ----------------------------------------------------------------

---Initialisiert den AdminConfigService.
--- Snapshottet Basisconfig, lädt Overrides, wendet sie auf Config an.
function AdminConfigService.Init()
  -- Basisconfig snapshotten (BEVOR irgendwelche Overrides angewandt werden)
  for _, sek in ipairs(MANAGED_SECTIONS) do
    if Config[sek] ~= nil then
      baseConfigSnapshot[sek] = tiefKopie(Config[sek])
    end
  end

  currentOverrides = overridesLaden()
  configAnwenden(currentOverrides)

  if Config and Config.Kern and Config.Kern.Debugmodus then
    local n = 0
    for _ in pairs(currentOverrides) do n = n + 1 end
    print(("[AdminConfigService] Init: %d Override-Sektion(en) aus '%s' geladen."):format(n, OVERRIDES_FILE))
  end
end

---Gibt die globale Config zurück (enthält bereits alle angewandten Overrides).
---@return table
function AdminConfigService.GetEffectiveConfig()
  return Config
end

---Gibt den Override-Stand einer oder aller Sektionen zurück.
---@param sektion string|nil  z.B. "Standorte"; nil → alle Sektionen
---@return table
function AdminConfigService.GetOverrides(sektion)
  if sektion then
    return currentOverrides[sektion] or {}
  end
  return currentOverrides
end

---Gibt den Basis-Snapshot einer Sektion zurück (vor Overrides).
---@param sektion string
---@return table
function AdminConfigService.GetBasis(sektion)
  if sektion then
    return baseConfigSnapshot[sektion] or {}
  end
  return baseConfigSnapshot
end

---Speichert neue Override-Daten für eine Sektion und wendet sie sofort an.
---@param sektion string   z.B. "Standorte"
---@param daten   table    Neue Override-Daten für diese Sektion
---@return boolean ok
---@return string? fehler
function AdminConfigService.SektionSpeichern(sektion, daten)
  if type(sektion) ~= "string" or sektion == "" then
    return false, "Ungültige Sektion"
  end
  if type(daten) ~= "table" then
    return false, "Daten müssen eine Tabelle sein"
  end

  -- In-Memory aktualisieren
  currentOverrides[sektion] = daten

  -- Datei schreiben
  local ok, err = overridesSpeichern(currentOverrides)
  if not ok then
    -- Rollback in-memory
    currentOverrides[sektion] = overridesLaden()[sektion] or nil
    return false, ("Persistenz fehlgeschlagen: %s"):format(tostring(err))
  end

  -- Config sofort neu mergen
  configAnwenden(currentOverrides)
  return true, nil
end

---Löscht eine Override-Sektion (Basis-Config greift wieder).
---@param sektion string
---@return boolean ok
---@return string? fehler
function AdminConfigService.SektionZuruecksetzen(sektion)
  if type(sektion) ~= "string" then
    return false, "Ungültige Sektion"
  end
  currentOverrides[sektion] = nil
  local ok, err = overridesSpeichern(currentOverrides)
  if not ok then return false, err end
  configAnwenden(currentOverrides)
  return true, nil
end

---Lädt Overrides aus Datei neu und wendet sie an (ohne Neustart).
---@return boolean
function AdminConfigService.Neuladen()
  currentOverrides = overridesLaden()
  configAnwenden(currentOverrides)
  if Config and Config.Kern and Config.Kern.Debugmodus then
    print("[AdminConfigService] Konfiguration neugeladen.")
  end
  return true
end

---Liste aller vom AdminConfigService verwalteten Sektionsnamen.
---Wird von api_admin.lua genutzt, um Duplikate zu vermeiden.
AdminConfigService.SEKTIONEN = MANAGED_SECTIONS

HM_BP.Server.Dienste.AdminConfigService = AdminConfigService
