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

*
		INCDIR	":AMOS.S/Common/"
		Include	"_Equ.s"
		RsSet	DataLong
		Include "_Pointe.s"
*
		Include	"_WEqu.s"
		Include "_CEqu.s"
		Include	"_LEqu.s"
*
CDebug		set	0
*
F_Courant	equ	0
F_Source	equ	1
F_Objet		equ	2
F_Libs		equ	3
M_Libs		equ	27
M_Fichiers	equ	F_Libs+M_Libs
Mes_Base	equ	14+26
Mes_BaseCh	equ	36
Mes_BaseNoms	equ	46
*
		Bra	CliIn
		Bra	AMOSIn1
		Bra	AMOSIn2
		dc.b	"ACmp"
;---------------------------------------------------------------------
		dc.b	0,"$VER: 1.36",0
		even
; Modifs 1.34b / 1.34
;        	- Print # avec des ;
;
;---------------------------------------------------------------------
*
Ext_Nb		equ	5
Ext_TkCmp       equ     6
Ext_TkCOp       equ     $14
Ext_TkTston     equ     $28
Ext_TkTstof     equ     $3a
Ext_TkTst       equ     $4e
*
;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
;  Entree AMOS mode direct
;---------------------------------------------------------------------
AMOSIn1	move.l	a5,a4
	lea	DZ(pc),a5
	bsr	ResetDZ
	move.w	#1,Flag_AMOS(a5)
	bra.s	AMOS_Suite
;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
;  Entree AMOS compiler.amos
;---------------------------------------------------------------------
AMOSIn2	lea	AMOS_Save(pc),a1
	movem.l	a3-a6,(a1)
	move.l	a5,a4
	lea	DZ(pc),a5
	bsr	ResetDZ
	move.w	#-1,Flag_Quiet(a5)
	move.w	#-1,Flag_AMOS(a5)
AMOS_Suite
	move.l	IconBase(a4),C_IconBase(a5)
	bne.s	.skip
	move.w	#-1,IconAMOS(a5)
.skip	move.l	DosBase(a4),C_DosBase(a5)
	move.l	T_GfxBase(a4),C_GfxBase(a5)
	move.l	a4,AMOS_Dz(a5)
	bra	Go_On
;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
;  Entree CLI
;---------------------------------------------------------------------
CliIn	lea	DZ(pc),a5
	bsr	ResetDZ
	clr.w	Flag_AMOS(a5)

* Entree commune
Go_On	move.l	sp,C_Pile(a5)
	move.l	a0,a1
	move.l	d0,d1
* Buffer de travail
	move.l	#256,d0
	bsr	ResBuffer
	beq	OOfMem
	move.l	a0,B_Work(a5)
* Recopie la ligne de commande
	subq.l	#1,d1
	bmi.s	.loop3
.loop1	move.b	(a1)+,d0
	cmp.b	#32,d0
	bcs.s	.loop2
	move.b	d0,(a0)+
.loop2	dbra	d1,.loop1
.loop3	clr.b	(a1)
* Init de l'amigados
	bsr	IniDisc
* Liste par defaut
	lea	Def_Liste(pc),a0
	lea	Nom_Liste(a5),a1
.Init0	move.b	(a0)+,(a1)+
	bne.s	.Init0

	moveq	#3,d0
	bsr	GoPos
* Flash par defaut, aucun!
	move.w	#32,Flag_Flash(a5)
* Explore la ligne de commande (si option -C)
	move.l	B_Work(a5),a0
	bsr	CommandLine
* Charge la LIB LISTE / Explore sa ligne de commande (si option -E)
	lea	Nom_Liste(a5),a1
	bsr	LoadInBuffer
	moveq	#1,d3
	bsr	ListeNom
	move.l	B_DiskIn(a5),a0
	bsr	CommandLine
	move.l	d0,-(sp)
* Encore un coup la vraie...
	move.l	B_Work(a5),a0
	bsr	CommandLine
	move.l	d0,-(sp)
* Ca y est! On peut trouver les noms
	bsr	InitListe
* Des erreurs?
	move.l	(sp)+,d0
	bne	ErrCommand
	move.l	(sp)+,d0
	bne	ErrComList
* Imprime le titre
	moveq	#20,d0
	bsr	MesPrint
* Ouvre l'icon.library
	bsr	InitIcons
* Longueur des buffers
	moveq	#1,d0
	bsr	GetChiffre
	move.l	d0,L_Bso(a5)
	moveq	#2,d0
	bsr	GetChiffre
	move.l	d0,MaxBob(a5)

* 1ere phase terminee
	moveq	#6,d0
	bsr	GoPos

* Debut de compilation
Compile
* Initialisations
	bsr	IniSource
	bsr	IniNOb
	moveq	#9,d0
	bsr	GoPos

	bsr	IniObjet
	moveq	#12,d0
	bsr	GoPos

	moveq	#18,d0
	bsr	CompPos
	bsr	InitLibs
	bsr	FActualise

* Compilation
	bsr	Passe1
	bsr	Passe2

* Sauvegarde
	bsr	SObject
	bsr	SIcon
	move.w	#143,d0
	bsr	GoPos
	bsr	FActualise

* Nettoyage
CFin
	moveq	#29,d0
	bsr	MesPrint
	move.l	MaxMem(a5),d0
	bsr	Digit
	moveq	#31,d0
	bsr	MesPrint
*
	moveq	#30,d0
	bsr	MesPrint
	move.l	L_Objet(a5),d0
	bsr	Digit
	moveq	#31,d0
	bsr	MesPrint
*
	moveq	#32,d0
	bsr	MesPrint

	IFNE	CDebug
	bsr	Print_Buffers
	ENDC

	moveq	#0,d0
	move.l	L_Objet(a5),d1
	moveq	#0,d2
	move.w	NbInstr(a5),d2
	bra	CFini

******* Re-initialisation Datazone
ResetDZ
	movem.l	a0/d0,-(sp)
	move.l	a5,a0
	move.w	#LDZ-1,d0
Rdz	clr.b	(a0)+
	dbra	d0,Rdz
	movem.l	(sp)+,a0/d0
	rts

******* Exploration d'une ligne de commande...

CommandLine:

; Saute le d�but
.Cli0	move.b	(a0)+,d0
	beq	.CliX
	cmp.b	#" ",d0
	beq.s	.Cli0
	subq.l	#1,a0
; Nom du programme SOURCE?
	cmp.b	#"-",(a0)
	beq.s	.CliO
	lea	Nom_Source(a5),a1
	move.l	a1,d2
	bsr	.CliNom
; Options
.CliO	move.b	(a0)+,d0
	beq	.CliX
	cmp.b	#" ",d0
	beq.s	.CliO
	cmp.b	#"-",d0
	bne	.CliE
	move.b	(a0)+,d0
	beq	.CliE
	bsr	D0Maj
	cmp.b	#"D",d0
	beq	.ClioD
	cmp.b	#"O",d0
	beq	.ClioO
	cmp.b	#"C",d0
	beq	.ClioC
	cmp.b	#"F",d0
	beq	.ClioF
	cmp.b	#"E",d0
	beq	.ClioE
	cmp.b	#"S",d0
	beq	.ClioS
	cmp.b	#"T",d0
	beq	.ClioT
	cmp.b	#"W",d0
	beq	.ClioW
	cmp.b	#"Q",d0
	beq	.ClioQ
	cmp.b	#"L",d0
	beq	.ClioL
	cmp.b	#"Z",d0
	beq	.ClioZ
** Erreur dans la commandline
.CliE	moveq	#-1,d0
	rts
** OK!
.CliX	moveq	#0,d0
	rts
** OPTION -D<source><sbjet>
.ClioD	bsr	.Cli01
	move.w	d0,Flag_Source(a5)
	bsr	.Cli01
	move.w	d0,Flag_Objet(a5)
	bra	.CliO
** OPTION -Errors
.ClioE	bsr	.Cli01
	move.w	d0,Flag_Errors(a5)
	bra	.CliO
** OPTION -L
.ClioL	move.w	#1,Flag_Long(a5)
	bra	.CliO
** OPTION -Screen
.ClioS	bsr	.Cli01
	move.w	d0,Flag_Default(a5)
	bra	.CliO
** OPTION -Object
.ClioO	lea	Nom_Objet(a5),a1
	bsr	.CliNom
	bra	.CliO
** OPTION -Configuration
.ClioC	lea	Nom_Liste(a5),a1
	bsr	.CliNom
	bra	.CliO
** OPTION -FromDEVICE:
.ClioF	lea	Nom_From(a5),a1
	bsr	.CliNom
	bra	.CliO
** OPTION Type : 0=WB / 1=CLI / 2=Backstart / 3=AMOS
.ClioT	bsr	.CliDigit
	move.w	d0,Flag_Type(a5)
	bra	.CliO
** OPTION Wb01 : 0= AMOS / 1= WB
.ClioW	bsr	.Cli01
	move.w	d0,Flag_WB(a5)
	bra	.CliO
** OPTION Quiet
.ClioQ	or.w	#1,Flag_Quiet(a5)
	bra	.CliO
** OPTION Z
.ClioZ	bsr	.CliDigit
	move.w	d0,d1
	mulu	#10,d1
	bsr	.CliDigit
	add.b	d0,d1
	move.w	d1,Flag_Flash(a5)
	bra	.CliO
** Routines
.CliNom	move.b	#" ",d1
	move.b	(a0),d0
	beq.s	.Clin1
	cmp.b	#'"',d0
	beq.s	.ClinB
	cmp.b	#"'",d0
	bne.s	.Clin0
.ClinB	move.b	d0,d1
	addq.l	#1,a0
.Clin0	move.b	(a0),d0
	beq.s	.Clin1
	addq.l	#1,a0
	cmp.b	d0,d1
	beq.s	.Clin1
	move.b	d0,(a1)+
	bra.s	.Clin0
.Clin1	clr.b	(a1)
	rts
.Cli01	move.b	(a0)+,d1
	beq	.CliE
	clr.w	d0
	cmp.b	#"0",d1
	beq.s	.Cli01x
	cmp.b	#"1",d1
	bne	.CliE
	subq.w	#1,d0
.Cli01x	rts
.CliDigit
	moveq	#0,d0
	move.b	(a0)+,d0
	beq	.CliE
	sub.b	#"0",d0
	bcs	.CliE
	rts
D0Maj	cmp.b	#"a",d0
	bcs.s	D0mx
	cmp.b	#"z",d0
	bhi.s	D0mx
	sub.b	#$20,d0
D0mx	rts
******* Fabrique le nom du programme OBJET, si NOM.AMOS!
IniNOb	tst.b	Nom_Objet(a5)
	bne.s	NObX
	lea	Nom_Source(a5),a1
	move.l	a1,d2
.Nob	tst.b	(a1)+
	bne.s	.Nob
	subq.l	#1,a1
	lea	SOMA(pc),a2
.Cli2	cmp.l	d2,a1
	bls.s	NObx
	move.b	(a2)+,d1
	beq.s	.Cli3
	move.b	-(a1),d0
	bsr	D0Maj
	cmp.b	d0,d1
	beq.s	.Cli2
	bne.s	NObx
.Cli3	exg	d2,a1
	lea	Nom_Objet(a5),a2
.Cli4	move.b	(a1)+,(a2)+
	cmp.l	d2,a1
	bcs.s	.Cli4
; Si type=4, nom= nom_C.AMOS
	cmp.w	#3,Flag_Type(a5)
	bne.s	.Cli6
	lea	_C.AMOS(pc),a1
.Cli5	move.b	(a1)+,(a2)+
	bne.s	.Cli5
.Cli6	clr.b	(a2)
NObX	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; SORTIE compilation
;---------------------------------------------------------------------

******* Actualisation position compilateur
Actualise
	tst.w	Flag_AMOS(a5)
	bpl.s	.End
	move.l	AMOS_Dz(a5),a0
	tst.b	T_Actualise(a0)
	bne.s	DoVbl
.End	rts
* Un VBL!
DoVbl	movem.l	a1-a6/d1-d7,-(sp)
	lea	AMOS_Save(pc),a0
	movem.l	(a0),a3-a6
* Actualise
	SyCall	Synchro
* Break
	move.w	T_Actualise(a5),d7
	clr.w	T_Actualise(a5)
	bclr	#BitControl,d7
	beq.s	.cont
	movem.l	(sp)+,a1-a6/d1-d7
	bra	ErrAbort
* Affiche le bob?
.cont	bclr	#BitBobs,d7
	beq.s	.skip
	SyCall	ActBob
	SyCall	AffBob
.skip	movem.l	(sp)+,a1-a6/d1-d7
	rts

******* Set compiler position...
GoPos	bsr	CompPos
	bra	FActualise
CompPos	tst.w	Flag_AMOS(a5)
	bmi.s	.Yes
	rts
.Yes	movem.l	d0-d7/a1-a6,-(sp)
	move.l	AMOS_Dz(a5),a5
	moveq	#-1,d1
	moveq	#0,d2
	moveq	#0,d3
	SyCall	AMALReg
	movem.l	(sp)+,d0-d7/a1-a6
	move.w	d0,(a0)
	move.w	d0,Pour_Pos(a5)
	rts

******* Fait progresser la fleche -> fin
FActualise
	tst.w	Flag_AMOS(a5)
	bmi.s	.Loop
	rts
.Loop	bsr	Actualise
	movem.l	d1-d7/a1-a2/a5,-(sp)
	move.l	AMOS_Dz(a5),a5
	moveq	#-1,d1
	moveq	#0,d2
	moveq	#1,d3
	SyCall	AMALReg
	movem.l	(sp)+,d1-d7/a1-a2/a5
	move.w	(a0),d0
	cmp.w	Pour_Pos(a5),d0
	bcs.s	.loop
	rts

******* Set pourcentage
*	D0= largeur alouee
*	D1= nombre de pas
SetPour	divu	d0,d1
	tst.w	d1
	bne.s	.skip
	moveq	#1,d1
.skip	move.w	d1,Pour_Base(a5)
	move.w	d1,Pour_Cpt(a5)
	add.w	Pour_Pos(a5),d0
	bra	CompPos
******* Un pas d'affichage...
AffPour	tst.w	Flag_AMOS(a5)
	bpl.s	.Skip
	subq.w	#1,Pour_Cpt(a5)
	bne.s	.Skip
	move.w	Pour_Base(a5),Pour_Cpt(a5)
	bsr	DoVBL
.Skip	rts

******* Print un chiffre!
Digit	movem.l	d1-d7/a0-a2,-(sp)
	move.l	B_Work(a5),a0
	bsr	LongDec
	clr.b	(a0)
	move.l	B_Work(a5),a0
	bsr	StrPrint
	movem.l	(sp)+,d1-d7/a0-a2
	rts

******* Syntax error!
Synt
	moveq	#7,d0
NoQuiet
	move.w	Flag_Quiet(a5),-(sp)
	bmi.s	.skip
	clr.w	Flag_Quiet(a5)
	bsr	MesPrint
	bsr	FindL
	bsr	Digit
	bsr	Return
.skip
	move.w	(sp)+,Flag_Quiet(a5)
	moveq	#12,d0
	bra	SyntOut
******* Compilation aborted!
ErrAbort
	moveq	#9,d0
	bra.s	ErrPrint
******* Erreur: program not tested!
ErrNotest
	moveq	#12,d0
	bra.s	ErrPrint
******* Erreur: not an AMOS program!
ErrNoAMOS
	moveq	#13,d0
	bra.s	ErrPrint
******* Erreur: label not defined
ErrLabel
	bclr	#31,d0
	move.l	d0,a6
	moveq	#14,d0
	bra.s	NoQuiet
******* Erreur program already compiled
ErrAlready
	moveq	#15,d0
	bra.s	ErrPrint
******* Erreur: use the -l option
ErrDoLong
	moveq	#16,d0
	bra.s	ErrPrint
******* Erreur: nothing to compile!
ErrNothing
	moveq	#10,d0
	bra.s	ErrPrint
******* Erreur:	bad list!
ErrListe
	moveq	#4,d0
	bra.s	ErrPrint
******* Erreur: cannot uncode procedure
NoCode
	moveq	#8,d0
	bra.s	ErrPrint
******* Erreur: extension not loaded.
ErrExt
	moveq	#3,d0
	bra.s	ErrPrint
******* Syntax error dans la ligne de commande
ErrCommand
	moveq	#1,d0
	bra.s	ErrPrint
******* Syntax error dans la ligne de commande LISTE
ErrComList
	moveq	#2,d0
	bra.s	ErrPrint
******* Syntax error dans la configuration
ErrConfig
	moveq	#11,d0
	bra.s	ErrPrint
******* Erreur disque
DError
	moveq	#5,d0
	bra.s	ErrPrint
******* Erreur icons
NoIcons
	moveq	#4,d0
	bra.s	ErrPrint
******* Out of mem
Oofmem
	moveq	#6,d0

******* Sortie avec erreur!
ErrPrint
	move.w	d0,-(sp)
	move.w	Flag_Quiet(a5),-(sp)
	bmi.s	.skip
	clr.w	Flag_Quiet(a5)
	bsr	MesPrint
.skip
	move.w	(sp)+,Flag_Quiet(a5)
	move.w	(sp)+,d0
SyntOut
	add.w	#Mes_BaseNoms,d0
	bsr	GetNom
	lea	Nom_Source(a5),a1
.loop	move.b	(a0)+,(a1)+
	beq.s	.loop1
	cmp.b	#32,-1(a1)
	bcc.s	.loop
	subq.l	#1,a1
	bra.s	.loop
.loop1	tst.l	B_Noms(a5)
	beq.s	.loop2
	moveq	#32,d0
	bsr	MesPrint
.loop2
; Efface l'objet, si cree
	bsr	KObject
; Retour de parametres
	moveq	#10,d0
	moveq	#0,d1
	moveq	#0,d2

******* Abort general!
CFini	movem.l	d0/d1/d2,-(sp)
	bsr	EraBuffer
	bsr	FinIcons
	bsr	FinDisc
	movem.l	(sp)+,d0/d1/d2
CFini2	lea	Nom_Source(a5),a0
	move.l	C_Pile(a5),sp
	rts

	IFNE	CDebug
******* Imprime l'etat des buffers
Print_Buffers:
	lea	Mes_Buffers(pc),a4
	lea	B_Work(a5),a3
.Loop0	move.l	a4,a0
	bsr	StrPrint
	move.l	(a3),d0
	beq.s	.Loop3
	move.l	d0,a2
	move.l	-4(a2),d6
	subq.l	#4,d6
	lea	0(a2,d6.l),a1
.Loop1	tst.l	-(a1)
	bne.s	.Loop2
	cmp.l	a2,a1
	bhi.s	.Loop1
.Loop2	addq.l	#4,a1
	move.l	a1,d7
	sub.l	a2,d7
	move.l	d7,d0
	bsr	Digit
	lea	Mes_Bufs2(pc),a0
	bsr	StrPrint
	move.l	d6,d0
	bsr	Digit
	lea	Mes_Bufs3(pc),a0
	bsr	StrPrint
	move.l	d6,d0
	sub.l	d7,d0
	bsr	Digit
	bsr	Return
.Loop3	tst.b	(a4)+
	bne.s	.Loop3
	addq.l	#4,a3
	tst.b	(a4)
	bne.s	.Loop0
	bsr	Return
	rts
	ENDC

******* Trouve le num�ro de la ligne pointee par A6->D0
FindL	move.l	a6,d2
	move.l	#20,a6
	moveq	#0,d1
.Loop0	addq.l	#1,d1
	bsr	GetWord
	lsr.w	#8,d0
	beq.s	.Loop2
	lsl.w	#1,d0
	lea	-2(a6,d0.w),a6
	cmp.l	d2,a6
	bcs.s	.Loop0
* Trouve!
.Loop1	move.l	d1,d0
	rts
* Pas trouve!
.Loop2	moveq	#-1,d0
	rts

******* Imprime le message D0
MesPrint
	tst.w	Flag_Quiet(a5)
	bne.s	PrintXXX
* Imprime le message...
	movem.l	a0-a6/d0-d7,-(sp)
	add.w	#Mes_BaseNoms,d0
	bsr	GetNom
	tst.w	Flag_Amos(a5)
	bne.s	AMOSPrint
	move.l	d0,d3
	move.l	a0,d2
	move.l	C_DosBase(a5),a6
	jsr	-60(a6)
	move.l	d0,d1
	jsr	DosWrite(a6)
	movem.l	(sp)+,a0-a6/d0-d7
PrintXXX
	rts
AMOSPrint
	move.l	B_DiskIn(a5),a1
.Loop1	move.b	(a0)+,(a1)+
	beq.s	.Loop2
	cmp.b	#10,-1(a1)
	bne.s	.Loop1
	move.b	#13,-1(a1)
	move.b	#10,(a1)+
	bra.s	.Loop1
.Loop2	clr.b	(a1)
	move.l	B_DiskIn(a5),a1
	move.l	AMOS_Dz(a5),a5
	WiCall	Print
	movem.l	(sp)+,a0-a6/d0-d7
	rts

*******	Imprime la chaine A0 sur l'output standart
StrPrint
	tst.w	Flag_Quiet(a5)
	bne.s	Clip1
	movem.l	a0-a6/d0-d7,-(sp)
	tst.w	Flag_AMOS(a5)
	bne.s	AMOSPrint
	move.l	a0,-(sp)
	move.l	C_DosBase(a5),a6
	jsr	-60(a6)
	move.l	d0,d1
	move.l	(sp)+,d2
	move.l	d2,a0
Clip0	tst.b	(a0)+
	bne.s	Clip0
	move.l	a0,d3
	sub.l	d2,d3
	subq.l	#1,d3
	jsr	DosWrite(a6)
	movem.l	(sp)+,a0-a6/d0-d7
Clip1	rts

******* Return
Return
	lea	Mes_return(pc),a0
	bra.s	StrPrint


; CONVERSION HEXA--->DECIMAL SUR QUATRE OCTETS
longdec1: move #-1,d3         ;proportionnel
          moveq #1,d4         ;avec signe
          bra.s longent
longdec:  clr.l d4            ;proportionnel, sans espace si positif!
          move.l #-1,d3
; conversion proprement dite: LONG-->ENTIER
longent:  move.l a1,-(sp)
	  tst.l d0            ;test du signe!
          bpl.s hexy
          move.b #"-",(a0)+
          neg.l d0
          bra.s hexz
hexy:     tst d4
          beq.s hexz
          move.b #32,(a0)+
hexz:     tst.l d3
          bmi.s hexv
          neg.l d3
          add.l #10,d3
hexv:     move.l #9,d4
          lea multdix(pc),a1
hxx0:     move.l (a1)+,d1     ;table des multiples de dix
          move.b #$ff,d2
hxx1:     addq.b #1,d2
          sub.l d1,d0
          bcc.s hxx1
          add.l d1,d0
          tst.l d3
          beq.s hxx4
          bpl.s hxx3
          btst #31,d4
          bne.s hxx4
          tst d4
          beq.s hxx4
          tst.b d2
          beq.s hxx5
          bset #31,d4
          bra.s hxx4
hxx3:     subq.l #1,d3
          bra.s hxx5
hxx4:     add #48,d2
          move.b d2,(a0)+
hxx5:     dbra d4,hxx0
	  move.l (sp)+,a1
          rts
* TABLE DES MULTIPLES DE DIX
multdix:  dc.l 1000000000,100000000,10000000,1000000
          dc.l 100000,10000,1000,100,10,1,0


;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; PASSE 1-> Fabrication du code
;---------------------------------------------------------------------

Passe1
* Reservation des buffers
	moveq	#8,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_FlagVarL(a5)
	moveq	#7,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_FlagVarG(a5)
	move.l	a0,A_FlagVarL(a5)
	moveq	#5,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_Chaines(a5)
	move.l	a0,A_Chaines(a5)
	moveq	#8,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_Lea(a5)
	move.l	a0,A_Lea(a5)
	move.l	#$7FFFFFFF,(a0)
	moveq	#6,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_Labels(a5)
	moveq	#7,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_Bcles(a5)
	move.l	a0,A_Bcles(a5)
	move.l	#128,d0
	bsr	ResBuffer
	move.l	a0,B_Stock(a5)
	move.l	a0,A_Stock(a5)
* Longueur du buffer par default
	move.l	#8,L_Buf(a5)
* Relocation
	bsr	InitRel
* Adresses SORTIE / ENTREE
	sub.l	a4,a4
	lea	20,a6

******* Message
	moveq	#22,d0
	bsr	MesPrint
	moveq	#36,d0
	moveq	#0,d1
	move.w	NL_Source(a5),d1
	bsr	SetPour

******* Va fabriquer le header
	bsr	Header

;-----> Debut du hunk programme
	moveq	#NH_Prog,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk

;-----> Debut de la relocation
	move.l	a4,DebRel(a5)
	move.l	a4,OldRel(a5)

;-----> NO DATAS
	bsr	CreNoData

;-----> Appel des routines d'init
	bsr	CreeInits

;-----> Code bug
	IFNE	CDebug
	lea	BugCode(pc),a0
	bsr	OutCode
	ENDC

;--------------------------------------> Programme principal
	bsr	PrgIn
	moveq	#L_PrgIn,d0
	bsr	CreFonc
ChrGet	bsr	AffPour
	cmp.l	A_Banks(a5),a6
	beq.s	ChrEnd
	bsr	GetWord
	beq.s	ChrEnd
; Regarde la table des branchements en avant
Chr0	move.l	B_Lea(a5),a0
	cmp.l	(a0),a6
	bcs.s	Chr1
	bsr	PokeAd
	bra.s	Chr0
; Appelle l'instruction
Chr1	bsr	GetWord
	beq.s	ChrGet
	addq.w	#1,NbInstr(a5)
	lea	Tk(pc),a0
	move.w	0(a0,d0.w),d1
	bne.s	Chr2
	bsr	IStandard
	bra.s	Chr0
Chr2	jsr	0(a0,d1.w)		* Une autre instruction
	bra.s	Chr0
* Appelle la routine de fin
ChrEnd	move.w	#L_End,d0
	bsr	CreJmp
	move.l	AdAdress(a5),AdAdAdress(a5)
	move.w	Flag_Labels(a5),OFlag_Labels(a5)
	move.w	Flag_Procs(a5),OFlag_Procs(a5)
	move.l	B_FlagVarL(a5),A_FlagVarL(a5)
	move.l	A_Datas(a5),A_ADatas(a5)
	move.w	M_ForNext(a5),MM_ForNext(a5)
* Quelque chose � compiler???
	tst.w	NbInstr(a5)
	beq	ErrNothing

;--------------------------------------> Procedures
	move.l	B_Labels(a5),A_Proc(a5)
PChr1	move.l	A_Proc(a5),a0
	moveq	#-6,d0
PChr2	lea	6(a0,d0.w),a0
	move.w	(a0),d0
	beq	PChrX
	move.l	2(a0),d1
	bclr	#30,d1
	beq.s	PChr2
	move.l	d1,a6
	move.l	a4,2(a0)
* Adresse de la fin de la procedure
	bsr	GetLong
	subq.l	#4,a6
	lea	10-2(a6,d0.l),a0
	move.l	a0,F_Proc(a5)
* Stockage position actuelle
	move.w	CMvqd0(pc),d0
	bsr	OutWord
	moveq	#L_DProc1,d0
	bsr	CreFonc
	bsr	PrgIn
	moveq	#L_PrgIn,d0
	bsr	CreFonc
* Adresse des variables
	lea	10(a6),a6
	bsr	Sovar
	moveq	#0,d7
	moveq	#0,d6
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkBra1-Tk,d0
	bne.s	DPro6
	addq.l	#2,a6
DPro0	addq.l	#2,a6
	lsl.l	#1,d6
	addq.l	#1,d7
	movem.l	d6/d7,-(sp)
	bsr	VarAdr
	movem.l	(sp)+,d6/d7
	cmp.b	#1,d2
	bne.s	DPro1
	bset	#0,d6
DPro1	tst.w	d1
	bmi.s	DPro4
	beq.s	DPro2
; Variable GLOBALE
	move.w	CLea2a0a0(pc),d0
	bra.s	DPro3
; Variable LOCALE
DPro2	move.w	CLea2a6a0(pc),d0
DPro3	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	bra.s	DPro5
; Variable TABLEAU
DPro4	moveq	#L_GetTablo,d0
	bsr	CreFonc
DPro5	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
; Encore un param?
	bsr	GetWord
	cmp.w	#TkBra2-Tk,d0
	bne.s	DPro0
* Entete de la procedure
	move.w	Cmvqd4(pc),d0		* N params
	move.b	d7,d0
	bsr	OutWord
	move.w	Cmvid5(pc),d0		* Flags des params
	bsr	OutWord
	move.l	d6,d0
	bsr	OutLong
	moveq	#L_DProc2,d0		* Routine d'egalisation
	bsr	CreFonc
* Pas de melange des labels!
DPro6	addq.w	#1,N_Proc(a5)

* CHRGET!
	addq.l	#2,a6
ProChr	bsr	AffPour
	bsr	GetWord
	beq	Synt
;
ProChr0	move.l	B_Lea(a5),a0
	cmp.l	(a0),a6
	bcs.s	ProChr1
	bsr	PokeAd
	bra.s	ProChr0
;
ProChr1	bsr	GetWord
	beq.s	ProChr
	addq.w	#1,NbInstr(a5)
	lea	Tk(pc),a0
	move.w	0(a0,d0.w),d1
	bne.s	ProChr2
	bsr	IStandard
	bra.s	ProChr0
ProChr2	jsr	0(a0,d1.w)		* Une autre instruction
	bra.s	ProChr0
; Fin procedure
CEProc	addq.l	#4,sp
	bsr	GetWord			* Un parametre???
	subq.w	#2,a6
	cmp.w	#TkBra1-Tk,d0
	bne.s	CEpr2
	bsr	FnEval
	addq.l	#2,a6
	move.l	CdEProE(pc),d0
	and.b	#$0F,d2
	subq.b	#1,d2
	bmi.s	CEpr1
	move.l	CdEProF(pc),d0
	tst.b	d2
	beq.s	CEpr1
	move.l	CdEProS(pc),d0
CEpr1	bsr	OutLong
CEpr2	moveq	#L_FProc,d0
	bsr	CreJmp
	move.l	A_FlagVarL(a5),a0
	bsr	PrgOut
	bra	PChr1
PChrX

;-----> Variables globales
	move.l	AdAdAdress(a5),AdAdress(a5)
	move.l	B_FlagVarG(a5),a0
	move.l	A_ADatas(a5),A_Datas(a5)
	move.w	OFlag_Labels(a5),Flag_Labels(a5)
	move.w	OFlag_Procs(a5),Flag_Procs(a5)
	move.w	MM_ForNext(a5),M_ForNext(a5)
	clr.w	N_Proc(a5)
	bsr	PrgOut

;------------------------------------> COPIE LES ROUTINES LIBRAIRIE
	moveq	#23,d0
	bsr	MesPrint
	bsr	FActualise
	moveq	#36,d0
	move.l	#36*12,d1
	bsr	SetPour

	move.l	B_Bcles(a5),a6
CLib0	lea	BufLibs(a5),a2
	moveq	#-1,d6
CLib1	addq.l	#1,d6
	move.l	(a2)+,d0
	bne.s	CLib2
	cmp.w	#M_Libs-1,d6
	bne.s	CLib1
	tst.l	d6
	bmi.s	CLib0
	moveq 	#0,d0
        bsr 	OutRel
        bsr 	OutRel
	bra	CLibFin

; Une librairie chargee
CLib2	move.l	d0,a1
	tst.w	(a1)
	bne.s	CLib3
; Pas appel�e: met un RTS!
	move.l	a4,4(a1)
	move.w	CRts(pc),d0
	bsr	OutWord
	bra.s	CLib1
; Appell�e
CLib3	lea	4-10(a1),a1
	moveq	#-10,d5
CLib4	add.l	#10,d5
	lea	10(a1),a1
	move.l	(a1),d0
	beq.s	CLib4
	bmi.s	CLib1
	subq.l	#1,d0
	bne.s	CLib4
	movem.l	a1/a2,-(sp)
	bsr	GetRout
	movem.l	(sp)+,a1/a2
	bset	#31,d6
	bra.s	CLib4

******* Routine recursive de copie d'une routine
*	D6= 	# librairie
*	D5=	# routine
GetRout	movem.l	d5/d6,-(sp)

* Actions particulieres sur librairie principale...
	tst.w	d6
	bne.s	PaPrin
; Copie les routines FLOAT?
	cmp.w	#L_FlRout*10,d5
	bne.s	.PaFl
	btst	#0,Flag_Math(a5)
	bne.s	.PaFl
	move.w	#L_FoFloat*10,d5
.PaFl
; Copie des RUN et ERROR (.AMOS)
	cmp.w	#3,Flag_Type(a5)
	bne.s	PaPrin
	cmp.w	#L_Error*10,d5
	bne.s	PaPrin
	move.w	#L_ErrorAMOS*10,d5
PaPrin
; Pointe la librairie
	move.w	d6,d0
	lsl.w	#2,d0
	lea	BufLibs(a5),a2
	move.l	0(a2,d0.w),d0
	beq	DError
	move.l	d0,a2
	move.w	2(a2),d1
	move.w	d1,MaxCLibs(a5)
	addq.l	#4,a2
; Est-ce la routine d'erreur d'une extension???
	tst.w	d6		; Librairie extension?
	beq.s	.skip
	mulu	#10,d1
	move.w	d5,d0
	add.w	#20,d0
	cmp.w	d0,d1		; Avant derniere routine?
	bne.s	.skip
	tst.w	Flag_Errors(a5)	; Erreurs a charger?
	bne.s	.skip
	add.w	#10,d5		; PAS D'ERREURS!!!
.skip
; Continue
	move.w	d5,d0
	add.w	d0,a2
	move.l	(a2),d0
	cmp.l	#1,d0
	bhi	GRouX
; Charge la routine dans le buffer
	moveq	#24,d0
	bsr	MesPrint
	bsr	AffPour
	move.l	a4,(a2)		; Poke l'adresse de la routine
	move.l	a4,-(sp)
	move.w	#-1,(a6)+
** Init recopie routine
	move.l	4(a2),P_Clib(a5)
	moveq	#0,d0
	move.w	8(a2),d0
	lsl.l	#1,d0
	move.l	d0,T_Clib(a5)
	moveq	#0,d4		* P_CLIB-> D4
** Boucle de recopie, D3 octets
GRou0	bsr	LdClib
GRou1	move.b	(a2),d0
	cmp.b	#C_Code1,d0
	beq	GRou10
GRou2	move.w	(a2)+,d0
	bsr	OutWord
	addq.l	#2,d4
GRouR	cmp.l	d3,d4
	bcs.s	GRou1
	cmp.l	T_Clib(a5),d4
	bcs.s	GRou0
; Branche les routines demandees
GRou4	move.w	-(a6),d0
	bmi.s	GRou6
	move.w	d0,d5
	bsr	GetRout
	move.l	a4,d2
	move.l	-(a6),a4
	move.l	d0,d1
	sub.l	a4,d0
	cmp.l	#-32760,d0
	ble.s	GRou5
	cmp.l	#+32760,d0
	bge.s	GRou5
; Saut relatif OK!
	bsr	OutWord
	move.l	d2,a4
	bra.s	GRou4
; Saut en ARRIERE trop long: BRA-> JMP
GRou5	move.l	d2,d0		* 1-> BRA sur le JMP
	sub.l	a4,d0
	cmp.l	#-32760,d0
	ble	DError
	cmp.l	#+32760,d0
	bge	DError
	bsr	OutWord
	move.l	d2,a4		* 2-> JMP sur la routine
	move.w	CJmp(pc),d0
	bsr	OutWord
	bsr	RelJsr
	move.l	d1,d0
	bsr	OutLong
	bra.s	GRou4
; Ramene l'adresse de la routine
GRou6	move.l	(sp)+,d0
;-----> Fin copie routine
GRouX	movem.l	(sp)+,d5/d6
	rts

******* Charge la routine dans le buffer
LdClib	move.w	d6,d1
	addq.w	#F_Libs,d1
	move.l	d4,d2
	add.l	P_Clib(a5),d2
	moveq	#-1,d3
	bsr	FSeek
	move.w	d6,d1
	addq.w	#F_Libs,d1
	move.l	B_DiskIn(a5),d2
	move.l	T_Clib(a5),d3
	sub.l	d4,d3
	clr.l	-(sp)
	cmp.l	#L_DiscIn,d3
	bcs.s	Ldcl1
	move.l	#L_DiscIn,d3
	move.l	#8,(sp)
Ldcl1	bsr	FRead
	beq	DError
	move.l	d2,a2
	add.l	d4,d3
	sub.l	(sp)+,d3
	rts

;-----> Instruction speciale
GRou10	move.w	(a2),d0
	move.b	d0,d2
	and.b	#$0F,d0
	cmp.b	#C_Code2,d0
	bne	GRou2
	and.w	#$00F0,d2
	lsr.w	#1,d2
	lea	GRout(pc),a1
	jmp	0(a1,d2.w)
;-----> Table des sauts
GRout	bra.s	GRouJ			; 0 - RJmp
	jmp	$FFFFF0
	bra.s	GRouJ			; 1 - RJsr
	jsr	$FFFFF0
	bra	GRouB			; 2 - RBra
	bra	GRout
	bra	GRouB			; 3 - RBsr
	bsr	GRout
	bra	GRouB			; 4 - RBeq
	beq	GRout
	bra	GRouB			; 5 - RBne
	bne	GRout
	bra	GRouB			; 6 - RBcs
	bcs	GRout
	bra	GRouB			; 7 - RBcc
	bcc	GRout
	bra	GRouB			; 8 - RBlt
	blt	GRout
	bra	GRouB			; 9 - RBge
	bge	GRout
	bra	GRouB			; 10- RBls
	bls	GRout
	bra	GRouB			; 11- RBhi
	bhi	GRout
	bra	GRouB			; 12- RBle
	ble	GRout
	bra	GRouB			; 13- RBpl
	bpl	GRout
	bra	GRouB			; 14- RBmi
	bmi	GRout
	bra	GRouD			; 15- RData
;-----> RJMP / RJSR
GRouJ	cmp.b	#C_CodeJ,2(a2)
	bne	GRou2
	moveq	#0,d1
	move.b	3(a2),d1
	cmp.b	#27,d1
	bcc	GRou2
	move.w	4(a2),d0
; Poke l'appel
	move.w	2(a1,d2.w),d0
	bsr	OutWord
	bsr	RelJsr
	move.w	4(a2),d0
	mulu	#10,d0
	swap	d0
	lsl.w	#2,d1
	move.w	d1,d0
	swap	d0
	bset	#BitLib,d0
	bsr	OutLong
	addq.l	#6,a2
	addq.l	#6,d4
; Marque la librairie
	lea	BufLibs(a5),a0
	move.l	0(a0,d1.w),d2
	beq	DError
	move.l	d2,a0
	tst.l	4(a0,d0.w)
	bne	GRou1
	move.l	#1,4(a0,d0.w)
	bra	GRouR
;-----> RBRA etc..
GRouB	move.w	2(a2),d1
	cmp.w	MaxClibs(a5),d1
	bcc	GRou2
	mulu	#10,d1
	move.w	4(a1,d2.w),d0
	bsr	OutWord
	move.l	a4,(a6)+
	move.w	d1,(a6)+
	addq.l	#4,a2
	addq.l	#4,d4
	addq.l	#2,a4
	bra	GRouR
;-----> Instruction RDATA
GRouD	cmp.w	#C_CodeD,2(a2)
	bne	GRou2
	addq.l	#4,a2
	addq.l	#4,d4
	move.w	CNop(pc),d0
	bsr	OutWord
	bsr	OutWord
GRouD1	cmp.l	d3,d4
	bcc	GRouD2
	move.w	(a2)+,d0
	bsr	OutWord
	addq.l	#2,d4
	bra.s	GRouD1
GRouD2	cmp.l	T_Clib(a5),d4
	bcc	GRou4
	bsr	LdClib
	bra.s	GRouD1
CLibFin
;	lea	Protect(pc),a0
;	bsr	OutCode
	bsr	Return

;-----> Copie les constantes alphanumeriques
	move.l	B_Chaines(a5),a1
	bra.s	c_ch5
c_ch1	move.l	d0,a6
	move.l	a4,(a1)
	bsr	GetWord
	move.w	d0,d1
	bsr	OutWord
	addq.w	#1,d1
	lsr.w	#1,d1
	subq.w	#1,d1
	bmi.s	c_ch4
c_ch3	bsr	GetWord
	bsr	OutWord
	dbra	d1,c_ch3
c_ch4	addq.l	#4,a1
c_ch5	move.l	(a1),d0
	bne.s	c_ch1
; Securite un mot long
	moveq	#0,d0
	bsr	OutLong

;-----> Fin du hunk programme
	moveq	#NH_Prog,d1
	bsr	FinHunk
	bsr	FActualise

******* HUNK 2: Table de relocation
	moveq	#NH_Reloc,d1
	moveq	#Hunk_Public,d2		* En PUBLIC Mem
	bsr	DebHunk
	move.l	a4,AA_Reloc(a5)
; Copie
	move.l	B_Reloc(a5),a1
CRel1	move.b	(a1)+,d0
	bsr	OutByte
	tst.b	d0
	bne.s	CRel1
	sub.l	B_Reloc(a5),a1
	move.w	a1,L_Reloc(a5)
; Fin du hunk reloc
	moveq	#NH_Reloc,d1
	bsr	FinHunk
	moveq	#93,d0
	bsr	GoPos

******* Copie du systeme?
	cmp.w	#3,Flag_Type(a5)
	bne	CSystem
* AMOS: Copie la fin de la procedure
	moveq	#0,d0
	bsr	OutWord
	move.l	a4,AA_EProc(a5)
	move.w	#$0301,d0
	bsr	OutWord
	move.w	#TkEndP-Tk,d0
	bsr	OutWord
	clr.w	d0
	bsr	OutWord
	moveq	#108,d0
	bsr	GoPos
	bra	NoSystem

******* HUNK 2: W.Lib
CSystem	moveq	#25,d0
	bsr	MesPrint
	moveq	#NH_W.Lib,d1
	moveq	#Hunk_Public,d2		* PUBLIC mem
	moveq	#$20,d3			* Pas d'entete
	moveq	#4,d4
	moveq	#4-1,d0
	bsr	GetNom
	move.l	a0,a1
	bsr	CopyHunk
	moveq	#96,d0
	bsr	GoPos

******* HUNK 4: .Env
	moveq	#NH_Env,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	moveq	#0,d0			* Mot vide!!!
	bsr	OutLong
	moveq	#1,d0
	bsr	GetNom
	move.l	a0,a1
	moveq	#F_Courant,d1
	bsr	FOpenOld
	beq	DError
	moveq	#F_Courant,d1
	bsr	FLof
	move.l	d0,d6
	moveq	#F_Courant,d1
	move.l	B_Work(a5),d2		* Longueur DATAZONE
	moveq	#$24,d3
	bsr	FRead
	beq	DError
	move.l	d2,a0
	move.l	$20(a0),d0
	bsr	OutLong
	sub.l	#$24,d6
	move.l	d6,d0			* Longueur donnees
	bsr	OutLong
	moveq	#F_Courant,d1
	move.l	d6,d3			* Charge
	bsr	OutFRead
	moveq	#F_Courant,d1
	bsr	FClose
	moveq	#NH_Env,d1
	bsr	FinHunk
	moveq	#99,d0
	bsr	GoPos

******* HUNK 5: Mouse.Abk
	moveq	#NH_Mouse,d1
	move.l	#Hunk_Chip,d2		* CHIP mem
	bsr	DebHunk
	move.l	a4,-(sp)
	lea	16*2(a4),a4		* Place pour la palette
	moveq	#9-1,d0
	bsr	GetNom
	move.l	a0,a1
	moveq	#F_Courant,d1
	bsr	FOpenOld
	beq	DError
	moveq	#F_Courant,d1
	moveq	#6,d2
	moveq	#-1,d3
	bsr	FSeek
	moveq	#F_Courant,d1
	bsr	FLof
	moveq	#F_Courant,d1
	move.l	d0,d3			* Tout sauf la palette
	sub.l	#32*2+6,d3
	bsr	OutFRead
	moveq	#-1,d0			* Marque la fin
	bsr	OutWord
	moveq	#F_Courant,d1
	moveq	#16*2,d2		* Saute 1ere moitie palette
	moveq	#0,d3
	bsr	FSeek
	move.l	(sp)+,d0
	move.l	a4,-(sp)
	move.l	d0,a4
	moveq	#16*2,d3
	moveq	#F_Courant,d1
	bsr	OutFRead
	moveq	#F_Courant,d1
	bsr	FClose
	move.l	(sp)+,a4
	moveq	#NH_Mouse,d1
	bsr	FinHunk
	moveq	#102,d0
	bsr	GoPos

******* HUNK 6: Default.Font
	moveq	#NH_Font,d1			* Numero 5
	moveq	#Hunk_Public,d2		* PUBLIC mem
	moveq	#0,d3
	moveq	#0,d4
	moveq	#10-1,d0
	bsr	GetNom
	move.l	a0,a1
	bsr	CopyHunk
	moveq	#105,d0
	bsr	GoPos

******* HUNK 7: Default.Key
	moveq	#NH_Key,d1			* Numero 6
	moveq	#Hunk_Public,d2		* PUBLIC mem
	moveq	#0,d3
	moveq	#0,d4
	moveq	#11-1,d0
	bsr	GetNom
	move.l	a0,a1
	bsr	CopyHunk
	moveq	#108,d0
	bsr	GoPos
NoSystem:

******* HUNK 8 - 25 : Banques
	moveq	#26,d0
	bsr	MesPrint
	moveq	#16,d0
	moveq	#16,d1
	bsr	SetPour
	move.l	A_Banks(a5),a6
	cmp.w	#3,Flag_Type(a5)
	beq	BankAMOS

* Copie les banques NORMALE
	addq.l	#4,a6
	bsr	GetWord
	move.w	d0,d6
	beq	P1Finie
	moveq	#N_HunkSys,d5
BkLoop	bsr	AffPour
	bsr	GetLong
	cmp.l	#"AmSp",d0
	beq.s	BklS
	cmp.l	#"AmIc",d0
	beq.s	BklI
* Banque normale
	bsr	GetWord			* Numero banque
	move.w	d0,-(sp)
	bsr	GetWord
	moveq	#Hunk_Public,d2
	move.w	d0,-(sp)
	bne.s	Bkl1
	move.l	#Hunk_Chip,d2
Bkl1	move.l	d5,d1
	bsr	DebHunk
	move.l	a4,d7
	bsr	GetLong
	move.l	d0,d3		0-> Longueur reelle
	and.l	#$FFFFFFF,d3	avec flags: 31-> DATA, 30-> CHIP
	tst.w	(sp)+
	bne.s	Bkl1a
	bset	#30,d0
Bkl1a	bsr	OutLong
	move.w	(sp)+,d0	4-> Numero
	bsr	OutWord
	clr.w	d0		6-> 0
	bsr	OutWord
	bsr	CopySrce
	bra	BklEnd
* Banque de sprites/Icones
BklS	pea	Nom_Spr(pc)
	move.w	#-1,-(sp)
	bra.s	Bkl2
BklI	pea	Nom_Ico(pc)
	move.w	#-2,-(sp)
Bkl2	move.l	d5,d1
	move.l	#Hunk_Chip,d2
	bsr	DebHunk
	move.l	a4,d7
	bsr	GetWord		0-> Nombre sprite/icones
	ext.l	d0
	bsr	OutLong
	move.w	d0,d4
	move.w	(sp)+,d0	4-> -1 sprites / -2 icones
	bsr	OutWord
	clr.w	d0		6-> 0
	bsr	OutWord
* Place pour la table d'entete
	move.l	(sp)+,a1
	move.l	(a1)+,d0
	bsr	OutLong
	move.l	(a1)+,d0
	bsr	OutLong
	move.l	a4,a3
	move.w	d4,d0
	lsl.w	#3,d0
	lea	2+64+6(a4,d0.w),a4
	move.w	d4,d2
	subq.w	#1,d2
	bmi.s	Bkl4
	move.l	B_Lea(a5),a2
* Copie les bobs
Bkl3	move.l	a4,d7
	bsr	GetWord		TX
	move.w	d0,d3
	bsr	OutWord
	bsr	GetWord		TY
	mulu	d0,d3
	bsr	OutWord
	bsr	GetWord		NPlan
	mulu	d0,d3
	bsr	OutWord
	bsr	GetLong
	bsr	OutLong
	lsl.l	#1,d3
	beq.s	Bkl3a
	bsr	CopySrce
	bra.s	Bkl3c
Bkl3a	lea	-10(a4),a4
Bkl3c	bsr	Mult8
	move.l	a4,d0
	sub.l	d7,d0
	move.l	d0,(a2)+
	dbra	d2,Bkl3
* Refait l'entete
Bkl4	exg	a4,a3
	move.w	d4,d0
	bsr	OutWord
	subq.w	#1,d4
	bmi.s	Bkl4b
	move.l	B_Lea(a5),a2
Bkl4a	move.l	(a2)+,d0
	bsr	OutLong
	moveq	#0,d0
	bsr	OutLong
	dbra	d4,Bkl4a
Bkl4b	moveq	#64,d3
	bsr	CopySrce
	exg	a4,a3
	move.l	a4,d7
* Fin de la banque
BklEnd	bsr	Mult8
	move.l	d5,d1
	bsr	FinHunk
	addq.w	#1,d5
	subq.w	#1,d6
	bne	BkLoop
	bra	P1Finie

******* Copie les banques / AMOS
BankAMOS
	move.l	L_Source(a5),d3		FACILE!
	sub.l	a6,d3
	bsr	CopySrce

******* Fin de la passe 1
P1Finie	bsr	FActualise
	move.l	a4,L_Objet(a5)
	rts

* ROUTINE: rend multiple de 8
Mult8	move.l	a4,d0
	sub.l	d7,d0
	and.l	#7,d0
	beq.s	Mu8.2
	moveq	#8,d1
	sub.l	d0,d1
	beq.s	Mu8.2
	lsr.w	#1,d1
Mu8.1	moveq	#0,d0
	bsr	OutWord
	subq.w	#1,d1
	bne.s	Mu8.1
Mu8.2	rts

* ROUTINE: Entree programme/procedure
PrgIn	move.l	a4,AdAdress(a5)
	move.w	Cleaa0(pc),d0
	bsr	OutWord
	bsr	RelJsr
	addq.l	#4,a4
	move.w	Cleaa1(pc),d0
	bsr	OutWord
	bsr	RelJsr
	addq.l	#4,a4
	move.w	Cleaa2(pc),d0
	bsr	OutWord
	bsr	RelJsr
	addq.l	#4,a4
	move.l	A_FlagVarL(a5),a0
	clr.w	(a0)
	clr.l	A_Datas(a5)
	clr.w	Flag_Labels(a5)
	clr.w	Flag_Procs(a5)
	clr.w	M_ForNext(a5)
	rts
* ROUTINE -> Sortie programme/procedures
* A0-> Buffer a copier
PrgOut	move.l	a4,-(sp)
	move.l	a0,-(sp)
	tst.w	Flag_Labels(a5)
	beq.s	PaClb
	move.w	N_Proc(a5),d7
	move.l	B_Labels(a5),a2
	move.w	(a2),d2
	beq.s	ClbX
Clb1	cmp.w	-2+6(a2,d2.w),d7
	beq.s	Clb0
	tst.w	Flag_Procs(a5)		* Pour le moment PROC a$, interdit!
	beq.s	Clb3
	tst.w	-2+6(a2,d2.w)
	bpl.s	Clb3
Clb0	move.w	d2,d0
	bsr	OutWord
	bsr	RelJsr
	move.l	2(a2),d0
	bsr	OutLong
	lea	6(a2),a1
	move.w	d2,d1
	lsr.w	#1,d1
	subq.w	#1,d1
Clb2	move.w	(a1)+,d0
	bsr	OutWord
	dbra	d1,Clb2
Clb3	lea	6(a2,d2.w),a2
	move.w	(a2),d2
	bne.s	Clb1
ClbX	moveq	#0,d0
	bsr	OutWord
	clr.w	Flag_Labels(a5)
* Copie la table des flags variable
PaClb	move.l	(sp),a1
	move.l	a4,(sp)
	move.w	M_ForNext(a5),d0
	bsr	OutWord
	move.w	(a1)+,d0
	moveq	#0,d1
	move.w	d0,d1
	neg.w	d0
	bsr	OutWord
	divu	#6,d1
	subq.w	#1,d1
	bmi.s	CFg2
CFg1	move.b	(a1)+,d0
	bsr	OutByte
	dbra	d1,CFg1
CFg2	moveq	#-1,d0
	bsr	OutByte
	bsr	A4Pair
* Change les adresses au debut de la procedure
	move.l	a4,-(sp)
	move.l	AdAdress(a5),a4
	addq.l	#2,a4
	move.l	8(sp),d0
	bsr	OutLong
	addq.l	#2,a4
	move.l	4(sp),d0
	bsr	OutLong
	addq.l	#2,a4
	move.l	A_Datas(a5),d0
	bne.s	CFg3
	move.l	A_EDatas(a5),d0
CFg3	bsr	OutLong
	move.l	(sp)+,a4
	addq.l	#8,sp
	rts

*********************************************************************
*	Fabrique le header...
Header	cmp.w	#3,Flag_Type(a5)
	beq	HeaderAMOS

******* Programme NORMAL
* Fabrique le HUNK entete
	move.l	#$3F3,d0		* AmigaDos
	bsr	OutLong
	moveq	#0,d0			* Pas de nom
	bsr	OutLong
	move.w	N_Banks(a5),d1
	ext.l	d1
	addq.w	#N_HunkSys,d1
	move.l	d1,d0
	bsr	OutLong
	moveq	#0,d0			* Debut=0
	bsr	OutLong
	move.l	d1,d0
	subq.l	#1,d0
	bsr	OutLong
	lsl.w	#2,d1			* Saute les tailles
	lea	0(a4,d1.w),a4
* Fabrique le hunk header
	moveq	#NH_Header,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	moveq	#5-1,d0
	cmp.w	#2,Flag_Type(a5)
	bne.s	.Skip
	moveq	#6-1,d0
.Skip	bsr	GetNom
	move.l	a0,a1
	moveq	#F_Courant,d1
	bsr	FOpenOld
	beq	DError
	moveq	#F_Courant,d1
	move.l	B_Work(a5),d2
	moveq	#$20+2+4,d3
	bsr	FRead
	beq	DError
	move.l	d2,a1
; Envoie le BRA
	move.w	$22(a1),d0
	bsr	Outword
; Envoie les FLAGS
	moveq	#0,d0
	move.w	Flag_Flash(a5),d0	Couleur a flasher
	lsl.w	#8,d0
	tst.w	Flag_WB(a5)		Workbench???
	bne.s	.Skip1
	bset	#0,d0
.Skip1	bsr	OutWord
; Envoie le reste
	moveq	#0,d3
	move.w	$20(a1),d3
	sub.w	#4,d3
	moveq	#F_Courant,d1
	bsr	OutFRead
	moveq	#F_Courant,d1
	bsr	FClose
	moveq	#NH_Header,d1
	bsr	FinHunk
	rts

******* Programme AMOS
HeaderAMOS
	moveq	#7-1,d0
	bsr	GetNom
	move.l	a0,a1
	bsr	LoadInBuffer
	move.l	d5,a1
* Recopie le header AMOS Basic
	moveq	#3,d1
.loop0	move.l	(a1)+,d0
	bsr	OutLong
	dbra	d1,.loop0
	move.l	a4,AA_Long(a5)
* Recopie en cherchant le SET BUFFER
.loop1	move.w	(a1)+,d0
	bsr	OutWord
	cmp.w	#TkSBu-Tk,d0
	bne.s	.loop1
	move.l	a4,AA_SBuf(a5)
* Cherche maintenant le PROCEDURE
.loop2	move.w	(a1)+,d0
	bsr	OutWord
	cmp.w	#TkProc-Tk,d0
	bne.s	.loop2
	move.l	a4,AA_Proc(a5)
	move.l	(a1)+,d0
	bsr	OutLong
	move.l	(a1)+,d0
	or.w	#%0101000000000000,d0
	bsr	OutLong
* Cherche maintenant le CMPCALL
.loop3	move.w	(a1)+,d0
	bsr	OutWord
	cmp.w	#TkExt-Tk,d0
	bne.s	.loop3
	cmp.w	#Ext_Nb*256,(a1)
	bne.s	.loop3
	cmp.w	#Ext_TkCmp,2(a1)
	bne.s	.loop3
	move.l	(a1)+,d0
	bsr	OutLong
* Sort des zeros
	move.l	a4,A_InitMath(a5)
	moveq	#0,d0
	bsr	OutWord
	bsr	OutLong
	bsr	OutLong
* Efface le programme
	bsr 	EraInBuffer
* Debut du programme proprement dit!
	rts

***********************************************************************
*	Fabrique les routines d'init
CreeInits
	cmp.w	#3,Flag_Type(a5)
	beq	InitAMOS

******* Programme normal
	move.l	a4,A_InitMath(a5)
	move.w	CMvqd0(pc),d0		* Flags
	bsr	OutWord
	move.w	CMvid1(pc),d0		* Taille du buffer
	bsr	OutWord
	moveq	#0,d0
	bsr	OutLong
	moveq	#L_Init1,d0
	bsr	CreFonc
	lea	BufLibs+4(a5),a1
	moveq	#1,d1
IInit0	move.l	(a1)+,d0
	beq.s	IInit1
	move.l	d0,a0
	move.w	(a0),-(sp)
	movem.l	d1/a0/a1,-(sp)
	moveq	#0,d0
	bsr	CreFoncExt
	movem.l	(sp)+,d1/a0/a1
	move.w	(sp)+,(a0)
IInit1	addq.w	#1,d1
	cmp.w	#26,d1
	bls.s	IInit0
	moveq	#L_Init2,d0
	bsr	CreFonc
	rts

******* Programme .AMOS
InitAMOS
	move.w	#L_AMOSIn,d0
	bsr	CreFonc
	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; PASSE 2-> Relocation
;---------------------------------------------------------------------
Passe2
	cmp.w	#3,Flag_Type(a5)
	beq	P2AMOS

******* Copie toutes les longueurs de HUNKS dans l'entete
	sub.l	a4,a4
	lea	20(a4),a4
	moveq	#N_HunkSys-1,d4
	add.w	N_Banks(a5),d4
	lea	T_Hunks(a5),a1
CLhu1	move.l	4(a1),d0
	bsr	OutLong
	addq.l	#8,a1
	dbra	d4,CLhu1

******* Longueur du hunk programme
	moveq	#NH_Header,d1
	bsr	MarkHunk
	moveq	#NH_Prog,d1
	bsr	MarkHunk

******* Flags ouverture...
	move.l	A_InitMath(a5),a4
	move.w	CMvqd0(pc),d0
	move.b	Flag_Math(a5),d0
	tst.w	Flag_Default(a5)
	beq.s	.Label
	bset	#2,d0
.Label	bsr	OutWord
	addq.l	#2,a4
	move.l	L_Buf(a5),d0
	mulu	#1024,d0
	add.l	#512,d0
	bsr	OutLong
	bra	P2Reloc

******* Programme .AMOS, fabrique l'entete
P2AMOS	move.l	AA_Long(a5),a4		* Longueur du source
	move.l	AA_EProc(a5),d0
	add.l	#6-4,d0
	sub.l	a4,d0
	bsr	OutLong
	move.l	AA_SBuf(a5),a4		* Instruction Set Buffer
	addq.l	#2,a4
	move.l	L_Buf(a5),d0
*	add.l	#512,d0
	bsr	OutLong
	move.l	AA_Proc(a5),a4
	move.l	AA_EProc(a5),d0
	sub.l	a4,d0
	subq.l	#4,d0
	bsr	OutLong
	move.l	A_InitMath(a5),a4	* Flags maths
	moveq	#0,d0
	move.b	Flag_Math(a5),d0
	bsr	OutWord
	move.l	AA_Reloc(a5),d0		* Pointeur sur relocation
	sub.l	a4,d0
	bsr	OutLong

******* Reloge le programme
P2Reloc
	moveq	#10,d0
	moveq	#0,d1
	move.w	L_Reloc(a5),d1
	bsr	SetPour

	move.l 	DebRel(a5),d7         	;Base de toute les adresses
        move.l 	d7,a4            	;Debut de l'exploration
        move.l 	B_Reloc(a5),a6        	;Table de relocation
P2a:    bsr	AffPour
	move.b 	(a6)+,d0
        beq.s 	P2Fin
        cmp.b 	#1,d0
        bne.s 	P2b
        lea	508(a4),a4
        bra.s 	P2a
; Affyche la position
P2b:    and.w	#$FF,d0
	lsl.w	#1,d0
        add.w 	d0,a4
        bsr 	GtoLong
        subq.l 	#4,a4
	bclr	#BitLib,d0
	bne.s	P2L
	bclr	#BitChaine,d0
	bne.s	P2S
	bclr	#BitLabel,d0
	bne.s	P2G
; Simple JSR
	sub.l	d7,d0
	bsr	OutLong
	subq.l	#4,a4
	bra.s	P2a
; Trouve l'adresse d'une routine librairie
P2L	move.w	d0,d1
	swap	d0
	lea	BufLibs(a5),a0
	move.l	0(a0,d0.w),a0
        move.l 	4(a0,d1.w),d0    	;Adresse absolue de la routine
        sub.l 	d7,d0
        bsr 	OutLong
        subq.l 	#4,a4
        bra.s 	P2a
; Trouve l'adresse d'une chaine
P2S	move.l	d0,a1
	move.l	(a1),d0
	sub.l	d7,d0
	bsr	OutLong
	subq.l	#4,a4
	bra.s	P2a
; Adresse d'un label
P2G	move.l	d0,a1
	move.l	2(a1),d0
	bmi	ErrLabel
	sub.l	d7,d0
	bsr	OutLong
	subq.l	#4,a4
	bra.s	P2a
P2Fin

******* Marque les longueurs des HUNKS
	cmp.w	#3,Flag_Type(a5)
	beq.s	P2Finie
	moveq	#NH_Reloc,d2
	move.w	N_Banks(a5),d3
	add.w	#N_HunkSys-3,d3
P2hu	move.w	d2,d1
	bsr	MarkHunk
	addq.w	#1,d2
	dbra	d3,P2Hu

******* Fin passe 2
P2Finie	bsr	FActualise
	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Gestion des librairies / Relocation
;---------------------------------------------------------------------

******* Charge la LIB LIST et les datas. Fabrique la liste des noms.
InitListe
; Trouve le nom des datas
	moveq	#2,d3			PAL
	move.l	C_GfxBase(a5),a0
	move.w	212(a0),d0
	cmp.w	#300,d0
	bcc.s	.skip
	moveq	#3,d3			NTSC
.skip	tst.w	Flag_Errors(a5)
	bne.s	.Init0
	moveq	#4,d3			NO ERRORS
.Init0	move.w	d3,d7
	bsr	ListeNom
	move.l	B_DiskIn(a5),a3
	lea	128(a3),a3
	move.l	a3,d3
	moveq	#-1,d2
	bsr	CopyNom
* Charge les datas
	move.l	d3,d1
	move.l	C_DosBase(a5),a6
	jsr	DosLoadSeg(a6)
	tst.l	d0
	beq	DError
	move.l	d0,d4
	lsl.l	#2,d0
	addq.l	#8,d0
	move.l	d0,a4
* Estimation de la taille
	moveq	#0,d2
	move.w	d7,d3
	bsr	InitNoms
* Reserve le buffer, recommence!
	move.l	d2,d0
	addq.l	#8,d0
	bsr	ResBuffer
	move.l	a0,a3
	move.l	a0,B_Noms(a5)
	moveq	#-1,d2
	move.w	d7,d3
	bsr	InitNoms
* Reserve le buffer des pointeurs
	move.l	d3,d0
	lsl.w	#1,d0
	addq.w	#8,d0
	bsr	ResBuffer
	move.l	a0,B_Pointeurs(a5)
	move.l	B_Noms(a5),a1
	subq.w	#1,d3
.Init1	move.l	a1,d1
.Init2	tst.b	(a1)+
	bne.s	.Init2
	sub.l	a1,d1
	neg.l	d1
	move.w	d1,(a0)+
	dbra	d3,.Init1
* Enleve le .Env
	move.l	C_DosBase(a5),a6
	move.l	d4,d1
	jsr	DosULoadSeg(a6)
* Enleve le buffer et revient.
	bsr	EraInBuffer
	rts

** Charge le fichier dans un buffer...
LoadInBuffer
	moveq	#F_Courant,d1
	bsr	FOpenOld
	beq	DError
	moveq	#F_Courant,d1
	bsr	FLof
	move.l	d0,d6
	bsr	RamFast
	move.l	d0,d5
	beq	OOfMem
	move.l	d5,InBuf(a5)
	move.l	d6,InBufs(a5)
	moveq	#F_Courant,d1
	move.l	d5,d2
	move.l	d6,d3
	bsr	FRead
	beq	DError
	moveq	#F_Courant,d1
	bsr	FClose
	rts
** Enleve le buffer
EraInBuffer
	move.l	InBuf(a5),d0
	beq.s	EraIb
	clr.l	InBuf(a5)
	move.l	d0,a1
	move.l	InBufs(a5),d0
	bsr	RamFree
EraIb	rts

** Trouve les noms des librairies principales
InitNoms
* .Env
	bsr	ListeNom
	bsr	CopyNom
* Librairies principales
	moveq	#5,d3
.Init1	bsr	ListeNom
	bsr	CopyNom
	addq.w	#1,d3
	cmp.w	#11,d3
	bcs.s	.Init1
* Trouve les noms des fichiers par defaut
	bsr	ListeNom
	move.w	#ANMouse,d0
	bsr	GetA1
	bsr	EnvOuListe
	moveq	#12,d3
	bsr	ListeNom
	move.w	#ANFonte,d0
	bsr	GetA1
	bsr	EnvOuListe
	moveq	#13,d3
	bsr	ListeNom
	move.w	#AKyNom,d0
	bsr	GetA1
	bsr	EnvOuListe
* Trouve les noms des extensions
	moveq	#14,d3
	move.w	#AExtNames,d0
	bsr	GetA1
	move.l	a1,a2
.Init2	bsr	ListeNom
	move.l	a2,a1
	bsr	EnvOuListe
.Init3	tst.b	(a2)+
	bne.s	.Init3
	addq.w	#1,d3
	cmp.w	#14+26,d3
	bcs.s	.Init2
* Trouve les messages du compilateur
	moveq	#Mes_Base,d3
.Init4	bsr	ListeNom
	bne.s	.Init5
	bsr	Copy
	addq.w	#1,d3
	bra.s	.Init4
.Init5	move.w	d3,d0
	rts
** Routine: trouve le nom #D3 dans la liste
ListeNom
	move.l	d5,a0
	bsr.s	.Liste
	bne.s	.ListeE
	move.w	d3,d0
	subq.w	#2,d0
	bmi.s	.List1
.List0	bsr.s	.Liste
	bne.s	.ListeE
	dbra	d0,.List0
.List1	move.l	B_DiskIn(a5),a1
.List2	move.b	(a0)+,(a1)
	beq.s	.ListeE
	cmp.b	#"}",(a1)+
	bne.s	.List2
	clr.b	-1(a1)
	move.l	B_DiskIn(a5),a0
	moveq	#0,d0
	rts
.Liste	tst.b	(a0)
	beq.s	.ListeE
	cmp.b	#"{",(a0)+
	bne.s	.Liste
	rts
.ListeE	moveq	#-1,d0
	rts
** Routine: adresse string dans les datas
GetA1	sub.w	-2(a4),d0
	move.l	a4,a1
	sub.l	-4(a4),a1
	add.w	0(a4,d0.w),a1
	rts
** Routine: copie ou nom dans la liste
EnvOuListe
	exg	a0,a1
	tst.b	(a1)
	beq.s	CopyNom
	move.l	a1,a0
	cmp.w	#$2E00,(a0)
	bne.s	CopyNom
	clr.b	(a0)
** Routine: copie dans les noms, inclus le NOM_PATH, si defini!
CopyNom	tst.b	(a0)
	beq.s	Copy
	tst.b	Nom_From(a5)
	beq.s	Copy
	move.l	a0,a1
.Copy1	tst.b	(a1)+
	bne.s	.Copy1
.Copy2	move.b	-(a1),d0
	cmp.l	a0,a1
	bcs.s	.Copy3
	cmp.b	#"/",d0
	beq.s	.Copy3
	cmp.b	#":",d0
	bne.s	.Copy2
.Copy3	lea	Nom_From(a5),a0
	bsr	Copy
	subq.l	#1,a3
	lea	1(a1),a0
* Routine de copie / comptage
Copy	tst.l	d2
	bmi.s	List4
; Compte la taille
List3	addq.l	#1,d2
	tst.b	(a0)+
	bne.s	List3
	rts
; Recopie
List4	move.b	(a0)+,(a3)+
	bne.s	List4
	rts

******* Trouve le nom #D0 dans la liste-> A0
GetNom	tst.l	B_Noms(a5)
	beq.s	.Nom2
	move.l	d1,-(sp)
	move.l	B_Pointeurs(a5),a0
	moveq	#0,d1
	subq.w	#2,d0
	bmi.s	.Nom1
.Nom0	add.w	(a0)+,d1
	dbra	d0,.Nom0
.Nom1	moveq	#0,d0
	move.w	(a0),d0
	subq.w	#1,d0
	move.l	B_Noms(a5),a0
	lea	0(a0,d1.w),a0
	move.l	(sp)+,d1
	tst.b	(a0)
	rts
* Si noms pas charg�s: messages d'urgence!
.Nom2	lea	Mes_OOfMem(pc),a0
	cmp.w	#Mes_BaseNoms+6,d0
	beq.s	.Nom3
	lea	Mes_DError(pc),a0
.Nom3	move.l	a0,d0
.Nom4	tst.b	(a0)+
	bne.s	.Nom4
	sub.l	d0,a0
	exg	d0,a0
	rts
******* Trouve le chiffre #D dans la liste -> D0
GetChiffre
 	add.w	#Mes_BaseCh,d0
	bsr	GetNom
	moveq	#0,d0
 	moveq	#0,d2
ddh1:  	move.b 	(a0)+,d2
        beq.s 	ddh2
        cmp.b 	#32,d2
        beq.s 	ddh1
	sub.b 	#48,d2
	cmp.b	#10,d2
        bcc	ErrConfig
        move 	d0,d1
        mulu 	#10,d1
        swap 	d0
        mulu 	#10,d0
        swap 	d0
        tst 	d0
        bne	ErrConfig
        add.l 	d1,d0
        bcs 	ErrConfig
        add.l 	d2,d0
        bmi 	ErrConfig
        addq 	#1,d3
        bra.s 	ddh1
ddh2: 	rts				;OK: chiffre en d0, et beq

******* Initialisation de toutes les librairies
InitLibs
	moveq	#21,d0
	bsr	MesPrint
* Charge AMOS.Lib
	moveq	#3-1,d0
	moveq	#0,d1
	bsr	GetNom
	bsr	InitLib
* Charge les librairies!
	moveq	#12-1,d0
	moveq	#1,d1
Ilib5	movem.l	d0/d1,-(sp)
	bsr	GetNom
	movem.l	(sp)+,d0/d1
	beq.s	Ilib6
	bsr	InitLib
Ilib6	addq.w	#1,d0
	addq.w	#1,d1
	cmp.w	#27,d1
	bcs.s	ILib5
	rts
******* Initialisation librairie D1, nom A0
InitLib	movem.l	a0-a6/d0-d7,-(sp)
	move.l	a0,a1
	move.w	d1,d0
	lsl.w	#2,d0
	lea	BufLibs(a5),a2
	lea	BufToks(a5),a3
	add.w	d0,a2			* A2-> Pointeur librairie
	add.w	d0,a3			* A3-> Pointeurs tokens/erreurs
	addq.l	#F_Libs,d1
	move.l	d1,d6
	bsr	FOpenOld
	beq	DError
	move.l	d6,d1
	move.l	B_DiskIn(a5),d2
	moveq	#$20+$12,d3
	bsr	FRead
	beq	DError
	move.l	d2,a0
* Charge le catalogue
	move.l	$20(a0),d3		* Longueur du catalogue
	move.l	d6,d1
	add.l	#$32,d2
	bsr	FRead
	beq	DError
	move.l	d2,a1
; Reserve le buffer
	lsr.w	#1,d3
	move.w	d3,d0
	mulu	#10,d0
	add.l	#16,d0
	bsr	ResBuffer
	move.l	a0,(a2)
; Calcule les offsets des routines
	move.l	B_DiskIn(a5),a2
	move.w	$20+$10(a2),(a0)+	* Compteur / Signal
	move.w	d3,(a0)+		* Nombre d'instructions
	moveq	#$20+$12,d1
	add.l	$20(a2),d1
	add.l	$24(a2),d1
	subq.w	#1,d3
ILib1	clr.l	(a0)+
	move.l	d1,d0
	move.l	d0,(a0)+
	moveq	#0,d2
	move.w	(a1)+,d2
	move.w	d2,(a0)+
	lsl.l	#1,d2
	add.l	d2,d1
	dbra	d3,ILib1
	move.l	#-1,(a0)+
* Charge la table des tokens?
	move.l	B_DiskIn(a5),a2
	move.l	$20+4(a2),d3
	beq.s	ILib0
	move.l	d3,d0
	bsr	ResBuffer
	move.l	a0,(a3)
	move.l	a0,d2
	move.l	d6,d1
	bsr	FRead
	beq	DError
* Ca y est!
ILib0	bsr	Actualise
	movem.l	(sp)+,a0-a6/d0-d7
	rts

******* Relocation

;-----> Init relocation
InitRel	moveq	#4,d0
	bsr	GetChiffre
	bsr	ResBuffer
	move.l	a0,B_Reloc(a5)
	move.l	a0,a3
	rts
;-----> Cree un appel a la routine #D0
CreJmp: mulu	#10,d0
        move.l 	d0,a0
        move.w 	#CiJmp,d0
        bra.s 	CreF
;-----> Cree un appel a un sous programme #D0
CreFonc:mulu	#10,d0
        move.l 	d0,a0
        move.w 	#CiJsr,d0           ;Dans le source: JSR
CreF:   bsr 	OutWord
        bsr 	RelJsr              ;Pointe la table de relocation ici
	move.l	a0,d0
	bset	#BitLib,d0
        bsr 	OutLong             ;#ROUTINE.L
; Met le flag dans buffer
        move.l	BufLibs(a5),a0
	move.w	#1,(a0)
        move.l 	#1,4(a0,d0.w)
        rts
;-----> Cree un appel a un sous programme #D0, librairie #D1
;	Incrementer flag: D2=0 / D2=1
CreFoncExt
	mulu	#10,d0
        move.l 	d0,a0
        move.w 	#CiJsr,d0           ;Dans le source: JSR
	bsr 	OutWord
        bsr 	RelJsr              ;Pointe la table de relocation ici
	lsl.w	#2,d1
	move.w	d1,d0
	swap	d0
	move.w	a0,d0
	bset	#BitLib,d0
        bsr 	OutLong             ;#ROUTINE.L
; Met le flag dans buffer
	lea	BufLibs(a5),a0
	move.l	0(a0,d1.w),d1
	beq	Synt
	move.l	d1,a0
	move.w	#1,(a0)
        move.l 	#1,4(a0,d0.w)
        rts

;-----> Marque la table de relocation
RelJsr: move.l d0,-(sp)
        move.l 	a4,d0
        sub.l 	OldRel(a5),d0
.ReJ1:  cmp.w	#510,d0
	beq.s	.Rej2
	cmp.w 	#508,d0
        bls.s 	.ReJ2
	bsr	OutRel1
        sub.w 	#508,d0
        bra.s 	.ReJ1
.ReJ2:  lsr.w	#1,d0
	bsr	OutRel
	move.l 	a4,OldRel(a5)
        move.l	(sp)+,d0
        rts
; Poke un octet dans la table de relocation
OutRel 	move.b 	d0,(a3)+
	rts
OutRel1 move.b 	#1,(a3)+
	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Routines compilateur
;---------------------------------------------------------------------

******* Reservation memoire
ResBuffer
	movem.l	d0/d1,-(sp)
	addq.l	#4,d0
	move.l	d0,d1
	bsr	RamFast
	beq	Oofmem
	move.l	d0,a0
	move.l	d1,(a0)+
	add.l	d1,MaxMem(a5)
	movem.l	(sp)+,d0/d1
	rts
******* Effacement memoire
EraBuffer
	lea	D_Buffers(a5),a2
	lea	F_Buffers(a5),a0
	move.l	a0,d2
EBuf1	move.l	(a2)+,d0
	beq.s	EBuf2
	move.l	d0,a1
	move.l	-(a1),d0
	bsr	RamFree
EBuf2	cmp.l	d2,a2
	bcs.s	EBuf1
	bsr	EraInBuffer
	bsr	EraObjet
	rts

******* Fabrication des hunks

;-----> Debut HUNK D1, type D2
DebHunk
	cmp.w	#3,Flag_Type(a5)
	beq.s	PasHunk
	movem.l	d0-d2/a0-a1,-(sp)
	move.l	#$3E9,d0
	or.l	d2,d0
	bsr	OutLong
	moveq	#0,d0
	bsr	OutLong
	lsl.w	#3,d1
	lea	T_Hunks(a5),a1
	move.l	a4,0(a1,d1.w)
	move.l	d2,4(a1,d1.w)
	movem.l	(sp)+,d0-d2/a0-a1
	rts
;-----> Fin d'un hunk
FinHunk
	cmp.w	#3,Flag_Type(a5)
	bne.s	FHu0
; Rend pair...
PasHunk	move.w	a4,d0
	and.w	#$0001,d0
	add.w	d0,a4
	rts
; Fait le HUNK
FHu0	movem.l	d0-d2/a0-a1,-(sp)
	lsl.w	#3,d1
	lea	T_Hunks(a5),a1
	move.l	a4,d0
	sub.l	0(a1,d1.w),d0
	and.w	#$0003,d0
	beq.s	FHu1
	neg.w	d0
	addq.w	#4,d0
	add.w	d0,a4
FHu1	move.l	a4,d0
	sub.l	0(a1,d1.w),d0
	lsr.l	#2,d0
	or.l	d0,4(a1,d1.w)
	move.l	#$3F2,d0
	bsr	OutLong
	movem.l	(sp)+,d0-d2/a0-a1
	rts
;-----> Marque la longueur d'un hunk
MarkHunk
	movem.l	d0-d2/a0-a1,-(sp)
	lsl.w	#3,d1
	lea	T_Hunks(a5),a1
	move.l	0(a1,d1.w),a4
	subq.l	#4,a4
	move.l	4(a1,d1.w),d0
	and.l	#$00FFFFFF,d0
	bsr	OutLong
	movem.l	(sp)+,d0-d2/a0-a1
	rts
;-----> Copie D3 octets, fichier D1 en (a4)
OutFRead
	movem.l	a0-a2/d0-d7,-(sp)
	move.l	d1,d5
	move.l	B_DiskIn(a5),d2
	move.l	d3,d6
Ofr0	move.l	#L_DiscIn,d3
	cmp.l	d6,d3
	bcs.s	Ofr1
	move.l	d6,d3
Ofr1	move.l	d5,d1
	bsr	FRead
	beq	DError
	sub.l	d3,d6
	move.l	d2,a2
	move.w	d3,d4
	lsr.l	#2,d3
	beq.s	Ofr3
	sub.w	#1,d3
Ofr2	move.l	(a2)+,d0
	bsr	OutLong
	dbra	d3,Ofr2
Ofr3	and.w	#$0003,d4
	beq.s	Ofr5
	subq.w	#1,d4
Ofr4	move.b	(a2)+,d0
	bsr	OutByte
	dbra	d4,Ofr4
Ofr5	tst.l	d6
	bne.s	Ofr0
	movem.l	(sp)+,a0-a2/d0-d7
	rts

;-----> Copie D3 octets source->objet
CopySrce
	tst.l	d3
	beq.s	CpyS
CpyS1	bsr	GetWord
	bsr	OutWord
	subq.l	#2,d3
	bcs.s	CpyS
	bne.s	CpyS1
CpyS	rts

;-----> Copie d'un fichier
;	A0=	Nom du fichier
;	D1/D2=	definition hunk
;	D3=	Nombre d'octets � sauter au debut!
;	D4=	A sauter a la fin
CopyHunk
	move.l	d1,-(sp)	* Cree le hunk
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	bsr	DebHunk
	moveq	#F_Courant,d1
	bsr	FOpenOld	* Ouvre le fichier
	beq	DError
	moveq	#F_Courant,d1
	bsr	FLof		* Taille
	sub.l	(sp)+,d0
	moveq	#-1,d3
	move.l	(sp)+,d2
	sub.l	d2,d0
	move.l	d0,-(sp)
	moveq	#F_Courant,d1
	bsr	FSeek		* Saute le debut
	move.l	(sp)+,d3	* Charge
	moveq	#F_Courant,d1
	bsr	OutFRead
	moveq	#F_Courant,d1
	bsr	FClose
	move.l	(sp)+,d1	* Fin du hunk
	bsr	FinHunk
	rts

******* Initialisation disque
IniDisc	movem.l	a0-a2/d0-d7,-(sp)
	move.l	#$1000,L_DiscIn(a5)	* Buffer disque
	move.l	#128,BordBso(a5)	* Bordure source
	move.l	#768,BordBob(a5)	* Bordure objet
	tst.w	Flag_AMOS(a5)
	bne.s	InidX
* Ouvre le DOS
	moveq	#0,d0
	move.l	$4,a6
	lea	Nom_Dos(pc),a1
	jsr	OpenLib(a6)
	move.l	d0,C_DosBase(a5)
	beq	CFini2
* Ouvre la graphics library
	moveq	#0,d0
	lea	Nom_Graphic(pc),a1
	jsr	OpenLib(a6)
	move.l	d0,C_GfxBase(a5)
	beq	DError
* Buffer disque
InidX	move.l	#L_DiscIn,d0
	bsr	ResBuffer
	move.l	a0,B_DiskIn(a5)
	movem.l	(sp)+,a0-a2/d0-d7
	rts

******* FIN DISQUE
FinDisc
* Ferme tous les fichiers
	bsr	CloseAll
* Ferme les librairies, si pas AMOS
	tst.w	Flag_AMOS(a5)
	bne.s	FDi2
	tst.l	C_DosBase(a5)
	beq.s	FDi1
	move.l	C_DosBase(a5),a1
	move.l	$4.w,a6
	jsr	CloseLib(a6)
* Ferme la GFX
FDi1	move.l	C_GfxBase(a5),d0
	beq.s	FDi2
	move.l	d0,a1
	move.l	$4.w,a6
	jsr	CloseLib(a6)
FDi2	rts

******* Initialisation des icones
InitIcons
	tst.w	Flag_Type(a5)
	bne.s	.Iicx
	tst.l	C_IconBase(a5)
	bne.s	.Iic1
	moveq	#0,d0
	lea	Nom_IconLib(pc),a1
	move.l	$4,a6
	jsr	OpenLib(a6)
	move.l	d0,C_IconBase(a5)
	beq	NoIcons
; Charge l'icone par defaut
.Iic1	move.l	C_IconBase(a5),a6
	moveq	#8-1,d0
	bsr	GetNom
	jsr	-78(a6)
	move.l	d0,C_Icon(a5)
	beq	NoIcons
	move.l	d0,a0
	move.l	#$80000000,d0
	move.l	d0,$3a(a0)
	move.l	d0,$3e(a0)
; Ok!
.Iicx	rts

******* Fin des icones
FinIcons
	move.l	C_IconBase(a5),d0
	beq.s	.FicX
	move.l	d0,a6
	move.l	C_Icon(a5),d0
	beq.s	.Fic1
	move.l	d0,a0
	jsr	-90(a6)
.Fic1
	tst.w	IconAMOS(a5)
	bne.s	.FicX
	move.l	a6,a1
	move.l	$4.w,a6
	jsr	CloseLib(a6)
.FicX	rts

******* Sauve l'icone du programme
SIcon	tst.w	Flag_Type(a5)
	bne.s	.SicX
	move.l	a6,-(sp)
	lea	Nom_Objet(a5),a0
	move.l	C_Icon(a5),a1
	move.l	C_IconBase(a5),a6
	jsr	-84(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq	DError
.SicX	rts

*********************************************************************
*	GESTION SOURCE

******* Initilialisation SOURCE
IniSource
	moveq	#27,d0
	bsr	MesPrint
	lea	Nom_Source(a5),a0
	bsr	StrPrint
	bsr	Return
	tst.w	Flag_Source(a5)
	bne.s	IniS2
* Tout en RAM
	lea	Nom_Source(a5),a1
	moveq	#F_Source,d1
	bsr	FOpenOld
	beq	DError
	moveq	#F_Source,d1
	bsr	FLof
	move.l	d0,L_Source(a5)
	move.l	d0,d3
	addq.l	#8,d0
	bsr	ResBuffer
	move.l	a0,B_Source(a5)
	move.l	a0,d2
	moveq	#F_Source,d1
	bsr	FRead
	moveq	#F_Source,d1
	bsr	FClose
	bra	HVerif
******* Petit buffer
IniS2	move.l	L_BSo(a5),d0
	move.l	d0,MaxBso(a5)
	bsr	ResBuffer
	move.l	a0,B_Source(a5)
	lea	Nom_Source(a5),a1
	moveq	#F_Source,d1
	bsr	FOpenOld
	beq	DError
	moveq	#F_Source,d1
	bsr	FLof
	move.l	d0,L_Source(a5)
; Charge le debut
        clr.l 	DebBso(a5)
	move.l	d0,TopSou(a5)
        move.l 	MaxBso(a5),FinBso(a5)
        bsr 	LoadBso
* Verifie le HEADER
HVerif:	move.l 	B_Source(a5),a0
        lea 	HeadAMOS(pc),a1
        moveq 	#10-1,d0
OpSo   	cmpm.b 	(a0)+,(a1)+
        bne 	ErrNoAMOS
        dbra 	d0,OpSo
* Si V>1.3, est-ce teste???
	move.b	1(a0),d0
	cmp.b	#"v",d0
	beq	ErrNoTest
* Adresse des banques
	move.l	B_Source(a5),a0
	move.l	16(a0),d0
	lea	20(a0,d0.l),a0
	sub.l	B_Source(a5),a0
	move.l	a0,A_Banks(a5)
	lea	4(a0),a6
	bsr	GetWord
	move.w	d0,N_Banks(a5)
* Estime le nombre de lignes
	move.l	L_Source(a5),d0
	lsr.l	#4,d0
	mulu	#584,d0
	divu	#19000,d0
	lsl.w	#4,d0
	move.w	d0,NL_Source(a5)
	rts

;-----> Prend un MOT du programme (A6)
GetWord:tst.w 	Flag_Source(a5)
        bne.s 	Gsw
	add.l	B_Source(a5),a6
        move.w 	(a6)+,d0
	sub.l	B_Source(a5),a6
        rts
Gsw	move.l 	a0,-(sp)
        bsr 	SoDisk
        move.w 	(a0),d0
        addq.l 	#2,a6
        move.l 	(sp)+,a0
        rts

;-----> Prend un MOTLONG du programme (A6)
GetLong:tst.w 	Flag_Source(a5)
        bne.s 	Gsl
	add.l	B_Source(a5),a6
	move.l	(a6)+,d0
	sub.l	B_Source(a5),a6
	rts
Gsl	move.l 	a0,-(sp)
        bsr 	SoDisk
        move.l 	(a0),d0
        addq.l 	#4,a6
        move.l 	(sp)+,a0
        rts

;-----> Gestion du buffer entree SOURCE
SoDisk: cmp.l 	DebBso(a5),a6
        bcs.s 	SoDi1
        lea 	4(a6),a0
        cmp.l 	FinBso(a5),a0
        bcc.s 	SoDi1
; Adresse RELATIVE dans le buffer
        move.l 	a6,a0
        sub.l 	DebBso(a5),a0
        add.l 	B_Source(a5),a0
        rts
; Change la position du buffer
SoDi1:  movem.l d0-d7/a1,-(sp)
; Bouge le bout
        move.l 	DebBso(a5),d0
        move.l 	FinBso(a5),d1
        move.l 	MaxBso(a5),d2
        sub.l 	BordBso(a5),d2
        lea 	4(a6),a0
SoDi3:  cmp.l 	d0,a6
        bcs.s 	SoDi4
        cmp.l 	d1,a0
        bcs.s 	SoDi5
; Monte le buffer
        add.l 	d2,d0
        add.l 	d2,d1
        bra.s 	SoDi3
; Descend le buffer
SoDi4:  sub.l 	d2,d0
        sub.l 	d2,d1
        bra.s 	SoDi3
SoDi5:  move.l 	d0,DebBso(a5)
        move.l 	d1,FinBso(a5)
        bsr 	LoadBso
; Trouve l'adresse relative
        movem.l (sp)+,d0-d7/a1
        move.l 	a6,a0
        sub.l 	DebBso(a5),a0
        add.l 	B_Source(a5),a0
        rts

;-----> Charge le buffer SOURCE
LoadBso:moveq 	#F_Source,d1
	move.l	DebBso(a5),d2
	moveq	#-1,d3
        bsr 	FSeek
; Sauve l'ancien
	moveq	#F_Source,d1
        move.l 	B_Source(a5),d2
        move.l	TopSou(a5),d3
        sub.l 	DebBso(a5),d3
        cmp.l 	MaxBso(a5),d3
        bcs.s 	SoDi2
        move.l 	FinBso(a5),d3
        sub.l 	DebBso(a5),d3
SoDi2:  bra 	FRead


*********************************************************************
*	GESTION OBJET

******* Initialisation OBJET
IniObjet
	tst.w	Flag_Objet(a5)
	bne.s	IObdisc
* En m�moire, reserve le 1er buffer
	moveq	#3,d0
	bsr	GetChiffre
	move.l	d0,L_Bob(a5)
	add.l	#16,d0
	bsr	ResBuffer
	move.l	a0,Bb_Objet_Base(a5)
	move.l	a0,Bb_OBjet(a5)
	move.l	#L_Bob,4(a0)
	rts
* Sur disque
IObDisc	move.l	#L_Bob,d0
	move.l	d0,L_Bob(a5)
	bsr	ResBuffer
	move.l	a0,B_Objet(a5)
	clr.l	DebBob(a5)
	move.l	#L_Bob,FinBob(a5)
	clr.l	TopOb(a5)
	lea	Nom_Objet(a5),a1
	moveq	#F_Objet,d1
	bsr	FOpenNew
	beq	DError
	rts

******* Efface tous les buffers objets
EraObjet
	move.l	Bb_Objet_Base(a5),d3
	beq.s	.skip
.loop	move.l	d3,a1
	move.l	8(a1),d3
	move.l	-(a1),d0
	bsr	RamFree
	tst.l	d3
	bne.s	.loop
.skip	rts

******* Sauve/Ferme le programme objet
SObject
	moveq	#28,d0
	bsr	MesPrint
	lea	Nom_Objet(a5),a0
	bsr	StrPrint
	bsr	Return

	tst.w	Flag_Objet(a5)
	bne.s	SObj1
	lea	Nom_Objet(a5),a1
	moveq	#F_Objet,d1
	bsr	FOpenNew
	beq	DError
	move.l	BB_Objet_Base(a5),d4
.loop	move.l	d4,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	a0,d2
	add.l	d3,d0
	cmp.l	L_Objet(a5),d0
	bls.s	.loop1
	sub.l	L_Objet(a5),d0
	sub.l	d0,d3
	beq.s	SObj2
.loop1	moveq	#F_Objet,d1
	bsr	FWrite
	beq	DError
.loop2	tst.l	d4
	bne.s	.loop
	bra.s	SObj2
* Sur disque: sauve le dernier buffer!
SObj1	bsr	SaveBob
SObj2	moveq	#F_Objet,d1
	bsr	FClose
	rts

;-----> En cas d'erreur, KILL OBJECT!
KObject	moveq	#F_Objet,d1
	bsr	FHandle
	beq.s	KObx
; Ferme le fichier
	clr.l	(a0)
	move.w	#DosClose,d7
	bsr	DosCall
; Efface le fichier
	lea	Nom_Objet(a5),a0
	move.l	a0,d1
	move.w	#DosDel,d7
	bsr	DosCall
; Fini
KObX	rts

;-----> Trouve le buffer objet contenant A4
GetBob	movem.l	a1/d0/d1,-(sp)
	move.l	Bb_Objet_Base(a5),a0
.loop	move.l	a0,a1
	move.l	(a0),d1
	add.l	4(a0),d1
	cmp.l	d1,a4
	bcs.s	.loop2
	move.l	8(a0),d0
	move.l	d0,a0
	bne.s	.loop
; Il faut en reserver un autre...
.loop1	move.l	#L_Bob,d0
	add.l	#16,d0
	bsr	ResBuffer
	move.l	a0,8(a1)
; En reserver ENCORE un autre?
	move.l	d1,(a0)
	move.l	#L_Bob,4(a0)
	move.l	a0,a1
	add.l	#L_Bob,d1
	cmp.l	d1,a4
	bcc.s	.loop1
* Ok!
.loop2	move.l	a1,Bb_Objet(a5)
	movem.l	(sp)+,a1/d0/d1
	rts

;-----> Poke un BYTE dans l'objet
OutByte:tst.w	Flag_Objet(a5)
	bne.s	OutbD
* En m�moire
	movem.l	a0/a4,-(sp)
.Reskip	move.l	Bb_Objet(a5),a0
	sub.l	(a0),a4
	cmp.l	4(a0),a4
	bcc.s	.skip
	add.l	a0,a4
	move.b	d0,12(a4)
	movem.l	(sp)+,a0/a4
	addq.l	#1,a4
	rts
.skip	movem.l	(sp),a0/a4
	bsr	GetBob
	bra.s	.ReSkip
* Sur disque
OutbD   move.l 	a0,-(sp)
        bsr 	ObDisk
        move.b 	d0,(a0)+
        addq.l 	#1,a4
        move.l 	(sp)+,a0
        cmp.l 	TopOb(a5),a4
        bcs.s 	PamB
        move.l 	a4,TopOb(a5)
PamB:   rts

;-----> Poke un MOT dans l'objet
OutWord:tst.w	Flag_Objet(a5)
	bne.s	OutwD
* En m�moire
OutW	movem.l	a0/a4,-(sp)
.Reskip	move.l	Bb_Objet(a5),a0
	sub.l	(a0),a4
	cmp.l	4(a0),a4
	bcc.s	.skip
	add.l	a0,a4
	move.w	d0,12(a4)
	movem.l	(sp)+,a0/a4
	addq.l	#2,a4
	rts
.skip	movem.l	(sp),a0/a4
	bsr	GetBob
	bra.s	.ReSkip
* Sur disque
OutwD   move.l 	a0,-(sp)
        bsr 	ObDisk
        move.w 	d0,(a0)+
        addq.l 	#2,a4
        move.l 	(sp)+,a0
        cmp.l 	TopOb(a5),a4
        bcs.s 	PamW
        move.l 	a4,TopOb(a5)
PamW:   rts

;-----> Poke un MOT LONG dans l'objet
OutLong:tst.w	Flag_Objet(a5)
	bne.s	OutlD
* En m�moire
	movem.l	a0/a4,-(sp)
.Reskip	move.l	Bb_Objet(a5),a0
	sub.l	(a0),a4
	cmp.l	4(a0),a4
	bcc.s	.skip
	addq.l	#4,a4
	cmp.l	4(a0),a4
	bhi.s	.probleme
	add.l	a0,a4
	move.l	d0,12-4(a4)
	movem.l	(sp)+,a0/a4
	addq.l	#4,a4
	rts
.skip	movem.l	(sp),a0/a4
	bsr	GetBob
	bra.s	.ReSkip
.probleme
	movem.l	(sp)+,a0/a4
	swap	d0
	bsr	OutW
	swap	d0
	bra	OutW
* Sur disque
OutlD   move.l 	a0,-(sp)
        bsr 	ObDisk
        move.l 	d0,(a0)+
        addq.l 	#4,a4
        move.l 	(sp)+,a0
        cmp.l 	TopOb(a5),a4
        bcs.s 	PamL
        move.l 	a4,TopOb(a5)
PamL:   rts

;-----> Debuggage
;Protect
;	move.l	#0,-(sp)
;	move.l	#0,-(sp)
;	move.l	#0,-(sp)
;	move.l	#0,-(sp)
;	bsr	*+$212
;	lea	$10(sp),sp
;	rts
;	dc.w	$4321

;-----> Prend un mot long dans l'objet
GtoLong:tst.w	Flag_Objet(a5)
	bne.s	PaGL
* En memoire
	bsr	GtoW
	swap	d0
	bsr	GtoW
	tst.l	d0
	rts
GtoW	movem.l	a0/a4,-(sp)
.Reskip	move.l	Bb_Objet(a5),a0
	sub.l	(a0),a4
	cmp.l	4(a0),a4
	bcc.s	.skip
	add.l	a0,a4
	move.w	12(a4),d0
	movem.l	(sp)+,a0/a4
	addq.l	#2,a4
	rts
.skip	movem.l	(sp),a0/a4
	bsr	GetBob
	bra.s	.ReSkip
* Sur disque
PaGL    move.l 	a0,-(sp)
        bsr 	ObDisk
        move.l 	(a0)+,d0
        addq.l 	#4,a4
        move.l 	(sp)+,a0
        rts

;-----> Sortie de code
OutCode	move.l	d0,-(sp)
	move.w	(a0)+,d0
OutC1	bsr	OutWord
	move.w	(a0)+,d0
	cmp.w	#$4321,d0
	bne.s	OutC1
	move.l	(sp)+,d0
	rts

;-----> GESTION DU BUFFER OBJET DISQUE
ObDisk: cmp.l 	DebBob(a5),a4
        bcs.s 	ObDi1
        lea 	4(a4),a0
        cmp.l 	FinBob(a5),a0
        bcc.s 	ObDi1
; Adresse RELATIVE dans le buffer
        move.l 	a4,a0
        sub.l 	DebBob(a5),a0
        add.l 	B_Objet(a5),a0
        rts
; Change la position du buffer
ObDi1:  movem.l d0-d7/a0-a2,-(sp)
; Sauve le buffer
        bsr 	SaveBob
; Bouge le bout
        move.l 	DebBob(a5),d0
        move.l 	FinBob(a5),d1
        move.l 	#L_Bob,d2
        sub.l 	BordBob(a5),d2
        lea 	4(a4),a0
ObDi3:  cmp.l 	d0,a4
        bcs.s 	ObDi4
        cmp.l 	d1,a0
        bcs.s 	ObDi5
; Monte le buffer
        add.l 	d2,d0
        add.l 	d2,d1
        bra.s 	ObDi3
; Descend le buffer
ObDi4:  sub.l 	d2,d0
        sub.l 	d2,d1
        bra.s 	ObDi3
ObDi5:  move.l 	d0,DebBob(a5)
        move.l 	d1,FinBob(a5)
; Charge le nouveau bout
	moveq 	#F_Objet,d1
	move.l	DebBob(a5),d2
	moveq	#-1,d3
        bsr 	FSeek
        move.l 	FinBob(a5),d3
        cmp.l 	TopOb(a5),d3
        bcs.s 	ObDi6
        move.l 	TopOb(a5),d3
ObDi6:  sub.l 	DebBob(a5),d3
        beq.s 	ObDi7
	moveq	#F_Objet,d1
	move.l	B_Objet(a5),d2
        bsr 	FRead
; Trouve l'adresse relative
ObDi7:  movem.l (sp)+,d0-d7/a0-a2
        move.l 	a4,a0
        sub.l 	DebBob(a5),a0
        add.l 	B_Objet(a5),a0
        rts

;-----> Sauve le buffer OBJET
SaveBob:moveq	#F_Objet,d1
        move.l 	DebBob(a5),d2
	moveq	#-1,d3
        bsr 	FSeek
; Sauve l'ancien
	moveq	#F_Objet,d1
        move.l 	B_Objet(a5),d2
        move.l 	TopOb(a5),d3
        sub.l 	DebBob(a5),d3
        cmp.l 	#L_Bob,d3
        bcs.s 	ObDi2
	move.l 	FinBob(a5),d3
        sub.l 	DebBob(a5),d3
ObDi2:  bsr 	FWrite
        rts


******* DOS CALL: appelle une routine DOS D7
DosCall
	movem.l a5/a6,-(sp)
	move.l 	C_DosBase(a5),a6
	move.l	a6,a5
	add.w	d7,a5
	jsr	(a5)
	movem.l	(sp)+,a5/a6
	tst.l	d0
	rts
******* Trouve le handle #D1
FHandle	move.w	d1,d0
	lsl.w	#2,d0
	lea	T_Handles(a5),a0
	add.w	d0,a0
	move.l	(a0),d1
	rts

******* OPEN: ouvre le fichier A0, # Handle D1, acces D2
FOpenOld
	move.l	#1005,d2
	bra.s	FOpen
FOpenNew
	move.l	#1006,d2
FOpen
	bsr	FHandle
	bne	DError
	move.l	a0,-(sp)
	move.l	a1,d1
	move.w	#DosOpen,d7
	bsr	DosCall
	move.l	(sp)+,a0
	move.l	d0,(a0)
	rts
******* CLOSE fichier D1
FClose
	bsr	FHandle
	beq	PaFCl
	clr.l	(a0)
	move.w	#DosClose,d7
	bsr	DosCall
PaFCl:	rts
******* CLOSE TOUS les fichiers
CloseAll
	moveq	#M_Fichiers-1,d6
ClAl	move.l	d6,d1
	bsr	FClose
	dbra	d6,ClAl
	rts
******* READ fichier D1, D3 octets dans D2
FRead:
	movem.l	d1/a6,-(sp)
	bsr	FHandle
	move.l	C_DosBase(a5),a6
	jsr	DosRead(a6)
	movem.l	(sp)+,d1/a6
	tst.l	d0
	beq.s	ErdE
	bmi.s	ErdE
	cmp.l	d0,d3
	bne.s	ErdE
ErdB	moveq	#-1,d7
	rts
ErdE 	moveq	#0,d7
	rts
******* WRITE fichier D1, D3 octets de D2
FWrite:	movem.l	d1/a6,-(sp)
	bsr	FHandle
	move.l	C_DosBase(a5),a6
	jsr	DosWrite(a6)
	movem.l	(sp)+,d1/a6
	tst.l	d0
	beq.s	ErdE
	bmi.s	ErdE
	cmp.l	d0,d3
	bne.s	ErdE
	bra.s	ErdB

******* SEEK fichier D1, D3 mode D2 deplacement
FSeek:
	movem.l	d1/a6,-(sp)
	bsr	FHandle
	move.l	C_DosBase(a5),a6
	jsr	DosSeek(a6)
	movem.l	(sp)+,d1/a6
	tst.l	d0
	bmi.s	ErdE
	bra.s	ErdB
******* LOF fichier D1
FLof
	bsr	FHandle
FLof2	move.l	d1,-(sp)
	moveq	#0,d2			* Seek --> fin
	moveq	#1,d3
	move.w	#DosSeek,d7
	bsr	DosCall
	move.l	(sp)+,d1
	move.l	d0,d2			* Seek --> debut!
	moveq	#-1,d3
	bra	DosCall
*
A4Pair	move.w	a4,d0
	btst	#0,d0
	beq.s	A4p
	addq.l	#1,a4
A4p	rts


******* Mise a zero!
RamFast	movem.l	d1-d2/a0-a2/a6,-(sp)
	move.l	#Public|Clear,d1
	ExeCall	AllocMem
	movem.l	(sp)+,d1-d2/a0-a2/a6
	tst.l	d0
	rts
RamChip	movem.l	d1-d2/a0-a2/a6,-(sp)
	move.l	#Public|Chip|Clear,d1
	ExeCall	AllocMem
	movem.l	(sp)+,d1-d2/a0-a2/a6
	tst.l	d0
	rts
******* Liberation
RamFree	movem.l	d0-d2/a0-a2/a6,-(sp)
	ExeCall	FreeMem
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

******* stocke la position dans l'objet
StockOut
	move.l	a0,-(sp)
	move.l	A_Stock(a5),a0
	move.l	a3,(a0)+
	move.l	a4,(a0)+
	move.l	OldRel(a5),(a0)+
	move.l	a0,A_Stock(a5)
	move.l	(sp)+,a0
	rts
RestOut
	move.l	a0,-(sp)
	move.l	A_Stock(a5),a0
	move.l	-(a0),OldRel(a5)
	move.l	-(a0),a4
	move.l	-(a0),a3
	move.l	a0,A_Stock(a5)
	move.l	(sp)+,a0
	rts
SautOut
	sub.l	#12,A_Stock(a5)
	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Instructions / Fonctions standart
;---------------------------------------------------------------------

;-----> CONTROLE COMPILATEUR
CTstOn	clr.w	Flag_NoTests(a5)
	rts
CTstOf	move.w	#-1,Flag_NoTests(a5)
	rts
CTst	move.w	#L_Tests,d0
	bra	CreFonc
COpt	bsr	StockOut
	bsr	Evalue
	bra	RestOut

;-----> Instruction etendue...
IExtension
	bsr	GetWord
	lsr.w	#8,d0
	move.w	d0,d2
	lsl.w	#2,d0
	lea	BufToks(a5),a2
	move.l	0(a2,d0.w),d0
	beq	ErrExt
	move.l	d0,a2
	bsr	GetWord
	move.w	d0,d4
	move.w	0(a2,d0.w),d1
	lea	4(a2,d0.w),a2
* Est-ce un instruction de controle COMPILER?
	cmp.w	#Ext_Nb,d2
	bne.s	.PaCont
	cmp.w	#Ext_TkCmp,d0
	beq	ErrAlready
	cmp.w	#Ext_TkCOp,d0
	beq	COpt
	cmp.w	#Ext_TkTstOn,d0
	beq	CTstOn
	cmp.w	#Ext_TkTstOf,d0
	beq	CTstOf
	cmp.w	#Ext_TkTst,d0
	beq	CTst
.PaCont
* Est-ce un .AMOS?
	moveq	#-1,d3
	cmp.w	#3,Flag_Type(a5)
	bne	IStan
	moveq	#0,d3
	bsr	IStan
	bra	ExtCall
;-----> Fonction etendue
FExtension
	bsr	GetWord
	lsr.w	#8,d0
	move.w	d0,d2
	lsl.w	#2,d0
	lea	BufToks(a5),a2
	move.l	0(a2,d0.w),d0
	beq	ErrExt
	move.l	d0,a2
	bsr	GetWord
	move.w	d0,d4
	addq.w	#2,d4
	move.w	2(a2,d0.w),d1
	lea	4(a2,d0.w),a2
; Est-ce un .AMOS?
	cmp.w	#3,Flag_Type(a5)
	beq.s	.Skip1
	moveq	#-1,d3
	bsr	FStan
	bra.s	.Skip2
.Skip1	moveq	#0,d3
	bsr	FStan
	bsr	ExtCall
.Skip2
; Pousse le parametre dans la pile et revient...
	move.w	CMvd3ma3(pc),d0
	bra	OutWord
* Routine: appelle l'extension en .AMOS
ExtCall	move.w	Cmviwd0(pc),d0
	bsr	OutWord
	move.w	d1,d0
	lsl.w	#2,d0
	bsr	OutWord
	move.w	Cmviwd1(pc),d0
	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	move.w	#L_ExtCall,d0
	bra	CreFonc

;-----> Instruction standard
IStandard
	move.w	2(a0,d0.w),d1
	moveq	#0,d2
	moveq	#-1,d3
	lea	4(a0,d0.w),a2
	bra	IStan
;-----> Fonction standard
FStandard
	move.w	2(a0,d0.w),d1
FStand
	moveq	#0,d2
	moveq	#-1,d3
	lea	4(a0,d0.w),a2
	bra	FStan

* Routine instruction
IStan	movem.w	d1/d2/d3/d4,-(sp)
IStan0	tst.b	(a2)+
	bpl.s	IStan0
	move.b	(a2)+,d0
; Instruction
	cmp.b	#"I",d0
	bne.s	IStan1
	bsr	OutLea
	bsr	CParams
	movem.w	(sp)+,d0/d1/d2/d3
	tst.w	d2
	bne	CreFoncExt
	rts
; Variable reservee en instruction
IStan1	cmp.b	#"V",d0
	bne	Synt
	move.b	(a2)+,d0
	sub.b	#"0",d0
	move.w	d0,-(sp)
	tst.b	(a2)		* Saute la parenthese!
	bmi.s	IStan1a
	addq.l	#2,a6
	bsr	CParams
IStan1a	bsr	GetWord
	cmp.w	#TkEg-Tk,d0
	bne	Synt
	bsr	Evalue
	move.w	(sp)+,d1
	cmp.b	d1,d2
	beq.s	IStan3
	subq.b	#1,d1
	bmi.s	IStan2
	bne	Synt
	bsr	IntToFl
	bra.s	IStan3
IStan2	bsr	FlToInt
IStan3	movem.w	(sp)+,d0/d1/d2/d3
	tst.w	d2
	bne	CreFoncExt
	rts
* Routine fonction
FStan	movem.w	d1/d2/d3/d4,-(sp)
FStan0	tst.b	(a2)+
	bpl.s	FStan0
	move.b	(a2)+,d0
; Fonction
	cmp.b	#"2",d0
	bhi.s	FStan2
FStand1	and.w	#$00FF,d0
	sub.b	#"0",d0
	move.w	d0,-(sp)
	tst.b	(a2)
	bmi.s	FStan1a
	addq.l	#2,a6
	bsr	CParams
FStan1a	move.w	(sp)+,d4
	cmp.b	#1,d4
	bne.s	FStan1b
	bset	#0,Flag_Math(a5)
FStan1b	movem.w	(sp)+,d0/d1/d2/d3
	exg	d2,d4
	tst.w	d4
	bne	CreFoncExt
	rts
; Variable reservee en fonction
FStan2	cmp.b	#"V",d0
	bne	Synt
	addq.w	#1,(sp)
	move.b	(a2)+,d0
	bra.s	FStand1

* ROUTINE > recupere les parametres standards
CParams	move.b	(a2)+,d0
	bmi.s	CParX
CPar1	move.l	a2,-(sp)
	cmp.b	#"3",d0
	beq.s	.Con
	sub.b	#48+1,d0
	bmi.s	CPar3
	beq.s	CPar2
; Une chaine
	bsr	Evalue
	cmp.b	#2,d2
	beq.s	CParL
	bra	Synt
; N'importe quoi (entier/float)
.Con	bsr	Evalue
	cmp.b	#1,d0
	bne.s	CParL
	bsr	FlToInt
	bra.s	CParL
; Un float
CPar2	bset	#0,Flag_Math(a5)
	bsr	Evalue
	subq.b	#1,d2
	beq.s	CParL
	bpl	Synt
	bsr	IntToFl
	bra.s	CParL
; Entier
CPar3	bsr	Evalue
	subq.b	#1,d2
	bmi.s	CParL
	bne	Synt
	bsr	FlToInt
; Encore un param?
CParL	move.l	(sp)+,a2
	tst.b	(a2)+
	bmi.s	CParX
	addq.l	#2,a6
	move.b	(a2)+,d0
	bra.s	CPar1
CParX	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Evaluations / Calculs
;---------------------------------------------------------------------

******* SET BUFFER
CSBuf	addq.l	#2,a6
	bsr	GetLong
	move.l	d0,L_Buf(a5)
	rts

******* GLOBAL / SHARED -> saute les variables
CGlob
CShar	addq.l	#2,a6
	bsr	GetWord
	move.w	d0,d3
	bsr	GetWord
	moveq	#0,d2
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
	bsr	VAdr0
CSh1	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CShar
	cmp.w	#TkPar1-Tk,d0
	bne.s	CSh2
	addq.l	#2,a6
	bra.s	CSh1
CSh2	subq.l	#2,a6
	rts

******* Prise d'une variable
IVar	bsr	OutLea
IVarBis	move.l	a6,-(sp)
	bsr	SoVar
	move.w	d2,-(sp)
	bsr	FnEval
	move.b	d2,d5
	move.w	(sp),d2
	and.w	#$07,d2
	cmp.b	#1,d2
	bne.s	.skip
	bset	#0,Flag_Math(a5)
.skip	cmp.b	d2,d5
	beq.s	IVr1
	tst.b	d2
	bne.s	IVr0
	bsr	FlToInt
	bra.s	IVr1
IVr0	bsr	IntToFl
IVr1	addq.l	#2,sp
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	move.l	(sp)+,a6
	bmi.s	IVrT
	beq.s	IVrL
* Variable GLOBALE
	move.w	CVrG(pc),d0
	bra.s	IVr2
CVrG	move.l	(a3)+,2(a0)
* Variable LOCALE
IVrL	move.w	CVrL(pc),d0
IVr2	bsr	OutWord
	move.w	d3,d0
	bra	OutWord
CVrL	move.l	(a3)+,2(a6)
* Variable TABLEAU
IVrT	moveq	#L_GetTablo,d0
	bsr	CreFonc
	move.w	CVrT(pc),d0
	bra	OutWord
CVrT	move.l	(a3)+,(a0)

******* Met l'adresse de base d'une variable en A0
AdBase	tst.w	d1
	beq.s	AdA0L
	bpl.s	AdA0G
	rts
* Variable GLOBALE
AdA0G	move.w	CLea2a0a0(pc),d0
	bra.s	IVr2
* Variable LOCALE
Ada0L	move.w	CLea2a6a0(pc),d0
	bra.s	IVr2
******* Met l'adresse d'une variable en A0
AdToA0	tst.w	d1
	beq.s	AdA0L
	bpl.s	AdA0G
	moveq	#L_GetTablo,d0
	bra	CreFonc

******* Variable en fonction
FVar	bsr	VarAdr
	and.w	#$000F,d2
	cmp.b	#1,d2
	bne.s	.skip
	bset	#0,Flag_Math(a5)
.skip	tst.w	d1
	bmi.s	FVrT
	beq.s	FVrL
; Variable globale
	move.w	Cmv2a0Ma3(pc),d0		Globale
	bra.s	FVr
; Variable locale
FVrL	move.w	Cmv2a6Ma3(pc),d0		Locale
FVr	bsr	OutWord
	move.w	d3,d0
	bra	OutWord
; Variable tableau
FVrT	moveq	#L_GetTablo,d0
	bsr	CreFonc
	move.w	Cmvpa0Ma3(pc),d0
	bra	OutWord

** Saute une variable
SoVar	bsr	GetWord
	bsr	GetWord
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
	btst	#6,d2
	beq.s	SoV3
; Saute les params du tableau
	clr.w	d1
SoV1	bsr	GetWord
	cmp.w	#TkPar1-Tk,d0
	bne.s	SoV2
	addq.w	#1,d1
SoV2	cmp.w	#TkPar2-Tk,d0
	bne.s	SoV1
	subq.w	#1,d1
	bne.s	SoV1
; Met le flag float!
SoV3	rts
** Trouve l'adresse d'une variable D2-D3
VarAdr	bsr	GetWord
	move.w	d0,d3
	bsr	GetWord
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
	btst	#6,d2
	bne	VAdrT
VAdr0	moveq	#0,d0
	tst.w	d3
	bmi.s	VAdrL
* >0: Variable LOCALE
	move.w	d3,d0
	move.l	A_FlagVarL(a5),a0
	bsr	VMark
	addq.w	#6,d3
	neg.w	d3
	moveq	#0,d1
	rts
* <0: Variable GLOBALE
VAdrL	addq.w	#1,d3
	move.w	d3,d0
	neg.w	d0
	move.l	B_FlagVarG(a5),a0
	bsr	VMark
	sub.w	#12,d3
 	move.l	CVarGlo(pc),d0
	bsr	OutLong
	moveq	#1,d1
	rts
CVarGlo	move.l	VarGlo(a5),a0
* Variable tableau
VAdrT	movem.w	d2/d3,-(sp)
	addq.l	#2,a6
	clr.w	-(sp)
VAdrt1	addq.w	#1,(sp)
	bsr	Expentier
	cmp.w	#TkPar2-Tk,d0
	beq.s	VAdrt2
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	VAdrt1
	bra	Synt
VAdrt2	move.w	(sp)+,d7
	movem.w	(sp)+,d2/d3
	bsr	VAdr0
	tst.w	d1
	beq.s	VAtl
	move.w	Clea2a0a0(pc),d0
	bra.s	VAtt
VAtl	move.w	Clea2a6a0(pc),d0
VAtt	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	moveq	#-1,d1
	rts
* Marque le flag de la variable
VMark	addq.w	#6,d0
	cmp.w	(a0),d0
	bcs.s	Vml1
	move.w	d0,(a0)
Vml1	divu	#6,d0
	and.b	#%01001111,d2
	lea	2-1(a0,d0.w),a0
	move.b	d2,(a0)
	rts
** Trouve l'adresse d'une variable D2-D3, SPECIAL FN
VarAdrFn
	bsr	GetWord
	move.w	d0,d3
	bsr	GetWord
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
	moveq	#0,d0
	tst.w	d3
	bmi.s	.VAdrL
* >0: Variable LOCALE
	move.w	d3,d0
	move.l	A_FlagVarL(a5),a0
	bsr	.VMark
	addq.w	#6,d3
	neg.w	d3
	moveq	#0,d1
	rts
* <0: Variable GLOBALE
.VAdrL	addq.w	#1,d3
	move.w	d3,d0
	neg.w	d0
	move.l	B_FlagVarG(a5),a0
	bsr.s	.VMark
	sub.w	#12,d3
 	move.l	CVarGlo(pc),d0
	bsr	OutLong
	moveq	#1,d1
	rts
* PREND le flag de la variable SPECIAL Def Fn
.VMark	addq.w	#6,d0
	divu	#6,d0
	lea	2-1(a0,d0.w),a0
	move.b	(a0),d2
	rts

******* DIM
CDim	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	move.w	Cmvqd0(pc),d0
	move.b	d7,d0
	bsr	OutWord
	moveq	#L_Dim,d0
	bsr	CreFonc
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CDim
	subq.l	#2,a6
	rts

******* DEF FN
CDefFn	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	move.l	a0,-(sp)		Adresse du flag!
	bsr	AdBase
	lea	CdDfn1(pc),a0
	bsr	OutCode
	move.l	a4,-(sp)
	bsr	GetWord
	cmp.w	#TkPar1-Tk,d0
	bne.s	Cdfn2
* Prend les variables (� l'envers)
	clr.w	N_Dfn(a5)
Cdfn0	addq.l	#2,a6
	move.l	a6,-(sp)
	addq.w	#1,N_Dfn(a5)
	bsr	SoVar
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	Cdfn0
	addq.l	#2,a6
	move.l	a6,A_Dfn(a5)
Cdfn1	move.l	(sp)+,a6
	bsr	VarAdr
	bsr	AdBase
	move.w	Cmvqd2(pc),d0
	and.b	#$03,d2
	move.b	d2,d0
	bsr	OutWord
	lea	CdDfn2(pc),a0
	bsr	OutCode
	subq.w	#1,N_Dfn(a5)
	bne.s	Cdfn1
	move.l	A_Dfn(a5),a6
* Fonction!
Cdfn2	bsr	Evalue
	move.l	4(sp),a0
	and.b	#%00000011,d2
	bset	#3,d2
	move.b	d2,(a0)
	move.w	CRts(pc),d0
	bsr	OutWord
* Saute le tout!
	move.l	a4,d0
	move.l	(sp),a4
	move.l	d0,(sp)
	subq.l	#2,a4
	sub.l	a4,d0
	bsr	OutWord
	move.l	(sp)+,a4
	addq.l	#4,sp
	rts
CdDfn1	lea	*+10(pc),a1
	move.l	a1,(a0)
	bra	CdDfn2
	dc.w	$4321
CdDfn2	lea	*+6(pc),a2
	rts
	dc.w	$4321

******* =FN
CFn	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	SoVar
	clr.w	-(sp)
	bsr	GetWord
	cmp.w	#TkPar1-Tk,d0
	bne.s	CFn2
* Prend les parametres
CFn1	addq.w	#1,(sp)
	bsr	Evalue
	move.w	Cmvima3(pc),d0
	bsr	OutWord
	and.w	#$0F,d2
	move.w	d2,d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CFn1
* Appelle la fonction
CFn2	subq.l	#2,a6
	move.l	2(sp),d0
	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	VarAdrFn
	bsr	AdBase
	move.w	(sp)+,d1
	move.w	Cmvqd0(pc),d0
	move.b	d1,d0
	bsr	OutWord
	move.l	(sp)+,a6
	move.w	#L_FN,d0
	bsr	CreFonc
	and.w	#$03,d2
	rts

******* SORT a()
CSort	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdBase
	move.w	Cmvqd2(pc),d0
	and.w	#$03,d2
	move.b	d2,d0
	bsr	OutWord
	move.w	#L_Sort,d0
	bra	CreFonc
******* =MATCH(a(),b)
CMatch	bsr	OutLea
	addq.l	#4,a6
	move.l	a6,-(sp)
	bsr	SoVar
	and.w	#$0f,d2
	move.w	d2,-(sp)
	addq.l	#2,a6
	bsr	Evalue
	move.w	(sp)+,d1
	bsr	EqType
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	bsr	AdBase
	move.w	Cmvqd2(pc),d0
	and.w	#$0f,d2
	move.b	d2,d0
	bsr	OutWord
	move.w	#L_FFind,d0
	bsr	CreFonc
	move.l	(sp)+,a6
	moveq	#0,d2
	rts

*******	Evaluation d'expression
FnEval:	addq.l	#2,a6
Evalue:	move.w	#$7FFF,d0
	bra.s	Eva1
Eva0:	move.w	d2,-(sp)
Eva1:	move.w	d0,-(sp)
	bsr	Operande
Eva2:	bsr	GetWord
	cmp.w	(sp),d0
	bhi.s	Eva0
	subq.l	#2,a6
	move.w	(sp)+,d1
	bpl.s	Eva3
	move.w	(sp)+,d5
	lea	Tk(pc),a0
	move.w	0(a0,d1.w),d1
	beq	Synt
	addq.w	#1,NbInstr(a5)
	jsr	0(a0,d1.w)
	clr.w	Flag_Const(a5)
	bra.s	Eva2
Eva3:	cmp.w	#TkPar2-Tk,d0
	bne.s	Eva4
	addq.l	#2,a6
Eva4:	rts
** Recupere un operande
Operande:
	clr.w	-(sp)
Ope0:	addq.w	#1,NbInstr(a5)
	bsr	GetWord
	lea	Tk(pc),a0
 	tst.w	0(a0,d0.w)
	bne.s	Ope0a
	bsr	FStandard
	bra.s	Ope0b
Ope0a	move.w	2(a0,d0.w),d1
	beq	Synt
	jsr	0(a0,d1.w)
Ope0b	clr.w	Flag_Const(a5)
* Changement de signe non effectue?
Const	tst.w	(sp)+
	bne.s	Chs0
	rts
Chs0:	tst.b	d2
	bne.s	Chs1
	move.w	CChsI(pc),d0
	bra	OutWord
Chs1:	moveq	#L_NegFl,d0
	bra	CreFonc
CChsI	neg.l	(a3)
	dc.w	$4321
* Signe moins devant
OpeM:	addq.l	#4,sp
	addq.w	#1,(sp)
	bra.s	Ope0

;-----> VIRGULE / : / TO / THEN / ELSE ---> pas de parametre, entier
FNull	lea	CNull(pc),a0
	bsr	OutCode
	moveq	#0,d2
	subq.l	#2,a6
	rts
CNull	move.l	#EntNul,-(a3)
	dc.w	$4321

;-----> CONSTANTE Entiere/Hex/Bin
FEnt	move.w	CCst(pc),d0
	bsr	OutWord
	bsr	GetLong
	tst.w	4(sp)
	beq	FEnt1
	clr.w	4(sp)
	neg.l	d0
FEnt1	move.l	d0,d3
	bsr	OutLong
	moveq	#0,d2
	bra.s	DoConst
;-----> CONSTANTE Float
FFloat	bset	#0,Flag_Math(a5)
	move.w	CCst(pc),d0
	bsr	OutWord
	bsr	GetLong
	tst.w	4(a7)
	beq	FFlo1
	clr.w	4(a7)
; Change le signe!
	tst.b	d0
	beq.s	FFlo1
	bchg	#7,d0
FFlo1	bsr	OutLong
	moveq	#1,d2
	bra.s	DoConst
CCst	move.l	#$55555555,-(a3)
;-----> CONSTANTE Chaine
FChaine	move.w	CCst(pc),d0
	bsr	OutWord
	bsr	RelJsr
	move.l	A_Chaines(a5),d0
	move.l	d0,a1
	bset	#BitChaine,d0
	bsr	OutLong
	move.l	a6,(a1)
	addq.l	#4,A_Chaines(a5)
; Saute la constante
	bsr	GetWord
	btst	#0,d0
	beq.s	FCh1
	addq.w	#1,d0
FCh1	add.w	d0,a6
	moveq	#2,d2
; Marque le flag CONSTANTE
DoConst	lea	Const(pc),a0
	move.l	a0,(sp)
	rts

******* Fonctions compilo
FnExpentier
	addq.l	#2,a6
Expentier
	bsr	Evalue
DoEntier
	tst.b	d2
	bne	FlToInt
	rts
Compat
	cmp.b	d2,d5
	beq.s	CptX
	bsr	QueFloat
CptX	subq.w	#1,d5
	bne.s	CptX1
	bset	#0,Flag_Math(a5)
CptX1	tst.b	d5
	rts
QuEntier
	tst.b	d2
	beq.s	Que1
	moveq	#L_FlToInt,d0
	bsr	CreFonc
	moveq	#0,d2
Que1	tst.b	d5
	beq.s	Que2
	move.w	#L_FlToInt2,d0
	bsr	CreFonc
	moveq	#0,d5
Que2	rts
QueFloat
	bset	#0,Flag_Math(a5)
	tst.b	d2
	bne.s	QueF1
	moveq	#L_IntToFl,d0
	bsr	CreFonc
	moveq	#1,d2
QueF1	tst.b	d5
	bne.s	QueF2
	move.w	#L_IntToFl2,d0
	bsr	CreFonc
	moveq	#1,d5
QueF2	rts
EqType
	cmp.b	d1,d2
	bne.s	Eqt1
	rts
Eqt1	tst.b	d1
	bne.s	IntToFl
	beq.s	FlToInt
FnFloat
	bset	#0,Flag_Math(a5)
	bsr	FnEval
	tst.b	d2
	bne.s	FnFl1
	moveq	#L_IntToFl,d0
	bsr	CreFonc
	moveq	#1,d2
FnFl1	rts
IntToFl
	movem.l	d0-d1/a0-a2,-(sp)
	bset	#0,Flag_Math(a5)
	moveq	#L_IntToFl,d0
	bsr	CreFonc
	moveq	#1,d2
	movem.l	(sp)+,d0-d1/a0-a2
	rts
FlToInt
	movem.l	d0-d1/a0-a2,-(sp)
	bset	#0,Flag_Math(a5)
	moveq	#L_FlToInt,d0
	bsr	CreFonc
	moveq	#0,d2
	movem.l	(sp)+,d0-d1/a0-a2
	rts

;-----> Operateur +
CPlus	bsr	Compat
	bmi.s	CPl2
	beq.s	CPl1
* Chaines
	moveq	#L_PlusC,d0
	bsr	CreFonc
	moveq	#2,d2
	rts
* Float
CPl1	moveq	#L_PlusF,d0
	bsr	CreFonc
	bset	#0,Flag_Math(a5)
	moveq	#1,d2
	rts
* Entiere
CPl2	lea	CcPlus(pc),a0
	bra	OutCode
CcPlus	move.l	(a3)+,d0
	add.l	d0,(a3)
	dc.w	$4321
;-----> Operateur -
CMoins	bsr	Compat
	bmi.s	CMn2
	beq.s	CMn1
* Chaines
	moveq	#L_MoinsC,d0
	bsr	CreFonc
	moveq	#2,d2
	rts
* Float
CMn1	moveq	#L_MoinsF,d0
	bsr	CreFonc
	bset	#0,Flag_Math(a5)
	moveq	#1,d2
	rts
* Entiere
CMn2	lea	CcMoins(pc),a0
	bra	OutCode
CcMoins	move.l	(a3)+,d0
	sub.l	d0,(a3)
	dc.w	$4321
;-----> Operateur *
CMult:  moveq	#L_Mult,d0
	bsr	COpe
	move.w	d1,d2
	rts
;-----> Operateur /
CDiv	moveq	#L_Div,d0
	bsr	COpe
	move.w	d1,d2
	rts
;-----> Operateur MODULO
CMod	bsr 	Quentier
        moveq 	#L_Mod,d0
        bra 	CreFonc
;-----> Operateur PUISSANCE
CPuis:  bsr 	QueFloat
	bset	#1,Flag_Math(a5)
        moveq 	#L_Puis,d0
        bra 	CreFonc
;-----> Operateur =
CEg:  	moveq 	#L_Eg,d0
        bra.s 	COpe
;-----> Operateur <>
CDif:  	moveq 	#L_Dif,d0
        bra.s 	COpe
;-----> Operateur <
CInf:   moveq 	#L_Inf,d0
        bra.s 	COpe
;-----> Operateur >
CSup:   moveq 	#L_Sup,d0
        bra.s 	COpe
;-----> Operateur <=
CInfEg  moveq 	#L_InfEg,d0
        bra.s 	COpe
;-----> Operateur >=
CSupEg  moveq 	#L_SupEg,d0
COpe	move.w	d0,-(sp)
	bsr	Compat
	bmi.s	COp2
	beq.s	COp1
; Chaines
	move.w	(sp)+,d0
	addq.w	#2,d0
	bsr	CreFonc
	moveq	#0,d2
	moveq	#2,d1
	rts
; Float
COp1	move.w	(sp)+,d0
	addq.w	#1,d0
	bsr	CreFonc
	bset	#0,Flag_Math(a5)
	moveq	#0,d2
	moveq	#1,d1
	rts
; Entier
COp2	move.w	(sp)+,d0
	bsr	CreFonc
	moveq	#0,d2
	moveq	#0,d1
	rts

;-----> Operateur OR
COr:    bsr 	Quentier
        lea 	COr2(pc),a0
COr1:   bsr 	OutCode
	moveq	#0,d2
        rts
COr2:   move.l 	(a3)+,d0
        or.l 	d0,(a3)
        dc.w 	$4321
;-----> Operateur AND
CAnd:   bsr 	Quentier
        lea 	CAnd1(pc),a0
        bra.s 	COr1
CAnd1:  move.l 	(a3)+,d0
        and.l 	d0,(a3)
        dc.w 	$4321
;-----> Operateur XOR
CXor:   bsr 	Quentier
        lea 	CXor1(pc),a0
        bra.s 	COr1
CXor1:  move.l 	(a3)+,d0
        eor.l 	d0,(a3)
        dc.w 	$4321
;-----> Fonction NOT
CNot:   bsr 	Expentier
        lea 	CNt(pc),a0
        bra.s 	COr1
CNt:    not.l 	(a3)
        dc.w 	$4321
;-----> FALSE / TRUE
CFalse	moveq	#0,d2
	lea	CdFal(pc),a0
	bra	OutCode
CTrue	moveq	#0,d2
	lea	CdTru(pc),a0
	bra	OutCode
CdFal	clr.l	-(a3)
	dc.w	$4321
CdTru	move.l	#-1,-(a3)
	dc.w	$4321

;-----> SWAP
CSwap	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdToA0
	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
	addq.l	#4,a6
	bsr	VarAdr
	bsr	AdToA0
	move.w	#L_Swap,d0
	bra	CreFonc

******* MIN + MAX
CMin	move.w	#L_MinE,-(sp)
	bra.s	CMinMax
CMax	move.w	#L_MaxE,-(sp)
CMinMax	bsr	FnEval
	move.w	d2,-(sp)
	bsr	FnEval
	move.w	(sp)+,d5
	bsr	Compat
	bmi.s	Cmm3
	beq.s	Cmm2
Cmm1	addq.w	#1,(sp)
Cmm2	addq.w	#1,(sp)
Cmm3	move.w	(sp)+,d0
	bra	CreFonc

*******	ABS
CInt	bsr	FnEval
	tst.b	d2
	beq.s	CInt2
	move.w	#L_IntF,d0
	bsr	CreFonc
	moveq	#1,d2
CInt2	rts
CAbs	bsr	FnEval
	move.w	#L_AbsE,d0
	tst.b	d2
	beq	CreFonc
	addq.w	#1,d0
	bra	CreFonc
CSgn	bsr	FnEval
	move.w	#L_SgnE,d0
	tst.b	d2
	beq	CreFonc
	addq.w	#1,d0
	moveq	#0,d2
	bra	CreFonc
CSqr	move.w	#L_Sqr,d0
	bra.s	CMath
CLog	move.w	#L_Log,d0
	bra.s	CMath
CLn	move.w	#L_Ln,d0
	bra.s	CMath
CExp	move.w	#L_Exp,d0
	bra.s	CMath
CSin	move.w	#L_Sin,d0
	bra.s	CMath
CCos	move.w	#L_Cos,d0
	bra.s	CMath
CTan	move.w	#L_Tan,d0
	bra.s	CMath
CASin	move.w	#L_ASin,d0
	bra.s	CMath
CACos	move.w	#L_ACos,d0
	bra.s	CMath
CATan	move.w	#L_ATan,d0
	bra.s	CMath
CHsin	move.w	#L_HSin,d0
	bra.s	CMath
CHCos	move.w	#L_HCos,d0
	bra.s	CMath
CHTan	move.w	#L_HTan,d0
* Appel de la fonction
CMath	bset	#0,Flag_Math(a5)
	bset	#1,Flag_Math(a5)
	move.w	d0,-(sp)
	bsr	FnFloat
	move.w	(sp)+,d0
	moveq	#1,d2
	bra	CreFonc

******* INC
CInc	pea	CdInc(pc)
	bra.s	CIncDec
CDec	pea	CdDec(pc)
CIncDec	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdToA0
	move.l	(sp)+,a0
	bra	OutCode
CdInc	addq.l	#1,(a0)
	dc.w	$4321
CdDec	subq.l	#1,(a0)
	dc.w	$4321
******* ADD a,b
CAdd2	bsr	OutLea
	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	SoVar
	bsr	FnExpentier
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	bsr	AdToA0
	lea	CdAdd1(pc),a0
	bsr	OutCode
	move.l	(sp)+,a6
	rts
CdAdd1	move.l	(a3)+,d0
	add.l	d0,(a0)
	dc.w	$4321
******* ADD a,b,c to d
CAdd4	bsr	OutLea
	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	SoVar
	bsr	FnExpentier
	bsr	FnExpentier
	bsr	FnExpentier
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	bsr	AdToA0
	move.l	(sp)+,a6
	move.w	#L_Add4,d0
	bra	CreFonc

******* Instruction finie??
Finie:	bsr	GetWord
FinieB:	beq.s	Finy
	cmp.w	#TkDP-Tk,d0
	beq.s	Finy
	cmp.w	#TkThen-Tk,d0
	beq.s	Finy
	cmp.w	#TkElse-Tk,d0
Finy:	rts

******* Appel de la routine de test
CTests	tst.w	Flag_NoTests(a5)
	bne.s	.skip
	move.w	#L_Tests,d0
	bsr	CreFonc
.skip	rts

******* =PARAM
CparamE	moveq	#0,d2
	move.l	CdParE(pc),d0
	bra	OutLong
CparamF	moveq	#1,d2
	bset	#0,Flag_Math(a5)
	move.l	CdParF(pc),d0
	bra	OutLong
CparamC	moveq	#2,d2
	move.l	CdParS(pc),d0
	bra	OutLong

******* FOLLOW
CFollow	bsr	Finie
	subq.l	#2,a6
	beq.s	CFol3
CFol1	bsr	Evalue
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CFol1
CFol2	subq.l	#2,a6
CFol3	rts

******* VARPTR
CVarptr	addq.l	#4,a6
	bsr	VarAdr
	bsr	AdToA0
	addq.l	#2,a6
	and.w	#$F,d2
	subq.w	#1,d2
	bhi.s	CVpt1
	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
	moveq	#0,d2
	rts
CVpt1	lea	CVpt2(pc),a0
	bsr	OutCode
	moveq	#0,d2
	rts
CVpt2	move.l	(a0),-(a3)
	addq.l	#2,(a3)
	dc.w	$4321

******* DATA
CData	addq.l	#2,a6
	move.l	CBra(pc),d0
	bsr	OutLong
	move.l	a4,-(sp)
	tst.l	A_Datas(a5)
	bne.s	CDt1
	move.l	a4,A_Datas(a5)
	bra.s	CDt2
CDt1	move.l	a4,-(sp)
	move.l	a4,d0
	move.l	A_JDatas(a5),a4
	bsr	OutLong
	move.l	(sp)+,a4
CDt2	move.w	CNop(pc),d0		* Signal-> DATAS!
	bsr	OutWord
	bsr	Evalue
	move.w	Cmvqd2(pc),d0
	and.w	#$000F,d2
	move.b	d2,d0
	bsr	OutWord
	move.w	Cleaa2(pc),d0
	bsr	OutWord
	bsr	RelJsr
	move.l	a4,A_JDatas(a5)
	move.l	A_EDatas(a5),d0
	bsr	OutLong
	move.w	CRts(pc),d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CDt1
	subq.l	#2,a6
* Met le BRA
	move.l	a4,d0
	move.l	(sp),a4
	move.l	d0,(sp)
	subq.l	#2,a4
	sub.l	a4,d0
	bsr	OutWord
	move.l	(sp)+,a4
	rts
CdDNul	clr.l	-(a3)
	moveq	#-1,d2
	rts
	dc.w	$4321

******* Cree la routine NO DATA
CreNoData
	tst.l	A_EDatas(a5)
	bne.s	CnDtX
	move.l	a4,A_EDatas(a5)
	addq.l	#2,A_EDatas(a5)
	lea	Cd0Data(pc),a0
	bsr	OutCode
CnDtX	rts
Cd0Data	bra.s	Cd1Data
	moveq	#-1,d0
	moveq	#-1,d2
	rts
Cd1Data	dc.w	$4321

******* RESTORE
CRest	bsr	OutLea
	move.w	#L_Rest0,d1
	bsr	Finie
	subq.l	#2,a6
	beq.s	CRest1
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_Rest1,d1
CRest1	move.w	d1,d0
	bra	CreFonc

******* READ
CRead	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdToA0
	and.w	#$000F,d2
	move.w	#L_ReadE,d0
	subq.b	#1,d2
	bmi.s	Cread1
	addq.w	#1,d0
	tst.b	d2
	beq.s	Cread1
	addq.w	#1,d0
Cread1	bsr	CreFonc
	bsr	GetWord
	cmp.w	#TkVir-TK,d0
	beq.s	Cread
	subq.l	#2,a6
	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; CHAINES / TEXTE
;---------------------------------------------------------------------

;------> MID en fonction
CFLeft	move.w	#L_FLeft,d1
	bra	FStand
CFRight	move.w	#L_FRight,d1
	bra	FStand
CFMid2	move.w	#L_FMid2,d1
	bra	FStand
CFMid3	move.w	#L_FMid3,d1
	bra	FStand
;------> MID en instruction
CIMid3	move.w	#L_IMid3,-(sp)
	bra.s	CIMid
CIMid2	move.w	#L_IMid2,-(sp)
	bra.s	CIMid
CILeft	move.w	#L_ILeft,-(sp)
	bra.s	CIMid
CIRight	move.w	#L_IRight,-(sp)
CIMid	bsr	OutLea
	addq.l	#4,a6
	move.l	a6,-(sp)
	bsr	SoVar
	addq.l	#2,a6
	bsr	Expentier
	cmp.w	#L_IMid3,4(sp)
	bne.s	CIMd
	addq.l	#2,a6
	bsr	Expentier
CIMd	addq.l	#2,a6
	bsr	Evalue
	move.l	a6,d0
	move.l	(sp)+,a6
	move.l	d0,-(sp)
	bsr	VarAdr
	bsr	AdToA0
	move.l	(sp)+,a6
	move.w	(sp)+,d0
	bra	CreFonc
;------> =STR$(n)
CStr	bsr	FnEval
	moveq	#L_StrE,d0
	move.w	d2,d1
	moveq	#2,d2
	subq.w	#1,d1
	bmi	CreFonc
	moveq	#L_StrF,d0
	bra	CreFonc
;------> =VAL(a$)
CVal	bsr	FnEval
	moveq	#L_Val,d0
	moveq	#0,d2
	btst	#0,Flag_Math(a5)
	beq	CreFonc
	moveq	#1,d2
	bra	CreFonc

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Boucles/Structure
;---------------------------------------------------------------------

******* REMs
CRem	subq.w	#1,NbInstr(a5)
	bsr	GetWord
	add.w	d0,a6
	rts

;----------------------> TRAITEMENT DES ERREURS
OutLea	move.l	CLeapca4(pc),d0
	bra	OutLong

;----------------------> PROCEDURES

******* Codage / Decodage procedure LOCKEE
*	A6---> "PROC"
ProCode	movem.l	d0-d7/a0-a6,-(sp)
	move.l	2(a6),d0
	lea	10+2+4(a6,d0.l),a2	* A2---> ENDPROC
	move.w	-2(a6),d0
	lsr.w	#8,d0
	lsl.w	#1,d0
	lea	-2(a6,d0.w),a1		* A1---> Ligne suivante
	move.l	2(a6),d5
	rol.l	#8,d5
	move.b	9(a6),d5
	moveq	#1,d4
	move.w	6(a6),d3
	bra.s	PrCo2
PrCo1	eor.w	d5,(a0)+
	add.w	d4,d5
	add.w	d3,d4
	ror.l	#1,d5
	cmp.l	a0,a1
	bne.s	PrCo1
PrCo2	move.l	a1,a0
	move.w	(a0)+,d0
	lsr.w	#8,d0
	lsl.w	#1,d0
	lea	-2(a0,d0.w),a1
	addq.l	#2,a0
	cmp.l	a0,a2
	bne.s	PrCo1
* Change le flag
	bchg	#5,8(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

******* Debut de procedure, premiere exploration
CProc	subq.w	#1,NbInstr(a5)
* Decode la procedure si codee...
	move.l	a6,-(sp)
	addq.l	#6,a6
	bsr	GetWord
	btst	#6+8,d0
	beq.s	VPr0
	btst	#5+8,d0
	beq.s	VPr0
	tst.w	Flag_Source(a5)
	bne	NoCode
	move.l	(sp),a6
	subq.l	#2,a6
	add.l	B_Source(a5),a6
	bsr	ProCode
VPr0	move.l	(sp)+,a6
* Stocke le label et les types
	bsr	GetLong
	subq.l	#4,a6
	pea	8(a6,d0.l)
	pea	(a6)
	lea	8+2(a6),a6
	moveq	#-1,d7
	bsr	RLabel
	move.l	(sp)+,d0
	bset	#30,d0
	move.l	d0,2(a2)
	move.l	(sp)+,a6
	rts

******* Proc
CPrc
	addq.l	#2,a6
******* Appel de procedure
CDoPro
	bsr	OutLea
	subq.l	#2,a6
	move.l	a6,-(sp)
	bsr	StockOut
	moveq	#-1,d7
	bsr	GetLabel
	bsr	RestOut
	moveq	#0,d7
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkBra1-Tk,d0
	bne.s	CDop3
	addq.l	#2,a6
CDop1	lsl.l	#1,d7
	move.l	d7,-(sp)
	bsr	Evalue
	move.l	(sp)+,d7
	cmp.b	#1,d2
	bne.s	CDop2
	bset	#0,d7
CDop2	bsr	GetWord
	cmp.w	#TkBra2-Tk,d0
	bne.s	CDop1
CDop3	move.l	a6,d0
	move.l	(sp),a6
	move.l	d0,(sp)
	move.l	d7,-(sp)
	moveq	#-1,d7
	bsr	GetLabel
	lea	CdDop(pc),a0
	move.w	(a0)+,d0
	bsr	OutWord
	addq.l	#4,a0
	move.l	(sp)+,d0
	bsr	OutLong
	bsr	OutCode
	move.l	(sp)+,a6
	rts
CdDop	move.l	#0,d6
	jsr	(a0)
	dc.w	$4321
******* POP PROC
CPopP	moveq	#L_FProc,d0
	bra	CreJmp

;----------------------> FOR / TO / NEXT
CFor
	bsr	OutLea
; Prend et egalise la variable
	bsr	GetWord		; Teste?
	beq	Synt
	pea	-2(a6,d0.w)	; Adresse du NEXT
	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	StockOut	; Saute la variable
        bsr 	IVarBis
	bsr	RestOut
	and.w	#$0F,d2
        move.w 	d2,-(sp)        ; Sauve le type
; Compile le TO
	addq.l	#2,a6
        bsr 	Evalue
        move.w 	(sp),d1
        bsr 	EqType 	        ; Egalise les types
; Compile le STEP
	move.w	#-1,Flag_Const(a5)
	bsr 	GetWord
        subq.l 	#2,a6
	cmp.w	#TkStp-Tk,d0
	bne.s	CFor3
        addq.l 	#2,a6
        bsr 	Evalue          ; va chercher le STEP
        bra.s 	CFor4
CFor3	lea 	ForCd1(pc),a0
        bsr 	OutCode
	moveq	#1,d3
        moveq	#0,d2
CFor4	move.w 	(sp),d1
        bsr 	EqType          ; Egalise les type TO / STEP
	move.l	d3,-(sp)
; Compile la variable
	move.l	4+2(sp),d0
	move.l	a6,4+2(sp)
	move.l	d0,a6
	bsr	IVarBis
	bsr	AdToA0
	move.l	4+2(sp),a6
; Adresse des adresses
	move.w	M_ForNext(a5),d1
	lea	forcd2(pc),a0
	bsr	RForNxt
	bsr	OutCode
; Fonction de demarrage de la boucle
	moveq	#0,d7
	tst.w	Flag_Const(a5)
	beq.s	CForPaR
	tst.w	4(sp)
	bne.s	CForPar
	moveq	#-1,d7
CForPaR
; Poke les tables du compilateur
        move.l 	A_Bcles(a5),a1
	move.w	d7,(a1)+		; 0  Flag rapide
	move.w	4(sp),(a1)+		; 2  Type
	move.l	(sp),(a1)+		; 4  Step
	move.l	a4,(a1)+		; 8  -6 Adresse dans le programme
	move.w	M_ForNext(a5),(a1)+	; 12 Position de la boucle
	move.w	#16,(a1)+		; 14 -2 Taille FOR/NEXT
        move.l 	a1,A_Bcles(a5)
; Un FOR/NEXT de plus!
	add.w	#12,M_ForNext(a5)
        addq.w 	#1,N_Bcles(a5)
	lea	14(sp),sp
	rts
forcd1: move.l 	#$1,-(a3)
        dc.w 	$4321
forcd2:	move.l	AForNext(a5),a2
	lea	0(a2),a2
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	a0,(a2)
	dc.w	$4321

;-----------------------------------> NEXT
CNext:
	bsr	OutLea
	bsr	CTests
; Saute la variable
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkVar-Tk,d0
	bne.s	CNx0
	addq.l	#2,a6
	bsr	SoVar
; Depile la boucle
CNx0	move.l	A_Bcles(a5),a1
	sub.w	-2(a1),a1
	move.w	12(a1),d1		* P_FORNEXT
	tst.w	(a1)
	beq.s	CNx2
; Une boucle "rapide"
	lea	CdNx(pc),a0
	bsr	RForNxt
	bsr	OutCode
	move.w	CBgtS(pc),d7
	swap	d7
	move.w	CBle(pc),d7
	tst.l	4(a1)
	bmi.s	CNx1
	move.w	CBltS(pc),d7
	swap	d7
	move.w	CBge(pc),d7
CNx1	moveq	#0,d5
	move.l	8(a1),d6
	bsr	DoTest
	bra.s	CNxX
* Boucle lente
CNx2	lea	CdNx(pc),a0
	bsr	RForNxt
	move.w	CLeaa1(pc),d7
	swap	d7
	move.w	CLeapca1(pc),d7
	move.l	8(a1),d6
	moveq	#0,d5
	bsr	DoLea
	moveq	#L_NextE,d0
	tst.w	2(a1)
	beq.s	CNx6
	moveq	#L_NextF,d0
CNx6	bsr	CreFonc
* Fin de la boucle
CNxX	bra	UnPile
; Routine
RForNxt	move.l	(a0)+,d0
	bsr	OutLong
	tst.w	d1
	beq.s	.Skip1
	move.w	(a0),d0
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
.Skip1	addq.l	#4,a0
	rts
; Code RAPIDE
CdNx	move.l	AForNext(a5),a2
	lea	0(a2),a2
	move.l	(a2)+,d0
	move.l	(a2)+,d1
	move.l	(a2),a2
	add.l	d0,(a2)
	cmp.l	(a2),d1
	dc.w	$4321

;------------------------------> REPEAT / UNTIL
CDo
CRepeat	move.l	A_Bcles(a5),a1
	move.l	a4,(a1)+		; 0  6 Adresse boucle
	bsr	GetWord
	beq	Synt
	lea	-2(a6,d0.w),a0
	move.w	#6,(a1)+
	move.l	a1,A_Bcles(a5)
	addq.w	#1,N_Bcles(a5)
	rts
CUntil
	bsr	OutLea
	bsr	CTests
	bsr	Evalue
	lea	CdUntil(pc),a0
	bsr	OutCode
	move.l	A_Bcles(a5),a1
	move.w	CBne8(pc),d7
	swap	d7
	move.w	CBeq(pc),d7
	move.l	-6(a1),d6
	moveq	#0,d5
	bsr	DoTest
	bra	UnPile
CdWhile
CdUntil	tst.l	(a3)+
	dc.w	$4321

;------------------------------> LOOP
CLoop
	bsr	OutLea
	bsr	CTests
	moveq	#0,d5
	move.l	A_Bcles(a5),a1
	move.l	-6(a1),d6
	bsr	DoBra
	bra	UnPile

;------------------------------> WHILE / WEND
CWhile
	bsr	GetWord
	beq	Synt
; Retour du WEND
	move.l	A_Bcles(a5),a1
	move.l	a6,(a1)+
	move.w	CJmp(pc),d0
	bsr	OutWord
	bsr	RelJsr
	addq.l	#4,a4
	move.l	a4,(a1)+
	move.w	#10,(a1)+
	move.l	a1,A_Bcles(a5)
	addq.w	#1,N_Bcles(a5)
; Saute l'expression
	bsr	StockOut
	bsr	Evalue
	bsr	RestOut
	rts

CWend
	bsr	OutLea
	bsr	CTests
	move.l	A_Bcles(a5),a1
; Reloge le JMP du debut
	move.l	a4,-(sp)
	move.l	a4,d0
	move.l	-6(a1),a4
	subq.l	#4,a4
	bsr	OutLong
	move.l	(sp)+,a4
; Evalue l'expression
	movem.l	a1/a6,-(sp)
	move.l	-10(a1),a6
	bsr	Expentier
	movem.l	(sp)+,a1/a6
	move.w	Ctsta3p(pc),d0
	bsr	OutWord
; Met le branchement
	moveq	#0,d5
	move.l	-6(a1),d6
	move.w	CBeq8(pc),d7
	swap	d7
	move.w	CBne(pc),d7
	bsr	DoTest
	bra	UnPile

;------------------------------> EXIT / EXIT IF
CExitIf
	bsr	OutLea
	bsr	GetWord
	move.w	d0,d1
	beq	Synt
	bsr	GetWord
	beq	Synt
	pea	0(a6,d1.w)
	bsr	Expentier
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkVir-Tk,d0
	bne.s	CEIf0
	addq.l	#2+6,a6
CEIf0	move.w	Ctsta3p(pc),d0
	bsr	OutWord
	move.l	(sp)+,d5
	moveq	#0,d6
	move.w	Cbeq8(pc),d7
	swap	d7
	move.w	Cbne(pc),d7
	bsr	DoTest
	rts
CExit
	bsr	GetWord
	move.w	d0,d1
	beq	Synt
	bsr	GetWord
	beq	Synt
	lea	0(a6,d1.w),a0
	move.l	a0,d5
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkEnt-Tk,d0
	bne.s	Cexi1
	addq.l	#6,a6
Cexi1	moveq	#0,d6
	bsr	DoBra
	rts

;------------------------------> IF / THEN / ELSE
CIf
	bsr	OutLea
	bsr	GetWord
	beq	Synt
	pea	0(a6,d0.w)
	bsr	Expentier
CIf0
	move.w	Ctsta3p(pc),d0
	bsr	OutWord
	move.l	(sp)+,d5
	moveq	#0,d6
	move.w	CBne8(pc),d7
	swap	d7
	move.w	CBeq(pc),d7
	bsr	DoTest
	rts

CElse
	bsr	GetWord
	beq	Synt
	lea	0(a6,d0.w),a0
	move.l	a0,d5
	moveq	#0,d6
	bsr	DoBra
	rts

******* DEUX POINTS
CIDP	subq.w	#1,NbInstr(a5)
CINop	rts

;-------------------------------------> GOTO / LABELS

;-----> LABEL:
CLabel
	move.w	N_Proc(a5),d7
	bsr	RLabel
	tst.l	2(a2)
	bpl	Synt
	move.l	a4,2(a2)
	rts

;-----> GOTO
CLGoto
	subq.l	#2,a6
CGoto
	bsr	OutLea
	bsr	CTests
	move.w	N_Proc(a5),d7
	bsr	GetLabel
CGoto1	move.w	Cjmpa0(pc),d0
	bra	OutWord
;-----> THEN ligne
CGoto2
	bsr	OutLea
	bsr	CTests
	bsr	CGlab1
	bra.s	CGoto1

;-----> EVERY n GOSUB / PROC
CEvery
	bsr	Expentier
	bsr	GetWord
	cmp.w	#TkPrc-Tk,d0
	beq.s	CEv1
; Every GOSUB
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_EvGosub,d0
	bra	CreFonc
; Every PROC
CEv1	moveq	#-1,d7
	bsr	GetLabel
	move.w	#L_EvProc,d0
	bra	CreFonc

;-----> GOSUB
CGosub
	bsr	OutLea
	bsr	CTests
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	lea	CdGsb(pc),a0
	bra	OutCode
CdGsb:	lea	-4(sp),a1
	move.l	a1,LowPile(a5)
	jsr	(a0)
	dc.w	$4321
;-----> RETURN
CReturn
	bsr	OutLea
	bsr	CTests
	moveq	#L_Return,d0
	bra	CreJmp
;-----> POP
CPop
	bsr	OutLea
	bsr	CTests
	moveq	#L_Pop,d0
	bra	CreFonc

;-----> ON exp GOTO / GOSUB
COn
	bsr	OutLea
	bsr	CTests
	bsr	GetWord
	beq	Synt
	lea	2(a6,d0.w),a1
	bsr	GetWord
	move.w	d0,-(sp)
	beq	Synt
	move.l	a1,-(sp)
	bsr	Expentier
	bsr	GetWord
	move.w	d0,-(sp)
	lea	CdOn(pc),a0
	move.w	(a0)+,d0
	move.b	6+1(sp),d0
	bsr	OutWord
	bsr	OutCode
	move.w	N_Proc(a5),d7
	move.w	(sp)+,d0
	cmp.w	#TkGsb-Tk,d0
	beq.s	COn1
	cmp.w	#TkPrc-Tk,d0
	beq.s	COnP
; On...Goto
	move.w	Cjmpa0(pc),d0
	bra.s	COnP1
; On...Gosub
COn1	lea	CdGsb(pc),a0
	bsr	OutCode
	bra.s	COn2
; On...Proc
COnP	moveq	#-1,d7
	move.w	Cjsra0(pc),d0
COnP1	bsr	OutWord
	move.w	CNop(pc),d0
	bsr	OutWord
	bsr	OutWord
	bsr	OutWord
	bsr	OutWord
; Bra final
COn2	move.w	CBra(pc),d0
	move.l	a4,d4
	move.l	(sp)+,d5
	bsr	OutWord
	addq.l	#2,a4
	bsr	MarkAd
; Met les labels
	move.w	(sp),d0
	move.l	a4,-(sp)
	move.l	a4,-(sp)
	lsl.w	#1,d0
	add.w	d0,a4
COn3	move.l	a4,d0
	move.l	a4,d4
	move.l	(sp),a4
	sub.l	4(sp),d0
	bsr	OutWord
	addq.l	#2,(sp)
	move.l	d4,a4
	bsr	GetLabel
	move.w	CRts(pc),d0
	bsr	OutWord
	addq.l	#2,a6
	subq.w	#1,8(sp)
	bne.s	COn3
; Ouf!
	subq.l	#2,a6
	lea	10(sp),sp
	rts
CdOn	moveq	#0,d1
	move.l	(a3)+,d0
	beq.s	CdOn1+10
	cmp.l	d1,d0
	bhi.s	CdOn1+10
	lsl.w	#1,d0
	move.w	CdOn1+10+4-2(pc,d0.w),d0
	jsr	CdOn1+10+4(pc,d0.w)
CdOn1	dc.w	$4321


******* ON ERROR
COnErr	bsr	OutLea
	move.w	#L_OnErr0,d1
	bsr	GetWord
	cmp.w	#TkPrc-Tk,d0
	beq.s	CerP
	cmp.w	#TkGto-Tk,d0
	bne.s	Cer0
* On error GOTO
	move.l	a6,-(sp)
	bsr	GetWord
	cmp.w	#TkEnt-Tk,d0
	bne.s	CerG
	bsr	GetLong
	tst.l	d0
	bne.s	CerG
	addq.l	#4,sp
	bra.s	Cer1
CerG	move.l	(sp)+,a6
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_OnErr1,d0
	bra	CreFonc
* On error PROC
CerP	moveq	#-1,d7
	bsr	GetLabel
	move.w	#L_OnErr2,d0
	bra	CreFonc
* On error RIEN
Cer0	subq.l	#2,a6
Cer1	move.w	#L_OnErr0,d0
	bra	CreFonc

******* RESUME
CRes	bsr	OutLea
	bsr	Finie
	subq.l	#2,a6
	beq.s	CRes0
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_Res1,d0
	bra	CreJmp
CRes0	move.w	#L_Res0,d0
	bra	CreJmp

******* RESUME LABEL
CResL	bsr	OutLea
	bsr	Finie
	subq.l	#2,a6
	beq.s	CResl0
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_Resl1,d0
	bra	CreFonc
Cresl0	move.w	#L_Resl0,d0
	bra	CreFonc

* ROUTINE -> adresse d'un label
* OUT >>> lea label,a0
* Retour VRAI si FIXE / FAUX si variable
GetLabel
	bsr	GetWord
	cmp.w	#TkLGo-Tk,d0
	beq	Cglab1
	cmp.w	#TkPro-Tk,d0
	beq	Cglab1
; Expression
	subq.w	#2,a6
	addq.w	#1,Flag_Labels(a5)		; Copier la table!
	move.w	#-1,Flag_Const(a5)
	bsr	StockOut
	move.w	d7,-(sp)
	bsr	Evalue
	move.w	(sp)+,d7
	moveq	#L_GetLabA,d1
	cmp.b	#2,d2
	beq	Glab0a
	tst.b	d2
	beq.s	Glab0
	bsr	FlToInt
Glab0	moveq	#L_GetLabE,d1
	tst.w	Flag_Const(a5)
	bne.s	Clab0b
; Expression variable!
Glab0a	bsr	SautOut
	move.w	Cmviwd6(pc),d0
	bsr	OutWord
	move.w	N_Proc(a5),d0
	bsr	OutWord
	move.w	d1,d0
	bra	CreFonc
; Numero de ligne FIXE
Clab0b	subq.w	#1,Flag_Labels(a5)
	bsr	RestOut
	move.l	d3,d0
	moveq	#-1,d3
	moveq	#0,d4
	move.l	B_Work(a5),a2
	move.l	a2,a0
	bsr	HexToAsc
	move.l	a0,a1
	move.l	a1,d6
	btst	#0,d6
	beq.s	Clab0c
	clr.b	(a1)+
	addq.l	#1,d6
Clab0c	sub.l	a2,d6
	move.w	d6,d5
	lsr.w	#1,d5
	bsr	CLabBis
	bra.s	Cglab0
; Label simple
Cglab1	bsr	RLabel
Cglab0	move.w	CLeaa0(pc),d0
	bsr	OutWord
	bsr	RelJsr
	move.l	a2,d0
	bset	#BitLabel,d0
	bra	OutLong

* ROUTINE -> Trouve / Cree / Saute le label (a6)
* Entree D7=	Numero procedure
* Retour A2=	Label
RLabel
	addq.l	#2,a6
	moveq	#0,d0
	bsr	GetWord
	lsr.w	#8,d0
	move.w	d0,d6
	lsr.w	#1,d0
	move.w	d0,d5
	move.w	d0,d1
	move.l	B_Work(a5),a1
CLab1	bsr	GetWord
	move.w	d0,(a1)+
	subq.b	#1,d1
	bne.s	CLab1
CLabBis	move.w	d7,(a1)+
	addq.w	#2,d6
*	addq.w	#1,d5		Pour DBRA!
; Recherche dans la table
	move.l	B_Labels(a5),a2
	moveq	#-6,d1
CLab3	lea	6(a2,d1.w),a2
	move.w	(a2),d1
	beq.s	CLab5
	cmp.w	d6,d1
	bne.s	CLab3
	move.l	B_Work(a5),a0
	lea	6(a2),a1
	move.w	d5,d0
CLab4	cmp.w	(a0)+,(a1)+
	bne.s	CLab3
	dbra	d0,CLab4
	rts
; Cree le nouveau
CLab5	move.w	d6,(a2)
	move.l	a6,d0
	bset	#31,d0
	move.l	d0,2(a2)
	move.l	B_Work(a5),a0
	lea	6(a2),a1
CLab6	move.w	(a0)+,(a1)+
	dbra	d5,CLab6
	lea	6(a2,d6.w),a0
	clr.w	(a0)
	rts

* ROUTINE -> Conversion HEX- > DEC
HexToAsc
	tst.l 	d0
        bpl.s	Chexy
        move.b 	#"-",(a0)+
        neg.l 	d0
        bra.s 	Chexz
Chexy:  tst 	d4
        beq.s 	Chexz
        move.b 	#32,(a0)+
Chexz:  tst.l 	d3
        bmi.s 	Chexv
        neg.l 	d3
        add.l 	#10,d3
Chexv:  move.l 	#9,d4
        lea 	Cmdx(pc),a1
Chxx0:  move.l 	(a1)+,d1     ;table des multiples de dix
        move.b 	#$ff,d2
Chxx1:  addq.b 	#1,d2
        sub.l 	d1,d0
        bcc.s 	Chxx1
        add.l 	d1,d0
        tst.l 	d3
        beq.s 	Chxx4
        bpl.s 	Chxx3
        btst 	#31,d4
        bne.s 	Chxx4
        tst 	d4
        beq.s 	Chxx4
        tst.b 	d2
        beq.s 	Chxx5
        bset 	#31,d4
        bra.s 	Chxx4
Chxx3:  subq.l 	#1,d3
        bra.s 	Chxx5
Chxx4:  add 	#48,d2
        move.b 	d2,(a0)+
Chxx5:  dbra 	d4,Chxx0
        rts
Cmdx:   dc.l 	1000000000,100000000,10000000,1000000
        dc.l 	100000,10000,1000,100,10,1,0

* ROUTINE -> BRA/JMP
* D5= adresse en AVANT
* D6= adresse en ARRIERE
DoBra	move.w	CJmp(pc),d7
	swap	d7
	move.w	CBra(pc),d7
* Entree pour LEA / LEA (pc)
DoLea	tst.l	d5
	bne.s	DBr2
* En arriere!
	move.l	d6,d1
	sub.l	a4,d1
	subq.l	#2,d1
	cmp.l	#32764,d1
	bge.s	Dbr1
	cmp.l	#-32764,d1
	ble.s	DBr1
; Ok, en SHORT!
DBr0	move.w	d7,d0
	bsr	OutWord
	move.w	d1,d0
	bra	OutWord
; En LONG!
Dbr1	swap	d7
	move.w	d7,d0
	bsr	OutWord
	bsr	RelJsr
	move.l	d6,d0
	bra	OutLong
* En avant!
Dbr2	move.l	a4,d4
	tst.w	Flag_Long(a5)
	bne.s	DBr3
; En short
Dbr4	move.w	d7,d0
	bsr	OutWord
	addq.l	#2,a4
	bra.s	MarkAd
; En long
Dbr3	bset	#31,d4
	swap	d7
	move.w	d7,d0
	bsr	OutWord
	bsr	RelJsr
	addq.l	#4,a4
	bra.s	MarkAd

* ROUTINE -> TEST ET BRANCHEMENT
* D5= adresse en AVANT
* D6= adresse en ARRIERE
DoTest	tst.l	d5
	bne.s	DTst2
* En arriere!
	move.l	d6,d1
	sub.l	a4,d1
	subq.l	#2,d1
	cmp.l	#32764,d1
	bge.s	Dtst1
	cmp.l	#-32764,d1
	bge.s	Dbr0
; En LONG!
Dtst1	swap	d7
	move.w	d7,d0
	bsr	OutWord
	move.w	CJmp(pc),d0
	bsr	OutWord
	bsr	RelJsr
	move.l	d6,d0
	bra	OutLong
* En Avant!
DTst2	move.l	a4,d4
	tst.w	Flag_Long(a5)
	beq.s	DBr4
; En long!
	bset	#31,d4
	addq.l	#2,d4
	swap	d7
	move.w	d7,d0
	bsr	OutWord
	move.w	CJmp(pc),d0
	bsr	OutWord
	bsr	RelJsr
	addq.l	#4,a4

* Marque la table des branch forward
MarkAd
	movem.l	a0/a1,-(sp)
	move.l	B_Lea(a5),a0
MAd1	cmp.l	(a0),d5
	addq.l	#8,a0
	bcc.s	MAd1
	subq.l	#8,a0
; Fait une place
	move.l	A_Lea(a5),a1
MAd2	move.l	(a1),8(a1)
	move.l	4(a1),12(a1)
	subq.l	#8,a1
	cmp.l	a0,a1
	bcc.s	MAd2
; Poke le nouveau
	move.l	d5,(a0)+
	move.l	d4,(a0)
	addq.l	#8,A_Lea(a5)
	movem.l	(sp)+,a0/a1
	rts
* ROUTINE -> Poke l'adresse d'une ligne
PokeAd	move.l	a4,-(sp)
	move.l	a4,d0
	move.l	B_Lea(a5),a2
	move.l	4(a2),d1
	bmi.s	JAbs
; Branchement (pc)
	addq.l	#2,d1
	move.l	d1,a4
	sub.l	d1,d0
	cmp.l	#32764,d0
	bgt	ErrDoLong
	cmp.l	#-32764,d0
	blt	ErrDoLong
	bsr	OutWord
; Enleve de la table
ETable	move.l	A_Lea(a5),a1
PAd1	move.l	8(a2),(a2)+
	move.l	8(a2),(a2)+
	cmp.l	a1,a2
	bcs.s	PAd1
	subq.l	#8,A_Lea(a5)
	move.l	(sp)+,a4
	rts
; Branchement absolu
JAbs	bclr	#31,d1
	addq.l	#2,d1
	move.l	d1,a4
	bsr	OutLong
	bra.s	ETable
* ROUTINE -> Depile une boucle -> A1
UnPile	move.l	A_Bcles(a5),a1
	sub.w	-2(a1),a1
	move.l	a1,A_Bcles(a5)
	subq.w	#1,N_Bcles(a5)
	rts

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; Entree / Sortie
;---------------------------------------------------------------------

Lp1	lea	Lp1(pc),a4	 	; Debut expression
	dc.w	$4321

;-----> LPRINT
CLPrnt: move.w	#1,-(sp)
	bra.s	Cp2
;-----> PRINT #
CHPrnt	move.w	#-1,-(sp)
	bsr	Expentier
	addq.l	#2,a6
	move.w	#L_HPrintD,d0
	bsr	CreFonc
	bra.s	Cp2
;-----> PRINT
CPrnt:  clr.w	-(sp)
; Prend les expressions
Cp2   	bsr	Finie
	bne.s	Cp3
	subq.l	#2,a6
	moveq	#L_CRPrint,d0
	bsr	CreFonc
	bra	Cp13
Cp3	lea	Lp1(pc),a0
	bsr	OutCode
* USING: prend la chaine et marque le using
	clr.w	-(sp)
	cmp.w 	#TkUsing-Tk,d0
	bne.s 	Cp4
	subq.w	#1,(sp)
	bsr	Evalue
	addq.l	#4,a6
	cmp.b	#2,d2
	bne	Synt
; Prend l'expression
Cp4     subq.l	#2,a6
	bsr 	Evalue
        subq.w	#1,d2
	bmi.s	Cp5
	beq.s	Cp6
* Chaine
	tst.w	(sp)+
	bne.s	Cp4a
	moveq	#L_PrintS,d0		; Pas using
	tst.w	(sp)
	beq.s	Cp7a
	moveq	#L_PrintS,d0		; ILLEGAL!!
	tst.w	(sp)
	bpl.s	Cp7a
	move.w	#L_HPrintS,d0
	bra.s	Cp7a
cp4a	moveq	#L_UsingS,d0		; Using
	bra.s	Cp7a
* Entier
cp5	bclr	#6,2(sp)
	move.w	#L_PrintE,d0
	bsr	CreFonc
	moveq	#L_UsingC,d0
        bra.s 	Cp7
* Float
cp6	bset	#0,Flag_Math(a5)
	bclr	#6,2(sp)
	moveq	#L_PrintF,d0
	bsr	CreFonc
	moveq	#L_UsingC,d0
Cp7:    and.w	(sp)+,d0
	beq.s	Cp7b
Cp7a	bsr 	CreFonc
Cp7b
; Prend le separateur
Cp8:    bsr 	GetWord
	cmp.w 	#TkPVir-Tk,d0
        beq.s 	Cp13
	bclr	#6,(sp)
        cmp.w	#TkVir-Tk,d0
        beq.s 	Cp11
        subq.l 	#2,a6
	moveq 	#L_PrtRet,d0
        bra.s 	Cp12
Cp11:   moveq 	#L_PrtVir,d0
Cp12:   bsr 	CreFonc

; Imprime!
Cp13	moveq	#L_PrintX,d0
	tst.w	(sp)
	beq.s	Cp14
	moveq	#L_LPrintX,d0
	tst.w	(sp)
	bpl.s	Cp14
	bset	#6,(sp)
	bne.s	Cp15
	move.w	#L_HPrintX,d0
Cp14	bsr	CreFonc
Cp15
* Encore quelque chose a imprimer?
	bsr 	Finie
        bne	Cp3

* Termine!
	subq.l	#2,a6
	tst.w	(sp)+
	rts

;----------------------------------> INPUT #
CInputH
	move.w	#-1,-(sp)
	move.w	#L_InputH,-(sp)
	bra.s	CIn0
;----------------------------------> INPUT #
CLInputH
	move.w	#-1,-(sp)
	move.w	#L_LInputH,-(sp)
CIn0	bsr	OutLea
	bsr	Stockout
	move.l	a6,-(sp)
	bsr	Expentier
	bsr	RestOut
	addq.l	#2,a6
	bra.s	CIn7
;----------------------------------> LINE INPUT
CLInput clr.w	-(sp)
	move.w	#L_LInputC,-(sp)
        bra.s 	CIn1
;----------------------------------> INPUT
CInput  clr.w	-(sp)
	move.w	#L_InputC,-(sp)
CIn1:   bsr	OutLea
	bsr	GetWord
	subq.l	#2,a6
; Saute la chaine alphanumerique
	clr.l	-(sp)
	cmp.w	#TkVar-Tk,d0
	beq.s	CIn7
	move.l	a6,(sp)
	bsr	Stockout
	bsr	Evalue
	bsr	RestOut
	addq.l	#2,a6
* Stocke la liste des variable ---> -(A3) / moveq #NB,d6
CIn7:   clr.w 	-(sp)
CIn8:  	addq.l	#2,a6
	bsr 	VarAdr
	bsr	AdToA0
	and.w	#$000F,d2
	lea	CdInp(pc),a0
	move.w	(a0)+,d0
	bsr	OutWord
	move.w	d2,d0
	bsr	OutWord
	addq.l	#2,a0
	move.w	(a0)+,d0
	bsr	OutWord
        addq.w 	#1,(sp)
        bsr 	GetWord
        cmp.w	#TkVir-Tk,d0
        beq.s 	CIn8
CIn9:   subq.l 	#2,a6
******* Input clavier...
	tst.w	8(sp)
	bne.s	CIn11
; Evalue la chaine
	move.l	2(sp),d0
	bne.s	Cin10
	move.w	Cclrma3(pc),d0
	bsr	OutWord
	bra.s	CIn12
CIn10	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	Evalue
	move.l	2(sp),a6
	bra.s	CIn12
; Evalue le fichier
CIn11	move.l	2(sp),d0
	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	Expentier
	move.l	2(sp),a6
; Moveq nombre de params
CIn12	move.w 	cmvqd6(pc),d0
        move.w 	(sp)+,d1
        move.b 	d1,d0
        bsr 	Outword
	addq.l	#4,sp
; Appele la fonction
	move.w	(sp)+,d0
	bsr	CreFonc
; Un point virgule?
	tst.w	(sp)+
	bne	CInX
	bsr	GetWord
	cmp.w	#TkPVir-Tk,d0
	beq.s	CInX
	moveq	#L_CRet,d0
	bsr	CreFonc
	subq.l	#2,a6
CInX	rts

CdInp	move.w 	#$ffff,-(a3)
        move.l 	a0,-(a3)
        dc.w 	$4321


;-----> FIELD
CField	bsr	OutLea
	bsr	Stockout
	move.l	a6,-(sp)
	bsr	Expentier
	bsr	RestOut
	addq.l	#2,a6
	clr.w	-(sp)
Cfld1	addq.w	#1,(sp)
	bsr	Expentier
	addq.l	#4,a6
	bsr	VarAdr
	bsr	AdToA0
	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CFld1
	subq.l	#2,a6
; Handle fichier
	move.l	2(sp),d0
	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	Expentier
	move.l	2(sp),a6
; Nombre de champs
	move.w	Cmvqd0(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
; Appelle la fontion
	addq.l	#4,sp
	move.w	#L_Field,d0
	bra	CreFonc

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; ECRANS / GRAPHIQUES
;---------------------------------------------------------------------

*******	PALETTEs
CDPal	move.w	#L_DPal,-(sp)
	bra.s	CPal0
CPal	move.w	#L_Pal,-(sp)
CPal0 	bsr	OutLea
	clr.w	-(sp)
CPal1	addq.w	#1,(sp)
	bsr	Expentier
	bsr	GetWord
	cmp.w	#TKVir-Tk,d0
	beq.s	CPal1
	subq.l	#2,a6
	move.w	CMvqd0(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	(sp)+,d0
	bsr	CreFonc
	rts

******* FADE
CFade	bsr	OutLea
	bsr	Expentier
	bsr	GetWord
	move.w	#L_FadeN,-(sp)
	cmp.w	#TkVir-Tk,d0
	beq.s	CPal0
	cmp.w	#TkTo-Tk,d0
	beq.s	CFad1
	subq.l	#2,a6
	move.w	#L_Fade1,(sp)
	bra	CFadX
CFad1	move.w	#L_Fade2,(sp)
	bsr	Expentier
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkVir-Tk,d0
	bne.s	CFadX
	move.w	#L_Fade3,(sp)
	bsr	FnExpentier
CFadX	move.w	(sp)+,d0
	bra	CreFonc

******* POLYLINE / POLYGON
CPoLine	move.w	#L_Polyl,-(sp)
	bra.s	CPol
CPoGone	move.w	#L_Pogo,-(sp)
CPol	clr.l	-(sp)
	bsr	OutLea
	bsr	GetWord
	cmp.w	#TkTo-Tk,d0
	beq.s	CPol1
	subq.l	#2,a6
	move.w	#-1,2(sp)
	bsr	Expentier
	addq.l	#2,a6
	bsr	Expentier
	addq.w	#1,(sp)
	addq.l	#2,a6
CPol1	addq.w	#1,(sp)
	bsr	Expentier
	addq.l	#2,a6
	bsr	Expentier
	bsr	GetWord
	cmp.w	#TkTo-Tk,d0
	beq.s	CPol1
	subq.l	#2,a6
	move.w	Cmvqd0(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	CMvqd1(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	(sp)+,d0
	bra	CreFonc

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; MEMOIRE
;---------------------------------------------------------------------

******* BSET
CBset	move.w	#L_Bset,-(sp)
	bra.s	BsRout
CBclr	move.w	#L_Bclr,-(sp)
	bra.s	BsRout
CBchg	move.w	#L_Bchg,-(sp)
	bra.s	BsRout
CBtst	addq.l	#2,a6
	move.w	#L_BTst,-(sp)
	bra.s	BsRout
******* ROR / ROL
CRorb	move.w	#L_BRor,-(sp)
	bra.s	BsRout
CRorw	move.w	#L_WRor,-(sp)
	bra.s	BsRout
CRorl	move.w	#L_LRor,-(sp)
	bra.s	BsRout
CRolb	move.w	#L_BRol,-(sp)
	bra.s	BsRout
CRolw	move.w	#L_WRol,-(sp)
	bra.s	BsRout
CRoll	move.w	#L_LRol,-(sp)
******* Routine: ramene l'adresse a affecter!
BsRout	bsr	OutLea
	move.l	A_Stock(a5),-(sp)
	bsr	Expentier
	addq.l	#2,a6
	bsr	GetWord
	cmp.w	#TkVar-Tk,d0
	bne.s	BsR3
* Une variable
BsR1	bsr	StockOut
	move.l	a6,-(sp)
	bsr	VarAdr
	bsr	AdToA0
	bsr	Finie
	bne.s	BsR2
	subq.l	#2,a6
BsR0	addq.l	#4,sp
	bra.s	BsR4
BsR2	cmp.w	#TkPar2-Tk,d0
	beq.s	BsR0
	bsr	RestOut
	move.l	(sp)+,a6
* Une adresse
BsR3	addq.w	#1,4(sp)
	subq.l	#2,a6
	bsr	Expentier
* Fin...
BsR4	move.l	(sp)+,A_Stock(a5)
	move.w	(sp)+,d0
	bra	CreFonc

******* CALL
CCall	bsr	OutLea
	move.w	Cmva3msp(pc),d0
	bsr	OutWord
	move.l	a6,-(sp)
	bsr	StockOut
	bsr	Expentier
	bsr	RestOut
CCal0	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	bne.s	CCal1
	bsr	Evalue
	bra.s	CCal0
CCal1	move.l	(sp)+,d0
	pea	-2(a6)
	move.l	d0,a6
	bsr	Expentier
	move.l	(sp)+,a6
	move.w	#L_Call,d0
	bsr	CreFonc
	move.w	Cmvpspa3(pc),d0
	bra	OutWord

;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; BOB/SPRITES et autres
;---------------------------------------------------------------------

******* Channel
CChannel
	bsr	OutLea
	bsr	Expentier
	addq.l	#2,a6
	bsr	GetWord
	move.w	#L_ChaSpr,d1
	cmp.w	#TkSpr-Tk,d0
	beq.s	CChaX
	move.w	#L_ChaBob,d1
	cmp.w	#TkBob-Tk,d0
	beq.s	CChaX
	move.w	#L_ChaScD,d1
	cmp.w	#TkScD-Tk,d0
	beq.s	CChaX
	move.w	#L_ChaScO,d1
	cmp.w	#TkScO-Tk,d0
	beq.s	CChaX
	move.w	#L_ChaScS,d1
	cmp.w	#TkScS-Tk,d0
	beq.s	CChaX
	move.w	#L_ChaRain,d1
CChaX	move.w	d1,-(sp)
	bsr	Expentier
	move.w	(sp)+,d0
	bra	CreFonc


;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
; MENUS
;---------------------------------------------------------------------

;-----> MENU$(,,)=
CMenu	bsr	OutLea
	move.w	#L_Imen1-1,-(sp)
	bsr	MPar
	subq.l	#2,a4
	move.w	d1,-(sp)
	addq.l	#2,a6
CMenL	addq.w	#1,2(sp)
	bsr	Evalue
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	CMenL
	subq.l	#2,a6
	move.w	Cmvqd7(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	(sp)+,d0
	bra	CreFonc

;-----> MENU DEL
CMnDel	bsr	OutLea
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkPar1-Tk,d0
	beq.s	CMnD1
	move.w	#L_MnDl0,d0
	bra	CreFonc
CMnD1	bsr	MPar
	move.w	#L_MnDl1,d0
	bra	CreFonc

;-----> SET MENU
CSMenu	bsr	OutLea
	move.l	a6,-(sp)
	bsr	Stockout
	bsr	MPar
	bsr	Restout
	addq.l	#2,a6
	bsr	Expentier
	addq.l	#2,a6
	bsr	Expentier
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	MPar
	move.l	(sp)+,a6
	move.w	#L_SMen,d0
	bra	CreFonc

;-----> Instruction flags
CXMenu
	move.w	#L_XMen,d0
	bra.s	GoFlag
CYMenu
	move.w	#L_YMen,d0
	bra.s	GoFlag
CmnBar
	move.w	#L_MnBa,d0
	bra.s	GoFlag
Cmnline
	move.w	#L_MnLi,d0
	bra.s	GoFlag
Cmntline
	move.w	#L_Mntl,d0
	bra.s	GoFlag
Cmnmove
	move.w	#L_Mnmv,d0
	bra.s	GoFlag
Cmnsta
	move.w	#L_Mnst,d0
	bra.s	GoFlag
Cmnimove
	move.w	#L_mnimv,d0
	bra.s	GoFlag
Cmnista
	move.w	#L_mnist,d0
	bra.s	GoFlag
Cmnact
	move.w	#L_Mnact,d0
	bra.s	GoFlag
Cmninact
	move.w	#L_Mnina,d0
	bra.s	GoFlag
Cmnsep
	move.w	#L_Mnsep,d0
	bra.s	GoFlag
CMnlink
	move.w	#L_Mnlnk,d0
	bra.s	GoFlag
CMnCall
	move.w	#L_MnCl,d0
	bra.s	GoFlag
CMnOnce
	move.w	#L_Mnncl,d0
;
GoFlag	move.w	d0,-(sp)
	bsr	OutLea
	bsr	MPar
	move.w	(sp)+,d0
	bra	CreFonc

;-----> MENU KEY
CMnKey	bsr	OutLea
	move.l	a6,-(sp)
	bsr	Stockout
	bsr	MPar
	bsr	GetWord
	cmp.w	#TkTo-Tk,d0
	beq.s	CMnk1
* MENU KEY (,,) seul
	bsr	SautOut
	subq.l	#2,a6
	addq.l	#4,sp
	move.w	#L_MnKey0,d0
	bra	CreFonc
* MENU KEY (,,) TO
Cmnk1	bsr	RestOut
	move.w	#L_MnKey1,-(sp)
	bsr	Evalue
	cmp.b	#2,d2
	beq.s	Cmnk2
	bsr	DoEntier
	move.w	#L_MnKey2,(sp)
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#TkVir-Tk,d0
	bne.s	Cmnk2
	move.w	#L_MnKey3,(sp)
	bsr	FnExpentier
Cmnk2	move.l	2(sp),d0
	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	MPar
	move.w	(sp)+,d0
	bsr 	CreFonc
	move.l	(sp)+,a6
	rts

;-----> ON MENU got/gosub/proc
Conmen	bsr	OutLea
	bsr	GetWord
	moveq	#-1,d1
	move.w	N_Proc(a5),d7
	cmp.w	#TkGto-Tk,d0
	beq.s	Com0
	addq.l	#1,d1
	cmp.w	#TkGsb-Tk,d0
	beq.s	Com0
	addq.l	#1,d1
	moveq	#-1,d7
Com0	move.w	d1,-(sp)
	clr.w	-(sp)
Com1	addq.w	#1,(sp)
	bsr	GetLabel
	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	Com1
	subq.l	#2,a6
	move.w	Cmvqd0(pc),d0
	move.b	3(sp),d0
	bsr	OutWord
	move.w	Cmvqd1(pc),d0
	move.b	1(sp),d0
	bsr	OutWord
	addq.l	#4,sp
	move.w	#L_OnMen,d0
	bra	CreFonc

;-----> Prend les parametres menus
MPar	bsr	GetWord
	cmp.w	#TkPar1-Tk,d0
	beq.s	MPar1
; Une dimension
	subq.l	#2,a6
	bsr	Expentier
	move.w	Cmvqd7(pc),d0
	bra	OutWord
; Un objet de menu
MPar1	clr.w	-(sp)
MPar2	addq.w	#1,(sp)
	bsr	Expentier
	bsr	GetWord
	cmp.w	#TkVir-Tk,d0
	beq.s	MPar2
	subq.l	#2,a6
	move.w	Cmvqd7(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bra	OutWord


;---------------------------------------------------------------------
BugCode		btst	#6,CiaaPra
		bne.s	BugCode1
		illegal
BugCode1	dc.w	$4321

* Endproc / Param
CdEproE		move.l	(a3)+,ParamE(a5)
CdEproF		move.l	(a3)+,ParamF(a5)
CdEproS		move.l	(a3)+,ParamC(a5)
CdParE		move.l	ParamE(a5),-(a3)
CdParF		move.l	ParamF(a5),-(a3)
CdParS		move.l	ParamC(a5),-(a3)

CJsr		jsr	$fffff0
CBsr		bsr	CBsr
CJmp		jmp	$fffff0
Cjmpa0		jmp	(a0)
Cjsra0		jsr	(a0)
CBra		bra	CBra
Cble		ble	Cble
Cbge		bge	Cbge
CbltS		blt.s	*+8
CbgtS		bgt.s	*+8
Cbeq		beq	CBeq
Cbeq8		beq.s	*+8
Cbeq10		beq.s	*+10
Cbeq12		beq.s	*+12
Cbne		bne	CBne
Cbne8		bne.s	*+8
Cbne10		bne.s	*+10
Cbne12		bne.s	*+12
CLea2a3a3	lea	2(a3),a3
Clea2a0a0	lea	2(a0),a0
Clea2a6a0	lea	2(a6),a0
Cleapca4	lea	Cleapca4(pc),a4
CLeapca0	lea	Cjsr(pc),a0
Cleapca1	lea	Cjsr(pc),a1
Cleapca2	lea	Cjsr(pc),a2
Cleaa0		lea	$fffff0,a0
Cleaa1		lea	$fffff0,a1
Cleaa2		lea	$fffff0,a2
Cmv2a0ma3	move.l	2(a0),-(a3)
Cmv2a6Ma3	move.l	2(a6),-(a3)
Cmvpa0Ma3	move.l	(a0),-(a3)
Cmva3msp	move.l	a3,-(sp)
Cmvpspa3	move.l	(sp)+,a3
Cmva0ma3	move.l	a0,-(a3)
Cmvi2a5		move.l	#-1,2(a5)
Cmvd3ma3	move.l	d3,-(a3)
Cmvima3		move.w	#0,-(a3)
Cmvid1		move.l	#0,d1
Cmvid5		move.l	#0,d5
Cmviwd0		move.w	#0,d0
Cmviwd1		move.w	#0,d1
Cmviwd6		move.w	#0,d6
Cmvqd0		moveq	#0,d0
Cmvqd1		moveq	#0,d1
Cmvqd2		moveq	#0,d2
Cmvqd4		moveq	#0,d4
Cmvqd6		moveq	#0,d6
Cmvqd7		moveq	#0,d7
CTsta3p		tst.l	(a3)+
Cillegal	illegal
CRts		rts
CClrma3		clr.l	-(a3)
Cnop		nop
;---------------------------------------------------------------------
		Include	"_TokTab.s"
;---------------------------------------------------------------------
;   ***  ***  **   ** ****  **** **    **    **   **   **  ***   ***
;  **   ** ** *** *** ** **  **  **    **   ****  *** *** ** ** **
;  **   ** ** ** * ** ** **  **  **   **   **  ** ** * ** ** **  ***
;  **   ** ** **   ** ****   **  **        ****** **   ** ** **    **
;  **   ** ** **   ** **     **  **        **  ** **   ** ** ** *  **
;   ***  ***  **   ** **    **** ****      **  ** **   **  ***   ***
;---------------------------------------------------------------------
;  Zone de donnees
;---------------------------------------------------------------------
AMOS_Save	ds.l	4
Nom_Dos		dc.b	"dos.library",0
Nom_Graphic	dc.b	"graphics.library",0
Nom_IconLib	dc.b	"icon.library",0
Def_Liste	dc.b	":AMOS_System/Compiler_Configuration",0
HeadAMOS	dc.b	"AMOS Basic "
SOMA		dc.b	"SOMA.",0
_C.AMOS		dc.b	"_C.AMOS",0
Mes_DError	dc.b	"Could not load .ENV or Compiler_Configuration file.",10,0
Mes_OOfMem	dc.b	"Out of memory when loading Compiler_Configuration file.",10,0
		even
Nom_Spr		dc.b	"Sprites "
Nom_Ico		dc.b	"Icons   "
		even
Mes_Return	dc.b	13,10,0

		IFNE	CDebug
Mes_Buffers:
		dc.b	"Buffer work: ",0
		dc.b	"Buffer relocation: ",0
		dc.b	"Buffer object: ",0
		dc.b	"Buffer flags local: ",0
		dc.b	"Buffer flags global: ",0
		dc.b	"Buffer strings: ",0
		dc.b 	"Buffer leas: ",0
		dc.b	"Buffer labels: ",0
		dc.b	"Buffer loops: ",0
		dc.b	"Buffer discin: ",0
		dc.b	"Buffer stock: ",0
		dc.b	0
Mes_Bufs2	dc.b	" / ",0
Mes_Bufs3	dc.b	" - Free: ",0
		ENDC

		even

		RsReset
Nom_Source	rs.b	108
Nom_Objet	rs.b	108
Nom_Liste	rs.b	108
Nom_From	rs.b	108
Nom_Messages	rs.b	108
C_Pile		rs.l	1
Flag_Source	rs.w	1
Flag_Objet	rs.w	1
Flag_AMOS	rs.w	1
Flag_Errors	rs.w	1
Flag_Default	rs.w	1
Flag_Type	rs.w	1
Flag_WB		rs.w	1
Flag_Quiet	rs.w	1
Flag_NoTests	rs.w	1
Flag_Flash	rs.w	1
PrintJSR	rs.l	1
C_GfxBase	rs.l	1
C_DosBase	rs.l	1
C_IconBase	rs.l	1
C_Icon		rs.l	1
AMOS_Dz		rs.l	1

OldRel		rs.l	1
DebRel		rs.l	1
Sa3		rs.l	1
Sa4		rs.l	1
SOldRel		rs.l	1
A_Chaines	rs.l	1
A_Bcles		rs.l	1
A_Lea		rs.l	1
A_Proc		rs.l	1
N_Bcles		rs.w	1
N_Proc		rs.w	1
Flag_Const	rs.w	1
Flag_Labels	rs.w	1
Flag_Procs	rs.w	1
OFlag_Labels	rs.w	1
OFlag_Procs	rs.w	1
Flag_Long	rs.w	1
Flag_Val	rs.w	1
Flag_Math	rs.w	1
AdAdress	rs.l	1
AdAdAdress	rs.l	1
F_Proc		rs.l	1
A_FlagVarL	rs.l	1
L_Buf		rs.l	1
P_Source	rs.l	1
A_Banks		rs.l	1
A_InitMath	rs.l	1
A_Dfn		rs.l	1
N_Dfn		rs.w	1
A_Datas		rs.l	1
A_ADatas	rs.l	1
A_EDatas	rs.l	1
A_JDatas	rs.l	1
A_Stock		rs.l	1
AA_Proc		rs.l	1
AA_EProc	rs.l	1
AA_SBuf		rs.l	1
AA_Reloc	rs.l	1
AA_Long		rs.l	1
MaxMem		rs.l	1
Pour_Cpt	rs.w	1
Pour_Base	rs.w	1
Pour_Pos	rs.w	1
L_Reloc		rs.w	1
M_ForNext	rs.w	1
MM_ForNext	rs.w	1
NbInstr		rs.w	1
IconAMOS	rs.w	1

* Source
L_Source	rs.l	1
NL_Source	rs.w	1
DebBso		rs.l	1
FinBso		rs.l	1
MaxBso		rs.l	1
BordBso		rs.l	1
TopSou		rs.l	1
L_Bso		rs.l	1

* Objet
L_Objet		rs.l	1
DebBob		rs.l	1
FinBob		rs.l	1
MaxBob		rs.l	1
TopOb		rs.l	1
BordBob		rs.l	1
BB_Objet_Base	rs.l	1
BB_Objet	rs.l	1
L_Bob		rs.l	1

* Banques
N_Banks		rs.w	1

* Disque
L_DiscIn	rs.l	1
T_Handles	rs.l	M_Fichiers
P_Clib		rs.l	1
T_Clib		rs.l	1
MaxClibs	rs.w	1

* Table des hunks
T_Hunks		rs.l	24*2

* Buffers reserves
InBuf		rs.l	1
InBufs		rs.l	1

D_Buffers	equ	__Rs
B_Noms		rs.l	1
B_Pointeurs	rs.l	1
B_Work		rs.l	1
B_Reloc		rs.l	1
B_Objet		rs.l	1
B_FlagVarL	rs.l	1
B_FlagVarG	rs.l	1
B_Chaines	rs.l	1
B_Lea		rs.l	1
B_Labels	rs.l	1
B_Bcles		rs.l	1
B_DiskIn	rs.l	1
B_Stock		rs.l	1
B_Source	rs.l	1
BufLibs		rs.l	M_Libs
BufToks		rs.l	M_Libs
F_Buffers	equ	__Rs

LDZ		equ	__Rs

		even
DZ		ds.b	LDZ
		even
