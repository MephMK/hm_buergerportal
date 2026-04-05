HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ---------------------------------------------------------------
-- Lokale Hilfsfunktionen für Webhook-Emits und Benachrichtigungen
-- ---------------------------------------------------------------

local function emitWebhook(eventName, data)
  local ws = HM_BP.Server.Dienste.WebhookService
  if ws and ws.Emit then ws.Emit(eventName, data) end
end

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

-- =========================
-- Justiz: Kategorien/Queues/Details/Aktionen + Suche + Rückfragen
-- =========================

RegisterNetEvent("hm_bp:justiz:kategorien_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
  if not spieler then
    TriggerClientEvent("hm_bp:justiz:kategorien_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local liste = HM_BP.Server.Dienste.JustizZugriffService.SichtbareJustizKategorien(spieler)
  TriggerClientEvent("hm_bp:justiz:kategorien_antwort", quelle, { ok = true, kategorien = liste })
end)

RegisterNetEvent("hm_bp:justiz:bearbeiter_liste_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
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

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
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

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
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

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
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

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
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

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
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

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.QUESTION_ASK, {})
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

  -- Webhook + Bürger benachrichtigen
  emitWebhook("antrag_question_asked", {
    submission_id   = antragId,
    public_id       = res.public_id,
    aktenzeichen    = res.public_id,
    category_id     = res.category_id,
    form_id         = res.form_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
    text            = text,
  })
  local benachrichtigungSvc = HM_BP.Server.Dienste.BenachrichtigungService
  if benachrichtigungSvc then benachrichtigungSvc.RueckfrageGestellt(res.citizen_identifier, res.public_id) end
end)

-- Aktionen
RegisterNetEvent("hm_bp:justiz:uebernehmen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_TAKE, {})
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

  emitWebhook("antrag_assigned", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
  })
end)

RegisterNetEvent("hm_bp:justiz:zuweisen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_ASSIGN, {})
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

  emitWebhook("antrag_assigned", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = zielName or zielIdentifier,
  })
end)

RegisterNetEvent("hm_bp:justiz:prioritaet_setzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_SET_PRIORITY, {})
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

  emitWebhook("antrag_priority_changed", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
    priority        = prio,
  })
end)

RegisterNetEvent("hm_bp:justiz:archivieren", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_ARCHIVE, {})
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

  emitWebhook("antrag_archived", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
    text            = (grund ~= "") and grund or nil,
  })
end)

RegisterNetEvent("hm_bp:justiz:interne_notiz", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.NOTES_INTERNAL_WRITE, {})
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

  emitWebhook("antrag_staff_internal_note", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
    text            = text,
  })
end)

RegisterNetEvent("hm_bp:justiz:oeffentliche_antwort", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.MESSAGE_PUBLIC_WRITE, {})
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

  emitWebhook("antrag_staff_public_reply", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    category_id     = res and res.category_id,
    form_id         = res and res.form_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
    text            = text,
  })
  local benachrichtigungSvc = HM_BP.Server.Dienste.BenachrichtigungService
  if benachrichtigungSvc and res and res.citizen_identifier then
    benachrichtigungSvc.OeffentlicheAntwort(res.citizen_identifier, res.public_id)
  end
end)

RegisterNetEvent("hm_bp:justiz:status_setzen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_CHANGE_STATUS, {})
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

  local alterStatus = res and res.alt
  local neuerStatusVal = neuerStatus
  emitWebhook("antrag_status_changed", {
    submission_id   = antragId,
    public_id       = res and res.public_id,
    aktenzeichen    = res and res.public_id,
    category_id     = res and res.category_id,
    form_id         = res and res.form_id,
    akteur_name     = anzeigeNameAuflosen(quelle, spieler.name),
    -- Bürger: gespeicherter Charname aus DB (citizen_name), nie Identifier
    buerger_name    = res and res.citizen_name,
    alter_status    = alterStatus,
    neuer_status    = neuerStatusVal,
    bearbeiter_name = anzeigeNameAuflosen(quelle, spieler.name),
    text            = (kommentar and kommentar ~= "") and kommentar or nil,
  })

  local benachrichtigungSvc = HM_BP.Server.Dienste.BenachrichtigungService
  if benachrichtigungSvc and res and res.citizen_identifier then
    if neuerStatusVal == "approved" or neuerStatusVal == "genehmigt" then
      benachrichtigungSvc.AntragGenehmigt(res.citizen_identifier, res.public_id)
    elseif neuerStatusVal == "rejected" or neuerStatusVal == "abgelehnt" then
      benachrichtigungSvc.AntragAbgelehnt(res.citizen_identifier, res.public_id)
    else
      benachrichtigungSvc.StatusGeaendert(res.citizen_identifier, res.public_id, alterStatus, neuerStatusVal)
    end
  end
end)

RegisterNetEvent("hm_bp:justiz:sperre_verlaengern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
  if not spieler then
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then return end

  HM_BP.Server.Dienste.JustizAntragService.SperreVerlaengern(spieler, antragId)
end)

RegisterNetEvent("hm_bp:justiz:sperren_alle_loesen", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.JUSTICE_VIEW, {})
  if not spieler then
    return
  end

  HM_BP.Server.Dienste.SperrService.AlleSperrenDesBearbeitersLoesen(spieler)
end)