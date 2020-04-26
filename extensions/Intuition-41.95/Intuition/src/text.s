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


