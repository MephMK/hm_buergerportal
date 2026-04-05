HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AntiSpamService = {}

local zustand = {
  cooldownGlobal = {},      -- identifier -> unix
  rateLimit = {},           -- identifier -> { resetAt, count }
}

local function jetzt()
  return os.time(os.date("!*t"))
end

function AntiSpamService.PruefeGlobalenCooldown(spieler)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end

  local sek = tonumber(Config.AntiSpam.GlobalerCooldownSekunden or 0) or 0
  if sek <= 0 then return true, nil end

  local id = spieler.identifier
  local last = zustand.cooldownGlobal[id] or 0
  local nun = jetzt()

  if (nun - last) < sek then
    return false, {
      code = HM_BP.Shared.Errors.RATE_LIMITED,
      nachricht = ("Bitte warte kurz (%ds Cooldown)."):format(sek)
    }
  end

  zustand.cooldownGlobal[id] = nun
  return true, nil
end

function AntiSpamService.PruefeRateLimit(spieler, schluessel)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end
  if Config.AntiSpam.RateLimit and Config.AntiSpam.RateLimit.Aktiviert ~= true then
    return true, nil
  end

  local maxAktionen = tonumber(Config.AntiSpam.RateLimit.MaxAktionen or 20) or 20
  local proSek = tonumber(Config.AntiSpam.RateLimit.ProSekunden or 60) or 60

  local id = spieler.identifier .. ":" .. tostring(schluessel or "global")
  local nun = jetzt()

  local eintrag = zustand.rateLimit[id]
  if not eintrag or nun >= (eintrag.resetAt or 0) then
    zustand.rateLimit[id] = { resetAt = nun + proSek, count = 1 }
    return true, nil
  end

  eintrag.count = (eintrag.count or 0) + 1
  if eintrag.count > maxAktionen then
    return false, {
      code = HM_BP.Shared.Errors.RATE_LIMITED,
      nachricht = "Zu viele Aktionen in kurzer Zeit. Bitte warte einen Moment."
    }
  end

  return true, nil
end

HM_BP.Server.Dienste.AntiSpamService = AntiSpamService