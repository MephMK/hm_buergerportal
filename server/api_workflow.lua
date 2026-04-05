-- =============================================================
-- server/api_workflow.lua
-- Workflow-API: Lock anfordern/freigeben/überschreiben,
-- SLA pausieren/fortsetzen (PR7)
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- -------------------------------------------------------
-- Lock: anfordern
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:workflow:lock_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, HM_BP.Shared.Actions.WORKFLOW_LOCK_REQUEST, {})
  if not spieler then
    TriggerClientEvent("hm_bp:workflow:lock_anfordern_antwort", quelle,
      { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:workflow:lock_anfordern_antwort", quelle,
      { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local ok2, err2 = HM_BP.Server.Dienste.SperrService.Sperren(
    spieler, antragId, payload.grund or nil)
  if not ok2 then
    TriggerClientEvent("hm_bp:workflow:lock_anfordern_antwort", quelle,
      { ok = false, fehler = err2 })
    return
  end

  -- Audit
  HM_BP.Server.Dienste.AuditService.Log(
    "lock.angefordert", spieler, "submission", tostring(antragId),
    { grund = payload.grund or nil })

  TriggerClientEvent("hm_bp:workflow:lock_anfordern_antwort", quelle, { ok = true })
end)

-- -------------------------------------------------------
-- Lock: freigeben (eigener Lock)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:workflow:lock_freigeben", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, HM_BP.Shared.Actions.WORKFLOW_LOCK_RELEASE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:workflow:lock_freigeben_antwort", quelle,
      { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:workflow:lock_freigeben_antwort", quelle,
      { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local ok2, err2 = HM_BP.Server.Dienste.SperrService.Entsperren(spieler, antragId)
  if not ok2 then
    TriggerClientEvent("hm_bp:workflow:lock_freigeben_antwort", quelle,
      { ok = false, fehler = err2 })
    return
  end

  -- Audit
  HM_BP.Server.Dienste.AuditService.Log(
    "lock.freigegeben", spieler, "submission", tostring(antragId), {})

  TriggerClientEvent("hm_bp:workflow:lock_freigeben_antwort", quelle, { ok = true })
end)

-- -------------------------------------------------------
-- Lock: überschreiben/aufheben (nur Leitung oder Admin)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:workflow:lock_ueberschreiben", function(payload)
  local quelle = source
  payload = payload or {}

  -- Basis-Zugang: muss als Justiz/Admin eingeloggt sein
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
  if not spieler then
    TriggerClientEvent("hm_bp:workflow:lock_ueberschreiben_antwort", quelle,
      { ok = false, fehler = err })
    return
  end

  -- Nur Leitung oder Admin darf überschreiben
  local istLeitung = HM_BP.Server.Dienste.WorkflowService.IstLeitung(spieler)
  local istAdmin   = HM_BP.Server.Dienste.AuthService.IstAdmin(spieler)
  if not istLeitung and not istAdmin then
    TriggerClientEvent("hm_bp:workflow:lock_ueberschreiben_antwort", quelle, {
      ok     = false,
      fehler = {
        code     = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG,
        nachricht = "Nur Leitung oder Admin darf Sperren überschreiben."
      }
    })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:workflow:lock_ueberschreiben_antwort", quelle,
      { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local lock = HM_BP.Server.Dienste.SperrService.SperreHolen(antragId)
  local altBesitzer = lock and (lock.locked_by_name or lock.locked_by_identifier) or nil

  -- Direkt löschen (Override ignoriert Owner-Prüfung)
  HM_BP.Server.Datenbank.Ausfuehren(
    "DELETE FROM hm_bp_submission_locks WHERE submission_id = ?", { antragId })

  -- Timeline-Eintrag
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({
      text     = "Bearbeitungssperre durch Leitung aufgehoben.",
      befreit  = altBesitzer or "–",
      grund    = payload.grund or ""
    })
  })

  -- Audit
  HM_BP.Server.Dienste.AuditService.Log(
    "lock.ueberschrieben", spieler, "submission", tostring(antragId), {
      alt_besitzer = altBesitzer,
      grund        = payload.grund or nil,
    })

  TriggerClientEvent("hm_bp:workflow:lock_ueberschreiben_antwort", quelle, { ok = true })
end)

-- -------------------------------------------------------
-- SLA: pausieren (nur Leitung oder Admin)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:workflow:sla_pausieren", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
  if not spieler then
    TriggerClientEvent("hm_bp:workflow:sla_pausieren_antwort", quelle,
      { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:workflow:sla_pausieren_antwort", quelle,
      { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  -- IstLeitung/IstAdmin-Check ist in WorkflowService.SlaPausieren integriert
  local ok2, err2 = HM_BP.Server.Dienste.WorkflowService.SlaPausieren(
    spieler, antragId, payload.grund)
  if not ok2 then
    TriggerClientEvent("hm_bp:workflow:sla_pausieren_antwort", quelle,
      { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:workflow:sla_pausieren_antwort", quelle, { ok = true })
end)

-- -------------------------------------------------------
-- SLA: fortsetzen (nur Leitung oder Admin)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:workflow:sla_fortsetzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
  if not spieler then
    TriggerClientEvent("hm_bp:workflow:sla_fortsetzen_antwort", quelle,
      { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:workflow:sla_fortsetzen_antwort", quelle,
      { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  -- IstLeitung/IstAdmin-Check ist in WorkflowService.SlaFortsetzen integriert
  local ok2, err2 = HM_BP.Server.Dienste.WorkflowService.SlaFortsetzen(
    spieler, antragId, payload.grund)
  if not ok2 then
    TriggerClientEvent("hm_bp:workflow:sla_fortsetzen_antwort", quelle,
      { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:workflow:sla_fortsetzen_antwort", quelle, { ok = true })
end)
