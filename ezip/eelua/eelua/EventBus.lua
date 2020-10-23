local table = require "table"

local _M = {}

local function tbl_remove_value(tbl, obj)
  local idx = nil
  for k, v in ipairs(tbl) do
    if v == obj then
      idx = k
      break
    end
  end

  if idx ~= nil then
    return table.remove(tbl, idx)
  end
end

local mt = {
  __index = function(self, k)
    return _M[k]
  end
}

function _M.new()
  local self = {
    handle_map = {},
  }
  setmetatable(self, mt)
  return self
end

function _M:get_handle_count(event)
  local handlers = self.handle_map[event]
  if handlers ~= nil then
    return #handlers
  end
  return 0
end

function _M:add_event_handler(event, handler)
  local handlers = self.handle_map[event]
  if handlers == nil then
    handles = {}
    self.handle_map[event] = handles
  end

  tinsert(handlers, handler)
end

function _M:remove_event_handler(event, handler)
  local handlers = self.handle_map[event]
  if handlers == nil then
    handles = {}
    self.handle_map[event] = handles
    return false
  end

  return tbl_remove_value(handlers, handler) ~= nil
end

function _M:remove_all_event_handlers(event)
  self.handle_map[event] = {}
end

return _M
