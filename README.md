# hm_buergerportal

Modulares Bürgerportal / Antragssystem für FiveM (ESX, oxmysql, NUI) – vollständig auf Deutsch.

**Version:** 0.7.0 · **Framework:** ESX 1.3.4+ · **Datenbank:** oxmysql

---

## Inhaltsverzeichnis

1. [Überblick & Module](#1-überblick--module)
2. [Abhängigkeiten](#2-abhängigkeiten)
3. [Installation & Einrichtung](#3-installation--einrichtung)
4. [server.cfg – Start-Reihenfolge](#4-servercfg--start-reihenfolge)
5. [Datenbank-Migrationen](#5-datenbank-migrationen)
6. [Erste Konfiguration (Quickstart)](#6-erste-konfiguration-quickstart)
7. [Webhooks & Discord-Integration](#7-webhooks--discord-integration)
8. [Sicherheit & Datenschutz](#8-sicherheit--datenschutz)
9. [Module & Feature-Flags](#9-module--feature-flags)
10. [Standorte konfigurieren](#10-standorte-konfigurieren)
11. [Häufige Fehler & Lösungen](#11-häufige-fehler--lösungen)
12. [Vollständige Config-Referenz](#12-vollständige-config-referenz)

---

## 1. Überblick & Module

`hm_buergerportal` ist ein vollständig auf Deutsch gehaltenes Antrags- und Verwaltungssystem für FiveM-ESX-Server. Bürger können Anträge stellen, Justiz/Behörden bearbeiten diese, Admins verwalten das gesamte System.

| Modul | Standard | Beschreibung |
|---|---|---|
| **Kern** | ✅ ON | Anträge einreichen, Status anzeigen, Nachrichten |
| **Webhooks** | ✅ ON | Discord-Benachrichtigungen (konfigurierbar) |
| **Gebühren** | ✅ ON | Gebühren bei Antragsentscheidung oder -einreichung |
| **Admin-UI** | ✅ ON | Adminbereich, Formular-Editor, Audit-Log |
| **Anhänge** | ✅ ON | Bild-Links an Anträge hängen (Imgur, Discord CDN) |
| **Exporte** | ✅ ON | CSV-/PDF-Export von Anträgen |
| **Audit-Härtung** | ✅ ON | Unveränderliche, korrelierte Audit-Logs |
| **Benachrichtigungen** | ✅ ON | Ingame-Benachrichtigungen an Spieler |
| **Delegation** | ❌ OFF | Im-Auftrag-Einreichung / Vollmacht-Prüfung |
| **Entwürfe** | ❌ OFF | Antrags-Entwürfe für Bürger |
| **Integrationen** | ❌ OFF | Folgeaktionen nach Statuswechsel (Actions Engine) |
| **AntiSpam** | ❌ OFF | Missbrauchsschutz (Cooldown, Blacklist, Lockout) |

> **Wichtig:** Module, die als „OFF" markiert sind, müssen in `Config.Module` explizit auf `true` gesetzt werden.  
> Die vollständige Config-Referenz mit allen Optionen findest du in [`docs/CONFIG_REFERENCE.md`](docs/CONFIG_REFERENCE.md).

### 📚 Dokumentation

| Dokument | Beschreibung |
|---|---|
| 📖 **[Konfigurationsanleitung (DE)](docs/CONFIG_GUIDE_DE.md)** | Schritt-für-Schritt Einrichtung der `config.lua` – auch ohne IT-Kenntnisse |
| 🖥️ **[Admin-UI Anleitung (DE)](docs/ADMIN_UI_GUIDE_DE.md)** | Alle Tabs und Funktionen des Admin-Panels erklärt |
| 💡 **[Beispiele & Troubleshooting (DE)](docs/EXAMPLES_AND_TROUBLESHOOTING_DE.md)** | Fertige Beispiel-Konfigurationen und Lösungen für häufige Probleme |
| 🔧 **[Vollständige Config-Referenz](docs/CONFIG_REFERENCE.md)** | Technische Referenz aller Konfigurations-Optionen |

---

## 2. Abhängigkeiten

### Pflicht

| Ressource | Version | Zweck |
|---|---|---|
| `oxmysql` | neueste | Datenbankanbindung (MySQL/MariaDB) |
| `es_extended` | 1.3.4+ | ESX-Framework (Spieler, Jobs, Identities) |

### Bezahlungs-Bibliothek (eine davon)

Das Gebührensystem prüft automatisch, welche Bibliothek verfügbar ist:

| Priorität | Ressource | Beschreibung |
|---|---|---|
| 1 (höchste) | `wasabi_banking` | Wasabi Advanced Banking |
| 2 | `wasabi_billing` | Wasabi Billing |
| 3 | `esx_banking` | ESX-Standard Banking |
| 4 (Fallback) | `esx_billing` | ESX-Standard Billing |

> Wenn keine Bibliothek erkannt wird, gibt das System beim Start eine Warnung aus und Gebühren können nicht abgebucht werden.

### Optional

| Ressource | Zweck |
|---|---|
| `ox_target` | Alternativer Interaktionsmodus für Standorte |

---

## 3. Installation & Einrichtung

### Schritt 1 – Dateien kopieren

Kopiere den gesamten Ordner `hm_buergerportal` in das `resources`-Verzeichnis deines FiveM-Servers:

```
resources/
  [hm]/
    hm_buergerportal/
      config.lua
      fxmanifest.lua
      client/
      server/
      shared/
      ui/
```

> Der Ordner `[hm]` ist eine optionale Gruppierung. Du kannst den Ordner auch direkt in `resources/` ablegen.

### Schritt 2 – Datenbank vorbereiten

Das Script legt alle Tabellen **automatisch** beim ersten Start über das Migrationssystem an.  
Du musst **keine SQL-Dateien manuell importieren**.

Voraussetzung: Eine funktionierende MySQL/MariaDB-Verbindung via `oxmysql`.

### Schritt 3 – Config anpassen

Öffne `config.lua` und passe mindestens folgende Werte an:

```lua
Config.Kern = {
  Jobs = {
    Admin  = "admin",   -- Job-Name deines Admin-Jobs
    Justiz = "doj",     -- Job-Name deines Justiz-/Behörden-Jobs
  },
  Justiz = {
    Job = "doj",        -- Muss mit Jobs.Justiz übereinstimmen
  },
}

Config.Zahlung = {
  SocietyKonto = "society_justiz",  -- Society-Konto für Gebühren-Einzahlungen
}
```

### Schritt 4 – server.cfg anpassen

Siehe Abschnitt [4. server.cfg – Start-Reihenfolge](#4-servercfg--start-reihenfolge).

### Schritt 5 – Server starten

Starte den Server. Im Server-Log solltest du sehen:

```
[hm_buergerportal] Migration angewendet: v1_core_tables
[hm_buergerportal] Migration angewendet: v2_monats_sequenzen
...
[hm_buergerportal] Migration angewendet: v19_abuse_lockout_log
[hm_buergerportal] Alle Migrationen erfolgreich abgeschlossen.
[hm_buergerportal] Bürgerportal gestartet (v0.7.0)
```

---

## 4. server.cfg – Start-Reihenfolge

Die Reihenfolge ist entscheidend. `oxmysql` und `es_extended` müssen **vor** `hm_buergerportal` gestartet sein.

```cfg
# ── Pflicht-Abhängigkeiten ──────────────────────────────────────────
ensure oxmysql
ensure es_extended

# ── Optionale Bezahlungs-Bibliothek (eine davon, je nach Server) ───
# ensure wasabi_banking
# ensure wasabi_billing
# ensure esx_banking
# ensure esx_billing

# ── Optional: ox_target (nur wenn InteraktionsModus = "ox_target") ─
# ensure ox_target

# ── Bürgerportal ────────────────────────────────────────────────────
ensure hm_buergerportal
```

> **Typischer Fehler:** `hm_buergerportal` startet vor `es_extended` → Spieler-Daten können nicht geladen werden.  
> **Lösung:** Stelle sicher, dass `ensure es_extended` in der `server.cfg` **oberhalb** von `ensure hm_buergerportal` steht.

---

## 5. Datenbank-Migrationen

### Wie Migrationen laufen

Das Migrationssystem läuft automatisch beim Serverstart (wenn `Config.Datenbank.Migrationen.BeimStartAutomatisch = true`).  
Jede Migration wird genau einmal ausgeführt – der Status wird in der Tabelle `hm_bp_migrations` gespeichert.

```lua
Config.Datenbank = {
  Adapter = "oxmysql",
  Migrationen = {
    Aktiviert = true,
    BeimStartAutomatisch = true,  -- Automatisch beim Start ausführen
  }
}
```

### Wie man prüft, ob Migrationen durchgelaufen sind

**Option A – Server-Log:**  
Jede neue Migration gibt eine Zeile aus:
```
[hm_buergerportal] Migration angewendet: v17_zahlungs_ledger
```
Wenn keine neuen Zeilen erscheinen, sind alle Migrationen bereits angewendet worden.

**Option B – Datenbank direkt:**
```sql
SELECT * FROM hm_bp_migrations ORDER BY applied_at DESC;
```
Du solltest einen Eintrag pro Migrationsschritt sehen (v1 bis v19 bei vollständiger Installation).

### Übersicht aller Migrationsstufen

| Version | Tabellen / Änderungen | Seit |
|---|---|---|
| v1 | Kerntabellen (Kategorien, Formulare, Anträge, Standorte) | PR1 |
| v2 | Monats-Sequenzen (öffentliche IDs) | PR1 |
| v3 | Soft-Sperren | PR1 |
| v4–v6 | Staff-Verzeichnis, Formular-Editor, SLA-Spalten | PR1–PR2 |
| v7–v9 | Lock-Grund, Anhänge, DB-Indizes | PR1–PR2 |
| v10 | Audit-Härtung (request_id, actor_name) | PR2 |
| v11 | SLA-Erstbearbeitung | PR2 |
| v12 | Gebühren (fee_eur, zahlung_status, charged_at) | PR4 |
| v13 | SLA-Reminder/Eskalation Indizes | PR2 |
| v14 | Due-State, Status-History | PR2 |
| **v15** | **Staff-Entwürfe** (`hm_bp_staff_drafts`) | **PR2** |
| **v16** | **Delegation/Vollmacht** (actor_*-Spalten, `hm_bp_vollmachten`) | **PR3** |
| **v17** | **Zahlungs-Ledger** (`hm_bp_zahlungs_ledger`) | **PR4** |
| **v18** | **Integrations-Flags** (`hm_bp_integration_flags`) | **PR5** |
| **v19** | **Missbrauchsschutz-Log** (`hm_bp_abuse_log`) | **PR6** |

---

## 6. Erste Konfiguration (Quickstart)

### Minimal lauffähig

Das System läuft mit diesen **Mindestanpassungen** sofort:

```lua
-- config.lua – Mindest-Anpassungen

Config.Kern.Jobs.Admin  = "admin"   -- deinen Admin-Job-Namen eintragen
Config.Kern.Jobs.Justiz = "doj"     -- deinen Justiz-Job-Namen eintragen
Config.Kern.Justiz.Job  = "doj"     -- gleicher Wert wie Jobs.Justiz

Config.Zahlung.SocietyKonto = "society_justiz"  -- Society-Konto für Gebühren
```

Webhooks sind optional – ohne URLs werden keine Discord-Nachrichten gesendet.

### Empfohlen (für Produktivbetrieb)

```lua
-- Kern
Config.Kern.Jobs.Admin  = "admin"
Config.Kern.Jobs.Justiz = "doj"
Config.Kern.Justiz.Job  = "doj"
Config.Kern.Debugmodus  = false  -- nur für Entwicklung auf true setzen

-- Gebühren
Config.Zahlung.SocietyKonto = "society_justiz"
Config.Zahlung.Modus        = "bei_entscheidung"  -- oder "bei_einreichung"

-- Webhooks (URLs eintragen)
Config.Webhooks.Urls["antrag_payments"]   = "https://discord.com/api/webhooks/..."
Config.Webhooks.Urls["antrag_escalation"] = "https://discord.com/api/webhooks/..."
Config.Webhooks.Urls["admin_ops"]         = "https://discord.com/api/webhooks/..."
Config.Webhooks.Urls["missbrauch"]        = "https://discord.com/api/webhooks/..."
Config.Webhooks.Urls["integrationen"]     = "https://discord.com/api/webhooks/..."

-- AntiSpam aktivieren (optional, aber empfohlen)
Config.AntiSpam.Aktiviert = true
Config.AntiSpam.GlobalerCooldownSekunden = 30
Config.AntiSpam.MaxOffeneAntraegeProSpieler = 5

-- Missbrauchsschutz-Blacklist (optional)
Config.AntiSpam.Blackliste.Aktiviert = true
Config.AntiSpam.Blackliste.Woerter   = { "spam", "test123" }
```

### Produktiv (mit allen Funktionen)

```lua
-- Delegation aktivieren (Vollmacht-System)
Config.Module.Delegation    = true
Config.Delegation.Vollmacht = { Aktiviert = true }

-- Integrationen aktivieren (Folgeaktionen)
Config.Module.Integrationen     = true
Config.Integrationen.Aktiviert  = true

-- Erstattungen aktivieren
Config.Zahlung.Erstattungen = {
  aktiv = true,
  regeln = {
    { status = "rejected",  prozent = 100 },
    { status = "withdrawn", prozent = 50  },
  },
}

-- Gebührenbefreiungen
Config.Zahlung.Befreiungen = {
  aktiv    = true,
  rollen   = { "richter", "staatsanwalt" },
  formulare = { "interne_anfrage" },
}

-- Pings bei kritischen Events
Config.Webhooks.Pings.Aktiviert = true
Config.Webhooks.Pings.RolleId  = "123456789012345678"  -- Discord-Rollen-ID
```

---

## 7. Webhooks & Discord-Integration

### Verfügbare Webhook-Kanäle

Trage Discord-Webhook-URLs in `Config.Webhooks.Urls` ein:

| Schlüssel | Events | Priorität |
|---|---|---|
| `antrag_payments` | Gebühren abgezogen/erstattet/befreit/Fehler | Hoch |
| `antrag_escalation` | SLA-Überschreitung, Reminder | Mittel |
| `admin_ops` | Admin-Verschieben, Hard-Delete, Status-Override | Hoch |
| `missbrauch` | Spam-Block, Lockout, Blacklist-Treffer | Hoch |
| `integrationen` | Folgeaktions-Fehler/-Erfolg | Mittel |
| `pdf_export` | PDF-Export-Benachrichtigung | Niedrig |

### Event-basiertes Routing

Zusätzlich zu den dedizierten Kanälen kannst du für **jeden Event-Typ** eine eigene URL konfigurieren:

```lua
Config.Webhooks.Routing.NachEvent = {
  antrag_created          = "https://discord.com/api/webhooks/...",
  antrag_status_changed   = "https://discord.com/api/webhooks/...",
  antrag_question_asked   = "https://discord.com/api/webhooks/...",
  antrag_citizen_replied  = "https://discord.com/api/webhooks/...",
}
```

### Routing-Priorisierung

Das System prüft in dieser Reihenfolge – die **erste** passende URL gewinnt:

1. `Config.Webhooks.Routing.NachFormular[formularId]`
2. `Config.Webhooks.Routing.NachKategorie[kategorieId]`
3. `Config.Webhooks.Routing.NachEvent[event]`
4. `Config.Webhooks.Routing.Fallback`

### Dedizierte URLs (Priorität über Routing)

`Config.Webhooks.Urls` überschreibt das normale Routing für system-spezifische Events (Gebühren, Eskalation, Admin-Ops etc.).

### Discord-Pings

Optional kann das System `@<Rolle>` Mentions bei kritischen Events senden:

```lua
Config.Webhooks.Pings = {
  Aktiviert = true,
  RolleId   = "123456789012345678",  -- Discord-Rollen-ID (String)
  NurFuerEvents = {
    "abuse_triggered",
    "antrag_hartgeloescht",
    "admin_status_override",
  }
}
```

> **Standard: OFF** – explizit aktivieren.

---

## 8. Sicherheit & Datenschutz

### Keine Identifier in der UI

**Alle spieler-spezifischen Identifier** (Steam-Hex, License, Discord-ID usw.) werden **niemals** an die NUI (Browser) oder an Discord-Webhooks weitergegeben.

- Bürger sehen nur ihren eigenen Ingame-Namen und ihre öffentliche Antrags-ID (Format: `HM-DOJ-2024-000001`).
- Justiz und Admin sehen den Ingame-Namen des Antragstellers, aber keinen Identifier.
- Discord-Embeds enthalten ausschließlich: Spielername (Ingame), Charakter-Name und Aktenzeichen.

### Serverseitige Prüfungen

Alle sicherheitsrelevanten Operationen finden **ausschließlich auf dem Server** statt:

- Berechtigungsprüfung (Rolle, Job, Grade)
- Gebührenabbuchung und Einzahlung
- Statusübergangsprüfung (erlaubteFolgeStatus)
- Soft-Lock-Verwaltung
- Integrations-Whitelist (Server-Events, Exports, DB-Flags)
- Missbrauchsschutz (Cooldown, Duplikat, Blacklist, Lockout)

### Audit-Logs

Alle relevanten Aktionen werden in `hm_bp_audit_logs` gespeichert.  
Logs sind unveränderlich (kein UPDATE/DELETE durch die Anwendung).  
Retention: Standardmäßig 90 Tage (konfigurierbar via `Config.Audit.Retention.TageMax`).

---

## 9. Module & Feature-Flags

Alle Haupt-Module können in `Config.Module` einzeln ein-/ausgeschaltet werden:

```lua
Config.Module = {
  AdminUI          = true,   -- Admin-Bereich in der NUI
  Anhaenge         = true,   -- Bild-Anhänge (URL-Links)
  Gebuehren        = true,   -- Gebührensystem
  Delegation       = false,  -- Im-Auftrag-Einreichung (default OFF)
  Entwuerfe        = false,  -- Antrags-Entwürfe für Bürger (default OFF)
  Exporte          = true,   -- CSV/PDF-Export
  AuditHaertung    = true,   -- Erweiterte Audit-Sicherheit
  Webhooks         = true,   -- Discord-Webhooks
  Benachrichtigungen = true, -- Ingame-Benachrichtigungen
  Integrationen    = false,  -- Folgeaktionen-Engine (default OFF)
}
```

> **Achtung:** Das Gebührensystem benötigt zusätzlich eine konfigurierte Bezahlungs-Bibliothek (wasabi_banking/billing oder esx_banking/billing) und einen gültigen `SocietyKonto`-Wert.

---

## 10. Standorte konfigurieren

Die Standorte werden in `config.lua` unter `Config.Standorte` konfiguriert.

### Globaler Interaktionsmodus

```lua
Config.Standorte.InteraktionsModus = "taste"     -- Standard: Taste E
-- Config.Standorte.InteraktionsModus = "ox_target"  -- ox_target (erfordert ox_target resource)
```

### Pro-Standort-Optionen

```lua
Config.Standorte.Liste = {
  ["mein_standort"] = {
    id   = "mein_standort",    -- eindeutige ID (string)
    name = "Mein Standort",    -- Anzeigename im UI
    aktiv = true,              -- true/false

    koordinaten = vector3(x, y, z),
    heading     = 0.0,

    interaktionsRadius = 2.0,  -- Radius für Tastendruck / ox_target-Zone
    sichtbarRadius     = 30.0, -- Radius, ab dem Marker sichtbar wird

    -- Optionale Interaktions-Overrides (überschreibt globale Defaults)
    interaktion = {
      taste = 38,                      -- GTA-Control-Index (Standard: 38 = E)
      text  = "[E] Portal öffnen",     -- Hilfstext
      -- modus = "ox_target",          -- Standort-spezifischer Modus-Override
    },

    -- Zugriffsbeschränkungen (alle leer/false = alle Spieler erlaubt)
    zugriff = {
      nurBuerger         = false,  -- true → nur Bürger (nicht Justiz/Admin)
      nurJustiz          = false,  -- true → nur Justiz und Admin
      nurAdmin           = false,  -- true → nur Admin
      erlaubteRollen     = {},     -- z.B. { "buerger", "justiz" }
      erlaubteJobs       = {},     -- z.B. { "doj", "admin" }
      erlaubteKategorien = {},     -- leer = alle Kategorien sichtbar
      erlaubteFormulare  = {},     -- leer = alle Formulare sichtbar
    },

    -- Optionaler PED
    ped = {
      aktiv           = true,
      modell          = "s_m_y_cop_01",
      scenario        = "WORLD_HUMAN_CLIPBOARD",
      unverwundbar    = true,
      eingefroren     = true,
      blockiereEvents = true,
    },

    -- Optionaler Marker (DrawMarker)
    marker = {
      aktiv   = true,
      typ     = 2,
      groesse = vector3(0.3, 0.3, 0.3),
      farbe   = { r = 0, g = 120, b = 255, a = 160 },
    },

    -- Optionaler Blip auf der Karte
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

### Sicherheit

Die UI-Öffnung wird **serverseitig geprüft**. Der Client sendet nur eine Anfrage
(`hm_bp:location:ui_oeffnen_anfordern`). Der Server prüft Standort-Aktiv-Status,
Rollen, Jobs und globale Rechte. Nur bei Genehmigung antwortet der Server mit
`hm_bp:location:ui_oeffnen_antwort` und der Client öffnet dann die UI.

### ox_target

Wenn `Config.Standorte.InteraktionsModus = "ox_target"` gesetzt ist, registriert
`client/target_adapter.lua` automatisch Sphere-Zonen bzw. Ped-Interaktionen über
ox_target. Ist ox_target nicht installiert, werden alle Aufrufe ignoriert (keine
harte Abhängigkeit).

---

## 11. Häufige Fehler & Lösungen

| Fehlerbild | Ursache | Lösung |
|---|---|---|
| `attempt to index a nil value (global 'HM_BP')` | Script startet in falscher Reihenfolge | Prüfe `server.cfg`: `oxmysql` und `es_extended` müssen vor `hm_buergerportal` stehen |
| Tabellen fehlen / `hm_bp_submissions not found` | Migrationen nicht ausgeführt | `Config.Datenbank.Migrationen.BeimStartAutomatisch = true` sicherstellen und Server neu starten |
| Gebühr nicht abgezogen | Keine Bezahlungs-Lib erkannt | Stelle sicher, dass `wasabi_banking`, `wasabi_billing`, `esx_banking` oder `esx_billing` in `server.cfg` gestartet wird |
| Gebühr geht nicht auf Society-Konto | Falscher `SocietyKonto`-Name | `Config.Zahlung.SocietyKonto` auf den genauen Namen des Society-Kontos setzen |
| Keine Discord-Nachrichten | Webhook-URL fehlt | URL in `Config.Webhooks.Urls[...]` oder `Config.Webhooks.Routing.NachEvent[...]` eintragen |
| Justiz sieht keine Anträge | Falscher Job-Name | `Config.Kern.Justiz.Job` und `Config.Kern.Jobs.Justiz` auf den tatsächlichen Job-Namen setzen |
| Admin kann nicht auf Admin-UI zugreifen | Falscher Job/Grade | `Config.Kern.Admin.Job` und `Config.Kern.Admin.MinGrade` prüfen |
| Integrationen werden nicht ausgelöst | Feature-Flag nicht gesetzt | Beide Flags setzen: `Config.Module.Integrationen = true` **und** `Config.Integrationen.Aktiviert = true` |
| Spam-/Cooldown-Block greift nicht | AntiSpam nicht aktiviert | `Config.AntiSpam.Aktiviert = true` setzen |
| Migrationen laufen beim Start nicht | Config-Flag deaktiviert | `Config.Datenbank.Migrationen.BeimStartAutomatisch = true` |

---

## 12. Vollständige Config-Referenz

Die ausführliche Beschreibung **aller** Konfigurations-Sektionen mit Beispielen, Use-Cases und typischen Fehlern findest du in:

📄 **[`docs/CONFIG_REFERENCE.md`](docs/CONFIG_REFERENCE.md)**

Dort sind alle Abschnitte dokumentiert:

- `Config.Kern` – Framework, Jobs, öffentliche IDs
- `Config.Datenbank` – Adapter, Migrationen
- `Config.Zahlung` – Gebühren, Modus, Erstattungen, Befreiungen
- `Config.JobSettings` – Job-Grade-Berechtigungen
- `Config.Standorte` – Standorte, PEDs, Marker, Blips
- `Config.Rechte` / `Config.Permissions` – Berechtigungssystem
- `Config.Kategorien` – Kategorien, Workflow, SLA
- `Config.Formulare` – Formulare, Felder, Gebühren pro Formular
- `Config.Status` – Statusdefinitionen
- `Config.Workflows` – SLA, Sperren, Eskalation
- `Config.Benachrichtigungen` – Ingame-Benachrichtigungen
- `Config.Webhooks` – Routing, Pings, Dedizierte URLs
- `Config.Suche` – Suche/Filter
- `Config.AntiSpam` – Missbrauchsschutz (default OFF)
- `Config.Module` – Feature-Flags
- `Config.Anhaenge` – Anhang-Einstellungen
- `Config.Audit` – Retention, Cleanup
- `Config.SLA` – SLA-Checker
- `Config.Delegation` – Vollmacht-System (default OFF)
- `Config.Integrationen` – Folgeaktionen-Engine (default OFF)

---

### Weitere Anleitungen

Für Einsteiger und Nicht-IT-Nutzer gibt es ergänzende, sehr ausführliche Anleitungen:

| Dokument | Für wen? | Inhalt |
|---|---|---|
| 📖 **[Konfigurationsanleitung (DE)](docs/CONFIG_GUIDE_DE.md)** | Jeden, der den Server einrichtet | Schritt-für-Schritt Erklärung der `config.lua`, Feature-Flags, Overrides, Beispiele |
| 🖥️ **[Admin-UI Anleitung (DE)](docs/ADMIN_UI_GUIDE_DE.md)** | Admins und Leitung | Alle Tabs und Funktionen des Admin-Panels mit Beispielen |
| 💡 **[Beispiele & Troubleshooting (DE)](docs/EXAMPLES_AND_TROUBLESHOOTING_DE.md)** | Alle | Fertige Beispiel-Konfigurationen (klein/mittel/groß), Lösungen für häufige Probleme |
