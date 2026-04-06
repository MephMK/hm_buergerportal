# Konfigurationsanleitung – hm_buergerportal

> **Für wen ist diese Anleitung?**  
> Diese Anleitung richtet sich an FiveM-Server-Admins und Spieler, die das Bürgerportal einrichten oder anpassen möchten – **auch ohne IT-Kenntnisse**. Jeder Begriff wird erklärt, Schritt für Schritt.

---

## Inhaltsverzeichnis

1. [Was ist die config.lua und wo finde ich sie?](#1-was-ist-die-configlua-und-wo-finde-ich-sie)
2. [Wie bearbeite ich die config.lua?](#2-wie-bearbeite-ich-die-configlua)
3. [Drei Konfigurations-Ebenen verstehen](#3-drei-konfigurations-ebenen-verstehen)
4. [Die wichtigsten Abschnitte erklärt](#4-die-wichtigsten-abschnitte-erklärt)
   - [4.1 Kern-Einstellungen](#41-kern-einstellungen-configkern)
   - [4.2 Datenbank](#42-datenbank-configdatenbank)
   - [4.3 Gebühren](#43-gebühren-configzahlung)
   - [4.4 Job-Berechtigungen (JobSettings)](#44-job-berechtigungen-configjobsettings)
   - [4.5 Standorte in der Spielwelt](#45-standorte-in-der-spielwelt-configstandorte)
   - [4.6 Berechtigungssystem](#46-berechtigungssystem-configpermissions)
   - [4.7 Kategorien](#47-kategorien-configkategorien)
   - [4.8 Formulare](#48-formulare-configformulare)
   - [4.9 Status-Definitionen](#49-status-definitionen-configstatus)
   - [4.10 SLA und Fristen](#410-sla-und-fristen-configworkflows)
   - [4.11 Ingame-Benachrichtigungen](#411-ingame-benachrichtigungen-configbenachrichtigungen)
   - [4.12 Discord-Webhooks](#412-discord-webhooks-configwebhooks)
   - [4.13 Missbrauchsschutz (AntiSpam)](#413-missbrauchsschutz-configantispam)
   - [4.14 Modul-Schalter (Feature-Flags)](#414-modul-schalter-configmodule)
   - [4.15 Anhänge](#415-anhänge-configanhaenge)
   - [4.16 Audit-Logs](#416-audit-logs-configaudit)
   - [4.17 Delegation (Vollmacht)](#417-delegation-configdelegation)
   - [4.18 Integrationen (Folgeaktionen)](#418-integrationen-configintegrationen)
5. [Vollständige Beispiel-Setups](#5-vollständige-beispiel-setups)
   - [Setup A – Kleiner Roleplay-Server](#setup-a--kleiner-roleplay-server-minimalsetup)
   - [Setup B – Mittlerer RP-Server mit Justiz](#setup-b--mittlerer-rp-server-mit-vollständiger-justiz)
   - [Setup C – Großer Server mit allen Features](#setup-c--großer-server-mit-allen-features)
6. [Troubleshooting – Häufige Probleme und Lösungen](#6-troubleshooting--häufige-probleme-und-lösungen)

---

## 1. Was ist die config.lua und wo finde ich sie?

Die Datei `config.lua` ist die **zentrale Einstellungsdatei** des Bürgerportals. In ihr steht alles, was das Script wissen muss: welche Jobs es gibt, wie Gebühren funktionieren, welche Discord-Kanäle Nachrichten erhalten sollen usw.

### Wo liegt die Datei?

```
FiveM-Server/
  resources/
    [hm]/                      ← optionaler Gruppenordner
      hm_buergerportal/
        config.lua             ← ✅ DIESE DATEI bearbeiten
        fxmanifest.lua
        client/
        server/
        shared/
        ui/
        data/
          admin_overrides.json ← ⚠️  wird automatisch erstellt (nicht manuell bearbeiten)
```

> **Wichtig:** Es gibt nur **eine** `config.lua`. Diese liegt direkt im Hauptordner des Scripts (`hm_buergerportal/`), nicht in Unterordnern.

---

## 2. Wie bearbeite ich die config.lua?

### Was du brauchst

Du brauchst einen **Text-Editor**. Empfohlen (kostenlos):
- **Visual Studio Code** – [code.visualstudio.com](https://code.visualstudio.com) – hebt Lua-Code farbig hervor, zeigt Fehler an
- **Notepad++** – einfacher, ebenfalls kostenlos

**Nicht geeignet:** Windows Notepad (Editor) – kann Zeilenenden falsch speichern.

### Schritt-für-Schritt

1. Öffne den Ordner `hm_buergerportal/` auf deinem Server oder lokal.
2. Mache einen **Rechtsklick** auf `config.lua` → „Öffnen mit" → deinen Text-Editor auswählen.
3. Suche den Abschnitt, den du ändern möchtest (Strg+F zum Suchen).
4. Ändere den Wert hinter dem `=`-Zeichen.
5. **Speichere** die Datei (Strg+S).
6. **Starte den FiveM-Server neu** – Änderungen werden erst beim nächsten Start übernommen.

### Was bedeuten die Zeichen?

```lua
-- Das ist ein Kommentar. Diese Zeile wird ignoriert.

Config.Kern.Debugmodus = false   -- false = ausgeschaltet, true = eingeschaltet

Config.Kern.Jobs.Admin = "admin"   -- "admin" ist ein Text-Wert (immer in Anführungszeichen)

Config.Zahlung.MaxBetrag = 100     -- 100 ist eine Zahl (ohne Anführungszeichen)
```

| Zeichen | Bedeutung |
|---------|-----------|
| `--` | Kommentar – wird vom Script ignoriert |
| `"text"` | Text-Wert (String) – immer in Anführungszeichen |
| `true` / `false` | Ein/Aus-Schalter |
| Zahl ohne `""` | Zahlenwert |
| `{ }` | Eine Liste oder Gruppe von Einstellungen |

---

## 3. Drei Konfigurations-Ebenen verstehen

Das Bürgerportal hat **drei Ebenen**, die zusammen die aktive Konfiguration ergeben:

```
┌─────────────────────────────────────────────────────────┐
│  Ebene 1: config.lua                                    │
│  → Deine Basis-Einstellungen (du bearbeitest diese)    │
└─────────────────────────────┬───────────────────────────┘
                              │ wird beim Start geladen
                              ▼
┌─────────────────────────────────────────────────────────┐
│  Ebene 2: data/admin_overrides.json                     │
│  → Wird vom Admin-Panel geschrieben                     │
│  → Überschreibt bestimmte Werte aus config.lua          │
└─────────────────────────────┬───────────────────────────┘
                              │ wird über Basis gelegt
                              ▼
┌─────────────────────────────────────────────────────────┐
│  Ebene 3: Effektive Konfiguration (im laufenden Server) │
│  → Was das Script tatsächlich verwendet                 │
└─────────────────────────────────────────────────────────┘
```

### Was bedeutet das konkret?

**Beispiel:** Du hast in `config.lua` das Gebührenmodul auf `true` gesetzt. Ein Admin geht ins Admin-Panel und schaltet es auf `false`. Das Script schreibt diesen Wert in `data/admin_overrides.json`. Ab jetzt ist das Gebührenmodul **ausgeschaltet – auch wenn config.lua noch `true` sagt**.

> **Merke:** Wenn du etwas in `config.lua` änderst, aber das Script verhält sich anders, könnte ein Override in `data/admin_overrides.json` aktiv sein. Im Admin-Panel kannst du Overrides zurücksetzen.

### Was kann überschrieben werden?

Über das Admin-Panel (und damit `data/admin_overrides.json`) können folgende Bereiche überschrieben werden:
- **Feature-Flags** (`Config.Module`) – Module ein-/ausschalten
- **JobSettings** – Job-Grade-Berechtigungen
- **Webhooks** – Discord-URLs
- **Kategorien und Formulare** – Einstellungen per Kategorie/Formular

### Die Datei admin_overrides.json direkt bearbeiten

Du kannst `data/admin_overrides.json` auch direkt in einem Text-Editor öffnen. Das ist jedoch **nicht empfohlen**, weil:
- JSON-Syntax ist fehleranfällig (ein falsches Komma lässt das Script nicht starten)
- Das Admin-Panel macht dasselbe bequemer und sicherer

Wenn du eine Override zurücksetzen möchtest, ist es am einfachsten, sie im Admin-Panel zu löschen.

---

## 4. Die wichtigsten Abschnitte erklärt

### 4.1 Kern-Einstellungen (`Config.Kern`)

**Was macht dieser Abschnitt?**  
Hier legst du die grundlegenden Dinge fest: Welcher Job ist der Admin-Job? Welcher Job ist der Justiz-Job? Wie sollen Aktenzeichen aussehen?

```lua
Config.Kern = {
  RessourcenName = "hm_buergerportal",  -- Der Ordnername des Scripts (nicht ändern!)
  Sprache        = "de",                -- Sprache (nur Deutsch verfügbar)
  Framework      = "esx",               -- Framework (nur ESX verfügbar)

  Jobs = {
    Admin  = "admin",   -- ← ANPASSEN: Dein Admin-Job-Name in ESX
    Justiz = "doj",     -- ← ANPASSEN: Dein Justiz-/Behörden-Job-Name in ESX
  },

  Admin = {
    Job      = "admin",  -- ← ANPASSEN: Gleicher Wert wie Jobs.Admin
    MinGrade = 0,        -- 0 = alle Grades des Admin-Jobs haben Vollzugriff
                         -- z.B. 2 = nur Grade 2 und höher haben Admin-Zugriff
  },

  Justiz = {
    Job = "doj",    -- ← ANPASSEN: Gleicher Wert wie Jobs.Justiz
  },

  Debugmodus = false,  -- Auf true setzen nur wenn du Fehler suchst!
                       -- Erzeugt sehr viele Server-Log-Einträge.

  OeffentlicheIds = {
    Aktiviert = true,
    Prefix    = "HM-DOJ",              -- Präfix vor dem Aktenzeichen, z.B. "DOJ", "BPOL"
    Format    = "PREFIX-YYYY-MM-NNNNNN", -- Format: Nicht ändern ohne guten Grund
    Stellen   = 6,                      -- Anzahl der Ziffern, z.B. 6 → DOJ-2024-01-000001
  }
}
```

**Typischer Fehler:** `Config.Kern.Justiz.Job` und `Config.Kern.Jobs.Justiz` müssen **denselben Wert** haben. Wenn sie unterschiedlich sind, erkennt das Script den Justiz-Job nur in manchen Bereichen.

**Beispiel:** Dein Justiz-Job heißt in ESX `staatsanwaltschaft`:
```lua
Config.Kern.Jobs.Justiz = "staatsanwaltschaft"
Config.Kern.Justiz.Job  = "staatsanwaltschaft"
```

---

### 4.2 Datenbank (`Config.Datenbank`)

**Was macht dieser Abschnitt?**  
Regelt, wie das Script mit der Datenbank kommuniziert und ob Tabellen automatisch angelegt werden.

```lua
Config.Datenbank = {
  Adapter = "oxmysql",           -- Nicht ändern (nur oxmysql wird unterstützt)
  Migrationen = {
    Aktiviert            = true, -- Migrationssystem ein/aus
    BeimStartAutomatisch = true, -- true = Tabellen werden beim Serverstart automatisch angelegt
  }
}
```

**Empfehlung:** `BeimStartAutomatisch = true` immer aktiv lassen. Das System legt dann alle benötigten Datenbank-Tabellen beim ersten Start automatisch an – du musst keine SQL-Dateien importieren.

---

### 4.3 Gebühren (`Config.Zahlung`)

**Was macht dieser Abschnitt?**  
Regelt, ob und wie Gebühren für Anträge erhoben werden. Gebühren werden vom Spieler-Konto abgezogen und auf ein Server-Society-Konto eingezahlt.

> **Voraussetzung:** Eines dieser Scripts muss auf deinem Server laufen: `wasabi_banking`, `wasabi_billing`, `esx_banking` oder `esx_billing`.

```lua
Config.Zahlung = {
  SocietyKonto = "society_justiz",  -- ← ANPASSEN: Name des Society-Kontos in deiner Banking-Ressource

  -- Wann wird die Gebühr abgezogen?
  Modus = "bei_entscheidung",   -- "bei_entscheidung" = erst wenn der Antrag entschieden wird
                                -- "bei_einreichung"  = sofort wenn der Antrag eingereicht wird

  -- Terminale Status = Status, bei denen eine Gebühr (im Modus "bei_entscheidung") fällig wird
  TerminaleStatus = {
    "approved", "rejected", "withdrawn", "closed", "completed", "archived"
  },

  -- Rückerstattungen (Standard: ausgeschaltet)
  Erstattungen = {
    aktiv = false,       -- auf true setzen um Rückerstattungen zu aktivieren
    regeln = {
      { status = "rejected",  prozent = 100 },  -- Bei Ablehnung: 100% zurück
      { status = "withdrawn", prozent = 50  },  -- Bei Rückzug: 50% zurück
    },
  },

  -- Gebührenbefreiungen (Standard: ausgeschaltet)
  Befreiungen = {
    aktiv     = false,      -- auf true setzen um Befreiungen zu aktivieren
    rollen    = {},         -- z.B. { "richter", "staatsanwalt" } – diese Rollen zahlen nichts
    kategorien = {},        -- z.B. { "interne_kategorie" } – diese Kategorien sind kostenfrei
    formulare  = {},        -- z.B. { "interne_anfrage" } – diese Formulare sind kostenfrei
  },
}
```

**Gebühr pro Formular konfigurieren:**  
Die Höhe der Gebühr wird nicht hier, sondern im jeweiligen **Formular** festgelegt:

```lua
-- Beispiel: Formular "gewerbe_anmeldung" kostet 50€
Config.Formulare.Liste["gewerbe_anmeldung"].gebuehren = {
  aktiv      = true,   -- Gebühr für dieses Formular aktivieren
  betrag     = 50,     -- Betrag in ganzen Euro (nur ganze Zahlen)
  erstattbar = true,   -- Gilt die Erstattungsregel auch für dieses Formular?
}
```

---

### 4.4 Job-Berechtigungen (`Config.JobSettings`)

**Was macht dieser Abschnitt?**  
Hier kannst du festlegen, welche **Grades (Ränge)** eines Jobs welche Aktionen im Bürgerportal durchführen dürfen. Höhere Grade bekommen automatisch mehr Rechte.

> **Wichtig:** Diese Einstellungen können auch **direkt im Admin-Panel** (→ Tab „JobSettings") bearbeitet werden. Änderungen dort werden in `data/admin_overrides.json` gespeichert und **überschreiben** die Werte hier.

```lua
Config.JobSettings = {
  Jobs = {

    -- ── Justiz-Job ──────────────────────────────────────────────────
    ["doj"] = {                           -- ← ANPASSEN: dein Justiz-Job-Name
      anzeigeName        = "Justiz (DoJ)", -- Anzeigename im Admin-Panel
      globalDefaultRolle = "justiz",       -- Welche Basis-Rolle bekommt dieser Job?

      -- Grade/Ränge des Jobs (mit Namen für das Admin-Panel)
      grades = {
        { grade = 0, name = "Mitarbeiter"           },
        { grade = 1, name = "Senior Mitarbeiter"    },
        { grade = 2, name = "Leitender Mitarbeiter" },
        { grade = 3, name = "Abteilungsleiter"      },
      },

      -- Welche Grade bekommen zusätzliche Rechte?
      gradPermissions = {
        -- Grade 2 und höher dürfen: Alle Anträge sehen, archivieren, zuweisen usw.
        [2] = {
          allow = {
            "workflow.lock.override",    -- Sperren anderer Bearbeiter aufheben
            "workflow.sla.pause",        -- SLA-Countdown pausieren
            "workflow.sla.resume",       -- SLA-Countdown fortsetzen
            "submissions.view_all",      -- Alle Anträge sehen (nicht nur zugewiesene)
            "submissions.view_archive",  -- Archiv einsehen
            "submissions.archive",       -- Anträge archivieren
            "submissions.assign",        -- Anträge zuweisen
            "submissions.set_priority",  -- Priorität setzen
            "notes.internal.write",      -- Interne Notizen schreiben
            "form_editor.publish",       -- Formulare veröffentlichen
            "form_editor.archive",       -- Formulare archivieren
          },
          deny = {},  -- Hier kannst du Rechte auch explizit verbieten
        },
      },
    },

    -- ── Admin-Job ───────────────────────────────────────────────────
    ["admin"] = {                          -- ← ANPASSEN: dein Admin-Job-Name
      anzeigeName        = "Administrator",
      globalDefaultRolle = "admin",        -- Admin bekommt automatisch alle Rechte
      grades = {
        { grade = 0, name = "Administrator" },
      },
      gradPermissions = {},   -- Admin hat immer Vollzugriff, hier nichts nötig
    },
  },
}
```

**Alle verfügbaren Rechte-Schlüssel** (für `allow`/`deny`):

| Schlüssel | Was darf der Grade? |
|---|---|
| `system.open` | Das Portal überhaupt öffnen |
| `submissions.create` | Einen Antrag einreichen |
| `submissions.view_own` | Eigene Anträge sehen |
| `submissions.view_inbox` | Die Eingangs-Queue sehen (Justiz) |
| `submissions.view_all` | Alle Anträge sehen (Leitung) |
| `submissions.view_archive` | Das Archiv einsehen |
| `submissions.approve` | Anträge genehmigen |
| `submissions.reject` | Anträge ablehnen |
| `submissions.archive` | Anträge archivieren |
| `submissions.assign` | Anträge einem Bearbeiter zuweisen |
| `submissions.set_priority` | Priorität eines Antrags setzen |
| `workflow.lock.request` | Einen Antrag zur Bearbeitung sperren |
| `workflow.lock.override` | Die Sperre eines anderen aufheben |
| `workflow.sla.pause` | Den Frist-Countdown pausieren |
| `notes.internal.write` | Interne Notizen (nur für Justiz sichtbar) |
| `form_editor.publish` | Formulare veröffentlichen |
| `delegate.submit_for_citizen` | Im Auftrag eines Bürgers einreichen |
| `vollmacht.manage` | Vollmachten verwalten |

---

### 4.5 Standorte in der Spielwelt (`Config.Standorte`)

**Was macht dieser Abschnitt?**  
Legt fest, an welchen Orten in der Spielwelt Spieler das Bürgerportal öffnen können (mit Marker, Blip auf der Karte und NPC).

```lua
Config.Standorte = {
  Aktiviert         = true,
  InteraktionsModus = "taste",   -- "taste" = Taste E drücken zum Öffnen
                                 -- "ox_target" = Crosshair auf NPC/Marker (braucht ox_target)

  Liste = {
    ["mein_standort"] = {
      id   = "mein_standort",   -- Eindeutige ID (nur Buchstaben, Zahlen, Unterstriche)
      name = "Bürgerportal",    -- Anzeigename im Spiel
      aktiv = true,             -- false = dieser Standort wird ignoriert

      -- Position in der Spielwelt (X, Y, Z-Koordinaten)
      koordinaten        = vector3(440.12, -981.92, 30.69),
      heading            = 90.0,          -- In welche Richtung schaut der NPC (0-360)
      interaktionsRadius = 2.0,           -- Wie nah muss der Spieler ran? (in Metern)
      sichtbarRadius     = 30.0,          -- Ab welcher Entfernung ist der Marker sichtbar?

      -- Taste-Einstellungen (nur bei InteraktionsModus = "taste")
      interaktion = {
        taste = 38,                    -- 38 = Taste E (Standard)
        text  = "[E] Portal öffnen",   -- Hinweis-Text der angezeigt wird
      },

      -- Wer darf diesen Standort benutzen?
      zugriff = {
        nurBuerger = false,   -- true = nur normale Spieler (kein Justiz/Admin)
        nurJustiz  = false,   -- true = nur Justiz und Admin
        nurAdmin   = false,   -- true = nur Admin
        erlaubteRollen     = {},  -- leer = alle Rollen erlaubt
        erlaubteJobs       = {},  -- leer = alle Jobs erlaubt
        erlaubteKategorien = {},  -- leer = alle Kategorien sichtbar
        erlaubteFormulare  = {},  -- leer = alle Formulare sichtbar
      },

      -- NPC-Figur am Standort
      ped = {
        aktiv           = true,
        modell          = "s_m_y_cop_01",           -- GTA-Modell-Name
        scenario        = "WORLD_HUMAN_CLIPBOARD",  -- Was der NPC tut (Animation)
        unverwundbar    = true,   -- NPC kann nicht getötet werden
        eingefroren     = true,   -- NPC bewegt sich nicht
        blockiereEvents = true,   -- NPC reagiert nicht auf andere Spieler
      },

      -- Blauer Kreis/Pfeil auf dem Boden
      marker = {
        aktiv   = true,
        typ     = 2,                            -- Marker-Form (2 = Kreis mit Pfeil)
        groesse = vector3(0.3, 0.3, 0.3),       -- Größe
        farbe   = { r = 0, g = 120, b = 255, a = 160 },  -- Farbe (RGBA)
      },

      -- Symbol auf der Karte (Blip)
      blip = {
        aktiv  = true,
        sprite = 525,          -- GTA-Symbol-Nummer
        farbe  = 3,            -- GTA-Farb-Nummer
        scale  = 0.8,          -- Größe des Symbols
        name   = "Bürgerportal", -- Text beim Hover auf der Karte
      },
    },
  }
}
```

---

### 4.6 Berechtigungssystem (`Config.Permissions`)

**Was macht dieser Abschnitt?**  
Das detaillierte Berechtigungssystem. Es baut auf `Config.JobSettings` auf und erlaubt Ausnahmen pro Kategorie oder Formular.

**Das Kaskaden-Prinzip** (von unten nach oben – die spezifischste Regel gewinnt):

```
Admin-Job         → immer alles erlaubt (kann nicht eingeschränkt werden)
    ↑
Formular-Override → Ausnahme für ein bestimmtes Formular
    ↑
Kategorie-Override→ Ausnahme für eine bestimmte Kategorie
    ↑
Globale Defaults  → Standardrechte pro Rolle (buerger/justiz/admin)
```

**Globale Standardrechte:**
```lua
Config.Permissions = {
  Defaults = {
    buerger = {
      allow = {
        "system.open",
        "submissions.create",
        "submissions.view_own",
      }
    },
    justiz = {
      allow = {
        "system.open",
        "submissions.view_inbox",
        "submissions.view_own",
        "submissions.approve",
        "submissions.reject",
        "notes.internal.write",
      }
    },
    -- Admin bekommt automatisch alles
  }
}
```

**Beispiel: Für eine bestimmte Kategorie nur Leitung (Grade 2+) erlauben:**
```lua
Config.Kategorien.Liste["geheime_kategorie"].permissions = {
  justiz = {
    grade = { min = 2 },   -- Nur Grade 2 und höher dürfen diese Kategorie sehen
    allow = { "submissions.view_all", "submissions.archive" },
    deny  = {},
  },
}
```

---

### 4.7 Kategorien (`Config.Kategorien`)

**Was macht dieser Abschnitt?**  
Kategorien sind die **Hauptbereiche** des Portals, z.B. „Allgemein", „Gewerbe", „Führerschein". Formulare werden einer Kategorie zugeordnet.

```lua
Config.Kategorien = {
  Aktiviert = true,
  Liste = {
    ["general"] = {
      id           = "general",           -- Eindeutige ID (nur Buchstaben/Zahlen/Unterstriche)
      name         = "Allgemein",         -- Anzeigename im Portal
      beschreibung = "Allgemeine Anträge",
      icon         = "file",              -- Symbol-Name (FontAwesome-Icons)
      sortierung   = 1,                   -- Reihenfolge im Portal (1 = oben)
      aktiv        = true,

      fuerBuergerSichtbar = true,   -- Können Bürger diese Kategorie sehen?
      nurIntern           = false,  -- true = Nur Justiz/Admin sehen diese Kategorie

      standardPrioritaet   = "normal",  -- Standard-Priorität für neue Anträge
      standardFristStunden = 72,        -- Standard-Frist in Stunden (SLA)

      -- Farbe der Kategorie im Portal (CSS-Farbe)
      ui = { farbe = "#2f80ed" },

      -- Welche Status dürfen Anträge in dieser Kategorie haben?
      erlaubteStatus = {
        "submitted", "in_review", "approved", "rejected", "archived"
        -- (alle verfügbaren Status, die du erlauben möchtest)
      },

      -- Workflow-Regeln (SLA, Status-Übergänge)
      workflow = {
        sla_hours             = 48,   -- Frist in Stunden (überschreibt standardFristStunden)
        pause_sla_in_statuses = { "question_open", "waiting_for_documents" },
        -- Wenn Antrag in diesen Status → Frist-Countdown pausiert

        -- Welcher Status kann zu welchem anderen werden?
        erlaubteFolgeStatus = {
          ["submitted"]  = { "in_review", "rejected", "withdrawn" },
          ["in_review"]  = { "approved", "rejected", "question_open" },
          ["approved"]   = { "archived", "closed" },
          ["rejected"]   = { "archived", "closed" },
        },
      },
    },
  }
}
```

---

### 4.8 Formulare (`Config.Formulare`)

**Was macht dieser Abschnitt?**  
Formulare sind die **einzelnen Antragsformulare** innerhalb einer Kategorie, z.B. „Gewerbe-Anmeldung" oder „Führerschein-Antrag".

```lua
Config.Formulare.Liste["gewerbe_anmeldung"] = {
  id                  = "gewerbe_anmeldung",  -- Eindeutige ID
  titel               = "Gewerbe-Anmeldung",  -- Anzeigename
  beschreibung        = "Antrag zur Gewerbeanmeldung",
  kategorieId         = "gewerbe",            -- Zu welcher Kategorie gehört dieses Formular?

  aktiv               = true,
  fuerBuergerSichtbar = true,  -- Können Bürger dieses Formular sehen?

  buergerDuerfenEinreichen = true,   -- Dürfen Bürger dieses Formular einreichen?
  nurJustizDarfErstellen   = false,  -- true = nur Justiz/Admin kann diesen Antrag erstellen

  -- Gebühr für dieses Formular
  gebuehren = {
    aktiv      = true,    -- Gebühr für dieses Formular aktiv?
    betrag     = 50,      -- Betrag in Euro (ganze Zahl)
    erstattbar = true,    -- Kann erstattet werden?
  },

  cooldownSekunden   = 60,  -- Spieler muss X Sekunden warten bevor er erneut einreichen darf
  maxOffenProSpieler = 3,   -- Maximal X gleichzeitig offene Anträge pro Spieler

  standardStatus     = "submitted",  -- Status wenn Antrag eingereicht wird
  standardPrioritaet = "normal",     -- Standard-Priorität

  -- Formularfelder (die Fragen, die der Spieler beantworten muss)
  felder = {
    {
      id          = "betreff",
      label       = "Betreff",             -- Angezeigter Titel des Feldes
      beschreibung = "Kurze Zusammenfassung",
      typ         = "shorttext",           -- Feldtyp (kurzer Text)
      pflicht     = true,                  -- Muss ausgefüllt werden?
      minLaenge   = 3,
      maxLaenge   = 60,
      placeholder = "z.B. Antrag auf ...", -- Platzhalter-Text im Feld
      reihenfolge = 1,                     -- Reihenfolge im Formular (1 = oben)
    },
    {
      id          = "beschreibung",
      label       = "Beschreibung",
      typ         = "longtext",            -- Feldtyp (langer Text, mehrzeilig)
      pflicht     = true,
      minLaenge   = 10,
      maxLaenge   = 2000,
      reihenfolge = 2,
    },
    {
      id          = "fahrzeugkennzeichen",
      label       = "Fahrzeugkennzeichen",
      typ         = "license_plate",       -- Spezieller Feldtyp für Kennzeichen
      pflicht     = false,
      reihenfolge = 3,
    },
  },
}
```

**Alle Feldtypen im Überblick:**

| Typ | Was ist das? |
|-----|-------------|
| `shorttext` | Kurzes Textfeld (1 Zeile) |
| `longtext` | Langes Textfeld (mehrzeilig) |
| `number` | Nur Zahlen |
| `amount` | Geldbetrag in Euro |
| `date` | Datum-Auswahl |
| `time` | Uhrzeit-Auswahl |
| `datetime` | Datum + Uhrzeit |
| `select` | Dropdown (eine Auswahl) |
| `multiselect` | Dropdown (mehrere Auswahlen) |
| `radio` | Auswahl-Buttons |
| `checkbox` | Ja/Nein-Haken |
| `url` | Internet-Link |
| `license_plate` | Fahrzeugkennzeichen |
| `player_reference` | Spieler-Name/ID |
| `company_reference` | Firmen-Referenz |
| `case_number` | Aktenzeichen-Referenz |
| `heading` | Überschrift (kein Eingabefeld) |
| `info` | Infotext (kein Eingabefeld) |
| `divider` | Trennlinie (kein Eingabefeld) |

---

### 4.9 Status-Definitionen (`Config.Status`)

**Was macht dieser Abschnitt?**  
Definiert alle möglichen Zustände, die ein Antrag haben kann. Der Standard-Satz funktioniert für die meisten Server.

**Alle Standard-Status:**

| ID | Anzeigename | Bürger sieht das? | Justiz sieht das? |
|----|-------------|-------------------|-------------------|
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

> **Hinweis:** `escalated` wird Bürgern **nicht** gezeigt – so merken sie nicht, dass ihr Antrag intern eskaliert wurde.

---

### 4.10 SLA und Fristen (`Config.Workflows`)

**Was ist SLA?**  
SLA (Service Level Agreement) ist eine **Bearbeitungs-Frist**. Wenn ein Antrag nicht innerhalb dieser Zeit bearbeitet wird, passiert etwas (z.B. Discord-Nachricht, Eskalation).

```lua
Config.Workflows = {
  Aktiviert = true,

  -- Ab welchem Grade gilt jemand als "Leitung"?
  -- Leitung darf: SLA pausieren, Sperren aufheben, Eskalations-Nachrichten empfangen
  Leitung = {
    MinGrade = 2,   -- ← ANPASSEN: Ab welchem Grade ist jemand Leitung?
  },

  -- SLA-Einstellungen
  Sla = {
    DefaultSlaHours      = 48,   -- Standard-Frist: 48 Stunden (falls Kategorie keine eigene hat)
    TickIntervalSekunden = 30,   -- Wie oft prüft das System ob eine Frist überschritten ist?
  },

  -- Soft-Sperren (verhindert dass 2 Bearbeiter gleichzeitig denselben Antrag bearbeiten)
  Sperren = {
    Aktiviert            = true,
    ExklusiveBearbeitung = true,
    TimeoutSekunden      = 600,   -- Nach 10 Minuten ohne Aktivität läuft die Sperre ab
    HeartbeatSekunden    = 45,    -- Alle 45s wird die Sperre erneuert solange der Bearbeiter aktiv ist
  },

  -- Eskalation bei überfälligen Anträgen
  Eskalation = {
    Aktiviert               = true,
    UeberfaelligNachStunden = 72,  -- Nach 72h ohne Bearbeitung: Eskalations-Webhook senden
  },
}
```

**Wie läuft SLA in der Praxis ab?**

1. Spieler reicht Antrag ein → SLA-Countdown startet (z.B. 48 Stunden)
2. Wenn Status auf `question_open` wechselt → Countdown **pausiert** (Spieler muss antworten)
3. Wenn Spieler antwortet und Status wechselt → Countdown läuft weiter
4. Wenn Frist abläuft → `due_state = "overdue"` in der Datenbank + Discord-Webhook
5. Nach `UeberfaelligNachStunden` → Antrag wird als `escalated` markiert

---

### 4.11 Ingame-Benachrichtigungen (`Config.Benachrichtigungen`)

**Was macht dieser Abschnitt?**  
Spieler bekommen Ingame-Nachrichten wenn sich an ihren Anträgen etwas ändert.

```lua
Config.Benachrichtigungen = {
  Aktiviert = true,
  Ingame = {
    Aktiviert       = true,
    Anbieter        = "esx",   -- "esx" (Standard-ESX-Benachrichtigungen)
    StandardDauerMs = 5500,    -- Wie lange wird die Nachricht angezeigt? (in Millisekunden)
                               -- 5500 = 5,5 Sekunden
  },

  -- Texte der Benachrichtigungen
  -- {id} = Aktenzeichen, {status} = neuer Status
  Texte = {
    antrag_eingereicht   = "Dein Antrag wurde unter Aktenzeichen {id} erfolgreich eingereicht.",
    status_geaendert     = "Dein Antrag {id} wurde auf Status '{status}' gesetzt.",
    rueckfrage_gestellt  = "Zum Antrag {id} wurde eine Rückfrage gestellt.",
    oeffentliche_antwort = "Zu deinem Antrag {id} gibt es eine neue Nachricht der Behörde.",
    antrag_genehmigt     = "Dein Antrag {id} wurde genehmigt.",
    antrag_abgelehnt     = "Dein Antrag {id} wurde abgelehnt.",
  }
}
```

---

### 4.12 Discord-Webhooks (`Config.Webhooks`)

**Was ist ein Webhook?**  
Ein Webhook ist eine automatische Nachricht, die das Script in einen Discord-Kanal schickt, wenn etwas passiert (z.B. neuer Antrag, Eskalation, Gebühr abgezogen).

**Wie erstelle ich einen Webhook in Discord?**
1. Discord-Server → Kanal-Einstellungen → „Integrationen" → „Webhooks" → „Neuer Webhook"
2. Webhook-URL kopieren
3. URL in die config.lua eintragen

```lua
Config.Webhooks = {

  -- Dedizierte URLs für bestimmte System-Events
  Urls = {
    ["pdf_export"]        = nil,   -- nil = kein Webhook für dieses Event
    ["antrag_escalation"] = "https://discord.com/api/webhooks/DEINE_URL_HIER",
    ["antrag_payments"]   = "https://discord.com/api/webhooks/DEINE_URL_HIER",
    ["integrationen"]     = nil,
    ["admin_ops"]         = "https://discord.com/api/webhooks/DEINE_URL_HIER",
    ["missbrauch"]        = "https://discord.com/api/webhooks/DEINE_URL_HIER",
  },

  -- Routing nach Event-Typ (für normale Antrags-Events)
  Routing = {
    Fallback    = nil,  -- Fallback-URL wenn kein anderer Eintrag passt

    -- Welcher Event → welcher Kanal?
    NachEvent = {
      antrag_created        = "https://discord.com/api/webhooks/...",
      antrag_status_changed = "https://discord.com/api/webhooks/...",
      antrag_question_asked = "https://discord.com/api/webhooks/...",
    },

    -- Bestimmte Kategorien in eigene Kanäle leiten
    NachKategorie = {
      ["gewerbe"] = "https://discord.com/api/webhooks/...",
    },

    -- Bestimmte Formulare in eigene Kanäle leiten
    NachFormular = {
      ["eilantrag"] = "https://discord.com/api/webhooks/...",
    },
  },

  -- Warteschlange für fehlgeschlagene Webhooks (Retry)
  Warteschlange = {
    Aktiviert         = true,
    MaxGroesse        = 5000,
    WorkerIntervallMs = 750,
    MaxProIntervall   = 5,
    Wiederholung = {
      Aktiviert   = true,
      MaxVersuche = 5,
      BackoffMs   = { 1000, 3000, 7000, 15000, 30000 }
    }
  },

  -- Discord @Erwähnung bei kritischen Events
  Pings = {
    Aktiviert = false,    -- Standard: ausgeschaltet
    RolleId   = nil,      -- Discord-Rollen-ID (Rechtklick auf Rolle → ID kopieren)
    NurFuerEvents = {
      "abuse_triggered",          -- Bei Missbrauchs-Block
      "antrag_hartgeloescht",     -- Bei Hard-Delete durch Admin
      "admin_status_override",    -- Bei Status-Überschreibung durch Admin
    }
  },

  -- Name und Avatar des Webhook-Bots in Discord
  Identitaet = {
    Benutzername = "HM Bürgerportal",
    AvatarUrl    = nil,   -- Optional: URL zu einem Bild
    Footer       = "HM Bürgerportal",
  },
}
```

**Routing-Reihenfolge** (die erste passende Regel gewinnt):
1. `NachFormular` – spezifisch für ein Formular
2. `NachKategorie` – spezifisch für eine Kategorie
3. `NachEvent` – nach Event-Typ
4. `Fallback` – alles andere

---

### 4.13 Missbrauchsschutz (`Config.AntiSpam`)

**Was macht dieser Abschnitt?**  
Schützt den Server vor Spam und Missbrauch (zu viele Anträge in kurzer Zeit, identische Anträge usw.).

> **Wichtig:** Alles hier ist standardmäßig **ausgeschaltet**. Du musst jeden Teil aktiv aktivieren.

```lua
Config.AntiSpam = {
  Aktiviert = false,   -- ← Master-Schalter: erst auf true setzen wenn konfiguriert!

  -- Globale Grundschutz-Werte
  GlobalerCooldownSekunden    = 15,   -- Wartezeit zwischen zwei Anträgen (Sekunden)
  MaxOffeneAntraegeProSpieler = 5,    -- Wie viele offene Anträge gleichzeitig?
  MinTextLaenge               = 3,    -- Texte kürzer als das werden abgelehnt
  MaxTextLaenge               = 2000, -- Texte länger als das werden abgelehnt

  -- Cooldown pro Formular (überschreibt globalen Cooldown)
  PerFormularCooldown = {
    ["gewerbe_anmeldung"] = 120,  -- 2 Minuten Cooldown nur für dieses Formular
  },

  -- Wörter-Blacklist
  Blackliste = {
    Aktiviert = false,
    Woerter   = { "spam", "test123" },  -- Groß-/Kleinschreibung wird ignoriert
  },

  -- Duplikat-Erkennung (gleicher Text = Duplikat)
  DuplikatPruefung = {
    Aktiviert      = false,
    FensterMinuten = 30,   -- Duplikate aus den letzten 30 Minuten werden erkannt
  },

  -- Rate-Limiting (zu viele Aktionen in kurzer Zeit)
  RateLimit = {
    Aktiviert   = false,
    MaxAktionen = 20,   -- Maximal 20 Aktionen ...
    ProSekunden = 60,   -- ... in 60 Sekunden
  },

  -- Lockout nach zu vielen Fehlversuchen
  Lockout = {
    Aktiviert       = false,
    MaxFehlversuche = 5,    -- Nach 5 Versuchen gesperrt
    DauerSekunden   = 300,  -- 5 Minuten Sperre
  },
}
```

---

### 4.14 Modul-Schalter (`Config.Module`)

**Was macht dieser Abschnitt?**  
Hier kannst du ganze Funktionsbereiche des Portals ein- oder ausschalten.

> **Tipp:** Diese Einstellungen können auch **live im Admin-Panel** (→ Tab „Module") geändert werden, ohne den Server neu zu starten.

```lua
Config.Module = {
  AdminUI          = true,    -- Admin-Bereich in der Benutzeroberfläche
  Anhaenge         = true,    -- Bild-Anhänge an Anträge (Links)
  Gebuehren        = true,    -- Gebührensystem (braucht Banking-Script)
  Delegation       = false,   -- Im-Auftrag-Einreichung / Vollmacht-System
  Entwuerfe        = false,   -- Entwürfe speichern für Justiz-Mitarbeiter
  Exporte          = true,    -- CSV und PDF Export
  AuditHaertung    = true,    -- Erweiterte Sicherheit für Audit-Logs
  Webhooks         = true,    -- Discord-Webhooks
  Benachrichtigungen = true,  -- Ingame-Benachrichtigungen an Spieler
  Integrationen    = false,   -- Folgeaktionen bei Statuswechseln (fortgeschritten)
}
```

**Was passiert wenn ein Modul ausgeschaltet ist?**

- `AdminUI = false` → Admins sehen keinen Admin-Bereich im Portal
- `Anhaenge = false` → Spieler können keine Bild-Links an Anträge hängen
- `Gebuehren = false` → Keine Gebühren werden erhoben (auch wenn Formulare Gebühren haben)
- `Webhooks = false` → Keine Discord-Nachrichten werden gesendet
- `Benachrichtigungen = false` → Spieler bekommen keine Ingame-Meldungen

---

### 4.15 Anhänge (`Config.Anhaenge`)

**Was macht dieser Abschnitt?**  
Spieler können Bild-Links (z.B. Imgur, Discord CDN) an ihre Anträge hängen. Aus Sicherheitsgründen sind nur bestimmte Hosting-Dienste erlaubt.

```lua
Config.Anhaenge = {
  Aktiviert       = true,
  MaxProAntrag    = 10,         -- Maximal 10 Anhänge pro Antrag

  ErlaubteSchemes = { "https" }, -- Nur HTTPS-Links erlaubt (kein http://)
  ErlaubteHosts   = {
    "i.imgur.com",
    "imgur.com",
    "cdn.discordapp.com",
    "media.discordapp.net",
    -- Hier weitere erlaubte Domains hinzufügen
  },
  DirektlinkEndungen = { ".png", ".jpg", ".jpeg", ".webp", ".gif" },

  -- In welchen Status darf der Bürger Anhänge hinzufügen?
  BuergerErlaubteStatus = { "submitted", "question_open" },

  Preview = { NurBeiDirektlink = true },  -- Vorschau nur bei direkten Bild-Links
}
```

---

### 4.16 Audit-Logs (`Config.Audit`)

**Was macht dieser Abschnitt?**  
Alle wichtigen Aktionen werden in der Datenbank protokolliert (Audit-Log). Dieser Abschnitt regelt wie lange die Einträge aufbewahrt werden.

```lua
Config.Audit = {
  Aktiviert = true,

  Retention = {
    TageMax = 90,   -- Audit-Einträge nach 90 Tagen automatisch löschen
  },

  Cleanup = {
    IntervalSekunden = 3600,  -- Aufräum-Job läuft alle 3600 Sekunden (= 1 Stunde)
  },

  LeitungDarfLesen = true,  -- Justiz-Leitung (ab MinGrade) darf das Audit-Log lesen
}
```

---

### 4.17 Delegation (`Config.Delegation`)

**Was ist Delegation?**  
Mit Delegation kann ein Spieler **im Namen eines anderen** Anträge einreichen, z.B.:
- Anwalt reicht für seinen Mandanten einen Antrag ein
- Justiz-Mitarbeiter erstellt für einen Bürger, der nicht online ist, einen Antrag

> **Voraussetzung:** `Config.Module.Delegation = true` setzen.

```lua
Config.Delegation = {
  Vollmacht = {
    Aktiviert = false,  -- true = Delegation nur mit vorher erteilter Vollmacht möglich
  },

  MaxSuchergebnisse = 20,  -- Wie viele Spieler werden bei der Namenssuche angezeigt?

  -- Wer darf im Auftrag von wem einreichen?
  ErlaubteTypen = {
    buerger = { "submit_for_citizen", "submit_for_company" },
    justiz  = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
    admin   = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
  },
}
```

**Aktivierung:**
```lua
Config.Module.Delegation    = true   -- Modul einschalten
Config.Delegation.Vollmacht = { Aktiviert = true }  -- optional: Vollmacht-Pflicht
```

---

### 4.18 Integrationen (`Config.Integrationen`)

**Was macht dieser Abschnitt?**  
Fortgeschrittene Funktion: Das System kann bei Statuswechseln **automatisch andere Scripts benachrichtigen** oder Datenbank-Flags setzen.

> **Voraussetzung:** Beide Flags müssen gesetzt sein: `Config.Module.Integrationen = true` **UND** `Config.Integrationen.Aktiviert = true`.

```lua
Config.Integrationen = {
  Aktiviert           = false,  -- Master-Schalter
  MaxAktionenProQueue = 20,     -- Maximal 20 Folgeaktionen auf einmal
  MaxGesamtZeitMs     = 4000,   -- Abbruch nach 4 Sekunden (Sicherheits-Timeout)

  -- Nur diese Aktionstypen sind erlaubt (Sicherheitsliste)
  ErlaubteAktionsTypen = {
    "emit_server_event",   -- Server-Event auslösen
    "call_export",         -- Funktion in anderem Script aufrufen
    "set_db_flag",         -- Datenbank-Flag setzen
    "send_webhook_event",  -- Webhook senden
  },

  -- Welche Server-Events dürfen ausgelöst werden? (muss explizit erlaubt sein)
  ErlaubteServerEvents = {
    "mein_script:antrag_genehmigt",
  },

  -- Welche Exports dürfen aufgerufen werden?
  ErlaubteExports = {
    "mein_script:AntragVerarbeiten",
  },

  -- Welche Datenbank-Flags dürfen gesetzt werden?
  ErlaubteDBFlags = {
    "vorgang_abgeschlossen",
    "akte_geschlossen",
  },
}
```

---

## 5. Vollständige Beispiel-Setups

### Setup A – Kleiner Roleplay-Server (Minimalsetup)

**Situation:** Du hast einen kleinen Server, möchtest das Bürgerportal einfach und ohne viel Schnickschnack betreiben. Keine Gebühren, keine Discord-Webhooks, einfache Jobs.

```lua
-- ═══════════════════════════════════════════════════════════════
-- SETUP A: Kleiner Server – Minimalsetup
-- ═══════════════════════════════════════════════════════════════

-- Kern: Jobs anpassen
Config.Kern.Jobs.Admin  = "admin"       -- dein Admin-Job in ESX
Config.Kern.Jobs.Justiz = "police"      -- dein Polizei/Behörden-Job in ESX
Config.Kern.Justiz.Job  = "police"      -- gleicher Wert wie Jobs.Justiz
Config.Kern.Debugmodus  = false

-- Datenbank: Automatische Migrationen aktiv lassen
Config.Datenbank.Migrationen.BeimStartAutomatisch = true

-- Gebühren: Ausschalten (kein Banking-Script vorhanden)
Config.Module.Gebuehren = false

-- Discord: Keine Webhooks
Config.Module.Webhooks = false

-- Module: Nur das Nötigste
Config.Module = {
  AdminUI            = true,   -- Admin-Bereich
  Anhaenge           = true,   -- Bild-Links erlauben
  Gebuehren          = false,  -- Keine Gebühren
  Delegation         = false,  -- Kein Vollmacht-System
  Entwuerfe          = false,  -- Keine Entwürfe
  Exporte            = true,   -- Export erlauben
  AuditHaertung      = true,   -- Audit-Sicherheit
  Webhooks           = false,  -- Kein Discord
  Benachrichtigungen = true,   -- Ingame-Nachrichten
  Integrationen      = false,  -- Keine Folgeaktionen
}

-- Missbrauchsschutz: Einfacher Grundschutz
Config.AntiSpam.Aktiviert                   = true
Config.AntiSpam.GlobalerCooldownSekunden    = 30
Config.AntiSpam.MaxOffeneAntraegeProSpieler = 5
```

**server.cfg für Setup A:**
```cfg
ensure oxmysql
ensure es_extended
ensure hm_buergerportal
```

---

### Setup B – Mittlerer RP-Server mit vollständiger Justiz

**Situation:** Du hast einen mittelgroßen Roleplay-Server mit einem DoJ-Job. Gebühren werden erhoben, Discord-Webhooks für wichtige Events. Kein Vollmacht-System, aber AntiSpam aktiv.

```lua
-- ═══════════════════════════════════════════════════════════════
-- SETUP B: Mittlerer Server – Vollständige Justiz
-- ═══════════════════════════════════════════════════════════════

-- Kern
Config.Kern.Jobs.Admin  = "admin"
Config.Kern.Jobs.Justiz = "doj"
Config.Kern.Justiz.Job  = "doj"
Config.Kern.Debugmodus  = false

Config.Kern.OeffentlicheIds = {
  Aktiviert = true,
  Prefix    = "DOJ",
  Format    = "PREFIX-YYYY-MM-NNNNNN",
  Stellen   = 6,
}

-- Gebühren (wasabi_banking ist installiert)
Config.Zahlung.SocietyKonto = "society_doj"
Config.Zahlung.Modus        = "bei_entscheidung"
Config.Zahlung.Erstattungen = {
  aktiv  = true,
  regeln = {
    { status = "rejected",  prozent = 100 },
    { status = "withdrawn", prozent = 50  },
  },
}

-- Webhooks (nur wichtige Events)
Config.Webhooks.Urls["antrag_escalation"] = "https://discord.com/api/webhooks/AAA/BBB"
Config.Webhooks.Urls["antrag_payments"]   = "https://discord.com/api/webhooks/CCC/DDD"
Config.Webhooks.Urls["admin_ops"]         = "https://discord.com/api/webhooks/EEE/FFF"

Config.Webhooks.Routing.NachEvent = {
  antrag_created        = "https://discord.com/api/webhooks/GGG/HHH",  -- Neue Anträge
  antrag_status_changed = "https://discord.com/api/webhooks/GGG/HHH",  -- Statuswechsel
}

-- Module
Config.Module = {
  AdminUI            = true,
  Anhaenge           = true,
  Gebuehren          = true,   -- ← Aktiv (wasabi_banking vorhanden)
  Delegation         = false,
  Entwuerfe          = false,
  Exporte            = true,
  AuditHaertung      = true,
  Webhooks           = true,   -- ← Aktiv
  Benachrichtigungen = true,
  Integrationen      = false,
}

-- Job-Settings: DoJ Grade 2+ = Leitung
Config.JobSettings.Jobs["doj"] = {
  anzeigeName        = "Department of Justice",
  globalDefaultRolle = "justiz",
  grades = {
    { grade = 0, name = "Associate"  },
    { grade = 1, name = "Attorney"   },
    { grade = 2, name = "Senior Attorney" },
    { grade = 3, name = "Chief of Staff"  },
    { grade = 4, name = "Attorney General"},
  },
  gradPermissions = {
    [2] = {
      allow = {
        "submissions.view_all",
        "submissions.view_archive",
        "submissions.archive",
        "submissions.assign",
        "submissions.set_priority",
        "workflow.lock.override",
        "workflow.sla.pause",
        "workflow.sla.resume",
        "notes.internal.write",
        "form_editor.publish",
        "form_editor.archive",
      },
      deny = {},
    },
  },
}

-- AntiSpam: Aktiviert mit Grundschutz
Config.AntiSpam = {
  Aktiviert                   = true,
  GlobalerCooldownSekunden    = 30,
  MaxOffeneAntraegeProSpieler = 5,
  Blackliste       = { Aktiviert = true,  Woerter = { "spam", "test" } },
  DuplikatPruefung = { Aktiviert = true,  FensterMinuten = 60 },
  Lockout          = { Aktiviert = false },
}

-- SLA: 48h Standard, Eskalation nach 72h
Config.Workflows.Sla.DefaultSlaHours       = 48
Config.Workflows.Eskalation.Aktiviert      = true
Config.Workflows.Eskalation.UeberfaelligNachStunden = 72
```

**server.cfg für Setup B:**
```cfg
ensure oxmysql
ensure es_extended
ensure wasabi_banking

ensure hm_buergerportal
```

---

### Setup C – Großer Server mit allen Features

**Situation:** Du hast einen großen Server, möchtest alle Features nutzen: Vollmacht-System, Integrationen, vollständiger AntiSpam, Discord-Pings für kritische Events.

```lua
-- ═══════════════════════════════════════════════════════════════
-- SETUP C: Großer Server – Alle Features aktiv
-- ═══════════════════════════════════════════════════════════════

-- Kern
Config.Kern.Jobs.Admin  = "admin"
Config.Kern.Jobs.Justiz = "doj"
Config.Kern.Justiz.Job  = "doj"
Config.Kern.Debugmodus  = false

-- Gebühren mit Erstattung und Befreiungen
Config.Zahlung = {
  SocietyKonto = "society_doj",
  Modus        = "bei_einreichung",   -- Vorauszahlung
  TerminaleStatus = { "approved", "rejected", "withdrawn", "closed", "archived" },
  Erstattungen = {
    aktiv  = true,
    regeln = {
      { status = "rejected",  prozent = 100 },
      { status = "withdrawn", prozent = 75  },
    },
  },
  Befreiungen = {
    aktiv    = true,
    rollen   = { "richter", "staatsanwalt" },  -- Diese Jobs zahlen keine Gebühren
    formulare = { "interne_anfrage" },
  },
}

-- Module: Alle Features aktiv
Config.Module = {
  AdminUI            = true,
  Anhaenge           = true,
  Gebuehren          = true,
  Delegation         = true,    -- ← Vollmacht-System aktiv
  Entwuerfe          = true,    -- ← Entwürfe aktiv
  Exporte            = true,
  AuditHaertung      = true,
  Webhooks           = true,
  Benachrichtigungen = true,
  Integrationen      = true,    -- ← Folgeaktionen aktiv
}

-- Delegation (Vollmacht-System)
Config.Delegation = {
  Vollmacht         = { Aktiviert = true },
  MaxSuchergebnisse = 20,
  ErlaubteTypen = {
    buerger = { "submit_for_citizen", "submit_for_company" },
    justiz  = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
    admin   = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
  },
}

-- Integrationen (Folgeaktionen)
Config.Integrationen = {
  Aktiviert           = true,
  MaxAktionenProQueue = 20,
  MaxGesamtZeitMs     = 4000,
  ErlaubteAktionsTypen = { "emit_server_event", "set_db_flag", "send_webhook_event" },
  ErlaubteServerEvents = { "mein_script:antrag_genehmigt" },
  ErlaubteDBFlags      = { "vorgang_abgeschlossen", "akte_geschlossen" },
}

-- Vollständiger AntiSpam
Config.AntiSpam = {
  Aktiviert                   = true,
  GlobalerCooldownSekunden    = 60,
  MaxOffeneAntraegeProSpieler = 3,
  MinTextLaenge               = 10,
  MaxTextLaenge               = 1500,
  Blackliste       = { Aktiviert = true,  Woerter = { "spam", "test123" } },
  DuplikatPruefung = { Aktiviert = true,  FensterMinuten = 60 },
  RateLimit        = { Aktiviert = true,  MaxAktionen = 10, ProSekunden = 60 },
  Lockout          = { Aktiviert = true,  MaxFehlversuche = 3, DauerSekunden = 600 },
}

-- Discord-Pings für kritische Events
Config.Webhooks.Pings = {
  Aktiviert = true,
  RolleId   = "123456789012345678",   -- ← ANPASSEN: Deine Discord-Rollen-ID
  NurFuerEvents = {
    "abuse_triggered",
    "antrag_hartgeloescht",
    "admin_status_override",
  }
}

-- Audit: Längere Aufbewahrung
Config.Audit.Retention.TageMax = 180   -- 6 Monate
```

**server.cfg für Setup C:**
```cfg
ensure oxmysql
ensure es_extended
ensure wasabi_banking

ensure hm_buergerportal
```

---

## 6. Troubleshooting – Häufige Probleme und Lösungen

### Problem: „Das Script startet nicht" / Fehlermeldung im Server-Log

**Symptom:** Im Server-Log erscheint ein Fehler wie `attempt to index a nil value` oder `Script 'hm_buergerportal' has an error`

**Ursachen und Lösungen:**

| Fehlerbild | Wahrscheinliche Ursache | Lösung |
|---|---|---|
| `attempt to index a nil value (global 'HM_BP')` | Falsche Start-Reihenfolge | Prüfe server.cfg: `oxmysql` und `es_extended` müssen **vor** `hm_buergerportal` stehen |
| `Syntax error` in config.lua | Tippfehler in config.lua | Öffne config.lua im Editor und suche nach rot markierten Zeilen |
| Kein Log-Output nach Start | Migrationssystem deaktiviert | `Config.Datenbank.Migrationen.BeimStartAutomatisch = true` setzen |

---

### Problem: „Tabellen fehlen" / Datenbankfehler

**Symptom:** Fehlermeldungen wie `hm_bp_submissions not found` oder `Table doesn't exist`

**Lösung:**
1. Prüfe ob `Config.Datenbank.Migrationen.BeimStartAutomatisch = true` gesetzt ist
2. Starte den Server neu
3. Prüfe das Server-Log auf Zeilen wie `[hm_buergerportal] Migration angewendet: v1_core_tables`
4. Wenn Migrationen fehlen: Prüfe ob `oxmysql` gestartet ist und die Datenbankverbindung funktioniert

---

### Problem: „Gebühren werden nicht abgezogen"

**Symptom:** Anträge werden genehmigt/abgelehnt, aber keine Gebühr wird abgezogen

**Checkliste:**
- [ ] `Config.Module.Gebuehren = true` gesetzt?
- [ ] Das Banking-Script (`wasabi_banking`, `wasabi_billing`, `esx_banking` oder `esx_billing`) ist in `server.cfg` eingetragen und startet vor `hm_buergerportal`?
- [ ] `Config.Zahlung.SocietyKonto` hat den richtigen Namen des Society-Kontos?
- [ ] Das Formular hat `gebuehren.aktiv = true` und einen `betrag > 0`?
- [ ] Ist der Spieler in `Config.Zahlung.Befreiungen.rollen` oder `.formulare` eingetragen (also von Gebühren befreit)?

---

### Problem: „Gebühr geht nicht auf das Society-Konto"

**Symptom:** Gebühr wird vom Spieler abgezogen, aber das Society-Konto empfängt nichts

**Lösung:**  
Prüfe den genauen Namen des Society-Kontos in deiner Banking-Ressource.  
Beispiel: In `wasabi_banking` heißt das Konto oft `society_doj` – schaue in die Konfiguration deines Banking-Scripts für den exakten Namen.

```lua
Config.Zahlung.SocietyKonto = "society_doj"   -- ← exakter Name aus dem Banking-Script
```

---

### Problem: „Justiz sieht keine Anträge" / „Justiz-Tab ist nicht sichtbar"

**Symptom:** Spieler mit Justiz-Job sieht den Justiz-Bereich nicht

**Checkliste:**
- [ ] `Config.Kern.Justiz.Job` und `Config.Kern.Jobs.Justiz` haben **denselben** Wert?
- [ ] Der Job-Name in der Config stimmt **exakt** mit dem ESX-Job-Namen überein (Groß-/Kleinschreibung beachten)?
- [ ] Hat der Justiz-Job mindestens `grade = 0` in `Config.JobSettings.Jobs`?
- [ ] Überprüfe im Spiel: `/esxinfo` oder ähnlich um den genauen Job-Namen zu sehen

---

### Problem: „Admin sieht keinen Admin-Bereich"

**Symptom:** Spieler mit Admin-Job sieht den Admin-Tab nicht

**Checkliste:**
- [ ] `Config.Module.AdminUI = true` gesetzt?
- [ ] `Config.Kern.Admin.Job` hat den richtigen Job-Namen?
- [ ] `Config.Kern.Admin.MinGrade` – hat der Spieler diesen Grade oder höher?
- [ ] `data/admin_overrides.json` prüfen – könnte dort `AdminUI: false` gesetzt sein

---

### Problem: „Keine Discord-Nachrichten"

**Symptom:** Anträge werden eingereicht/bearbeitet, aber keine Webhooks in Discord

**Checkliste:**
- [ ] `Config.Module.Webhooks = true` gesetzt?
- [ ] Webhook-URL in `Config.Webhooks.Urls[...]` oder `Config.Webhooks.Routing.NachEvent[...]` eingetragen?
- [ ] Webhook-URL ist aktuell und nicht abgelaufen (Discord-Webhooks können ungültig werden)?
- [ ] Prüfe Server-Log auf Webhook-Fehler (wenn `Config.Kern.Debugmodus = true` gesetzt)

---

### Problem: „Integrationen werden nicht ausgeführt"

**Symptom:** Folgeaktionen passieren nicht bei Statuswechseln

**Checkliste:**
- [ ] **Beide** Flags gesetzt: `Config.Module.Integrationen = true` **UND** `Config.Integrationen.Aktiviert = true`?
- [ ] Das Formular hat `.integrationen` konfiguriert?
- [ ] Der Status-Hook ist in `Config.Integrationen.StatusHooks` gemappt?
- [ ] Der Event/Export/Flag ist in der Whitelist (`ErlaubteServerEvents`/`ErlaubteExports`/`ErlaubteDBFlags`)?

---

### Problem: „AntiSpam blockiert Spieler zu aggressiv"

**Symptom:** Normale Spieler können keine Anträge einreichen und bekommen Fehlermeldungen

**Lösung:**
- Erhöhe `GlobalerCooldownSekunden` (oder setze ihn auf `0` um den Cooldown zu deaktivieren)
- Erhöhe `MaxOffeneAntraegeProSpieler`
- Überprüfe ob Wörter in der `Blackliste.Woerter` Liste zufällig in normalen Texten vorkommen
- Überprüfe `DuplikatPruefung.FensterMinuten` – bei zu kurzen Texten kann das zu Falschmeldungen führen

---

### Problem: „Änderung in config.lua hat keinen Effekt"

**Symptom:** Du hast etwas in config.lua geändert, aber das Script verhält sich nicht entsprechend

**Mögliche Ursachen:**
1. **Server wurde nicht neu gestartet** → Einstellungen werden erst beim Neustart geladen
2. **Override in admin_overrides.json** → Das Admin-Panel hat einen anderen Wert gesetzt, der config.lua überschreibt  
   → Lösung: Im Admin-Panel → entsprechendes Feld → „Zurücksetzen"
3. **Tippfehler in config.lua** → Lua-Syntaxfehler führt dazu dass der Abschnitt nicht geladen wird  
   → Prüfe Server-Log auf Lua-Fehler

---

### Problem: „Migrationen laufen beim Start nicht"

**Symptom:** Im Server-Log erscheint keine Migration-Zeile

**Lösung:**
```lua
Config.Datenbank.Migrationen.BeimStartAutomatisch = true
Config.Datenbank.Migrationen.Aktiviert            = true
```
Beide Werte auf `true` setzen und Server neu starten.

---

### Wo finde ich mehr Hilfe?

- **Vollständige Config-Referenz:** [`docs/CONFIG_REFERENCE.md`](CONFIG_REFERENCE.md)
- **Admin-Panel Anleitung:** [`docs/ADMIN_UI_GUIDE_DE.md`](ADMIN_UI_GUIDE_DE.md)
- **Überblick und Installation:** [`README.md`](../README.md)
