	IFND	WORKBENCH_WORKBENCH_I
WORKBENCH_WORKBENCH_I	SET	1
**
**	$Filename: workbench/workbench.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC	; EXEC_TYPES_I

	IFND	EXEC_NODES_I
	INCLUDE "exec/nodes.i"
	ENDC	; EXEC_NODES_I

	IFND	EXEC_LISTS_I
	INCLUDE "exec/lists.i"
	ENDC	; EXEC_LISTS_I

	IFND	EXEC_TASKS_I
	INCLUDE "exec/tasks.i"
	ENDC	; EXEC_TASKS_I

	IFND	INTUITION_INTUITION_I
	INCLUDE "intuition/intuition.i"
	ENDC	; INTUITION_INTUITION_I


; the Workbench object types
WBDISK		EQU	1
WBDRAWER	EQU	2
WBTOOL		EQU	3
WBPROJECT	EQU	4
WBGARBAGE	EQU	5
WBDEVICE	EQU	6
WBKICK		EQU	7


; the main workbench object structure
 STRUCTURE DrawerData,0
    STRUCT	dd_NewWindow,nw_SIZE	; args to open window
    LONG	dd_CurrentX		; current x coordinate of origin
    LONG	dd_CurrentY		; current y coordinate of origin
    LABEL	dd_SIZEOF

; the amount of DrawerData actually written to disk
DRAWERDATAFILESIZE	EQU (dd_SIZEOF)


 STRUCTURE DiskObject,0
    UWORD	do_Magic		; a magic num at the start of the file
    UWORD	do_Version		; a version number, so we can change it
    STRUCT	do_Gadget,gg_SIZEOF	; a copy of in core gadget
    UWORD	do_Type
    APTR	do_DefaultTool
    APTR	do_ToolTypes
    LONG	do_CurrentX
    LONG	do_CurrentY
    APTR	do_DrawerData
    APTR	do_ToolWindow		; only applies to tools
    LONG	do_StackSize		; only applies to tools
    LABEL	do_SIZEOF

WB_DISKMAGIC	EQU	$e310	; a magic number, not easily impersonated
WB_DISKVERSION	EQU	1	; our current version number

 STRUCTURE FreeList,0
    WORD	fl_NumFree
    STRUCT	fl_MemList,LH_SIZE
    ; weird name to avoid conflicts with FileLocks
    LABEL	FreeList_SIZEOF



* each message that comes into the WorkBenchPort must have a type field
* in the preceeding short.  These are the defines for this type
*

MTYPE_PSTD		EQU	1	; a "standard Potion" message
MTYPE_TOOLEXIT		EQU	2	; exit message from our tools
MTYPE_DISKCHANGE	EQU	3	; dos telling us of a disk change
MTYPE_TIMER		EQU	4	; we got a timer tick
MTYPE_CLOSEDOWN		EQU	5	; <unimplemented>
MTYPE_IOPROC		EQU	6	; <unimplemented>


* workbench does different complement modes for its gadgets.
* It supports separate images, complement mode, and backfill mode.
* The first two are identical to intuitions GADGIMAGE and GADGHCOMP.
* backfill is similar to GADGHCOMP, but the region outside of the
* image (which normally would be color three when complemented)
* is flood-filled to color zero.
*
GADGBACKFILL		EQU	$0001

* if an icon does not really live anywhere, set its current position
* to here
*
NO_ICON_POSITION	EQU	($80000000)

	ENDC	; WORKBENCH_WORKBENCH_I
