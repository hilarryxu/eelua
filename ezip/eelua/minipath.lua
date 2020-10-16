local table = require"table"
require"eelua.stdext"

local tinsert = table.insert
local tconcat = table.concat

local DIRSEP = "\\"
local _M = {}

local function iif(expr, trueval, falseval)
  if (expr) then
    return trueval
  else
    return falseval
  end
end

function _M.isabsolute(p)
  return p:sub(2, 2) == ":"
end

function _M.getdirectory(p)
  local i = p:findlast("[/\\]")
  if i then
    if i > 1 then i = i - 1 end
    return p:sub(1, i)
  else
    return "."
  end
end

function _M.getdrive(p)
  local ch1 = p:sub(1, 1)
  local ch2 = p:sub(2, 2)
  if ch2 == ":" then
    return ch1
  end
end

function _M.getextension(p)
  local i = p:findlast(".", true)
  if i then
    return p:sub(i)
  else
    return ""
  end
end

function _M.getname(p)
  local i = p:findlast("[/\\]")
  if i then
    return p:sub(i + 1)
  else
    return p
  end
end

function _M.getbasename(p)
  local name = _M.getname(p)
  local i = name:findlast(".", true)
  if i then
    return name:sub(1, i - 1)
  else
    return name
  end
end

function _M.translate(p, sep)
  if type(p) == "table" then
    local result = {}
    for _, value in ipairs(p) do
      tinsert(result, _M.translate(value))
    end
    return result
  else
    if not sep then
      sep = DIRSEP
    end
    local result = p:gsub("[/\\]", sep)
    return result
  end
end

function _M.join(...)
  local numargs = select("#", ...)
  if numargs == 0 then
    return ""
  end

  local allparts = {}
  for i = numargs, 1, -1 do
    local part = select(i, ...)
    if part and #part > 0 and part ~= "." then
      while part:endswith(DIRSEP) do
        part = part:sub(1, -2)
      end

      tinsert(allparts, 1, part)
      if _M.isabsolute(part) then
        break
      end
    end
  end

  return tconcat(allparts, DIRSEP)
end

function _M.getabsolute(p)
  p = _M.translate(p, DIRSEP)
  if (p == "") then p = "." end

  local result = nil
  for n, part in ipairs(p:explode(DIRSEP, true)) do
    if (part == "" and n == 1) then
      result = "/"
    elseif (part == "..") then
      result = _M.getdirectory(result)
    elseif (part ~= ".") then
      result = _M.join(result, part)
    end
  end
  result = iif(result:endswith(DIRSEP), result:sub(1, -2), result)

  return result
end

_M.DIRSEP = DIRSEP

return _M
