	IFND	HARDWARE_CUSTOM_I
HARDWARE_CUSTOM_I	SET	1
**
**	$Filename: hardware/custom.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

*
* do this to get base of custom registers:
*  XREF _custom;
*

bltddat	    EQU	  $000
dmaconr	    EQU	  $002
vposr	    EQU	  $004
vhposr	    EQU	  $006
dskdatr	    EQU	  $008
joy0dat	    EQU	  $00A
joy1dat	    EQU	  $00C
clxdat	    EQU	  $00E

adkconr	    EQU	  $010
pot0dat	    EQU	  $012
pot1dat	    EQU	  $014
potinp	    EQU	  $016
serdatr	    EQU	  $018
dskbytr	    EQU	  $01A
intenar	    EQU	  $01C
intreqr	    EQU	  $01E

dskpt	    EQU	  $020
dsklen	    EQU	  $024
dskdat	    EQU	  $026
refptr	    EQU	  $028
vposw	    EQU	  $02A
vhposw	    EQU	  $02C
copcon	    EQU	  $02E
serdat	    EQU	  $030
serper	    EQU	  $032
potgo	    EQU	  $034
joytest	    EQU	  $036
strequ	    EQU	  $038
strvbl	    EQU	  $03A
strhor	    EQU	  $03C
strlong	    EQU	  $03E

bltcon0	    EQU	  $040
bltcon1	    EQU	  $042
bltafwm	    EQU	  $044
bltalwm	    EQU	  $046
bltcpt	    EQU	  $048
bltbpt	    EQU	  $04C
bltapt	    EQU	  $050
bltdpt	    EQU	  $054
bltsize	    EQU	  $058

bltcmod	    EQU	  $060
bltbmod	    EQU	  $062
bltamod	    EQU	  $064
bltdmod	    EQU	  $066

bltcdat	    EQU	  $070
bltbdat	    EQU	  $072
bltadat	    EQU	  $074

dsksync	    EQU	  $07E

cop1lc	    EQU	  $080
cop2lc	    EQU	  $084
copjmp1	    EQU	  $088
copjmp2	    EQU	  $08A
copins	    EQU	  $08C
diwstrt	    EQU	  $08E
diwstop	    EQU	  $090
ddfstrt	    EQU	  $092
ddfstop	    EQU	  $094
dmacon	    EQU	  $096
clxcon	    EQU	  $098
intena	    EQU	  $09A
intreq	    EQU	  $09C
adkcon	    EQU	  $09E

aud	    EQU	  $0A0
aud0	    EQU	  $0A0
aud1	    EQU	  $0B0
aud2	    EQU	  $0C0
aud3	    EQU	  $0D0

* STRUCTURE AudChannel,0
ac_ptr	    EQU	  $00	; ptr to start of waveform data
ac_len	    EQU	  $04	; length of waveform in words
ac_per	    EQU	  $06	; sample period
ac_vol	    EQU	  $08	; volume
ac_dat	    EQU	  $0A	; sample pair
ac_SIZEOF   EQU	  $10

bplpt	    EQU	  $0E0

bplcon0	    EQU	  $100
bplcon1	    EQU	  $102
bplcon2	    EQU	  $104
bpl1mod	    EQU	  $108
bpl2mod	    EQU	  $10A

bpldat	    EQU	  $110

sprpt	    EQU	  $120

spr	    EQU	  $140
* STRUCTURE SpriteDef
sd_pos	    EQU	  $00
sd_ctl	    EQU	  $02
sd_dataa    EQU	  $04
sd_datab    EQU	  $08

color	    EQU	  $180

	ENDC	; HARDWARE_CUSTOM_I
