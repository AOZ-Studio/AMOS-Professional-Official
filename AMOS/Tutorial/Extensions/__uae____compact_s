;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; AMOSPro Picture compactor extension source code,
; By François Lionet
; AMOS, AMOSPro and AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOS1.3 and over
;--------------------------------------------------------------------- 
; This file is public domain
;---------------------------------------------------------------------
; Please refer to the _Music.s file for more informations
;---------------------------------------------------------------------
*
Version		MACRO
		dc.b	"1.0"
		ENDM
*
*
ExtNb		equ	2-1
*
		Include "|AMOS_Includes.s"
*
Start		dc.l	C_Tk-C_Off
		dc.l	C_Lib-C_Tk
		dc.l	C_Title-C_Lib
		dc.l	C_End-C_Title
		dc.w	0

***********************************************************
* 		OFFSETS TO FUNCTIONS
C_Off   	dc.w (L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2
        	dc.w (L5-L4)/2,(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
        	dc.w (L9-L8)/2,(L10-L9)/2,(L11-L10)/2,(L12-L11)/2
       		dc.w (L13-L12)/2,(L14-L13)/2,(L15-L14)/2,(L16-L15)/2
        	dc.w (L17-L16)/2,(L18-L17)/2,(L19-L18)/2,(L20-L19)/2
		dc.w (L21-L20)/2,(L22-L21)/2,(L23-L22)/2

***********************************************************
* 		COMPACTOR TOKENS
C_Tk		dc.w 	1,0
		dc.b 	$80,-1
		dc.w 	L_Pack2,-1
		dc.b 	"!pac","k"+$80,"I0t0",-2
		dc.w	L_Pack6,-1
		dc.b	$80,"I0t0,0,0,0,0",-1
		dc.w 	L_SPack2,-1
		dc.b 	"!spac","k"+$80,"I0t0",-2
		dc.w	L_SPack6,-1
		dc.b	$80,"I0t0,0,0,0,0",-1
		dc.w	L_UPack1,-1
		dc.b	"!unpac","k"+$80,"I0",-2
		dc.w 	L_UPack2,-1
		dc.b	$80,"I0t0",-2
		dc.w 	L_UPack3,-1
		dc.b	$80,"I0,0,0",-1
		dc.w 	0

******************************************************************
*		Start of library
C_Lib

******************************************************************
*		COLD START
L0	moveq	#ExtNb,d0
	rts

******************************************************************
*
L1

******************************************************************
*	
L2

******************************************************************
*		PACK Screen,Bank#
L_Pack2		equ	3
L3	clr.l	-(a3)
	clr.l	-(a3)
	move.l	#10000,-(a3)
	move.l	(a3),-(a3)
	RBra	L_Pack6

******************************************************************
*		PACK Screen,Bank#
L_Pack6		equ	4
L4	Rbsr	L_PacPar
	Rbsr	L_GetSize
	Rbsr	L_ResBank
	Rbsr	L_Pack
	rts

*******************************************************************
*		SPACK Screen,Bank#
L_SPack2	equ	5
L5	clr.l	-(a3)
	clr.l	-(a3)
	move.l	#10000,-(a3)
	move.l	(a3),-(a3)
	Rbra	L_SPack6

*******************************************************************
*		SPACK Screen,Bank#,X1,Y1 TO X2,Y2
L_SPack6	equ	6
L6	Rbsr	L_PacPar
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
	move.w	EcAWX(a0),PsAWX(a1)
	move.w	EcAWY(a0),PsAWY(a1)
	move.w	EcAWTX(a0),PsAWTX(a1)
	move.w	EcAWTY(a0),PsAWTY(a1)
	move.w	EcAVX(a0),PsAVX(a1)
	move.w	EcAVY(a0),PsAVY(a1)
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

*************************************************************************
*		UNPACK Bank# 		-> To current screen
L_UPack1	equ	7
L7	move.l	ScOnAd(a5),d0
	Rbeq	L_JFonCall
	move.l	d0,a1
	moveq	#-1,d1
	moveq	#-1,d2
	Rbra	L_UPack

*************************************************************************
*		UNPACK Bank#,X,Y	-> To current screen
L_UPack3	equ	8
L8	move.l	ScOnAd(a5),d0
	Rbeq	L_JFonCall
	move.l	d0,a1
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	lsr.l	#3,d1
	Rbra	L_UPack

L_UPack		equ	9
L9	movem.l	d1/a1,-(sp)
	 move.l	(a3)+,d0
	RJsr	L_Bnk.OrAdr
	movem.l	(sp)+,d1/a1
* Autoback 
	tst.w	EcAuto(a1)		* Is screen autobacked?
	Rbeq	L_UnPack		* NOPE! Do simple unpack
	movem.l	d0-d7/a0-a2,-(sp)	* YEP! First step
	EcCall	AutoBack1
	movem.l	(sp),d0-d7/a0-a2
	btst	#BitDble,EcFlags(a1)	* DOUBLE BUFFER?
	beq.s	ABPac1
	Rbsr	L_UnPack
	EcCall	AutoBack2		* Second step
	movem.l	(sp),d0-d7/a0-a2
	Rbsr	L_UnPack
	EcCall	AutoBack3		* Third step
	bra.s	ABPac2
ABPac1	Rbsr	L_UnPack		* SINGLE BUFFER autobacked
	EcCall	AutoBack4
ABPac2	movem.l	(sp)+,d0-d7/a0-a2
	rts

*************************************************************************
*		UNPACK Bank# TO screen	-> Creates/Erases screen!
L_UPack2	equ	10
L10	move.l	(a3)+,d1
	cmp.l	#8,d1
	Rbcc	L_JFoncall
* Creates new screen
	move.l	d1,-(sp)
	move.l	(a3)+,d0
	RJsr	L_Bnk.OrAdr
	move.l	(sp)+,d1
	cmp.l	#SCCode,PsCode(a0)
	Rbne	L_NoScr
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.w	PsTx(a0),d2
	move.w	PsTy(a0),d3
	move.w	PsNPlan(a0),d4
	move.w	PsCon0(a0),d5
	move.w	PsNbCol(a0),d6
	lea	PsPal(a0),a1
	move.l	a0,-(sp)
	EcCall	Cree
	Rbne	L_JOOfMem
	move.l	a0,a1
	move.l	(sp)+,a0
	move.l	a1,ScOnAd(a5)
	move.w	EcNumber(a1),ScOn(a5)
	addq.w	#1,ScOn(a5)
* Enleve le curseur
	movem.l	a0-a6/d0-d7,-(sp)
	lea	CuCuOff(pc),a1
	WiCall	Print
	movem.l	(sp)+,a0-a6/d0-d7
* Change View/Offset
	move.w	PsAWX(a0),EcAWX(a1)
	move.w	PsAWY(a0),EcAWY(a1)
	move.w	PsAWTx(a0),EcAWTx(a1)
	move.w	PsAWTy(a0),EcAWTy(a1)
	move.w	PsAVX(a0),EcAVX(a1)
	move.w	PsAVY(a0),EcAVY(a1)
	move.b	#%110,EcAW(a1)
	move.b	#%110,EcAWT(a1)
	move.b	#%110,EcAV(a1)
* Unpack!
	lea	PsLong(a0),a0
	moveq	#0,d1
	moveq	#0,d2
	Rbra	L_UnPack
CuCuOff	dc.b	27,"C0",0
	even

***********************************************************
*		Reserves memory bank, A1= number
L_ResBank	equ	11
L11	movem.l	a0/d1/d2,-(sp)
	move.l	d0,d2
	moveq	#(1<<Bnk_BitData),d1
	move.l	a1,d0
	lea	BkPac(pc),a0
	Rjsr	L_Bnk.Reserve
	Rbeq	L_JOOfMem
	move.l	a0,a1 
	movem.l	(sp)+,a0/d1/d2
	rts
******* Definition banque de samples
BkPac:	dc.b "Pac.Pic."
	even

***********************************************************
*		Unpile parameters
L_PacPar	equ	12
L12	move.l	(a3)+,d5
	move.l	(a3)+,d4
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	lsr.w	#3,d4
	lsr.w	#3,d2
* Screen
	move.l	4(a3),d1
	RJsr	L_GetEc
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
L_GetSize	equ	13
L13	movem.l	a1-a3,-(sp)
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
	movem.l	(sp)+,a1-a3
	rts

******* Simulate a packing
PacSize	movem.l	d1-d7/a0-a6,-(sp)
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
	Rjsr	L_RamFast
	Rbeq	L_JOofMem
	move.l	(sp)+,a0
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
	bne.s	IPlan
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
	Rjsr	L_RamFree
* Finished!
	move.l	d2,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
******* Packing methods
TSize	dc.w 	1,2,3,4,5,6,7,8,12,16,24,32,48,64,0


***********************************************************
*	REAL PACKING!!!
L_Pack		equ	14
L14
* Header of the packed bitmap
	movem.l	d1-d7/a0-a6,-(sp)

* Packed bitmap header
        move.l 	#BMCode,PkCode(a1)
        move.w 	d2,Pkdx(a1)
        move.w 	d3,Pkdy(a1)  
        move.w 	d4,Pktx(a1)  
        move.w 	d5,Pkty(a1)   
        move.w 	d1,Pktcar(a1)  
	move.w	EcNPlan(a0),PkNPlan(a1)

* Reserve intermediate table space
	move.w	d1,d0
	mulu	d4,d0
	mulu	d5,d0
	mulu	EcNPlan(a0),d0
	lsr.l	#3,d0
	addq.l	#2,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	Rjsr	L_RamFast
	Rbeq	L_JOofMem
	move.l	(sp)+,a0
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
	bne.s	Plan
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
comp2b: dbra	d2,Comp2

* Free intermediate memory
	move.l	(sp)+,a1
	move.l	(sp)+,d0
	RJsr	L_RamFree
	movem.l	(sp)+,d1-d7/a0-a6
	rts

***********************************************************
*		Bitmap unpacker
*		A0-> packed picture
*		A1-> Destination screen
*		D1.L Start in X
*		D2.L Start in Y
UAEc:	equ 0
UDEc:	equ 4
UITy:	equ 8
UTy:	equ 10
UTLine:	equ 12
UNPlan:	equ 14
UPile:	equ 16
L_UnPack	equ	15
L15	movem.l	a0-a6/d1-d7,-(sp)

* Jump over SCREEN DEFINITION
	cmp.l	#SCCode,(a0)
	bne.s	dec0
	lea	PsLong(a0),a0
* Is it a packed bitmap?
dec0	cmp.l	#BMCode,(a0)
	Rbne	L_NoPac

* Parameter preparation
	lea	-UPile(sp),sp		* Space to work
	lea	EcCurrent(a1),a2
	move.l	a2,UAEc(sp)		* Bitmaps address
        move.w 	EcTLigne(a1),d7    	* d7--> line size
	move.w	EcNPlan(a1),d0		* How many bitplanes
	cmp.w	PkNPlan(a0),d0
	Rbne	L_JFoncall
	move.w	d0,UNPlan(sp)
	move.w	Pktcar(a0),d6		* d6--> SY square

        tst.l 	d1			* Screen address in X
        bpl.s 	dec1
        move.w 	Pkdx(a0),d1
dec1:   tst.l 	d2			* In Y
        bpl.s 	dec2
        move.w 	Pkdy(a0),d2
dec2:   move.w	Pktx(a0),d0
	add.w	d1,d0
	cmp.w	d7,d0
	Rbhi	L_JFoncall
	move.w	Pkty(a0),d0
	mulu	d6,d0
	add.w	d2,d0
	cmp.w	EcTy(a1),d0
	Rbhi	L_JFoncall

	mulu	d7,d2			* Screen address
	ext.l	d1	
	add.l	d2,d1
	move.l	d1,UDEc(sp)
	
	move.w	d6,d0			* Size of one line
        mulu 	d7,d0
        move 	d0,UTLine(sp)

        move.w 	Pktx(a0),a3		* Size in X
        subq.w	#1,a3
        move.w 	Pkty(a0),UITy(sp)	* in Y
        lea 	PkDatas1(a0),a4        	* a4--> bytes table 1
        move.l 	a0,a5
        move.l 	a0,a6
        add.l 	PkDatas2(a0),a5     	* a5--> bytes table 2
        add.l 	PkPoint2(a0),a6     	* a6--> pointer table

        moveq 	#7,d0			
        moveq 	#7,d1
        move.b 	(a5)+,d2
        move.b 	(a4)+,d3
        btst 	d1,(a6)
        beq.s 	prep
        move.b 	(a5)+,d2
prep:   subq.w 	#1,d1

* Unpack!
dplan:  move.l 	UAEc(sp),a2
	addq.l	#4,UAEc(sp)
	move.l	(a2),a2
	add.l	UDEc(sp),a2
        move.w 	UITy(sp),UTy(sp)	* Y Heigth counter
dligne: move.l 	a2,a1
        move.w 	a3,d4
dcarre: move.l 	a1,a0
        move.w 	d6,d5   		* Square height
doctet1:subq.w 	#1,d5
        bmi.s 	doct3
        btst 	d0,d2
        beq.s 	doct1
        move.b 	(a4)+,d3
doct1:  move.b 	d3,(a0)
        add.w 	d7,a0
        dbra 	d0,doctet1
        moveq 	#7,d0
        btst 	d1,(a6)
        beq.s 	doct2
        move.b 	(a5)+,d2
doct2:  dbra 	d1,doctet1
        moveq 	#7,d1
        addq.l 	#1,a6
        bra.s 	doctet1
doct3:  addq.l	#1,a1           	* Other squares?
        dbra 	d4,Dcarre
        add.w 	UTLine(sp),a2          	* Other square line?
        subq.w 	#1,UTy(sp)
        bne.s 	Dligne
        subq.w 	#1,UNPlan(sp)
        bne.s 	Dplan
        lea	UPile(sp),sp            * Restore the pile
* Finished!
	movem.l	(sp)+,a0-a6/d1-d7
	rts


***********************************************************
*		JUMP TO ERROR MESSAGES
L_JFoncall	equ	16
L16	moveq	#23,d0
	RJmp	L_Error
L_JScnop	equ	17
L17	moveq	#47,d0
	RJmp	L_Error
L_JOOfmem	equ	18
L18	moveq	#24,d0
	RJmp	L_Error

***********************************************************
*		ERROR HANDLING
L_NoPac		equ	19
L19	moveq	#0,d0
	RBra	L_Custom
L_NoScr		equ	20
L20	moveq	#1,d0
	RBra	L_Custom

***********************************************************
*		ERROR MESSAGES

******* First routine
L_Custom	equ	21
L21	lea	ErrMes(pc),a0
	moveq	#0,d1
	moveq	#ExtNb,d2
	moveq	#0,d3
	RJmp	L_ErrorExt
ErrMes	dc.b 	"Not a packed bitmap",0
	dc.b 	"Not a packed screen",0
	even	
******* Second routine
L22	moveq	#0,d1
	moveq	#ExtNb,d2
	moveq	#0,d3
	RJmp	L_ErrorExt
L23

***********************************************************
* 		Welcome message
C_Title		dc.b 	"AMOSPro Picture Compactor V "
		Version
		dc.b	0,"$VER: "
		Version
		dc.b	0
		Even

***********************************************************
C_End	dc.w	0


