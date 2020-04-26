	IFND	WORKBENCH_STARTUP_I
WORKBENCH_STARTUP_I	SET	1
**
**	$Filename: workbench/startup.i $
**	$Release: 1.3 $
**
**	Workbench startup definitions 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC	; EXEC_TYPES_I

	IFND	EXEC_PORTS_I
	INCLUDE "exec/ports.i"
	ENDC	; EXEC_PORTS_I

	IFND	LIBRARIES_DOS_I
	INCLUDE "libraries/dos.i"
	ENDC	; LIBRARIES_DOS_I

 STRUCTURE WBStartup,0
    STRUCT	sm_Message,MN_SIZE	; a standard message structure
    APTR	sm_Process		; the process descriptor for you
    BPTR	sm_Segment		; a descriptor for your code
    LONG	sm_NumArgs		; the number of elements in ArgList
    APTR	sm_ToolWindow		; description of window
    APTR	sm_ArgList		; the arguments themselves
    LABEL	sm_SIZEOF

 STRUCTURE WBArg,0
    BPTR	wa_Lock			; a lock descriptor
    APTR	wa_Name			; a string relative to that lock
    LABEL	wa_SIZEOF

	ENDC	; WORKBENCH_STARTUP_I
