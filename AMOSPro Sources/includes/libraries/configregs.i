	IFND	LIBRARIES_CONFIGREGS_I
LIBRARIES_CONFIGREGS_I	SET	1
**
**	$Filename: libraries/configregs.i $
**	$Release: 1.3 $
**
**	register and bit definitions for expansion boards 
**
**	(C) Copyright 1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

** Expansion boards are actually organized such that only one nibble per
** word (16 bits) are valid information.  This table is structured
** as LOGICAL information.  This means that it never corresponds
** exactly with a physical implementation.
**
** The expansion space is logically split into two regions:
** a rom portion and a control portion.	 The rom portion is
** actually stored in one's complement form (except for the
** er_type field).


 STRUCTURE ExpansionRom,0
    UBYTE	er_Type
    UBYTE	er_Product
    UBYTE	er_Flags
    UBYTE	er_Reserved03
    UWORD	er_Manufacturer
    ULONG	er_SerialNumber
    UWORD	er_InitDiagVec
    UBYTE	er_Reserved0c
    UBYTE	er_Reserved0d
    UBYTE	er_Reserved0e
    UBYTE	er_Reserved0f
    LABEL	ExpansionRom_SIZEOF

 STRUCTURE ExpansionControl,0
    UBYTE	ec_Interrupt		; interrupt control register
    UBYTE	ec_Reserved11
    UBYTE	ec_BaseAddress		; set new config address
    UBYTE	ec_Shutup		; don't respond, pass config out
    UBYTE	ec_Reserved14
    UBYTE	ec_Reserved15
    UBYTE	ec_Reserved16
    UBYTE	ec_Reserved17
    UBYTE	ec_Reserved18
    UBYTE	ec_Reserved19
    UBYTE	ec_Reserved1a
    UBYTE	ec_Reserved1b
    UBYTE	ec_Reserved1c
    UBYTE	ec_Reserved1d
    UBYTE	ec_Reserved1e
    UBYTE	ec_Reserved1f
    LABEL	ExpansionControl_SIZEOF

**
** many of the constants below consist of a triplet of equivalent
** definitions: xxMASK is a bit mask of those bits that matter.
** xxBIT is the starting bit number of the field.  xxSIZE is the
** number of bits that make up the definition.	This method is
** used when the field is larger than one bit.
**
** If the field is only one bit wide then the xxB_xx and xxF_xx convention
** is used (xxB_xx is the bit number, and xxF_xx is mask of the bit).
**

** manifest constants */
E_SLOTSIZE		EQU	$10000
E_SLOTMASK		EQU	$ffff
E_SLOTSHIFT		EQU	16

** these define the two free regions of Zorro memory space.
** THESE MAY WELL CHANGE FOR FUTURE PRODUCTS!
E_EXPANSIONBASE		EQU	$e80000
E_EXPANSIONSIZE		EQU	$080000
E_EXPANSIONSLOTS	EQU	8

E_MEMORYBASE		EQU	$200000
E_MEMORYSIZE		EQU	$800000
E_MEMORYSLOTS		EQU	128



******* ec_Type definitions */

** board type -- ignore "old style" boards */
ERT_TYPEMASK		EQU	$c0
ERT_TYPEBIT		EQU	6
ERT_TYPESIZE		EQU	2
ERT_NEWBOARD		EQU	$c0


** type field memory size */
ERT_MEMMASK		EQU	$07
ERT_MEMBIT		EQU	0
ERT_MEMSIZE		EQU	3


** other bits defined in type field */
	BITDEF	ERT,CHAINEDCONFIG,3
	BITDEF	ERT,DIAGVALID,4
	BITDEF	ERT,MEMLIST,5


** er_Flags byte -- for those things that didn't fit into the type byte */
	BITDEF	ERF,MEMSPACE,7		; wants to be in 8 meg space.  Also
					;     implies that board is moveable
	BITDEF	ERF,NOSHUTUP,6		; board can't be shut up.  Must not
					;     be a board.  Must be a box that
					;     does not pass on the bus.


** interrupt control register */
	BITDEF	ECI,INTENA,1
	BITDEF	ECI,RESET,3
	BITDEF	ECI,INT2PEND,4
	BITDEF	ECI,INT6PEND,5
	BITDEF	ECI,INT7PEND,6
	BITDEF	ECI,INTERRUPTING,7


**************************************************************************
**
** these are the specifications for the diagnostic area.  If the Diagnostic
** Address Valid bit is set in the Board Type byte (the first byte in
** expansion space) then the Diag Init vector contains a valid offset.
**
** The Diag Init vector is actually a word offset from the base of the
** board.  The resulting address points to the base of the DiagArea
** structure.  The structure may be physically implemented either four,
** eight, or sixteen bits wide.	 The code will be copied out into
** ram first before being called.
**
** The da_Size field, and both code offsets (da_DiagPoint and da_BootPoint)
** are offsets from the diag area AFTER it has been copied into ram, and
** "de-nibbleized" (if needed).	 Inotherwords, the size is the size of
** the actual information, not how much address space is required to
** store it.
**
** All bits are encoded with uninverted logic (e.g. 5 volts on the bus
** is a logic one).
**
** If your board is to make use of the boot facility then it must leave
** its config area available even after it has been configured.	 Your
** boot vector will be called AFTER your board's final address has been
** set.
**
**************************************************************************

 STRUCTURE DiagArea,0
    UBYTE	da_Config	; see below for definitions
    UBYTE	da_Flags	; see below for definitions
    UWORD	da_Size		; the size (in bytes) of the total diag area
    UWORD	da_DiagPoint	; where to start for diagnostics, or zero
    UWORD	da_BootPoint	; where to start for booting
    UWORD	da_Name		; offset in diag area where a string
				;   identifier can be found (or zero if no
				;   identifier is present).

    UWORD	da_Reserved01	; two words of reserved data.  must be zero.
    UWORD	da_Reserved02
    LABEL	DiagArea_SIZEOF

; da_Config definitions
DAC_BUSWIDTH	EQU	$C0	; two bits for bus width
DAC_NIBBLEWIDE	EQU	$00
DAC_BYTEWIDE	EQU	$40
DAC_WORDWIDE	EQU	$80

DAC_BOOTTIME	EQU	$30	; two bits for when to boot
DAC_NEVER	EQU	$00	; obvious
DAC_CONFIGTIME	EQU	$10	; call da_BootPoint when first configing the
				;   the device
DAC_BINDTIME	EQU	$20	; run when binding drivers to boards

**
** These are the calling conventions for Diag or Boot area
**
** A7 -- points to at least 2K of stack
** A6 -- ExecBase
** A5 -- ExpansionBase
** A3 -- your board's ConfigDev structure
** A2 -- Base of diag/init area that was copied
** A0 -- Base of your board
**
** Your board should return a value in D0.  If this value is NULL, then
** the diag/init area that was copied in will be returned to the free
** memory pool.
**

	ENDC	; LIBRARIES_CONFIGREGS_I
