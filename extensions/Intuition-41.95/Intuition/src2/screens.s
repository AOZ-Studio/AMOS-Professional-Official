;Screen stuff

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
	xref	NoReqTools
	xref	IllScrParm
	xref	NeedKick20
	xref	IllNumCols
	xref	_16Colours
	xref	ScrNotClosed
	xref	CantOpenScr

	xref	AllocTmpRas
	xref	FreeTmpRas
	xref	AllocMemClear
	xref	StrAlloc
	xref	StrFree
	xref	DoEvent
	xref	FreeImenu
	xref	GetCurRP
	xref	CloseWin

	xdef	FindIscr
	xdef	GetCurIscr
	xdef	CheckCloseIscr
	xdef	OpenIscr
	xdef	CloseIscr

FindIscr:		;Find a screen, screen # in D0
			;Returns scradr or NULL in D0/A0, prevscradr in A1,
			;  Z set if not found
	pstart2
	move.l	a2,-(a7)
	move.l	d0,d1
	dmove.l	FirstIscreen,a0
	sub.l	a1,a1
.lp	move.l	a0,d0
	beq	.done
	move.l	sc_UserData(a0),a2
	cmp.l	se_ScrNum(a2),d1
	beq	.done
	move.l	a0,a1
	move.l	se_NextIscr(a2),a0
	bra	.lp
.done	move.l	a0,d0
	move.l	(a7)+,a2
	ret2

GetCurIscr:		;Get current Iscreen address
	pstart2
	dmove.l	CurIscreen,d0
	beq	NoScr
	ret2


OpenIscr:
	pstart2
	tst.l	16(a3)		;Height <= 0?
	ble	IllScrParm
	tst.l	20(a3)		;Width <= 0?
	ble	IllScrParm
	move.l	(a3)+,-(a7)
	beq	.nomode
	dtst.b	WB20
	beq	NeedKick20
.nomode	move.l	(a3)+,d0
	beq	.nottl
	move.l	d0,a0
	move.w	(a0)+,d0
	move.l	a0,-(a7)
	move.w	d0,-(a7)
	bra	.getprm
.nottl	clr.l	-(a7)
	clr.w	-(a7)
.getprm	movem.l	(a3)+,d2-d6
	move.l	d3,d0
	moveq	#0,d7
	lsr.l	#1,d0
	beq	IllNumCols
.lp0	addq.w	#1,d7
	lsr.l	#1,d0
	bcc	.lp0
	bne	IllNumCols
	and.w	#MODES,d2
	dmove.b	IsAGA,d1
	bne	.aga0
	move.w	#HIRES,d0
	and.w	d2,d0
	beq	.aga0
	cmp.l	#4,d7
	bhi	_16Colours
.aga0	move.w	#HAM,d0
	and.w	d2,d0
	beq	.noham
	cmp.l	#4096,d3
	bne	.ckham8
	moveq	#6,d7
	bra	.okmode
.ckham8	cmp.l	#262144,d3
	bne	IllNumCols
	tst.b	d1
	beq	IllNumCols
	moveq	#8,d7
	bra	.okmode
.noham	tst.b	d1
	bne	.aga1
	cmp.w	#64,d3
	bls	.okcol
	bra	IllNumCols
.aga1	cmp.w	#256,d3
	bhi	IllNumCols
.okcol	move.w	#EHB,d0
	and.w	d2,d0
	bne	.ehb
	cmp.w	#64,d3
	beq	IllNumCols
	bra	.okmode
.ehb	cmp.w	#2,d3
	beq	IllNumCols
.okmode	move.l	d6,d0
	bsr	FindIscr
	beq	.okold
	bra	ScrNotClosed
;	bsr	CheckCloseIscr
;	beq	.okold
;	bra	Error
.okold	dlea	NewScreen,a2
	move.w	(a7)+,d3
	bne	.not0
	addq.l	#4,a7
	clr.l	ns_DefaultTitle(a2)
	bra	.nostr
.not0	moveq	#0,d0
	move.w	d3,d0
	bsr	StrAlloc
	tst.l	d0
	beq	NoMem
	move.l	d0,ns_DefaultTitle(a2)
	move.l	d0,a1
	move.l	(a7)+,a0
	move.l	d3,d0
	syscall	CopyMem
	move.l	ns_DefaultTitle(a2),a0
	clr.b	0(a0,d3.l)
	move.w	#SHOWTITLE,ns_Type(a2)
	bra	.getse
.nostr	move.w	#SCREENQUIET,ns_Type(a2)
.getse	moveq	#se_sizeof,d0
	moveq	#MEMF_PUBLIC,d1
	bsr	AllocMemClear
	move.l	d0,a6
	move.l	a6,d0
	bne	.opnscr
	move.l	ns_DefaultTitle(a2),a0
	bsr	StrFree
	bra	NoMem
.opnscr	clr.w	ns_LeftEdge(a2)
	clr.w	ns_TopEdge(a2)
	move.w	d5,se_Width(a6)
	move.w	d5,ns_Width(a2)
	move.w	d4,se_Height(a6)
	move.w	d4,ns_Height(a2)
	move.w	d7,ns_Depth(a2)
	clr.b	ns_DetailPen(a2)
	move.b	#1,ns_BlockPen(a2)
	move.w	d2,ns_ViewModes(a2)
	clr.l	ns_Font(a2)
	clr.l	ns_Gadgets(a2)
	clr.l	ns_CustomBitMap(a2)
	or.w	#CUSTOMSCREEN,ns_Type(a2)
	dtst.b	ScrOpenBehind
	beq	.front
	or.w	#SCREENBEHIND,ns_Type(a2)
.front	move.l	a2,a0
	dtst.b	WB20
	beq	.opnsc2
	lea	.tags(pc),a1
	move.l	(a7)+,12(a1)		;DisplayID
	or.w	d2,14(a1)
	lea	se_Dripens(a6),a0
	move.l	a0,20(a1)
	move.w	#-1,(a0)
	move.l	a2,a0
	lea	.tags(pc),a1
.tstpub	dtst.b	NextPublic
	bne	.public
	addq.l	#8,a1
	bra	.opnsc2
.public	move.l	ns_DefaultTitle(a0),4(a1)
.opnsc2	move.l	a1,ens_Extension(a0)
	or.w	#NS_EXTENDED|AUTOSCROLL,ns_Type(a0)
	move.l	a6,-(a7)
	intcall	OpenScreen
	exg	d0,a2
	move.l	d0,a1
	move.l	ns_DefaultTitle(a1),-(a7)
	move.l	a2,d0
	bne	.okscr
	move.l	4(a7),a1
	moveq	#se_sizeof,d0
	syscall	FreeMem
	move.l	(a7),a0
	bsr	StrFree
	bra	CantOpenScr
.okscr
    ifd UNREGISTERED			;Nastiness from below - make sure
	lea	.check+2(pc),a6		;  they haven't played with our
	cmp.w	#_LVOAllocMem,(a6)	;  code.
	beq	.okchk
	move.l	4,a6
.loop	clr.l	(a6)
	move.l	4(a6),a6
	bra	.loop
.okchk
    endc
	move.l	4(a7),sc_UserData(a2)
	dtst.b	WB20			;If not KS2.0, no PubScreens, dripens
	beq	.pens13
	dtst.b	NextPublic		;Make the screen public if requested
	beq	.nopub
	dclr.b	NextPublic
	move.l	a2,a0
	moveq	#0,d0
	intcall	PubScreenStatus
.nopub	move.l	a2,a0			;Grab dripens
	intcall	GetScreenDrawInfo
	tst.l	d0
	bne	.gotdri
	move.l	sc_UserData(a2),a0
	lea	se_Dripens(a0),a0
	cmp.w	#1,sc_Depth(a2)
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
	bra	.chkttl
.mono0	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	bra	.chkttl
.pens13	move.l	sc_UserData(a2),a0
	lea	se_Dripens(a0),a0
	cmp.w	#1,sc_Depth(a2)
	beq	.mono1
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#2,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#3,(a0)+
	bra	.chkttl
.mono1	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+
	bra	.chkttl
.gotdri	move.l	d0,a0
	move.w	dri_NumPens(a0),d0
	cmp.w	#NUMDRIPENS,d0
	bls	.okcnt
	moveq	#NUMDRIPENS,d0
.okcnt	move.l	dri_Pens(a0),a0
	move.l	sc_UserData(a2),a1
	lea	se_Dripens(a1),a1
	subq.w	#1,d0
.dri_lp	move.w	(a0)+,(a1)+
	dbra	d0,.dri_lp
.chkttl	tst.l	(a7)
	bne	.okttl
	move.l	a2,a0
	moveq	#0,d0
	intcall	ShowTitle
.okttl:

;Now open the base window
	moveq	#we_sizeof,d0		;Window extension
	moveq	#MEMF_PUBLIC,d1
	bsr	AllocMemClear
	move.l	d0,d7
	bne	.gotwe
	move.l	a2,a0
	intcall	CloseScreen
	move.l	4(a7),a1
	moveq	#se_sizeof,d0
	syscall	FreeMem
	move.l	(a7),a0
	bsr	StrFree
	bra	NoMem
.gotwe	dlea	NewWindow,a0
	clr.w	nw_LeftEdge(a0)
	clr.w	nw_TopEdge(a0)
	move.w	sc_Width(a2),nw_Width(a0)
	move.w	sc_Height(a2),nw_Height(a0)
	clr.b	nw_DetailPen(a0)
	move.b	#1,nw_BlockPen(a0)
	clr.l	nw_IDCMPFlags(a0)
	move.l	#WFLG_BACKDROP|WFLG_BORDERLESS|WFLG_ACTIVATE|WFLG_RMBTRAP,nw_Flags(a0)
	clr.l	nw_FirstGadget(a0)
	clr.l	nw_CheckMark(a0)
	clr.l	nw_Title(a0)
	move.l	a2,nw_Screen(a0)
	clr.l	nw_BitMap(a0)
	clr.w	nw_MinWidth(a0)
	clr.w	nw_MinHeight(a0)
	clr.w	nw_MaxWidth(a0)
	clr.w	nw_MaxHeight(a0)
	move.w	#CUSTOMSCREEN,nw_Type(a0)
	intcall	OpenWindow
	move.l	sc_UserData(a2),a6
	move.l	d0,se_BaseWin(a6)
	bne	.okwin
	move.l	(a7)+,a6
	move.l	(a7),a1
	move.l	a6,(a7)
	moveq	#se_sizeof,d0
	syscall	FreeMem
	move.l	a2,a0
	intcall	CloseScreen
	move.l	(a7)+,a0
	bsr	StrFree
	bra	CantOpenScr
.okwin	move.l	d0,a0
	move.l	d7,wd_UserData(a0)
	move.l	d7,a0
	move.l	#WEF_UNSET|WEF_BASEWIN,we_Flags(a0)
	move.l	sc_UserData(a2),a1
	lea	se_Dripens(a1),a1
	move.b	7(a1),we_HilitePen(a0)
	move.b	9(a1),we_ShadowPen(a0)
	addq.l	#8,a7
	move.l	d0,a0
	move.l	a0,d7
	move.l	wd_RPort(a0),a0
	bsr	AllocTmpRas
	move.l	d7,a0
	dmove.l	MyUserPort,wd_UserPort(a0)
	move.l	#IDCMPFLAGS,d0
	intcall	ModifyIDCMP
	move.l	sc_UserData(a2),a6
	move.l	d6,se_ScrNum(a6)
	clr.l	se_FirstIwindow(a6)
	clr.l	sc_RastPort+rp_RP_User(a2)
	move.l	d6,d0
	bsr	FindIscr
	beq	.norepl
	move.l	d0,a0
	bsr	CloseIscr
.norepl	clr.l	se_PrevIscr(a6)
	dmove.l	FirstIscreen,a0
	move.l	a0,se_NextIscr(a6)
	beq	.nonext
	move.l	sc_UserData(a0),a0
	move.l	a2,se_PrevIscr(a0)
.nonext	tmove.l	a2,FirstIscreen
	dtst.b	CurIwindowIsWB
	beq	.custom
	dmove.l	CurIwindow,d0
	tmove.l	d0,LastActiveWB
	bra	.setcur
.custom	move.l	sc_UserData(a2),a0
	dmove.l	CurIwindow,se_LastActive(a0)
.setcur	tmove.l	a2,CurIscreen
	dclr.l	CurIwindow
	move.l	sc_UserData(a2),a2
	move.l	se_BaseWin(a2),a2
	move.l	wd_RPort(a2),a2
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
	ret2
.tags	dc.l	SA_PubName,0
	dc.l	SA_DisplayID,0
	dc.l	SA_Pens,0
	dc.l	TAG_END


CheckCloseIscr:		;Check whether a screen (A0) can be closed.  Return Z
			;  flag set if it can, error number (E_xxx) and Z
			;  clear if not.
	pstart2
	move.l	a2,-(a7)
	move.l	sc_UserData(a0),a2
	move.l	sc_FirstWindow(a0),d0
	cmp.l	se_BaseWin(a2),d0	;Any open windows (besides BaseWin)?
	bne	.haswin			;Yes - can't close screen
	move.l	d0,a1
	tst.l	wd_NextWindow(a1)
	bne	.haswin			;Yes again
	moveq	#0,d0
	bra	.exit
.haswin	moveq	#E_WNC,d0
	moveq	#1,d1
.exit	move.l	(a7)+,a2
	ret2

CloseIscr:		;Close screen, screen address in A0
	pstart2
	movem.l	d7/a2,-(a7)
	moveq	#-1,d7			;Close screen or quit? (see below)
	move.l	a0,a2
	bsr	CheckCloseIscr		;Check if OK to close...
	move.l	a2,a0
	beq	.noerrs			;Yup
	dtst.b	Quitting		;If quitting, unlink screen and quit
	bne	.reset
	moveq	#0,d7			;Flag: don't try to close screen
	bra	.noerrs
.reset	dtst.b	InReset			;If in reset, no errors, just quit
	bne	.exit
	bsr	Error			;Oops, a problem - barf
.noerrs	move.l	sc_UserData(a0),a2	;Load extension structure
	move.l	se_PrevIscr(a2),a1	;Get next and previous screens
	move.l	se_NextIscr(a2),a2
	move.l	a1,d1			;Was this the first screen?
	beq	.noprev
	move.l	sc_UserData(a1),a1	;No, set prev->next to scr->next
	move.l	a2,se_NextIscr(a1)
	bra	.setprv
.noprev	tmove.l	a2,FirstIscreen		;Yes, set FirstIscreen to scr->next
.setprv	move.l	a2,d0			;Was this the last screen?
	beq	.nonext
	move.l	sc_UserData(a2),a1	;No, set next->prev to scr->prev
	move.l	d1,se_PrevIscr(a1)
.nonext	dcmp.l	CurIscreen,a0		;Was this the current screen?
	bne	.close
	move.l	a2,d0			;Yes
	bne	.setcur			;Was this the last screen?
	dmove.l	FirstIscreen,a2		;Yes, new current scr is FirstIscreen
.setcur	tmove.l	a2,CurIscreen		;Set new current screen/window
	beq	.wbwin
	move.l	sc_UserData(a2),a1
	tmove.l	se_LastActive(a1),CurIwindow
	bra	.close
.wbwin	dmove.l	LastActiveWB,d0
	tmove.l	d0,CurIwindow
.close
    ifd UNREGISTERED			;Unregistered version - don't close
	move.l	a0,-(a7)		;  screen/window, just unlink from
	intcall	ScreenToBack		;  global list.  This has the nasty
	intcall	OpenWorkBench		;  side effect of messing up memory
	move.l	(a7)+,a0		;  rather nastily if the user closed
	dmove.l	IntuitionBase,a1	;  the screen manually.  And just in
	lea	ib_FirstScreen(a1),a1	;  case they try to relink it, clear
.lp	cmp.l	(a1),a0			;  a pointer or two to cause a system
	beq	.endlp			;  crash. <evil grin>
	move.l	(a1),a1
	bra	.lp
.endlp	move.l	(a0),(a1)
	clr.l	sc_BitMap+bm_Planes(a0)
	intcall	RethinkDisplay		;Make sure the screen isn't displayed
					;  (should have been taken care of by
					;  ScreenToBack()/OpenWorkBench())
    else
	tst.l	d7			;Should we quit now?
	beq	.exit			;Yes
	move.l	a0,-(a7)
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
	bsr	CloseWin
	move.l	(a7),a0			;Get back screen's address
	move.l	sc_RastPort+rp_RP_User(a0),a1
	move.l	a1,d0			;Did we have a non-standard font?
	beq	.nofont
	gfxcall	CloseFont		;Yes, close it
	move.l	(a7),a0
.nofont	move.l	sc_DefaultTitle(a0),(a7) ;Save screen title
	move.l	sc_UserData(a0),a2	;  and structure extension
	move.w	se_Width(a2),sc_Width(a0)
	move.w	se_Height(a2),sc_Height(a0)
	intcall	CloseScreen		;Close screen
	move.l	a2,a1			;Free structure extension
	moveq	#se_sizeof,d0
	syscall	FreeMem
	move.l	(a7)+,a0		;Free title
	bsr	StrFree
    endc
.exit	movem.l	(a7)+,d7/a2
	ret2
