HM_BP = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

local uiOffen = false
local letzterStandort = nil

-- Heartbeat State
local heartbeatAktiv = false
local heartbeatAntragId = nil

local function heartbeatStart(antragId)
  heartbeatAktiv = true
  heartbeatAntragId = antragId
end

local function heartbeatStop()
  heartbeatAktiv = false
  heartbeatAntragId = nil
end

CreateThread(function()
  while true do
    local sek = (Config.Workflows and Config.Workflows.Sperren and Config.Workflows.Sperren.HeartbeatSekunden) or 45
    if sek < 10 then sek = 10 end
    Wait(sek * 1000)

    if uiOffen and heartbeatAktiv and heartbeatAntragId ~= nil then
      TriggerServerEvent("hm_bp:justiz:sperre_verlaengern", { antragId = heartbeatAntragId })
    end
  end
end)

RegisterNUICallback("hm_bp:ui_schliessen", function(_, cb)
  TriggerServerEvent("hm_bp:justiz:sperren_alle_loesen")
  heartbeatStop()

  uiOffen = false
  SetNuiFocus(false, false)
  SendNUIMessage({ typ = "hm_bp:ui_schliessen" })
  cb({ ok = true })
end)

-- Statusliste
RegisterNUICallback("hm_bp:status_liste_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:status:liste_anfordern", { kategorieId = daten.kategorieId })
  cb({ ok = true })
end)

-- Prioritätenliste
RegisterNUICallback("hm_bp:prioritaeten_liste_laden", function(_, cb)
  TriggerServerEvent("hm_bp:prioritaeten:liste_anfordern")
  cb({ ok = true })
end)

-- Bearbeiterliste
RegisterNUICallback("hm_bp:justiz_bearbeiter_liste_laden", function(_, cb)
  TriggerServerEvent("hm_bp:justiz:bearbeiter_liste_anfordern")
  cb({ ok = true })
end)

-- Bürger
RegisterNUICallback("hm_bp:portal_daten_anfordern", function(_, cb)
  TriggerServerEvent("hm_bp:portal:daten_anfordern", { standortId = letzterStandort })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:kategorien_laden", function(_, cb)
  TriggerServerEvent("hm_bp:kategorien:liste_anfordern", { standortId = letzterStandort })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:formulare_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:formulare:liste_anfordern", { standortId = letzterStandort, kategorieId = daten.kategorieId })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:formular_schema_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:formular:schema_anfordern", { formularId = daten.formularId })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:antrag_einreichen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:antrag:einreichen", {
    standortId = letzterStandort,
    formularId = daten.formularId,
    antworten  = daten.antworten,
    delegation = daten.delegation,  -- PR3: optional { typ, ziel_source }
  })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:meine_antraege_laden", function(_, cb)
  TriggerServerEvent("hm_bp:antraege:meine_anfordern", { limit = 50 })
  cb({ ok = true })
end)

-- NEU: Bürger – Details eines eigenen Antrags
RegisterNUICallback("hm_bp:antrag_details_mein_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:antrag:details_mein_anfordern", { antragId = daten.antragId })
  cb({ ok = true })
end)

-- NEU: Bürger – Antwort senden (nur wenn Rückfrage offen)
RegisterNUICallback("hm_bp:antrag_buerger_antwort_senden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:antrag:buerger_antwort", { antragId = daten.antragId, text = daten.text })
  cb({ ok = true })
end)

-- NEU: Bürger – Fehlende Felder nachreichen (nur bei question_open)
RegisterNUICallback("hm_bp:antrag_nachreichen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:antrag:nachreichen", { antragId = daten.antragId, felder = daten.felder })
  cb({ ok = true })
end)

-- PR6: Bürger-Suche (eigene Anträge mit Filtern suchen)
RegisterNUICallback("hm_bp:buerger_suchen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:antraege:suchen", daten)
  cb({ ok = true })
end)

-- Justiz
RegisterNUICallback("hm_bp:justiz_kategorien_laden", function(_, cb)
  TriggerServerEvent("hm_bp:justiz:kategorien_anfordern")
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_eingang_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:eigang_anfordern", { kategorieId = daten.kategorieId, limit = daten.limit or 100 })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_zugewiesen_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:zugewiesen_anfordern", { kategorieId = daten.kategorieId, limit = daten.limit or 100 })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_alle_kategorie_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:alle_kategorie_anfordern", { kategorieId = daten.kategorieId, limit = daten.limit or 100 })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_details_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:details_anfordern", { antragId = daten.antragId })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_uebernehmen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:uebernehmen", { antragId = daten.antragId })
  heartbeatStart(tonumber(daten.antragId))
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_zuweisen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:zuweisen", { antragId = daten.antragId, zielIdentifier = daten.zielIdentifier, zielName = daten.zielName })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_prioritaet_setzen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:prioritaet_setzen", { antragId = daten.antragId, prio = daten.prio })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_archivieren", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:archivieren", { antragId = daten.antragId, grund = daten.grund })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_interne_notiz", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:interne_notiz", { antragId = daten.antragId, text = daten.text })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_oeffentliche_antwort", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:oeffentliche_antwort", { antragId = daten.antragId, text = daten.text })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_status_setzen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:status_setzen", { antragId = daten.antragId, neuerStatus = daten.neuerStatus, kommentar = daten.kommentar })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:justiz_suchen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:suchen_anfordern", daten)
  cb({ ok = true })
end)

-- NEU: Rückfrage stellen
RegisterNUICallback("hm_bp:justiz_rueckfrage_stellen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:justiz:rueckfrage_stellen", { antragId = daten.antragId, text = daten.text })
  cb({ ok = true })
end)

-- Entwurf speichern / laden / löschen
RegisterNUICallback("hm_bp:entwurf_speichern", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:entwurf:speichern", { antragId = daten.antragId, typ = daten.typ, text = daten.text })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:entwurf_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:entwurf:laden", { antragId = daten.antragId, typ = daten.typ })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:entwurf_loeschen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:entwurf:loeschen", { antragId = daten.antragId, typ = daten.typ })
  cb({ ok = true })
end)

-- Debug
RegisterNUICallback("hm_bp:debug_oeffentliche_id_test", function(_, cb)
  TriggerServerEvent("hm_bp:debug:oeffentliche_id_test")
  cb({ ok = true })
end)

-- ==========================
-- Export / PDF (PR11)
-- ==========================

-- NUI fordert PDF-Exportdaten an; Antwort kommt als ClientEvent zurück.
RegisterNUICallback("hm_bp:export_pdf_starten", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:export:pdf_daten_anfordern", { antragId = daten.antragId })
  cb({ ok = true })
end)

-- ==========================
-- Delegation / Stellvertretung (PR3)
-- ==========================
RegisterNUICallback("hm_bp:delegation_online_spieler_suchen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:delegation:online_spieler_suchen", { name = daten.name })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:delegation_vollmacht_anlegen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:delegation:vollmacht_anlegen", {
    typ                       = daten.typ,
    auftraggeber_source       = daten.auftraggeber_source,
    bevollmaechtigter_source  = daten.bevollmaechtigter_source,
  })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:delegation_vollmacht_widerrufen", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:delegation:vollmacht_widerrufen", { vollmacht_id = daten.vollmacht_id })
  cb({ ok = true })
end)

RegisterNUICallback("hm_bp:delegation_vollmachten_laden", function(daten, cb)
  daten = daten or {}
  TriggerServerEvent("hm_bp:delegation:vollmachten_listen", { typ = daten.typ, nur_aktiv = daten.nur_aktiv })
  cb({ ok = true })
end)

-- ==========================
-- Formular-Editor (Direkte NUI-Callbacks mit Promise/Await)
-- ==========================
-- Antwort-Events als Net-Events registrieren (verhindert FiveM-Warnung "not safe for net")
RegisterNetEvent("hm_bp:form_editor:rechte_antwort")
RegisterNetEvent("hm_bp:form_editor:liste_antwort")
RegisterNetEvent("hm_bp:form_editor:formular_erstellen_antwort")
RegisterNetEvent("hm_bp:form_editor:schema_holen_antwort")
RegisterNetEvent("hm_bp:form_editor:schema_speichern_antwort")
RegisterNetEvent("hm_bp:form_editor:veroeffentlichen_antwort")
RegisterNetEvent("hm_bp:form_editor:archivieren_antwort")

-- Hilfsfunktion: Server-Event auslösen und synchron auf die Antwort warten.
local function formEditorAufruf(serverEvent, daten, antwortEvent)
  local p = promise.new()
  local h = AddEventHandler(antwortEvent, function(result)
    p:resolve(result)
  end)
  TriggerServerEvent(serverEvent, daten)
  local ok, result = pcall(Citizen.Await, p)
  RemoveEventHandler(h)
  if ok then return result end
  return { ok = false, fehler = { nachricht = "Keine Antwort vom Server erhalten." } }
end

RegisterNUICallback("hm_bp:form_editor_rechte_laden", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:rechte_anfordern",
    daten or {},
    "hm_bp:form_editor:rechte_antwort"
  ))
end)

RegisterNUICallback("hm_bp:form_editor_liste_laden", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:liste_anfordern",
    daten or {},
    "hm_bp:form_editor:liste_antwort"
  ))
end)

RegisterNUICallback("hm_bp:form_editor_formular_erstellen", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:formular_erstellen",
    daten or {},
    "hm_bp:form_editor:formular_erstellen_antwort"
  ))
end)

RegisterNUICallback("hm_bp:form_editor_schema_holen", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:schema_holen",
    daten or {},
    "hm_bp:form_editor:schema_holen_antwort"
  ))
end)

RegisterNUICallback("hm_bp:form_editor_schema_speichern", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:schema_speichern",
    daten or {},
    "hm_bp:form_editor:schema_speichern_antwort"
  ))
end)

RegisterNUICallback("hm_bp:form_editor_veroeffentlichen", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:veroeffentlichen",
    daten or {},
    "hm_bp:form_editor:veroeffentlichen_antwort"
  ))
end)

RegisterNUICallback("hm_bp:form_editor_archivieren", function(daten, cb)
  cb(formEditorAufruf(
    "hm_bp:form_editor:archivieren",
    daten or {},
    "hm_bp:form_editor:archivieren_antwort"
  ))
end)

local function sende(typ, payload)
  SendNUIMessage({ typ = typ, payload = payload or {} })
end

RegisterNetEvent("hm_bp:portal:daten_antwort", function(payload) sende("hm_bp:portal:daten_antwort", payload) end)
RegisterNetEvent("hm_bp:status:liste_antwort", function(payload) sende("hm_bp:status:liste_antwort", payload) end)
RegisterNetEvent("hm_bp:prioritaeten:liste_antwort", function(payload) sende("hm_bp:prioritaeten:liste_antwort", payload) end)

RegisterNetEvent("hm_bp:kategorien:liste_antwort", function(payload) sende("hm_bp:kategorien:liste_antwort", payload) end)
RegisterNetEvent("hm_bp:formulare:liste_antwort", function(payload) sende("hm_bp:formulare:liste_antwort", payload) end)
RegisterNetEvent("hm_bp:formular:schema_antwort", function(payload) sende("hm_bp:formular:schema_antwort", payload) end)
RegisterNetEvent("hm_bp:antrag:einreichen_antwort", function(payload) sende("hm_bp:antrag:einreichen_antwort", payload) end)
RegisterNetEvent("hm_bp:antraege:meine_antwort", function(payload) sende("hm_bp:antraege:meine_antwort", payload) end)
-- PR6: Bürger-Suche Antwort
RegisterNetEvent("hm_bp:antraege:suchen_antwort", function(payload) sende("hm_bp:antraege:suchen_antwort", payload) end)

-- NEU: Bürger Details + Antwort + Nachreichen Ack
RegisterNetEvent("hm_bp:antrag:details_mein_antwort", function(payload) sende("hm_bp:antrag:details_mein_antwort", payload) end)
RegisterNetEvent("hm_bp:antrag:buerger_antwort_antwort", function(payload) sende("hm_bp:antrag:buerger_antwort_antwort", payload) end)
RegisterNetEvent("hm_bp:antrag:nachreichen_antwort", function(payload) sende("hm_bp:antrag:nachreichen_antwort", payload) end)

RegisterNetEvent("hm_bp:justiz:kategorien_antwort", function(payload) sende("hm_bp:justiz:kategorien_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:bearbeiter_liste_antwort", function(payload) sende("hm_bp:justiz:bearbeiter_liste_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:eigang_antwort", function(payload) sende("hm_bp:justiz:eigang_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:zugewiesen_antwort", function(payload) sende("hm_bp:justiz:zugewiesen_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:alle_kategorie_antwort", function(payload) sende("hm_bp:justiz:alle_kategorie_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:details_antwort", function(payload) sende("hm_bp:justiz:details_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:uebernehmen_antwort", function(payload) sende("hm_bp:justiz:uebernehmen_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:zuweisen_antwort", function(payload) sende("hm_bp:justiz:zuweisen_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:prioritaet_setzen_antwort", function(payload) sende("hm_bp:justiz:prioritaet_setzen_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:archivieren_antwort", function(payload) sende("hm_bp:justiz:archivieren_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:interne_notiz_antwort", function(payload) sende("hm_bp:justiz:interne_notiz_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:oeffentliche_antwort_antwort", function(payload) sende("hm_bp:justiz:oeffentliche_antwort_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:status_setzen_antwort", function(payload) sende("hm_bp:justiz:status_setzen_antwort", payload) end)
RegisterNetEvent("hm_bp:justiz:suchen_antwort", function(payload) sende("hm_bp:justiz:suchen_antwort", payload) end)

-- NEU: Rückfrage Ack
RegisterNetEvent("hm_bp:justiz:rueckfrage_stellen_antwort", function(payload) sende("hm_bp:justiz:rueckfrage_stellen_antwort", payload) end)

-- Entwurf: Antworten weiterleiten
RegisterNetEvent("hm_bp:entwurf:speichern_antwort", function(payload) sende("hm_bp:entwurf:speichern_antwort", payload) end)
RegisterNetEvent("hm_bp:entwurf:laden_antwort", function(payload) sende("hm_bp:entwurf:laden_antwort", payload) end)
RegisterNetEvent("hm_bp:entwurf:loeschen_antwort", function(payload) sende("hm_bp:entwurf:loeschen_antwort", payload) end)

RegisterNetEvent("hm_bp:debug:oeffentliche_id_test_antwort", function(payload) sende("hm_bp:debug:oeffentliche_id_test_antwort", payload) end)

-- PR11: PDF-Export Antwort (Daten + Discord-Status)
RegisterNetEvent("hm_bp:export:pdf_daten_antwort", function(payload) sende("hm_bp:export:pdf_daten_antwort", payload) end)

-- PR3: Delegation / Stellvertretung
RegisterNetEvent("hm_bp:delegation:online_spieler_ergebnis", function(payload) sende("hm_bp:delegation:online_spieler_ergebnis", payload) end)
RegisterNetEvent("hm_bp:delegation:vollmacht_anlegen_antwort", function(payload) sende("hm_bp:delegation:vollmacht_anlegen_antwort", payload) end)
RegisterNetEvent("hm_bp:delegation:vollmacht_widerrufen_antwort", function(payload) sende("hm_bp:delegation:vollmacht_widerrufen_antwort", payload) end)
RegisterNetEvent("hm_bp:delegation:vollmachten_ergebnis", function(payload) sende("hm_bp:delegation:vollmachten_ergebnis", payload) end)

function HM_BP.Client.UIOeffnen(kontext)
  if uiOffen then return end
  uiOffen = true

  letzterStandort = (kontext and kontext.standortId) or nil

  SetNuiFocus(true, true)
  SendNUIMessage({ typ = "hm_bp:ui_oeffnen", kontext = kontext or {} })

  TriggerServerEvent("hm_bp:portal:daten_anfordern", { standortId = letzterStandort })
  TriggerServerEvent("hm_bp:kategorien:liste_anfordern", { standortId = letzterStandort })
  TriggerServerEvent("hm_bp:antraege:meine_anfordern", { limit = 25 })

  TriggerServerEvent("hm_bp:prioritaeten:liste_anfordern")
end

function HM_BP.Client.UISchliessen()
  if not uiOffen then return end
  TriggerServerEvent("hm_bp:justiz:sperren_alle_loesen")
  heartbeatStop()
  uiOffen = false
  SetNuiFocus(false, false)
  SendNUIMessage({ typ = "hm_bp:ui_schliessen" })
end