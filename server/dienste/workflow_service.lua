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
  return tonumber(Config.Workflow and Config.Workflow.LeitungMinGrade) or 29
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
  local defaultStunden = tonumber(Config.Workflow and Config.Workflow.DefaultSlaHours) or 48

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
---Wird alle Config.Workflow.TickIntervalSekunden aufgerufen.
function WorkflowService.SlaTick()
  local eskalierung = Config.Workflow and Config.Workflow.Eskalierung
  if not (eskalierung and eskalierung.Aktiviert) then return end

  local overdue = HM_BP.Server.Datenbank.Alle([[
    SELECT id, category_id, citizen_name, public_id
    FROM hm_bp_submissions
    WHERE deleted_at IS NULL
      AND archived_at IS NULL
      AND sla_due_at IS NOT NULL
      AND sla_due_at <= UTC_TIMESTAMP()
      AND (sla_paused_at IS NULL OR sla_paused_at = '')
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
      SELECT id, category_id, citizen_name, public_id, escalated_at, needs_leitung
      FROM hm_bp_submissions WHERE id = ? AND deleted_at IS NULL
    ]], { antragId })
  end

  if not antragInfo then return end
  if antragInfo.escalated_at and antragInfo.escalated_at ~= "" then return end

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
    HM_BP.Server.Datenbank.Ausfuehren([[
      UPDATE hm_bp_submissions
      SET assigned_to_identifier = ?,
          assigned_to_name       = ?
      WHERE id = ?
        AND (assigned_to_identifier IS NULL OR needs_leitung = 1)
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
  if a.sla_paused_at and a.sla_paused_at ~= "" then
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
  if not a.sla_paused_at or a.sla_paused_at == "" then
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

HM_BP.Server.Dienste.WorkflowService = WorkflowService
