HM_BP = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

local gespawntePeds = {}
local erstellteBlips = {}

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
  if not standort.ped or standort.ped.aktiv ~= true then return end

  local hash = modellLaden(standort.ped.modell)
  if not hash then return end

  local ped = CreatePed(4, hash, standort.koordinaten.x, standort.koordinaten.y, standort.koordinaten.z - 1.0, standort.heading or 0.0, false, true)
  SetEntityAsMissionEntity(ped, true, true)

  if standort.ped.unverwundbar then SetEntityInvincible(ped, true) end
  if standort.ped.eingefroren then FreezeEntityPosition(ped, true) end
  if standort.ped.blockiereEvents then SetBlockingOfNonTemporaryEvents(ped, true) end

  if standort.ped.scenario and standort.ped.scenario ~= "" then
    TaskStartScenarioInPlace(ped, standort.ped.scenario, 0, true)
  end

  gespawntePeds[standort.id] = ped
  SetModelAsNoLongerNeeded(hash)
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
  if not standort.aktiv then return false end
  -- echte Rechteprüfung kommt serverseitig; clientseitig nur UX.
  return true
end

local function portalOeffnen(standort)
  HM_BP.Client.UIOeffnen({
    standortId = standort.id,
    standortName = standort.name
  })
end

CreateThread(function()
  Wait(1000)

  if not Config.Standorte.Aktiviert then return end

  for _, standort in pairs(Config.Standorte.Liste) do
    if standort.aktiv then
      pedErstellen(standort)
      blipErstellen(standort)
    end
  end

  if (Config.Kern.Interaktion.Modus == "taste") then
    while true do
      local schlafen = 900
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      for _, standort in pairs(Config.Standorte.Liste) do
        if kannInteragieren(standort) then
          local dist = #(pos - standort.koordinaten)
          if dist < (standort.sichtbarRadius or 30.0) then
            schlafen = 0

            if standort.marker and standort.marker.aktiv then
              DrawMarker(
                standort.marker.typ or 2,
                standort.koordinaten.x, standort.koordinaten.y, standort.koordinaten.z + 0.2,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                standort.marker.groesse.x, standort.marker.groesse.y, standort.marker.groesse.z,
                standort.marker.farbe.r, standort.marker.farbe.g, standort.marker.farbe.b, standort.marker.farbe.a,
                false, true, 2, nil, nil, false
              )
            end

            if dist < (standort.interaktionsRadius or 2.0) then
              local text = (standort.interaktion and standort.interaktion.text) or Config.Kern.Interaktion.Text
              BeginTextCommandDisplayHelp("STRING")
              AddTextComponentSubstringPlayerName(text)
              EndTextCommandDisplayHelp(0, false, true, -1)

              local taste = (standort.interaktion and standort.interaktion.taste) or Config.Kern.Interaktion.Taste
              if IsControlJustReleased(0, taste) then
                portalOeffnen(standort)
              end
            end
          end
        end
      end

      Wait(schlafen)
    end
  end

  -- ox_target wird im nächsten Modul integriert (konfigurierbar)
end)