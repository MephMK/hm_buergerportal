-- =============================================================
-- server/api_admin.lua
--
-- Server-API für den Adminbereich.
-- Alle Endpunkte:
--   1. Prüfen ob Spieler Admin ist (Job + MinGrade aus Config.Kern.Admin)
--   2. Bei Mutations-Endpunkten: Grund (reason) darf nicht leer sein
--   3. Schreiben Audit-Einträge via AdminAuditService
--   4. Lesen/Schreiben Overrides via AdminConfigService
--
-- Events (Client → Server → Client):
--   hm_bp:admin:panel_anfordern        → hm_bp:admin:panel_antwort
--   hm_bp:admin:sektion_laden          → hm_bp:admin:sektion_antwort
--   hm_bp:admin:sektion_speichern      → hm_bp:admin:sektion_speichern_antwort
--   hm_bp:admin:sektion_validieren     → hm_bp:admin:sektion_validieren_antwort
--   hm_bp:admin:sektion_zuruecksetzen  → hm_bp:admin:sektion_zuruecksetzen_antwort
--   hm_bp:admin:audit_laden            → hm_bp:admin:audit_antwort
--   hm_bp:admin:neuladen               → hm_bp:admin:neuladen_antwort
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ----------------------------------------------------------------
-- Interne Hilfsfunktionen
-- ----------------------------------------------------------------

local function cfgSvc()  return HM_BP.Server.Dienste.AdminConfigService  end
local function audSvc()  return HM_BP.Server.Dienste.AdminAuditService   end
local function valSvc()  return HM_BP.Server.Dienste.AdminValidierungService end

-- Prüft Admin-Berechtigung mit zwei unabhängigen Schichten:
--   1) Rate-Limit + Permission-Check via Middleware
--   2) Direkte Job+Grade-Prüfung gegen Config.Kern.Admin (NICHT überschreibbar via Overrides)
-- Dadurch kann kein Angreifer durch Manipulation der Config.Permissions-Sektion
-- Zugriff auf den Admin-Bereich erhalten.
local function pruefeAdmin(quelle, aktion)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, aktion or HM_BP.Shared.Actions.ADMIN_PANEL_OPEN, {})
  if not spieler then return nil, err end

  -- Hardcoded Job+Grade-Prüfung gegen Config.Kern.Admin (dieser Abschnitt liegt
  -- NICHT im Verwaltungsbereich der Overrides und kann nicht per Admin-Panel geändert werden).
  -- AuthService.RolleErmitteln liest ausschließlich Config.Kern.Admin/Jobs.
  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  if rolle ~= "admin" then
    return nil, {
      code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
      nachricht = "Nur Administratoren dürfen auf den Adminbereich zugreifen."
    }
  end
  spieler.rolle = rolle
  return spieler, nil
end

local function grundPruefen(grund)
  if type(grund) ~= "string" or grund:match("^%s*$") then
    return false, "Ein Grund (reason) ist Pflicht und darf nicht leer sein."
  end
  return true, nil
end

-- Gültige Sektionen: aus AdminConfigService.SEKTIONEN abgeleitet (single source of truth).
-- Wird als Set für O(1)-Lookup aufgebaut.
local function gueltigeSektionenSet()
  local svc = cfgSvc()
  local sektionen = (svc and svc.SEKTIONEN) or
    { "Standorte", "Kategorien", "Formulare", "Permissions", "Status", "Webhooks" }
  local set = {}
  for _, s in ipairs(sektionen) do set[s] = true end
  return set, sektionen
end

local function sektionValidieren(sektion, daten)
  local set, liste = gueltigeSektionenSet()
  if not set[sektion] then
    return false, ("Unbekannte Sektion '%s'. Gültige Sektionen: %s"):format(
      tostring(sektion),
      table.concat(liste, ", ")
    )
  end
  if type(daten) ~= "table" then
    return false, "Die Sektions-Daten müssen eine JSON-Tabelle sein."
  end

  -- Erweitertes Schema-Validierung via AdminValidierungService (falls verfügbar)
  local vs = valSvc()
  if vs then
    local valOk, valErr = vs.ValidiereSektion(sektion, daten)
    if not valOk then return false, valErr end
    return true, nil
  end

  -- Fallback: Sektion-spezifische Basisprüfungen
  if sektion == "Standorte" or sektion == "Kategorien" or sektion == "Formulare" or sektion == "Status" then
    if daten.Liste ~= nil and type(daten.Liste) ~= "table" then
      return false, "Feld 'Liste' muss eine Tabelle sein."
    end
  end
  if sektion == "Permissions" then
    if daten.Defaults ~= nil and type(daten.Defaults) ~= "table" then
      return false, "Feld 'Defaults' muss eine Tabelle sein."
    end
  end
  if sektion == "Webhooks" then
    if daten.Routing ~= nil and type(daten.Routing) ~= "table" then
      return false, "Feld 'Routing' muss eine Tabelle sein."
    end
  end
  return true, nil
end

-- ----------------------------------------------------------------
-- Adminbereich öffnen / Panel laden
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:panel_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:panel_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local svc = cfgSvc()
  local eff = svc and svc.GetEffectiveConfig() or Config

  -- Nur die relevanten Sektionen senden (kein kompletter Config-Dump)
  local verwaltete = (svc and svc.SEKTIONEN) or
    { "Standorte", "Kategorien", "Formulare", "Permissions", "Status", "Webhooks" }
  local sektionen = {}
  for _, sek in ipairs(verwaltete) do
    sektionen[sek] = eff[sek] or {}
  end

  TriggerClientEvent("hm_bp:admin:panel_antwort", quelle, {
    ok       = true,
    sektionen = sektionen,
    admin    = {
      job      = Config.Kern.Admin and Config.Kern.Admin.Job     or Config.Kern.Jobs.Admin,
      minGrade = Config.Kern.Admin and Config.Kern.Admin.MinGrade or 0,
    }
  })
end)

-- ----------------------------------------------------------------
-- Sektion laden (effektiv oder nur Overrides)
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:sektion_laden", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:sektion_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local sektion = payload.sektion
  local svc = cfgSvc()
  local sektSet = {}
  for _, s in ipairs((svc and svc.SEKTIONEN) or
    { "Standorte", "Kategorien", "Formulare", "Permissions", "Status", "Webhooks" }) do
    sektSet[s] = true
  end
  if not sektSet[sektion] then
    TriggerClientEvent("hm_bp:admin:sektion_antwort", quelle, {
      ok = false, fehler = { nachricht = "Unbekannte Sektion." }
    })
    return
  end
  local modus = payload.modus or "effektiv"  -- "effektiv" | "override" | "basis"

  local daten
  if modus == "override" then
    daten = svc and svc.GetOverrides(sektion) or {}
  elseif modus == "basis" then
    daten = svc and svc.GetBasis(sektion) or (Config[sektion] or {})
  else
    local eff = svc and svc.GetEffectiveConfig() or Config
    daten = eff[sektion] or {}
  end

  TriggerClientEvent("hm_bp:admin:sektion_antwort", quelle, {
    ok      = true,
    sektion = sektion,
    modus   = modus,
    daten   = daten,
  })
end)

-- ----------------------------------------------------------------
-- Sektion validieren (Dry-run, kein Speichern)
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:sektion_validieren", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:sektion_validieren_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local sektion = payload.sektion
  local daten   = payload.daten

  local valOk, valErr = sektionValidieren(sektion, daten)
  if not valOk then
    TriggerClientEvent("hm_bp:admin:sektion_validieren_antwort", quelle, {
      ok = false, fehler = { nachricht = valErr }
    })
    return
  end

  TriggerClientEvent("hm_bp:admin:sektion_validieren_antwort", quelle, {
    ok = true, nachricht = "Validierung erfolgreich (keine Schema-Fehler gefunden)."
  })
end)

-- ----------------------------------------------------------------
-- Sektion speichern (mit Grund + Audit)
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:sektion_speichern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:sektion_speichern_antwort", quelle, { ok = false, fehler = err })
    return
  end

  -- Grund ist Pflicht
  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:sektion_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = grundErr }
    })
    return
  end

  local sektion = payload.sektion
  local daten   = payload.daten

  -- Validierung
  local valOk, valErr = sektionValidieren(sektion, daten)
  if not valOk then
    TriggerClientEvent("hm_bp:admin:sektion_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = valErr }
    })
    return
  end

  -- Alte Daten für Audit-Diff sichern
  local svc   = cfgSvc()
  local altDaten = svc and svc.GetOverrides(sektion) or {}

  -- Speichern
  local saveOk, saveErr
  if svc then
    saveOk, saveErr = svc.SektionSpeichern(sektion, daten)
  else
    saveOk, saveErr = false, "AdminConfigService nicht verfügbar"
  end
  if not saveOk then
    TriggerClientEvent("hm_bp:admin:sektion_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = tostring(saveErr) }
    })
    return
  end

  -- Audit schreiben
  local aud = audSvc()
  if aud then
    aud.Log(
      "sektion.speichern",
      spieler,
      payload.grund,
      sektion,
      altDaten,
      daten
    )
  end

  -- Webhook-Benachrichtigung (optional, falls Webhook konfiguriert)
  local ws = HM_BP.Server.Dienste.WebhookService
  if ws and ws.Emit then
    ws.Emit("admin.config.changed", {
      sektion    = sektion,
      actor_name = spieler.name,
      grund      = payload.grund,
    })
  end

  TriggerClientEvent("hm_bp:admin:sektion_speichern_antwort", quelle, {
    ok = true,
    nachricht = ("Sektion '%s' erfolgreich gespeichert."):format(tostring(sektion))
  })
end)

-- ----------------------------------------------------------------
-- Sektion zurücksetzen (Override löschen → Basisconfig aktiv)
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:sektion_zuruecksetzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:sektion_zuruecksetzen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:sektion_zuruecksetzen_antwort", quelle, {
      ok = false, fehler = { nachricht = grundErr }
    })
    return
  end

  local sektion = payload.sektion
  local svc = cfgSvc()
  local sektSet2 = {}
  for _, s in ipairs((svc and svc.SEKTIONEN) or
    { "Standorte", "Kategorien", "Formulare", "Permissions", "Status", "Webhooks" }) do
    sektSet2[s] = true
  end
  if not sektSet2[sektion] then
    TriggerClientEvent("hm_bp:admin:sektion_zuruecksetzen_antwort", quelle, {
      ok = false, fehler = { nachricht = "Unbekannte Sektion." }
    })
    return
  end
  local altDaten = svc and svc.GetOverrides(sektion) or {}
  local ok, err2
  if svc then
    ok, err2 = svc.SektionZuruecksetzen(sektion)
  else
    ok, err2 = false, "AdminConfigService nicht verfügbar"
  end
  if not ok then
    TriggerClientEvent("hm_bp:admin:sektion_zuruecksetzen_antwort", quelle, {
      ok = false, fehler = { nachricht = tostring(err2) }
    })
    return
  end

  local aud = audSvc()
  if aud then
    aud.Log("sektion.zuruecksetzen", spieler, payload.grund, sektion, altDaten, nil)
  end

  TriggerClientEvent("hm_bp:admin:sektion_zuruecksetzen_antwort", quelle, {
    ok = true,
    nachricht = ("Override für Sektion '%s' zurückgesetzt."):format(tostring(sektion))
  })
end)

-- ----------------------------------------------------------------
-- Audit-Log laden
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:audit_laden", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:audit_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local aud = audSvc()
  local eintraege = aud and aud.Holen(payload.limit or 100) or {}

  TriggerClientEvent("hm_bp:admin:audit_antwort", quelle, {
    ok        = true,
    eintraege = eintraege,
  })
end)

-- ----------------------------------------------------------------
-- Config neu laden
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:neuladen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:neuladen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:neuladen_antwort", quelle, {
      ok = false, fehler = { nachricht = grundErr }
    })
    return
  end

  local svc = cfgSvc()
  if svc then svc.Neuladen() end

  local aud = audSvc()
  if aud then
    aud.Log("config.neuladen", spieler, payload.grund, nil, nil, nil)
  end

  TriggerClientEvent("hm_bp:admin:neuladen_antwort", quelle, {
    ok = true, nachricht = "Konfiguration neu geladen."
  })
end)
