HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local FeldValidierungService = {}

local function istString(v) return type(v) == "string" end
local function istZahl(v) return type(v) == "number" end
local function trim(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end

local function regexPruefen(text, muster)
  if not muster or muster == "" then return true end
  local ok, res = pcall(function()
    return string.match(text, muster) ~= nil
  end)
  if not ok then return false end
  return res == true
end

local function validiereText(feld, wert)
  if wert == nil then return true end
  if not istString(wert) then return false, "muss Text sein" end

  local t = trim(wert)
  if feld.minLaenge and #t < tonumber(feld.minLaenge) then
    return false, ("muss mindestens %d Zeichen haben"):format(tonumber(feld.minLaenge))
  end
  if feld.maxLaenge and #t > tonumber(feld.maxLaenge) then
    return false, ("darf maximal %d Zeichen haben"):format(tonumber(feld.maxLaenge))
  end
  if feld.regex and not regexPruefen(t, feld.regex) then
    return false, "hat ein ungültiges Format"
  end
  return true
end

local function validiereZahl(feld, wert)
  if wert == nil then return true end
  if istString(wert) then
    local n = tonumber(wert)
    wert = n
  end
  if not istZahl(wert) then return false, "muss eine Zahl sein" end

  if feld.min and wert < tonumber(feld.min) then
    return false, ("muss mindestens %s sein"):format(tostring(feld.min))
  end
  if feld.max and wert > tonumber(feld.max) then
    return false, ("darf maximal %s sein"):format(tostring(feld.max))
  end
  return true
end

local function validiereCheckbox(_, wert)
  if wert == nil then return true end
  if type(wert) ~= "boolean" then return false, "muss wahr/falsch sein" end
  return true
end

local function validiereDropdown(feld, wert)
  if wert == nil then return true end
  if not istString(wert) then return false, "muss Text sein" end
  if type(feld.optionen) ~= "table" or #feld.optionen == 0 then
    return true
  end
  for _, opt in ipairs(feld.optionen) do
    if opt.value == wert or opt == wert then
      return true
    end
  end
  return false, "hat eine ungültige Auswahl"
end

function FeldValidierungService.ValidiereSchemaUndAntworten(schema, antworten)
  if type(schema) ~= "table" or type(schema.felder) ~= "table" then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formularschema ist ungültig." }
  end
  if type(antworten) ~= "table" then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antworten sind ungültig." }
  end

  local fehler = {}

  for _, feld in ipairs(schema.felder) do
    local wert = antworten[feld.key]

    if feld.pflicht == true then
      if wert == nil or (type(wert) == "string" and trim(wert) == "") then
        fehler[feld.key] = "Pflichtfeld"
        goto weiter
      end
    end

    if feld.typ == "shorttext" or feld.typ == "longtext" then
      local ok, msg = validiereText(feld, wert)
      if not ok then fehler[feld.key] = msg end

    elseif feld.typ == "number" then
      local ok, msg = validiereZahl(feld, wert)
      if not ok then fehler[feld.key] = msg end

    elseif feld.typ == "checkbox" then
      local ok, msg = validiereCheckbox(feld, wert)
      if not ok then fehler[feld.key] = msg end

    elseif feld.typ == "dropdown" or feld.typ == "radio" then
      local ok, msg = validiereDropdown(feld, wert)
      if not ok then fehler[feld.key] = msg end

    else
      fehler[feld.key] = ("Feldtyp '%s' wird aktuell nicht unterstützt."):format(tostring(feld.typ))
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