	IFND	LIBRARIES_EXPANSIONBASE_I
LIBRARIES_EXPANSIONBASE_I	SET	1
**
**	$Filename: libraries/expansionbase.i $
**	$Release: 1.3 $
**
**	library structure for expansion library 
**
**	(C) Copyright 1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC	; EXEC_TYPES_I

	IFND	EXEC_LIBRARIES_I
	INCLUDE "exec/libraries.i"
	ENDC	; EXEC_LIBRARIES_I

	IFND	EXEC_INTERRUPTS_I
	INCLUDE "exec/interrupts.i"
	ENDC	; EXEC_INTERRUPTS_I

	IFND	EXEC_SEMAPHORES_I
	INCLUDE "exec/semaphores.i"
	ENDC	; EXEC_SEMAPHORES_I

	IFND	LIBRARIES_CONFIGVARS_I
	INCLUDE "libraries/configvars.i"
	ENDC	; LIBRARIES_CONFIGVARS_I


TOTALSLOTS	EQU	256

 STRUCTURE	ExpansionInt,0
    UWORD		ei_IntMask	; mask for this list
    UWORD		ei_ArrayMax	; current max valid index
    UWORD		ei_ArraySize	; allocated size
    LABEL		ei_Array	; actual data is after this
    LABEL		ExpansionInt_SIZEOF

 STRUCTURE	ExpansionBase,LIB_SIZE
    UBYTE		eb_Flags
    UBYTE		eb_pad
    ULONG		eb_ExecBase
    ULONG		eb_SegList
    STRUCT		eb_CurrentBinding,CurrentBinding_SIZEOF
    STRUCT		eb_BoardList,LH_SIZE
    STRUCT		eb_MountList,LH_SIZE
    STRUCT		eb_AllocTable,TOTALSLOTS
    STRUCT		eb_BindSemaphore,SS_SIZE
    STRUCT		eb_Int2List,IS_SIZE
    STRUCT		eb_Int6List,IS_SIZE
    STRUCT		eb_Int7List,IS_SIZE
    LABEL		ExpansionBase_SIZEOF


; error codes
EE_LASTBOARD	EQU	40	; could not shut him up
EE_NOEXPANSION	EQU	41	; not enough expansion mem; board shut up
EE_NOBOARD	EQU	42	; no board at that address
EE_NOMEMORY	EQU	42	; not enough normal memory

; flags
	BITDEF	EB,CLOGGED,0	; someone could not be shutup
	BITDEF	EB,SHORTMEM,1	; ran out of expansion mem

	ENDC	; LIBRARIES_EXPANSIONBASE_I
