HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ===================================================
-- API-Endpunkte für Mitarbeiter-Entwürfe (PR2)
-- Alle Endpunkte sind auf Justiz/Admin beschränkt.
-- ===================================================

-- Entwurf speichern
RegisterNetEvent("hm_bp:entwurf:speichern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.NOTES_INTERNAL_WRITE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:entwurf:speichern_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.EntwurfService.Speichern(
    spieler,
    payload.antragId,
    payload.typ,
    payload.text
  )
  if not res then
    TriggerClientEvent("hm_bp:entwurf:speichern_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:entwurf:speichern_antwort", quelle, { ok = true, updated_at = res.updated_at, typ = payload.typ })
end)

-- Entwurf laden
RegisterNetEvent("hm_bp:entwurf:laden", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.NOTES_INTERNAL_WRITE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:entwurf:laden_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.EntwurfService.Laden(
    spieler,
    payload.antragId,
    payload.typ
  )
  if not res then
    TriggerClientEvent("hm_bp:entwurf:laden_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:entwurf:laden_antwort", quelle, { ok = true, entwurf = res.entwurf, typ = payload.typ })
end)

-- Entwurf löschen
RegisterNetEvent("hm_bp:entwurf:loeschen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.NOTES_INTERNAL_WRITE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:entwurf:loeschen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.EntwurfService.Loeschen(
    spieler,
    payload.antragId,
    payload.typ
  )
  if not res then
    TriggerClientEvent("hm_bp:entwurf:loeschen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:entwurf:loeschen_antwort", quelle, { ok = true, geloescht = res.geloescht, typ = payload.typ })
end)
