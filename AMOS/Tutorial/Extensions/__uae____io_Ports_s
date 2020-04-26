
;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; Serial / Parallel / Printer extension source code
; By François Lionet
; AMOS, AMOSPro, AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOSPro V1.0 and over
;--------------------------------------------------------------------- 
; This file is public domain
;---------------------------------------------------------------------
;
; Please refer to the _Music.s file for more informations...
;
;---------------------------------------------------------------------

Version		MACRO
		dc.b	"1.0"
		ENDM


* AMIGA's includes
		INCDIR		":Includes/I/"
		INCLUDE		"Exec/Types.I"
		INCLUDE		"Exec/Exec.I"
		INCLUDE 	"Devices/Serial.I"
		INCLUDE		"Devices/PrtBase.I"
		INCLUDE		"Devices/Printer.I"
		INCLUDE		"Devices/PrtGfx.I"
		INCLUDE		"Devices/Parallel.I"

*************** AMOS includes
ExtNb		equ	6-1

		Include	"|AMOS_Includes.s"

Dlea		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\2
		add.w	#\1-DT,\2
		ENDM
Dload		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\1
		ENDM

* Number of serial channels allowed
NSerial		equ	4

******************************************************************
*	Header
Start	dc.l	C_Tk-C_Off
	dc.l	C_Lib-C_Tk
	dc.l	C_Title-C_Lib
	dc.l	C_End-C_Title
	dc.w	0	

******************************************************************
*	Offsets to library
C_Off   dc.w (L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2
        dc.w (L5-L4)/2,(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
        dc.w (L9-L8)/2,(L10-L9)/2,(L11-L10)/2,(L12-L11)/2
        dc.w (L13-L12)/2,(L14-L13)/2,(L15-L14)/2,(L16-L15)/2
        dc.w (L17-L16)/2,(L18-L17)/2,(L19-L18)/2,(L20-L19)/2
        dc.w (L21-L20)/2,(L22-L21)/2,(L23-L22)/2,(L24-L23)/2
        dc.w (L25-L24)/2,(L26-L25)/2,(L27-L26)/2,(L28-L27)/2
        dc.w (L29-L28)/2,(L30-L29)/2,(L31-L30)/2,(L32-L31)/2
        dc.w (L33-L32)/2,(L34-L33)/2,(L35-L34)/2,(L36-L35)/2
        dc.w (L37-L36)/2,(L38-L37)/2,(L39-L38)/2,(L40-L39)/2
        dc.w (L41-L40)/2,(L42-L41)/2,(L43-L42)/2,(L44-L43)/2
        dc.w (L45-L44)/2,(L46-L45)/2,(L47-L46)/2,(L48-L47)/2
        dc.w (L49-L48)/2,(L50-L49)/2,(L51-L50)/2,(L52-L51)/2
        dc.w (L53-L52)/2,(L54-L53)/2,(L55-L54)/2,(L56-L55)/2
        dc.w (L57-L56)/2,(L58-L57)/2,(L59-L58)/2,(L60-L59)/2
        dc.w (L61-L60)/2,(L62-L61)/2,(L63-L62)/2,(L64-L63)/2
        dc.w (L65-L64)/2,(L66-L65)/2,(L67-L66)/2,(L68-L67)/2
        dc.w (L69-L68)/2,(L70-L69)/2,(L71-L70)/2,(L72-L71)/2

******************************************************************
*	TOKEN TABLE
C_Tk	dc.w 	1,0
	dc.b 	$80,-1
	dc.w	L_SerOp2,-1
	dc.b	"!serial ope","n"+$80,"I0,0",-2
	dc.w	L_SerOp5,-1
	dc.b	$80,"I0,0,0,0,0",-1
	dc.w	L_SerClo0,-1
	dc.b	"!serial clos","e"+$80,"I",-2
	dc.w	L_SerClo1,-1
	dc.b	$80,"I0",-1
	dc.w	L_SerSp,-1
	dc.b	"serial spee","d"+$80,"I0,0",-1
	dc.w	-1,L_SerChk
	dc.b	"serial chec","k"+$80,"00",-1
	dc.w 	L_SerSend,-1
	dc.b	"serial sen","d"+$80,"I0,2",-1
	dc.w 	L_SerSp,-1
	dc.b	"serial spee","d"+$80,"I0,0",-1
	dc.w 	L_SerBit,-1
	dc.b	"serial bit","s"+$80,"I0,0,0",-1
	dc.w 	L_SerX,-1
	dc.b	"serial ","x"+$80,"I0,0",-1
	dc.w 	L_SerBuf,-1
	dc.b	"serial bu","f"+$80,"I0,0",-1
	dc.w 	L_SerPar,-1
	dc.b	"serial parit","y"+$80,"I0,0",-1
	dc.w	-1,L_SerGet
	dc.b	"serial ge","t"+$80,"00",-1
	dc.w	-1,L_SerInp
	dc.b	"serial input","$"+$80,"20",-1
	dc.w	L_SerFast,-1
	dc.b	"serial fas","t"+$80,"I0",-1
	dc.w	L_SerSlow,-1
	dc.b	"serial slo","w"+$80,"I0",-1
	dc.w	-1,L_SerE
	dc.b	"serial erro","r"+$80,"00",-1
	dc.w	L_SerOut,-1
	dc.b	"serial ou","t"+$80,"I0,0,0",-1
	dc.w	-1,L_SerStatus
	dc.b	"serial statu","s"+$80,"00",-1
	dc.w	-1,L_SerBase
	dc.b	"serial bas","e"+$80,"00",-1
	dc.w	L_SerAbort,-1
	dc.b	"serial abor","t"+$80,"I0",-1
	
; Printer commands
; ~~~~~~~~~~~~~~~~
	dc.w   	L_PrtOpen,-1
	dc.b	"printer ope","n"+$80,"I",-1
	dc.w	L_PrtClose,-1
	dc.b	"printer clos","e"+$80,"I",-1
	dc.w	L_PrtSend,-1
	dc.b	"printer sen","d"+$80,"I2",-1
	dc.w	L_PrtRaw,-1
	dc.b	"printer ou","t"+$80,"I0,0",-1
	dc.w	L_PrtDump1,-1
	dc.b	"!printer dum","p"+$80,"I0",-2	
	dc.w	L_PrtDump2,-1
	dc.b	$80,"I0,0t0,0",-2 
	dc.w	L_PrtDump3,-1
	dc.b	$80,"I0,0t0,0,0,0,0",-1	
	dc.w	L_PrtAbort,-1
	dc.b	"printer abor","t"+$80,"I",-1
	dc.w	-1,L_PrtCheck
	dc.b 	"printer chec","k"+$80,"0",-1
	dc.w	-1,L_PrtOnLine
	dc.b	"printer onlin","e"+$80,"0",-1
	dc.w	-1,L_PrtBase
	dc.b	"printer bas","e"+$80,"0",-1
	dc.w	-1,L_PrtError
	dc.b	"printer erro","r"+$80,"0",-1
; Parallel commands
; ~~~~~~~~~~~~~~~~~
	dc.w   	L_ParOpen,-1
	dc.b	"parallel ope","n"+$80,"I",-1
	dc.w	L_ParClose,-1
	dc.b	"parallel clos","e"+$80,"I",-1
	dc.w	L_ParSend,-1
	dc.b	"parallel sen","d"+$80,"I2",-1
	dc.w	L_ParRaw,-1
	dc.b	"parallel ou","t"+$80,"I0,0",-1
	dc.w	L_ParAbort,-1
	dc.b	"parallel abor","t"+$80,"I",-1
	dc.w	-1,L_ParCheck
	dc.b 	"parallel chec","k"+$80,"0",-1
	dc.w	-1,L_ParStatus
	dc.b	"parallel statu","s"+$80,"0",-1
	dc.w	-1,L_ParBase
	dc.b	"parallel bas","e"+$80,"0",-1
	dc.w	-1,L_ParError
	dc.b	"parallel erro","r"+$80,"0",-1
	dc.w	-1,L_ParInput1
	dc.b	"!parallel input","$"+$80,"20",-2
	dc.w	-1,L_ParInput2
	dc.b	$80,"20,0",-2

	dc.w	0
C_Lib

******************************************************************
*		COLD START
L0	movem.l	a3-a6,-(sp)
	lea	DT(pc),a3
	move.l	a3,ExtAdr+ExtNb*16(a5)
	lea	SerDef(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+4(a5)
	lea	SerEnd(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+8(a5)
	movem.l	(sp)+,a3-a6
	moveq	#ExtNb,d0		* NO ERRORS
	rts

******* SCREEN RESET
SerDef	
******* QUIT
SerEnd	Rbsr	L_SCloseA
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.Close
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.Close
	rts

*************** Data zone
DT
SerialIO	ds.l	3*NSerial	Serial IO Port
PrinterIO	ds.l	3		Printer IO Port
ParallelIO	ds.l	3		Parallel IO Port
BufIn		dc.l	0
Prt_Query	dc.l	0		Espace pour informations

; Screen Dump
; ~~~~~~~~~~~
width:		dc.w	0
height:		dc.w	0
viewModes	dc.w	0
depth:		dc.w	0
screen		dc.l	0
vPort		dc.l	0
rPort		dc.l	0
colourmap	dc.l	0
oldCtable	dc.l	0
special		dc.w	$84
srcX		dc.w	0
srcY		dc.w	0
pwidth		dc.w	0
pheight		dc.w	0
temp1		dc.w	0
temp2		dc.w	0
destCols	dc.l	0
destRows	dc.l	0
ScreenBase:	dc.l 	0

; Nom des devices
; ~~~~~~~~~~~~~~~
SerName		dc.b	"serial.device",0
PrtName		dc.b	"printer.device",0
ParName		dc.b	"parallel.device",0
		even

L1
L2

***********************************************************
*	OPEN SERIAL DEVICE

******* Seropen logicnumber,physicnumber[,shared,xdisabled,7wires]	
L_SerOp2	equ	3
L3	clr.l	-(a3)
	clr.l	-(a3)
	clr.l	-(a3)
	Rbra	L_SerOp5
L_SerOp5	equ	4
L4	move.l	16(a3),d0
	Rbsr	L_GetSerial
; Opening parameters
	move.w	#IO_SERFLAGS,d5
	swap	d5
	clr.w	d5
	tst.l	(a3)+
	beq.s	SerOpA
	bset	#SERB_7WIRE,d5
SerOpA	bset	#SERB_XDISABLED,d5
	tst.l	(a3)+
	beq.s	SerOpB
	bclr	#SERB_XDISABLED,d5
SerOpB  tst.l	(a3)+
	beq.s	SerOpC
	bset	#SERB_SHARED,d5
SerOpC	Dlea	SerName,a0
	moveq	#IOEXTSER_SIZE,d0
	move.l	(a3),d1
	moveq	#0,d2
	move.w	#145,d3
	moveq	#16,d4
	Rjsr	L_Dev.Open
	move.l	(a3)+,d0
	addq.l	#4,a3
	beq.s	.PaSet
* If NOT user-serial (#0),
* default settings for French MINITEL: 1200/7/1 Stop/EVEN parity
	move.l	(a2),a1
	move.l	#1200,IO_BAUD(a1)
	move.b	#7,IO_READLEN(a1)
	move.b	#7,IO_WRITELEN(a1)
	move.b	#1,IO_STOPBITS(a1)
	bset	#SERB_XDISABLED,IO_SERFLAGS(a1)
	bset	#SERB_PARTY_ON,IO_SERFLAGS(a1)
	bclr	#SERB_PARTY_ODD,IO_SERFLAGS(a1)
	bclr	#SEXTB_MSPON,IO_EXTFLAGS+3(a1)
	bclr	#SEXTB_MARK,IO_EXTFLAGS+3(a1)
* Appelle le device au moins une fois! BUG!
.PaSet	move.l	(a2),a1
	Rbra	L_Stpar

***********************************************************
*	Serclose [N]
L_SerClo1	equ	5
L5	move.l	(a3)+,d0
	Rbsr	L_GetSerial
	Rjmp	L_Dev.Close
;-----> Close ALL channels
L_SerClo0	equ	6	
L_SCloseA	equ	6
L6	Dlea	SerialIO,a2
	moveq	#NSerial-1,d2
SCloA1	Rjsr	L_Dev.Close
	lea	12(a2),a2
	dbra	d2,SCloA1
	rts
L7	

***********************************************************
*	Serial Send ser,A$
L_SerSend	equ	8
L8	move.l	(a3)+,d2
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d2,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	Rbeq	L_IFonc
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.SendIO
***********************************************************
*	Serial Out ser,address,length
L_SerOut	equ	9
L9	move.l	(a3)+,d2
	Rbmi	L_IFonc
	Rbeq	L_IFonc
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d1,IO_DATA(a1)
	move.l	d2,IO_LENGTH(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.SendIO
***********************************************************
*	=Serial Get(ser)
L_SerGet	equ	10
L10	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.w	#SDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	moveq	#-1,d3
	move.l	IO_ACTUAL(a1),d0
	beq.s	SerINo
	Dlea	BufIn,a0
	move.l	a0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	moveq	#CMD_READ,d0
	Rjsr	L_Dev.DoIO
	moveq	#0,d3
	Dlea	BufIn,a0
	move.b	(a0),d3
SerINo	moveq	#0,d2
	rts
***********************************************************
*	=Serial Input$(Ser) 
L_SerInp	equ	11
L11	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	moveq	#SDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	move.l	IO_ACTUAL(a1),d4
	beq.s	SInpNo
	cmp.l	#65530,d4
	Rbcc	L_IFonc
* Ask for string space...
	movem.l	a1/a2,-(sp)
	move.l	d4,d3
	and.w	#$FFFE,d3		* Only EVEN!
	addq.w	#2,d3
	Rjsr	L_Demande
	lea	2(a1,d3.w),a1
	move.l	a1,HiChaine(a5)
* Send to device...
	movem.l	(sp)+,a1/a2
	move.l	a0,d3
	move.w	d4,(a0)+
	move.l	a0,IO_DATA(a1)
	move.l	d4,IO_LENGTH(a1)
	moveq	#CMD_READ,d0
	Rjsr	L_Dev.DoIO
	moveq	#2,d2
	rts
* Nothing to return
SInpNo	move.l	ChVide(a5),d3		* Empty string
	moveq	#2,d2
	rts

***********************************************************
*	Serial Speed ser,baud
L_SerSp		equ	12
L12	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d1,IO_BAUD(a1)
	Rbra	L_Stpar
L_Stpar		equ	13
L13	moveq	#SDCMD_SETPARAMS,d0
	Rjmp	L_Dev.DoIO
***********************************************************
*	Serial Bit ser,number,stop
L_SerBit	equ	14
L14	move.l	(a3)+,d2
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.b	d1,IO_READLEN(a1)
	move.b	d1,IO_WRITELEN(a1)
	move.b	d2,IO_STOPBITS(a1)
	Rbra	L_Stpar
***********************************************************
*	Serial Parity ser,on/off/odd/even/mspon
L_SerPar	equ	15
L15	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	bclr	#SERB_PARTY_ON,IO_SERFLAGS(a1)
	bclr	#SERB_PARTY_ODD,IO_SERFLAGS(a1)
	bclr	#SEXTB_MSPON,IO_EXTFLAGS+3(a1)
	bclr	#SEXTB_MARK,IO_EXTFLAGS+3(a1)
; -1-> NO PARITY
	tst.w	d1
	bmi.s	.parX
; 0--> EVEN
	bne.s	.par1
	bset	#SERB_PARTY_ON,IO_SERFLAGS(a1)
	bra.s	.parX
; 1--> ODD
.par1	cmp.w	#1,d1
	bne.s	.par2
	bset	#SERB_PARTY_ON,IO_SERFLAGS(a1)
	bset	#SERB_PARTY_ODD,IO_SERFLAGS(a1)
	bra.s	.parX
; 2--> SPACE
.par2	cmp.w	#2,d1
	bne.s	.par3
	bset	#SEXTB_MSPON,IO_EXTFLAGS+3(a1)
	bra.s	.parX
; 3--> MARK
.par3	cmp.w	#3,d1
	bne.s	.parX
	bset	#SEXTB_MSPON,IO_EXTFLAGS+3(a1)
	bset	#SEXTB_MARK,IO_EXTFLAGS+3(a1)
; Envoie
.parX	Rbra	L_Stpar	
**********************************************************
*	Serial X ser,value
L_SerX		equ	16
L16	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	bset	#SERB_XDISABLED,IO_SERFLAGS(a1)
	cmp.l	#-1,d1
	Rbeq	L_Stpar
	bclr	#SERB_XDISABLED,IO_SERFLAGS(a1)
	move.l	d1,IO_CTLCHAR(a1)
	Rbra	L_Stpar
**********************************************************
*	Serial Buffer ser,length
L_SerBuf	equ	17
L17	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d1,IO_RBUFLEN(a1)
	Rbra	L_Stpar
**********************************************************
*	Serial Fast ser
L_SerFast	equ	18
L18	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	bclr	#SERB_PARTY_ON,IO_SERFLAGS(a1)
	bclr	#SEXTB_MSPON,IO_EXTFLAGS+3(a1)
	bset	#SERB_XDISABLED,IO_SERFLAGS(a1)
	move.b	#8,IO_READLEN(a1)
	move.b	#8,IO_WRITELEN(a1)
	bset	#SERB_RAD_BOOGIE,IO_SERFLAGS(a1)
	Rbra	L_Stpar
**********************************************************
*	Serial Slow Ser
L_SerSlow	equ	19
L19	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	bclr	#SERB_RAD_BOOGIE,IO_SERFLAGS(a1)
	Rbra	L_Stpar
**********************************************************
*	=Serial Check(N)
L_SerChk	equ	20
L20	move.l	(a3)+,d0
	Rbsr	L_GetSerial
	Rjsr	L_Dev.CheckIO
	move.l	d0,d3
	beq.s	SerChk1
	moveq	#-1,d3
SerChk1	moveq	#0,d2	
	rts
**********************************************************
*	=Serial Error(n)
L_SerE		equ	21
L21	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	moveq	#0,d3
	move.b	IO_ERROR(a1),d3
	moveq	#0,d2
	rts

**********************************************************
*	=Serial Status(n)
L_SerStatus	equ	22
L22	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	moveq	#SDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	moveq	#0,d3
	move.l	(a2),a1
	move.w	IO_STATUS(a1),d3
	moveq	#0,d2
	rts

**********************************************************
*		=SERIAL BASE
L_SerBase	equ	23	
L23	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	a1,d3
	moveq	#0,d2	
	rts

;-----> IO #D0 to A1/a2
L_GetSerA1	equ	24
L24	Rbsr	L_GetSerial
	Rjmp	L_Dev.GetIO
;-----> Find IO address > D0
L_GetSerial	equ	25
L25	cmp.l	#NSerial,d0
	Rbcc	L_IFonc
	mulu	#12,d0
	Dlea	SerialIO,a2
	add.w	d0,a2
	rts

*********************************************************************
*		SERIAL ABORT channel
L_SerAbort	equ	26
L26	move.l	(a3)+,d0
	Rbsr	L_GetSerial
	Rjmp	L_Dev.AbortIO

L27
L28
*********************************************************************
*	ERRORS
L_IFonc		equ	29
L29	moveq	#23,d0			* Illegal function call
	Rjmp	L_Error
L30	
L31
L32

**********************************************************
*		=PRINTER BASE
L_PrtBase	equ	33
L33	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	move.l	a1,d3
	moveq	#0,d2	
	rts
**********************************************************
*		=PRINTER CHECK
L_PrtCheck	equ	34
L34	Dlea	PrinterIO,a2
	Rjsr	L_Dev.CheckIO
	move.l	d0,d3
	beq.s	PrtChk1
	moveq	#-1,d3
PrtChk1	moveq	#0,d2	
	rts

*********************************************************************
*		PRINTER OPEN
L_PrtOpen	equ	35
L35	Dlea	PrtName,a0
	Dlea	PrinterIO,a2
	moveq	#64,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#161,d3		Premier message erreurs
	moveq	#7,d4		7 messages
	moveq	#0,d5
	Rjmp	L_Dev.Open

*********************************************************************
*		PRINTER CLOSE
L_PrtClose	equ	36
L36	Dlea	PrinterIO,a2
	Rjmp	L_Dev.Close

*********************************************************************
*		=PRINTER ERROR
L_PrtError	equ	37
L37	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	moveq	#0,d3
	move.b	IO_ERROR(a1),d3
	moveq	#0,d2
	rts

***********************************************************
*		PRINTER SEND A$
L_PrtSend	equ	38
L38	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	move.l	(a3)+,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	Rbeq	L_IFonc
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.SendIO

***********************************************************
*		PRINTER SENDRAW ad,lenght
L_PrtRaw	equ	39
L39	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	move.l	(a3)+,d0
	Rbeq	L_IFonc
	move.l	(a3)+,a0
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#PRD_RAWWRITE,d0
	Rjmp	L_Dev.SendIO

*********************************************************************
*		PRINTER ABORT
L_PrtAbort	equ	40
L40	Dlea	PrinterIO,a2
	Rjmp	L_Dev.AbortIO

*********************************************************************
*		=PRINTER ONLINE
L_PrtOnLine	equ	41
L41	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	Dlea	Prt_Query,a0
	move.l	a0,IO_DATA(a1)
	moveq	#PRD_QUERY,d0
	Rjsr	L_Dev.DoIO
	Dlea	Prt_Query,a0
	moveq	#0,d3
	move.l	(a2),a1
	cmp.l	#1,IO_ACTUAL(a1)
	bne.s	.Skip
	btst	#0,(a0)
	bne.s	.Skip
	moveq	#-1,d3
.Skip	moveq	#0,d2
	rts

*********************************************************************
*		PRINTER DUMP

; No parameters
; ~~~~~~~~~~~~~
L_PrtDump1	equ	42
L42	Dload	a2
	Rbsr	L_GetScr
	move.w	width-DT(a2),pwidth-DT(a2)
	move.w	height-DT(a2),pheight-DT(a2)
	move.l	#0,destCols-DT(a2)
	move.l	#0,destRows-DT(a2)
	move.w	#$8c,special-DT(a2)	; ASPECT | FULLROWS | FULLCOLS
	Rbra	L_Dump

; Four parameters
; ~~~~~~~~~~~~~~~
L_PrtDump2	equ	43
L43	Dload	a2
	Rbsr	L_Dump2a
	
; Calculate proportional DestX, DestY
	clr.l	d0
	clr.l	d1
	move.w	pwidth-DT(a2),d0
	tst.w	d0
	Rbeq	L_IFonc	
	move.w	width-DT(a2),d1
	divu.w	d0,d1
	tst.w	d1
	Rbeq	L_IFonc
	lea	destCols-DT(a2),a0
	move.l	#$ffff,d0
	divu.w	d1,d0
	move.l	d0,(a0)
	andi.l	#$ffff,(a0)
	move.l	#$10,d1
	move.l	(a0),d0
	rol.l	d1,d0
	move.l	d0,(a0)

	clr.l	d0
	clr.l	d1
	move.w	pheight-DT(a2),d0
	tst.w	d0
	Rbeq	L_IFonc
	move.w	height-DT(a2),d1
	divu.w	d0,d1
	tst.w	d1
	Rbeq	L_IFonc
	lea	destRows-DT(a2),a0
	move.l	#$ffff,d0
	divu.w	d1,d0
	move.l	d0,(a0)
	andi.l	#$ffff,(a0)
	move.l	#$10,d1
	move.l	(a0),d0
	rol.l	d1,d0
	move.l	d0,(a0)
	lea	special-DT(a2),a0
	move.w	#$b0,(a0)
	Rbra 	L_Dump

; Tous les parametres
; ~~~~~~~~~~~~~~~~~~~
L_PrtDump3	equ	44
L44	movem.l	a4-a6,-(sp)
	Dload	a2
	Rbsr	L_Dump3a
	Rbra	L_Dump

; DUMP Routines...
; ~~~~~~~~~~~~~~~~
L_Dump3a	equ	45
L45	lea	special-DT(a2),a0
	lea	2(a3),a3
	move.w	(a3)+,(a0)		; special
	lea	destRows-DT(a2),a0
	move.l	(a3)+,(a0)		; destY
	lea	destCols-DT(a2),a0
	move.l	(a3)+,(a0)		; destY
	Rbra	L_Dump2a
L_Dump2a	equ	46
L46	lea	pheight-DT(a2),a0
	lea	2(a3),a3
	move.w	(a3)+,(a0)		; bottom y
	lea	pwidth-DT(a2),a0
	lea	2(a3),a3
	move.w	(a3)+,(a0)		; bottom x
	lea	srcY-DT(a2),a0
	lea	2(a3),a3
	move.w	(a3)+,(a0)		; srcy
	lea	srcX-DT(a2),a0
	lea	2(a3),a3
	move.w	(a3)+,(a0)		; srcx
	Rbsr	L_GetScr
; get srcX,Y back
	move.w	srcX-DT(a2),d0
	move.w	srcY-DT(a2),d1
; calculate width, height
	neg.w	d0
	neg.w	d1
	lea	pwidth-DT(a2),a0
	add.w	d0,(a0)			; width = -srcX+bottomX
	lea	pheight-DT(a2),a0
	add.w	d1,(a0)			; height = -srcY+bottomY
	rts
; Do the screen dump
; ~~~~~~~~~~~~~~~~~~
L_Dump		equ	47
L47	
; Initialise colour map
	moveq	#32,d0
	move.l	a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	-570(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq	cl5
	move.l	d0,colourmap-DT(a2)
	move.l	d0,a0
	moveq	#0,d0
	move.l	ScreenBase-DT(a2),a1
	lea	EcPal(a1),a1
.loop	move.w	(a1)+,d1
	move.w	d1,d3
	and.w	#$f,d3
	lsr.w	#4,d1
	move.w	d1,d2
	and.w	#$f,d2
	lsr.w	#4,d1
	movem.l	d0/a0-a1/a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	-$276(a6)
	movem.l	(sp)+,d0/a0-a1/a6
	addq.w	#1,d0
	cmp.w	#32,d0
	bne.s	.loop

; Dump the rast port!!!
	move.l	PrinterIO-DT(a2),a1
	move.w	#11,28(a1)		; command
	move.l	T_RastPort(a5),32(a1)	; rastPort
	move.l	colourmap-DT(a2),36(a1)	; colourmap
	move.w	viewModes-DT(a2),40+2(a1)	; viewmodes
	move.w	srcX-DT(a2),44(a1)	; srcX
	move.w	srcY-DT(a2),46(a1)	; srcY
	move.w	pwidth-DT(a2),48(a1)	; srcWidth
	move.w	pheight-DT(a2),50(a1)	; srcHeight
	move.l	destCols-DT(a2),52(a1)	; destCols
	move.l	destRows-DT(a2),56(a1)	; destRows
	move.w	special-DT(a2),60(a1)	; special
	move.l	a6,-(sp)
	move.l	$4.w,a6
	jsr	_LVOSendIO(a6)		; Do it!!!! (at last)
	move.l	(sp)+,a6
	move.w	d0,-(sp)

; Free colour map
cl8	move.l	colourmap-DT(a2),a0
	move.l	a6,-(sp)
	move.l	T_GfxBase(a5),a6
	jsr	-576(a6)		; Free colourmap
	move.l	(sp)+,a6
cl5
; Return to the user
	move.w	(sp)+,d0
	bne.s	.Err
	rts
; Error
.Err	Rjmp	L_Dev.Error

; Return informations about the current screen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_GetScr	equ	48
L48	move.l	ScOnAd(a5),d0	
	beq.s	.Err				; get the address of the screen 
	move.l	d0,a0
	move.l 	a0,ScreenBase-DT(a2)
; Now we need to extract all the information about the screen
	move.w	EcTx(a0),width-DT(a2)		; width
	move.w	EcTy(a0),height-DT(a2)		; height
	move.w	EcCon0(a0),d0
	and.w	#%1000100010000100,d0		; Hires / HAM / DualPF / Halfbrite
	move.w	d0,viewModes-DT(a2)		; View Modes
	move.w	EcNPlan(a0),depth-DT(a2)	; depth
	rts
.Err	moveq	#47,d0				; Screen not opened
	Rjmp	L_Error

L49
L50
L51
L52
**********************************************************
*		=PARALLEL BASE
L_ParBase	equ	53
L53	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	a1,d3
	moveq	#0,d2	
	rts

**********************************************************
*		=PARALLEL CHECK
L_ParCheck	equ	54
L54	Dlea	ParallelIO,a2
	Rjsr	L_Dev.CheckIO
	move.l	d0,d3
	beq.s	ParChk1
	moveq	#-1,d3
ParChk1	moveq	#0,d2	
	rts

*********************************************************************
*		PARALLEL OPEN
L_ParOpen	equ	55
L55	Dlea	ParName,a0
	Dlea	ParallelIO,a2
	moveq	#62,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#171,d3		Premier message erreurs
	moveq	#7,d4		7 messages
	moveq	#0,d5
	Rjmp	L_Dev.Open

*********************************************************************
*		PARALLEL CLOSE
L_ParClose	equ	56
L56	Dlea	ParallelIO,a2
	Rjmp	L_Dev.Close

*********************************************************************
L57

***********************************************************
*		PARALLEL SEND A$
L_ParSend	equ	58
L58	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	(a3)+,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	Rbeq	L_IFonc
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.DoIO

***********************************************************
*		PARALLEL SENDRAW ad,lenght
L_ParRaw	equ	59
L59	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	(a3)+,d0
	Rbeq	L_IFonc
	move.l	(a3)+,a0
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#PRD_RAWWRITE,d0
	Rjmp	L_Dev.DoIO

*********************************************************************
*		PARALLEL ABORT
L_ParAbort	equ	60
L60	Dlea	ParallelIO,a2
	Rjmp	L_Dev.AbortIO

*********************************************************************
*		=PARALLEL STATUS
L_ParStatus	equ	61
L61	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	moveq	#PDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	moveq	#0,d3
	move.l	(a2),a1
	move.b	$34(a1),d3
	moveq	#0,d2
	rts

*********************************************************************
*		=PARALLEL ERROR
L_ParError	equ	62
L62	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	moveq	#0,d3
	move.l	(a2),a1
	move.b	IO_ERROR(a1),d3
	moveq	#0,d2
	rts

*********************************************************************
*		=PARALLEL INPUT$(long[,stop])
L_ParInput1	equ	63
L63	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	bclr	#PARB_EOFMODE,IO_PARFLAGS(a1)
	Rbra	L_ParInput
L_ParInput2	equ	64
L64	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	(a3)+,d3
	bset	#PARB_EOFMODE,IO_PARFLAGS(a1)
	beq.s	.Set
	cmp.b	IO_PTERMARRAY(a1),d3
	beq.s	.Skip
.Set	moveq	#7,d0
	lea	IO_PTERMARRAY(a1),a0
.Loop	move.b	d3,(a0)+
	dbra	d0,.Loop
	moveq	#PDCMD_SETPARAMS,d0
	Rjsr	L_Dev.DoIO
.Skip	Rbra	L_ParInput
; Appel
L_ParInput	equ	65
L65	move.l	(a3)+,d4
	Rble	L_IFonc
	cmp.l	#65000,d4
	Rbcc	L_IFonc
* Ask for string space...
	movem.l	a1/a2,-(sp)
	move.l	d4,d3
	and.l	#$FFFE,d3
	addq.w	#2,d3
	Rjsr	L_Demande
	lea	2(a1,d3.w),a1
	move.l	a1,HiChaine(a5)
	movem.l	(sp)+,a1/a2
* Send to device...
	move.l	a0,d3
	move.w	d4,(a0)+
	move.l	a0,IO_DATA(a1)
	move.l	d4,IO_LENGTH(a1)
	moveq	#CMD_READ,d0
	Rjsr	L_Dev.DoIO
	moveq	#2,d2
	rts

L66
L67
L68
L69

**********************************************************************
*	SPACE FOR ERROR ROUTINES...
L70
L71
L72
*********************************************************************

******* TITLE MESSAGE
C_Title	dc.b	"AMOSPro IO Devices Extension V "
	Version
	dc.b	0,"$VER: "
	Version
	dc.b	0
	Even

******* END OF THE EXTENSION
C_End	dc.w	0
	even
