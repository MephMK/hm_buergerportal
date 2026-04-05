HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AuthService = {}
local ESX = nil

local function esxSicherstellen()
  if ESX ~= nil then return ESX end
  ESX = exports['es_extended']:getSharedObject()
  return ESX
end

local function spielerObjekt(quelle)
  local esx = esxSicherstellen()
  if not esx then return nil end
  local xPlayer = esx.GetPlayerFromId(quelle)
  return xPlayer
end

function AuthService.SpielerLaden(quelle)
  local xPlayer = spielerObjekt(quelle)
  if not xPlayer then
    return nil, {
      code = HM_BP.Shared.Errors.NOT_AUTHENTICATED,
      nachricht = HM_BP.Shared.Texts.Errors.NOT_AUTHENTICATED
    }
  end

  local job = xPlayer.getJob and xPlayer.getJob() or nil
  local jobName = job and job.name or "unemployed"
  local jobGrad = job and (job.grade or 0) or 0
  local jobLabel = job and (job.label or jobName) or jobName
  local gradLabel = job and (job.grade_label or tostring(jobGrad)) or tostring(jobGrad)

  local identifier = xPlayer.identifier
  local name = xPlayer.getName and xPlayer.getName() or ("Spieler %s"):format(tostring(quelle))

  return {
    quelle = quelle,
    identifier = identifier,
    name = name,
    job = {
      name = jobName,
      grade = jobGrad,
      label = jobLabel,
      gradeLabel = gradLabel
    }
  }, nil
end

function AuthService.RolleErmitteln(spieler)
  if not spieler or not spieler.job or not spieler.job.name then
    return "buerger"
  end

  local adminJob = Config.Kern.Jobs.Admin
  local justizJob = Config.Kern.Jobs.Justiz

  if spieler.job.name == adminJob then return "admin" end
  if spieler.job.name == justizJob then return "justiz" end
  return "buerger"
end

function AuthService.IstAdmin(spieler)
  return AuthService.RolleErmitteln(spieler) == "admin"
end

function AuthService.IstJustiz(spieler)
  return AuthService.RolleErmitteln(spieler) == "justiz"
end

HM_BP.Server.Dienste.AuthService = AuthService