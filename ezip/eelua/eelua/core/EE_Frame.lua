local ffi = require"ffi"
local eelua = require"eelua"
local base = require"eelua.core.base"
local unicode = require"unicode"

local C = eelua.C
local ffi_new = ffi.new
local ffi_cast = ffi.cast
local send_message = base.send_message

ffi.cdef[[
typedef struct {
  HWND hwnd;
} EE_Frame;
]]

local _M = {}
local mt = {
  __index = function(self, k)
    if k == "doc" then
      return _M.get_doc(self)
    elseif k == "fullpath" then
      return _M.get_fullpath(self)
    elseif k == "frame_type" then
      return _M.get_frame_type(self)
    end
    return _M[k]
  end
}

function _M.new(hwnd)
  if tonumber(hwnd) == 0 then
    return nil
  end
  return ffi_new("EE_Frame", { hwnd })
end

function _M:get_fullpath()
  return App:get_frame_fullpath(self.hwnd)
end

function _M:get_doc()
  return App:get_doc_from_frame(self.hwnd)
end

function _M:get_frame_type()
  return tonumber(send_message(App.hMain, C.EEM_GETFRAMETYPE, self.hwnd))
end

ffi.metatype("EE_Frame", mt)

return _M
