;Output routines

;;;;;;;; Location

L_Ilocate:			;Ilocate x,y   [text positioning]
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	move.l	rp_Font(a0),a1
	move.l	rp_BitMap(a0),a2
	move.l	(a3)+,d1
	cmp.l	#Null,d1
	beq	.no_y
	swap	d1
	tst.w	d1
	bne	L_IllFunc
	swap	d1
	moveq	#0,d2
	move.w	bm_Rows(a2),d2
	divu	tf_YSize(a1),d2
	cmp.w	d2,d1
	bcc	L_IllFunc
	mulu	tf_YSize(a1),d1
	add.w	tf_Baseline(a1),d1
.no_y	move.l	(a3)+,d0
	cmp.l	#Null,d0
	beq	.no_x
	swap	d0
	tst.w	d0
	bne	L_IllFunc
	swap	d0
	moveq	#0,d2
	move.w	bm_BytesPerRow(a2),d2
	lsl.w	#3,d2
	divu	tf_XSize(a1),d2
	cmp.w	d2,d0
	bcc	L_IllFunc
	mulu	tf_XSize(a1),d0
.no_x	jtcall	SetCoords
	ret

L_IlocateGr:			;Ilocate Gr x,y   [graphics positioning]
				;This function is called all over the place to
				;  set coordinates for drawing operations, so
				;  we need to preserve all registers (except
				;  A3, which we pop arguments off of).
	pstart
	movem.l	d0-d2/a0-a1,-(a7)
	jtcall	GetCurRP
	move.l	d0,a0
	move.l	rp_BitMap(a0),a1
	move.l	(a3)+,d0
      ifd SAFE_GRPOS
	cmp.l	#Null,d0
	beq	.no_y
	swap	d0
	tst.w	d0
	bne	L_IllFunc
	swap	d0
	cmp.w	bm_Rows(a1),d0
	bcc	L_IllFunc
      endc
.no_y	move.l	d0,-(a7)
	move.l	(a3)+,d0
      ifd SAFE_GRPOS
	cmp.l	#Null,d0
	beq	.no_x
	swap	d0
	tst.w	d0
	bne	L_IllFunc
	swap	d0
	move.w	bm_BytesPerRow(a1),d1
	lsl.w	#3,d1
	cmp.w	d1,d0
	bcc	L_IllFunc
      endc
.no_x	move.l	(a7)+,d1
	jtcall	SetCoords
	movem.l	(a7)+,d0-d2/a0-a1
	ret

L_Ixgr:				;=Ixgr
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	moveq	#0,d3
	move.w	rp_cp_x(a0),d3
	moveq	#0,d2
	ret

L_Iygr:				;=Iygr
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	moveq	#0,d3
	move.w	rp_cp_y(a0),d3
	moveq	#0,d2
	ret


;;;;;;;; Text

L_IgrWriting:		;Igr Writing n
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.l	(a3)+,d0
	gfxcall	SetDrMd
	ret

L_Itext:		;Itext [x],[y],s$
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.l	(a3)+,a0	;string adr
	move.w	(a0)+,d0	;string len
	bsr	L_IlocateGr	;set position
	gfxcall	Text
	ret

L_Icentre:		;Icentre s$
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a2
	move.l	wd_RPort(a2),a1
	move.l	(a3),a0		;string adr (save on A3 for now)
	move.w	(a0),d0		;string len
	gfxcall	TextLength	;Calculate X position and set CP
	move.w	d0,d1
	move.w	wd_Width(a2),d0
	sub.w	d1,d0
	lsr.w	#1,d0
	move.l	a2,a0
	move.l	#Null,d1
	jtcall	SetCoords
	move.l	wd_RPort(a2),a1	;Now write string
	move.l	(a3)+,a0
	move.w	(a0)+,d0
	gfxcall	Text
	ret

L_Iwrite:		;Iwrite s$
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	jtcall	GetWinFlags
	btst	#WEB_UNSET,d0
	beq	.set
	moveq	#0,d0
	moveq	#0,d1
	move.w	rp_TxBaseline(a2),d1
	jtcall	SetCoords
.set	move.l	(a3)+,a0
	move.w	(a0)+,d0
	move.l	a2,a1
	gfxcall	Text
	jtcall	GetCurWin
	move.l	d0,a1
	moveq	#0,d0
	move.w	wd_Height(a1),d0
	moveq	#0,d2
	move.b	wd_BorderTop(a1),d2
	sub.w	d2,d0
	move.b	wd_BorderBottom(a1),d2
	sub.w	d2,d0
	divu	rp_TxHeight(a2),d0
	moveq	#0,d1
	move.w	rp_cp_y(a2),d1
	move.b	wd_BorderTop(a1),d2
	sub.w	d2,d1
	divu	rp_TxHeight(a2),d1
	addq.w	#1,d1
	cmp.w	d0,d1
	bcs	.noscrl
	moveq	#0,d2
	move.b	wd_BorderLeft(a1),d2
	moveq	#0,d3
	move.b	wd_BorderTop(a1),d3
	moveq	#0,d0
	move.w	wd_Width(a1),d4
	move.b	wd_BorderRight(a1),d0
	sub.w	d0,d4
	subq.w	#1,d4
	move.w	wd_Height(a1),d5
	move.b	wd_BorderBottom(a1),d0
	sub.w	d0,d5
	subq.w	#1,d5
	moveq	#0,d0
	move.w	rp_TxHeight(a2),d1
	move.l	a2,a1
	call	ScrollRaster
	bra	.setx
.noscrl	move.w	rp_TxHeight(a2),d1
	moveq	#0,d0
	jtcall	SetCoordsRel
.setx	moveq	#0,d0
	move.l	#Null,d1
	jtcall	SetCoords
.exit	ret

L_Iwrite0:		;Iwrite
	pstart
	dlea	NullStr,a0
	move.l	a0,-(a3)
	bsr	L_Iwrite
	ret


;;;;;;;; Graphics

L_Icls:			;Icls
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
	move.l	wd_RPort(a0),a1
	moveq	#0,d0
	gfxcall	SetRast
	ret

L_IclsCol:		;Icls colour
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
	move.l	wd_RPort(a0),a1
	move.l	(a3)+,d0
	gfxcall	SetRast
	ret

L_IclsXY:		;Icls colour,x1,y1 To x2,y2
	pstart
	jtcall	GetCurIscr
	move.l	d0,a1
	move.l	sc_UserData(a1),a1
	move.l	se_BaseWin(a1),a0
	move.l	wd_RPort(a0),a2
	move.b	rp_FgPen(a0),d7
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d6
	cmp.l	d4,d2
	blt	L_MixedCoords
	cmp.l	d5,d3
	blt	L_MixedCoords
      ifd SAFE_GRPOS
	tst.l	d4
	bmi	L_IllFunc
	tst.l	d5
	bmi	L_IllFunc
	moveq	#0,d0
	move.w	se_Width(a1),d0
	cmp.l	d0,d2
	bge	L_IllFunc
	move.w	se_Height(a1),d0
	cmp.l	d0,d3
	bge	L_IllFunc
      endc
	move.b	d6,d0
	move.l	a2,a1
	gfxcall	SetAPen
	move.l	d4,d0
	move.l	d5,d1
	move.l	a2,a1
	call	RectFill
	move.b	d7,d0
	move.l	a2,a1
	call	SetAPen
	ret

L_Iclw:			;Iclw
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	move.b	rp_FgPen(a2),d7
	move.l	a2,a1
	moveq	#0,d0
	gfxcall	SetAPen
	jtcall	GetCurWin
	move.l	d0,a1
	moveq	#0,d0
	move.b	wd_BorderLeft(a1),d0
	moveq	#0,d1
	move.b	wd_BorderTop(a1),d1
	moveq	#0,d4
	move.w	wd_Width(a0),d2
	move.b	wd_BorderRight(a0),d4
	sub.w	d4,d2
	subq.w	#1,d2
	move.w	wd_Height(a0),d3
	move.b	wd_BorderBottom(a0),d4
	sub.w	d4,d3
	subq.w	#1,d3
	move.l	a2,a1
	gfxcall	RectFill
	move.l	a2,a1
	move.b	d7,d0
	gfxcall	SetAPen
	ret

L_IclwCol:		;Iclw colour
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	move.b	rp_FgPen(a2),d7
	move.l	a2,a1
	move.l	(a3)+,d0
	gfxcall	SetAPen
	jtcall	GetCurWin
	move.l	d0,a1
	moveq	#0,d0
	move.b	wd_BorderLeft(a1),d0
	moveq	#0,d1
	move.b	wd_BorderTop(a1),d1
	move.w	wd_Width(a0),d2
	moveq	#0,d4
	move.b	wd_BorderRight(a0),d4
	sub.w	d4,d2
	subq.w	#1,d2
	move.w	wd_Height(a0),d3
	move.b	wd_BorderBottom(a0),d4
	sub.w	d4,d3
	subq.w	#1,d3
	move.l	a2,a1
	gfxcall	RectFill
	move.l	a2,a1
	move.b	d7,d0
	gfxcall	SetAPen
	ret

L_IclwXY:		;Iclw colour,x1,y1 To x2,y2
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a1
	move.l	wd_RPort(a1),a2
	move.b	rp_FgPen(a2),d7
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d6
	cmp.l	d4,d2
	blt	L_MixedCoords
	cmp.l	d5,d3
	blt	L_MixedCoords
      ifd SAFE_GRPOS
	tst.l	d4
	bmi	L_IllFunc
	tst.l	d5
	bmi	L_IllFunc
	moveq	#0,d1
	moveq	#0,d0
	move.w	wd_Width(a5),d0
	move.b	wd_LeftBorder(a5),d1
	sub.w	d1,d0
	move.b	wd_RightBorder(a5),d1
	sub.w	d1,d0
	cmp.l	d0,d2
	bge	L_IllFunc
	move.w	wd_Height(a5),d0
	move.b	wd_TopBorder(a5),d1
	sub.w	d1,d0
	move.b	wd_BottomBorder(a5),d1
	sub.w	d1,d0
	cmp.l	d0,d3
	bge	L_IllFunc
      endc
	moveq	#0,d0
	move.b	wd_BorderLeft(a1),d0
	add.w	d0,d2
	add.w	d0,d4
	move.b	wd_BorderTop(a1),d0
	add.w	d0,d3
	add.w	d0,d5
	move.b	d6,d0
	move.l	a2,a1
	gfxcall	SetAPen
	move.l	d4,d0
	move.l	d5,d1
	move.l	a2,a1
	call	RectFill
	move.b	d7,d0
	move.l	a2,a1
	call	SetAPen
	ret

L_SetInk:		;Iink fg,bg,ol
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	move.l	(a3)+,d0
	move.b	d0,rp_AOLPen(a2)
	move.l	a2,a1
	move.l	(a3)+,d0
	gfxcall	SetBPen
	move.l	a2,a1
	move.l	(a3)+,d0
	call	SetAPen
	ret

L_SetInk2:		;Iink fg,bg
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	move.l	a2,a1
	move.l	(a3)+,d0
	gfxcall	SetBPen
	move.l	a2,a1
	move.l	(a3)+,d0
	call	SetAPen
	ret

L_SetInk1:		;Iink fg
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.l	(a3)+,d0
	gfxcall	SetAPen
	ret

L_IplotInk:		;Iplot x,y,c
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	move.l	a2,a1
	move.l	(a3)+,d0
	gfxcall	SetAPen
	move.l	(a3),d1
	move.l	4(a3),d0
	move.l	a2,a1
	bsr	L_IlocateGr
	jtcall	WritePixel
	ret

L_Iplot:		;Iplot x,y
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.l	(a3),d1
	move.l	4(a3),d0
	bsr	L_IlocateGr
	jtcall	WritePixel
	ret

L_Idraw:		;Idraw x1,y1 To x2,y2
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d0
	move.w	rp_cp_y(a1),d1
	bsr	L_IlocateGr
	gfxcall	Draw
	ret

L_IdrawTo:		;Idraw To x,y
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.w	rp_cp_x(a1),d2
	move.w	rp_cp_y(a1),d3
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d0
	move.w	rp_cp_y(a1),d1
	move.w	d2,rp_cp_x(a1)
	move.w	d3,rp_cp_y(a1)
	gfxcall	Draw
	ret

L_Ibox:			;Ibox x1,y1 To x2,y2
	pstart
	jtcall	GetCurRP
	move.l	d0,a2
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d4
	move.w	rp_cp_y(a1),d5
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d2
	move.w	rp_cp_y(a1),d3
	move.w	d4,d0
	move.w	d3,d1
	move.l	a2,a1
	gfxcall	Draw
	move.w	d4,d0
	move.w	d5,d1
	move.l	a2,a1
	call	Draw
	move.w	d2,d0
	move.w	d5,d1
	move.l	a2,a1
	call	Draw
	move.w	d2,d0
	move.w	d3,d1
	move.l	a2,a1
	call	Draw
	ret

L_Ibar:			;Ibar x1,y1 To x2,y2
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d2
	move.w	rp_cp_y(a1),d3
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d0
	move.w	rp_cp_y(a1),d1
	gfxcall	RectFill
	ret

L_Iellipse:		;Iellipse cx,cy,rx,ry
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	bsr	L_IlocateGr
	move.w	rp_cp_x(a1),d0
	move.w	rp_cp_y(a1),d1
	gfxcall	DrawEllipse
	ret

L_Icircle:		;Icircle cx,cy,r
	move.l	(a3),d0
	move.l	d0,-(a3)
	bra	L_Iellipse

L_IpasteIcon:		;Ipaste Icon x,y,n
	pstart
	move.l	a5,-(a7)
	jtcall	GetCurRP
	move.l	d0,a2
	move.l	(a3)+,d0
	jtcall	FindIcon
	beq	L_NoIcon
	bsr	L_IlocateGr
	move.l	a0,d0			;If icon is empty, just quit
	beq	.exit
	exg	a1,a2
	move.l	a0,a5
	lea	.tempbm(pc),a0		;Set up a temporary bitmap
	move.w	(a5)+,d0
	lsl.w	#1,d0
	move.w	d0,bm_BytesPerRow(a0)
	move.w	(a5)+,bm_Rows(a0)
	move.w	(a5)+,d2
	move.b	d2,bm_Depth(a0)
	addq.l	#4,a5			;A5 now points to image data
	mulu	bm_Rows(a0),d0
	lea	bm_Planes(a0),a0
	subq.w	#1,d2
.bplp	move.l	a5,(a0)+
	add.l	d0,a5
	dbra	d2,.bplp
	lea	.tempbm(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	rp_cp_x(a1),d2
	move.w	rp_cp_y(a1),d3
	move.w	.tempbm+bm_BytesPerRow(pc),d4
	lsl.w	#3,d4
	move.w	.tempbm+bm_Rows(pc),d5
	move.l	a2,d7
	bne	.mask
	move.b	#$C0,d6
	gfxcall	BltBitMapRastPort
	bra	.finish
.mask	addq.l	#4,a2
	move.b	#$E0,d6
	gfxcall	BltMaskBitMapRastPort	
.finish	gfxcall	WaitBlit
.exit	move.l	(a7)+,a5
	ret
.tempbm	ds.b	bm_sizeof

;	include "flood.s"	;Iflood - a BIG set of routines
