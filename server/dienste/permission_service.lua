-- =============================================================
-- server/dienste/permission_service.lua
--
-- Feingranulares Permissions-System mit Kaskaden-Auflösung:
--   1) System deaktiviert → alles erlaubt
--   2) Admin-Job → immer volles Zugriff (Kurzschluss)
--   3) Globale Defaults für die Rolle (Config.Permissions.Defaults)
--   4) Job-Constraint (spieler.job.name muss in defaults.jobs)
--   5) Grade-Constraint (min/max oder allowed-Liste)
--   6) Kategorie-Override (ctx.kategorieId → .permissions[rolle])
--   7) Formular-Override  (ctx.formularId  → .permissions[rolle])
--   8) Global-Default entscheidet (Default-Deny)
--
-- Entscheidungslogik (pro Ebene):
--   - deny-Liste hat Vorrang: Aktion in deny? → false (kein weiterer Override)
--   - allow-Liste oder Stern (*): Aktion in allow? → true
--   - Ebene schweigt: weiter zur nächstniedrigeren Ebene
--
-- PermissionService.Hat(spieler, aktion, ctx?) → ok, fehler
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local PermissionService = {}

-- ----------------------------------------------------------------
-- Interne Hilfsfunktionen
-- ----------------------------------------------------------------

local function debug(...)
  if Config.Permissions and Config.Permissions.Debug == true then
    print("[PermissionService]", ...)
  end
end

local function enthaelt(liste, wert)
  if type(liste) ~= "table" then return false end
  for _, v in ipairs(liste) do
    if v == wert then return true end
  end
  return false
end

local function hatStern(liste)
  if type(liste) ~= "table" then return false end
  for _, v in ipairs(liste) do
    if v == "*" then return true end
  end
  return false
end

-- Prüft Job-Constraint einer Regelgruppe.
-- regel.jobs  → Liste erlaubter Job-Namen (leer = alle)
-- regel.job   → einzelner Job-Name (Kurzform, Rückwärtskompatibilität)
local function jobPasst(spieler, regel)
  if not regel then return true end

  local jobName = spieler.job and spieler.job.name or ""

  -- Multi-Job-Liste
  if type(regel.jobs) == "table" and #regel.jobs > 0 then
    return enthaelt(regel.jobs, jobName)
  end
  -- Einzelner Job (Rückwärtskompatibilität)
  if type(regel.job) == "string" and regel.job ~= "" then
    return jobName == regel.job
  end
  return true
end

-- Prüft Grade-Constraint einer Regelgruppe.
-- regel.grade.min     → Mindestgrad (inkl.)
-- regel.grade.max     → Höchstgrad (inkl.)
-- regel.grade.allowed → erlaubte Gradwerte (Liste)
-- Rückwärtskompatibilität: regel.mindestGrad (flaches Feld)
local function gradePasst(spieler, regel)
  if not regel then return true end

  local grad = tonumber(spieler.job and spieler.job.grade) or 0

  -- Neues verschachteltes grade-Objekt
  if type(regel.grade) == "table" then
    local g = regel.grade
    if type(g.allowed) == "table" and #g.allowed > 0 then
      local ok = false
      for _, v in ipairs(g.allowed) do
        if tonumber(v) == grad then ok = true; break end
      end
      return ok
    end
    if g.min ~= nil and grad < tonumber(g.min) then return false end
    if g.max ~= nil and grad > tonumber(g.max) then return false end
    return true
  end

  -- Rückwärtskompatibilität: flaches mindestGrad-Feld
  if regel.mindestGrad ~= nil and grad < tonumber(regel.mindestGrad) then
    return false
  end

  return true
end

-- Wertet eine einzelne Regel-Ebene aus.
-- Gibt zurück:  true (erlaubt), false (explizit verboten), nil (keine Aussage)
local function ebeneAuswerten(regel, aktion)
  if not regel then return nil end

  -- Deny hat Vorrang
  if type(regel.deny) == "table" and (enthaelt(regel.deny, aktion) or hatStern(regel.deny)) then
    return false
  end

  -- Allow (inkl. Wildcard)
  if type(regel.allow) == "table" and (enthaelt(regel.allow, aktion) or hatStern(regel.allow)) then
    return true
  end

  return nil  -- Ebene schweigt
end

-- Holt die Override-Regel für eine Kategorie oder ein Formular.
-- Quelle: Config.Kategorien.Liste[id].permissions[rolle]
--      oder Config.Formulare.Liste[id].permissions[rolle]
local function overrideRegel(typ, id, rolle)
  local liste
  if typ == "kategorie" then
    liste = Config.Kategorien and Config.Kategorien.Liste
  elseif typ == "formular" then
    liste = Config.Formulare and Config.Formulare.Liste
  end
  if not liste then return nil end

  local eintrag = liste[id]
  if not eintrag then return nil end

  local perms = eintrag.permissions
  if not perms then return nil end

  return perms[rolle]  -- kann nil sein
end

-- ----------------------------------------------------------------
-- Öffentliche API
-- ----------------------------------------------------------------

---Prüft, ob `spieler` die `aktion` im gegebenen `ctx` durchführen darf.
---@param spieler table  Spieler-Kontext (aus AuthService.SpielerLaden + RolleErmitteln)
---@param aktion  string Kanonischer Aktionsschlüssel (HM_BP.Shared.Actions.*)
---@param ctx     table? Optionaler Kontext: { kategorieId, formularId }
---@return boolean ok
---@return table?  fehler  -- nil wenn ok == true
function PermissionService.Hat(spieler, aktion, ctx)
  -- 1) Permissions-System deaktiviert → alles erlaubt
  if not (Config.Permissions and Config.Permissions.Aktiviert == true) then
    debug("System deaktiviert – erlaube", aktion)
    return true, nil
  end

  ctx = ctx or {}

  local rolle = (spieler.rolle)
    or HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)

  debug("Hat(", spieler.identifier, ",", aktion, ", rolle=", rolle, ")")

  -- 2) Admin-Job → immer Vollzugriff (Kurzschluss, kein weiteres Cascading)
  if rolle == "admin" then
    debug("Admin-Kurzschluss → erlaube", aktion)
    return true, nil
  end

  -- 3) Lade globale Defaults für die Rolle
  local defaults = Config.Permissions.Defaults and Config.Permissions.Defaults[rolle]
  if not defaults then
    debug("Keine Defaults für Rolle", rolle, "→ verweigert")
    return false, {
      code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
      nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
    }
  end

  -- 4) Job-Constraint aus globalen Defaults
  if not jobPasst(spieler, defaults) then
    debug("Job-Constraint verletzt für Rolle", rolle, "→ verweigert")
    return false, {
      code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
      nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
    }
  end

  -- 5) Grade-Constraint aus globalen Defaults
  if not gradePasst(spieler, defaults) then
    debug("Grade-Constraint verletzt für Rolle", rolle, "→ verweigert")
    return false, {
      code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
      nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
    }
  end

  -- 6) Kategorie-Override (höchste kontextuelle Spezifizität nach Formular)
  local kategorieId = ctx.kategorieId
  if kategorieId then
    local catRegel = overrideRegel("kategorie", kategorieId, rolle)
    if catRegel then
      -- Job/Grade-Constraints des Overrides prüfen
      if not jobPasst(spieler, catRegel) or not gradePasst(spieler, catRegel) then
        debug("Kategorie-Override Job/Grade-Constraint verletzt →", aktion, "verweigert")
        return false, {
          code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
          nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
        }
      end
      local erg = ebeneAuswerten(catRegel, aktion)
      if erg ~= nil then
        debug("Kategorie-Override entscheidet:", erg, "für", aktion)
        if erg then return true, nil end
        return false, {
          code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
          nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
        }
      end
    end
  end

  -- 7) Formular-Override
  local formularId = ctx.formularId
  if formularId then
    local frmRegel = overrideRegel("formular", formularId, rolle)
    if frmRegel then
      if not jobPasst(spieler, frmRegel) or not gradePasst(spieler, frmRegel) then
        debug("Formular-Override Job/Grade-Constraint verletzt →", aktion, "verweigert")
        return false, {
          code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
          nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
        }
      end
      local erg = ebeneAuswerten(frmRegel, aktion)
      if erg ~= nil then
        debug("Formular-Override entscheidet:", erg, "für", aktion)
        if erg then return true, nil end
        return false, {
          code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
          nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
        }
      end
    end
  end

  -- 8) Globale Defaults entscheiden
  local erg = ebeneAuswerten(defaults, aktion)
  if erg == true then
    debug("Globale Defaults erlauben", aktion)
    return true, nil
  end

  debug("Keine Regel erlaubt", aktion, "→ verweigert (Default-Deny)")
  return false, {
    code = HM_BP.Shared.Errors.NOT_AUTHORIZED,
    nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHORIZED
  }
end

HM_BP.Server.Dienste.PermissionService = PermissionService
