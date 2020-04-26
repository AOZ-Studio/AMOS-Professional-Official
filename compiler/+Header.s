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

		Include	"+AMOS_Includes.s"
		OPT	P+

		dc.w	LInit

; Calcul de la taille des buffers de travail
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TBufParams	equ	256
LDataWork	equ	32+BbLong+12*2+(AAreaSize*5+6)+24+16+12+70*3+4+20+108+108+256+TBuffer+TBufParams

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Entete programme objet
;---------------------------------------------------------------------

DebPrg	move.l	#0,d2			Les flags
	move.l	#0,d3			Decalage librairie

;-----> Debut normal
CliStart
	lea	DebPrg(pc),a4
	move.l	a4,Header_DebPrg-DebPrg(a4)

; Entree en cas de backstart
BackIn	move.l	sp,Header_Pile-DebPrg(a4)
	movem.l	a0/d0,-(sp)

	moveq	#0,d4			Pas de message!
	moveq	#0,d5
	moveq	#0,d6
	move.l	$4.w,a6

; Workbench?
; ~~~~~~~~~~
	btst	#FHead_PRun,d2		Pas si PRUN
	bne.s	.Cli
	btst	#FHead_Backed,d2	Backstart?
	bne.s	.Cli
	sub.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,a0
	tst.l	$ac(a0)
	bne.s	.Cli
	lea	$5c(a0),a0		Recupere le message
	move.l	a0,-(sp)
	jsr	-384(a6)		WaitPort
	move.l	(sp)+,a0
	jsr	-372(a6)		GetMsg
	move.l 	d0,d4
.Cli

; Init dos.library
; ~~~~~~~~~~~~~~~~
	moveq	#0,d0
	lea	DosName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,d5
	beq	Abort_Panic

; Init INTUITION library
; ~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	lea	IntName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,d6
	beq	Abort_Panic

; Si workbench, change le directory >>> Directory du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.l	d4
	beq.s	.Cli2
	move.l	d4,a2
	move.l	$24(a2),d0
	beq.s	.Cli2
	move.l	d0,a0
	move.l	(a0),d1
	beq.s	.Cli2
	move.l	d5,a6
	jsr	_LVOCurrentDir(a6)
.Cli2

; Reserve une zone de donnees pour le header
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ReRun_Short
	move.l	#H_DZLong,d0		Longueur
	move.l	#Public|Clear,d1	Flags
	lea	Header_DZ(pc),a0
	bsr	A0_Reserve
	beq	Abort_Mem
	move.l	a0,a4
	move.l	d5,H_DosBase(a4)
	move.l	d6,H_IntBase(a4)
	move.l	d4,H_Message(a4)

;	Preparation du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ReRun_Normal
	move.l	d2,H_Flags(a4)		Flags header

; 1 : programme
	lea	H_Load+0*8(a4),a6
	bsr	DecHunk
	bmi	Abort_Mem
	move.l	a1,a2			Programme >>> A2
	move.l	a1,H_Program(a4)

; 2 : librairies
	lea	H_Load+1*8(a4),a6
	bsr	DecHunk
	bmi	Abort_Mem
	move.l	a1,a3			Librairies >> A3
	add.l	a3,d3
	move.l	d3,H_Libraries(a4)	Adresse absolue (a4)

; 3 : relocation
	lea	H_Load+2*8(a4),a6
	bsr	DecHunk
	bmi	Abort_Mem
	bsr	H_Reloc
	bsr	EffLastLoad

; 4-5 : amos.library + datazone + mouse.abk
	btst	#FHead_PRun,Head_Flags(a4)	PRun?
	bne	.PRunne
	btst	#FHead_Run,Head_Flags(a4)	Run?
	bne	.Runne

	lea	H_Load+3*8(a4),a6
	bsr	DecHunk
	bmi	Abort_Mem
	tst.l	(a1)				Une librairie?
	bne.s	.Libhere
	bsr	EffLastLoad			Non, on enleve de la memoire
	move.l	a6,-(sp)			Et on charge du disque
	move.l	H_DosBase(a4),a6
	lea	LibName2(pc),a0			APSystem/amos.library
	move.l	a0,d1
	jsr	_LVOLoadSeg(a6)
	tst.l	d0
	bne.s	.Ok
	lea	LibName3(pc),a0			libs/amos.library
	move.l	a0,d1
	jsr	_LVOLoadSeg(a6)
	tst.l	d0
	bne.s	.Ok
	lea	LibName1(pc),a0			libs:amos.library
	move.l	a0,d1
	jsr	_LVOLoadSeg(a6)
.Ok	move.l	(sp)+,a6
	move.l	d0,H_WSegment(a4)		Adresse du segment
	lsl.l	#2,d0
	beq	Abort_Lib
	addq.l	#4,d0
	move.l	d0,a1
.Libhere
	move.l	a1,a3
	move.l	a3,H_WAddress(a4)	Adresse amos.library

; Reserve la zone de datas...
	move.l	#LDataWork+DataLong,d0	  Longueur buffers travail
	add.l	8(a3),d0		+ Longueur datas W
	move.l	d0,d2
	lea	H_DataZone(a4),a0
	move.l	#Public|Clear,d1	Flags
	bsr	A0_Reserve
	beq	Abort_Mem
	lea	LDataWork(a0),a5
	move.l	a5,a0
	add.l	8(a3),a5
	move.l	a5,H_DataA5(a4)
; Trouve toutes les adresses de buffers de travail
	lea	-32(a0),a0
	move.l	a0,BufLabel(a5)		Buffer label expression
	lea	-BbLong(a0),a0
	move.l	a0,BufBob(a5)		Buffer dessin d'un bob
	lea	-12*2(a0),a0
	move.l	a0,MnTDraw(a5)		Buffer outline menus
	lea	-(AAreaSize*5+6)(a0),a0
	move.l	a0,AAreaBuf(a5)		Zone pour les AREAFILL
	lea	-24(a0),a0
	move.l	a0,AAreaInfo(a5)
	lea	-16(a0),a0
	move.l	a0,BufAMSC(a5)		Buffers chargement IFF
	lea	-12(a0),a0
	move.l	a0,BufCCRT(a5)
	lea	-70*3(a0),a0
	move.l	a0,BufCMAP(a5)
	lea	-4(a0),a0
	move.l	a0,BufCAMG(a5)
	lea	-20(a0),a0
	move.l	a0,BufBMHD(a5)
	lea	-108(a0),a0
	move.l	a0,DirFNeg(a5)		Filtre negatif directory
	lea	-108(a0),a0
	move.l	a0,Name2(a5)		Buffers nom disque
	lea	-256(a0),a0
	move.l	a0,Name1(a5)
	lea	-TBuffer(a0),a0
	move.l	a0,Buffer(a5)
	move.l	a0,BasA3(a5)		Buffer parametres
	move.l	#256,d0
	lea	PathAct(a5),a0		Buffer du pathact
	move.l	#Public|Clear,d1
	bsr	A0_Reserve
	beq	Abort_Mem
; Start system function of the amos.library
	move.l	#"V2.0",d0		Magic
	move.w	#$0200,d1		Version
	jsr	12(a3)
	cmp.l	#"W2.0",d0		Bonne version?
	bne	Abort_Lib

; 5 : MOUSE.ABK
	lea	H_Load+4*8(a4),a6
	move.l	#Public|Chip,d1
	bsr	DecHunk
	bmi	Abort_Mem
	tst.l	(a1)
	bne.s	.Mouse
	bsr	EffLastLoad
	bra.s	.FMouse
.Mouse	move.l	a1,PI_AdMouse(a5)
.FMouse	bra.s	.Fin45

; 4-5: RUN, on ne charge rien
.Runne	bsr	EffHunk			Saute AMOS.library
	bsr	EffHunk			Saute mouse.abk
.Fin45

; 6 : Recopie l'environement systeme
	lea	H_Load+5*8(a4),a6
	bsr	DecHunk			Environment interpreter
	bmi	Abort_Mem
	move.l	(a1)+,d0		Taille des PI_
	subq.l	#1,d0
	lea	PI_Start(a5),a0
.Cop1	move.b	(a1)+,(a0)+
	dbra	d0,.Cop1
	move.l	(a1)+,d0
	lea	Sys_Messages(a5),a0	Reserve les messages
	move.l	#Public,d1
	bsr	A0_Reserve
	subq.l	#1,d0
.Cop2	move.b	(a1)+,(a0)+
	dbra	d0,.Cop2
	bsr	EffLastLoad
	bra.s	.PaPRun

; 4-5-6: PRUN, on saute tout!
.PRunne	bsr	EffHunk			amos.library
	bsr	EffHunk			mouse.abk
	bsr	EffHunk			environment systeme
	move.b	#1,H_PRun(a4)		Met le flag PRUN
.PaPRun

; 7 : Banque de dialogues par defaut
	lea	H_Load+6*8(a4),a6
	bsr	DecHunk
	bmi	Abort_Mem
; Une banque?
	cmp.l	#-1,(a1)
	bne.s	.Bk
	bsr	EffLastLoad
	bra.s	.Nobk
; Fabrique et branche la banque
.Bk	lea	Sys_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	IFNE	Debug
	moveq	#0,d0			Si debug, empeche la copie
	ENDC
	bsr	Get_Bank
	move.l	a0,Sys_Resource(a5)
.Nobk

; 8 : les messages d'erreur
	lea	H_Load+7*8(a4),a6
	bsr	DecHunk
	bmi	Abort_Mem
; Des messages?
	move.l	(a1)+,d0
	beq.s	.Noerr
	lea	Ed_RunMessages(a5),a0
	move.l	#Public,d1
	bsr	A0_Reserve
	subq.w	#1,d0
.Cope	move.b	(a1)+,(a0)+
	dbra	d0,.Cope
.Noerr	bsr	EffLastLoad

;	Short-Mem run, ou first run?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#FHead_Short,Head_Flags(a4)
	bne.s	.Short
	btst	#FHead_Run,Head_Flags(a4)
	bne	.RunMes

; First run: saisie de la ligne de commande
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	(sp)+,a0/d0
	move.l	Buffer(a5),a1
	lea	TBuffer-256-6(a1),a1
	move.l	#"CmdL",(a1)+
	move.l	a1,a2
	clr.w	(a1)+
; Prend le message du CLI
	move.l	H_Message(a4),d1
	bne.s	.PaCli
	moveq	#0,d2
	subq.w	#1,d0
	bmi.s	.FinMes
.Cl1	move.b	(a0)+,d1
	cmp.b	#32,d1
	bcs.s	.Cl2
	bne.s	.Cl0
	tst.b	d2
	beq.s	.Cl2
.Cl0	move.b	d1,(a1)+
	addq.w	#1,d2
.Cl2	dbra	d0,.Cl1
	bra.s	.FinMes
.PaCli
; Prend le message du WB
	move.l	d1,a0
	cmp.l	#2,$1c(a0)
	bne.s	.FinMes
	move.l	$24(a0),d0
	beq.s	.FinMes
	move.l	d0,a0
	move.l	12(a0),d0
	beq.s	.FinMes
	move.l	d0,a0
.WbL1	move.b	(a0)+,(a1)+
	bne.s	.WbL1
	subq.l	#1,a1
	bra.s	.FinMes

; Short-mem: repoke les donn�es sauvees dans la pile
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Short	clr.b	H_Short(a4)
; Le pathact
	lea	Short_Path(sp),a0
	move.l	PathAct(a5),a1
.Cp1	move.b	(a0)+,(a1)+
	bne.s	.Cp1
; La ligne de commande
	lea	Short_Command(sp),a0
	move.l	Buffer(a5),a1
	lea	TBuffer-256-6(a1),a1
	move.l	#"CmdL",(a1)+
	move.l	a1,a2
	move.w	(a0)+,d0
	move.w	d0,(a1)+
	beq.s	.FinMes
	subq.w	#1,d0
.Cp2	move.b	(a0)+,(a1)+
	dbra	d0,.Cp2
	lea	Short_Save(sp),sp	Restore la pile
; Termine le message
.FinMes	sub.l	a2,a1
	subq.l	#2,a1
	move.w	a1,(a2)
.RunMes

; Vide les caches du 68030 / 68040
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Sys_ClearCache

; Init amos.library
; ~~~~~~~~~~~~~~~~~
	btst	#FHead_Run,Head_Flags(a4)
	bne.s	.NoAMOS
	move.l	$4.w,a6			Open graphics.library
	moveq	#0,d0
	lea	GfxName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,T_GfxBase(a5)
	beq	Abort_Mem
	move.l	H_IntBase(a4),T_IntBase(a5)
	moveq	#3,d0
	bsr	Sys_GetMessage
	move.l	a0,a3			A3= Fonte / 0
	lea	PI_DefEPa(a5),a2	A2= Default Palette
	move.l	PI_AdMouse(a5),a1	A1= Mouse.Abk
	lea	PI_ParaTrap(a5),a0	A0= Parametres start
	move.l	PI_DefAmigA(a5),d1	A1= Amiga-A
	moveq	#0,d0			D0= Pas d'ecran
	move.l	H_WAddress(a4),a6
	jsr	(a6)
	tst.l	d0
	bne	Abort_Mem
	move.b	#-1,H_WStarted(a4)
.NoAMOS

; 	HUNKS 9 ... : les BANQUES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Cmp_CurBanks(a5),a0	Banques courantes
	move.l	a0,Cur_Banks(a5)
	lea	Cmp_CurDialogs(a5),a0	Dialogues courants
	move.l	a0,Cur_Dialogs(a5)
	move.w	Prg_Flags(a4),d2	Partie haute des flags
	lea	H_Load+8*8(a4),a6
.Loop	bsr	DecHunk
	bmi.s	.Mem
	beq.s	.LoopX
	IFNE	Debug
	moveq	#1,d0			Si Debug, force la copie
	ENDC
	bsr	Get_Bank
	beq.s	.Loop
.Mem	bset	#15,d2			Flag ABORT pour le programme!
.LoopX

;	Fin de RUN
; ~~~~~~~~~~~~~~~~
	move.l	H_DosBase(a4),DosBase(a5)
	move.l	sp,BasSp(a5)		Niveau FIN
	subq.l	#4,BasSp(a5)
	move.l	H_Program(a4),a0	Debut du programme
	move.l	BasA3(a5),a3		Buffer parametres
	move.l	H_Libraries(a4),a4	Base jsr(a4)
	jsr	(a0)
	bra	Abort			Fin normale
	bra	Run_Normal		Run Normal

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RUN SHORT MEMORY
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Run_Short
	move.l	Header_DZ(pc),a4
	lea	-Short_Save(sp),sp
; Sauve le nom du programme
	move.l	Name1(a5),a0
	lea	Short_Name(sp),a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
; Sauve le pathname courant
	move.l	PathAct(a5),a0
	lea	Short_Path(sp),a1
.Cop2	move.b	(a0)+,(a1)+
	bne.s	.Cop2
; Sauve la ligne de commande
	move.l	Buffer(a5),a0
	lea	TBuffer-256-6(a0),a0
	lea	Short_Command(sp),a1
	clr.b	(a1)
	cmp.l	#"CmdL",(a0)+
	bne.s	.Cop4
	move.w	(a0)+,d0
	move.w	d0,(a1)+
	beq.s	.Cop4
	subq.w	#1,d0
.Cop3	move.b	(a0)+,(a1)+
	dbra	d0,.Cop3
.Cop4
; Effacement de toute la m�moire
	bsr	Abort_All		Tout AMOS!
	move.l	H_Message(a4),d4	Le header
	move.l	H_DosBase(a4),d5
	move.l	H_IntBase(a4),d6
	lea	Header_DZ(pc),a0	La datazone!
	bsr	A0_Free
; Fait un flush!
	moveq	#4,d2			4 fois!!!
.Flush	move.l	#80000000,d0		Fait un flush!
	move.l	#Public,d1		80 megas en public!
	bsr	H_Ram
	dbra	d2,.Flush
; Charge tout le programme
	lea	Short_Name(sp),a0	Charge les hunks
	bsr	Load_Run
	beq	Abort_Mem
	bset	#FHead_Short,d2		Flags RUN-SHORT
	bra	ReRun_Short

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RUN NORMAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Run_Normal
	move.l	Header_DZ(pc),a4
; Enleve le programme precedent
	lea	H_Load+16(a4),a6
	bsr	EffLastLoad		Les librairies
	bsr	EffLastLoad		Le programmme
	bsr	Abort_Run		Les banques + buffers
	lea	Sys_Messages(a5),a0	+ les messages systeme
	bsr	A0_Free
; Charge le suivant
	move.l	Name1(a5),a0
	move.l	DosBase(a5),d5
	bsr	Load_Run
	beq	Abort_Mem
	bset	#FHead_Run,d2		Change le flag
	bset	#FPrg_DefRunAcc+16,d2	DEFRUNACC pour le programme
	bra	ReRun_Normal

; Charge tout le programme suivant, le branche sur le precedent
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Load_Run
	move.l	a0,d1
	move.l	d5,a6
	jsr	-150(a6)
	tst.l	d0
	beq.s	.Err
; Enleve le premier hunk (header), en recuperant les flags
	lsl.l	#2,d0
	move.l	d0,a2
	move.l	a2,a1
	move.l	-(a1),d0
	move.l	Header_DebPrg(pc),a0
	move.l	(a2)+,-4(a0)		Branche apres celui-ci
	move.l	2(a2),d2		Flags programme + Flags hader
	move.l	2+6(a2),d3		Prend les flags
	bsr	H_Free
	moveq	#-1,d0			VRAI
.Err	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SORTIE DU PROGRAMME
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Messages d'erreur!
; ~~~~~~~~~~~~~~~~~~~~~~~~
Abort_Panic
	moveq	#20,d0			Rien n'est ouvert!
	bra	Abort_Finish
Abort_Mem
	moveq	#-2,d0			Out of mem
	bra.s	Abort
Abort_Lib
	moveq	#-3,d0			Cannot open amos.library

;	Trouve / Copie le message d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Abort	move.l	d0,-(sp)		Message d'erreur reel
	sub.l	a2,a2
	move.l	d0,d2
	beq.s	.Push
	moveq	#20,d2			Message d'erreur CLI= 20
	cmp.w	#-2,d0			Out of memory
	beq.s	.Mem
	cmp.w	#-3,d0			Cannot open amos.library
	bne.s	.Mess
.Lib	lea	NoAMOSlib(pc),a0
	bra.s	.Mess
.Mem	lea	OOfMem(pc),a0
.Mess	move.l	a0,d1			Un message?
	beq.s	.Push
	tst.b	(a0)			Vraiment un message?
	beq.s	.Push
	lea	-256(sp),sp		Copie dans la pile
	move.l	sp,a2
	move.l	sp,a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
.Push	movem.l	a2/d2,-(sp)

; Quelquechose d'ouvert?
	move.l	Header_DZ(pc),d0	Adresse de la datazone
	beq.s	.PMess			Rien de demarre!
	move.l	d0,a4
; Un PRUN?
	tst.b	H_PRun(a4)
	bne.s	Abort_PRun
	bsr	Abort_All		Va tout fermer
; Efface la zone de donnees du header
	move.l	H_Message(a4),d4	Prend les donnees essentielles!
	move.l	H_DosBase(a4),d5
	move.l	H_IntBase(a4),d6
	lea	Header_DZ(pc),a0
	bsr	A0_Free
; Imprime l'eventuel message d'erreur
.PMess	move.l	4(sp),a0
	bsr	Print_Message
	move.l	(sp),d0

; Ferme toutes les librairies restantes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Abort_Finish
	move.l	d0,d2
	move.l	$4.w,a6
	tst.l	d5			Ferme dos.library
	beq.s	.Skip1
	move.l	d5,a1
	jsr	_LVOCloseLibrary(a6)
.Skip1	tst.l	d6
	beq.s	.Skip2
	move.l	d6,a6			Rouvre le workbench
	jsr	-210(a6)
	move.l	$4.w,a6			Ferme la librairie
	move.l	d6,a1
	jsr	_LVOCloseLibrary(a6)
.Skip2	tst.l	d4
	beq.s	.PaMe
	move.l	$4.w,a6
	jsr	_LVOForbid(a6)
	move.l 	d4,a1
	jsr	-378(a6)
.PaMe	move.l	d2,d0
; On sort!
	move.l	Header_Pile(pc),sp
	rts

; Sort d'un PRUN
; ~~~~~~~~~~~~~~
Abort_PRun
	bsr	Abort_Run		Les banques + buffers
	moveq	#H_NLoad,d2		Toutes les donnees chargees
	lea	H_Load(a4),a2
	bsr	Free_Memories
	moveq	#0,d4			Pas de message
	move.l	H_DosBase(a4),d5
	move.l	H_IntBase(a4),d6
	lea	Header_DZ(pc),a0	La zone de donnee header
	bsr	A0_Free
	move.l	8(sp),d0		Reprend le message d'erreur
	bra.s	Abort_Finish		On sort!

; Ferme toute la datazone AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Abort_All
; Arrete amos.library si demarree
	tst.b	H_WStarted(a4)
	beq.s	.Pas
	move.l	H_WAddress(a4),a0	Stop amos.library
	jsr	4(a0)
.Pas
; Enleve tout (a5) si defini
	move.l	H_DataA5(a4),d0
	beq.s	.NoDZ
	move.l	d0,a5
	bsr	Abort_Run		Tout run
	lea	Sys_Messages(a5),a0	+ messages systeme
	bsr	A0_Free
	lea	PathAct(a5),a0		+ pathact
	bsr	A0_Free
	lea	H_DataZone(a4),a0	+ datazone
	bsr	A0_Free
.NoDZ

; Enleve toutes les donnees chargee
	moveq	#H_NLoad,d2		Enleve tout!
	lea	H_Load(a4),a2
	bsr	Free_Memories

; Enleve amos.library si chargee
	move.l	H_WAddress(a4),d0
	beq.s	.noLib
	move.l	d0,a0				Stop system
	jsr	16(a0)
	move.l	H_DosBase(a4),a6		Unloadsegment
	move.l	H_WSegment(a4),d1
	beq.s	.noLib
	jsr	_LVOUnLoadSeg(a6)
.noLib
; Enleve la graphics.library
	move.l	$4.w,a6
	move.l	T_GfxBase(a5),d0
	beq.s	.NoGFX
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
.NoGFX
	rts

; Libere les buffers recharges par RUN
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Abort_Run
	lea	Ed_RunMessages(a5),a0
	bsr	A0_Free
	move.l	Sys_Resource(a5),d0
	beq.s	.NoRes
	move.l	d0,a1
	lea	-8*3(a1),a1
	move.l	4(a1),d0
	addq.l	#8,d0
	bsr	H_Free
	clr.l	Sys_Resource(a5)
.NoRes	rts

; 	Imprime le message d'erreur dans l'entree courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Message
;	D4=	WB Message
;	D5=	DosBase
;	D6=	IntBase
Print_Message
	move.l	a0,d7			Un message?
	beq.s	.Exit
	tst.l	d4			Wb  ou CLI?
	bne.s	.Wb
; Sous DOS-> Message dans la fenetre courante
	move.l	d5,a6			Handle courant
	jsr	-60(a6)
	move.l	d0,d1
	beq.s	.Exit
	move.l	d7,a1
.Copy	tst.b	(a1)+
	bne.s	.Copy
	move.b	#10,-1(a1)
	clr.b	(a1)
	move.l	a1,d3
	sub.l	d7,d3
	move.l	d7,d2
	jsr	_LVOWrite(a6)
.Exit	rts
; Sous WB-> ouvre une tchote fenetre
.Wb	move.l	d6,a6			IntBase
	lea	H_Click(pc),a0
	lea	H_AutoBody(pc),a1
	move.l	d7,12(a1)
	lea	H_AutoClick(pc),a3
	move.l	a0,12(a3)
	sub.l	a2,a2
	sub.l	a0,a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	#560,d2
	moveq	#50,d3
	jsr	-348(a6)
	rts


;	Clear CPU Caches, quel que soit le systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_ClearCache
	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	cmp.w	#36,$14(a6)			Si systeme 2.0
	bcs.s	.Exit
	jsr	-$27c(a6)			CacheClearU
.Exit	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts

;	Trouve un message configuration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_GetMessage
	move.l	Sys_Messages(a5),a0
GetMessage
	clr.w	d1
	addq.l	#1,a0
	bra.s	.In
.Loop	move.b	(a0),d1
	lea	2(a0,d1.w),a0
.In	subq.w	#1,d0
	bgt.s	.Loop
.Out	move.b	(a0)+,d0
	rts

;	Reservation memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~
H_Ram	movem.l	a0-a1/a6/d1,-(sp)
	move.l	$4.w,a6
	jsr	-198(a6)
	movem.l	(sp)+,a0-a1/a6/d1
	tst.l	d0
	rts
H_Free	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	jsr	FreeMem(a6)
	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts
H_Copy	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	$4.w,a6
	jsr	 -$270(a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

; 	Reserve un espace m�moire sur (a0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
;	D0=	Longueur
;	D1=	Flags
A0_Reserve
	movem.l	a1/d0/d2,-(sp)
	move.l	a0,a1
	move.l	d0,d2
	addq.l	#4,d0
	bsr	H_Ram
	beq.s	.Out
	move.l	d0,a0
	move.l	d2,(a0)+
	move.l	a0,(a1)
.Out	movem.l	(sp)+,a1/d0/d2
	rts

; 	Efface un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
A0_Free
	movem.l	a0/a1/d0,-(sp)
	move.l	(a0),d0
	beq.s	.Skip
	clr.l	(a0)
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	bsr	H_Free
.Skip	movem.l	(sp)+,a0/a1/d0
	rts

;	Reloge le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1=	Table de relocation
;	A2=	Debut programme
;	A3=	Debut librairies
H_Reloc	moveq	#-1,d0
	move.l	a2,a0
.Loop	moveq	#0,d1
	move.b	(a1)+,d1
	beq.s	.Zero
	cmp.b	#1,d1
	bne.s	.Relo
	lea	508(a0),a0
	bra.s	.Loop
.Zero	move.l	a3,a0
	addq.l	#1,d0
	beq.s	.Loop
	rts
.Relo	lsl.w	#1,d1
	add.l	d1,a0
	move.l	(a0),d2
	bmi.s	.Lib
	add.l	a2,d2
	move.l	d2,(a0)
	bra.s	.Loop
.Lib	bclr	#31,d2
	add.l	a3,d2
	move.l	d2,(a0)
	bra.s	.Loop

;-----> Gestion des banques, A1= adresse banque
;	D0 (si debug)=
Get_Bank
	movem.l	a2/d2-d4,-(sp)
; Une banque de sprites / icons?
	cmp.l	#"AmSp",(a1)
	beq.s	.Spr
	cmp.l	#"AmIc",(a1)
	beq.s	.Ico
; Banque simple: branche dans la liste

	IFNE	Debug
	tst.w	d0
	bne.s	.Debug
	ENDC

; Mode normal: simple changement dans la liste
	move.l	Cur_Banks(a5),a0
	subq.l	#8,a1			Pointe le header
	move.l	(a1),4(a1)		Longueur
	subq.l	#8,4(a1)		Moins header Listes
	move.l	(a0),(a1)
	move.l	a1,(a0)
	bsr	ClrLastLoad		Banque debranchee des hunks
	bra	.Ok

; Mode debug: recopie la banque dans une zone reservee par amos.library
	IFNE	Debug
.Debug	move.l	-8(a6),a1		Adresse banque
	movem.l	a0-a1/a6/d1-d2,-(sp)	TypeOfMem
	move.l	$4.w,a6
	jsr	-$216(a6)
	movem.l	(sp)+,a0-a1/a6/d1-d2
	btst	#1,d0			CHIP?
	bne.s	.Chip
	move.l	-4(a6),d0
	SyCall	MemFast
	bra.s	.Suit
.Chip	move.l	-4(a6),d0
	SyCall	MemChip
.Suit	beq	.Error
	exg.l	a0,a1			Va copier la banque origine
	bsr	H_Copy
	move.l	Cur_Banks(a5),a0
	move.l	(a1),4(a1)		Longueur
	subq.l	#8,4(a1)
	move.l	(a0),(a1)
	move.l	a1,(a0)
	bsr	EffLastLoad		Efface l'origine
	bra	.Ok
	ENDC
; Banque de sprites
.Spr	moveq	#1,d3
	lea	Head_Sprite(pc),a0
	moveq	#1<<Bnk_BitBob+1<<Bnk_BitData,d4
	bra.s	.SprIco
; Banque d'icones
.Ico	moveq	#2,d3
	lea	Head_Icon(pc),a0
	moveq	#1<<Bnk_BitIcon+1<<Bnk_BitData,d4
; Cree la banque
.SprIco	move.l	a0,-(sp)
	addq.l	#4,a1
	move.w	(a1)+,d2		Nombre de sprites
	move.w	d2,d0
	lsl.w	#3,d0			* 8
	add.w	#24+2+32*2,d0		+ header + Palette
	ext.l	d0
	SyCall	MemFastClear
	beq.s	.Error
	move.l	a0,a2
	move.l	Cur_Banks(a5),a0	Branche la banque
	move.l	(a0),(a2)
	move.l	a2,(a0)
	subq.l	#8,d0			Moins header listes
	move.l	d0,4(a2)
	lea	8(a2),a2		Met le header
	move.l	d3,(a2)+
	move.w	d4,(a2)+
	clr.w	(a2)+
	move.l	(sp)+,a0
	move.l	(a0)+,(a2)+		Copie le nom
	move.l	(a0)+,(a2)+
	move.w	d2,(a2)+		Nombre de sprites
	bra.s	.SIn
.SLoop	move.w	(a1),d0			Taille d'un sprite
	mulu	2(a1),d0
	mulu	4(a1),d0
	beq.s	.SNext
	lsl.l	#1,d0
	add.l	#10,d0
	SyCall	MemChip
	beq.s	.Error
	move.l	a0,(a2)
	exg	a0,a1
	bsr	H_Copy
	exg	a0,a1
	lea	-10(a1,d0.l),a1
.SNext	lea	10(a1),a1
	addq.l	#8,a2
.SIn	dbra	d2,.SLoop
	moveq	#32-1,d0
.Pal	move.w	(a1)+,(a2)+
	dbra	d0,.Pal
	bsr	EffLastLoad		Debranche des hunks
; Retourne l'adresse de la banque
.Ok	move.l	Cur_Banks(a5),a0	Retourne Start(b)
	move.l	(a0),a0
	lea	8*3(a0),a0
	moveq	#0,d0
	bra.s	.Out
; Out of mem pendant la copie de la banque
.Error	moveq	#1,d0			Laisse le HUNK sur A6!
; Sortie
.Out	movem.l	(sp)+,a2/d2-d4
	rts

;	Enleve le dernier hunk de la liste
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EffHunk	move.l	Header_DebPrg(pc),a0
	move.l	-4(a0),d0
	lsl.l	#2,d0
	move.l	d0,a1			Adresse
	move.l	(a1),-4(a0)		Detache de la liste
	move.l	-(a1),d0		Longueur
	bra	H_Free

;	Decompacte et enleve de la liste le HUNK suivant le header
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A6> Liste des zones reservees
DecHunk	movem.l	a0/a2-a5/d2-d7,-(sp)
	move.l	Header_DebPrg(pc),a4
	move.l	-4(a4),d0
	lsl.l	#2,d0
	beq	DecEnd
	move.l	d0,a2
; Compacte ou non?
	cmp.l	#$78566467,4(a2)
	beq.s	DecHC
; Non compacte, met directement dans la liste delete
	move.l	(a2),-4(a4)		Detache de la liste
	move.l	-(a2),d1
	move.l	a2,(a6)+		Poke l'adresse REELLE dans la liste
	move.l	d1,(a6)+		La longueur REELLE
	lea	8(a2),a1
	subq.l	#8,d1
	moveq	#1,d0
	bra.s	DecEnd
; Hunk compacte..
DecHC	move.l	a2,a1
	movem.l	a0-a1/a6/d1-d2,-(sp)	TypeOfMem
	move.l	$4.w,a6
	jsr	-$216(a6)
	movem.l	(sp)+,a0-a1/a6/d1-d2
	and.l	#$0003,d0		Enleve le flag FAST!
	or.w	#$0001,d0		Public mem
	move.l	d0,d1
	move.l	8(a2),d2
	move.l	d2,d0
	addq.l	#8,d0			+ Header de banque!
	bsr	H_Ram
	bne.s	.Skip
	moveq	#-1,d0
	bra.s	DecEnd
.Skip	addq.l	#8,d0			Saute le header
	move.l	d0,a1
	movem.l	a1/d2,-(sp)		Adresses banque
	movem.l	a2/a4,-(sp)		Infos hunks
	move.l	d0,d3
	move.l	12(a2),d1		Longueur a decompater
	move.l	d1,d0
	lea	16(a2),a0		Origine des data
	bsr	H_Copy			Copie
	bsr	UnSquash		Va decompacter
	movem.l	(sp)+,a1/a4		Enleve le hunk de la liste
	move.l	(a1),-4(a4)		Detache de la liste
	move.l	-(a1),d0
	bsr	H_Free
	movem.l	(sp)+,a1/d1
	lea	-8(a1),a0
	move.l	d1,d0
	addq.l	#8,d0
	move.l	a0,(a6)+		Adresse reelle dans la liste
	move.l	d0,(a6)+		Longueur reelle
	move.l	d0,(a0)
	clr.l	4(a0)			Faux header de chunk
	moveq	#1,d0			Pas d'erreur!
DecEnd	movem.l	(sp)+,a0/a2-a5/d2-d7
	tst.l	d0			1= Ok existe / 0= termine / -1= out of mem!
	rts

;	Enleve le dernier pointeur de la liste (a6)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EffLastLoad
	movem.l	a1/d0,-(sp)
	move.l	-(a6),d0
	clr.l	(a6)
	move.l	-(a6),a1
	clr.l	(a6)
	bsr	H_Free
	movem.l	(sp)+,a1/d0
	rts
;	Efface de la liste le dernier pointeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClrLastLoad
	clr.l	-(a6)
	clr.l	-(a6)
	rts
; 	Libere les buffers de chargement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_Memories
	subq.w	#1,d2
.Loop	move.l	(a2),d0
	beq.s	.Skip
	move.l	d0,a1
	move.l	4(a2),d0
	beq.s	.Skip
	bsr	H_Free
.Skip	addq.l	#8,a2
	dbra	d2,.Loop
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
L22446E
;Flish	nop				Place pour le FLASH
;	nop
;	nop
	LSR.L	#1,D0
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
	BLT	L22446E
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

Header_DZ	dc.l	0
Header_DebPrg	dc.l	0
Header_Pile	dc.l	0

		RsReset
H_Flags		rs.l	1
Prg_Flags	equ	H_Flags
Head_Flags	equ	H_Flags+3

H_DosBase	rs.l	1
H_IntBase	rs.l	1
H_WAddress	rs.l	1
H_WSegment	rs.l	1
H_Message	rs.l	1
H_Program	rs.l	1
H_Libraries	rs.l	1
H_DataZone	rs.l	1
H_DataA5	rs.l	1

H_WStarted	rs.b	1
H_Short		rs.b	1
H_PRun		rs.b	1
		rs.b	1

H_Load		rs.l	12*2
H_DZLong	equ	__RS

H_NLoad		equ	12

; Definition du petit requester
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
H_AutoBody	dc.b	2,0
		dc.w	1
		dc.w	8,7
		dc.l	0
		dc.l	0
		dc.l	0
H_AutoClick	dc.b	0,1
		dc.w	1
		dc.w	5,4
		dc.l	0
		dc.l	0
		dc.l	0
H_Click		dc.b	" Cancel ",0
		even

DosName		dc.b	"dos.library",0
IntName		dc.b	"intuition.library",0
GfxName		dc.b	"graphics.library",0
OOfMem		dc.b	"Out of memory.",0
NoAMOSlib	dc.b	"Cannot open AMOS.library (V2.00 or over).",0
LibName1	dc.b	"Libs:AMOS.library",0
LibName2	dc.b	"APSystem/AMOS.library",0
LibName3	dc.b	"Libs/AMOS.library",0
		even
Head_Sprite	dc.b	"Sprites ",0
Head_Icon	dc.b	"Icons   ",0
		even


FInit
LInit		equ 	FInit-DebPrg
