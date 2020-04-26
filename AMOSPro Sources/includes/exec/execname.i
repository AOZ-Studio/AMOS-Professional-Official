	IFND	EXEC_EXECNAME_I
EXEC_EXECNAME_I SET	1
**
**	$Filename: exec/execname.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

EXECNAME	macro
		dc.b	'exec.library',0
		ds.w	0
		endm

	ENDC	; EXEC_EXECNAME_I
