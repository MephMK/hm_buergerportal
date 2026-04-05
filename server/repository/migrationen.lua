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

local function migrationAnwenden(id, sql)
  if migrationVorhanden(id) then return end
  HM_BP.Server.Datenbank.Ausfuehren(sql)
  HM_BP.Server.Datenbank.Ausfuehren("INSERT INTO hm_bp_migrations (id) VALUES (?)", { id })
  print(("[hm_buergerportal] Migration angewendet: %s"):format(id))
end

function HM_BP.Server.Migrationen.AlleAusfuehren()
  migrationsTabelleSicherstellen()

  migrationAnwenden("v1_core_tables", [[
    CREATE TABLE IF NOT EXISTS hm_bp_categories (
      id VARCHAR(64) PRIMARY KEY,
      data JSON NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS hm_bp_forms (
      id VARCHAR(64) PRIMARY KEY,
      category_id VARCHAR(64) NOT NULL,
      active TINYINT(1) NOT NULL DEFAULT 1,
      data JSON NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_forms_category (category_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS hm_bp_form_versions (
      form_id VARCHAR(64) NOT NULL,
      version INT NOT NULL,
      schema_json JSON NOT NULL,
      created_by_identifier VARCHAR(128) NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (form_id, version),
      INDEX idx_form_versions_form (form_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS hm_bp_locations (
      id VARCHAR(64) PRIMARY KEY,
      data JSON NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS hm_bp_submission_payloads (
      submission_id BIGINT NOT NULL,
      form_snapshot JSON NOT NULL,
      fields_snapshot JSON NOT NULL,
      answers JSON NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (submission_id),
      CONSTRAINT fk_payloads_submission FOREIGN KEY (submission_id) REFERENCES hm_bp_submissions(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

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

  migrationAnwenden("v5_formular_editor", [[
    CREATE TABLE IF NOT EXISTS hm_bp_form_editor_forms (
      id VARCHAR(64) NOT NULL,
      category_id VARCHAR(64) NOT NULL,

      status VARCHAR(16) NOT NULL DEFAULT 'draft', -- draft|published|archived
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE IF NOT EXISTS hm_bp_form_editor_permissions (
      id BIGINT NOT NULL AUTO_INCREMENT,
      category_id VARCHAR(64) NOT NULL,

      role VARCHAR(16) NOT NULL,           -- admin|justiz|buerger
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])
end