ESX = ESX or nil

CreateThread(function()
  while ESX == nil do
    ESX = exports['es_extended']:getSharedObject()
    if ESX == nil then
      Wait(250)
    end
  end
end)