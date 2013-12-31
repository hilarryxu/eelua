/********************************************************************************
 * SDK for EverEdit
 * Copyright 2011-2013 everedit.net, All Rights Reserved.
 *
 * Plugin must implement the below functions
 *
 * DWORD EE_PluginInit(EE_Context* pContext);
 * DWORD EE_PluginUninit();
 * DWORD EE_PluginInfo(wchar_t* lpText, int nLength);
 *
 * Version: 1.1
 *
 *
 * 2013/01/10 First Version
 * 2013/11/12 Update for EverEdit 3.0
********************************************************************************/

#ifndef __EESDK_HPP__
#define __EESDK_HPP__

#include "eecore.h"

/**
 * @Msg:    Restore layout of docking windows. This message will be sent from EE on startup, DO NOT send this message to EE!
 * @Return: HWND: If plugin has a docking window, it should return a HWND handle, otherwise EE will not update its layout.
 * @wparam: const wchar_t*: Caption of docking window. Plugin can restore itself by this param.
**/
#define EEM_RESOTREDOCKINGWINDOW    WM_USER+1211

/**
 * @Msg:    Preview a file with built-in browser.
 * @wparam: WebPreviewData*
**/
#define EEM_WEBPREVIEW              WM_USER+1220

/**
 * @Msg:	Get handle of active document(Text mode). If current view was divided, it will return the activated one.
 * @Return: HWND
**/
#define EEM_GETACTIVETEXT           WM_USER+3000

/**
 * @Msg:	Get handle of active hex document(Hex Mode)
 * @Return: HWND
**/
#define EEM_GETACTIVEHEX            WM_USER+3001

/**
 * @Msg:    Open a file
 * @Return: HWND: return the handle of opened file
 * @wparam: const wchar_t*: full path of file
 * @lparam: EE_LoadFile*
**/
#define EEM_LOADFILE                WM_USER+3002

/**
 * @Msg:    Manage callback functions. Plugin can Add/Remove callbacks
 * @Return: int: Total callbacks
 * @wparam: int: Type of callback
 * @lparam: LPVOID: Address of callback function
**/
#define EEM_SETHOOK                 WM_USER+3003

/**
 * @Msg:    Manage a dockingWindow
 * @Return: BOOL: Return true if success
 * @wparam: int: Action
 *          1: Add
 *			2: Hide
 *			3: Activate
 * @lparam: (EE_DockingWindow*)
**/
#define EEM_DOCKINGWINDOW           WM_USER+3004

/**
 * @Msg:    Update UI element's state(Check/Uncheck/Disable/Enable). UI elements are menu/button items.
 * @Return: void
 * @wparam: int: ID of UI element
 * @lparam: EE_UpdateUIElement*: You must set a valid value for nAction
**/
#define EEM_UPDATEUIELEMENT         WM_USER+3004

/**
 * NOT IMPLEMENTED!
 * @Msg:    Get a array which includes all handle of text document. Plugin should destroy this array after use
 * @Return: HWND*: head address of this vector
 * @wparam: int*: An integer to receive the size
**/
#define EEM_GETHWNDLIST             WM_USER+3005

/**
 * NOT IMPLEMENTED!
 * @Msg:    Activate a child window
 * @Return: BOOL: Return true if this window does exist and be activated, otherwise return false
 * @wparam: HWND: Windows' handle
**/
#define EEM_SETACTIVEVIEW           WM_USER+3006

/**
 * @Msg:    Add multiple callbacks
 * @Return: int: Total callbacks
 * @wparam: EE_HookFunc*: Address of callback array
 * @lparam: int: array's size
**/
#define EEM_SETHOOKS                WM_USER+3007


/**
 * @Msg:    Get default UI font of EverEdit
 * @Return: HFONT: Font's handle. DO NOT destroy this handle!
**/
#define EEM_GETUIFONT               WM_USER+3008


/**
 * EE_LoadFile.nViewType
**/
#define WT_UNKNOWN                    0
#define WT_TEXT                       1
#define WT_HEX                        2

/**
 * EE_UpdateUIElementn.Action
**/
#define EE_UI_REMOVE                  0
#define EE_UI_ADD                     1
#define EE_UI_ENABLE                  2
#define EE_UI_SETCHECK                3

/**
 * Remove a callback
**/
#define EEHOOK_REMOVE                 0

/**
 * @Prototype:int OnPopupTextMenu(HWND hWnd, HWND hMenu, int x, int y )
 * @Vars:
 *		hWnd: 	Handle of current document
 *		hMenu: 	Handle of context menu
 *		x: 		mouse position x
 *		y: 		mouse position y
 *
 * Called on popuping context menu of text document. Plugin can add/remove menu items here.
 * The command id of menu item should be retrieved from EE_Context.
**/
#define EEHOOK_TEXTMENU               1

/**
 * @Prototype:int OnPopupHexMenu(HWND hWnd, HWND hMenu, int x, int y )
 * @Vars:
 *		hWnd: 	Handle of current document
 *		hMenu: 	Handle of context menu
 *		x: 		mouse position x
 *		y: 		mouse position y
 *
 * Called on popuping context menu of hex document. Plugin can add/remove menu items here
 * The command id of menu item should be retrieved from EE_Context.
**/
#define EEHOOK_HEXMENU                2

/**
 * @Prototype:int OnPreSaveFile(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of current document
 *
 * Called before saving a document
**/
#define EEHOOK_PRESAVE                3

/**
 * @Prototype:int OnPostSaveFile(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of current document
 *
 * Called after saving a document
**/
#define EEHOOK_POSTSAVE               4

/**
 * @Prototype:int OnPreCloseFile(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of current document
 *
 * Called before closing a document
**/
#define EEHOOK_PRECLOSE               5

/**
 * @Prototype:int OnPostCloseFile(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of current document
 *
 * Called after closing a document
**/
#define EEHOOK_POSTCLOSE              6

/**
 * @Prototype:int OnAppMessage(UINT uMsg, WPARM wp, LPARAM lp)
 * @Vars:
 *		uMsg: 	Message's ID
 *
 * Translate and Dispatch messages. Plugin can hook this function and monitor messages.
**/
#define EEHOOK_APPMSG                 7

/**
 * @Prototype:int OnIdle(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of main frame
 *
 * Idle message. Plugin can update UI element's state here! DO NOT do complicated operations in this hook!
**/
#define EEHOOK_IDLE                   8

/**
 * @Prototype:int OnPreTranslateMsg(MSG* pMsg)
 * @Vars:
 *		MSG*: 	See MSDN to get details about struct MSG
 *
 * Plugin can monitor messages before dispatching.
**/
#define EEHOOK_PRETRANSLATEMSG        9

/**
 * @Prototype:int OnAppResize(RECT* rect)
 * @Vars:
 *		rect: 	Client rect
 *
 * Application is reszing
**/
#define EEHOOK_APPRESIZE              10

/**
 * @Prototype:int OnAppActivate(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of main window
 *
 * Main application was activated
**/
#define EEHOOK_APPACTIVATE            11

/**
 * @Prototype:int OnChildActivate(HWND hOldWnd, HWND hNewWnd)
 * @Vars:
 *		hOldWnd: Handle of deactivated window
 *		hNewWnd: Handle of activated window
 *
 * Child window(Text/Hex/Browser) was activated
**/
#define EEHOOK_CHILDACTIVATE          12

/**
 * @Prototype:int OnRunningCommand(const wchar_t* command, int length)
 * @Vars:
 *		command: command's text
 *		length:	 length
 *
 * Plugin can handle commands from Command Bar
**/
#define EEHOOK_RUNCOMMAND             13

/**
 * @Prototype:int OnPreLoadTextFile(const wchar_t* pathname)
 * @Vars:
 *		pathname: file's full path
 *
 * File would be loaded as text format
**/
#define EEHOOK_PRELOAD                14

/**
 * @Prototype:int OnPostLoadTextFile(const wchar_t* pathname)
 * @Vars:
 *		pathname: file's full path
 *
 * File was loaded as text format. Note: EverEdit loads files asynchronously, plugin might not get content in this hook.
**/
#define EEHOOK_POSTLOAD               15

/**
 * @Prototype:int OnPostCreateTextFile(HWND hWnd)
 * @Vars:
 *		hWnd: Handle of this window
 *
 * A new text window was created
**/
#define EEHOOK_POSTNEWTEXT            16

/**
 * @Prototype:int OnPopupTabMenu(HMENU hMenu, int x, int y)
 * @Vars:
 *		hMenu:	Handle of menu
 *		x:		x position
 *		y:		y position
 *
 * Context menu of tab area will popup.
**/
#define EEHOOK_TABMENU                17

/**
 * @Prototype:int OnGetTextViewIcon(int type, HWND hWnd, HICON& ret)
 * @Vars:
 *		type:	Type of current window(Always is 1 now)
 *		hWnd:	Handle of window
 *		ret:	Handle of icon
 *
 * Plugin can customize icon of each text view.
**/
#define EEHOOK_VIEWICON               18

/**
 * @Prototype:int OnPopupDockMenu(HMENU hMenu, int x, int y)
 * @Vars:
 *		hMenu:	Handle of menu
 *		x:		x position
 *		y:		y position
 *
 * Context menu of dock tab will popup.
**/
#define EEHOOK_DOCKTABMENU            19

/**
 * @Prototype:int OnPreDirViewMenu(HMENU hMenu, int x, int y)
 * @Vars:
 *		hMenu:	Handle of menu
 *		x:		x position
 *		y:		y position
 *
 * Context menu of directory view will popup. Plugin can add menu items with any unique id which is different with ContextMenu
**/
#define EEHOOK_PREDIRVIEWMENU         20

/**
 * @Prototype:int OnPostDirViewMenu(HWND hWnd, int command)
 * @Vars:
 *		hWnd:	Handle of directory view window
 *		command:Selected command
 *
 * Context menu of directory view was popuped. Plugin executes some functions via command.
**/
#define EEHOOK_POSTDIRVIEWMENU        21

/**
 * @Prototype:int OnInputText(HWND hWnd, wchar_t* text)
 * @Vars:
 *		hWnd:	Handle of text window
 *		text:	content
 *
 * Text will be inserted into text document by keyboard.
**/
#define EEHOOK_TEXTCHAR               100

/**
 * @Prototype:int OnTextCommand(HWND hWnd, WPARAM wp, LPARAM lp)
 * @Vars:
 *		hWnd:	Handle of text window
 *
 * Command hook for text document
**/
#define EEHOOK_TEXTCOMMAND            101

/**
 * @Prototype:int OnUpdateTextView(HWND hWnd, ECNMHDR_TextUpdate* info)
 * @Vars:
 *		hWnd:	Handle of text window
 *		info:	info includes insert/delete range
 *
 * Delete/Insert operations were executed! All text were already updated, so DO NOT use info to get text!
**/
#define EEHOOK_UPDATETEXT             102

/**
 * @Prototype:int OnCaretChange(HWND hWnd, ECNMHDR_CaretChange* info)
 * @Vars:
 *		hWnd:	Handle of text window
 *		info:
 *
 * Caret's position was changed!
**/
#define EEHOOK_TEXTCARETCHANGE        103

/**
 * @Prototype:int OnPreWordComplete(HWND hWnd, AutoWordInput* info)
 * @Vars:
 *		hWnd:	Handle of text window
 *		info:
 *
 * Auto completion is collecting words.
**/
#define EEHOOK_PREWORDCOMPLETE        104

/**
 * @Prototype:int OnPostWordComplete(HWND hWnd, int id, const wchar_t* text, int length)
 * @Vars:
 *		hWnd:	Handle of text window
 *		text:	word's text
 *		length:	word's length
 *
 * Word will be inserted into document
**/
#define EEHOOK_POSTWORDCOMPLETE       105

/**
 * @Prototype:int OnCloseWordComplete()
 *
 * Window of auto completion was closed.
**/
#define EEHOOK_CLOSEWORDCOMPLETE      106

/**
 * Hook function can return this message to stop routing message!
**/
#define EEHOOK_RET_DONTROUTE          0xBC614E


/**
 * Position of docking window
**/
#define EE_DOCK_LEFT                0
#define EE_DOCK_RIGHT               1
#define EE_DOCK_BOTTOM              2
#define EE_DOCK_TOP					3
#define EE_DOCK_UNKNOWN             5

/**
 * Context of main application
**/
typedef struct tagEE_Context
{
    HWND 	hMain;			// Main window
    HWND 	hToolBar;		// Toolbar
    HWND 	hStatusBar;		// Status bar
    HWND 	hClient;		// Client window
    HWND 	hStartPage;		// Start page
    HMENU	hMainMenu;		// Main menu
    HMENU 	hPluginMenu;	// Plugin menu
    DWORD* 	pCommand;		// Command value. Plugin reserves some commands and set a new value for other plugins
    DWORD 	dwVersion;		// Version info
    DWORD 	dwBuild;		// Build info
    LCID 	dwLCID;			// LCID
} EE_Context;

/**
 * EE_HookFunc
**/
typedef struct tagEE_HookFunc
{
	int 	nType;			// type
 	LPVOID 	lpFunc;			// address of callback
} EE_HookFunc;

/**
 * EE_LoadFile
**/
typedef struct tagEE_LoadFile
{
    int 	nCodepage;		// Codepage of file
    int 	nViewType;		// View's type
    BOOL 	bReadOnly;		// Is read-only?
} EE_LoadFile;

/**
 * EE_UpdateUIElement
**/
typedef struct tagEE_UpdateUIElement
{
    int nAction;
    int nValue;			// update to new state
} EE_UpdateUIElement;

/**
 * EE_DockingWindow
**/
typedef struct tagEE_DockingWindow
{
    HWND hWnd;
    int nSide;			// valid on adding
} EE_DockingWindow;

/**
 * AutoWordInput
**/
typedef struct tagAutoWordInput
{
    EC_Pos* pos;					// caret pos
    const 	wchar_t* lpHintText;	// User is inputting some texts
    int 	nLength;
} AutoWordInput;

/**
 * Plugin returns words for auto completion
**/
typedef struct tagAutoWordList
{
    wchar_t** 	lpWords;			// words
    int 		nCount;				// count
    HICON 		hIcon;				// Not used!
    DWORD 		id;					// ID
} AutoWordList;

/**
 * Web preview
**/
typedef struct tagWebPreviewData
{
	const wchar_t* lpPathName;	// full path
	const wchar_t* lpCharset;	// Not used!
	bool bCanDelete;			// Can be delete after closing EverEdit?
} WebPreviewData;

#endif //__EESDK_HPP__
