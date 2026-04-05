HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

local Middleware = {}

function Middleware.SpielerKontext(quelle)
  local spieler, err = HM_BP.Server.Dienste.AuthService.SpielerLaden(quelle)
  if not spieler then return nil, err end

  local rolle = HM_BP.Server.Dienste.AuthService.RolleErmitteln(spieler)
  spieler.rolle = rolle

  return spieler, nil
end

function Middleware.PruefeRecht(quelle, aktion, kontext)
  local spieler, err = Middleware.SpielerKontext(quelle)
  if not spieler then return nil, err end

  local okRL, errRL = HM_BP.Server.Dienste.AntiSpamService.PruefeRateLimit(spieler, "api:" .. tostring(aktion))
  if not okRL then return nil, errRL end

  local ok, err2 = HM_BP.Server.Dienste.PermissionService.Hat(spieler, aktion, kontext)
  if not ok then return nil, err2 end

  return spieler, nil
end

HM_BP.Server.Middleware = Middleware