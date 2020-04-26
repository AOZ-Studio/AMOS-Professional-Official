;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; AMOS Requester handler 2.0
; By Fran�ois Lionet
; AMOS - AMOS Pro - AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOS Pro 2.0 and over
;---------------------------------------------------------------------
;
;  Published under the MIT Licence
;
;  Copyright (c) 1992 Europress Software
;  Copyright (c) 2020 Francois Lionet
;
;  Permission is hereby granted, free of charge, to any person
;  obtaining a copy of this software and associated documentation
;  files (the "Software"), to deal in the Software without
;  restriction, including without limitation the rights to use,
;  copy, modify, merge, publish, distribute, sublicense, and/or
;  sell copies of the Software, and to permit persons to whom the
;  Software is furnished to do so, subject to the following
;  conditions:
;
;  The above copyright notice and this permission notice shall be
;  included in all copies or substantial portions of the Software.
;
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
;  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
;  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
;---------------------------------------------------------------------
; Please refer to the +Music.s file for more informations
;---------------------------------------------------------------------


ExtNb		equ	3-1

;---------------------------------------------------------------------
;		Include the files automatically calculated by
;		Library_Digest.AMOS
;---------------------------------------------------------------------
		Include	"+Request_Size.s"
		Include	"+Request_Labels.s"
 		Include	"+AMOS_Includes.s"
		Include	"+Version.s"

Start		dc.l	C_Tk-C_Off
		dc.l	C_Lib-C_Tk
		dc.l	C_Title-C_Lib
		dc.l	C_End-C_Title
		dc.w	0
		dc.b	"AP20"

;---------------------------------------------------------------------
;		Creates the pointers to functions
;---------------------------------------------------------------------
		MCInit
C_Off
		REPT	Lib_Size
		MC
		ENDR

******************************************************************
* 	TOKEN TABLE + Addresses

;		TOKEN_START
C_Tk		dc.w 	1,0
		dc.b 	$80,-1
		dc.w	L_InRequestOn,L_Nul
		dc.b	"request o","n"+$80,"I",-1
		dc.w	L_InRequestOff,L_Nul
		dc.b	"request of","f"+$80,"I",-1
		dc.w	L_InRequestWb,L_Nul
		dc.b	"request w","b"+$80,"I",-1
;		TOKEN_END
		dc.w 	0
		dc.l	0			Important!


;---------------------------------------------------------------------
	Lib_Ini	0
;---------------------------------------------------------------------

C_Lib

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	COLD START
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Cold
; - - - - - - - - - - - - -
	cmp.l	#"APex",d1			Version 1.10 or over?
	bne.s	BadVer
	movem.l	a3-a6,-(sp)
	lea	Warm(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+4(a5)
	movem.l	(sp)+,a3-a6
	moveq	#ExtNb,d0		* NO ERRORS
	move.w	#VerNumber,d1		* Current version
	rts
; In case this extension is runned on AMOSPro V1.00
BadVer	moveq	#-1,d0			* Bad version number
	sub.l	a0,a0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SCREEN RESET: back to AMOS requester (Called by AMOSPro)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Warm
; - - - - - - - - - - - - -
	Rbra	L_InRequestOn

;--------------------------------------------------------------------

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Leave one empty routine here!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Empty
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	REQUEST WB
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InRequestWb
; - - - - - - - - - - - - -
	moveq	#1,d0
	SyCall	Request_OnOff
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	REQUEST ON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InRequestOn
; - - - - - - - - - - - - -
	moveq	#-1,d0
	SyCall	Request_OnOff
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	REQUEST OFF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InRequestOff
; - - - - - - - - - - - - -
	moveq	#0,d0
	SyCall	Request_OnOff
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Even if you do not have error messages, you MUST
;	leave TWO routines empty at the end...
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Empty
	Lib_Empty
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Finish the library
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_End
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 		TITLE OF THE EXTENSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_Title		dc.b 	"AMOSPro Requester V "
		Version
		dc.b	0,"$VER: "
		Version
		dc.b	0
		Even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		END OF THE EXTENSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_End		dc.w	0
		even
