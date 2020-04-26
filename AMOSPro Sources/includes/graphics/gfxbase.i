	IFND	GRAPHICS_GFXBASE_I
GRAPHICS_GFXBASE_I	SET	1
**
**	$Filename: graphics/gfxbase.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    IFND    EXEC_LISTS_I
    include "exec/lists.i"
    ENDC
    IFND    EXEC_LIBRARIES_I
    include "exec/libraries.i"
    ENDC
    IFND    EXEC_INTERRUPTS_I
    include "exec/interrupts.i"
    ENDC

 STRUCTURE  GfxBase,LIB_SIZE
    APTR    gb_ActiView	    ; struct *View
    APTR    gb_copinit	    ; struct *copinit; ptr to copper start up list
    APTR    gb_cia	; for 6526 resource use
    APTR    gb_blitter	    ; for blitter resource use
    APTR    gb_LOFlist	    ; current copper list being run
    APTR    gb_SHFlist	    ; current copper list being run
    APTR    gb_blthd	    ; struct *bltnode
    APTR    gb_blttl	    ;
    APTR    gb_bsblthd	    ;
    APTR    gb_bsblttl	    ;
    STRUCT  gb_vbsrv,IS_SIZE
    STRUCT  gb_timsrv,IS_SIZE
    STRUCT  gb_bltsrv,IS_SIZE
    STRUCT  gb_TextFonts,LH_SIZE
    APTR    gb_DefaultFont
    UWORD   gb_Modes	    ; copy of bltcon0
    BYTE    gb_VBlank
    BYTE    gb_Debug
    UWORD   gb_BeamSync
    WORD    gb_system_bplcon0
    BYTE    gb_SpriteReserved
    BYTE    gb_bytereserved

    WORD    gb_Flags
    WORD    gb_BlitLock
	WORD	gb_BlitNest
	STRUCT	gb_BlitWaitQ,LH_SIZE
	APTR	gb_BlitOwner
	STRUCT	gb_TOF_WaitQ,LH_SIZE

	WORD	gb_DisplayFlags
	APTR	gb_SimpleSprites
	WORD	gb_MaxDisplayRow
	WORD	gb_MaxDisplayColumn
	WORD	gb_NormalDisplayRows
	WORD	gb_NormalDisplayColumns
	WORD	gb_NormalDPMX
	WORD	gb_NormalDPMY

	APTR	gb_LastChanceMemory
	APTR	gb_LCMptr

	WORD	gb_MicrosPerLine	; usecs per line times 256
	WORD	gb_MinDisplayColumn

    STRUCT  gb_reserved,92   ; bytes reserved for future use
    LABEL   gb_SIZE

* bits for dalestuff, which may go away when blitter becomes a resource
OWNBLITTERn equ 0   * blitter owned bit
QBOWNERn    equ 1   * blitter owned by blit queuer

QBOWNER	    equ 1<<QBOWNERn

	ENDC	; GRAPHICS_GFXBASE_I
