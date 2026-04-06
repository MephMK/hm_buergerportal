# Admin-Panel Anleitung – hm_buergerportal

> **Für wen ist diese Anleitung?**  
> Diese Anleitung erklärt das **Admin-Panel** (Admin-UI) des Bürgerportals. Du brauchst keine IT-Kenntnisse – alles wird Schritt für Schritt erklärt.  
> Um das Admin-Panel zu öffnen, musst du den konfigurierten Admin-Job haben (Standard: `admin`).

---

## Inhaltsverzeichnis

1. [Das Admin-Panel öffnen](#1-das-admin-panel-öffnen)
2. [Überblick: Was kann das Admin-Panel?](#2-überblick-was-kann-das-admin-panel)
3. [Tab: Module (Feature-Flags)](#3-tab-module-feature-flags)
4. [Tab: JobSettings (Job-Berechtigungen)](#4-tab-jobsettings-job-berechtigungen)
5. [Tab: Webhooks (Discord-Einstellungen)](#5-tab-webhooks-discord-einstellungen)
6. [Tab: Formulare & Kategorien (Formular-Editor)](#6-tab-formulare--kategorien-formular-editor)
7. [Tab: Anträge verwalten (Admin-Ops)](#7-tab-anträge-verwalten-admin-ops)
8. [Tab: Audit-Log](#8-tab-audit-log)
9. [Was sind Overrides und wie setzt man sie zurück?](#9-was-sind-overrides-und-wie-setzt-man-sie-zurück)
10. [Sicherheitshinweise](#10-sicherheitshinweise)

---

## 1. Das Admin-Panel öffnen

Das Admin-Panel öffnest du genauso wie das normale Bürgerportal – an einem konfigurierten Standort in der Spielwelt (Taste **E** oder per `ox_target`). Spieler mit dem Admin-Job sehen einen zusätzlichen **„Admin"**-Tab in der Benutzeroberfläche.

**Voraussetzungen:**
- Du hast den Admin-Job (Standard: `admin`) in ESX
- `Config.Module.AdminUI = true` ist in der `config.lua` gesetzt (Standard: aktiv)
- Dein Grade erfüllt `Config.Kern.Admin.MinGrade` (Standard: 0 = alle Grades)

> **Hinweis:** Wenn du den Admin-Tab nicht siehst, prüfe ob der Job-Name in `Config.Kern.Admin.Job` mit deinem ESX-Job-Namen übereinstimmt.

---

## 2. Überblick: Was kann das Admin-Panel?

Das Admin-Panel ist in mehrere Bereiche (Tabs) aufgeteilt:

| Tab | Kurzbeschreibung |
|-----|-----------------|
| **Module** | Einzelne Features ein-/ausschalten |
| **JobSettings** | Job-Grade-Berechtigungen verwalten |
| **Webhooks** | Discord-Webhook-URLs live ändern |
| **Formulare & Kategorien** | Formulare erstellen, bearbeiten, veröffentlichen |
| **Anträge** | Anträge suchen, verschieben, löschen, Status überschreiben |
| **Audit-Log** | Protokoll aller Aktionen lesen |

**Das Besondere am Admin-Panel:**  
Änderungen, die du im Admin-Panel machst, werden sofort aktiv – **du musst den Server nicht neu starten**. Diese Änderungen nennt man **Overrides** und werden in der Datei `data/admin_overrides.json` gespeichert. Sie haben Vorrang vor der `config.lua`.

---

## 3. Tab: Module (Feature-Flags)

### Was ist das?

Hier kannst du ganze Funktionsbereiche des Portals **live ein- oder ausschalten**, ohne die `config.lua` zu bearbeiten und den Server neu zu starten.

### Verfügbare Module

| Modulname | Was macht es? | Standard |
|-----------|--------------|---------|
| **AdminUI** | Zeigt/versteckt den Admin-Bereich in der UI | ✅ AN |
| **Anhänge** | Erlaubt Spielern, Bild-Links an Anträge zu hängen | ✅ AN |
| **Gebühren** | Aktiviert das Gebührensystem | ✅ AN |
| **Delegation** | Ermöglicht das Einreichen im Auftrag anderer | ❌ AUS |
| **Entwürfe** | Speichern von Entwürfen für Justiz-Mitarbeiter | ❌ AUS |
| **Exporte** | CSV/PDF-Export von Anträgen | ✅ AN |
| **Audit-Härtung** | Erweiterte Sicherheit der Audit-Logs | ✅ AN |
| **Webhooks** | Discord-Benachrichtigungen | ✅ AN |
| **Benachrichtigungen** | Ingame-Nachrichten an Spieler | ✅ AN |
| **Integrationen** | Automatische Folgeaktionen nach Statuswechseln | ❌ AUS |

### Wie aktiviere/deaktiviere ich ein Modul?

1. Admin-Panel öffnen → Tab **„Module"**
2. Den gewünschten Schalter umlegen (🟢 = aktiv, ⚫ = inaktiv)
3. Die Änderung ist **sofort** aktiv

> **Achtung bei Gebühren:** Das Gebührenmodul kann zwar hier eingeschaltet werden, es funktioniert aber nur, wenn auch ein Banking-Script (`wasabi_banking`, `wasabi_billing`, `esx_banking` oder `esx_billing`) auf deinem Server läuft.

> **Achtung bei Integrationen:** Das Integrationen-Modul braucht **zusätzlich** `Config.Integrationen.Aktiviert = true` in der `config.lua`. Nur das Modul einzuschalten reicht nicht.

### Was passiert im Hintergrund?

Wenn du einen Schalter umlegst, schreibt das Admin-Panel den neuen Wert in `data/admin_overrides.json`. Beim nächsten Serverstart wird dieser Wert geladen und überschreibt den Wert aus `config.lua`.

**Beispiel admin_overrides.json nach dem Einschalten von Delegation:**
```json
{
  "module": {
    "Delegation": true
  }
}
```

---

## 4. Tab: JobSettings (Job-Berechtigungen)

### Was ist das?

Hier verwaltest du, welche **Grade (Ränge)** welcher Jobs welche Aktionen im Bürgerportal durchführen dürfen.

> **Hintergrund:** In FiveM/ESX hat jeder Job mehrere Ränge (Grades), z.B. Grade 0 = Neuling, Grade 3 = Abteilungsleiter. Das JobSettings-System erlaubt dir, höheren Grades mehr Rechte zu geben.

### Struktur des JobSettings-Tabs

Du siehst eine Liste aller konfigurierten Jobs. Für jeden Job kannst du:

1. **Anzeigenamen** ändern (wie der Job im Admin-Panel heißt)
2. **Globale Default-Rolle** setzen (welche Basis-Rechte der Job bekommt: `buerger`, `justiz` oder `admin`)
3. **Grades** verwalten (Namen der einzelnen Ränge)
4. **Grad-Berechtigungen** festlegen (ab welchem Grade welche zusätzlichen Rechte)

### So funktionieren Grad-Berechtigungen

Jeder Mitarbeiter hat zunächst die **Rechte seiner Basis-Rolle** (`buerger`/`justiz`/`admin`). Zusätzlich können bestimmte Grades extra Rechte bekommen (mit `allow`) oder bestehende verlieren (mit `deny`).

**Praxisbeispiel – DoJ (Justiz):**

```
Grade 0 (Associate)  → Basis-Rechte des "justiz"-Rolle (Anträge sehen, bearbeiten)
Grade 1 (Attorney)   → + keine Extra-Rechte
Grade 2 (Senior)     → + Alle Anträge sehen, Archiv, Archivieren, Zuweisen, Priorität setzen
Grade 3 (Chief)      → + alles wie Grade 2 (Rechte kumulieren sich)
```

### Wichtige Rechte-Schlüssel im JobSettings-Tab

Wenn du im Admin-Panel Rechte hinzufügst oder entfernst, verwendest du diese Schlüssel-Namen:

| Schlüssel | Bedeutung |
|---|---|
| `submissions.view_all` | **Alle** Anträge sehen (nicht nur zugewiesene) |
| `submissions.view_archive` | Das Archiv einsehen |
| `submissions.archive` | Anträge ins Archiv verschieben |
| `submissions.assign` | Anträge einem Bearbeiter zuweisen |
| `submissions.set_priority` | Priorität eines Antrags ändern |
| `submissions.approve` | Anträge genehmigen |
| `submissions.reject` | Anträge ablehnen |
| `workflow.lock.override` | Die Bearbeitungs-Sperre eines anderen aufheben |
| `workflow.sla.pause` | Den Frist-Countdown pausieren |
| `workflow.sla.resume` | Den Frist-Countdown fortsetzen |
| `notes.internal.write` | Interne Notizen schreiben (nur Justiz sichtbar) |
| `form_editor.publish` | Formulare veröffentlichen |
| `form_editor.archive` | Formulare archivieren |
| `delegate.submit_for_citizen` | Im Auftrag eines Bürgers einreichen |
| `vollmacht.manage` | Vollmachten verwalten |

### Beispiel: Grade 2 bekommt Leitungs-Rechte

Im Admin-Panel → Tab „JobSettings" → Job „doj" → Grade 2 → Bearbeiten:

**Erlauben (allow):**
```
submissions.view_all
submissions.view_archive
submissions.archive
submissions.assign
submissions.set_priority
workflow.lock.override
workflow.sla.pause
notes.internal.write
form_editor.publish
```

**Verbieten (deny):** (leer lassen = nichts verbieten)

Nach dem Speichern ist die Änderung sofort aktiv. Der Wert wird in `data/admin_overrides.json` gespeichert.

### Hinweis: Kumulierung von Rechten

Rechte kumulieren sich von unten nach oben. Ein Spieler mit Grade 3 hat automatisch alle Rechte von Grade 0, 1, 2 und 3. Du musst Rechte nicht doppelt eintragen.

---

## 5. Tab: Webhooks (Discord-Einstellungen)

### Was ist das?

Hier kannst du die Discord-Webhook-URLs live ändern, ohne die `config.lua` zu bearbeiten.

### Was ist ein Webhook?

Ein Webhook ist eine automatische Nachricht, die das System in einen Discord-Kanal schickt, wenn etwas passiert. Du brauchst eine **Webhook-URL** von Discord.

**Webhook-URL erstellen:**
1. Gehe in Discord zu dem Kanal, der die Nachrichten empfangen soll
2. Kanal-Einstellungen (Zahnrad) → „Integrationen" → „Webhooks"
3. „Neuer Webhook" → Name eingeben → „Webhook-URL kopieren"
4. Diese URL im Admin-Panel eintragen

### Verfügbare Webhook-Kanäle

| Kanal-Schlüssel | Für welche Events? | Empfehlungen |
|---|---|---|
| `antrag_payments` | Gebühren abgezogen, erstattet, Fehler | Kanal nur für Admins |
| `antrag_escalation` | SLA-Überschreitungen, Erinnerungen | Kanal für Leitung |
| `admin_ops` | Admin-Aktionen (Löschen, Status-Override) | Kanal nur für Admins |
| `missbrauch` | Spam-Blocks, Lockouts, Blacklist-Treffer | Kanal für Admins |
| `integrationen` | Folgeaktions-Fehler und -Erfolge | Technischer Kanal |
| `pdf_export` | PDF-Export-Benachrichtigungen | Optional |

### Event-Routing

Zusätzlich zu den dedizierten Kanälen kannst du für normale Antrags-Events eigene Kanäle konfigurieren:

| Event | Wann wird es ausgelöst? |
|---|---|
| `antrag_created` | Ein neuer Antrag wurde eingereicht |
| `antrag_status_changed` | Status eines Antrags hat sich geändert |
| `antrag_question_asked` | Eine Rückfrage wurde gestellt |
| `antrag_citizen_replied` | Ein Bürger hat auf eine Rückfrage geantwortet |

### Routing-Reihenfolge

Wenn ein Event ausgelöst wird, prüft das System in dieser Reihenfolge, wohin die Nachricht geht:

```
1. Formular-spezifische URL (NachFormular)  ← höchste Priorität
2. Kategorie-spezifische URL (NachKategorie)
3. Event-spezifische URL (NachEvent)
4. Fallback-URL (wenn nichts anderes passt)
```

**Beispiel:** Ein Antrag für das Formular „eilantrag" wird eingereicht:
- Wenn `NachFormular["eilantrag"]` eine URL hat → diese wird genutzt
- Sonst: Wenn `NachKategorie[".."]` eine URL hat → diese
- Sonst: `NachEvent["antrag_created"]` → diese
- Sonst: `Fallback` → diese
- Wenn alle `nil`: Kein Webhook wird gesendet

### Discord-Pings konfigurieren

Du kannst das System so einrichten, dass bei kritischen Events eine Discord-Rolle angepingt wird (`@Rolle`). Das konfigurierst du nicht im Admin-Panel, sondern in der `config.lua`:

```lua
Config.Webhooks.Pings = {
  Aktiviert = true,
  RolleId   = "123456789012345678",  -- Discord-Rollen-ID (Rechtsklick → ID kopieren)
  NurFuerEvents = {
    "abuse_triggered",          -- Missbrauchsblock
    "antrag_hartgeloescht",     -- Hard-Delete
    "admin_status_override",    -- Status-Überschreibung
  }
}
```

**Rollen-ID herausfinden:** Discord-Einstellungen → Rollen → Rechtsklick auf Rolle → „ID kopieren" (Developer Mode muss aktiviert sein: Einstellungen → Erweitert → Developer Mode)

---

## 6. Tab: Formulare & Kategorien (Formular-Editor)

### Was ist das?

Mit dem Formular-Editor kannst du **neue Formulare** erstellen, bestehende bearbeiten, veröffentlichen oder archivieren – alles ohne die `config.lua` zu bearbeiten.

> **Wichtig:** Formulare, die du im Editor erstellst, werden in der **Datenbank** gespeichert (nicht in config.lua). Sie existieren nur auf deinem Server.

### Zwei Modi des Editors

Der Formular-Editor bietet zwei Bearbeitungsmodi:

| Modus | Geeignet für | Beschreibung |
|---|---|---|
| **Geführt** | Einsteiger | Schrittweise Formulare durch eine visuelle Oberfläche |
| **Erweitert** | Fortgeschrittene | Direktes JSON-Bearbeiten (mehr Kontrolle, aber Fehleranfälliger) |

**Empfehlung für Einsteiger:** Den Geführten Modus verwenden.

### Formular erstellen (Geführter Modus)

1. Admin-Panel → Tab „Formulare" → „Neues Formular"
2. Grunddaten eingeben:
   - **Titel** (Anzeigename, z.B. „Gewerbe-Anmeldung")
   - **Kategorie** (wohin gehört das Formular?)
   - **Beschreibung** (kurze Erklärung für Bürger)
3. Felder hinzufügen:
   - „Feld hinzufügen" → Feldtyp wählen
   - Label (Feldname), Pflichtfeld ja/nein, Min/Max-Länge einstellen
4. Gebühren einstellen (falls gewünscht):
   - Gebühr aktivieren, Betrag in Euro eingeben
5. Formular **speichern** (Status: Entwurf)
6. Formular **veröffentlichen** (erst dann können Bürger es sehen)

### Formular veröffentlichen/archivieren

- **Veröffentlichen:** Das Formular wird sichtbar und kann eingereicht werden
  - Nur möglich wenn der Grade des Admins `form_editor.publish` erlaubt
- **Archivieren:** Das Formular wird versteckt (bestehende Anträge bleiben erhalten)
  - Nur möglich wenn der Grade `form_editor.archive` erlaubt

### Wer darf Formulare bearbeiten?

Die Zugriffsrechte für den Formular-Editor werden in `Config.FormularEditor` in der `config.lua` festgelegt:

```lua
Config.FormularEditor = {
  AdminHatImmerZugriff = true,  -- Admin kann immer alles

  Kategorien = {
    ["general"] = {
      editor      = { job = "doj", mindestGrad = 2 },  -- ab Grade 2: Formulare bearbeiten
      publisher   = { job = "doj", mindestGrad = 4 },  -- ab Grade 4: Formulare veröffentlichen
      archivierer = { job = "doj", mindestGrad = 4 },  -- ab Grade 4: Formulare archivieren
    },
  }
}
```

### Unterstützte Feldtypen im Formular-Editor

| Typ | Was ist das? | Pflichtfeld möglich? |
|-----|-------------|---------------------|
| Kurzer Text | Einzeiliges Textfeld | ✅ |
| Langer Text | Mehrzeiliges Textfeld | ✅ |
| Zahl | Nur Zahlen | ✅ |
| Geldbetrag | Betrag in Euro | ✅ |
| Datum | Datum-Auswahl | ✅ |
| Uhrzeit | Uhrzeit-Auswahl | ✅ |
| Datum + Uhrzeit | Kombiniert | ✅ |
| Dropdown (Einfach) | Eine Auswahl aus mehreren Optionen | ✅ |
| Dropdown (Mehrfach) | Mehrere Auswahlen gleichzeitig | ✅ |
| Radio-Buttons | Auswahl-Buttons | ✅ |
| Ja/Nein (Checkbox) | Haken-Feld | ✅ |
| Internet-Link (URL) | URL-Eingabefeld | ✅ |
| Fahrzeugkennzeichen | Kennzeichen-Format | ✅ |
| Spieler-Referenz | Spieler-Name oder ID | ✅ |
| Firmen-Referenz | Firmen-Name | ✅ |
| Aktenzeichen-Referenz | Verknüpfung zu anderem Antrag | ✅ |
| Überschrift | Dekoratives Element (kein Eingabefeld) | ❌ |
| Infotext | Hinweistext (kein Eingabefeld) | ❌ |
| Trennlinie | Optische Trennung | ❌ |

---

## 7. Tab: Anträge verwalten (Admin-Ops)

### Was ist das?

Als Admin kannst du direkt in Anträge eingreifen – auch wenn das normalerweise nicht erlaubt wäre. Diese Aktionen nennt man **Admin-Ops**.

> **Wichtig:** Alle Admin-Ops werden im **Audit-Log** protokolliert und lösen Discord-Webhooks an `Config.Webhooks.Urls["admin_ops"]` aus.

### Verfügbare Admin-Aktionen

#### Anträge suchen

Du kannst Anträge suchen nach:
- **Volltext** (Spielername, Aktenzeichen, Formular-ID)
- **Zahlungsstatus** (bezahlt / unbezahlt / befreit)
- **Formular-ID** (nur Anträge dieses Formulars)
- **Sortierung** nach: Erstellt am, Zuletzt geändert, SLA-Frist

Der Admin-Bereich sucht **kategorieübergreifend** – du siehst alle Anträge aller Kategorien.

#### Antrag verschieben

**Was macht das?**  
Verschiebt einen Antrag in eine andere Kategorie oder ein anderes Formular.

**Wann sinnvoll?**  
Wenn ein Bürger das falsche Formular verwendet hat und der Antrag in die richtige Abteilung soll.

**Ablauf:**
1. Antrag suchen und öffnen
2. „Verschieben" klicken
3. Ziel-Kategorie und ggf. Ziel-Formular auswählen
4. Bestätigen

**Webhook-Event:** `antrag_verschoben`

#### Antrag wiederherstellen

**Was macht das?**  
Holt einen archivierten Antrag zurück in die aktive Queue.

**Wann sinnvoll?**  
Wenn ein Antrag versehentlich archiviert wurde oder wieder bearbeitet werden muss.

**Webhook-Event:** `antrag_wiederhergestellt`

#### Antrag dauerhaft löschen (Hard-Delete)

**Was macht das?**  
Löscht einen Antrag **unwiderruflich** aus der Datenbank (inkl. aller zugehörigen Daten: Nachrichten, Anhänge, Audit-Einträge für diesen Antrag).

> **⚠️ Achtung:** Diese Aktion kann **nicht rückgängig** gemacht werden!

**Einstellungen in config.lua:**
```lua
Config.Archiv.HartLoeschen = {
  Aktiviert    = true,    -- false = Hard-Delete im Admin-Panel deaktivieren
  NurAdmin     = true,    -- true = nur der Admin-Job darf hard-deleten (nicht Justiz)
  GrundPflicht = true,    -- true = ein Löschgrund muss angegeben werden
}
```

**Webhook-Event:** `antrag_hartgeloescht` (löst Discord-Ping aus, falls konfiguriert)

#### Status überschreiben (Status-Override)

**Was macht das?**  
Setzt den Status eines Antrags **direkt** – auch auf Status, die normalerweise nicht erlaubt wären (z.B. direkt von `submitted` auf `archived`).

**Wann sinnvoll?**  
Notfall-Korrekturen, wenn ein Antrag in einem falschen Status feststeckt.

> **Achtung:** Status-Override umgeht die normalen Workflow-Regeln (`erlaubteFolgeStatus`). Verwende es nur wenn nötig.

**Webhook-Event:** `admin_status_override`

#### Im Auftrag erstellen

**Was macht das?**  
Ein Admin kann einen Antrag **im Namen eines anderen Spielers** erstellen – z.B. für einen Bürger, der gerade nicht online ist.

**Voraussetzung:** `Config.Module.Delegation = true`

**Sicherheit:** Der Identifier (Steam-ID etc.) des Bürgers wird dabei **nicht** im System oder in Discord angezeigt.

**Webhook-Event:** `antrag_im_auftrag_erstellt`

---

## 8. Tab: Audit-Log

### Was ist das?

Das Audit-Log ist ein **vollständiges Protokoll** aller Aktionen, die im System stattgefunden haben. Es kann nicht bearbeitet oder gelöscht werden (nur automatisch nach `Config.Audit.Retention.TageMax` Tagen).

### Wer kann das Audit-Log sehen?

- **Admin:** Immer (alle Einträge)
- **Justiz-Leitung** (ab `Config.Workflows.Leitung.MinGrade`): Wenn `Config.Audit.LeitungDarfLesen = true` gesetzt ist

### Was wird protokolliert?

| Aktion | Wann? |
|--------|-------|
| Antrag eingereicht | Spieler reicht Formular ein |
| Status geändert | Justiz ändert Status |
| Antrag genehmigt / abgelehnt | Finale Entscheidung |
| Antrag archiviert | Archivierung |
| Antrag dauerhaft gelöscht | Hard-Delete durch Admin |
| Gebühr abgezogen | Zahlungsvorgang |
| Gebühr erstattet | Rückerstattung |
| Missbrauchsblock | AntiSpam hat geblockt |
| Admin-Aktion | Verschieben, Override, etc. |
| Integration ausgeführt | Folgeaktion bei Statuswechsel |

### Audit-Log-Einträge filtern

Im Audit-Log kannst du filtern nach:
- **Zeitraum** (Von/Bis)
- **Aktion** (z.B. nur Zahlungen)
- **Spieler** (nach Namen)
- **Antrag** (nach Aktenzeichen)

### Wie lange werden Logs aufbewahrt?

Die Aufbewahrungsdauer wird in `config.lua` festgelegt:

```lua
Config.Audit.Retention.TageMax = 90   -- 90 Tage (Standard)
```

Alle 3600 Sekunden (1 Stunde) räumt das System automatisch ältere Einträge auf.

---

## 9. Was sind Overrides und wie setzt man sie zurück?

### Was ist ein Override?

Wenn du im Admin-Panel eine Einstellung änderst, wird der neue Wert in der Datei `data/admin_overrides.json` gespeichert. Diese Datei **überschreibt** die Werte in `config.lua`. Das nennt man einen **Override**.

**Beispiel:** In `config.lua` steht `Config.Module.Gebuehren = true`. Du schaltest es im Admin-Panel aus. Jetzt steht in `admin_overrides.json`:

```json
{
  "module": {
    "Gebuehren": false
  }
}
```

Das Gebührenmodul ist jetzt ausgeschaltet – **auch wenn config.lua noch `true` sagt**.

### Override zurücksetzen

**Option A – Im Admin-Panel:**
1. Admin-Panel → Tab „Module" (oder „JobSettings" etc.)
2. Das betroffene Feld suchen
3. „Zurücksetzen" oder „Standard" klicken

**Option B – admin_overrides.json direkt bearbeiten:**
1. Datei `data/admin_overrides.json` öffnen
2. Den betroffenen Schlüssel löschen
3. Datei speichern
4. Server neu starten

> **Achtung bei Option B:** JSON-Syntax ist genau. Ein fehlendes oder falsches Komma kann die Datei ungültig machen und den Server-Start verhindern.

**Option C – Alle Overrides löschen:**
1. Datei `data/admin_overrides.json` löschen oder leeren (`{}`)
2. Server neu starten
3. Jetzt gelten wieder alle Werte aus `config.lua`

### Welche Bereiche können überschrieben werden?

| Bereich | Kann im Admin-Panel überschrieben werden? |
|---------|------------------------------------------|
| Modul-Schalter (`Config.Module`) | ✅ Ja |
| Job-Berechtigungen (`Config.JobSettings`) | ✅ Ja |
| Webhook-URLs (`Config.Webhooks`) | ✅ Ja |
| Kategorien-Einstellungen | ✅ Ja |
| Formular-Einstellungen | ✅ Ja |
| Kern-Einstellungen (`Config.Kern`) | ❌ Nein (nur über config.lua) |
| Zahlungs-Einstellungen (`Config.Zahlung`) | ❌ Nein (nur über config.lua) |
| Standorte (`Config.Standorte`) | ❌ Nein (nur über config.lua) |

---

## 10. Sicherheitshinweise

### Identifier-Schutz

Das Admin-Panel zeigt **niemals** spieler-spezifische Identifier (Steam-ID, License-Hash, Discord-ID usw.). Du siehst nur:
- Ingame-Namen
- Charakter-Namen
- Öffentliche Aktenzeichen (z.B. `HM-DOJ-2024-000001`)

### Serverseitige Prüfungen

Alle Admin-Aktionen werden **serverseitig** geprüft. Das bedeutet:
- Die Berechtigungen werden auf dem Server geprüft, nicht im Browser
- Ein Spieler kann die Admin-UI nicht manipulieren um sich Rechte zu verschaffen
- Hard-Delete, Status-Override und andere kritische Aktionen erfordern den Admin-Job **auf dem Server**

### Audit-Trail

Alle Admin-Aktionen hinterlassen einen unveränderlichen Eintrag im Audit-Log. Selbst ein Admin kann diese Einträge nicht löschen (nur das automatische Retention-System nach X Tagen).

### Wer hat Zugriff auf das Admin-Panel?

Nur Spieler, die in ESX den konfigurierten Admin-Job haben (`Config.Kern.Admin.Job`, Standard: `admin`) und den konfigurierten Mindest-Grade haben (`Config.Kern.Admin.MinGrade`, Standard: 0 = alle).

> **Empfehlung:** Vergib den Admin-Job nur an vertrauenswürdige Personen. Alle ihre Aktionen werden geloggt.

---

## Weiterführende Anleitungen

- **Vollständige Konfigurations-Anleitung:** [`docs/CONFIG_GUIDE_DE.md`](CONFIG_GUIDE_DE.md)
- **Vollständige Config-Referenz (technisch):** [`docs/CONFIG_REFERENCE.md`](CONFIG_REFERENCE.md)
- **Überblick und Installation:** [`README.md`](../README.md)
