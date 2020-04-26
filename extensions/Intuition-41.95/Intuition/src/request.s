;Requester routines

L_IrequestFile:		;=Irequest File$(title$,pat$,def$)
	pstart
	move.l	(a3)+,d7
	move.l	(a3)+,a2
	move.l	a2,d0
	beq	.nopat
	tst.w	(a2)
	beq	.nopat
	moveq	#0,d0
	move.w	(a2)+,d0
	add.l	d0,a2
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a0
	add.l	d2,a0
	clr.b	(a0)
	sub.l	a1,a1
	subq.l	#1,d2
.lp	move.b	-(a2),d0
	move.b	d0,-(a0)
	cmp.b	#':',d0
	beq	.gotp
	cmp.b	#'/',d0
	bne	.endlp
.gotp	move.l	a1,d0
	beq	.endlp
	move.l	a0,a1
.endlp	dbra	d2,.lp
	move.l	a0,a2
	move.l	a1,d0
	beq	.nopath
	clr.b	(a1)+
	move.l	#TAG_END,-(a7)
	move.l	a1,-(a7)
	move.l	#RTFI_MatchPat,-(a7)
	move.l	a0,-(a7)
	move.l	#RTFI_Dir,-(a7)
	move.l	a7,a0
	dmove.l	FileReq,a1
	rtcall	rtChangeReqAttrA
	lea	20(a7),a7
	bra	.gotpth
.nopath	move.l	#TAG_END,-(a7)
	move.l	a0,-(a7)
	move.l	#RTFI_MatchPat,-(a7)
	move.l	a7,a0
	dmove.l	FileReq,a1
	rtcall	rtChangeReqAttrA
	lea	12(a7),a7
.gotpth	move.l	a2,a0
	jtcall	StrFree
.nopat	move.l	(a3)+,a2
	move.l	a3,-(a7)
	move.l	a2,d0
	beq	.nottl0
	tst.w	(a2)
	bne	.havttl
.nottl0	sub.l	a3,a3
	bra	.dodef
.havttl	moveq	#0,d0
	move.w	(a2)+,d0
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a3
	move.l	a3,a1
	move.l	a2,a0
	move.l	d2,d0
	syscall	CopyMem
	clr.b	0(a3,d2.l)
.dodef	dlea	Filename108,a2
	moveq	#0,d2
	tst.l	d7
	beq	.nodef
	move.l	a2,a1
	move.l	d7,a0
	move.w	(a0)+,d2
	move.l	d2,d0
	syscall	CopyMem
.nodef	clr.b	0(a2,d2.l)
.doreq	lea	.tags(pc),a0
	dmove.l	CurIwindow,d0
	bne	.setwin
	dmove.l	CurIscreen,d0
	bne	.setscr
	addq.l	#8,a0
	bra	.setreq
.setscr	move.l	d0,a1
	move.l	sc_UserData(a1),a1
	move.l	se_BaseWin(a1),d0
.setwin	move.l	d0,4(a0)
.setreq	dmove.l	FileReq,a1
	rtcall	rtFileRequestA
	move.l	d0,-(a7)
	move.l	a3,a0
	jtcall	StrFree
.nottl	move.l	(a7)+,d0
	beq	.cancel
	dtst.b	Filename108
	bne	.gotfil
.cancel	dlea	NullStr,a0
	move.l	a0,d3
	bra	.exit
.gotfil	dmove.l	FileReq,a1
	moveq	#-1,d0
	move.l	rtfi_Dir(a1),a1
	tst.b	(a1)
	bne	.yesdir
	clr.l	-(a7)
	bra	.nodir
.yesdir	move.l	a1,a0
.lp2	addq.w	#1,d0
	tst.b	(a0)+
	bne	.lp2
	move.l	a1,-(a7)
	subq.w	#1,d0
.nodir	dlea	Filename108,a0
	move.l	a0,a2
.lp3	addq.w	#1,d0
	tst.b	(a0)+
	bne	.lp3
	move.w	d0,d2
	addq.l	#4,d0
	lea	.rsc(pc),a1
	jtcall	GetRetStr
	move.l	(a7),a1
	move.l	a0,(a7)
	move.w	d2,(a0)+
	move.l	a1,d0
	beq	.putfil
.lp4	move.b	(a1)+,(a0)+
	bne	.lp4
	subq.l	#1,a0
	cmp.b	#':',-1(a0)
	beq	.putfil
	cmp.b	#'/',-1(a0)
	beq	.putfil
	move.b	#'/',(a0)+
	move.l	(a7),a1
	addq.w	#1,(a1)
.putfil	move.b	(a2)+,(a0)+
	bne	.putfil
	move.l	(a7)+,d3
.exit	moveq	#2,d2
	move.l	(a7)+,a3
	ret
.tags	dc.l	RT_Window,0
	dc.l	RTFI_Flags,FREQF_PATGAD
	dc.l	TAG_END
.rsc	ds.b	rsc_sizeof

L_IrequestFile2:	;=Irequest File$(title$,pat$)
	clr.l	-(a3)
	bra	L_IrequestFile

L_IrequestFile1:	;=Irequest File$(title$)
	clr.l	-(a3)
	bra	L_IrequestFile2

L_IrequestFile0:	;=Irequest File$
	clr.l	-(a3)
	bra	L_IrequestFile1

L_IreqFileMulti:	;=Irequest File Multi$(title$,pat$)
	pstart
	dmove.l	FRFileList0,a0
	rtcall	rtFreeFileList
	move.l	(a3)+,a2
	move.l	a2,d0
	beq	.nopat
	tst.w	(a2)
	beq	.nopat
	moveq	#0,d0
	move.w	(a2)+,d0
	add.l	d0,a2
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a0
	add.l	d2,a0
	clr.b	(a0)
	sub.l	a1,a1
	subq.l	#1,d2
.lp	move.b	-(a2),d0
	move.b	d0,-(a0)
	cmp.b	#':',d0
	beq	.gotp
	cmp.b	#'/',d0
	bne	.endlp
.gotp	move.l	a1,d0
	beq	.endlp
	move.l	a0,a1
.endlp	dbra	d2,.lp
	move.l	a0,a2
	move.l	a1,d0
	beq	.nopath
	clr.b	(a1)+
	move.l	#TAG_END,-(a7)
	move.l	a1,-(a7)
	move.l	#RTFI_MatchPat,-(a7)
	move.l	a0,-(a7)
	move.l	#RTFI_Dir,-(a7)
	move.l	a7,a0
	dmove.l	FileReq,a1
	rtcall	rtChangeReqAttrA
	lea	20(a7),a7
	bra	.gotpth
.nopath	move.l	#TAG_END,-(a7)
	move.l	a0,-(a7)
	move.l	#RTFI_MatchPat,-(a7)
	move.l	a7,a0
	dmove.l	FileReq,a1
	rtcall	rtChangeReqAttrA
	lea	12(a7),a7
.gotpth	move.l	a2,a0
	jtcall	StrFree
.nopat	move.l	(a3)+,a2
	move.l	a3,-(a7)
	move.l	a2,d0
	beq	.doreq
	tst.w	(a2)
	bne	.havttl
.nottl0	sub.l	a3,a3
	bra	.doreq
.havttl	moveq	#0,d0
	move.w	(a2)+,d0
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a3
	move.l	a3,a1
	move.l	a2,a0
	move.l	d2,d0
	syscall	CopyMem
	clr.b	0(a3,d2.l)
.doreq	dlea	Filename108,a2
	lea	.tags(pc),a0
	dmove.l	CurIwindow,d0
	bne	.setwin
	dmove.l	CurIscreen,d0
	bne	.setscr
	addq.l	#8,a0
	bra	.setreq
.setscr	move.l	d0,a1
	move.l	sc_UserData(a1),a1
	move.l	se_BaseWin(a1),d0
.setwin	move.l	d0,4(a0)
.setreq	dmove.l	FileReq,a1
	rtcall	rtFileRequestA
	move.l	d0,-(a7)
	move.l	a3,a0
	jtcall	StrFree
	move.l	(a7)+,d0
	beq	.cancel
	move.l	d0,a2
	tmove.l	a2,FRFileList0
	tmove.l	rtfl_Next(a2),FRFileList
	bra	.gotfil
.cancel	dlea	NullStr,a0
	move.l	a0,d3
	dclr.l	FRFileList0
	dclr.l	FRFileList
	bra	.exit
.gotfil	dmove.l	FileReq,a1
	move.l	rtfi_Dir(a1),a1
	tst.b	(a1)
	bne	.yesdir
	dclr.l	FRDir
	moveq	#0,d0
	bra	.nodir
.yesdir	moveq	#-1,d0
	tmove.l	a1,FRDir
	move.l	a1,a0
.lp2	addq.l	#1,d0
	tst.b	(a0)+
	bne	.lp2
	tmove.l	d0,FRDirLen
.nodir	move.l	rtfl_StrLen(a2),d5
	add.l	d5,d0
	move.l	rtfl_Name(a2),a2
	move.l	d0,d2
	addq.l	#3,d0
	lea	.rsc(pc),a1
	jtcall	GetRetStr
	move.l	a0,-(a7)
	move.w	d2,(a0)+
	dmove.l	FRDir,d0
	beq	.putfil
	move.l	a0,-(a7)
	move.l	a0,a1
	move.l	d0,a0
	dmove.l	FRDirLen,d0
	syscall	CopyMem
	move.l	(a7)+,a0
	dmove.l	FRDirLen,d0
	add.l	d0,a0
	cmp.b	#':',-1(a0)
	beq	.putfil
	cmp.b	#'/',-1(a0)
	beq	.putfil
	move.b	#'/',(a0)+
	move.l	(a7),a1
	addq.w	#1,(a1)
.putfil	move.l	d5,d0
	move.l	a0,a1
	move.l	a2,a0
	syscall	CopyMem
	move.l	(a7)+,d3
.exit	moveq	#2,d2
	move.l	(a7)+,a3
	ret
.tags	dc.l	RT_Window,0
	dc.l	RTFI_Flags,FREQF_PATGAD|FREQF_MULTISELECT
	dc.l	TAG_END
.rsc	ds.b	rsc_sizeof

L_IreqFileMulti1:	;=Irequest File Multi$(title$)
	clr.l	-(a3)
	bra	L_IreqFileMulti

L_IreqFileMulti0:	;=Irequest File Multi$
	clr.l	-(a3)
	bra	L_IreqFileMulti1

L_IreqFileNext:		;=Irequest File Next$
	pstart
	dmove.l	FRFileList,d0
	bne	.gotfl
	dlea	NullStr,a0
	move.l	a0,d3
	bra	.exit
.gotfl	move.l	d0,a2
	tmove.l	rtfl_Next(a2),FRFileList
	move.l	rtfl_StrLen(a2),d2
	move.l	d2,d4
	dmove.l	FRDir,d6
	beq	.nodir
	subq.w	#1,d2
	move.l	d6,a0
	move.l	FRDirLen,d5
	add.l	d5,d2
.nodir	move.l	d2,d0
	addq.l	#3,d0
	lea	.rsc(pc),a1
	jtcall	GetRetStr
	move.l	a1,d7
	move.w	d2,(a1)+
	move.l	4,a6
	move.l	d6,d0
	beq	.nodir2
	move.l	d6,a0
	move.l	d5,d0
	call	CopyMem
	move.l	d7,a1
	addq.l	#2,a1
	add.l	d5,a1
	cmp.b	#'/',-1(a1)
	beq	.nodir2
	cmp.b	#':',-1(a1)
	beq	.nodir2
	move.b	#'/',(a1)+
	move.l	d7,a0
	addq.w	#1,(a0)
.nodir2	move.l	rtfl_Name(a2),a0
	move.l	d4,d0
	call	CopyMem
	move.l	d7,d3
.exit	moveq	#2,d2
	ret
.rsc	ds.b	rsc_sizeof

L_IrequestFont:		;=Irequest Font$(title)
	pstart
	move.l	(a3)+,a2
	move.l	a3,-(a7)
	move.l	a2,d0
	beq	.nottl0
	tst.w	(a2)
	bne	.havttl
.nottl0	sub.l	a3,a3
	bra	.doreq
.havttl	moveq	#0,d0
	move.w	(a2)+,d0
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a3
	move.l	a3,a1
	move.l	a2,a0
	move.l	d2,d0
	syscall	CopyMem
	clr.b	0(a3,d2.l)
.doreq	lea	.tags(pc),a0
	dmove.l	CurIwindow,d0
	bne	.setwin
	dmove.l	CurIscreen,d0
	bne	.setscr
	addq.l	#8,a0
	bra	.setreq
.setscr	move.l	d0,a1
	move.l	sc_UserData(a1),a1
	move.l	se_BaseWin(a1),d0
.setwin	move.l	d0,4(a0)
.setreq	dmove.l	FontReq,a1
	rtcall	rtFontRequestA
	move.l	d0,-(a7)
	move.l	a3,d0
	beq	.nottl
	move.l	a3,a0
	jtcall	StrFree
.nottl	move.l	(a7)+,d0
	tst.l	d0
	bne	.gotfnt
	dlea	NullStr,a0
	move.l	a0,d3
	bra	.exit
.gotfnt	dmove.l	FontReq,a1
	move.l	rtfo_Attr+ta_Name(a1),a0
	move.w	rtfo_Attr+ta_YSize(a1),d5
	move.l	a0,a2
	moveq	#-1,d0
.lp3	addq.w	#1,d0
	tst.b	(a0)+
	bne	.lp3
	move.w	d0,d2
	addq.w	#8,d0
	lea	.rsc(pc),a1
	jtcall	GetRetStr
	move.w	d2,(a0)+
.putnam	move.b	(a2)+,(a0)+
	bne	.putnam
	move.b	#'/',-1(a0)
	addq.w	#1,(a1)
	moveq	#0,d0
	move.w	d5,d0
	moveq	#-1,d1
.sizelp	addq.w	#1,d1
	divu	#10,d0
	swap	d0
	clr.w	d0
	swap	d0
	tst.l	d0
	bne	.sizelp
	move.w	d1,d2
	addq.w	#1,d2
	moveq	#0,d0
	move.w	d5,d0
.numlp	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,0(a0,d1.w)
	clr.w	d0
	swap	d0
	addq.w	#1,(a1)
	dbra	d1,.numlp
	move.l	a1,d3
.exit	moveq	#2,d2
	move.l	(a7)+,a3
	ret
.tags	dc.l	RT_Window,0
	dc.l	RTFO_Flags,FREQF_SCALE
	dc.l	TAG_END
.rsc	ds.b	rsc_sizeof

L_IrequestFont0:	;=Irequest Font$
	clr.l	-(a3)
	bra	L_IrequestFont

L_IrequestScreen:	;=Irequest Screen(title$)
	pstart
	dtst.b	WB20
	beq	L_NeedKick20
	move.l	(a3)+,a2
	move.l	a3,-(a7)
	move.l	a2,d0
	beq	.nottl0
	tst.w	(a2)
	bne	.havttl
.nottl0	sub.l	a3,a3
	bra	.doreq
.havttl	moveq	#0,d0
	move.w	(a2)+,d0
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a3
	move.l	a3,a1
	move.l	a2,a0
	move.l	d2,d0
	syscall	CopyMem
	clr.b	0(a3,d2.l)
.doreq	lea	.tags(pc),a0
	dmove.l	CurIwindow,d0
	bne	.setwin
	dmove.l	CurIscreen,d0
	bne	.setscr
	addq.l	#8,a0
	bra	.setreq
.setscr	move.l	d0,a1
	move.l	sc_UserData(a1),a1
	move.l	se_BaseWin(a1),d0
.setwin	move.l	d0,4(a0)
.setreq	dmove.l	ScreenModeReq,a1
	rtcall	rtScreenModeRequestA
	move.l	d0,-(a7)
	move.l	a3,d0
	beq	.nottl
	move.l	a3,a0
	jtcall	StrFree
.nottl	move.l	(a7)+,d0
	tst.l	d0
	bne	.ok
	moveq	#0,d3
	bra	.exit
.ok	moveq	#-1,d3
	dmove.l	ScreenModeReq,a0
	dlea	ScreenData,a1
	move.w	rtsc_DisplayWidth(a0),sd_Width(a1)
	move.w	rtsc_DisplayHeight(a0),sd_Height(a1)
	move.l	rtsc_DisplayID(a0),d0
	move.l	d0,sd_DisplayID(a1)
	and.w	#MODES,d0
	move.w	d0,sd_ViewModes(a1)
	move.w	rtsc_DisplayDepth(a0),d1
	and.w	#HAM,d0
	bne	.ham
	moveq	#1,d0
	lsl.l	d1,d0
	move.l	d0,sd_NumCols(a1)
	bra	.exit
.ham	cmp.w	#6,d1
	bne	.ham8
	move.l	#4096,sd_NumCols(a1)
	bra	.exit
.ham8	move.l	#262144,sd_NumCols(a1)
.exit	moveq	#0,d2
	move.l	(a7)+,a3
	ret
.tags	dc.l RT_Window,0
	dc.l RTSC_Flags,SCREQF_SIZEGADS|SCREQF_DEPTHGAD
	dc.l TAG_END

L_IrequestScreen0:	;=Irequest Screen
	clr.l	-(a3)
	bra	L_IrequestScreen

L_IreqScrMode:		;=Irequest Screen Mode(n)
	pstart
	dlea	ScreenData,a0
	moveq	#0,d2
	move.l	(a3)+,d0
	bne	.dispID
	moveq	#0,d3
	move.w	sd_ViewModes(a0),d3
	ret
.dispID	move.l	sd_DisplayID(a0),d3
	ret

L_IreqScrCols:		;=Irequest Screen Colour
	pstart
	dlea	ScreenData,a0
	move.l	sd_NumCols(a0),d3
	moveq	#0,d2
	ret

L_IreqScrWidth:		;=Irequest Screen Width
	pstart
	dlea	ScreenData,a0
	moveq	#0,d3
	move.w	sd_Width(a0),d3
	moveq	#0,d2
	ret

L_IreqScrHeight:	;=Irequest Screen Height
	pstart
	dlea	ScreenData,a0
	moveq	#0,d3
	move.w	sd_Height(a0),d3
	moveq	#0,d2
	ret

L_IrequestWarning:	;=Irequest Warning(title$,s$,ok$,cancel$)
	pstart
	move.l	(a3)+,a2
	move.w	(a2)+,d3
	beq	L_IllFunc
	move.l	(a3)+,a1
	move.w	(a1)+,d2
	beq	L_IllFunc
	move.l	a1,-(a7)
	moveq	#0,d0
	move.w	d2,d0
	add.w	d3,d0
	addq.w	#1,d0
	jtcall	StrAlloc
	move.l	(a7)+,a0
	move.l	d0,d4
	move.l	d0,a1
	moveq	#0,d0
	move.w	d2,d0
	syscall	CopyMem
	move.l	d4,a0
	add.w	d2,a0
	move.b	#'|',(a0)+
	exg	a0,a2
	move.l	a2,a1
	moveq	#0,d0
	move.w	d3,d0
	call	CopyMem
	clr.b	0(a2,d3.w)
	move.l	d4,a2
	move.l	(a3)+,a1
	move.l	(a3)+,a0
	move.l	#EZREQF_LAMIGAQUAL,d0
	jtcall	EZRequest
	subq.w	#2,d0
	move.w	d0,d3
	ext.l	d3
	moveq	#0,d2
	ret

L_IrequestWarning3:	;=Irequest Warning(s$,ok$,cancel$)
	subq.l	#4,a3
	move.l	4(a3),(a3)
	move.l	8(a3),4(a3)
	move.l	12(a3),8(a3)
	clr.l	12(a3)
	bra	L_IrequestWarning

L_IrequestWarning1:	;=Irequest Warning(s$)
	lea	.ok(pc),a0
	move.l	a0,-(a3)
	lea	.cancel(pc),a0
	move.l	a0,-(a3)
	bra	L_IrequestWarning3
.ok	dc.b 0,2,"Ok"
.cancel	dc.b 0,6,"Cancel"
	ds.w 0

L_IrequestError:	;Irequest Error title$,s$,cancel$
	pstart
	move.l	(a3)+,a2
	move.w	(a2)+,d2
	beq	L_IllFunc
	moveq	#0,d0
	move.w	d2,d0
	jtcall	StrAlloc
	move.l	a2,a0
	move.l	d0,a2
	move.l	d0,a1
	moveq	#0,d0
	move.w	d2,d0
	syscall	CopyMem
	clr.b	0(a2,d2.w)
	move.l	(a3)+,a1
	move.l	(a3)+,a0
	move.l	#EZREQF_LAMIGAQUAL,d0
	jtcall	EZRequest
	ret


L_IrequestError2:	;Irequest Error s$,cancel$
	subq.l	#4,a3
	move.l	4(a3),(a3)
	move.l	8(a3),4(a3)
	clr.l	8(a3)
	bra	L_IrequestError

L_IrequestError1:	;Irequest Error s$
	lea	.cancel(pc),a0
	move.l	a0,-(a3)
	bra	L_IrequestError2
.cancel	dc.b 0,6,"Cancel"
	ds.w 0

L_IrequestMessage:	;=Irequest Message(title$,text$,gadget$)
	pstart
	move.l	(a3)+,a2
	move.w	(a2)+,d2
	beq	L_IllFunc
	moveq	#0,d0
	move.w	d2,d0
	jtcall	StrAlloc
	move.l	a2,a0
	move.l	d0,a2
	move.l	d0,a1
	moveq	#0,d0
	move.w	d2,d0
	syscall	CopyMem
	clr.b	0(a2,d2.w)
	move.l	(a3)+,a1
	move.l	(a3)+,a0
	moveq	#0,d0
	jtcall	EZRequest
	move.l	d0,d3
	moveq	#0,d2
	ret


L_IrequestMessage2:	;=Irequest Message(text$,gadget$)
	move.l	(a3)+,d0
	move.l	(a3),d1
	clr.l	(a3)
	move.l	d1,-(a3)
	move.l	d0,-(a3)
	bra	L_IrequestMessage

L_IreqSetDefTitle:	;Irequest Def Title title$
	pstart
	move.l	(a3)+,a2
	moveq	#0,d0
	move.w	(a2)+,d0
	beq	.nodef
	move.l	d0,d2
	jtcall	StrAlloc
	move.l	d0,a0
	exg	a0,a2
	move.l	a2,a1
	move.l	d2,d0
	syscall	CopyMem
	clr.b	0(a2,d2.l)
	bra	.setdef
.nodef	dlea	DefReqTitleStr,a2
.setdef	tmove.l	a2,DefReqTitle
	ret
