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
; ...2220002.220000 2....220002...22.....200002..0000000000002...................
; ...220000..222000002...20000..........200000......2222........................
; ...000000000000000000..200000..........00002..................................
; ..220000000022020000002.200002.........22.......______________________________
; ..0000002........2000000220022.................|
; .200000............2002........................| GESTION SOURCE
; .200002........................................| CHARGEMENT / TEST / VERIF
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
;
; ______________________________________________________________________________

Reloc_Step	equ	1024
TablA_Step	equ	1024
Reloc_End	equ	$80
Reloc_Var	equ	$82
Reloc_Long	equ	$84
Reloc_NewBuffer	equ	$86
Reloc_Proc1	equ	$88
Reloc_Proc2	equ	$8A
Reloc_Proc3	equ	$8C
Reloc_Proc4	equ	$8E
Reloc_Debug	equ	$90
Reloc_Label	equ	$92

;_____________________________________________________________________________
;
;						Test en mode direct
;_____________________________________________________________________________
;
VerDirect
Ver_Direct
	tst.l	VarBuf(a5)		Buffer general deja reserve?
	bne.s	.PaVar
	move.l	#4*1024,d1
	bsr	ResVarBuf
.PaVar	bsr	ResDir			Espace pour variables directes
	tst.l	VNmMini(a5)		Buffer noms deja reserve?
	bne.s	.PaNom
	move.l	PI_VNmMax(a5),d1
	bsr	ResVNom
.PaNom	tst.w	Stack_Size(a5)		Buffer des boucles deja reserve?
	bne.s	.PaSt
	move.w	#10,Stack_Size(a5)
.PaSt	move.l	Ed_BufT(a5),Prg_Test(a5)	Adresse de test
	move.l	Prg_Test(a5),Prg_Run(a5)	Adresse de run
	clr.l	Edt_Runned(a5)			Securites!
	clr.l	Prg_Runned(a5)
	move.w	#1,Phase(a5)			Parametres de test
	move.w	#1,DirFlag(a5)
	bsr	SsTest
	bsr	Free_VerTables			Efface les tables
	bsr	Ver_Run				Table de tokens
	rts

;_____________________________________________________________________________
;
;						Test du programme
;_____________________________________________________________________________
;
PTest:
	movem.l	a2-a4/a6/d2-d7,-(sp)

	clr.b	VerNot1.3(a5)			Compatible, au depart...

; Recherche les includes / Met l'adresse du programme � runner...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_Source(a5),Prg_Run(a5)	Par defaut
	bsr	Get_Includes
	tst.l	Prg_FullSource(a5)		Faut-il changer?
	beq.s	.Skip
	move.l	Prg_FullSource(a5),Prg_Run(a5)
.Skip	move.l	Prg_Run(a5),Prg_Test(a5)	A tester

; RAZ de toutes les variables
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#8*1024,d1
	bsr	ResVarBuf
	move.l	PI_VNmMax(a5),d1
	bsr	ResVNom

	clr.w	Phase(a5)
	clr.w	ErrRet(a5)
	clr.w	DirFlag(a5)
	clr.w	VarBufFlg(a5)
	move.w	#51,Stack_Size(a5)
	clr.b	Prg_Accessory(a5)
	clr.b	MathFlags(a5)		Plus de double precision
	clr.b	Ver_SPConst(a5)		Plus de flags
	clr.b	Ver_DPConst(a5)
	clr.l	VerNInst(a5)

; PHASE 1: exploration du programme principal
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ReVer	clr.w	VarLong(a5)
	move.l	DVNmBas(a5),a0
	move.l	a0,VNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,VNmBas(a5)
	bsr	SsTest
	bne.s	.ReVer

	move.l	Ver_TablA(a5),d0
	move.l	d0,Ver_MainTablA(a5)		Stocke la table
	beq.s	.Skop
	addq.l	#4,d0				Si table il y a
.Skop	clr.l	Ver_TablA(a5)			Une nouvelle table
	move.l	VNmBas(a5),DVNmBas(a5)		Variables
	move.l	VNmHaut(a5),DVNmHaut(a5)
	move.w	VarLong(a5),GloLong(a5)

; 	Exploration de la TablA a la recherche des procedures
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.l	d0				Une table?
	beq.s	.Fini
.PLoop	move.l	d0,a0
	cmp.b	#1<<VF_Proc,Vta_Flag(a0)	Une procedure?
	beq.s	.Test
	move.l	(a0),d0
	bne.s	.PLoop
	bra.s	.Fini
; Verification de la procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Test	move.l	(a0),-(sp)			La suivante
	move.l	Vta_Prog(a0),Prg_Test(a5)	Va explorer la procedure!
	addq.w	#1,Phase(a5)			Une phase de plus
	clr.w	VarLong(a5)
	move.l	DVNmBas(a5),a0
	move.l	a0,VNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,VNmBas(a5)
	bsr	Locale				Toutes les variables >>> locales
	bsr	SsTest
	move.l	Prg_Test(a5),a0			Longueur variable procedure
	move.w	VarLong(a5),6(a0)
	move.l	(sp)+,d0
	bne.s	.PLoop
.Fini

; Libere l'espace pour les variables globales
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	LabBas(a5),a1
	clr.l	-(a1)
	move.w	#-1,-(a1)		* Marque la fin des variables
	move.l	a1,a0
	sub.w	GloLong(a5),a0
	cmp.l	HiChaine(a5),a0
	bcs	VerVNm
	move.l	a0,VarGlo(a5)
	move.l	a0,VarLoc(a5)
	move.l	a0,TabBas(a5)
	move.l	a1,d0			* Nettoie les variables globales
	sub.l	a0,d0
	beq.s	.Clr3
	lsr.l	#2,d0
	bcc.s	.Clr1
	clr.w	(a0)+
.Clr1	subq.w	#1,d0
.Clr2	clr.l	(a0)+
	dbra	d0,.Clr2
.Clr3

; Rend toutes les variables GLOBALES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Globale
; Libere les tables
; ~~~~~~~~~~~~~~~~~
	bsr	Free_VerTables
; Remet la table de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ver_Run
; Verification compatibilite sur le nombre de banques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	clr.b	VerCheck1.3(a5)		Plus de check 1.3
	move.l	Cur_Banks(a5),a0
	bra.s	.Next
.Loop	move.l	d0,a0
	cmp.l	#16,8(a0)		Numero de la banque
	bhi.s	.Non
.Next	move.l	(a0),d0
	bne.s	.Loop
	beq.s	.Oui
.Non	move.b	#1,VerNot1.3(a5)	Flag, directement...
.Oui
; Termine!!!
; ~~~~~~~~~~
	movem.l	(sp)+,a2-a4/a6/d2-d7
	rts

; Libere les tables de verification
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_VerTables
	bsr	Free_Reloc
	bsr	Free_TablA		La courante
	move.l	Ver_MainTablA(a5),Ver_TablA(a5)
	clr.l	Ver_MainTablA(a5)
	bsr	Free_TablA		La principale
	rts

; Met le flag 1.3!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetNot1.3
	move.b	#1,VerNot1.3(a5)
	tst.b	VerCheck1.3(a5)
	bne.s	.Stop
	rts
.Stop	moveq	#47,d0
	bra	VerErr


;	Sous programme de verification
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SsTest:	clr.l	ErrRet(a5)
	clr.w	Passe(a5)
	clr.w	Ver_NBoucles(a5)
	clr.w	Ver_PBoucles(a5)

	bsr	Ver_Verif
	bsr	Reserve_Reloc
	bsr	Reserve_TablA

	move.l	Prg_Test(a5),a6
	move.l	a6,a3

	tst.w	DirFlag(a5)
	bne.s	VerD
	tst.w	Phase(a5)
	bne.s	VerDd

; Debut d'une ligne
; ~~~~~~~~~~~~~~~~~
VerD	move.l	a6,VDLigne(a5)
	tst.w	(a6)+
	beq	VerX

; Definition procedures / Data en debut de ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerDd:	move.l	a6,VerPos(a5)
	move.w	(a6)+,d0
	beq.s	VerD
	bmi	VerSynt
	move.l	AdTokens(a5),a0
	move.b	0(a0,d0.w),d1
	bpl.s	VLoop1
	addq.l	#1,VerNInst(a5)
	ext.w	d1
	asl.w	#2,d1
	jmp	.Jmp(pc,d1.w)
	bra	VerSha			FA-Global (Nouvelle maniere)
	bra	VerSha			FB-Shared
	bra	VerDFn			FC-Def Fn
	bra	VerData			FD-Debut data
	bra	V1_EndProc		FE-Fin procedure
	bra	V1_Procedure		FF-Debut procedure
.Jmp

; Boucle de test dans une ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerLoop move.l	a6,VerPos(a5)		Position du test
	move.w	(a6)+,d0
	beq	VerD
	bmi	VerSynt
	move.l	AdTokens(a5),a0
	move.b	0(a0,d0.w),d1
VLoop1	addq.l	#1,VerNInst(a5)		Un instruction de plus!
	ext.w	d1
	asl.w	#2,d1
	jmp	.Jmp(pc,d1.w)		Branche � la fonction


; Table des sauts pour les instructions particulieres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bra	VerShal			FA-Global (Nouvelle maniere)
	bra	VerShal			FB-Shared
	bra	VerDaL			FC-Def Fn
	bra	VerDaL			FD-Debut data
	bra	VerPDb			FE-Fin procedure
	bra	VerPDb			FF-Debut procedure
.Jmp	bra	Ver_Normal		00-Instruction normale
	bra	VerSynt			01-Syntax error
	bra	VerRem			02-Rem
	bra	VerSBu			03-Set Buffer
	bra	VerDPre			04-Set Double Precision
	bra	VerSStack		05-Set Stack
	bra	VerVar			06-Variable
	bra	VerLab			07-Un label
	bra	VerPro			08-Un appel de procedure
	bra	VerDim			09-DIM
	bra	VerPr			0A-Print
	bra	VerDPr			0B-Print #
	bra	VerInp			0C-Input / Line Input
	bra	VerDInp			0D-Input #
	bra	VerInc			0E-Dec
	bra	V1_Proc			0F-Proc
	IFNE	Debug=2
	bra	V1_Debug		10- Debugging
	ENDC
	IFEQ	Debug=2
	bra	Ver_Normal
	ENDC
	bra	VerPal			11-Default Palette
	bra	VerPal			12-Palette
	bra	VerRead			13-Read
	bra	VerRest			14-Restore
	bra	VerChan			15-Channel
	bra	VerInc			16-Inc
	bra	VerAdd			17-Add
	bra	VerPo			18-Polyline/Gon
	bra	VerFld			19-Field
	bra	VerCall			1A-Call
	bra	VerMn			1B-Menu
	bra	VerMnD			1C-Menu Del
	bra	VerSmn			1D-Set Menu
	bra	VerMnK			1E-Menu Key
	bra	VerIMn			1F-Menu diverse
	bra	VerFade			20-Fade
	bra	VerSort			21-Sort
	bra	VerSwap			22-Swap
	bra	VerFol			23-Follow
	bra	VerSetA			24-Set Accessory
	bra	VerTrap			25-Trap
	bra	VerStruI		26-Struc
	bra	VerStruIS		27-Struc$
	bra	Ver_Extension		28-Token d'extension
	bra	Ver_NormalPro		29-Instruction AMOSPro
	bra	Ver_DejaTesteePro	2A-Instruction AMOSPro deja testee
	bra	Ver_VReservee		2B-Variable reservee
	bra	Ver_VReserveePro	2C-Variable reservee AMOSPro
	bra	Ver_DejaTestee		2D-Instruction normale deja testee
	bra	VerD			2E-LIBRE
	bra	VerD			2F-Fin de ligne
	bra	V1_For			30-For
	bra	V1_Next			31-Next
	bra	V1_Repeat		32-Repeat
	bra	V1_Until		33-Until
	bra	V1_While		34-While
	bra	V1_Wend			35-Wend
	bra	V1_Do			36-Do
	bra	V1_Loop			37-Loop
	bra	V1_Exit			38-Exit
	bra	V1_ExitI		39-Exit If
	bra	V1_If			3A-If
	bra	V1_Else			3B-Else
	bra	V1_ElseIf		3C-ElseIf
	bra	V1_EndI			3D-EndIf
	bra	V1_Goto			3E-Goto
	bra	V1_Gosub		3F-Gosub
	bra	V1_OnError		40-OnError
	bra	V1_OnBreak		41-OnBreak
	bra	V1_OnMenu		42-OnMenu
	bra	V1_On			43-On
	bra	V1_Resume		44-Resume
	bra	V1_ResLabel		45-ResLabel
	bra	V1_PopProc		46-PopProc
	bra	V1_Every		47-Every
	bra	VerPr			48-LPrint
	bra	VerInp			49-Line Input
	bra	VerDInp			4A-Line Input #
	bra	VerMid			4B-Mid3
	bra	VerMid			4C-Mid2
	bra	VerMid			4D-Left
	bra	VerMid			4E-Right
	bra	VerAdd			4F-Add
	bra	Ver_NormalPro		50-Dialogues
	bra	Ver_Normal		51-Dir
	bra	VerSynt			52-Then
	bra	Ver_Normal		53-Return
	bra	Ver_Normal		54-Pop
	bra	Ver_NormalPro		55-Procedure langage machine
	bra	Ver_Normal		56-Bset/Bchg/Ror///
	bra	VerSynt			57-APCmp Call

	IFNE	Debug=2
V1_Debug
	move.b	#Reloc_Debug,d0		Dans relocation
	bsr	New_Reloc
	lea	V2_Debug(pc),a0		Dans TablA
	move.w	#_TkDP,d0
	moveq	#0,d1
	moveq	#1<<VF_Debug,d2
	bsr	Init_TablA
	bra	VerDP
V2_Debug
	jsr	BugBug
	rts
	ENDC

;	Une extension
; ~~~~~~~~~~~~~~~~~~~
Ver_Extension
	bset	#0,VarBufFlg(a5)
	move.b	(a6)+,d1		Numero de l'extension
	ext.w	d1
	move.l	a6,-(sp)		Position du nombre de params
	tst.b	(a6)+
	move.w	(a6)+,d0		Token de l'extension
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	tst.l	0(a0,d1.w)		Extension definie?
	beq	VerExN
	move.l	0(a0,d1.w),a0
	clr.w	-(sp)			Flag librairie 2.0 ou ancienne
	btst	#LBF_20,LB_Flags(a0)	Librarie 2.0?
	beq.s	.Skip
	move.w	#-1,(sp)
.Skip	move.l	a0,VerBase(a5)		Base de la librairie
	bsr	Ver_OlDInst		Debut de la definition
	cmp.b	#"I",d0			Une instruction
	beq.s	.Inst
	cmp.b	#"V",d0			Une variable reservee?
	bne	VerSynt
	bsr	VerVR
	bra.s	.Poke
.Inst	bsr	VerI			Verification
.Poke	tst.w	(sp)+			Le flag
	move.l	(sp)+,a0		Poke le nombre de params...
	beq.s	.Old
	move.b	#-1,(a0)		Nouvelle extension: pas de params!
	bra	VerDP
.Old	move.b	d0,(a0)			Ancienne extension: des params...
	bra	VerDP

; 	Variable reservee
; ~~~~~~~~~~~~~~~~~~~~~~~
Ver_VReserveePro
	bsr	SetNot1.3		Si AMOSPro
Ver_VReservee
	bset	#0,VarBufFlg(a5)
	move.l	a0,VerBase(a5)
	bsr	Ver_DInst
	bsr	VerVR
	bra	VerDP

;	Routine de verification VARIABLE RESERVEE en instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerVR:	move.b	(a0)+,d2
	move.w	d2,-(sp)
	bsr	VerF
	move.w	d0,-(sp)
	move.l	a6,VerPos(a5)
	cmp.w	#_TkEg,(a6)+
	bne	VerSynt
	bsr	Ver_Expression
	move.w	(sp)+,d0
	move.w	(sp)+,d1
	cmp.b	d1,d2
	bne	VerType
	rts

; 	Instruction deja testee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_DejaTesteePro
	bsr	SetNot1.3		Si AMOSPro
Ver_DejaTestee
	bset	#0,VarBufFlg(a5)
	bsr	Ver_DInst
	bsr	VerI_DejaTestee
	bra	VerDP

; 	Instruction normale
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_NormalPro
	bsr	SetNot1.3		Si AMOSPro
Ver_Normal
	bset	#0,VarBufFlg(a5)
	move.l	a0,VerBase(a5)
	bsr	Ver_DInst
	bsr	VerI
;	Veut un deux points apres l'instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerDP:	move.l	a6,VerPos(a5)
	move.w	(a6)+,d0
	beq	VerD
	cmp.w	#_TkDP,d0
	beq	VerLoop
	cmp.w	#_TkElse,d0
	bne	VerSynt
	subq.l	#2,a6
	bra	VerLoop


;	PASSE2: simple relecture du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerX:	addq.w	#1,Passe(a5)
	move.b	#Reloc_End,d0
	bsr	New_Reloc

; Boucle de relocation des variables / labels / appel procedures
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Ver_Reloc(a5),a4
	move.l	a4,Ver_CReloc(a5)
	addq.l	#4,a4
	move.l	Prg_Test(a5),a6
.RReloc	moveq	#0,d6
.Reloc	add.w	d6,a6
	move.b	(a4)+,d6
	lsl.b	#1,d6
	bcc.s	.Reloc
	jsr	.V2Jmp(pc,d6.w)
	bra.s	.RReloc
.V2Jmp	bra	V2_EndRel
	bra	V2_StoVar
	bra	V2_Long
	bra	V2_NTable
	bra	V2_CallProc1
	bra	V2_CallProc2
	bra	V2_CallProc3
	bra	V2_CallProc4
	IFNE	Debug=2
	bra	V2_Debug		A
	ENDC
	IFEQ	Debug=2
	rts
	nop
	ENDC
; Find label
; ~~~~~~~~~~
	move.l	a6,VerPos(a5)		C
	subq.l	#2,VerPos(a5)
	bsr	V2_FindLabel
	beq	VerUnd
	rts
; Nouvelle table de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_NTable
	move.l	Ver_CReloc(a5),a4
	move.l	(a4),a4
	move.l	a4,Ver_CReloc(a5)
	addq.l	#4,a4
	rts
; Saut long dans relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~
V2_Long	moveq	#0,d6
	move.b	(a4)+,d6
	lsl.w	#8,d6
	move.b	(a4)+,d6
	add.l	d6,a6
	rts

; Fin de la relocation
; ~~~~~~~~~~~~~~~~~~~~
V2_EndRel
	addq.l	#4,sp

; Boucle d'appel des traitement de boucle
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Ver_TablA(a5),d0
	beq.s	.TablX
	addq.l	#4,d0
.TablA	move.l	d0,a4
	move.l	Vta_Jump(a4),d0
	beq.s	.TablB
	move.l	d0,a1
	move.l	Vta_Prog(a4),a6
	move.l	a6,VerPos(a5)
	subq.l	#2,VerPos(a5)
	move.l	a4,a0
	jsr	(a1)
.TablB	move.l	(a4),d0
	bne.s	.TablA
.TablX

; 	Efface la relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Free_Reloc

; 	Fin des deux passes, erreur retardee?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	ErrRet(a5),d0
	beq.s	.Skip
	move.l	ErrRAd(a5),VerPos(a5)
	bra	VerErr
.Skip	moveq	#0,d0			Ne pas reboucler...
	rts

******* MESSAGES D'ERREUR VERIFICATION
* Loops crossing / ERREUR RETARDEE
VerCrs:	move.l	a0,-(sp)
	moveq	#1,d0			Bad Structure
	bsr	ERetard
	move.l	(sp)+,a0
	rts
ERetard:tst.l	ErrRet(a5)
	bne.s	ERet1
	move.l	d0,ErrRet(a5)
	move.l	VerPos(a5),ErrRAd(a5)
ERet1:	rts
* User function
VerNFn	moveq	#2,d0
	bra	VerEr
* Impossible to change buffer
VerNoB	moveq	#3,d0
	bra	VerEr
* Datas en debut de ligne
VerDaL:	moveq	#4,d0
	bra	VerEr
* Extension not present
VerExN:	moveq	#5,d0
	bra	VerEr
* Too many direct variables
VerVTo:	moveq	#6,d0
	bra	VerEr
* Illegal direct mode
VerIlD:	moveq	#7,d0
	bra.s	VerEr
* Buffer variable too small
VerVNm:	moveq	#8,d0
	bra.s	VerEr
* Goto dans une boucle
VerPaGo:moveq	#9,d0
	bra.s	VerEr
* Structure too long
VerLong:moveq	#10,d0
	bra.s	VerEr
* Shared
VerShp:	moveq	#11,d0
	bra.s	VerEr
VerAlG:	moveq	#12,d0
	bra.s	VerEr
VerPaG:	moveq	#13,d0
	bra.s	VerEr
VerNoPa:moveq	#14,d0
	bra.s	VerEr
VerShal:moveq	#15,d0
	bra.s	VerEr
* Procedures
VerPDb:	moveq	#16,d0
	bra.s	VerEr
VerPOp:	moveq	#17,d0
	bra.s	VerEr
VerPNo:	moveq	#18,d0
	bra.s	VerEr
VerPRTy:moveq	#18,d0
	bra.s	VerEr
VerIlP:	moveq	#19,d0
	bra.s	VerEr
VerUndP:moveq	#20,d0
	bra.s	VerEr
* Else without If
VerElI:	moveq	#21,d0
VerEr:	bra	VerErr
VerIfE:	moveq	#22,d0
	bra	VerErr
VerEIf:	moveq	#23,d0
	bra	VerErr
VerElE:	moveq	#24,d0
	bra	VerErr
VerNoT:	moveq	#25,d0
	bra	VerErr
* Not enough loop
VerNoL:	moveq	#26,d0
	bra	VerErr
* Do/Loop
VerDoL:	moveq	#27,d0
	bra	VerErr
VerLDo:	moveq	#28,d0
	bra.s	VerErr
* While/Wend
VerWWn:	moveq	#29,d0
	bra.s	VerErr
VerWnW:	moveq	#30,d0
	bra.s	VerErr
* Repeat/until
VerRUn:	moveq	#31,d0
	bra.s	VerErr
VerUnR:	moveq	#32,d0
	bra.s	VerErr
* For/Next
VerFoN:	moveq	#33,d0
	bra.s	VerErr
VerNFo:	moveq	#34,d0
	bra.s	VerErr
* Syntax
VerSynt:moveq	#35,d0
	bra.s	VerErr
* Out of mem
VerOut:	moveq	#36,d0
	bra.s	VerErr
* Out of variable name space
VerNmO:	moveq	#37,d0
	bra.s	VerErr
* Non dimensionned
VerNDim	moveq	#38,d0
	bra.s	VerErr
* Already dimensionned
VerAlD:	moveq	#39,d0
	bra.s	VerErr
* Type mismatch
VerType	moveq	#40,d0
	bra.s	VerErr
* Label not defined
VerUnd:	moveq	#41,d0
	bra.s	VerErr
* Label defined twice
VerLb2:	moveq	#42,d0


; Traitement message d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerErr	move.l	d0,-(sp)
; Remet les tokens
; ~~~~~~~~~~~~~~~~
	bsr	Ver_Run
; Efface les buffers d'inclusion
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	VerPos(a5),a0
	bsr	Includes_Adr
	move.l	a0,VerPos(a5)
	bsr	Includes_Clear
; Efface les equates
; ~~~~~~~~~~~~~~~~~~
	jsr	D_Close
; Efface les tables
; ~~~~~~~~~~~~~~~~~
	bsr	Free_VerTables
; Plus de check1.3
; ~~~~~~~~~~~~~~~~
	clr.b	VerCheck1.3(a5)
; Depile le programme
; ~~~~~~~~~~~~~~~~~~~
	move.l	Prg_JError(a5),a2
	bsr	Prg_Pull
; Branche � l'appelant
; ~~~~~~~~~~~~~~~~~~~~
	move.l	(sp)+,d0
	neg.l	d0				Message negatif= TEST
	sub.l	a0,a0				Trouver le message
	jmp	(a2)				On branche


;	REM
; ~~~~~~~~~
VerRem	tst.w	Direct(a5)
	bne	VerIlD
	add.w	(a6)+,a6
	addq.l	#2,a6
	bra	VerD

;	Token appel procedure, change en variable
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerPro	tst.w	Direct(a5)
	bne	VerIlD
;	Variable en instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerVar	bset	#0,VarBufFlg(a5)
	bsr	V1_IVariable
	bra	VerDP


;	D�finition d'un label
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerLab:	tst.w	Direct(a5)
	bne	VerIlD
	bset	#0,VarBufFlg(a5)
	bsr	V1_StockLabel
	cmp.w	#_TkData,(a6)
	bne	VerLoop
	addq.l	#2,a6
	bra	VerData

;	SET DOUBLE PRECISION
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
VerDPre	bsr	SetNot1.3
	btst	#0,VarBufFlg(a5)
	bne.s	VVErr
	bset	#1,VarBufFlg(a5)
	bne.s	VVErr
	move.b	#%10000011,MathFlags(a5)
	bra	VerDP
VVErr	moveq	#50,d0
	bra	VerErr

;	SET STACK n
; ~~~~~~~~~~~~~~~~~
VerSStack
	tst.w	Direct(a5)
	bne	VerIlD
	btst	#0,VarBufFlg(a5)
	bne.s	VVErr
	bset	#3,VarBufFlg(a5)
	bne.s	VVErr
	cmp.w	#_TkEnt,(a6)+
	bne	VerSynt
	move.l	(a6)+,d1
	cmp.w	#10,d1
	bcc.s	.Ok
	moveq	#10,d1
.Ok	addq.w	#1,d1
	move.w	d1,Stack_Size(a5)
	bra	VerDP

;	SET BUFFER n
; ~~~~~~~~~~~~~~~~~~
VerSBu	tst.w	Direct(a5)
	bne	VerIlD
	btst	#0,VarBufFlg(a5)
	bne	VerNoB
	cmp.w	#_TkEnt,(a6)+
	bne	VerSynt
	move.l	(a6)+,d1
	mulu	#1024,d1
	cmp.l	VarBufL(a5),d1
	beq	VerDP
; Change la taille / recommence
	bset	#2,VarBufFlg(a5)
	bne	VerNoB
	bsr	ResVarBuf
	moveq	#-1,d0
	rts

;	SET ACCESSORY
; ~~~~~~~~~~~~~~~~~~~
VerSetA	bsr	SetNot1.3
	addq.b	#1,Prg_Accessory(a5)
	bra	VerDP

;	DIM
; ~~~~~~~~~
VerDim:	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkVar,(a6)+		Veut une variable
	bne	VerSynt
	and.b	#%00001111,3(a6)	RAZ du flag!
	bsr	VarA0
	cmp.w	#_TkPar1,(a0)		TABLEAU?
	bne	VerSynt
	bset	#6,3(a6)		Met le flag tableau!
	move.b	3(a6),d3
	bsr	V1_StoVar
	beq	VerAlD
	bsr	VerTablo		Verifie les params d'un tableau
	move.b	d0,4(a1)		Stocke le nb de dimensions
	cmp.w	#_TkVir,(a6)+		Une autre variable?
	beq	VerDim
	subq.l	#2,a6
	bra	VerDP

;	SORT
; ~~~~~~~~~~
VerSort	bset	#0,VarBufFlg(a5)
	move.l	a6,-(sp)
	bsr	VerGV
	move.l	(sp)+,a0
	btst	#6,5(a0)
	bne	VerDP
	bra	VerSynt

;	SWAP
; ~~~~~~~~~~
VerSwap	bset	#0,VarBufFlg(a5)
	bsr	VerGV
	move.w	d2,-(sp)
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	bsr	VerGV
	cmp.w	(sp)+,d2
	beq	VerDP
	bne	VerType

;	DEF FN
; ~~~~~~~~~~~~
VerDFn	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	and.b	#%00001111,3(a6)	Change le flag
	bset	#3,3(a6)
	bsr	VarA0			Adresse
	move.w	d2,-(sp)
	bsr	V1_StoVar		Stocke la variable
	bsr	VDfnR			Recupere les parametres
	cmp.w	#_TkEg,(a6)+
	bne	VerSynt
	bsr	Ver_Expression		Evalue l'expression
	move.w	(sp)+,d0		Verifie le type
	cmp.b	d0,d2
	bne	VerType
	tst.w	(a6)			Seul sur la ligne
	bne	VerDaL
	bra	VerDP
; Routinette---> Prend les variables!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VDfnR	cmp.w	#_TkPar1,(a6)
	bne.s	.Exit
	addq.l	#2,a6
.Loop	bsr	VerGV
	cmp.w	#_TkVir,(a6)+
	beq.s	.Loop
	cmp.w	#_TkPar2,-2(a6)
	bne	VerSynt
.Exit	rts

;	Verification PRINT/LPRINT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerDPr	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
VerPr:	bset	#0,VarBufFlg(a5)
	move.w	(a6),d0
	cmp.w	#_TkDieze,d0
	bne.s	VerPr1
	addq.l	#2,a6
	bsr	Ver_Expression
	cmp.b	#"2",d2
	beq	VerType
	cmp.w	#_TkVir,(a6)
	bne 	VerDP
	addq.l	#2,a6
VerPr1:	bsr	Finie
	beq	VerDP
	move.l	a6,VerPos(a5)
	cmp.w	#_TkUsing,(a6)
	bne.s	VerPr2
	addq.l	#2,a6
	bsr	Ver_ExpA
	cmp.w	#_TkPVir,(a6)+
	bne	VerSynt
VerPr2	bsr	Ver_Expression
	move.w	(a6)+,d0
	cmp.w	#_TkVir,d0
	beq.s	VerPr1
	cmp.w	#_TkPVir,d0
	beq.s	VerPr1
	subq.l	#2,a6
	bra	VerDP

;	Verification INPUT / LINE INPUT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerDInp	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	bra.s	VerIn1
VerInp:	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkVar,(a6)
	beq.s	VerIn1
	bsr	Ver_Expression
	cmp.b	#"2",d2
	bne	VerType
	cmp.w	#_TkPVir,(a6)+
	bne	VerSynt
VerIn1:	bsr	VerGV
	cmp.w	#_TkVir,(a6)+
	beq.s	VerIn1
	cmp.w	#_TkPVir,-2(a6)
	beq	VerDP
	subq.l	#2,a6
	bra	VerDP

;	Verification PALETTE / DEFAULT PALETTE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerFa1:	addq.l	#2,a6
VerPal:	clr.w	d0
VPal:	bset	#0,VarBufFlg(a5)
	addq.w	#1,d0
	move.w	d0,-(sp)
	bsr	Ver_ExpE
	move.w	(sp)+,d0
	cmp.w	#_TkVir,(a6)
	bne	VerDP
	addq.l	#2,a6
	cmp.w	#32,d0
	bcs.s	VPal
	bra	VerDP

;	Verification FADE
; ~~~~~~~~~~~~~~~~~~~~~~~
VerFade	bset	#0,VarBufFlg(a5)
	bsr	Ver_ExpE
	cmp.w	#_TkVir,d0
	beq.s	VerFa1
	cmp.w	#_TkTo,d0
	bne	VerDP
	addq.l	#2,a6
	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	Ver_ExpE
	bra	VerDP

;					Verification instructions MENU
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;	Instruction MENU$(,,)=
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerMn	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	cmp.w	#_TkEg,(a6)+
	bne	VerSynt
; Chaines alphanumeriques
; ~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#_TkVir,(a6)
	beq.s	VerMn1
	bsr	Ver_ExpA
	cmp.w	#_TkVir,(a6)
	bne	VerDP
VerMn1	addq.l	#2,a6
	cmp.w	#_TkVir,(a6)
	beq.s	VerMn2
	bsr	Ver_ExpA
	cmp.w	#_TkVir,(a6)
	bne	VerDP
VerMn2	addq.l	#2,a6
	cmp.w	#_TkVir,(a6)
	beq.s	VerMn3
	bsr	Ver_ExpA
	cmp.w	#_TkVir,(a6)
	bne	VerDP
VerMn3	addq.l	#2,a6
	bsr	Ver_ExpA
	bra	VerDP

;	Instructions diverses flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerIMn	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkPar1,(a6)
	beq.s	VIMn1
	cmp.w	#_TkMnCl,(a6)
	bcc	VerSynt
	bsr	Ver_ExpE
	bra	VerDP
VIMn1	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	bra	VerDP

;	Menu del
; ~~~~~~~~~~~~~~
VerMnD	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkPar1,(a6)
	bne	VerDP
	bra.s	VIMn1

;	Set Menu
; ~~~~~~~~~~~~~~
VerSmn	bset	#0,VarBufFlg(a5)
	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	cmp.w	#_TkTo,(a6)+
	bne	VerSynt
	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	bsr	Ver_ExpE
	bra	VerDP

;	On menu
; ~~~~~~~~~~~~~
V1_OnMenu
	move.w	(a6)+,d0
	cmp.w	#_TkGto,d0
	beq.s	.Goto
	cmp.w	#_TkGsb,d0
	beq.s	.Goto
	cmp.w	#_TkPrc,d0
	beq.s	.Proc
	bra	VerSynt
; Goto, prend le label
; ~~~~~~~~~~~~~~~~~~~~
.Goto	bsr	V1_GoLabel
	cmp.w	#_TkVir,(a6)+
	beq.s	.Goto
	subq.l	#2,a6
	bra	VerDP
; Procedure
; ~~~~~~~~~
.Proc	bsr	V1_GoProcedureNoParam
	cmp.w	#_TkVir,(a6)+
	beq.s	.Proc
	subq.l	#2,a6
	bra	VerDP

;	Menu key
; ~~~~~~~~~~~~~~
VerMnK	bset	#0,VarBufFlg(a5)
	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	cmp.w	#_TkTo,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	Ver_Evalue
	cmp.b	#"2",d2
	beq	VerDP
	cmp.b	#"0",d2
	bne	VerType
	cmp.w	#_TkVir,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	Ver_ExpE
	bra	VerDP

;	Verification FOLLOW
; ~~~~~~~~~~~~~~~~~~~~~~~~~
VerFol	bsr	Finie
	beq	VerDP
.Loop	bsr	Ver_Expression
	cmp.w	#_TkVir,(a6)+
	beq.s	.Loop
	subq.l	#2,a6
	bra	VerDP

;	Verification DATAS
; ~~~~~~~~~~~~~~~~~~~~~~~~
VerData	bset	#0,VarBufFlg(a5)
	move.l	a6,d0
	sub.l	VDLigne(a5),d0
	move.w	d0,(a6)
.Loop	addq.l	#2,a6
	bsr	Ver_Expression
	cmp.w	#_TkVir,(a6)
	beq.s	.Loop
	bra	VerDP

;	Verification READ
; ~~~~~~~~~~~~~~~~~~~~~~~
VerRead	bset	#0,VarBufFlg(a5)
	bsr	VerGV
	cmp.w	#_TkVir,(a6)
	bne	VerDP
	addq.l	#2,a6
	bra.s	VerRead

;	Verification RESTORE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
VerRest	bsr	Finie
	beq	VerDP
	bsr	V1_GoLabel
	bra	VerDP

;	Verification CHANNEL x TO SPRITE x
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerChan	bset	#0,VarBufFlg(a5)
	bsr	Ver_ExpE
	cmp.w	#_TkTo,(a6)+
	bne	VerSynt
	move.w	(a6)+,d0
	cmp.w	#_TkScD,d0
	beq.s	VerCh1
	cmp.w	#_TkScO,d0
	beq.s	VerCh1
	cmp.w	#_TkScS,d0
	beq.s	VerCh1
	cmp.w	#_TkBob,d0
	beq.s	VerCh1
	cmp.w	#_TkSpr,d0
	beq	VerCh1
	cmp.w	#_TkRn,d0
	beq.s	VerCh1
	subq.l	#2,a6			* Channel to ADRESS!
VerCh1:	bsr	Ver_ExpE
	bra	VerDP

;	Verification POLYLINE/POLYGON
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerPo	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkTo,(a6)
	beq.s	VerPo1
VerPo0	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	bsr	Ver_ExpE
VerPo1	cmp.w	#_TkTo,(a6)+
	beq.s	VerPo0
	subq.l	#2,a6
	bra	VerDP

;	Verification MID/LEFT/RIGHT en instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerMid:	bset	#0,VarBufFlg(a5)
	move.w	d0,-(sp)
	move.l	a6,-(sp)
	addq.b	#1,Ver_NoReloc(a5)
	addq.l	#2,a6
	bsr	VerVarA
	subq.b	#1,Ver_NoReloc(a5)
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	move.l	(sp)+,a6
	move.w	(sp)+,d0
	move.l	AdTokens(a5),a0
	move.l	a0,VerBase(a5)
	bsr	Ver_OlDInst
	bsr	VerF
	cmp.w	#_TkEg,(a6)+
	bne	VerSynt
	bsr	Ver_Expression
	cmp.b	#"2",d2
	bne 	VerType
	bra	VerDP

;	Verification INC/DEC
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
VerInc:	bset	#0,VarBufFlg(a5)
	bsr	VerVEnt
	bsr	VerGV
	bra	VerDP

;	Verification ADD
; ~~~~~~~~~~~~~~~~~~~~~~
VerAdd:	bset	#0,VarBufFlg(a5)
	move.w	#_TkAd2,-2(a6)
	move.l	a6,-(sp)
	bsr	VerVEnt
	bsr	VerGV
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)
	bne	VerAdX
; Plus de 2 parametres
; ~~~~~~~~~~~~~~~~~~~~
	move.l	(sp),a0
	move.w	#_TkAd4,-2(a0)
	addq.l	#2,a6
	bsr	Ver_ExpE
	cmp.w	#_TkTo,(a6)+
	bne	VerAdX
	bsr	Ver_ExpE
VerAdX:	addq.l	#4,sp
	bra	VerDP

;	Verification FIELD
; ~~~~~~~~~~~~~~~~~~~~~~~~
VerFld	bset	#0,VarBufFlg(a5)
	bsr	Ver_ExpE
	cmp.w	#_TkVir,(a6)
	bne	VerSynt
.Loop	addq.l	#2,a6
	bsr	Ver_ExpE
	cmp.w	#_TkAs,(a6)+
	bne	VerSynt
	bsr	VerVarA
	cmp.w	#_TkVir,(a6)
	beq.s	.Loop
	bra	VerDP

;	CALL
; ~~~~~~~~~~
VerCall	bset	#0,VarBufFlg(a5)
	bsr	Ver_ExpE
.Loop	cmp.w	#_TkVir,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	Ver_Expression
	bra.s	.Loop

;	STRUCTURE en instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerStruI
	bset	#0,VarBufFlg(a5)
	bsr	VStru
	cmp.b	#7,d2
	bcc	EquType
	moveq	#"0",d2
	bra.s	VStru2
VerStruIS
	bsr	VStru
	cmp.b	#6,d2
	bne	EquType
	moveq	#"2",d2
; Fin verification
VStru2	cmp.w	#_TkEg,(a6)+
	bne	VerSynt
	move.w	d2,-(sp)
	bsr	Ver_Expression
	ext.w	d2
	cmp.w	(sp)+,d2
	bne	VerType
	bra	VerDP
; Routine verification
VStru	move.l	a6,-(sp)
	addq.l	#6,a6
	cmp.w	#_TkPar1,(a6)+
	bne	VerSynt
	bsr	Ver_Expression
	cmp.b	#"0",d2
	bne	VerType
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	move.l	(sp)+,a1
	lea	Equ_Nul(pc),a0
	bsr	Equ_Verif
	move.b	4(a1),d2
	cmp.w	#_TkPar2,(a6)+
	bne	VerSynt
	rts
EquType	moveq	#54,d0
	bra	VerErr

; Verification d'un Equate / Structure
;	A0=	Header equate
;	A1=	Debut des donnees
;	A6=	Debut de la chaine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Equ_Verif
	bsr	SetNot1.3		AMOSPro!
	btst	#7,5(a1)		Flag, equate correct?
	bne	.Ok
; Poke l'equate dans le buffer, � la suite du header
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	a0-a2,-(sp)
	move.l	a1,-(sp)
	move.l	Buffer(a5),a2
.Cop	move.b	(a0)+,(a2)+
	bne.s	.Cop
	subq.l	#1,a2
	move.w	(a6),d0
	cmp.w	#_TkCh1,d0
	beq.s	.Ch
	cmp.w	#_TkCh2,d0
	bne	VerSynt
.Ch	move.w	2(a6),d0
	beq	VerSynt
	cmp.w	#127,d0
	bcc	VerSynt
	move.w	d0,d2
	move.l	a2,a1
	lea	4(a6),a0
	subq.w	#1,d0
.Lop2	move.b	(a0)+,(a1)+
	dbra	d0,.Lop2
	move.b	#":",(a1)+
	move.l	Buffer(a5),a2
	move.l	a1,d2
	sub.l	a2,d2
; Va charger le fichier d'equates>>> A1/D1 positionnes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Equ_Load
; Recherche dans le fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	a1/d1/d2,-(sp)
	moveq	#0,d4
	JJsr	L_InstrFind		***
	movem.l	(sp)+,a1/d1/d2
	tst.l	d3
	beq	.NoDef
; Trouve: poke dans le listing
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	-1(a1,d3.l),a1
.Fnd	cmp.b	#":",(a1)+		Trouve le debut
	bne.s	.Fnd
	clr.w	-(sp)
	move.l	a1,a0
	cmp.b	#"-",(a0)
	bne.s	.Pam
	addq.w	#1,(sp)
	addq.l	#1,a0
.Pam	moveq	#0,d0			Pas de signe!
	JJsrR	L_ValRout,a1
	bne.s	.Bad
	cmp.w	#_TkFl,d1
	beq.s	.Bad
	cmp.w	#_TkDFl,d1
	beq.s	.Bad
	tst.w	(sp)+
	beq.s	.Pamm
	neg.l	d0
.Pamm	move.l	(sp),a2
	move.l	d0,(a2)
	cmp.b	#",",(a0)+
	bne.s	.Bad
	move.b	(a0),d0
	sub.b	#"0",d0
	cmp.b	#7,d0
	bhi.s	.Bad
	move.b	d0,4(a2)
	bset	#7,5(a2)
	addq.l	#4,sp
	movem.l	(sp)+,a0-a2
; Saute la variable alphanumerique
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Ok	move.w	2(a6),d0
	move.w	d0,d1
	and.w	#1,d1
	add.w	d1,d0
	lea	4(a6,d0.w),a6
	rts
; Not defined!
; ~~~~~~~~~~~~
.NoDef	moveq	#51,d0
	bra	VerErr
; Bad equates file
; ~~~~~~~~~~~~~~~~
.Bad	moveq	#53,d0
	bra	VerErr

; Charge le fichier d'equates dans un buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Equ_Load
	movem.l	a0/d2/d3,-(sp)
	tst.l	Equ_Base(a5)
	bne	.Ok
; Branche la routine de FLUSH equates
	JLea	L_Equ_Free,a0
	lea	Equ_FlushStructure(pc),a1
	move.l	a0,(a1)
	SyCall	AddFlushRoutine
; Charge le fichier
	moveq	#9,d0
	JJsr	L_Sys_GetMessage
	JJsrR	L_Sys_AddPath,a1
	move.l	#1005,d2
	jsr	D_Open
	beq.s	.Err
; Trouve la taille du fichier!
	moveq	#0,d2
	moveq	#1,d3
	jsr	D_Seek
	moveq	#0,d2
	moveq	#-1,d3
	jsr	D_Seek
; Reserve la memoire
	move.l	d0,d3
	move.l	#Fast|Public,d1
	lea	Equ_Base(a5),a0
	bsr	A5_Reserve
	beq.s	.Err
; Charge le fichier
	move.l	a0,d2
	jsr	D_Read
	bne.s	.Err
; Ferme le fichier
	jsr	D_Close
; Retourne l'adresse et la longueur
.Ok	move.l	Equ_Base(a5),a1
	move.l	-4(a1),d1
	movem.l	(sp)+,a0/d2/d3
	rts
; Erreur!
.Err	jsr	D_Close
	bsr	Equ_Free
	moveq	#52,d0
	bra	VerErr
;	Structure FLUSH pour les equates
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Equ_FlushStructure
	dc.l	0
; 	Libere le fichier d'equates (ne pas bouger!)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Equ_Free
	lea	Equ_Base(a5),a0
	bsr	A5_Free
	rts

; Routine, veut une variable numerique
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerVEnt	move.l	a6,-(sp)
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	bsr	VarA0
	tst.b	d0
	bne	VerType
	move.l	(sp)+,a6
	rts

; Routine, veut une variable seule alphanumerique
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerVarA:bsr	VerGV
	cmp.b	#"2",d2
	bne	VerType
	rts

; RouRoutine, veut une variable, SEULE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerGV:	move.l	a6,VerPos(a5)
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	and.b	#%00001111,3(a6)	RAZ du flag!
	bsr	VarA0
	cmp.w	#_TkPar1,(a0)		TABLEAU?
	bne.s	VGv1
	bset	#6,3(a6)		Met le flag tableau!
	move.b	3(a6),d3
	bsr	V1_StoVar		Le tableau doit etre cree avant
	bne	VerNDim
	bsr	VerTablo		Verifie les params d'un tableau
	bra.s	VGv2
VGv1:	bsr	V1_StoVar
VGv2:	rts



;					Verification des procedures
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; 	Instruction Proc
; ~~~~~~~~~~~~~~~~~~~~~~
V1_OnBreak
V1_Proc	tst.w	Direct(a5)
	bne	VerIlD
	bset	#0,VarBufFlg(a5)
	cmp.w	#_TkVar,(a6)		Un variable?
	beq.s	.Skip
	cmp.w	#_TkPro,(a6)		Un procedure
	bne	VerSynt
.Skip	move.l	a6,-(sp)
	addq.l	#2,a6
	bsr	V1_IVariable
	move.l	(sp)+,a0
	cmp.w	#_TkPro,(a0)
	bne	VerUndP
	bra	VerDP

;	Debut de procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~
V1_Procedure
	bset	#0,VarBufFlg(a5)
	subq.l	#2,a6
	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Phase(a5)
	bne	V1_ProcedureIn

; PHASE 0: Stocke et saute le nom et les params
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	subq.l	#1,VerNInst(a5)		Retabli le compte...
	btst	#6,8(a6)		Decoder la procedure?
	beq.s	.Skip0
	btst	#5,8(a6)
	beq.s	.Skip0
	bsr	ProCode
.Skip0	sub.l	a0,a0

	move.w	#_TkProc,d0
	moveq	#4,d1
	moveq	#1<<VF_Proc,d2
	bsr	Init_TablA

	move.l	a6,-(sp)
	move.l	a0,-(sp)

	lea	10(a6),a6
	cmp.w	#_TkVar,(a6)+		Stocke dans les labels
	bne	VerSynt
	and.b	#$0F,3(a6)
	or.b	#$80,3(a6)
	bsr	V1_StockLabel
	move.l	4(sp),4(a2)		Pointe le DEBUT de la procedure!
	cmp.w	#_TkBra1,(a6)
	bne.s	.NoPar

.Par	addq.l	#2,a6
	move.l	a6,VerPos(a5)
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	and.b	#$0F,3(a6)
	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	cmp.w	#_TkVir,(a6)
	beq.s	.Par
	move.l	a6,VerPos(a5)
	cmp.w	#_TkBra2,(a6)+
	bne	VerSynt

.NoPar	move.l	a6,VerPos(a5)
	move.w	(a6),d0
	bne	VerPDb
	addq.l	#2,a6
; Saute une procedure COMPILED/LANGAGE MACHINE
	move.l	4(sp),a0
	btst	#4,8(a0)		Langage machine?
	beq.s	.EPLoop
	cmp.w	#_TkAPCmp,2(a6)		Une procedure compilee AMOSPro?
	bne.s	.Noap
	move.l	a0,-(sp)
	lea	2(a6),a0		Va reloger
	bsr	Ver_APCmp
	bsr	SetNot1.3
	move.l	(sp)+,a0
.Noap	move.l	2(a0),d0		Et saute la procedure
	lea	12(a0,d0.l),a6
	bra.s	.Comp
; Cherhe le ENDPROC
	moveq	#0,d0
.EPLoop	move.b	(a6),d0
	beq	VerPOp
	move.w	2(a6),d1
	cmp.w	#_TkEndP,d1
	beq.s	.EndP
	cmp.w	#_TkSha,d1
	beq.s	.Shared
	cmp.w	#_TkGlo,d1
	beq.s	.Shared
.Resha	add.w	d0,a6
	add.w	d0,a6
	bra.s	.EPLoop
; Traite les variables shared
.Shared	movem.l	d0/a6,-(sp)		Appel de shared / Global
	addq.l	#2,a6
	bsr	VpSha
	movem.l	(sp)+,d0/a6
	bra.s	.Resha
; END PROC trouve, prend la ligne suivante
.EndP	add.w	d0,a6			Pointe la ligne suivante
	add.w	d0,a6
.Comp	subq.l	#2,a6			Zero de la ligne precedente
	move.l	(sp)+,a0		TablA
	move.l	(sp)+,a1		Debut procedure
	move.l	a6,Vta_Variable(a0)
	move.l	a6,a0
	sub.l	a1,a0			Poke la distance au END PROC
	lea	-10(a0),a0
	move.l	a0,2(a1)
; Termine
	addq.w	#2,a6
	bra	VerD

;	Procedure compilee: reloge le programme
;	A0= Instruction ||APCmp||
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_APCmp
	movem.l	a0-a6/d0-d7,-(sp)
	lea	2(a0),a6
	move.w	APrg_MathFlags(a6),d0	Prend les flags mathematiques
	or.b	d0,MathFlags(a5)
	lsr.w	#8,d0			Et le flag accessory...
	move.b	d0,Prg_Accessory(a5)
	lea	APrg_Relocation(a6),a1	Table de relocation
	add.l	(a1),a1
	lea	APrg_Program(a6),a2	Pointe le programme
	move.l	a2,d1
	sub.l	APrg_OldReloc(a6),d1	Ancienne relocation
	beq.s	.RFin			Deja reloge!
	move.l	a2,APrg_OldReloc(a6)
.RLoop	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	.RFin
	cmp.b	#1,d0
	bne.s	.RReloc
	lea	508(a2),a2
	bra.s	.RLoop
.RReloc	lsl.w	#1,d0
	add.l	d0,a2
	move.l	(a2),d0
	add.l	d1,(a2)
	bra.s	.RLoop
.RFin	movem.l	(sp)+,a0-a6/d0-d7
	rts

;	Procedure PHASE >0, Passe 1, stocke les variables!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_ProcedureIn
	btst	#4,8(a6)		Procedure Machine?
	bne.s	.PMach
	lea	12(a6),a6
	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	cmp.w	#_TkBra1,(a6)		Pointe les parametres
	bne	VerDP
.Loop	addq.l	#4,a6
	bsr	V1_StoVar
	cmp.w	#_TkVir,(a6)
	beq.s	.Loop
	addq.l	#2,a6
	bra	VerDP
.PMach	move.w	6(a6),VarLong(a5)	Recopie le nombre de params
	bra	VerX			Et on sort!

;	END PROC [expression]
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_EndProc
	tst.w	Direct(a5)
	bne	VerIlD
	tst.w	Phase(a5)
	beq	VerPNo
	cmp.w	#_TkBra1,(a6)+
	bne.s	.Skip
	bsr	Ver_Expression
.Skip	bra	VerX



;			Verification des test, boucles et branchements
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Flags pour table-A
VF_Boucles	equ	0
VF_If		equ	1
VF_Proc		equ	2
VF_Exit		equ	3
VF_Goto		equ	4
VF_Debug	equ	5

; 	FOR / Passe 1
; ~~~~~~~~~~~~~~~~~~~
V1_For	addq.w	#1,Ver_NBoucles(a5)	Une boucle de plus
	add.w	#TForNxt,Ver_PBoucles(a5)
	lea	V2_For(pc),a0
	moveq	#2,d1
	bsr	Init_TablABoucle
; Verification
	clr.w	(a6)+
	movem.l	a0/a6,-(sp)
	bsr	VerGV			La variable
	movem.l	(sp)+,a0/a1
	move.w	2(a1),Vta_Variable(a0)	Stocke l'offset de la variable
	cmp.b	#"0",d2
	bne	VerType
	move.w	d2,-(sp)		Verifie la suite
	cmp.w	#_TkEg,(a6)+		=
	bne	VerSynt
	bsr	Ver_Expression		Expression
	cmp.b	1(sp),d2		Meme type
	bne	VerType
	move.l	a6,VerPos(a5)
	cmp.w	#_TkTo,(a6)+		To
	bne	VerSynt
	bsr	Ver_Expression		Expression
	cmp.b	1(sp),d2		Meme type
	bne	VerType
	cmp.w	#_TkStp,(a6)		Step?
	bne.s	.Skip
	addq.l	#2,a6
	bsr	Ver_Expression		Expression
	cmp.b	1(sp),d2		Meme type
	bne	VerType
.Skip	addq.l	#2,sp			OK!
	bra	VerDP
;	FOR / Passe 2 : cherche le NEXT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_For	move.l	a0,a1
	move.w	#1<<VF_Boucles,d0	Flag � trouver
	move.w	Vta_NBoucles(a0),d1	Position de pile
	subq.w	#1,d1
	move.w	#_TkNxt,d2		Token � trouver
	bsr	Find_TablA
	beq	VerFoN			For without Next
	tst.b	Vta_UFlag(a0)		Une variable dans le NEXT?
	beq.s	.Skip
	move.w	Vta_Variable+4(a0),d0	La meme?
	cmp.w	Vta_Variable(a1),d0
	bne	VerFoN
.Skip	clr.l	Vta_Jump(a0)		NEXT pris en compte
; Doke la distance au NEXT dans le FOR
	move.l	Vta_Variable(a0),d0
	bsr	Doke_Distance
	rts
;	NEXT / Passe 1
; ~~~~~~~~~~~~~~~~~~~~
V1_Next
	subq.w	#1,Ver_NBoucles(a5)		Une boucle de moins
	sub.w	#TForNxt,Ver_PBoucles(a5)
	lea	VerNFo(pc),a0			Next without For
	move.w	#6,d1
	bsr	Init_TablABoucle
; Verification
	move.l	a0,-(sp)
	bsr	Finie				Une variable?
	beq.s	.Skip
	movem.l	a0/a6,-(sp)
	bsr	VerGV
	movem.l	(sp)+,a0/a1
	move.w	2(a1),Vta_Variable+4(a0)	Stocke pointeur variable
	addq.b	#1,Vta_UFlag(a0)		Flag pour For / Passe2
.Skip	move.l	(sp)+,a0
	bsr	Find_End			Trouve la fin du NEXT
	move.l	d0,Vta_Variable(a0)		Pour le for passe 2
	bra	VerDP

;	REPEAT / Passe1
; ~~~~~~~~~~~~~~~~~~~~~
V1_Repeat
	addq.w	#1,Ver_NBoucles(a5)	Une boucle de plus
	add.w	#TRptUnt,Ver_PBoucles(a5)
	lea	V2_Repeat(pc),a0
	moveq	#0,d1
	bsr	Init_TablABoucle
	clr.w	(a6)+
	bra	VerDP
;	REPEAT / Passe2
; ~~~~~~~~~~~~~~~~~~~~~
V2_Repeat
	move.l	a0,a1
	move.w	#1<<VF_Boucles,d0	Flag � trouver
	move.w	Vta_NBoucles(a0),d1	Position de pile
	subq.w	#1,d1
	move.w	#_TkUnt,d2		Token � trouver
	bsr	Find_TablA
	beq	VerRUn			Repeat without Until
	clr.l	Vta_Jump(a0)		Until pris en compte
; Doke la distance au NEXT dans le FOR
	move.l	Vta_Variable(a0),d0
	bsr	Doke_Distance
	rts
;	UNTIL / Passe 1
; ~~~~~~~~~~~~~~~~~~~~~
V1_Until
	subq.w	#1,Ver_NBoucles(a5)		Une boucle de moins
	sub.w	#TRptUnt,Ver_PBoucles(a5)
	lea	VerUnR(pc),a0
	moveq	#4,d1
	bsr	Init_TablABoucle
; Verification / Poke l'adresse de fin
	move.l	a0,-(sp)
	bsr	Ver_Expression
	bsr	Find_End
	move.l	(sp)+,a0
	move.l	d0,Vta_Variable(a0)
	bra	VerDP

;	WHILE / Passe1
; ~~~~~~~~~~~~~~~~~~~~
V1_While
	addq.w	#1,Ver_NBoucles(a5)	Une boucle de plus
	add.w	#TWhlWnd,Ver_PBoucles(a5)
	lea	V2_While(pc),a0
	moveq	#0,d1
	bsr	Init_TablABoucle
	clr.w	(a6)+
	bsr	Ver_Expression
	bra	VerDP
;	WHILE / Passe2
; ~~~~~~~~~~~~~~~~~~~~
V2_While
	move.l	a0,a1
	move.w	#1<<VF_Boucles,d0	Flag � trouver
	move.w	Vta_NBoucles(a0),d1	Position de pile
	subq.w	#1,d1
	move.w	#_TkWnd,d2		Token � trouver
	bsr	Find_TablA
	beq	VerWWn			Repeat without Until
	clr.l	Vta_Jump(a0)		Wend pris en compte
; Doke la distance au NEXT dans le FOR
	move.l	Vta_Variable(a0),d0
	bsr	Doke_Distance
	rts
;	WEND / Passe1
; ~~~~~~~~~~~~~~~~~~~
V1_Wend
	subq.w	#1,Ver_NBoucles(a5)	Une boucle de moins
	sub.w	#TWhlWnd,Ver_PBoucles(a5)
	lea	VerWnW(pc),a0
	moveq	#4,d1
	bsr	Init_TablABoucle
; Verification / Poke l'adresse de fin
	bsr	Find_End
	move.l	d0,Vta_Variable(a0)
	bra	VerDP


;	 DO / Passe1
; ~~~~~~~~~~~~~~~~~~
V1_Do	addq.w	#1,Ver_NBoucles(a5)		Une boucle de moins
	add.w	#TDoLoop,Ver_PBoucles(a5)
	lea	V2_Do(pc),a0
	moveq	#0,d1
	bsr	Init_TablABoucle
	clr.w	(a6)+
	bra	VerDP
;	DO / Passe2
; ~~~~~~~~~~~~~~~~~
V2_Do	move.l	a0,a1
	move.b	#1<<VF_Boucles,d0	Flag � trouver
	move.w	Vta_NBoucles(a0),d1	Position de pile
	subq.w	#1,d1
	move.w	#_TkLoo,d2		Token � trouver
	bsr	Find_TablA
	beq	VerDoL			Repeat without Until
; Doke la distance au NEXT dans le FOR
	clr.l	Vta_Jump(a0)		Loop pris en compte
	move.l	Vta_Variable(a0),d0
	bsr	Doke_Distance
	rts
;	LOOP / Passe1
; ~~~~~~~~~~~~~~~~~~~
V1_Loop
	subq.w	#1,Ver_NBoucles(a5)	Une boucle de moins
	sub.w	#TDoLoop,Ver_PBoucles(a5)
	lea	VerLDo(pc),a0
	moveq	#4,d1
	bsr	Init_TablABoucle
; Verification / Poke l'adresse de fin
	bsr	Find_End
	move.l	d0,Vta_Variable(a0)
	bra	VerDP

;	EXIT / Passe1
; ~~~~~~~~~~~~~~~~~~~
V1_Exit
	lea	V2_Exit(pc),a0
	moveq	#4,d1
	moveq	#1<<VF_Exit,d2
	bsr	Init_TablA
	clr.l	(a6)+
	move.l	#1,Vta_Variable(a0)
	cmp.w	#_TkEnt,(a6)
	bne	VerDP
	move.l	2(a6),Vta_Variable(a0)
	addq.l	#6,a6
	bra	VerDP
;	EXIT / Passe2
; ~~~~~~~~~~~~~~~~~~~
V2_ExitI
V2_Exit	move.l	a0,a1
	move.l	a6,a2
	move.l	Vta_Variable(a1),d3
	move.b	#1<<VF_Boucles,d0	Flag � trouver
	move.w	Vta_NBoucles(a0),d1	Position de pile
	sub.w	d3,d1
	bmi	VerNoL			Not enough loops
	moveq	#-1,d2			Pas de token
	bsr	Find_TablA
	beq	VerNoL			Not enough loops
; Loke dans le source
	move.l	Vta_Variable(a0),d0
	sub.l	a2,d0
	subq.l	#4,d0
	cmp.l	#$10000,d0
	bcc	VerSynt
	move.w	Vta_PBoucles(a1),d1
	sub.w	Vta_PBoucles(a0),d1
	move.w	d0,(a2)+		Distance a la fin
	move.w	d1,(a2)+		Decalage de la pile
	rts

;	EXIT IF / Passe1
; ~~~~~~~~~~~~~~~~~~~~~~
V1_ExitI
	lea	V2_ExitI(pc),a0
	moveq	#4,d1
	moveq	#1<<VF_Exit,d2
	bsr	Init_TablA
	move.l	a0,-(sp)
	clr.l	(a6)+
	bsr	Ver_ExpE
	move.l	(sp)+,a0
	move.l	#1,Vta_Variable(a0)
	cmp.w	#_TkVir,(a6)
	bne	VerDP
	cmp.w	#_TkEnt,2(a6)
	bne	VerSynt
	move.l	4(a6),Vta_Variable(a0)
	addq.l	#8,a6
	bra	VerDP

; 	IF Passe 1
; ~~~~~~~~~~~~~~~~
V1_If	lea	V2_If(pc),a0
	moveq	#8,d1
	moveq	#1<<VF_If,d2
	bsr	Init_TablA
	clr.w	(a6)+
	move.l	a6,Vta_Variable(a0)
	move.l	VDLigne(a5),Vta_Variable+4(a0)
; Verification
	move.l	a0,-(sp)
	bsr	Ver_ExpE
	move.l	(sp)+,a0
	cmp.w	#_TkThen,(a6)
	bne	VerDP
	addq.l	#2,a6
	move.l	a6,Vta_Variable(a0)
	move.b	#1,Vta_UFlag(a0)
	lea	V2_IfThen(pc),a1
	move.l	a1,Vta_Jump(a0)
	cmp.w	#_TkLGo,(a6)
	bne	VerLoop
	bsr	V1_SautLGoto
	bra	VerDP

; 	If non structure / Passe2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_IfThen
	move.l	a0,a1
; Cherche sur la meme ligne
	move.l	Vta_Variable+4(a1),d1
	moveq	#1,d2
.Loop	tst.l	(a0)
	beq.s	.NextL
	move.l	(a0),a0
	cmp.b	#1<<VF_If,Vta_Flag(a0)
	bne.s	.Loop
	cmp.l	Vta_Variable+4(a0),d1		Sur la meme ligne
	bne.s	.NextL
	cmp.w	#_TkElse,Vta_Token(a0)	Else?
	beq.s	.Moins
	cmp.w	#_TkIf,Vta_Token(a0)		If
	bne.s	.Loop
	addq.w	#1,d2
	bra.s	.Loop
.Moins	subq.w	#1,d2
	bne.s	.Loop
	lea	V2_ElseThen(pc),a2	Traitement du ELSE
	move.l	a2,Vta_Jump(a0)
	move.l	Vta_Variable(a0),d0
	moveq	#0,d2
	bra.s	V2_IfThenLabel
.NextL	move.l	Vta_Variable+4(a1),a6	Pointe la fin ligne
	moveq	#0,d0
	move.b	(a6),d0
	add.w	d0,a6
	lea	-2(a6,d0.w),a6
	move.l	a6,d0
	moveq	#0,d2
; Verifie le label goto apres le then
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_IfThenLabel
	move.l	a1,-(sp)
	bsr	V2_IfDoke
	move.l	(sp),a0
	move.l	Vta_Variable(a0),a6
	cmp.w	#_TkLGo,(a6)+
	bne.s	.Fin
	bsr	V2_FindLabel
	beq	VerUnd
	move.l	(sp),a0
	bsr	Goto_Loops
.Fin	addq.l	#4,sp
	rts


; 	If structure / Passe 2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_If	move.l	a0,a1
	move.w	#_TkElse,d1		Tokens a trouver
	move.w	#_TkElsI,d2
	move.w	#_TkEndI,d3
	bsr	Find_TablATest		Va chercher
	beq	VerIfE			If without EndIf
	move.w	Vta_Token(a0),d0	Trouve le traitement de la passe 2
	move.l	Vta_Variable(a0),a6	Adresse de saut
	cmp.w	d0,d1			Else ?
	beq.s	.j1
	cmp.w	d0,d2			Else If ?
	beq.s	.j2
	bsr	Find_End
	sub.l	a2,a2			End If >>> Rien!
	moveq	#0,d2
	bra.s	.j0
.j2	lea	V2_ElsI(pc),a2
	moveq	#1,d2
	move.l	a6,d0
	bra.s	.j0
.j1	lea	V2_Else(pc),a2
	moveq	#0,d2
	move.l	a6,d0
.j0	move.l	a2,Vta_Jump(a0)
; Doke dans le source, en tenant compte des boucles...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_IfDoke
	exg	a0,a1
	move.l	Vta_Prog(a0),a6
	bsr	Goto_Loops		Verifie la validite du saut
	sub.l	a6,d0
	subq.l	#2,d0
	cmp.l	#$10000,d0
	bcc	VerLong
	tst.w	d2
	beq.s	.Skip
	bset	#0,d0
.Skip	move.w	d0,(a6)+
	rts

; 	ELSE IF / Passe 1
; ~~~~~~~~~~~~~~~~~~~~~~~
V1_ElseIf
	lea	VerElI(pc),a0		Else without If
	moveq	#4,d1
	moveq	#1<<VF_If,d2
	bsr	Init_TablA
	clr.w	(a6)+
	move.l	a6,Vta_Variable(a0)	Adresse apres endif
	bsr	Ver_ExpE		Cherche l'expression
	bra	VerDP
; 	ELSE IF / Passe2
; ~~~~~~~~~~~~~~~~~~~~~~
V2_ElsI	move.l	a0,a1
.Loop	move.w	#_TkElse,d1		Tokens a trouver
	move.w	#_TkElsI,d2
	move.w	#_TkEndI,d3
	bsr	Find_TablATest		Va chercher
	beq	VerElI			Else without Endif
	move.w	Vta_Token(a0),d0	Trouve le traitement de la passe 2
	move.l	Vta_Variable(a0),a6	Adresse de saut
	cmp.w	d0,d1			Else ?
	beq.s	.j1
	cmp.w	d0,d2			Else If ?
	beq.s	.j2
	bsr	Find_End
	sub.l	a2,a2			End If >>> Rien!
	moveq	#0,d2
	bra.s	.j0
.j2	lea	V2_ElsI(pc),a2
	moveq	#1,d2
	move.l	a6,d0
	bra.s	.j0
.j1	lea	V2_Else(pc),a2
	moveq	#0,d2
	move.l	a6,d0
.j0	move.l	a2,Vta_Jump(a0)
	bra	V2_IfDoke

; 	ELSE Passe 1
; ~~~~~~~~~~~~~~~~~~
V1_Else	lea	VerElI(pc),a0		Else without If
	moveq	#8,d1
	moveq	#1<<VF_If,d2
	bsr	Init_TablA
	clr.w	(a6)+
	move.l	a6,Vta_Variable(a0)	Adresse apres endif
	move.l	VDLigne(a5),Vta_Variable+4(a0)
; Verification
	cmp.w	#_TkDP,(a6)
	beq	VerDP
	cmp.w	#_TkLGo,(a6)
	bne	VerLoop
	bsr	V1_SautLGoto
	bra	VerDP
; 	ELSE non structure, passe2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_ElseThen
	move.l	a0,a1
	move.l	Vta_Variable+4(a1),a6	Pointe la fin ligne
	moveq	#0,d0
	move.b	(a6),d0
	add.w	d0,a6
	lea	-2(a6,d0.w),a6
	move.l	a6,d0
	moveq	#0,d2
	bra	V2_IfThenLabel
; 	ELSE structure / Passe2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_Else	move.l	a0,a1
.Loop	moveq	#-1,d1			Tokens a trouver
	moveq	#-1,d2
	move.w	#_TkEndI,d3
	bsr	Find_TablATest		Va chercher
	beq	VerEIf			ENDIF without IF
	clr.l	Vta_Jump(a0)		Endif detecte >>> Pas d'erreur
	move.l	Vta_Variable(a0),a6	Adresse de saut
	bsr	Find_End
	moveq	#0,d2
	bra	V2_IfDoke

; 	ENDIF Passe 1
; ~~~~~~~~~~~~~~~~~~~
V1_EndI	lea	VerEIf(pc),a0		EndIf without If
	moveq	#4,d1
	moveq	#1<<VF_If,d2
	bsr	Init_TablA
	move.l	a6,Vta_Variable(a0)
	bra	VerDP

;	Gosub
; ~~~~~~~~~~~
V1_Gosub
	bsr	V1_GoLabel
	bra	VerDP

; 	Goto / Passe 1
; ~~~~~~~~~~~~~~~~~~~~
V1_Goto	moveq	#0,d1
	move.b	#1<<VF_Goto,d2
	lea	V2_Goto(pc),a0
	bsr	Init_TablA
	bsr	V1_GoLabel
	bra	VerDP
;	Goto / Passe 2
; ~~~~~~~~~~~~~~~~~~~~
V2_Goto	move.l	a0,-(sp)
	bsr	V2_GoLabel
	move.l	(sp)+,a0
	beq.s	.Skip
	bsr	Goto_Loops
.Skip	rts

;	On XX Goto / Gosub / Passe1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_On	move.l	a6,-(sp)
	clr.l	(a6)+
	bsr	Ver_ExpE
	move.w	(a6)+,d0
	cmp.w	#_TkGto,d0
	beq.s	.Goto
	cmp.w	#_TkGsb,d0
	beq.s	.Gosub
	cmp.w	#_TkPrc,d0
	bne	VerSynt
; Des procedures
; ~~~~~~~~~~~~~~
	clr.w	-(sp)
.Pro1	addq.w	#1,(sp)
	bsr	V1_GoProcedureNoParam
	cmp.w	#_TkVir,(a6)+
	beq.s	.Pro1
	bra.s	.Poke
; Des Goto
; ~~~~~~~~
.Goto	move.w	#_TkOn,d0
	moveq	#0,d1
	move.b	#1<<VF_Goto,d2
	lea	V2_OnGoto(pc),a0
	bsr	Init_TablA
.Gosub	clr.w	-(sp)
.Gto1	addq.w	#1,(sp)
	bsr	V1_GoLabel
	cmp.w	#_TkVir,(a6)+
	beq.s	.Gto1
; Poke le nombre dans le source
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Poke	subq.l	#2,a6
	move.w	(sp)+,d0
	move.l	(sp)+,a0
	move.w	d0,2(a0)		Poke le nombre de labels
 	move.l	a6,d0
	sub.l	a0,d0
	subq.l	#4,d0
	move.w	d0,(a0)			Poke la longueur de l'instruction
	bra	VerDP

;	On xx GOTO verifie les branchements
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_OnGoto
	bsr	V2_Goto
	cmp.w	#_TkVir,(a6)+
	beq.s	V2_OnGoto
	rts

;	On Error / Passe1
; ~~~~~~~~~~~~~~~~~~~~~~~
V1_OnError
	cmp.w	#_TkPrc,(a6)
	beq	VerLoop
	cmp.w	#_TkGto,(a6)
	bne	VerDP
	addq.l	#2,a6
	bra	V1_Goto

; 	Resume / Passe1
; ~~~~~~~~~~~~~~~~~~~~~
V1_Resume
	bsr	Finie
	beq	VerDP
	bra	V1_Goto
;	Resume Label
; ~~~~~~~~~~~~~~~~~~
V1_ResLabel
	bsr	Finie
	beq	VerDP
	bsr	V1_GoLabel
	bra	VerDP

;	AMOSPro: TRAP, veut une instruction juste apr�s!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerTrap	bsr	SetNot1.3		Non compatible!
	bsr	Finie
	bne	VerLoop
	moveq	#43,d0			Must be followed by an inst
	bra	VerErr

;	POP PROC
; ~~~~~~~~~~~~~~
V1_PopProc
	tst.w	Phase(a5)
	beq	VerPNo
	cmp.w	#_TkBra1,(a6)
	bne	VerDP
	addq.l	#2,a6
	bsr	Ver_Expression
	cmp.w	#_TkBra2,(a6)+
	beq	VerDP
	bra	VerSynt

;	EVERY n PROC / GOSUB
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_Every
	bsr	Ver_ExpE
	move.w	(a6)+,d0
	cmp.w	#_TkGsb,d0
	beq.s	.Skip
	cmp.w	#_TkPrc,d0
	bne	VerSynt
	bsr	V1_GoProcedureNoParam	Une procedure
	bra	VerDP
.Skip	bsr	V1_GoLabel		Gosub
	bra	VerDP

		RSRESET
Vta_Next	rs.l	1		0
Vta_Prev	rs.l	1		4
Vta_Token	rs.w	1		8
Vta_Flag	rs.b	1		10
Vta_UFlag	rs.b	1		11
Vta_Prog	rs.l	1		12
Vta_NBoucles	rs.w	1		16
Vta_PBoucles	rs.w	1		18
Vta_Jump	rs.l	1		20
Vta_Variable	equ	__RS		24

;	Initialisation generale de la table des boucles
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reserve_TablA
	bsr	Free_TablA
	lea	Ver_TablA(a5),a0
	move.l	a0,Ver_CTablA(a5)
	clr.l	Ver_PTablA(a5)
	clr.l	Ver_PrevTablA(a5)
	rts
;	Efface les buffers de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_TablA
	move.l	Ver_TablA(a5),d2
	beq.s	.Out
.Loop	move.l	d2,a1
	move.l	(a1),d2
	move.l	#TablA_Step,d0
	SyCall	MemFree
	tst.l	d2
	bne.s	.Loop
.Out	clr.l	Ver_TablA(a5)
	clr.l	Ver_FTablA(a5)
	rts
; 	Nouveau buffer de table
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
New_TablA
	movem.l	a1/d0/d1,-(sp)
	move.l	#TablA_Step,d0
	SyCall	MemFast
	beq	VerOut
	move.l	Ver_CTablA(a5),a1
	move.l	a0,(a1)
	move.l	a0,Ver_CTablA(a5)
	clr.l	(a0)+
	move.l	a0,Ver_PTablA(a5)
	lea	TablA_Step-8(a0),a1
	move.l	a1,Ver_FTablA(a5)
	movem.l	(sp)+,a1/d0/d1
	rts

; 	Creation d'une entree TablA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Init_TablABoucle
	moveq	#1<<VF_Boucles,d2
Init_TablA
	bset	#0,VarBufFlg(a5)
	move.l	a0,-(sp)
	move.l	Ver_PTablA(a5),a0
	lea	Vta_Variable(a0,d1.w),a1
	cmp.l	Ver_FTablA(a5),a1			Sorti de la table?
	bcs.s	.Ok
	bsr	New_TablA
	lea	Vta_Variable(a0,d1.w),a1

.Ok	move.l	a1,Ver_PTablA(a5)			Suivant
	clr.l	Vta_Next(a0)
	clr.l	Vta_Prev(a0)
	move.w	d0,Vta_Token(a0)			Token
	move.b	d2,Vta_Flag(a0)		  		Flag
	clr.b	Vta_UFlag(a0)				User-Flag
	move.l	a6,Vta_Prog(a0)				Position programme
	move.w	Ver_NBoucles(a5),Vta_NBoucles(a0)	Position pile
	move.w	Ver_PBoucles(a5),Vta_PBoucles(a0)	Position pile
	move.l	(sp)+,Vta_Jump(a0)			Jump Passe2

	move.l	Ver_PrevTablA(a5),d0			Branche au precedent
	beq.s	.Skip
	move.l	d0,a1
	move.l	a0,Vta_Next(a1)
	move.l	a1,Vta_Prev(a0)
.Skip	move.l	a0,Ver_PrevTablA(a5)
	rts

;	Trouve une boucle / structure apres (a0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Find_TablA
	tst.l	(a0)
	beq.s	.Not
	move.l	(a0),a0
	cmp.w	Vta_NBoucles(a0),d1	Bonne pile?
	bne.s	Find_TablA
	cmp.b	Vta_Flag(a0),d0		Bon flag?
	bne.s	Find_TablA
	tst.w	d2			Bon token?
	bmi.s	.Skip
	cmp.w	Vta_Token(a0),d2
	bne.s	Find_TablA
.Skip	move.w	Vta_Token(a0),d0
.Not	rts

;	Trouve un test structure apres (a0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Find_TablATest
	moveq	#0,d4
.Loop	tst.l	(a0)
	beq.s	.NFnd
	move.l	(a0),a0
	cmp.b	#1<<VF_If,Vta_Flag(a0)	Meme flag
	bne.s	.Loop
	tst.b	Vta_UFlag(a0)		Meme structure
	bne.s	.NoT
	move.w	Vta_Token(a0),d0
	cmp.w	#_TkIf,d0
	beq.s	.Plus
	tst.w	d4
	bne.s	.PaTst
	cmp.w	d0,d1
	beq.s	.Fnd
	cmp.w	d0,d2
	beq.s	.Fnd
	cmp.w	d0,d3
	bne.s	.Loop
.Fnd	tst.w	d0
	rts
.PaTst	cmp.w	#_TkEndI,d0
	bne.s	.Loop
	subq.w	#1,d4
	bpl.s	.Loop
.NFnd	moveq	#0,d0
	rts
.Plus	addq.w	#1,d4
	bra.s	.Loop
; No then in a structured loop
.NoT	move.l	Vta_Prog(a0),VerPos(a5)
	subq.l	#2,VerPos(a5)
	bra	VerNoT

;	Doke une distance
; ~~~~~~~~~~~~~~~~~~~~~~~
Doke_Distance
	sub.l	a6,d0
	subq.l	#2,d0
	cmp.l	#$10000,d0
	bcc	VerLong
	move.w	d0,(a6)+
	rts

; 	Trouve la veritable adresse de fin d'une instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Find_End
	move.l	a0,-(sp)
	move.l	a6,a0
	move.w	(a0),d0
	bne.s	.S1
	tst.w	2(a0)
	beq.s	.S2
	addq.l	#4,a0
	bra.s	.S2
.S1	cmp.w	#_TkDP,d0
	bne	VerSynt
	addq.l	#2,a0
.S2	move.l	a0,d0
	move.l	(sp)+,a0
	rts

;	Verification GOTO pas a l'interieur d'une boucle
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Goto_Loops
	move.w	Vta_NBoucles(a0),d1
	cmp.l	a6,d0
	bcc	.Avant
; Saut en arriere
; ~~~~~~~~~~~~~~~
.Arr	tst.l	Vta_Prev(a0)
	beq.s	.Ok
	move.l	Vta_Prev(a0),a0
	cmp.l	Vta_Prog(a0),d0
	bcs.s	.Arr
	cmp.w	Vta_NBoucles(a0),d1
	bcs	VerPaGo
	rts
; Saut en AVANT
; ~~~~~~~~~~~~~
.Avant	move.l	a0,a1
	tst.l	(a0)
	beq.s	.Ok
	move.l	(a0),a0
	cmp.l	Vta_Prog(a0),d0
	bcc.s	.Avant
	cmp.w	Vta_NBoucles(a1),d1
	bcs	VerPaGo
.Ok	rts


;	Saute un LABEL GOTO / Passe 1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_SautLGoto
	move.l	a6,VerPos(a5)
	cmp.w	#_TkLGo,(a6)+
	bne	VerSynt
	move.b	2(a6),d0
	ext.w	d0
	lea	4(a6,d0.w),a6
	rts

;					Verification des expressions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;	Veut une expression alphanumerique
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_ExpA
	bsr	Ver_Expression
	cmp.b	#"2",d2
	bne	VerType
	rts
;	Veut une expression entiere
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_ExpE
	bsr	Ver_Expression
	cmp.b	#"0",d2
	bne	VerType
	rts

;						Verification d'une expression
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_Expression
	move.l	a6,VerPos(a5)
	bsr	Ver_Evalue
	tst.w	Parenth(a5)
	bne	VerSynt
	rts
;					Boucle de verification d'une expression
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_Evalue
	clr.w	Parenth(a5)
Ver_REvalue
	move.w	#$7FFF,d0
	bra.s	Eva_1
Eva_0	move.w	d2,-(sp)
Eva_1	move.w	d0,-(sp)
	move.l	VerBase(a5),-(sp)
	bsr	Ver_Operande
	move.l	(sp)+,VerBase(a5)
Eva_Ret	move.w	(a6)+,d0
	cmp.w	(sp),d0
	bhi.s	Eva_0
	subq.l	#2,a6
	move.w	(sp)+,d1
	bpl.s	Eva_Fin
	move.w	(sp)+,d5
	lea	Tst_Jumps(pc),a0
	jmp	0(a0,d1.w)
Eva_Fin	cmp.w	#_TkPar2,d0
	beq.s	.Par
	rts
.Par	subq.w	#1,Parenth(a5)
	addq.l	#2,a6
	rts

;	Operateur mixte: Chiffre / String
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst_Mixte
	cmp.b	d2,d5
	bne	VerType
	bra	Eva_Ret
;	Operateur mixte de comparaison
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst_Comp
	cmp.b	d2,d5
	bne	VerType
	moveq	#"0",d2
	bra	Eva_Ret
;	Operateur puissance
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Tst_Puis
	or.b	#%00000011,MathFlags(a5)
; 	Operateur entier seulement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst_Chiffre
	cmp.b	d2,d5
	bne	VerType
	cmp.b	#"0",d2
	bne	VerType
	bra	Eva_Ret

;						V�rification d'un operande
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_Operande
	clr.w	-(sp)			Pas de signe devant
Ope_Loop
	move.w	(a6)+,d0
	beq	Ope_Fin1
	bmi.s	.Moins
	move.l	AdTokens(a5),a0
	move.b	1(a0,d0.w),d1
	ext.w	d1			Branche � la routine
	lsl.w	#2,d1
	jmp	.Jmp(pc,d1.w)
.Moins	cmp.w	#_TkM,d0		Signe moins devant?
	bne	VerSynt
	tst.w	(sp)			Deja un?
	bne	VerSynt
	addq.w	#1,(sp)
	bra	Ope_Loop

; Table des sauts directs aux operandes particuliers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Jmp	bra	Ope_Normal		00- Normal
	bra	VerSynt			01= Syntax error!
	bra	Ope_Fin1		02= Evaluation finie
	bra	Ope_Fin2		03= Evaluation finie par une virgule
	bra	Ope_Parenth		04= Ouverture de parenthese
	bra	Ope_Normal		05= Val!
	bra	Ope_Extension		06= Extension
	bra	Ope_Variable		07= Variable
	bra	Ope_Varptr		08= Varptr
	bra	Ope_Fn			09= FN
	bra	Ope_Not			0A= Not
	bra	Ope_XYMn		0B= X Menu
	bra	Ope_Equ			0C= Equ
	bra	Ope_Match		0D= Match
	bra	Ope_Array		0E- Array
	bra	Ope_MinMax		0F= Min
	bra	Ope_LVO			10= LVO
	bra	Ope_Struc		11= Struc
	bra	Ope_StrucS		12= Struc$
	bra	Ope_Math		13= Fonction math
	bra	Ope_ConstEnt		14= Constante Entiere
	bra	Ope_ConstFl		15= Constante Float
	bra	Ope_ConstDFl		16= Constante DFloat
	bra	Ope_ConstStr		17= Constante String
	bra	Ope_InstFonction	18= Instruction + Fonction
	bra	Ope_DejaTeste		19- Deja teste!
	bra	Ope_VReservee		1A- Variable reservee
; Fonctions speciales compilateur
	bra	Ope_Normal		1B- ParamE
	bra	Ope_Normal		1C- ParamF
	bra	Ope_Normal		1D- ParamS
	bra	Ope_Normal		1E- False
	bra	Ope_Normal		1F- True
	bra	Ope_MinMax		20- Max
	bra	Ope_Normal		21- Mid3
	bra	Ope_Normal		22- Mid2
	bra	Ope_Normal		23- Left
	bra	Ope_Normal		24- Right
	bra	Ope_Normal		25- Fonction dialogues
	bra	Ope_Normal		26- Selecteur de fichier
	bra	Ope_Normal		27- Btst


; 	Operande mathematique>>> met les flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Math
	or.b	#%00000011,MathFlags(a5)
	bra.s	Ope_Normal
; 	Nouvelle fonction normale AMOSPro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_ProNormal
	bsr	SetNot1.3
; 	Gestion d'un operande normal
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Normal
	move.l	a0,VerBase(a5)
	bsr	Ver_DInst		Pointe la definition
	move.w	d0,d2
	bsr	VerF			Va verifier
; Compute type in D2>>> float / integer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_CheckType
	addq.l	#2,sp
	moveq	#0,d0
	move.b	d2,d0
	sub.w	#"0",d0
	lsl.w	#1,d0
	jmp	.jmp(pc,d0.w)
.jmp	rts				0 Entier
	bra.s	.Float			1 Float
	rts				2 Chaine
	rts				3 Entier/Chaine ??? Impossible
	bra.s	.Indif			4 Entier/Float
.Math	bset	#1,MathFlags(a5)	Angle (=math)
.Float	bset	#0,MathFlags(a5)
.Indif	move.b	#"0",d2
	rts

; 	Gestion d'une variable reservee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_VReservee
	move.l	a0,VerBase(a5)
	bsr	Ver_DInst		Pointe la definition
	move.b	(a0)+,d2
	bsr	VerF
	bra	Ope_CheckType

; 	Operande deja teste +++ rapide (jamais une vreservee)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_DejaTeste
	bsr	Ver_DInst		Pointe la definition
	move.w	d0,d2
	bsr	VerF_DejaTeste		Va verifier
	bra.s	Ope_CheckType

; 	Une extension: toutes les possibilites
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Extension
	move.b	(a6)+,d1
	move.l	a6,-(sp)
	tst.b	(a6)+
	move.w	(a6)+,d0
	ext.w	d1
	lsl.w	#2,d1
	lea	AdTokens(a5),a0
	tst.l	0(a0,d1.w)
	beq	VerExN
	move.l	0(a0,d1.w),a0
	clr.w	-(sp)			Flag librairie 2.0 ou ancienne
	btst	#LBF_20,LB_Flags(a0)	Librarie 2.0?
	beq.s	.Old
	move.w	#-1,(sp)
; Verifie Fonction / Variable reservee, sans table!
.Old	move.l	a0,VerBase(a5)		Debut de tokenisation
	bsr	Ver_OlDInst
	move.w	d0,d2
	cmp.b	#"I",d2
	beq	VerSynt
	cmp.b	#"V",d2			Variable r�servee
	bne.s	.Skip
	move.b	(a0)+,d2
.Skip	bsr	VerF			Va verifier
; Poke le nombre de parametres
	tst.w	(sp)+			Le flag
	move.l	(sp)+,a0		Poke le nombre de params...
	beq.s	.Old2
	move.b	#-1,(a0)		Nouvelle extension: pas de params!
	bra	Ope_CheckType
.Old2	move.b	d0,(a0)			Ancienne extension: des params...
	bra	Ope_CheckType

;	Une instruction, essaie de trouver une fonction apres!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_InstFonction
	move.l	a0,VerBase(a5)
	lea	0(a0,d0.w),a0
.Loop0	move.l	a0,d1
	addq.l	#4,a0
.Loop1	tst.b	(a0)+
	bpl.s	.Loop1
	move.b	(a0)+,d2
	cmp.b	#"I",d2
	bne.s	.Ok
.Loop2	tst.b	(a0)+
	bpl.s	.Loop2
	move.b	-1(a0),d0
	cmp.b	#-3,d0
	bne	VerSynt
	move.w	a0,d0
	and.w	#$0001,d0
	add.w	d0,a0
	bra.s	.Loop0
; Trouve, change le token
.Ok	sub.l	VerBase(a5),d1
	move.w	d1,-2(a6)
	bsr	VerF

	bra	Ope_CheckType

; 	Fin: une virgule avant---> ommis!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Fin1
	cmp.w	#_TkVir,-4(a6)
	bne	VerSynt
; 	Fin, avec une virgule: le parametre est ommis
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Fin2
	subq.l	#2,a6
	moveq	#"0",d2
	tst.w	(sp)+
	bne	VerSynt
	rts

; 	Ouverture d'un parenthese
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Parenth
	addq.w	#1,Parenth(a5)
	bsr	Ver_REvalue
	addq.l	#2,sp
	rts

;	Variable en fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_Variable
	bsr	V1_FVariable
	addq.l	#2,sp
	rts

;	Varptr(var)
; ~~~~~~~~~~~~~~~~~
Ope_Varptr
	cmp.w	#_TkPar1,(a6)+
	bne	VerSynt
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	bsr	V1_FVariable
	cmp.w	#_TkPar2,(a6)+
	bne	VerSynt
	moveq	#"0",d2
	addq.l	#2,sp
	rts

;	Constante entiere
; ~~~~~~~~~~~~~~~~~~~~~~~
Ope_ConstEnt
	addq.l	#4,a6
	moveq	#"0",d2
	addq.l	#2,sp
	rts
; 	Constante string
; ~~~~~~~~~~~~~~~~~~~~~~
Ope_ConstStr
	move.w	(a6)+,d0		* Saute la chaine
	move.w	d0,d1
	and.w	#$0001,d1
	add.w	d1,d0
	lea	0(a6,d0.w),a6
	moveq	#"2",d2
	addq.l	#2,sp
	rts
; 	Constante float simple precision
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_ConstFl
	addq.l	#4,a6
	move.b	#1,Ver_SPConst(a5)
	bset	#0,MathFlags(a5)	Flag: un peu de maths!
	moveq	#"0",d2
	addq.l	#2,sp
	rts
; 	Constante float double precision
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_ConstDFl
	addq.l	#8,a6
	move.b	#1,Ver_DPConst(a5)
	bset	#0,MathFlags(a5)	Flag: un peu de maths!
	bsr	SetNot1.3		Non compatible!
	moveq	#"0",d2
	addq.l	#2,sp
	rts

;	=Array(a$())
; ~~~~~~~~~~~~~~~~~~
Ope_Array
	bsr	SetNot1.3		Non compatible
;	=Match(a$())
; ~~~~~~~~~~~~~~~~~~
Ope_Match
	move.l	a6,-(sp)
	move.l	a0,VerBase(a5)
	bsr	Ver_DInst
	bsr	VerF
	moveq	#"0",d2			BUG, type= 0, entier!
	move.l	(sp)+,a0
	btst	#6,5+2(a0)		La variable est-elle un tableau?
	bne	Ope_CheckType
	bra	VerSynt

;	=MIN / MAX
; ~~~~~~~~~~~~~~~~
Ope_MinMax
	cmp.w	#_TkPar1,(a6)+
	bne	VerSynt
	move.w	Parenth(a5),-(sp)
	bsr	Ver_Expression
	move.w	d2,-(sp)
	cmp.w	#_TkVir,(a6)+
	bne	VerSynt
	bsr	Ver_Evalue
	cmp.w	#-1,Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,d1
	cmp.b	d1,d2
	bne	VerType
	move.w	(sp)+,Parenth(a5)
	addq.l	#2,sp
	rts

;	NOT
; ~~~~~~~~~
Ope_Not	move.w	Parenth(a5),-(sp)
	bsr	Ver_Evalue
	tst.w	Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,Parenth(a5)
	cmp.b	#"2",d2
	beq	VerType
	addq.l	#2,sp
	rts

; 	= Fn AKJDKJS(k,d,d,d)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_OpeFn
	tst.w	-(sp)
Ope_Fn	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	and.b	#%00001111,3(a6)
	bset	#3,3(a6)
	bsr	VarA0
	move.w	d2,-(sp)
	bsr	V1_StoVar
	bne	VerNFn
* Verifie les parametres
	cmp.w	#_TkPar1,(a6)
	bne.s	VerFn3
	addq.l	#2,a6
	move.w	Parenth(a5),-(sp)
VerFn1	bsr	Ver_Evalue
	tst.w	Parenth(a5)
	bne.s	VerFn2
	cmp.w	#_TkVir,(a6)+
	beq.s	VerFn1
	bne	VerSynt
VerFn2	cmp.w	#-1,Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,Parenth(a5)
* Ok!
VerFn3	move.w	(sp)+,d2
	addq.w	#2,sp
	moveq	#0,d0
	rts

;	=XY MENU(,,) / =MENU(,,)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ope_XYMn
	bsr	VerTablo
	cmp.w	#MnNDim,d0
	bcc	VerSynt
	moveq	#"0",d2
	addq.l	#2,sp
	rts

;	STRUC / STRUC$
; ~~~~~~~~~~~~~~~~~~~~
Ope_Struc
	move.w	Parenth(a5),-(sp)
	bsr	VStru
	move.w	(sp)+,Parenth(a5)
	cmp.b	#7,d2
	bcc	VerType
	moveq	#"0",d2
	addq.l	#2,sp
	rts
Ope_StrucS
	move.w	Parenth(a5),-(sp)
	bsr	VStru
	move.w	(sp)+,Parenth(a5)
	cmp.b	#6,d2
	bne	VerType
	moveq	#"2",d2
	addq.l	#2,sp
	rts
; Equates / LVO
; ~~~~~~~~~~~~~
Ope_Equ	lea	Equ_Nul(pc),a0
	bra	VEqu
Ope_LVO	lea	Equ_LVO(pc),a0
VEqu	move.l	a6,a1
	addq.l	#6,a6
	cmp.w	#_TkPar1,(a6)+
	bne	VerSynt
	bsr	Equ_Verif
	cmp.w	#_TkPar2,(a6)+
	bne	VerSynt
	moveq	#"0",d2
	addq.l	#2,sp
	rts


; 					Verification instruction deja testee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerI_DejaTestee
	move.b	(a0)+,d0		Un parametre?
	bmi.s	.Ok
.Loop	move.l	a0,-(sp)
	bsr	Ver_Evalue		Evaluation
	move.l	(sp)+,a0
	tst.b	(a0)+			Un separateur?
	bmi.s	.Ok
	addq.l	#1,a0			Un autre parametre!
	addq.l	#2,a6			Saute le separateur
	bra.s	.Loop
.Ok	rts

;				Verification d'une instruction standart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Position dans la table de tokens
;	A6=	Instruction + 2
VerI:	move.w	d2,-(sp)
	pea	-2(a6)			* Adresse de l'instruction
	move.l	a0,-(sp)
	clr.w	-(sp)			* Position dans definition
	clr.l	-(sp)			* Chaine SOURCE
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.b	#-1,(sp)
	move.w	(a6),d0			* Fin ligne?
	bsr	FinieB
	beq	VerI6
* Compte les parametres
VerI2:	bsr	Ver_Evalue
	move.w	20(sp),d0
	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	VerI3
	subq.w	#1,d0
VerI3:	move.w	d0,20(sp)
	tst.w	Parenth(a5)
	bne	VerSynt
	moveq	#",",d2
	move.w	(a6),d1
	cmp.w	#_TkVir,d1
	beq.s	VerI4
	moveq	#"t",d2
	cmp.w	#_TkTo,d1
	bne	VerI6
VerI4:	addq.l	#2,a6
	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	VerI5
	subq.w	#1,d0
VerI5:	move.w	d0,20(sp)
 	bra.s	VerI2
* Compare la chaine cree aux parametres
VerI6:	bsr	VerC
* C'est bon: depile
	move.w	20(sp),d0		* Nombre de parametres!
	addq.w	#1,d0
	lsr.w	#1,d0
	lea	30(sp),sp
	move.w	(sp)+,d2
	rts

; 					Verification fonction deja testee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerF_DejaTeste
	move.b	(a0)+,d0		Un parametre?
	bmi.s	.Fin
	move.w	d2,-(sp)
	move.w	Parenth(a5),-(sp)
.Loop	addq.l	#2,a6			Parenth / Separateur
	move.l	a0,-(sp)
	bsr	Ver_Evalue			Evaluation
	move.l	(sp)+,a0
	tst.b	(a0)+			Un separateur?
	bmi.s	.Ok
	addq.l	#1,a0			Un autre parametre!
	bra.s	.Loop
.Ok	move.w	(sp)+,Parenth(a5)
	move.w	(sp)+,d2
.Fin	rts

;					Verification d'une fonction standart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerF:	move.w	d2,-(sp)
	move.w	Parenth(a5),-(sp)
	pea	-2(a6)			* Adresse de l'instruction
	move.l	a0,-(sp)		* Adresse definition
	clr.w	-(sp)			* Position dans definition
	clr.l	-(sp)			* Chaine SOURCE
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.b	#-1,(sp)
	cmp.w	#_TkPar1,(a6)
	bne	Verf6
	addq.l	#2,a6
	cmp.w	#_TkPar2,(a6)+
	beq	Verf6
	subq.l	#2,a6
* Compte les parametres
Verf2:	bsr	Ver_Evalue
	move.w	20(sp),d0
	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	Verf3
	subq.w	#1,d0
Verf3:	move.w	d0,20(sp)
	cmp.w	#-1,Parenth(a5)
	beq.s	Verf6
	tst.w	Parenth(a5)
	bne	VerSynt
	moveq	#",",d2
	move.w	(a6)+,d1
	cmp.w	#_TkVir,d1
	beq.s	Verf4
	moveq	#"t",d2
	cmp.w	#_TkTo,d1
	bne	VerSynt
Verf4:	move.b	d2,0(sp,d0.w)
	move.b	#-1,1(sp,d0.w)
	addq.w	#1,d0
	cmp.w	#19,d0
	bcs.s	Verf5
	subq.w	#1,d0
Verf5:	move.w	d0,20(sp)
	bra.s	Verf2
* Compare la chaine cree aux parametres
Verf6:	bsr	VerC
* C'est bon: depile et ramene le type
	move.w	20(sp),d0
	addq.w	#1,d0
	lsr.w	#1,d0
	lea	30(sp),sp
	move.w	(sp)+,Parenth(a5)
	move.w	(sp)+,d2
	rts

;	Verification standart: compare la chaine cree aux parametres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerC:	move.l	(sp)+,a2	* Adresse de retour
	lea	(sp),a0
	move.l	22(sp),a1	* Pas de definition: PROCEDURE!
	cmp.l	#0,a1
	beq	VerCF
* Pas de parametre?
	move.b	(a1),d1
	bpl.s	VerC0
	tst.b	(a0)
	bmi.s	VerCF
	bra.s	VerC3
VerC0:	tst.b	(a0)
	bmi.s	VerC3
* Explore les params
VerC1:	move.b	(a1)+,d1
	bmi.s	VerC4
	move.b	(a0)+,d0
	cmp.b	#"3",d1		Indifferent?
	beq.s	VerC1a
	cmp.b	#"2",d1		Chaine
	beq.s	.Comp
	moveq	#"0",d1		Sinon, un chiffre!
.Comp	cmp.b	d0,d1
	bne	VerType
VerC1a:	move.b	(a0)+,d0
	bmi.s	VerC2
	move.b	(a1)+,d1
	bmi.s	VerC4
	cmp.b	d0,d1
	beq.s	VerC1
	bra	VerC3
VerC2:	move.b	(a1)+,d1
	bpl.s	VerC3
* OK!
VerCF:	jmp	(a2)
* Essaie les params suivants
VerC3:	move.b	(a1)+,d1
	bpl.s	VerC3
VerC4:	cmp.b	#-2,d1		* Change le numero de l'instruction
	bne	VerSynt
	move.l	a1,d0
	btst	#0,d0
	beq.s	VerC5
	addq.l	#1,a1
	addq.l	#1,d0
VerC5:	sub.l	VerBase(a5),d0
	move.l	26(sp),a0
	move.w	d0,(a0)
	addq.l	#4,a1
VerC6:	tst.b	(a1)+
	bpl.s	VerC6
	lea	(sp),a0
	cmp.b	#"V",(a1)+
	bne.s	VerC1
	addq.l	#1,a1
	bra.s	VerC1

;	Pointe la liste des params d'une instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_DInst:
	add.w	d0,a0
	move.b	2(a0),d0
	ext.w	d0
	add.w	d0,a0
	move.b	(a0)+,d0
	bpl.s	.Skip
	subq.l	#1,a0
.Skip	rts

; DInst, ancienne maniere
; ~~~~~~~~~~~~~~~~~~~~~~~
Ver_OlDInst
	lea	4(a0,d0.w),a0
.Loop	tst.b	(a0)+
	bpl.s	.Loop
	move.b	(a0)+,d0
	bpl.s	.Skip
	subq.l	#1,a0
.Skip	rts


;				Verification / Stockage des variables
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;	Variable en INSTRUCTION: egalisation ou appel procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_IVariable
	move.w	#_TkVar,-2(a6)	Force le token
	and.b	#%00001111,3(a6)	RAZ du flag!
	bsr	VarA0
	moveq	#0,d4			Pour CallProc
	cmp.w	#_TkEg,(a0)		Egal=> egalisation (!)
	beq.s	.VVi1
	cmp.w	#_TkPar1,(a0)		Une procedure!
	bne	V1_CallProc
; Un tableau
; ~~~~~~~~~~
	move.w	d2,-(sp)
	bset	#6,3(a6)		Met le flag tableau!
	bsr	V1_StoVar
	bne	VerNDim
	bsr	VerTablo		Verifie les params d'un tableau
	cmp.b	4(a1),d0
	bne	VerIlP			Illegal numbre of dimensions
	bra.s	.VVi2
; Une variable normale
; ~~~~~~~~~~~~~~~~~~~~
.VVi1	move.w	d2,-(sp)
	bsr	V1_StoVar
; Verifie l'expression
; ~~~~~~~~~~~~~~~~~~~~
.VVi2	cmp.w	#_TkEg,(a6)+
	bne	VerSynt
	move.l	a6,VerPos(a5)
	bsr	Ver_Expression
	move.w	(sp)+,d0
	cmp.b	d0,d2
	bne	VerType
	rts

;	VARIABLE EN FONCTION
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_FVariable
	and.b	#%00001111,3(a6)	RAZ du flag
	bsr	VarA0
	cmp.w	#_TkPar1,(a0)
	bne	V1_StoVar
	bset	#6,3(a6)		Met le flag tableau!
	bsr	V1_StoVar
	bne	VerNDim
	bsr	VerTablo		Verifie les params d'un tableau
	cmp.b	4(a1),d0
	bne	VerIlP			Illegal numbre of dimensions
	rts

;	Routine, veut un appel de procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_GoProcedureParam
	moveq	#1,d4
	bra.s	GoPro
V1_GoProcedureNoParam
	moveq	#0,d4
GoPro	move.w	(a6)+,d0
	cmp.w	#_TkPro,d0
	beq.s	V1_CallProc
	cmp.w	#_TkVar,d0
	bne	VerSynt
; 	Appel de procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~
V1_CallProc
	tst.w	Direct(a5)
	bne	VerIlD
	move.b	#Reloc_Proc1,d0		Flag un appel de procedure
	bsr	New_Reloc		Force la relocation en V2
	bsr	VarA0
	move.w	#_TkPro,-2(a6)
	or.b	#$80,3(a6)		Change le flag
	move.l	a0,a6
; Saute les params
	move.l	a6,VerPos(a5)
	cmp.w	#_TkBra1,(a6)
	bne.s	.NopA
	tst.w	d4
	bne	VerSynt
.Loop	addq.l	#2,a6
	bsr	Ver_Expression
	move.b	#Reloc_Proc2,d0
	bsr	New_Reloc
	move.b	d2,d0			Stocke dans la table de relocation
	bsr	Out_Reloc
	cmp.w	#_TkVir,(a6)
	beq.s	.Loop
	move.l	a6,VerPos(a5)
	cmp.w	#_TkBra2,(a6)+
	bne	VerSynt
	move.b	#Reloc_Proc3,d0
	bsr	New_Reloc
.Out	rts
.NopA	move.b	#Reloc_Proc4,d0
	bsr	New_Reloc
	rts


; 	Appel de procedure passe2, premiere etape
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_CallProc1
	move.l	a6,VerPos(a5)
	moveq	#0,d0			Retrouve le label
	bsr	V2_FindLabelP
	beq	VerUndP
	move.l	d0,a3
	lea	12(a3),a3
	move.b	2(a3),d0
	ext.w	d0
	lea	4(a3,d0.w),a3		Pointe le debut de la procedure
	cmp.w	#_TkBra1,(a3)+
	beq.s	.Skip
	sub.l	a3,a3
.Skip	rts
;	Appel de procedure passe2, pas de parametre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_CallProc4
	move.l	a3,d0
	bne	VerIlP
	rts
;	Appel de procedure passe2, deuxieme etape
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_CallProc2
	move.l	a3,d0
	beq	VerIlP
	move.l	a6,VerPos(a5)
	cmp.w	#_TkBra2,(a3)
	beq	VerIlP
	cmp.w	#_TkVir,(a3)
	bne.s	.Sko
	addq.l	#2,a3
.Sko	move.b	5(a3),d1
	and.w	#$0F,d1
	cmp.w	#1,d1
	bne.s	.Skip
	moveq	#0,d1
.Skip	add.b	#"0",d1
	cmp.b	(a4)+,d1
	bne	VerType
	move.b	4(a3),d0
	ext.w	d0
	lea	6(a3,d0.w),a3
	rts
;	Appel de procedure passe3, derniere etape
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_CallProc3
	move.l	a6,VerPos(a5)
	cmp.w	#_TkBra2,(a3)
	bne	VerIlP
	rts

;		 					Stockage des labels
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;	Verification d'un label / Expression
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_GoLabel
	move.w	(a6),d0
	cmp.w	#_TkLGo,d0
	bne.s	.Skip
	move.w	#_TkVar,d0
	move.w	d0,(a6)
.Skip	cmp.w	#_TkVar,d0
	bne.s	.Expr
	move.b	5(a6),d2
	and.b	#$0F,d2
	bne.s	.Expr
; Est-ce REEELEMENT un label?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.b	4(a6),d0
	ext.w	d0
	lea	6(a6,d0.w),a0
	move.w	(a0),d0
	beq.s	.Label
	cmp.w	#_TkVir,d0
	beq.s	.Label
	bsr	FinieB
	bne.s	.Expr
; C'est un label GOTO! Change le token!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Label	move.w	#_TkLGo,(a6)+
	move.b	#Reloc_Label,d0		Un label
	bsr	New_Reloc		Relocation en passe2
	move.l	a0,a6
	rts
; C'est une expression: va evaluer!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Expr	bsr	Ver_Evalue
	rts

;	Retourne en D0 l'adresse d'un label, si vrai label
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_GoLabel
	cmp.w	#_TkLGo,(a6)+
	bne.s	.Nul
	move.w	(a6)+,d0
	move.l	LabHaut(a5),a0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	0(a0,d0.w),d0
	rts
.Nul	moveq	#0,d0
	rts

;	STOCKAGE D'UN LABEL / PASSE 1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_StockLabel
	move.w	Phase(a5),d0
	bsr	Get_Label
	bne	VerLb2
; Cree le label
; ~~~~~~~~~~~~~
	move.w	d1,d3
	move.l	LabBas(a5),a0		Baisse le bas des labels
	subq.l	#8,a0
	sub.w	d1,a0
	cmp.l	LabMini(a5),a0		Attention aux boucles
	bcs	VerVNm
	move.l	a0,LabBas(a5)
	move.l	a0,a2
	move.l	d0,(a0)+		Longueur / Flags / Phase
	lea	4(a6),a1
	addq.l	#4,a0
	lsr.w	#1,d3			Copie le nom
	subq.w	#1,d3
.N1	move.w	(a1)+,(a0)+
	dbra	d3,.N1
	lea	4(a6,d1.w),a6		Saute le label
	move.l	a6,a0			Trouve l'adresse de saut
	tst.w	(a0)
	bne.s	.N2
	tst.w	2(a0)			Pointe la ligne suivante si on peut
	beq.s	.N2
	addq.l	#4,a0
.N2	move.l	a0,4(a2)		Poke l'adresse, A2= pointeur
	rts

;	STOCKAGE LABEL PASSE 2 : essaie de retrouver le label
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_FindLabel
	move.w	Phase(a5),d0		Niveau de procedure
V2_FindLabelP
	bsr	Get_Label		Va chercher
	beq.s	.NFnd
; Label trouve, LOKE dans le listing / saute le label
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a0,a2
	addq.l	#4,a0
	sub.l	LabHaut(a5),a0
	move.w	a0,(a6)
	move.l	4(a2),d0
.NFnd	rts

; Routine: retrouve un label dans la liste. D0=Phase
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_Label
	move.b	3(a6),d2		Flag
	moveq	#0,d1
	move.b	2(a6),d1		Longueur du nom
	swap	d0
	move.b	d1,d0
	lsl.w	#8,d0
	move.b	d2,d0
	swap	d0
; Boucle de recherche + rapide
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	LabBas(a5),a0
	moveq	#0,d3
	move.b	(a0),d3
	beq.s	.Nouvo
.Loop	cmp.l	(a0),d0
	beq.s	.Test
.Loop2	lea	8(a0,d3.w),a0
	move.b	(a0),d3
	bne.s	.Loop
	bra.s	.Nouvo
.Test	lea	4(a6),a1
	lea	8(a0),a2
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
.Test2	cmp.w	(a1)+,(a2)+
	dbne	d4,.Test2
	tst.w	d4
	bpl.s	.Loop2
	move.w	#%00000,CCR		BNE: trouve, A0=adresse
	rts
.Nouvo	move.w	#%00100,CCR		BEQ: pas trouve
	rts


******* ENLEVE TOUS LES FLAGS VARIABLE GLOBALE!
Locale:	move.l	DVNmBas(a5),a0
	bra.s	LoK2
LoK1:	ext.w	d0
	cmp.b	#2,5(a0)
	beq.s	LoK0
	clr.b	5(a0)
LoK0:	lea	6(a0,d0.w),a0
LoK2:	move.b	(a0),d0
	bne.s	LoK1
	rts
******* MET TOUS LES FLAGS VARIABLE GLOBALE!
Globale:move.l	DVNmBas(a5),a0
	bra.s	GlK2
GlK1:	ext.w	d0
	move.b	#1,5(a0)
	lea	6(a0,d0.w),a0
GlK2:	move.b	(a0),d0
	bne.s	GlK1
	rts

;	STOCKAGE VARIABLE PASSE 1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V1_StoVar
	movem.l	d2/d3/a3/a4,-(sp)
	lea	4(a6),a0		* Pointe le nom
	move.l	a0,d0
	move.b	2(a6),d1
	ext.w	d1			* Longueur variable
	move.b	3(a6),d2		* Flag
	move.l	a6,a3

	tst.w	Phase(a5)
	beq.s	StV1
; Essaie de trouver les variables globales
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	DVNmBas(a5),a4		* Prend les noms GLOBAUX
	move.l	a4,a1
StV1a:	move.l	a1,a2
	move.b	(a1),d3
	beq.s	StV1
	ext.w	d3
	tst.b	5(a1)
	beq.s	StV1n
	cmp.w	d1,d3
	bne.s	StV1n
	cmp.b	1(a1),d2
	bne.s	StV1n
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	addq.w	#6,a1
	move.l	d0,a0
StV1b:	cmp.w	(a0)+,(a1)+
	bne.s	StV1n
	dbra	d4,StV1b
	move.l	a2,a1			* Ramene l'adresse variable
	move.l	a2,d0
	sub.l	DVNmHaut(a5),d0		* Offset / Table variables
	neg.w	d0			* >0===> GLOBALES!
	move.w	d0,(a6)
	moveq	#0,d0			* Deja existante
	bra	Rn1VFin			* Va terminer
StV1n:	lea	6(a2,d3.w),a1
	bra.s	StV1a

; Trouve la variable LOCALE!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
StV1:	move.l	VNmBas(a5),a4
	move.l	a4,a1
Rn1Va:	move.l	d0,a0
	move.l	a1,a2
	move.b	(a1)+,d3
	beq.s	Rn1Vx
	ext.w	d3
	cmp.b	d1,d3			* Longueur egale?
	bne.s	Rn1Vn
	cmp.b	(a1)+,d2		* Flag egal?
	bne.s	Rn1Vn
	tst.w	(a1)+			* Saute DIVERS
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	addq.w	#2,a1
Rn1Vb:	cmp.w	(a0)+,(a1)+
	bne.s	Rn1Vn
	dbra	d4,Rn1Vb
	moveq	#0,d0			* Variable deja existante
	bra.s	Rn1Vz
; Passe a la variable suivante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rn1Vn:	lea	6(a2,d3.w),a1
	bra.s	Rn1Va
; Cree la variable
; ~~~~~~~~~~~~~~~~
Rn1Vx:	lea	-6(a4),a2
	sub.w	d1,a2
	cmp.l	VNmMini(a5),a2
	bcs	VerNmO
	move.l	a2,VNmBas(a5)
	move.l	a2,a1
	move.b	d1,(a1)+		* Poke la longueur
	move.b 	d2,(a1)+		* Poke le flag
	move.w	VarLong(a5),(a1)+	* Pointeur
	clr.w	(a1)+			* Variables Locale-Non dim
	addq.w	#6,VarLong(a5)		* Place pour le type
; Si float DP, non tableau: variable sur 10 octets...
	cmp.b	#1,d2
	bne.s	.Skip
	tst.b	MathFlags(a5)
	bpl.s	.Skip
	addq.w	#4,VarLong(a5)
.Skip	move.w	d1,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	move.l	d0,a0
Rn1Vy:	move.w	(a0)+,(a1)+
	dbra	d3,Rn1Vy
	moveq	#-1,d0			* Variable nouvelle!
; Variable trouvee
; ~~~~~~~~~~~~~~~~
Rn1Vz:	move.l	a2,a1			* Ramene l'adresse variable
	sub.l	VNmHaut(a5),a2		* Offset / Table variables
	move.w	a2,(a6)
; Force la relocation en passe 2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rn1VFin	movem.l	(sp)+,d2/d3/a3/a4
	move.w	d0,-(sp)
	move.b	#Reloc_Var,d0
	bsr	New_Reloc		* Nouvelle relocation
	lea	4(a6,d1.w),a6		* Saute la variable
	tst.w	(sp)+			* Positionne le flag
	rts

;	STOCKAGE VARIABLE DEUXIEME PASSE: retrouve l'adresse
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
V2_StoVar
	lea	4(a6),a0		* Pointe le nom
	move.b	2(a6),d1
	ext.w	d1			* Longueur variable
	move.w	(a6),d3
	bpl.s	.Skip
; DOKE le pointeur, variable locale (<0!)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	VNmHaut(a5),a1
	lea	0(a1,d3.w),a1
	move.w	2(a1),(a6)
	bra.s	.Out
; Variable GLOBALE (>0!)
; ~~~~~~~~~~~~~~~~~~~~~~
.Skip	neg.w	d3
	move.l	DVNmHaut(a5),a1
	lea	0(a1,d3.w),a1
	move.w	2(a1),d0
	addq.w	#1,d0
	neg.w	d0
	move.w	d0,(a6)
.Out	rts

;	Saute le nom d'une variable / A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VarA0:	lea	2(a6),a0
	move.b	(a0)+,d1
	ext.w	d1
	move.b	(a0)+,d3
	move.b	d3,d0
	moveq	#"0",d2
	and.b	#%111,d0
	beq.s	.Skip
	cmp.b	#1,d0
	beq.s	.Skip
	moveq	#"2",d2
.Skip	add.w	d1,a0
	rts

;	Verifie les params d'un tableau
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VerTablo
	move.w	d2,-(sp)
	move.l	a1,-(sp)
	move.l	a6,VerPos(a5)
	cmp.w	#_TkPar1,(a6)+
	bne	VerSynt
	move.w	Parenth(a5),-(sp)
	clr.w	-(sp)
.VTab	move.l	a6,VerPos(a5)
	addq.w	#1,(sp)
	bsr	Ver_Evalue		Verifie les parametres
	cmp.b	#"0",d2
	bne	VerType
	tst.w	Parenth(a5)
	bne.s	.VTab1
	cmp.w	#_TkVir,(a6)+
	beq.s	.VTab
	bne	VerSynt
.VTab1	cmp.w	#-1,Parenth(a5)
	bne	VerSynt
	move.w	(sp)+,d0		Nombre de dimensions
	move.w	(sp)+,Parenth(a5)
	move.l	(sp)+,a1
	move.w	(sp)+,d2
	rts


;	Initialisation de la table de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reserve_Reloc
	bsr	Free_Reloc
	lea	Ver_Reloc(a5),a0
	move.l	a0,Ver_CReloc(a5)
	clr.l	Ver_FReloc(a5)
	clr.b	Ver_NoReloc(a5)
	sub.l	a4,a4
	rts
;	Efface les buffers de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_Reloc
	move.l	Ver_Reloc(a5),d2
	beq.s	.Out
.Loop	move.l	d2,a1
	move.l	(a1),d2
	move.l	#Reloc_Step,d0
	SyCall	MemFree
	tst.l	d2
	bne.s	.Loop
.Out	clr.l	Ver_Reloc(a5)
	clr.l	Ver_FReloc(a5)
	rts



;	Poke le pointeur actuel dans la table de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
New_Reloc
	tst.b	Ver_NoReloc(a5)		Relocation autorisee???
	bne.s	.Out
	cmp.l	Ver_FReloc(a5),a4	Sorti de la table?
	bcc.s	.NewBuf
	move.l 	d0,-(sp)
        move.l 	a6,d0
        sub.l 	a3,d0
	beq.s	.ReJ5
	bls.s	.Bug
.ReJ1	cmp.l 	#254,d0
        bls.s 	.ReJ4
	cmp.l	#254*3,d0
	bls.s	.ReJ3
	cmp.l	#65534,d0
	bls.s	.ReJ2
; >65534
	move.b	#Reloc_Long,(a4)+
	move.b	#$FF,(a4)+
	move.b	#$FE,(a4)+
	sub.l	#65534,d0
	bra.s	.ReJ1
; >254*3 <65536
.ReJ2	move.b	#Reloc_Long,(a4)+
	move.b	d0,1(a4)
	ror.w	#8,d0
	move.b	d0,(a4)
	addq.l	#2,a4
	bra.s	.ReJ5
; >254 <254*3
.ReJ3	move.b	#127,(a4)+
        sub.l 	#254,d0
        bra.s 	.ReJ1
; <254
.ReJ4	lsr.w	#1,d0
	move.b	d0,(a4)+
; Fini
.ReJ5	move.l 	a6,a3
        move.l	(sp)+,d0
	move.b	d0,(a4)+
.Out	rts
.Bug	illegal
; Nouveau buffer de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.NewBuf	tst.l	Ver_FReloc(a5)		Premiere table?
	beq.s	.Init
	move.b	#Reloc_NewBuffer,(a4)+	Code de changement
.Init	movem.l	a0/a1/d0/d1,-(sp)
	move.l	#Reloc_Step,d0
	SyCall	MemFastClear
	beq	VerOut
	move.l	Ver_CReloc(a5),a1
	move.l	a0,(a1)
	move.l	a0,Ver_CReloc(a5)
	move.l	a0,a4
	clr.l	(a4)+
	lea	Reloc_Step-32(a0),a0
	move.l	a0,Ver_FReloc(a5)
	movem.l	(sp)+,a0/a1/d0/d1
	bra	New_Reloc
; 	Simple sortie d'un chiffre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Out_Reloc
	tst.b	Ver_NoReloc(a5)		Relocation autorisee???
	bne.s	.Out
	move.b	d0,(a4)+
.Out	rts


******* SHARED a,b()

******* Routine SHARED: cree les variables
VpSha:	addq.l	#2,a6
VpSha1:	bsr	VpGv
	cmp.w	#_TkVir,(a6)+
	beq.s	VpSha1
	move.w	-(a6),d0
	move.l	a6,VerPos(a5)
	tst.w	d0
	bne	VerSynt
	rts
* Verification des variables
VpGv:	move.l	a6,VerPos(a5)
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
* Premiere passe
	and.b	#%00001111,3(a6)
	bsr	VarA0
	cmp.w	#_TkPar1,(a0)
	bne	V1_StoVar
	cmp.w	#_TkPar2,2(a0)
	bne	VerNoPa
	lea	4(a0),a6
	rts
******* Verification proprement dite
VerSha	bset	#0,VarBufFlg(a5)
	subq.l	#2,a6
	tst.w	Direct(a5)
	bne	VerIlD
* GLOBAL: Cree les variables
	move.l	DVNmBas(a5),-(sp)
	tst.w	Phase(a5)
	bne	VSh0a
	move.l	a6,-(sp)
	bsr	VpSha
	move.l	(sp)+,a6
	move.l	VNmBas(a5),(sp)
* Ok! verifie
VSh0a:	addq.l	#2,a6
* Passe 1
VSh1a:	move.l	a6,VerPos(a5)
	cmp.w	#_TkVar,(a6)+
	bne	VerSynt
	lea	4(a6),a0		* Pointe le nom
	move.l	a0,d0
	move.b	2(a6),d1
	ext.w	d1			* Longueur variable
	and.b	#%00001111,3(a6)
	move.b	3(a6),d2		* Flag
	lea	4(a6,d1.w),a6
	cmp.w	#_TkPar1,(a6)
	bne.s	Sh1d
	bset	#6,d2
	bset	#6,-1(a0)
	cmp.w	#_TkPar2,2(a6)
	bne	VerNoPa
	addq.l	#4,a6
* Cherche la variable dans les variables globales
Sh1d:	move.l	(sp),a1
Sh1a:	move.l	a1,a2
	move.b	(a1),d3
	beq	VerNDim			* PaG	* Pas une variable GLOBALE!
	ext.w	d3
	cmp.w	d1,d3
	bne.s	Sh1n
	cmp.b	1(a1),d2
	bne.s	Sh1n
	move.w	d3,d4
	lsr.w	#1,d4
	subq.w	#1,d4
	addq.w	#6,a1
	move.l	d0,a0
Sh1b:	cmp.w	(a0)+,(a1)+
	bne.s	Sh1n
	dbra	d4,Sh1b
	cmp.b	#2,5(a2)		* Already GLOBALE!
	beq.s	Sh1c
	move.b	#1,5(a2)		* Marque la variable
	tst.w	Phase(a5)
	bne.s	Sh1c
	addq.b	#1,5(a2)		* Devient globale!
	bra.s	Sh1c
Sh1n:	lea	6(a2,d3.w),a1
	bra.s	Sh1a
* Une autre variable?
Sh1c:	move.w	(a6)+,d0
	cmp.w	#_TkVir,d0
	beq	VSh1a
	addq.l	#4,sp
	tst.w	d0
	bne	VerShal
	bra	VerD

***********************************************************

******* Instruction finie??
Finie:	move.w	(a6),d0
FinieB:	beq.s	Finy
	cmp.w	#_TkDP,d0
	beq.s	Finy
	cmp.w	#_TkThen,d0
	beq.s	Finy
	cmp.w	#_TkElse,d0
Finy:	rts




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	NETTOYAGES DES VARIABLES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ClearVar
; - - - - - - - - - - - - -

	movem.l	d0-d7/a0-a6,-(sp)

; Variables du programme
; ~~~~~~~~~~~~~~~~~~~~~~
	lea	DebRaz(a5),a0
	lea	FinRaz(a5),a1
ClV1:	clr.w	(a0)+
	cmp.l	a1,a0
	bcs.s	ClV1
	clr.b	Test_Flags(a5)
; Initialisation du disque
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#$FFFFFFFF,IffMask(a5)
	moveq	#47,d0
	JJsr	L_Sys_GetMessage
	move.l	DirFNeg(a5),a1
ClV2:	move.b	(a0)+,(a1)+
	bne.s	ClV2
	move.w	PI_DirSize(a5),DirLNom(a5)
	clr.l	T_ClLast(a5)
	move.w	#$0A0D,ChrInp(a5)
; DREG/AREG
; ~~~~~~~~~
	lea	CallReg(a5),a0
	move.l	a5,(8+5)*4(a0)			* A5-> Datazone
	move.l	T_ClAsc(a5),(8+4)*4(a0)		* A4-> Clavier actuel
	move.l	Prg_Source(a5),(8+3)*4(a0)	* A3-> Bas du programme
	move.l	T_RastPort(a5),(8+0)*4(a0)	* A0-> Rastport
	move.l	DosBase(a5),7*4(a0)		* D7-> Dos Base
	move.l	T_GfxBase(a5),6*4(a0)		* D6-> Gfx Base
	move.l	T_IntBase(a5),5*4(a0)		* D5-> Int Base
	move.l	BasSp(a5),4*4(a0)		* D4-> BasSp
	lea	Ed_Config(a5),a1		* D3-> Configuration Base Editor
	move.l	a1,3*4(a0)
; Ferme toutes les routines appellees
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Sys_ClearRoutines(a5),a1
	SyCall	CallRoutines
; Initialisations diverses
; ~~~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_Bnk.EffTemp
	JJsr	L_Bnk.Change
	JJsr	L_MenuReset
	JJsr	L_Dia_WarmInit
; Plus de buffers!
; ~~~~~~~~~~~~~~~~
	bsr	ClearBuffers
; Init float
; ~~~~~~~~~~
	move.w	#-1,FixFlg(a5)
	clr.w	ExpFlg(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; 	Nettoie tous les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClearBuffers
	moveq	#0,d1
	bsr	ResVarBuf
	clr.w	VarBufFlg(a5)
	moveq	#0,d1
	bsr	ResVNom
	clr.w	Stack_Size(a5)
	bsr	Stack_Reserve
	rts

; 	Reservation de la memoire pour la pile
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Stack_Reserve
	move.w	Stack_CSize(a5),d0
	cmp.w	Stack_Size(a5),d0
	beq.s	.Ok
	tst.w	d0
	beq.s	.NoFree
	clr.w	Stack_CSize(a5)
	addq.w	#1,d0
	mulu	#Stack_ProcSize,d0
	move.l	BaLoop(a5),a1
	SyCall	MemFree
.NoFree	move.w	Stack_Size(a5),d0
	beq.s	.Ok
	move.w	d0,Stack_CSize(a5)
	addq.w	#1,d0
	mulu	#Stack_ProcSize,d0
	move.l	d0,d1
	SyCall	MemFastClear
	beq	.Out
	move.l	a0,BaLoop(a5)
	add.l	d1,a0
	move.l	a0,HoLoop(a5)
.Ok	move.w	Stack_CSize(a5),d0
	rts
.Out	moveq	#0,d0
	rts

;	RESERVE DE L'ESPACE POUR LES VARIABLES DIRECTES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ResDir:	movem.l	d0/d1/a0,-(sp)
	tst.w	TVMax(a5)
	bne.s	RsD3
	move.l	TabBas(a5),d1
	move.l	d1,a0
	sub.l	HiChaine(a5),d1
	bcs.s	RsD3
	moveq	#0,d0
	move.w	PI_TVDirect(a5),d0
	cmp.l	d1,d0
	bls.s	RsD1
	move.l	d1,d0
RsD1:	divu	#6,d0
	mulu	#6,d0
	subq.l	#6,d0
	beq.s	RsD3
	move.l	VarLoc(a5),-(a0)
	move.w	#$FFFF,-(a0)
	sub.l	d0,a0
	move.l	a0,VarLoc(a5)
	move.l	a0,TabBas(a5)
	move.w	d0,TVMax(a5)
	lsr.w	#1,d0
	subq.w	#1,d0
	bmi.s	RsD3
RsD2:	clr.w	(a0)+
	dbra	d0,RsD2
RsD3:	movem.l	(sp)+,d0/d1/a0
	rts

;	Reserve le buffer chaines / variables
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1= Taille
ResVarBuf
	move.l	VarBuf(a5),d0
	beq.s	Vbr1
	clr.l	VarBuf(a5)
	move.l	d0,a1
	move.l	VarBufL(a5),d0
	SyCall	MemFree
Vbr1	move.l	d1,d0
	beq.s	Vbr2
	SyCall	MemFastClear
 	beq	VerOut
	move.l	a0,VarBuf(a5)
	lea	0(a0,d1.l),a1
* Adresses dans ce buffer
	move.l	a1,LabHaut(a5)
	clr.w	-(a1)
	move.l	a1,LabBas(a5)
	clr.l	-(a1)
	move.w	#-1,-(a1)
	move.l	a1,VarGlo(a5)
	move.l	a1,TabBas(a5)
	move.l	a1,VarLoc(a5)
* Chaines
	move.l	a0,LoChaine(a5)
	move.l	a0,ChVide(a5)
	move.l	a0,ParamC(a5)
	clr.w	(a0)+
	move.l 	a0,HiChaine(a5)
	move.l	a0,LabMini(a5)
* Fini!
Vbr2	clr.w	VarLong(a5)
	clr.w	GloLong(a5)
	clr.w	TVMax(a5)
	move.l	d1,VarBufL(a5)
	rts

;	Reserve le buffer des noms de variable
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1= taille
ResVNom	move.l	VNmMini(a5),d0
	beq.s	RVn1
	clr.l	VNmMini(a5)
	move.l	d0,a1
	move.l	VNmLong(a5),d0
	clr.l	VNmLong(a5)
	SyCall	MemFree
RVn1	move.l	d1,d0
	beq.s	RVn2
	SyCall	MemFastClear
 	beq	VerOut
	move.l	a0,VNmMini(a5)
	move.l	d1,VNmLong(a5)
	add.l	d1,a0
	move.l	a0,DVNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,DVNmBas(a5)
	move.l	a0,VNmHaut(a5)
	clr.w	-(a0)
	move.l	a0,VNmBas(a5)
RVn2	rts

; Inclus les INCLUDES dans le programme courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_Includes
; Efface d'eventuels anciens
	bsr	Includes_Clear
; Demande un buffer
	lea	Prg_Includes(a5),a0
	move.l	#20*16,d0
	move.l	#Public|Clear,d1
	bsr	A5_Reserve
	beq	.XX
	move.l	a0,a3
; Explore le d�but
	move.l	Prg_Source(a5),a0
	move.l	a0,(a3)
	moveq	#0,d6
	moveq	#0,d7
	moveq	#0,d0
	bsr	Tk_FindL
	beq	.Inclus
.Incl1	cmp.w	#_TkIncl,2(a0)
	beq.s	.Inclu
	bsr	Tk_FindN
	bne.s	.Incl1
	bra	.Inclus
; Une inclusion
.Inclu	bsr	SetNot1.3		Non compatible!
	addq.w	#1,d7
	move.l	a0,d0
	sub.l	(a3),d0
	move.l	a0,(a3)
	add.l	d0,d6
	move.l	d0,4(a3)
; Ouvre le fichier, sauve le lock
	cmp.w	#_TkCh1,4(a0)
	bne	.SErr
	lea	6(a0),a0
	move.w	(a0)+,d0
	subq.w	#1,d0
	bmi	.SErr
	cmp.w	#107,d0
	bcc	.SErr
	move.l	Name1(a5),a1
.Incl2	move.b	(a0)+,(a1)+
	dbra	d0,.Incl2
	clr.b	(a1)
	move.l	#1005,d2
	jsr	D_Open
	beq	.DErr
; Verifie entete, prend la taille du source
	move.l	Buffer(a5),d2
	moveq	#16+4,d3
	jsr	D_Read
	bne	.DErr
	move.l	d2,a2
	move.l	d2,a1			Entete AMOSPRO
	lea	H_Pro(pc),a0
	moveq	#8-1,d0
.Ver1	cmp.b	(a0)+,(a1)+
	bne	.13
	dbra	d0,.Ver1
	bra.s	.Ver3
.13	move.l	d2,a1			Entete AMOS1.3
	lea	H_1.3(pc),a0
	moveq	#10-1,d0
.Ver2	cmp.b	(a0)+,(a1)+
	bne	.AErr
	dbra	d0,.Ver2
.Ver3	add.l	16(a2),d6		Taille du source
	move.l	16(a2),12(a3)
	move.l	Handle(a5),8(a3)	Sauve le lock
	clr.l	Handle(a5)
; Reprend le cours
	move.l	(a3),a0
	bsr	Tk_FindN
	move.l	a0,d0
	sub.l	(a3),d0
	move.l	d0,16(a3)
	lea	20(a3),a3
	move.l	a0,(a3)
	bra	.Incl1
; Reserve le buffer / Charge les programmes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Inclus	move.l	a0,d0
	sub.l	(a3),d0
	move.l	a0,(a3)
	move.l	d0,4(a3)
	tst.w	d7
	beq	.PaIncl
	add.l	d6,d0				Taille du dernier incluse
	addq.l	#4,d0
	move.l	#Public,d1
	lea	Prg_FullSource(a5),a0
	bsr	A5_Reserve
	beq	.MErr
	move.l	a0,a2
	move.l	Prg_Includes(a5),a3
	move.l	Prg_Source(a5),a4
; Copie le programme
.Copy	move.l	4(a3),d0
	lsr.l	#1,d0
	beq.s	.Copf
.Cop	move.w	(a4)+,(a2)+
	subq.l	#1,d0
	bne.s	.Cop
.Copf
; Charge le chunk
	move.l	8(a3),Handle(a5)
	beq.s	.X
	move.l	a2,d2
	move.l	12(a3),d3
	jsr	D_Read
	bne	.DErr
	add.l	d0,a2
	jsr	D_Close
	clr.l	8(a3)
; Le suivant!
	add.l	16(a3),a4		Saute le INCLUDE
	lea	20(a3),a3		Suivant
	bra.s	.Copy
; Fini
.X	clr.l	(a2)+
.XX	rts
; Pas d'include
; ~~~~~~~~~~~~~
.PaIncl	bsr	Includes_Clear
	rts
; Erreur dans les includes
; ~~~~~~~~~~~~~~~~~~~~~~~~
.MErr	moveq	#36,d0
	bra.s	.Err
.DErr	moveq	#45,d0
	bra.s	.Err
.AErr	moveq	#46,d0
	bra.s	.Err
.SErr	moveq	#35,d0
.Err	move.l	d0,-(sp)
	move.l	(a3),VerPos(a5)
; Ferme tous les fichiers
	jsr	D_Close
	move.l	Prg_Includes(a5),a3
.Clo	move.l	8(a3),d0
	beq.s	.Nx
	clr.l	8(a3)
	move.l	d0,Handle(a5)
	jsr	D_Close
.Nx	lea	20(a3),a3
	subq.w	#1,d7
	bne.s	.Clo
; Efface les zones
	bsr	Includes_Clear
; Erreur!
	move.l	(sp)+,d0
	bra	VerErr

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INCLUDES ET FIN DE PROGRAMME
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Effacement des buffers includes / Retour � la normale
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Includes_Clear
	movem.l	a0-a1/d0-d1,-(sp)
	lea	Prg_FullSource(a5),a0
	bsr	A5_Free
	lea	Prg_Includes(a5),a0
	bsr	A5_Free
	movem.l	(sp)+,a0-a1/d0-d1
	rts

; 	Transforme une adresse FullSource (eventuellement) en adresse Source
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Includes_Adr
	movem.l	a1/d0-d1,-(sp)
	move.l	Prg_Includes(a5),d1
	beq.s	.Out
	move.l	d1,a1
	lea	-20(a1),a1
	sub.l	Prg_FullSource(a5),a0
	moveq	#0,d1
	moveq	#0,d2
; Chunk de source
.Loop	lea	20(a1),a1
	add.l	4(a1),d2		Longueur de source
	cmp.l	d2,a0
	bcs.s	.Source
; Chunk d'include
	tst.l	12(a1)
	beq.s	.Out
	add.l	12(a1),d1		A soustraire au source
	sub.l	16(a1),d1		Sans l'include lui meme
	add.l	12(a1),d2
	cmp.l	d2,a0
	bcc.s	.Loop
; Dans un include
	move.l	(a1),a0
	bra.s	.Out
; Dans le source
.Source	sub.l	d1,a0
	add.l	Prg_Source(a5),a0
; Sortie
.Out	movem.l	(sp)+,a1/d0-d1
	rts


Equ_LVO	dc.b	10,"_LVO",0
Equ_Nul	dc.b	10,0
	even


; __________________________________________________________________________
;
; 					CHARGEMENTS / SAUVEGARDE PROGRAMMES
; __________________________________________________________________________
;
; Entete AMOS Basic
; ~~~~~~~~~~~~~~~~~
H_1.3	dc.b	"AMOS Basic v134 "
H_Pro	dc.b	"AMOS Pro101v",0,0,0,0
	even

; ___________________________________________________________________
;
; 	RUN programme general (A6)
;
;	D0=	0:Normal / 1:Accessoire / -1:PRUN
;	A1=	Adresse Errors
;	A2=	Patches lors du test
; ___________________________________________________________________
;
Prg_RunIt
	movem.l	a2-a6/d2-d7,-(sp)
	move.w	d0,d2
; Deja en route?
; ~~~~~~~~~~~~~~
	bsr	Prg_DejaRunned
	bne	.Deja
; Sauve les donnees courantes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Prg_Push
	bne	.Omm
; Va tester le programme
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	a1,Prg_JError(a5)
	bsr	Prg_SetBanks			Banques courantes
	JJsr	L_Bnk.Change			Envoie aux trappes
	clr.b	Prg_Not1.3(a6)			Non compatible au depart
	move.l	a2,d0				Premier affichage
	beq.s	.Skip1
	jsr	(a2)
.Skip1	bsr	ClearVar			Plus de variables
	bsr	PTest				Tests
	clr.b	Prg_StModif(a6)			Programme teste!
	move.b	VerNot1.3(a5),Prg_Not1.3(a6)	Stocke la comptibilite
	move.b	MathFlags(a5),Prg_MathFlags(a6)	Double precision
	move.l	a2,d0				Deuxieme affichage
	beq.s	.Skip2
	jsr	4(a2)
; Initialisation graphique
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Skip2	tst.w	d2			Un accessoire
	beq.s	.Nor
	bmi.s	.PRun
; Accessoire
	tst.b	Prg_Accessory(a5)	Vraiment un accessoire?
	beq.s	.Nor
; PRun
.PRun	JJsr	L_DefRunAcc
	JJsr	L_ReCop
	JJsr	L_WOption		AMOS en premier s'il faut!
	JJmp	L_New_ChrGet
; Programme normal
.Nor	move.w	#-1,DefFlag(a5)		Non, programme normal
	JJsr	L_DefRun1
	move.l	a2,d0
	beq.s	.Skip3
	jsr	8(a2)
.Skip3	JJsr	L_DefRun2
	JJsr	L_ReCop
	EcCalD	Active,0
	clr.b	Prg_Accessory(a5)
	JJsr	L_WOption		AMOS en premier s'il faut!
	JJmp	L_New_ChrGet
; Out of memory
; ~~~~~~~~~~~~~
.Omm	moveq	#0,d0
	bra.s	.Out
; Deja runned
; ~~~~~~~~~~~
.Deja	moveq	#-1,d0
.Out	movem.l	(sp)+,a2-a6/d2-d7
	rts
; ___________________________________________________________________
;
; 	TEST programme general (A6)
;
;	A1=	Adresse Errors
;	A2=	Patches lors du test
; ___________________________________________________________________
;
Prg_TestIt
	movem.l	a2-a6/d2-d7,-(sp)
	move.w	d0,d2
; Deja en route?
; ~~~~~~~~~~~~~~
	bsr	Prg_DejaRunned
	bne.s	.Deja
; Sauve les donnees courantes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Prg_Push
	bne	.Omm
; Va tester le programme
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	a1,Prg_JError(a5)
	bsr	Prg_SetBanks
	clr.b	Prg_Not1.3(a6)			Non compatible au depart
	move.l	a2,d0				Premier affichage
	beq.s	.Skip1
	jsr	(a2)
.Skip1	bsr	ClearVar			Plus de variables
	bsr	PTest				Tests
	clr.b	Prg_StModif(a6)			Programme teste!
	move.b	VerNot1.3(a5),Prg_Not1.3(a6)	Stocke la compatibilite
	move.b	MathFlags(a5),Prg_MathFlags(a6)	Double precision
	move.l	a2,d0				Deuxieme affichage
	beq.s	.Skip2
	jsr	4(a2)
.Skip2
; Depile le programme
; ~~~~~~~~~~~~~~~~~~~
	bsr	Prg_Pull
	moveq	#0,d0
.Out	movem.l	(sp)+,a2-a6/d2-d7
	rts
; Deja runned
; ~~~~~~~~~~~
.Deja	moveq	#-1,d0
	bra.s	.Out
; Out of memory
; ~~~~~~~~~~~~~
.Omm	moveq	#0,d0
	bra.s	.Out

;
; Regarde si le programme A6 est deja RUNNE!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_DejaRunned
	movem.l	a0-a1/d0-d1,-(sp)
	move.l	Prg_Runned(a5),d0
	beq.s	.Ok
.DejaL	move.l	d0,a0
	cmp.l	a0,a6
	beq.s	.Deja
	move.l	Prg_Previous(a0),d0
	bne.s	.DejaL
.Ok	moveq	#0,d0
	bra.s	.Out
.Deja	moveq	#-1,d0
.Out	movem.l	(sp)+,a0-a1/d0-d1
	rts

;
; STOCKAGE DES DONNEES DU PROGRAMME A6
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Prg_Push
	movem.l	a0-a4/a6/d1-d7,-(sp)
	move.l	Prg_Runned(a5),d0
	move.l	a6,Prg_Runned(a5)
	move.l	d0,Prg_Previous(a6)
	beq	.Ok
; Programme en route, stocke les donn�es pour les programmes suivants
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_Previous(a6),a0
	lea	Prg_RunData(a0),a0
	bsr	Prg_DataSave
	beq	.Err
; Prepare le nouveau programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Prg_DataNew
; Pas d'erreur
; ~~~~~~~~~~~~
.Ok	moveq	#0,d0
.Out	movem.l	(sp)+,a0-a4/a6/d1-d7
	rts
; Out of mem
; ~~~~~~~~~~
.Err	move.l	Prg_Previous(a6),Prg_Runned(a5)
	clr.l	Prg_Previous(a6)
	moveq	#-1,d0
	bra.s	.Out

;
; RESTAURATION DES DONNEES DU PROGRAMME POUSSE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Prg_Pull
	movem.l	a0-a4/a6/d0-d7,-(sp)
	move.l	Prg_Runned(a5),d0
	beq.s	.Skip
	move.l	d0,a6			Prend l'ancien programme
	move.l	Prg_Previous(a6),d0	Programme precedent
	clr.l	Prg_Previous(a6)	Plus de programme precedent!
	move.l	d0,Prg_Runned(a5)	Le programme actuel
	beq.s	.Skip			Si dernier programme, on garde tout!
; Efface les variables
; ~~~~~~~~~~~~~~~~~~~~
	bsr	ClearVar
	bsr	Includes_Clear
; Efface la structure programme ancienne, si non editee...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	Prg_Edited(a6)
	bne.s	.Edited
	bsr	Prg_DelStructure
.Edited
; Remet les donnees
; ~~~~~~~~~~~~~~~~~
	move.l	Prg_Runned(a5),a6
	lea	Prg_RunData(a6),a0
	bsr	Prg_DataLoad
; Fini!
; ~~~~~
.Skip	movem.l	(sp)+,a0-a4/a6/d0-d7
	rts

;
; Programme en route, stocke les donn�es pour les programmes suivants
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse ou poker la structure
;
Prg_DataSave
	move.l	#FinSave-DebSave+4+4+4*32,d0
	move.l	#Public|Clear,d1
	bsr	A5_Reserve
	beq	.Err
	move.l	a0,a1
; Sauve les donnees
; ~~~~~~~~~~~~~~~~~
	lea	DebSave(a5),a0
	move.w	#(FinSave-DebSave)/2-1,d0
.Copy1	move.w	(a0)+,(a1)+
	dbra	d0,.Copy1
; Sauve la liste CLEARVAR
; ~~~~~~~~~~~~~~~~~~~~~~~
	lea	Sys_ClearRoutines(a5),a2
	move.l	(a2),d0
.Loop	move.l	d0,(a1)+
	beq.s	.Out
	move.l	d0,a0
	move.l	(a0),d0
	lsl.l	#1,d0
	bra.s	.Loop
.Out
; Pas d'erreur
; ~~~~~~~~~~~~
	moveq	#-1,d0
	rts
.Err	moveq	#0,d0
	rts

;
; Remet les donn�es pour retour de programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse ou prendre la structure
;
Prg_DataLoad
	move.l	a0,a2
	move.l	(a2),a0
	lea	DebSave(a5),a1
	move.w	#(FinSave-DebSave)/2-1,d0
.Copy1	move.w	(a0)+,(a1)+
	dbra	d0,.Copy1
; Remet la liste CLEARVAR
; ~~~~~~~~~~~~~~~~~~~~~~~
	lea	Sys_ClearRoutines(a5),a1
	move.l	(a0)+,d0
	move.l	d0,(a1)
	bra.s	.In
.Loop	move.l	d0,a1
	move.l	(a0)+,d0
	move.l	d0,d1
	lsr.l	#1,d1
	bset	#31,d1
	move.l	d1,(a1)
.In	tst.l	d0
	bne.s	.Loop
; Remet le moniteur s'il faut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	Cur_ChrJump(a5),d0
	JJsr	L_SetChrPatch
; Les banques ont change
; ~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_Bnk.Change
; Efface la zone de donn�es
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a2,a0
	bsr	A5_Free
	moveq	#0,d0
	rts

; Nettoie les structures interpreteur pour appel en boucle
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_DataNew
	clr.l	VarBuf(a5)		Plus de buffers
	clr.l	VNmMini(a5)
	clr.w	Stack_Size(a5)
	clr.w	Stack_CSize(a5)
	clr.l	MnBase(a5)		Plus de menus
	clr.w	OMnNb(a5)
	clr.l	OMnBase(a5)
	clr.l	Prg_Includes(a5)	Plus d'includes
	clr.l	Prg_FullSource(a5)
	clr.l	Patch_Errors(a5)	Plus de moniteur
	clr.l	Patch_Menage(a5)
	clr.l	Patch_ScFront(a5)
	clr.l	Patch_ScCopy(a5)
	bclr	#1,ActuMask+1(a5)
	moveq	#0,d0
	JJsr	L_SetChrPatch
	clr.b	Ed_Zappeuse(a5)		Plus de zappeuse
	clr.b	Prg_Accessory(a5)	Plus une accessoire
	lea	Fichiers(a5),a0		Plus de fichiers
	moveq	#NFiche-1,d0
.New1	clr.l	(a0)
	lea	TFiche(a0),a0
	dbra	d0,.New1
	lea	Dev_List(a5),a0		Plus de devices (12 byte/device)
	moveq	#(3*Dev_Max)-1,d0
.New2	clr.l	(a0)+
	dbra	d0,.New2
	lea	Lib_List(a5),a0		Plus de librairies
	moveq	#Lib_Max-1,d0
.New3	clr.l	(a0)+
	dbra	d0,.New3
	rts

;
; Ouvre une structure de programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	IN	D0=	Longueur buffer
;	OUT	D0=	0(rate) Structure(reussi)
Prg_NewStructure
	movem.l	d2/a6,-(sp)
	move.l	d0,d2
; Reserve la structure
	move.l	#Prg_Long,d0
	SyCall	SyFast
	beq	.Err2
	move.l	d0,a0
; Insere dans la liste
	move.l	Prg_List(a5),Prg_Next(a0)
	move.l	a0,Prg_List(a5)
; Reserve le buffer
	move.l	a0,a6
	move.l	d2,d0
	bsr	Prg_ChgTTexte
	beq.s	.Err1
	move.l	a6,d0
	movem.l	(sp)+,d2/a6
	rts
; Rate: efface le buffer
.Err1	bsr	Prg_DelStructure
.Err2	moveq	#0,d0
	movem.l	(sp)+,d2/a6
	rts

;
; Ferme une structure de programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	IN	A6=	Adresse structure
Prg_DelStructure
	movem.l	a0-a6/d0-d7,-(sp)
; Efface le programme
	tst.l	Prg_StTTexte(a6)	Efface programme + Banques
	beq.s	.Skip
	bsr	Prg_SetBanks
	bsr	ClearVar
	JJsr	L_Bnk.EffAll		Enleve les banques
	moveq	#0,d0			Efface le buffer de texte
	bsr	Prg_ChgTTexte
; Enleve de la liste
.Skip	move.l	a6,a1			Enleve de la liste
	move.l	Prg_List(a5),d0
	cmp.l	d0,a6
	beq.s	.First
.Loop	move.l	d0,a0
	move.l	Prg_Next(a0),d0
	cmp.l	d0,a6
	bne.s	.Loop
	move.l	Prg_Next(a6),Prg_Next(a0)
	bra.s	.End
.First	move.l	Prg_Next(a6),Prg_List(a5)
; Efface la structure
.End	move.l	#Prg_Long,d0		Efface la structure
	move.l	a6,a1
	SyCall	SyFree
	movem.l	(sp)+,a0-a6/d0-d7
	rts

;
; Programme A6 >>> Programme courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_ReSetBanks
	move.l	a6,-(sp)
	move.l	Prg_Runned(a5),a6
	bsr.s	Prg_SetBanks
	move.l	(sp)+,a6
	rts
Prg_SetBanks
	move.l	a0,-(sp)
	lea	Prg_Banks(a6),a0
	move.l	a0,Cur_Banks(a5)
	lea	Prg_Dialogs(a6),a0
	move.l	a0,Cur_Dialogs(a5)
	move.l	Prg_StBas(a6),Prg_Source(a5)
	move.l	(sp)+,a0
	rts

; New du program A6 - D0=0 Pas de DEFRUN 1- DEFRUN -2-DEFRUN sans ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_New	move.w	d0,-(sp)
; Plus rien dans le buffer
	clr.w	Prg_NLigne(a6)
	tst.l	Prg_StTTexte(a6)
	beq.s	.Vide
	move.l	Prg_StHaut(a6),a0
	clr.w	-(a0)
	move.l	a0,Prg_StBas(a6)
; Plus de nom!
	clr.b	Prg_NamePrg(a6)
	clr.b	Prg_Change(a6)
	move.b	#1,Prg_StModif(a6)
	clr.b	Prg_MathFlags(a6)
; Raz des banques
.Vide	clr.b	T_Actualise(a5)
	bsr	Prg_SetBanks
	JJsr	L_Bnk.EffAll
	bsr	ClearVar
; Raz de l'affichage
	move.w	(sp)+,d0
	beq.s	.Skip
	move.w	d0,DefFlag(a5)
	JJsr	L_DefRun1
	JJsr	L_DefRun2
.Skip	rts

;
; Change la taille du buffer de texte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	IN	D0=	Nouvelle taille
;		A6= 	Structure programme
;	OUT	D0=	0(rate) StBas(reussi)
Prg_ChgTTexte
	movem.l	d1/a1,-(sp)
	and.l	#$FFFFFFFE,d0
	move.l	d0,d1
	move.l	Prg_StTTexte(a6),d0
	beq.s	.Ctt1
	move.l	Prg_StMini(a6),a1
	SyCall	MemFree
	clr.l	Prg_StTTexte(a6)
.Ctt1	move.l	d1,d0
	beq.s	.Ctt2
	SyCall	MemFastClear
	beq.s	.Ctt3
	move.l	d1,Prg_StTTexte(a6)	Raz du programme
	move.l	a0,Prg_StMini(a6)
	add.l	d1,a0
	move.l	a0,Prg_StHaut(a6)
	clr.w	-(a0)
	move.l	a0,Prg_StBas(a6)
; Ok!
.Ctt2	move.l	a0,d0
.Ctt3	movem.l	(sp)+,d1/a1
	rts
;
; Charge un programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	IN	Name1=	nom du programme
;		A6	structure dans laquelle charger
;		D0=	<1: TOUJOURS adapter
;			=0: Adapter si necessaire
;			>0: Revenir si trop petit
Prg_Load
	movem.l	a2-a4/d2-d7,-(sp)
	move.w	d0,-(sp)
	move.l	#1005,d2
	jsr	D_Open
	beq	.DErr
; Verifie l'entete 1.3 ou pro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),d2
	moveq	#16+4,d3
	jsr	D_Read
	bne	.DErr
	move.l	d2,a2
	clr.b	Prg_MathFlags(a6)
; 1.3?
	clr.b	Prg_Not1.3(a6)
	lea	H_1.3(pc),a0
	move.l	d2,a1
	moveq	#10-1,d0
.Ver1	cmp.b	(a0)+,(a1)+
	bne.s	.P13
	dbra	d0,.Ver1
	moveq	#0,d7
	bra.s	.Load
; Pro?
.P13	move.b	#1,Prg_Not1.3(a6)
	lea	H_Pro(pc),a0
	move.l	d2,a1
	moveq	#8-1,d0
.Ver2	cmp.b	(a0)+,(a1)+
	bne	.PAmos
	dbra	d0,.Ver2
	move.l	d2,a1			Prend le flag maths...
	move.b	15(a1),d7
; Verifie la taille du buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Load	move.l	16(a2),d3
	move.l	d3,d1
	tst.w	(sp)
	beq.s	.Sine
	bmi.s	.2Joor
; Charge si possible
	cmp.l	Prg_StTTexte(a6),d1
	blt.s	.CBon
	add.l	#256,d1
	bra.s	.Papo
; Adapter si necessaire
.Sine		cmp.l	Prg_StTTexte(a6),d1
	blt.s	.CBon
; Adapter!
.2Joor	add.l	#256,d1
	move.l	d1,d0
	bsr	Prg_ChgTTexte
	beq.s	.MErr
.CBon	move.l	Prg_StHaut(a6),a0
	clr.w	-(a0)
	move.l	a0,d2
	sub.l	d3,d2
; Charge le fichier
; ~~~~~~~~~~~~~~~~~
	jsr	D_Read
	bne	.DErr
	move.l	d2,Prg_StBas(a6)
; Charge les banques
; ~~~~~~~~~~~~~~~~~~
	bsr	Prg_SetBanks
	move.l	#EntNul,d0
	JJsr	L_Bnk.Load
	bne	.Out
; Change le nom
; ~~~~~~~~~~~~~
	move.l	Name1(a5),a0
	lea	Prg_NamePrg(a6),a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
; Programme non modifie
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Prg_CptLines
	clr.b	Prg_Change(a6)
	move.b	d7,Prg_MathFlags(a6)
	moveq	#0,d0
	bra.s	.Out
; Erreur de disque
; ~~~~~~~~~~~~~~~~
.DErr	moveq	#-1,d0
	bra.s	.Out
; Out of mem
; ~~~~~~~~~~
.MErr	moveq	#-2,d0
	bra.s	.Out
; Pas un programme AMOS
; ~~~~~~~~~~~~~~~~~~~~~
.PAmos	moveq	#-3,d0
	bra.s	.Out
; Impossible de charger: buffer trop petit
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Papo	moveq	#1,d0
; Ferme le fichier et sort
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Out	jsr	D_Close
	addq.l	#2,sp
	movem.l	(sp)+,a2-a4/d2-d7
	tst.l	d0
	rts
;
; COMPTE LE NOMBRE DE LIGNES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_CptLines
	move.l	Prg_StBas(a6),a0
	moveq	#0,d0
	moveq	#0,d1
CpL1	add.w	d1,a0
	add.w	d1,a0
CpL2	move.b	(a0),d1
	beq.s	CpLx
	addq.w	#1,d0
	cmp.w	#_TkProc,2(a0)
	bne.s	CpL1
; Saute une procedure fermee
	tst.b	10(a0)
	bpl.s	CpL1
	add.l	4(a0),a0
	moveq	#(10+2+2)/2,d1
	bra.s	CpL1
; Nombre de lignes
CpLx	move.w	d0,Prg_NLigne(a6)
	rts

;
; TROUVE L'ADRESSE DU PROGRAMME NAME1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	In	Name1	Nom � cherche
;	Out	Trouve	BNE, A0=adresse
;		Non	BEQ
;
Prg_AccAdr
	movem.l	a2-a3/d2,-(sp)
	move.l	Name1(a5),a0
	JJsrR	L_Dsk.DNom,a3
	move.l	a0,d2
	move.l	Prg_List(a5),d0
	beq.s	.Out
.Loop0	move.l	d0,a2
	lea	Prg_NamePrg(a2),a0
	JJsrR	L_Dsk.DNom,a3
	move.l	d2,a1
.Loop1	move.b	(a0)+,d0
	bsr	MajD0
	move.b	d0,d1
	move.b	(a1)+,d0
	bsr	MajD0
	cmp.b	d0,d1
	bne.s	.Next
	or.b	d1,d0
	bne.s	.Loop1
	move.l	a2,d0
	bra.s	.Ok
.Next	move.l	Prg_Next(a2),d0
	bne.s	.Loop0
.Out	moveq	#0,d0
.Ok	move.l	d0,a0
	movem.l	(sp)+,a2-a3/d2
	rts
MajD0	cmp.b	#"a",d0
	bcs.s	.Ski
	cmp.b	#"z",d0
	bhi.s	.Ski
	sub.b	#$20,d0
.Ski	rts

;
; Sauve un programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	IN	Name1=	nom du programme
;		A6	structure � sauver
Prg_Save
	movem.l	a2/d2-d4,-(sp)
	move.l	#1006,d2
	jsr	D_Open
	beq	.Err
; Sauve le header du programme: PRO / 1.3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	H_Pro(pc),a0			Header PRO
	move.b	Prg_MathFlags(a6),15(a0)	Double precision
	tst.b	Prg_Not1.3(a6)
	bne.s	.N13
	lea	H_1.3(pc),a0
.N13	moveq	#"V",d0			Teste!
	tst.b	Prg_StModif(a6)
	beq.s	.Skip
	moveq	#"v",d0			Non teste!
.Skip	move.b	d0,11(a0)		Met la marque
	move.l	a0,d2
	moveq	#16,d3
	jsr	D_Write
	bne	.Err
; Trouve la fin REELLE du programme (pas les zeros de fin!)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_StBas(a6),a0
.Loop	bsr	Tk_FindN		Explore le programme
	bne.s	.Loop
.Fin	move.l	a0,d4			Stoppe sur le premier zero
; Sauve la taille PRG
; ~~~~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),a0
	move.l	d4,d0
	sub.l	Prg_StBas(a6),d0
	move.l	d0,(a0)
	move.l	a0,d2
	moveq	#4,d3
	jsr	D_Write
	bne	.Err
; Sauve le corps du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_StBas(a6),d2
	move.l	d4,d3
	sub.l	d2,d3
	jsr	D_Write
	bne	.Err
; Sauve les banques....
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Prg_SetBanks
	JJsr	L_Bnk.SaveAll
	bne	.Err
; Fin de la sauvegarde
; ~~~~~~~~~~~~~~~~~~~~
	jsr	D_Close
; Change le nom
; ~~~~~~~~~~~~~
	move.l	Name1(a5),a0
	lea	Prg_NamePrg(a6),a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
; Pas d'erreur
; ~~~~~~~~~~~~
	clr.b	Prg_Change(a6)
	moveq	#0,d0
	bra.s	.Out
.Err	moveq	#-1,d0
.Out	movem.l	(sp)+,a2/d2-d4
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ROUTINES GESTION SOURCE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; FIND_LINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 	Trouve la ligne 	D0
;	Debut source		A0
;	Debut Proc >>>		A1
Tk_FindN
	moveq	#1,d0
Tk_FindL
	move.l	d1,-(sp)
	moveq	#0,d1
	sub.l	a1,a1
	subq.w	#1,d0
	bmi.s	FndT
; Boucle principale
Fnd1	move.b	(a0),d1
	beq.s	FndT
	cmp.w	#_TkProc,2(a0)
	beq.s	Fnd4
Fnd2	add.w	d1,a0
	add.w	d1,a0
Fnd3	dbra	d0,Fnd1
	bra.s	FndT
; Debut de procedure
Fnd4	tst.w	10(a0)			* Fermee
	bpl.s	Fnd5
	move.l	4(a0),d1
	lea	12+2(a0,d1.l),a0
	moveq	#0,d1
	bra.s	Fnd3
Fnd5	move.l	a0,a1			* Ouverte
	bra.s	Fnd7
Fnd6	move.b	(a0),d1
	beq.s	FndT
	cmp.w	#_TkEndP,2(a0)
	beq.s	Fnd8
Fnd7	add.w	d1,a0
	add.w	d1,a0
	dbra	d0,Fnd6
	bra.s	FndT
Fnd8	sub.l	a1,a1
	bra.s	Fnd2
; Trouve!
FndT	move.l	(sp)+,d1
	move.w	(a0),d0
	beq.s	FndT1
	cmp.w	#_TkProc,2(a0)
	bne.s	FndT1
	move.l	a0,a1
FndT1	tst.w	d0
	rts
; Taille de la ligne A0
; ~~~~~~~~~~~~~~~~~~~~~
Tk_SizeL
	moveq	#0,d0
	move.b	(a0),d0
	beq.s	.Out
	cmp.w	#_TkProc,2(a0)
	beq.s	.Proc
.Ouv	lsl.w	#1,d0
.Out	rts
.Proc	tst.w	10(a0)
	bpl.s	.Ouv
	moveq	#12+2,d0
	add.l	4(a0),d0
	rts
; La ligne courante est-elle editable?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tk_EditL
	tst.b	(a0)
	beq.s	.Oui
	cmp.w	#_TkProc,2(a0)
	bne.s	.Oui
	btst	#7,10(a0)
	beq.s	.Oui
	move.w	#%00100,CCR		BEQ>>> faux
	rts
.Oui	move.w	#%00000,CCR		BNE>>> vrai
	rts

; TROUVE LE NUMERO ET LE DEBUT DE LA LIGNE A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; A1-> Debut du buffer
; D0-> Numero
; D1-> Adresse debut proc
Tk_FindA
	movem.l	d2/a2,-(sp)
	move.l	a1,a2
	moveq	#-1,d0
	moveq	#0,d1
	moveq	#0,d2
FdA1:	addq.l	#1,d0
	move.l	a2,a1
	move.b	(a2),d2
	beq.s	FdAT
	cmp.w	#_TkProc,2(a2)
	beq.s	FdA4
FdA2	add.w	d2,a2
	add.w	d2,a2
FdA3	cmp.l	a0,a2
	bls.s	FdA1
	bra.s	FdAT
; Une procedure
FdA4	tst.w	10(a2)
	bpl.s	FdA2
	move.l	a2,d1
	btst	#4,10(a2)
	beq.s	FdA6
	add.l	4(a2),a2
	lea	12+2(a2),a2
	moveq	#0,d2
	bra.s	FdA6
FdA5	move.l	a2,a1
	move.b	(a2),d2
	beq.s	FdAT
	cmp.w	#_TkEndP,2(a2)
	beq.s	FdA7
FdA6	add.w	d2,a2
	add.w	d2,a2
	cmp.l	a0,a2
	bls.s	FdA5
	bra.s	FdAT
FdA7	moveq	#0,d1
	bra.s	FdA2
; Trouve!
FdAT	move.l	a1,a0
	movem.l	(sp)+,d2/a2
	rts

;				Codage / Decodage procedure LOCKEE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 	A6---> "PROC"
ProCode	movem.l	d0-d7/a0-a6,-(sp)
	btst	#4,8(a6)		* Flag COMPILED?
	bne	PaCo
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
PaCo	movem.l	(sp)+,d0-d7/a0-a6
	rts

;				Echange des tables de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ver_Verif
	moveq	#-1,d3
	bra.s	Ver_Echange
Ver_Run	moveq	#0,d3
Ver_Echange
	lea	AdTokens(a5),a2
	moveq	#27-1,d2
.Loop	tst.l	(a2)
	beq.s	.Next
	move.l	(a2),a1
	tst.l	LB_Verif(a1)		Une table?
	beq.s	.Next
	tst.w	d3			Run (0)  ou Verif (1)
	bne.s	.Verif
; Run!
	bclr	#LBF_Verif,LB_Flags(a1)		Deja RUN?
	beq	.Next
	bsr.s	Ver_Ech			On echange
	bra.s	.Next
; Verif!
.Verif	bset	#LBF_Verif,LB_Flags(a1)		Deja VERIF?
	bne	.Next
	bsr.s	Ver_Ech
; Table suivante
.Next	addq.l	#4,a2
	dbra	d2,.Loop
	rts
; Echange des tables
; ~~~~~~~~~~~~~~~~~~
Ver_Ech	move.l	a1,a0			Debut des tokens
	move.l	LB_Verif(a0),a1		Adresse table
	move.w	(a1)+,d1		Longueur table
	ext.l	d1
	add.l	a1,d1			Fin table
.Loop	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
.Skip1	tst.b	(a0)+
	bpl.s	.Skip1
.Skip2	tst.b	(a0)+
	bpl.s	.Skip2
	move.w	a0,d0
	and.w	#$0001,d0
	add.w	d0,a0
	cmp.l	d1,a1
	bcs.s	.Loop
	rts


;						Table des operateurs / Test
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst_Operateurs
	bra	Tst_Chiffre
	dc.b 	" xor"," "+$80,"O00",-1
	bra	Tst_Chiffre
	dc.b 	" or"," "+$80,"O00",-1
	bra	Tst_Chiffre
	dc.b 	" and"," "+$80,"O00",-1
	bra	Tst_Comp
	dc.b 	"<",">"+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	">","<"+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	"<","="+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	"=","<"+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	">","="+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	"=",">"+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	"="+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	"<"+$80,"O20",-1
	bra	Tst_Comp
	dc.b 	">"+$80,"O20",-1
	bra	Tst_Mixte
	dc.b 	"+"+$80,"O22",-1
	bra	Tst_Mixte
	dc.b 	"-"+$80,"O22",-1
	bra	Tst_Chiffre
	dc.b 	" mod"," "+$80,"O00",-1
	bra	Tst_Chiffre
	dc.b 	"*"+$80,"O00",-1
	bra	Tst_Chiffre
	dc.b 	"/"+$80,"O00",-1
	bra	Tst_Puis
	dc.b 	"^"+$80,"O00",-1
	even
Tst_Jumps
	dc.l 	0
