// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#ifndef EELUA_UTIL_H_
#define EELUA_UTIL_H_

#include <string>

#include <windows.h>

#include "config.h"

void LoggerImpl(const char* domain, int level, const char* fmt, ...);

#define LOG_LEVEL_OFF 11
#define LOG_LEVEL_FATAL 9
#define LOG_LEVEL_ERROR 7
#define LOG_LEVEL_WARN 5
#define LOG_LEVEL_INFO 3
#define LOG_LEVEL_DEBUG 1

#define LOGF(fmt, ...) LoggerImpl(LOG_TAG, LOG_LEVEL_FATAL, fmt, ##__VA_ARGS__)
#define LOGE(fmt, ...) LoggerImpl(LOG_TAG, LOG_LEVEL_ERROR, fmt, ##__VA_ARGS__)
#define LOGW(fmt, ...) LoggerImpl(LOG_TAG, LOG_LEVEL_WARN, fmt, ##__VA_ARGS__)
#define LOGI(fmt, ...) LoggerImpl(LOG_TAG, LOG_LEVEL_INFO, fmt, ##__VA_ARGS__)
#define LOGD(fmt, ...) LoggerImpl(LOG_TAG, LOG_LEVEL_DEBUG, fmt, ##__VA_ARGS__)

std::string WideToInternalString(const std::wstring& wide);
std::wstring InternalStringToWide(const std::string& luastring);

void ReportLuaWarn(const char* msg);
void ReportLuaError(const char* msg);

#endif  // EELUA_UTIL_H_

