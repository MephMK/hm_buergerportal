HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local StatusService = {}

local function boolOr(v, fallback)
  if v == nil then return fallback end
  return v == true
end

function StatusService.StatusListeFuerKategorie(kategorieId)
  local liste = {}

  if not (Config.Status and Config.Status.Aktiviert and Config.Status.Liste) then
    return liste
  end

  local erlaubte = nil
  local k = Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]
  if k and type(k.erlaubteStatus) == "table" and #k.erlaubteStatus > 0 then
    erlaubte = {}
    for _, s in ipairs(k.erlaubteStatus) do erlaubte[s] = true end
  end

  for _, s in pairs(Config.Status.Liste) do
    if s and s.id then
      if (erlaubte == nil) or (erlaubte[s.id] == true) then
        table.insert(liste, {
          id = s.id,
          label = s.label,
          farbe = s.farbe,
          sortierung = s.sortierung or 999,

          -- NEU: Status-Metadaten (kompatibel: Defaults greifen, wenn nicht in Config gesetzt)
          sichtbarFuerBuerger = boolOr(s.sichtbarFuerBuerger, true),
          sichtbarFuerJustiz = boolOr(s.sichtbarFuerJustiz, true),
          bearbeitbar = boolOr(s.bearbeitbar, false),

          erlaubtBuergerAntwort = boolOr(s.erlaubtBuergerAntwort, false),
          erlaubtNachreichung = boolOr(s.erlaubtNachreichung, false),
          erlaubtInterneNotiz = boolOr(s.erlaubtInterneNotiz, true),

          erlaubteFolgeStatus = s.erlaubteFolgeStatus -- kann nil sein (dann keine Prüfung)
        })
      end
    end
  end

  table.sort(liste, function(a, b)
    return (a.sortierung or 999) < (b.sortierung or 999)
  end)

  return liste
end

HM_BP.Server.Dienste.StatusService = StatusService