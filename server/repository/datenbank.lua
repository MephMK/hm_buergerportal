HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}

local Datenbank = {}

function Datenbank.Ausfuehren(sql, parameter)
  return MySQL.update.await(sql, parameter or {})
end

function Datenbank.Alle(sql, parameter)
  return MySQL.query.await(sql, parameter or {})
end

function Datenbank.Skalar(sql, parameter)
  return MySQL.scalar.await(sql, parameter or {})
end

function Datenbank.Einzel(sql, parameter)
  return MySQL.single.await(sql, parameter or {})
end

HM_BP.Server.Datenbank = Datenbank