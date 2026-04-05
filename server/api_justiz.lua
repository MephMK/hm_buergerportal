HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- =========================
-- Justiz: Kategorien/Queues/Details/Aktionen + Suche + Rückfragen
-- =========================

RegisterNetEvent("hm_bp:justiz:kategorien_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:kategorien_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local liste = HM_BP.Server.Dienste.JustizZugriffService.SichtbareJustizKategorien(spieler)
  TriggerClientEvent("hm_bp:justiz:kategorien_antwort", quelle, { ok = true, kategorien = liste })
end)

RegisterNetEvent("hm_bp:justiz:bearbeiter_liste_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:bearbeiter_liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  HM_BP.Server.Dienste.SpielerService.SyncOnlineStaffInsDirectory()

  local liste = HM_BP.Server.Dienste.SpielerService.BearbeiterListeHolen()
  TriggerClientEvent("hm_bp:justiz:bearbeiter_liste_antwort", quelle, { ok = true, liste = liste })
end)

RegisterNetEvent("hm_bp:justiz:eigang_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:eigang_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local kategorieId = payload.kategorieId
  local liste, err2 = HM_BP.Server.Dienste.JustizAntragService.EingangListe(spieler, kategorieId, payload.limit or 50)
  if not liste then
    TriggerClientEvent("hm_bp:justiz:eigang_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:eigang_antwort", quelle, { ok = true, liste = liste })
end)

RegisterNetEvent("hm_bp:justiz:zugewiesen_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:zugewiesen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local kategorieId = payload.kategorieId
  local liste, err2 = HM_BP.Server.Dienste.JustizAntragService.ZugewiesenListe(spieler, kategorieId, payload.limit or 50)
  if not liste then
    TriggerClientEvent("hm_bp:justiz:zugewiesen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:zugewiesen_antwort", quelle, { ok = true, liste = liste })
end)

RegisterNetEvent("hm_bp:justiz:alle_kategorie_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:alle_kategorie_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local kategorieId = payload.kategorieId
  local liste, err2 = HM_BP.Server.Dienste.JustizAntragService.AlleKategorieListe(spieler, kategorieId, payload.limit or 50)
  if not liste then
    TriggerClientEvent("hm_bp:justiz:alle_kategorie_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:alle_kategorie_antwort", quelle, { ok = true, liste = liste })
end)

RegisterNetEvent("hm_bp:justiz:details_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:details_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:justiz:details_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local details, err2 = HM_BP.Server.Dienste.JustizAntragService.DetailsHolen(spieler, antragId)
  if not details then
    TriggerClientEvent("hm_bp:justiz:details_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:details_antwort", quelle, { ok = true, details = details })
end)

-- Suche/Filter/Sortierung
RegisterNetEvent("hm_bp:justiz:suchen_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:suchen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizSucheService.Suchen(spieler, payload)
  if not res then
    TriggerClientEvent("hm_bp:justiz:suchen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:suchen_antwort", quelle, { ok = true, res = res })
end)

-- Rückfrage stellen (1A)
RegisterNetEvent("hm_bp:justiz:rueckfrage_stellen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "ANTRAG_STATUS_SETZEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:rueckfrage_stellen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local text = payload.text or ""

  local res, err2 = HM_BP.Server.Dienste.RueckfrageService.JustizRueckfrageStellen(spieler, antragId, text)
  if not res then
    TriggerClientEvent("hm_bp:justiz:rueckfrage_stellen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:rueckfrage_stellen_antwort", quelle, { ok = true, res = res })
end)

-- Aktionen
RegisterNetEvent("hm_bp:justiz:uebernehmen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "ANTRAG_UEBERNEHMEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:uebernehmen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:justiz:uebernehmen_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.Uebernehmen(spieler, antragId)
  if not res then
    TriggerClientEvent("hm_bp:justiz:uebernehmen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:uebernehmen_antwort", quelle, { ok = true })
end)

RegisterNetEvent("hm_bp:justiz:zuweisen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "ANTRAG_ZUWEISEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:zuweisen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local zielIdentifier = payload.zielIdentifier
  local zielName = payload.zielName

  if not antragId then
    TriggerClientEvent("hm_bp:justiz:zuweisen_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.Zuweisen(spieler, antragId, zielIdentifier, zielName)
  if not res then
    TriggerClientEvent("hm_bp:justiz:zuweisen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:zuweisen_antwort", quelle, { ok = true })
end)

RegisterNetEvent("hm_bp:justiz:prioritaet_setzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "ANTRAG_PRIORITAET_SETZEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:prioritaet_setzen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local prio = payload.prio

  if not antragId then
    TriggerClientEvent("hm_bp:justiz:prioritaet_setzen_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.PrioritaetSetzen(spieler, antragId, prio)
  if not res then
    TriggerClientEvent("hm_bp:justiz:prioritaet_setzen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:prioritaet_setzen_antwort", quelle, { ok = true, res = res })
end)

RegisterNetEvent("hm_bp:justiz:archivieren", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "ARCHIVIEREN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:archivieren_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local grund = payload.grund or ""

  if not antragId then
    TriggerClientEvent("hm_bp:justiz:archivieren_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.Archivieren(spieler, antragId, grund)
  if not res then
    TriggerClientEvent("hm_bp:justiz:archivieren_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:archivieren_antwort", quelle, { ok = true })
end)

RegisterNetEvent("hm_bp:justiz:interne_notiz", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "INTERNE_NOTIZ_SCHREIBEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:interne_notiz_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local text = payload.text
  if not antragId then
    TriggerClientEvent("hm_bp:justiz:interne_notiz_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.InterneNotiz(spieler, antragId, text)
  if not res then
    TriggerClientEvent("hm_bp:justiz:interne_notiz_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:interne_notiz_antwort", quelle, { ok = true })
end)

RegisterNetEvent("hm_bp:justiz:oeffentliche_antwort", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "OEFFENTLICHE_NACHRICHT_SCHREIBEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:oeffentliche_antwort_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local text = payload.text
  if not antragId then
    TriggerClientEvent("hm_bp:justiz:oeffentliche_antwort_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.OeffentlicheAntwort(spieler, antragId, text)
  if not res then
    TriggerClientEvent("hm_bp:justiz:oeffentliche_antwort_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:oeffentliche_antwort_antwort", quelle, { ok = true })
end)

RegisterNetEvent("hm_bp:justiz:status_setzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "ANTRAG_STATUS_SETZEN", {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:status_setzen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local neuerStatus = payload.neuerStatus
  local kommentar = payload.kommentar

  if not antragId then
    TriggerClientEvent("hm_bp:justiz:status_setzen_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.JustizAntragService.StatusAendern(spieler, antragId, neuerStatus, kommentar)
  if not res then
    TriggerClientEvent("hm_bp:justiz:status_setzen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:justiz:status_setzen_antwort", quelle, { ok = true, res = res })
end)

RegisterNetEvent("hm_bp:justiz:sperre_verlaengern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then return end

  HM_BP.Server.Dienste.JustizAntragService.SperreVerlaengern(spieler, antragId)
end)

RegisterNetEvent("hm_bp:justiz:sperren_alle_loesen", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, "JUSTIZ_OEFFNEN", {})
  if not spieler then
    return
  end

  HM_BP.Server.Dienste.SperrService.AlleSperrenDesBearbeitersLoesen(spieler)
end)