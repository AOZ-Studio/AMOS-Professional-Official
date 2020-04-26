	IFND	GRAPHICS_CLIP_I
GRAPHICS_CLIP_I SET	1
**
**	$Filename: graphics/clip.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    IFND    GRAPHICS_GFX_I
    include "graphics/gfx.i"
    ENDC
	IFND	EXEC_SEMAPHORES_I
	include "exec/semaphores.i"
	ENDC

NEWLOCKS	equ	1

 STRUCTURE  Layer,0
    LONG    lr_front
    LONG    lr_back
    LONG    lr_ClipRect
    LONG    lr_rp
    WORD    lr_MinX
    WORD    lr_MinY
    WORD    lr_MaxX
    WORD    lr_MaxY
	STRUCT	lr_reserved,4
	WORD	lr_priority
    WORD    lr_Flags
    LONG    lr_SuperBitMap
    LONG    lr_SuperClipRect
    APTR    lr_Window
    WORD    lr_Scroll_X
    WORD    lr_Scroll_Y
    APTR    lr_cr
    APTR    lr_cr2
    APTR    lr_crnew
    APTR    lr_SuperSaverClipRects
    APTR    lr__cliprects
    APTR    lr_LayerInfo
*			just by lucky coincidence
*			this is not confused with simplesprites
	STRUCT	lr_Lock,SS_SIZE
	STRUCT	lr_reserved3,8
	APTR	lr_ClipRegion
	APTR	lr_saveClipRects
	STRUCT	lr_reserved2,22
    APTR    lr_DamageList
    LABEL   lr_SIZEOF

 STRUCTURE  ClipRect,0
    LONG    cr_Next
    LONG    cr_prev
    LONG    cr_lobs
    LONG    cr_BitMap
    WORD    cr_MinX
    WORD    cr_MinY
    WORD    cr_MaxX
    WORD    cr_MaxY
    APTR    cr__p1
    APTR    cr__p2
    LONG    cr_reserved
    LONG    cr_Flags
 LABEL	    cr_SIZEOF

* internal cliprect flags
CR_NEEDS_NO_CONCEALED_RASTERS	equ	1

* defines for clipping
ISLESSX equ 1
ISLESSY equ 2
ISGRTRX equ 4
ISGRTRY equ 8

* for ancient history reasons
	IFND	lr_Front
lr_Front	equ lr_front
lr_Back		equ lr_back
lr_RastPort	equ	lr_rp
cr_Prev		equ cr_prev
cr_LObs		equ	cr_lobs
	ENDC

	ENDC	; GRAPHICS_CLIP_I
