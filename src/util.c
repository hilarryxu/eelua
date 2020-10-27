// Copyright (C) 2020 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "util.h"

#include <stdio.h>
#include <stdarg.h>


static const char *
Level2Str(int level)
{
    switch (level) {
    case LOG_LEVEL_DEBUG: return "DEBUG";
    case LOG_LEVEL_INFO: return "INFO";
    case LOG_LEVEL_WARN: return "WARN";
    case LOG_LEVEL_ERROR: return "ERROR";
    case LOG_LEVEL_FATAL: return "FATAL";
    default: return "NULL";
    }
}


void
LoggerImpl(const char *domain, int level, const char *fmt, ...)
{
    va_list args;
    char buf[1024] = {0};
    sprintf(buf, "{%s} [%s] ", (domain == NULL) ? "NULL" : domain,
            Level2Str(level));
    char* p = buf + strlen(buf);
    va_start(args, fmt);
    vsnprintf(p, sizeof(buf) - strlen(buf) - 1, fmt, args);
    OutputDebugStringA(buf);
    va_end(args);
}


void
ReportLuaWarn(const char *msg)
{
    OutputDebugStringA(msg);
}


void
ReportLuaError(const char *msg)
{
    MessageBoxA(NULL, msg, "[eelua] Error", MB_OK|MB_ICONERROR);
}
