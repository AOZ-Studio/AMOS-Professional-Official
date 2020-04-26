	IFND	LIBRARIES_ROMBOOT_BASE_I
LIBRARIES_ROMBOOT_BASE_I	SET	1
**
**	$Filename: libraries/romboot_base.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    IFND    EXEC_TYPES_I
    include "exec/types.i"
    ENDC
    IFND    EXEC_NODES_I
    include "exec/nodes.i"
    ENDC
    IFND    EXEC_LISTS_I
    include "exec/lists.i"
    ENDC
    IFND    EXEC_LIBRARIES_I
    include "exec/libraries.i"
    ENDC
    IFND    EXEC_EXECBASE_I
    include "exec/execbase.i"
    ENDC
    IFND    EXEC_EXECNAME_I
    include "exec/execname.i"
    ENDC

 STRUCTURE  RomBootBase,LIB_SIZE
	APTR	rbb_ExecBase
	STRUCT	rbb_BootList,LH_SIZE
	STRUCT	rbb_Reserved,16			; for future expansion
    LABEL   rbb_SIZEOF

 STRUCTURE BootNode,LN_SIZE
	UWORD	bn_Flags
	CPTR	bn_DeviceNode
	LABEL	BootNode_SIZEOF

ROMBOOT_NAME:  MACRO
	DC.B	'romboot.library',0
	DS.W	0
	ENDM

	ENDC	; LIBRARIES_ROMBOOT_BASE_I
