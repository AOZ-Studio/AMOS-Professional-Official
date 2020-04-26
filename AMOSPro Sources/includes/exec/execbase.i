	IFND	EXEC_EXECBASE_I
EXEC_EXECBASE_I SET	1
**
**	$Filename: exec/execbase.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    IFND EXEC_TYPES_I
    INCLUDE "exec/types.i"
    ENDC	; EXEC_TYPES_I

    IFND EXEC_LISTS_I
    INCLUDE "exec/lists.i"
    ENDC	; EXEC_LISTS_I

    IFND EXEC_INTERRUPTS_I
    INCLUDE "exec/interrupts.i"
    ENDC	; EXEC_INTERRUPTS_I

    IFND EXEC_LIBRARIES_I
    INCLUDE "exec/libraries.i"
    ENDC	; EXEC_LIBRARIES_I


******* Static System Variables **************************************

 STRUCTURE  ExecBase,LIB_SIZE		; Standard library node

	    UWORD	SoftVer		; kickstart release number
	    WORD	LowMemChkSum	; checksum of 68000 trap vectors
	    ULONG	ChkBase		; system base pointer complement
	    APTR	ColdCapture	; cold soft capture vector
	    APTR	CoolCapture	; cool soft capture vector
	    APTR	WarmCapture	; warm soft capture vector
	    APTR	SysStkUpper	; system stack base   (upper bound)
	    APTR	SysStkLower	; top of system stack (lower bound)
	    ULONG	MaxLocMem	; last calculated local memory max
	    APTR	DebugEntry	; global debugger entry point
	    APTR	DebugData	; global debugger data segment
	    APTR	AlertData	; alert data segment
	    APTR	MaxExtMem	; top of extended mem, or null if none

	    WORD	ChkSum		; for all of the above


******* Interrupt Related ********************************************

	    LABEL	IntVects  
	    STRUCT	IVTBE,IV_SIZE
	    STRUCT	IVDSKBLK,IV_SIZE
	    STRUCT	IVSOFTINT,IV_SIZE
	    STRUCT	IVPORTS,IV_SIZE
	    STRUCT	IVCOPER,IV_SIZE
	    STRUCT	IVVERTB,IV_SIZE
	    STRUCT	IVBLIT,IV_SIZE
	    STRUCT	IVAUD0,IV_SIZE
	    STRUCT	IVAUD1,IV_SIZE
	    STRUCT	IVAUD2,IV_SIZE
	    STRUCT	IVAUD3,IV_SIZE
	    STRUCT	IVRBF,IV_SIZE
	    STRUCT	IVDSKSYNC,IV_SIZE
	    STRUCT	IVEXTER,IV_SIZE
	    STRUCT	IVINTEN,IV_SIZE
	    STRUCT	IVNMI,IV_SIZE


******* Dynamic System Variables *************************************

	    APTR	ThisTask	; pointer to current task
	    ULONG	IdleCount	; idle counter
	    ULONG	DispCount	; dispatch counter
	    UWORD	Quantum		; time slice quantum
	    UWORD	Elapsed		; current quantum ticks
	    UWORD	SysFlags	; misc system flags
	    BYTE	IDNestCnt	; interrupt disable nesting count
	    BYTE	TDNestCnt	; task disable nesting count

	    UWORD	AttnFlags	; special attention flags
	    UWORD	AttnResched	; rescheduling attention
	    APTR	ResModules	; pointer to resident module array

	    APTR	TaskTrapCode	; default task trap routine
	    APTR	TaskExceptCode	; default task exception code
	    APTR	TaskExitCode	; default task exit code
	    ULONG	TaskSigAlloc	; preallocated signal mask
	    UWORD	TaskTrapAlloc	; preallocated trap mask


******* System List Headers ******************************************

	    STRUCT	MemList,LH_SIZE
	    STRUCT	ResourceList,LH_SIZE
	    STRUCT	DeviceList,LH_SIZE
	    STRUCT	IntrList,LH_SIZE
	    STRUCT	LibList,LH_SIZE
	    STRUCT	PortList,LH_SIZE
	    STRUCT	TaskReady,LH_SIZE
	    STRUCT	TaskWait,LH_SIZE

	    STRUCT	SoftInts,SH_SIZE*5

	    STRUCT	LastAlert,4*4


	    ;------ these next two variables are provided to allow
	    ;------ system developers to have a rough idea of the
	    ;------ period of two externally controlled signals --
	    ;------ the time between vertical blank interrupts and the
	    ;------ external line rate (which is counted by CIA A's
	    ;------ "time of day" clock).  In general these values
	    ;------ will be 50 or 60, and may or may not track each
	    ;------ other.  These values replace the obsolete AFB_PAL
	    ;------ and AFB_50HZ flags.
	    UBYTE	VBlankFrequency
	    UBYTE	PowerSupplyFrequency

	    STRUCT	SemaphoreList,LH_SIZE

	    ;------ these next two are to be able to kickstart into user ram.
	    ;------ KickMemPtr holds a singly linked list of MemLists which
	    ;------ will be removed from the memory list via AllocAbs.	If
	    ;------ all the AllocAbs's succeeded, then the KickTagPtr will
	    ;------ be added to the rom tag list.
	    APTR	KickMemPtr	; ptr to queue of mem lists
	    APTR	KickTagPtr	; ptr to rom tag queue
	    APTR	KickCheckSum	; checksum for mem and tags

	    STRUCT	ExecBaseReserved,10
	    STRUCT	ExecBaseNewReserved,20

	    LABEL	SYSBASESIZE

******* AttnFlags
*  Processors and Co-processors:
	BITDEF	AF,68010,0	; also set for 68020
	BITDEF	AF,68020,1
	BITDEF	AF,68881,4

; These two bits used to be AFB_PAL and AFB_50HZ.  After some soul
; searching we realized that they were misnomers, and the information
; is now kept in VBlankFrequency and PowerSupplyFrequency above.
; To find out what sort of video conversion is done, look in the
; graphics subsytem.
	BITDEF	AF,RESERVED8,8
	BITDEF	AF,RESERVED9,9

	ENDC	; EXEC_EXECBASE_I
