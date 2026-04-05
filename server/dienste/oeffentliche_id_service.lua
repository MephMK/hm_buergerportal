HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local OeffentlicheIdService = {}

local function linkeNullen(zahl, stellen)
  local s = tostring(zahl)
  while #s < stellen do
    s = "0" .. s
  end
  return s
end

local function aktuellesJahrMonatUtc()
  -- UTC, damit Serverzeit konsistent ist (nicht von lokaler Zeitzone abhängig)
  local t = os.date("!*t")
  local jahr = t.year
  local monat = t.month
  local ym = string.format("%04d-%02d", jahr, monat)
  return jahr, monat, ym
end

-- Liefert: "HM-DOJ-YYYY-MM-000001"
function OeffentlicheIdService.NaechsteAntragsNummerErzeugen()
  if not Config.Kern.OeffentlicheIds or Config.Kern.OeffentlicheIds.Aktiviert ~= true then
    return nil, "Öffentliche IDs sind deaktiviert."
  end

  local prefix = Config.Kern.OeffentlicheIds.Prefix or "HM-DOJ"
  local stellen = tonumber(Config.Kern.OeffentlicheIds.Stellen or 6) or 6

  local _, _, ym = aktuellesJahrMonatUtc()

  -- Atomar per INSERT .. ON DUPLICATE KEY UPDATE, seq++ und dann seq lesen.
  -- Dadurch keine Race-Conditions bei vielen gleichzeitigen Anträgen.
  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_public_id_sequences (ym, seq)
    VALUES (?, 1)
    ON DUPLICATE KEY UPDATE seq = LAST_INSERT_ID(seq + 1)
  ]], { ym })

  local seq = HM_BP.Server.Datenbank.Skalar("SELECT LAST_INSERT_ID()", {})
  if not seq then
    return nil, "Konnte Sequenznummer nicht ermitteln."
  end

  local nummer = linkeNullen(seq, stellen)
  local publicId = string.format("%s-%s-%s", prefix, ym, nummer)

  return publicId, nil
end

HM_BP.Server.Dienste.OeffentlicheIdService = OeffentlicheIdService