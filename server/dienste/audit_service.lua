-- =============================================================
-- server/dienste/audit_service.lua  (PR12 – Audit-Härtung)
--
-- Unveränderliche Audit-Logs: Einträge werden nur per INSERT
-- geschrieben – kein UPDATE, kein DELETE via API oder UI.
--
-- Öffentliche API:
--   AuditService.Log(aktion, spieler, targetType, targetId, daten, extra)
--     extra (optional): {
--       request_id        string   Korrelations-ID (wird generiert wenn nil)
--       actor_source      string   "citizen"|"admin"|"justiz"|"system" (+ "fivem:N")
--       actor_ip          string   Spieler-IP aus GetPlayerEndpoint
--       target_public_id  string   öffentliche Antragsnummer
--       target_category_id string  Kategorie-ID
--       target_form_id    string   Formular-ID
--       reason            string   Freitext-Begründung
--       metadata          table    beliebige Zusatzdaten (JSON ≤ 4 KB)
--     }
--
--   AuditService.Liste(filter, seite, proSeite)
--     filter: { von, bis, actor_name, aktion, target_public_id, request_id }
--     → { ok, eintraege, gesamt, seite, pro_seite }
--     (für Admin-/Leitung-View; actor_identifier nur bei redacted=false)
--
--   AuditService.RetentionCleanup()
--     Löscht Einträge, die älter als Config.Audit.Retention.TageMax Tage sind.
--     Blockiert nicht den Game-Thread (async DB-Aufruf).
--
--   AuditService.GenerateRequestId()
--     Gibt eine neue, eindeutige Korrelations-ID zurück.
-- =============================================================

HM_BP        = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AuditService = {}

-- ----------------------------------------------------------------
-- Hilfsfunktionen
-- ----------------------------------------------------------------

local function safeJsonEncode(data)
  if data == nil then return nil end
  local ok, res = pcall(function() return json.encode(data) end)
  if ok then return res end
  return json.encode({ encode_error = true, raw = tostring(data) })
end

-- ----------------------------------------------------------------
-- Öffentliche API
-- ----------------------------------------------------------------

---Generiert eine eindeutige Korrelations-ID (16 Zeichen Hex).
---@return string
function AuditService.GenerateRequestId()
  local t = os.time()
  local r1 = math.random(0, 0xFFFF)
  local r2 = math.random(0, 0xFFFF)
  return string.format("%08x%04x%04x", t, r1, r2)
end

---Schreibt einen Audit-Eintrag (append-only, kein Edit/Delete via API).
---Rückwärtskompatibel: extra ist optional.
---@param aktion      string   Technischer Aktionsschlüssel z.B. "antrag.eingereicht"
---@param spieler     table?   Spieler-Kontext (identifier, name, job, quelle)
---@param targetType  string?  Zieltyp z.B. "submission", "form", "system"
---@param targetId    string?  Technische Ziel-ID
---@param daten       table?   Optionale Kontextdaten
---@param extra       table?   Erweiterte PR12-Felder (siehe oben)
---@return boolean ok
function AuditService.Log(aktion, spieler, targetType, targetId, daten, extra)
  if not (HM_BP and HM_BP.Server and HM_BP.Server.Datenbank) then return false end
  if not aktion or aktion == "" then return false end

  extra = extra or {}

  local actorIdentifier    = spieler and spieler.identifier or "system"
  local actorName          = spieler and spieler.name or "system"
  local actorJob           = spieler and spieler.job and spieler.job.name or nil
  local actorGrade         = spieler and spieler.job and spieler.job.grade or nil
  local actorDisplayName   = extra.actor_display_name or actorName

  -- actor_source: Rolle-Info + optionale FiveM-Source-ID
  local actorSource = extra.actor_source
  if not actorSource then
    if spieler and spieler.rolle then
      actorSource = tostring(spieler.rolle)
    elseif spieler and spieler.job then
      -- Fallback über Job-Name
      local adminJob  = (Config.Kern.Admin and Config.Kern.Admin.Job) or "admin"
      local justizJob = (Config.Kern.Justiz and Config.Kern.Justiz.Job)
                     or (Config.Kern.Jobs and Config.Kern.Jobs.Justiz)
                     or "doj"
      if spieler.job.name == adminJob then
        actorSource = "admin"
      elseif spieler.job.name == justizJob then
        actorSource = "justiz"
      else
        actorSource = "citizen"
      end
    else
      actorSource = "system"
    end
    -- Hänge FiveM-Source an wenn vorhanden
    if spieler and spieler.quelle and tonumber(spieler.quelle) then
      actorSource = actorSource .. ";fivem:" .. tostring(spieler.quelle)
    end
  end

  -- Spieler-IP (GetPlayerEndpoint gibt "IP:Port" zurück)
  local actorIp = extra.actor_ip
  if not actorIp and spieler and spieler.quelle and tonumber(spieler.quelle) then
    local ep = GetPlayerEndpoint and GetPlayerEndpoint(tonumber(spieler.quelle))
    if ep and ep ~= "" then
      actorIp = tostring(ep)
    end
  end

  local requestId = extra.request_id or AuditService.GenerateRequestId()

  -- metadata-Größe begrenzen (max. ~4 KB)
  local metaJson = nil
  if extra.metadata ~= nil then
    local rawMeta = safeJsonEncode(extra.metadata)
    if rawMeta and #rawMeta <= 4096 then
      metaJson = rawMeta
    else
      metaJson = safeJsonEncode({ truncated = true, size = rawMeta and #rawMeta or 0 })
    end
  end

  local payload = safeJsonEncode(daten)

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_display_name,
       actor_job, actor_grade, actor_source, actor_ip,
       target_type, target_id,
       target_public_id, target_category_id, target_form_id,
       request_id, reason, data, metadata)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ]], {
    tostring(aktion),
    tostring(actorIdentifier),
    tostring(actorName),
    tostring(actorDisplayName),
    actorJob,
    actorGrade,
    tostring(actorSource),
    actorIp,
    tostring(targetType or "system"),
    tostring(targetId or ""),
    extra.target_public_id and tostring(extra.target_public_id) or nil,
    extra.target_category_id and tostring(extra.target_category_id) or nil,
    extra.target_form_id and tostring(extra.target_form_id) or nil,
    tostring(requestId),
    extra.reason and tostring(extra.reason) or nil,
    payload,
    metaJson,
  })

  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    print(("[hm_buergerportal][AUDIT] %s req=%s actor=%s src=%s target=%s:%s"):format(
      tostring(aktion),
      tostring(requestId),
      tostring(actorIdentifier),
      tostring(actorSource),
      tostring(targetType or "system"),
      tostring(targetId or "")
    ))
  end

  return true
end

---Gibt eine gefilterte, paginierte Liste von Audit-Einträgen zurück.
---Wird ausschließlich von Admins und Justiz-Leitung aufgerufen.
---@param filter      table?   { von, bis, actor_name, aktion, target_public_id, request_id }
---@param seite       number?  Seitennummer (1-basiert)
---@param proSeite    number?  Einträge pro Seite (max 100)
---@param zeigeIdentifier boolean? true = actor_identifier einschließen (nur Admin)
---@return table result { ok, eintraege, gesamt, seite, pro_seite }
function AuditService.Liste(filter, seite, proSeite, zeigeIdentifier)
  if not (HM_BP and HM_BP.Server and HM_BP.Server.Datenbank) then
    return { ok = false, fehler = "Datenbank nicht verfügbar" }
  end

  filter    = filter or {}
  seite     = math.max(1, tonumber(seite) or 1)
  proSeite  = math.min(100, math.max(1, tonumber(proSeite) or 50))
  local offset = (seite - 1) * proSeite

  -- WHERE-Klausel dynamisch aufbauen
  local bedingungen = {}
  local parameter   = {}

  if type(filter.von) == "string" and filter.von ~= "" then
    table.insert(bedingungen, "created_at >= ?")
    table.insert(parameter, filter.von)
  end
  if type(filter.bis) == "string" and filter.bis ~= "" then
    table.insert(bedingungen, "created_at <= ?")
    table.insert(parameter, filter.bis)
  end
  if type(filter.actor_name) == "string" and filter.actor_name ~= "" then
    table.insert(bedingungen, "actor_name LIKE ?")
    table.insert(parameter, "%" .. filter.actor_name .. "%")
  end
  if type(filter.aktion) == "string" and filter.aktion ~= "" then
    table.insert(bedingungen, "action = ?")
    table.insert(parameter, filter.aktion)
  end
  if type(filter.target_public_id) == "string" and filter.target_public_id ~= "" then
    table.insert(bedingungen, "target_public_id = ?")
    table.insert(parameter, filter.target_public_id)
  end
  if type(filter.request_id) == "string" and filter.request_id ~= "" then
    table.insert(bedingungen, "request_id = ?")
    table.insert(parameter, filter.request_id)
  end

  local whereClause = ""
  if #bedingungen > 0 then
    whereClause = "WHERE " .. table.concat(bedingungen, " AND ")
  end

  -- Gesamtzahl (für Pagination)
  local countParams = {}
  for _, v in ipairs(parameter) do table.insert(countParams, v) end
  local countRow = HM_BP.Server.Datenbank.Einzel(
    "SELECT COUNT(*) AS gesamt FROM hm_bp_audit_logs " .. whereClause,
    countParams
  )
  local gesamt = countRow and (countRow.gesamt or 0) or 0

  -- Einträge laden
  local selectParams = {}
  for _, v in ipairs(parameter) do table.insert(selectParams, v) end
  table.insert(selectParams, proSeite)
  table.insert(selectParams, offset)

  local zeilen = HM_BP.Server.Datenbank.Alle([[
    SELECT
      id, created_at, action, request_id,
      actor_name, actor_display_name, actor_source,
      target_type, target_id,
      target_public_id, target_category_id, target_form_id,
      reason, data, metadata
    FROM hm_bp_audit_logs
    ]] .. whereClause .. [[
    ORDER BY created_at DESC
    LIMIT ? OFFSET ?
  ]], selectParams) or {}

  -- actor_identifier nur für Admins (nicht für Leitung)
  if zeigeIdentifier then
    local idParams = {}
    for _, v in ipairs(parameter) do table.insert(idParams, v) end
    table.insert(idParams, proSeite)
    table.insert(idParams, offset)
    zeilen = HM_BP.Server.Datenbank.Alle([[
      SELECT
        id, created_at, action, request_id,
        actor_identifier, actor_name, actor_display_name, actor_source,
        target_type, target_id,
        target_public_id, target_category_id, target_form_id,
        reason, data, metadata
      FROM hm_bp_audit_logs
      ]] .. whereClause .. [[
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    ]], idParams) or {}
  end

  -- Timestamps als String sicherstellen
  local eintraege = {}
  for _, z in ipairs(zeilen) do
    table.insert(eintraege, {
      id                = z.id,
      created_at        = tostring(z.created_at or ""),
      action            = z.action,
      request_id        = z.request_id,
      actor_identifier  = zeigeIdentifier and z.actor_identifier or nil,
      actor_name        = z.actor_name,
      actor_display_name = z.actor_display_name,
      actor_source      = z.actor_source,
      target_type       = z.target_type,
      target_id         = z.target_id,
      target_public_id  = z.target_public_id,
      target_category_id = z.target_category_id,
      target_form_id    = z.target_form_id,
      reason            = z.reason,
      data              = z.data,
      metadata          = z.metadata,
    })
  end

  return {
    ok       = true,
    eintraege = eintraege,
    gesamt   = gesamt,
    seite    = seite,
    pro_seite = proSeite,
  }
end

---Löscht Audit-Einträge, die älter als die konfigurierten Retention-Tage sind.
---Läuft asynchron und blockiert den Game-Thread nicht.
function AuditService.RetentionCleanup()
  if not (HM_BP and HM_BP.Server and HM_BP.Server.Datenbank) then return end

  local tage = (Config.Audit and Config.Audit.Retention and Config.Audit.Retention.TageMax)
    or 90

  -- Audit-Logs
  HM_BP.Server.Datenbank.Ausfuehren(
    "DELETE FROM hm_bp_audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)",
    { tage }
  )

  -- Webhook-Logs mitbereinigen (gleiche Retention)
  HM_BP.Server.Datenbank.Ausfuehren(
    "DELETE FROM hm_bp_webhook_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)",
    { tage }
  )

  -- Security-Events mitbereinigen
  HM_BP.Server.Datenbank.Ausfuehren(
    "DELETE FROM hm_bp_security_events WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)",
    { tage }
  )

  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    print(("[hm_buergerportal][AUDIT] Retention-Cleanup: Einträge älter als %d Tage gelöscht."):format(tage))
  end
end

HM_BP.Server.Dienste.AuditService = AuditService
