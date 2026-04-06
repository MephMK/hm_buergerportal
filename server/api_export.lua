-- =============================================================
-- server/api_export.lua
-- PR11: PDF-Export – Daten-Endpunkt + Discord-Benachrichtigung
--
-- Nur Justiz und Admin dürfen exportieren (export.pdf Permission).
-- Bürger haben keinen Zugang zu diesem Endpunkt.
-- Der Discord-Webhook wird serverseitig über WebhookService ausgelöst.
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ---------------------------------------------------------------
-- Hilfsfunktionen
-- ---------------------------------------------------------------

local function anzeigeNameAuflosen(quelle, fallback)
  local ss = HM_BP.Server.Dienste.SpielerService
  if ss and ss.AnzeigeNameAuflosen then
    return ss.AnzeigeNameAuflosen(quelle, fallback)
  end
  return fallback or "System"
end

local function emitWebhook(eventName, data)
  local ws = HM_BP.Server.Dienste.WebhookService
  if ws and ws.Emit then ws.Emit(eventName, data) end
end

-- ---------------------------------------------------------------
-- Endpunkt: PDF-Exportdaten anfordern
-- Prüft Berechtigung, lädt Antragsdaten, löst Discord-Webhook aus.
-- Antwort: hm_bp:export:pdf_daten_antwort
-- ---------------------------------------------------------------

RegisterNetEvent("hm_bp:export:pdf_daten_anfordern", function(payload)
  local quelle = source
  payload = payload or {}

  -- Modul-Check
  if Config.Module and Config.Module.Exporte == false then
    TriggerClientEvent("hm_bp:export:pdf_daten_antwort", quelle, {
      ok = false,
      fehler = { nachricht = "Export-Modul ist deaktiviert." }
    })
    return
  end

  -- Berechtigungsprüfung (nur Justiz/Admin)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle,
    HM_BP.Shared.Actions.EXPORT_PDF,
    {}
  )
  if not spieler then
    TriggerClientEvent("hm_bp:export:pdf_daten_antwort", quelle, {
      ok = false, fehler = err
    })
    return
  end

  -- Antrag-ID validieren
  local antragId = tonumber(payload.antragId)
  if not antragId then
    TriggerClientEvent("hm_bp:export:pdf_daten_antwort", quelle, {
      ok = false,
      fehler = { nachricht = "Keine gültige Antrags-ID angegeben." }
    })
    return
  end

  -- Antragsdaten via JustizAntragService laden (inkl. Zugriffscheck)
  local details, detailsErr = HM_BP.Server.Dienste.JustizAntragService.DetailsHolen(spieler, antragId)
  if not details then
    TriggerClientEvent("hm_bp:export:pdf_daten_antwort", quelle, {
      ok = false, fehler = detailsErr
    })
    return
  end

  local antrag = details.antrag or {}

  -- Anhänge laden (Justiz/Admin darf alle sehen)
  local anhaenge = {}
  local as = HM_BP.Server.Dienste.AttachmentService
  if as and as.Liste then
    local liste, _ = as.Liste(spieler, antragId)
    anhaenge = liste or {}
  end

  -- Payload (Formulareingaben des Bürgers) für den Export aufbereiten
  local payloadExport = nil
  if details.payload then
    local p = details.payload
    payloadExport = {
      fields_snapshot = p.fields_snapshot,
      answers         = p.answers,
    }
  end

  -- Sanitisierte Export-Daten zusammenstellen
  local exportDaten = {
    antrag = {
      id              = antrag.id,
      public_id       = antrag.public_id,
      status          = antrag.status,
      priority        = antrag.priority,
      citizen_name    = antrag.citizen_name,
      assigned_to_name = antrag.assigned_to_name,
      category_id     = antrag.category_id,
      form_id         = antrag.form_id,
      created_at      = antrag.created_at,
      updated_at      = antrag.updated_at,
    },
    -- Nur öffentliche und interne (Justiz-sichtbare) Timeline-Einträge
    timeline    = details.timeline or {},
    akteur_name = anzeigeNameAuflosen(quelle, spieler.name or "Unbekannt"),
    -- Formulareingaben des Bürgers
    payload     = payloadExport,
    -- Anhänge des Antrags
    anhaenge    = anhaenge,
  }

  -- Discord-Webhook: Exportereignis asynchron melden
  local akteurName = exportDaten.akteur_name
  local publicId   = tostring(antrag.public_id or "–")

  emitWebhook("pdf_export", {
    akteur_name  = akteurName,
    public_id    = publicId,
    aktenzeichen = publicId,
  })

  -- Daten zurück an den Client (NUI generiert daraus das PDF)
  TriggerClientEvent("hm_bp:export:pdf_daten_antwort", quelle, {
    ok    = true,
    daten = exportDaten,
  })
end)
