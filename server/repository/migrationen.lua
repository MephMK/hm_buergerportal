HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

HM_BP.Server.Migrationen = {}

local function migrationsTabelleSicherstellen()
  HM_BP.Server.Datenbank.Ausfuehren([[
    CREATE TABLE IF NOT EXISTS hm_bp_migrations (
      id VARCHAR(64) PRIMARY KEY,
      applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])
end

local function migrationVorhanden(id)
  local zeile = HM_BP.Server.Datenbank.Einzel("SELECT id FROM hm_bp_migrations WHERE id = ?", { id })
  return zeile ~= nil
end

-- Akzeptiert entweder einen SQL-String oder eine Funktion für komplexe Migrationen.
local function migrationAnwenden(id, sqlOderFn)
  if migrationVorhanden(id) then return end
  if type(sqlOderFn) == "function" then
    sqlOderFn()
  else
    HM_BP.Server.Datenbank.Ausfuehren(sqlOderFn)
  end
  HM_BP.Server.Datenbank.Ausfuehren("INSERT INTO hm_bp_migrations (id) VALUES (?)", { id })
  print(("[hm_buergerportal] Migration angewendet: %s"):format(id))
end

-- Führt mehrere CREATE TABLE-Statements einzeln aus (Multi-Statement-Kompatibilität).
-- tabellen: Liste von { tabellenName, sql } Paaren.
local function tabellenErstellen(migId, tabellen)
  for _, t in ipairs(tabellen) do
    local ok, err = pcall(HM_BP.Server.Datenbank.Ausfuehren, t[2])
    if not ok then
      print(("[hm_buergerportal] FEHLER bei %s – Tabelle '%s': %s"):format(migId, t[1], tostring(err)))
      error(err)
    end
  end
end
local function spalteFehlt(tabellenName, spaltenName)
  local zeile = HM_BP.Server.Datenbank.Einzel(
    "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?",
    { tabellenName, spaltenName }
  )
  return zeile == nil
end

-- Prüft ob ein Index in einer Tabelle fehlt (via INFORMATION_SCHEMA, MySQL/MariaDB-kompatibel).
local function indexFehlt(tabellenName, indexName)
  local zeile = HM_BP.Server.Datenbank.Einzel(
    "SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND INDEX_NAME = ? LIMIT 1",
    { tabellenName, indexName }
  )
  return zeile == nil
end

function HM_BP.Server.Migrationen.AlleAusfuehren()
  migrationsTabelleSicherstellen()

  -- v1_core_tables: Jede Tabelle wird in einem eigenen DB-Call erstellt (Multi-Statement-Kompatibilität).
  migrationAnwenden("v1_core_tables", function()
    tabellenErstellen("v1_core_tables", {
      { "hm_bp_categories", [[
        CREATE TABLE IF NOT EXISTS hm_bp_categories (
          id VARCHAR(64) PRIMARY KEY,
          data JSON NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_forms", [[
        CREATE TABLE IF NOT EXISTS hm_bp_forms (
          id VARCHAR(64) PRIMARY KEY,
          category_id VARCHAR(64) NOT NULL,
          active TINYINT(1) NOT NULL DEFAULT 1,
          data JSON NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          INDEX idx_forms_category (category_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_form_versions", [[
        CREATE TABLE IF NOT EXISTS hm_bp_form_versions (
          form_id VARCHAR(64) NOT NULL,
          version INT NOT NULL,
          schema_json JSON NOT NULL,
          created_by_identifier VARCHAR(128) NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (form_id, version),
          INDEX idx_form_versions_form (form_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_locations", [[
        CREATE TABLE IF NOT EXISTS hm_bp_locations (
          id VARCHAR(64) PRIMARY KEY,
          data JSON NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_submissions", [[
        CREATE TABLE IF NOT EXISTS hm_bp_submissions (
          id BIGINT NOT NULL AUTO_INCREMENT,
          public_id VARCHAR(32) NOT NULL,
          citizen_identifier VARCHAR(128) NOT NULL,
          citizen_name VARCHAR(128) NULL,

          category_id VARCHAR(64) NOT NULL,
          form_id VARCHAR(64) NOT NULL,
          form_version INT NOT NULL,

          status VARCHAR(32) NOT NULL,
          priority VARCHAR(16) NOT NULL,

          deadline_at DATETIME NULL,
          due_state VARCHAR(16) NOT NULL DEFAULT 'normal',

          assigned_to_identifier VARCHAR(128) NULL,
          assigned_to_name VARCHAR(128) NULL,

          location_id VARCHAR(64) NULL,

          flags JSON NULL,

          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          closed_at DATETIME NULL,
          archived_at DATETIME NULL,
          deleted_at DATETIME NULL,
          delete_reason VARCHAR(255) NULL,

          PRIMARY KEY (id),
          UNIQUE KEY uq_public_id (public_id),
          INDEX idx_citizen_identifier (citizen_identifier),
          INDEX idx_status (status),
          INDEX idx_priority (priority),
          INDEX idx_category (category_id),
          INDEX idx_form (form_id),
          INDEX idx_assigned (assigned_to_identifier),
          INDEX idx_created (created_at),
          INDEX idx_archived (archived_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_submission_payloads", [[
        CREATE TABLE IF NOT EXISTS hm_bp_submission_payloads (
          submission_id BIGINT NOT NULL,
          form_snapshot JSON NOT NULL,
          fields_snapshot JSON NOT NULL,
          answers JSON NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (submission_id),
          CONSTRAINT fk_payloads_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_submission_timeline", [[
        CREATE TABLE IF NOT EXISTS hm_bp_submission_timeline (
          id BIGINT NOT NULL AUTO_INCREMENT,
          submission_id BIGINT NOT NULL,
          entry_type VARCHAR(32) NOT NULL,
          visibility VARCHAR(16) NOT NULL,
          author_identifier VARCHAR(128) NOT NULL,
          author_name VARCHAR(128) NULL,
          content JSON NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX idx_timeline_submission (submission_id),
          INDEX idx_timeline_created (created_at),
          CONSTRAINT fk_timeline_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_submission_status_history", [[
        CREATE TABLE IF NOT EXISTS hm_bp_submission_status_history (
          id BIGINT NOT NULL AUTO_INCREMENT,
          submission_id BIGINT NOT NULL,
          old_status VARCHAR(32) NULL,
          new_status VARCHAR(32) NOT NULL,
          changed_by_identifier VARCHAR(128) NOT NULL,
          changed_by_name VARCHAR(128) NULL,
          comment VARCHAR(255) NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX idx_statushist_submission (submission_id),
          INDEX idx_statushist_created (created_at),
          CONSTRAINT fk_statushist_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_audit_logs", [[
        CREATE TABLE IF NOT EXISTS hm_bp_audit_logs (
          id BIGINT NOT NULL AUTO_INCREMENT,
          action VARCHAR(64) NOT NULL,
          actor_identifier VARCHAR(128) NOT NULL,
          actor_name VARCHAR(128) NULL,
          actor_job VARCHAR(64) NULL,
          actor_grade INT NULL,
          target_type VARCHAR(32) NOT NULL,
          target_id VARCHAR(64) NOT NULL,
          data JSON NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX idx_audit_action (action),
          INDEX idx_audit_actor (action, actor_identifier),
          INDEX idx_audit_target (target_type, target_id),
          INDEX idx_audit_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_webhook_logs", [[
        CREATE TABLE IF NOT EXISTS hm_bp_webhook_logs (
          id BIGINT NOT NULL AUTO_INCREMENT,
          event_name VARCHAR(64) NOT NULL,
          webhook_url_hash VARCHAR(64) NOT NULL,
          payload JSON NOT NULL,
          success TINYINT(1) NOT NULL DEFAULT 0,
          response_code INT NULL,
          error_text VARCHAR(255) NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX idx_webhook_event (event_name),
          INDEX idx_webhook_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_security_events", [[
        CREATE TABLE IF NOT EXISTS hm_bp_security_events (
          id BIGINT NOT NULL AUTO_INCREMENT,
          event_type VARCHAR(64) NOT NULL,
          actor_identifier VARCHAR(128) NULL,
          actor_name VARCHAR(128) NULL,
          data JSON NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (id),
          INDEX idx_sec_event_type (event_type),
          INDEX idx_sec_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
    })
  end)

  migrationAnwenden("v2_monats_sequenzen", [[
    CREATE TABLE IF NOT EXISTS hm_bp_public_id_sequences (
      ym CHAR(7) NOT NULL,
      seq INT NOT NULL DEFAULT 0,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (ym)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  migrationAnwenden("v3_sperren", [[
    CREATE TABLE IF NOT EXISTS hm_bp_submission_locks (
      submission_id BIGINT NOT NULL,
      locked_by_identifier VARCHAR(128) NOT NULL,
      locked_by_name VARCHAR(128) NULL,
      locked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      expires_at DATETIME NOT NULL,
      PRIMARY KEY (submission_id),
      INDEX idx_lock_expires (expires_at),
      CONSTRAINT fk_lock_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  migrationAnwenden("v4_staff_directory", [[
    CREATE TABLE IF NOT EXISTS hm_bp_staff_directory (
      identifier VARCHAR(128) NOT NULL,
      display_name VARCHAR(128) NULL,
      job VARCHAR(64) NOT NULL,
      grade INT NOT NULL DEFAULT 0,
      last_seen_at DATETIME NULL,
      PRIMARY KEY (identifier),
      INDEX idx_staff_job (job),
      INDEX idx_staff_last_seen (last_seen_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  -- v5_formular_editor: Jede Tabelle in einem eigenen DB-Call (Multi-Statement-Kompatibilität).
  migrationAnwenden("v5_formular_editor", function()
    tabellenErstellen("v5_formular_editor", {
      { "hm_bp_form_editor_forms", [[
        CREATE TABLE IF NOT EXISTS hm_bp_form_editor_forms (
          id VARCHAR(64) NOT NULL,
          category_id VARCHAR(64) NOT NULL,

          status VARCHAR(16) NOT NULL DEFAULT 'draft',
          active TINYINT(1) NOT NULL DEFAULT 1,

          title VARCHAR(128) NOT NULL,
          description TEXT NULL,

          created_by_identifier VARCHAR(128) NULL,
          created_by_name VARCHAR(128) NULL,

          updated_by_identifier VARCHAR(128) NULL,
          updated_by_name VARCHAR(128) NULL,

          published_version INT NULL,
          published_at DATETIME NULL,

          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

          PRIMARY KEY (id),
          INDEX idx_fe_forms_category (category_id),
          INDEX idx_fe_forms_status (status),
          INDEX idx_fe_forms_active (active)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_form_editor_versions", [[
        CREATE TABLE IF NOT EXISTS hm_bp_form_editor_versions (
          form_id VARCHAR(64) NOT NULL,
          version INT NOT NULL,
          schema_json JSON NOT NULL,

          created_by_identifier VARCHAR(128) NULL,
          created_by_name VARCHAR(128) NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

          PRIMARY KEY (form_id, version),
          INDEX idx_fe_versions_form (form_id),
          CONSTRAINT fk_fe_versions_form FOREIGN KEY (form_id) REFERENCES hm_bp_form_editor_forms(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
      { "hm_bp_form_editor_permissions", [[
        CREATE TABLE IF NOT EXISTS hm_bp_form_editor_permissions (
          id BIGINT NOT NULL AUTO_INCREMENT,
          category_id VARCHAR(64) NOT NULL,

          role VARCHAR(16) NOT NULL,
          job VARCHAR(64) NULL,
          min_grade INT NULL,
          max_grade INT NULL,

          can_create TINYINT(1) NOT NULL DEFAULT 0,
          can_edit   TINYINT(1) NOT NULL DEFAULT 0,
          can_publish TINYINT(1) NOT NULL DEFAULT 0,
          can_archive TINYINT(1) NOT NULL DEFAULT 0,

          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

          PRIMARY KEY (id),
          INDEX idx_fe_perm_category (category_id),
          INDEX idx_fe_perm_role (role),
          INDEX idx_fe_perm_job (job),
          INDEX idx_fe_perm_grade (min_grade, max_grade)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      ]] },
    })
  end)

  -- v6: SLA/Workflow-Spalten für Anträge (PR7)
  migrationAnwenden("v6_workflow_sla", function()
    if spalteFehlt("hm_bp_submissions", "last_status_change_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN last_status_change_at DATETIME NULL")
    end
    if spalteFehlt("hm_bp_submissions", "sla_due_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN sla_due_at DATETIME NULL")
    end
    if spalteFehlt("hm_bp_submissions", "sla_paused_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN sla_paused_at DATETIME NULL")
    end
    if spalteFehlt("hm_bp_submissions", "sla_paused_by") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN sla_paused_by VARCHAR(128) NULL")
    end
    if spalteFehlt("hm_bp_submissions", "escalated_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN escalated_at DATETIME NULL")
    end
    if spalteFehlt("hm_bp_submissions", "needs_leitung") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN needs_leitung TINYINT(1) NOT NULL DEFAULT 0")
    end
  end)

  -- v7: lock_reason für Bearbeitungssperren (PR7)
  migrationAnwenden("v7_lock_reason", function()
    if spalteFehlt("hm_bp_submission_locks", "lock_reason") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submission_locks ADD COLUMN lock_reason VARCHAR(128) NULL")
    end
  end)

  -- v8: Anhänge als URL-Links (PR8)
  migrationAnwenden("v8_attachments", [[
    CREATE TABLE IF NOT EXISTS hm_bp_submission_attachments (
      id BIGINT NOT NULL AUTO_INCREMENT,
      submission_id BIGINT NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      created_by_identifier VARCHAR(128) NOT NULL,
      created_by_role VARCHAR(16) NOT NULL,
      url VARCHAR(2048) NOT NULL,
      title VARCHAR(128) NULL,
      mime_hint VARCHAR(64) NULL,
      is_direct_image TINYINT(1) NOT NULL DEFAULT 0,
      deleted_at DATETIME NULL,
      deleted_by_identifier VARCHAR(128) NULL,
      delete_reason VARCHAR(255) NULL,
      PRIMARY KEY (id),
      INDEX idx_attach_submission (submission_id),
      INDEX idx_attach_created (created_at),
      INDEX idx_attach_deleted (deleted_at),
      CONSTRAINT fk_attach_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  -- v9: Performance-Indexes für Suche & Filter (PR9)
  -- Einzelne ALTER TABLE pro Index – jede Migration läuft exakt einmal (idempotent).
  migrationAnwenden("v9_idx_citizen_name", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_citizen_name (citizen_name(64));
  ]])
  migrationAnwenden("v9_idx_status", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_status (status);
  ]])
  migrationAnwenden("v9_idx_kategorie", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_kategorie (category_id);
  ]])
  migrationAnwenden("v9_idx_priority", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_priority (priority);
  ]])
  migrationAnwenden("v9_idx_created_at", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_created_at (created_at);
  ]])
  migrationAnwenden("v9_idx_assigned_to", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_assigned_to (assigned_to_identifier);
  ]])
  migrationAnwenden("v9_idx_archived_at", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_archived_at (archived_at);
  ]])
  migrationAnwenden("v9_idx_eskalation", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_eskalation (needs_leitung, escalated_at, sla_due_at);
  ]])

  -- v10: Audit-Log-Härtung (PR12)
  -- Neue Spalten für vollständige, unveränderliche Audit-Einträge.
  migrationAnwenden("v10_audit_haertung_spalten", function()
    if spalteFehlt("hm_bp_audit_logs", "request_id") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN request_id VARCHAR(32) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "actor_display_name") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN actor_display_name VARCHAR(256) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "actor_source") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN actor_source VARCHAR(64) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "actor_ip") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN actor_ip VARCHAR(64) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "target_public_id") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN target_public_id VARCHAR(32) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "target_category_id") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN target_category_id VARCHAR(64) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "target_form_id") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN target_form_id VARCHAR(64) NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "reason") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN reason TEXT NULL")
    end
    if spalteFehlt("hm_bp_audit_logs", "metadata") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_audit_logs ADD COLUMN metadata JSON NULL")
    end
  end)
  migrationAnwenden("v10_audit_idx_request_id", [[
    ALTER TABLE hm_bp_audit_logs ADD INDEX idx_audit_request_id (request_id);
  ]])
  migrationAnwenden("v10_audit_idx_public_id", [[
    ALTER TABLE hm_bp_audit_logs ADD INDEX idx_audit_public_id (target_public_id);
  ]])
  migrationAnwenden("v10_audit_idx_actor_name", [[
    ALTER TABLE hm_bp_audit_logs ADD INDEX idx_audit_actor_name (actor_name(64));
  ]])

  -- v11: SLA Erste-Bearbeitung (PR13)
  migrationAnwenden("v11_sla_erst_bearbeitung", function()
    if spalteFehlt("hm_bp_submissions", "first_staff_comment_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN first_staff_comment_at DATETIME NULL")
    end
    if spalteFehlt("hm_bp_submissions", "escalated") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN escalated TINYINT(1) NOT NULL DEFAULT 0")
    end
    if spalteFehlt("hm_bp_submissions", "last_escalation_reminder_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN last_escalation_reminder_at DATETIME NULL")
    end
  end)
  migrationAnwenden("v11_idx_sla_erst_bearbeitung", [[
    ALTER TABLE hm_bp_submissions
      ADD INDEX idx_sub_erst_bearbeitung (escalated, created_at, first_staff_comment_at);
  ]])

  -- v12: Gebührenzahlung (PR14)
  migrationAnwenden("v12_gebuehren_forms", function()
    if spalteFehlt("hm_bp_form_editor_forms", "fee_eur") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_form_editor_forms ADD COLUMN fee_eur INT NOT NULL DEFAULT 0")
    end
  end)
  migrationAnwenden("v12_gebuehren_submissions", function()
    if spalteFehlt("hm_bp_submissions", "fee_eur") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN fee_eur INT NOT NULL DEFAULT 0")
    end
    if spalteFehlt("hm_bp_submissions", "zahlung_status") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN zahlung_status VARCHAR(16) NOT NULL DEFAULT 'bezahlt'")
    end
    if spalteFehlt("hm_bp_submissions", "charged_at") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN charged_at DATETIME NULL")
    end
  end)
  -- Backfill: Alle bestehenden Einreichungen hatten fee_eur = 0 → als bezahlt markieren.
  -- Neue Einreichungen mit fee_eur > 0 werden beim Einreichen explizit auf 'unbezahlt' gesetzt.
  migrationAnwenden("v12_backfill_zahlung_status", [[
    UPDATE hm_bp_submissions SET zahlung_status = 'bezahlt' WHERE fee_eur = 0;
  ]])
  migrationAnwenden("v12_idx_zahlung_status", [[
    ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_zahlung_status (zahlung_status, charged_at);
  ]])

  -- v13: Performance-Indexes (PR16 – Release-Candidate Bugfixes)
  -- idx_sub_erst_reminder: Index für den Reminder-Zweig in SlaErstBearbeitungTick.
  --   Abfrageform: escalated=1 AND last_escalation_reminder_at <= DATE_SUB(...)
  --   Der neue Index (escalated, last_escalation_reminder_at) erlaubt einen Index-Range-Scan
  --   statt eines vollständigen Table-Scans.
  migrationAnwenden("v13_idx_sla_reminder", [[
    ALTER TABLE hm_bp_submissions
      ADD INDEX idx_sub_erst_reminder (escalated, last_escalation_reminder_at);
  ]])
  -- idx_sub_sla_tick: Index für den regulären SlaTick (sla_due_at, paused, needs_leitung).
  --   Ergänzt den bestehenden idx_sub_eskalation um einen dedizierteren Index ohne escalated_at.
  migrationAnwenden("v13_idx_sla_tick", [[
    ALTER TABLE hm_bp_submissions
      ADD INDEX idx_sub_sla_tick (needs_leitung, sla_due_at, sla_paused_at);
  ]])
  -- idx_audit_created_action: Composite-Index für Audit-Filter (Datum + Aktion).
  --   Deckt die häufigste Audit-Viewer-Kombination: von/bis + Aktionsfilter.
  migrationAnwenden("v13_idx_audit_created_action", [[
    ALTER TABLE hm_bp_audit_logs
      ADD INDEX idx_audit_created_action (created_at, action);
  ]])

  -- v14: PR1 – Statusystem-Erweiterung (neue Status + Overdue-Optimierung)
  migrationAnwenden("v14_idx_due_state", [[
    ALTER TABLE hm_bp_submissions
      ADD INDEX idx_sub_due_state (due_state, sla_due_at, sla_paused_at, deleted_at, archived_at);
  ]])
  -- idx_sub_status_history: Index für Statusverlauf-Abfragen
  migrationAnwenden("v14_idx_status_history", function()
    if indexFehlt("hm_bp_submission_status_history", "idx_ssh_sub_created") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submission_status_history ADD INDEX idx_ssh_sub_created (submission_id, created_at)")
    end
  end)

  -- v15: PR2 – Mitarbeiter-Entwürfe (interne Notizen + Rückfragen als Entwurf speichern)
  migrationAnwenden("v15_staff_drafts", [[
    CREATE TABLE IF NOT EXISTS hm_bp_staff_drafts (
      id BIGINT NOT NULL AUTO_INCREMENT,
      submission_id BIGINT NOT NULL,
      actor_identifier VARCHAR(128) NOT NULL,
      draft_type VARCHAR(32) NOT NULL,
      draft_text TEXT NOT NULL,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uq_draft (submission_id, actor_identifier, draft_type),
      INDEX idx_draft_sub (submission_id),
      INDEX idx_draft_actor (actor_identifier),
      CONSTRAINT fk_draft_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])
  -- v15: author_role-Spalte in Timeline ergänzen
  migrationAnwenden("v15_timeline_author_role", function()
    if spalteFehlt("hm_bp_submission_timeline", "author_role") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submission_timeline ADD COLUMN author_role VARCHAR(16) NULL")
    end
  end)

  -- v16: PR3 – Delegation / Stellvertretung + Vollmacht
  migrationAnwenden("v16_submissions_delegation", function()
    if spalteFehlt("hm_bp_submissions", "actor_identifier") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN actor_identifier VARCHAR(128) NULL")
    end
    if spalteFehlt("hm_bp_submissions", "actor_name") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN actor_name VARCHAR(128) NULL")
    end
    if spalteFehlt("hm_bp_submissions", "delegation_type") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD COLUMN delegation_type VARCHAR(32) NULL")
    end
  end)
  migrationAnwenden("v16_idx_actor", function()
    if indexFehlt("hm_bp_submissions", "idx_sub_actor") then
      HM_BP.Server.Datenbank.Ausfuehren("ALTER TABLE hm_bp_submissions ADD INDEX idx_sub_actor (actor_identifier)")
    end
  end)
  -- Vollmachten-Tabelle: Bürger ↔ Bevollmächtigter und Firma ↔ Firmenvertreter
  migrationAnwenden("v16_vollmachten", [[
    CREATE TABLE IF NOT EXISTS hm_bp_vollmachten (
      id BIGINT NOT NULL AUTO_INCREMENT,
      vollmacht_typ VARCHAR(32) NOT NULL COMMENT 'buerger_anwalt | firma_vertreter',
      auftraggeber_identifier VARCHAR(128) NOT NULL COMMENT 'Bürger oder Firma (als pseudo-ID)',
      auftraggeber_name       VARCHAR(128) NOT NULL,
      bevollmaechtigter_identifier VARCHAR(128) NOT NULL,
      bevollmaechtigter_name       VARCHAR(128) NOT NULL,
      erteilt_von_identifier  VARCHAR(128) NOT NULL COMMENT 'Justiz-Leitung/Admin der die Vollmacht angelegt hat',
      erteilt_von_name        VARCHAR(128) NOT NULL,
      aktiv TINYINT(1) NOT NULL DEFAULT 1,
      erstellt_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      widerrufen_at DATETIME NULL,
      widerrufen_von_identifier VARCHAR(128) NULL,
      widerrufen_von_name       VARCHAR(128) NULL,
      PRIMARY KEY (id),
      INDEX idx_vm_typ_auftraggeber (vollmacht_typ, auftraggeber_identifier),
      INDEX idx_vm_bevollmaechtigter (bevollmaechtigter_identifier),
      INDEX idx_vm_aktiv (aktiv)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  -- v17: PR4 – Zahlungs-Ledger (Gebühren v2)
  -- Jede Zahlung, Rückerstattung und Befreiung wird hier protokolliert.
  -- typ:    'debit' | 'credit' | 'refund' | 'exempt'
  -- status: 'success' | 'failed'
  migrationAnwenden("v17_zahlungs_ledger", [[
    CREATE TABLE IF NOT EXISTS hm_bp_zahlungs_ledger (
      id                  BIGINT NOT NULL AUTO_INCREMENT,
      antrag_id           BIGINT NOT NULL,
      public_id           VARCHAR(64) NOT NULL,
      citizen_identifier  VARCHAR(128) NOT NULL,
      actor_name          VARCHAR(128) NOT NULL DEFAULT '',
      typ                 VARCHAR(16) NOT NULL COMMENT 'debit|credit|refund|exempt',
      betrag_eur          INT NOT NULL DEFAULT 0,
      status              VARCHAR(16) NOT NULL DEFAULT 'success' COMMENT 'success|failed',
      metadata            JSON NULL,
      created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      INDEX idx_ledger_antrag (antrag_id),
      INDEX idx_ledger_citizen (citizen_identifier),
      INDEX idx_ledger_typ (typ),
      INDEX idx_ledger_created (created_at),
      CONSTRAINT fk_ledger_submission FOREIGN KEY (antrag_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  -- v18: PR5 – Integrations-Flags (set_db_flag Aktion)
  -- Speichert pro (submission_id, schluessel) einen Wert.
  -- Wird durch die Folgeaktionen-Engine (IntegrationService) befüllt.
  migrationAnwenden("v18_integration_flags", [[
    CREATE TABLE IF NOT EXISTS hm_bp_integration_flags (
      id            BIGINT NOT NULL AUTO_INCREMENT,
      submission_id BIGINT NOT NULL,
      schluessel    VARCHAR(128) NOT NULL,
      wert          TEXT NOT NULL DEFAULT '',
      gesetzt_am    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uq_flag (submission_id, schluessel),
      INDEX idx_flag_submission (submission_id),
      INDEX idx_flag_schluessel (schluessel),
      CONSTRAINT fk_flag_submission FOREIGN KEY (submission_id)
        REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  -- v19: PR6 – Missbrauchsschutz-Log
  -- Protokolliert Missbrauchs-Ereignisse (Lockouts, Blacklist-Treffer usw.)
  -- für Monitoring und Auditing.
  migrationAnwenden("v19_abuse_lockout_log", [[
    CREATE TABLE IF NOT EXISTS hm_bp_abuse_log (
      id             BIGINT NOT NULL AUTO_INCREMENT,
      identifier     VARCHAR(128) NOT NULL,
      grund          VARCHAR(255) NOT NULL DEFAULT '',
      extra          JSON NULL,
      created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      INDEX idx_abuse_identifier (identifier),
      INDEX idx_abuse_created (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])
end