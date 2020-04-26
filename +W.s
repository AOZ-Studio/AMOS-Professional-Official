
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;		LIBRAIRIE GRAPHIQUE AMOS
;
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;  Published under the MIT Licence
;
;  Copyright (c) 1992 Europress Software
;  Copyright (c) 2020 Francois Lionet
;
;  Permission is hereby granted, free of charge, to any person
;  obtaining a copy of this software and associated documentation
;  files (the "Software"), to deal in the Software without
;  restriction, including without limitation the rights to use,
;  copy, modify, merge, publish, distribute, sublicense, and/or
;  sell copies of the Software, and to permit persons to whom the
;  Software is furnished to do so, subject to the following
;  conditions:
;
;  The above copyright notice and this permission notice shall be
;  included in all copies or substantial portions of the Software.
;
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
;  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
;  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		OPT	P+

***************************************************************************
		IFND	EZFlag
EZFlag		equ 	0
		ENDC
***************************************************************************

		IncDir	"includes/"
		Include "exec/types.i"
		Include "exec/interrupts.i"
		Include "graphics/gfx.i"
		Include "graphics/layers.i"
		Include "graphics/clip.i"
		Include "hardware/intbits.i"
		Include "devices/input.i"
		Include "devices/inputevent.i"

		Include	"+Debug.s"
		Include	"+AMOS_Includes.s"

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Version	MACRO
	dc.b	0,"$VER: 2.00",0
	even
	ENDM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WDebut	bra	Startall	Cold start
	bra	Endall		End
	dc.l	L_Trappe	Length of data zone
	bra	IceStart	Access of System functions
	bra	IceEnd		Stop access of system functions
	dc.b	"P110"		Version Pro 1.10

BugBug	movem.l	d0-d2/a0-a2,-(sp)
.Ll	move.w	#$FF0,$DFF180
 	btst	#6,$BFE001
	bne.s	.Ll
	move.w	#20,d0
.L0	move.w	#10000,d1
.L1	move.w	d0,$DFF180
	dbra	d1,.L1
	dbra	d0,.L0
	btst	#6,$BFE001
	beq.s	.Ill
	movem.l	(sp)+,d0-d2/a0-a2
	rts
.Ill	moveq	#0,d1
	bsr	TAMOSWb
	movem.l	(sp)+,d0-d2/a0-a2
	illegal
	rts

		Version

	IFEQ	EZFlag
***********************************************************
*	COLLISIONS HARD

******* SET HARDCOL
*	D1= 	Sprites
*	D2=	Enable
*	D3=	Compare
HColSet	and.w	#$000F,d1
	lsl.w	#8,d1
	lsl.w	#4,d1
	and.w	#$003F,d2
	lsl.w	#6,d2
	and.w	#$003F,d3
	or.w	d2,d1
	or.w	d3,d1
	move.w	d1,Circuits+$98
	moveq	#0,d0
	rts
******* =HARDCOL
*	D1=	#Sprite / -1 Si bitplanes
HColGet	lea	T_TColl(a5),a0
	move.l	a0,a1
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.w	Circuits+$0E,d2
	tst.w	d1
	bmi.s	HCol3
* Sprites
	and.w	#$0006,d1
	lsl.w	#2,d1
	lea	HColT(pc),a0
	add.w	d1,a0
	moveq	#0,d3
	moveq	#%00000011,d4
	moveq	#0,d1
	move.b	(a0)+,d0
HCol1	bmi.s	HCol2
	btst	d0,d2
	beq.s	HCol2
	or.w	d4,d3
	cmp.w	#$0100,d3
	bcc.s	HCol2
	moveq	#-1,d1
HCol2	lsl.w	#2,d4
	move.b	(a0)+,d0
	bne.s	HCol1
* Ok!
	ror.w	#8,d3
	move.w	d3,(a1)
	moveq	#0,d0
	rts
******* Playfield / Playfield
HCol3	moveq	#0,d1
	btst	#0,d2
	beq.s	HCol4
	moveq	#-1,d1
HCol4	rts
******* Table des bits a tester!
HColT	dc.b	-1,9,10,11,1,5,0,0
	dc.b	9,-1,12,13,2,6,0,0
	dc.b	10,12,-1,14,3,7,0,0
	dc.b	11,13,14,-1,4,8,0,0
	ENDC

***********************************************************
*	COLLISIONS SOFT

******* Routine collision:
*	A3/A2= 	descripteur sprite concerne
*	D0/D1=	bob dest   DX/DY
*	D2=	Image!
*	D4/D5= 	bob source DX/DY
*	D6/D7=	bob source FX/FY
*	A4=	banque!
******* RETOUR: BNE-> Pas coll
*******		BEQ-> Coll
ColRout:
* Pointe le descripteur
	and.w	#$3FFF,d2
	beq	ColRF
	cmp.w	(a4),d2
	bhi	ColRF
	lsl.w	#3,d2
	lea	-8+2(a4,d2.w),a0
	move.l	4(a0),d2
	ble	ColRF
	move.l	d2,a1
	move.l	(a0),d2
	beq	ColRF
	move.l	d2,a0
* Prend les coordonnees
	move.w	6(a0),d2
	lsl.w	#2,d2
	asr.w	#2,d2
	sub.w	d2,d0
	sub.w	8(a0),d1
	move.w	(a0),d2
	lsl.w	#4,d2
	move.w	2(a0),d3
	add.w	d0,d2
	add.w	d1,d3
* Croisement?
	cmp.w	d4,d2
	ble	ColRF
	cmp.w	d6,d0
	bge	ColRF
	cmp.w	d5,d3
	ble	ColRF
	cmp.w	d7,d1
	bge	ColRF
* Verifie avec le blitter!
	movem.l	d4-d7/a2/a3,-(sp)
	cmp.w	d0,d4		* Met le plus a gauche en D0
	bge.s	ColR1
	exg.l	d0,d4
	exg.l	d1,d5
	exg.l	d2,d6
	exg.l	d3,d7
	exg.l	a1,a3
	exg.l	a0,a2
ColR1:	cmp.w	d5,d1
	bge.s	ColR5
	move.w	d5,-(sp)
	sub.w	d1,(sp)
	clr.w	-(sp)
ColR2:	cmp.w	d3,d7
	bge.s	ColR3
	move.w	d7,-(sp)
	bra.s	ColR4
ColR3:	move.w	d3,-(sp)
ColR4:	sub.w	d5,(sp)
	bra.s	ColR7a
ColR5:	clr.w	-(sp)
	move.w	d1,-(sp)
	sub.w	d5,(sp)
	cmp.w	d3,d7
	bge.s	ColR6
	move.w	d7,-(sp)
	bra.s	ColR7
ColR6:	move.w	d3,-(sp)
ColR7:	sub.w	d1,(sp)

ColR7a:	move.w	d4,d1
	sub.w	d0,d1
	cmp.w	d2,d6
	bge.s	ColR8
	move.w	d6,d3
	bra.s	ColR9
ColR8:	move.w	d2,d3
ColR9:	sub.w	d4,d3

	move.w	d1,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	move.w	d0,BltCon1(a6)
	move.w	#%0000110011000000,BltCon0(a6)
	lsr.w	#4,d3
	tst.w	d0
	beq.s	ColRA
	addq.w	#1,d3
ColRA:	move.w	d3,d4
	move.w	(sp)+,d0
	ble.s	ColRF0
	lsl.w	#6,d0
	or.w	d0,d4
	lsl.w	#1,d3
	move.w	(a0),d0
	lsl.w	#1,d0
;	addq.w	#2,d0
	move.w	d0,d6
	sub.w	d3,d0
	move.w	d0,BltModA(a6)
	move.w	(a2),d0
	lsl.w	#1,d0
;	addq.w	#2,d0
	move.w	d0,d5
	sub.w	d3,d0
	move.w	d0,BltModB(a6)

	mulu	(sp)+,d5
	lea	4(a3,d5.w),a3
	move.l	a3,BltAdB(a6)
	move.w	d1,d0
	lsr.w	#4,d0
	lsl.w	#1,d0
	mulu	(sp)+,d6
	add.w	d0,d6
	lea	4(a1,d6.w),a1
	move.l	a1,BltAdA(a6)
	move.w	#-1,BltMaskD(a6)
	and.w	#$000F,d1
	lsl.w	#1,d1
	lea	MCls(pc),a1
	move.w	0(a1,d1.w),BltMaskG(a6)

	move.w	d4,BltSize(a6)
	movem.l	(sp)+,d4-d7/a2/a3

ColRW:	bsr	BlitWait
	btst	#13,DmaConR(a6)
	rts
* Yapa collision!
ColRF:	moveq	#1,d0
	rts
* Yapa special!
ColRF0:	addq.l	#4,sp
ColRF1:	movem.l	(sp)+,d4-d7/a2/a3
	moveq	#1,d0
	rts

***********************************************************
*	BOB COLLIDE
*	D1= Numero du bob
*	D2= Debut a explorer (Bit 31===> TO SPRITE)
*	D3= Fin a explorer
BbColl:	movem.l	a2-a6/d2-d7,-(sp)
	lea	Circuits,a6
	bsr	OwnBlit
	lea	T_TColl(a5),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	moveq	#0,d7
	move.l	T_SprBank(a5),d0
	beq	BbColX
	move.l	d0,a4
	bsr	BobAd
	bne	BbColX

* Coordonnees du bob a tester!
	move.l	a1,a2
	tst.b	BbAct(a2)
	bmi	BbColX
	move.w	d1,a0
	move.l	BbEc(a2),d1
	move.w	BbX(a2),d4
	move.w	BbY(a2),d5
	move.w	BbI(a2),d0
	and.w	#$3FFF,d0
	beq	BbColX
	cmp.w	(a4),d0
	bhi	BbColX
	lsl.w	#3,d0
	lea	-8+2(a4,d0.w),a2
	move.l	4(a2),d0
	ble	BbColX
	move.l	d0,a3
	move.l	(a2),d0
	beq	BbColX
	move.l	d0,a2
	move.w	6(a2),d0
	lsl.w	#2,d0
	asr.w	#2,d0
	sub.w	d0,d4
	sub.w	8(a2),d5
	move.w	d4,d6
	move.w	d5,d7
	move.w	(a2),d0
	lsl.w	#4,d0
	add.w	d0,d6
	add.w	2(a2),d7
	btst	#31,d2
	bne	GoToSp

	exg.l	a0,a5
	move.l	T_BbDeb(a0),d0
	lea	T_TColl(a0),a0
******* Explore la table des bobs!
BbCol1:	move.l	d0,a1
	move.w	BbNb(a1),d0
	cmp.w	d2,d0
	bcs.s	BbColN
	cmp.w	d3,d0
	bhi.s	BbColX
	cmp.w	a5,d0
	beq.s	BbColN
	cmp.l	BbEc(a1),d1
	bne.s	BbColN
	tst.b	BbAct(a1)
	bmi.s	BbColN
	movem.l	d0-d3/a0/a1,-(sp)
	move.w	BbX(a1),d0
	move.w	BbY(a1),d1
	move.w	BbI(a1),d2
	bsr	ColRout
	movem.l	(sp)+,d0-d3/a0/a1
	bne.s	BbColN
	swap	d2
	and.w	#$00FF,d0
	move.w	d0,d2
	lsr.w	#3,d0
	and.w	#$7,d2
	bset	d2,0(a0,d0.w)
	bset	#31,d7
	swap	d2
BbColN:	move.l	BbNext(a1),d0
	bne.s	BbCol1

******* Fini!
BbColX:	bsr	DOwnBlit
	btst	#31,d7
	bne.s	BbColT
	moveq	#0,d0
	bra.s	BbColXx
BbColT	moveq	#-1,d0
BbColXx	movem.l	(sp)+,a2-a6/d2-d7
	rts

******* Conversion---> HARD
GoToSp:	movem.w	d2-d3,-(sp)
	move.l	d1,a0
	sub.w	d4,d6
	sub.w	d5,d7
	move.w	d4,d1
	move.w	d5,d2
	bsr	CXyS
	move.w	d1,d4
	move.w	d2,d5
	add.w	d4,d6
	add.w	d5,d7
	movem.w	(sp)+,d2-d3
	moveq	#-1,d1
	bra	BbToSp

	IFEQ	EZFlag
***********************************************************
*	SPRITE COLLIDE
*	D1= Numero du sprite
*	D2= Debut a explorer
*	D3= Fin a explorer
SpColl:	movem.l	a2-a6/d2-d7,-(sp)
	lea	Circuits,a6
	bsr	OwnBlit
	lea	T_TColl(a5),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	moveq	#0,d7
	move.l	T_SprBank(a5),d0
	beq	BbColX
	move.l	d0,a4

* Coordonnees du sprite a tester!
	cmp.w	#64,d1
	bcc	BbColX
	lea	T_HsTAct(a5),a2
	move.w	d1,d0
	lsl.w	#3,d0
	add.w	d0,a2
	move.w	2(a2),d4
	move.w	4(a2),d5
	move.w	6(a2),d0
	and.w	#$3FFF,d0
	beq	BbColX
	cmp.w	(a4),d0
	bhi	BbColX
	lsl.w	#3,d0
	lea	-8+2(a4,d0.w),a2
	move.l	4(a2),d0
	ble	BbColX
	move.l	d0,a3
	move.l	(a2),d0
	beq	BbColX
	move.l	d0,a2
	move.w	6(a2),d0
	lsl.w	#2,d0
	asr.w	#2,d0
	sub.w	d0,d4
	sub.w	8(a2),d5
	move.w	d4,d6
	move.w	d5,d7
	move.w	(a2),d0
	lsl.w	#4,d0
	add.w	d0,d6
	add.w	2(a2),d7
	btst	#31,d2
	bne	SpToBb
	ENDC

BbToSp:	cmp.w	#64,d3
	bcc	BbColX
	cmp.w	d2,d3
	bcs	BbColX
	lea	T_TColl(a5),a0
	lea	T_HsTAct(a5),a1
	move.w	d2,d0
	lsl.w	#3,d2
	add.w	d2,a1
	move.w	d3,a5
******* Explore la table des sprites!
SpCol1:	cmp.w	d1,d0
	beq.s	SpColN
	tst.w	(a1)
	bmi.s	SpColN
	move.w	6(a1),d2
	ble.s	SpColN
	movem.l	d0/d1/a0/a1,-(sp)
	move.w	2(a1),d0
	move.w	4(a1),d1
	bsr	ColRout
	movem.l	(sp)+,d0/d1/a0/a1
	bne.s	SpColN
	move.w	d0,d2
	move.w	d0,d3
	lsr.w	#3,d2
	and.w	#$7,d3
	bset	d3,0(a0,d2.w)
	bset	#31,d7
SpColN:	addq.w	#1,d0
	addq.l	#8,a1
	cmp.w	a5,d0
	bls.s	SpCol1
	bra	BbColX

******* Fin de SPRITE/BOB
SpToBb:	move.l	T_BbDeb(a5),d0
	lea	T_TColl(a5),a5
SbCol1:	move.l	d0,a1
	move.w	BbNb(a1),d0
	cmp.w	d2,d0
	bcs	SbColN
	cmp.w	d3,d0
	bhi	BbColX
	tst.b	BbAct(a1)
	bmi	SbColN
	movem.l	d0/d2/d3/a1,-(sp)
	move.l	BbEc(a1),a0
	move.w	BbX(a1),d1
	move.w	BbY(a1),d2
	bsr	CXyS
	move.w	d1,d0
	move.w	d2,d1
	move.w	BbI(a1),d2
	bsr	ColRout
	movem.l	(sp)+,d0/d2/d3/a1
	bne.s	SbColN
	and.w	#$00FF,d0
	move.w	d0,d1
	lsr.w	#3,d0
	and.w	#$7,d1
	bset	d1,0(a5,d0.w)
	bset	#31,d7
SbColN:	move.l	BbNext(a1),d0
	bne.s	SbCol1
	bra	BbColX

***********************************************************
*	=COLL(n) ramene la collision d'un bob/sprite
GetCol:	lea	T_TColl(a5),a0
	tst.l	d1
	bmi.s	GetC2
	and.w	#$FF,d1
	move.w	d1,d0
	lsr.w	#3,d0
	and.w	#$7,d1
	btst	d1,0(a0,d0.w)
	bne.s	GetC1
GetC0:	moveq	#0,d0
	rts
GetC1:	moveq	#-1,d0
	rts
* Ramene le premier en collision
GetC2:	neg.l	d1
	cmp.l	#255,d1
	bcc.s	GetC0
	move.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0
	move.l	d1,d0
	and.w	#7,d1
.loop	btst	d1,(a0)
	bne.s	.found
	addq.w	#1,d0
	addq.w	#1,d1
	cmp.w	#8,d1
	bcs.s	.loop
	moveq	#0,d1
	addq.l	#1,a0
	cmp.w	#256,d0
	bcs.s	.loop
	bra.s	GetC0
.found	rts

***********************************************************
*	HOT SPOT!
*	A2= descripteur
*	D1= Mode
*	D2= Dx
*	D3= Dy
SpotH:	move.l	(a2),d0
	beq.s	SpoE
	move.l	d0,a1
	tst.w	d1
	beq.s	Spo4
******* Mode FIXE!
	move.w	(a1),d2
	lsl.w	#4,d2
	move.w	2(a1),d3
	subq.w	#1,d1
* En X
	move.w	d1,d0
	lsr.w	#4,d0
	and.w	#3,d0
	subq.w	#1,d0
	bhi.s	Spo2
	beq.s	Spo1
	moveq	#0,d2
Spo1:	lsr.w	#1,d2
* En Y
Spo2:	and.w	#3,d1
	subq.w	#1,d1
	bhi.s	Spo4
	beq.s	Spo3
	moveq	#0,d3
Spo3:	lsr.w	#1,d3
* Poke, en respectant les FLAGS!
Spo4:	and.w	#$C000,6(a1)
	and.w	#$3FFF,d2
	or.w	d2,6(a1)
	move.w	d3,8(a1)
	moveq	#0,d0
	rts
SpoE:	moveq	#-1,d0
	rts

***********************************************************
*	GET BOB/BLOC
*	A1= Ecran
*	A2= descripteur
*	D2/D3= X1/Y1
*	D4/D5= TX/TY
*	D6=    X2
GetBob:	movem.l	d1-d7/a0-a6,-(sp)
	move.l	a1,a5
* Masque droite
	move.w	d4,d6
	and.w	#$000F,d6
	lsl.w	#1,d6
	move.w	d6,a4
* Taille en octets!
	move.w	EcNPlan(a5),d7
	add.w	#15,d4
	lsr.w	#4,d4
	move.w	d4,d6
	lsl.w	#1,d6
	move.w	d6,d1
	mulu	d5,d1
	mulu	d7,d1
******* Efface l'ancien???
	move.l	(a2),d0
	beq.s	GtBb1
	move.l	d0,a1			* Efface le bob
	move.w	(a1),d0
	lsl.w	#1,d0
	mulu	2(a1),d0
	mulu	4(a1),d0
	cmp.l	d0,d1
	beq.s	GtBb1
	add.l	#10,d0
	bsr	FreeMm
	clr.l	(a2)
GtBb1:	move.l	4(a2),d0
	ble.s	GtBb2
	move.l	d0,a1
	move.l	(a1),d0
	bsr	FreeMm
GtBb2	clr.l	4(a2)
******* Reserve le mouveau
	tst.l	(a2)
	bne.s	GtBb3
	move.l	d1,d0
	add.l	#10,d0
	bsr	ChipMm2
	beq	GtBbE
	move.l	d0,(a2)
******* Ca y est!
GtBb3:	move.l	(a2),a2
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	move.w	d7,(a2)+
	clr.w	(a2)+
	clr.w	(a2)+
******* GETTE!
	lea	Circuits,a6
	bsr	OwnBlit
	subq.w	#1,d7
	move.w	d2,d0
	and.w	#$000F,d0
	bne.s	GtBc

******* Au mot!
	moveq	#-1,d1
	move.w	d1,BltMaskG(a6)
	move.w	a4,d0
	beq.s	GtBbM
	lea	MCls(pc),a0
	move.w	0(a0,d0.w),d1
	not.w	d1
GtBbM:	move.w	d1,BltMaskD(a6)
	move.w	EcTLigne(a5),d1
	mulu	d1,d3
	lsr.w	#4,d2
	lsl.w	#1,d2
	ext.l	d2
	add.l	d2,d3
	lea	EcCurrent(a5),a1
	sub.w	d6,d1
	move.w	d1,BltModA(a6)
	move.l	a2,BltAdD(a6)
	clr.w	BltModD(a6)
	lsl.w	#6,d5
	or.w	d5,d4
	move.w	#%0000100111110000,BltCon0(a6)
	clr.w	BltCon1(a6)
GtBb5:	move.l	(a1)+,a0
	add.l	d3,a0
	move.l	a0,BltAdA(a6)
	move.w	d4,BltSize(a6)
GtBb6:	bsr	BlitWait
	dbra	d7,GtBB5
	bra	GtBbX

******* Au pixel!
GtBc:	move.w	#%0000010111001100,BltCon0(a6)
	moveq	#16,d1
	sub.w	d0,d1
	moveq	#12,d0
	lsl.w	d0,d1
	move.w	d1,BltCon1(a6)
	move.w	EcTligne(a5),d1
	ext.l	d1
	mulu	d1,d3
	lsr.w	#4,d2
	lsl.w	#1,d2
	ext.l	d2
	add.l	d2,d3
	lea	EcCurrent(a5),a1
	subq.l	#2,a2
	addq.w	#1,d4
	or.w	#%0000000001000000,d4
	subq.w	#1,d5
	ext.l	d6
	move.w	a4,d2
	lea	MCls(pc),a0
	move.w	0(a0,d2.w),d2
	bmi.s	GtBc1
	not.w	d2
GtBc1:	move.l	(a1)+,a0
	add.l	d3,a0
	move.w	d5,d0
GtBc2:	move.l	a0,BltAdB(a6)
	move.w	(a2),a4
	move.l	a2,BltAdD(a6)
	move.w	d4,BltSize(a6)
	move.l	a2,a5
	add.l	d1,a0
	add.l	d6,a2
GtBc3:	bsr	BlitWait
	move.w	a4,(a5)
	and.w	d2,(a2)
	dbra	d0,GtBc2
	dbra	d7,GtBc1

******* FINI! Pas d'erreur
GtBbX:	bsr	DOwnBlit
	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	rts
******* Out of mem
GtBbE:	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#-1,d0
	rts

***********************************************************
*	INITIALISATION BOBS / D0= Nombre de bobs!
BbInit:
********
	clr.l	T_BbDeb(a5)
* Efface ce qui etait reserve
	move.w	d0,-(sp)
	bsr	BbEnd
	move.w	(sp)+,d1
* Reserve la memoire pour les tables priorites
	move.w	d1,T_BbMax(a5)
	ext.l	d1
	lsl.w	#2,d1
	move.l	d1,d0
	bsr	FastMm
	beq	GFatal
	move.l	d0,T_BbPrio(a5)
	move.l	d1,d0
	bsr	FastMm
	beq	GFatal
	move.l	d0,T_BbPrio2(a5)
	moveq	#0,d0
	rts

***********************************************************
*	FIN DES BOBS
BbEnd:
*******
	move.w	T_BbMax(a5),d1
	ext.l	d1
	lsl.l	#2,d1
	move.l	T_BbPrio(a5),d0
	beq.s	BOBE1
	move.l	d0,a1
	move.l	d1,d0
	bsr	FreeMm
BOBE1:	move.l	T_BbPrio2(a5),d0
	beq.s	BOBE2
	move.l	d0,a1
	move.l	d1,d0
	bsr	FreeMm
BOBE2:	moveq	#0,d0
	rts

***********************************************************
*	BOB X/Y
BobXY:	bsr	BobAd
	bne.s	BobxyE
	move.w	BbX(a1),d1
	move.w	BbY(a1),d2
	move.w	BbI(a1),d3
	moveq	#0,d0
BobxyE:	rts

***********************************************************
*	PATCH BOB / ICON
*	Dessine simplement un bob/icon
*	A1-	Buffer de calcul
*	A2-	Descripteur bob/icon
*	D1-	Image retournee???
*	D2/D3-	Coordonnees
*	D4-	Minterms (0 si rien)
*	D5-	APlan
TPatch
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	a1,a4
* Va retourner le bob
	move.l	a2,a0
	move.w	d1,d0
	and.w	#$C000,d0
	bsr	Retourne
* Parametres de l'ecran courant
	move.l	T_EcCourant(a5),a0	* Calculssss
	move.w	EcClipX0(a0),d0
	and.w	#$FFF0,d0
	move.w	d0,BbLimG(a4)
	move.w	EcClipY0(a0),BbLimH(a4)
	move.w	EcClipX1(a0),d0
	add.w	#15,d0
	and.w	#$FFF0,d0
	move.w	d0,BbLimD(a4)
	move.w	EcClipY1(a0),BbLimB(a4)
	tst.w	d4
	beq.s	Patch1
	and.w	#$00FF,d4
	bset	#15,d4
Patch1	move.w	d4,BbACon(a4)
	move.w	d5,BbAPlan(a4)
	move.l	a0,BbEc(a4)
	exg.l	d3,d1
	bset	#31,d3			* Flag PAS POINT CHAUD!
	bsr	BobCalc
	bne.s	PatchO
* Gestion de l'autoback
	move.l	T_EcCourant(a5),a0
	tst.w	EcAuto(a0)
	beq.s	Patch2
	bsr	TAbk1
	bsr	PBobA
	bsr	TAbk2
	bsr	PBobA
	bsr	TAbk3
	bra.s	PatchO
Patch2	bsr	PBobA
* Fini!
PatchO	moveq	#0,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
* Appelle la routine d'affichage
PBobA	lea	Circuits,a6
	bsr	OwnBlit
	move.w	BbASize(a4),d2
	move.w	BbTPlan(a4),d4
	ext.l	d4
	move.l	BbAData(a4),a0
	move.l	BbEc(a4),a3
	lea	EcCurrent(a3),a3
	move.w	BbAModD(a4),d0
	move.w	d0,BltModC(a6)
	move.w	d0,BltModD(a6)
	move.l	BbADraw(a4),a2
	move.l	BbAMask(a4),d5
	jsr	(a2)
	bsr	BlitWait
	bra	DOwnBlit

***********************************************************
*	CREATION / CHANGEMENT D'UN BOB
*	D1= Numero du CANAL
*	D2= X
*	D3= Y
*	D4= Image
*	D5= MODE DECOR
*	D6= Plans affiches
*	D7= Minterms
BobSet:
********
	cmp.w	T_BbMax(a5),d1
	bcc	CreBbS

******* Ecris sur l'ancienne - SI PRESENT -
	move.l	a1,a0
	move.l	T_BbDeb(a5),d0
	beq.s	CreBb1
CreBb0:	move.l	d0,a1
	cmp.w	BbNb(a1),d1
	beq.s	CreBb5
	bcs.s	CreBb2
	move.l	BbNext(a1),d0
	bne.s	CreBb0
* Met a la fin!
	bsr	ResBOB
	bne	CreBbE
	move.l	a1,BbPrev(a0)
	move.l	a0,BbNext(a1)
	move.l	a0,a1
	bra.s	CreBb5
* Au tout debut
CreBb1:	bsr	ResBOB
	bne	CreBbE
	move.l	a0,T_BbDeb(a5)
	move.l	a0,a1
	bra.s	CreBb5
* Insere la nouvelle
CreBb2:	bsr	ResBOB
	bne	CreBbE
	move.l	BbPrev(a1),d0
	move.l	a0,BbPrev(a1)
	move.l	d0,BbPrev(a0)
	bne.s	CreBb3
	move.l	T_BbDeb(a5),d1
	move.l	a0,T_BbDeb(a5)
	bra.s	CreBb4
CreBb3:	move.l	d0,a2
	move.l	BbNext(a2),d1
	move.l	a0,BbNext(a2)
CreBb4:	move.l	d1,BbNext(a0)
	move.l	a0,a1
* Poke les coordonnees
CreBb5:	move.l	#EntNul,d7
	move.b	BbAct(a1),d6
	bmi.s	CreBb9
	cmp.l	d7,d2
	beq.s	CreBb6
	move.w	d2,BbX(a1)
	bset	#1,d6
CreBb6:	cmp.l	d7,d3
	beq.s	CreBb7
	move.w	d3,BbY(a1)
	bset	#2,d6
CreBb7:	cmp.l	d7,d4
	beq.s	CreBb8
	move.w	d4,BbI(a1)
	bset	#0,d6
CreBb8:	move.b	d6,BbAct(a1)
* Doit actualiser les bob
CreBb9:	bset	#BitBobs,T_Actualise(a5)
	moveq	#0,d0
	rts
******* Erreur!
CreBbS:	moveq	#1,d0
CreBbE:	tst.w	d0
	rts

******* CREATION DE LA TABLE!
ResBOB:	move.l	#BbLong,d0
	bsr	FastMm
	beq.s	ResBErr
	move.l	d0,a0
	move.w	d1,BbNb(a0)
	move.l	T_EcCourant(a5),a2
	move.l	a2,BbEc(a0)
	move.w	EcTx(a2),BbLimD(a0)
	move.w	EcTy(a2),BbLimB(a0)
	move.w	d6,BbAPlan(a0)
	and.w	#$00FF,d7
	beq.s	ResBb0
	bset	#15,d7
ResBb0	move.w	d7,BbACon(a0)
	move.w	#$01,BbDecor(a0)
	btst	#BitDble,EcFlags(a2)
	beq.s	ResBb1
	addq.w	#1,BbDecor(a0)
	move.w	#Decor,BbDCur2(a0)
ResBb1:	tst.w	d5
	bpl.s	ResBb2
	clr.w	BbDecor(a0)
ResBb2:	move.w	d5,BbEff(a0)
	moveq	#0,d0
	rts
* Erreur memoire!
ResBErr	moveq	#-1,d0
	rts

***********************************************************
*	BOB OFF d1=#
BobOff:
*******
	move.l	T_BbDeb(a5),d0
	beq.s	DBb2
DBb1:	move.l	d0,a1
	cmp.w	BbNb(a1),d1
	beq.s	DBb3
	bcs.s	DBb2
	move.l	BbNext(a1),d0
	bne.s	DBb1
DBb2:	moveq	#1,d0
	rts
DBb3:	move.b	#-1,BbAct(a1)
	bset	#BitBobs,T_Actualise(a5)
	moveq	#0,d0
	rts
***********************************************************
*	ARRET TOUS LES BOBS
BobSOff:
*******
	movem.l	d0/a1/a2,-(sp)
	move.l	T_BbDeb(a5),d0
	beq.s	DBbs2
DBbs1:	move.l	d0,a1
	move.b	#-1,BbAct(a1)
	move.l	BbNext(a1),d0
	bne.s	DBbs1
DBbs2:	bset	#BitBobs,T_Actualise(a5)
	movem.l	(sp)+,d0/a1/a2
	moveq	#0,d0
	rts

***********************************************************
*	LIMIT BOB tous, Ecran courant!
*	D1= # ou -1, D2/D3->D4/D5
BobLim:
*******
	movem.l	d2-d7,-(sp)
	move.l	T_BbDeb(a5),d0
	beq	LBbX
* Verifie les coordonnees
	move.l	T_EcCourant(a5),d6
	move.l	d6,a0
	move.l	#EntNul,d7
	cmp.w	d7,d2
	bne.s	LBba
	clr.w	d2
LBba:	cmp.w	d7,d3
	bne.s	LBbb
	clr.w	d3
LBbb:	cmp.w	d7,d4
	bne.s	LBbc
	move.w	EcTx(a0),d4
LBbc:	cmp.w	d7,d5
	bne.s	LBbd
	move.w	EcTy(a0),d5
LBbd:	and.w	#$FFF0,d2
	and.w	#$FFF0,d4
	cmp.w	d2,d4
	bls.s	LbbE
	cmp.w	d2,d5
	bls.s	LbbE
	cmp.w	EcTx(a0),d4
	bhi.s	LbbE
	cmp.w	EcTy(a0),d5
	bhi.s	LbbE
* Change les bobs!
LBb1:	move.l	d0,a1
	tst.w	BbAct(a1)
	bmi.s	LBb3
	cmp.l	BbEc(a1),d6
	bne.s	LBb3
	tst.w	d1
	bmi.s	LBb2
	cmp.w	BbNb(a1),d1
	bhi.s	LBb3
	bcs.s	LBbX
LBb2:	move.w	d2,BbLimG(a1)
	move.w	d3,BbLimH(a1)
	move.w	d4,BbLimD(a1)
	move.w	d5,BbLimB(a1)
	bset	#0,BbAct(a1)			***Bug?
	bset	#BitBobs,T_Actualise(a5)
LBb3:	move.l	BbNext(a1),d0
	bne.s	LBb1
LBbX:	moveq	#0,d0
LBbXx	movem.l	(sp)+,d2-d7
	rts
LBbE:	moveq	#-1,d0
	bra.s	LBbXx

***********************************************************
*	PRIORITY ON/OFF
*	D1= on/off - Ecran courant (-1 indet)
*	D2= normal - reversed      (-1 indet)
TPrio	tst.l	d1
	bmi.s	TPri2
	beq.s	TPri1
	move.l	T_EcCourant(a5),d1
TPri1	move.l	d1,T_Priorite(a5)
TPri2	tst.l	d2
	bmi.s	TPri3
	move.w	d2,T_PriRev(a5)
TPri3	moveq	#0,d0
	rts

***********************************************************
*	ENLEVE LES BOBS D'UN ECRAN!
*	A0= Ecran
BbEcOff:
********
	movem.l	d1-d7/a0/a1,-(sp)
	move.l	a0,d7
	move.l	T_BbDeb(a5),d0
	beq.s	BbEO2
BbEO1:	move.l	d0,a1
	cmp.l	BbEc(a1),d7
	beq.s	BbEO3
	move.l	BbNext(a1),d0
	bne.s	BbEO1
BbEO2:	movem.l	(sp)+,d1-d7/a0/a1
	moveq	#0,d0
	rts
******* Enleve le bob!
BbEO3:	move.l	BbNext(a1),d0
	bsr	DelBob
* Encore?
	tst.l	d0
	bne.s	BbEO1
	bra.s	BbEO2

******* Efface la definition du bob (A1)
DelBob:	movem.l	d0-d7/a0-a2,-(sp)
	move.l	a1,a2

* Enleve les buffers de decor, s'il y en a!
	moveq	#0,d0
	move.w	BbDLBuf(a2),d0
	beq.s	DBo1
	lsl.l	#1,d0
	move.l	BbDABuf(a2),a1
	bsr	FreeMm
DBo1:	moveq	#0,d0
	move.w	BbDLBuf+Decor(a2),d0
	beq.s	DBo2
	lsl.l	#1,d0
	move.l	BbDABuf+Decor(a2),a1
	bsr	FreeMm
* Enleve le canal d'animation
DBo2:	lea	BbAct(a2),a0
	bsr	DAdAMAL
* Enleve le bob
	move.l	BbNext(a2),d3
	move.l	BbPrev(a2),d2
	beq.s	DBo3
	move.l	d2,a0
	move.l	d3,BbNext(a0)
	bra.s	DBo4
DBo3:	move.l	d3,T_BbDeb(a5)
DBo4:	tst.l	d3
	beq.s	DBo5
	move.l	d3,a0
	move.l	d2,BbPrev(a0)
DBo5:	move.l	a2,a1
	move.l	#BbLong,d0
	bsr	FreeMm

	movem.l	(sp)+,d0-d7/a0-a2
	rts

***********************************************************
*	ADRESSE D'UN BOB: D1= Numero!
BobAd:
*******
	move.l	T_BbDeb(a5),d0
	beq.s	AdBb1
AdBb0:	move.l	d0,a1
	cmp.w	BbNb(a1),d1
	beq.s	AdBb2
	bcs.s	AdBb1
	move.l	BbNext(a1),d0
	bne.s	AdBb0
AdBb1	moveq	#1,d0
AdBb2	rts

***********************************************************
*	PUT BOB n
BobPut:	bsr	BobAd
	bne.s	BbPx
	move.w	BbDecor(a1),BbECpt(a1)
	moveq	#0,d0
BbPx:	rts

***********************************************************
*	ACTUALISATION DES BOBS
*******
BobAct:	movem.l	d2-d7/a2-a6,-(sp)
	move.l	T_BbPrio(a5),a3
* Banque de sprites chargee?
	move.l	T_SprBank(a5),d0
	beq	BbSx
	move.l	d0,a6
******* Explore les bobs!
	move.l	T_BbDeb(a5),d0
	beq	BbSx
	clr.w	-(sp)
	move.l	T_Priorite(a5),-(sp)
	move.l	T_BbPrio2(a5),a5
BbS0:	move.l	d0,a4
* Flippe les decors!
	move.w	BbDCur2(a4),d4
	move.w	BbDCur1(a4),BbDCur2(a4)
	move.w	d4,BbDCur1(a4)
* Bob modifie?
	tst.w	BbECpt(a4)		* Si PUT BOB---> Pas d'act!
	bne.s	BbSDec
	tst.b	BbAct(a4)
	beq	BbSDec
	bmi	BbDel
	clr.b	BbAct(a4)
	move.w	BbI(a4),d2		* Pointe l'image
	moveq	#0,d3
	move.w	d2,d3
	and.w	#$C000,d3
	move.w	d3,BbRetour(a4)
	and.w	#$3FFF,d2
	beq	BbSort
	cmp.w	(a6),d2
	bhi	BbSort
	lsl.w	#3,d2
	lea	-8+2(a6,d2.w),a2
	tst.l	(a2)
	beq	BbSort
	move.l	a2,BbARetour(a4)
	move.w	BbX(a4),d2		* Coordonnees
	move.w	BbY(a4),d1
	move.l	BbEc(a4),a0		* Ecran
	bsr	BobCalc
	bne	BbSort

******* Sauvegarde du decor!
BbSDec:	move.w	BbDecor(a4),d0
	beq	BbSN
	move.w	BbESize(a4),d1
	beq	BbSort
* Stocke les parametres
	move.w	d0,BbDCpt(a4)
	move.w	BbDCur1(a4),d0
	lea	0(a4,d0.w),a2
	move.w	d1,BbDASize(a2)
	move.w	BbEMod(a4),BbDMod(a2)
	move.w	BbAPlan(a4),BbDAPlan(a2)
	move.w	BbEAEc(a4),BbDAEc(a2)
	move.w	BbNPlan(a4),d1
	move.w	d1,BbDNPlan(a2)
	tst.w	BbEff(a4)		* Effacement en couleurs?
	bne.s	BbSN
	addq.w	#1,d1
	mulu	BbETPlan(a4),d1		* Taille du buffer
	moveq	#0,d0
	move.w	BbDLBuf(a2),d0
	beq.s	BbD4
	lsl.l	#1,d0
	cmp.l	d0,d1			* Taille suffisante?
	bls.s	BbD5
* Efface l'ancien buffer?
	move.l	BbDABuf(a2),a1
	bsr	FreeMm
	clr.l	BbDABuf(a2)
	clr.w	BbDLbuf(a2)
* Reserve le nouveau!
BbD4:	move.l	d1,d0
	bsr	ChipMm
	beq.s	BbD5
	move.l	d0,BbDABuf(a2)
	lsr.l	#1,d1
	move.w	d1,BbDLBuf(a2)
* Ok!
BbD5:	bra	BbSN

******* BOB ARRETE
BbDel:	subq.w	#1,BbDecor(a4)		* Compte le nombre de REDRAW
	bhi.s	BbSort
* Efface!
	move.l	BbNext(a4),d0
	move.l	a4,a1
	move.l	a5,-(sp)
	move.l	W_Base(pc),a5
	bsr	DelBob
	move.l	(sp)+,a5
	tst.l	d0
	bne	BbS0
	bra.s	BbBug

******* Calcul des priorites
BbSN:	move.l	BbEc(a4),d0
	cmp.l	(sp),d0
	bne.s	BbPrX
* Priorite!
	move.l	a4,(a5)+
	addq.w	#1,4(sp)
	bra.s	BbSort
* Pas de priorite
BbPrX	move.l	a4,(a3)+
******* En dehors!
BbSort:	move.l	BbNext(a4),d0
	bne	BbS0
BbBug
******* Classe les bobs...
	move.l	W_Base(pc),a5
	addq.l	#4,sp
	move.w	(sp)+,d6
	beq.s	BbSx
	subq.w	#1,d6
* Recopie dans la liste
	move.l	a3,a4
	move.l	T_BbPrio2(a5),a0
	move.w	d6,d0
BbPr1	move.l	(a0)+,(a3)+
	dbra	d0,BbPr1
	subq.w	#1,d6
	bmi.s	BbSx
* Classe (a bulle!)
BbPr2	moveq	#0,d1
	move.w	d6,d2
	move.l	a4,a2
	move.l	(a2)+,a0
BbPr3	move.l	(a2)+,a1
	move.w	BbY(a0),d0		* Compare
	cmp.w	BbY(a1),d0
	blt.s	BbPr5
	bne.s	BbPr4
	move.w	BbX(a0),d0
	cmp.w	BbX(a1),d0
	ble.s	BbPr5
BbPr4	exg	a0,a1
	move.l	a0,-8(a2)
	move.l	a1,-4(a2)
	addq.w	#1,d1
BbPr5	move.l	a1,a0
	dbra	d2,BbPr3
	tst.w	d1
	bne.s	BbPr2
* Renverser la table???
BbSx:	clr.l	(a3)
	tst.w	T_PriRev(a5)
	beq.s	BbSxX
* Renverse la table!!!
	move.l	T_BbPrio(a5),a0
	cmp.l	a3,a0
	bcc.s	BbSxX
BbSRv	move.l	(a0),d0
	move.l	-(a3),(a0)+
	move.l	d0,(a3)
	cmp.l	a3,a0
	bcs.s	BbSRv
* Fini!
BbSxX	movem.l	(sp)+,d2-d7/a2-a6
	rts

******* ROUTINE DE CALCUL DES PARAMS AFFICHAGE BOB/BLOC
*	A0-> 	Ecran
*	A2-> 	Descripteur image
*	A4-> 	Buffer calcul
*	D2-> 	X
*	D1->	Y
* 	D3-> 	Flags retournement
BobCalc	move.l	(a2),a1
	tst.l	4(a2)
	bne.s	BbS1
* Va calculer le masque!
	bsr	Masque
	bne	BbSOut
* Point chaud retourne?
BbS1:	tst.l	d3
	bmi.s	BbHt3
	move.w	6(a1),d0
	move.w	d0,d4
	lsl.w	#2,d4
	asr.w	#2,d4
	move.w	8(a1),d5
	eor.w	d0,d3
* En Y?
	btst	#14,d3
	beq.s	BbHt1
	neg.w	d5
	add.w	2(a1),d5
* En X?
BbHt1	btst	#15,d3
	beq.s	BbHt2
	move.w	(a1),d0
	lsl.w	#4,d0
	sub.w	d4,d0
	move.w	d0,d4
BbHt2	sub.w	d5,d1
	sub.w	d4,d2
* Nombre de plans
BbHt3	move.w	4(a1),d0
	cmp.w	EcNPlan(a0),d0
	bls.s	BbS1a
	move.w	EcNPlan(a0),d0
BbS1a:	subq.w	#1,d0
	move.w	d0,BbNPlan(a4)
	clr.w	BbESize(a4)
* Mots de controle?
	tst.w	BbACon(a4)
	beq.s	BbS1b
	bpl.s	BbS1d
	move.w	BbACon(a4),d0		* MASQUER le minterm
	bclr	#15,d0
	or.w	#%0000111100000000,d0
	tst.l	4(a2)
	bpl.s	BbS1c
	and.w	#%0000011111111111,d0
	bra.s	BbS1c
BbS1b	move.w	#%0000111111001010,d0	* FAIRE le minterm
	tst.l	4(a2)
	bpl.s	BbS1c
	move.w	#%0000011111001010,d0
BbS1c	move.w	d0,BbACon(a4)
BbS1d	move.w	d2,d0
	and.w	#$F,d2
	beq	BbND

******* DECALES!
	lsl.w	#8,d2			* Registres de controle
	lsl.w	#4,d2
	move.w	d2,BbACon1(a4)
	or.w	BbACon(a4),d2
	move.w	d2,BbACon0(a4)

	move.w	(a1),d4			* Taille en X
	lsl.w	#1,d4
	move.w	d4,d3
	move.w	2(a1),d5		* Taille en Y
	move.w	d4,d2
	mulu	d5,d2
	move.w	d2,BbTPLan(a4)		* Taille plan!
	add.w	d5,d2
	add.w	d5,d2
	move.w	d2,BbETPlan(a4)		* Effacement: prend les bords!

	move.w	d5,d2
	add.w	d1,d2
	cmp.w	BbLimB(a4),d2		* Limite en BAS!
	ble	BbDe2
	sub.w	BbLimB(a4),d2
	sub.w	d2,d5
	bls	BbSOut
BbDe2:
	moveq	#0,d7
	cmp.w	BbLimH(a4),d1		* Teste la limite en HAUT!
	bge.s	BbDe1
	sub.w	BbLimH(a4),d1
	neg.w	d1
	sub.w	d1,d5
	bls	BbSOut
	move.w	d1,d7
	mulu	d4,d7
	move.w	BbLimH(a4),d1
BbDe1:
	move.w	EcTLigne(a0),d2
	move.w	d2,d6
	mulu	d1,d6

	lsl.w	#3,d4
	move.w	d4,d1
	add.w	d0,d1
	clr.w	BbAMaskD(a4)
	cmp.w	BbLimD(a4),d1		* Teste la limite a DROITE
	ble.s	BbDe4
	sub.w	BbLimD(a4),d1
	and.w	#$FFF0,d1
	add.w	#16,d1
	sub.w	d1,d4
	bmi	BbSOut
	move.w	d0,d1
	and.w	#$000F,d1
	lsl.w	#1,d1
	lea	MCls2(pc),a0
	move.w	0(a0,d1.w),d1
	not.w	d1
	move.w	d1,BbAMaskD(a4)
BbDe4:
	moveq	#-1,d1
	cmp.w	BbLimG(a4),d0		* Teste la limite a GAUCHE
	bge.s	BbDe3
	move.w	d0,d1
	sub.w	BbLimG(a4),d0
	neg.w	d0
	sub.w	d0,d4
	bls	BbSOut
	add.w	#16,d4
	lsr.w	#4,d0
	lsl.w	#1,d0
	add.w	d0,d7
	bset	#31,d7
	subq.l	#2,d6
	lea	MCls2(pc),a0		* Masque a gauche
	and.w	#$000F,d1
	lsl.w	#1,d1
	move.w	0(a0,d1.w),d1
	move.w	BbLimG(a4),d0
BbDe3:	move.w	d1,BbAMaskG(a4)
	add.w	#16,d4

	lsr.w	#4,d0			* Adresse ecran
	lsl.w	#1,d0
	ext.l	d0			BUG !
	add.l	d0,d6
	lsr.l	#1,d6
	move.w	d6,BbAAEc(a4)

	lsr.w	#4,d4			* Modulo ecran
	move.w	d4,d0
	lsl.w	#1,d4
	sub.w	d4,d3
	move.w	d3,BbAModO(a4)
	sub.w	d4,d2
	move.w	d2,BbAModD(a4)

	move.w	d0,d1
	lea	BbAP(pc),a0
	tst.l	d7
	bpl.s	BbDe5
	addq.w	#1,d6			Suite BUG !
	subq.w	#1,d1
	addq.w	#2,d2
	bne.s	BbDe5
	lea	BbAL(pc),a0
BbDe5:	lsl.w	#6,d5
	or.w	d5,d1
	move.w	d1,BbESize(a4)
	or.w	d5,d0
	move.w	d0,BbASize(a4)
	move.w	d2,BbEMod(a4)
	move.w	d6,BbEAEc(a4)
	move.l	a0,BbADraw(a4)

	move.l	4(a2),a2		* Adresses bob
	lea	4(a2,d7.w),a2
	move.l	a2,BbAMask(a4)
	lea	10(a1,d7.w),a2
	move.l	a2,BbAData(a4)

	moveq	#0,d0
	rts

* Sortie
BbSOut	moveq	#-1,d0
	rts

* NON DECALES: Teste limites en H G
BbND:	move.w	d0,d2
	move.w	d1,d3
	moveq	#0,d4
	moveq	#0,d5
	cmp.w	BbLimG(a4),d0
	bge.s	BbS2
	move.w	BbLimG(a4),d4
	sub.w	d0,d4
	lsr.w	#4,d4
	move.w	BbLimG(a4),d0
BbS2:	cmp.w	BbLimH(a4),d1
	bge.s	BbS3
	move.w	BbLimH(a4),d5
	sub.w	d1,d5
	move.w	BbLimH(a4),d1
BbS3:	lsr.w	#4,d0
	lsl.w	#1,d0
	ext.l	d0			BUG !
	mulu	EcTLigne(a0),d1
	add.l	d0,d1
	lsr.l	#1,d1
	move.w	d1,BbAAEc(a4)
	move.w	d1,BbEAEc(a4)
	move.w	(a1),d6
	move.w	2(a1),d7
	move.w	d6,d0
	lsl.w	#1,d0
	move.w	d0,d1
	mulu	d7,d1
	move.w	d1,BbTPlan(a4)
	move.w	d1,BbETPlan(a4)
	mulu	d5,d0
	add.w	d4,d0
	add.w	d4,d0
	move.l	4(a2),a2
	lea	4(a2,d0.w),a2
	move.l	a2,BbAMask(a4)
	lea	10(a1,d0.w),a2
	move.l	a2,BbAData(a4)

	move.w	BbACon(a4),BbACon0(a4)
	clr.w	BbACon1(a4)
	move.w	d6,d0
	lsl.w	#4,d0
	add.w	d0,d2
	add.w	d7,d3
	move.w	d6,d0
	move.w	d7,d1
	cmp.w	BbLimD(a4),d2
	ble.s	BbS4
	sub.w	BbLimD(a4),d2
	lsr.w	#4,d2
	sub.w	d2,d0
BbS4:	cmp.w	BbLimB(a4),d3
	ble.s	BbS5
	sub.w	BbLimB(a4),d3
	sub.w	d3,d1
BbS5:	sub.w	d4,d0
	ble	BbSOut
	sub.w	d5,d1
	ble	BbSout
	sub.w	d0,d6
	lsl.w	#1,d6
	move.w	d6,BbAModO(a4)
	move.w	EcTLigne(a0),d6
	sub.w	d0,d6
	sub.w	d0,d6
	move.w	d6,BbAModD(a4)
	move.w	d6,BbEMod(a4)
	lsl.w	#6,d1
	or.w	d1,d0
 	move.w	d0,BbASize(a4)
	move.w	d0,BbESize(a4)
	lea	BbA16(pc),a0
	move.l	a0,BbADraw(a4)
	moveq	#0,d0
	rts

***********************************************************
*	RETOURNEUR DE SPRITES!

******* Initialisation: fabrique la table
RbInit	lea	TRetour(pc),a0
        moveq 	#0,d0
IRet1:  moveq 	#7,d3
        move.b 	d0,d1
IRet2:  lsr.b 	#1,d1
        roxl.b 	#1,d2
        dbra 	d3,IRet2
        move.b 	d2,(a0)+
        addq.b 	#1,d0
        bne.s 	IRet1
	rts
******* Fin, libere la memoire
RbEnd	rts

******* Entree trappe
*	A1/D0
RevTrap	move.l	a1,a0
	move.l	d1,d0
******* Retourne un sprite, s'il faut.
*	A0---> Descripteur
*	D0---> Flags seuls
Retourne
	move.l	(a0),d1
	beq.s	RetBobX
	move.l	d1,a1
	move.w	6(a1),d1
	and.w	#$C000,d1
	eor.w	d0,d1
	beq.s	RetBobX
* En X?
	btst	#15,d1
	beq.s	RetBb1
	bsr	RBobX
* En Y?
RetBb1	btst	#14,d1
	beq.s	RetBb2
	bsr	RBobY
* Poke les flags
RetBb2	move.w	6(a1),d1
	and.w	#$3FFF,d1
	or.w	d0,d1
	move.w	d1,6(a1)
* Ca y est!
RetBobX	rts

******* Retourne le bob en X
RBobX	movem.l a0-a3/d0-d7,-(sp)
* Retourne le point chaud
	move.w	6(a1),d0
	lsl.w	#2,d0
	asr.w	#2,d0
	move.w	(a1),d6
	move.w	d6,d1
	lsl.w	#4,d1
	sub.w	d0,d1
	move.w	d1,6(a1)
* Retourne le dessin
	moveq	#0,d0
	moveq	#0,d1
	lea	TRetour(pc),a3
	move.w	2(a1),d7
	move.w	4(a1),d3
	lea	10(a1),a1
	move.l	a0,-(sp)
	bsr	RBbX
	move.l	(sp)+,a0
* Retourne le masque
	move.l	4(a0),d2
	ble.s	RBobXx
	move.l	d2,a1
	addq.l	#4,a1
	moveq	#0,d3
	bsr	RBBis
* Fini
RBobXx	movem.l (sp)+,a0-a3/d0-d7
	rts
******* Retourne le bob en Y
RBobY	movem.l a0-a2/d0-d7,-(sp)
* Retourne le point chaud
	move.w	2(a1),d7
	move.w	d7,d0
	sub.w	8(a1),d0
	move.w	d0,8(a1)
* Retourne le dessin
	move.w	(a1),d6
	move.w	4(a1),d5
	lea	10(a1),a1
	move.l	a0,-(sp)
	bsr	RBbY
	move.l	(sp)+,a0
* Retourne le masque
	move.l	4(a0),d0
	ble.s	RBobYx
	move.l	d0,a1
	addq.l	#4,a1
	moveq	#0,d5
	bsr	RBbY1
* Fini
RBobYx	movem.l (sp)+,a0-a2/d0-d7
	rts

************************
* Retourne en X
* A1-> Ad plan
* D7-> Ty
* D6-> Tx
* D3-> Nb plans
RBbX	subq.w	#1,d7		* Base cpt Y
	subq.w	#1,d3		* Cpt nombre de plans
	moveq	#0,d4
	move.w	d6,d4
	lsr.w	#1,d6
	subq.w	#1,d6
	move.w	d6,a2		* Base cpt en X
RBBis	btst	#0,d4
	bne.s	RBbI0
* Nombre PAIR de plans
RBbx0	move.w	d7,d5		* Cpt Y
RBbx1	add.l	d4,a1
	move.l	a1,a0
	move.w	a2,d6
RBbx2	move.b	-(a0),d0
	move.b 	(a1),d1
	move.b	0(a3,d1.w),(a0)
	move.b	0(a3,d0.w),(a1)+
	move.b 	-(a0),d0
	move.b	(a1),d1
	move.b	0(a3,d1.w),(a0)
	move.b	0(a3,d0.w),(a1)+
	dbra	d6,RBbx2
	dbra	d5,RBbX1
	dbra	d3,RBbX0
	rts
* Nombre IMPAIR de plans
RBbI0	move.w	d7,d5		* Cpt Y
RBbI1	add.l	d4,a1
	move.l	a1,a0
	move.b	-(a0),d0
	move.b 	(a1),d1
	move.b	0(a3,d1.w),(a0)
	move.b	0(a3,d0.w),(a1)+
	move.w	a2,d6
	bmi.s	RBbI3
RBbI2	move.b	-(a0),d0
	move.b 	(a1),d1
	move.b	0(a3,d1.w),(a0)
	move.b	0(a3,d0.w),(a1)+
	move.b 	-(a0),d0
	move.b	(a1),d1
	move.b	0(a3,d1.w),(a0)
	move.b	0(a3,d0.w),(a1)+
	dbra	d6,RBbI2
RBbI3	dbra	d5,RBbI1
	dbra	d3,RBbI0
	rts

************************
* Retournement VERTICAL
* D5= NPlan
* D6= TX
* D7= TY
RBbY   	move.w  d6,d4
        lsl.w   #1,d4
        ext.l   d4
        move.w  d7,d3
        lsr.w   #1,d3
        mulu    d4,d3
	move.l	d4,d2
        lsr.w   #1,d7
        bcc.s   RBbY0
	add.l	d4,d2
        add.l   d4,d3
RBbY0   neg.l	d2
	subq.w  #1,d7
        move.w  d7,a2
        subq.w  #1,d6
	subq.w	#1,d5
	lsl.w	#1,d4
* Boucle de retournement
RBbY1   add.w   d3,a1
        lea     0(a1,d2.w),a0
        move.w  a2,d7
RBbY2   move.w  d6,d1
RBbY3   move.w  (a1),d0
        move.w  (a0),(a1)+
        move.w  d0,(a0)+
        dbra    d1,RBbY3
        sub.l   d4,a0
        dbra    d7,RBbY2
        dbra    d5,RBbY1
        rts

***********************************************************
*	CALCUL DU MASQUE, 1 MOT BLANC A DROITE!
*	A2= descripteur
Masque:
*******
	movem.l	d1-d7/a0-a2,-(sp)
	move.l	(a2),a1
	move.w	(a1),d2
	lsl.w	#1,d2
	mulu	2(a1),d2		* D2= Taille plan
	move.l	d2,d3
	addq.l	#4,d3			* D3= Taille memoire
	move.w	4(a1),d4
	subq.w	#2,d4			* D4= Nb de plans
	move.w	d2,d5
	lsr.w	#1,d5
	subq.w	#1,d5
* Reserve la memoire pour le masque
	move.l	4(a2),d0
	bne.s	Mas0
MasM	move.l	d3,d0
	bsr	ChipMm2
	beq.s	MasErr
	move.l	d0,4(a2)
* Calcule le masque
Mas0:	bmi.s	MasM
	move.l	d0,a2			* Adresse du masque
	move.l	d3,(a2)+		* Taille du masque
	lea	10(a1),a1		* Pointe le premier plan
Mas2:	move.l	a1,a0
	move.w	(a0),d0
	move.w	d4,d3
	bmi.s	Mas4
Mas3:	add.l	d2,a0
	or.w	(a0),d0
	dbra	d3,Mas3
Mas4:	move.w	d0,(a2)+
	addq.l	#2,a1
	dbra	d5,Mas2
* Pas d'erreur
	movem.l	(sp)+,d1-d7/a0-a2
	moveq	#0,d0
	rts
* Erreur!
MasErr:	movem.l	(sp)+,d1-d7/a0-a2
	moveq	#-1,d0
	rts

********************************************************
*	EFFACEMENT DE TOUS LES BOBS DES ECRANS
********
BobEff:	movem.l	d2-d7/a2-a6,-(sp)
	lea	Circuits,a6
	move.l	T_BbDeb(a5),d0
	beq	BbExX

******* Initialise le blitter
	bsr	OwnBlit
	move.w	#0,BltModA(a6)
	move.w	#0,BltCon1(a6)
	moveq	#-1,d1
	move.w	d1,BltMaskG(a6)
	move.w	d1,BltMaskD(a6)

******* Explore la liste des bobs
BbE0:	move.l	d0,a5
	tst.w	BbECpt(a5)			* Compteur PUT BOB
	bne.s	BbE5
	move.l	BbEc(a5),a3
	lea	EcLogic(a3),a3
	move.w	BbDCur2(a5),d4
	lea	0(a5,d4.w),a4

	move.w	BbDASize(a4),d2			* D2= BltSize
	beq.s	BbE4
	move.w	BbDAEc(a4),d3			* D3= Decalage ecran
	ext.l	d3
	lsl.l	#1,d3
	move.w	BbEff(a5),d4
	bne.s	BbEFc

* Effacement NORMAL
	tst.l	BbDABuf(a4)
	beq.s	BbE4
	move.w	BbDAPlan(a4),d1
	move.w	BbDNPlan(a4),d0
	bsr	BlitWait
	move.w	BbDMod(a4),BltModD(a6)
	move.l	BbDABuf(a4),BltAdA(a6)		* Adresse buffer
	move.w	#%0000100111110000,BltCon0(a6)
BbE1:	lsr.w	#1,d1
	bcc.s	BbE3
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.l	a2,BltAdD(a6)
	move.w	d2,BltSize(a6)
BbE3:	addq.l	#4,a3
	dbra	d0,BbE1
* Un autre?
BbE4:	move.l	BbNext(a5),d0
	bne.s	BbE0
	bra.s	BbEx
BbE5:	subq.w	#1,BbECpt(a5)
	bne.s	BbE4
	bra.s	BbE4

* Effacement COLORE!
BbEfC:	subq.w	#1,d4
	move.w	BbDAPlan(a4),d1
	move.w	BbDNPlan(a4),d0
	bsr	BlitWait
	move.w	BbDMod(a4),BltModD(a6)
	move.w	#%0000000111110000,BltCon0(a6)
	moveq	#0,d5
BbEfc1:
	lsr.w	#1,d4
	subx.w	d5,d5
	lsr.w	#1,d1
	bcc.s	BbEfc4
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.w	d5,BltDatA(a6)
	move.l	a2,BltAdD(a6)
	move.w	d2,BltSize(a6)
BbEfc4:	addq.l	#4,a3
	moveq	#0,d5
	dbra	d0,BbEfc1
* Un autre?
	move.l	BbNext(a5),d0
	bne	BbE0

* FINI: remet le blitter
BbEx:	bsr	BlitWait
	bsr	DOwnBlit
BbExX:	movem.l	(sp)+,d2-d7/a2-a6
	rts

********************************************************
*	SAISIE  ET DESSIN DE TOUS LES BOBS
********
BobAff	movem.l	d2-d7/a2-a6,-(sp)
	lea	Circuits,a6
	bsr	OwnBlit

******* SAISIE
	move.l	T_BbDeb(a5),d0
	beq	BbGx
* Initialise le blitter
	move.w	#0,BltModD(a6)
	move.w	#%0000100111110000,BltCon0(a6)
	move.w	#0,BltCon1(a6)
	moveq	#-1,d1
	move.w	d1,BltMaskG(a6)
	move.w	d1,BltMaskD(a6)

* Explore les bobs
BbG0:	move.l	d0,a5
	tst.w	BbDCpt(a5)			* Nombre de saisies
	beq.s	BbG4
	tst.w	BbEff(a5)			* Decor colore?
	bne.s	BbG4

	move.l	BbEc(a5),a3			* Adresse ecran
	lea	EcLogic(a3),a3
	move.w	BbDCur1(a5),d4
	lea	0(a5,d4.w),a4
	tst.l	BbDABuf(a4)			* Adress buffer 0?
	beq.s	BbG4
	move.w	BbDASize(a4),d2			* D2= BltSize
	beq.s	BbG4
	subq.w	#1,BbDCpt(a5)			* Une saisie de moins

	move.w	BbDAEc(a4),d3			* D3= Decalage ecran
	ext.l	d3
	lsl.l	#1,d3
	move.w	BbDAPlan(a4),d1
	move.w	BbDNPlan(a4),d0

	bsr	BlitWait
	move.l	BbDABuf(a4),d7
	move.l	d7,BltAdD(a6)			* Adresse buffer
	move.w	BbDMod(a4),BltModA(a6)
BbG1:	lsr.w	#1,d1
	bcc.s	BbG3
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.l	a2,BltAdA(a6)
	move.w	d2,BltSize(a6)
BbG3:	addq.l	#4,a3
	dbra	d0,BbG1

* Un autre?
BbG4:	move.l	BbNext(a5),d0
	bne.s	BbG0
BbGx:

*******	AFFICHAGE
	move.l	W_Base(pc),a5
	move.l	T_BbPrio(a5),a5
* Explore tous les bobs
	move.l	(a5)+,d0
	beq	BbAx
* Valeurs communes au 16 et autre
BbA0:	move.l	d0,a4
	move.w	BbASize(a4),d2
	beq.s	BbAn
* Va retourner le bob???
	move.w	BbRetour(a4),d0
	move.l	BbARetour(a4),a0
	bsr	Retourne
* Va dessiner
	moveq	#0,d4
	move.w	BbTPlan(a4),d4
	move.l	BbAData(a4),a0
	move.l	BbEc(a4),a3
	lea	EcLogic(a3),a3
	move.w	BbAModD(a4),d0
	move.l	BbADraw(a4),a1
	bsr	BlitWait
	move.w	d0,BltModC(a6)
	move.w	d0,BltModD(a6)
	move.l	BbAMask(a4),d5
	jsr	(a1)
* Un autre?
BbAn:	move.l	(a5)+,d0
	bne	BbA0
******* FINI: remet le blitter
BbAx:	bsr	BlitWait
	bsr	DOwnBlit
	movem.l	(sp)+,d2-d7/a2-a6
	rts

******* ROUTINE DESSIN au pixel
BbAp:	bmi	BMAp
	move.w	BbACon0(a4),BltCon0(a6)
	move.w	BbACon1(a4),BltCon1(a6)
	move.w	BbAAEc(a4),d3
	ext.l	d3
	lsl.l	#1,d3
	move.w	BbAModO(a4),d0
	move.w	d0,BltModA(a6)
	move.w	d0,BltModB(a6)
	move.w	BbAMaskG(a4),BltMaskG(a6)
	move.w	BbAMaskD(a4),BltMaskD(a6)
	move.w	#0,BltDatA(a6)
	move.w	BbAPlan(a4),d1
	move.w	BbNPlan(a4),d0
BbAp1:	lsr.w	#1,d1
	bcc.s	BbAp4
BbAp2:
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.l	d5,BltAdA(a6)
	move.l	a0,BltAdB(a6)
	move.l	a2,BltAdC(a6)
	move.l	a2,BltAdD(a6)
	move.w	d2,BltSize(a6)
BbAp4:	add.l	d4,a0
	addq.l	#4,a3
	dbra	d0,BbAp1
	rts

******* ROUTINE DESSIN au pixel trop grand
BbAL:	bmi	BmAp
	move.w	d2,d6
	lsr.w	#6,d6
	and.w	#%0111111,d2
	or.w	#%1000000,d2
	move.w	BbACon0(a4),BltCon0(a6)
	move.w	BbACon1(a4),BltCon1(a6)
	move.w	BbAAEc(a4),d3
	ext.l	d3
	lsl.l	#1,d3
	move.w	BbAModO(a4),d0
	move.w	d0,BltModA(a6)
	move.w	d0,BltModB(a6)
	move.w	BbAMaskG(a4),BltMaskG(a6)
	move.w	BbAMaskD(a4),BltMaskD(a6)
	move.w	#0,BltDatA(a6)
	move.w	BbAPlan(a4),d1
	move.w	BbNPlan(a4),d0
BbAl1:	lsr.w	#1,d1
	bcc.s	BbAl5
BbAl2:
	move.l	(a3),a2
	add.l	d3,a2
	move.w	d6,d7
	bsr	BlitWait
	move.l	d5,BltAdA(a6)
	move.l	a0,BltAdB(a6)
	move.l	a2,BltAdC(a6)
	move.l	a2,BltAdD(a6)
BbAl3	bsr	BlitWait
	move.w	#0,BltDatA(a6)
	move.w	d2,BltSize(a6)
	subq.w	#1,d7
	bne.s	BbAl3
BbAl5:	add.l	d4,a0
	addq.l	#4,a3
	dbra	d0,BbAl1
	rts

******* ROUTINE DESSIN: Multiple de 16!
BbA16:	bmi	BMA16
	move.w	BbAAEc(a4),d3		* D3= Decalage ecran
	ext.l	d3
	lsl.l	#1,d3
	move.w	BbAModO(a4),d0		* Valeur MODULO
	move.w	d0,BltModA(a6)
	move.w	d0,BltModB(a6)
	move.w	BbACon0(a4),BltCon0(a6)	* Registres de controle
	move.w	#0,BltCon1(a6)
	moveq	#-1,d0
	move.w	d0,BltMaskG(a6)
	move.w	d0,BltMaskD(a6)
	move.w	BbAPlan(a4),d1
	move.w	BbNPlan(a4),d0
BbA1:	lsr.w	#1,d1
	bcc.s	BbA4
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.l	d5,BltAdA(a6)
	move.l	a0,BltAdB(a6)
	move.l	a2,BltAdC(a6)
	move.l	a2,BltAdD(a6)
	move.w	d2,BltSize(a6)
BbA4:	add.l	d4,a0
	addq.l	#4,a3
	dbra	d0,BbA1
	rts

******* ROUTINE DESSIN SANS MASQUE, Multiple de 16!
BMA16:	move.w	BbAAEc(a4),d3
	ext.l	d3
	lsl.l	#1,d3
	move.w	BbAModO(a4),BltModB(a6)

	move.w	BbACon0(a4),d0		  *If minterm replace use
	cmp.b	#$CA,d0			  *fast blit , ideal for
	bne.s	Normal_BMA16		  *fast icon pasting in games!
	move.w	BbAModO(a4),BltModA(a6)	  *
	move.w	#%100111110000,BltCon0(a6)*
	move.w	#0,BltCon1(a6)		  *
	moveq	#-1,d0			  *
	move.w	d0,BltMaskG(a6)		  *
	move.w	d0,BltMaskD(a6)		  *
	move.w	d0,BltDatB(a6)		  *
	move.w	d0,BltDatC(a6)		  *
	move.w	BbAPlan(a4),d1		  *
	move.w	BbNPlan(a4),d0		  *
BMA1f:	lsr.w	#1,d1			  *
	bcc.s	BMA3f			  *
	move.l	(a3),a2			  *
	add.l	d3,a2			  *
	bsr	BlitWait		  *
	move.l	a0,BltAdA(a6)		  *
	move.l	a2,BltAdD(a6)		  *
	move.w	d2,BltSize(a6)		  *
BMA3f:	add.l	d4,a0			  *
	addq.l	#4,a3			  *
	dbra	d0,BMA1f		  *
	rts				  *

Normal_BMA16:
	move.w	BbACon0(a4),BltCon0(a6)
	move.w	#0,BltCon1(a6)
	moveq	#-1,d0
	move.w	d0,BltMaskG(a6)
	move.w	d0,BltMaskD(a6)
	move.w	d0,BltDatA(a6)
	move.w	BbAPlan(a4),d1
	move.w	BbNPlan(a4),d0
BMA1:	lsr.w	#1,d1
	bcc.s	BMA3
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.l	a0,BltAdB(a6)
	move.l	a2,BltAdC(a6)
	move.l	a2,BltAdD(a6)
	move.w	d2,BltSize(a6)
BMA3:	add.l	d4,a0
	addq.l	#4,a3
	dbra	d0,BMA1
	rts

******* ROUTINE DESSIN SANS MASQUE, Pixel!
BMAp:
	move.w	BbAAEc(a4),d3
	ext.l	d3
	lsl.l	#1,d3

	move.w	BbAModO(a4),BltModB(a6)
	move.w	BbACon0(a4),BltCon0(a6)
	move.w	BbACon1(a4),BltCon1(a6)
	move.w	BbAMaskG(a4),BltMaskG(a6)
	move.w	BbAMaskD(a4),BltMaskD(a6)
	move.w	#-1,BltDatA(a6)
	move.w	BbAPlan(a4),d1
	move.w	BbNPlan(a4),d0
BMAp1:	lsr.w	#1,d1
	bcc.s	BMAp4
	move.l	(a3),a2
	add.l	d3,a2
	bsr	BlitWait
	move.l	a0,BltAdB(a6)
	move.l	a2,BltAdC(a6)
	move.l	a2,BltAdD(a6)
	move.w	d2,BltSize(a6)
BMAp4:	add.l	d4,a0
	addq.l	#4,a3
	dbra	d0,BMAp1
	rts

******* ROUTINE DESSIN SANS MASQUE au pixel trop grand
BmAL:	move.w	d2,d6
	lsr.w	#6,d6
	and.w	#%0111111,d2
	or.w	#%1000000,d2
	move.w	BbACon0(a4),BltCon0(a6)
	move.w	BbACon1(a4),BltCon1(a6)

	move.w	BbAAEc(a4),d3
	ext.l	d3
	lsl.l	#1,d3

	move.w	BbAModO(a4),BltModB(a6)
	move.w	BbAMaskG(a4),BltMaskG(a6)
	move.w	BbAMaskD(a4),BltMaskD(a6)
	move.w	#0,BltDatA(a6)
	move.w	BbAPlan(a4),d1
	move.w	BbNPlan(a4),d0
BmAl1:	lsr.w	#1,d1
	bcc.s	Bmal7
	move.l	(a3),a2
	add.l	d3,a2
	move.w	d6,d7
	bsr	BlitWait
	move.l	a0,BltAdB(a6)
	move.l	a2,BltAdC(a6)
	move.l	a2,BltAdD(a6)
Bmal3:	bsr	BlitWait
	move.w	#-1,BltDatA(a6)
	move.w	d2,BltSize(a6)
	subq.w	#1,d7
	bne.s	Bmal3
Bmal7:	add.l	d4,a0
	addq.l	#4,a3
	dbra	d0,BmAl1
	rts

******************************************************************
*	Screen copy a0,d0,d1,d4,d5 to a1,d2,d3,d6
*
*	a0 Origin Bit Map Struc.   a1 Destination Bit Map Struc.
*	d0 Origin X (16 a factor!) d2 Destination X (16 a factor!)
*	d1 Origin Y		   d3 Destination Y
*		  	d4 Width  X (Must be multiple of 16!)
*			d5 height Y
*			d6 Minterm
*
*	If minterm is $CC and d0,d2,d4 are on word boundaries
*	then blit is done and result is 0 otherwise not done
*	and result is -1.
*
*	Uses only A and D channels for blit,
*	therefore twice as fast as normal screen copy!
*

WScCpy:	cmp.b	#$CC,d6
	bne.s	NoWScCpy
	move.w	d0,d7
	and.w	#$f,d7
	bne.s	NoWScCpy
	move.w	d2,d7
	and.w	#$f,d7
	bne.s	NoWScCpy
	move.w	d4,d7
	and.w	#$f,d7
	bne.s	NoWScCpy
	bra.s	DoWScCpy
NoWScCpy:
	moveq.l	#-1,d7
	rts
DoWScCpy:
	moveq.l	#0,d7
	cmp.w	d1,d3
	blt.s	Ascending_Blit
	bgt.s	Descending_Blit
	cmp.w	d0,d2
	blt.s	Ascending_Blit
Descending_Blit:
	addq.l	#2,d7

	add.w	d4,d0
	sub.w	#16,d0
	add.w	d5,d1
	subq.w	#1,d1

	add.w	d4,d2
	sub.w	#16,d2
	add.w	d5,d3
	subq.w	#1,d3
Ascending_Blit:
	lsl.w	#6,d5
	lsr.w	#4,d0
	lsl.w	#1,d0

	lsr.w	#4,d2
	lsl.w	#1,d2

	lsr.w	#4,d4
	lsl.w	#1,d4
	move.w	(a0),d6
	mulu	d6,d1
	and.l	#$FFFF,d0
	add.l	d1,d0
	sub.w	d4,d6
	move.w	(a1),d1
	mulu	d1,d3
	and.l	#$FFFF,d2
	add.l	d3,d2
	sub.w	d4,d1
	lsr.w	#1,d4
	add.w	d4,d5
	moveq.l	#0,d4
	move.b	5(a0),d4
	moveq.l	#0,d3
	move.b	5(a1),d3
	lea	8(a0),a0
	lea	8(a1),a1
	lea	circuits,a6
	bsr	OwnBlit
	move.w	#%100111110000,BltCon0(a6)
	move.w	d7,BltCon1(a6)
	moveq.l	#-1,d7
	move.w	d7,BltDatB(a6)
	move.w	d7,BltDatC(a6)
	move.w	d7,BltMaskD(a6)
	move.w	d7,BltMaskG(a6)
	move.w	d6,BltModA(a6)
	move.w	d1,BltModD(a6)
	bra.s	Start_Blit
Blit_Loop:
	move.l	(a0)+,a2
	add.l	d0,a2
	move.l	(a1)+,a3
	add.l	d2,a3
	bsr	BlitWait
	move.l	a2,BltAdA(a6)
	move.l	a3,BltAdC(a6)
	move.l	a3,BltAdD(a6)
	move.w	d5,BltSize(a6)
Start_Blit:
	subq.w	#1,d4
	bmi.s	Blit_out
	dbra	d3,Blit_Loop
Blit_out:
	bsr	BlitWait
	bsr	DownBlit
	moveq.l	#0,d7
	rts

***********************************************************
*	Calcul de PEN/PAPER
***********************************************************
AdColor:move.w	WiNPlan(a5),d1

	move.w	WiPaper(a5),d2
	move.w	WiPen(a5),d3
	move.w	d2,d4
	move.w	d3,d5
	lea	TAdCol(pc),a0
	lea	WiColor(a5),a1
	lea	WiColFl(a5),a2

ACol:	moveq	#16,d0
	btst	d1,WiSys+1(a5)
	bne.s	ACol1
	clr.w	d0
	lsr.w	#1,d2
	roxl.w	#1,d0
	lsr.w	#1,d3
	roxl.w	#1,d0
	lsl.w	#2,d0
ACol1	move.l	0(a0,d0.w),d0
	add.l	a0,d0
	move.l	d0,(a1)+

	lsr.w	#1,d4
	subx.w	d0,d0
	move.w	d0,(a2)+
	lsr.w	#1,d5
	subx.w	d0,d0
	move.w	d0,(a2)+

	dbra	d1,ACol

	rts

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* SCREENS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

***********************************************************
*	DEMARRAGE A FROID DES ECRANS
*	D0= taille memoire pour liste copper
***********************************************************
EcInit:
* Reserve la memoire pour liste copper ecrans
	move.l	#EcTCop,d0
	bsr	FastMm
	beq	GFatal
	move.l	d0,T_EcCop(a5)
* Petit buffer en CHIP pour les operations graphiques
	move.l	#256,d0
	bsr	ChipMm
	beq	GFatal
	move.l	d0,T_ChipBuf(a5)
* Taille affichage par defaut
	move.w	#311+EcYBase,T_EcYMax(a5)	PAL
	move.l	$4.w,a0
	cmp.b	#50,530(a0)			VBlankFrequency=50?
	beq.s	.NoNTSC
	move.w	#261+EcYBase,T_EcYMax(a5)	NTSC!
.NoNTSC
* Autre inits
	bsr	EcRaz
	bsr	EcCopper
	tst.b	T_AMOSHere(a5)
	beq.s	.Skip
	lea	Circuits,a6
	clr.w	CopJmp1(a6)
	move.w	#$82A0,DmaCon(a6)
.Skip
; Installe le vecteur
	lea	EcIn(pc),a0
	move.l	a0,T_EcVect(a5)
	moveq	#0,d0
	rts

**********************************************************
*	ARRET FINAL DES ECRANS
**********************************************************
EcEnd:	moveq	#0,d1
	moveq	#EcMax-1,d2
	bsr	EcDAll
	bsr	RazCBloc
	bsr	RazBloc
	moveq	#-1,d1
	bsr	TrDel
* Efface la memoire du buffer CHIP
	move.l	T_ChipBuf(a5),d0
	beq.s	.skip
	move.l	d0,a1
	move.l	#256,d0
	bsr	FreeMm
.skip
* Efface la memoire liste copper
	move.l	T_EcCop(a5),d0
	beq.s	EcEnd1
	move.l	d0,a1
	move.l	#EcTCop,d0
	bsr	FreeMm
EcEnd1:	rts


******* Jumps to screen functions
EcIn:	bra	EcRaz		;Raz:
	bra	EcCopper	;CopMake:
	bra	EcCopper	;*
	bra	EcCree		;Cree:
	bra	EcDel		;Del:
	bra	EcFirst		;First:
	bra	EcLast		;Last:
	bra	EcMarch		;Active:
	bra	EcForceCop	;CopForce:
	bra	EcView		;AView:
	bra	EcOffs		;OffSet:
	bra	EcEnd		;Visible:
	bra	EcDAll		;DelAll:
	bra	EcGCol		;GCol:
	bra	EcSCol		;SCol:
	bra	EcSPal		;SPal:
	bra	EcSColB		;SColB:
	bra	FlStop		;FlRaz:
	bra	FlStart		;Flash:
	bra	ShStop		;ShRaz:
	bra	ShStart		;Shift:
	bra	EcHide		;EHide:
	bra	MakeCBloc	;CBlGet:
	bra	DrawCBloc	;CBlPut:
	bra	FreeCBloc	;CBlDel:
	bra	RazCBloc	;CBlRaz:
	bra	EcLibre		;Libre:
	bra	EcCClo		;CCloEc:
	bra	EcCrnt		;Current:
	bra	EcDouble	;Double:
	bra	ScSwap		;SwapSc:
	bra	ScSwapS		;SwapScS:
	bra	EcAdres		;AdrEc:
	bra	Duale		;SetDual:
	bra	DualP		;PriDual:
	bra	EcCls		;ClsEc:
	bra	SPat		;Pattern:
	bra	TGFonts		;GFonts:
	bra	TFFonts		;FFonts:
	bra	TGFont		;GFont:
	bra	TSFont		;SFont:
	bra	TSClip		;SetClip:
	bra	MakeBloc	;- BlGet:		Routine blocs normaux
	bra	DelBloc		;-BlDel:
	bra	RazBloc		;-BlRaz:
	bra	DrawBloc	;-BlPut:
	bra	SliVer		;- VerSli:		Slider vertical
	bra	SliHor		;- HorSli:		Slider horizontal
	bra	SliSet		;- SetSli:		Set slider params
	bra	StaMn		;- MnStart:	Sauve l'ecran
	bra	StoMn		;- MnStop:		Remet l'ecran
	bra	TRDel		;- RainDel:	Delete RAINBOW
	bra	TRSet		;- RainSet:	Set RAINBOW
	bra	TRDo		;- RainDo:		Do RAINBOW
	bra	TRHide		;- RainHide:	Hide / Show RAINBOW
	bra	TRVar		;- RainVar:	Var RAINBOW
	bra	FadeTOn		;- FadeOn:		Fade
	bra	FadeTOf		;- FadeOf:		Fade Off
	bra	TCopOn		;- CopOnOff:	Copper ON/OFF
	bra	TCopRes		;- CopReset:	Copper RESET
	bra	TCopSw		;- CopSwap:	Copper SWAP
	bra	TCopWt		;- CopWait:	Copper WAIT
	bra	TCopMv		;- CopMove:	Copper MOVE
	bra	TCopMl		;- CopMoveL:	Copper MOVEL
	bra	TCopBs		;- CopBase:	Copper BASE ADDRESS
	bra	TAbk1		;- AutoBack1:	Autoback 1
	bra	TAbk2		;- AutoBack2:	Autoback 2
	bra	TAbk3		;- AutoBack3:	Autoback 3
	bra	TAbk4		;- AutoBack4:	Autoback 4
	bra	TPaint		;- SuPaint:	Super paint!
	bra	RevBloc		;- BlRev:		Retourne le bloc
	bra	RevTrap		;- DoRev:		Retourne dans la banque
	bra	TAmosWB		;- AMOS_WB		AMOS/WorkBench
	bra	WScCpy		;- ScCpyW		New_W_2.s
	bra	TMaxRaw		;- MaxRaw		Maximum raw number
	bra	TNTSC		;- NTSC		NTSC?
	bra	SliPour		;- PourSli		Calculs slider

***********************************************************
*	Instructions de gestion des ecrans
***********************************************************

******* MAX RAW
TMaxRaw	move.w	T_EcYMax(a5),d1
	sub.w	#EcYBase,d1
	ext.l	d1
	moveq	#0,d0
	rts
******* NTSC?
TNTSC	moveq	#0,d0
	moveq	#0,d1			PAL
	move.l	$4.w,a0
	cmp.b	#50,530(a0)		VBlankFrequency=50?
	beq.s	.NoNTSC
	moveq	#-1,d1			NTSC!
.NoNTSC	rts

******* SCREEN SWAP D1
ScSwap:	movem.l	d1-d7/a1-a6,-(sp)
	bsr	EcGet
	beq	EcE3
	move.l	d0,a4
	btst	#BitDble,EcFlags(a4)
	beq	EcOk
	move.w	EcNumber(a4),d0
	lea	T_SwapList(a5),a0
	tst.l	(a0)
	beq.s	ScSw2
ScSw1:	cmp.w	SwapL-2(a0),d0		* Screen already swapped!
	beq	EcOk
	lea	SwapL(a0),a0
	tst.l	(a0)
	bne.s	ScSw1
ScSw2:	move.w	d0,SwapL-2(a0)
	lsl.w	#6,d0
	add.w	#CopL1*EcMax,d0
	lea	T_CopMark(a5),a1	* Garde l'adresse pour la fin!
	add.w	d0,a1
	move.l	a0,a6
	addq.l	#4,a0
	move.w	EcNPlan(a4),d0		* Nombre de bit planes
	subq.w	#1,d0
	move.w	d0,(a0)+
	move.l	EcDEcran(a4),d2
	lea	EcLogic(a4),a2
	lea	EcPhysic(a4),a3
	move.w	d0,d3
ScSw3:	move.l	(a2),d1			* Screen swap!
	move.l	(a3),(a2)+
	move.l	d1,(a3)+
	add.l	d2,d1
	move.l	d1,(a0)+
	dbra	d3,ScSw3
	lea	EcLogic(a4),a0		* Update les outputs!
	lea	EcCurrent(a4),a2
	move.l	Ec_BitMap(a4),a3
	lea	bm_Planes(a3),a3
	move.w	d0,d3
ScSw4	move.l	(a0),(a2)+
	move.l	(a0)+,(a3)+
	dbra	d3,ScSw4
* Autorise le screen swap
	tst.w	T_CopON(a5)		* Pas si COPPER OFF!
	beq	EcOk
	btst	#2,EcCon0+1(a4)		* Interlace?
	bne	EcOk
	clr.l	SwapL(a6)		* Empeche le suivant
	move.l	a1,(a6)
	bra	EcOk

******* SCREEN SWAP DE TOUS LES ECRANS UTILISATEUR
ScSwapS	movem.l	d1-d7/a1-a6,-(sp)
	lea	T_EcAdr(a5),a1
	moveq	#8-1,d6
	lea	T_SwapList(a5),a0
	clr.l	(a0)
* Explore tous les ecrans
ScSwS0:	move.l	(a1)+,d0
	bne.s	ScSwS2
ScSwS1:	dbra	d6,ScSwS0
	bra	EcOk
* Swappe un ecran!
ScSwS2:	move.l	d0,a4
	btst	#BitDble,EcFlags(a4)
	beq.s	ScSwS1
	move.w	EcNumber(a4),d0
	move.w	d0,SwapL-2(a0)
	lsl.w	#6,d0
	add.w	#CopL1*EcMax,d0
	lea	T_CopMark(a5),a2	* Garde l'adresse pour la fin!
	add.w	d0,a2
	move.l	a2,d7
	move.l	a0,a6
	addq.l	#4,a0
	move.w	EcNPlan(a4),d0		* Nombre de bit planes
	subq.w	#1,d0
	move.w	d0,(a0)+
	move.l	EcDEcran(a4),d2
	lea	EcLogic(a4),a2
	lea	EcPhysic(a4),a3
	move.w	d0,d3
ScSwS3:	move.l	(a2),d1			* Screen swap!
	move.l	(a3),(a2)+
	move.l	d1,(a3)+
	add.l	d2,d1
	move.l	d1,(a0)+
	dbra	d3,ScSwS3
	lea	EcLogic(a4),a0		* Update les outputs!
	lea	EcCurrent(a4),a2
	move.l	Ec_BitMap(a4),a3
	lea	bm_Planes(a3),a3
	move.w	d0,d3
ScSwS4	move.l	(a0),(a2)+
	move.l	(a0)+,(a3)+
	dbra	d3,ScSwS4
* Autorise le screen swap
	lea	SwapL(a6),a0
	tst.w	T_CopON(a5)		* Si COPPER ON!
	beq	ScSwS1
	btst	#2,EcCon0+1(a4)		* Interlace?
	bne	ScSwS1
	clr.l	SwapL(a6)		* Empeche le suivant!
	move.l	d7,(a6)
	bra	ScSwS1

******* SCREEN CLONE N
EcCClo:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	d1,-(sp)
	bsr	EcGet
	beq.s	EcCT0
	addq.l	#4,sp
	bra	EcE2
* Reserve la RAM / Verifie les parametres
EcCT0:	move.l	#EcLong,d0
	bsr	FastMm
	beq	EcE1
	move.l	d0,a4
	move.l	d0,a1
	move.w	#EcLong-1,d0
	move.l	T_EcCourant(a5),a0
EcCT1:	move.b	(a0)+,(a1)+
	dbra	d0,EcCT1
* Pas de zones
	clr.l	EcAZones(a4)
	clr.w	EcNZones(a4)
* Pas de fenetre!
	clr.l	EcWindow(a4)
* Pas de pattern
	clr.l	EcPat(a4)
* Pas de fonte
	clr.w	EcFontFlag(a4)
* Cree l'ecran dans les tables
	bset	#BitClone,EcFlags(a4)
	move.l	(sp)+,d1
	move.w	d1,EcNumber(a4)
* Entrelace?
	bsr	InterPlus
* Met dans la displaylist
	bsr	EcGet
	move.l	a4,(a0)
	bsr	EcFirst
	bra	EcTout

******* DOUBLE BUFFER: Passe en double buffer!
EcDouble:
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
* Deja en double?
	btst	#BitDble,EcFlags(a4)
	bne	EcE25
* Reserve la RAM / Copie le contenu
	move.w	EcNplan(a4),d6
	subq.w	#1,d6
	lea	EcPhysic(a4),a2
	lea	EcLogic(a4),a3
	lea	EcCurrent(a4),a6
EcDb1:	move.l	EcTPlan(a4),d0		* Reserve!
	bsr	ChipMm
	beq	EcDbE
	move.l	d0,(a3)+
	move.l	d0,(a6)+
	move.l	d0,a1			* Copie!
	move.l	(a2)+,a0
	move.l	EcTPlan(a4),d0
	lsr.w	#4,d0
	subq.w	#1,d0
EcDb2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,EcDb2
	dbra	d6,EcDb1
* Met le flag!
	bset	#BitDble,EcFlags(a4)
	move.w	#2,EcAuto(a4)
* Enleve le BUG!
	bsr	TAbk1
	bsr	TAbk2
	bsr	TAbk3
	bra	EcOk
* Erreur! Efface l'ecran entier
EcDbE	moveq	#0,d1
	move.w	EcNumber(a4),d1
	bsr	EcDel
	bra	EcE1

	IFEQ	EZFlag
******* Dual Playfield D1,D2
*	D1= Ecran 1
*	D2= Ecran 2
Duale:	movem.l	d1-d7/a1-a6,-(sp)
	cmp.w	d1,d2
	beq	EcE26
	move.w	d2,d7
	addq.w	#1,d7
	exg	d1,d2
	bsr	EcGet
	beq	EcE3
	move.l	d0,a1
	move.w	d2,d1
	bsr	EcGet
	beq	EcE3
	move.l	d0,a0
	tst.w	EcDual(a0)		* Pas deja dual!
	bne	EcE26
	tst.w	EcDual(a1)
	bne	EcE26
	moveq	#3,d2
	move.w	EcCon0(a0),d0		* Meme resolution!
	bpl.s	EcDu1
	moveq	#2,d2
EcDu1:	and.w	#%1000111111111111,d0
	move.w	EcCon0(a1),d1
	and.w	#%1000111111111111,d1
	cmp.w	d0,d1
	bne	EcE26
	move.w	EcNPlan(a0),d3
	move.w	EcNPlan(a1),d4
	cmp.w	d2,d3
	bhi	EcE26
	cmp.w	d2,d4
	bhi	EcE26
	move.w	d3,d2			* Nombre total de plans
	add.w	d4,d2
	cmp.w	d3,d4			* Combinaisons autorisees?
	beq.s	EcDu2
	addq.w	#1,d4
	cmp.w	d3,d4
	bne	EcE26
EcDu2:	moveq	#12,d1
	lsl.w	d1,d2
	or.w	d2,d0
	bset	#10,d0			* Mode DUAL PLAYFIELD!
	move.w	d0,EcCon0(a0)
	move.w	EcCon2(a0),d0		* Priorites sprites-> 2 ieme plan!
	and.w	#%111,d0
	lsl.w	#3,d0
	or.w	d0,EcCon2(a0)
	and.w	#%111111,EcCon2(a0)
	bset	#BitHide,EcFlags(a1)	* Cache le deuxieme
	move.w	d7,EcDual(a0)		* Met les flags!
	neg.w	d7
	move.w	d7,EcDual(a1)
	bra	EcTout

******* DUAL PRIORITY n,m
DualP:	movem.l	d1-d7/a1-a6,-(sp)
	cmp.w	d1,d2
	beq	EcE27
	exg	d1,d2
	bsr	EcGet
	beq	EcE3
	move.l	d0,a1
	move.w	d2,d1
	bsr	EcGet
	beq	EcE3
	move.l	d0,a0
	moveq	#0,d0
	tst.w	EcDual(a0)
	beq	EcE27
	tst.w	EcDual(a1)
	beq	EcE27
	bmi.s	EcDup1
	move.l	a1,a0
	moveq	#-1,d0
EcDup1:	move.w	EcCon2(a0),d1
	bclr	#6,d1
	tst.w	d0
	beq.s	EcDup2
	bset	#6,d1
EcDup2:	move.w	d1,EcCon2(a0)
	bra	EcOtoV
	ENDC

******* Creation de l'ecran
*	D1= #
*	D2= TX
*	D3= TY
*	D4= NB PLANS
*	D5= MODE
*	D6= NB COULEURS
*	A1= PALETTE
EcCree:	movem.l	d1-d7/a1-a6,-(sp)

;	Verifie les parametres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	and.l	#$FFFFFFF0,d2
	beq	EcE4
	cmp.l	#1024,d2
	bcc	EcE4
	tst.l	d3
	beq	EcE4
	cmp.l	#1024,d3
	bcc	EcE4
	tst.l	d4
	beq	EcE4
	cmp.l	#EcMaxPlans,d4
	bhi	EcE4

;	Ecran deja reserve?
; ~~~~~~~~~~~~~~~~~~~~~~~~~
ReEc:	move.l	d1,-(sp)
	bsr	EcGet
	beq.s	EcCr0
; Efface l'ecran deja r�serve
	move.l	(sp)+,d1
	bsr	EcDel
	bra.s	ReEc

;	Reserve la RAM pour la structure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EcCr0:	move.l	#EcLong,d0
	bsr	FastMm
	beq	EcEE1
	move.l	d0,a4

; Couleurs
; ~~~~~~~~
	move.w	d6,EcNbCol(a4)
	moveq	#31,d0
	lea	EcPal(a4),a2
EcCr4:	move.w	(a1)+,(a2)+
	dbra	d0,EcCr4
; Taille de l'ecran
; ~~~~~~~~~~~~~~~~~
	move.w	d2,EcTx(a4)
	move.w	d2,EcTxM(a4)
	subq.w	#1,EcTxM(a4)
	move.w	d2,d7
	lsr.w	#3,d7
	move.w	d7,EcTLigne(a4)
	move.w	d3,EcTy(a4)
	move.w	d3,EcTyM(a4)
	subq.w	#1,EcTyM(a4)
	mulu	d3,d7
	move.l	d7,EcTPlan(a4)
	move.w	d4,EcNPlan(a4)

; 	Parametres d'affichage -1-
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_GfxBase(a5),a0	EcCon0
	move.w	164(a0),d0
	and.w	#%0000001111111011,d0
	move.w	d4,d1
	lsl.w	#8,d1
	lsl.w	#4,d1
	or.w	d0,d1
	or.w	d1,d5
	move.w	d5,EcCon0(a4)
	move.w	#%00100100,EcCon2(a4)	EcCon2

;	Creation de la structure BitMap / Reservation des bitmaps
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#40,d0				bm_SIZEOF
	bsr	FastMm
	beq	EcMdd
	move.l	d0,Ec_BitMap(a4)
	move.l	d0,a0
	move.w	EcNPlan(a4),d0			Creation de BitMap
	ext.l	d0
	move.w	EcTx(a4),d1
	ext.l	d1
	move.w	EcTy(a4),d2
	ext.l	d2
	move.l	T_GfxBase(a5),a6
	jsr	_LVOInitBitMap(a6)
; Reserve la RAM
; ~~~~~~~~~~~~~~
	move.w	d4,d6
	subq.w	#1,d6
	move.l	Ec_BitMap(a4),a1
	moveq	#0,d2
EcCra:	move.l	d7,d0
	bsr	ChipMm
	beq	EcMdd
	move.l	d0,bm_Planes(a1,d2.w)
	move.l	d0,EcCurrent(a4,d2.w)
	move.l	d0,EcLogic(a4,d2.w)
	move.l	d0,EcPhysic(a4,d2.w)
	addq.l	#4,d2
	dbra	d6,EcCra

;	Ouverture d'un rastport intuition REEL
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_LayBase(a5),a6
	jsr	_LVONewLayerInfo(a6)		Creation de LayerInfo
	move.l	d0,Ec_LayerInfo(a4)
	beq	EcMdd
	move.l	d0,a0				Creation du layer
	move.l	Ec_BitMap(a4),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	EcTx(a4),d2
	subq.w	#1,d2
	ext.l	d2
	move.w	EcTy(a4),d3
	subq.w	#1,d3
	ext.l	d3
	moveq	#LAYERSIMPLE,d4
	sub.l	a2,a2
	jsr	_LVOCreateUpfrontLayer(a6)
	move.l	d0,Ec_Layer(a4)
	beq	EcMdd
	move.l	d0,a0				Rastport courant
	move.l	lr_rp(a0),Ec_RastPort(a4)

	bsr	BlitWait
	bsr	WVbl
	bsr	BlitWait

;	Zones
; ~~~~~~~~~~~
	clr.l	EcAZones(a4)
	clr.w	EcNZones(a4)

;	Additionne l'ecran dans les tables
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	(sp),d1
	lea	Circuits,a6
	bsr	EcGet
	move.l	a4,(a0)			Branche
	move.w	d1,EcNumber(a4)		Un numero!
	move.l	a4,a0			Devient l'ecran courant
	bsr	Ec_Active
	move.l	(sp),d1
	bsr	EcFirst			Et devant les autres
	bsr	InterPlus		Si entrelace

; 	Parametres d'affichage -2-
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	T_DefWX(a5),d2		Affichage par defaut
	move.w	T_DefWY(a5),d3
	move.w	EcTx(a4),d4
	tst.w	EcCon0(a4)
	bpl.s	EcCr6
	lsr.w	#1,d4
EcCr6	move.w	EcTy(a4),d5
	cmp.w	#320+16,d4
	bcs.s	EcCr7
	move.w	T_DefWX2(a5),d2
EcCr7	cmp.w	#256,d5
	bcs.s	EcCr8
	btst	#2,EcCon0+1(a4)
	beq.s	EcCr7a
	cmp.w	#256*2,d5
	bcs.s	EcCr8
EcCr7a	move.w	T_DefWY2(a5),d3
EcCr8	ext.l	d2
	ext.l	d3
	ext.l	d4
	ext.l	d5
	move.l	(sp),d1
	bsr	EcView

; 	Cree la fenetre de texte plein ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	clr.l	EcWindow(a4)
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	EcTx(a4),d4
	lsr.w	#4,d4
	lsl.w	#1,d4
	move.w	EcTy(a4),d5
	lsr.w	#3,d5
	moveq	#1,d6
	moveq	#0,d7
	sub.l	a1,a1
	bsr	WOpen
	bne	EcM1

;	Initialisation des parametres graphiques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	EcWindow(a4),a0
	move.b	WiPen+1(a0),d1
	move.b	d1,EcInkA(a4)
	move.b	WiPaper+1(a0),d0
	move.b	d0,EcInkB(a4)
	move.b	d1,EcFInkC(a4)
	move.b	d1,EcIInkC(a4)
	move.b	d0,EcFInkA(a4)
	move.b	d0,EcFInkB(a4)
	move.b	d0,EcIInkA(a4)
	move.b	d0,EcIInkB(a4)
	move.w	#1,EcIPat(a4)
	move.w	#2,EcFPat(a4)
	move.b	#1,EcMode(a4)
	move.w	#-1,EcLine(a4)

	move.l	Ec_RastPort(a4),a1
	moveq	#0,d0
	move.b	EcInkA(a4),d0			Ink A
	GfxA5	_LVOSetAPen
	move.b	EcInkB(a4),d0			Ink B
	GfxA5	_LVOSetBPen
	move.b	EcMode(a4),d0			Draw Mode
	GfxA5	_LVOSetDrMd
;	move.w	EcCont(a4),32(a1)		Cont
	move.w	EcLine(a4),34(a1)		Line
	clr.w	36(a1)				X
	clr.w	38(a1)				Y

	move.l	T_DefaultFont(a5),a0		Fonte systeme
	GfxA5	_LVOSetFont

	clr.w	EcClipX0(a4)			Par default
	clr.w	EcClipY0(a4)
	move.w	EcTx(a4),EcClipX1(a4)
	move.w	EcTy(a4),EcClipY1(a4)

; Pas d'erreur
; ~~~~~~~~~~~~~
	addq.l	#4,sp
	move.l	T_EcCourant(a5),a0	* Ramene l'adresse definition
; Doit recalculer les ecrans
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
EcTout:	addq.w	#1,T_EcYAct(a5)
; Doit actualiser ECRANS
; ~~~~~~~~~~~~~~~~~~~~~~
EcOtoV:	bset	#BitEcrans,T_Actualise(a5)
EcOk:	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#0,d0
	rts

;	Erreur creation d'un ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EcM1:	move.l	(sp),d1
	bsr	EcDel
	bra.s	EcEE1
EcMdd	bsr	EcDDel			* Efface la structure
EcEE1	addq.l	#4,sp
EcE1:	moveq	#1,d0
	bra.s	EcOut
EcE4:	moveq	#4,d0			* Sans effacement
	bra.s	EcOut
EcE3:	moveq	#3,d0			* 3 : SCREEN NOT OPENED
	bra.s	EcOut
EcE25:	moveq	#25,d0			* 25: Screen already double buffered
	bra.s	EcOut
EcE26:	moveq	#26,d0			* Can't set dual-playfield
	bra.s	EcOut
EcE27:	moveq	#27,d0			* Screen not dual playfield
	bra.s	EcOut
EcE2:	moveq	#2,d0			* 2 : SCREEN ALREADY OPENED
* Sortie erreur ecrans
EcOut:	movem.l	(sp)+,d1-d7/a1-a6
	tst.l	d0
	rts

******* Un ecran entrelace en plus!
InterPlus:
	btst	#2,EcCon0+1(a4)
	beq.s	IntPls
	movem.l	d0/a0/a1,-(sp)
	clr.w	T_InterBit(a5)
	lea	T_InterList(a5),a0
IntP0	tst.l	(a0)
	addq.l	#8,a0
	bne.s	IntP0
	clr.l	(a0)
	move.l	a4,-8(a0)
	move.w	EcNumber(a4),d0
	lsl.w	#6,d0
	add.w	#CopL1*EcMax,d0
	ext.l	d0
	lea	T_CopMark(a5),a1
	add.l	a1,d0
	move.l	d0,-4(a0)
	movem.l	(sp)+,d0/a0/a1
IntPls	rts

;	Sauve les contenu du rasport de l'ecran courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ec_Push	movem.l	a0-a1/d0,-(sp)
	tst.w	T_PaPeek(a5)
	bne.s	.Pasave
	move.l	T_RastPort(a5),d0
	beq.s	.Pasave
	move.l	d0,a0
	lea	T_EcSave(a5),a1
	move.b	25(a0),(a1)+		0 EcInkA(a1)
	move.b	26(a0),(a1)+		1 EcInkB(a1)
	move.b	27(a0),(a1)+		2 EcOutL(a1)
	move.b	28(a0),(a1)+		3 EcMode(a1)
	move.w	32(a0),(a1)+		4 EcCont(a1)
	move.w	34(a0),(a1)+		6 EcLine(a1)
	move.w	36(a0),(a1)+		8 EcX(a1)
	move.w	38(a0),(a1)+		10 EcY(a1)
	move.l	8(a0),(a1)+		12 EcPat
	move.b	29(a0),(a1)+		16 EcPatY
	addq.l	#1,a1
	lea	52(a0),a0
	moveq	#14-1,d0		18 Fonte
.Loop	move.b	(a0)+,(a1)+
	dbra	d0,.Loop
; Sauve le clip rectangle
	move.l	T_EcCourant(a5),a0
	move.w	EcClipX0(a0),(a1)+	32
	move.w	EcClipY0(a0),(a1)+	34
	move.w	EcClipX1(a0),(a1)+	36
	move.w	EcClipY1(a0),(a1)+	38
.Pasave	movem.l	(sp)+,a0-a1/d0
	rts

;	Restore les modes graphiques de l'ecran courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ec_Pull	movem.l	a0-a2/d0-d3,-(sp)
	tst.w	T_PaPeek(a5)
	bne.s	.Papull
	lea	T_EcSave(a5),a2
	move.l	T_RastPort(a5),d0
	beq.s	.Papull
	move.l	d0,a1
; Change le RASTPORT
; ~~~~~~~~~~~~~~~~~~
	moveq	#0,d0			Ink A
	move.b	(a2)+,d0
	GfxA5	SetAPen
 	moveq	#0,d0			Ink B
	move.b	(a2)+,d0
	GfxA5	SetBPen
	move.b	(a2)+,27(a1)		OutL
	moveq	#0,d0
	move.b	(a2)+,d0
	GfxA5	SetDrMd			Draw Mode
	move.w	(a2)+,32(a1)		Cont
	move.w	(a2)+,34(a1)		Line
	move.w	(a2)+,36(a1)		X
	move.w	(a2)+,38(a1)		Y
	move.l	(a2)+,8(a1)		EcPat
	move.b	(a2)+,29(a1)		EcPatY
	addq.l	#1,a2
	lea	52(a1),a1		Fonte
	moveq	#14-1,d0
.Loop	move.b 	(a2)+,(a1)+
	dbra	d0,.Loop
; Restore le clip rectangle
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,d2
	move.w	(a2)+,d3
	bsr	Ec_SetClip
.Papull	movem.l	(sp)+,a0-a2/d0-d3
	rts

******* VIEW: change le point de vue d'un ecran
*	D1= #
*	D2= WX
*	D3= WY
*	D4= WTx
* 	D5= WTy
EcView:	movem.l	d1-d7/a1-a6,-(sp)
	bsr	EcGet
	beq	EcE3
	move.l	d0,a4
* WX
	cmp.l	#EntNul,d2
	beq.s	EcV2
	move.w	d2,EcAWX(a4)
	bset	#1,EcAW(a4)
* WTX
EcV2:	cmp.l	#EntNul,d4
	beq.s	EcV3
	move.w	d4,EcAWTx(a4)
	bset	#1,EcAWT(a4)
* WY
EcV3:	cmp.l	#EntNul,d3
	beq.s	EcV4
	move.w	d3,EcAWY(a4)
	bset	#2,EcAW(a4)
* WTy
EcV4:	cmp.l	#EntNul,d5
	beq	EcOtoV
	move.w	d5,EcAWTy(a4)
	bset	#2,EcAWT(a4)
	bra	EcOtoV

******* Fait passer l'ecran D1 en premier
EcFirst:movem.l	d1-d7/a1-a6,-(sp)
	bsr	EcGet
	beq	EcE3
	lea	T_EcPri(a5),a0
	move.l	a0,a1
	move.l	(a1),d1
	move.l	d0,(a0)
EcF1:	addq.l	#4,a0
EcF2:	addq.l	#4,a1
	move.l	d1,d2
	move.l	(a1),d1
	move.l	d2,(a0)
	bmi.s	EcF3
	beq.s	EcF2
	cmp.l	d2,d0
	beq.s	EcF2
	bne.s	EcF1
EcF3:	bra	EcTout

******* Fait passer l'ecran D1 en dernier
EcLast:	movem.l	d1-d7/a1-a6,-(sp)
	bsr	EcGet
	beq	EcE3
	lea	T_EcPri(a5),a0
	move.l	a0,a1
EcL1:	move.l	(a1)+,d1
	move.l	d1,(a0)
	bmi.s	EcL2
	beq.s	EcL1
	cmp.l	d1,d0
	beq.s	EcL1
	addq.l	#4,a0
	bra.s	EcL1
EcL2:	move.l	d0,(a0)+
	move.l	#-1,(a0)+
	bra	EcTout

;	 Arret ecran special creation!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A4= Adresse!
EcDDel	movem.l	d1-d7/a1-a6,-(sp)
	bra.s	EcDD

;	Arret d'un ecran D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~
EcDel:	movem.l	d1-d7/a1-a6,-(sp)
	bsr	EcGet
	beq	EcE3
	move.l	d0,a4
	clr.l	(a0)			;Arrete dans la table
	lea	T_EcPri(a5),a0		;Arrete dans les priorites
	move.l	a0,a1
EcD1:	move.l	(a1)+,d0
	move.l	d0,(a0)
	bmi.s	EcD2
	beq.s	EcD1
	cmp.l	d0,a4
	beq.s	EcD1
	addq.l	#4,a0
	bra.s	EcD1
; Entrelace?
; ~~~~~~~~~~
EcD2	btst	#2,EcCon0+1(a4)
	beq.s	EcDit3
	clr.w	T_InterBit(a5)
	lea	T_InterList(a5),a0
	move.l	a0,a1
EcDit0	move.l	(a1),d0
	beq.s	EcDit2
	cmp.l	d0,a4
	beq.s	EcDit1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	bra.s	EcDit0
EcDit1	lea	8(a1),a1
	bra.s	EcDit0
EcDit2	clr.l	(a0)
; Enleve les screen swaps!
; ~~~~~~~~~~~~~~~~~~~~~~~~
EcDit3	lea	T_SwapList(a5),a0
	clr.l	(a0)
; Recalcule la liste copper
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	WVbl
	bset	#BitHide,EcFlags(a4)
	bsr	EcForceCop
	bsr	WVbl

; 	Entree sans recalcul des listes copper
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EcDD:	move.l	EcAZones(a4),d0		Les zones
	beq.s	.Nozone
	move.l	d0,a1
	move.w	EcNZones(a4),d0
	mulu	#8,d0
	bsr	FreeMm
.Nozone	lea	EcAW(a4),a0		Les animations
	bsr	DAdAMAL
	lea	EcAWT(a4),a0
	bsr	DAdAMAL
	lea	EcAV(a4),a0
	bsr	DAdAMAL
	move.l	a4,a0			Les bobs
	bsr	BbEcOff

	move.l	T_EcCourant(a5),d3
	move.l	a4,a0			Active l'ecran
	bsr	Ec_Active		Pour les effacements
	bsr	WiDelA			Toutes les fenetres
	bsr	FlStop			Animations de couleur
	bsr	ShStop
	bsr	FaStop
	bsr	EffPat			Le pattern
	bsr	CFont			La fonte

; Si ECRAN COURANT: met le + prioritaire pas clone, <8 si possible!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	a4,d3
	bne.s	EcD3
	lea	T_EcPri(a5),a0		1ere boucle: <8
EcDc2:	move.l	(a0)+,d3
	bmi.s	EcDc3
	move.l	d3,a1
	btst	#BitClone,EcFlags(a1)
	bne.s	EcDc2
	cmp.w	#8,EcNumber(a1)
	bcc.s	EcDc2
	bra.s	EcD3
EcDc3	lea	T_EcPri(a5),a0		2ieme n'importe!
EcDc4	move.l	(a0)+,d3
	bmi.s	EcDc5
	move.l	d3,a1
	btst	#BitClone,EcFlags(a1)
	bne.s	EcDc4
	bra.s	EcD3
EcDc5	moveq	#0,d3
EcD3:	move.l	d3,a0
	bsr	Ec_Active

; 	Liberation des memoires, si pas clone...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#BitClone,EcFlags(a4)		Si clone, rien a liberer...
	bne	PaClon
	move.l	a6,-(sp)

; Ferme le ClipRect
; ~~~~~~~~~~~~~~~~~
	tst.l	Ec_Region(a4)
	beq.s	.Paclip
	move.l	T_LayBase(a5),a6		Enleve le ClipRegion
	move.l	Ec_Layer(a4),a0
	sub.l	a1,a1
	jsr	_LVOInstallClipRegion(a6)
	move.l	Ec_Region(a4),a0		Enleve la region
	move.l	T_GfxBase(a5),a6
	jsr	_LVODisposeRegion(a6)
.Paclip
; Ferme le layer
; ~~~~~~~~~~~~~~
	move.l	T_LayBase(a5),a6
	move.l	Ec_Layer(a4),d0
	beq.s	.Nola1
	move.l	d0,a1
	sub.l	a0,a0
	move.l	T_LayBase(a5),a6
	jsr	_LVODeleteLayer(a6)		Enleve le layer
.Nola1	bsr	BlitWait			Blitter Wait!
	bsr	WVbl
	bsr	BlitWait
	move.l	Ec_LayerInfo(a4),d0		Enleve Layer Info
	beq.s	.Nola2
	move.l	d0,a0
	jsr	_LVODisposeLayerInfo(a6)	Enleve le layer info
.Nola2
; Liberation des bitmaps
; ~~~~~~~~~~~~~~~~~~~~~~
	bsr	BlitWait			Correction du bug dans les
	bsr	WVbl				layers...
	bsr	BlitWait
	moveq	#EcMaxPlans-1,d7
	lea	EcLogic(a4),a2
	lea	EcPhysic(a4),a3
EcFr0:	move.l	(a2),d2
	beq.s	EcFr1
	move.l	d2,a1
	move.l	EcTPlan(a4),d0
	bsr	FreeMm
EcFr1:	clr.l	(a2)+
	cmp.l	(a3)+,d2
	bne.s	EcFr2
	clr.l	-4(a3)
EcFr2:	dbra	d7,EcFr0
	moveq	#EcMaxPlans-1,d7
	lea	EcPhysic(a4),a2
EcFr3:	move.l	(a2),d0
	beq.s	EcFr4
	move.l	d0,a1
	move.l	EcTPlan(a4),d0
	bsr	FreeMm
EcFr4:	clr.l	(a2)+
	dbra	d7,EcFr3
	move.l	(sp)+,a6
; La structure Bitmap
; ~~~~~~~~~~~~~~~~~~~
	move.l	Ec_BitMap(a4),d0
	beq.s	.PaBM
	move.l	d0,a1
	moveq	#40,d0
	bsr	FreeMm
.PaBM

; 	Libere les structures
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
PaClon	move.l	a4,a1				La structure AMOS
	move.l	#EcLong,d0
	bsr	FreeMm

	move.l	T_EcCourant(a5),a0
	bra	EcOk

******* Initialisation des ecrans
EcRaz:	lea	T_EcAdr(a5),a0
	moveq	#EcMax-1,d0
EcR1:	clr.l	(a0)+
	dbra	d0,EcR1
	move.l	#-1,T_EcPri(a5)
	lea	T_CopMark(a5),a0
	move.w	#CopML/4-1,d0
EcR2:	clr.l	(a0)+
	dbra	d0,EcR2
	move.w	#1,T_EcYAct(a5)
	moveq	#0,d0
	rts

******* Arret de tous les ecrans entre D1-D2
EcDAll:	bsr	EcDel
	addq.l	#1,d1
	cmp.l	d2,d1
	bls.s	EcDAll
	moveq	#0,d0
	rts

******* SCREEN OFFSET n,dx,dy
EcOffs:	bsr	EcGet
	beq	EcME
	move.l	d0,a0
	cmp.l	#EntNul,d2
	beq.s	EcO1
	move.w	d2,EcAVX(a0)
	bset	#1,EcAV(a0)
EcO1:	cmp.l	#EntNul,d3
	beq.s	EcO2
	move.w	d3,EcAVY(a0)
	bset	#2,EcAV(a0)
EcO2:	bra.s	EcTu

******* HIDE/SHOW ecran D1,d2
EcHide:	bsr	EcGet
	beq	EcME
	move.l	d0,a0
	tst.w	EcDual(a0)		* Pas DUAL PLAYFIELD
	bmi.s	EcTut
	bclr	#BitHide,EcFlags(a0)
	tst.w	d2
	beq.s	EcTut
	bset	#BitHide,EcFlags(a0)
EcTut:	addq.w	#1,T_EcYAct(a5)
EcTu:	bset	#BitEcrans,T_Actualise(a5)
	moveq	#0,d0
	rts

***********************************************************
*	GESTION DE L'AUTOBACK!
******* AUTOBACK 1
TAbk1:	movem.l	a3-a6,-(sp)
	move.l	W_Base(pc),a5
	move.l	T_EcCourant(a5),a0
	move.w	EcAuto(a0),d0
	subq.w	#1,d0
	ble.s	TAbk1X
	bsr	WVbl
	bsr	BobEff
TAbk1X:	movem.l	(sp)+,a3-a6
	rts
******* AUTOBACK 2
TAbk2	move.l	W_Base(pc),a1
	move.l	T_EcCourant(a1),a0
	move.w	EcAuto(a0),d0
	subq.w	#1,d0
	bmi.s	TAbk2X
	bne.s	TAbk2B
* Autoback simple---> change le rastport / current
	moveq	#EcMaxPlans-1,d0
	move.l	Ec_BitMap(a0),a1
	addq.l	#8,a1
	lea	EcCurrent(a0),a2
	lea	EcPhysic(a0),a0
TAbk2A	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,TAbk2A
TAbk2X	rts
* Autoback total---> screen swap
TAbk2B	movem.l	a3-a6,-(sp)
	move.l	a1,a5
	bsr	BobAct
	bsr	BobAff
	bsr	ScSwapS
	bsr	WVbl
	bsr	BobEff
	movem.l	(sp)+,a3-a6
	rts
******* AUTOBACK 3
TAbk3	move.l	W_Base(pc),a1
	move.l	T_EcCourant(a1),a0
	move.w	EcAuto(a0),d0
	subq.w	#1,d0
	bmi.s	TAbk3X
	bne.s	TAbk3B
* Simple ---> remet le rasport / current
	moveq	#EcMaxPlans-1,d0
	move.l	Ec_BitMap(a0),a1
	addq.l	#8,a1
	lea	EcCurrent(a0),a2
	lea	EcLogic(a0),a0
TAbk3A	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,TAbk3A
TAbk3X	rts
* Total ---> Re screen swap!
TAbk3B	movem.l	a3-a6,-(sp)
	move.l	a1,a5
	bsr	BobAct
	bsr	BobAff
	bsr	ScSwapS
	bsr	WVbl
	bclr	#BitBobs,T_Actualise(a5)
	movem.l	(sp)+,a3-a6
	rts
******* AUTOBACK 4 -> ecrans single buffer!
TAbk4:	movem.l	a3-a6,-(sp)
	move.l	W_Base(pc),a5
	move.l	T_EcCourant(a5),a0
	move.w	EcAuto(a0),d0
	subq.w	#1,d0
	ble.s	TAbk4X
	bsr	BobAct
	bsr	BobAff
TAbk4X:	movem.l	(sp)+,a3-a6
	rts

***********************************************************
*	CLS
*	D1= Couleur
*	D2= X
*	D3= Y
*	D4= X2
*	D5= Y2
EcCls:	movem.l	d1-d7/a0/a1/a5/a6,-(sp)
	move.l	T_EcCourant(a5),a5
	tst.w	d2
	bpl.s	Cls5b
	moveq	#0,d2
Cls5b:	cmp.w	EcTx(a5),d2
	bls.s	Cls5c
	move.w	EcTx(a5),d2
Cls5c:	tst.w	d3
	bpl.s	Cls5d
	moveq	#0,d3
Cls5d:	cmp.w	EcTy(a5),d3
	bls.s	Cls5e
	move.w	EcTy(a5),d3
Cls5e:	tst.w	d4
	bpl.s	Cls5f
	moveq	#0,d4
Cls5f:	cmp.w	EcTx(a5),d4
	bls.s	Cls5g
	move.w	EcTx(a5),d4
Cls5g:	tst.w	d5
	bpl.s	Cls5h
	moveq	#0,d5
Cls5h:	cmp.w	EcTy(a5),d5
	bls.s	Cls5i
	move.w	EcTy(a5),d5
Cls5i:	cmp.w	d2,d4
	bls	Cls5x
	sub.w	d3,d5
	bls	Cls5x
* Gestion de l'autoback!
	tst.w	EcAuto(a5)
	beq.s	Cls5W
	movem.l	d0-d7/a0-a2,-(sp)
	bsr	TAbk1
	movem.l	(sp),d0-d7/a0-a2
	bsr	ClsR
	bsr	TAbk2
	movem.l	(sp)+,d0-d7/a0-a2
	bsr	ClsR
	bsr	TAbk3
	bra.s	Cls5X
Cls5W	bsr	ClsR
Cls5X:	movem.l	(sp)+,d1-d7/a0/a1/a5/a6
	moveq	#0,d0
	rts

* Routine d'effacement!
ClsR:	lea	Circuits,a6
	bsr	OwnBlit
	lea	MCls(pc),a0		* Masques
	move.w	d2,d0
	and.w	#$000F,d0
	lsl.w	#1,d0
	move.w	0(a0,d0.w),BltMaskG(a6)
	moveq	#0,d6
	moveq	#-1,d7
	move.w	d4,d0
	and.w	#$000F,d0
	beq.s	Cls5j
	moveq	#1,d6
	lsl.w	#1,d0
	move.w	0(a0,d0.w),d7
	not.w	d7
Cls5j:	move.w	d7,BltMaskD(a6)
	lsr.w	#4,d2			* Taille en X
	lsr.w	#4,d4
	sub.w	d2,d4
	add.w	d6,d4
	lsl.w	#6,d5			* Taille blitter
	or.w	d4,d5
	move.w	EcTLigne(a5),d0		* Adresse ecran
	mulu	d0,d3
	lsl.w	#1,d2
	ext.l	d2
	add.l	d2,d3
	lsl.w	#1,d4			* Mod C et D
	sub.w	d4,d0
	move.w	d0,BltModC(a6)
	move.w	d0,BltModD(a6)
	lea	EcCurrent(a5),a0
	move.w	#%0000001111001010,BltCon0(a6)
	clr.w	BltCon1(a6)
	move.w	#-1,BltDatA(a6)
	move.w	EcNPlan(a5),d7
	subq.w	#1,d7
	moveq	#-1,d6

Cls5k:	moveq	#0,d0
	lsr.w	#1,d1
	subx.w	d0,d0
	move.w	d0,BltDatB(a6)
	move.l	(a0)+,a1
	lsr.w	#1,d6
	bcc.s	Cls5m
	add.l	d3,a1
	move.l	a1,BltAdC(a6)
	move.l	a1,BltAdD(a6)
	move.w	d5,BltSize(a6)
Cls5l:	bsr	BlitWait
Cls5m:	dbra	d7,Cls5k
* Remet le blitter et revient
	bra	DOwnBlit

******* Table des masques
MCls:	dc.w	%1111111111111111
	dc.w 	%0111111111111111
	dc.w 	%0011111111111111
	dc.w	%0001111111111111
	dc.w	%0000111111111111
	dc.w	%0000011111111111
	dc.w	%0000001111111111
	dc.w	%0000000111111111
	dc.w	%0000000011111111
	dc.w	%0000000001111111
	dc.w	%0000000000111111
	dc.w	%0000000000011111
	dc.w	%0000000000001111
	dc.w	%0000000000000111
	dc.w	%0000000000000011
	dc.w	%0000000000000001
MCls2:	dc.w	%0000000000000000
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w 	%0011111111111111
	dc.w 	%0111111111111111

;	Active l'ecran D1 - si pas ecran CLONE!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EcMarch	bsr	EcGet
	beq.s	EcME
	move.l	d0,a0
	btst	#BitClone,EcFlags(a0)
	bne.s	EcCl
	bsr	Ec_Active
EcMOk	moveq	#0,d0
	rts
EcME	moveq	#3,d0
	rts
EcCl	moveq	#4,d0
	rts

;	Routine d'activation de l'ecran A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ec_Active
	move.l	a0,T_EcCourant(a5)
	move.l	a0,d0
	beq.s	.Skip
	move.l	Ec_RastPort(a0),T_RastPort(a5)
	move.l	a1,-(sp)
	lea	WRastPort(pc),a1
	move.l	Ec_RastPort(a0),(a1)
	move.l	(sp)+,a1
.Skip	rts

******* RETURNS CURRENT USERS SCREEN ADDRESS
EcCrnt	move.l	T_EcCourant(a5),a0
	move.w	EcNumber(a0),d0
	cmp.w	#8,d0
	bcs.s	EcCr
	moveq	#-1,d0
EcCr:	rts

******* ADRESSE ECRAN D1
EcAdres	cmp.w	#8,d1
	bcs	EcGet
	moveq	#0,d0
	rts

******* SET COLOUR D1,D2
EcSCol:	move.l	T_EcCourant(a5),a0
	and.w	#31,d1
	lsl.w	#1,d1
	and.w	#$FFF,d2
	move.w	d2,EcPal(a0,d1.w)
* Poke dans le copper
	lsl.w	#1,d1
	move.w	EcNumber(a0),d0
	lsl.w	#7,d0
	lea	T_CopMark(a5),a0
	add.w	d0,a0
	cmp.w	#PalMax*4,d1
	bcs.s	ECol0
	lea	64(a0),a0
ECol0:	move.l	(a0)+,d0
	beq.s	ECol1
	move.l	d0,a1
	move.w	d2,2(a1,d1.w)
	bra.s	ECol0
ECol1:	moveq	#0,d0
	rts

******* GET COLOUR D1
EcGCol:	move.l	T_EcCourant(a5),a0
	and.l	#31,d1
	lsl.w	#1,d1
	move.w	EcPal(a0,d1.w),d1
	moveq	#0,d0
	rts

******* SET PALETTE A1
EcSPal	movem.l	a2-a3/d2-d4,-(sp)
	move.l	T_EcCourant(a5),a0
	move.w	EcNumber(a0),d2
	lsl.l	#7,d2
	lea	T_CopMark(a5),a2
	add.w	d2,a2
	move.l	a2,d2
	lea	EcPal(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#31,d4
* Boucle de pokage
EcSP1	move.w	(a1)+,d1
	bmi.s	EcSP3
	and.w	#$FFF,d1
* Poke dans la table
	move.w	d1,(a0)
* Poke dans le copper
	move.l	d2,a2
	cmp.w	#PalMax*4,d0
	bcs.s	EcSP2
	lea	64(a2),a2
EcSP2:	move.l	(a2)+,d3
	beq.s	EcSP3
	move.l	d3,a3
	move.w	d1,2(a3,d0.w)
	bra.s	EcSP2
EcSP3:	addq.l	#2,a0
	addq.w	#4,d0
	dbra	d4,EcSP1
	movem.l	(sp)+,a2-a3/d2-d4
	moveq	#0,d0
	rts

******* COLOUR BACK D1
EcSColB	and.w	#$FFF,d1
	move.w	d1,T_EcFond(a5)
	moveq	#0,d0
	rts


******* RAINBOW HIDE
TRHide	tst.w	d1
	bpl.s	Trh
	move.w	T_Rainbow(a5),T_OldRain(a5)
	clr.w	T_RainBow(a5)
	rts
Trh:	move.w	T_OldRain(a5),T_RainBow(a5)
	rts

******* Adresse RainBow
RainAd	move.l	d1,d0
	bmi	RainEr
	cmp.w	#NbRain,d0
	bcc	RainEr
	mulu	#RainLong,d0
	lea	T_RainTable(a5),a0
	add.w	d0,a0
	moveq	#0,d0
	rts
RainEr	moveq	#1,d0
	rts

******* DO RAINBOW
*	D1=	#Rainbow
*	D2=	Base
*	D3=	Debut
*	D4=	Taille
TRDo	bsr	RainAd
	bne	RainEr
	move.b	RnAct(a0),d0
	tst.w	RnLong(a0)
	beq.s	RainEr
	move.l	#EntNul,d5
	cmp.l	d2,d5
	beq.s	TRDo1
	move.w	d2,RnX(a0)
	bset	#1,d0
TRDo1	cmp.l	d3,d5
	beq.s	TRDo2
	move.w	d3,RnY(a0)
	bset	#2,d0
TRDo2	cmp.l	d4,d5
	beq.s	TRDo3
	move.w	d4,RnI(a0)
	bset	#0,d0
TRDo3	move.b	d0,RnAct(a0)
* Force l'actualisation
RainAct	bset	#BitEcrans,T_Actualise(a5)
	moveq	#0,d0
	rts

******* ADRESSE VAR RAINBOW
TRVar	bsr	RainAd
	bne	RainEr
	move.l	RnBuf(a0),d0
	beq	RainEr
	move.l	d0,a1
	tst.l	d2
	bmi	RainEr
	lsl.w	#1,d2
	cmp.w	RnLong(a0),d2
	bcc	RainEr
	add.w	d2,a1
	move.l	a1,a0
	moveq	#0,d0
	rts

******* SET RAINBOW
*	D1= Numero
*	D2= Nb de lignes
*	D3= Couleur modifiee
*	D4= Chaine R
*	D5= Chaine G
*	D6= Chaine B
*	D7= Valeur de depart
TRSet
	clr.l	T_AMALSp(a5)

* Efface l'ancien
	bsr	RnDel
	bne	RainEr

* Cree le nouveau
	bsr	RainAd
	movem.l	d1-d7/a1-a3,-(sp)
	move.l	sp,a3
	move.l	a0,a1
	and.w	#31,d3			* Couleur du rainbow
	cmp.w	#PalMax,d3
	bcc	TrSynt
	move.w	d3,RnColor(a1)
	move.w	d7,d3
	move.w	d2,d0			* Reserve le buffer
	ext.l	d0
	lsl.l	#1,d0
	move.w	d0,d1
	bsr	FastMm2
	beq	TROmm
	move.l	d0,RnBuf(a1)
	move.w	d1,RnLong(a1)
	clr.w	RnAct(a0)		* Rien a faire pour le moment
	move.w	#-1,RnI(a0)		* Rien � afficher
	clr.w	RnX(a0)			* Position base
	clr.w	RnY(a0)			* Position Y
	clr.l	RnDY(a0)		* Rien en route!
	clr.w	RnTY(a0)		* Vraiment rien!

	move.l	d0,a2
	move.l	Buffer(a5),a1
	move.l	a1,-(sp)		* 12(sp)-> Base
	clr.w	-(sp)			* 10(sp)-> Position
	move.w	#1,-(sp)		*  8(sp)-> Nb Mvt
	clr.w	-(sp)			*  6(sp)-> Vitesse
	move.w	#1,-(sp)		*  4(sp)-> Cpt
	clr.w	-(sp)			*  2(sp)-> Plus
	move.w	d3,d0
	and.w	#$000F,d0
	move.w	d0,-(sp)		*  0(sp)-> Valeur!
	move.l	d6,a0
	bsr	RainTok
	bne	TrSynt

	move.l	a1,-(sp)		* 12(sp)-> Base
	clr.w	-(sp)			* 10(sp)-> Position
	move.w	#1,-(sp)		*  8(sp)-> Nb Mvt
	clr.w	-(sp)			*  6(sp)-> Vitesse
	move.w	#1,-(sp)		*  4(sp)-> Cpt
	clr.w	-(sp)			*  2(sp)-> Plus
	move.w	d3,d0
	lsr.w	#4,d0
	and.w	#$000F,d0
	move.w	d0,-(sp)		*  0(sp)-> Valeur!
	move.l	d5,a0
	bsr	RainTok
	bne	TrSynt

	move.l	a1,-(sp)		* 12(sp)-> Base
	clr.w	-(sp)			* 10(sp)-> Position
	move.w	#1,-(sp)		*  8(sp)-> Nb Mvt
	clr.w	-(sp)			*  6(sp)-> Vitesse
	move.w	#1,-(sp)		*  4(sp)-> Cpt
	clr.w	-(sp)			*  2(sp)-> Plus
	lsr.w	#8,d3
	and.w	#$000F,d3
	move.w	d3,-(sp)		*  0(sp)-> Valeur!
	move.l	d4,a0
	bsr	RainTok
	bne	TrSynt

	subq.w	#1,d2
* Rempli la table
Trs1	move.l	sp,a0
	moveq	#2,d0
Trs2	tst.w	4(a0)
	beq.s	Trs5
	subq.w	#1,4(a0)
	bne.s	Trs5
	move.w	6(a0),4(a0)
	move.w	2(a0),d1
	add.w	(a0),d1
	and.w	#$000F,d1
	move.w	d1,(a0)
	tst.w	8(a0)
	beq.s	Trs5
	subq.w	#1,8(a0)
	bne.s	Trs5
	move.w	10(a0),d1
	move.l	12(a0),a1
Trs3	move.w	0(a1,d1.w),4(a0)
	bpl.s	Trs4
	clr.w	d1
	bra.s	Trs3
Trs4	move.w	4(a0),6(a0)
	move.w	2(a1,d1.w),2(a0)
	move.w	4(a1,d1.w),8(a0)
	addq.l	#6,d1
	move.w	d1,10(a0)
Trs5	lea	16(a0),a0
	dbra	d0,Trs2
	move.w	(sp),d0
	lsl.w	#8,d0
	move.w	16(sp),d1
	lsl.w	#4,d1
	or.w	d1,d0
	or.w	32(sp),d0
	move.w	d0,(a2)+
	dbra	d2,Trs1
	move.w	#1,T_RainBow(a5)
	moveq	#0,d0
* A y est!
TrOut	move.l	a3,sp
	movem.l	(sp)+,d1-d7/a1-a3
	rts
* Out of mem!
TrOMm	moveq	#-1,d0
	bra.s	TrOut
* Syntax error!
TrSynt	move.l	a3,sp
	movem.l	(sp)+,d1-d7/a1-a3
	bsr	TRDel
	moveq	#1,d0
	rts

******* Tokenisation RAINBOW
RainTok	movem.l	a2/d1-d4,-(sp)
	clr.l	(a1)
	clr.w	4(a1)
	move.w	(a0)+,d0
	lea	0(a0,d0.w),a2
	move.b	(a2),d4
	clr.b	(a2)
	bsr	AniChr
	beq.s	RainT2
RainT1	cmp.b	#"(",d0
	bne.s	RainTE
	bsr	AniLong
	ble	RainTE
	move.w	d0,(a1)+
	bsr	AniChr
	cmp.b	#",",d0
	bne	RainTE
	bsr	AniLong
	move.w	d0,(a1)+
	bsr	AniChr
	cmp.b	#",",d0
	bne	RainTE
	bsr	AniLong
	blt	RainTE
	move.w	d0,(a1)+
	bsr	AniChr
	cmp.b	#")",d0
	bne	RainTE
	move.w	#-1,(a1)
	clr.l	2(a1)
	bsr	AniChr
	bne.s	RainT1
RainT2	addq.l	#6,a1
	move.b	d4,(a2)
	movem.l	(sp)+,a2/d1-d4
	moveq	#0,d0
	rts
RainEE	addq.l	#4,sp
RainTE	move.b	d4,(a2)
	movem.l	(sp)+,a2/d1-d4
	moveq	#1,d0
	rts

******* Effacement RAINBOW D1
TRDel	tst.l	d1
	bpl.s	RnDel
	clr.w	T_RainBow(a5)
	clr.w	T_OldRain(a5)
	moveq	#NbRain-1,d1
TRDel0	bsr	RnDel
	bne	RainEr
	subq.w	#1,d1
	bne.s	TRDel0
* Routine!
RnDel:	bsr	RainAd
	bne	RainEr
	move.l	a1,-(sp)
	tst.l	RnBuf(a0)
	beq.s	RnDel1
	clr.l	(a0)
	move.l	RnBuf(a0),a1
	clr.l	RnBuf(a0)
	move.w	RnLong(a0),d0
	clr.w	RnLong(a0)
	ext.l	d0
	bsr	FreeMm
RnDel1	movem.l	(sp)+,a1
	moveq	#0,d0
	rts

***********************************************************
*-----*	Ss programme ---> adresse d'un ecran
EcGet:	move.w	d1,d0
	lsl.w	#2,d0
	lea	T_EcAdr(a5),a0
	add.w	d0,a0
	move.l	(a0),d0
	rts
EcGE:	moveq	#0,d0
	rts

******* Trouve le premier ecran libre
EcLibre:lea	T_EcAdr(a5),a0
	moveq	#-1,d1
EcL:	addq.l	#1,d1
	tst.l	(a0)+
	beq.s	EcGE
	cmp.w	#EcMax,d1
	bcs.s	EcL
	moveq	#-1,d0
	rts

;	SET CLIP ecran courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TSClip:	move.l	T_EcCourant(a5),a0
	tst.w	d1
	bpl.s	SClip1
; RAZ clipping!
; ~~~~~~~~~~~~~
	moveq	#0,d0
	moveq	#0,d1
	move.w	EcTx(a0),d2
	move.w	EcTy(a0),d3
	bra.s	SClipX
; Clippe!
; ~~~~~~~
SClip1	move.l	#Entnul,d0
	cmp.l	d0,d2
	bne.s	SClip2
	moveq	#0,d2
	move.w	EcClipX0(a0),d2
SClip2	cmp.l	d0,d3
	bne.s	SClip3
	moveq	#0,d3
	move.w	EcClipY0(a0),d3
SClip3	cmp.l	d0,d4
	bne.s	SClip4
	moveq	#0,d4
	move.w	EcClipX1(a0),d4
SClip4	cmp.l	d0,d5
	bne.s	SClip5
	moveq	#0,d5
	move.w	EcClipY1(a0),d5
SClip5:	tst.l	d2
	bmi.s	SClipE
	tst.l	d3
	bmi.s	SClipE
	move.w	EcTx(a0),d0
	ext.l	d0
	cmp.l	d0,d4
	bhi.s	SClipE
	move.w	EcTy(a0),d0
	cmp.l	d0,d5
	bhi.s	SClipE
	cmp.l	d2,d4
	ble.s	SClipE
	cmp.l	d3,d5
	ble.s	SClipE
	move.w	d2,d0
	move.w	d3,d1
	move.w	d4,d2
	move.w	d5,d3
SClipX	bsr	Ec_SetClip
	moveq	#0,d0
	rts
SClipE:	moveq	#1,d0
	rts


;	Change le clip rectangle dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ec_SetClip
	movem.l	d2-d4/a4/a6,-(sp)
	move.l	T_EcCourant(a5),a4
	tst.l	Ec_Region(a4)
	bne.s	.Deja

; Faut-il creer un cliprect?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EcClipX0(a4),a0
	cmp.w	(a0)+,d0
	bne.s	.Nou
	cmp.w	(a0)+,d1
	bne.s	.Nou
	cmp.w	(a0)+,d2
	bne.s	.Nou
	cmp.w	(a0)+,d3
	beq.s	.Exit

; Installe la clipping region
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Nou	movem.w	d0-d3,-(sp)			Sauve
	movem.w	d0-d3,-(sp)			Pour structure
	subq.w	#1,4(sp)
	subq.w	#1,6(sp)
	move.l	T_GfxBase(a5),a6
	jsr	_LVONewRegion(a6)		Prend une nouvelle region
	move.l	d0,Ec_Region(a4)
	beq.s	.Out				Out of memory
	move.l	sp,a1
	move.l	d0,a0
	jsr	_LVOOrRectRegion(a6)
	tst.l	d0
	beq.s	.Out
	move.l	T_LayBase(a5),a6		Installe le CLIP
	move.l	Ec_Layer(a4),a0
	move.l	Ec_Region(a4),a1
	jsr	_LVOInstallClipRegion(a6)
	addq.l	#8,sp
	movem.w	(sp)+,d0-d3

; Poke dans les structures
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Deja	lea	EcClipX0(a4),a0
	movem.w	d0-d3,(a0)
	subq.w	#1,d2
	subq.w	#1,d3
	move.l	Ec_Layer(a4),a0			Layer
	move.l	8(a0),a0			ClipRect
	movem.w	d0-d3,16(a0)			Poke les nouveaux!
	bra.s	.Exit

.Out	addq.l	#8,sp
	movem.w	(sp)+,d0-d3
.Exit	movem.l	(sp)+,d2-d4/a4/a6
	rts

******* PAINT non crashant!!!
*	D1= X
*	D2= Y
*	D3= couleur
*	D4= Mode
*	D5= Buffer 1024 octets
PntTBuf	equ 	2048
PntPos	equ	EcCurs
PntDeb	equ	EcCurs+4
TPaint	movem.l	d1-d7/a0-a6,-(sp)
	move.w	d1,a2
	move.w	d2,a3
	move.l	d5,a1
	move.l	T_EcCourant(a5),a5
	move.l	EcCurs(a5),-(sp)	* Room for addresses!
	move.l	EcCurs+4(a5),-(sp)
	moveq	#0,d7
	cmp.w	EcClipX0(a5),a2
	bcs	NoPaint
	cmp.w	EcClipX1(a5),a2
	bcc	NoPaint
	cmp.w	EcClipY0(a5),a3
	bcs	NoPaint
	cmp.w	EcClipY1(a5),a3
	bcc	NoPaint
	move.l	WRastPort(pc),a4
	move.l	12(a4),d0
	beq	NoPaint
	move.l	d0,a4
* Calcul des parametres blitter
	move.w	d3,-(sp)
	move.w	EcClipX1(a5),d6
	add.w	#15,d6
	and.w	#$FFF0,d6
	move.w	EcClipX0(a5),d1
	and.w	#$FFF0,d1
	move.w	d1,d2
	sub.w	d1,d6
	lsr.w	#4,d6
	move.w	EcClipY1(a5),d1
	sub.w	EcClipY0(a5),d1
	move.w	d1,d3
	lsl.w	#6,d1
	or.w	d6,d1
	move.w	d1,-(sp)		* Largeur/hauteur blitter
	ext.l	d6
	lsl.w	#1,d6			* Delta ligne carre
	move.w	EcTLigne(a5),d1
	sub.w	d6,d1
	move.w	d1,-(sp)		* Modulo origine
	move.w	EcClipY0(a5),d0
	mulu	EcTLigne(a5),d0
	lsr.w	#3,d2
	add.w	d2,d0
	move.w	d0,-(sp)		* Adresse depart carre
	mulu	d6,d3			* Verifie la taille du tempras
	cmp.l	4(a4),d3
	bhi	PntE2
	move.l	(a4),a4
* Met a UN toutes les couleurs AUTRES!!!
	move.w	#%11110000,d3
	move.w	#%00001111,d4
	move.w	#%11111100,d5
	move.w	#%11001111,d7
	bsr	PMask

******* PAINT LOOP!
	moveq	#0,d5
	bset	#13,d5
	lea	1024-16*4-16(a1),a0
	move.l	a0,d1
	move.l	a1,PntPos(a5)
	move.l	a1,PntDeb(a5)
	moveq	#15,d0
Pnt0	clr.l	(a1)+
	dbra	d0,Pnt0
	moveq	#-1,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.w	#-1,(a1)+
	clr.w	(a1)+

	move.w	EcClipX0(a5),d4
	sub.w	d4,a2
	move.w	EcClipX1(a5),d2
	sub.w	d4,d2
	and.w	#$000F,d4
	move.w	EcClipY1(a5),d3
	sub.w	EcClipY0(a5),d3
	sub.w	EcClipY0(a5),a3
* Screen adress
Pnt1	move.w	a3,d0
	mulu	d6,d0
	move.w	a2,d7
	add.w	d4,d7
	ror.l	#3,d7
	add.w	d7,d0
	rol.l	#3,d7
	and.w	#7,d7
	neg.w	d7
	addq.w	#7,d7
	lea	0(a4,d0.l),a0
* Go to the left
	bset	#15,d5
	bset	#14,d5
	bset	#13,d5
	beq.s	Pnt5
Pnt2	subq.w	#1,a2
	addq.w	#1,d7
	cmp.w	#8,d7
	bcs.s	Pnt3
	moveq	#0,d7
	subq.l	#1,a0
Pnt3	btst	d7,(a0)
	bne.s	Pnt4
	cmp.w	d2,a2
	bcc.s	Pnt4
	cmp.w	d3,a3
	bcs.s	Pnt2
* Go to the right
Pnt4	addq.w	#1,a2
	subq.w	#1,d7
	bcc.s	Pnt5
	moveq	#7,d7
	addq.l	#1,a0
* Look UP
Pnt5	subq.w	#1,a3
	sub.l	d6,a0
	btst	d7,(a0)
	bne.s	Pnt6
	cmp.w	d3,a3
	bcc.s	Pnt6
	bclr	#15,d5
	beq.s	Pnt7
	move.w	a2,(a1)+
	move.w	a3,(a1)
	or.w	d5,(a1)+
	cmp.l	d1,a1
	bcs.s	Pnt7
	bsr	PntNBuf
	bra.s	Pnt7
Pnt6	bset	#15,d5
* Plot in the middle
Pnt7	addq.w	#1,a3
	add.l	d6,a0
	bset	d7,(a0)
* Look down
	addq.w	#1,a3
	btst	d7,(a0,d6.l)
	bne.s	Pnt8
	cmp.w	d3,a3
	bcc.s	Pnt8
	bclr	#14,d5
	beq.s	Pnt9
	move.w	a2,(a1)+
	move.w	a3,(a1)
	or.w	d5,(a1)+
	cmp.l	d1,a1
	bcs.s	Pnt9
	bsr	PntNBuf
	bra.s	Pnt9
Pnt8	bset	#14,d5
* One pixel to the right?
Pnt9	bclr	#13,d5
	subq.w	#1,a3
	addq.w	#1,a2
	subq.w	#1,d7
	bcc.s	Pnt10
	moveq	#7,d7
	addq.l	#1,a0
* Fait un essai FAST
	move.w	a0,d0
	btst	#0,d0
	bne.s	PntFX
	move.w	a2,d0
	add.w	#15,d0
	cmp.w	d2,d0
	bcc.s	PntFX
	move.w	a3,d0
	beq.s	PntFX
	addq.w	#1,d0
	cmp.w	d3,d0
	bcc.s	PntFX
	move.l	d1,-(sp)
	moveq	#-1,d0
	btst	#15,d5
	bne.s	PntF1
	moveq	#0,d0
PntF1	moveq	#-1,d1
	btst	#14,d5
	bne.s	PntF2
	moveq	#0,d1
PntF2	tst.w	(a0)
	bne.s	PntF3
	cmp.w	(a0,d6.l),d1
	bne.s	PntF3
	sub.l	d6,a0
	cmp.w	(a0),d0
	add.l	d6,a0
	bne.s	PntF3
	move.w	#-1,(a0)+
	lea	16(a2),a2
	cmp.w	d2,a2
	bcs.s	PntF2
PntF3	move.l	(sp)+,d1
PntFX
* A droite!
Pnt10	btst	d7,(a0)
	bne.s	Pnt11
	cmp.w	d2,a2
	bcc.s	Pnt11
	cmp.w	d3,a3
	bcs	Pnt5
* Change line!
Pnt11	move.w	-(a1),d5
	move.w	d5,d0
	and.w	#%0001111111111111,d0
	move.w	d0,a3
	and.w	#%1110000000000000,d5
	move.w	-(a1),d0
	move.w	d0,a2
	bpl	Pnt1
	subq.l	#4,PntPos(a5)
	move.l	-(a1),d1
	move.l	-(a1),a1
	bpl.s	Pnt11

******* Masks the tempras
	move.w	#%00001100,d3
	move.w	#%11000000,d4
	move.w	d3,d5
	move.w	d4,d7
	bsr	PMask

******* Copper copy!
* Initialisation
	bsr	OwnBlit
	move.w	#-1,BltMaskG(a6)
	move.w	#-1,BltMaskD(a6)
	move.w	2(sp),d0
	move.w	d0,BltModC(a6)
	move.w	d0,BltModD(a6)
	clr.w	BltModA(a6)
	move.w	#%0000101111001010,BltCon0(a6)
	clr.w	BltCon1(a6)

	lea	EcCurrent(a5),a0
	move.l	WRastPort(pc),a1
	move.b	25(a1),d7
	move.b	26(a1),d6
	move.w	EcNPlan(a5),d5
	move.w	4(sp),d3
	and.w	#%0111111,d3
	or.w	#%1000000,d3

* Calcul des patterns
	lea	FoPat(pc),a2
	move.l	a2,a3
	sub.l	a5,a5
	move.l	8(a1),d0
	beq.s	PntP4
	move.l	d0,a2
	moveq	#1,d2
	move.b	29(a1),d0
	move.b	d0,d1
	bpl.s	PntP2
	neg.b	d1
PntP2	lsl.w	#1,d2
	subq.b	#1,d1
	bne.s	PntP2
PntP3	lsl.w	#1,d2
	lea	0(a2,d2.w),a3
	tst.b	d0
	bpl.s	PntP4
	move.l	d2,a5
PntP4

* Fait un plan
PntCc1	bsr	BlitWait
	move.l	a2,a1
	moveq	#0,d0
	move.w	(sp),d0
	add.l	(a0)+,d0
	move.l	d0,BltAdC(a6)
	move.l	d0,BltAdD(a6)
	move.l	a4,BltAdA(a6)
	move.w	4(sp),d4
	lsr.w	#6,d4
* Fait une ligne
PntCc2	moveq	#0,d0
	roxr.w	#1,d7
	subx.w	d0,d0
	roxl.w	#1,d7
	move.w	(a1)+,d1
	and.w	d1,d0
	not.w	d1
	moveq	#0,d2
	roxr.w	#1,d6
	subx.w	d2,d2
	roxl.w	#1,d6
	and.w	d2,d1
	or.w	d1,d0
	bsr	BlitWait
	move.w	d0,BltDatB(a6)
	move.w	d3,BltSize(a6)
	cmp.l	a3,a1
	bcs.s	PntCc3
	move.l	a2,a1
PntCc3	subq.w	#1,d4
	bne.s	PntCc2
	add.l	a5,a2
	add.l	a5,a3
	lsr.w	#1,d6
	lsr.w	#1,d7
	subq.w	#1,d5
	bne.s	PntCc1
	bsr	DOwnBlit
******* Copper copy!
PntEnd	moveq	#0,d7
PntE1	move.l	W_Base(pc),a5
	move.l	T_EcCourant(a5),a5
	bsr	PntDBuf
PntE2	addq.l	#8,sp
NoPaint	move.l	d7,d1
	move.l	(sp)+,EcCurs+4(a5)
	move.l	(sp)+,EcCurs(a5)
	movem.l	(sp)+,d1-d7/a0-a6
	rts
* Erreur!
PntErr	moveq	#-1,d7
	bra.s	PntE1

******* Routine, masque la zone dessin
PMask	lea	$Dff000,a6
	bsr	OwnBlit
	lea	EcCurrent(a5),a0
	move.w	4+6(sp),d0
	move.w	EcNPlan(a5),d1
PMsk1	move.w	#-1,BltMaskG(a6)
	move.w	#-1,BltMaskD(a6)
	moveq	#0,d2
	move.w	4(sp),d2
	add.l	(a0)+,d2
	move.l	d2,BltAdA(a6)
	move.w	4+2(sp),BltModA(a6)
	move.l	a4,BltAdB(a6)
	clr.w	BltModB(a6)
	move.l	a4,BltAdD(a6)
	clr.w	BltModD(a6)
	move.w	d3,d2
	lsr.w	#1,d0
	bcc.s	PMsk2
	move.w	d4,d2
PMsk2	or.w	#%0000110100000000,d2
	move.w	d2,BltCon0(a6)
	clr.w	BltCon1(a6)
	move.w	4+4(sp),BltSize(a6)
	move.w	d5,d3
	move.w	d7,d4
	bsr	BlitWait
	subq.w	#1,d1
	bne.s	PMsk1
	bra	DOwnBlit

******* Reserves a new buffer!
PntNBuf	movem.l	a0/a2/a3,-(sp)
	move.l	PntPos(a5),a2
	move.l	(a2),d0
	bmi.s	PntMem
	bne.s	PntB1
	move.l	#PntTBuf,d0
	bsr	FastMM2
	beq.s	PntMem
PntB1	move.l	d0,(a2)+
	move.l	a2,PntPos(a5)
	exg	d0,a1
	move.l	d1,(a1)+
	move.l	d0,(a1)+
	move.w	#-2,(a1)+
	clr.w	(a1)+
	lea	PntTBuf-16(a1),a0
	move.l	a0,d1
	movem.l	(sp)+,a0/a2/a3
	rts
PntMem	lea	12+4(sp),sp
	bra	PntErr
******* Erases all new buffers
PntDBuf	move.l	PntDeb(a5),a2
PntDb0	move.l	(a2)+,d0
	bmi.s	PntDb1
	beq.s	PntDb1
	move.l	d0,a1
	move.l	#PntTBuf,d0
	bsr	FreeMM
	bra.s	PntDb0
PntDb1	rts

******* SET PATTERN ecran courant!
SPat:	movem.l	d1-d7/a0-a6,-(sp)
* Efface l'ancien
	bsr	EffPat
* Met le nouveau
	tst.w	d1
	beq	SPatX
	bmi.s	SPat1
* Patterns charge avec la banque!
	move.l	T_MouBank(a5),a2
	moveq	#4,d2
	bsr	SoMouse
	bmi	SPatE
	subq.w	#1,d1
	beq.s	SPat2
	move.w	d1,d2
	bsr	SoMouse
	bmi	SPatE
	bra.s	SPat2
* Patterns dans la banque de sprites!
SPat1:	move.l	T_SprBank(a5),d0
	beq	SPatX
	move.l	d0,a2
	neg.w	d1
	cmp.w	(a2)+,d1
	bhi	SPatX
	lsl.w	#3,d1
	move.l	-8(a2,d1.w),d0
	beq	SPatX
	move.l	d0,a2
******* Change!
SPat2:	move.w	(a2)+,d4
	move.w	(a2)+,d5
	move.w	(a2)+,d6
	addq.l	#4,a2
	moveq	#1,d0
	moveq	#0,d3
SPat3:	cmp.w	d5,d0			* Cherche le multiple de 8 <= TY
	beq.s	SPat5
	bcc.s	SPat4
	lsl.w	#1,d0
	addq.w	#1,d3
	cmp.w	#8,d3
	bcs.s	SPat3
	bra.s	SPatE
SPat4:	subq.w	#1,d3
	beq.s	SPatE
	lsr.w	#1,d0
SPat5:	move.w	d0,d7
	cmp.w	#1,d6
	beq.s	SPat6
	neg.b	d3
SPat6:	lsl.w	#1,d0
	mulu	d6,d0
	move.w	d0,d1
	bsr	ChipMm
	beq	SPatE
	move.l	T_EcCourant(a5),a0	* Poke!
	move.l	d0,EcPat(a0)
	move.w	d1,EcPatL(a0)
	move.b	d3,EcPatY(a0)
	move.l	T_RastPort(a5),a0
	move.l	d0,8(a0)
	move.b	d3,29(a0)
* Copie le motif
	move.l	d0,a1
	subq.w	#1,d6
	lsl.w	#1,d2
	lsl.w	#1,d4
	mulu	d4,d5
	subq.w	#1,d7
SPat7:	move.w	d7,d3
	move.l	a2,a0
SPat8:	move.w	(a0),(a1)+
	add.w	d4,a0
	dbra	d3,SPat8
SPat9:	add.w	d5,a2
	dbra	d6,SPat7
* Pas d'erreur
SPatX:	moveq	#0,d0
SPatex:	movem.l	(sp)+,d1-d7/a0-a6
	rts
* Erreur quelconque
SPatE:	moveq	#1,d0
	bra.s	SPatex

******* Efface le pattern de l'ecran courant
EffPat:	movem.l	a0-a1/d0-d2,-(sp)
	move.l	T_EcCourant(a5),a0
	move.l	EcPat(a0),d0
	beq.s	EffPx
	move.l	d0,a1
	move.w	EcPatL(a0),d0
	ext.l	d0
	clr.l	EcPat(a0)
	clr.w	EcPatL(a0)
	clr.b	EcPatY(a0)
	bsr	FreeMm
EffPx:	move.l	T_RastPort(a5),a0
	clr.l	8(a0)
	clr.b	29(a0)
	movem.l	(sp)+,a0-a1/d0-d2
	rts

******* Routine
SoMouse	subq.w	#1,d2
Som0:	move.w	(a2)+,d0
	bmi.s	SomE
	mulu	(a2)+,d0
	mulu	(a2)+,d0
	lsl.w	#1,d0
	lea	4(a2,d0.w),a2
	dbra	d2,Som0
	moveq	#0,d0
	rts
SomE:	moveq	#-1,d0
	rts

******* GET FONTS A0= buffer D1= type
TGFonts	movem.l	d1-d7/a1-a6,-(sp)
	move.w	d1,-(sp)
* Ouvre la librairie disk font
	bsr	OpenDFont
	beq	IgfE
* Efface les anciens
	bsr	TFFonts
* Demande la taille
	moveq	#8,d0
	move.l	a1,a0
	move.w	(sp),d1
	move.l	T_FntBase(a5),a6
	jsr	AvailFonts(a6)
	tst.l	d0
	beq.s	IgfX
* Refait en reservant
	addq.l	#8,d0
	move.l	d0,d1
	bsr	FastMm
	beq.s	IgfE
	move.l	d0,a0
	move.l	d0,T_FontInfos(a5)
	move.w	d1,T_FontILong(a5)
	move.l	d1,d0
	move.w	(sp),d1
	move.l	T_FntBase(a5),a6
	jsr	AvailFonts(a6)
	tst.l	d0
	beq.s	IgfX
	bsr	TFFonts
IgfX:	addq.l	#2,sp
	movem.l	(sp)+,d1-d7/a1-a6
	tst.w	d0
	rts
IgfE:	moveq	#-1,d0
	bra.s	IgfX
******* Init DISKFONT Library
OpenDFont
	movem.l	a0-a1/a6/d0-d1,-(sp)
	moveq	#0,d0
	lea	FntName(pc),a1
	move.l	$4.w,a6
	jsr	OpenLib(a6)
	move.l	d0,T_FntBase(a5)
	movem.l	(sp)+,a0-a1/a6/d0-d1
	tst.l	T_FntBase(a5)
	rts

******* Libere le buffer des infos fontes
TFFonts	movem.l	d0/a1,-(sp)
	move.l	T_FontInfos(a5),d0
	beq.s	FrfX
	move.l	d0,a1
	move.w	T_FontILong(a5),d0
	ext.l	d0
	bsr	FreeMm
	clr.l	T_FontInfos(a5)
	clr.w	T_FontILong(a5)
FrfX:	movem.l	(sp)+,d0/a1
	moveq	#0,d0
	rts

******* GET FONT D1 / Retour A0= adresse si def existe
TGFont:	move.l	T_FontInfos(a5),d0
	beq.s	TgfE
	move.l	d0,a0
	tst.w	d1
	beq.s	TgfV
	cmp.w	(a0)+,d1
	bhi.s	TgfV
	mulu	#10,d1
	lea	-10(a0,d1.w),a0
Tsf0:	moveq	#0,d0
	rts
TgfE:	moveq	#-1,d0
	rts
TgfV:	moveq	#1,d0
	rts

; SET FONT
;	D1= 	Numero fonte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
TSFont	bsr	CFont
	tst.w	d1
	beq.s	Tsf0
	bsr	TGFont
	bne	.Xx
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	a0,a2
	move.w	(a0),d0
	cmp.w	#1,d0
	beq.s	.Ram
; Fonte DISQUE: essaie d'abord en ROM, au cas zou
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#502,d0			50 Fontes retourn�es
	moveq	#1,d1			Fontes RAM
	lea	-502(sp),sp
	move.l	sp,a0
	move.l	T_FntBase(a5),a6
	jsr	AvailFonts(a6)
	move.l	sp,a0
	move.w	(a0)+,d0
	subq.w	#1,d0
	bmi.s	.PaRom
.Loop	move.w	6(a0),d1
	cmp.w	6(a2),d1
	bne.s	.Next
	move.l	2(a0),a1
	move.l	2(a2),a3
.Comp	move.b	(a1)+,d1
	beq.s	.Found
	cmp.b	(a3)+,d1
	beq.s	.Comp
.Next	lea	10(a0),a0
	dbra	d0,.Loop
; Pas trouve en ram, prendre sur disque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PaRom	lea	502(sp),sp
.Disc	lea	2(a2),a0
	move.l	T_FntBase(a5),a6
	jsr	OpenDiskFont(a6)
	tst.l	d0
	beq.s	.Err
	bne.s	.Suit
; Ouvre une fonte RAM
; ~~~~~~~~~~~~~~~~~~~
.Found	lea	502(sp),sp
.Ram	lea	2(a2),a0
	move.l	T_GfxBase(a5),a6
	jsr	OpenFont(a6)
	tst.l	d0
	beq.s	.Err
; Change le rastport et marque l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Suit	move.l	d0,a0
	move.l	T_RastPort(a5),a1
	move.l	T_GfxBase(a5),a6
	jsr	SetFont(a6)
	move.l	T_EcCourant(a5),a0
	addq.w	#1,EcFontFlag(a0)
.Rien	moveq	#0,d0
.X	movem.l	(sp)+,d1-d7/a1-a6
.Xx	rts
.Err	moveq	#1,d0
	bra.s	.X

;	Ferme la fonte de l'ecran courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CFont:	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	T_EcCourant(a5),d0
	beq.s	.Nofont
	move.l	d0,a0
	tst.w	EcFontFlag(a0)
	beq.s	.Nofont
; Ferme la fonte
; ~~~~~~~~~~~~~~
	clr.w	EcFontFlag(a0)
	move.l	EcText(a0),a1
	move.l	T_GfxBase(a5),a6
	jsr	_LVOCloseFont(a6)
; Remet la fonte systeme
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_DefaultFont(a5),a0
	move.l	T_RastPort(a5),a1
	jsr	_LVOSetFont(a6)
.Nofont	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

	IFEQ	EZFlag
******************************************************************
*	MARCHE / ARRET de menus
StaMn:	bsr	Ec_Push
	move.w	#1,T_PaPeek(a5)
* Branche d'autres zones
	move.l	T_EcCourant(a5),a0
	move.l	EcAZones(a0),T_SaveZo(a5)
	move.w	EcNZones(a0),T_SaveNZo(a5)
	clr.l	EcAZones(a0)
	clr.w	EcNZones(a0)
* Clippe tout l'ecran
	moveq	#0,d0
	moveq	#0,d1
	move.w	EcTx(a0),d2
	move.w	EcTy(a0),d3
	bsr	Ec_SetClip
* Writing normal
	move.l	T_RastPort(a5),a1
	moveq	#1,d0
	GfxA5	SetDrMd
* Outline ON
	bset	#3,33(a1)
	move.w	#$FFFF,34(a1)
	rts
StoMn	move.l	T_EcCourant(a5),a0
	move.l	T_SaveZo(a5),EcAZones(a0)
	move.w	T_SaveNZo(a5),EcNZones(a0)
	clr.w	T_PaPeek(a5)
	bsr	Ec_Pull
	rts
	ENDC

******************************************************************
*	SLIDERS

******* Dessine un slider HORIZONTAL
*	D1/D2->	TX/TY
*	D3->	Total
*	D4->	Position
*	D5->	Taille
*	D6->	X
*	D7->	Y
SliHor	movem.l	d1-d7/a4,-(sp)
	move.l	T_EcCourant(a5),a4
	bsr	Ec_Push
	cmp.w	d3,d4
	bhi.s	SlPa
	move.w	d1,d0
	bsr	SliPour
	bsr	SlRegs
	move.w	d0,d2
	add.w	d6,d2
	bsr	SliTour
	bsr	SliDess
	move.w	d2,d0
	add.w	d7,d2
	bsr	SliInt
	bsr	SliDess
	move.w	d2,d0
	move.w	d4,d2
	bsr	SliTour
	bsr	SliDess
SlOk:	moveq	#0,d0
SlGo:	bsr	Ec_Pull
	movem.l	(sp)+,d1-d7/a4
	tst.w	d0
	rts
SlPa:	moveq	#1,d0
	bra.s	SlGo
SlRegs	move.w	d4,d0
	add.w	d1,d4
	move.w	d5,d1
	add.w	d2,d5
	move.w	d4,d2
	move.w	d5,d3
	rts
******* Dessine un slider VERTICAL
SliVer	movem.l	d1-d7/a4,-(sp)
	move.l	T_EcCourant(a5),a4
	bsr	Ec_Push
	cmp.w	d3,d4
	bhi.s	SlPa
	move.w	d2,d0
	bsr	SliPour
	bsr	SlRegs
	move.w	d1,d3
	add.w	d6,d3
	bsr	SliTour
	bsr	SliDess
	move.w	d3,d1
	add.w	d7,d3
	bsr	SliInt
	bsr	SliDess
	move.w	d3,d1
	move.w	d5,d3
	bsr	SliTour
	bsr	SliDess
	bra.s	SlOk

******* Dessine l'interieur du slider
*	D0= X
*	D1= Y
*	D2= X1
*	D2= X2
SliInt	movem.l	d0-d7,-(sp)
	move.b	EcIInkA(a4),d4
	move.b	EcIInkB(a4),d5
	move.b	EcIInkC(a4),d6
	move.w	EcIPat(a4),d7
	bsr	SliPut
	bra.s	SliSx
******* Dessine le TOUR du slider
*	D6= X
*	D7= Y
*	D1= TX
*	D2= TY
SliTour	movem.l	d0-d7,-(sp)
	move.b	EcFInkA(a4),d4
	move.b	EcFInkB(a4),d5
	move.b	EcFInkC(a4),d6
	move.w	EcFPat(a4),d7
	bsr	SliPut
SliSx	movem.l	(sp)+,d0-d7
	rts
******* Dessine la bar
SliDess	cmp.w	d0,d2
	bls.s	SliDx
	cmp.w	d1,d3
	bls.s	SliDx
	move.l	T_RastPort(a5),a1
	GfxA5	RectFill
SliDx	rts

******* Change les parametres pour dessiner le slider
SliPut:
* Change les encres
	move.l	T_RastPort(a5),a1
	move.b	d6,27(a1)		* Ink C
	move.w	d5,d0			* Ink B
	GfxA5	SetBPen
	move.w	d6,d0			* Ink A
	GfxA5	SetAPen
* Lignes continues, outlined
	move.w	#$FFFF,34(a1)
	bset	#3,33(a1)
* Pattern
	move.w	d7,d1
	bsr	SPat
	rts

******* Calcule les pourcentages
SliPour	move.w	d0,-(sp)
	movem.l	d1/d2,-(sp)
	movem.l	d6/d7,-(sp)
	moveq	#0,d6
	move.w	d0,d7
	cmp.w	d3,d5
	bcs.s	Poub
	tst.w	d3
	bne.s	Poua
	moveq	#1,d3
Poua:	move.w	d3,d5

Poub	bclr	#31,d7		* Flag DBug
	move.w	d5,d1		* Si position + taille
	add.w	d4,d1		  >= maximum: dessin plein...
	cmp.w	d3,d1
	bcs.s	.Deb
	bset	#31,d7
.Deb
	move.w	d0,d1		* Calculs *65536
	swap	d0
	clr.w	d0
	divu	d3,d0
	bvs.s	Pou1
	mulu	d0,d4
	swap	d4
	mulu	d5,d0
	cmp.w	#$8000,d0
	bcs.s	.Skip
	add.l	#$00010000,d0
.Skip	swap	d0
	bra.s	Pou3
Pou1:	moveq	#0,d0		* Calculs *256
	move.w	d1,d0
	lsl.l	#8,d0
	divu	d3,d0
	bvs.s	Pou2
	mulu	d0,d4
	lsr.l	#8,d4
	mulu	d5,d0
	cmp.b	#$80,d0
	bcs.s	.Skip
	add.l	#$00000100,d0
.Skip	lsr.l	#8,d0
	bra.s	Pou3
Pou2:	moveq	#0,d0		* Calculs normaux
	move.w	d1,d0
	divu	d3,d0
	mulu	d0,d4
	mulu	d5,d0
Pou3:	cmp.w	#4,d0		* Ty >= 4
	bcc.s	SlPo1
	moveq	#4,d0
SlPo1:	move.w	d4,d6
	cmp.w	d1,d6		* Sort en bas?
	bcs.s	SlPo3
	move.w	d1,d6
	sub.w	d0,d6
SlPo3:	move.w	d6,d7		* Fin du slider
	add.w	d0,d7
	cmp.w	d1,d7		* Sort en bas?
	bls.s	SlPoF
	move.w	d1,d6
	move.w	d1,d7
	sub.w	d0,d6
SlPoF:	sub.w	d6,d7		* TAILLE du centre!
; La fin
	movem.l	(sp)+,d4/d5
	movem.l	(sp)+,d1/d2
	move.w	(sp)+,d0
	btst	#31,d7
	beq.s	.Ok
	move.w	d0,d6		* Positionne EXACTEMENT � la fin! GRRRRRRR
	sub.w	d7,d6
.Ok	moveq	#0,d0
	rts

******* Set Slider params!
*	D0-	InkFa
*	D1-	InkFb
*	D2-	InkFc
*	D3-	Pattern
*	D4-	InkIa
*	D5-	InkIb
*	D6-	InkIc
*	D7-	Pattern
SliSet:	move.l	T_EcCourant(a5),a0
	move.l	#EntNul,a1
	cmp.l	a1,d0
	beq.s	Slip0
	move.b	d0,EcFInkA(a0)
Slip0	cmp.l	a1,d1
	beq.s	Slip1
	move.b	d1,EcFInkB(a0)
Slip1	cmp.l	a1,d2
	beq.s	Slip2
	move.b	d2,EcFInkC(a0)
Slip2	cmp.l	a1,d3
	beq.s	Slip3
	move.w	d3,EcFPat(a0)
Slip3	cmp.l	a1,d4
	beq.s	Slip4
	move.b	d4,EcIInkA(a0)
Slip4	cmp.l	a1,d5
	beq.s	Slip5
	move.b	d5,EcIInkB(a0)
Slip5	cmp.l	a1,d6
	beq.s	Slip6
	move.b	d6,EcIInkC(a0)
Slip6	cmp.l	a1,d7
	beq.s	Slip7
	move.w	d7,EcIPat(a0)
Slip7	moveq	#0,d0
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         INITIALISATION DU FLASHEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlInit: clr 	T_nbflash(a5)
        move 	#lflash*FlMax-1,d0
        lea	T_tflash(a5),a0
razfl1: clr.b 	(a0)+
        dbra 	d0,razfl1
        rts

; FLASH OFF: arrete les flash de l'ecran active
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FlStop:	move.l	T_EcCourant(a5),d0
	addq.b	#1,T_NbFlash+1(a5)	Inhibe les interruptions
	moveq	#FlMax-1,d1
	lea	T_TFlash(a5),a0
FlS1	tst.w	(a0)
	beq.s	FlS3
	cmp.l	4(a0),d0
	bne.s	FlS3
	clr.w	(a0)
FlS3	lea	LFlash(a0),a0
	dbra	d1,FlS1
FlSx	bsr	FlCalc			Nombre de flash reels
	subq.b	#1,T_NbFlash+1(a5)	Redemarre
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       FLASH X,A$     d1=numero de la couleur, a1=adresse de la chaine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlStart	movem.l	a2-a6/d2-d7,-(sp)
	cmp.b	#FlMax,T_NbFlash(a5)
	bcc	FlToo
	addq.b	#1,T_NbFlash+1(a5)	;Arrete les flashes
        clr 	d5
; Trouve une position dans la table
        lea	T_tflash(a5),a0       	;trouve la position dans la table
	moveq	#FlMax-1,d0
        addq 	#1,d1
        lsl 	#1,d1
	move.l	T_EcCourant(a5),d2	;ecran ouvert!
flshi1: tst.w 	(a0)            	;premiere place libre
        beq.s 	flspoke
        cmp.w 	(a0),d1         	;Meme couleur Meme ecran
        bne.s	flshi0
	cmp.l	4(a0),d2
	beq.s	flspoke
flshi0: lea 	lflash(a0),a0
	dbra	d0,flshi1
        bra.s 	flsont          	;par securite
flsynt	clr.w 	(a0)          		;arrete la couleur
flsont	moveq 	#8,d0
flout	bsr	FlCalc			;Nombre de flash REEL
	subq.b	#1,T_NbFlash+1(a5)	;Deshinibe
	tst.w	d0
FlExit	movem.l	(sp)+,d2-d7/a2-a6
	rts
; Place trouvee: poke dans la table
flspoke	moveq 	#lflash-1,d0  		;nettoie la table
        move.l 	a0,a2
flshi3: clr.b 	(a2)+
        dbra 	d0,flshi3
        moveq	#0,d0
        tst.b 	(a1)          		;flash 1,"": arret de la couleur
        beq.s 	flout
	move.l	a0,a2
	move.w	d1,(a2)+		;Numero de la couleur
	move.w	#1,(a2)+		;Compteur
        move.l 	d2,(a2)+    		;Adresse de l'ecran
	clr.w	(a2)+			;Position
        moveq 	#-1,d4
flshi4: move.b	(a1)+,d0
        cmp.b 	#"(",d0
        bne 	flshi5
        addq.l 	#1,d4
        cmp 	#16,d4             	;16 couleurs autorisees!
        bcc 	flsynt
	moveq	#12,d2
	clr.l	d1
	bsr	GetHexa
	beq	FlSynt
	lsl.w	d2,d1
	lsl.l	#4,d1
	bsr	GetHexa
	beq	FlSynt
	lsl.w	d2,d1
	lsl.l	#4,d1
	bsr	GetHexa
	beq	FlSynt
	lsl.w	d2,d1
	lsl.l	#4,d1
	swap	d1
        move.w 	d1,2(a2)	  	;poke la couleur!
        cmp.b 	#",",(a1)+
        bne 	flsynt
        bsr 	dechexa
        bne 	flsynt
        tst 	d1
        beq 	flsynt
        move.w 	d1,(a2)		   	;poke la vitesse
	addq.l	#4,a2
        cmp.b 	#")",d0
        bne 	flsynt
        bra 	flshi4
flshi5: tst.b 	d0            		;la chaine doit etre finie!
        bne 	flsynt
        clr.l 	d0            		;pas d'erreur
        bra 	flout
; Erreurs flash
FlToo	moveq	#7,d0			* Too many flash
	bra	FlExit

; 	Calcule le nombre exact de flash
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FlCalc	movem.l	a0-a1/d0-d1,-(sp)
	addq.b	#1,T_NbFlash+1(a5)
	moveq	#0,d0
	moveq	#FlMax-1,d1
        lea	T_tflash(a5),a0       	;trouve la position dans la table
.Loop	tst.w	(a0)
	beq.s	.Next
	addq.w	#1,d0
.Next	lea	lflash(a0),a0
	dbra	d1,.Loop
	move.b	d0,T_NbFlash(a5)
	subq.b	#1,T_NbFlash+1(a5)
	movem.l	(sp)+,a0-a1/d0-d1
	rts


	IFEQ	EZFlag
***********************************************************
*	START SHIFT
*	D1= 	Numero du shift
*	D2=	Vitesse
*	D3=	Col debut
*	D4=	Col fin
*	D5= 	Direction
*	D6= 	Rotation?
***********************************************************
ShStart	movem.l	a2/d3/d4,-(sp)
	move.l	T_EcCourant(a5),a0
	lea	T_TShift(a5),a1
	move.l	a1,a2
	clr.w	(a1)+
	move.w	d2,(a1)+
	move.l	a0,(a1)+
	and.w	#31,d3				*** 256 couleurs!
	and.w	#31,d4
	cmp.w	d3,d4
	bls.s	.Err
	lsl.w	#1,d3
	lsl.w	#1,d4
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	move.b	d5,(a1)+
	move.b	d6,(a1)+
	move.w	#1,(a2)
	moveq	#0,d0
.Out	movem.l	(sp)+,a2/d3/d4
	rts
.Err:	moveq	#9,d0
	bra.s	.Out

***********************************************************
*	Initialisation de la table des shifts
***********************************************************
ShInit:	lea	T_TShift(a5),a0
	move.w	#LShift/2-1,d0
ShI:	clr.w	(a0)+
	dbra	d0,ShI
	rts

***********************************************************
*	Arret des shifts d'un ecran
***********************************************************
ShStop:	move.l	T_EcCourant(a5),d0
	lea	T_TShift(a5),a0
	tst.w	(a0)
	beq.s	ShStX
	cmp.l	4(a0),d0
	bne.s	ShStX
	clr.w	(a0)
ShStX:	moveq	#0,d0
	rts

***********************************************************
*	INTERRUPTIONS SHIFTER
***********************************************************
Shifter:lea	T_TShift(a5),a0
	tst.w	(a0)
	beq.s	ShfX
	subq.w	#1,(a0)
	bne.s	ShfX
* Shifte!
	move.w	2(a0),(a0)
	addq.l	#4,a0
	move.l	(a0)+,a1
	move.w	EcNumber(a1),d0
	lsl.w	#7,d0
	lea	0(a3,d0.w),a4
	lea	EcPal(a1),a1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	d0,d2
	move.w	d1,d3
	tst.b	(a0)+
	bne.s	Shf6
* En montant!
	move.w	0(a1,d3.w),d5
Shf5:	move.w	-2(a1,d3.w),0(a1,d3.w)
	subq.w	#2,d3
	cmp.w	d2,d3
	bne.s	Shf5
	bra.s	Shf8
* En descendant
Shf6:	move.w	0(a1,d2.w),d5
Shf7:	move.w	2(a1,d2.w),0(a1,d2.w)
	addq.w	#2,d2
	cmp.w	d2,d3
	bne.s	Shf7
* Poke dans les listes copper les couleurs D0-D1
Shf8:	tst.b	(a0)+			* Rotation???
	beq.s	Shf8a
	move.w	d5,0(a1,d2.w)
Shf8a:	move.w	d0,d2
	lsl.w	#1,d2
Shf9:	move.w	0(a1,d0.w),d3
	move.l	a4,a2
	cmp.w	#PalMax*2,d0
	bcs.s	ShfC
	lea	64(a2),a2
ShfC:	move.l	(a2)+,d4
	beq.s	ShfB
ShfA:	move.l	d4,a0
	move.w	d3,2(a0,d2.w)
	move.l	(a2)+,d4
	bne.s	ShfA
ShfB:	addq.w	#2,d0
	addq.w	#4,d2
	cmp.w	d1,d0
	bls.s	Shf9
* Fini!
ShfX	rts
	ENDC

***********************************************************
*	FADE OFF
FadeTOf	clr.w	T_FadeFlag(a5)
	moveq	#0,d0
	rts
***********************************************************
*	ARRETE LE FADE DE L'ECRAN COURANT!
FaStop	move.l	T_EcCourant(a5),a0
	lea	EcPal(a0),a0
	cmp.l	T_FadePal(a5),a0
	bne.s	FaStp
	clr.w	T_FadeFlag(a5)
FaStp	rts

***********************************************************
*	INSTRUCTION FADE
*	A1=	Nouvelle palette
*	D1=	Vitesse
FadeTOn	movem.l	d1-d7/a1-a3,-(sp)
	move.l	T_EcCourant(a5),a2
* Params
DoF1	clr.w	T_FadeFlag(a5)
	move.w	#1,T_FadeCpt(a5)
	move.w	d1,T_FadeVit(a5)
	move.w	EcNumber(a2),d0
	lsl.w	#7,d0
	lea	T_CopMark(a5),a3
	add.w	d0,a3
	move.l	a3,T_FadeCop(a5)
	lea	EcPal(a2),a2
	move.l	a2,T_FadePal(a5)
* Explore toutes la palette (marquee)
	moveq	#0,d7
	moveq	#0,d6
	lea	T_FadeCol(a5),a3
DoF2	move.w	(a1)+,d2
	bmi.s	DoF5
	move.w	d7,(a3)+
	moveq	#8,d4
	moveq	#0,d5
	move.w	0(a2,d7.w),d0
DoF3	move.w	d0,d1
	lsr.w	d4,d1
	and.w	#$000F,d1
	move.w	d2,d3
	lsr.w	d4,d3
	and.w	#$000F,d3
	move.b	d1,(a3)+
	move.b	d3,(a3)+
	cmp.b	d1,d3
	beq.s	DoF4
	or.w	#$1,d5
DoF4	subq.w	#4,d4
	bpl.s	DoF3
	add.w	d5,d6
	tst.w	d5
	bne.s	DoF5
	subq.l	#8,a3
DoF5	addq.w	#2,d7
	cmp.w	#32*2,d7
	bcs.s	DoF2
* Demarre -ou non!-
	move.w	d6,T_FadeFlag(a5)
	subq.w	#1,d6
	move.w	d6,T_FadeNb(a5)
DoFx	movem.l	(sp)+,d1-d7/a1-a3
	moveq	#0,d0
	rts
***********************************************************
*	INTERRUPTIONS FADEUR
*	Attention! Change A3!!!
***********************************************************
FadeI	tst.w	T_FadeFlag(a5)
	beq.s	FadX
	subq.w	#1,T_FadeCpt(a5)
	beq.s	Fad0
FadX	rts
* Fade!
Fad0	move.w	T_FadeVit(a5),T_FadeCpt(a5)
	move.l	T_FadePal(a5),a1
	move.l	T_FadeCop(a5),d3
	move.w	T_FadeNb(a5),d7
	lea	T_FadeCol(a5),a2
	moveq	#0,d6
* Boucle
Fad1	move.w	(a2)+,d5
	bmi.s	FadN0
	moveq	#0,d4
	moveq	#0,d0
	move.b	(a2)+,d0
	cmp.b	(a2)+,d0		* R
	beq.s	Fad4
	bhi.s	Fad2
	addq.w	#1,d0
	bra.s	Fad3
Fad2	subq.w	#1,d0
Fad3	addq.w	#1,d4
	move.b	d0,-2(a2)
Fad4	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	(a2)+,d1		* G
	beq.s	Fad7
	bhi.s	Fad5
	addq.w	#1,d1
	bra.s	Fad6
Fad5	subq.w	#1,d1
Fad6	addq.w	#1,d4
	move.b	d1,-2(a2)
Fad7	moveq	#0,d2
	move.b	(a2)+,d2
	cmp.b	(a2)+,d2		* B
	beq.s	FadA
	bhi.s	Fad8
	addq.w	#1,d2
	bra.s	Fad9
Fad8	subq.w	#1,d2
Fad9	addq.w	#1,d4
	move.b	d2,-2(a2)
* Calcule la couleur
FadA	tst.w	d4
	beq.s	FadN1
	addq.w	#1,d6
	lsl.w	#4,d0
	or.w	d1,d0
	lsl.w	#4,d0
	or.w	d2,d0
* Poke dans l'ecran
	move.w	d0,0(a1,d5.w)
* Poke dans les listes copper
	lsl.w	#1,d5
	move.l	d3,a3
	cmp.w	#PalMax*4,d5
	bcs.s	FadC
	lea	64(a3),a3
FadC	move.l	(a3)+,d1
	beq.s	FadN
FadB	move.l	d1,a4
	move.w	d0,2(a4,d5.w)
	move.l	(a3)+,d1
	bne.s	FadB
* Couleur suivante
FadN	dbra	d7,Fad1
	move.w	d6,T_FadeFlag(a5)
	rts
* Rien dans cette couleur
FadN0	addq.l	#6,a2
	dbra	d7,Fad1
	move.w	d6,T_FadeFlag(a5)
	rts
* Plus rien maintenant
FadN1	move.w	#-1,-8(a2)
	bra.s	FadN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       INTERRUPTIONS FLASHEUR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlInt:  tst.b	T_NbFlash+1(a5)		Autorisee?
	bne.s	FlShXX
	move.b 	T_NbFlash(a5),d7	Nombre en route
	beq.s	FlShXX
	addq.b	#1,T_NbFlash+1(a5)	Inhibe!
        lea	T_tflash-lflash+2(a5),a0
FlShLL	lea	lflash-2(a0),a0
FlShL	move.w 	(a0)+,d0
        beq.s 	FlShLL
; Flashe!
	sub.w 	#1,(a0)			* Compteur
        bne.s 	FlShN
	lea	2(a0),a1
	move.l	(a1)+,a2		* Adresse de l'ecran
	add.w	(a1)+,a1		* Pointe
	move.w	(a1)+,(a0)
	bne.s	Flsh4
	lea	6(a0),a1
	clr.w	(a1)+
	move.w	(a1)+,(a0)
FlSh4:	addq.w	#4,6(a0)		* Pointe le suivant
	move.w	(a1),d2
	move.w	d2,EcPal-2(a2,d0.w)	* Change dans la definition
	lsl.w	#1,d0
	move.w	EcNumber(a2),d1
	lsl.w	#7,d1
	lea	0(a3,d1.w),a2
	cmp.w	#PalMax*4+4,d0
	bcs.s	FlSh5
	lea	64(a2),a2
FlSh5:	move.l	(a2)+,d1		* Change toutes les definitions
	beq.s	FlShN
FlSh6:	move.l	d1,a1
	move.w	d2,2-4(a1,d0.w)
	move.l	(a2)+,d1
	bne.s	FlSh6
; Encore un actif?
FlShN	subq.b	#1,d7
	bne.s	FlShLL
; Fini!
FlShX	subq.b	#1,T_NbFlash+1(a5)	Retabli les interruptions
FlShXX	rts

***********************************************************
*	FABRIQUE LA COPPER LISTE A PARTIR DES ECRANS
*
******* ACTUALISATION DES ECRANS
EcForceCop:				* Entree en forcant le calcul
	addq.w	#1,T_EcYAct(a5)
EcCopper:				* Entree normale
	movem.l	d1-d7/a1-a6,-(sp)

* Suite actualisation
	move.w	T_EcYAct(a5),d7
	lea	T_EcPri(a5),a0
	move.l	(a0)+,d0
	beq	EcA6
	bmi	EcActX
EcAct0:	move.l	d0,a1
* Changement en WY
	move.b	EcAW(a1),d0
	beq.s	EcA2
	btst	#2,d0
	beq.s	EcAct1
	move.w	EcAWY(a1),d1
	add.w	#EcYBase,d1
	bpl.s	EcAa
	moveq	#0,d1
EcAa:	move.w	d1,EcWY(a1)
	addq.w	#1,d7
* Changement en WX
EcAct1:	btst	#1,d0
	beq.s	EcAct2
	move.w	EcAWX(a1),d1
	and.w	#$FFF0,d1
	move.w	d1,EcWX(a1)
* Changement en WTY
EcAct2:	clr.w	EcAW(a1)
EcA2:	move.b	EcAWT(a1),d0
	beq.s	EcA4
	btst	#2,d0
	beq.s	EcAct3
	move.w	EcAWTY(a1),d1
	beq.s	EcAct3
	cmp.w	EcTY(a1),d1
	bcs.s	EcAc
EcAg:	move.w	EcTY(a1),d1
EcAc:	btst	#2,EcCon0+1(a1)
	beq.s	EcA2a
	lsr.w	#1,d1
EcA2a:	move.w	d1,EcWTy(a1)
	addq.w	#1,d7
* Changement en WTX
EcAct3:	btst	#1,d0
	beq.s	EcAct4
	move.w	EcAWTX(a1),d1
	and.w	#$FFF0,d1
	beq.s	EcAct4
	move.w	EcTx(a1),d2
	tst.w	EcCon0(a1)
	bpl.s	EcAe
	lsr.w	#1,d2
EcAe:	cmp.w	d2,d1
	bcs.s	EcAf
	move.w	d2,d1
EcAf:	move.w	d1,EcWTx(a1)
* Changement en OY
EcAct4:	clr.w	EcAWT(a1)
EcA4:	move.b	EcAV(a1),d0
	beq.s	EcA6
	btst	#2,d0
	beq.s	EcAct5
	move.w	EcAVY(a1),EcVY(a1)
* Changement en OX
EcAct5:	btst	#1,d0
	beq.s	EcAct6
	move.w	EcAVX(a1),EcVX(a1)
* Encore un ecran?
EcAct6:	clr.w	EcAV(a1)
EcA6:	move.l	(a0)+,d0
	beq.s	EcA6
	bpl	EcAct0
EcActX:

******* Calcul des nouvelles priorites?
	move.l	T_EcCop(a5),a1

;-----> Si pas de changement Y/TY/Priorite, pas de calcul
	tst.w	d7
	beq	PaDecoup
	clr.w	T_EcYAct(a5)

;-----> Decoupe les ecrans en tranches
	lea	T_EcBuf(a5),a3
	moveq	#0,d2		;Limite en haut
MkD0:	lea	T_EcPri(a5),a2
	move.w	#10000,d3		;Limite en bas
	moveq	#-1,d5
	moveq	#0,d1

MkD1:	addq.w	#4,d1
	move.l	(a2)+,d0
	bmi.s	MkD3
	beq.s	MkD1
	move.l	d0,a0
	tst.b	EcFlags(a0)
	bmi.s	MkD1
	move.w	EcWY(a0),d0
	subq.w	#1,d0
	cmp.w	d2,d0
	bls.s	MkD2
	cmp.w	d3,d0
	bcc.s	MkD2
	move.w	d0,d3
	move.w	d3,d4
	add.w	EcWTy(a0),d4
	addq.w	#1,d4
	move.w	d1,d5
	bra.s	MkD1
MkD2:	add.w	EcWTy(a0),d0
	addq.w	#1,d0
	cmp.w	d2,d0
	bls.s	MkD1
	cmp.w	d3,d0
	bcc.s	MkD1
	move.w	d0,d3
	move.w	d1,d5
	bset 	#15,d5
	bra.s	MkD1

MkD3:	cmp.w	#-1,d5			;Fini?
	beq.s	MkD5
	cmp.w	#EcYStrt-1,d2		;Passe le haut de l'ecran?
	bcc.s	MkD3a
	cmp.w	#EcYStrt-1,d3
	bcs.s	MkD3a
	move.w	#EcYStrt-1,(a3)+	;Marque le haut de l'ecran
	clr.w	(a3)+
	move.w	#$8000,(a3)+

MkD3a:
MkD3b:
	move.w	d3,(a3)+
	move.w	d4,(a3)+
	move.w	d5,(a3)+
; Re-Explore la liste en cas d'egalite SI DEBUT DE FENETRE
	and.w	#$7fff,d5
	lea	T_EcPri(a5),a2
	moveq	#0,d1

MkD4:	addq.w	#4,d1
	move.l	(a2)+,d0
	bmi.s	MkD4a
	beq.s	MkD4
	move.l	d0,a0
	tst.b	EcFlags(a0)
	bmi.s	MkD4
	move.w	EcWY(a0),d0
	subq.w	#1,d0
	cmp.w	d0,d3
	bne.s	MkD4
	cmp.w	d5,d1
	beq.s	MkD4
	move.w	d3,(a3)+
	move.w	d3,d4
	addq.w	#1,d4
	add.w	EcWTy(a0),d4
	move.w	d4,(a3)+
	move.w	d1,(a3)+
	bra.s	MkD4
; Remonte la limite
MkD4a:	move.w	d3,d2
	bra	MkD0
; Fin de la liste
MkD5:	move.w	#-1,(a3)+

PaDecoup:

;-----> Analyse de la table / creation de la liste
	clr.w	T_InterInter(a5)
	lea	T_EcPri(a5),a2
	lea	T_EcBuf(a5),a3
MkA1:	move.w	(a3),d0
	bmi	MkAFin
	move.w	2(a3),d1
	move.w	4(a3),d2
	bmi	MkA4
; Debut d'une fenetre: doit-on l'afficher?
	lea	T_EcBuf(a5),a0
MkA2:	cmp.l	a3,a0
	bcc	MkA8
	tst.w	4(a0)
	bmi.s	MkA3
	cmp.w	(a0),d0
	bcs.s	MkA3
	cmp.w	2(a0),d0
	bcc.s	MkA3
	cmp.w	4(a0),d2
	bcc	MkA10
MkA3:	lea	6(a0),a0
	bra.s	MkA2

; Fin d'une fenetre: doit-on en reafficher une autre?
MkA4:	and.w	#$7FFF,d2
	cmp.w	#$100,d2		;Si fin de l'ecran --> marque!
	beq	MkA9a

	clr.w	d3
MkA4a:	addq.w	#6,d3			;Cherche UN DEBUT devant
	cmp.w	0(a3,d3.w),d0
	bne.s	MkA4b
	tst.w	4(a3,d3.w)
	bmi.s	MkA4a
	lea	0(a3,d3.w),a3		;Va faire le debut!
	bra	MkA1

MkA4b:	lea	T_EcBuf(a5),a0		;Cherche la fenetre a reafficher
	move.w	#1000,d3
MkA5:	cmp.l	a3,a0
	bcc.s	MkA7
	tst.w	4(a0)
	bmi.s	MkA6
	cmp.w	(a0),d0
	bcs.s	MkA6
	cmp.w	2(a0),d0
	bcc.s	MkA6
	cmp.w	4(a0),d3
	bcs.s	MkA6
	move.w	4(a0),d3
MkA6:	lea	6(a0),a0
	bra.s	MkA5
MkA7:	cmp.w	#1000,d3
	beq.s	MkA9
	cmp.w	d2,d3
	bls.s	MkA10
	move.w	d3,d2
; Peut creer la fenetre
MkA8:	move.l	-4(a2,d2.w),a0
	move.w	(a3),d0
	cmp.w	#EcYStrt-1,d0		* Sort en haut?
	bcs.s	MkA10
	move.w	T_EcYMax(a5),d1		* Sort en bas?
	subq.w	#2,d1
	cmp.w	d1,d0
	bcc.s	MkA10
	move.w	d0,(a1)+
	move.l	a0,(a1)+
	btst	#2,EcCon0+1(a0)
	beq.s	MkA10
	move.w	#%100,T_InterInter(a5)
	bra.s	MkA10
; Fin normale de la fenetre
MkA9:	tst.w	d2
	beq.s	MkA10
	move.w	(a3),d0
MkA9a:	cmp.w	#EcYStrt-1,d0
	bcs.s	MkA10
	move.w	T_EcYMax(a5),d1
	subq.w	#1,d1
	cmp.w	d1,d0
	bcc.s	MkA11
	neg.w	d0
	move.w	d0,(a1)+
; Passe a une autre
MkA10:	lea	6(a3),a3
	bra	MkA1
; C'est la fin
MkA11	neg.w	d1
	move.w	d1,(a1)+
* Marque la fin des ecrans
MkAFin:	clr.w	(a1)

*******	Fabrique la liste copper
* 	Avec RAINBOW ou non!
* Plus de screen swap
	clr.w	T_Cop255(a5)
	clr.w	T_InterBit(a5)
	clr.l	T_SwapList(a5)
* Nettoie les marqueurs
	clr.l	T_CopMark+CopL1*0(a5)
	clr.l	T_CopMark+CopL1*0+64(a5)
	clr.l	T_CopMark+CopL1*1(a5)
	clr.l	T_CopMark+CopL1*1+64(a5)
	clr.l	T_CopMark+CopL1*2(a5)
	clr.l	T_CopMark+CopL1*2+64(a5)
	clr.l	T_CopMark+CopL1*3(a5)
	clr.l	T_CopMark+CopL1*3+64(a5)
	clr.l	T_CopMark+CopL1*4(a5)
	clr.l	T_CopMark+CopL1*4+64(a5)
	clr.l	T_CopMark+CopL1*5(a5)
	clr.l	T_CopMark+CopL1*5+64(a5)
	clr.l	T_CopMark+CopL1*6(a5)
	clr.l	T_CopMark+CopL1*6+64(a5)
	clr.l	T_CopMark+CopL1*7(a5)
	clr.l	T_CopMark+CopL1*7+64(a5)
	clr.l	T_CopMark+CopL1*8(a5)
	clr.l	T_CopMark+CopL1*8+64(a5)
	clr.l	T_CopMark+CopL1*9(a5)
	clr.l	T_CopMark+CopL1*9+64(a5)
	clr.l	T_CopMark+CopL1*10(a5)
	clr.l	T_CopMark+CopL1*10+64(a5)
	clr.l	T_CopMark+CopL1*11(a5)
	clr.l	T_CopMark+CopL1*11+64(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*0(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*1(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*2(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*3(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*4(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*5(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*6(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*7(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*8(a5)
	clr.l	T_CopMark+CopL1*12+CopL2*9(a5)
* Copper manuel???
	tst.w	T_CopON(a5)
	beq	PasCop
* Liste copper logique
	move.l	T_CopLogic(a5),a1
	lea	64+4(a1),a1		* Saute les sprites
* Rainbow?
	tst.w	T_RainBow(a5)
	bne.s	CopBow
******* Fabrique NORMAL
MCop0	move.l	T_EcCop(a5),a2
MCop1	move.w	(a2)+,d0
	beq.s	MCopX
	bmi.s	MCop2
* Debut d'un ecran
	move.l	(a2)+,a0
	bsr	EcCopHo
	bra.s	MCop1
* Fin d'un ecran
MCop2	neg.w	d0
	bsr	EcCopBa
	bra.s	MCop1
* Fin de la liste
MCopX:	subq.l	#2,a2
	cmp.l	T_EcCop(a5),a2
	bne.s	.Skip
	move.w	T_EcYMax(a5),d0
	subq.w	#1,d0
	bsr	EcCopBa
.Skip	move.l	#$FFFFFFFE,(a1)+
*******	Swappe les listes
MCopSw	move.l	T_CopLogic(a5),a0
	move.l	T_CopPhysic(a5),a1
	move.l	a1,T_CopLogic(a5)
	move.l	a0,T_CopPhysic(a5)
* Poke dans le copper, si AMOS est la!
	tst.b	T_AMOSHere(a5)
	beq.s	PasCop
	move.l	a0,Circuits+Cop1Lc
	move.w	T_InterInter(a5),T_InterBit(a5)
* Fini!
PasCop	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#0,d0
	rts

******* Actualise les RAINBOWS
CopBow	lea	T_RainTable(a5),a0
	moveq	#0,d4
	moveq	#NbRain-1,d6
	moveq	#0,d5
RainA1	tst.w	RnLong(a0)
	beq.s	RainA5
	addq.w	#1,d5
	tst.w	RnI(a0)
	bmi.s	RainA5
	addq.w	#1,d4
	move.b	RnAct(a0),d7
	beq.s	RainA5
	clr.b	RnAct(a0)
* Taille en Y
	bclr	#0,d7
	beq.s	RainA2
	move.w	RnI(a0),d0
	move.w	d0,RnTY(a0)
	bset	#2,d7
* Position en Y
RainA2	bclr	#2,d7
	beq.s	RainA4
	clr.l	RnDY(a0)
	move.w	RnY(a0),d1
	cmp.w	#28,d1
	bcc.s	RainA3
	moveq	#28,d1
RainA3	move.w	RnTy(a0),d0
	add.w	#EcYBase,d1
	move.w	d1,RnDY(a0)
	add.w	d0,d1
	move.w	d1,RnFY(a0)
* Position de la base
RainA4	bclr	#1,d7
	beq.s	RainA5
	move.w	RnX(a0),d0
	lsl.w	#1,d0
	cmp.w	RnLong(a0),d0
	bcc.s	RainA5
	lsr.w	#1,d0
	move.w	d0,RnBase(a0)
* Rainbow suivant
RainA5	lea	RainLong(a0),a0
	dbra	d6,RainA1
* Securite!
	move.w	d5,T_RainBow(a5)
	tst.w	d4
	beq	MCop0

******* Fabrique la liste
	move.l	T_EcCop(a5),a2
	move.w	#EcYBase,d0
	moveq	#-1,d3
	moveq	#-1,d4
	moveq	#0,d7
Rain1	move.w	(a2)+,d1
	beq	Rain3
	bmi.s	Rain2
* Debut d'un ecran
	bsr	Rain
	move.l	(a2)+,a0
	movem.l	d0/d3-d7,-(sp)
	bsr	EcCopHo
	movem.l	(sp)+,d0/d3-d7
	clr.w	d3
	tst.w	d4
	bmi.s	Rain1e
	cmp.w	#PalMax*4,d4
	bcs.s	Rain1d
	lea	64(a4),a4
Rain1d	move.l	(a4),a0
	move.w	2(a0,d4.w),d3
	bclr	#31,d3
Rain1e	cmp.w	d7,d0
	bcc.s	Rain1a
	move.w	(a3)+,2(a0,d4.w)
	cmp.l	a6,a3
	bcs.s	Rain1a
	move.l	d6,a3
Rain1a	addq.w	#1,d0
	move.w	(a2),d1
	bpl.s	Rain1b
	neg.w	d1
Rain1b	cmp.w	d0,d1
	beq.s	Rain1
	cmp.w	d7,d0
	bcc.s	Rain2a
	move.w	d5,(a1)+
	move.w	(a3)+,(a1)+
	bra.s	Rain1c
* Fin d'un ecran
Rain2	neg.w	d1
	bsr	Rain
	bsr	EcCopBa
	tst.w	d4
	bne.s	Rain1b
	move.w	T_EcFond(a5),d3
	cmp.w	d7,d0
	bcc.s	Rain2a
	move.l	a1,a0			* Recherche la couleur
Rain1z	cmp.w	#$0180,-(a0)
	bne.s	Rain1z
	move.w	(a3)+,2(a0)
Rain1c	cmp.l	a6,a3
	bcs.s	Rain2a
	move.l	d6,a3
Rain2a	addq.w	#1,d0
	bra	Rain1
* Fin des ecrans
Rain3	subq.l	#2,a2
	cmp.l	T_EcCop(a5),a2
	bne.s	.Skip
	move.w	T_EcYMax(a5),d0
	subq.w	#1,d0
	bsr	Rain
	bsr	EcCopBa
.Skip	move.l	#$FFFFFFFE,(a1)+
	bra	MCopSw
******* Fabrique le rainbow ---> Y=D1
RainD1	move.w	d0,d2
	sub.w	#EcYBase,d2
	cmp.w	#256,d2			* Attente -> ligne -> D0
	bcs.s	RainD2
	tst.w	T_Cop255(a5)
	bne.s	RainD2
	move.w	#$FFE1,(a1)+
	move.w	#$FFFE,(a1)+
	addq.w	#1,T_Cop255(a5)
RainD2	lsl.w	#8,d2
	or.w	#$03,d2
	move.w	d2,(a1)+
	move.w	#$FFFE,(a1)+
	move.w	d5,(a1)+		* Change la couleur
	move.w	(a3)+,(a1)+
	cmp.l	a6,a3
	bcs.s	RainD3
	move.l	d6,a3
RainD3	addq.w	#1,d0
* Entree!
Rain	cmp.w	d7,d0
	bcc.s	RainNx
RainD0	cmp.w	d1,d0
	bcs.s	RainD1
RainDX	move.w	d1,d0
	rts
******* Trouve le rainbow comprenant D0
RainNX	tst.l	d3
	bmi.s	RainN0
	tst.w	d3			* Si RIEN au dessus
	bpl.s	Rain0a
	move.w	#Color00,(a1)+		* Couleur 0 d'office!
	move.w	T_EcFond(a5),(a1)+
	bset	#31,d3
	bra.s	RainN0
Rain0a	move.w	d5,(a1)+
	move.w	d3,(a1)+
	bset	#31,d3
RainN0	lea	T_RainTable(a5),a0	* Cherche le 1er
	moveq	#NbRain-1,d2
RainN1	cmp.w	(a0),d0
	bcs.s	RainN2
	cmp.w	RnFY(a0),d0
	bcs.s	RainN5
RainN2	lea	RainLong(a0),a0
	dbra	d2,RainN1
	lea	T_RainTable(a5),a0	* Trouve le 1er plus bas
	moveq	#0,d7
	moveq	#NbRain-1,d2
	move.w	d1,d6
RainN3	cmp.w	RnFY(a0),d0
	bcc.s	RainN4
	cmp.w	(a0),d1
	bcs.s	RainN4
	cmp.w	(a0),d6
	bcs.s	RainN4
	move.w	(a0),d6
	move.l	a0,d7
RainN4	lea	RainLong(a0),a0
	dbra	d2,RainN3
	tst.l	d7
	beq	RainDX
	move.l	d7,a0
	move.w	(a0),d0
* Debut d'un RainBow
RainN5	move.w	d0,d5
	sub.w	(a0),d5
	add.w	RnBase(a0),d5
	lsl.w	#1,d5
	move.l	RnBuf(a0),d6
	move.l	d6,a3
	move.l	a3,a6
	add.w	RnLong(a0),a6
	add.w	d5,a3
	cmp.l	a6,a3
	bcs.s	RainD7
RainN6	sub.w	RnLong(a0),a3
	cmp.l	a6,a3
	bcc.s	RainN6
RainD7	move.w	RnFY(a0),d7
* Nouvelle couleur
	move.w	d4,d2
	move.w	RnColor(a0),d4
	move.w	d4,d5
	lsl.w	#2,d4
	lsl.w	#1,d5
	add.w	#Color00,d5
* Reprend la couleur!
	tst.w	d3
	bmi.s	RainD9
	cmp.w	d4,d2
	beq.s	RainD9
	move.l	(a4),a0
	move.w	2(a0,d4.w),d3
RainD9	bclr	#31,d3
	bra	RainD0

******* Creation de la ligne COPPER de definition d'un ecran!
*	D0=	Y ecran
*	A0= 	Adresse de l'ecran
EcCopHo
* Decalage PHYSIQUE dans la fenetre
	move.w	d0,d1
	sub.w	EcWY(a0),d1
	addq.w	#1,d1
	btst	#2,EcCon0+1(a0)		* par 2 si entrelace!
	beq.s	MkC4a
	lsl.w	#1,d1
MkC4a
* Attend jusqu'a la ligne D0
	move.w	d0,d2
	sub.w	#EcYBase,d2
	bsr	WaitD2
* Preparation image
	move.w	#DmaCon,(a1)+		;Arret DMA
	move.w	#$0100,(a1)+
* Debut de la palette
	move.l	a1,-(sp)
	moveq	#PalMax-1,d3
	move.w	#Color00,d2
	lea	EcPal(a0),a4
MkC5:	move.w	d2,(a1)+
	addq.w	#2,d2
	move.w	(a4)+,(a1)+
	dbra	d3,MkC5

	IFEQ	EZFlag
* Dual playfield???
	move.w	EcDual(a0),d2
	bne	CreeDual
PluDual:
	ENDC

* Ecran normal!
	add.w	EcVY(a0),d1		* Decalage ecran
	mulu	EcTLigne(a0),d1
	move.w	EcVx(a0),d2
	lsr.w	#4,d2
	lsl.w	#1,d2
	add.w	d2,d1
	move.l	a1,d3
* Poke les adresses des bitplanes
	moveq	#EcPhysic,d2
	move.w	EcNPlan(a0),d6
	subq.w	#1,d6
	move.w	#Bpl1PtH,d7
MkC0:	move.l	0(a0,d2.w),d5
	add.l	d1,d5
	move.w	d7,(a1)+
	addq.w	#2,d7
	swap	d5
	move.w	d5,(a1)+
	move.w	d7,(a1)+
	addq.w	#2,d7
	swap	d5
	move.w	d5,(a1)+
	addq.l	#4,d2
	dbra	d6,MkC0
* Marque les adresses SCREEN SWAP
	move.w	EcNumber(a0),d2		* Marque les adresse
	cmp.w	#10,d2			* Si ecran utilisateur!
	bcc.s	MrkC2
	lsl.w	#6,d2
	lea	CopL1*EcMax+T_CopMark(a5),a4
	add.w	d2,a4
MrkC1	tst.l	(a4)
	addq.l	#8,a4
	bne.s	MrkC1
	clr.l	(a4)
	move.l	d3,-8(a4)		* Adresse dans liste
	move.l	d1,-4(a4)		* Decalage
MrkC2:
* Calcule les valeurs non plantantes!
	move.w	#465+16,d3
	tst.w	EcCon0(a0)
	bpl.s	MkC1c
	move.w	#465,d3
MkC1c	move.w	EcWX(a0),d1
	addq.w	#1,d1
	move.w	EcWTx(a0),d2
	move.w	d1,d6
	add.w	d2,d6
	cmp.w	d3,d6
	bcs.s	MkC1a
	sub.w	d3,d6
	add.w	#16,d6
	sub.w	d6,d2
	bra.s	MkC1b
MkC1a:	cmp.w	#176,d6
	bhi.s	MkC1b
	sub.w	#176,d6
	sub.w	d6,d1
MkC1b:	move.w	d1,EcWXr(a0)
	move.w	d2,EcWTxr(a0)
* Calcul et poke DIW Start/Stop
	move.w	#DiwStrt,(a1)+		;DiwStrt Y = 0
	move.w	d1,(a1)
	or.w	#$0100,(a1)+
	move.w	#DiwStop,(a1)+		;DiwStop Y = 311
	add.w	d2,d1
	and.w	#$00ff,d1
	or.w	#$3700,d1
	move.w	d1,(a1)+
* Calcul des valeurs modulo ---> d4
	move.w	EcTLigne(a0),d4
	move.w	EcWTxr(a0),d5
	lsr.w	#3,d5
	btst	#7,EcCon0(a0)
	bne.s	MkC2a
	lsr.w	#1,d5
MkC2a:	lsl.w	#1,d5
	sub.w	d5,d4
	bpl.s	MkC2
	clr.w	d4
MkC2:
* Calcul DDF Start/Stop---> D1/D2
	move.w	EcWXr(a0),d1
	move.w	EcWTxr(a0),d2
	move.w	EcVX(a0),d6
	btst	#7,EcCon0(a0)
	bne.s	MkCH
* Lowres
	sub.w	#17,d1
	lsr.w	#1,d1
	and.w	#$FFF8,d1
	lsr.w	#1,d2
	subq.w	#8,d2
	add.w	d1,d2
	and.w	#15,d6			;Scrolling?
	beq.s	MkC3
	subq.w	#8,d1
	subq.w	#2,d4
	neg.w	d6
	add.w	#16,d6
	bra.s	MkC3
* Hires
MkCH:	sub.w	#9,d1
	lsr.w	#1,d1
	and.w	#$FFFC,d1
	lsr.w	#1,d2
	subq.w	#8,d2
	add.w	d1,d2
	and.w	#15,d6			;Scrolling?
	lsr.w	#1,d6
	beq.s	MkC3
	subq.w	#4,d1
	subq.w	#4,d4
	neg.w	d6
	addq.w	#8,d6
MkC3:	move.w	d6,d5
	lsl.w	#4,d5
	or.w	d6,d5
* Poke les valeurs
	move.w	#DdfStrt,(a1)+
	move.w	d1,(a1)+
	move.w	#DdfStop,(a1)+
	move.w	d2,(a1)+
* Interlace?
	move.w	EcCon0(a0),d1
	btst	#2,d1
	beq.s	MkCi1
	move.w	EcTx(a0),d2
	lsr.w	#3,d2
	add.w	d2,d4
MkCi1	move.w	#Bpl1Mod,(a1)+
	move.w	d4,(a1)+
	move.w	#Bpl2Mod,(a1)+
	move.w	d4,(a1)+
* Registres de controle
	move.w	#BplCon0,(a1)+
	or.w	T_InterInter(a5),d1
	move.w	d1,(a1)+
	move.w	#BplCon1,(a1)+
	move.w	d5,(a1)+
	move.w	#BplCon2,(a1)+
	move.w	EcCon2(a0),(a1)+
* Reactive le DMA au debut de la fenetre
FiniCop	move.l	(sp)+,d4
	addq.w	#1,d0
	move.w	(a2),d1
	bpl.s	FiCp1
	neg.w	d1
FiCp1	cmp.w	d0,d1
	beq.s	MkC9
	move.w	d0,d2
	sub.w	#EcYBase,d2
	bsr	WaitD2
	move.w	#DmaCon,(a1)+
	move.w	#$8300,(a1)+
* Fin de la palette!
	move.l	a1,d3
	moveq	#32-PalMax-1,d1
	move.w	#Color00+PalMax*2,d2
	lea	EcPal+PalMax*2(a0),a4
MkC7:	move.w	d2,(a1)+
	addq.w	#2,d2
	move.w	(a4)+,(a1)+
	dbra	d1,MkC7
* Adresse de la 2ieme palette
	move.w	EcNumber(a0),d2
	lsl.w	#7,d2
	lea	T_CopMark+64(a5),a4
	add.w	d2,a4
MkC8:	tst.l	(a4)+
	bne.s	MkC8
	clr.l	(a4)
	sub.l	#4*PalMax,d3
	move.l	d3,-(a4)
* Adresse de la 1ere palette dans la liste copper
MkC9	move.w	EcNumber(a0),d2		* Marque les adresse
	lsl.w	#7,d2
	lea	T_CopMark(a5),a4
	add.w	d2,a4
MkC10:	tst.l	(a4)+
	bne.s	MkC10
	clr.l	(a4)
	move.l	d4,-(a4)
* Fini!
	rts

	IFEQ	EZFlag
******* Creation liste copper pour ecrans DUAL PLAYFIED!
CreeDual:
* Adresse du deuxieme ecran
	move.l	a2,-(sp)
	lsl.w	#2,d2
	lea	T_EcAdr(a5),a2
	move.l	-4(a2,d2.w),d2		* On a efface le deuxieme!
	bne.s	CrDu1
	move.l	(sp)+,a2
	clr.w	EcDual(a0)		* Transforme en ecran simple!
	move.w	EcCon0(a0),d2
	and.w	#%1000101111111111,d2
	move.w	EcNPlan(a0),d7
	lsl.w	#8,d7
	lsl.w	#4,d7
	or.w	d7,d2
	move.w	d2,EcCon0(a0)
	bra	PluDual
CrDu1:	move.l	d2,a2
* Adresses bitplanes PAIRS!
	move.w	d1,-(sp)
	add.w	EcVY(a0),d1		* Decalage ecran
	mulu	EcTLigne(a0),d1
	move.w	EcVx(a0),d2
	lsr.w	#4,d2
	lsl.w	#1,d2
	add.w	d2,d1
	move.l	a1,d3
	moveq	#EcPhysic,d2
	move.w	EcNPlan(a0),d6
	subq.w	#1,d6
	move.w	#Bpl1PtH,d7
MkDC1:	move.l	0(a0,d2.w),d5
	add.l	d1,d5
	move.w	d7,(a1)+
	addq.w	#2,d7
	swap	d5
	move.w	d5,(a1)+
	move.w	d7,(a1)+
	addq.w	#2,d7
	swap	d5
	move.w	d5,(a1)+
	addq.l	#4,d2
	addq.w	#4,d7
	dbra	d6,MkDC1
	move.w	EcNumber(a0),d2		* Marque les adresses
	cmp.w	#8,d2
	bcc.s	MrkDC2
	lsl.w	#6,d2
	lea	CopL1*EcMax+T_CopMark(a5),a4
	add.w	d2,a4
MrkDC1	tst.l	(a4)
	addq.l	#8,a4
	bne.s	MrkDC1
	clr.l	(a4)
	move.l	d3,-8(a4)
	move.l	d1,-4(a4)
* Adresses bitplanes IMPAIRS!
MrkDC2	move.w	(sp)+,d1
	add.w	EcVY(a2),d1		* Decalage ecran
	mulu	EcTLigne(a2),d1
	move.w	EcVx(a2),d2
	lsr.w	#4,d2
	lsl.w	#1,d2
	add.w	d2,d1
	move.l	a1,d3
	moveq	#EcPhysic,d2
	move.w	EcNPlan(a2),d6
	subq.w	#1,d6
	move.w	#Bpl1PtH+4,d7
MkdC12:	move.l	0(a2,d2.w),d5
	add.l	d1,d5
	move.w	d7,(a1)+
	addq.w	#2,d7
	swap	d5
	move.w	d5,(a1)+
	move.w	d7,(a1)+
	addq.w	#2,d7
	swap	d5
	move.w	d5,(a1)+
	addq.l	#4,d2
	addq.w	#4,d7
	dbra	d6,MkdC12
	move.w	EcNumber(a2),d2		* Marque les adresses
	cmp.w	#8,d2
	bcc.s	MrkDC4
	lsl.w	#6,d2
	lea	CopL1*EcMax+T_CopMark(a5),a4
	add.w	d2,a4
MrkDC3	tst.l	(a4)
	addq.l	#8,a4
	bne.s	MrkDC3
	clr.l	(a4)
	move.l	d3,-8(a4)
	move.l	d1,-4(a4)
MrkDC4
* Calcule les valeurs non plantantes!
	move.w	#465+16,d3
	tst.w	EcCon0(a0)
	bpl.s	MkdC1c
	sub.w	#16,d3
MkdC1c	move.w	EcWX(a0),d1
	addq.w	#1,d1
	move.w	EcWTx(a0),d2
	move.w	d1,d6
	add.w	d2,d6
	cmp.w	d3,d6
	bcs.s	MkdC1a
	sub.w	d3,d6
	add.w	#16,d6
	sub.w	d6,d2
	bra.s	MkdC1b
MkdC1a:	cmp.w	#176,d6
	bhi.s	MkdC1b
	sub.w	#176,d6
	sub.w	d6,d1
MkdC1b:	move.w	d1,EcWXr(a0)
	move.w	d2,EcWTxr(a0)
	move.w	#DiwStrt,(a1)+		;DiwStrt Y = 0
	move.w	d1,(a1)
	or.w	#$0100,(a1)+
	move.w	#DiwStop,(a1)+		;DiwStop Y = 311
	add.w	d2,d1
	and.w	#$00ff,d1
	or.w	#$3700,d1
	move.w	d1,(a1)+
* Calcul des valeurs modulo ---> D4/D5
	move.w	EcTLigne(a0),d4
	move.w	EcTLigne(a2),d5
	move.w	EcWTxr(a0),d6
	move.w	EcWTxr(a2),d7
	lsr.w	#3,d6
	lsr.w	#3,d7
	btst	#7,EcCon0(a0)
	bne.s	MkdC2
	lsr.w	#1,d6
	lsr.w	#1,d7
MkdC2:	lsl.w	#1,d6
	lsl.w	#1,d7
	sub.w	d6,d4
	bpl.s	MkdC2a
	clr.w	d4
MkdC2a:	sub.w	d7,d5
	bpl.s	MkdC2b
	clr.w	d5
MkdC2b:
* Calcul DDF Start/Stop---> D1/D2
	move.w	EcVX(a0),d6
	move.w	EcVX(a2),d7
	move.w	d6,d1
	and.w	#15,d1
	bne.s	Mkd2d
	and.w	#$FFF0,d7
Mkd2d:	move.w	d7,d1
	and.w	#15,d1
	bne.s	Mkd2e
	and.w	#$FFF0,d6
Mkd2e:	move.w	EcWXr(a0),d1
	move.w	EcWTxr(a0),d2
	btst	#7,EcCon0(a0)
	bne.s	MkdCH
* Lowres
	sub.w	#17,d1
	lsr.w	#1,d1
	and.w	#$FFF8,d1
	lsr.w	#1,d2
	subq.w	#8,d2
	add.w	d1,d2
	and.w	#15,d6
	and.w	#15,d7
	beq.s	MkdC3
	subq.w	#8,d1
	subq.w	#2,d4
	subq.w	#2,d5
	neg.w	d6
	add.w	#16,d6
	neg.w	d7
	add.w	#16,d7
	bra.s	MkdC3
* Hires
MkdCH:	sub.w	#9,d1
	lsr.w	#1,d1
	and.w	#$FFFC,d1
	lsr.w	#1,d2
	subq.w	#8,d2
	add.w	d1,d2
	and.w	#15,d6
	and.w	#15,d7
	lsr.w	#1,d6
	lsr.w	#1,d7
	beq.s	MkdC3
	subq.w	#4,d1
	subq.w	#4,d4
	subq.w	#4,d5
	neg.w	d6
	addq.w	#8,d6
	neg.w	d7
	addq.w	#8,d7
MkdC3:	lsl.w	#4,d7
	or.w	d7,d6
* Poke les valeurs
	move.w	#DdfStrt,(a1)+
	move.w	d1,(a1)+
	move.w	#DdfStop,(a1)+
	move.w	d2,(a1)+
	move.w	#Bpl1Mod,(a1)+
	move.w	d4,(a1)+
	move.w	#Bpl2Mod,(a1)+
	move.w	d5,(a1)+
* Registres de controle
	move.w	#BplCon0,(a1)+
	move.w	EcCon0(a0),d1
	or.w	T_InterInter(a5),d1
	move.w	d1,(a1)+
	move.w	#BplCon1,(a1)+
	move.w	d6,(a1)+
	move.w	#BplCon2,(a1)+
	move.w	EcCon2(a0),(a1)+
* Fini! Retourne au programme normal
	move.l	(sp)+,a2
	bra	FiniCop
	ENDC

******* Cree la ligne COPPER de fin de fenetre
EcCopBa	move.w	d0,d2
	sub.w	#EcYBase,d2
	bsr	WaitD2
	move.w	#DmaCon,(a1)+
	move.w	#$0100,(a1)+
	move.w	#Color00,(a1)+
	move.w	T_EcFond(a5),(a1)+
	rts

******* Attente copper jusqu'a la ligne D2
WaitD2:	cmp.w	#256,d2
	bcs.s	WCop
	tst.w	T_Cop255(a5)
	bne.s	WCop
	move.w	#$FFDF,(a1)+
	move.w	#$FFFE,(a1)+
	addq.w	#1,T_Cop255(a5)
WCop:	lsl.w	#8,d2
	or.w	#$03,d2
	move.w	d2,(a1)+
	move.w	#$FFFE,(a1)+
	rts

***********************************************************
*	INITIALISATION GENERALE LISTE COPPERS
*	D0= longueur des listes (physic et logic)
CpInit:
* Reserve la memoire pour les listes
	move.l	d0,T_CopLong(a5)
	bsr	ChipMm
	beq	GFatal
	move.l	d0,T_CopLogic(a5)
	move.l	d0,a0
	move.l	T_CopLong(a5),d0
	bsr	ChipMm
	beq	GFatal
	move.l	d0,T_CopPhysic(a5)
	move.l	d0,a1
* Copper en ROUTE!
	move.w	#-1,T_CopON(a5)
* Marque les offsets des listes sprites au debut...
HsCop	move.l	#$1003FFFE,(a0)+		Legere attente!
	move.l	-4(a0),(a1)+
	move.w	#$120,d0
CpI1:	move.w	d0,(a0)+
	move.w	d0,(a1)+
	addq.w	#2,d0
	addq.l	#2,a0
	addq.l	#2,a1
	cmp.w	#$13e,d0
	bls.s	CpI1
	moveq	#0,d0
	rts

***********************************************************
*	LIBERATION DES LISTES COPPER
CpEnd:	move.l	T_CopLogic(a5),d0
	beq.s	CpE1
	move.l	d0,a1
	move.l	T_CopLong(a5),d0
	bsr	FreeMm
CpE1:	move.l	T_CopPhysic(a5),d0
	beq.s	CpE2
	move.l	d0,a1
	move.l	T_CopLong(a5),d0
	bsr	FreeMm
CpE2:	rts


***********************************************************
*	GESTION DIRECTE COPPER
***********************************************************
	IFEQ	EZFlag
******* COPPER ON/OFF
TCopOn	tst.w	d1
	bne.s	ICpo1
* Copper OFF -> Hide!
	tst.w	T_CopON(a5)
	beq.s	ICpoX
	clr.w	T_CopON(a5)
	bsr	EcForceCop			* RAZ des pointeurs
	clr.l	T_HsChange(a5)			* Plus de HS!
	move.w	#-1,T_MouShow(a5)		* Plus de souris
	move.l	T_CopLogic(a5),T_CopPos(a5)	* Init!
	bsr	WVbl
	bra	TCopSw
* Copper ON -> Recalcule!
ICpo1	tst.w	T_CopON(a5)
	bne.s	ICpoX
	bsr	WVbl
	move.l	T_CopLogic(a5),a0		* Remet les listes sprites
	move.l	a0,a1
	bsr	HsCop
	bsr	TCpSw
	bsr	WVbl
	move.l	T_CopLogic(a5),a0
	move.l	a0,a1
	bsr	HsCop
	bsr	TCpSw
	bsr	WVbl
	move.w	#-1,T_CopON(a5)		* Remet!
	bsr	HsAff
	clr.w	T_MouShow(a5)
	bsr	EcForceCop		* Recalcule les listes
	bsr	WVbl
ICpoX	moveq	#0,d0
	rts

******* COPSWAP
TCopSw	tst.w	T_CopON(a5)
	bne	CopEr1
	move.l	T_CopPos(a5),a0
	move.l	#$FFFFFFFE,(a0)
TCpSw	move.l	T_CopLogic(a5),a0
	move.l	T_CopPhysic(a5),a1
	move.l	a1,T_CopLogic(a5)
	move.l	a0,T_CopPhysic(a5)
	move.l	a0,Circuits+Cop1Lc
******* COPRESET
TCopRes	tst.w	T_CopON(a5)
	bne	CopEr1
	move.l	T_CopLogic(a5),T_CopPos(a5)
	clr.w	T_Cop255(a5)
	moveq	#0,d0
	rts

******* COP WAIT x,y
*	D1=	X
*	D2=	Y
*	D3=	Masque X
*	D4=	Masque Y
TCopWt	tst.w	T_CopON(a5)
	bne	CopEr1
	cmp.w	#313,d1
	bcc	CopEr3
	cmp.w	#313,d2
	bcc	CopEr3
	move.l	T_CopPos(a5),a1
	cmp.w	#256,d2
	bcs.s	CopW1
	tst.w	T_Cop255(a5)
	bne.s	CopW1
	move.w	#$FFE1,(a1)+
	move.w	#$FFFE,(a1)+
	addq.w	#1,T_Cop255(a5)
CopW1	lsl.w	#8,d2			* Position en X/Y
	lsr.w	#1,d1
	and.w	#$00FE,d1
	or.w	#$01,d1
	or.w	d2,d1
	move.w	d1,(a1)+
	lsl.w	#8,d4			* Masque en X/Y
	lsr.w	#1,d3
	and.w	#$00FE,d3
	or.w	d4,d3
	move.w	d3,(a1)+
CopFin	move.l	a1,T_CopPos(a5)
	sub.l	T_CopLogic(a5),a1
	cmp.l	T_CopLong(a5),a1
	bcc	CopEr2
	moveq	#0,d0
	rts
CopEr1	moveq	#1,d0			* Copper not desactivated
	rts
CopEr2	moveq	#2,d0			* Copper list too long
	rts
CopEr3	moveq	#3,d0			* Copper param out of range
	rts

******* CMOVE ad,value
*	D1=	AD
*	D2=	Value
TCopMv	tst.w	T_CopON(a5)
	bne.s	CopEr1
	move.l	T_CopPos(a5),a1
	cmp.w	#512,d1
	bcc.s	CopEr3
	and.w	#$01FE,d1
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	bra	CopFin
******* CMOVEL ad,value
TCopMl	swap	d2
	bsr	TCopMv
	swap	d2
	addq.w	#2,d1
	bra	TCopMv
******* CBASE
TCopBs	move.l	T_CopLogic(a5),d1
	moveq	#0,d0
	rts
	ENDC

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* DIVERS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
;-----> Wait mouse key
WaitMK:	bsr	MBout
	cmp.w	#2,d1
	bne.s	WaitMk
Att:	bsr	MBout
	cmp.w	#0,d1
	bne.s	Att
	rts

;-----> OWN BLITTER
OwnBlit:movem.l	d0/d1/a0/a1/a6,-(sp)
	move.l	GfxBase(pc),a6
	jsr	_LVOOwnBlitter(a6)		OwnBlitter
	movem.l	(sp)+,d0/d1/a0/a1/a6
;-----> Wait blitter fini
BlitWait
	move.l	a6,-(sp)
	move.l	GfxBase(pc),a6
	jsr	_LVOWaitBlit(a6)
	move.l	(sp)+,a6
	rts
;-----> DISOWN BLITTER
DOwnBlit
	movem.l	d0/d1/a0/a1/a6,-(sp)
	move.l	GfxBase(pc),a6
	jsr	DisownBlitter(a6)
	movem.l	(sp)+,d0/d1/a0/a1/a6
	rts

;-----> Position du faisceau
PosVbl:	move.l 	$004(a6),d0
	lsr.l 	#8,d0
	and.w 	#$1FF,d0
	rts

******* RESERVATION MEMOIRE
FastMm	movem.l	a0/d1,-(sp)
	move.l	#CLEAR|PUBLIC,d1
	bsr	WMemReserve
	move.l	a0,d0
	movem.l	(sp)+,a0/d1
	rts
FastMm2	movem.l	a0/d1,-(sp)
	move.l	#PUBLIC,d1
	bsr	WMemReserve
	move.l	a0,d0
	movem.l	(sp)+,a0/d1
	rts
ChipMm	movem.l	a0/d1,-(sp)
	move.l	#CLEAR|PUBLIC|CHIP,d1
	bsr	WMemReserve
	move.l	a0,d0
	movem.l	(sp)+,a0/d1
	rts
ChipMm2	movem.l	a0/d1,-(sp)
	move.l	#PUBLIC|CHIP,d1
	bsr	WMemReserve
	move.l	a0,d0
	movem.l	(sp)+,a0/d1
	rts
FreeMm	bra	WMemFree

; Mini CHRGET: (a1)--->d0
miniget:move.b	(a1)+,d0     ;beq: fini
        beq.s 	mini5           ;bmi: lettre
        cmp.b 	#32,d0        ;bne: chiffre
        beq.s 	miniget
        cmp.b 	#"0",d0
        blt.s 	mini2
        cmp.b 	#"9",d0
        bhi.s 	mini2
        moveq 	#1,d7
        rts
mini2:  cmp.b 	#"a",d0       ;transforme en majuscules
        bcs.s 	mini3
        sub.b 	#32,d0
mini3:  moveq 	#-1,d7
mini5:  rts

; Prend un chiffre hexa--> D1
Gethexa:clr.w	d1
	bsr	MiniGet
	beq.s	GhX
	move.b	d0,d1
	sub.b	#"0",d1
	cmp.b	#9,d1
	bls.s	Gh1
	sub.b	#7,d1
Gh1:	cmp.b	#15,d1
	bhi.s	GhX
	moveq	#1,d0
	rts
GhX:	moveq	#0,d0
	rts

;Conversion dec/hexa a1 -> chiffre en d1
dechexa:clr 	d1         	; derniere lettre en D0
        clr 	d2
        bsr 	miniget
        beq.s 	Mdh5
        bpl.s 	Mdh2
        cmp.b 	#"-",d0
        bne.s 	Mdh5
        moveq 	#1,d2
Mdh0:   bsr 	miniget
        beq.s 	Mdh3
        bmi.s 	Mdh3
Mdh2:   mulu 	#10,d1
        sub.b 	#48,d0
        and 	#$00ff,d0
        add 	d0,d1
        bra.s 	Mdh0
Mdh3:   tst 	d2
        beq.s 	Mdh4
        neg 	d1
Mdh4:   clr 	d2              ;beq: un chiffre
        rts
Mdh5:   moveq 	#1,d2         	;bne: pas de chiffre
        rts

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* AMAL
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
******* CHRGET pour les animations
* 	SAUTE LES MINUSCULES! GENIAL!
AniChr	moveq	#0,d0
AniCh0:	move.b	(a0)+,d0
	beq.s	AnChX
	cmp.b	#33,d0
	bcs.s	AniCh1
	cmp.b	#"Z",d0
	bhi.s	AniCh1
AnChX:	rts
AniCh1:	cmp.b	#"|",d0
	beq.s	AnChX
	cmp.b	#"!",d0
	beq.s	AnChX
	cmp.b	#27,d0
	bne.s	AniCh0
	addq.l	#2,a0
	bra.s	AniCh0

******* Conversion DECIMAL/HEXA-> HEXA
AniLong	moveq	#1,d3
	bsr	AniChr
	cmp.b	#"-",d0
	bne.s	Adh0
	subq.w	#1,d3
	bsr	AniChr
Adh0:	cmp.b	#"$",d0			* Hexa????
	beq.s	Adhh0
	sub.b	#"0",d0
	bcs	AniE1
	cmp.b	#10,d0
	bcc	AniE1
	move.l	d0,d1
	subq.w	#1,d3
Adh1:   bsr 	AniChr
	sub.b	#"0",d0
	bcs.s	Adh2
	cmp.b 	#10,d0
        bcc.s 	Adh2
	add.l	d1,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1
	add.l	d0,d1
	bra.s	Adh1
Adh2:   subq.l 	#1,a0
        tst 	d3
	beq.s	AdhX
	bpl	AniE1
	neg.l	d1
AdhX:	move.l	d1,d0
	rts
* En Hexa!
Adhh0	bsr	AniChr
	bsr	Tohh
	bmi	AniE1
	move.l	d0,d1
	subq.w	#1,d3
Adhh1:  bsr 	AniChr
	bsr	Tohh
	bmi.s	Adh2
	lsl.l	#4,d1
	add.l	d0,d1
	bra.s	Adhh1
Tohh	sub.b	#"0",d0
	bcs.s	TohhE
	cmp.b	#10,d0
	bcs.s	TohhX
	sub.b	#"A"-"0",d0
	bcs.s	TohhE
	cmp.b	#6,d0
	bcc.s	TohhE
	add.b	#10,d0
TohhX	tst.b	d0
	rts
TohhE	moveq	#-1,d0
	rts

	IFEQ	EZFlag
***************************** FORMAT D'UNE SEQUENCE
NbInterne:	equ 10
AmPrev:		equ 0
AmNext:		equ 4
AmLong:		equ 8
AmNb:		equ 10
AmPos:		equ 12
AmAuto:		equ 16
AmAct:		equ 20
AmBit:		equ 24
AmCpt:		equ 26
AmDeltX:	equ 28
AmDeltY:	equ 32
AmVirgX:	equ 36
AmVirgY:	equ 38
AmFin:		equ 40
AmAJsr:		equ 44
AmAAd:		equ 48
AmAALoop:	equ 52
AmACLoop:	equ 56
AmACpt:		equ 58
AmIRegs:	equ 60
AmStart:	equ 60+NbInterne*2

***********************************************************
*	TOKENISATEUR AMAL
******* ENTREE
*	D3==> Type 0=Anim / 1= Move / 2= Move X / 3= Move Y
*	A1==> Chaine
*	A2/D2==> Buffer tokenisation
*	D1==> Buffer variables
******* SORTIE
*	D0==> ERREUR?
*	A0==> Longueur chaine
TokAMAL:
********
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	sp,T_AMALSp(a5)
	move.l	d7,-(sp)
	move.l	d7,T_AmBank(a5)

	move.l	a1,a0			* Debut chaine!
	move.l	d1,a1
	move.l	a2,d7			* Bas du buffer
	lea	0(a2,d2.w),a5		* Fin du buffer
	moveq	#0,d6
	move.l	d6,a6
	moveq	#0,d5			* Pas d'autotest
	moveq	#0,d4			* Pas d'erreur
* Init de la table des labels
	move.l	a1,a3
	moveq	#26/2,d0
	moveq	#-1,d1
InA0:	move.l	d1,(a3)+
	dbra	d0,InA0
* Table des FOR/NEXT
	lea	26*2+26*4(a1),a3	* 256 Octets de plus!
	move.l	#-1,(a3)+
	lea	AmJumps(pc),a4		* Table des decalages
* Stos type?
	tst.w	d3
	bne	AniStos

* Boucle d'interpretation
AniLoop	cmp.l	a5,a2
	bcc	AniTrop
	bsr	AniChr
	beq	AnPasse2
	move.w	d0,d1
	bsr	AniChr
	cmp.b	#":",d0
	beq	AnLab
	subq.l	#1,a0
	cmp.b	#"J",d1
	beq	AnJmp
	cmp.b	#"L",d1
	beq	AnLet
	cmp.b	#"M",d1
	beq	AnMove
	cmp.b	#"F",d1
	beq	AnFor
	cmp.b	#"N",d1
	beq	AnNext
	cmp.b	#"I",d1
	beq	AnIf
	cmp.b	#"W",d1
	beq	AnWait
	cmp.b	#"P",d1
	beq	AnPose
	cmp.b	#"E",d1
	beq	AnStop
	cmp.b	#"A",d1
	beq	AnAni
	cmp.b	#"D",d1
	beq	AnDirect
	cmp.b	#"X",d1
	beq	AnExit
	cmp.b 	#")",d1
	beq	AnAutOf
	bra	AniLoop
******* Trop long! Marque et boucle!
AniTrop:sub.l	d7,a2
	add.l	a2,a6
	move.l	d7,a2
	bra	AniLoop

******* AUto test
AnAutOn:addq.l	#1,a0
	bsr	AniChr
	tst.w	d5
	bne	AniE5
	cmp.b	#"(",d0
	bne	AniE1
	bsr	AniChr
	cmp.b	#")",d0
	beq.s	AnAu1
	subq.l	#1,a0
	move.w	$60/2(a4),(a2)+
	move.l	a2,d5
	sub.l	d7,d5
	swap	d5
	move.w	#1,d5
	clr.w	(a2)+
	bra	AniLoop
AnAu1:	move.w	$64/2(a4),(a2)+
	bra	AniLoop
******* FIN AUTOTEST / EXIT
AnExit:	tst.w	d5
	beq	AniE6
	move.w	$68/2(a4),(a2)+
	clr.w	(a2)+
	bra	AniLoop
AnAutOf	tst.w	d5
	beq	AniE6
	move.w	$68/2(a4),(a2)+
	move.l	a2,d0
	sub.l	d7,d0
	swap	d5
	sub.w	d5,d0
	move.l	a0,-(sp)
	move.l	d7,a0
	move.w	d0,0(a0,d5.w)
	move.l	(sp)+,a0
	moveq	#0,d5
	bra	AniLoop
******* DIRECT label EXTERNE!
AnDirect:
	tst.w	d5
	beq	AniE6
	move.w	$6C/2(a4),(a2)+
	bsr	AniChr
	sub.b	#"A",d0
	bcs	AniE1
	cmp.b	#26,d0
	bhi	AniE1
	lsl.w	#1,d0
	move.l	a2,d1
	sub.l	d7,d1
	move.w	d1,26*2(a1,d6.w)
	move.w	d0,26*2+2(a1,d6.w)
	addq.w	#4,d6
	move.w	#-1,26*2(a1,d6.w)
	clr.w	(a2)+
	bra	AniLoop

******* Un LABEL!
AnLab:	sub.b	#"A",d1
	bcs	AniE1
	cmp.b	#26,d1
	bhi	AniE1
	lsl.w 	#1,d1
	tst.w	0(a1,d1.w)
	bpl	AniE8
	move.l	a2,d0
	sub.l	d7,d0
	or.w	d5,d0
	move.w	d0,0(a1,d1.w)
	bra	AniLoop
******* Un BRANCHEMENT
AnJmp:	move.w	$1C/2(a4),(a2)+
	bsr	AniChr
	sub.b	#"A",d0
	bcs	AniE1
	cmp.b	#26,d0
	bhi	AniE1
	lsl.w	#1,d0
	move.l	a2,d1
	sub.l	d7,d1
	or.w	d5,d1
	move.w	d1,26*2(a1,d6.w)
	move.w	d0,26*2+2(a1,d6.w)
	addq.w	#4,d6
	move.w	#-1,26*2(a1,d6.w)
	clr.w	(a2)+
	bra	AniLoop

*******	For RA=deb To end
AnFor:	tst.w	d5
	bne	AniE9
	move.w	$28/2(a4),(a2)+
	bsr	AniReg
	beq	AniE1
	cmp.w	#$000C/2,d1
	bne	AniE1
	swap	d2
	move.w	d2,-(sp)		* Poke le debut
	bsr	AniChr
	cmp.b	#"=",d0
	bne	AniE1
	bsr	AniExp
	bsr	AniChr			* Poke le TO
	cmp.b	#"T",d0
	bne	AniE1
	bsr	AniExp
	move.l	a2,(a3)+
	move.w	(sp)+,d2		* Poke la variable
	move.w	d2,(a3)+
	move.w	d2,(a2)+
	clr.w	(a2)+			* Place pour le TO!
	bra	AniLoop
******* NEXT RA
AnNext:	tst.w	d5
	bne	AniE9
	move.w	$2C/2(a4),(a2)+
	bsr	AniReg
	beq	AniE1
	cmp.w	#$000C/2,d1
	bne	AniE1
	swap	d2
	cmp.w	-(a3),d2
	bne	AniE2
	move.l	-(a3),d0
	sub.l	a2,d0
	move.w	d0,(a2)+
	bra	AniLoop

******* LET
AnLet:	move.w	$20/2(a4),(a2)+
	bsr	AniReg
	beq	AniE1
	add.w	#$0030/2,d1
	movem.l	d1-d3,-(sp)
	bsr	AniChr
	cmp.b	#"=",d0
	bne	AniE1
	bsr	AniExp
	movem.l	(sp)+,d1-d3
	move.w	0(a4,d1.w),(a2)
	move.l	d2,2(a2)
	add.w	d3,a2
	bra	AniLoop

******* TESTS
AnIf:	move.w	$24/2(a4),(a2)+
	bsr	AniExp
	bsr	AniChr
	cmp.b	#"J",d0
	beq	AnJmp
	cmp.b	#"D",d0
	beq	AnDirect
	cmp.b	#"X",d0
	beq	AnExit
	bra	AniE1

******* MOVE DeltaX,DeltaY,Nbstep
AnMove:	tst.w	d5
	bne	AniE9
	move.w	$18/2(a4),(a2)+
	bsr	AniExp
	bsr	AniChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniExp
	bsr	AniChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniExp
	bra	AniLoop


******* PAUSE
AnPose:	cmp.b 	#"L",(a0)
	beq.s	AnPlay
	move.w	$0014/2(a4),(a2)+
	bra	AniLoop
******* END
AnStop:	move.w	$0000/2(a4),(a2)+
	bra	AniLoop
******* WAIT
AnWait:	tst.w	d5
	bne	AniE9
	move.w	$0010/2(a4),(a2)+
	bra	AniLoop
******* PLay Exp
AnPlay:	addq.l	#1,a0
	tst.l	(sp)
	beq	AniE10
	move.w	$00C0/2(a4),(a2)+
	bsr	AniExp
	bra	AniLoop
******* Anim
AnAni:	cmp.b	#"U",(a0)
	beq	AnAutOn
	move.w	$CC/2(a4),(a2)+
	bsr	AniExp
	move.l	a2,-(sp)
	clr.w	(a2)+
	bsr	AniChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniChr
	cmp.b	#"(",d0
	bne	AniE1
AnAni1	bsr	AniExp
	bsr	AniChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniExp
	bsr	AniChr
	cmp.b	#")",d0
	bne	AniE1
	bsr	AniChr
	cmp.b	#"(",d0
	beq.s	AnAni1
	subq.l	#1,a0
	clr.w	(a2)+
	move.l	(sp),d0
	move.l	a2,(sp)
	exg	d0,a2
	sub.l	a2,d0
	move.w	d0,(a2)
	move.l	(sp)+,a2
	bra	AniLoop

***********************************************************
*	COMPATIBLE STOS!
AniStos	move.l	a0,-(sp)
	move.l	(sp)+,a0
	cmp.w	#1,d3
	bne.s	AnMve
******* ANIMATION!
	move.w	$04/2(a4),(a2)+
	bsr	StChr
	cmp.b	#"(",d0
	bne	AniE1
AnSt0	bsr	AniLong
	move.w	d0,(a2)+
	bsr	StChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniLong
	move.w	d0,(a2)+
	bmi	AniE1
	bsr	StChr
	cmp.b	#")",d0
	bne	AniE1
AnSt1:	bsr	StChr
	beq.s	AnSt2
	cmp.b	#"L",d0
	beq.s	AnSt3
	cmp.b	#"(",d0
	beq.s	AnSt0
	bra	AniE1
AnSt2	move.w	#-1,(a2)+
	bra	AnPasse2
AnSt3	move.w	#-2,(a2)+
	bra	AnPasse2
* Mouvement X ou Y!
AnMve:	move.w	$08/2(a4),d0
	cmp.w	#2,d3
	beq.s	AnMv1
	move.w	$0C/2(a4),d0
AnMv1	move.w	d0,(a2)+
	move.l	a2,a3
	move.w	#$8000,(a2)+		* Debut
	clr.w	(a2)+			* Loop/End
	move.w	#$8000,(a2)+		* End
	bsr	StChr
	beq	AniE1
	cmp.b	#"(",d0
	beq.s	AnMv2
	subq.l	#1,a0
	bsr	AniLong
	move.w	d0,(a3)
	bsr	StChr
	cmp.b	#"(",d0
	bne	AniE1
AnMv2	bsr	AniLong
	move.w	d0,(a2)+
	ble	AniE1
	bsr	StChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniLong
	move.w	d0,(a2)+
	bsr	StChr
	cmp.b	#",",d0
	bne	AniE1
	bsr	AniLong
	move.w	d0,(a2)+
	bmi	AniE1
	bsr	StChr
	cmp.b	#")",d0
	bne	AniE1
	bsr	StChr
	cmp.b	#"(",d0
	beq.s	AnMv2
	clr.w	(a2)+
	tst.b	d0
	beq	AnPasse2
	cmp.b	#"L",d0
	bne.s	AnMv3
	move.w	#-1,2(a3)
	bra.s	AnMv4
AnMv3	cmp.b	#"E",d0
	bne	AniE1
AnMv4	bsr	StChr
	beq	AnPasse2
	subq.l	#1,a0
	bsr	AniLong
	move.w	d0,4(a3)
	bra	AnPasse2
******* Chrget pour stos type!
StChr:	moveq	#0,d0
StChr1	move.b	(a0)+,d0
	beq.s	StChr2
	cmp.b	#32,d0
	beq.s	StChr1
	cmp.b	#"a",d0
	bcs.s	StChr2
	cmp.b	#"z",d0
	bhi.s	StChr2
	sub.b	#32,d0
StChr2	rts

***********************************************************
* 	DEUXIEME PASSE: affecte les labels!
AnPasse2:
	move.w	$00/2(a4),(a2)+
	sub.l	d7,a2
	exg.l	d7,a2
	lea	26*2(a1),a0
	moveq	#0,d0
AnLoop2	move.w	(a0)+,d0
	bmi.s	AniX
	move.w	d0,d2
	and.w	#$0001,d2
	and.w	#$FFFE,d0
	move.w	(a0)+,d1
	move.w	0(a1,d1.w),d1
	bmi	Aniee3
	move.w	d1,d3
	and.w	#$0001,d3
	and.w	#$FFFE,d1
	cmp.w	d2,d3
	bne	Aniee4
	sub.w	d0,d1
	move.w	d1,0(a2,d0.w)
	bra.s	AnLoop2
******* Tout est fini!
AniX:	addq.l	#4,sp
	cmp.l	#0,a6
	bne.s	AniX2
	move.l	d7,a0
	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#0,d0
	rts
AniX2:	move.l	a6,a0
	add.l	d7,a0
	movem.l	(sp)+,d1-d7/a1-a6	* -1-> Pas assez de place!
	moveq	#-1,d0			* A0= longueur necessaire!
	rts
Aniee3:	lea	0(a2,d0.w),a0
	bra.s	Anie3
Aniee4:	lea	0(a2,d0.w),a0
	bra.s	Anie4
	ENDC

******* ERREUR!
AniE10:	addq.w	#1,d4			* PLay only with bank
AniE9:	addq.w	#1,d4			* Not authorised during autotest
AniE8:	addq.w	#1,d4			* Label already def
AniE7:	addq.w	#1,d4			* String too long
AniE6:	addq.w	#1,d4			* Autotest not opened
AniE5:	addq.w	#1,d4			* Autotest already on
AniE4:	addq.w	#1,d4			* Jump To/Within AUTOTEST
AniE3:	addq.w	#1,d4			* Label not defined
AniE2:	addq.w	#1,d4			* Next /For
AniE1:	move.l	W_Base(pc),a5
	move.l	T_AMALSp(a5),d1		* Vient de RAINBOW?
	beq	RainEE
	move.l	d1,sp
	addq.w	#1,d4			* Syntax error
	move.l	d4,d0
	movem.l	(sp)+,d1-d7/a1-a6
	sub.l	a1,a0			* Offset de l'erreur
	tst.w	d0
	rts

	IFEQ	EZFlag

***********************************************************
*	ROUTINES INTERPRETATION
******* Prend X/Y/A/ ou REG
AniReg:	bsr	AniChr
AniR:	moveq	#$00/2,d1
	cmp.b	#"A",d0
	beq.s	AniRx
	moveq	#$04/2,d1
	cmp.b	#"X",d0
	beq.s	AniRx
	moveq	#$08/2,d1
	cmp.b	#"Y",d0
	beq.s	AniRx
	cmp.b	#"R",d0
	bne.s	AniRe
* R
	moveq	#$0C/2,d1
	bsr	AniChr
	sub.b	#"0",d0
	bcs	AniRe
	cmp.b	#NbInterne,d0
	bcc.s	AniR0
	addq.w	#1,d0
	neg.w	d0
	bra.s	AniR1
AniR0:	sub.b	#"A"-"0",d0
	bcs	AniRe
	cmp.b	#26,d0
	bhi	AniRe
AniR1:	lsl.w	#1,d0
	move.w	d0,d2
	swap 	d2
	moveq	#4,d3
	rts
* Autres
AniRx:	moveq	#2,d3
	rts
* Pas un registre
AniRe:	subq.l	#1,a0
	moveq	#0,d3
	rts

******* Operande!
AniOpe:	bsr	AniChr
	cmp.b	#"K",d0
	beq.s	AniMou
	cmp.b	#"J",d0
	beq.s	AniJoy
	cmp.b	#"O",d0
	beq.s	AniOn
	cmp.b	#"S",d0
	beq	AniSCol
	cmp.b 	#"B",d0
	beq	AniBCol
	cmp.b 	#"C",d0
	beq	AniCol
	cmp.b	#"Z",d0
	beq	AniHaz
	cmp.b	#"V",d0
	beq	AniVu
	cmp.b	#"-",d0
	beq.s	AniOc
	cmp.b	#"$",d0
	beq.s	AniOc
	cmp.b	#"0",d0
	bcs.s	AniO1
	cmp.b	#"9",d0
	bhi.s	AniO1
* Chiffre!
AniOc:	subq.l	#1,a0
	bsr	AniLong
	move.w	$70/2(a4),(a2)+
	move.w	d0,(a2)+
	rts
* =On
AniOn:	move.w	$50/2(a4),(a2)+
	rts
* Saisie du joystick!
AniJoy:	bsr	AniChr
	move.w	$80/2(a4),d1
	cmp.b	#"0",d0
	beq.s	AniO0
	move.w	$84/2(a4),d1
	cmp.b	#"1",d0
	bne	AniE1
AniO0:	move.w	d1,(a2)+
	rts
* Saisie touches souris!
AniMou:	bsr	AniChr
	move.w	$88/2(a4),d1
	cmp.b	#"1",d0
	beq.s	AniO0
	move.w	$8C/2(a4),d1
	cmp.b	#"2",d0
	beq.s	AniO0
	bra	AniE1
* Autres registres
AniO1:	bsr	AniR
	beq	AniE1
	cmp.w	#$04/2,d1
	beq.s	AniO4
	cmp.w	#$08/2,d1
	beq.s	AniO4
* Un registre normal
AniO2:	add.w	#$0040/2,d1
	bra	AniO5
* X-Y  MOUSE/SCREEN/HARD
AniO4:	bsr	AniChr
	subq.l	#1,a0
	cmp.b	#"S",d0
	beq.s	AniO4a
	cmp.b	#"H",d0
	beq.s	AniO4b
	cmp.b	#"M",d0
	bne.s	AniO2
	add.w	#$0070/2,d1
	addq.l	#1,a0
	bra	AniO5
AniO4a:	add.w	#$0050/2,d1
	bra.s	AniO4c
AniO4b	add.w	#$00C0/2,d1
AniO4c:	addq.l	#1,a0
	move.w	0(a4,d1.w),(a2)+
AniPp2:	bsr	AniChr
	cmp.b	#"(",d0
	bne	AniRe
	bra.s	AniP2
* = Col(n)
AniCol:	move.w	$005C/2(a4),(a2)+
AniPp1:	bsr	AniChr
	cmp.b	#"(",d0
	bne	AniRe
	bsr	AniExp
	bsr	AniChr
	cmp.b	#")",d0
	bne	AniRe
	rts
* = Spr Col(n,x,y)
AniSCol	move.w	$00B8/2(a4),(a2)+
	bra.s	AniCo
* = Bob Col(n,x,y)
AniBCol:move.w	$00BC/2(a4),(a2)+
AniCo:	bsr	AniChr
	cmp.b	#"C",d0
	bne	AniRe
AniPp3:	bsr	AniChr
	cmp.b	#"(",d0
	bne	AniRe
	bsr	AniExp
	bsr	AniChr
	cmp.b	#",",d0
	bne	AniRe
AniP2:	bsr	AniExp
	bsr	AniChr
	cmp.b	#",",d0
	bne	AniRe
	bsr	AniExp
	bsr	AniChr
	cmp.b	#")",d0
	bne	AniRe
	rts
* Poke!
AniO5:	move.w	0(a4,d1.w),(a2)
	move.l	d2,2(a2)
	add.w	d3,a2
	rts
* =H(xx)
AniHaz	move.w	$D0/2(a4),(a2)+
	bra	AniPp1
* =V(xx)
AniVu	move.w	$D4/2(a4),(a2)+
	bra	AniPp1

******* EXPRESSION
AniExp:	bsr	AniOpe
AniE0:	bsr	AniChr
	moveq	#$0090/2,d1
	cmp.b	#"=",d0
	beq.s	AniEx1
	addq.w	#4,d1
	cmp.b	#"<",d0
	bne.s	AniEx0
	cmp.b	#">",(a0)
	bne.s	AniEx1
	subq.w	#2,d1
	addq.l	#1,a0
	bra.s	AniEx1
AniEx0:	addq.w	#2,d1
	cmp.b	#">",d0
	beq.s	AniEx1
	addq.w	#2,d1
	cmp.b	#"+",d0
	beq.s	AniEx1
	addq.w	#2,d1
	cmp.b	#"-",d0
	beq.s	AniEx1
	addq.w	#2,d1
	cmp.b	#"/",d0
	beq.s	AniEx1
	addq.w	#2,d1
	cmp.b	#"*",d0
	beq.s	AniEx1
	addq.w	#2,d1
	cmp.b	#"|",d0
	beq.s	AniEx1
	addq.w	#2,d1
	cmp.b	#"&",d0
	beq.s	AniEx1
	cmp.b	#"!",d0
	beq.s	AniXor
* Fin de l'expression
	move.w	$7c/2(a4),(a2)+
	subq.l	#1,a0
	rts
* Special pour XOR
AniXor	moveq	#$00D8/2,d1
* Cherche le deuxieme operande
AniEx1	move.w	0(a4,d1.w),-(sp)
	bsr	AniOpe
	move.w	(sp)+,(a2)+
	bra	AniE0

***********************************************************
*	INITIALISATION AMAL
AMALInit:
********
	clr.l	T_AmDeb(a5)
	clr.l	T_AmChaine(a5)
	move.w	#$1234,T_AmSeed(a5)
***********************************************************
*	CLEAR AMAL
ClrAMAL:
*******
	bsr	DAllAMAL
	lea	T_AmRegs(a5),a0
	moveq	#26/2-1,d0
ClAm:	clr.l	(a0)+
	dbra	d0,ClAm
	moveq	#0,d0
	rts

***********************************************************
*	SYNCHRO: D1= on/off
SyncO:	move.w	d1,T_SyncOff(a5)
	moveq	#0,d0
	rts
Sync:	tst	T_SyncOff(a5)
	beq.s	Sync1
	movem.l	d2-d7/a2-a6,-(sp)
	bsr	Animeur
	movem.l	(sp)+,d2-d7/a2-a6
Sync1:	rts

***********************************************************
*	RAMENE L'ADRESSE UN REGISTRE
*	D1= -1-> generaux / # du mouvement
*	D2= type du mouvement
*	D3= numero du registre
RegAMAL:
*******
	lea	T_AmRegs(a5),a0
	lsl.w	#1,d3
	tst.w	d1
	bmi.s	RgA3
* Registres internes
	move.l	T_AmDeb(a5),d0
	beq.s	RgA1
	lsl.w	#2,d1
	add.w	d2,d1
RgA0	move.l	d0,a1
	cmp.w	AmNb(a1),d1
	beq.s	RgA2
	bcs.s	RgA1
	move.l	AMNext(a1),d0
	bne.s	RgA0
RgA1	moveq	#-1,d0
	rts
RgA2:	lea	AmIRegs+NbInterne*2-2(a1),a0
	neg.w	d3
RgA3:	add.w	d3,a0
	moveq	#0,d0
	rts

***********************************************************
*	AMAL PLAY
*	D1= Debut
*	D2= Fin
*	D3= Speed (R0)
*	D4= Direction (R1)
SetPlay:
*******
	move.l	T_AmDeb(a5),d0
	beq.s	StPx
	lsl.w	#2,d1
	lsl.w	#2,d2
	move.l	#EntNul,d5
StP1:	move.l	d0,a1
	move.w	AmNb(a1),d0
	cmp.w	d2,d0
	bhi.s	StPx
	cmp.w	d1,d0
	bcs.s	StP3
	cmp.l	d5,d3
	beq.s	StP2
	move.w	d3,AmIRegs+NbInterne*2-2(a1)
StP2:	cmp.l	d5,d4
	beq.s	StP3
	move.w	d4,AmIRegs+NbInterne*2-4(a1)
StP3:	move.l	AMNext(a1),d0
	bne.s	StP1
StPx:	moveq	#0,d0
	rts

***********************************************************
*	CREATION / REMPLACEMENT D'UNE ANIMATION
*	A1=	Chaine a tokeniser
*	A2/D2=	Buffer de tokenisation
*	D1=	Buffer variables
*	D3= 	0-> Amal / 1-> Anim / 2-> X / 3-> Y
*	D4= 	0-> Sprite / 1-> Bobs / 2-> Ecrans / 3-> Adresse
*	D5= 	# De l'objet
*	D6= 	# du Canal
CreAMAL:
********
******* Va tokeniser!
	bsr	TokAMAL
	tst.w	d0
	beq.s	CreA0
	bpl	CreAmE
* Pas assez de place! Reserve et RE-tokenise!
	add.w	#AmStart+4,a0
	move.l	a0,d0
	move.l	d0,d2
	bsr	FastMm
	beq	CreME
	move.l	d0,a2
	move.w	d2,AmLong(a2)
	sub.l	#AmStart+4,d2
	lea	AmStart(a2),a2
	bsr	TokAMAL
	lea	-AmStart(a2),a2
	sub.l	a0,a0
* Ok!
CreA0:	move.l	a0,d1
	move.w	d6,d2

******* Insere dans la liste
	clr.l	T_AmChaine(a5)
	clr.l	T_AmFreeze(a5)
******* ID complet!
	lsl.w	#2,d2
	add.w	d3,d2

******* Efface l'ancienne - SI PRESENT -
	move.l	a1,a0
	move.l	T_AmDeb(a5),d0
	beq.s	CreAm1
CreAm0:	move.l	d0,a1
	cmp.w	AmNb(a1),d2
	beq.s	CreAm2
	bcs.s	CreAm5
	move.l	AmNext(a1),d0
	bne.s	CreAm0
* Met a la fin!
	bsr	ResAMAL
	bne	CreAmE
	move.l	a1,AmPrev(a0)
	move.l	a0,AmNext(a1)
	bra.s	CreAm10
* Au tout debut
CreAm1:	bsr	ResAMAL
	bne	CreAmE
	move.l	a0,T_AmDeb(a5)
	bra.s	CreAm10
* Remplace l'ancienne chaine
CreAm2:	move.l	AmPrev(a1),d6
	move.l	AmNext(a1),d7
	moveq	#0,d0
	move.w	AmLong(a1),d0
	bsr	FreeMm
	bsr	ResAMAL
	move.w	d0,-(sp)
	move.l	d6,AmPrev(a0)
	move.l	d7,AmNext(a0)
	beq.s	CreAm3
	move.l	d7,a1
	move.l	a0,AmPrev(a1)
CreAm3:	tst.l	d6
	bne.s	CreAm4
	move.l	a0,T_AmDeb(a5)
	bra.s	CreAm4a
CreAm4:	move.l	d6,a1
	move.l	a0,AmNext(a1)
CreAm4a	move.w	(sp)+,d0
	beq.s	CreAm10
	bra.s	CreAmE
* Insere la nouvelle
CreAm5:	bsr	ResAMAL
	bne	CreAmE
	move.l	AmPrev(a1),d0
	move.l	a0,AmPrev(a1)
	move.l	d0,AmPrev(a0)
	bne.s	CreAm6
	move.l	T_AmDeb(a5),d3
	move.l	a0,T_AmDeb(a5)
	bra.s	CreAm7
CreAm6:	move.l	d0,a2
	move.l	AmNext(a2),d3
	move.l	a0,AmNext(a2)
CreAm7:	move.l	d3,AmNext(a0)
******* Pas d'erreur!
CreAm10	move.l	T_AmDeb(a5),T_AmChaine(a5)
	moveq	#0,d0
	rts
******* Erreur!
CreAmE:	tst.w	d0
	rts
CreME:	moveq	#-1,d0
	bra.s	CreAME

******* CREATION DE LA TABLE!
ResAMAL:tst.l	d1
	beq.s	ResDeja
* Reserve la memoire pour la table, et copie le buffer!
	move.l	a2,a0
	add.w	#AmStart+4,d1
	moveq	#0,d0
	move.w	d1,d0
	bsr	FastMm
	beq	ResAErr
	move.l	d0,a2
	move.w	d1,AmLong(a2)
	move.w	d2,AmNb(a2)
	move.l	a1,-(sp)		* Copie la table
	lea	AmStart(a2),a1
	move.l	a1,AmPos(a2)
	sub.w	#AmStart+4,d1
	lsr.w	#2,d1
ResAc:	move.l	(a0)+,(a1)+
	dbra	d1,ResAc
	move.l	(sp)+,a1
	bra.s	ResPas
* Table deja reservee!
ResDeja	move.w	d2,AmNb(a2)
	lea	AmStart(a2),a0
	move.l	a0,AmPos(a2)

* Calcule l'adresse ACT
ResPas:	move.l	a2,a0
	cmp.w	#6,d4
	beq	ResRain
	cmp.w	#5,d4
	beq	ResAdd
	subq.w	#1,d4
	bmi.s	ResAs
	beq.s	ResAb

******* Creation ECRANS
	lsl.w	#2,d5
	lea	T_EcAdr(a5),a2
	move.l	0(a2,d5.w),d5
	beq.s	ResAee
	move.l	d5,a2
	subq.w	#2,d4
	bmi.s	ResAe3
	beq.s	ResAe2
* Ecrans OFFSET
	add.w	#EcAV,a2
	bra.s	ResAe4
* Ecrans TAILLE
ResAe2:	add.w	#EcAWT,a2
	bra.s	ResAe4
* Ecrans position
ResAe3:	add.w	#EcAW,a2
ResAe4:	move.l	a2,AmAct(a0)
	move.w	#$8000+BitEcrans,AmBit(a0)
	moveq	#0,d0
	rts
* Erreur! Screen not opened
ResAee:	moveq	#-3,d0
	bra.s	ResAEx

******* Creation BOBS
ResAb:	move.w	d5,d1
	movem.l	a0/a1,-(sp)
	bsr	BobAd
	bne.s	ResAbe
	lea	BbAct(a1),a2
	movem.l	(sp)+,a0/a1
	move.l	a2,AmAct(a0)
	move.w	#$8000+BitBobs,AmBit(a0)
	moveq	#0,d0
	rts
* Erreur! BOB not defined
ResAbe:	movem.l	(sp)+,a0/a1
	moveq	#-24,d0
	bra.s	ResAEx

******* Creation SPRITES
ResAs:	lsl.w	#3,d5
	lea	T_HsTAct(a5),a2
	add.w	d5,a2
	move.l	a2,AmAct(a0)
	move.w	#$8000+BitSprites,AmBit(a0)
	moveq	#0,d0
	rts

******* Creation ADRESSE
ResAdd:	move.l	d5,AmAct(a0)
	move.l	d4,d0
	swap	d0
	and.w	#$00FF,d0
	add.w	#$8000,d0
	move.w	d0,AmBit(a0)
	moveq	#0,d0
	rts

******* Creation RAINBOW
ResRain	lea	T_RainTable(a5),a2
	mulu	#RainLong,d5
	lea	RnAct(a2,d5.w),a2
	move.l	a2,AmAct(a0)
	move.w	#$8000+BitEcrans,AmBit(a0)
	moveq	#0,d0
	rts

******* Erreur memoire!
ResAErr	moveq	#-1,d0
	rts
******* Efface la table si ERREUR!
ResAex:	move.l	d0,-(sp)
	move.l	a0,a1
	moveq	#0,d0
	move.w	AmLong(a1),d0
	bsr	FreeMm
	move.l	(sp)+,d0
	rts

***********************************************************
*	ARRET D'UN CANAL avec une adresse ACTUALISATION
*	A0= Adresse ACTUALISATION
DAdAMAL:
********
	movem.l	d1-d7/a0-a2,-(sp)
	move.l	T_AmDeb(a5),d6
	clr.l	T_AmChaine(a5)
	clr.l	T_AmFreeze(a5)
	move.l	d6,d5
	beq	MvOx
	move.l	a0,d7
DAdAM1:	move.l	d5,a1
	cmp.l	AmAct(a1),d7
	beq.s	DAdAM2
	move.l	AmNext(a1),d5
	bne.s	DAdAM1
	bra	MvOx
DAdAM2:	move.l	AmNext(a1),d5
	bsr	DAMAL
	tst.l	d5
	bne.s	DAdAM1
	bra	MvOx

***********************************************************
*	ADRESSE D'UN CANAL: D1= Numero!
*	D6= AmDeb!
AdAMAL:
*******
	move.l	d6,d5
	beq.s	AdAmal1
	lsl.w	#2,d1
AdAmal0	move.l	d5,a1
	move.w	AmNb(a1),d0
	and.w	#$FFFC,d0
	cmp.w	d0,d1
	beq.s	AdAmal2
	bcs.s	AdAmal3
	move.l	AMNext(a1),d5
	bne.s	AdAmal0
AdAmal1 rts
AdAmal2 move.l	AmNext(a1),d5
	move.w	AmNb(a1),d7
	and.w	#$0003,d7
	moveq	#-1,d0
	rts
AdAmNx:	tst.l	d5
	bne.s	AdAmal0
	rts
AdAmal3 moveq	#0,d0
	rts

***********************************************************
*	=AMAL ADRESSE
*	D1= #
TAmAd:	move.l	T_AmDeb(a5),d6
	bsr	AdAmal
	move.l	a1,d1
	tst.w	d0
	rts
***********************************************************
*	=MOVON
*	D1= #
TMovon	move.l	T_AmDeb(a5),d6
	bsr	AdAmal
	beq.s	TMvo1
TMvo0	cmp.w	#2,d7
	beq.s	TMvo3
	cmp.w	#3,d7
	beq.s	TMvo3
	bsr	AdAmNx
	bne.s	TMvo0
TMvo1	moveq	#0,d1
	rts
TMvo3	tst.w	AmBit(a1)
	bmi.s	TMvo1
	tst.l	AmAJsr(a1)
	beq.s	TMvo1
TMvo2	moveq	#-1,d1
	rts
***********************************************************
*	= CHANAN
*	D1= #
RChan	move.l	T_AmDeb(a5),d6
	bsr	AdAmal
	beq.s	RChan1
	tst.w	AmBit(a1)
	bpl.s	RChan2
RChan1	addq.l	#4,sp
	moveq	#0,d1
RChan2	rts
TChanA	bsr	RChan
	tst.l	AmAJsr(a1)
	beq.s	TMvo1
	bne.s	TMvo2
TChanM	bsr	RChan
	tst.l	AmPos(a1)
	beq.s	TMvo1
	bne.s	TMvo2

***********************************************************
*	OFF/ON/FREEZE
*	D1= -1 -> TOUS / D1=#
*	D2= Bit a 1--> A Changer
*	D3= -1-> OFF / 0-> Freeze / 1-> On
MvOAMAL:
*******
	movem.l	d1-d7/a0-a2,-(sp)
	move.l	T_AmDeb(a5),d6
	clr.l	T_AmFreeze(a5)
	clr.l	T_AmChaine(a5)

	tst.w	d1
	bmi.s	MvOAll
	bsr	AdAMAL
	beq.s	MvOx
******* Efface
MvO1:	btst	d7,d2
	beq.s	MvO2
	bsr	OnOfFrz
MvO2:	bsr	AdAMNx
	bne.s	MvO1

* FINI!
MvOx:	move.l	d6,T_AmDeb(a5)
	move.l	d6,T_AmChaine(a5)
	movem.l	(sp)+,d1-d7/a0-a2
	moveq	#0,d0
	rts

******* ARRETE TOUT!
MvOAll:	move.l	d6,d5
	beq.s	MvOx
MvOA1:	move.l	d5,a1
	move.l	AmNext(a1),d5
	move.w	AmNb(a1),d7
	and.w	#$0003,d7
	btst	d7,d2
	beq.s	MvOA2
	bsr	OnOfFrz
MvOA2:	tst.l	d5
	bne.s	MvOA1
	bra	MvOx

******************************************* ENLEVE / MET / FREEZE
OnOfFrz	tst.w	d3
	bmi.s	DAMAL
	beq.s	OoF
* On!
	and.w	#$7FFF,AmBit(a1)
	rts
* Freeze
OoF:	or.w	#$8000,AmBit(a1)
	rts
****************************************** Enleve!
*	D6= AmDeb!
DAMAL:	movem.l	d0-d3,-(sp)
	move.l	AmNext(a1),d3
	move.l	AmPrev(a1),d2
	beq.s	DAMAL3
	move.l	d2,a0
	move.l	d3,AmNext(a0)
	bra.s	DAMAL4
DAMAL3:	move.l	d3,d6
DAMAL4:	tst.l	d3
	beq.s	DAMAL5
	move.l	d3,a0
	move.l	d2,AmPrev(a0)
DAMAL5:	move.w	AmLong(a1),d0
	ext.l	d0
	bsr	FreeMm
	movem.l	(sp)+,d0-d3
	rts

***********************************************************
*	EFFACEMENT TOUS CANAUX
DAllAMAL:
AMALEnd:
********
	moveq	#-1,d1
	moveq	#%1111,d2
	moveq	#-1,d3
	bra	MvOAMAL

***********************************************************
*	FREEZE AMAL
FrzAMAL:
********
	tst.l	T_AmFreeze(a5)
	bne.s	FrzA
	move.l	T_AmChaine(a5),T_AmFreeze(a5)
	clr.l	T_AmChaine(a5)
FrzA:	moveq	#0,d0
	rts
**********************
*	UNFREEZE AMAL
********
UFrzAMAL:
	tst.l	T_AmChaine(a5)
	bne.s	UFrzA
	move.l	T_AmFreeze(a5),d0
	beq.s	FrzA
	move.l	d0,T_AmChaine(a5)
UFrzA:	clr.l	T_AmFreeze(a5)
	bra.s	FrzA


******* BRANCHEMENT AUX FONCTIONS
AmJumps	dc.w 	AmStop-AmJumps			* 00
	dc.w	AmAnim-AmJumps			* 04
	dc.w	AmMvtX-AmJumps			* 08
	dc.w 	AmMvtY-AmJumps			* 0C
	dc.w	AmWait-AmJumps			* 10
	dc.w	AmPose-AmJumps			* 14
	dc.w	AmMove-AmJumps			* 18
	dc.w	AmJump-AmJumps			* 1C
	dc.w	AmLet-AmJumps			* 20
	dc.w	AmIf-AmJumps			* 24
	dc.w	AmFor-AmJumps			* 28
	dc.w	AmNxt-AmJumps			* 2C
	dc.w	AmAEg-AmJumps			* 30
	dc.w	AmXEg-AmJumps			* 34
	dc.w	AmYEg-AmJumps			* 38
	dc.w	AmREg-AmJumps			* 3C
	dc.w	AmEgA-AmJumps			* 40
	dc.w	AmEgX-AmJumps			* 44
	dc.w	AmEgY-AmJumps			* 48
	dc.w	AmEgR-AmJumps			* 4C
	dc.w	AmOn-AmJumps			* 50
	dc.w	AmXS-AmJumps			* 54
	dc.w	AmYS-AmJumps			* 58
	dc.w	AmCol-AmJumps			* 5C
	dc.w	AmAOn-AmJumps			* 60
	dc.w	AmAOff-AmJumps			* 64
	dc.w	AmAExit-AmJumps			* 68
	dc.w	AmDirect-AmJumps		* 6C
	dc.w	AmChif-AmJumps			* 70
	dc.w	AmXMou-AmJumps			* 74
	dc.w	AmYMou-AmJumps			* 78
	dc.w	AmSExp-AmJumps			* 7C
	dc.w	AmJ0-AmJumps			* 80
	dc.w	AmJ1-AmJumps			* 84
	dc.w	AmM1-AmJumps			* 88
	dc.w	AmM2-AmJumps			* 8C
	dc.w	AmEg-AmJumps			* 90
	dc.w	AmDif-AmJumps			* 94
	dc.w	AmInf-AmJumps			* 98
	dc.w	AmSup-AmJumps			* 9C
	dc.w	AmPlus-AmJumps			* A0
	dc.w	AmMoins-AmJumps			* A4
	dc.w	AmDiv-AmJumps			* A8
	dc.w	AmMult-AmJumps			* AC
	dc.w	AmOr-AmJumps			* B0
	dc.w	AmAnd-AmJumps			* B4
	dc.w	AmSCol-AmJumps			* B8
	dc.w	AmBCol-AmJumps			* BC
	dc.w	AmPlay-AmJumps			* C0
	dc.w	AmXH-AmJumps			* C4
	dc.w	AmYH-AmJumps			* C8
	dc.w	AmAni-AmJumps			* CC
	dc.w 	AmHaz-AmJumps			* D0
	dc.w	AmVu-AmJumps			* D4
	dc.w	AmXor-AmJumps			* D8

***********************************************************
*	ANIMEUR / DEPLACEUR
Animeur:
********
	lea	AMJumps(pc),a4
	move.l	T_AMChaine(a5),d7
	beq.s	AMX
	move.l	d7,d0
	clr.l	T_AMChaine(a5)
	move.w	T_Actualise(a5),d5

******* Depart animation!
AmRE:	move.l	d0,a6
	move.w	AmBit(a6),d4
	bmi.s	AmL2

******* Boucle de l'autotest
	move.l	AmAuto(a6),d0
	beq.s	AmL1
	move.l	d0,a3
	moveq	#20,d6
	move.w	(a3)+,d0
	jsr	0(a4,d0.w)

******* Boucle normale
AmL1:	move.l	AmPos(a6),d0
	beq.s	AmRet
	move.l	d0,a3
	moveq	#10,d6
	move.w	(a3)+,d0
	jsr	0(a4,d0.w)

******* Appel de l'animation?
AmRet:	move.l	AmAJsr(a6),d0
	beq.s	AmL2
	move.l	d0,a0
	jsr	(a0)

******* Un Autre?
AmL2:	move.l	AmNext(a6),d0
	bne.s	AmRE

* Rebranche les inters
	move.w	d5,T_Actualise(a5)
	move.l	d7,T_AmChaine(a5)
AmX:	rts

******* MOVE x,y,step
AmMove:	subq.w	#1,AmCpt(a6)
	bmi.s	AmMvI
	beq.s	AmMvX
* Un cran
	move.l	AmAct(a6),a0
	move.w	2(a0),d0
	move.w	d0,d2
	swap	d0
	move.w	AmVirgX(a6),d0
	move.w	4(a0),d1
	move.w	d1,d3
	swap	d1
	move.w	AmVirgY(a6),d1
	add.l	AmDeltX(a6),d0
	add.l	AmDeltY(a6),d1
AmMv0:	move.w	d0,AmVirgX(a6)
	move.w	d1,AmVirgY(a6)
	swap	d0
	swap	d1
	cmp.w	d2,d0
	beq.s	AmMv1
	move.w	d0,2(a0)
	bset	#1,(a0)
	bset	d4,d5
AmMv1:	cmp.w	d3,d1
	beq.s	AmMv2
	move.w	d1,4(a0)
	bset	#2,(a0)
	bset	d4,d5
AmMv2:	rts
* Mvt suivant
AmMvX:	move.l	AmFin(a6),a3
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
* Init! Calcule les pentes
AmMvI:	lea	-2(a3),a0
	move.l	a0,AmPos(a6)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.l	a3,AmFin(a6)
	tst.w	d3
	bgt.s	AmMi1
	moveq	#1,d3
AmMi1:	move.w	d3,AmCpt(a6)
	move.w	(sp)+,d1
	move.w	(sp)+,d0
	moveq	#0,d2
	ext.l	d0
	bpl.s	AmMi2
	neg.l	d0
	bset	#0,d2
AmMi2:	ext.l	d1
	bpl.s	AmMi3
	neg.l	d1
	bset	#1,d2
AmMi3:	lsl.l	#8,d0
	lsl.l	#8,d1
	divu	d3,d0
	bvc.s	AmMi4
	moveq	#0,d0
AmMi4:	divu	d3,d1
	bvc.s	AmMi5
	moveq	#0,d1
AmMi5:	btst	#0,d2
	beq.s	AmMi6
	neg.w	d0
AmMi6:	btst	#1,d2
	beq.s	AmMi7
	neg.w	d1
AmMi7:	ext.l	d0
	ext.l	d1
	lsl.l	#8,d0
	lsl.l	#8,d1
	move.l	d0,AmDeltX(a6)
	move.l	d1,AmDeltY(a6)
	move.l	AmAct(a6),a0
	move.w	2(a0),d2
	swap	d2
	move.w	#$8000,d2
	move.w	4(a0),d3
	swap	d3
	move.w	#$8000,d3
	add.l	d2,d0
	add.l	d3,d1
	bra	AmMv0

******* PLAY n
AmPlay:	subq.w	#1,AmCpt(a6)
	bmi	AmPli
	bne	AmX
AmPl0:	move.w	AmIRegs+NbInterne*2-4(a6),d2
	bmi	AmMvX
	move.l	AmAct(a6),a0
* Pas suivant en X
	move.l	AmDeltX(a6),a1
	move.b	(a1),d0
	beq	AmMvX
	bmi	AmPWx
	lsl.b	#1,d0
	asr.b	#1,d0
	ext.w	d0
	bset	#1,(a0)
	bset	d4,d5
	tst.w	d2
	beq.s	AmPx1
	add.w	d0,2(a0)
	addq.l	#1,AmDeltX(a6)
	bra.s	AmPy
AmPx1:	sub.w	d0,2(a0)
	subq.l	#1,AmDeltX(a6)
	bra.s	AmPy
* Attente en X!
AmPWx:	subq.w	#1,AmVirgX(a6)
	beq.s	Ampwx1
	bpl.s	Ampy
	and.w	#$7f,d0
	beq.s	Ampwx1
	move.w	d0,AmVirgX(a6)
	bra.s	AmPy
Ampwx1:	tst.w	d2
	bne.s	Ampwx2
	subq.l	#1,AmDeltX(a6)
	bra.s	AmPy
Ampwx2:	addq.l	#1,AmDeltX(a6)
* Pas suivant en Y
AmPy:	move.l	AmDeltY(a6),a1
	move.b	(a1),d0
	beq	AmMvX
	bmi	AmPWy
	lsl.b	#1,d0
	asr.b	#1,d0
	ext.w	d0
	bset	#2,(a0)
	bset	d4,d5
	tst.w	d2
	beq.s	AmPy1
	add.w	d0,4(a0)
	addq.l	#1,AmDeltY(a6)
	bra.s	Ampwy3
AmPy1:	sub.w	d0,4(a0)
	subq.l	#1,AmDeltY(a6)
	bra.s	Ampwy3
* Attente en Y!
AmPWy:	subq.w	#1,AmVirgY(a6)
	beq.s	Ampwy1
	bpl.s	Ampwy3
	and.w	#$7f,d0
	beq.s	Ampwy1
	move.w	d0,AmVirgY(a6)
	bra.s	Ampwy3
Ampwy1:	tst.w	d2
	bne.s	Ampwy2
	subq.l	#1,AmDeltY(a6)
	bra.s	Ampwy3
Ampwy2:	addq.l	#1,AmDeltY(a6)
Ampwy3:	move.w	AmIRegs+NbInterne*2-2(a6),AmCpt(a6)
	rts
******* Initialisation!
AmPli:	lea	-2(a3),a0
	move.l	a0,AmPos(a6)
	bsr	AmEvalue
	move.l	a3,AmFin(a6)
	move.l	T_AmBank(a5),d0
	beq	AmMvX
	move.l	d0,a0
	cmp.w	4(a0),d3
	bhi	AmMvX
	lsl.w	#1,d3
	beq	AmMvX
	move.w	4+2-2(a0,d3.w),d3
	beq	AmMvX
	lsl.w	#1,d3
	lea	4(a0,d3.w),a0
	move.w	(a0)+,AmIRegs+NbInterne*2-2(a6)
	move.w	#1,AmIRegs+NbInterne*2-4(a6)
	move.w	(a0)+,d0
	lea	-4+1(a0,d0.w),a1
	move.l	a1,AmDeltY(a6)
	addq.l	#1,a0
	move.l	a0,AmDeltX(a6)
	clr.w	AmVirgX(a6)
	clr.w	AmVirgY(a6)
	bra	AmPl0

******* ANIM
AmAni:	bsr	AmEvalue		* Initialise l'animation!
	move.w	d3,AmACLoop(a6)
	move.w	#1,AmACpt(a6)
	lea	2(a3),a0
	move.l	a0,AmAAd(a6)
	move.l	a0,AmAALoop(a6)
	lea	AmDoAni(pc),a0
	move.l	a0,AmAJsr(a6)
	add.w	(a3),a3
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
AmDoAni	subq.w	#1,AmACpt(a6)		* Fait l'animation
	bne.s	AmDAX
	move.l	AmAAd(a6),a3
AmDA0	tst.w	(a3)
	beq.s	AmDA1
	bsr	AmEvalue
	move.l	AmAct(a6),a0
	move.w	d3,6(a0)
	bset	#0,(a0)
	bset	d4,d5
	bsr	AmEvalue
	move.w	d3,AmACpt(a6)
	move.l	a3,AmAAd(a6)
AmDAX	rts
AmDA1	tst.w	AmACLoop(a6)
	beq	AmDA2
	subq.w	#1,AmACLoop(a6)
	beq.s	AmDA3
AmDA2	move.l	AmAALoop(a6),a3
	bra.s	AmDA0
AmDA3	clr.l	AmAJsr(a6)
	rts

******* ST-ANIMATION
AmAnim:	move.w	#1,AmACpt(a6)
	move.l	a3,AmAAd(a6)
	move.l	a3,AmAALoop(a6)
	lea	StAni(pc),a0
	move.l	a0,AmAJsr(a6)
	clr.l	AmPos(a6)
	rts
StAni:	subq.w	#1,AmACpt(a6)
	bne.s	StA1
	move.l	AmAAd(a6),a3
StA0	move.w	(a3)+,d0
	bmi.s	StA2
	move.l	AmAct(a6),a0
	move.w	d0,6(a0)
	bset	#0,(a0)
	bset	d4,d5
	move.w	(a3)+,AmACpt(a6)
	beq.s	StA3
	move.l	a3,AmAAd(a6)
StA1	rts
StA2	cmp.w	#-1,d0
	beq.s	StA3
	move.l	AmAALoop(a6),a3
	bra.s	StA0
StA3	clr.l	AmAJsr(a6)
	rts

******* ST-MOUVEMENT EN X
AmMvtX:	move.w	#1,AmACpt(a6)
	move.l	a3,AmAALoop(a6)
	lea	StMvX(pc),a0
	move.l	a0,AmAJsr(a6)
	clr.l	AmPos(a6)
	moveq	#1,d1
	move.l	AmAct(a6),a0
	lea	2(a0),a1
	bra	StML
******* ST-MOUVEMENT EN Y
AmMvtY:	move.w	#1,AmACpt(a6)
	move.l	a3,AmAALoop(a6)
	lea	StMvY(pc),a0
	move.l	a0,AmAJsr(a6)
	clr.l	AmPos(a6)
	moveq	#2,d1
	move.l	AmAct(a6),a0
	lea	4(a0),a1
	bra	StML
* Entree MOVE X
StMvX	subq.w	#1,AmACpt(a6)
	bne.s	StMXx
	moveq	#1,d1
	move.l	AmAct(a6),a0
	lea	2(a0),a1
	bra.s	StM0
* Entree MOVE Y
StMvY	subq.w	#1,AmACpt(a6)
	bne.s	StMXx
	moveq	#2,d1
	move.l	AmAct(a6),a0
	lea	4(a0),a1
* Fait le mouvement
StM0	move.l	AmAAd(a6),a3
	move.w	(a3)+,AmACpt(a6)
	move.w	(a1),d0
	add.w	(a3)+,d0
	move.w	d0,(a1)
	bset	d1,(a0)
	bset	d4,d5
	cmp.w	AmDeltY(a6),d0		* Condition?
	beq.s	StM2
	subq.w	#1,AmDeltX(a6)		* Encore un mouvement?
	beq.s	StM1
StMXx:	rts
* Mouvement suivant
StM1	addq.l	#2,a3
	tst.w	(a3)
	bne.s	StM4
* Condition realisee: on boucle?
StM2:	move.l	AmAALoop(a6),a3
	tst.w	2(a3)
	beq.s	StMF
StML:	move.w	(a3)+,d0		* Reinitialisation
	cmp.w	#$8000,d0
	beq.s	StM3
	move.w	d0,(a1)
	bset	d1,(a0)
	bset	d4,d5
StM3:	addq.l	#2,a3
	move.w	(a3)+,AmDeltY(a6)
StM4:	move.l	a3,AmAAd(a6)
	move.w	4(a3),AmDeltX(a6)
	rts
StMF:	clr.l	AmAJsr(a6)
	rts

******* AUTOTEST ON
AmAOn:	move.w	(a3)+,d0
	move.l	a3,AmAuto(a6)
	lea	-2(a3,d0.w),a3
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
******* AUTOTEST OFF
AmAOff:	clr.l	AmAuto(a6)
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
******* AUTOTEST EXIT
AmAExit:rts
******* DIRECT label
AmDirect:
	move.w	(a3)+,d0
	lea	-2(a3,d0.w),a0
	move.l	a0,AmPos(a6)
	clr.w	AmCpt(a6)
	rts

******* STOP GENERAL!
AmStop:	clr.l	AmPos(a6)
	clr.l	AmAuto(a6)
	rts
******* WAIT VBL
AmPose:	move.l	a3,AmPos(a6)
	rts
******* WAIT
AmWait:	clr.l	AmPos(a6)
	rts
******* RIEN
AmRien:	move.w	(a3)+,d0
	jmp	0(a4,d0.w)

******* LET
AmLet:	bsr	AmEvalue
	move.w	(a3)+,d0
	jsr	0(a4,d0.w)
	move.w	d3,(a0)
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)

******* IF
AmIf:	bsr	AmEvalue
	tst.w	d3
	bne.s	AmIfV
	addq.l	#4,a3
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
AmIfV:	move.w	(a3)+,d0
	jmp	0(a4,d0.w)

******* FOR
AmFor:	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	lea	T_AmRegs(a5),a0
	move.w	(a3)+,d0
	bpl.s	AmFr0
	lea	AmIRegs+NbInterne*2(a6),a0
AmFr0:	move.w	(sp)+,0(a0,d0.w)
	move.w	d3,(a3)+
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
******* NEXT
AmNxt:	move.w	(a3)+,d0
	lea	-2(a3,d0.w),a1
	lea	T_AmRegs(a5),a0
	move.w	(a1)+,d0
	bpl.s	AnNx0
	lea	AmIRegs+NbInterne*2(a6),a0
AnNx0:	add.w	d0,a0
	addq.w	#1,(a0)
	move.w	(a1)+,d0
	cmp.w	(a0),d0
	bge.s	AmNx1
* Sortie, on continue
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
* On reste dans la boucle
AmNx1:	move.l	a1,AmPos(a6)
	rts

******* JUMP
AmJump:	add.w	(a3),a3
	subq.w	#1,d6
	beq.s	AmJp1
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)
AmJp1	lea	AmRet(pc),a0
	cmp.l	(sp),a0
	bne.s	AmJp2
	move.l	a3,AmPos(a6)
AmJp2	rts

******* A=
AmAEg:	move.l	AmAct(a6),a0
	bset	#0,(a0)
	bset	d4,d5
	addq.l	#6,a0
	rts
******* X=
AmXEg:	move.l	AmAct(a6),a0
	bset	#1,(a0)
	bset	d4,d5
	addq.l	#2,a0
	rts
******* Y=
AmYEg:	move.l	AmAct(a6),a0
	bset	#2,(a0)
	bset	d4,d5
	addq.l	#4,a0
	rts
******* REG=
AmREg:	move.w	(a3)+,d0
	bmi.s	AmREg0
	lea	T_AmRegs(a5),a0
	add.w	d0,a0
	rts
AmREg0:	lea	AmIRegs+NbInterne*2(a6),a0
	add.w	d0,a0
	rts

******* EVALUATION D'EXPRESSION
AmEvalue:
	move.w	(a3)+,d0
	jsr	0(a4,d0.w)
	move.w	d2,d3
AmELoop	move.w	(a3)+,d0
	jsr	0(a4,d0.w)
	move.w	(a3)+,d0
	jmp	0(a4,d0.w)

* =XH(Ec,X)
AmXH:	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d1
	bsr	AmEcTo
	tst.w	EcCon0(a0)
	bpl.s	AmXH0
	asr.w	#1,d2
AmXH0:	add.w	EcWX(a0),d2
	move.w	(sp)+,d3
	rts
* =YH(Ec,Y)
AmYH:	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d1
	bsr	AmEcTo
	add.w	EcWY(a0),d2
	sub.w	#EcYBase,d2
	move.w	(sp)+,d3
	rts
* =XS(Ec,X)
AmXS:	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d1
	bsr	AmEcTo
	sub.w	EcWx(a0),d2
	btst	#7,EcCon0(a0)
	beq.s	AmXs1
	asl.w	#1,d2
AmXs1:	add.w	EcVx(a0),d2
	move.w	(sp)+,d3
	rts
* =YS(e,X)
AmYS:	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d1
	bsr	AmEcTo
	add.w	#EcYBase,d2
	sub.w	EcWy(a0),d2
	add.w	EcVy(a0),d2
	move.w	(sp)+,d3
	rts
* Routine: Ecto
AmEcTo	move.w	d3,d2
	and.w	#$0007,d1
	lsl.w	#2,d1
	lea	T_EcAdr(a5),a0
	move.l	0(a0,d1.w),d1
	beq.s	AmEc1
	move.l	d1,a0
	rts
AmEc1:	addq.l	#4,sp
	moveq	#-1,d2
	move.w	(sp)+,d3
	rts
* = Bob Coll
AmBCol:	move.w	T_SyncOff(a5),d0
	beq.s	AmbbX
	movem.l	d3-d7/a0-a2,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	bsr	BbColl
	movem.l	(sp)+,d3-d7/a0-a2
	move.w	d0,d2
	rts
* = Spr Coll
AmSCol:	move.w	T_SyncOff(a5),d0
	beq.s	AmbbX
	movem.l	d3-d7/a0-a2,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	bsr	SpColl
	movem.l	(sp)+,d3-d7/a0-a2
	move.w	d0,d2
	rts
AmBbx:	moveq	#0,d2
	rts
* = Col(n)
AmCol:	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	d3,d1
	bsr	GetCol
	move.w	d0,d2
	move.w	(sp)+,d3
	rts
* = Haz(n)
AmHaz:	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	T_AmSeed(a5),d2
	mulu	#$3171,d2
	add.w	Circuits+$06,d2
	addq.w	#1,d2
	move.w	d2,T_AmSeed(a5)
	lsr.l	#8,d2
	and.w	d3,d2
	move.w	(sp)+,d3
	rts
* =Vu(n)
AmVu	move.w	d3,-(sp)
	bsr	AmEvalue
	move.w	(sp)+,d3
	move.l	ExtAdr+0*16(a5),d0
	beq.s	AmVu0
	move.l	d0,a0
	cmp.w	#4,d2
	bcc.s	AmVu0
	add.w	d2,a0
	move.b	(a0),d2
	clr.b	(a0)
	rts
AmVu0	moveq	#0,d2
	rts
* =A
AmEgA:	move.l	AmAct(a6),a0
	move.w	6(a0),d2
	rts
* =X
AmEgX:	move.l	AmAct(a6),a0
	move.w	2(a0),d2
	rts
* =Y
AmEgY:	move.l	AmAct(a6),a0
	move.w	4(a0),d2
	rts
* =RA
AmEgR:	move.w	(a3)+,d0
	bmi.s	AEgR0
	lea	T_AmRegs(a5),a0
	move.w	0(a0,d0.w),d2
	rts
AEgR0:	lea	AmIRegs+NbInterne*2(a6),a0
	move.w	0(a0,d0.w),d2
	rts
* =On
AmOn:	tst.w	AmCpt(a6)
	bmi.s	AmO0
	beq.s	AmO0
AmOnM:	moveq	#-1,d2
	rts
AmO0:	moveq	#0,d2
	rts
AmO1:	moveq	#1,d2
	rts

* =Chiffre
AmChif:	move.w	(a3)+,d2
	rts
* =XMouse
AmXMou:	move.w	T_XMouse(a5),d2
	rts
* =YMouse
AmYMou:	move.w	T_Ymouse(a5),d2
	rts
* =Joy0
AmJ0:	moveq	#0,d1
	bsr	ClJoy
	move.w	d1,d2
	rts
* =Joy1
AmJ1:	moveq	#1,d1
	bsr	ClJoy
	move.w	d1,d2
	rts
* = Mousekey1
AmM1:	moveq	#0,d2
	btst	#6,CiaAPrA
	bne.s	AmMx
	moveq	#-1,d2
AmMx:	rts
* = Mousekey 2
AmM2:	moveq	#0,d2
	btst	#10,$DFF016
	beq.s	AmMx
	moveq	#-1,d2
	rts

******* OPERATEURS

* Fin de l'evaluation
AmSExp:	addq.l	#4,sp
	rts
* =
AmEg:	cmp.w	d3,d2
	bne.s	AmEF
AmEV:	moveq	#-1,d3
	bra	AmELoop
AmEF:	moveq	#0,d3
	bra	AmELoop
* <
AmInf:	cmp.w	d2,d3
	blt.s	AmEV
	bra.s	AmEF
* >
AmSup:	cmp.w	d2,d3
	bgt.s	AmEv
	bra.s	AmEF
* <>
AmDif:	cmp.w	d2,d3
	bne.s	AmEV
	bra.s	AmEF
* +
AmPlus:	add.w	d2,d3
	bra	AmELoop
* -
AmMoins	sub.w	d2,d3
	bra	AmELoop
* /
AmDiv:	tst.w	d2
	beq	AmELoop
	ext.l	d3
	divs	d2,d3
	bra	AmELoop
* *
AmMult:	ext.l	d3
	muls	d2,d3
	bra	AmELoop
* |
AmOr:	or.w	d2,d3
	bra	AmELoop
* !
AmXor:	eor.w	d2,d3
	bra	AmELoop
* &
AmAnd:	and.w	d2,d3
	bra	AmELoop
	ENDC


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ROUTINES AU MILIEU!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Icestart: branch system functions only.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IceStart
	move.l	a6,-(sp)

	clr.w	T_WVersion(a5)		Par defaut
	cmp.l	#"V2.0",d0		Le magic
	bne.s	.Nomagic
	move.w	d1,T_WVersion(a5)	La version d'AMOS
.Nomagic

	lea	W_Base(pc),a0
	move.l	a5,(a0)
	lea	SyIn(pc),a0
	move.l	a0,T_SyVect(a5)
	bsr	WMemInit

; Recherche et stoppe les programmes AMOS lanc�s... (si AMOSPro V2.0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#$0200,T_WVersion(a5)
	bcs.s	.No20
	move.l	$4.w,a6
	jsr	Forbid(a6)
	lea	TaskName(pc),a1
	jsr	FindTask(a6)
	tst.l	d0
	beq.s	.skip
	move.l	d0,a0
	move.l	10(a0),a1
	move.b	#"S",(a1)		* STOP!!!
	move.l	a1,T_Stopped(a5)
.skip	jsr	Permit(a6)
; Change son propre nom...
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,a0
	move.l	d0,T_MyTask(a5)
	move.l	10(a0),T_OldName(a5)
	lea	TaskName(pc),a1
	move.l	a1,10(a0)
	move.l	a5,$58(a0)		Adresse des datas...
; Fini!
.No20	move.l	(sp)+,a6
	move.l	#"W2.0",d0		Retourne des magic
	move.w	#$0200,d1
	rts

; Normal cold start: start default system
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StartAll
	movem.l	a0-a6/d1-d7,-(sp)
	move.l	sp,T_GPile(a5)

	move.l	a2,-(sp)			Palette par defaut
	move.l	a0,-(sp)

; Attend que l'autre AMOS soit arrete! (si v2.0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#$0200,T_WVersion(a5)
	bcs.s	.No20_a
	movem.l	a0-a3/d0-d3,-(sp)
	move.l	T_Stopped(a5),d0
	beq.s	.Wait2
	move.l	d0,a2
	move.w	#50*5,d3
.Wait1	move.l	T_GfxBase(a5),a6
	jsr	-270(a6)
	cmp.b	#"S",(a2)
	bne.s	.Wait2
	dbra	d3,.Wait1
.GoEnd	bra	GFatal
.Wait2	movem.l	(sp)+,a0-a3/d0-d3
.No20_a

; Sauve les flags du DMA
; ~~~~~~~~~~~~~~~~~~~~~~
	move.b	d0,T_AMOSHere(a5)
	move.w	Circuits+DmaConR,T_OldDma(a5)
	bset	#7,T_OldDma(a5)

; Amiga-A
; ~~~~~~~
	tst.l	d1
	bne.s	.Skip
	move.l	#$00406141,d1
.Skip	move.b	d1,T_AmigA_Ascii1(a5)
	lsr.l	#8,d1
	move.b	d1,T_AmigA_Ascii2(a5)
	lsr.w	#8,d1
	move.b	d1,T_AmigA_Shifts(a5)

; Mouse.Abk (si v2.0)
; ~~~~~~~~~~~~~~~~~~~
	cmp.w	#2,T_WVersion(a5)
	bcs.s	.No20_b
	move.l	a1,d0
	bne.s	.MSkip
	move.l	WDebut-4(pc),d0			Prend le HUNK suivant
	lsl.l	#2,d0
	move.l	d0,a1
	addq.l	#4,a1
.MSkip	cmp.l	#"AmSp",(a1)+
	bne	GFatal
	move.w	(a1)+,d1
	cmp.w	#4,d1
	bcs	GFatal
	move.l	a1,T_MouBank(a5)
; Pointe la palette pour l'ouverture des ecrans
	subq.w	#1,d1
.MLoop	move.w	(a1)+,d0
	mulu	(a1)+,d0
	mulu	(a1)+,d0
	lsl.l	#1,d0
	lea	4(a1,d0.l),a1
	dbra	d1,.MLoop
	move.w	#-1,(a1)		Stoppe la mouse.abk
	lea	16*2(a1),a1		Pointe couleurs 16-32
	lea	16*2(a2),a2		Couleurs 16-32 de default palette
	moveq	#15,d0
.PCopy	move.w	(a1)+,(a2)+
	dbra	d0,.PCopy
.No20_b

; Ouverture de la fonte systeme 8x8
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	TopazName(pc),a1	Topaz force si <2.0
	cmp.w	#$0200,T_WVersion(a5)
	bcs.s	.Sfont
	move.l	a3,d0			Sinon, fonte dans a3
	beq.s	.Sfont
	tst.b	(a3)
	beq.s	.Sfont
	move.l	a3,a1
.Sfont	lea	-8(sp),sp
	move.l	sp,a0
	move.l	a1,(a0)
	move.w	#8,4(a0)
	move.w	#$0041,6(a0)
	move.l	T_GfxBase(a5),a6
	jsr	_LVOOpenFont(a6)
	move.l	d0,T_DefaultFont(a5)
	bne.s	.fOk
	lea	TopazName(pc),a1
	move.l	sp,a0			On ressaie avec topaz
	move.l	a1,(a0)
	move.w	#8,4(a0)
	move.w	#$0041,6(a0)
	jsr	_LVOOpenFont(a6)
	move.l	d0,T_DefaultFont(a5)
	beq	GFatal			???
.fOk	addq.l	#8,sp

; Graphic library
; ~~~~~~~~~~~~~~~
	lea	GfxBase(pc),a1
	move.l	T_GfxBase(a5),a0
	move.l	a0,(a1)
	clr.b	T_WFlags(a5)			Flag AA
	btst	#2,236(a0)
	beq.s	.PaAA
	bset	#WFlag_AA,T_WFlags(a5)
	bset	#WFlag_LoadView,T_WFlags(a5)
.PaAA	move.l	$4.w,a0				Kickstart >= V39?
	cmp.w	#39,$14(a0)			Si oui, on fait un LoadView(0)
	bcs.s	.Pa39
	bset	#WFlag_LoadView,T_WFlags(a5)
.Pa39
	IFNE	Debug=2				Si debug
	bclr	#WFlag_LoadView,T_WFlags(a5)	AMIGA-A normal...
	ENDC


; Ma propre tache
; ~~~~~~~~~~~~~~~
	sub.l	a1,a1
	move.l	$4.w,a6
	jsr	FindTask(a6)
	move.l	d0,T_MyTask(a5)
	move.l	d0,a0

; Ouverture du layer.library
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	lea	LayName(pc),a1
	move.l	$4.w,a6
	jsr	OpenLib(a6)
	move.l	d0,T_LayBase(a5)
	beq	GFatal

; Branche l'input.device
; ~~~~~~~~~~~~~~~~~~~~~~
	bsr	ClInit
; Open Console Device
; ~~~~~~~~~~~~~~~~~~~
	lea	ConIo(pc),a1
	bsr	OpConsole
; Branche le input_handler
; ~~~~~~~~~~~~~~~~~~~~~~~~
	lea	T_IoDevice(a5),a1
	bsr	OpInput
	lea	T_Interrupt(a5),a0
	lea	IoHandler(pc),a1
	move.l	a1,IS_CODE(a0)
	clr.l	IS_DATA(a0)
	move.b	#100,ln_pri(a0)
	lea	T_IoDevice(a5),a1
	move.l	a0,io_Data(a1)
	move.w	#IND_ADDHANDLER,io_command(a1)
	jsr	_LVODoIo(a6)
	move.w	#-1,T_DevHere(a5)

; Parametres par defaut des ecrans
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	(sp),a0
	move.w	#129,T_DefWX(a5)
	move.w	#129-16,T_DefWX2(a5)
	move.w	10(a0),T_DefWY(a5)
	move.w	10(a0),T_DefWY2(a5)
	subq.w	#8,T_DefWY2(a5)

	lea 	Circuits,a6
	move.l	(sp),a0
	move.l	16(a0),d0
	bsr	HsInit			Hard sprites
	move.l	(sp),a0
	move.w	8(a0),d0
	bsr	BbInit			Bobs
	bsr	RbInit			Retourneur de bobs
	move.l	(sp),a0
	move.l	12(a0),d0
	bsr	CpInit			Copper
	bsr	EcInit			Ecrans
	bsr	SyInit			Systeme
	bsr	VBLInit			Interruptions VBL
	bsr	WiInit			Windows

;	Si AA, change le vecteur LOADVIEW
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#WFlag_LoadView,T_WFlags(a5)	Si LoadView en route
	beq.s	.NoLoadView
	lea	AMOS_LoadView(pc),a0
	lea	T_AMOSHere(a5),a1		Adresse du test
	move.l	a1,2(a0)			>>> dans le source...
	move.l	a0,d0				Nouvelle fonction
	move.w	#-222,a0			LOADVIEW
	move.l	T_GfxBase(a5),a1		Librairie
	move.l	$4.w,a6
	jsr	-420(a6)			Set function
	lea	Old_LoadView(pc),a0		Ancien vecteur
	move.l	d0,(a0)
	bsr	Sys_ClearCache			Nettoie les caches!
.NoLoadView

; 	Branche le requester
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#$0200,T_WVersion(a5)
	bcs.s	.No20_c
	move.l	4(sp),a0			Palette par defaut
	bsr	WRequest_Start
; 	Fabrique la fonte par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Wi_MakeFonte
	bne	GFatal
; 	Envoie le signal a l'AMOS Switcher
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_MyTask(a5),a0
	move.l	a5,$58(a0)
	moveq	#Switcher_Signal,d3
	bsr	Send_Switcher
.No20_c

; 	Tout fini: AMOS to front ?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	T_AMOSHere(a5)
	beq.s	.Pafr
	clr.b	T_AMOSHere(a5)
	moveq	#1,d1
	bsr	TAMOSWb
.Pafr
; Pas d'erreur
; ~~~~~~~~~~~~
	moveq	#0,d0
	bra.s	GFini
; 	Erreur: EFFACE TOUT, et revient!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GFatal	bsr.s	EndAll
	moveq	#-1,d0
GFini	move.l	T_GPile(a5),a7
	movem.l	(sp)+,a0-a6/d1-d7
	rts


;							Arret general
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EndAll	lea	Circuits,a6

;	Remet l'ecran du workbench
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d1
	bsr	TAMOSWb
	moveq	#2,d0
	bsr	WVbl_d0

; Empeche le switcher de fonctionner (si 2.0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#$0200,T_WVersion(a5)
	bcs.s	.No20_a
	moveq	#Switcher_Signal+1,d3
	bsr	Send_Switcher
; 	Plus de requester
; ~~~~~~~~~~~~~~~~~~~~~~~
	bsr	WRequest_Stop
;	Efface la fonte
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Wi_DelFonte
.No20_a

;	Si AA, remet le vecteur LOADVIEW
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#WFlag_LoadView,T_WFlags(a5)	Si LoadView en route
	beq.s	.NoLoadView
	move.l	Old_LoadView(pc),d0		Ancienne fonction
	beq.s	.NoLoadView
	move.w	#-222,a0			LOADVIEW
	move.l	T_GfxBase(a5),a1		Librairie
	move.l	$4.w,a6
	jsr	-420(a6)			Set function
.NoLoadView

;	Debranche l'input.device
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	T_DevHere(a5)
	beq.s	.skip0
	lea	T_Interrupt(a5),a0
	lea	T_IoDevice(a5),a1
	move.l	a0,io_Data(a1)
	move.w	#IND_REMHANDLER,Io_Command(a1)
	move.l	$4.w,a6
	jsr	_LVODoIo(a6)
	lea	T_IoDevice(a5),a1
	bsr	ClInput
.Skip0

; 	Arret des toutes les fonctions AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	TFFonts
;	bsr	WiEnd			Rts!
	bsr	SyEnd
	bsr	EcEnd
	bsr	RbEnd
	bsr	BbEnd
	bsr	HsEnd
	bsr	VBLEnd
	bsr	CpEnd

;	Ferme les librairies
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a6
	move.l	T_FntBase(a5),d0		diskfont.library
	beq.s	.Lib0
	move.l	d0,a1
	jsr 	CloseLib(a6)
.Lib0	move.l	T_LayBase(a5),d0		layer.library
	beq.s	.Lib1
	move.l	d0,a1
	jsr 	CloseLib(a6)
.Lib1	move.l	T_GfxBase(a5),d0		graphics.library
	beq.s	.Lib2
	move.l	d0,a6				Ferme la fonte par defaut
	move.l	T_DefaultFont(a5),d0
	beq.s	.Lib2
	move.l	d0,a1
	jsr	_LVOCloseFont(a6)
.Lib2
	moveq	#0,d0
	rts

; Fin d'access au fonctions systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IceEnd
; Relance l'ancien AMOS (si 2.0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#$0200,T_WVersion(a5)
	bcs.s	.No20_a
	move.l	T_Stopped(a5),d0
	beq.s	.Skup
	move.l	d0,a0
	move.b	#" ",(a0)
; Remet son ancien nom
.Skup	move.l	T_MyTask(a5),d0
	beq.s	.Skiip
	move.l	d0,a0
	move.l	T_OldName(a5),10(a0)
.Skiip
.No20_a
; Enleve la gestion memoire si definie
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	WMemEnd			Plus de memory checking!
	rts

;	Envoie un signal � l'AMOS_Switcher (D3= signal)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Send_Switcher
	lea	Switcher(pc),a1
	move.l	$4.w,a6
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq.s	.PaSwi
	move.l	d0,a1
	moveq	#0,d0
	bset	d3,d0
	jsr	_LVOSignal(a6)
.PaSwi	rts

;	Fabrique la fonte par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Wi_MakeFonte
	movem.l	a2/d2-d7,-(sp)
	moveq	#0,d1			Ecran 16x8, 2 couleur
	moveq	#16,d2
	moveq	#8,d3
	moveq	#1,d4
	moveq	#0,d5
	moveq	#2,d6
	lea	Wi_MakeFonte(pc),a1
	bsr	EcCree
	bne	.Error
; Boucle de creation
	move.l	#8*256,d0
	SyCall	MemFastClear
	beq	.Error
	move.l	a0,T_JeuDefo(a5)
	move.l	a0,a2
	lea	32*8(a2),a0
	moveq	#32,d2
	move.w	#128,d3
	bsr	.CreeFont
	lea	160*8(a2),a0
	move.w	#160,d2
	move.w	#256,d3
	bsr	.CreeFont
; Poke les caracteres specifiques
	lea	Def_Font(pc),a0
	move.l	a2,a1
	moveq	#(8*32)/4-1,d0
.Copy1	move.l	(a0)+,(a1)+
	dbra	d0,.Copy1
	lea	128*8(a2),a1
	moveq	#(8*32)/4-1,d0
.Copy2	move.l	(a0)+,(a1)+
	dbra	d0,.Copy2
; A y est!
	moveq	#0,d0
	bra.s	.Out
; Erreur
.Error	moveq	#1,d0
; Sortie!
.Out	move.l	d0,-(sp)
	moveq	#0,d0
	bsr	EcDel
	move.l	(sp)+,d0
	movem.l	(sp)+,a2/d2-d7
	rts
; Saisit les caracteres d2-d3
.CreeFont
	movem.l	d2/d3/a2/a3/a6,-(sp)
	move.l	a0,a2
	move.l	T_EcCourant(a5),a3
.Car	move.l	T_RastPort(a5),a1		Le rastport
	move.w	#0,36(a1)			Curseur en 0,0
	move.w	#6,38(a1)
	moveq	#1,d0				Un caractere
	lea	.COut(pc),a0
	move.b	d2,(a0)
	move.l	T_GfxBase(a5),a6		La fonction
	jsr	_LVOText(a6)
	move.l	EcLogic(a3),a0			Boucle de recopie
	move.w	EcTligne(a3),d0
	ext.l	d0
	moveq	#7,d1
.Loop	move.b	(a0),(a2)+
	add.l	d0,a0
	dbra	d1,.Loop
	addq.w	#1,d2
	cmp.w	d3,d2
	bcs.s	.Car
	movem.l	(sp)+,d2/d3/a2/a3/a6
	rts
.COut	dc.w	0

;	Effacement du jeu de caracteres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Wi_DelFonte
	move.l	T_JeuDefo(a5),d0
	beq.s	.Sip
	move.l	d0,a1
	move.l	#8*256,d0
	SyCall	MemFree
	clr.l	T_JeuDefo(a5)
.Sip	rts

***********************************************************
* Librairies
FntName:	dc.b	"diskfont.library",0
DevName		dc.b	"input.device",0
ConName		dc.b	"console.device",0
LayName		dc.b	"layers.library",0
TopazName	dc.b	"topaz.font",0
Switcher	dc.b	"_Switcher AMOS_",0
TaskName	dc.b	" AMOS",0
		even
***********************************************************

; 	Patch sur LOADVIEW si AMOS TO FRONT si AA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_LoadView
	tst.b	0.l			T_AMOSHere, modifie lors du patch...
	bne.s	.Wb
	move.l	Old_LoadView(pc),-(sp)
.Wb	rts
Old_LoadView	dc.l	0		Ici et pas ailleurs...

; AMOS / WORKBENCH
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1=0	> 	Workbench
;	D1>0	>	AMOS
;	D1<0	>	Rien (trouver valeur)
;	Retour D1= AMOS ici(-1), WB ici (0)
TAMOSWb
	tst.w	d1
	beq	.ToWB
	bmi	.Return

; 	Back to AMOS
; ~~~~~~~~~~~~~~~~~~
.ToAMOS	tst.b	T_AMOSHere(a5)
	bne	.Return
	move.b	#-1,T_AMOSHere+1(a5)		Code interdisant les requester

; Load View(0) + WaitTOF si AA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#WFlag_LoadView,T_WFlags(a5)
	beq.s	.PaAA0
	movem.l	d0-d3/a0-a2/a6,-(sp)

	move.l	T_IntBase(a5),a6		Ouvre un ecran LOWRES

	btst	#WFlag_WBClosed,T_WFlags(a5)	Si WB ferme, le referme!
	beq.s	.NoWB
	jsr	-78(a6)
.NoWB
	lea	NewScreen(pc),a0
	jsr	OpenScreen(a6)
	move.l	d0,T_IntScreen(a5)

	move.l	T_GfxBase(a5),a6		WaitTOF
	jsr	-$10e(a6)
	jsr	-$10e(a6)

	sub.l	a1,a1
	move.l	T_GfxBase(a5),a6
	jsr	-$de(a6)			LoadView(a0)
	jsr	-$10e(a6)			WaitTOF
	jsr	-$10e(a6)			WaitTOF
	move.w	$dff07c,d0
	cmp.b	#$f8,d0				AA Chipset?
	bne.s	.NoBug
	move.w	#0,$dff1fc			Sprite resolution
	move.w	#%0000110000000000,$dff106	Sprite width / DualPF palette
.NoBug

	movem.l	(sp)+,d0-d3/a0-a2/a6
.PaAA0
	lea	Circuits,a0			Remet les circuits
	move.w	#$8080,JoyTest(a0)
	move.l 	T_CopPhysic(a5),$80(a0)
	clr.w 	$88(a0)
	move.b	#-1,T_AMOSHere(a5)		AMOS en front!
	clr.b	T_AMOSHere+1(a5)		Flip termine!
	bra.s	.Return

; 	Goto workbench
; ~~~~~~~~~~~~~~~~~~~~
.ToWB	tst.b	T_AMOSHere(a5)
	beq.s	.Return
	clr.b	T_AMOSHere(a5)			AMOS en fond!
	move.b	#-1,T_AMOSHere+1(a5)		Code interdisant les requesters

	move.w	T_OldDma(a5),$Dff096		Remet les chips
	move.l	T_GfxBase(a5),a0
	move.l 	38(a0),$dff080
	clr.w	$dff088

; Efface l'ecran si AA
; ~~~~~~~~~~~~~~~~~~~~
	btst	#WFlag_LoadView,T_WFlags(a5)
	beq.s	.PaAA1
	movem.l	d0-d3/a0-a2/a6,-(sp)
	move.l	T_IntBase(a5),a6		Close Screen
	btst	#WFlag_WBClosed,T_WFlags(a5)	Si WB ferme, le rouvre!
	beq.s	.NoBW
	jsr	-210(a6)			Reopen workbench
.NoBW	move.l	T_IntScreen(a5),a0		Close screen
	jsr	CloseScreen(a6)
	move.l	T_GfxBase(a5),a6
	jsr	-$10e(a6)			WaitTOF
	jsr	-$10e(a6)			WaitTOF
	movem.l	(sp)+,d0-d3/a0-a2/a6
.PaAA1
	clr.b	T_AMOSHere+1(a5)		Flip termine!

; Retourne l'etat actuel
; ~~~~~~~~~~~~~~~~~~~~~~
.Return	move.b	T_AMOSHere(a5),d1
	ext.w	d1
	ext.l	d1
	moveq	#0,d0
	rts

;	Clear CPU Caches
; ~~~~~~~~~~~~~~~~~~~~~~
Sys_ClearCache
	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	cmp.w	#37,$14(a6)			A partir de V37
	bcs.s	.Exit
	jsr	-$27c(a6)			CacheClearU
.Exit	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ZONE DE DONNE CENTRALE (BEARK)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Table des sauts aux affichages texte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TAdCol		dc.l CZero-TAdCol,CNorm-TAdCol
		dc.l CInv-TAdCol,CUn-TAdCol
		dc.l CNul-TAdCol

;		Zone de donnee externe
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ConIo		ds.b 	32+8
LConBuffer	equ	64
ConBuffer	ds.b 	LConBuffer
ConEssai	ds.b	32
W_Base		ds.l	1
GfxBase		ds.l	1
WRastPort	ds.l	1
FoPat		dc.w	-1
; Autoback fenetres
WiAuto		ds.b	8*6+WiSAuto+4
		even
; Table de retournement bobs
TRetour		ds.b	256

NTx:		equ 480
NTy:		equ 12
NNp:		equ 1
NewScreen:	dc.w 0,0,NTx,NTy,NNp
		dc.b 1,0
		dc.w %0010000000000000,%00000110
		dc.l 0,0,0,0
		ds.b	16
		even

;		Caracteres speciaux des fontes AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Def_Font	IncBin	"bin/+WFont.bin"
		even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* SYSTEME : SOURIS / CLAVIER / INTER VBL
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

***********************************************************
*	DEMARRAGE A FROID DU SYSTEME
***********************************************************
SyInit:
	bsr	AMALInit
	moveq	#0,d0
	rts
***********************************************************
*	ARRET FINAL DU SYSTEME
***********************************************************
SyEnd:	bsr	AMALEnd
	moveq	#0,d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Initialisation / Fin du requester
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Demarrage du requester (a0)= default palette
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WRequest_Start
; Copy default palette
	lea	8*2(a0),a0
	lea	Req_Pal+8*2(pc),a1
	moveq	#24-1,d0
CPal	move.w	(a0)+,(a1)+
	dbra	d0,CPal
; Branch the requester
	lea	AutoReq(pc),a2
	lea	EasyReq(pc),a3
	bsr.s	SetJump
	move.l	a2,T_PrevAuto(a5)
	move.l	a3,T_PrevEasy(a5)
	move.w	#-1,T_ReqFlag(a5)	        * Default is AMOS request
	rts

;	Arret du requester
; ~~~~~~~~~~~~~~~~~~~~~~~~
WRequest_Stop
	tst.l	T_PrevAuto(a5)
	beq.s	.Skip
	move.l	T_PrevAuto(a5),a2
	move.l	T_PrevEasy(a5),a3
	bsr.s	SetJump
.Skip	rts

; Branche A2/a3 sur easy/auto request
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetJump	movem.l	a0/a1/a6,-(sp)
	move.l	$4.w,a6
; AutoRequest
	move.l	a2,d0
	lea	-$15c,a0
	move.l	T_IntBase(a5),a1
	jsr	SetFunction(a6)
	move.l	d0,a2
; EasyRequest, seulement si wb>=2.0
	move.l	$4.w,a0
	cmp.w	#36,$14(a0)
	bcs.s	.skip
	move.l	a3,d0
	lea	-$1d4-(20*6),a0
	move.l	T_IntBase(a5),a1
	jsr	SetFunction(a6)
	move.l	d0,a3
.skip	movem.l	(sp)+,a0/a1/a6
	rts

******* Table des sauts
SyIn:	bra 	ClInky			;0 -Inkey:
	bra	ClVide			;1 -ClearKey:
	bra 	ClSh			;2 -Shifts:
	bra	ClInst			;3 -Instant:
	bra	ClKeyM			;4 -KeyMap:
	bra	ClJoy			;5 -Joy:
	bra	ClPutK			;6 -PutKey:
	bra	MHide			;7 -Hide:
	bra	MShow			;8 -Show:
	bra	MChange			;9 -ChangeM:	 ChMouse
	bra	MXy			;10-XyMou:	 XY Mouse
	bra	CXyHard			;11-XyHard:	 Conversion SCREEN-> HARD
	bra	CXyScr			;12-XyScr:	 Conversion HARD-> SCREEN
	bra	MBout			;13-MouseKey:
	bra	MSetAb			;14-SetM:
	bra	GetSIn			;15-ScIn:	 Get screen IN
	bra	CXyWi			;16-XyWin:	 Conversion SCREEN-> WINDOW courante
	bra	MLimA			;17-LimitM:	 Limit mouse
	bra	SyZoHd			;18-ZoHd:	 Zone coordonnees HARD
	bra	SyResZ			;19-ResZone:	 Reserve des zones
	bra	SyRazZ			;20-RazZone:	 Effacement zones
	bra	SySetZ			;21-SetZone:	 Set zone
	bra	SyMouZ			;22-GetZone:	 Zone souris!
	bra	WVbl			;23-WaitVbl:
	bra	HsSet			;24-SetHs:	 Affiche un hard sprite
	bra	HsUSet			;25-USetHs:	 Efface un hard sprite
	bra	ClFFk			;26-SetFunk:
	bra	ClGFFk			;27-GetFunk:
	bra	HsAff			;28-AffHs:	 Recalcule les hard sprites
	bra	HsBank			;29-SetSpBank:	 Fixe la banque de sprites
	bra	HsNXYA			;30-NXYAHs:	 Instruction sprite
	bra	HsXOff			;31-XOffHs:	 Sprite off n
	bra	HsOff			;32-OffHs:	 All sprite off
	bra	HsAct			;33-ActHs:	 Actualisation HSprite
	bra	HsSBuf			;34-SBufHs:	 Set nombre de lignes
	bra	HsStAct			;35-StActHs:	 Arrete les HS sans deasctiver!
	bra	HsReAct			;36-ReActHs:	 Re-Active tous!
	bra	MStore			;37-StoreM:	 Stocke etat souris / Show on
	bra	MRecall			;38-RecallM:	 Remet la souris
	bra	HsPri			;39-PriHs:	 Priorites SPRITES/PLAYFIELD
	bra	TokAMAL			;40-AMALTok:	 Tokenise AMAL
	bra	CreAMAL			;41-AMALCre:	 Demarre AMAL
	bra	MvOAMAL			;42-AMALMvO:	 On/Off/Freeze AMAL
	bra	DAllAMAL		;43-AMALDAll:	 Enleve TOUT!
	bra	Animeur			;44-AMAL:	 Un coup d'animation
	bra	RegAMAL			;45-AMALReg:	 Registre!
	bra	ClrAMAL			;46-AMALClr:	 Clear
	bra	FrzAMAL			;47-AMALFrz:	 FREEZE all
	bra	UFrzAMAL		;48-AMALUFrz:	 UNFREEZE all
	bra	BobSet			;49-SetBob:	 Entree set bob
	bra	BobOff			;50-OffBob:	 Arret bob
	bra	BobSOff			;51-OffBobS:	 Arret tous bobs
	bra 	BobAct			;52-ActBob:	 Actualisation bobs
	bra	BobAff			;53-AffBob:	 Affichage bobs
	bra	BobEff			;54-EffBob:	 Effacement bobs
	bra	ChipMM			;55-SyChip:	 Reserve CHIP
	bra	FastMM			;56-SyFast:	 Reserve FAST
	bra	BobLim			;57-LimBob:	 Limite bobs!
	bra	SyZoGr			;58-ZoGr:	 Zone coord graphiques
	bra	GetBob			;59-SprGet:	 Saisie graphique
	bra	Masque			;60-MaskMk:	 Calcul du masque
	bra	SpotH			;61-SpotHot:	 Fixe le point chaud
	bra	BbColl			;62-ColBob:	 Collisions bob
	bra	GetCol			;63-ColGet:	 Fonction collision
	bra	SpColl			;64-ColSpr:	 Collisions sprites
	bra	SyncO			;65-SetSync:	 Synchro on/off
	bra	Sync			;66-Synchro:	 Synchro step
	bra	SetPlay			;67-PlaySet:	 Set play direction...
	bra	BobXY			;68-XYBob:	 Get XY Bob
	bra	HsXY			;69-XYSp:	 Get XY Sprite
	bra	BobPut			;70-PutBob:	 Put Bob!
	bra	TPatch			;71-Patch:	 Patch icon/bob!
	bra	MRout			;72-MouRel:	 Souris relachee
	bra	MLimEc			;73-LimitMEc:	 Limit mouse ecran
	bra	FreeMM			;74-SyFree:	 Libere mem
	bra	HColSet			;75-SetHCol:	 Set HardCol
	bra	HColGet			;76-GetHCol:	 Get HardCol
	bra	TMovon			;77-MovOn:	 Movon!
	bra	TKSpeed			;78-KeySpeed:	 Key speed
	bra	TChanA			;79-ChanA:	 =ChanAn
	bra	TChanM			;80-ChanM:	 =ChanMv
	bra	TPrio			;81-SPrio:	 Set priority
	bra	TGetDisc		;82-GetDisc:	 State of disc drive
	bra	Add_VBL			;83-RestartVBL	 Restart VBL
	bra	Rem_VBL			;84-StopVBL	 Stop VBL
	bra	ClKWait			;85-KeyWaiting	 (P) Une touche en attente?
	bra	WMouScrFront		;86-MouScrFront	 (P) Coordonnees souris dans ecran front
	bra	WMemReserve		;87-MemReserve	 (P) Reservation memoire secure
	bra	WMemFree		;88-MemFree	 (P) Liberation memoire secure
	bra	WMemCheck		;89-MemCheck	 (P) Verification memoire
	bra	WMemFastClear		;90-MemFastClear (P)
	bra	WMemChipClear		;91-MemChipClear
	bra	WMemFast		;92-MemFast
	bra	WMemChip		;93-MemChip
	bra	WSend_FakeEvent		;94-Send_FakeEvent	Envoi d'un faux event souris
	bra	WTest_Cyclique		;95-Test_Cyclique	Tests cyclique AMOS
	bra	WAddFlushRoutine	;96-AddFlushRoutine	Ajoute une routine FLUSH
	bra	WMemFlush		;97-MemFlush	 	Force un memory FLUSH
	bra	WAddRoutine		;98-AddRoutine		Ajoute une routine
	bra	WCallRoutines		;99-CallRoutines 	Appelle les routines
	bra	WRequest_OnOff		;100-Set Requester	Change le requester

; ___________________________________________________________________
;
;	RESERVATION / LIBERATION MEMOIRE CENTRALISEE / DEBUGGAGE
; ___________________________________________________________________
;
		RsReset
Mem_Length	rs.l	1
Mem_Pile	rs.l	8
Mem_Header	equ	__Rs
Mem_Border	equ	128
Mem_Code	equ	$AA
MemList_Size	equ	1024*8

; Reservations directes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	IN:	D0	length
;	OUT:	A0	adress / nothing else changed.
WMemFastClear
	move.l	d1,-(sp)
	move.l	#Public|Clear,d1
	bsr	WMemReserve
	movem.l	(sp)+,d1
	rts
WMemFast
	move.l	d1,-(sp)
	move.l	#Public,d1
	bsr	WMemReserve
	movem.l	(sp)+,d1
	rts
WMemChipClear
	move.l	d1,-(sp)
	move.l	#Chip|Public|Clear,d1
	bsr	WMemReserve
	movem.l	(sp)+,d1
	rts
WMemChip
	move.l	d1,-(sp)
	move.l	#Chip|Public,d1
	bsr	WMemReserve
	movem.l	(sp)+,d1
	rts


	IFEQ	Debug

; Reservation memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	Longueur
;	D1=	Flags
WMemReserve
	movem.l	d0-d3/a1/a5-a6,-(sp)
	move.l	W_Base(pc),a5
	move.l	d1,d2
	move.l	d0,d3
	move.l	$4.w,a6
	jsr	AllocMem(a6)
	tst.l	d0
	bne.s	.MemX
; Out of memory: flush procedure!
	bsr	WMemFlush
; Try once again
	move.l	d2,d1
	move.l	d3,d0
	jsr	AllocMem(a6)
; Get out, address in A0, Z set.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.MemX	move.l	d0,a0
	tst.l	d0
	movem.l	(sp)+,d0-d3/a1/a5-a6
	rts

; Liberation memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1=	Debut zone
;	D0=	Taille zone
WMemFree
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	$4.w,a6
	jsr	FreeMem(a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

; Fausses fonctions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemInit
WMemEnd
WMemCheck
	rts
	ENDC
	IFNE	Debug
; Initialisation memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemInit
	movem.l	a0-a1/a5-a6/d0-d1,-(sp)
	move.l	W_Base(pc),a5
	move.l	#MemList_Size*4,d0
	move.l	#Clear|Public,d1
	move.l	$4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,T_MemList(a5)
	movem.l	(sp)+,a0-a1/a5-a6/d0-d1
	rts

; Fin memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemEnd
	movem.l	a0-a1/a5-a6/d0-d1,-(sp)
	bsr	WMemCheck
	tst.l	d0
	beq.s	.Skip
	bsr	BugBug
.Skip	move.l	W_Base(pc),a5
	move.l	#MemList_Size*4,d0
	move.l	T_MemList(a5),a1
	move.l	$4.w,a6
	jsr	FreeMem(a6)
	clr.l	T_MemList(a5)
	movem.l	(sp)+,a0-a1/a5-a6/d0-d1
	rts

; Reservation memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	Longueur
;	D1=	Flags
WMemReserve
	movem.l	d0-d3/a1-a2/a5-a6,-(sp)
	move.l	W_Base(pc),a5

;	cmp.l	#$4FC-Mem_Header-2*Mem_Border,d0
;	bne.s	.Skip
;	jsr	BugBug
;.Skip
	move.l	d1,d2
	move.l	d0,d3
	add.l	#Mem_Header+2*Mem_Border,d0
	move.l	$4.w,a6
	jsr	AllocMem(a6)
	tst.l	d0
	beq.s	.OutM
; Store the adress in the table
.Again	move.l	T_MemList(a5),a0
.Free	tst.l	(a0)+
	bne.s	.Free
	move.l	d0,-4(a0)
	move.l	d0,a0
	move.l	d3,(a0)+			Save length
	lea	4*4+4*4(sp),a1
	moveq	#7,d1
.Save	move.l	(a1)+,(a0)+			Save Content of pile
	dbra	d1,.Save
; Put code before and after memory
	move.b	#Mem_Code,d2
	move.w	#Mem_Border-1,d1
	move.l	a0,a1
	add.l	#Mem_Border,a1
	add.l	d3,a1
.Code1	move.b	d2,(a0)+
	move.b	d2,(a1)+
	dbra	d1,.Code1
; All right, memory reserved
	add.l	#Mem_Header+Mem_Border,d0
	bra.s	.MemX
; Out of memory: flush procedure!
.OutM	bsr	WMemFlush
; Try once again
	move.l	d2,d1
	move.l	d3,d0
	add.l	#Mem_Header+2*Mem_Border,d0
	jsr	AllocMem(a6)
	tst.l	d0
	bne.s	.Again
; Get out, address in A0, Z set.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.MemX	move.l	d0,a0
	tst.l	d0
	movem.l	(sp)+,d0-d3/a1-a2/a5-a6
	rts

; Liberation memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1=	Debut zone
;	D0=	Taille zone
WMemFree
	movem.l	d0-d2/a0-a2/a5-a6,-(sp)
	move.l	W_Base(pc),a5
; Find in the list
	sub.l	#Mem_Header+Mem_Border,a1
	move.l	T_MemList(a5),a2
	move.w	#MemList_Size-1,d2
.Find	cmp.l	(a2)+,a1
	beq.s	.Found
	dbra	d2,.Find
	bra.s	Mem_NFound
; Found, erase from the list
.Found	clr.l	-4(a2)
; Check the length
	cmp.l	Mem_Length(a1),d0
	bne.s	Mem_BLen
; Check the borders
	lea	Mem_Header(a1),a0
	move.l	a0,a2
	add.l	#Mem_Border,a2
	add.l	d0,a2
	move.w	#Mem_Border-1,d1
.Check	cmp.b	#Mem_Code,(a0)+
	bne.s	Mem_BCode
	cmp.b	#Mem_Code,(a2)+
	bne.s	Mem_BCode
	dbra	d1,.Check
; Perfect!
	add.l	#Mem_Header+2*Mem_Border,d0
	move.l	$4.w,a6
	jsr	FreeMem(a6)
Mem_Go	movem.l	(sp)+,d0-d2/a0-a2/a5-a6
	rts
; Error messages
; ~~~~~~~~~~~~~~
Mem_NFound
	bsr	BugBug
	bra.s	Mem_Go
	dc.b	"No found"
Mem_BLen
	bsr	BugBug
	bra.s	Mem_Go
	dc.b	"Bad leng"
Mem_BCode
	bsr	BugBug
	bra.s	Mem_Go
	dc.b	"Bad code"

; Check the whole memory list
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemCheck
	movem.l	d1-d2/a0-a2/a5-a6,-(sp)
	move.l	W_Base(pc),a5
	moveq	#0,d2
	move.l	T_MemList(a5),a0
	move.w	#MemList_Size-1,d0
.List	tst.l	(a0)+
	beq.s	.Next
	move.l	-4(a0),a1
	add.l	(a1),d2
; Check the borders
	move.l	(a1),d1
	lea	Mem_Header(a1),a1
	lea	0(a1,d1.l),a2
	add.l	#Mem_Border,a2
	move.w	#Mem_Border-1,d1
.Check	cmp.b	#Mem_Code,(a1)+
	bne.s	.BCode2
	cmp.b	#Mem_Code,(a2)+
	bne.s	.BCode2
	dbra	d1,.Check
; Next chunk
.Next	dbra	d0,.list
	move.l	d2,d0
.Xx	movem.l	(sp)+,d1-d2/a0-a2/a5-a6
	rts
.BCode2
	bsr	BugBug
	moveq	#0,d0
	bra.s	.Xx
	dc.b	"Bad code"
	even

	ENDC

;	Ajoute une routine flush
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WAddFlushRoutine
	move.l	a2,-(sp)
	lea	T_MemFlush(a5),a2
	bsr.s	WAddRoutine
	move.l	(sp)+,a2
	rts
;	Insere une routine dans une liste de routines
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1=	Pointeur sur structure
;	A2=	Liste des routines
;		dc.l	0
;		...routine...
WAddRoutine
	tst.l	(a1)			Deja la?
	bmi.s	.Deja
	move.l	(a2),d0
	lsr.l	#1,d0
	bset	#31,d0
	move.l	d0,(a1)			Branche dans la liste
	move.l	a1,(a2)
.Deja	rts

;	Apelle le memory flush
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemFlush
	lea	T_MemFlush(a5),a1
;	Appelle une liste de routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1=	Liste des routines
WCallRoutines
	move.l	(a1),d0
	beq.s	.Out
	clr.l	(a1)
.Loop	move.l	d0,a0
	move.l	(a0),d0
	clr.l	(a0)
	lsl.l	#1,d0
	movem.l	a0-a6/d0-d7,-(sp)
	jsr	4(a0)
	movem.l	(sp)+,a0-a6/d0-d7
	tst.l	d0
	bne.s	.Loop
.Out	rts

***********************************************************
*	Gestion de la souris
***********************************************************

******* Branche les interruptions
VblInit:
* Init couleurs
	bsr	FlInit
	bsr	ShInit
* Init souris
	move.l	T_MouBank(a5),a0
	move.l	a0,T_MouDes(a5)
	move.w	2(a0),T_MouTY(a5)
	clr.w	T_MouXOld(a5)
	clr.w	T_MouYOld(a5)
	move.w	#-1,T_MouShow(a5)
* Branche les interruptions!
	bsr	Add_VBL
	rts

******* Branche PROPREMENT les interruptions VBL...
Add_VBL
	move.l	a6,-(sp)
	lea	T_VBL_Is(a5),a1
	move.b	#NT_INTERRUPT,Ln_Type(a1)
	move.b	#100,Ln_Pri(a1)
	clr.l	Ln_Name(a1)
	move.l	a5,IS_DATA(a1)
	lea	VBLIn(pc),a0
	move.l	a0,IS_CODE(a1)
	move.l	$4.w,a6
	move.l	#INTB_VERTB,d0
	jsr	_LVOAddIntServer(a6)
	move.l	(sp)+,a6
	rts
******* Debranche PROPREMENT les interruptions VBL...
Rem_VBL
VBLEnd
	move.l	a6,-(sp)
	lea	T_VBL_Is(a5),a1
	tst.l	IS_CODE(a1)
	beq.s	.skip
	move.l	$4.w,a6
	move.l	#INTB_VERTB,d0
	jsr	_LVORemIntServer(a6)
.skip	move.l	(sp)+,a6
	rts

******* Entree des interruptions
VblIn:	movem.l	d2-d7/a2-a4,-(sp)
	lea	Circuits,a6
	move.l	a1,a5
* Fait les switch entrelaces
	tst.w	T_InterBit(a5)
	beq.s	SIntX2
	lea	T_InterList(a5),a5
	move.l	(a5)+,d0
	beq.s	SIntX
	move.w	$4(a6),d6
SInt0	move.l	d0,a4			* Adresse ecran
	move.l	(a5)+,a3		* Adresse marqueur
	move.w	EcNPlan(a4),d5		* D5 Nb de plans
	subq.w	#1,d5
	move.l	(a3)+,d2
	beq.s	SInt4
SInt1	move.l	(a3)+,a0
	tst.w	d6
	bmi.s	SInt2
	move.w	EcTx(a4),d0
	lsr.w	#3,d0
	add.w	d0,a0
SInt2	move.w	d5,d1
	move.l	d2,a2
	lea	EcPhysic(a4),a1
SInt3	move.l	(a1)+,d0
	add.l	a0,d0
	move.w	d0,6(a2)
	swap	d0
	move.w	d0,2(a2)
	addq.l	#8,a2
	dbra	d1,SInt3
	move.l	(a3)+,d2
	bne.s	SInt1
SInt4	move.l	(a5)+,d0
	bne.s	SInt0
SIntX	move.l	W_Base(pc),a5
SIntX2

* Fait les screen swaps
	lea	T_SwapList(a5),a0
	move.l	(a0),d0
	beq.s	SSwpX
	clr.l	(a0)+
SSwp1:	move.l	a0,a1
	move.l	d0,a4
	move.w	(a1)+,d1		* Nb de plans
	move.l	(a4)+,d0
	beq.s	SSwp4
SSwp2:	move.l	(a4)+,d3		* Decalage
	move.l	d0,a3
	move.l	a1,a2
	move.w	d1,d2
SSwp3:	move.l	(a2)+,d0
	add.l	d3,d0
	move.w	d0,6(a3)
	swap	d0
	move.w	d0,2(a3)
	addq.l	#8,a3
	dbra	d2,SSwp3
	move.l	(a4)+,d0
	bne.s	SSwp2
SSwp4:	lea	SwapL-4(a0),a0
	move.l	(a0)+,d0
	bne.s	SSwp1
SSwpX:

* Change l'adresses des sprites hard
	move.l	T_HsChange(a5),d0
	beq.s	VblPaHs
	clr.l	T_HsChange(a5)
	bsr	HsPCop
VblPaHs:

* Marque le VBL
	addq.l	#1,T_VBLCount(a5)
	addq.l	#1,T_VBLTimer(a5)
	subq.w	#1,T_EveCpt(a5)
	bset	#BitVBL,T_Actualise(a5)

* Appelle les autres routines
	lea	VblRout(a5),a4
	move.l	(a4)+,d0
	beq.s	VblPaCa
VblCall	move.l	d0,a0
	jsr	(a0)
	move.l	(a4)+,d0
	bne.s	VblCall
VblPaCa
* Affiche la souris
	bsr	MousInt
* Couleurs
	lea	T_CopMark(a5),a3

	IFEQ	EZFlag
	bsr	Shifter
	ENDC

	bsr	FlInt
	bsr	FadeI

	IFEQ	EZFlag
* Animations
	move.w	T_SyncOff(a5),d0
	bne.s	PaSync
	bsr	Animeur
PaSync:
	ENDC

	movem.l	(sp)+,d2-d7/a2-a4
	lea	$DFF000,a0
	moveq	#0,d0
	rts

******* WAIT VBL D0, multitache
WVbl_D0	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.w	d0,-(sp)
.Lp	move.l	T_GfxBase(a5),a6
	jsr	_LVOWaitTOF(a6)
	subq.w	#1,(sp)
	bne.s	.Lp
	addq.l	#2,sp
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

******* WAIT VBL
WVbl:	move.l	T_VblCount(a5),d0
WVbl1:	cmp.l	T_VblCount(a5),d0
	beq.s	WVbl1
	moveq	#0,d0
	rts

******* Traitement de la souris
MousInt:tst.b	T_AMOSHere(a5)
	beq	MouF

	move.w	T_MouseX(a5),d0
	move.w	T_MouseY(a5),d1

; Limite la souris
MouV7	cmp.w	T_MouXMin(a5),d0
	bge.s	Mou5
	move.w	T_MouXMin(a5),d0
Mou5:	cmp.w	T_MouXMax(a5),d0
	ble.s	Mou6
	move.w	T_MouXMax(a5),d0
Mou6:	cmp.w	T_MouYMin(a5),d1
	bge.s	Mou7
	move.w	T_MouYMin(a5),d1
Mou7:	cmp.w	T_MouYMax(a5),d1
	ble.s	Mou8
	move.w	T_MouYMax(a5),d1
Mou8:	move.w	d0,T_MouseX(a5)
	move.w	d1,T_MouseY(a5)
	lsr.w	#1,d0
	lsr.w	#1,d1
	move.w	d0,T_XMouse(a5)
	move.w	d1,T_YMouse(a5)

; Poke les mots de control, si SHOW
	move.w	T_MouShow(a5),d2
	bmi.s	MouF
	sub.w	T_MouHotX(a5),d0
	sub.w	T_MouHotY(a5),d1
	move.l	T_HsPhysic(a5),a0		;Adresse du dessin
	move.l	T_HsLogic(a5),a1
	move.l	T_HsInter(a5),a2
	ror.w	#1,d0
	move.b	d1,d2
	lsl.w	#8,d2
	move.b	d0,d2
	move.w	d2,(a0)
	move.w	d2,(a1)
	move.w	d2,(a2)
	clr.w	d2
	btst	#8,d1
	beq.s	Mou10
	bset	#8+2,d2
Mou10:	add.w	T_MouTy(a5),d1
	move.b	d1,d2
	ror.w	#8,d2
	btst	#8,d1
	beq.s	Mou11
	bset	#1,d2
Mou11:	btst	#15,d0
	beq.s	Mou12
	bset	#0,d2
Mou12:	move.w	d2,2(a0)
	move.w	d2,2(a1)
	move.w	d2,2(a2)
MouF:	rts

***********************************************************
*	BOUTONS DE LA SOURIS
***********************************************************
MBout:	clr.w	d1
	tst.b	T_AMOSHere(a5)
	beq.s	MouB3
	move.w	T_MouXOld(a5),d0
	btst	#IEQUALIFIERB_LEFTBUTTON,d0
	beq.s	MouB1
	bset	#0,d1
MouB1:	btst	#IEQUALIFIERB_RBUTTON,d0
	beq.s	MouB2
	bset	#1,d1
MouB2:	btst	#IEQUALIFIERB_MIDBUTTON,d0
	beq.s	MouB3
	bset	#2,d1
MouB3:	moveq	#0,d0
	rts
******* Bouton relache?
MRout:	clr.w	d1
	clr.w	d2
	clr.w	d3
	tst.b	T_AMOSHere(a5)
	beq.s	MouB3
	move.w	T_OldMk(a5),d2
	move.w	T_MouXOld(a5),d0
	btst	#IEQUALIFIERB_LEFTBUTTON,d0
	beq.s	MouR1
	bset	#0,d3
	btst	#0,d2
	bne.s	MouR1
	bset	#0,d1
MouR1:	btst	#IEQUALIFIERB_RBUTTON,d0
	beq.s	MouR2
	bset	#1,d3
	btst	#1,d2
	bne.s	MouR2
	bset	#1,d1
MouR2:	btst	#IEQUALIFIERB_MIDBUTTON,d0
	beq.s	MouR3
	bset	#2,d3
	btst	#2,d2
	bne.s	MouR3
	bset	#2,d1
MouR3:	move.w	d3,T_OldMk(a5)
	moveq	#0,d0
	rts

**********************************************************
*	Remember MOUSE
MRecall:move.w	T_OMouShow(a5),T_MouShow(a5)
	move.w	T_OMouSpr(a5),d1
	bra.s	MChange
**********************************************************
*	Store MOUSE/SHOW ON
MStore:	move.w	T_MouShow(a5),T_OMouShow(a5)
	move.w	T_MouSpr(a5),T_OMouSpr(a5)
	clr.w	T_MouShow(a5)
	moveq	#0,d1
**********************************************************
*	CHANGE MOUSE D1
MChange:
*******
	move.w	T_MouShow(a5),-(sp)
	move.w	#-1,T_MouShow(a5)
MCh0:	move.w	d1,d2
	cmp.w	#3,d1
	bcc.s	MCh3
* Pointe dans la banque de la souris
	move.l	T_MouBank(a5),a0
	bra.s	MCh2
MCh1:	move.w	(a0)+,d0
	mulu	(a0)+,d0
	mulu	(a0)+,d0
	lsl.w	#1,d0
	lea	4(a0,d0.w),a0
MCh2:	subq.w	#1,d1
	bpl.s	MCh1
	bra.s	MCh4
* Pointe dans la banque de sprites
MCh3:	move.l	T_SprBank(a5),d0
	beq.s	MChE
	move.l	d0,a0
	subq.w	#3,d1
	cmp.w	(a0)+,d1
	bcc.s	MChE
	lsl.w	#3,d1
	move.l	0(a0,d1.w),a0
	cmp.w	#1,(a0)			* Verifie ke le sprite est bon!
	bne.s	MChE
	cmp.w	#2,4(a0)
	bne.s	MChE
* Change!
MCh4:	move.w	d2,T_MouSpr(a5)
	move.l	a0,T_MouDes(a5)
	move.w	2(a0),T_MouTY(a5)
	move.w	6(a0),T_MouHotX(a5)
	move.w	8(a0),T_MouHotY(a5)
* Re-Affiche la souris???
	tst.w	(sp)
	bmi.s	MCh5
	bsr	HiSho1
	bra.s	MChX
MCh5:	bsr	HiHi
* Cbon
MChX:	move.w	(sp)+,T_MouShow(a5)
	moveq	#0,d0
	rts
* Erreur--> met la souris 1!
MChE:	moveq	#0,d1
	bra	MCh0

**********************************************************
*	HIDE / HIDE ON: D1= off/on
**********************************************************
MHide:	tst.w	T_CopON(a5)
	beq.s	HiSho0
	move.w	T_MouShow(a5),d0
	tst.w	d1
	bne.s	Hid1
	subq.w	#1,d0
	bra.s	HiSho
Hid1:	moveq	#-1,d0
	bra.s	HiSho

**********************************************************
*	SHOW / SHOW ON: D1= off/on
**********************************************************
MShow:	tst.w	T_CopON(a5)		* Si COPPER OFF -> NON!!!
	beq.s	HiSho0
	move.w	T_MouShow(a5),d0
	tst.w	d1
	bne.s	Sho1
	addq.w	#1,d0
	bra.s	HiSho
Sho1:	moveq	#0,d0

******* Routine commune / affiche - eteint
HiSho:	move.w	d0,T_MouShow(a5)
	beq.s	HiSho1
	cmp.w	#-1,d0
	bne.s	HiSho0
; HIDE
HiHi:	moveq	#0,d1
	bsr	HsUSet
	bsr	HAa3
HiSho0:	moveq	#0,d0
	rts
; SHOW
HiSho1:	move.w	#-1,T_MouShow(a5)
	moveq	#0,d1
	move.w	T_XMouse(a5),d2
	move.w	T_YMouse(a5),d3
	move.l	T_MouDes(a5),a1
	bsr	HsSet
	bsr	HAa3
	clr.w	T_MouShow(a5)
	moveq	#0,d0
	rts
* Appele TROIS fois HsAff!
HAa3:	move.w	#3,-(sp)
HA3a:	tst.l	T_HsChange(a5)
	bne.s	HA3a
	bsr	HsAff
	subq.w	#1,(sp)
	bne.s	HA3a
	addq.l	#2,sp
	rts

**********************************************************
*	COORDONNEES
**********************************************************
******* Ecrans D3
*	<0	=> Rien du tout
*	0	=> Ecran courant
*	>0	=> Ecran+1
EcToD1:	tst.w	d3
	bmi.s	EcToD4
	bne.s	EcToD2
	move.l	T_EcCourant(a5),a0
	rts
EcToD2:	lsl.w	#2,d3
	lea	T_EcAdr(a5),a0
	move.l	-4(a0,d3.w),d3
	beq.s	EcToD3
	move.l	d3,a0
	rts
EcToD3:	addq.l	#4,sp
	moveq	#3,d0
	rts
EcToD4:	addq.l	#4,sp
	move.l	#EntNul,d1
	move.l	d1,d2
	moveq	#0,d0
	rts

*******	XYMOUSE
MXy:	moveq	#0,d1
	moveq	#0,d2
	move.w	T_XMouse(a5),d1
	move.w	T_YMouse(a5),d2
	moveq	#0,d3
	rts

******* XYSCREEN: conversion HARD-> SCREEN
*	D3-> Ecran
*	D1-> X
*	D2-> Y
CXyScr	bsr	EcToD1
* Coordonnee en Y
	add.w	#EcYBase,d2
	sub.w	EcWy(a0),d2
	btst	#2,EcCon0+1(a0)
	beq.s	XyH0
	asl.w	#1,d2
XyH0	add.w	EcVy(a0),d2
	ext.l	d2
* Coordonnee en X
XyH1:	sub.w	EcWx(a0),d1
	btst	#7,EcCon0(a0)
	beq.s	XyH2
	asl.w	#1,d1
XyH2:	add.w	EcVx(a0),d1
	ext.l	d1
	moveq	#0,d0
	rts

******* XYHARD : conversion SCREEN -> HARD
*	D3= ecran
*	D1/D2= x/y
CXyHard	bsr	EcToD1
* Coordonnee en X
CXyS:	tst.w	EcCon0(a0)
	bpl.s	CXyS0
	asr.w	#1,d1
CXyS0:	add.w	EcWX(a0),d1
	ext.l	d1
* Coordonnee en Y
CXyS2:	btst	#2,EcCon0+1(a0)
	beq.s	CXyS3
	asr.w	#1,d2
CXyS3	add.w	EcWY(a0),d2
	sub.w	#EcYBase,d2
	ext.l	d2
	moveq	#0,d0
	rts

******* XY WINDOW : conversion XY screen -> XY window
*	D1/D2= X/Y
CXyWi:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
* En X
	sub.w	WiDyI(a0),d2
	bmi.s	CXyw0
	divu	WiTyCar(a0),d2
	cmp.w	WiTyI(a0),d2
	bcc.s	CXyw0
	ext.l	d2
	bra.s	CXyw1
CXyw0:	move.l	#EntNul,d2
* En Y
CXyw1:	lsr.w	#3,d1
	sub.w	WiDxI(a0),d1
	bmi.s	CXyw3
	cmp.w	WiTxI(a0),d1
	bcc.s	CXyW3
	ext.l	d1
CXyw2:	move.l	d2,d0			D0= Signe
	or.l	d1,d0
	rts
CXyw3:	move.l	#EntNul,d1
	bra.s	CXyw2

******* Retourne la souris dans l'ecran de devant
WMouScrFront
	move.l	d4,-(sp)
	move.w	T_XMouse(a5),d1
	move.w	T_YMouse(a5),d2
	moveq	#0,d3
	moveq	#16,d4
	bsr	GetSIn
	move.l	d1,d3
	bmi.s	.Out
	move.l	d1,-(sp)
	addq.w	#1,d3
	move.w	T_XMouse(a5),d1
	move.w	T_YMouse(a5),d2
	bsr	CXYScr
	move.l	(sp)+,d0
.Out	movem.l	(sp)+,d4
	rts
.Hors	moveq	#-1,d0
	bra.s	.Out

******* Recherche l'ecran contenant X/Y
*	D1/D2= X/Y HARD
*	D3= 1er ecran
*	D4= Ecran MAX
GetSIn:	lea	T_EcPri(a5),a1
	add.w	#EcYBase,d2
	tst.w	d3
	beq.s	GSin1
	bmi.s	GSin1
	bsr	EcToD1
	move.l	a1,a2
GSin0:	tst.l	(a2)
	bmi.s	GSin1
	cmp.l	(a2)+,a0
	bne.s	GSin0
	lea	-4(a2),a1
* Cherche l'ecran dans l'ordre des priorites
GSin1:	move.l	(a1)+,d0
	bmi.s	GSinX
	move.l	d0,a0
	cmp.w	EcNumber(a0),d4
	bls.s	GSin1
	btst	#BitHide,EcFlags(a0)
	bne.s	GSin1
* Coordonnee en X
	move.w	d1,d3
	sub.w	EcWx(a0),d3
	bcs.s	GSin1
	cmp.w	EcWTx(a0),d3
	bcc.s	GSin1
* Coordonnee en Y
	move.w	d2,d3
	sub.w	EcWy(a0),d3
	bcs.s	GSin1
	cmp.w	EcWTy(a0),d3
	bcc.s	GSin1
* Trouve!
	moveq	#0,d1
	move.w	EcNumber(a0),d1
	moveq	#0,d0
	rts
* Pas trouve!
GSinX:	move.l	#EntNul,d1
	moveq	#0,d0
	rts

**********************************************************
*	SET MOUSE
**********************************************************

******* Set mouse ABSOLU
MSetAb:	move.l	#EntNul,d0

	cmp.l	d0,d1
	beq.s	MSaX
	lsl.w	#1,d1
	cmp.w	T_MouXMin(a5),d1
	bcc.s	MSa1
	move.w	T_MouXMin(a5),d1
MSa1:	cmp.w	T_MouXMax(a5),d1
	bcs.s	MSa2
	move.w	T_MouXMax(a5),d1
MSa2:	move.w	d1,T_MouseX(a5)
	lsr.w	#1,d1
	move.w	d1,T_XMouse(a5)

MSaX	cmp.l	d0,d2
	beq.s	MSaXx
	lsl.w	#1,d2
	cmp.w	T_MouYMin(a5),d2
	bcc.s	MSa3
	move.w	T_MouYMin(a5),d2
MSa3:	cmp.w	T_MouYMax(a5),d2
	bcs.s	MSa4
	move.w	T_MouYMax(a5),d2
MSa4:	move.w	d2,T_MouseY(a5)
	lsr.w	#1,d2
	move.w	d2,T_YMouse(a5)

MSaXx:	moveq	#0,d0
	rts

**********************************************************
*	LIMIT MOUSE D1/D2/D3/D4
**********************************************************
******* LIMIT MOUSE ECRAN
*	D1= 0-> ecran courant
*	D1>0 -> ecran
MLimEc	move.w	d1,d3
	move.w	d1,d4
	clr.w	d1
	clr.w	d2
	bsr	CXyHard
	movem.w	d1/d2,-(sp)
	move.w	EcTx(a0),d1
	move.w	EcTy(a0),d2
	subq.w	#1,d1
	subq.w	#1,d2
	move.w	d4,d3
	bsr	CXyHard
	move.w	d1,d3
	move.w	d2,d4
	movem.w	(sp)+,d1-d2
******* Absolu
MLimA:	cmp.w	#458,d3
	bls.s	MLima1
	move.w	#458,d3
MLima1	cmp.w	#312,d4
	bls.s	MLima2
	move.w	#312,d4
MLima2	tst.w	d1
	bpl.s	MLima3
	clr.w	d1
MLima3	tst.w	d2
	bpl.s	MLima4
	clr.w	d2
MLima4	cmp.w	d3,d1
	bls.s	MLima5
	exg	d1,d3
MLima5	cmp.w	d4,d2
	bls.s	MLima6
	exg	d2,d4
MLima6	lsl.w	#1,d1
	lsl.w	#1,d2
	lsl.w	#1,d3
	lsl.w	#1,d4
	move.w	d1,T_MouXMin(a5)
	move.w	d3,T_MouXMax(a5)
	move.w	d2,T_MouYMin(a5)
	move.w	d4,T_MouYMax(a5)
	moveq	#0,d0
	rts

**********************************************************
*	JOYSTICK / d1= # de port
**********************************************************
ClJoy:	tst.b	T_AMOSHere(a5)
	beq.s	JoyNo
	moveq	#6,d0			;# du bit de FEU
	add.w	d1,d0
	lea	Circuits,a0
	lsl.w	#1,d1
	move.w	10(a0,d1.w),d2
; Prend le bouton
	clr.w	d1
	btst	d0,CiaAPrA
	bne.s	Joy1
	bset	#4,d1
; Teste les directions
Joy1:	lea	JoyTab(pc),a0
	lsl.b	#6,d2
	lsr.w 	#6,d2
	and.w	#$000F,d2
	or.b	0(a0,d2.w),d1
Joy2	moveq	#0,d0
	rts
JoyNo	moveq	#0,d1
	bra.s	Joy2
JoyTab:	dc.b 	%0000,%0010,%1010,%1000,%0001,%0000,%0000,%1001
	dc.b 	%0101,%0000,%0000,%0000,%0100,%0110,%0000,%0000

***********************************************************
*	RESERVE ZONES D1= nb de zones - Enleve la memoire
***********************************************************
SyResZ:	move.l	T_EcCourant(a5),a0
	tst.l	EcAZones(a0)
	beq.s	SyRz1
* Efface les anciennes zones
	move.l	EcAZones(a0),a1
	move.w	EcNZones(a0),d0
	mulu	#8,d0
	bsr	FreeMm
	clr.l	EcAZones(a0)
	clr.w	EcNZones(a0)
* Reserve les nouvelles
SyRz1:	move.w	d1,d0
	beq.s	ZoOk
	mulu	#8,d0
	bsr	FastMm
	beq	RzErr
	move.l	d0,EcAZones(a0)
	move.w	d1,EcNZones(a0)
ZoOk	moveq	#0,d0
        rts
RzErr:	moveq	#1,d0
	rts
NoZo:	moveq	#29,d0
	rts

***********************************************************
*	RAZ zone D1
***********************************************************
SyRazZ:	move.l	T_EcCourant(a5),a1
	move.l	EcAZones(a1),d0
	beq	NoZo
	move.l	d0,a0
        tst.w	d1
        beq 	SyRzz
        cmp.w	EcNZones(a1),d1
        bhi 	PErr7
        lsl.w	#3,d1
        lea	-8(a0,d1.w),a0
	clr.l	(a0)+
	clr.l	(a0)
	bra	ZoOk
* Toutes les zones
SyRzz:	move.w	EcNZones(a1),d1
	subq.w	#1,d1
SyRzz1:	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d1,SyRzz1
	bra	ZoOk

***********************************************************
*	SET ZONE dans l'ecran courant
*	D1-D2/D3/D4/D5 n-dx/dy/fx/fy
***********************************************************
SySetZ: move.l 	T_EcCourant(a5),a1
	move.l	EcAZones(a1),d0
	beq	NoZo
	move.l	d0,a0
        tst.w	d1
        beq 	RzErr
        cmp.w	EcNZones(a1),d1
        bhi 	RzErr
        lsl.w	#3,d1
        lea	-8(a0,d1.w),a0
        cmp.w	d4,d2
        bcc 	RzErr
        cmp.w 	d5,d3
        bcc 	RzErr
        move.w	d2,(a0)+
        move.w 	d3,(a0)+
        move.w 	d4,(a0)+
        move.w 	d5,(a0)+
	bra	ZoOk

***********************************************************
*	ZONE GRAPHIC ecran D1/D2 -D3
SyZoGr:	bsr	EcToD1
	move.w	d2,d4
	move.w	d1,d3
	move.l	a0,a1
	moveq	#0,d0
	bra	GZone

***********************************************************
*	ZONE HARD ecran D1/D2 - D3
SyZoHd:	bsr	EcToD1
	move.w	d2,d4
	move.w	d1,d3
	move.l	a0,a1
	moveq	#0,d0

******* Regarde si les coordonnees HARD D3/D4 sont dans l'ecran A1!
ZoEc:	cmp.w	EcNumber(a1),d5
	bls.s	ZoEcX
; Coordonnee en X
	move.w	d3,d1
	sub.w	EcWx(a1),d1
	bcs.s	ZoEcX
	cmp.w	EcWTx(a1),d1
	bcc.s	ZoEcX
; Coordonnee en Y
	move.w	d4,d2
	add.w	#EcYBase,d2
	sub.w	EcWy(a1),d2
	bcs.s	ZoEcX
	cmp.w	EcWTy(a1),d2
	bcc.s	ZoEcX
	btst	#7,EcCon0(a1)
	beq.s	ZoEc2
	lsl.w	#1,d1
ZoEc2:	btst	#2,EcCon0+1(a1)
	beq.s	ZoEc3
	lsl.w	#1,d2
ZoEc3:	add.w	EcVx(a1),d1
	add.w	EcVy(a1),d2
	bsr	GZone
	rts
ZoEcX:	moveq	#0,d1
	rts

******* Explore la table de l'ecran A1
GZone:	movem.l	a2/d3,-(sp)
	cmp.w	EcNumber(a1),d5
	bls.s	GZo3
	move.l	EcAZones(a1),d3
	beq.s	GZo3
	move.l	d3,a2
	move.w	EcNZones(a1),d3
	subq.w	#1,d3
GZo1:	tst.l	4(a2)
	beq.s	GZo2
	cmp.w	(a2),d1
        bcs.s 	GZo2
        cmp.w 	2(a2),d2
        bcs.s	GZo2
	cmp.w	4(a2),d1
	bhi.s 	GZo2
	cmp.w 	6(a2),d2
	bhi.s 	GZo2
	move.w	EcNZones(a1),d1
	sub.w	d3,d1
	movem.l	(sp)+,a2/d3
	ext.l	d1
        rts
GZo2:	lea	8(a2),a2
	dbra	d3,GZo1
GZo3:	movem.l	(sp)+,a2/d3
	moveq	#0,d1
	rts

***********************************************************
*	ZONE pour la souris
SyMouZ:	move.w	T_XMouse(a5),d3
	move.w	T_YMouse(a5),d4
	moveq	#16,d5
	lea	T_EcPri(a5),a0
HZo1:	moveq	#0,d1
	move.l	(a0)+,d0
	bmi.s	HZoX
	move.l	d0,a1
	bsr	ZoEc
	beq.s	HZo1
	swap	d1
	move.w	EcNumber(a1),d1
HZoX:	moveq	#0,d0
	rts

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* SPRITES HARDWARE
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
***********************************************************
*	INITIALISATION SPRITES HARDWARE / D0= Nbre lignes
HsInit:	movem.l	d1-d7/a1-a6,-(sp)
	move.w	d0,-(sp)
* Reserve la table
	moveq	#HsNb,d0
	mulu	#HsLong,d0
	addq.l	#4,d0
	bsr	FastMm
	beq	GFatal
	addq.l	#4,d0
	move.l	d0,T_HsTable(a5)
* Va reserver les buffers
	move.w	(sp)+,d0
	bsr	HsRBuf
	bne	GFatal
* Pas d'erreur
HsOk:	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#0,d0
	rts

***********************************************************
*	CHANGE LA TAILLE DU BUFFER SPRITES
*	D1= Nb de lignes
HsSBuf:
*******
	movem.l	d1-d7/a1-a6,-(sp)
	tst.w	T_CopOn(a5)			* Si COPPER OFF -> RIEN!
	beq.s	HsOk
	addq.w	#2,d1
	cmp.w	T_HsNLine(a5),d1
	beq.s	HsOK
	move.w	d1,-(sp)
* Enleve tous les sprites
	move.w	#-1,T_MouShow(a5)
	bsr	HsOff
	moveq	#-1,d1
	bsr	MHide
* Fait pointer les registres sur RIEN!
	clr.w	T_HsTCol(a5)
	move.l	T_CopLogic(a5),a0
	add.l	T_CopLong(a5),a0
	clr.l	-(a0)
	move.l	a0,T_HsChange(a5)
HsCl1:	tst.l	T_HsChange(a5)
	bne.s	HsCl1
* Efface la memoire
	bsr	HsEBuf
* Reserve la nouvelle
	move.w	(sp)+,d0
	bsr	HsRBuf
	bne.s	HsCl2
* Ok! Remet la souris
	moveq	#-1,d1
	bsr	MShow
	bra	HsOk
* Pas assez! Essaie de reserver 16 lignes au moins!
HsCl2:	moveq	#16,d0			* 1728 octets!
	move.w	d0,T_HsNLine(a5)
	bsr	HsRBuf
	beq.s	HsCl3
	moveq	#2,d0			* 384 octets!
	bsr	HsRBuf
	bne	HsCl4
HsCl3:	move.l	T_MouBank(a5),T_MouDes(a5)
	clr.w	T_MouSpr(a5)
	moveq	#-1,d1
	bsr	MShow
HsCl4	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#1,d0
	rts

******* Reserve le buffer des colonnes
HsRBuf:	clr.l	T_HsBuffer(a5)
	clr.w	T_HsPMax(a5)
	clr.w	T_HsTCol(a5)
	move.w	d0,T_HsNLine(a5)
	mulu	#4*8,d0
	move.l	d0,d1
	mulu	#3,d0
	move.l	d0,T_HsTBuf(a5)
	bsr	ChipMm
	beq.s	HsRBe
	move.l	d0,T_HsBuffer(a5)
	move.l	d0,T_HsPhysic(a5)
	add.l	d1,d0
	move.l	d0,T_HsLogic(a5)
	add.l	d1,d0
	move.l	d0,T_HsInter(a5)
* Calcule les colonnes
	lsr.l	#3,d1
	move.w	d1,T_HsTCol(a5)
	lsr.w	#2,d1
	subq.w	#2,d1
	move.w	d1,T_HsPMax(a5)
* Ok!
	moveq	#0,d0
	rts
* Erreur!
HsRbe:	moveq	#1,d0
	rts

******* Efface le buffer des colonnes
HsEBuf:	tst.l	T_HsBuffer(a5)
	beq.s	HsEb1
	clr.w	T_HsPMax(a5)
	clr.w	T_HsTCol(a5)
	move.l	T_HsBuffer(a5),a1
	clr.l	T_HsBuffer(a5)
	move.l	T_HsTBuf(a5),d0
	bsr	FreeMm
HsEb1:	rts

******* Poke l'adresse D0 dans les listes copper
HsPCop:	move.w	T_HsTCol(a5),d1
	ext.l	d1
	move.l	T_CopLogic(a5),a0
	move.l	T_CopPhysic(a5),a1
	addq.l	#4,a0
	addq.l	#4,a1
	moveq	#7,d2
HsPc1:	swap	d0
	move.w	d0,2(a0)
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a0)
	move.w	d0,6(a1)
	add.l	d1,d0
	lea	8(a0),a0
	lea	8(a1),a1
	dbra	d2,HsPc1
	rts

***********************************************************
*	SET SPRITE PRIORITY (0-1)
HsPri:	move.l	T_EcCourant(a5),a0
	cmp.w	#5,d1
	bcs.s	HsPr1
	moveq	#0,d1
HsPr1:	move.w	EcCon2(a0),d2
	and.w	#%1111000,d2
	move.w	EcDual(a0),d0
	beq.s	HsPrP
	bpl.s	HsPrP
* Ecran DUAL 2 --> Poke dans le DUAL 1!
	neg.w	d0
	lsl.w	#2,d0
	lea	T_EcAdr(a5),a0
	move.l	-4(a0,d0.w),d0
	beq.s	HsPrX
	move.l	d0,a0
	lsl.w	#3,d1
	move.w	EcCon2(a0),d2
	and.w	#%1000111,d2
* Poke!
HsPrP:	or.w	d1,d2
	move.w	d2,EcCon2(a0)
HsPrX:	moveq	#0,d0
	rts

***********************************************************
*	ARRET SPRITES HARDWARE
HsEnd:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_HsTable(a5),d0
	beq.s	HsE1
	move.l	d0,a1
	subq.l	#4,a1
	moveq	#HsNb,d0
	mulu	#HsLong,d0
	addq.l	#4,d0
	bsr	FreeMm
HsE1:	bsr	HsEBuf
	bra	HsOk

**********************************************************
*	SET SPRITE BANK - A1
HsBank:	cmp.l	T_SprBank(a5),a1
	beq.s	HsBk1
*	movem.l	a0-a2/d0-d7,-(sp)
	move.l	a1,T_SprBank(a5)
*	bsr	HsOff
*	bsr	BobSOff
*	movem.l	(sp)+,a0-a2/d0-d7
HsBk1:	moveq	#0,d0
	rts

**********************************************************
*	Adresse actualisation HS D1--> A0
HsActAd:
	cmp.w	#HsNb,d1
	bcc.s	HsAdE
	lea	T_HsTAct(a5),a0
	move.w	d1,d0
	lsl.w	#3,d0
	lea	0(a0,d0.w),a0
	rts
HsAdE:	addq.l	#4,sp
	moveq	#1,d0
	rts

**********************************************************
*	SPRITE X OFF D1=Sprite
HsXOff:
	bsr	HsActAd
	clr.w	(a0)
	clr.w	6(a0)
	bsr	DAdAMAL
	bsr	HsUSet
	bset	#BitSprites,T_Actualise(a5)
	moveq	#0,d0
	rts

**********************************************************
*	SPRITE OFF
HsOff:	moveq	#0,d1
HsOO1:	bsr	HsActAd
	clr.w	(a0)
	clr.w	6(a0)
	bsr	DAdAMAL
	bsr	HsUSet
	addq.w	#1,d1
	cmp.w	#HsNb,d1
	bne.s	HsOO1
* Actualise
	bset	#BitSprites,T_Actualise(a5)
	moveq	#0,d0
	rts

**********************************************************
*	=XY SPRITE
HsXY:	bsr	HsActAd
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	moveq	#0,d0
	rts

**********************************************************
*	SPRITE n,x,y,a (D1/D2/D3/D4)
HsNxya:	bsr	HsActAd
	move.l	#EntNul,d0
	cmp.l	d0,d2
	bne.s	HsN1
	move.w	2(a0),d2
	beq.s	HsNErr
HsN1:	cmp.l	d0,d3
	bne.s	HsN2
	move.w	4(a0),d3
	beq.s	HsNErr
HsN2:	cmp.l	d0,d4
	bne.s	HsN3
	move.w	6(a0),d4
HsN3:	bset	#3,(a0)
	addq.l	#2,a0
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	bset	#BitSprites,T_Actualise(a5)
	moveq	#0,d0
	rts
HsNErr:	moveq	#1,d0
	rts

**********************************************************
*	EFFACE DE L'ECRAN TOUS LES SPRITES HARD
HsStAct:moveq	#0,d1
HsSa1:	bsr	HsUSet
	addq.w	#1,d1
	cmp.w	#HsNb,d1
	bne.s	HsSa1
	rts

**********************************************************
*	RE-ACTIVE TOUS les sprites HARD
HsReAct:lea	T_HsTAct(a5),a0
	moveq	#HsNb-1,d0
HsRa0:	tst.b	(a0)
	bmi.s	HsRa1
	bset	#3,(a0)
HsRa1:	lea	8(a0),a0
	dbra	d0,HsRa0
	rts

**********************************************************
*	ACTUALISATION SPRITES HARD
HsAct:	movem.l	d2-d7/a2-a6,-(sp)
	move.l	T_SprBank(a5),d0
	beq.s	HsActX
	move.l	d0,a2
	move.w	(a2)+,d6
	lea	T_HsTAct(a5),a0
	move.w	#HsNb,d7
	subq.w	#1,d7
	moveq	#0,d1
HsAct0:	tst.b	(a0)
	bne.s	HsAct2
HsAct1:	lea	8(a0),a0
	addq.w	#1,d1
	dbra	d7,HsAct0
HsActX:	movem.l	(sp)+,d2-d7/a2-a6
	rts
******* Change!
HsAct2:	bmi.s	HsAct3
* Dessine
	clr.w	(a0)
	move.w	2(a0),d2
	move.w	4(a0),d3
	move.w	6(a0),d0
	and.w	#$3FFF,d0
	beq.s	HsAct1
	cmp.w	d6,d0
	bhi.s	HsAct1
	lsl.w	#3,d0
	move.l	-8(a2,d0.w),d0
	beq.s	HsAct1
	move.l	d0,a1
	bsr	HsSet
	bra.s	HsAct1
* Efface
HsAct3:	clr.w	(a0)
	clr.w	6(a0)
	bsr	HsUSet
	bra.s	HsAct1

**********************************************************
*	POSITIONNEMENT D'UN SPRITE HARD!
*	D1= Nb
*	D2= X
*	D3= Y
*	D4= Retournement?
*	A1= Dessin

HsSet:	movem.l	d1-d7,-(sp)
	movem.l	a1/a3/a4,-(sp)
	move.w	d1,d0
	mulu	#HsLong,d1
	move.l	T_HsTable(a5),a3
	lea	0(a3,d1.w),a4

**************************************** Sprite DIRECT!
	cmp.w	#8,d0
	bcc	Hss4
* Si sprite 0: la souris est-elle presente?
	tst.w	d0
	bne.s	HsDm
	tst.w	T_MouShow(a5)
	bpl	Hss30
* Doit recopier l'image?
HsDm:	cmp.l	HsImage(a4),a1
	beq.s	HsD0
	move.w	2(a1),d0
	addq.w	#1,d0
	cmp.w	T_HsPMax(a5),d0
	bcc	Hss30
	move.l	a1,HsImage(a4)
	move.w	#3,2(a4)
* Poke!
HsD0:	move.w	#1,(a4)
	move.w	d2,HsX(a4)
	move.w	d3,HsY(a4)
* Calcule les mots de controle
	move.w	6(a1),d0		* Pas de retournement!
	lsl.w	#2,d0
	asr.w	#2,d0
	sub.w	d0,d2
	bpl.s	HsD1
	clr.w	d2
HsD1:	sub.w	8(a1),d3
	bpl.s	HsD2
	clr.w	d3
HsD2:	ror.w	#1,d2
	move.b	d3,d0
	lsl.w	#8,d0
	move.b	d2,d0
	move.w	d0,HsControl(a4)
	clr.w	d0
	btst	#8,d3
	beq.s	HsD3
	bset	#8+2,d0
HsD3:	add.w	2(a1),d3
	move.b	d3,d0
	ror.w	#8,d0
	btst	#8,d3
	beq.s	HsD4
	bset	#1,d0
HsD4:	btst	#15,d2
	beq.s	HsD5
	bset	#0,d0
HsD5:	move.w	d0,HsControl+2(a4)
* A y est, doit actualiser!
	bra	Hss30

********************************** Sprites partages...
Hss4:	tst.l	(a4)
	beq.s	Hss6
	cmp.w	HsY(a4),d3
	bne.s	Hss5
	cmp.l	HsImage(a4),a1
	beq.s	Hss6
Hss5:	move.w	(a4),d6
	move.w	HsNext(a4),d7
	clr.l	(a4)
	move.w	d7,2(a3,d6.w)
	beq.s	Hss6
	move.w	d6,0(a3,d7.w)
Hss6:
******* Poke!
	move.w	d2,HsX(a4)
	move.w	d3,HsY(a4)
	move.l	a1,HsImage(a4)
******* Calcule les mots de controle
	move.w	6(a1),d0
	lsl.w	#2,d0
	asr.w	#2,d0
	sub.w	d0,d2
	bpl.s	Hss10
	clr.w	d2
Hss10:	sub.w	8(a1),d3
	bpl.s	Hss11
	clr.w	d3
Hss11:	move.w	d3,HsYr(a4)
	move.w	d3,d5
	ror.w	#1,d2
	move.b	d3,d0
	lsl.w	#8,d0
	move.b	d2,d0
	move.w	d0,HsControl(a4)
	clr.w	d0
	btst	#8,d3
	beq.s	Hss12
	bset	#8+2,d0
Hss12:	add.w	2(a1),d3
	move.b	d3,d0
	ror.w	#8,d0
	btst	#8,d3
	beq.s	Hss13
	bset	#1,d0
Hss13:	btst	#15,d2
	beq.s	Hss14
	bset	#0,d0
Hss14:	move.w	d0,HsControl+2(a4)

******* Recalcule???
	tst.l	(a4)
	bne.s	Hss30
	moveq	#-4,d7
	move.w	HsNext(a3,d7.w),d6
	beq.s	Hss22
Hss20:	move.w	d6,d7
	cmp.w	HsYr(a3,d7.w),d5
	bcs.s	Hss23
	bhi.s	Hss21
	cmp.w	d7,d1			* Si EGAL-> numero joue
	bcs.s	Hss23
* Prend le suivant!
Hss21:	move.w	HsNext(a3,d7.w),d6
	bne.s	Hss20
* Le met ` la fin!
Hss22:	move.w	d1,HsNext(a3,d7.w)
	move.w	d7,HsPrev(a3,d1.w)
	bra.s	Hss30
* L'insere au milieu
Hss23:	move.w	HsPrev(a3,d7.w),d0
	move.w	d0,HsPrev(a3,d1.w)
	move.w	d1,HsPrev(a3,d7.w)
	move.w	d1,HsNext(a3,d0.w)
	move.w	d7,HsNext(a3,d1.w)

******* Cibon!
Hss30:	movem.l	(sp)+,a1/a3/a4
	movem.l	(sp)+,d1-d7
	rts

***********************************************************
*	ARRET D'UN SPRITE HARD
HsUSet:	movem.l	a3/a4/d6/d7,-(sp)
	move.w	d1,d0
	mulu	#HsLong,d0
	move.l	T_HsTable(a5),a3
	lea	0(a3,d0.w),a4
	cmp.w	#8,d1
	bcc.s	HsOff1
* Sprite FIXE
	clr.l	(a4)
	bra.s	HsOff2
* Sprite PATCHE!
HsOff1:	tst.l	(a4)
	beq.s	HsOff3
	move.w	(a4),d6
	move.w	HsNext(a4),d7
	clr.l	(a4)
	move.w	d7,2(a3,d6.w)
	beq.s	HsOff2
	move.w	d6,0(a3,d7.w)
HsOff2:	clr.w	HsX(a4)
	clr.w	HsY(a4)
	clr.l	HsImage(a4)
HsOff3:	movem.l	(sp)+,a3/a4/d6/d7
	moveq	#0,d0
	rts

***********************************************************
*	AFFICHAGE DES SPRITES HARDWARE
HsAff:	movem.l	d1-d7/a1-a6,-(sp)
	clr.l	T_HsChange(a5)
	move.l	GfxBase(pc),a6
	jsr	OwnBlitter(a6)		OwnBlitter
	lea	Circuits,a6

******* Cree la table position / Gestion des SPRITES DIRECTS!
	move.l	T_HsTable(a5),a4
	moveq	#7,d7
	move.w	T_HsTCol(a5),d6
	ext.l	d6
	moveq	#0,d5
	lea	T_HsPosition(a5),a3
	move.l	T_HsLogic(a5),a2

* Si SOURIS empeche le 1er!
	tst.w	T_MouShow(a5)
	bmi.s	HsAd0
	clr.l	(a3)+
	addq.l	#4,a3
	bra.s	HsAd6

* Teste les 8 1ers sprites
HsAd0:	tst.w	(a4)
	bne.s	HsAd1
	move.l	a2,(a3)+
	clr.l	(a3)+
	clr.l	(a2)			* RAZ colonne
	addq.w	#1,d5
HsAd6:	add.l	d6,a2
	lea	HsLong(a4),a4
	dbra	d7,HsAd0
	bra	HsAd7
*******	SPRITE DIRECT!
HsAd1:	move.l	HsControl(a4),d3
	tst.w	2(a4)
	beq	HsAdP
	subq.w	#1,2(a4)
	move.l	HsImage(a4),a1
	move.w	(a1),d1
	move.w	2(a1),d2
	move.w	d1,d4
	cmp.w	#4,4(a1)
	bcc.s	HsAd3
	lea	10(a1),a1
* Affiche le sprite MONOCOULEUR
HsAd2:	clr.l	(a3)+
	addq.l	#4,a3
	move.l	a2,a0
	move.l	d3,(a0)+
	move.l	a1,-(sp)
	bsr	HsBlit
	clr.l	(a0)
	move.l	(sp)+,a1
	subq.w	#1,d4
	beq.s	HsAd6
	addq.l	#2,a1
	add.l	d6,a2
	add.l	#$00080000,d3
	lea	HsLong(a4),a4
	dbra	d7,HsAd2
	bra	HsAd7
* Sprite MULTICOLOR
HsAd3:	lea	10(a1),a1
	btst	#0,d7			* Si IMPAIR, colonne vide!
	bne.s	HsAd4
	clr.l	(a3)+
	addq.l	#4,a3
	clr.l	(a2)
	add.l	d6,a2
	lea	HsLong(a4),a4
	subq.w	#1,d7
	bmi	HsAd7
HsAd4:	clr.l	(a3)+
	addq.l	#4,a3
	lea	HsLong(a4),a4
	subq.w	#1,d7
	move.l	a2,a0
	move.l	d3,(a0)+
	move.l	a1,-(sp)
	bsr	HsBlit
	clr.l	(a0)
	clr.l	(a3)+
	addq.l	#4,a3
	add.l	d6,a2
	move.l	a2,a0
	bset	#7,d3
	move.l	d3,(a0)+
	bclr	#7,d3
	bsr	HsBlit
	clr.l	(a0)
	move.l	(sp)+,a1
	subq.w	#1,d4
	beq	HsAd6
	addq.l	#2,a1
	add.l	d6,a2
	add.l	#$00080000,d3
	lea	HsLong(a4),a4
	dbra	d7,HsAd4
	bra.s	HsAd7
* Pas de recopie!
HsAdP:	move.l	HsImage(a4),a1
	move.w	(a1),d1
	cmp.w	#4,4(a1)
	bcc.s	HsAdP2
HsAdP1:	clr.l	(a3)+			* 4 couleurs
	addq.l	#4,a3
	move.l	d3,(a2)
	subq.w	#1,d1
	beq	HsAd6
	lea	HsLong(a4),a4
	add.l	d6,a2
	add.l	#$00080000,d3
	dbra	d7,HsAdP1
	bra.s	HsAd7
HsAdP2:	btst	#0,d7			* 16 couleurs
	bne	HsAdP3
	clr.l	(a3)+
	addq.l	#4,a3
	clr.l	(a2)
	add.l	d6,a2
	lea	HsLong(a4),a4
	subq.w	#1,d7
	bmi.s	HsAd7
HsAdP3:	clr.l	(a3)+
	addq.l	#4,a3
	move.l	d3,(a2)
	add.l	d6,a2
	lea	HsLong(a4),a4
	subq.w	#1,d7
	clr.l	(a3)+
	addq.l	#4,a3
	bset	#7,d3
	move.l	d3,(a2)
	bclr	#7,d3
	subq.w	#1,d1
	beq	HsAd6
	lea	HsLong(a4),a4
	add.l	d6,a2
	add.l	#$00080000,d3
	dbra	d7,HsAdP3

******* FINI! Marque la fin des colonnes
HsAd7:	move.l	#-1,(a3)
* Encore des colonnes?
	tst.w	d5
	beq	HsAFini

******* 1er sprite
	move.l	T_HsTable(a5),a4
	moveq	#-4,d4
******* Boucle d'affichage
HsA3:	lea	T_HsPosition-8(a5),a3	* Passe a la colonne suivante
HsA4:	lea	8(a3),a3
HsA4a:	tst.l	(a3)
	bmi.s	HsA3
	beq.s	HsA4
HsA5:	move.w	HsNext(a4,d4.w),d4	* Prend le sprite
	beq	HsAFini
	move.l	HsImage(a4,d4.w),a2
	lea	10(a2),a1
	move.w	(a2),d5
	move.l	HsControl(a4,d4.w),d3
	moveq	#8,d6
	move.w	2(a2),d2
	addq.w	#1,d2
	cmp.w	#4,4(a2)
	bcc	HsMAff
HsA6:	move.w	HsYR(a4,d4.w),d0
	cmp.w	HsYAct(a3),d0
	bcs.s	HsA10
	move.w	HsPAct(a3),d1
	add.w	d2,d1
	cmp.w	T_HsPMax(a5),d1
	bcc.s	HsA10
* Peut recopier dans cette colonne!
	add.w	d2,d0
	move.w	d0,HsYAct(a3)
	move.w	HsPAct(a3),d0
	move.w	d1,HsPAct(a3)
	lsl.w	#2,d0
	move.l	(a3),a0
	add.w	d0,a0
	move.l	d3,(a0)+
	move.w	(a2),d1
	subq.w	#1,d2
	move.l	a1,-(sp)
	bsr	HsBlit
	clr.l	(a0)
	move.l	(sp)+,a1
	subq.w	#1,d5			* Encore un plan?
	beq.s	HsA4
	addq.w	#1,d2
	addq.l	#2,a1
	moveq	#8,d6
	add.l	#$00080000,d3		* Decale le sprite a droite
	bra.s	HsA11
* Passe a la colonne suivante!
HsA10:	subq.w	#1,d6			* Arret apres 8 essais negatifs
	beq	HsA4a
HsA11:	lea	8(a3),a3
HsA12:	tst.l	(a3)
	beq.s	HsA10
	bpl.s	HsA6
	lea	T_HsPosition(a5),a3
	bra.s	HsA12

******* Affichage sprite multicolors
HsMAff:	moveq	#4,d6
	lea	T_HsPosition(a5),a0	* Situe a colonne PAIRE
	move.l	a3,d0
	sub.l	a0,d0
	btst	#3,d0
	beq.s	HsMA1
	lea	8(a3),a3
	bra	HsMA7
HsMA1:	move.w	HsYR(a4,d4.w),d0	* 2ieme colonne
	cmp.w	HsYAct+8(a3),d0
	bcs.s	HsMA5
	move.w	HsPAct+8(a3),d7
	add.w	d2,d7
	cmp.w	T_HsPMax(a5),d7
	bcc.s	HsMA5
	cmp.w	HsYAct(a3),d0		* 1ere colonne
	bcs.s	HsMA5
	move.w	HsPAct(a3),d1
	add.w	d2,d1
	cmp.w	T_HsPMax(a5),d1
	bcc.s	HsMA5
* Recopie dans la 1ere colonne
	add.w	d2,d0
	move.w	d0,HsYAct(a3)
	move.w	d0,HsYAct+8(a3)
	move.w	HsPAct(a3),d0
	move.w	d1,HsPAct(a3)
	move.w	d7,HsPAct+8(a3)
	lsl.w	#2,d0
	move.w	d0,d7
	move.l	(a3),a0
	add.w	d0,a0
	move.l	d3,(a0)+
	move.w	(a2),d1
	subq.w	#1,d2
	move.l	a1,-(sp)
	bsr	HsBlit
	clr.l	(a0)
* Recopie dans la 2ieme colonne
	move.l	8(a3),a0
	add.w	d7,a0
	bset	#7,d3
	move.l	d3,(a0)+
	bsr	HsBlit
	clr.l	(a0)
* Encore un plan?
	move.l	(sp)+,a1
	subq.w	#1,d5			* Encore un plan?
	beq.s	HsMA2
	bclr	#7,d3
	addq.w	#1,d2
	addq.l	#2,a1
	moveq	#4,d6
	add.l	#$00080000,d3		* Decale le sprite a droite
	bra.s	HsMA1
* Saute les 2 colonnes
HsMA2:	lea	8(a3),a3
	bra	HsA4
* Passe a la colonne suivante!
HsMA5:	subq.w	#1,d6			* Arret apres 8 essais negatifs
	beq	HsA4a
HsMA6:	lea	8*2(a3),a3
HsMA7:	tst.l	(a3)
	beq.s	HsMA5
	bmi.s	HsMA8
	tst.l	8(a3)
	bne	HsMA1
	beq.s	HsMA6
HsMA8:	lea	T_HsPosition(a5),a3
	bra	HsMA7

******* FINI
HsAFini	tst.w	T_CopON(a5)			* Copper en route???
	beq	HsAf1
	move.w	T_MouShow(a5),d3
	move.w	#-1,T_MouShow(a5)
	move.l	T_HsPhysic(a5),d0
	move.l	T_HsLogic(a5),d1
	move.l	T_HsInter(a5),d2
	move.l	d1,T_HsPhysic(a5)
	move.l	d2,T_HsLogic(a5)
	move.l	d0,T_HsInter(a5)
	move.l	d1,T_HsChange(a5)
	move.w	d3,T_MouShow(a5)

******* Remet le blitter
HsAf1:	bsr	BlitWait
	move.l	GfxBase(pc),a6
	jsr	DisownBlitter(a6)

******* Retour
HsAffX:	movem.l	(sp)+,d1-d7/a1-a6
	rts

******* Recopie par blitter A1->A0 / BitMap->HSprite
*	A0= Destination
*	A1= Source
*	D1= Tx (mots)
*	D2= Ty
HsBlit:	bsr	BlitWait
	move.w	#%0000001110101010,BltCon0(a6)
	clr.w	BltCon1(a6)
	move.w	d1,d0
	subq.w	#1,d0
	lsl.w	#1,d0
	move.w	d0,BltModC(a6)
	move.w	#2,BltModD(a6)
	move.w	d2,d0
	lsl.w	#6,d0
	or.w	#1,d0
	move.w	d1,-(sp)
	lsl.w	#1,d1
	mulu	d2,d1
	move.w	#$8040,DmaCon(a6)
	move.l	a1,BltAdC(a6)
	move.l	a0,BltAdD(a6)
	move.w	d0,BltSize(a6)
	add.l	d1,a1
	lea	2(a0),a0
HsBl2:	bsr	BlitWait
	move.l	a1,BltAdC(a6)
	move.l	a0,BltAdD(a6)
	move.w	d0,BltSize(a6)
	add.l	d1,a1
	move.w	(sp)+,d1
	move.w	d2,d0
	lsl.w	#2,d0
	lea	-2(a0,d0.w),a0
	rts


;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* BLOCS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
	IFEQ	EZFlag
******* FABRIQUE UN BLOC COMPRESSE
*	D1= X
*	D2= Y
*	D3= TX
*	D4= TY
CBloc:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	moveq	#0,d0
	lsr.w	#3,d1
	lsr.w	#3,d3
	move.w	d1,d0
	add.w	d3,d0
	cmp.w	EcTLigne(a4),d0
	bhi	CBlE3
	move.w	d2,d0
	add.w	d4,d0
	mulu	EcTLigne(a4),d0
	cmp.l	EcTPlan(a4),d0
	bhi	CBlE3
	mulu	EcTLigne(a4),d2
	ext.l	d1
	add.w	d1,d2
	subq.w	#1,d4
	lea	EcCurrent(a4),a0
 	move.w	EcNPlan(a4),d0
	subq.w	#1,d0
	sub.l	a3,a3

CBl1:	move.l	a0,a1
	move.w	d0,d1
CBl2:	move.l	(a1)+,a2
	add.l	d2,a2
	move.w	d3,d5
CBl3:	moveq	#0,d7
	move.b	(a2)+,d6
CBl4:	subq.w	#1,d5
	beq.s	CBl5
	cmp.b	(a2),d6
	bne.s	CBl5
	addq.l	#1,a2
	addq.w	#1,d7
	cmp.w	#64,d7
	bcs.s	CBl4
	subq.w	#1,d7
CBl5:	tst.w	d7
	bne.s	CBl7
	cmp.b	#%11000000,d6
	bcs.s	CBl6
	addq.l	#1,a3
CBl6:	addq.l	#1,a3
	tst.w	d5
	bne.s	CBl3
	bra.s	CBl8
CBl7:	addq.l	#2,a3
	tst.w	d5
	bne.s	CBl3
CBl8:	dbra	d1,CBl2
	add.w	EcTLigne(a4),d2
	dbra	d4,CBl1

* Demande la memoire necessaire
	lea	20+16(a3),a3
	move.l	a3,d0
	and.l	#$FFFFFFF8,d0
	move.l	d0,a3
	bsr	FastMm
	beq	CBlE1
	move.l	a3,a0

* Fabrique rellement le bloc!
	movem.l	(sp)+,d1-d7/a1-a6
	move.l	d0,a1			* Adresse de debut!
	movem.l	d1-d7/a1-a6,-(sp)

	move.l	d0,a3
	move.l	T_EcCourant(a5),a4
	clr.l	(a3)+			* Pointeur sur le precedent
	clr.l	(a3)+			* Pointeur sur le suivant
	move.l	a0,(a3)+		* Longueur utilisee
	clr.w	(a3)+			* Numero du bloc
	move.w	d1,(a3)+		* X/8
	move.w	d2,(a3)+		* Y
	lsr.w	#3,d1
	lsr.w	#3,d3
	move.w	d3,(a3)+		* TX/8
	move.w	d4,(a3)+		* TY
	mulu	EcTLigne(a4),d2
	ext.l	d1
	add.l	d1,d2
	subq.w	#1,d4
	lea	EcCurrent(a4),a0
	move.w	EcNPlan(a4),d0
	move.w	d0,(a3)+		* NbPlans
	subq.w	#1,d0

GBl1:	move.l	a0,a1
	move.w	d0,d1
GBl2:	move.l	(a1)+,a2
	add.l	d2,a2
	move.w	d3,d5
GBl3:	moveq	#0,d7
	move.b	(a2)+,d6
GBl4:	subq.w	#1,d5
	beq.s	GBl5
	cmp.b	(a2),d6
	bne.s	GBl5
	addq.l	#1,a2
	addq.w	#1,d7
	cmp.w	#64,d7
	bcs.s	GBl4
	subq.w	#1,d7
GBl5:	tst.w	d7
	bne.s	GBl7
	cmp.b	#%11000000,d6
	bcs.s	GBl6
	move.b	#%11000000,(a3)+
GBl6:	move.b	d6,(a3)+
	tst.w	d5
	bne.s	GBl3
	beq.s	GBl8
GBl7:	or.b	#%11000000,d7
	move.b	d7,(a3)+
	move.b	d6,(a3)+
	tst.w	d5
	bne.s	GBl3

GBl8:	dbra	d1,GBl2
	add.w	EcTLigne(a4),d2
	dbra	d4,GBl1

	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#0,d0
	rts

******* RESTORE UN BLOC COMPRESSE
*	A1= Adresse bloc
*	D1= X (ou -1)
*	D2= Y (ou -1)
PBloc:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	lea	14(a1),a3
	tst.w	d1
	bpl.s	PBl1
	move.w	(a3),d1
PBl1:	tst.w	d2
	bpl.s	PBl2
	move.w	2(a3),d2
PBl2:	addq.l	#4,a3
	move.w	(a3)+,d3
	move.w	(a3)+,d4
	lsr.w	#3,d1
* Verifie que ca ne sorte pas
	moveq	#0,d0
	move.w	d1,d0
	add.w	d3,d0
	cmp.w	EcTLigne(a4),d0
	bhi	CBlE3
	move.w	d2,d0
	add.w	d4,d0
	mulu	EcTLigne(a4),d0
	cmp.l	EcTPlan(a4),d0
	bhi	CBlE3
	mulu	EcTLigne(a4),d2
	ext.l	d1
	add.l	d1,d2
	subq.w	#1,d3
	subq.w	#1,d4
	lea	EcCurrent(a4),a0
	move.w	(a3)+,d0
	cmp.w	EcNPlan(a4),d0
	bls.s	PBl3
	move.w	EcNPlan(a4),d0
PBl3:	subq.w	#1,d0

* Decompacte!
PBl4:	move.l	a0,a1
	move.w	d0,d1
PBl5:	move.l	(a1)+,a2
	add.l	d2,a2
	move.w	d3,d5
PBl6:	move.b	(a3)+,d6
	cmp.b	#%11000000,d6
	bcc.s	PBl7
	move.b	d6,(a2)+
	dbra	d5,PBl6
	bra.s	PBl9
PBl7:	and.w	#%00111111,d6
	sub.w	d6,d5
	move.b	(a3)+,d7
PBl8:	move.b	d7,(a2)+
	dbra	d6,PBl8
	subq.w	#1,d5
	bpl.s	PBl6
PBl9:	dbra	d1,PBl5
	add.w	EcTLigne(a4),d2
	dbra	d4,PBl4

	movem.l	(sp)+,d1-d7/a1-a6
	moveq	#0,d0
	rts
	ENDC

******* Erreurs
BlE:	equ 	19
* Out of mem, general!
CBlE1:	moveq	#1,d0
	bra.s	CBlEm
* Erreurs blocs
CBlE3:	moveq	#BlE+3,d0
CBlEm:	movem.l	(sp)+,d1-d7/a1-a6
	tst.l	d0
	rts
CBlE2:	moveq	#BlE+2,d0
	rts

	IFEQ	EZFlag
***********************************************************
*	FABRIQUE UN BLOC
*	D1/D2/D3/D4 - D5= numero du bloc
***************************************
MakeCBloc:
	bsr	FindCBloc
	beq.s	MkCBl1
	bsr	FreeCBloc
MkCBl1:	bsr	CBloc
	bne.s	MkCBlX
* Incorpore le bloc dans la liste
	move.w	d5,12(a1)
	move.l	T_AdCBlocs(a5),a0
	cmp.l	#0,a0
	beq.s	MkCBl2
	move.l	a1,0(a0)		* 2ieme---> nouveau
MkCBl2:	move.l	a0,4(a1)		* Nouveau---> 2ieme
	move.l	a1,T_AdCBlocs(a5)	* 1ier bloc
MkCBlX:	tst.w	d0
	rts

***********************************************************
*	DESSINE UN BLOC
*	D1/D2 - D5= numero du bloc
***************************************
DrawCBloc:
	bsr	FindCBloc
	beq.s	CBlE2
	bra	PBloc

***********************************************************
*	EFFACE LE BLOC D5
**************************
FreeCBloc:
	bsr	FindCBloc
	beq.s	CBlE2
*******	LIBERE LE BLOC A1
FrCBloc:
* Enleve le bloc de la liste
	cmp.l	T_AdCBlocs(a5),a1
	bne.s	FrCBl0
	move.l	4(a1),T_AdCBlocs(a5)
FrCBl0:	tst.l	(a1)
	beq.s	FrCBl1
	move.l	(a1),a0
	move.l	4(a1),4(a0)
FrCBl1:	tst.l	4(a1)
	beq.s	FrCBl2
	move.l	4(a1),a0
	move.l	(a1),(a0)
FrCBl2:
* Libere la memoire
	move.l	8(a1),d0
	bsr	FreeMm
	moveq	#0,d0
	rts

***********************************************************
*	EFFACE TOUS LES BLOCS
******************************
RazCBloc:
	move.l	T_AdCBlocs(a5),d0
	beq.s	RzCblX
	move.l	d0,a1
	bsr	FrCBloc
	bra.s	RazCBloc
RzCBlX:	moveq	#0,d0
	rts

******* TROUVE UN BLOC D5 DANS LA LISTE
*	BNE---> trouve	/  a1=adresse
FindCBloc:
	move.l	T_AdCBlocs(a5),d0
	beq.s	FnCBl1
FnCBl0:	move.l	d0,a1
	cmp.w	12(a1),d5
	beq.s	FnCBl2
	move.l	4(a1),d0
	bne.s	FnCBl0
FnCBl1:	moveq	#0,d0
	rts
FnCBl2:	moveq	#1,d0
	rts
	ENDC


;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* BLOCS NON COMPRESSE
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

******* Description d'un bloc
	RsReset
BlPrev:	rs.l 	1
BlNext:	rs.l 	1
BlNb:	rs.w	1
BlX:	rs.w 	1
BlY:	rs.w	1
BlMask:	rs.w	1
BlCon:	rs.w	1
BlAPlan	rs.w 	1
BlDesc:	rs.l 	2
BlLong:	equ	__Rs

***********************************************************
*	FABRIQUE UN BLOC, ECRAN COURANT
*	D1- 	Numero du bloc
*	D2/D3/D4/D5
*	D6-	Flag Masque
***************************************
MakeBloc:
	movem.l	a2-a6/d2-d7,-(sp)
	moveq	#0,d7
	move.w	d6,d7
* Verifie les parametres
	move.l	T_EcCourant(a5),a0
	tst.w	d2
	bmi	BlE3
	tst.w	d3
	bmi	BlE3
	tst.w	d4
	ble	BlE3
	tst.w	d5
	ble	BlE3
	move.w	d5,d6
	add.w	d3,d6
	cmp.w	EcTy(a0),d6
	bhi	BlE3
	move.w	d4,d6
	add.w	d2,d6
	cmp.w	EcTx(a0),d6
	bhi	BlE3
* Reserve l'espace pour les datas
	bsr	FindBloc
	bne.s	MkBl1
	moveq	#BlLong,d0
	bsr	FastMm
	beq.s	BlE1
	move.l	d0,a1
	bset	#31,d7
* Met les parametres
MkBl1:	move.w	d1,BlNb(a1)
	clr.w	BlCon(a1)
	move.w	#$FFFF,BlAPlan(a1)
	move.w	d2,BlX(a1)
	move.w	d3,BlY(a1)
* Prend l'image
	exg	a0,a1
	lea	BlDesc(a0),a2
	bsr	GetBob
	move.l	a0,a1
	tst.w	d0
	bne.s	MkBl3
* Fabrique le masque?
	move.l	#$C0000000,4(a2)
	tst.w	d7
	beq.s	MkBlM
	bsr	Masque
* Incorpore le bloc dans la liste
MkBlM:	btst	#31,d7
	beq.s	MkBlX
	lea	T_AdBlocs(a5),a2
	move.l	(a2),d0
	beq.s	MkBl2
	move.l	d0,a0
	move.l	a1,BlPrev(a0)
MkBl2:	move.l	d0,BlNext(a1)
	move.l	a1,(a2)
MkBlX:	moveq	#0,d0
BlOut	movem.l	(sp)+,a2-a6/d2-d7
	rts

******* Erreurs
BlE2:	moveq	#BlE+2,d0		* Not found
	bra.s	BlOut
BlE3:	moveq	#BlE+3,d0		* Foncall
	bra.s	BlOut
MkBl3:	bsr	FrBloc			* Out of mem
BlE1:	moveq	#1,d0
	bra.s	BlOut

***********************************************************
*	EFFACE LE BLOC D1
**************************
DelBloc:
	bsr	FindBloc
	bne.s	FrBloc
	moveq	#BlE+2,d0
	rts
*******	LIBERE LE BLOC A1
FrBloc:	movem.l	a2-a6/d2-d7,-(sp)
	move.l	a1,a2
* Enleve le dessin
	move.l	BlDesc(a2),d0
	beq.s	FrBl1
	move.l	d0,a1
	move.w	(a1),d0
	mulu	2(a1),d0
	mulu	4(a1),d0
	addq.l	#5,d0
	lsl.l	#1,d0
	bsr	FreeMm
* Enleve le masque
FrBl1:	move.l	BlDesc+4(a2),d0
	ble.s	FrBl2
	move.l	d0,a1
	move.l	(a1),d0
	bsr	FreeMm
* Enleve le bloc de la liste
FrBl2:	move.l	a2,a1
	lea	T_AdBlocs(a5),a2
	cmp.l	(a2),a1
	bne.s	FrBl3
	move.l	BlNext(a1),(a2)
FrBl3:	tst.l	BlPrev(a1)
	beq.s	FrBl4
	move.l	BlPrev(a1),a0
	move.l	BlNext(a1),BlNext(a0)
FrBl4:	tst.l	BlNext(a1)
	beq.s	FrBl5
	move.l	BlNext(a1),a0
	move.l	BlPrev(a1),BlPrev(a0)
FrBl5:	moveq	#BlLong,d0
	bsr	FreeMm
	moveq	#0,d0
	bra	BlOut

***********************************************************
*	EFFACE TOUS LES BLOCS
******************************
RazBloc	lea	T_AdBlocs(a5),a0
	move.l	(a0),d0
	beq.s	RzBlX
	move.l	d0,a1
	bsr	FrBloc
	bra.s	RazBloc
RzBlX:	moveq	#0,d0
	rts

***********************************************************
*	DESSINE UN BLOC
*	D1-	Numero du bloc
*	D2/D3-	Coordonnees
*	D4-	Plans
*	D5-	Minterm
*	A1-	Buffer de calcul
DrawBloc:
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a1,a4
	bsr	FindBloc
	bne.s	DrBl0
BlNDef	moveq	#2,d0
	bra	BlOut
* Parametres de l'ecran courant
DrBl0:	move.l	T_EcCourant(a5),a0
	move.w	EcClipX0(a0),d0
	and.w	#$FFF0,d0
	move.w	d0,BbLimG(a4)
	move.w	EcClipY0(a0),BbLimH(a4)
	move.w	EcClipX1(a0),d0
	add.w	#15,d0
	and.w	#$FFF0,d0
	move.w	d0,BbLimD(a4)
	move.w	EcClipY1(a0),BbLimB(a4)
* Parametres du bob
	move.l	#EntNul,d7
	cmp.l	d2,d7
	bne.s	DrBl1
	move.w	BlX(a1),d2
DrBl1:	cmp.l	d3,d7
	bne.s	DrBl2
	move.w	BlY(a1),d3
DrBl2:	move.w	BlAPlan(a1),BbAPlan(a4)
	cmp.l	d4,d7
	beq.s	DrBl3
	move.w	d4,BbAPlan(a4)
DrBl3:	move.w	BlCon(a1),BbACon(a4)
	cmp.l	d5,d7
	beq.s	DrBl4
	and.w	#$00FF,d5
	bset	#15,d5
	move.w	d5,BbACon(a4)
DrBl4:	move.l	a0,BbEc(a4)
	move.w	d3,d1
	moveq	#-1,d3
	lea	BlDesc(a1),a2
	bsr	BobCalc
	bne.s	DBlOut
* Appelle la routine d'affichage
	lea	Circuits,a6
	bsr	OwnBlit
	move.w	BbASize(a4),d2
	move.w	BbTPlan(a4),d4
	ext.l	d4
	move.l	BbAData(a4),a0
	move.l	BbEc(a4),a3
	lea	EcCurrent(a3),a3
	move.w	BbAModD(a4),d0
	move.w	d0,BltModC(a6)
	move.w	d0,BltModD(a6)
	move.l	BbADraw(a4),a1
	move.l	BbAMask(a4),d5
	jsr	(a1)
* FINI: remet le blitter
	bsr	BlitWait
	bsr	DOwnBlit
DBlOut:	moveq	#0,d0
	bra	BlOut

******* Retourne un bloc
*	D1->	Numero bloc
*	D2-> 	Bit 0 => X / Bit 1 => Y
RevBloc	movem.l	d2-d7/a2-a6,-(sp)
	bsr	FindBloc
	beq	BlNDef
	lea	BlDesc(a1),a0
	move.l	(a0),a1
	and.w	#$3FFF,6(a1)
	move.w	d2,d0
	bsr	Retourne
	moveq	#0,d0
	bra	BlOut

******* TROUVE UN BLOC D1 DANS LA LISTE
*	BNE---> trouve	/  a1=adresse
FindBloc:
	lea	T_AdBlocs(a5),a1
	move.l	(a1),d0
	beq.s	FnBl1
FnBl0:	move.l	d0,a1
	cmp.w	BlNb(a1),d1
	beq.s	FnBl2
	move.l	BlNext(a1),d0
	bne.s	FnBl0
FnBl1:	moveq	#0,d0
	rts
FnBl2:	moveq	#1,d0
	rts

;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* TRAPPE FENETRES
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------


; OPEN CONSOLE.DEVICE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OpConsole
	lea	ConIo(pc),a1
	moveq	#(Lio+Lmsg)/2-1,d0
.Clean	clr.w	(a1)+
	dbra	d0,.Clean
	move.l	$4.w,a6
	lea	ConName(pc),a0
	lea	ConIo(pc),a1
	moveq	#-1,d0			Console #= -1
	moveq	#0,d1
	jsr	OpenDev(a6)
	rts

; OPEN INPUT.DEVICE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1-> 	pointeur sur zone libre!!!
OpInput
	move.l	a1,-(sp)
* Clean
	moveq	#(Lio+Lmsg)/2-1,d0
OpInp1	clr.w	(a1)+
	dbra	d0,OpInp1
* Creates port
	sub.l	a1,a1
	move.l	$4.w,a6
	jsr	FindTask(a6)
	move.l	(sp),a1
	lea	Lio(a1),a1
	move.l	d0,$10(a1)
	jsr	AddPort(a6)
* Open device
	lea	DevName(pc),a0
	move.l	(sp),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	OpenDev(a6)
	move.l	(sp)+,a1
	lea	Lio(a1),a0
	move.l	a0,14(a1)
	rts

; CLOSE input.device
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClInput	move.l	a1,-(sp)
; Close device
	move.l	$4.w,a6
	jsr	CloseDev(a6)
; Close port
	move.l	(sp)+,a1
	lea	Lio(a1),a1
	jsr	RemPort(a6)
	rts

; Input handler, branche sur la chaine des inputs.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IoHandler
	move.l	a5,-(sp)
	move.l	W_Base(pc),a5
; Si inhibe, laisse TOUT passer!
	tst.w	T_Inhibit(a5)
	bne.s	I_Inhibit
; Continue...
	move.b	T_AMOSHere(a5),d4		Si AMOS pas la,
	ext.w	d4
	bne.s	.Skip
	bset	#WFlag_Event,T_WFlags(a5)	Marque des faux events!
.Skip	move.l	a0,d0
	move.l	a0,d2
	moveq	#0,d3
IeLoop	move.b	Ie_Class(a0),d1
	cmp.b	#IeClass_RawMouse,d1
	beq.s	IeMous
	cmp.b	#IeClass_Rawkey,d1
	beq	IeKey
	cmp.b	#IeClass_DiskInserted,d1
	beq.s	IeDIn
	cmp.b	#IeClass_DiskRemoved,d1
	beq.s	IeDOut
IeLp1	move.l	d2,d3
	move.l	(a0),d2
IeLp2	move.l	d2,a0
	bne.s	IeLoop
IeLpX	move.l	(sp)+,a5
	rts
I_Inhibit
	move.l	(sp)+,a5
	move.l	a0,d0
	rts
; Disc inserted
IeDIn	bset	#WFlag_Event,T_WFlags(a5)
	move.w	#-1,T_DiscIn(a5)
	bra.s	IeLp1
; Disc removed
IeDOut	bset	#WFlag_Event,T_WFlags(a5)
	clr.w	T_DiscIn(a5)
	bra.s	IeLp1
; Evenement Mouse, fait le mouvement!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IeMous	tst.w	d4
	beq.s	IeLp1
	bset	#WFlag_Event,T_WFlags(a5)		Flag: un event!
	cmp.l	#Fake_Code,ie_X(a0)	Un faux evenement?
	beq.s	IeFake
IeNof	move.w	T_MouYOld(a5),d1	* Devenir des MOUSERAW
	and.w	#$0003,d1		* 0-> Normal
	beq.s	.norm			* 1-> Trash
	subq.w	#2,d1			* 2-> Tout passe
	bmi.s	IeTrash			* 3-> Mouvements seuls
	beq.s	IeLp1
; Mode key only>>> prend les touches, laisse passer les mouvements
	move.w	ie_Qualifier(a0),T_MouXOld(a5)
	and.w	#%1000111111111111,ie_Qualifier(a0)
	move.w	ie_Code(a0),d1
	and.w	#$7f,d1
	cmp.w	#IECODE_LBUTTON,d1
	beq.s	.ski1
	cmp.w	#IECODE_RBUTTON,d1
	bne.s	IeLp1
.ski1	move.w	#IECODE_NOBUTTON,ie_Code(a0)
	bra.s	IeLp1
; Mode normal>>> prend et met a la poubelle
.norm	move.w	ie_Qualifier(a0),d1
	move.w	d1,T_MouXOld(a5)
	btst	#IEQUALIFIERB_RELATIVEMOUSE,d1
	beq.s	IeTrash
	move.w	ie_X(a0),d1
	add.w	d1,T_MouseX(a5)
	move.w	ie_Y(a0),d1
	add.w	d1,T_MouseY(a5)
; Event to trash!
IeTrash	tst.l	d3
	beq.s	IeTr1
	move.l	d3,a1
	move.l	(a0),d2
	move.l	d2,(a1)
	bra	IeLp2
IeTr1	move.l	(a0),d0
	move.l	d0,a0
	bne	IeLoop
	move.l	(sp)+,a5
	rts
; Faux evenement clavier...
; ~~~~~~~~~~~~~~~~~~~~~~~~~
IeFake	cmp.w	#IEQUALIFIER_RELATIVEMOUSE,ie_Qualifier(a0)
	bne	IeNof
	clr.l	ie_X(a0)			Plus de decalage
	bra	IeLp1				On laisse passer
; Event clavier: prend le caractere au vol
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IeKey	bset	#WFlag_Event,T_WFlags(a5)
	bsr	Cla_Event
	bne.s	.IeKy1
.IeKy0	tst.w	d4		Event to trash ou non
	bne.s	IeTrash
	bra	IeLp1
; AMIGA-A pressed
; ~~~~~~~~~~~~~~~
.IeKy1	tst.w	T_NoFlip(a5)
	bne.s	.IeKy0
	btst	#WFlag_LoadView,T_WFlags(a5)
	bne.s	.AA
; Appel de TAMOSWb, rapide...
	movem.l	a0-a1/d0-d1,-(sp)
	moveq	#0,d1
	tst.w	d4
	bne.s	.Ska
	moveq	#1,d1
.Ska	bsr	TAMOSWb
	movem.l	(sp)+,a0-a1/d0-d1
	bra	IeTrash
; Marque pour TESTS CYCLIQUES
.AA	bset	#WFlag_AmigaA,T_WFlags(a5)
	bra	IeTrash

; 	Gestion des evenements clavier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	EVENT KEY
;	D4=	Flag AMOS / WB
Cla_Event
	movem.l	a0-a1/d0-d3,-(sp)
	move.w	Ie_Code(a0),d0
	bclr	#7,d0
	bne	.ClaI2
; Appui sur une touche
; ~~~~~~~~~~~~~~~~~~~~
	cmp.b	#$68,d0				Shifts>>> pas stockes
	bcc.s	.RawK
	cmp.b	#$40,d0
	bcs.s	.RawK
	cmp.b	#$60,d0
	bcc	.Cont
; Conversion a la main des codes speciaux
	lea	Cla_Special-$40(pc),a1
	move.b	0(a1,d0.w),d1
	bpl	.Rien
	cmp.b	#$FF,d1
	beq.s	.RawK
; Une touche de fonction AMOS?
	moveq	#0,d1				Ascii nul
	move.b	Ie_Qualifier+1(a0),d2		Les shifts
	btst	#6,d2
	beq.s	.FFk1
	lea	T_TFF1(a5),a1			Touches 1-10
	bra.s	.FFk2
.FFk1	btst	#7,d2				Pas AMIGA>>> Touche normale
	beq.s	.Rien
	lea	T_TFF2(a5),a1			Touches 11-20
.FFk2	move.w	d0,d2
	sub.w	#$50,d2
	mulu	#FFkLong,d2
	lea	0(a1,d2.w),a1
	tst.b	(a1)
	beq.s	.Rien
	bsr	ClPutK
	moveq	#0,d2
	bra	.ClaIX
; Appel de RAWKEYCONVERT et stockage si AMOS present
.RawK	move.b	Ie_Qualifier+1(a0),d2		Prend CONTROL
	and.b	#%11110111,Ie_Qualifier+1(a0)	Plus de CONTROL
	movem.l	a0/a2/a6,-(sp)
	lea	ConIo(pc),a6			Structure IO
	move.l	20(a6),a6			io_device
	lea	ConBuffer(pc),a1			Buffer de sortie
	sub.l	a2,a2				Current Keymap
	moveq	#LConBuffer,d1			Longueur du buffer
	jsr	-$30(a6)			RawKeyConvert
	move.w	d0,d3
	movem.l	(sp)+,a0/a2/a6
	move.b	d2,Ie_Qualifier+1(a0)		Remet CONTROL
	move.w	Ie_Code(a0),d0
	moveq	#0,d1
	subq.w	#1,d3
	bmi.s	.Rien
	lea	ConBuffer(pc),a1			Une seule touche
	move.b	(a1),d1
.Rien	move.b	Ie_Qualifier+1(a0),d2		Les shifts!
; Amiga-A?
.A	move.b	d2,d3
	and.b	T_AmigA_Shifts(a5),d3
	cmp.b	T_AmigA_Shifts(a5),d3
	bne.s	.AAA
	cmp.b	T_AmigA_Ascii1(a5),d1
	beq.s	.AA
	cmp.b	T_AmigA_Ascii2(a5),d1
	bne.s	.AAA
.AA	moveq	#-1,d2
	bra.s	.ClaI1
; AMOS Not here: stop!
.AAA	tst.w	d4
	beq.s	.Cont
; Est-ce un CONTROL-C?
	btst	#3,d2
	beq.s	.Sto
	cmp.b	#"C",d1
	beq.s	.C
	cmp.b	#"c",d1
	bne.s	.Sto
.C	bset	#BitControl,T_Actualise(a5)
	bra.s	.Cont
; Stocke dans le buffer
.Sto	bsr	Cla_Stocke			On stocke!
; Change la table
.Cont	moveq	#0,d2
.ClaI1	move.w	d0,d1
	and.w	#$0007,d0
	lsr.w	#3,d1
	lea	T_ClTable(a5),a0
	bset	d0,0(a0,d1.w)
.ClaIX	tst.w	d2
	movem.l	(sp)+,a0-a1/d0-d3
	rts
; Relachement d'une touche
; ~~~~~~~~~~~~~~~~~~~~~~~~
.ClaI2	move.w	d0,d1
	and.w	#$0007,d0
	lsr.w	#3,d1
	lea	T_ClTable(a5),a1
	bclr	d0,0(a1,d1.w)
.ClaIF	moveq	#0,d0
	movem.l	(sp)+,a0-a1/d0-d3
	rts

; Table des touches $40->$5f
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Cla_Special
	dc.b	$ff,$08,$09,$0d,$0d,$1b,$00,$00		$40>$47
	dc.b	$00,$00,$ff,$00,$1e,$1f,$1c,$1d		$48>$4f
	dc.b	$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe		$50>$57
	dc.b	$fe,$fe,$ff,$ff,$ff,$ff,$ff,$00		$58>$5f

; Stocke D0/D1/D2 dans le buffer clavier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0	Rawkey
;	D1	Ascii
;	D2	Shifts
Cla_Stocke
	movem.l	a0/d3,-(sp)
	lea	T_ClBuffer(a5),a0
	move.w	T_ClTete(a5),d3
	addq.w	#3,d3
	cmp.w	#ClLong,d3
	bcs.s	.ClS11
	clr.w	d3
.ClS11	cmp.w	T_ClQueue(a5),d3
	beq.s	.ClS12
	move.w	d3,T_ClTete(a5)
	move.b	d2,0(a0,d3.w)
	move.b	d0,1(a0,d3.w)
	move.b	d1,2(a0,d3.w)
.ClS12	move.b	d2,-4(a0)
	move.b	d0,-3(a0)
	move.b	d1,-1(a0)
.ClSFin	movem.l	(sp)+,a0/d3
	rts

; Envoi d'un faux event souris au systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WSend_FakeEvent
	movem.l	d0-d1/a1/a6,-(sp)
	lea	Fake_Event(pc),a0
	move.b	#IECLASS_RAWMOUSE,ie_Class(a0)
	clr.b	ie_SubClass(a0)
	move.w	#IECODE_NOBUTTON,ie_Code(a0)
	move.w	#IEQUALIFIER_RELATIVEMOUSE,ie_Qualifier(a0)
	move.l	#Fake_Code,ie_X(a0)
	lea	T_IoDevice(a5),a1
	move.l	a0,io_Data(a1)
	move.w	#IND_WRITEEVENT,io_Command(a1)
	move.l	#22,io_Length(a1)
	move.l	$4.w,a6
	jsr	_LVODoIO(a6)
	movem.l	(sp)+,d0-d1/a1/a6
	rts
Fake_Code	equ	$789A789A
; Faux evenement souris
Fake_Event	dc.l	0				0
		dc.b	IeClass_RawMouse		4
		dc.b	0				5
		dc.w	IECODE_NOBUTTON			6
		dc.w	0				8
		dc.w	0				10
		dc.w	0				12
		dc.l	0				14 Time Stamp
		dc.l	0				18   "    "

; Initialisation / Vide du buffer clavier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClInit
ClVide	move.w	T_ClTete(a5),T_ClQueue(a5)
	clr.b	T_ClFlag(a5)
	moveq	#0,d0
	rts

; KEY WAIT, retourne BNE si des touches en attente
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClKWait	moveq	#0,d0
	move.w	T_ClQueue(a5),d1
	cmp.w	T_ClTete(a5),d1
	rts

; INKEY: D1 haut: SHIFTS/SCANCODE - D1 bas: ASCII
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClInky	moveq	#0,d1
	move.w	T_ClQueue(a5),d2
	cmp.w	T_ClTete(a5),d2
	beq.s	Ink2
	lea	T_ClBuffer(a5),a0
	addq.w	#3,d2
	cmp.w	#ClLong,d2
	bcs.s	Ink1
	moveq	#0,d2
Ink1:	move.b	0(a0,d2.w),d1
	lsl.w	#8,d1
	move.b	1(a0,d2.w),d1
	swap	d1
	move.b	2(a0,d2.w),d1
	move.w	d2,T_ClQueue(a5)
Ink2:	moveq	#0,d0
	rts

; Change KEY MAP A1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClKeyM	rts

***********************************************************
*	Set key speed D1,d2
*	A1---> Buffer libre!!!
***********************************************************
TKSpeed	movem.l	a3-a6,-(sp)
	move.l	a1,-(sp)
	movem.l	d1/d2,-(sp)
	bsr	OpInput
	move.l	(sp),d0
	bsr	CalRep
	move.w	#IND_SETTHRESH,io_command(a1)
	move.l	$4.w,a6
	jsr	DoIO(a6)
	move.l	4(sp),d0
	move.l	8(sp),a1
	bsr	CalRep
	move.w	#IND_SETPERIOD,io_command(a1)
	move.l	$4.w,a6
	jsr	DoIO(a6)
	move.l	8(sp),a1
	bsr	ClInput
	lea	12(sp),sp
	movem.l	(sp)+,a3-a6
	moveq	#0,d0
	rts
CalRep	ext.l	d0
	divu	#50,d0
	move.w	d0,d1
	swap	d0
	ext.l	d0
	mulu	#20000,d0
	move.l	d1,$20(a1)		tv_secs
	move.l	d0,$24(a1)		tv_micro
	rts

; Get shifts
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClSh:	moveq	#0,d1
	move.b	T_ClShift(a5),d1
	moveq	#0,d0
	rts

; Instant key D1: 0=relache / -1= enfonce
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClInst:	and.w	#$7F,d1
	move.w	d1,d0
	and.w	#$0007,d0
	lsr.w	#3,d1
	lea	T_ClTable(a5),a0
	lea	0(a0,d1.w),a0
	moveq	#0,d1
	btst	d0,(a0)
	beq.s	Inst
	moveq	#-1,d1
Inst:	moveq	#0,d0
	rts

; PUT KEY: stocke la chaine (A1) dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClPutK:	move.l	a0,-(sp)
	movem.w	d0-d3,-(sp)
	lea	T_ClBuffer(a5),a0
ClPk0:	clr.b	d0
	clr.b	d1
	move.b	(a1)+,d2
	beq.s	ClPk4
	cmp.b	#"'",d2			* REM
	beq.s	ClPk5
	cmp.b	#1,d2			* ESC
	bne.s	ClPk1
	move.b	(a1)+,d0		* Puis SHF/SCAN/ASCI
	move.b	(a1)+,d1
	move.b	(a1)+,d2
; Stocke!
ClPk1:	move.w	T_ClTete(a5),d3
	addq.w	#3,d3
	cmp.w	#ClLong,d3
	bcs.s	ClPk2
	clr.w	d3
ClPk2:	cmp.w	T_ClQueue(a5),d3
	beq.s	ClPk4
	move.b	d0,0(a0,d3.w)
	move.b	d1,1(a0,d3.w)
	move.b	d2,2(a0,d3.w)
	move.w	d3,T_ClTete(a5)
ClPk3:	bra.s	ClPk0
ClPk5:	move.b	(a1)+,d2
	beq.s	ClPk4
	cmp.b	#"'",d2
	bne.s	ClPk5
	bra.s	ClPk0
ClPk4:	movem.w	(sp)+,d0-d3
	move.l	(sp)+,a0
	rts

; FUNC KEY: stocke la chaine (A1) en fonc D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClFFk:	movem.l	d1-d2,-(sp)
	lea	T_TFF1(a5),a0
	mulu	#FFkLong,d1
	add.w	d1,a0
	clr.w	d0
ClF1:	clr.b	(a0)
	move.b	(a1)+,d2
	beq.s	ClFx
	cmp.b	#1,d2
	beq.s	ClF2
	cmp.b	#"`",d2
	beq.s	ClF3
	addq.w	#1,d0
	cmp.w	#FFkLong-1,d0
	bcc.s	ClF1
	move.b	d2,(a0)+
	bra.s	ClF1
ClFx:	movem.l	(sp)+,d1-d2
	move.l	a1,a0
	moveq	#0,d0
	rts
ClF2:	addq.w	#4,d0
	addq.l	#3,a1
	cmp.w	#FFkLong-1,d0
	bcc.s	ClF1
	move.b	d2,(a0)+
	move.b	-3(a1),(a0)+
	move.b	-2(a1),(a0)+
	move.b	-1(a1),(a0)+
	bra.s	ClF1
ClF3:	addq.w	#2,d0
	cmp.w	#FFkLong-1,d0
	bcc.s	ClF1
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	bra.s	ClF1

; GET KEY: ramene la touche de fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClGFFk:	lea	T_TFF1(a5),a0
	move.w	d1,d0
	mulu	#FFkLong,d0
	add.w	d0,a0
	moveq	#0,d0
	rts

; RETOUR L'ETAT DU FLAG DISC
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TGetDisc
	move.w	T_DiscIn(a5),d0
	ext.l	d0
	rts

;	Gestion cyclique hors interruptions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WTest_Cyclique

; Verifie AMOS / WB si AA
; ~~~~~~~~~~~~~~~~~~~~~~~
	bclr	#WFlag_AmigaA,T_WFlags(a5)
	beq.s	.NoFlip
	moveq	#0,d1
	tst.b	T_AMOSHere(a5)
	bne.s	.Wb
	moveq	#1,d1
.Wb	bsr	TAMOSWb
.NoFlip
; Envoi des faux messages au WB, en cas de blanker
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a0
	cmp.w	#36,$14(a0)
	bcs.s	.Noev
	subq.w	#1,T_FakeEventCpt(a5)
	bpl.s	.Noev
	move.w	#50*2,T_FakeEventCpt(a5)
	tst.b	T_AMOSHere(a5)
	beq.s	.Noev
	bsr	WSend_FakeEvent
.Noev
; Verifie l'inhibition
; ~~~~~~~~~~~~~~~~~~~~
	move.l	T_MyTask(a5),a0
	move.l	10(a0),a0
	cmp.b	#"S",(a0)
	bne.s	.Skip
	bsr	AMOS_Stopped
.Skip	rts

;	Cet AMOS est inhibe par un premier!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_Stopped
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	a0,a4
; Fait revenir le WB / Stoppe les interrupts
	move.w	#-1,T_Inhibit(a5)
	moveq	#-1,d1
	bsr	TAMOSWb
	move.w	d1,d7
	moveq	#0,d1
	bsr	TAMOSWb
; Stoppe les interrupts
	bsr	Rem_VBL
; Arrete le son
	move.w	#$000F,$Dff096
; Change le "S"top en "W"
	move.b	#"W",(a4)
; Attend qu'il se retransforme en " "
.Wait	move.l	T_GfxBase(a5),a6
	jsr	-270(a6)
	cmp.b	#"W",(a4)
	beq.s	.Wait
; Ramene le programme..
	bsr	Add_VBL
	tst.w	d7
	beq.s	.Skip
	moveq	#1,d1
	bsr	TAMOSWb
.Skip	clr.w	T_Inhibit(a5)
	movem.l	(sp)+,a0-a6/d0-d7
	rts

***********************************************************
*	DEMARRAGE A FROID DES FENETRES
***********************************************************
WiInit:	lea	WiIn(pc),a0
	move.l	a0,T_WiVect(a5)
	rts

******* FONCTIONS FENETRES
WiIn:	bra	WOutC
	bra	WPrint
	bra	WCentre
	bra	WOpen
	bra	WLocate
	bra	WQWind
	bra	WDel
	bra	WSBor
	bra	WSTit
	bra	WAdr
	bra	WiMove
	bra	WiCls
	bra	WiSize
	bra	WiSCur
	bra	WiXYCu
	bra	WiXGr
	bra	WiYGr
	bra	WPrint2
	bra	WPrint3
	bra	WiXYWi

***********************************************************
*	ARRET FINAL DES FENETRES
***********************************************************
WiEnd:	rts

***********************************************************
*	Writing FENETRE, loin de la destination!!!
*	D1= 0/ Normal - 1/ Or - 2/ Xor - 3/ And - 4/ RIEN
*	D2= NORMAL - PAPER only - PEN only
***********************************************************
Writing:move.w	d1,d2
	and.w	#$07,d1
	cmp.w	#5,d1
	bcc.s	Wrt0
	bclr	#7,WiFlags(a5)
	lsl.w	#1,d1
	beq.s	Wrt1
	bset	#7,WiFlags(a5)
Wrt1:	lea	WrtTab(pc),a1
	move.w	0(a1,d1.w),d0
	lea	WMod1(pc),a0
	move.w	d0,(a0)
	lea	WMod2(pc),a0
	move.w	d0,(a0)
	lea	WMod3(pc),a0
	move.w	d0,(a0)
Wrt0:	move.w	d2,d1
	lsr.w	#3,d1
	and.w	#$03,d1
	cmp.w	#3,d1
	bcc.s	Wrt3
	lsl.w	#1,d1
	beq.s	Wrt2
	bset	#7,WiFlags(a5)
Wrt2:	lea	GetTab(pc),a1
	lea	WGet1(pc),a0
	move.w	0(a1,d1.w),(a0)
	lea	WGet2(pc),a0
	move.w	0(a1,d1.w),(a0)
Wrt3:	bsr	Sys_ClearCache
	moveq	#0,d0
	rts
WrtTab:	move.b	d0,(a4)
	or.b	d0,(a4)
	eor.b	d0,(a4)
	and.b	d0,(a4)
	nop
GetTab:	or.b	d1,d0
	nop
	move.w	d1,d0


***********************************************************
*	DECOR DES FENETRES

******* Fabrique le decor de la fenetre COURANTE!
WiStore	movem.l	d0-d7/a0-a5,-(sp)
	tst.w	EcWiDec(a4)
	beq	WiMdX
	move.l	EcWindow(a4),d0
	beq	WiMdX
	move.l	d0,a5

* Gestion memoire de sauvegarde
	move.w	WiTxR(a5),d1
	mulu	WiTyP(a5),d1
	mulu	EcNPlan(a4),d1
	tst.l	WiDBuf(a5)
	beq.s	WiMd0
	cmp.l	WiTBuf(a5),d1
	beq.s	WiMd1
* Efface!
	move.l	WiDBuf(a5),a1
	move.l	WiTBuf(a5),d0
	bsr	FreeMm
	clr.l	WiDBuf(a5)
	clr.l	WiTBuf(a5)
* Reserve!
WiMd0:	move.l	d1,d0
	bsr	FastMm
	beq.s	WiMdX
	move.l	d0,WiDBuf(a5)
	move.l	d1,WiTBuf(a5)
* Copie le contenu de l'ecran!
WiMd1:	move.l	WiDBuf(a5),a3
	move.w	WiDyR(a5),d0
	move.w	EcTLigne(a4),d1
	ext.l	d1
	mulu	d1,d0
	add.w	WiDxR(a5),d0
	move.w	WiTyP(a5),d2
	subq.w	#1,d2
	move.w	WiTxR(a5),d3
	move.w	d3,WiTxBuf(a5)
	subq.w	#1,d3
	move.w	WiNPlan(a5),d5
	lea	EcLogic(a4),a0
WiMd2:	move.w	d5,d6
	move.l	a0,a1
WiMd3:	move.l	(a1)+,a2
	add.l	d0,a2
	move.w	d3,d4
WiMd4:	move.b	(a2)+,(a3)+
	dbra	d4,WiMd4
	dbra	d6,WiMd3
	add.l	d1,d0
	dbra	d2,WiMd2
* Ca y est!
WiMdX:	movem.l	(sp)+,d0-d7/a0-a5
	rts

******* Entree EFFACEMENT pour WIND SIZE!
WiEff2:	movem.l	d0-d7/a0-a3,-(sp)
	tst.w	EcWiDec(a4)
	beq	WiEfX
	tst.l	WiDBuf(a5)
	beq	WiEfX
* Limite en X
	move.w	d6,d5
	cmp.w	WiTxR(a5),d5
	bls.s	WiEf2a
	move.w	WiTxR(a5),d5
* Limite en Y
WiEf2a:	cmp.w	WiTyP(a5),d7
	bls.s	WiEf2b
	move.w	WiTyP(a5),d7
* Limite en X
WiEf2b:	move.w	WiDxR(a5),d0
	move.w	d0,d2
	add.w	d5,d2
	move.w	WiDyR(a5),d1
	move.w	d1,d3
	add.w	d7,d3
* Bordure?
	tst.w	WiBord(a5)
	beq.s	WiEf2c
	addq.w	#1,d0
	addq.w	#8,d1
	subq.w	#1,d2
	subq.w	#8,d3
* Pousse!
WiEf2c:	move.w	d3,-(sp)
	move.w	d2,-(sp)
	move.w	d0,-(sp)
	moveq	#0,d4
	moveq	#0,d5
	ext.l	d6
	move.w	d1,d7
	bra	WiEf0

******* Efface la fenetre (A5) avec CLIP des fenetres DEVANT!
*	Avec D5= 1/0 Avec / Sans bordure
*	Entre Y=D6 et Y=D7 seulement!
WiEff:	movem.l	d0-d7/a0-a3,-(sp)
	tst.w	EcWiDec(a4)
	beq	WiEfX
	tst.l	WiDBuf(a5)
	beq	WiEfX

* Limites la zone en Y
	move.w	WiDyR(a5),d0
	move.w	WiFyR(a5),d1
	cmp.w	d7,d0
	bcc	WiEfX
	cmp.w	d6,d1
	bls	WiEfX
	cmp.w	d6,d0
	bls.s	WiEe1
	move.w	d0,d6
WiEe1:	cmp.w	d7,d1
	bcc.s	WiEe2
	move.w	d1,d7
WiEe2:	move.w	d7,-(sp)
	exg.l	d6,d7

* Donnees inits
	moveq	#0,d6
	move.w	WiTxR(a5),d6
	move.w	WiDxR(a5),d0
	add.w	d6,d0
	move.w	d0,-(sp)
	move.w	WiDxR(a5),-(sp)
	moveq	#0,d4
	moveq	#0,d5

WiEf0:	move.w	(sp),d5
* Va clipper
WiEf1:	move.w	d5,d4
	move.w	2(sp),d5
	bsr	WiClip
	bne	WiEf4
* Adresse dans l'ecran
	move.w	d7,d3
	mulu	EcTLigne(a4),d3
	add.l	d4,d3
* Adresse dans le buffer
	move.w	d7,d0
	sub.w	WiDyR(a5),d0
	move.w	EcNPlan(a4),d2
	mulu	d2,d0
	mulu	d6,d0
	add.w	d4,d0
	sub.w	WiDxR(a5),d0
	move.l	WiDBuf(a5),a0
	add.l	d0,a0
	subq.w	#1,d2
	move.w	d5,d1
	sub.w	d4,d1
	lea	EcLogic(a4),a2
	cmp.w	#8,d1
	bcc.s	WiER
** Recopie LENTE!
	subq.w	#1,d1
WiEf2:	move.l	(a2)+,a3
	add.l	d3,a3
	move.l	a0,a1
	move.w	d1,d0
WiEf3:	move.b	(a1)+,(a3)+
	dbra	d0,WiEf3
	add.l	d6,a0
	dbra	d2,WiEf2
	cmp.w	2(sp),d5
	bcs.s	WiEf1
	bra.s	WiEf4
** Recopie plus RAPIDE!
WiER:	move.w	d1,d4
	lsr.w	#2,d1
	subq.w	#1,d1
	and.w	#3,d4
	subq.w	#1,d4
WiEr2:	move.l	(a2)+,a3
	add.l	d3,a3
	move.l	a0,a1
	move.w	d1,d0
WiEr3:	move.b	(a1)+,(a3)+
	move.b	(a1)+,(a3)+
	move.b	(a1)+,(a3)+
	move.b	(a1)+,(a3)+
	dbra	d0,WiEr3
	move.w	d4,d0
	bmi.s	WiEr5
WiEr4:	move.b	(a1)+,(a3)+
	dbra	d0,WiEr4
WiEr5:	add.l	d6,a0
	dbra	d2,WiEr2
	cmp.w	2(sp),d5
	bcs	WiEf1
** Encore une ligne en Y?
WiEf4:	addq.w	#1,d7
	cmp.w	4(sp),d7
	bcs	WiEf0
	addq.l	#6,sp
** Ca y est!
WiEfX:	movem.l	(sp)+,d0-d7/a0-a3
	rts

******* Effacement du buffer de decor (a5)
WiEffBuf:
	move.l	WiDBuf(a5),d0
	beq.s	WiEbX
	move.l	d0,a1
	move.l	WiTBuf(a5),d0
	bsr	FreeMm
	clr.l	WiDBuf(a5)
	clr.l	WiTBuf(a5)
WiEbX:	rts

******* Window clipping
WiClip:	move.l	WiPrev(a5),d0
	beq.s	WiClpX
WiClp0:	move.l	d0,a0
	move.w	d4,d2
	move.w	d5,d3
* Bonne ligne?
	cmp.w	WiDyR(a0),d7
	bcs.s	WiClpN
	cmp.w	WiFyR(a0),d7
	bcc.s	WiClpN
* Rapproche les limites
	cmp.w	WiDxR(a0),d5
	bls.s	WiClpN
	cmp.w	WiFxR(a0),d4
	bcc.s	WiClpN
	cmp.w	WiDxR(a0),d4
	bcc.s	WiClp1
	move.w	WiDxR(a0),d5
	bra.s	WiClp2
WiClp1:	move.w	WiFxR(a0),d4
* Encore de la place?
WiClp2:	cmp.w	d4,d5
	bls.s	WiClpO
* Encore une fenetre devant?
WiClpN:	move.l	WiPrev(a0),d0
	bne.s	WiClp0
WiClpX:	moveq	#0,d0
	rts
* Refaire un tour?
WiClpO:	cmp.w	d2,d4
	bne.s	WiClpR
	cmp.w	d3,d5
	bne.s	WiClpR
WiClpE:	moveq	#-1,d0
	rts
* Un tour encore pour sortir des chevauchements
WiClpR:	cmp.w	4+2(sp),d4
	bcc.s	WiClpE
	move.w	d5,d4
	move.w	4+2(sp),d5
	move.l	WiPrev(a5),d0
	bra.s	WiClp0

***********************************************************
*	GESTION DU CURSEUR
***********************************************************

******* AffCur:	affiche le curseur si en route
AffCur:	btst	#1,WiSys(a5)
	beq.s	AfCFin

	movem.l	d0-d7/a0-a3,-(sp)
	lea	WiCuDraw(a5),a0
	move.l	a0,d6
	lea	EcCurS(a4),a1
	lea	EcCurrent(a4),a3
	move.l	WiAdCur(a5),d2
	move.w	WiCuCol(a5),d5
	move.w	WiNPlan(a5),d4
	move.w	EcTLigne(a4),d3
	ext.l	d3

; Affiche NORMAL
AfC1:	move.l	d6,a0
	move.l	(a3)+,a2
	add.l	d2,a2
	moveq	#7,d1
	lsr.w	#1,d5
	bcs.s	AfC3
AfC2:	move.b	(a2),(a1)+		;Sauve
	move.b	(a0)+,d0
	not.b	d0
	and.b	d0,(a2)
	add.l	d3,a2
	dbra	d1,AfC2
	bra.s	AfC4
AfC3:	move.b	(a2),(a1)+
	move.b	(a0)+,d0
	or.b	d0,(a2)
	add.l	d3,a2
	dbra	d1,AfC3
AfC4:	dbra	d4,AfC1
	movem.l	(sp)+,d0-d7/a0-a3
AfCFin:	rts

******* EffCur:	efface le curseur si en route
EffCur:	btst	#1,WiSys(a5)
	beq.s	EfCFin

	movem.l	d3-d7/a0-a2,-(sp)
	lea	EcCurS(a4),a0

	move.w	WiNPlan(a5),d6
	move.w	EcTLigne(a4),d5
	ext.l	d5
	move.l	WiAdCur(a5),d4
	lea	EcCurrent(a4),a2

; Efface NORMAL
EfC1:	move.l	(a2)+,a1
	add.l	d4,a1
	moveq	#7,d3
EfC2:	move.b	(a0)+,(a1)
	add.l	d5,a1
	dbra	d3,EfC2
	dbra	d6,EfC1
	movem.l	(sp)+,d3-d7/a0-a2
EfCFin:	rts

***********************************************************
*	WINDOPEN
*	D1= # de fenetre
*	D2= X
*	D3= Y
*	D4= TX
*	D5= TY
*	D6= Flags / 0=Faire un CLW
*	D7= 0 / # de bordure
*	A1= # du jeu de caracteres
***********************************************************
WOpen:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4

; Demande de la place memoire
	move.l	#WiLong,d0
	bsr	FastMm
	bne.s	Wo0
	moveq	#1,d0
	bra	WOut
Wo0:	move.l	a5,a3
	move.l	d0,a5
	lea	Circuits,a6

; Fenetre deja ouverte?
	bsr	WindFind
	beq	WErr2
	move.w	d1,WiNumber(a5)
	move.w	EcNPlan(a4),d0
	subq.w	#1,d0
	move.w	d0,WiNPlan(a5)
	move.w	#8,WiTyCar(a5)

* Jeu de caractere
	move.l	a1,d0
	bne	WErr5
	move.l	T_JeuDefo(a3),WiFont(a5)
	lsr.w	#4,d2
	lsl.w	#1,d2
	cmp.w	#16,d7
	bhi	WErr7
	move.w	d7,WiBord(a5)
	beq.s	Wo2
	addq.w	#1,d2
* Va tout calculer!
Wo2	bsr	WiAdr
	bne	WErr

* Init parametres
	clr.w	WiSys(a5)
	clr.w	WiEsc(a5)
	moveq	#0,d1			;Writing 0
	bsr	Writing
	move.l	EcWindow(a4),d0
	beq.s	Wo3a
* Une fenetre ouverte: reprend les parametres
	move.l	d0,a0
	move.w	WiPaper(a0),WiPaper(a5)
	move.w	WiPen(a0),WiPen(a5)
	move.w	WiCuCol(a0),WiCuCol(a5)
	move.w	WiBorPap(a0),WiBorPap(a5)
	move.w	WiBorPen(a0),WiBorPen(a5)
	move.w	WiTab(a0),WiTab(a5)
	bra.s	Wo4
* Aucune fenetre ouverte: parametre par defaut
Wo3a:	move.w	#1,WiPaper(a5)		;Paper=1 / Pen=2
	move.w	#2,WiPen(a5)
	move.w	#3,WiCuCol(a5)
	move.w	#4,WiTab(a5)
	move.w	#1,WiBorPap(a5)
	move.w	#2,WiBorPen(a5)
	cmp.w	#1,EcNPlan(a4)		;Si 1 plan
	bne.s	Wo4
	clr.w	WiPaper(a5)		;Paper=0 / Pen=1
	move.w	#1,WiPen(a5)
	move.w	#1,WiCuCol(a5)
	clr.w	WiBorPap(a5)
	move.w	#1,WiBorPen(a5)
Wo4:	bsr	AdColor
	moveq	#1,d1			;Scrollings
	bsr	Scroll

* Stocke (s'il faut!) la fenetre courante
	move.l	EcWindow(a4),d0
	beq.s	Wo5
	move.l	a5,-(sp)
	move.l	d0,a5
	bsr	EffCur
	bsr	WiStore
	move.l	(sp)+,a5
Wo5:

* Bordure: Pas de titre
	clr.w	WiTitH(a5)
	clr.w	WiTitB(a5)
	tst.w	WiBord(a5)
	beq.s	PaBor
	bsr	DesBord
PaBor:
* Effacement de l'interieur
	bsr	WiInt
	btst	#0,d6
	beq.s	.Skip
	bsr	Clw
.Skip	bsr	Home

* Initialisation du curseur nouvelle fenetre
	lea	DefCurs(pc),a0
	lea	WiCuDraw(a5),a1
	moveq	#7,d0
InCu:	move.b	(a0)+,(a1)+
	dbra	d0,InCu
	bset	#1,WiSys(a5)
	bsr	AffCur

* Premiere fenetre de l'ecran / Fenetre courante
	move.l	EcWindow(a4),d0
	move.l	a5,EcWindow(a4)
	clr.l	WiPrev(a5)
	move.l	d0,WiNext(a5)
	beq	WOk
	move.l	d0,a0
	move.l	a5,WiPrev(a0)
	bra	WOk

******* Calcul des adresses fenetres!
WiAdr:	move.w	d2,WiDxR(a5)
	move.w	d2,WiDxI(a5)
	move.w	d3,WiDyI(a5)

* Controle largeur
	and.w	#$FFFE,d4		* Taille en X paire
	beq	WAdE3
	move.w	d2,d0
	add.w	d4,d0
	cmp.w	EcTLigne(a4),d0
	bhi	WAdE4
	move.w	d0,WiFxR(a5)
* Controle hauteur
	move.w	WiTyCar(a5),d1
	move.w	EcTLigne(a4),d0
	mulu	d1,d0
	move.w	d0,WiTLigne(a5)
	move.w	d5,d0
	beq	WAdE3
	mulu	d1,d0
	move.w	d0,WiTyP(a5)
	move.w	d3,WiDyR(a5)
	add.w	d3,d0
	move.w	d0,WiFyR(a5)
	mulu	EcTLigne(a4),d0
	cmp.l	EcTPlan(a4),d0
	bhi	WAdE4
	mulu	EcTLigne(a4),d3
	add.w	d2,d3

	move.l	d3,WiAdhgR(a5)
	move.w	d4,WiTxR(a5)
	move.w	d5,WiTyR(a5)
	tst.w	WiBord(a5)
	beq.s	Wo3
	addq.w	#1,WiDxI(a5)
	add.w	d1,WiDyI(a5)
	subq.w	#2,d4
	bmi	WAdE3
	beq	WAdE3
	subq.w	#2,d5
	bmi	WAdE3
	beq	WAdE3
	mulu	EcTLigne(a4),d1
	add.l	d1,d3
	addq.l	#1,d3
Wo3:	move.l	d3,WiAdhgI(a5)
	move.w	d4,WiTxI(a5)
	move.w	d5,WiTyI(a5)
	moveq	#0,d0
	rts
WAdE3:	moveq	#12,d0
	rts
WAdE4:	moveq	#13,d0
	rts

***********************************************************
*	Activation de fenetre: WINDOW
***********************************************************
WQWind:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
; Trouve l'adresse de la fenetre
	bsr	WindFind
	bne	WErr1
; Deja activee?
	move.l	WiPrev(a0),d0
	beq.s	QWiF
* Stocke le contenu de la fenetre courante
	bsr	EffCur
	bsr	WiStore
* Debranche la fenetre
	move.l	d0,a1
	move.l	WiNext(a0),a2
	move.l	a2,WiNext(a1)
	cmp.l	#0,a2
	beq.s	QWi1
	move.l	a1,WiPrev(a2)
QWi1:
* La met en premier
	move.l	EcWindow(a4),a1
	move.l	a0,EcWindow(a4)
	clr.l	WiPrev(a0)
	move.l	a1,WiNext(a0)
	move.l	a0,WiPrev(a1)
	move.l	a0,a5
	move.w	WiDyR(a5),d6
	move.w	WiFyR(a5),d7
	bsr	WiEff			* Redessine
	bsr	WiEffBuf		* Plus besoin de buffer
* Plus d'escape!
	bsr	AffCur
QWiF	clr.w	WiEsc(a5)
* Pas d'erreur
WOk:	movem.l	(sp)+,d1-d7/a1-a6
*	clr.w	T_WiRep(a5)
	moveq	#0,d0
	rts
* Erreur 1
QWErr1:	bsr	EffCur
	bra	WErr1
WOut:	movem.l	(sp)+,d1-d7/a1-a6
	tst.l	d0
	rts

***********************************************************
*	WIND MOVE change la position de la fenetre
***********************************************************
WiMove:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	tst.w	WiNumber(a5)
	bne.s	WiMv0
	moveq	#18,d0
	bra.s	WOut

* Stocke le contenu de la fenetre courante
WiMv0:	bsr	EffCur
	bsr	WiStore
	move.w	WiDyR(a5),d6
	move.w	WiFyR(a5),d7
* Redessine les autres fenetres
	move.l	WiNext(a5),d0
	beq.s	WiMv2
	move.l	a5,-(sp)
	move.l	d0,a3
	move.l	WiPrev(a3),d3
	clr.l	WiPrev(a3)
WiMv1:	move.l	d0,a5			* Redessine toutes les autres
	bsr	WiEff
	move.l	WiNext(a5),d0
	bne.s	WiMv1
	move.l	d3,WiPrev(a3)
	move.l	(sp)+,a5
* Change les coordonnees
WiMv2:	move.w	d1,d0
	lsr.w	#4,d0
	lsl.w	#1,d0
	tst.w	WiBord(a5)
	beq.s	WiMv2a
	addq.w	#1,d0
WiMv2a:	move.w	d2,d1
	move.w	WiDxR(a5),d2
	move.w	WiDyR(a5),d3
	move.w	WiTxR(a5),d4
	move.w	WiTyR(a5),d5
	movem.w	d2-d5,-(sp)
	move.l	#EntNul,d7
	cmp.l	d7,d0
	bne.s	WiMv3
	move.w	WiDxR(a5),d0
WiMv3:	cmp.l	d7,d1
	bne.s	WiMv4
	move.w	WiDyR(a5),d1
WiMv4:	move.w	d0,d2
	move.w	d1,d3
	bsr	WiAdr
	beq.s	WiMv5
	movem.w	(sp)+,d2-d5
	move.l	d0,-(sp)
	bsr	WiAdr
	bra.s	WiMv6
WiMv5:	addq.l	#8,sp
	clr.l	-(sp)
* Redessine la fenetre
WiMv6:	bsr	WiInt
	bsr	AdCurs
	moveq	#0,d6
	move.w	#10000,d7
	bsr	WiEff
	bsr	WiEffBuf
	bsr	AffCur
	move.l	(sp)+,d0
	bra	WOut

***********************************************************
*	WIND SIZE change la taille de la fenetre
***********************************************************
WiSize:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	tst.w	WiNumber(a5)
	bne.s	WiSi0
	moveq	#18,d0
	bra	WOut

* Stocke le contenu de la fenetre courante
WiSi0:	bsr	EffCur
	bsr	WiStore
	move.w	WiTxR(a5),d6
	move.w	WiTyP(a5),d7
	clr.w	-(sp)
	movem.w	d6-d7,-(sp)
* Redessine les autres fenetres
	move.w	WiDyR(a5),d6
	move.w	WiFyR(a5),d7
	move.l	WiNext(a5),d0
	beq.s	WiSi2
	move.l	a5,-(sp)
	move.l	d0,a3
	move.l	WiPrev(a3),d3
	clr.l	WiPrev(a3)
WiSi1:	move.l	d0,a5			* Redessine toutes les autres
	bsr	WiEff
	move.l	WiNext(a5),d0
	bne.s	WiSi1
	move.l	d3,WiPrev(a3)
	move.l	(sp)+,a5
* Change les coordonnees
WiSi2:	move.w	d1,d0
	move.w	d2,d1
	move.w	WiDxR(a5),d2
	move.w	WiDyR(a5),d3
	move.w	WiTxR(a5),d4
	move.w	WiTyR(a5),d5
	movem.w	d2-d5,-(sp)
	move.l	#EntNul,d7
	cmp.l	d7,d0
	bne.s	WiSi3
	move.w	WiTxR(a5),d0
WiSi3:	cmp.l	d7,d1
	bne.s	WiSi4
	move.w	WiTyR(a5),d1
WiSi4:	move.w	d0,d4
	move.w	d1,d5
	bsr	WiAdr
	beq.s	WiSi5
	movem.w	(sp)+,d2-d5
	move.w	d0,4(sp)
	bsr	WiAdr
	bra.s	WiSi6
WiSi5:	addq.l	#8,sp
* Redessinne la fenetre
WiSi6:	bsr	WiInt
	bsr	AdCurs
	lea	Circuits,a6
	tst.w	WiBord(a5)
	beq.s	WiSi7
	bsr	DesBord
WiSi7:	bsr	Clw
	movem.w	(sp)+,d6-d7
	bsr	WiEff2
	bsr	WiEffBuf
	bsr	AffCur
	move.w	(sp)+,d0
	ext.l	d0
	bra	WOut

******* BORDER n,pen,paper
WSBor:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	cmp.l	#EntNul,d1
	beq.s	Wsb1
	cmp.l	#16,d1
	bcc	WErr7
	tst.w	d1
	beq.s	Wsb1
	move.w	d1,WiBord(a5)
Wsb1:	cmp.l	#EntNul,d2
	beq.s	Wsb2
	cmp.w	EcNbCol(a4),d2
	bcc	WErr7
	move.w	d2,WiBorPap(a5)
Wsb2:	cmp.l	#EntNul,d3
	beq.s	Wsb3
	cmp.w	EcNbCol(a4),d3
	bcc	WErr7
	move.w	d3,WiBorPen(a5)
Wsb3:	bsr	ReBord
	bra	WOk

******* TITLE D1/D2
WSTit:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	tst.w	WiBord(a5)
	beq	WErr10
	tst.l	d1
	beq.s	WTi1
	move.l	d1,a0
	lea	WiTitH(a5),a1
	bsr	ssWti
WTi1:	tst.l	d2
	beq.s	WTi2
	move.l	d2,a0
	lea	WiTitB(a5),a1
	bsr	ssWti
WTi2:	bsr	ReBord
	bra	WOk

* routine!
SsWti:	moveq	#78,d0
sWti1:	move.b	(a0)+,(a1)+
	beq.s	sWti2
	dbra	d0,sWti1
	clr.b	(a1)
sWti2:	rts

******* WINDOW ADRESSE
WAdr:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
	moveq	#0,d1
	move.w	WiNumber(a0),d1
	moveq	#0,d0
	rts

******* SET CURS a1
WiSCur:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	bsr	EffCur
	lea	WiCuDraw(a5),a2
	moveq	#7,d0
WiScu:	move.b	(a1)+,(a2)+
	dbra	d0,WiScu
	bsr	AffCur
	bra	WOk

******* Effacement de la fenetre courante
WDel:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
	tst.w	WiNumber(a0)
	bne.s	WiD1
	moveq	#18,d0
	rts
WiD1:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),d0
	move.l	d0,a5
	beq	WErr1
	bsr	EffCur
	lea	Circuits,a6
	bsr	CClw
	move.l	WiNext(a5),-(sp)
	moveq	#-1,d5
	move.w	WiDyR(a5),d6		* Zone a clipper!
	move.w	WiFyR(a5),d7
* Enleve la table de donnees
	move.l	a5,a1
	move.l	#WiLong,d0
	bsr	FreeMm
* Branche la fenetre suivante
	move.l	(sp)+,a5
	move.l	a5,EcWindow(a4)
	cmp.l	#0,a5
	beq	WOk
	clr.l	WiPrev(a5)
* Redessine toutes les autres fenetres
	move.l	a5,-(sp)
	bsr	WiEff
	bsr	WiEffBuf
WiD2	move.l	WiNext(a5),d0
	beq.s	WiD3
	move.l	d0,a5
	bsr	WiEff
	bra.s	WiD2
* Remet le curseur
WiD3:	move.l	(sp)+,a5
	bsr	AffCur
	bra	WOk

******* Effacement de toutes les fenetres
WiDelA:	bsr	WiD1
	tst.l	d0
	beq.s	WiDelA
	moveq	#0,d0
	rts

******* CLS effacement de toutes les fenetres SAUF zero!
WiCls:	movem.l	d1-d7/a0-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),d5
	move.l	d5,a5
	bsr	EffCur
WiCls1:	move.l	d5,a5
	move.l	WiNext(a5),d5
	tst.w	WiNumber(a5)
	bne.s	WiCls2
	move.l	a5,d7
	bra.s	WiCls3
WiCls2:	bsr	WiEffBuf
	move.l	#WiLong,d0
	move.l	a5,a1
	bsr	FreeMm
WiCls3:	tst.l	d5
	bne.s	WiCls1
	move.l	d7,a5
	move.l	a5,EcWindow(a4)
	clr.l	WiPrev(a5)
	clr.l	WiNext(a5)
	lea	Circuits,a6
	bsr	Clw
	bsr	WiEffBuf
	bsr	AffCur
	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	rts

******* Recherche la fenetre D1 dans les tables
WindFind:
	move.l	EcWindow(a4),d0
	beq.s	WiF2
WiF1:	move.l	d0,a0
	cmp.w	WiNumber(a0),d1
	beq.s	WiF3
	move.l	WiNext(a0),d0
	bne.s	WiF1
WiF2:	moveq	#1,d0
WiF3:	rts

***********************************************************
*	Dessine la bordure D1
***********************************************************
DesBord:movem.l	d1-d7/a1-a6,-(sp)

	tst.w	WiBord(a5)
	beq	WErr10
	move.w	WiBord(a5),d1
	lsl.w	#1,d1
	lea	Brd(pc),a1
	add.w	-2(a1,d1.w),a1
	bsr	WiExt

; Dessine le haut!
	bsr	Home
	lea	WiTitH(a5),a2
	bsr	DHoriz
; Dessine la droite
	move.w	WiTx(a5),d1
	subq.w	#1,d1
	moveq	#1,d2
	bsr	Loca
	bsr	DVert
; Dessine le bas
	moveq	#0,d1
	move.w	WiTy(a5),d2
	subq.w	#1,d2
	bsr	Loca
	lea	WiTitB(a5),a2
	bsr	DHoriz
; Dessine la gauche
	moveq	#0,d1
	moveq	#1,d2
	bsr	Loca
	bsr	DVert

; Pas d'erreur
	bsr	WiInt
	bra	WOk

******* Re dessine le bord, remet le curseur!!!
ReBord	move.w	WiX(a5),-(sp)
	move.w	WiY(a5),-(sp)
	move.l	WiAdCur(a5),-(sp)
	bsr	DesBord
	move.l	(sp)+,WiAdCur(a5)
	move.w	(sp)+,WiY(a5)
	move.w	(sp)+,WiX(a5)
	moveq	#0,d0
	rts

******* Dessine de la bordure HORIZONTALE
DHoriz:

; Fixe la fenetre pour les bords
	bsr	SetBord

; Position en Y
	move.w	WiY(a5),d2

; Dessine la gauche
Dh1:	cmp.w	WiY(a5),d2
	bne.s	Dh2
	move.b	(a1)+,d1
	beq.s	Dh3
	bsr	COut
	bra.s	Dh1
Dh2:	move.l	a1,a0
	bsr	Compte
	move.l	a0,a1
	bsr	CLeft
Dh3:	move.w	WiTx(a5),d6
	sub.w	WiX(a5),d6

; Dessine la droite
	move.l	a1,a0
	bsr	Compte
	move.l	a0,d3
	move.w	WiTx(a5),d7
	sub.w	d0,d7
	bcc.s	Dh10
	clr.w	d7
Dh10:	cmp.w	d6,d7
	bcc.s	Dh11
	move.w	d6,d7
Dh11:	move.w	d7,d1
	bsr	Loca
Dh12:	cmp.w	WiY(a5),d2
	bne.s	Dh13
	move.b	(a1)+,d1
	beq.s	Dh13
	bsr	COut
	bra.s	Dh12
Dh13:	move.l	d3,a1

; Dessine le milieu
	move.l	a1,d3
	move.w	d6,d1
	bsr	Loca
Dh20:	move.w	WiTx(a5),d0
	sub.w	WiX(a5),d0
	cmp.w	d7,d0
	bcc.s	Dh22
	move.b	(a1)+,d1
	bne.s	Dh21
	move.l	d3,a1
	move.b	(a1)+,d1
	bne.s	Dh21
	subq.l	#1,a1
	moveq	#32,d1
Dh21:	bsr	COut
	bra.s	Dh20
Dh22:	move.l	d3,a0
	bsr	Compte
	move.l	a0,a1

; Imprime la chaine de de caracteres (A2)
	exg	a2,a1
	move.w	d6,d1
	bsr	Loca
Dh30:	move.w	WiTx(a5),d0
	sub.w	WiX(a5),d0
	cmp.w	d7,d0
	bcc.s	Dh32
	move.b	(a1)+,d1
	beq.s	Dh32
	bsr	COut
	bra.s	Dh30
Dh32:	exg	a1,a2

; Fini! Restore
DhFin:	bsr	SetNorm
	rts


******* Dessin bordure VERTICAL
DVert:

;-----> Fixe fenetre pour les bords
	bsr	SetBord

;-----> Dessine le bord
	move.w	WiTx(a5),d4
	sub.w	WiX(a5),d4
	moveq	#1,d2
	move.w	WiTyI(a5),d3
	move.l	a1,d5
DbV1:	cmp.w	d3,d2
	bhi.s	DbV3
	move.w	d4,d1
	bsr	Loca
	move.b	(a1)+,d1
	bne.s	DbV2
	move.l	d5,a1
	move.b	(a1)+,d1
	bne.s	DbV2
	subq.l	#1,a1
	moveq	#32,d1
DbV2:	move.w	WiX(a5),d6
	bsr	COut
	cmp.w	WiX(a5),d6		;Boucle si code de controle
	beq.s	DbV1
	addq.w	#1,d2
	bra.s	DbV1
DbV3:	move.l	d5,a0
	bsr	Compte
	move.l	a0,a1

	bsr	SetNorm
	rts

******* Scroll off / Ecriture normale
SetBord:move.l	(sp)+,a3

	move.w	WiSys(a5),-(sp)
	move.w	WiFlags(a5),-(sp)
	move.w	WiPaper(a5),-(sp)
	move.w	WiPen(a5),-(sp)

	movem.l	a1/a2/a3,-(sp)
	moveq	#0,d1
	bsr	Scroll
	move.w	#-1,WiGraph(a5)
	and.w	#$0001,WiFlags(a5)
	move.w	WiBorPap(a5),WiPaper(a5)
	move.w	WiBorPen(a5),WiPen(a5)
	bsr	AdColor
	movem.l	(sp)+,a1/a2/a3

	jmp	(a3)

******* Retour fenetre normale
SetNorm:move.l	(sp)+,a3

	move.w	(sp)+,WiPen(a5)
	move.w	(sp)+,WiPaper(a5)
	move.w	(sp)+,WiFlags(a5)
	move.w	(sp)+,WiSys(a5)
	clr.w	WiGraph(a5)

	movem.l	a1/a2/a3,-(sp)
	bsr	AdColor
	movem.l	(sp)+,a1/a2/a3

	jmp	(a3)

***********************************************************
*	CLW D1 caracteres au curseur
***********************************************************
RazCur:	cmp.w	WiX(a5),d1
	bcs.s	RazC0a
	move.w	WiX(a5),d1
RazC0a	subq.w	#1,d1
	bmi.s	RazC3

	move.l	WiAdCur(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiNPlan(a5),d2
	move.w	EcTLigne(a4),d3
	ext.l	d3
	move.w	WiTyCar(a5),d4
	subq.w	#1,d4
	lea	WiColFl(a5),a3

	move.l	a4,-(sp)
RazC0:	move.l	a0,a1
	move.l	a3,a4
	move.w	d2,d5
RazC1:	move.l	(a1)+,a2
	add.l	d0,a2
	move.w	(a4)+,d7
	addq.l	#2,a4
	move.w	d4,d6
	btst	d5,WiSys+1(a5)
	bne.s	RazC2a
RazC2:	move.b	d7,(a2)
	add.l	d3,a2
	dbra	d6,RazC2
RazC2a:	dbra	d5,RazC1
	addq.l	#1,d0
	dbra	d1,RazC0
	move.l	(sp)+,a4

RazC3:	moveq	#0,d0
	rts

***********************************************************
*	CL TO END OF LINE (Vite!)
***********************************************************
ClEol:	move.w	WiX(a5),d3
	move.l	WiAdCur(a5),d0
	btst	#0,d0
	beq.s	ClEo1
	movem.l	d0/d3,-(sp)
	moveq	#1,d1
	bsr	RazCur
	movem.l	(sp)+,d0/d3
	addq.l	#1,d0
	subq.w	#1,d3
ClEo1	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	tst.w	d3
	ble.s	ClEo2
	bsr	ClFin
ClEo2	moveq	#0,d0
	rts

***********************************************************
*	CLW of ALL window, even border!
***********************************************************
CClw:	tst.w	WiBord(a5)
	beq.s	Clw
	clr.b	WiTitH(a5)
	clr.b	WiTitB(a5)
	move.w	#16,WiBord(a5)
	move.w	WiPaper(a5),WiBorPap(a5)
	bsr	DesBord

***********************************************************
*	CLW
***********************************************************
Clw:	move.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	mulu	WiTyI(a5),d2
	move.w	WiTxI(a5),d3
	bsr	ClFin
	bra	Home

***********************************************************
*	CL LIGNE CURSEUR
***********************************************************
ClLine:	move.w	WiY(a5),d0
	mulu	WiTLigne(a5),d0
	add.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	move.w	WiTxI(a5),d3

; Fin de CLW
ClFin:	subq.w	#1,d2
	lea	WiColFl(a5),a1
	move.w	EcTLigne(a4),d1
	ext.l	d1
	lsr.w	#1,d3
	lsl.w	#6,d3
	or.w	#1,d3
	move.w	WiNPlan(a5),d4

	bsr	OwnBlit
	move.w	#%0000000110101010,BltCon0(a6)
	clr.w	BltCon1(a6)
	clr.w	BltModD(a6)
	move.w	#$8040,DmaCon(a6)
Clw1:	move.w	d4,d5
	move.l	a0,a2
	move.l	a1,a3
Clw2:	btst	d5,WiSys+1(a5)
	bne.s	.skip
	bsr	BlitWait
	move.l	(a2),d7
	add.l	d0,d7
	move.l	d7,BltAdD(a6)
	move.w	(a3),BltDatC(a6)
	move.w	d3,BltSize(a6)
.skip	addq.l	#4,a2
	addq.l	#4,a3
	dbra	d5,Clw2
	add.l	d1,d0
	dbra	d2,Clw1
	bsr	Blitwait
	bsr	DOwnBlit
	moveq	#0,d0
	rts

***********************************************************
*	SCROLLING VERS LA GAUCHE LIGNE CURSEUR
***********************************************************
ScGLine:move.w	WiY(a5),d0
	mulu	WiTLigne(a5),d0
	add.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	bra	ScGFin
***********************************************************
*	SCROLLING VERS LA GAUCHE DE TOUT L'ECRAN
***********************************************************
ScGWi:	move.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	mulu	WiTyI(a5),d2

; Fin de
ScGFin:	subq.w	#1,d2
	lea	WiColFl(a5),a1
	move.w	EcTLigne(a4),d1
	ext.l	d1
	move.w	WiTxI(a5),d3
	lsr.w	#1,d3
	lsl.w	#6,d3
	or.w	#1,d3
	move.w	WiNPlan(a5),d4
	move.w	WiTxI(a5),d6
	subq.w	#1,d6

	move.l	a4,-(sp)
	bsr	OwnBlit
	move.w	#%0000010111001100,BltCon0(a6)
	move.w	#%1000000000000000,BltCon1(a6)
	clr.w	BltModB(a6)
	clr.w	BltModD(a6)
	move.w	#$8040,DmaCon(a6)
ScG1:	move.w	d4,d5
	move.l	a0,a4
	move.l	a1,a3
ScG2:	move.l	(a4)+,a2
	btst	d5,WiSys+1(a5)
	bne.s	.skip
	add.l	d0,a2
	move.l	a2,BltAdD(a6)		* Scrolle la ligne
	move.b	1(a2),d7
	lea	2(a2),a2
	move.l	a2,BltAdB(a6)
	lea	-2(a2),a2
	move.w	d3,BltSize(a6)
	bsr	BlitWait
	move.b	d7,(a2)
	move.b	(a3),0(a2,d6.w)		* Efface le petit bout
.skip	addq.l	#4,a3
	dbra	d5,ScG2
	add.l	d1,d0
	dbra	d2,ScG1
	bsr	DOwnBlit
	move.l	(sp)+,a4
	moveq	#0,d0
	rts

***********************************************************
*	SCROLLING VERS LA DROITE LIGNE CURSEUR
***********************************************************
ScDLine:move.w	WiY(a5),d0
	mulu	WiTLigne(a5),d0
	add.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	bra	ScDFin
***********************************************************
*	SCROLLING VERS LA GAUCHE DE TOUT L'ECRAN
***********************************************************
ScDWi:	move.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	mulu	WiTyI(a5),d2

; Fin de
ScDFin:	subq.w	#1,d2
	lea	WiColFl(a5),a1
	move.w	EcTLigne(a4),d1
	ext.l	d1
	move.w	WiTxI(a5),d3
	lsr.w	#1,d3
	lsl.w	#6,d3
	or.w	#1,d3
	move.w	WiNPlan(a5),d4

	move.l	a4,-(sp)
	bsr	OwnBlit
	move.w	#%0000010111001100,BltCon0(a6)
	move.w	#%1000000000000000,BltCon1(a6)
	clr.w	BltModB(a6)
	clr.w	BltModD(a6)
	move.w	#$8040,DmaCon(a6)
ScD1:	move.w	d4,d5
	move.l	a0,a4
	move.l	a1,a3
ScD2:	move.l	(a4)+,a2
	btst	d5,WiSys+1(a5)
	bne.s	.skip
	add.l	d0,a2
	move.l	a2,BltAdB(a6)
	move.l	a2,BltAdD(a6)		* Scrolle la ligne
	move.w	d3,BltSize(a6)
	bsr	BlitWait
	move.b	(a3),(a2)
.skip	addq.l	#4,a3
	dbra	d5,ScD2
	add.l	d1,d0
	dbra	d2,ScD1
	bsr	DOwnBlit
	move.l	(sp)+,a4
	moveq	#0,d0
	rts

***********************************************************
*	SCROLLING VERS LE HAUT DU BAS AU CURSEUR
***********************************************************
ScHautBas:
	lea	EcCurrent(a4),a2
	move.w	EcTLigne(a4),d0
	ext.l	d0
	move.w	WiTLigne(a5),d1
	move.w	WiY(a5),d2
	mulu	d1,d2
	add.l	WiAdhgI(a5),d2
	move.l	d2,a1			;Destination
	move.l	d2,a0
	add.w	d1,a0			;Source

; Va scroller
	move.w	WiTyI(a5),d1
	sub.w	WiY(a5),d1
	subq.w	#1,d1
	mulu	WiTyCar(a5),d1
	bsr	Scrolle

; Effacer la ligne du bas
	move.w	WiTyI(a5),d0
	subq.w	#1,d0
	mulu	WiTLigne(a5),d0
	add.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	move.w	WiTxI(a5),d3
	bra	ClFin

***********************************************************
*	SCROLLING VERS LE BAS DU HAUT AU CURSEUR
***********************************************************
ScBasHaut:
	lea	EcCurrent(a4),a2
	move.w	EcTLigne(a4),d0
	ext.l	d0
	move.w	WiTLigne(a5),d1
	move.w	WiY(a5),d2
	addq.w	#1,d2
	mulu	d1,d2
	sub.l	d0,d2
	add.l	WiAdhgI(a5),d2
	move.l	d2,a1			;Destination
	move.l	d2,a0
	sub.w	d1,a0			;Source
	neg.l	d0			;Delta ligne

; Va scroller
	move.w	WiY(a5),d1
	mulu	WiTYCar(a5),d1
	bsr	Scrolle

; Efface la ligne du haut
	move.l	WiAdhgI(a5),d0
	lea	EcCurrent(a4),a0
	move.w	WiTyCar(a5),d2
	move.w	WiTxI(a5),d3
	bra	ClFin

***********************************************************
*	SCROLLING VERS LE HAUT A LA POSITION DU CURSEUR
***********************************************************
ScHaut:	lea	EcCurrent(a4),a2
	move.w	EcTLigne(a4),d0		;Delta ligne= D0
	ext.l	d0
	move.l	WiAdhgI(a5),a1
	move.l	a1,a0
	add.w	WiTLigne(a5),a0		;Source= A0

	move.w	WiY(a5),d1		;Nb ligne= D1
	mulu	WiTyCar(a5),d1
	bsr	Scrolle
	bra	ClLine

***********************************************************
*	SCROLLING VERS LE BAS A LA POSITION DU CURSEUR
***********************************************************
ScBas:	lea	EcCurrent(a4),a2
	move.w	EcTLigne(a4),d0
	ext.l	d0
	move.w	WiTLigne(a5),d1
	move.w	WiTyI(a5),d2
	mulu	d1,d2
	sub.l	d0,d2
	add.l	WiAdhgI(a5),d2
	move.l	d2,a1			;Destination
	move.l	d2,a0
	sub.w	d1,a0			;Source
	neg.l	d0			;Delta ligne

	move.w	WiTyI(a5),d1
	sub.w	WiY(a5),d1
	subq.w	#1,d1
	mulu	WiTyCar(a5),d1
	bsr	Scrolle
	bra	ClLine

******* Fait le scrolling
Scrolle:subq.w	#1,d1
	bmi.s	ScFin

	move.l	EcTPlan(a4),d2
	move.w	WiTxI(a5),d3
	lsr.w	#1,d3
	lsl.w	#6,d3
	or.w	#1,d3
	move.w	WiNPlan(a5),d4

	bsr	OwnBlit
	move.w	#%0000001110101010,BltCon0(a6)
	clr.w	BltCon1(a6)
	clr.w	BltModC(a6)
	clr.w	BltModD(a6)
	move.w	#$8040,DmaCon(a6)
Sc1:	move.w	d4,d5
	move.l	a2,a3
Sc2:	btst	d5,WiSys+1(a5)
	bne.s	.skip
	bsr	BlitWait
	move.l	(a3),d6
	move.l	d6,d7
	add.l	a0,d6
	add.l	a1,d7
	move.l	d6,BltAdC(a6)
	move.l	d7,BltAdD(a6)
	move.w	d3,BltSize(a6)
.skip	addq.l	#4,a3
	dbra	d5,Sc2
	add.l	d0,a0
	add.l	d0,a1
	dbra	d1,Sc1
	bsr	BlitWait
	bsr	DOwnBlit

; Va effacer la ligne du curseur
ScFin:	rts

***********************************************************
*	SCROLLING ON/OFF
***********************************************************
Scroll:	bclr	#0,WiSys(a5)
	tst.w	d1
	beq.s	Scl
	bset	#0,WiSys(a5)
Scl:	moveq	#0,d0
	rts

***********************************************************
*	FIXE LA COULEUR DU CURSEUR
***********************************************************
CurCol:	cmp.w	EcNbCol(a4),d1
	bcc	PErr7
	move.w	d1,WiCuCol(a5)
	moveq	#0,d0
	rts

***********************************************************
*	CURSEUR ON/OFF
***********************************************************
Curs:	bclr	#1,WiSys(a5)
	tst.w	d1
	beq.s	Cus
	bset	#1,WiSys(a5)
Cus:	moveq	#0,d0
	rts

***********************************************************
*	JEU NORMAL/JEU GRAPHIQUE
*	D1=0 --> Normal / D1=1 --> Graphique
***********************************************************
ChgCar:	move.w	d1,WiGraph(a5)
	moveq	#0,d0
	rts

***********************************************************
*	SHADE on/off
*	D1= faux / vrai
***********************************************************
Shade:	bclr	#1,WiFlags+1(a5)
	tst.w	d1
	beq.s	Sha
	bset	#1,WiFlags+1(a5)
Sha:	moveq	#0,d0
	rts

***********************************************************
*	UNDER on/off
*	D1= faux / vrai
***********************************************************
Under:	bclr	#2,WiFlags+1(a5)
	tst.w	d1
	beq.s	Und
	bset	#2,WiFlags+1(a5)
Und:	moveq	#0,d0
	rts

***********************************************************
*	INVERSE on/off
*	D1= faux / vrai
***********************************************************
Inv:	tst.w	d1
	bne.s	InvOn
; Inverse off
	bclr	#2,WiSys(a5)
	beq.s	InvF
	bra.s	Inv1
; Inverse on
InvOn:	bset	#2,WiSys(a5)
	bne.s	InvF
Inv1:	move.w	WiPaper(a5),d0
	move.w	WiPen(a5),WiPaper(a5)
	move.w	d0,WiPen(a5)
	bsr	AdColor
InvF:	moveq	#0,d0
	rts

***********************************************************
*	Set PAPER
*	D1= paper
***********************************************************
Paper:	cmp.w	EcNbCol(a4),d1
	bcc	PErr7
	bclr	#2,WiSys(a5)
	beq.s	Pap1
	move.w	WiPaper(a5),WiPen(a5)
Pap1:	move.w	d1,WiPaper(a5)
	bsr	AdColor
	moveq	#0,d0
	rts

***********************************************************
*	Set PEN
*	D1= pen
***********************************************************
Pen:	cmp.w	EcNbCol(a4),d1
	bcc	PErr7
	bclr	#2,WiSys(a5)
	beq.s	Pen1
	move.w	WiPen(a5),WiPaper(a5)
Pen1:	move.w	d1,WiPen(a5)
	bsr	AdColor
	moveq	#0,d0
	rts

***********************************************************
*	Set PLANES
*	D1= planes
***********************************************************
Planes:	moveq	#0,d0
	move.w	WiNPlan(a5),d2
	moveq	#0,d3
.loop	btst	d3,d1
	bne.s	.skip
	bset	d2,d0
.skip	addq.w	#1,d3
	dbra	d2,.loop
	move.b	d0,WiSys+1(a5)
	bsr	AdColor
	moveq	#0,d0
	rts

***********************************************************
*	Curseur LEFT
***********************************************************
CLeft:	move.w	WiX(a5),d0
	addq.w	#1,d0
	cmp.w	WiTx(a5),d0
	bhi.s	CLt1
	move.w	d0,WiX(a5)
	bsr	AdCurs
	moveq	#0,d0
	rts
CLt1:	move.w	#1,WiX(a5)
	bra	CUp

***********************************************************
*	Curseur RIGHT
***********************************************************
CRight:	subq.w	#1,WiX(a5)
	beq.s	CRt1
	bsr	AdCurs
	moveq	#0,d0
	rts
CRt1:	move.w	WiTx(a5),WiX(a5)
	bra	CDown

***********************************************************
*	Curseur UP
***********************************************************
CUp:	subq.w	#1,WiY(a5)
	bpl.s	CUp1
	btst	#0,WiSys(a5)
	bne.s	CUp2
	move.w	WiTy(a5),d0
	subq.w	#1,d0
	move.w	d0,WiY(a5)
CUp1:	bsr	AdCurs
	moveq	#0,d0
	rts
CUp2:	clr.w	WiY(a5)
	bsr	AdCurs
	movem.l	d2-d7/a1-a3,-(sp)
	bsr	ScBas
	movem.l	(sp)+,d2-d7/a1-a3
	rts

***********************************************************
*	Curseur DOWN
***********************************************************
CDown:	move.w	WiY(a5),d0
	addq.w	#1,d0
	cmp.w	WiTy(a5),d0
	bcs.s	Cdo1
	btst	#0,WiSys(a5)
	bne.s	Cdo2
	clr.w	d0
Cdo1:	move.w	d0,WiY(a5)
	bsr	AdCurs
	moveq	#0,d0
	rts
Cdo2:	movem.l	d2-d7/a1-a3,-(sp)
	bsr	ScHaut
	movem.l	(sp)+,d2-d7/a1-a3
	rts

***********************************************************
*	A la ligne
***********************************************************
CReturn:move.w	WiTx(a5),WiX(a5)
	bsr	AdCurs
	moveq	#0,d0
	rts

***********************************************************
*	Set TAB
***********************************************************
SetTab:	cmp.w	WiTx(a5),d1
	bcc	PErr7
	move.w	d1,WiTab(a5)
	moveq	#0,d0
	rts

***********************************************************
*	Next TAB
***********************************************************
Tab:	move.w	WiTx(a5),d0
	sub.w	WiX(a5),d0
	move.w	WiTab(a5),d1
	beq.s	Tab3
Tab1:	cmp.w	d0,d1
	bhi.s	Tab2
	add.w	WiTab(a5),d1
	bra.s	Tab1
Tab2:	cmp.w	WiTx(a5),d1
	bcc.s	Tab3
	move.w	WiY(a5),d2
	bsr	Loca
Tab3:	moveq	#0,d0
	rts

***********************************************************
*	Repeter
***********************************************************
Repete:	move.l	W_Base(pc),a3
	tst.w	T_WiRep(a3)
	bne.s	Rep2
; Demarrage du REPEAT
	tst.w	d1
	bne.s	Rep1
	lea	T_WiRepBuf(a3),a0
	move.l	a0,T_WiRepAd(a3)
	addq.w	#1,T_WiRep(a3)
	move.w	#1,WiEsc(a5)
Rep1:	moveq	#0,d0
	rts
; Stockage,
Rep2:	add.w	#48,d1
	lea	T_WiRepBuf+WiRepL-1(a3),a0
	move.l	a0,d2
	move.l	T_WiRepAd(a3),a0
	cmp.b	#27,-2(a0)
	bne.s	Rep3
	cmp.b	#"R",-1(a0)
	beq.s	Rep5
Rep3:	move.b	d1,(a0)+
	cmp.l	d2,a0
	bcc.s	Rep4
	move.l	a0,T_WiRepAd(a3)
RepF:	move.w	#1,WiEsc(a5)
	moveq	#0,d0
	rts
Rep4:	lea	2(a0),a0
	moveq	#48+1,d1
Rep5:	clr.b	-2(a0)
	move.w	d1,d2
	sub.w	#49,d2
	bpl.s	Rep6
	moveq	#0,d2
Rep6:	lea	T_WiRepBuf(a3),a0
Rep7:	move.b	(a0)+,d1
	beq.s	Rep8
	bsr	COut
	bra.s	Rep7
Rep8:	dbra	d2,Rep6
; Fini!
	clr.w	T_WiRep(a3)
	moveq	#0,d0
	rts

***********************************************************
*	Fonction MEMORISER
***********************************************************
MemoCu:	tst.w	d1
	beq.s	MeX
	cmp.w	#1,d1
	beq.s	ReX
	cmp.w	#2,d1
	beq.s	MeY
	cmp.w	#3,d1
	beq.s	ReY
	bra.s	MemFin
* Memorise la position en X
MeX:    move.w	WiX(a5),WiMx(a5)
 	bra.s	MemFin
* Restitue la position en X
ReX:	move.w	WiMx(a5),d0
	beq.s	MemFin
	cmp.w	WiTx(a5),d0
	bhi.s	MemFin
	move.w	d0,WiX(a5)
        bsr	AdCurs
        bra.s	MemFin
* Memorise la position en Y
MeY:	move.w	WiY(a5),WiMy(a5)
	bra.s	MemFin
* Restitue la position en Y
ReY:	move.w	WiMy(a5),d0
	cmp.w	WiTy(a5),d0
	bcc.s	MemFin
	move.w	d0,WiY(a5)
	bsr	AdCurs
* Fini!
MemFin:	moveq	#0,d0
	rts

***********************************************************
*	Mouvement relatif du curseur
***********************************************************
DecaX:	add.w	#48,d1
	sub.b	#128,d1
 	ext.w	d1
 	move.w	WiTx(a5),d0
 	sub.w	WiX(a5),d0
	add.w	d0,d1
        bra	LocaX

DecaY:	add.w	#48,d1
	sub.b	#128,d1
	ext.w	d1
	add.w	WiY(a5),d1
	bra	LocaY

***********************************************************
*	Fonction ZONES
***********************************************************
WiZone:	tst.b	d1
	bne.s	WiZ

; CODE 0 ---> stocke X et Y
	move.w	WiTx(a5),d0
	sub.w	WiX(a5),d0
	move.w	d0,WiZoDX(a5)
	move.w	WiY(a5),WiZoDY(a5)
	moveq	#0,d0
	rts

; CODE <>0 ---> stocke dans les zones
WiZ:	move.w	d1,-(sp)
	bsr	CLeft
	move.w	(sp)+,d1
	and.w	#$FF,d1
	move.w	WiZoDx(a5),d2
	move.w	WiZoDy(a5),d3
	move.w	WiTx(a5),d4
	sub.w	WiX(a5),d4
	move.w	WiY(a5),d5
	addq.w	#1,d5
	lsl.w	#3,d2
	lsl.w	#3,d4
	add.w	#7,d4
	mulu	WiTyCar(a5),d3
	mulu	WiTyCar(a5),d5
	move.w	WiDxI(a5),d0
	lsl.w	#3,d0
	add.w	d0,d2
	add.w	d0,d4
	add.w	WiDyI(a5),d3
	add.w	WiDyI(a5),d5
	move.l	a5,-(sp)
	move.l	W_Base(pc),a5
	bsr	SySetZ
	move.l	(sp)+,a5
	move.l	d0,-(sp)
	bsr	CRight
	move.l	(sp)+,d0
	rts

***********************************************************
*	Fonction ENCADRER
***********************************************************
Encadre:move.l	W_Base(pc),a3
	tst.b	d1
	bne.s	Enc

; CODE 0 ---> stocke X et Y
	move.w	WiTx(a5),d0
	sub.w	WiX(a5),d0
	move.w	d0,T_WiEncDX(a3)
	move.w	WiY(a5),T_WiEncDY(a3)
	moveq	#0,d0
	rts

; CODE <>0 ---> encadre
Enc:	move.w	WiX(a5),-(sp)
	move.w	WiY(a5),-(sp)
	move.w	#-1,WiGraph(a5)

	and.w	#7,d1			;Pointe la bordure
	lsl.w	#3,d1
	lea	TEncadre(pc),a2
	lea	-8(a2,d1.w),a2
	move.w	WiTx(a5),d3		;TX
	sub.w	WiX(a5),d3
	sub.w	T_WiEncDX(a3),d3
	bmi	EncFin
	subq.w	#1,d3
	move.w	WiY(a5),d4		;TY
	sub.w	T_WiEncDY(a3),d4
	bmi	EncFin
	move.w	T_WiEncDX(a3),d1
	move.w	T_WiEncDY(a3),d2
	bsr	Loca

; Coin superieur gauche
	bsr	CLeft
	bsr	CUp
	move.b	(a2)+,d1
	bsr	COut
; Montant haut
	move.b	(a2)+,d1
	move.w	d3,d5
	bmi.s	Enc4
Enc3:	bsr	COut
	dbra	d5,Enc3
; Coin superieur droit
Enc4:	move.b	(a2)+,d1
	bsr	COut
	bsr	CLeft
	bsr	CDown
; Montant droit
	move.w	d4,d5
	bmi.s	Enc6
Enc5:	move.b	(a2),d1
	bsr	Cout
	bsr	CLeft
	bsr	CDown
	dbra	d5,Enc5
Enc6:	addq.l	#1,a2
; Coin inferieur droit
	move.b	(a2)+,d1
	bsr	COut
	bsr	CLeft
	bsr	CLeft
; Montant inferieur
	move.w	d3,d5
	bmi.s	Enc8
Enc7:	move.b	(a2),d1
	bsr	Cout
	bsr	CLeft
	bsr	CLeft
	dbra	d5,Enc7
Enc8:	addq.l	#1,a2
; Coin inferieur gauche
	move.b	(a2)+,d1
	bsr	COut
	bsr	CLeft
	bsr	CUp
; Montant gauche
	move.w	d4,d5
	bmi.s	Enc10
Enc9:	move.b	(a2),d1
	bsr	Cout
	bsr	CLeft
	bsr	CUp
	dbra	d5,Enc9
Enc10:

; Restore X et Y / Jeu de caracteres
EncFin:	clr.w	WiGraph(a5)
	move.w	(sp)+,WiY(a5)
	move.w	(sp)+,WiX(a5)
	bsr	AdCurs
	moveq	#0,d0
	rts

***********************************************************
*	HOME
***********************************************************
Home:	move.w	WiTx(a5),WiX(a5)
	clr.w	WiY(a5)
	bsr	AdCurs
	moveq	#0,d0
	rts

***********************************************************
*	XY WINDOW courant
***********************************************************
WiXYWi:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
	moveq	#0,d1
	moveq	#0,d2
	move.w	WiSys(a0),d0
	move.w	WiTx(a0),d1
	move.w	WiTy(a0),d2
	rts

***********************************************************
*	XYCURS
***********************************************************
WiXYCu:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
	moveq	#0,d1
	moveq	#0,d2
	move.w	WiTx(a0),d1
	sub.w	WiX(a0),d1
	move.w	WiY(a0),d2
	moveq	#0,d0
	rts

***********************************************************
*	XYGRAPHIC
***********************************************************
WiXGr:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
	cmp.w	WiTx(a0),d1
	bcc.s	WiXYo
	add.w	WiDxI(a0),d1
	lsl.w	#3,d1
	ext.l	d1
	moveq	#0,d0
	rts
WiYGr:	move.l	T_EcCourant(a5),a0
	move.l	EcWindow(a0),a0
	cmp.w	WiTy(a0),d1
	bcc.s	WiXYo
	lsl.w	#3,d1
	add.w	WiDyI(a0),d1
	ext.l	d1
	moveq	#0,d0
	rts
WiXYo:	moveq	#-1,d1
	rts

***********************************************************
*	Locate X= D1
***********************************************************
LocaX:	move.w	WiY(a5),d2
	bra.s	Loca

***********************************************************
*	Locate Y= D1
***********************************************************
LocaY:	move.w	d1,d2
	move.w	WiTx(a5),d1
	sub.w	WiX(a5),d1
	bra.s	Loca

***********************************************************
*	Locate D1/D2
***********************************************************
WLocate:movem.l	a4-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	tst.w	EcAuto(a4)
	bne.s	WLo3
	bsr	RLoca
WLoX	movem.l	(sp)+,a4-a6
	tst.l	d0
	rts
* Autoback
WLo3	lea	RLoca(pc),a0
	bsr	AutoPrt
	bra.s	WLoX
* Routine locate
RLoca:	bsr	EffCur
	cmp.l	#EntNul,d1
	bne.s	WLo1
	move.w	WiTx(a5),d1
	sub.w	WiX(a5),d1
WLo1:	cmp.l	#EntNul,d2
	bne.s	WLo2
	move.w	WiY(a5),d2
WLo2:	bsr	Loca
	bra	AffCur

Loca:	cmp.w	WiTy(a5),d2
	bcc	PErr7
	move.w	WiTx(a5),d0
	sub.w	d1,d0
	bls	PErr7
	move.w	d0,WiX(a5)
	move.w	d2,WiY(a5)
	move.l	d2,-(sp)
	move.w	d2,WiY(a5)
	mulu	WiTLigne(a5),d2
	move.w	d1,d0
	ext.l	d0
	add.l	d0,d2
	add.l	WiAdhg(a5),d2
	move.l	d2,WiAdCur(a5)
	move.l	(sp)+,d2
	moveq	#0,d0
	rts

***********************************************************
*	CHR OUT
***********************************************************
WOutC:	movem.l	a4-a6,-(sp)
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	lea	Circuits,a6
	bsr	EffCur
	bsr	COut
	bsr	AffCur
	movem.l	(sp)+,a4-a6
	tst.l	d0
	rts

***********************************************************
*	IMPRESSION LIGNE Scrollee � gauche
*	A1=	Ligne, finie par zero
*	D1= 	Nombre de caracteres � sauter sur la gauche
*		Bit 31= code controle?
*	D2=	Position minimum � gauche
*	D3=	Position maximum � droite
***********************************************************
WPrint3	movem.l	a4-a6/d2-d7,-(sp)
	lea	Circuits,a6
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	bsr	EffCur
	move.w	WiTx(a5),d5
	sub.w	WiX(a5),d5
	move.w	d3,d4
	move.w	d2,d3
	move.l	d1,d2
; Impression
.Loop	move.b	(a1)+,d1
	beq.s	.Ok
	cmp.b	#32,d1
	bcs.s	.Cont
; Un code normal, l'imprimer?
	subq.w	#1,d2
	bge.s	.Skip
	cmp.w	d3,d5
	blt.s	.Skip0
	cmp.w	d4,d5
	bge.s	.Ok
	bsr	COut
	bne	.Err
.Skip0	addq.w	#1,d5
.Skip	bra.s	.Loop
; Codes de controle autorises?
.Cont	cmp.b	#9,d1			TAB?
	beq.s	.Cont1
	tst.l	d2
	bpl.s	.PaCont
	cmp.b	#27,d1
	bne.s	.Cont1
	bsr	COut
	move.b	(a1)+,d1
	bsr	COut
	move.b	(a1)+,d1
.Cont1	bsr	COut
	bra.s	.Loop
.PaCont	cmp.b	#27,d1
	bne.s	.Loop
	addq.l	#2,a1
	bra.s	.Loop
; Fini!
.Ok	moveq	#0,d0
	move.w	d5,d1
.Err	bsr	AffCur
	movem.l	(sp)+,a4-a6/d2-d7
	tst.w	d0
	rts


***********************************************************
*	PRINT LINE,
*	A1= adresse chaine D1= nombre caracteres
***********************************************************
WPrint2	movem.l	a4-a6,-(sp)
	lea	Circuits,a6
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	tst.w	EcAuto(a4)
	bne.s	.WPrt
* Pas autoback!
	movem.l	a1/d1/d2,-(sp)
	bsr.s	.RPrt
	movem.l	(sp)+,a1/d1/d2
	movem.l	(sp)+,a4-a6
	tst.l	d0
	rts
* AutoBack!
.WPrt	lea	.RPrt(pc),a0
	bsr	AutoPrt
	movem.l	(sp)+,a4-a6
	tst.l	d0
	rts
******* Routine print nb caracteres
.RPrt	bsr	EffCur
	move.w	d1,d2
	subq.w	#1,d2
	bmi.s	.Out
.Prt	move.b	(a1)+,d1
	bsr	COut
	tst.w	d0
	bne.s	.Out
	dbra	d2,.Prt
.Out	bra	AffCur

***********************************************************
*	PRINT LINE, finie par ZERO
*	A1= adresse chaine
***********************************************************
WPrint:	movem.l	a4-a6,-(sp)
	lea	Circuits,a6
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	tst.w	EcAuto(a4)
	bne.s	WPrt
* Pas autoback!
	movem.l	a1/d1,-(sp)
	bsr	RPrt
	movem.l	(sp)+,a1/d1
	movem.l	(sp)+,a4-a6
	tst.l	d0
	rts
* AutoBack!
WPrt	lea	RPrt(pc),a0
	bsr	AutoPrt
	movem.l	(sp)+,a4-a6
	tst.l	d0
	rts
******* Routine print normale
RPrt:	bsr	EffCur
Prt:	move.b	(a1)+,d1
	beq	AffCur
	bsr	COut
	tst.w	d0
	beq.s	Prt
	bra	AffCur
*******	Routine print avec autoback
*	A0= routine a appeler
AutoPrt	movem.l	a0-a2/d1-d7,-(sp)
	btst	#BitDble,EcFlags(a4)
	beq.s	WPrt5
* Double buffer!
	lea	WiAuto(pc),a1
	lea	EcCurS(a5),a0
	moveq	#(8*6)/4-1,d0
WPrt1	move.l	(a0)+,(a1)+
	dbra	d0,WPrt1
	move.l	a5,a0
	moveq	#WiSAuto/4-1,d0
WPrt2	move.l	(a0)+,(a1)+
	dbra	d0,WPrt2
	bsr	TAbk1
	movem.l	(sp),a0-a2/d1-d7
	jsr	(a0)
	lea	WiAuto(pc),a0
	lea	EcCurS(a5),a1
	moveq	#(8*6)/4-1,d0
WPrt3	move.l	(a0)+,(a1)+
	dbra	d0,WPrt3
	move.l	a5,a1
	moveq	#WiSAuto/4-1,d0
WPrt4	move.l	(a0)+,(a1)+
	dbra	d0,WPrt4
	bsr	TAbk2
	movem.l	(sp),a0-a2/d1-d7
	jsr	(a0)
	move.l	d0,-(sp)
	bsr	TAbk3
	move.l	(sp)+,d0
	movem.l	(sp)+,a0-a2/d1-d7
	rts
* Single buffer
WPrt5	bsr	TAbk1
	movem.l	(sp),a0-a2/d1-d7
	jsr	(a0)
	move.l	d0,-(sp)
	bsr	TAbk4
	move.l	(sp)+,d0
	movem.l	(sp)+,a0-a2/d1-d7
	rts

***********************************************************
*	CENTRE chaine, finie par ZERO
*	A1= adresse chaine
***********************************************************
WCentre:movem.l	a4-a6,-(sp)
	lea	Circuits,a6
	move.l	T_EcCourant(a5),a4
	move.l	EcWindow(a4),a5
	move.l	a1,a0
	bsr	Compte
	move.w	WiTx(a5),d1
	sub.w	d0,d1
	lsr.w	#1,d1
	tst.w	EcAuto(a4)
	bne.s	ABCen
* Pas autob
	bsr	EffCur
	bsr	LocaX
	bsr	Prt
	movem.l	(sp)+,a4-a6
	tst.w	d0
	rts
* Autob
ABCen	lea	CPrt(pc),a0
	bsr	AutoPrt
	movem.l	(sp)+,a4-a6
	tst.w	d0
	rts
CPrt:	bsr	EffCur
	bsr	LocaX
	bra	Prt

*******	Calcul de l'adresse curseur
AdCurs:	move.w	WiY(a5),d0
	mulu	WiTLigne(a5),d0
	move.w	WiTx(a5),d1
	sub.w	WiX(a5),d1
	ext.l	d1
	add.l	d1,d0
	add.l	WiAdhg(a5),d0
	move.l	d0,WiAdCur(a5)
	rts

*******	Mode INTERIEUR
WiInt:	move.w	WiTxI(a5),WiTx(a5)
	move.w	WiTyI(a5),WiTy(a5)
	move.l	WiAdhgI(a5),WiAdhg(a5)
	rts

******* Mode EXTERIEUR
WiExt:	move.w	WiTxR(a5),WiTx(a5)
	move.w	WiTyR(a5),WiTy(a5)
	move.l	WiAdhgR(a5),WiAdhg(a5)
	rts

******* Compte la chaine de caracteres A0
*	D0 compte les caracteres IMPRIMES
*	A0 pointe la fin
Compte:	clr.w	d0
Copt1:	tst.b	(a0)
	beq.s	Copt2
	addq.w	#1,d0
	cmp.b	#27,(a0)+
	bne.s	Copt1
	subq.w	#1,d0
	addq.l	#2,a0
	bra.s	Copt1
Copt2:	addq.l	#1,a0
	rts

******* Blitter termine?
BltFini:bra	BlitWait

***********************************************************
*		AFFICHAGE D'UN CARACTERE
*		  DANS L'ECRAN LOGIQUE
*	- D1= caractere
*	- A6= chips
*	- A5= window
***********************************************************
COut:	movem.l	d1-d7/a0-a3,-(sp)
	and.w	#255,d1

******* Mode escape?
	tst.w	WiEsc(a5)
	bne	Esc

*******	Code de controle?
	cmp.w	#32,d1
	bcs	Cont
PaCont
*******	Affiche!
	lsl.w	#3,d1			;Pointe le caractere
	move.l	WiFont(a5),a2
	add.w	d1,a2

	move.w	WiNPlan(a5),d2		;Nombre de plans
	lea	EcCurrent(a4),a1
	move.l	WiAdCur(a5),d3		;Adresse du caractere
	move.w	EcTLigne(a4),d4
	ext.l	d4			;Taille d'une ligne

	move.w	WiFlags(a5),d7		;Flags d'ecriture
	bne	YaFlag

*-----* Pas de flag: rapide
	moveq	#-1,d6			;Pour CUn
	lea	WiColor(a5),a0		;Definition couleur
COut1:	move.l	(a0)+,a3
	jmp	(a3)

; Met a zero le plan
CZero:	move.l	(a1)+,a3
	add.l	d3,a3
	REPT	7			;Plan vide
	clr.b	(a3)
	add.l	d4,a3
	ENDR
	clr.b	(a3)
	dbra	d2,COut1
	bra	COutFin
CNul:	addq.l	#4,a1
	dbra	d2,COut1
	bra	COutFin
; Poke le caractere NORMAL
CNorm:	move.l	(a1)+,a3
	add.l	d3,a3
	REPT	7			;Poke l'octet
	move.b	(a2)+,(a3)
	add.l	d4,a3
	ENDR
	move.b	(a2),(a3)
	subq.l	#7,a2
	dbra	d2,COut1
	bra	COutFin
; Poke le caractere INVERSE
CInv:	move.l	(a1)+,a3
	add.l	d3,a3
	REPT 	7
	move.b	(a2)+,d0
	not.b	d0
	move.b	d0,(a3)
	add.l	d4,a3
	ENDR
	move.b	(a2),d0
	not.b	d0
	move.b	d0,(a3)
	subq.l	#7,a2
	dbra	d2,COut1
	bra	COutFin
; Poke du blanc
CUn:	move.l	(a1)+,a3
	add.l	d3,a3
	REPT	7
	move.b	d6,(a3)
	add.l	d4,a3
	ENDR
	move.b	d6,(a3)
	dbra	d2,COut1

;****** Un cran a droite
COutFin:addq.l	#1,WiAdCur(a5)
	subq.w	#1,WiX(a5)
	bne.s	COutS3
; A la ligne
	move.w	WiTx(a5),WiX(a5)
	move.w	WiY(a5),d0
	addq.w	#1,d0
	cmp.w	WiTy(a5),d0
	bcs.s	COutS2
	btst	#0,WiSys(a5)		;Scroll ON?
	beq.s	COutS1
; Scrolle!
	bsr	AdCurs
	bsr	ScHaut
	bra.s	COutS3
; Pas scrolle
COutS1:	clr.w	d0
COutS2:	move.w	d0,WiY(a5)
	bsr	AdCurs
COutS3:	moveq	#0,d0

******* Fini
COutOut:movem.l	(sp)+,d1-d7/a0-a3
	rts

******* Il y a des flags
YaFlag:	moveq	#-1,d6
	btst	#1,d7			;FLAG 1---> SHADE
	beq.s	YaF2
	move.w	#%1010101010101010,d6
YaF2:	lea	WiColFl(a5),a0
	move.l	a4,-(sp)
	move.l	d3,a3
	btst	#2,d7			;FLAG 2---> souligne
	bne.s	YaS5

; Non souligne
YaF5:	move.w	(a0)+,d5
	move.w	(a0)+,d7
	moveq	#7,d3
	move.l	(a1)+,a4
	add.l	a3,a4
	btst	d2,WiSys+1(a5)
	bne.s	YaF6a
YaF6:	move.b	(a2)+,d0
	and.b	d6,d0
	ror.w	#1,d6
	move.b	d0,d1
	not.b	d0
	and.b	d5,d0
	and.b	d7,d1
WGet1:	or.b	d1,d0
WMod1:	eor.b	d0,(a4)
	add.l	d4,a4
	dbra	d3,YaF6
	lea	-8(a2),a2
YaF6a:	dbra	d2,YaF5
	move.l	(sp)+,a4
	bra	COutFin

; Souligne
YaS5:	move.w	(a0)+,d5
	move.w	(a0)+,d7
	moveq	#6,d3
	move.l	(a1)+,a4
	add.l	a3,a4
	btst	d2,WiSys+1(a5)
	bne.s	YaS6a
YaS6:	move.b	(a2)+,d0
	and.b	d6,d0
	ror.w	#1,d6
	move.b	d0,d1
	not.b	d0
	and.b	d5,d0
	and.b	d7,d1
WGet2:	or.b	d1,d0
WMod2:	eor.b	d0,(a4)
	add.l	d4,a4
	dbra	d3,YaS6
; Souligne!
	move.b	d7,d0
	and.b	d6,d0
	ror.w	#1,d6
WMod3:	eor.b	d0,(a4)
	lea	-7(a2),a2
YaS6a:	dbra	d2,YaS5
	move.l	(sp)+,a4
	bra	COutFin

******* Codes de CONTROLE
Cont:	tst.w	WiGraph(a5)
	bne	PaCont
	lsl.w	#2,d1
	lea	CCont(pc),a0
	jsr	0(a0,d1.w)
	bra	COutOut

******* ESCAPE en marche

;-----> Mise en marche ESC
EscM:	move.w	#2,WiEsc(a5)
	moveq	#0,d0
Rien:	rts

;-----> ESC
Esc:	subq.w	#1,WiEsc(a5)
	beq.s	Esc1
	move.w	d1,WiEscPar(a5)
	bra	COutOut
Esc1:	move.w	WiEscPar(a5),d0
	cmp.w	#"Z",d0
	bhi.s	Esc2
	sub.w	#"A",d0
	bcs.s	Esc2
	lsl.w	#2,d0
	lea	CEsc(pc),a0
	sub.w	#"0",d1
	jsr	0(a0,d0.w)
Esc2:	movem.l	(sp)+,d1-d7/a0-a3
	tst.l	d0
	rts

***********************************************************
*	MESSAGES D'ERREUR
***********************************************************
PErr7:	moveq	#16,d0
	rts
WErr1:	moveq	#10,d0
	bra.s	WErr
WErr2:	moveq	#11,d0
	bra.s	WErr
WErr3:	moveq	#12,d0
	bra.s	WErr
WErr4:	moveq	#13,d0
	bra.s	WErr
WErr5:	moveq	#14,d0
	bra.s	WErr
WErr6:	moveq	#15,d0
	bra.s	WErr
WErr7:	moveq	#16,d0
	bra.s	WErr
WErr8:	moveq	#1,d0
	bra.s	WErr
WErr10:	moveq	#19,d0

* Erreurs generales
WErr:	move.l	d0,-(sp)
	cmp.l	EcWindow(a4),a5
	beq.s	WErF
	cmp.l	#0,a5
	beq.s	WErF
	move.l	a5,a1
	move.l	#WiLong,d0
	bsr	FreeMm
WErF:	move.l	(sp)+,d0
	movem.l	(sp)+,d1-d7/a1-a6
	rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	AMOS REQUESTER ROUTINES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Req_WY		equ	100
T_Tit		equ	0
T_Text		equ	T_Tit+80
T_Gad		equ	T_Text+320
T_Size		equ	T_Gad+128

;	Set request ON / OFF
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
WRequest_OnOff
	move.w	d0,T_ReqFlag(a5)
	rts

; - - - - - - - - - - - - -
AutoReq
; - - - - - - - - - - - - -
	movem.l	a0-a6/d0-d7,-(sp)
	bsr	Req_In
	bpl.s	.Skip
	bsr	Req_Auto
	bra	Req_AMOS
.Skip	move.l	T_PrevAuto(a5),T_ScAdr(a5)
	bra.s	Req_WB


; - - - - - - - - - - - - -
EasyReq
; - - - - - - - - - - - - -
	movem.l	a0-a6/d0-d7,-(sp)
	bsr	Req_In
	bpl.s	.Skip
	bsr	Req_Easy
	bra	Req_AMOS
.Skip	move.l	T_PrevEasy(a5),T_ScAdr(a5)
	bra.s	Req_WB

;	Dispatch requester between AMOS/WB
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Req_In	move.l	W_Base(pc),a5
	tst.b	T_AMOSHere+1(a5)	If AMOS / WB flipping running?
	bne.s	Req_ANo			...no requester at all!
	tst.w	T_ReqFlag(a5)		Ou aller?
	beq.s	Req_ANo
	bmi.s	.AMOS
; System requester?
; ~~~~~~~~~~~~~~~~~
	tst.b	WB_Closed(a5)		WB closed!
	bne.s	.AMOS
.WB	moveq	#1,d0
	rts
; AMOS requester
; ~~~~~~~~~~~~~~
.AMOS	tst.b	T_AMOSHere(a5)		AMOS here?
	beq.s	.WB
	tst.w	T_Req_On(a5)		Requester already running?
	bne.s	Req_ANo			Always no...
	moveq	#-1,d0
	rts

;	Always no!
; ~~~~~~~~~~~~~~~~
Req_ANo	addq.l	#4,sp
	movem.l	(sp)+,a0-a6/d0-d7
	moveq	#0,d0
	rts

;	WB requester
; ~~~~~~~~~~~~~~~~~~
Req_WB	move.b	T_AMOSHere(a5),d0	Is AMOS here?
	ext.w	d0
	move.w	d0,T_ReqOld(a5)
	beq.s	.skip1
	EcCalD	AMOS_WB,0		AMOS To BACK
.skip1	pea	.ret(pc)
	move.l	T_ScAdr(a5),-(sp)
	movem.l	8(sp),a0-a6/d0-d7
	rts
.ret	move.l	W_Base(pc),a5
	move.l	d0,T_Req_Pos(a5)
	move.l	d0,(sp)			en D0
	move.w	T_ReqOld(a5),d1
	beq.s	.skip2
	EcCalD	AMOS_WB,1		AMOS To FRONT
.skip2	movem.l	(sp)+,a0-a6/d0-d7	Recupere Req_Pos
	rts

;	AMOS Normal requester
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Req_AMOS
	move.w	#-1,T_Req_On(a5)	Requester ON !

	SyCall	AMALFrz
	bsr	UnMix1

	move.w	T_Req_Sx(a5),d2
	lsl.w	#3,d2
	ext.l	d2
	move.w	T_Req_Sy(a5),d3
	lsl.w	#3,d3
	ext.l	d3
	moveq	#3,d4
	move.l	#$8000,d5
	moveq	#8,d6
	moveq	#0,d7
	lea	Req_Pal(pc),a1
	EcCalD	Cree,EcReq
	bne	NoReq
	move.l	a0,T_ScAdr(a5)
	WiCalA	Print,Req_Init(pc)

; Top
; ~~~
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#4,d4
	moveq	#3*8,d5
	bsr	Copy
	moveq	#4,d0
	moveq	#1,d4
	move.w	T_Req_Sx(a5),d6
.lp1	bsr	Copy
	subq.w	#1,d6
	cmp.w	#9,d6
	bcc.s	.lp1
	moveq	#10,d0
	moveq	#4,d4
	bsr	Copy
; Middle
; ~~~~~~
	moveq	#3*8,d3
	move.w	T_Req_Sy(a5),d7
	sub.w	#6,d7
.lp2	moveq	#0,d0
	moveq	#3*8,d1
	moveq	#0,d2
	moveq	#2,d4
	moveq	#12,d5
	bsr	Copy
	moveq	#6,d0
	moveq	#1,d4
	move.w	T_Req_Sx(a5),d6
.lp3	bsr	Copy
	subq.w	#1,d6
	cmp.w	#5,d6
	bcc.s	.lp3
	moveq	#12,d0
	moveq	#2,d4
	bsr	Copy
	addq.w	#8,d3
	subq.w	#1,d7
	bne.s	.lp2
; Bottom
; ~~~~~~
	moveq	#0,d0
	moveq	#4*8+4,d1
	moveq	#0,d2
	add.w	#4,d3
	moveq	#1,d4
	moveq	#2*8+4,d5
	bsr	Copy
	moveq	#6,d0
	moveq	#1,d4
	move.w	T_Req_Sx(a5),d6
.lp4	bsr	Copy
	subq.w	#1,d6
	cmp.w	#3,d6
	bcc.s	.lp4
	moveq	#13,d0
	moveq	#1,d4
	bsr	Copy
; Bottom Left
; ~~~~~~~~~~~
	move.l	T_Req_Pos(a5),a0
.lp5	tst.b	(a0)+
	bne.s	.lp5
	sub.l	T_Req_Pos(a5),a0
	move.w	a0,d6
	moveq	#1,d0
	moveq	#4*8+4,d1
	moveq	#1,d2
	moveq	#2,d4
	moveq	#2*8,d5
	bsr	Copy
	moveq	#3,d0
	moveq	#1,d4
	subq.w	#3+1,d6
	bmi.s	.sk2
.lp6	bsr	Copy
	dbra	d6,.lp6
.sk2	moveq	#4,d0
	moveq	#2,d4
	bsr	Copy
; Bottom right
; ~~~~~~~~~~~~
	move.l	T_Req_Neg(a5),d0
	move.l	d0,a0
	beq.s	.sk1
.lp7	tst.b	(a0)+
	bne.s	.lp7
	sub.l	T_Req_Neg(a5),a0
	move.w	a0,d6
	move.w	T_Req_Sx(a5),d0
	sub.w	a0,d0
	add.b	#48-1,d0
	move.l	a1,-(sp)
	lea	XTNeg(pc),a1
	move.b	d0,(a1)
	move.l	(sp)+,a1
	moveq	#8,d0
	moveq	#4*8+4,d1
	move.w	T_Req_Sx(a5),d2
	sub.w	d6,d2
	subq.w	#2,d2
	moveq	#2,d4
	moveq	#2*8,d5
	bsr	Copy
	moveq	#10,d0
	moveq	#1,d4
	subq.w	#3+1,d6
	bmi.s	.sk3
.lp8	bsr	Copy
	dbra	d6,.lp8
.sk3	moveq	#11,d0
	moveq	#2,d4
	bsr	Copy
.sk1
; End of init
; ~~~~~~~~~~~
	SyCalD	ResZone,2
	move.w	T_Req_Sy(a5),d0
	lsl.w	#3,d0
	move.w	d0,T_Req_Sy(a5)

; Initialise background text
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	WiCalA	Centre,T_Tit(a4)
; Print main text
; ~~~~~~~~~~~~~~~
	WiCalA	Print,Req_Main(pc)
	lea	T_Text(a4),a1
.lop	move.l	a1,-(sp)
	WiCall	Centre
	move.l	(sp)+,a1
.lop1	tst.b	(a1)+
	bne.s	.lop1
	tst.b	(a1)
	bne.s	.lop
; Positive text (left)
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#1,d0
	moveq	#"0",d1
	bsr	PrtZone
; Negative text (right)
; ~~~~~~~~~~~~~~~~~~~~~
	move.l	T_Req_Neg(a5),d0
	beq.s	.NoNeg
	move.l	d0,a0
	moveq	#2,d0
	moveq	#"0",d1
	bsr	PrtZone
; Screen appearance
; ~~~~~~~~~~~~~~~~~
.NoNeg	move.l	T_ScAdr(a5),a2
	move.w	#288,d0
	move.w	T_Req_Sx(a5),d1
	lsl.w	#1,d1
	sub.w	d1,d0
	move.w	d0,EcAWX(a2)
	bset	#1,EcAW(a2)
	moveq	#8,d7
	moveq	#1,d6
	move.w	T_Req_Sy(a5),d5
	lsr.w	#1,d5
	add.w	#Req_WY,d5
	bsr	AppCentre
; State of disc drive
; ~~~~~~~~~~~~~~~~~~~
	SyCall	GetDisc
	move.w	d0,T_DOld(a5)

;	Test loop (fun!)
; ~~~~~~~~~~~~~~~~~~~~~~
ReqLoop
	bsr	UnMix2
	move.l	a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	-270(a6)		WaitTOF
	move.l	(sp)+,a6
	bsr	UnMix1

; Automatic disc change
; ~~~~~~~~~~~~~~~~~~~~~
	move.l	T_Req_IDCMP(a5),d0
	btst	#15,d0
	beq.s	NoAuto
	SyCall	GetDisc
	cmp.w	T_DOld(a5),d0
	beq.s	NoAuto
	move.w	d0,T_DOld(a5)
	bne	ReqYes
; Keyboard
; ~~~~~~~~
NoAuto	SyCall	Inkey
	cmp.w	#13,d1		* ASCII-> Return
	beq.s	ReqYes
	cmp.w	#27,d1		* ASCII-> ESC
	beq.s	ReqNo
; Don't you think it is better than this wierd Amiga V and B?
; Sometime I ask myself what they were thinking when they chose such
; key combinations!
	swap	d1
	move.w	d1,d0		* Isolate AMIGA keys
	and.w	#%1100000000000000,d0
	beq.s	RqL0
	cmp.b	#$34,d1		* V
	beq.s	ReqYes
	cmp.b	#$35,d1		* B
	beq.s	ReqNo
; Mouse pointer
; ~~~~~~~~~~~~~
RqL0	SyCall	GetZone
	cmp.w	#EcReq,d1
	beq.s	RqL1
	moveq	#0,d1
RqL1:	swap 	d1
	cmp.w	d7,d1
	beq.s	RqL2
	move.w	d7,d0
	move.w	d1,d7
	moveq	#"0",d1
	bsr	PrtZone
RqL2:	move.w	d7,d0
	moveq	#"1",d1
	bsr	PrtZone
	tst.w	d7
	beq	ReqLoop
	SyCall	MouseKey
	tst.w	d1
	beq	ReqLoop
	cmp.w	#2,d7
	beq.s	ReqNo
ReqYes	moveq	#-1,d0
	bra.s	ReqGo
ReqNo	moveq	#0,d0

;	End of screen (well done!!!)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ReqGo	move.l	d0,-(sp)
	move.l	T_ScAdr(a5),a2
	moveq	#-8,d7
	move.w	EcTy(a2),d6
	lsr.w	#1,d6
	move.w	T_Req_Sy(a5),d5
	lsr.w	#1,d5
	add.w	#Req_WY,d5
	bsr	AppCentre
	EcCalD	Del,EcReq

;	Back to system!
; ~~~~~~~~~~~~~~~~~~~~~
ReqX	bsr	UnMix2
	bsr	ClrData
	SyCall	AMALUFrz
	move.l	(sp)+,T_Req_Pos(a5)	* Returns answer
	clr.w	T_Req_On(a5)		* No more requester
; Normal exit
; ~~~~~~~~~~~
ReqXX	move.l	T_Req_Pos(a5),(sp)	ReqPos>>> D0
	movem.l	(sp)+,a0-a6/d0-d7
	rts
;	Can't open screen!!!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
NoReq	clr.l	-(sp)
	bra.s	ReqX

;	Print a zone D0-> zone, D1-> inverse or not
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PrtZone	subq.w	#1,d0
	bmi.s	PrtX
	bne.s	PrtNeg
; Print pos text
; ~~~~~~~~~~~~~~
PrtPos	tst.l	T_Req_Pos(a5)
	beq.s	.skip
	lea	TPos1(pc),a1
	move.b	d1,8(a1)
	WiCall	Print
	move.l	T_Req_Pos(a5),a1
	WiCall	Print
	WiCalA	Print,TPos2(pc)
.skip	bra.s	PrtX
; Print neg text
; ~~~~~~~~~~~~~~
PrtNeg	tst.l	T_Req_Neg(a5)
	beq.s	.skip
	lea	TNeg1(pc),a1
	move.b	d1,8(a1)
	WiCall	Print
	move.l	T_Req_Neg(a5),a1
	WiCall	Print
	WiCalA	Print,TNeg2(pc)
.skip
PrtX	rts

;	Screen appearance
; ~~~~~~~~~~~~~~~~~~~~~~~
AppCentre:
	move.w	d6,d4
	move.w	d6,EcAWTY(a2)
	add.w	d6,EcAWTY(a2)
	bset	#2,EcAWT(a2)
	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	sub.w	d6,d0
	move.w	d0,EcAVY(a2)
	bset	#2,EcAV(a2)
	move.w	d5,EcAWY(a2)
	sub.w	d6,EcAWY(a2)
	bset	#2,EcAW(a2)
	movem.l	a2/d4-d7,-(sp)
	SyCall	WaitVbl
	EcCall	CopForce
	movem.l	(sp)+,a2/d4-d7
	add.w	d7,d6
	bpl.s	FsApp2
	clr.w	d6
FsApp2:	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	cmp.w	d0,d6
	bcs.s	FsApp3
	move.w	d0,d6
FsApp3:	cmp.w	d4,d6
	bne.s	AppCentre
	rts

;	Prevent mixes between AMOS and the requester!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
UnMix1	movem.l	d0-d7/a0-a6,-(sp)
	move.l	$4.w,a6
	jsr	Forbid(a6)
	EcCall	Current
	move.w	EcNumber(a0),d1
	move.w	d1,T_ReqOldScreen(a5)
	EcCalD	Active,EcReq
	EcCalD	First,EcReq
	EcCall	CopMake
	SyCall	WaitVbl
	movem.l	(sp)+,d0-d7/a0-a6
	rts
UnMix2	movem.l	d0-d7/a0-a6,-(sp)
	move.w	T_ReqOldScreen(a5),d1
	EcCall	Active
	move.l	$4.w,a6
	jsr	Permit(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;	Open TEXT data zone
; ~~~~~~~~~~~~~~~~~~~~~~~~~
ResData	move.l	#T_Size,d0
	SyCall	SyFast
	move.l	d0,a4
	rts
;	Clear TEXT data zone
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
ClrData	move.l	#T_Size,d0
	move.l	a4,a1
	SyCall	SyFree
	rts

;	WB1.3 requester entry
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Req_Auto

	bsr	ResData

	move.l	#$00008000,T_Req_IDCMP(a5)

	lsr.w	#3,d2
	addq.w	#3,d2
	and.w	#$FFFC,d2
	move.w	d2,T_Req_Sx(a5)
	lsr.w	#3,d3
	addq.w	#2,d3
	move.w	d3,T_Req_Sy(a5)

	move.l	a1,a0
	lea	T_Text(a4),a1
	moveq	#10,d0
	bsr	IT_Print

	clr.l	T_Req_Pos(a5)
	lea	T_Gad(a4),a1
	move.l	a2,d0
	move.l	d0,a0
	beq.s	.skip1
	move.l	a1,T_Req_Pos(a5)
	moveq	#0,d0
	bsr	IT_Print
.skip1
	clr.l	T_Req_Neg(a5)
	lea	T_Gad+64(a4),a1
	move.l	a3,d0
	move.l	d0,a0
	beq.s	.skip2
	move.l	a1,T_Req_Neg(a5)
	moveq	#0,d0
	bsr	IT_Print
.skip2
	lea	Req_Tit(pc),a0
	lea	T_Tit(a4),a1
.loop	move.b	(a0)+,(a1)+
	bne.s	.loop
	rts

;	WB2.0 Requester entry
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Req_Easy
	bsr	ResData
	move.l	(a2),T_Req_IDCMP(a5)

	lea	8(a1),a2
	clr.w	T_TxtMaxCx(a5)

	lea	T_Tit(a4),a1
	move.l	(a2)+,d0
	move.l	d0,a0
	bne.s	.nof
	lea	Req_Tit(pc),a0
.nof	bsr	Format

	move.l	(a2)+,a0
	lea	T_Text(a4),a1
	bsr	Format
	move.w	T_TxtCy(a5),T_Req_Sy(a5)

	move.l	(a2)+,a0
	lea	T_Gad(a4),a1
	bsr	Format

	lea	T_Gad(a4),a0
	move.l	a0,T_Req_Pos(a5)
	clr.l	T_Req_Neg(a5)
.loop	move.b	(a0)+,d0
	beq.s	.skp
	cmp.b	#"|",d0
	bne.s	.loop
	clr.b	-1(a0)
	move.l	a0,T_Req_Neg(a5)
.skp
	move.w	T_TxtMaxCx(a5),d0
	cmp.w	#32,d0
	bcc.s	.skp2
	moveq	#32,d0
.skp2	add.w	#9,d0
	and.w	#$FFFC,d0
	move.w	d0,T_Req_Sx(a5)

	addq.w	#8,T_Req_Sy(a5)
	rts

;	Call RawDoFmt
; ~~~~~~~~~~~~~~~~~~~
Format	clr.w	T_TxtCx(a5)
	move.w	#1,T_TxtCy(a5)
	movem.l	a2/a3/a6,-(sp)
	exg	a3,a1
	lea	.OutC(pc),a2
	move.l	$4.w,a6
	jsr	-522(a6)
	exg	a3,a1
	movem.l	(sp)+,a2/a3/a6
.XMax	move.w	T_TxtCx(a5),d0
	cmp.w	T_TxtMaxCx(a5),d0
	bls.s	.sk
	move.w	d0,T_TxtMaxCx(a5)
.sk	rts
.OutC	movem.l	d0/a5,-(sp)
	move.l	W_Base(pc),a5
	addq.w	#1,T_TxtCx(a5)
	move.b	d0,(a3)+
	cmp.b	#10,d0
	bne.s	.Skip
	clr.b	(a3)+
	addq.w	#1,T_TxtCy(a5)
	bsr.s	.XMax
	clr.w	T_TxtCx(a5)
.Skip	movem.l	(sp)+,d0/a5
	clr.b	(a3)
	rts

;	Copy an intuitext into the buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0-> ITEXT
;	A1-> Buffer
;	D0-> Mettre un 10 a la fin...
IT_Print
	movem.l	a0-a2/d0-d1,-(sp)
.loop	move.l	12(a0),d1
	move.l	d1,a2
	beq.s	.skip
.loop1	move.b	(a2)+,(a1)+
	bne.s	.loop1
	tst.w	d0
	beq.s	.skip
	move.b	d0,-1(a1)
	clr.b	(a1)+
.skip	move.l	16(a0),d1
	move.l	d1,a0
	bne.s	.loop
	movem.l	(sp)+,a0-a2/d0-d1
	rts

;	Routine: copy the binary data
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Copy	movem.l	d0-d7/a0-a5,-(sp)
	mulu	#RPic_Sx/8,d1			d1= offset source
	add.l	d1,d0
	lea	RPic(pc),a0			a0= adress source
	move.w	T_Req_Sx(a5),d1
	ext.l	d1				d1= size of dest line
	mulu	d1,d3
	add.l	d2,d3				d3= offset dest
	move.l	T_ScAdr(a5),a3			a3= dest screen
	subq.w	#1,d4
	subq.w	#1,d5
	move.w	#RPic_Np-1,d2
.loop1	move.l	(a3)+,a4
	add.l	d3,a4
	move.l	a0,a1
	add.l	d0,a1
	move.w	d5,d7
.loop2	move.w	d4,d6
	move.l	a1,a2
	move.l	a4,a5
.loop3	move.b	(a2)+,(a5)+
	dbra	d6,.loop3
	add.w	#RPic_Sx/8,a1
	add.l	d1,a4
	dbra	d7,.loop2
	add.w	#(RPic_Sx/8)*RPic_Sy,a0
	dbra	d2,.loop1
	movem.l	(sp)+,d0-d7/a0-a5
	add.w	d4,d2
	rts

;--------------------------------------------------------------------
*		DATA ZONE

* 		Title
Req_Tit		dc.b "System request",0
Req_Init	dc.b 27,"C0",27,"V0",27,"Y1",27,"B2",27,"P7",0
*		Main text
Req_Main	dc.b 27,"B2",27,"P3",27,"Y4",0
* 		Positive text
TPos1		dc.b 27,"B4",27,"P3",27,"I0",24,30,30,27,"X2",27,"Z0",0
TPos2		dc.b 27,"Z1",0
* 		Negative text
TNeg1		dc.b 27,"B4",27,"P3",27,"I0",24,30,30,27,"X"
XTNeg		dc.b "0",27,"Z0",0
TNeg2		dc.b 27,"Z2",0
		even
; 		Insertion de l'image de fond
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
RPic_Sx		equ	112
RPic_Sy		equ	56
RPic_Np		equ	3
Req_Pal		Incbin	"bin/ReqPic.bin"
RPic		equ	Req_Pal+32*2
		even


***********************************************************



***********************************************************
*		Table des codes de CONTROLE
***********************************************************
CCont:		bra	Rien		;0
		bra	Rien		;1
		bra	Rien		;2
		bra	Rien		;3
		bra	Rien		;4
		bra	Rien		;5
		bra	Rien		;6
		bra	ClEol		;7-  Clear to EOL
		bra	CLeft		;8-  Backspace
		bra	Tab		;9-  Tab
		bra	CDown		;10- Curseur bas
		bra	Rien		;11
		bra	Home		;12- Home
		bra	CReturn		;13- A la ligne
		bra	Rien		;14
		bra	Rien		;15-
		bra	ScGLine		;16- Scrolling gauche ligne curseur
		bra	ScGWi		;17- Scrolling gauche fenetre
		bra	ScDLine		;18- Scrolling droite ligne curseur
		bra	ScDWi		;19- Scrolling droite fenetre
		bra	ScBas		;20
		bra	ScBasHaut	;21
		bra	ScHaut		;22
		bra	ScHautBas	;23
		bra	Home		;24
		bra	Clw		;25
		bra	ClLine		;26
		bra	EscM		;27- ESCAPE
		bra	CRight		;28
		bra	CLeft		;29
		bra	CUp		;30
		bra	CDown		;31

***********************************************************
*		Table des ESCAPES
***********************************************************

CEsc:		bra	Rien		;A
		bra	Paper		;B- Paper
		bra	Curs		;C- Curseur OFF/ON
		bra	CurCol		;D- Couleur du curseur
		bra	Encadre		;E- Encadre!
		bra	Rien		;F
		bra	Rien		;G
		bra	Rien		;H
		bra	Inv		;I- Inverse on/off
		bra	Planes		;J- Set active planes
		bra	ChgCar		;K- 0/1 jeu normal/graphique
		bra	Rien		;L
		bra	MemoCu		;M- Memorise le curseur
		bra	DecaX		;N- Decalage curseur X
		bra	DecaY		;O- Decalage curseur Y
		bra	Pen		;P- Pen
		bra	RazCur		;Q- Efface N caracteres
		bra	Repete		;R- Repeter
		bra	Shade		;S- Shade on/off
		bra	SetTab		;T- Set Tab
		bra	Under		;U- Underline on/off
		bra	Scroll		;V- Scroll on/off
		bra	Writing		;W- Writing
		bra	LocaX		;X- Fixe X
		bra	LocaY		;Y- Fixe Y
		bra	WiZone		;Z- Stocke une zone

***********************************************************
*		Bordures
***********************************************************

Brd:		dc.w Bor0-Brd,Bor1-Brd,Bor2-Brd,Bor3-Brd
		dc.w Bor4-Brd,Bor5-Brd,Bor0-Brd,Bor0-Brd
		dc.w Bor0-Brd,Bor0-Brd,Bor0-Brd,Bor0-Brd
		dc.w Bor0-Brd,Bor0-Brd,Bor0-Brd,Bor15-Brd
		dc.b 0
Bor0:		dc.b 136,0		* Haut G
		dc.b 138,0		* Haut D
		dc.b 137,0		* Haut
		dc.b 139,0		* Droite
		dc.b 140,0		* Bas G
		dc.b 141,0		* Bas D
		dc.b 137,0		* Bas
		dc.b 139,0		* Gauche
Bor1:		dc.b 128,0		* Haut G
		dc.b 130,0		* Haut D
		dc.b 129,0		* Haut
		dc.b 132,0		* Droite
		dc.b 133,0		* Bas G
		dc.b 135,0		* Bas D
		dc.b 134,0		* Bas
		dc.b 131,0		* Gauche
Bor2:		dc.b 157,0		* Haut G
		dc.b 2,0		* Haut D
		dc.b 1,0		* Haut
		dc.b 3,0		* Droite
		dc.b 6,0		* Bas G
		dc.b 4,0		* Bas D
		dc.b 5,0		* Bas
		dc.b 7,0		* Gauche
Bor3:		dc.b 8,0		* Haut G
		dc.b 10,0		* Haut D
		dc.b 9,0		* Haut
		dc.b 11,0		* Droite
		dc.b 14,0		* Bas G
		dc.b 12,0		* Bas D
		dc.b 13,0		* Bas
		dc.b 15,0		* Gauche
Bor4:		dc.b 16,0		* Haut G
		dc.b 18,0		* Haut D
		dc.b 17,0		* Haut
		dc.b 19,0		* Droite
		dc.b 22,0		* Bas G
		dc.b 20,0		* Bas D
		dc.b 21,0		* Bas
		dc.b 23,0		* Gauche
Bor5:		dc.b 24,0		* Haut G
		dc.b 26,0		* Haut D
		dc.b 25,0		* Haut
		dc.b 158,0		* Droite
		dc.b 30,0		* Bas G
		dc.b 28,0		* Bas D
		dc.b 29,0		* Bas
		dc.b 31,0		* Gauche
Bor15		dc.b " ",0
		dc.b " ",0
		dc.b " ",0
		dc.b " ",0
		dc.b " ",0
		dc.b " ",0
		dc.b " ",0
		dc.b " ",0
		even

***********************************************************
*		CODE AMOS HERE?
BufCode		dc.w	0
		dc.b	"I"+$60
		dc.b	"S"+$60
		dc.b	" "+$60
		dc.b	"A"+$60
		dc.b	"M"+$60
		dc.b	"O"+$60
		dc.b	"S"+$60
		dc.b	" "+$60
		dc.b	"H"+$60
		dc.b	"E"+$60
		dc.b	"R"+$60
		dc.b	"E"+$60
		dc.b 	0

***********************************************************
*		FONCTIONS ESCAPES
***********************************************************

		dc.b 32,32,32,32,32,32,32,32
TEncadre:	dc.b 136,137,138,139,141,137,140,139
		dc.b 128,129,130,132,135,134,133,131
		dc.b 157,1,2,3,4,5,6,7
		dc.b 8,9,10,11,12,13,14,15
		dc.b 16,17,18,19,20,21,22,23
		dc.b 24,25,26,158,28,29,30,31
		dc.b 32,32,32,32,32,32,32,32

***********************************************************
*		CURSEUR TEXTE
***********************************************************
DefCurs:	dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %11111111
		dc.b %11111111
		dc.w 0

	IFNE	EzFlag
TokAMAL
CreAMAL
MvOAMAL
DAllAMAL
Animeur
RegAMAL
ClrAMAL
FrzAMAL
UFrzAMAL
SpColl
SyncO
Sync
SetPlay
HColSet
HColGet
TMovon
TChanA
TChanM

ShStop
ShStart
MakeCBloc
DrawCBloc
FreeCBloc
RazCBloc
Duale
DualP
StaMn
StoMn
TCopOn
TCopRes
TCopSw
TCopWt
TCopMv
TCopMl
TCopBs

DAdAMAL
AMALInit
AMALEnd
ShInit
	rts

	ENDC

;		Banque MOUSE.ABK par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		SECTION	"m",DATA_C
		IncBin	"bin/+AMOSPro_Mouse.abk"

		even
