#ifndef L_IRRXML_H
#define L_IRRXML_H

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"

#include "auxiliar.h"

#define LUAIRRXML_COPYRIGHT     "Copyright (C) 2013 Larry Xu <hilarryxu@gmail.com>"
#define LUAIRRXML_DESCRIPTION   "Bindings of irrxml"
#define LUAIRRXML_VERSION       "Lua irrxml 0.1.0"

int luaopen_lirrxml(lua_State *L);

#ifdef __cplusplus
}
#endif

#endif  /* L_IRRXML_H */

