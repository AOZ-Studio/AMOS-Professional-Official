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
C_Code1		equ	$FE
C_Code2		equ	$01
C_CodeD		equ	$6543
C_CodeJ		equ	$F7

CiJSR		equ	$4EB9
CiJMP		equ	$4EF9
CiBGT		equ	$6E00

CodeR		equ	$8F
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
Rbgt		MACRO
		dc.w	CiBGT+4
		Rble	\1
		ENDM
Rdata		MACRO
		dc.b	C_Code1,15*16+C_Code2
		dc.w	C_CodeD
		ENDM
Rlea		MACRO
		lea	\1,\2
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
*
BitLib		equ	31
BitChaine	equ	30
BitLabel	equ	29
*
Hunk_Public	equ	0
Hunk_Chip	equ	$40000000
N_HunkSys	equ	8
NH_Header	equ	0
NH_Prog		equ	1
NH_Reloc	equ	2
NH_W.Lib	equ	3
NH_Env		equ	4
NH_Mouse	equ	5
NH_Font		equ	6
NH_Key		equ	7
*
FlagFloat	equ	EdMarks+4*4
AForNext	equ	EdMarks+5*4
Ad_Labels	equ	EdMarks+6*4
Num_Proc	equ	EdMarks+7*4
LowPile		equ	EdMarks+8*4
LowPileP	equ	EdMarks+9*4
*
;---------------------------------------------------------------------
