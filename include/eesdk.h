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
 *
 * 2013/01/10 First Version
 * 2013/11/12 Update for EverEdit 3.0
 * 2014/03/19 Update for EverEdit 3.2.0(3548)
 * 2014/05/26 Update for 3.2.4.3696+
********************************************************************************/

#ifndef __EESDK_HPP__
#define __EESDK_HPP__

#include "eecore.h"

/**
 * @Msg:    execute a script
 * @wparam: const wchar_t*: full path of script
 * @lparam: BOOL: 0: execute with at least one document exists. 1: just execute
**/
#define EEM_EXCUTESCRIPT			WM_USER+1203

/**
 * @Msg:    get font of docking windows
 * @Return: HFONT, handle of font(DON'T destroy it)
**/
#define EEM_GETDOCKFONT				WM_USER+1225

/**
 * @Msg:    Preview a file with built-in browser.
 * @wparam: WebPreviewData*
**/
#define EEM_WEBPREVIEW              WM_USER+1220

/**
 * @Msg:	Get handle of active document(Text mode). If current view was divided, it will return the activated one.
 *			If you want to get child frame, use GetParent(...)
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
 * @Return: HWND: return the child frame of opened file
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
 * @Msg:    Get an array which includes all handle of child frames (Text/Hex/Browser).
 * @Return: int: The count of child frames
 * @wparam: HWND*: A buffer to receive the handles. Set it to NULL to get the count of child frames.
**/
#define EEM_GETFRAMELIST            WM_USER+3005

/**
 * @Msg:    Activate a child frame
 * @Return: BOOL: Return true if this window does exist and be activated, otherwise return false
 * @wparam: HWND: Handle of child frame
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
 * @Msg:    Update UI element's state(Check/Uncheck/Disable/Enable). UI elements are menu/button items.
 * @Return: void
 * @wparam: int: ID of UI element
 * @lparam: EE_UpdateUIElement*: You must set a valid value for nAction
**/
#define EEM_UPDATEUIELEMENT         WM_USER+3009

/**
 * @Msg:    Output text to outputwindow
 * @Return: void
 * @wparam: wchar_t*: text
 * @lparam: int*: length
**/
#define EEM_OUTPUTTEXT              WM_USER+3010


/**
 * @Msg:    Get handle of active output window
 * @Return: HWND: it may be null, Set wparam to TRUE to show the outputwindow and then retrive the handle again.
 * @wparam: BOOL: show or hide output window
**/
#define EEM_GETOUTPUTHWND           WM_USER+3011

/**
 * @Msg:    Get handle of document from child frame
 * @Return: HWND: it may be null if can't get hwnd
 * @wparam: HWND: handle of child frame, it must be a valid child frame
**/
#define EEM_GETDOCFROMFRAME			WM_USER+3012

/**
 * @Msg:    Popup a message box
 * @Return: int: 
 * @wparam: MsgBoxData*
**/
#define EEM_MSGBOX					WM_USER+3013

/**
 * @Msg:    Paint a rect with app theme
 * @wparam: HDC
 * @lparam: RECT*
**/
#define EEM_PAINTWITHAPPTHEME		WM_USER+3014


/**
 * @Msg:    Set type of a textview
 * @wparam: HWND: Child frame
 * @lparam: int: value. (use 0xFF to get current value).
 * TVT_DEFAULT=0
 * TVT_GREP=1
 * TVT_SORT=2
 * TVT_SNIPPET=3
 * TVT_REPLACE=4
 * TVT_FTP=5
 * TVT_RETURN=0xFF
**/
#define EEM_SETVIEWTYPE				WM_USER+3015

/**
 * @Msg:	Get child frame from path name
 * @Return:	If this file was already opened then return the handle of frame, otherwise return 0
 * @wparam: w_char*: full path name of file
 **/
#define EEM_GETFRAMEFROMPATH		WM_USER+3016

/**
 * @Msg:	Get current frame type
 * @Return:	return an int value (FRAMETYPE_TEXT/FRAMETYPE_HEX/FRAMETYPE_UNKOWN)
 * @wparam: HWND: Child frame
 **/
#define EEM_GETFRAMETYPE			WM_USER+3017

/**
 * @Msg:	Get frame's path
 * @Return:	return full path name of view frame
 * @wparam: HWND: Child frame
 **/
#define EEM_GETFRAMEPATH			WM_USER+3018

/**
 * @Msg:	Get handle of active frame
 * @Return:	return the handle
 **/
#define EEM_GETACTIVEFRAME			WM_USER+3019

/**
 * @Msg:	Get color table of application
 * @Return:	return the address of color table
 **/
#define EEM_GETAPPCOLORTBL			WM_USER+3020

/**
 * @Msg:	Show a built-in dialog
 * @wparam: int: dialog id
 * @lparam: LPCTSTR: some strings
**/
#define EEM_SWOWDIALOG				WM_USER+3021

/**
 * @Msg:	Query a docking window side
 * @wparam: LPCTSTR: title of a docking window
 * @lparam: int: side
**/
#define EEM_QUERYDOCKSIDE			WM_USER+3022

/**
 * @Msg:	Query app metrics
 * @wparam:	see metrics enum
 * @return:	value
*/
#define EEM_GETAPPMETRICS			WM_USER+3023


/**
 * EE_UpdateUIElementn.Action
**/
#define EE_UI_REMOVE                  0
#define EE_UI_ADD                     1
#define EE_UI_ENABLE                  2
#define EE_UI_SETCHECK                4

/**
 * Remove a callback
**/
#define EEHOOK_REMOVE                 0

/**
 * @Prototype:int OnPrePopupTextMenu(HWND hWndDoc, HMENU hMenu, int x, int y )
 * @Vars:
 *		hWndDoc: Handle of current text document
 *		hMenu: 	Handle of context menu
 *		x: 		mouse position x
 *		y: 		mouse position y
 *
 * Called before popuping context menu of current document. Plugin can add/remove menu items here.
 * The command id of menu item should be retrieved from EE_Context.
**/
#define EEHOOK_PRETEXTMENU            1

/**
 * @Prototype:int OnPopupHexMenu(HWND hWndDoc, HMENU hMenu, int x, int y )
 * @Vars:
 *		hWndDoc: 	Handle of current hex document
 *		hMenu: 	Handle of context menu
 *		x: 		mouse position x
 *		y: 		mouse position y
 *
 * Called on popuping context menu of hex document. Plugin can add/remove menu items here
 * The command id of menu item should be retrieved from EE_Context.
**/
#define EEHOOK_HEXMENU                2

/**
 * @Prototype:int OnPreSaveFile(HWND hChildFrame)
 * @Vars:
 *		hChildFrame: 	Handle of current child frame
 *
 * Called before saving a document
**/
#define EEHOOK_PRESAVE                3

/**
 * @Prototype:int OnPostSaveFile(HWND hChildFrame)
 * @Vars:
 *		hChildFrame: 	Handle of current child frame
 *
 * Called after saving a document
**/
#define EEHOOK_POSTSAVE               4

/**
 * @Prototype:int OnPreCloseFile(HWND hChildFrame)
 * @Vars:
 *		hChildFrame: 	Handle of current child frame
 *
 * Called before closing a document
**/
#define EEHOOK_PRECLOSE               5

/**
 * @Prototype:int OnPostCloseFile(HWND hChildFrame)
 * @Vars:
 *		hChildFrame: 	Handle of current child frame
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
 * @Prototype:int OnAppIdle(HWND hWnd, HWND hChildFrame)
 * @Vars:
 *		hWnd: 	Handle of main frame
 *
 * Idle message. Plugin can update UI element's state here! DO NOT do complicated operations in this hook!
**/
#define EEHOOK_APPIDLE                8

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
 * @Prototype:int OnRunningCommand(const wchar_t* command, int length)
 * @Vars:
 *		command: command's text
 *		length:	 length
 *
 * Plugin can handle commands from Command Bar
**/
#define EEHOOK_RUNCOMMAND             13

/**
 * @Prototype:int OnPreLoadTextFile(const wchar_t* pathname, HWND hChildFrame)
 * @Vars:
 *		pathname: file's full path
 *		hChildFrame: Handle of this child frame
 *
 * File would be loaded as text format
**/
#define EEHOOK_PRELOAD                14

/**
 * @Prototype:int OnPostLoadTextFile(const wchar_t* pathname, HWND hChildFrame)
 * @Vars:
 *		pathname: file's full path
 *		hChildFrame: Handle of this child frame
 *
 * File was loaded as text format. Note: EverEdit loads files asynchronously, plugin might not get content in this hook.
**/
#define EEHOOK_POSTLOAD               15

/**
 * @Prototype:int OnPostCreateTextFile(HWND hChildFrame)
 * @Vars:
 *		hChildFrame: Handle of this child frame
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
 * @Prototype:int OnGetTextViewIcon(int type, HWND hChildFrame, HICON& ret)
 * @Vars:
 *		type:	Type of current window(Always is 1 now)
 *		hChildFrame:	Handle of child frame
 *		ret:	Handle of icon
 *
 * Plugin can customize icon of each text view.
**/
#define EEHOOK_VIEWICON               18

/**
 * @Prototype:int OnPopupDockMenu(HMENU hMenu, int x, int y, HWND hWnd)
 * @Vars:
 *		hMenu:	Handle of menu
 *		x:		x position
 *		y:		y position
 *		hWnd:	Handle of selected docking window
 *
 * Context menu of dock tab will popup.
**/
#define EEHOOK_DOCKTABMENU            19

/**
 * @Prototype:int OnPreDirViewMenu(HWND hWnd, HMENU hMenu, int x, int y)
 * @Vars:
 *		hWnd:	Handle of directory view window
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
 * @Prototype:int OnPostPopupTextMenu(HWND hWndDoc, HMENU hMenu, int nCommand )
 * @Vars:
 *		hWndDoc:	Handle of current text document
 *		hMenu: 		Handle of context menu
 *		nCommand: 	Selected Command
 *
 * Called after popuping context menu of current document.
**/
#define EEHOOK_POSTTEXTMENU           22

/**
 * @Prototype:int OnAddTabPage(HWND hChildFrame)
 * @Vars:
 *		hChildFrame:	Handle of child frame
**/
#define EEHOOK_ADDTABPAGE             23

/**
 * @Prototype:int OnRemoveTabPage(HWND hChildFrame)
 * @Vars:
 *		hChildFrame:	Handle of child frame
**/
#define EEHOOK_REMOVETABPAGE          24

/**
 * @Prototype:int OnTabPageInfoChanged(HWND hChildFrame)
 * @Vars:
 *		hChildFrame:	Handle of child frame
 *
 * Called after infomation of tab page changed, such as icon/title...
**/
#define EEHOOK_TABPAGEINFOCHANGED     25

/**
 * @Prototype:int OnTabPageSelChanged(HWND hOldFrame, HWND hNewFrame)
 * @Vars:
 *		hOldFrame:	Handle of old child frame
 *		hNewFrame:	Handle of new child frame
 *
**/
#define EEHOOK_TABPAGESELCHANGED      26

/**
 * @Prototype:int OnTextIdle(HWND hWnd)
 * @Vars:
 *		hWnd: 	Handle of active document
 *
 * Idle message. Plugin can update UI element's state of document here! DO NOT do complicated operations in this hook!
**/
#define EEHOOK_TEXTIDLE               27

/**
 * @Prototype:int OnRestoreDockingWindow(const wchar_t* caption, int side)
 * @Vars:
 *		const wchar_t*: Caption of docking window. Plugin can restore itself by this param.
 *		side: this docking window should be in [side]
 *
**/
#define EEHOOK_RESTOREDOCKINGWINDOW   28

/**
 * @Prototype:int OnListPluginCommand(HWND hWnd)
 * @Vars:
 *		hWnd*: handle of list view control in shortcut dialog. Plugin should append items from subitem 1
 *             subitem 0: DON'T insert text here
 *             subitem 1: title of this command, it must be pl_xxxxxxxx
 *			   subimte 2: short description
 *			   subimte 3: long description
**/
#define EEHOOK_LISTPLUGINCOMMAND	  29

/**
 * @Prototype:int OnExecutePluginCommand(const wchar_t* command)
 * @Vars:
 *		const wchar_t*: command title
**/
#define EEHOOK_EXECUTEPLUGINCOMMAND	  30

/**
 * @Prototype:int OnMenuSelect(int id, wchar_t* text, int length)
 * @Vars:
 *		id: menu id
 *		text*: a buffer to hold the description of this menu id
 *		length: length of buffer
 *
 * Called on mouse hover items of popup menu(Note: this menu be popuped from mainframe)
**/
#define EEHOOK_MENUSELECT	 		  31

/**
 * @Prototype:int OnSettingChanged(DWORD dialog, DWORD control)
 * @Vars:
 *		dialog: dialog id
 *		control: control id
 *
 * Called after user changed some settings(Theme, Font, etc..)
**/
#define EEHOOK_SETTINGCHANGED 		  32


/**
 * @Prototype:int OnInputText(HWND hWndDoc, wchar_t* text, int length)
 * @Vars:
 *		hWndDoc: Handle of active document
 *		text:	content
 *		length:	size of text
 *
 * Text will be inserted into text document by keyboard.
**/
#define EEHOOK_TEXTCHAR               100

/**
 * @Prototype:int OnTextCommand(HWND hWndDoc, UINT uMsg, WPARAM wp, LPARAM lp)
 * @Vars:
 *		hWndDoc:	Handle of text window
 *
 * Command hook for active document
**/
#define EEHOOK_TEXTCOMMAND            101

/**
 * @Prototype:int OnUpdateTextView(HWND hChildFrame, ECNMHDR_TextUpdate* info)
 * @Vars:
 *		hChildFrame:	Handle of child frame
 *		info:	info includes insert/delete range
 *
 * Delete/Insert operations were executed! All text were already updated, so DO NOT use info to get text!
**/
#define EEHOOK_UPDATETEXT             102

/**
 * @Prototype:int OnCaretChange(HWND hChildFrame, ECNMHDR_CaretChange* info)
 * @Vars:
 *		hChildFrame:	Handle of child frame
 *		info:
 *
 * Caret's position was changed!
**/
#define EEHOOK_TEXTCARETCHANGE        103

/**
 * @Prototype:int OnPreWordComplete(HWND hWndDoc, AutoWordInput* info)
 * @Vars:
 *		hWndDoc: Handle of active document
 *		info:
 *
 * Auto completion is collecting words.
**/
#define EEHOOK_PREWORDCOMPLETE        104

/**
 * @Prototype:int OnPostWordComplete(HWND hWndDoc, int id, const wchar_t* text, int length)
 * @Vars:
 *		hWndDoc: Handle of active document
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
 * @Prototype:int OnPostSaveHexFile(HWND hChildFrame)
 * @Vars:
 *		hChildFrame: 	Handle of current hex child frame
 *
 * Called after saving a hex document
**/
#define EEHOOK_POSTSAVEHEX            107


/**
 * @Prototype:int OnPreExecuteScript(const wchar_t* pathname)
 * @Vars:
 *		hChildFrame: 	Handle of current hex child frame
 *
 * Called before executing a script, so plugin can hook this message and add pythong/lua native support
**/
#define EEHOOK_PREEXECUTESCRIPT       108


/**
 * Hook function can return this value to stop message routing!
**/
#define EEHOOK_RET_DONTROUTE          0xBC614E


/**
 * Position of docking window
**/
#define EE_DOCK_LEFT                0
#define EE_DOCK_BOTTOM              1
#define EE_DOCK_RIGHT               2
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
    DWORD* 	pCommand;		// invalid from 3.20
	DWORD	dwCommand;		// Command value. Plugin reserves some commands and set a new value for other plugins
    DWORD 	dwVersion;		// Version info
    DWORD 	dwBuild;		// Build info
    LCID 	dwLCID;			// LCID
    HMODULE hModule;
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
    int 	nEncoding;		// Encoding of this file, set it to 1 to detect it automatically
    int 	nViewType;		// View's type
    BOOL 	bReadOnly;		// Is read-only?
    BOOL	bAddToMRU;		// Add it into MRU?
	BOOL	bAsynMode;		// Load file asynchronously
} EE_LoadFile;


/**
 * EE_LoadFile.nViewType
**/
#define WT_UNKNOWN                    0
#define WT_TEXT                       1
#define WT_HEX                        2

/**
 * EEM_GETFRAMETYPE
**/
#define FRAMETYPE_UNKOWN			  0
#define FRAMETYPE_TEXT				  1
#define FRAMETYPE_HEX				  2

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
	bool bSplitGroup;			// show in split group
} WebPreviewData;

/**
 * MsgBox
**/
typedef struct tagMsgBoxData
{
	const wchar_t* lpMsg;
	const wchar_t* lpCaption;
	HWND hWnd;
	DWORD dwFlag;
} MsgBoxData;

/**
 * App metrics
**/
#define EE_METRIC_TOOLBARICONSIZE		1

#endif //__EESDK_HPP__
