HM_BP = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}

-- ============================================================
-- shared/location_schema.lua
-- Standard-Defaults und Validierungshelfer für Location-Configs
-- ============================================================

local LocationSchema = {}

LocationSchema.Defaults = {
  aktiv           = true,
  heading         = 0.0,
  interaktionsRadius = 2.0,
  sichtbarRadius  = 30.0,

  interaktion = {
    -- taste: optional override for this location (nil = use global Config.Kern.Interaktion.Taste)
    taste = nil,
    -- text: optional override for this location (nil = use global Config.Kern.Interaktion.Text)
    text  = nil,
  },

  ped = {
    aktiv           = false,
    modell          = "a_m_m_business_01",
    scenario        = "",
    unverwundbar    = true,
    eingefroren     = true,
    blockiereEvents = true,
  },

  marker = {
    aktiv   = true,
    typ     = 2,
    -- groesse must be vector3; set in MitDefaults if missing
    farbe   = { r = 0, g = 120, b = 255, a = 160 },
  },

  blip = {
    aktiv  = false,
    sprite = 1,
    farbe  = 0,
    scale  = 0.8,
    name   = "Bürgerportal",
  },

  zugriff = {
    nurBuerger         = false,
    nurJustiz          = false,
    nurAdmin           = false,
    erlaubteRollen     = {},   -- e.g. { "buerger", "justiz", "admin" }
    erlaubteJobs       = {},   -- e.g. { "doj", "admin" }
    erlaubteKategorien = {},   -- empty = all categories allowed
    erlaubteFormulare  = {},   -- empty = all forms allowed
  },
}

-- Apply defaults to a location config table (shallow merge, does not overwrite set values).
function LocationSchema.MitDefaults(standort)
  if type(standort) ~= "table" then return standort end

  local d = LocationSchema.Defaults

  if standort.heading         == nil then standort.heading         = d.heading         end
  if standort.interaktionsRadius == nil then standort.interaktionsRadius = d.interaktionsRadius end
  if standort.sichtbarRadius  == nil then standort.sichtbarRadius  = d.sichtbarRadius  end

  -- interaktion sub-table
  if standort.interaktion == nil then
    standort.interaktion = {}
  end

  -- ped sub-table
  if standort.ped == nil then
    standort.ped = HM_BP.Shared.Util and HM_BP.Shared.Util.DeepCopy(d.ped) or { aktiv = false }
  else
    for k, v in pairs(d.ped) do
      if standort.ped[k] == nil then standort.ped[k] = v end
    end
  end

  -- marker sub-table
  if standort.marker == nil then
    standort.marker = HM_BP.Shared.Util and HM_BP.Shared.Util.DeepCopy(d.marker) or { aktiv = false }
  else
    for k, v in pairs(d.marker) do
      if standort.marker[k] == nil then standort.marker[k] = v end
    end
    if standort.marker.groesse == nil then
      standort.marker.groesse = vector3(0.3, 0.3, 0.3)
    end
    if standort.marker.farbe == nil then
      standort.marker.farbe = { r = 0, g = 120, b = 255, a = 160 }
    end
  end

  -- blip sub-table
  if standort.blip == nil then
    standort.blip = HM_BP.Shared.Util and HM_BP.Shared.Util.DeepCopy(d.blip) or { aktiv = false }
  else
    for k, v in pairs(d.blip) do
      if standort.blip[k] == nil then standort.blip[k] = v end
    end
  end

  -- zugriff sub-table
  if standort.zugriff == nil then
    standort.zugriff = HM_BP.Shared.Util and HM_BP.Shared.Util.DeepCopy(d.zugriff) or {}
  else
    for k, v in pairs(d.zugriff) do
      if standort.zugriff[k] == nil then standort.zugriff[k] = v end
    end
  end

  return standort
end

-- Validate a location config; returns ok (bool), message (string|nil).
function LocationSchema.IstGueltig(standort)
  if type(standort) ~= "table" then
    return false, "Standort ist kein Table."
  end
  if not standort.id or standort.id == "" then
    return false, "Standort hat keine ID."
  end
  if not standort.koordinaten then
    return false, ("Standort '%s' hat keine koordinaten."):format(tostring(standort.id))
  end
  -- koordinaten must be vector3-like
  if standort.koordinaten.x == nil or standort.koordinaten.y == nil or standort.koordinaten.z == nil then
    return false, ("Standort '%s': koordinaten muss x/y/z enthalten."):format(tostring(standort.id))
  end
  return true, nil
end

HM_BP.Shared.LocationSchema = LocationSchema
