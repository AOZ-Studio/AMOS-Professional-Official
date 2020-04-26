	IFND	GRAPHICS_VIEW_I
GRAPHICS_VIEW_I SET	1
**
**	$Filename: graphics/view.i $
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

    IFND    GRAPHICS_COPPER_I
    include "graphics/copper.i"
    ENDC

V_PFBA	    EQU	    $40
V_DUALPF    EQU	    $400
V_HIRES	    EQU	    $8000
V_LACE	    EQU	    4
V_HAM	    EQU	    $800
V_SPRITES   EQU	    $4000
GENLOCK_VIDEO	EQU 2

   STRUCTURE   ColorMap,0
      BYTE  cm_Flags
      BYTE  cm_Type
      WORD  cm_Count
      APTR  cm_ColorTable
   LABEL cm_SIZEOF


   STRUCTURE	  ViewPort,0
   LONG	   vp_Next
   LONG	   vp_ColorMap
   LONG	   vp_DspIns
   LONG	   vp_SprIns
   LONG	   vp_ClrIns
   LONG	   vp_UCopIns
   WORD	   vp_DWidth
   WORD	   vp_DHeight
   WORD	   vp_DxOffset
   WORD	   vp_DyOffset
   WORD	   vp_Modes
   BYTE	   vp_SpritePriorities
   BYTE	   vp_reserved
   APTR	   vp_RasInfo
   LABEL   vp_SIZEOF


   STRUCTURE View,0
   LONG	   v_ViewPort
   LONG	   v_LOFCprList
   LONG	   v_SHFCprList
   WORD	   v_DyOffset
   WORD	   v_DxOffset
   WORD	   v_Modes
   LABEL   v_SIZEOF


   STRUCTURE  collTable,0
   LONG	   cp_collPtrs,16
   LABEL   cp_SIZEOF


   STRUCTURE  RasInfo,0
   APTR	   ri_Next
   LONG	   ri_BitMap
   WORD	   ri_RxOffset
   WORD	   ri_RyOffset
   LABEL   ri_SIZEOF

	ENDC	; GRAPHICS_VIEW_I
