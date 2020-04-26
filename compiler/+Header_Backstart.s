**********************************************************************
*
*  Published under the MIT Licence
*
*  Copyright (c) 1992 Europress Software
*  Copyright (c) 2020 Francois Lionet
*
*  Permission is hereby granted, free of charge, to any person
*  obtaining a copy of this software and associated documentation
*  files (the "Software"), to deal in the Software without
*  restriction, including without limitation the rights to use,
*  copy, modify, merge, publish, distribute, sublicense, and/or
*  sell copies of the Software, and to permit persons to whom the
*  Software is furnished to do so, subject to the following
*  conditions:
*
*  The above copyright notice and this permission notice shall be
*  included in all copies or substantial portions of the Software.
*
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
*  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
*  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
*  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
*  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
*  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
*  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
**********************************************************************
*
*	HEADER BACKSTART Programme compile
*
*	Ne pas changer le fichier sans verifier que c'est multiple
*	de 8
*
**********************************************************************
*
	dc.w	FinBack-DebBack
*
DebBack	move.l	#0,d2
	move.l	#0,d3
BackStart
	lea	DebPrg(pc),a4
	move.l	a4,Header_DebPrg-DebPrg(a4)
; Recopie les parametres
	move.l	d2,ComD2-DebPrg(a4)
	move.l	d3,ComD3-DebPrg(a4)
; Recopie la ligne de commande
	cmp.w	#256,d0
	bcs.s	.skip
	move.w	#255,d0
.skip	move.w	d0,ComLong-DebPrg(a4)
	lea	ComLine-DebPrg(a4),a1
	subq.w	#1,d0
	bmi.s	.loopX
.loop	move.b	(a0)+,(a1)+
	dbra	d0,.loop
.loopX
; CLI ou WORKBENCH?
	move.l	$4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,a0
	tst.l	$ac(a0)
	beq	DDebPrg

; 	Ca vient du CLI: RUN BACK
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CliBack	bset	#FHead_Backed,ComD2+3-DebPrg(a4)
; Ouvre le DOS
	moveq	#0,d0
	lea	DosName(pc),a1
	jsr	OpenLib(a6)
	move.l	d0,a6
	tst.l	d0
	beq.s	BackX
; Coupe les segments
	lea	DDebPrg-8(pc),a2
	move.l	a2,a1
	lea	DebBack-8(pc),a0
	move.l	4(a0),4(a2)
	clr.l	4(a0)
	sub.l	a0,a1
	move.l	(a0),d0
	move.l	a1,(a0)
	sub.l	a1,d0
	move.l	d0,(a2)
; Adresse du debut du hunk
	addq.l	#4,a2
	move.l	a2,d3
	addq.l	#4,a2
	move.l	a2,Header_DebPrg-DebPrg(a4)
; Fait d�marrer le processus
	lsr.l	#2,d3		Segments...
	moveq	#0,d2
	lea	FoNom(pc),a0
	move.l	a0,d1		Faux nom...
	move.l	#4096,d4	Taille de pile...
	jsr	-138(a6)	Create Proc!
; Ferme le DOS
	move.l	a6,a1
	move.l	$4.w,a6
	jsr	CloseLib(a6)
; Fini!
BackX	moveq	#0,d0
	rts
;---------------------------------------------------------------------
	dc.l	0
	ds.l	2
;---------------------------------------------------------------------
DDebPrg	lea	ComLine(pc),a0
	move.w	ComLong(pc),d0
	lea	DebPrg(pc),a4
	move.l	ComD2(pc),d2
	move.l	ComD3(pc),d3
	bsr.s	BackIn
	move.l	$4.w,a6
	jsr	Forbid(a6)
	lea	DDebPrg-4(pc),a1
	move.l	-(a1),d0
	jsr	FreeMem(a6)
	moveq	#0,d0
	rts
;---------------------------------------------------------------------
	Include	"+Header.s"
;---------------------------------------------------------------------
ComLong	dc.w	0
ComLine	ds.b	256
ComD2	dc.l	0
ComD3	dc.l	0
FoNom	dc.b	"Backstart",0
	even
;---------------------------------------------------------------------
FinBack	dc.w	0
