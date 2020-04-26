	IFND	INTUITION_INTUITION_I
INTUITION_INTUITION_I	SET	1
**
**	$Filename: intuition/intuition.i $
**	$Release: 1.3 $
**
**	main intuition include 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC

	IFND	GRAPHICS_GFX_I
	include "graphics/gfx.i"
	ENDC

	IFND	GRAPHICS_CLIP_I
	include "graphics/clip.i"
	ENDC

	IFND	GRAPHICS_VIEW_I
	include "graphics/view.i"
	ENDC

	IFND	GRAPHICS_RASTPORT_I
	include "graphics/rastport.i"
	ENDC

	IFND	GRAPHICS_LAYERS_I
	include "graphics/layers.i"
	ENDC

	IFND	GRAPHICS_TEXT_I
	include "graphics/text.i"
	ENDC

	IFND EXEC_PORTS_I
	include "exec/ports.i"
	ENDC

	IFND	DEVICES_TIMER_I
	include "devices/timer.i"
	ENDC

	IFND	DEVICES_INPUTEVENT_I
	include "devices/inputevent.i"
	ENDC


; ========================================================================;
; === Menu ===============================================================;
; ========================================================================;
 STRUCTURE Menu,0

    APTR  mu_NextMenu	; menu pointer, same level
    WORD mu_LeftEdge	; position of the select box
    WORD mu_TopEdge	; position of the select box
    WORD mu_Width	; dimensions of the select box
    WORD mu_Height	; dimensions of the select box
    WORD mu_Flags	; see flag definitions below
    APTR mu_MenuName	; text for this Menu Header
    APTR  mu_FirstItem	; pointer to first in chain

    ; these mysteriously-named variables are for internal use only
    WORD mu_JazzX
    WORD mu_JazzY
    WORD mu_BeatX
    WORD mu_BeatY

    LABEL mu_SIZEOF

;*** FLAGS SET BY BOTH THE APPLIPROG AND INTUITION ***
MENUENABLED EQU $0001	; whether or not this menu is enabled

;*** FLAGS SET BY INTUITION ***
MIDRAWN EQU $0100	; this menu's items are currently drawn

; ========================================================================;
; === MenuItem ===========================================================;
; ========================================================================;
 STRUCTURE MenuItem,0

    APTR mi_NextItem	; pointer to next in chained list
    WORD mi_LeftEdge	; position of the select box
    WORD mi_TopEdge	; position of the select box
    WORD mi_Width	; dimensions of the select box
    WORD mi_Height	; dimensions of the select box
    WORD mi_Flags	; see the defines below

    LONG mi_MutualExclude ; set bits mean this item excludes that item

    APTR mi_ItemFill	; points to Image, IntuiText, or NULL

    ; when this item is pointed to by the cursor and the items highlight
    ; mode HIGHIMAGE is selected, this alternate image will be displayed
    APTR mi_SelectFill	; points to Image, IntuiText, or NULL

    BYTE mi_Command	; only if appliprog sets the COMMSEQ flag

    BYTE mi_KludgeFill00 ; This is strictly for word-alignment

    APTR mi_SubItem	; if non-zero, DrawMenu shows "->"

   ; The NextSelect field represents the menu number of next selected 
   ; item (when user has drag-selected several items)
    WORD mi_NextSelect

    LABEL  mi_SIZEOF

; --- FLAGS SET BY THE APPLIPROG --------------------------------------------
CHECKIT		EQU $0001	; whether to check this item if selected
ITEMTEXT	EQU $0002	; set if textual, clear if graphical item
COMMSEQ		EQU $0004	; set if there's an command sequence
MENUTOGGLE	EQU $0008	; set to toggle the check of a menu item 
ITEMENABLED	EQU $0010	; set if this item is enabled

; these are the SPECIAL HIGHLIGHT FLAG state meanings 
HIGHFLAGS	EQU $00C0	; see definitions below for these bits
HIGHIMAGE	EQU $0000	; use the user's "select image"
HIGHCOMP	EQU $0040	; highlight by complementing the select box
HIGHBOX		EQU $0080	; highlight by drawing a box around the image
HIGHNONE	EQU $00C0	; don't highlight

; --- FLAGS SET BY BOTH APPLIPROG AND INTUITION -----------------------------
CHECKED		EQU $0100	; if CHECKIT, then set this when selected


; --- FLAGS SET BY INTUITION ------------------------------------------------
ISDRAWN		EQU $1000	; this item's subs are currently drawn
HIGHITEM	EQU $2000	; this item is currently highlighted
MENUTOGGLED	EQU $4000	; this item was already toggled 






; ========================================================================
; === Requester ==========================================================
; ========================================================================
 STRUCTURE Requester,0

    ; the ClipRect and BitMap and used for rendering the requester
    APTR  rq_OlderRequest
    WORD rq_LeftEdge		; dimensions of the entire box
    WORD rq_TopEdge		; dimensions of the entire box
    WORD rq_Width		; dimensions of the entire box
    WORD rq_Height		; dimensions of the entire box

    WORD rq_RelLeft		; get POINTREL Pointer relativity offsets
    WORD rq_RelTop		; get POINTREL Pointer relativity offsets

    APTR  rq_ReqGadget		; pointer to the first of a list of gadgets
    APTR  rq_ReqBorder		; the box's border
    APTR  rq_ReqText		; the box's text

    WORD  rq_Flags		; see definitions below

    UBYTE rq_BackFill		; pen number for back-plane fill before draws

    BYTE rq_KludgeFill00	; This is strictly for word-alignment

    APTR rq_ReqLayer		; layer in which requester rendered
    STRUCT rq_ReqPad1,32	; for backwards compatibility (reserved)

    ; If the BitMap plane pointers are non-zero, this tells the system 
    ; that the image comes pre-drawn (if the appliprog wants to define 
    ; it's own box, in any shape or size it wants!); this is OK by 
    ; Intuition as long as there's a good correspondence between the image 
    ; and the specified Gadgets
    APTR  rq_ImageBMap		; points to the BitMap of PREDRAWN imagery

    APTR  rq_RWindow		; points back to requester's window
    STRUCT rq_ReqPad2,36	; for backwards compatibility (reserved)

    LABEL rq_SIZEOF

; FLAGS SET BY THE APPLIPROG
POINTREL	EQU $0001  ; if POINTREL set, TopLeft is relative to pointer
PREDRAWN	EQU $0002  ; if ReqBMap points to predrawn Requester imagery
NOISYREQ	EQU $0004  ; if you don't want requester to filter input

; FLAGS SET BY INTUITION;
REQOFFWINDOW	EQU $1000	; part of one of the Gadgets was offwindow
REQACTIVE	EQU $2000	; this requester is active
SYSREQUEST	EQU $4000	; this requester caused by system
DEFERREFRESH	EQU $8000	; this Requester stops a Refresh broadcast





; ========================================================================
; === Gadget =============================================================
; ========================================================================
 STRUCTURE Gadget,0

    APTR gg_NextGadget		; next gadget in the list

    WORD gg_LeftEdge		; "hit box" of gadget
    WORD gg_TopEdge		; "hit box" of gadget
    WORD gg_Width		; "hit box" of gadget
    WORD gg_Height		; "hit box" of gadget

    WORD gg_Flags		; see below for list of defines

    WORD gg_Activation		; see below for list of defines

    WORD gg_GadgetType		; see below for defines

    ; appliprog can specify that the Gadget be rendered as either as Border
    ; or an Image.  This variable points to which (or equals NULL if there's
    ; nothing to be rendered about this Gadget)
    APTR gg_GadgetRender

    ; appliprog can specify "highlighted" imagery rather than algorithmic
    ; this can point to either Border or Image data
    APTR gg_SelectRender

    APTR gg_GadgetText		; text for this gadget;

    ; by using the MutualExclude word, the appliprog can describe 
    ; which gadgets mutually-exclude which other ones.	The bits in 
    ; MutualExclude correspond to the gadgets in object containing 
    ; the gadget list.	If this gadget is selected and a bit is set 
    ; in this gadget's MutualExclude and the gadget corresponding to 
    ; that bit is currently selected (e.g. bit 2 set and gadget 2 
    ; is currently selected) that gadget must be unselected.  Intuition 
    ; does the visual unselecting (with checkmarks) and leaves it up 
    ; to the program to unselect internally
    LONG gg_MutualExclude	; set bits mean this gadget excludes that

    ; pointer to a structure of special data required by Proportional, String 
    ; and Integer Gadgets
    APTR gg_SpecialInfo

    WORD gg_GadgetID	; user-definable ID field
    APTR  gg_UserData	; ptr to general purpose User data (ignored by Intuit)

    LABEL gg_SIZEOF

; --- FLAGS SET BY THE APPLIPROG --------------------------------------------
; combinations in these bits describe the highlight technique to be used
GADGHIGHBITS	EQU $0003
GADGHCOMP	EQU $0000	; Complement the select box
GADGHBOX	EQU $0001	; Draw a box around the image
GADGHIMAGE	EQU $0002	; Blast in this alternate image
GADGHNONE	EQU $0003	; don't highlight

; set this flag if the GadgetRender and SelectRender point to Image imagery, 
; clear if it's a Border 
GADGIMAGE	EQU $0004 

; combinations in these next two bits specify to which corner the gadget's
; Left & Top coordinates are relative.	If relative to Top/Left,
; these are "normal" coordinates (everything is relative to something in
; this universe)
GRELBOTTOM	EQU $0008	; set if rel to bottom, clear if rel top
GRELRIGHT	EQU $0010	; set if rel to right, clear if to left
; set the RELWIDTH bit to spec that Width is relative to width of screen
GRELWIDTH	EQU $0020
; set the RELHEIGHT bit to spec that Height is rel to height of screen
GRELHEIGHT	EQU $0040

; the SELECTED flag is initialized by you and set by Intuition.	 It 
; specifies whether or not this Gadget is currently selected/highlighted
SELECTED	EQU $0080


; the GADGDISABLED flag is initialized by you and later set by Intuition
; according to your calls to On/OffGadget().  It specifies whether or not 
; this Gadget is currently disabled from being selected
GADGDISABLED	EQU $0100


; --- These are the Activation flag bits ----------------------------------
; RELVERIFY is set if you want to verify that the pointer was still over
; the gadget when the select button was released
RELVERIFY	EQU $0001

; the flag GADGIMMEDIATE, when set, informs the caller that the gadget
; was activated when it was activated.	this flag works in conjunction with
; the RELVERIFY flag
GADGIMMEDIATE	EQU $0002

; the flag ENDGADGET, when set, tells the system that this gadget, when
; selected, causes the Requester or AbsMessage to be ended.  Requesters or
; AbsMessages that are ended are erased and unlinked from the system
ENDGADGET	EQU $0004

; the FOLLOWMOUSE flag, when set, specifies that you want to receive
; reports on mouse movements (ie, you want the REPORTMOUSE function for
; your Window).	 When the Gadget is deselected (immediately if you have
; no RELVERIFY) the previous state of the REPORTMOUSE flag is restored
; You probably want to set the GADGIMMEDIATE flag when using FOLLOWMOUSE,
; since that's the only reasonable way you have of learning why Intuition
; is suddenly sending you a stream of mouse movement events.  If you don't
; set RELVERIFY, you'll get at least one Mouse Position event.
FOLLOWMOUSE	EQU $0008

; if any of the BORDER flags are set in a Gadget that"s included in the
; Gadget list when a Window is opened, the corresponding Border will
; be adjusted to make room for the Gadget
RIGHTBORDER	EQU $0010
LEFTBORDER	EQU $0020
TOPBORDER	EQU $0040
BOTTOMBORDER	EQU $0080

TOGGLESELECT	EQU $0100	; this bit for toggle-select mode

STRINGCENTER	EQU $0200	; center the String
STRINGRIGHT	EQU $0400	; right-justify the String

LONGINT		EQU $0800	; This String Gadget is a Long Integer

ALTKEYMAP	EQU $1000	; This String has an alternate keymapping

BOOLEXTEND	EQU $2000	; This Boolean Gadget has a BoolInfo

; --- GADGET TYPES -----------------------------------------------------------
; These are the Gaget Type definitions for the variable GadgetType.
; Gadget number type MUST start from one.  NO TYPES OF ZERO ALLOWED.
; first comes the mask for Gadget flags reserved for Gadget typing
GADGETTYPE	EQU $FC00	; all Gadget Global Type flags (padded)
SYSGADGET	EQU $8000	; 1 = SysGadget, 0 = AppliGadget
SCRGADGET	EQU $4000	; 1 = ScreenGadget, 0 = WindowGadget
GZZGADGET	EQU $2000	; 1 = Gadget for GIMMEZEROZERO borders
REQGADGET	EQU $1000	; 1 = this is a Requester Gadget
; system gadgets
SIZING		EQU $0010
WDRAGGING	EQU $0020
SDRAGGING	EQU $0030
WUPFRONT	EQU $0040
SUPFRONT	EQU $0050
WDOWNBACK	EQU $0060
SDOWNBACK	EQU $0070
CLOSE		EQU $0080
; application gadgets
BOOLGADGET	EQU $0001
GADGET0002	EQU $0002
PROPGADGET	EQU $0003
STRGADGET	EQU $0004



; ======================================================================== 
; === BoolInfo============================================================
; ======================================================================== 
; This is the special data needed by an Extended Boolean Gadget
; Typically this structure will be pointed to by the Gadget field SpecialInfo

 STRUCTURE BoolInfo,0

    WORD    bi_Flags	; defined below 
    APTR    bi_Mask	; bit mask for highlighting and selecting
			; mask must follow the same rules as an Image
			; plane.  It's width and height are determined
			; by the width and height of the gadget's 
			; select box. (i.e. Gadget.Width and .Height).
    LONG    bi_Reserved ; set to 0

    LABEL   bi_SIZEOF

; set BoolInfo.Flags to this flag bit.
; in the future, additional bits might mean more stuff hanging
; off of BoolInfo.Reserved.

BOOLMASK	EQU	$0001	; extension is for masked gadget

; ========================================================================
; === PropInfo ===========================================================
; ========================================================================
; this is the special data required by the proportional Gadget
; typically, this data will be pointed to by the Gadget variable SpecialInfo
 STRUCTURE PropInfo,0

    WORD pi_Flags	; general purpose flag bits (see defines below)

    ; You initialize the Pot variables before the Gadget is added to 
    ; the system.  Then you can look here for the current settings 
    ; any time, even while User is playing with this Gadget.  To 
    ; adjust these after the Gadget is added to the System, use 
    ; ModifyProp(); The Pots are the actual proportional settings, 
    ; where a value of zero means zero and a value of MAXPOT means 
    ; that the Gadget is set to its maximum setting.
    WORD pi_HorizPot	; 16-bit FixedPoint horizontal quantity percentage;
    WORD pi_VertPot	; 16-bit FixedPoint vertical quantity percentage;

    ; the 16-bit FixedPoint Body variables describe what percentage 
    ; of the entire body of stuff referred to by this Gadget is 
    ; actually shown at one time.  This is used with the AUTOKNOB 
    ; routines, to adjust the size of the AUTOKNOB according to how 
    ; much of the data can be seen.  This is also used to decide how 
    ; far to advance the Pots when User hits the Container of the Gadget.  
    ; For instance, if you were controlling the display of a 5-line 
    ; Window of text with this Gadget, and there was a total of 15 
    ; lines that could be displayed, you would set the VertBody value to 
    ;	 (MAXBODY / (TotalLines / DisplayLines)) = MAXBODY / 3.
    ; Therefore, the AUTOKNOB would fill 1/3 of the container, and if 
    ; User hits the Cotainer outside of the knob, the pot would advance 
    ; 1/3 (plus or minus) If there's no body to show, or the total 
    ; amount of displayable info is less than the display area, set the 
    ; Body variables to the MAX.  To adjust these after the Gadget is 
    ; added to the System, use ModifyProp().
    WORD pi_HorizBody	; horizontal Body
    WORD pi_VertBody	; vertical Body

    ; these are the variables that Intuition sets and maintains
    WORD pi_CWidth	; Container width (with any relativity absoluted)
    WORD pi_CHeight	; Container height (with any relativity absoluted)
    WORD pi_HPotRes	; pot increments
    WORD pi_VPotRes	; pot increments
    WORD pi_LeftBorder	; Container borders
    WORD pi_TopBorder	; Container borders
    LABEL  pi_SIZEOF

; --- FLAG BITS --------------------------------------------------------------
AUTOKNOB	EQU $0001	; this flag sez:  gimme that old auto-knob
FREEHORIZ	EQU $0002	; if set, the knob can move horizontally
FREEVERT	EQU $0004	; if set, the knob can move vertically
PROPBORDERLESS	EQU $0008	; if set, no border will be rendered
KNOBHIT		EQU $0100	; set when this Knob is hit


KNOBHMIN	EQU 6		; minimum horizontal size of the knob
KNOBVMIN	EQU 4		; minimum vertical size of the knob
MAXBODY		EQU $FFFF	; maximum body value
MAXPOT		EQU $FFFF	; maximum pot value


; ========================================================================
; === StringInfo =========================================================
; ========================================================================
; this is the special data required by the string Gadget
; typically, this data will be pointed to by the Gadget variable SpecialInfo
 STRUCTURE StringInfo,0

    ; you initialize these variables, and then Intuition maintains them
    APTR  si_Buffer	; the buffer containing the start and final string
    APTR  si_UndoBuffer ; optional buffer for undoing current entry
    WORD si_BufferPos	; character position in Buffer
    WORD si_MaxChars	; max number of chars in Buffer (including NULL)
    WORD si_DispPos	; Buffer position of first displayed character

    ; Intuition initializes and maintains these variables for you
    WORD si_UndoPos	; character position in the undo buffer
    WORD si_NumChars	; number of characters currently in Buffer
    WORD si_DispCount	; number of whole characters visible in Container
    WORD si_CLeft	; topleft offset of the container
    WORD si_CTop	; topleft offset of the container
    APTR  si_LayerPtr	; the RastPort containing this Gadget

    ; you can initialize this variable before the gadget is submitted to
    ; Intuition, and then examine it later to discover what integer 
    ; the user has entered (if the user never plays with the gadget, 
    ; the value will be unchanged from your initial setting)
    LONG  si_LongInt	; the LONG return value of a LONGINT String Gadget

    ; If you want this Gadget to use your own Console keymapping, you
    ; set the ALTKEYMAP bit in the Activation flags of the Gadget, and then
    ; set this variable to point to your keymap.  If you don't set the
    ; ALTKEYMAP, you'll get the standard ASCII keymapping.
    APTR si_AltKeyMap

    LABEL si_SIZEOF




; ========================================================================
; === IntuiText ==========================================================
; ========================================================================
; IntuiText is a series of strings that start with a screen location
; (always relative to the upper-left corner of something) and then the
; text of the string.  The text is null-terminated.
 STRUCTURE IntuiText,0

    BYTE it_FrontPen		; the pens for rendering the text
    BYTE it_BackPen		; the pens for rendering the text

    BYTE it_DrawMode		; the mode for rendering the text

    BYTE it_KludgeFill00	; This is strictly for word-alignment 

    WORD it_LeftEdge		; relative start location for the text
    WORD it_TopEdge		; relative start location for the text

    APTR  it_ITextFont		; if NULL, you accept the defaults

    APTR it_IText		; pointer to null-terminated text

    APTR  it_NextText		; continuation to TxWrite another text

    LABEL it_SIZEOF





; ========================================================================
; === Border =============================================================
; ========================================================================
; Data type Border, used for drawing a series of lines which is intended for
; use as a border drawing, but which may, in fact, be used to render any
; arbitrary vector shape.
; The routine DrawBorder sets up the RastPort with the appropriate
; variables, then does a Move to the first coordinate, then does Draws
; to the subsequent coordinates.
; After all the Draws are done, if NextBorder is non-zero we call DrawBorder
; recursively
 STRUCTURE Border,0

    WORD  bd_LeftEdge		; initial offsets from the origin
    WORD  bd_TopEdge		; initial offsets from the origin
    BYTE  bd_FrontPen		; pen number for rendering 
    BYTE  bd_BackPen		; pen number for rendering 
    BYTE  bd_DrawMode		; mode for rendering 
    BYTE  bd_Count		; number of XY pairs
    APTR  bd_XY			; vector coordinate pairs rel to LeftTop
    APTR  bd_NextBorder		; pointer to any other Border too

    LABEL bd_SIZEOF


; ======================================================================== 
; === Image ============================================================== 
; ======================================================================== 
; This is a brief image structure for very simple transfers of 
; image data to a RastPort
 STRUCTURE Image,0

    WORD ig_LeftEdge		; starting offset relative to something 
    WORD ig_TopEdge		; starting offset relative to something 
    WORD ig_Width		; pixel size (though data is word-aligned)
    WORD ig_Height		; pixel size 
    WORD ig_Depth		; pixel size 
    APTR ig_ImageData		; pointer to the actual image bits

    ; the PlanePick and PlaneOnOff variables work much the same way as the
    ; equivalent GELS Bob variables.  It's a space-saving 
    ; mechanism for image data.	 Rather than defining the image data
    ; for every plane of the RastPort, you need define data only for planes 
    ; that are not entirely zero or one.  As you define your Imagery, you will
    ; often find that most of the planes ARE just as color selectors.  For
    ; instance, if you're designing a two-color Gadget to use colors two and
    ; three, and the Gadget will reside in a five-plane display, plane zero
    ; of your imagery would be all ones, bit plane one would have data that
    ; describes the imagery, and bit planes two through four would be
    ; all zeroes.  Using these flags allows you to avoid wasting all that 
    ; memory in this way:  
    ; first, you specify which planes you want your data to appear 
    ; in using the PlanePick variable.	For each bit set in the variable, the 
    ; next "plane" of your image data is blitted to the display.  For each bit
    ; clear in this variable, the corresponding bit in PlaneOnOff is examined.
    ; If that bit is clear, a "plane" of zeroes will be used.  If the bit is 
    ; set, ones will go out instead.  So, for our example:
    ;	Gadget.PlanePick = 0x02;
    ;	Gadget.PlaneOnOff = 0x01;
    ; Note that this also allows for generic Gadgets, like the System Gadgets,
    ; which will work in any number of bit planes
    ; Note also that if you want an Image that is only a filled rectangle,
    ; you can get this by setting PlanePick to zero (pick no planes of data)
    ; and set PlaneOnOff to describe the pen color of the rectangle.
    BYTE ig_PlanePick
    BYTE ig_PlaneOnOff

    ; if the NextImage variable is not NULL, Intuition presumes that 
    ; it points to another Image structure with another Image to be 
    ; rendered
    APTR ig_NextImage


    LABEL ig_SIZEOF




; ======================================================================== 
; === IntuiMessage ======================================================= 
; ======================================================================== 
 STRUCTURE IntuiMessage,0

    STRUCT im_ExecMessage,MN_SIZE

    ; the Class bits correspond directly with the IDCMP Flags, except for the
    ; special bit LONELYMESSAGE (defined below)
    LONG im_Class

    ; the Code field is for special values like MENU number 
    WORD im_Code

    ; the Qualifier field is a copy of the current InputEvent's Qualifier 
    WORD im_Qualifier

    ; IAddress contains particular addresses for Intuition functions, like
    ; the pointer to the Gadget or the Screen
    APTR im_IAddress

    ; when getting mouse movement reports, any event you get will have the
    ; the mouse coordinates in these variables.	 the coordinates are relative
    ; to the upper-left corner of your Window (GIMMEZEROZERO notwithstanding)
    WORD im_MouseX
    WORD im_MouseY

    ; the time values are copies of the current system clock time.  Micros
    ; are in units of microseconds, Seconds in seconds.
    LONG im_Seconds
    LONG im_Micros

    ; the IDCMPWindow variable will always have the address of the Window of 
    ; this IDCMP 
    APTR im_IDCMPWindow

    ; system-use variable 
    APTR im_SpecialLink

    LABEL  im_SIZEOF



; --- IDCMP Classes ------------------------------------------------------ 
SIZEVERIFY	EQU	$00000001	; See the Programmer's Guide
NEWSIZE		EQU	$00000002	; See the Programmer's Guide
REFRESHWINDOW	EQU	$00000004	; See the Programmer's Guide
MOUSEBUTTONS	EQU	$00000008	; See the Programmer's Guide
MOUSEMOVE	EQU	$00000010	; See the Programmer's Guide 
GADGETDOWN	EQU	$00000020	; See the Programmer's Guide
GADGETUP	EQU	$00000040	; See the Programmer's Guide 
REQSET		EQU	$00000080	; See the Programmer's Guide
MENUPICK	EQU	$00000100	; See the Programmer's Guide 
CLOSEWINDOW	EQU	$00000200	; See the Programmer's Guide
RAWKEY		EQU	$00000400	; See the Programmer's Guide 
REQVERIFY	EQU	$00000800	; See the Programmer's Guide
REQCLEAR	EQU	$00001000	; See the Programmer's Guide 
MENUVERIFY	EQU	$00002000	; See the Programmer's Guide
NEWPREFS	EQU	$00004000	; See the Programmer's Guide 
DISKINSERTED	EQU	$00008000	; See the Programmer's Guide
DISKREMOVED	EQU	$00010000	; See the Programmer's Guide 
WBENCHMESSAGE	EQU	$00020000	; See the Programmer's Guide
ACTIVEWINDOW	EQU	$00040000	; See the Programmer's Guide
INACTIVEWINDOW	EQU	$00080000	; See the Programmer's Guide
DELTAMOVE	EQU	$00100000	; See the Programmer's Guide
VANILLAKEY	EQU	$00200000	; See the Programmer's Guide
INTUITICKS	EQU	$00400000	; See the Programmer's Guide
; NOTEZ-BIEN:		$80000000 is reserved for internal use by IDCMP

; the IDCMP Flags do not use this special bit, which is cleared when
; Intuition sends its special message to the Task, and set when Intuition
; gets its Message back from the Task.	Therefore, I can check here to
; find out fast whether or not this Message is available for me to send
LONELYMESSAGE	EQU	$80000000



; --- IDCMP Codes -------------------------------------------------------- 
; This group of codes is for the MENUVERIFY function 
MENUHOT		EQU	$0001	; IntuiWants verification or MENUCANCEL	   
MENUCANCEL	EQU	$0002	; HOT Reply of this cancels Menu operation 
MENUWAITING	EQU	$0003	; Intuition simply wants a ReplyMsg() ASAP 

; These are internal tokens to represent state of verification attempts
; shown here as a clue.
OKOK		EQU	MENUHOT		; guy didn't care
OKABORT		EQU	$0004		; window rendered question moot
OKCANCEL	EQU	MENUCANCEL	; window sent cancel reply

; This group of codes is for the WBENCHMESSAGE messages
WBENCHOPEN	EQU $0001
WBENCHCLOSE	EQU $0002




; ======================================================================== 
; === Window ============================================================= 
; ======================================================================== 
 STRUCTURE Window,0

    APTR wd_NextWindow		; for the linked list of a Screen

    WORD wd_LeftEdge		; screen dimensions
    WORD wd_TopEdge		; screen dimensions
    WORD wd_Width		; screen dimensions
    WORD wd_Height		; screen dimensions

    WORD wd_MouseY		; relative top top-left corner 
    WORD wd_MouseX		; relative top top-left corner 

    WORD wd_MinWidth		; minimum sizes
    WORD wd_MinHeight		; minimum sizes
    WORD wd_MaxWidth		; maximum sizes
    WORD wd_MaxHeight		; maximum sizes

    LONG wd_Flags		; see below for definitions

    APTR wd_MenuStrip		; first in a list of menu headers

    APTR wd_Title		; title text for the Window

    APTR wd_FirstRequest	; first in linked list of active Requesters 
    APTR wd_DMRequest		; the double-menu Requester 
    WORD wd_ReqCount		; number of Requesters blocking this Window
    APTR wd_WScreen		; this Window's Screen
    APTR wd_RPort		; this Window's very own RastPort

    ; the border variables describe the window border.	If you specify
    ; GIMMEZEROZERO when you open the window, then the upper-left of the
    ; ClipRect for this window will be upper-left of the BitMap (with correct
    ; offsets when in SuperBitMap mode; you MUST select GIMMEZEROZERO when
    ; using SuperBitMap).  If you don't specify ZeroZero, then you save
    ; memory (no allocation of RastPort, Layer, ClipRect and associated
    ; Bitmaps), but you also must offset all your writes by BorderTop,
    ; BorderLeft and do your own mini-clipping to prevent writing over the
    ; system gadgets
    BYTE wd_BorderLeft
    BYTE wd_BorderTop
    BYTE wd_BorderRight
    BYTE wd_BorderBottom
    APTR wd_BorderRPort

    ; You supply a linked-list of gadget that you want for your Window.
    ; This list DOES NOT include system Gadgets.  You get the standard
    ; window system Gadgets by setting flag-bits in the variable Flags (see
    ; the bit definitions below)
    APTR wd_FirstGadget

    ; these are for opening/closing the windows 
    APTR wd_Parent
    APTR wd_Descendant

    ; sprite data information for your own Pointer
    ; set these AFTER you Open the Window by calling SetPointer()
    APTR wd_Pointer
    BYTE wd_PtrHeight
    BYTE wd_PtrWidth
    BYTE wd_XOffset
    BYTE wd_YOffset

    ; the IDCMP Flags and User's and Intuition's Message Ports 
    ULONG wd_IDCMPFlags
    APTR wd_UserPort
    APTR wd_WindowPort
    APTR wd_MessageKey

    BYTE wd_DetailPen
    BYTE wd_BlockPen

    ; the CheckMark is a pointer to the imagery that will be used when 
    ; rendering MenuItems of this Window that want to be checkmarked
    ; if this is equal to NULL, you'll get the default imagery
    APTR wd_CheckMark

    ; if non-null, Screen title when Window is active 
    APTR wd_ScreenTitle

    ; These variables have the mouse coordinates relative to the 
    ; inner-Window of GIMMEZEROZERO Windows.  This is compared with the
    ; MouseX and MouseY variables, which contain the mouse coordinates
    ; relative to the upper-left corner of the Window, GIMMEZEROZERO
    ; notwithstanding
    WORD wd_GZZMouseX
    WORD wd_GZZMouseY
    ; these variables contain the width and height of the inner-Window of
    ; GIMMEZEROZERO Windows
    WORD wd_GZZWidth
    WORD wd_GZZHeight

    APTR wd_ExtData

    ; general-purpose pointer to User data extension 
    APTR wd_UserData
    APTR wd_WLayer	; stash of Window.RPort->Layer

    ; NEW 1.2: need to keep track of the font that OpenWindow opened,
    ; in case user SetFont's into RastPort
    APTR IFont

    LABEL wd_Size

; --- FLAGS REQUESTED (NOT DIRECTLY SET THOUGH) BY THE APPLIPROG -------------
WINDOWSIZING	EQU $0001	; include sizing system-gadget? 
WINDOWDRAG	EQU $0002	; include dragging system-gadget? 
WINDOWDEPTH	EQU $0004	; include depth arrangement gadget? 
WINDOWCLOSE	EQU $0008	; include close-box system-gadget? 

SIZEBRIGHT	EQU $0010	; size gadget uses right border 
SIZEBBOTTOM	EQU $0020	; size gadget uses bottom border 

; --- refresh modes ----------------------------------------------------------
; combinations of the REFRESHBITS select the refresh type 
REFRESHBITS	EQU $00C0
SMART_REFRESH	EQU $0000
SIMPLE_REFRESH	EQU $0040
SUPER_BITMAP	EQU $0080
OTHER_REFRESH	EQU $00C0

BACKDROP	EQU $0100	; this is an ever-popular BACKDROP window 

REPORTMOUSE	EQU $0200	; set this to hear about every mouse move 

GIMMEZEROZERO	EQU $0400	; make extra border stuff 

BORDERLESS	EQU $0800	; set this to get a Window sans border 

ACTIVATE	EQU $1000	; when Window opens, it's the Active one 

; FLAGS SET BY INTUITION 
WINDOWACTIVE	EQU $2000	; this window is the active one 
INREQUEST	EQU $4000	; this window is in request mode 
MENUSTATE	EQU $8000	; this Window is active with its Menus on 

; --- Other User Flags -------------------------------------------------------
RMBTRAP		EQU $00010000	; Catch RMB events for your own 
NOCAREREFRESH	EQU $00020000	; not to be bothered with REFRESH

; --- Other Intuition Flags ----------------------------------------------
WINDOWREFRESH	EQU $01000000	; Window is currently refreshing
WBENCHWINDOW	EQU $02000000	; WorkBench Window
WINDOWTICKED	EQU $04000000	; only one timer tick at a time

SUPER_UNUSED	EQU $FCFC0000	;bits of Flag unused yet


; --- see struct IntuiMessage for the IDCMP Flag definitions -----------------


; ======================================================================== 
; === NewWindow ========================================================== 
; ======================================================================== 
 STRUCTURE NewWindow,0

    WORD nw_LeftEdge		; initial Window dimensions
    WORD nw_TopEdge		; initial Window dimensions
    WORD nw_Width		; initial Window dimensions
    WORD nw_Height		; initial Window dimensions

    BYTE nw_DetailPen		; for rendering the detail bits of the Window
    BYTE nw_BlockPen		; for rendering the block-fill bits 

    LONG nw_IDCMPFlags		; initial IDCMP state

    LONG nw_Flags		; see the Flag definition under Window

    ; You supply a linked-list of Gadgets for your Window.
    ; This list DOES NOT include system Gadgets.  You get the standard
    ; system Window Gadgets by setting flag-bits in the variable Flags (see
    ; the bit definitions under the Window structure definition)
    APTR	nw_FirstGadget

    ; the CheckMark is a pointer to the imagery that will be used when 
    ; rendering MenuItems of this Window that want to be checkmarked
    ; if this is equal to NULL, you'll get the default imagery
    APTR nw_CheckMark

    APTR nw_Title		; title text for the Window
    
    ; the Screen pointer is used only if you've defined a CUSTOMSCREEN and
    ; want this Window to open in it.  If so, you pass the address of the
    ; Custom Screen structure in this variable.	 Otherwise, this variable
    ; is ignored and doesn't have to be initialized.
    APTR nw_Screen
    
    ; SUPER_BITMAP Window?  If so, put the address of your BitMap structure
    ; in this variable.	 If not, this variable is ignored and doesn't have 
    ; to be initialized
    APTR nw_BitMap

    ; the values describe the minimum and maximum sizes of your Windows.
    ; these matter only if you've chosen the WINDOWSIZING Gadget option,
    ; which means that you want to let the User to change the size of 
    ; this Window.  You describe the minimum and maximum sizes that the
    ; Window can grow by setting these variables.  You can initialize
    ; any one these to zero, which will mean that you want to duplicate
    ; the setting for that dimension (if MinWidth == 0, MinWidth will be
    ; set to the opening Width of the Window).
    ; You can change these settings later using SetWindowLimits().
    ; If you haven't asked for a SIZING Gadget, you don't have to
    ; initialize any of these variables.
    WORD nw_MinWidth
    WORD nw_MinHeight
    WORD nw_MaxWidth
    WORD nw_MaxHeight

    ; the type variable describes the Screen in which you want this Window to
    ; open.  The type value can either be CUSTOMSCREEN or one of the
    ; system standard Screen Types such as WBENCHSCREEN.  See the
    ; type definitions under the Screen structure
    WORD nw_Type

    LABEL nw_SIZE


	IFND INTUITION_SCREENS_I
	INCLUDE "intuition/screens.i"
	ENDC

	IFND INTUITION_PREFERENCES_I
	INCLUDE "intuition/preferences.i"
	ENDC

; ========================================================================
; === Remember ===========================================================
; ========================================================================
; this structure is used for remembering what memory has been allocated to
; date by a given routine, so that a premature abort or systematic exit
; can deallocate memory cleanly, easily, and completely
 STRUCTURE Remember,0

    APTR rm_NextRemember
    LONG rm_RememberSize
    APTR rm_Memory

 LABEL	  rm_SIZEOF



; ======================================================================== 
; === Miscellaneous ====================================================== 
; ======================================================================== 

; = MACROS ============================================================== 
;#define MENUNUM(n) (n & 0x1F)
;#define ITEMNUM(n) ((n >> 5) & 0x003F)
;#define SUBNUM(n) ((n >> 11) & 0x001F)
;
;#define SHIFTMENU(n) (n & 0x1F)
;#define SHIFTITEM(n) ((n & 0x3F) << 5)
;#define SHIFTSUB(n) ((n & 0x1F) << 11)
;
;#define SRBNUM(n)  (0x08 - (n >> 4))  /* SerRWBits -> read bits per char */
;#define SWBNUM(n)  (0x08 - (n & 0x0F))/* SerRWBits -> write bits per chr */
;#define SSBNUM(n)  (0x01 + (n >> 4))  /* SerStopBuf -> stop bits per chr */
;#define SPARNUM(n) (n >> 4)	       /* SerParShk -> parity setting	 */
;#define SHAKNUM(n) (n & 0x0F)	       /* SerParShk -> handshake mode	 */
;
; = MENU STUFF =========================================================== 
NOMENU EQU	$001F
NOITEM EQU	$003F
NOSUB  EQU	$001F
MENUNULL EQU	$FFFF


; = =RJ='s peculiarities ================================================= 
;#define FOREVER for(;;)
;#define SIGN(x) ( ((x) > 0) - ((x) < 0) )


; these defines are for the COMMSEQ and CHECKIT menu stuff.  If CHECKIT,
; I'll use a generic Width (for all resolutions) for the CheckMark.
; If COMMSEQ, likewise I'll use this generic stuff
CHECKWIDTH	EQU	19
COMMWIDTH	EQU	27
LOWCHECKWIDTH	EQU	13
LOWCOMMWIDTH	EQU	16


; these are the AlertNumber defines.  if you are calling DisplayAlert()
; the AlertNumber you supply must have the ALERT_TYPE bits set to one
; of these patterns
ALERT_TYPE	EQU	$80000000
RECOVERY_ALERT	EQU	$00000000	; the system can recover from this 
DEADEND_ALERT	EQU	$80000000	; no recovery possible, this is it 


; When you're defining IntuiText for the Positive and Negative Gadgets 
; created by a call to AutoRequest(), these defines will get you 
; reasonable-looking text.  The only field without a define is the IText
; field; you decide what text goes with the Gadget
AUTOFRONTPEN	EQU	0
AUTOBACKPEN	EQU	1
AUTODRAWMODE	EQU	RP_JAM2
AUTOLEFTEDGE	EQU	6
AUTOTOPEDGE	EQU	3
AUTOITEXTFONT	EQU	0
AUTONEXTTEXT	EQU	0



;* --- RAWMOUSE Codes and Qualifiers (Console OR IDCMP) -------------------
SELECTUP	EQU	(IECODE_LBUTTON+IECODE_UP_PREFIX)
SELECTDOWN	EQU	(IECODE_LBUTTON)
MENUUP		EQU	(IECODE_RBUTTON+IECODE_UP_PREFIX)
MENUDOWN	EQU	(IECODE_RBUTTON)
ALTLEFT		EQU	(IEQUALIFIER_LALT)
ALTRIGHT	EQU	(IEQUALIFIER_RALT)
AMIGALEFT	EQU	(IEQUALIFIER_LCOMMAND)
AMIGARIGHT	EQU	(IEQUALIFIER_RCOMMAND)
AMIGAKEYS	EQU	(AMIGALEFT+AMIGARIGHT)
			
CURSORUP	EQU	$4C
CURSORLEFT	EQU	$4F
CURSORRIGHT	EQU	$4E
CURSORDOWN	EQU	$4D
KEYCODE_Q	EQU	$10
KEYCODE_X	EQU	$32
KEYCODE_N	EQU	$36
KEYCODE_M	EQU	$37
KEYCODE_V	EQU	$34
KEYCODE_B	EQU	$35

	IFND	INTUITION_INTUITIONBASE_I
	include "intuition/intuitionbase.i"
	ENDC

	ENDC	; INTUITION_INTUITION_I
