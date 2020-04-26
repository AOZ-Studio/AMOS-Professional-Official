	IFND	EXEC_LIBRARIES_I
EXEC_LIBRARIES_I	SET	1
**
**	$Filename: exec/libraries.i $
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


*------ Special Constants ---------------------------------------

LIB_VECTSIZE	EQU	6
LIB_RESERVED	EQU	4
LIB_BASE	EQU	$FFFFFFFA	* (-LIB_VECTSIZE)
LIB_USERDEF	EQU	LIB_BASE-(LIB_RESERVED*LIB_VECTSIZE)
LIB_NONSTD	EQU	LIB_USERDEF

*----------------------------------------------------------------
*
*   Library Definition Macros
*
*----------------------------------------------------------------

*------ LIBINIT sets base offset for library function definitions:

LIBINIT	    MACRO   * [baseOffset]
	    IFC	    '\1',''
COUNT_LIB   SET	    LIB_USERDEF
	    ENDC
	    IFNC    '\1',''
COUNT_LIB   SET	    \1
	    ENDC
	    ENDM


*------ LIBDEF is used to define each library function entry:

LIBDEF	    MACRO   * libraryFunctionSymbol
\1	    EQU	    COUNT_LIB
COUNT_LIB   SET	    COUNT_LIB-LIB_VECTSIZE
	    ENDM


*----------------------------------------------------------------
*
*   Standard Library Functions
*
*----------------------------------------------------------------

    LIBINIT LIB_BASE

    LIBDEF  LIB_OPEN
    LIBDEF  LIB_CLOSE
    LIBDEF  LIB_EXPUNGE
    LIBDEF  LIB_EXTFUNC			* reserved *


*----------------------------------------------------------------
*
*   Standard Library Data Structure
*
*----------------------------------------------------------------

 STRUCTURE LIB,LN_SIZE
    UBYTE   LIB_FLAGS
    UBYTE   LIB_pad
    UWORD   LIB_NEGSIZE			* number of bytes before LIB
    UWORD   LIB_POSSIZE			* number of bytes after LIB
    UWORD   LIB_VERSION			* major
    UWORD   LIB_REVISION		* minor
    APTR    LIB_IDSTRING		* identification
    ULONG   LIB_SUM			* the checksum itself
    UWORD   LIB_OPENCNT			* number of current opens
    LABEL   LIB_SIZE


*------ LIB_FLAGS bit definitions:

    BITDEF  LIB,SUMMING,0		* we are currently checksumming
    BITDEF  LIB,CHANGED,1		* we have just changed the lib
    BITDEF  LIB,SUMUSED,2		* set if we should bother to sum
    BITDEF  LIB,DELEXP,3		* delayed expunge


*----------------------------------------------------------------
*
*   Function Invocation Macros
*
*----------------------------------------------------------------

*------ CALLLIB for calling functions where A6 is already correct:

CALLLIB	    MACRO   * functionOffset
	IFGT NARG-1
	    FAIL    !!! CALLLIB MACRO - too many arguments !!!
	ENDC
	    JSR	    \1(A6)
	    ENDM


*------ LINKLIB for calling functions where A6 is incorrect:

LINKLIB	    MACRO   * functionOffset,libraryBase
	IFGT NARG-2
	    FAIL    !!! LINKLIB MACRO - too many arguments !!!
	ENDC
	    MOVE.L  A6,-(SP)
	    MOVE.L  \2,A6
	    CALLLIB \1
	    MOVE.L  (SP)+,A6
	    ENDM

	ENDC	; EXEC_LIBRARIES_I
