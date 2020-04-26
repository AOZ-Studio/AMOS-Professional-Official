;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; EQUATES
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
C_Code1		equ	$FE
C_Code2		equ	$01
C_CodeD		equ	$6543
C_CodeInst	equ	$6545
C_CodeJ		equ	$F7
C_CodeT		equ	$F5

CiJSR		equ	$4EB9
CiJMP		equ	$4EF9
CodeR		equ	$8F

Ret_Int		MACRO
		moveq	#0,d2
		rts
		ENDM
Ret_Float	MACRO
		moveq	#1,d2
		rts
		ENDM
Ret_String	MACRO
		moveq	#2,d2
		rts
		ENDM

Rjmpt		MACRO
		dc.b	C_Code1,0*16+C_Code2
		dc.b	C_CodeT,0
		dc.w	\1
		ENDM
Rjsrt		MACRO
		dc.b	C_Code1,1*16+C_Code2
		dc.b	C_CodeT,0
		dc.w	\1
		ENDM
RjsrtR		MACRO
		dc.b	C_Code1,1*16+C_Code2
		dc.b	C_CodeT,\2
		dc.w	\1
		ENDM
RjmptR		MACRO
		dc.b	C_Code1,0*16+C_Code2
		dc.b	C_CodeT,\2
		dc.w	\1
		ENDM
Rlea		MACRO
		dc.b	C_Code1,1*16+C_Code2
		dc.b	C_CodeT,8+\2
		dc.w	\1
		ENDM
Rjmp		MACRO
		dc.b	C_Code1,0*16+C_Code2
		dc.b	C_CodeJ,0
		dc.w	\1
		ENDM
Rjsr		MACRO
		dc.b	C_Code1,1*16+C_Code2
		dc.b	C_CodeJ,0
		dc.w	\1
		ENDM
Ljmp		MACRO
		dc.b	C_Code1,0*16+C_Code2
		dc.b	C_CodeJ,\2
		dc.w	\1
		ENDM
Ljsr		MACRO
		dc.b	C_Code1,1*16+C_Code2
		dc.b	C_CodeJ,\2
		dc.w	\1
		ENDM
Rbra		MACRO
		dc.b	C_Code1,2*16+C_Code2
		dc.w	\1
		ENDM
Rbsr		MACRO
		dc.b	C_Code1,3*16+C_Code2
		dc.w	\1
		ENDM
Rbeq		MACRO
		dc.b	C_Code1,4*16+C_Code2
		dc.w	\1
		ENDM
Rbne		MACRO
		dc.b	C_Code1,5*16+C_Code2
		dc.w	\1
		ENDM
Rbcs		MACRO
		dc.b	C_Code1,6*16+C_Code2
		dc.w	\1
		ENDM
Rbcc		MACRO
		dc.b	C_Code1,7*16+C_Code2
		dc.w	\1
		ENDM
Rblt		MACRO
		dc.b	C_Code1,8*16+C_Code2
		dc.w	\1
		ENDM
Rbge		MACRO
		dc.b	C_Code1,9*16+C_Code2
		dc.w	\1
		ENDM
Rbls		MACRO
		dc.b	C_Code1,10*16+C_Code2
		dc.w	\1
		ENDM
Rbhi		MACRO
		dc.b	C_Code1,11*16+C_Code2
		dc.w	\1
		ENDM
Rble		MACRO
		dc.b	C_Code1,12*16+C_Code2
		dc.w	\1
		ENDM
Rbpl		MACRO
		dc.b	C_Code1,13*16+C_Code2
		dc.w	\1
		ENDM
Rbmi		MACRO
		dc.b	C_Code1,14*16+C_Code2
		dc.w	\1
		ENDM
Rdata		MACRO
		dc.b	C_Code1,15*16+C_Code2
		dc.w	C_CodeD
		ENDM
Ret_Inst	MACRO
		rts
;		dc.b	C_Code1,15*16+C_Code2
;		dc.w	C_CodeInst
		ENDM
;Alea		MACRO
;		move.l	a5,\2
;		add.w	A\1(a5),\2
;		ENDM
*
GfxC		MACRO
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	T_GfxBase(a5),a6
		jsr	\1(a6)
		movem.l	(sp)+,d0-d7/a0-a6
		ENDM

Hunk_Public	equ	0
Hunk_Chip	equ	$40000000

N_HunkLib	equ	1		Nombre de hunks amos.library
N_HunkSys	equ	9		Nombre de hunks systeme

NH_Header	equ	0		Le header
NH_Prog		equ	1		Le programme
NH_Libraries	equ	2		Les librairies
NH_Reloc	equ	3		La relocation
NH_amoslib	equ	4		amos.library
NH_Mouse	equ	5		La mouse.abk
NH_Env		equ	6		L'environement
NH_DefaultBank	equ	7		La banque par defaut
NH_ErrorMessage	equ	8		Les messages d'erreur
NH_Banks	equ	9		Debut des banques

FHead_Run	equ	0
FHead_Short	equ	1
FHead_PRun	equ	2
FHead_Backed	equ	3

FPrg_DefRunAcc	equ	0
FPrg_Default	equ	1
FPrg_Wb		equ	2

; 		Zone de sauvegarde des donn�es short-run
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
Short_Name	rs.b	128
Short_Path	rs.b	256
Short_Command	rs.b	256
Short_Save	equ	__RS

;		Header procedure compilee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
APrg_MathFlags	rs.w	1		0
APrg_Relocation	rs.l	1		2
APrg_EndProc	rs.l	1		6
APrg_OldReloc	rs.l	1		10
		rs.b	16-__RS		Jusqu'� 16
APrg_Program	equ	__RS
;---------------------------------------------------------------------
