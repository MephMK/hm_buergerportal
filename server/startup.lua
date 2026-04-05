HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

CreateThread(function()
  Wait(250)

  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    print(("[hm_buergerportal] Startup: Ressource '%s' startet..."):format(tostring(Config.Kern.RessourcenName or "hm_buergerportal")))
  end

  -- Migrationen
  if Config
    and Config.Datenbank
    and Config.Datenbank.Migrationen
    and Config.Datenbank.Migrationen.Aktiviert == true
    and Config.Datenbank.Migrationen.BeimStartAutomatisch == true then

    if HM_BP.Server and HM_BP.Server.Migrationen and HM_BP.Server.Migrationen.AlleAusfuehren then
      local ok, err = pcall(function()
        HM_BP.Server.Migrationen.AlleAusfuehren()
      end)

      if not ok then
        print(("[hm_buergerportal] FEHLER: Migrationen konnten nicht ausgeführt werden: %s"):format(tostring(err)))
      else
        if Config and Config.Kern and Config.Kern.Debugmodus == true then
          print("[hm_buergerportal] Migrationen ausgeführt.")
        end
      end
    else
      print("[hm_buergerportal] WARN: Migrationen aktiviert, aber HM_BP.Server.Migrationen ist nicht verfügbar.")
    end
  end
end)