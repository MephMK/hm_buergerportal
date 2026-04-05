-- =============================================================
-- server/dienste/workflow_service.lua
--
-- Workflow-Engine (PR7):
--   - Leitung-Erkennung  (IstLeitung)
--   - Erlaubte Statusübergänge (UebergangErlaubt)
--   - SLA-Initialisierung beim Einreichen (SlaInitialisieren)
--   - SLA-Tick: überprüft aktive Anträge, löst Eskalation aus
--   - Eskalation: weist an Leitung zu, schreibt Timeline + Audit
--   - SLA pausieren/fortsetzen (nur Leitung)
-- =============================================================

HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local WorkflowService = {}

-- -------------------------------------------------------
-- Hilfsfunktionen
-- -------------------------------------------------------

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function leitungMinGrade()
  return tonumber(Config.Workflows and Config.Workflows.Leitung and Config.Workflows.Leitung.MinGrade) or 29
end

local function justizJob()
  return (Config.Kern and Config.Kern.Jobs and Config.Kern.Jobs.Justiz) or "doj"
end

-- -------------------------------------------------------
-- Leitung-Prüfung
-- -------------------------------------------------------

---Gibt true zurück, wenn der Spieler Justiz-Job hat und Grade >= LeitungMinGrade.
function WorkflowService.IstLeitung(spieler)
  if not spieler or not spieler.job then return false end
  if spieler.job.name ~= justizJob() then return false end
  return (tonumber(spieler.job.grade) or 0) >= leitungMinGrade()
end

-- -------------------------------------------------------
-- Statusübergang-Validierung
-- -------------------------------------------------------

---Prüft, ob der Übergang vonStatus → nachStatus für eine Kategorie erlaubt ist.
---Reihenfolge:
---  1. Kategorie-spezifisches workflow.erlaubteFolgeStatus  (spezifischer)
---  2. Globales Config.Status.Liste[vonStatus].erlaubteFolgeStatus
---  3. Kein Eintrag → erlaubt (kein Zwang)
---@return boolean
function WorkflowService.UebergangErlaubt(kategorieId, vonStatus, nachStatus)
  if type(vonStatus) ~= "string" or type(nachStatus) ~= "string" then return true end

  -- 1. Kategorie-spezifisch
  local k = Config.Kategorien
    and Config.Kategorien.Liste
    and Config.Kategorien.Liste[kategorieId]
  if k and k.workflow and type(k.workflow.erlaubteFolgeStatus) == "table" then
    local folge = k.workflow.erlaubteFolgeStatus[vonStatus]
    if type(folge) == "table" then
      for _, s in ipairs(folge) do
        if s == nachStatus then return true end
      end
      return false  -- Kategorie hat Regeln für diesen Status → kein Match
    end
    -- Kein Eintrag für vonStatus → kein Zwang auf Kategorieebene, weiter prüfen
  end

  -- 2. Globaler Status-Config
  if Config.Status and Config.Status.Liste then
    for _, s in pairs(Config.Status.Liste) do
      if s and s.id == vonStatus and type(s.erlaubteFolgeStatus) == "table" then
        for _, fs in ipairs(s.erlaubteFolgeStatus) do
          if fs == nachStatus then return true end
        end
        return false  -- Globale Regel vorhanden → kein Match
      end
    end
  end

  -- 3. Kein Zwang
  return true
end

-- -------------------------------------------------------
-- SLA-Initialisierung (beim Einreichen)
-- -------------------------------------------------------

---Berechnet sla_due_at und schreibt es für einen frisch eingereichten Antrag.
---Wird von AntragService aufgerufen.
function WorkflowService.SlaInitialisieren(antragId, kategorieId)
  local defaultStunden = tonumber(Config.Workflows and Config.Workflows.Sla and Config.Workflows.Sla.DefaultSlaHours) or 48

  local k = Config.Kategorien
    and Config.Kategorien.Liste
    and Config.Kategorien.Liste[kategorieId]
  local stunden = (k and k.workflow and tonumber(k.workflow.sla_hours)) or defaultStunden

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET sla_due_at = DATE_ADD(created_at, INTERVAL ? HOUR),
        last_status_change_at = created_at
    WHERE id = ? AND sla_due_at IS NULL
  ]], { stunden, antragId })
end

-- -------------------------------------------------------
-- SLA-Tick
-- -------------------------------------------------------

---Prüft aktive Anträge auf SLA-Überschreitung und eskaliert ggf.
---Wird alle Config.Workflows.Sla.TickIntervalSekunden aufgerufen.
function WorkflowService.SlaTick()
  local eskalation = Config.Workflows and Config.Workflows.Eskalation
  if not (eskalation and eskalation.Aktiviert) then return end

  local overdue = HM_BP.Server.Datenbank.Alle([[
    SELECT id, category_id, citizen_name, public_id
    FROM hm_bp_submissions
    WHERE deleted_at IS NULL
      AND archived_at IS NULL
      AND sla_due_at IS NOT NULL
      AND sla_due_at <= UTC_TIMESTAMP()
      AND (sla_paused_at IS NULL)
      AND (escalated_at IS NULL)
      AND needs_leitung = 0
    LIMIT 50
  ]], {})

  for _, a in ipairs(overdue or {}) do
    local ok, err = pcall(function()
      WorkflowService.Eskalieren(a.id, a)
    end)
    if not ok then
      print(("[hm_buergerportal][WorkflowService] Eskalierungsfehler Antrag %s: %s"):format(
        tostring(a.id), tostring(err)))
    end
  end
end

-- -------------------------------------------------------
-- Eskalation
-- -------------------------------------------------------

---Eskaliert einen Antrag an Leitung: setzt needs_leitung=1, weist zu, Timeline+Audit.
function WorkflowService.Eskalieren(antragId, antragInfo)
  -- Antrag nachladen, falls kein antragInfo übergeben
  if not antragInfo then
    antragInfo = HM_BP.Server.Datenbank.Einzel([[
      SELECT id, category_id, status, citizen_name, public_id, escalated_at, needs_leitung
      FROM hm_bp_submissions WHERE id = ? AND deleted_at IS NULL
    ]], { antragId })
  end

  if not antragInfo then return end
  if antragInfo.escalated_at then return end  -- bereits eskaliert (DATETIME ist NIL wenn nicht gesetzt)

  -- Eskalations-Flag setzen
  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET needs_leitung = 1,
        escalated_at  = UTC_TIMESTAMP(),
        due_state     = 'overdue'
    WHERE id = ?
  ]], { antragId })

  -- Versuche, Leitung-Mitglied zu ermitteln
  local lGrade = leitungMinGrade()
  local lJob   = justizJob()

  local leitungMitglied = HM_BP.Server.Datenbank.Einzel([[
    SELECT identifier, display_name
    FROM hm_bp_staff_directory
    WHERE job = ? AND grade >= ?
    ORDER BY last_seen_at DESC
    LIMIT 1
  ]], { lJob, lGrade })

  if leitungMitglied then
    -- Zuweisen, aber nur wenn noch nicht zugewiesen oder bisher keiner übernommen hat
    HM_BP.Server.Datenbank.Ausfuehren([[
      UPDATE hm_bp_submissions
      SET assigned_to_identifier = ?,
          assigned_to_name       = ?
      WHERE id = ?
        AND assigned_to_identifier IS NULL
    ]], {
      leitungMitglied.identifier,
      leitungMitglied.display_name or leitungMitglied.identifier,
      antragId
    })
  end

  local eskalierungsEmpfaenger = leitungMitglied
    and (leitungMitglied.display_name or leitungMitglied.identifier)
    or "Leitung-Queue"

  -- Timeline-Eintrag
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', 'system', 'System', ?)
  ]], {
    antragId,
    json.encode({
      text           = "SLA überschritten – Eskalation an Leitung.",
      eskaliert_an   = eskalierungsEmpfaenger,
      zeit           = utcJetztIso(),
    })
  })

  -- Audit-Log
  HM_BP.Server.Dienste.AuditService.Log(
    "sla.eskaliert",
    nil,
    "submission",
    tostring(antragId),
    {
      kategorie    = antragInfo.category_id,
      public_id    = antragInfo.public_id,
      eskaliert_an = leitungMitglied and leitungMitglied.identifier or nil,
      zeit         = utcJetztIso(),
    }
  )

  -- Ingame-Benachrichtigung an online Leitung
  WorkflowService.LeitungBenachrichtigen(antragId, antragInfo)
end

-- -------------------------------------------------------
-- Ingame-Benachrichtigung an Leitung
-- -------------------------------------------------------

function WorkflowService.LeitungBenachrichtigen(antragId, antragInfo)
  local lGrade = leitungMinGrade()
  local lJob   = justizJob()

  local ok, esx = pcall(function()
    return exports['es_extended']:getSharedObject()
  end)
  if not ok or not esx then return end

  local players = esx.GetPlayers()
  for _, src in ipairs(players) do
    local xPlayer = esx.GetPlayerFromId(src)
    if xPlayer then
      local job = xPlayer.getJob and xPlayer.getJob() or nil
      if job and job.name == lJob and (tonumber(job.grade) or 0) >= lGrade then
        TriggerClientEvent("hm_bp:workflow:eskalierung_benachrichtigung", src, {
          antragId  = antragId,
          publicId  = antragInfo and antragInfo.public_id or nil,
          buerger   = antragInfo and antragInfo.citizen_name or nil,
          kategorie = antragInfo and antragInfo.category_id or nil,
        })
      end
    end
  end
end

-- -------------------------------------------------------
-- SLA pausieren (nur Leitung)
-- -------------------------------------------------------

function WorkflowService.SlaPausieren(spieler, antragId, grund)
  if not WorkflowService.IstLeitung(spieler)
    and not HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return false, {
      code     = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG,
      nachricht = "Nur Leitung (Grade ≥ " .. tostring(leitungMinGrade()) .. ") darf die SLA pausieren."
    }
  end

  local a = HM_BP.Server.Datenbank.Einzel(
    "SELECT id, sla_paused_at FROM hm_bp_submissions WHERE id = ? AND deleted_at IS NULL",
    { antragId })
  if not a then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if a.sla_paused_at then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "SLA ist bereits pausiert." }
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET sla_paused_at = UTC_TIMESTAMP(),
        sla_paused_by = ?
    WHERE id = ?
  ]], { spieler.identifier, antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({ text = "SLA pausiert.", grund = grund or "" })
  })

  HM_BP.Server.Dienste.AuditService.Log(
    "sla.pausiert", spieler, "submission", tostring(antragId), { grund = grund })

  return true, nil
end

-- -------------------------------------------------------
-- SLA fortsetzen (nur Leitung)
-- -------------------------------------------------------

function WorkflowService.SlaFortsetzen(spieler, antragId, grund)
  if not WorkflowService.IstLeitung(spieler)
    and not HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return false, {
      code     = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG,
      nachricht = "Nur Leitung (Grade ≥ " .. tostring(leitungMinGrade()) .. ") darf die SLA fortsetzen."
    }
  end

  local a = HM_BP.Server.Datenbank.Einzel(
    "SELECT id, sla_paused_at, sla_due_at FROM hm_bp_submissions WHERE id = ? AND deleted_at IS NULL",
    { antragId })
  if not a then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.NICHT_GEFUNDEN, nachricht = "Antrag nicht gefunden." }
  end
  if not a.sla_paused_at then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT, nachricht = "SLA ist nicht pausiert." }
  end

  -- Verlängere sla_due_at um die pausierte Zeitspanne
  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET sla_due_at   = DATE_ADD(sla_due_at,
                         INTERVAL TIMESTAMPDIFF(SECOND, sla_paused_at, UTC_TIMESTAMP()) SECOND),
        sla_paused_at = NULL,
        sla_paused_by = NULL
    WHERE id = ?
  ]], { antragId })

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_timeline
      (submission_id, entry_type, visibility, author_identifier, author_name, content)
    VALUES (?, 'system', 'internal', ?, ?, ?)
  ]], {
    antragId, spieler.identifier, spieler.name,
    json.encode({ text = "SLA fortgesetzt.", grund = grund or "" })
  })

  HM_BP.Server.Dienste.AuditService.Log(
    "sla.fortgesetzt", spieler, "submission", tostring(antragId), { grund = grund })

  return true, nil
end

-- -------------------------------------------------------
-- SLA Erste-Bearbeitung – Tick (PR13)
-- -------------------------------------------------------

---Konfigurationshelfer: Frist bis erste Bearbeitung in Stunden.
local function erstBearbeitungStunden()
  return tonumber(Config.SLA and Config.SLA.ErsteBearbeitungStunden) or 24
end

---Konfigurationshelfer: Reminder-Intervall in Stunden.
local function reminderIntervalStunden()
  return tonumber(Config.SLA and Config.SLA.ReminderIntervalStunden) or 6
end

---System-Spieler-Kontext für Audit-Logs (SLA-System).
local function systemSpieler()
  return {
    identifier = "system",
    name       = "System (SLA)",
    job        = nil,
    quelle     = nil,
  }
end

---Sendet den antrag_escalation-Webhook für einen Antrag (Eskalation oder Reminder).
local function eskalationsWebhookSenden(antragInfo, istReminder)
  if not HM_BP.Server.Dienste.WebhookService then return end
  HM_BP.Server.Dienste.WebhookService.Emit("antrag_escalation", {
    public_id    = antragInfo.public_id,
    aktenzeichen = antragInfo.public_id,
    akteur_name  = "System (SLA)",
    category_id  = antragInfo.category_id,
    citizen_name = antragInfo.citizen_name,
    text         = istReminder
      and ("Erinnerung: Antrag %s wartet seit mehr als %dh auf erste Bearbeitung."):format(
            tostring(antragInfo.public_id or antragInfo.id), erstBearbeitungStunden())
      or  ("Antrag %s hat die %dh-Frist für die erste Bearbeitung überschritten."):format(
            tostring(antragInfo.public_id or antragInfo.id), erstBearbeitungStunden()),
  })
end

---Prüft Anträge auf Überschreitung der Erste-Bearbeitungs-SLA und
---löst Eskalation oder Reminder aus.
---
--- Eskalation (einmalig):
---   created_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL N HOUR)
---   AND first_staff_comment_at IS NULL
---   AND escalated = 0
---
--- Reminder (periodisch):
---   escalated = 1
---   AND first_staff_comment_at IS NULL
---   AND last_escalation_reminder_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL N HOUR)
function WorkflowService.SlaErstBearbeitungTick()
  local slaCfg = Config.SLA
  if not slaCfg or slaCfg.Aktiviert == false then return end

  local fristStunden    = erstBearbeitungStunden()
  local reminderStunden = reminderIntervalStunden()

  -- 1. Neue Eskalationen: Frist überschritten, noch nicht eskaliert
  -- Rewritten to use DATE_SUB so the index on (escalated, created_at) can be used.
  local neueEskalationen = HM_BP.Server.Datenbank.Alle([[
    SELECT id, public_id, category_id, citizen_name
    FROM hm_bp_submissions
    WHERE deleted_at IS NULL
      AND archived_at IS NULL
      AND first_staff_comment_at IS NULL
      AND escalated = 0
      AND created_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL ? HOUR)
    LIMIT 50
  ]], { fristStunden })

  for _, a in ipairs(neueEskalationen or {}) do
    local ok, err = pcall(function()
      -- Eskalations-Flag setzen
      HM_BP.Server.Datenbank.Ausfuehren([[
        UPDATE hm_bp_submissions
        SET escalated = 1,
            escalated_at = UTC_TIMESTAMP(),
            last_escalation_reminder_at = UTC_TIMESTAMP()
        WHERE id = ? AND escalated = 0
      ]], { a.id })

      -- Timeline-Eintrag (intern)
      HM_BP.Server.Datenbank.Ausfuehren([[
        INSERT INTO hm_bp_submission_timeline
          (submission_id, entry_type, visibility, author_identifier, author_name, content)
        VALUES (?, 'system', 'internal', 'system', 'System (SLA)', ?)
      ]], {
        a.id,
        json.encode({
          text      = ("SLA-Eskalation: Antrag hat die %dh-Frist für die erste Bearbeitung überschritten."):format(fristStunden),
          frist_h   = fristStunden,
          zeit      = utcJetztIso(),
        })
      })

      -- Discord-Webhook (separater antrag_escalation-Key)
      eskalationsWebhookSenden(a, false)

      -- Audit-Log
      local reqId = HM_BP.Server.Dienste.AuditService.GenerateRequestId()
      HM_BP.Server.Dienste.AuditService.Log(
        "sla.erst_bearbeitung.eskaliert",
        nil,
        "submission",
        tostring(a.id),
        {
          frist_stunden = fristStunden,
          public_id     = a.public_id,
          zeit          = utcJetztIso(),
        },
        {
          request_id         = reqId,
          actor_source       = "sla",
          actor_display_name = "System (SLA)",
          target_public_id   = a.public_id,
          target_category_id = a.category_id,
        }
      )
    end)
    if not ok then
      print(("[hm_buergerportal][WorkflowService] SlaErstBearbeitungTick Eskalationsfehler Antrag %s: %s"):format(
        tostring(a.id), tostring(err)))
    end
  end

  -- 2. Reminder: bereits eskaliert, aber immer noch keine erste Bearbeitung
  -- Rewritten to use DATE_SUB so the index on last_escalation_reminder_at can be used.
  local reminders = HM_BP.Server.Datenbank.Alle([[
    SELECT id, public_id, category_id, citizen_name
    FROM hm_bp_submissions
    WHERE deleted_at IS NULL
      AND archived_at IS NULL
      AND first_staff_comment_at IS NULL
      AND escalated = 1
      AND last_escalation_reminder_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL ? HOUR)
    LIMIT 50
  ]], { reminderStunden })

  for _, a in ipairs(reminders or {}) do
    local ok, err = pcall(function()
      -- Reminder-Zeitstempel aktualisieren
      HM_BP.Server.Datenbank.Ausfuehren([[
        UPDATE hm_bp_submissions
        SET last_escalation_reminder_at = UTC_TIMESTAMP()
        WHERE id = ?
      ]], { a.id })

      -- Timeline-Eintrag (intern)
      HM_BP.Server.Datenbank.Ausfuehren([[
        INSERT INTO hm_bp_submission_timeline
          (submission_id, entry_type, visibility, author_identifier, author_name, content)
        VALUES (?, 'system', 'internal', 'system', 'System (SLA)', ?)
      ]], {
        a.id,
        json.encode({
          text        = "SLA-Erinnerung: Antrag wartet weiterhin auf erste Bearbeitung.",
          reminder_h  = reminderStunden,
          zeit        = utcJetztIso(),
        })
      })

      -- Discord-Webhook (Reminder)
      eskalationsWebhookSenden(a, true)

      -- Audit-Log
      local reqId = HM_BP.Server.Dienste.AuditService.GenerateRequestId()
      HM_BP.Server.Dienste.AuditService.Log(
        "sla.erst_bearbeitung.reminder",
        nil,
        "submission",
        tostring(a.id),
        {
          reminder_intervall_h = reminderStunden,
          public_id            = a.public_id,
          zeit                 = utcJetztIso(),
        },
        {
          request_id         = reqId,
          actor_source       = "sla",
          actor_display_name = "System (SLA)",
          target_public_id   = a.public_id,
          target_category_id = a.category_id,
        }
      )
    end)
    if not ok then
      print(("[hm_buergerportal][WorkflowService] SlaErstBearbeitungTick Reminder-Fehler Antrag %s: %s"):format(
        tostring(a.id), tostring(err)))
    end
  end
end

-- -------------------------------------------------------
-- Overdue-Aktualisierung (Batch)
-- -------------------------------------------------------

---Aktualisiert due_state für alle Anträge ohne Sperre auf Basis von sla_due_at.
---Läuft zusammen mit dem SLA-Tick. Setzt due_state = 'overdue' wenn
---sla_due_at < NOW() und SLA nicht pausiert; setzt 'normal' zurück wenn nicht mehr überfällig.
function WorkflowService.OverdueAktualisieren()
  -- Überfällige Anträge auf 'overdue' setzen
  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET due_state = 'overdue'
    WHERE deleted_at IS NULL
      AND archived_at IS NULL
      AND sla_due_at IS NOT NULL
      AND sla_due_at < UTC_TIMESTAMP()
      AND sla_paused_at IS NULL
      AND due_state != 'overdue'
  ]], {})

  -- Nicht mehr überfällige Anträge auf 'normal' zurücksetzen
  -- (z.B. nach SLA-Verlängerung oder manueller Korrektur)
  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_submissions
    SET due_state = 'normal'
    WHERE deleted_at IS NULL
      AND archived_at IS NULL
      AND due_state = 'overdue'
      AND (
        sla_due_at IS NULL
        OR sla_due_at >= UTC_TIMESTAMP()
        OR sla_paused_at IS NOT NULL
      )
  ]], {})
end

HM_BP.Server.Dienste.WorkflowService = WorkflowService
