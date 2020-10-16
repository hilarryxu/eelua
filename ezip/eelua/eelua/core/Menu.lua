local ffi = require"ffi"
local bit = require"bit"
local eelua = require"eelua"
local base = require"eelua.core.base"
local unicode = require"unicode"

local C = ffi.C
local ffi_new = ffi.new
local ffi_cast = ffi.cast
local send_message = base.send_message

ffi.cdef[[
typedef struct {
  HMENU hmenu;
} Menu;

static const UINT MF_STRING = 0x00000000;
static const UINT MF_SEPARATOR = 0x00000800;
static const UINT MF_POPUP = 0x00000010;
static const UINT MF_BYPOSITION = 0x00000400;

HMENU CreatePopupMenu();
BOOL IsMenu(HMENU hMenu);
int GetMenuItemCount(HMENU hMenu);
BOOL AppendMenuA(
  HMENU    hMenu,
  UINT     uFlags,
  UINT_PTR uIDNewItem,
  const char*    lpNewItem
);
BOOL InsertMenuA(
  HMENU    hMenu,
  UINT     uPosition,
  UINT     uFlags,
  UINT_PTR uIDNewItem,
  const char*   lpNewItem
);
]]

local _M = {}
local mt = {
  __index = function(self, k)
    if k == "count" then
      return _M.get_count(self)
    end
    return _M[k]
  end
}

function _M.new(hmenu)
  if hmenu == nil then
    hmenu = C.CreatePopupMenu()
  end
  assert(C.IsMenu(hmenu) == 1)
  return ffi_new("Menu", { hmenu })
end

function _M:get_count()
  return C.GetMenuItemCount(self.hmenu)
end

function _M:add_item(cmd_id, text)
  C.AppendMenuA(self.hmenu, C.MF_STRING, ffi_cast("UINT_PTR", cmd_id), text)
end

function _M:add_separator()
  C.AppendMenuA(self.hmenu, C.MF_SEPARATOR, 0, nil)
end

function _M:add_subitem(text, submenu)
  C.AppendMenuA(
    self.hmenu,
    bit.bor(C.MF_STRING, C.MF_POPUP),
    submenu.hmenu,
    text
  )
end

function _M:insert_menu(pos, text, menu)
  C.InsertMenuA(
    self.hmenu,
    pos,
    bit.bor(C.MF_BYPOSITION, C.MF_STRING, C.MF_POPUP),
    menu.hmenu,
    text
  )
end

ffi.metatype("Menu", mt)

return _M
