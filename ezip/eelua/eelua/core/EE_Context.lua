local ffi = require"ffi"
local table = require"table"
local eelua = require"eelua"
local base = require"eelua.core.base"
local EE_Document = require"eelua.core.EE_Document"
local EE_Frame = require"eelua.core.EE_Frame"
local unicode = require"unicode"

local C = ffi.C
local ffi_new = ffi.new
local ffi_cast = ffi.cast
local tinsert = table.insert
local send_message = base.send_message

local _M = {}
local mt = {
  __index = function(self, k)
    if k == "active_doc" then
      return _M.get_active_doc(self)
    elseif k == "frame_nr" then
      return _M.get_frame_nr(self)
    elseif k == "active_frame" then
      return _M.get_active_frame(self)
    elseif k == "frames" then
      return _M.get_frames(self)
    elseif k == "app_metrics" then
      return tonumber(send_message(self.hMain, C.EEM_GETAPPMETRICS))
    end
    return _M[k]
  end
}

function _M:send_message(msg, wparam, lparam)
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
  p[0].nCodepage = codepage or C.CODEPAGE_AUTO
  p[0].nViewType = view_type or C.VIEWTYPE_TEXT
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

function _M:get_output_doc(show)
  local hwnd = ffi_cast("HWND", send_message(self.hMain, C.EEM_GETOUTPUTHWND, show and 1 or 0))
  return EE_Document.new(hwnd)
end

function _M:next_cmd_id()
  self.dwCommand = self.dwCommand + 1
  return tonumber(self.dwCommand)
end

function _M:execute_script(script_fn, just_execute)
  local wstr, wlen = unicode.a2w(script_fn)
  send_message(self.hMain, C.EEM_EXCUTESCRIPT, wstr, just_execute and 1 or 0)
end

function _M:update_ui_element(cmd_id, action, value)
  local p = ffi_new("EE_UpdateUIElement[1]")
  p[0].action = action
  p[0].value = value or 0
  send_message(self.hMain, C.EEM_UPDATEUIELEMENT, cmd_id, p)
end

function _M:get_frame_nr()
  return tonumber(send_message(self.hMain, C.EEM_GETFRAMELIST, 0))
end

function _M:get_frame_fullpath(frame_hwnd)
  local wtext = ffi_cast("wchar_t*", send_message(self.hMain, C.EEM_GETFRAMEPATH, frame_hwnd))
  return unicode.w2a(wtext, C.lstrlenW(wtext))
end

function _M:get_active_frame()
  local hwnd = ffi_cast("HWND", send_message(self.hMain, C.EEM_GETACTIVEFRAME))
  return EE_Frame.new(hwnd)
end

function _M:set_active_frame(index)
  local p_hwnds = ffi_new("HWND[1025]")
  local count = tonumber(send_message(self.hMain, C.EEM_GETFRAMELIST, p_hwnds))
  if index > count then
    return false
  end

  local rc = tonumber(send_message(self.hMain, C.EEM_SETACTIVEVIEW, p_hwnds[index - 1]))
  return rc == 1
end

function _M:get_frames(hwnd_sz)
  hwnd_sz = hwnd_sz or 1024
  local p_hwnds = ffi_new("HWND[?]", hwnd_sz + 1)

  local count = tonumber(send_message(self.hMain, C.EEM_GETFRAMELIST, p_hwnds))
  local frames = {}
  for i = 0, count - 1 do
    tinsert(frames, EE_Frame.new(p_hwnds[i]))
  end

  return frames
end

function _M:get_doc_from_frame(frame_hwnd)
  local hwnd = ffi_cast("HWND", send_message(self.hMain, C.EEM_GETDOCFROMFRAME, frame_hwnd))
  return EE_Document.new(hwnd)
end

function _M:get_doc(index, hwnd_sz)
  hwnd_sz = hwnd_sz or 1024
  local p_hwnds = ffi_new("HWND[?]", hwnd_sz + 1)

  local count = tonumber(send_message(self.hMain, C.EEM_GETFRAMELIST, p_hwnds))
  if index > count then
    return nil
  end
  return self:get_doc_from_frame(p_hwnds[index - 1])
end

function _M:get_view_type(frame_hwnd)
  return tonumber(send_message(self.hMain, C.EEM_SETVIEWTYPE, frame_hwnd, 0xFF))
end

function _M:set_view_type(frame_hwnd, value)
  send_message(self.hMain, C.EEM_SETVIEWTYPE, frame_hwnd, value)
end

function _M:get_frame_from_path(path)
  local wpath, wlen = unicode.a2w(path)
  local frame_hwnd = tonumber(send_message(self.hMain, C.EEM_GETFRAMEFROMPATH, wpath))
  return EE_Frame.new(frame_hwnd)
end

ffi.metatype("EE_Context", mt)

return _M
