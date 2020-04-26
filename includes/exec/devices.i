	IFND	EXEC_DEVICES_I
EXEC_DEVICES_I	SET	1
**
**	$Filename: exec/devices.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    IFND EXEC_LIBRARIES_I
    INCLUDE "exec/libraries.i"
    ENDC	; EXEC_LIBRARIES_I

    IFND EXEC_PORTS_I
    INCLUDE "exec/ports.i"
    ENDC	; EXEC_PORTS_I


*----------------------------------------------------------------
*
*   Device Data Structure
*
*----------------------------------------------------------------

 STRUCTURE  DD,LIB_SIZE
    LABEL   DD_SIZE			* identical to library


*----------------------------------------------------------------
*
*   Suggested Unit Structure
*
*----------------------------------------------------------------

 STRUCTURE  UNIT,MP_SIZE		* queue for requests
    UBYTE   UNIT_FLAGS
    UBYTE   UNIT_pad
    UWORD   UNIT_OPENCNT
    LABEL   UNIT_SIZE


*------ UNIT_FLAG definitions:

    BITDEF  UNIT,ACTIVE,0		* driver is active
    BITDEF  UNIT,INTASK,1		* running in driver's task

	ENDC	; EXEC_DEVICES_I
