HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ===========================================================================
-- PaymentService – Gebührenzahlung (PR14)
--
-- Abstraktion über Banking-Ressourcen:
--   Primär:   wasabi_banking  + wasabi_billing
--   Fallback: esx_banking     + esx_billing
--
-- Öffentliche API:
--   PaymentService.GebuehrAbbuchen(spieler, betragEur, antragInfo)
--     → { ok, abgezogen, eingezahlt, fehler }
-- ===========================================================================

local PaymentService = {}

-- -----------------------------------------------------------------------
-- Hilfsfunktionen
-- -----------------------------------------------------------------------

local function ressourceGestartet(name)
  return GetResourceState(name) == "started"
end

local function utcJetztIso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

-- -----------------------------------------------------------------------
-- Banking-Adapter: Abhebung vom Bürgerkonto
-- -----------------------------------------------------------------------

--- Hebt `betrag` (EUR, Ganzzahl > 0) vom Bankkonto von `spieler` ab.
--- Versucht wasabi_banking zuerst, dann esx_banking.
--- @param societyName  string  – Name des Society-Kontos (für esx_billing-Fallback)
--- @return ok boolean, fehlertext string|nil
local function bankAbheben(spieler, betrag, grund, societyName)
  local identifier = spieler.identifier
  local source      = tonumber(spieler.source)

  -- wasabi_banking (exports.wasabi_banking:removeBankMoney)
  if ressourceGestartet("wasabi_banking") then
    local ok = exports["wasabi_banking"]:removeBankMoney(source, betrag, grund)
    if ok then
      return true, nil
    end
    return false, "wasabi_banking: Abbuchung fehlgeschlagen (unzureichendes Guthaben oder Fehler)."
  end

  -- wasabi_billing als Sekundär (kann Bankkonten belasten)
  if ressourceGestartet("wasabi_billing") then
    local ok = exports["wasabi_billing"]:removeBankMoney(source, betrag, grund)
    if ok then
      return true, nil
    end
    return false, "wasabi_billing: Abbuchung fehlgeschlagen."
  end

  -- esx_banking
  if ressourceGestartet("esx_banking") then
    local ok = exports["esx_banking"]:removeBankMoney(identifier, betrag)
    if ok then
      return true, nil
    end
    return false, "esx_banking: Abbuchung fehlgeschlagen (unzureichendes Guthaben oder Fehler)."
  end

  -- esx_billing (Fallback über Rechnungssystem)
  -- HINWEIS: esx_billing ist fire-and-forget via TriggerEvent (keine Bestätigung möglich).
  -- Wird als Erfolg gewertet, auch wenn die Rechnung intern fehlschlägt.
  -- Nur nutzen wenn kein anderes Banking-System verfügbar ist.
  if ressourceGestartet("esx_billing") then
    local billSociety = societyName or "justiz"
    TriggerEvent("esx_billing:addPlayerBill", identifier, billSociety, grund, betrag)
    return true, nil
  end

  return false, "Kein Banking-Ressource verfügbar (wasabi_banking, wasabi_billing, esx_banking, esx_billing)."
end

-- -----------------------------------------------------------------------
-- Society-Adapter: Einzahlung auf Society-Konto
-- -----------------------------------------------------------------------

--- Zahlt `betrag` (EUR, Ganzzahl) auf das Society-Konto `societyName` ein.
--- Versucht wasabi_banking zuerst, dann esx_banking.
--- @return ok boolean, fehlertext string|nil
local function societyEinzahlen(societyName, betrag, grund)
  -- wasabi_banking
  if ressourceGestartet("wasabi_banking") then
    local ok = exports["wasabi_banking"]:addSocietyMoney(societyName, betrag, grund)
    if ok then
      return true, nil
    end
    -- Nicht fatal: Geld wurde bereits abgebucht – loggen aber nicht als Gesamtfehler werten
    return false, ("wasabi_banking: Society-Einzahlung für '%s' fehlgeschlagen."):format(societyName)
  end

  -- wasabi_billing
  if ressourceGestartet("wasabi_billing") then
    local ok = exports["wasabi_billing"]:addSocietyMoney(societyName, betrag, grund)
    if ok then
      return true, nil
    end
    return false, ("wasabi_billing: Society-Einzahlung für '%s' fehlgeschlagen."):format(societyName)
  end

  -- esx_banking
  if ressourceGestartet("esx_banking") then
    local ok = exports["esx_banking"]:addSocietyMoney(societyName, betrag)
    if ok then
      return true, nil
    end
    return false, ("esx_banking: Society-Einzahlung für '%s' fehlgeschlagen."):format(societyName)
  end

  -- esx_billing (Fallback)
  -- HINWEIS: fire-and-forget via TriggerEvent (keine Bestätigung möglich).
  if ressourceGestartet("esx_billing") then
    TriggerEvent("esx_billing:addSocietyMoney", societyName, betrag, 1)
    return true, nil
  end

  return false, "Kein Banking-Ressource für Society-Einzahlung verfügbar."
end

-- -----------------------------------------------------------------------
-- Webhook-Helfer
-- -----------------------------------------------------------------------

local function webhookSenden(event, daten)
  if HM_BP.Server.Dienste.WebhookService then
    pcall(function()
      HM_BP.Server.Dienste.WebhookService.Emit(event, daten)
    end)
  end
end

-- -----------------------------------------------------------------------
-- Audit-Helfer
-- -----------------------------------------------------------------------

local function auditLoggen(aktion, spieler, antragId, daten)
  if HM_BP.Server.Dienste.AuditService then
    pcall(function()
      HM_BP.Server.Dienste.AuditService.Log(
        aktion,
        spieler,
        "submission",
        tostring(antragId),
        daten,
        { actor_source = "payment_service" }
      )
    end)
  end
end

-- -----------------------------------------------------------------------
-- Öffentliche API
-- -----------------------------------------------------------------------

--- Bucht die Gebühr eines Antrags ab und zahlt sie auf das Society-Konto ein.
---
--- @param spieler       table   – Spieler-Objekt (identifier, name, source, job)
--- @param betragEur     number  – Gebühr in ganzen Euro (integer > 0)
--- @param antragInfo    table   – { antrag_id, public_id, form_id, formular_titel, citizen_name, spieler_name }
--- @return result table { ok, abgezogen, eingezahlt, fehler }
function PaymentService.GebuehrAbbuchen(spieler, betragEur, antragInfo)
  betragEur = tonumber(betragEur) or 0
  if betragEur <= 0 then
    return { ok = true, abgezogen = false, eingezahlt = false, fehler = nil }
  end

  if not (Config.Module and Config.Module.Gebuehren) then
    return { ok = true, abgezogen = false, eingezahlt = false, fehler = "Gebühren-Modul deaktiviert." }
  end

  local societyKonto = (Config.Zahlung and Config.Zahlung.SocietyKonto) or "society_justiz"
  local antragId     = antragInfo and antragInfo.antrag_id
  local publicId     = antragInfo and antragInfo.public_id
  local formTitel    = antragInfo and (antragInfo.formular_titel or antragInfo.form_id) or "Unbekannt"
  local citizenName  = antragInfo and antragInfo.citizen_name or spieler.name
  local spielerName  = antragInfo and antragInfo.spieler_name or spieler.name

  local grund = ("Antrag %s – %s"):format(tostring(publicId or antragId), formTitel)

  -- 1) Abhebung vom Bürgerkonto
  local abOk, abErr = bankAbheben(spieler, betragEur, grund, societyKonto)
  if not abOk then
    -- Fehler: unzureichendes Guthaben oder kein Banking vorhanden
    auditLoggen("zahlung.fehlgeschlagen", spieler, antragId, {
      betrag_eur   = betragEur,
      public_id    = publicId,
      form_id      = antragInfo and antragInfo.form_id,
      formular_titel = formTitel,
      grund        = abErr,
    })
    return { ok = false, abgezogen = false, eingezahlt = false, fehler = abErr }
  end

  -- Webhook: Abbuchung vom Bürger
  webhookSenden("antrag_payment_abgezogen", {
    public_id      = publicId,
    spieler_name   = spielerName,
    citizen_name   = citizenName,
    betrag_eur     = betragEur,
    formular_titel = formTitel,
    form_id        = antragInfo and antragInfo.form_id,
    society        = societyKonto,
    zeitpunkt      = utcJetztIso(),
  })

  auditLoggen("zahlung.abgezogen", spieler, antragId, {
    betrag_eur     = betragEur,
    public_id      = publicId,
    form_id        = antragInfo and antragInfo.form_id,
    formular_titel = formTitel,
    society        = societyKonto,
  })

  -- 2) Einzahlung auf Society-Konto
  local einOk, einErr = societyEinzahlen(societyKonto, betragEur, grund)
  if not einOk then
    -- Geld wurde bereits abgebucht aber Society-Einzahlung schlug fehl – loggen, aber ok=true
    -- (kein Rollback möglich; Staff wird per Webhook informiert)
    auditLoggen("zahlung.society_fehlgeschlagen", spieler, antragId, {
      betrag_eur     = betragEur,
      public_id      = publicId,
      form_id        = antragInfo and antragInfo.form_id,
      formular_titel = formTitel,
      society        = societyKonto,
      grund          = einErr,
    })
    webhookSenden("antrag_payment_society_fehler", {
      public_id      = publicId,
      spieler_name   = spielerName,
      citizen_name   = citizenName,
      betrag_eur     = betragEur,
      formular_titel = formTitel,
      form_id        = antragInfo and antragInfo.form_id,
      society        = societyKonto,
      fehler         = einErr,
      zeitpunkt      = utcJetztIso(),
    })
    return { ok = true, abgezogen = true, eingezahlt = false, fehler = einErr }
  end

  -- Webhook: Society-Einzahlung
  webhookSenden("antrag_payment_eingezahlt", {
    public_id      = publicId,
    spieler_name   = spielerName,
    citizen_name   = citizenName,
    betrag_eur     = betragEur,
    formular_titel = formTitel,
    form_id        = antragInfo and antragInfo.form_id,
    society        = societyKonto,
    zeitpunkt      = utcJetztIso(),
  })

  auditLoggen("zahlung.eingezahlt", spieler, antragId, {
    betrag_eur     = betragEur,
    public_id      = publicId,
    form_id        = antragInfo and antragInfo.form_id,
    formular_titel = formTitel,
    society        = societyKonto,
  })

  return { ok = true, abgezogen = true, eingezahlt = true, fehler = nil }
end

HM_BP.Server.Dienste.PaymentService = PaymentService
