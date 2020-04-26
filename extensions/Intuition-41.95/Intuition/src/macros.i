;Macros

mvoe	macro			;Because I keep typing "mvoe" instead of
				;  "move" so much... :-)
	move.\0	\1,\2
	endm
mvoeq	macro
	moveq	\1,\2
	endm

;Note that in the next macros, A4 is assumed to hold the base address of
;the extension's data.  This should always be the case (set up at the
;beginning of each routine - see PSTART/RET below - or with DINIT).

dlea	macro
	lea	\1(a4),\2	;Don't need "-DataBase" because of rs.x
	endm

dmove	macro	;move from data
	move.\0	\1(a4),\2
	endm

amove	macro	;move from data with a specific address register as DataBase.
		;Calling format: amove.x variable,dest,An
	move.\0	\1(\3),\2
	endm

tmove	macro	;move to data
	move.\0	\1,\2(a4)
	endm

dclr	macro
	clr.\0	\1(a4)
	endm

aclr	macro
	clr.\0	\1(\2)
	endm

dcmp	macro
	cmp.\0	\1(a4),\2
	endm

acmp	macro
	cmp.\0	\1(\3),\2
	endm

dtst	macro
	tst.\0	\1(a4)
	endm

atst	macro
	tst.\0	\1(\2)
	endm

;;;;;;;;;;;;;;;;

dinit	macro			;For routines that can't/don't use PSTART,
				;  or that need A4 for something else
	move.l	ExtAdr+(ExtNum-1)*16(a5),\1
	endm

pstart	macro
	movem.l	a4/a6,-(a7)
	move.l	ExtAdr+(ExtNum-1)*16(a5),a4
	dmove.l	A7StackPtr,a6
	move.l	a7,-(a6)
	tmove.l	a6,A7StackPtr
	move.l	4(a7),a6
	endm

ret	macro
	bsr	L_0
	dmove.l	A7StackPtr,a6
	move.l	(a6)+,a7
	tmove.l	a6,A7StackPtr
	movem.l	(a7)+,a4/a6
	rts
	endm

fixA6	macro			;Set saved A6 value to current A6.  Parameter
	move.l	a6,4+\1(a7)	;  is number of bytes pushed after "pstart"
	endm

;;;;;;;;;;;;;;;;

call	macro
	jsr	_LVO\1(a6)
	endm

syscall	macro
	move.l	4,a6
	call	\1
	endm

doscal	macro			;Not a typo!!  "doscall" is defined in equ.s
	dmove.l	DOSBase,a6
	call	\1
	endm

gfxcall	macro
	dmove.l	GfxBase,a6
	call	\1
	endm

intcall	macro
	dmove.l	IntuitionBase,a6
	call	\1
	endm

rtcall	macro
	dtst.l	ReqToolsBase
	beq	L_NoReqTools
	dmove.l	ReqToolsBase,a6
	call	\1
	endm

;;;;;;;;;;;;;;;;

rjsrA5	macro			;Restore A5 to AMOS Data Zone and do an RJSR
	move.l	a5,-(a7)
	dmove.l	SavedA5,a5
	rjsr	\1
	move.l	(a7)+,a5
	endm

;;;;;;;;;;;;;;;;

jtcall	macro			;Call a routine in the jump table
	move.l	a6,-(a7)
	dmove.l	IntJumpTable,a6
	jsr	jt_\1(a6)
	move.l	(a7)+,a6
	endm
