	IFND	LIBRARIES_EXPANSION_I
LIBRARIES_EXPANSION_I	SET	1
**
**	$Filename: libraries/expansion.i $
**	$Release: 1.3 $
**
**	external definitions for expansion.library 
**
**	(C) Copyright 1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

EXPANSIONNAME	MACRO
		dc.b	'expansion.library',0
		ENDM


;* flags for the AddDosNode() call */
	BITDEF	ADN,STARTPROC,0

	ENDC	; LIBRARIES_EXPANSION_I
