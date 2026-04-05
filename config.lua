Config = {}

Config.Kern = {
  RessourcenName = "hm_buergerportal",
  Sprache = "de",

  Framework = "esx",

  Jobs = {
    Admin = "admin",
    Justiz = "doj",
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

  Liste = {
    ["doj_frontdesk_1"] = {
      id = "doj_frontdesk_1",
      name = "Justizzentrum Empfang",
      aktiv = true,

      koordinaten = vector3(440.12, -981.92, 30.69),
      heading = 90.0,

      interaktionsRadius = 2.0,
      sichtbarRadius = 30.0,

      interaktion = {},

      zugriff = {
        nurBuerger = false,
        nurJustiz = false,
        nurAdmin = false,

        erlaubteJobs = { "doj", "admin" },

        erlaubteKategorien = {},
        erlaubteFormulare = {},
      },

      ped = {
        aktiv = true,
        modell = "s_m_y_cop_01",
        scenario = "WORLD_HUMAN_CLIPBOARD",
        unverwundbar = true,
        eingefroren = true,
        blockiereEvents = true,
      },

      marker = {
        aktiv = true,
        typ = 2,
        groesse = vector3(0.3, 0.3, 0.3),
        farbe = { r = 0, g = 120, b = 255, a = 160 },
      },

      blip = {
        aktiv = true,
        sprite = 525,
        farbe = 3,
        scale = 0.8,
        name = "Justizzentrum Bürgerportal",
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
    }
  }
}

Config.Status = {
  Aktiviert = true,
  Liste = {
    ["draft"] = { id = "draft", label = "Entwurf", farbe = "#9aa0a6", sortierung = 1 },
    ["submitted"] = { id = "submitted", label = "Eingereicht", farbe = "#2f80ed", sortierung = 2 },
    ["in_review"] = { id = "in_review", label = "In Prüfung", farbe = "#f2c94c", sortierung = 3 },
    ["question_open"] = { id = "question_open", label = "Rückfrage offen", farbe = "#bb6bd9", sortierung = 4 },
    ["approved"] = { id = "approved", label = "Genehmigt", farbe = "#27ae60", sortierung = 10 },
    ["rejected"] = { id = "rejected", label = "Abgelehnt", farbe = "#eb5757", sortierung = 11 },
    ["archived"] = { id = "archived", label = "Archiviert", farbe = "#4f4f4f", sortierung = 99 },
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

Config.Workflows = {
  Aktiviert = true,

  Sperren = {
    Aktiviert = true,
    ExklusiveBearbeitung = true,
    TimeoutSekunden = 300,
    HeartbeatSekunden = 45,
  },

  Eskalation = {
    Aktiviert = true,
    UeberfaelligNachStunden = 72,
  }
}

Config.Benachrichtigungen = {
  Aktiviert = true,
  Ingame = {
    Aktiviert = true,
    Anbieter = "esx",
    StandardDauerMs = 5500,
  }
}

Config.Webhooks = {
  Aktiviert = true,
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
    Fallback = nil,
    NachEvent = {},
    NachKategorie = {},
    NachFormular = {}
  }
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