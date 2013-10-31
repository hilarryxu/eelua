// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_EDITOR_H_
#define EELUA_EDITOR_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"

struct EE_Context;

int editor_open(lua_State* L, EE_Context* context);

#ifdef __cplusplus
}
#endif

#endif  // EELUA_EDITOR_H_

