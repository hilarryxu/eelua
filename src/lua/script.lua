--
-- Init scripts
--

eelua.scripts = {}

local editor = eelua.editor
local script_basedir = eelua.eelua_scripts_path
local main_menu = eelua.main_menu
local script_menu = editor:menu()

local function script(name, spath)
  local cid = editor:new_commandid()
  eelua.scripts[tostring(cid)] = spath
  script_menu:add_item(cid, path.getbasename(name))
end

local function script_dir(name, spath)
  local dir_manu = editor:menu()
  for _, script_name in ipairs(os.readdir(spath)) do
    local script_path = path.join(spath, script_name)
    if os.isfile(script_path) then
      local cid = editor:new_commandid()
      eelua.scripts[tostring(cid)] = script_path
      dir_manu:add_item(cid, path.getbasename(script_name))
    end
  end
  script_menu:insert_submenu(#script_menu, dir_manu, name)
end

if os.isdir(script_basedir) then
  for _, script_name in ipairs(os.readdir(script_basedir)) do
    local script_path = path.join(script_basedir, script_name)
    if os.isdir(script_path) then
      script_dir(script_name, script_path)
    else
      script(script_name, script_path)
    end
  end
end

main_menu:insert_submenu(#main_menu - 1, script_menu, 'lua scripts')

eelua.bind_event('appmsg', function(msg, wparam, lparam)
  if msg ~= WM_COMMAND then
    return 0
  end
  local cid = tostring(wparam)
  local script_path = eelua.scripts[cid]
  if script_path then
    dofile(script_path)
  end
end)

