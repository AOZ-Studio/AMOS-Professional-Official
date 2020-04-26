	IFND	EXEC_STRINGS_I
EXEC_STRINGS_I	SET	1
**
**	$Filename: exec/strings.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

*------ Terminal Control:

EOS		EQU	0
BELL		EQU	7
LF		EQU	10
CR		EQU	13
BS		EQU	8
DEL		EQU	$7F
NL		EQU	LF


*----------------------------------------------------------------
*
*   String Support Macros
*
*----------------------------------------------------------------

STRING	    MACRO
	    DC.B    \1
	    DC.B    0
	    CNOP    0,2
	    ENDM


STRINGL	    MACRO
	    DC.B    13,10
	    DC.B    \1
	    DC.B    0
	    CNOP    0,2
	    ENDM


STRINGR	    MACRO
	    DC.B    \1
	    DC.B    13,10,0
	    CNOP    0,2
	    ENDM


STRINGLR    MACRO
	    DC.B    13,10
	    DC.B    \1
	    DC.B    13,10,0
	    CNOP    0,2
	    ENDM

	ENDC	; EXEC_STRINGS_I
