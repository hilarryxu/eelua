local package = require"package"
package.path = package.path .. [[;.\eelua\?.lua]]

local ffi = require"ffi"
local string = require"string"
local eelua = require"eelua"
require"eelua.core"
require"eelua.stdext"
require"eelua.utils"
local base = require"eelua.core.base"
local Menu = require"eelua.core.Menu"
local print_r = require"print_r"
local unicode = require"unicode"
local path = require"minipath"
local lfs = require"lfs"

local C = ffi.C
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_cast = ffi.cast
local str_fmt = string.format
local _p = eelua.printf

ee_context = ffi_cast("EE_Context*", eelua._ee_context)
App = ee_context

local app_path_strbuf = base.get_string_buf()
C.GetModuleFileNameA(ee_context.hModule, app_path_strbuf, base.get_string_buf_size())
local app_path = path.getdirectory(path.getabsolute(ffi_str(app_path_strbuf)))
eelua.app_path = app_path

eelua.main_menu = Menu.new(App.hMainMenu)
eelua.plugin_menu = Menu.new(App.hPluginMenu)

---
-- init menu
---
eelua.scripts = {}
local script_menu = Menu.new()
local dir_lua_scripts = path.join(app_path, "eelua\\scripts")
for _, v in ipairs(lfs.list_dir(dir_lua_scripts, "file")) do
  if string.contains(v, ".lua") then
    local cmd_id = App:next_cmd_id()
    local snr = str_fmt("SNR_%s", tonumber(cmd_id))
    eelua.scripts[snr] = path.join(dir_lua_scripts, v)
    script_menu:add_item(cmd_id, v)
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

  local filepath = path.join(app_path, params[1])
  local okay, chunk = pcall(dofile, filepath)
  if not okay then
    _p("ERR: OnDoFile: %s", chunk)
    return
  end
  if nparams > 1 then
    local func = chunk(params[2])
    func(unpack(select(3, unpack(params))))
  end
end

OnRunningCommand = ffi_cast("pfnOnRunningCommand", function(wcommand, wlen)
  _p("command: %s", unicode.w2a(wcommand, wlen))
  return C.EEHOOK_RET_DONTROUTE
end)

OnAppMessage = ffi_cast("pfnOnAppMessage", function(msg, wparam, lparam)
  if msg == C.WM_COMMAND then
    local cmd_id = tonumber(wparam)
    if cmd_id >= 65536 + 40000 then
      cmd_id = cmd_id - 65536
    end
    local snr = str_fmt("SNR_%s", cmd_id)
    local script_path = eelua.scripts[snr]
    if script_path then
      local okay, chunk = pcall(dofile, script_path)
      if not okay then
        _p("ERR: RunScript: %s", chunk)
      end
    end
  end
  return 0
end)

OnPreExecuteScript = ffi_cast("pfnOnPreExecuteScript", function(wpathname)
  local pathname = unicode.w2a(wpathname, C.lstrlenW(wpathname))
  local okay, chunk = pcall(dofile, pathname)
  if not okay then
    _p("ERR: OnPreExecuteScript: %s", chunk)
  end
  return 0
end)

OnListPluginCommand = ffi_cast("pfnOnListPluginCommand", function(hwnd)
  local row = tonumber(base.send_message(hwnd, C.LVM_GETITEMCOUNT))
  local p_item = ffi_new("LVITEMA[0]")

  p_item[0].mask = C.LVIF_TEXT
  p_item[0].iItem = row
  p_item[0].iSubItem = 0
  p_item[0].pszText = ""
  base.send_message(hwnd, C.LVM_INSERTITEMA, 0, p_item)

  p_item[0].iSubItem = 1
  p_item[0].pszText = "pl_eelua_execute_current_file"
  base.send_message(hwnd, C.LVM_SETITEMTEXTA, row, p_item)

  p_item[0].iSubItem = 2
  p_item[0].pszText = "Execute current lua script file"
  base.send_message(hwnd, C.LVM_SETITEMTEXTA, row, p_item)

  return 0
end)

OnExecutePluginCommand = ffi_cast("pfnOnExecutePluginCommand", function(wcommand)
  local command = unicode.w2a(wcommand, C.lstrlenW(wcommand))
  _p("command: %s", command)

  if command == "pl_eelua_execute_current_file" then
    local fn = App.active_doc.fullpath
    if fn ~= "" and not fn:contains([[eelua\scripts\F5.lua]]) then
      if fn:endswith(".lua") then
        local okay, chunk = pcall(dofile, fn)
        if not okay then
          _p("ERR: RunScript: %s", chunk)
        end
      end
    end
  end

  return 0
end)

ee_context:set_hook(C.EEHOOK_RUNCOMMAND, OnRunningCommand)
ee_context:set_hook(C.EEHOOK_APPMSG, OnAppMessage)
ee_context:set_hook(C.EEHOOK_PREEXECUTESCRIPT, OnPreExecuteScript)
ee_context:set_hook(C.EEHOOK_LISTPLUGINCOMMAND, OnListPluginCommand)
ee_context:set_hook(C.EEHOOK_EXECUTEPLUGINCOMMAND, OnExecutePluginCommand)
