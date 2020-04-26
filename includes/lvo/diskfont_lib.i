; ASM-One - diskfont_lib.i
; (Release 3.0)
;
; by SCHWARZENEGGER/R.A.F

_LVOOpenDiskFont	EQU	-30
_LVOAvailFonts	EQU	-36
_LVONewFontContents	EQU	-42
_LVODisposeFontContents	EQU	-48
_LVONewScaledDiskFont	EQU	-54

CALLDISKFONT	MACRO
	move.l	_DiskfontBase,a6
	jsr	_LVO\1(a6)
	ENDM

DISKFONTNAME	MACRO
	dc.b	'diskfont.library',0
	ENDM
