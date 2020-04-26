	IFND	LIBRARIES_CONFIGVARS_I
LIBRARIES_CONFIGVARS_I	SET	1
**
**	$Filename: libraries/configvars.i $
**	$Release: 1.3 $
**
**	software structures for configuration subsystem 
**
**	(C) Copyright 1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_NODES_I
	INCLUDE "exec/nodes.i"
	ENDC	; EXEC_NODES_I

	IFND	LIBRARIES_CONFIGREGS_I
	INCLUDE "libraries/configregs.i"
	ENDC	; LIBRARIES_CONFIGREGS_I


 STRUCTURE ConfigDev,0
    STRUCT	cd_Node,LN_SIZE
    UBYTE	cd_Flags
    UBYTE	cd_Pad
    STRUCT	cd_Rom,ExpansionRom_SIZEOF ; copy of boards config rom
    APTR	cd_BoardAddr	; where in memory the board is
    APTR	cd_BoardSize	; size in bytes
    UWORD	cd_SlotAddr	; which slot number
    UWORD	cd_SlotSize	; number of slots the board takes
    APTR	cd_Driver	; pointer to node of driver
    APTR	cd_NextCD	; linked list of drivers to config
    STRUCT	cd_Unused,4*4	; for whatever the driver whats
    LABEL	ConfigDev_SIZEOF

; cd_Flags
	BITDEF	CD,SHUTUP,0	; this board has been shut up
	BITDEF	CD,CONFIGME,1	; this board needs a driver to claim it

; this structure is used by GetCurrentBinding() and SetCurrentBinding()
 STRUCTURE CurrentBinding,0
    APTR	cb_ConfigDev
    APTR	cb_FileName
    APTR	cb_ProductString
    APTR	cb_ToolTypes
    LABEL	CurrentBinding_SIZEOF

	ENDC	; LIBRARIES_CONFIGVARS_I
