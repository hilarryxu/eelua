local ffi = require "ffi"
local bit = require "bit"
local string = require "string"
local table = require "table"

local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_cast = ffi.cast
local bor = bit.bor
local str_fmt = string.format
local tinsert = table.insert
local tconcat = table.concat

local is_luajit = pcall(require, 'jit')
local clib

---
-- aux
---
local aux = {}

if is_luajit then
  function aux.is_null(ptr)
    return ptr == nil
  end
else
  function aux.is_null(ptr)
    return ptr == ffi.C.NULL
  end
end

function aux.wrap_string(c_str, len)
  if not aux.is_null(c_str) then
    return ffi_str(c_str, len)
  end
  return nil
end

function aux.wrap_bool(c_bool)
  return c_bool ~= 0
end


---
-- wininet
---
local _M = {}
local consts = {}

local function init_mod(mod, opts)
  if clib ~= nil then
    return mod
  end

  clib = _M._load_clib(opts)
  _M._bind_clib()
  mod.C = clib
  return mod
end

function _M._load_clib(opts)
  if opts == nil then
    return ffi.C
  end

  return ffi.load(opts)
end

function _M._bind_clib()
  _M.consts = consts

  consts.OK = 0

  consts.OPEN_TYPE_PRECONFIG = 0

  consts.SERVICE_HTTP = 3

  consts.FLAG_NO_UI = 0x00000200
  consts.FLAG_SECURE = 0x00800000

  consts.OPTION_HTTP_DECODING = 65

  consts.HTTP_QUERY_CONTENT_LENGTH = 5
  consts.HTTP_QUERY_FLAG_NUMBER = 0x20000000
  consts.HTTP_QUERY_FLAG_REQUEST_HEADERS = 0x80000000
  consts.HTTP_QUERY_FLAG_SYSTEMTIME = 0x40000000

  if not is_luajit then
    consts.C_NULL = ffi.C.NULL
  end

  ffi.cdef [[
    typedef void* HANDLE;
    typedef uint16_t WORD;
    typedef uint32_t DWORD;
    typedef int32_t LONG;
    typedef int BOOL;
    typedef HANDLE HINTERNET;
    typedef WORD INTERNET_PORT;

    typedef void (__stdcall *INTERNET_STATUS_CALLBACK)(
      HINTERNET hInternet,
      DWORD *dwContext,
      DWORD dwInternetStatus,
      void *lpvStatusInformation,
      DWORD dwStatusInformationLength
    );
  ]]

  ffi.cdef [[
    BOOL InternetCloseHandle(HINTERNET hInternet);
    HINTERNET InternetOpenA(
      const char *lpszAgent, DWORD dwAccessType,
      const char *lpszProxyName, const char *lpszProxyBypass,
      DWORD dwFlags
    );
    HINTERNET InternetOpenUrlA(HINTERNET hInternet,
      const char *lpszUrl,
      const char *lpszHeaders, DWORD dwHeadersLength,
      DWORD dwFlags, DWORD *dwContext
    );
    BOOL InternetSetOptionA(HINTERNET hInternet,
      DWORD dwOption,
      void *lpBuffer, DWORD dwBufferLength
    );
    DWORD InternetSetFilePointer(HINTERNET hFile,
      LONG lDistanceToMove, LONG *lpDistanceToMoveHigh,
      DWORD dwMoveMethod,
      DWORD *dwContext
    );
    INTERNET_STATUS_CALLBACK InternetSetStatusCallback(HINTERNET hInternet,
      INTERNET_STATUS_CALLBACK lpfnInternetCallback
    );
    HINTERNET InternetConnectA(HINTERNET hInternet,
      const char *lpszServerName, INTERNET_PORT nServerPort,
      const char *lpszUsername, const char *lpszPassword,
      DWORD dwService,
      DWORD dwFlags, DWORD *dwContext
    );
    BOOL InternetQueryDataAvailable(
      HINTERNET hFile,
      DWORD   *lpdwNumberOfBytesAvailable,
      DWORD     dwFlags,
      DWORD *dwContext
    );
    BOOL InternetQueryOptionA(
      HINTERNET hInternet,
      DWORD     dwOption,
      void *lpBuffer,
      DWORD *lpdwBufferLength
    );
    BOOL InternetReadFile(
      HINTERNET hFile,
      void *lpBuffer,
      DWORD     dwNumberOfBytesToRead,
      DWORD *lpdwNumberOfBytesRead
    );
    BOOL InternetWriteFile(
      HINTERNET hFile,
      void *lpBuffer,
      DWORD     dwNumberOfBytesToWrite,
      DWORD *lpdwNumberOfBytesWritten
    );
    BOOL InternetGetLastResponseInfoA(
      DWORD *lpdwError,
      char *lpszBuffer,
      DWORD *lpdwBufferLength
    );

    BOOL HttpAddRequestHeadersA(HINTERNET hConnect,
      const char *lpszHeaders, DWORD dwHeadersLength, DWORD dwModifiers
    );
    HINTERNET HttpOpenRequestA(HINTERNET hConnect,
      const char *lpszVerb, const char *lpszObjectName, const char *lpszVersion,
      const char *lpszReferer, char **lplpszAcceptTypes,
      DWORD dwFlags, DWORD *dwContext
    );
    BOOL HttpQueryInfoA(HINTERNET hRequest,
      DWORD dwInfoLevel,
      void *lpvBuffer, DWORD *lpdwBufferLength,
      DWORD *lpdwIndex
    );
    BOOL HttpSendRequestA(HINTERNET hRequest,
      const char *lpszHeaders, DWORD dwHeadersLength,
      void *lpOptional, DWORD dwOptionalLength
    );
  ]]
end

-----------------------------------------------------------------------------
-- Parses a url and returns a table with all its parts according to RFC 2396
-- The following grammar describes the names given to the URL parts
-- <url> ::= <scheme>://<authority>/<path>;<params>?<query>#<fragment>
-- <authority> ::= <userinfo>@<host>:<port>
-- <userinfo> ::= <user>[:<password>]
-- <path> :: = {<segment>/}<segment>
-- Input
--   url: uniform resource locator of request
--   default: table with default values for each field
-- Returns
--   table with the following fields, where RFC naming conventions have
--   been preserved:
--     scheme, authority, userinfo, user, password, host, port,
--     path, params, query, fragment
-- Obs:
--   the leading '/' in {/<path>} is considered part of <path>
-----------------------------------------------------------------------------
function _M.url_parse(url, default)
  -- initialize default parameters
  local parsed = {}
  for i, v in pairs(default or parsed) do parsed[i] = v end

  -- empty url is parsed to nil
  if not url or url == "" then return nil, "invalid url" end

  -- remove whitespace
  -- url = string.gsub(url, "%s", "")
  -- get scheme
  url = string.gsub(url, "^([%w][%w%+%-%.]*)%:",
    function(s) parsed.scheme = s; return "" end
  )
  -- get authority
  url = string.gsub(url, "^//([^/]*)", function(n)
    parsed.authority = n
    return ""
  end)
  -- get fragment
  url = string.gsub(url, "#(.*)$", function(f)
    parsed.fragment = f
    return ""
  end)
  -- get query string
  url = string.gsub(url, "%?(.*)", function(q)
    parsed.query = q
    return ""
  end)
  -- get params
  url = string.gsub(url, "%;(.*)", function(p)
    parsed.params = p
    return ""
  end)

  -- path is whatever was left
  if url ~= "" then parsed.path = url end
  local authority = parsed.authority
  if not authority then return parsed end
  authority = string.gsub(authority,"^([^@]*)@",
    function(u) parsed.userinfo = u; return "" end
  )
  authority = string.gsub(authority, ":([^:%]]*)$",
    function(p) parsed.port = p; return "" end
  )
  if authority ~= "" then
    -- IPv6?
    parsed.host = string.match(authority, "^%[(.+)%]$") or authority
  end
  local userinfo = parsed.userinfo
  if not userinfo then return parsed end
  userinfo = string.gsub(userinfo, ":([^:]*)$",
    function(p) parsed.password = p; return "" end
  )
  parsed.user = userinfo

  return parsed
end

function _M.escape(s)
  return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
    return string.format("%%%02x", string.byte(c))
  end))
end

function _M.unescape(s)
  return (string.gsub(s, "%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

function _M.request(method, url, opts)
  opts = opts or {}
  local rc
  local C_NULL = consts.C_NULL
  local user_agent = opts.user_agent or "lua-WinInet/0.1"

  local uri = _M.url_parse(url)
  local session = clib.InternetOpenA(user_agent, consts.OPEN_TYPE_PRECONFIG,
                                     C_NULL, C_NULL, 0)
  local server_port = tonumber(uri.port or 80)
  if uri.scheme == "https" then
    server_port = tonumber(uri.port or 443)
  end
  local conn = clib.InternetConnectA(
    session,
    uri.host, server_port,
    C_NULL, C_NULL,
    consts.SERVICE_HTTP,
    0,
    C_NULL
  )

  -- HINTERNET HttpOpenRequestA(HINTERNET hConnect,
  --   const char *lpszVerb, const char *lpszObjectName, const char *lpszVersion,
  --   const char *lpszReferer, char **lplpszAcceptTypes,
  --   DWORD dwFlags, DWORD *dwContext
  -- );
  local req_flags = consts.FLAG_NO_UI
  if uri.scheme == "https" then
    req_flags = bor(req_flags, consts.FLAG_SECURE)
  end
  if opts.req_flags then
    req_flags = bor(req_flags, opts.req_flags)
  end
  local req_url = uri.path
  if opts.params then
    if type(opts.params) == "string" then
      req_url = str_fmt("%s?%s", req_url, opts.params)
    else
      local t = {}
      for k, v in pairs(opts.params) do
        tinsert(t, str_fmt("%s=%s", k, _M.escape(v)))
      end
      req_url = str_fmt("%s?%s", req_url, tconcat(t, "&"))
    end
  end
  local req = clib.HttpOpenRequestA(
    conn,
    method:upper(), req_url, opts.http_version or C_NULL,
    opts.referer or C_NULL, C_NULL,
    req_flags, C_NULL
  )

  -- local p_decoding = ffi_new("BOOL[1]", { 1 })
  -- rc = clib.InternetSetOptionA(req, consts.OPTION_HTTP_DECODING, p_decoding, ffi.sizeof("BOOL"))

  local headers, headers_len = C_NULL, 0
  if opts.headers then
    local t = {}
    for k, v in pairs(opts.headers) do
      tinsert(t, str_fmt("%s: %s", k, v))
    end
    headers = tconcat(t, "\r\n")
    headers_len = #headers
  end
  local data, data_len = C_NULL, 0
  if opts.data then
    data = opts.data
    data_len = #data
  end
  rc = clib.HttpSendRequestA(req, headers, headers_len, data, data_len)

  local cl_sz = 40
  local buf = ffi.new("char[?]", cl_sz)
  local p_buf_len = ffi.new("DWORD[1]", { cl_sz })
  clib.HttpQueryInfoA(req, consts.HTTP_QUERY_CONTENT_LENGTH,
    buf, p_buf_len, C_NULL
  )
  local content_length = tonumber(aux.wrap_string(buf, p_buf_len[0])) or 4 * 1024 * 1024

  local buf_sz = content_length + 2
  local buf = ffi.new("char[?]", buf_sz)
  local p_nread = ffi.new("DWORD[1]")
  local total_read_size = 0
  while true do
    p_nread[0] = 0
    rc = clib.InternetReadFile(req, buf + total_read_size, buf_sz, p_nread)
    if rc == 0 then break end
    if p_nread[0] == 0 then break end
    total_read_size = total_read_size + p_nread[0]
    if total_read_size >= content_length then
      break
    end
  end

  local content = aux.wrap_string(buf, total_read_size)

  clib.InternetCloseHandle(req)
  clib.InternetCloseHandle(conn)
  clib.InternetCloseHandle(session)

  return {
    content = content,
    content_length = content_length
  }
end

return init_mod(_M, "wininet.dll")
