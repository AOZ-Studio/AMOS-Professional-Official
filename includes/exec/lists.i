	IFND	EXEC_LISTS_I
EXEC_LISTS_I	SET	1
**
**	$Filename: exec/lists.i $
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


*---------------------------------------------------------------------
*
*   List Structures
*
*---------------------------------------------------------------------

; normal, full featured list
 STRUCTURE  LH,0
    APTR    LH_HEAD
    APTR    LH_TAIL
    APTR    LH_TAILPRED
    UBYTE   LH_TYPE
    UBYTE   LH_pad
    LABEL   LH_SIZE

; minimal list, no type checking possible
 STRUCTURE  MLH,0
    APTR    MLH_HEAD
    APTR    MLH_TAIL
    APTR    MLH_TAILPRED
    LABEL   MLH_SIZE


NEWLIST	    MACRO   * list
	    MOVE.L  \1,(\1)
	    ADDQ.L  #LH_TAIL,(\1)
	    CLR.L   LH_TAIL(\1)
	    MOVE.L  \1,(LH_TAIL+LN_PRED)(\1)
	    ENDM

TSTLIST	    MACRO   * [list]
	    IFC	    '\1',''
	    CMP.L   LH_TAIL+LN_PRED(A0),A0
	    ENDC
	    IFNC    '\1',''
	    CMP.L   LH_TAIL+LN_PRED(\1),\1
	    ENDC
	    ENDM

SUCC	    MACRO   * node,succ
	    MOVE.L  (\1),\2
	    ENDM

PRED	    MACRO   * node,pred
	    MOVE.L  LN_PRED(\1),\2
	    ENDM

IFEMPTY	    MACRO   * list,label
	    CMP.L   LH_TAIL+LN_PRED(\1),\1
	    BEQ	    \2
	    ENDM

IFNOTEMPTY  MACRO   * list,label
	    CMP.L   LH_TAIL+LN_PRED(\1),\1
	    BNE	    \2
	    ENDM

TSTNODE	    MACRO   * node,next
	    MOVE.L  (\1),\2
	    TST.L   (\2)
	    ENDM

NEXTNODE    MACRO   * next,current,exit_label (DX,AX,DISP16)
	    MOVE.L  \1,\2
	    MOVE.L  (\2),\1
	    IFC	    '\0',''
	    BEQ	    \3
	    ENDC
	    IFNC    '\0',''
	    BEQ.S   \3
	    ENDC
	    ENDM

ADDHEAD	    MACRO
	    MOVE.L  (A0),D0
	    MOVE.L  A1,(A0)
	    MOVEM.L D0/A0,(A1)
	    MOVE.L  D0,A0
	    MOVE.L  A1,LN_PRED(A0)
	    ENDM

ADDTAIL	    MACRO
	    LEA	    LH_TAIL(A0),A0
	    MOVE.L  LN_PRED(A0),D0
	    MOVE.L  A1,LN_PRED(A0)
	    MOVE.L  A0,(A1)
	    MOVE.L  D0,LN_PRED(A1)
	    MOVE.L  D0,A0
	    MOVE.L  A1,(A0)
	    ENDM

REMOVE	    MACRO
	    MOVE.L  (A1),A0
	    MOVE.L  LN_PRED(A1),A1
	    MOVE.L  A0,(A1)
	    MOVE.L  A1,LN_PRED(A0)
	    ENDM

REMHEAD	    MACRO
	    MOVE.L  (A0),A1
	    MOVE.L  (A1),D0
	    BEQ.S   REMHEAD\@
	    MOVE.L  D0,(A0)
	    EXG.L   D0,A1
	    MOVE.L  A0,LN_PRED(A1)
REMHEAD\@
	    ENDM

*----------------------------------------------------------------
*
*  REMHEADQ -- remove-head quickly
*
*	Useful when a scratch register is available, and
*	list is known to contain at least one node.
*
*----------------------------------------------------------------

REMHEADQ    MACRO   * head,node,scratchReg
	    MOVE.L  (\1),\2
	    MOVE.L  (\2),\3
	    MOVE.L  \3,(\1)
	    MOVE.L  \1,LN_PRED(\3)
	    ENDM

REMTAIL	    MACRO
	    MOVE.L  LH_TAIL+LN_PRED(A0),A1
	    MOVE.L  LN_PRED(A1),D0
	    BEQ.S   REMTAIL\@
	    MOVE.L  D0,LH_TAIL+LN_PRED(A0)
	    EXG.L   D0,A1
	    MOVE.L  A0,(A1)
	    ADDQ.L  #4,(A1)
REMTAIL\@
	    ENDM

	ENDC	; EXEC_LISTS_I
