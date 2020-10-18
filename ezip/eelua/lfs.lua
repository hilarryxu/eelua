local ffi = require"ffi"
local bit = require"bit"
local string = require"string"
local table = require"table"
local os = require"os"
require"eelua.stdext"

local C = ffi.C
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_cast = ffi.cast
local str_fmt = string.format
local tinsert = table.insert
local tconcat = table.concat

ffi.cdef[[
uint32_t GetFileAttributesA(
  const char* lpFileName
);
int DeleteFileA(
  const char* lpFileName
);
int CopyFileA(
  const char* lpExistingFileName,
  const char* lpNewFileName,
  int bFailIfExists
);
int SetCurrentDirectoryA(
  const char* lpPathName
);
int RemoveDirectoryA(
  const char* lpPathName
);
int CreateDirectoryA(
  const char*     lpPathName,
  void* lpSecurityAttributes
);
int GetCurrentDirectoryA(
  int  nBufferLength,
  char* lpBuffer
);

typedef struct _FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} FILETIME;

typedef struct _WIN32_FIND_DATAA {
  DWORD dwFileAttributes;
  FILETIME ftCreationTime;
  FILETIME ftLastAccessTime;
  FILETIME ftLastWriteTime;
  DWORD nFileSizeHigh;
  DWORD nFileSizeLow;
  DWORD dwReserved0;
  DWORD dwReserved1;
  char cFileName[260];
  char cAlternateFileName[14];
  DWORD dwFileType;
  DWORD dwCreatorType;
  WORD  wFinderFlags;
} WIN32_FIND_DATAA;

HANDLE FindFirstFileA(const char* lpFileName, WIN32_FIND_DATAA* lpFindFileData);
WINBOOL FindNextFileA (HANDLE hFindFile, WIN32_FIND_DATAA* lpFindFileData);
WINBOOL FindClose (HANDLE hFindFile);

static const int FILE_ATTRIBUTE_DIRECTORY = 16;
]]

local _M = {}

local WIN_FALSE = 0
local PATH_MAX = 4096
local INVALID_HANDLE_VALUE = ffi_cast("HANDLE", -1)

function _M.exists_file(filepath)
  local rv = C.GetFileAttributesA(filepath)
  if rv <= 0x7FFFFFFF then
    return bit.band(rv, C.FILE_ATTRIBUTE_DIRECTORY) == 0
  end
  return false
end

function _M.exists_dir(filepath)
  local rv = C.GetFileAttributesA(filepath)
  if rv <= 0x7FFFFFFF then
    return bit.band(rv, C.FILE_ATTRIBUTE_DIRECTORY) ~= 0
  end
  return false
end

function _M.remove_file(filepath)
  local rv = C.DeleteFileA(filepath)
  if rv == WIN_FALSE then
    return nil, str_fmt("unable to remove file '%s'", filepath)
  end
end

function _M.copy_file(source, dest, check_exists)
  local fail_if_exists = 0
  if check_exists == true then
    fail_if_exists = 1
  end
  local rv = C.CopyFileA(source, dest, fail_if_exists)
  if rv == WIN_FALSE then
    return nil, str_fmt("unable to copy file to '%s'", dest)
  end
  return true
end

function _M.chdir(pathname)
  local rv = C.SetCurrentDirectoryA(pathname)
  if rv == WIN_FALSE then
    return nil, str_fmt("unable to switch to directory '%s'", pathname)
  end
  return true
end

function _M.rmdir(pathname)
  local rv = C.RemoveDirectoryA(pathname)
  if rv == WIN_FALSE then
    return nil, str_fmt("unable to remove directory '%s'", pathname)
  end
  return true
end

function _M.mkdir(pathname)
  local rv = C.CreateDirectoryA(pathname, nil)
  if rv == WIN_FALSE then
    return nil, str_fmt("unable to create directory '%s'", pathname)
  end
  return true
end

function _M.currentdir()
  local buf = ffi.new("char[?]", PATH_MAX + 1)
  local rv = C.GetCurrentDirectoryA(PATH_MAX, buf)
  if rv == WIN_FALSE then
    return nil
  end
  return ffi.string(buf, rv)
end

function _M.attributes(filepath, aname)
  if aname == "mode" then
    local mode = "other"
    local rv = C.GetFileAttributesA(filepath)
    if rv <= 0x7FFFFFFF then
      mode = bit.band(rv, C.FILE_ATTRIBUTE_DIRECTORY) ~= 0 and "directory" or "file"
    end
    return mode
  end
end

function _M.list_dir(pathname, filter, rec)
  local search_pat = pathname .. "\\*"
  local p_ffd = ffi_new("WIN32_FIND_DATAA[1]")
  local h = C.FindFirstFileA(search_pat, p_ffd)
  if h == INVALID_HANDLE_VALUE then
    return {}
  end

  local out = {}
  repeat
    local fn = ffi_str(p_ffd[0].cFileName)
    if fn ~= "." and fn ~= ".." then
      local is_valid = true
      if filter == "file" and bit.band(p_ffd[0].dwFileAttributes, C.FILE_ATTRIBUTE_DIRECTORY) ~= 0 then
        is_valid = false
      elseif filter == "directory" and bit.band(p_ffd[0].dwFileAttributes, C.FILE_ATTRIBUTE_DIRECTORY) == 0 then
        is_valid = false
      end
      if is_valid then
        tinsert(out, fn)
      end
    end
  until C.FindNextFileA(h, p_ffd) == WIN_FALSE
  C.FindClose(h)
  return out
end

function _M._list_dir(pathname, filter, rec)
  local cmds = { "dir /B" }
  if filter == "file" then
    tinsert(cmds, "/A:-D")
  elseif filter == "directory" then
    tinsert(cmds, "/A:D")
  end
  if rec == true then
    tinsert(cmds, "/S")
  end
  tinsert(cmds, str_fmt([["%s"]], pathname))

  local s = os.outputof(tconcat(cmds, " "))
  return string.explode(s, "\n", true)
end

return _M
