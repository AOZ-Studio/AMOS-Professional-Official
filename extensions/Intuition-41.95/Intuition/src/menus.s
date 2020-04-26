;Menu routines

L_SetImenu:			;Imenu$(menu,item,sub)=s$
				;Set Imenu s$,menu,item,sub
	pstart
	move.l	a5,-(a7)
	jtcall	GetCurIwin2		;Save current window pointer
	lea	.curwin(pc),a0
	move.l	d0,(a0)
	jtcall	GetWinFlags		;If menus are already active, barf
	btst	#WEB_MENUACTIVE,d0
	bne	L_MenuActive
	move.l	(a3)+,d7		;Get menu numbers
	move.l	(a3)+,d6
	move.l	(a3)+,d5
	move.l	(a3)+,a5		;Get menu string to A5
	tst.l	d5			;Check ranges
	beq	L_IllFunc
	cmp.l	#31,d5
	bhi	L_IllFunc
	cmp.l	#63,d6
	bhi	L_IllFunc
	cmp.l	#31,d7
	bhi	L_IllFunc
	move.w	d5,d0			;Look for menu #D5
	jtcall	FindImenu
	move.l	d0,d2
	bne	.ckitem			;If found, look at items
	tst.w	d6			;Not found, item/subitem # must be 0
	bne	L_IllFunc
	tst.w	d7
	bne	L_IllFunc
	bra	.set
.ckitem	move.w	d6,d0			;Is there an item number?
	bne	.here
	tst.w	d7			;Nope, subitem # must be 0
	bne	L_IllFunc
	bra	.set			;Set menu
.here	jtcall	FindImenuItem		;Yes, look for menu item #D6
	move.l	d0,d3
	bne	.cksub			;If found, look at subitems
	tst.w	d7			;Not found, subitem # must be 0
	bne	L_IllFunc
.cksub	move.w	d7,d0			;Is there a subitem number?
	beq	.set			;No, start doing stuff
	jtcall	FindImenuSub		;Yes, look for it

.set	move.l	a0,d4			;Does structure exist?
	bne	.exists			;Yes
	tst.w	(a5)			;Are we trying to free it?
	beq	.exit			;No, exit
	bra	.create
.exists	move.l	a1,-(a7)
	tst.w	d6			;Free structure and fix links
	bne	.isitm2
	move.l	a1,d0
	bne	.del0
	move.l	.curwin(pc),a1
	move.l	wd_UserData(a1),a1
	lea	we_FirstMenu-mu_NextMenu(a1),a1
.del0	move.l	mu_NextMenu(a0),mu_NextMenu(a1)
	jtcall	FreeImenu
	bra	.chkfre
.isitm2	move.l	a1,d0
	bne	.del1
	move.l	d2,a1
	lea	mu_FirstItem-mi_NextItem(a1),a1
.del1	move.l	mi_NextItem(a0),mi_NextItem(a1)
	jtcall	FreeImenuItem
.chkfre	move.l	(a7)+,a1
	tst.w	(a5)			;Are we just freeing structure?
	beq	.exit			;Yes, quit

.create	tst.w	d6			;Create the structure
	bne	.isitem
	moveq	#mu_sizeof,d0
	bra	.alloc
.isitem	moveq	#mi_sizeof,d0
.alloc	moveq	#MEMF_PUBLIC,d1
	move.l	a1,-(a7)
	jtcall	AllocMemClear
	move.l	d0,d4			;Did we get it?
	beq	L_NoMem			;No, barf
	move.l	d4,a2
	moveq	#0,d0			;Make null-terminated string
	move.w	(a5)+,d0
	move.l	d0,d4
	jtcall	StrAlloc
	move.l	a5,a0
	move.l	d0,a1
	move.l	a1,a5
	move.l	d4,d0
	syscall	CopyMem
	move.l	(a7)+,a1
	clr.b	0(a5,d4.l)
	tst.w	d6			;Is this an item?
	bne	.isitm3			;Yes, do special stuff
	move.l	a5,mu_MenuName(a2)	;No, just set up menu
	move.w	d5,mu_MenuNum(a2)
	move.w	#MENUENABLED,mu_Flags(a2)
	lsl.w	#3,d4
	addq.w	#8,d4
	move.w	d4,mu_Width(a2)
	move.w	#10,mu_Height(a2)
	move.l	a1,d0			;Each menu 8 pixels right of previous
	beq	.munext
	move.w	mu_LeftEdge(a1),d0
	add.w	mu_Width(a1),d0
	addq.w	#8,d0
	move.w	d0,mu_LeftEdge(a2)
	move.l	a1,d0			;Fix up pointers
	bne	.muprev
.munext	move.l	.curwin(pc),a0
	move.l	wd_UserData(a0),a0
	lea	we_FirstMenu-mu_NextMenu(a0),a1
.muprev	move.l	mu_NextMenu(a1),mu_NextMenu(a2)
	move.l	a2,mu_NextMenu(a1)
	bra	.exit			;Done
.isitm3	tst.w	d7			;Set up item structure
	bne	.issub
	move.w	d6,mi_ItemNum(a2)
	move.l	d2,mi_Parent(a2)
	bra	.itemxy
.issub	move.w	d7,mi_ItemNum(a2)
	move.w	#1,mi_IsSubitem(a2)
	move.l	d3,mi_Parent(a2)
	move.l	d3,a0
	move.w	mi_LeftEdge(a0),d0
	add.w	mi_Width(a0),d0
	subq.w	#8,d0
	move.w	d0,mi_LeftEdge(a2)
.itemxy	lsl.w	#3,d4
	addq.w	#4,d4
	mvoe.w	d4,mi_Width(a2)
	move.w	#2,mi_Height(a2)
	move.l	.curwin(pc),a0		;Find out font height
	move.l	wd_RPort(a0),a0
	move.w	rp_TxHeight(a0),d0
	add.w	d0,mi_Height(a2)
	move.l	a1,d0
	beq	.itext0
	move.w	mi_TopEdge(a1),d0
	add.w	mi_Height(a1),d0
	move.w	d0,mi_TopEdge(a2)
.itext0	moveq	#it_sizeof,d0		;Allocate an IntuiText
	moveq	#MEMF_PUBLIC,d1
	move.l	a1,-(a7)
	jtcall	AllocMemClear
	move.l	(a7)+,a1
	tst.l	d0			;Did we get it?
	bne	.itext1
	move.l	a2,a1			;No, barf
	moveq	#mi_sizeof,d0
	syscall	FreeMem
	bsr	L_NoMem
.itext1	move.l	d0,mi_ItemFill(a2)	;Stick it in the item structure
	move.l	d0,a0			;Now fill it up
	move.l	a5,it_IText(a0)
	move.l	a0,a5
	move.l	.curwin(pc),a0		;Use pens, font from RastPort
	move.l	wd_RPort(a0),a0
	move.b	rp_BgPen(a0),it_FrontPen(a5)
	move.b	rp_FgPen(a0),it_BackPen(a5)
	move.b	#RP_JAM2,it_DrawMode(a5)
	move.w	#2,it_LeftEdge(a5)
	move.w	#1,it_TopEdge(a5)
	;Now set up item flags
	move.w	#ITEMTEXT|ITEMENABLED|HIGHCOMP,mi_Flags(a2)
	move.l	a1,d0			;Link item into lists
	bne	.miprev
	move.l	d2,a0
	tst.w	d7
	bne	.issub2
	lea	mu_FirstItem-mi_NextItem(a0),a1
	bra	.miprev
.issub2	move.l	d3,a0
	lea	mi_SubItem-mi_NextItem(a0),a1
.miprev	move.l	mi_NextItem(a1),mi_NextItem(a2)
	move.l	a2,mi_NextItem(a1)
.exit	move.l	(a7)+,a5		;Done!!!
	ret
.curwin	dc.l 0

L_SetImenu2:			;Imenu$(menu,item)=s$
				;Set Imenu s$,menu,item
	clr.l	-(a3)
	bra	L_SetImenu

L_SetImenu1:			;Imenu$(menu)=s$
				;Set Imenu s$,menu,item
	clr.l	-(a3)
	bra	L_SetImenu2

L_GetImenu:			;s$=Imenu$(menu,item,sub)
	pstart
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	move.l	(a3)+,d0
	beq	L_IllFunc
	cmp.l	#31,d0
	bhi	L_IllFunc
	cmp.l	#63,d2
	bhi	L_IllFunc
	cmp.l	#31,d3
	bhi	L_IllFunc
	tst.w	d2
	bne	.find
	tst.w	d3
	bne	L_IllFunc
.find	jtcall	FindImenu
	tst.l	d0
	beq	.none
	move.w	d2,d0
	bne	.getitm
	move.l	mu_MenuName(a0),a0
	bra	.done
.getitm	jtcall	FindImenuItem
	tst.l	d0
	beq	.none
	move.w	d3,d0
	bne	.getsub
	move.l	mi_ItemFill(a0),a0
	move.l	it_IText(a0),a0
	bra	.done
	jtcall	FindImenuSub
.getsub	tst.l	d0
	beq	.none
	move.l	mi_ItemFill(a0),a0
	move.l	it_IText(a0),a0
.done	lea	.rsc(pc),a1
	jtcall	ReturnString
	bra	.exit
.none	dlea	NullStr,a0
	move.l	a0,d3
	moveq	#2,d2
.exit	ret
.rsc	ds.b	rsc_sizeof

L_GetImenu2:			;s$=Imenu$(menu,item)
	clr.l	-(a3)
	bra	L_GetImenu

L_GetImenu1:			;s$=Imenu$(menu)
	clr.l	-(a3)
	bra	L_GetImenu2

L_Ichoice:			;n=Ichoice(level)
	pstart
	moveq	#0,d3
	move.l	(a3)+,d0
	subq.l	#1,d0
	beq	.menu
	subq.l	#1,d0
	beq	.item
	subq.l	#1,d0
	bne	L_IllFunc
	dmove.w	LastMenuSub,d3
	bpl	.getsub
	jtcall	GetCurInput
	move.l	d0,a0
	jtcall	GetMenu
	dmove.w	LastMenuSub,d3
.getsub	tmove.w	#-1,LastMenuSub
	bra	.exit
.menu	dmove.w	LastMenu,d3
	bpl	.getmnu
	jtcall	GetCurInput
	move.l	d0,a0
	jtcall	GetMenu
	dmove.w	LastMenu,d3
.getmnu	tmove.w	#-1,LastMenu
	bra	.exit
.item	dmove.w	LastMenuItem,d3
	bpl	.getitm
	jtcall	GetCurInput
	move.l	d0,a0
	jtcall	GetMenu
	dmove.w	LastMenuItem,d3
.getitm	tmove.w	#-1,LastMenuItem
.exit	tst.w	d3
	bpl	.exit2
	moveq	#0,d3
.exit2	moveq	#0,d2
	ret

L_ImenuOn:			;Imenu On
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	move.l	wd_UserData(a0),a2
	move.l	we_FirstMenu(a2),d0
	beq	.nomenu
	and.l	#~RMBTRAP,wd_Flags(a0)
	move.l	d0,a1
	intcall	SetMenuStrip
	moveq	#WEF_MENUACTIVE,d0
	move.l	d0,d1
	jtcall	SetWinFlags
	bra	.exit
.nomenu	or.l	#RMBTRAP,wd_Flags(a0)
	intcall	ClearMenuStrip
	and.l	#~WEF_MENUACTIVE,we_Flags(a2)
.exit	ret

L_ImenuOff:			;Imenu Off
	pstart
	jtcall	GetCurIwin2
	move.l	d0,a0
	or.l	#RMBTRAP,wd_Flags(a0)
	intcall	ClearMenuStrip
	moveq	#0,d0
	moveq	#WEF_MENUACTIVE,d1
	jtcall	SetWinFlags
	ret
