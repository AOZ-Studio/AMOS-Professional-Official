;Window routines

L_IwindowOpen:		;Iwindow Open n,x,y,w,h,title$,flags
	pstart
	moveq	#1,d0
	move.l	(a3)+,d1
	jtcall	OpenIwin
	ret

L_IwindowOpenNF:	;Iwindow Open n,x,y,w,h,title$
	pstart
	moveq	#1,d0
	move.l	#Null,d1
	jtcall	OpenIwin
	ret

L_IwindowOpenNT:	;Iwindow Open n,x,y,w,h
	clr.l	-(a3)
	bra	L_IwindowOpenNF

L_IwindowOpenWB:	;Iwindow Open Wb n,x,y,w,h,title$,flags
	pstart
	moveq	#0,d0
	move.l	(a3)+,d1
	jtcall	OpenIwin
	ret

L_IwindowOpenWB_NF:	;Iwindow Open Wb n,x,y,w,h,title$
	pstart
	moveq	#0,d0
	move.l	#Null,d1
	jtcall	OpenIwin
	ret

L_IwindowOpenWB_NT:	;Iwindow Open Wb n,x,y,w,h
	clr.l	-(a3)
	bra	L_IwindowOpenWB_NF


L_IwindowClose:		;Iwindow Close n
	pstart
	move.l	(a3)+,d0
	beq	L_NoCloseWin0
	jtcall	FindIwin
	beq	L_NoWin
	jtcall	CloseIwin
	ret

L_IwindowCloseWB:	;Iwindow Close Wb n
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	jtcall	CloseWBIwin
	ret

L_IwindowSet:		;Set Iwindow n
	pstart
	dtst.l	CurIscreen
	beq	L_NoScr
	move.l	(a3)+,d0
	beq	.bkwin
	jtcall	FindIwin
	beq	L_NoWin
	dtst.b	CurIwindowIsWB
	beq	.setcur
	dmove.l	CurIwindow,d0
	tmove.l	d0,LastActiveWB
.setcur	tmove.l	a0,CurIwindow
	dclr.b	CurIwindowIsWB
	ret
.bkwin	dtst.b	CurIwindowIsWB
	beq	.clrcur
	dmove.l	CurIwindow,d0
	tmove.l	d0,LastActiveWB
.clrcur	dclr.l	CurIwindow
	dclr.b	CurIwindowIsWB
	ret

L_IwindowGet:		;=Iwindow
	pstart
	dmove.l	CurIwindow,d0
	beq	.bkwin
	move.l	d0,a0
	move.l	wd_UserData(a0),a0
	move.l	we_WinNum(a0),d3
	moveq	#0,d2
	ret
.bkwin	dtst.l	CurIscreen
	beq	L_NoScr
	moveq	#0,d3
	moveq	#0,d2
	ret

L_IwindowSetWB:		;Set Iwindow Wb n
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	dtst.b	CurIwindowIsWB
	bne	.setcur
	dmove.l	CurIscreen,d0
	beq	.setcur
	mvoe.l	d0,a1
	move.l	sc_UserData(a1),a1
	dmove.l	CurIwindow,se_LastActive(a1)
.setcur	tmove.l	a0,CurIwindow
	tmove.b	#-1,CurIwindowIsWB
	ret

L_IwindowOnWB:		;=Iwindow On Wb
	pstart
	dmove.b	CurIwindowIsWB,d3
	ext.w	d3
	ext.l	d3
	moveq	#0,d2
	ret

L_WinToFront:		;Base for 'Iwindow To Front *'; window in A0
	pstart
	move.l	a0,a2
	intcall	WindowToFront
	move.l	wd_UserData(a2),a0
	move.l	we_PrevIwin(a0),d0
	beq	.exit
	move.l	we_NextIwin(a0),d1
	move.l	d0,a1
	move.l	wd_UserData(a1),a1
	move.l	d1,we_NextIwin(a1)
	tst.l	d1
	beq	.nonext
	move.l	d1,a1
	move.l	wd_UserData(a1),a1
	move.l	d0,we_PrevIwin(a1)
.nonext	move.l	wd_WScreen(a2),a1
	move.l	sc_UserData(a1),a1
	move.l	se_FirstIwindow(a1),a6
	move.l	a6,we_NextIwin(a0)
	move.l	wd_UserData(a6),a6
	move.l	a2,we_PrevIwin(a6)
	clr.l	we_PrevIwin(a0)
	move.l	a2,se_FirstIwindow(a1)
.exit	ret

L_IwindowToFront:	;Iwindow To Front n
	pstart
	move.l	(a3)+,d0
	beq	L_NoModWin0
	jtcall	FindIwin
	beq	L_NoWin
	bsr	L_WinToFront
	ret

L_IwindowToFrontWB:	;Iwindow To Front Wb n
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	bsr	L_WinToFront
	ret

L_CurIwinToFront:	;Iwindow To Front
	pstart
	jtcall	GetCurIwin
	move.l	d0,a0
	bsr	L_WinToFront
	ret

L_WinToBack:		;Base for 'Iwindow To Back *'; window in A0
	pstart
	move.l	a0,a2
	intcall	WindowToBack
	move.l	wd_UserData(a2),a0
	move.l	we_NextIwin(a0),d0
	beq	.exit
	move.l	we_PrevIwin(a0),d1
	move.l	d0,a1
	move.l	wd_UserData(a1),a1
	move.l	d1,we_PrevIwin(a1)
	tst.l	d1
	beq	.noprev
	move.l	d1,a1
	move.l	wd_UserData(a1),a1
	move.l	d0,we_NextIwin(a1)
	bra	.mklast
.noprev	move.l	wd_WScreen(a2),a1
	move.l	sc_UserData(a1),a1
	move.l	d0,se_FirstIwindow(a1)
.mklast	move.l	wd_WScreen(a2),a1
	move.l	sc_UserData(a1),a1
	move.l	se_FirstIwindow(a1),a1
.lastlp	move.l	wd_UserData(a1),a0
	move.l	we_NextIwin(a0),d0
	beq	.endlp
	move.l	d0,a1
	bra	.lastlp
.endlp	move.l	a2,we_NextIwin(a0)
	move.l	wd_UserData(a2),a2
	move.l	a1,we_PrevIwin(a2)
	clr.l	we_NextIwin(a2)
.exit	ret

L_IwindowToBack:	;Iwindow To Back n
	pstart
	move.l	(a3)+,d0
	beq	L_NoModWin0
	jtcall	FindIwin
	beq	L_NoWin
	bsr	L_WinToBack
	ret

L_IwindowToBackWB:	;Iwindow To Back Wb n
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	bsr	L_WinToBack
	ret

L_CurIwinToBack:	;Iwindow To Back
	pstart
	jtcall	GetCurIwin
	move.l	d0,a0
	bsr	L_WinToBack
	ret

L_WinMove:		;Window in A0, new coords in D2/D3 (X/Y)
	pstart
	cmp.l	#Null,d2
	bne	.gotx
	moveq	#0,d2
	move.w	wd_LeftEdge(a0),d2
.gotx	cmp.l	#Null,d3
	bne	.goty
	moveq	#0,d3
	move.w	wd_TopEdge(a0),d3
.goty	move.l	wd_WScreen(a0),a1
	moveq	#0,d0
	move.w	sc_Width(a1),d0
	sub.w	wd_Width(a0),d0
	moveq	#0,d1
	move.w	sc_Height(a1),d1
	sub.w	wd_Height(a0),d1
	cmp.l	d0,d2
	bhi	L_IllFunc
	cmp.l	d1,d3
	bhi	L_IllFunc
	move.w	d2,d0
	move.w	d3,d1
	sub.w	wd_LeftEdge(a0),d0
	sub.w	wd_TopEdge(a0),d1
	ext.l	d0
	ext.l	d1
	intcall	MoveWindow
	ret

L_IwindowMove:		;Iwindow Move n,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	beq	L_NoModWin0
	jtcall	FindIwin
	beq	L_NoWin
	bsr	L_WinMove
	ret

L_IwindowMoveWB:	;Iwindow Move Wb n,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	bsr	L_WinMove
	ret

L_WinSize:		;Window in A0
	pstart
	cmp.l	#Null,d2
	bne	.gotx
	moveq	#0,d2
	move.w	wd_Width(a0),d2
.gotx	cmp.l	#Null,d3
	bne	.goty
	moveq	#0,d3
	move.w	wd_Height(a0),d3
.goty	move.l	wd_WScreen(a0),a1
	moveq	#0,d0
	move.w	sc_Width(a1),d0
	sub.w	wd_LeftEdge(a0),d0
	moveq	#0,d1
	move.w	sc_Height(a1),d1
	sub.w	wd_TopEdge(a0),d1
	cmp.l	d0,d2
	bhi	L_WinTooLarge
	cmp.l	d1,d3
	bhi	L_WinTooLarge
	cmp.l	#80,d2
	bcs	L_WinTooSmall
	cmp.l	#48,d3
	bcs	L_WinTooSmall
	move.w	d2,d0
	move.w	d3,d1
	sub.w	wd_Width(a0),d0
	sub.w	wd_Height(a0),d1
	ext.l	d0
	ext.l	d1
	intcall	SizeWindow
	ret

L_IwindowSize:		;Iwindow Size n,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	beq	L_NoModWin0
	jtcall	FindIwin
	beq	L_NoWin
	bsr	L_WinSize
	ret

L_IwindowSizeWB:	;Iwindow Size Wb n,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	bsr	L_WinSize
	ret

L_IwindowX:		;=Iwindow X(n)
	pstart
	move.l	(a3)+,d0
	beq	.scrwin
	jtcall	FindIwin
	beq	L_NoWin
	move.l	d0,a0
	move.w	wd_LeftEdge(a0),d3
	ext.l	d3
	moveq	#0,d2
	ret
.scrwin	dtst.l	CurIscreen
	beq	L_NoScr
	moveq	#0,d3
	moveq	#0,d2
	ret

L_IwindowXWB:		;=Iwindow X Wb(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	move.l	d0,a0
	move.w	wd_LeftEdge(a0),d3
	ext.l	d3
	moveq	#0,d2
	ret

L_CurIwindowX:		;=Iwindow X
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	move.w	wd_LeftEdge(a0),d3
	ext.l	d3
	moveq	#0,d2
	ret

L_IwindowY:		;=Iwindow Y(n)
	pstart
	move.l	(a3)+,d0
	beq	.scrwin
	jtcall	FindIwin
	beq	L_NoWin
	move.l	d0,a0
	move.w	wd_TopEdge(a0),d3
	ext.l	d3
	moveq	#0,d2
	ret
.scrwin	dtst.l	CurIscreen
	beq	L_NoScr
	moveq	#0,d3
	moveq	#0,d2
	ret

L_IwindowYWB:		;=Iwindow Y Wb(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	move.l	d0,a0
	move.w	wd_TopEdge(a0),d3
	ext.l	d3
	moveq	#0,d2
	ret

L_CurIwindowY:		;=Iwindow Y
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	move.w	wd_TopEdge(a0),d3
	ext.l	d3
	moveq	#0,d2
	ret

L_IwindowWidth:		;=Iwindow Width(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIwin
	beq	L_NoWin
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Width(a0),d3
	moveq	#0,d2
	ret

L_IwindowWidthWB:	;=Iwindow Width Wb(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Width(a0),d3
	moveq	#0,d2
	ret

L_CurIwindowWidth:	;=Iwindow Width
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Width(a0),d3
	moveq	#0,d2
	ret

L_IwindowHeight:	;=Iwindow Height(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIwin
	beq	L_NoWin
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Width(a0),d3
	moveq	#0,d2
	ret

L_IwindowHeightWB:	;=Iwindow Height Wb(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Width(a0),d3
	moveq	#0,d2
	ret

L_CurIwindowHeight:	;=Iwindow Height
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Height(a0),d3
	moveq	#0,d2
	ret

L_IwindowActWidth:	;=Iwindow Actual Width
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Width(a0),d3
	moveq	#0,d0
	move.b	wd_BorderLeft(a0),d0
	sub.w	d0,d3
	move.b	wd_BorderRight(a0),d0
	sub.w	d0,d3
	moveq	#0,d2
	ret

L_IwindowActHeight:	;=Iwindow Actual Height
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	moveq	#0,d3
	move.w	wd_Height(a0),d3
	moveq	#0,d0
	move.b	wd_BorderTop(a0),d0
	sub.w	d0,d3
	move.b	wd_BorderBottom(a0),d0
	sub.w	d0,d3
	moveq	#0,d2
	ret

L_IwindowBase:		;=Iwindow Base
	pstart
	moveq	#0,d2
	jtcall	GetCurIwin2
	move.l	d0,d3
	ret

L_IwindowActivate:	;Iwindow Activate n
	pstart
	move.l	(a3)+,d0
	beq	.bkwin
	jtcall	FindIwin
	move.l	d0,a0
	bra	.setwin
.bkwin	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
.setwin	tmove.l	a0,CurIwindow
	intcall	ActivateWindow
	ret

L_IwindowActivateWB:	;Iwindow Activate Wb n
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	tmove.l	d0,CurIwindow
	move.l	d0,a0
	intcall	ActivateWindow
	ret

L_IwindowActive:	;=Iwindow Active
	pstart
	moveq	#0,d2
	jtcall	GetActiveWin
	move.l	d0,a0
	move.l	wd_UserData(a0),d0
	beq	.no
	move.l	d0,a0
	cmp.l	#WE_MAGIC,we_MagicID(a0)
	bne	.no
.yes	moveq	#-1,d3
	ret
.no	moveq	#0,d3
	ret

L_IwindowActiveNum:	;=Iwindow Active Num
	pstart
	jtcall	GetActiveWin
	move.l	d0,a0
	move.l	wd_UserData(a0),a0
	move.l	we_WinNum(a0),d3
	moveq	#0,d2
	ret

L_IwindowActiveBase:	;=Iwindow Active Base
	pstart
	jtcall	GetActiveWin
	move.l	d0,d3
	moveq	#0,d2
	ret

L_IwindowStatus:	;=Iwindow Status(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIwin
	beq	L_NoWin
	move.l	d0,a2
	move.l	wd_UserPort(a2),a0
	jtcall	DoEvent			;If close gadget clicked, catch it
	move.l	a2,a0
	jtcall	GetSomeWinFlags
	move.l	d0,d3
	and.l	#WEF_CLOSED|WEF_MENUACTIVE,d3	;Legal flags to return
	moveq	#0,d2
	ret

L_IwindowStatusWB:	;=Iwindow Status Wb(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindWBIwin
	beq	L_NoWin
	move.l	d0,a2
	move.l	wd_UserPort(a2),a0
	jtcall	DoEvent			;If close gadget clicked, catch it
	move.l	a2,a0
	jtcall	GetSomeWinFlags
	move.l	d0,d3
	and.l	#WEF_CLOSED|WEF_MENUACTIVE,d3
	moveq	#0,d2
	ret

L_CurIwindowStatus:	;=Iwindow Status
	pstart
	jtcall	GetWinFlags
	move.l	d0,d3
	and.l	#WEF_CLOSED|WEF_MENUACTIVE,d3
	moveq	#0,d2
	ret

L_SetIwindowTitle:	;Set Iwindow Title [n],[win$],[scr$]
	pstart
	move.l	(a3)+,d5
	cmp.l	#Null,d5
	bne	.snonul
	moveq	#-1,d5
.snonul	move.l	(a3)+,d2
	cmp.l	#Null,d2
	bne	.wnonul
	moveq	#-1,d2
.wnonul	move.l	(a3)+,d0
	cmp.l	#Null,d0
	beq	.curwin
	jtcall	FindIwin
	beq	L_NoWin
	move.l	d0,d3
	bra	.wtitle
.curwin	dmove.l	CurIwindow,d3
	beq	L_NoWin
.wtitle	cmp.l	#-1,d2
	beq	.stitle
	move.l	d2,a2
	moveq	#0,d0
	move.w	(a2)+,d0
	beq	.wempty
	move.l	d0,d4
	jtcall	StrAlloc
	exg	d0,a2
	move.l	a2,a1
	move.l	d0,a0
	move.l	d4,d0
	syscall	CopyMem
	clr.b	(a2,d4.l)
	move.l	a2,d2
	bra	.stitle
.wempty	mvoeq	#0,d2
.stitle	cmp.l	#-1,d5
	beq	.set
	move.l	d5,a2
	moveq	#0,d0
	move.w	(a2)+,d0
	beq	.sempty
	move.l	d0,d4
	jtcall	StrAlloc
	exg	d0,a2
	move.l	a2,a1
	move.l	d0,a0
	move.l	d4,d0
	syscall	CopyMem
	clr.b	(a2,d4.l)
	move.l	a2,d5
	bra	.set
.sempty	mvoeq	#0,d5
.set	move.l	d3,a0
	move.l	d2,a1
	move.l	d5,a2
	intcall	SetWindowTitles
	ret
