L_Iflood:		;Iflood x,y,mode
	procstart
	move.l	(a3)+,d0
	sne.b	d2
	neg.b	d2
	bsr	L_GetCurRP
;	move.l	d0,a0
;	moveq	#0,d4
;	move.l	(a3),d1
;	move.l	4(a3),d0
;	bsr	MyFlood
	move.l	d0,a2
	move.l	a2,a0
	move.l	4(a3),d0
	move.l	(a3),d1
	call	Flood
	clr.l	rp_TmpRas(a2)
	
	bsr	L_IlocateGr
	ret
.tmpras	ds.b tr_sizeof
.raster	dc.l 0

MyFlood:
	dmove.l	GfxBase,a6
	move.l	a0,a2
	move.w	d2,d4
	move.w	d1,d3
	move.w	d0,d2
	move.l	rp_BitMap(a2),a0
	move.w	bm_BytesPerRow(a0),d6
	move.w	bm_Rows(a0),d7
	lsl.w	#3,d6
	tst.w	d4
	bne	FloodXY

FloodOPen:
	move.b	rp_AOlPen(a2),d4
.loop	dcmp.l	flStackWarn,a7
	bls	flMoreStack		;If we need more stack, get it
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_WritePixel
	subq.w	#1,d2
	bmi	.xpl1
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.xpl1
	bsr	.loop
.xpl1	addq.w	#2,d2
	cmp.w	d6,d2
	bcc	.ymi1
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.ymi1
	bsr	.loop
.ymi1	subq.w	#1,d2
	subq.w	#1,d3
	bmi	.ypl1
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.ypl1
	bsr	.loop
.ypl1	addq.w	#2,d3
	cmp.w	d7,d3
	bcc	.done
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.done
	bsr	.loop
.done	subq.w	#1,d3
	rts

FloodXY:
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	move.b	d0,d4
.loop	dcmp.l	flStackWarn,a7
	bls	flMoreStack
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_WritePixel
	subq.w	#1,d2
	bmi	.xpl1
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.xpl1
	bsr	.loop
.xpl1	addq.w	#2,d2
	cmp.w	d6,d2
	bcc	.ymi1
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.ymi1
	bsr	.loop
.ymi1	subq.w	#1,d2
	subq.w	#1,d3
	bmi	.ypl1
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.ypl1
	bsr	.loop
.ypl1	addq.w	#2,d3
	cmp.w	d7,d3
	bcc	.done
	move.l	a2,a1
	move.w	d2,d0
	move.w	d3,d1
	bsr	L_ReadPixel
	cmp.b	d4,d0
	bne	.done
	bsr	.loop
.done	subq.w	#1,d3
	rts

flMoreStack:
	move.l	a0,-(a7)
	lea	.save(pc),a0
	move.l	(a7)+,(a0)+	;save A0
	move.l	a1,(a0)+	;save A1
	move.l	d0,(a0)+	;save D0
	move.l	d1,(a0)+	;save D1
	move.l	(a7)+,(a0)+	;pop return address
	dmove.l	flStackSize,d0	;now get some more stack
	moveq	#MEMF_PUBLIC,d1
	syscall	AllocMem
	tst.l	d0
	beq	L_NoMem		;oops, no memory - barf
	move.l	d0,a1
	dmove.l	flStackSize,d1
	add.l	d1,a1
	move.l	a7,-(a1)	;caller's original stack
	dmove.l	flStackWarn,-(a1);caller's original warning address
	move.l	d0,-(a1)	;our new stack base
	add.l	#1024,d0	;set up our new warning address
	tmove.l	d0,flStackWarn
	move.l	a1,a7		;now use the new stack
	pea	flKillStack(pc)	;routine to free stack
	lea	.save+20(pc),a0
	move.l	-(a0),-(a7)	;put our return address back
	move.l	-(a0),d1	;restore old regs
	move.l	-(a0),d0
	move.l	-(a0),a1
	move.l	.save(pc),a0	;don't use -(a0),(a0)
	rts
.save	ds.l 5

flKillStack:
	move.l	a0,-(a7)
	lea	.save(pc),a0
	move.l	(a7)+,(a0)+
	move.l	a1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	(a7)+,a1	;our stack base
	tmove.l	(a7)+,flStackWarn;restore old warning address
	move.l	(a7)+,a0	;old stack
	move.l	a0,a7		;use old stack again
	dmove.l	flStackSize,d0
	syscall	FreeMem		;free extra stack
	rts
.save	ds.l 4
