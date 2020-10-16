local ffi = require"ffi"

ffi.cdef[[
int MultiByteToWideChar(unsigned int CodePage,
  unsigned long dwFlags,
  const char* lpMultiByteStr,
  int cbMultiByte,
  wchar_t* lpWideCharStr,
  int cchWideChar
);

int WideCharToMultiByte(unsigned int CodePage,
  unsigned long dwFlags,
  const wchar_t* lpWideCharStr,
  int cchWideChar,
  char* lpMultiByteStr,
  int cchMultiByte,
  const char* lpDefaultChar,
  int* pfUsedDefaultChar
);

int lstrlenW(
  const wchar_t* lpString
);
]]

local CP_UTF8 = 65001
local CP_ACP = 0

-- UTF-8 to UTF-16
local function u2w(input)
  local wlen = ffi.C.MultiByteToWideChar(CP_UTF8, 0, input, #input, nil, 0)
  local wstr = ffi.new("wchar_t[?]", wlen + 1)
  ffi.C.MultiByteToWideChar(CP_UTF8, 0, input, #input, wstr, wlen)
  return wstr, wlen
end

local function a2w(input)
  local wlen = ffi.C.MultiByteToWideChar(CP_ACP, 0, input, #input, nil, 0)
  local wstr = ffi.new("wchar_t[?]", wlen + 1)
  ffi.C.MultiByteToWideChar(CP_ACP, 0, input, #input, wstr, wlen)
  return wstr, wlen
end

local function w2u(wstr, wlen)
  local len = ffi.C.WideCharToMultiByte(CP_UTF8, 0, wstr, wlen, nil, 0, nil, nil)
  local str = ffi.new("char[?]", len + 1)
  ffi.C.WideCharToMultiByte(CP_UTF8, 0, wstr, wlen, str, len, nil, nil)
  return ffi.string(str)
end

local function w2a(wstr, wlen)
  local len = ffi.C.WideCharToMultiByte(CP_ACP, 0, wstr, wlen, nil, 0, nil, nil)
  local str = ffi.new("char[?]", len + 1)
  ffi.C.WideCharToMultiByte(CP_ACP, 0, wstr, wlen, str, len, nil, nil)
  return ffi.string(str)
end

-- UTF-8 to ANSI
local function A(input)
  local wlen = ffi.C.MultiByteToWideChar(CP_UTF8, 0, input, #input, nil, 0)
  local wstr = ffi.new("wchar_t[?]", wlen + 1)
  ffi.C.MultiByteToWideChar(CP_UTF8, 0, input, #input, wstr, wlen)

  local len = ffi.C.WideCharToMultiByte(CP_ACP, 0, wstr, wlen, nil, 0, nil, nil)
  local str = ffi.new("char[?]", len + 1)
  ffi.C.WideCharToMultiByte(CP_ACP, 0, wstr, wlen, str, len, nil, nil)

  return ffi.string(str)
end

local function Pass(input)
  return input
end

return {
  L = u2w,
  A = A,
  Pass = Pass,

  u2w = u2w,
  a2w = a2w,
  w2u = w2u,
  w2a = w2a,
  u2a = function (input)
    return w2a(u2w(input))
  end,
  a2u = function (input)
    return w2u(a2w(input))
  end,
}
