// SDK for EverEdit
// Copyright ?2011-2013 everedit.net, All Rights Reserved.
//
// 插件最少需要实现EE_PluginInit, 否则不加载
// DWORD EE_PluginInit(EE_Context* pContext);
// DWORD EE_PluginUninit();
// DWORD EE_PluginInfo(wchar_t* lpText, int nLength);
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 * 2013/01/10 First Version
*******************************************************************************/

#ifndef __EESDK_HPP__
#define __EESDK_HPP__

#include "eecore.h"

//******************************************************************************
// Messages

/**
 * @Return: (HWND)获取当前激活的文本文档
 */
#define EEM_GETACTIVETEXT           WM_USER+3000

/**
 * @Return: (HWND)获取当前激活的HEX文档
 */
#define EEM_GETACTIVEHEX            WM_USER+3001

/**
 * @Msg:    打开指定的文件
 * @Return: (HWND)显示该文件的窗口
 * @wparam: (const wchar_t*)文件的全路径
 * @lparam: (EE_LoadFile)
 */
#define EEM_LOADFILE                WM_USER+3002

/**
 * @Msg:    设定各种回调函数,可以用于添加/删除Hook
 * @Return: (int)回调函数总数
 * @wparam: (int)回调函数的枚举值
 * @lparam: (LPVOID)回调函数地址
 */
#define EEM_SETHOOK                 WM_USER+3003

/**
 * @Msg:    添加DockingWindow
 * @Return: (BOOL)
 * @wparam: (BOOL)true:添加,false:删除
 * @lparam: (EE_DockingWindow*)
 */
#define EEM_DOCKINGWINDOW           WM_USER+3004

/**
 * @Msg:    添加/删除/更新界面元素状态
 * @Return: (void)
 * @wparam: (int)命令
 * @lparam: (EE_UpdateUIElement*)元素状态,其中nUpdate必须指定
 */
#define EEM_UPDATEUIELEMENT         WM_USER+3004

/**
 * @Msg:    获取一个列表,该列表包含所有的text窗口的句柄,注意:调用者必须手工销毁(delete[] list)
 * @Return: (HWND*)列表首地址
 * @wparam: (int*)接受个数的地址
 */
#define EEM_GETHWNDLIST             WM_USER+3005

/**
 * @Msg:    激活一个子视图窗口
 * @Return: (BOOL)True:该窗口存在且被成功设置为激活, 否则为:False
 * @wparam: (HWND子窗口的句柄
 */
#define EEM_SETACTIVEVIEW           WM_USER+3006

/**
 * @Msg:    批量添加各种回调函数
 * @Return: (int)回调函数总数
 * @wparam: (int)数组起始地址(EE_HookFunc*)
 * @lparam: (int)数组个数
 */
#define EEM_SETHOOKS                WM_USER+3007


/**
 * @Msg:    恢复DockingWindow的位置信息. 该消息在启动时由系统自动发送, 用户不可调用!
 * @Return: (HWND)返回有效的窗口信息
 * @wparam: (const wchar_t*)该DockingWindow的Caption
 */
#define EEM_RESOTREDOCKINGWINDOW    WM_USER+1211


//******************************************************************************

// EE_LoadFile.nViewType
#define WT_UNKNOWN                    0
#define WT_TEXT                       1
#define WT_HEX                        2

//EE_UpdateUIElementn.Action
#define EE_UI_REMOVE                  0
#define EE_UI_ADD                     1
#define EE_UI_ENABLE                  2
#define EE_UI_SETCHECK                3

//******************************************************************************
// 各种回调函数原型说明

// 删除指定的回调函数
#define EEHOOK_REMOVE                 0

// int(HWND, HMENU, int, int)
#define EEHOOK_TEXTMENU               1

// int(HWND, HMENU, int, int)
#define EEHOOK_HEXMENU                2

// int(HWND)
#define EEHOOK_PRESAVE                3

// int(HWND)
#define EEHOOK_POSTSAVE               4

// int(HWND)
#define EEHOOK_PRECLOSE               5

// int(HWND)
#define EEHOOK_POSTCLOSE              6

// int(HWND, WPARAM, LPARAM)
#define EEHOOK_APPMSG                 7

// int(HWND)
#define EEHOOK_IDLE                   8

// int(MSG*)
#define EEHOOK_PRETRANSLATEMSG        9

// int(RECT*)
#define EEHOOK_APPRESIZE              10

// int(HWND)
#define EEHOOK_APPACTIVATE            11

// int(HWND old, HWND new)
#define EEHOOK_CHILDACTIVE            12

// int(const wchar_t*, int)
#define EEHOOK_RUNCOMMAND             13

// int(const wchar_t*LPVOID)
#define EEHOOK_PRELOAD                14

// int(const wchar_t*LPVOID)
#define EEHOOK_POSTLOAD               15

// int(HWND)
#define EEHOOK_POSTNEWTEXT            16

// int(HMENU, int, int)
#define EEHOOK_TABMENU                17

// int(int, HWND, HICON*)
#define EEHOOK_VIEWICON               18

// int(HWND, wchar_t*)
#define EEHOOK_TEXTCHAR               100

// int(HWND, WPARAM, LPARAM)
#define EEHOOK_TEXTCOMMAND            101

// int(HWND, ECNMHDR_TextUpdate*)
#define EEHOOK_UPDATETEXT             102

// int(HWND, ECNMHDR_CaretChange*)
#define EEHOOK_TEXTCARETCHANGE        103

// AutoWordList*(HWND, AutoWordInput*)
#define EEHOOK_PREWORDCOMPLETE        104

// int(int, LPCTSTR, int)
#define EEHOOK_POSTWORDCOMPLETE       105

// int()
#define EEHOOK_CLOSEWORDCOMPLETE      106

// int(HWND, wchar_t)
#define EEHOOK_HEXCHAR                200


// 函数返回此消息表示不再继续往其它的callback路由, magic value
#define EEHOOK_RET_DONTROUTE          0xBC614E

//******************************************************************************
// 插件用函数和结构体

//上下文信息
struct EE_Context
{
    HWND hMain;
    HWND hToolBar;
    HWND hStatusBar;
    HWND hClient;
    HWND hStartPage;
    HMENU hMainMenu;
    HMENU hPluginMenu;
    DWORD* pCommand;
    DWORD dwVersion;
    DWORD dwBuild;
    LCID dwLCID;
};

//用于批量添加Hook
struct EE_HookFunc
{
	int nType;
 	LPVOID lpFunc;
};

// Messages
struct EE_LoadFile
{
    int nCodepage;
    int nViewType;
    BOOL bReadOnly;
};

//界面元素更新
struct EE_UpdateUIElement
{
    int nAction;
    int nValue;
};

// 窗口停靠的位置
#define EE_DOCK_LEFT                0
#define EE_DOCK_TOP                 1
#define EE_DOCK_RIGHT               2
#define EE_DOCK_BOTTOM              3
#define EE_DOCK_FLOAT               4

#define EE_DOCK_NOLEFT              (1<<EE_DOCK_LEFT)
#define EE_DOCK_NOTOP               (1<<EE_DOCK_TOP)
#define EE_DOCK_NORIGHT             (1<<EE_DOCK_RIGHT)
#define EE_DOCK_NOBOTTOM            (1<<EE_DOCK_BOTTOM)

struct EE_DockingWindow
{
    HWND hWnd;
    BOOL bDestroyOnClose;
    int nSide; 
};


//自动完成时用户输入的提示文本信息
struct AutoWordInput
{
    EC_Pos* pos;
    const wchar_t* lpHintText;
    int nLength;
};

//插件返回的自动完成信息
struct AutoWordList
{
    wchar_t** lpWords;
    int nCount;
    HICON hIcon;
    DWORD id;
};


#endif //__EESDK_HPP__

