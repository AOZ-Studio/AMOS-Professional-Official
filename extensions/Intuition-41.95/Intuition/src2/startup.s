;Startup and cleanup routines

	section text,code

	xref	JumpTable
	xref	AllocRequest
	xref	AllocMemClear
	xref	CreatePort
	xref	DeletePort
	xref	StrFree
	xref	CloseIscr
	xref	CloseIwin
	xref	CloseWBIwin

	xdef	CustomError
	xdef	DataBase
	xdef	Startup
	xdef	CloseAll
	xdef	Quit


	include "offsets.i"
	include "defs.i"
	include "macros.i"
	include "macros2.i"

      ifd CREATOR
	incdir	"/AMOS1.3"
      else
	incdir	"/AMOS"
      endc
;	include "equ.s"		;PhxAss is buggy...
VblRout		equ	0
ExtAdr		equ	62*4
Sys_MyTask	equ	$2F0

;Final exit routine from intuition.s, error routine, and pointers to base
;of data area.

FinalExit	dc.l	0
CustomError	dc.l	0
DataBasePtr	dc.l	0	;Address of extension's DataBase
DataBase	dc.l	0	;Our own copy


;Data initialisation constants

IntID		equ 'IE'<<16+DataVer

i_flStackSize	equ 32768

i_strings:
i_DiskfontName	dc.b	"diskfont.library",0
i_DOSName	dc.b	"dos.library",0
i_GfxName	dc.b	"graphics.library",0
i_IntuitionName	dc.b	"intuition.library",0
i_ReqToolsName	dc.b	"reqtools.library",0
i_ConsoleName	dc.b	"console.device",0
i_DefReqTitleStr dc.b	"AMOS Request",0
i_PortName	dc.b	"AMOS IDCMP",0
n_strings	equ	8

;Warning message data.

nosig_txt	dc.b	"Intuition.lib: warning: No VBL signals available.  "
		dc.b	"Some commands may not work properly.",13,10
nosig_len	equ	*-nosig_txt

novbl_txt	dc.b	"Intuition.lib: warning: No room for VBL routine.  "
		dc.b	"Some commands may not work properly.",13,10
novbl_len	equ	*-novbl_txt

nomem_txt	dc.b	"Intuition.lib: Out of memory! (code 1)",13,10
nomem_len	equ	*-nomem_txt

nomem_ke_txt	dc.b	"Intuition.lib: Out of memory! (code 2)",13,10
nomem_ke_len	equ	*-nomem_ke_txt

nomem_ue_txt	dc.b	"Intuition.lib: Out of memory! (code 4)",13,10
nomem_ue_len	equ	*-nomem_ue_txt

nomem_stk_txt	dc.b	"Intuition.lib: Out of memory! (code 5)",13,10
nomem_stk_len	equ	*-nomem_stk_txt

nodos_txt	dc.b	"Intuition.lib: Can't open dos.library!",13,10
nodos_len	equ	*-nodos_txt

nogfx_txt	dc.b	"Intuition.lib: Can't open graphics.library!",13,10
nogfx_len	equ	*-nogfx_txt

noint_txt	dc.b	"Intuition.lib: Can't open intuition.library!",13,10
noint_len	equ	*-noint_txt

nodf_txt	dc.b	"Intuition.lib: Can't open diskfont.library!",13,10
nodf_len	equ	*-nodf_txt

nocon_txt	dc.b	"Intuition.lib: Can't open console.device!",13,10
nocon_len	equ	*-nocon_txt

nort_txt	dc.b	"Intuition.lib: warning: Can't open "
		dc.b	"reqtools.library v38.  Some commands may not work "
		dc.b	"properly.",13,10
nort_len	equ	*-nort_txt

noport_txt	dc.b	"Intuition.lib: Can't create message port!",13,10
noport_len	equ	*-noport_txt

		ds.w	0



;Write an error to stdout if possible.  Text in A0, length in D0.
OutError:
	movem.l	d2-d3/a6,-(a7)
	move.l	a0,d2
	move.l	d0,d3
	lea	.dosname(pc),a1
	moveq	#0,d0
	move.l	4,a6
	call	OpenLibrary
	tst.l	d0
	beq	.no_lib
	move.l	d0,a6
	call	Output
	move.l	d0,d1
	beq	.no_out
	call	Write
.no_out	move.l	a6,a1
	move.l	4,a6
	call	CloseLibrary
.no_lib	movem.l	(a7)+,d2-d3/a6
	rts
.dosname:
	dc.b	"dos.library",0
	ds.w 0

;Set up all the stuff we need.  On entry, D1 should point to final exit
;routine (to UnLoadSeg() this code), D0 should point to custom error
;routine (the one which calls L_ErrorExt), and A1 should contain the
;address of the DataBase variable.
Startup:
	lea	FinalExit(pc),a0
	move.l	d1,(a0)
	lea	CustomError(pc),a0
	move.l	d0,(a0)
	lea	DataBasePtr(pc),a0
	move.l	a1,(a0)
	movem.l	a4/a6,-(a7)
	move.l	#datalength,d0	;Allocate memory for data
	move.l	#MEMF_PUBLIC,d1
	bsr	AllocMemClear
	move.l	DataBasePtr(pc),a0
	move.l	d0,(a0)
	bne	.okdata
	lea	nomem_txt(pc),a0
	moveq	#nomem_len,d0
	moveq	#-1,d0
	movem.l	(a7)+,a4/a6
	rts
.okdata	lea	DataBase(pc),a0
	move.l	d0,(a0)
	move.l	d0,a4		;Initialise data area as necessary
	lea	JumpTable(pc),a0
	tmove.l	a0,IntJumpTable
	sub.l	a1,a1
	syscall	FindTask
	tmove.l	d0,MyTask
	tmove.w	#1,String1
	lea	i_strings(pc),a0
	dlea	data_strings,a1
	moveq	#n_strings-1,d0
.strlp	move.l	a0,(a1)+
.strlp2	tst.b	(a0)+
	bne	.strlp2
	dbra	d0,.strlp
	tmove.l	#i_flStackSize,flStackSize
	tmove.w	#-1,LastMenu
	tmove.w	#-1,LastMenuItem
	tmove.w	#-1,LastMenuSub
	tmove.b	#-1,Initialised	;Well, not quite yet... but close enough :-)
	tmove.l	a5,SavedA5
	move.l	a4,ExtAdr+(ExtNum-1)*16(a5)
	lea	CloseAll(pc),a0
	move.l	a0,ExtAdr+(ExtNum-1)*16+4(a5)
	lea	Quit(pc),a0
	move.l	a0,ExtAdr+(ExtNum-1)*16+8(a5)
	clr.l	ExtAdr+(ExtNum-1)*16+12(a5)
	dlea	A7StackEnd,a0
	tmove.l	a0,A7StackPtr

	move.l	4,a6
	cmp.b	#60,$212(a6)	;SysBase->VBlankFrequency
	seq	d0
	tmove.b	d0,IsNTSC
	move.w	20(a6),d1	;SysBase->lib_Version
	cmp.w	#36,d1
	scc	d0
	tmove.b	d0,WB20

	moveq	#-1,d0		;Get a VBL signal bit
	call	AllocSignal
	tmove.b	d0,VBLSignal
	bpl	.sigok		;Did we get it?
	lea	nosig_txt(pc),a0 ;No - warn the user on stdout and continue
	moveq	#nosig_len,d0	;with setup
	bsr	OutError
	bra	.getdos
.sigok	lea	VblRout(a5),a0	;Find an empty VBL handler
	moveq	#7,d0		;8 handlers available, minus 1 for DBRA
.vbl_lp	tst.l	(a0)
	beq	.gotvbl
	addq.l	#4,a0
	dbra	d0,.vbl_lp
	lea	novbl_txt(pc),a0 ;No VBL handler available
	moveq	#novbl_len,d0
	bsr	OutError
	moveq	#0,d0
	dmove.b	VBLSignal,d0
	call	FreeSignal
	tmove.b	#-1,VBLSignal
	bra	.getdos
.gotvbl	lea	VBLHandler(pc),a1  ;Got the handler!
	move.l	a1,(a0)

.getdos	dmove.l	DOSName,a1
	moveq	#0,d0
	call	OpenLibrary
	tmove.l	d0,DOSBase
	bne	.gotdos
	lea	nodos_txt(pc),a0
	move.l	#nodos_len,d0
	bsr	OutError
	bra	.nodos

.gotdos	dmove.l	IntuitionName,a1
	moveq	#0,d0
	call	OpenLibrary
	tmove.l	d0,IntuitionBase
	bne	.gotint
	lea	noint_txt(pc),a0
	move.l	#noint_len,d0
	bsr	OutError
	bra	.nodos

.gotint	move.l	d0,a6
	call	ViewAddress	;Get ViewLord address
	move.l	d0,a0
	tmove.l	d0,ViewLord
	cmp.w	#36,20(a6)	;IntuitionBase->lib_Version
	bcs	.wb13wh
	moveq	#-1,d0
	tmove.w	d0,MaxDispWidth
	tmove.w	d0,MaxDispHeight
	bra	.getgfx
.wb13wh	move.w	#449,d0
	sub.w	v_DxOffset(a0),d0
	tmove.w	d0,MaxDispWidth
	moveq	#0,d0
	dtst.w	IsNTSC
	seq	d0
	and.b	#56,d0
	add.w	#255,d0
	sub.w	v_DyOffset(a0),d0
	tmove.w	d0,MaxDispHeight

.getgfx	move.l	4,a6
	dmove.l	GfxName,a1
	moveq	#0,d0
	call	OpenLibrary
	tmove.l	d0,GfxBase
	bne	.gotgfx
	lea	nogfx_txt(pc),a0
	move.l	#nogfx_len,d0
	bsr	OutError
	bra	.nogfx

.gotgfx	dmove.l	DiskfontName,a1
	moveq	#0,d0
	call	OpenLibrary
	tmove.l	d0,DiskfontBase
	bne	.gotdf
	lea	nodf_txt(pc),a0
	move.l	#nodf_len,d0
	bsr	OutError
	bra	.nodf

.gotdf	dmove.l	ConsoleName,a0
	moveq	#-1,d0
	dlea	ConsoleRequest,a2
	move.l	a2,a1
	moveq	#0,d1
	call	OpenDevice
	tst.l	d0
	beq	.gotcon
	lea	nocon_txt(pc),a0
	move.l	#nocon_len,d0
	bsr	OutError
	bra	.nocdev
.gotcon	tmove.l	io_Device(a2),ConsoleDevice

	dmove.l	ReqToolsName,a1
	moveq	#38,d0
	call	OpenLibrary
	tmove.l	d0,ReqToolsBase
	bne	.gotrt
	lea	nort_txt(pc),a0
	move.l	#nort_len,d0
	bsr	OutError
	bra	.nort0	
.gotrt	moveq	#RT_FILEREQ,d0
	bsr	AllocRequest
	tmove.l	d0,FileReq
	beq	.nortfi
	moveq	#RT_FONTREQ,d0
	bsr	AllocRequest
	tmove.l	d0,FontReq
	beq	.nortfo
	dtst.b	WB20		;Screen mode requester, GfxBase.ChipRevBits0
	beq	.bufini		;  only available on 2.0+
	moveq	#RT_SCREENMODEREQ,d0
	bsr	AllocRequest
	tmove.l	d0,ScreenModeReq
	beq	.nortsc

.nort0	dmove.l	GfxBase,a0
	moveq	#GFXF_HR_AGNUS|GFXF_HR_DENISE,d1
	move.b	d1,d0
	and.b	gb_ChipRevBits0(a0),d0
	cmp.b	d0,d1		;Need both ECS chips for an ECS system
	seq	d0
	tmove.b	d0,IsECS
	or.b	#GFXF_AA_ALICE|GFXF_AA_LISA,d1
	move.b	d1,d0
	and.b	gb_ChipRevBits0(a0),d0
	cmp.b	d0,d1
	seq	d0
	tmove.b	d0,IsAGA

.bufini	move.l	#KeyBufSize,d0
	move.l	d0,d2
	moveq	#MEMF_PUBLIC,d1
	call	AllocMem
	tmove.l	d0,KeyBuffer
	bne	.got_ke
	lea	nomem_ke_txt(pc),a0
	move.l	#nomem_ke_len,d0
	bsr	OutError
	bra	.no_ke
.got_ke	tmove.l	d0,KeyBufPtr
	tmove.l	d0,KeyBufNext
	add.l	d2,d0
	tmove.l	d0,KeyBufEnd

	move.l	#MenuBufSize,d0
	move.l	d0,d2
	moveq	#MEMF_PUBLIC,d1
	call	AllocMem
	tmove.l	d0,MenuBuffer
	bne	.got_ue
	lea	nomem_ue_txt(pc),a0
	move.l	#nomem_ue_len,d0
	bsr	OutError
	bra	.no_ue
.got_ue	tmove.l	d0,MenuBufPtr
	tmove.l	d0,MenuBufNext
	add.l	d2,d0
	tmove.l	d0,MenuBufEnd

	dmove.l	flStackSize,d0
	moveq	#MEMF_PUBLIC,d1
	call	AllocMem
	tmove.l	d0,flStack
	bne	.gotstk
	lea	nomem_stk_txt(pc),a0
	move.l	#nomem_stk_len,d0
	bsr	OutError
	bra	.nostk
.gotstk	add.l	#1024,d0
	tmove.l	d0,flStackWarn

	dmove.l	DefReqTitleStr,a0
	tmove.l	a0,DefReqTitle

	moveq	#0,d0
	dmove.l	PortName,a0
	bsr	CreatePort
	tmove.l	d0,MyUserPort
	bne	.gotprt
	lea	noport_txt(pc),a0
	move.l	#noport_len,d0
	bsr	OutError
	bra	.noport

.gotprt	moveq	#ExtNum-1,d0	;Successfully initialised!
	bra	.exit

.noport	dmove.l	flStack,a1
	dmove.l	flStackSize,d0
	call	FreeMem
.nostk	move.l	#MenuBufSize,d0
	dmove.l	MenuBuffer,a1
	call	FreeMem
.no_ue	move.l	#KeyBufSize,d0
	dmove.l	KeyBuffer,a1
	call	FreeMem
.no_ke	dtst.l	ReqToolsBase
	beq	.nort
	dtst.b	WB20
	beq	.nortsc
	dmove.l	ScreenModeReq,a1
	rtcall2	rtFreeRequest
.nortsc	dmove.l	FontReq,a1
	rtcall2	rtFreeRequest
.nortfo	dmove.l	FileReq,a1
	rtcall2	rtFreeRequest
	move.l	4,a6
.nortfi	dmove.l	ReqToolsBase,d0
	beq	.nort
	move.l	d0,a1
	call	CloseLibrary
.nort	dlea	ConsoleRequest,a1
	call	CloseDevice
.nocdev	dmove.l	DiskfontBase,a1
	call	CloseLibrary
.nodf	dmove.l	GfxBase,a1
	call	CloseLibrary
.nogfx	dmove.l	IntuitionBase,a1
	call	CloseLibrary
.noint	dmove.l	DOSBase,a1
	call	CloseLibrary
.nodos	move.l	DataBase(pc),a1		;free data area
	move.l	#datalength,d0
	call	FreeMem
	clr.l	ExtAdr+ExtNum*16+8(a5)	;don't try to clean up
	moveq	#-1,d0
.exit	movem.l	(a7)+,a4/a6
	rts

CloseAll:
	movem.l	a4/a6,-(a7)
	dinit	a4
	tmove.b	#-1,InReset
	move.l	a5,-(a7)

.scrlp	dmove.l	FirstIscreen,a2
	move.l	a2,d0
	beq	.scdone
	move.l	sc_UserData(a2),a1
	move.l	se_FirstIwindow(a1),a0
.winlp	move.l	a0,d0
	beq	.close
	move.l	wd_UserData(a0),a1
	move.l	we_NextIwin(a1),a5
	bsr	CloseIwin
	move.l	a5,a0
	bra	.winlp
.close	move.l	a2,a0
	bsr	CloseIscr
	bra	.scrlp

.scdone
.wblp	dmove.l	FirstWBIwindow,a0
	move.l	a0,d0
	beq	.wbdone
	bsr	CloseWBIwin
	bra	.wblp

.wbdone
.strlp	dmove.l	FirstString,d2
	tst.l	d2
	beq	.stdone
	move.l	d2,a0
	lea	12(a0),a0
	bsr	StrFree
	bra	.strlp

;The screen/window pointers had better be null now...

.stdone	dmove.l	KeyBufPtr,a0
	tmove.l	a0,KeyBufNext
	dmove.l	MenuBufPtr,a0
	tmove.l	a0,MenuBufNext
	dclr.l	LastError
	dclr.l	LastErrorStr
	dclr.b	TrapErrors
	dclr.b	ErrorTrapped
	dlea	DefReqTitleStr,a0
	tmove.l	a0,DefReqTitle
	moveq	#-1,d0
	tmove.w	d0,LastMenu
	tmove.w	d0,LastMenuItem
	tmove.w	d0,LastMenuSub

	move.l	(a7)+,a5
	dclr.b	InReset
	movem.l	(a7)+,a4/a6
	rts

Quit:
	movem.l	a4/a6,-(a7)
	dinit	a4
	tmove.b	#-1,Quitting
	bsr	CloseAll
	dmove.l	MyUserPort,a0
	bsr	DeletePort
	dmove.l	flStack,d0
	beq	.nostk
	move.l	d0,a1
	dmove.l	flStackSize,d0
	syscall	FreeMem
.nostk	move.l	#MenuBufSize,d0
	dmove.l	MenuBuffer,a1
	call	FreeMem
	move.l	#KeyBufSize,d0
	dmove.l	KeyBuffer,a1
	call	FreeMem
	dtst.l	ReqToolsBase
	beq	.nort
	dmove.l	ReqToolsBase,a6
	dmove.l	ScreenModeReq,d0
	beq	.nortsc
	move.l	d0,a1
	call	rtFreeRequest
.nortsc	dmove.l	FontReq,a1
	call	rtFreeRequest
	dmove.l	FRFileList0,d0
	beq	.nofl
	move.l	d0,a0
	call	rtFreeFileList
.nofl	dmove.l	FileReq,a1
	call	rtFreeRequest
	move.l	a6,a1
	move.l	4,a6
	call	CloseLibrary
.nort	dlea	ConsoleRequest,a1
	call	CloseDevice
	dmove.l	GfxBase,a1
	call	CloseLibrary
	dmove.l	DOSBase,a1
	call	CloseLibrary
	dmove.l	IntuitionBase,a1
	call	CloseLibrary
	moveq	#0,d0
	dmove.b	VBLSignal,d0
	bmi	.nosig
	call	FreeSignal
.nosig	move.l	a4,a1
	move.l	#datalength,d0
	call	FreeMem
.exit	movem.l	(a7)+,a4/a6
	move.l	FinalExit(pc),a0
	jmp	(a0)


;The VBL handler - sends AMOS a signal at each VBL.
VBLHandler:
	move.l	a6,-(a7)
	dinit2	a0
	amove.l	MyTask,a1,a0
	moveq	#0,d1
	amove.b	VBLSignal,d1,a0
	moveq	#1,d0
	lsl.l	d1,d0
	syscall	Signal
	move.l	(a7)+,a6
	rts
