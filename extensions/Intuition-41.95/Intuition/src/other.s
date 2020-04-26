;Various other commands that don't fit anywhere else

L_IFlush:		;I Flush
	pstart
	jtcall	FlushRetStr
	ret

L_Iwait:		;Iwait n
	pstart
	jtcall	GetCurInput
	move.l	d0,a2
	move.l	(a3)+,d2
.lp	moveq	#0,d0
	move.l	a2,a0
	jtcall	DoEvent
	gfxcall	WaitTOF
	subq.l	#1,d2
	bne	.lp
	ret

L_IwaitVbl:		;Iwait Vbl
	move.l	#1,-(a3)
	bra	L_Iwait

L_Ierr:			;=Ierr
	pstart
	dmove.l	LastError,d3
	moveq	#0,d2
	ret

L_IerrStr:		;=Ierr$
	pstart
	dmove.l	LastErrorStr,d0
	beq	.noerr
	dclr.b	TrapErrors
	bmi	L_NoErrStr
	move.l	d0,a0
	lea	.rsc(pc),a1
	jtcall	ReturnString
	ret
.noerr	dlea	NullStr,a0
	move.l	a0,d3
	moveq	#2,d2
	ret
.rsc	ds.b	rsc_sizeof

L_Ierror:		;Ierror n
	move.l	(a3)+,d0
	bra	L_CustomError	;This is OK - errors.a is right after this

L_ItrapOn:		;Itrap On
	pstart
	tmove.b	#-1,TrapErrors
	dclr.b	ErrorTrapped
	ret

L_ItrapOff:		;Itrap Off
	pstart
	dclr.b	TrapErrors
	ret

L_Ierrtrap:		;=Ierrtrap
	pstart
	dmove.b	ErrorTrapped,d3
	dclr.b	ErrorTrapped
	ext.w	d3
	ext.l	d3
	moveq	#0,d2
	ret

L_RTHere:		;=Reqtools Here
	pstart
	dtst.l	ReqToolsBase
	sne	d3
	ext.w	d3
	ext.l	d3
	moveq	#0,d2
	ret

L_IgetIcon5:		;Iget Icon n,x1,y1 To x2,y2
	pstart
	move.l	a5,-(a7)
	jtcall	GetCurIwin2
	move.l	d0,a5
	bsr	L_IgetIcon
	move.l	(a7)+,a5
	ret

L_IgetIcon6:		;Iget Icon screen,n,x1,y1 To x2,y2
	pstart
	move.l	a5,-(a7)
	move.l	20(a3),d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a5
	bsr	L_IgetIcon
	addq.l	#4,a3
	move.l	(a7)+,a5
	ret

L_IgetIcon7:		;Iget Icon screen,window,x1,y1 To x2,y2
	pstart
	move.l	a5,-(a7)
	move.l	24(a3),d0
	jtcall	FindIscr
	beq	L_NoScr
	move.l	20(a3),d0
	jtcall	FindIwin2
	beq	L_NoWin
	move.l	d0,a5
	bsr	L_IgetIcon
	addq.l	#8,a3
	move.l	(a7)+,a5
	ret

L_IgetIcon:		;Base routine for grabbing icons
	pstart
	moveq	#2,d0
	jtcall	GetBankAdr
	beq	.nobank
	btst	#Bnk_BitIcon,d0
	bne	.gotbnk
.nobank
;Create the bank
	bra	L_NoIconBank
.gotbnk	movem.l	(a3)+,d3-d7
	cmp.l	#65535,d7
	bhi	L_IllFunc
	tst.w	d7
	beq	L_IllFunc
	cmp.l	#32767,d6
	bgt	L_IllFunc
	cmp.l	#-32768,d6
	blt	L_IllFunc
	cmp.l	#32767,d5
	bgt	L_IllFunc
	cmp.l	#-32768,d5
	blt	L_IllFunc
	cmp.l	#32767,d4
	bgt	L_IllFunc
	cmp.l	#-32768,d4
	blt	L_IllFunc
	cmp.l	#32767,d3
	bgt	L_IllFunc
	cmp.l	#-32768,d3
	blt	L_IllFunc
	move.l	wd_WScreen(a5),a0
	cmp.w	sc_Width(a0),d6
	bge	L_IllFunc
	cmp.w	sc_Height(a0),d5
	bge	L_IllFunc
	tst.w	d4
	blt	L_IllFunc
	tst.w	d3
	blt	L_IllFunc
	cmp.w	d3,d5
	bcs	L_MixedCoords
	cmp.w	d4,d6
	bcs	L_MixedCoords
	tst.w	d6			;Coordinates are OK, do clipping
	bge	.x1ok
	moveq	#0,d6
.x1ok	tst.w	d5
	bge	.y1ok
	mvoeq	#0,d5
.y1ok	cmp.w	sc_Width(a0),d4
	blt	.x2ok
	move.w	sc_Width(a0),d4
	subq.w	#1,d4
.x2ok	cmp.w	sc_Height(a0),d3
	blt	.y2ok
	move.w	sc_Height(a0),d3
	subq.w	#1,d3
.y2ok	cmp.w	(a0),d7
	bls	.goticn
;Create new icon(s)
	bra	L_NoIcon

.goticn	move.l	a0,a2
	lsl.l	#3,d7
	move.l	-6(a2,d7.l),d2		;Erase any old image
	beq	.grab
	tst.l	-2(a2,d7.l)		;along with its mask
	ble	.nomask
	move.l	-2(a2,d7.l),a1
	move.l	(a1),d0
	syscall	FreeMem
	clr.l	-2(a2,d7.l)
.nomask	move.l	d2,a1
	move.w	(a1),d0
	mulu.w	2(a1),d0
	lsl.w	#1,d0
	move.w	4(a1),d1
	jtcall	LongMul
	add.l	#10,d0
	syscall	FreeMem

.grab	lea	icontemp(pc),a1		;Allocate w*h*d+10 bytes for icon
	move.w	d4,d2			;Width (in words) = ((x2-x1+1)+15)/16
	sub.w	d6,d2			;                 = (x2-x1+16)/16
	lsr.w	#4,d2			;                 = (x2-x1)/16 + 1
	addq.w	#1,d2
	move.w	d2,(a1)
	move.w	d3,d2
	sub.w	d5,d2
	addq.w	#1,d2
	move.w	d2,2(a1)
	move.l	wd_WScreen(a5),a0
	moveq	#0,d2
	move.b	sc_Depth(a0),d2
	move.w	d2,4(a1)
	move.w	(a1),d0
	mulu	2(a1),d0
	lsl.l	#1,d0
	move.w	d2,d1
	jtcall	LongMul
	moveq	#MEMF_CHIP|MEMF_PUBLIC,d1
	jtcall	AllocMemClear
	tst.l	d0
	bne	.gotmem
	clr.l	-6(a2,d7.l)
	clr.l	-2(a2,d7.l)
	bra	L_NoMem
.gotmem	move.l	d0,a0
	lea	icontemp(pc),a1
	move.l	(a1)+,(a0)
	move.w	(a1),4(a0)
	dlea	TempBitMap,a1
	move.b	5(a0),bm_Depth(a1)
	move.w	(a0),d0
	lsl.w	#1,d0
	move.w	d0,bm_BytesPerRow(a1)
	move.w	2(a0),bm_Rows(a1)
	mulu	2(a0),d0
	move.l	a2,-(a7)		;Determine bitplane addresses for icon
	lea	10(a0),a2
	lea	bm_Planes(a1),a6
	move.w	4(a0),d1
	subq.w	#1,d1
.bploop	move.l	a2,(a6)+
	add.l	d0,a2
	dbra	d1,.bploop
	move.l	(a7)+,a2
	sub.w	d6,d4			;Store width for BltBitMap()
	addq.w	#1,d4
	movem.l	d7/a0,-(a7)		;Save icon pointer and bank offset
	moveq	#0,d0			;Calculate X/Y for source
	move.b	wd_BorderLeft(a5),d0
	add.w	wd_LeftEdge(a5),d0
	add.w	d6,d0
	moveq	#0,d1
	move.b	wd_BorderTop(a5),d1
	add.w	wd_TopEdge(a5),d1
	add.w	d5,d1
	move.l	wd_WScreen(a5),a0	;Get source BitMap
	lea	sc_BitMap(a0),a0
	moveq	#0,d2			;Destination X/Y = (0,0)
	moveq	#0,d3
	move.w	bm_Rows(a1),d5		;Icon height
	move.b	#$C0,d6			;Minterms
	moveq	#-1,d7			;Mask
	sub.l	a2,a2
	gfxcall	BltBitMap		;Copy the icon
	movem.l	(a7)+,d7/a0		;Restore icon pointer and bank offset
	move.l	a0,-6(a2,d7.l)		;Store icon pointer in bank
	ret
icontemp	ds.w 3
