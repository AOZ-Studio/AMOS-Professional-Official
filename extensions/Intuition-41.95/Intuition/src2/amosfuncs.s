;Interface routines for AMOS functions, and other miscellaneous AMOS stuff.
;The interface routines are here because the calling conventions for AMOS
;functions changed between Creator and Pro.

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
L_Bnk_GetAdr	equ	1100
L_Bnk_Reserve	equ	1103
Bnk_BitData	equ	0
Bnk_BitChip	equ	1
Bnk_BitBob	equ	2
Bnk_BitIcon	equ	3
ABanks		equ	1252
ExtAdr		equ	62*4
EcNumber	equ	188
C_Code1		equ	$FE
C_Code2		equ	$01
C_CodeJ		equ	$F7
Rjmp		MACRO
		dc.b	C_Code1,0*16+C_Code2
		dc.b	C_CodeJ,0
		dc.w	\1
		ENDM
Rjsr		MACRO
		dc.b	C_Code1,1*16+C_Code2
		dc.b	C_CodeJ,0
		dc.w	\1
		ENDM

	section text,code

	xdef	GetBankAdr
	xdef	CreateBank
	xdef	FindAscr
	xdef	FindSprite
	xdef	FindIcon
	xdef	ReturnString
	xdef	GetRetStr
	xdef	FlushRetStr

	xref	DataBase
	xref	Ascr0to7
	xref	NoObjBank
	xref	NoIconBank
	xref	IllFunc
	xref	NoMem
	xref	LongMul
	xref	StrAlloc
	xref	StrFree
	xref	StrLen


GetBankAdr:		;Get address of bank D0 to A0, return bank flags in
			;  D0.w.  If bank does not exist, D0/A0 undefined and
			;  Z set on return; otherwise, Z clear.
      ifd CREATOR
	pstart2
	tst.l	d0
	beq	IllFunc
	cmp.l	#16,d0
	bhi	IllFunc
	movem.l	d2/a5,-(a7)
	dmove.l	SavedA5,a5
	move.l	ABanks(a5),a0
	subq.w	#1,d0
	lsl.w	#3,d0
	move.l	4(a0,d0.w),d1
	move.l	0(a0,d0.w),a0
	move.l	a0,d0
	beq	.nobank
	moveq	#0,d2
	btst	#31,d1
	sne	d0
	and.b	#1<<Bnk_BitData,d0
	or.b	d0,d2
	btst	#30,d1
	sne	d0
	and.b	#1<<Bnk_BitChip,d0
	or.b	d0,d2
	cmp.l	#'Spri',(a0)
	seq	d0
	cmp.l	#'tes ',4(a0)
	seq	d1
	and.b	d0,d1
	and.b	#1<<Bnk_BitBob,d1
	or.b	d1,d2
	cmp.l	#'Icon',(a0)
	seq	d0
	cmp.l	#'s   ',4(a0)
	seq	d1
	and.b	d0,d1
	and.b	#1<<Bnk_BitIcon,d1
	or.b	d1,d2
	move.l	d2,d0
	addq.l	#8,a0
	moveq	#1,d1
	bra	.exit
.nobank	moveq	#0,d0
.exit	movem.l	(a7)+,d2/a5
	ret2
      else
	rjmp	L_Bnk_GetAdr
      endc

CreateBank:		;Create bank number D0 with length D1, bank flags D2.
      ifd CREATOR	;  Return address in D0, or NULL if not successful.
	pstart2
	tst.l	d0
	beq	IllFunc
	cmp.l	#16,d0
	bhi	IllFunc
	movem.l	d2-d7/a2-a6,-(a7)
	move.l	d0,d5
	move.l	d1,d6
	move.l	d1,d7
	dmove.l	SavedA5,a5
	move.l	ABanks(a5),a2
	move.w	d5,d4
	subq.w	#1,d4
	lsl.w	#3,d4
	move.l	4(a2,d4.w),d0
	move.l	0(a2,d4.w),a3
	move.l	a3,d1
	beq	.nobank
	move.l	4,a6
	cmp.l	#'Spri',(a1)
	bne	.clr0
	cmp.l	#'tes ',4(a1)
	beq	.clrspr
.clr0	cmp.l	#'Icon',(a1)
	bne	.clr1
	cmp.l	#'s   ',4(a1)
	bne	.clr1
.clrspr	lsl.l	#3,d0
	add.l	#10,d0
	movem.l	d0/a1,-(a7)
	lea	8(a1),a3
	move.w	(a3)+,d2
	subq.w	#1,d2
.clrlp	move.l	(a3)+,d1
	beq	.noimg
	move.l	d1,a1
	move.w	(a1),d0
	mulu	2(a1),d0
	move.w	4(a1),d1
	lsl.l	#1,d0
	bsr	LongMul
	add.l	#10,d0
	call	FreeMem
	move.l	(a3)+,d1
	ble	.clrnxt
	move.l	d1,a1
	move.l	(a1),d0
	call	FreeMem
	bra	.clrnxt
.noimg	addq.l	#4,a3
.clrnxt	dbra	d2,.clrlp
	movem.l	(a7)+,d0/a1
.clr1	syscall	FreeMem
	clr.l	0(a2,d4.w)
	clr.l	4(a2,d4.w)

.nobank	move.l	d6,d2
	btst	#Bnk_BitChip,d7
	beq	.nochip
	move.l	#MEMF_CHIP,d5
	bset	#30,d2
.nochip	or.l	#MEMF_PUBLIC|MEMF_CLEAR,d5
	btst	#Bnk_BitData,d7
	beq	.nodata
	bset	#31,d2
	move.l	#'Data',d7
	bra	.alloc
.nodata	move.l	#'Work',d7
.alloc	move.l	d6,d0
	addq.l	#8,d0
	move.l	d5,d1
	
	syscall	AllocMem
	tst.l	d0
	beq	.nomem
	move.l	d0,a0
	move.l	a0,0(a2,d4.w)
	move.l	d7,(a0)+
	move.l	#'    ',(a0)+
	move.l	a0,d0
	bra	.exit
.nomem	move.l	#0,d0
.exit	lea	ExtAdr(a5),a0
	moveq	#26,d1
	move.l	d0,-(a7)
.chglp	movem.l	d1/a0,-(a7)
	jsr	12(a0)
	movem.l	(a7)+,d1/a0
	dbra	d1,.chglp
	move.l	(a7)+,d0
	movem.l	(a7)+,d2-d7/a2-a6
	ret2
      else
	btst	#Bnk_BitData,d2
	beq	.nodata
	lea	.dataname(pc),a0
	bra	.alloc
.nodata	lea	.workname(pc),a0
.alloc	swap	d1,d2
	rjsr	L_Bnk_Reserve
	beq	.nomem
	move.l	a0,d0
	bra	.change
.nomem	moveq	#0,d0
.change	lea	ExtAdr(a5),a0
	moveq	#26,d1
	movem.l	d0/d2-d7/a1-a6,-(a7)
.chglp	movem.l	d1/a0,-(a7)
	jsr	12(a0)
	movem.l	(a7)+,d1/a0
	dbra	d1,.chglp
	movem.l	(a7)+,d0/d2-d7/a1-a6
	rts
.dataname	dc.b "Data    "
.workname	dc.b "Work    "
      endif

FindAscr:		;Get address of AMOS screen D0 to A0
	pstart2
	cmp.l	#7,d0
	bhi	Ascr0to7
	dmove.l	SavedA5,a0
	lea	-528(a0),a1		;Why isn't this documented?
.lp	move.l	(a1)+,d1
	bmi	.noscr
	move.l	d1,a0
	move.w	EcNumber(a0),d1
	and.w	#7,d1
	cmp.w	d1,d0
	bne	.lp
	moveq	#1,d0
	bra	.exit
.noscr	moveq	#0,d0
.exit	ret2

;;;;;;;;

FindSprite:		;Find sprite # in D0.  Return addr. in A0, mask in A1
			;   and Z clear if successful, otherwise return Z set.
	pstart2
	move.w	d0,d2
	beq	.nospr
	subq.w	#1,d2
	moveq	#1,d0
	bsr	GetBankAdr
	beq	NoObjBank
	btst	#Bnk_BitBob,d0
	beq	NoObjBank
	cmp.w	(a0)+,d2
	bcc	.nospr
	moveq	#0,d0
	move.w	d2,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.l	4(a0),a1
	move.l	(a0),a0
	moveq	#1,d0
	bra	.exit
.nospr	moveq	#0,d0
.exit	ret2

FindIcon:		;Find icon # in D0.  Return addr. in A0, mask in A1
			;   and Z clear if successful, otherwise return Z set.
	pstart2
	move.w	d0,d2
	beq	.noicon
	subq.w	#1,d2
	moveq	#2,d0
	bsr	GetBankAdr
	beq	NoIconBank
	btst	#Bnk_BitIcon,d0
	beq	NoIconBank
	cmp.w	(a0)+,d2
	bcc	.noicon
	moveq	#0,d0
	move.w	d2,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.l	4(a0),a1
	move.l	(a0),a0
	moveq	#1,d0
	bra	.exit
.noicon	moveq	#0,d0
.exit	ret2

;;;;;;;;

RSList	dc.l	0

GetRetStr:		;Get memory for an AMOS-format string.  Pass RSControl
			;  structure address in A1 and string length in D0.w.
	pstart2
	swap	d0
	clr.w	d0
	swap	d0
	addq.l	#6,d0		;2 for length word and 4 for list link
	bsr	StrAlloc
	tst.l	d0
	beq	NoMem
	move.l	RSList(pc),d1
	beq	.nolist
	move.l	d1,a0
	bra	.cont
.nolist	lea	RSList(pc),a0
.cont	move.l	d0,(a0)
	move.l	d0,a0
	move.l	d1,(a0)+
	addq.l	#4,d0
	ret2

ReturnString:		;Set up string in A0 as a return value (sets D2/D3).
			;  Preserves all other registers.  Pass RSControl
			;  address in A1.
	pstart2
	movem.l	d0-d1/a0-a2,-(a7)
	move.l	a1,a2
	bsr	StrLen
	move.l	a2,a1
	move.l	a0,-(a7)
	move.l	d0,-(a7)
	bsr	GetRetStr
	move.l	d0,a1
	move.l	(a7)+,d0
	move.l	(a7)+,a0
.gotstr	move.l	a1,d3
	move.w	d0,(a1)+
	tst.w	d0
	beq	.nostr
	syscall	CopyMem
.nostr	moveq	#2,d2
	movem.l	(a7)+,d0-d1/a0-a2
	ret2

FlushRetStr:		;Flush all RS's from memory.
	pstart2
	move.l	RSList(pc),a0
	bra	.test
.loop	move.l	(a0),-(a7)
	bsr	StrFree
	move.l	(a7)+,a0
.test	move.l	a0,d0
	bne	.loop
	lea	RSList(pc),a0
	clr.l	(a0)
	ret2
