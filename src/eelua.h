// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_EELUA_H_
#define EELUA_EELUA_H_

#include "config.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

lua_State* eelua_setup(EE_Context* context);
void eelua_teardown(lua_State* L);

#ifdef __cplusplus
}
#endif

#endif  // EELUA_EELUA_H_

