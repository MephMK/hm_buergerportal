-- =============================================================
-- server/api_job_settings.lua  (PR15)
--
-- JobSettings-API: Job-Grade-Berechtigungen im Admin-Panel verwalten.
-- Alle Endpunkte erfordern Admin-Berechtigung (Job + MinGrade aus Config.Kern.Admin).
-- Änderungen werden über AdminConfigService in data/admin_overrides.json persistiert
-- und ohne Serverneustart sofort wirksam (in-memory reload via PermissionService).
--
-- Events (Client → Server → Client):
--   hm_bp:admin:job_settings_laden          → hm_bp:admin:job_settings_antwort
--   hm_bp:admin:job_settings_speichern      → hm_bp:admin:job_settings_speichern_antwort
--   hm_bp:admin:job_settings_zuruecksetzen  → hm_bp:admin:job_settings_zuruecksetzen_antwort
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ----------------------------------------------------------------
-- Interne Hilfsfunktionen
-- ----------------------------------------------------------------

local function cfgSvc()  return HM_BP.Server.Dienste.AdminConfigService  end
local function audSvc()  return HM_BP.Server.Dienste.AdminAuditService   end

local function anzeigeNameAuflosen(quelle, fallback)
  local ss = HM_BP.Server.Dienste.SpielerService
  if ss and ss.AnzeigeNameAuflosen then
    return ss.AnzeigeNameAuflosen(quelle, fallback)
  end
  if ss and ss.SpielerNameAuflosen then
    local name = ss.SpielerNameAuflosen(quelle)
    if name and name ~= "" then return name end
  end
  return fallback or "System"
end

-- Identische Admin-Prüfung wie in api_admin.lua (doppelte Sicherheitsschicht).
local function pruefeAdmin(quelle, aktion)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle,
    aktion or HM_BP.Shared.Actions.ADMIN_PANEL_OPEN,
    {}
  )
  if not spieler then return nil, err end

  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  if rolle ~= "admin" then
    return nil, {
      code     = HM_BP.Shared.Errors.NOT_AUTHORIZED,
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

-- Gibt alle kanonischen Aktionsschlüssel als sortiertes Array zurück.
local function aktionenListe()
  local liste = {}
  local actions = HM_BP.Shared.Actions or {}
  for _, v in pairs(actions) do
    if type(v) == "string" then
      liste[#liste + 1] = v
    end
  end
  table.sort(liste)
  return liste
end

-- Gibt den effektiven globalen Defaults-Eintrag (allow/deny) für eine Rolle zurück.
local function rollenDefaultsLaden()
  local defaults = Config.Permissions and Config.Permissions.Defaults or {}
  local result = {}
  for rolle, def in pairs(defaults) do
    -- Serialisierbare Kopie (ohne jobs/grade-Constraints, die die UI nicht braucht)
    result[rolle] = {
      allow = type(def.allow) == "table" and def.allow or {},
      deny  = type(def.deny)  == "table" and def.deny  or {},
    }
  end
  return result
end

-- Validiert eine einzelne gradPermissions-Tabelle gegen die erlaubten Aktionen.
local function validiereGradPermissions(gradPerms, erlaubteAktionen)
  if type(gradPerms) ~= "table" then
    return false, "gradPermissions muss eine Tabelle sein."
  end
  local erlaubtSet = {}
  for _, a in ipairs(erlaubteAktionen) do erlaubtSet[a] = true end

  for gradeStr, perms in pairs(gradPerms) do
    local gradeNum = tonumber(gradeStr)
    if not gradeNum or gradeNum < 0 or gradeNum ~= math.floor(gradeNum) then
      return false, ("Ungültiger Grade-Schlüssel: '%s' (muss nicht-negative Ganzzahl sein)."):format(tostring(gradeStr))
    end
    if type(perms) ~= "table" then
      return false, ("gradPermissions[%s] muss eine Tabelle sein."):format(tostring(gradeStr))
    end
    for _, liste in ipairs({ perms.allow or {}, perms.deny or {} }) do
      if type(liste) ~= "table" then
        return false, ("allow/deny in Grade %s muss ein Array sein."):format(tostring(gradeStr))
      end
      for _, aktion in ipairs(liste) do
        if type(aktion) ~= "string" then
          return false, ("Aktionsschlüssel in Grade %s muss ein String sein."):format(tostring(gradeStr))
        end
        if aktion ~= "*" and not erlaubtSet[aktion] then
          return false, ("Unbekannter Aktionsschlüssel '%s' in Grade %s."):format(aktion, tostring(gradeStr))
        end
      end
    end
  end
  return true, nil
end

-- Vollständige Validierung der JobSettings-Nutzdaten.
local function validiereJobSettings(daten)
  if type(daten) ~= "table" then
    return false, "JobSettings muss eine Tabelle sein."
  end
  local jobs = daten.Jobs
  if jobs ~= nil and type(jobs) ~= "table" then
    return false, "Jobs muss eine Tabelle sein."
  end
  if not jobs then return true, nil end  -- Leere Settings sind gültig

  local erlaubteAktionen = aktionenListe()

  for jobName, jobDef in pairs(jobs) do
    if type(jobName) ~= "string" or jobName == "" then
      return false, "Job-Name muss ein nicht-leerer String sein."
    end
    if type(jobDef) ~= "table" then
      return false, ("Job '%s' muss eine Tabelle sein."):format(jobName)
    end
    -- grades validieren (optional, aber wenn vorhanden korrekt formatiert)
    if jobDef.grades ~= nil then
      if type(jobDef.grades) ~= "table" then
        return false, ("Job '%s': grades muss ein Array sein."):format(jobName)
      end
      for _, g in ipairs(jobDef.grades) do
        if type(g) ~= "table" then
          return false, ("Job '%s': Jeder Grade-Eintrag muss eine Tabelle sein."):format(jobName)
        end
        if tonumber(g.grade) == nil then
          return false, ("Job '%s': Grade-Eintrag ohne gültige 'grade'-Zahl."):format(jobName)
        end
        if g.name ~= nil and type(g.name) ~= "string" then
          return false, ("Job '%s', Grade %s: 'name' muss ein String sein."):format(jobName, tostring(g.grade))
        end
      end
    end
    -- gradPermissions validieren
    if jobDef.gradPermissions ~= nil then
      local ok, err = validiereGradPermissions(jobDef.gradPermissions, erlaubteAktionen)
      if not ok then
        return false, ("Job '%s': %s"):format(jobName, err)
      end
    end
  end
  return true, nil
end

-- ----------------------------------------------------------------
-- Endpunkt: JobSettings laden
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:job_settings_laden", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_PANEL_OPEN)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:job_settings_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local svc = cfgSvc()
  local eff = svc and svc.GetEffectiveConfig() or Config
  local basis = svc and svc.GetBasis("JobSettings") or (Config.JobSettings or {})

  TriggerClientEvent("hm_bp:admin:job_settings_antwort", quelle, {
    ok          = true,
    daten       = eff.JobSettings or {},
    basis       = basis,
    aktionen    = aktionenListe(),
    rollenDefaults = rollenDefaultsLaden(),
  })
end)

-- ----------------------------------------------------------------
-- Endpunkt: JobSettings speichern
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:job_settings_speichern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = grundErr }
    })
    return
  end

  local daten = payload.daten
  if type(daten) ~= "table" then
    TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = "Keine gültigen Daten übermittelt." }
    })
    return
  end

  -- Validierung
  local valOk, valErr = validiereJobSettings(daten)
  if not valOk then
    TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = "Validierungsfehler: " .. tostring(valErr) }
    })
    return
  end

  -- Persistieren via AdminConfigService
  local svc = cfgSvc()
  if not svc then
    TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = "AdminConfigService nicht verfügbar." }
    })
    return
  end

  local saveOk, saveErr = svc.SektionSpeichern("JobSettings", daten)
  if not saveOk then
    TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, {
      ok = false, fehler = { nachricht = "Speicherfehler: " .. tostring(saveErr) }
    })
    return
  end

  -- Audit-Log
  local requestId   = HM_BP.Server.Dienste.AuditService and
                      HM_BP.Server.Dienste.AuditService.GenerateRequestId and
                      HM_BP.Server.Dienste.AuditService.GenerateRequestId() or "N/A"
  local akteurName  = anzeigeNameAuflosen(quelle, "Admin")
  local as = audSvc()
  if as and as.Log then
    as.Log("admin.job_settings.speichern", spieler, "job_settings", "JobSettings", {
      grund   = payload.grund,
      request_id       = requestId,
      actor_display_name = akteurName,
      actor_source     = "admin_panel",
      metadata         = json.encode({ aktion = "job_settings_speichern" }),
    })
  end

  TriggerClientEvent("hm_bp:admin:job_settings_speichern_antwort", quelle, {
    ok       = true,
    nachricht = "JobSettings gespeichert.",
    request_id = requestId,
  })
end)

-- ----------------------------------------------------------------
-- Endpunkt: JobSettings zurücksetzen (Override entfernen)
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:admin:job_settings_zuruecksetzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle, HM_BP.Shared.Actions.ADMIN_CONFIG_WRITE)
  if not spieler then
    TriggerClientEvent("hm_bp:admin:job_settings_zuruecksetzen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local grundOk, grundErr = grundPruefen(payload.grund)
  if not grundOk then
    TriggerClientEvent("hm_bp:admin:job_settings_zuruecksetzen_antwort", quelle, {
      ok = false, fehler = { nachricht = grundErr }
    })
    return
  end

  local svc = cfgSvc()
  if not svc then
    TriggerClientEvent("hm_bp:admin:job_settings_zuruecksetzen_antwort", quelle, {
      ok = false, fehler = { nachricht = "AdminConfigService nicht verfügbar." }
    })
    return
  end

  local resetOk, resetErr = svc.SektionZuruecksetzen("JobSettings")
  if not resetOk then
    TriggerClientEvent("hm_bp:admin:job_settings_zuruecksetzen_antwort", quelle, {
      ok = false, fehler = { nachricht = "Zurücksetzen fehlgeschlagen: " .. tostring(resetErr) }
    })
    return
  end

  -- Audit-Log
  local requestId  = HM_BP.Server.Dienste.AuditService and
                     HM_BP.Server.Dienste.AuditService.GenerateRequestId and
                     HM_BP.Server.Dienste.AuditService.GenerateRequestId() or "N/A"
  local akteurName = anzeigeNameAuflosen(quelle, "Admin")
  local as = audSvc()
  if as and as.Log then
    as.Log("admin.job_settings.zuruecksetzen", spieler, "job_settings", "JobSettings", {
      grund   = payload.grund,
      request_id       = requestId,
      actor_display_name = akteurName,
      actor_source     = "admin_panel",
      metadata         = json.encode({ aktion = "job_settings_zuruecksetzen" }),
    })
  end

  TriggerClientEvent("hm_bp:admin:job_settings_zuruecksetzen_antwort", quelle, {
    ok       = true,
    nachricht = "JobSettings auf Basis-Config zurückgesetzt.",
    request_id = requestId,
  })
end)
