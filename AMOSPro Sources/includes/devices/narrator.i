	IFND	DEVICES_NARRATOR_I
DEVICES_NARRATOR_I	SET	1
**
**	$Filename: devices/narrator.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	IFND	EXEC_IO_I
	INCLUDE "exec/io.i"
	ENDC

*-------- DEFAULT VALUES, USER PARMS, AND GENERAL CONSTANTS

DEFPITCH  EQU	    110		   ;DEFAULT PITCH
DEFRATE	  EQU	    150		   ;DEFAULT RATE
DEFVOL	  EQU	    64		   ;DEFAULT VOLUME (FULL)
DEFFREQ	  EQU	    22200	   ;DEFAULT SAMPLING FREQUENCY
NATURALF0 EQU	    0		   ;NATURAL F0 CONTOURS
ROBOTICF0 EQU	    1		   ;MONOTONE F0
MALE	  EQU	    0		   ;MALE SPEAKER
FEMALE	  EQU	    1		   ;FEMALE SPEAKER
DEFSEX	  EQU	    MALE	   ;DEFAULT SEX
DEFMODE	  EQU	    NATURALF0	   ;DEFAULT MODE

*     Parameter bounds

MINRATE	  EQU	    40		   ;MINIMUM SPEAKING RATE
MAXRATE	  EQU	    400		   ;MAXIMUM SPEAKING RATE
MINPITCH  EQU	    65		   ;MINIMUM PITCH
MAXPITCH  EQU	    320		   ;MAXIMUM PITCH
MINFREQ	  EQU	    5000	   ;MINIMUM SAMPLING FREQUENCY
MAXFREQ	  EQU	    28000	   ;MAXIMUM SAMPLING FREQUENCY
MINVOL	  EQU	    0		   ;MINIMUM VOLUME
MAXVOL	  EQU	    64		   ;MAXIMUM VOLUME

*     Driver error codes

ND_NotUsed	EQU	-1		;
ND_NoMem	EQU	-2		;Can't allocate memory
ND_NoAudLib	EQU	-3		;Can't open audio device
ND_MakeBad	EQU	-4		;Error in MakeLibrary call
ND_UnitErr	EQU	-5		;Unit other than 0
ND_CantAlloc	EQU	-6		;Can't allocate the audio channel
ND_Unimpl	EQU	-7		;Unimplemented command
ND_NoWrite	EQU	-8		;Read for mouth shape without write
ND_Expunged	EQU	-9		;Can't open, deferred expunge bit set
ND_PhonErr	EQU	-20		;Phoneme code spelling error
ND_RateErr	EQU	-21		;Rate out of bounds
ND_PitchErr	EQU	-22		;Pitch out of bounds
ND_SexErr	EQU	-23		;Sex not valid
ND_ModeErr	EQU	-24		;Mode not valid
ND_FreqErr	EQU	-25		;Sampling freq out of bounds
ND_VolErr	EQU	-26		;Volume out of bounds



*		;------ Write IORequest block 
 STRUCTURE NDI,IOSTD_SIZE
	UWORD	NDI_RATE		;Speaking rate in words/minute
	UWORD	NDI_PITCH		;Baseline pitch in Hertz
	UWORD	NDI_MODE		;F0 mode
	UWORD	NDI_SEX			;Speaker sex
	APTR	NDI_CHMASKS		;Pointer to audio channel masks
	UWORD	NDI_NUMMASKS		;Size of channel masks array
	UWORD	NDI_VOLUME		;Channel volume
	UWORD	NDI_SAMPFREQ		;Sampling frequency
	UBYTE	NDI_MOUTHS		;Generate mouths? (Boolean value)
	UBYTE	NDI_CHANMASK		;Actual channel mask used (internal use)
	UBYTE	NDI_NUMCHAN		;Number of channels used (internal use)
	UBYTE	NDI_PAD			;For alignment
	LABEL	NDI_SIZE		;Size of Narrator IORequest block


*		;------ Mouth read IORB
 STRUCTURE MRB,NDI_SIZE
	UBYTE	MRB_WIDTH		;Mouth width
	UBYTE	MRB_HEIGHT		;Mouth height
	UBYTE	MRB_SHAPE		;Compressed shape (height/width)
	UBYTE	MRB_PAD			;Alignment
	LABEL	MRB_SIZE

	ENDC	; DEVICES_NARRATOR_I
