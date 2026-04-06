# Admin-UI Anleitung – hm_buergerportal

> **Für wen ist diese Anleitung?**  
> Für Admins und Leitung, die das Bürgerportal über die **Benutzeroberfläche im Spiel** verwalten wollen.  
> Hier wird erklärt, welche Tabs es gibt, was du dort einstellen kannst und wie die Änderungen gespeichert werden – ohne Programmierkenntnisse.

---

## Inhaltsverzeichnis

1. [Wie öffne ich das Admin-Panel?](#1-wie-öffne-ich-das-admin-panel)
2. [Tab: Übersicht / Dashboard](#2-tab-übersicht--dashboard)
3. [Tab: JobSettings – Rang-Berechtigungen](#3-tab-jobsettings--rang-berechtigungen)
4. [Tab: Module – Feature-Flags ein-/ausschalten](#4-tab-module--feature-flags-einausschalten)
5. [Tab: Berechtigungen (Permissions)](#5-tab-berechtigungen-permissions)
6. [Tab: Webhooks](#6-tab-webhooks)
7. [Tab: Status & Workflow](#7-tab-status--workflow)
8. [Tab: Standorte (Standortverwaltung)](#8-tab-standorte-standortverwaltung)
9. [Tab: Formular-Editor](#9-tab-formular-editor)
10. [Tab: Audit-Log](#10-tab-audit-log)
11. [Tab: Admin-Operationen](#11-tab-admin-operationen)
12. [Wie werden Änderungen gespeichert?](#12-wie-werden-änderungen-gespeichert)
13. [Unterschied: Admin-Panel vs. config.lua](#13-unterschied-admin-panel-vs-configlua)
14. [Häufige Fragen zum Admin-Panel](#14-häufige-fragen-zum-admin-panel)

---

## 1. Wie öffne ich das Admin-Panel?

Das Admin-Panel ist Teil des Bürgerportals – du öffnest es an einem Portal-Standort oder über einen Befehl (je nach Serverkonfiguration).

### Voraussetzungen

- Du musst den **Admin-Job** auf deinem Server haben (Standard: `admin`)
- `Config.Module.AdminUI = true` muss in der `config.lua` gesetzt sein

### So öffnest du es

1. Gehe zu einem Standort, an dem das Bürgerportal geöffnet werden kann
2. Öffne das Portal (Taste E oder ox_target)
3. Im Portal-Fenster erscheint oben rechts (oder in einer eigenen Leiste) der **Admin-Bereich**

Wenn du den Admin-Job hast, siehst du zusätzliche Tabs und Menüpunkte, die normale Spieler nicht sehen.

---

## 2. Tab: Übersicht / Dashboard

Das Dashboard zeigt dir auf einen Blick:

- **Anzahl offener Anträge** – wie viele Anträge gerade in Bearbeitung sind
- **Überfällige Anträge** – Anträge, bei denen die SLA-Frist überschritten wurde
- **Letzte Aktivitäten** – die neuesten Statuswechsel und Aktionen

> **Tipp:** Das Dashboard hilft dir, schnell zu sehen, ob irgendwo Engpässe entstehen oder viele Anträge schon zu lange warten.

---

## 3. Tab: JobSettings – Rang-Berechtigungen

Im **JobSettings-Tab** legst du fest, welche Ränge eines Jobs welche zusätzlichen Rechte haben.

### Was du hier siehst

- Eine Liste aller konfigurierten Jobs (z.B. `doj` – Justiz, `admin` – Administrator)
- Für jeden Job: eine Liste der Ränge (Grade)
- Für jeden Rang: welche Aktionen erlaubt oder verboten sind

### Beispiel: Was du bei "doj" einstellen kannst

Wenn du auf den Job `doj` klickst, siehst du die Ränge:

| Rang | Name | Beispiel: Erlaubte Aktionen |
|---|---|---|
| 0 | Mitarbeiter | Anträge ansehen, antworten |
| 1 | Senior Mitarbeiter | Anträge übernehmen, Status ändern |
| 2 | Leitender Mitarbeiter | Alle Anträge sehen, Archiv, SLA pausieren |
| 3 | Abteilungsleiter | Vollzugriff innerhalb des Jobs |

### Wie du Berechtigungen änderst

1. Klicke auf den Job (z.B. `doj`)
2. Klicke auf den Rang, den du anpassen möchtest
3. Du siehst eine Liste von Aktionen mit Häkchen (erlaubt) oder X (verboten)
4. Ändere die Einstellungen wie gewünscht
5. Klicke „Speichern"

### Welche Aktionen gibt es?

| Aktion | Beschreibung |
|---|---|
| `submissions.view_inbox` | Eingangs-Queue der Anträge sehen |
| `submissions.view_all` | Alle Anträge aller Mitarbeiter sehen |
| `submissions.view_archive` | Archiv ansehen |
| `submissions.approve` | Antrag genehmigen |
| `submissions.reject` | Antrag ablehnen |
| `submissions.archive` | Antrag archivieren |
| `submissions.assign` | Antrag einem Mitarbeiter zuweisen |
| `submissions.set_priority` | Priorität eines Antrags ändern |
| `workflow.lock.override` | Bearbeitungs-Sperre eines anderen aufheben |
| `workflow.sla.pause` | SLA-Frist pausieren |
| `notes.internal.write` | Interne Notizen schreiben |
| `form_editor.publish` | Formular veröffentlichen |
| `form_editor.archive` | Formular archivieren |

> **Wichtig:** Änderungen im JobSettings-Tab werden in `data/admin_overrides.json` gespeichert und **überschreiben** die Werte in `config.lua`. Das ist gewollt – so kannst du Einstellungen live ändern, ohne den Server neu zu starten.

---

## 4. Tab: Module – Feature-Flags ein-/ausschalten

Im **Module-Tab** kannst du Funktionen des Portals ein- oder ausschalten – ohne die `config.lua` bearbeiten zu müssen.

### Was du hier siehst

Eine Liste aller Module mit einem Schalter (an/aus):

| Modul | Was es macht |
|---|---|
| **Admin-UI** | Den Admin-Bereich selbst anzeigen/ausblenden |
| **Anhänge** | Bild-Links an Anträge erlauben |
| **Gebühren** | Gebührensystem aktivieren |
| **Delegation** | Im-Auftrag-Einreichung aktivieren |
| **Entwürfe** | Entwürfe für Justiz-Mitarbeiter |
| **Exporte** | PDF/CSV-Export aktivieren |
| **Audit-Härtung** | Erweiterte Protokollierung |
| **Webhooks** | Discord-Benachrichtigungen |
| **Benachrichtigungen** | Ingame-Nachrichten an Spieler |
| **Integrationen** | Folgeaktionen nach Statuswechsel |

### Screenshot-Platzhalter

```
[Bild: Module-Tab mit Liste aller Schalter]
```

### So schaltest du ein Modul um

1. Gehe zum **Module-Tab**
2. Suche das gewünschte Modul
3. Klicke auf den Schalter (grün = an, grau = aus)
4. Bestätige die Änderung
5. Die Änderung wird sofort aktiv – kein Serverneustart nötig

> **Hinweis:** Wenn du ein Modul hier ausschaltest, das in `config.lua` auf `true` steht, gilt trotzdem die hier getroffene Einstellung (Override). Die Änderung wird in `data/admin_overrides.json` gespeichert.

---

## 5. Tab: Berechtigungen (Permissions)

Im **Permissions-Tab** kannst du die feingranularen Berechtigungen für Rollen und Jobs anpassen.

### Kaskaden-Prinzip verstehen

Das Berechtigungssystem arbeitet mit einer Hierarchie – die spezifischste Einstellung gewinnt:

```
Admin-Job → immer Vollzugriff (höchste Priorität)
    ↓
Globale Defaults (gilt für alle)
    ↓
Kategorie-Override (gilt nur für diese Kategorie)
    ↓
Formular-Override (gilt nur für dieses Formular)
```

### Beispiel: Kategorie-spezifische Berechtigungen

**Situation:** In der Kategorie „Gewerbe" sollen nur Ränge 2 und höher Anträge archivieren dürfen.

Im Admin-Panel:
1. Kategorie „Gewerbe" auswählen
2. Im Permissions-Tab für diese Kategorie:
   - Für Justiz: `grade.min = 2`
   - `submissions.archive` erlauben
3. Speichern

### Screenshot-Platzhalter

```
[Bild: Permissions-Tab mit Kategorie-Override-Einstellungen]
```

---

## 6. Tab: Webhooks

Im **Webhooks-Tab** kannst du Discord-Webhook-URLs direkt im Admin-Panel eintragen und testen.

### Was du hier siehst

- Eine Liste aller konfigurierbaren Webhook-Kanäle
- Für jeden Kanal: ein Eingabefeld für die Discord-Webhook-URL
- Einen „Test"-Button zum sofortigen Testen

### Webhook-Kanäle und ihre Bedeutung

| Kanal | Wann wird etwas gesendet? |
|---|---|
| **Gebühren** (`antrag_payments`) | Gebühr abgezogen, erstattet oder Fehler |
| **Eskalation** (`antrag_escalation`) | SLA-Frist überschritten, Erinnerungen |
| **Admin-Ops** (`admin_ops`) | Admin hat Antrag verschoben, gelöscht oder Status geändert |
| **Missbrauch** (`missbrauch`) | Spam-Erkennung, Spieler gesperrt, Blacklist-Treffer |
| **Integrationen** (`integrationen`) | Folgeaktions-Ereignisse |
| **PDF-Export** (`pdf_export`) | PDF wurde erstellt |

### Event-Routing

Hier kannst du festlegen, welche Art von Ereignis in welchen Discord-Channel geht:

- **Nach Event-Typ:** z.B. „Neuer Antrag" → Channel A, „Statuswechsel" → Channel B
- **Nach Kategorie:** z.B. „Gewerbe-Anträge" → Channel C
- **Nach Formular:** z.B. „Gewerbeanmeldung" → Channel D
- **Fallback:** Wenn kein anderer Eintrag passt → dieser Channel

### Routing-Priorität

Das System prüft in dieser Reihenfolge – die **erste** passende Einstellung gewinnt:

1. Formular-spezifische URL
2. Kategorie-spezifische URL
3. Event-spezifische URL
4. Fallback-URL

### Screenshot-Platzhalter

```
[Bild: Webhooks-Tab mit URL-Eingabefeldern und Test-Buttons]
```

### Discord-Pings einrichten

Wenn bei kritischen Ereignissen eine Discord-Rolle angepingt werden soll:

1. Im Webhooks-Tab den Bereich „Pings" öffnen
2. „Pings aktivieren" einschalten
3. Discord-Rollen-ID eintragen (rechtsklick auf Rolle in Discord → „ID kopieren")
4. Auswählen, für welche Ereignisse gepingt werden soll

---

## 7. Tab: Status & Workflow

Im **Status-Tab** kannst du die Antrags-Status und Workflow-Regeln verwalten.

### Antrags-Status

Das System hat 13 Standard-Status:

| Status-ID | Anzeige | Bürger sieht es? | Justiz sieht es? |
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

> **Hinweis:** `escalated` ist für Bürger unsichtbar – so bleibt interne Eskalation verborgen.

### Erlaubte Folge-Status

Jeder Status hat eine Liste, welche Status als nächstes möglich sind. Das verhindert unlogische Sprünge:

- Aus `submitted` kann der Status wechseln zu: `in_review`, `rejected`, `withdrawn` usw.
- Aus `approved` kann der Status wechseln zu: `archived`, `closed`

Diese Regeln kannst du im Status-Tab anpassen oder in der `config.lua` unter `Config.Status.Liste[id].erlaubteFolgeStatus`.

### SLA / Fristen

SLA (Service Level Agreement) ist die Frist, innerhalb derer ein Antrag bearbeitet werden soll.

**Was passiert wenn die Frist überschritten wird:**
1. Der Antrag wird als „überfällig" markiert (`due_state = "overdue"`)
2. Es wird ein Webhook an den Eskalations-Channel gesendet
3. Im Admin-Dashboard erscheint der Antrag in der Überfällig-Liste

**SLA-Pause:** Wenn ein Antrag auf „Rückfrage offen" oder „Warten auf Unterlagen" gesetzt wird, pausiert die SLA-Uhr automatisch. Das ist wichtig, weil die Behörde dann auf den Bürger wartet.

### Workflow-Einstellungen

| Einstellung | Beschreibung |
|---|---|
| `DefaultSlaHours` | Standard-Frist in Stunden (wenn Kategorie nichts eigenes definiert) |
| `Leitung.MinGrade` | Ab welchem Rang gilt ein doj-Mitarbeiter als „Leitung" (für SLA-Override) |
| `Sperren.TimeoutSekunden` | Wie lange ein Bearbeitungs-Lock gilt (Standard: 600s = 10 Min.) |
| `Eskalation.UeberfaelligNachStunden` | Nach wie vielen Stunden wird eskaliert (Standard: 72h) |

### Screenshot-Platzhalter

```
[Bild: Status-Tab mit Übersicht der Status und erlaubten Übergängen]
```

---

## 8. Tab: Standorte (Standortverwaltung)

Im **Standorte-Tab** siehst du alle konfigurierten Standorte in der Spielwelt und kannst sie verwalten.

### Was du hier siehst

- Eine Liste aller Standorte mit Name, Koordinaten und Status (aktiv/inaktiv)
- Für jeden Standort: Details zu PED, Marker, Blip und Zugriffsregeln

### Standort aktivieren/deaktivieren

1. Standort in der Liste auswählen
2. Schalter „Aktiv" umschalten
3. Speichern

Ein deaktivierter Standort ist in der Spielwelt nicht mehr sichtbar und kann nicht mehr genutzt werden.

### Zugriffsregeln eines Standorts

Für jeden Standort kannst du festlegen:

| Einstellung | Beschreibung |
|---|---|
| `nurBuerger` | Nur normale Spieler (nicht Justiz/Admin) |
| `nurJustiz` | Nur Justiz und Admin |
| `nurAdmin` | Nur Admin |
| `erlaubteJobs` | Nur bestimmte Jobs (z.B. `["doj", "admin"]`) |
| `erlaubteKategorien` | Nur bestimmte Kategorien sichtbar |
| `erlaubteFormulare` | Nur bestimmte Formulare sichtbar |

### Beispiele

**Öffentlicher Bürger-Schalter:**
```
nurBuerger = false, nurJustiz = false, nurAdmin = false
erlaubteJobs = {}  (leer = alle Jobs erlaubt)
```

**Interne Justiz-Workstation:**
```
nurJustiz = true
erlaubteJobs = { "doj", "admin" }
```

**Nur für Gewerbe-Anträge:**
```
erlaubteKategorien = { "gewerbe" }
erlaubteFormulare = { "gewerbe_anmeldung" }
```

### Screenshot-Platzhalter

```
[Bild: Standorte-Tab mit Kartenansicht und Standortliste]
```

---

## 9. Tab: Formular-Editor

Der **Formular-Editor** ermöglicht es, neue Formulare direkt im Spiel zu erstellen, ohne die `config.lua` bearbeiten zu müssen.

> **Zugriffsvoraussetzung:** Du brauchst die Berechtigung `form_editor.publish` (oder höher).  
> Admin-Job hat immer Zugriff. Für Justiz muss es explizit in `Config.FormularEditor` oder den JobSettings freigegeben werden.

### Zwei Modi

| Modus | Beschreibung |
|---|---|
| **Geführt** (empfohlen) | Formular mit Schritt-für-Schritt Assistent erstellen |
| **Erweitert** | Formular als JSON direkt bearbeiten (für Fortgeschrittene) |

### Formular erstellen (geführter Modus)

1. Klicke „Neues Formular erstellen"
2. Wähle die **Kategorie** aus (z.B. „Allgemein")
3. Gib **Titel** und **Beschreibung** ein
4. Füge **Felder** hinzu (Klick auf „Feld hinzufügen"):
   - Feldtyp wählen (Kurztext, Langtext, Dropdown, Datum, usw.)
   - Label eingeben (z.B. „Betreff")
   - Pflichtfeld: Ja/Nein
   - Minimale/Maximale Länge
5. Gebühren einstellen (optional)
6. Klicke „Entwurf speichern"
7. Klicke „Veröffentlichen" wenn das Formular bereit ist

### Formular-Status

| Status | Beschreibung |
|---|---|
| Entwurf | Formular ist nur im Editor sichtbar, nicht für Spieler |
| Aktiv | Spieler können Anträge über dieses Formular stellen |
| Archiviert | Formular ist nicht mehr nutzbar, aber bestehende Anträge bleiben erhalten |

### Felder und ihre Typen

| Feldtyp | Beschreibung | Verwendung |
|---|---|---|
| Kurztext | Eine Zeile Text | Betreff, Name |
| Langtext | Mehrzeiliger Text | Beschreibung, Begründung |
| Zahl | Nur Zahlen | Betrag, Anzahl |
| Geldbetrag | Euro-Betrag | Kaufpreis |
| Datum | Kalender-Eingabe | Gültigkeitsdatum |
| Uhrzeit | Zeitangabe | Uhrzeiteingabe |
| Dropdown | Auswahl aus Liste | Kategorie wählen |
| Mehrfach-Dropdown | Mehrere Auswahlen | Tags wählen |
| Ja/Nein-Haken | Checkbox | Zustimmung |
| URL | Internetadresse | Screenshot-Link |
| Kennzeichen | Fahrzeug-Kennzeichen | Fahrzeugantrag |
| Spieler-Referenz | Ingame-Name/ID | Beteiligter Spieler |

### Screenshot-Platzhalter

```
[Bild: Formular-Editor mit Feldliste und Vorschau]
```

---

## 10. Tab: Audit-Log

Das **Audit-Log** zeigt alle Aktionen, die im System stattgefunden haben – wer hat was wann gemacht.

> **Zugriffsvoraussetzung:** Admin-Job oder `Config.Audit.LeitungDarfLesen = true` mit ausreichend hohem Rang.

### Was du im Audit-Log siehst

- **Zeitstempel** – wann die Aktion stattfand
- **Akteur** – wer die Aktion durchgeführt hat (Ingame-Name)
- **Aktion** – was gemacht wurde
- **Ziel** – welcher Antrag oder welche Ressource betroffen war
- **Details** – weitere Informationen

### Protokollierte Aktionen

| Aktion | Beschreibung |
|---|---|
| `submission.erstellt` | Neuer Antrag eingereicht |
| `submission.status_geaendert` | Statuswechsel |
| `submission.genehmigt` | Antrag genehmigt |
| `submission.abgelehnt` | Antrag abgelehnt |
| `submission.archiviert` | Antrag archiviert |
| `submission.hart_geloescht` | Antrag dauerhaft gelöscht (Admin) |
| `payment.abgezogen` | Gebühr abgezogen |
| `payment.refund` | Rückerstattung ausgeführt |
| `abuse.blockiert` | Spam-Block oder Missbrauchsblock |
| `admin_ops.*` | Admin-Operationen (Verschieben, Override usw.) |

### Filter und Suche

Im Audit-Log kannst du filtern nach:
- Akteur (Spieler-Name)
- Aktion (Art der Aktion)
- Zeitraum (von/bis)
- Antrag (Aktenzeichen)

### Wie lange werden Logs aufbewahrt?

Standard: **90 Tage** (konfigurierbar in `Config.Audit.Retention.TageMax`).  
Ältere Einträge werden automatisch gelöscht (Cleanup läuft stündlich).

### Unveränderlichkeit

Audit-Logs sind **unveränderlich** – die Anwendung kann keine Logs nachträglich ändern oder löschen. Das gilt für `hm_bp_audit_logs` in der Datenbank.

---

## 11. Tab: Admin-Operationen

Im **Admin-Ops-Tab** kannst du spezielle Aktionen für Anträge ausführen, die über normale Statuswechsel hinausgehen.

> **Zugriffsvoraussetzung:** Nur der Admin-Job hat Zugang zu diesen Funktionen.

### Verfügbare Operationen

#### 🔀 Antrag verschieben

Einen Antrag in eine andere Kategorie oder ein anderes Formular verschieben.

**Wann nötig:** Wenn ein Bürger das falsche Formular gewählt hat und der Antrag in die richtige Kategorie verschoben werden soll.

**Vorgehen:**
1. Antrag auswählen
2. „Verschieben" klicken
3. Ziel-Kategorie und Ziel-Formular wählen
4. Bestätigen

**Webhook:** `antrag_verschoben` wird gesendet.

#### ♻️ Antrag wiederherstellen

Einen archivierten Antrag wieder aktiv setzen.

**Wann nötig:** Wenn ein Antrag versehentlich archiviert wurde oder nochmals bearbeitet werden muss.

**Vorgehen:**
1. Ins Archiv gehen
2. Antrag auswählen
3. „Wiederherstellen" klicken
4. Neuen Status wählen (z.B. `in_review`)
5. Bestätigen

**Webhook:** `antrag_wiederhergestellt` wird gesendet.

#### 🗑️ Hard-Delete (dauerhaft löschen)

Einen Antrag **dauerhaft und unwiderruflich** aus dem System löschen.

> **Achtung:** Dieser Vorgang kann **nicht rückgängig gemacht werden**. Der Antrag und alle zugehörigen Daten werden gelöscht.

**Vorgehen:**
1. Antrag auswählen
2. „Hart löschen" klicken
3. Pflicht: Löschgrund eingeben
4. Bestätigung zweimal bestätigen

**Webhook:** `antrag_hartgeloescht` wird gesendet (+ Discord-Ping wenn konfiguriert).  
**Audit:** Wird immer in `hm_bp_audit_logs` gespeichert.

#### ⚡ Status-Override

Den Status eines Antrags direkt setzen, auch wenn der Statusübergang normalerweise nicht erlaubt wäre.

**Wann nötig:** Wenn ein Antrag in einem falschen Status feststeckt oder ein Ausnahmefall behandelt werden muss.

**Vorgehen:**
1. Antrag auswählen
2. „Status-Override" klicken
3. Ziel-Status wählen
4. Grund eingeben (Pflicht)
5. Bestätigen

**Webhook:** `admin_status_override` wird gesendet.

#### 📝 Im Auftrag erstellen

Einen Antrag im Namen eines anderen Spielers erstellen.

**Wann nötig:** Wenn ein Bürger nicht selbst online ist, aber ein Antrag für ihn erstellt werden muss (z.B. von einem Anwalt oder Behördenmitarbeiter).

**Vorgehen:**
1. „Im Auftrag erstellen" klicken
2. Spieler über Ingame-Namen suchen
3. Formular auswählen
4. Antrag ausfüllen
5. Einreichen

> **Datenschutz:** Der eigentliche Identifier des Spielers wird **nie** angezeigt – nur der Ingame-Name.

#### 🔍 Admin-Suche

Suche über alle Kategorien hinweg nach Anträgen (normale Justiz-Suche ist auf zugewiesene Kategorien begrenzt).

**Filter-Optionen:**
- Volltext (Bürger-Name, Aktenzeichen, Formular-ID)
- Zahlungsstatus (bezahlt / unbezahlt / befreit)
- Formular-ID
- Sortierung (Datum, SLA-Frist)

### Screenshot-Platzhalter

```
[Bild: Admin-Ops-Tab mit den 5 Aktions-Buttons]
```

---

## 12. Wie werden Änderungen gespeichert?

### Sofort aktiv (kein Serverneustart nötig)

Folgende Änderungen werden sofort wirksam:
- Module an-/ausschalten
- JobSettings (Rang-Berechtigungen)
- Webhook-URLs

### Gespeichert in data/admin_overrides.json

Alle Änderungen, die du im Admin-Panel machst, werden in der Datei `data/admin_overrides.json` gespeichert. Diese Datei wird beim Serverstart geladen und überschreibt die entsprechenden Werte in der `config.lua`.

**Beispiel:** Du schaltest das Delegations-Modul im Admin-Panel ein. In `config.lua` steht `Config.Module.Delegation = false`. Trotzdem ist Delegation jetzt aktiv, weil der Override in `admin_overrides.json` `true` hat.

### Zurücksetzen

Um eine Override zurückzusetzen:
1. Im Admin-Panel die Einstellung auf den gewünschten Wert setzen und speichern
2. Oder: Die Datei `data/admin_overrides.json` manuell bearbeiten
3. Oder: Die Datei löschen – dann gelten wieder alle Werte aus `config.lua`

---

## 13. Unterschied: Admin-Panel vs. config.lua

| Was | config.lua | Admin-Panel |
|---|---|---|
| **Permanente Grundkonfiguration** | ✅ Hier einrichten | ❌ Nicht geeignet |
| **Job-Namen (admin/doj)** | ✅ Hier eintragen | ❌ Nicht änderbar |
| **Standorte und Koordinaten** | ✅ Hier eintragen | Nur ansehen |
| **Module an-/ausschalten** | ✅ möglich | ✅ Live, ohne Neustart |
| **Rang-Berechtigungen** | ✅ möglich | ✅ Live, ohne Neustart |
| **Webhook-URLs** | ✅ möglich | ✅ Live, ohne Neustart |
| **Formulare erstellen** | ✅ möglich | ✅ über Formular-Editor |
| **Anträge verwalten** | ❌ | ✅ Über Admin-Ops |
| **Audit-Logs lesen** | ❌ | ✅ im Audit-Tab |

> **Faustregel:** Alles, was sich öfter ändert (Module, Berechtigungen, Webhooks), im **Admin-Panel** ändern.  
> Alles, was grundlegend ist und sich selten ändert (Job-Namen, Koordinaten), in der **config.lua** festlegen.

---

## 14. Häufige Fragen zum Admin-Panel

### Ich sehe keinen Admin-Bereich im Portal

**Mögliche Ursachen:**
1. Du hast nicht den Admin-Job auf deinem Server
2. `Config.Module.AdminUI = false` in der `config.lua`
3. Dein Rang (`Grade`) des Admin-Jobs liegt unter `Config.Kern.Admin.MinGrade`

**Lösung:**
1. Im Spiel prüfen: `/job` oder `setjob admin 0` (je nach Server)
2. In `config.lua` prüfen: `Config.Module.AdminUI = true`
3. `Config.Kern.Admin.MinGrade = 0` setzen (0 = alle Ränge)

### Ich kann keine Formulare veröffentlichen

**Ursache:** Du hast nicht die Berechtigung `form_editor.publish`.

**Lösung:**
1. Im Admin-Panel → JobSettings → deinen Job → deinen Rang
2. `form_editor.publish` erlauben
3. Speichern

### Änderungen im Admin-Panel werden nach Serverneustart zurückgesetzt

**Ursache:** Das passiert **nicht** – Änderungen werden in `data/admin_overrides.json` gespeichert und bleiben erhalten.

Wenn Änderungen doch verloren gehen: Prüfe, ob die Datei `data/admin_overrides.json` existiert und ob das Script Schreibrechte auf den `data/`-Ordner hat.

### Der Hard-Delete-Button fehlt

**Ursache:** `Config.Archiv.HartLoeschen.Aktiviert = false` oder du hast nicht den Admin-Job.

**Lösung:** In `config.lua` prüfen: `Config.Archiv.HartLoeschen = { Aktiviert = true, NurAdmin = true, GrundPflicht = true }`

### Webhook-Test-Nachrichten kommen nicht an

**Mögliche Ursachen:**
1. Webhook-URL falsch oder abgelaufen
2. `Config.Module.Webhooks = false`
3. Discord-Channel hat keine Webhook-Berechtigung

**Lösung:**
1. Webhook-URL in Discord neu erstellen und aktualisieren
2. `Config.Module.Webhooks = true` prüfen
3. Discord: Kanaleinstellungen → Integrationen → Webhooks prüfen

---

> **Weiterführende Anleitungen:**
> - [Konfigurationsanleitung](CONFIG_GUIDE_DE.md) – config.lua Schritt für Schritt erklärt
> - [Beispiele & Troubleshooting](EXAMPLES_AND_TROUBLESHOOTING_DE.md) – Fertige Beispiel-Konfigurationen
> - [Vollständige Config-Referenz](CONFIG_REFERENCE.md) – Technische Referenz aller Optionen
