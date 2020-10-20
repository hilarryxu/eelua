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
} EE_Document;
]]

local _M = {}
local mt = {
  __index = function(self, k)
    if k == "cursor" then
      return _M.get_cursor(self)
    elseif k == "fullpath" then
      return _M.get_fullpath(self)
    elseif k == "line_nr" then
      return tonumber(send_message(self.hwnd, C.ECM_GETLINECNT))
    elseif k == "visual_line_nr" then
      return tonumber(send_message(self.hwnd, C.ECM_GETVISUALLINECOUNT))
    elseif k == "font_height" then
      return tonumber(send_message(self.hwnd, C.ECM_GETFONTHEIGHT))
    elseif k == "edit_mode" then
      return tonumber(send_message(self.hwnd, C.ECM_EDITMODE, 0xFF))
    elseif k == "sel_type" then
      return _M.get_sel_type(self)
    elseif k == "text" then
      return _M.gettext(self)
    elseif k == "sel_text" then
      return _M.get_sel_text(self)
    elseif k == "eol_type" then
      return tonumber(send_message(self.hwnd, C.ECM_SETEOLTYPE, 0xFF))
    elseif k == "encoding" then
      return tonumber(send_message(self.hwnd, C.ECM_GETBUFFERENCODING, 0))
    end
    return _M[k]
  end,
  __newindex = function(self, k, v)
    if k == "text" then
      _M.delete(self)
      _M.insert(self, v)
    elseif k == "eol_type" then
      send_message(self.hwnd, C.ECM_SETEOLTYPE, v)
    elseif k == "edit_mode" then
      send_message(self.hwnd, C.ECM_EDITMODE, v)
    elseif k == "wrap_mode" then
      send_message(self.hwnd, C.ECM_WRAP, v)
    elseif k == "fold_method" then
      send_message(self.hwnd, C.ECM_SETFOLDMETHOD, v)
    elseif k == "encoding" then
      send_message(self.hwnd, C.ECM_GETBUFFERENCODING, 1, v)
    else
      error("unkown prop " .. k .. " for EE_Document")
    end
  end
}

function _M.new(hwnd)
  return ffi_new("EE_Document", { hwnd })
end

function _M:get_cursor()
  local p_pos = ffi_new("EC_Pos[1]")
  send_message(self.hwnd, C.ECM_GETCARETPOS, p_pos)
  return p_pos[0]
end

function _M:set_cursor(cursor, visible)
  local p_pos = ffi_new("EC_Pos[1]")
  p_pos[0].line = cursor.line
  p_pos[0].col = cursor.col

  send_message(self.hwnd, C.ECM_SETPOS, p_pos, visible and 1 or 0)
end

function _M:getline(lnum)
  if lnum == "." then
    lnum = self.cursor.line
  elseif lnum < 0 or lnum >= self.line_nr then
    return ""
  end
  local wtext = ffi_cast("wchar_t*", send_message(self.hwnd, C.ECM_GETLINEBUF, lnum))
  return unicode.w2a(wtext, C.lstrlenW(wtext))
end

function _M:setline(lnum, text)
  if lnum == "." then
    lnum = self.cursor.line
  elseif lnum < 0 or lnum >= self.line_nr then
    return false
  end

  self:set_cursor({ line = lnum, col = 0 })
  self:send_command(80)  -- ECC_DELTOLINETAIL
  self:insert(text)
end

function _M:get_fullpath()
  local wtext = ffi_cast("wchar_t*", send_message(self.hwnd, C.ECM_GETPATH))
  return unicode.w2a(wtext, C.lstrlenW(wtext))
end

function _M:gettext(begin_pos, end_pos, eol_type)
  begin_pos = begin_pos or { line = 0, col = 0 }
  end_pos = end_pos or { line = C.INT_MAX, col = C.INT_MAX }

  local sel_ptr = ffi_new("EC_SelInfo[1]")
  sel_ptr[0].bpos_line = begin_pos.line
  sel_ptr[0].bpos_col = begin_pos.col
  sel_ptr[0].epos_line = end_pos.line
  sel_ptr[0].epos_col = end_pos.col
  sel_ptr[0].lpBuffer = nil
  sel_ptr[0].nEol = eol_type or C.EC_EOL_NULL

  local wlen = tonumber(send_message(self.hwnd, C.ECM_GETTEXT, sel_ptr))

  local strbuf = base.get_string_buf((wlen + 3) * 2)
  sel_ptr[0].lpBuffer = ffi_cast("wchar_t*", strbuf)
  send_message(self.hwnd, C.ECM_GETTEXT, sel_ptr)
  return unicode.w2a(sel_ptr[0].lpBuffer, wlen), wlen
end

function _M:delete(begin_pos, end_pos)
  begin_pos = begin_pos or { line = 0, col = 0 }
  end_pos = end_pos or { line = C.INT_MAX, col = C.INT_MAX }

  local bpos_ptr = ffi_new("EC_Pos[1]")
  bpos_ptr[0].line = begin_pos.line
  bpos_ptr[0].col = begin_pos.col
  local epos_ptr = ffi_new("EC_Pos[1]")
  epos_ptr[0].line = end_pos.line
  epos_ptr[0].col = end_pos.col

  send_message(self.hwnd, C.ECM_DELETETEXT, bpos_ptr, epos_ptr)
end

function _M:insert(text)
  local wtext, wlen = unicode.a2w(text)
  local insert_text_ptr = ffi_new("EC_InsertText[1]")
  insert_text_ptr[0].wtext = wtext
  insert_text_ptr[0].wlen = wlen

  send_message(self.hwnd, C.ECM_INSERTTEXT, 0, insert_text_ptr)
end

function _M:insert_at(line, col, text)
  local pos_ptr = ffi_new("EC_Pos[1]")
  pos_ptr[0].line = line
  pos_ptr[0].col = col

  local wtext, wlen = unicode.a2w(text)
  local insert_text_ptr = ffi_new("EC_InsertText[1]")
  insert_text_ptr[0].wtext = wtext
  insert_text_ptr[0].wlen = wlen

  send_message(self.hwnd, C.ECM_INSERTTEXT, pos_ptr, insert_text_ptr)
end

function _M:gotoline(line)
  send_message(self.hwnd, C.ECM_JUMPTOLINE, line)
end

function _M:redraw()
  send_message(self.hwnd, C.ECM_REDRAW)
end

function _M:send_command(cmd)
  send_message(self.hwnd, C.WM_COMMAND, cmd)
end

function _M:get_sel_type()
  return tonumber(send_message(self.hwnd, C.ECM_HASSEL))
end

function _M:get_sel()
  local bpos_ptr = ffi_new("EC_Pos[1]")
  local epos_ptr = ffi_new("EC_Pos[1]")

  local rc = send_message(self.hwnd, C.ECM_GETSEL, bpos_ptr, epos_ptr)
  return rc ~= 0, bpos_ptr[0], epos_ptr[0]
end

function _M:set_sel(begin_pos, end_pos)
  begin_pos = begin_pos or { line = 0, col = 0 }
  end_pos = end_pos or { line = C.INT_MAX, col = C.INT_MAX }

  local bpos_ptr = ffi_new("EC_Pos[1]")
  bpos_ptr[0].line = begin_pos.line
  bpos_ptr[0].col = begin_pos.col
  local epos_ptr = ffi_new("EC_Pos[1]")
  epos_ptr[0].line = end_pos.line
  epos_ptr[0].col = end_pos.col

  send_message(self.hwnd, C.ECM_SETSEL, bpos_ptr, epos_ptr)
end

function _M:get_sel_text()
  local hmem = ffi_cast("HANDLE", send_message(self.hwnd, C.ECM_GETSELTEXT))
  local wtext = ffi_cast("wchar_t*", C.GlobalLock(hmem))
  local text = unicode.w2a(wtext, C.lstrlenW(wtext))
  C.GlobalUnlock(hmem)
  return text
end

function _M:is_dirty()
  return tonumber(send_message(self.hwnd, C.ECM_ISDOCDIRTY)) ~= 0
end

function _M:comment_line(comment, yes_or_no)
  local val = send_message(self.hwnd, C.ECM_COMMENTLINE,
                           unicode.a2w(comment),
                           yes_or_no and 1 or 0)
  return val ~= 0
end

function _M:can_undo()
  return tonumber(send_message(self.hwnd, C.ECM_CANUNDO)) ~= 0
end

function _M:can_redo()
  return tonumber(send_message(self.hwnd, C.ECM_CANREDO)) ~= 0
end

function _M:force_caret_visible()
  send_message(self.hwnd, C.ECM_FORCECARETVISIBLE)
end

function _M:move_cursor(offset)
  send_message(self.hwnd, C.ECM_MOVECARET, offset)
end

function _M:get_wrap_count(lnum)
  return tonumber(send_message(self.hwnd, C.ECM_WRAPCOUNT, lnum))
end

function _M:insert_snippet(text)
  local wtext, wlen = unicode.a2w(text)
  send_message(self.hwnd, C.ECM_INSERTSNIPPET, wtext, wlen)
end

function _M:clear_dirty()
  send_message(self.hwnd, C.ECM_CLEARDIRTY)
end

function _M:get_scope()
  local wtext = ffi_cast("wchar_t*", send_message(self.hwnd, C.ECM_GETSCOPE))
  local text = unicode.w2a(wtext, C.lstrlenW(wtext))
  return text
end

function _M:is_loading()
  return tonumber(send_message(self.hwnd, C.ECM_ISLOADING)) ~= 0
end

function _M:close_tag()
  return tonumber(send_message(self.hwnd, C.ECM_CLOSETAG)) ~= 0
end

function _M:op_bookmark(op, lnum)
  if op == "get" then
    return tonumber(send_message(self.hwnd, C.ECM_BOOKMARKER, 2, lnum))
  elseif op == "set" then
    send_message(self.hwnd, C.ECM_BOOKMARKER, 1, lnum)
  elseif op == "del" then
    send_message(self.hwnd, C.ECM_BOOKMARKER, 0, lnum)
  end
end

ffi.metatype("EE_Document", mt)

return _M
