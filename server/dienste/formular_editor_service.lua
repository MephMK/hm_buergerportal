HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local FormularEditorService = {}

local function istLeer(s)
  return s == nil or tostring(s):gsub("%s+", "") == ""
end

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function configAktiv()
  return Config
    and Config.FormularEditor
    and Config.FormularEditor.Aktiviert == true
end

local function rolleErmitteln(spieler)
  return HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
end

local function adminHatImmerZugriff()
  if not configAktiv() then return false end
  if Config.FormularEditor.AdminHatImmerZugriff == nil then return true end
  return Config.FormularEditor.AdminHatImmerZugriff == true
end

local function erlaubteKategorieRegeln(kategorieId)
  if not configAktiv() then return nil end
  local k = Config.FormularEditor.Kategorien
  if type(k) ~= "table" then return nil end
  return k[kategorieId]
end

local function gradeInRange(grad, minG, maxG)
  grad = tonumber(grad or 0) or 0
  if minG ~= nil and grad < tonumber(minG) then return false end
  if maxG ~= nil and grad > tonumber(maxG) then return false end
  return true
end

local function permissionMatch(spieler, row)
  if not row then return false end

  local rolle = rolleErmitteln(spieler)
  if tostring(row.role) ~= tostring(rolle) then return false end

  if row.job ~= nil and tostring(row.job) ~= "" then
    if not spieler.job or tostring(spieler.job.name) ~= tostring(row.job) then
      return false
    end
  end

  local grad = spieler.job and spieler.job.grade or 0
  if not gradeInRange(grad, row.min_grade, row.max_grade) then
    return false
  end

  return true
end

local function rechteAusDB(kategorieId, spieler)
  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT role, job, min_grade, max_grade, can_create, can_edit, can_publish, can_archive
    FROM hm_bp_form_editor_permissions
    WHERE category_id = ?
  ]], { kategorieId }) or {}

  local res = { create = false, edit = false, publish = false, archive = false }

  for _, r in ipairs(rows) do
    if permissionMatch(spieler, r) then
      if tonumber(r.can_create or 0) == 1 then res.create = true end
      if tonumber(r.can_edit or 0) == 1 then res.edit = true end
      if tonumber(r.can_publish or 0) == 1 then res.publish = true end
      if tonumber(r.can_archive or 0) == 1 then res.archive = true end
    end
  end

  return res
end

local function rechteAusConfig(kategorieId, spieler)
  local rolle = rolleErmitteln(spieler)

  -- Admin override
  if rolle == "admin" and adminHatImmerZugriff() then
    return { create = true, edit = true, publish = true, archive = true }
  end

  local regeln = erlaubteKategorieRegeln(kategorieId)
  if not regeln then
    return { create = false, edit = false, publish = false, archive = false }
  end

  local function pruefeBlock(block)
    if type(block) ~= "table" then return false end
    if block.rolle and tostring(block.rolle) ~= tostring(rolle) then
      return false
    end
    if block.job and tostring(block.job) ~= "" then
      if not spieler.job or tostring(spieler.job.name) ~= tostring(block.job) then
        return false
      end
    end
    local grad = spieler.job and spieler.job.grade or 0
    if type(block.erlaubteGrade) == "table" and #block.erlaubteGrade > 0 then
      local ok = false
      for _, g in ipairs(block.erlaubteGrade) do
        if tonumber(g) == tonumber(grad) then ok = true break end
      end
      if not ok then return false end
    end
    if block.mindestGrad ~= nil and tonumber(grad) < tonumber(block.mindestGrad) then
      return false
    end
    if block.maxGrad ~= nil and tonumber(grad) > tonumber(block.maxGrad) then
      return false
    end
    return true
  end

  local out = { create = false, edit = false, publish = false, archive = false }

  if pruefeBlock(regeln.editor) then
    out.create = true
    out.edit = true
  end
  if pruefeBlock(regeln.publisher) then
    out.publish = true
  end
  if pruefeBlock(regeln.archivierer) then
    out.archive = true
  end

  return out
end

function FormularEditorService.RechteFuerKategorie(kategorieId, spieler)
  if not configAktiv() then
    return { create = false, edit = false, publish = false, archive = false }
  end

  -- Admin immer alles
  local rolle = rolleErmitteln(spieler)
  if rolle == "admin" and adminHatImmerZugriff() then
    return { create = true, edit = true, publish = true, archive = true }
  end

  -- Erst DB, dann Config OR (vereinigt)
  local a = rechteAusDB(kategorieId, spieler)
  local b = rechteAusConfig(kategorieId, spieler)

  return {
    create = (a.create or b.create) == true,
    edit = (a.edit or b.edit) == true,
    publish = (a.publish or b.publish) == true,
    archive = (a.archive or b.archive) == true
  }
end

local function assertRecht(kategorieId, spieler, neededKey)
  local r = FormularEditorService.RechteFuerKategorie(kategorieId, spieler)
  if neededKey == "create" and r.create ~= true then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung: Formular erstellen." }
  end
  if neededKey == "edit" and r.edit ~= true then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung: Formular bearbeiten." }
  end
  if neededKey == "publish" and r.publish ~= true then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung: Formular veröffentlichen." }
  end
  if neededKey == "archive" and r.archive ~= true then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung: Formular archivieren." }
  end
  return true, nil
end

local function nextVersion(formId)
  local v = HM_BP.Server.Datenbank.Skalar("SELECT MAX(version) FROM hm_bp_form_editor_versions WHERE form_id = ?", { formId })
  v = tonumber(v or 0) or 0
  return v + 1
end

local function formExists(formId)
  local row = HM_BP.Server.Datenbank.Einzel("SELECT id FROM hm_bp_form_editor_forms WHERE id = ?", { formId })
  return row ~= nil
end

local function loadFormRow(formId)
  return HM_BP.Server.Datenbank.Einzel([[
    SELECT id, category_id, status, active, title, description, published_version, published_at, created_at, updated_at
    FROM hm_bp_form_editor_forms
    WHERE id = ?
  ]], { formId })
end

local function loadLatestSchema(formId)
  local row = HM_BP.Server.Datenbank.Einzel([[
    SELECT version, schema_json
    FROM hm_bp_form_editor_versions
    WHERE form_id = ?
    ORDER BY version DESC
    LIMIT 1
  ]], { formId })
  return row
end

local function loadPublishedSchema(formId)
  local row = HM_BP.Server.Datenbank.Einzel([[
    SELECT v.version, v.schema_json
    FROM hm_bp_form_editor_forms f
    JOIN hm_bp_form_editor_versions v
      ON v.form_id = f.id AND v.version = f.published_version
    WHERE f.id = ?
      AND f.status = 'published'
      AND f.active = 1
    LIMIT 1
  ]], { formId })
  return row
end

local function validateSchema(schema)
  if type(schema) ~= "table" then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Schema ist ungültig." }
  end
  if type(schema.formular) ~= "table" then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Schema.formular fehlt." }
  end
  if type(schema.felder) ~= "table" then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Schema.felder fehlt." }
  end

  local FT = HM_BP.Shared.FieldTypes

  -- Checks: keys unique, key not empty, valid field type
  local keys = {}
  for _, f in ipairs(schema.felder) do
    local key = f and f.key or nil
    if istLeer(key) then
      return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ein Feld hat keinen key." }
    end
    key = tostring(key)
    if keys[key] then
      return false, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = ("Doppelter Feld-key: %s"):format(key) }
    end
    keys[key] = true

    -- Feldtyp prüfen (unbekannte Typen werden gewarnt, nicht blockiert, für Backwards-Kompatibilität)
    if FT and f.typ then
      if not FT.Bekannt(f.typ) then
        -- Warnung im Server-Log; kein harter Fehler für Backwards-Compat
        if Config and Config.Kern and Config.Kern.Debugmodus then
          print(("[hm_buergerportal] WARNUNG: Feld '%s' hat unbekannten Typ '%s'. Wird als text_short behandelt."):format(key, tostring(f.typ)))
        end
      end
    end

    -- select/multiselect/radio müssen Optionen haben (bei Veröffentlichung streng prüfen)
    if FT and f.typ then
      local meta = FT.Meta(f.typ)
      if meta and meta.hatOptionen and meta.isInput then
        if type(f.optionen) ~= "table" or #f.optionen == 0 then
          -- Nur Warnung im Entwurf – beim Veröffentlichen wird diese Prüfung als Fehler behandelt
          -- (siehe validateSchemaFuerVeroeffentlichung weiter unten)
        end
      end
    end
  end

  return true, nil
end

-- Strenge Schema-Validierung vor dem Veröffentlichen
local function validateSchemaFuerVeroeffentlichung(schema)
  local ok, err = validateSchema(schema)
  if not ok then return false, err end

  local FT = HM_BP.Shared.FieldTypes

  for _, f in ipairs(schema.felder) do
    if FT and f.typ then
      local meta = FT.Meta(f.typ)
      if meta and meta.hatOptionen and meta.isInput then
        if type(f.optionen) ~= "table" or #f.optionen == 0 then
          return false, {
            code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
            nachricht = ("Feld '%s' (%s) benötigt mindestens eine Option."):format(tostring(f.key), tostring(f.typ))
          }
        end
      end
    end
  end

  return true, nil
end

function FormularEditorService.FormularListe(kategorieId, spieler)
  if istLeer(kategorieId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Kategorie-ID fehlt." }
  end

  local okR, errR = assertRecht(kategorieId, spieler, "edit")
  if not okR then return nil, errR end

  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, category_id, status, active, title, description, published_version, published_at, created_at, updated_at
    FROM hm_bp_form_editor_forms
    WHERE category_id = ?
    ORDER BY updated_at DESC
    LIMIT 200
  ]], { kategorieId }) or {}

  return rows, nil
end

function FormularEditorService.FormularErstellen(spieler, daten)
  daten = daten or {}
  local formId = trim(daten.id)
  local kategorieId = trim(daten.kategorieId)
  local titel = trim(daten.titel)
  local beschreibung = trim(daten.beschreibung)

  if istLeer(formId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID fehlt." }
  end
  if #formId > 64 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID ist zu lang (max 64)." }
  end
  if istLeer(kategorieId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Kategorie-ID fehlt." }
  end
  if istLeer(titel) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Titel fehlt." }
  end

  local okR, errR = assertRecht(kategorieId, spieler, "create")
  if not okR then return nil, errR end

  if formExists(formId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Formular-ID existiert bereits." }
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_form_editor_forms
      (id, category_id, status, active, title, description, created_by_identifier, created_by_name, updated_by_identifier, updated_by_name)
    VALUES
      (?, ?, 'draft', 1, ?, ?, ?, ?, ?, ?)
  ]], {
    formId,
    kategorieId,
    titel,
    (beschreibung ~= "" and beschreibung or nil),
    spieler.identifier,
    spieler.name,
    spieler.identifier,
    spieler.name
  })

  -- initial schema (empty fields)
  local schema = {
    formular = {
      id = formId,
      titel = titel,
      beschreibung = beschreibung,
      kategorieId = kategorieId,
      version = 1
    },
    felder = {}
  }

  local okS, errS = validateSchema(schema)
  if not okS then
    return nil, errS
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_form_editor_versions
      (form_id, version, schema_json, created_by_identifier, created_by_name)
    VALUES (?, 1, ?, ?, ?)
  ]], { formId, json.encode(schema), spieler.identifier, spieler.name })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES ('formular.editor.erstellt', ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ kategorie_id = kategorieId, zeit = utcJetztIso() })
  })

  return loadFormRow(formId), nil
end

function FormularEditorService.SchemaHolen(spieler, formId, modus)
  formId = trim(formId)
  if istLeer(formId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID fehlt." }
  end

  local form = loadFormRow(formId)
  if not form then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Formular nicht gefunden." }
  end

  -- modus: "draft" oder "published"
  modus = tostring(modus or "draft")

  if modus == "published" then
    local row = loadPublishedSchema(formId)
    if not row then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Keine veröffentlichte Version vorhanden." }
    end
    local schema = row.schema_json
    if type(schema) == "string" then
      schema = json.decode(schema)
    end
    return schema, nil
  end

  -- Draft-Ansicht: braucht edit-Recht
  local okR, errR = assertRecht(form.category_id, spieler, "edit")
  if not okR then return nil, errR end

  local row = loadLatestSchema(formId)
  if not row then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Keine Version gefunden." }
  end

  local schema = row.schema_json
  if type(schema) == "string" then
    schema = json.decode(schema)
  end

  return schema, nil
end

function FormularEditorService.SchemaSpeichern(spieler, formId, schema)
  formId = trim(formId)
  if istLeer(formId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID fehlt." }
  end

  local form = loadFormRow(formId)
  if not form then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Formular nicht gefunden." }
  end

  local okR, errR = assertRecht(form.category_id, spieler, "edit")
  if not okR then return nil, errR end

  if form.status ~= "draft" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "Nur Entwürfe können bearbeitet werden. Bitte neuen Entwurf erstellen (kommt in Paket C) oder Formular zurück auf Entwurf setzen (Admin)." }
  end

  local okS, errS = validateSchema(schema)
  if not okS then return nil, errS end

  -- version bump
  local v = nextVersion(formId)

  -- schema.formular version + meta refresh
  schema.formular = schema.formular or {}
  schema.formular.id = formId
  schema.formular.kategorieId = form.category_id
  schema.formular.version = v
  if istLeer(schema.formular.titel) then schema.formular.titel = form.title end
  if schema.formular.beschreibung == nil then schema.formular.beschreibung = form.description or "" end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_form_editor_versions
      (form_id, version, schema_json, created_by_identifier, created_by_name)
    VALUES (?, ?, ?, ?, ?)
  ]], { formId, v, json.encode(schema), spieler.identifier, spieler.name })

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_form_editor_forms
    SET updated_by_identifier = ?, updated_by_name = ?
    WHERE id = ?
  ]], { spieler.identifier, spieler.name, formId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES ('formular.editor.schema_gespeichert', ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ version = v, zeit = utcJetztIso() })
  })

  return { ok = true, version = v }, nil
end

function FormularEditorService.Veroeffentlichen(spieler, formId)
  formId = trim(formId)
  if istLeer(formId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID fehlt." }
  end

  local form = loadFormRow(formId)
  if not form then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Formular nicht gefunden." }
  end

  local okR, errR = assertRecht(form.category_id, spieler, "publish")
  if not okR then return nil, errR end

  local latest = loadLatestSchema(formId)
  if not latest then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Keine Version zum Veröffentlichen gefunden." }
  end

  local version = tonumber(latest.version or 0) or 0
  if version < 1 then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültige Version." }
  end

  -- Strenge Schema-Validierung vor Veröffentlichung
  local schemaRaw = latest.schema_json
  if type(schemaRaw) == "string" then
    local ok, parsed = pcall(json.decode, schemaRaw)
    if ok then schemaRaw = parsed end
  end
  if type(schemaRaw) == "table" then
    local okS, errS = validateSchemaFuerVeroeffentlichung(schemaRaw)
    if not okS then return nil, errS end
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_form_editor_forms
    SET status = 'published',
        published_version = ?,
        published_at = UTC_TIMESTAMP(),
        updated_by_identifier = ?,
        updated_by_name = ?
    WHERE id = ?
  ]], { version, spieler.identifier, spieler.name, formId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES ('formular.editor.veroeffentlicht', ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ version = version, zeit = utcJetztIso() })
  })

  return { ok = true, version = version }, nil
end

function FormularEditorService.Archivieren(spieler, formId)
  formId = trim(formId)
  if istLeer(formId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Formular-ID fehlt." }
  end

  local form = loadFormRow(formId)
  if not form then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Formular nicht gefunden." }
  end

  local okR, errR = assertRecht(form.category_id, spieler, "archive")
  if not okR then return nil, errR end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_form_editor_forms
    SET status = 'archived',
        active = 0,
        updated_by_identifier = ?,
        updated_by_name = ?
    WHERE id = ?
  ]], { spieler.identifier, spieler.name, formId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES ('formular.editor.archiviert', ?, ?, ?, ?, 'form', ?, ?)
  ]], {
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    formId,
    json.encode({ zeit = utcJetztIso() })
  })

  return { ok = true }, nil
end

-- Permissions: optional, falls du später im Spiel Rechte in DB pflegen willst.
-- Für jetzt reicht Config. Wir lassen die Methoden trotzdem drin (admin-only), um DB-Regeln zu setzen.
function FormularEditorService.RechteDBSetzen(spieler, kategorieId, liste)
  kategorieId = trim(kategorieId)
  if istLeer(kategorieId) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Kategorie-ID fehlt." }
  end

  local rolle = rolleErmitteln(spieler)
  if rolle ~= "admin" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Nur Admins dürfen Editor-Rechte in der DB setzen." }
  end

  if type(liste) ~= "table" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Rechte-Liste ist ungültig." }
  end

  HM_BP.Server.Datenbank.Ausfuehren("DELETE FROM hm_bp_form_editor_permissions WHERE category_id = ?", { kategorieId })

  for _, r in ipairs(liste) do
    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_form_editor_permissions
        (category_id, role, job, min_grade, max_grade, can_create, can_edit, can_publish, can_archive)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
      kategorieId,
      r.role or "justiz",
      r.job,
      r.min_grade,
      r.max_grade,
      (r.can_create and 1 or 0),
      (r.can_edit and 1 or 0),
      (r.can_publish and 1 or 0),
      (r.can_archive and 1 or 0)
    })
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES ('formular.editor.rechte_db_gesetzt', ?, ?, ?, ?, 'category', ?, ?)
  ]], {
    spieler.identifier,
    spieler.name,
    spieler.job and spieler.job.name or nil,
    spieler.job and spieler.job.grade or nil,
    kategorieId,
    json.encode({ anzahl = #liste, zeit = utcJetztIso() })
  })

  return { ok = true }, nil
end

HM_BP.Server.Dienste.FormularEditorService = FormularEditorService