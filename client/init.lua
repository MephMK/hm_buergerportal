HM_BP = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

CreateThread(function()
  while not NetworkIsSessionStarted() do Wait(250) end

  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    local mode = (Config.Kern.Interaktion and Config.Kern.Interaktion.Modus) or "unbekannt"
    print(("[hm_buergerportal] client gestartet (Interaktion: %s)"):format(tostring(mode)))
  end
end)