; ASM-One - mathffp_lib.i
; (Release 3.0)
;
; by SCHWARZENEGGER/R.A.F

_LVOSPFix	EQU	-30
_LVOSPFlt	EQU	-36
_LVOSPCmp	EQU	-42
_LVOSPTst	EQU	-48
_LVOSPAbs	EQU	-54
_LVOSPNeg	EQU	-60
_LVOSPAdd	EQU	-66
_LVOSPSub	EQU	-72
_LVOSPMul	EQU	-78
_LVOSPDiv	EQU	-84
_LVOSPFloor	EQU	-90
_LVOSPCeil	EQU	-96

CALLFFP	MACRO
	move.l	_MathBase,a6
	jsr	_LVO\1(a6)
	ENDM

FFPNAME	MACRO
	dc.b	'mathffp.library',0
	ENDM
