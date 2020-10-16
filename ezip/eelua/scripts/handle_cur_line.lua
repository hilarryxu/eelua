local string = require"string"
local path = require"minipath"

local str_fmt = string.format

local dir_envir = "D:\\Mirserver\\Mir200\\Envir"
-- local dir_mirserver = [[E:\clear\Envir]]

function trim(s)
  return s:match("^%s*(.-)%s*$")
end

local doc = App.active_doc
local fullpath = doc.fullpath or ""
if string.contains(fullpath, "Envir") then
  local parts = string.explode(fullpath, [[\]], true)
  local out = {}
  for i, v in ipairs(parts) do
    table.insert(out, v)
    if v == "Envir" then
      break
    end
  end
  dir_envir = table.concat(out, [[\]])
end
local text = trim(doc:getline("."))
local parts = string.explode(text, "[%s]+")
if #parts >= 7 then
  local npc_fn = path.join(dir_envir, "Market_Def",
                           str_fmt("%s-%s.txt", parts[1], parts[2]))
  -- App:output_line(str_fmt("npc_fn: %s", npc_fn))
  App:open_doc(npc_fn, 936)
elseif #parts >= 2 and parts[1]:upper() == "#CALL" then
  local script_name = parts[2]:sub(2, -2)
  local script_fn = path.join(dir_envir, "QuestDiary",
                              script_name)
  -- App:output_line(str_fmt("script_fn: %s", script_fn))
  App:open_doc(script_fn, 936)
elseif #parts >= 2 then
  for _, val in ipairs(parts) do
    if string.contains(val, "QuestDiary") or string.contains(val, "questdiary") then
      local fn = path.join(dir_envir, "Market_Def", val)
      fn = path.getabsolute(fn)
      App:open_doc(fn, 936)
      break
    end
  end
end
