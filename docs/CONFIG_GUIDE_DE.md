# Konfigurationsanleitung – hm_buergerportal

> **Für wen ist diese Anleitung?**  
> Für alle, die das Bürgerportal auf ihrem FiveM-Server einrichten möchten – auch ohne IT-Kenntnisse.  
> Hier wird Schritt für Schritt erklärt, was du wo ändern musst und warum.

---

## Inhaltsverzeichnis

1. [Was ist die config.lua?](#1-was-ist-die-configlua)
2. [Grundregeln beim Bearbeiten der config.lua](#2-grundregeln-beim-bearbeiten-der-configlua)
3. [Schritt 1 – Job-Namen eintragen](#3-schritt-1--job-namen-eintragen)
4. [Schritt 2 – Datenbank-Einstellungen](#4-schritt-2--datenbank-einstellungen)
5. [Schritt 3 – Gebühren konfigurieren](#5-schritt-3--gebühren-konfigurieren)
6. [Schritt 4 – Feature-Flags (Module ein-/ausschalten)](#6-schritt-4--feature-flags-module-ein--ausschalten)
7. [Schritt 5 – Discord-Webhooks einrichten](#7-schritt-5--discord-webhooks-einrichten)
8. [Schritt 6 – Standorte in der Spielwelt](#8-schritt-6--standorte-in-der-spielwelt)
9. [Schritt 7 – Berechtigungen (Wer darf was?)](#9-schritt-7--berechtigungen-wer-darf-was)
10. [Schritt 8 – Job-Grade-Berechtigungen (JobSettings)](#10-schritt-8--job-grade-berechtigungen-jobsettings)
11. [Schritt 9 – Kategorien und Formulare](#11-schritt-9--kategorien-und-formulare)
12. [Schritt 10 – AntiSpam aktivieren](#12-schritt-10--antispam-aktivieren)
13. [Schritt 11 – Delegation / Vollmacht](#13-schritt-11--delegation--vollmacht)
14. [Schritt 12 – Integrationen (Folgeaktionen)](#14-schritt-12--integrationen-folgeaktionen)
15. [Was sind Overrides? (data/admin_overrides.json)](#15-was-sind-overrides-dataadmin_overridesjson)
16. [Checkliste: Minimal lauffähige Konfiguration](#16-checkliste-minimal-lauffähige-konfiguration)
17. [Häufige Fehler und ihre Lösungen](#17-häufige-fehler-und-ihre-lösungen)

---

## 1. Was ist die config.lua?

Die Datei `config.lua` ist die **zentrale Steuerdatei** des Bürgerportals. Hier legst du fest:

- Welche **Jobs** (Berufe) auf deinem Server Admin und Justiz sind
- Ob **Gebühren** abgezogen werden sollen und wohin das Geld fließt
- Welche **Discord-Channels** Benachrichtigungen bekommen
- Welche **Funktionen** überhaupt aktiv sein sollen (sogenannte Feature-Flags)
- Wo im Spiel das Portal geöffnet werden kann (Standorte)

> **Einfach gesagt:** Die `config.lua` ist wie die Fernbedienung für das gesamte System.  
> Du musst **kein Programmierer** sein – du änderst nur bestimmte Werte zwischen den Anführungszeichen oder Zahlen.

### Wo liegt die Datei?

```
resources/
  [hm]/
    hm_buergerportal/
      config.lua       ← Das ist die Datei
      fxmanifest.lua
      client/
      server/
      ...
```

---

## 2. Grundregeln beim Bearbeiten der config.lua

### Texte (Strings)

Texte stehen immer in **Anführungszeichen**:

```lua
Jobs.Admin = "admin"     -- "admin" ist der Text
```

Wenn du den Job-Namen änderst, ersetzt du nur den Text zwischen den Anführungszeichen.

### Zahlen

Zahlen stehen **ohne** Anführungszeichen:

```lua
MinGrade = 0     -- 0 ist eine Zahl
```

### Wahr/Falsch (true/false)

Schalter sind entweder `true` (an) oder `false` (aus):

```lua
Aktiviert = true    -- eingeschaltet
Aktiviert = false   -- ausgeschaltet
```

### Kommentare (-- ...)

Alles nach `--` ist ein Kommentar und wird vom Spiel ignoriert:

```lua
Jobs.Admin = "admin"   -- Das hier wird ignoriert, es ist nur eine Erklärung
```

### Wichtig: Kein Schaden, solange du nur Werte änderst

Du kannst keine Funktionen kaputt machen, solange du nur die **Werte** (Texte, Zahlen, true/false) änderst und die Struktur der Datei nicht veränderst. Lösche keine geschweiften Klammern `{ }` oder Kommas `,`.

---

## 3. Schritt 1 – Job-Namen eintragen

Das ist der **wichtigste Schritt**. Hier trägst du ein, wie deine Admin- und Justiz-Jobs auf deinem Server heißen.

### Standard-Werte im Script

| Einstellung | Standard-Wert | Was es bedeutet |
|---|---|---|
| `Config.Kern.Jobs.Admin` | `"admin"` | Job-Name deines Admin-Jobs |
| `Config.Kern.Jobs.Justiz` | `"doj"` | Job-Name des Justiz-Jobs (Fallback) |
| `Config.Kern.Admin.Job` | `"admin"` | Admin-Job für Vollzugriff |
| `Config.Kern.Admin.MinGrade` | `0` | Mindestrang für Admin-Zugang (0 = alle Ränge) |
| `Config.Kern.Justiz.Job` | `"doj"` | Hauptname des Justiz-Jobs (wird von allen Teilen des Systems genutzt) |

### So änderst du es

Suche in der `config.lua` nach diesem Block:

```lua
Config.Kern = {
  Jobs = {
    Admin  = "admin",   -- ← Hier deinen Admin-Job-Namen eintragen
    Justiz = "doj",     -- ← Hier deinen Justiz-Job-Namen eintragen
  },

  Admin = {
    Job      = "admin", -- ← Gleicher Wert wie Jobs.Admin
    MinGrade = 0,       -- ← 0 = alle Ränge des Admin-Jobs haben Zugang
  },

  Justiz = {
    Job = "doj",        -- ← Gleicher Wert wie Jobs.Justiz
  },
  ...
}
```

### Beispiel für einen typischen Server

Angenommen dein Admin-Job heißt `admin` und dein Justiz-Job heißt `doj`:

```lua
Config.Kern = {
  Jobs = {
    Admin  = "admin",
    Justiz = "doj",
  },
  Admin = {
    Job      = "admin",
    MinGrade = 0,
  },
  Justiz = {
    Job = "doj",
  },
  Debugmodus = false,   -- Auf false lassen (nur für Entwickler)
  OeffentlicheIds = {
    Aktiviert = true,
    Prefix    = "HM-DOJ",
    Format    = "PREFIX-YYYY-MM-NNNNNN",
    Stellen   = 6,
  }
}
```

> **Achtung:** `Config.Kern.Justiz.Job` und `Config.Kern.Jobs.Justiz` müssen **immer denselben Wert** haben.  
> Wenn sie unterschiedlich sind, kann es passieren, dass verschiedene Teile des Scripts unterschiedliche Job-Namen nutzen und das Portal dann nicht richtig funktioniert.

### Was macht der MinGrade?

`MinGrade` legt fest, ab welchem **Rang** (Grade) ein Admin Zugang zum Admin-Bereich hat.

- `MinGrade = 0` → Alle Ränge des Admin-Jobs haben Zugang (empfohlen)
- `MinGrade = 2` → Nur Ränge 2 und höher haben Zugang

---

## 4. Schritt 2 – Datenbank-Einstellungen

Das Bürgerportal erstellt seine Datenbank-Tabellen **automatisch** beim ersten Serverstart. Du musst nichts manuell in die Datenbank importieren.

```lua
Config.Datenbank = {
  Adapter = "oxmysql",        -- Nicht ändern! oxmysql ist der einzige unterstützte Adapter
  Migrationen = {
    Aktiviert            = true,  -- Nicht ausschalten!
    BeimStartAutomatisch = true,  -- Tabellen werden beim Start automatisch angelegt
  }
}
```

### Was ist eine Migration?

Eine Migration ist wie ein automatisches Update für die Datenbank. Wenn das Script eine neue Tabelle oder Spalte braucht, wird diese automatisch beim Serverstart angelegt – du musst nichts machen.

### Wie erkennst du, ob die Migrationen erfolgreich waren?

Beim Serverstart siehst du im **Server-Log** (Konsole) diese Zeilen:

```
[hm_buergerportal] Migration angewendet: v1_core_tables
[hm_buergerportal] Migration angewendet: v2_monats_sequenzen
...
[hm_buergerportal] Alle Migrationen erfolgreich abgeschlossen.
[hm_buergerportal] Bürgerportal gestartet (v0.7.0)
```

Wenn du diese Zeilen siehst – alles gut!

> **Fehler:** Wenn Tabellen fehlen oder das Script nicht startet, stelle sicher, dass  
> `BeimStartAutomatisch = true` gesetzt ist und starte den Server neu.

---

## 5. Schritt 3 – Gebühren konfigurieren

Das Gebührensystem zieht automatisch Geld vom Spieler ab, wenn er einen Antrag stellt oder wenn der Antrag entschieden wird.

### Voraussetzung: Bezahlungs-Bibliothek

Das Script erkennt automatisch, welche Banking-Bibliothek du installiert hast. Es prüft in dieser Reihenfolge:

1. `wasabi_banking` (höchste Priorität)
2. `wasabi_billing`
3. `esx_banking`
4. `esx_billing`

Ist keine Bibliothek installiert, gibt das Script beim Start eine Warnung aus und Gebühren können nicht abgezogen werden.

### Das Society-Konto eintragen

Das ist der **Pflichtschritt** für Gebühren. Du musst eintragen, auf welches Server-Konto das Geld eingezahlt werden soll:

```lua
Config.Zahlung = {
  SocietyKonto = "society_justiz",  -- ← Hier den genauen Namen deines Society-Kontos eintragen
  ...
}
```

> **Wo finde ich den Namen meines Society-Kontos?**  
> Das hängt von deiner Banking-Ressource ab. Meistens heißt das Justiz-Konto `society_police`, `society_justiz` oder ähnlich. Schau in deine Banking-Ressource oder frage deinen Serverentwickler.

### Zahlungsmodus: Wann wird abgezogen?

```lua
Config.Zahlung = {
  SocietyKonto = "society_justiz",
  Modus        = "bei_entscheidung",  -- oder "bei_einreichung"
  ...
}
```

| Modus | Bedeutung |
|---|---|
| `"bei_entscheidung"` | Das Geld wird erst abgezogen, wenn der Antrag genehmigt, abgelehnt oder geschlossen wird (**empfohlen**) |
| `"bei_einreichung"` | Das Geld wird sofort beim Einreichen abgezogen |

### Erstattungen aktivieren

Wenn du möchtest, dass Spieler ihr Geld teilweise oder ganz zurückbekommen (z.B. bei Ablehnung), aktiviere Erstattungen:

```lua
Config.Zahlung = {
  SocietyKonto = "society_justiz",
  Modus        = "bei_entscheidung",

  Erstattungen = {
    aktiv = true,                         -- ← Erstattungen einschalten
    regeln = {
      { status = "rejected",  prozent = 100 },  -- Bei Ablehnung: 100% zurück
      { status = "withdrawn", prozent = 50  },  -- Bei Rückzug: 50% zurück
    },
  },
}
```

### Bestimmte Rollen von Gebühren befreien

Wenn Richter oder Staatsanwälte keine Gebühren zahlen sollen:

```lua
Config.Zahlung = {
  ...
  Befreiungen = {
    aktiv  = true,
    rollen = { "richter", "staatsanwalt" },  -- Diese Jobs zahlen keine Gebühren
  },
}
```

### Gebühr pro Formular festlegen

Die eigentliche Höhe der Gebühr wird **direkt am Formular** eingetragen, nicht in `Config.Zahlung`:

```lua
Config.Formulare.Liste["gewerbe_anmeldung"] = {
  ...
  gebuehren = {
    aktiv      = true,   -- Gebühr für dieses Formular aktivieren
    betrag     = 50,     -- 50 Euro
    erstattbar = true,   -- Erstattungsregeln gelten für dieses Formular
  },
}
```

> **Wichtig:** `Config.Module.Gebuehren = true` muss gesetzt sein, damit Gebühren überhaupt funktionieren.

---

## 6. Schritt 4 – Feature-Flags (Module ein-/ausschalten)

Feature-Flags sind die **Hauptschalter** für alle großen Funktionen des Portals. Hier kannst du Dinge komplett an- oder ausschalten.

```lua
Config.Module = {
  AdminUI          = true,    -- Admin-Bereich in der NUI (fast immer true lassen)
  Anhaenge         = true,    -- Spieler können Bild-Links an Anträge hängen
  Gebuehren        = true,    -- Gebührensystem (benötigt Banking-Bibliothek)
  Delegation       = false,   -- Im-Auftrag-Einreichung / Vollmacht-System
  Entwuerfe        = false,   -- Antrags-Entwürfe für Justiz-Mitarbeiter
  Exporte          = true,    -- CSV/PDF-Export von Anträgen
  AuditHaertung    = true,    -- Erweiterte Audit-Sicherheit (empfohlen: true)
  Webhooks         = true,    -- Discord-Benachrichtigungen
  Benachrichtigungen = true,  -- Ingame-Benachrichtigungen per Chat
  Integrationen    = false,   -- Folgeaktionen nach Statuswechsel (fortgeschritten)
}
```

### Was bedeuten die einzelnen Module?

| Modul | Was es macht | Empfehlung |
|---|---|---|
| `AdminUI` | Schaltet den Admin-Bereich im Portal frei | Immer `true` lassen |
| `Anhaenge` | Spieler können Bild-URLs an Anträge hängen (z.B. Screenshots von Imgur) | `true` |
| `Gebuehren` | Aktiviert das gesamte Gebührensystem | `true` wenn Banking vorhanden |
| `Delegation` | Ermöglicht Anträge im Namen anderer Spieler (z.B. Anwalt für Mandanten) | Nur aktivieren wenn benötigt |
| `Entwuerfe` | Justiz-Mitarbeiter können Notizen/Rückfragen als Entwurf speichern | Optional |
| `Exporte` | Anträge als PDF oder CSV exportieren | `true` |
| `AuditHaertung` | Jede Aktion wird unveränderlich protokolliert | `true` (Sicherheit) |
| `Webhooks` | Discord-Benachrichtigungen bei Statusänderungen etc. | `true` wenn Discord gewünscht |
| `Benachrichtigungen` | Spieler bekommen Ingame-Nachrichten (z.B. "Dein Antrag wurde genehmigt") | `true` |
| `Integrationen` | Automatische Folgeaktionen nach Statuswechseln (für Fortgeschrittene) | Erst aktivieren wenn du weißt was du tust |

> **Tipp:** Starte mit den Standardwerten. Du kannst Module jederzeit nachträglich aktivieren – auch über das Admin-Panel im Spiel (ohne Serverneustart).

---

## 7. Schritt 5 – Discord-Webhooks einrichten

Webhooks schicken automatisch Nachrichten in deine Discord-Channels, wenn etwas im Portal passiert (z.B. neuer Antrag, Statuswechsel, Gebühr abgezogen).

### Was ist ein Webhook?

Ein Discord-Webhook ist eine URL (Internetadresse), über die das Script Nachrichten in deinen Discord-Channel schicken kann. Du erstellst die URL in Discord und trägst sie in der `config.lua` ein.

### So erstellst du einen Webhook in Discord

1. Öffne deinen Discord-Server
2. Klicke auf das Zahnrad-Symbol neben dem Channel, in den Nachrichten kommen sollen
3. Klicke auf „Integrationen" → „Webhooks" → „Neuer Webhook"
4. Kopiere die Webhook-URL (fängt mit `https://discord.com/api/webhooks/` an)

### Webhook-URLs eintragen

```lua
Config.Webhooks.Urls = {
  ["antrag_payments"]   = "https://discord.com/api/webhooks/1234567890/DEINE_URL",
  ["antrag_escalation"] = "https://discord.com/api/webhooks/1234567890/DEINE_URL",
  ["admin_ops"]         = "https://discord.com/api/webhooks/1234567890/DEINE_URL",
  ["missbrauch"]        = "https://discord.com/api/webhooks/1234567890/DEINE_URL",
  ["integrationen"]     = nil,  -- nil = kein Webhook für diesen Kanal
  ["pdf_export"]        = nil,
}
```

### Welcher Webhook für was?

| Schlüssel | Wann wird etwas gesendet? |
|---|---|
| `antrag_payments` | Gebühr abgezogen, erstattet oder fehlgeschlagen |
| `antrag_escalation` | SLA-Frist überschritten, Erinnerungen |
| `admin_ops` | Admin hat Antrag verschoben, gelöscht oder Status überschrieben |
| `missbrauch` | Spam-Block, Spieler gesperrt, Blacklist-Treffer |
| `integrationen` | Folgeaktions-Fehler oder -Erfolge |
| `pdf_export` | PDF-Export wurde erstellt |

### Bestimmte Events in eigene Channels leiten

Du kannst auch festlegen, dass **jede Art von Ereignis** in einen eigenen Channel geht:

```lua
Config.Webhooks.Routing = {
  Fallback = nil,   -- Wird genutzt wenn kein anderer Eintrag passt
  NachEvent = {
    antrag_created         = "https://discord.com/api/webhooks/...",  -- Neue Anträge
    antrag_status_changed  = "https://discord.com/api/webhooks/...",  -- Statuswechsel
    antrag_question_asked  = "https://discord.com/api/webhooks/...",  -- Rückfragen
    antrag_citizen_replied = "https://discord.com/api/webhooks/...",  -- Bürger antwortet
  },
  NachKategorie = {
    ["gewerbe"] = "https://discord.com/api/webhooks/...",  -- Nur Gewerbe-Anträge
  },
  NachFormular = {
    ["gewerbe_anmeldung"] = "https://discord.com/api/webhooks/...",  -- Nur dieses Formular
  },
}
```

### Discord-Pings (Rollen anpingen)

Wenn bei besonders wichtigen Ereignissen eine Discord-Rolle angepingt werden soll:

```lua
Config.Webhooks.Pings = {
  Aktiviert = true,
  RolleId   = "123456789012345678",  -- Discord-Rollen-ID (rechtsklick auf Rolle → ID kopieren)
  NurFuerEvents = {
    "abuse_triggered",
    "antrag_hartgeloescht",
    "admin_status_override",
  }
}
```

> **Standard: Pings sind ausgeschaltet** – du musst sie explizit aktivieren.

### Darüber hinaus: Absender-Name und Avatar

```lua
Config.Webhooks.Identitaet = {
  Benutzername = "HM Bürgerportal",
  AvatarUrl    = nil,   -- Optional: URL zu einem Bild für den Webhook-Avatar
  Footer       = "HM Training - Felix Hoffmann",
}
```

---

## 8. Schritt 6 – Standorte in der Spielwelt

Standorte sind die Punkte in der GTA-Welt, wo Spieler das Bürgerportal öffnen können. Dort erscheint ein Marker (farbiger Kreis am Boden), optional ein NPC (PED) und ein Punkt auf der Karte (Blip).

### Globaler Interaktionsmodus

```lua
Config.Standorte.InteraktionsModus = "taste"     -- Spieler drücken E zum Öffnen
-- oder:
Config.Standorte.InteraktionsModus = "ox_target" -- Spieler nutzen ox_target zum Öffnen
```

### Einen Standort hinzufügen

```lua
Config.Standorte.Liste = {
  ["mein_buergeramt"] = {
    id    = "mein_buergeramt",     -- Eindeutige ID (nur kleine Buchstaben, keine Leerzeichen)
    name  = "Bürgeramt",           -- Anzeigename in der UI
    aktiv = true,                  -- true = Standort ist aktiv

    koordinaten        = vector3(440.12, -981.92, 30.69),  -- X, Y, Z Koordinaten in GTA
    heading            = 90.0,                              -- Blickrichtung (0-360)
    interaktionsRadius = 2.0,    -- Wie nah muss der Spieler ran (in Metern)
    sichtbarRadius     = 30.0,   -- Ab wann wird der Marker sichtbar

    -- Zugriff: Wer darf diesen Standort nutzen?
    zugriff = {
      nurBuerger = false,   -- true = nur normale Spieler (nicht Justiz/Admin)
      nurJustiz  = false,   -- true = nur Justiz und Admin
      nurAdmin   = false,   -- true = nur Admin
      erlaubteJobs = {},    -- Leer = alle Jobs erlaubt. Alternativ: { "doj", "admin" }
    },

    -- PED (NPC am Standort)
    ped = {
      aktiv    = true,
      modell   = "s_m_y_cop_01",            -- GTA-Modellname des NPCs
      scenario = "WORLD_HUMAN_CLIPBOARD",   -- Animation des NPCs
      unverwundbar    = true,
      eingefroren     = true,
      blockiereEvents = true,
    },

    -- Marker (farbiger Kreis am Boden)
    marker = {
      aktiv   = true,
      typ     = 2,
      groesse = vector3(0.3, 0.3, 0.3),
      farbe   = { r = 0, g = 120, b = 255, a = 160 },  -- Blau, halbtransparent
    },

    -- Blip (Punkt auf der Karte)
    blip = {
      aktiv  = true,
      sprite = 525,
      farbe  = 3,
      scale  = 0.8,
      name   = "Bürgerportal",
    },
  }
}
```

### Koordinaten herausfinden

Um die Koordinaten herauszufinden, gehe im Spiel zum gewünschten Ort und nutze einen Koordinaten-Befehl (z.B. `/coords` falls auf deinem Server installiert). Die Ausgabe gibt dir die X, Y, Z Werte.

### Interner Justiz-Standort (nur für doj/admin)

```lua
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
    nurJustiz    = true,                  -- Nur Justiz und Admin
    erlaubteJobs = { "doj", "admin" },
  },

  ped    = { aktiv = false },             -- Kein NPC
  marker = { aktiv = true, typ = 1, groesse = vector3(0.5, 0.5, 0.5), farbe = { r = 255, g = 165, b = 0, a = 180 } },
  blip   = { aktiv = false },             -- Kein Karten-Punkt (intern = nicht sichtbar)
}
```

---

## 9. Schritt 7 – Berechtigungen (Wer darf was?)

Das Berechtigungssystem legt fest, welche Aktionen Bürger, Justiz und Admins durchführen dürfen.

### Einfaches System (Config.Rechte)

Das einfache System gibt es für schnelle Standard-Einstellungen:

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
        erlauben = { "SYSTEM_OEFFNEN", "JUSTIZ_OEFFNEN", "KATEGORIE_ANSEHEN", "ANTRAG_EINGANG_ANSEHEN" }
      },
      admin = { job = "admin", mindestGrad = 0, erlauben = { "*" } }  -- * = alles erlaubt
    }
  }
}
```

### Feingranulares System (Config.Permissions)

Für präzisere Berechtigungen gibt es `Config.Permissions`. Hier kannst du für jede Aktion festlegen, wer sie darf.

**Wichtige Aktions-Schlüssel:**

| Schlüssel | Bedeutung |
|---|---|
| `system.open` | Portal öffnen |
| `submissions.create` | Antrag einreichen |
| `submissions.view_own` | Eigene Anträge sehen |
| `submissions.view_inbox` | Eingangs-Queue sehen (Justiz) |
| `submissions.view_all` | Alle Anträge sehen (Leitung) |
| `submissions.approve` | Antrag genehmigen |
| `submissions.reject` | Antrag ablehnen |
| `submissions.archive` | Antrag archivieren |
| `submissions.assign` | Antrag einem Mitarbeiter zuweisen |
| `notes.internal.write` | Interne Notizen schreiben |
| `workflow.lock.override` | Bearbeiter-Sperre aufheben (Leitungsebene) |
| `workflow.sla.pause` | Frist pausieren (Leitungsebene) |

### Berechtigungen für eine Kategorie überschreiben

Du kannst für eine bestimmte Kategorie abweichende Regeln setzen:

```lua
Config.Kategorien.Liste["general"].permissions = {
  justiz = {
    grade = { min = 2 },   -- Nur Ränge 2 und höher
    allow = {
      "submissions.archive",
      "submissions.assign",
      "submissions.set_priority",
      "notes.internal.write",
    },
    deny = {},
  },
}
```

---

## 10. Schritt 8 – Job-Grade-Berechtigungen (JobSettings)

Mit `Config.JobSettings` legst du fest, welche **Ränge** eines Jobs welche zusätzlichen Rechte haben.

```lua
Config.JobSettings = {
  Jobs = {
    ["doj"] = {
      anzeigeName        = "Justiz (DoJ)",
      globalDefaultRolle = "justiz",
      grades = {
        { grade = 0, name = "Mitarbeiter"           },
        { grade = 1, name = "Senior Mitarbeiter"    },
        { grade = 2, name = "Leitender Mitarbeiter" },
        { grade = 3, name = "Abteilungsleiter"      },
      },
      gradPermissions = {
        -- Ab Rang 2: Erweiterte Rechte
        [2] = {
          allow = {
            "workflow.lock.override",
            "workflow.sla.pause",
            "submissions.view_all",
            "submissions.archive",
            "submissions.assign",
            "submissions.set_priority",
            "notes.internal.write",
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

### Wie lese ich das?

- `grades` listet alle Ränge des Jobs auf – Rang 0 ist der niedrigste.
- `gradPermissions` legt fest, welche Aktionen ab einem bestimmten Rang freigeschaltet werden.
- `[2]` bedeutet: Ab Rang 2 gelten diese Regeln (und alle höheren Ränge erben sie ebenfalls).

> **Tipp:** Diese Einstellungen können auch über das Admin-Panel im Spiel vorgenommen werden (JobSettings-Tab). Änderungen dort werden in `data/admin_overrides.json` gespeichert und überschreiben die `config.lua`.

---

## 11. Schritt 9 – Kategorien und Formulare

### Kategorien

Kategorien sind wie **Ordner** für Anträge. Zum Beispiel „Allgemein", „Gewerbe", „Fahrzeuge" etc.

```lua
Config.Kategorien.Liste["general"] = {
  id           = "general",
  name         = "Allgemein",
  beschreibung = "Allgemeine Anträge an das Justizzentrum",
  icon         = "file",
  sortierung   = 1,    -- Reihenfolge in der Liste (1 = ganz oben)
  aktiv        = true,

  fuerBuergerSichtbar = true,   -- Bürger sehen diese Kategorie
  nurIntern           = false,  -- false = auch für Bürger sichtbar

  standardPrioritaet   = "normal",
  standardFristStunden = 72,    -- Standard-SLA: 72 Stunden

  workflow = {
    sla_hours = 48,             -- SLA für diese Kategorie: 48 Stunden
    pause_sla_in_statuses = { "question_open", "waiting_for_documents" },
    -- Wenn eine Rückfrage offen ist, wird die Frist pausiert
  },
}
```

### Formulare

Formulare sind die eigentlichen Antragsformulare innerhalb einer Kategorie.

```lua
Config.Formulare.Liste["gewerbe_anmeldung"] = {
  id                  = "gewerbe_anmeldung",
  titel               = "Gewerbeanmeldung",
  beschreibung        = "Antrag auf Anmeldung eines Gewerbes",
  kategorieId         = "general",    -- Muss einer vorhandenen Kategorie-ID entsprechen

  aktiv               = true,
  fuerBuergerSichtbar = true,

  gebuehren = {
    aktiv      = true,
    betrag     = 50,      -- 50 Euro
    erstattbar = true,
  },

  felder = {
    {
      id       = "betreff",
      label    = "Betreff",
      typ      = "shorttext",   -- Kurzer Text (1 Zeile)
      pflicht  = true,
      minLaenge = 3,
      maxLaenge = 60,
    },
    {
      id       = "beschreibung",
      label    = "Beschreibung",
      typ      = "longtext",    -- Langer Text (mehrere Zeilen)
      pflicht  = true,
      minLaenge = 10,
      maxLaenge = 2000,
    },
  },
}
```

### Unterstützte Feld-Typen

| Typ | Beschreibung |
|---|---|
| `shorttext` | Kurzer Text (eine Zeile) |
| `longtext` | Langer Text (mehrzeilig) |
| `number` | Zahl |
| `amount` | Geldbetrag in Euro |
| `date` | Datum |
| `time` | Uhrzeit |
| `select` | Dropdown (eine Auswahl) |
| `multiselect` | Dropdown (mehrere Auswahlen) |
| `checkbox` | Ja/Nein-Haken |
| `url` | Internetadresse |
| `license_plate` | Fahrzeugkennzeichen |

---

## 12. Schritt 10 – AntiSpam aktivieren

Der AntiSpam-Schutz verhindert, dass Spieler das System mit Spam-Anträgen überfluten.

> **Standard: Komplett ausgeschaltet** – du musst ihn explizit aktivieren.

### Minimale Aktivierung (empfohlen für den Anfang)

```lua
Config.AntiSpam = {
  Aktiviert                    = true,   -- Master-Schalter einschalten
  GlobalerCooldownSekunden     = 30,     -- 30 Sekunden Pause zwischen zwei Anträgen
  MaxOffeneAntraegeProSpieler  = 5,      -- Max. 5 gleichzeitig offene Anträge pro Spieler
  -- Alles andere bleibt ausgeschaltet
}
```

### Vollständiger Schutz

```lua
Config.AntiSpam = {
  Aktiviert                    = true,
  GlobalerCooldownSekunden     = 60,    -- 1 Minute Cooldown
  MaxOffeneAntraegeProSpieler  = 3,

  Blackliste = {
    Aktiviert = true,
    Woerter   = { "spam", "test123", "aaaaa" },  -- Groß-/Kleinschreibung egal
  },

  DuplikatPruefung = {
    Aktiviert      = true,
    FensterMinuten = 30,    -- Prüft ob derselbe Antrag in den letzten 30 Minuten schon gestellt wurde
  },

  Lockout = {
    Aktiviert       = true,
    MaxFehlversuche = 5,     -- Nach 5 Fehlversuchen wird der Spieler gesperrt
    DauerSekunden   = 300,   -- 5 Minuten Sperre
  },
}
```

---

## 13. Schritt 11 – Delegation / Vollmacht

Die Delegation ermöglicht es, Anträge **im Namen eines anderen Spielers** einzureichen.

> **Standard: Ausgeschaltet** – nur aktivieren wenn du dieses Feature benötigst.

### Aktivieren

```lua
Config.Module.Delegation = true       -- Feature-Flag einschalten

Config.Delegation = {
  Vollmacht = {
    Aktiviert = true,   -- Vollmacht-Prüfung aktivieren (optional)
  },
  MaxSuchergebnisse = 20,
}
```

### Delegationstypen

| Typ | Wer kann es nutzen? | Bedeutung |
|---|---|---|
| `submit_for_citizen` | Bürger, Justiz, Admin | Antrag für einen anderen Bürger einreichen |
| `submit_for_company` | Bürger, Justiz, Admin | Antrag für eine Firma einreichen |
| `justice_create_for_citizen` | Justiz, Admin | Justiz erstellt Antrag im Namen eines Bürgers |

---

## 14. Schritt 12 – Integrationen (Folgeaktionen)

Integrationen erlauben es, nach einem Statuswechsel automatisch andere Scripts zu benachrichtigen oder Datenbank-Flags zu setzen.

> **Standard: Komplett ausgeschaltet** – nur für Fortgeschrittene, die andere Scripts verknüpfen wollen.

### Aktivierung (zwei Schalter nötig!)

```lua
Config.Module.Integrationen    = true   -- Schritt 1: Feature-Flag
Config.Integrationen.Aktiviert = true   -- Schritt 2: Master-Switch
```

### Folgeaktion an einem Formular definieren

```lua
Config.Formulare.Liste["gewerbe_anmeldung"].integrationen = {
  on_approve = {
    {
      typ        = "set_db_flag",
      schluessel = "vorgang_abgeschlossen",
      wert       = "1",
    },
  },
  on_reject = {
    {
      typ   = "emit_server_event",
      event = "mein_script:gewerbe_abgelehnt",
      daten = { formular = "gewerbe_anmeldung" },
    },
  },
}
```

> **Wichtig:** Alle genutzten Events, Exports und DB-Flags müssen in der Whitelist in `Config.Integrationen.ErlaubteServerEvents` / `ErlaubteExports` / `ErlaubteDBFlags` eingetragen sein.

---

## 15. Was sind Overrides? (data/admin_overrides.json)

### Was ist das?

Die Datei `data/admin_overrides.json` speichert **Einstellungen, die über das Admin-Panel im Spiel gemacht wurden**. Diese Datei überschreibt bestimmte Werte aus der `config.lua` beim Serverstart.

Das bedeutet: Wenn du im Admin-Panel eine Einstellung änderst (z.B. ein Modul ausschalten oder JobSettings anpassen), wird diese Änderung in `admin_overrides.json` gespeichert – und bleibt auch nach einem Serverneustart erhalten.

### Warum ist das wichtig?

Stell dir vor, du hast in der `config.lua` `Config.Module.Delegation = false`. Dann gehst du im Admin-Panel und schaltest Delegation ein. Das Script speichert das in `admin_overrides.json`. Beim nächsten Serverstart gilt: **Override aus admin_overrides.json gewinnt** – Delegation ist eingeschaltet, obwohl in der `config.lua` false steht.

### Was kann in admin_overrides.json überschrieben werden?

- Feature-Flags (`Config.Module.*`)
- Job-Grade-Berechtigungen (`Config.JobSettings`)

### Wie setze ich eine Override zurück?

**Option A (empfohlen):** Im Admin-Panel die Einstellung zurücksetzen.

**Option B (manuell):** Öffne die Datei `data/admin_overrides.json` und lösche den entsprechenden Eintrag (oder lösche die ganze Datei – dann gelten wieder die Werte aus `config.lua`).

> **Vorsicht:** Die Datei `data/admin_overrides.json` liegt im `data/`-Ordner des Scripts. Wenn du die Datei löscht, verlierst du alle im Admin-Panel vorgenommenen Einstellungen.

---

## 16. Checkliste: Minimal lauffähige Konfiguration

Damit das Bürgerportal sofort läuft, musst du mindestens folgende Werte anpassen:

- [ ] **`Config.Kern.Jobs.Admin`** → Deinen Admin-Job-Namen eintragen (Standard: `"admin"`)
- [ ] **`Config.Kern.Jobs.Justiz`** → Deinen Justiz-Job-Namen eintragen (Standard: `"doj"`)
- [ ] **`Config.Kern.Admin.Job`** → Gleicher Wert wie `Jobs.Admin`
- [ ] **`Config.Kern.Justiz.Job`** → Gleicher Wert wie `Jobs.Justiz`
- [ ] **`Config.Zahlung.SocietyKonto`** → Namen deines Society-Kontos eintragen (z.B. `"society_justiz"`)
- [ ] **`server.cfg`** → Sicherstellen, dass `oxmysql` und `es_extended` **vor** `hm_buergerportal` gestartet werden

Optional aber empfohlen:
- [ ] Mindestens eine Discord-Webhook-URL eintragen
- [ ] `Config.AntiSpam.Aktiviert = true` setzen

---

## 17. Häufige Fehler und ihre Lösungen

### Portal öffnet sich nicht

**Mögliche Ursachen:**
- Falscher Job-Name in `Config.Kern.Jobs.Justiz` oder `Config.Kern.Justiz.Job`
- `oxmysql` oder `es_extended` starten nach `hm_buergerportal`

**Lösung:** Job-Namen prüfen, `server.cfg` Reihenfolge korrigieren.

### "Justiz sieht keine Anträge"

**Ursache:** Der Job-Name in der Config stimmt nicht mit dem tatsächlichen ESX-Job-Namen überein.

**Lösung:** `Config.Kern.Justiz.Job = "doj"` prüfen – muss exakt mit dem ESX-Job-Namen übereinstimmen (Groß-/Kleinschreibung beachten).

### Gebühren werden nicht abgezogen

**Mögliche Ursachen:**
1. Keine Banking-Bibliothek gestartet
2. `Config.Module.Gebuehren = false`
3. Falscher `SocietyKonto`-Name

**Lösung:**
1. Sicherstellen, dass `wasabi_banking`, `wasabi_billing`, `esx_banking` oder `esx_billing` in der `server.cfg` gestartet wird
2. `Config.Module.Gebuehren = true` setzen
3. `Config.Zahlung.SocietyKonto` auf den korrekten Namen setzen

### Keine Discord-Nachrichten

**Ursache:** Webhook-URL fehlt oder ist falsch.

**Lösung:** URL in `Config.Webhooks.Urls[...]` oder `Config.Webhooks.Routing.NachEvent[...]` korrekt eintragen.

### Tabellen fehlen in der Datenbank

**Ursache:** Migrationen haben nicht funktioniert.

**Lösung:** `Config.Datenbank.Migrationen.BeimStartAutomatisch = true` sicherstellen und Server neu starten. Im Log nach Fehlern suchen.

### Admin kann nicht auf Admin-UI zugreifen

**Ursache:** Falscher Job-Name oder falscher MinGrade.

**Lösung:** `Config.Kern.Admin.Job` und `Config.Kern.Admin.MinGrade` prüfen.

### Integrationen werden nicht ausgeführt

**Ursache:** Nur ein Feature-Flag gesetzt.

**Lösung:** Beide Flags setzen: `Config.Module.Integrationen = true` **und** `Config.Integrationen.Aktiviert = true`.

### AntiSpam greift nicht

**Ursache:** Master-Schalter vergessen.

**Lösung:** `Config.AntiSpam.Aktiviert = true` setzen.

---

> **Weiterführende Anleitungen:**
> - [Admin-UI Anleitung](ADMIN_UI_GUIDE_DE.md) – Einstellungen im Admin-Panel erklärt
> - [Beispiele & Troubleshooting](EXAMPLES_AND_TROUBLESHOOTING_DE.md) – Fertige Beispiel-Konfigurationen
> - [Vollständige Config-Referenz](CONFIG_REFERENCE.md) – Technische Referenz aller Optionen
