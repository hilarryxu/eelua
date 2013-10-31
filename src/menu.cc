// Copyright (C) 2013 by Larry Xu
//
// This file is part of eelua, distributed under the MIT License.
// For full terms see the included LICENSE file.

#include "menu.h"

#include <windows.h>

#include "eesdk.h"
#include "auxiliar.h"

#include "config.h"
#include "util.h"
#include "document.h"

#define LOG_TAG "menu"
#define CLASS_MENU "eelua{menu}"

typedef struct t_menu_ {
  HMENU menu;
} t_menu;
typedef t_menu* p_menu;

static int failed(lua_State* L, const char* errmsg) {
  lua_pushnil(L);
  lua_pushstring(L, errmsg);
  return 2;
}

int menu_new(lua_State* L) {
  p_menu menu = (p_menu) lua_newuserdata(L, sizeof(t_menu));
  auxiliar_setclass(L, CLASS_MENU, -1);
  menu->menu = ::CreatePopupMenu();
  if (!::IsMenu(menu->menu)) {
    lua_pop(L, 1);
    return failed(L, "failed to create menu");
  } else {
    return 1;
  }
}

static int menu_new2(lua_State* L, HMENU hmenu) {
  p_menu menu = (p_menu) lua_newuserdata(L, sizeof(t_menu));
  auxiliar_setclass(L, CLASS_MENU, -1);
  menu->menu = hmenu;
  if (!::IsMenu(menu->menu)) {
    lua_pop(L, 1);
    return failed(L, "failed to create menu");
  } else {
    return 1;
  }
}

static int menu_len(lua_State* L) {
  p_menu menu = (p_menu) auxiliar_checkclass(L, CLASS_MENU, 1);
  lua_pushinteger(L, ::GetMenuItemCount(menu->menu));
  return 1;
}

static int menu_add_item(lua_State* L) {
  p_menu menu = (p_menu) auxiliar_checkclass(L, CLASS_MENU, 1);
  UINT_PTR cmdid = luaL_checkinteger(L, 2);
  const char *ltext = luaL_checkstring(L, 3);
  std::wstring text = InternalStringToWide(ltext);
  ::AppendMenuW(menu->menu, MF_STRING, cmdid, text.c_str());
  return 0;
}

static int menu_add_separator(lua_State* L) {
  p_menu menu = (p_menu) auxiliar_checkclass(L, CLASS_MENU, 1);
  ::AppendMenuW(menu->menu, MF_SEPARATOR, 0, NULL);
  return 0;
}

static int menu_insert_submenu(lua_State* L) {
  p_menu menu = (p_menu) auxiliar_checkclass(L, CLASS_MENU, 1);
  int pos = luaL_checkinteger(L, 2);
  p_menu submenu = (p_menu) auxiliar_checkclass(L, CLASS_MENU, 3);
  const char *ltext = luaL_checkstring(L, 4);
  std::wstring text = InternalStringToWide(ltext);
  ::InsertMenuW(menu->menu, pos, MF_BYPOSITION | MF_STRING | MF_POPUP,
                (UINT_PTR) (submenu->menu), text.c_str());
  return 0;
}

static luaL_Reg meths[] = {
  {"__tostring", auxiliar_tostring},
  {"__len", menu_len},
  {"add_item", menu_add_item},
  {"add_separator", menu_add_separator},
  {"insert_submenu", menu_insert_submenu},
  {NULL, NULL}
};

int menu_open(lua_State *L, EE_Context* context) {
  auxiliar_newclass(L, CLASS_MENU, meths);
  menu_new2(L, context->hMainMenu);  // eelua, main_menu
  lua_setfield(L, -2, "main_menu");  // eelua
  menu_new2(L, context->hPluginMenu);  // eelua, plugin_menu
  lua_setfield(L, -2, "plugin_menu");  // eelua
  return 0;
}

