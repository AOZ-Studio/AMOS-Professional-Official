;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; AMOS Requester handler V1.6
; By François Lionet
; AMOS - AMOS Pro - AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOS Pro 1.0 and over
;--------------------------------------------------------------------- 
; This file is public domain
;---------------------------------------------------------------------
; Please refer to the _Music.s file for more informations
;---------------------------------------------------------------------

Version		MACRO
		dc.b	"1.0"
		ENDM



Req_WY		equ	100

T_Tit		equ	0
T_Text		equ	T_Tit+80
T_Gad		equ	T_Text+320
T_Size		equ	T_Gad+128

*
ExtNb		equ	3-1
*
 		Include	"|AMOS_Includes.s"
*
Start		dc.l	C_Tk-C_Off
		dc.l	C_Lib-C_Tk
		dc.l	C_Title-C_Lib
		dc.l	C_End-C_Title
		dc.w	-1	
*
******************************************************************
* 		OFFSETS TO FUNCTIONS
C_Off           dc.w (L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2
        	dc.w (L5-L4)/2,(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
        	dc.w (L9-L8)/2,(L10-L9)/2,(L11-L10)/2

******************************************************************
* 	TOKEN TABLE + Addresses
C_Tk		dc.w 	1,0
		dc.b 	$80,-1
		dc.w	L_ReqOn,-1
		dc.b	"request o","n"+$80,"I",-1
		dc.w	L_ReqOf,-1
		dc.b	"request of","f"+$80,"I",-1
		dc.w	L_ReqWb,-1
		dc.b	"request w","b"+$80,"I",-1
		dc.w 	0

******************************************************************
C_Lib
******************************************************************
*		COLD START
L0	movem.l	a3-a6,-(sp)
	lea	ReqData(pc),a4
	move.l	a4,ExtAdr+ExtNb*16(a5)
	lea	Quit(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+8(a5)
* Copy default palette	
	lea	PI_DefEPa+8*2(a5),a0	
	lea	Req_Pal+8*2(pc),a1
	moveq	#24-1,d0
CPal	move.w	(a0)+,(a1)+
	dbra	d0,CPal
* Branch the requester
	move.l	a5,Datas-ReqData(a4)
	lea	AutoReq(pc),a2
	lea	EasyReq(pc),a3
	Rbsr	L_SetJump
	move.l	a2,PrevAuto-ReqData(a4)
	move.l	a3,PrevEasy-ReqData(a4)
	move.w	#-1,ReqFlag-ReqData(a4)	        * Default is AMOS request
* Return to caller
	movem.l	(sp)+,a3-a6
	moveq	#ExtNb,d0			* NO ERRORS
	rts

******* SCREEN RESET
Warm	rts

******* QUIT
Quit	move.l	PrevAuto(pc),a2
	move.l	PrevEasy(pc),a3
	Rbra	L_SetJump

***********************************************************
*	AMOS REQUESTER

AutoReq	movem.l	a0-a6/d0-d7,-(sp)
	bsr	Req_In
	bpl.s	.Skip
	bsr	Req_Auto
	bra	Req_AMOS
.Skip	move.l	PrevAuto-ReqData(a6),ScAdr-ReqData(a6)
	bra.s	Req_WB

EasyReq	movem.l	a0-a6/d0-d7,-(sp)
	bsr	Req_In
	bpl.s	.Skip
	bsr	Req_Easy
	bra.s	Req_AMOS
.Skip	move.l	PrevEasy-ReqData(a6),ScAdr-ReqData(a6)
	bra.s	Req_WB

******* Dispatch requester between AMOS/WB
Req_In	lea	ReqData(pc),a6
	move.l	Datas-ReqData(a6),a5
	tst	ReqFlag-ReqData(a6)
	beq.s	Req_ANo
	bmi.s	.AMOS
* System requester?
	tst.b	WB_Closed(a5)		WB closed!
	bne.s	.AMOS
.WB	moveq	#1,d0
	rts
* AMOS requester
.AMOS	tst.w	T_AMOSHere(a5)		AMOS here?
	beq.s	.WB
	moveq	#-1,d0
	rts

******* Always no!
Req_ANo	addq.l	#4,sp
	movem.l	(sp)+,a0-a6/d0-d7
	moveq	#0,d0
	rts

******* WB requester
Req_WB	move.w	T_AMOSHere(a5),d0	Is AMOS here?
	move.w	d0,ReqOld-ReqData(a6)
	beq.s	.skip1
	EcCalD	AMOS_WB,0		AMOS To BACK
.skip1	movem.l	(sp),a0-a6/d0-d7
	move.l	ScAdr(pc),a5
	jsr	(a5)
	lea	ReqData(pc),a6
	move.l	Datas-ReqData(a6),a5
	move.l	d0,Req_Pos-ReqData(a6)
	move.w	ReqOld-ReqData(a6),d1
	beq.s	.skip2
	EcCalD	AMOS_WB,1		AMOS To FRONT
.skip2	movem.l	(sp)+,a0-a6/d0-d7
	move.l	Req_Pos(pc),d0
	rts

******* AMOS Normal requester
Req_AMOS

	SyCall	AMALFrz
	bsr	UnMix1

	move.w	Req_Sx-ReqData(a6),d2
	lsl.w	#3,d2
	ext.l	d2
	move.w	Req_Sy-ReqData(a6),d3
	lsl.w	#3,d3
	ext.l	d3
	moveq	#3,d4
	move.l	#$8000,d5
	moveq	#8,d6
	moveq	#0,d7
	lea	Req_Pal-ReqData(a6),a1
	EcCalD	Cree,EcReq
	bne	NoReq
	move.l	a0,ScAdr-ReqData(a6)
	WiCalA	Print,Req_Init-ReqData(a6)

* Top
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#4,d4
	moveq	#3*8,d5
	bsr	Copy
	moveq	#4,d0
	moveq	#1,d4
	move.w	Req_Sx-ReqData(a6),d6
.lp1	bsr	Copy
	subq.w	#1,d6
	cmp.w	#9,d6
	bcc.s	.lp1
	moveq	#10,d0
	moveq	#4,d4
	bsr	Copy
* Middle
	moveq	#3*8,d3
	move.w	Req_Sy-ReqData(a6),d7
	sub.w	#6,d7
.lp2	moveq	#0,d0
	moveq	#3*8,d1
	moveq	#0,d2
	moveq	#2,d4
	moveq	#12,d5
	bsr	Copy
	moveq	#6,d0
	moveq	#1,d4
	move.w	Req_Sx-ReqData(a6),d6
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
* Bottom
	moveq	#0,d0
	moveq	#4*8+4,d1
	moveq	#0,d2
	add.w	#4,d3
	moveq	#1,d4
	moveq	#2*8+4,d5
	bsr	Copy
	moveq	#6,d0
	moveq	#1,d4
	move.w	Req_Sx-ReqData(a6),d6
.lp4	bsr	Copy
	subq.w	#1,d6
	cmp.w	#3,d6
	bcc.s	.lp4
	moveq	#13,d0
	moveq	#1,d4
	bsr	Copy
* Bottom Left
	move.l	Req_Pos-ReqData(a6),a0
.lp5	tst.b	(a0)+
	bne.s	.lp5
	sub.l	Req_Pos-ReqData(a6),a0
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
* Bottom right
	move.l	Req_Neg-ReqData(a6),d0
	move.l	d0,a0
	beq.s	.sk1
.lp7	tst.b	(a0)+
	bne.s	.lp7
	sub.l	Req_Neg-ReqData(a6),a0
	move.w	a0,d6
	move.w	Req_Sx-ReqData(a6),d0
	sub.w	a0,d0
	add.b	#48-1,d0
	move.b	d0,XTNeg-ReqData(a6)
	moveq	#8,d0
	moveq	#4*8+4,d1
	move.w	Req_Sx-ReqData(a6),d2
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
* End of init
	SyCalD	ResZone,2
	move.w	Req_Sy-ReqData(a6),d0
	lsl.w	#3,d0
	move.w	d0,Req_Sy-ReqData(a6)

* Initialise background text
	WiCalA	Centre,T_Tit(a4)
* Print main text
	WiCalA	Print,Req_Main(pc)
	lea	T_Text(a4),a1
.lop	move.l	a1,-(sp)
	WiCall	Centre
	move.l	(sp)+,a1
.lop1	tst.b	(a1)+
	bne.s	.lop1
	tst.b	(a1)
	bne.s	.lop
* Positive text (left)
	moveq	#1,d0
	moveq	#"0",d1
	bsr	PrtZone
* Negative text (right)
	move.l	Req_Neg-ReqData(a6),d0
	beq.s	.NoNeg
	move.l	d0,a0
	moveq	#2,d0
	moveq	#"0",d1
	bsr	PrtZone
* Screen appearance
.NoNeg	move.l	ScAdr-ReqData(a6),a2
	move.w	#288,d0
	move.w	Req_Sx-ReqData(a6),d1
	lsl.w	#1,d1
	sub.w	d1,d0
	move.w	d0,EcAWX(a2)
	bset	#1,EcAW(a2)
	moveq	#8,d7
	moveq	#1,d6
	move.w	Req_Sy-ReqData(a6),d5
	lsr.w	#1,d5
	add.w	#Req_Wy,d5
	bsr	AppCentre
* State of disc drive
	SyCall	GetDisc
	move.w	d0,DOld-ReqData(a6)

******* Test loop (fun!)
ReqLoop	
	bsr	UnMix2
	move.l	a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	-270(a6)		WaitTOF
	move.l	(sp)+,a6
	bsr	UnMix1

* Automatic disc change
	move.l	Req_IDCMP-ReqData(a6),d0
	btst	#15,d0
	beq.s	NoAuto
	SyCall	GetDisc
	cmp.w	DOld-ReqData(a6),d0
	beq.s	NoAuto
	move.w	d0,DOld-ReqData(a6)
	bne	ReqYes
* Keyboard
NoAuto	SyCall	Inkey
	cmp.w	#13,d1		* ASCII-> Return 
	beq.s	ReqYes	
	cmp.w	#27,d1		* ASCII-> ESC
	beq.s	ReqNo	
* Don't you think it is better than this wierd Amiga V and B?
* Sometime I ask myself what they were thinking when they chose such
* key combinations!
	swap	d1
	move.w	d1,d0		* Isolate AMIGA keys
	and.w	#%1100000000000000,d0
	beq.s	RqL0
	cmp.b	#$34,d1		* V
	beq.s	ReqYes
	cmp.b	#$35,d1		* B
	beq.s	ReqNo
* Mouse pointer
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

******* End of screen (well done!!!)
ReqGo	move.l	d0,-(sp)
	move.l	ScAdr-ReqData(a6),a2
	moveq	#-8,d7
	move.w	EcTY(a2),d6
	lsr.w	#1,d6
	move.w	Req_Sy-ReqData(a6),d5
	lsr.w	#1,d5
	add.w	#Req_Wy,d5
	bsr	AppCentre
	EcCalD	Del,EcReq

******* Back to system!
ReqX	bsr	UnMix2
	bsr	ClrData
	SyCall	AMALUFrz	
	move.l	(sp)+,Req_Pos-ReqData(a6)	* Returns answer
* Normal exit
ReqXX	movem.l	(sp)+,a0-a6/d0-d7
	move.l	Req_Pos(pc),d0
	rts
******* Can't open screen!!!
NoReq	clr.l	-(sp)
	bra.s	ReqX

******* Print a zone D0-> zone, D1-> inverse or not
PrtZone	subq.w	#1,d0
	bmi.s	PrtX
	bne.s	PrtNeg
* Print pos text
PrtPos	tst.l	Req_Pos-ReqData(a6)
	beq.s	.skip
	lea	TPos1-ReqData(a6),a1
	move.b	d1,8(a1)
	WiCall	Print
	move.l	Req_Pos-ReqData(a6),a1
	WiCall	Print
	WiCalA	Print,TPos2-ReqData(a6)
.skip	bra.s	PrtX
* Print neg text
PrtNeg	tst.l	Req_Neg-ReqData(a6)
	beq.s	.skip
	lea	TNeg1-ReqData(a6),a1
	move.b	d1,8(a1)
	WiCall	Print
	move.l	Req_Neg-ReqData(a6),a1
	WiCall	Print
	WiCalA	Print,TNeg2-ReqData(a6)
.skip
PrtX	rts

******* Screen appearance
AppCentre:
	move.w	d6,d4
	move.w	d6,EcAWTy(a2)
	add.w	d6,EcAWTy(a2)
	bset	#2,EcAWT(a2)
	move.w	EcTy(a2),d0
	lsr.w	#1,d0
	sub.w	d6,d0
	move.w	d0,EcAVY(a2)
	bset	#2,EcAV(a2)
	move.w	d5,EcAWy(a2)
	sub.w	d6,EcAWy(a2)
	bset	#2,EcAW(a2)
	movem.l	a2/d4-d7,-(sp)
	SyCall	WaitVBL
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

******* Prevent mixes between AMOS and the requester!
UnMix1	movem.l	d0-d7/a0-a6,-(sp)
	move.l	$4.w,a6
	jsr	Forbid(a6)
	EcCall	Current
	move.w	EcNumber(a0),d1
	lea	ReqOld(pc),a0
	move.w	d1,(a0)
	EcCalD	Active,EcReq
	EcCalD	First,EcReq
	EcCall	CopMake
	SyCall	WaitVBL
	movem.l	(sp)+,d0-d7/a0-a6
	rts
UnMix2	movem.l	d0-d7/a0-a6,-(sp)
	move.w	ReqOld(pc),d1
	EcCall	Active
	move.l	$4.w,a6
	jsr	Permit(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

******* Open TEXT data zone
ResData	move.l	#T_Size,d0
	SyCall	SyFast
	move.l	d0,a4
	rts
******* Clear TEXT data zone
ClrData	move.l	#T_Size,d0
	move.l	a4,a1
	SyCall	SyFree
	rts

******* Entree requester WB1.3
Req_Auto

	bsr	ResData

	move.l	#$00008000,Req_IDCMP-ReqData(a6)

	lsr.w	#3,d2
	addq.w	#3,d2
	and.w	#$FFFC,d2
	move.w	d2,Req_Sx-ReqData(a6)
	lsr.w	#3,d3
	addq.w	#2,d3
	move.w	d3,Req_Sy-ReqData(a6)

	move.l	a1,a0
	lea	T_Text(a4),a1
	moveq	#10,d0
	bsr	IT_Print

	clr.l	Req_Pos-ReqData(a6)
	lea	T_Gad(a4),a1
	move.l	a2,d0
	move.l	d0,a0
	beq.s	.skip1
	move.l	a1,Req_Pos-ReqData(a6)
	moveq	#0,d0
	bsr	IT_Print
.skip1
	clr.l	Req_Neg-ReqData(a6)
	lea	T_Gad+64(a4),a1
	move.l	a3,d0
	move.l	d0,a0
	beq.s	.skip2
	move.l	a1,Req_Neg-ReqData(a6)
	moveq	#0,d0
	bsr	IT_Print
.skip2
	lea	Req_Tit(pc),a0
	lea	T_Tit(a4),a1
.loop	move.b	(a0)+,(a1)+
	bne.s	.loop
	rts	

******* Entree requester WB2.0: fabrique les chaines de caracteres
Req_Easy
	bsr	ResData
	move.l	(a2),Req_IDCMP-ReqData(a6)

	lea	8(a1),a2
	clr.w	TxtMaxCx-ReqData(a6)

	lea	T_Tit(a4),a1
	move.l	(a2)+,d0
	move.l	d0,a0
	bne.s	.nof
	lea	Req_Tit(pc),a0
.nof	bsr	Format

	move.l	(a2)+,a0
	lea	T_Text(a4),a1
	bsr	Format
	move.w	TxtCy-ReqData(a6),Req_Sy-ReqData(a6)

	move.l	(a2)+,a0
	lea	T_Gad(a4),a1
	bsr	Format

	lea	T_Gad(a4),a0
	move.l	a0,Req_Pos-ReqData(a6)
	clr.l	Req_Neg-ReqData(a6)
.loop	move.b	(a0)+,d0
	beq.s	.skp
	cmp.b	#"|",d0
	bne.s	.loop
	clr.b	-1(a0)
	move.l	a0,Req_Neg-ReqData(a6)
.skp
	move.w	TxtMaxCx-ReqData(a6),d0
	cmp.w	#32,d0
	bcc.s	.skp2
	moveq	#32,d0
.skp2	add.w	#9,d0
	and.w	#$FFFC,d0
	move.w	d0,Req_Sx-ReqData(a6)

	add.w	#8,Req_Sy-ReqData(a6)
	rts

** Routine, appel de RawDoFmt
Format	clr.w	TxtCx-ReqData(a6)
	move.w	#1,TxtCy-ReqData(a6)
	movem.l	a2/a3/a6,-(sp)
	exg	a3,a1
	lea	.OutC(pc),a2
	move.l	$4.w,a6
	jsr	-522(a6)
	exg	a3,a1
	movem.l	(sp)+,a2/a3/a6
.XMax	move.w	TxtCx-ReqData(a6),d0
	cmp.w	TxtMaxCx-ReqData(a6),d0
	bls.s	.sk
	move.w	d0,TxtMaxCx-ReqData(a6)
.sk	rts
.OutC	movem.l	a6/d0,-(sp)
	lea	ReqData(pc),a6
	addq.w	#1,TxtCx-ReqData(a6)
	move.b	d0,(a3)+
	cmp.b	#10,d0
	bne.s	.Skip
	clr.b	(a3)+
	addq.w	#1,TxtCy-ReqData(a6)
	bsr.s	.XMax
	clr.w	TxtCx-ReqData(a6)
.Skip	movem.l	(sp)+,a6/d0
	clr.b	(a3)
	rts

******* Routine: copie un intuitext dans le buffer
*	A0-> ITEXT
*	A1-> Buffer
*	D0-> Mettre un 10 a la fin...
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

******* Routine: copie les donnees binaires
Copy	movem.l	d0-d7/a0-a5,-(sp)
	mulu	#RPic_Sx/8,d1			d1= offset source
	add.l	d1,d0
	lea	RPic-ReqData(a6),a0		a0= adress source
	move.w	Req_Sx-ReqData(a6),d1
	ext.l	d1				d1= size of dest line
	mulu	d1,d3
	add.l	d2,d3				d3= offset dest
	move.l	ScAdr-ReqData(a6),a3		a3= dest screen
	subq.w	#1,d4
	subq.w	#1,d5
	move.w	#RPic_NP-1,d2
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
ReqData		
*
ScAdr		dc.l 	0
Datas		dc.l 	0
PrevAuto	dc.l	0
PrevEasy	dc.l	0

Req_Sx		dc.w 	0
Req_Sy		dc.w	0
Req_Pos		dc.l	0
Req_Neg		dc.l	0

Req_IDCMP	dc.l	0
ReqFlag		dc.w 	0
ReqOld		dc.w 	0
DOld		dc.w	0
TxtCx		dc.w	0
TxtMaxCx	dc.w	0
TxtCy		dc.w	0

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
RPic_Sx		equ	112
RPic_Sy		equ	56
RPic_Np		equ	3

Req_Pal		Incbin	"ReqPic.Bin"
RPic		equ	Req_Pal+32*2

		even

;--------------------------------------------------------------------

L1
L2
L3

***********************************************************
*		REQUEST WB
L_ReqWb		equ	4
L4	moveq	#1,d0
	Rbra	L_ROnOf
*********************************************************** 
*		REQUEST ON
L_ReqOn		equ	5
L5	moveq	#-1,d0
	Rbra	L_ROnOf
*********************************************************** 
*		REQUEST OFF
L_ReqOf		equ	6
L6	moveq	#0,d0
	Rbra	L_ROnOf
*
L_ROnOf		equ	7
L7	move.l	ExtAdr+ExtNb*16(a5),a0
	move.w	d0,ReqFlag-ReqData(a0)
	rts

********************************************************** 
*	Change the library jumps
*	a2->	AutoRequest entry
*	a3->	EasyRequest entry
L_SetJump	equ	8
L8	movem.l	a0/a1/a6,-(sp)
	move.l	$4.w,a6
* AutoRequest
	move.l	a2,d0
	lea	-$15c,a0
	move.l	T_IntBase(a5),a1
	jsr	SetFunction(a6)
	move.l	d0,a2
* EasyRequest
	tst.w	WB2.0(a5)
	beq.s	.skip
	move.l	a3,d0
	lea	-$1d4-(20*6),a0
	move.l	T_IntBase(a5),a1
	jsr	SetFunction(a6)
	move.l	d0,a3
.skip	movem.l	(sp)+,a0/a1/a6
	rts

**********************************************************
*	Even if you do not have error messages, you MUST
*	leave TWO routines empty at the end...
L9
L10
* Two routines means three borders!
L11

*******************************************************************************

* 		Welcome message
C_Title		dc.b 	"AMOSPro Requester V"
		Version
		dc.b	0,"$VER: "
		Version
		dc.b	0
		Even
*		End of extension
C_End		dc.w	0

	even
