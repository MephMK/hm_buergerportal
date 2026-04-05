HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ==========================================
-- Formular-Editor API (Entwurf/Veröffentlicht)
-- ==========================================
-- Dieses File stellt Server-Events bereit, die von der NUI (app.js) genutzt werden.
--
-- Erwartete NUI-Routen (client -> server bridge):
--  - hm_bp:form_editor_rechte_laden
--  - hm_bp:form_editor_liste_laden
--  - hm_bp:form_editor_formular_erstellen
--  - hm_bp:form_editor_schema_holen
--  - hm_bp:form_editor_schema_speichern
--  - hm_bp:form_editor_veroeffentlichen
--  - hm_bp:form_editor_archivieren
--
-- Hinweis:
--  - Rechte kommen aus Config.FormularEditor
--  - Admin kann optional immer alles (Config.FormularEditor.AdminHatImmerZugriff)
--
-- DB-Tabellen:
--  - hm_bp_forms
--  - hm_bp_form_versions
--
-- Status:
--  - draft
--  - published
--  - archived

HM_BP.Server.FormEditorApi = HM_BP.Server.FormEditorApi or {}

local function istBlank(s)
  return s == nil or tostring(s):gsub("%s+", "") == ""
end

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function sichereStringId(id)
  id = trim(id)
  if id == "" then return nil end
  -- Erlaubt: a-zA-Z0-9_-
  if not id:match("^[a-zA-Z0-9_%-%_]+$") then return nil end
  if #id < 3 then return nil end
  if #id > 64 then return nil end
  return id
end

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function istAdmin(spieler)
  return HM_BP.Server.Dienste.AuthService.IstAdmin(spieler)
end

local function rolleErmitteln(spieler)
  return HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
end

local function configRechte()
  return (Config and Config.FormularEditor) or { Aktiviert = false }
end

local function kategorieCfg(kategorieId)
  local c = configRechte()
  if not (c and c.Kategorien and c.Kategorien[kategorieId]) then return nil end
  return c.Kategorien[kategorieId]
end

local function spielerErfuelltRegel(spieler, regel)
  if not regel then return false end

  -- Rolle (buerger/justiz/admin) optional
  if regel.rolle and rolleErmitteln(spieler) ~= regel.rolle then
    return false
  end

  -- Job optional
  if regel.job and spieler.job and spieler.job.name and spieler.job.name ~= regel.job then
    return false
  end

  -- Mindestgrad optional
  if regel.mindestGrad ~= nil then
    local g = spieler.job and spieler.job.grade or 0
    if tonumber(g) < tonumber(regel.mindestGrad) then
      return false
    end
  end

  return true
end

local function rechteFuerKategorie(spieler, kategorieId)
  local c = configRechte()
  if not (c and c.Aktiviert == true) then
    return { create = false, edit = false, publish = false, archive = false }
  end

  if istAdmin(spieler) and c.AdminHatImmerZugriff == true then
    return { create = true, edit = true, publish = true, archive = true }
  end

  local kc = kategorieCfg(kategorieId)
  if not kc then
    return { create = false, edit = false, publish = false, archive = false }
  end

  local canEdit = spielerErfuelltRegel(spieler, kc.editor)
  local canPublish = spielerErfuelltRegel(spieler, kc.publisher)
  local canArchive = spielerErfuelltRegel(spieler, kc.archivierer)

  -- create folgt editor
  return {
    create = canEdit,
    edit = canEdit,
    publish = canPublish,
    archive = canArchive
  }
end

local function pruefeRechte(spieler, kategorieId, aktion)
  local r = rechteFuerKategorie(spieler, kategorieId)
  if aktion == "create" and r.create then return true, r end
  if aktion == "edit" and r.edit then return true, r end
  if aktion == "publish" and r.publish then return true, r end
  if aktion == "archive" and r.archive then return true, r end
  return false, r
end

local function formRowHolen(formId)
  return HM_BP.Server.Datenbank.Einzel([[
    SELECT id, category_id, active, data, created_at, updated_at
    FROM hm_bp_forms
    WHERE id = ?
  ]], { formId })
end

local function formDataDecode(row)
  if not row or row.data == nil then return {} end
  if type(row.data) == "table" then return row.data end
  local ok, decoded = pcall(function()
    return json.decode(row.data)
  end)
  if ok and type(decoded) == "table" then return decoded end
  return {}
end

local function schemaDecode(row)
  if not row or row.schema_json == nil then return nil end
  if type(row.schema_json) == "table" then return row.schema_json end
  local ok, decoded = pcall(function()
    return json.decode(row.schema_json)
  end)
  if ok and type(decoded) == "table" then return decoded end
  return nil
end

local function aktuellsteVersionHolen(formId)
  local v = HM_BP.Server.Datenbank.Einzel([[
    SELECT form_id, version, schema_json, created_by_identifier, created_at
    FROM hm_bp_form_versions
    WHERE form_id = ?
    ORDER BY version DESC
    LIMIT 1
  ]], { formId })
  return v
end

local function publishedVersionNr(formData)
  -- wir speichern in hm_bp_forms.data: published_version
  local pv = formData and formData.published_version or nil
  pv = tonumber(pv)
  return pv
end

local function formStatus(formData)
  local st = tostring(formData and formData.status or "draft")
  if st ~= "draft" and st ~= "published" and st ~= "archived" then st = "draft" end
  return st
end

local function schemaNormierenEinfacheValidierung(schema, formId, kategorieId)
  if type(schema) ~= "table" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Schema ist ungültig." }
  end

  schema.formular = schema.formular or {}
  schema.felder = schema.felder or {}

  if type(schema.felder) ~= "table" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Felderliste ist ungültig." }
  end

  -- Formular-Metadaten erzwingen (StringID + Kategorie)
  schema.formular.id = formId
  schema.formular.kategorieId = kategorieId
  schema.formular.version = tonumber(schema.formular.version or 1) or 1
  schema.formular.titel = tostring(schema.formular.titel or "Formular")
  schema.formular.beschreibung = tostring(schema.formular.beschreibung or "")

  -- Feld-Minimalvalidierung
  local keys = {}
  for i, f in ipairs(schema.felder) do
    if type(f) ~= "table" then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = ("Feld #%d ist ungültig."):format(i) }
    end

    local key = trim(f.key)
    if key == "" then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = ("Feld #%d: Key fehlt."):format(i) }
    end
    if not key:match("^[a-zA-Z0-9_%-%_]+$") then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = ("Feld '%s': Key enthält ungültige Zeichen."):format(key) }
    end
    if keys[key] then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = ("Feld-Key doppelt: %s"):format(key) }
    end
    keys[key] = true

    f.key = key
    f.id = tostring(f.id or key)
    f.label = tostring(f.label or key)
    f.typ = tostring(f.typ or "shorttext")
    f.pflicht = (f.pflicht == true)
    f.reihenfolge = tonumber(f.reihenfolge or i) or i

    -- Sichtbarkeit Default
    f.sichtbarkeit = f.sichtbarkeit or { buerger = true, justiz = true, nurIntern = false }
    if type(f.sichtbarkeit) ~= "table" then
      f.sichtbarkeit = { buerger = true, justiz = true, nurIntern = false }
    end
    if f.sichtbarkeit.buerger == nil then f.sichtbarkeit.buerger = true end
    if f.sichtbarkeit.justiz == nil then f.sichtbarkeit.justiz = true end
    if f.sichtbarkeit.nurIntern == nil then f.sichtbarkeit.nurIntern = false end
  end

  table.sort(schema.felder, function(a, b)
    return (a.reihenfolge or 999) < (b.reihenfolge or 999)
  end)

  return schema, nil
end

-- ==========================
-- Event: Rechte anfordern
-- ==========================
RegisterNetEvent("hm_bp:form_editor:rechte_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:rechte_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local c = configRechte()
  if not (c and c.Aktiviert == true) then
    TriggerClientEvent("hm_bp:form_editor:rechte_antwort", quelle, { ok = true, rechte = {} })
    return
  end

  local rechte = {}
  if Config.Kategorien and Config.Kategorien.Liste then
    for kategorieId, _ in pairs(Config.Kategorien.Liste) do
      local r = rechteFuerKategorie(spieler, kategorieId)
      if r.create or r.edit or r.publish or r.archive then
        rechte[kategorieId] = r
      end
    end
  end

  TriggerClientEvent("hm_bp:form_editor:rechte_antwort", quelle, { ok = true, rechte = rechte })
end)

-- ==========================
-- Event: Formular-Liste (DB) für Kategorie
-- ==========================
RegisterNetEvent("hm_bp:form_editor:liste_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local kategorieId = payload.kategorieId
  if istBlank(kategorieId) then
    TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = false, fehler = { nachricht = "Kategorie-ID fehlt." } })
    return
  end

  local okR = false
  okR = (rechteFuerKategorie(spieler, kategorieId).edit == true)
    or (rechteFuerKategorie(spieler, kategorieId).create == true)
    or (rechteFuerKategorie(spieler, kategorieId).publish == true)
    or (rechteFuerKategorie(spieler, kategorieId).archive == true)

  if not okR then
    TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Rechte für Formular-Editor in dieser Kategorie." } })
    return
  end

  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, category_id, active, data, created_at, updated_at
    FROM hm_bp_forms
    WHERE category_id = ?
    ORDER BY updated_at DESC
    LIMIT 500
  ]], { kategorieId }) or {}

  local liste = {}
  for _, r in ipairs(rows) do
    local data = formDataDecode(r)
    local st = formStatus(data)
    table.insert(liste, {
      id = r.id,
      category_id = r.category_id,
      active = (tonumber(r.active or 1) == 1),
      status = st,
      title = data.title or data.titel or r.id,
      description = data.description or data.beschreibung or "",
      published_version = publishedVersionNr(data)
    })
  end

  TriggerClientEvent("hm_bp:form_editor:liste_antwort", quelle, { ok = true, liste = liste })
end)

-- ==========================
-- Event: Formular erstellen (Entwurf)
-- ==========================
RegisterNetEvent("hm_bp:form_editor:formular_erstellen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local id = sichereStringId(payload.id)
  local kategorieId = payload.kategorieId
  local titel = trim(payload.titel)
  local beschreibung = trim(payload.beschreibung)

  if not id then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Formular-ID ist ungültig. Erlaubt: a-zA-Z0-9_- (3-64 Zeichen)." } })
    return
  end
  if istBlank(kategorieId) then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Kategorie-ID fehlt." } })
    return
  end
  if istBlank(titel) then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Titel fehlt." } })
    return
  end

  local okR = pruefeRechte(spieler, kategorieId, "create")
  if not okR then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Berechtigung zum Erstellen." } })
    return
  end

  -- Kategorie existiert?
  if not (Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]) then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Kategorie existiert nicht." } })
    return
  end

  -- Schon vorhanden?
  local existing = formRowHolen(id)
  if existing then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Diese Formular-ID existiert bereits." } })
    return
  end

  local formData = {
    title = titel,
    description = beschreibung,
    status = "draft",
    published_version = nil,
    created_by_identifier = spieler.identifier,
    created_by_name = spieler.name,
    created_at_utc = utcJetztIso(),
  }

  local ins = HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_forms (id, category_id, active, data)
    VALUES (?, ?, 1, ?)
  ]], { id, kategorieId, json.encode(formData) })

  if not ins or ins < 1 then
    TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = false, fehler = { nachricht = "Formular konnte nicht gespeichert werden." } })
    return
  end

  -- Startschema als Version 1
  local schema = {
    formular = {
      id = id,
      titel = titel,
      beschreibung = beschreibung,
      kategorieId = kategorieId,
      version = 1
    },
    felder = {}
  }

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_form_versions (form_id, version, schema_json, created_by_identifier)
    VALUES (?, 1, ?, ?)
  ]], { id, json.encode(schema), spieler.identifier })

  -- Audit
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    "form_editor.form_created",
    spieler.identifier, spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    id,
    json.encode({ category_id = kategorieId })
  })

  TriggerClientEvent("hm_bp:form_editor:formular_erstellen_antwort", quelle, { ok = true, res = { id = id, version = 1 } })
end)

-- ==========================
-- Event: Schema holen (draft/published)
-- ==========================
RegisterNetEvent("hm_bp:form_editor:schema_holen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local formId = sichereStringId(payload.formId)
  local modus = tostring(payload.modus or "draft")

  if not formId then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = { nachricht = "Formular-ID fehlt/ungültig." } })
    return
  end

  local row = formRowHolen(formId)
  if not row then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = { nachricht = "Formular nicht gefunden." } })
    return
  end

  local data = formDataDecode(row)
  local kategorieId = row.category_id

  local okR = (rechteFuerKategorie(spieler, kategorieId).edit == true)
    or (rechteFuerKategorie(spieler, kategorieId).publish == true)
    or (rechteFuerKategorie(spieler, kategorieId).archive == true)

  if not okR then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Berechtigung." } })
    return
  end

  local schemaRow = nil

  if modus == "published" then
    local pv = publishedVersionNr(data)
    if not pv then
      TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = { nachricht = "Dieses Formular ist noch nicht veröffentlicht." } })
      return
    end

    schemaRow = HM_BP.Server.Datenbank.Einzel([[
      SELECT form_id, version, schema_json, created_by_identifier, created_at
      FROM hm_bp_form_versions
      WHERE form_id = ? AND version = ?
      LIMIT 1
    ]], { formId, pv })
  else
    schemaRow = aktuellsteVersionHolen(formId)
  end

  if not schemaRow then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = { nachricht = "Schema nicht gefunden." } })
    return
  end

  local schema = schemaDecode(schemaRow)
  if not schema then
    TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = false, fehler = { nachricht = "Schema ist beschädigt (JSON)." } })
    return
  end

  TriggerClientEvent("hm_bp:form_editor:schema_holen_antwort", quelle, { ok = true, schema = schema })
end)

-- ==========================
-- Event: Schema speichern -> neue Version
-- ==========================
RegisterNetEvent("hm_bp:form_editor:schema_speichern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local formId = sichereStringId(payload.formId)
  local schema = payload.schema

  if not formId then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = { nachricht = "Formular-ID fehlt/ungültig." } })
    return
  end
  if type(schema) ~= "table" then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = { nachricht = "Schema fehlt." } })
    return
  end

  local row = formRowHolen(formId)
  if not row then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = { nachricht = "Formular nicht gefunden." } })
    return
  end

  local kategorieId = row.category_id
  local okR = pruefeRechte(spieler, kategorieId, "edit")
  if not okR then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Berechtigung zum Bearbeiten." } })
    return
  end

  local normSchema, errSchema = schemaNormierenEinfacheValidierung(schema, formId, kategorieId)
  if not normSchema then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = errSchema })
    return
  end

  local last = aktuellsteVersionHolen(formId)
  local nextVersion = (last and tonumber(last.version) or 0) + 1
  normSchema.formular.version = nextVersion

  local okIns = HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_form_versions (form_id, version, schema_json, created_by_identifier)
    VALUES (?, ?, ?, ?)
  ]], { formId, nextVersion, json.encode(normSchema), spieler.identifier })

  if not okIns or okIns < 1 then
    TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = false, fehler = { nachricht = "Version konnte nicht gespeichert werden." } })
    return
  end

  -- Form-Metadaten (titel/beschreibung) aktualisieren
  local data = formDataDecode(row)
  data.title = normSchema.formular.titel
  data.description = normSchema.formular.beschreibung
  if not data.status then data.status = "draft" end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_forms
    SET data = ?, updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  ]], { json.encode(data), formId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    "form_editor.schema_saved",
    spieler.identifier, spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ version = nextVersion })
  })

  TriggerClientEvent("hm_bp:form_editor:schema_speichern_antwort", quelle, { ok = true, res = { version = nextVersion } })
end)

-- ==========================
-- Event: Veröffentlichen
-- ==========================
RegisterNetEvent("hm_bp:form_editor:veroeffentlichen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local formId = sichereStringId(payload.formId)
  if not formId then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = { nachricht = "Formular-ID fehlt/ungültig." } })
    return
  end

  local row = formRowHolen(formId)
  if not row then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = { nachricht = "Formular nicht gefunden." } })
    return
  end

  local kategorieId = row.category_id
  local okR = pruefeRechte(spieler, kategorieId, "publish")
  if not okR then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Berechtigung zum Veröffentlichen." } })
    return
  end

  local last = aktuellsteVersionHolen(formId)
  if not last then
    TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Version vorhanden." } })
    return
  end

  local data = formDataDecode(row)
  data.published_version = tonumber(last.version)
  data.status = "published"
  data.published_by_identifier = spieler.identifier
  data.published_by_name = spieler.name
  data.published_at_utc = utcJetztIso()

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_forms
    SET data = ?, updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  ]], { json.encode(data), formId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    "form_editor.published",
    spieler.identifier, spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ version = tonumber(last.version) })
  })

  TriggerClientEvent("hm_bp:form_editor:veroeffentlichen_antwort", quelle, { ok = true, res = { version = tonumber(last.version) } })
end)

-- ==========================
-- Event: Archivieren
-- ==========================
RegisterNetEvent("hm_bp:form_editor:archivieren", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local formId = sichereStringId(payload.formId)
  if not formId then
    TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = false, fehler = { nachricht = "Formular-ID fehlt/ungültig." } })
    return
  end

  local row = formRowHolen(formId)
  if not row then
    TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = false, fehler = { nachricht = "Formular nicht gefunden." } })
    return
  end

  local kategorieId = row.category_id
  local okR = pruefeRechte(spieler, kategorieId, "archive")
  if not okR then
    TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = false, fehler = { nachricht = "Keine Berechtigung zum Archivieren." } })
    return
  end

  local data = formDataDecode(row)
  data.status = "archived"
  data.archived_by_identifier = spieler.identifier
  data.archived_by_name = spieler.name
  data.archived_at_utc = utcJetztIso()

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_forms
    SET active = 0, data = ?, updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  ]], { json.encode(data), formId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    "form_editor.archived",
    spieler.identifier, spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ status = "archived" })
  })

  TriggerClientEvent("hm_bp:form_editor:archivieren_antwort", quelle, { ok = true })
end)