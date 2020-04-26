;AMOS Intuition Extension
;Copyright © 1994-1996, Andrew Church
;E-mail: achurch@cmu.edu

SILLYMACRO	macro		;PhxAss sometimes kills the first macro.  Why?
	dc.b "Stop that! It's silly!",0
	endm

VERSION	macro
	dc.b "41.95"
	endm
DATE	macro
	dc.b "96/02/22"
	endm

MYVERSION macro
	dc.b "1.3b"
	endm

	include "offsets.i"

      ifd CREATOR
;EXTASM: DCREATOR
	incdir	"/AMOS1.3"
	include	"equ.s"
	include "cequ.s"
;EXTASM: E
      else
;EXTASM: NCREATOR
	incdir	"/AMOS"
	include	"amos_includes.s"
;EXTASM: E
      endc

	incdir	"includes:"
	include "defs.i"	;Constant and structure definitions
	include "macros.i"	;Macros for extension
	include "jumptable.i"	;Jump table offsets

;;;;;;;;;;;;;;;;

Start	dc.l C_Tk-C_Off
	dc.l C_Lib-C_Tk
	dc.l C_Title-C_Lib
	dc.l C_End-C_Title
	dc.w 0

C_Off:				;ExtAsm sets up the offsets automatically

C_Tk:	dc.w 1,0
	dc.b $80,-1

	include "itokens.s"


C_Lib:
L_0:				;ExtAsm takes care of L_* and Lnnn labels
	bra	startup

;Data area
DataBase	dc.l 0		;Allocated dynamically

ExternalJump	dc.l 0		;Jump table for external code



;Initial startup code (loads external data and jumps to real startup code)
startup	move.l	a0,-(a7)
	lea	DataBase(pc),a0
	tst.l	(a0)		;Are we initialised yet?
	move.l	(a7)+,a0
	beq	.init		;Nope, do it
	move.l	DataBase(pc),a4	;Yes, just return DataBase in A4
	rts

.init	move.l	a4,-(a7)
	bsr	L_GetExtCode
	lea	ExternalJump(pc),a1
	move.l	a0,(a1)
	bsr	L_GetErrorAdr		;Grab address of error routine to D0
	lea	FinalExit(pc),a1
	move.l	a1,d1
	lea	DataBase(pc),a1
	move.l	ExternalJump(pc),a0
	jsr	jt_Startup(a0)		;Do our real startup
	tst.l	d0
	bmi	.error

	move.l	DataBase(pc),a4
	dlea	BranchTable,a0		;If successful, set up branch table
	lea	_IscreenAdr(pc),a1
	move.l	a1,(a0)+
	lea	_IwindowAdr(pc),a1
	move.l	a1,(a0)+
	lea	_CurIscreenAdr(pc),a1
	move.l	a1,(a0)+
	lea	_CurIwindowAdr(pc),a1
	move.l	a1,(a0)+
	bra	.done

.error	moveq	#-1,d0
.done	move.l	(a7)+,a4
	rts

FinalExit:
	rts


	include "extutils.s"		;MUST BE FIRST!!!!!

	include "screens.s"
	include "color.s"
	include "windows.s"
	include "fonts.s"
	include "input.s"

	include "errorstubs.s"		;in the middle

	include "text.s"
	include "graphics.s"
	include "request.s"
	include "menus.s"
	include "gadgets.s"
	include "other.s"

	include	"extcode.s"		;external code - MUST be immediately
					;  before errors.s
	include "errors.s"		;MUST BE LAST!!!!!!

L_LastLabel:


C_Title:
      ifd CREATOR
	dc.b 31
      endif
	dc.b "Intuition Extension v"
	MYVERSION
      ifd UNREGISTERED
	dc.b " Demo"
      endc
	dc.b " - copyright © 1994-1995 Andrew Church",0

	dc.b "$VER: Intuition.lib "
	VERSION
	dc.b " ("
      ifd CREATOR
	dc.b "Creator"
      else
	dc.b "Pro"
      endc
	dc.b " v"
	MYVERSION
	dc.b ", "
	DATE
      ifd UNREGISTERED
	dc.b " - unregistered demo version"
      endc
	dc.b ")",0

	ds.w 0

C_End:

	end
