HM_BP = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}

local Util = {}

function Util.IsBlank(str)
  return str == nil or tostring(str):gsub("%s+", "") == ""
end

function Util.DeepCopy(obj, seen)
  if type(obj) ~= "table" then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = {}
  s[obj] = res
  for k, v in pairs(obj) do
    res[Util.DeepCopy(k, s)] = Util.DeepCopy(v, s)
  end
  return setmetatable(res, getmetatable(obj))
end

function Util.NowUnix()
  return os.time(os.date("!*t"))
end

function Util.SafeJsonEncode(obj)
  local ok, encoded = pcall(json.encode, obj)
  if not ok then return "null" end
  return encoded
end

function Util.SafeJsonDecode(str)
  if str == nil then return nil end
  local ok, decoded = pcall(json.decode, str)
  if not ok then return nil end
  return decoded
end

HM_BP.Shared.Util = Util