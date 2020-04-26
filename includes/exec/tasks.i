	IFND	EXEC_TASKS_I
EXEC_TASKS_I	SET	1
**
**	$Filename: exec/tasks.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    IFND EXEC_NODES_I
    INCLUDE "exec/nodes.i"
    ENDC	; EXEC_NODES_I

    IFND EXEC_LISTS_I
    INCLUDE "exec/lists.i"
    ENDC	; EXEC_LISTS_I


*----------------------------------------------------------------
*
*   Task Control Structure
*
*----------------------------------------------------------------

 STRUCTURE  TC,LN_SIZE
    UBYTE   TC_FLAGS
    UBYTE   TC_STATE
    BYTE    TC_IDNESTCNT	    * intr disabled nesting
    BYTE    TC_TDNESTCNT	    * task disabled nesting
    ULONG   TC_SIGALLOC		    * sigs allocated
    ULONG   TC_SIGWAIT		    * sigs we are waiting for
    ULONG   TC_SIGRECVD		    * sigs we have received
    ULONG   TC_SIGEXCEPT	    * sigs we take as exceptions
    UWORD   TC_TRAPALLOC	    * traps allocated
    UWORD   TC_TRAPABLE		    * traps enabled
    APTR    TC_EXCEPTDATA	    * data for except proc
    APTR    TC_EXCEPTCODE	    * exception procedure
    APTR    TC_TRAPDATA		    * data for proc trap proc
    APTR    TC_TRAPCODE		    * proc trap procedure
    APTR    TC_SPREG		    * stack pointer
    APTR    TC_SPLOWER		    * stack lower bound
    APTR    TC_SPUPPER		    * stack upper bound + 2
    APTR    TC_SWITCH		    * task losing CPU
    APTR    TC_LAUNCH		    * task getting CPU
    STRUCT  TC_MEMENTRY,LH_SIZE	    * allocated memory
    APTR    TC_Userdata
    LABEL   TC_SIZE


*------ Flag Bits:

    BITDEF  T,PROCTIME,0
    BITDEF  T,STACKCHK,4
    BITDEF  T,EXCEPT,5
    BITDEF  T,SWITCH,6
    BITDEF  T,LAUNCH,7


*------ Task States:
TS_INVALID  EQU	    0
TS_ADDED    EQU	    TS_INVALID+1
TS_RUN	    EQU	    TS_ADDED+1
TS_READY    EQU	    TS_RUN+1
TS_WAIT	    EQU	    TS_READY+1
TS_EXCEPT   EQU	    TS_WAIT+1
TS_REMOVED  EQU	    TS_EXCEPT+1


*------ System Task Signals:

SIGF_ABORT	EQU	$0001
SIGF_CHILD	EQU	$0002
SIGF_BLIT	EQU	$0010
SIGF_SINGLE	EQU	$0010
SIGF_DOS	EQU	$0100

SIGB_ABORT	EQU	0
SIGB_CHILD	EQU	1
SIGB_BLIT	EQU	4
SIGB_SINGLE	EQU	4
SIGB_DOS	EQU	8


SYS_SIGALLOC	EQU	$0FFFF		; pre-allocated signals
SYS_TRAPALLOC	EQU	$08000		; pre-allocated traps

	ENDC	; EXEC_TASKS_I
