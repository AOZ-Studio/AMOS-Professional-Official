;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; AMOSPro Picture compactor extension source code,
; By Fran�ois Lionet
; AMOS, AMOSPro and AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOS1.3 and over
;---------------------------------------------------------------------
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
;---------------------------------------------------------------------
; Please refer to the _Music.s file for more informations
;---------------------------------------------------------------------

ExtNb		equ	2-1

;---------------------------------------------------------------------
;		Include the files automatically calculated by
;		Library_Digest.AMOS
;---------------------------------------------------------------------
		Include	"+Compact_Size.s"
		Include	"+Compact_Labels.s"
 		Include	"+AMOS_Includes.s"
		Include	"+Version.s"
Start		dc.l	C_Tk-C_Off
		dc.l	C_Lib-C_Tk
		dc.l	C_Title-C_Lib
		dc.l	C_End-C_Title
		dc.w	0
		dc.b	"AP20"

;---------------------------------------------------------------------
;		Creates the pointers to functions
;---------------------------------------------------------------------
		MCInit
C_Off
		REPT	Lib_Size
		MC
		ENDR

***********************************************************
* 		COMPACTOR TOKENS

;		TOKEN_START
C_Tk		dc.w 	1,0
		dc.b 	$80,-1
		dc.w 	L_InPack2,L_Nul
		dc.b 	"!pac","k"+$80,"I0t0",-2
		dc.w	L_InPack6,L_Nul
		dc.b	$80,"I0t0,0,0,0,0",-1
		dc.w 	L_InSPack2,L_Nul
		dc.b 	"!spac","k"+$80,"I0t0",-2
		dc.w	L_InSPack6,L_Nul
		dc.b	$80,"I0t0,0,0,0,0",-1
		dc.w	L_InUnpack1,L_Nul
		dc.b	"!unpac","k"+$80,"I0",-2
		dc.w 	L_InUnpack2,L_Nul
		dc.b	$80,"I0t0",-2
		dc.w 	L_InUnpack3,L_Nul
		dc.b	$80,"I0,0,0",-1
;		TOKEN_END
		dc.w 	0
		dc.l	0			Important!


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	THE LIBRARY
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;---------------------------------------------------------------------
	Lib_Ini	0
;---------------------------------------------------------------------

C_Lib

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	COLD START
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Compact_Cold
; - - - - - - - - - - - - -
	cmp.l	#"APex",d1		Version 1.10 or over?
	bne.s	BadVer
	moveq	#ExtNb,d0		* Extension number
	move.w	#$0110,d1		* Current version
	rts
; In case this extension is runned on AMOSPro V1.00
BadVer	moveq	#-1,d0			* Bad version number
	sub.l	a0,a0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ONE EMPTY SPACE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Empty
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PACK Screen,Bank#
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPack2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	clr.l	-(a3)
	clr.l	-(a3)
	move.l	#10000,d3
	move.l	d3,-(a3)
	Rbra	L_InPack6

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PACK Screen,Bank#
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPack6
; - - - - - - - - - - - - -
	Rbsr	L_PacPar
	Rbsr	L_GetSize
	Rbsr	L_ResBank
	Rbsr	L_Pack
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SPACK Screen,Bank#
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSPack2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	clr.l	-(a3)
	clr.l	-(a3)
	move.l	#10000,d3
	move.l	d3,-(a3)
	Rbra	L_InSPack6

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SPACK Screen,Bank#,X1,Y1 TO X2,Y2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSPack6
; - - - - - - - - - - - - -
	Rbsr	L_PacPar
	Rbsr	L_GetSize
	add.l	#PsLong,d0
	Rbsr	L_ResBank
* Screen definition header
	move.l	#SCCode,(a1)
	move.w	EcTx(a0),PsTx(a1)
	move.w	EcTy(a0),PsTy(a1)
	move.w	EcNbCol(a0),PsNbCol(a1)
	move.w	EcNPlan(a0),PsNPlan(a1)
	move.w	EcCon0(a0),PsCon0(a1)
	move.w	EcAWX(a0),PsAWx(a1)
	move.w	EcAWY(a0),PsAWy(a1)
	move.w	EcAWTX(a0),PsAWTx(a1)
	move.w	EcAWTY(a0),PsAWTy(a1)
	move.w	EcAVX(a0),PsAVx(a1)
	move.w	EcAVY(a0),PsAVy(a1)
	movem.l	a0/a1,-(sp)
	moveq	#31,d0
	lea	EcPal(a0),a0
	lea	PsPal(a1),a1
SPac1	move.w	(a0)+,(a1)+
	dbra	d0,SPac1
	movem.l	(sp)+,a0/a1
	lea	PsLong(a1),a1
* Finish packing!
	Rbsr	L_Pack
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	UNPACK Bank# 		-> To current screen
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InUnpack1
; - - - - - - - - - - - - -
	move.l	ScOnAd(a5),d0
	Rbeq	L_JFoncall
	move.l	d0,a1
	moveq	#-1,d1
	moveq	#-1,d2
	move.l	d3,d0
	Rbra	L_UPack

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	UNPACK Bank#,X,Y	-> To current screen
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InUnpack3
; - - - - - - - - - - - - -
	move.l	ScOnAd(a5),d0
	Rbeq	L_JFoncall
	move.l	d0,a1
	move.l	d3,d2
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbra	L_UPack

; - - - - - - - - - - - - -
	Lib_Def	UPack
; - - - - - - - - - - - - -
	movem.l	d1/a1,-(sp)
	Rjsr	L_Bnk.OrAdr
	movem.l	(sp)+,d1/a1
* Autoback
	tst.w	EcAuto(a1)		* Is screen autobacked?
	bne.s	.Dbl
	Rjsr	L_UnPack_Bitmap		* NOPE! Do simple unpack
	Rbeq	L_NoPac
	rts
.Dbl	movem.l	d0-d7/a0-a2,-(sp)	* YEP! First step
	EcCall	AutoBack1
	movem.l	(sp),d0-d7/a0-a2
	btst	#BitDble,EcFlags(a1)	* DOUBLE BUFFER?
	beq.s	ABPac1
	Rjsr	L_UnPack_Bitmap
	EcCall	AutoBack2		* Second step
	movem.l	(sp),d0-d7/a0-a2
	Rjsr	L_UnPack_Bitmap
	move.w	d0,-(sp)
	EcCall	AutoBack3		* Third step
	bra.s	ABPac2
ABPac1	Rjsr	L_UnPack_Bitmap		* SINGLE BUFFER autobacked
	move.w	d0,-(sp)
	EcCall	AutoBack4
ABPac2	tst.w	(sp)+
	movem.l	(sp)+,d0-d7/a0-a2
	Rbeq	L_NoPac
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	UNPACK Bank# TO screen	-> Creates/Erases screen!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InUnpack2
; - - - - - - - - - - - - -
	move.l	(a3)+,d0		Get bank address
	Rjsr	L_Bnk.OrAdr
	move.l	d3,d0			Get screen number
	Rjsr	L_UnPack_Screen		Performs unpacking
	tst.w	d0
	beq.s	.Err
	move.l	a0,ScOnAd(a5)		Branch new screen into AMOS
	move.w	EcNumber(a0),ScOn(a5)
	addq.w	#1,ScOn(a5)
	rts
.Err	tst.w	d1
	Rbeq	L_NoPac
	Rjmp	L_OOfMem

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Reserves memory bank, A1= number
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	ResBank
; - - - - - - - - - - - - -
	movem.l	a0/d1/d2,-(sp)
	move.l	d0,d2
	moveq	#(1<<Bnk_BitData),d1
	move.l	a1,d0
	lea	BkPac(pc),a0
	Rjsr	L_Bnk.Reserve
	Rbeq	L_JOOfMem
	move.l	a0,a1
	movem.l	(sp)+,a0/d1/d2
	rts
; Definition packed picture bank
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BkPac:	dc.b "Pac.Pic."
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Unpile parameters
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	PacPar
; - - - - - - - - - - - - -
	move.l	d3,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	lsr.w	#3,d4
	lsr.w	#3,d2
* Screen
	move.l	4(a3),d1
	Rjsr	L_GetEc
	move.l	d0,a2
	cmp.w	EcTLigne(a0),d4
	bls.s	PacP1
	move.w	EcTLigne(a0),d4
PacP1	cmp.w	EcTy(a0),d5
	bls.s	PacP2
	move.w	EcTy(a0),d5
PacP2	sub.w	d2,d4
	Rble	L_JFoncall
	sub.w	d3,d5
	Rble	L_JFoncall
; Number of memory bank
	move.l	(a3)+,a1
	cmp.l	#$10000,a1
	Rbcc	L_JFoncall
	addq.l	#4,a3
	rts


***************************************************************************
*
*       BITMAP COMPACTOR
*                       A0: Origin screen datas
*                       A1: Destination zone
*			A2: Origin screen bitmap
*                       D2: DX in BYTES
*                       D3: DY in LINES
*                       D4: TX in BYTES
*                       D5: TY in LINES
*
***************************************************************************
* 	ESTIMATE THE SIZE OF A PICTURE

******* Makes differents tries
*	And finds the best square size in D1
; - - - - - - - - - - - - -
	Lib_Def	GetSize
; - - - - - - - - - - - - -
	movem.l	a1-a3/d6-d7,-(sp)
	lea	TSize(pc),a3
	move.l	Buffer(a5),a1
	moveq	#0,d7
	move.w	d5,d7
	clr.w	-(sp)
	move.l	#$10000000,-(sp)
GSize1	move.l	d7,d5
	move.w	(a3)+,d1
	beq.s	GSize2
	divu	d1,d5
	swap	d5
	tst.w	d5
	bne.s	GSize1
	swap	d5
	bsr	PacSize
	cmp.l	(sp),d0
	bcc.s	GSize1
	move.l	d0,(sp)
	move.w	d1,4(sp)
	bra.s	GSize1
GSize2	move.l	(sp)+,d0
	move.w	(sp)+,d1
	move.l	d7,d5
	divu	d1,d5
	movem.l	(sp)+,a1-a3/d6-d7
	rts

******* Simulate a packing
PacSize	movem.l	d1-d7/a0-a4/a6,-(sp)
	move.l	a5,-(sp)
* Fake data zone
        move.w 	d2,Pkdx(a1)
        move.w 	d3,Pkdy(a1)
        move.w 	d4,Pktx(a1)
        move.w 	d5,Pkty(a1)
        move.w 	d1,Pktcar(a1)
* Reserve intermediate table space
	move.w	d1,d0
	mulu	d4,d0
	mulu	d5,d0
	mulu	EcNPlan(a0),d0
	lsr.l	#3,d0
	addq.l	#2,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	SyCall	MemFast
	move.l	a0,d0
	move.l	(sp)+,a0
	Rbeq	L_JOOfMem
	move.l	d0,a6
	move.l	d0,-(sp)
* Prepare registers
        move.l	a2,a4	        	;a4--> picture address
        lea 	PkDatas1(a1),a5        	;a5--> main datas
	move.w	EcTLigne(a0),d7
	move.w	d7,d5
	mulu	d1,d5			;d5--> SY line of square
        move.w 	Pkdy(a1),d3
        mulu 	d7,d3
        move.w 	Pkdx(a1),d0
	ext.l	d0
	add.l	d0,d3
	move.w	EcNPlan(a0),-(sp)
* Main packing
        moveq 	#7,d1  		        * Bit pointer
	moveq	#0,d0
Iplan:  move.l 	(a4)+,a3
	add.l	d3,a3
        move.w 	Pkty(a1),d6
	subq.w	#1,d6
Iligne: move.l 	a3,a2
	move.w	Pktx(a1),d4
	subq.w	#1,d4
Icarre: move.l 	a2,a0
        move.w 	Pktcar(a1),d2
	subq.w	#1,d2
Ioct0: 	cmp.b 	(a0),d0         	* Compactage d'un carre
        beq.s 	Ioct1
	move.b	(a0),d0
        addq.l 	#1,a5
        bset 	d1,(a6)
Ioct1:  dbra 	d1,Ioct2
        moveq 	#7,d1
        addq.l 	#1,a6
	clr.b	(a6)
Ioct2:  add.w 	d7,a0
        dbra 	d2,Ioct0
        addq.l	#1,a2
        dbra 	d4,Icarre
	add.l	d5,a3
        dbra 	d6,Iligne
	subq.w	#1,(sp)
	bne.s	Iplan
	addq.l	#2,sp
	addq.l	#1,a5
* Packing of first pointers table
	move.l	a5,a6
	move.l	4(sp),d2
	move.l	d2,d0
	subq.w	#1,d2
	lsr.w	#3,d0
	addq.w	#2,d0
	add.w	d0,a5
	move.l	(sp),a0
	moveq	#0,d0
        moveq 	#7,d1
Icomp2  cmp.b 	(a0)+,d0
        beq.s 	Icomp2a
	move.b	-1(a0),d0
        addq.l 	#1,a5
Icomp2a dbra	d2,Icomp2
* Final size (EVEN!)
	move.l	a5,d2
	sub.l	a1,d2
	addq.l	#3,d2
	and.l	#$FFFFFFFE,d2
* Free intermediate memory
	move.l	(sp)+,a1
	move.l	(sp)+,d0
	move.l	(sp)+,a5
	SyCall	MemFree
* Finished!
	move.l	d2,d0
	movem.l	(sp)+,d1-d7/a0-a4/a6
	rts
******* Packing methods
TSize	dc.w 	1,2,3,4,5,6,7,8,12,16,24,32,48,64,0


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	REAL PACKING!!!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Pack
; - - - - - - - - - - - - -
* Header of the packed bitmap
	movem.l	d1-d7/a0-a4/a6,-(sp)
	move.l	a5,-(sp)

* Packed bitmap header
        move.l 	#BMCode,Pkcode(a1)
        move.w 	d2,Pkdx(a1)
        move.w 	d3,Pkdy(a1)
        move.w 	d4,Pktx(a1)
        move.w 	d5,Pkty(a1)
        move.w 	d1,Pktcar(a1)
	move.w	EcNPlan(a0),Pknplan(a1)

* Reserve intermediate table space
	move.w	d1,d0
	mulu	d4,d0
	mulu	d5,d0
	mulu	EcNPlan(a0),d0
	lsr.l	#3,d0
	addq.l	#2,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	SyCall	MemFast
	move.l	a0,d0
	move.l	(sp)+,a0
	Rbeq	L_JOOfMem
	move.l	d0,a6
	move.l	d0,-(sp)

* Prepare registers
        move.l	a2,a4        		;a4--> picture address
        lea 	PkDatas1(a1),a5        	;a5--> main datas
	move.w	EcTLigne(a0),d7
	move.w	d7,d5
	mulu	d1,d5			;d5--> SY line of square
        move.w 	Pkdy(a1),d3
        mulu 	d7,d3
        move.w 	Pkdx(a1),d0
	ext.l	d0
	add.l	d0,d3
	move.w	EcNPlan(a0),-(sp)

* Main packing
        moveq 	#7,d1  		        * Bit pointer
	moveq	#0,d0
        clr.b 	(a5)              	* First byte to zero
        clr.b 	(a6)
plan:   move.l 	(a4)+,a3
	add.l	d3,a3
        move.w 	Pkty(a1),d6
	subq.w	#1,d6
ligne:  move.l 	a3,a2
	move.w	Pktx(a1),d4
	subq.w	#1,d4
carre:  move.l 	a2,a0
        move.w 	Pktcar(a1),d2
	subq.w	#1,d2
oct0: 	cmp.b 	(a0),d0         	* Compactage d'un carre
        beq.s 	oct1
	move.b	(a0),d0
        addq.l 	#1,a5
        move.b 	d0,(a5)
        bset 	d1,(a6)
oct1:   dbra 	d1,oct2
        moveq 	#7,d1
        addq.l 	#1,a6
        clr.b 	(a6)
oct2:   add.w 	d7,a0
        dbra 	d2,oct0
        addq.l	#1,a2			* Carre suivant en X
        dbra 	d4,carre
	add.l	d5,a3			* Ligne suivante
        dbra 	d6,ligne
	subq.w	#1,(sp)			* Plan couleur suivant
	bne.s	plan
	addq.l	#2,sp
	addq.l	#1,a5

; Packing of first pointers table
	move.l	a5,d0
	sub.l	a1,d0
	move.l	d0,PkPoint2(a1)
	move.l	a5,a6
	move.l	4(sp),d0
	move.l	d0,d2
	subq.w	#1,d2
	lsr.w	#3,d0
	addq.w	#2,d0
	add.w	d0,a5
	move.l	a5,d0
	sub.l	a1,d0
	move.l	d0,PkDatas2(a1)
	move.l	(sp),a0
	moveq	#0,d0
        moveq 	#7,d1
        clr.b 	(a5)
        clr.b 	(a6)
comp2:  cmp.b 	(a0)+,d0
        beq.s 	comp2a
	move.b	-1(a0),d0
        addq.l 	#1,a5
        move.b 	d0,(a5)
        bset 	d1,(a6)
comp2a: dbra 	d1,comp2b
        moveq 	#7,d1
        addq.l 	#1,a6
        clr.b 	(a6)
comp2b: dbra	d2,comp2

* Free intermediate memory
	move.l	(sp)+,a1
	move.l	(sp)+,d0
	move.l	(sp)+,a5
	SyCall	MemFree
	movem.l	(sp)+,d1-d7/a0-a4/a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	JUMP TO ERROR MESSAGES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	JFoncall
; - - - - - - - - - - - - -
	moveq	#23,d0
	Rjmp	L_Error
; - - - - - - - - - - - - -
	Lib_Def	JScnop
; - - - - - - - - - - - - -
	moveq	#47,d0
	Rjmp	L_Error
; - - - - - - - - - - - - -
	Lib_Def	JOOfMem
; - - - - - - - - - - - - -
	moveq	#24,d0
	Rjmp	L_Error

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	ERROR HANDLING
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	NoPac
; - - - - - - - - - - - - -
	moveq	#0,d0
	Rbra	L_Custom
; - - - - - - - - - - - - -
	Lib_Def	NoScr
; - - - - - - - - - - - - -
	moveq	#1,d0
	Rbra	L_Custom


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ERRORS: First routine
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Custom
; - - - - - - - - - - - - -
	lea	ErrMes(pc),a0
	moveq	#0,d1
	moveq	#ExtNb,d2
	moveq	#0,d3
	Rjmp	L_ErrorExt
ErrMes	dc.b 	"Not a packed bitmap",0
	dc.b 	"Not a packed screen",0
	even
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	ERRORS: Second routine
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Custom2
; - - - - - - - - - - - - -
	moveq	#0,d1
	moveq	#ExtNb,d2
	moveq	#0,d3
	Rjmp	L_ErrorExt

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Finish the library
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_End
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TITLE OF THE EXTENSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_Title		dc.b 	"AMOSPro Picture Compactor V "
		Version
		dc.b	0,"$VER: "
		Version
		dc.b	0
		Even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		END OF THE EXTENSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_End		dc.w	0
		even
