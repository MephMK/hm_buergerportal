HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ---------------------------------------------------------------
-- BenachrichtigungService
-- Sendet serverseitig Ingame-Benachrichtigungen an Spieler.
-- Nachrichten werden über TriggerClientEvent ausgeliefert.
-- Alle Texte sind über Config.Benachrichtigungen.Texte konfigurierbar.
-- ---------------------------------------------------------------

local BenachrichtigungService = {}

local function cfgBenach()
  return (Config and Config.Benachrichtigungen) or { Aktiviert = false }
end

local function istAktiviert()
  local c = cfgBenach()
  if c.Aktiviert ~= true then return false end
  if c.Ingame and c.Ingame.Aktiviert == false then return false end
  if Config.Module and Config.Module.Benachrichtigungen == false then return false end
  return true
end

local function getText(schluessel, ersatz)
  local c = cfgBenach()
  local texte = c.Texte or {}
  return texte[schluessel] or ersatz or schluessel
end

-- Sucht einen online Spieler anhand seines Identifiers.
-- Greift direkt auf ESX zu, da ein Rückweg (identifier→source) in SpielerService nicht vorhanden ist.
local function findeOnlineSpielerQuelle(identifier)
  if not identifier or identifier == "" then return nil end
  local esx = nil
  local ok, obj = pcall(function()
    return exports['es_extended']:getSharedObject()
  end)
  if ok then esx = obj end
  if esx then
    local players = esx.GetPlayers()
    for _, src in ipairs(players) do
      local xPlayer = esx.GetPlayerFromId(src)
      if xPlayer and xPlayer.identifier == identifier then
        return src
      end
    end
  end
  return nil
end

--- Sendet eine Ingame-Benachrichtigung an einen Spieler (per Identifier).
--- @param identifier string  – Spieler-Identifier (license:...)
--- @param nachricht  string  – Anzuzeigende Nachricht
--- @param typ        string  – Typ: "info"|"success"|"warning"|"error" (optional)
function BenachrichtigungService.AnSpieler(identifier, nachricht, typ)
  if not istAktiviert() then return end
  if not identifier or not nachricht then return end

  local quelle = findeOnlineSpielerQuelle(identifier)
  if not quelle then return end -- Spieler offline, kein Fehler

  TriggerClientEvent("hm_bp:benachrichtigung:ingame", quelle, {
    nachricht = tostring(nachricht),
    typ       = typ or "info",
  })
end

--- Sendet eine Ingame-Benachrichtigung direkt an eine Server-Quell-ID.
--- @param quelle    number  – Server source
--- @param nachricht string  – Anzuzeigende Nachricht
--- @param typ       string  – Typ (optional)
function BenachrichtigungService.AnQuelle(quelle, nachricht, typ)
  if not istAktiviert() then return end
  local src = tonumber(quelle)
  if not src or src <= 0 then return end

  TriggerClientEvent("hm_bp:benachrichtigung:ingame", src, {
    nachricht = tostring(nachricht),
    typ       = typ or "info",
  })
end

--- Benachrichtigt den Bürger über Statuswechsel seines Antrags.
function BenachrichtigungService.StatusGeaendert(identifier, publicId, alterStatus, neuerStatus)
  if not istAktiviert() then return end
  local vorlage = getText("status_geaendert", "Dein Antrag {id} wurde auf Status '{status}' gesetzt.")
  local msg = vorlage
    :gsub("{id}",     tostring(publicId    or ""))
    :gsub("{status}", tostring(neuerStatus or ""))
    :gsub("{alt}",    tostring(alterStatus or ""))
  BenachrichtigungService.AnSpieler(identifier, msg, "info")
end

--- Benachrichtigt den Bürger, dass eine Rückfrage gestellt wurde.
function BenachrichtigungService.RueckfrageGestellt(identifier, publicId)
  if not istAktiviert() then return end
  local vorlage = getText("rueckfrage_gestellt", "Zum Antrag {id} wurde eine Rückfrage gestellt. Bitte beantworte diese.")
  local msg = vorlage:gsub("{id}", tostring(publicId or ""))
  BenachrichtigungService.AnSpieler(identifier, msg, "warning")
end

--- Benachrichtigt den Bürger über eine öffentliche Antwort.
function BenachrichtigungService.OeffentlicheAntwort(identifier, publicId)
  if not istAktiviert() then return end
  local vorlage = getText("oeffentliche_antwort", "Zu deinem Antrag {id} gibt es eine neue Nachricht der Behörde.")
  local msg = vorlage:gsub("{id}", tostring(publicId or ""))
  BenachrichtigungService.AnSpieler(identifier, msg, "info")
end

--- Benachrichtigt den Bürger, dass sein Antrag genehmigt wurde.
function BenachrichtigungService.AntragGenehmigt(identifier, publicId)
  if not istAktiviert() then return end
  local vorlage = getText("antrag_genehmigt", "Dein Antrag {id} wurde genehmigt.")
  local msg = vorlage:gsub("{id}", tostring(publicId or ""))
  BenachrichtigungService.AnSpieler(identifier, msg, "success")
end

--- Benachrichtigt den Bürger, dass sein Antrag abgelehnt wurde.
function BenachrichtigungService.AntragAbgelehnt(identifier, publicId)
  if not istAktiviert() then return end
  local vorlage = getText("antrag_abgelehnt", "Dein Antrag {id} wurde abgelehnt.")
  local msg = vorlage:gsub("{id}", tostring(publicId or ""))
  BenachrichtigungService.AnSpieler(identifier, msg, "error")
end

--- Benachrichtigt den Bürger über Eingang seiner Einreichung.
function BenachrichtigungService.AntragEingereicht(quelle, publicId, formularName)
  if not istAktiviert() then return end
  local vorlage = getText("antrag_eingereicht", "Dein Antrag wurde unter Aktenzeichen {id} erfolgreich eingereicht.")
  local msg = vorlage
    :gsub("{id}",      tostring(publicId    or ""))
    :gsub("{formular}", tostring(formularName or ""))
  BenachrichtigungService.AnQuelle(quelle, msg, "success")
end

HM_BP.Server.Dienste.BenachrichtigungService = BenachrichtigungService
