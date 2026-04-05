HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local FormularService = {}

local function formularErlaubtFuerStandort(formularId, standort)
  if not standort or not standort.zugriff then return true end
  local erlaubte = standort.zugriff.erlaubteFormulare
  if type(erlaubte) ~= "table" then return true end
  if #erlaubte == 0 then return true end
  for _, id in ipairs(erlaubte) do
    if id == formularId then return true end
  end
  return false
end

local function kategorieErlaubtFuerStandort(kategorieId, standort)
  if not standort or not standort.zugriff then return true end
  local erlaubte = standort.zugriff.erlaubteKategorien
  if type(erlaubte) ~= "table" then return true end
  if #erlaubte == 0 then return true end
  for _, id in ipairs(erlaubte) do
    if id == kategorieId then return true end
  end
  return false
end

local function configFormsAktiv()
  return (Config.Formulare and Config.Formulare.Aktiviert and Config.Formulare.Liste)
end

local function dbFormsAktiv()
  return (Config.FormularEditor and Config.FormularEditor.Aktiviert == true)
end

local function dbPublishedFormsForCategory(kategorieId)
  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT id, category_id, title, description, status, active, published_version, fee_eur
    FROM hm_bp_form_editor_forms
    WHERE category_id = ?
      AND status = 'published'
      AND active = 1
    ORDER BY updated_at DESC
    LIMIT 500
  ]], { kategorieId }) or {}
  return rows
end

local function dbPublishedSchema(formId)
  local row = HM_BP.Server.Datenbank.Einzel([[
    SELECT v.schema_json, f.fee_eur
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

local function feldByKey(schema, key)
  if not schema or type(schema.felder) ~= "table" then return nil end
  for _, f in ipairs(schema.felder) do
    if f and f.key == key then
      return f
    end
  end
  return nil
end

local function ensureCitizenNameField(schema, rolle)
  -- Nur im Bürger-Formular relevant; Justiz-Ansicht kann später erweitert werden.
  if rolle ~= "buerger" then
    return schema
  end

  schema = schema or {}
  schema.felder = schema.felder or {}

  -- Falls Feld schon existiert -> nur sicherstellen: pflicht true + sichtbarkeit buerger true
  local existing = feldByKey(schema, "citizen_name")
  if existing then
    existing.pflicht = true
    existing.typ = existing.typ or "shorttext"
    existing.label = existing.label or "Name"
    existing.beschreibung = existing.beschreibung or "Bitte deinen Namen eintragen."
    existing.placeholder = existing.placeholder or "Vor- und Nachname"
    existing.minLaenge = existing.minLaenge or 2
    existing.maxLaenge = existing.maxLaenge or 60
    return schema
  end

  -- Neues Pflichtfeld als erstes Feld einfügen
  local f = {
    id = "citizen_name",
    key = "citizen_name",
    label = "Name",
    beschreibung = "Bitte deinen Namen eintragen.",
    typ = "shorttext",
    pflicht = true,
    minLaenge = 2,
    maxLaenge = 60,
    placeholder = "Vor- und Nachname",
    optionen = nil,
    reihenfolge = 0,
    sichtbarkeit = { buerger = true, justiz = true, nurIntern = false }
  }

  table.insert(schema.felder, 1, f)

  -- reihenfolge sauber nachziehen
  for i, ff in ipairs(schema.felder) do
    if ff and type(ff) == "table" then
      if ff.reihenfolge == nil then
        ff.reihenfolge = i
      end
    end
  end

  return schema
end

function FormularService.ListeSichtbarFuer(spieler, standortId, kategorieId)
  local rolle = spieler.rolle or HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  local standort = nil
  if standortId and Config.Standorte and Config.Standorte.Liste then
    standort = Config.Standorte.Liste[standortId]
  end

  local ergebnis = {}

  -- 1) Config-Forms
  if configFormsAktiv() then
    for fId, f in pairs(Config.Formulare.Liste) do
      if f and f.aktiv == true then
        if kategorieId and f.kategorieId ~= kategorieId then
          goto weiter
        end

        if standort then
          if not formularErlaubtFuerStandort(fId, standort) then goto weiter end
          if not kategorieErlaubtFuerStandort(f.kategorieId, standort) then goto weiter end
        end

        if rolle == "buerger" then
          if f.fuerBuergerSichtbar ~= true then goto weiter end
          if f.buergerDuerfenEinreichen ~= true then goto weiter end
        end

        table.insert(ergebnis, {
          id = f.id,
          titel = f.titel,
          beschreibung = f.beschreibung,
          kategorieId = f.kategorieId,
          quelle = "config",
          cooldownSekunden = f.cooldownSekunden or 0,
          maxOffenProSpieler = f.maxOffenProSpieler or 0,
          standardStatus = f.standardStatus,
          standardPrioritaet = f.standardPrioritaet,
          -- Gebühr aus config.gebuehren (PR14)
          fee_eur = (f.gebuehren and f.gebuehren.aktiv and tonumber(f.gebuehren.betrag)) or 0,
        })
      end
      ::weiter::
    end
  end

  -- 2) DB-Forms (published only)
  if dbFormsAktiv() then
    if kategorieId then
      local rows = dbPublishedFormsForCategory(kategorieId)
      for _, r in ipairs(rows) do
        if standort then
          if not kategorieErlaubtFuerStandort(r.category_id, standort) then
            goto weiter_db
          end
          if not formularErlaubtFuerStandort(r.id, standort) then
            goto weiter_db
          end
        end

        table.insert(ergebnis, {
          id = r.id,
          titel = r.title,
          beschreibung = r.description or "",
          kategorieId = r.category_id,
          quelle = "db",
          cooldownSekunden = 0,
          maxOffenProSpieler = 0,
          standardStatus = nil,
          standardPrioritaet = nil,
          -- Gebühr aus DB-Formular (PR14)
          fee_eur = tonumber(r.fee_eur) or 0,
        })

        ::weiter_db::
      end
    end
  end

  table.sort(ergebnis, function(a, b)
    return tostring(a.titel) < tostring(b.titel)
  end)

  return ergebnis
end

function FormularService.FormularSchemaHolen(spieler, formularId)
  local rolle = spieler.rolle or HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)

  -- 1) DB first (published only)
  if dbFormsAktiv() then
    local row = dbPublishedSchema(formularId)
    if row and row.schema_json then
      local schema = row.schema_json
      if type(schema) == "string" then
        schema = json.decode(schema)
      end

      -- Gebühr aus DB in Schema eintragen (PR14)
      schema.formular = schema.formular or {}
      schema.formular.fee_eur = tonumber(row.fee_eur) or 0

      schema = ensureCitizenNameField(schema, rolle)
      return schema, nil
    end
  end

  -- 2) Config fallback
  if not (Config.Formulare and Config.Formulare.Liste and Config.Formulare.Liste[formularId]) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Formular wurde nicht gefunden." }
  end

  local f = Config.Formulare.Liste[formularId]
  if f.aktiv ~= true then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Formular ist deaktiviert." }
  end

  if rolle == "buerger" then
    if f.fuerBuergerSichtbar ~= true or f.buergerDuerfenEinreichen ~= true then
      return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst dieses Formular nicht nutzen." }
    end
  end

  local schema = {
    formular = {
      id = f.id,
      titel = f.titel,
      beschreibung = f.beschreibung,
      kategorieId = f.kategorieId,
      version = 1,
      -- Gebühr aus Config (PR14)
      fee_eur = (f.gebuehren and f.gebuehren.aktiv and tonumber(f.gebuehren.betrag)) or 0,
    },
    felder = {}
  }

  local felder = f.felder or {}
  table.sort(felder, function(a, b)
    return (a.reihenfolge or 999) < (b.reihenfolge or 999)
  end)

  for _, feld in ipairs(felder) do
    local sicht = feld.sichtbarkeit or { buerger = true, justiz = true, nurIntern = false }
    if rolle == "buerger" then
      if sicht.nurIntern == true or sicht.buerger ~= true then
        goto weiter
      end
    end

    table.insert(schema.felder, {
      id = feld.id,
      key = feld.key,
      label = feld.label,
      beschreibung = feld.beschreibung,
      typ = feld.typ,
      placeholder = feld.placeholder,
      pflicht = feld.pflicht == true,
      standardwert = feld.standardwert,

      minLaenge = feld.minLaenge,
      maxLaenge = feld.maxLaenge,
      min = feld.min,
      max = feld.max,
      regex = feld.regex,
      optionen = feld.optionen,
      reihenfolge = feld.reihenfolge,
      sichtbarkeit = feld.sichtbarkeit,
    })
    ::weiter::
  end

  schema = ensureCitizenNameField(schema, rolle)
  return schema, nil
end

HM_BP.Server.Dienste.FormularService = FormularService