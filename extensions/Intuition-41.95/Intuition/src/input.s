;Input routines

L_IbufReset:		;Iclear All
	pstart
	dmove.l	KeyBufPtr,a0
	tmove.l	a0,KeyBufNext
	dmove.l	MenuBufPtr,a0
	tmove.l	a0,MenuBufNext
	ret

L_IbufResetKey:		;Iclear Key
	pstart
	dmove.l	KeyBufPtr,a0
	tmove.l	a0,KeyBufNext
	ret

L_IbufResetMouse:	;Iclear Mouse - now a no-op
	rts

L_IbufResetMenu:	;Iclear Menu
	pstart
	dmove.l	MenuBufPtr,a0
	tmove.l	a0,MenuBufNext
	ret


L_IwaitKey:		;Iwait Key
	pstart
	jtcall	GetCurInput
	move.l	d0,a2
.lp	move.l	a2,a0
	jtcall	GetKey
	beq	.lp
	ret

L_IwaitMouse:		;Iwait Mouse
	pstart
	jtcall	GetCurInput
	move.l	d0,a2
.lp	move.l	a2,a0
	jtcall	GetMouse
	beq	.lp
	ret

L_Iscan:		;=Iscan
	pstart
	moveq	#0,d3
	dmove.w	LastCode,d3
	moveq	#0,d2
	ret

L_Ishift:		;=Ishift
	pstart
	moveq	#0,d3
	dmove.w	LastQual,d3
	moveq	#0,d2
	ret

L_ImouseKey:		;=Imouse Key
	pstart
	jtcall	GetCurInput
	move.l	d0,a0
	jtcall	GetMouse
	moveq	#0,d3
	dmove.b	MouseState,d3
	moveq	#0,d2
	ret

L_ImouseX:		;=Imouse X
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	move.w	wd_MouseX(a0),d3
	moveq	#0,d0
	move.b	wd_BorderLeft(a0),d0
	sub.w	d0,d3
	ext.l	d3
	moveq	#0,d2
	ret

L_ImouseY:		;=Imouse Y
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	move.w	wd_MouseY(a0),d3
	moveq	#0,d0
	move.b	wd_BorderTop(a0),d0
	sub.w	d0,d3
	ext.l	d3
	moveq	#0,d2
	ret

L_GetChar:		;=Iget$
	pstart
	jtcall	GetCurInput
	move.l	d0,a0
	jtcall	GetKey
	beq	.nokey
	dlea	String1,a0
	move.b	d0,2(a0)
	bra	.done
.nokey	dlea	NullStr,a0
.done	move.l	a0,d3
	moveq	#2,d2
	ret

L_ReadChar:		;=Iread Char$
	pstart
	jtcall	GetCurInput
	move.l	d0,a2
.lp	move.l	a2,a0
	jtcall	GetKey
	bne	.endlp
	gfxcall	WaitTOF
	bra	.lp
.endlp	dlea	String1,a0
	move.b	d0,2(a0)
	move.l	a0,d3
	moveq	#2,d2
	ret

L_ReadStr:		;=Iread Str$
	pstart
	move.l	a5,-(a7)
	moveq	#0,d2		;# of characters read
	move.w	#256,d3		;Buffer expansion block size
	move.w	d3,d4		;Current buffer size
	move.w	d3,d5		;Chars remaining in current buffer block
	sub.w	d3,a7
	jtcall	GetCurInput
	move.l	d0,a2
	jtcall	GetCurRP
	move.l	d0,a5
.lp	move.l	a2,a0
	jtcall	GetKey
	bne	.gotkey
	gfxcall	WaitTOF
	bra	.lp
.gotkey	move.b	d0,d7		;0 returned if window closed
	beq	.cancel
	cmp.b	#13,d7
	beq	.endlp
	cmp.b	#10,d7
	beq	.endlp
	cmp.b	#8,d7
	beq	.bksp
	lea	0(a7,d2.l),a0
	move.b	d7,(a0)
	moveq	#1,d0
	move.l	a5,a1
	gfxcall	Text
	addq.w	#1,d2
	subq.w	#1,d5
	bne	.lp
	move.w	d3,d5
	add.w	d3,d4
	move.l	a7,a0
	sub.w	d3,a7
	move.l	a7,a1
	move.l	d2,d0
	syscall	CopyMem
	bra	.lp
.bksp	move.l	d2,d0
	beq	.lp
	subq.w	#1,d2
	moveq	#0,d0
	move.b	0(a7,d2.l),d0
	move.l	rp_Font(a5),a0
	sub.b	tf_LoChar(a0),d0
	move.l	tf_CharSpace(a0),d1
	beq	.nospc
	move.l	d1,a0
	lsl.w	#1,d0
	move.w	d0,d7
	move.w	0(a0,d0.w),d0
	move.l	tf_CharKern(a0),d1
	beq	.gotspc
	move.l	d1,a0
	add.w	0(a0,d7.w),d0
	bra	.gotspc
.nospc	move.w	tf_XSize(a0),d0
.gotspc	sub.w	d0,rp_cp_x(a5)
	move.w	rp_cp_x(a5),-(a7)
	moveq	#RP_COMPLEMENT,d0
	move.l	a5,a1
	call	SetDrMd
	lea	2(a7,d2.l),a0
	moveq	#1,d0
	move.l	a5,a1
	call	Text
	moveq	#RP_JAM2,d0
	move.l	a5,a1
	call	SetDrMd
	move.w	(a7)+,rp_cp_x(a5)
	bra	.lp
.endlp	clr.b	0(a7,d2.l)
	move.l	a7,a0
	lea	.rsc(pc),a1
	jtcall	ReturnString
	add.w	d4,a7
	bra	.done
.cancel	dlea	NullStr,a0
	move.l	a0,d3
	moveq	#2,d2
.done	move.l	(a7)+,a5
	ret
.rsc	ds.b	rsc_sizeof

L_ReadInt:		;=Iread Int
	pstart
	movem.l	a3/a5,-(a7)
	moveq	#0,d2		;Current value
	moveq	#0,d3		;Radix (can be 0=dec, 16=bin, 32=hex)
	moveq	#0,d4		;Negative flag (0/8 - see .maxval below)
	moveq	#9,d5		;Max. digit value (dec=9, bin=1, hex=15)
	moveq	#0,d6		;Index into .maxval table (=D3+D4)
	jtcall	GetCurInput
	move.l	d0,a2
	jtcall	GetCurRP
	move.l	d0,a5
	lea	.maxval(pc),a3
	subq.w	#2,a7
.lp	move.l	a2,a0
	jtcall	GetKey
	bne	.gotkey
	gfxcall	WaitTOF
	bra	.lp
.gotkey	move.w	d0,(a7)
	move.b	d0,d7
	beq	.cancel
	cmp.b	#13,d7
	beq	.endlp
	cmp.b	#10,d7
	beq	.endlp
	cmp.b	#8,d7
	beq	.bksp
	tst.l	d2
	bne	.Nnot0
	tst.w	d3
	bne	.notrdx
	tst.w	d4
	bne	.notneg
	cmp.b	#'-',d7
	bne	.notneg
	moveq	#8,d4
	moveq	#8,d6
	bra	.print
.notneg	cmp.b	#'%',d7
	bne	.notbin
	moveq	#16,d3
	add.w	d3,d6
	moveq	#1,d5
	bra	.print
.notbin	cmp.b	#'$',d7
	bne	.nothex
	moveq	#32,d3
	add.w	d3,d6
	moveq	#$F,d5
	bra	.print
.nothex
.notrdx
	cmp.b	#'0',d7
	beq	.lp
.Nnot0	sub.b	#'0',d7
	bmi	.lp
	cmp.b	#9,d7
	bls	.tstdig
	bclr	#5,d7
	bclr	#5,1(a7)	;If letter, make it upper-case
	sub.b	#17,d7
	bmi	.lp
	add.b	#10,d7
.tstdig	cmp.b	d5,d7
	bhi	.lp
	cmp.l	0(a3,d6.w),d2
	bhi	.lp
	bcs	.putdig
	cmp.b	7(a3,d6.w),d7
	bhi	.lp
.putdig	tst.w	d3
	beq	.pd_dec
	cmp.w	#16,d3
	beq	.pd_bin
	lsl.l	#4,d2
	or.b	d7,d2
	bra	.print
.pd_dec	move.l	d2,d0
	moveq	#10,d1
	jtcall	LongMul
	moveq	#0,d2
	move.b	d7,d2
	add.l	d0,d2
	bra	.print
.pd_bin	lsl.l	#1,d2
	or.b	d7,d2
.print	lea	1(a7),a0
	moveq	#1,d0
	move.l	a5,a1
	gfxcall	Text
	bra	.lp
.bksp	tst.l	d2
	bne	.bs_dig
	tst.w	d3
	bne	.bs_rdx
	tst.w	d4
	beq	.lp
	moveq	#0,d4
	move.b	#'-',d0
	bra	.bsprnt
.bs_rdx	cmp.w	#16,d3
	beq	.br_bin
	moveq	#0,d3
	move.b	#'$',d0
	bra	.bsprnt
.br_bin	moveq	#0,d3
	move.b	#'%',d0
	bra	.bsprnt
.bs_dig	tst.w	d3
	beq	.bd_dec
	cmp.w	#16,d3
	beq	.bd_bin
	move.b	d2,d0
	and.b	#$F,d0
	lsr.l	#4,d2
	bra	.bd_all
.bd_dec	move.l	d2,d0
	moveq	#10,d1
	jtcall	LongDiv
	move.l	d0,d2
	move.b	d1,d0
	bra	.bd_all
.bd_bin	move.b	d2,d0
	and.b	#1,d0
	lsr.l	#1,d2
.bd_all	add.b	#'0',d0
	cmp.b	#'9',d0
	bls	.bsprnt
	addq.b	#7,d0
.bsprnt	move.w	d0,(a7)
	move.l	rp_Font(a5),a0
	sub.b	tf_LoChar(a0),d0
	move.l	tf_CharSpace(a0),d1
	beq	.nospc
	move.l	d1,a0
	lsl.w	#1,d0
	move.w	0(a0,d0.w),d0
	bra	.gotspc
.nospc	move.w	tf_XSize(a0),d0
.gotspc	sub.w	d0,rp_cp_x(a5)
	move.w	rp_cp_x(a5),-(a7)
	moveq	#RP_COMPLEMENT,d0
	move.l	a5,a1
	call	SetDrMd
	lea	3(a7),a0
	moveq	#1,d0
	move.l	a5,a1
	call	Text
	moveq	#RP_JAM2,d0
	move.l	a5,a1
	call	SetDrMd
	move.w	(a7)+,rp_cp_x(a5)
	bra	.lp
.cancel	moveq	#0,d2
.endlp	addq.l	#2,a7
	move.l	d2,d3
	tst.w	d4
	beq	.exit
	neg.l	d3
.exit	moveq	#0,d2
	movem.l	(a7)+,a3/a5
	ret

;Maximum values:
;	dc.l MaxPos,MaxPosMaxDig,MaxNeg,MaxNegMaxDig
;where:	MaxPos is the maximum positive value / radix
;	MaxPosMaxDig is the maximum positive value % radix
;	MaxNeg is the abs. value of (maximum negative value / radix)
;	MaxNegMaxDig is the abs. value of (maximum negative value % radix)
.maxval	dc.l 429496729,5,214748364,8
	dc.l %1111111111111111111111111111111,%1
		dc.l %1000000000000000000000000000000,%0
	dc.l $FFFFFFF,$F,$8000000,$0


;;;;;;;; Event waiting

L_IwaitEvent:
	pstart
	jtcall	GetCurInput
	move.l	d0,a2
.lp	moveq	#0,d1
	move.b	mp_SigBit(a2),d1
	moveq	#1,d0
	lsl.l	d1,d0
	syscall	Wait
	move.l	a2,a0
	move.l	#IDCMPWAIT,d0
	jtcall	DoEvent
	tmove.l	d1,EventData
	move.l	d0,d3
	beq	.lp
;If a hit-select gadget, cancel the count
	cmp.l	#GADGETUP,d3
	bne	.exit
	move.l	d1,a0
	move.w	#~GADGETTYPE,d0
	and.w	gg_GadgetType(a0),d0
	cmp.w	#BOOLGADGET,d0
	bne	.exit
	move.w	#TOGGLESELECT,d0
	and.w	gg_Activation(a0),d0
	beq	.exit
	move.l	gg_UserData(a0),a0
	clr.w	ge_HitCount(a0)
.exit	moveq	#0,d2
	ret

L_IwaitEventVbl:
	pstart
	jtcall	GetCurInput
	move.l	d0,a2
.lp	moveq	#0,d1
	move.b	mp_SigBit(a2),d1
	moveq	#1,d0
	lsl.l	d1,d0
	dmove.b	VBLSignal,d1
	moveq	#1,d2
	lsl.l	d1,d2
	or.l	d2,d0
	move.l	d0,d3
	move.l	d2,d1
	moveq	#0,d0
	syscall	SetSignal
	move.l	d3,d0
	call	Wait
	cmp.l	d2,d0
	beq	.vbl
	move.l	a2,a0
	move.l	#IDCMPWAIT,d0
	jtcall	DoEvent
	tmove.l	d1,EventData
	move.l	d0,d3
	beq	.lp
	cmp.l	#GADGETUP,d3
	bne	.exit
	move.l	d1,a0
	move.w	#~GADGETTYPE,d0
	and.w	gg_GadgetType(a0),d0
	cmp.w	#BOOLGADGET,d0
	bne	.exit
	move.w	#TOGGLESELECT,d0
	and.w	gg_Activation(a0),d0
	beq	.exit
	move.l	gg_UserData(a0),a0
	clr.w	ge_HitCount(a0)
	bra	.exit
.vbl	move.l	#$80000000,d3
.exit	moveq	#0,d2
	ret

L_IeventData:
	pstart
	dmove.l	EventData,d3
	moveq	#0,d2
	ret

L_IeventVbl:
	move.l	#$80000000,d3
	moveq	#0,d2
	rts

L_IeventMouse:
	move.l	#MOUSEBUTTONS,d3
	moveq	#0,d2
	rts

L_IeventGadget:
	move.l	#GADGETUP,d3
	moveq	#0,d2
	rts

L_IeventMenu:
	move.l	#MENUPICK,d3
	moveq	#0,d2
	rts

L_IeventClose:
	move.l	#CLOSEWINDOW,d3
	moveq	#0,d2
	rts

L_IeventKey:
	move.l	#RAWKEY,d3
	moveq	#0,d2
	rts
