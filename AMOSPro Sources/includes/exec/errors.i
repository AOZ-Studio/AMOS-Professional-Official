	IFND	EXEC_ERRORS_I
EXEC_ERRORS_I	SET	1
**
**	$Filename: exec/errors.i $
**	$Release: 1.3 $
**
**	Standard IO Errors: 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

IOERR_OPENFAIL	EQU	-1		* device/unit failed to open
IOERR_ABORTED	EQU	-2		* request aborted
IOERR_NOCMD	EQU	-3		* command not supported
IOERR_BADLENGTH EQU	-4		* not a valid length


ERR_OPENDEVICE	EQU  IOERR_OPENFAIL	* REMOVE !!!

	ENDC	; EXEC_ERRORS_I
