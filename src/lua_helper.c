// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "lua_helper.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "util.h"

static int
msghandler(lua_State *L)
{
    const char *msg = lua_tostring(L, 1);
    if (msg == NULL) {  /* is error object not a string? */
        if (luaL_callmeta(L, 1, "__tostring")  /* does it have a metamethod */
            && lua_type(L, -1) == LUA_TSTRING) {  /* that produces a string? */
            return 1;  /* that is the message */
        } else {
            msg = lua_pushfstring(L, "(error object is a %s value)",
                                  luaL_typename(L, 1));
        }
    }
    luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
    return 1;  /* return the traceback */
}


static int
luaH_report(lua_State *L, int rc)
{
    if (rc != LUA_OK) {
        const char *errmsg = lua_tostring(L, -1);
        ReportLuaError(errmsg);
        lua_pop(L, 1);
    }
    return rc;
}


int
luaH_docall(lua_State *L, int narg, int nres, const char *extra_msg)
{
    // 栈顶是函数加参数列表
    int base = lua_gettop(L) - narg;  // 函数位置
    lua_pushcfunction(L, msghandler);
    lua_insert(L, base);  // 插入 msghandler
    int rc = lua_pcall(L, narg, nres, base);  // 调用函数，栈顶为结果列表或错误消息
    lua_remove(L, base);  // 移除 msghandler
    // NOTE: 该函数保留错误信息，需要自行处理
    return rc;
}


static int
luaH_dochunk(lua_State *L, int rc)
{
    // 栈顶是chunk函数或者错误信息
    // 成功栈顶为返回结果列表
    // 失败时恢复为调用前（错误消息已移除）
    if (rc == LUA_OK) {
        rc = luaH_docall(L, 0, 0, NULL);
    }
    return luaH_report(L, rc);
}


int
luaH_dofile(lua_State *L, const char *fname)
{
    return luaH_dochunk(L, luaL_loadfile(L, fname));
}


int
luaH_dostring(lua_State *L, const char *code)
{
    return luaH_dochunk(L, luaL_loadstring(L, code));
}
