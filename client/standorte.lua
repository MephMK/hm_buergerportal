HM_BP = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

-- ============================================================
-- client/standorte.lua  (location_client)
-- Spawnt Peds/Blips, zeichnet Marker, behandelt Interaktionen.
-- UI-Öffnung wird grundsätzlich serverseitig genehmigt.
-- Interaktionsmodus: "taste" (Standard) oder "ox_target".
-- ============================================================

local gespawntePeds  = {}
local erstellteBlips = {}

-- Prevents duplicate open-requests while waiting for server answer.
local wartendeOeffnung = nil

-- -------------------------------------------------------
-- Hilfsfunktionen
-- -------------------------------------------------------

local function modellLaden(modell)
  local hash = type(modell) == "number" and modell or joaat(modell)
  if not IsModelInCdimage(hash) then return nil end
  RequestModel(hash)
  local timeout = GetGameTimer() + 8000
  while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(10) end
  if not HasModelLoaded(hash) then return nil end
  return hash
end

local function pedErstellen(standort)
  if not standort.ped or standort.ped.aktiv ~= true then return nil end

  local hash = modellLaden(standort.ped.modell)
  if not hash then return nil end

  local ped = CreatePed(4, hash,
    standort.koordinaten.x, standort.koordinaten.y, standort.koordinaten.z - 1.0,
    standort.heading or 0.0, false, true)
  SetEntityAsMissionEntity(ped, true, true)

  if standort.ped.unverwundbar    then SetEntityInvincible(ped, true)             end
  if standort.ped.eingefroren     then FreezeEntityPosition(ped, true)            end
  if standort.ped.blockiereEvents then SetBlockingOfNonTemporaryEvents(ped, true) end

  if standort.ped.scenario and standort.ped.scenario ~= "" then
    TaskStartScenarioInPlace(ped, standort.ped.scenario, 0, true)
  end

  gespawntePeds[standort.id] = ped
  SetModelAsNoLongerNeeded(hash)
  return ped
end

local function blipErstellen(standort)
  if not standort.blip or standort.blip.aktiv ~= true then return end

  local blip = AddBlipForCoord(standort.koordinaten.x, standort.koordinaten.y, standort.koordinaten.z)
  SetBlipSprite(blip, standort.blip.sprite or 1)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, standort.blip.scale or 0.8)
  SetBlipColour(blip, standort.blip.farbe or 0)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(standort.blip.name or standort.name or "Bürgerportal")
  EndTextCommandSetBlipName(blip)

  erstellteBlips[standort.id] = blip
end

local function kannInteragieren(standort)
  -- Clientseitig nur UX-Gate; echte Prüfung erfolgt serverseitig.
  return standort.aktiv == true
end

-- Resolve the effective interaction mode:
-- per-location interaktion.modus → Config.Standorte.InteraktionsModus → Config.Kern.Interaktion.Modus
local function interaktionsModus(standort)
  if standort and standort.interaktion and standort.interaktion.modus then
    return standort.interaktion.modus
  end
  if Config.Standorte and Config.Standorte.InteraktionsModus then
    return Config.Standorte.InteraktionsModus
  end
  return (Config.Kern.Interaktion and Config.Kern.Interaktion.Modus) or "taste"
end

-- -------------------------------------------------------
-- Server-Approval Flow
-- Client requests approval → server decides → client opens UI.
-- -------------------------------------------------------

local function portalOeffnenAnfordern(standort)
  if wartendeOeffnung then return end  -- avoid duplicate requests
  wartendeOeffnung = standort.id
  TriggerServerEvent("hm_bp:location:ui_oeffnen_anfordern", { standortId = standort.id })
end

RegisterNetEvent("hm_bp:location:ui_oeffnen_antwort", function(res)
  local standortId = wartendeOeffnung
  wartendeOeffnung = nil

  if not res or not res.ok then
    local msg = (res and res.fehler and res.fehler.nachricht) or "Zugriff verweigert."
    if HM_BP.Client.Benachrichtigung then
      HM_BP.Client.Benachrichtigung.Anzeigen("~r~" .. msg, "error", 5000)
    end
    return
  end

  HM_BP.Client.UIOeffnen({
    standortId   = standortId,
    standortName = res.standort and res.standort.name or nil,
  })
end)

-- -------------------------------------------------------
-- Startup Thread – spawn entities & register interactions
-- -------------------------------------------------------

CreateThread(function()
  Wait(1000)

  if not Config.Standorte or not Config.Standorte.Aktiviert then return end

  for _, standort in pairs(Config.Standorte.Liste) do
    if standort.aktiv then
      local ped = pedErstellen(standort)
      blipErstellen(standort)

      local modus = interaktionsModus(standort)

      if modus == "ox_target" and HM_BP.Client.TargetAdapter then
        local label = (standort.interaktion and standort.interaktion.text) or Config.Kern.Interaktion.Text
        if ped then
          HM_BP.Client.TargetAdapter.PedZoneHinzufuegen(ped, standort.id, label, function()
            portalOeffnenAnfordern(standort)
          end)
        else
          HM_BP.Client.TargetAdapter.ZoneHinzufuegen(
            standort.id, standort.koordinaten,
            standort.interaktionsRadius or 2.0, label,
            function() portalOeffnenAnfordern(standort) end
          )
        end
      end
    end
  end

  -- Keyboard interaction loop (only runs when global modus is "taste")
  if interaktionsModus(nil) ~= "taste" then return end

  while true do
    local schlafen = 900
    local localPed = PlayerPedId()
    local pos      = GetEntityCoords(localPed)

    for _, standort in pairs(Config.Standorte.Liste) do
      -- Skip locations that use ox_target individually
      local modus = interaktionsModus(standort)
      if modus == "taste" and kannInteragieren(standort) then
        local dist = #(pos - standort.koordinaten)

        if dist < (standort.sichtbarRadius or 30.0) then
          schlafen = 0

          if standort.marker and standort.marker.aktiv then
            DrawMarker(
              standort.marker.typ or 2,
              standort.koordinaten.x, standort.koordinaten.y, standort.koordinaten.z + 0.2,
              0.0, 0.0, 0.0,
              0.0, 0.0, 0.0,
              standort.marker.groesse.x, standort.marker.groesse.y, standort.marker.groesse.z,
              standort.marker.farbe.r, standort.marker.farbe.g, standort.marker.farbe.b, standort.marker.farbe.a,
              false, true, 2, nil, nil, false
            )
          end

          if dist < (standort.interaktionsRadius or 2.0) then
            local text  = (standort.interaktion and standort.interaktion.text)  or Config.Kern.Interaktion.Text
            local taste = (standort.interaktion and standort.interaktion.taste) or Config.Kern.Interaktion.Taste

            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandDisplayHelp(0, false, true, -1)

            if IsControlJustReleased(0, taste) then
              portalOeffnenAnfordern(standort)
            end
          end
        end
      end
    end

    Wait(schlafen)
  end
end)