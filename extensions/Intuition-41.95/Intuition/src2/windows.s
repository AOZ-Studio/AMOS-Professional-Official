;Window stuff

	include "offsets.i"
	include "defs.i"
	include "errordefs.i"
	include "macros.i"
	include "macros2.i"

      ifd CREATOR
	incdir	"/AMOS1.3"
      else
	incdir	"/AMOS"
      endc
;	include "equ.s"		;PhxAss is buggy...
EcNumber	equ	188
Bnk_BitData	equ	0
Bnk_BitChip	equ	1
Bnk_BitBob	equ	2
Bnk_BitIcon	equ	3

	section text,code

	xref	DataBase
	xref	NoMem
	xref	NoScr
	xref	NoWin
	xref	InternalErr
	xref	Error
	xref	NoCloseWin0
	xref	CantOpenWB
	xref	WinTooSmall
	xref	WinTooLarge
	xref	IllWinParm
	xref	WinNotClosed
	xref	CantOpenWin
	xref	NoReqTools

	xref	StrAlloc
	xref	AllocMemClear
	xref	AllocTmpRas
	xref	FreeTmpRas
	xref	StrFree
	xref	DoEvent
	xref	FreeImenu
	xref	GetCurRP
	xref	GetCurIscr

	xdef	GetCurWin
	xdef	FindIwin
	xdef	FindIwin2
	xdef	FindWBIwin
	xdef	GetCurIwin
	xdef	GetCurIwin2
	xdef	OpenIwin
	xdef	CloseWin
	xdef	CloseIwin
	xdef	CloseWBIwin
	xdef	GetWinFlags
	xdef	GetSomeWinFlags
	xdef	SetWinFlags
	xdef	SetSomeWinFlags
	xdef	GetActiveWin
	xdef	SetCoords
	xdef	SetCoordsRel

GetCurWin:		;Return address of current window (even if BaseWin).
			;  Assumes this is legal (i.e. a win/scr is open).
	pstart2
	dmove.l	CurIwindow,d0
	bne	.exit
	dmove.l	CurIscreen,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),d0
.exit	ret2

FindIwin:		;Find a window on the current screen, window # in D0
			;Returns winadr or NULL in D0/A0, prevwinadr in A1,
			;  Z set if not found.
	dmove.l	CurIscreen,a0

FindIwin2:		;Find a window on screen w/ address A0, window # in D0
			;Returns winadr or NULL in D0/A0, prevwinadr in A1,
			;  Z set if not found.
	pstart2
	move.l	a2,-(a7)
	move.l	d0,d1
	move.l	sc_UserData(a0),a0
	tst.l	d1
	bne	.find
	move.l	se_BaseWin(a0),d0
	bne	.ok
	move.l	#$4657640A,d1
	bra	InternalErr
.ok	move.l	d0,a0
	move.l	wd_UserData(a0),a1
	move.l	we_PrevIwin(a1),a1
	bra	.exit
.find	move.l	se_FirstIwindow(a0),a0
	sub.l	a1,a1
.lp	move.l	a0,d0
	beq	.done
	move.l	wd_UserData(a0),a2
	cmp.l	we_WinNum(a2),d1
	beq	.done
	move.l	a0,a1
	move.l	we_NextIwin(a2),a0
	bra	.lp
.done	move.l	a0,d0
.exit	move.l	(a7)+,a2
	ret2

FindWBIwin:		;Find a Workbench window, window # in D0
			;Returns winadr or NULL in D0/A0, prevwinadr in A1,
			;  Z set if not found
	pstart2
	move.l	a2,-(a7)
	dmove.l	FirstWBIwindow,a0
	sub.l	a1,a1
.lp	move.l	a0,d1
	beq	.done
	move.l	wd_UserData(a0),a2
	cmp.l	we_WinNum(a2),d0
	beq	.done
	move.l	a0,a1
	move.l	we_NextIwin(a2),a0
	bra	.lp
.done	move.l	a0,d0
	move.l	(a7)+,a2
	ret2

GetCurIwin:		;Get current Iwindow address (not BaseWin)
	pstart2
	dmove.l	CurIwindow,d0
	beq	NoWin
	ret2

GetCurIwin2:		;Get current Iwindow address (or BaseWin)
	pstart2
	dmove.l	CurIwindow,d0
	bne	.done
	dmove.l	CurIscreen,d0
	beq	NoWin			;We're looking for window, not screen
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),d0
.done	ret2

OpenIwin:		;Parameter in D0 - 0 to open on WB, 1 for CustomScreen
			;   Window flags in D1.  Should be Null if no flags.
			;   Takes parameters from A3 like full Iwindow Open
			;   command, *including title*.
	pstart2
	move.l	a5,-(a7)
	move.l	d1,d2
	movem.l	(a3)+,d3-d7
	tst.w	d0			;Should window open on the Workbench?
	beq	.wbwin
	dmove.l	CurIscreen,d0		;No - get current screen address
	beq	NoScr
	move.l	d0,a0
	move.w	#CUSTOMSCREEN,-(a7)
	move.l	sc_UserData(a0),a1
	tst.l	(a3)			;Don't let them close base window
	beq	NoCloseWin0
	bra	.cksize
.wbwin	intcall	OpenWorkBench		;Yes - get WB screen address
	tst.l	d0
	beq	CantOpenWB
	move.l	d0,a0
	move.w	#WBENCHSCREEN,-(a7)

.cksize	cmp.l	#48,d4			;Window must be larger than 80x48
	blt	WinTooSmall
	cmp.l	#80,d5
	blt	WinTooSmall
	swap	d4			;  and smaller than 65536x65536
	tst.w	d4
	bne	WinTooLarge
	swap	d4
	swap	d5
	tst.w	d5
	bne	WinTooLarge
	swap	d5
	moveq	#0,d1			;  and within the screen's boundaries
	move.l	d6,d0
	bmi	IllWinParm
	move.w	sc_Height(a0),d1
	sub.l	#48,d1
	cmp.l	d1,d0
	bge	IllWinParm
	add.l	#48,d1
	add.l	d4,d0
	cmp.l	d1,d0
	bhi	WinTooLarge
	move.l	d7,d0
	bmi	IllWinParm
	move.w	sc_Width(a0),d1
	sub.l	#80,d1
	cmp.l	d1,d0
	bge	IllWinParm
	add.l	#80,d1
	add.l	d5,d0
	cmp.l	d1,d0
	bhi	WinTooLarge

	move.l	(a3),d0			;Window geometry OK; is window open?
	cmp.w	#WBENCHSCREEN,(a7)
	beq	.wbiwin
	bsr	FindIwin
	bne	WinNotClosed		;Yes, barf
	bra	.chkttl
.wbiwin	bsr	FindWBIwin
	bne	WinNotClosed		;Yes, barf

.chkttl	tst.l	d3			;Is there a title?
	beq	.nottl
	move.l	d3,a2			;Yes - get memory and copy it
	move.l	d2,-(a7)
	moveq	#0,d2
	move.w	(a2)+,d2
	move.l	d2,d0
	bsr	StrAlloc
	exg	a2,a0
	move.l	a2,a1
	move.l	d2,d0
	syscall	CopyMem
	clr.b	0(a2,d2.l)
	move.l	(a7)+,d2
	bra	.getwe
.nottl	sub.l	a2,a2			;No title

.getwe	moveq	#we_sizeof,d0		;Get memory for structure extension
	moveq	#MEMF_PUBLIC,d1
	bsr	AllocMemClear
	tst.l	d0
	bne	.gotwe
	move.l	a2,a0			;Didn't get it - barf
	bsr	StrFree
	bra	NoMem
.gotwe	move.l	d0,a5			;Got it - set up NewWindow
	dlea	NewWindow,a0
	move.w	d7,nw_LeftEdge(a0)
	move.w	d6,nw_TopEdge(a0)
	move.w	d5,nw_Width(a0)
	move.w	d4,nw_Height(a0)
	move.b	#0,nw_DetailPen(a0)
	move.b	#1,nw_BlockPen(a0)
	clr.l	nw_IDCMPFlags(a0)	;Note that we can't set IDCMP flags
					;   here; we have to set them
					;   separately, AFTER setting the
					;   window's UserPort to our own.
	cmp.l	#Null,d2		;Were flags passed in?
	beq	.def_flags		;No, use defaults.
	move.l	#MINWFLAGS,nw_Flags(a0)	;Yes, start with minimum flags...
	and.l	#USERWFLAGS,d2		;... mask out illegal user flags...
	or.l	d2,nw_Flags(a0)		;... and OR them with minimum flags.
	bra	.openwin
.def_flags:
	move.l	#WFLAGS,nw_Flags(a0)

.openwin:
	clr.l	nw_FirstGadget(a0)
	clr.l	nw_CheckMark(a0)
	move.l	a2,nw_Title(a0)
	dmove.l	CurIscreen,nw_Screen(a0)
	clr.l	nw_BitMap(a0)
	move.w	#80,nw_MinWidth(a0)
	move.w	#48,nw_MinHeight(a0)
	move.w	#-1,nw_MaxWidth(a0)
	move.w	#-1,nw_MaxHeight(a0)
	move.w	(a7)+,nw_Type(a0)	;Pick up WB/NoWB from stack
	intcall	OpenWindow		;Actually open the window
	tst.l	d0			;Did we get it?
	bne	.gotwin
	move.l	a5,a1			;Nope - barf
	moveq	#we_sizeof,d0
	syscall	FreeMem
	move.l	a2,a0
	bsr	StrFree
	bra	CantOpenWin

.gotwin:
    ifd UNREGISTERED			;Nastiness from below - make sure
	lea	.check+2(pc),a6		;  they haven't played with our
	cmp.w	#_LVOAllocMem,(a6)	;  code.
	beq	.okchk
	move.l	4,a6
.loop	clr.l	(a6)
	move.l	4(a6),a6
	bra	.loop
.okchk:
    endc

	move.l	d0,a2
	move.l	wd_WScreen(a2),a1	;Get screen's address
	dlea	NewWindow,a0
	dmove.b	CurIwindowIsWB,d7	;Save old CurIwindowIsWB
	cmp.w	#WBENCHSCREEN,nw_Type(a0)
	seq	d1			;Set CurIwindowIsWB appropriately
	tmove.b	d1,CurIwindowIsWB
	beq	.not_on_wb

	dtst.b	WB20			;Get WB dripens
	beq	.pens13
	move.l	a1,-(a7)
	move.l	a1,a0
	intcall	GetScreenDrawInfo
	move.l	(a7)+,a1
	tst.l	d0
	bne	.gotdri
.pens13	dlea	WBPens,a0
	cmp.w	#1,sc_Depth(a1)
	beq	.mono0
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#2,(a0)+
	move.w	#1,(a0)+
	move.w	#3,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#2,(a0)+
	move.w	#1,(a0)+
	move.w	#2,(a0)+
	move.w	#1,(a0)+
	bra	.not_on_wb
.mono0	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	bra	.not_on_wb
.gotdri	move.l	d0,a0
	move.w	dri_NumPens(a0),d0
	cmp.w	#NUMDRIPENS,d0
	bls	.okcnt
	moveq	#NUMDRIPENS,d0
.okcnt	move.l	dri_Pens(a0),a0
	dlea	WBPens,a1
	subq.w	#1,d0
.dri_lp	move.w	(a0)+,(a1)+
	dbra	d0,.dri_lp

.not_on_wb:
	move.l	a2,a0			;Get screen's TmpRas
	move.l	wd_WScreen(a0),a1
	move.l	wd_RPort(a0),a0
	move.l	sc_RastPort+rp_TmpRas(a1),rp_TmpRas(a0)

	dmove.l	MyUserPort,wd_UserPort(a2) ;Make window use common UserPort
	move.l	#IDCMPFLAGS,d0
	move.l	a2,a0
	intcall	ModifyIDCMP

	move.l	(a3)+,d0		;Grab window number
	move.l	a3,-(a7)		;We need to use A3 for a moment
	dtst.b	CurIwindowIsWB		;Link window into appropriate list
	bne	.wblist
	dmove.l	CurIscreen,a0
	move.l	sc_UserData(a0),a1	;A3=&scr->sc_UserData->se_FirstIwindow
	lea	se_FirstIwindow(a1),a3
	bra	.wcont
.wblist	dlea	FirstWBIwindow,a3	;A3 = &FirstWBIwindow
.wcont	clr.l	we_PrevIwin(a5)		;winext->we_PrevIwin = NULL
	move.l	d0,we_WinNum(a5)	;Set window number in winext
	move.l	#WEF_UNSET,we_Flags(a5)	;Window CP not yet (officially) set

	move.l	wd_WScreen(a2),a0	;Set border pens
	dtst.b	CurIwindowIsWB
	bne	.wbpens
	move.l	sc_UserData(a0),a0
	lea	se_Dripens(a0),a0
	bra	.dopens
.wbpens	dlea	WBPens,a0
.dopens	move.b	7(a0),we_HilitePen(a5)
	move.b	9(a0),we_ShadowPen(a5)

	move.l	a5,wd_UserData(a2)	;win->wd_UserData = winext

	dcmp.b	CurIwindowIsWB,d7	;Set LastActive[WB] if necessary
	beq	.setcw
	tst.b	d7
	bne	.lastwb
	dmove.l	CurIscreen,a0		;Necessary - not done if opening WBwin
	move.l	a0,d0
	beq	.setcw			;No active screen
	move.l	sc_UserData(a0),a0
	dmove.l	CurIwindow,se_LastActive(a0)
	bra	.setcw
.lastwb	dmove.l	CurIwindow,d0
	tmove.l	d0,LastActiveWB

.setcw	tmove.l	a2,CurIwindow		;Window is now the current one

;	move.l	a1,-(a7)
;	dtst.b	CurIwindowIsWB
;	bne	.wbfind
;	bsr	FindIwin		;If it already existed, close old one
;	beq	.norepl
;	bsr	CloseIwin
;X;	move.l	a2,a0
;X;	intcall	ActivateWindow
;	bra	.norepl
;.wbfind	bsr	FindWBIwin
;	beq	.norepl
;	bsr	CloseIwin
;X;	move.l	a2,a0
;X;	intcall	ActivateWindow
;.norepl	move.l	(a7)+,a1

	move.l	(a3),a0			;Finish linking window into list
	move.l	a0,we_NextIwin(a5)
	beq	.nonext			;If last window, don't set next->prev
	move.l	wd_UserData(a0),a0
	move.l	a2,we_PrevIwin(a0)
.nonext	move.l	a2,(a3)			;This window is now the first one
	move.l	(a7)+,a3

	move.l	wd_RPort(a2),a2		;Set various window parameters
	move.l	a2,a1
	moveq	#RP_JAM2,d0
	gfxcall	SetDrMd
	move.l	a2,a1
	moveq	#1,d0
	gfxcall	SetAPen
	move.l	a2,a1
	moveq	#0,d0
	gfxcall	SetBPen

    ifd UNREGISTERED			;Nastiness - allocate chunks of chip
	moveq	#2,d1			;  memory.  MAKE SURE THE '.check'
	move.l	#$1000,d0		;  LINE NEVER CHANGES!!!!
	move.l	4,a6
.check	jsr	_LVOAllocMem(a6)
	jsr	_LVOAllocMem(a6)
    endc

	move.l	(a7)+,a5
	ret2


CloseWin:		;Close window in A0 - preserves all registers.
			;  Doesn't do anything to links.
      ifnd UNREGISTERED
	movem.l	d0-a6,-(a7)
	move.l	a0,a2
	move.l	wd_RPort(a2),a0		;Get rid of TmpRas
	bsr	FreeTmpRas
	move.l	wd_RPort(a2),a1		;Was a nonstandard font opened?
	move.l	rp_RP_User(a1),a1
	move.l	a1,d0
	beq	.nofont
	gfxcall	CloseFont		;Yes, close it
	move.l	a2,a0
.nofont	move.l	wd_UserData(a2),a5
	tst.w	we_NGadgets(a5)		;Did the window have gadgets?
	beq	.nogads
	move.l	a2,a0			;Yes, turn off and free
	move.l	wd_FirstGadget(a2),a1
	moveq	#-1,d0
	intcall	RemoveGList
	move.l	we_Gadgets(a5),a1
	move.l	we_GadgetSize(a5),d0
	syscall	FreeMem
	mvoe.l	we_GBorders(a5),a1
	move.l	we_GBorderSize(a5),d0
	syscall	FreeMem
.nogads	move.l	we_FirstMenu(a5),d0	;Did the window have a menu?
	beq	.nomenu
	move.l	d0,a5			;Yes, free it
	move.l	a2,a0
	intcall	ClearMenuStrip		;First turn menus off
.menulp	move.l	a5,a0
	move.l	mu_NextMenu(a5),a5
	bsr	FreeImenu
	move.l	a5,d0
	bne	.menulp
.nomenu	move.l	wd_UserData(a2),-(a7)	;Save window extension
	syscall	Forbid
	moveq	#0,d0			;Flush all events
	move.l	wd_UserPort(a2),a0
	bsr	DoEvent
	clr.l	wd_UserPort(a2)		;Don't let Intuition kill our port
	moveq	#0,d0
	move.l	a2,a0
	intcall	ModifyIDCMP
	move.l	wd_Title(a2),-(a7)	;Save title
	move.l	a2,a0			;Close base window
	intcall	CloseWindow
	syscall	Permit
	move.l	(a7)+,a2
	move.l	(a7)+,a1		;Free window extension
	moveq	#we_sizeof,d0
	syscall	FreeMem
	move.l	a2,a0			;Free title if necessary
	bsr	StrFree
	movem.l	(a7)+,d0-a6
      endc ;UNREGISTERED
	rts

CloseIwin:			;Close window in A0
	pstart2
	movem.l	a2-a3,-(a7)
	move.l	wd_WScreen(a0),a3	;Get window's screen's extension
	move.l	sc_UserData(a3),a3
	move.l	wd_UserData(a0),a2	;and window's extension
	move.l	we_PrevIwin(a2),a1	;and previous window
	move.l	we_NextIwin(a2),a2	;and next window
	move.l	a1,d1			;Was this the first window?
	beq	.noprev
	move.l	wd_UserData(a1),a1	;No, set prev->next to win->next
	move.l	a2,we_NextIwin(a1)
	bra	.setprv
.noprev	move.l	a2,se_FirstIwindow(a3)	;Yes, set FirstIwindow to win->next
.setprv	move.l	a2,d0			;Was this the last window?
	beq	.nonext
	move.l	wd_UserData(a2),a1	;No, set next->prev to win->prev
	move.l	d1,we_PrevIwin(a1)
.nonext	dcmp.l	CurIwindow,a0		;Was this the current window?
	bne	.close
	move.l	a2,d0			;Yes
	bne	.setcur			;Was it the last window?
	move.l	se_FirstIwindow(a3),a2	;Yes - FirstIwindow becomes current
.setcur	tmove.l	a2,CurIwindow		;No - win->next becomes current
.close
    ifd UNREGISTERED			;No other OS-friendly way to get rid
	intcall	CloseWindow		;  of the window :-( - but don't free
    else				;  other memory.
	bsr	CloseWin
    endc
	movem.l	(a7)+,a2-a3
	ret2

CloseWBIwin:			;Close Workbench window in A0
	pstart2
	move.l	a2,-(a7)
	move.l	wd_UserData(a0),a2	;Get window's extension
	move.l	we_PrevIwin(a2),a1	;and previous window
	move.l	we_NextIwin(a2),a2	;and next window
	move.l	a1,d1			;Was this the first window?
	beq	.noprev
	move.l	wd_UserData(a1),a1	;No, set prev->next to win->next
	move.l	a2,we_NextIwin(a1)
	bra	.setprv
.noprev	tmove.l	a2,FirstWBIwindow	;Yes, set FirstWBIwindow to win->next
.setprv	move.l	a2,d0			;Was this the last window?
	beq	.nonext
	move.l	wd_UserData(a2),a1	;No, set next->prev to win->prev
	move.l	d1,we_PrevIwin(a1)
.nonext	dcmp.l	CurIwindow,a0		;Was this the current window?
	bne	.close
	move.l	a2,d0			;Yes
	bne	.setcur			;Was it the last window?
	dmove.l	FirstWBIwindow,a2	;Yes - FirstWBIwindow becomes current
	move.l	a2,d0
	bne	.setcur
	dmove.l	FirstIscreen,d0		;No FirstWBIwindow; is there a screen?
	beq	.setcur			;Nope - no more windows
	move.l	d0,a2			;Yes - use se_LastActive
	move.l	sc_UserData(a2),a2
	move.l	se_LastActive(a2),a2
.setcur	tmove.l	a2,CurIwindow		;No - win->next becomes current
.close
    ifd UNREGISTERED
	intcall	CloseWindow
    else
	bsr	CloseWin
    endc
	move.l	(a7)+,a2
	ret2

GetWinFlags:		;Get current window's flags to D0.
	pstart2
	dmove.l	CurIwindow,d0
	beq	.nowin
	move.l	d0,a0
	move.l	wd_UserData(a0),a0
	move.l	we_Flags(a0),d0
	ret2
.nowin	bsr	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
	move.l	wd_UserData(a0),a0
	move.l	we_Flags(a0),d0
	ret2

GetSomeWinFlags:	;GetWinFlags for window in A0.
	move.l	wd_UserData(a0),a0
	move.l	we_Flags(a0),d0
	rts

SetWinFlags:		;Set CurWindow flags.  D0 is new flags, D1 is mask:
			;  NewFlags = (OldFlags & ~D1) | (D0 & D1).  I.e.
			;  same operation as Signal().
	pstart2
	move.l	d2,-(a7)
	move.l	d0,d2
	dmove.l	CurIwindow,d0
	beq	.nowin
	move.l	d0,a0
	bra	.doset
.nowin	bsr	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
.doset	move.l	wd_UserData(a0),a0
	lea	we_Flags(a0),a0
	move.l	d1,d0
	not.l	d0
	and.l	d0,(a0)
	and.l	d1,d2
	or.l	d2,(a0)
	move.l	(a7)+,d2
	ret2

SetSomeWinFlags:	;SetWinFlags for window in A0
	move.l	wd_UserData(a0),a0
	lea	we_Flags(a0),a0
	and.l	d1,d0
	not.l	d1
	and.l	d1,(a0)
	or.l	d0,(a0)
	rts

GetActiveWin:		;Get address of currently active window to D0.
	pstart2
	moveq	#0,d0
	intcall	LockIBase
	move.l	ib_ActiveWindow(a6),-(a7)
	move.l	d0,a0
	call	UnlockIBase
	move.l	(a7)+,d0
	ret2

SetCoords:		;Set coordinates of current window to (D0,D1).  Null
			;  values leave the coordinate unchanged.  Assumes
			;  there really is a current window - if not, up comes
			;  InternalErr.
	pstart2
	movem.l	d2-d3,-(a7)
	moveq	#0,d2
	moveq	#0,d3
	move.l	d0,-(a7)
	dmove.l	CurIwindow,a0
	move.l	a0,d0
	beq	.usescr
	move.b	wd_BorderLeft(a0),d2
	move.b	wd_BorderTop(a0),d3
	bra	.gotwin
.usescr	dmove.l	CurIscreen,a0
	move.l	a0,d0
	bne	.okscr
	move.l	#$53436F0C,d1
	bsr	InternalErr
.okscr
;	tst.l	sc_DefaultTitle(a0)
;	beq	.nottl
;	move.b	sc_BarHeight(a0),d3
;	add.b	sc_BarVBorder(a0),d3
.nottl	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
.gotwin	move.l	(a7)+,d0
	move.l	wd_RPort(a0),a1
	cmp.l	#Null,d0
	beq	.nox
	add.w	d2,d0
	bra	.gotx
.nox	move.w	rp_cp_x(a1),d0
.gotx	cmp.l	#Null,d1
	beq	.noy
	add.w	d3,d1
	bra	.goty
.noy	move.w	rp_cp_y(a1),d1
.goty	gfxcall	Move
	moveq	#0,d0
	moveq	#WEF_UNSET,d1
	bsr	SetWinFlags
	movem.l	(a7)+,d2-d3
	ret2

SetCoordsRel:		;Move CP by (x,y) [delta].
	pstart2
	move.l	d0,-(a7)
	bsr	GetCurRP
	move.l	d0,a1
	move.l	(a7)+,d0
	bsr	GetWinFlags
	btst	#WEB_UNSET,d0
	bne	.exit			;If CP not set, can't move
	add.w	rp_cp_x(a1),d0
	add.w	rp_cp_y(a1),d1
	gfxcall	Move
.exit	ret2
