-- =============================================================
-- shared/permission_actions.lua
-- Kanonische Aktionsschlüssel für das Permissions-System.
-- Alle Berechtigungsprüfungen MÜSSEN einen dieser Schlüssel
-- verwenden, um Inkonsistenzen und Tippfehler zu vermeiden.
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}

---@class PermissionActions
HM_BP.Shared.Actions = {

  -- -------------------------------------------------------
  -- System / Portal-Öffnen
  -- -------------------------------------------------------
  -- Spieler darf das Portal grundsätzlich öffnen
  SYSTEM_OPEN       = "system.open",

  -- -------------------------------------------------------
  -- Ansichts-Berechtigungen (Portalbereiche)
  -- -------------------------------------------------------
  -- Bürger-Bereich (eigene Anträge, Formularübersicht)
  CITIZEN_VIEW      = "citizen.view",
  -- Justiz-Dashboard öffnen
  JUSTICE_VIEW      = "justice.view",
  -- Admin-Bereich öffnen
  ADMIN_VIEW        = "admin.view",

  -- -------------------------------------------------------
  -- Kategorien & Formulare
  -- -------------------------------------------------------
  CATEGORIES_VIEW   = "categories.view",
  CATEGORIES_MANAGE = "categories.manage",
  FORMS_VIEW        = "forms.view",
  FORMS_MANAGE      = "forms.manage",

  -- -------------------------------------------------------
  -- Anträge (Bürger)
  -- -------------------------------------------------------
  -- Bürger darf einen neuen Antrag einreichen
  SUBMISSIONS_CREATE   = "submissions.create",
  -- Bürger darf seine eigenen Anträge einsehen
  SUBMISSIONS_VIEW_OWN = "submissions.view_own",

  -- -------------------------------------------------------
  -- Anträge (Justiz / Admin – Queues)
  -- -------------------------------------------------------
  -- Eingangsqueue einsehen (alle neuen Anträge einer Kategorie)
  SUBMISSIONS_VIEW_INBOX    = "submissions.view_inbox",
  -- Nur zugewiesene Anträge einsehen
  SUBMISSIONS_VIEW_ASSIGNED = "submissions.view_assigned",
  -- Alle Anträge der Kategorie einsehen (auch fremde)
  SUBMISSIONS_VIEW_ALL      = "submissions.view_all",
  -- Archivierte Anträge einsehen
  SUBMISSIONS_VIEW_ARCHIVE  = "submissions.view_archive",

  -- -------------------------------------------------------
  -- Antrags-Aktionen (Justiz / Admin)
  -- -------------------------------------------------------
  -- Antrag übernehmen (assign to self)
  SUBMISSIONS_TAKE          = "submissions.take",
  -- Antrag einem anderen Bearbeiter zuweisen
  SUBMISSIONS_ASSIGN        = "submissions.assign",
  -- Priorität ändern
  SUBMISSIONS_SET_PRIORITY  = "submissions.set_priority",
  -- Status manuell setzen
  SUBMISSIONS_CHANGE_STATUS = "submissions.change_status",
  -- Antrag genehmigen (→ approved)
  SUBMISSIONS_APPROVE       = "submissions.approve",
  -- Antrag ablehnen (→ rejected)
  SUBMISSIONS_REJECT        = "submissions.reject",
  -- Antrag archivieren (→ archived)
  SUBMISSIONS_ARCHIVE       = "submissions.archive",
  -- Antrag hart löschen (nur Admin)
  SUBMISSIONS_DELETE        = "submissions.delete",

  -- -------------------------------------------------------
  -- Interne Notizen
  -- -------------------------------------------------------
  NOTES_INTERNAL_READ  = "notes.internal.read",
  NOTES_INTERNAL_WRITE = "notes.internal.write",

  -- -------------------------------------------------------
  -- Öffentliche Nachrichten (sichtbar für Bürger)
  -- -------------------------------------------------------
  MESSAGE_PUBLIC_READ  = "message.public.read",
  MESSAGE_PUBLIC_WRITE = "message.public.write",

  -- -------------------------------------------------------
  -- Rückfragen & Bürgernachreichung
  -- -------------------------------------------------------
  -- Justiz stellt dem Bürger eine Rückfrage
  QUESTION_ASK         = "question.ask",
  -- Bürger antwortet auf eine Rückfrage
  QUESTION_ANSWER      = "question.answer",
  -- Bürger reicht fehlende Felder nach
  CITIZEN_SUPPLEMENT   = "citizen.supplement",

  -- -------------------------------------------------------
  -- Audit & Administration
  -- -------------------------------------------------------
  AUDIT_VIEW            = "audit.view",
  WEBHOOK_TEST          = "webhook.test",
  ADMIN_SETTINGS        = "admin.settings",

  -- Admin-Konfigurationsbereich öffnen (Lesen)
  ADMIN_PANEL_OPEN      = "admin.panel.open",
  -- Admin-Konfiguration schreiben (alle Mutations-Endpunkte)
  ADMIN_CONFIG_WRITE    = "admin.config.write",

  -- -------------------------------------------------------
  -- Formular-Editor
  -- -------------------------------------------------------
  -- Editor öffnen und Entwürfe bearbeiten
  FORM_EDITOR_USE     = "form_editor.use",
  -- Formular veröffentlichen
  FORM_EDITOR_PUBLISH = "form_editor.publish",
  -- Formular archivieren
  FORM_EDITOR_ARCHIVE = "form_editor.archive",

  -- -------------------------------------------------------
  -- Workflow / Locks / SLA (PR7)
  -- -------------------------------------------------------
  -- Bearbeitungssperre anfordern (jeder Justiz-Bearbeiter)
  WORKFLOW_LOCK_REQUEST  = "workflow.lock.request",
  -- Eigene Sperre freigeben
  WORKFLOW_LOCK_RELEASE  = "workflow.lock.release",
  -- Fremde Sperre überschreiben/aufheben (nur Leitung ≥ Grade 29)
  WORKFLOW_LOCK_OVERRIDE = "workflow.lock.override",
  -- SLA pausieren (nur Leitung ≥ Grade 29)
  WORKFLOW_SLA_PAUSE     = "workflow.sla.pause",
  -- Pausierte SLA fortsetzen (nur Leitung ≥ Grade 29)
  WORKFLOW_SLA_RESUME    = "workflow.sla.resume",

  -- -------------------------------------------------------
  -- Anhänge / Attachments (PR8)
  -- -------------------------------------------------------
  -- Anhang hinzufügen (Bürger: nur in erlaubten Status; Justiz/Admin: immer)
  ATTACHMENT_ADD    = "attachment.add",
  -- Anhang entfernen (nur Justiz/Admin)
  ATTACHMENT_REMOVE = "attachment.remove",
  -- Anhänge ansehen (Justiz/Admin: immer; Bürger: nur eigene)
  ATTACHMENT_VIEW   = "attachment.view",
}
