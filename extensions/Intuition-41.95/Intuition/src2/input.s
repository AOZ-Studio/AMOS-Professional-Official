;Input routines

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
	xref	NoScr
	xref	InternalErr
	xref	InternalErr2
	xref	ProgInt
	xref	GetCurWin
	xref	GetSomeWinFlags
	xref	SetSomeWinFlags

	xdef	GetCurInput
	xdef	ConvRawKey
	xdef	DoEvent
	xdef	GetKey
	xdef	GetMouse
	xdef	GetMenu


GetCurInput:			;Get current input port to D0
	pstart2
	dmove.l	CurIwindow,d0
	beq	.nowin
	move.l	d0,a0
	move.l	wd_UserPort(a0),d0
	ret2
.nowin	dmove.l	CurIscreen,d0
	beq	NoScr
	move.l	d0,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),a0
	move.l	wd_UserPort(a0),d0
	ret2

ConvRawKey:			;Convert raw key code to character.  D0=code,
				;  D1=qualifier.  Return 0 if not convertable.
	pstart2
	move.l	a2,-(a7)
	sub.l	#ie_sizeof+2,a7
	clr.l	ie_NextEvent(a7)
	move.b	#1,ie_Class(a7)		;IECLASS_RAWKEY
	move.w	d0,ie_Code(a7)
	move.w	d1,ie_Qualifier(a7)
	dmove.l	ConsoleDevice,a6
	move.l	a7,a0
	lea	ie_sizeof+1(a7),a1
	moveq	#1,d1
	sub.l	a2,a2
	jsr	-$30(a6)		;RawKeyConvert()
	add.l	#ie_sizeof,a7
	tst.l	d0
	bmi	.notok
	move.w	(a7)+,d0
	bra	.done
.notok	moveq	#0,d0
	addq.l	#2,a7
.done	move.l	(a7)+,a2
	ret2

DoEvent:		;Get an event from port in A0 and do something.  Keep
			;  repeating until im_Class & D0 or no more messages.
			;  Return Z clear if im_Class & D0, set otherwise.
			;  im_Class of the last message is returned in D0.
			;  Depending on im_Class, a return value may be in D1.
	pstart2
	movem.l	d2-d3/a2,-(a7)
	move.l	d0,d2
	move.l	a0,-(a7)
	cmp.b	#NT_MSGPORT,ln_Type(a0)
	beq	.lp
	move.l	#$44457605,d1
	bsr	InternalErr
.lp	move.l	(a7),a0
	syscall	GetMsg
	tst.l	d0
	beq	.exit
	move.l	d0,a0
	move.l	a0,a2
	move.l	im_Class(a0),d3
	cmp.l	#CLOSEWINDOW,d3
	bne	.notcw
	move.l	im_IDCMPWindow(a0),a0
	moveq	#WEF_CLOSED,d0
	move.l	d0,d1
	bsr	SetSomeWinFlags
	bra	.endlp
.notcw	cmp.l	#RAWKEY,d3
	bne	.notrk
	move.w	im_Code(a0),d0
	cmp.w	#$60,d0			;Ignore key up and shifting-key events
	bcs	.keyok
	moveq	#0,d3
	bra	.endlp
.keyok	move.w	im_Qualifier(a0),d1
	dmove.l	KeyBufPtr,a0		;Get pointer to next event to read
	dmove.l	KeyBufNext,a1		;Get pointer to current end of buffer
	sub.w	#ke_sizeof,a1		;Are we out of buffer?
	cmp.l	a0,a1
	bne	.setke
	moveq	#0,d3			;Yes, discard event
	bra	.endlp
.setke	move.b	d0,ke_code(a0)		;Save event data in buffer
	move.b	d1,ke_qual(a0)
	move.l	a0,-(a7)
	bsr	ConvRawKey
	move.l	(a7)+,a0
	move.b	d0,ke_char(a0)
	add.l	#ke_sizeof,a0
	dcmp.l	KeyBufEnd,a0		;Update pointer (buffer is circular)
	bne	.chkbrk
	dmove.l	KeyBuffer,a0
.chkbrk	tmove.l	a0,KeyBufPtr
	cmp.b	#3,d0			;Ctrl-C interrupts program
	bne	.endlp
	bra	ProgInt
.notrk	cmp.l	#MOUSEBUTTONS,d3
	bne	.notmb
	move.b	im_Code+1(a0),d0
	bclr	#7,d0
	seq	d1			;D1 == 0 if release, != 0 if press
	and.w	#3,d0			;SELECTDOWN is $68, MENUDOWN $69
	tst.b	d1
	bne	.mbset
	dmove.b	MouseState,d1
	bclr	d0,d1
	tmove.b	d1,MouseState
	bra	.mbdone
.mbset	dmove.b	MouseState,d1
	bclr	d0,d1
	tmove.b	d1,MouseState
.mbdone	bra	.endlp
.notmb	cmp.l	#MENUPICK,d3
	bne	.notmu
	move.w	im_Code(a0),d1
	dmove.l	MenuBufPtr,a0
	dmove.l	MenuBufNext,a1
	sub.w	#ue_sizeof,a1
	cmp.l	a0,a1
	bne	.setmu
	moveq	#0,d3
	bra	.endlp
.setmu	move.w	d1,ue_menupick(a0)
	add.l	#ue_sizeof,a0
	dcmp.l	MenuBufEnd,a0
	bne	.muset
	dmove.l	MenuBuffer,a0
.muset	tmove.l	a0,MenuBufPtr
	bra	.endlp
.notmu	cmp.l	#GADGETDOWN,d3
	bne	.notgd
	move.l	im_IAddress(a0),a1
	move.l	gg_UserData(a1),a0
	;Check whether this is really one of our gadgets.  (It should be,
	;  but this can't hurt...)
	cmp.l	#GADGET_MAGIC,ge_MagicID(a0)
	bne	.badgad
	or.l	#GEF_GADGETDOWN,ge_Flags(a0)
	moveq	#0,d0				;Return gadget number
	move.w	gg_GadgetID(a1),d0
	bra	.endlp
.notgd	cmp.l	#GADGETUP,d3
	bne	.notgu
	move.l	im_IAddress(a0),a1
	move.l	gg_UserData(a1),a0
	cmp.l	#GADGET_MAGIC,ge_MagicID(a0)
	bne	.badgad
	and.l	#~GEF_GADGETDOWN,ge_Flags(a0)
	moveq	#0,d0				;Return gadget number
	move.w	gg_GadgetID(a1),d0
	move.w	#~GADGETTYPE,d1
	and.w	gg_GadgetType(a1),d1
	cmp.w	#BOOLGADGET,d1
	bne	.endlp
	move.w	#TOGGLESELECT,d1
	and.w	gg_Activation(a1),d1
	bne	.endlp
	addq.w	#1,ge_HitCount(a0)
	bra	.endlp
.badgad	moveq	#0,d3
	bra	.endlp
.notgu
.endlp	move.l	d0,-(a7)
	move.l	a2,a1
	syscall	ReplyMsg
	move.l	(a7)+,d1			;Message's return value to D1
	cmp.l	#CLOSEWINDOW,d3
	beq	.done
.test	and.l	d2,d3
	beq	.lp
.done	move.l	d3,d0
.exit	addq.l	#4,a7
	movem.l	(a7)+,d2-d3/a2
	ret2

GetKey:			;Read key from buffer, return Z set if no key pressed.
			;  Input port in A0.
	pstart2
	cmp.b	#NT_MSGPORT,ln_Type(a0)
	beq	.portok
	move.l	#$6B655F02,d1
	bsr	InternalErr
.portok	move.l	#RAWKEY,d0
	bsr	DoEvent
	dmove.l	KeyBufNext,a0
	dcmp.l	KeyBufPtr,a0
	beq	.nokey
	moveq	#0,d0
	move.b	ke_code(a0),d0
	tmove.w	d0,LastCode
	move.b	ke_qual(a0),d0
	tmove.w	d0,LastQual
	move.b	ke_char(a0),d0
	tmove.b	d0,LastChar
	add.l	#ke_sizeof,a0
	dcmp.l	KeyBufEnd,a0
	bcs	.set
	dmove.l	KeyBuffer,a0
.set	tmove.l	a0,KeyBufNext
	moveq	#1,d1
	ret2
.nokey	dclr.w	LastCode
	dclr.w	LastQual
	dclr.b	LastChar
	moveq	#0,d0
	ret2

GetMouse:		;Read MB event, return Z set if none available.  Input
			;  port in A0.
	pstart2
	cmp.b	#NT_MSGPORT,ln_Type(a0)
	beq	.portok
	move.l	#$6D655F02,d1
	bsr	InternalErr
.portok	move.l	#MOUSEBUTTONS,d0
	bsr	DoEvent
	ret2

GetMenu:		;Read menu event, return Z set if none available.
			;  Input port in A0.
	pstart2
	movem.l	d2/a2,-(a7)
	move.l	a0,a2
	cmp.b	#NT_MSGPORT,ln_Type(a2)
	beq	.portok
	move.l	#$75655F04,d1
	bsr	InternalErr
.portok	move.l	#MENUPICK,d0
	move.l	a2,a0
	bsr	DoEvent
	dmove.l	MenuBufNext,a0
	dcmp.l	MenuBufPtr,a0
	beq	.nomenu
	move.w	ue_menupick(a0),d2
	add.l	#ue_sizeof,a0
	dcmp.l	MenuBufEnd,a0
	bcs	.set
	dmove.l	MenuBuffer,a0
.set	tmove.l	a0,MenuBufNext
	cmp.w	#MENUNULL,d2
	beq	.portok
	bsr	GetCurWin
	tst.l	d0
	bne	.okwin
	move.l	#$75655F16,d1
	bsr	InternalErr
.okwin	move.l	d0,a0
	move.l	wd_UserData(a0),a0
	move.l	we_FirstMenu(a0),a0
	move.w	d2,d0
	intcall	ItemAddress
	tst.l	d0
	bne	.okitem
	move.l	#$75655F1F,d1
	exg	d2,d3
	moveq	#0,d2
	move.w	d3,d2
	bsr	InternalErr2
.okitem	move.l	d0,a0
	tst.w	mi_IsSubitem(a0)
	bne	.issub
	dclr.w	LastMenuSub
	bra	.doitem
.issub	tmove.w	mi_ItemNum(a0),LastMenuSub
	move.l	mi_Parent(a0),a0
.doitem	tmove.w	mi_ItemNum(a0),LastMenuItem
	move.l	mi_Parent(a0),a0
	tmove.w	mu_MenuNum(a0),LastMenu
	moveq	#1,d1
	movem.l	(a7)+,d2/a2
	ret2
.nomenu	moveq	#0,d0
	movem.l	(a7)+,d2/a2
	ret2
