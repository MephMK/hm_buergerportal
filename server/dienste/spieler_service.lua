HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local SpielerService = {}

local ESX = nil

local function esxSicherstellen()
  if ESX ~= nil then return ESX end
  local ok, obj = pcall(function()
    return exports['es_extended']:getSharedObject()
  end)
  if ok then
    ESX = obj
  else
    ESX = nil
    if Config and Config.Kern and Config.Kern.Debugmodus then
      print(("[hm_buergerportal] WARN: SpielerService konnte ESX nicht laden: %s"):format(tostring(obj)))
    end
  end
  return ESX
end

local function istStaffJob(jobName)
  local justizJob = (Config.Kern.Justiz and Config.Kern.Justiz.Job)
                 or (Config.Kern.Jobs and Config.Kern.Jobs.Justiz) or "doj"
  if jobName == justizJob then return true end
  if jobName == (Config.Kern.Jobs and Config.Kern.Jobs.Admin or "admin") then return true end
  return false
end

-- Gibt den FiveM-Spielernamen (GetPlayerName) für eine Server-Quell-ID zurück.
-- Gibt nil zurück, wenn der Spieler nicht online ist oder die Quelle ungültig ist.
function SpielerService.SpielerNameAuflosen(quelle)
  local src = tonumber(quelle)
  if not src or src <= 0 then return nil end
  local ok, name = pcall(GetPlayerName, src)
  if ok and name and name ~= "" then
    return name
  end
  return nil
end

-- Gibt den Bezeichner (Identifier) für eine Server-Quell-ID zurück.
function SpielerService.IdentifierAuflosen(quelle)
  local src = tonumber(quelle)
  if not src or src <= 0 then return nil end
  local esx = esxSicherstellen()
  if esx then
    local xPlayer = esx.GetPlayerFromId(src)
    if xPlayer then return xPlayer.identifier end
  end
  return nil
end

function SpielerService.UpsertStaffEintrag(identifier, displayName, job, grade)
  if not identifier or identifier == "" then return end
  if not job or job == "" then return end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_staff_directory (identifier, display_name, job, grade, last_seen_at)
    VALUES (?, ?, ?, ?, UTC_TIMESTAMP())
    ON DUPLICATE KEY UPDATE
      display_name = VALUES(display_name),
      job = VALUES(job),
      grade = VALUES(grade),
      last_seen_at = UTC_TIMESTAMP()
  ]], { identifier, displayName, job, tonumber(grade or 0) or 0 })
end

function SpielerService.SyncOnlineStaffInsDirectory()
  local esx = esxSicherstellen()
  if not esx then return end

  local players = esx.GetPlayers()
  for _, src in ipairs(players) do
    local xPlayer = esx.GetPlayerFromId(src)
    if xPlayer then
      local job = xPlayer.getJob()
      if job and istStaffJob(job.name) then
        local identifier = xPlayer.identifier
        local name = xPlayer.getName()
        SpielerService.UpsertStaffEintrag(identifier, name, job.name, job.grade)
      end
    end
  end
end

function SpielerService.BearbeiterListeHolen()
  local esx = esxSicherstellen()

  -- 1) online staff
  local onlineMap = {} -- identifier -> {identifier, name, job, grade, online=true}
  if esx then
    local players = esx.GetPlayers()
    for _, src in ipairs(players) do
      local xPlayer = esx.GetPlayerFromId(src)
      if xPlayer then
        local job = xPlayer.getJob()
        if job and istStaffJob(job.name) then
          local identifier = xPlayer.identifier
          local name = xPlayer.getName()
          onlineMap[identifier] = {
            identifier = identifier,
            name = name,
            job = job.name,
            grade = job.grade,
            online = true
          }
        end
      end
    end
  end

  -- Upsert online staff so offline list stays fresh
  for _, v in pairs(onlineMap) do
    SpielerService.UpsertStaffEintrag(v.identifier, v.name, v.job, v.grade)
  end

  -- 2) directory staff (offline+history)
  local rows = HM_BP.Server.Datenbank.Alle([[
    SELECT identifier, display_name, job, grade, last_seen_at
    FROM hm_bp_staff_directory
    WHERE job IN (?, ?)
    ORDER BY job ASC, grade DESC, display_name ASC
    LIMIT 500
  ]], {
    (Config.Kern.Justiz and Config.Kern.Justiz.Job) or (Config.Kern.Jobs and Config.Kern.Jobs.Justiz) or "doj",
    (Config.Kern.Jobs and Config.Kern.Jobs.Admin) or "admin"
  }) or {}

  local result = {}

  for _, r in ipairs(rows) do
    local o = onlineMap[r.identifier]
    if o then
      table.insert(result, {
        identifier = o.identifier,
        name = o.name,
        job = o.job,
        grade = o.grade,
        online = true,
        last_seen_at = r.last_seen_at
      })
    else
      table.insert(result, {
        identifier = r.identifier,
        name = r.display_name or r.identifier,
        job = r.job,
        grade = r.grade,
        online = false,
        last_seen_at = r.last_seen_at
      })
    end
  end

  -- 3) add online players not in directory yet (edge cases)
  for identifier, o in pairs(onlineMap) do
    local found = false
    for _, rr in ipairs(result) do
      if rr.identifier == identifier then found = true break end
    end
    if not found then
      table.insert(result, {
        identifier = o.identifier,
        name = o.name,
        job = o.job,
        grade = o.grade,
        online = true,
        last_seen_at = nil
      })
    end
  end

  -- 4) optional sorting: online first, then job, grade desc, name
  table.sort(result, function(a, b)
    if (a.online == true) ~= (b.online == true) then
      return a.online == true
    end
    if tostring(a.job) ~= tostring(b.job) then
      return tostring(a.job) < tostring(b.job)
    end
    if tonumber(a.grade or 0) ~= tonumber(b.grade or 0) then
      return tonumber(a.grade or 0) > tonumber(b.grade or 0)
    end
    return tostring(a.name) < tostring(b.name)
  end)

  return result
end

HM_BP.Server.Dienste.SpielerService = SpielerService