;Colour-fiddling instructions
L_IcolourGet:		;=Icolour(n)
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	move.l	sc_ViewPort+vp_ColorMap(a0),a0
	move.l	(a3)+,d0
	gfxcall	GetRGB4
	move.l	d0,d3
	bmi	L_IllFunc
	moveq	#0,d2
	ret

L_IcolourSet:		;Icolour n,c
	pstart
	jtcall	GetCurIscr
	move.l	d0,a0
	lea	sc_ViewPort(a0),a0
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	move.l	vp_ColorMap(a0),a1
	cmp.w	cm_Count(a1),d0
	bcc	L_IllFunc
	move.w	d1,d2
	move.w	d1,d3
	lsr.w	#8,d1
	and.w	#$F,d1
	lsr.w	#4,d2
	and.w	#$F,d2
	and.w	#$F,d3
	gfxcall	SetRGB4
	ret


;Ipalette disabled because it's unstable.

    ifne 0
;EXTASM: DNOTDEF

L_Ipalette:	;Ipalette for any number of args.  Pass number of args in *D7*.
	pstart
	dmove.l	GfxBase,a6
	jtcall	GetCurIscr
	move.l	d0,a0
	lea	sc_ViewPort(a0),a0
	move.l	vp_ColorMap(a0),a2
	move.w	d7,d2
	subq.w	#1,d2
.lp	move.l	(a3)+,d0
	cmp.l	#Null,d0
	bne	.endlp
	move.l	d2,d0
	move.l	a0,-(a7)
	move.l	a2,a0
	call	GetRGB4
	move.l	(a7)+,a0
.endlp	move.w	d0,-(a7)
	dbra	d2,.lp
	move.l	a7,a1
	move.w	d7,d0
	call	LoadRGB4
	lsl.w	#1,d7
	add.l	d7,a7
	ret

L_Ipalette1:
	moveq	#1,d0
	bra	L_Ipalette

L_Ipalette2:
	moveq	#2,d0
	bra	L_Ipalette

L_Ipalette3:
	moveq	#3,d0
	bra	L_Ipalette

L_Ipalette4:
	moveq	#4,d0
	bra	L_Ipalette

L_Ipalette5:
	moveq	#5,d0
	bra	L_Ipalette

L_Ipalette6:
	moveq	#6,d0
	bra	L_Ipalette

L_Ipalette7:
	moveq	#7,d0
	bra	L_Ipalette

L_Ipalette8:
	moveq	#8,d0
	bra	L_Ipalette

L_Ipalette9:
	moveq	#9,d0
	bra	L_Ipalette

      ifd CREATOR
;;EXTASM: DCREATOR

L_Ipalette10:
	moveq	#10,d0
	bra	L_Ipalette

L_Ipalette11:
	moveq	#11,d0
	bra	L_Ipalette

L_Ipalette12:
	moveq	#12,d0
	bra	L_Ipalette

L_Ipalette13:
	moveq	#13,d0
	bra	L_Ipalette

L_Ipalette14:
	moveq	#14,d0
	bra	L_Ipalette

L_Ipalette15:
	moveq	#15,d0
	bra	L_Ipalette

L_Ipalette16:
	moveq	#16,d0
	bra	L_Ipalette

L_Ipalette17:
	moveq	#17,d0
	bra	L_Ipalette

L_Ipalette18:
	moveq	#18,d0
	bra	L_Ipalette

L_Ipalette19:
	moveq	#19,d0
	bra	L_Ipalette

L_Ipalette20:
	moveq	#20,d0
	bra	L_Ipalette

L_Ipalette21:
	moveq	#21,d0
	bra	L_Ipalette

L_Ipalette22:
	moveq	#22,d0
	bra	L_Ipalette

L_Ipalette23:
	moveq	#23,d0
	bra	L_Ipalette

L_Ipalette24:
	moveq	#24,d0
	bra	L_Ipalette

L_Ipalette25:
	moveq	#25,d0
	bra	L_Ipalette

L_Ipalette26:
	moveq	#26,d0
	bra	L_Ipalette

L_Ipalette27:
	moveq	#27,d0
	bra	L_Ipalette

L_Ipalette28:
	moveq	#28,d0
	bra	L_Ipalette

L_Ipalette29:
	moveq	#29,d0
	bra	L_Ipalette

L_Ipalette30:
	moveq	#30,d0
	bra	L_Ipalette

L_Ipalette31:
	moveq	#31,d0
	bra	L_Ipalette

L_Ipalette32:
	moveq	#32,d0
	bra	L_Ipalette

;;EXTASM: E
      else ;Pro
;;EXTASM: NCREATOR

L_Ipalette10:	;for all #'s of colours >9
	pstart
	move.l	a5,-(a7)
	jtcall	GetCurIscr
	move.l	d0,a0
	lea	sc_ViewPort(a0),a0
	move.l	vp_ColorMap(a0),a5	;oops - have to write over AMOS's A5
	moveq	#0,d0
.lp0	tst.w	(a6)		;only 9 colours on A3 stack, rest at A6
	beq	.endlp0
	addq.l	#8,a6
	addq.w	#1,d0
	bra	.lp0
.endlp0	move.l	a7,a2		;save old A7
	fixA6	4		;tell AMOS we got the extra parameters
	move.l	a6,a1
	dmove.l	GfxBase,a6
	move.w	d0,d1
	subq.w	#1,d1
	add.w	#9,d0
.lp1	move.l	-(a1),d2
	subq.l	#4,a1
	cmp.l	#Null,d2
	bne	.endlp1
	move.l	a5,a0
	movem.l	d0-d1/a1,-(a7)
	add.w	#9,d1
	move.l	d1,d0
	move.l	a5,a0
	call	GetRGB4
	move.w	d0,d2
	movem.l	(a7)+,d0-d1/a1
.endlp1	move.w	d2,-(a7)
	dbra	d1,.lp1
	moveq	#8,d1
.lp2	move.l	(a3)+,d2
	cmp.l	#Null,d2
	bne	.endlp2
	movem.l	d0-d1,-(a7)
	move.l	d1,d0
	move.l	a5,a0
	call	GetRGB4
	move.w	d0,d2
	movem.l	(a7)+,d0-d1
.endlp2	move.w	d2,-(a7)
	dbra	d1,.lp2
	move.l	a7,a1
	call	LoadRGB4
	move.l	a2,a7
	move.l	(a7)+,a5
	ret

;;EXTASM: E
      endc ;Creator/Pro

;EXTASM: E
    else ;ifne 0
;EXTASM: NNOTDEF

L_Ipalette0:		;Ipalette - just a stub
	rts

;EXTASM: E
    endc

L_IgetSprPal:		;Iget Sprite Palette mask
	pstart
	move.l	(a3)+,d4
	movem.l	a3/a5,-(a7)
	jtcall	GetCurIscr
	move.l	d0,a2
	lea	sc_ViewPort(a2),a2
	move.l	vp_ColorMap(a2),a3
	moveq	#1,d0
	jtcall	GetBankAdr
	beq	L_NoObjBank
	btst	#Bnk_BitBob,d0
	beq	L_NoObjBank
	moveq	#0,d0
	move.w	(a0)+,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.l	a0,a5
	dmove.l	GfxBase,a6
	moveq	#31,d5
.lp	move.w	(a5)+,d1
	btst	d5,d4
	bne	.next
	move.l	d5,d0
	move.w	d1,d2
	move.w	d2,d3
	lsr.w	#8,d1
	lsr.w	#4,d2
	and.w	#$F,d2
	and.w	#$F,d3
	move.l	a3,a0
	call	SetRGB4CM
.next	dbra	d5,.lp
	move.l	a2,a0
	move.l	a3,a1
	move.l	cm_ColorTable(a1),a1
	moveq	#32,d0
	call	LoadRGB4
	movem.l	(a7)+,a3/a5
	ret

L_IgetSprPal0:		;Iget Sprite Palette
	pstart
	jtcall	GetCurIscr
	move.l	d0,a2
	lea	sc_ViewPort(a2),a2
	moveq	#1,d0
	jtcall	GetBankAdr
	beq	L_NoObjBank
	btst	#Bnk_BitBob,d0
	beq	L_NoObjBank
	moveq	#0,d0
	move.w	(a0)+,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.l	a0,a1
	move.l	a2,a0
	moveq	#32,d0
	gfxcall	LoadRGB4
	ret

L_IgetIconPal:		;Iget Icon Palette mask
	pstart
	move.l	(a3)+,d4
	movem.l	a3/a5,-(a7)
	jtcall	GetCurIscr
	move.l	d0,a2
	lea	sc_ViewPort(a2),a2
	move.l	vp_ColorMap(a2),a3
	moveq	#2,d0
	jtcall	GetBankAdr
	beq	L_NoIconBank
	btst	#Bnk_BitIcon,d0
	beq	L_NoIconBank
	moveq	#0,d0
	move.w	(a0)+,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.l	a0,a5
	dmove.l	GfxBase,a6
	moveq	#31,d5
.lp	move.w	(a5)+,d1
	btst	d5,d4
	bne	.next
	move.l	d5,d0
	move.w	d1,d2
	move.w	d2,d3
	lsr.w	#8,d1
	lsr.w	#4,d2
	and.w	#$F,d2
	and.w	#$F,d3
	move.l	a3,a0
	call	SetRGB4CM
.next	dbra	d5,.lp
	move.l	a2,a0
	move.l	a3,a1
	move.l	cm_ColorTable(a1),a1
	moveq	#32,d0
	call	LoadRGB4
	movem.l	(a7)+,a3/a5
	ret

L_IgetIconPal0:		;Iget Icon Palette
	pstart
	jtcall	GetCurIscr
	move.l	d0,a2
	lea	sc_ViewPort(a2),a2
	moveq	#2,d0
	jtcall	GetBankAdr
	beq	L_NoIconBank
	btst	#Bnk_BitIcon,d0
	beq	L_NoIconBank
	moveq	#0,d0
	move.w	(a0)+,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.l	a0,a1
	move.l	a2,a0
	moveq	#32,d0
	gfxcall	LoadRGB4
	ret
