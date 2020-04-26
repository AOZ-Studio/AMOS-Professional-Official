;Read a row of an ILBM RLE-compressed picture into memory
;D1=Y
;D2=Width
;D3=Depth
;A0=Data
;A2=DestList
;Returns A0=End of compressed data used.  This can be used in the next
;  call to this procedure (with Y incremented by one).

ReadILBM:
	movem.l	d0-d5/a1-a2,-(a7)
	add.w	#15,d2		;Make sure it's word-aligned
	lsr.w	#4,d2
	add.w	d2,d2
	mulu	d2,d1
	subq.w	#1,d3
.bploop moveq	#0,d0
	move.l	(a2)+,a1
	add.l	d1,a1
.xloop	move.b	(a0)+,d5
	ext.w	d5
	bpl.s	.read
	cmp.b	#-$80,d5
	beq.s	.nxtX
	move.b	(a0)+,d4	;Copy a single byte multiple times
	neg.w	d5
	add.w	d5,d0
	addq.w	#1,d0
.copylp move.b	d4,(a1)+
	dbra	d5,.copylp
	bra.s	.nxtX
.read	add.w	d5,d0		;Copy a string of bytes literally
	addq.w	#1,d0
.readlp move.b	(a0)+,(a1)+
	dbra	d5,.readlp
.nxtX	cmp.w	d2,d0
	blt.s	.xloop
	dbra	d3,.bploop
	movem.l	(a7)+,d0-d5/a1-a2
	rts
