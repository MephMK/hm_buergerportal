HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

CreateThread(function()
  Wait(250)

  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    print(("[hm_buergerportal] Startup: Ressource '%s' startet..."):format(tostring(Config.Kern.RessourcenName or "hm_buergerportal")))
  end

  -- Admin-Konfigurationsservice: Overrides laden und mit Basis-Config mergen.
  -- MUSS VOR den Migrationen laufen, damit alle Dienste die effektive Config sehen.
  if HM_BP.Server and HM_BP.Server.Dienste and HM_BP.Server.Dienste.AdminConfigService then
    local ok, err = pcall(function()
      HM_BP.Server.Dienste.AdminConfigService.Init()
    end)
    if not ok then
      print(("[hm_buergerportal] WARN: AdminConfigService.Init fehlgeschlagen: %s"):format(tostring(err)))
    end
  end

  -- Admin-Audit-Service initialisieren (lädt bestehende Log-Einträge)
  if HM_BP.Server and HM_BP.Server.Dienste and HM_BP.Server.Dienste.AdminAuditService then
    local ok, err = pcall(function()
      HM_BP.Server.Dienste.AdminAuditService.Init()
    end)
    if not ok then
      print(("[hm_buergerportal] WARN: AdminAuditService.Init fehlgeschlagen: %s"):format(tostring(err)))
    end
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

-- =============================================================
-- SLA-Tick: Periodischer Check auf überfällige Anträge (PR7)
-- =============================================================
CreateThread(function()
  -- Kurz warten, bis DB + Services vollständig initialisiert sind
  Wait(5000)

  while true do
    local interval = tonumber(
      Config.Workflows and Config.Workflows.Sla and Config.Workflows.Sla.TickIntervalSekunden
    ) or 30

    Wait(interval * 1000)

    if HM_BP.Server.Dienste.WorkflowService then
      local ok, err = pcall(function()
        HM_BP.Server.Dienste.WorkflowService.SlaTick()
      end)
      if not ok and Config and Config.Kern and Config.Kern.Debugmodus == true then
        print(("[hm_buergerportal] WARN: SlaTick fehlgeschlagen: %s"):format(tostring(err)))
      end
    end
  end
end)