HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ==========================================
-- Formular-Editor API
-- ==========================================
-- Delegiert alle Logik an FormularEditorService.
-- Nutzt ausschließlich die neuen Tabellen:
--   hm_bp_form_editor_forms, hm_bp_form_editor_versions, hm_bp_form_editor_permissions
--
-- NUI-Routen (via client/ui_bruecke.lua):
--   hm_bp:form_editor_rechte_laden
--   hm_bp:form_editor_liste_laden
--   hm_bp:form_editor_formular_erstellen
--   hm_bp:form_editor_schema_holen
--   hm_bp:form_editor_schema_speichern
--   hm_bp:form_editor_veroeffentlichen
--   hm_bp:form_editor_archivieren
--
-- Server-Events (intern, von ui_bruecke ausgelöst):
--   hm_bp:form_editor:rechte_anfordern
--   hm_bp:form_editor:liste_anfordern
--   hm_bp:form_editor:formular_erstellen
--   hm_bp:form_editor:schema_holen
--   hm_bp:form_editor:schema_speichern
--   hm_bp:form_editor:veroeffentlichen
--   hm_bp:form_editor:archivieren
-- ==========================================

local function svc()
  return HM_BP.Server.Dienste.FormularEditorService
end

local function webhookEmit(eventKey, data)
  local ws = HM_BP.Server.Dienste.WebhookService
  if ws and ws.Emit then ws.Emit(eventKey, data) end
end

-- ==========================
-- Rechte laden
-- ==========================
RegisterNetEvent("hm_bp:form_editor:rechte_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:rechte_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local c = Config and Config.FormularEditor
  if not (c and c.Aktiviert == true) then
    TriggerClientEvent("hm_bp:form_editor:rechte_antwort", quelle, { ok = true, rechte = {} })
    return
  end

  local rechte = {}
  if Config.Kategorien and Config.Kategorien.Liste then
    for kategorieId, _ in pairs(Config.Kategorien.Liste) do
      local r = svc().RechteFuerKategorie(kategorieId, spieler)
      if r.create or r.edit or r.publish or r.archive then
        rechte[kategorieId] = r
      end
    end
  end

  TriggerClientEvent("hm_bp:form_editor:rechte_antwort", quelle, { ok = true, rechte = rechte })
end)

-- ==========================
-- Formular-Liste (DB)
-- ==========================
RegisterNetEvent("hm_bp:form_editor:liste_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local liste, fehler = svc().FormularListe(payload.kategorieId, spieler)
  if not liste then
    TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = false, fehler = fehler })
    return
  end

  TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = true, liste = liste })
end)

-- ==========================
-- Formular erstellen (Entwurf)
-- ==========================
RegisterNetEvent("hm_bp:form_editor:formular_erstellen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local result, fehler = svc().FormularErstellen(spieler, {
    id          = payload.id,
    kategorieId = payload.kategorieId,
    titel       = payload.titel,
    beschreibung = payload.beschreibung,
  })
  if not result then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = fehler })
    return
  end

  webhookEmit("form_editor_form_created", {
    form_id     = result.id,
    category_id = result.category_id,
    actor_name  = spieler.name,
  })

  TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, {
    ok = true,
    res = { id = result.id, version = 1 }
  })
end)

-- ==========================
-- Schema holen (draft / published)
-- ==========================
RegisterNetEvent("hm_bp:form_editor:schema_holen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local schema, fehler = svc().SchemaHolen(spieler, payload.formId, payload.modus)
  if not schema then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = fehler })
    return
  end

  TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = true, schema = schema })
end)

-- ==========================
-- Schema speichern (neue Version)
-- ==========================
RegisterNetEvent("hm_bp:form_editor:schema_speichern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local result, fehler = svc().SchemaSpeichern(spieler, payload.formId, payload.schema)
  if not result then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = fehler })
    return
  end

  webhookEmit("form_editor_schema_saved", {
    form_id    = payload.formId,
    version    = result.version,
    actor_name = spieler.name,
  })

  TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, {
    ok = true,
    res = { version = result.version }
  })
end)

-- ==========================
-- Veröffentlichen
-- ==========================
RegisterNetEvent("hm_bp:form_editor:veroeffentlichen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local result, fehler = svc().Veroeffentlichen(spieler, payload.formId)
  if not result then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = fehler })
    return
  end

  webhookEmit("form_editor_published", {
    form_id    = payload.formId,
    version    = result.version,
    actor_name = spieler.name,
  })

  TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, {
    ok = true,
    res = { version = result.version }
  })
end)

-- ==========================
-- Archivieren
-- ==========================
RegisterNetEvent("hm_bp:form_editor:archivieren", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.FORM_EDITOR_USE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local result, fehler = svc().Archivieren(spieler, payload.formId)
  if not result then
    TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = false, fehler = fehler })
    return
  end

  webhookEmit("form_editor_archived", {
    form_id    = payload.formId,
    actor_name = spieler.name,
  })

  TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = true })
end)
