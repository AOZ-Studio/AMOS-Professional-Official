	IFND	HARDWARE_BLIT_I
HARDWARE_BLIT_I SET	1
**
**	$Filename: hardware/blit.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

   STRUCTURE bltnode,0
   LONG	 bn_n
   LONG	 bn_function
   BYTE	 bn_stat
   BYTE	 bn_dummy
   WORD	 bn_blitsize
   WORD	 bn_beamsync
   LONG	 bn_cleanup
   LABEL bn_SIZEOF

* bit defines used by blit queuer
CLEANMEn    equ 6
CLEANME	    equ 1<<CLEANMEn

* include file for blitter */
HSIZEBITS   equ	  6
VSIZEBITS   equ	  16-HSIZEBITS
HSIZEMASK   equ	  $3f	      /* 2^6 -- 1 */
VSIZEMASK   equ	  $3FF	      /* 2^10 - 1 */

MAXBYTESPERROW EQU   128

* definitions for blitter control register 0 */

ABC	    equ	  $80
ABNC	    equ	  $40
ANBC	    equ	  $20
ANBNC	    equ	  $10
NABC	    equ	  $8
NABNC	    equ	  $4
NANBC	    equ	  $2
NANBNC	    equ	  $1

BC0B_DEST   equ	    8 
BC0B_SRCC   equ	    9 
BC0B_SRCB   equ	    10 
BC0B_SRCA   equ	    11 
BC0F_DEST   equ	  $100
BC0F_SRCC   equ	  $200
BC0F_SRCB   equ	  $400
BC0F_SRCA   equ	  $800

BC1F_DESC   equ 2

DEST	    equ	  $100
SRCC	    equ	  $200
SRCB	    equ	  $400
SRCA	    equ	  $800

ASHIFTSHIFT equ	  12 /* bits to right align ashift value */
BSHIFTSHIFT equ	  12 /* bits to right align bshift value */

* definations for blitter control register 1 */
LINEMODE    equ	  $1
FILL_OR	    equ	  $8
FILL_XOR    equ	  $10
FILL_CARRYIN   equ   $4
ONEDOT	    equ	  $2
OVFLAG	    equ	  $20
SIGNFLAG    equ	  $40
BLITREVERSE equ	  $2

SUD	    equ	  $10
SUL	    equ	  $8
AUL	    equ	  $4

OCTANT8	    equ	  24
OCTANT7	    equ	  4
OCTANT6	    equ	  12
OCTANT5	    equ	  28
OCTANT4	    equ	  20
OCTANT3	    equ	  8
OCTANT2	    equ	  0
OCTANT1	    equ	  16

	ENDC	; HARDWARE_BLIT_I
