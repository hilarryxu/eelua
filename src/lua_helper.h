// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_LUA_HELPER_H_
#define EELUA_LUA_HELPER_H_

#include "config.h"
#include "lua.h"

int luaH_docall(lua_State *L, int narg, int nres, const char *extra_msg);

int luaH_dofile(lua_State *L, const char *fname);
int luaH_dostring(lua_State *L, const char *code);

#endif  // EELUA_LUA_HELPER_H_
