HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local KategorieService = {}

local function kategorieErlaubtFuerStandort(kategorieId, standort)
  if not standort or not standort.zugriff then return true end
  local erlaubte = standort.zugriff.erlaubteKategorien
  if type(erlaubte) ~= "table" then return true end
  if #erlaubte == 0 then return true end
  for _, id in ipairs(erlaubte) do
    if id == kategorieId then return true end
  end
  return false
end

local function jobIstErlaubt(jobName, erlaubteJobs)
  if type(erlaubteJobs) ~= "table" or #erlaubteJobs == 0 then
    return true
  end
  for _, j in ipairs(erlaubteJobs) do
    if j == jobName then return true end
  end
  return false
end

function KategorieService.ListeSichtbarFuer(spieler, standortId)
  local rolle = spieler.rolle or HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  local standort = nil
  if standortId and Config.Standorte and Config.Standorte.Liste then
    standort = Config.Standorte.Liste[standortId]
  end

  local ergebnis = {}

  if not (Config.Kategorien and Config.Kategorien.Aktiviert and Config.Kategorien.Liste) then
    return ergebnis
  end

  for kId, k in pairs(Config.Kategorien.Liste) do
    if k and k.aktiv == true then
      -- Standortfilter
      if kategorieErlaubtFuerStandort(kId, standort) then
        -- Bürger-Sichtbarkeit
        if rolle == "buerger" and k.fuerBuergerSichtbar ~= true then
          goto weiter
        end

        -- Job/Grad Einschränkung (für Justiz/Admin meist egal, aber konfigurierbar)
        if rolle ~= "buerger" then
          if not jobIstErlaubt(spieler.job.name, k.erlaubteJobs) then
            goto weiter
          end
          if k.erlaubterMindestGrad ~= nil and spieler.job.grade < tonumber(k.erlaubterMindestGrad) then
            goto weiter
          end
        end

        table.insert(ergebnis, {
          id = k.id,
          name = k.name,
          beschreibung = k.beschreibung,
          icon = k.icon,
          sortierung = k.sortierung or 999,
          farbe = (k.ui and k.ui.farbe) or "#2f80ed"
        })
      end
    end
    ::weiter::
  end

  table.sort(ergebnis, function(a, b)
    if a.sortierung == b.sortierung then
      return tostring(a.name) < tostring(b.name)
    end
    return (a.sortierung or 999) < (b.sortierung or 999)
  end)

  return ergebnis
end

HM_BP.Server.Dienste.KategorieService = KategorieService