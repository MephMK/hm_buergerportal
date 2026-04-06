HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local WebhookService = {}

-- Warteschlange: { event, url, data, versuch, naechsterVersuchNach }
local queue = {}
local workerLaeuft = false

-- ---------------------------------------------------------------
-- Hilfsfunktionen: Config-Zugriff
-- ---------------------------------------------------------------

local function cfg()
  return (Config and Config.Webhooks) or { Aktiviert = false }
end

local function ident()
  local c = cfg()
  return (c and c.Identitaet) or { Benutzername = "HM Bürgerportal", AvatarUrl = nil, Footer = "HM Bürgerportal" }
end

local function debug()
  return Config and Config.Kern and Config.Kern.Debugmodus == true
end

local function nowIsoUtc()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function gameTimerMs()
  return GetGameTimer() -- milliseconds since game start (FiveM)
end

-- ---------------------------------------------------------------
-- Webhook-URL-Routing: Form > Kategorie > Event > Fallback
-- ---------------------------------------------------------------

local function resolveWebhookUrl(eventName, data)
  local c = cfg()
  if not c or c.Aktiviert ~= true then return nil end

  -- Dedizierte URL-Tabelle (z.B. für pdf_export): hat Vorrang vor NachEvent
  if type(c.Urls) == "table" then
    local directUrl = c.Urls[eventName]
    if directUrl and directUrl ~= "" then return directUrl end

    -- Gebühren-Events: alle payment-Events nutzen den gemeinsamen "antrag_payments"-Webhook
    if eventName == "antrag_payment_abgezogen" or
       eventName == "antrag_payment_eingezahlt" or
       eventName == "antrag_payment_society_fehler" or
       eventName == "antrag_payment_refund" or
       eventName == "antrag_payment_befreit" then
      local payUrl = c.Urls["antrag_payments"]
      if payUrl and payUrl ~= "" then return payUrl end
    end

    -- Integrations-Events: nutzen den gemeinsamen "integrationen"-Webhook (PR5)
    if eventName == "integration_failed" or eventName == "integration_succeeded" then
      local intUrl = c.Urls["integrationen"]
      if intUrl and intUrl ~= "" then return intUrl end
    end
  end

  local routing = c.Routing or {}

  local categoryId = data and (data.category_id or data.kategorie_id)
  local formId     = data and (data.form_id     or data.formular_id)

  if formId and routing.NachFormular and routing.NachFormular[formId] then
    return routing.NachFormular[formId]
  end
  if categoryId and routing.NachKategorie and routing.NachKategorie[categoryId] then
    return routing.NachKategorie[categoryId]
  end
  if routing.NachEvent and routing.NachEvent[eventName] then
    return routing.NachEvent[eventName]
  end
  return routing.Fallback
end

-- ---------------------------------------------------------------
-- Embed-Farben + Deutsche Titel/Feldnamen pro Event
-- ---------------------------------------------------------------

local EVENT_META = {
  antrag_created             = { farbe = 0x2F80ED, titel = "📋 Neuer Antrag eingereicht"           },
  antrag_status_changed      = { farbe = 0xF2C94C, titel = "🔄 Antragsstatus geändert"             },
  antrag_assigned            = { farbe = 0x6FCF97, titel = "👤 Antrag zugewiesen"                  },
  antrag_priority_changed    = { farbe = 0xEB5757, titel = "⚡ Priorität geändert"                 },
  antrag_archived            = { farbe = 0x4F4F4F, titel = "📦 Antrag archiviert"                  },
  antrag_deleted             = { farbe = 0xEB5757, titel = "🗑️ Antrag gelöscht"                   },
  antrag_approved            = { farbe = 0x27AE60, titel = "✅ Antrag genehmigt"                   },
  antrag_rejected            = { farbe = 0xEB5757, titel = "❌ Antrag abgelehnt"                   },
  antrag_escalation          = { farbe = 0xF2994A, titel = "🚨 Antrag eskaliert"                   },
  antrag_question_asked      = { farbe = 0x9B51E0, titel = "❓ Rückfrage gestellt"                 },
  antrag_citizen_replied     = { farbe = 0x56CCF2, titel = "💬 Bürger hat geantwortet"             },
  antrag_staff_public_reply  = { farbe = 0x27AE60, titel = "📢 Öffentliche Antwort (Justiz)"       },
  antrag_staff_internal_note = { farbe = 0x828282, titel = "🔒 Interne Notiz hinzugefügt"          },
  antrag_nachgereicht        = { farbe = 0x2D9CDB, titel = "📎 Unterlagen nachgereicht"            },
  anhang_hinzugefuegt        = { farbe = 0x2D9CDB, titel = "🖼️ Anhang hinzugefügt"               },
  anhang_entfernt            = { farbe = 0xEB5757, titel = "🗑️ Anhang entfernt"                   },
  admin_action               = { farbe = 0xEB5757, titel = "🛡️ Admin-Aktion"                      },
  security_incident          = { farbe = 0xEB5757, titel = "⚠️ Sicherheitsvorfall"                 },
  system_error               = { farbe = 0xFF0000, titel = "🔴 Systemfehler"                       },
  ["form_editor.published"]  = { farbe = 0x27AE60, titel = "✅ Formular veröffentlicht"            },
  ["form_editor.archived"]   = { farbe = 0x4F4F4F, titel = "📦 Formular archiviert"               },
  ["admin.config.changed"]   = { farbe = 0xEB5757, titel = "⚙️ Admin-Konfiguration geändert"      },
  webhook_test               = { farbe = 0x3447DB, titel = "🔔 Webhook-Test"                       },
  pdf_export                 = { farbe = 0x1a365d, titel = "📄 PDF-Export erstellt"                },
  antrag_payment_abgezogen   = { farbe = 0xF2994A, titel = "💳 Gebühr abgebucht"                  },
  antrag_payment_eingezahlt  = { farbe = 0x27AE60, titel = "🏦 Gebühr auf Society eingezahlt"     },
  antrag_payment_society_fehler = { farbe = 0xFF0000, titel = "🚨 Society-Einzahlung fehlgeschlagen" },
  antrag_payment_refund      = { farbe = 0x9B51E0, titel = "↩️ Gebühr rückerstattet"              },
  antrag_payment_befreit     = { farbe = 0x6FCF97, titel = "✅ Gebührenbefreiung"                  },
  integration_failed         = { farbe = 0xFF0000, titel = "⚠️ Folgeaktion fehlgeschlagen"         },
  integration_succeeded      = { farbe = 0x27AE60, titel = "✅ Folgeaktion erfolgreich"             },
}

local function embedColorForEvent(eventName)
  local meta = EVENT_META[eventName]
  if meta then return meta.farbe end
  return 0x2D9CDB
end

local function embedTitelForEvent(eventName)
  local meta = EVENT_META[eventName]
  if meta then return meta.titel end
  return ("Bürgerportal: %s"):format(tostring(eventName))
end

-- ---------------------------------------------------------------
-- Embed-Bau: kurzes Format, nur relevante Felder, kein Identifier
-- ---------------------------------------------------------------

local function makeEmbed(eventName, data)
  local i = ident()
  local fields = {}

  local function add(name, value, inline)
    if value == nil then return end
    local v = tostring(value)
    if v == "" then return end
    table.insert(fields, { name = name, value = v, inline = inline ~= false })
  end

  -- Aktenzeichen / öffentliche ID (immer zuerst, wenn vorhanden)
  add("Aktenzeichen", data and (data.public_id or data.aktenzeichen), true)

  -- Akteur: wer hat die Aktion ausgelöst (immer dabei)
  -- Bevorzuge akteur_name; Fallback auf spieler_name/buerger_name/citizen_name
  local akteurAnzeige = data and (data.akteur_name or data.spieler_name or data.buerger_name or data.citizen_name)
  add("Akteur", akteurAnzeige, true)

  -- Bürger/Antragsteller (wenn separat angegeben und vom Akteur verschieden)
  local buergerAnzeige = data and (data.buerger_name or data.citizen_name)
  if buergerAnzeige and buergerAnzeige ~= akteurAnzeige then
    add("Bürger", buergerAnzeige, true)
  end

  -- Gebühren-spezifische Felder (PR14)
  if data and data.betrag_eur ~= nil then
    add("Betrag", ("%d €"):format(tonumber(data.betrag_eur) or 0), true)
  end
  if data and data.formular_titel then
    add("Formular", data.formular_titel, true)
  elseif data then
    -- Fallback auf form_id wenn kein Titel vorhanden
    add("Formular",   data.form_id    or data.formular_id,  true)
  end
  if data and data.society then
    add("Society-Konto", data.society, true)
  end

  -- Kategorie
  add("Kategorie",  data and (data.category_id or data.kategorie_id), true)

  -- Status-Änderung
  if data and data.alter_status and data.neuer_status then
    add("Status", ("%s → %s"):format(tostring(data.alter_status), tostring(data.neuer_status)), false)
  elseif data and data.status then
    add("Status", data.status, true)
  end

  -- Bearbeiter / Zuweisung (nur wenn vom Akteur verschieden)
  local bearbeiterAnzeige = data and (data.bearbeiter_name or data.assigned_to_name)
  if bearbeiterAnzeige and bearbeiterAnzeige ~= akteurAnzeige then
    add("Bearbeiter", bearbeiterAnzeige, true)
  end
  add("Priorität",   data and data.priority,  true)

  -- Integrations-spezifische Felder (PR5)
  add("Hook",         data and data.hook,        true)
  add("Aktionstyp",   data and data.aktion_typ,  true)
  if data and data.fehler then
    local f = tostring(data.fehler)
    if #f > 500 then f = f:sub(1, 500) .. "…" end
    add("Fehlermeldung", f, false)
  end

  -- Freitext (kurz)
  if data and data.text then
    local t = tostring(data.text)
    if #t > 500 then t = t:sub(1, 500) .. "…" end
    add("Nachricht", t, false)
  end

  return {
    title     = embedTitelForEvent(eventName),
    color     = embedColorForEvent(eventName),
    fields    = fields,
    footer    = { text = i.Footer or "HM Bürgerportal" },
    timestamp = nowIsoUtc(),
  }
end

-- ---------------------------------------------------------------
-- DB-Log (optional)
-- ---------------------------------------------------------------

local function shaLike(text)
  return tostring(text or ""):gsub("[^a-zA-Z0-9_%-%.:]", ""):sub(1, 64)
end

local function logInDB(c, eventName, url, payload, ok, code, body)
  if c.LogsInDB ~= true then return end
  local db = HM_BP.Server.Datenbank
  if not db or not db.Ausfuehren then return end
  db.Ausfuehren([[
    INSERT INTO hm_bp_webhook_logs
      (event_name, webhook_url_hash, payload, success, response_code, error_text)
    VALUES (?, ?, ?, ?, ?, ?)
  ]], {
    tostring(eventName),
    shaLike(url),
    payload,
    ok and 1 or 0,
    tonumber(code or 0),
    ok and nil or (tostring(body or ""):sub(1, 255))
  })
end

-- ---------------------------------------------------------------
-- HTTP POST (nicht-blockierend, Callback)
-- ---------------------------------------------------------------

local function httpPost(url, payload, cb)
  PerformHttpRequest(url, function(code, body, headers)
    cb(code, body, headers)
  end, "POST", payload, { ["Content-Type"] = "application/json" })
end

-- ---------------------------------------------------------------
-- Worker-Schleife mit Retry + Backoff + Rate-Limit (429)
-- ---------------------------------------------------------------

local function arbeiteQueue()
  if workerLaeuft then return end
  workerLaeuft = true

  CreateThread(function()
    local c = cfg()
    local intervall  = (c.Warteschlange and c.Warteschlange.WorkerIntervallMs) or 750
    local maxPer     = (c.Warteschlange and c.Warteschlange.MaxProIntervall)   or 5
    local wiederholKfg = (c.Warteschlange and c.Warteschlange.Wiederholung) or {}
    local maxVersuche = tonumber(wiederholKfg.MaxVersuche) or 5
    local backoff     = wiederholKfg.BackoffMs or { 1000, 3000, 7000, 15000, 30000 }

    while #queue > 0 do
      local jetztMs   = gameTimerMs()
      local processed = 0

      -- Index-basierte Iteration, da wir ggf. Einträge am Ende wiedereinfügen
      local i = 1
      while i <= #queue and processed < maxPer do
        local item = queue[i]

        -- Warte-Zeit noch nicht erreicht? → überspringen
        if item.naechsterVersuchNach and item.naechsterVersuchNach > jetztMs then
          i = i + 1
        else
          table.remove(queue, i)
          processed = processed + 1

          local url       = item.url
          local eventName = item.event
          local data      = item.data or {}
          local versuch   = item.versuch or 1

          if not url or url == "" then
            -- kein Ziel, verwerfen
          else
            local identCfg = ident()
            local embed    = makeEmbed(eventName, data)
            local msg = {
              username   = identCfg.Benutzername or "HM Bürgerportal",
              avatar_url = identCfg.AvatarUrl,
              embeds     = { embed }
            }
            local payload = json.encode(msg)

            httpPost(url, payload, function(code, body, headers)
              local statusCode = tonumber(code or 0)
              local ok = statusCode >= 200 and statusCode < 300

              -- Discord Rate-Limit: Retry-After Header auswerten
              if statusCode == 429 then
                local retryAfterSek = 1
                if headers then
                  local ra = headers["retry-after"] or headers["Retry-After"] or headers["x-ratelimit-reset-after"]
                  retryAfterSek = tonumber(ra) or 1
                end
                local warteMs = math.ceil(retryAfterSek * 1000) + 100 -- +100ms Puffer für Netzwerklatenz
                if versuch <= maxVersuche then
                  local naechster = gameTimerMs() + warteMs
                  table.insert(queue, {
                    event               = eventName,
                    url                 = url,
                    data                = data,
                    versuch             = versuch + 1,
                    naechsterVersuchNach = naechster,
                  })
                end
                if debug() then
                  print(("[hm_buergerportal] WARN: Discord Rate-Limit (429), retry %ds: %s"):format(
                    retryAfterSek, tostring(eventName)))
                end
                return
              end

              -- Fehler: Retry mit Backoff
              if not ok then
                if versuch < maxVersuche then
                  local warteMs = backoff[versuch] or backoff[#backoff] or 30000
                  local naechster = gameTimerMs() + warteMs
                  table.insert(queue, {
                    event               = eventName,
                    url                 = url,
                    data                = data,
                    versuch             = versuch + 1,
                    naechsterVersuchNach = naechster,
                  })
                  if debug() then
                    print(("[hm_buergerportal] WARN: Webhook fehlgeschlagen (Versuch %d/%d) code=%s event=%s, retry in %dms"):format(
                      versuch, maxVersuche, tostring(statusCode), tostring(eventName), warteMs))
                  end
                else
                  -- Maximale Versuche erreicht
                  if debug() then
                    print(("[hm_buergerportal] ERR: Webhook endgültig fehlgeschlagen (nach %d Versuchen) code=%s event=%s body=%s"):format(
                      versuch, tostring(statusCode), tostring(eventName), tostring(body or ""):sub(1, 200)))
                  end
                end
              end

              logInDB(c, eventName, url, payload, ok, statusCode, body)
            end)
          end
        end
      end

      Wait(intervall)
    end

    workerLaeuft = false
  end)
end

-- ---------------------------------------------------------------
-- Öffentliche API
-- ---------------------------------------------------------------

--- Sendet ein Webhook-Event in die Queue.
--- akteur_name SOLLTE im data-Table stehen (kein Identifier an Discord).
--- buerger_name und bearbeiter_name sind optional (werden nur angezeigt, wenn vorhanden).
function WebhookService.Emit(eventName, data)
  local c = cfg()
  if not c or c.Aktiviert ~= true then return end
  if Config.Module and Config.Module.Webhooks == false then return end

  local url = resolveWebhookUrl(tostring(eventName), data or {})
  if not url or url == "" then return end

  local maxGroesse = (c.Warteschlange and c.Warteschlange.MaxGroesse) or 5000
  if #queue >= maxGroesse then
    if debug() then
      print(("[hm_buergerportal] WARN: Webhook-Queue voll, verwerfe Event: %s"):format(tostring(eventName)))
    end
    return
  end

  table.insert(queue, {
    event               = tostring(eventName),
    url                 = url,
    data                = data or {},
    versuch             = 1,
    naechsterVersuchNach = nil,
  })

  arbeiteQueue()
end

--- Sendet direkt an eine übergebene URL (für Admin-Test).
--- Gibt das Embed-Objekt zurück und sendet asynchron.
function WebhookService.SendDirektTest(url, spielerName, cb)
  local identCfg = ident()
  local embed = {
    title       = "🔔 Webhook-Test",
    description = ("Webhook-Test von **%s** – die Verbindung funktioniert."):format(
                    tostring(spielerName or "Administrator")),
    color       = 0x3447DB,
    fields      = {
      { name = "Akteur",    value = tostring(spielerName or "Administrator"), inline = true },
      { name = "Zeitpunkt", value = nowIsoUtc(),                              inline = true },
    },
    footer    = { text = identCfg.Footer or "HM Bürgerportal Admin-Panel" },
    timestamp = nowIsoUtc(),
  }
  local msg = {
    username   = identCfg.Benutzername or "HM Bürgerportal (Test)",
    avatar_url = identCfg.AvatarUrl,
    embeds     = { embed },
  }
  local payload = json.encode(msg)
  PerformHttpRequest(url, function(code, body, headers)
    if cb then cb(tonumber(code or 0), body) end
  end, "POST", payload, { ["Content-Type"] = "application/json" })
end

HM_BP.Server.Dienste.WebhookService = WebhookService
