;all functions.

	include "errordefs.i"	;Error numbers

	section text,code

	xdef	Error
	xdef	ProgInt
	xdef	IllFunc
	xdef	NoMem
	xdef	NoFont
	xdef	NoScr
	xdef	IllScrParm
	xdef	IllNumCols
	xdef	_16Colours
	xdef	CantOpenScr
	xdef	NeedKick20
	xdef	CantOpenWin
	xdef	NoCloseWin0
	xdef	NoModWin0
	xdef	NoWin
	xdef	WinTooSmall
	xdef	WinTooLarge
	xdef	IllWinParm
	xdef	WinNotClosed
	xdef	CantOpenWB
	xdef	ScrNotClosed
	xdef	NoIcon
	xdef	NoIconBank
	xdef	NoErrStr
	xdef	NoObj
	xdef	NoObjBank
	xdef	MixedCoords
	xdef	MenuActive
	xdef	InternalErr
	xdef	InternalErr2
	xdef	NoReqTools
	xdef	TooManyGads
	xdef	GadgetActive
	xdef	WrongGadType
	xdef	GadNotDef
	xdef	GadNotRes
	xdef	Ascr0to7
	xdef	BankNotDef
	xdef	UnknownFmt
	xdef	Inconsistent

	xref	CustomError


Error:		;error # in D0
	bra	L_CustomError

ProgInt:	;Program interrupted
	moveq	#E_PI,d0
	bra	L_CustomError

IllFunc:	;Illegal function cal|
	moveq	#E_IFC,d0
	bra	L_CustomError

NoMem:		;Out of memory
	moveq	#E_OOM,d0
	bra	L_CustomError

NoFont:		;Font not available
	moveq	#E_FNA,d0
	bra	L_CustomError

NoScr:		;Screen not opened
	moveq	#E_SNO,d0
	bra	L_CustomError

IllScrParm:	;Illegal screen parameter
	moveq	#E_ISP,d0
	bra	L_CustomError

IllNumCols:	;Illegal number of colours
	moveq	#E_INC,d0
	bra	L_CustomError

_16Colours:	;Only 16 colours allowed on non-AGA hires screen
	moveq	#E_16C,d0
	bra	L_CustomError

CantOpenScr:	;Unable to open screen
	moveq	#E_UOS,d0
	bra	L_CustomError

NeedKick20:	;Need Kickstart 2.0 or higher
	moveq	#E_KS2,d0
	bra	L_CustomError

CantOpenWin:	;Unable to open window
	moveq	#E_UOW,d0
	bra	L_CustomError

NoCloseWin0:	;Window 0 can't be closed
	moveq	#E_CW0,d0
	bra	L_CustomError

NoModWin0:	;Window 0 can't be modified
	moveq	#E_MW0,d0
	bra	L_CustomError

NoWin:		;Window not opened
	moveq	#E_WNO,d0
	bra	L_CustomError

WinTooSmall:	;Window too small
	moveq	#E_WTS,d0
	bra	L_CustomError

WinTooLarge:	;Window too large
	moveq	#E_WTL,d0
	bra	L_CustomError

IllWinParm:	;Illegal window parameter
	moveq	#E_IWP,d0
	bra	L_CustomError

WinNotClosed:	;Window not closed
	moveq	#E_WNC,d0
	bra	L_CustomError

CantOpenWB:	;Unable to open Workbench
	moveq	#E_NWB,d0
	bra	L_CustomError

ScrNotClosed:	;Screen not closed
	moveq	#E_SNC,d0
	bra	L_CustomError

NoIcon:		;Icon not defined
	moveq	#E_IND,d0
	bra	L_CustomError

NoIconBank:	;Icon bank not defined
	moveq	#E_NIB,d0
	bra	L_CustomError

NoErrStr:	;Error text not available
	moveq	#E_NES,d0
	bra	L_CustomError

NoObj:		;Object not defined
	moveq	#E_OND,d0
	bra	L_CustomError

NoObjBank:	;Object bank not defined
	moveq	#E_NOB,d0
	bra	L_CustomError

MixedCoords:	;Backward coordinates
	moveq	#E_BWC,d0
	bra	L_CustomError

MenuActive:	;Menu already active
	moveq	#E_MAA,d0
	bra	L_CustomError

InternalErr:	;Internal error, code xxxxxxxx
		;Value for xxxxxxxx should be in D1
	moveq	#E_INT,d0
	bra	L_CustomError

InternalErr2:	;Internal error, code xxxxxxxx, subcode yyyyyyyy
		;Value for xxxxxxxx should be in D1, yyyyyyyy in D2
	moveq	#E_IN2,d0
	bra	L_CustomError

NoReqTools:	;ReqTools.library version 2 or higher required
	moveq	#E_NRT,d0
	bra	L_CustomError

TooManyGads:	;Only 65535 gadgets allowed
	moveq	#E_TMG,d0
	bra	L_CustomError

GadgetActive:	;Gadget already active
	moveq	#E_GAA,d0
	bra	L_CustomError

WrongGadType:	;Wrong gadget type
	moveq	#E_WGT,d0
	bra	L_CustomError

GadNotDef:	;Gadget not defined
	moveq	#E_GND,d0
	bra	L_CustomError

GadNotRes:	;Gadget not reserved
	moveq	#E_GNR,d0
	bra	L_CustomError

Ascr0to7:	;Valid AMOS screen numbers range from 0 to 7
	moveq	#E_ASN,d0
	bra	L_CustomError

BankNotDef:	;Bank not defined
	moveq	#E_BND,d0
	bra	L_CustomError

UnknownFmt:	;Bank format not understood
	moveq	#E_FNU,d0
	bra	L_CustomError

Inconsistent:	;Inconsistent data
	moveq	#E_IDT,d0
	bra	L_CustomError

L_CustomError:
	move.l	CustomError(pc),a0
	jmp	(a0)
