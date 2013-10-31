// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "eelua.h"

#include <windows.h>

#include "eesdk.h"
#include "auxiliar.h"

#include "config.h"
#include "util.h"
#include "lextralib.h"
#include "menu.h"
#include "editor.h"
#include "document.h"

#define LOG_TAG "eelua"

extern const char* builtin_scripts[];
extern lua_State* g_lua_state;
static char apppath[PATH_MAX] = {0};

typedef struct t_eelua_hook_ {
  const char* name;
  int type;
  LPVOID func;
} t_eelua_hook;
typedef t_eelua_hook* p_eelua_hook;

static int eelua_panic(lua_State* L) {
  (void) L;
  ReportLuaError(lua_tostring(L, -1));
  return 0;
}

static void set_apppath(lua_State* L) {
  char* ch;
  ::GetModuleFileNameA(NULL, apppath, sizeof(apppath));
  char *p = strrchr(apppath, '\\');
  if (p) *p = '\0';
  // Convert to platform-neutral directory separators
  for (ch = apppath; *ch != '\0'; ++ch) {
    if (*ch == '\\') *ch = '/';
  }
  lua_pushliteral(L, "apppath");
  lua_pushstring(L, apppath);
  lua_rawset(L, -3);
}

static int eelua_dprint(lua_State* L) {
  std::wstring msg = InternalStringToWide(luaL_checkstring(L, 1));
  ::OutputDebugStringW(msg.c_str());
  return 0;
}

int HookPreSave(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_presave");
  LOGD("eehook_presave");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookPostSave(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_postsave");
  LOGD("eehook_postsave");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookPreClose(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_preclose");
  LOGD("eehook_preclose");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookPostClose(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_postclose");
  LOGD("eehook_postclose");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookAppMsg(UINT msg, WPARAM wparam, LPARAM lparam) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_appmsg");
  lua_pushinteger(L, msg);
  lua_pushinteger(L, wparam);
  lua_pushinteger(L, lparam);
  if (lua_pcall(L, 3, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookIdle(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_idle");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookAppActivate(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_appactivate");
  LOGD("eehook_appactivate");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookRunCommand(const wchar_t* text, int sz) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_runcommand");
  LOGD("eehook_runcommand");
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  lua_pushinteger(L, sz);
  if (lua_pcall(L, 2, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookPreLoad(const wchar_t* text) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_preload");
  LOGD("eehook_preload");
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookPostLoad(const wchar_t* text) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_postload");
  LOGD("eehook_postload");
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookPostNewText(HWND hwnd) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_postnewtext");
  LOGD("eehook_postnewtext");
  lua_pushinteger(L, (lua_Integer) hwnd);
  if (lua_pcall(L, 1, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookTextChar(HWND hwnd, const wchar_t* text) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_textchar");
  lua_pushinteger(L, (lua_Integer) hwnd);
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  if (lua_pcall(L, 2, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookTextCommand(HWND hwnd, WPARAM wparam, LPARAM lparam) {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_textcommand");
  lua_pushinteger(L, (lua_Integer) hwnd);
  lua_pushinteger(L, wparam);
  lua_pushinteger(L, lparam);
  if (lua_pcall(L, 3, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

int HookCloseWordcomplete() {
  lua_State* L = g_lua_state;
  lua_getglobal(L, "eehook_closewordcomplete");
  LOGD("eehook_closewordcomplete");
  if (lua_pcall(L, 0, 1, 0)) {
    ReportLuaError(lua_tostring(L, -1));
    return 0;
  }
  return lua_tointeger(L, -1);
}

static t_eelua_hook hooks[] = {
  {"", EEHOOK_TEXTMENU, NULL},
  {"", EEHOOK_HEXMENU, NULL},
  {"presave", EEHOOK_PRESAVE, (LPVOID) HookPreSave},
  {"postsave", EEHOOK_POSTSAVE, (LPVOID) HookPostSave},
  {"preclose", EEHOOK_PRECLOSE, (LPVOID) HookPreClose},
  {"postclose", EEHOOK_POSTCLOSE, (LPVOID) HookPostClose},
  {"appmsg", EEHOOK_APPMSG, (LPVOID) HookAppMsg},
  {"idle", EEHOOK_IDLE, (LPVOID) HookIdle},
  {"", EEHOOK_PRETRANSLATEMSG, NULL},
  {"", EEHOOK_APPRESIZE, NULL},
  {"appactivate", EEHOOK_APPACTIVATE, (LPVOID) HookAppActivate},
  {"", EEHOOK_CHILDACTIVE, NULL},
  {"runcommand", EEHOOK_RUNCOMMAND, (LPVOID) HookRunCommand},
  {"preload", EEHOOK_PRELOAD, (LPVOID) HookPreLoad},
  {"postload", EEHOOK_POSTLOAD, (LPVOID) HookPostLoad},
  {"postnewtext", EEHOOK_POSTNEWTEXT, (LPVOID) HookPostNewText},
  {"", EEHOOK_TABMENU, NULL},
  {"", EEHOOK_VIEWICON, NULL},
  {"textchar", EEHOOK_TEXTCHAR, (LPVOID) HookTextChar},
  {"textcommand", EEHOOK_TEXTCOMMAND, (LPVOID) HookTextCommand},
  {"", EEHOOK_UPDATETEXT, NULL},
  {"", EEHOOK_TEXTCARETCHANGE, NULL},
  {"", EEHOOK_PREWORDCOMPLETE, NULL},
  {"", EEHOOK_POSTWORDCOMPLETE, NULL},
  {"closewordcomplete", EEHOOK_CLOSEWORDCOMPLETE, (LPVOID) HookCloseWordcomplete},
  {"", EEHOOK_HEXCHAR, NULL},
  {NULL, 0, NULL}
};

static luaL_Reg funcs[] = {
  {"dprint", eelua_dprint},
  {NULL, NULL}
};

#if !defined(NDEBUG)
static int LoadBuiltinScripts(lua_State* L, EE_Context* context) {
  char buf[PATH_MAX] = {0};

  // Load start.lua
  snprintf(buf, PATH_MAX, "%s\\eelua\\start.lua", apppath);
  if (luaL_dofile(L, buf)) {
    LOGE("failed to load '%s'", buf);
    ReportLuaError(lua_tostring(L, -1));
    return !OKAY;
  }

  // Init hooks
  p_eelua_hook hook = hooks;
  lua_getglobal(L, "eehooks");
  if (lua_istable(L, -1)) {
    for (; hook->name; hook++) {
      if (hook->func) {
        lua_getfield(L, -1, hook->name);
        if (lua_istable(L, -1)) {
          LOGD("sethook: %s", hook->name);
          ::SendMessage(context->hMain, EEM_SETHOOK, hook->type, (LPARAM) (hook->func));
        }
        lua_pop(L, 1);
      }
    }
  }
  lua_pop(L, 1);

  // Call _eelua_main()
  lua_getglobal(L, "_eelua_main");
  if (lua_pcall(L, 0, 1, 0)) {
    LOGE("failed to call _eelua_main");
    ReportLuaError(lua_tostring(L, -1));
    return !OKAY;
  } else {
    return (int) lua_tonumber(L, -1);
  }
}
#endif

#if defined(NDEBUG)
static int LoadBuiltinScripts(lua_State* L, EE_Context* context) {
  int i;

  // Load scripts
  for (i = 0; builtin_scripts[i]; ++i) {
    if (luaL_dostring(L, builtin_scripts[i])) {
      LOGE("failed to load builtin script '%d'", i + 1);
      ReportLuaError(lua_tostring(L, -1));
      return !OKAY;
    }
  }

  // Init hooks
  p_eelua_hook hook = hooks;
  lua_getglobal(L, "eehooks");
  if (lua_istable(L, -1)) {
    for (; hook->name; hook++) {
      if (hook->func) {
        lua_getfield(L, -1, hook->name);
        if (lua_istable(L, -1)) {
          LOGD("sethook: %s", hook->name);
          ::SendMessage(context->hMain, EEM_SETHOOK, hook->type, (LPARAM) (hook->func));
        }
        lua_pop(L, 1);
      }
    }
  }
  lua_pop(L, 1);

  // Call _eelua_main()
  lua_getglobal(L, "_eelua_main");
  if (lua_pcall(L, 0, 1, 0)) {
    LOGE("failed to call _eelua_main");
    ReportLuaError(lua_tostring(L, -1));
    return !OKAY;
  } else {
    return (int) lua_tonumber(L, -1);
  }
}
#endif

lua_State* eelua_setup(EE_Context* context) {
  lua_State* L = luaL_newstate();
  if (L) {
    lua_atpanic(L, eelua_panic);
    luaL_openlibs(L);
    lextralib_open(L);
    luaL_newlib(L, funcs);
    set_apppath(L);
    menu_open(L, context);
    editor_open(L, context);
    document_open(L);
    lua_setglobal(L, "eelua");

    if (LoadBuiltinScripts(L, context) != OKAY) {
      LOGE("failed to call LoadBuiltinScripts");
      eelua_teardown(L);
      return NULL;
    }
  }
  return L;
}

void eelua_teardown(lua_State* L) {
  lua_close(L);
}

