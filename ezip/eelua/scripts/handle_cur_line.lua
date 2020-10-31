local string = require "string"
local table = require "table"
local io = require "io"
local path = require "minipath"
local lfs = require "lfs"

local str_fmt = string.format
local tinsert = table.insert
local tconcat = table.concat

local CP_GB2312 = 936
local dir_envir = [[D:\Mirserver\Mir200\Envir]]

local function ensure_fn(fn, content)
  fn = path.getabsolute(fn)
  content = content or "\r\n"
  if not lfs.exists_file(fn) then
    local parent_dir = path.getdirectory(fn)
    if not lfs.exists_dir(parent_dir) then
      lfs.mkdir(parent_dir)
    end
    io.writefile(fn, content)
  end
  return fn
end

-- main
local doc = App.active_doc
local fullpath = doc.fullpath or ""
local i, j = fullpath:find("Envir")
if j then
  dir_envir = path.getabsolute(fullpath:sub(1, j))
end

local text = doc:getline("."):trim()
local parts = string.explode(text, "[%s]+")
if #parts >= 7 then
  -- 处理 MerChant.txt 中的 NPC 文件跳转（自动新建）
  parts[1] = string.trim(parts[1]:gsub(";", ""))
  local npc_fn = path.join(dir_envir, "Market_Def",
                           str_fmt("%s-%s.txt", parts[1], parts[2]))
  npc_fn = ensure_fn(npc_fn, "[@main]\r\n\r\n")
  App:open_doc(npc_fn, CP_GB2312)
elseif #parts >= 2 and parts[1] == ";#include" then
  local fn = path.join(dir_envir, "QuestDiary\\_include", parts[2])
  fn = ensure_fn(fn)
  App:open_doc(fn, CP_GB2312)
elseif #parts >= 2 and string.contains(parts[1]:upper(), "#CALL") then
  -- 处理 #CALL 调用跳转（支持注释过的行）
  local script_name = parts[2]:sub(2, -2)
  local fn = path.join(dir_envir, "QuestDiary", script_name)
  fn = ensure_fn(fn)
  App:open_doc(fn, CP_GB2312)
elseif #parts >= 2 and string.contains(parts[1]:upper(), "NNDOLUASCRIPT") then
  local script_name = parts[2]
  local fn = path.join(dir_envir, "QuestDiary", script_name)
  fn = ensure_fn(fn)
  App:open_doc(fn, CP_GB2312)
elseif #parts >= 2 then
  -- 处理 QuestDiary 下文件引用跳转
  for _, val in ipairs(parts) do
    if string.contains(val, "QuestDiary") or string.contains(val, "questdiary") then
      local fn = path.join(dir_envir, "Market_Def", val)
      fn = path.getabsolute(fn)
      App:open_doc(fn, CP_GB2312)
      break
    end
  end
end
