// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "eelua_plugin.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "eesdk.h"

#include "util.h"
#include "eelua.h"
#include "lua_helper.h"

#define LOG_TAG     "eelua_plugin"

EE_Context *g_ee_context = NULL;
HMODULE g_ee_module = NULL;
lua_State *g_lua_vm = NULL;

static int
run_eelua_init(lua_State *L)
{
    return luaH_dofile(L, "./eelua/eelua_init.lua");
}


DWORD
EE_PluginInit(EE_Context *context)
{
    LOGI("EE_PluginInit");
    g_ee_context = context;
    g_lua_vm = lua_open();
    lua_State *L = g_lua_vm;
    if (L != NULL) {
        luaL_openlibs(L);
        luaopen_eelua(L);
        lua_pushlightuserdata(L, context);
        lua_setfield(L, -2, "_ee_context");
        lua_pop(L, 1);
        run_eelua_init(L);
    }
    return 0;
}


DWORD
EE_PluginUninit()
{
    LOGI("EE_PluginUninit");
    if (g_lua_vm != NULL) {
        lua_close(g_lua_vm);
    }
    return 0;
}


DWORD
EE_PluginInfo(wchar_t *text, int len)
{
    return 0;
}


EELUA_EXPORT DWORD
dofile(EE_Context *context, LPRECT rect, const wchar_t *text)
{
    lua_State *L = g_lua_vm;

    lua_getglobal(L, "OnDoFile");
    lua_pushlightuserdata(L, context);
    lua_pushlightuserdata(L, rect);
    lua_pushlightuserdata(L, (void *) text);
    int rc = luaH_docall(L, 3, 0, NULL);
    if (rc != LUA_OK) {
        const char *msg = lua_tostring(L, -1);
        ReportLuaError(msg);
        lua_pop(L, 1);
    }
    return 0;
}


BOOL WINAPI
DllMain(HMODULE module, DWORD reason, LPVOID reserved)
{
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
