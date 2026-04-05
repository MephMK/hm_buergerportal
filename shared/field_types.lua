-- =============================================================
-- shared/field_types.lua
-- Kanonische Feldtyp-Definitionen für das Formular-System.
-- Jede Validierung und jede Rendering-Entscheidung MUSS auf
-- diese Definitionen zurückgreifen, um Inkonsistenzen zu
-- vermeiden.
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}

-- -------------------------------------------------------
-- Typ-Metadaten-Tabelle
-- isInput      : Feld erzeugt eine Antwort (false = dekorativ)
-- hatOptionen  : Feld benötigt optionen-Liste (select/radio/…)
-- hatMinMax    : Feld unterstützt min/max (Zahl/Länge)
-- hatRegex     : Feld unterstützt Regex-Validierung
-- hatLaenge    : min/max bezieht sich auf Text-Länge (nicht Zahlenwert)
-- hatDefault   : Feld kann einen Standardwert haben
-- mehrfach     : Wert ist eine Liste (multiselect)
-- -------------------------------------------------------
---@class FieldTypeMeta
---@field id string
---@field label string
---@field isInput boolean
---@field hatOptionen boolean
---@field hatMinMax boolean
---@field hatRegex boolean
---@field hatLaenge boolean
---@field hatDefault boolean
---@field mehrfach boolean

local TYPEN = {
  -- ---- Texteingaben -----------------------------------------------
  text_short = {
    id = "text_short", label = "Kurztext",
    isInput = true, hatOptionen = false, hatMinMax = true,
    hatRegex = true, hatLaenge = true, hatDefault = true, mehrfach = false,
  },
  text_long = {
    id = "text_long", label = "Langtext",
    isInput = true, hatOptionen = false, hatMinMax = true,
    hatRegex = true, hatLaenge = true, hatDefault = true, mehrfach = false,
  },

  -- ---- Zahlen / Beträge ------------------------------------------
  number = {
    id = "number", label = "Zahl",
    isInput = true, hatOptionen = false, hatMinMax = true,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },
  amount = {
    id = "amount", label = "Betrag (Währung)",
    isInput = true, hatOptionen = false, hatMinMax = true,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },

  -- ---- Datum / Zeit -----------------------------------------------
  date = {
    id = "date", label = "Datum",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },
  time = {
    id = "time", label = "Uhrzeit",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },
  datetime = {
    id = "datetime", label = "Datum + Uhrzeit",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },

  -- ---- Auswahl ----------------------------------------------------
  checkbox = {
    id = "checkbox", label = "Checkbox (Ja/Nein)",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },
  select = {
    id = "select", label = "Dropdown (Einfachauswahl)",
    isInput = true, hatOptionen = true, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },
  multiselect = {
    id = "multiselect", label = "Mehrfachauswahl",
    isInput = true, hatOptionen = true, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = false, mehrfach = true,
  },
  radio = {
    id = "radio", label = "Radio-Buttons",
    isInput = true, hatOptionen = true, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = true, mehrfach = false,
  },

  -- ---- Spezialfelder ----------------------------------------------
  url = {
    id = "url", label = "URL / Link",
    isInput = true, hatOptionen = false, hatMinMax = true,
    hatRegex = true, hatLaenge = true, hatDefault = false, mehrfach = false,
  },
  license_plate = {
    id = "license_plate", label = "Kennzeichen",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = true, hatLaenge = false, hatDefault = false, mehrfach = false,
  },
  player_reference = {
    id = "player_reference", label = "Spieler-Referenz",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = true, hatLaenge = false, hatDefault = false, mehrfach = false,
  },
  company_reference = {
    id = "company_reference", label = "Firmen-Referenz",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = true, hatLaenge = false, hatDefault = false, mehrfach = false,
  },
  case_number = {
    id = "case_number", label = "Aktenzeichen",
    isInput = true, hatOptionen = false, hatMinMax = false,
    hatRegex = true, hatLaenge = false, hatDefault = false, mehrfach = false,
  },

  -- ---- Dekorative / nicht-Eingabe Felder --------------------------
  divider = {
    id = "divider", label = "Trennlinie",
    isInput = false, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = false, mehrfach = false,
  },
  heading = {
    id = "heading", label = "Überschrift",
    isInput = false, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = false, mehrfach = false,
  },
  info = {
    id = "info", label = "Infotext",
    isInput = false, hatOptionen = false, hatMinMax = false,
    hatRegex = false, hatLaenge = false, hatDefault = false, mehrfach = false,
  },
}

-- -------------------------------------------------------
-- Rückwärtskompatibilitäts-Aliase
-- (Ältere Schemata verwenden die alten Typnamen.)
-- -------------------------------------------------------
local ALIASE = {
  shorttext         = "text_short",
  longtext          = "text_long",
  dropdown          = "select",
  kennzeichen       = "license_plate",
  spieler           = "player_reference",
  firma             = "company_reference",
  aktenzeichen      = "case_number",
  betrag            = "amount",
  datum             = "date",
  uhrzeit           = "time",
  datumzeit         = "datetime",
  mehrfachauswahl   = "multiselect",
}

-- -------------------------------------------------------
-- Öffentliche API
-- -------------------------------------------------------
local FieldTypes = {}

--- Gibt die kanonische Typ-ID zurück (Alias auflösen).
--- Bei unbekanntem Typ wird nil zurückgegeben.
---@param typ string
---@return string|nil
function FieldTypes.Kanonisch(typ)
  if not typ then return nil end
  typ = tostring(typ):lower()
  if TYPEN[typ] then return typ end
  local alias = ALIASE[typ]
  if alias and TYPEN[alias] then return alias end
  return nil
end

--- Gibt die Metadaten für einen Typ zurück.
--- Aliase werden automatisch aufgelöst.
--- Gibt nil zurück wenn der Typ unbekannt ist.
---@param typ string
---@return FieldTypeMeta|nil
function FieldTypes.Meta(typ)
  local k = FieldTypes.Kanonisch(typ)
  if not k then return nil end
  return TYPEN[k]
end

--- Prüft ob ein Typ bekannt ist (inkl. Aliase).
---@param typ string
---@return boolean
function FieldTypes.Bekannt(typ)
  return FieldTypes.Kanonisch(typ) ~= nil
end

--- Prüft ob ein Typ ein Eingabefeld ist (isInput = true).
---@param typ string
---@return boolean
function FieldTypes.IstEingabe(typ)
  local m = FieldTypes.Meta(typ)
  return m ~= nil and m.isInput == true
end

--- Gibt eine geordnete Liste aller Input-Typen zurück (für Formular-Editor).
---@return FieldTypeMeta[]
function FieldTypes.AlleInputTypen()
  local ergebnis = {}
  -- Reihenfolge für Editor-Dropdown
  local reihenfolge = {
    "text_short", "text_long",
    "number", "amount",
    "date", "time", "datetime",
    "checkbox", "select", "multiselect", "radio",
    "url", "license_plate", "player_reference", "company_reference", "case_number",
    "divider", "heading", "info",
  }
  for _, id in ipairs(reihenfolge) do
    local m = TYPEN[id]
    if m then
      table.insert(ergebnis, m)
    end
  end
  return ergebnis
end

HM_BP.Shared.FieldTypes = FieldTypes
