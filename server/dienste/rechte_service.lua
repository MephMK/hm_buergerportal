HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local RechteService = {}

local function enthaelt(t, wert)
  if type(t) ~= "table" then return false end
  for _, v in ipairs(t) do
    if v == wert then return true end
  end
  return false
end

local function hatStern(t)
  if type(t) ~= "table" then return false end
  for _, v in ipairs(t) do
    if v == "*" then return true end
  end
  return false
end

local function regelFuerRolle(rolle)
  local g = Config.Rechte and Config.Rechte.Richtlinie and Config.Rechte.Richtlinie.Global
  if not g then return nil end
  return g[rolle]
end

local function passtJobGrad(spieler, regel)
  if not regel then return true end
  if regel.job and spieler.job.name ~= regel.job then
    return false
  end
  if regel.mindestGrad ~= nil and spieler.job.grade < tonumber(regel.mindestGrad) then
    return false
  end
  return true
end

local function pruefeListe(erlauben, verbieten, aktion)
  if type(verbieten) == "table" and enthaelt(verbieten, aktion) then
    return false
  end
  if type(erlauben) == "table" and (enthaelt(erlauben, aktion) or hatStern(erlauben)) then
    return true
  end
  return nil
end

local function overrideRegel(typ, id, rolle)
  local r = Config.Rechte and Config.Rechte.Richtlinie and Config.Rechte.Richtlinie[typ]
  if not r then return nil end
  if not r[id] then return nil end
  return r[id][rolle]
end

function RechteService.Darf(spieler, aktion, kontext)
  if Config.Rechte and Config.Rechte.Aktiviert ~= true then
    return true, nil
  end

  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)

  local globalRegel = regelFuerRolle(rolle)
  if not globalRegel then
    return false, { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
  end

  if not passtJobGrad(spieler, globalRegel) then
    return false, { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
  end

  local kategorieId = kontext and kontext.kategorieId or nil
  local formularId = kontext and kontext.formularId or nil

  if kategorieId then
    local o = overrideRegel("Kategorie", kategorieId, rolle)
    if o then
      if not passtJobGrad(spieler, o) then
        return false, { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
      end
      local r = pruefeListe(o.erlauben, o.verbieten, aktion)
      if r ~= nil then
        return r, r and nil or { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
      end
    end
  end

  if formularId then
    local o = overrideRegel("Formular", formularId, rolle)
    if o then
      if not passtJobGrad(spieler, o) then
        return false, { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
      end
      local r = pruefeListe(o.erlauben, o.verbieten, aktion)
      if r ~= nil then
        return r, r and nil or { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
      end
    end
  end

  local r = pruefeListe(globalRegel.erlauben, globalRegel.verbieten, aktion)
  if r == true then return true, nil end

  return false, { code = HM_BP.Shared.Errors.NOT_AUTHORIZED, nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED }
end

HM_BP.Server.Dienste.RechteService = RechteService