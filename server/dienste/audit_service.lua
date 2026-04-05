HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local AuditService = {}

local function safeJsonEncode(data)
  if data == nil then return nil end
  local ok, res = pcall(function() return json.encode(data) end)
  if ok then return res end
  return json.encode({ encode_error = true, raw = tostring(data) })
end

-- Einheitliche Audit-Log-Schreibmethode
-- action: string (z.B. "antrag.eingereicht")
-- spieler: Spieler-Kontext (identifier, name, job, grade)
-- targetType: z.B. "submission", "form", "category", "system"
-- targetId: string
-- data: table (optional)
function AuditService.Log(action, spieler, targetType, targetId, data)
  if not (HM_BP and HM_BP.Server and HM_BP.Server.Datenbank) then return false end
  if not action or action == "" then return false end

  local actorIdentifier = spieler and spieler.identifier or "system"
  local actorName = spieler and spieler.name or "system"
  local actorJob = spieler and spieler.job and spieler.job.name or nil
  local actorGrade = spieler and spieler.job and spieler.job.grade or nil

  local payload = safeJsonEncode(data)

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_audit_logs
      (action, actor_identifier, actor_name, actor_job, actor_grade, target_type, target_id, data)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  ]], {
    tostring(action),
    tostring(actorIdentifier),
    tostring(actorName),
    actorJob,
    actorGrade,
    tostring(targetType or "system"),
    tostring(targetId or ""),
    payload
  })

  if Config and Config.Kern and Config.Kern.Debugmodus == true then
    print(("[hm_buergerportal][AUDIT] %s actor=%s target=%s:%s"):format(
      tostring(action),
      tostring(actorIdentifier),
      tostring(targetType or "system"),
      tostring(targetId or "")
    ))
  end

  return true
end

HM_BP.Server.Dienste.AuditService = AuditService