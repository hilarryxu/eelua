local ffi = require"ffi"
local eelua = require"eelua"
local base = require"eelua.core.base"
local EE_Document = require"eelua.core.EE_Document"
local unicode = require"unicode"

local C = ffi.C
local ffi_new = ffi.new
local ffi_cast = ffi.cast
local send_message = base.send_message

local _M = {}
local mt = {
  __index = function(self, k)
    if k == "active_doc" then
      return _M.get_active_doc(self)
    elseif k == "frame_count" then
      return _M.get_frame_count(self)
    end
    return _M[k]
  end
}

function _M:api_call(hwnd, msg, wparam, lparam)
  return C.SendMessageA(self.hMain, msg, wparam or 0, lparam or 0)
end

function _M:set_hook(name, func)
  return send_message(self.hMain, C.EEM_SETHOOK, name, ffi_cast("intptr_t", func))
end

function _M:get_active_doc()
  local hwnd = ffi_cast("HWND", send_message(self.hMain, C.EEM_GETACTIVETEXT))
  return EE_Document.new(hwnd)
end

function _M:open_doc(filepath, codepage, view_type)
  local p = ffi_new("EE_LoadFile[1]")
  p[0].nCodepage = codepage or 0
  p[0].nViewType = view_type or 1
  local hwnd = ffi_cast("HWND", send_message(self.hMain, C.EEM_LOADFILE, unicode.a2w(filepath), p))
  return EE_Document.new(hwnd)
end

function _M:output_text(text)
  local wstr, wlen = unicode.a2w(text)
  send_message(self.hMain, C.EEM_OUTPUTTEXT, wstr, wlen)
end

function _M:output_line(text)
  self:output_text(text .. "\n")
end

function _M:next_cmd_id()
  self.dwCommand = self.dwCommand + 1
  return self.dwCommand
end

function _M:execute_script(script_fn, just_execute)
  local wstr, wlen = unicode.a2w(script_fn)
  send_message(self.hMain, C.EEM_EXCUTESCRIPT, wstr, just_execute and 1 or 0)
end

function _M:get_frame_count()
  return tonumber(send_message(self.hMain, C.EEM_GETFRAMELIST, 0))
end

function _M:update_uielement(cmd_id, action, value)
  local p = ffi_new("EE_UpdateUIElement[1]")
  p[0].action = action
  p[0].value = value or 0
  send_message(self.hMain, C.EEM_UPDATEUIELEMENT, cmd_id, p)
end

function _M:get_active_frame()
  local hwnd = ffi_cast("HWND", send_message(self.hMain, C.EEM_GETACTIVEFRAME))
  return hwnd
end

function _M:show_dialog(dlg_id, settings)
  send_message(self.hMain, C.EEM_SWOWDIALOG, dlg_id, settings or "")
end

ffi.metatype("EE_Context", mt)

return _M
