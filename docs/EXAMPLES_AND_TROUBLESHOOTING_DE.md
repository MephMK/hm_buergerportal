# Beispiele & Troubleshooting – hm_buergerportal

> **Für wen ist diese Anleitung?**  
> Für alle, die konkrete Beispiel-Konfigurationen suchen oder bestimmte Probleme lösen wollen.  
> Hier findest du fertige „Kopier-und-Einfügen"-Konfigurationen für verschiedene Szenarien.

---

## Inhaltsverzeichnis

1. [Beispiel-Setup A: Kleiner RP-Server (minimal)](#1-beispiel-setup-a-kleiner-rp-server-minimal)
2. [Beispiel-Setup B: Mittlerer RP-Server (empfohlen)](#2-beispiel-setup-b-mittlerer-rp-server-empfohlen)
3. [Beispiel-Setup C: Vollständiger Justiz-Server (alle Features)](#3-beispiel-setup-c-vollständiger-justiz-server-alle-features)
4. [Beispiel: Standort-Konfigurationen](#4-beispiel-standort-konfigurationen)
5. [Beispiel: Formular mit Gebühr](#5-beispiel-formular-mit-gebühr)
6. [Beispiel: Formular mit Integrationen (Folgeaktionen)](#6-beispiel-formular-mit-integrationen-folgeaktionen)
7. [Beispiel: Discord-Webhooks vollständig konfigurieren](#7-beispiel-discord-webhooks-vollständig-konfigurieren)
8. [Beispiel: AntiSpam konfigurieren](#8-beispiel-antispam-konfigurieren)
9. [Beispiel: Delegation (Vollmacht-System)](#9-beispiel-delegation-vollmacht-system)
10. [Troubleshooting: Portal startet nicht](#10-troubleshooting-portal-startet-nicht)
11. [Troubleshooting: Spieler-Probleme](#11-troubleshooting-spieler-probleme)
12. [Troubleshooting: Gebühren-Probleme](#12-troubleshooting-gebühren-probleme)
13. [Troubleshooting: Discord-Probleme](#13-troubleshooting-discord-probleme)
14. [Troubleshooting: Migrationen und Datenbank](#14-troubleshooting-migrationen-und-datenbank)
15. [Troubleshooting: Berechtigungsprobleme](#15-troubleshooting-berechtigungsprobleme)

---

## 1. Beispiel-Setup A: Kleiner RP-Server (minimal)

Dieses Setup ist für einen kleinen Server, der einfach loslegen will – ohne komplizierte Einstellungen.

**Voraussetzungen:**
- ESX Framework
- oxmysql
- Beliebige Banking-Ressource (wasabi_banking, esx_banking, etc.)
- Admin-Job: `admin`, Justiz-Job: `doj`

```lua
-- =============================================
-- Minimale Konfiguration – Kleiner RP-Server
-- =============================================

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
  Debugmodus = false,
  OeffentlicheIds = {
    Aktiviert = true,
    Prefix    = "HM-DOJ",
    Format    = "PREFIX-YYYY-MM-NNNNNN",
    Stellen   = 6,
  }
}

Config.Zahlung = {
  SocietyKonto = "society_justiz",  -- Anpassen!
  Modus        = "bei_entscheidung",
  Erstattungen = { aktiv = false },
  Befreiungen  = { aktiv = false },
}

Config.Module = {
  AdminUI          = true,
  Anhaenge         = true,
  Gebuehren        = true,
  Delegation       = false,
  Entwuerfe        = false,
  Exporte          = true,
  AuditHaertung    = true,
  Webhooks         = false,   -- Kein Discord → ausschalten
  Benachrichtigungen = true,
  Integrationen    = false,
}

-- Kein AntiSpam, keine Webhooks, kein Delegation
-- Alles andere bleibt auf Standardwerten
```

---

## 2. Beispiel-Setup B: Mittlerer RP-Server (empfohlen)

Dieses Setup eignet sich für die meisten Server. Es aktiviert Discord-Benachrichtigungen und AntiSpam.

```lua
-- =============================================
-- Empfohlene Konfiguration – Mittlerer RP-Server
-- =============================================

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
  Debugmodus = false,
  OeffentlicheIds = {
    Aktiviert = true,
    Prefix    = "HM-DOJ",
    Format    = "PREFIX-YYYY-MM-NNNNNN",
    Stellen   = 6,
  }
}

Config.Zahlung = {
  SocietyKonto = "society_justiz",  -- ← ANPASSEN
  Modus        = "bei_entscheidung",
  Erstattungen = {
    aktiv = true,
    regeln = {
      { status = "rejected",  prozent = 100 },
      { status = "withdrawn", prozent = 50  },
    },
  },
  Befreiungen = {
    aktiv  = false,
    rollen = {},
  },
}

Config.Module = {
  AdminUI          = true,
  Anhaenge         = true,
  Gebuehren        = true,
  Delegation       = false,
  Entwuerfe        = false,
  Exporte          = true,
  AuditHaertung    = true,
  Webhooks         = true,
  Benachrichtigungen = true,
  Integrationen    = false,
}

-- Discord-Webhooks (URLs anpassen!)
Config.Webhooks.Urls = {
  ["antrag_payments"]   = "https://discord.com/api/webhooks/DEINE_URL_HIER",
  ["antrag_escalation"] = "https://discord.com/api/webhooks/DEINE_URL_HIER",
  ["admin_ops"]         = "https://discord.com/api/webhooks/DEINE_URL_HIER",
  ["missbrauch"]        = nil,
}

-- Neue Anträge und Statuswechsel in separatem Channel
Config.Webhooks.Routing.NachEvent = {
  antrag_created        = "https://discord.com/api/webhooks/DEINE_URL_HIER",
  antrag_status_changed = "https://discord.com/api/webhooks/DEINE_URL_HIER",
}

-- Minimaler AntiSpam-Schutz
Config.AntiSpam = {
  Aktiviert                    = true,
  GlobalerCooldownSekunden     = 30,
  MaxOffeneAntraegeProSpieler  = 5,
}
```

---

## 3. Beispiel-Setup C: Vollständiger Justiz-Server (alle Features)

Dieses Setup nutzt alle verfügbaren Features des Bürgerportals.

```lua
-- =============================================
-- Vollständige Konfiguration – Justiz-Server
-- =============================================

Config.Kern = {
  Jobs = {
    Admin  = "admin",
    Justiz = "doj",
  },
  Admin  = { Job = "admin", MinGrade = 0 },
  Justiz = { Job = "doj" },
  Debugmodus = false,
  OeffentlicheIds = {
    Aktiviert = true,
    Prefix    = "HM-DOJ",
    Format    = "PREFIX-YYYY-MM-NNNNNN",
    Stellen   = 6,
  }
}

Config.Zahlung = {
  SocietyKonto = "society_justiz",  -- ← ANPASSEN
  Modus        = "bei_entscheidung",
  Erstattungen = {
    aktiv = true,
    regeln = {
      { status = "rejected",  prozent = 100 },
      { status = "withdrawn", prozent = 75  },
    },
  },
  Befreiungen = {
    aktiv  = true,
    rollen = { "richter", "staatsanwalt" },
  },
}

Config.Module = {
  AdminUI          = true,
  Anhaenge         = true,
  Gebuehren        = true,
  Delegation       = true,    -- Vollmacht-System aktiv
  Entwuerfe        = true,    -- Justiz-Entwürfe aktiv
  Exporte          = true,
  AuditHaertung    = true,
  Webhooks         = true,
  Benachrichtigungen = true,
  Integrationen    = true,    -- Folgeaktionen aktiv
}

-- Vollständige Webhook-Konfiguration
Config.Webhooks.Urls = {
  ["antrag_payments"]   = "https://discord.com/api/webhooks/URL_ZAHLUNGEN",
  ["antrag_escalation"] = "https://discord.com/api/webhooks/URL_ESKALATION",
  ["admin_ops"]         = "https://discord.com/api/webhooks/URL_ADMIN",
  ["missbrauch"]        = "https://discord.com/api/webhooks/URL_MISSBRAUCH",
  ["integrationen"]     = "https://discord.com/api/webhooks/URL_INTEGRATIONEN",
}

Config.Webhooks.Routing.NachEvent = {
  antrag_created         = "https://discord.com/api/webhooks/URL_NEUE_ANTRAEGE",
  antrag_status_changed  = "https://discord.com/api/webhooks/URL_STATUS",
  antrag_question_asked  = "https://discord.com/api/webhooks/URL_RUECKFRAGEN",
  antrag_citizen_replied = "https://discord.com/api/webhooks/URL_ANTWORTEN",
}

-- Discord-Pings für kritische Ereignisse
Config.Webhooks.Pings = {
  Aktiviert = true,
  RolleId   = "123456789012345678",  -- ← Discord-Rollen-ID anpassen
  NurFuerEvents = {
    "abuse_triggered",
    "antrag_hartgeloescht",
    "admin_status_override",
  },
}

-- Vollständiger AntiSpam-Schutz
Config.AntiSpam = {
  Aktiviert                    = true,
  GlobalerCooldownSekunden     = 60,
  MaxOffeneAntraegeProSpieler  = 3,
  Blackliste       = { Aktiviert = true, Woerter = { "spam", "test123" } },
  DuplikatPruefung = { Aktiviert = true, FensterMinuten = 60 },
  Lockout          = { Aktiviert = true, MaxFehlversuche = 5, DauerSekunden = 300 },
}

-- Delegation / Vollmacht
Config.Delegation = {
  Vollmacht         = { Aktiviert = true },
  MaxSuchergebnisse = 20,
}

-- Integrationen (beide Flags!)
Config.Integrationen = {
  Aktiviert           = true,
  MaxAktionenProQueue = 20,
  MaxGesamtZeitMs     = 4000,
  ErlaubteAktionsTypen = {
    "emit_server_event",
    "call_export",
    "set_db_flag",
    "send_webhook_event",
  },
  ErlaubteServerEvents = {
    "mein_script:antrag_genehmigt",
  },
  ErlaubteDBFlags = {
    "vorgang_abgeschlossen",
  },
}
```

---

## 4. Beispiel: Standort-Konfigurationen

### Öffentlicher Bürger-Schalter (Bürgeramt)

```lua
Config.Standorte.Liste["buergeramt"] = {
  id    = "buergeramt",
  name  = "Bürgeramt",
  aktiv = true,

  koordinaten        = vector3(440.12, -981.92, 30.69),
  heading            = 90.0,
  interaktionsRadius = 2.0,
  sichtbarRadius     = 30.0,

  interaktion = {
    taste = 38,                       -- E-Taste
    text  = "[E] Bürgeramt öffnen",
  },

  -- Jeder Spieler darf hier
  zugriff = {
    nurBuerger = false,
    nurJustiz  = false,
    nurAdmin   = false,
    erlaubteJobs = {},
  },

  ped = {
    aktiv    = true,
    modell   = "s_m_y_cop_01",
    scenario = "WORLD_HUMAN_CLIPBOARD",
    unverwundbar    = true,
    eingefroren     = true,
    blockiereEvents = true,
  },

  marker = {
    aktiv   = true,
    typ     = 2,
    groesse = vector3(0.3, 0.3, 0.3),
    farbe   = { r = 0, g = 120, b = 255, a = 160 },  -- Blau
  },

  blip = {
    aktiv  = true,
    sprite = 525,
    farbe  = 3,
    scale  = 0.8,
    name   = "Bürgerportal",
  },
}
```

### Interne Justiz-Workstation (nur doj/admin)

```lua
Config.Standorte.Liste["doj_intern"] = {
  id    = "doj_intern",
  name  = "Justiz Workstation",
  aktiv = true,

  koordinaten        = vector3(462.31, -993.46, 30.69),
  heading            = 270.0,
  interaktionsRadius = 1.8,
  sichtbarRadius     = 15.0,

  interaktion = {
    text = "[E] Interne Workstation öffnen",
  },

  -- Nur für doj und admin
  zugriff = {
    nurBuerger = false,
    nurJustiz  = true,
    nurAdmin   = false,
    erlaubteJobs = { "doj", "admin" },
  },

  ped    = { aktiv = false },            -- Kein NPC
  marker = {
    aktiv   = true,
    typ     = 1,
    groesse = vector3(0.5, 0.5, 0.5),
    farbe   = { r = 255, g = 165, b = 0, a = 180 },  -- Orange
  },
  blip = { aktiv = false },              -- Kein Karten-Punkt
}
```

### Standort mit ox_target

```lua
Config.Standorte.InteraktionsModus = "ox_target"  -- Global auf ox_target umschalten

Config.Standorte.Liste["buergeramt_ox"] = {
  id    = "buergeramt_ox",
  name  = "Bürgeramt (ox_target)",
  aktiv = true,

  koordinaten        = vector3(440.12, -981.92, 30.69),
  heading            = 90.0,
  interaktionsRadius = 2.0,
  sichtbarRadius     = 30.0,

  interaktion = {
    modus = "ox_target",  -- Standort-spezifischer Override
    text  = "Portal öffnen",
  },

  zugriff = { nurBuerger = false, nurJustiz = false, nurAdmin = false, erlaubteJobs = {} },

  ped    = { aktiv = true, modell = "s_m_y_cop_01", scenario = "WORLD_HUMAN_CLIPBOARD",
             unverwundbar = true, eingefroren = true, blockiereEvents = true },
  marker = { aktiv = false },  -- ox_target braucht keinen Marker
  blip   = { aktiv = true, sprite = 525, farbe = 3, scale = 0.8, name = "Bürgerportal" },
}
```

---

## 5. Beispiel: Formular mit Gebühr

Ein typisches Formular für eine Gewerbeanmeldung mit einer Gebühr von 50€.

```lua
Config.Formulare.Liste["gewerbe_anmeldung"] = {
  id                  = "gewerbe_anmeldung",
  titel               = "Gewerbeanmeldung",
  interneBezeichnung  = "GEWERBE_ANMELDUNG",
  beschreibung        = "Antrag auf Anmeldung eines Gewerbes bei der Behörde.",
  kategorieId         = "gewerbe",       -- Muss einer vorhandenen Kategorie-ID entsprechen

  aktiv               = true,
  fuerBuergerSichtbar = true,

  buergerDuerfenEinreichen = true,
  nurJustizDarfErstellen   = false,

  -- Gebühr: 50€ bei Entscheidung, bei Ablehnung zurückerstatten
  gebuehren = {
    aktiv      = true,
    betrag     = 50,
    erstattbar = true,
  },

  cooldownSekunden    = 120,   -- 2 Minuten Cooldown zwischen Einreichungen
  maxOffenProSpieler  = 2,

  standardStatus     = "submitted",
  standardPrioritaet = "normal",

  fristen = { fristStunden = 72 },   -- 72 Stunden Bearbeitungsfrist

  felder = {
    {
      id          = "firmenname",
      label       = "Firmenname",
      beschreibung = "Der vollständige Name deines Unternehmens",
      typ         = "shorttext",
      pflicht     = true,
      minLaenge   = 3,
      maxLaenge   = 100,
      placeholder = "z.B. Mustermann GmbH",
      reihenfolge = 1,
      sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
    },
    {
      id          = "taetigkeitsbereich",
      label       = "Tätigkeitsbereich",
      beschreibung = "Was macht dein Unternehmen?",
      typ         = "longtext",
      pflicht     = true,
      minLaenge   = 20,
      maxLaenge   = 500,
      reihenfolge = 2,
      sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
    },
    {
      id          = "startdatum",
      label       = "Gewünschtes Startdatum",
      typ         = "date",
      pflicht     = true,
      reihenfolge = 3,
      sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
    },
    {
      id          = "agb_akzeptiert",
      label       = "Ich akzeptiere die Nutzungsbedingungen",
      typ         = "checkbox",
      pflicht     = true,
      reihenfolge = 4,
      sichtbarkeit = { buerger = true, justiz = true, nurIntern = false },
    },
  },
}
```

---

## 6. Beispiel: Formular mit Integrationen (Folgeaktionen)

Dieses Beispiel zeigt, wie nach einer Genehmigung automatisch ein anderes Script benachrichtigt wird.

> **Voraussetzung:** `Config.Module.Integrationen = true` und `Config.Integrationen.Aktiviert = true`

```lua
-- Zuerst die Whitelist in Config.Integrationen befüllen:
Config.Integrationen = {
  Aktiviert           = true,
  MaxAktionenProQueue = 20,
  MaxGesamtZeitMs     = 4000,
  ErlaubteAktionsTypen = {
    "emit_server_event",
    "set_db_flag",
    "send_webhook_event",
  },
  ErlaubteServerEvents = {
    "mein_firmen_script:gewerbe_genehmigt",
    "mein_firmen_script:gewerbe_abgelehnt",
  },
  ErlaubteDBFlags = {
    "gewerbe_aktiv",
    "gewerbe_gesperrt",
  },
}

-- Dann die Folgeaktionen am Formular definieren:
Config.Formulare.Liste["gewerbe_anmeldung"].integrationen = {
  -- Bei Genehmigung:
  on_approve = {
    -- 1. DB-Flag setzen (andere Scripts können das abfragen)
    {
      typ        = "set_db_flag",
      schluessel = "gewerbe_aktiv",   -- muss in ErlaubteDBFlags stehen
      wert       = "1",
    },
    -- 2. Anderen Script benachrichtigen
    {
      typ   = "emit_server_event",
      event = "mein_firmen_script:gewerbe_genehmigt",  -- muss in ErlaubteServerEvents stehen
      daten = { formular = "gewerbe_anmeldung" },
    },
  },

  -- Bei Ablehnung:
  on_reject = {
    {
      typ        = "set_db_flag",
      schluessel = "gewerbe_gesperrt",
      wert       = "1",
    },
    {
      typ   = "emit_server_event",
      event = "mein_firmen_script:gewerbe_abgelehnt",
      daten = { formular = "gewerbe_anmeldung" },
    },
  },

  -- Bei Rückfrage (Unterlagen fehlen):
  on_return  = {},

  -- Bei Archivierung:
  on_archive = {},
}
```

---

## 7. Beispiel: Discord-Webhooks vollständig konfigurieren

Dieses Beispiel zeigt, wie du alle Webhook-Kanäle für verschiedene Discord-Channels einrichtest.

```lua
-- Dedizierte Kanäle für System-Events
Config.Webhooks.Urls = {
  ["antrag_payments"]   = "https://discord.com/api/webhooks/111/TOKEN_ZAHLUNGEN",
  ["antrag_escalation"] = "https://discord.com/api/webhooks/222/TOKEN_ESKALATION",
  ["admin_ops"]         = "https://discord.com/api/webhooks/333/TOKEN_ADMIN_OPS",
  ["missbrauch"]        = "https://discord.com/api/webhooks/444/TOKEN_MISSBRAUCH",
  ["integrationen"]     = "https://discord.com/api/webhooks/555/TOKEN_INTEGRATIONEN",
  ["pdf_export"]        = nil,  -- Kein Webhook für PDF-Export
}

-- Event-basiertes Routing
Config.Webhooks.Routing = {
  Fallback = "https://discord.com/api/webhooks/999/TOKEN_FALLBACK",  -- Alles andere hier

  NachEvent = {
    antrag_created         = "https://discord.com/api/webhooks/101/TOKEN_NEUE_ANTRAEGE",
    antrag_status_changed  = "https://discord.com/api/webhooks/102/TOKEN_STATUS",
    antrag_question_asked  = "https://discord.com/api/webhooks/103/TOKEN_RUECKFRAGEN",
    antrag_citizen_replied = "https://discord.com/api/webhooks/104/TOKEN_ANTWORTEN",
  },

  -- Gewerbe-Anträge in eigenen Channel
  NachKategorie = {
    ["gewerbe"] = "https://discord.com/api/webhooks/201/TOKEN_GEWERBE",
  },

  -- Spezielles Formular in eigenen Channel
  NachFormular = {
    ["gewerbe_anmeldung"] = "https://discord.com/api/webhooks/301/TOKEN_GEWERBE_ANMELDUNG",
  },
}

-- Discord-Pings bei kritischen Ereignissen
Config.Webhooks.Pings = {
  Aktiviert = true,
  RolleId   = "123456789012345678",  -- ← Discord-Rollen-ID (rechtsklick auf Rolle → ID kopieren)
  NurFuerEvents = {
    "abuse_triggered",
    "antrag_hartgeloescht",
    "admin_status_override",
  },
}

-- Webhook-Absender-Name
Config.Webhooks.Identitaet = {
  Benutzername = "Bürgerportal | Server-Name",
  AvatarUrl    = nil,
  Footer       = "Dein Server-Name",
}

-- Retry-Warteschlange (Standard-Werte sind gut)
Config.Webhooks.Warteschlange = {
  Aktiviert = true,
  Wiederholung = {
    Aktiviert   = true,
    MaxVersuche = 5,
  },
}
```

---

## 8. Beispiel: AntiSpam konfigurieren

### Minimaler Schutz (empfohlen für den Start)

```lua
Config.AntiSpam = {
  Aktiviert                    = true,
  GlobalerCooldownSekunden     = 30,    -- 30 Sekunden zwischen Anträgen
  MaxOffeneAntraegeProSpieler  = 5,     -- Max. 5 gleichzeitig offene Anträge
}
```

### Mittlerer Schutz

```lua
Config.AntiSpam = {
  Aktiviert                    = true,
  GlobalerCooldownSekunden     = 60,
  MaxOffeneAntraegeProSpieler  = 3,
  MinTextLaenge                = 10,
  MaxTextLaenge                = 1500,
  Blackliste = {
    Aktiviert = true,
    Woerter   = { "spam", "test123", "asdf", "1111" },
  },
  DuplikatPruefung = {
    Aktiviert      = true,
    FensterMinuten = 30,
  },
}
```

### Vollständiger Schutz (maximale Sicherheit)

```lua
Config.AntiSpam = {
  Aktiviert                    = true,
  GlobalerCooldownSekunden     = 120,   -- 2 Minuten Cooldown
  MaxOffeneAntraegeProSpieler  = 2,
  MinTextLaenge                = 20,
  MaxTextLaenge                = 1000,
  Blackliste = {
    Aktiviert = true,
    Woerter   = { "spam", "test123", "asdf" },
  },
  DuplikatPruefung = {
    Aktiviert      = true,
    FensterMinuten = 60,
  },
  RateLimit = {
    Aktiviert   = true,
    MaxAktionen = 10,
    ProSekunden = 60,
  },
  Lockout = {
    Aktiviert       = true,
    MaxFehlversuche = 3,
    DauerSekunden   = 600,  -- 10 Minuten Sperre
  },
}
```

---

## 9. Beispiel: Delegation (Vollmacht-System)

Das Vollmacht-System erlaubt Anträge im Namen anderer Spieler.

```lua
-- Schritt 1: Modul aktivieren
Config.Module.Delegation = true

-- Schritt 2: Delegation konfigurieren
Config.Delegation = {
  Vollmacht = {
    Aktiviert = true,   -- Vollmacht-Prüfung aktivieren
  },
  MaxSuchergebnisse = 20,
  ErlaubteTypen = {
    buerger = { "submit_for_citizen", "submit_for_company" },
    justiz  = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
    admin   = { "submit_for_citizen", "submit_for_company", "justice_create_for_citizen" },
  },
}
```

**Was die Delegationstypen bedeuten:**

| Typ | Wer nutzt es | Wann |
|---|---|---|
| `submit_for_citizen` | Anwalt für Mandanten | Bürger möchte einen anderen Bürger vertreten |
| `submit_for_company` | Firmenvertreter | Jemand reicht im Namen einer Firma ein |
| `justice_create_for_citizen` | Justiz-Mitarbeiter | Behördenmitarbeiter erstellt Antrag für Bürger |

---

## 10. Troubleshooting: Portal startet nicht

### Problem: `attempt to index a nil value (global 'HM_BP')`

**Bedeutung:** Das Script konnte seine Kern-Bibliotheken nicht laden, weil entweder ESX oder oxmysql noch nicht bereit war.

**Lösung:**
1. Öffne `server.cfg`
2. Stelle sicher, dass die Reihenfolge so ist:
```cfg
ensure oxmysql
ensure es_extended
# ... andere Ressourcen ...
ensure hm_buergerportal
```
3. Server neu starten

### Problem: Script lädt, aber das Portal öffnet sich nicht

**Mögliche Ursachen und Lösungen:**

| Mögliche Ursache | Prüfen | Lösung |
|---|---|---|
| Falscher Job-Name | `Config.Kern.Justiz.Job` und `Config.Kern.Jobs.Justiz` | Auf exakten ESX-Job-Namen setzen |
| AdminUI deaktiviert | `Config.Module.AdminUI` | Auf `true` setzen |
| Standort nicht aktiv | `Config.Standorte.Liste["dein_standort"].aktiv` | Auf `true` setzen |

### Problem: Im Server-Log erscheinen keine Migrations-Zeilen

**Bedeutung:** Migrationen wurden nicht ausgeführt.

**Lösung:**
1. In `config.lua` prüfen: `Config.Datenbank.Migrationen.BeimStartAutomatisch = true`
2. Server neu starten und Log beobachten

---

## 11. Troubleshooting: Spieler-Probleme

### Justiz sieht keine Anträge

**Ursache:** Der Job-Name in der Config stimmt nicht mit dem ESX-Job überein.

**Diagnose:** Schreibe in die Konsole oder logge (wenn `Debugmodus = true`): Welchen Job-Namen hat der Spieler in ESX?

**Lösung:**
```lua
-- Prüfe und gleiche an:
Config.Kern.Justiz.Job  = "doj"    -- Muss EXAKT dem ESX-Job-Namen entsprechen
Config.Kern.Jobs.Justiz = "doj"    -- Beide auf denselben Wert
```

> **Tipp:** Groß-/Kleinschreibung beachten! `"DOJ"` und `"doj"` sind unterschiedlich.

### Bürger kann keinen Antrag einreichen

**Mögliche Ursachen:**
1. Das gewünschte Formular hat `fuerBuergerSichtbar = false`
2. Das Formular hat `buergerDuerfenEinreichen = false`
3. AntiSpam blockiert den Spieler (zu viele offene Anträge)
4. Der Spieler hat kein `submissions.create` Recht

**Lösung:** Formular-Einstellungen prüfen, AntiSpam-Logs in Discord prüfen.

### Spieler bekommt keine Ingame-Benachrichtigungen

**Ursache:** `Config.Module.Benachrichtigungen = false` oder ESX-Benachrichtigungen nicht aktiv.

**Lösung:**
```lua
Config.Module.Benachrichtigungen = true
Config.Benachrichtigungen.Ingame.Aktiviert = true
Config.Benachrichtigungen.Ingame.Anbieter  = "esx"
```

### Portal hat keine Übersetzungen / Text fehlt

**Ursache:** Sprach-Datei nicht gefunden (sehr selten).

**Lösung:** `Config.Kern.Sprache = "de"` prüfen – aktuell ist nur Deutsch unterstützt.

---

## 12. Troubleshooting: Gebühren-Probleme

### Gebühren werden nicht abgezogen

**Diagnose-Schritte:**

1. **Banking-Bibliothek gestartet?**
   ```cfg
   # server.cfg - eine dieser Zeilen muss vorhanden sein:
   ensure wasabi_banking
   # oder:
   ensure wasabi_billing
   # oder:
   ensure esx_banking
   # oder:
   ensure esx_billing
   ```

2. **Modul aktiviert?**
   ```lua
   Config.Module.Gebuehren = true
   ```

3. **Formular hat Gebühr konfiguriert?**
   ```lua
   Config.Formulare.Liste["dein_formular"].gebuehren = {
     aktiv  = true,
     betrag = 50,
   }
   ```

4. **Society-Konto korrekt?**
   ```lua
   Config.Zahlung.SocietyKonto = "society_justiz"  -- Exakten Namen prüfen
   ```

### Gebühr abgezogen, aber nicht auf Society-Konto eingegangen

**Ursache:** Falscher `SocietyKonto`-Name.

**Lösung:** Den exakten Namen deines Society-Kontos aus deiner Banking-Ressource verwenden.

**Wo finde ich den Namen?**
- `wasabi_banking`: Schau in die `config.lua` oder Datenbank der Banking-Ressource
- `esx_billing`: Standard ist `society_police`, `society_justiz` oder ähnlich

### Erstattungen funktionieren nicht

**Prüfe:**
```lua
Config.Zahlung.Erstattungen = {
  aktiv = true,   -- ← Muss true sein!
  regeln = {
    { status = "rejected", prozent = 100 },
  },
}

-- Und am Formular:
Config.Formulare.Liste["dein_formular"].gebuehren.erstattbar = true
```

### Gebühren-Webhook kommt nicht an

**Prüfe:**
```lua
Config.Webhooks.Urls["antrag_payments"] = "https://discord.com/api/webhooks/..."
Config.Module.Webhooks = true
```

---

## 13. Troubleshooting: Discord-Probleme

### Keine Discord-Nachrichten trotz konfigurierter URL

**Diagnose:**

1. Ist die URL korrekt? Sie muss mit `https://discord.com/api/webhooks/` beginnen.
2. Ist `Config.Module.Webhooks = true`?
3. Existiert der Discord-Channel noch? (Webhook wird ungültig wenn Channel gelöscht wird)

**Test:** Im Admin-Panel → Webhooks-Tab → Test-Button klicken.

### Nachrichten kommen in den falschen Channel

**Ursache:** Routing-Priorität nicht beachtet.

**Merke:** Das System prüft in dieser Reihenfolge:
1. `NachFormular[formularId]` (höchste Priorität)
2. `NachKategorie[kategorieId]`
3. `NachEvent[event]`
4. `Fallback`

Wenn du einen Formular-spezifischen Webhook gesetzt hast, geht diese Nachricht immer dorthin – egal was du bei `NachEvent` einträgst.

### Webhook-Nachrichten mit Fehlern im Log

**Typischer Fehler:** `HTTP 401` oder `HTTP 404`

- `401`: Webhook nicht autorisiert → URL neu erstellen
- `404`: Webhook nicht mehr vorhanden → Channel oder Webhook wurde gelöscht

**Lösung:** Neuen Webhook in Discord erstellen und URL aktualisieren.

### Discord-Pings funktionieren nicht

**Prüfe:**
```lua
Config.Webhooks.Pings.Aktiviert = true      -- Muss true sein
Config.Webhooks.Pings.RolleId   = "1234..."  -- Discord-Rollen-ID (als String, nicht Zahl!)
```

> **Tipp:** Rollen-ID in Discord: Einstellungen → Servereinstellungen → Rollen → rechtsklick auf Rolle → „ID kopieren"

---

## 14. Troubleshooting: Migrationen und Datenbank

### Tabellen fehlen / `hm_bp_submissions not found`

**Ursache:** Migrationen wurden nicht ausgeführt.

**Lösung:**
1. `Config.Datenbank.Migrationen.BeimStartAutomatisch = true` prüfen
2. Server neu starten
3. Log beobachten: Du solltest `Migration angewendet: v1_core_tables` sehen

### Manche neuen Features funktionieren nicht

**Ursache:** Neuere Migrationen wurden nicht ausgeführt (passiert wenn Script aktualisiert wurde aber Migrationen noch nicht gelaufen sind).

**Lösung:** Server neu starten – beim Start werden automatisch fehlende Migrationen nachgeholt.

**Überprüfen per Datenbank:**
```sql
SELECT * FROM hm_bp_migrations ORDER BY applied_at DESC;
```
Du solltest Einträge von `v1_core_tables` bis `v19_abuse_lockout_log` sehen.

### oxmysql-Fehler beim Start

**Typische Fehlermeldung:** `[oxmysql] Connection refused` oder ähnlich

**Ursache:** MySQL/MariaDB-Verbindung nicht hergestellt.

**Lösung:**
1. Prüfe ob MySQL/MariaDB läuft
2. Prüfe die Verbindungsdaten in der FiveM-Server-Config (`set mysql_connection_string "..."`)
3. Stelle sicher, dass `oxmysql` korrekt in `server.cfg` eingetragen ist

---

## 15. Troubleshooting: Berechtigungsprobleme

### Justiz-Mitarbeiter kann keine Statusänderungen vornehmen

**Ursache:** Rang ist zu niedrig oder Berechtigung fehlt.

**Diagnose:** Welchen Rang hat der Spieler im doj-Job?

**Lösung:**
1. Im Admin-Panel → JobSettings → `doj` → Rang des Spielers
2. Sicherstellen, dass `submissions.approve` oder `submissions.reject` erlaubt ist

### Bestimmte Aktionen sind für alle gesperrt

**Mögliche Ursache:** Kategorie-Override zu restriktiv.

**Prüfe:**
```lua
Config.Kategorien.Liste["general"].permissions = {
  justiz = {
    grade = { min = 0 },   -- min = 0 → alle Ränge
    allow = { "submissions.approve", "submissions.reject" },
  },
}
```

### Admin-Job hat keinen Vollzugriff

**Das sollte nicht passieren** – der Admin-Job hat immer Vollzugriff (Kurzschluss in der Berechtigungsprüfung).

**Wenn es trotzdem nicht funktioniert:** Prüfe, ob der Admin-Job-Name korrekt ist:
```lua
Config.Kern.Admin.Job  = "admin"  -- Exakt wie in ESX
Config.Kern.Jobs.Admin = "admin"  -- Beide auf denselben Wert
```

### Formular-Editor-Tab fehlt im Admin-Panel

**Ursache:** Keine `form_editor.*`-Berechtigung.

**Lösung:**
1. Admin-Panel → JobSettings → `admin` → Rang 0
2. `form_editor.publish` und `form_editor.archive` erlauben
3. Oder in `config.lua`:
```lua
Config.FormularEditor = {
  Aktiviert            = true,
  AdminHatImmerZugriff = true,  -- ← Immer true für Admin-Job
}
```

---

> **Weiterführende Anleitungen:**
> - [Konfigurationsanleitung](CONFIG_GUIDE_DE.md) – config.lua Schritt für Schritt erklärt
> - [Admin-UI Anleitung](ADMIN_UI_GUIDE_DE.md) – Admin-Panel erklärt
> - [Vollständige Config-Referenz](CONFIG_REFERENCE.md) – Technische Referenz aller Optionen
