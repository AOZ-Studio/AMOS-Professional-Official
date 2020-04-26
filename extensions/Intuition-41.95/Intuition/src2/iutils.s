;Internal utility routines for Intuition Extension.  Note that these follow
;the Commodore library function standard for registers: D0/D1/A0/A1 are
;trashed (unless the function says otherwise; e.g. a return value), while all
;other registers are preserved.
;
;This file just contains very basic routines.

	include "offsets.i"
	include "defs.i"
	include "errordefs.i"
	include "macros.i"
	include "macros2.i"

      ifd CREATOR
	incdir	"/AMOS1.3"
      else
	incdir	"/AMOS"
      endc
;	include "equ.s"		;PhxAss is buggy...
EcNumber	equ	188
Bnk_BitData	equ	0
Bnk_BitChip	equ	1
Bnk_BitBob	equ	2
Bnk_BitIcon	equ	3

	section text,code

	xdef	LongMul
	xdef	LongDiv
	xdef	StrLen
	xdef	RTS


LongMul:		;Multiply a 32-bit number in D0 by a 16-bit number in
			;  D1.  Returns 32-bit product in D0.  Multiplication
			;  is unsigned.  Registers A0-A1 are preserved.
	move.l	d2,-(a7)
	move.w	d0,d2
	mulu	d1,d2
	swap	d0
	mulu	d1,d0
	swap	d0
	tst.w	d0
	bne	.ovrflw
	clr.w	d0
	add.l	d2,d0
	move.l	(a7)+,d2
	tst.l	d0
	rts
.ovrflw	move.l	(a7)+,d2
	or.w	#2,ccr
	rts

LongDiv:		;Divide a 32-bit number in D0 by a 16-bit number in D1
			;  without overflow.  Returns 32-bit quotient in D0
			;  and remainder in D1.  Division is unsigned.
			;  Registers A0-A1 are preserved.
	movem.l	d2-d3,-(a7)
	move.l	d0,d2
	clr.w	d0
	swap	d0
	divu	d1,d0
	move.w	d0,d3
	swap	d3
	move.w	d2,d0
	divu	d1,d0
	move.w	d0,d3
	swap	d0
	moveq	#0,d1
	move.w	d0,d1
	move.l	d3,d0
	movem.l	(a7)+,d2-d3
	rts

StrLen:			;Return length of string in A0.  Leaves A0 alone.
	move.l	a0,a1
	moveq	#-1,d0
.lp	addq.l	#1,d0
	tst.b	(a1)+
	bne	.lp
	rts

RTS:			;Just an RTS.  Possibly useful in some cases.
	rts
