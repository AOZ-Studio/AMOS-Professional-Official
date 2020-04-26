;Font stuff

L_ItextBase:			;=Itext Base
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	move.l	rp_Font(a0),a0
	moveq	#0,d3
	move.w	tf_Baseline(a0),d3
	moveq	#0,d2
	ret

L_ItextLength:			;=Itext Length(s$)
	pstart
	jtcall	GetCurRP
	move.l	d0,a1
	move.l	(a3)+,a0
	move.w	(a0)+,d0
	gfxcall	TextLength
	moveq	#0,d3
	move.w	d0,d3
	moveq	#0,d2
	ret

L_SetIfont:			;Set Ifont font$,size
	pstart
	movem.l	a5,-(a7)
	jtcall	GetCurRP
	move.l	d0,a2
	dlea	TextAttr,a5
	move.l	(a3)+,d0
	move.w	d0,ta_YSize(a5)
	move.l	(a3)+,a6
	moveq	#0,d3
	move.w	(a6)+,d3
	move.l	a6,a0
	add.l	d3,a0
	subq.l	#5,a0
	cmp.b	#'.',(a0)+
	bne	.addext
	cmp.b	#'f',(a0)+
	bne	.addext
	cmp.b	#'o',(a0)+
	bne	.addext
	cmp.b	#'n',(a0)+
	bne	.addext
	cmp.b	#'t',(a0)+
	bne	.addext
	move.l	d3,d0
	jtcall	StrAlloc
	move.l	d0,ta_Name(a5)
	move.l	ta_Name(a5),a1
	move.l	d3,d0
	move.l	a6,a0
	syscall	CopyMem
	move.l	ta_Name(a5),a1
	add.l	d3,a1
	clr.b	(a1)
	bra	.open1
.addext	move.l	d3,d0
	addq.l	#5,d0
	jtcall	StrAlloc
	move.l	d0,ta_Name(a5)
	move.l	ta_Name(a5),a1
	move.l	d3,d0
	move.l	a6,a0
	syscall	CopyMem
	move.l	ta_Name(a5),a1
	add.l	d3,a1
	move.b	#'.',(a1)+
	move.b	#'f',(a1)+
	move.b	#'o',(a1)+
	move.b	#'n',(a1)+
	move.b	#'t',(a1)+
	clr.b	(a1)
.open1	move.l	a5,a0
	gfxcall	OpenFont
	tst.l	d0
	bne	.gotfnt
	move.l	a5,a0
	dmove.l	DiskfontBase,a6
	call	OpenDiskFont
	tst.l	d0
	bne	.gotfnt
	move.l	ta_Name(a5),a0
	jtcall	StrFree
	bra	L_NoFont
.gotfnt	move.l	d0,a0
	move.l	a2,a1
	gfxcall	SetFont
	move.l	ta_Name(a5),a0
	jtcall	StrFree
	move.l	rp_RP_User(a2),d0
	beq	.exit
	move.l	d0,a1
	gfxcall	CloseFont
.exit	move.l	rp_Font(a2),rp_RP_User(a2)
	move.l	(a7)+,a5
	ret

L_SetIfont1:			;Set Ifont namesize$
	pstart
	move.l	(a3)+,a0
	move.w	(a0)+,d5
	move.l	a0,a2
	add.w	d5,a0
	move.l	a0,a1
.lp	cmp.l	a0,a2
	beq	L_IllFunc
	cmp.b	#'/',-(a0)
	bne	.lp
	move.l	a0,d6
	addq.l	#1,a0
	moveq	#0,d0
	moveq	#0,d1
.lp2	move.b	(a0)+,d1
	sub.b	#'0',d1
	bmi	L_IllFunc
	cmp.b	#9,d1
	bhi	L_IllFunc
	mulu	#10,d0
	add.w	d1,d0
	cmp.l	a1,a0
	bcs	.lp2
	move.l	d0,d7
	sub.l	a2,d6
	move.l	d6,d0
	lea	.rsc(pc),a1
	jtcall	GetRetStr	;Not really a "return string", but it'll do...
	move.l	a1,-(a7)
	move.l	d0,a1
	move.w	d5,(a1)+
	move.l	d5,d0
	move.l	a2,a0
	syscall	CopyMem
	move.l	(a7)+,-(a3)
	move.l	d7,-(a3)
	bsr	L_SetIfont
	ret
.rsc	ds.b	rsc_sizeof

L_IfontName:
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	move.l	rp_Font(a0),a0
	move.l	10(a0),a0
	lea	.rsc(pc),a1
	jtcall	ReturnString
	ret
.rsc	ds.b	rsc_sizeof

L_IfontBase:
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	move.l	rp_Font(a0),d3
	moveq	#0,d2
	ret

L_IfontHeight:
	pstart
	jtcall	GetCurRP
	move.l	d0,a0
	move.l	rp_Font(a0),a0
	moveq	#0,d3
	move.w	tf_YSize(a0),d3
	moveq	#0,d2
	ret
