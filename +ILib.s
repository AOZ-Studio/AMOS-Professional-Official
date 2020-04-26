
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

;---------------------------------------------------------------------
	Lib_Ini	0
;---------------------------------------------------------------------

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					INITIALISATION LIBRAIRIE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Init
Init
; - - - - - - - - - - - - -
	move.w	#$00FF,d0		Librairie numero 0
	move.w	#Ver_Number,d1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ROUTINES A NETTOYER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Routines de chargement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Int	Edit_Load
	Lib_Int	Edit_Free
	Lib_Int	Mon_Load
	Lib_Int	Mon_Free

;	Entrees dans le moniteur (5 places)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Def	Mon_Start
	Lib_Def	Mon_In_Editor
	Lib_Def	Mon_In_Program
	Lib_Def	Mon_MonitorChr
	Lib_Def	Mon_Free2
	Lib_Def	Mon_Free3

; 	Entrees dans l'editeur (15 places)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Def	Ed_Start
	Lib_Def	Ed_Cold				0
	Lib_Def	Ed_Title			1
	Lib_Def	Ed_End				2
	Lib_Def	Ed_Loop				3
	Lib_Def	Ed_ErrRun			4
	Lib_Def	Ed_CloseEditor			5
	Lib_Def	Ed_KillEditor			6
	Lib_Def	Ed_ZapFonction			7
	Lib_Def	Ed_ZapIn			8
	Lib_Def	Ed_RunDirect			9
	Lib_Def	Tokenise			10
	Lib_Def	Detok				11
	Lib_Def	Mon_Detok			12
	Lib_Def	TInst				13
	Lib_Def	Ed_Free1			14
	Lib_Def	Ed_Free2			15
	Lib_Def	Ed_Free3			16
	Lib_Def	Ed_Free1			17
	Lib_Def	Ed_Free2			18

; 	Routines dans la verification
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Int	Tk_FindA
	Lib_Int	Tk_EditL
	Lib_Int	Tk_FindL
	Lib_Int	Tk_FindN
	Lib_Int	Tk_SizeL
	Lib_Int	Prg_RunIt
	Lib_Int	Prg_TestIt
	Lib_Int	Prg_Save
	Lib_Int	Prg_Load
	Lib_Int	Prg_New
	Lib_Int	Prg_NewStructure
	Lib_Int	Prg_DelStructure
	Lib_Int	Prg_AccAdr
	Lib_Int	Prg_DejaRunned
	Lib_Int	Prg_DataLoad
	Lib_Int	Prg_DataSave
	Lib_Int	Prg_DataNew
	Lib_Int	Prg_CptLines
	Lib_Int	Prg_ChgTTexte
	Lib_Int	Prg_SetBanks
	Lib_Int	Prg_ReSetBanks
	Lib_Int	Prg_SetBanks
	Lib_Int	Prg_Pull
	Lib_Int	ClearVar
	Lib_Int	PTest
	Lib_Int	SsTest
	Lib_Int	ResVNom
	Lib_Int	ResDir
	Lib_Int	ResVarBuf
	Lib_Int	VerDirect
	Lib_Int	Stack_Reserve
	Lib_Int	Includes_Clear
	Lib_Int	Includes_Adr
	Lib_Int	Equ_Free

; 	Routines internes � "+b.s"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Int	RamFast			Ram Access
	Lib_Int	RamFast2
	Lib_Int	RamChip
	Lib_Int	RamChip2
	Lib_Int	RamFree
	Lib_Int	ResTempBuffer

	Lib_Int	Math_Close
	Lib_Int	Sys_WaitMul
	Lib_Int	Def_GetMessage
	Lib_Int	Sys_GetMessage
	Lib_Int	GetMessage
	Lib_Int	Sys_AddPath
	Lib_Def	Sys_GetPath		Pour le compilateur!
	Lib_Int	Sys_UnCode
	Lib_Int	MemMaximum
	Lib_Int	MemDelBanks
	Lib_Int	TheEnd
	Lib_Int	UserReg
	Lib_Int	VersionN
	Lib_Int	BugBug
	Lib_Int	PreBug
	Lib_Int	Sys_ClearCache
	Lib_Int	WOption
	Lib_Int	ReCop

	Lib_Int	Lst.ChipNew		Gestion des listes
	Lib_Int	Lst.New
	Lib_Int	Lst.Cree
	Lib_Int	Lst.DelAll
	Lib_Int	Lst.Del
	Lib_Int	Lst.Insert
	Lib_Int	Lst.Remove
	Lib_Int	Bnk.PrevProgram
	Lib_Int	Bnk.CurProgram
	Lib_Int	AskDir
	Lib_Int	AskDir2

;	Special compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Def	Tokenisation		Routines pour APCMP
	Lib_Def	Testing
	Lib_Def	CValRout

	Lib_Def	CmpInit1		Routines d'initialisation
	Lib_Def	CmpInit2
	Lib_Def	AMOSInit
	Lib_Def	CmpDbMode
	Lib_Def	CmpLineCLI
	Lib_Def	CmpLineSER
	Lib_Def	CmpPrintCLI
	Lib_Def	CmpPrintSER
	Lib_Def	CmpEffVarBuf
	Lib_Def	CmpLibrariesInit
	Lib_Def	CmpLibrariesStop
	Lib_Def	CmpEndRoutines
	Lib_Def	CmpLibClose
	Lib_Def	CmpClearVar

	Lib_Def	PlusF			Routines d'operateurs
	Lib_Def	PlusC
	Lib_Def	MoinsF
	Lib_Def	MoinsC
	Lib_Def	MultE
	Lib_Def	MultF
	Lib_Def	DiviseE
	Lib_Def	DiviseF
	Lib_Def	Puissance
	Lib_Def	Modulo
	Lib_Def	Chaine_Compare

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEFRUN: initialisation graphique
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	DefRun1
; - - - - - - - - - - - - -
	tst.w	DefFlag(a5)
	beq	DRunX
	movem.l	d0-d7/a0-a6,-(sp)
; Enleve les animations
; ~~~~~~~~~~~~~~~~~~~~~
	SyCall	AMALClr
	clr.w	PAmalE(a5)
; Enleve les rainbows
; ~~~~~~~~~~~~~~~~~~~
	EcCalD	RainDel,-1
; Appel des routines de nettoyage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Sys_DefaultRoutines(a5),a1
	SyCall	CallRoutines
; Enleve tous les ecrans
; ~~~~~~~~~~~~~~~~~~~~~~
	move.w	PI_DefEBa(a5),ColBack(a5)
	moveq	#0,d1
	moveq	#7,d2
	EcCall	DelAll
	clr.w	ScOn(a5)
	clr.l	ScOnAd(a5)
	move.w	#8,CurTab(a5)		Tab par defaut
; Enleve le tempras
; ~~~~~~~~~~~~~~~~~
	clr.l	RasLock(a5)
	Rjsr	L_FreeRas
; Enleve les blocs!
; ~~~~~~~~~~~~~~~~~
	EcCall	CBlRaz
	EcCall	BlRaz
; Enleve les font-infos
; ~~~~~~~~~~~~~~~~~~~~~
	EcCall	FFonts
; RAZ des canaux d'animation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	AnCanaux(a5),a0
	moveq	#0,d0
DRun1:	clr.b	(a0)+
	move.b	d0,(a0)+
	addq.w	#1,d0
	cmp.w	#64,d0
	bne.s	DRun1
; Priority off
; ~~~~~~~~~~~~
	moveq	#0,d1
	moveq	#0,d2
	SyCall	SPrio
; RAZ des scrollings
; ~~~~~~~~~~~~~~~~~~
	moveq	#NDScrolls-1,d0
	lea	DScrolls(a5),a0
DRun2:	move.w	#$8000,(a0)
	lea	12(a0),a0
	dbra	d0,DRun2
; Interruptions branchees
; ~~~~~~~~~~~~~~~~~~~~~~~
	clr.w	InterOff(a5)
	move.w	InterOff(a5),d1
	SyCall	SetSync
	move.w	#%0111000100000000,ActuMask(a5)
	clr.w	VBLDelai(a5)
	clr.w	VBLOCount(a5)
; Copie la palette par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	PI_DefEPa(a5),a0
	lea	DefPal(a5),a1
	moveq	#31,d0
EdTr:	move.w	(a0)+,(a1)+
	dbra	d0,EdTr
; Cree l'ecran (si pas system!)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#-2,DefFlag(a5)
	beq.s	DRex0
	move.w	PI_DefETx(a5),d2
	ext.l	d2
	move.w	PI_DefETy(a5),d3
	ext.l	d3
	move.w	PI_DefECo(a5),d4
	ext.l	d4
	move.w	PI_DefEMo(a5),d5
	move.w	PI_DefECoN(a5),d6
	moveq	#0,d7
	lea	DefPal(a5),a1
	EcCalD	Cree,0
	bne.s	DRex0
	move.l	a0,ScOnAd(a5)
	move.w	#1,ScOn(a5)
	move.l	#EntNul,d4
	move.l	d4,d5
	move.w	PI_DefEWx(a5),d2	Si non initialise...
	bne.s	.Skip1
	move.l	d4,d2
.Skip1	move.w	PI_DefEWy(a5),d3
	bne.s	.Skip2
	move.l	d4,d3
.Skip2	EcCalD	AView,0
; Fait flasher la couleur 3 (si plus de 2 couleurs)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#1,PI_DefECo(a5)
	beq.s	DRex0
	moveq	#3,d1
	moveq	#46,d0
	Rjsr	L_Sys_GetMessage
	move.l	a0,a1
	EcCall	Flash
; Call extensions
; ~~~~~~~~~~~~~~~
	Rbsr	L_DefRunExtensions
; Fini
; ~~~~
DRex0	movem.l	(sp)+,d0-d7/a0-a6
DRunX:	rts

; - - - - - - - - - - - - -
	Lib_Def	DefRun2
; - - - - - - - - - - - - -
	tst.w	DefFlag(a5)
	beq.s	DRunX
	clr.w	DefFlag(a5)
; Limite la souris
; ~~~~~~~~~~~~~~~~
	move.w	T_DefWX(a5),d1
	move.w	T_DefWY(a5),d2
	move.w	PI_DefETx(a5),d3
	move.w	PI_DefETy(a5),d4
	subq.w	#1,d3
	subq.w	#1,d4
	add.w	d1,d3
	add.w	d2,d4
	lsl.w	#1,d1
	lsl.w	#1,d2
	lsl.w	#1,d3
	lsl.w	#1,d4
	lea	LimSave(a5),a0
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	lea	T_MouXMin(a5),a0
	tst.l	(a0)
	bne.s	.Skip
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d4,(a0)+
.Skip	move.l	PI_ParaTrap+16(a5),d1	* Nombre de lignes
	SyCall	SBufHs
	SyCall	OffHs
	SyCall	StoreM
	SyCall	StoreM
	SyCall	AffHs
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEFRUNACC: semi initialisation graphique pour accessoires
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	DefRunAcc
; - - - - - - - - - - - - -
	movem.l	d0-d7/a0-a6,-(sp)
; Appel des routines de nettoyage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Sys_DefaultRoutines(a5),a1
	SyCall	CallRoutines
; Enleve les animations
; ~~~~~~~~~~~~~~~~~~~~~
	SyCall	AMALClr
	clr.w	PAmalE(a5)
; RAZ des canaux d'animation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	AnCanaux(a5),a0
	moveq	#0,d0
.DRun1	clr.b	(a0)+
	move.b	d0,(a0)+
	addq.w	#1,d0
	cmp.w	#64,d0
	bne.s	.DRun1
; Priority off
; ~~~~~~~~~~~~
	moveq	#0,d1
	moveq	#0,d2
	SyCall	SPrio
; RAZ des scrollings
; ~~~~~~~~~~~~~~~~~~
	moveq	#NDScrolls-1,d0
	lea	DScrolls(a5),a0
.DRun2	move.w	#$8000,(a0)
	lea	12(a0),a0
	dbra	d0,.DRun2
; Interruptions branchees
; ~~~~~~~~~~~~~~~~~~~~~~~
	clr.w	InterOff(a5)
	move.w	InterOff(a5),d1
	SyCall	SetSync
 	move.w	#%0111000100000000,ActuMask(a5)
	clr.w	VBLDelai(a5)
	clr.w	VBLOCount(a5)
; Call extensions
; ~~~~~~~~~~~~~~~
	Rbsr	L_DefRunExtensions
; Sprites
; ~~~~~~~
	SyCall	OffHs
	SyCall	AffHs
	move.w	#1,DefFlag(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INITIALISATION ECRAN DES EXTENSIONS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	DefRunExtensions
; - - - - - - - - - - - - -
	movem.l	a2-a6/d2-d7,-(sp)
.DRex0	lea	ExtAdr(a5),a0
	moveq	#26-1,d0
.DRex1	move.l	4(a0),d1
	beq.s	.DRex2
	move.l	d1,a1
	movem.l	a0/d0,-(sp)
	jsr	(a1)
	movem.l	(sp)+,a0/d0
.DRex2	lea	16(a0),a0
	dbra	d0,.DRex1
	movem.l	(sp)+,a2-a6/d2-d7
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Set Patch sur CHRGET
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	SetChrPatch
; - - - - - - - - - - - - -
	move.w	d0,Cur_ChrJump(a5)
	lea	_Poke(pc),a1
	tst.w	d0
	beq.s	.Norm
	move.w	.Mon(pc),(a1)+
	lsl.w	#2,d0
	neg.w	d0
	sub.w	#LB_Size+4,d0
	move.w	d0,(a1)+
	bra.s	.Clear
.Norm	move.l	.Chr(pc),(a1)+
.Clear	Rjsr	L_Sys_ClearCache
	rts
.Chr	move.l	-LB_Size(a4,d1.w),a0
.Mon	move.l	0(a4),a0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 						ENTREE DU CHRGET
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Pos_IRet
; - - - - - - - - - - - - -
	dc.w	_IRet-_DChr
; - - - - - - - - - - - - -
	Lib_Def	New_ChrGet
; - - - - - - - - - - - - - - -
_DChr	move.l	BasSp(a5),sp
	move.l	AdTokens(a5),a4

; Adresse du retour d'instructions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	_IRet(pc),a0
	move.l	a0,Prg_InsRet(a5)
; Buffer des boucles
; ~~~~~~~~~~~~~~~~~~
	Rjsrt	L_Stack_Reserve
;	beq	VerOut				*** Illegal!
	move.l	HoLoop(a5),a3
	move.l	a3,PLoop(a5)
	move.l	a3,BasA3(a5)
	move.l	BaLoop(a5),MinLoop(a5)
	add.l	#64,MinLoop(a5)

; Ouverture des librairies mathematiques / Choix des routines dans la librarie
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Open_MathLibraries

; Autres inits
; ~~~~~~~~~~~~
	clr.w	T_Actualise(a5)
	clr.l	AData(a5)
	move.w	#1,DefFlag(a5)
	move.l	Prg_Run(a5),a6
	move.l	a6,DProc(a5)
	move.l	a6,PData(a5)

; Debuggage
	IFNE	Debug>1
	move.l	VarBufL(a5),d0
	cmp.l	#1024*1,d0
	bne.s	.NoBug
	Rjsr	L_PreBug
.NoBug
	ENDC

;	Boucle du ChrGet
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	AdTokens(a5),a4
_NLine	tst.w	(a6)+
	beq.s	InEnd
_ILoop	move.w	(a6)+,d0
	beq.s	_NLine
_Inst	move.l	a6,d7
	move.w	0(a4,d0.w),d1		Pointe la table de tokens
_Poke	move.l	-LB_Size(a4,d1.w),a0
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	movem.l	d6/d7,Chr_Debug+4(a5)
	ENDC
	jsr	(a0)
_IRet
	IFNE	Debug>1
	move.l	Chr_Debug(a5),a0
	movem.l	Chr_Debug+4(a5),d0/d1
 	cmp.l	a0,a3			Test valide PLOOP
	bne.s	.Bug
	cmp.l	d0,d6			Test sauvegarde D6/D7
	bne.s	.Bug
	cmp.l	d1,d7
	beq.s	.Skip
.Bug	Rjsr	L_BugBug
	Rjsr	L_InMonitor
	ENDC
	IFNE	Debug
	move.l	Chr_Debug(a5),a0
	movem.l	Chr_Debug+4(a5),d0/d1
 	cmp.l	a0,a3			Test valide PLOOP
	bne.s	.Bug1
	cmp.l	d0,d6			Test sauvegarde D6/D7
	bne.s	.Bug1
	cmp.l	d1,d7
	beq.s	.Skip
.Bug1	Rjsr	L_InMonitor
	ENDC
.Skip
	move.w	(a6)+,d0
	bne.s	_Inst
	tst.w	(a6)+
	bne.s	_ILoop
	bra.s	InEnd

; - - - - - - - - - - - - -
	Lib_Par InEnd
; - - - - - - - - - - - - -
InEnd	moveq	#NbEnd,d0
	bra	RunErr

;		Librairies ouvertes par le ChrGet
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MathName	dc.b 	"mathtrans.library",0
DFloatName	dc.b 	"mathieeedoubbas.library",0
DMathName	dc.b 	"mathieeedoubtrans.library",0
		even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EXTENSION INSTRUCTION CALL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InExtCall
; - - - - - - - - - - - - -
	move.b	(a6)+,d1		# Extension
	move.b	(a6)+,d0		Nombre de params
	bpl.s	.Old			NOUVELLE extension?
;	Nouvelle extension AMOSPro II
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ext.w	d1
	lsl.w	#2,d1
	move.l	AdTokens(a5,d1.w),a0
	move.w	(a6)+,d0
	move.w	0(a0,d0.w),d1		# du jump dans la librarie
	move.w	2(a0,d0.w),d2		Nombre de parametres
	move.l	-LB_Size(a0,d1.w),a0	Adresse du saut
	jmp	(a0)			On y va!
; 	Ancienne extension
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Old	move.w	(a6)+,d2
	ext.w	d1
	lsl.w	#2,d1
	move.l	AdTokens(a5,d1.w),a0
	add.w	0(a0,d2.w),a0
	ext.w	d0
	beq.s	.Skip
	move.l	a0,-(sp)
	move.w	d0,-(sp)
.Loop	bsr	New_Evalue
	cmp.b	#1,d2
	bne.s	.Ent
	Rjsrt	L_FlToInt1
.Ent	move.l	d3,-(a3)
	addq.l	#2,a6
	subq.w	#1,(sp)
	bne.s	.Loop
	subq.l	#2,a6
	addq.l	#2,sp
	move.l	(sp)+,a0
.Skip	movem.l	d6-d7,ErrorSave(a5)
	move.b	#1,ErrorRegs(a5)
	jsr	(a0)
	movem.l	ErrorSave(a5),d6-d7
	clr.b	ErrorRegs(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EXTENSION FUNCTION CALL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FnExtCall
; - - - - - - - - - - - - -
	move.b	(a6)+,d1
	move.b	(a6)+,d0
	bpl.s	.Old			NOUVELLE extension?
;	Nouvelle extension AMOSPro II
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ext.w	d1
	lsl.w	#2,d1
	move.l	AdTokens(a5,d1.w),a0
	move.w	(a6)+,d0
	move.w	0(a0,d0.w),d1		# du jump dans la librarie
	move.w	2(a0,d0.w),d2		Nombre de parametres
	move.l	-LB_Size-4(a0,d1.w),a0	Adresse du saut
	jmp	(a0)			On y va!
; 	Ancienne extension
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Old	move.w	(a6)+,d2
	ext.w	d1
	lsl.w	#2,d1
	move.l	AdTokens(a5,d1.w),a0
	add.w	2(a0,d2.w),a0
	ext.w	d0
	beq.s	.Skip
	move.l	a0,-(sp)
	move.w	d0,-(sp)
.Loop	bsr	Fn_New_Evalue
	cmp.b	#1,d2
	bne.s	.Ent
	Rjsrt	L_FlToInt1
.Ent	move.l	d3,-(a3)
	subq.w	#1,(sp)
	bne.s	.Loop
	addq.l	#2,sp
	move.l	(sp)+,a0
.Skip	movem.l	d6-d7,ErrorSave(a5)
	move.b	#1,ErrorRegs(a5)
	jsr	(a0)
	movem.l	ErrorSave(a5),d6-d7
	clr.b	ErrorRegs(a5)
	rts

;	Ouverture / Echange des routines mathemetiques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; - - - - - - - - - - - - -
	Lib_Def	Open_MathLibraries
; - - - - - - - - - - - - -
Open_MathLibraries
	move.l	a6,-(sp)
	move.l	#$c90fd942,ValPi(a5)		Simple precision
	move.l	#$b4000048,Val180(a5)
	move.l	#$04040404,Long_Var(a5)
	move.l	$4.w,a6
	btst	#1,MathFlags(a5)		Simple precision
	beq.s	.M1
	tst.l	MathBase(a5)
	bne.s	.M1
	moveq	#0,d0
	lea	MathName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,MathBase(a5)
	beq	ErrMLibs
.M1	tst.b	MathFlags(a5)			Double precicion
	bpl.s	.M3
	move.l	#$40668000,Val180(a5)
	move.l	#$00000000,Val180+4(a5)
	move.l	#$400921fb,ValPi(a5)
	move.l	#$54442eea,ValPi+4(a5)
	move.l	#$04080404,Long_Var(a5)
	tst.l	DFloatBase(a5)
	bne.s	.M2
	moveq	#0,d0
	lea	DFloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DFloatBase(a5)
	beq	ErrMLibs
.M2	tst.l	DMathBase(a5)
	bne.s	.M3
	moveq	#0,d0
	lea	DMathName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DMathBase(a5)
	beq	ErrMLibs
.M3	bsr	Lib_FloatSwap		Echange les routines float
	Rjsr	L_Sys_ClearCache
	move.l	(sp)+,a6
	rts

; 			Echange des routines float dans la librarie
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lib_FloatSwap
	movem.l	a2/d2,-(sp)
	lea	AdTokens(a5),a2
	moveq	#27-1,d2
.Loop	tst.l	(a2)
	beq.s	.MSkip
	move.l	(a2),a1
	tst.w	LB_FFloatSwap(a1)
	beq.s	.MSkip
	tst.b	MathFlags(a5)
	bmi.s	.MDble
	btst	#LBF_DFloat,LB_Flags(a4)
	bne.s	.MSwap
	beq.s	.MSkip
.MDble	btst	#LBF_DFloat,LB_Flags(a4)
	bne.s	.MSkip
.MSwap	bsr	Lib_FSwap
.MSkip	addq.l	#4,a2
	dbra	d2,.Loop
	movem.l	(sp)+,a2/d2
	rts
; Routine d'echange
; ~~~~~~~~~~~~~~~~~
Lib_FSwap
	bchg	#LBF_DFloat,LB_Flags(a4)
	move.w	LB_DFloatSwap(a1),d0
	lsl.w	#2,d0
	neg.w	d0
	lea	-LB_Size-4(a1,d0.w),a0
	move.w	LB_FFloatSwap(a1),d1
	sub.w	LB_DFloatSwap(a1),d1
	ext.l	d1
	lsr.l	#1,d1
	subq.w	#1,d1
	bmi.s	.Skip
.Loop	move.l	-4(a0),d0
	move.l	-8(a0),-4(a0)
	move.l	d0,-8(a0)
	lea	-8(a0),a0
	dbra	d1,.Loop
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INTERPRETEUR SEUL: recuperation des parametres...
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Parameters
; - - - - - - - - - - - - -
Par	dc.w	Ent_0-Par		0>>> Entier normal
	dc.w	Ent_1-Par		1
	dc.w	Ent_2-Par		2
	dc.w	Ent_3-Par		3
	dc.w	Ent_4-Par		4
	dc.w	Ent_N-Par		5
	dc.w	Flt_0-Par		6>>> Float normal
	dc.w	Flt_1-Par		7
	dc.w	Flt_2-Par		8
	dc.w	Flt_N-Par		9
	dc.w	Flt_N-Par		10
	dc.w	Flt_N-Par		11
	dc.w	IVar_0-Par		12>> Variable reservee
	dc.w	IVar_1-Par		13
	dc.w	IVar_2-Par		14
	dc.w	IVar_3-Par		15
	dc.w	IVar_4-Par		16
	dc.w	IVar_N-Par		17
	dc.w	Par_Angle-Par		18>> Fonction angle
	dc.w	Par_Math-Par		19>> Fonction math
; Si extensions (D2= nombre de params)
	dc.w	Ent_0-Par		0>>> Entier normal
	dc.w	Ent_1-Par		1
	dc.w	Ent_2-Par		2
	dc.w	Ent_3-Par		3
	dc.w	Ent_4-Par		4
	dc.w	EEnt_N-Par		5
	dc.w	Flt_0-Par		6>>> Float normal
	dc.w	Flt_1-Par		7
	dc.w	Flt_2-Par		8
	dc.w	EFlt_N-Par		9
	dc.w	EFlt_N-Par		10
	dc.w	EFlt_N-Par		11
	dc.w	IVar_0-Par		12>> Variable reservee
	dc.w	IVar_1-Par		13
	dc.w	IVar_2-Par		14
	dc.w	IVar_3-Par		15
	dc.w	IVar_4-Par		16
	dc.w	EIVar_N-Par		17
	dc.w	Par_Angle-Par		18>> Fonction angle
	dc.w	Par_Math-Par		19>> Fonction math

; 	Variable reserve en instruction, 1 param
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EIVar_N
	bsr	EFEnt_N
	bra.s	IVar
IVar_N	bsr	FEnt_N
	bra.s	IVar
IVar_4	bsr.s	FEnt_4
	bra.s	IVar
IVar_3	bsr.s	FEnt_3
	bra.s	IVar
IVar_2	bsr.s	FEnt_2
	bra.s	IVar
IVar_1	bsr.s	FEnt_1
IVar	move.l	d3,-(a3)
IVar_0	bsr	Fn_New_Evalue		Recolte du parametre a affecter
	cmp.b	#1,d2
	beq.s	.Ent
	rts
.Ent	Rjmpt	L_FlToInt1

;	QUATRE parametres ENTIER / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FEnt_4	addq.l	#2,a6
Ent_4	bsr	New_Evalue
	cmp.b	#1,d2
	bne.s	.Ent
	Rjsrt	L_FlToInt1
.Ent	move.l	d3,-(a3)
;	TROIS parametres ENTIER / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FEnt_3	addq.l	#2,a6
Ent_3	bsr	New_Evalue
	cmp.b	#1,d2
	bne.s	.Ent
	Rjsrt	L_FlToInt1
.Ent	move.l	d3,-(a3)
;	DEUX parametres ENTIER / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FEnt_2	addq.l	#2,a6
Ent_2	bsr	New_Evalue
	cmp.b	#1,d2
	bne.s	.Ent
	Rjsrt	L_FlToInt1
.Ent	move.l	d3,-(a3)
;	UN parametre ENTIER / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FEnt_1	addq.l	#2,a6
Ent_1	bsr	New_Evalue
	cmp.b	#1,d2
	beq.s	Ent
Ent_0	rts
Ent	Rjmpt	L_FlToInt1

; 	Fonction ANGLE, toujours float, appel FAngle
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Par_Angle
	bsr	Fn_New_Evalue
	tst.b	d2
	bne.s	.Flaot
	Rjsrt	L_IntToFl1
.Flaot	Rjmpt	L_FFAngle

; 	Fonction mathematique: 1 param, branchement >entier >float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Par_Math
	addq.l	#4,sp
	move.w	d1,-(sp)
	bsr	Fn_New_Evalue
	move.w	(sp)+,d0
	tst.b	d2
	bne.s	.Float
	move.l	-LB_Size-4(a4,d0.w),a0		Saute l'appel params
	jmp	4(a0)
.Float	move.l	-LB_Size-8(a4,d0.w),a0		Pas d'appel params ici...
	jmp	(a0)

; 	N Parametres FLOAT / CHAINES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EFFlt_N	addq.l	#2,a6
EFlt_N	move.w	d2,-(sp)
	bra.s	SOne
FFlt_N	addq.l	#2,a6
Flt_N	move.w	2(a4,d0.w),-(sp)
	bra.s	SOne
SLoop	move.l	d3,-(a3)
	addq.l	#2,a6
SOne	bsr	New_Evalue
	tst.b	d2
	bne.s	SOk
	Rjsrt	L_IntToFl1
SOk	subq.w	#1,(sp)
	bne.s	SLoop
	rtr
;	DEUX parametres FLOAT / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FFlt_2	addq.l	#2,a6
Flt_2	bsr	New_Evalue
	tst.b	d2
	bne.s	.Ent
	Rjmpt	L_IntToFl1
.Ent	move.l	d3,-(a3)
;	UN parametre FLOAT / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FFlt_1	addq.l	#2,a6
Flt_1	bsr	New_Evalue
	tst.b	d2
	beq.s	Flt
Flt_0	rts
Flt	Rjmpt	L_IntToFl1

; 	N parametres ENTIERS / CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EFEnt_N	addq.l	#2,a6
EEnt_N	move.w	d2,-(sp)
	bra.s	_POne
FEnt_N	addq.l	#2,a6
Ent_N	move.w	2(a4,d0.w),-(sp)
	bra.s	_POne
_PLoop	move.l	d3,-(a3)
	addq.l	#2,a6
_POne	bsr	New_Evalue
	cmp.b	#1,d2
	bne.s	_POk
	Rjsrt	L_FlToInt1
_POk	subq.w	#1,(sp)
	bne.s	_PLoop
	rtr

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TEST INTER SANS SAUT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Test_PaSaut
Test_PaSaut
; - - - - - - - - - - - - -
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#Bit_PaSaut,Test_Flags(a5)
	bsr.s	Test_Normal
	bclr	#Bit_PaSaut,Test_Flags(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TEST NORMAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Test_Normal
Test_Normal
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	Test_Force
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TEST FORCE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Test_Force
Test_Force
; - - - - - - - - - - - - -
	move.w	ActuMask(a5),d4

; Inhibition par un autre AMOS?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	SyCall	Test_Cyclique

; Les dialogues???
; ~~~~~~~~~~~~~~~~
	move.l	Cur_Dialogs(a5),a0	Un dialogue?
	tst.l	(a0)
	beq.s	.NoDia
	Rjsr	L_Dia_AutoTest
	beq.s	.NoDia
	add.w	#IDia_Errors,d0
	Rbra	L_Error
.NoDia
; Les menus???
; ~~~~~~~~~~~~
	btst	#BitMenu,d4		Menus en route?
	beq.s	Tst0
	tst.l	MnBase(a5)		Un menu defini?
	beq.s	Tst0
	tst.w	MnProc(a5)		Pas dans une procedure menu
	bne.s	Tst0
	tst.l	T_ClLast(a5)		Une touche?
	beq.s	Tst0a
	tst.w	Direct(a5)		Pas en mode direct
	bne.s	Tst0a
	Rjsr	L_MenuKeyExplore
Tst0a	btst	#10,$dff016		Afficher le menu?
	bne.s	Tst0
	Rjsr	L_MnGere
	bne	RunErr

; Autres choses???
; ~~~~~~~~~~~~~~~~
Tst0	move.w	T_Actualise(a5),d3
	bclr	#BitControl,d3
	bne.s	Tst00
	and.w	d4,d3
	beq	TstX1
	bra.s	Tst1
; CONTROLE-C?
; ~~~~~~~~~~~
Tst00	tst.l	Mon_Base(a5)			Retour au moniteur?
	bne.s	IStop
	btst	#BitControl,d4			Break autorise?
	beq.s	Tst01
IStop	move.w	d3,T_Actualise(a5)
	moveq	#9,d0
	bra	RunErr
Tst01	move.w	d3,T_Actualise(a5)
	Rjsr	L_OnBreakGo
	bra.s	Tst1a

; Branchement automatique aux menus?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst1	bclr	#BitJump,d3
	beq.s	Tst1a
	Rjsr	L_GoMenu

; Actualisation des ecrans/animations
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst1a	move.w	T_VblCount+2(a5),d0
	sub.w	VBLOCount(a5),d0
	cmp.w	VBLDelai(a5),d0
	bcs	TstX1
	move.w	T_VblCount+2(a5),VBLOCount(a5)
; Bobs?
	bclr	#BitBobs,d3
	beq.s	Tst2
	SyCall	EffBob
	SyCall	ActBob
	SyCall	AffBob
	EcCall	SwapScS
; Hard Sprites?
Tst2:	bclr	#BitSprites,d3
	beq.s	Tst3
	SyCall	ActHs
	SyCall	AffHs
; Extensions?
Tst3:	lsr.b	#1,d3
	beq.s	Tst4
	lea	ExtTests(a5),a1
	bra.s	Tst3b
Tst3a	move.l	(a1),d0
	beq.s	Tst3b
	move.l	d0,a0
	jsr	(a0)
Tst3b	addq.l	#4,a1
	lsr.b	#1,d3
	bcs.s	Tst3a
	bne.s	Tst3b
; Ecrans?
Tst4:	bclr	#BitEcrans,d3
	beq.s	Tst5
	EcCall	CopMake
Tst5:

; Correction du bug CONTROL-C / Beaucoup de sprites
	move.w	T_Actualise(a5),d0
	and.w	#%0000000100000000,d0		BITCONTROL=8
	or.w	d0,d3
; Every
; ~~~~~
TstX1	move.w	d3,T_Actualise(a5)
	btst	#BitEvery,d4
	beq.s	TstX2
	tst.w	T_EveCpt(a5)
	bgt.s	TstX2
	move.w	EveCharge(a5),T_EveCpt(a5)
	bclr	#BitEvery,d4
	Rjsr	L_EveJump

TstX2	bclr 	#BitVBL,T_Actualise(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Fait le branchement ON MENU
;					Appele par TESTS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	GoMenu
GoMenu
; - - - - - - - - - - - - -
	btst	#Bit_PaSaut,Test_Flags(a5)	* Sauts autorises?
	bne.s	GoMX
	tst.w	Direct(a5)			* Mode direct???
	bne	GoMX
	lea	MnChoix(a5),a0
	move.w	(a0),d0
	beq.s	GoMX
	cmp.w	OMnNb(a5),d0
	bls.s	GoMGo
* Rien trouve: FINI!
GoMX:	rts
;	Fait le branchement
; ~~~~~~~~~~~~~~~~~~~~~~~~~
GoMGo	bclr	#BitJump,d4		* Plus de jump!
	move.w	d4,ActuMask(a5)
	move.w	d3,T_Actualise(a5)	* Derniere bug avant master!
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.l	OMnBase(a5),a0
	lsl.w	#2,d0
	move.l	-4(a0,d0.w),d0
	move.w	OMnType(a5),d1
	cmp.w	#_TkGto,d1
	beq.s	GoMG2
	cmp.w	#_TkGsb,d1
	beq.s	GoMG1
; Procedure!
; ~~~~~~~~~~
	move.l	d7,a6
	subq.l	#2,a6
	move.l	d0,a2
	clr.w	-(sp)
	bra	InProE
; Gosub
; ~~~~~
GoMG1	move.l	d7,a6
	subq.l	#2,a6
	bra	Gos2
; Goto
; ~~~~
GoMG2	move.l	d0,a6
	bra	LGoto

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ON BREAK : Fait le branchement en cas de BREAK
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	OnBreakGo
; - - - - - - - - - - - - -
	btst	#Bit_PaSaut,Test_Flags(a5)
	beq.s	.Jmp
.Skip	rts
.Jmp	move.l	OnBreak(a5),d0
	beq.s	.Skip
	move.l	d0,a2
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.l	d7,a6
	subq.l	#2,a6
	clr.w	-(sp)
	bra	InProE

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Fait le branchement a EVERY
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	EveJump
EveJump
; - - - - - - - - - - - - -
	tst.l	EveLabel(a5)
	bne.s	.Jmp
.Skip	rts
.Jmp	btst	#Bit_PaSaut,Test_Flags(a5)
	bne.s	.Skip
	move.w	d4,ActuMask(a5)
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.w	EveType(a5),d0
	cmp.w	#_TkGsb,d0
	beq.s	.Gsb
; Procedure!
; ~~~~~~~~~~
	move.l	d7,a6
	subq.l	#2,a6
	move.l	EveLabel(a5),a2
	clr.w	-(sp)
	bra	InProE
; Gosub
; ~~~~~
.Gsb	move.l	EveLabel(a5),d0
	move.l	d7,a6
	subq.l	#2,a6
	bra	Gos2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: b.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ERREURS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; - - - - - - - - - - - - -
ErrMLibs
; - - - - - - - - - - - - -		Cannot open math libraries
	move.l	Prg_Run(a5),a6		Au debut du programme!
	moveq	#12,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
MnINDef
; - - - - - - - - - - - - -
	moveq	#39,d0
	bra.s	RunErr



; - - - - - - - - - - - - -
	Lib_Def	RIllDir
RIllDir
; - - - - - - - - - - - - -
	moveq	#17,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	OOfData
; - - - - - - - - - - - - -
OOfData	moveq	#33,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	OOfBuf
; - - - - - - - - - - - - -
OOfBuf	moveq	#11,d0			Out of buffer space
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	InpTL
InpTL
; - - - - - - - - - - - - -
	moveq	#DEBase+20,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	EProErr
EProErr
; - - - - - - - - - - - - -
	moveq	#8,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	ResLNo
ResLNo
; - - - - - - - - - - - - -
	moveq	#6,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	NoOnErr
NoOnErr
; - - - - - - - - - - - - -
	moveq	#5,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	ResPLab
ResPLab
; - - - - - - - - - - - - -
	moveq	#4,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	NoResume
NoResum
; - - - - - - - - - - - - -
	moveq	#3,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	NoErr
NoErr
; - - - - - - - - - - - - -
	moveq	#7,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	OofStack
OofStack
; - - - - - - - - - - - - -
	moveq 	#13,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	NonDim
NonDim
; - - - - - - - - - - - - -
	moveq 	#27,d0
	bra.s 	RunErr
; - - - - - - - - - - - - -
	Lib_Def	AlrDim
AlrDim
; - - - - - - - - - - - - -
	moveq 	#28,d0
	bra.s 	RunErr
; - - - - - - - - - - - - -
	Lib_Def	DByZero
DByZero
; - - - - - - - - - - - - -
	moveq 	#20,d0
	bra.s 	RunErr
; - - - - - - - - - - - - -
	Lib_Def	OverFlow
OverFlow
; - - - - - - - - - - - - -
	moveq 	#29,d0
	bra.s 	RunErr
; - - - - - - - - - - - - -
	Lib_Def	RetGsb
RetGsb
; - - - - - - - - - - - - -
	moveq	#1,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
	Lib_Def	PopGsb
PopGsb
; - - - - - - - - - - - - -
	moveq	#2,d0
	bra.s	RunErr
; - - - - - - - - - - - - -
TypeMis
; - - - - - - - - - - - - -
	moveq	#34,d0

; __________________________________________________________________________
;
;	Traitement des erreurs RUN TIME
; __________________________________________________________________________
;
; - - - - - - - - - - - - -
	Lib_Def	Error
; - - - - - - - - - - - - -
RunErr:	moveq	#19,d1
	moveq	#-1,d2
; - - - - - - - - - - - - -
	Lib_Def	ErrorExt
; - - - - - - - - - - - - -
RunErrExt
; Recupere les registres?
; ~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	ErrorRegs(a5)
	beq.s	.Skip
	clr.b	ErrorRegs(a5)
	movem.l	ErrorSave(a5),d6-d7
.Skip
; Appel des routines de fermeture
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	d0-d2/a0,-(sp)
	lea	Sys_ErrorRoutines(a5),a1
	SyCall	CallRoutines
	movem.l	(sp)+,d0-d2/a0
; Erreurs patchees?
; ~~~~~~~~~~~~~~~~~
	tst.l	Patch_Errors(a5)
	bne	J_EPatch
; Peut-on detourner l'erreur?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	clr.l	PrintPos(a5)
	clr.w	InputFlg(a5)
	clr.w	ContFlg(a5)
	cmp.w	#11,d0			* Variable space?
	beq.s	.skip
	cmp.w	d1,d0
	bcs	rErr1
.skip	cmp.w	#1000,d0		* Edit / Direct?
	bcc	rErr1
	tst.w	Direct(a5)		* Mode direct
	bne	rErr1
	tst.w	ErrorOn(a5)		* Erreur en route
	bne	rErr1
	cmp.l	TrapAdr(a5),d7		* TRAP?
	beq.s	.ETrap
	tst.l	OnErrLine(a5)		* On error goto
	beq	rErr1
; ON ERROR GOTO
; ~~~~~~~~~~~~~
	clr.l	TrapAdr(a5)		Plus de trap
	clr.w	TrapErr(a5)
	addq.w	#1,d0
	addq.w	#1,d2
	lsl.w	#8,d2
	or.w	d2,d0
	move.w	d0,ErrorOn(a5)		Numero de l'erreur
	move.l	PLoop(a5),a3		Position pile expression
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.l	d7,d5
	subq.l	#2,d5
	tst.w	ErrorChr(a5)
	bmi.s	.rErr0
	move.l	d5,ErrorChr(a5)		On error GOTO
	move.l	OnErrLine(a5),a6
	rts
; ON ERROR PROC
; ~~~~~~~~~~~~~
.rErr0	move.l	d5,a6			Retour procedure= RESUME
	move.l	OnErrLine(a5),a2
	move.w	ErrorOn(a5),-(sp)
	bra	InProE
; Nouvelle intruction TRAP
; ~~~~~~~~~~~~~~~~~~~~~~~~
.ETrap	clr.l	TrapAdr(a5)
	addq.w	#1,d2
	lsl.w	#8,d2
	or.w	d2,d0
	move.w	d0,TrapErr(a5)
	move.l	PLoop(a5),a3
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.l	d7,d5
	subq.l	#2,d5
	move.l	d5,a0
.ResN1	move.w	(a0)+,d0
	bsr	TInst
	bne.s	.ResN2
	tst.w	(a0)
	beq.s	.ResN2
	addq.l	#2,a0
.ResN2	tst.w	d0
	bsr	FinieB
	bne.s	.ResN1
	move.l	a0,a6
	rts

; Erreurs non d�tourn�es : les menus sont ouverts.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
E_Retour:
rErr1:
; Un peu de menage...
; ~~~~~~~~~~~~~~~~~~~
	movem.l	a0/d0-d2,-(sp)
; Effacement des includes
	move.l	d7,a0
	subq.l	#2,a0
	Rjsr	L_Includes_Adr
	move.l	a0,VerPos(a5)
	Rjsr	L_Includes_Clear
; Depile le programme
	move.l	Prg_JError(a5),a2
	Rjsr	L_Prg_Pull
; Une erreur extension?
; ~~~~~~~~~~~~~~~~~~~~~
	movem.l	(sp)+,a0/d0-d2
	move.w	d0,d1
	tst.w	d2
	bpl.s	.Ext
; Erreur normale, branche a l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	sub.l	a0,a0
	bra.s	.Jmp
; Erreur extension: trouve le message
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ELoop	tst.b	(a0)+
	bne.s	.ELoop
.Ext	dbra	d1,.ELoop
	moveq	#1,d0			Change le numero message!
; Branche � la routine courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Jmp	jmp	(a2)
; Branchement � un detournement des erreurs
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
J_EPatch
	move.l	Patch_Errors(a5),a0
	jmp	(a0)



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEBUT DES ROUTINES AMOS / CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Start_Type
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	||APCMP|| appel de procedure compilee
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	InAPCmp
; - - - - - - - - - - - - -
	jsr	APrg_Program(a6)	Appelle le programme
	move.l	AdTokens(a5),a4		Recharge a4
	tst.l	d0
	bmi	RunII			-1 >>> deuxieme partie de RUN
	bne.s	.Err			Si erreur >>> BREAK!
	lea	APrg_EndProc(a6),a6	Pointe le delta a la fin
	add.l	(a6),a6
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	movem.l	d6/d7,Chr_Debug+4(a5)
	ENDC
	rts
.Err	move.l	#512,d1			Force l'arret!
	moveq	#-1,d2
	Rbra	L_ErrorExt

; - - - - - - - - - - - - -
	Lib_Def	InAPCmpCLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	INSTRUCTION RUN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRun0
; - - - - - - - - - - - - -
	tst.w	Direct(a5)
	beq	Synt
	Rjmpt	L_Ed_RunDirect
; - - - - - - - - - - - - -
	Lib_Def	InRun0CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InRun1
; - - - - - - - - - - - - -
	tst.w	Direct(a5)
	bne	RIllDir
	tst.l	Mon_Base(a5)
	bne	PRun_Acc
	tst.b	Prg_Accessory(a5)
	bne	PRun_Acc
; Verifie la presence du programme
	move.l	d3,a2
	move.w	(a2)+,d2
	move.l	Name1(a5),a0
	Rjsr	L_ChVerBuf2
	Rjsr	L_Dsk.PathIt
	move.l	#1005,d2		Verifie la presence du fichier!
	Rbsr	L_D_Open
	beq	JDisk
	Rbsr	L_D_Close		Le ferme!
; Effacement des includes
	lea	-2(a4),a0
	Rjsr	L_Includes_Adr
	move.l	a0,VerPos(a5)
	Rjsr	L_Includes_Clear
; - - - - - - - - - - - - -
RunII
; - - - - - - - - - - - - -
; Fait un new, sans effacer les ecrans
	move.l	Prg_Runned(a5),a6
	moveq	#0,d0			Pas d'effacement
	Rjsr	L_Prg_New
; Depile le programme
	Rjsr	L_Prg_Pull
; Charge le nouveau programme dans la structure
	move.b	#1,Prg_Reloaded(a6)
	moveq	#-1,d0			Toujours adapter!
	Rjsr	L_Prg_Load
	cmp.w	#-1,d0
	beq.s	.DErr
	cmp.w	#-2,d0
	ble.s	.OMem
; Run le nouveau programme
	moveq	#-1,d0			Semi init graphique
	move.l	Prg_JError(a5),a1	Ou se brancher en erreur
	sub.l	a2,a2			Pas de message
	Rjsr	L_Prg_RunIt
; Erreurs
; ~~~~~~~
.OMem	moveq	#36,d0
	bra.s	.Err
.DErr	moveq	#101,d0
.Err	sub.l	a0,a0
	move.l	Prg_JError(a5),a1
	jmp	(a1)
Rn_NoF	moveq	#81,d0			Erreur normale!
	Rjmp	L_Error
; - - - - - - - - - - - - -
	Lib_Def	InRun1CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 		INSTRUCTION PRUN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPRun
; - - - - - - - - - - - - -
	tst.w	Direct(a5)
	bne	RIllDir
	tst.l	Mon_Base(a5)
	bne	PRun_Acc
;	tst.b	Prg_Accessory(a5)
;	bne	PRun_Acc
	move.l	d3,a2
	move.w	(a2)+,d2
	move.l	Name1(a5),a0
	Rjsr	L_ChVerBuf2
; Sauve le programme courant
	movem.l	a3-a6/d6/d7,-(sp)
; Le programme est-il deja charge?
	Rjsr	L_Prg_AccAdr
	beq.s	.Loadit
	move.l	a0,a6
	Rjsr	L_Prg_DejaRunned
	beq.s	.Runit
; Il faut charger: verifie la presence du programme
.Loadit	Rjsr	L_Dsk.PathIt
	move.l	#1005,d2		Verifie la presence du fichier!
	Rbsr	L_D_Open
	beq	JDisk
	Rbsr	L_D_Close		Le ferme!
; Ouvre une nouvelle structure
	moveq	#0,d0			Pas de buffer
	Rjsr	L_Prg_NewStructure	Ouvre la structure
	beq	OOfMem
	move.l	d0,a6
; Charge le programme
	moveq	#-1,d0			Toujours adapter
	Rjsr	L_Prg_Load
	tst.w	d0
	bne	.LErr
	move.l	a6,-(sp)		Remet les banques
	move.l	Prg_Runned(a5),a6	du premier programme
	Rjsr	L_Prg_SetBanks
	move.l	(sp)+,a6
; Programme charge: on le demarre!
.Runit	moveq	#-1,d0			Semi init graphique
	lea	PRun_Errors(pc),a1	Retour en cas d'erreur
	sub.l	a2,a2			Pas de message
	move.l	sp,BasSp(a5)		Bas de la pile
	Rjsr	L_Prg_RunIt
	bra.s	.OMm
; Erreur lors du chargement
.LErr	move.w	d0,d1
	moveq	#101,d0
	cmp.w	#-1,d1
	beq.s	.Goerr
.OMm	moveq	#36,d0
; Revient au programme, avec un message d'erreur
.Goerr	move.l	d0,-(sp)
	tst.b	Prg_Edited(a6)		Efface la structure s'il faut
	bne.s	.Edited
	Rjsr	L_Prg_DelStructure
.Edited	move.l	Prg_Runned(a5),a6
	Rjsr	L_Prg_SetBanks
	Rjsr	L_Bnk.Change
	move.l	(sp)+,d0
	move.l	Ed_RunMessages(a5),a0
	Rjsr	L_GetMessage
	movem.l	(sp)+,a3-a6/d6/d7
	move.l	sp,BasSp(a5)
	Rbra	L_ZapReturn
PRun_Acc
 	moveq	#102,d0
	Rjmp	L_Error
;	Retour d'erreur lors de PRUN
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRun_Errors
	move.l	BasSp(a5),sp
	movem.l	(sp)+,a3-a6/d6/d7	Restore le programme
	move.l	sp,BasSp(a5)
	movem.l	d6/d7,ErrorSave(a5)	Au cas zou
	IFNE	Debug
	movem.l	d6/d7,Chr_Debug+4(a5)	Pour empecher le plantage
	ENDC
	movem.l	a0-a1/d0-d1,-(sp)
	bsr	Open_MathLibraries	Rouvre les libraries
	movem.l	(sp)+,a0-a1/d0-d1

	cmp.w	#10,d0
	beq.s	.Nul
	cmp.w	#1000,d0
	blt.s	.Null
.Nul	moveq	#0,d0
.Null	move.l	ChVide(a5),a0
	Rbra	L_ZapReturn
JDisk	Rjmp	L_DiskError
; - - - - - - - - - - - - -
	Lib_Def	InPRunCLI
; - - - - - - - - - - - - -


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		ASK EDITOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InAskEditor1
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	move.l	d3,-(a3)
	Rbra	L_InAskEditor3
; - - - - - - - - - - - - -
	Lib_Def	InAskEditor1CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par	InAskEditor2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	Rbra	L_InAskEditor3
; - - - - - - - - - - - - -
	Lib_Def	InAskEditor2CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InAskEditor3
; - - - - - - - - - - - - -
	bsr	Ed_Par
	tst.l	Edit_Segment(a5)
	beq	FonCall
	Rjsrt	L_Ed_ZapFonction
	move.l	d0,ParamE(a5)
	move.l	ChVide(a5),ParamC(a5)
	tst.w	d2
	beq.s	.Skip
	Rjsr	L_A0ToChaine
	move.l	a0,ParamC(a5)
.Skip	rts
; - - - - - - - - - - - - -
	Lib_Def	InAskEditor3CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		ZAPPEUSE D'EDITEUR!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InCallEditor1
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	move.l	d3,-(a3)
	Rbra	L_InCallEditor3
; - - - - - - - - - - - - -
	Lib_Def	InCallEditor1CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InCallEditor2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	Rbra	L_InCallEditor3
; - - - - - - - - - - - - -
	Lib_Def	InCallEditor2CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InCallEditor3
; - - - - - - - - - - - - -
	bsr	Ed_Par			Recupere les parametres
	tst.l	Edit_Segment(a5)
	beq	FonCall
	move.l	BasSp(a5),-(sp)		Pousse la pile
	movem.l	a3-a6/d6/d7,-(sp)	Pousse le programme
	move.l	sp,BasSp(a5)
	subq.l	#4,BasSp(a5)
	Rjsrt	L_Ed_ZapIn		Appel de l'editeur
	movem.l	(sp)+,a3-a6/d6/d7
	move.l	(sp)+,BasSp(a5)
	Rbra	L_ZapReturn
; - - - - - - - - - - - - -
	Lib_Def	InCallEditor3CLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Int	Bnk.PrevProgram
	Lib_Def	Bnk.PrevProgramCLI
; - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Int	Bnk.CurProgram
	Lib_Def	Bnk.CurProgramCLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	=Prg Under
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnPrgUnder
; - - - - - - - - - - - - -
	moveq	#-1,d3
	tst.l	Mon_Base(a5)		Si moniteur: RIEN!
	bne.s	.Exit
	move.l	Prg_Runned(a5),a0	Un programme en dessous?
	move.l	Prg_Previous(a0),d0	Non!
	bne.s	.Out
	move.l	Edt_Current(a5),d0	Le programme courant?
	beq.s	.Exit
	move.l	d0,a1
	move.l	Edt_Prg(a1),d0
	cmp.l	d0,a0			Non!
	beq.s	.Exit
	tst.l	Edit_Segment(a5)	Editeur KILL?
	beq.s	.Out
	moveq	#1,d3			OUIIIIIII
	bra.s	.Out
.Exit	moveq	#0,d3
.Out	Ret_Int
; - - - - - - - - - - - - -
	Lib_Def	FnPrgUnderCLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Int	InCloseEditor
	Lib_Def	InCloseEditorCLI
	Lib_Int	InKillEditor
	Lib_Def	InKillEditorCLI
	Lib_Int	InMonitor
	Lib_Def	InMonitorCLI
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FIN DES ROUTINES AMOS / CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	End_Type
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Def	RunName
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Recupere les parametres
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Ed_Par
; - - - - - - - - - - - - -
Ed_Par	move.l	Name1(a5),a0
	move.l	Name2(a5),a1
	clr.w	(a1)
	cmp.l	#EntNul,d3
	beq.s	.Skip
	move.l	d3,a2
	move.w	(a2)+,d2
	move.w	d2,(a1)
	Rjsr	L_ChVerBuf2
.Skip	move.l	(a3)+,d1
	move.l	(a3)+,d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Retour de zappeuse
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	ZapReturn
; - - - - - - - - - - - - -
	move.l	ChVide(a5),ParamC(a5)
	ext.l	d0
	move.l	d0,ParamE(a5)
	beq.s	.Bof
	Rjsr	L_A0ToChaine
	move.l	a0,ParamC(a5)
.Bof	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	=Prg State
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnPrgState
; - - - - - - - - - - - - -
	move.w	T_AMOState(a5),d3
	ext.l	d3
	Ret_Int

; - - - - - - - - - - - - -
	Lib_Def	GetInstruction
	Lib_Def	GetInstruction2
; - - - - - - - - - - - - -


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					REM
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRem
; - - - - - - - - - - - - -
	add.w	(a6)+,a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					SET BUFFER  / SET STACK
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InSetBuffer
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: branch.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						SAUTE UN LABEL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InLab
; - - - - - - - - - - - - - - - -
	moveq	#0,d0
	move.b	2(a6),d0
	lea	4(a6,d0.w),a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					SYSTEM
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InSystem
InSystem
; - - - - - - - - - - - - -
	move.w	#1002,d0
	bra	RunErr
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EDIT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InEdit
InEdit
; - - - - - - - - - - - - -
	move.w	#1000,d0
	bra	RunErr
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					DIRECT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InDirect
InDirect
; - - - - - - - - - - - - -
	move.w	#1001,d0
	bra	RunErr

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					BREAK ON / OFF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InBreakOn
InBreakOn
; - - - - - - - - - - - - -
	bset	#BitControl,ActuMask(a5)
	clr.l	OnBreak(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Par InBreakOff
InBreakOff
; - - - - - - - - - - - - -
	bclr	#BitControl,ActuMask(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ON BREAK PROC label
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InOnBreak
InOnBreak
; - - - - - - - - - - - - -
	bsr	GetLabel
	beq	LbNDef
	move.l	d0,OnBreak(a5)
	bclr	#BitControl,ActuMask(a5)
;	Rlea	L_OnBreakGo,0		Pas de routine de branchement
;	move.l	a0,GoTest_OnBreak(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ON ERROR ...
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InOnError
InOnError
; - - - - - - - - - - - - -
	tst.w	ErrorOn(a5)		Error not resumed!
	bne	NoResum
	clr.l	OnErrLine(a5)
	clr.l	ErrorChr(a5)
	cmp.w	#_TkPrc,(a6)
	beq.s	OnEPrc
	cmp.w	#_TkGto,(a6)
	bne.s	.Skip
	addq.l	#2,a6
	cmp.w	#_TkEnt,(a6)
	bne.s	OnEg1
	move.l	2(a6),d0
	bne.s	OnEg1
	addq.l	#6,a6
.Skip	rts

OnEg1	bsr	GetLabel
	beq	LbNDef
	move.l	d0,OnErrLine(a5)
	rts

* ON ERROR PROC
OnEPrc:	addq.l	#4,a6
	move.w	(a6)+,d0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	LabHaut(a5),a2
	move.l	0(a2,d0.w),OnErrLine(a5)
	bset	#7,ErrorChr(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InOnErrorGoto
	Lib_Def	InOnErrorProc
; - - - - - - - - - - - - -
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					RESUME LABEL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InResumeLabel
InResumeLabel
; - - - - - - - - - - - - -
	bsr	Finie
	beq.s	ResL1
	tst.l	OnErrLine(a5)
	beq	NoOnErr
	tst.w	ErrorChr(a5)
	bpl	NoOnErr
	bsr	GetLabel
	beq	LbNDef
	bset	#31,d0
	move.l	d0,ErrorChr(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InResumeLabel1
; - - - - - - - - - - - - -
* Resume label proprement dit
ResL1:	bsr	Test_Normal
	tst.w	ErrorOn(a5)
	beq	NoErr
	bsr	PopP
	clr.w	ErrorOn(a5)
	move.l	ErrorChr(a5),d0
	bclr	#31,d0
	beq	NoOnErr
	tst.l	d0
	beq	ResLNo
	move.l	d0,a6
	bra	LGoto

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					RESUME [label]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InResume
InResume
; - - - - - - - - - - - - -
	bsr	Test_Normal
	tst.w	ErrorOn(a5)
	beq	NoErr
	tst.w	ErrorChr(a5)
	bmi.s	ResP
	bsr	Finie
	bne.s	ResL
	clr.w	ErrorOn(a5)
	move.l	ErrorChr(a5),a6
	bra	LGoto
ResL:	bsr	GetLabel
	beq	LbNDef
	clr.w	ErrorOn(a5)
	move.l	d0,a6
	bra	LGoto
* PROCEDURE ERREUR!
ResP:	bsr	Finie			* Pas de label!
	bne	ResPLab
	bsr	PopP			* POPpe la procedure
	clr.w	ErrorOn(a5)
	bra	LGoto
; - - - - - - - - - - - - -
	Lib_Def	InResume1
; - - - - - - - - - - - - -
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					RESUME NEXT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InResumeNext
InResumeNext
; - - - - - - - - - - - - -
	bsr	Test_Normal
	tst.w	ErrorOn(a5)
	beq	NoErr
	tst.w	ErrorChr(a5)
	bmi.s	ResNP
	clr.w	ErrorOn(a5)
	move.l	ErrorChr(a5),a0
ResN1:	move.w	(a0)+,d0
	bsr	TInst
	bne.s	ResN2
	tst.w	(a0)
	beq.s	ResN2
	addq.l	#2,a0
ResN2:	tst.w	d0
	bsr	FinieB
	bne.s	ResN1
	move.l	a0,a6
	bra	LGoto
* Procedure erreur!
ResNP:	bsr	PopP
	move.l	a6,a0
	clr.w	ErrorOn(a5)
	bra.s	ResN1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TRAP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InTrap
InTrap
; - - - - - - - - - - - - -
	lea	2(a6),a0
	move.l	a0,TrapAdr(a5)
	clr.w	TrapErr(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=TRAPERR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnErrTrap
FnErrTrap
; - - - - - - - - - - - - -
	moveq	#0,d3
	move.w	TrapErr(a5),d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EVERY n PROC GOSUB label
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	InEveryGosub
	Lib_Def	InEveryProc
	Lib_Par InEvery
InEvery
; - - - - - - - - - - - - -
;	Rlea	L_EveJump,0		Pas de routine de branchement!
;	move.l	a0,GoTest_Every(a5)
	bclr	#BitEvery,ActuMask(a5)
	bsr	New_Expentier
	tst.l	d3
	beq	FonCall
	cmp.l	#32767,d3
	bcc	FonCall
	move.w	d3,EveCharge(a5)
	move.w	d3,T_EveCpt(a5)
	move.w	(a6)+,EveType(a5)
	bsr	GetLabel
	beq	LbNDef
	move.l	d0,EveLabel(a5)
	bset	#BitEvery,ActuMask(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EVERY OFF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InEveryOff
InEveryOff
; - - - - - - - - - - - - -
	bclr	#BitEvery,ActuMask(a5)
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EVERY ON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InEveryOn
InEveryOn
; - - - - - - - - - - - - -
	bset	#BitEvery,ActuMask(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InFor
InFor
; - - - - - - - - - - - - -
	move.w	(a6)+,d0		Pousse l'adresse du NEXT
	pea	0(a6,d0.w)
	bsr	FindVar
	move.w	d2,-(sp)
	move.l	a0,-(sp)
	bsr	Fn_New_Evalue		Egalise la variable
	move.w	4(sp),d1
	bsr	MMType
	move.l	(sp)+,a0
	move.l	d3,(a0)
	move.l	a0,-(a3)
	bsr	Fn_New_Evalue		Cherche la limite
	move.w	(sp),d1
	bsr	MMType
	move.l	d3,-(a3)
	moveq	#0,d2
	moveq	#1,d3
	cmp.w	#_TkStp,(a6)
	bne.s	For3
	bsr	Fn_New_Evalue		Cherche la STEP
For3:	move.w	(sp)+,d1
	bsr	MMType
	move.l	d3,-(a3)
	move.w	d2,-(a3)		Poke le type
	move.l	(sp)+,a0
	moveq	#TForNxt,d0
	bra	Rpt0
* Egalise le type D3 au type demande (D1)
MMType:	cmp.b	d1,d2
	bne.s	MMt1
	rts
MMt1:	tst.b	d2
	beq.s	.Int
	Rjmpt	L_FlToInt1
.Int	Rjmpt	L_IntToFl1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					NEXT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InNext
InNext
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TNext
RNext	move.l	20(a3),a2
	tst.b	11(a3)
	bne.s	NextF
	move.l	12(a3),d3
	move.l	16(a3),d4
; TRAVAILLE SUR ENTIERS
	add.l 	d3,(a2)         ;ENTIER
        tst.l 	d3
        bpl.s 	next1
; step negative: inferieur
	cmp.l 	(a2),d4
        ble.s 	nextR
        bra.s 	nextS
; step positive: superieur
next1:  cmp.l 	(a2),d4
        blt.s 	nextS
; ON RESTE DANS LA BOUCLE!
nextR:  move.l	6(a3),a6
	rts
; ON SORT DE LA BOUCLE!
nextS: 	add.w	#TForNxt,a3
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	cmp.w	#_TkVar,(a6)	Saute la variable
	bne.s	.Skip
	bsr	FindVar
.Skip	rts
; Appel du test
TNext:	bsr	Test_Force
	bra.s	RNext
; TRAVAILLE SUR FLOAT simple precision
NextF:	move.l	12(a3),d3
	move.l	16(a3),d4
	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	move.l	d3,d1
	jsr	SPTst(a6)
	move.l	d0,d2
	move.l	d3,d0
	move.l 	(a2),d1
	jsr	SPAdd(a6)
	move.l	d0,(a2)
	move.l	d4,d1
	jsr	SPCmp(a6)
	move.l	(sp)+,a6
	blt	NextF1
	tst.l	d2
	bpl.s	nextS
	bmi.s	nextR
NextF1	tst.l	d2
	bpl.s	nextR
	bmi.s	nextS
; - - - - - - - - - - - - -
	Lib_Def	InNextF
	Lib_Def	InNextD
; - - - - - - - - - - - - -


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					REPEAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRepeat
InRepeat
; - - - - - - - - - - - - -
	move.w	(a6)+,d0
	lea	0(a6,d0.w),a0
	moveq	#TRptUnt,d0
Rpt0:	tst.w	(a6)+
	bne.s	Rpt1
	addq.l	#2,a6
Rpt1:	move.l	a6,-(a3)
	move.l	a0,-(a3)
	move.w	d0,-(a3)
	cmp.l	MinLoop(a5),a3
	bcs	OofStack
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					UNTIL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InUntil
InUntil
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TUnt
RUnt	bsr	New_Expentier
	tst.l	d3
	bne.s	Unt1
* On reste dans la boucle
	move.l	6(a3),a6
	rts
* On sort de la boucle
Unt1:	lea	TRptUnt(a3),a3
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	rts
TUnt	bsr	Test_Force
	bra.s	RUnt

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					WHILE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InWhile
InWhile
; - - - - - - - - - - - - -
	move.w	(a6)+,d0
	move.l	a6,-(a3)
	add.w	d0,a6
	move.l	a6,-(a3)
	move.w	#TWhlWnd,-(a3)
	cmp.l	MinLoop(a5),a3
	bcs	OofStack
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	bra	RWend

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					WEND
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InWend
InWend
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TWend
RWend	move.l	a6,-(sp)
	move.l	6(a3),a6
	bsr	New_Expentier
	tst.l	d3
	beq.s	Wnd1
* On reste dans la boucle
	addq.l	#4,sp
	rts
* On sort de la boucle
Wnd1:	move.l	(sp)+,a6
	lea	TWhlWnd(a3),a3
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	rts
TWend	bsr	Test_Force
	bra.s	RWend

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					DO
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InDo
InDo
; - - - - - - - - - - - - -
	bra	InRepeat

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					LOOP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InLoop
InLoop
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TLoop
RLoop	move.l	6(a3),a6
	rts
TLoop	bsr	Test_Force
	bra.s	RLoop

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EXIT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InExit
InExit
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TExit
RExit	move.w	(a6)+,d0
	add.w	(a6)+,a3
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	add.w	d0,a6
	rts
TExit:	bsr	Test_Force
	bra.s	RExit

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EXIT IF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InExitIf
InExitIf
; - - - - - - - - - - - - -
	move.l	a6,-(sp)
	addq.l	#4,a6
	bsr	New_Expentier
	tst.l	d3
	beq.s	Exi1
	move.l	(sp)+,a6
	bra	InExit
Exi1:	addq.l	#4,sp
	cmp.w	#_TkVir,(a6)
	bne.s	.Skip
	addq.l	#8,a6
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					IF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InIf
InIf
; - - - - - - - - - - - - -
.Loop	move.l	a6,-(sp)
	addq.l	#2,a6
	bsr	New_Expentier
	tst.l	d3
	bne.s	.IfV
; Faux: ELSE/ENDIF ou ELSE IF
	move.l	(sp)+,a6
	move.w	(a6)+,d0
	bclr	#0,d0			Bit 0=0 => ELSE / ENDIF
	add.w	d0,a6
	beq	LGoto			ENDIF ou ELSE => fini
	subq.l	#2,a6
	bra.s	.Loop
; Vrai
.IfV	addq.l	#4,sp
	cmp.w	#_TkThen,(a6)
	bne.s	.Skip
	addq.l	#2,a6
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ELSE IF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InElseIf
InElseIf
; - - - - - - - - - - - - -
	subq.l	#2,a6
	bra	InElse
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ELSE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InElse
InElse
; - - - - - - - - - - - - -
	move.w	(a6)+,d0
	bclr	#0,d0
	add.w	d0,a6
	bne.s	InElseIf
	cmp.w	#_TkElse,-4(a6)
	beq.s	InElseIf
	bra	LGoto
; - - - - - - - - - - - - -
	Lib_Def	FnElse
; - - - - - - - - - - - - -
	move.l	#EntNul,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					GOSUB
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InGosub
InGosub
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TGosub
RGosub	bsr	GetLabel
	beq	LbNDef
Gos2:	move.l	BasA3(a5),-(a3)
	move.l	a6,-(a3)
	move.l	#"Gosb",-(a3)
	cmp.l	MinLoop(a5),a3
	bcs	OofStack
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	move.l	a3,BasA3(a5)
	move.l	d0,a6
	rts
TGosub:	bsr	Test_Force
	bra.s	RGosub

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InReturn
InReturn
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TRetN
RRetN	move.l	BasA3(a5),a3
	move.l	#"Gosb",d0
	cmp.l	(a3)+,d0
	bne	RetGsb
	move.l	(a3)+,a6
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	rts
TRetN	bsr	Test_Force
	bra.s	RRetN

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					POP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPop
InPop
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TPop
RPop	move.l	BasA3(a5),a3		BUG si POP au milieu d'une boucle
	move.l	#"Gosb",d0
	cmp.l	(a3)+,d0
	bne	PopGsb
	addq.l	#4,a3
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	bra	LGoto
TPop:	bsr	Test_Force
	bra	RPop

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PASSAGE SUR PROCEDURE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	DProc1
	Lib_Def	DProc2F
	Lib_Def	DProc2D
	Lib_Def	FProc
	Lib_Def	PrgInF
	Lib_Def	PrgInD
; - - - - - - - - - - - - -
	Lib_Par InProcedure
InProcedure
; - - - - - - - - - - - - -
	move.l	(a6)+,d0
	lea	4(a6,d0.l),a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PROC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InProc
InProc
; - - - - - - - - - - - - -
	addq.w	#2,a6
	bra	CallProc
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					APPEL PROCEDURE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	CallProc
CallProc
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi	TInPro
RInPro	move.w	(a6)+,d0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	LabHaut(a5),a2
	move.l	0(a2,d0.w),a2
	clr.w	-(sp)
* Entree pour la routine d'erreur
InProE	clr.l	-(sp)
* Bas de la zone de variables
InPrOn2	addq.l	#6,a2
* Assez de m�moire?
	move.l	TabBas(a5),a1
	lea	-6-4(a1),a0
	sub.w	(a2),a0
	cmp.l	HiChaine(a5),a0
	bcc.s	InP0b
	move.l	a1,-(sp)
	moveq	#0,d3
	Rbsr	L_Menage
	move.l	(sp)+,a1

;	IFNE	Debug>1
;	movem.l	d0-d7/a0-a6,-(sp)
;	moveq	#20,d3
;	JJsrIns	L_InBell1,1
;	movem.l	(sp)+,d0-d7/a0-a6
;	ENDC
;	IFNE	Debug>3
;	Rjsr	L_PreBug
;	ENDC

* Recule les piles de variables
InP0b	move.l	VarLoc(a5),-(a1)
	move.w	#$FFFF,-(a1)
	move.l	a1,a0
	sub.w	(a2)+,a0
	addq.l	#2,a2
	move.l	a0,-(sp)
* Nettoie les variables
	move.l	a1,d0
	sub.l	a0,d0
	beq.s	.Clr3
	lsr.l	#2,d0
	bcc.s	.Clr1
	clr.w	(a0)+
.Clr1	subq.w	#1,d0
.Clr2	clr.l	(a0)+
	dbra	d0,.Clr2
.Clr3	move.b	4(a2),d0
	ext.w	d0
	lea	6(a2,d0.w),a2
	cmp.w	#_TkBra1,(a6)
	bne.s	InPx
* Recupere les variables
InPa:	addq.l	#2,a6
	pea	4(a2)
	bsr	New_Evalue
	move.l	(sp)+,a2
	move.w	(a2)+,d0
	bmi	InPaGlo
	move.l	(sp),a1
	lea	2(a1,d0.w),a1
InPa0	move.b	(a2)+,d0
	ext.w	d0
	move.b	(a2)+,d1
	add.w	d0,a2
	and.w	#$0F,d1
	lea	Long_Var(a5),a0
	move.b	0(a0,d1.w),-2(a1)	Longueur de la variable
	move.b	d1,-1(a1)		Flag
	cmp.b	d1,d2			Des conversions?
	beq.s	InPe
	move.l	a1,-(sp)
	tst.b	d2
	bne.s	InPc
	Rjsrt	L_IntToFl1
	bra.s	InPd
InPc	Rjsrt	L_FlToInt1
InPd	move.l	(sp)+,a1
InPe	move.l	d3,(a1)
	cmp.b	#8,-2(a1)		Si Float double
	bne.s	.Skip
	move.l	d4,4(a1)		Met la suite
.Skip	cmp.w	#_TkVir,(a6)
	beq.s	InPa
	addq.l	#2,a6
	addq.l	#2,a2
* Descend les limites
InPx	move.l	(sp)+,a0
	lea	-8(a0),a1
	cmp.l	HiChaine(a5),a1
	bcs.s	ReFaire
	move.l	(sp)+,d0
	beq.s	InPx1
	move.l	d0,a6
InPx1	move.l	BasA3(a5),-(a3)
	move.l	VarLoc(a5),-(a3)
	move.l	TabBas(a5),-(a3)
	move.l	OnErrLine(a5),-(a3)
	move.l	ErrorChr(a5),-(a3)
	move.w	ErrorOn(a5),-(a3)
	move.l	PData(a5),-(a3)
	move.l	AData(a5),-(a3)
	move.l	DProc(a5),-(a3)
	move.l	a6,-(a3)
	move.l	#"Proc",-(a3)		* Code anti crash!!!
	cmp.l	MinLoop(a5),a3
	bcs	OofStack
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	move.l	a3,BasA3(a5)
	move.l	a0,VarLoc(a5)
	move.l	a0,TabBas(a5)
	clr.l	OnErrLine(a5)
	move.l	a2,a6
	addq.l	#2,a2
	move.l	a2,DProc(a5)
	move.l	a2,PData(a5)
	clr.l	AData(a5)
* Erreurs
	move.w	(sp)+,ErrorOn(a5)
* Branche a la procedure
	rts
* Les variables ont ete effacees par les chaines!
ReFaire	move.l	TabBas(a5),d3
	lea	-16(a0),a0
	sub.l	a0,d3
	bra	Demande
* Test entree de procedure
TInPro	bsr	Test_Force
	bra	RInPro
* Si variable globale
InPaGlo	move.l	VarGlo(a5),a1
	neg.w	d0
	lea	1(a1,d0.w),a1
	bra	InPa0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					END PROC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InEndProc
InEndProc
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TEProc
REProc	cmp.w	#_TkBra1,(a6)
	bne.s	EPro1
	bsr	FnEProc
EPro1:	tst.w	ErrorOn(a5)
	bne	EProErr
* Protection anti crash!!!
EPro2	move.l	(a3),d0
	addq.l	#2,a3
	cmp.l	#"Proc",d0
	bne.s	EPro2
	addq.l	#2,a3
* Ok!
	move.l	(a3)+,d0
	move.l	(a3)+,DProc(a5)
	move.l	(a3)+,AData(a5)
	move.l	(a3)+,PData(a5)
	move.w	(a3)+,ErrorOn(a5)
	move.l	(a3)+,ErrorChr(a5)
	move.l	(a3)+,OnErrLine(a5)
	move.l	(a3)+,TabBas(a5)
	move.l	(a3)+,VarLoc(a5)
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	move.l	d0,a6
	tst.l	d0
	beq.s	.Menu
	rts
* Retour au MENU!!!
.Menu	move.l	MnPile(a5),a0
	lea	-4(a0),sp
	rts
TEProc:	bsr	Test_Force
	bra.s	REProc

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Routine: retourne ENDPROC[x]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FnEProc
; - - - - - - - - - - - - -
	bsr	Fn_New_Evalue
	subq.b	#1,d2
	bmi.s	FnE1
	beq.s	FnE2
	move.l	d3,ParamC(a5)
	rts
FnE1:	move.l	d3,ParamE(a5)
	rts
FnE2:	move.l	d3,ParamF(a5)
	tst.b	MathFlags(a5)
	bmi.s	.Dble
	rts
.Dble	move.l	d4,ParamF2(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					POP PROC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPopProc
InPopProc
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TPopPro
RPopPro	tst.w	ErrorOn(a5)
	bne	EProErr
	cmp.w	#_TkBra1,(a6)
	bne.s	.Skip
	bsr.s	FnEProc
.Skip	bsr	PopP
	rts
TPopPro	bsr	Test_Force
	bra.s	RPopPro

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Routine Pop Proc
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	PopP
PopP
; - - - - - - - - - - - - -
	move.l	BasA3(a5),a3
* Protection anti crash!!!
.Loop	move.l	(a3),d0
	addq.l	#2,a3
	cmp.l	#"Proc",d0
	bne.s	.Loop
	addq.l	#2,a3
* Ok!
	move.l	(a3)+,d0
	move.l	(a3)+,DProc(a5)
	move.l	(a3)+,AData(a5)
	move.l	(a3)+,PData(a5)
	move.w	(a3)+,ErrorOn(a5)
	move.l	(a3)+,ErrorChr(a5)
	move.l	(a3)+,OnErrLine(a5)
	move.l	(a3)+,TabBas(a5)
	move.l	(a3)+,VarLoc(a5)
	tst.l	d0
	beq	FonCall
	move.l	d0,a6
	move.l	(a3)+,BasA3(a5)
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					GOTO interne: appel direct
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Goto2
Goto2
; - - - - - - - - - - - - -
	move.w	(a6),d0
	move.l	LabHaut(a5),a0
	move.l	0(a0,d0.w),a6
	bra.s	LGoto
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					GOTO
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InGoto
InGoto
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi.s	TGoto
RGoto	bsr	GetLabel
	beq	LbNDef
	move.l	d0,a6
;	Routine GOTO
; ~~~~~~~~~~~~~~~~~~
LGoto	move.l	BasA3(a5),d0
.Loop	cmp.l	d0,a3
	bcc.s	.Ret
	cmp.l	6(a3),a6
	bcs.s	.Skip
	cmp.l	2(a3),a6
	bls.s	.Ret
.Skip	add.w	(a3),a3
	bra.s	.Loop
.Ret	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	rts
; Test pour GOTO
; ~~~~~~~~~~~~~~
TGoto:	bsr	Test_Force
	bra.s	RGoto

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InOn
InOn
; - - - - - - - - - - - - -
	tst.b	T_Actualise(a5)
	bmi	TOn
ROn	move.w	(a6)+,d0
	pea	2(a6,d0.w)
	move.w	(a6)+,-(sp)
	bsr	New_Expentier
	moveq	#0,d2
	move.w	(sp),d2
	move.w	(a6)+,(sp)
	subq.l	#1,d3
	bmi.s	OnR
	beq.s	OnG
	cmp.l	d2,d3
	bcc.s	OnR
* Pointe le bon label et fait le saut
	move.w	d3,-(sp)
On1	bsr	GetLabel
* Pour version 2!
*	cmp.w	#_TkBra1,(a6)+
*	bne.s	On1b
*On1a	cmp.w	#_TkBra2,(a6)+
*	bne.s	On1a
*	cmp.w	#_TkVir,(a6)
*	bne.s	On1a
	addq.l	#2,a6
On1b	subq.w	#1,(sp)
	bne.s	On1
	addq.l	#2,sp
OnG:	move.w	(sp)+,d1
	move.l	(sp)+,a0
	cmp.w	#_TkGto,d1
	beq	InGoto
	cmp.w	#_TkPrc,d1
	beq.s	ROnP
	move.l	BasA3(a5),-(a3)		On Gosub
	move.l	a0,-(a3)
	move.l	#"Gosb",-(a3)
	cmp.l	MinLoop(a5),a3
	bcs	OofStack
	bsr	GetLabel
	beq	LbNDef
	move.l	d0,a6
	move.l	a3,PLoop(a5)
	IFNE	Debug
	move.l	a3,Chr_Debug(a5)
	ENDC
	move.l	a3,BasA3(a5)
	rts
* Appel d'une procedure
ROnP	clr.w	-(sp)			* Flag
	move.l	a0,-(sp)		* Adresse de retour
	bsr	GetLabel
	move.l	d0,a2			* Adresse procedure
	bra	InPrOn2
* Passe a l'instruction suivante
OnR:	addq.l	#2,sp
	move.l	(sp)+,a6
	rts
; Test pour ON
; ~~~~~~~~~~~~
TOn	bsr	Test_Force
	bra	ROn

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					GETLABEL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	GetLabelE
	Lib_Def	GetLabelA
	Lib_Def	GetLabel
GetLabel
; - - - - - - - - - - - - -
	move.w	(a6)+,d0
	cmp.w	#_TkPro,d0
	beq.s	GLb0
	cmp.w	#_TkLGo,d0
	bne.s	GLb1
* Un label NORMAL!!!
GLb0	move.w	(a6)+,d0
	move.l	LabHaut(a5),a0
	move.b	(a6),d1
	ext.w	d1
	lea	2(a6,d1.w),a6
	move.l	0(a0,d0.w),d0
	rts
* Une expression
GLb1	subq.l	#2,a6
	bsr	New_Evalue
	subq.b	#1,d2
	bmi.s	GLb2
	bne.s	GLb3
	Rjsrt	L_FlToInt1
* Ecrit le chiffre dans le buffer!
GLb2	move.l	BufLabel(a5),a1
	move.l	a1,a0
	move.l	d3,d0
	Rjsr	L_LongToDec
	move.l	a0,d2
	sub.l	a1,d2
	beq.s	GLabE
	move.l	a1,d3
	bra.s	GLab
* Chaine alphanumerique
GLb3	move.l	d3,a2
	move.w	(a2)+,d2
	beq.s	GLabE
	cmp.w	#32,d2
	bcc.s	GLabE
	move.w	d2,d1
	subq.w	#1,d1
	move.l	BufLabel(a5),a0
	move.l	a0,d3
GLab0	move.b	(a2)+,d0
	cmp.b	#"A",d0
	bcs.s	GLab1
	cmp.b	#"Z",d0
	bhi.s	GLab1
	add.b	#32,d0
GLab1	move.b	d0,(a0)+
	dbra	d1,GLab0
* Rend pair
GLab	btst	#0,d2
	beq.s	GLab2
	clr.b	(a0)+
	addq.w	#1,d2
* Trouve le label
GLab2	move.l	LabBas(a5),a1
GLab3	move.l	a1,a0
	move.b	(a0),d1
	beq.s	GLabE
	ext.w	d1
	cmp.w	d2,d1
	bne.s	GLabN
	move.l	d3,a2
	addq.l	#8,a0
	move.w	d1,d0
	subq.w	#1,d0
GLab4	cmp.b	(a0)+,(a2)+
	bne.s	GLabN
	dbra	d0,GLab4
* Label trouve!
GLabT	move.l	4(a1),d0
	rts
* Label suivant
GLabN	lea	8(a1,d1.w),a1
	bra.s	GLab3
* Label pas trouve!
GLabE	moveq	#0,d0
	rts
* Erreur!
LbNDef:	moveq	#40,d0
	bra	RunErr

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Instruction finie?
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Finie
Finie
; - - - - - - - - - - - - -
	move.w	(a6),d0
FinieB	beq.s	.Skip
	cmp.w	#_TkDP,d0
	beq.s	.Skip
	cmp.w	#_TkThen,d0
	beq.s	.Skip
	cmp.w	#_TkElse,d0
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	RAMENE LA TAILLE DE L'INSTRUCTION D0 en D1
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	TInst
TInst
; - - - - - - - - - - - - -
	tst.w	d0
	beq	TFin
	cmp.w	#_TkLGo,d0
	bls	TVar
	cmp.w	#_TkCh1,d0
	beq	TCh
	cmp.w	#_TkCh2,d0
	beq	TCh
	cmp.w	#_TkRem1,d0
	beq	TCh
	cmp.w	#_TkRem2,d0
	beq	TCh
	cmp.w	#_TkDFl,d0
	beq.s	T8
	cmp.w	#_TkFl,d0
	bls.s	T4
	cmp.w	#_TkExt,d0
	beq.s	T4
	cmp.w	#_TkFor,d0
	beq.s	T2
	cmp.w	#_TkRpt,d0
	beq.s	T2
	cmp.w	#_TkWhl,d0
	beq.s	T2
	cmp.w	#_TkDo,d0
	beq.s	T2
	cmp.w	#_TkExit,d0
	beq.s	T4
	cmp.w	#_TkExIf,d0
	beq.s	T4
	cmp.w	#_TkIf,d0
	beq.s	T2
	cmp.w	#_TkElse,d0
	beq.s	T2
	cmp.w	#_TkElsI,d0
	beq.s	T2
	cmp.w	#_TkData,d0
	beq.s	T2
	cmp.w	#_TkProc,d0
	beq.s	T8
	cmp.w	#_TkOn,d0
	beq.s	T4
	cmp.w	#_TkEqu,d0
	bcs.s	T0
	cmp.w	#_TkStruS,d0
	bls.s	T6
T0:	moveq	#1,d1
TFin:	rts
T2:	addq.l	#2,a0
	bra.s	T0
T4:	addq.l	#4,a0
	bra.s	T0
T8:	addq.l	#8,a0
	bra.s	T0
T6:	addq.l	#6,a0
	bra.s	T0
TCh:	add.w	(a0)+,a0
	move.w	a0,d1
	btst	#0,d1
	beq.s	T0
	addq.l	#1,a0
	bra.s	T0
TVar:	moveq	#0,d1
	move.b	2(a0),d1
	lea	4(a0,d1.w),a0
	bra.s	T0


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: Evalue.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					EVALUATION D'EXPRESSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Operateur nul (:)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	L_OpeNul
; - - - - - - - - - - - - -
	move.l	#EntNul,d3
	Ret_Int
;						Table des operateurs
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tk_Operateurs
	bra	Op_Xor
	dc.b 	" xor"," "+$80,"O00",-1
	bra	Op_Or
	dc.b 	" or"," "+$80,"O00",-1
	bra	Op_And
	dc.b 	" and"," "+$80,"O00",-1
	bra	Op_Diff
	dc.b 	"<",">"+$80,"O20",-1
	bra	Op_Diff
	dc.b 	">","<"+$80,"O20",-1
	bra	Op_InfEg
	dc.b 	"<","="+$80,"O20",-1
	bra	Op_InfEg
	dc.b 	"=","<"+$80,"O20",-1
	bra	Op_SupEg
	dc.b 	">","="+$80,"O20",-1
	bra	Op_SupEg
	dc.b 	"=",">"+$80,"O20",-1
TOpEg	bra	Op_Egal
	dc.b 	"="+$80,"O20",-1
	bra	Op_Inf
	dc.b 	"<"+$80,"O20",-1
	bra	Op_Sup
	dc.b 	">"+$80,"O20",-1
	bra	Op_Plus
	dc.b 	"+"+$80,"O22",-1
TOpM	bra	Op_Moins
	dc.b 	"-"+$80,"O22",-1
	bra	Op_Modulo
	dc.b 	" mod"," "+$80,"O00",-1
	bra	Op_Mult
	dc.b 	"*"+$80,"O00",-1
	bra	Op_Div
	dc.b 	"/"+$80,"O00",-1
TOpPuis	bra	Op_Puis
	dc.b 	"^"+$80,"O00",-1
	even
OP_Jumps
	dc.l 	0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Entree evaluation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par Fn_New_Evalue
Fn_New_Evalue
; - - - - - - - - - - - - -
	addq.l	#2,a6

; Debut de parenthese
; ~~~~~~~~~~~~~~~~~~~
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Entree de l'evaluation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	New_Evalue
New_Evalue
; - - - - - - - - - - - - -

	IFNE	Debug>1
	move.l	VarBufL(a5),d0		Debuggage
	cmp.l	#1024*1,d0
	bne.s	.NoBug
	Rjsr	L_PreBug
.NoBug
	ENDC

	move.w	#$7FFF,d0
	bra.s	Eva1
Eva0	movem.l	d2/d3/d4,-(a3)
Eva1	move.w	d0,-(a3)
; Recolte d'un operande
; ~~~~~~~~~~~~~~~~~~~~~
	clr.w	-(sp)
OpeRe	move.w	(a6)+,d0
	bmi.s	OpeM
	move.w	0(a4,d0.w),d1
	move.l	-LB_Size-4(a4,d1.w),a0
	jsr	(a0)
	tst.w	(sp)+
	bne.s	Chs0
; Nouvel operateur
; ~~~~~~~~~~~~~~~~
OP_Ret	move.w	(a6)+,d0
	cmp.w	(a3),d0
	bhi.s	Eva0
	subq.l	#2,a6
	move.w	(a3)+,d1
	bpl.s	Eva3
	jmp	OP_Jumps(pc,d1.w)
Eva3	cmp.w	#_TkPar2,d0
	beq.s	Eva4
	rts
Eva4	move.w	(a6)+,d0
	rts
; Changement de signe avant l'operande
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Chs0	tst.b	d2
	bne.s	Chs1
	neg.l	d3
	bra.s	OP_Ret
Chs1	tst.b	MathFlags(a5)
	bmi.s	Dble
	bchg	#7,d3
	bra.s	OP_Ret
Dble	bchg	#31,d3
	bra.s	OP_Ret
; Signe moins devant
; ~~~~~~~~~~~~~~~~~~
OpeM	addq.w	#1,(sp)
	bra	OpeRe

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR PLUS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Plus
; - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	plus1
        bne.s 	plus2
; Plus float!
	moveq	#_LVOSPAdd,d2
	Rjsrt	L_Float_Operation
	lea	12(a3),a3
	bra	OP_Ret
; Addition entiere
plus1:  add.l 	4(a3),d3
        bvs 	OverFlow
	lea	12(a3),a3
	bra	OP_Ret
; Addition de chaines
plus2:  move.l 	d3,a2
        move.l	d3,-(sp)
        clr.l 	d3
        move 	(a2),d3        ;taille de la deuxieme chaine
        beq.s 	plus11        ;deuxieme chaine nulle
        move.l 	4(a3),a2
        clr.l 	d0
        move 	(a2),d0
        beq.s 	plus10          ;premiere chaine nulle
        add.l 	d0,d3
        cmp.l 	#String_Max,d3
        bcc 	StooLong        ;string too long!
        bsr 	Demande
        move 	d3,(a0)+       ;poke la taille resultante
        move 	(a2)+,d0
        beq.s 	plus4
        subq 	#1,d0
plus3:  move.b 	(a2)+,(a0)+  ;recopie de la premiere chaine
        dbra 	d0,plus3
plus4:  move.l 	(sp)+,a2
        move 	(a2)+,d0
        beq.s 	plus6
        subq 	#1,d0
plus5:  move.b 	(a2)+,(a0)+
        dbra 	d0,plus5
plus6:  move 	a0,d0          ;rend pair
        btst 	#0,d0
        beq.s 	plus7
        addq.l 	#1,a0
plus7:  move.l 	a0,HiChaine(a5)
        move.l 	a1,d3
	lea	12(a3),a3
	bra	OP_Ret
plus10: move.l 	(sp)+,d3     ;premiere chaine nulle: ramene la deuxieme
	lea	12(a3),a3
        bra	OP_Ret
plus11: addq.l 	#4,sp        ;deuxieme chaine nulle: ramene la premiere
        move.l 	4(a3),d3
	lea	12(a3),a3
 	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR MOINS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Moins
; - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	ms1
        bne.s 	ms2
; Moins float
	moveq	#_LVOSPSub,d2
	Rjsrt	L_Float_Operation
	lea	12(a3),a3
	bra	OP_Ret
; Moins entier
ms1:    move.l	4(a3),d0
	sub.l	d3,d0          ;soustraction entiere
        bvs 	OverFlow
        move.l 	d0,d3
	lea	12(a3),a3
	bra	OP_Ret
; Soustraction de chaines EXCLUSIF!!!
ms2:    move.l	d5,-(sp)
	move.l	d3,d4        	;sauve pour plus tard
        move.l 	4(a3),a2
        clr.l 	d3
        move.w 	(a2)+,d3
        move.l 	d3,d1
        bsr 	Demande         ;prend la place une fois pour toute!
        move.w 	d3,(a0)+
        beq.s 	ms4
        addq 	#1,d3
        lsr 	#1,d3
        subq 	#1,d3
ms3:    move.w 	(a2)+,(a0)+  	;recopie la chaine
        dbra 	d3,ms3
ms4:    move.l 	a0,HiChaine(a5)
        addq.l 	#2,a1        	;chaine dont auquelle on soustrait en a1/d1
        move.l 	d4,a2
        clr.l 	d2
        move 	(a2)+,d2       	;chaine a soustraire en a2/d2

ms5:    clr.l 	d4
        movem.l d1-d2/a1-a3,-(sp)
	Rjsr	L_InstrFind
        movem.l (sp)+,d1-d2/a1-a3
        tst.l 	d3
        beq.s 	ms9
        move.l 	a1,a0
        move.l 	a1,d4        	;pour plus tard!
        subq.l 	#1,d3
        move.l 	d3,d5        	;taille du debut a garder
        add.l 	d3,a1         	;pointe ou transferer la fin
        add.l 	d2,d3
        add.l 	d3,a0         	;pointe la fin a recopier
        sub.l 	d3,d1
        add.l 	d1,d5         	;taille finale en memoire
        subq.l 	#1,d1
        bmi.s 	ms7
ms6:    move.b 	(a0)+,(a1)+
        dbra 	d1,ms6
ms7:    move 	a0,d0          	;rend pair
        btst 	#0,d0
        beq.s 	ms8
        addq.l 	#1,a0
ms8:    move.l 	a0,HiChaine(a5)
        move.l 	d4,a1
        move.w 	d5,-2(a1)
        move.l 	d5,d1
        bra.s 	ms5
ms9:    moveq 	#2,d2
        move.l 	a1,d3
        subq.l 	#2,d3
	move.l	(sp)+,d5
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR ETOILE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Mult
; - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	milt1
; Multiplie float
	moveq	#_LVOSPMul,d2
	Rjsrt	L_Float_Operation
	lea	12(a3),a3
	bra	OP_Ret
; Entier!
milt1:  move.l	4(a3),d2
	clr 	d4              ;multiplication signee 32*32 bits
        tst.l 	d3            ;aabb*ccdd
        bpl.s 	mlt1
        neg.l 	d3
        not 	d4
mlt1:   tst.l 	d2            ;tests des signes
        bpl.s 	mlt2
        neg.l 	d2
        not 	d4
* Peut on faire une mult rapide?
mlt2:  	cmp.l 	#$00010000,d3
        bcc.s 	mlt0
        cmp.l 	#$00010000,d2
        bcc.s 	mlt0
        mulu 	d2,d3          ;quand on le peut: multiplication directe!
	tst.w 	d4
	beq.s	mltF
	neg.l 	d3
	bra.s 	mltF
* Multipcation lente
mlt0:   move 	d2,d1
        mulu 	d3,d1
        bmi 	OverFlow
        swap 	d2
        move 	d2,d0
        mulu 	d3,d0
        swap 	d0
        bmi 	OverFlow
        tst 	d0
        bne 	OverFlow
        add.l 	d0,d1
        bvs 	OverFlow
        swap 	d3
        move 	d2,d0
        mulu 	d3,d0
        bne 	OverFlow
        swap 	d2
        move 	d2,d0
        mulu 	d3,d0
        swap 	d0
        bmi 	OverFlow
        tst 	d0
        bne 	OverFlow
        add.l 	d0,d1
        bvs 	OverFlow
        tst 	d4              ;signe du resultat
        beq.s 	mlt3
        neg.l 	d1
mlt3:   move.l 	d1,d3
mltF:	moveq	#0,d2
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR DIVISE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Div
; - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	div1
; Divise float
	Rjsrt	L_Float_Test
	beq	DByZero
	move.w	#_LVOSPDiv,d2
	Rjsrt	L_Float_Operation
	lea	12(a3),a3
	bra	OP_Ret
; Divise entier
div1: 	move.l	4(a3),d2
        moveq	#0,d4
        tst.l 	d2
        bpl.s 	dva
        bset	#31,d4
        neg.l 	d2
dva:    tst.l 	d3
        beq 	DByZero         ;division par zero!
        bpl.s 	dvb
    	bchg	#31,d4
        neg.l 	d3
dvb:	cmp.l 	#$10000,d3    	;Division rapide ou non?
        bcc.s 	dv0
        move.l 	d2,d0
        divu 	d3,d0          	;division rapide: 16/16 bits
        bvs.s 	dv0
        moveq 	#0,d3
        move.w	d0,d3
        bra.s 	dvc
dv0:	move.w 	#31,d4         ;division lente: 32/32 bits
        moveq 	#-1,d5
        clr.l 	d1
dv2:    lsl.l 	#1,d2
        roxl.l	#1,d1
        cmp.l 	d3,d1
        bcs.s 	dv1
        sub.l 	d3,d1
        lsr.l	#1,d5           ;met X a un!
dv1:    roxl.l 	#1,d0
        dbra 	d4,dv2
        move.l 	d0,d3
dvc:    tst.l	d4
        bpl.s 	dvd
        neg.l 	d3
dvd:    moveq	#0,d2
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR PUISSANCE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Puis
; - - - - - - - - - - - - -
	bsr 	QueFloat        	;que des float
	move.w	#_LVOSPPow,d2
	Rjsrt	L_Math_Operation	Fait une operation math
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						OPERATEUR MODULO
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Modulo
	bsr 	QuEntier      ;Que des entiers!
	move.l	d6,-(sp)
	move.l	4(a3),d6
	tst.l 	d3
        bpl.s 	mdv3
        neg.l 	d3
mdv3:   moveq 	#31,d2         ;division lente: 32/32 bits
        moveq 	#-1,d4
        clr.l 	d1
mdv2:   lsl.l 	#1,d6
        roxl.l 	#1,d1
        cmp.l 	d3,d1
        bcs.s 	mdv1
        sub.l 	d3,d1
        lsr 	#1,d4           ;met X a un!
mdv1:   roxl.l 	#1,d0
        dbra 	d2,mdv2
	move.l 	d1,d3        ;prend le reste!
	moveq	#0,d2
	move.l	(sp)+,d6
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						OPERATEUR EGAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Egal
; - - - - - - - - - - - - - - - -
	bsr 	Compat
egbis	bmi.s 	eg1             ;entree pour find
        bne.s 	eg2
	Rjsrt	L_Float_Compare
	bne.s	Faux
	bra.s	Vrai
eg1:    cmp.l 	4(a3),d3
        beq.s 	Vrai
Faux:   moveq 	#0,d3
	moveq 	#0,d2
	lea	12(a3),a3
	bra	OP_Ret
Vrai:   moveq 	#-1,d3
        moveq 	#0,d2
	lea	12(a3),a3
	bra	OP_Ret
eg2:    bsr 	compch
	cmp.l	d4,d3
	beq.s	Vrai
	bra.s	Faux

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR INFERIEUR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Inf
; - - - - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	inf1
        bne.s 	inf2
	Rjsrt	L_Float_Compare
	blt	Vrai
	bra	Faux
inf1:   cmp.l 	4(a3),d3
        bgt.s 	Vrai
        bra.s 	Faux
inf2:   bsr 	compch
	cmp.l	d4,d3
        bgt.s 	Vrai
        bra.s 	Faux

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR INFERIEUR OU EGAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_InfEg
; - - - - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	infeg1
        bne.s 	infeg2
	Rjsrt	L_Float_Compare
	ble	Vrai
	bra	Faux
infeg1: cmp.l 	4(a3),d3
        bge 	Vrai
        bra 	Faux
infeg2: bsr 	compch
	cmp.l	d4,d3
        bge 	Vrai
        bra 	Faux

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR DIFFERENT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Diff
; - - - - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	dif1
        bne.s 	dif2
	Rjsrt	L_Float_Compare
	bne	Vrai
	bra	Faux
dif1:   cmp.l 	4(a3),d3
        bne 	Vrai
        bra 	Faux
dif2:   bsr 	compch
	cmp.l	d4,d3
        bne 	Vrai
        bra 	Faux

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR SUPERIEUR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Sup
; - - - - - - - - - - - - - - - -
	bsr 	Compat
	bmi.s 	sup1
        bne.s 	sup2
	Rjsrt	L_Float_Compare
	bgt	Vrai
	bra	Faux
sup1:   cmp.l 	4(a3),d3
        blt 	Vrai
        bra 	Faux
sup2:   bsr 	compch
	cmp.l	d4,d3
        blt 	Vrai
        bra 	Faux

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					OPERATEUR SUPERIEUR OU EGAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_SupEg
; - - - - - - - - - - - - - - - -
	bsr 	Compat
        bmi.s 	supeg1
        bne.s 	supeg2
	Rjsrt	L_Float_Compare
	bge	Vrai
	bra	Faux
supeg1: cmp.l 	4(a3),d3
        ble 	Vrai
        bra 	Faux
supeg2: bsr 	compch
	cmp.l	d4,d3
        ble 	Vrai
        bra 	Faux

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						OPERATEUR AND
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_And
; - - - - - - - - - - - - - - - -
	bsr 	QuEntier
        and.l 	4(a3),d3
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						OPERATEUR OR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Or
; - - - - - - - - - - - - - - - -
	bsr 	QuEntier
        or.l 	4(a3),d3
	lea	12(a3),a3
	bra	OP_Ret

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						OPERATEUR XOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Op_Xor
; - - - - - - - - - - - - - - - -
	bsr 	QuEntier
	move.l	4(a3),d0
        eor.l 	d0,d3
	lea	12(a3),a3
	bra	OP_Ret


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						ROUTINES INTERNES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Que des floats
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
QueFloat
	tst.b 	d2
	bne.s 	Compat
	Rjsrt 	L_IntToFl1
; 	Rend compatible les deux operandes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Compat:	move.b	3(a3),d1
	cmp.b	d1,d2
	bne.s 	Cpt1
	subq.b 	#1,d1
	rts
Cpt1	tst.b	d2
	bne.s 	Cpt2
	Rjsrt	L_IntToFl1		Change D2/D3/D4 en float
	moveq 	#0,d1
	rts
Cpt2	Rjsrt	L_IntToFl2		Change (a3) en float
	moveq 	#0,d1
	rts
; 	Que des entiers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
QuEntier
	tst.b 	d2
	beq.s 	.Quent1
	Rjsrt 	L_FlToInt1		Change d2-d4 en entier
.Quent1	tst.b	3(a3)
	bne.s 	.Cpt3
	rts
.Cpt3	Rjmpt	L_FlToInt2		Change (a3) en entier

; 	COMPARAISON DE DEUX CHAINES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
compch: move.l	4(a3),a0
        move.l 	d3,a1
 	moveq	#0,d3
 	moveq	#0,d4
        clr.b 	d2
        move.w 	(a0)+,d0
        move.w 	(a1)+,d1
        beq.s 	cpch8
        tst 	d0
        beq.s	cpch7
cpch1:  cmpm.b 	(a0)+,(a1)+
        bne.s 	cpch6
        subq 	#1,d0
        beq.s 	cpch3
        subq	#1,d1
        bne.s 	cpch1
; on estrrive au bout d'une des chaines
cpch2:  moveq 	#1,d4         ;A$>B$
        rts
cpch3:  subq 	#1,d1         ;egalite!
        beq.s 	cpch5
cpch4:  moveq 	#1,d3         ;B$>A$
cpch5:  rts
; on estas arrive au bout des chaines
cpch6:  bcc.s 	cpch4
        bcs.s 	cpch2
; a$ estulle
cpch7:  tst 	d1
        beq.s 	cpch5           ;deux chaines nulles
        bne.s 	cpch4           ;B$>A$
; b$ estulle
cpch8:  tst 	d0
        beq.s 	cpch5           ;deux chaines nulles
        bne.s 	cpch2           ;A$>B$

;	Saute D0 params
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Saut_D0Param
	subq.l	#2,a6
Fn_Saut_D0Param
	move.w	d0,-(sp)
.Loop	bsr	Fn_New_Evalue
	subq.w	#1,(sp)
	bne.s	.Loop
	addq.l	#2,sp
	rts
;	Recupere D0 params
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ParD0	subq.l	#2,a6
FnParD0	move.w	d0,-(sp)
.Loop	bsr	Fn_New_Evalue
	cmp.b	#1,d2
	bne.s	.Skip
	Rjsrt	L_FlToInt1
.Skip	move.l	d3,-(a3)
	subq.w	#1,(sp)
	bne.s	.Loop
	addq.l	#2,sp
	rts

;	Expentier: retourne un parametre entier / chaine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Fn_New_Expentier
	addq.l	#2,a6
New_Expentier
	bsr	New_Evalue
	cmp.b	#1,d2
	beq.s	.Skip
	rts
.Skip	Rjmpt	L_FlToInt1



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Instruction vide
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	InNull
; - - - - - - - - - - - - -
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					OPERATEUR NULL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnNull
; - - - - - - - - - - - - -
	move.l	#EntNul,d3
	subq.l	#2,a6
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					VARIABLE EN INSTRUCTION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InVar
; - - - - - - - - - - - - -
	move.w	(a6)+,d0
	bmi.s	.Glo
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
.Glo2	moveq	#0,d1
	move.b	(a6)+,d1
	move.b	(a6)+,d2
	add.w	d1,a6
	btst	#6,d2		* Si tableau, pointe l'interieur
	bne.s	InVarT
	move.l	a0,-(sp)
	move.w	d2,-(sp)
	bsr	Fn_New_Evalue	* Va evaluer
	move.w	(sp)+,d5
	cmp.b	d5,d2		??? Possible probleme si autres flags?
	beq.s	.Skip2
	tst.b	d2
	bne.s	.Skip1
	Rjsrt	L_IntToFl1
	bra.s	.Skip2
.Skip1	Rjsrt	L_FlToInt1
.Skip2	move.l	(sp)+,a0
	cmp.b	#1,d2
	beq.s	.Flt
.Ent	move.b	#4,-2(a0)	La longueur
	move.b	d5,-1(a0)	Le flag
	move.l	d3,(a0)		La valeur
	rts
; Si variable globale
.Glo	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra.s	.Glo2
; Si float
; ~~~~~~~~
.Flt	tst.b	MathFlags(a5)
	bpl.s	.Ent
	move.b	#8,-2(a0)
	move.b	d5,-1(a0)
	move.l	d3,(a0)
	move.l	d4,4(a0)
	rts
;	Un tableau: ne poke pas les flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InVarT	bsr	GetTablo
	and.w	#$000F,d2
	move.l	a0,-(sp)
	move.w	d2,-(sp)
	bsr	Fn_New_Evalue	* Va evaluer
	move.w	(sp)+,d1
	cmp.b	d1,d2
	beq.s	.Skip2
	tst.b	d2
	bne.s	.Skip1
	Rjsrt	L_IntToFl1
	bra.s	.Skip2
.Skip1	Rjsrt	L_FlToInt1
.Skip2	move.l	(sp)+,a0
	cmp.b	#1,d2
	beq.s	.Flt
.Ent	move.l	d3,(a0)
	rts
.Flt	tst.b	MathFlags(a5)
	bpl.s	.Ent
	move.l	d3,(a0)
	move.l	d4,4(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					VARIABLE EN FONCTION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnVar
; - - - - - - - - - - - - -
	move.w	(a6)+,d0
	bmi.s	.Glo
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
.Glo2	moveq	#0,d1
	move.b	(a6)+,d1
	move.b	(a6)+,d2
	add.w	d1,a6
	btst	#6,d2
	beq.s	.FnV1			* Tableau
	bsr	GetTablo
.FnV1	and.w	#$F,d2
	beq.s	.Ent
	cmp.b	#2,d2
	beq.s	.Str
; Float : simple ou double?
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	MathFlags(a5)
	bpl.s	.Ent
	move.l	(a0)+,d3
	move.l	(a0),d4
	rts
; Si variable globale
; ~~~~~~~~~~~~~~~~~~~
.Glo	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra.s	.Glo2
; Ramene la valeur ENTIERE / FLOAT simple
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Ent	move.l	(a0),d3
	rts
; Ramene la valeur CHAINE
; ~~~~~~~~~~~~~~~~~~~~~~~
.Str	move.l	(a0),d3
	beq.s	.Vide
	rts
.Vide	move.l	ChVide(a5),d3		Initialise la variable
	move.w	#$0402,-2(a0)		Le flag
	move.l	d3,(a0)			La variable
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Trouve l'adresse d'une variable > A0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FindVar
; - - - - - - - - - - - - -
	addq.l	#2,a6
	move.w	(a6)+,d0
	bmi.s	.Glo
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
.Glo2	moveq	#0,d1
	move.b	(a6)+,d1
	move.b	(a6)+,d2
	add.w	d1,a6
	btst	#6,d2
	beq.s	.FdV0
	bsr	GetTablo			Tableau: pas de flag
	and.w	#$0F,d2				Isole le flag
	cmp.b	#2,d2
	beq.s	.Str
	rts
; Si variable globale
.Glo	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra.s	.Glo2
; Si pas tableau
.FdV0	move.b	#4,-2(a0)			Met la longueur
	move.b	d2,-1(a0)			Variable simple: met le flag
;	and.w	#$F,d2				???
	beq.s	.Fin
	cmp.b	#1,d2
	beq.s	.Flt
.Str	tst.l	(a0)				Une chaine, initialisee?
	bne.s	.Fin
	move.l	ChVide(a5),(a0)
	rts
.Flt	tst.b	MathFlags(a5)			Un float simple ou double?
	bpl.s	.Fin
	move.b	#8,-2(a0)
.Fin	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						DIM
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InDim
InDim
; - - - - - - - - - - - - - - - -
	addq.l	#2,a6
	move.w	(a6)+,d0
	bmi	DimGlo
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
Dim0	moveq	#0,d1
	move.b	(a6)+,d1
	move.b	(a6)+,d2
	add.w	d1,a6
	tst.l	(a0)		Already dimensionned
	bne	AlrDim
	moveq	#2,d1		Taille variable (nombre de LSL)
	and.w	#$F,d2
	cmp.b	#1,d2
	bne.s	.Skip
	tst.b	MathFlags(a5)
	bpl.s	.Skip
	moveq	#3,d1		Variable double
.Skip	move.w	d2,-(sp)	Nombre de dims
	move.l	a0,-(sp)	Adresse du tableau
	move.w	d1,-(sp)	Taille variable
* Recupere et compte les params
	clr.w	-(sp)
	move.w	#1,-(sp)
Dim1:	bsr	Fn_New_Evalue
	tst.b	d2
	beq.s	Dim2
	move.w	d0,-(sp)
	Rjsrt	L_FlToInt1
	move.w	(sp)+,d0
Dim2:	cmp.l	#$FFFF,d3
	bcc	FonCall
	move.w	d3,-(a3)
	addq.w	#1,d3
	addq.w	#1,2(sp)
	mulu	(sp),d3
	cmp.w	#_TkPar2,d0
	beq.s	Dim3
	cmp.l	#$10000,d3
	bcc	FonCall
	move.w	d3,(sp)
	cmp.w	#_TkVir,(a6)
	beq.s	Dim1
	bra	Synt
Dim3:	addq.l	#2,sp
	move.w	(sp)+,d2		Nb de dimensions
	move.l	d3,d0
	move.w	(sp)+,d4		Taille variable
	lsl.l	d4,d3
	move.l	d3,d5
	lsr.l	#2,d5			Nombre de mots long a nettoyer
	move.l	TabBas(a5),a0		Descend le bas tableaux
	move.l	a0,a2			Pour le nettoyage
	sub.l	d3,a0
	move.w	d2,d0			Taille du header
	lsl.w	#2,d0
	addq.l	#2,d0
	sub.w	d0,a0
	cmp.l	HiChaine(a5),a0
	bcc	DimM1
	movem.l	a0-a1/d0-d1,-(sp)
	Rbsr	L_Menage
	movem.l	(sp)+,a0-a1/d0-d1
	cmp.l	HiChaine(a5),a0
	bcs	OOfBuf
DimM1	move.l	(sp),a1			Stocke l'adresse du tableau
	move.l	a0,(a1)
	move.l	a0,TabBas(a5)
	move.b	d2,(a0)			Stocke le nb de dim
	move.b	d4,1(a0)		Nombre de LSL
	lea	0(a0,d0.w),a0
	move.l	a0,a1			Pointe le premier element
	moveq	#1,d1
	subq.w	#1,d2
Dim4:	move.w	d1,-(a0)		Stocke taille et multiplicateur
	move.w	(a3)+,d0
	move.w	d0,-(a0)
	addq.w	#1,d0
	mulu	d0,d1
	dbra	d2,Dim4
; Poke le flag du tableau
	move.l	(sp)+,a0		Adresse du pointeur
	move.w	(sp)+,d2		Flag
	move.w	d2,d0
	or.w	#$0440,d0		4 octets / Tableau
	move.w	d0,-2(a0)
; Nettoyage
	moveq	#0,d0
	cmp.w	#2,d2
	bne.s	.Clean
	move.l	ChVide(a5),d0
.Clean	move.l	d0,(a1)+
	subq.l	#1,d5
	bne.s	.Clean
; Une autre variable
	cmp.w	#_TkVir,(a6)+
	beq	InDim
; Fin du dim!
	subq.l	#2,a6
	rts
; Si variable globale
DimGlo	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra	Dim0


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						TROUVE ELEMENT DE TABLEAU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	GetTablo
GetTablo
; - - - - - - - - - - - - - - - -
	movem.l	d2/d3/d4,-(sp)
	move.l	(a0),d0
	beq	NonDim
	move.l	d0,a0
	moveq	#0,d0
	move.b	(a0)+,d0	Nombre de dims
	move.w	d0,-(sp)
	move.b	(a0)+,d0	Taille variables
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	clr.l	-(sp)
GetT1:	bsr	Fn_New_Evalue
	subq.w	#1,10(sp)
	beq.s	GetT3
	tst.b	d2
	beq.s	GetT2
	Rjsrt	L_FlToInt1
GetT2:	move.l	4(sp),a0
	moveq	#0,d0
	move.w	(a0)+,d0
	cmp.l	d0,d3
	bhi	FonCall
	mulu	(a0)+,d3
	add.l	d3,(sp)
	move.l	a0,4(sp)
	bra.s	GetT1
GetT3:	tst.b	d2
	beq.s	GetT4
	Rjsrt	L_FlToInt1
GetT4:	move.l	(sp)+,d2
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(a0)+,d0
	cmp.l	d0,d3
	bhi	FonCall
	add.l	d3,d2
	move.w	(sp)+,d0		Taille variable
	lsl.l	d0,d2
	addq.l	#2,sp
	lea	2(a0,d2.l),a0
	movem.l	(sp)+,d2/d3/d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						VARPTR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnVarPtr
; - - - - - - - - - - - - -
	addq.l	#2,a6
	bsr	FindVar
	addq.l	#2,a6
	cmp.b	#2,d2
	beq.s	.Str
.Ent	move.l	a0,d3
	Ret_Int
.Str	move.l	(a0),d3
	addq.l	#2,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					=ARRAY$(a$(0))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnArray
; - - - - - - - - - - - - -
	addq.l	#4,a6
	move.w	(a6)+,d0
	bmi.s	.Glo
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
.Glo2	moveq	#0,d1
	move.b	(a6)+,d1
	move.b	(a6)+,d2
	add.w	d1,a6
	move.l	(a0),d0
	beq	NonDim
; Saute les params
	move.l	d0,-(sp)
	move.l	d0,a0
	moveq	#0,d0
	move.b	(a0),d0
	bsr	Saut_D0Param
	move.l	(sp)+,d3
; Retour valeur
	Ret_Int
; Si variable globale
.Glo	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra.s	.Glo2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					PREND UNE CONSTANTE ENTIERE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnCEntier
; - - - - - - - - - - - - -
	move.l	(a6)+,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					PREND UN FLOAT SIMPLE PRECISION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnCstFl
; - - - - - - - - - - - - -
	tst.b	MathFlags(a5)
	bmi.s	.DFlt
	move.l	(a6)+,d3
	Ret_Float
.DFlt	move.l	(a6)+,d0
	Rjsr	L_FFP2Ieee
	Rjsr	L_Sp2Dp
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					PREND UN FLOAT DOUBLE PRECISION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnCstDFl
; - - - - - - - - - - - - -
	tst.b	MathFlags(a5)
	bpl.s	.SFlt
	move.l	(a6)+,d3
	move.l	(a6)+,d4
	Ret_Float
.SFlt	move.l	(a6)+,d0
	move.l	(a6)+,d1
	Rjsr	L_Dp2Sp
	Rjsr	L_Ieee2FFP
	move.l	d0,d3
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					PREND UNE CHAINE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnCstCh
; - - - - - - - - - - - - -
	move.l	a6,d3
	move.w	(a6)+,d0
	add.w	d0,a6
	btst	#0,d0
	beq.s	.CstC0
	addq.l	#1,a6
.CstC0:	tst.w	Direct(a5)
	bne.s	.CstC1
	Ret_String
; Mode direct: recopier la chaine
.CstC1:	move.l	d3,a2
	moveq	#0,d3
	move.w	(a2)+,d3
	bsr	Demande
	move.w	d3,(a0)+
	addq.w	#1,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	bmi.s	.CstC3
.CstC2:	move.w	(a2)+,(a0)+
	dbra	d3,.CstC2
.CstC3:	move.l	a1,d3
	move.l	a0,HiChaine(a5)
	Ret_String


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						SHARED / GLOBAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InShared
; - - - - - - - - - - - - - - - -
Sha0	move.b	4(a6),d0
	ext.w	d0
	lea	6(a6,d0.w),a6
	cmp.w	#_TkPar1,(a6)
	bne.s	Sha1
	addq.l	#4,a6
Sha1:	cmp.w	#_TkVir,(a6)+
	beq.s	Sha0
	subq.l	#2,a6
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						DEF FN / =FN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InDFn
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	move.l	a6,(a0)
	move.l	d7,a6
	subq.l	#4,a6
	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	lea	-2(a6,d0.w),a6			Branche a la fin de la ligne
	rts
; - - - - - - - - - - - - - - - -
	Lib_Par FnFn
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	move.l	(a0),d0
	beq	FnNDef
	move.l	d0,a2
; Egalise les params
	move.w	(a6),d0
	cmp.w	#_TkPar1,d0
	bne.s	FFn5
	addq.l	#2,a6
FFn1	cmp.w	(a2)+,d0
	bne	FnIlNb
	move.l	a2,-(sp)
	bsr	New_Evalue
	movem.l	d2/d3/d4/a6,-(sp)
	move.l	4*4(sp),a6
	bsr	FindVar
	move.w	d2,d1
	move.l	a6,a2
	movem.l	(sp)+,d2/d3/d4/a6
	addq.l	#4,sp
	cmp.b	d1,d2
	beq.s	FFn3
	cmp.b	#1,d1
	bhi	TypeMis
	bne.s	FFn2
	move.l	a0,-(sp)
	Rjsrt	L_IntToFl1
	move.l	(sp)+,a0
	bra.s	FFn3
FFn2	cmp.b	#1,d2
	bhi	TypeMis
	move.l	a0,-(sp)
	Rjsrt	L_FlToInt1
	move.l	(sp)+,a0
FFn3	cmp.b	#1,d1
	bne.s	.Ent
	tst.b	MathFlags(a5)
	bpl.s	.Ent
	move.l	d4,4(a0)
.Ent	move.l	d3,(a0)
	move.w	(a6)+,d0
	cmp.w	#_TkVir,d0
	beq.s	FFn1
	subq.l	#2,a6
	cmp.w	#_TkPar2,(a2)+
	bne.s	FnIlNb
FFn5	cmp.w	#_TkEg,(a2)+
	bne.s	FnIlNb
; Appelle la fonction
; ~~~~~~~~~~~~~~~~~~~
	movem.l	a3-a6,-(sp)
	move.l	a2,a6
	bsr	New_Evalue
	movem.l	(sp)+,a3-a6
	rts
FnIlNb	moveq	#16,d0
	bra	RunErr
FnNDef	moveq	#15,d0
	bra	RunErr

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						SWAP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InSwap
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	move.l	a0,-(sp)
	addq.l	#2,a6
	bsr	FindVar
	move.l	(sp)+,a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	cmp.b	#1,d2
	bne.s	.Fin
	tst.b	MathFlags(a5)
	bpl.s	.Fin
	move.l	4(a0),d0
	move.l	4(a1),4(a0)
	move.l	d0,4(a1)
.Fin	rts
; - - - - - - - - - - - - -
	Lib_Def	InSwapD
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						NOT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnNot
; - - - - - - - - - - - - - - - -
	bsr	New_Evalue
	tst.b	d2
	beq.s	.Skip
	Rjsrt	L_FlToInt1
.Skip	not.l	d3
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						MAX / MIN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnMax
; - - - - - - - - - - - - - - - -
	bsr	MinMax
	ble.s	FMx2
FMx1	movem.l	4(a3),d3/d4
FMx2	lea	12(a3),a3
	rts
; - - - - - - - - - - - - -
	Lib_Def	FnMaxS
; - - - - - - - - - - - - -
; - - - - - - - - - - - - - - - -
	Lib_Par FnMin
; - - - - - - - - - - - - - - - -
	bsr	MinMax
	ble.s	FMx1
	bra.s	FMx2
; Routine min max
; ~~~~~~~~~~~~~~~
MinMax	bsr	Fn_New_Evalue
	movem.l	d2/d3/d4,-(a3)
	bsr	Fn_New_Evalue
	bsr	Compat
	bmi.s	MMx1
	bne.s	MMx2
	movem.l	d2-d4,-(sp)		* Float
	Rjsrt	L_Float_Compare
	movem.l	(sp)+,d2-d4
	rts
MMx1	move.l	4(a3),d4
	cmp.l	d3,d4			* Int
	rts
MMx2	movem.l	d2-d4,-(sp)		* Chaine
	bsr	compch
	move.l	d3,d0
	move.l	d4,d1
	movem.l	(sp)+,d2-d4
	cmp.l	d3,d4
	rts
; - - - - - - - - - - - - -
	Lib_Def	FnMinS
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						INC + DEC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InInc
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	addq.l	#1,(a0)
	rts
; - - - - - - - - - - - - - - - -
	Lib_Par InDec
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	subq.l	#1,(a0)
	rts
; - - - - - - - - - - - - - - - -
	Lib_Par InAdd2
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	move.l	a0,-(sp)
	bsr	Fn_New_Evalue
	move.l	(sp)+,a0
	add.l	d3,(a0)
	rts
; - - - - - - - - - - - - - - - -
	Lib_Par InAdd4
; - - - - - - - - - - - - - - - -
	bsr	FindVar
	move.l	a0,-(sp)
	moveq	#3,d0
	bsr	FnParD0
	move.l	(sp)+,a0
	move.l	(a0),d0
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	add.l	(a3)+,d0
	cmp.l	d1,d0
	blt.s	IAdd4m
	cmp.l	d2,d0
	bgt.s	IAdd4p
	move.l	d0,(a0)
	rts
IAdd4m:	move.l	d2,(a0)
	rts
IAdd4p:	move.l	d1,(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						SORT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InSort
; - - - - - - - - - - - - - - - -
	bsr 	GTablo       	;va chercher les caracteristiques du tableau
        move.l 	d6,d3
or4:    lsr.l 	#1,d3         	;E=d3
        beq 	XSort
	moveq 	#1,d5         	;NA=d5
or5:    move.l 	d5,d4        	;NR=d4 -> NR=NA
or6:    movem.l	d3-d6/a1,-(sp)
        move.l 	a1,a0
        subq.l 	#1,d4
	move.l	d4,d0
	move.l	d3,d1
	bsr	AdSort
	movem.l	a0/a1/d2,-(sp)
	move.l	4(a0),-(a3)
	move.l	(a0),-(a3)
	subq.l	#4,a3
	movem.l	(a1),d3-d4
	bsr	CpBis
	lea	12(a3),a3
	movem.l	(sp)+,a0/a1/d2
  	ble.s	or8
; fait le swap
        move.l 	(a0),d0
        move.l 	(a1),(a0)
        move.l 	d0,(a1)
	cmp.b	#3,d7
	bne.s	.Skip
	move.l	4(a0),d0
	move.l	4(a1),4(a0)
	move.l	d0,4(a1)
.Skip	movem.l (sp)+,d3-d6/a1
        sub.l 	d3,d4         	;NR=NR-E
        beq.s 	or9
        bcc.s 	or6
        bra.s 	or9
or8:    movem.l (sp)+,d3-d6/a1
or9:    addq.l 	#1,d5        	;NA=NA+1
        move.l 	d6,d0
        sub.l 	d3,d0
        cmp.l 	d0,d5
        bls.s 	or5
        bra.s 	or4
XSort	Rjsr	L_LoadRegs
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						=MATCH
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnMatch
; - - - - - - - - - - - - - - - -
	addq.l	#2,a6
	bsr	GTablo
        movem.l a1/d2/d6/d7,-(sp)
	bsr	Fn_New_Evalue
        movem.l (sp)+,a1/d5/d6/d7
* Etabli la compatibilite entre variables
        cmp.b 	d2,d5
        beq.s 	di3
        subq.w	#1,d5
	beq.s	di2
	bpl	TypeMis
        Rjsrt 	L_FlToInt1
        bra.s 	di3
di2:    Rjsrt 	L_IntToFl1
; recherche!
di3:    moveq	#0,d5
        move.l 	d6,d1
        lsr.l	#1,d6
di4:    movem.l a1/d1-d7,-(sp)
        add.l 	d6,d5
	move.l	d5,d1
	move.l	a1,a0
	moveq	#0,d0
	bsr	AdSort
	move.l	4(a1),-(a3)
	move.l	(a1),-(a3)
	subq.l	#4,a3
	bsr	CpBis
	lea	12(a3),a3
	movem.l	(sp)+,a1/d1-d7
        beq.s 	di11
        bgt.s	di5
	add.l 	d6,d5
di5:    tst.l 	d6
        beq.s 	di7
        lsr.l 	#1,d6
        bra.s 	di4
; pas trouve: cherche le premier element superieur
di7:    cmp.l 	d1,d5
        bcc.s 	di8
        movem.l a1/d1-d7,-(sp)
	move.l	d5,d1
	move.l	a1,a0
	moveq	#0,d0
	bsr	AdSort
	move.l	4(a1),-(a3)
	move.l	(a1),-(a3)
	subq.l	#4,a3
	bsr	CpBis
	lea	12(a3),a3
        movem.l (sp)+,a1/d1-d7
        beq.s 	di11
        bgt.s 	di8
        addq.l 	#1,d5
        bra.s 	di7
di8:    move.l 	d5,d3
        addq.l 	#1,d3
        neg.l 	d3
	bra.s	di12
; trouve!
di11:   move.l 	d5,d3
        add.l 	d6,d3
; Sortie
di12	Rjsr	L_LoadRegs
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Trouve les parametres tableau pour SORT et FIND
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	GTablo
; - - - - - - - - - - - - -
GTablo	Rjsr	L_SaveRegs
	addq.l	#2,a6
	move.w	(a6)+,d0
	bmi.s	GTbG
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
GTb0	move.b	(a6)+,d1
	move.b	(a6)+,d2
	ext.w	d1
	add.w	d1,a6
	move.l	(a0),d0
	beq	NonDim
	move.l	d0,a1
	moveq	#0,d0
	move.b	(a1)+,d0		Nombre de dims
	move.b	(a1)+,d7		Taille des variables
	move.w	d0,d1
	moveq	#1,d6
GTb1:	move.w	(a1)+,d3
	addq.l	#2,a1
	addq.w	#1,d3
	mulu	d3,d6
	subq.w	#1,d1
	bne.s	GTb1
	and.w	#$F,d2
* Saute les params
	movem.l	a1/a3/d2/d6/d7,-(sp)
	bsr	FnParD0
	movem.l	(sp)+,a1/a3/d2/d6/d7
	rts
; Si variable globale
GTbG	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra.s	GTb0

* Trouve l'adresse D0/D1 >>> A0/A1
; - - - - - - - - - - - - -
	Lib_Def	AdSort
AdSort
; - - - - - - - - - - - - -
	lsl.l	d7,d0
	add.l	d0,a0
	move.l	a0,a1
	lsl.l	d7,d1
	add.l	d1,a1
	rts
* Comparaison pour SORT/FIND
; - - - - - - - - - - - - -
	Lib_Def	CpBis
CpBis
; - - - - - - - - - - - - -
	cmp.b	#1,d2
	beq.s	.Flt
	bcs.s	.Ent
	bsr 	compch
	cmp.l	d3,d4
	rts
.Ent	move.l	4(a3),d4
	cmp.l 	d3,d4
	rts
.Flt	Rjmpt	L_Float_Compare


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						Instruction DATA
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InData
; - - - - - - - - - - - - - - - -
	move.w	(a6),d0			Passe a la fin de la ligne
	sub.w	d0,a6
	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	lea	-2(a6,d0.w),a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						Instruction READ
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRead
; - - - - - - - - - - - - - - - -
* Va chercher la variable
LRead	bsr	FindVar
* Va chercher le data
	move.l	a0,-(sp)
	move.w	d2,-(sp)
	move.l	a6,-(sp)
	move.l	AData(a5),d0
	beq.s	NxD0
	move.l	d0,a6
	bra.s	NxD3
NxD0:	move.l	PData(a5),d0
	beq	OOf
	move.l	d0,a6
NxD1:	tst.w	(a6)
	beq	OOf
	lea	2(a6),a0
	move.w	(a0),d0
	cmp.w	#_TkEndP,d0
	beq	OOf
	cmp.w	#_TkProc,d0
	beq.s	NxD6
	cmp.w	#_TkData,d0		* DATA direct
	beq.s	NxD2
	cmp.w	#_TkLab,d0		* LABEL: DATA
	bne.s	NxD5
	move.b	6(a6),d0
	ext.w	d0
	lea	8(a6,d0.w),a0
	cmp.w	#_TkData,(a0)
	beq.s	NxD2
NxD5:	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	lea	0(a6,d0.w),a6
	bra.s	NxD1
NxD6:	move.l	2(a0),d0
	lea	10(a0,d0.l),a6
	bra.s	NxD1
NxD2:	moveq	#0,d0
	move.b	(a6),d0
	lsl.w	#1,d0
	lea	0(a6,d0.w),a6
	move.l	a6,PData(a5)
	lea	4(a0),a6
* Virgule---> SPECIAL!
NxD3:	move.w	(a6),d0
	beq.s	InRdV
	cmp.w	#_TkVir,d0
	bne.s	InRd0
InRdV:	moveq	#0,d3
	moveq	#0,d2
	move.w	4(sp),d5
	subq.w	#2,d5
	bmi.s	InRd1
	move.l	ChVide(a5),d3
	moveq	#2,d2
	bra.s	InRd1
* Evaluation normale
InRd0:	bsr	New_Evalue
* Pointe la fin du data
InRd1:	tst.w	(a6)+
	bne.s	InRd2
	sub.l	a6,a6
InRd2:	move.l	a6,AData(a5)
* Egalise
	move.l	(sp)+,a6
	move.w	(sp)+,d1
	move.l	(sp)+,a2
	cmp.b	d2,d1
	beq.s	InRd5
	cmp.b	#2,d1
	beq	RTypeM
	cmp.b	#2,d2
	beq	RTypeM
	tst.b	d1
	beq.s	InRd4
	Rjsrt	L_IntToFl1
	bra.s	InRd5
InRd4	Rjsrt	L_FlToInt1
InRd5	cmp.b	#1,d2			Float?
	bne.s	InRd6
	tst.b	MathFlags(a5)		Double precision?
	bpl.s	InRd6
	move.l	d4,4(a2)
InRd6	move.l	d3,(a2)
* Encore une variable?
	cmp.w	#_TkVir,(a6)+
	beq	LRead
	subq.l	#2,a6
	rts
OOf	clr.l	PData(a5)
	bra	OOfData
RTypeM:	moveq	#34,d0
	bra	RunErr

; - - - - - - - - - - - - -
	Lib_Def	InReadF
	Lib_Def	InReadS
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						Instruction RESTORE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRestore
; - - - - - - - - - - - - - - - -
	bsr	Finie
	bne.s	InRs1
* Sans label
	move.l	DProc(a5),PData(a5)
	clr.l	AData(a5)
	rts
* Avec label
InRs1:	bsr	GetLabel
	beq	LbNDef
	move.l	d0,a0
	cmp.w	#_TkData,(a0)+
	bne.s	InRs2
	move.w	(a0),d0
	sub.w	d0,a0
	move.l	a0,PData(a5)
	clr.l	AData(a5)
	rts
InRs2	moveq	#41,d0
	bra	RunErr
; - - - - - - - - - - - - -
	Lib_Def	InRestore1
; - - - - - - - - - - - - -


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source:	Diskio.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FIELD n,AA as A$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InField
; - - - - - - - - - - - - -
	bsr	New_Expentier
	move.l	d3,d0
	Rjsr	L_GetFile
	beq	FilNO
	move.l	a3,-(sp)
	move.l	a2,-(sp)
	clr.w	-(sp)
* Recupere les variables
Fld1	addq.l	#2,a6
	bsr	New_Expentier
	move.l	d3,-(a3)
	addq.l	#2,a6
	bsr	FindVar
	move.l	a0,-(a3)
	addq.w	#1,(sp)
	cmp.w	#_TkVir,(a6)
	beq.s	Fld1
* Reserve la memoire necessaire
	move.w	(sp),d0
	mulu	#6,d0
	addq.l	#8,d0
	SyCall	MemFastClear
	beq	OOfMem
	move.w	(sp)+,d1
	move.l	(sp)+,a2
	move.l	a0,FhF(a2)
	move.l	a0,a1
	lea	8(a1),a0
	move.w	d1,(a1)
	subq.w	#1,d1
	moveq	#0,d2
	move.l	(sp),a3
Fld2	move.l	-(a3),d0
	beq	FldFonc
	add.l	d0,d2
	cmp.l	#String_Max,d2
	bcc	FldFonc
	move.w	d0,(a0)+
	move.l	-(a3),(a0)+
	dbra	d1,Fld2
	move.w	d2,2(a1)
* Taille du fichier
	move.l	(sp)+,a3
	move.l	a1,-(sp)
	move.l	FhA(a2),d1
	moveq	#0,d2
	moveq	#1,d3
	DosCall	_LVOSeek
	move.l	FhA(a2),d1
	moveq	#0,d2
	moveq	#-1,d3
	DosCall	_LVOSeek
	move.l	(sp)+,a1
	move.l	d0,4(a1)
	rts
* FonCall field!
FldFonc	Rjsr	L_Cloa1
	bra	FonCall
FilNO	moveq	#DEBase+18,d0
	bra	RunErr


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					INPUT #
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InLineInputH
; - - - - - - - - - - - - -
	clr.w	-(sp)
	bra.s	DInp0
; - - - - - - - - - - - - -
	Lib_Par InInputH
; - - - - - - - - - - - - -
	move.w	#",",-(sp)
DInp0	bsr	New_Expentier
	addq.l	#2,a6
	move.l	d3,d0
	Rjsr	L_GetFile
	beq	FilNO
	move.l	a2,PrintFile(a5)
	clr.l	DeFloat(a5)
	Rjsr	L_SaveRegs
	bra	ReInp
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					INPUT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InInput
; - - - - - - - - - - - - -
	move.w	#",",-(sp)
	bra.s	IInp0
; - - - - - - - - - - - - -
	Lib_Par InLineInput
; - - - - - - - - - - - - -
	clr.w	-(sp)
IInp0:	Rjsr	L_SaveRegs
	clr.l	DeFloat(a5)
	clr.l	PrintFile(a5)
	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	Buffer(a5),a0
	clr.b	(a0)
	moveq	#1,d7
* Chaine a imprimer?
	cmp.w	#_TkVar,(a6)
	beq.s	IInp1
	bsr	New_Evalue
	move.l	d3,a2
	move.w	(a2)+,d2
	addq.l	#2,a6
	moveq	#0,d7
	tst.w	d2
	beq.s	IInp1
	move.b	0(a2,d2.w),d6
	clr.b	0(a2,d2.w)
	move.l	a2,a1
	WiCall	Print
	move.b	d6,0(a2,d2.w)
* Imprime le ?
IInp1:	tst.w	d7
	beq.s	ReInp
	WiCalA	Print,InnInt(pc)
	clr.l	DeFloat(a5)

;	 Rempli le buffer!
; ~~~~~~~~~~~~~~~~~~~~~~~~
ReInp:	tst.l	PrintFile(a5)
	bne.s	ReDInp
* Clavier
	lea	Es_LEd(a5),a0
	move.l	Buffer(a5),a1
	clr.b	(a1)
	move.l	a1,a2
	move.w	#(1<<LEd_FCursor)|(1<<LEd_FTests)|(1<<LEd_FMulti),d0
	moveq	#0,d1			Curseur � zero
	move.w	#256,d2			256 caracteres maxi
	moveq	#-1,d3			Largeur maxi
	move.l	a3,-(sp)
	Rjsr	L_LEd_Init
	bne	FonCall			Trop � droite...
	Rjsr	L_LEd_Loop
	move.l	(sp)+,a3
	move.l	d0,d3
	tst.w	d2
	bmi	IStop
	bra	InnPut
* Fichier!
ReDInp	move.l	PrintFile(a5),a2
	move.l	Buffer(a5),a1
	clr.b	(a1)
	moveq	#0,d1
	move.w	(sp),d2
	move.b	ChrInp+1(a5),d3
	move.b	ChrInp(a5),d4
	bra.s	InpD1
InpD0	move.b	d0,(a1)+
	addq.w	#1,d1
	cmp.w	#1000,d1
	bcc	InpTL
InpD1	Rjsr	L_GetByte
	cmp.b	d0,d2			* Stop aux virgules
	beq.s	InpD2
	cmp.b	d0,d3			* Premier caractere?
	bne.s	InpD0
 	tst.b	d4			* Sauter le deuxieme?
	bmi.s	InpD2
	Rjsr	L_GetByte
InpD2	clr.b	(a1)
	move.l	a1,d3
	sub.l	Buffer(a5),d3		* Nombre de caracteres -> D3

******* INPUT/LINE INPUT: interprete le buffer!
InnPut	move.l	Buffer(a5),a2
Inn1:	move.l	a2,-(sp)
	bsr	FindVar
	move.l	(sp)+,a2
	movem.l	a0/d2,-(sp)
	cmp.b	#2,d2
	bne.s	Inn5
* Variable alphanumerique
	move.l	ChVide(a5),(a0)		* Libere la memoire!
	bsr	DDemande
	addq.l	#2,a0
	move.b	8+1(sp),d1
Inn2:	move.b	(a2)+,d0
	move.b	d0,(a0)+
	beq.s	Inn3
	cmp.b	d0,d1
	bne.s	Inn2
Inn3:	subq.l	#1,a0
	subq.l	#1,a2
	move.l	a0,d0
	sub.l	a1,d0
	subq.l	#2,d0
	move.w	d0,(a1)
	btst	#0,d0
	beq.s	Inn4
	addq.l	#1,a0
Inn4:	move.l	a0,HiChaine(a5)
	movem.l	(sp)+,a0/d2
	move.l	a1,(a0)
	bra.s	Inn10
* Variable numerique
Inn5:	move.l	a2,a0
	moveq	#1,d0			Tenir compte du signe
	Rjsr	L_ValRout
	move.l	a0,a2
	movem.l	(sp)+,a1/d1
	move.b	(a2),d0
	beq.s	Inn6
	cmp.b	1(sp),d0
	bne	InnRedo
Inn6:	cmp.b	d1,d2
	beq.s	Inn8
	tst.b	d1
	beq.s	Inn7
	move.l	a1,-(sp)
	Rjsrt	L_IntToFl1
	move.l	(sp)+,a1
	bra.s	Inn8
Inn7:	move.l	a1,-(sp)
	Rjsrt	L_FlToInt1
	move.l	(sp)+,a1
Inn8:	move.l	d3,(a1)			Poke la variable
	cmp.b	#1,d2			Float?
	bne.s	Inn10
	tst.b	MathFlags(a5)		Double?
	bpl.s	Inn10
	move.l	d4,4(a1)		Poke la 2eme partie
* Encore une variable a prendre???
Inn10:	cmp.w	#_TkVir,(a6)+
	bne.s	Inn11
	cmp.b	#",",(a2)+
	beq	Inn1
* ??
	tst.l	PrintFile(a5)
	bne	ReInp
	WiCalA	Print,InnEnc(pc)
	move.l	Buffer(a5),a0
	clr.b	(a0)
	bra	ReInp
* Fini!
Inn11:	subq.l	#2,a6
	addq.l	#2,sp
	Rjsr	L_EndByte
	tst.l	PrintFile(a5)
	bne.s	InnFin
	cmp.w	#_TkPVir,(a6)+
	beq.s	InnFin
	subq.l	#2,a6
	WiCalA	Print,InnRet(pc)
	bra.s	InnFin
* Redo from start
InnRedo	Rjsr	L_EndByte
	tst.l	PrintFile(a5)
	bne	TypeMis
	WiCalA	Print,InnRet(pc)
	moveq	#15,d0
	Rjsr	L_Def_GetMessage
	move.l	a0,a1
	WiCall	Print
	WiCalA	Print,InnRet(pc)
	Rjsr	L_LoadRegs
	move.l	d7,a6
	bra	IInp0
* Fini!
InnFin	Rjsr	L_LoadRegs
	rts
InnRet:	dc.b 	13,10,0
InnInt:	dc.b	"? ",0
InnEnc:	dc.b	13,10,"?? ",0
	even
; - - - - - - - - - - - - -
	Lib_Def	Input
	Lib_Def	CRet
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PRINT #n,"kjfdjkf";
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPrintH
; - - - - - - - - - - - - -
	bsr	New_Expentier
	addq.l	#2,a6
	move.l	d3,d0
	Rjsr	L_GetFile
	tst.l	FhA(a2)
	beq	FilNO
	btst	#0,FhT(a2)
	beq	FilTM
	cmp.w	#1,d0
	beq	FilTM
	move.l	a2,PrintFile(a5)
	clr.w	ImpFlg(a5)
	bra.s	Print0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					LPRINT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InLPrint
; - - - - - - - - - - - - -
 	clr.l	PrintFile(a5)
	move 	#1,ImpFlg(a5)
        bra.s 	Print0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PRINT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPrint
; - - - - - - - - - - - - -
  	clr 	ImpFlg(a5)
	clr.l	PrintFile(a5)
* Entree commune
Print0	Rjsr	L_SaveRegs
	move.l 	PrintPos(a5),d0
        beq.s 	Print1
	move.l	d0,a6
        bclr 	#7,PrintFlg(a5)
* Boucle
Print1	clr 	PrintFlg(a5)
Prunt2	bsr 	ssprint
        beq 	FinPrint
        tst.w 	d7
        beq.s 	Prunt2
	move.l	PrintFile(a5),d0
	bne.s	Print4
* A l'ecran / Imprimante
	move.l	Buffer(a5),a0
	Rjsr	L_ImpChaine
	bra.s	Prunt2
* Impression dans un fichier
Print4	move.l	d0,a0
	move.l	FhA(a0),d1
Print5	move.l	Buffer(a5),d2
	move.l	d3,-(sp)
	moveq	#0,d3
	move.w	d7,d3
	DosCall	_LVOWrite
	move.l	d3,d1
	move.l	(sp)+,d3
	cmp.l	d0,d1
	beq.s	Prunt2
	Rjmp	L_DiskError
* Fin du print
FinPrint:
	Rjsr	L_LoadRegs
	clr.l 	PrintPos(a5)
        clr.l 	PrintFile(a5)
	rts

; ROUTINE DE PRINT: REMPLI LE BUFFER, REVIENT D7=LONGUEUR A IMPRIMER!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ssprint	btst 	#7,PrintFlg(a5)    impression de chaine en route!
        bne 	sp2a
        btst 	#6,PrintFlg(a5)    fini?
        bne 	sp17
 	move.l 	Buffer(a5),a0
        cmp.w 	#_TkUsing,(a6)	Using?
	beq.s 	sp20
	bsr 	Finie		Print termine?
	beq 	sp11
	bra.s 	spa
; USING "+ - #### . ^^^^ ~~~~": debut, STOCKE LA CHAINE
sp20:   bsr	Fn_New_Evalue
	move.l	d3,a2
	move.w	(a2)+,d2
        cmp 	#120,d2         	pas plus de 200 caracteres
        bcc 	FonCall
        move.l 	Buffer(a5),a0
	lea 	256(a0),a0
        Rjsr 	L_ChVerBuf2       	copie la chaine dans le buffer
        move 	#1,UsingFlg(a5)
	addq.l 	#2,a6		Saute le ;
	bra.s 	spb
* Prend le param
spa:    clr 	UsingFlg(a5)
spb:    bsr	New_Evalue
	move.l 	d7,d0
	bne.s 	spb0
	move.l 	MenA4(a5),d7
spb0:   move.l 	Buffer(a5),a0
        subq.b 	#1,d2
        bmi.s 	sp1
        bne.s 	sp2
; IMPRESSION D'UN CHIFFRE FLOAT
        RjsrtR 	L_Float2Ascii,1        	;va ecrire dans le buffer
        bra 	using1
; IMPRESSION D'UN CHIFFRE ENTIER
sp1:	move.l 	d3,d0
	moveq	#-1,d3         		;proportionnel
        moveq 	#1,d4         		;avec signe
        Rjsr 	L_LongToAsc
        bra 	using1
; IMPRESSION D'UNE CHAINE -debut-
sp2:    move.l 	d3,a2
        move.w 	(a2)+,d3
        bne.s 	sp3
        bra 	using50
; IMPRESSION D'UNE CHAINE -milieu-
sp2a:   move.l 	Buffer(a5),a0
sp3:    moveq 	#120,d0
sp4:    move.b 	(a2)+,(a0)+  	;imprime par salves de 120 caracteres,
        subq 	#1,d3
        beq.s 	sp5
        dbra 	d0,sp4
        bset 	#7,PrintFlg(a5)    ;on a pas fini d'imprimer la chaine!
        bra.s 	sp11
sp5:    bclr 	#7,PrintFlg(a5)    ;on a fini!
        bra 	using50
; fin du sspgm/retour du USING
sp11:   clr 	UsingFlg(a5)        ;une seule expression par USING
        btst 	#7,PrintFlg(a5)    ;pas fini: ne fait rien!
        bne.s 	sp15
        move.w 	(a6),d0
        cmp.w 	#_TkVir,d0
        beq.s 	sp12
        cmp.b 	#_TkPVir,d0     ;point virgule: ne fait rien!
        beq.s 	sp13
        bra.s 	sp14
sp12:   move.b 	#9,(a0)+         	;TAB
sp13:   addq.l	#2,a6
        bsr 	Finie
	beq.s 	sp14a
        bne.s 	sp15
sp14:   move.b 	#13,(a0)+        	;met le RETURN
        move.b 	#10,(a0)+
sp14a:  bset 	#6,PrintFlg(a5)    	;flag: c'est fini apres!
sp15:   clr.b 	(a0)
        sub.l 	Buffer(a5),a0
        move.l 	a0,d7            	;taille du buffer
        btst 	#7,PrintFlg(a5)
        bne.s 	sp16
        move.l 	a6,PrintPos(a5)  	;position du CHRGET PRINT
sp16:   moveq 	#1,d0             	;retour: quelque chose a imprimer!
        rts
sp17: 	moveq 	#0,d0
        rts

; USING pour les CHIFFRES
using1: tst 	UsingFlg(a5)        Si pas using: revient imprimer
        beq 	sp11
        clr.b 	(a0)          	Stoppe la chaine
        move.l 	Buffer(a5),a1
        lea 	128(a1),a2
        moveq 	#127,d0
us2:    move.b 	(a1),(a2)+   	recopie la chaine, et fait le menage!!!
        move.b 	#32,(a1)+
        dbra 	d0,us2
        move.l 	Buffer(a5),a0
        lea 	128(a0),a1      	a1 pointe la chaine
        move.l 	a1,d6        	debut chaine a formatter
	move.l 	Buffer(a5),a2
	lea 	256(a2),a2		a2 pointe la chaine de definition
        move.l 	a2,d7        	debut chaine de format
us3:    move.b 	(a2),d0
        beq.s 	us5
        cmp.b 	#".",d0       	cherche la fin du format de chiffre
        beq.s 	us5
        cmp.b 	#";",d0
        beq.s 	us5
        cmp.b 	#"^",d0
        beq.s 	us5
        addq.l 	#1,a0
        addq.l 	#1,a2
        bra.s 	us3
us5:    move.b 	(a1),d0
        beq.s 	us6
        cmp.b 	#".",d0       	trouve le point de la chaine a formatter
        beq.s 	us6             	ou la fin
        cmp.b 	#"E",d0
        beq.s 	us6
        addq.l 	#1,a1
        bra.s 	us5
us6:    movem.l	a0-a3,-(sp)
; ecris la gauche du chiffre
us7:    cmp.l 	d7,a2         	fini a gauche???
        beq 	us15
        move.b 	-(a2),d0
        cmp.b 	#"#",d0
        beq.s 	us8
        cmp.b 	#"-",d0
        beq.s 	us11
        cmp.b 	#"+",d0
        beq.s 	us12
        move.b 	d0,-(a0)     	aucun signe reserve: le met simplement!
        bra.s 	us7
us8:    cmp.l 	d6,a1         	-----> "#"
        bne.s 	us10
us9:    move.b 	#" ",-(a0)   	arrive au debut du chiffre!
        bra.s 	us7
us10:   move.b 	-(a1),d0
        cmp.b 	#"0",d0       	pas un chiffre (signe)
        bcs.s 	us9
        cmp.b 	#"9",d0
        bhi.s 	us9
        move.b 	d0,-(a0)     	OK, chiffre: poke!
        bra.s 	us7
us11:   move.l 	d6,a3        	-----> "-"
        move.b 	(a3),-(a0)   	met le "signe": 32 ou "-"
        bra.s 	us7
us12:   move.l 	d6,a3
        move.b 	(a3),d0
        cmp.b 	#"-",d0
        beq.s 	us13
        move.b 	#"+",d0
us13:   move.b 	d0,-(a0)     	-----> "+"
        bra 	us7
; ecrit la droite du chiffre
us15:   movem.l (sp)+,a0-a3 	recupere les adresses pivot
        clr.l 	d2            	flag puissance
        cmp.b 	#".",(a1)     	saute le point dans le chiffre a afficher
        bne.s 	us16
        addq.l 	#1,a1
us16:   move.b 	(a2)+,d0
        beq 	sp11        	fini OUF!
        cmp.b 	#";",d0       	";" marque la virgule sans l'ecrire!
        beq.s 	us18z
        cmp.b 	#"#",d0
        beq.s 	us17
        cmp.b 	#"^",d0
        beq.s 	us20
        move.b 	d0,(a0)+     	ne correspond a rien: POKE!
        bra.s 	us16
us17:   move.b 	(a1),d0      	-----> "#"
        bne.s 	us19
us18:   tst 	d2
        beq.s 	us18a
us18z:  move.b 	#" ",(a0)+   	si puissance passee: met des espaces
        bra.s 	us16
us18a:  move.b 	#"0",(a0)+   	Fin du chiffre: met un zero apres la virgule
        bra.s 	us16
us19:   cmp.b 	#"0",d0
        bcs.s 	us18
        cmp.b 	#"9",d0
        bhi.s 	us18
        addq.l 	#1,a1
        move.b 	d0,(a0)+
        bra 	us16
us20:   tst 	d2              	-----> "^"
        bmi.s 	us24
        bne.s 	us25
us21:   move.b 	(a1),d0
        beq.s 	us22
        cmp.b 	#"E",d0
        beq.s 	us23
        addq.l 	#1,a1
        bra.s 	us21
us22:   move 	#1,d2          	pas de puissance: en fabrique une!
        bra.s 	us25
us23:   move 	#-1,d2
us24:   move.b 	(a1),d0      	si fin du chiffre: met des espaces
        beq 	us18
        addq.l 	#1,a1
        cmp.b 	#32,d0        	saute l'espace entre E et +/-
        beq.s 	us24
        move.b 	d0,(a0)+
        bra 	us16
us25:   move.l	a3,-(sp)
	lea 	UsPuiss(pc),a3
        move.b 	-1(a3,d2.w),(a0)+ 	met une fausse puissance!
	move.l	(sp)+,a3
        cmp.b 	#6,d2
        beq 	us16
        addq 	#1,d2
        bra 	us16

; PRINT USING POUR DES CHAINES +++facile
using50:tst 	UsingFlg(a5)	si pas using, va imprimer
        beq 	sp11
	move.l 	a2,-(sp)
        clr.b 	(a0)        	stoppe la chaine
        move.l 	Buffer(a5),a0
        lea 	128(a0),a1
        moveq 	#127,d0
us51:   move.b 	(a0)+,(a1)+  	recopie la chaine, et fait le menage!!!
        dbra 	d0,us51
        move.l 	Buffer(a5),a0
        lea 	128(a0),a1      	a1 pointe la chaine
        lea 	128(a1),a2		a2 pointe la chaine de definition
; ecris la chaine dans le buffer
us52:   move.b 	(a2)+,d0
        beq.s 	us55        	fini!
        cmp.b 	#"~",d0
        beq.s 	us53
        move.b 	d0,(a0)+
        bra.s 	us52
us53:   move.b 	(a1),d0      	----> "~"
        bne.s 	us54
        move.b 	#32,(a0)+
        bra.s 	us52
us54:   addq.l 	#1,a1
        move.b 	d0,(a0)+
        bra.s 	us52
us55:	move.l	(sp)+,a2
	bra 	sp11
UsPuiss dc.b "E+000  "
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Pour le compilateur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	PrintE
	Lib_Def	PrintF
	Lib_Def	PrintS
	Lib_Def	PrintX
	Lib_Def	LPrintX
	Lib_Def	CRPrint
	Lib_Def	HPrintS
	Lib_Def	PrtRet
	Lib_Def	PrtVir
	Lib_Def	HPrintX
	Lib_Def	UsingC
	Lib_Def	UsingS
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: Ecrans.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					DEFAULT PALETTE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InDefaultPalette
; - - - - - - - - - - - - -
	lea	DefPal(a5),a0
	bsr	Plt
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PALETTE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPalette
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	beq	ScNOp
	moveq	#15,d0
	move.l	Buffer(a5),a0
	move.l	a0,a1
Pal1:	move.l	#-1,(a1)+
	dbra	d0,Pal1
	bsr	Plt
	EcCall	SPal
	bne	EcWiErr
	rts

* Routine palette
; - - - - - - - - - - - - -
	Lib_Def	Plt
; - - - - - - - - - - - - -
Plt:	move.l	a0,-(sp)
	bsr	New_Evalue
	subq.b	#1,d2
	bmi.s	Plt1
	Rjsrt	L_IntToFl1
Plt1:	move.l	(sp)+,a0
	tst.l	d3
	bmi.s	Plt2
	and.w	#$FFF,d3
	move.w	d3,(a0)
Plt2:	addq.l	#2,a0
	move.w	(a6)+,d0
	cmp.w	#_TkVir,d0
	beq.s	Plt
	subq.l	#2,a6
	move.l	Buffer(a5),a1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FADE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	InFade1
	Lib_Def	InFade2
	Lib_Def	InFade3
	Lib_Def	InFadePal
	Lib_Par InFade
; - - - - - - - - - - - - -
	bsr	New_Expentier
	move.l	d3,-(a3)
	move.w	(a6),d0
	cmp.w	#_TkTo,d0
	beq.s	IFaTo
	cmp.w	#_TkVir,d0
	beq.s	IFaPal
* FADE n
	move.l	Buffer(a5),a0
	move.l	a0,a1
	moveq	#31,d0
IFad0	clr.w	(a0)+
	dbra	d0,IFad0
	bra.s	IFadT
* FADE TO
IFaTo	bsr	Fn_New_Expentier
	tst.l	d3
	bpl.s	IFat1
	Rjsr	L_Bnk.GetBobs		<0 -->> sprite palette
	beq	BkNoRes
	move.w	(a0)+,d0
	lsl.w	#3,d0
	lea	0(a0,d0.w),a0
	bra.s	IFat2
IFat1	move.l	d3,d1			* Dans un ecran
	Rjsr	L_GetEc
	lea	EcPal(a0),a0
IFat2	moveq	#-1,d3
	cmp.w	#_TkVir,(a6)
	bne.s	IFat3
	move.l	a0,-(sp)
	bsr	Fn_New_Expentier
	move.l	(sp)+,a0
IFat3	Rjsr	L_PalRout
	bra.s	IFadT
* FADE palette
IFaPal	moveq	#15,d0
	move.l	Buffer(a5),a0
	move.l	a0,a1
IFap	move.l	#-1,(a1)+
	dbra	d0,IFap
	addq.l	#2,a6
	bsr	Plt
* Appelle!
IFadT	tst.w	ScOn(a5)
	beq	ScNOp
	move.l	(a3)+,d1
	bls	FonCall
	EcCall	FadeOn
	bne	FonCall
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					POLYLINE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPolyline
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	beq	ScNOp
	clr.w	-(sp)
	move.l	T_RastPort(a5),a1
	move.l	Buffer(a5),a2
	cmp.w	#_TkTo,(a6)
	bne.s	PLi1
	move.w	36(a1),d0
	move.w	38(a1),d1
	bra.s	PLi2
PLi1:	movem.l	a1/a2,-(sp)
	bsr	New_Expentier
	move.l	d3,-(a3)
	bsr	Fn_New_Expentier
	movem.l	(sp)+,a1/a2
	move.l	d3,d1
	move.l	(a3)+,d0
PLi2:	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq.w	#1,(sp)
	cmp.w	#_TkTo,(a6)+
	beq.s	PLi1
	subq.l	#2,a6
	move.w	(sp)+,d0
	cmp.w	#1,d0
	bls	FonCall
	move.l	Buffer(a5),a0
	move.w	(a0),36(a1)
	move.w	2(a0),38(a1)
	move.w	#PolyDraw,d5
	Rjsr	L_GfxFunc
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					POLYGON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InPolygon
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	beq	ScNOp

; Initialise le buffer AREADRAW
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	AAreaInfo(a5),a0
	lea	AAreaBuf(a5),a1
	moveq	#AAreaSize,d0
	move.l	T_RastPort(a5),a2
	move.l	a0,16(a2)
	GfxCa5	InitArea

	move.l	T_RastPort(a5),a1
	move.l	Buffer(a5),a2
	cmp.w	#_TkTo,(a6)
	bne.s	PGi0
	addq.l	#2,a6
	move.w	36(a1),d0
	move.w	38(a1),d1
	bra.s	PGi1
PGi0:	move.l	a1,-(sp)
	bsr	New_Expentier
	move.l	d3,-(a3)
	bsr	Fn_New_Expentier
	move.l	(sp)+,a1
	addq.l	#2,a6
	move.l	d3,d1
	move.l	(a3)+,d0
PGi1:	GfxCa5	AreaMove
PGi2:	move.l	a1,-(sp)
	bsr	New_Expentier
	move.l	d3,-(a3)
	bsr	Fn_New_Expentier
	move.l	(sp)+,a1
	move.l	d3,d1
	move.l	(a3)+,d0
	GfxCa5	AreaDraw
	cmp.w	#_TkTo,(a6)+
	beq.s	PGi2
	subq.l	#2,a6
FinRas	Rjsr	L_GetRas
	GfxCa5	AreaEnd
	Rjsr	L_FreeRas
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source:	Sprite.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					CHANNEL x TO SPRITE x
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	ChannelToSprite
	Lib_Def	ChannelToBob
	Lib_Def	ChannelToSDisplay
	Lib_Def	ChannelToSSize
	Lib_Def	ChannelToSOffset
	Lib_Def	ChannelToRainbow
; - - - - - - - - - - - - -
	Lib_Par InChannel
; - - - - - - - - - - - - -
	bsr	New_Expentier
	cmp.l	#64,d3
	bcc	FonCall
	addq.l	#2,a6
	move.w	(a6)+,d0
	moveq	#0,d4			* 0-> Sprites
	moveq	#64,d5
	cmp.w	#_TkSpr,d0
	beq.s	ChaX
	addq.w	#1,d4			* 1-> Bobs
	moveq	#64,d5
	cmp.w	#_TkBob,d0
	beq.s	ChaX
	addq.w	#1,d4			* 2-> Screen display
	moveq	#8,d5
	cmp.w	#_TkScD,d0
	beq.s	ChaX
	addq.w	#1,d4			* 3-> Screen size
	cmp.w	#_TkScS,d0
	beq.s	ChaX
	addq.w	#1,d4			* 4-> Screen offset
	cmp.w	#_TkScO,d0
	beq.s	ChaX
	addq.w	#2,d4			* 6-> Rainbow
	moveq	#4,d5
ChaX:	movem.l	d3-d5,-(sp)
	bsr	New_Expentier
	move.l	d3,d2
	movem.l	(sp)+,d3-d5
	cmp.l	d5,d2
	bcc	FonCall
	lsl.w	#1,d3
	lea	AnCanaux(a5),a0
	move.b	d4,0(a0,d3.w)		* 1 => TYPE
	move.b	d2,1(a0,d3.w)		* 2 => NUMERO
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: memory.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					BSET / BTST / BCHG / BCLR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InBset
; - - - - - - - - - - - - -
IBset:	bsr	BsRout
	bmi.s	IBs1
	move.l	(a0),d1
	bset	d0,d1
	move.l	d1,(a0)
	rts
IBs1:	bset	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InBset1
; - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Par InBclr
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	IBc1
	move.l	(a0),d1
	bclr	d0,d1
	move.l	d1,(a0)
	rts
IBc1:	bclr	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InBclr1
; - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Par InBchg
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	IBh1
	move.l	(a0),d1
	bchg	d0,d1
	move.l	d1,(a0)
	rts
IBh1:	bchg	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InBchg1
; - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Par FnBtst
; - - - - - - - - - - - - -
	addq.w	#2,a6
	bsr	BsRout
	bmi.s	IBt1
	move.l	(a0),d1
	btst	d0,d1
	bne.s	IbtT
	bra.s	IbtF
IBt1:	btst	d0,(a0)
	bne.s	IbtT
IbtF:	moveq	#0,d3
	Ret_Int
IbtT:	moveq	#-1,d3
	Ret_Int
; - - - - - - - - - - - - -
	Lib_Def	FnBtst1
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ROR ROL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRorB
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	Brr1
	move.b	3(a0),d1
	ror.b	d0,d1
	move.b	d1,3(a0)
	rts
Brr1:	move.b	(a0),d1
	ror.b	d0,d1
	move.b	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InRorB1
; - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Par InRorW
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	Wrr1
	move.w	2(a0),d1
	ror.w	d0,d1
	move.w	d1,2(a0)
	rts
Wrr1:	move.w	(a0),d1
	ror.w	d0,d1
	move.w	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InRorW1
; - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Par InRorL
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	Lrr1
	move.l	(a0),d1
	ror.l	d0,d1
	move.l	d1,(a0)
	rts
Lrr1:	move.l	(a0),d1
	ror.l	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InRorL1
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InRolB
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	Brl1
	move.b	3(a0),d1
	rol.b	d0,d1
	move.b	d1,3(a0)
	rts
Brl1:	move.b	(a0),d1
	rol.b	d0,d1
	move.b	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InRolB1
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InRolW
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	Wrl1
	move.w	2(a0),d1
	rol.w	d0,d1
	move.w	d1,2(a0)
	rts
Wrl1:	move.w	(a0),d1
	rol.w	d0,d1
	move.w	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InRolW1
; - - - - - - - - - - - - -

; - - - - - - - - - - - - -
	Lib_Par InRolL
; - - - - - - - - - - - - -
	bsr	BsRout
	bmi.s	Lrl1
	move.l	(a0),d1
	rol.l	d0,d1
	move.l	d1,(a0)
	rts
Lrl1:	move.l	(a0),d1
	rol.l	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InRolL1
; - - - - - - - - - - - - -

******* Routine: ramene l'adresse a affecter!
BsRout	bsr	New_Expentier
	tst.l	d3
	bmi	FonCall
	addq.w	#2,a6
	cmp.w	#_TkVar,(a6)
	beq.s	BsR1
* Une adresse
	bset	#31,d3
	move.l	d3,-(a3)
	bsr	New_Expentier
	move.l	d3,a0
	move.l	(a3)+,d0
	rts
* Une variable
BsR1	move.l	a6,-(sp)
	move.l	d3,-(a3)
	bsr	FindVar
	cmp.w	#_TkPar2,(a6)+
	beq.s	BsR2
	subq.l	#2,a6
	bsr	Finie
	bne.s	BsR3
BsR2	addq.l	#4,sp
	move.l	(a3)+,d0
	rts
* He non! Une adresse!
BsR3	move.l	(sp)+,a6
	bsr	New_Expentier
	move.l	d3,a0
	move.l	(a3)+,d0
	moveq	#-1,d1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					CALL PROCEDURE LANGAGE MACHINE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par In_apml_
; - - - - - - - - - - - - -
; Des parametres � empiler?
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	(a6)+,d0
	beq.s	.PaPar
	moveq	#0,d1
	lea	-2+2(a6,d0.w),a2
.PaL	move.w	(a2)+,d0
	bmi.s	.Glo
	move.l	VarLoc(a5),a0
	lea	2(a0,d0.w),a0
.Glo2	move.l	(a0),-(a3)
	move.b	(a2)+,d1
	lea	1(a2,d1.w),a2
	cmp.w	#_TkVir,(a2)+
	addq.l	#2,a2
	beq.s	.PaL
; Appelle la routine
; ~~~~~~~~~~~~~~~~~~
.PaPar	movem.l	a3-a6/d6-d7,-(sp)
	lea	CallReg(a5),a4
	move.l	a4,-(sp)
	movem.l	(a4),d0-d7/a0-a2
	jsr	(a6)
.Return	move.l	(sp)+,a4
	movem.l	d0-d7/a0-a2,(a4)
	movem.l	(sp)+,a3-a6/d6-d7
	move.l	d0,ParamE(a5)
	bra	PopP
; Si variable globale
.Glo	move.l	VarGlo(a5),a0
	neg.w	d0
	lea	1(a0,d0.w),a0
	bra.s	.Glo2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					CALL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InCall
; - - - - - - - - - - - - -
	bsr	New_Expentier
	move.l	d3,d0
	Rjsr	L_Bnk.OrAdr
	move.l	a0,-(sp)
; Evalue les params!
.Loop	cmp.w	#_TkVir,(a6)
	bne.s	.Call
	addq.l	#2,a6
	bsr	New_Expentier
	move.l	d3,-(a3)
	bra.s	.Loop
; Appel
.Call	move.l	(sp)+,a0
	movem.l	d6-d7/a3-a6,-(sp)
	move.l	a0,a4
	lea	CallReg(a5),a6
	move.l	a6,-(sp)
	movem.l	(a6),d0-d7/a0-a2
	jsr	(a4)
.Return	move.l	(sp)+,a6
	movem.l	d0-d7/a0-a2,(a6)
	movem.l	(sp)+,d6-d7/a3-a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=LVO =EQU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnEqu
; - - - - - - - - - - - - -
	move.l	(a6),d3
	moveq	#0,d2
	move.w	6+2+2(a6),d0
	move.w	d0,d1
	and.w	#1,d1
	add.w	d1,d0
	lea	6+2+4+2(a6,d0.w),a6
	Ret_Int


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=STRUC=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InStruc
; - - - - - - - - - - - - -
	bsr	GStruc
	movem.l	a0/d0/d1,-(sp)
	addq.l	#2,a6
	bsr	New_Expentier
	movem.l	(sp)+,a0/d0/d1
	lsl.w	#1,d0
	jmp	.Jmp(pc,d0.w)
.Jmp	bra.s	.Byte
	bra.s	.Word
	bra.s	.Long
	bra.s	.Byte
	bra.s	.Word
	bra.s	.Long
	bra.s	.Long
.Byte	move.b	d0,(a0)
	rts
.Word	btst	#0,d1
	bne	AdrErr
	move.w	d3,(a0)
	rts
.Long	btst	#0,d1
	bne	AdrErr
	move.l	d3,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Par FnStruc
; - - - - - - - - - - - - -
	bsr	GStruc
	moveq	#0,d3
	lsl.w	#1,d0
	jmp	.Jmp(pc,d0.w)
.Jmp	bra.s	.Byte
	bra.s	.Word
	bra.s	.Long
	bra.s	.UByte
	bra.s	.UWord
	bra.s	.ULong
	bra.s	.ULong
.Byte	move.b	(a0),d3
	ext.w	d3
	ext.l	d3
	Ret_Int
.Word	btst	#0,d1
	bne	AdrErr
	move.w	(a0),d3
	ext.l	d3
	Ret_Int
.Long	btst	#0,d1
	bne	AdrErr
	move.l	(a0),d3
	Ret_Int
.UByte	move.b	(a0),d3
	Ret_Int
.UWord	btst	#0,d1
	bne	AdrErr
	move.w	(a0),d3
	Ret_Int
.ULong	btst	#0,d1
	bne	AdrErr
	move.l	(a0),d3
	Ret_Int
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=STRUC$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InStrucD
; - - - - - - - - - - - - -
	bsr	GStruc
	btst	#0,d1
	bne	AdrErr
	clr.l	(a0)
	move.l	a0,-(sp)
	bsr	Fn_New_Evalue
	move.l	d3,a2
	move.w	(a2)+,d2
	cmp.l	#"|00|",(a2)
	beq.s	.Skp
	moveq	#2,d3
	add.w	d2,d3
	bsr	Demande
	lea	2(a0,d3.w),a0
	move.w	a0,d0
	and.w	#1,d0
	add.w	d0,a0
	move.l	a0,HiChaine(a5)
	move.l	(sp)+,a0
	move.l	a1,(a0)
	move.w	d2,(a1)
	addq.w	#1,(a1)+
	subq.w	#1,d2
	bmi.s	.Skp
.Lop	move.b	(a2)+,(a1)+
	dbra	d2,.Lop
	clr.b	(a1)
.Skp	rts
; - - - - - - - - - - - - -
	Lib_Par FnStrucD
; - - - - - - - - - - - - -
	bsr	GStruc
	btst	#0,d1
	bne	AdrErr
	move.l	(a0),d0
	beq.s	.Vide
	move.l	d0,a0
	Rjsr	L_A0ToChaine
	move.l	a0,d3
	Ret_String
.Vide	Rjmp	L_Ret_ChVide
; Routine de saisie des parametres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GStruc	move.l	(a6)+,-(sp)	Equate
	move.w	(a6)+,-(sp)	Type
	addq.l	#2,a6		Saute (
	bsr	New_Expentier	Adresse de base
	move.w	2+2(a6),d0	Saute la chaine et la )
	move.w	d0,d1
	and.w	#1,d1
	add.w	d1,d0
	lea	2+4+2(a6,d0.w),a6
	move.w	(sp)+,d0
	lsr.w	#8,d0
	move.l	d3,d1
	add.l	(sp)+,d1
	move.l	d1,a0		Adresse resultante
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: String.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 				Demande de l'espace pour les chaines
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Demande
Demande
; - - - - - - - - - - - - -
	move.l 	HiChaine(a5),a0
        move.l 	a0,a1
	add.l	d3,a1
	addq.l	#4,a1
	cmp.l	TabBas(a5),a1
	bcc.s	dem1
	move.l	a0,a1
        rts
; Va faire le menage
dem1	tst.b	ErrorRegs(a5)		Recharger les registres?
	beq.s	.NoReg
	movem.l	ErrorSave(a5),d6-d7
.NoReg	Rbsr	L_Menage		Va faire le menage
; Ca marche maintenant?
	move.l	HiChaine(a5),a1		Ca marche maintenant?
	add.l	d3,a1
	addq.l	#4,a1
	cmp.l	TabBas(a5),a1
	bcc	FinMenE
; Ca a marche, un patch?
	tst.l	Patch_Menage(a5)
	bne.s	dem3
	move.l	d7,d0			Ou en est-ton?
	bmi.s	Demande			Menage simple: ca va revenir!
	beq.s	FinMenE			Deux fois sur la meme instruction
; Rebranche au debut de l'instruction
	move.l	PLoop(a5),a3
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.l	d7,a6
	move.l	d7,MenA4(a5)
	moveq	#0,d7			Signal pour nouveau menage
	movem.l	d6-d7,ErrorSave(a5)	Au cas zou!
	IFNE	Debug
	movem.l	d6/d7,Chr_Debug+4(a5)
	ENDC
	move.w	-2(a6),d0
	move.w	0(a4,d0.w),d1		Pointe la table de tokens
	move.l	-LB_Size(a4,d1.w),a0
	jmp	(a0)			Rebranche
; Branche au patch
dem3	move.l	Patch_Menage(a5),a0
	jmp	(a0)
; Erreur: out of string space!
FinMenE	move.l	d7,d0			A4>0
	bgt	OOfBuf
	move.l	MenA4(a5),d7		Non, charge l'instruction
	bra	OOfBuf

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Demande chaine sans erreur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	DDemande
DDemande
; - - - - - - - - - - - - -
	move.l	d7,MenA4(a5)
	moveq	#-1,d7
	movem.l	d6-d7,ErrorSave(a5)
	IFNE	Debug
	movem.l	d6/d7,Chr_Debug+4(a5)
	ENDC
	bsr	Demande
	move.l	MenA4(a5),d7
	movem.l	d6-d7,ErrorSave(a5)
	IFNE	Debug
	movem.l	d6/d7,Chr_Debug+4(a5)
	ENDC
	rts




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MENAGE ALPHANUMERIQUE
;	Taille maximum chaine: 65472 ($FFC0)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Menage
; - - - - - - - - - - - - -
	movem.l d1-d7/a2-a6,-(sp)

	IFNE	Debug>1
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#70,d3
	JJsrIns	L_InBell1,1
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC
	IFNE	Debug>1
	Rjsr	L_PreBug
	ENDC

******* Essaie de proceder � un FAST-MENAGE!
	move.l	HiChaine(a5),d7
	move.l	LoChaine(a5),d6
	move.l	d7,d0
	sub.l	d6,d0
	cmp.l	#$3FFFFE*2,d0			8 Megas maximum!
	bcc	SLOW_MENAGE
	move.l	d0,d5
	SyCall	MemFast
	beq	SLOW_MENAGE

*********************************************************************
FAST_MENAGE
	move.l	a0,a4
	move.l	a0,a2
	clr.w	(a2)+
FfMen0  move.l 	VarLoc(a5),a6			;Debut des variables
        moveq 	#-1,d2                    	;Maxi dans le tableau
; Rempli la table intermediaire
FfMen1	moveq	#0,d4
.Loop	move.w	(a6)+,d0			Prend le flag
	beq.s	.Loop				Nul: non initialise!
	bmi.s	.Proc				Negatif: fin de chunk
.Var	btst	#1,d0				Une chaine?
	bne.s	.Alpha
	lsr.w	#8,d0				Recupere la taille
	add.w	d0,a6
	move.w	(a6)+,d0			Suivante
	beq.s	.Loop
	bpl.s	.Var
.Proc	move.l	(a6),d0				Chunk suivant
	beq	FfMenX				Le dernier?
	move.l	d0,a6				Non, on boucle!
	bra.s	.Loop
; Variable alphanumerique
.Alpha	move.l	a6,a3
	move.l	(a6)+,d1
	beq.s	.Loop				Non initialise!
	btst 	#6,d0				Un tableau?
	beq.s 	FfMen4
	move.l	d1,a3				Un tableau!
	moveq	#0,d0
	move.b	(a3)+,d0			Nombre de dimensions
	addq.l	#1,a3				Taille des variables
	subq.w 	#1,d0
	moveq 	#1,d4
FfMen2	move.w 	(a3)+,d1			Calcule nombre de variable
	addq.l	#2,a3
	addq.w	#1,d1
	mulu	d1,d4
	dbra 	d0,FfMen2
	subq.l	#1,d4
; Recopie la chaine dans le buffer intermediaire
FfMen4	move.l	(a3),a0
	cmp.l	d6,a0				Dans le buffer?
	bcs.s	FfMenN
	cmp.l	d7,a0
	bcc.s	FfMenN
	move.w	(a0),d0				Chaine vide?
	beq.s	FfMenV
	move.w	d0,d1
	and.w	#$FFC0,d1			Chaine deja copiee?
	cmp.w	#$FFC0,d1
	beq.s	FfMenD				Deja fait!
	move.l	a2,d2
	sub.l	a4,d2
	move.l	d2,d1
	add.l	d6,d1
	move.l	d1,(a3)+			Change le pointeur
	move.w	d0,(a2)+
	addq.w	#1,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	lea	2(a0),a1
FfMen5	move.w	(a1)+,(a2)+
	dbra	d0,FfMen5
	lsr.l	#1,d2				/ 2 car pair
	or.l	#$FFC00000,d2			Masque
	move.l	d2,(a0)				Marque la chaine...
FfSuiv	subq.l	#1,d4
        bpl.s 	FfMen4
        bmi	FfMen1
; Chaine deja copiee
FfMenD	move.l	(a0),d0
	and.l	#$003FFFFF,d0
	lsl.l	#1,d0
	add.l	d6,d0
	move.l	d0,(a3)+
	bra.s	FfSuiv
; Chaine vide
FfMenV	move.l	ChVide(a5),(a3)+
	bra.s	FfSuiv
; Chaine en dehors du buffer
FfMenN	addq.l	#4,a3
	bra.s	FfSuiv
; Recopie le tout dans le buffer
FfMenX	move.l	a4,a0
	move.l	d6,a1
FfMenX1	move.w	(a0)+,(a1)+
	cmp.l	a2,a0
	bcs.s	FfMenX1
	move.l	a1,HiChaine(a5)
; Libere le buffer temporaire
	move.l	a4,a1
	move.l	d5,d0
	SyCall	MemFree
	bra	FinMenS
*********************************************************************
SLOW_MENAGE
* Reserve la memoire, ou prend le BUFFER si rien du tout!!!
	move.l	#TMenage+16,d0
	SyCall	MemFast
	bne.s	L47a
	move.l	#-1,BMenage(a5)
	move.l	Buffer(a5),d5
	bra.s	L47b
L47a	move.l	a0,BMenage(a5)
	move.l	a0,d5
* Menage
L47b   	move.l 	d5,d6
	add.l 	#TMenage,d6                  	;Fin TI
	move.l 	LoChaine(a5),d7               	;Ad mini de recopie
	move.l	HiChaine(a5),a4			;Ad maxi des chaines!
	addq.l 	#2,d7		  		;Chaine vide
	move.l 	d7,a1		  		;Si ya pas de variable!

Men0:  	move.l 	VarLoc(a5),a6			;Debut des variables
        moveq 	#-1,d2                    	;Maxi dans le tableau
        moveq 	#0,d4                     	;Cpt tableau---> 0
        move.l 	d5,d3                    	;Rien dans la TI
        move.l 	d3,a0
        move.l 	#$7fffffff,(a0)
; Rempli la table intermediaire
Men1
.Loop	move.w	(a6)+,d0			Prend le flag
	beq.s	.Loop				Nul: non initialise!
	bmi.s	.Proc				Negatif: fin de chunk
.Var	btst	#1,d0				Une chaine?
	bne.s	.Alpha
	lsr.w	#8,d0				Recupere la taille
	add.w	d0,a6
	move.w	(a6)+,d0			Suivante
	beq.s	.Loop
	bpl.s	.Var
.Proc	move.l	(a6),d0				Chunk suivant
	beq	Men20				Le dernier?
	move.l	d0,a6				Non, on boucle!
	bra.s	.Loop
; Variable alphanumerique
.Alpha	move.l	a6,a3
	move.l	(a6)+,d1			Initialise?
	beq.s	Men1
	btst 	#6,d0
	beq.s 	Men4
	move.l	d1,a3
	moveq	#0,d0
	move.b	(a3)+,d0
	addq.l	#1,a3
	subq.w 	#1,d0
	moveq 	#1,d4
Men2:	move.w 	(a3)+,d1			Calcule nombre de variable
	addq.l	#2,a3
	addq.w	#1,d1
	mulu	d1,d4
	dbra 	d0,Men2
Men3:	subq.l 	#1,d4
; Essai de poker dans la TI
Men4:   move.l 	(a3),d0
        cmp.l 	d7,d0                     	;< au minimum?
        bcs.s 	Men10
	cmp.l	a4,d0				;Dans le source?
	bcc.s	Men10
        cmp.l 	d2,d0                     	;>= au maximum?
        bcc.s 	Men10
        move.l 	d5,a0
Men6:   cmp.l 	(a0),d0
        lea 	8(a0),a0
        bcc.s 	Men6
        cmp.l 	d6,a0
        bne.s 	Men7
        move.l 	d0,d2                    	;C'est le dernier element!
        move.l 	d6,d3
        bra.s 	Men9
Men7:   move.l 	d3,a1                    	;Decale les adresses au dessus
        cmp.l 	d6,d3
        bcs.s 	Men7a
        lea 	-8(a1),a1
        move.l 	-8(a1),d2                	;Remonte la limite haute
        bra.s 	Men8
Men7a:  addq.l 	#8,d3
        move.l 	#$7fffffff,8(a1)
Men8:   move.l 	-(a1),8(a1)
        move.l 	-(a1),8(a1)
        cmp.l 	a0,a1
        bcc.s 	Men8
Men9:   move.l 	a3,-(a0)                 	;Poke dans la table
        move.l 	d0,-(a0)
Men10:  addq.l	#4,a3
	tst.l 	d4
        bne.s 	Men3
        beq 	Men1

; Recopie toutes les chaines du buffer
Men20:  move.l 	d5,a3                    	;Adresse TI
        move.l 	d7,a1                    	;Adresse de recopie
        moveq 	#0,d7
Men21:  cmp.l 	d3,a3                     	;Fini-ni?
        bcc.s 	Men26
        move.l 	(a3),a0                  	;Adresse de la chaine
        lea 	8(a3),a3
        cmp.l 	a0,d7                    	;Chaine deja bougee?
        beq.s 	Men25
        move.l 	a0,d7
        cmp.l 	a0,a1                     	;Au meme endroit?
        bne.s 	Men22
; Les 2 chaines sont au meme endroit!
        move.l 	a1,d1
	moveq 	#0,d0
        move.w 	(a1)+,d0
	add.l 	d0,a1
        move.w 	a1,d0
        btst 	#0,d0
        beq.s 	Men21
        addq.l 	#1,a1
        bra.s 	Men21
; Recopie la chaine
Men22:  move.l 	-4(a3),a2                	;Change la variable
        move.l 	a1,(a2)
        move.l 	a1,d1
        move.w 	(a0)+,d0                 	;Recopie la chaine
        beq.s 	Men24
        move.w 	d0,(a1)+
        subq.w 	#1,d0
        lsr.w 	#1,d0
Men23:  move.w 	(a0)+,(a1)+
        dbra 	d0,Men23
        bra.s 	Men21
; Chaine vide au milieu: pointe la vraie
Men24:  move.l 	ChVide(a5),d1
        move.l 	d1,(a2)
        bra.s 	Men21
; La variable pointait la meme chaine que la precedente
Men25:  move.l 	-4(a3),a2
        move.l 	d1,(a2)
        bra.s 	Men21
; Est-ce completement fini?
Men26:  cmp.l 	d6,d3                     	;Buffer TI rempli?
        bcs.s 	FinMen                    	;NON---> c'est fini!

;-----> Reexplore les variables a la recherche de la DERNIERE CHAINE
        move.l 	VarLoc(a5),a6             	;Table des ad strings
        moveq 	#0,d4                     	;Cpt tableau---> 0
	move.l 	d1,d2		  		;Feneant!
; Rempli la table intermediaire
Men31:
.Loop	move.w	(a6)+,d0			Prend le flag
	beq.s	.Loop				Nul: non initialise!
	bmi.s	.Proc				Negatif: fin de chunk
.Var	btst	#1,d0				Une chaine?
	bne.s	.Alpha
	lsr.w	#8,d0				Recupere la taille
	add.w	d0,a6
	move.w	(a6)+,d0			Suivante
	beq.s	.Loop
	bpl.s	.Var
.Proc	move.l	(a6),d0				Chunk suivant
	beq	Men40				Le dernier?
	move.l	d0,a6				Non, on boucle!
	bra.s	.Loop
; Variable alphanumerique
.Alpha	move.l	a6,a3
	move.l	(a6)+,d1
	beq.s	Men31
	btst 	#6,d0
	beq.s 	Men34
	move.l	d1,a3
	moveq	#0,d0
	move.b	(a3)+,d0
	addq.l	#1,a3
	subq.w 	#1,d0
	moveq 	#1,d4
Men32:	move.w 	(a3)+,d1			;Calcule nombre de variable
	addq.l	#2,a3
	addq.w	#1,d1
	mulu	d1,d4
	dbra 	d0,Men32
Men33:	subq.l 	#1,d4
; La variable pointe elle la meme chaine?
Men34:  cmp.l 	(a3)+,d7
        beq.s 	Men36
        tst.l 	d4
        bne.s 	Men33
        beq.s 	Men31
Men36:  move.l 	d2,-4(a3)
        tst.l 	d4
        bne.s 	Men33
        beq.s 	Men31

;-----> Refait un tour!
Men40:  move.l 	a1,d7    	                ;Monte la limite <
        bra 	Men0
;-----> Menage fini!
FinMen	move.l 	a1,HiChaine(a5)
; Libere la m�moire
	move.l	BMenage(a5),d0
	bmi.s	Finm1
	move.l	d0,a1
	move.l	#TMenage+16,d0
	SyCall	MemFree
Finm1   clr.l	BMenage(a5)

;-----> FIN DES DEUX MENAGES
FinMenS movem.l (sp)+,d1-d7/a2-a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					LEFT$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InLeft
; - - - - - - - - - - - - -
	bsr 	RInMid
	movem.l a2/d2,-(sp)
	bsr 	Fn_New_Expentier
        move.l 	d3,d4
        moveq 	#0,d5
	bra 	RInMid2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Fonction LEFT$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnLeft
; - - - - - - - - - - - - -
	bsr	FEnt_2
        move.l 	d3,d4
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
        moveq 	#0,d5
	bra 	RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=RIGHT$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InRight
; - - - - - - - - - - - - -
	bsr 	RInMid
	movem.l a2/d2,-(sp)
	bsr 	Fn_New_Expentier
	move.l 	d3,d4
        bmi 	FonCall
	move.l 	(sp),d2
        moveq 	#0,d5
        cmp.l 	d2,d4
        bcc 	RInMid2
        move.l 	d2,d5
	sub.l 	d4,d5
        addq.l 	#1,d5
	bra 	RInMid2
; - - - - - - - - - - - - -
	Lib_Par FnRight
; - - - - - - - - - - - - -
	bsr	FEnt_2
        move.l 	d3,d5
        bmi 	FonCall
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
        move.l 	#$ffff,d4
        cmp.l 	d2,d5
        bcs 	L73c
        move.l 	d2,d5
L73c:   neg.l 	d5
        add.l 	d2,d5
        addq.l 	#1,d5
	bra 	RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					MID$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InMid2
; - - - - - - - - - - - - -
	bsr 	RInMid
	movem.l a2/d2,-(sp)
	bsr 	Fn_New_Expentier
	move.l 	d3,d5
*	addq.l 	#1,d5
        move.l 	#$FFFF,d4
	bra 	RInMid2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnMid2
; - - - - - - - - - - - - -
	bsr	FEnt_2
        move.l 	d3,d5
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
        move.l 	#$FFFF,d4
	bra 	RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=MID$() 3 params
; - - - - - - - - - - - - -
	Lib_Par InMid3
; - - - - - - - - - - - - -
	bsr 	RInMid
	movem.l a2/d2,-(sp)
	bsr	Fn_New_Expentier
	move.l	d3,-(sp)
	bsr	Fn_New_Expentier
	move.l	d3,d4
	move.l	(sp)+,d5
*	addq.l #1,d5
	bra	RInMid2
; - - - - - - - - - - - - -
	Lib_Par FnMid3
; - - - - - - - - - - - - -
	bsr	FEnt_3
        move.l 	d3,d4
        move.l 	(a3)+,d5
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
	bra	RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Commun LEFT MID RIGHT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	RFnMid
RFnMid
; - - - - - - - - - - - - -
        tst.l 	d5                        ;pointe au milieu de la chaine
        bmi 	FonCall
        beq.s 	mi2
        subq.l 	#1,d5
mi2:    add.l 	d5,a2
        cmp.l 	d2,d5                     ;pas pointe trop loin??
        bcc.s 	RVide                     ;si! chaine vide
mi3:    tst.l 	d4
        beq.s 	RVide
        bmi 	FonCall
mi4:    add.l 	d5,d4
        cmp.l 	d2,d4
        bls.s 	mi5
        move.l 	d2,d4
mi5:    sub.l 	d5,d4
mi6:    move.l 	d4,d3
	bsr 	Demande
        move 	d4,(a0)+                   ;poke la longueur
        subq.l 	#1,d4
        bmi.s 	mi8
mi7:    move.b 	(a2)+,(a0)+
        dbra 	d4,mi7
        move 	a0,d0                      ;rend pair
        btst 	#0,d0
        beq.s 	mi8
        addq.l 	#1,a0
mi8:    move.l 	a0,HiChaine(a5)
        move.l 	a1,d3
	Ret_String
RVide:  move.l 	ChVide(a5),d3          	;ramene la chaine vide
	Ret_String

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Commun MID LEFT RIGHT =
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	RInMid
RInMid
; - - - - - - - - - - - - -
	addq.w 	#2,a6		Saute la parenthese
	bsr 	FindVar
        move.l 	(a0),a2		Recopie la variable!
        moveq 	#0,d2
        move.w 	(a2)+,d2
	beq.s 	L77c
L77a:   move.l 	a0,-(sp)	Sauve l'adresse de la variable
	move.l 	d2,d3
	bsr 	Demande		Recopie la chaine dans le source
        move.w 	d2,(a1)+	Longueur
	move.w 	d2,d0
        subq.w 	#1,d0
        lsr.w 	#2,d0
L77b:   move.l 	(a2)+,(a1)+
        dbra 	d0,L77b
        move.l 	a1,HiChaine(a5)
	move.l 	(sp)+,a1
	move.l 	a0,(a1)		Change la variable
	lea 	2(a0),a2
L77c:   rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Commun LEFT MID RIGHT II
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	RInMid2
RInMid2
; - - - - - - - - - - - - -
	movem.l d4/d5,-(sp)
	bsr 	Fn_New_Expentier
	move.l	d3,a2
	moveq	#0,d2
	move.w	(a2)+,d2
	movem.l (sp)+,d4/d5
	movem.l (sp)+,a1/d1
        tst.l 	d5
        bmi 	FonCall
        beq.s 	mdst2
        subq.l 	#1,d5
mdst2:  add.l 	d5,a1             ;situe dans la chaine a changer
        cmp.l 	d1,d5
        bcc.s 	mdst10            ;trop loin: ne change rien
        tst.l 	d4
        bmi 	FonCall
        beq.s 	mdst10
        add.l 	d5,d4
        cmp.l 	d1,d4
        bls.s 	mdst3
        move.l 	d1,d4
mdst3:  sub.l 	d5,d4
        cmp.l 	d2,d4             ;limite par la taille de la chaine source
        bls.s 	mdst4
        move.l 	d2,d4
mdst4:  subq.l 	#1,d4            ;la chaine source est nulle!
        bmi.s 	mdst10
mdst5:  move.b 	(a2)+,(a1)+
        dbra 	d4,mdst5
mdst10:	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=VAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnVal
; - - - - - - - - - - - - -
	move.l	d3,a2
	move.w	(a2)+,d2
	beq.s	val11
        Rjsr 	L_ChVerBuf        	recopie la chaine dans le buffer
        move.l	Buffer(a5),a0
	moveq	#1,d0			Tenir compte du signe
        Rjsr 	L_ValRout
	rts
val11 	moveq	#0,d3
	Ret_Int


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 		=RESOURCE$(n)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par FnResource
; - - - - - - - - - - - - -
; Un message normal?
	move.l	d3,d0
	ble.s	.Skip1
	Rjsr	L_Dia_GetPuzzle
	move.l	a2,a0
	move.l	d3,d0
	Rjsr	L_GetMessage
	bra	.Fin
; Le path du systeme? (0)
.Skip1	neg.l	d0
	bne.s	.Skip2
	lea	Sys_Pathname(a5),a0
	bra.s	.Fin
; Un message systeme? (-1)
.Skip2	cmp.l	#1001,d0
	bcc.s	.Skip3
	move.l	Sys_Messages(a5),a0
	bra.s	.Fin0
; Un message systeme editeur? (-1000)
.Skip3	sub.l	#1000,d0
	cmp.l	#1001,d0
	bcc.s	.Skip4
	move.l	Ed_Systeme(a5),a0
	bra.s	.Fin0
; Un message de menu editeur? (-2000)
.Skip4	sub.l	#1000,d0
	cmp.l	#1001,d0
	bcc.s	.Skip5
	move.l	EdM_Messages(a5),a0
	bra.s	.Fin0
; Un message editeur? (-3000)
.Skip5	sub.l	#1000,d0
	cmp.l	#1001,d0
	bcc.s	.Skip6
	move.l	Ed_Messages(a5),a0
	bra.s	.Fin0
; Un message de test? (-4000)
.Skip6	sub.l	#1000,d0
	cmp.l	#1001,d0
	bcc.s	.Skip7
	move.l	Ed_TstMessages(a5),a0
	bra.s	.Fin0
; Un message run-time? (-5000)
.Skip7	sub.l	#1000,d0
	cmp.l	#1001,d0
	bcc	FonCall
	move.l	Ed_RunMessages(a5),a0
; Retourne la chaine
.Fin0	Rjsr	L_GetMessage
.Fin	move.l	a0,a2
	Rjmp	L_Str2Chaine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: Menus.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					MENU KEY
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InMenuKey
; - - - - - - - - - - - - -
	bsr	MnDim
	tst.l	MnLat(a2)
	bne	FonCall
	cmp.w	#_TkTo,(a6)
	bne.s	IMnk2
	move.l	a2,-(sp)
	addq.l	#2,a6
	bsr	New_Evalue
	cmp.b	#2,d2
	beq.s	IMnk1
* Scancode, shifts
	move.l	d3,-(sp)
	moveq	#0,d3
	cmp.w	#_TkVir,(a6)
	bne.s	IMnk0
	bsr	Fn_New_Expentier
IMnk0	move.l	(sp)+,d2
	move.l	(sp)+,a2
	cmp.l	#256,d3
	bcc	FonCall
	move.b	d3,MnKSh(a2)
	cmp.l	#128,d2
	bcc	FonCall
	move.b	d2,MnKSc(a2)
	move.b	#-1,MnKFlag(a2)
	rts
* "n"
IMnk1	move.l	(sp)+,a2
	move.l	d3,a0
	tst.w	(a0)+
	beq	FonCall
	move.b	(a0),MnKAsc(a2)
	move.b	#1,MnKFlag(a2)
	rts
* Arret!
IMnk2	clr.b	MnKFlag(a2)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InMenuKey1
	Lib_Def	InMenuKey2
	Lib_Def	InMenuKey3
	Lib_Def	MnKy
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ON MENU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InOnMenu
; - - - - - - - - - - - - -
	Rjsr	L_OMnEff
;	Rlea	L_GoMenu,0		Pas de routine de branchement
;	move.l	a0,GoTest_GoMenu(a5)
	move.w	(a6)+,-(sp)
*	Cherche les labels
	clr.w	-(sp)
OnMn1	bsr	GetLabel
	beq	LbNDef
	move.l	d0,-(a3)
	addq.w	#1,(sp)
	cmp.w	#_TkVir,(a6)+
	beq.s	OnMn1
	subq.l	#2,a6
* 	Taille
	move.w	(sp)+,d2
	move.w	d2,OMnNb(a5)
	moveq	#0,d1
	move.w	d2,d1			* Nb de labesl*4
	lsl.w	#2,d1
	move.l	d1,d0
	SyCall	MemFast
	beq	OOfMem
	move.l	a0,OMnBase(a5)
	add.l	d1,a0
* Poke les jumps
	subq.w	#1,d2
OnMn2	move.l	(a3)+,-(a0)
	dbra	d2,OnMn2
* Goto/Gosub/Proc
	move.w	(sp)+,OMnType(a5)
* Plus de branchements
	bclr	#BitJump,ActuMask(a5)
* Branche la routine Clearvar
	lea	.Struc(pc),a1
	lea	Sys_ClearRoutines(a5),a2
	SyCall	AddRoutine
	rts
; Structure clearvar
; ~~~~~~~~~~~~~~~~~~
.Struc	dc.l	0
	Rjmp	L_OMnEff

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					MENU$(,,,)=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InMenu
; - - - - - - - - - - - - -
	move.l	a3,-(sp)
	clr.w	-(sp)
* Branche la routine pour CLEARVAR
	Rjsr	L_MnClearVar
* Empile les parametres
IMen1:	addq.w	#1,(sp)
	bsr	Fn_New_Expentier
	move.l	d3,-(a3)
	cmp.w	#_TkVir,(a6)
	beq.s	IMen1
* Trouve le menu
	move.w	(sp)+,d5
	Rjsr	L_MnFind
	bne.s	IMenA
	Rjsr	L_MnIns
IMenA:	move.l	(sp)+,a3
* Prend les parametres
*	cmp.w	#_TkEg,(a6)
*	bne.s	IMenI
******* Fonction MENU$="jfkjdkfjkdj"
	move.l	ScOnAd(a5),a0
	cmp.l	MnAdEc(a5),a0
	beq.s	IMen6
	tst.l	MnAdEc(a5)
	bne	ScNOp
	move.l	a0,MnAdEc(a5)
IMen6:	move.l	EcWindow(a0),a0
	move.b	WiPaper+1(a0),d0
	move.b	WiPen+1(a0),d1
	move.b	d0,MnInkA1(a2)
	move.b	d1,MnInkB1(a2)
	move.b	d0,MnInkC1(a2)
	move.b	d1,MnInkA2(a2)
	move.b	d0,MnInkB2(a2)
	move.b	d0,MnInkC2(a2)
* Prend la chaine OB1
	lea	MnOb1(a2),a0
	bsr	MnOob
* Prend la chaine OB2
IMen7	cmp.w	#_TkVir,(a6)
	bne.s	IMenX
	lea	MnOb2(a2),a0
	bsr	MnOob
* Prend la chaine OBOFF
IMen8	cmp.w	#_TkVir,(a6)
	bne.s	IMenX
	lea	MnOb3(a2),a0
	bsr	MnOob
* Prend la chaine OBF
IMen9	cmp.w	#_TkVir,(a6)
	bne.s	IMenX
	lea	MnObF(a2),a0
	bsr	MnOob
* Ca y est!!!
IMenX:	addq.w	#1,MnChange(a5)
	rts

*	bclr	#BitMenu,ActuMask(a5)

;	Petite routine de creation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MnOob	movem.l	a0-a2,-(sp)
	bsr	Fn_New_Evalue			*** ?
	movem.l	(sp)+,a0-a2
	cmp.l	#EntNul,d3
	beq	MnOob0
	move.l	d3,a1
	tst.w	(a1)
	bne	MnOob1
* Efface la chaine
MnOobE	move.l	(a0),d0
	beq.s	MnOob0
	clr.l	(a0)
	move.l	d0,a1
	moveq	#0,d0
	move.w	(a1),d0
	SyCall	MemFree
MnOob0	rts
* Une chaine!
MnOob1	movem.l	a0/a1,-(sp)		* Efface l'ancienne
	bsr.s	MnOobE
	movem.l	(sp)+,a0/a1
	Rjsr	L_MnObjet		* Cree la nouvelle
	beq	OOfMem
	bmi	FonCall
	move.l	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Def	InMenu2
	Lib_Def	InMenu3
	Lib_Def	InMenu4
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MENU DEL [(coordonnees,,)]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InMenuDel
; - - - - - - - - - - - - -
	cmp.w	#_TkPar1,(a6)
	beq.s	IMnD1
	Rjsr	L_MnRaz
	rts
IMnD1	bsr	MnDim
	move.l	a2,d0
	moveq	#0,d5
	addq.w	#1,MnChange(a5)
	Rjsr	L_MnEff
	rts
; - - - - - - - - - - - - -
	Lib_Def	InMenuDel1
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SET MENU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Par InSetMenu
; - - - - - - - - - - - - -
	bsr	MnDim
	move.l	a2,-(sp)
	bsr	Fn_New_Expentier
	move.l	d3,-(a3)
	bsr	Fn_New_Expentier
	move.l	(sp)+,a2
	move.l	#EntNul,d0
	cmp.l	d0,d3
	beq.s	ISMn1
	move.w	d3,MnY(a2)
	bset	#MnFixed,MnFlag(a2)
ISMn1	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	ISMn2
	move.w	d1,MnX(a2)
	bset	#MnFixed,MnFlag(a2)
ISMn2	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Routine-> adresse du flag
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	MnDim
MnDim
; - - - - - - - - - - - - -
	cmp.w	#_TkPar1,(a6)
	beq.s	MnDim1
	bsr	New_Expentier
	tst.l	d3
	beq	FonCall
	cmp.l	#MnNDim,d3
	bhi	FonCall
	lea	MnDFlags(a5),a0
	lea	-1(a0,d3.w),a0
	rts
;	Cherche l'adresse D'UN objet
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MnDim1	move.l	a3,-(sp)
	clr.w	-(sp)
MnDim2	addq.w	#1,(sp)
	bsr	Fn_New_Expentier
	move.l	d3,-(a3)
	cmp.w	#_TkVir,(a6)
	beq.s	MnDim2
* Trouve le menu
	move.w	(sp)+,d5
	Rjsr	L_MnFind
	move.l	(sp)+,a3
	tst.l	d0
	beq	MnINDef
	lea	MnFlag(a2),a0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Entree appel de procedure menu
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	MenuProcedure
; - - - - - - - - - - - - -
	move.l	a0,d3			Le nom du label
	bsr	GLb3			Va chercher le label
	beq.s	.Err
	move.l	d0,a2			Adresse de la procedure
	sub.l	a6,a6			Pas de retour!
	move.l	Prg_InsRet(a5),-(sp)
	clr.w	-(sp)			Pas d'erreur
	bra	InProE			Va a la procedure
.Err	moveq	#-1,d0			Une Erreur!
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SOUS PROGRAMME UTILISE PAR VAL ET INPUT
;	D0=	Tenir compte du signe (TRUE)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	ValRout
; - - - - - - - - - - - - -
        movem.l a1-a2/d5-d7,-(sp)
	move.l	a0,d7
	moveq	#0,d4
	move.l	a0,a2
	tst.w	d0
	beq.s	val1c
; y-a-t'il un signe devant?
val1:   move.b 	(a0)+,d0
        beq 	val10
        cmp.b 	#32,d0
        beq.s 	val1
        move.l 	a0,a2
        subq.l 	#1,a2
        cmp.b 	#"-",d0
        bne.s 	val1a
        not 	d4
        bra.s 	val1c
val1a:  cmp.b 	#"+",d0
        beq.s 	val1c
val1b:  subq.l 	#1,a0
val1c
; Explore le chiffre
; ~~~~~~~~~~~~~~~~~~
	move.b 	(a0)+,d0
        beq 	val10
        cmp.b 	#32,d0
        beq.s 	val1c
        cmp.b 	#"$",d0      	;chiffre HEXA
        beq 	val5
        cmp.b	#"%",d0       	;chiffre BINAIRE
        beq 	val6
        cmp.b 	#".",d0
        beq.s 	val2
        cmp.b 	#"0",d0
        bcs 	val10
        cmp.b 	#"9",d0
        bhi 	val10
; c'estn chiffre DECIMAL: entier ou float?
val2:   subq.l	#1,a0
	move.l 	a0,a1        	;si float: trouve la fin du chiffre
        clr 	d3
val3:   move.b 	(a1)+,d0
        beq.s 	val4
        cmp.b 	#32,d0
        beq.s 	val3
        cmp.b 	#"0",d0
        bcs.s 	val3z
        cmp.b 	#"9",d0
        bls.s 	val3
val3z:  cmp.b 	#".",d0       	;cherche une "virgule"
        bne.s	val3a
        bset 	#0,d3          	;si deux virgules: fin du chiffre
        beq.s 	val3
        bne.s 	val4
val3a:  cmp.b 	#"e",d0       	;cherche un exposant
        beq.s 	val3b
        cmp.b 	#"E",d0       	;autre caractere: fin du chiffre
        bne.s 	val4
val3ab: move.b 	#"e",-1(a1)  	;met un E minuscule!!!
val3b:  move.b 	(a1)+,d0     	;apres un E, accepte -/+ et chiffres
        cmp.b 	#32,d0
        beq.s 	val3b
        cmp.b 	#"+",d0
        beq.s 	val3c
        cmp.b 	#"-",d0
        bne.s 	val3e
val3c:  bset 	#1,d3          	;+ ou -: c'est un float!
val3d:  move.b 	(a1)+,d0     	;puis cherche la fin de l'exposant
        cmp.b 	#32,d0
        beq.s 	val3d
val3e:  cmp.b 	#"0",d0
        bcs.s 	val4
        cmp.b 	#"9",d0       	;chiffre! c'est un float
        bls.s 	val3c
val4:   tst 	d3              ;si d3=0: c'est un entier
        beq 	val7
; conversion ASCII--->FLOAT
	move.l	a2,a0
        subq.l 	#1,a1
	movem.l	a1/a3-a6,-(sp)
	lea 	BuFloat(a5),a2
	moveq 	#32,d1
Ca1:	cmp.l	a0,a1
	beq.s	Ca2
	move.b 	(a0)+,d0
	cmp.b 	#32,d0
	beq.s 	Ca1
	move.b 	d0,(a2)+
	dbra 	d1,Ca1
Ca2:	clr.b 	(a2)
	clr.b 	1(a2)
	tst.b	MathFlags(a5)		Simple ou double precision?
	bmi.s	.Double
; Simple precision
	lea	BuFloat(a5),a0
	move.l	a0,-(sp)
	Rjsr	L_AscToFloat
	addq.l	#4,sp
	move.l	d0,d3
        moveq 	#1,d2
        move.w 	#_TkFl,d1    	    ;chiffre FLOAT
	bra.s	.FQuit
; Double precision
.Double	lea	BuFloat(a5),a0
	move.l	a0,-(sp)
	Rjsr	L_AscToDouble
	addq.l	#4,sp
	move.l	d0,d3
	move.l	d1,d4
	moveq	#1,d2
	move.w	#_TkDFl,d1
.FQuit	movem.l	(sp)+,a0/a3-a6
	moveq	#0,d0
	bra.s	valOut
; chiffre hexa
val5:   bsr 	hexalong
        move.w 	#_TkHex,d2
        bra.s 	val8
; chiffre binaire
val6:   bsr 	binlong
        move.w 	#_TkBin,d2
        bra.s 	val8
; chiffre entier
val7:   bsr 	declong
        move.w 	#_TkEnt,d2
val8:   exg 	d2,d1           ;type de conversion--->d1
        tst 	d2
        bne.s 	val10           ;si probleme: ramene zero!
        move.l 	d0,d3
; Test du signe, si entier
        tst 	d4
        beq.s 	val8a
        neg.l 	d3
val8a:	moveq	#0,d2
	bra.s	valOut
; ramene zero
val10:  moveq	#0,d2           		Erreur: ramene zero!
        moveq	#0,d3
	move.l	d7,a0
	moveq	#1,d0
; Sortie
valOut 	movem.l (sp)+,a1-a2/d5-d7
        rts

; 	MINI CHRGET POUR LES CONVERSIONS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
minichr	move.b 	(a0)+,d2
        beq.s 	mc1
        cmp.b 	#32,d2
        beq.s 	minichr
        cmp.b 	#"a",d2       ;si minuscule: majuscule
        bcs.s 	mc0
        sub.b 	#"a"-"A",d2
mc0     sub.b 	#48,d2
        rts
mc1     move.b 	#-1,d2
        rts
; Minichr pour hexa
; ~~~~~~~~~~~~~~~~~
minichr2
	move.b (a0)+,d2
        beq.s .mc1
        cmp.b #"a",d2       ;si minuscule: majuscule
        bcs.s .mc0
        sub.b #"a"-"A",d2
.mc0:   sub.b #48,d2
        rts
.mc1:   move.b #-1,d2
        rts

; 	CONVERSION DECIMAL->HEXA SUR QUATRE OCTETS, SIGNE!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
declong moveq	#0,d0
 	moveq	#0,d2
        moveq	#0,d3
        move.l 	a0,-(sp)
ddh1:   bsr 	minichr
ddh1a:  cmp.b 	#10,d2
        bcc.s 	ddh5
        move 	d0,d1
        mulu 	#10,d1
        swap 	d0
        mulu 	#10,d0
        swap 	d0
        tst 	d0
        bne.s 	ddh2
        add.l 	d1,d0
        bcs.s 	ddh2
        add.l	d2,d0
        bmi.s 	ddh2
        addq 	#1,d3
        bra.s 	ddh1
ddh2:   move.l 	(sp)+,a0
        moveq	#1,d1          	;out of range: bpl, et recupere l'adresse
        rts
ddh5:   subq.l 	#1,a0
	addq.l 	#4,sp
        tst	d3
        beq.s 	ddh7
        moveq	#0,d1           ;OK: chiffre en d0, et beq
        rts
ddh7:   moveq	#-1,d1     	;pas de chiffre: bmi
        rts

; 	CONVERSION HEXA-ASCII EN HEXA-HEXA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
hexalong
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
        move.l 	a0,-(sp)
hh1:    bsr 	minichr2
        cmp.b 	#10,d2
        bcs.s 	hh2
        cmp.b 	#17,d2
        bcs.s 	ddh5
        subq.w 	#7,d2
hh2:    cmp.b 	#16,d2
        bcc.s 	ddh5
        lsl.l 	#4,d0
        or.b 	d2,d0
        addq.w 	#1,d3
        cmp 	#9,d3
        bne.s 	hh1
        beq.s 	ddh2

; 	CONVERSION BINAIRE ASCII ---> HEXA SUR QUATRE OCTETS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
binlong	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
        move.l 	a0,-(sp)
bh1:    bsr 	minichr
        cmp.b 	#2,d2
        bcc.s 	ddh5
        roxr 	#1,d2
        roxl.l 	#1,d0
        bcs.s 	ddh2
        addq.w	#1,d3
        cmp.w 	#33,d3
        bne.s 	bh1
        beq 	ddh1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					DEBUT DES SWAP FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Start_FloatSwap
; - - - - - - - - - - - - -
	Lib_Def	CmpInitFloat
	Lib_Def	CmpInitDouble
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ENTIER >>> FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion entier >>> float dans le dernier operateur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	IntToFl1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFlt(a6)
	move.l	d3,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	DIntToFl1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFlt(a6)
	move.l	d3,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ENTIER >>> FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion entier >>> float dans la pile
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	IntToFl2
; - - - - - - - - - - - - -
	move.l	4(a3),d0
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFlt(a6)
	move.l	d4,a6
	move.l	d0,4(a3)
	move.b	#1,3(a3)
	rts
; - - - - - - - - - - - - -
	Lib_Def	DIntToFl2
; - - - - - - - - - - - - -
	movem.l	4(a3),d0-d1
	move.l	a6,-(sp)
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFlt(a6)
	move.l	(sp)+,a6
	movem.l	d0-d1,4(a3)
	move.b	#1,3(a3)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FLOAT >>> ENTIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion float >>> entier dans le dernier operateur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FlToInt1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFix(a6)
	move.l	d3,a6
	move.l	d0,d3
	Ret_Int
; - - - - - - - - - - - - -
	Lib_Def	DFlToInt1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d3
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFix(a6)
	move.l	d3,a6
	move.l	d0,d3
	Ret_Int

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FLOAT >>> ENTIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion float >>> entier dans la pile
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FlToInt2
; - - - - - - - - - - - - -
	move.l	4(a3),d0
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFix(a6)
	move.l	d4,a6
	move.l	d0,4(a3)
	clr.b	3(a3)
	rts
; - - - - - - - - - - - - -
	Lib_Def	DFlToInt2
; - - - - - - - - - - - - -
	movem.l	4(a3),d0-d1
	move.l	a6,-(sp)
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFix(a6)
	move.l	(sp)+,a6
	movem.l	d0-d1,4(a3)
	clr.b	3(a3)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FONCTION MATHEMATIQUE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une fonction mathematique
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Math_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	MathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	DMath_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d3
	move.l	DMathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					COMPARAISONS FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une comparaison float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Float_Compare
; - - - - - - - - - - - - -
	move.l	d3,d1
	move.l	4(a3),d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	_LVOSPCmp(a6)
	move.l	d3,a6
	rts
; - - - - - - - - - - - - -
	Lib_Def	DFloat_Compare
; - - - - - - - - - - - - -
	movem.l	4(a3),d0-d1
	move.l	d3,d2
	move.l	d4,d3
	move.l	a6,d4
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPCmp(a6)
	move.l	d4,a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Operation FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une operation float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Float_Operation
; - - - - - - - - - - - - -
	move.l	4(a3),d0
	move.l	d3,d1
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d4,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	DFloat_Operation
; - - - - - - - - - - - - -
	movem.l	4(a3),d0-d1
	exg	d3,d2
	exg	d4,d3
	move.l	a6,-(sp)
	move.l	DFloatBase(a5),a6
	jsr	0(a6,d4.w)
	move.l	(sp)+,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FLOAT= ZERO?
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait un TST sur le float D3
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Float_Test
; - - - - - - - - - - - - -
	move.l	d3,d1
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	_LVOSPTst(a6)
	move.l	d4,a6
	rts
; - - - - - - - - - - - - -
	Lib_Def	Float_TestF
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d5
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPTst(a6)
	move.l	d5,a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Operation MATH
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une operation Math
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Math_Operation
; - - - - - - - - - - - - -
	move.l	4(a3),d0
	move.l	d3,d1
	move.l	a6,d4
	move.l	MathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d4,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	DMath_Operation
; - - - - - - - - - - - - -
	movem.l	4(a3),d0-d1
	exg	d3,d2
	exg	d4,d3
	move.l	a6,-(sp)
	move.l	DMathBase(a5),a6
	jsr	0(a6,d4.w)
	move.l	(sp)+,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FONCTION FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une fonction float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Float_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	DFloat_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d3
	move.l	DFloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Verifie que le float est positif
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FlPos			Simple precision
; - - - - - - - - - - - - -
	btst	#7,d3
	Rbne	L_FonCall
	rts
; - - - - - - - - - - - - -
	Lib_Def	FlPosD			Double precision
; - - - - - - - - - - - - -
	btst	#31,d3
	Rbne	L_FonCall
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					RETOURNE UN ANGLE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	AAngle			SFloat
; - - - - - - - - - - - - -
	move.l	d3,d0			Appel de la fonction
	move.l	a6,d3
	move.l	MathBase(a5),a6
	jsr	0(a6,d2.w)
	tst.w	Angle(a5)
	beq.s	.AAnX
	move.l	FloatBase(a5),a6
	move.l	ValPi(a5),d1
	jsr	_LVOSPDiv(a6)
	move.l	Val180(a5),d1
	jsr	_LVOSPMul(a6)
.AAnX	move.l	d3,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	AAngleD			DFloat
; - - - - - - - - - - - - -
	move.l	d3,d0			Appel de la fonction
	move.l	d4,d1
	move.l	a6,-(sp)
	move.l	DMathBase(a5),a6
	jsr	0(a6,d2.w)
	tst.w	Angle(a5)
	beq.s	.AAnY
	move.l	DFloatBase(a5),a6
	move.l	ValPi(a5),d2
	move.l	ValPi+4(a5),d3
	jsr	_LVOSPDiv(a6)
	move.l	Val180(a5),d2
	move.l	Val180+4(a5),d3
	jsr	_LVOSPMul(a6)
.AAnY	move.l	(sp)+,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TRANSFORME EN ANGLE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FFAngle			SFloat
; - - - - - - - - - - - - -
	tst.w	Angle(a5)
	bne.s	.Conv
	rts
; Conversion--> radian
.Conv	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	move.l	Val180(a5),d1
	jsr	_LVOSPDiv(a6)
	move.l	ValPi(a5),d1
	jsr	_LVOSPMul(a6)
	move.l	d3,a6
	move.l	d0,d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def	FAngleD			DFloat
; - - - - - - - - - - - - -
	tst.w	Angle(a5)
	bne.s	.Conv
	rts
; Conversion--> radian
.Conv	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,-(sp)
	move.l	DFloatBase(a5),a6
	move.l	Val180(a5),d2
	move.l	Val180+4(a5),d3
	jsr	_LVOSPDiv(a6)
	move.l	ValPi(a5),d2
	move.l	ValPi+4(a5),d3
	jsr	_LVOSPMul(a6)
	move.l	(sp)+,a6
	move.l	d0,d3
	move.l	d1,d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PARAM FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def FnParamF		SFloat
; - - - - - - - - - - - - -
	move.l	ParamF(a5),d3
	Ret_Float
; - - - - - - - - - - - - -
	Lib_Def FnParamD		DFloat
; - - - - - - - - - - - - -
	move.l	ParamF(a5),d3
	move.l	ParamF2(a5),d4
	Ret_Float

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ASCII Vers Float
;	A0	Buffer
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Ascii2Float
; - - - - - - - - - - - - -
	move.l	a0,-(sp)
	Rjsr	L_AscToFloat
	addq.l	#4,sp
	rts
; - - - - - - - - - - - - -
	Lib_Def	Ascii2FloatD
; - - - - - - - - - - - - -
	move.l	a0,-(sp)
	Rjsr	L_AscToDouble
	addq.l	#4,sp
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Float vers ascii
;	D3/D4	Float
;	A0	Buffer
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	Float2Ascii
; - - - - - - - - - - - - -
	move.l 	d3,d0			Simple precision
	move.w	FixFlg(a5),d4
        move.w 	ExpFlg(a5),d5
	bclr	#31,d4
	Rjmp	L_FloatToAsc
; - - - - - - - - - - - - -
	Lib_Def	Float2AsciiD
; - - - - - - - - - - - - -
	moveq	#2,d0			Double precision
	moveq	#15,d1
	tst.w	FixFlg(a5)
	bmi.s	.Ok
	move.w	FixFlg(a5),d1		Nombre de chiffres
	tst.w	ExpFlg(a5)
	beq.s	.Ok
	moveq	#0,d0
.Ok	movem.l	a0-a1,-(sp)
	btst	#31,d3			Si positif
	bne.s	.Neg
	move.b	#" ",(a0)+		Un espace devant
.Neg	move.l	d0,-(sp)
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move.l	d4,-(sp)
	move.l	d3,-(sp)
	Rjsr	L_DoubleToAsc
	lea	20(sp),sp
	movem.l	(sp)+,a0/a1
.Lop	tst.b	(a0)+
	bne.s	.Lop
	subq.l	#1,a0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Pour le compilateur, fonctions internes
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	FnMaxF
	Lib_Def	FnMaxD
	Lib_Def	FnMinF
	Lib_Def	FnMinD

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FIN DES SWAP FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Def	End_FloatSwap
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Relai de saut aux erreurs principales
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FonCall		Rbra	L_FonCall
Synt		Rbra	L_Syntax
OOfMem		Rbra	L_OOfMem
StooLong	Rbra	L_StooLong
ScNOp		Rbra	L_ScNOp
FilTM		Rbra	L_FilTM
AdrErr		Rbra	L_AdrErr
EcWiErr		Rbra	L_EcWiErr
BkNoRes		Rbra	L_BkNoRes



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Espace pour le compilateur!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Pos 500
; - - - - - - - - - - - - -
