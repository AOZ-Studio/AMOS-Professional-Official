;Error routines
;These should be in about the middle of the code to be easily accessible to
;all functions.

	include "errordefs.i"	;Error numbers

L__Error:	;error # in D0
	bra	L_CustomError

L_ProgInt:	;Program interrupted
	moveq	#E_PI,d0
	bra	L_CustomError

L_IllFunc:	;Illegal function cal|
	moveq	#E_IFC,d0
	bra	L_CustomError

L_NoMem:	;Out of memory
	moveq	#E_OOM,d0
	bra	L_CustomError

L_NoFont:	;Font not available
	moveq	#E_FNA,d0
	bra	L_CustomError

L_NoScr:	;Screen not opened
	moveq	#E_SNO,d0
	bra	L_CustomError

L_IllScrParm:	;Illegal screen parameter
	moveq	#E_ISP,d0
	bra	L_CustomError

L_IllNumCols:	;Illegal number of colours
	moveq	#E_INC,d0
	bra	L_CustomError

L_16Colours:	;Only 16 colours allowed on non-AGA hires screen
	moveq	#E_16C,d0
	bra	L_CustomError

L_CantOpenScr:	;Unable to open screen
	moveq	#E_UOS,d0
	bra	L_CustomError

L_NeedKick20:	;Need Kickstart 2.0 or higher
	moveq	#E_KS2,d0
	bra	L_CustomError

L_CantOpenWin:	;Unable to open window
	moveq	#E_UOW,d0
	bra	L_CustomError

L_NoCloseWin0:	;Window 0 can't be closed
	moveq	#E_CW0,d0
	bra	L_CustomError

L_NoModWin0:	;Window 0 can't be modified
	moveq	#E_MW0,d0
	bra	L_CustomError

L_NoWin:	;Window not opened
	moveq	#E_WNO,d0
	bra	L_CustomError

L_WinTooSmall:	;Window too small
	moveq	#E_WTS,d0
	bra	L_CustomError

L_WinTooLarge:	;Window too large
	moveq	#E_WTL,d0
	bra	L_CustomError

L_IllWinParm:	;Illegal window parameter
	moveq	#E_IWP,d0
	bra	L_CustomError

L_WinNotClosed:	;Window not closed
	moveq	#E_WNC,d0
	bra	L_CustomError

L_CantOpenWB:	;Unable to open Workbench
	moveq	#E_NWB,d0
	bra	L_CustomError

L_ScrNotClosed:	;Screen not closed
	moveq	#E_SNC,d0
	bra	L_CustomError

L_NoIcon:	;Icon not defined
	moveq	#E_IND,d0
	bra	L_CustomError

L_NoIconBank:	;Icon bank not defined
	moveq	#E_NIB,d0
	bra	L_CustomError

L_NoErrStr:	;Error text not available
	moveq	#E_NES,d0
	bra	L_CustomError

L_NoObj:	;Object not defined
	moveq	#E_OND,d0
	bra	L_CustomError

L_NoObjBank:	;Object bank not defined
	moveq	#E_NOB,d0
	bra	L_CustomError

L_MixedCoords:	;Backward coordinates
	moveq	#E_BWC,d0
	bra	L_CustomError

L_MenuActive:	;Menu already active
	moveq	#E_MAA,d0
	bra	L_CustomError

L_InternalErr:	;Internal error, code xxxxxxxx
		;Value for xxxxxxxx should be in D1
	moveq	#E_INT,d0
	bra	L_CustomError

L_InternalErr2:	;Internal error, code xxxxxxxx, subcode yyyyyyyy
		;Value for xxxxxxxx should be in D1, yyyyyyyy in D2
	moveq	#E_IN2,d0
	bra	L_CustomError

L_NoReqTools:	;ReqTools.library version 2 or higher required
	moveq	#E_NRT,d0
	bra	L_CustomError

L_TooManyGads:	;Only 65535 gadgets allowed
	moveq	#E_TMG,d0
	bra	L_CustomError

L_GadgetActive:	;Gadget already active
	moveq	#E_GAA,d0
	bra	L_CustomError

L_WrongGadType:	;Wrong gadget type
	moveq	#E_WGT,d0
	bra	L_CustomError

L_GadNotDef:	;Gadget not defined
	moveq	#E_GND,d0
	bra	L_CustomError

L_GadNotRes:	;Gadget not reserved
	moveq	#E_GNR,d0
	bra	L_CustomError

L_Ascr0to7:	;Valid AMOS screen numbers range from 0 to 7
	moveq	#E_ASN,d0
	bra	L_CustomError

L_BankNotDef:	;Bank not defined
	moveq	#E_BND,d0
	bra	L_CustomError

L_UnknownFmt:	;Bank format not understood
	moveq	#E_FNU,d0
	bra	L_CustomError

L_Inconsistent:	;Inconsistent data
	moveq	#E_IDT,d0
	bra	L_CustomError
