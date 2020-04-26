;The Intuition Extension includes a few routines that other extensions
;(or any assembler code) can call to access Intuition data.  The routine
;addresses are stored in a table, which can be accessed using the
;following instructions:
;
;	move.l	ExtAdr+IntExtNum*16(a5),a0
;	move.l	4(a0),a0
;
;Then, a routine would be called like this:
;
;	jsr	RoutineName(a0)
;
;(Of course, you can substitute any address register you want in place
;of A0.)
;
;See below for making sure the branch table exists and contains the
;functions you need.
;
;The routines are:
;
;   IscreenAdr: get the address of a screen
;	Input:	D0 = screen number
;	Output:	D0 = screen address or NULL
;
;   IwindowAdr: get the address of a window
;	Input:	D0 = window number
;		A0 = screen address, NULL for current screen, or
;		     -1 for Workbench
;	Output:	D0 = window address or NULL
;
;   CurIscreenAdr: get the current screen's address
;	Input:	none
;	Output: D0 = screen address or NULL
;
;   CurIwindowAdr: get the current window's address
;	Input:	none
;	Output:	D0 = window address or NULL
;
;The routines preserve all registers, except for return values.


;The extension number.

IntExtNum	equ 14

;The identification word for the extension.  This is at the beginning
;of the extension's data buffer, i.e. at ExtAdr+(IntExtNum-1)*16(a5).
;If this word is not present, you are using an old version of the
;extension without a branch table.

IntuitionID	equ 'IE'

;The word immediately following the ID is a branch table version
;number.  You may only call functions with a version number less than
;or equal to this value.  (The version number of a function is the
;last version number listed in the table below that precedes the
;function definition.)

;Version 0
IscreenAdr	equ 0
IwindowAdr	equ 4
CurIscreenAdr	equ 8
CurIwindowAdr	equ 12
