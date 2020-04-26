	IFND	DEVICES_CONUNIT_I
DEVICES_CONUNIT_I	SET	1
**
**	$Filename: devices/conunit.i $
**	$Release: 1.3 $
**
**	Console device unit definitions 
**
**	(C) Copyright 1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

   IFND	 EXEC_PORTS_I
   INCLUDE  "exec/ports.i"
   ENDC

   IFND	 DEVICES_CONSOLE_I
   INCLUDE  "devices/console.i"
   ENDC

   IFND	 DEVICES_KEYMAP_I
   INCLUDE  "devices/keymap.i"
   ENDC

   IFND	 DEVICES_INPUTEVENT_I
   INCLUDE  "devices/inputevent.i"
   ENDC

PMB_ASM	    EQU	  M_LNM+1     ; internal storage bit for AS flag
PMB_AWM	    EQU	  PMB_ASM+1   ; internal storage bit for AW flag
MAXTABS	    EQU	  80


 STRUCTURE  ConUnit,MP_SIZE
    ;------ read only variables
   APTR	 cu_Window	      ; intuition window bound to this unit
   WORD	 cu_XCP		      ; character position
   WORD	 cu_YCP
   WORD	 cu_XMax	      ; max character position
   WORD	 cu_YMax
   WORD	 cu_XRSize	      ; character raster size
   WORD	 cu_YRSize
   WORD	 cu_XROrigin	      ; raster origin
   WORD	 cu_YROrigin
   WORD	 cu_XRExtant	      ; raster maxima
   WORD	 cu_YRExtant
   WORD	 cu_XMinShrink	      ; smallest area intact from resize process
   WORD	 cu_YMinShrink
   WORD	 cu_XCCP	      ; cursor position
   WORD	 cu_YCCP

   ;------ read/write variables (writes must must be protected)
   ;------ storage for AskKeyMap and SetKeyMap
   STRUCT   cu_KeyMapStruct,km_SIZEOF
   ; ---- tab stops
   STRUCT   cu_TabStops,2*MAXTABS   ; 0 at start, 0xffff at end of list

   ;------ console rastport attributes
   BYTE	 cu_Mask	      ; these must appear as in RastPort
   BYTE	 cu_FgPen	      ;	  |
   BYTE	 cu_BgPen	      ;	  |
   BYTE	 cu_AOLPen	      ;	  +
   BYTE	 cu_DrawMode	      ; these must appear as in RastPort
   BYTE	 cu_AreaPtSz	      ;	  +
   APTR	 cu_AreaPtrn	      ; cursor area pattern
   STRUCT   cu_Minterms,8     ; console minterms
   APTR	 cu_Font	      ;
   UBYTE cu_AlgoStyle	      ; these must appear as in RastPort
   UBYTE cu_TxFlags	      ;	  +
   UWORD cu_TxHeight	      ; these must appear as in RastPort
   UWORD cu_TxWidth	      ;	  |
   UWORD cu_TxBaseline	      ;	  |
   UWORD cu_TxSpacing	      ;	  +

   ;------ console MODES and RAW EVENTS switches
   STRUCT   cu_Modes,<(PMB_AWM+7)/8>   ; one bit per mode
   STRUCT   cu_RawEvents,<(IECLASS_MAX+7)/8>

   ;------ ensure the ConsUnit structure is even
ODDEVEN	 EQU   ((PMB_AWM+7)/8)+((IECLASS_MAX+7)/8)
   IFNE	 ODDEVEN-((ODDEVEN/2)*2)
      UBYTE cu_pad   
   ENDC

   LABEL ConUnit_SIZEOF

	ENDC	; DEVICES_CONUNIT_I
