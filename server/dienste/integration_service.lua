-- =============================================================
-- IntegrationService
-- PR5: Folgeaktionen/Integrationen Framework
-- =============================================================
-- Führt pro Formular konfigurierbare Aktionen aus, wenn ein Antrag
-- einen bestimmten terminalen/entscheidenden Status erreicht.
--
-- Feature-Flag: Config.Module.Integrationen (default = false)
-- Ist das Flag false oder Config.Integrationen.Aktiviert = false,
-- hat der Service keinen Effekt.
--
-- Unterstützte Aktionstypen (Whitelist):
--   emit_server_event  – TriggerEvent auf dem Server
--   call_export        – exports[resource][funktion](args, antrag)
--   set_db_flag        – setzt einen Key/Value-Eintrag in hm_bp_integration_flags
--   send_webhook_event – WebhookService.Emit(event, daten)
--
-- Sicherheit:
--   • Jeder Aktionstyp muss in ErlaubteAktionsTypen stehen (Whitelist)
--   • emit_server_event: Event muss in ErlaubteServerEvents stehen
--   • call_export: "resource:export" muss in ErlaubteExports stehen
--   • set_db_flag: Schlüssel muss in ErlaubteDBFlags stehen
--   • Jede Aktion wird mit pcall ausgeführt (Lua-Fehler abgefangen)
--   • Harte Begrenzung: MaxAktionenProQueue (default 20)
--   • Zeitlicher Guard: MaxGesamtZeitMs (default 4000 ms über alle Actions)
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local IntegrationService = {}

-- ---------------------------------------------------------------
-- Hilfsfunktionen
-- ---------------------------------------------------------------

local function cfg()
  return (Config and Config.Integrationen) or { Aktiviert = false }
end

local function istAktiv()
  if not (Config.Module and Config.Module.Integrationen) then return false end
  local c = cfg()
  return c.Aktiviert == true
end

local function hookFuerStatus(status)
  local c = cfg()
  local hooks = c.StatusHooks or {}
  return hooks[status]
end

local function typInWhitelist(typ)
  local c = cfg()
  local liste = c.ErlaubteAktionsTypen or {}
  for _, t in ipairs(liste) do
    if t == typ then return true end
  end
  return false
end

local function serverEventInWhitelist(event)
  local c = cfg()
  local liste = c.ErlaubteServerEvents or {}
  for _, e in ipairs(liste) do
    if e == event then return true end
  end
  return false
end

local function exportInWhitelist(resource, exportFn)
  local c = cfg()
  local liste = c.ErlaubteExports or {}
  local key = tostring(resource or "") .. ":" .. tostring(exportFn or "")
  for _, e in ipairs(liste) do
    if e == key then return true end
  end
  return false
end

local function dbFlagInWhitelist(schluessel)
  local c = cfg()
  local liste = c.ErlaubteDBFlags or {}
  for _, k in ipairs(liste) do
    if k == schluessel then return true end
  end
  return false
end

-- ---------------------------------------------------------------
-- Einzelne Aktion ausführen (mit pcall-Schutz)
-- Gibt zurück: ok (bool), fehlermeldung (string|nil)
-- ---------------------------------------------------------------

local function aktionAusfuehren(aktion, antrag)
  if type(aktion) ~= "table" then
    return false, "Aktion ist kein Table"
  end

  local typ = tostring(aktion.typ or "")
  if typ == "" then
    return false, "Aktionstyp fehlt"
  end

  if not typInWhitelist(typ) then
    return false, ("Aktionstyp nicht in Whitelist: %s"):format(typ)
  end

  -- ---- emit_server_event ----
  if typ == "emit_server_event" then
    local event = tostring(aktion.event or "")
    if event == "" then
      return false, "emit_server_event: event fehlt"
    end
    if not serverEventInWhitelist(event) then
      return false, ("Server-Event nicht in Whitelist: %s"):format(event)
    end
    local ok, err = pcall(function()
      TriggerEvent(event, aktion.daten or {}, {
        submission_id = antrag.id,
        public_id     = antrag.public_id,
        form_id       = antrag.form_id,
        category_id   = antrag.category_id,
      })
    end)
    if not ok then return false, tostring(err) end
    return true

  -- ---- call_export ----
  elseif typ == "call_export" then
    local resource = tostring(aktion.resource or "")
    local exportFn = tostring(aktion.export or "")
    if resource == "" or exportFn == "" then
      return false, "call_export: resource oder export fehlt"
    end
    if not exportInWhitelist(resource, exportFn) then
      return false, ("Export nicht in Whitelist: %s:%s"):format(resource, exportFn)
    end
    local ok, err = pcall(function()
      exports[resource][exportFn](aktion.args or {}, {
        submission_id = antrag.id,
        public_id     = antrag.public_id,
        form_id       = antrag.form_id,
        category_id   = antrag.category_id,
      })
    end)
    if not ok then return false, tostring(err) end
    return true

  -- ---- set_db_flag ----
  elseif typ == "set_db_flag" then
    local schluessel = tostring(aktion.schluessel or "")
    if schluessel == "" then
      return false, "set_db_flag: schluessel fehlt"
    end
    if not dbFlagInWhitelist(schluessel) then
      return false, ("DB-Flag-Schlüssel nicht in Whitelist: %s"):format(schluessel)
    end
    local wert = tostring(aktion.wert or "")
    local ok, err = pcall(function()
      HM_BP.Server.Datenbank.Ausfuehren([[
        INSERT INTO hm_bp_integration_flags (submission_id, schluessel, wert)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE wert = VALUES(wert), gesetzt_am = UTC_TIMESTAMP()
      ]], { antrag.id, schluessel, wert })
    end)
    if not ok then return false, tostring(err) end
    return true

  -- ---- send_webhook_event ----
  elseif typ == "send_webhook_event" then
    if not HM_BP.Server.Dienste.WebhookService then
      return false, "WebhookService nicht verfügbar"
    end
    local event = tostring(aktion.event or "")
    if event == "" then
      return false, "send_webhook_event: event fehlt"
    end
    local ok, err = pcall(function()
      HM_BP.Server.Dienste.WebhookService.Emit(event, aktion.daten or {})
    end)
    if not ok then return false, tostring(err) end
    return true
  end

  return false, ("Unbekannter Aktionstyp: %s"):format(typ)
end

-- ---------------------------------------------------------------
-- Öffentliche API
-- ---------------------------------------------------------------

--- Ermittelt die Aktionsliste für den gegebenen Status und führt sie aus.
--- Wird aus justiz_antrag_service.StatusAendern aufgerufen.
--- @param antrag  table  { id, public_id, form_id, category_id }
--- @param neuerStatus  string
--- @param spieler  table  { identifier, name }
function IntegrationService.AktionenAusfuehren(antrag, neuerStatus, spieler)
  if not istAktiv() then return end

  local hook = hookFuerStatus(neuerStatus)
  if not hook then return end

  -- Aktionsliste aus Formular-Config ermitteln
  local formAktionen = nil
  if Config.Formulare
    and Config.Formulare.Liste
    and Config.Formulare.Liste[antrag.form_id]
  then
    local form = Config.Formulare.Liste[antrag.form_id]
    if form.integrationen
      and type(form.integrationen[hook]) == "table"
    then
      formAktionen = form.integrationen[hook]
    end
  end

  if not formAktionen or #formAktionen == 0 then return end

  local c              = cfg()
  local maxAktionen    = tonumber(c.MaxAktionenProQueue) or 20
  local maxGesamtMs    = tonumber(c.MaxGesamtZeitMs)     or 4000
  local requestId      = HM_BP.Server.Dienste.AuditService
                          and HM_BP.Server.Dienste.AuditService.GenerateRequestId
                          and HM_BP.Server.Dienste.AuditService.GenerateRequestId()
                          or  tostring(math.random(100000, 999999))

  -- Audit: Aktionen geplant
  if HM_BP.Server.Dienste.AuditService then
    HM_BP.Server.Dienste.AuditService.Log(
      "integration.geplant", spieler, "submission", tostring(antrag.id),
      {
        hook            = hook,
        anzahl_aktionen = math.min(#formAktionen, maxAktionen),
        form_id         = antrag.form_id,
        request_id      = requestId,
      }
    )
  end

  local startMs = GetGameTimer()

  for i, aktion in ipairs(formAktionen) do
    -- Harte Aktions-Grenze
    if i > maxAktionen then
      print(("[hm_buergerportal] WARN [Integration] Aktions-Limit (%d) erreicht – "
        .. "weitere Aktionen abgebrochen. Antrag=%s Hook=%s"):format(
          maxAktionen, tostring(antrag.public_id), tostring(hook)))
      break
    end

    -- Zeitlicher Guard
    local vergangeneMs = GetGameTimer() - startMs
    if vergangeneMs > maxGesamtMs then
      print(("[hm_buergerportal] WARN [Integration] Gesamt-Zeitlimit (%dms) überschritten – "
        .. "weitere Aktionen abgebrochen. Antrag=%s Hook=%s"):format(
          maxGesamtMs, tostring(antrag.public_id), tostring(hook)))
      break
    end

    local ok, fehler = aktionAusfuehren(aktion, antrag)

    if ok then
      -- Audit: Aktion erfolgreich
      if HM_BP.Server.Dienste.AuditService then
        HM_BP.Server.Dienste.AuditService.Log(
          "integration.erfolgreich", spieler, "submission", tostring(antrag.id),
          {
            hook          = hook,
            aktion_index  = i,
            typ           = aktion.typ,
            form_id       = antrag.form_id,
            request_id    = requestId,
          }
        )
      end
    else
      -- Server-Konsole: Fehler
      print(("[hm_buergerportal] ERR [Integration] Aktion fehlgeschlagen – "
        .. "Antrag=%s Hook=%s Index=%d Typ=%s Fehler=%s"):format(
          tostring(antrag.public_id), tostring(hook), i,
          tostring(aktion.typ), tostring(fehler)))

      -- Audit: Aktion fehlgeschlagen
      if HM_BP.Server.Dienste.AuditService then
        HM_BP.Server.Dienste.AuditService.Log(
          "integration.fehlgeschlagen", spieler, "submission", tostring(antrag.id),
          {
            hook          = hook,
            aktion_index  = i,
            typ           = aktion.typ,
            fehler        = fehler,
            form_id       = antrag.form_id,
            request_id    = requestId,
          }
        )
      end

      -- Webhook: integration_failed (kein Identifier an Discord)
      if HM_BP.Server.Dienste.WebhookService then
        pcall(function()
          HM_BP.Server.Dienste.WebhookService.Emit("integration_failed", {
            public_id    = antrag.public_id,
            aktenzeichen = antrag.public_id,
            akteur_name  = spieler and spieler.name or "System",
            form_id      = antrag.form_id,
            category_id  = antrag.category_id,
            hook         = hook,
            aktion_typ   = aktion.typ,
            fehler       = fehler,
          })
        end)
      end
    end
  end
end

HM_BP.Server.Dienste.IntegrationService = IntegrationService
