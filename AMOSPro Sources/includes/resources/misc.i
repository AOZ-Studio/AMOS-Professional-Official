	IFND	RESOURCES_MISC_I
RESOURCES_MISC_I	SET	1
**
**	$Filename: resources/misc.i $
**	$Release: 1.3 $
**
**	external declarations for misc system resources 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC	; EXEC_TYPES_I

	IFND	EXEC_LIBRARIES_I
	INCLUDE "exec/libraries.i"
	ENDC	; EXEC_LIBRARIES_I

*********************************************************************
*
* Resource structures
*
*********************************************************************

MR_SERIALPORT	EQU	0
MR_SERIALBITS	EQU	1
MR_PARALLELPORT EQU	2
MR_PARALLELBITS EQU	3

NUMMRTYPES	EQU	4

    STRUCTURE MiscResource,LIB_SIZE
	STRUCT	mr_AllocArray,4*NUMMRTYPES
	LABEL	mr_Sizeof

	LIBINIT LIB_BASE
	LIBDEF	MR_ALLOCMISCRESOURCE
	LIBDEF	MR_FREEMISCRESOURCE


MISCNAME	MACRO
		DC.B	'misc.resource',0
		ENDM

	ENDC	; RESOURCES_MISC_I
