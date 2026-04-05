HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ============================================================
-- server/dienste/location_service.lua
-- Liefert aktive Locations aus der Config und prüft Spieler-Zugriff
-- ============================================================

local LocationService = {}

-- Return all active location configs from Config.Standorte.Liste.
function LocationService.AktiveLocationsLaden()
  local liste = {}
  if not Config.Standorte or not Config.Standorte.Liste then return liste end
  for _, standort in pairs(Config.Standorte.Liste) do
    if standort.aktiv then
      table.insert(liste, standort)
    end
  end
  return liste
end

-- Fetch one location by id; returns table or nil.
function LocationService.LocationHolen(standortId)
  if not standortId then return nil end
  if not Config.Standorte or not Config.Standorte.Liste then return nil end
  return Config.Standorte.Liste[standortId]
end

-- Check whether a player (with .rolle set) may access the given location.
-- Returns: ok (bool), fehler (table|nil)
function LocationService.PruefeZugriff(spieler, standortId)
  if not spieler then
    return false, { nachricht = "Spieler-Kontext fehlt." }
  end

  local standort = LocationService.LocationHolen(standortId)
  if not standort then
    return false, { nachricht = ("Standort '%s' nicht gefunden."):format(tostring(standortId)) }
  end
  if not standort.aktiv then
    return false, { nachricht = ("Standort '%s' ist nicht aktiv."):format(tostring(standortId)) }
  end

  local rolle = spieler.rolle or HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)

  local zugriff = standort.zugriff
  if not zugriff then return true, nil end  -- no restrictions defined

  -- Exclusive role flags (shorthand)
  if zugriff.nurBuerger == true and rolle ~= "buerger" then
    return false, { nachricht = "Nur Bürger haben Zugriff auf diesen Standort." }
  end
  if zugriff.nurJustiz == true and rolle ~= "justiz" and rolle ~= "admin" then
    return false, { nachricht = "Nur Justiz hat Zugriff auf diesen Standort." }
  end
  if zugriff.nurAdmin == true and rolle ~= "admin" then
    return false, { nachricht = "Nur Admins haben Zugriff auf diesen Standort." }
  end

  -- erlaubteRollen: if set and non-empty, player's role must be listed
  if type(zugriff.erlaubteRollen) == "table" and #zugriff.erlaubteRollen > 0 then
    local gefunden = false
    for _, r in ipairs(zugriff.erlaubteRollen) do
      if r == rolle then gefunden = true; break end
    end
    if not gefunden then
      return false, { nachricht = "Ihre Rolle hat keinen Zugriff auf diesen Standort." }
    end
  end

  -- erlaubteJobs: if set and non-empty, player's job must be listed
  -- (admins bypass this check since they have "*" access globally)
  if type(zugriff.erlaubteJobs) == "table" and #zugriff.erlaubteJobs > 0 then
    if rolle ~= "admin" then
      local jobName = spieler.job and spieler.job.name or ""
      local gefunden = false
      for _, job in ipairs(zugriff.erlaubteJobs) do
        if job == jobName then gefunden = true; break end
      end
      if not gefunden then
        return false, { nachricht = "Ihr Job hat keinen Zugriff auf diesen Standort." }
      end
    end
  end

  return true, nil
end

HM_BP.Server.Dienste.LocationService = LocationService
