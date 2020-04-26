	IFND	RESOURCES_MATHRESOURCE_I
RESOURCES_MATHRESOURCE_I	SET	1
**
**	$Filename: resources/mathresource.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_TYPES_I
	include "exec/types.i"
	ENDC

	IFND	EXEC_NODES_I
	include "exec/nodes.i"
	ENDC

*
*	The 'Init' entries are only used if the corresponding
*	bit is set in the Flags field.
*
*	So if you are just a 68881, you do not need the Init stuff
*	just make sure you have cleared the Flags field.
*
*	This should allow us to add Extended Precision later.
*
*	For Init users, if you need to be called whenever a task
*	opens this library for use, you need to change the appropriate
*	entries in MathIEEELibrary.
*

	STRUCTURE MathIEEEResourceResource,0
		STRUCT	MathIEEEResource_Node,LN_SIZE
		USHORT	MathIEEEResource_Flags
		APTR	MathIEEEResource_BaseAddr	* ptr to 881 if exists *
		APTR	MathIEEEResource_DblBasInit
		APTR	MathIEEEResource_DblTransInit
		APTR	MathIEEEResource_SglBasInit
		APTR	MathIEEEResource_SglTransInit
		APTR	MathIEEEResource_ExtBasInit
		APTR	MathIEEEResource_ExtTransInit
	LABEL	MathIEEEResourceResource_SIZE

* definations for MathIEEERESOURCE_FLAGS *
	BITDEF	MATHIEEERESOURCE,DBLBAS,0
	BITDEF	MATHIEEERESOURCE,DBLTRANS,1
	BITDEF	MATHIEEERESOURCE,SGLBAS,2
	BITDEF	MATHIEEERESOURCE,SGLTRANS,3
	BITDEF	MATHIEEERESOURCE,EXTBAS,4
	BITDEF	MATHIEEERESOURCE,EXTTRANS,5

	ENDC	; RESOURCES_MATHRESOURCE_I
