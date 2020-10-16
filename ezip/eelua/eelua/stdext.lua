local string = require"string"
local table = require"table"
local io = require"io"
local os = require"os"

local tinsert = table.insert
local str_fmt = string.format
local unpack = unpack or table.unpack

function string.startswith(haystack, needle)
  return haystack:find(needle, 1, true) == 1
end

function string.endswith(haystack, needle)
  return needle == "" or haystack:sub(-#needle) == needle
end

function string.contains(s, match)
  return s:find(match, 1, true) ~= nil
end

function string.explode(s, pattern, plain)
  if pattern == "" then return false end
  local pos = 0
  local arr = {}
  for st, sp in function() return s:find(pattern, pos, plain) end do
    tinsert(arr, s:sub(pos, st-1))
    pos = sp + 1
  end
  tinsert(arr, s:sub(pos))
  return arr
end

function string.findlast(s, pattern, plain)
  local curr = 0
  repeat
    local next = s:find(pattern, curr + 1, plain)
    if (next) then curr = next end
  until (not next)
  if curr > 0 then
    return curr
  end
end


function table.contains(t, value)
  for _, v in pairs(t) do
    if (v == value) then
      return true
    end
  end
  return false
end

function table.isempty(t)
  return next(t) == nil
end

function table.keys(tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

function table.indexof(tbl, obj)
  for k, v in ipairs(tbl) do
    if v == obj then
      return k
    end
  end
end

function table.find_key_by_value(tbl, obj)
  for k, v in pairs(tbl) do
    if v == obj then
      return k
    end
  end
end

function table.implode(arr, before, after, between)
  local result = ""
  for _, v in ipairs(arr) do
    if (result ~= "" and between) then
      result = result .. between
    end
    result = result .. before .. v .. after
  end
  return result
end

function table.translate(arr, translation)
  local result = {}
  for _, value in ipairs(arr) do
    local tvalue
    if type(translation) == "function" then
      tvalue = translation(value)
    else
      tvalue = translation[value]
    end
    if (tvalue) then
      table.insert(result, tvalue)
    end
  end
  return result
end

function table.filter(arr, fn)
  local result = {}
  table.foreachi(arr, function(val)
    if fn(val) then
      table.insert(result, val)
    end
  end)
  return result
end


function io.readfile(filename)
  local file = io.open(filename, "rb")
  if file then
    local content = file:read("*a")
    file:close()
    return content
  end
end

function io.writefile(filename, content)
  local file = io.open(filename, "w+b")
  if file then
    file:write(content)
    file:close()
    return true
  end
end


function os.executef(cmd, ...)
  cmd = str_fmt(cmd, unpack(arg))
  return os.execute(cmd)
end

function os.outputof(cmd)
  local pipe = io.popen(cmd)
  local result = pipe:read('*a')
  pipe:close()
  return result
end
