-- =============================================================
-- shared/validation.lua
-- Gemeinsame Validierungslogik (Server + Client-Helper).
-- Wird serverseitig für die endgültige Prüfung genutzt und
-- kann clientseitig für sofortiges UI-Feedback gespiegelt
-- werden.
-- WICHTIG: Der Server ist die einzige Quelle der Wahrheit.
-- Die Client-Funktion ist nur ein UX-Helper.
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}

local Validation = {}

-- -------------------------------------------------------
-- Interne Hilfsfunktionen
-- -------------------------------------------------------
local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function istLeer(v)
  if v == nil then return true end
  if type(v) == "string" and trim(v) == "" then return true end
  return false
end

-- Muster für eingebaute Typen (Lua-Patterns)
local MUSTER = {
  -- Datum: YYYY-MM-DD
  date         = "^%d%d%d%d%-%d%d%-%d%d$",
  -- Uhrzeit: HH:MM oder HH:MM:SS
  time         = "^%d%d:%d%d$",
  -- Datetime: Datum T Uhrzeit (ISO 8601 vereinfacht)
  datetime     = "^%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d",
  -- URL: muss mit http:// oder https:// beginnen
  url          = "^https?://",
  -- Kennzeichen: z.B. "AB 1234" oder "B-AB 1234" (ein optionaler Bindestrich zwischen Buchstabengruppen)
  license_plate = "^[A-Za-z]+%-?[A-Za-z]* ?%d+$",
  -- Aktenzeichen: z.B. "DOJ-2024-000123"
  case_number  = "^[A-Za-z0-9%-_]+$",
}

-- -------------------------------------------------------
-- Einzelfeld-Validierung (typ-abhängig)
-- Gibt ok, msg zurück. Wenn ok=true, ist msg nil.
-- -------------------------------------------------------

local function regexPruefen(text, muster)
  if not muster or muster == "" then return true end
  local ok, treffer = pcall(function()
    return string.match(text, muster) ~= nil
  end)
  if not ok then return false end
  return treffer == true
end

local function textValidieren(feld, wert)
  if not wert then return true end
  if type(wert) ~= "string" then return false, "muss Text sein" end
  local t = trim(wert)
  local minL = tonumber(feld.minLaenge or feld.min)
  local maxL = tonumber(feld.maxLaenge or feld.max)
  if minL and #t < minL then
    return false, ("muss mindestens %d Zeichen haben"):format(minL)
  end
  if maxL and #t > maxL then
    return false, ("darf maximal %d Zeichen haben"):format(maxL)
  end
  if feld.regex and not regexPruefen(t, feld.regex) then
    return false, "hat ein ungültiges Format"
  end
  return true
end

local function zahlValidieren(feld, wert)
  if wert == nil then return true end
  local n = tonumber(wert)
  if n == nil then return false, "muss eine Zahl sein" end
  local minV = tonumber(feld.min)
  local maxV = tonumber(feld.max)
  if minV and n < minV then
    return false, ("muss mindestens %s sein"):format(tostring(feld.min))
  end
  if maxV and n > maxV then
    return false, ("darf maximal %s sein"):format(tostring(feld.max))
  end
  return true
end

local function checkboxValidieren(_, wert)
  if wert == nil then return true end
  if type(wert) ~= "boolean" then
    -- Toleriere JSON-kodierte Booleans als Strings
    if wert == "true" or wert == "false" or wert == 1 or wert == 0 then
      return true
    end
    return false, "muss wahr/falsch sein"
  end
  return true
end

local function optionValidieren(feld, wert)
  if wert == nil then return true end
  if not (type(feld.optionen) == "table" and #feld.optionen > 0) then
    return true  -- keine Optionsliste → freies Feld
  end
  for _, opt in ipairs(feld.optionen) do
    local v = type(opt) == "table" and opt.value or opt
    if tostring(v) == tostring(wert) then return true end
  end
  return false, "hat eine ungültige Auswahl"
end

local function multiselectValidieren(feld, wert)
  if wert == nil then return true end
  -- Wert muss ein Array sein (table mit integer-keys)
  if type(wert) ~= "table" then
    -- Erlaube komma-getrennte Strings als Fallback
    if type(wert) == "string" then return true end
    return false, "muss eine Liste sein"
  end
  if not (type(feld.optionen) == "table" and #feld.optionen > 0) then
    return true
  end
  local erlaubt = {}
  for _, opt in ipairs(feld.optionen) do
    local v = type(opt) == "table" and opt.value or opt
    erlaubt[tostring(v)] = true
  end
  for _, eintrag in ipairs(wert) do
    if not erlaubt[tostring(eintrag)] then
      return false, ("ungültige Auswahl: %s"):format(tostring(eintrag))
    end
  end
  return true
end

local function musterfeldValidieren(musterKey, feld, wert)
  if wert == nil then return true end
  if type(wert) ~= "string" then return false, "muss Text sein" end
  local t = trim(wert)
  -- Erst eingebautes Muster prüfen
  local eingebaut = MUSTER[musterKey]
  if eingebaut and not regexPruefen(t, eingebaut) then
    return false, "hat ein ungültiges Format"
  end
  -- Dann optionales benutzerdefiniertes Regex
  if feld.regex and not regexPruefen(t, feld.regex) then
    return false, "hat ein ungültiges Format"
  end
  return true
end

-- -------------------------------------------------------
-- Öffentliche API
-- -------------------------------------------------------

--- Validiert einen einzelnen Feldwert gegen die Feld-Definition.
--- Gibt ok, msg zurück. msg ist nil wenn ok=true.
---@param feld table Feld-Definition aus dem Schema
---@param wert any   Antwort-Wert
---@return boolean, string|nil
function Validation.FeldValidieren(feld, wert)
  if not feld or not feld.typ then
    return false, "Feld hat keinen Typ"
  end

  local FT = HM_BP.Shared.FieldTypes
  local kanon = FT and FT.Kanonisch(feld.typ) or feld.typ

  -- Pflicht-Check
  if feld.pflicht == true then
    if istLeer(wert) then
      -- multiselect: leeres Array ebenfalls als leer werten
      if type(wert) == "table" and #wert == 0 then
        return false, "Pflichtfeld"
      elseif type(wert) ~= "table" then
        return false, "Pflichtfeld"
      end
    end
  end

  -- Dekorative Felder: kein Wert erwartet
  if FT and not FT.IstEingabe(kanon or feld.typ) then
    return true
  end

  -- Wenn kein Wert, kein Fehler (Pflicht-Check oben bereits erledigt)
  if istLeer(wert) and type(wert) ~= "boolean" then
    if type(wert) == "table" and #wert > 0 then
      -- nicht leer
    else
      return true
    end
  end

  local t = kanon or feld.typ

  if t == "text_short" or t == "text_long" then
    return textValidieren(feld, wert)

  elseif t == "number" or t == "amount" then
    return zahlValidieren(feld, wert)

  elseif t == "checkbox" then
    return checkboxValidieren(feld, wert)

  elseif t == "select" or t == "radio" then
    return optionValidieren(feld, wert)

  elseif t == "multiselect" then
    return multiselectValidieren(feld, wert)

  elseif t == "date" then
    return musterfeldValidieren("date", feld, wert)

  elseif t == "time" then
    return musterfeldValidieren("time", feld, wert)

  elseif t == "datetime" then
    return musterfeldValidieren("datetime", feld, wert)

  elseif t == "url" then
    return musterfeldValidieren("url", feld, wert)

  elseif t == "license_plate" then
    return musterfeldValidieren("license_plate", feld, wert)

  elseif t == "case_number" then
    return musterfeldValidieren("case_number", feld, wert)

  elseif t == "player_reference" or t == "company_reference" then
    -- Freitext mit optionalem Regex
    return textValidieren(feld, wert)

  else
    -- Unbekannter Typ: Toleranz-Modus (nur Warnung), kein Fehler
    return true
  end
end

--- Validiert alle Felder eines Schemas gegen die übergebenen Antworten.
--- Gibt ok, feldFehler zurück.
--- feldFehler ist eine Tabelle { feldKey = fehlermeldung }.
---@param schema table  { felder = [...] }
---@param antworten table { feldKey = wert }
---@return boolean, table|nil
function Validation.SchemaValidieren(schema, antworten)
  if type(schema) ~= "table" or type(schema.felder) ~= "table" then
    return false, { _schema = "Formularschema ist ungültig." }
  end
  if type(antworten) ~= "table" then
    return false, { _antworten = "Antworten sind ungültig." }
  end

  local fehler = {}

  for _, feld in ipairs(schema.felder) do
    if not feld.key then goto weiter end

    local wert = antworten[feld.key]
    local ok, msg = Validation.FeldValidieren(feld, wert)
    if not ok then
      fehler[feld.key] = msg or "Ungültiger Wert."
    end

    ::weiter::
  end

  if next(fehler) ~= nil then
    return false, fehler
  end

  return true, nil
end

HM_BP.Shared.Validation = Validation
