-- =============================================================
-- server/api_audit.lua  (PR12 – Audit-Härtung)
--
-- Audit-Log-API für Admin und Justiz-Leitung.
-- Einträge sind append-only – kein Bearbeiten oder Löschen via API.
--
-- Events:
--   hm_bp:audit:liste_laden  →  hm_bp:audit:liste_antwort
--     Payload: { filter?, seite?, pro_seite? }
--     filter: {
--       von              "YYYY-MM-DD HH:MM:SS" oder "YYYY-MM-DD"
--       bis              "YYYY-MM-DD HH:MM:SS" oder "YYYY-MM-DD"
--       actor_name       string (Teilstring-Suche)
--       aktion           string (exakt)
--       target_public_id string (exakt)
--       request_id       string (exakt)
--     }
--
-- Zugriffsregel:
--   Admin (AuthService.IstAdmin)    → Vollzugriff, actor_identifier sichtbar
--   Justiz-Leitung (IstLeitung)     → Lesezugriff, actor_identifier redaktiert
--   Alle anderen                    → KEINE_BERECHTIGUNG
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ----------------------------------------------------------------
-- Hilfsfunktion: Zugriffsprüfung
-- ----------------------------------------------------------------

local function pruefeAuditZugriff(quelle)
  -- Spieler laden
  local spieler, err = HM_BP.Server.Dienste.AuthService.SpielerLaden(quelle)
  if not spieler then return nil, false, err end

  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  spieler.rolle = rolle

  -- Admin hat immer Zugriff (inklusive actor_identifier)
  if rolle == "admin" then
    return spieler, true, nil
  end

  -- Justiz-Leitung (grade >= Config.Workflows.Leitung.MinGrade)
  local ws = HM_BP.Server.Dienste.WorkflowService
  if ws and ws.IstLeitung and ws.IstLeitung(spieler) then
    local leitungDarf = (Config.Audit == nil) or (Config.Audit.LeitungDarfLesen ~= false)
    if leitungDarf then
      return spieler, false, nil  -- false = actor_identifier redaktiert
    end
  end

  return nil, false, {
    code     = (HM_BP.Shared and HM_BP.Shared.Errors and HM_BP.Shared.Errors.NOT_AUTHORIZED)
               or "KEINE_BERECHTIGUNG",
    nachricht = "Nur Administratoren und Justiz-Leitung können Audit-Logs einsehen."
  }
end

-- ----------------------------------------------------------------
-- Event: Audit-Log-Liste laden (mit Filter + Pagination)
-- ----------------------------------------------------------------

RegisterNetEvent("hm_bp:audit:liste_laden", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, zeigeIdentifier, err = pruefeAuditZugriff(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:audit:liste_antwort", quelle, {
      ok = false, fehler = err
    })
    return
  end

  -- Rate-Limit
  local spam = HM_BP.Server.Dienste.AntiSpamService
  if spam and spam.PruefeRateLimit then
    local ok, errSpam = spam.PruefeRateLimit(spieler, "api:audit.view")
    if not ok then
      TriggerClientEvent("hm_bp:audit:liste_antwort", quelle, {
        ok = false, fehler = errSpam
      })
      return
    end
  end

  -- Filter validieren (nur erlaubte Schlüssel)
  local filter = {}
  local rawFilter = payload.filter or {}
  if type(rawFilter.von)              == "string" then filter.von              = rawFilter.von end
  if type(rawFilter.bis)              == "string" then filter.bis              = rawFilter.bis end
  if type(rawFilter.actor_name)       == "string" then filter.actor_name       = rawFilter.actor_name end
  if type(rawFilter.aktion)           == "string" then filter.aktion           = rawFilter.aktion end
  if type(rawFilter.target_public_id) == "string" then filter.target_public_id = rawFilter.target_public_id end
  if type(rawFilter.request_id)       == "string" then filter.request_id       = rawFilter.request_id end

  local seite    = tonumber(payload.seite)    or 1
  local proSeite = tonumber(payload.pro_seite) or 50

  local svc = HM_BP.Server.Dienste.AuditService
  if not svc then
    TriggerClientEvent("hm_bp:audit:liste_antwort", quelle, {
      ok = false, fehler = { nachricht = "AuditService nicht verfügbar." }
    })
    return
  end

  local result = svc.Liste(filter, seite, proSeite, zeigeIdentifier)

  -- Antwortobjekt aufbauen
  TriggerClientEvent("hm_bp:audit:liste_antwort", quelle, {
    ok        = result.ok,
    fehler    = result.fehler and { nachricht = result.fehler } or nil,
    eintraege = result.eintraege or {},
    gesamt    = result.gesamt or 0,
    seite     = result.seite or seite,
    pro_seite = result.pro_seite or proSeite,
    ist_admin = zeigeIdentifier,
  })
end)
