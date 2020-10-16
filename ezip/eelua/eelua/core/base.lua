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

typedef int (__stdcall *pfnOnRunningCommand)(const wchar_t* command, int length);
typedef int (*pfnOnAppMessage)(UINT uMsg, WPARAM wp, LPARAM lp);
typedef int (*pfnOnPreExecuteScript)(const wchar_t* pathname);

static const int INT_MAX = 2147483647;
static const int INT_MIN = -2147483648;

static const int WM_USER = 1024;
static const int WM_COMMAND = 0x0111;

static const int ECM_JUMPTOLINE = WM_USER + 3;
static const int ECM_GETLINECNT = WM_USER + 8;
static const int ECM_GETPATH = WM_USER + 11;
static const int ECM_GETCARETPOS = WM_USER + 12;
static const int ECM_GETLINEBUF = WM_USER + 15;
static const int ECM_DELETETEXT = WM_USER + 16;
static const int ECM_INSERTTEXT = WM_USER + 17;
static const int ECM_SETEOLTYPE = WM_USER + 18;
static const int ECM_ISDOCDIRTY = WM_USER + 21;
static const int ECM_SETSEL = WM_USER + 32;
static const int ECM_HASSEL = WM_USER + 33;
static const int ECM_GETSEL = WM_USER + 34;
static const int ECM_GETTEXT = WM_USER + 35;
static const int ECM_GETSELTEXT = WM_USER + 40;
static const int ECM_REDRAW = WM_USER + 74;

static const int EEM_EXCUTESCRIPT = WM_USER + 1203;
static const int EEM_GETACTIVETEXT = WM_USER + 3000;
static const int EEM_LOADFILE = WM_USER + 3002;
static const int EEM_SETHOOK = WM_USER + 3003;
static const int EEM_GETFRAMELIST = WM_USER + 3005;
static const int EEM_UPDATEUIELEMENT = WM_USER + 3009;
static const int EEM_OUTPUTTEXT = WM_USER + 3010;
static const int EEM_GETFRAMEPATH = WM_USER + 3018;
static const int EEM_GETACTIVEFRAME = WM_USER + 3018;
static const int EEM_SWOWDIALOG = WM_USER + 3021;

static const int EEHOOK_APPMSG = 7;
static const int EEHOOK_IDLE = 8;
static const int EEHOOK_RUNCOMMAND = 13;
static const int EEHOOK_TEXTIDLE = 27;
static const int EEHOOK_PREEXECUTESCRIPT = 108;

static const int EEHOOK_RET_DONTROUTE = 0xBC614E;

static const int EE_UI_REMOVE = 0;
static const int EE_UI_ADD = 1;
static const int EE_UI_ENABLE = 2;
static const int EE_UI_SETCHECK = 3;
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
