--
-- Load plugins
--

eelua.plugins = {}

local plugin_basedir = eelua.eelua_plugins_path

function plugin(option)
  if option.name then
    table.insert(eelua.plugins, option)
  end
end

if os.isdir(plugin_basedir) then
  for _, plugin_name in ipairs(os.readdir(plugin_basedir)) do
    local plugin_path = path.join(plugin_basedir, plugin_name)
    local plugin_lua_fn = path.join(plugin_path, 'plugin.lua')
    if os.isfile(plugin_lua_fn) then
      dofile(plugin_lua_fn)
    end
  end
end

