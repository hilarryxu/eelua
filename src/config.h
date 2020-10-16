// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_CONFIG_H_
#define EELUA_CONFIG_H_

#include <windows.h>

#include "eesdk.h"

#ifdef _MSC_VER
#define snprintf  _snprintf
#define PATH_MAX  _MAX_PATH
#endif

// #define EELUA_INTERNAL_UTF8  1

#endif  // EELUA_CONFIG_H_
