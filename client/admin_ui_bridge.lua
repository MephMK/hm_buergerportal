-- =============================================================
-- client/admin_ui_bridge.lua
--
-- Client-Bridge für den Admin-Bereich:
--   - NUI-Callbacks (synchron via Promise, wie FormularEditor)
--   - Server-Event-Handler leiten Antworten an die NUI weiter
--   - Panel wird nur geöffnet wenn Server das bestätigt
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Client = HM_BP.Client or {}

local function sende(typ, payload)
  SendNUIMessage({ typ = typ, payload = payload or {} })
end

-- Synchroner Server-Aufruf (Promise/Await-Muster wie FormularEditor)
local function adminAufruf(serverEvent, daten, antwortEvent)
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

-- -------------------------------------------------------
-- NUI-Callbacks (synchron)
-- -------------------------------------------------------

RegisterNUICallback("hm_bp:admin_panel_laden", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:panel_anfordern",
    daten or {},
    "hm_bp:admin:panel_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_sektion_laden", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:sektion_laden",
    daten or {},
    "hm_bp:admin:sektion_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_sektion_validieren", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:sektion_validieren",
    daten or {},
    "hm_bp:admin:sektion_validieren_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_sektion_speichern", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:sektion_speichern",
    daten or {},
    "hm_bp:admin:sektion_speichern_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_sektion_zuruecksetzen", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:sektion_zuruecksetzen",
    daten or {},
    "hm_bp:admin:sektion_zuruecksetzen_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_audit_laden", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:audit_laden",
    daten or {},
    "hm_bp:admin:audit_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_neuladen", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:neuladen",
    daten or {},
    "hm_bp:admin:neuladen_antwort"
  ))
end)

-- -------------------------------------------------------
-- CRUD-Callbacks
-- -------------------------------------------------------

RegisterNUICallback("hm_bp:admin_entity_speichern", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:entity_speichern",
    daten or {},
    "hm_bp:admin:entity_speichern_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_entity_loeschen", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:entity_loeschen",
    daten or {},
    "hm_bp:admin:entity_loeschen_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_kategorie_status", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:kategorie_status",
    daten or {},
    "hm_bp:admin:kategorie_status_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_formular_status", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:formular_status",
    daten or {},
    "hm_bp:admin:formular_status_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_modul_toggle", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:modul_toggle",
    daten or {},
    "hm_bp:admin:modul_toggle_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_webhook_test", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:webhook_test",
    daten or {},
    "hm_bp:admin:webhook_test_antwort"
  ))
end)

RegisterNUICallback("hm_bp:admin_sektion_validieren_v2", function(daten, cb)
  cb(adminAufruf(
    "hm_bp:admin:sektion_validieren_v2",
    daten or {},
    "hm_bp:admin:sektion_validieren_v2_antwort"
  ))
end)
