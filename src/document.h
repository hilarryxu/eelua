// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_DOCUMENT_H_
#define EELUA_DOCUMENT_H_

#include "config.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"

int document_open(lua_State* L);
int document_new(lua_State* L, HWND window);

#ifdef __cplusplus
}
#endif

#endif  // EELUA_DOCUMENT_H_

