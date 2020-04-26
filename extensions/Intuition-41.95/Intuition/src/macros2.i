;Macros for internal routines

pstart2	macro			;Doesn't depend on A5, and doesn't save SP
	movem.l	a4/a6,-(a7)
	move.l	DataBase(pc),a4
	endm

ret2	macro
	movem.l	(a7)+,a4/a6
	rts
	endm

dinit2	macro			;DINIT without A5
	move.l	DataBase(pc),\1
	endm

rtcall1	macro
	dtst.l	ReqToolsBase
	beq	NoReqTools
	dmove.l	ReqToolsBase,a6
	call	\1
	endm

rtcall2	macro
	dmove.l	ReqToolsBase,a6
	call	\1
	endm
