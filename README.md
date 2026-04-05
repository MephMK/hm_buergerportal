# hm_buergerportal

Modulares Bürgerportal / Antragssystem für FiveM (ESX, oxmysql, NUI) – vollständig auf Deutsch.

---

## Standorte / Locations

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
