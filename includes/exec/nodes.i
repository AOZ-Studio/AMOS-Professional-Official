	IFND	EXEC_NODES_I
EXEC_NODES_I	SET	1
**
**	$Filename: exec/nodes.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

*----------------------------------------------------------------
*
*   List Node Structure
*
*----------------------------------------------------------------

 STRUCTURE  LN,0
    APTR    LN_SUCC
    APTR    LN_PRED
    UBYTE   LN_TYPE
    BYTE    LN_PRI
    APTR    LN_NAME
    LABEL   LN_SIZE

; min node -- only has minimum necessary, no type checking possible
 STRUCTURE  MLN,0
    APTR    MLN_SUCC
    APTR    MLN_PRED
    LABEL   MLN_SIZE

*------ Node Types:

NT_UNKNOWN	EQU	0
NT_TASK		EQU	1
NT_INTERRUPT	EQU	2	; also for software interrupt node
NT_DEVICE	EQU	3
NT_MSGPORT	EQU	4
NT_MESSAGE	EQU	5
NT_FREEMSG	EQU	6
NT_REPLYMSG	EQU	7
NT_RESOURCE	EQU	8
NT_LIBRARY	EQU	9
NT_MEMORY	EQU	10
NT_SOFTINT	EQU	11	; exec private
NT_FONT		EQU	12
NT_PROCESS	EQU	13
NT_SEMAPHORE	EQU	14
NT_SIGNALSEM	EQU	15	; signal semaphores
NT_BOOTNODE	EQU	16

	ENDC	; EXEC_NODES_I
