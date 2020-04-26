;Miscellaneous Intuition functions

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
	xref	IllFunc
	xref	NoReqTools
	xref	GetCurIwin2
	xref	StrAlloc

	xdef	FindImenu
	xdef	FindImenuItem
	xdef	FindImenuSub
	xdef	EZRequest


FindImenu:		;Return address of menu #D0 in D0/A0, prev in A1 (Z 
			;  flag set accordingly)
	pstart2
	move.w	d2,-(a7)
	move.w	d0,d2
	bsr	GetCurIwin2
	move.l	d0,a0
	move.l	wd_UserData(a0),a0
	move.l	we_FirstMenu(a0),a0
	sub.l	a1,a1
.loop	move.l	a0,d0
	beq	.exit
	cmp.w	mu_MenuNum(a0),d2
	beq	.exit
	bcs	.high
	move.l	a0,a1
	move.l	mu_NextMenu(a0),a0
	bra	.loop
.high	moveq	#0,d0
	move.l	d0,a0
.exit	move.w	(a7)+,d2
	tst.l	d0
	ret2

FindImenuItem:		;Return address of menu A0 item #D0 in D0/A0, prev in
			;  A1 (Z flag set accordingly)
	pstart2
	move.w	d0,d1
	move.l	mu_FirstItem(a0),a0
	sub.l	a1,a1
.loop	move.l	a0,d0
	beq	.exit
	cmp.w	mi_ItemNum(a0),d1
	beq	.exit
	bcs	.high
	move.l	a0,a1
	move.l	mi_NextItem(a0),a0
	bra	.loop
.high	moveq	#0,d0
	move.l	d0,a0
.exit	ret2

FindImenuSub:		;Return address of item A0 subitem #D0 in D0/A0, prev
			;  in A1
	pstart2
	move.l	mi_SubItem(a0),a0
	sub.l	a1,a1
.loop	move.l	a0,d1
	beq	.exit
	cmp.w	mi_ItemNum(a0),d0
	beq	.exit
	bcs	.high
	move.l	a0,a1
	move.l	mi_NextItem(a0),a0
	bra	.loop
.high	moveq	#0,d0
	move.l	d0,a0
.exit	ret2

EZRequest:		;Call rtEZRequest.  On entry, title should be in A0
			;  (AMOS format), body string should be in A1 (AMOS
			;  format), gadget string in A2 (null terminated), and
			;  additional flags (besides EZREQF_CENTERTEXT) in D0.
			;  Returns result (ID of gadget selected) in D0.
			;  If title (A0) is NULL, default title is used.
	pstart2
	tst.b	(a2)
	beq	IllFunc
	movem.l	d2/a2-a6,-(a7)
	move.l	a0,a3
	lea	.tags+12(pc),a0
	or.l	d0,(a0)
	moveq	#0,d0
	move.w	(a1)+,d0
	move.w	d0,d2
	subq.w	#1,d2
	bmi	.nobody
	move.l	a1,a4
	bsr	StrAlloc
	move.l	d0,a5
	move.l	a5,a1
.lp	move.b	(a4)+,d0
	cmp.b	#'|',d0
	bne	.next
	moveq	#10,d0
.next	move.b	d0,(a1)+
	dbra	d2,.lp
	clr.b	(a1)
.nobody	move.l	a3,d0
	beq	.nottl
	tst.w	(a3)
	beq	.nottl
	moveq	#0,d0
	move.w	(a3)+,d0
	move.w	d0,d2
	bsr	StrAlloc
	move.l	d0,a4
	moveq	#0,d0
	move.w	d2,d0
	beq	.blank
	move.l	a3,a0
	move.l	a4,a1
	syscall	CopyMem
	clr.b	0(a4,d2.w)
	bra	.call
.blank	clr.b	(a4)
	bra	.call
.nottl	dinit2	a0
	amove.l	DefReqTitle,a4,a0
.call	move.l	a5,a1
	dinit2	a5
	lea	.tags(pc),a0
	move.l	a4,20(a0)
	amove.l	CurIwindow,d0,a5
	bne	.setwin
	amove.l	CurIscreen,d0,a5
	bne	.setscr
	addq.l	#8,a0
	bra	.setreq
.setscr	move.l	d0,a6
	move.l	sc_UserData(a6),a6
	move.l	se_BaseWin(a6),d0
.setwin	move.l	d0,4(a0)
.setreq	sub.l	a3,a3
	sub.l	a4,a4
	atst.l	ReqToolsBase,a5
	beq	NoReqTools
	amove.l	ReqToolsBase,a6,a5
	call	rtEZRequestA
	tst.w	d0
	bne	.exit
	moveq	#1,d0
.lp2	move.b	(a2)+,d1
	beq	.exit
	cmp.b	#'|',d1
	bne	.lp2
	addq.w	#1,d0
	bra	.lp2
.exit	movem.l	(a7)+,d2/a2-a6
	ret2
.tags	dc.l RT_Window,0
	dc.l RTEZ_Flags,EZREQF_CENTERTEXT
	dc.l RTEZ_ReqTitle,0
	dc.l TAG_END
