// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_MENU_H_
#define EELUA_MENU_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"

struct EE_Context;

int menu_open(lua_State* L, EE_Context* context);
int menu_new(lua_State* L);

#ifdef __cplusplus
}
#endif

#endif  // EELUA_MENU_H_

