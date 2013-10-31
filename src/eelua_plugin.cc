// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "eelua_plugin.h"

#include "lua.hpp"
#include "eesdk.h"

#include "util.h"
#include "UnicodeUtils.h"
#include "eelua.h"

#define LOG_TAG "eelua_plugin"

EE_Context* g_ee_context = NULL;
HMODULE g_ee_module = NULL;
lua_State* g_lua_state = NULL;

DWORD EE_PluginInit(EE_Context* context) {
  LOGI("EE_PluginInit");
  g_ee_context = context;
  g_lua_state = eelua_setup(g_ee_context);
  return 0;
}

DWORD EE_PluginUninit() {
  LOGI("EE_PluginUninit");
  if (g_lua_state)
    eelua_teardown(g_lua_state);
  return 0;
}

DWORD EE_PluginInfo(wchar_t* text, int len) {
    return 0;
}

EELUA_EXPORT DWORD dofile(EE_Context* context, LPRECT rect, const wchar_t* text) {
  lua_State* L = g_lua_state;
  char buf[PATH_MAX] = {0};
  ::GetModuleFileNameA(NULL, buf, sizeof(buf));
  char *p = strrchr(buf, '\\');
  if (p) *p = '\0';
  strcat(buf, "\\eelua\\scripts\\");
  std::string luafilename = WideToMultibyte(text);
  strcat(buf, luafilename.c_str());

  LOGI("dofile: %s", luafilename.c_str());
  if (luaL_dofile(L, buf)) {
    ReportLuaError(lua_tostring(L, -1));
    return 1;
  }
  return 0;
}

extern "C" BOOL WINAPI DllMain(HMODULE module, DWORD reason, LPVOID reserved) {
  g_ee_module = module;
  switch (reason) {
    case DLL_PROCESS_ATTACH:
      break;
    case DLL_THREAD_ATTACH:
      break;
    case DLL_THREAD_DETACH:
      break;
    case DLL_PROCESS_DETACH:
      break;
  }
  return TRUE;
}

