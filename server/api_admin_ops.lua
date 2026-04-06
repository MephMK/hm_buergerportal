-- =============================================================
-- server/api_admin_ops.lua
--
-- Server-API für Admin-Operative Verwaltung (PR6).
-- Events (Client → Server → Client):
--   hm_bp:admin_ops:suchen               → hm_bp:admin_ops:suchen_antwort
--   hm_bp:admin_ops:verschieben          → hm_bp:admin_ops:verschieben_antwort
--   hm_bp:admin_ops:wiederherstellen     → hm_bp:admin_ops:wiederherstellen_antwort
--   hm_bp:admin_ops:hartloeschen         → hm_bp:admin_ops:hartloeschen_antwort
--   hm_bp:admin_ops:status_override      → hm_bp:admin_ops:status_override_antwort
--   hm_bp:admin_ops:im_auftrag_erstellen → hm_bp:admin_ops:im_auftrag_erstellen_antwort
--
-- Sicherheit:
--   • Alle Endpunkte prüfen Admin-Berechtigung (Job+Grade via Config.Kern.Admin).
--   • im_auftrag_erstellen erlaubt zusätzlich Justiz-Rolle.
--   • Identifier werden NICHT an den Client zurückgegeben.
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

local function ops()
  return HM_BP.Server.Dienste.AdminOpsService
end

local function anzeigeNameAuflosen(quelle, fallback)
  local ss = HM_BP.Server.Dienste.SpielerService
  if ss and ss.AnzeigeNameAuflosen then
    return ss.AnzeigeNameAuflosen(quelle, fallback)
  end
  return fallback or "System"
end

--- Admin-Prüfung (identisch zu api_admin.lua / api_admin_crud.lua)
local function pruefeAdmin(quelle, aktion)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, aktion or HM_BP.Shared.Actions.ADMIN_PANEL_OPEN, {}
  )
  if not spieler then return nil, err end

  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  if rolle ~= "admin" then
    return nil, {
      code     = HM_BP.Shared.Errors.NOT_AUTHORIZED,
      nachricht = "Nur Administratoren dürfen auf den Admin-Bereich zugreifen."
    }
  end
  spieler.rolle = rolle
  return spieler, nil
end

--- Admin- oder Justiz-Prüfung (für im_auftrag_erstellen)
local function pruefeAdminOderJustiz(quelle)
  local spieler, err = HM_BP.Server.Middleware.PruefeRecht(
    quelle, HM_BP.Shared.Actions.SUBMISSIONS_VIEW_ALL, {}
  )
  if not spieler then return nil, err end

  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  if rolle ~= "admin" and rolle ~= "justiz" then
    return nil, {
      code     = HM_BP.Shared.Errors.NOT_AUTHORIZED,
      nachricht = "Keine Berechtigung für diese Aktion."
    }
  end
  spieler.rolle = rolle
  return spieler, nil
end

-- ----------------------------------------------------------------
-- hm_bp:admin_ops:suchen
-- Admin-übergreifende Suche (kein Kategorie-Filter nötig).
-- ----------------------------------------------------------------
RegisterNetEvent("hm_bp:admin_ops:suchen", function(payload)
  local quelle = source

  local spieler, err = pruefeAdmin(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:admin_ops:suchen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  local result, err2 = ops().AdminSuchen(spieler, payload or {})
  if not result then
    TriggerClientEvent("hm_bp:admin_ops:suchen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:admin_ops:suchen_antwort", quelle, { ok = true, res = result })
end)

-- ----------------------------------------------------------------
-- hm_bp:admin_ops:verschieben
-- Ändert Kategorie und/oder Formular eines Antrags.
-- ----------------------------------------------------------------
RegisterNetEvent("hm_bp:admin_ops:verschieben", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:admin_ops:verschieben_antwort", quelle, { ok = false, fehler = err })
    return
  end

  spieler.name = anzeigeNameAuflosen(quelle, spieler.name)

  local result, err2 = ops().Verschieben(
    spieler,
    tonumber(payload.antragId),
    payload.neuKategorieId,
    payload.neuFormularId,
    payload.grund
  )
  if not result then
    TriggerClientEvent("hm_bp:admin_ops:verschieben_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:admin_ops:verschieben_antwort", quelle, { ok = true })
end)

-- ----------------------------------------------------------------
-- hm_bp:admin_ops:wiederherstellen
-- Hebt die Archivierung eines Antrags auf.
-- ----------------------------------------------------------------
RegisterNetEvent("hm_bp:admin_ops:wiederherstellen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:admin_ops:wiederherstellen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  spieler.name = anzeigeNameAuflosen(quelle, spieler.name)

  local result, err2 = ops().Wiederherstellen(
    spieler,
    tonumber(payload.antragId),
    payload.grund
  )
  if not result then
    TriggerClientEvent("hm_bp:admin_ops:wiederherstellen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:admin_ops:wiederherstellen_antwort", quelle, { ok = true })
end)

-- ----------------------------------------------------------------
-- hm_bp:admin_ops:hartloeschen
-- Löscht einen Antrag unwiderruflich (Hard Delete).
-- ----------------------------------------------------------------
RegisterNetEvent("hm_bp:admin_ops:hartloeschen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:admin_ops:hartloeschen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  spieler.name = anzeigeNameAuflosen(quelle, spieler.name)

  local result, err2 = ops().HartLoeschen(
    spieler,
    tonumber(payload.antragId),
    payload.grund
  )
  if not result then
    TriggerClientEvent("hm_bp:admin_ops:hartloeschen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:admin_ops:hartloeschen_antwort", quelle, { ok = true })
end)

-- ----------------------------------------------------------------
-- hm_bp:admin_ops:status_override
-- Setzt den Status direkt (ohne Workflow-Regeln).
-- ----------------------------------------------------------------
RegisterNetEvent("hm_bp:admin_ops:status_override", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdmin(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:admin_ops:status_override_antwort", quelle, { ok = false, fehler = err })
    return
  end

  spieler.name = anzeigeNameAuflosen(quelle, spieler.name)

  local result, err2 = ops().StatusUeberschreiben(
    spieler,
    tonumber(payload.antragId),
    payload.neuerStatus,
    payload.grund
  )
  if not result then
    TriggerClientEvent("hm_bp:admin_ops:status_override_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:admin_ops:status_override_antwort", quelle, { ok = true })
end)

-- ----------------------------------------------------------------
-- hm_bp:admin_ops:im_auftrag_erstellen
-- Erstellt einen Antrag für einen online befindlichen Bürger
-- (Suche ausschließlich per Ingame-Name).
-- Erlaubt: Admin oder Justiz.
-- ----------------------------------------------------------------
RegisterNetEvent("hm_bp:admin_ops:im_auftrag_erstellen", function(payload)
  local quelle = source
  payload = payload or {}

  local spieler, err = pruefeAdminOderJustiz(quelle)
  if not spieler then
    TriggerClientEvent("hm_bp:admin_ops:im_auftrag_erstellen_antwort", quelle, { ok = false, fehler = err })
    return
  end

  spieler.name = anzeigeNameAuflosen(quelle, spieler.name)

  local result, err2 = ops().ImAuftragErstellen(
    spieler,
    payload.zielIngameName,
    payload.formularId,
    payload.antworten,
    payload.grund
  )
  if not result then
    TriggerClientEvent("hm_bp:admin_ops:im_auftrag_erstellen_antwort", quelle, { ok = false, fehler = err2 })
    return
  end

  TriggerClientEvent("hm_bp:admin_ops:im_auftrag_erstellen_antwort", quelle, { ok = true, res = result })
end)
