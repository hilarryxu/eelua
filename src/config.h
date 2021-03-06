// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_CONFIG_H_
#define EELUA_CONFIG_H_

#include <windows.h>

#include "eesdk.h"

#define EELUA_VERSION       "eelua 0.5"
#define EELUA_RELEASE       "eelua 0.5.0"
#define EELUA_VERSION_NUM   5  // (maj) * 1000) + min

#ifdef _MSC_VER
#define snprintf  _snprintf
#define PATH_MAX  _MAX_PATH
#endif

#ifndef LUA_OK
#define LUA_OK  0
#endif

#endif  // EELUA_CONFIG_H_
