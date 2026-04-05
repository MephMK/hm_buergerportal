HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local WebhookService = {}

local queue = {}
local sending = false

local function cfg()
  return (Config and Config.Webhooks) or { Aktiviert = false }
end

local function ident()
  local c = cfg()
  return (c and c.Identitaet) or { Benutzername = "HM Bürgerportal", AvatarUrl = nil, Footer = "HM Bürgerportal" }
end

local function nowIsoUtc()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function shaLike(text)
  text = tostring(text or "")
  return text:gsub("[^a-zA-Z0-9_%-%.:]", ""):sub(1, 64)
end

local function resolveWebhookUrl(eventName, data)
  local c = cfg()
  if not c or c.Aktiviert ~= true then return nil end
  local routing = c.Routing or {}

  local categoryId = data and (data.category_id or data.kategorie_id)
  local formId = data and (data.form_id or data.formular_id)

  -- 1) pro Formular
  if formId and routing.NachFormular and routing.NachFormular[formId] then
    return routing.NachFormular[formId]
  end

  -- 2) pro Kategorie
  if categoryId and routing.NachKategorie and routing.NachKategorie[categoryId] then
    return routing.NachKategorie[categoryId]
  end

  -- 3) pro Event
  if routing.NachEvent and routing.NachEvent[eventName] then
    return routing.NachEvent[eventName]
  end

  -- 4) fallback
  return routing.Fallback
end

local function embedColorForEvent(eventName)
  eventName = tostring(eventName or "")
  if eventName:find("error") then return 0xE74C3C end
  if eventName:find("security") then return 0x8E44AD end
  if eventName:find("submission%.created") then return 0x2F80ED end
  if eventName:find("status") then return 0xF2C94C end
  if eventName:find("archiv") then return 0x4F4F4F end
  return 0x2D9CDB
end

local function makeEmbed(eventName, data)
  local i = ident()
  local title = ("Bürgerportal: %s"):format(tostring(eventName))

  local fields = {}
  local function addField(name, value, inline)
    if value == nil then return end
    local v = tostring(value)
    if v == "" then return end
    table.insert(fields, { name = name, value = v, inline = inline == true })
  end

  addField("Antrag-ID", data and (data.public_id or data.antrag_id or data.submission_id), true)
  addField("Kategorie", data and (data.category_id or data.kategorie_id), true)
  addField("Formular", data and (data.form_id or data.formular_id), true)

  addField("Bürger", data and data.citizen_name, true)
  addField("Identifier", data and data.citizen_identifier, true)

  addField("Status", data and data.status, true)
  addField("Priorität", data and data.priority, true)

  addField("Bearbeiter", data and data.assigned_to_name, true)

  if data and data.text then
    local text = tostring(data.text)
    if #text > 900 then text = text:sub(1, 900) .. "..." end
    addField("Text", text, false)
  end

  addField("Standort", data and data.standort_id, true)

  local footer = i.Footer or "HM Bürgerportal"

  return {
    title = title,
    description = nil,
    color = embedColorForEvent(eventName),
    fields = fields,
    footer = { text = footer },
    timestamp = nowIsoUtc()
  }
end

local function pushQueue(item)
  local c = cfg()
  local max = (c.Warteschlange and c.Warteschlange.MaxGroesse) or 5000
  if #queue >= max then
    -- wenn zu voll: älteste raus (oder verwerfen). Wir verwerfen hier das neue Item.
    if Config.Kern and Config.Kern.Debugmodus then
      print("[hm_buergerportal] WARN: Webhook-Queue voll, verwerfe Event " .. tostring(item and item.event))
    end
    return
  end
  table.insert(queue, item)
end

local function httpPost(url, payload, cb)
  PerformHttpRequest(url, function(code, body, headers)
    cb(code, body, headers)
  end, "POST", payload, { ["Content-Type"] = "application/json" })
end

local function workerTick()
  if sending then return end
  sending = true

  CreateThread(function()
    local c = cfg()
    local interval = (c.Warteschlange and c.Warteschlange.WorkerIntervallMs) or 750
    local maxPer = (c.Warteschlange and c.Warteschlange.MaxProIntervall) or 5

    while #queue > 0 do
      local processed = 0
      while processed < maxPer and #queue > 0 do
        processed = processed + 1

        local item = table.remove(queue, 1)
        local url = item and item.url
        local eventName = item and item.event
        local data = item and item.data or {}

        if not url or url == "" then
          goto continue_item
        end

        local i = ident()
        local embed = makeEmbed(eventName, data)

        local msg = {
          username = i.Benutzername or "HM Bürgerportal",
          avatar_url = i.AvatarUrl,
          embeds = { embed }
        }

        local payload = json.encode(msg)
        httpPost(url, payload, function(code, body, headers)
          local ok = (tonumber(code or 0) >= 200 and tonumber(code or 0) < 300)

          -- optionales Logging in DB: hm_bp_webhook_logs existiert
          if c.LogsInDB == true then
            local hash = shaLike(url)
            HM_BP.Server.Datenbank.Ausfuehren([[
              INSERT INTO hm_bp_webhook_logs (event_name, webhook_url_hash, payload, success, response_code, error_text)
              VALUES (?, ?, ?, ?, ?, ?)
            ]], {
              tostring(eventName),
              hash,
              payload,
              ok and 1 or 0,
              tonumber(code or 0),
              ok and nil or (tostring(body or ""):sub(1, 255))
            })
          end

          if not ok and Config.Kern and Config.Kern.Debugmodus then
            print(("[hm_buergerportal] WARN: Webhook fehlgeschlagen (%s) code=%s body=%s"):format(
              tostring(eventName), tostring(code), tostring(body)
            ))
          end
        end)

        ::continue_item::
      end

      Wait(interval)
    end

    sending = false
  end)
end

function WebhookService.Emit(eventName, data)
  local c = cfg()
  if not c or c.Aktiviert ~= true then return end

  local url = resolveWebhookUrl(eventName, data or {})
  if not url or url == "" then
    -- bewusst still: wenn nichts geroutet ist, dann nichts senden
    return
  end

  pushQueue({ event = tostring(eventName), url = url, data = data or {} })
  workerTick()
end

HM_BP.Server.Dienste.WebhookService = WebhookService