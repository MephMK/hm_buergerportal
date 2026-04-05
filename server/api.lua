HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- Lokale Hilfsfunktion: kanonischen Anzeigenamen (Spielername + Charname) auflösen.
local function anzeigeNameAuflosen(quelle, fallback)
  local ss = HM_BP.Server.Dienste.SpielerService
  if ss and ss.AnzeigeNameAuflosen then
    return ss.AnzeigeNameAuflosen(quelle, fallback)
  end
  -- Nothilfe: nur FiveM-Name
  if ss and ss.SpielerNameAuflosen then
    local name = ss.SpielerNameAuflosen(quelle)
    if name and name ~= "" then return name end
  end
  return fallback or "System"
end

-- =========================
-- Portal-Grunddaten
-- =========================
RegisterNetEvent("hm_bp:portal:daten_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:portal:daten_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local standortId = payload.standortId
  local standort = nil
  if standortId and Config.Standorte and Config.Standorte.Liste then
    standort = Config.Standorte.Liste[standortId]
  end

  TriggerClientEvent("hm_bp:portal:daten_antwort", quelle, {
    ok = true,
    daten = {
      spieler = {
        name = spieler.name,
        identifier = spieler.identifier,
        rolle = spieler.rolle,
        job = spieler.job.name,
        grad = spieler.job.grade,
        jobLabel = spieler.job.label,
        gradLabel = spieler.job.gradeLabel
      },
      standort = standort and { id = standort.id, name = standort.name } or nil
    }
  })
end)

-- =========================
-- Statusliste (serverseitig, nach Kategorie gefiltert)
-- =========================
RegisterNetEvent("hm_bp:status:liste_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:status:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local kategorieId = payload.kategorieId
  if not kategorieId then
    TriggerClientEvent("hm_bp:status:liste_antwort", quelle, { ok = false, fehler = { nachricht = "Kategorie-ID fehlt." } })
    return
  end

  if HM_BP.Server.Dienste.AuthService.IstJustiz(spieler) or HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    local regeln = HM_BP.Server.Dienste.JustizZugriffService.KategorieRegelnFuer(spieler, kategorieId)
    if not regeln or regeln.erlaubt ~= true then
      TriggerClientEvent("hm_bp:status:liste_antwort", quelle, { ok = false, fehler = { nachricht = "Kein Zugriff auf diese Kategorie." } })
      return
    end
  end

  local liste = HM_BP.Server.Dienste.StatusService.StatusListeFuerKategorie(kategorieId)
  TriggerClientEvent("hm_bp:status:liste_antwort", quelle, { ok = true, liste = liste })
end)

-- =========================
-- Prioritätenliste
-- =========================
RegisterNetEvent("hm_bp:prioritaeten:liste_anfordern", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:prioritaeten:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local liste = {}
  if Config.Prioritaeten and Config.Prioritaeten.Aktiviert and type(Config.Prioritaeten.Liste) == "table" then
    for _, p in ipairs(Config.Prioritaeten.Liste) do
      table.insert(liste, { id = p.id, label = p.label, farbe = p.farbe, sortierung = p.sortierung or 999 })
    end
  end
  table.sort(liste, function(a, b) return (a.sortierung or 999) < (b.sortierung or 999) end)

  TriggerClientEvent("hm_bp:prioritaeten:liste_antwort", quelle, { ok = true, liste = liste })
end)

-- =========================
-- Bürger: Kategorien/Formulare/Schemas/Einreichen/Meine Anträge
-- =========================
RegisterNetEvent("hm_bp:kategorien:liste_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:kategorien:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local standortId = payload.standortId
  local liste = HM_BP.Server.Dienste.KategorieService.ListeSichtbarFuer(spieler, standortId)
  TriggerClientEvent("hm_bp:kategorien:liste_antwort", quelle, { ok = true, kategorien = liste })
end)

RegisterNetEvent("hm_bp:formulare:liste_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:formulare:liste_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local standortId = payload.standortId
  local kategorieId = payload.kategorieId
  if not kategorieId then
    TriggerClientEvent("hm_bp:formulare:liste_antwort", quelle, { ok = false, fehler = { nachricht = "Kategorie-ID fehlt." } })
    return
  end

  local liste = HM_BP.Server.Dienste.FormularService.ListeSichtbarFuer(spieler, standortId, kategorieId)
  TriggerClientEvent("hm_bp:formulare:liste_antwort", quelle, { ok = true, formulare = liste })
end)

RegisterNetEvent("hm_bp:formular:schema_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:formular:schema_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local formularId = payload.formularId
  if not formularId then
    TriggerClientEvent("hm_bp:formular:schema_antwort", quelle, { ok = false, fehler = { nachricht = "Formular-ID fehlt." } })
    return
  end

  local schema, err2 = HM_BP.Server.Dienste.FormularService.FormularSchemaHolen(spieler, formularId)
  if not schema then
    TriggerClientEvent("hm_bp:formular:schema_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:formular:schema_antwort", quelle, { ok = true, schema = schema })
end)

RegisterNetEvent("hm_bp:antrag:einreichen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_CREATE, {})
  if not spieler then
    TriggerClientEvent("hm_bp:antrag:einreichen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local standortId = payload.standortId
  local formularId = payload.formularId
  local antworten = payload.antworten

  if not formularId or type(antworten) ~= "table" then
    TriggerClientEvent("hm_bp:antrag:einreichen_antwort", quelle, { ok = false, fehler = { nachricht = "Ungültige Daten (Formular/Antworten fehlen)." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.AntragService.Einreichen(spieler, standortId, formularId, antworten)
  if not res then
    TriggerClientEvent("hm_bp:antrag:einreichen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  -- Webhook + Ingame-Benachrichtigung (nur falls aktiviert/konfiguriert)
  if HM_BP.Server.Dienste.WebhookService and HM_BP.Server.Dienste.WebhookService.Emit then
    HM_BP.Server.Dienste.WebhookService.Emit("antrag_created", {
      submission_id = res.id,
      public_id     = res.public_id,
      aktenzeichen  = res.public_id,
      category_id   = (Config.Formulare and Config.Formulare.Liste and Config.Formulare.Liste[formularId] and Config.Formulare.Liste[formularId].kategorieId) or nil,
      form_id       = formularId,
      akteur_name   = anzeigeNameAuflosen(quelle, spieler.name),
      buerger_name  = anzeigeNameAuflosen(quelle, spieler.name),
      -- citizen_identifier wird NICHT an Discord übermittelt
      priority      = res.prioritaet,
      status        = res.status,
    })
  end

  if HM_BP.Server.Dienste.BenachrichtigungService then
    local formularName = (Config.Formulare and Config.Formulare.Liste and Config.Formulare.Liste[formularId] and Config.Formulare.Liste[formularId].name) or formularId
    HM_BP.Server.Dienste.BenachrichtigungService.AntragEingereicht(quelle, res.public_id, formularName)
  end

  TriggerClientEvent("hm_bp:antrag:einreichen_antwort", quelle, { ok = true, antrag = res })
end)

RegisterNetEvent("hm_bp:antraege:meine_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_VIEW_OWN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:antraege:meine_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local liste = HM_BP.Server.Dienste.AntragService.MeineAntraegeAuflisten(spieler, payload.limit or 25)
  TriggerClientEvent("hm_bp:antraege:meine_antwort", quelle, { ok = true, antraege = liste })
end)

-- =========================
-- Bürger – Details eigener Antrag + Timeline (citizen) + Antworten (2A)
-- =========================
RegisterNetEvent("hm_bp:antrag:details_mein_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_VIEW_OWN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:antrag:details_mein_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:antrag:details_mein_antwort", quelle, { ok = false, fehler = { nachricht = "Antrags-ID fehlt." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.RueckfrageService.BuergerDetailsHolen(spieler, antragId)
  if not res then
    TriggerClientEvent("hm_bp:antrag:details_mein_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:antrag:details_mein_antwort", quelle, { ok = true, details = res })
end)

RegisterNetEvent("hm_bp:antrag:buerger_antwort", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_VIEW_OWN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:antrag:buerger_antwort_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local text = payload.text or ""

  local res, err2 = HM_BP.Server.Dienste.RueckfrageService.BuergerAntwort(spieler, antragId, text)
  if not res then
    TriggerClientEvent("hm_bp:antrag:buerger_antwort_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  if HM_BP.Server.Dienste.WebhookService and HM_BP.Server.Dienste.WebhookService.Emit then
    HM_BP.Server.Dienste.WebhookService.Emit("antrag_citizen_replied", {
      submission_id = antragId,
      akteur_name   = anzeigeNameAuflosen(quelle, spieler.name),
      buerger_name  = anzeigeNameAuflosen(quelle, spieler.name),
      text          = text,
      neuer_status  = res.statusNeu,
    })
  end

  TriggerClientEvent("hm_bp:antrag:buerger_antwort_antwort", quelle, { ok = true, res = res })
end)

-- =========================
-- Bürger – Formular-Antworten nachreichen (nur bei question_open)
-- =========================
RegisterNetEvent("hm_bp:antrag:nachreichen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SUBMISSIONS_VIEW_OWN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:antrag:nachreichen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local antragId = tonumber(payload.antragId)
  local felder = payload.felder

  if not antragId or type(felder) ~= "table" then
    TriggerClientEvent("hm_bp:antrag:nachreichen_antwort", quelle, { ok = false, fehler = { nachricht = "Ungültige Daten (antragId oder felder fehlen)." } })
    return
  end

  local res, err2 = HM_BP.Server.Dienste.NachreichungService.NachreichungEinreichen(spieler, antragId, felder)
  if not res then
    TriggerClientEvent("hm_bp:antrag:nachreichen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  if HM_BP.Server.Dienste.WebhookService and HM_BP.Server.Dienste.WebhookService.Emit then
    HM_BP.Server.Dienste.WebhookService.Emit("antrag_nachgereicht", {
      submission_id = antragId,
      public_id     = res.public_id,
      aktenzeichen  = res.public_id,
      akteur_name   = anzeigeNameAuflosen(quelle, spieler.name),
      buerger_name  = anzeigeNameAuflosen(quelle, spieler.name),
      category_id   = res.category_id,
      form_id       = res.form_id,
    })
  end

  TriggerClientEvent("hm_bp:antrag:nachreichen_antwort", quelle, { ok = true, res = res })
end)

-- Debug: Öffentliche ID testen
RegisterNetEvent("hm_bp:debug:oeffentliche_id_test", function()
  local quelle = source

  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(quelle, HM_BP.Shared.Actions.SYSTEM_OPEN, {})
  if not spieler then
    TriggerClientEvent("hm_bp:debug:oeffentliche_id_test_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local publicId, err2 = HM_BP.Server.Dienste.OeffentlicheIdService.NaechsteAntragsNummerErzeugen()
  if not publicId then
    TriggerClientEvent("hm_bp:debug:oeffentliche_id_test_antwort", quelle, { ok = false, fehler = { nachricht = err2 } })
    return
  end

  TriggerClientEvent("hm_bp:debug:oeffentliche_id_test_antwort", quelle, { ok = true, publicId = publicId })
end)