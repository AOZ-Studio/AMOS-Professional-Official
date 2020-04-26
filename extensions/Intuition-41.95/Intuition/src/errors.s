;Error routines

L_CustomError:
.start	cmp.l	#-1,d0			;Kludge - error -1 returns pointer to
	bne	.real_error		;  routine
	lea	.start(pc),a0		;Can't use L_CustomError - it remaps
	move.l	a0,d0			;  to a label number
	rts
.real_error:
	bsr	L_errGoto0		;Can't assume any registers are valid.
					;  This is a kludge to get the base of
					;  the data area; L_errGoto0 (in
					;  extcode.s) calls L_0 because the
					;  distance is too large for a single
					;  branch.
	dmove.l	SavedA5,a5		
	tmove.l	d0,LastError
	move.l	d0,d7
	lea	Errors(pc),a0
	move.l	a0,a1
.d0lp	tst.l	d0
	beq	.set
.a1lp	tst.b	(a1)+
	bne	.a1lp
	subq.l	#1,d0
	bra	.d0lp
.set	tmove.l	a1,LastErrorStr
	cmp.w	#E_INT,d7		;If internal error, insert codes D1/D2
	beq	.intlp
	cmp.w	#E_IN2,d7
	bne	.trap
.intlp	tst.b	(a1)+
	bne	.intlp
	subq.l	#1,a1
	moveq	#7,d3
.intlp2	moveq	#$F,d0
	and.l	d1,d0
	lsr.l	#4,d1
	cmp.b	#9,d0
	bls	.mkasc
	addq.b	#7,d0
.mkasc	add.b	#'0',d0
	move.b	d0,-(a1)
	dbra	d3,.intlp2
	cmp.w	#E_INT,d7
	beq	.trap
	add.l	#26,a1
	moveq	#7,d3
.intlp3	moveq	#$F,d0
	and.l	d1,d0
	lsr.l	#4,d2
	cmp.b	#9,d0
	bls	.mkasc2
	addq.b	#7,d0
.mkasc2	add.b	#'0',d0
	move.b	d0,-(a1)
	dbra	d3,.intlp3
.trap	dtst.b	TrapErrors
	beq	.doerr
	tmove.b	#-1,ErrorTrapped
	dlea	A7StackEnd-4,a0		;Quit from offending routine
	move.l	(a0)+,a7
	tmove.l	a0,A7StackPtr
	movem.l	(a7)+,a4/a6
	rts
.doerr	move.l	d7,d0
	moveq	#0,d1
	moveq	#ExtNum,d2
	moveq	#0,d3
	jmp	L_ErrorExt
Errors:
	dc.b "Only 16 colours allowed on non-AGA hires screen",0
	dc.b "Unable to open screen",0
	dc.b "Need Kickstart 2.0 or higher",0
	dc.b "Unable to open window",0
	dc.b "Window 0 can't be closed",0
	dc.b "Window 0 can't be modified",0
	dc.b "Window not opened",0
	dc.b "Window too small",0
	dc.b "Window too large",0
	dc.b "Illegal window parameter",0
	dc.b "Window not closed",0
	dc.b "Unable to open Workbench",0
	dc.b "Program interrupted",0
	dc.b "Illegal function call",0
	dc.b "Out of memory",0
	dc.b "Font not available",0
	dc.b "Screen not opened",0
	dc.b "Illegal screen parameter",0
	dc.b "Illegal number of colours",0
	dc.b "Screen not closed",0
	dc.b "Icon not defined",0
	dc.b "Icon bank not defined",0
;Why do I include this?  Nobody's ever going to see it...
	dc.b "Error text not available",0
	dc.b "Object not defined",0
	dc.b "Object bank not defined",0
	dc.b "Backward coordinates",0
	dc.b "Menu already active",0
	dc.b "Internal error, code 00000000",0
	dc.b "Internal error, code 00000000, subcode 00000000",0
	dc.b "ReqTools.library version 2 or higher required",0
	dc.b "Only 65535 gadgets allowed",0
	dc.b "Gadget already active",0
	dc.b "Wrong gadget type",0
	dc.b "Gadget not defined",0
	dc.b "Gadget not reserved",0
	dc.b "Valid AMOS screen numbers range from 0 to 7",0
	dc.b "Bank not defined",0
	dc.b "Bank format not understood",0
	dc.b "Inconsistent data",0
	ds.w 0

L_CustomNoErr:
.start	cmp.l	#-1,d0
	bne	.real_error
	lea	.start(pc),a0
	move.l	a0,d0
	rts
.real_error:
	bsr	L_errGoto0
	dmove.l	SavedA5,a5
	tmove.l	d0,LastError
	tmove.l	#-1,LastErrorStr
	dtst.b	TrapErrors
	beq	.doerr
	tmove.b	#-1,ErrorTrapped
	dlea	A7StackEnd-4,a0
	move.l	(a0)+,a7
	tmove.l	a0,A7StackPtr
	movem.l	(a7)+,a4/a6
	rts
.doerr	moveq	#0,d1
	moveq	#ExtNum,d2
	moveq	#-1,d3
	jmp	L_ErrorExt
