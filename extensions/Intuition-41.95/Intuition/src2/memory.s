;Memory-related routines (allocating/freeing memory, structures etc.)

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

	xref	DataBase
	xref	NoMem
	xref	InternalErr
	xref	NoReqTools

	xdef	FreeImenu
	xdef	FreeImenuItem
	xdef	AllocMemClear
	xdef	StrAlloc
	xdef	StrFree
	xdef	AllocRequest
	xdef	CreatePort
	xdef	DeletePort


FreeImenu:		;Free menu in A0.
	pstart2
	movem.l	a2/a3,-(a7)
	move.l	a0,a2
	move.l	mu_FirstItem(a2),d0	;Free menu items, if any
	beq	.noitem
.lp	move.l	d0,a0
	move.l	mi_NextItem(a0),a3
	bsr	FreeImenuItem
	move.l	a3,d0
	bne	.lp
.noitem	move.l	mu_MenuName(a2),a0	;Free menu title string
	bsr	StrFree
	moveq	#mu_sizeof,d0
	move.l	a2,a1
	syscall	FreeMem
	movem.l	(a7)+,a2/a3
	ret2

FreeImenuItem:		;Free MenuItem in A0.
	pstart2
	movem.l	a2/a5,-(a7)
	move.l	a0,a2
	move.l	mi_SubItem(a2),d0
	beq	.nosub
	move.l	a2,-(a7)
.lp	move.l	d0,a2			;Free subitems
	move.l	a2,a0
	move.l	mi_NextItem(a2),a5
	bsr	FreeImenuItem
	move.l	a5,d0
	bne	.lp
	move.l	(a7)+,a2
.nosub	move.l	mi_ItemFill(a2),a5
	move.l	it_IText(a5),a0
	bsr	StrFree
	move.l	a5,a1
	moveq	#it_sizeof,d0
	syscall	FreeMem
	moveq	#mi_sizeof,d0
	move.l	a2,a1
	syscall	FreeMem
	movem.l	(a7)+,a2/a5
	ret2

AllocMemClear:		;AllocMem(size, flags | MEMF_CLEAR)
      ifd MEMF_CLEAR_BUG
	move.l	d0,-(a7)
	move.l	a6,-(a7)
	syscall	AllocMem
	move.l	(a7)+,a6
	move.l	(a7)+,d1
	tst.l	d0
	beq	.exit		;Don't generate an error - there might be
				;  stuff to clean up.
	move.l	d0,a0
	move.l	d0,a1
	addq.l	#3,d1		;Don't worry about overrun - memory is always
	lsr.l	#2,d1		;  allocated in blocks of 8 bytes.  Just make
	subq.l	#1,d1		;  sure we clear the entire requested area.
.lp	clr.l	(a1)+
	dbra	d1,.lp
	move.l	a0,d0
.exit	rts
      else
	or.l	#MEMF_CLEAR,d1
	move.l	a6,-(a7)
	syscall	AllocMem
	move.l	(a7)+,a6
	rts
      endc

StrAlloc:		;Allocate a string, length in D0 (not counting \0)
	pstart2
	move.l	d2,-(a7)
	add.l	#13,d0
	move.l	d0,d2
	moveq	#MEMF_PUBLIC,d1
	syscall	AllocMem
	move.l	d0,a0
	move.l	a0,d0
	beq	NoMem
	dlea	FirstString,a1
	move.l	(a1),a6
	move.l	a6,(a0)		;next
	move.l	a6,d0
	beq	.nonext
	move.l	a0,4(a6)	;next->prev
.nonext	move.l	a0,(a1)		;prev->next (==FirstString)
	addq.l	#4,a0
	move.l	a1,(a0)+	;prev
	move.l	d2,(a0)+	;len
	move.l	a0,d0
	move.l	(a7)+,d2
	ret2

StrFree:		;Free a string, string adr in A0
	move.l	a0,d0
	beq	.exit
	move.l	a6,-(a7)
	move.l	-(a0),d0	;len
	move.l	-(a0),a1	;prev
	move.l	-(a0),(a1)	;next (=> prev->next)
	beq	.nonext
	move.l	(a1),a1		;prev => next->prev
	move.l	4(a0),4(a1)
.nonext	move.l	a0,a1
	syscall	FreeMem
	move.l	(a7)+,a6
.exit	rts

AllocRequest:		;Allocate a ReqTools requester of type D0
	pstart2
	sub.l	a0,a0
	rtcall1	rtAllocRequestA
	tst.l	d0
	beq	NoMem
	ret2

CreatePort:	;Create a message port; priority in D0, name (if public port)
		;  in A0.  Returns port address or 0 in D0.
	movem.l	d5-d7/a2,-(a7)
	move.l	d0,d7
	move.l	a0,a2
	moveq	#-1,d0
	syscall	AllocSignal
	move.b	d0,d6
	bge	.initmp
	clr.l	d0
	bra	.exitcp
.initmp	move.l	#mp_sizeof,d0
	moveq	#MEMF_PUBLIC,d1
	bsr	AllocMemClear
	move.l	d0,d5
	bne	.initmn
	move.b	d6,d0
	syscall	FreeSignal
	clr.l	d0
	bra	.exitcp
.initmn	move.l	d0,a1
	move.l	a2,ln_Name(a1)
	move.b	d7,ln_Pri(a1)
	move.b	#NT_MSGPORT,ln_Type(a1)
	move.b	#PA_SIGNAL,mp_Flags(a1)
	move.b	d6,mp_SigBit(a1)
	move.l	a1,-(a7)
	sub.l	a1,a1
	syscall	FindTask
	move.l	(a7)+,a1
	move.l	d0,mp_SigTask(a1)
	cmp.l	#0,a2
	bne	.public
	lea	mp_MsgList(a1),a0
	move.l	a0,(a0)
	addq.l	#lh_Tail,(a0)
	clr.l	lh_Tail(a0)
	move.l	a0,lh_TailPred(a0)
	move.l	d5,d0
	bra	.exitcp
.public	move.l	d5,a1
	syscall	AddPort
	move.l	d5,d0
.exitcp	movem.l	(a7)+,d5-d7/a2
	rts

DeletePort:		;Delete a message port (in A0).
	move.l	a2,-(a7)
	cmp.b	#NT_MSGPORT,ln_Type(a0)
	beq	.okport
	move.l	#$446C5002,d1
	bsr	InternalErr
.okport	move.l	a0,a2
	tst.l	ln_Name(a2)
	beq	.delete
	move.l	a2,a1
	syscall	RemPort
.delete	move.l	#-1,mp_SigTask(a2)
	move.l	#-1,lh_Head(a2)
	move.b	mp_SigBit(a2),d0
	syscall	FreeSignal
	move.l	a2,a1
	move.l	#mp_sizeof,d0
	syscall	FreeMem
	move.l	(a7)+,a2
	rts
