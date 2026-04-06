# Config-Referenz – hm_buergerportal

Vollständige Dokumentation aller Konfigurations-Sektionen in `config.lua`.  
Alle Lua-Snippets sind kopierbar und zeigen den empfohlenen Default-Wert.

---

## Inhaltsverzeichnis

1. [Config.Kern](#1-configkern)
2. [Config.Datenbank](#2-configdatenbank)
3. [Config.Zahlung – Gebühren v2](#3-configzahlung--gebühren-v2)
4. [Config.JobSettings](#4-configjobsettings)
5. [Config.Standorte](#5-configstandorte)
6. [Config.Rechte](#6-configrechte)
7. [Config.Permissions – Feingranulares Berechtigungssystem](#7-configpermissions--feingranulares-berechtigungssystem)
8. [Config.Kategorien](#8-configkategorien)
9. [Config.Formulare](#9-configformulare)
10. [Config.Status](#10-configstatus)
11. [Config.Prioritaeten](#11-configprioritaeten)
12. [Config.Workflows – SLA / Sperren / Eskalation](#12-configworkflows--sla--sperren--eskalation)
13. [Config.Benachrichtigungen](#13-configbenachrichtigungen)
14. [Config.Webhooks – Routing & Pings](#14-configwebhooks--routing--pings)
15. [Config.Suche](#15-configsuche)
16. [Config.AntiSpam – Missbrauchsschutz](#16-configantispam--missbrauchsschutz)
17. [Config.Archiv](#17-configarchiv)
18. [Config.Entwuerfe](#18-configentwuerfe)
19. [Config.Module – Feature-Flags](#19-configmodule--feature-flags)
20. [Config.Anhaenge](#20-configanhaenge)
21. [Config.FormularEditor](#21-configformulareditor)
22. [Config.Audit](#22-configaudit)
23. [Config.SLA](#23-configsla)
24. [Config.Delegation – Vollmacht-System](#24-configdelegation--vollmacht-system)
25. [Config.Integrationen – Folgeaktionen-Engine](#25-configintegrationen--folgeaktionen-engine)

---

## 1. Config.Kern

**Zweck:** Grundlegende Systemeinstellungen – Jobs, Framework, öffentliche IDs.

### Optionen

| Schlüssel | Typ | Default | Beschreibung |
|---|---|---|---|
| `RessourcenName` | string | `"hm_buergerportal"` | FiveM-Ressourcenname (muss dem Ordnernamen entsprechen) |
| `Sprache` | string | `"de"` | Sprache (aktuell nur Deutsch) |
| `Framework` | string | `"esx"` | Framework (aktuell nur ESX) |
| `Jobs.Admin` | string | `"admin"` | Job-Name des Admin-Jobs |
| `Jobs.Justiz` | string | `"doj"` | Job-Name des Justiz-Jobs (Fallback) |
| `Admin.Job` | string | `"admin"` | Admin-Job-Name für Vollzugriff |
| `Admin.MinGrade` | number | `0` | Mindestgrad für Admin-Zugang (0 = alle Grades) |
| `Justiz.Job` | string | `"doj"` | **Kanonischer** Justiz-Job-Name – alle Services nutzen diesen |
| `Debugmodus` | boolean | `false` | Erweiterte Konsolenausgaben (nur Entwicklung!) |
| `OeffentlicheIds.Aktiviert` | boolean | `true` | Öffentliche Aktenzeichen generieren |
| `OeffentlicheIds.Prefix` | string | `"HM-DOJ"` | Präfix der Aktenzeichen |
| `OeffentlicheIds.Format` | string | `"PREFIX-YYYY-MM-NNNNNN"` | Format der öffentlichen ID |
| `OeffentlicheIds.Stellen` | number | `6` | Anzahl der Ziffern im Aktenzeichen |

### Beispiel

```lua
Config.Kern = {
  RessourcenName = "hm_buergerportal",
  Sprache        = "de",
  Framework      = "esx",

  Jobs = {
    Admin  = "admin",  -- Job-Name deines Admin-Jobs
    Justiz = "doj",    -- Fallback (für Rückwärtskompatibilität)
  },

  Admin = {
    Job      = "admin",
    MinGrade = 0,       -- 0 = alle Grades des Admin-Jobs
  },

  -- Kanonischer Justiz-Job (wird von allen Services genutzt)
  Justiz = {
    Job = "doj",        -- Anpassen falls dein Job anders heißt
  },

  Debugmodus = false,

  OeffentlicheIds = {
    Aktiviert = true,
    Prefix    = "HM-DOJ",
    Format    = "PREFIX-YYYY-MM-NNNNNN",
    Stellen   = 6,
  }
}
```

### Häufige Fehler

- `Config.Kern.Justiz.Job` und `Config.Kern.Jobs.Justiz` müssen **denselben Wert** haben – sonst können verschiedene Services unterschiedliche Job-Namen nutzen.
- `Debugmodus = true` auf Produktivservern erzeugt sehr viel Konsolenausgabe → immer auf `false` belassen.

---

## 2. Config.Datenbank

**Zweck:** Datenbankadapter und Migrationssystem.

```lua
Config.Datenbank = {
  Adapter = "oxmysql",        -- Einziger unterstützter Adapter
  Migrationen = {
    Aktiviert            = true,  -- Migrationssystem aktivieren
    BeimStartAutomatisch = true,  -- Beim Serverstart automatisch migrieren
  }
}
```

### Hinweis

- Migrationen sind idempotent – werden nur einmal ausgeführt.
- Alle Migrationsstände sind in `hm_bp_migrations` gespeichert.
- Wenn `BeimStartAutomatisch = false`: Migrationen müssen manuell über den Admin-Bereich oder eine Server-Konsole ausgelöst werden (nicht empfohlen).

---

## 3. Config.Zahlung – Gebühren v2

**Zweck:** Konfiguration des Gebührensystems. Regelt Zahlungsmodus, Erstattungen und Befreiungen.

> **Abhängigkeit:** `Config.Module.Gebuehren = true` muss gesetzt sein.  
> **Pflicht-Key:** `SocietyKonto` muss einen gültigen Society-Konto-Namen enthalten.

### Zahlungsmodus (`Modus`)

| Wert | Verhalten |
|---|---|
| `"bei_einreichung"` | Gebühr wird sofort bei Antragstellung abgezogen |
| `"bei_entscheidung"` | Gebühr wird erst beim Erreichen eines terminalen Status erhoben (Standard) |

```lua
Config.Zahlung = {
  SocietyKonto     = "society_justiz",  -- PFLICHT: Society-Konto für Einzahlungen

  TerminaleStatus  = {
    "approved", "rejected", "withdrawn", "closed", "completed", "archived"
  },

  Modus = "bei_entscheidung",  -- oder "bei_einreichung"

  -- ── Erstattungen ──────────────────────────────────────────────────
  Erstattungen = {
    aktiv = false,             -- Standard: OFF – explizit aktivieren
    regeln = {
      -- Bei Ablehnung: 100% Rückerstattung
      { status = "rejected",  prozent = 100 },
      -- Bei Rückzug: 50% Rückerstattung
      { status = "withdrawn", prozent = 50  },
    },
  },

  -- ── Gebührenbefreiungen ───────────────────────────────────────────
  Befreiungen = {
    aktiv     = false,         -- Standard: OFF – explizit aktivieren
    rollen    = {},            -- Job-Namen, die generell befreit sind
    kategorien = {},           -- Kategorie-IDs ohne Gebühren
    formulare  = {},           -- Formular-IDs ohne Gebühren
  },
}
```

### Gebühr pro Formular

Die Gebühr wird **pro Formular** in `Config.Formulare.Liste[id].gebuehren` konfiguriert:

```lua
Config.Formulare.Liste["gewerbe_anmeldung"] = {
  -- ...
  gebuehren = {
    aktiv      = true,    -- Gebühr für dieses Formular aktivieren
    betrag     = 50,      -- Betrag in ganzen Euro
    erstattbar = true,    -- Ob Erstattungsregeln für dieses Formular gelten
  },
}
```

### Webhook-Events für Gebühren

Alle Gebühren-Events werden über `Config.Webhooks.Urls["antrag_payments"]` gesendet:

| Event | Auslöser |
|---|---|
| `antrag_payment_abgezogen` | Gebühr erfolgreich abgezogen |
| `antrag_payment_eingezahlt` | Gebühr auf Society-Konto eingezahlt |
| `antrag_payment_refund` | Rückerstattung ausgeführt |
| `antrag_payment_befreit` | Antragsteller ist befreit – keine Abbuchung |
| `antrag_payment_society_fehler` | Einzahlung auf Society-Konto fehlgeschlagen |

### Zahlungs-Ledger

Alle Zahlungsvorgänge werden in `hm_bp_zahlungs_ledger` (Migration v17) protokolliert.  
Der Ledger enthält: Spieler-Quellsource (nur zur Laufzeit), Betrag, Status, Zeitstempel, Referenz-Antrag.

### Use-Cases

**Einfache Gebühr bei Entscheidung:**
```lua
Config.Zahlung.Modus = "bei_entscheidung"
Config.Zahlung.Erstattungen.aktiv = false
```

**Vorauszahlung mit Teilerstattung bei Rückzug:**
```lua
Config.Zahlung.Modus = "bei_einreichung"
Config.Zahlung.Erstattungen = {
  aktiv = true,
  regeln = {
    { status = "rejected",  prozent = 100 },
    { status = "withdrawn", prozent = 75  },
  }
}
```

**Bestimmte Rollen befreien:**
```lua
Config.Zahlung.Befreiungen = {
  aktiv  = true,
  rollen = { "richter", "staatsanwalt" },
}
```

---

## 4. Config.JobSettings

**Zweck:** Job-Grade-spezifische Berechtigungen. Overrides für bestimmte Grades.  
Persistiert in `data/admin_overrides.json` (Admin-Panel → JobSettings-Tab).

```lua
Config.JobSettings = {
  Jobs = {
    ["doj"] = {
      anzeigeName        = "Justiz (DoJ)",
      globalDefaultRolle = "justiz",     -- Globale Basis-Rolle
      grades = {
        { grade = 0, name = "Mitarbeiter"           },
        { grade = 1, name = "Senior Mitarbeiter"    },
        { grade = 2, name = "Leitender Mitarbeiter" },
        { grade = 3, name = "Abteilungsleiter"      },
      },
      gradPermissions = {
        -- Grade 2+: Erweiterte Leitungs-Aktionen freischalten
        [2] = {
          allow = {
            "workflow.lock.override",
            "workflow.sla.pause",
            "workflow.sla.resume",
            "submissions.view_all",
            "submissions.view_archive",
            "submissions.archive",
            "submissions.assign",
            "submissions.set_priority",
            "notes.internal.write",
            "form_editor.publish",
            "form_editor.archive",
          },
          deny = {},
        },
      },
    },
    ["admin"] = {
      anzeigeName        = "Administrator",
      globalDefaultRolle = "admin",
      grades = {
        { grade = 0, name = "Administrator" },
      },
      gradPermissions = {},
    },
  },
}
```

### Hinweis

- **Overrides** aus dem Admin-Panel (gespeichert in `data/admin_overrides.json`) **überschreiben** die Werte in `config.lua` beim Serverstart.
- Um eine Override zurückzusetzen: Im Admin-Panel zurücksetzen oder `data/admin_overrides.json` manuell bearbeiten.

---

## 5. Config.Standorte

**Zweck:** Interaktionspunkte in der Spielwelt (PEDs, Marker, Blips).

```lua
Config.Standorte = {
  Aktiviert        = true,
  InteraktionsModus = "taste",  -- "taste" oder "ox_target"

  Liste = {
    ["doj_frontdesk_1"] = {
      id    = "doj_frontdesk_1",
      name  = "Justizzentrum Empfang",
      aktiv = true,

      koordinaten        = vector3(440.12, -981.92, 30.69),
      heading            = 90.0,
      interaktionsRadius = 2.0,   -- Radius für Taste / ox_target-Zone
      sichtbarRadius     = 30.0,  -- Radius, ab dem Marker sichtbar wird

      interaktion = {
        -- taste = 38,                  -- Control-Index (Standard: 38 = E)
        -- text  = "[E] Portal öffnen", -- Hilfstext (Standard aus Config.Kern)
        -- modus = "ox_target",         -- Standort-spezifischer Modus-Override
      },

      zugriff = {
        nurBuerger     = false,
        nurJustiz      = false,
        nurAdmin       = false,
        erlaubteRollen = {},        -- leer = alle Rollen
        erlaubteJobs   = {},        -- leer = alle Jobs
        erlaubteKategorien = {},    -- leer = alle Kategorien sichtbar
        erlaubteFormulare  = {},    -- leer = alle Formulare sichtbar
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

    -- Interner Justiz-Standort (nur doj/admin)
    ["doj_intern_1"] = {
      id    = "doj_intern_1",
      name  = "Justiz Workstation (Intern)",
      aktiv = true,

      koordinaten        = vector3(462.31, -993.46, 30.69),
      heading            = 270.0,
      interaktionsRadius = 1.8,
      sichtbarRadius     = 15.0,

      interaktion = { text = "[E] Interne Workstation öffnen" },

      zugriff = {
        nurBuerger = false,
        nurJustiz  = true,   -- Nur Justiz + Admin
        nurAdmin   = false,
        erlaubteJobs = { "doj", "admin" },
        erlaubteRollen = {}, erlaubteKategorien = {}, erlaubteFormulare = {},
      },

      ped    = { aktiv = false },
      marker = { aktiv = true, typ = 1, groesse = vector3(0.5, 0.5, 0.5), farbe = { r = 255, g = 165, b = 0, a = 180 } },
      blip   = { aktiv = false },
    }
  }
}
```

---

## 6. Config.Rechte

**Zweck:** Einfaches Rollen-Aktionssystem (parallel zu `Config.Permissions`).  
Wird für schnelle Aktions-Checks im Legacy-Code genutzt.

```lua
Config.Rechte = {
  Aktiviert = true,
  Richtlinie = {
    Global = {
      buerger = {
        erlauben = { "SYSTEM_OEFFNEN", "BUERGER_OEFFNEN", "ANTRAG_ERSTELLEN", "ANTRAG_EIGENE_ANSEHEN" }
      },
      justiz = {
        job = "doj", mindestGrad = 0,
        erlauben = { "SYSTEM_OEFFNEN", "JUSTIZ_OEFFNEN", "KATEGORIE_ANSEHEN", "FORMULAR_ANSEHEN",
                     "ANTRAG_EINGANG_ANSEHEN", "ANTRAG_ZUGEWIESENE_ANSEHEN" }
      },
      admin = { job = "admin", mindestGrad = 0, erlauben = { "*" } }
    }
  }
}
```

---

## 7. Config.Permissions – Feingranulares Berechtigungssystem

**Zweck:** Kaskadiertes Berechtigungssystem. Gibt die kanonischen Action-Keys für das gesamte System vor.

### Kaskaden-Reihenfolge (spezifischste Ebene gewinnt)

1. Admin-Job → immer Vollzugriff (Kurzschluss)
2. Globale Defaults (`Config.Permissions.Defaults[rolle]`)
3. Kategorie-Override (`Config.Kategorien.Liste[id].permissions`)
4. Formular-Override (`Config.Formulare.Liste[id].permissions`)

### Wichtige Action-Keys

| Key | Beschreibung |
|---|---|
| `system.open` | Portal öffnen |
| `submissions.create` | Antrag einreichen |
| `submissions.view_own` | Eigene Anträge sehen |
| `submissions.view_inbox` | Eingangs-Queue sehen (Justiz) |
| `submissions.view_all` | Alle Anträge sehen (Leitung) |
| `submissions.view_archive` | Archiv sehen |
| `submissions.approve` | Genehmigen |
| `submissions.reject` | Ablehnen |
| `submissions.archive` | Archivieren |
| `submissions.assign` | Zuweisen |
| `submissions.set_priority` | Priorität setzen |
| `workflow.lock.request` | Soft-Lock anfordern |
| `workflow.lock.override` | Lock überschreiben (Leitung) |
| `workflow.sla.pause` | SLA pausieren (Leitung) |
| `notes.internal.write` | Interne Notiz schreiben |
| `form_editor.publish` | Formular veröffentlichen |
| `delegate.submit_for_citizen` | Im Auftrag eines Bürgers einreichen |
| `vollmacht.manage` | Vollmachten verwalten |

### Beispiel: Kategorie-Override für Leitung

```lua
Config.Kategorien.Liste["general"].permissions = {
  justiz = {
    grade = { min = 2 },   -- Nur Grade 2+
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
}
```

### Beispiel: Formular-Override – keine Rückfragen erlaubt

```lua
Config.Formulare.Liste["gewerbe_anmeldung"].permissions = {
  justiz = {
    deny  = { "question.ask" },
    allow = { "submissions.approve", "submissions.reject" },
  },
}
```

---

## 8. Config.Kategorien

**Zweck:** Definiert Antragskategorien mit SLA, Workflow, Berechtigungen und Webhooks.

```lua
Config.Kategorien = {
  Aktiviert = true,
  Liste = {
    ["general"] = {
      id           = "general",
      name         = "Allgemein",
      beschreibung = "Allgemeine Anträge an das Justizzentrum",
      icon         = "file",
      sortierung   = 1,
      aktiv        = true,

      fuerBuergerSichtbar  = true,
      nurIntern            = false,

      standardPrioritaet   = "normal",
      standardFristStunden = 72,

      erlaubteStatus = {
        "draft", "submitted", "in_review", "question_open",
        "waiting_for_documents", "forwarded", "escalated",
        "partially_approved", "approved", "rejected",
        "withdrawn", "closed", "archived"
      },

      ui = { farbe = "#2f80ed" },

      -- Zugriffsrechte (Legacy-System, parallel zu permissions)
      zugriff = {
        justiz = {
          job           = "doj",
          erlaubteGrade = { 0, 1, 2, 3, 4, 5 },
          aktionenProGrade = {
            [2] = {
              sehen     = { eingang = true, zugewiesen = true, alleKategorie = true, archiv = true },
              aktionen  = { antragUebernehmen = true, statusAendern = true, genehmigen = true, ablehnen = true, archivieren = true }
            }
          }
        },
        adminImmer = true
      },

      -- PermissionService-Override (feingranular)
      permissions = {
        justiz = {
          grade = { min = 2 },
          allow = { "submissions.archive", "submissions.assign", "notes.internal.write" },
          deny  = {},
        },
      },

      -- Workflow-Regeln
      workflow = {
        sla_hours              = 48,
        pause_sla_in_statuses  = { "question_open", "waiting_for_documents" },
        erlaubteFolgeStatus    = {
          ["submitted"]  = { "in_review", "waiting_for_documents", "rejected", "withdrawn" },
          ["in_review"]  = { "question_open", "approved", "rejected", "withdrawn", "closed" },
          ["approved"]   = { "archived", "closed" },
          ["rejected"]   = { "archived", "closed" },
          -- ... weitere Status
        },
      },

      webhooks = {}  -- Kategorie-spezifischer Webhook (optional)
    }
  }
}
```

### SLA-Pause

Wenn ein Antrag in einen der `pause_sla_in_statuses`-Status wechselt, wird der SLA-Countdown **automatisch angehalten** und beim nächsten Status-Wechsel aus dieser Liste wieder aufgenommen.

---

## 9. Config.Formulare

**Zweck:** Definiert Formularstrukturen mit Feldern, Gebühren, Cooldowns und Integrations-Hooks.

### Formular-Grundstruktur

```lua
Config.Formulare.Liste["mein_formular"] = {
  id                  = "mein_formular",
  titel               = "Mein Formular",
  interneBezeichnung  = "MEIN_FORMULAR",
  beschreibung        = "Kurze Beschreibung",
  kategorieId         = "general",         -- Muss einer Kategorie-ID entsprechen

  aktiv               = true,
  fuerBuergerSichtbar = true,

  buergerDuerfenEinreichen = true,
  nurJustizDarfErstellen   = false,

  -- Gebühren (benötigt Config.Module.Gebuehren = true)
  gebuehren = {
    aktiv      = true,
    betrag     = 50,          -- Betrag in ganzen Euro
    erstattbar = true,        -- Erstattungsregeln aus Config.Zahlung.Erstattungen anwenden?
  },

  cooldownSekunden     = 60,   -- Globaler Cooldown für dieses Formular (Sekunden)
  maxOffenProSpieler   = 3,    -- Max. gleichzeitig offene Anträge pro Spieler
  duplikatPruefung     = { aktiv = true },

  standardStatus       = "submitted",
  standardPrioritaet   = "normal",

  zuweisung = {
    autoZuweisungAktiv        = false,
    erlaubteBearbeiterJobs    = { "doj", "admin" },
    erlaubterMindestGrad      = 0,
  },

  fristen = { fristStunden = 72 },

  -- Felder (citizen_name wird automatisch als Pflichtfeld ergänzt)
  felder = {
    {
      id           = "betreff",
      key          = "betreff",
      label        = "Betreff",
      beschreibung = "Kurze Zusammenfassung (max. 60 Zeichen)",
      typ          = "shorttext",
      pflicht      = true,
      minLaenge    = 3,
      maxLaenge    = 60,
      placeholder  = "z.B. Antrag auf ...",
      reihenfolge  = 1,
      sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
    },
    {
      id           = "beschreibung",
      key          = "beschreibung",
      label        = "Beschreibung",
      typ          = "longtext",
      pflicht      = true,
      minLaenge    = 10,
      maxLaenge    = 2000,
      reihenfolge  = 2,
      sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
    },
  },
}
```

### Unterstützte Feldtypen

| Typ | Beschreibung |
|---|---|
| `shorttext` / `text_short` | Kurzer Text (1 Zeile) |
| `longtext` / `text_long` | Langer Text (mehrzeilig) |
| `number` | Ganze Zahl (mit min/max) |
| `amount` | Geldbetrag in Euro |
| `date` | Datum (JJJJ-MM-TT) |
| `time` | Uhrzeit (HH:MM) |
| `datetime` | Datum + Uhrzeit |
| `select` | Dropdown (Einfachauswahl) |
| `multiselect` | Dropdown (Mehrfachauswahl) |
| `radio` | Radio-Buttons |
| `checkbox` | Ja/Nein-Haken |
| `url` | URL-Eingabe |
| `license_plate` | Fahrzeugkennzeichen |
| `player_reference` | Spieler-Referenz (Name/ID) |
| `company_reference` | Firmen-Referenz |
| `case_number` | Aktenzeichen-Referenz |
| `heading` | Dekorative Überschrift |
| `info` | Infotext |
| `divider` | Trennlinie |

### Integrations-Hooks an Formularen

Wenn `Config.Module.Integrationen = true` und `Config.Integrationen.Aktiviert = true`, können Formulare Folgeaktionen auslösen:

```lua
Config.Formulare.Liste["mein_formular"].integrationen = {
  on_approve = {
    {
      typ        = "set_db_flag",
      schluessel = "vorgang_abgeschlossen",  -- muss in ErlaubteDBFlags stehen
      wert       = "1",
    },
    {
      typ   = "send_webhook_event",
      event = "antrag_status_changed",
      daten = { text = "Antrag genehmigt." },
    },
  },
  on_reject = {
    {
      typ   = "emit_server_event",
      event = "mein_script:antrag_abgelehnt",  -- muss in ErlaubteServerEvents stehen
      daten = { grund = "Anforderungen nicht erfüllt" },
    },
  },
  on_return  = {},
  on_archive = {},
}
```

---

## 10. Config.Status

**Zweck:** Definiert alle möglichen Antragsstatus mit Labels, Farben und erlaubten Folge-Status.

```lua
Config.Status.Liste = {
  ["submitted"] = {
    id     = "submitted",
    label  = "Eingereicht",
    farbe  = "#2f80ed",
    sortierung = 2,

    sichtbarFuerBuerger   = true,
    sichtbarFuerJustiz    = true,
    bearbeitbar           = false,
    erlaubtBuergerAntwort = false,
    erlaubtNachreichung   = false,
    erlaubtInterneNotiz   = true,
    erlaubteFolgeStatus   = {
      "in_review", "question_open", "waiting_for_documents",
      "forwarded", "approved", "rejected", "withdrawn", "closed", "archived"
    },
  },
  -- ... weitere Status
}
```

### Alle Standard-Status

| ID | Label | Bürger sichtbar | Justiz sichtbar |
|---|---|---|---|
| `draft` | Entwurf | ❌ | ✅ |
| `submitted` | Eingereicht | ✅ | ✅ |
| `in_review` | In Prüfung | ✅ | ✅ |
| `question_open` | Rückfrage offen | ✅ | ✅ |
| `waiting_for_documents` | Warten auf Unterlagen | ✅ | ✅ |
| `forwarded` | Weitergeleitet | ✅ | ✅ |
| `escalated` | Eskaliert | ❌ | ✅ |
| `partially_approved` | Teilweise genehmigt | ✅ | ✅ |
| `approved` | Genehmigt | ✅ | ✅ |
| `rejected` | Abgelehnt | ✅ | ✅ |
| `withdrawn` | Zurückgezogen | ✅ | ✅ |
| `closed` | Geschlossen | ✅ | ✅ |
| `archived` | Archiviert | ✅ | ✅ |

> **Hinweis:** `escalated` ist für Bürger nicht sichtbar – interne Eskalation bleibt verborgen.

---

## 11. Config.Prioritaeten

**Zweck:** Definiert Prioritätsstufen für Anträge.

```lua
Config.Prioritaeten = {
  Aktiviert = true,
  Liste = {
    { id = "low",    label = "Niedrig",  farbe = "#56ccf2", sortierung = 1 },
    { id = "normal", label = "Normal",   farbe = "#2f80ed", sortierung = 2 },
    { id = "high",   label = "Hoch",     farbe = "#f2994a", sortierung = 3 },
    { id = "urgent", label = "Dringend", farbe = "#eb5757", sortierung = 4 },
  }
}
```

---

## 12. Config.Workflows – SLA / Sperren / Eskalation

**Zweck:** Workflow-Engine mit SLA-Countdown, Soft-Locks und Eskalation.

```lua
Config.Workflows = {
  Aktiviert = true,

  -- Leitung-Erkennung: ab welchem DOJ-Grade gilt als Leitung
  -- (SLA-Pause/-Override, Lock-Override, Eskalations-Empfänger)
  Leitung = {
    MinGrade = 29,  -- Grade 29+ = Leitung (anpassen an deine Grade-Struktur)
  },

  -- SLA / Fristen
  Sla = {
    DefaultSlaHours       = 48,   -- Standard-SLA wenn Kategorie nichts definiert
    TickIntervalSekunden  = 30,   -- SLA-Check-Intervall (30–60s empfohlen)
  },

  -- Soft-Locks: verhindert gleichzeitige Bearbeitung desselben Antrags
  Sperren = {
    Aktiviert            = true,
    ExklusiveBearbeitung = true,
    TimeoutSekunden      = 600,   -- 10 Minuten Lock-Timeout
    HeartbeatSekunden    = 45,    -- Heartbeat-Intervall zur Lock-Verlängerung
  },

  Eskalation = {
    Aktiviert               = true,
    UeberfaelligNachStunden = 72,  -- Nach 72h ohne Bearbeitung → Eskalation
  },
}
```

### SLA-Verhalten

- SLA-Countdown startet bei Einreichung.
- Pausiert automatisch in Status aus `pause_sla_in_statuses` (pro Kategorie konfigurierbar).
- Überläuft der SLA → `due_state = "overdue"` in der DB; Webhook an `antrag_escalation`.

### Soft-Locks

- Justiz-Bearbeiter fordern einen Lock an, wenn sie einen Antrag öffnen.
- Andere Bearbeiter werden blockiert (Schreibzugriff gesperrt).
- Lock läuft nach `TimeoutSekunden` automatisch ab.
- Leitung (Grade ≥ `Leitung.MinGrade`) und Admin können Locks überschreiben.

---

## 13. Config.Benachrichtigungen

**Zweck:** Ingame-Benachrichtigungen an Spieler nach Statuswechseln etc.

```lua
Config.Benachrichtigungen = {
  Aktiviert = true,
  Ingame = {
    Aktiviert    = true,
    Anbieter     = "esx",     -- "esx" oder zukünftige Anbieter
    StandardDauerMs = 5500,
  },
  -- Platzhalter: {id} = Aktenzeichen, {status} = neuer Status,
  --              {alt} = alter Status, {formular} = Formularname
  Texte = {
    antrag_eingereicht  = "Dein Antrag wurde unter Aktenzeichen {id} erfolgreich eingereicht.",
    status_geaendert    = "Dein Antrag {id} wurde auf Status '{status}' gesetzt.",
    rueckfrage_gestellt = "Zum Antrag {id} wurde eine Rückfrage gestellt.",
    oeffentliche_antwort = "Zu deinem Antrag {id} gibt es eine neue Nachricht der Behörde.",
    antrag_genehmigt    = "Dein Antrag {id} wurde genehmigt.",
    antrag_abgelehnt    = "Dein Antrag {id} wurde abgelehnt.",
  }
}
```

---

## 14. Config.Webhooks – Routing & Pings

**Zweck:** Discord-Integration via Webhooks. Routing, Retry-Queue, Pings.

> **Abhängigkeit:** `Config.Module.Webhooks = true`

### Dedizierte Webhook-URLs

```lua
Config.Webhooks.Urls = {
  ["pdf_export"]         = nil,   -- PDF-Export-Benachrichtigungen
  ["antrag_escalation"]  = nil,   -- SLA-Eskalationen und Reminder
  ["antrag_payments"]    = nil,   -- Alle Gebühren-Events
  ["integrationen"]      = nil,   -- Folgeaktions-Fehler/-Erfolg (PR5)
  ["admin_ops"]          = nil,   -- Admin-Ops (Verschieben, Hard-Delete, Override)
  ["missbrauch"]         = nil,   -- Missbrauchsschutz-Events
}
```

### Event-Routing

```lua
Config.Webhooks.Routing = {
  Fallback     = nil,   -- URL, wenn kein anderer Eintrag greift
  NachEvent    = {
    antrag_created         = "https://discord.com/api/webhooks/...",
    antrag_status_changed  = "https://discord.com/api/webhooks/...",
    antrag_question_asked  = "https://discord.com/api/webhooks/...",
    antrag_citizen_replied = "https://discord.com/api/webhooks/...",
  },
  NachKategorie = {
    ["gewerbe"] = "https://discord.com/api/webhooks/...",
  },
  NachFormular  = {
    ["gewerbe_anmeldung"] = "https://discord.com/api/webhooks/...",
  },
}
```

### Retry-Queue

```lua
Config.Webhooks.Warteschlange = {
  Aktiviert           = true,
  MaxGroesse          = 5000,
  WorkerIntervallMs   = 750,
  MaxProIntervall     = 5,
  Wiederholung = {
    Aktiviert   = true,
    MaxVersuche = 5,
    BackoffMs   = { 1000, 3000, 7000, 15000, 30000 }
  }
}
```

### Discord-Pings

```lua
Config.Webhooks.Pings = {
  Aktiviert     = false,     -- Standard: OFF
  RolleId       = nil,       -- Discord-Rollen-ID als String
  NurFuerEvents = {
    "abuse_triggered",
    "security_incident",
    "system_error",
    "antrag_hartgeloescht",
    "admin_status_override",
  }
}
```

### Identität des Webhooks

```lua
Config.Webhooks.Identitaet = {
  Benutzername = "HM Bürgerportal",
  AvatarUrl    = nil,    -- Optional: URL zu einem Avatar-Bild
  Footer       = "HM Training - Felix Hoffmann",
}
```

### Datenschutz

Alle Discord-Embeds enthalten **keine spieler-spezifischen Identifier**.  
Lediglich folgende Daten werden gesendet: Ingame-Name, Charakter-Name, Aktenzeichen (öffentliche ID), Formularname, Status.

---

## 15. Config.Suche

**Zweck:** Suche/Filter-Einstellungen für Justiz- und Admin-Queues.

```lua
Config.Suche = {
  Aktiviert         = true,
  StandardProSeite  = 25,    -- Standardmäßige Einträge pro Seite
  MaxProSeite       = 100,   -- Maximale Einträge pro Seite (Schutz vor DB-Überlastung)
  MaxSuchtextLaenge = 64,    -- Maximale Länge des Suchtexts
}
```

### Verfügbare Filter (Justiz/Admin)

- Volltext: `citizen_name`, `public_id`, `form_id`
- `zahlungStatus`: `bezahlt` / `unbezahlt` / `befreit`
- `formularId`: exakte Formular-ID
- `sortBy`: `created_at`, `updated_at`, `sla_due_at`

---

## 16. Config.AntiSpam – Missbrauchsschutz

**Zweck:** Schutz vor Spam, Missbrauch, Duplikaten und koordinierten Angriffen.

> **Standard: KOMPLETT AUS** – jedes Sub-Feature muss einzeln aktiviert werden.  
> **Abhängigkeit:** Migration v19 (`hm_bp_abuse_log`) muss durchgelaufen sein.

```lua
Config.AntiSpam = {
  -- Master-Schalter (Standard: OFF)
  Aktiviert                    = false,

  GlobalerCooldownSekunden     = 15,   -- Globaler Cooldown zwischen zwei Anträgen
  MaxOffeneAntraegeProSpieler  = 5,    -- Max. gleichzeitig offene Anträge
  MinTextLaenge                = 3,    -- Mindest-Textlänge (global)
  MaxTextLaenge                = 2000, -- Max.-Textlänge (global)

  -- Per-Formular-Cooldown (überschreibt globalen Cooldown)
  PerFormularCooldown = {
    ["gewerbe_anmeldung"] = 120,  -- 2 Minuten für dieses Formular
  },

  -- Per-Formular-Textlängen (überschreibt globale Werte)
  PerFormularLaengen = {
    ["general_request"] = { min = 10, max = 1500 },
  },

  -- Blackliste
  Blackliste = {
    Aktiviert = false,
    Woerter   = { "spam", "test123", "aaaaa" },  -- Groß-/Kleinschreibung wird ignoriert
  },

  -- Duplikatprüfung (FNV-1a Hash des Antragstexts)
  DuplikatPruefung = {
    Aktiviert     = false,
    FensterMinuten = 30,    -- Zeitfenster in Minuten für Duplikat-Check
  },

  -- Rate-Limiting
  RateLimit = {
    Aktiviert   = false,
    MaxAktionen = 20,    -- Max. Aktionen pro Spieler
    ProSekunden = 60,    -- ... in diesem Zeitfenster
  },

  -- Lockout nach Fehlversuchen
  Lockout = {
    Aktiviert       = false,
    MaxFehlversuche = 5,
    DauerSekunden   = 300,   -- 5 Minuten Lockout
  }
}
```

### Webhook-Events für Missbrauchsschutz

Missbrauchsschutz-Events werden über `Config.Webhooks.Urls["missbrauch"]` gesendet:

| Event | Auslöser |
|---|---|
| `abuse_triggered` | Allgemeiner Missbrauchsblock |
| `abuse_blacklist_hit` | Blacklist-Wort gefunden |
| `abuse_lockout` | Spieler ausgesperrt (nach MaxFehlversuchen) |
| `abuse_duplicate` | Duplikat-Antrag erkannt |

### Use-Case: Minimale Aktivierung

```lua
Config.AntiSpam.Aktiviert                   = true
Config.AntiSpam.GlobalerCooldownSekunden    = 30
Config.AntiSpam.MaxOffeneAntraegeProSpieler = 5
-- Rest bleibt OFF
```

### Use-Case: Vollschutz

```lua
Config.AntiSpam = {
  Aktiviert                   = true,
  GlobalerCooldownSekunden    = 60,
  MaxOffeneAntraegeProSpieler = 3,
  MinTextLaenge               = 10,
  MaxTextLaenge               = 1500,
  Blackliste       = { Aktiviert = true, Woerter = { "spam" } },
  DuplikatPruefung = { Aktiviert = true, FensterMinuten = 60 },
  RateLimit        = { Aktiviert = true, MaxAktionen = 10, ProSekunden = 60 },
  Lockout          = { Aktiviert = true, MaxFehlversuche = 3, DauerSekunden = 600 },
}
```

---

## 17. Config.Archiv

**Zweck:** Archivierungsregeln, Auto-Archiv, Hard-Delete.

```lua
Config.Archiv = {
  Aktiviert     = true,
  AutoArchiv    = { Aktiviert = true, NachTagen = 30 },  -- Nach 30 Tagen automatisch archivieren
  Sichtbarkeit  = { Buerger = true, Justiz = true, Admin = true },
  Wiederherstellung = { Aktiviert = true },               -- Archivierte Anträge wiederherstellen
  HartLoeschen  = {
    Aktiviert    = true,
    NurAdmin     = true,    -- Nur Admin darf hard-deleten
    GrundPflicht = true,    -- Löschgrund ist Pflichtfeld
  }
}
```

---

## 18. Config.Entwuerfe

**Zweck:** Entwürfe für Justiz-Mitarbeiter (interne Notizen und Rückfragen).

> **Standard: OFF**

```lua
Config.Entwuerfe = {
  Aktiviert              = false,
  AutoLoeschenNachTagen  = 14,   -- Entwürfe nach 14 Tagen automatisch löschen
}
```

---

## 19. Config.Module – Feature-Flags

**Zweck:** Master-Schalter für alle Haupt-Module.

```lua
Config.Module = {
  AdminUI          = true,    -- Admin-Bereich in der NUI
  Anhaenge         = true,    -- Bild-Anhänge (URL-Links)
  Gebuehren        = true,    -- Gebührensystem (benötigt Bezahlungs-Lib)
  Delegation       = false,   -- Im-Auftrag-Einreichung (default OFF)
  Entwuerfe        = false,   -- Antrags-Entwürfe für Bürger (default OFF)
  Exporte          = true,    -- CSV/PDF-Export
  AuditHaertung    = true,    -- Erweiterte Audit-Sicherheit
  Webhooks         = true,    -- Discord-Webhooks
  Benachrichtigungen = true,  -- Ingame-Benachrichtigungen
  Integrationen    = false,   -- Folgeaktionen-Engine (default OFF)
}
```

### Live-Overrides

Alle Feature-Flags können über das Admin-Panel live überschrieben werden.  
Die Overrides werden in `data/admin_overrides.json` gespeichert und beim Serverstart geladen.

---

## 20. Config.Anhaenge

**Zweck:** Bild-Anhänge als URL-Links. Whitelist für erlaubte Hosts.

```lua
Config.Anhaenge = {
  Aktiviert = true,
  MaxProAntrag    = 10,         -- Max. Anhänge pro Antrag
  ErlaubteSchemes = { "https" },
  ErlaubteHosts   = {
    "i.imgur.com",
    "imgur.com",
    "cdn.discordapp.com",
    "media.discordapp.net",
  },
  DirektlinkEndungen = { ".png", ".jpg", ".jpeg", ".webp", ".gif" },
  BuergerErlaubteStatus = { "submitted", "question_open" },  -- Bürger darf nur in diesen Status anhängen
  Preview = { NurBeiDirektlink = true },
}
```

---

## 21. Config.FormularEditor

**Zweck:** Zugriffsrechte für den Formular-Editor (wer darf erstellen/veröffentlichen).

```lua
Config.FormularEditor = {
  Aktiviert            = true,
  AdminHatImmerZugriff = true,

  Kategorien = {
    ["general"] = {
      editor      = { rolle = "justiz", job = "doj", mindestGrad = 2 },
      publisher   = { rolle = "justiz", job = "doj", mindestGrad = 4 },
      archivierer = { rolle = "justiz", job = "doj", mindestGrad = 4 },
    },
    ["gewerbe"] = {
      editor      = { rolle = "justiz", job = "doj", mindestGrad = 1 },
      publisher   = { rolle = "justiz", job = "doj", mindestGrad = 3 },
      archivierer = { rolle = "justiz", job = "doj", mindestGrad = 3 },
    },
  }
}
```

---

## 22. Config.Audit

**Zweck:** Audit-Logs: Retention, Cleanup-Job.

```lua
Config.Audit = {
  Aktiviert = true,

  Retention = {
    TageMax = 90,       -- Audit-Einträge nach 90 Tagen löschen
  },

  Cleanup = {
    IntervalSekunden = 3600,   -- Cleanup alle 1 Stunde
  },

  LeitungDarfLesen = true,  -- Justiz-Leitung (Grade >= MinGrade) darf Audit-Log lesen
}
```

### Was protokolliert wird

| Aktion | Beschreibung |
|---|---|
| `submission.erstellt` | Neuer Antrag eingereicht |
| `submission.status_geaendert` | Statuswechsel |
| `submission.genehmigt` / `abgelehnt` | Finale Entscheidung |
| `submission.archiviert` | Antrag archiviert |
| `submission.hart_geloescht` | Hard-Delete durch Admin |
| `payment.abgezogen` | Gebühr abgezogen |
| `payment.refund` | Rückerstattung |
| `integration.geplant` / `erfolgreich` / `fehlgeschlagen` | Folgeaktionen |
| `abuse.blockiert` | Missbrauchsblock |
| `admin_ops.*` | Admin-Operationen |

---

## 23. Config.SLA

**Zweck:** SLA-Checker für Erstbearbeitung (separate von Workflow-SLA).

```lua
Config.SLA = {
  Aktiviert = true,

  ErsteBearbeitungStunden  = 24,   -- Frist für erste Justiz-Reaktion
  ReminderIntervalStunden  = 6,    -- Mindestabstand zwischen Reminder-Webhooks
  TickIntervalSekunden     = 60,   -- Wie oft der SLA-Checker läuft (60–300s empfohlen)
}
```

### Webhook

Eskalations-Events werden über `Config.Webhooks.Urls["antrag_escalation"]` gesendet.  
Solange dieser Wert `nil` ist, werden keine Webhooks gesendet (kein Fehler).

---

## 24. Config.Delegation – Vollmacht-System

**Zweck:** Im-Auftrag-Einreichung (Anwalt, Firmenvertreter, Justiz-Hilfsantrag).

> **Standard: OFF** – `Config.Module.Delegation = true` setzen zum Aktivieren.

```lua
Config.Delegation = {

  -- Vollmacht-Prüfung (Standard: OFF)
  -- Wenn true: Delegation A/B nur mit gültiger Vollmacht in hm_bp_vollmachten.
  -- Justiz-Hilfsantrag (Typ C) ist davon nicht betroffen.
  Vollmacht = {
    Aktiviert = false,
  },

  MaxSuchergebnisse = 20,   -- Max. Treffer bei Ingame-Namenssuche

  -- Erlaubte Delegationstypen pro Rolle
  ErlaubteTypen = {
    buerger = { "submit_for_citizen", "submit_for_company" },
    justiz  = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
    admin   = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
  },
}
```

### Delegationstypen

| Typ | Beschreibung | Rollen |
|---|---|---|
| `submit_for_citizen` | Anwalt/Bevollmächtigter für Bürger | Bürger, Justiz, Admin |
| `submit_for_company` | Firmenvertreter für Firma | Bürger, Justiz, Admin |
| `justice_create_for_citizen` | Justiz-Hilfsantrag im Namen eines Bürgers | Justiz, Admin |

### Sicherheit

- Spielersuche erfolgt ausschließlich über den **Ingame-Namen** (kein Identifier).
- Identifier-Leaks an die UI oder Discord sind **nicht möglich**.
- Vollmacht-Prüfung ist serverseitig (kein Client-Bypass möglich).

### Aktivierung

```lua
Config.Module.Delegation     = true
Config.Delegation.Vollmacht  = { Aktiviert = true }  -- optional
```

---

## 25. Config.Integrationen – Folgeaktionen-Engine

**Zweck:** Konfigurierbare Folgeaktionen nach Statuswechseln pro Formular.

> **Standard: KOMPLETT AUS** – **beide** Flags müssen gesetzt sein!  
> **Abhängigkeit:** Migration v18 (`hm_bp_integration_flags`) muss durchgelaufen sein.

### Aktivierung (beide Flags erforderlich!)

```lua
Config.Module.Integrationen    = true   -- Feature-Flag (Schritt 1)
Config.Integrationen.Aktiviert = true   -- Master-Switch (Schritt 2)
```

### Vollständige Konfiguration

```lua
Config.Integrationen = {
  Aktiviert           = false,    -- Master-Switch (Standard: OFF)
  MaxAktionenProQueue = 20,       -- Harte Grenze: Aktionen pro Aufruf
  MaxGesamtZeitMs     = 4000,     -- Zeitlicher Guard (ms)

  -- Whitelist: Nur diese Typen sind erlaubt
  ErlaubteAktionsTypen = {
    "emit_server_event",
    "call_export",
    "set_db_flag",
    "send_webhook_event",
  },

  -- Whitelist: Erlaubte Server-Events
  ErlaubteServerEvents = {
    "mein_script:antrag_genehmigt",
    "anderes_script:status_benachrichtigung",
  },

  -- Whitelist: Erlaubte Exports ("resource:funktion")
  ErlaubteExports = {
    "mein_script:AntragVerarbeiten",
  },

  -- Whitelist: Erlaubte DB-Flag-Schlüssel
  ErlaubteDBFlags = {
    "vorgang_abgeschlossen",
    "bearbeitung_gestartet",
    "akte_geschlossen",
  },

  -- Status → Hook-Mapping (anpassen an deine Status-IDs)
  StatusHooks = {
    approved           = "on_approve",
    partially_approved = "on_approve",
    rejected           = "on_reject",
    withdrawn          = "on_reject",
    question_open      = "on_return",
    waiting_for_documents = "on_return",
    archived           = "on_archive",
  },
}
```

### Hooks an Formularen konfigurieren

```lua
-- Beispiel: Folgeaktionen für "gewerbe_anmeldung"
Config.Formulare.Liste["gewerbe_anmeldung"].integrationen = {

  -- Bei Genehmigung: DB-Flag setzen + Webhook senden
  on_approve = {
    {
      typ        = "set_db_flag",
      schluessel = "vorgang_abgeschlossen",  -- muss in ErlaubteDBFlags stehen
      wert       = "1",
    },
    {
      typ   = "send_webhook_event",
      event = "antrag_status_changed",
      daten = { text = "Gewerbe genehmigt." },
    },
  },

  -- Bei Ablehnung: Server-Event auslösen
  on_reject = {
    {
      typ   = "emit_server_event",
      event = "mein_script:gewerbe_abgelehnt",  -- muss in ErlaubteServerEvents stehen
      daten = { formular = "gewerbe_anmeldung" },
    },
  },

  -- Bei Rückfrage / Dokumente anfordern: Export-Funktion aufrufen
  on_return = {
    {
      typ      = "call_export",
      resource = "mein_script",                -- muss "mein_script:Funktion" in ErlaubteExports stehen
      funktion = "AntragZurueckgegeben",
      daten    = {},
    },
  },

  on_archive = {},
}
```

### Sicherheitshinweise

- Alle Action-Typen, Server-Events, Exports und DB-Flags müssen **explizit** in der Whitelist stehen.
- Aktionen werden in `pcall` ausgeführt – Lua-Fehler werden abgefangen und geloggt.
- Fehler werden in `hm_bp_audit_logs` und via `Config.Webhooks.Urls["integrationen"]` gemeldet.
- `MaxAktionenProQueue` und `MaxGesamtZeitMs` verhindern Endlos-Aktionsketten.

---

## Admin-Ops – Kurzreferenz

Der Admin-Bereich bietet folgende operative Funktionen (keine Config nötig, alles über Admin-UI):

| Funktion | Beschreibung | Webhook-Event |
|---|---|---|
| Verschieben | Antrag in andere Kategorie/Formular verschieben | `antrag_verschoben` |
| Wiederherstellen | Archivierten Antrag wiederherstellen | `antrag_wiederhergestellt` |
| Hard-Delete | Antrag mit Grund dauerhaft löschen | `antrag_hartgeloescht` |
| Status-Override | Status umgehen / direkt setzen | `admin_status_override` |
| Im Auftrag erstellen | Antrag im Namen eines Bürgers erstellen | `antrag_im_auftrag_erstellt` |

Alle Admin-Ops schreiben Audit-Einträge und senden Webhooks an `Config.Webhooks.Urls["admin_ops"]`.
