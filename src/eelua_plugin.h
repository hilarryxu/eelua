// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_PLUGIN_H_
#define EELUA_PLUGIN_H_

#include "config.h"

#define EELUA_EXPORT    __declspec(dllexport)

EELUA_EXPORT DWORD EE_PluginInit(EE_Context *context);
EELUA_EXPORT DWORD EE_PluginUninit();
EELUA_EXPORT DWORD EE_PluginInfo(wchar_t *text, int len);

EELUA_EXPORT DWORD dofile(EE_Context *context, LPRECT rect, const wchar_t *text);

#endif  // EELUA_PLUGIN_H_
