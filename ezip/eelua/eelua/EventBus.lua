local ffi = require "ffi"
local string = require "string"
local table = require "table"

local C = ffi.C
local str_fmt = string.format
local unpack = unpack or table.unpack
local tinsert = table.insert

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
    runned_handlers = {}
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
    handlers = {}
    self.handle_map[event] = handlers
  end

  tinsert(handlers, handler)
end

function _M:remove_event_handler(event, handler)
  local handlers = self.handle_map[event]
  if handlers == nil then
    handlers = {}
    self.handle_map[event] = handlers
    return false
  end

  return tbl_remove_value(handlers, handler) ~= nil
end

function _M:remove_all_event_handlers(event)
  self.handle_map[event] = {}
end

function _M:run_event_handlers(event, args, once)
  local handlers = self.handle_map[event]
  if handlers then
    for _, handler in ipairs(handlers) do
      if not once or (once and not self.runned_handlers[handler]) then
        local ok, rv = pcall(handler, unpack(args or {}))
        if once then
          self.runned_handlers[handler] = true
        end

        if not ok then
          App:output_line(str_fmt("ERR: RunEventHandler(%s): %s", event, rv))
        else
          if rv == C.EEHOOK_RET_DONTROUTE then
            break
          end
        end
      end
    end
  end
end

return _M
