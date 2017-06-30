// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "lextralib.h"

#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

#include <windows.h>

#include "config.h"

static int path_isabsolute(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);
  if (path[0] == '/' || path[0] == '\\' || path[0] == '$' || (path[0] != '\0' && path[1] == ':')) {
    lua_pushboolean(L, 1);
    return 1;
  }
  return 0;
}

static int string_endswith(lua_State* L) {
  const char* haystack = luaL_optstring(L, 1, NULL);
  const char* needle   = luaL_optstring(L, 2, NULL);

  if (haystack && needle) {
    int hlen = strlen(haystack);
    int nlen = strlen(needle);
    if (hlen >= nlen) {
      lua_pushboolean(L, strcmp(haystack + hlen - nlen, needle) == 0);
      return 1;
    }
  }

  return 0;
}

static int os_chdir(lua_State* L) {
  int z;
  const char* path = luaL_checkstring(L, 1);

  z = ::SetCurrentDirectory(path);

  if (!z) {
    lua_pushnil(L);
    lua_pushfstring(L, "unable to switch to directory '%s'", path);
    return 2;
  } else {
    lua_pushboolean(L, 1);
    return 1;
  }
}

static int os_copyfile(lua_State* L) {
  int z;
  const char* src = luaL_checkstring(L, 1);
  const char* dst = luaL_checkstring(L, 2);

  z = ::CopyFile(src, dst, FALSE);

  if (!z) {
    lua_pushnil(L);
    lua_pushfstring(L, "unable to copy file to '%s'", dst);
    return 2;
  } else {
    lua_pushboolean(L, 1);
    return 1;
  }
}

static int os_getcwd(lua_State* L) {
  char buffer[PATH_MAX];
  char* ch;
  int result;

  result = (::GetCurrentDirectory(PATH_MAX, buffer) != 0);

  if (!result)
    return 0;

  // Convert to platform-neutral directory separators
  for (ch = buffer; *ch != '\0'; ++ch) {
    if (*ch == '\\') *ch = '/';
  }

  lua_pushstring(L, buffer);
  return 1;
}

static int os_isdir(lua_State* L) {
  struct stat buf;
  const char* path = luaL_checkstring(L, 1);

  // Empty path is equivalent to ".", must be true.
  if (strlen(path) == 0) {
    lua_pushboolean(L, 1);
  } else if (stat(path, &buf) == 0) {
    lua_pushboolean(L, buf.st_mode & S_IFDIR);
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

static int os_isfile(lua_State* L) {
  struct stat buf;
  const char* filename = luaL_checkstring(L, 1);

  if (stat(filename, &buf) == 0) {
    lua_pushboolean(L, ((buf.st_mode & S_IFDIR) == 0));
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

static int os_mkdir(lua_State* L) {
  int z;
  const char* path = luaL_checkstring(L, 1);

  z = ::CreateDirectory(path, NULL);

  if (!z) {
    lua_pushnil(L);
    lua_pushfstring(L, "unable to create directory '%s'", path);
    return 2;
  } else {
    lua_pushboolean(L, 1);
    return 1;
  }
}

static int os_rmdir(lua_State* L) {
  int z;
  const char* path = luaL_checkstring(L, 1);

  z = ::RemoveDirectory(path);

  if (!z) {
    lua_pushnil(L);
    lua_pushfstring(L, "unable to remove directory '%s'", path);
    return 2;
  } else {
    lua_pushboolean(L, 1);
    return 1;
  }
}

static int os_stat(lua_State* L) {
  struct stat s;
  const char* filename = luaL_checkstring(L, 1);

  if (stat(filename, &s) != 0) {
    lua_pushnil(L);
    switch (errno) {
      case EACCES:
        lua_pushfstring(L, "'%s' could not be accessed", filename);
        break;
      case ENOENT:
        lua_pushfstring(L, "'%s' was not found", filename);
        break;
      default:
        lua_pushfstring(L, "unknown error %d occured while accessing '%s'", errno, filename);
        break;
    }
    return 2;
  }

  lua_newtable(L);
  lua_pushstring(L, "mtime");
  lua_pushinteger(L, (lua_Integer) s.st_mtime);
  lua_settable(L, -3);
  lua_pushstring(L, "size");
  lua_pushnumber(L, s.st_size);
  lua_settable(L, -3);

  return 1;
}

static int os_readdir(lua_State* L) {
  char buf[PATH_MAX];
  WIN32_FIND_DATA fd;
  HANDLE h;
  const char *dirname = luaL_checkstring(L, 1);

  snprintf(buf, PATH_MAX, "%s\\*", dirname);
  h = ::FindFirstFileExA(buf, FindExInfoStandard, &fd,
                      FindExSearchNameMatch, NULL, 0);
  if (h == INVALID_HANDLE_VALUE) {
    lua_pushnil(L);
    lua_pushfstring(L, "unable to readdir '%s'", dirname);
    return 2;
  }

  lua_newtable(L);
  lua_Integer num = 1;
  do {
    if (strcmp(fd.cFileName, ".") && strcmp(fd.cFileName, "..")) {
      lua_pushinteger(L, num);
      lua_pushstring(L, fd.cFileName);
      lua_settable(L, -3);
      num++;
    }
  } while (::FindNextFileA(h, &fd));

  ::FindClose(h);
  return 1;
}

static luaL_Reg path_funcs[] = {
  {"isabsolute",  path_isabsolute},
  {NULL, NULL}
};

static luaL_Reg os_funcs[] = {
  {"chdir", os_chdir},
  {"copyfile", os_copyfile},
  {"isdir", os_isdir},
  {"getcwd", os_getcwd},
  {"isfile", os_isfile},
  {"mkdir", os_mkdir},
  {"rmdir", os_rmdir},
  {"stat", os_stat},
  {"readdir", os_readdir},
  {NULL, NULL}
};

static luaL_Reg string_funcs[] = {
  {"endswith",  string_endswith},
  {NULL, NULL}
};

int lextralib_open(lua_State* L) {
  // luaL_openlib(L, "path", path_funcs, 0);
  // luaL_openlib(L, "os", os_funcs, 0);
  // luaL_openlib(L, "string", string_funcs, 0);
  // lua_pop(L, 3);
  return 0;
}

