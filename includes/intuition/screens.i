	IFND	INTUITION_SCREENS_I
INTUITION_SCREENS_I	SET	1
**
**	$Filename: intuition/screens.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC

	IFND GRAPHICS_GFX_I
	INCLUDE "graphics/gfx.i"
	ENDC

	IFND GRAPHICS_CLIP_I
	INCLUDE "graphics/clip.i"
	ENDC

	IFND GRAPHICS_VIEW_I
	INCLUDE "graphics/view.i"
	ENDC

	IFND GRAPHICS_RASTPORT_I
	INCLUDE "graphics/rastport.i"
	ENDC

	IFND GRAPHICS_LAYERS_I
	INCLUDE "graphics/layers.i"
	ENDC

; ======================================================================== 
; === Screen ============================================================= 
; ======================================================================== 
 STRUCTURE Screen,0

    APTR sc_NextScreen		; linked list of screens
    APTR sc_FirstWindow		; linked list Screen's Windows

    WORD sc_LeftEdge		; parameters of the screen
    WORD sc_TopEdge		; parameters of the screen

    WORD sc_Width		; null-terminated Title text
    WORD sc_Height		; for Windows without ScreenTitle

    WORD sc_MouseY		; position relative to upper-left
    WORD sc_MouseX		; position relative to upper-left

    WORD sc_Flags		; see definitions below

    APTR sc_Title
    APTR sc_DefaultTitle

    ; Bar sizes for this Screen and all Window's in this Screen
    BYTE sc_BarHeight
    BYTE sc_BarVBorder
    BYTE sc_BarHBorder
    BYTE sc_MenuVBorder
    BYTE sc_MenuHBorder
    BYTE sc_WBorTop
    BYTE sc_WBorLeft
    BYTE sc_WBorRight
    BYTE sc_WBorBottom

    BYTE sc_KludgeFill00	; This is strictly for word-alignment 

    ; the display data structures for this Screen
    APTR sc_Font			; this screen's default font
    STRUCT sc_ViewPort,vp_SIZEOF	; describing the Screen's display
    STRUCT sc_RastPort,rp_SIZEOF	; describing Screen rendering
    STRUCT sc_BitMap,bm_SIZEOF		; auxiliary graphexcess baggage
    STRUCT sc_LayerInfo,li_SIZEOF	; each screen gets a LayerInfo

    ; You supply a linked-list of Gadgets for your Screen.
    ; This list DOES NOT include system Gadgets.  You get the standard
    ; system Screen Gadgets by default
    APTR sc_FirstGadget

    BYTE sc_DetailPen		; for bar/border/gadget rendering
    BYTE sc_BlockPen		; for bar/border/gadget rendering

    ; the following variable(s) are maintained by Intuition to support the
    ; DisplayBeep() color flashing technique
    WORD sc_SaveColor0

    ; This layer is for the Screen and Menu bars
    APTR sc_BarLayer		; was "BarLayer"

    APTR sc_ExtData

    APTR sc_UserData		; general-purpose pointer to User data 

    LABEL sc_SIZEOF


; --- FLAGS SET BY INTUITION -------------------------------------------------
; The SCREENTYPE bits are reserved for describing various Screen types
; available under Intuition.  
SCREENTYPE	EQU	$000F	; all the screens types available 
; --- the definitions for the Screen Type ------------------------------------
WBENCHSCREEN	EQU	$0001	; Ta Da!  The Workbench
CUSTOMSCREEN	EQU	$000F	; for that special look

SHOWTITLE	EQU	$0010	; this gets set by a call to ShowTitle() 

BEEPING		EQU	$0020	; set when Screen is beeping 

CUSTOMBITMAP	EQU	$0040	; if you are supplying your own BitMap

SCREENBEHIND	EQU	$0080	; if you want your screen to open behind
				; already open screens

SCREENQUIET	EQU	$0100	; if you do not want Intuition to render
				; into your screen (gadgets, title)

STDSCREENHEIGHT EQU	-1	; supply in NewScreen.Height

; ======================================================================== 
; === NewScreen ========================================================== 
; ======================================================================== 
 STRUCTURE NewScreen,0

    WORD ns_LeftEdge		; initial Screen dimensions
    WORD ns_TopEdge		; initial Screen dimensions
    WORD ns_Width		; initial Screen dimensions
    WORD ns_Height		; initial Screen dimensions
    WORD ns_Depth		; initial Screen dimensions

    BYTE ns_DetailPen		; default rendering pens (for Windows too)
    BYTE ns_BlockPen		; default rendering pens (for Windows too)

    WORD ns_ViewModes		; display "modes" for this Screen

    WORD ns_Type		; Intuition Screen Type specifier

    APTR ns_Font		; default font for Screen and Windows

    APTR ns_DefaultTitle	; Title when Window doesn't care

    APTR ns_Gadgets		; Your own initial Screen Gadgets

    ; if you are opening a CUSTOMSCREEN and already have a BitMap 
    ; that you want used for your Screen, you set the flags CUSTOMBITMAP in
    ; the Types variable and you set this variable to point to your BitMap
    ; structure.  The structure will be copied into your Screen structure,
    ; after which you may discard your own BitMap if you want
    APTR ns_CustomBitMap

 LABEL	  ns_SIZEOF

	ENDC	; INTUITION_SCREENS_I
