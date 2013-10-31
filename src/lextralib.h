// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_LEXTRALIB_H_
#define EELUA_LEXTRALIB_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"


int lextralib_open(lua_State* L);

#ifdef __cplusplus
}
#endif

#endif  // EELUA_LEXTRALIB_H_

