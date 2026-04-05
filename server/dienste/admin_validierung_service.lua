-- =============================================================
-- server/dienste/admin_validierung_service.lua
--
-- Serverseitige Validierung für Admin-verwaltete Entitäten.
-- Liefert deutsche Fehlermeldungen.
-- Prüft auch referentielle Integrität (z.B. Kategorie-ID existiert).
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AdminValidierungService = {}

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

local function istString(v)  return type(v) == "string" and v ~= "" end
local function istZahl(v)    return type(v) == "number" end
local function istBool(v)    return type(v) == "boolean" end
local function istTabelle(v) return type(v) == "table" end

local function fehler(msg) return false, msg end
local function ok()        return true, nil  end

local function pflichtString(wert, feldName)
  if not istString(wert) then
    return false, ("Feld '%s' ist ein Pflichtfeld und muss eine nicht-leere Zeichenkette sein."):format(feldName)
  end
  return true, nil
end

-- ----------------------------------------------------------------
-- Standort-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereStandort(daten, alleStandorteIds)
  if not istTabelle(daten) then return fehler("Standort-Daten müssen eine Tabelle sein.") end

  local ok2, err

  ok2, err = pflichtString(daten.id, "id")
  if not ok2 then return fehler(err) end

  if daten.id:match("[^%w_%-]") then
    return fehler("Feld 'id' darf nur Buchstaben, Ziffern, Unterstriche und Bindestriche enthalten.")
  end

  ok2, err = pflichtString(daten.name, "name")
  if not ok2 then return fehler(err) end

  if daten.aktiv ~= nil and not istBool(daten.aktiv) then
    return fehler("Feld 'aktiv' muss ein boolescher Wert (true/false) sein.")
  end

  -- Koordinaten: optional, aber wenn vorhanden müssen x/y/z Zahlen sein
  if daten.koordinaten ~= nil then
    local k = daten.koordinaten
    if not istTabelle(k) then return fehler("Feld 'koordinaten' muss eine Tabelle mit x, y, z sein.") end
    if k.x ~= nil and tonumber(k.x) == nil then return fehler("koordinaten.x muss eine Zahl sein.") end
    if k.y ~= nil and tonumber(k.y) == nil then return fehler("koordinaten.y muss eine Zahl sein.") end
    if k.z ~= nil and tonumber(k.z) == nil then return fehler("koordinaten.z muss eine Zahl sein.") end
  end

  if daten.interaktionsRadius ~= nil and tonumber(daten.interaktionsRadius) == nil then
    return fehler("Feld 'interaktionsRadius' muss eine Zahl sein.")
  end

  if daten.sichtbarRadius ~= nil and tonumber(daten.sichtbarRadius) == nil then
    return fehler("Feld 'sichtbarRadius' muss eine Zahl sein.")
  end

  if daten.zugriff ~= nil and not istTabelle(daten.zugriff) then
    return fehler("Feld 'zugriff' muss eine Tabelle sein.")
  end

  if daten.ped ~= nil and not istTabelle(daten.ped) then
    return fehler("Feld 'ped' muss eine Tabelle sein.")
  end

  if daten.marker ~= nil and not istTabelle(daten.marker) then
    return fehler("Feld 'marker' muss eine Tabelle sein.")
  end

  if daten.blip ~= nil and not istTabelle(daten.blip) then
    return fehler("Feld 'blip' muss eine Tabelle sein.")
  end

  return ok()
end

-- ----------------------------------------------------------------
-- Kategorie-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereKategorie(daten)
  if not istTabelle(daten) then return fehler("Kategorie-Daten müssen eine Tabelle sein.") end

  local ok2, err

  ok2, err = pflichtString(daten.id, "id")
  if not ok2 then return fehler(err) end

  if daten.id:match("[^%w_%-]") then
    return fehler("Feld 'id' darf nur Buchstaben, Ziffern, Unterstriche und Bindestriche enthalten.")
  end

  ok2, err = pflichtString(daten.name, "name")
  if not ok2 then return fehler(err) end

  if daten.aktiv ~= nil and not istBool(daten.aktiv) then
    return fehler("Feld 'aktiv' muss ein boolescher Wert (true/false) sein.")
  end

  if daten.sortierung ~= nil and tonumber(daten.sortierung) == nil then
    return fehler("Feld 'sortierung' muss eine Zahl sein.")
  end

  if daten.farbe ~= nil and type(daten.farbe) == "string" then
    if not daten.farbe:match("^#%x%x%x%x%x%x$") and not daten.farbe:match("^#%x%x%x$") then
      return fehler("Feld 'farbe' muss ein gültiger Hex-Farbcode sein (z.B. #2f80ed).")
    end
  end

  if daten.sichtbarkeit ~= nil and not istTabelle(daten.sichtbarkeit) then
    return fehler("Feld 'sichtbarkeit' muss eine Tabelle sein.")
  end

  if daten.permissions ~= nil and not istTabelle(daten.permissions) then
    return fehler("Feld 'permissions' muss eine Tabelle sein.")
  end

  return ok()
end

-- ----------------------------------------------------------------
-- Formular-Validierung
-- ----------------------------------------------------------------

local ERLAUBTE_FORMULAR_STATUS = { entwurf = true, veroeffentlicht = true, archiviert = true }

function AdminValidierungService.ValidiereFormular(daten, alleKategorienIds)
  if not istTabelle(daten) then return fehler("Formular-Daten müssen eine Tabelle sein.") end

  local ok2, err

  ok2, err = pflichtString(daten.id, "id")
  if not ok2 then return fehler(err) end

  if daten.id:match("[^%w_%-]") then
    return fehler("Feld 'id' darf nur Buchstaben, Ziffern, Unterstriche und Bindestriche enthalten.")
  end

  ok2, err = pflichtString(daten.name, "name")
  if not ok2 then return fehler(err) end

  if daten.status ~= nil then
    if not ERLAUBTE_FORMULAR_STATUS[daten.status] then
      return fehler(("Feld 'status' muss einer dieser Werte sein: %s"):format(
        table.concat({"entwurf", "veroeffentlicht", "archiviert"}, ", ")
      ))
    end
  end

  -- Referentielle Integrität: kategorie_id muss existieren (wenn angegeben und Kategorien bekannt)
  if daten.kategorie_id ~= nil and istTabelle(alleKategorienIds) then
    if not alleKategorienIds[daten.kategorie_id] then
      return fehler(("Kategorie '%s' existiert nicht. Bitte eine gültige Kategorie-ID verwenden."):format(
        tostring(daten.kategorie_id)
      ))
    end
  end

  if daten.cooldownSekunden ~= nil and tonumber(daten.cooldownSekunden) == nil then
    return fehler("Feld 'cooldownSekunden' muss eine Zahl sein.")
  end

  if daten.maxOffen ~= nil and tonumber(daten.maxOffen) == nil then
    return fehler("Feld 'maxOffen' muss eine Zahl sein.")
  end

  if daten.felder ~= nil and not istTabelle(daten.felder) then
    return fehler("Feld 'felder' muss eine Tabelle (Array) sein.")
  end

  if daten.gebuehren ~= nil and not istTabelle(daten.gebuehren) then
    return fehler("Feld 'gebuehren' muss eine Tabelle sein.")
  end

  return ok()
end

-- ----------------------------------------------------------------
-- Webhook-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereWebhook(url)
  if not istString(url) then
    return fehler("Webhook-URL muss eine nicht-leere Zeichenkette sein.")
  end
  if not url:match("^https://") then
    return fehler("Webhook-URL muss mit 'https://' beginnen.")
  end
  if not url:match("discord%.com/api/webhooks/") and
     not url:match("discordapp%.com/api/webhooks/") then
    return fehler("Webhook-URL muss eine gültige Discord-Webhook-URL sein.")
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Permissions-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidierePermissions(daten)
  if not istTabelle(daten) then
    return fehler("Permissions-Daten müssen eine Tabelle sein.")
  end
  if daten.Defaults ~= nil and not istTabelle(daten.Defaults) then
    return fehler("Feld 'Defaults' muss eine Tabelle sein.")
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Status-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereStatus(daten)
  if not istTabelle(daten) then
    return fehler("Status-Daten müssen eine Tabelle sein.")
  end
  if daten.Liste ~= nil and not istTabelle(daten.Liste) then
    return fehler("Feld 'Liste' muss eine Tabelle sein.")
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Module-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereModule(daten)
  if not istTabelle(daten) then
    return fehler("Module-Daten müssen eine Tabelle sein.")
  end
  for k, v in pairs(daten) do
    if not istBool(v) then
      return fehler(("Modul '%s' muss ein boolescher Wert (true/false) sein."):format(tostring(k)))
    end
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Workflows-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereWorkflows(daten)
  if not istTabelle(daten) then
    return fehler("Workflows-Daten müssen eine Tabelle sein.")
  end
  if daten.Aktiviert ~= nil and not istBool(daten.Aktiviert) then
    return fehler("Feld 'Aktiviert' muss ein boolescher Wert sein.")
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Kern-Validierung (nur Justiz-Untersektion via Overrides änderbar)
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereKern(daten)
  if not istTabelle(daten) then
    return fehler("Kern-Daten müssen eine Tabelle sein.")
  end
  -- Sicherheit: Admin-Job-Konfiguration darf NICHT über Overrides geändert werden
  -- (verhindert Privilege Escalation via Config-Manipulation).
  if daten.Admin ~= nil then
    return fehler("Die 'Admin'-Konfiguration innerhalb 'Kern' kann nicht über das Admin-Panel geändert werden. Bitte config.lua direkt bearbeiten.")
  end
  if daten.Justiz ~= nil then
    if not istTabelle(daten.Justiz) then
      return fehler("Feld 'Kern.Justiz' muss eine Tabelle sein.")
    end
    if daten.Justiz.Job ~= nil and not istString(daten.Justiz.Job) then
      return fehler("Feld 'Kern.Justiz.Job' muss eine nicht-leere Zeichenkette sein.")
    end
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Anhaenge-Validierung
-- ----------------------------------------------------------------

function AdminValidierungService.ValidiereAnhaenge(daten)
  if not istTabelle(daten) then
    return fehler("Anhaenge-Daten müssen eine Tabelle sein.")
  end
  if daten.MaxProAntrag ~= nil and tonumber(daten.MaxProAntrag) == nil then
    return fehler("Feld 'MaxProAntrag' muss eine Zahl sein.")
  end
  return ok()
end

-- ----------------------------------------------------------------
-- Dispatcher: Validiere beliebige Sektion
-- ----------------------------------------------------------------

local SEKTION_VALIDATOREN = {
  Standorte   = function(d) return AdminValidierungService.ValidiereStandort(d) end,
  Kategorien  = function(d) return AdminValidierungService.ValidiereKategorie(d) end,
  Formulare   = function(d) return AdminValidierungService.ValidiereFormular(d) end,
  Permissions = function(d) return AdminValidierungService.ValidierePermissions(d) end,
  Status      = function(d) return AdminValidierungService.ValidiereStatus(d) end,
  Webhooks    = function(d)
    -- Webhooks-Sektion hat keine eigene Entitäts-Validierung auf Top-Level
    if type(d) ~= "table" then return false, "Webhooks-Daten müssen eine Tabelle sein." end
    return true, nil
  end,
  Workflows   = function(d) return AdminValidierungService.ValidiereWorkflows(d) end,
  Anhaenge    = function(d) return AdminValidierungService.ValidiereAnhaenge(d) end,
  Module      = function(d) return AdminValidierungService.ValidiereModule(d) end,
  Kern        = function(d) return AdminValidierungService.ValidiereKern(d) end,
}

---Validiert eine komplette Sektion (Top-Level).
---@param sektion string
---@param daten table
---@return boolean ok
---@return string? fehlerNachricht
function AdminValidierungService.ValidiereSektion(sektion, daten)
  local validator = SEKTION_VALIDATOREN[sektion]
  if not validator then
    return false, ("Unbekannte Sektion '%s'. Validierung nicht möglich."):format(tostring(sektion))
  end
  return validator(daten)
end

HM_BP.Server.Dienste.AdminValidierungService = AdminValidierungService
