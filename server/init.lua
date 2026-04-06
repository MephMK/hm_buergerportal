HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- Readiness-Guard: wird nach erfolgreichen Migrationen auf true gesetzt.
-- Alle API-Handler prüfen diesen Status bevor sie DB-Abfragen ausführen.
HM_BP.Server.Ready = false

CreateThread(function()
  -- server/init.lua ist bewusst schlank:
  -- - kein DB Zugriff hier (das macht startup.lua)
  -- - nur Debug/Bootstrapping
  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    print("[hm_buergerportal] server/init.lua geladen")
  end
end)