;Graphics-related stuff

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
	xref	NoScr

	xdef	GetCurRP
	xdef	ClearGadget
	xdef	ReadPixel
	xdef	WritePixel
	xdef	AllocTmpRas
	xdef	FreeTmpRas


GetCurRP:		;Get current RastPort address
	pstart2
	dmove.l	CurIwindow,d0
	beq	.nowin
	move.l	d0,a0
	move.l	wd_RPort(a0),d0
	ret2
.nowin	dmove.l	CurIscreen,d0
	beq	NoScr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
	move.l	wd_RPort(a0),d0
	ret2

ClearGadget:		;Erase gadget A0 from window A1.
	pstart2
	movem.l	d2-d4,-(a7)
	move.w	gg_LeftEdge(a0),d0
	move.w	gg_TopEdge(a0),d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	gg_Width(a0),d2
	add.w	gg_Height(a0),d3
	subq.w	#1,d2
	subq.w	#1,d3
	move.w	#~GADGETTYPE,d4
	and.w	gg_GadgetType(a0),d4
	cmp.w	#STRGADGET,d4
	bne	.clear
	subq.w	#4,d0
	subq.w	#2,d1
	addq.w	#8,d2
	addq.w	#4,d3
.clear	move.l	wd_RPort(a1),a1
	gfxcall	EraseRect
	movem.l	(a7)+,d2-d4
	ret2

ReadPixel:		;Replacement for graphics.library ReadPixel()
	movem.l	d2-d3/a2,-(a7)
	move.l	rp_BitMap(a1),a0
	mulu	bm_BytesPerRow(a0),d1
	swap	d0
	clr.w	d0
	swap	d0
	move.w	d0,d2
	lsr.w	#3,d0
	add.l	d1,d0
	and.w	#7,d2
	eor.w	#7,d2
	moveq	#0,d1
	moveq	#0,d3
	addq.l	#bm_Planes,a0
.bplp	move.l	(a0)+,a2
	btst	d2,0(a2,d0.l)
	beq	.nextbp
	bset	d1,d3
.nextbp	addq.b	#1,d1
	cmp.b	bm_Depth(a1),d1
	bcs	.bplp
	move.l	d3,d0
	movem.l	(a7)+,d2-d3/a2
	rts

WritePixel:
      ifd FAST_WRITEPIXEL
;Replacement for graphics.library WritePixel()
	movem.l	d2-d5,-(a7)
	move.l	rp_BitMap(a1),a0
	mulu	bm_BytesPerRow(a0),d1
	swap	d0
	clr.w	d0
	swap	d0
	move.w	d0,d2
	lsr.w	#3,d0
	add.l	d1,d0
	and.w	#7,d2
	eor.w	#7,d2
	moveq	#7,d1
	addq.l	#bm_Planes,a0
	move.b	rp_FgPen(a1),d3
	move.b	rp_Mask(a1),d4
.bplp	move.l	(a0)+,a1
	move.l	a1,d5
	beq	.nextbp
	lsr.b	#1,d4
	beq	.nextbp
	lsr.b	#1,d3
	bcc	.clrbit
	bset	d2,0(a0,d0.l)
	bra	.nextbp
.clrbit	bclr	d2,0(a0,d0.l)
.nextbp	dbra	d1,.bplp
	move.l	d3,d0
	movem.l	(a7)+,d2-d5
	rts
      else
;Stub - just use standard WritePixel() (assumes A4 contains DataBase, just
;  like a gfxcall)
	pstart2
	dmove.l	GfxBase,a6
	jsr	_LVOWritePixel(a6)
	ret2
      endc

AllocTmpRas:		;Allocate a TmpRas structure given RastPort in A0
	pstart2
	movem.l	d3/a2-a3,-(a7)
	move.l	a0,a2
	moveq	#tr_sizeof,d0
	moveq	#MEMF_PUBLIC,d1
	syscall	AllocMem
	move.l	d0,a3
	move.l	a3,d0
	beq	NoMem
	move.l	rp_BitMap(a2),a1
	move.w	bm_BytesPerRow(a1),d0
	mulu	bm_Rows(a1),d0
	move.l	d0,d3
	moveq	#MEMF_PUBLIC|MEMF_CHIP,d1
	call	AllocMem
	tst.l	d0
	bne	.gotras
	move.l	a3,a1
	moveq	#tr_sizeof,d0
	call	FreeMem
	bra	NoMem
.gotras	move.l	d0,a1
	move.l	d3,d0
	move.l	a3,a0
	gfxcall	InitTmpRas
	move.l	a3,rp_TmpRas(a2)
	movem.l	(a7)+,d3/a2-a3
	ret2

FreeTmpRas:		;Free TmpRas structure from RastPort in A0
	move.l	a2,-(a7)
	move.l	rp_TmpRas(a0),a2
	move.l	a2,d0
	beq	.exit			;No TmpRas
	clr.l	rp_TmpRas(a0)
	move.l	tr_RasPtr(a2),a1
	move.l	tr_Size(a2),d0
	syscall	FreeMem
	move.l	a2,a1
	moveq	#tr_sizeof,d0
	syscall	FreeMem
.exit	move.l	(a7)+,a2
	rts
