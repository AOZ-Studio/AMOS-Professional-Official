; ______________________________________________________________________________
; ..............................................................................
; ...................................................................2222222....
; ................................................................22222222220...
; ...................................................222........222222.....222..
; ..............................................2202222222222..22000............
; ..................................22000.....20222222222200000200002...........
; .................................2002202...2222200222.220000000200000000022...
; ....................220002......22222200..2200002.......2200000...20000000000.
; ....................22222202....2220000022200000..........200002........200000
; .....200000.........2222200000222200220000000002..........200002........20000.
; .....00222202........2220022000000002200002000002........2000002000020000000..
; ....2222200000.......220002200000002.2000000000000222222000000..2000000002....
; ....220000200002......20000..200002..220000200000000000000002.......22........
; ...2220002.2200002....220002...22.....200002..0000000000002...................
; ...220000..222000002...20000..........200000......2222........................
; ...000000000000000000..200000..........00002..................................
; ..220000000022020000002.200002.........22.......______________________________
; ..0000002........2000000220022.................|
; .200000............2002........................| AMOS Compiler Extension
; .200002........................................| For AMOSPro 2.0 and over
; 220002.........................................|______________________________
; ______________________________________________________________________________
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
; ______________________________________________________________________________

;---------------------------------------------------------------------
;		Include the files automatically calculated by
;		Library_Digest.AMOS
;---------------------------------------------------------------------
 		Include	"+AMOS_Includes.s"
		Include	"+Version.s"
		Include	"+Compext_Size.s"
		Include	"+Compext_Labels.s"

		INCDIR	"Work:Includes/i/"
		Include "pp/powerpacker_lib.i"
		Include "pp/ppbase.i"

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 		Initialisation stuff
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ExtNb		equ	5-1

Dlea		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\2
		add.w	#\1-DT,\2
		ENDM
Dload		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\1
		ENDM

Cmp_Magic	equ	"Gaga"

		dc.l	C_Tk-C_Off
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
		dc.w 	L_Nul,L_Nul
		dc.b 	$80,-1
TkCmp		dc.w	L_CmpCall,L_Nul
		dc.b	"cmpcal","l"+$80,"I",-1
TkCOp		dc.w	L_CmpOpt,L_Nul
		dc.b	"comp option","s"+$80,"I2",-1
TkTston		dc.w	L_Rien,L_Nul
		dc.b	"comp test o","n"+$80,"I",-1
TkTstof		dc.w	L_Rien,L_Nul
		dc.b	"comp test of","f"+$80,"I",-1
TkTst		dc.w	L_Rien,L_Nul
		dc.b	"comp tes","t"+$80,"I",-1
		dc.w	L_Compile1,L_Nul
		dc.b	"!compil","e"+$80,"I2",-2
		dc.w	L_Compile2,L_Nul
		dc.b	$80,"I2,0",-1
		dc.w	L_Nul,L_CompErr
		dc.b	"comp err","$"+$80,"2",-1
		dc.w	L_CompLoad0,L_Nul
		dc.b	"!comp loa","d"+$80,"I",-2
		dc.w	L_CompLoad1,L_Nul
		dc.b	$80,"I2",-1
		dc.w	L_CompDel,L_Nul
		dc.b	"comp de","l"+$80,"I",-1
		dc.w	L_Nul,L_CompHere
		dc.b	"comp her","e"+$80,"0",-1
		dc.w	L_Nul,L_CompSize
		dc.b	"comp siz","e"+$80,"0",-1
		dc.w	L_Nul,L_Squash
		dc.b	"squas","h"+$80,"00,0,0,0,0",-1
		dc.w 	L_Nul,L_UnSquash
		dc.b	"unsquas","h"+$80,"00,0",-1
		dc.w	L_InppSave2,L_Nul
		dc.b	"!ppsav","e"+$80,"I2,0",-2
		dc.w	L_InppSave3,L_Nul
		dc.b	$80,"I2,0,0",-1
		dc.w	L_InppLoad1,L_Nul
		dc.b	"!pploa","d"+$80,"I2",-2
		dc.w	L_InppLoad2,L_Nul
		dc.b	$80,"I2,0",-1

;		TOKEN_END
		dc.w	0
		dc.l	0


;---------------------------------------------------------------------
	Lib_Ini	0
;---------------------------------------------------------------------

C_Lib

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COLD START
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Cmp_Cold
; - - - - - - - - - - - - -
	cmp.l	#"APex",d1		V1.10 or over?
	bne.s	.BadVer
* Poke les adresses
	lea	CD(pc),a0
	move.l	a0,ExtAdr+ExtNb*16(a5)
	lea	CmpEnd(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+8(a5)
* Termin�!
.NoCom	moveq	#ExtNb,d0		Numero extension
	move.w	#VerNumber,d1		Current AMOSPro Version
	rts
* Bad version
.BadVer	sub.l	a0,a0
	moveq	#-1,d0			Retour a l'envoyeur!
	rts

******* Routine END
CmpEnd:	Rbra	L_CompDel

; ---------------------------------------------------------------------
;		DATA ZONE
CD
Cmp_Vect	dc.l	0
Cmp_Jump	dc.l	0
Cmp_NSteps	dc.l	0
Cmp_Config	dc.l	0
pp_Base		dc.l	0
pp_Color	dc.l	0
pp_Flash	dc.l	0
pp_CrunchInfo	dc.l	0

Cmp_Name1	dc.b	"C:"
Cmp_Name2	dc.b	"APCmp",0
CSize		dc.l	0
CNumb		dc.l	0
LErreur		dc.w	0
Erreur		ds.b	80
pp_Name		dc.b	"powerpacker.library",0

		even
; ---------------------------------------------------------------------

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMPCALL: appel du programme compile!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CmpCall
; - - - - - - - - - - - - -
	moveq	#0,d0
	Rbra	L_Custom

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMP OPTIONS "command line"
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CmpOpt
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMPILE "command string"
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	Compile1
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	Dload	a2
	Rbsr	L_CompLoad0
	move.l	(a3)+,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	Cmp_Jump-CD(a2),a1
	jsr	4(a1)
	Rbra	L_FinComp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMPILE "Command line",magic
;	Special COMPILER.AMOS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	Compile2
; - - - - - - - - - - - - -
	Dload	a2
	move.l	(a3)+,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	cmp.w	#4,d0
	bne.s	.Start
	cmp.l	#"Step",(a0)
	beq.s	.Step
	cmp.l	#"Conf",(a0)
	beq.s	.Conf
	cmp.l	#"Cont",(a0)
	beq.s	.Cont
	cmp.l	#"Stop",(a0)
	beq.s	.Stop
	Rbra	L_FCall
; Stocke le nombre de pas
; ~~~~~~~~~~~~~~~~~~~~~~~
.Step	move.l	d3,Cmp_NSteps-CD(a2)
	rts
; Stocke l'adresse de la config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Conf	move.l	d3,Cmp_Config-CD(a2)
	rts
; Premier appel du compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Start	cmp.l	#Cmp_Magic,d3			Veut un magic!
	Rbne	L_FCall
	move.l	Cmp_NSteps-CD(a2),d1
	move.l	Cmp_Config-CD(a2),d2
	tst.l	Cmp_Vect-CD(a2)
	Rbeq	L_FCall
	move.l	Cmp_Jump-CD(a2),a1
	jsr	8(a1)
	bra.s	.Fin
; Arret du compilateur
; ~~~~~~~~~~~~~~~~~~~~
.Stop	cmp.l	#Cmp_Magic,d3
	Rbne	L_FCall
	move.l	Cmp_Jump-CD(a2),a1
	jsr	16(a1)
	bra.s	.Fin
; Appels suivants
; ~~~~~~~~~~~~~~~
.Cont	cmp.l	#Cmp_Magic,d3
	Rbne	L_FCall
	move.l	Cmp_Jump-CD(a2),a1
	jsr	12(a1)
; Retour de APCmp
; ~~~~~~~~~~~~~~~
.Fin	clr.l	ParamE(a5)		Zero si termine!
	tst.l	d0			D0>0 : message normal
	Rbpl	L_FinComp
	cmp.w	#-1,d0
	Rbne	L_OOMem			Out of memory!
	move.l	d1,ParamE(a5)		Position dans PARAM
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=COMP ERR$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CompErr
; - - - - - - - - - - - - -
	Dload	a2
	moveq	#0,d3
	move.w	LErreur-CD(a2),d3
	beq.s	.Vide
	Rjsr	L_Demande
	move.w	d3,d0
	move.l	a0,d3
	move.w	d0,(a1)+
	subq.w	#1,d0
	lea	Erreur-CD(a2),a0
.Loop1	move.b	(a0)+,(a1)+
	dbra	d0,.Loop1
	move.w	a1,d1
	and.w	#$0001,d1
	add.w	d1,a1
	move.l	a1,HiChaine(a5)
	moveq	#2,d2
	rts
.Vide	move.l	ChVide(a5),d3
	moveq	#2,d2
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMP TEST ON/OFF-> RIEN!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	Rien
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMP LOAD
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CompLoad0
; - - - - - - - - - - - - -
	Dload	a2
	lea	Cmp_Name2-CD(a2),a0	APCMP
	Rjsr	L_Sys_AddPath		+ path systeme
	Rbra	L_CLoad			= nom complet!

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	COMP LOAD "nom"
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CompLoad1
; - - - - - - - - - - - - -
	move.l	d3,a2
	Rjsr	L_NomDisc		Compute le nom >>> name1
	Rbra	L_CLoad

;	Charge le compilateur, nom= NAME1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Def	CLoad
	movem.l	a0-a2/d0-d2,-(sp)
	Dload	a2
	tst.l	Cmp_Vect-CD(a2)
	bne.s	.Loaded
	move.l	Name1(a5),d1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-150(a6)
	move.l	(sp)+,a6
	move.l	d0,Cmp_Vect-CD(a2)
	Rbeq	L_NFound
	lsl.l	#2,d0
	addq.l	#4,d0
	move.l	d0,a0
	cmp.l	#"APcp",20(a0)
	bne.s	.Error
	move.l	a0,Cmp_Jump-CD(a2)
.Loaded	movem.l	(sp)+,a0-a2/d0-d2
	rts
.Error	Rbsr	L_CompDel
	moveq	#95,d0
	Rjmp	L_Error

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	EFFACE LE COMPILATEUR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	CompDel
; - - - - - - - - - - - - -
	movem.l	a0-a2/d0-d2,-(sp)
	Dload	a2
	move.l	Cmp_Vect-CD(a2),d1
	beq.s	.skip
	clr.l	Cmp_Vect-CD(a2)
	clr.l	Cmp_Jump-CD(a2)
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-156(a6)
	move.l	(sp)+,a6
.skip	movem.l	(sp)+,a0-a2/d0-d2
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	ERROR MESSAGES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FCall
; - - - - - - - - - - - - -
	moveq	#23,d0
	Rjmp	L_Error
	Lib_Def	NFound
	moveq	#81,d0
	Rjmp	L_Error
	Lib_Def	OOMem
	moveq	#24,d0
	Rjmp	L_Error
	Lib_Def	Errdisc
	Rjmp	L_DiskError

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=COMPHERE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CompHere
; - - - - - - - - - - - - -
	Dload	a0
	moveq	#0,d3
	tst.l	Cmp_Vect-CD(a0)
	beq.s	.skip
	moveq	#-1,d3
.skip	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Fin de compilation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FinComp
; - - - - - - - - - - - - -
	Dload	a2
	move.l	d1,CSize-CD(a2)
	move.l	d2,CNumb-CD(a2)
	clr.w	LErreur-CD(a2)
	tst.l	d0
	beq.s	Cmp3
	moveq	#0,d2
	lea	Erreur-CD(a2),a1
Cmp2	cmp.w	#80,d2
	bcc.s	.Long
	addq.w	#1,d2
	move.b	(a0)+,(a1)+
	bne.s	Cmp2
.Long	subq.w	#1,d2
	move.w	d2,LErreur-CD(a2)
Cmp3	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=COMP SIZE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	CompSize
; - - - - - - - - - - - - -
	Dload	a0
	move.l	CSize-CD(a0),d3
	move.l	CNumb-CD(a0),CSize-CD(a0)
	clr.l	CNumb-CD(a0)
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	PPLOAD "bank"
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InppLoad1
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	Rbra	L_ppLoad
; - - - - - - - - - - - - -
	Lib_Par	InppLoad2
; - - - - - - - - - - - - -
	cmp.l	#$10000,d3
	Rbge	L_FCall
	Rbra	L_ppLoad
; - - - - - - - - - - - - -
	Lib_Def	ppLoad
; - - - - - - - - - - - - -
;	illegal
	move.l	(a3)+,a2
	Rjsr	L_NomDisc
;	Rbsr	L_Openpplib
;	move.l	d0,a6
;	lea	-8(sp),sp
;	move.l	Name1(a5),a0
;	moveq	#0,d0
;	move.l	#Public|Chip,d1
;	lea	(sp),a1
;	lea	4(sp),a2
;	move.l	#-1,a3
;	jsr	_LVOppLoadData(a6)
;	illegal
	move.l	#1005,d2
	Rjsr	L_D_Open
	Rbeq	L_Errdisc
	move.l	d3,d0
	Rbsr	L_ppBnk_Load
	Rjsr	L_D_Close
	Rjsr	L_Bnk.Change
	rts
; - - - - - - - - - - - - -
	Lib_Def	ppBnk_Load
; - - - - - - - - - - - - -
	movem.l	d2-d5/a2-a3,-(sp)
	Rjsr	L_SaveRegs
	move.l	d0,d5
	moveq	#0,d0
	Rjsr	L_ResTempBuffer
; Lis l'entete
	move.l	Buffer(a5),d2
	moveq	#4,d3
	Rjsr	L_D_Read
	Rbne	L_Errdisc
	move.l	d2,a2
	cmp.l	#"PPbk",(a2)
	bne	.Errbadformat
	moveq	#12,d3
	Rjsr	L_D_Read
	Rbne	L_Errdisc
	move.w	2(a2),d2
	btst	#Bnk_BitBob,d2
	bne.s	.BbIc
	btst	#Bnk_BitIcon,d2
	bne.s	.BbIc
; Une banque normale
	move.l	4(a2),d0		Longueur banque
	add.l	#8+8,d0			+ Flags + Header.lst
	move.l	#Public,d1
	btst	#Bnk_BitChip,d2
	beq.s	.Skip
	move.l	#Public|Chip,d1
.Skip	SyCall	MemReserve		Reserve le tempbuffer
	Rbeq	L_OOMem
	subq.l	#4,d0
	move.l	d0,(a0)+
	move.l	a0,TempBuffer(a5)
	addq.l	#4,a0			Pointe au niveau des flags
	move.l	a0,d2
	move.l	8(a2),d3		Longueur de la partie PP
	Rbsr	L_LoadUncrunch
; Efface la banque origine
	tst.l	d5
	bpl.s	.Skip3
	moveq	#0,d5
	move.w	(a2),d5
.Skip3	move.l	d5,d0
	Rjsr	L_Bnk.Eff
; Branche la banque dans la liste
	move.l	Cur_Banks(a5),a0
	move.l	TempBuffer(a5),a1
	clr.l	TempBuffer(a5)
	move.l	-(a1),d0
	subq.l	#4,d0
	move.l	d0,4(a1)		Met la longueur en 2
	move.l	(a0),(a1)		Branche dans la liste
	move.l	a1,(a0)
	addq.l	#8,a1
	clr.w	(a1)+
	move.w	d5,(a1)+		Numero de la banque
	addq.l	#2,a2
	move.w	(a2)+,(a1)+		Flags
	clr.w	(a1)+
	bra	.Out
; Une banque de sprites / icons
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BbIc	move.l	4(a2),d0		Longueur tempbuffer
	addq.l	#8,d0			+ Securite pp
	Rjsr	L_ResTempBuffer
	Rbeq	L_OOMem
	move.l	a0,d2			Adresse
	move.l	8(a2),d3		Longueur
	Rbsr	L_LoadUncrunch		Charge + Decompacte
	move.l	TempBuffer(a5),a3
	addq.l	#8,a3
; Sprite / Icons / Load / Append
	move.w	2(a2),d0
	btst	#Bnk_BitBob,d0
	beq.s	.Icons
; Bobs / Sprites
	move.w	(a3)+,d6		Nombre de bobs
	tst.l	d5			Overwrite?
	ble.s	.Over
	Rjsr	L_Bnk.GetBobs		Demande le nombre de bobs
	beq.s	.Over			0= overwrite
	moveq	#1,d0			Append!
	move.w	d6,d1
	move.w	(a0),d5			Nombre actuel
	add.w	d5,d1
	bra.s	.Res
.Over	moveq	#0,d0
	move.w	d6,d1
	clr.w	d5
.Res	Rjsr	L_Bnk.ResBob		Va reserve la place...
	Rbne	L_OOMem
	bra.s	.BB
; Icons
.Icons	move.w	(a3)+,d6		Nombre d'icons
	tst.l	d5			Overwrite?
	ble.s	.IOver
	Rjsr	L_Bnk.GetIcons		Demande le nombre de bobs
	beq.s	.IOver			0= overwrite
	moveq	#1,d0			Append!
	move.w	d6,d1
	move.w	(a0),d5			Nombre actuel
	add.w	d5,d1
	bra.s	.IRes
.IOver	moveq	#0,d0
	move.w	d6,d1
	clr.w	d5
.IRes	Rjsr	L_Bnk.ResIco		Va reserve la place...
	Rbne	L_OOMem
; Partie commune
; ~~~~~~~~~~~~~~
.BB	lsl.w	#3,d5			Pointe le debut des nouveaux
	lea	2(a0,d5.w),a2
	subq.w	#1,d6			D6= compteur
	bmi.s	.Pal
.LSLoop	clr.l	(a2)+			Raz
	clr.l	(a2)+
	move.w	(a3)+,d0		Prend les caracteristiques
	mulu	(a3)+,d0
	mulu	(a3)+,d0
	addq.l	#4,a3
	lsl.l	#1,d0			Vide?
	beq.s	.Rien
	move.l	d0,d3			Reserve la memoire
	add.l	#10,d0
	SyCall	MemChip
	Rbeq	L_OOMem
	move.l	a0,-8(a2)		Poke le pointeur
	move.l	-10(a3),(a0)+		TX/TY
	move.w	-6(a3),(a0)+
	move.w	-4(a3),(a0)		Plus de FLAGS!
	and.w	#$3FFF,(a0)+
	move.w	-2(a3),(a0)+
	move.l	a0,a1			Copie l'image
	move.l	a3,a0
	move.l	d3,d0
	Rjsr	L_TransMem
	move.l	a0,a3
.Rien	dbra	d6,.LSLoop
; Recopie la palette
.Pal	moveq	#31,d0
.PCopy	move.w	(a3)+,(a2)+
	dbra	d0,.PCopy
; Efface le tempbuffer
	moveq	#0,d0
	Rjsr	L_ResTempBuffer
; Fini!
.Out	Rjsr	L_LoadRegs
	movem.l	(sp)+,a2-a3/d2-d5
	rts
.Errbadformat
	moveq	#2,d0
	Rbra	L_Custom

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Load + Uncrunch file
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	LoadUncrunch
; - - - - - - - - - - - - -
	movem.l	d2-d3/a2,-(sp)
; Ouvre la librairie
	Rbsr	L_Openpplib
; Charge le header >>> Buffer+16
	movem.l	d2/d3,-(sp)
	move.l	Buffer(a5),a2
	lea	16(a2),a2
	move.l	a2,d2
	moveq	#8,d3
	Rjsr	L_D_Read
	Rbne	L_Errdisc
	cmp.l	#"PP20",(a2)+		A2 pointe sur efficiency
	Rbne	L_Errdisc
; Charge le fichier
	movem.l	(sp)+,d2/d3
	Rjsr	L_D_Read
	Rbne	L_Errdisc
; Decompacte le fichier
	move.l	a6,-(sp)
	Dload	a0
	move.l	pp_Base-CD(a0),a6
	move.l	d2,a0
	lea	8(a0),a1
	add.l	d3,a0
	moveq	#0,d0
	jsr	_LVOppDecrunchBuffer(a6)
	move.l	(sp)+,a6
; Fini
	movem.l	(sp)+,d2-d3/a2
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	PPSAVE "bank",number,efficiency
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	InppSave2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	moveq	#2,d3
	Rbra	L_InppSave3
; - - - - - - - - - - - - -
	Lib_Par	InppSave3
; - - - - - - - - - - - - -
	cmp.l	#5,d3			Efficiency
	Rbcc	L_FCall
	move.l	d3,d5
; Ouvre  la librairie
	Rbsr	L_Openpplib
; Trouve les adresses de la banque
	move.l	(a3)+,d0
	Rjsr	L_Bnk.GetAdr
	beq	.Errnotres
	move.l	a1,a0
	move.l	a1,-(sp)		Adresse banque origine
	bsr	B_Length		Trouve la longueur totale
; Fabrique le header
	move.l	Buffer(a5),a2
	move.l	#"PPbk",(a2)+		Reconnaissance
	move.w	-8-6(a0),(a2)+		Le numero
	move.w	-8-4(a0),(a2)+		Flags
	move.l	d0,(a2)+		Longueur banque / buffer de crunch
; Recopie la banque dans un buffer
	Rjsr	L_ResTempBuffer
	Rbeq	L_OOMem
	move.l	a0,a1
	move.l	(sp),a0
	bsr	B_Copie2Buffer
; Va cruncher
	move.l	TempBuffer(a5),a0
	move.l	-4(a0),d0
	move.l	d3,d1
	Rbsr	L_Crunche
	move.l	d0,d4
	move.l	d0,(a2)+		Longueur du buffer crunche
; Ouvre le fichier / Mode NEW
	move.l	(a3)+,a2
	Rjsr	L_NomDisc
	move.l	#1006,d2
	Rjsr	L_D_Open
	beq.s	.Errdisc
; Sauve le header
	move.l	Buffer(a5),d2
	moveq	#16,d3
	Rjsr	L_D_Write
	bne.s	.Errdisc
; Sauve le header pp
	Dload	a2
	move.l	Handle(a5),d0
	move.l	d5,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	a6,-(sp)
	move.l	pp_Base-CD(a2),a6
	jsr	_LVOppWriteDataHeader(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Errdisc
	Rbsr	L_FreeCrunchInfo
; Sauve la banque pp
	move.l	TempBuffer(a5),a0
	move.l	a0,d2
	move.l	d4,d3
	Rjsr	L_D_Write
	Rbne	L_Errdisc
; Ferme le fichier
	Rjsr	L_D_Close
; Libere les buffer
	Rbsr	L_FreeCrunchInfo
	moveq	#0,d0
	Rjsr	L_ResTempBuffer
	addq.l	#4,sp
	rts
.Errdisc
	Rbsr	L_FreeCrunchInfo
	Rjmp	L_DiskError
.Errnotres
	Rjmp	L_BkNoRes

;	Trouve la taille d'une banque de memoire quelconque, avec le nom
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
B_Length
	movem.l	a0-a1/d1-d2,-(sp)
	move.w	-8*2+4(a0),d0
	btst	#Bnk_BitBob,d0
	bne.s	.BB
	btst	#Bnk_BitIcon,d0
	bne.s	.BB
	move.l	-8*3+4(a0),d0
	subq.l	#8,d0			Moins les flags
	bra.s	.Out
; Une banque de bobs / icones
.BB	moveq	#2+32*2,d0		Pas le nom
	move.w	(a0)+,d1
	subq.w	#1,d1
	bmi.s	.Out
.BBLoop	move.l	(a0),d2
	beq.s	.BBNext
	move.l	d2,a1
	move.w	(a1)+,d2		SX
	mulu	(a1)+,d2		SY
	mulu	(a1)+,d2		NPlan
	lsl.l	#1,d2			En mots
	add.l	d2,d0
.BBNext	add.l	#10,d0			Le header
	addq.l	#8,a0
	dbra	d1,.BBLoop
.Out	movem.l	(sp)+,a0-a1/d1-d2
	rts
;	Recopie une banque memoire quelconque dans un buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
B_Copie2Buffer
	movem.l	a0-a2/d0-d3,-(sp)
	move.w	-8*2+4(a0),d0
	btst	#Bnk_BitBob,d0
	bne.s	.BB
	btst	#Bnk_BitIcon,d0
	bne.s	.BB
	move.l	-8*3+4(a0),d0
	subq.l	#8,d0
	subq.l	#8,a0
	Rjsr	L_TransMem
	bra.s	.Out
; Une banque de bobs / icones
.BB	move.w	(a0)+,d3		Nombre de bobs
	move.w	d3,(a1)+
	subq.w	#1,d3
	bmi.s	.Out
.BBLoop	move.l	(a0),d1
	beq.s	.BBVide
	move.l	d1,a2
	move.l	(a2)+,(a1)		SX/SY
	move.l	(a2)+,4(a1)		NPLAN/HX
	move.w	(a2)+,8(a1)		HY
	move.w	(a1)+,d0		SX
	mulu	(a1)+,d0		SY
	mulu	(a1)+,d0		NPlan
	lsl.l	#1,d0			En mots
	addq.l	#4,a1
	exg	a0,a2
	Rjsr	L_TransMem		Va copier
	exg	a0,a2
	bra.s	.BBNext
.BBVide	clr.l	(a1)+
	clr.l	(a1)+
	clr.w	(a1)+
.BBNext	addq.l	#8,a0
	dbra	d3,.BBLoop
; La palette
	moveq	#31,d0
.BBPal	move.w	(a0)+,(a1)+
	dbra	d0,.BBPal
; Fini
.Out	movem.l	(sp)+,a0-a2/d0-d3
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Crunche le buffer A0 / Longueur D0 / Efficiency D1
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Crunche
; - - - - - - - - - - - - -
	movem.l	a2/d2,-(sp)
	Dload	a2
	movem.l	a0/d0/d1,-(sp)
; Quelle rapidite?
	moveq	#2,d1
	move.l	#256*1024,d0
	SyCall	MemFast
	bne.s	.Ok
	moveq	#1,d1
	move.l	#64*1024,d0
	SyCall	MemFast
	bne.s	.Ok
	moveq	#0,d1
	bra.s	.OMem
.Ok	move.l	a0,a1
	SyCall	MemFree
.OMem
; Reserve le Crunch info
	move.l	4(sp),d0			Efficiency
	move.l	a5,a1				User data
	lea	.Control(pc),a0			Control-C
	move.l	a6,-(sp)
	move.l	pp_Base-CD(a2),a6
	jsr	_LVOppAllocCrunchInfo(a6)
	move.l	(sp)+,a6
	move.l	d0,pp_CrunchInfo-CD(a2)
	Rbeq	L_OOMem
; Crunche le buffer
	move.l	d0,a0				CrunchInfo
	movem.l	(sp)+,a1/d0-d1
	move.l	a6,-(sp)
	move.l	pp_Base-CD(a2),a6
	jsr	_LVOppCrunchBuffer(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq.s	.Erraborted
	bmi.s	.Errnopack
; Retourne la longueur en D0
	movem.l	(sp)+,a2/d2
	rts
.Erraborted
	moveq	#9,d0
	Rjmp	L_Error
.Errnopack
	moveq	#3,d0
	Rbra	L_Custom

; 	Routine de test du control-c
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Control
	movem.l	a0-a1/d1/a5,-(sp)
	move.l	4+4*4+3*4(sp),a5
	move.w	T_Actualise(a5),d0
	bclr	#BitControl,d0
	beq.s	.Cont
.Stop	moveq	#0,d0
	bra.s	.Out
.Cont	moveq	#1,d0
.Out	movem.l	(sp)+,a0-a1/d1/a5
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Libere le crunchinfo
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FreeCrunchInfo
; - - - - - - - - - - - - -
	Dload	a0
	move.l	pp_CrunchInfo-CD(a0),d0
	beq.s	.Skip
	move.l	a6,-(sp)
	clr.l	pp_CrunchInfo-CD(a0)
	move.l	pp_Base-CD(a0),a6
	move.l	d0,a0
	jsr	_LVOppFreeCrunchInfo(a6)
	move.l	(sp)+,a6
.Skip	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Ouvre la librairie pp
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Openpplib
; - - - - - - - - - - - - -
	movem.l	a2/a6,-(sp)
	Dload	a2
	move.l	pp_Base-CD(a2),d0
	bne.s	.Open
	lea	pp_Name-CD(a2),a1
	moveq	#35,d0
	move.l	$4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,pp_Base-CD(a2)
.Open	movem.l	(sp)+,a2/a6
	tst.l	d0
	beq.s	.Err
	rts
.Err	moveq	#1,d0
	Rbra	L_Custom
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Ferme la librairie pp
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Closepplib
; - - - - - - - - - - - - -
	Rbsr	L_FreeCrunchInfo
	Dload	a0
	move.l	pp_Base-CD(a0),d0
	beq.s	.Skip
	clr.l	pp_Base-CD(a0)
	move.l	d0,a1
	move.l	a6,-(sp)
	move.l	$4.w,a6
	jsr	_LVOCloseLibrary(a6)
	move.l	(sp)+,a6
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	= SQUASH(address,length,fast,speed,colour)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	Squash
; - - - - - - - - - - - - -
	Rjsr	L_SaveRegs
	move.l	d3,d6
	cmp.l	#32,d6
	Rbcc	L_FCall
	move.l	(a3)+,d7
	cmp.l	#256,d7
	Rbcs	L_FCall
	cmp.l	#4096,d7
	Rbcc	L_FCall
	move.l	(a3)+,d5
	move.l	(a3)+,d1
	Rbls	L_FCall
	move.l	(a3)+,d3
	moveq	#0,d0
	lea	T_Actualise(a5),a0
	movem.l	a3-a6/d6/d7,-(sp)
	Rbsr	L_Sq
	movem.l	(sp)+,a3-a6/d6/d7
	Rjsr	L_LoadRegs
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	= UNSQUASH(address,lenght)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par	UnSquash
; - - - - - - - - - - - - -
	move.l	d3,d1
	Rbls	L_FCall
	move.l	(a3)+,d3
	moveq	#1,d0
	movem.l	a3-a6/d6/d7,-(sp)
	Rbsr	L_Sq
	movem.l	(sp)+,a3-a6/d6/d7
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SQUASHER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Sq

	Rdata
*
* Squasher II.
*
* Enhanced for varied speed (at a cost of very little inefficiency),
* error checking and pre scan of memory for fast and efficient squashing!
* Routine checks if enough memory is present for pre scan.You can
* turn off pre scan if you want to test it in non scan but you have
* enough memory for scan by setting d5 to -1.
* This is totally compatible with the original ST Squasher.
*
*
* Main Entry d0=0 for squash or d0<>0 for unsquash
* (Check routines below for entry parameters)!
*

Squasher:
	tst.l	d0
	bne	UnSquash
********************************************************************
*
* Squash code from STOS!
*
*
********************************************************************
*Entry
*	D7 Search length $80 to $1024 (works in non scan only)
*	D5 -1 for enforced non scan
*	D3 Address
*	D1 Length
*	D0 0 Squash
*
*Exit
*	D3 Length positive
*	   or
*	   Error negative:-
*		             -1 Squashed>=Normal

Squash:

* Change the addresses
	lea	_Test1(pc),a1
	move.l	a0,2(a1)
	lea	_Test2(pc),a1
	move.l	a0,4(a1)
	lea	_Colour(pc),a1
	lsl.w	#1,d6
	add.l	#$DFF180,d6
	move.l	d6,2(a1)
* Load processor masks
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	$4.w,a6
	sub.l	a1,a1
	jsr	FindTask(a6)
	movem.l	(sp)+,a0-a6/d0-d7
* Real squasher
	lea	use_scan(pc),a0
	clr.l	(a0)
	tst.l	d5
	beq.b	squash_entry
pre_scan_mem:
	movem.l	d0-d7,-(sp)

	move.l	d3,a0
	move.l	d3,a1
	add.l	d1,a1

	move.l	d1,d5

	move.l	#$10000*4,d0
	bsr	allocate_mem
	lea	use_scan(pc),a6
	move.l	d0,(a6)
	beq.b	exit_pre_scan_mem
	move.l	d0,a4

	move.l	d5,d0
	lsl.l	#1,d0
	move.l	d0,4(a6)
	bsr	allocate_mem
	move.l	d0,(a6)
	beq.b	exit_mem_clean_up


	move.l	#$1024,d7
	move.l	d0,a5
scan_loop:
	move.b	(a1),d0
	moveq.l	#0,d1
	move.b	-(a1),d1
	lsl.l	#8,d1
	or.b	d0,d1
	lsl.l	#2,d1
	move.l	(a4,d1.l),d2
	beq.b	no_word_ahead
	sub.l	a1,d2
	cmp.l	d7,d2
	bhi.b	no_word_ahead
	move.l	a1,d4
	sub.l	a0,d4
	lsl.l	#1,d4
	move.w	d2,(a5,d4.l)
no_word_ahead:
	move.l	a1,(a4,d1.l)
	cmp.l	a0,a1
	bgt.b	scan_loop

exit_mem_clean_up:
	move.l	a4,d1
	move.l	#$10000*4,d0
	bsr	deallocate_mem

exit_pre_scan_mem:
	movem.l	(sp)+,d0-d7

squash_entry:
	MOVE.L	D3,D0
	ADD.L	D0,D1
	lea	scan_ahead_count2(pc),a0
	move.l	d7,(a0)
	LEA	start(PC),A0
	MOVE.L	D0,(A0)
	MOVE.L	D0,4(A0)
	MOVE.L	D1,8(A0)
	BRA	do_squash


allocate_mem:
	movem.l	d2-d7/a0-a6,-(sp)
	move.l	#%10000000000000001,d1
	move.l	4,a6
	jsr	-198(a6)
	movem.l	(sp)+,d2-d7/a0-a6
	rts

deallocate_mem:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d1,a1
	tst.l	d1
	beq.b	not_alloc
	move.l	4,a6
	jsr	-210(a6)
not_alloc:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

use_scan:
	dc.l	0
use_scan_size:
	dc.l	0
offset_for_msg:
	dc.l	0
msg_length_code_index:
	dc.w	0
code_table:
o0	dc.w	$0100
o2	dc.w	$0200
o4	dc.w	$0400
o6	dc.w	$1000

o8	dc.w	8
oa	dc.w	9
oc	dc.w	$A
oe	dc.w	$C

o10	dc.w	0
o12	dc.w	0
o14	dc.w	0
o16	dc.w	8

o18	dc.w	2
o1a	dc.w	3
o1c	dc.w	3
o1e	dc.w	3

o20	dc.w	1
o22	dc.w	4
o24	dc.w	5
o26	dc.w	6

final_reg_load:
o28	dc.w	0
o2a	dc.w	0
o2c	dc.w	0
o2e	dc.w	0
add_current_byte_count_tally:
	dc.w	0
add_current_byte_large_count_tally:
	dc.w	0
	dc.w	0
	DC.B	0,0,0,0
	DC.B	$4D,$B8,$FF,$FF
	DC.B	0,0,0,0
	DC.B	0,0,0,0
start	DC.l	0
start2	DC.l	0
finish	DC.l	0
	DC.B	0,7,0,0
	DC.B	0,0,0,0
	DC.B	0,0,0,0
	DC.B	0,0
scan_ahead_count:
	DC.l	$1024
	DC.B	1,0
end_address:
	dc.l	0
scan_ahead_count2:
	DC.l	0

do_squash:
	MOVEA.L	start(PC),A0
	MOVEA.L	finish(PC),A1
	MOVEA.L	start2(PC),A2
	MOVEQ	#1,D2
	CLR.W	D1
	CLR.L	D7
main_sq_loop:
	BSR	main_sq_rtn
	TST.B	D0
	BEQ.S	exit_main_sq_loop
	ADDQ.W	#1,D1
	CMPI.W	#$108,D1
	BNE.S	exit_main_sq_loop
	BSR	add_current_byte_count
exit_main_sq_loop:
	CMPA.L	A0,A1
	BGT.S	main_sq_loop
	BSR	add_current_byte_count
	BSR	insert_next_long

	move.l	use_scan_size(pc),d0
	move.l	use_scan(pc),d1
	bsr	deallocate_mem
	add.l	#32,a2
	cmp.l	a2,a1
	bhi.b	ok_squash
	moveq.l	#-1,d3
	rts
ok_squash:
	sub.l	#32,a2
	MOVE.L	D7,(A2)+
	sub.l	start(PC),a1
	MOVE.L	A1,(A2)+
	MOVE.L	A2,d3
	sub.l	start(pc),d3
	RTS

; Routine de test CONTROL-C
_Test2	bclr	#BitControl,$800000
	bne	squash_abort
_Colour	move.w	a0,$DFF180
	bra.s	EndIt

main_sq_rtn:
_Test1	tst.b	$800000
	bmi.s	_Test2
EndIt	MOVEA.L	A0,A3
	ADDA.L	scan_ahead_count(PC),A3
	CMPA.L	A1,A3
	BLE.S	not_over_end
	MOVEA.L	A1,A3
not_over_end:
	move.l	a0,a4
	add.l	scan_ahead_count2(PC),a4
	CMPA.L	A1,A4
	BLE.S	not_over_end2
	MOVEA.L	A1,A4
not_over_end2:
	lea	last_match(pc),a5
	move.l	a0,(a5)
	lea	end_address(pc),a5
	move.l	a4,(a5)
	MOVEQ	#1,D5
	MOVEA.L	A0,A5
	addq.l	#1,a5
main_loop:

	move.l	use_scan(pc),d4
	beq.b	no_scan
	move.l	d4,a4
	move.l	last_match(pc),d4
	sub.l	start(pc),d4
	lsl.l	#1,d4
	moveq.l	#0,d3
	move.w	(a4,d4.l),d3
	beq	leave_sq_main_rtn
	add.l	last_match(pc),d3
	move.l	d3,a5
	bra.b	move_ahead
last_match:
	dc.l	0
no_scan:
	MOVE.B	(A0),D3
	MOVE.B	1(A0),D4
	move.l	end_address(pc),a4
L22431C	CMP.B	(A5)+,D3
	BEQ.S	L22432C
L224324	CMPA.L	A5,A4
	BGT.S	L22431C
	BRA	leave_sq_main_rtn
L22432C
	cmp.b	(a5),d4
	bne.b	L224324
	SUBQ.W	#1,A5
move_ahead:
	lea	last_match(pc),a4
	move.l	a5,(a4)
	MOVEA.L	A0,A4
	move.b	(a0),d3
	move.b	1(a0),d4
L224330	cmp.b	(a4)+,(a5)+
	BNE.S	L22433A
	cmp.b	(a5),d3
	bne.b	no_match
	cmp.b	1(a5),d4
	bne.b	no_match
	move.l	a0,-(sp)
	lea	last_match(pc),a0
	move.l	a5,(a0)
	move.l	(sp)+,a0
no_match:
	CMPA.L	A5,A3
	BGT.S	L224330
L22433A	MOVE.L	A4,D3
	SUB.L	A0,D3
	SUBQ.L	#1,D3
	CMP.L	D3,D5
	BGE.S	too_far
	MOVE.L	A5,D4
	SUB.L	A0,D4
	SUB.L	D3,D4
	SUBQ.W	#1,D4
	CMP.L	#4,D3
	BLE.S	less_than_5_bytes_long
	MOVEQ	#6,D6
	CMP.L	#$101,D3
	BLT.S	less_than_257_bytes_long
	MOVE.W	#$100,D3
less_than_257_bytes_long:
	BRA.S	L22436A
less_than_5_bytes_long:
	MOVE.W	D3,D6
	SUBQ.W	#2,D6
	LSL.W	#1,D6
L22436A	LEA	code_table(PC),A6
	CMP.W	0(A6,D6.W),D4
	BGE.S	too_far
	MOVE.L	D3,D5
	MOVE.L	A0,-(A7)
	LEA	offset_for_msg(PC),A0
	MOVE.L	D4,(A0)
	LEA	msg_length_code_index(PC),A0
	MOVE.B	D6,(A0)
	MOVEA.L	(A7)+,A0
too_far:
	CMPA.L	A5,A3
	BGT	main_loop
leave_sq_main_rtn:
	CMP.L	#1,D5
	BEQ.S	byte_only
	BSR	add_current_byte_count
	MOVE.B	msg_length_code_index(PC),D6
	MOVE.L	offset_for_msg(PC),D3
	MOVE.W	8(A6,D6.W),D0
	BSR	add_d0_bits_from_d3
	MOVE.W	$10(A6,D6.W),D0
	BEQ.S	L2243B4
	MOVE.L	D5,D3
	SUBQ.W	#1,D3
	BSR	add_d0_bits_from_d3
L2243B4	MOVE.W	$18(A6,D6.W),D0
	MOVE.W	$20(A6,D6.W),D3
	BSR	add_d0_bits_from_d3
	ADDI.W	#1,$28(A6,D6.W)
	ADDA.L	D5,A0
	CLR.B	D0
	RTS

byte_only:
	MOVE.B	(A0)+,D3
	MOVEQ	#8,D0
	BSR	add_d0_bits_from_d3
	MOVEQ	#1,D0
	RTS

add_current_byte_count:
	TST.W	D1
	BEQ.S	add_current_byte_count_end
	MOVE.W	D1,D3
	CLR.W	D1
	CMP.W	#9,D3
	BGE.S	add_current_byte_large_count
	MOVE.L	A0,-(A7)
	LEA	add_current_byte_count_tally(PC),A0
	ADDQ.W	#1,(A0)
	MOVEA.L	(A7)+,A0
	SUBQ.W	#1,D3
	MOVEQ	#5,D0
	BRA	add_d0_bits_from_d3
add_current_byte_count_end:
	RTS

add_current_byte_large_count:
	MOVE.L	A0,-(A7)
	LEA	add_current_byte_large_count_tally(PC),A0
	ADDQ.W	#1,(A0)
	MOVEA.L	(A7)+,A0
	SUBI.W	#9,D3
	ORI.W	#$700,D3
	MOVEQ	#$B,D0
	BRA	add_d0_bits_from_d3

add_d0_bits_from_d3:
	SUBQ.W	#1,D0
add_bits_loop:
	LSR.L	#1,D3
	ROXL.L	#1,D2
	BCS.S	insert_next_long2
	DBF	D0,add_bits_loop
	RTS
insert_next_long:
	CLR.W	D0
insert_next_long2:
	cmp.l	a2,a1
	bls.b	inefficient_compression
	MOVE.L	D2,(A2)+
	EOR.L	D2,D7
	MOVEQ	#1,D2
	DBF	D0,add_bits_loop
	RTS

inefficient_compression:
	move.l	a1,a2
	moveq.l	#-1,d0
	rts
squash_abort:
	move.l	use_scan_size(pc),d0
	move.l	use_scan(pc),d1
	bsr	deallocate_mem
	moveq	#-2,d3
	addq.l	#4,sp
	rts

**********************************
*Entry
*
*	D3 Address
*	D1 Length
*	D0 1 Unsquash
*
*Exit
*	D3 Unsquashed Length positive
*	   or
*	   Error negative:-
*			     -1 Check on data bad!
*			     -2 Unsquasher was going to overwrite
*				memory that was out of bounds!
UnSquash:
	MOVE.L	D3,D0
	ADD.L	D0,D1
	MOVEA.L	D1,A0
	MOVEA.L	D0,A1
	MOVEA.L	-(A0),A2
	move.l	a2,d7
	ADDA.L	A1,A2
	MOVE.L	-(A0),D5
	MOVE.L	-(A0),D0
	EOR.L	D0,D5
L22446E	LSR.L	#1,D0
	BNE.S	L224476
	BSR	L2244E8
L224476	BCS.S	L2244AE
	MOVEQ	#8,D1
	MOVEQ	#1,D3
	LSR.L	#1,D0
	BNE.S	L224484
	BSR	L2244E8
L224484	BCS.S	L2244D4
	MOVEQ	#3,D1
	CLR.W	D4
L22448A	BSR	L2244F4
	MOVE.W	D2,D3
	ADD.W	D4,D3
L224492	MOVEQ	#7,D1
L224494	LSR.L	#1,D0
	BNE.S	L22449A
	BSR.S	L2244E8
L22449A	ROXL.L	#1,D2
	DBF	D1,L224494
	cmp.l	a1,a2
	ble.b	bad_squash_mem
	MOVE.B	D2,-(A2)
	DBF	D3,L224492
	BRA.S	L2244E0
L2244A8	MOVEQ	#8,D1
	MOVEQ	#8,D4
	BRA.S	L22448A
L2244AE	MOVEQ	#2,D1
	BSR.S	L2244F4
	CMP.B	#2,D2
	BLT.S	L2244CA
	CMP.B	#3,D2
	BEQ.S	L2244A8
	MOVEQ	#8,D1
	BSR.S	L2244F4
	MOVE.W	D2,D3
	MOVE.W	#$C,D1
	BRA.S	L2244D4
L2244CA	MOVE.W	#9,D1
	ADD.W	D2,D1
	ADDQ.W	#2,D2
	MOVE.W	D2,D3
L2244D4	BSR.S	L2244F4
L2244D6	SUBQ.W	#1,A2
	cmp.l	a1,a2
	blt.b	bad_squash_mem
	MOVE.B	0(A2,D2.W),(A2)
	DBF	D3,L2244D6
L2244E0	CMPA.L	A2,A1
	BLT.S	L22446E
	tst.l	d5
	beq.b	check_ok
	moveq.l	#-1,d3
	rts
check_ok:
	move.l	d7,d3
	RTS
bad_squash_mem:
	moveq.l	#-2,d3
	rts

L2244E8	MOVE.L	-(A0),D0
	EOR.L	D0,D5
	MOVE.B	#$10,CCR
	ROXR.L	#1,D0
	RTS

L2244F4	SUBQ.W	#1,D1
	CLR.W	D2
L2244F8	LSR.L	#1,D0
	BNE.S	L224506
	MOVE.L	-(A0),D0
	EOR.L	D0,D5
	MOVE.B	#$10,CCR
	ROXR.L	#1,D0
L224506	ROXL.L	#1,D2
	DBF	D1,L2244F8
	RTS



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	ERROR MESSAGES...
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Custom
; - - - - - - - - - - - - -
	lea	ErrMess(pc),a0
	moveq	#0,d1			* Can be trapped
	moveq	#ExtNb,d2		* Number of extension
	moveq	#0,d3			* IMPORTANT!!!
	Rjmp	L_ErrorExt		* Jump to routine...
ErrMess	dc.b	"Cannot run 1.3 compiled procedures under AMOSPro",0
	dc.b	"Cannot open powerpacker.library (v35)",0
	dc.b	"Not a powerpacked memory bank",0
	dc.b	"Cannot pack this bank",0
	even

;	"No errors" routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Def	NoErrors
	moveq	#0,d1
	moveq	#ExtNb,d2
	moveq	#-1,d3
	Rjmp	L_ErrorExt


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Welcome message
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_Title
; - - - - - - - - - - - - -
	dc.b	"AMOSPro Compiler extension V "
	Version
	dc.b	0,"$VER: "
	Version
	dc.b	0
	Even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Finish the library
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_End
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_End	dc.w	0
