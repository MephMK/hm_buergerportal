HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ============================================================
-- server/api_locations.lua
-- Server-seitige Events für Location-basierte UI-Öffnung.
-- Der Server entscheidet, ob ein Spieler an einem Standort
-- das Portal öffnen darf (Security-Gate).
-- ============================================================

-- -------------------------------------------------------
-- hm_bp:location:ui_oeffnen_anfordern
-- Client → Server: Spieler möchte das Portal an einem Standort öffnen.
-- Server prüft Berechtigung und antwortet mit ok/fehler.
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:location:ui_oeffnen_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  -- Basic auth / rate-limit check
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "SYSTEM_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:location:ui_oeffnen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local standortId = payload.standortId
  if not standortId then
    TriggerClientEvent("hm_bp:location:ui_oeffnen_antwort", quelle, {
      ok = false,
      fehler = { nachricht = "Standort-ID fehlt." }
    })
    return
  end

  -- Location-specific access check (server is the authority)
  local ok, err2 = HM_BP.Server.Dienste.LocationService.PruefeZugriff(spieler, standortId)
  if not ok then
    TriggerClientEvent("hm_bp:location:ui_oeffnen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  local standort = HM_BP.Server.Dienste.LocationService.LocationHolen(standortId)

  -- Send only the minimal info the client needs to open the UI
  local standortInfo = {
    id                 = standort.id,
    name               = standort.name,
    erlaubteKategorien = standort.zugriff and standort.zugriff.erlaubteKategorien or {},
    erlaubteFormulare  = standort.zugriff and standort.zugriff.erlaubteFormulare  or {},
  }

  if Config.Kern.Debugmodus then
    print(("[hm_buergerportal] Location-Zugriff erlaubt: Spieler %s → Standort %s"):format(
      tostring(spieler.identifier), tostring(standortId)
    ))
  end

  TriggerClientEvent("hm_bp:location:ui_oeffnen_antwort", quelle, {
    ok       = true,
    standort = standortInfo,
  })
end)

-- -------------------------------------------------------
-- hm_bp:location:liste_anfordern
-- Client → Server: Spieler fragt aktive, für ihn sichtbare Locations ab.
-- Antwort enthält nur minimale Info (id/name) – keine Koordinaten etc.
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:location:liste_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "SYSTEM_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:location:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local alle = HM_BP.Server.Dienste.LocationService.AktiveLocationsLaden()
  local sichtbar = {}
  for _, standort in ipairs(alle) do
    local ok, _ = HM_BP.Server.Dienste.LocationService.PruefeZugriff(spieler, standort.id)
    if ok then
      table.insert(sichtbar, { id = standort.id, name = standort.name })
    end
  end

  TriggerClientEvent("hm_bp:location:liste_antwort", quelle, { ok = true, locations = sichtbar })
end)
