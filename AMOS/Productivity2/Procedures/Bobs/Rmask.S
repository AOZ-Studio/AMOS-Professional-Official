; ____________________________________________________________________________
;
; 	AMOS Complex mask calculation
;
;	[Number,Colour0,Colour1]
; ____________________________________________________________________________

	OPT	P+
	Include	"|AMOS_Includes.s"
; ____________________________________________________________________________


; Look for the sprite bank
; ~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Bnk_GetBobs
	beq	Erreur
; Get the parameters back
; ~~~~~~~~~~~~~~~~~~~~~~~
	move.l	(a3)+,d2	Colour 2
	move.l	(a3)+,d1	Colour 1
	move.l	(a3)+,d0	Number of the bob
; Parameter check
; ~~~~~~~~~~~~~~~
	tst.w	d0
	ble	Erreur
	cmp.w	(a0)+,d0	> of available sprites 
	bhi	Erreur		
	lsl.w	#3,d0
	lea	-8(a0,d0.w),a5	Adress of the bobs
	move.l	(a5)+,d0
	beq	Erreur
	move.l	d0,a4		A4= SpriteBase

* Built up table
	lea	Table(pc),a0
	cmp.l	(a0),d1
	bne.s	DoTable
	cmp.l	4(a0),d2
	beq.s	PaTable
DoTable	move.l	d1,(a0)+
	move.l	d2,(a0)+
	moveq	#64-1,d0
Table0	clr.b	(a0)
	lsr.l	#1,d1
	roxr.l	#1,d2
	bcc.s	Table1
	subq.b	#1,(a0)
Table1	addq.l	#1,a0
	dbra	d0,Table0
PaTable

* Calculation of mask size
	move.w	(a4),d7		TX
	lsl.w	#1,d7		En mots
	mulu	2(a4),d7	fois TY

* Reserve memory (if needed)
	move.l	(a5),d0
	beq.s	Reserve
	bpl.s	DejaLa
Reserve	move.l	d7,d0
	addq.l	#4,d0
	move.l	d0,d2
	move.l	$4,a6
	move.l	#Chip|Public,d1		CHIP memory only
	jsr	_LVOAllocMem(a6)
	move.l	d0,(a5)
	beq	Erreur
	move.l	d0,a0
	move.l	d2,(a0)+	Loke the size 
DejaLa	move.l	d0,a2
	addq.l	#4,a2

* Loop initialisation
	move.l	d7,d6		D6-> Size of one memory plane
	subq.l	#1,d7		D7-> Byte counter
	move.w	4(a4),d5	Number of planes
	subq.w	#1,d5		D5-> Plane counter reload
	lea	10(a4),a1	A1-> Bitmap base
;				A2-> Mask address
	lea	Table+8(pc),a3	A3-> Mask table

* Calculation loop
.loop0	moveq	#7,d3		D3-> Bit counter
.loop1	moveq	#0,d0		D0-> Color calculation
	moveq	#0,d1		D1-> Bit position
	move.w	d5,d2		D2-> Plane counter
	move.l	a1,a0		A0-> Point to current byte
.loop2	btst	d3,(a0)
	beq.s	.loop3
	bset	d1,d0
.loop3	add.l	d6,a0		Next plane
	addq.w	#1,d1
	dbra	d2,.loop2

	bset	d3,(a2)
	tst.b	0(a3,d0.w)	Transparent colour?	
	beq.s	.loop4
	bclr	d3,(a2)
.loop4
	dbra	d3,.loop1	Still one bit?
	addq.l	#1,a1
	addq.l	#1,a2
	dbra	d7,.loop0	Still one byte?

* All done, no errors
	moveq	#0,d0
	rts
* An error
Erreur	moveq	#-1,d0
	rts

; Finds a bank adress
; ~~~~~~~~~~~~~~~~~~~
Bnk_GetAdr
	move.l	Cur_Banks(a5),a0
	move.l	(a0),d1
	beq.s	.Nof
.Loop	move.l	d1,a1
	cmp.l	8(a1),d0
	beq.s	.Fnd
	move.l	(a1),d1
	bne.s	.Loop
.Nof	sub.l	a1,a1
	move.l	a1,a0
	rts
.Fnd	move.w	8+4(a1),d0
	lea	8*3(a1),a0
	move.l	a0,a1
	move.w	#%00000,CCR
	rts
; Finds bob bank address
; ~~~~~~~~~~~~~~~~~~~~~~
;	OUT	BNE found A0/A1=address (D0/D1 unchanged)
Bnk_GetBobs
	movem.l	d0/d1,-(sp)
	moveq	#1,d0
	bsr	Bnk_GetAdr
	beq.s	.Nof
	btst	#Bnk_BitBob,d0
.Nof	movem.l	(sp)+,d0/d1
	rts

******* Work table
	even
Table	ds.b	64+8
	even
