; ASM-One - icon_lib.i
; (Release 3.0)
;
; by SCHWARZENEGGER/R.A.F

_LVOGetIcon	EQU	-42
_LVOPutIcon	EQU	-48
_LVOFreeFreeList	EQU	-54
_LVOAddFreeList	EQU	-72
_LVOGetDiskObject	EQU	-78
_LVOPutDiskObject	EQU	-84
_LVOFreeDiskObject	EQU	-90
_LVOFindToolType	EQU	-96
_LVOMatchToolValue	EQU	-102
_LVOBumpRevision	EQU	-108
_LVOGetDefDiskObject	EQU	-120
_LVOPutDefDiskObject	EQU	-126
_LVOGetDiskObjectNew	EQU	-132
_LVODeleteDiskObject	EQU	-138

CALLICON	MACRO
	move.l	_IconBase,a6
	jsr	_LVO\1(a6)
	ENDM

ICONNAME	MACRO
	dc.b	'icon.library',0
	ENDM
