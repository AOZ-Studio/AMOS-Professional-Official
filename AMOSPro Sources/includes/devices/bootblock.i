	IFND	DEVICES_BOOTBLOCK_I
DEVICES_BOOTBLOCK_I	SET	1
**
**	$Filename: devices/bootblock.i $
**	$Release: 1.3 $
**
**	BootBlock definition: 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

 STRUCTURE BB,0
	STRUCT	BB_ID,4		* 4 character identifier
	LONG	BB_CHKSUM	* boot block checksum (balance)
	LONG	BB_DOSBLOCK	* reserved for DOS patch
	LABEL	BB_ENTRY	* bootstrap entry point
	LABEL	BB_SIZE

BOOTSECTS	equ	2	* 1K bootstrap

BBID_DOS	macro		* something that is bootable
		dc.b	'DOS',0
		endm

BBID_KICK	macro		* firmware image disk
		dc.b	'KICK'
		endm


BBNAME_DOS	EQU	(('D'<<24)!('O'<<16)!('S'<<8))
BBNAME_KICK	EQU	(('K'<<24)!('I'<<16)!('C'<<8)!('K'))

	ENDC	; DEVICES_BOOTBLOCK_I
