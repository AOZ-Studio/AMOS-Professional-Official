
;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; Serial / Parallel / Printer extension source code
; By Fran�ois Lionet
; AMOS, AMOSPro, AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOSPro V2.0 and over
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
;
; Please refer to the _Music.s file for more informations...
;
;---------------------------------------------------------------------

ExtNb		equ	6-1

;		AMIGA's includes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		INCDIR		"includes/"
		INCLUDE		"Exec/Types.I"
		INCLUDE		"Exec/Exec.I"
		INCLUDE 	"Devices/Serial.I"
		INCLUDE		"Devices/PrtBase.I"
		INCLUDE		"Devices/Printer.I"
		INCLUDE		"Devices/PrtGfx.I"
		INCLUDE		"Devices/Parallel.I"

;---------------------------------------------------------------------
;		Include the files automatically calculated by
;		Library_Digest.AMOS
;---------------------------------------------------------------------
 		Include	"+AMOS_Includes.s"
		Include	"+Version.s"
		Include	"+IO_Ports_Size.s"
		Include	"+IO_Ports_Labels.s"

; 		Number of serial channels allowed
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NSerial		equ	4


Dlea		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\2
		add.w	#\1-DT,\2
		ENDM
Dload		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\1
		ENDM


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

;---------------------------------------------------------------------
;		TOKEN TABLE
;---------------------------------------------------------------------
;		TOKEN_START

C_Tk
		dc.w 	1,0
		dc.b 	$80,-1
		dc.w	L_InSerialOpen2,L_Nul
		dc.b	"!serial ope","n"+$80,"I0,0",-2
		dc.w	L_InSerialOpen5,L_Nul
		dc.b	$80,"I0,0,0,0,0",-1
		dc.w	L_InSerialClose0,L_Nul
		dc.b	"!serial clos","e"+$80,"I",-2
		dc.w	L_InSerialClose1,L_Nul
		dc.b	$80,"I0",-1
		dc.w	L_InSerialSpeed,L_Nul
		dc.b	"serial spee","d"+$80,"I0,0",-1
		dc.w	L_Nul,L_FnSerialCheck
		dc.b	"serial chec","k"+$80,"00",-1
		dc.w 	L_InSerialSend,L_Nul
		dc.b	"serial sen","d"+$80,"I0,2",-1
		dc.w 	L_InSerialSpeed,L_Nul
		dc.b	"serial spee","d"+$80,"I0,0",-1
		dc.w 	L_InSerialBits,L_Nul
		dc.b	"serial bit","s"+$80,"I0,0,0",-1
		dc.w 	L_InSerialX,L_Nul
		dc.b	"serial ","x"+$80,"I0,0",-1
		dc.w 	L_InSerialBuf,L_Nul
		dc.b	"serial bu","f"+$80,"I0,0",-1
		dc.w 	L_InSerialParity,L_Nul
		dc.b	"serial parit","y"+$80,"I0,0",-1
		dc.w	L_Nul,L_FnSerialGet
		dc.b	"serial ge","t"+$80,"00",-1
		dc.w	L_Nul,L_FnSerialInput
		dc.b	"serial input","$"+$80,"20",-1
		dc.w	L_InSerialFast,L_Nul
		dc.b	"serial fas","t"+$80,"I0",-1
		dc.w	L_InSerialSlow,L_Nul
		dc.b	"serial slo","w"+$80,"I0",-1
		dc.w	L_Nul,L_FnSerialError
		dc.b	"serial erro","r"+$80,"00",-1
		dc.w	L_InSerialOut,L_Nul
		dc.b	"serial ou","t"+$80,"I0,0,0",-1
		dc.w	L_Nul,L_FnSerialStatus
		dc.b	"serial statu","s"+$80,"00",-1
		dc.w	L_Nul,L_FnSerialBase
		dc.b	"serial bas","e"+$80,"00",-1
		dc.w	L_InSerialAbort,L_Nul
		dc.b	"serial abor","t"+$80,"I0",-1

; Printer commands
; ~~~~~~~~~~~~~~~~
		dc.w   	L_InPrinterOpen,L_Nul
		dc.b	"printer ope","n"+$80,"I",-1
		dc.w	L_InPrinterClose,L_Nul
		dc.b	"printer clos","e"+$80,"I",-1
		dc.w	L_InPrinterSend,L_Nul
		dc.b	"printer sen","d"+$80,"I2",-1
		dc.w	L_InPrinterOut,L_Nul
		dc.b	"printer ou","t"+$80,"I0,0",-1
		dc.w	L_InPrinterDump0,L_Nul
		dc.b	"!printer dum","p"+$80,"I",-2
		dc.w	L_InPrinterDump4,L_Nul
		dc.b	$80,"I0,0t0,0",-2
		dc.w	L_InPrinterDump7,L_Nul
		dc.b	$80,"I0,0t0,0,0,0,0",-1
		dc.w	L_InPrinterAbort,L_Nul
		dc.b	"printer abor","t"+$80,"I",-1
		dc.w	L_Nul,L_FnPrinterCheck
		dc.b 	"printer chec","k"+$80,"0",-1
		dc.w	L_Nul,L_FnPrinterOnline
		dc.b	"printer onlin","e"+$80,"0",-1
		dc.w	L_Nul,L_FnPrinterBase
		dc.b	"printer bas","e"+$80,"0",-1
		dc.w	L_Nul,L_FnPrinterError
		dc.b	"printer erro","r"+$80,"0",-1

; Parallel commands
; ~~~~~~~~~~~~~~~~~
		dc.w   	L_InParallelOpen,L_Nul
		dc.b	"parallel ope","n"+$80,"I",-1
		dc.w	L_InParallelClose,L_Nul
		dc.b	"parallel clos","e"+$80,"I",-1
		dc.w	L_InParallelSend,L_Nul
		dc.b	"parallel sen","d"+$80,"I2",-1
		dc.w	L_InParallelOut,L_Nul
		dc.b	"parallel ou","t"+$80,"I0,0",-1
		dc.w	L_InParallelAbort,L_Nul
		dc.b	"parallel abor","t"+$80,"I",-1
		dc.w	L_Nul,L_FnParallelCheck
		dc.b 	"parallel chec","k"+$80,"0",-1
		dc.w	L_Nul,L_FnParallelStatus
		dc.b	"parallel statu","s"+$80,"0",-1
		dc.w	L_Nul,L_FnParallelBase
		dc.b	"parallel bas","e"+$80,"0",-1
		dc.w	L_Nul,L_FnParallelError
		dc.b	"parallel erro","r"+$80,"0",-1
		dc.w	L_Nul,L_FnParallelInput1
		dc.b	"!parallel input","$"+$80,"20",-2
		dc.w	L_Nul,L_FnParallelInput2
		dc.b	$80,"20,0",-2
;		TOKEN_END
		dc.w 	0
		dc.l	0			Important!


;---------------------------------------------------------------------
	Lib_Ini	0
;---------------------------------------------------------------------

C_Lib

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	COLD START
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	IOCold
; - - - - - - - - - - - - -
	cmp.l	#"APex",d1		Version 1.10 or over?
	bne.s	BadVer
	movem.l	a3-a6,-(sp)
	lea	DT(pc),a3
	move.l	a3,ExtAdr+ExtNb*16(a5)
	lea	SerDef(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+4(a5)
	lea	SerEnd(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+8(a5)
	movem.l	(sp)+,a3-a6
	moveq	#ExtNb,d0		* NO ERRORS
	move.w	#VerNumber,d1		* Current version
	rts
; In case this extension is runned on AMOSPro V1.00
BadVer	moveq	#-1,d0			* Bad version number
	sub.l	a0,a0
	rts

;	SCREEN RESET (called by AMOSPro)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SerDef
;	QUIT (called by AMOSPro)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SerEnd	Rbsr	L_InSerialClose0
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.CloseA2
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.CloseA2
	rts

*************** Data zone
DT
SerialIO	ds.l	3*NSerial	Serial IO Port
PrinterIO	ds.l	3		Printer IO Port
ParallelIO	ds.l	3		Parallel IO Port
BufIn		dc.l	0
Prt_Query	dc.l	0		Espace pour informations
Prt_Request	dc.l	0		Ancien requester

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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Leave one empty routine here!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Empty
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SERIAL OPEN logicnumber,physicnumber[,shared,xdisabled,7wires]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialOpen2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	moveq	#0,d3
	move.l	d3,-(a3)
	move.l	d3,-(a3)
	Rbra	L_InSerialOpen5
; - - - - - - - - - - - - -
	Lib_Par	InSerialOpen5
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	16(a3),d0
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
* Call the device at least once
.PaSet	move.l	(a2),a1
	Rbra	L_Stpar

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serclose [N]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialClose1
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerial
	Rjmp	L_Dev.CloseA2
; - - - - - - - - - - - - -
	Lib_Par	InSerialClose0
; - - - - - - - - - - - - -
	Dlea	SerialIO,a2
	moveq	#NSerial-1,d2
.Loop	Rjsr	L_Dev.CloseA2
	lea	12(a2),a2
	dbra	d2,.Loop
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Send ser,A$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialSend
; - - - - - - - - - - - - -
	move.l	d3,d2
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d2,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	Rbeq	L_IOFonc
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.SendIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Out ser,address,length
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialOut
; - - - - - - - - - - - - -
	move.l	d3,d2
	Rbmi	L_IOFonc
	Rbeq	L_IOFonc
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d1,IO_DATA(a1)
	move.l	d2,IO_LENGTH(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.SendIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=Serial Get(ser)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnSerialGet
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	move.w	#SDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	moveq	#-1,d3
	move.l	IO_ACTUAL(a1),d0
	beq.s	.SerINo
	Dlea	BufIn,a0
	move.l	a0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	moveq	#CMD_READ,d0
	Rjsr	L_Dev.DoIO
	moveq	#0,d3
	Dlea	BufIn,a0
	move.b	(a0),d3
.SerINo	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=Serial Input$(Ser)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnSerialInput
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	moveq	#SDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	move.l	IO_ACTUAL(a1),d4
	beq.s	.No
	cmp.l	#String_Max,d4
	Rbcc	L_IOFonc
* Ask for string space...
	movem.l	a1/a2,-(sp)
	move.l	d4,d3
	and.w	#$FFFE,d3			* Only EVEN!
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
	bra.s	.Out
* Nothing to return
.No	move.l	ChVide(a5),d3		* Empty string
.Out	Ret_String

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Speed ser,baud
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialSpeed
; - - - - - - - - - - - - -
	move.l	d3,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d1,IO_BAUD(a1)
	Rbra	L_Stpar

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Bit ser,number,stop
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialBits
; - - - - - - - - - - - - -
	move.l	d3,d2
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.b	d1,IO_READLEN(a1)
	move.b	d1,IO_WRITELEN(a1)
	move.b	d2,IO_STOPBITS(a1)
	Rbra	L_Stpar

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Parity ser,on/off/odd/even/mspon
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialParity
; - - - - - - - - - - - - -
	move.l	d3,d1
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


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial X ser,value
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialX
; - - - - - - - - - - - - -
	move.l	d3,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	bset	#SERB_XDISABLED,IO_SERFLAGS(a1)
	cmp.l	#-1,d1
	Rbeq	L_Stpar
	bclr	#SERB_XDISABLED,IO_SERFLAGS(a1)
	move.l	d1,IO_CTLCHAR(a1)
	Rbra	L_Stpar

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Buf ser,length
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialBuf
; - - - - - - - - - - - - -
	move.l	d3,d1
	move.l	(a3)+,d0
	Rbsr	L_GetSerA1
	move.l	d1,IO_RBUFLEN(a1)
	Rbra	L_Stpar

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Fast ser
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialFast
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	bclr	#SERB_PARTY_ON,IO_SERFLAGS(a1)
	bclr	#SEXTB_MSPON,IO_EXTFLAGS+3(a1)
	bset	#SERB_XDISABLED,IO_SERFLAGS(a1)
	move.b	#8,IO_READLEN(a1)
	move.b	#8,IO_WRITELEN(a1)
	bset	#SERB_RAD_BOOGIE,IO_SERFLAGS(a1)
	Rbra	L_Stpar


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Serial Slow Ser
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialSlow
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	bclr	#SERB_RAD_BOOGIE,IO_SERFLAGS(a1)
	Rbra	L_Stpar

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=Serial Check(N)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnSerialCheck
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerial
	Rjsr	L_Dev.CheckIO
	move.l	d0,d3
	beq.s	.Out
	moveq	#-1,d3
.Out	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=Serial Error(n)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnSerialError
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	moveq	#0,d3
	move.b	IO_ERROR(a1),d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=Serial Status(n)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnSerialStatus
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	moveq	#SDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	moveq	#0,d3
	move.l	(a2),a1
	move.w	IO_STATUS(a1),d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=SERIAL BASE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnSerialBase
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerA1
	move.l	a1,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SERIAL ABORT channel
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InSerialAbort
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetSerial
	Rjmp	L_Dev.AbortIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Routines
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	GetSerA1
; - - - - - - - - - - - - -		-----> IO #D0 to A1/a2
	Rbsr	L_GetSerial
	Rjmp	L_Dev.GetIO
; - - - - - - - - - - - - -
	Lib_Def	GetSerial
; - - - - - - - - - - - - -		-----> Find IO address > D0
	cmp.l	#NSerial,d0
	Rbcc	L_IOFonc
	mulu	#12,d0
	Dlea	SerialIO,a2
	add.w	d0,a2
	rts
; - - - - - - - - - - - - -
	Lib_Def	Stpar
; - - - - - - - - - - - - -
	moveq	#SDCMD_SETPARAMS,d0
	Rjmp	L_Dev.DoIO




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PRINTER BASE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnPrinterBase
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	move.l	a1,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PRINTER CHECK
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnPrinterCheck
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.CheckIO
	move.l	d0,d3
	beq.s	.Skip
	moveq	#-1,d3
.Skip	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PRINTER OPEN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPrinterOpen
; - - - - - - - - - - - - -
	Rjsr	L_PRT_Close	Ferme LPRINT
	Dlea	PrtName,a0
	Dlea	PrinterIO,a2
	moveq	#64,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#161,d3		Premier message erreurs
	moveq	#7,d4		7 messages
	moveq	#0,d5
	Rjsr	L_Dev.Open
; Ask for printer device task, and forbid its requester...
	Dload	a2
	lea	PrtName-DT(a2),a1
	move.l	a6,-(sp)
	move.l	$4.w,a6
	jsr	_LVOFindTask(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Skip
	move.l	d0,a0
	move.l	$b8(a0),Prt_Request-DT(a2)
	move.l	#-1,$b8(a0)
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PRINTER CLOSE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPrinterClose
; - - - - - - - - - - - - -
	Dload	a2
; Restore printer.device requester
	tst.l	Prt_Request-DT(a2)
	beq.s	.Skip
	lea	PrtName-DT(a2),a1
	move.l	a6,-(sp)
	move.l	$4.w,a6
	jsr	_LVOFindTask(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Skip
	move.l	d0,a0
	move.l	Prt_Request-DT(a2),$b8(a0)
	clr.l	Prt_Request-DT(a2)
; Close device
.Skip	Dlea	PrinterIO,a2
	Rjmp	L_Dev.CloseA2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PRINTER ERROR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnPrinterError
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	moveq	#0,d3
	move.b	IO_ERROR(a1),d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PRINTER SEND A$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPrinterSend
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	move.l	d3,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	Rbeq	L_IOFonc
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.SendIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PRINTER OUT ad,lenght
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPrinterOut
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
	move.l	d3,d0
	Rbeq	L_IOFonc
	move.l	(a3)+,a0
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#PRD_RAWWRITE,d0
	Rjmp	L_Dev.SendIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PRINTER ABORT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPrinterAbort
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
	Rjmp	L_Dev.AbortIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PRINTER ONLINE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnPrinterOnline
; - - - - - - - - - - - - -
	Dlea	PrinterIO,a2
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
.Skip	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PRINTER DUMP [parameters!]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InPrinterDump0
; - - - - - - - - - - - - -
	Dload	a2
	Rbsr	L_GetScr
	move.w	width-DT(a2),pwidth-DT(a2)
	move.w	height-DT(a2),pheight-DT(a2)
	move.l	#0,destCols-DT(a2)
	move.l	#0,destRows-DT(a2)
	move.w	#$8c,special-DT(a2)	; ASPECT | FULLROWS | FULLCOLS
	Rbra	L_Dump
; - - - - - - - - - - - - -
	Lib_Par	InPrinterDump4
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	Dload	a2
	Rbsr	L_Dump2a

; Calculate proportional DestX, DestY
	clr.l	d0
	clr.l	d1
	move.w	pwidth-DT(a2),d0
	tst.w	d0
	Rbeq	L_IOFonc
	move.w	width-DT(a2),d1
	divu.w	d0,d1
	tst.w	d1
	Rbeq	L_IOFonc
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
	Rbeq	L_IOFonc
	move.w	height-DT(a2),d1
	divu.w	d0,d1
	tst.w	d1
	Rbeq	L_IOFonc
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

; - - - - - - - - - - - - -
	Lib_Par	InPrinterDump7
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	movem.l	a4-a6,-(sp)
	Dload	a2
	Rbsr	L_Dump3a
	Rbra	L_Dump

; - - - - - - - - - - - - -
	Lib_Def	Dump3a
; - - - - - - - - - - - - -
	lea	special-DT(a2),a0
	lea	2(a3),a3
	move.w	(a3)+,(a0)		; special
	lea	destRows-DT(a2),a0
	move.l	(a3)+,(a0)		; destY
	lea	destCols-DT(a2),a0
	move.l	(a3)+,(a0)		; destY
	Rbra	L_Dump2a
; - - - - - - - - - - - - -
	Lib_Def	Dump2a
; - - - - - - - - - - - - -
	lea	pheight-DT(a2),a0
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

; - - - - - - - - - - - - -
	Lib_Def	Dump
; - - - - - - - - - - - - -
; Check the structure
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.GetIO
; Initialise colour map
	Dload	a2
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
	move.l	PrinterIO-DT(a2),a1	; IO structure
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
	moveq	#11,d0			; command
	Dlea	PrinterIO,a2
	Rjsr	L_Dev.DoIO
	move.w	d0,-(sp)
	Dload	a2
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

;	Return informations about the current screen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; - - - - - - - - - - - - -
	Lib_Def	GetScr
; - - - - - - - - - - - - -
	move.l	ScOnAd(a5),d0
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


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PARALLEL BASE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnParallelBase
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	a1,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PARALLEL CHECK
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnParallelCheck
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.CheckIO
	move.l	d0,d3
	beq.s	.Skip
	moveq	#-1,d3
.Skip	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PARALLEL OPEN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InParallelOpen
; - - - - - - - - - - - - -
	Rjsr	L_PRT_Close
	Dlea	ParName,a0
	Dlea	ParallelIO,a2
	moveq	#62,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#171,d3		Premier message erreurs
	moveq	#7,d4		7 messages
	moveq	#0,d5
	Rjmp	L_Dev.Open

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PARALLEL CLOSE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InParallelClose
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjmp	L_Dev.CloseA2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PARALLEL SEND A$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InParallelSend
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	d3,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	Rbeq	L_IOFonc
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#CMD_WRITE,d0
	Rjmp	L_Dev.DoIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PARALLEL OUT ad,lenght
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InParallelOut
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	move.l	d3,d0
	Rbeq	L_IOFonc
	move.l	(a3)+,a0
	move.l	d0,IO_LENGTH(a1)
	move.l	a0,IO_DATA(a1)
	moveq	#PRD_RAWWRITE,d0
	Rjmp	L_Dev.DoIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	PARALLEL ABORT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InParallelAbort
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjmp	L_Dev.AbortIO

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PARALLEL STATUS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnParallelStatus
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	moveq	#PDCMD_QUERY,d0
	Rjsr	L_Dev.DoIO
	moveq	#0,d3
	move.l	(a2),a1
	move.b	$34(a1),d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PARALLEL ERROR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnParallelError
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	moveq	#0,d3
	move.l	(a2),a1
	move.b	IO_ERROR(a1),d3
	Ret_Int


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=PARALLEL INPUT$(long[,stop])
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	FnParallelInput1
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
	bclr	#PARB_EOFMODE,IO_PARFLAGS(a1)
	move.l	d3,-(a3)
	Rbra	L_ParInput
; - - - - - - - - - - - - -
	Lib_Par	FnParallelInput2
; - - - - - - - - - - - - -
	Dlea	ParallelIO,a2
	Rjsr	L_Dev.GetIO
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
; - - - - - - - - - - - - -
	Lib_Def	ParInput
; - - - - - - - - - - - - -
	move.l	(a3)+,d4
	Rble	L_IOFonc
	cmp.l	#String_Max,d4
	Rbcc	L_IOFonc
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
	Ret_String

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Jump to illegal function call
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	IOFonc
; - - - - - - - - - - - - -
	moveq	#23,d0			* Illegal function call
	Rjmp	L_Error

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Even if you do not have error messages, you MUST
;	leave TWO routines empty at the end...
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Empty
	Lib_Empty
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Finish the library
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_End
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 		TITLE OF THE EXTENSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_Title	dc.b	"AMOSPro IO Devices Extension V "
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
