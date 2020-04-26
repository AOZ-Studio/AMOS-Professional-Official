	IFND	DEVICES_KEYBOARD_I
DEVICES_KEYBOARD_I	SET	1
**
**	$Filename: devices/keyboard.i $
**	$Release: 1.3 $
**
**	Keyboard device command definitions 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

   IFND	    EXEC_IO_I
   INCLUDE     "exec/io.i"
   ENDC

   DEVINIT

   DEVCMD	KBD_READEVENT
   DEVCMD	KBD_READMATRIX
   DEVCMD	KBD_ADDRESETHANDLER
   DEVCMD	KBD_REMRESETHANDLER
   DEVCMD	KBD_RESETHANDLERDONE

	ENDC	; DEVICES_KEYBOARD_I
