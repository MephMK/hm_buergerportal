Config = {}

Config.Kern = {
  RessourcenName = "hm_buergerportal",
  Sprache = "de",

  Framework = "esx",

  Jobs = {
    Admin = "admin",
    Justiz = "doj",
  },

  -- Admin-Zugang: welcher Job + ab welchem Mindestgrad gilt als Admin.
  -- Wer job == Admin.Job UND job.grade >= Admin.MinGrade hat, bekommt Vollzugriff.
  Admin = {
    Job      = "admin",  -- Job-Name des Admin-Jobs
    MinGrade = 0,        -- Mindestgrad (inkl.), 0 = alle Grades des Jobs
  },

  -- Justiz-Job-Konfiguration: maßgeblich für alle Dienste.
  -- Ändere hier den Job-Namen wenn dein Justiz-Job nicht "doj" heißt.
  -- Config.Kern.Jobs.Justiz bleibt als Fallback für Rückwärtskompatibilität erhalten.
  Justiz = {
    Job = "doj",  -- Job-Name des Justiz-Jobs (anpassbar an den Job-Namen deines Servers)
  },

  Debugmodus = false,

  Interaktion = {
    Modus = "taste",
    Taste = 38,
    Text = "[E] Bürgerportal öffnen",
  },

  OeffentlicheIds = {
    Aktiviert = true,
    Prefix = "HM-DOJ",
    Format = "PREFIX-YYYY-MM-NNNNNN",
    Stellen = 6,
  }
}

Config.Datenbank = {
  Adapter = "oxmysql",
  Migrationen = {
    Aktiviert = true,
    BeimStartAutomatisch = true,
  }
}

Config.Standorte = {
  Aktiviert = true,

  -- Globaler Interaktionsmodus für alle Standorte:
  --   "taste"     – Spieler drückt Taste E (Standard)
  --   "ox_target" – Interaktion über ox_target (erfordert ox_target Resource)
  -- Pro Standort kann der Modus in standort.interaktion.modus überschrieben werden.
  InteraktionsModus = "taste",

  Liste = {
    -- -------------------------------------------------------
    -- Standort 1: Justizzentrum Empfang (öffentlich, alle Rollen)
    -- -------------------------------------------------------
    ["doj_frontdesk_1"] = {
      id   = "doj_frontdesk_1",
      name = "Justizzentrum Empfang",
      aktiv = true,

      koordinaten = vector3(440.12, -981.92, 30.69),
      heading     = 90.0,

      interaktionsRadius = 2.0,
      sichtbarRadius     = 30.0,

      -- interaktion: leer = globale Defaults (Taste E, globaler Text)
      interaktion = {},

      zugriff = {
        nurBuerger = false,
        nurJustiz  = false,
        nurAdmin   = false,

        -- Alle Rollen erlaubt (leer = keine Einschränkung)
        erlaubteRollen     = {},
        erlaubteJobs       = {},
        erlaubteKategorien = {},
        erlaubteFormulare  = {},
      },

      ped = {
        aktiv           = true,
        modell          = "s_m_y_cop_01",
        scenario        = "WORLD_HUMAN_CLIPBOARD",
        unverwundbar    = true,
        eingefroren     = true,
        blockiereEvents = true,
      },

      marker = {
        aktiv   = true,
        typ     = 2,
        groesse = vector3(0.3, 0.3, 0.3),
        farbe   = { r = 0, g = 120, b = 255, a = 160 },
      },

      blip = {
        aktiv  = true,
        sprite = 525,
        farbe  = 3,
        scale  = 0.8,
        name   = "Justizzentrum Bürgerportal",
      }
    },

    -- -------------------------------------------------------
    -- Standort 2: Interne Justiz-Workstation (nur Justiz/Admin)
    -- -------------------------------------------------------
    ["doj_intern_1"] = {
      id   = "doj_intern_1",
      name = "Justiz Workstation (Intern)",
      aktiv = true,

      koordinaten = vector3(462.31, -993.46, 30.69),
      heading     = 270.0,

      interaktionsRadius = 1.8,
      sichtbarRadius     = 15.0,

      -- Per-Location Interaktionsmodus-Override (z.B. ox_target nur hier):
      -- interaktion = { modus = "ox_target", text = "[E] Intern öffnen" },
      interaktion = {
        text = "[E] Interne Workstation öffnen",
      },

      zugriff = {
        nurBuerger = false,
        nurJustiz  = true,   -- Nur Justiz und Admin dürfen diesen Standort nutzen
        nurAdmin   = false,

        erlaubteRollen     = {},
        erlaubteJobs       = { "doj", "admin" },
        erlaubteKategorien = {},
        erlaubteFormulare  = {},
      },

      ped = {
        aktiv = false,   -- kein PED an internem Terminal
      },

      marker = {
        aktiv   = true,
        typ     = 1,
        groesse = vector3(0.5, 0.5, 0.5),
        farbe   = { r = 255, g = 165, b = 0, a = 180 },
      },

      blip = {
        aktiv  = false,  -- kein Blip für internen Standort
      }
    }
  }
}

Config.Rechte = {
  Aktiviert = true,

  Aktionen = {
    SYSTEM_OEFFNEN = true,
    BUERGER_OEFFNEN = true,
    JUSTIZ_OEFFNEN = true,
    ADMIN_OEFFNEN = true,

    KATEGORIE_ANSEHEN = true,
    KATEGORIE_VERWALTEN = true,

    FORMULAR_ANSEHEN = true,
    FORMULAR_VERWALTEN = true,

    ANTRAG_ERSTELLEN = true,
    ANTRAG_EIGENE_ANSEHEN = true,

    ANTRAG_EINGANG_ANSEHEN = true,
    ANTRAG_ZUGEWIESENE_ANSEHEN = true,
    ANTRAG_ALLE_KATEGORIE_ANSEHEN = true,

    ANTRAG_UEBERNEHMEN = true,
    ANTRAG_ZUWEISEN = true,
    ANTRAG_PRIORITAET_SETZEN = true,
    ANTRAG_STATUS_SETZEN = true,
    ANTRAG_GENEHMIGEN = true,
    ANTRAG_ABLEHNEN = true,
    ANTRAG_ZURUECKGEBEN = true,
    ANTRAG_WEITERLEITEN = true,
    ANTRAG_ESKALIEREN = true,

    INTERNE_NOTIZ_LESEN = true,
    INTERNE_NOTIZ_SCHREIBEN = true,
    OEFFENTLICHE_NACHRICHT_LESEN = true,
    OEFFENTLICHE_NACHRICHT_SCHREIBEN = true,

    ARCHIV_ANSEHEN = true,
    ARCHIVIEREN = true,
    ANTRAG_LOESCHEN = true,

    AUDIT_ANSEHEN = true,
    WEBHOOK_TESTEN = true,
    ADMIN_EINSTELLUNGEN_AENDERN = true,
  },

  Richtlinie = {
    Global = {
      buerger = {
        erlauben = {
          "SYSTEM_OEFFNEN",
          "BUERGER_OEFFNEN",
          "ANTRAG_ERSTELLEN",
          "ANTRAG_EIGENE_ANSEHEN",
          "OEFFENTLICHE_NACHRICHT_LESEN",
        }
      },

      justiz = {
        job = "doj",
        mindestGrad = 0,
        erlauben = {
          "SYSTEM_OEFFNEN",
          "JUSTIZ_OEFFNEN",
          "KATEGORIE_ANSEHEN",
          "FORMULAR_ANSEHEN",
          "ANTRAG_EINGANG_ANSEHEN",
          "ANTRAG_ZUGEWIESENE_ANSEHEN",
          "OEFFENTLICHE_NACHRICHT_LESEN",
          "OEFFENTLICHE_NACHRICHT_SCHREIBEN",
        }
      },

      admin = {
        job = "admin",
        mindestGrad = 0,
        erlauben = { "*" }
      }
    },

    Kategorie = {},
    Formular = {}
  }
}

-- =============================================================
-- Config.Permissions
-- Feingranulares Permissions-System (permission_service.lua).
-- Dieses System arbeitet parallel zu Config.Rechte und nutzt
-- kanonische Aktionsschlüssel (HM_BP.Shared.Actions.*).
--
-- Kaskaden-Reihenfolge (spezifischste Ebene gewinnt):
--   1) Admin-Job → immer Vollzugriff (Kurzschluss)
--   2) Globale Defaults (Defaults[rolle])
--   3) Kategorie-Override (Config.Kategorien.Liste[id].permissions)
--   4) Formular-Override  (Config.Formulare.Liste[id].permissions)
--
-- allow = { "aktion1", "aktion2", ... } oder { "*" } für alle
-- deny  = { "aktion1", ... }            deny schlägt allow
-- grade = { min = N }  oder { max = N } oder { allowed = { 1, 2, 3 } }
-- jobs  = { "doj", "admin" }            Job-Whitelist (leer = alle)
-- =============================================================
Config.Permissions = {
  Aktiviert = true,

  -- Debug-Ausgabe in der Server-Konsole (nur für Entwicklung!)
  Debug = false,

  -- ----------------------------------------------------------
  -- Globale Defaults pro Rolle
  -- ----------------------------------------------------------
  Defaults = {

    -- Bürger: darf das Portal öffnen, eigene Anträge verwalten,
    --         öffentliche Nachrichten lesen, Rückfragen beantworten
    --         und fehlende Felder nachreichen.
    buerger = {
      allow = {
        "system.open",
        "citizen.view",
        "categories.view",
        "forms.view",
        "submissions.create",
        "submissions.view_own",
        "message.public.read",
        "question.answer",
        "citizen.supplement",
        -- Anhänge: Bürger darf hinzufügen (Status-Prüfung im Service) und eigene ansehen
        "attachment.add",
        "attachment.view",
      },
      deny  = {},
    },

    -- Justiz: mind. Job "doj", Grade 0+.
    -- Grundrechte für alle DoJ-Mitglieder; erweiterte Aktionen
    -- (archivieren, interne Notizen, etc.) können per Kategorie-
    -- oder Formular-Override für bestimmte Grades freigeschaltet
    -- werden (siehe Beispiel-Override weiter unten).
    justiz = {
      jobs  = { "doj" },
      grade = { min = 0 },
      allow = {
        "system.open",
        "justice.view",
        "categories.view",
        "forms.view",
        "submissions.view_inbox",
        "submissions.view_assigned",
        "submissions.take",
        "submissions.change_status",
        "submissions.approve",
        "submissions.reject",
        "message.public.read",
        "message.public.write",
        "question.ask",
        "notes.internal.read",
        "form_editor.use",
        -- Workflow/Locks (PR7): alle Justiz-Bearbeiter dürfen Locks anfordern/freigeben
        "workflow.lock.request",
        "workflow.lock.release",
        -- SLA-Pause und Lock-Override nur per Kategorie/Grade-Override für Leitung
        -- Anhänge: Justiz darf immer ansehen und entfernen (PR8)
        "attachment.add",
        "attachment.view",
        "attachment.remove",
        -- Export: Justiz darf PDFs exportieren (PR11)
        "export.pdf",
      },
      deny  = {},
    },

    -- Admin: voller Zugriff auf alles.
    admin = {
      jobs  = { "admin" },
      allow = { "*" },
      deny  = {},
    },
  },
}



-- ------------------------------------------------------------------
-- Beispiel: Kategorie-Override „general"
-- Justiz-Mitglieder mit Grade >= 2 dürfen zusätzlich:
--   archivieren, interne Notizen schreiben, Priorität setzen,
--   zuweisen, Formular-Editor veröffentlichen/-archivieren.
-- Grade 0–1 bleiben auf die globalen Justiz-Defaults beschränkt.
-- ------------------------------------------------------------------
-- Config.Kategorien.Liste["general"].permissions = {
--   justiz = {
--     grade = { min = 2 },
--     allow = {
--       "submissions.archive",
--       "submissions.assign",
--       "submissions.set_priority",
--       "notes.internal.write",
--       "submissions.view_all",
--       "submissions.view_archive",
--       "form_editor.publish",
--       "form_editor.archive",
--     },
--     deny = {},
--   },
-- }

-- ------------------------------------------------------------------
-- Beispiel: Formular-Override „gewerbe_antrag"
-- Für dieses Formular darf kein Justiz-Mitarbeiter (unabhängig vom
-- Grade) eine Rückfrage stellen – stattdessen nur Genehmigen/Ablehnen.
-- ------------------------------------------------------------------
-- Config.Formulare.Liste["gewerbe_antrag"].permissions = {
--   justiz = {
--     deny  = { "question.ask" },
--     allow = { "submissions.approve", "submissions.reject" },
--   },
-- }

Config.JustizFallback = {
  sehen = {
    eingang = true,
    zugewiesen = true,
    alleKategorie = false,
    archiv = false
  },
  aktionen = {
    antragUebernehmen = true,
    statusAendern = true,
    prioritaetAendern = false,
    interneNotizSchreiben = false,
    oeffentlicheAntwortSchreiben = true,
    rueckfrageStellen = true,
    zuweisen = false,
    genehmigen = false,
    ablehnen = false,
    weiterleiten = false,
    eskalieren = false,
    archivieren = false,
    loeschen = false
  }
}

Config.Kategorien = {
  Aktiviert = true,
  Liste = {
    ["general"] = {
      id = "general",
      name = "Allgemein",
      beschreibung = "Allgemeine Anträge an das Justizzentrum",
      icon = "file",
      sortierung = 1,
      aktiv = true,

      fuerBuergerSichtbar = true,
      nurIntern = false,

      standardPrioritaet = "normal",
      standardFristStunden = 72,

      erlaubteStatus = { "draft", "submitted", "in_review", "question_open", "approved", "rejected", "archived" },

      ui = { farbe = "#2f80ed" },

      zugriff = {
        justiz = {
          job = "doj",
          erlaubteGrade = { 0, 1, 2, 3, 4, 5 },

          aktionenProGrade = {
            [2] = {
              sehen = { eingang = true, zugewiesen = true, alleKategorie = true, archiv = true },
              aktionen = {
                antragUebernehmen = true,
                statusAendern = true,
                prioritaetAendern = true,
                interneNotizSchreiben = true,
                oeffentlicheAntwortSchreiben = true,
                rueckfrageStellen = true,
                zuweisen = true,
                genehmigen = true,
                ablehnen = true,
                weiterleiten = true,
                eskalieren = true,
                archivieren = true,
                loeschen = false
              }
            }
          }
        },

        adminImmer = true
      },

      -- PermissionService-Override für Kategorie "general":
      -- Justiz-Mitglieder mit Grade >= 2 dürfen archivieren, zuweisen,
      -- interne Notizen schreiben sowie den Formular-Editor vollständig nutzen.
      -- Grade 0–1 bleiben auf die globalen Justiz-Defaults beschränkt.
      permissions = {
        justiz = {
          grade = { min = 2 },
          allow = {
            "submissions.archive",
            "submissions.assign",
            "submissions.set_priority",
            "submissions.view_all",
            "submissions.view_archive",
            "notes.internal.write",
            "form_editor.publish",
            "form_editor.archive",
          },
          deny = {},
        },
      },

      -- Workflow-Regeln: SLA, erlaubte Statusübergänge, SLA-Pause-Statuses
      workflow = {
        -- SLA in Stunden; Fallback: Config.Workflows.Sla.DefaultSlaHours
        sla_hours = 48,

        -- Statuses, in denen der SLA-Countdown pausiert
        pause_sla_in_statuses = { "question_open" },

        -- Erlaubte Folge-Statuses pro Ausgangs-Status.
        -- Wenn definiert, werden Übergänge serverseitig strikt erzwungen.
        erlaubteFolgeStatus = {
          ["draft"]         = { "submitted" },
          ["submitted"]     = { "in_review", "rejected" },
          ["in_review"]     = { "question_open", "approved", "rejected" },
          ["question_open"] = { "in_review", "rejected" },
          ["approved"]      = { "archived" },
          ["rejected"]      = { "archived" },
        },
      },

      webhooks = {}
    },

    -- ==========================
    -- BEISPIEL 1: Gewerbe
    -- ==========================
    ["gewerbe"] = {
      id = "gewerbe",
      name = "Gewerbe",
      beschreibung = "Gewerbeanmeldungen / Genehmigungen / Rückfragen",
      icon = "briefcase",
      sortierung = 2,
      aktiv = true,

      fuerBuergerSichtbar = true,
      nurIntern = false,

      standardPrioritaet = "normal",
      standardFristStunden = 96,

      erlaubteStatus = { "draft", "submitted", "in_review", "question_open", "approved", "rejected", "archived" },

      ui = { farbe = "#27ae60" },

      zugriff = {
        justiz = {
          job = "doj",
          erlaubteGrade = { 0, 1, 2, 3, 4, 5 },

          aktionenProGrade = {
            [1] = {
              sehen = { eingang = true, zugewiesen = true, alleKategorie = false, archiv = false },
              aktionen = {
                antragUebernehmen = true,
                statusAendern = true,
                prioritaetAendern = false,
                interneNotizSchreiben = false,
                oeffentlicheAntwortSchreiben = true,
                rueckfrageStellen = true,
                zuweisen = false,
                genehmigen = false,
                ablehnen = false,
                weiterleiten = false,
                eskalieren = false,
                archivieren = false,
                loeschen = false
              }
            },
            [3] = {
              sehen = { eingang = true, zugewiesen = true, alleKategorie = true, archiv = true },
              aktionen = {
                antragUebernehmen = true,
                statusAendern = true,
                prioritaetAendern = true,
                interneNotizSchreiben = true,
                oeffentlicheAntwortSchreiben = true,
                rueckfrageStellen = true,
                zuweisen = true,
                genehmigen = true,
                ablehnen = true,
                weiterleiten = true,
                eskalieren = true,
                archivieren = true,
                loeschen = false
              }
            }
          }
        },

        adminImmer = true
      },

      -- PermissionService-Override für Kategorie "gewerbe":
      -- Grade 0–1 dürfen nur Status ändern und öffentlich antworten.
      -- Grade 3+ erhalten erweiterte Aktionen inkl. Archivieren und interne Notizen.
      -- question.ask ist für alle Justiz-Grades in dieser Kategorie verboten
      -- (Gewerbeanträge sollen direkt genehmigt/abgelehnt werden).
      permissions = {
        justiz = {
          grade = { min = 3 },
          allow = {
            "submissions.archive",
            "submissions.assign",
            "submissions.set_priority",
            "submissions.view_all",
            "submissions.view_archive",
            "notes.internal.write",
            "form_editor.publish",
            "form_editor.archive",
          },
          deny = { "question.ask" },
        },
      },

      -- Workflow-Regeln für "gewerbe": kürzere SLA, keine Rückfragen
      workflow = {
        sla_hours = 96,
        pause_sla_in_statuses = {},
        erlaubteFolgeStatus = {
          ["draft"]     = { "submitted" },
          ["submitted"] = { "in_review", "rejected" },
          ["in_review"] = { "approved", "rejected" },
          ["approved"]  = { "archived" },
          ["rejected"]  = { "archived" },
        },
      },

      webhooks = {}
    }
  }
}

Config.Formulare = {
  Aktiviert = true,
  Versionierung = { Aktiviert = true },

  Liste = {
    ["general_request"] = {
      id = "general_request",
      titel = "Allgemeiner Antrag",
      interneBezeichnung = "ALLGEMEINER_ANTRAG",
      beschreibung = "Standard-Antrag an das Justizzentrum",
      kategorieId = "general",

      aktiv = true,
      fuerBuergerSichtbar = true,

      buergerDuerfenEinreichen = true,
      nurJustizDarfErstellen = false,

      gebuehren = { aktiv = false, betrag = 0, erstattbar = false },

      cooldownSekunden = 60,
      maxOffenProSpieler = 3,
      duplikatPruefung = { aktiv = true },

      standardStatus = "submitted",
      standardPrioritaet = "normal",

      zuweisung = {
        autoZuweisungAktiv = false,
        erlaubteBearbeiterJobs = { "doj", "admin" },
        erlaubterMindestGrad = 0,
      },

      fristen = { fristStunden = 72 },

      -- Hinweis:
      -- citizen_name wird serverseitig automatisch als Pflichtfeld eingefügt.
      -- Du musst es hier NICHT definieren.
      felder = {
        {
          id = "subject",
          key = "subject",
          label = "Betreff",
          beschreibung = "Kurze Zusammenfassung",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 3,
          maxLaenge = 60,
          placeholder = "z.B. Antrag auf ...",
          reihenfolge = 1,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "details",
          key = "details",
          label = "Beschreibung",
          beschreibung = "Bitte ausführlich beschreiben",
          typ = "longtext",
          pflicht = true,
          minLaenge = 10,
          maxLaenge = 2000,
          placeholder = "Beschreibe dein Anliegen...",
          reihenfolge = 2,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        }
      }
    },

    -- ==========================
    -- BEISPIEL 2: Allgemeiner Antrag MIT Telefon/E-Mail Pflicht
    -- (shorttext + Regex, wie von dir gewünscht)
    -- ==========================
    ["general_request_contact"] = {
      id = "general_request_contact",
      titel = "Allgemeiner Antrag (mit Kontaktdaten)",
      interneBezeichnung = "ALLGEMEINER_ANTRAG_KONTAKT",
      beschreibung = "Wie Standard, aber zusätzlich Pflichtfelder für Telefon & E-Mail.",
      kategorieId = "general",

      aktiv = true,
      fuerBuergerSichtbar = true,

      buergerDuerfenEinreichen = true,
      nurJustizDarfErstellen = false,

      gebuehren = { aktiv = false, betrag = 0, erstattbar = false },

      cooldownSekunden = 60,
      maxOffenProSpieler = 3,
      duplikatPruefung = { aktiv = true },

      standardStatus = "submitted",
      standardPrioritaet = "normal",

      zuweisung = {
        autoZuweisungAktiv = false,
        erlaubteBearbeiterJobs = { "doj", "admin" },
        erlaubterMindestGrad = 0,
      },

      fristen = { fristStunden = 72 },

      felder = {
        {
          id = "email",
          key = "email",
          label = "E-Mail-Adresse",
          beschreibung = "Bitte eine gültige E-Mail-Adresse angeben.",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 6,
          maxLaenge = 120,
          -- Lua pattern (einfach, bewusst nicht 100% RFC):
          regex = "^[^%s@]+@[^%s@]+%.[^%s@]+$",
          placeholder = "z.B. name@domain.de",
          reihenfolge = 1,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "phone",
          key = "phone",
          label = "Telefonnummer",
          beschreibung = "Nur Zahlen und übliche Zeichen (+ - Leerzeichen Klammern).",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 6,
          maxLaenge = 30,
          regex = "^[0-9%+%-%s%(%)]+$",
          placeholder = "z.B. +49 170 1234567",
          reihenfolge = 2,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "subject",
          key = "subject",
          label = "Betreff",
          beschreibung = "Kurze Zusammenfassung",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 3,
          maxLaenge = 60,
          placeholder = "z.B. Antrag auf ...",
          reihenfolge = 3,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "details",
          key = "details",
          label = "Beschreibung",
          beschreibung = "Bitte ausführlich beschreiben",
          typ = "longtext",
          pflicht = true,
          minLaenge = 10,
          maxLaenge = 2000,
          placeholder = "Beschreibe dein Anliegen...",
          reihenfolge = 4,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        }
      }
    },

    -- ==========================
    -- BEISPIEL 3: Gewerbe-Anmeldung (Kategorie "gewerbe")
    -- ==========================
    ["gewerbe_anmeldung"] = {
      id = "gewerbe_anmeldung",
      titel = "Gewerbe anmelden",
      interneBezeichnung = "GEWERBE_ANMELDUNG",
      beschreibung = "Anmeldung eines neuen Gewerbes (inkl. Pflicht-Kontakt).",
      kategorieId = "gewerbe",

      aktiv = true,
      fuerBuergerSichtbar = true,

      buergerDuerfenEinreichen = true,
      nurJustizDarfErstellen = false,

      gebuehren = { aktiv = false, betrag = 0, erstattbar = false },

      cooldownSekunden = 120,
      maxOffenProSpieler = 2,
      duplikatPruefung = { aktiv = true },

      standardStatus = "submitted",
      standardPrioritaet = "normal",

      zuweisung = {
        autoZuweisungAktiv = false,
        erlaubteBearbeiterJobs = { "doj", "admin" },
        erlaubterMindestGrad = 0,
      },

      fristen = { fristStunden = 96 },

      felder = {
        {
          id = "email",
          key = "email",
          label = "E-Mail-Adresse",
          beschreibung = "Bitte eine gültige E-Mail-Adresse angeben.",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 6,
          maxLaenge = 120,
          regex = "^[^%s@]+@[^%s@]+%.[^%s@]+$",
          placeholder = "z.B. name@domain.de",
          reihenfolge = 1,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "phone",
          key = "phone",
          label = "Telefonnummer",
          beschreibung = "Nur Zahlen und übliche Zeichen (+ - Leerzeichen Klammern).",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 6,
          maxLaenge = 30,
          regex = "^[0-9%+%-%s%(%)]+$",
          placeholder = "z.B. +49 170 1234567",
          reihenfolge = 2,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "gewerbe_name",
          key = "gewerbe_name",
          label = "Name des Gewerbes",
          beschreibung = "Wie soll das Gewerbe heißen?",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 3,
          maxLaenge = 80,
          placeholder = "z.B. Autohaus Mustermann",
          reihenfolge = 3,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "gewerbe_art",
          key = "gewerbe_art",
          label = "Art des Gewerbes",
          beschreibung = "Was wird angeboten/verkauft?",
          typ = "longtext",
          pflicht = true,
          minLaenge = 10,
          maxLaenge = 2000,
          placeholder = "Bitte beschreiben...",
          reihenfolge = 4,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "adresse",
          key = "adresse",
          label = "Adresse / Standort des Gewerbes",
          beschreibung = "Wo befindet sich das Gewerbe?",
          typ = "shorttext",
          pflicht = true,
          minLaenge = 5,
          maxLaenge = 120,
          placeholder = "z.B. Strawberry Ave 12",
          reihenfolge = 5,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "oeffnungszeiten",
          key = "oeffnungszeiten",
          label = "Öffnungszeiten (optional)",
          beschreibung = "Optional, falls relevant.",
          typ = "shorttext",
          pflicht = false,
          minLaenge = 0,
          maxLaenge = 120,
          placeholder = "z.B. Mo-Fr 10-18 Uhr",
          reihenfolge = 6,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        }
      }
    },

    -- ==============================================================
    -- DEMO: Formular mit ALLEN Feldtypen (Lastenheft – PR #5)
    -- Dieses Formular dient als Referenz und Akzeptanztest.
    -- Kann deaktiviert werden mit: aktiv = false
    -- ==============================================================
    ["alle_feldtypen_demo"] = {
      id = "alle_feldtypen_demo",
      titel = "Demo: Alle Feldtypen",
      interneBezeichnung = "ALLE_FELDTYPEN",
      beschreibung = "Referenzformular mit allen unterstützten Feldtypen.",
      kategorieId = "general",

      aktiv = true,
      fuerBuergerSichtbar = true,
      buergerDuerfenEinreichen = true,
      nurJustizDarfErstellen = false,

      gebuehren = { aktiv = false, betrag = 0, erstattbar = false },
      cooldownSekunden = 30,
      maxOffenProSpieler = 5,
      duplikatPruefung = { aktiv = false },
      standardStatus = "submitted",
      standardPrioritaet = "normal",
      zuweisung = {
        autoZuweisungAktiv = false,
        erlaubteBearbeiterJobs = { "doj", "admin" },
        erlaubterMindestGrad = 0,
      },
      fristen = { fristStunden = 72 },

      felder = {
        -- Dekorative Felder
        {
          id = "h_allgemein", key = "h_allgemein",
          label = "Allgemeine Angaben",
          typ = "heading",
          reihenfolge = 0,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "info_hinweis", key = "info_hinweis",
          label = "Bitte alle Felder sorgfältig ausfüllen.",
          typ = "info",
          reihenfolge = 1,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Texteingaben
        {
          id = "kurztitel", key = "kurztitel",
          label = "Kurzbezeichnung",
          beschreibung = "Bis zu 60 Zeichen",
          typ = "text_short",
          pflicht = true,
          minLaenge = 3, maxLaenge = 60,
          placeholder = "Stichwort oder Titel",
          reihenfolge = 2,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "langbeschreibung", key = "langbeschreibung",
          label = "Ausführliche Beschreibung",
          typ = "text_long",
          pflicht = true,
          minLaenge = 10, maxLaenge = 3000,
          reihenfolge = 3,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Trennlinie
        {
          id = "divider_1", key = "divider_1",
          label = "",
          typ = "divider",
          reihenfolge = 4,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Zahlen / Beträge
        {
          id = "anzahl", key = "anzahl",
          label = "Anzahl",
          typ = "number",
          pflicht = false,
          min = 1, max = 1000,
          reihenfolge = 5,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "betrag_eur", key = "betrag_eur",
          label = "Betrag (€)",
          beschreibung = "Bitte in Euro (z.B. 123.45)",
          typ = "amount",
          pflicht = false,
          min = 0, max = 1000000,
          reihenfolge = 6,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Datum / Zeit
        {
          id = "ereignis_datum", key = "ereignis_datum",
          label = "Datum des Ereignisses",
          beschreibung = "Format: JJJJ-MM-TT",
          typ = "date",
          pflicht = false,
          reihenfolge = 7,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "ereignis_uhrzeit", key = "ereignis_uhrzeit",
          label = "Uhrzeit",
          beschreibung = "Format: HH:MM",
          typ = "time",
          pflicht = false,
          reihenfolge = 8,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "termin_datetime", key = "termin_datetime",
          label = "Termindatum + Uhrzeit",
          typ = "datetime",
          pflicht = false,
          reihenfolge = 9,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Auswahl
        {
          id = "kategorie_auswahl", key = "kategorie_auswahl",
          label = "Kategorie",
          typ = "select",
          pflicht = true,
          optionen = {
            { value = "privat",  label = "Privat" },
            { value = "gewerblich", label = "Gewerblich" },
            { value = "sonstiges", label = "Sonstiges" },
          },
          reihenfolge = 10,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "interessen", key = "interessen",
          label = "Relevante Bereiche (Mehrfachauswahl)",
          typ = "multiselect",
          pflicht = false,
          optionen = {
            { value = "recht",   label = "Recht" },
            { value = "finanzen", label = "Finanzen" },
            { value = "immobilien", label = "Immobilien" },
            { value = "fahrzeuge", label = "Fahrzeuge" },
          },
          reihenfolge = 11,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "prioritaet_wunsch", key = "prioritaet_wunsch",
          label = "Gewünschte Bearbeitungspriorität",
          typ = "radio",
          pflicht = false,
          optionen = {
            { value = "niedrig", label = "Niedrig" },
            { value = "normal",  label = "Normal" },
            { value = "hoch",    label = "Hoch" },
          },
          standardwert = "normal",
          reihenfolge = 12,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Boolean
        {
          id = "datenschutz_akzeptiert", key = "datenschutz_akzeptiert",
          label = "Ich stimme der Datenschutzerklärung zu",
          typ = "checkbox",
          pflicht = true,
          reihenfolge = 13,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },

        -- Spezialfelder
        {
          id = "webseite", key = "webseite",
          label = "Webseite (optional)",
          beschreibung = "Muss mit http:// oder https:// beginnen",
          typ = "url",
          pflicht = false,
          maxLaenge = 200,
          reihenfolge = 14,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "fahrzeug_kennzeichen", key = "fahrzeug_kennzeichen",
          label = "Fahrzeugkennzeichen",
          beschreibung = "z.B. AB 1234",
          typ = "license_plate",
          pflicht = false,
          reihenfolge = 15,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "spieler_ref", key = "spieler_ref",
          label = "Betroffener Spieler",
          beschreibung = "Name oder Identifier des Spielers",
          typ = "player_reference",
          pflicht = false,
          reihenfolge = 16,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "firma_ref", key = "firma_ref",
          label = "Unternehmen / Firma",
          typ = "company_reference",
          pflicht = false,
          reihenfolge = 17,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
        {
          id = "aktenzeichen", key = "aktenzeichen",
          label = "Bezug-Aktenzeichen",
          beschreibung = "Falls bekannt: z.B. DOJ-2024-000123",
          typ = "case_number",
          pflicht = false,
          reihenfolge = 18,
          sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
        },
      }
    }
  }
}

Config.Status = {
  Aktiviert = true,
  Liste = {
    ["draft"] = {
      id = "draft", label = "Entwurf", farbe = "#9aa0a6", sortierung = 1,
      -- Metadaten
      sichtbarFuerBuerger   = false,  -- Entwurf ist für Bürger noch nicht sichtbar
      sichtbarFuerJustiz    = true,
      bearbeitbar           = true,   -- Bürger darf Entwurf noch bearbeiten
      erlaubtBuergerAntwort = false,
      erlaubtNachreichung   = false,
      erlaubtInterneNotiz   = true,
      erlaubteFolgeStatus   = { "submitted" },
    },
    ["submitted"] = {
      id = "submitted", label = "Eingereicht", farbe = "#2f80ed", sortierung = 2,
      sichtbarFuerBuerger   = true,
      sichtbarFuerJustiz    = true,
      bearbeitbar           = false,
      erlaubtBuergerAntwort = false,
      erlaubtNachreichung   = false,
      erlaubtInterneNotiz   = true,
      erlaubteFolgeStatus   = { "in_review", "question_open", "approved", "rejected", "archived" },
    },
    ["in_review"] = {
      id = "in_review", label = "In Prüfung", farbe = "#f2c94c", sortierung = 3,
      sichtbarFuerBuerger   = true,
      sichtbarFuerJustiz    = true,
      bearbeitbar           = false,
      erlaubtBuergerAntwort = false,
      erlaubtNachreichung   = true,   -- Bürger darf Dokumente nachreichen
      erlaubtInterneNotiz   = true,
      erlaubteFolgeStatus   = { "question_open", "approved", "rejected", "archived" },
    },
    ["question_open"] = {
      id = "question_open", label = "Rückfrage offen", farbe = "#bb6bd9", sortierung = 4,
      sichtbarFuerBuerger   = true,
      sichtbarFuerJustiz    = true,
      bearbeitbar           = false,
      erlaubtBuergerAntwort = true,   -- Bürger darf auf Rückfrage antworten
      erlaubtNachreichung   = true,
      erlaubtInterneNotiz   = true,
      erlaubteFolgeStatus   = { "in_review", "approved", "rejected", "archived" },
    },
    ["approved"] = {
      id = "approved", label = "Genehmigt", farbe = "#27ae60", sortierung = 10,
      sichtbarFuerBuerger   = true,
      sichtbarFuerJustiz    = true,
      bearbeitbar           = false,
      erlaubtBuergerAntwort = false,
      erlaubtNachreichung   = false,
      erlaubtInterneNotiz   = true,
      erlaubteFolgeStatus   = { "archived" },
    },
    ["rejected"] = {
      id = "rejected", label = "Abgelehnt", farbe = "#eb5757", sortierung = 11,
      sichtbarFuerBuerger   = true,
      sichtbarFuerJustiz    = true,
      bearbeitbar           = false,
      erlaubtBuergerAntwort = false,
      erlaubtNachreichung   = false,
      erlaubtInterneNotiz   = true,
      erlaubteFolgeStatus   = { "archived" },
    },
    ["archived"] = {
      id = "archived", label = "Archiviert", farbe = "#4f4f4f", sortierung = 99,
      sichtbarFuerBuerger   = true,
      sichtbarFuerJustiz    = true,
      bearbeitbar           = false,
      erlaubtBuergerAntwort = false,
      erlaubtNachreichung   = false,
      erlaubtInterneNotiz   = false,
      erlaubteFolgeStatus   = {},
    },
  }
}

Config.Prioritaeten = {
  Aktiviert = true,
  Liste = {
    { id = "low", label = "Niedrig", farbe = "#56ccf2", sortierung = 1 },
    { id = "normal", label = "Normal", farbe = "#2f80ed", sortierung = 2 },
    { id = "high", label = "Hoch", farbe = "#f2994a", sortierung = 3 },
    { id = "urgent", label = "Dringend", farbe = "#eb5757", sortierung = 4 },
  }
}

-- =============================================================
-- Config.Workflows
-- Workflow-Engine: SLA/Fristen, Leitung-Erkennung, Eskalation,
-- Soft-Locks und erlaubte Statusübergänge.
-- Alle Einstellungen sind über config.lua und/oder
-- data/admin_overrides.json (Live-Override) änderbar.
-- =============================================================
Config.Workflows = {
  Aktiviert = true,

  -- Leitung-Erkennung: ab welchem DOJ-Jobgrad gilt ein Justiz-Mitglied
  -- als Leitung (SLA-Pause/-Override, Lock-Override, Eskalierungs-Empfänger).
  Leitung = {
    MinGrade = 29,
  },

  -- SLA / Fristen
  Sla = {
    -- Standard-SLA in Stunden, wenn für eine Kategorie nichts definiert.
    DefaultSlaHours = 48,
    -- Periodischer SLA-Check-Intervall in Sekunden (30–60 empfohlen).
    TickIntervalSekunden = 30,
  },

  Sperren = {
    -- Soft-Locks: Server blockiert Schreibzugriffe wenn ein anderer Bearbeiter
    -- die Sperre hält. Leitung (Grade >= Config.Workflows.Leitung.MinGrade) und
    -- Admin können Sperren immer überschreiben.
    Aktiviert = true,
    ExklusiveBearbeitung = true,
    -- Ablauf-Timeout in Sekunden (default: 10 min = 600s).
    TimeoutSekunden = 600,
    HeartbeatSekunden = 45,
  },

  Eskalation = {
    Aktiviert = true,
    UeberfaelligNachStunden = 72,
  },
}

Config.Benachrichtigungen = {
  Aktiviert = true,
  Ingame = {
    Aktiviert = true,
    Anbieter = "esx",
    StandardDauerMs = 5500,
  },
  -- Konfigurierbare Nachrichtentexte für Ingame-Benachrichtigungen.
  -- Platzhalter: {id} = Aktenzeichen, {status} = neuer Status,
  --              {alt} = alter Status, {formular} = Formularname
  Texte = {
    antrag_eingereicht  = "Dein Antrag wurde unter Aktenzeichen {id} erfolgreich eingereicht.",
    status_geaendert    = "Dein Antrag {id} wurde auf Status '{status}' gesetzt.",
    rueckfrage_gestellt = "Zum Antrag {id} wurde eine Rückfrage gestellt. Bitte beantworte diese im Bürgerportal.",
    oeffentliche_antwort = "Zu deinem Antrag {id} gibt es eine neue Nachricht der Behörde.",
    antrag_genehmigt    = "Dein Antrag {id} wurde genehmigt.",
    antrag_abgelehnt    = "Dein Antrag {id} wurde abgelehnt.",
  }
}

Config.Webhooks = {
  Aktiviert = true,
  -- Webhook-Logs in der Datenbank speichern (Tabelle hm_bp_webhook_logs).
  -- Nur aktivieren, wenn die Tabelle per Migration angelegt wurde.
  LogsInDB = false,
  Identitaet = {
    Benutzername = "HM Bürgerportal",
    AvatarUrl = nil,
    Footer = "HM Training - Felix Hoffmann",
  },
  Warteschlange = {
    Aktiviert = true,
    MaxGroesse = 5000,
    WorkerIntervallMs = 750,
    MaxProIntervall = 5,
    Wiederholung = {
      Aktiviert = true,
      MaxVersuche = 5,
      BackoffMs = { 1000, 3000, 7000, 15000, 30000 }
    }
  },
  Routing = {
    -- Webhook-URL als Fallback, wenn kein anderer Eintrag greift
    Fallback = nil,

    -- Pro Event-Key eine Webhook-URL eintragen.
    -- Verfügbare Event-Keys (lower_snake_case):
    --   antrag_created              – Neuer Antrag eingereicht
    --   antrag_status_changed       – Status eines Antrags geändert
    --   antrag_assigned             – Antrag einem Bearbeiter zugewiesen
    --   antrag_priority_changed     – Priorität geändert
    --   antrag_archived             – Antrag archiviert
    --   antrag_question_asked       – Justiz stellt Rückfrage
    --   antrag_citizen_replied      – Bürger antwortet auf Rückfrage
    --   antrag_staff_public_reply   – Öffentliche Antwort durch Justiz
    --   antrag_staff_internal_note  – Interne Notiz durch Justiz
    --   form_editor_form_created    – Neues Formular im Editor erstellt
    --   form_editor_schema_saved    – Schema-Entwurf gespeichert
    --   form_editor_published       – Formular veröffentlicht
    --   form_editor_archived        – Formular archiviert
    --   anhang_hinzugefuegt         – Anhang zu Antrag hinzugefügt (PR8)
    --   anhang_entfernt             – Anhang von Antrag entfernt (PR8)
    --
    -- Beispiel:
    --   NachEvent = {
    --     antrag_created = "https://discord.com/api/webhooks/...",
    --     antrag_citizen_replied = "https://discord.com/api/webhooks/...",
    --   },
    NachEvent = {},

    -- Pro Kategorie-ID eine Webhook-URL eintragen.
    -- Beispiel: NachKategorie = { ["general"] = "https://..." }
    NachKategorie = {},

    -- Pro Formular-ID eine Webhook-URL eintragen.
    -- Beispiel: NachFormular = { ["general_request"] = "https://..." }
    NachFormular = {}
  },

  -- ----------------------------------------------------------
  -- Dedizierte Webhook-URLs (PR11+)
  -- Für spezifische Systemfunktionen (nicht antragsbezogen).
  -- Der Schlüssel wird direkt als Event-Name verwendet.
  -- ----------------------------------------------------------
  -- pdf_export: Discord-Webhook-URL für PDF-Export-Benachrichtigungen.
  -- Jedes erzeugte PDF wird mit Akteur (Spielername + Charname) und
  -- Aktenzeichen als Embed in diesen Discord-Kanal gepostet.
  -- PFLICHT für Discord-Export: Trage hier die vollständige Discord-Webhook-URL ein.
  -- Solange dieser Wert nil ist, werden keine Benachrichtigungen gesendet.
  -- Beispiel:
  --   ["pdf_export"] = "https://discord.com/api/webhooks/XXXXXX/XXXXXX",
  Urls = {
    ["pdf_export"] = nil,
    -- antrag_escalation: Separater Discord-Webhook-Kanal für SLA-Eskalationen (PR13).
    -- Eskalations- und Reminder-Embeds enthalten Akteur = "System (SLA)" + Aktenzeichen.
    -- Beispiel:
    --   ["antrag_escalation"] = "https://discord.com/api/webhooks/XXXXXX/XXXXXX",
    ["antrag_escalation"] = nil,
  }
}

-- =============================================================
-- Config.Suche
-- Sucheinstellungen für Justiz- und Admin-Queues.
-- Aktiviert/deaktivierbar; Standard- und Maximalwerte für
-- Seitenanzahl und Suchtext-Länge konfigurierbar.
-- Wird über AdminConfigService verwaltet und ist per
-- data/admin_overrides.json live überschreibbar.
-- =============================================================
Config.Suche = {
  -- Suche/Filter insgesamt aktivieren
  Aktiviert = true,

  -- Standard-Seitengröße (Einträge pro Seite)
  StandardProSeite = 25,

  -- Maximale Seitengröße (Schutz vor übermäßigen DB-Abfragen)
  MaxProSeite = 100,

  -- Maximale Länge des Suchtexts (Bürgername)
  MaxSuchtextLaenge = 64,
}

Config.AntiSpam = {
  Aktiviert = true,
  GlobalerCooldownSekunden = 15,
  MaxOffeneAntraegeProSpieler = 5,
  MinTextLaenge = 3,
  MaxTextLaenge = 2000,
  DuplikatPruefung = { Aktiviert = true, FensterMinuten = 30 },
  RateLimit = { Aktiviert = true, MaxAktionen = 20, ProSekunden = 60 }
}

Config.Archiv = {
  Aktiviert = true,
  AutoArchiv = { Aktiviert = true, NachTagen = 30 },
  Sichtbarkeit = { Buerger = true, Justiz = true, Admin = true },
  Wiederherstellung = { Aktiviert = true },
  HartLoeschen = { Aktiviert = true, NurAdmin = true, GrundPflicht = true }
}

Config.Entwuerfe = {
  Aktiviert = false,
  AutoLoeschenNachTagen = 14
}

-- =============================================================
-- Config.Module
-- Feature-Flags: Aktiviere/Deaktiviere Hauptsysteme.
-- Alle Flags sind über config.lua (Basis) und/oder
-- data/admin_overrides.json (Live-Override) änderbar.
-- =============================================================
Config.Module = {
  -- Admin-UI: Adminbereich in der NUI anzeigen und bedienbar machen.
  AdminUI          = true,

  -- Anhänge: Bild-Links an Anträge anhängen (PR8).
  Anhaenge         = true,

  -- Gebühren: Gebührenkonfiguration an Formularen (Implementierung folgt).
  Gebuehren        = false,

  -- Delegation: Anträge an andere Bearbeiter weiterdelegieren (Implementierung folgt).
  Delegation       = false,

  -- Entwürfe: Bürger kann Anträge als Entwurf speichern.
  Entwuerfe        = false,

  -- Exporte: Anträge/Berichte als CSV/PDF exportieren (PR11).
  Exporte          = true,

  -- Audit-Härtung: Erweiterte Audit-Sicherheit und Unveränderlichkeit der Logs.
  AuditHaertung    = true,

  -- Webhooks: Discord-Webhook-Benachrichtigungen.
  Webhooks         = true,

  -- Benachrichtigungen: Ingame-Benachrichtigungen an Spieler.
  Benachrichtigungen = true,
}

-- =============================================================
-- Config.Anhaenge
-- Bild-Anhänge als URL-Links (kein lokaler Upload).
-- Whitelist: Imgur + Discord CDN.
-- Bürger darf Anhänge nur in erlaubten Status hinzufügen.
-- Justiz/Admin sieht immer alle Anhänge.
-- Alle Einstellungen sind über config.lua und/oder
-- data/admin_overrides.json (Live-Override) änderbar.
-- =============================================================
Config.Anhaenge = {
  Aktiviert = true,

  -- Maximale Anzahl Anhänge pro Antrag (gesamt, inkl. aller Rollen)
  MaxProAntrag = 10,

  -- Erlaubte URL-Schemes (nur https empfohlen)
  ErlaubteSchemes = { "https" },

  -- Erlaubte Hosts (Whitelist). Nur URLs von diesen Domains werden akzeptiert.
  -- Imgur: i.imgur.com (Direktlinks), imgur.com (Seiten-Links)
  -- Discord: cdn.discordapp.com, media.discordapp.net
  ErlaubteHosts = {
    "i.imgur.com",
    "imgur.com",
    "cdn.discordapp.com",
    "media.discordapp.net",
  },

  -- Direktlink-Erkennung: Endungen, die als direktes Bild-URL gewertet werden
  -- → UI zeigt dann eine Vorschau (<img>). Alle anderen Links werden nur als
  --   klickbarer Hyperlink angezeigt (kein <img>-Preview).
  DirektlinkEndungen = { ".png", ".jpg", ".jpeg", ".webp", ".gif" },

  -- Status, in denen ein Bürger Anhänge hinzufügen darf.
  -- Justiz/Admin kann immer Anhänge hinzufügen und entfernen.
  BuergerErlaubteStatus = { "submitted", "question_open" },

  Preview = {
    -- true = nur bei erkanntem Direktlink wird ein <img>-Preview gezeigt
    NurBeiDirektlink = true,
  },
}

-- Formular-Editor (Entwurf/Veröffentlicht) – Serverlogik hast du bereits.
Config.FormularEditor = {
  Aktiviert = true,
  AdminHatImmerZugriff = true,

  Kategorien = {
    ["general"] = {
      editor = { rolle = "justiz", job = "doj", mindestGrad = 2 },
      publisher = { rolle = "justiz", job = "doj", mindestGrad = 4 },
      archivierer = { rolle = "justiz", job = "doj", mindestGrad = 4 }
    },
    ["gewerbe"] = {
      editor = { rolle = "justiz", job = "doj", mindestGrad = 1 },
      publisher = { rolle = "justiz", job = "doj", mindestGrad = 3 },
      archivierer = { rolle = "justiz", job = "doj", mindestGrad = 3 }
    }
  }
}
-- =============================================================
-- Config.Audit
-- Unveränderliche Audit-Logs (PR12): Retention, Cleanup-Job.
-- =============================================================
Config.Audit = {
  -- Aktiviert: Audit-Logs schreiben und Cleanup-Job ausführen.
  Aktiviert = true,

  -- Retention: Audit-Einträge werden nach TageMax Tagen automatisch gelöscht.
  -- Cleanup läuft beim Serverstart und dann alle IntervalSekunden Sekunden.
  Retention = {
    TageMax = 90,
  },

  Cleanup = {
    -- Intervall in Sekunden zwischen zwei Cleanup-Läufen (Standard: 1 Stunde).
    IntervalSekunden = 3600,
  },

  -- Leitung-Zugriff auf Audit-Log-Ansicht:
  -- Admin hat immer Zugriff (via *-Permission).
  -- Justiz-Leitung (grade >= Config.Workflows.Leitung.MinGrade) bekommt
  -- Lesezugriff auf den Audit-Log-Viewer (kein actor_identifier sichtbar).
  LeitungDarfLesen = true,
}

-- =============================================================
-- Config.SLA
-- Fristen/Eskalation (PR13): Erste-Bearbeitungs-SLA.
--
-- ErsteBearbeitungStunden:
--   Frist in Stunden ab Einreichung, nach der ein Antrag als
--   „nicht bearbeitet" gilt, wenn noch kein Justiz/Admin-
--   Kommentar oder Rückfrage eingetragen wurde.
--
-- ReminderIntervalStunden:
--   Mindestabstand zwischen wiederholten Reminder-Webhooks
--   (falls Eskalation noch nicht aufgelöst ist).
--
-- TickIntervalSekunden:
--   Wie oft der SLA-Checker läuft (Sekunden).
--   Empfohlen: 60–300.
--
-- Webhook:
--   Eskalations- und Reminder-Benachrichtigungen werden über
--   Config.Webhooks.Urls["antrag_escalation"] gesendet.
--   Solange dieser Wert nil ist, werden keine Webhooks gesendet.
-- =============================================================
Config.SLA = {
  Aktiviert = true,

  -- Standard-Frist bis zur „ersten Bearbeitung" in Stunden.
  -- „Erste Bearbeitung" = erster Justiz/Admin-Kommentar oder Rückfrage.
  ErsteBearbeitungStunden = 24,

  -- Mindestabstand zwischen Reminder-Webhooks in Stunden.
  ReminderIntervalStunden = 6,

  -- Intervall des SLA-Checkers in Sekunden.
  TickIntervalSekunden = 60,
}
