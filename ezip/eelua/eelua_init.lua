local package = require "package"
package.path = package.path .. [[;.\eelua\?.lua]]

local ffi = require "ffi"
local string = require "string"
local table = require "table"
local eelua = require "eelua"
require "eelua.core"
require "eelua.stdext"
require "eelua.utils"
local base = require "eelua.core.base"
local EE_Document = require "eelua.core.EE_Document"
local Menu = require "eelua.core.Menu"
local print_r = require "print_r"
local unicode = require "unicode"
local path = require "minipath"
local lfs = require "lfs"
local EventBus = require "eelua.EventBus"

local C = ffi.C
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_cast = ffi.cast
local unpack = unpack or table.unpack
local str_fmt = string.format
local tinsert = table.insert
local tconcat = table.concat

---
-- globals
---
App = ffi_cast("EE_Context*", eelua._ee_context)
local event_bus = EventBus.new()
eelua.event_bus = event_bus

print = function(...)
  local out = {}
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    tinsert(out, tostring(arg))
  end
  App:output_line(tconcat(out, "\t"))
end

local function err(fmt, ...)
  local msg = str_fmt(fmt, ...)
  eelua.dprint(msg)
  App:output_line(msg)
end

local app_path_strbuf = base.get_string_buf()
C.GetModuleFileNameA(App.hModule, app_path_strbuf, base.get_string_buf_size())
eelua.app_path = path.getdirectory(path.getabsolute(ffi_str(app_path_strbuf)))

function eelua.add_event_handler(event, handler)
  event_bus:add_event_handler(event, handler)
end

function eelua.remove_event_handler(event, handler)
  return event_bus:remove_event_handler(event, handler)
end

function eelua.remove_all_event_handlers(event)
  event_bus:remove_all_event_handlers(event)
end

local _plugin_commands = {}
function eelua.add_plugin_command(opts)
  tinsert(_plugin_commands, opts)
end

local _console_commands = {}
function eelua.add_console_command(opts)
  tinsert(_console_commands, opts)
end

local _wm_commands = {}
function eelua.register_wm_command(cmd_id, opts)
  if type(opts) == "function" then
    opts = { func = opts }
  end
  opts = opts or {}
  opts.cmd_id = cmd_id
  _wm_commands[tostring(cmd_id)] = opts
end

eelua.add_plugin_command {
  name = "pl_eelua_execute_current_file",
  desc = "Execute current lua script file",
  func = function()
    local fn = App.active_doc.fullpath
    if fn ~= "" and not fn:contains([[eelua\scripts\F5.lua]]) then
      if fn:endswith(".lua") then
        local ok, errmsg = pcall(dofile, fn)
        if not ok then
          err("ERR: RunScript: %s", errmsg)
        end
      end
    end
  end
}

eelua.add_console_command {
  match = "^lua$",
  desc = "Run a chunk of lua code",
  func = function(name, cmdline)
    local chunk, errmsg = load(cmdline, "=cmdline")
    if not chunk then
      err("ERR: cmdline lua: %s", errmsg)
      return
    end
    local ok, errmsg = pcall(chunk)
    if not ok then
      err("ERR: cmdline lua: %s", errmsg)
    end
  end
}

---
-- load eeluarc.lua
---
local eeluarc_fpath = path.join(eelua.app_path, [[eelua\eeluarc.lua]])
if lfs.exists_file(eeluarc_fpath) then
  local ok, errmsg = pcall(dofile, eeluarc_fpath)
  if not ok then
    err("ERR: load eeluarc.lua: %s", errmsg)
  end
end


---
-- load plugins
---
local plugins_dir = path.join(eelua.app_path, [[eelua\plugins]])
for _, v in ipairs(lfs.list_dir(plugins_dir, "file")) do
  if v:endswith(".lua") then
    local fn = path.join(plugins_dir, v)
    local ok, errmsg = pcall(dofile, fn)
    if not ok then
      err("ERR: LoadPlugin: %s", errmsg)
    end
  end
end


---
-- init menu
---
eelua.main_menu = Menu.new(App.hMainMenu)
eelua.plugin_menu = Menu.new(App.hPluginMenu)
local script_menu = Menu.new()
local scripts_dir = path.join(eelua.app_path, [[eelua\scripts]])
for _, v in ipairs(lfs.list_dir(scripts_dir, "file")) do
  if v:endswith(".lua") then
    local cmd_id = App:next_cmd_id()
    script_menu:add_item(cmd_id, v)
    eelua.register_wm_command(cmd_id, {
      type = "_script",
      script_path = path.join(scripts_dir, v)
    })
  end
end
eelua.plugin_menu:add_subitem("lua scripts", script_menu)


---
-- init hooks
---
OnDoFile = function(ctx, rect, wtext)
  local text = unicode.w2a(wtext, C.lstrlenW(wtext))
  local params = string.explode(text, "^^", true)
  local nparams = #params
  assert(nparams > 0)

  local filepath = path.join(eelua.app_path, params[1])
  local ok, chunk = pcall(dofile, filepath)
  if not ok then
    err("ERR: OnDoFile: %s", chunk)
    return
  end
  if nparams > 1 then
    local func = chunk(params[2])
    func(unpack(select(3, unpack(params))))
  end
end

OnRunningCommand = ffi_cast("pfnOnRunningCommand", function(wcommand, wlen)
  local command = unicode.w2a(wcommand, wlen)
  local name, cmdline = command
  local space_idx = command:find(" ", 1, true)
  if space_idx then
    name = command:sub(1, space_idx - 1)
    cmdline = command:sub(space_idx + 1)
  end

  for i, cmd in ipairs(_console_commands) do
    if name:match(cmd.match) then
      local ok, errmsg = pcall(cmd.func, name, cmdline)
      if not ok then
        err("ERR: RunningCommand: %s", errmsg)
      end
      return C.EEHOOK_RET_DONTROUTE
    end
  end
  return 0
end)

OnAppMessage = ffi_cast("pfnOnAppMessage", function(msg, wparam, lparam)
  if msg == C.WM_COMMAND then
    local cmd_id = tonumber(wparam)
    if cmd_id >= 65536 + 40000 then
      cmd_id = cmd_id - 65536
    end

    local cmd_info = _wm_commands[tostring(cmd_id)]
    if cmd_info then
      local cmd_type = cmd_info.type or "default"
      if cmd_type == "_script" then
        local script_path = cmd_info.script_path
        if script_path then
          local ok, errmsg = pcall(dofile, script_path)
          if not ok then
            err("ERR: RunMenuScript: %s", errmsg)
          end
        end
      elseif cmd_type == "default" then
        local handler = cmd_info.func
        if handler then
          local ok, errmsg = pcall(handler)
          if not ok then
            err("ERR: RunCmdHandler: %s", errmsg)
          end
        end
      end
    end
  end

  return 0
end)

OnPreExecuteScript = ffi_cast("pfnOnPreExecuteScript", function(wpathname)
  local pathname = unicode.w2a(wpathname, C.lstrlenW(wpathname))
  if pathname:endswith(".lua") then
    local ok, msg = pcall(dofile, pathname)
    if not ok then
      err("ERR: OnPreExecuteScript: %s", msg)
    end
    return C.EEHOOK_RET_DONTROUTE
  end
  return 0
end)

OnListPluginCommand = ffi_cast("pfnOnListPluginCommand", function(hwnd)
  local row = tonumber(base.send_message(hwnd, C.LVM_GETITEMCOUNT))

  for i, cmd in ipairs(_plugin_commands) do
    local p_item = ffi_new("LVITEMA[0]")
    local cur_row = row + i - 1

    p_item[0].mask = C.LVIF_TEXT
    p_item[0].iItem = cur_row
    p_item[0].iSubItem = 0
    p_item[0].pszText = ""
    base.send_message(hwnd, C.LVM_INSERTITEMA, 0, p_item)

    p_item[0].iSubItem = 1
    p_item[0].pszText = cmd.name
    base.send_message(hwnd, C.LVM_SETITEMTEXTA, cur_row, p_item)

    if cmd.desc then
      p_item[0].iSubItem = 2
      p_item[0].pszText = cmd.desc
      base.send_message(hwnd, C.LVM_SETITEMTEXTA, cur_row, p_item)
    end

    if cmd.long_desc then
      p_item[0].iSubItem = 3
      p_item[0].pszText = cmd.long_desc
      base.send_message(hwnd, C.LVM_SETITEMTEXTA, cur_row, p_item)
    end
  end

  return 0
end)

OnExecutePluginCommand = ffi_cast("pfnOnExecutePluginCommand", function(wcommand)
  local command = unicode.w2a(wcommand, C.lstrlenW(wcommand))
  for i, cmd in ipairs(_plugin_commands) do
    if cmd.name == command then
      local ok, errmsg = pcall(cmd.func)
      if not ok then
        err("ERR: ExecutePluginCommand: %s", errmsg)
      end
      return C.EEHOOK_RET_DONTROUTE
    end
  end
  return 0
end)

local OnPrePopupTextMenu = ffi_cast("pfn_OnPrePopupTextMenu", function(doc_hwnd, hmenu, x, y)
  local doc = EE_Document.new(doc_hwnd)
  local menu = Menu.new(hmenu)
  event_bus:run_event_handlers("OnPrePopupTextMenu", {
    doc, menu, x, y
  }, true)
  return 0
end)

if #_console_commands > 0 then
  App:set_hook(C.EEHOOK_RUNCOMMAND, OnRunningCommand)
end
App:set_hook(C.EEHOOK_APPMSG, OnAppMessage)
App:set_hook(C.EEHOOK_PREEXECUTESCRIPT, OnPreExecuteScript)
if #_plugin_commands > 0 then
  App:set_hook(C.EEHOOK_LISTPLUGINCOMMAND, OnListPluginCommand)
  App:set_hook(C.EEHOOK_EXECUTEPLUGINCOMMAND, OnExecutePluginCommand)
end
if event_bus:get_handle_count("OnPrePopupTextMenu") > 0 then
  App:set_hook(C.EEHOOK_PRETEXTMENU, OnPrePopupTextMenu)
end
