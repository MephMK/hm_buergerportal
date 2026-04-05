HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ===================================================
-- EntwurfService – Mitarbeiter-Entwürfe (PR2)
-- Unterstützt: interne Notiz (internal_note) +
--              Rückfrage (question)
-- Ein Entwurf je (submission_id, actor_identifier, draft_type).
-- Speichern überschreibt; Laden gibt Text + Zeitstempel zurück.
-- ===================================================

local EntwurfService = {}

local ERLAUBTE_TYPEN = { internal_note = true, question = true }
local MAX_LAENGE = 5000

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function istJustizOderAdmin(spieler)
  if not spieler then return false end
  local auth = HM_BP.Server.Dienste.AuthService
  if auth and auth.IstAdmin and auth.IstAdmin(spieler) then return true end
  if auth and auth.IstJustiz and auth.IstJustiz(spieler) then return true end
  -- Fallback über Permissions
  local pm = HM_BP.Server.Dienste.PermissionService
  if pm and pm.Hat then
    return pm.Hat(spieler, HM_BP.Shared.Actions.NOTES_INTERNAL_WRITE, {}) == true
  end
  return false
end

-- Entwurf speichern (INSERT … ON DUPLICATE KEY UPDATE)
function EntwurfService.Speichern(spieler, antragId, draftType, text)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  if not istJustizOderAdmin(spieler) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung für Entwürfe." }
  end

  if not ERLAUBTE_TYPEN[draftType] then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiger Entwurfstyp." }
  end

  text = trim(text)
  if text == "" then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Entwurfstext ist leer." }
  end
  if #text > MAX_LAENGE then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN,
                  nachricht = "Entwurfstext ist zu lang (max. " .. MAX_LAENGE .. " Zeichen)." }
  end

  local a = HM_BP.Server.Datenbank.Einzel(
    "SELECT id, deleted_at FROM hm_bp_submissions WHERE id = ?", { antragId }
  )
  if not a or a.deleted_at ~= nil then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_staff_drafts (submission_id, actor_identifier, draft_type, draft_text)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE draft_text = VALUES(draft_text), updated_at = CURRENT_TIMESTAMP
  ]], { antragId, spieler.identifier, draftType, text })

  -- Audit
  local audit = HM_BP.Server.Dienste.AuditService
  if audit and audit.Log then
    audit.Log("entwurf.gespeichert", spieler, "submission", tostring(antragId), {
      draft_type = draftType,
      text_laenge = #text,
    })
  end

  -- Zeitstempel des gespeicherten Entwurfs zurückgeben
  local row = HM_BP.Server.Datenbank.Einzel([[
    SELECT updated_at FROM hm_bp_staff_drafts
    WHERE submission_id = ? AND actor_identifier = ? AND draft_type = ?
  ]], { antragId, spieler.identifier, draftType })

  return { ok = true, updated_at = row and row.updated_at or nil }, nil
end

-- Entwurf laden
function EntwurfService.Laden(spieler, antragId, draftType)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  if not istJustizOderAdmin(spieler) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung für Entwürfe." }
  end

  if not ERLAUBTE_TYPEN[draftType] then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiger Entwurfstyp." }
  end

  local row = HM_BP.Server.Datenbank.Einzel([[
    SELECT draft_text, updated_at FROM hm_bp_staff_drafts
    WHERE submission_id = ? AND actor_identifier = ? AND draft_type = ?
  ]], { antragId, spieler.identifier, draftType })

  if not row then
    return { ok = true, entwurf = nil }, nil
  end

  return { ok = true, entwurf = { text = row.draft_text, updated_at = row.updated_at } }, nil
end

-- Entwurf löschen
function EntwurfService.Loeschen(spieler, antragId, draftType)
  antragId = tonumber(antragId)
  if not antragId then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Antrags-ID fehlt." }
  end

  if not istJustizOderAdmin(spieler) then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Keine Berechtigung für Entwürfe." }
  end

  if not ERLAUBTE_TYPEN[draftType] then
    return nil, { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "Ungültiger Entwurfstyp." }
  end

  local existing = HM_BP.Server.Datenbank.Einzel([[
    SELECT id FROM hm_bp_staff_drafts
    WHERE submission_id = ? AND actor_identifier = ? AND draft_type = ?
  ]], { antragId, spieler.identifier, draftType })

  if not existing then
    return { ok = true, geloescht = false }, nil
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    DELETE FROM hm_bp_staff_drafts
    WHERE submission_id = ? AND actor_identifier = ? AND draft_type = ?
  ]], { antragId, spieler.identifier, draftType })

  -- Audit
  local audit = HM_BP.Server.Dienste.AuditService
  if audit and audit.Log then
    audit.Log("entwurf.geloescht", spieler, "submission", tostring(antragId), {
      draft_type = draftType,
    })
  end

  return { ok = true, geloescht = true }, nil
end

HM_BP.Server.Dienste.EntwurfService = EntwurfService
