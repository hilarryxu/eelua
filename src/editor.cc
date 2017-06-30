// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "editor.h"

#include <windows.h>

#include "eesdk.h"
#include "auxiliar.h"

#include "config.h"
#include "util.h"
#include "menu.h"
#include "document.h"

#define LOG_TAG "editor"
#define CLASS_EDITOR "eelua{editor}"

typedef struct t_editor_ {
  EE_Context* context;
} t_editor;
typedef t_editor* p_editor;

static int failed(lua_State* L, const char* errmsg) {
  lua_pushnil(L);
  lua_pushstring(L, errmsg);
  return 2;
}

static int editor_new(lua_State* L, EE_Context* context) {
  p_editor editor = (p_editor) lua_newuserdata(L, sizeof(t_editor));
  auxiliar_setclass(L, CLASS_EDITOR, -1);
  editor->context = context;
  if (!context) {
    lua_pop(L, 1);
    return failed(L, "failed to create editor");
  } else {
    return 1;
  }
}

static int editor_commandid(lua_State* L) {
  p_editor editor = (p_editor) auxiliar_checkclass(L, CLASS_EDITOR, 1);
  lua_pushinteger(L, *(editor->context->pCommand));
  return 1;
}

static int editor_new_commandid(lua_State* L) {
  p_editor editor = (p_editor) auxiliar_checkclass(L, CLASS_EDITOR, 1);
  *(editor->context->pCommand) = *(editor->context->pCommand) + 1;
  lua_pushinteger(L, *(editor->context->pCommand));
  return 1;
}

static int editor_version(lua_State* L) {
  char version[32] = {0};
  p_editor editor = (p_editor) auxiliar_checkclass(L, CLASS_EDITOR, 1);
  snprintf(version, sizeof(version), "%lu.%lu",
           editor->context->dwVersion, editor->context->dwBuild);
  lua_pushstring(L, version);
  return 1;
}

static int editor_menu(lua_State* L) {
  auxiliar_checkclass(L, CLASS_EDITOR, 1);
  return menu_new(L);
}

static int editor_document(lua_State* L) {
  p_editor editor = (p_editor) auxiliar_checkclass(L, CLASS_EDITOR, 1);
  EE_Context* context = editor->context;
  HWND doc_hwnd = (HWND) ::SendMessage(context->hMain, EEM_GETACTIVETEXT, 0, 0);
  if (doc_hwnd) {
    return document_new(L, doc_hwnd);
  } else {
    return failed(L, "failed to get document");
  }
}

static int editor_sendcommand(lua_State* L) {
  p_editor editor = (p_editor) auxiliar_checkclass(L, CLASS_EDITOR, 1);
  int cmd = luaL_checkinteger(L, 2);
  EE_Context* context = editor->context;
  ::SendMessage(context->hMain, WM_COMMAND, cmd, 0);
  return 0;
}

static int editor_loadfile(lua_State* L) {
  p_editor editor = (p_editor) auxiliar_checkclass(L, CLASS_EDITOR, 1);
  const char *lpath = luaL_checkstring(L, 2);
  EE_Context* context = editor->context;
  std::wstring path = InternalStringToWide(lpath);
  EE_LoadFile eelf = {0, WT_TEXT, FALSE};
  HWND doc_hwnd = (HWND) ::SendMessage(context->hMain, EEM_LOADFILE, (WPARAM) path.c_str(), (LPARAM) &eelf);
  if (doc_hwnd) {
    return document_new(L, doc_hwnd);
  } else {
    return failed(L, "failed to loadfile");
  }
}

static luaL_Reg meths[] = {
  {"__tostring", auxiliar_tostring},
  {"commandid", editor_commandid},
  {"new_commandid", editor_new_commandid},
  {"version", editor_version},
  {"menu", editor_menu},
  {"document", editor_document},
  {"sendcommand", editor_sendcommand},
  {"loadfile", editor_loadfile},
  {NULL, NULL}
};

int editor_open(lua_State *L, EE_Context* context) {
  auxiliar_newclass(L, CLASS_EDITOR, meths);
  editor_new(L, context);  // eelua, editor
  lua_setfield(L, -2, "editor");  // eelua
  return 0;
}

