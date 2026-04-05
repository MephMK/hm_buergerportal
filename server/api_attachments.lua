-- =============================================================
-- server/api_attachments.lua
-- Netzwerk-Events für Anhänge (Liste, Hinzufügen, Entfernen).
-- PR8
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- -------------------------------------------------------
-- Anhänge auflisten
-- Payload: { antragId }
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:anhaenge_listen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.ATTACHMENT_VIEW, {})
  if not spieler then
    TriggerClientEvent("hm_bp:anhaenge_listen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:anhaenge_listen_antwort", quelle, {
      ok = false,
      fehler = { code = HM_BP.Gemeinsam.Fehlercodes.UNGUELTIGE_DATEN, nachricht = "antragId fehlt." }
    })
    return
  end

  local liste, err2 = HM_BP.Server.Dienste.AttachmentService.Liste(spieler, antragId)
  if not liste then
    TriggerClientEvent("hm_bp:anhaenge_listen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:anhaenge_listen_antwort", quelle, { ok = true, liste = liste })
end)

-- -------------------------------------------------------
-- Anhang hinzufügen
-- Payload: { antragId, url, titel? }
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:anhang_hinzufuegen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.ATTACHMENT_ADD, {})
  if not spieler then
    TriggerClientEvent("hm_bp:anhang_hinzufuegen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local url      = type(payload.url) == "string" and payload.url or ""
  local titel    = type(payload.titel) == "string" and payload.titel or nil

  local res, err2 = HM_BP.Server.Dienste.AttachmentService.Hinzufuegen(spieler, antragId, url, titel)
  if not res then
    TriggerClientEvent("hm_bp:anhang_hinzufuegen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:anhang_hinzufuegen_antwort", quelle, { ok = true, anhang = res })
end)

-- -------------------------------------------------------
-- Anhang entfernen (soft-delete, nur Justiz/Admin)
-- Payload: { anhangId, grund? }
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:anhang_entfernen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.ATTACHMENT_REMOVE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:anhang_entfernen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local anhangId = tonumber(payload.anhangId)
  local grund    = payload.grund

  local res, err2 = HM_BP.Server.Dienste.AttachmentService.Entfernen(spieler, anhangId, grund)
  if not res then
    TriggerClientEvent("hm_bp:anhang_entfernen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:anhang_entfernen_antwort", quelle, { ok = true })
end)
