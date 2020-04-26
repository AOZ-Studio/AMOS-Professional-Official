;EXTASM: I
	include "exec/nodes.i"
	include "exec/lists.i"
	include "exec/ports.i"
	include "exec/io.i"
	include "exec/memory.i"
	include "devices/inputevent.i"
	include "graphics/gfx.i"
	include "graphics/gfxbase.i"
	include "graphics/rastport.i"
	include "graphics/text.i"
	include "graphics/view.i"
	include "intuition/intuition.i"
	include "libraries/reqtools.i"
;EXTASM: i

io_sizeof	equ	io_size
mp_sizeof	equ	mp_size
ie_sizeof	equ	ie_SIZEOF
tr_sizeof	equ	tr_SIZEOF
ens_sizeof	equ	ens_SIZEOF
nw_sizeof	equ	nw_SIZEOF
ta_sizeof	equ	ta_SIZEOF
bm_sizeof	equ	bm_SIZEOF
;Define some extra fields at the ends of structures
mu_MenuNum	equ	mu_SIZEOF
mu_sizeof	equ	mu_SIZEOF+2
mi_ItemNum	equ	mi_SIZEOF
mi_IsSubitem	equ	mi_SIZEOF+2	;TRUE if item is a subitem
mi_Parent	equ	mi_SIZEOF+4	;Item's parent menu/item
mi_sizeof	equ	mi_SIZEOF+8
gg_sizeof	equ	gg_SIZEOF
si_sizeof	equ	si_SIZEOF
pi_sizeof	equ	pi_SIZEOF
it_sizeof	equ	it_SIZEOF
bd_sizeof	equ	bd_SIZEOF
rp_sizeof	equ	rp_SIZEOF

ExtNum	equ 14
Null	equ $80000000	;what AMOS passes if a parameter is omitted

DataVer		equ 0	;Should change to reflect branch table changes


;Constants affecting assembly
;SAFE_GRPOS	equ 1	;Don't allow Igr Locate etc. outside window
;FAST_WRITEPIXEL equ 1	;Use internal L_WritePixel instead of
			;  graphics.library WritePixel()
LIMIT_32K	equ 1	;Serious AMOS bug - extensions limited to 32k
;MEMF_CLEAR_BUG	equ 1	;Possible bug in AllocMem()/MEMF_CLEAR - see
			;  L_AllocMemClear


;Keyboard, menu events
	RsReset
ke_code		rs.b 1
ke_qual		rs.b 1
ke_char		rs.b 1
;ke_sizeof	equ __RS
ke_sizeof	rs.b 0

	RsReset
ue_menupick	rs.w 1
;ue_sizeof	equ __RS
ue_sizeof	rs.b 0


;Window structure extension
	RsReset
we_NextIwin	rs.l 1
we_PrevIwin	rs.l 1
we_MagicID	rs.l 1	;Structure identifier (see WE_MAGIC below)
we_WinNum	rs.l 1
we_Flags	rs.l 1
we_FirstMenu	rs.l 1
we_NGadgets	rs.w 1
we_Gadgets	rs.l 1	;Gadget space for Reserve Igadget
we_GadgetSize	rs.l 1	;sizeof(*we_Gadgets)
we_GBorders	rs.l 1	;Gadget Borders
we_GBorderSize	rs.l 1	;sizeof(*we_GBorders)
we_HilitePen	rs.b 1	;Pens for borders
we_ShadowPen	rs.b 1
we_sizeof	equ __RS

WE_MAGIC	equ $BEADF00D

WEB_DUBOIS	equ -1	;Wasn't he some famous guy we learned about in U.S.
			;  History? :-)
WEB_UNSET	equ 0	;Drawing coordinates not set
WEB_CLOSED	equ 1	;Window's close gadget was pressed
WEB_BASEWIN	equ 2	;Window is some screen's base window
WEB_MENUACTIVE	equ 3	;Window has an active menu strip

WEF_UNSET	equ (1<<0)
WEF_CLOSED	equ (1<<1)
WEF_BASEWIN	equ (1<<2)
WEF_MENUACTIVE	equ (1<<3)


;Screen structure extension
	RsReset
se_NextIscr	rs.l 1
se_PrevIscr	rs.l 1
se_ScrNum	rs.l 1
se_BaseWin	rs.l 1	;Base window pointer
se_Width	rs.w 1	;Screen width/height from Iscreen Open (their partners
se_Height	rs.w 1	;  in the Screen structure can be changed by Iscreen
			;  Display)
se_FirstIwindow	rs.l 1
se_LastActive	rs.l 1	;Last active window (saved/restored when current
			;  screen is changed)
se_Flags	rs.l 1
se_Dripens	rs.w NUMDRIPENS	;On screen open, just a -1.  Afterwards,
				;  filled with dripens from
				;  GetScreenDrawInfo().
se_sizeof	equ __RS

SEB_HIDDEN	equ 0

SEF_HIDDEN	equ (1<<0)


;Gadget structure extension
	RsReset
ge_MagicID	rs.l 1	;Identifier
ge_Flags	rs.l 1
ge_NUnits	rs.l 1	;Sliders only
ge_KnobSize	rs.l 1	;Sliders only
ge_HitCount	rs.w 1	;Hit-select gadgets only
ge_sizeof	equ __RS

GADGET_MAGIC	equ $BADF00D

GEB_DISPLAYED	equ 0
GEB_VSLIDER	equ 1	;Sliders only; 1=vertical, 0=horizontal
GEB_GADGETDOWN	equ 2	;Gadget is currently depressed

GEF_DISPLAYED	equ (1<<0)
GEF_VSLIDER	equ (1<<1)
GEF_GADGETDOWN	equ (1<<2)


;Screen mode data (used with Irequest Screen)
	RsReset
sd_Width	rs.w 1
sd_Height	rs.w 1
sd_NumCols	rs.l 1
sd_DisplayID	rs.l 1
sd_ViewModes	rs.w 1
sd_sizeof	equ __RS


;RSControl structure, for use with ReturnString and GetRetStr.  Currently
;empty, but kept in case we find a use for it.
	RsReset
rsc_sizeof	equ __RS


;Our own structure offsets
sc_ViewModes	equ	sc_ViewPort+vp_Modes
sc_Depth	equ	sc_BitMap+bm_Depth

;Screen mode constants not defined elsewhere
HIRES		equ	$8000
HAM		equ	$0800
EHB		equ	$0080
SUPERHIRES	equ	$0020
LACED		equ	$0004
;Screen modes supported
MODES		equ	HIRES | HAM | EHB | SUPERHIRES | LACED

;Default window flags
WFLAGS		set	WFLG_SIZEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET
WFLAGS		set	WFLAGS | WFLG_CLOSEGADGET | WFLG_ACTIVATE
WFLAGS		set	WFLAGS | WFLG_RMBTRAP
;Minimum window flags (if the user specifies some)
MINWFLAGS	equ	WFLG_RMBTRAP
;Flags that the user can specify
USERWFLAGS	set	WFLG_SIZEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET
USERWFLAGS	set	USERWFLAGS | WFLG_CLOSEGADGET | WFLG_SIZEBRIGHT
USERWFLAGS	set	USERWFLAGS | WFLG_SIZEBBOTTOM | WFLG_BACKDROP
USERWFLAGS	set	USERWFLAGS | WFLG_BORDERLESS | WFLG_ACTIVATE

;Default window IDCMP flags
IDCMPFLAGS	set	IDCMP_RAWKEY | IDCMP_MOUSEBUTTONS
IDCMPFLAGS	set	IDCMPFLAGS | IDCMP_CLOSEWINDOW | IDCMP_MENUPICK
IDCMPFLAGS	set	IDCMPFLAGS | IDCMP_GADGETDOWN | IDCMP_GADGETUP

;IDCMP flags that we wait for
IDCMPWAIT	set	IDCMP_RAWKEY | IDCMP_MOUSEBUTTONS
IDCMPWAIT	set	IDCMPWAIT | IDCMP_CLOSEWINDOW | IDCMP_MENUPICK
IDCMPWAIT	set	IDCMPWAIT | IDCMP_GADGETUP

;Non-Intuition (custom) OpenScreen flag
NOBACKDROP	equ	1	;Don't open initial backdrop window
SF_CUSTOM	equ	$0001
SF_SYSTEM	equ	~SF_CUSTOM


	include "data.i"	;Data area definition
