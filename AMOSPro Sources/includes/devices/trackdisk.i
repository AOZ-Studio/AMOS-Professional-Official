	IFND	DEVICES_TRACKDISK_I
DEVICES_TRACKDISK_I	SET	1
**
**	$Filename: devices/trackdisk.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_IO_I
	INCLUDE "exec/io.i"
	ENDC	; EXEC_IO_I

	IFND	EXEC_DEVICES_I
	INCLUDE "exec/devices.i"
	ENDC	; EXEC_DEVICES_I

*--------------------------------------------------------------------
*
* Physical drive constants
*
*--------------------------------------------------------------------


* OBSOLETE -- only valid for 3 1/4" drives.  Use the TD_GETNUMTRACKS command!
*
*NUMCYLS		EQU	80		; normal # of cylinders
*MAXCYLS		EQU	NUMCYLS+20	; max # of cyls to look for
*						;	during a calibrate
*NUMHEADS	EQU	2
*NUMTRACKS	EQU	NUMCYLS*NUMHEADS

NUMSECS		EQU	11
NUMUNITS	EQU	4

*--------------------------------------------------------------------
*
* Useful constants
*
*--------------------------------------------------------------------


*-- sizes before mfm encoding
TD_SECTOR	EQU	512
TD_SECSHIFT	EQU	9			; log TD_SECTOR
*						;    2


*--------------------------------------------------------------------
*
* Driver Specific Commands
*
*--------------------------------------------------------------------

*-- TD_NAME is a generic macro to get the name of the driver.  This
*-- way if the name is ever changed you will pick up the change
*-- automatically.
*--
*-- Normal usage would be:
*--
*-- internalName:	TD_NAME
*--

TD_NAME:	MACRO
		DC.B	'trackdisk.device',0
		DS.W	0
		ENDM

	BITDEF	TD,EXTCOM,15

	DEVINIT
	DEVCMD	TD_MOTOR		; control the disk's motor
	DEVCMD	TD_SEEK			; explicit seek (for testing)
	DEVCMD	TD_FORMAT		; format disk
	DEVCMD	TD_REMOVE		; notify when disk changes
	DEVCMD	TD_CHANGENUM		; number of disk changes
	DEVCMD	TD_CHANGESTATE		; is there a disk in the drive?
	DEVCMD	TD_PROTSTATUS		; is the disk write protected?
	DEVCMD	TD_RAWREAD		; read raw bits from the disk
	DEVCMD	TD_RAWWRITE		; write raw bits to the disk
	DEVCMD	TD_GETDRIVETYPE		; get the type of the disk drive
	DEVCMD	TD_GETNUMTRACKS		; get the # of tracks on this disk
	DEVCMD	TD_ADDCHANGEINT		; TD_REMOVE done right
	DEVCMD	TD_REMCHANGEINT		; removes softint set by ADDCHANGEINT
	DEVCMD	TD_LASTCOMM		; dummy placeholder for end of list


*
*
* The disk driver has an "extended command" facility.  These commands
* take a superset of the normal IO Request block.
*
ETD_WRITE	EQU	(CMD_WRITE!TDF_EXTCOM)
ETD_READ	EQU	(CMD_READ!TDF_EXTCOM)
ETD_MOTOR	EQU	(TD_MOTOR!TDF_EXTCOM)
ETD_SEEK	EQU	(TD_SEEK!TDF_EXTCOM)
ETD_FORMAT	EQU	(TD_FORMAT!TDF_EXTCOM)
ETD_UPDATE	EQU	(CMD_UPDATE!TDF_EXTCOM)
ETD_CLEAR	EQU	(CMD_CLEAR!TDF_EXTCOM)
ETD_RAWREAD	EQU	(TD_RAWREAD!TDF_EXTCOM)
ETD_RAWWRITE	EQU	(TD_RAWWRITE!TDF_EXTCOM)


*
* extended IO has a larger than normal io request block.
*

 STRUCTURE IOEXTTD,IOSTD_SIZE
	ULONG	IOTD_COUNT	; removal/insertion count
	ULONG	IOTD_SECLABEL	; sector label data region
	LABEL	IOTD_SIZE

*
* raw read and write can be synced with the index pulse.  This flag
* in io request's IO_FLAGS field tells the driver that you want this.
*
	BITDEF	IOTD,INDEXSYNC,4

* labels are TD_LABELSIZE bytes per sector

TD_LABELSIZE	EQU	16

*
* This is a bit in the FLAGS field of OpenDevice.  If it is set, then
* the driver will allow you to open all the disks that the trackdisk
* driver understands.  Otherwise only 3.5" disks will succeed.
*
*
	BITDEF	TD,ALLOW_NON_3_5,0

*
*  If you set the TDB_ALLOW_NON_3_5 bit in OpenDevice, then you don't
*  know what type of disk you really got.  These defines are for the
*  TD_GETDRIVETYPE command.  In addition, you can find out how many
*  tracks are supported via the TD_GETNUMTRACKS command.
*
DRIVE3_5	EQU	1
DRIVE5_25	EQU	2

*--------------------------------------------------------------------
*
* Driver error defines
*
*--------------------------------------------------------------------

TDERR_NotSpecified	EQU	20	; general catchall
TDERR_NoSecHdr		EQU	21	; couldn't even find a sector
TDERR_BadSecPreamble	EQU	22	; sector looked wrong
TDERR_BadSecID		EQU	23	; ditto
TDERR_BadHdrSum		EQU	24	; header had incorrect checksum
TDERR_BadSecSum		EQU	25	; data had incorrect checksum
TDERR_TooFewSecs	EQU	26	; couldn't find enough sectors
TDERR_BadSecHdr		EQU	27	; another "sector looked wrong"
TDERR_WriteProt		EQU	28	; can't write to a protected disk
TDERR_DiskChanged	EQU	29	; no disk in the drive
TDERR_SeekError		EQU	30	; couldn't find track 0
TDERR_NoMem		EQU	31	; ran out of memory
TDERR_BadUnitNum	EQU	32	; asked for a unit > NUMUNITS
TDERR_BadDriveType	EQU	33	; not a drive that trackdisk groks
TDERR_DriveInUse	EQU	34	; someone else allocated the drive
TDERR_PostReset		EQU	35	; user hit reset; awaiting doom

*--------------------------------------------------------------------
*
* Public portion of unit structure
*
*--------------------------------------------------------------------

 STRUCTURE TDU_PUBLICUNIT,UNIT_SIZE
	UWORD	TDU_COMP01TRACK		; track for first precomp
	UWORD	TDU_COMP10TRACK		; track for second precomp
	UWORD	TDU_COMP11TRACK		; track for third precomp
	ULONG	TDU_STEPDELAY		; time to wait after stepping
	ULONG	TDU_SETTLEDELAY		; time to wait after seeking
	UBYTE	TDU_RETRYCNT		; # of times to retry
	LABEL	TDU_PUBLICUNITSIZE

	ENDC	; DEVICES_TRACKDISK_I
