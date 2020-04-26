	IFND	GRAPHICS_TEXT_I
GRAPHICS_TEXT_I SET	1
**
**	$Filename: graphics/text.i $
**	$Release: 1.3 $
**
**	graphics library text structures 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**
   
   IFND	    EXEC_PORTS_I
   INCLUDE  "exec/ports.i"
   ENDC

*------ Font Styles --------------------------------------------------
FS_NORMAL   EQU 0	      ;normal text (no style attributes set)
   BITDEF   FS,EXTENDED,3     ;extended face (must be designed)
   BITDEF   FS,ITALIC,2	      ;italic (slanted 1:2 right)
   BITDEF   FS,BOLD,1	      ;bold face text (ORed w/ shifted right 1)
   BITDEF   FS,UNDERLINED,0   ;underlined (under baseline)

*------ Font Flags ---------------------------------------------------
   BITDEF   FP,ROMFONT,0      ;font is in rom
   BITDEF   FP,DISKFONT,1     ;font is from diskfont.library
   BITDEF   FP,REVPATH,2      ;designed path is reversed (e.g. left)
   BITDEF   FP,TALLDOT,3      ;designed for hires non-interlaced
   BITDEF   FP,WIDEDOT,4      ;designed for lores interlaced
   BITDEF   FP,PROPORTIONAL,5 ;character sizes can vary from nominal
   BITDEF   FP,DESIGNED,6     ;size is "designed", not constructed
   BITDEF   FP,REMOVED,7      ; the font has been removed


******* TextAttr node ************************************************
 STRUCTURE  TextAttr,0
   APTR	    ta_Name	      ;name of the desired font
   UWORD    ta_YSize	      ;size of the desired font
   UBYTE    ta_Style	      ;desired font style
   UBYTE    ta_Flags	      ;font preferences
   LABEL    ta_SIZEOF


******* TextFont node ************************************************
 STRUCTURE  TextFont,MN_SIZE
*			      ;font name in LN	      \ used in this
   UWORD    tf_YSize	      ;font height	      | order to best
   UBYTE    tf_Style	      ;font style	      | match a font
   UBYTE    tf_Flags	      ;preference attributes  / request.
   UWORD    tf_XSize	      ;nominal font width
   UWORD    tf_Baseline	      ;distance from the top of char to baseline
   UWORD    tf_BoldSmear      ;smear to affect a bold enhancement

   UWORD    tf_Accessors      ;access count

   UBYTE    tf_LoChar	      ;the first character described here
   UBYTE    tf_HiChar	      ;the last character described here
   APTR	    tf_CharData	      ;the bit character data

   UWORD    tf_Modulo	      ;the row modulo for the strike font data
   APTR	    tf_CharLoc	      ;ptr to location data for the strike font
*	    ;  2 words: bit offset then size
   APTR	    tf_CharSpace      ;ptr to words of proportional spacing data
   APTR	    tf_CharKern	      ;ptr to words of kerning data
   LABEL    tf_SIZEOF

	ENDC	; GRAPHICS_TEXT_I
