	IFND	EXEC_TYPES_I
EXEC_TYPES_I	SET	1
**
**	$Filename: exec/types.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

EXTERN_LIB  MACRO
	    XREF    _LVO\1
	    ENDM

STRUCTURE   MACRO
\1	    EQU	    0			* for assembler's sake
SOFFSET	    SET	    \2
	    ENDM

BOOL	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+2
	    ENDM

BYTE	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+1
	    ENDM

UBYTE	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+1
	    ENDM

WORD	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+2
	    ENDM

UWORD	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+2
	    ENDM

SHORT	     MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+2
	    ENDM

USHORT	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+2
	    ENDM

LONG	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+4
	    ENDM

ULONG	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+4
	    ENDM

FLOAT	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+4
	    ENDM

APTR	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+4
	    ENDM

CPTR	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+4
	    ENDM

RPTR	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+2
	    ENDM

STRUCT	    MACRO
\1	    EQU	    SOFFSET
SOFFSET	    SET	    SOFFSET+\2
	    ENDM

LABEL	    MACRO
\1	    EQU	    SOFFSET
	    ENDM

*------ bit definition macro ------------------------------------
*
*   Given:
*
*	BITDEF	MEM,CLEAR,16
*
*  Yields:
*
*	MEMB_CLEAR  EQU 16
*	MEMF_CLEAR  EQU (1.SL.MEMB_CLEAR)
*

BITDEF	    MACRO   * prefix,&name,&bitnum
	    BITDEF0 \1,\2,B_,\3
\@BITDEF    SET	    1<<\3
	    BITDEF0 \1,\2,F_,\@BITDEF
	    ENDM

BITDEF0	    MACRO   * prefix,&name,&type,&value
\1\3\2	    EQU	    \4
	    ENDM

LIBRARY_VERSION EQU	34

	ENDC	; EXEC_TYPES_I
