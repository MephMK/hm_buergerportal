HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

-- ===========================================================================
-- PaymentService – Gebührenzahlung (PR4)
--
-- Abstraktion über Banking-Ressourcen:
--   Primär:   wasabi_banking  + wasabi_billing
--   Fallback: esx_banking     + esx_billing
--
-- Öffentliche API:
--   PaymentService.GebuehrAbbuchen(spieler, betragEur, antragInfo)
--     → { ok, abgezogen, eingezahlt, fehler }
--   PaymentService.BefreiungPruefen(spieler, antragInfo)
--     → befreit boolean
--   PaymentService.GebuehrErstatten(spieler, betragEur, antragInfo)
--     → { ok, erstattet, fehler }
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
-- Ledger-Helfer
-- -----------------------------------------------------------------------

local function ledgerEintragen(params)
  if HM_BP.Server.Dienste.LedgerService then
    pcall(function()
      HM_BP.Server.Dienste.LedgerService.Eintragen(params)
    end)
  end
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

--- Prüft, ob ein Spieler/Antrag von Gebühren befreit ist.
---
--- @param spieler    table  – Spieler-Objekt (identifier, job)
--- @param antragInfo table  – { category_id, form_id }
--- @return befreit boolean
function PaymentService.BefreiungPruefen(spieler, antragInfo)
  if not (Config.Module and Config.Module.Gebuehren) then return false end
  local befreiungen = Config.Zahlung and Config.Zahlung.Befreiungen
  if not befreiungen or not befreiungen.aktiv then return false end

  local jobName    = spieler and spieler.job and spieler.job.name or ""
  local categoryId = antragInfo and antragInfo.category_id or ""
  local formId     = antragInfo and antragInfo.form_id or ""

  -- Rollenprüfung
  if type(befreiungen.rollen) == "table" then
    for _, rolle in ipairs(befreiungen.rollen) do
      if rolle == jobName then return true end
    end
  end

  -- Kategorieprüfung
  if type(befreiungen.kategorien) == "table" then
    for _, kat in ipairs(befreiungen.kategorien) do
      if kat == categoryId then return true end
    end
  end

  -- Formularprüfung
  if type(befreiungen.formulare) == "table" then
    for _, fid in ipairs(befreiungen.formulare) do
      if fid == formId then return true end
    end
  end

  return false
end

--- Bucht die Gebühr eines Antrags ab und zahlt sie auf das Society-Konto ein.
---
--- @param spieler       table   – Spieler-Objekt (identifier, name, source, job)
--- @param betragEur     number  – Gebühr in ganzen Euro (integer > 0)
--- @param antragInfo    table   – { antrag_id, public_id, form_id, formular_titel, citizen_name, spieler_name, category_id }
--- @return result table { ok, abgezogen, eingezahlt, befreit, fehler }
function PaymentService.GebuehrAbbuchen(spieler, betragEur, antragInfo)
  betragEur = tonumber(betragEur) or 0
  if betragEur <= 0 then
    return { ok = true, abgezogen = false, eingezahlt = false, befreit = false, fehler = nil }
  end

  if not (Config.Module and Config.Module.Gebuehren) then
    return { ok = true, abgezogen = false, eingezahlt = false, befreit = false, fehler = "Gebühren-Modul deaktiviert." }
  end

  local societyKonto = (Config.Zahlung and Config.Zahlung.SocietyKonto) or "society_justiz"
  local antragId     = antragInfo and antragInfo.antrag_id
  local publicId     = antragInfo and antragInfo.public_id
  local formTitel    = antragInfo and (antragInfo.formular_titel or antragInfo.form_id) or "Unbekannt"
  local citizenName  = antragInfo and antragInfo.citizen_name or spieler.name
  local spielerName  = antragInfo and antragInfo.spieler_name or spieler.name

  local grund = ("Antrag %s – %s"):format(tostring(publicId or antragId), formTitel)

  -- Gebührenbefreiung prüfen (PR4)
  if PaymentService.BefreiungPruefen(spieler, antragInfo) then
    auditLoggen("zahlung.befreit", spieler, antragId, {
      betrag_eur     = betragEur,
      public_id      = publicId,
      form_id        = antragInfo and antragInfo.form_id,
      formular_titel = formTitel,
    })
    ledgerEintragen({
      antrag_id          = antragId,
      public_id          = publicId,
      citizen_identifier = spieler.identifier,
      actor_name         = spielerName,
      typ                = "exempt",
      betrag_eur         = betragEur,
      status             = "success",
      metadata           = { form_id = antragInfo and antragInfo.form_id, formular_titel = formTitel },
    })
    webhookSenden("antrag_payment_befreit", {
      public_id      = publicId,
      spieler_name   = spielerName,
      citizen_name   = citizenName,
      betrag_eur     = betragEur,
      formular_titel = formTitel,
      form_id        = antragInfo and antragInfo.form_id,
      zeitpunkt      = utcJetztIso(),
    })
    return { ok = true, abgezogen = false, eingezahlt = false, befreit = true, fehler = nil }
  end

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
    ledgerEintragen({
      antrag_id          = antragId,
      public_id          = publicId,
      citizen_identifier = spieler.identifier,
      actor_name         = spielerName,
      typ                = "debit",
      betrag_eur         = betragEur,
      status             = "failed",
      metadata           = { fehler = abErr, form_id = antragInfo and antragInfo.form_id },
    })
    return { ok = false, abgezogen = false, eingezahlt = false, befreit = false, fehler = abErr }
  end

  -- Ledger: Abbuchung vom Bürger
  ledgerEintragen({
    antrag_id          = antragId,
    public_id          = publicId,
    citizen_identifier = spieler.identifier,
    actor_name         = spielerName,
    typ                = "debit",
    betrag_eur         = betragEur,
    status             = "success",
    metadata           = { form_id = antragInfo and antragInfo.form_id, formular_titel = formTitel, society = societyKonto },
  })

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
    return { ok = true, abgezogen = true, eingezahlt = false, befreit = false, fehler = einErr }
  end

  -- Ledger: Einzahlung auf Society
  ledgerEintragen({
    antrag_id          = antragId,
    public_id          = publicId,
    citizen_identifier = spieler.identifier,
    actor_name         = spielerName,
    typ                = "credit",
    betrag_eur         = betragEur,
    status             = "success",
    metadata           = { form_id = antragInfo and antragInfo.form_id, formular_titel = formTitel, society = societyKonto },
  })

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

  return { ok = true, abgezogen = true, eingezahlt = true, befreit = false, fehler = nil }
end

--- Erstattet einen Betrag vom Society-Konto zurück auf das Bürgerkonto.
---
--- @param spieler    table  – Spieler-Objekt des Bürgers (identifier, name, source, job)
--- @param betragEur  number – Zu erstattender Betrag in ganzen Euro (integer > 0)
--- @param antragInfo table  – { antrag_id, public_id, form_id, formular_titel, citizen_name, spieler_name, grund }
--- @return result table { ok, erstattet, fehler }
function PaymentService.GebuehrErstatten(spieler, betragEur, antragInfo)
  betragEur = tonumber(betragEur) or 0
  if betragEur <= 0 then
    return { ok = true, erstattet = false, fehler = nil }
  end

  if not (Config.Module and Config.Module.Gebuehren) then
    return { ok = true, erstattet = false, fehler = "Gebühren-Modul deaktiviert." }
  end

  local societyKonto = (Config.Zahlung and Config.Zahlung.SocietyKonto) or "society_justiz"
  local antragId     = antragInfo and antragInfo.antrag_id
  local publicId     = antragInfo and antragInfo.public_id
  local formTitel    = antragInfo and (antragInfo.formular_titel or antragInfo.form_id) or "Unbekannt"
  local citizenName  = antragInfo and antragInfo.citizen_name or spieler.name
  local spielerName  = antragInfo and antragInfo.spieler_name or spieler.name
  local grundText    = antragInfo and antragInfo.grund or "Rückerstattung"

  -- 1) Abhebung vom Society-Konto
  local grund = ("Rückerstattung Antrag %s – %s"):format(tostring(publicId or antragId), formTitel)
  local socOk, socErr = nil, nil

  if ressourceGestartet("wasabi_banking") then
    socOk = exports["wasabi_banking"]:removeSocietyMoney(societyKonto, betragEur, grund)
    if not socOk then
      socErr = "wasabi_banking: Society-Abbuchung für Rückerstattung fehlgeschlagen."
    end
  elseif ressourceGestartet("wasabi_billing") then
    socOk = exports["wasabi_billing"]:removeSocietyMoney(societyKonto, betragEur, grund)
    if not socOk then
      socErr = "wasabi_billing: Society-Abbuchung für Rückerstattung fehlgeschlagen."
    end
  elseif ressourceGestartet("esx_banking") then
    socOk = exports["esx_banking"]:removeSocietyMoney(societyKonto, betragEur)
    if not socOk then
      socErr = "esx_banking: Society-Abbuchung für Rückerstattung fehlgeschlagen."
    end
  else
    -- Kein passendes Banking vorhanden – trotzdem Bürgerkonto gutschreiben
    socOk = true
    socErr = nil
  end

  if not socOk then
    auditLoggen("erstattung.fehlgeschlagen", spieler, antragId, {
      betrag_eur     = betragEur,
      public_id      = publicId,
      form_id        = antragInfo and antragInfo.form_id,
      formular_titel = formTitel,
      grund          = socErr,
    })
    ledgerEintragen({
      antrag_id          = antragId,
      public_id          = publicId,
      citizen_identifier = spieler.identifier,
      actor_name         = spielerName,
      typ                = "refund",
      betrag_eur         = betragEur,
      status             = "failed",
      metadata           = { fehler = socErr, form_id = antragInfo and antragInfo.form_id, grund = grundText },
    })
    return { ok = false, erstattet = false, fehler = socErr }
  end

  -- 2) Gutschrift auf Bürgerkonto
  local gutOk, gutErr = nil, nil
  local source = tonumber(spieler.source)

  if ressourceGestartet("wasabi_banking") then
    gutOk = exports["wasabi_banking"]:addBankMoney(source, betragEur, grund)
    if not gutOk then gutErr = "wasabi_banking: Gutschrift fehlgeschlagen." end
  elseif ressourceGestartet("wasabi_billing") then
    gutOk = exports["wasabi_billing"]:addBankMoney(source, betragEur, grund)
    if not gutOk then gutErr = "wasabi_billing: Gutschrift fehlgeschlagen." end
  elseif ressourceGestartet("esx_banking") then
    gutOk = exports["esx_banking"]:addBankMoney(spieler.identifier, betragEur)
    if not gutOk then gutErr = "esx_banking: Gutschrift fehlgeschlagen." end
  elseif ressourceGestartet("esx_billing") then
    TriggerEvent("esx_billing:addPlayerMoney", spieler.identifier, betragEur)
    gutOk = true
  else
    gutErr = "Kein Banking-Ressource für Rückerstattung verfügbar."
    gutOk = false
  end

  if not gutOk then
    -- Society-Betrag wurde bereits abgebucht; Bürger-Gutschrift schlug fehl
    auditLoggen("erstattung.gutschrift_fehlgeschlagen", spieler, antragId, {
      betrag_eur     = betragEur,
      public_id      = publicId,
      form_id        = antragInfo and antragInfo.form_id,
      formular_titel = formTitel,
      grund          = gutErr,
    })
    ledgerEintragen({
      antrag_id          = antragId,
      public_id          = publicId,
      citizen_identifier = spieler.identifier,
      actor_name         = spielerName,
      typ                = "refund",
      betrag_eur         = betragEur,
      status             = "failed",
      metadata           = { fehler = gutErr, form_id = antragInfo and antragInfo.form_id, grund = grundText },
    })
    webhookSenden("antrag_payment_society_fehler", {
      public_id      = publicId,
      spieler_name   = spielerName,
      citizen_name   = citizenName,
      betrag_eur     = betragEur,
      formular_titel = formTitel,
      form_id        = antragInfo and antragInfo.form_id,
      fehler         = gutErr,
      zeitpunkt      = utcJetztIso(),
    })
    return { ok = false, erstattet = false, fehler = gutErr }
  end

  -- Ledger + Audit + Webhook
  ledgerEintragen({
    antrag_id          = antragId,
    public_id          = publicId,
    citizen_identifier = spieler.identifier,
    actor_name         = spielerName,
    typ                = "refund",
    betrag_eur         = betragEur,
    status             = "success",
    metadata           = { form_id = antragInfo and antragInfo.form_id, formular_titel = formTitel, gesellschaft = societyKonto, grund = grundText },
  })

  auditLoggen("erstattung.erstattet", spieler, antragId, {
    betrag_eur     = betragEur,
    public_id      = publicId,
    form_id        = antragInfo and antragInfo.form_id,
    formular_titel = formTitel,
    grund          = grundText,
  })

  webhookSenden("antrag_payment_refund", {
    public_id      = publicId,
    spieler_name   = spielerName,
    citizen_name   = citizenName,
    betrag_eur     = betragEur,
    formular_titel = formTitel,
    form_id        = antragInfo and antragInfo.form_id,
    grund          = grundText,
    zeitpunkt      = utcJetztIso(),
  })

  return { ok = true, erstattet = true, fehler = nil }
end

HM_BP.Server.Dienste.PaymentService = PaymentService
