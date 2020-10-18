// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "eelua.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "util.h"

#define LOG_TAG     "eelua"


int
Leelua_dprint(lua_State *L)
{
    const char *msg = luaL_checkstring(L, 1);
    ReportLuaWarn(msg);
    return 0;
}


static luaL_Reg  funcs[] = {
    { "dprint", Leelua_dprint },
    { NULL, NULL }
};


int
luaopen_eelua(lua_State *L)
{
    luaL_register(L, "eelua", funcs);

#if defined(_M_X64) || defined(__x86_64__)
    lua_pushboolean(L, 1);
#else
    lua_pushboolean(L, 0);
#endif
    lua_setfield(L, -2, "x64");

#if !defined(NDEBUG)
    lua_pushboolean(L, 1);
#else
    lua_pushboolean(L, 0);
#endif
    lua_setfield(L, -2, "DEBUG");

    lua_pushliteral(L, "_VERSION");
    lua_pushliteral(L, EELUA_VERSION);
    lua_rawset(L, -3);

    return 1;
}
