HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ===========================================================================
-- LedgerService – Zahlungs-Ledger (PR4)
--
-- Schreibt jeden Zahlungsvorgang (Abbuchung, Einzahlung, Rückerstattung,
-- Befreiung) in die Tabelle hm_bp_zahlungs_ledger.
--
-- Öffentliche API:
--   LedgerService.Eintragen(params)
--     params: { antrag_id, public_id, citizen_identifier, actor_name,
--               typ, betrag_eur, status, metadata }
--     typ:    "debit" | "credit" | "refund" | "exempt"
--     status: "success" | "failed"
--   LedgerService.FuerAntrag(antragId) → Liste der Einträge
-- ===========================================================================

local LedgerService = {}

--- Schreibt einen Ledger-Eintrag.
--- @param params table
---   antrag_id          number   – Interne Submission-ID
---   public_id          string   – Öffentliche Aktenzeichen-ID
---   citizen_identifier string   – Identifier des Bürgers (citizen)
---   actor_name         string   – Name des auslösenden Akteurs
---   typ                string   – "debit" | "credit" | "refund" | "exempt"
---   betrag_eur         number   – Betrag in ganzen Euro (>= 0)
---   status             string   – "success" | "failed"
---   metadata           table    – Beliebige Zusatzdaten (wird als JSON gespeichert)
function LedgerService.Eintragen(params)
  if type(params) ~= "table" then return end

  local antragId          = tonumber(params.antrag_id)
  local publicId          = tostring(params.public_id or "")
  local citizenIdentifier = tostring(params.citizen_identifier or "")
  local actorName         = tostring(params.actor_name or "")
  local typ               = tostring(params.typ or "debit")
  local betragEur         = math.max(0, math.floor(tonumber(params.betrag_eur) or 0))
  local status            = tostring(params.status or "success")
  local metadata          = type(params.metadata) == "table" and json.encode(params.metadata) or "{}"

  if not antragId or antragId <= 0 then return end

  pcall(function()
    HM_BP.Server.Datenbank.Ausfuehren([[
      INSERT INTO hm_bp_zahlungs_ledger
        (antrag_id, public_id, citizen_identifier, actor_name, typ, betrag_eur, status, metadata)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], { antragId, publicId, citizenIdentifier, actorName, typ, betragEur, status, metadata })
  end)
end

--- Gibt alle Ledger-Einträge für einen Antrag zurück.
--- @param antragId number
--- @return table[] – Liste der Einträge (oder leere Liste bei Fehler)
function LedgerService.FuerAntrag(antragId)
  antragId = tonumber(antragId)
  if not antragId or antragId <= 0 then return {} end

  local rows = {}
  pcall(function()
    rows = HM_BP.Server.Datenbank.Alle([[
      SELECT id, antrag_id, public_id, citizen_identifier, actor_name,
             typ, betrag_eur, status, metadata, created_at
      FROM hm_bp_zahlungs_ledger
      WHERE antrag_id = ?
      ORDER BY created_at ASC
    ]], { antragId }) or {}
  end)
  return rows
end

HM_BP.Server.Dienste.LedgerService = LedgerService
