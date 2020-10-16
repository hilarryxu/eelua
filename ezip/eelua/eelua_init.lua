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
for _, v in ipairs(lfs.list_dir(dir_lua_scripts)) do
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
  return 0
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

ee_context:set_hook(C.EEHOOK_RUNCOMMAND, OnRunningCommand)
ee_context:set_hook(C.EEHOOK_APPMSG, OnAppMessage)
ee_context:set_hook(C.EEHOOK_PREEXECUTESCRIPT, OnPreExecuteScript)
