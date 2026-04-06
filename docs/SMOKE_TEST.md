# Smoke-Test Checkliste – hm_buergerportal

Schritt-für-Schritt-Checkliste zur manuellen Überprüfung aller Haupt-Flows nach einer (Neu-)Installation oder nach größeren Config-Änderungen.

> **Hinweis:** Alle Tests werden **Ingame** auf einem Testserver durchgeführt.  
> Voraussetzung: Server läuft, alle Migrationen sind durchgelaufen, mindestens 1 Bürger- und 1 Justiz-/Admin-Account vorhanden.

---

## Vorbereitung

- [ ] Server gestartet, keine Fehler im Konsolenlog
- [ ] `hm_bp_migrations`-Tabelle enthält Einträge v1–v19
- [ ] Mindestens ein Spieler mit Job `doj` (Justiz) verfügbar
- [ ] Mindestens ein Spieler mit Job `admin` verfügbar
- [ ] Bürger-Test-Account verfügbar (kein Justiz-/Admin-Job)

---

## Test 1 – Bürger-Flow (Basis)

**Ziel:** Antrag einreichen, Liste anzeigen, Rückfrage beantworten.

- [ ] Als **Bürger** zum Standort `doj_frontdesk_1` gehen und `[E]` drücken
- [ ] Bürgerportal öffnet sich (keine Fehlermeldung im UI)
- [ ] Kategorie „Allgemein" ist sichtbar
- [ ] Formular auswählen, alle Pflichtfelder ausfüllen
- [ ] Formular einreichen → Bestätigung erscheint, Aktenzeichen (z.B. `HM-DOJ-YYYY-MM-000001`) angezeigt
- [ ] Ingame-Benachrichtigung erscheint: „Dein Antrag wurde unter Aktenzeichen ... eingereicht."
- [ ] In „Meine Anträge" ist der Antrag mit Status „Eingereicht" sichtbar
- [ ] Antrag öffnen → Bürger sieht Antragsdaten, aber keine internen Notizen

---

## Test 2 – Justiz-Flow (Basis)

**Ziel:** Antrag bearbeiten, Status ändern, Rückfrage stellen.

- [ ] Als **Justiz** zum Standort `doj_intern_1` gehen
- [ ] Justiz-Portal öffnet sich (Eingangs-Queue sichtbar)
- [ ] Neuer Antrag aus Test 1 erscheint in der Eingangs-Queue
- [ ] Antrag übernehmen (Lock erscheint, andere Justiz-Bearbeiter werden blockiert)
- [ ] Status auf „In Prüfung" setzen → Bürger erhält Ingame-Benachrichtigung
- [ ] Interne Notiz schreiben → Notiz ist für Bürger **nicht** sichtbar
- [ ] Öffentliche Antwort schreiben → Bürger sieht Antwort in seiner Antrag-Detailansicht
- [ ] Rückfrage stellen → Status wechselt zu „Rückfrage offen"
- [ ] **Als Bürger:** Auf Rückfrage antworten
- [ ] **Als Justiz:** Antrag wieder übernehmen, Status auf „In Prüfung" setzen

---

## Test 3 – Statuswechsel & Abschluss

**Ziel:** Terminale Status (Genehmigen/Ablehnen) testen.

- [ ] Antrag auf „Genehmigt" setzen → Status wechselt, Webhook (falls konfiguriert) wird gesendet
- [ ] Bürger erhält Ingame-Benachrichtigung: „Dein Antrag ... wurde genehmigt."
- [ ] Antrag archivieren → Status „Archiviert"
- [ ] Archiv-Tab zeigt den archivierten Antrag
- [ ] Gesperrte Übergänge prüfen: Versuch, von „Archiviert" auf „In Prüfung" zu wechseln → Fehlermeldung erscheint

---

## Test 4 – Gebühren

> **Voraussetzung:** `Config.Module.Gebuehren = true`, Bezahlungs-Bibliothek (wasabi/esx) aktiv,  
> Formular mit `gebuehren.aktiv = true, betrag = 50` vorhanden.

### 4a – Zahlungsmodus „bei_entscheidung"

- [ ] `Config.Zahlung.Modus = "bei_entscheidung"` sicherstellen
- [ ] Als Bürger Antrag für gebührenpflichtiges Formular einreichen → **keine** Abbuchung bei Einreichung
- [ ] Als Justiz Antrag genehmigen → Abbuchung von 50 € vom Bürger-Konto
- [ ] Einzahlung auf Society-Konto (`society_justiz`) prüfen
- [ ] Discord-Webhook (`antrag_payments`): Embed „Gebühr abgezogen" erscheint (kein Identifier!)
- [ ] `hm_bp_zahlungs_ledger` in DB enthält Eintrag

### 4b – Zahlungsmodus „bei_einreichung"

- [ ] `Config.Zahlung.Modus = "bei_einreichung"` setzen, Server neu starten
- [ ] Als Bürger Antrag einreichen → Abbuchung **sofort** bei Einreichung
- [ ] Antrag ablehnen → keine weitere Abbuchung

### 4c – Gebührenbefreiung

- [ ] `Config.Zahlung.Befreiungen = { aktiv = true, rollen = { "richter" } }` setzen
- [ ] Spieler mit Job `richter` Antrag einreichen → keine Abbuchung
- [ ] Discord-Webhook (`antrag_payments`): Embed „Gebührenbefreiung" erscheint

### 4d – Rückerstattung (wenn aktiviert)

- [ ] `Config.Zahlung.Erstattungen = { aktiv = true, regeln = { { status = "rejected", prozent = 100 } } }` setzen
- [ ] Bürger Antrag einreichen (Modus `bei_einreichung` oder genehmigter Antrag)
- [ ] Antrag ablehnen → 100 % Rückerstattung wird ausgeführt
- [ ] Betrag auf Bürger-Konto wieder gutgeschrieben
- [ ] Discord-Webhook (`antrag_payments`): Embed „Rückerstattung" erscheint

---

## Test 5 – Integrationen (Folgeaktionen-Engine)

> **Voraussetzung:** `Config.Module.Integrationen = false` (Standard, Test 5a), dann aktivieren (Test 5b).

### 5a – Default OFF verifizieren

- [ ] `Config.Module.Integrationen = false` (Standard)
- [ ] Antrag genehmigen → **keine** Folgeaktion, keine Fehler im Konsolenlog
- [ ] `hm_bp_integration_flags` enthält keine neuen Einträge

### 5b – Integration aktivieren und testen

- [ ] `Config.Module.Integrationen = true` und `Config.Integrationen.Aktiviert = true` setzen
- [ ] Whitelist konfigurieren: `ErlaubteDBFlags = { "test_flag" }`
- [ ] An Testformular Integration hinzufügen:
  ```lua
  Config.Formulare.Liste["general_request"].integrationen = {
    on_approve = {
      { typ = "set_db_flag", schluessel = "test_flag", wert = "1" }
    }
  }
  ```
- [ ] Server neu starten
- [ ] Antrag einreichen und genehmigen
- [ ] `hm_bp_integration_flags` prüfen: Eintrag `test_flag = "1"` für die Antrag-ID vorhanden
- [ ] Konsolenlog: `integration.erfolgreich` Auditlog sichtbar
- [ ] Discord-Webhook (`integrationen`): Embed „Integration erfolgreich" erscheint (falls URL konfiguriert)

### 5c – Fehlerhaften Event testen (Whitelist-Schutz)

- [ ] Event **nicht** in `ErlaubteServerEvents` eintragen, aber trotzdem in Integration referenzieren
- [ ] Antrag genehmigen → Aktion schlägt fehl, aber Server stürzt **nicht** ab
- [ ] Konsolenlog: `integration.fehlgeschlagen` Auditlog sichtbar
- [ ] Discord-Webhook (`integrationen`): Embed „Integration fehlgeschlagen" erscheint

---

## Test 6 – Webhooks

> **Voraussetzung:** Discord-Webhook-URLs in `Config.Webhooks.Urls` konfiguriert.

- [ ] **Zahlungs-Webhook** (`antrag_payments`): Antrag mit Gebühr genehmigen → Embed erscheint in Discord
  - Kein Identifier (Steam/License/Discord-ID) im Embed
  - Ingame-Name + Aktenzeichen vorhanden
- [ ] **Eskalations-Webhook** (`antrag_escalation`): Warte bis SLA überschritten (oder `Config.SLA.ErsteBearbeitungStunden` auf 0.01 setzen) → Embed erscheint
- [ ] **Integrations-Webhook** (`integrationen`): Aus Test 5b/5c – Embed erscheint
- [ ] **Admin-Ops-Webhook** (`admin_ops`): Admin-Op aus Test 8 durchführen → Embed erscheint
- [ ] **Missbrauchsschutz-Webhook** (`missbrauch`): Aus Test 7 – Embed erscheint
- [ ] **Fallback-Webhook**: Event ohne spezifische URL → Fallback-Webhook erhält Nachricht (falls konfiguriert)

### Webhook-Log (optional)

- [ ] `Config.Webhooks.LogsInDB = true` setzen
- [ ] Webhook auslösen
- [ ] `hm_bp_webhook_logs` in DB enthält Eintrag mit Status `gesendet`

---

## Test 7 – Missbrauchsschutz

> **Voraussetzung:** `Config.AntiSpam.Aktiviert = true`.  
> **Standard OFF** – vor diesem Test explizit aktivieren.

### 7a – Globaler Cooldown

- [ ] `Config.AntiSpam.GlobalerCooldownSekunden = 30` setzen
- [ ] Als Bürger zwei Anträge innerhalb von 30 Sekunden einreichen
- [ ] Zweiter Antrag wird blockiert (Fehlermeldung erscheint, kein Absturz)
- [ ] Nach 30 Sekunden ist ein weiterer Antrag möglich

### 7b – Max. offene Anträge

- [ ] `Config.AntiSpam.MaxOffeneAntraegeProSpieler = 2` setzen
- [ ] Bürger stellt 3 offene Anträge → 3. Antrag wird blockiert
- [ ] Discord-Webhook (`missbrauch`): Embed erscheint

### 7c – Blacklist

- [ ] `Config.AntiSpam.Blackliste = { Aktiviert = true, Woerter = { "verboten" } }` setzen
- [ ] Antrag mit dem Wort „verboten" im Text einreichen
- [ ] Antrag wird blockiert, Embed in Discord (`missbrauch`) erscheint
- [ ] Audit-Log: `abuse.blockiert` Eintrag vorhanden

### 7d – Lockout (nach Fehlversuchen)

- [ ] `Config.AntiSpam.Lockout = { Aktiviert = true, MaxFehlversuche = 3, DauerSekunden = 60 }` setzen
- [ ] 3× Antrag mit Blacklist-Wort einreichen
- [ ] Nach 3 Versuchen: Spieler wird für 60 Sekunden ausgesperrt
- [ ] Weiterer Einreichungsversuch: Lockout-Meldung erscheint
- [ ] Discord-Webhook (`missbrauch`): Lockout-Embed erscheint
- [ ] Nach 60 Sekunden: Spieler kann wieder Anträge einreichen

---

## Test 8 – Admin-Ops

> **Voraussetzung:** Spieler mit Job `admin` verfügbar.

- [ ] Als Admin Admin-UI öffnen
- [ ] **Suche:** Admin sucht nach Bürger-Name → Treffer erscheinen kategorieübergreifend
- [ ] **Filter:** Nach Status „Genehmigt" filtern → nur genehmigte Anträge sichtbar
- [ ] **Verschieben:** Antrag in andere Kategorie verschieben → Webhook (`admin_ops`) erscheint in Discord
- [ ] **Status-Override:** Status direkt setzen (Workflow-Bypass) → Audit-Eintrag + Webhook erscheinen
- [ ] **Im Auftrag erstellen:** Admin erstellt Antrag für Bürger (Ingame-Name, kein Identifier) → Antrag sichtbar in Bürger-Queue
- [ ] **Wiederherstellen:** Archivierten Antrag wiederherstellen → Status zurück auf „Geschlossen"
- [ ] **Hard-Delete:** Antrag mit Grund löschen → Audit-Eintrag + Webhook (`admin_ops`) erscheinen, Antrag nicht mehr sichtbar

---

## Test 9 – Delegation (wenn aktiviert)

> **Voraussetzung:** `Config.Module.Delegation = true`.

- [ ] Als Bürger Portal öffnen → „Im Auftrag einreichen" sichtbar
- [ ] Online-Spieler suchen (Ingame-Name) → Suchergebnis erscheint (kein Identifier!)
- [ ] Antrag im Auftrag des gefundenen Spielers einreichen
- [ ] Antrag erscheint in der Justiz-Queue mit Delegations-Hinweis
- [ ] Als Justiz: „Hilfsantrag im Auftrag" erstellen → funktioniert (kein Vollmacht-Check wenn `Vollmacht.Aktiviert = false`)

---

## Test 10 – SLA und Eskalation

- [ ] `Config.SLA.ErsteBearbeitungStunden = 0.01` (ca. 36 Sekunden) setzen für schnellen Test
- [ ] Antrag einreichen, **nicht** bearbeiten
- [ ] Nach ca. 1 Minute: SLA-Überschreitung im Konsolenlog sichtbar
- [ ] Webhook (`antrag_escalation`): Eskalations-Embed in Discord erscheint (kein Identifier!)
- [ ] `due_state = "overdue"` in `hm_bp_submissions` für diesen Antrag prüfen
- [ ] `Config.SLA.ErsteBearbeitungStunden` auf normalen Wert zurücksetzen

---

## Test 11 – Sicherheitsprüfungen

- [ ] **Identifier-Check:** Alle Discord-Embeds manuell prüfen → kein Steam-Hex, License-Key, Discord-ID oder sonstiger Identifier vorhanden
- [ ] **Permission-Bypass:** Als Bürger versuchen, Admin-Endpoints aufzurufen → Server verweigert (Fehlermeldung, kein Absturz)
- [ ] **Lock-Bypass:** Zwei Justiz-Mitarbeiter gleichzeitig denselben Antrag öffnen → zweiter Bearbeiter wird blockiert
- [ ] **Ungültige Statusübergänge:** Von „Archiviert" auf „In Prüfung" setzen → Server verweigert den Übergang

---

## Test 12 – Audit-Log

- [ ] Als Admin Audit-Log öffnen
- [ ] Alle Aktionen aus den vorherigen Tests sind protokolliert
- [ ] Kein `actor_identifier` im Audit-Log sichtbar (nur Ingame-Name)
- [ ] Filter nach Aktion, Spieler, Zeitraum funktioniert

---

## Abschluss-Checkliste

- [ ] Keine JavaScript-Fehler in der Browser-Konsole (F8 in FiveM)
- [ ] Keine Lua-Fehler im Server-Log
- [ ] Alle Webhook-Embeds enthalten keine Identifier
- [ ] Alle Migrationen v1–v19 in `hm_bp_migrations` vorhanden
- [ ] Config-Änderungen aus Tests wieder auf Produktivwerte zurückgesetzt
