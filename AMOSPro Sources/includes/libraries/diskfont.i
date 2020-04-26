	IFND	LIBRARIES_DISKFONT_I
LIBRARIES_DISKFONT_I	SET	1
**
**	$Filename: libraries/diskfont.i $
**	$Release: 1.3 $
**
**	diskfont library definitions 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

   IFND	    EXEC_NODES_I
   INCLUDE     "exec/nodes.i"
   ENDC
   IFND	    EXEC_LISTS_I
   INCLUDE     "exec/lists.i"
   ENDC
   IFND	    GRAPHICS_TEXT_I
   INCLUDE     "graphics/text.i"
   ENDC

MAXFONTPATH EQU	  256	; including null terminator

 STRUCTURE  FC,0
   STRUCT   fc_FileName,MAXFONTPATH
   UWORD fc_YSize
   UBYTE fc_Style
   UBYTE fc_Flags
   LABEL fc_SIZEOF

FCH_ID	    EQU	  $0f00

 STRUCTURE  FCH,0
   UWORD fch_FileID  ; FCH_ID
   UWORD fch_NumEntries ; the number of FontContents elements
   LABEL fch_FC	     ; the FontContents elements


DFH_ID	    EQU	  $0f80
MAXFONTNAME EQU	  32 ; font name including ".font\0"

 STRUCTURE  DiskFontHeader,0
    ; the following 8 bytes are not actually considered a part of the
    ; DiskFontHeader, but immediately preceed it.  The NextSegment is supplied
    ; by the linker/loader, and the ReturnCode is the code at the beginning
    ; of the font in case someone runs it...
    ; ULONG dfh_NextSegment   ; actually a BPTR
    ; ULONG dfh_ReturnCode    ; MOVEQ #0,D0 : RTS
    ; here then is the official start of the DiskFontHeader...
   STRUCT   dfh_DF,LN_SIZE    ; node to link disk fonts
   UWORD dfh_FileID	      ; DFH_ID
   UWORD dfh_Revision	      ; the font revision in this version
   LONG	 dfh_Segment	      ; the segment address when loaded
   STRUCT   dfh_Name,MAXFONTNAME ; the font name (null terminated)
   STRUCT   dfh_TF,tf_SIZEOF  ; loaded TextFont structure
   LABEL dfh_SIZEOF


   BITDEF   AF,MEMORY,0
   BITDEF   AF,DISK,1

 STRUCTURE  AF,0
   UWORD af_Type	; MEMORY or DISK
   STRUCT   af_Attr,ta_SIZEOF ; text attributes for font
   LABEL af_SIZEOF

 STRUCTURE  AFH,0
   UWORD afh_NumEntries	   ; number of AvailFonts elements
   LABEL afh_AF		; the AvailFonts elements

	ENDC	; LIBRARIES_DISKFONT_I
