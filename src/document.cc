// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "document.h"

#include <windows.h>

#include "eesdk.h"
#include "auxiliar.h"

#include "util.h"

#define LOG_TAG "document"
#define CLASS_DOCUMENT "eelua{document}"

typedef struct t_document_ {
  HWND window;
} t_document;
typedef t_document* p_document;

static int failed(lua_State* L, const char* errmsg) {
  lua_pushnil(L);
  lua_pushstring(L, errmsg);
  return 2;
}

int document_new(lua_State* L, HWND window) {
  p_document doc = (p_document) lua_newuserdata(L, sizeof(t_document));
  auxiliar_setclass(L, CLASS_DOCUMENT, -1);
  doc->window = window;
  if (!window) {
    lua_pop(L, 1);
    return failed(L, "failed to create document");
  } else {
    return 1;
  }
}

static int document_len(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int linecount = (int) ::SendMessage(doc->window, ECM_GETLINECNT, 0, 0);
  lua_pushinteger(L, linecount);
  return 1;
}


static int document_fname(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  const wchar_t* text = (const wchar_t*) ::SendMessage(doc->window, ECM_GETPATH, 0, 0);
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  return 1;
}

static int document_seltext(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  HANDLE h_seltext = (HANDLE) ::SendMessage(doc->window, ECM_GETSELTEXT, 0, 0);
  const wchar_t* text = (const wchar_t*) ::GlobalLock(h_seltext);
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  ::GlobalUnlock(h_seltext);
  return 1;
}

static int document_caret(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  EC_Pos pos = {0, 0};
  ::SendMessage(doc->window, ECM_GETCARETPOS, (WPARAM) &pos, 0);
  lua_newtable(L);
  lua_pushliteral(L, "line");
  lua_pushinteger(L, pos.line);
  lua_rawset(L, -3);
  lua_pushliteral(L, "col");
  lua_pushinteger(L, pos.col);
  lua_rawset(L, -3);
  return 1;
}

static int document_insert(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  const char *text = luaL_checkstring(L, 2);
  std::wstring buf = InternalStringToWide(text);
  EC_InsertText ecit = {buf.c_str(), (int) buf.size()};
  ::SendMessage(doc->window, ECM_INSERTTEXT, 0, (LPARAM) &ecit);
  return 0;
}

static int document_gotoline(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int nr_line = luaL_checkinteger(L, 2);
  ::SendMessage(doc->window, ECM_JUMPTOLINE, nr_line, 0);
  return 0;
}

static int document_redraw(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  ::SendMessage(doc->window, ECM_REDRAW, 0, 0);
  return 0;
}

static int document_hassel(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int ret = (int) ::SendMessage(doc->window, ECM_HASSEL, 0, 0);
  if (ret == 0) {
    lua_pushboolean(L, 0);
    return 1;
  }
  lua_pushinteger(L, ret);
  return 1;
}

static int document_setsel(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int sline = luaL_checkinteger(L, 2);
  int scol = luaL_checkinteger(L, 3);
  int eline = luaL_checkinteger(L, 4);
  int ecol = luaL_checkinteger(L, 5);

  EC_Pos spos = {sline, scol};
  EC_Pos epos = {eline, ecol};
  ::SendMessage(doc->window, ECM_SETSEL, (WPARAM) &spos, (LPARAM) &epos);
  return 0;
}

static int document_sendcommand(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int cmd = luaL_checkinteger(L, 2);
  ::SendMessage(doc->window, WM_COMMAND, cmd, 0);
  return 0;
}

static int document_insert_at(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int line = luaL_checkinteger(L, 2);
  int col = luaL_checkinteger(L, 3);
  const char *text = luaL_checkstring(L, 4);
  std::wstring buf = InternalStringToWide(text);
  EC_Pos pos = {line, col};
  EC_InsertText ecit = {buf.c_str(), (int) buf.size()};
  ::SendMessage(doc->window, ECM_INSERTTEXT, (WPARAM) &pos, (LPARAM) &ecit);
  return 0;
}

static int document_delete(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int sline = luaL_checkinteger(L, 2);
  int scol = luaL_checkinteger(L, 3);
  int eline = luaL_checkinteger(L, 4);
  int ecol = luaL_checkinteger(L, 5);

  EC_Pos spos = {sline, scol};
  EC_Pos epos = {eline, ecol};
  ::SendMessage(doc->window, ECM_DELETETEXT, (WPARAM) &spos, (LPARAM) &epos);
  return 0;
}

static int document_group_undo(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int action = lua_toboolean(L, 2);
  BOOL group = (action == 1) ? TRUE : FALSE;
  ::SendMessage(doc->window, ECM_GROUPUNDO, group, 0);
  return 0;
}

static int document_getline(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  int linenr = luaL_checkinteger(L, 2);
  const wchar_t* text = (const wchar_t*) ::SendMessage(doc->window, ECM_GETLINEBUF, linenr, 0);
  std::string buf = WideToInternalString(text);
  lua_pushstring(L, buf.c_str());
  return 1;
}

static int document_gettext(lua_State* L) {
  p_document doc = (p_document) auxiliar_checkclass(L, CLASS_DOCUMENT, 1);
  EC_SelInfo ecsi = {{0, 0}, {INT_MAX, INT_MAX}, NULL, EC_EOL_NULL};
  int sz = (int) ::SendMessage(doc->window, ECM_GETTEXT, (WPARAM) &ecsi, (LPARAM) 0);
  LOGD("sz: %d", sz);
  wchar_t* wbuf = new wchar_t[sz + 1];
  ecsi.lpBuffer = wbuf;
  ::SendMessage(doc->window, ECM_GETTEXT, (WPARAM) &ecsi, (LPARAM) 0);
  std::string ltext = WideToInternalString(wbuf);
  lua_pushstring(L, ltext.c_str());
  return 1;
}

static luaL_Reg meths[] = {
  {"__tostring", auxiliar_tostring},
  {"__len", document_len},
  {"fname", document_fname},
  {"seltext", document_seltext},
  {"caret", document_caret},
  {"insert", document_insert},
  {"gotoline", document_gotoline},
  {"redraw", document_redraw},
  {"hassel", document_hassel},
  {"setsel", document_setsel},
  {"sendcommand", document_sendcommand},
  {"insert_at", document_insert_at},
  {"delete", document_delete},
  {"group_undo", document_group_undo},
  {"getline", document_getline},
  {"gettext", document_gettext},
  {NULL, NULL}
};

int document_open(lua_State* L) {
  auxiliar_newclass(L, CLASS_DOCUMENT, meths);
  return 0;
}

