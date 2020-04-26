	IFND	DEVICES_INPUT_I
DEVICES_INPUT_I SET	1
**
**	$Filename: devices/input.i $
**	$Release: 1.3 $
**
**	input device command definitions 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

   IFND	    EXEC_IO_I
   INCLUDE     "exec/io.i"
   ENDC

   DEVINIT

   DEVCMD	IND_ADDHANDLER
   DEVCMD	IND_REMHANDLER
   DEVCMD	IND_WRITEEVENT
   DEVCMD	IND_SETTHRESH
   DEVCMD	IND_SETPERIOD
   DEVCMD	IND_SETMPORT
   DEVCMD	IND_SETMTYPE
   DEVCMD	IND_SETMTRIG

	ENDC	; DEVICES_INPUT_I
