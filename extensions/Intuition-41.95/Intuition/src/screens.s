;Screen routines for Intuition extension

;;;;;;;; Display information routines

L_HAM:			;=Ham ($800)
	move.l	#HAM,d3
	moveq	#0,d2
	rts

L_EHB:			;=Ehb ($80)
	move.l	#EHB,d3
	moveq	#0,d2
	rts

L_SuperHires:		;=Superhires ($20)
	move.l	#SUPERHIRES,d3
	moveq	#0,d2
	rts

;=Aga (test for AGA chipset.  Currently checks SysBase->lib_Version >= 39.
;	There must be a better way!)
L_AGA:
	pstart
	dmove.b	IsAGA,d3
	ext.w	d3
	ext.l	d3
	moveq	#0,d2
	ret

;=Ecs - test for ECS chipset.  Only works on systems with KS2.0 or higher;
;	returns False on all others.
L_ECS:
	pstart
	dmove.b	IsECS,d3
	ext.w	d3
	ext.l	d3
	moveq	#0,d2
	ret

L_XHardMin:		;=X Hard Min
	pstart
	dmove.l	ViewLord,a0
	moveq	#0,d3
	move.w	v_DxOffset(a0),d3
	moveq	#0,d2
	ret

L_YHardMin:		;=Y Hard Min
	pstart
	dmove.l	ViewLord,a0
	moveq	#0,d3
	move.w	v_DyOffset(a0),d3
	moveq	#0,d2
	ret


;;;;;;;; Screen control routines

L_IscreenOpen:		;Iscreen Open n,w,h,nc,modes,title$,dispID
	pstart
	jtcall	OpenIscr
	ret

L_IscreenOpenNT:	;Iscreen Open n,w,h,nc,modes,dispID - NOT CALLED
	pstart
	dtst.b	WB20
	beq	L_NeedKick20
	move.l	(a3),d0
	clr.l	(a3)
	move.l	d0,-(a3)
	jtcall	OpenIscr
	ret

L_IscreenOpenNM:	;Iscreen Open n,w,h,nc,modes,title$
	pstart
	dtst.b	WB20
	beq	.nomode
	dtst.b	IsNTSC
	bne	.ntsc
	move.l	#PAL_MONITOR_ID,-(a3)
	bra	.open
.ntsc	move.l	#NTSC_MONITOR_ID,-(a3)
	bra	.open
.nomode	clr.l	-(a3)
.open	jtcall	OpenIscr
	ret

L_IscreenOpen0:		;Iscreen Open n,w,h,nc,modes
	clr.l	-(a3)
	bra	L_IscreenOpenNM

L_IscrOpenPublic:	;Iscreen Open Public n,w,h,nc,modes,title$,dispID
	pstart
	dtst.b	WB20
	beq	L_NeedKick20
	tmove.b	#-1,NextPublic
	jtcall	OpenIscr
	ret

L_IscrOpenPubNT:	;Iscreen Open Public n,w,h,nc,modes,dispID - NOT CALLED
	pstart
	dtst.b	WB20
	beq	L_NeedKick20
	move.l	(a3),d0
	clr.l	(a3)
	move.l	d0,-(a3)
	bsr	L_IscrOpenPublic
	ret

L_IscrOpenPubNM:	;Iscreen Open Public n,w,h,nc,modes,title$
	pstart
	dtst.b	WB20
	beq	.nomode
	dtst.b	IsNTSC
	bne	.ntsc
	move.l	#PAL_MONITOR_ID,-(a3)
	bra	.open
.ntsc	move.l	#NTSC_MONITOR_ID,-(a3)
	bra	.open
.nomode	clr.l	-(a3)
.open	bsr	L_IscrOpenPublic
	ret

L_IscrOpenPub0:		;Iscreen Open Public n,w,h,nc,modes
	clr.l	-(a3)
	bra	L_IscrOpenPubNM

L_IscrOpenBack:		;Iscreen Open Back
	pstart
	tmove.b	#-1,ScrOpenBehind
	ret

L_IscrOpenFront:	;Iscreen Open Front
	pstart
	dclr.b	ScrOpenBehind
	ret

L_IscreenClose:		;Iscreen Close n
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	jtcall	CloseIscr
	ret

L_IscreenGet:		;=Iscreen
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_ScrNum(a0),d3
	moveq	#0,d2
	ret

L_IscreenSet:		;Set Iscreen n
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	dtst.b	CurIwindowIsWB
	beq	.custom
	dmove.l	CurIwindow,d0
	tmove.l	d0,LastActiveWB
	bra	.setcur
.custom	dmove.l	CurIscreen,a1
	move.l	sc_UserData(a1),a1
	dmove.l	CurIwindow,se_LastActive(a1)
.setcur	tmove.l	a0,CurIscreen
	dclr.l	CurIwindow
	ret

L_IscrFront:		;Iscreen To Front n
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	intcall	ScreenToFront
	ret

L_CurIscrFront:		;Iscreen To Front
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	intcall	ScreenToFront
	ret

L_IscrBack:		;Iscreen To Back n
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	intcall	ScreenToBack
	ret

L_CurIscrBack:		;Iscreen To Back
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	intcall	ScreenToBack
	ret

L_IscreenBase:		;Iscreen Base
	pstart
	dmove.l	CurIscreen,d3
	moveq	#0,d2
	ret

L_IscreenDisp:		;Iscreen Display n,x,y,w,h
	pstart
	movem.l	(a3)+,d2-d6
	move.l	d6,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	d0,a2
.x	cmp.l	#Null,d5
	bne	.xhere
	cmp.l	#Null,d4
	beq	.wid
	moveq	#0,d5
	bra	.yhere
.xhere	tst.w	d5
	bpl	.xpos
	moveq	#0,d5
.xpos	sub.w	sc_LeftEdge(a2),d5
.y	cmp.l	#Null,d4
	bne	.yhere
	moveq	#0,d4
	bra	.move
.yhere	tst.w	d4
	bpl	.ypos
	moveq	#0,d4
.ypos	sub.w	sc_TopEdge(a2),d4
.move	move.w	d5,d0
	move.w	d4,d1
	move.l	a2,a0
	intcall	MoveScreen
.wid	move.l	sc_UserData(a2),a0
	cmp.l	#Null,d3
	bne	.where
	cmp.l	#Null,d2
	beq	.exit
	bra	.hhere
.where	dcmp.w	MaxDispWidth,d3
	bhi	L_IllFunc
	cmp.w	se_Width(a0),d3
	bhi	L_IllFunc
	move.w	d3,sc_Width(a2)
	move.w	d3,sc_ViewPort+vp_DWidth(a2)
.hgt	cmp.l	#Null,d2
	beq	.set
.hhere	dcmp.w	MaxDispHeight,d2
	bhi	L_IllFunc
	cmp.w	se_Height(a0),d3
	bhi	L_IllFunc
	move.w	d2,sc_Height(a2)
	move.w	d3,sc_ViewPort+vp_DHeight(a2)
.set	move.l	a2,a0
	intcall	MakeScreen
.exit	ret

L_IscreenOfs:		;Iscreen Offset n,x,y
	pstart
	movem.l	(a3)+,d2-d4
	move.l	d4,d0
	jtcall	FindIscr		;get screen to A0
	beq	L_NoScr
	lea	sc_ViewPort(a0),a2
	move.l	vp_RasInfo(a2),a1
.x	cmp.l	#Null,d3
	beq	.y
	move.w	d3,ri_RxOffset(a1)
.y	cmp.l	#Null,d2
	beq	.set
	move.w	d2,ri_RyOffset(a1)
.set	move.l	a0,a2
	intcall	MakeScreen
	move.l	a2,a0
	moveq	#0,d0
	moveq	#0,d1
	intcall	MoveScreen		;kludge
	ret

L_GetIscrWidth:		;=Iscreen Width(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	moveq	#0,d3
	move.w	se_Width(a0),d3
	moveq	#0,d2
	ret

L_GetCISWidth:		;=Iscreen Width
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	moveq	#0,d3
	move.w	se_Width(a0),d3
	moveq	#0,d2
	ret

L_GetIscrHeight:	;=Iscreen Height(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	moveq	#0,d3
	move.w	se_Height(a0),d3
	moveq	#0,d2
	ret

L_GetCISHeight:		;=Iscreen Height
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	moveq	#0,d3
	move.w	se_Height(a0),d3
	moveq	#0,d2
	ret

L_GetIscrCols:		;=Iscreen Colour(n)
	pstart
	move.l	(a3)+,d2
	move.l	d2,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	d0,a6
	move.l	d2,-(a3)
	bsr	L_GetIscrMode
	and.w	#HAM,d3
	bne	.ham
	moveq	#1,d3
	moveq	#0,d2
	move.b	sc_Depth(a6),d2
	lsl.l	d2,d3
	bra	.done
.ham	cmp.b	#8,sc_Depth(a6)
	bne	.ham6
	move.l	#262144,d3
	bra	.done
.ham6	move.l	#4096,d3
.done	moveq	#0,d2
	ret

L_GetCISCols:		;=Iscreen Colour
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_ScrNum(a0),-(a3)
	bsr	L_GetIscrCols
	ret

L_GetIscrMode:		;=Iscreen Mode(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	d0,a0
	moveq	#0,d3
	move.w	sc_ViewModes(a0),d3
	and.w	#MODES,d3
	moveq	#0,d2
	ret

L_GetCISMode:		;=Iscreen Mode
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	moveq	#0,d3
	move.w	sc_ViewModes(a0),d3
	and.w	#MODES,d3
	moveq	#0,d2
	ret

L_IscreenCopy:		;Iscreen Copy a,x1,y1,x2,y2 To b,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	lea	sc_BitMap(a0),a2
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	sub.w	d1,d5
	sub.w	d0,d4
	addq.w	#1,d5
	addq.w	#1,d4
	movem.w	d0-d1,-(a7)
	move.l	(a3)+,d0
	jtcall	FindIscr
	movem.w	(a7)+,d0-d1
	beq	L_NoScr
	lea	sc_BitMap(a0),a0
	move.l	a2,a1
	move.b	#$C0,d6
	moveq	#-1,d7
	gfxcall	WaitBlit
	call	BltBitMap
	ret

L_IscreenCopy2:		;Iscreen Copy a To b
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	lea	sc_BitMap(a0),a2
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.w	sc_Width(a0),d4
	move.w	sc_Height(a0),d5
	lea	sc_BitMap(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	a2,a1
	moveq	#0,d2
	moveq	#0,d3
	move.b	#$C0,d6
	moveq	#-1,d7
	gfxcall	WaitBlit
	call	BltBitMap
	ret


L_XIhard:		;=X Ihard(x)
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	dmove.l	ViewLord,a1
	move.l	(a3)+,d3
	move.w	sc_ViewPort+vp_Modes(a0),d1
	moveq	#SUPERHIRES,d2
	and.w	d1,d2
	beq	.hires
	lsr.w	#2,d3
	bra	.add
.hires	move.w	#HIRES,d2
	and.w	d1,d2
	beq	.add
	lsr.w	#1,d3
.add	add.w	v_DxOffset(a1),d3
	moveq	#0,d2
	ret

L_XIscreen:		;=X Iscreen(x)
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	dmove.l	ViewLord,a1
	move.l	(a3)+,d3
	sub.w	v_DxOffset(a1),d3
	move.w	sc_ViewPort+vp_Modes(a0),d1
	moveq	#SUPERHIRES,d2
	and.w	d1,d2
	beq	.hires
	lsl.w	#2,d3
	bra	.done
.hires	move.w	#HIRES,d2
	and.w	d1,d2
	beq	.done
	lsl.w	#1,d3
.done	moveq	#0,d2
	ret

L_YIhard:		;=Y Ihard(y)
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	dmove.l	ViewLord,a1
	move.l	(a3)+,d3
	moveq	#LACED,d1
	and.w	sc_ViewPort+vp_Modes(a0),d1
	beq	.add
	lsr.w	#1,d3
.add	add.w	v_DyOffset(a1),d3
	moveq	#0,d2
	ret

L_YIscreen:		;=Y Iscreen(y)
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	dmove.l	ViewLord,a1
	move.l	(a3)+,d3
	sub.w	v_DyOffset(a1),d3
	moveq	#LACED,d1
	and.w	sc_ViewPort+vp_Modes(a0),d1
	beq	.done
	lsl.w	#1,d3
.done	moveq	#0,d2
	ret

L_AmosIscrCopy:		;Amos Iscreen Copy a,x1,y1,x2,y2 To b,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	lea	sc_BitMap(a0),a2
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	sub.w	d1,d5
	sub.w	d0,d4
	addq.w	#1,d5
	addq.w	#1,d4
	movem.w	d0-d1,-(a7)
	move.l	(a3)+,d0
	jtcall	FindAscr
	movem.w	(a7)+,d0-d1
	beq	L_NoScr
	move.l	a0,a1
	dlea	TempBitMap,a0
	moveq	#EcMaxPlans,d6
	subq.w	#1,d6
	move.w	d6,d7
	lsl.w	#2,d7
.bmlp	move.l	EcCurrent(a1,d7.w),bm_Planes(a0,d7.w)
	subq.w	#4,d7
	dbra	d6,.bmlp
	move.w	EcTx(a1),d6
	lsr.w	#3,d6			;AMOS screen width always 16n
	move.w	d6,bm_BytesPerRow(a0)
	move.w	EcTy(a1),bm_Rows(a0)
	clr.b	bm_Flags(a0)
	move.w	EcNPlan(a1),d6
	move.b	d6,bm_Depth(a0)
	move.l	a2,a1
	move.b	#$C0,d6
	moveq	#-1,d7
	gfxcall	WaitBlit
	call	BltBitMap
	ret

L_AmosIscrCopy2:	;Amos Iscreen Copy a To b
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	lea	sc_BitMap(a0),a2
	move.l	(a3)+,d0
	jtcall	FindAscr
	beq	L_NoScr
	move.l	a0,a1
	dlea	TempBitMap,a0
	moveq	#EcMaxPlans,d6
	subq.w	#1,d6
	move.w	d6,d7
	lsl.w	#2,d7
.bmlp	move.l	EcCurrent(a1,d7.w),bm_Planes(a0,d7.w)
	subq.w	#4,d7
	dbra	d6,.bmlp
	move.w	EcTx(a1),d4
	move.w	d4,d6
	lsr.w	#3,d6
	move.w	d6,bm_BytesPerRow(a0)
	move.w	EcTy(a1),d5
	move.w	d5,bm_Rows(a0)
	clr.b	bm_Flags(a0)
	move.w	EcNPlan(a1),d6
	move.b	d6,bm_Depth(a0)
	moveq	#0,d0
	moveq	#0,d1
	move.l	a2,a1
	moveq	#0,d2
	moveq	#0,d3
	move.b	#$C0,d6
	moveq	#-1,d7
	gfxcall	WaitBlit
	call	BltBitMap
	ret


L_IscrAmosCopy:		;Iscreen Amos Copy a,x1,y1,x2,y2 To b,x,y
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	jtcall	FindAscr
	beq	L_NoScr
	dlea	TempBitMap,a1
	moveq	#EcMaxPlans,d6
	subq.w	#1,d6
	move.w	d6,d7
	lsl.w	#2,d7
.bmlp	move.l	EcCurrent(a0,d7.w),bm_Planes(a1,d7.w)
	subq.w	#4,d7
	dbra	d6,.bmlp
	move.w	EcTx(a0),d6
	lsr.w	#3,d6
	move.w	d6,bm_BytesPerRow(a1)
	move.w	EcTy(a0),bm_Rows(a1)
	clr.b	bm_Flags(a1)
	move.w	EcNPlan(a0),bm_Depth(a1)
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	sub.w	d1,d5
	sub.w	d0,d4
	addq.w	#1,d5
	addq.w	#1,d4
	movem.l	d0-d1/a1,-(a7)
	move.l	(a3)+,d0
	jtcall	FindIscr
	movem.l	(a7)+,d0-d1/a1
	beq	L_NoScr
	lea	sc_BitMap(a0),a0
	move.b	#$C0,d6
	moveq	#-1,d7
	gfxcall	WaitBlit
	call	BltBitMap
	call	WaitBlit	;Need to call WaitBlit() after BltBitMap()
				;  because AMOS might not
	ret

L_IscrAmosCopy2:	;Iscreen Amos Copy a To b
	pstart
	move.l	(a3)+,d0
	jtcall	FindAscr
	beq	L_NoScr
	dlea	TempBitMap,a1
	moveq	#EcMaxPlans-1,d6
	move.w	d6,d7
	lsl.w	#2,d7
.bmlp	move.l	EcCurrent(a0,d7.w),bm_Planes(a1,d7.w)
	subq.w	#4,d7
	dbra	d6,.bmlp
	move.w	EcTx(a0),d6
	lsr.w	#3,d6
	move.w	d6,bm_BytesPerRow(a1)
	move.w	EcTy(a0),bm_Rows(a1)
	clr.b	bm_Flags(a1)
	move.w	EcNPlan(a0),bm_Depth(a1)
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.w	sc_Width(a0),d4
	move.w	sc_Height(a0),d5
	lea	sc_BitMap(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	dlea	TempBitMap,a1
	moveq	#0,d2
	moveq	#0,d3
	move.b	#$C0,d6
	moveq	#-1,d7
	gfxcall	WaitBlit
	call	BltBitMap
	call	WaitBlit
	ret


L_SetIscrTitle:		;Set Iscreen Title s$,n
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	sc_DefaultTitle(a0),d5
	move.l	a0,d6
	move.l	(a3)+,a2
	moveq	#0,d2
	move.w	(a2)+,d2
	beq	.none
	move.l	d2,d0
	jtcall	StrAlloc
	move.l	d0,a1
	move.l	d0,d7
	move.l	a2,a0
	move.l	d2,d0
	syscall	CopyMem
	move.l	d7,a1
	clr.b	(0,a1,d2.l)
	move.l	d6,a0
	move.l	a1,sc_DefaultTitle(a0)
	moveq	#1,d0
	bra	.finish
.none	move.l	d6,a0
	clr.l	sc_DefaultTitle(a1)
	moveq	#0,d0
.finish	intcall	ShowTitle
	tst.l	d5
	beq	.exit
	move.l	d5,a0
	jtcall	StrFree
.exit	ret

L_SetCurIscrTitle:	;Set Iscreen Title s$
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_DefaultTitle(a0),d5
	move.l	d0,d6
	move.l	(a3)+,a2
	moveq	#0,d2
	move.w	(a2)+,d2
	beq	.none
	move.l	d2,d0
	jtcall	StrAlloc
	move.l	d0,a1
	move.l	d0,d7
	move.l	a2,a0
	move.l	d2,d0
	syscall	CopyMem
	move.l	d7,a1
	clr.b	(0,a1,d2.l)
	move.l	d6,a0
	move.l	a1,sc_DefaultTitle(a0)
	moveq	#1,d0
.none	move.l	d6,a0
	clr.l	sc_DefaultTitle(a0)
	moveq	#0,d0
.finish	intcall	ShowTitle
	tst.l	d5
	beq	.exit
	move.l	d5,a0
	jtcall	StrFree
.exit	ret

L_IscrTitleHeight:	;=Iscreen Title Height(n)
	pstart
	move.l	(a3)+,d0
	jtcall	FindIscr
	beq	L_NoScr
	moveq	#0,d3
	move.b	sc_BarHeight(a0),d3
	moveq	#0,d2
	ret

L_CurIscrTitleHeight:	;=Iscreen Title Height
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	moveq	#0,d3
	move.b	sc_BarHeight(a0),d3
	moveq	#0,d2
	ret
