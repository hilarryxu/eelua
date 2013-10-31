--
-- Init hooks for eelua
--

eehooks = {}

eelua.bind_event = function(event, func)
  if not eehooks[event] then
    eehooks[event] = {}
  end
  table.insert(eehooks[event], func)
end

local hook_names = {
  'presave',
  'postsave',
  'preclose',
  'postclose',
  'appmsg',
  'idle',
  'appactivate',
  'runcommand',
  'preload',
  'postload',
  'postnewtext',
  'textchar',
  'textcommand',
  'closewordcomplete',
}

local function handle_event(event, ...)
  local funcs = eehooks[event]
  local block = false
  if funcs and type(funcs) == 'table' then
    for _, func in ipairs(funcs) do
      block = func(...) or block
    end
  end
  return block
end

for _, event in ipairs(hook_names) do
  _G['eehook_' .. event] = function (...) return handle_event(event, ...) end
end

