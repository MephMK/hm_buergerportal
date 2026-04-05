HM_BP = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

-- ============================================================
-- client/target_adapter.lua
-- Thin wrapper around ox_target.
-- Only active when Config.Kern.Interaktion.Modus == "ox_target"
-- AND the ox_target resource is available.
-- No hard dependency: if ox_target is absent, all calls are no-ops.
-- ============================================================

local TargetAdapter = {}

local function oxTargetVerfuegbar()
  if not Config.Kern.Interaktion or Config.Kern.Interaktion.Modus ~= "ox_target" then return false end
  -- Check whether ox_target export is available at runtime
  local ok, _ = pcall(function() return exports['ox_target'] end)
  return ok
end

-- Add a sphere zone (used when no ped is present at the location).
-- id       : unique location id (string)
-- koordinaten : vector3
-- radius   : number
-- label    : interaction label shown to the player
-- callback : function() called when the player selects the option
function TargetAdapter.ZoneHinzufuegen(id, koordinaten, radius, label, callback)
  if not oxTargetVerfuegbar() then return end
  local ok, err = pcall(function()
    exports['ox_target']:addSphereZone({
      coords  = koordinaten,
      radius  = radius or 2.0,
      options = {
        {
          name     = "hm_bp_zone_" .. tostring(id),
          label    = label or "[E] Bürgerportal öffnen",
          onSelect = callback,
        }
      }
    })
  end)
  if not ok and Config.Kern.Debugmodus then
    print(("[hm_buergerportal][target_adapter] ZoneHinzufuegen Fehler: %s"):format(tostring(err)))
  end
end

-- Remove a previously registered sphere zone.
function TargetAdapter.ZoneEntfernen(id)
  if not oxTargetVerfuegbar() then return end
  pcall(function()
    exports['ox_target']:removeZone("hm_bp_zone_" .. tostring(id))
  end)
end

-- Add an interaction option to a local ped entity.
-- pedHandle : entity handle returned by CreatePed
-- id        : unique location id (string)
-- label     : interaction label shown to the player
-- callback  : function() called when the player selects the option
function TargetAdapter.PedZoneHinzufuegen(pedHandle, id, label, callback)
  if not oxTargetVerfuegbar() then return end
  local ok, err = pcall(function()
    exports['ox_target']:addLocalEntity({
      entities = { pedHandle },
      options  = {
        {
          name     = "hm_bp_ped_" .. tostring(id),
          label    = label or "[E] Bürgerportal öffnen",
          onSelect = callback,
        }
      }
    })
  end)
  if not ok and Config.Kern.Debugmodus then
    print(("[hm_buergerportal][target_adapter] PedZoneHinzufuegen Fehler: %s"):format(tostring(err)))
  end
end

HM_BP.Client.TargetAdapter = TargetAdapter
