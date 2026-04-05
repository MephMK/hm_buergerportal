HM_BP = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}

HM_BP.Shared.Texts = {
  UI = {
    TITLE = "HM Bürgerportal",
    CLOSE = "Schließen",
  },

  Errors = {
    NOT_AUTHENTICATED   = "Du bist nicht angemeldet. Bitte melde dich erneut an.",
    NOT_AUTHORIZED      = "Du hast keine Berechtigung für diese Aktion.",
    INVALID_PAYLOAD     = "Ungültige Eingabedaten. Bitte Eingaben prüfen.",
    INTERNAL_ERROR      = "Interner Fehler. Bitte später erneut versuchen.",
    DB_UNAVAILABLE      = "Datenbankverbindung nicht verfügbar. Bitte wende dich an einen Administrator.",
    WEBHOOK_MISSING     = "Kein Webhook konfiguriert. Bitte URL in der Serverkonfiguration hinterlegen.",
    PAYMENT_FAILED      = "Zahlung fehlgeschlagen. Bitte prüfe dein Bankguthaben oder kontaktiere das Personal.",
    PAYMENT_OFFLINE     = "Zahlung konnte nicht durchgeführt werden, da der Bürger offline ist. Manuelle Abbuchung erforderlich.",
    NO_PERMISSION       = "Keine Berechtigung für diese Aktion.",
    FORM_NOT_FOUND      = "Formular nicht gefunden.",
    SUBMISSION_NOT_FOUND = "Antrag nicht gefunden.",
    CATEGORY_NOT_FOUND  = "Kategorie nicht gefunden.",
    ALREADY_ARCHIVED    = "Dieser Antrag ist bereits archiviert.",
    LOCK_CONFLICT       = "Dieser Antrag wird gerade von einem anderen Bearbeiter bearbeitet.",
    SLA_ALREADY_PAUSED  = "Die Frist ist bereits pausiert.",
    SLA_NOT_PAUSED      = "Die Frist ist nicht pausiert.",
  },

  Payment = {
    HINT_AFTER_PROCESSING = "Für diesen Antrag wird eine Gebühr von %d € erhoben. Die Zahlung erfolgt nach Bearbeitung Ihres Antrags.",
    STATUS_BEZAHLT        = "Bezahlt",
    STATUS_UNBEZAHLT      = "Ausstehend (wird nach Bearbeitung abgebucht)",
    STATUS_FEHLGESCHLAGEN = "Zahlung fehlgeschlagen – bitte Personal kontaktieren",
  },

  SLA = {
    ESKALATION_TEXT   = "Antrag %s hat die %dh-Frist für die erste Bearbeitung überschritten.",
    REMINDER_TEXT     = "Erinnerung: Antrag %s wartet seit mehr als %dh auf erste Bearbeitung.",
    PAUSED_NOTICE     = "SLA pausiert.",
    RESUMED_NOTICE    = "SLA fortgesetzt.",
  },
}
