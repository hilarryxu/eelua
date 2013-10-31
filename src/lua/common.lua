--
-- Init package.path and package.cpath
--

local eelua_path = eelua.apppath .. '/eelua'
eelua.eelua_path = eelua_path
eelua.eelua_plugins_path = eelua_path .. '/plugins'
eelua.eelua_scripts_path = eelua_path .. '/scripts'

package.path = eelua_path .. '/lua/?.lua;' .. eelua_path .. '/lua/?/init.lua'
package.cpath = eelua_path .. '/?.dll'



--
-- Global funcs and datas
--

WM_COMMAND = 0x0111

EEHOOK_RET_DONTROUTE = 0xBC614E

eelua.scriptnames = {}

function _p(msg, ...)
  eelua.dprint(string.format(msg, ...))
end

eelua.dofile = function(fn)
  local real_fn = eelua.eelua_path .. '/' .. fn
  if os.isfile(real_fn) then
    table.insert(eelua.scriptnames, fn)
    dofile(real_fn)
  end
end

