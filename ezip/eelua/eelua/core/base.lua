local ffi = require"ffi"
local string = require"string"
local eelua = require"eelua"
local unicode = require"unicode"

local C = ffi.C
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_cast = ffi.cast
local str_fmt = string.format

local str_buf_size = 4096
local str_buf
local size_ptr
local errmsg
local c_buf_type = ffi.typeof("char[?]")

local ok, new_tab = pcall(require, "table.new")
if not ok then
  new_tab = function (narr, nrec) return {} end
end

local clear_tab
ok, clear_tab = pcall(require, "table.clear")
if not ok then
  local pairs = pairs
  clear_tab = function (tab)
    for k, _ in pairs(tab) do
      tab[k] = nil
    end
  end
end

local _M = new_tab(0, 20)

_M.version = "0.1.0"
_M.new_tab = new_tab
_M.clear_tab = clear_tab

function _M.get_errmsg_ptr()
  if not errmsg then
    errmsg = ffi_new("char*[1]")
  end

  return errmsg
end

function _M.get_string_buf_size()
  return str_buf_size
end

function _M.get_size_ptr()
  if not size_ptr then
    size_ptr = ffi_new("size_t[1]")
  end

  return size_ptr
end

function _M.get_string_buf(size, must_alloc)
  size = size or -1
  if size > str_buf_size or must_alloc then
    return ffi_new(c_buf_type, size)
  end

  if not str_buf then
    str_buf = ffi_new(c_buf_type, str_buf_size)
  end

  return str_buf
end

function _M.newobj(obj)
  if ffi_cast("void*", obj) > nil then
    return obj
  else
    return nil, [[it's a NULL cdata]]
  end
end

function _M.ptr2number(p)
  return tonumber(ffi_cast("intptr_t", p))
end

ffi.cdef[[
typedef uint8_t uchar;

typedef void* HANDLE;
typedef HANDLE HWND;
typedef HANDLE HMENU;
typedef HANDLE HMODULE;

typedef uint16_t WORD;
typedef uint32_t DWORD;
typedef uint32_t UINT;
typedef uint32_t* UINT_PTR;
typedef intptr_t LONG_PTR;
typedef LONG_PTR WPARAM;
typedef LONG_PTR LPARAM;
typedef LONG_PTR LRESULT;
typedef int BOOL;
typedef int WINBOOL;

typedef struct {
  HWND hMain;
  HWND hToolBar;
  HWND hStatusBar;
  HWND hClient;
  HWND hStartPage;
  HMENU hMainMenu;
  HMENU hPluginMenu;
  DWORD* pCommand;
  DWORD dwCommand;
  DWORD dwVersion;
  DWORD dwBuild;
  DWORD dwLCID;
  HMODULE hModule;
} EE_Context;

typedef struct {
  int line;
  int col;
} EC_Pos;

typedef struct {
  int bpos_line;
  int bpos_col;
  int epos_line;
  int epos_col;
  wchar_t* lpBuffer;
  int nEol;
} EC_SelInfo;

typedef struct {
  wchar_t* wtext;
  int wlen;
} EC_InsertText;

typedef struct {
  int nCodepage;
  int nViewType;
  WINBOOL bReadOnly;
  WINBOOL bAddToMRU;
  WINBOOL bAsynMode;
} EE_LoadFile;

typedef struct {
  int action;
  int value;
} EE_UpdateUIElement;

void free(void *ptr);

LRESULT SendMessageA(
  HWND   hWnd,
  UINT   Msg,
  WPARAM wParam,
  LPARAM lParam
);

DWORD GetModuleFileNameA(
  HMODULE hModule,
  char* lpFilename,
  DWORD nSize
);

void* GlobalLock(
  HANDLE hMem
);

BOOL GlobalUnlock(
  HANDLE hMem
);

typedef struct tagLVITEMA {
  UINT mask;
  int iItem;
  int iSubItem;
  UINT state;
  UINT stateMask;
  const char *pszText;
  int cchTextMax;
  int iImage;
  LPARAM lParam;
  int iIndent;
  int iGroupId;
  UINT cColumns;
  UINT_PTR puColumns;
  int *piColFmt;
  int iGroup;
} LVITEMA;

typedef int (*pfnOnRunningCommand)(const wchar_t* command, int length);
typedef int (*pfnOnAppMessage)(UINT uMsg, WPARAM wp, LPARAM lp);
typedef int (*pfnOnPreExecuteScript)(const wchar_t* pathname);
typedef int (*pfnOnListPluginCommand)(HWND hwnd);
typedef int (*pfnOnExecutePluginCommand)(const wchar_t* command);

static const int INT_MAX = 2147483647;
static const int INT_MIN = -2147483648;

static const int WM_USER = 1024;
static const int WM_COMMAND = 0x0111;

static const int LVM_FIRST = 0x1000;
static const int LVM_GETITEMCOUNT = LVM_FIRST + 4;
static const int LVM_INSERTITEMA = LVM_FIRST + 7;
static const int LVM_SETITEMTEXTA = LVM_FIRST + 46;
static const int LVIF_TEXT = 1;

static const int ECM_CANUNDO = WM_USER + 1;
static const int ECM_CANREDO = WM_USER + 2;
static const int ECM_JUMPTOLINE = WM_USER + 3;
static const int ECM_GETLINECNT = WM_USER + 8;
static const int ECM_GETPATH = WM_USER + 11;
static const int ECM_GETCARETPOS = WM_USER + 12;
static const int ECM_GETLINEBUF = WM_USER + 15;
static const int ECM_DELETETEXT = WM_USER + 16;
static const int ECM_INSERTTEXT = WM_USER + 17;
static const int ECM_SETEOLTYPE = WM_USER + 18;
static const int ECM_ISDOCDIRTY = WM_USER + 21;
static const int ECM_EDITMODE = WM_USER + 28;
static const int ECM_SETSEL = WM_USER + 32;
static const int ECM_HASSEL = WM_USER + 33;
static const int ECM_GETSEL = WM_USER + 34;
static const int ECM_GETTEXT = WM_USER + 35;
static const int ECM_WRAP = WM_USER + 37;
static const int ECM_GETSELTEXT = WM_USER + 40;
static const int ECM_FORCECARETVISIBLE = WM_USER + 41;
static const int ECM_SETPOS = WM_USER + 46;
static const int ECM_GETVISUALLINECOUNT = WM_USER + 58;
static const int ECM_SETFOLDMETHOD = WM_USER + 59;
static const int ECM_GETFONTHEIGHT = WM_USER + 61;
static const int ECM_GETBUFFERENCODING = WM_USER + 63;
static const int ECM_COMMENTLINE = WM_USER + 69;
static const int ECM_REDRAW = WM_USER + 74;
static const int ECM_MOVECARET = WM_USER + 77;
static const int ECM_WRAPCOUNT = WM_USER + 79;
static const int ECM_INSERTSNIPPET = WM_USER + 82;
static const int ECM_CLEARDIRTY = WM_USER + 84;
static const int ECM_GETSCOPE = WM_USER + 87;
static const int ECM_BOOKMARKER = WM_USER + 88;
static const int ECM_CLOSETAG = WM_USER + 105;
static const int ECM_ISLOADING = WM_USER + 106;

static const int EEM_EXCUTESCRIPT = WM_USER + 1203;
static const int EEM_GETACTIVETEXT = WM_USER + 3000;
static const int EEM_LOADFILE = WM_USER + 3002;
static const int EEM_SETHOOK = WM_USER + 3003;
static const int EEM_GETFRAMELIST = WM_USER + 3005;
static const int EEM_SETACTIVEVIEW = WM_USER + 3006;
static const int EEM_UPDATEUIELEMENT = WM_USER + 3009;
static const int EEM_OUTPUTTEXT = WM_USER + 3010;
static const int EEM_GETOUTPUTHWND = WM_USER + 3011;
static const int EEM_GETDOCFROMFRAME = WM_USER + 3012;
static const int EEM_GETFRAMETYPE = WM_USER + 3017;
static const int EEM_GETFRAMEPATH = WM_USER + 3018;
static const int EEM_GETACTIVEFRAME = WM_USER + 3019;
static const int EEM_SWOWDIALOG = WM_USER + 3021;

static const int EEHOOK_APPMSG = 7;
static const int EEHOOK_IDLE = 8;
static const int EEHOOK_RUNCOMMAND = 13;
static const int EEHOOK_TEXTIDLE = 27;
static const int EEHOOK_LISTPLUGINCOMMAND = 29;
static const int EEHOOK_EXECUTEPLUGINCOMMAND = 30;
static const int EEHOOK_PREEXECUTESCRIPT = 108;

static const int EEHOOK_RET_DONTROUTE = 0xBC614E;

static const int EE_UI_REMOVE = 0;
static const int EE_UI_ADD = 1;
static const int EE_UI_ENABLE = 2;
static const int EE_UI_SETCHECK = 3;

static const int CODEPAGE_AUTO = 1;

static const int VIEWTYPE_UNKNOWN = 0;
static const int VIEWTYPE_TEXT = 1;
static const int VIEWTYPE_HEX = 2;

static const int FRAMETYPE_UNKNOWN = 0;
static const int FRAMETYPE_TEXT = 1;
static const int FRAMETYPE_HEX = 2;

static const int EC_EOL_NULL = 0;
static const int EC_EOL_WIN = 1;
static const int EC_EOL_UNIX = 2;
static const int EC_EOL_MAC = 3;
]]

eelua.C = C

function eelua.printf(fmt, ...)
  eelua.dprint(str_fmt(fmt, ...))
end

function _M.send_message(hwnd, msg, wparam, lparam)
  return C.SendMessageA(
    ffi_cast("HWND", hwnd),
    ffi_cast("UINT", msg),
    wparam and ffi_cast("WPARAM", wparam) or 0,
    lparam and ffi_cast("LPARAM", lparam) or 0
  )
end

return _M
