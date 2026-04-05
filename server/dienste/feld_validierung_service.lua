HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- =============================================================
-- FeldValidierungService
-- Server-seitige Feldvalidierung (Source of Truth).
-- Delegiert an HM_BP.Shared.Validation (shared/validation.lua)
-- und fügt Koerzionsregeln + Fehlerformatierung hinzu.
-- =============================================================
local FeldValidierungService = {}

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- -------------------------------------------------------
-- Typ-Koerzion: Wandelt Rohwerte aus JSON-Payloads in den
-- erwarteten Lua-Typ um, bevor die Validierung läuft.
-- -------------------------------------------------------
local function koerzieren(typ, wert)
  local FT = HM_BP.Shared.FieldTypes
  local kanon = FT and FT.Kanonisch(typ) or typ

  if kanon == "number" or kanon == "amount" then
    if type(wert) == "string" then
      local n = tonumber(wert)
      if n ~= nil then return n end
    end
    return wert

  elseif kanon == "checkbox" then
    if wert == "true" or wert == 1 then return true end
    if wert == "false" or wert == 0 then return false end
    return wert

  elseif kanon == "multiselect" then
    -- JSON-Array kommt manchmal als Lua-Table, manchmal als String
    if type(wert) == "string" and wert ~= "" then
      local ok, parsed = pcall(json.decode, wert)
      if ok and type(parsed) == "table" then return parsed end
    end
    return wert

  elseif kanon == "date" or kanon == "time" or kanon == "datetime" then
    if type(wert) == "string" then return trim(wert) end
    return wert
  end

  return wert
end

-- -------------------------------------------------------
-- Öffentliche API
-- -------------------------------------------------------

--- Validiert alle Felder eines Schemas gegen die übergebenen
--- Antworten. Gibt bei Fehlern einen strukturierten Fehler
--- mit feldFehler-Tabelle zurück (id → Meldung).
---@param schema table  { felder = [...] }
---@param antworten table { feldKey = wert }
---@return boolean, table|nil
function FeldValidierungService.ValidiereSchemaUndAntworten(schema, antworten)
  if type(schema) ~= "table" or type(schema.felder) ~= "table" then
    return false, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Formularschema ist ungültig."
    }
  end
  if type(antworten) ~= "table" then
    return false, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Antworten sind ungültig."
    }
  end

  -- Antworten erst koerzieren
  local koerziert = {}
  for k, v in pairs(antworten) do
    koerziert[k] = v
  end
  for _, feld in ipairs(schema.felder) do
    if feld.key and koerziert[feld.key] ~= nil then
      koerziert[feld.key] = koerzieren(feld.typ, koerziert[feld.key])
    end
  end

  -- Validierung via shared Modul
  local Validation = HM_BP.Shared.Validation
  local FT = HM_BP.Shared.FieldTypes

  if not Validation then
    return false, {
      code = HM_BP.Gemeinsam.Fehlercodes.INTERNER_FEHLER,
      nachricht = "Validierungsmodul nicht geladen."
    }
  end

  local fehler = {}

  for _, feld in ipairs(schema.felder) do
    if not feld.key then goto weiter end

    -- Dekorative Felder überspringen
    if FT and not FT.IstEingabe(feld.typ) then goto weiter end

    local wert = koerziert[feld.key]
    local ok, msg = Validation.FeldValidieren(feld, wert)
    if not ok then
      fehler[feld.key] = msg or "Ungültiger Wert."
    end

    ::weiter::
  end

  if next(fehler) ~= nil then
    return false, {
      code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
      nachricht = "Bitte prüfe deine Eingaben.",
      feldFehler = fehler
    }
  end

  return true, nil
end

HM_BP.Server.Dienste.FeldValidierungService = FeldValidierungService