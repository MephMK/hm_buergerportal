-- =============================================================
-- server/dienste/delegation_service.lua
-- PR3 – Delegation / Stellvertretung + Vollmacht
--
-- Funktionen:
--   OnlineSpielerSuchen(name)         → Liste online Spieler (Ingame-Name-Suche)
--   VollmachtPruefen(typ, auftraggeber_identifier, bevollmaechtigter_identifier)
--   VollmachtAnlegen(akteur, typ, auftraggeber_identifier, auftraggeber_name,
--                    bevollmaechtigter_identifier, bevollmaechtigter_name)
--   VollmachtWiderrufen(akteur, vollmacht_id)
--   VollmachtenListen(filter)
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local DelegationService = {}

-- ----------------------------------------------------------------
-- Hilfs-Funktion: ESX laden
-- ----------------------------------------------------------------
local ESX = nil
local function esxSicherstellen()
  if ESX ~= nil then return ESX end
  local ok, obj = pcall(function()
    return exports["es_extended"]:getSharedObject()
  end)
  if ok then ESX = obj end
  return ESX
end

-- ----------------------------------------------------------------
-- OnlineSpielerSuchen
--   Gibt alle aktuell online Spieler zurück, die den
--   gesuchten Ingame-Namen (GetPlayerName) enthalten.
--   Ergebnis: Liste von { source, name }
--   Bei mehreren Spielern mit gleichem Namen wird die source-ID
--   als Differenzierungsmerkmal mitgegeben (keine Identifier-Leak).
-- ----------------------------------------------------------------
function DelegationService.OnlineSpielerSuchen(suchname)
  suchname = (suchname or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if suchname == "" then return {} end

  local max  = (Config.Delegation and Config.Delegation.MaxSuchergebnisse) or 20
  local esx = esxSicherstellen()
  local ergebnisse = {}

  if esx then
    local spieler = esx.GetPlayers()
    for _, src in ipairs(spieler) do
      local ok, name = pcall(GetPlayerName, src)
      if ok and name and name ~= "" then
        if name:lower():find(suchname, 1, true) then
          table.insert(ergebnisse, { source = src, name = name })
          if #ergebnisse >= max then break end
        end
      end
    end
  else
    -- Fallback ohne ESX: rohe FiveM-API
    local playerList = GetPlayers()
    for _, src in ipairs(playerList) do
      local src_num = tonumber(src)
      if src_num and src_num > 0 then
        local ok, name = pcall(GetPlayerName, src_num)
        if ok and name and name ~= "" then
          if name:lower():find(suchname, 1, true) then
            table.insert(ergebnisse, { source = src_num, name = name })
            if #ergebnisse >= max then break end
          end
        end
      end
    end
  end

  return ergebnisse
end

-- ----------------------------------------------------------------
-- SpielerDurchSource
--   Gibt { identifier, name } für eine bestimmte source zurück,
--   nur wenn dieser Spieler tatsächlich online ist.
-- ----------------------------------------------------------------
function DelegationService.SpielerDurchSource(src)
  src = tonumber(src)
  if not src or src <= 0 then return nil end

  local ok, name = pcall(GetPlayerName, src)
  if not ok or not name or name == "" then return nil end

  local identifier = nil
  local esx = esxSicherstellen()
  if esx then
    local ok2, xPlayer = pcall(esx.GetPlayerFromId, src)
    if ok2 and xPlayer then
      identifier = xPlayer.identifier
    end
  end

  if not identifier then return nil end

  return { source = src, name = name, identifier = identifier }
end

-- ----------------------------------------------------------------
-- VollmachtPruefen
--   Prüft, ob für das Paar (auftraggeber, bevollmaechtigter)
--   eine aktive Vollmacht vom korrekten Typ vorliegt.
--   Wird nur geprüft wenn Config.Delegation.Vollmacht.Aktiviert = true.
--   Gibt true/false zurück.
-- ----------------------------------------------------------------
function DelegationService.VollmachtPruefen(typ, auftraggeber_identifier, bevollmaechtigter_identifier)
  -- Feature Guard
  if not (Config.Delegation and Config.Delegation.Vollmacht and Config.Delegation.Vollmacht.Aktiviert) then
    return true
  end
  if not typ or not auftraggeber_identifier or not bevollmaechtigter_identifier then
    return false
  end

  local row = HM_BP.Server.Datenbank.Einzel([[
    SELECT id FROM hm_bp_vollmachten
    WHERE vollmacht_typ = ?
      AND auftraggeber_identifier = ?
      AND bevollmaechtigter_identifier = ?
      AND aktiv = 1
    LIMIT 1
  ]], { typ, auftraggeber_identifier, bevollmaechtigter_identifier })

  return row ~= nil
end

-- ----------------------------------------------------------------
-- VollmachtAnlegen
--   Legt eine neue Vollmacht an. Erfordert vollmacht.manage-Recht.
--   typ: 'buerger_anwalt' oder 'firma_vertreter'
-- ----------------------------------------------------------------
function DelegationService.VollmachtAnlegen(akteur, typ, auftraggeber_identifier, auftraggeber_name, bevollmaechtigter_identifier, bevollmaechtigter_name)
  if not akteur then
    return nil, { nachricht = "Nicht authentifiziert." }
  end
  if not typ or typ == "" then
    return nil, { nachricht = "Vollmacht-Typ fehlt." }
  end
  if typ ~= "buerger_anwalt" and typ ~= "firma_vertreter" then
    return nil, { nachricht = "Ungültiger Vollmacht-Typ. Erlaubt: buerger_anwalt, firma_vertreter." }
  end
  if not auftraggeber_identifier or auftraggeber_identifier == "" then
    return nil, { nachricht = "Auftraggeber-Bezeichner fehlt." }
  end
  if not auftraggeber_name or auftraggeber_name == "" then
    return nil, { nachricht = "Auftraggeber-Name fehlt." }
  end
  if not bevollmaechtigter_identifier or bevollmaechtigter_identifier == "" then
    return nil, { nachricht = "Bevollmächtigter-Bezeichner fehlt." }
  end
  if not bevollmaechtigter_name or bevollmaechtigter_name == "" then
    return nil, { nachricht = "Bevollmächtigter-Name fehlt." }
  end
  if auftraggeber_identifier == bevollmaechtigter_identifier then
    return nil, { nachricht = "Auftraggeber und Bevollmächtigter dürfen nicht identisch sein." }
  end

  -- Prüfe ob bereits aktiv vorhanden
  local existing = HM_BP.Server.Datenbank.Einzel([[
    SELECT id FROM hm_bp_vollmachten
    WHERE vollmacht_typ = ?
      AND auftraggeber_identifier = ?
      AND bevollmaechtigter_identifier = ?
      AND aktiv = 1
    LIMIT 1
  ]], { typ, auftraggeber_identifier, bevollmaechtigter_identifier })

  if existing then
    return nil, { nachricht = "Eine aktive Vollmacht für dieses Paar existiert bereits." }
  end

  local inserted = HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_vollmachten
      (vollmacht_typ, auftraggeber_identifier, auftraggeber_name,
       bevollmaechtigter_identifier, bevollmaechtigter_name,
       erteilt_von_identifier, erteilt_von_name, aktiv)
    VALUES (?, ?, ?, ?, ?, ?, ?, 1)
  ]], {
    typ,
    auftraggeber_identifier,
    auftraggeber_name,
    bevollmaechtigter_identifier,
    bevollmaechtigter_name,
    akteur.identifier,
    akteur.name or akteur.identifier,
  })

  if not inserted or inserted < 1 then
    return nil, { nachricht = "Vollmacht konnte nicht gespeichert werden." }
  end

  local row = HM_BP.Server.Datenbank.Einzel(
    "SELECT id FROM hm_bp_vollmachten WHERE erteilt_von_identifier = ? ORDER BY id DESC LIMIT 1",
    { akteur.identifier }
  )
  local newId = row and row.id or nil

  -- Audit
  if HM_BP.Server.Dienste.AuditService then
    HM_BP.Server.Dienste.AuditService.Log(
      "vollmacht.angelegt",
      akteur,
      "vollmacht",
      tostring(newId or "?"),
      {
        typ                         = typ,
        auftraggeber_identifier     = auftraggeber_identifier,
        auftraggeber_name           = auftraggeber_name,
        bevollmaechtigter_identifier= bevollmaechtigter_identifier,
        bevollmaechtigter_name      = bevollmaechtigter_name,
      }
    )
  end

  return { id = newId, nachricht = "Vollmacht erfolgreich angelegt." }, nil
end

-- ----------------------------------------------------------------
-- VollmachtWiderrufen
--   Setzt eine Vollmacht auf inaktiv.
-- ----------------------------------------------------------------
function DelegationService.VollmachtWiderrufen(akteur, vollmacht_id)
  if not akteur then
    return nil, { nachricht = "Nicht authentifiziert." }
  end
  vollmacht_id = tonumber(vollmacht_id)
  if not vollmacht_id then
    return nil, { nachricht = "Vollmacht-ID ungültig." }
  end

  local row = HM_BP.Server.Datenbank.Einzel(
    "SELECT id, vollmacht_typ, auftraggeber_name, bevollmaechtigter_name FROM hm_bp_vollmachten WHERE id = ? AND aktiv = 1",
    { vollmacht_id }
  )
  if not row then
    return nil, { nachricht = "Vollmacht nicht gefunden oder bereits widerrufen." }
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    UPDATE hm_bp_vollmachten
    SET aktiv = 0,
        widerrufen_at = UTC_TIMESTAMP(),
        widerrufen_von_identifier = ?,
        widerrufen_von_name = ?
    WHERE id = ?
  ]], { akteur.identifier, akteur.name or akteur.identifier, vollmacht_id })

  -- Audit
  if HM_BP.Server.Dienste.AuditService then
    HM_BP.Server.Dienste.AuditService.Log(
      "vollmacht.widerrufen",
      akteur,
      "vollmacht",
      tostring(vollmacht_id),
      {
        vollmacht_typ         = row.vollmacht_typ,
        auftraggeber_name     = row.auftraggeber_name,
        bevollmaechtigter_name= row.bevollmaechtigter_name,
      }
    )
  end

  return { nachricht = "Vollmacht widerrufen." }, nil
end

-- ----------------------------------------------------------------
-- VollmachtenListen
--   Gibt alle Vollmachten zurück (aktiv + widerrufen), gefiltert
--   nach optionalem Typ.
-- ----------------------------------------------------------------
function DelegationService.VollmachtenListen(filter)
  filter = filter or {}
  local typ = filter.typ
  local nur_aktiv = filter.nur_aktiv ~= false -- default true

  local sql = [[
    SELECT id, vollmacht_typ, auftraggeber_name, bevollmaechtigter_name,
           erteilt_von_name, aktiv, erstellt_at, widerrufen_at, widerrufen_von_name
    FROM hm_bp_vollmachten
  ]]
  local params = {}
  local where_parts = {}

  if nur_aktiv then
    table.insert(where_parts, "aktiv = 1")
  end
  if typ and typ ~= "" then
    table.insert(where_parts, "vollmacht_typ = ?")
    table.insert(params, typ)
  end

  if #where_parts > 0 then
    sql = sql .. " WHERE " .. table.concat(where_parts, " AND ")
  end

  sql = sql .. " ORDER BY erstellt_at DESC LIMIT 500"

  local rows = HM_BP.Server.Datenbank.Alle(sql, params) or {}
  return rows
end

HM_BP.Server.Dienste.DelegationService = DelegationService
