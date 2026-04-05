HM_BP = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

local Benachrichtigung = {}

function Benachrichtigung.Anzeigen(nachricht, typ, dauer)
  dauer = dauer or (Config.Benachrichtigungen.Ingame.StandardDauerMs or 5500)

  if Config.Benachrichtigungen.Aktiviert ~= true or Config.Benachrichtigungen.Ingame.Aktiviert ~= true then
    return
  end

  if Config.Benachrichtigungen.Ingame.Anbieter == "esx" then
    if ESX and ESX.ShowNotification then
      ESX.ShowNotification(nachricht)
      return
    end
  end

  -- Fallback
  BeginTextCommandThefeedPost("STRING")
  AddTextComponentSubstringPlayerName(nachricht)
  EndTextCommandThefeedPostTicker(false, dauer)
end

HM_BP.Client.Benachrichtigung = Benachrichtigung
-- ---------------------------------------------------------------
-- Server-seitig ausgelöste Ingame-Benachrichtigungen empfangen
-- ---------------------------------------------------------------

RegisterNetEvent("hm_bp:benachrichtigung:ingame", function(payload)
  payload = payload or {}
  local nachricht = payload.nachricht
  local typ       = payload.typ or "info"
  if not nachricht or nachricht == "" then return end
  Benachrichtigung.Anzeigen(tostring(nachricht), typ)
end)
