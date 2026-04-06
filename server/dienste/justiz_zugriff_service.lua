HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local JustizZugriffService = {}

local function gradeInListe(grad, liste)
  if type(liste) ~= "table" then return false end
  for _, g in ipairs(liste) do
    if tonumber(g) == tonumber(grad) then return true end
  end
  return false
end

local function tiefKopie(t)
  if HM_BP.Gemeinsam and HM_BP.Gemeinsam.Hilfsfunktionen and HM_BP.Gemeinsam.Hilfsfunktionen.TiefKopie then
    return HM_BP.Gemeinsam.Hilfsfunktionen.TiefKopie(t)
  end
  -- Fallback: lokale Tiefkopie, falls das gemeinsame Hilfsmodul noch nicht geladen ist
  if type(t) ~= "table" then return t end
  local kopie = {}
  for k, v in pairs(t) do
    kopie[tiefKopie(k)] = tiefKopie(v)
  end
  return setmetatable(kopie, getmetatable(t))
end

function JustizZugriffService.KategorieRegelnFuer(spieler, kategorieId)
  -- Admin: alles
  if HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return {
      erlaubt = true,
      sehen = { eingang = true, zugewiesen = true, alleKategorie = true, archiv = true },
      aktionen = {
        antragUebernehmen = true,
        statusAendern = true,
        prioritaetAendern = true,
        interneNotizSchreiben = true,
        oeffentlicheAntwortSchreiben = true,
        rueckfrageStellen = true,
        zuweisen = true,
        genehmigen = true,
        ablehnen = true,
        weiterleiten = true,
        eskalieren = true,
        archivieren = true,
        loeschen = true
      }
    }
  end

  -- nur DOJ im Justizzugriff
  if not HM_BP.Server.Dienste.AuthService.IstJustiz(spieler) then
    return { erlaubt = false, grund = "Nicht Justiz." }
  end

  local k = Config.Kategorien and Config.Kategorien.Liste and Config.Kategorien.Liste[kategorieId]
  if not k or k.aktiv ~= true then
    return { erlaubt = false, grund = "Kategorie nicht gefunden oder deaktiviert." }
  end

  local zugriff = k.zugriff and k.zugriff.justiz
  if not zugriff then
    return { erlaubt = false, grund = "Kategorie hat keine Justiz-Zugriffsregeln." }
  end

  if zugriff.job and zugriff.job ~= spieler.job.name then
    return { erlaubt = false, grund = "Falscher Job für diese Kategorie." }
  end

  local grad = spieler.job.grade
  if not gradeInListe(grad, zugriff.erlaubteGrade) then
    return { erlaubt = false, grund = "Dein Jobgrad hat keinen Zugriff auf diese Kategorie." }
  end

  -- Fallback-Regeln anwenden
  local basis = tiefKopie(Config.JustizFallback or { sehen = {}, aktionen = {} })

  -- Grade-spezifisch überschreiben, wenn vorhanden
  if zugriff.aktionenProGrade and zugriff.aktionenProGrade[grad] then
    local gRegel = zugriff.aktionenProGrade[grad]
    if gRegel.sehen then
      for k2, v2 in pairs(gRegel.sehen) do basis.sehen[k2] = v2 end
    end
    if gRegel.aktionen then
      for k2, v2 in pairs(gRegel.aktionen) do basis.aktionen[k2] = v2 end
    end
  end

  return {
    erlaubt = true,
    sehen = basis.sehen or {},
    aktionen = basis.aktionen or {}
  }
end

function JustizZugriffService.SichtbareJustizKategorien(spieler)
  local liste = {}

  if not (Config.Kategorien and Config.Kategorien.Aktiviert and Config.Kategorien.Liste) then
    return liste
  end

  for kId, k in pairs(Config.Kategorien.Liste) do
    if k and k.aktiv == true then
      local regeln = JustizZugriffService.KategorieRegelnFuer(spieler, kId)
      if regeln and regeln.erlaubt == true then
        table.insert(liste, {
          id = kId,
          name = k.name,
          beschreibung = k.beschreibung,
          farbe = (k.ui and k.ui.farbe) or "#2f80ed",
          sehen = regeln.sehen,
          aktionen = regeln.aktionen
        })
      end
    end
  end

  table.sort(liste, function(a, b)
    return tostring(a.name) < tostring(b.name)
  end)

  return liste
end

HM_BP.Server.Dienste.JustizZugriffService = JustizZugriffService