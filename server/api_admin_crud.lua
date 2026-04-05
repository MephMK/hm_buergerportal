-- =============================================================
-- server/api_admin_crud.lua
--
-- CRUD-Endpunkte für den Admin-Bereich:
--   hm_bp:admin:entity_speichern      – Einzelne Entität anlegen/aktualisieren
--   hm_bp:admin:entity_loeschen       – Einzelne Entität löschen
--   hm_bp:admin:kategorie_status      – Kategorie aktivieren/deaktivieren/archivieren
--   hm_bp:admin:formular_status       – Formular veröffentlichen/archivieren/wiederherstellen
--   hm_bp:admin:modul_toggle          – Feature-Flag umschalten
--   hm_bp:admin:webhook_test          – Webhook-URL testen
--   hm_bp:admin:sektion_validieren_v2 – Sektion mit Validierungsservice prüfen
--
-- Alle Endpunkte prüfen Admin-Berechtigung und schreiben Audit-Einträge.
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

local function cfgSvc()  return HM_BP.Server.Dienste.AdminConfigService   end
local function audSvc()  return HM_BP.Server.Dienste.AdminAuditService    end
local function valSvc()  return HM_BP.Server.Dienste.AdminValidierungService end

-- Admin-Prüfung (identisch zu api_admin.lua)
local function pruefeAdmin(quelle, aktion)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, aktion or HM_BP.Shared.Actions.ADMIN_PANEL_OPEN, {}
  )
  if not spieler then return nil, err end
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
    return false, "Ein Grund (Begründung) ist Pflichtfeld und darf nicht leer sein."
  end
  return true, nil
end

-- Tiefe Kopie via JSON
local function tiefKopie(tbl)
  if type(tbl) ~= "table" then return tbl end
  local ok2, copy = pcall(function() return json.decode(json.encode(tbl)) end)
  return (ok2 and type(copy) == "table") and copy or tbl
end

-- Sektions-Liste holen (z.B. Config.Standorte.Liste)
local function getSektionListe(sektion)
  local cfg = cfgSvc()
  local eff  = cfg and cfg.GetEffectiveConfig() or Config
  local sek  = eff[sektion]
  if not sek then return {} end
  return sek.Liste or sek
end

-- ----------------------------------------------------------------
-- Entity speichern (anlegen oder aktualisieren)
-- Payload: { sektion, entity_id, daten, grund }
-- Sektionen mit "Liste"-Struktur: Standorte, Kategorien, Formulare, Status
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:entity_speichern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle,
      { ok = false, fehler = { nachricht = grundErr } })
    return
  end

  local sektion   = payload.sektion
  local entityId  = payload.entity_id
  local neuDaten  = payload.daten

  if type(sektion)  ~= "string" or sektion == ""  then
    TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'sektion' ist Pflichtfeld." } })
    return
  end
  if type(entityId) ~= "string" or entityId == "" then
    TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'entity_id' ist Pflichtfeld." } })
    return
  end
  if type(neuDaten) ~= "table" then
    TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'daten' muss eine Tabelle sein." } })
    return
  end

  -- Entity-spezifische Validierung
  local vs = valSvc()
  if vs then
    local valOk, valErr
    if sektion == "Standorte" then
      valOk, valErr = vs.ValidiereStandort(neuDaten)
    elseif sektion == "Kategorien" then
      valOk, valErr = vs.ValidiereKategorie(neuDaten)
    elseif sektion == "Formulare" then
      -- Kategorien-IDs für referentielle Integritätsprüfung sammeln
      local katIds = {}
      local effCfg = (cfgSvc() and cfgSvc().GetEffectiveConfig()) or Config
      if effCfg.Kategorien and effCfg.Kategorien.Liste then
        for id, _ in pairs(effCfg.Kategorien.Liste) do katIds[id] = true end
      end
      valOk, valErr = vs.ValidiereFormular(neuDaten, katIds)
    elseif sektion == "Status" then
      valOk, valErr = vs.ValidiereStatus({ Liste = { [entityId] = neuDaten } })
    else
      valOk, valErr = true, nil
    end

    if not valOk then
      TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle,
        { ok = false, fehler = { nachricht = valErr } })
      return
    end
  end

  -- Aktuelle Override-Sektion laden
  local svc = cfgSvc()
  local currentOverride = tiefKopie((svc and svc.GetOverrides(sektion)) or {})
  if type(currentOverride.Liste) ~= "table" then
    currentOverride.Liste = {}
  end

  local altDaten = currentOverride.Liste[entityId]
  currentOverride.Liste[entityId] = neuDaten

  -- Speichern
  local saveOk, saveErr
  if svc then
    saveOk, saveErr = svc.SektionSpeichern(sektion, currentOverride)
  else
    saveOk, saveErr = false, "AdminConfigService nicht verfügbar"
  end

  if not saveOk then
    TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle,
      { ok = false, fehler = { nachricht = tostring(saveErr) } })
    return
  end

  -- Audit
  local aud = audSvc()
  if aud then
    aud.Log(
      altDaten and "entity.aktualisieren" or "entity.anlegen",
      spieler,
      payload.grund,
      sektion .. "." .. entityId,
      altDaten,
      neuDaten
    )
  end

  TriggerClientEvent("hm_bp:admin:entity_speichern_antwort", quelle, {
    ok = true,
    nachricht = ("Eintrag '%s' in Sektion '%s' erfolgreich gespeichert."):format(
      tostring(entityId), tostring(sektion)
    )
  })
end)

-- ----------------------------------------------------------------
-- Entity löschen
-- Payload: { sektion, entity_id, grund }
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:entity_loeschen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle,
      { ok = false, fehler = { nachricht = grundErr } })
    return
  end

  local sektion  = payload.sektion
  local entityId = payload.entity_id

  if type(sektion)  ~= "string" or sektion == "" then
    TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'sektion' ist Pflichtfeld." } })
    return
  end
  if type(entityId) ~= "string" or entityId == "" then
    TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'entity_id' ist Pflichtfeld." } })
    return
  end

  local svc = cfgSvc()
  local currentOverride = tiefKopie((svc and svc.GetOverrides(sektion)) or {})

  -- Wir müssen die vollständige effektive Liste nehmen und die Entity entfernen
  local effCfg = (svc and svc.GetEffectiveConfig()) or Config
  local effSektion = effCfg[sektion] or {}
  local effListe   = effSektion.Liste or {}

  if effListe[entityId] == nil then
    TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle,
      { ok = false, fehler = { nachricht = ("Eintrag '%s' nicht gefunden."):format(entityId) } })
    return
  end

  local altDaten = effListe[entityId]

  -- Override-Liste aufbauen: alle effektiven Einträge außer dem zu löschenden
  local neueListe = {}
  for id, daten in pairs(effListe) do
    if id ~= entityId then
      neueListe[id] = daten
    end
  end

  -- Basis-Metadaten beibehalten (Aktiviert, etc.)
  local basisMeta = {}
  local basis = (svc and svc.GetBasis(sektion)) or {}
  for k, v in pairs(basis) do
    if k ~= "Liste" then basisMeta[k] = v end
  end
  for k, v in pairs(currentOverride) do
    if k ~= "Liste" then basisMeta[k] = v end
  end

  basisMeta.Liste = neueListe

  local saveOk, saveErr
  if svc then
    saveOk, saveErr = svc.SektionSpeichern(sektion, basisMeta)
  else
    saveOk, saveErr = false, "AdminConfigService nicht verfügbar"
  end

  if not saveOk then
    TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle,
      { ok = false, fehler = { nachricht = tostring(saveErr) } })
    return
  end

  local aud = audSvc()
  if aud then
    aud.Log("entity.loeschen", spieler, payload.grund, sektion .. "." .. entityId, altDaten, nil)
  end

  TriggerClientEvent("hm_bp:admin:entity_loeschen_antwort", quelle, {
    ok = true,
    nachricht = ("Eintrag '%s' aus Sektion '%s' erfolgreich gelöscht."):format(
      tostring(entityId), tostring(sektion)
    )
  })
end)

-- ----------------------------------------------------------------
-- Kategorie-Status ändern (aktivieren / deaktivieren / archivieren)
-- Payload: { kategorie_id, aktion: "aktivieren"|"deaktivieren"|"archivieren", grund }
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:kategorie_status", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle,
      { ok = false, fehler = { nachricht = grundErr } })
    return
  end

  local katId  = payload.kategorie_id
  local aktion = payload.aktion

  if type(katId) ~= "string" or katId == "" then
    TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'kategorie_id' ist Pflichtfeld." } })
    return
  end

  local ERLAUBTE_AKTIONEN = { aktivieren = true, deaktivieren = true, archivieren = true }
  if not ERLAUBTE_AKTIONEN[aktion] then
    TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle,
      { ok = false, fehler = { nachricht = "Ungültige Aktion. Erlaubt: aktivieren, deaktivieren, archivieren." } })
    return
  end

  local svc = cfgSvc()
  local effCfg = (svc and svc.GetEffectiveConfig()) or Config
  local katListe = (effCfg.Kategorien and effCfg.Kategorien.Liste) or {}

  if not katListe[katId] then
    TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle,
      { ok = false, fehler = { nachricht = ("Kategorie '%s' nicht gefunden."):format(katId) } })
    return
  end

  local altKat = tiefKopie(katListe[katId])
  local override = tiefKopie((svc and svc.GetOverrides("Kategorien")) or {})
  if type(override.Liste) ~= "table" then override.Liste = {} end
  if type(override.Liste[katId]) ~= "table" then
    override.Liste[katId] = tiefKopie(katListe[katId])
  end

  if aktion == "aktivieren" then
    override.Liste[katId].aktiv      = true
    override.Liste[katId].archiviert = nil
  elseif aktion == "deaktivieren" then
    override.Liste[katId].aktiv = false
  elseif aktion == "archivieren" then
    override.Liste[katId].aktiv      = false
    override.Liste[katId].archiviert = true
  end

  local saveOk, saveErr
  if svc then
    saveOk, saveErr = svc.SektionSpeichern("Kategorien", override)
  else
    saveOk, saveErr = false, "AdminConfigService nicht verfügbar"
  end

  if not saveOk then
    TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle,
      { ok = false, fehler = { nachricht = tostring(saveErr) } })
    return
  end

  local aud = audSvc()
  if aud then
    aud.Log(
      "kategorie." .. aktion,
      spieler,
      payload.grund,
      "Kategorien." .. katId,
      altKat,
      override.Liste[katId]
    )
  end

  local AKTIONS_NACHRICHT = {
    aktivieren   = "aktiviert",
    deaktivieren = "deaktiviert",
    archivieren  = "archiviert",
  }

  TriggerClientEvent("hm_bp:admin:kategorie_status_antwort", quelle, {
    ok = true,
    nachricht = ("Kategorie '%s' erfolgreich %s."):format(
      tostring(katId), AKTIONS_NACHRICHT[aktion] or aktion
    )
  })
end)

-- ----------------------------------------------------------------
-- Formular-Status ändern (veröffentlichen / archivieren / wiederherstellen)
-- Payload: { formular_id, aktion: "veroeffentlichen"|"archivieren"|"wiederherstellen", grund }
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:formular_status", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle,
      { ok = false, fehler = { nachricht = grundErr } })
    return
  end

  local formId = payload.formular_id
  local aktion = payload.aktion

  if type(formId) ~= "string" or formId == "" then
    TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'formular_id' ist Pflichtfeld." } })
    return
  end

  local ERLAUBTE_AKTIONEN = { veroeffentlichen = true, archivieren = true, wiederherstellen = true }
  if not ERLAUBTE_AKTIONEN[aktion] then
    TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle,
      { ok = false, fehler = { nachricht = "Ungültige Aktion. Erlaubt: veroeffentlichen, archivieren, wiederherstellen." } })
    return
  end

  local svc = cfgSvc()
  local effCfg   = (svc and svc.GetEffectiveConfig()) or Config
  local formListe = (effCfg.Formulare and effCfg.Formulare.Liste) or {}

  if not formListe[formId] then
    TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle,
      { ok = false, fehler = { nachricht = ("Formular '%s' nicht gefunden."):format(formId) } })
    return
  end

  local altForm    = tiefKopie(formListe[formId])
  local override   = tiefKopie((svc and svc.GetOverrides("Formulare")) or {})
  if type(override.Liste) ~= "table" then override.Liste = {} end
  if type(override.Liste[formId]) ~= "table" then
    override.Liste[formId] = tiefKopie(formListe[formId])
  end

  local ZIEL_STATUS = {
    veroeffentlichen = "veroeffentlicht",
    archivieren      = "archiviert",
    wiederherstellen = "entwurf",
  }
  override.Liste[formId].status = ZIEL_STATUS[aktion]

  local saveOk, saveErr
  if svc then
    saveOk, saveErr = svc.SektionSpeichern("Formulare", override)
  else
    saveOk, saveErr = false, "AdminConfigService nicht verfügbar"
  end

  if not saveOk then
    TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle,
      { ok = false, fehler = { nachricht = tostring(saveErr) } })
    return
  end

  local aud = audSvc()
  if aud then
    aud.Log(
      "formular." .. aktion,
      spieler,
      payload.grund,
      "Formulare." .. formId,
      altForm,
      override.Liste[formId]
    )
  end

  local AKTIONS_NACHRICHT = {
    veroeffentlichen = "veröffentlicht",
    archivieren      = "archiviert",
    wiederherstellen = "als Entwurf wiederhergestellt",
  }

  TriggerClientEvent("hm_bp:admin:formular_status_antwort", quelle, {
    ok = true,
    nachricht = ("Formular '%s' erfolgreich %s."):format(
      tostring(formId), AKTIONS_NACHRICHT[aktion] or aktion
    )
  })
end)

-- ----------------------------------------------------------------
-- Feature-Flag (Modul) umschalten
-- Payload: { modul, aktiviert: true|false, grund }
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:modul_toggle", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle,
      { ok = false, fehler = { nachricht = grundErr } })
    return
  end

  local modul     = payload.modul
  local aktiviert = payload.aktiviert

  if type(modul) ~= "string" or modul == "" then
    TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'modul' ist Pflichtfeld." } })
    return
  end
  if type(aktiviert) ~= "boolean" then
    TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'aktiviert' muss ein boolescher Wert (true/false) sein." } })
    return
  end

  -- Sicherheitscheck: AdminUI darf nicht über das Admin-Panel selbst deaktiviert werden
  if modul == "AdminUI" and not aktiviert then
    TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle,
      { ok = false, fehler = { nachricht = "Das AdminUI-Modul kann nicht über das Admin-Panel deaktiviert werden." } })
    return
  end

  local svc    = cfgSvc()
  local override = tiefKopie((svc and svc.GetOverrides("Module")) or {})
  local altWert  = Config.Module and Config.Module[modul]

  override[modul] = aktiviert

  -- Validierung
  local vs = valSvc()
  if vs then
    local valOk, valErr = vs.ValidiereModule(override)
    if not valOk then
      TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle,
        { ok = false, fehler = { nachricht = valErr } })
      return
    end
  end

  local saveOk, saveErr
  if svc then
    saveOk, saveErr = svc.SektionSpeichern("Module", override)
  else
    saveOk, saveErr = false, "AdminConfigService nicht verfügbar"
  end

  if not saveOk then
    TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle,
      { ok = false, fehler = { nachricht = tostring(saveErr) } })
    return
  end

  local aud = audSvc()
  if aud then
    aud.Log(
      "modul.toggle",
      spieler,
      payload.grund,
      "Module." .. modul,
      { [modul] = altWert },
      { [modul] = aktiviert }
    )
  end

  TriggerClientEvent("hm_bp:admin:modul_toggle_antwort", quelle, {
    ok = true,
    nachricht = ("Modul '%s' wurde %s."):format(
      tostring(modul),
      aktiviert and "aktiviert" or "deaktiviert"
    )
  })
end)

-- ----------------------------------------------------------------
-- Webhook testen
-- Payload: { url, grund }
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:webhook_test", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:webhook_test_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local url = payload.url

  -- Validierung der URL
  local vs = valSvc()
  if vs then
    local valOk, valErr = vs.ValidiereWebhook(url)
    if not valOk then
      TriggerClientEvent("hm_bp:admin:webhook_test_antwort", quelle,
        { ok = false, fehler = { nachricht = valErr } })
      return
    end
  end

  local ws = HM_BP.Server.Dienste.WebhookService
  if not ws then
    TriggerClientEvent("hm_bp:admin:webhook_test_antwort", quelle,
      { ok = false, fehler = { nachricht = "WebhookService nicht verfügbar." } })
    return
  end

  -- Deutschen Embed-Test senden (via WebhookService.SendDirektTest)
  if ws.SendDirektTest then
    ws.SendDirektTest(url, spieler.name, function(statusCode, responseText)
      if Config and Config.Kern and Config.Kern.Debugmodus then
        print(("[AdminCRUD] Webhook-Test Antwort: HTTP %d"):format(tonumber(statusCode) or 0))
      end
    end)
  else
    -- Fallback: direkter HTTP-Call mit deutschem Embed
    local PerformHttpRequest = PerformHttpRequest
    if not PerformHttpRequest then
      TriggerClientEvent("hm_bp:admin:webhook_test_antwort", quelle,
        { ok = false, fehler = { nachricht = "HTTP-Funktionalität nicht verfügbar." } })
      return
    end
    local testPayload = {
      username = "HM Bürgerportal (Test)",
      embeds = {
        {
          title       = "🔔 Webhook-Test",
          description = ("Webhook-Test von Administrator **%s** – die Verbindung funktioniert."):format(
            tostring(spieler.name or "Admin")
          ),
          color  = 3427803,
          fields = {
            { name = "Spielername", value = tostring(spieler.name or "Admin"), inline = true },
          },
          footer = { text = "HM Bürgerportal Admin-Panel" },
        }
      }
    }
    local body = json.encode(testPayload)
    PerformHttpRequest(url, function(statusCode, responseText, responseHeaders)
      if Config and Config.Kern and Config.Kern.Debugmodus then
        print(("[AdminCRUD] Webhook-Test Antwort: HTTP %d"):format(tonumber(statusCode) or 0))
      end
    end, "POST", body, { ["Content-Type"] = "application/json" })
  end

  local aud = audSvc()
  if aud then
    aud.Log("webhook.test", spieler, ("Webhook-Test an: %s"):format(url), "Webhooks", nil, nil)
  end

  TriggerClientEvent("hm_bp:admin:webhook_test_antwort", quelle, {
    ok = true,
    nachricht = "Webhook-Testnachricht wurde gesendet. Bitte Discord-Kanal prüfen."
  })
end)

-- ----------------------------------------------------------------
-- Sektion validieren (erweitert mit AdminValidierungService)
-- Payload: { sektion, daten }
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:sektion_validieren_v2", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:sektion_validieren_v2_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local sektion = payload.sektion
  local daten   = payload.daten

  if type(sektion) ~= "string" or sektion == "" then
    TriggerClientEvent("hm_bp:admin:sektion_validieren_v2_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'sektion' ist Pflichtfeld." } })
    return
  end
  if type(daten) ~= "table" then
    TriggerClientEvent("hm_bp:admin:sektion_validieren_v2_antwort", quelle,
      { ok = false, fehler = { nachricht = "Feld 'daten' muss eine Tabelle sein." } })
    return
  end

  local vs = valSvc()
  if vs then
    local valOk, valErr = vs.ValidiereSektion(sektion, daten)
    if not valOk then
      TriggerClientEvent("hm_bp:admin:sektion_validieren_v2_antwort", quelle,
        { ok = false, fehler = { nachricht = valErr } })
      return
    end
  end

  TriggerClientEvent("hm_bp:admin:sektion_validieren_v2_antwort", quelle, {
    ok = true,
    nachricht = ("Sektion '%s' ist gültig."):format(tostring(sektion))
  })
end)
