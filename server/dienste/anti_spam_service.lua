HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AntiSpamService = {}

local zustand = {
  cooldownGlobal  = {},    -- identifier -> unix
  cooldownPerForm = {},    -- "identifier:formularId" -> unix
  rateLimit       = {},    -- identifier -> { resetAt, count }
  duplikat        = {},    -- "identifier:formularId" -> { hash, zeit }
  fehlversuche    = {},    -- identifier -> { count, lockoutBis }
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

-- ----------------------------------------------------------------
-- Hilfsfunktionen: einfacher FNV-1a-Hashersatz (kein externer Lib)
-- ----------------------------------------------------------------

local function fnv1aHash(s)
  local h = 2166136261
  for i = 1, #s do
    h = ((h ~ string.byte(s, i)) * 16777619) & 0xFFFFFFFF
  end
  return h
end

local function duplikatHash(text, formularId)
  local kurz = tostring(#text) .. ":"
    .. tostring(text):sub(1, 50)
    .. ":"
    .. tostring(text):sub(-50)
    .. ":"
    .. tostring(formularId)
  return fnv1aHash(kurz)
end

-- ----------------------------------------------------------------
-- AntiSpamService.PruefeFormularCooldown
-- Prüft pro-Formular-Cooldown aus Config.AntiSpam.PerFormularCooldown.
-- ----------------------------------------------------------------
function AntiSpamService.PruefeFormularCooldown(spieler, formularId)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end

  local perForm = Config.AntiSpam.PerFormularCooldown
  if type(perForm) ~= "table" then return true, nil end

  local sek = tonumber(perForm[formularId]) or 0
  if sek <= 0 then return true, nil end

  local key = spieler.identifier .. ":" .. tostring(formularId)
  local last = zustand.cooldownPerForm[key] or 0
  local nun = jetzt()

  if (nun - last) < sek then
    return false, {
      code = HM_BP.Shared.Errors.RATE_LIMITED,
      nachricht = ("Bitte warte kurz (%ds Cooldown für dieses Formular)."):format(sek)
    }
  end

  zustand.cooldownPerForm[key] = nun
  return true, nil
end

-- ----------------------------------------------------------------
-- AntiSpamService.PruefeBlacklist
-- Prüft ob der Text verbotene Wörter aus Config.AntiSpam.Blackliste enthält.
-- ----------------------------------------------------------------
function AntiSpamService.PruefeBlacklist(text)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end

  local bl = Config.AntiSpam.Blackliste
  if not bl or bl.Aktiviert ~= true then return true, nil end

  local woerter = type(bl.Woerter) == "table" and bl.Woerter or {}
  local textLower = tostring(text or ""):lower()

  for _, wort in ipairs(woerter) do
    if textLower:find(tostring(wort):lower(), 1, true) then
      return false, {
        code     = HM_BP.Shared.Errors.INVALID_PAYLOAD,
        nachricht = "Deine Eingabe enthält unzulässige Inhalte."
      }
    end
  end

  return true, nil
end

-- ----------------------------------------------------------------
-- AntiSpamService.PruefeDuplikat
-- Prüft ob der Spieler kürzlich einen identischen Text für dieses
-- Formular eingereicht hat (innerhalb FensterMinuten).
-- ----------------------------------------------------------------
function AntiSpamService.PruefeDuplikat(spieler, formularId, text)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end

  local dp = Config.AntiSpam.DuplikatPruefung
  if not dp or dp.Aktiviert ~= true then return true, nil end

  local fensterSek = (tonumber(dp.FensterMinuten) or 30) * 60
  local key  = spieler.identifier .. ":" .. tostring(formularId)
  local hash = duplikatHash(text, formularId)
  local nun  = jetzt()

  local letzter = zustand.duplikat[key]
  if letzter and letzter.hash == hash then
    if (nun - letzter.zeit) < fensterSek then
      return false, {
        code     = HM_BP.Shared.Errors.CONFLICT,
        nachricht = "Dieser Antrag wurde kürzlich bereits identisch eingereicht. Bitte warte einen Moment."
      }
    end
  end

  -- Hash für nächste Prüfung speichern
  zustand.duplikat[key] = { hash = hash, zeit = nun }
  return true, nil
end

-- ----------------------------------------------------------------
-- AntiSpamService.PruefeLaengen
-- Prüft Mindest- und Maximallänge des Texts (global + pro Formular).
-- ----------------------------------------------------------------
function AntiSpamService.PruefeLaengen(text, formularId)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end

  local minGlobal = tonumber(Config.AntiSpam.MinTextLaenge) or 0
  local maxGlobal = tonumber(Config.AntiSpam.MaxTextLaenge) or 0

  -- Pro-Formular-Überschreibung
  local perLaengen = Config.AntiSpam.PerFormularLaengen
  local minLaenge = minGlobal
  local maxLaenge = maxGlobal
  if type(perLaengen) == "table" and type(perLaengen[formularId]) == "table" then
    local pfl = perLaengen[formularId]
    if tonumber(pfl.min) then minLaenge = tonumber(pfl.min) end
    if tonumber(pfl.max) then maxLaenge = tonumber(pfl.max) end
  end

  local laenge = #tostring(text or "")

  if minLaenge > 0 and laenge < minLaenge then
    return false, {
      code     = HM_BP.Shared.Errors.INVALID_PAYLOAD,
      nachricht = ("Deine Eingabe ist zu kurz (mindestens %d Zeichen)."):format(minLaenge)
    }
  end

  if maxLaenge > 0 and laenge > maxLaenge then
    return false, {
      code     = HM_BP.Shared.Errors.INVALID_PAYLOAD,
      nachricht = ("Deine Eingabe ist zu lang (maximal %d Zeichen)."):format(maxLaenge)
    }
  end

  return true, nil
end

-- ----------------------------------------------------------------
-- AntiSpamService.FehlversuchRegistrieren
-- Zählt einen Fehlversuch für den Spieler und setzt ggf. einen Lockout.
-- ----------------------------------------------------------------
function AntiSpamService.FehlversuchRegistrieren(spieler)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then return end

  local lk = Config.AntiSpam.Lockout
  if not lk or lk.Aktiviert ~= true then return end

  local maxVersuche = tonumber(lk.MaxFehlversuche) or 5
  local dauerSek    = tonumber(lk.DauerSekunden)   or 300
  local id          = spieler.identifier

  local eintrag = zustand.fehlversuche[id] or { count = 0, lockoutBis = 0 }
  eintrag.count = eintrag.count + 1

  if eintrag.count >= maxVersuche then
    eintrag.lockoutBis = jetzt() + dauerSek
  end

  zustand.fehlversuche[id] = eintrag
end

-- ----------------------------------------------------------------
-- AntiSpamService.PruefeLockout
-- Prüft ob der Spieler aktuell gesperrt ist.
-- ----------------------------------------------------------------
function AntiSpamService.PruefeLockout(spieler)
  if Config.AntiSpam and Config.AntiSpam.Aktiviert ~= true then
    return true, nil
  end

  local lk = Config.AntiSpam.Lockout
  if not lk or lk.Aktiviert ~= true then return true, nil end

  local eintrag = zustand.fehlversuche[spieler.identifier]
  if not eintrag then return true, nil end

  local nun = jetzt()
  if eintrag.lockoutBis and nun < eintrag.lockoutBis then
    local verbleibt = eintrag.lockoutBis - nun
    return false, {
      code     = HM_BP.Shared.Errors.RATE_LIMITED,
      nachricht = ("Zu viele Fehlversuche. Bitte warte %d Sekunden."):format(verbleibt)
    }
  end

  return true, nil
end

-- ----------------------------------------------------------------
-- AntiSpamService.LockoutAufheben
-- Setzt den Lockout und Fehlversuchs-Zähler eines Spielers zurück.
-- ----------------------------------------------------------------
function AntiSpamService.LockoutAufheben(spieler)
  zustand.fehlversuche[spieler.identifier] = nil
end

-- ----------------------------------------------------------------
-- AntiSpamService.AbuseWebhookSenden
-- Sendet ein abuse_triggered-Event via WebhookService.
-- ----------------------------------------------------------------
function AntiSpamService.AbuseWebhookSenden(grund, spieler, extra)
  local ws = HM_BP.Server.Dienste.WebhookService
  if not ws or not ws.Emit then return end

  local daten = {
    akteur_name = spieler and (spieler.name or "Unbekannt") or "Unbekannt",
    grund       = tostring(grund or ""),
    text        = tostring(grund or ""),
  }

  -- Bekannte Identifier-Schlüssel und FiveM-Identifier-Muster herausfiltern
  local idSchluessel = {
    identifier = true, citizen_identifier = true, actor_identifier = true,
    assigned_to_identifier = true, erteilt_von_identifier = true,
  }
  -- Muster für FiveM-Identifier-Werte (license:, steam:, discord:, usw.)
  local function istIdentifier(v)
    if type(v) ~= "string" then return false end
    return v:match("^license:[a-f0-9]+$")
        or v:match("^steam:[a-f0-9]+$")
        or v:match("^discord:%d+$")
        or v:match("^xbl:%d+$")
        or v:match("^live:%d+$")
        or v:match("^fivem:%d+$")
        or v:match("^ip:%d+%.%d+%.%d+%.%d+$")
  end

  if type(extra) == "table" then
    for k, v in pairs(extra) do
      if not idSchluessel[k] and not istIdentifier(v) then
        daten[k] = v
      end
    end
  end

  pcall(function()
    ws.Emit("abuse_triggered", daten)
  end)
end

HM_BP.Server.Dienste.AntiSpamService = AntiSpamService