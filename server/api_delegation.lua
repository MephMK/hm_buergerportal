-- =============================================================
-- server/api_delegation.lua
-- PR3 – Delegation / Stellvertretung + Vollmacht
--
-- Netz-Events:
--   hm_bp:delegation:online_spieler_suchen   → Suche online Spieler per Ingame-Name
--   hm_bp:delegation:vollmacht_anlegen        → Vollmacht anlegen  (Leitung/Admin)
--   hm_bp:delegation:vollmacht_widerrufen     → Vollmacht widerrufen (Leitung/Admin)
--   hm_bp:delegation:vollmachten_listen       → Vollmachten auflisten (Leitung/Admin)
-- =============================================================

-- -------------------------------------------------------
-- Online-Spieler suchen (per Ingame-Name)
-- Verwendungszweck: Auswahl des Ziel-Spielers für Delegation
-- Gibt source-ID + Name zurück; kein Identifier-Leak
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:delegation:online_spieler_suchen", function(payload)
  local quelle = source
  payload = payload or {}

  -- Jeder mit SUBMISSIONS_CREATE-Recht darf suchen
  -- (wird auch von der Delegation-Prüfung abgedeckt)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_CREATE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:delegation:online_spieler_ergebnis", quelle, { ok = false, fehler = err })
    return
  end

  if not (Config.Module and Config.Module.Delegation) then
    TriggerClientEvent("hm_bp:delegation:online_spieler_ergebnis", quelle, {
      ok = false,
      fehler = { nachricht = "Delegation ist nicht aktiviert." }
    })
    return
  end

  local suchname = tostring(payload.name or "")
  if #suchname < 2 then
    TriggerClientEvent("hm_bp:delegation:online_spieler_ergebnis", quelle, {
      ok = false,
      fehler = { nachricht = "Suchname muss mindestens 2 Zeichen haben." }
    })
    return
  end

  local ergebnisse = HM_BP.Server.Dienste.DelegationService.OnlineSpielerSuchen(suchname)

  -- Kein Identifier-Leak: nur source + name zurückgeben
  local sicher = {}
  for _, e in ipairs(ergebnisse) do
    table.insert(sicher, { source = e.source, name = e.name })
  end

  TriggerClientEvent("hm_bp:delegation:online_spieler_ergebnis", quelle, {
    ok = true,
    spieler = sicher
  })
end)

-- -------------------------------------------------------
-- Vollmacht anlegen (Justiz-Leitung / Admin)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:delegation:vollmacht_anlegen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.VOLLMACHT_MANAGE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:delegation:vollmacht_anlegen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  -- Auftraggeber: Identifier aus source (online Spieler)
  local auftraggeberSource = tonumber(payload.auftraggeber_source)
  local auftraggeberDaten  = auftraggeberSource and HM_BP.Server.Dienste.DelegationService.SpielerDurchSource(auftraggeberSource)
  if not auftraggeberDaten then
    TriggerClientEvent("hm_bp:delegation:vollmacht_anlegen_antwort", quelle, {
      ok = false,
      fehler = { nachricht = "Auftraggeber ist nicht online oder konnte nicht aufgelöst werden." }
    })
    return
  end

  -- Bevollmächtigter: Identifier aus source (online Spieler)
  local bevollSource  = tonumber(payload.bevollmaechtigter_source)
  local bevollDaten   = bevollSource and HM_BP.Server.Dienste.DelegationService.SpielerDurchSource(bevollSource)
  if not bevollDaten then
    TriggerClientEvent("hm_bp:delegation:vollmacht_anlegen_antwort", quelle, {
      ok = false,
      fehler = { nachricht = "Bevollmächtigter ist nicht online oder konnte nicht aufgelöst werden." }
    })
    return
  end

  local typ = tostring(payload.typ or "")

  local res, err2 = HM_BP.Server.Dienste.DelegationService.VollmachtAnlegen(
    spieler,
    typ,
    auftraggeberDaten.identifier,
    auftraggeberDaten.name,
    bevollDaten.identifier,
    bevollDaten.name
  )

  if not res then
    TriggerClientEvent("hm_bp:delegation:vollmacht_anlegen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:delegation:vollmacht_anlegen_antwort", quelle, { ok = true, ergebnis = res })
end)

-- -------------------------------------------------------
-- Vollmacht widerrufen (Justiz-Leitung / Admin)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:delegation:vollmacht_widerrufen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.VOLLMACHT_MANAGE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:delegation:vollmacht_widerrufen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local vollmachtId = tonumber(payload.vollmacht_id)
  if not vollmachtId then
    TriggerClientEvent("hm_bp:delegation:vollmacht_widerrufen_antwort", quelle, {
      ok = false,
      fehler = { nachricht = "Vollmacht-ID fehlt oder ungültig." }
    })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.DelegationService.VollmachtWiderrufen(spieler, vollmachtId)
  if not res then
    TriggerClientEvent("hm_bp:delegation:vollmacht_widerrufen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:delegation:vollmacht_widerrufen_antwort", quelle, { ok = true, ergebnis = res })
end)

-- -------------------------------------------------------
-- Vollmachten auflisten (Justiz-Leitung / Admin)
-- -------------------------------------------------------
RegisterNetEvent("hm_bp:delegation:vollmachten_listen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.VOLLMACHT_VIEW, {})
  if not spieler then
    TriggerClientEvent("hm_bp:delegation:vollmachten_ergebnis", quelle, { ok = false, fehler = err })
    return
  end

  local filter = {
    typ        = payload.typ,
    nur_aktiv  = payload.nur_aktiv ~= false,
  }

  local liste = HM_BP.Server.Dienste.DelegationService.VollmachtenListen(filter)

  TriggerClientEvent("hm_bp:delegation:vollmachten_ergebnis", quelle, {
    ok    = true,
    liste = liste
  })
end)
