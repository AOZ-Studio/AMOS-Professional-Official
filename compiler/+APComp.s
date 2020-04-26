;____________________________________________________________________________
;............................................................................
;..................................................................2222222...
;...............................................................22222222220..
;..................................................222........222222.....222.
;.............................................2202222222222..22000...........
;.................................22000.....20222222222200000200002..........
;................................2002202...2222200222.220000000200000000022..
;...................220002......22222200..2200002.......2200000...20000000000
;...................22222202....2220000022200000..........200002........20000
;....200000.........2222200000222200220000000002..........200002........20000
;....00222202........2220022000000002200002000002........2000002000020000000.
;...2222200000.......220002200000002.2000000000000222222000000..2000000002...
;...220000200002......20000..200002..220000200000000000000002.......22.......
;..2220002.220000 2....220002...22.....200002..0000000000002.................
;..220000..222000002...20000..........200000......2222.......................
;..000000000000000000..200000..........00002.................................
;.220000000022020000002.200002.........22......._____________________________
;.0000002........2000000220022.................|
;200000............2002........................| AMOSPro Compiler
;200002........................................|
;20002.........................................|_____________________________
;____________________________________________________________________________
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
;____________________________________________________________________________

		Include "+AMOS_Includes.s"
		Include "+Version.s"
;____________________________________________________________________________

PP_Config	equ	1
PP_IntConfig	equ	2
PP_LibLoad	equ	4
PP_OpenSource	equ	10
PP_OpenObjet	equ	12
PP_Compile	equ	20
PP_Chaines	equ	30
PP_LibInternes	equ	33
PP_LibExternes	equ	45
PP_System1	equ	60		amos.library
PP_System2	equ	62		interpreter env
PP_System3	equ	64		mouse.abk
PP_System4	equ	66		resource
PP_System5	equ	68		messages erreur
PP_Banks	equ	80
PP_RelRel	equ	85
PP_RelAbs	equ	90
PP_CloseObjet	equ	95
PP_Icons	equ	100

M_Libs			equ	28		26 librairies + defaut
F_Courant		equ	0
F_Source		equ	1
F_Objet			equ	2
F_Libs			equ	3
F_LibInterne		equ	F_Libs+M_Libs-1
F_Debug			equ	F_Libs+M_Libs
M_Fichiers		equ	F_Debug+1

L_PathToDelete		equ	108*2

; 			Tailles buffers standart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_BSo			equ	8000		Longueur buffer source
L_DiscIn		equ	1024*4		Buffer chargement banques...
L_BordBso		equ	128		Bordure buffer source
L_BordBob		equ	768		Bordure buffer objet
L_Bob			equ	1024*6		Buffer objet

;			Flags relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rel_Libraries		equ	$01000000
Rel_Chaines		equ	$02000000
Rel_Label		equ	$03000000

;			Tokens de l'extension
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ext_Nb			equ	5
Ext_TkCmp       	equ     6
Ext_TkCOp       	equ     $14
Ext_TkTstOn     	equ     $28
Ext_TkTstOf     	equ     $3a
Ext_TkTst       	equ     $4e


F_Externes		equ	0
F_Dialogs		equ	1
F_Menus			equ	2
F_Input			equ	3
F_FSel			equ	4

;---------------------------------------------------------------------
		bra	CliIn			0
		bra	AMOS_Compile		4
		bra	AMOS_Start		8
		bra	AMOS_Cont		12
		bra	AMOS_Stop		16
		dc.b	"APcp"			20
;---------------------------------------------------------------------
		dc.b	0,"$VER:"
		Version
		even
;---------------------------------------------------------------------

;---------------------------------------------------------------------
;  	Entree AMOS instruction "Compile"
;---------------------------------------------------------------------
AMOS_Compile
	movem.l	a3-a6/d6/d7,-(sp)
	move.l	a5,a4
	bsr	Reserve_DZ		***
	move.l	a4,AMOS_Dz(a5)
	move.b	#1,Flag_AMOS(a5)
	clr.b	Flag_Quiet(a5)
	bsr	Go_On
	movem.l	(sp)+,a3-a6/d6/d7
	rts

;---------------------------------------------------------------------
;  	Entree Compiler_Shell.AMOS
;---------------------------------------------------------------------

;	Premier appel: reserve une pile pour le compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_Start
	movem.l	a3-a6/d6/d7,-(sp)	Sauve les registres

	move.l	d2,d4			Adresse de la config
	move.l	d1,d3			Taille des sliders
	move.l	d0,d2
	move.l	a0,a2

	lea	DZ(pc),a3
	move.l	sp,Pile_AMOS-DZ(a3)	Position pile AMOS

	move.l	#1024*4,d0		Reserve la pile
	move.l	#Public|Clear,d1
	move.l	$4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	.OOMem
	move.l	d0,Pile_Base-DZ(a3)
	move.l	d0,a0
	lea	1024*4(a0),a0
	move.l	a0,sp

	move.l	a5,a4			Reserve la datazone APCmp
	bsr	Reserve_DZ		***
	move.l	a4,AMOS_Dz(a5)
	move.b	#-1,Flag_AMOS(a5)	Flag Compiler_Shell.AMOS
	move.l	d2,d0
	move.l	a2,a0
	move.w	d3,Total_Position(a5)	Stocke pour l'affichage
	move.l	d4,A_Config(a5)		Adresse de la configuration
	move.b	#-1,Flag_Quiet(a5)	Pas de messages
	bra	Go_On			Branche au compilateur

; Out of memory immediat
.OOMem	moveq	#-2,d0
	movem.l	(sp)+,a3-a6/d6/d7
	rts

; 	Rebranche au compilateur pour continuer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_Cont
	movem.l	a3-a6/d6/d7,-(sp)	Sauve les registres AMOSPro
	lea	DZ(pc),a0
	move.l	sp,Pile_AMOS-DZ(a0)	Stocke l'adresse de retour
	move.l	Pile_APCmp-DZ(a0),sp
	movem.l	(sp)+,d0-d7/a0-a6	Recupere tout le compilateur
	rts				Rebranche a la routine

;	ABORT: arrete la compilation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_Stop
	movem.l	a3-a6/d6/d7,-(sp)	Sauve les registres AMOSPro
	lea	DZ(pc),a0
	move.l	sp,Pile_AMOS-DZ(a0)	Stocke l'adresse de retour
	move.l	Pile_APCmp-DZ(a0),sp
	movem.l	(sp)+,d0-d7/a0-a6	Recupere tout le compilateur
	bra	Err_ControlC

; 	Retourne au basic avec tout ouvert!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_Back
	movem.l	a0-a6/d0-d7,-(sp)	Stocke tout!
	lea	DZ(pc),a0
	move.l	sp,Pile_APCmp-DZ(a0)	Stocke la pile
	move.l	Pile_AMOS-DZ(a0),sp	Pile d'AMOSPro en plan
	movem.l	(sp)+,a3-a6/d6/d7	On recupere tout!
	moveq	#-1,d0			Retour normal
	rts

;	Efface le buffer de la pile
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOS_TheEnd
	lea	DZ(pc),a3
	move.l	Pile_AMOS-DZ(a3),sp
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	Pile_Base-DZ(a3),a1
	clr.l	Pile_Base-DZ(a3)
	move.l	#1024*4,d0
	move.l	$4.w,a6
	jsr	_LVOFreeMem(a6)
.Skip	movem.l	(sp)+,d0-d1/a0-a1/a6
	movem.l	(sp)+,a3-a6/d6/d7
	tst.l	d0
	rts



;---------------------------------------------------------------------
;  Entree CLI
;---------------------------------------------------------------------
CliIn	bsr	Reserve_DZ
	clr.b	Flag_AMOS(a5)

; Entree commune
Go_On	move.l	sp,C_Pile(a5)
	movem.l	a0/d0,-(sp)
; Reserve les buffers principaux
	bsr	Reserve_Work
; Recopie la ligne de commande dans le buffer
	movem.l	(sp)+,a1/d1
	move.l	B_Work(a5),a0
	subq.l	#1,d1
	bmi.s	.loop3
.loop1	move.b	(a1)+,d0
	cmp.b	#32,d0
	bcs.s	.loop2
	move.b	d0,(a0)+
.loop2	dbra	d1,.loop1
.loop3	clr.b	(a0)
; Init de l'amigados
	bsr	Init_Disc

; Flags par defaut
	move.b	#32,Flag_Flash(a5)
	clr.b	Flag_Type(a5)
	move.b	#1,Flag_Default(a5)
	clr.b	Flag_WB(a5)

	IFNE	Debug
	move.w	d7,Stop_Line(a5)
	ENDC

; Explore la ligne de commande (si option -C)
	move.l	B_Work(a5),a0
	bsr	CommandLine
; Si pas sous AP_Compiler.AMOS, charge la config
; Explore sa ligne de commande (si option -E)
	tst.l	A_Config(a5)		Deja chargee?
	bne.s	.COk
	move.l	Path_Config(a5),a0
	tst.b	(a0)			Une command line specifiee?
	bne.s	.CLoad			OUI! Charge directement...
	lea	Def_Config0(pc),a0
	move.l	Path_Config(a5),a1
	bsr	CopName
	bsr	Load_Config
	bne.s	.COk
	lea	Def_Config1(pc),a0
	move.l	Path_Config(a5),a1
	bsr	CopName
	bsr	Load_Config
	bne.s	.COk
	lea	Def_Config2(pc),a0
	move.l	Path_Config(a5),a1
	bsr	CopName
.CLoad	bsr	Load_Config
	beq	Err_CantLoadConfig
.COk	bsr	Cold_Config		Recupere les chaines par defaut
	moveq	#1,d0
	bsr	Get_ConfigMessage	Recupere la ligne de commande
	bsr	CommandLine		Explore la commande line
	move.l	d0,-(sp)
	moveq	#PP_Config,d0
	bsr	Go_Position
; Encore un coup la vraie...
	move.l	B_Work(a5),a0
	bsr	CommandLine
	move.l	d0,-(sp)
; Charge la configuration interpreteur
	bsr	Init_Config
; Des erreurs?
	move.l	(sp)+,d0
	bne	Err_InCommand
	move.l	(sp)+,d0
	bne	Err_InDefCommand
; Si mode debug, force le mode numbers!
	tst.b	Flag_Debug(a5)		Debug en route?
	beq.s	.Sl
	move.b	#1,Flag_Numbers(a5)	Oui, force les numbers
.Sl
; Imprime le titre
	moveq	#16,d0
	moveq	#19,d1
	bsr	Mes_MPrint
	moveq	#PP_IntConfig,d0
	bsr	Go_Position
; Fabrique le nom du programme objet
	bsr	Make_ObjectName

;	Debut de compilation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
; Ouvre les librairies
	bsr	Libraries_Load
	moveq	#PP_LibLoad,d0
	bsr	Go_Position
; Ouverture / Tokenisation / Test du source
	bsr	Open_Source
	moveq	#PP_OpenSource,d0
	bsr	Go_Position
; Ouverture de l'objet
	bsr	Open_Objet
	moveq	#PP_OpenObjet,d0
	bsr	Go_Position

; Compilation
	bsr	Compile

; Sauvegarde
	bsr	Close_Objet
	moveq	#PP_CloseObjet,d0
	bsr	Go_Position

; Sauve l'icon
	bsr	Init_Icon
	bsr	Save_Icon
	moveq	#PP_Icons,d0
	bsr	Go_Position

; Messages de fin
	moveq	#30,d0
	bsr	Mes_Print
	move.l	Mem_Maximum(a5),d0
	bsr	Digit
	moveq	#32,d0
	bsr	Mes_Print
	bsr	Return

	moveq	#31,d0
	bsr	Mes_Print
	move.l	L_Objet(a5),d0
	bsr	Digit
	moveq	#32,d0
	bsr	Mes_Print
	bsr	Return

	moveq	#33,d0
	bsr	Mes_Print

; Mode INFOS: imprime l'etat des buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	Flag_Infos(a5)
	beq	.Noinfos
	bsr	Return

; Les informations generales
	tst.b	MathFlags(a5)			Des maths?
	beq.s	.Nomath
	lea	Debug_Float(pc),a0
	bsr	Str_Print
.Nomath	lea	Debug_LObjet(pc),a0		Longueur objet
	move.l	Info_LObjet(a5),d0
	bsr	Info_Print
	lea	Debug_LLibrary(pc),a0		Longueur lib relatives
	move.l	Info_LLibrary(a5),d0
	bsr	Info_Print
	lea	Debug_ELibrary(pc),a0
	move.l	Info_ELibrary(a5),d0
	bsr	Info_Print
; Les buffers
	lea	Mes_Buffers(pc),a4
	lea	D_Buffers(a5),a3
.Loop0	move.l	a4,a0
	bsr	Str_Print
	move.l	(a3),d0
	bne.s	.Pavide
	lea	Mes_Bufs1(pc),a0
	bsr	Str_Print
	bsr	Return
	bra.s	.Loop3
.Pavide	move.l	d0,a2
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
	bsr	Str_Print
	move.l	d6,d0
	bsr	Digit
	lea	Mes_Bufs3(pc),a0
	bsr	Str_Print
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
.Noinfos

; Compilation complete: retourne la taille / nombre instructions etc...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TheEndOk
	move.l	B_Work(a5),a0
	clr.b	(a0)
	moveq	#0,d0
	move.l	L_Objet(a5),d1
	moveq	#0,d2
	move.w	NbInstr(a5),d2
	bra	TheEnd


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SORTIE DU COMPILATEUR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TheEnd
; - - - - - - - - - - - - -
	move.l	C_Pile(a5),sp
	movem.l	a0/d0/d1/d2,-(sp)
	move.b	Flag_AMOS(a5),d7
	bsr	F_CloseAll
	bsr	Libraries_Free
	bsr	DeleteList
	bsr	Close_Source
	bsr	Free_Objet
	bsr	End_Icon
	bsr	Free_Work
	bsr	Free_DZ
	movem.l	(sp)+,a0/d0/d1/d2
	tst.b	d7
	bmi	AMOS_TheEnd
	rts
























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

; 	Reservation des buffers de compilation base= programme de 32K
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Compile_Reserve
	move.l	End_Source(a5),d2	Longueur source
	lsr.l	#8,d2			/ 1024
	lsr.l	#2,d2
	cmp.w	#16,d2			Base de calculs= 16K
	bcc.s	.Sup
	moveq	#16,d2
.Sup	tst.b	Flag_Big(a5)		Si flag big, buffers= buffersX4
	beq.s	.Pabig
	lsl.l	#2,d2
.Pabig	moveq	#4,d3			4 shifts= 16

	lea	B_FlagVarL(a5),a0	Variables locales
	move.l	d2,d0
	mulu	#256,d0
	lsr.l	d3,d0
	bsr	Buffer_Reserve

	lea	B_FlagVarG(a5),a0	Variable globales
	move.l	d2,d0
	mulu	#256,d0
	lsr.l	d3,d0
	bsr	Buffer_Reserve

	lea	B_Chaines(a5),a0	Buffer des chaines
	move.l	d2,d0
	mulu	#384*4,d0
	lsr.l	d3,d0
	bsr	Buffer_Reserve
	move.l	a0,A_Chaines(a5)	Marque la fin des chaines

	lea	B_Lea(a5),a0		Buffer des branchements en avant
	move.l	d2,d0
	mulu	#64*8,d0
	lsr.l	d3,d0
	bsr	Buffer_Reserve
	move.l	a0,B_Lea(a5)
	move.l	a0,A_Lea(a5)
	move.l	#$7FFFFFFF,(a0)

	lea	B_Labels(a5),a0		Buffer des labels
	move.l	d2,d0
	mulu	#768*4,d0
	lsr.l	d3,d0
	bsr	Buffer_Reserve
	move.l	a0,B_Labels(a5)

	lea	B_Reloc(a5),a0		Buffer de relocation
	move.l	d2,d0
	mulu	#256*4,d0
	lsr.l	d3,d0
	bsr	Buffer_Reserve

	lea	B_Instructions1(a5),a0	Buffer des adresses des instructions
	move.l	d2,d0
	mulu	#1024*4,d0		Environ 1500 instructions / 32 k
	lsr.l	d3,d0
	bsr	Buffer_Reserve

	lea	B_Instructions2(a5),a0	Buffer des adresses des instructions procedures
	move.l	d2,d0
	mulu	#768*4,d0		Environ 1500 instructions / 32 k
	lsr.l	d3,d0
	bsr	Buffer_Reserve

	lea	B_LibRel(a5),a0		Buffer de relocation des JSR
	move.l	d2,d0
	mulu	#1024*2,d0
	cmp.b	#1,Flag_Debug(a5)	Si mode DEBUG, un jump par instruction!
	bcs.s	.NoD
	lsl.l	#1,d0			Donc, fois deux!
.NoD	lsr.l	d3,d0
	bsr	Buffer_Reserve
	move.l	a0,A_LibRel(a5)

	move.l	#1024,d0		Buffer des boucles
	lea	B_Bcles(a5),a0
	bsr	Buffer_Reserve
	move.l	a0,A_Bcles(a5)

	move.l	#256,d0			Buffer de stockage position
	lea	B_Stock(a5),a0
	bsr	Buffer_Reserve
	move.l	a0,A_Stock(a5)

	move.l	#1024*4,d0		Buffer de script expressions
	lea	B_Script(a5),a0
	bsr	Buffer_Reserve
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	COMPILATION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Compile

; Longueur du buffer variable par default
	move.l	#8,L_Buf(a5)

; Relocation
	bsr	Init_Reloc

; Adresses SORTIE / ENTREE
	sub.l	a4,a4
	lea	20,a6			Commence apres le header

; Message
	moveq	#23,d0
	bsr	Mes_Print
	bsr	Return
	move.l	A_Banks(a5),d2		Estime le nombre de lignes
	lsr.l	#4,d2
	mulu	#584,d2
	divu	#19000,d2
	lsl.w	#4,d2
	move.w	New_Position(a5),d0
	moveq	#PP_Compile,d1
	bsr	Set_Pour

; Float
	clr.w	MathType(a5)
	tst.b	MathFlags(a5)
	bpl.s	.Flt
	move.w	#1,MathType(a5)
.Flt

;	Va fabriquer le header
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Header

;	Debut du hunk programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Prog,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk

;	Debut de la relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,DebRel(a5)
	move.l	a4,OldRel(a5)
	move.l	a4,Lib_OldRel(a5)

;	Prepare le source si DEBUG / NUMBERS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Db	tst.b	Flag_Numbers(a5)
	beq	DbEnd
	move.b	#1,Flag_Errors(a5)	Force les messages d'erreur
	move.l	B_Source(a5),d2		Position de la fin
	add.l	End_Source(a5),d2
	move.l	B_Source(a5),a0
	lea	20(a0),a0
	moveq	#0,d3			Commence en ligne 1
DbRloop	moveq	#0,d1
DbLoop	addq.w	#1,d3
	add.w	d1,a0			Ligne suivante
	add.w	d1,a0
	cmp.l	d2,a0			La fin?
	beq.s	DbEnd
	move.b	(a0),d1			Encore la fin?
	beq.s	DbEnd
	move.w	d3,(a0)			Change le numero
	cmp.w	#_TkProc,2(a0)		Une procedure
	bne.s	DbLoop
	move.w	10(a0),d0		Fermee?
	bpl.s	DbLoop
	btst	#6+8,d0			Bloquee?
	beq.s	DbLoop
	move.l	4(a0),d1		Oui, saute!
	lea	12+2(a0,d1.l),a0
	bra.s	DbRloop
DbEnd

;	NO DATAS
; ~~~~~~~~~~~~~~
	bsr	CreNoData

;	Appel des routines d'init
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	CreeInits

;	Code bug
; ~~~~~~~~~~~~~~
	IFNE	Debug>1
	lea	BugCode(pc),a0
	bsr	OutCode
	ENDC

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Compilation du programme principal
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	bsr	Ver_Compile		Table de tokenisation speciale

; Variables locales au niveau 0= variables globales
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	B_FlagVarG(a5),A_FlagVarL(a5)
	move.l	B_Instructions1(a5),B_Instructions(a5)

; Procedure d'entree
; ~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	bsr	PrgIn
	move.w	Cmva6d7(pc),d0		VGlobales=VLocales
	bsr	OutWord

;	Boucle du CHRGET
; ~~~~~~~~~~~~~~~~~~~~~~
ChrGet	bsr	Aff_Pour		Affichage
	cmp.l	End_Source(a5),a6	La fin?
	beq.s	ChrEnd
	bsr	GetWord
	beq.s	ChrEnd
	move.w	d0,Cur_Line(a5)
; Sort le numero de la ligne si mode debug
Chr0	bsr	Db_OutNumber
; Regarde la table des branchements en avant
.Loop	move.l	B_Lea(a5),a0		Faire un saut?
	cmp.l	(a0),a6
	bcs.s	Chr1
	bsr	PokeAd
	bra.s	.Loop
; Appelle l'instruction
Chr1	bsr	GetWord
	beq.s	ChrGet
	cmp.w	#_TkDP,d0
	beq.s	Chr0
	addq.w	#1,NbInstr(a5)
	move.l	B_Script(a5),A_Script(a5)
	clr.w	EvaCompteur(a5)
	move.l	AdTokens(a5),a0
	move.w	0(a0,d0.w),d1		Prend l'instruction
	bmi.s	.Spe			Speciale?
	bsr	InNormal		Non, routine generale
	bra.s	Chr0
.Spe	neg.w	d1			Negatif
	lea	Inst_Jumps(pc),a1	= pointeur sur la table
	jsr	0(a1,d1.w)
	bra.s	Chr0
; Appelle la routine de fin
ChrEnd	bsr	OutLea			Marque la fin du programme
	move.w	#L_InEnd,d0
	bsr	Do_JmpLibrary
	move.l	B_Instructions(a5),B_Instructions1(a5)
	move.l	B_Instructions2(a5),B_Instructions(a5)
	move.l	AdAdress(a5),AdAdAdress(a5)
	move.w	Cpt_Labels(a5),OCpt_Labels(a5)
	move.b	Flag_Procs(a5),OFlag_Procs(a5)
	move.l	A_Datas(a5),A_ADatas(a5)
	move.w	M_ForNext(a5),MM_ForNext(a5)
; Quelque chose � compiler???
	tst.w	NbInstr(a5)
	beq	Err_NothingToCompile


;--------------------------------------> Procedures
	move.l	B_FlagVarL(a5),A_FlagVarL(a5)
	move.l	B_Labels(a5),A_Proc(a5)
PChr1	move.l	A_Proc(a5),a0
	moveq	#-6,d0
PChr2	lea	6(a0,d0.w),a0		Label suivant
	move.w	(a0),d0			Le dernier?
	beq	PChrX
	move.l	2(a0),d1		Une procedure
	bclr	#30,d1
	beq.s	PChr2			Non, on boucle
	move.l	d1,a6
	move.l	a4,2(a0)		Adresse de l'entree de cette procedure
; Adresse de la fin de la procedure
	bsr	GetLong
	subq.l	#4,a6			Prend l'offset dans le source
	lea	10-2(a6,d0.l),a0
	move.l	a0,F_Proc(a5)
; Stocke l'entree procedure si procedure langage machine
	lea	Proc_Start(a5),a0
	move.l	a3,(a0)+		4  S_a3
	move.l	a4,(a0)+		8  S_a4
	move.l	OldRel(a5),(a0)+	12 S_OldRel
	move.l	A_LibRel(a5),(a0)+	16 S_LibRel
	move.l	Lib_OldRel(a5),(a0)+	20 S_LibOldRel
	move.l	A_Chaines(a5),(a0)+	24 S_Chaines
; Stockage position actuelle
	move.w	Cmvqd0(pc),d0
	bsr	OutWord
	move.w	#L_DProc1,d0
	bsr	Do_JsrLibrary
	moveq	#4,d0
	bsr	PrgIn
; Adresse des variables
	lea	10(a6),a6
	bsr	SoVar
	moveq	#0,d7
	moveq	#0,d6
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkBra1,d0
	bne.s	DPro6
; Empile les variables / Appelle DPROC2 + Float
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
	move.w	Clea2a0a0(pc),d0
	bra.s	DPro3
; Variable LOCALE
DPro2	move.w	Clea2a6a0(pc),d0
DPro3	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	bra.s	DPro5
; Variable TABLEAU
DPro4	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
DPro5	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
; Encore un param?
	bsr	GetWord
	cmp.w	#_TkBra2,d0
	bne.s	DPro0
; Entete de la procedure
	move.w	Cmvqd3(pc),d0		N params
	move.b	d7,d0
	bsr	OutWord
	move.w	Cmvid4(pc),d0		Flags des variables destination
	move.w	Cmvqd4(pc),d1
	move.l	d6,d2
	bsr	OutMove
	move.w	#L_DProc2F,d0		Routine d'egalisation
	add.w	MathType(a5),d0		+ 0 / 1 selon precision
	bsr	Do_JsrLibrary
; Pas de melange des labels!
DPro6	addq.w	#1,N_Proc(a5)

;	CHRGET!
; ~~~~~~~~~~~~~
	addq.l	#2,a6

ProChr	bsr	Aff_Pour		Nouvelle ligne
	bsr	GetWord
	beq	Err_Syntax		???
	move.w	d0,Cur_Line(a5)

; Sort le numero de la ligne si mode debug
ProChr0	bsr	Db_OutNumber

; Verifie les sauts en avant
.Loop	move.l	B_Lea(a5),a0
	cmp.l	(a0),a6
	bcs.s	ProChr1
	bsr	PokeAd
	bra.s	.Loop

ProChr1	bsr	GetWord			Nouvelle instruction
	beq.s	ProChr
	cmp.w	#_TkDP,d0
	beq.s	ProChr0
	addq.w	#1,NbInstr(a5)
	move.l	B_Script(a5),A_Script(a5)
	clr.w	EvaCompteur(a5)
	move.l	AdTokens(a5),a0
	move.w	0(a0,d0.w),d1		Prend l'instruction
	bmi.s	.Spe			Speciale?
	bsr	InNormal		Non, routine generale
	bra.s	ProChr0
.Spe	neg.w	d1			Negatif
	lea	Inst_Jumps(pc),a1	= pointeur sur la table
	jsr	0(a1,d1.w)
	bra.s	ProChr0

; Fin procedure
InEndProc
	bsr	OutLea
	addq.l	#4,sp
	bsr	GetWord			END PROC[ ]???
	subq.w	#2,a6
	cmp.w	#_TkBra1,d0
	bne.s	CEpr2
	bsr	Fn_New_Evalue
	bsr	Optimise_D2
	addq.l	#2,a6
	and.b	#$0F,d2			Recupere les parametres
	lsl.w	#1,d2
	jmp	.jmp(pc,d2.w)
.jmp	bra.s	.Ent
	bra.s	.Float
	lea	CdEProS(pc),a0
	bra.s	.Suite
.Float	lea	CdEProF(pc),a0
	tst.b	MathFlags(a5)
	bpl.s	.Suite
	lea	CdEProD(pc),a0
	bra.s	.Suite
.Ent	lea	CdEProE(pc),a0
.Suite	bsr	OutCode
CEpr2	move.w	#L_FProc,d0		Routine de fin de procedure
	bsr	Do_JmpLibrary
	move.l	A_FlagVarL(a5),a0	Poke toutes les adresses dans l'appel
	bsr	PrgOut
	bra	PChr1
PChrX

;	Insere les routines d'init
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr 	FiniInits

;	Retrouve les variables globales >>> init du niveau zero
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	B_Instructions1(a5),B_Instructions(a5)
	move.l	AdAdAdress(a5),AdAdress(a5)
	move.l	B_FlagVarG(a5),a0
	move.l	A_ADatas(a5),A_Datas(a5)
	move.w	OCpt_Labels(a5),Cpt_Labels(a5)
	move.b	OFlag_Procs(a5),Flag_Procs(a5)
	move.w	MM_ForNext(a5),M_ForNext(a5)
	clr.w	N_Proc(a5)
	bsr	PrgOut
	bsr	End_Pour

;	Si source en INCLUDE, on fait les banques!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	and.b	#1,Flag_Source(a5)

;	Copie les constantes alphanumeriques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
	moveq	#PP_Chaines,d0
	bsr	Go_Position

;	Fin du hunk programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	A_LibRel(a5),a0		Fin de la relocation relative
	clr.w	(a0)+
	moveq	#NH_Prog,d1
	bsr	FinHunk
	move.l	a4,Info_LObjet(a5)

; 	Si pas de banques, on peut fermer le source
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	N_Banks(a5)
	bne.s	.Banks
	bsr	Close_Source
.Banks
	cmp.b	#3,Flag_Type(a5)	Si AMOS >>> Fin speciale
	beq	Fin_AMOS

;	HUNK: libraries
; ~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Libraries,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	moveq	#0,d0			Termine la 1ere partie relocation
	bsr	OutRel
	move.l	a4,OldRel(a5)		Debut 2eme partie relocation
	bsr	Linker			Va linker!
	moveq	#NH_Libraries,d1
	bsr	FinHunk
	moveq	#0,d0			Fin 2eme partie relocation
	bsr	OutRel

;	HUNK: Recopie la table de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Reloc,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	move.l	a4,AA_Reloc(a5)
; Copie
	move.l	B_Reloc(a5),a1
CRel1	move.b	(a1)+,d0
	bsr	OutByte
	cmp.l	a3,a1
	bcs.s	CRel1
	sub.l	B_Reloc(a5),a1
	move.w	a1,L_Reloc(a5)
	moveq	#NH_Reloc,d1
	bsr	FinHunk

;	HUNK: AMOS.library
; ~~~~~~~~~~~~~~~~~~~~~~~~
CopyAMOSLib
	moveq	#NH_amoslib,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	tst.b	Flag_AMOSLib(a5)
	bne.s	.Lib
	moveq	#0,d0
	bsr	OutLong
	bra.s	.PasLib
; Inclus la librairie!
.Lib	moveq	#26,d0
	bsr	Mes_Print
	bsr	Return
	lea	Nom_AMOSLib(pc),a0
	move.l	a0,d1
	moveq	#F_Courant,d0
	bsr	F_OpenOldD1
	beq	Err_AMOSLib
	moveq	#F_Courant,d1		Ouvre le fichier
	move.l	B_Work(a5),d2
	moveq	#36,d3			Charge le header
	bsr	F_Read
	bne	Err_AMOSLib
	move.l	d2,a2
	cmp.l	#$03F3,(a2)		Un programme?
	bne	Err_BadConfig
	move.l	20(a2),d3		Longueur du code
	lsl.l	#2,d3
	moveq	#F_Courant,d1
	bsr	Out_F_Read
	moveq	#2,d0			Une mouse.abk?
	bsr	Get_IntConfigMessage
	tst.b	(a0)
	beq.s	.PasLib
	moveq	#F_Courant,d1		OUI, on ferme!
	bsr	F_Close
.PasLib	moveq	#NH_amoslib,d1		Fin du hunk
	bsr	FinHunk
	moveq	#PP_System1,d0
	bsr	Go_Position

;	HUNK: Mouse.Abk
; ~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Mouse,d1
	move.l	#Hunk_Chip,d2		CHIP mem
	bsr	DebHunk
	moveq	#2,d0			Mouse.Abk
	bsr	Get_IntConfigMessage
	tst.b	(a0)			Charger le fichier?
	bne.s	.Mouse
	tst.b	Flag_AMOSLib(a5)	Prendre celui de l'AMOS.Library
	bne.s	.AMouse
; Utiliser le fichier par defaut
	moveq	#0,d0
	bsr	OutLong
	bra.s	.FMouse
; Charger le fichier actuel
.Mouse	bsr	AddPath
	moveq	#F_Courant,d0
	bsr	F_OpenOld
	beq	Err_DiskError
	moveq	#F_Courant,d1
	bsr	F_Lof
	moveq	#F_Courant,d1
	move.l	d0,d3			Copie tout!
	bsr	Out_F_Read
	bra.s	.CMouse
; Charge la mouse de la librairie AMOS
.AMouse	moveq	#F_Courant,d1		Le debut du hunk
	move.l	B_Work(a5),d2
	moveq	#4+8,d3
	bsr	F_Read
	move.l	d2,a2			Longueur des sprites
	move.l	8(a2),d3
	and.l	#$0FFFFFFF,d3
	lsl.l	#2,d3
	bsr	Out_F_Read
.CMouse	moveq	#F_Courant,d1
	bsr	F_Close
; Ferme le hunk mouse
.FMouse	moveq	#NH_Mouse,d1
	bsr	FinHunk
	moveq	#PP_System2,d0
	bsr	Go_Position

;	HUNK: environnement interpreter (deja charge)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Env,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	move.l	#PI_End-PI_Start,d0	Recopie les donnees
	move.w	d0,d1
	lsr.w	#1,d1
	subq.w	#1,d1
	bsr	OutLong			Longueur des donnees
	lea	PI_Start(a5),a1
.Loop	move.w	(a1)+,d0		Puis donnees
	bsr	OutWord
	dbra	d1,.Loop
	move.l	Sys_Messages(a5),a1	Buffer des chaines
	move.l	-(a1),d1		Taille du buffer
	lsr.w	#1,d1			Copie tout!
	subq.w	#1,d1
.Loop1	move.w	(a1)+,d0		Puis donnees
	bsr	OutWord
	dbra	d1,.Loop1
	moveq	#NH_Env,d1
	bsr	FinHunk
	moveq	#PP_System3,d0
	bsr	Go_Position

;	HUNK: banque par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_DefaultBank,d1	Un nouveau hunk
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	btst	#F_Dialogs,Flag_Libraries(a5)	Quelques messages?
	bne.s	.Open
	btst	#F_Input,Flag_Libraries(a5)	Quelques messages?
	bne.s	.Open
; Pas de banque: un -1
	moveq	#-1,d0			Un simple 0 si pas de banque
	bsr	OutLong
	bra	.Close
; Ouvre le fichier
.Open	moveq	#8,d0			Le fichier
	bsr	Get_IntConfigMessage
	bsr	AddPath
	moveq	#F_Courant,d0
	bsr	F_OpenOld
	beq	Err_DiskError
	moveq	#F_Courant,d1
	move.l	B_Work(a5),d2		Charge le header dans le buffer
	moveq	#4,d3
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a1
	cmp.l	#"AmBk",(a1)		C'est bien la banque?
	bne	Err_DiskError
	moveq	#8,d3
	bsr	F_Read
	bne	Err_DiskError
	moveq	#0,d4
	move.w	(a1),d4			Numero
	move.w	#1<<Bnk_BitData,d5	Le flag
	move.l	4(a1),d6		Longueur avec le nom
	and.l	#$0FFFFFFF,d6
	move.l	d4,(a1)+		Fabrique un entete
	move.w	d5,(a1)+
	clr.w	(a1)+
	btst	#F_Dialogs,Flag_Libraries(a5)	Copier toute la banque?
	bne	.All
; On ne copie que quelques messages
	move.l	a1,d2			Charge le nom
	moveq	#8,d3
	bsr	F_Read
	bne	Err_DiskError
	lea	8(a1),a1
	move.w	#2,(a1)+		2 Chunks
	clr.l	(a1)+			Pas de graphismes
	move.l	#12,(a1)+		Pointeur sur les textes
	move.l	B_DiskIn(a5),a0
	move.l	a0,d2
	moveq	#12,d3			Lis le header de la banque
	bsr	F_Read
	bne	Err_DiskError
	move.l	2+4(a0),d2		Longueur des graphismes
	sub.l	#12,d2			Moins le header
	moveq	#0,d3			Par rapport a la position courante
	bsr	F_Seek
	move.l	B_DiskIn(a5),d2		Lis 1k de texte!
	move.l	#1024,d3
	bsr	F_Read			sans erreur
	moveq	#15,d0			Copie les message 15 � 19
	moveq	#19,d1
	moveq	#0,d2
.Cop	cmp.w	d0,d2			Copie des messages
	bcc.s	.In
	clr.b	(a1)+
	clr.b	(a1)+
	bra.s	.Suit
.In	movem.l	d0/d1,-(sp)
	move.w	d2,d0
	move.l	B_DiskIn(a5),a0
	bsr	Get_Message
	clr.b	(a1)+
	move.b	d0,(a1)+
	ext.w	d0
	bra.s	.Co
.Copy	move.b	(a0)+,(a1)+
.Co	dbra	d0,.Copy
	movem.l	(sp)+,d0/d1
.Suit	addq.w	#1,d2
	cmp.w	d1,d2
	bls.s	.Cop
	clr.b	(a1)+			Marque la fin
	move.b	#$FF,(a1)+
	move.w	a1,d0			Rend pair
	and.w	#$0001,d0
	add.w	d0,a1
	move.l	B_Work(a5),a0
	move.l	a1,d0
	sub.l	a0,d0
	bsr	Copy_Out
	bra.s	.Close
; On copie toute la banque
.All	moveq	#8,d0			Va ecrire l'entete
	move.l	B_Work(a5),a0
	bsr	Copy_Out
	move.l	d6,d3
	moveq	#F_Courant,d1
	bsr	Out_F_Read		Copie le reste
; Ferme le fichier
.Close	moveq	#F_Courant,d1
	bsr	F_Close
	moveq	#NH_DefaultBank,d1	Ferme le hunk
	bsr	FinHunk
.Nodialog
	moveq	#PP_System4,d0
	bsr	Go_Position

;	Copie les messages d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_ErrorMessage,d1	Un nouveau hunk
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	tst.b	Flag_Errors(a5)
	bne.s	.Err
	moveq	#0,d0			Un simple 0 si pas de banque
	bsr	OutLong
	bra.s	.NoErr
.Err	bsr	Open_EditConfig
	bsr	Skip_EditChunk		Saute les data systeme
	bsr	Skip_EditChunk		Saute les chaines systeme
	bsr	Skip_EditChunk		Saute les menus
	bsr	Skip_EditChunk		Saute les messages editeur
	moveq	#F_Courant,d1
	move.l	B_Work(a5),d2		Charge la taille
	moveq	#4,d3
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a1
	move.l	(a1),d0
	move.l	d0,d3			Longueur
	bsr	OutLong
	bsr	Out_F_Read		Puis les messages
	bsr	F_Close
.NoErr	moveq	#NH_ErrorMessage,d1
	bsr	FinHunk
	moveq	#PP_System5,d0
	bsr	Go_Position

; 	Copie les banques
; ~~~~~~~~~~~~~~~~~~~~~~~
CopyBanks
	move.w	New_Position(a5),d0
	moveq	#PP_Banks,d1
	move.w	N_Banks(a5),d2
	bsr	Set_Pour
	move.w	N_Banks(a5),d7
	beq	.NoBanks
	moveq	#27,d0
	bsr	Mes_Print
	bsr	Return
	move.l	A_Banks(a5),a6		Debut des banques
	addq.l	#6,a6
	moveq	#NH_Banks,d6		Numero des hunks
; Boucle de copie d'une banque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BLoop	bsr	GetLong
	cmp.l	#"AmSp",d0
	beq.s	.SprIco
	cmp.l	#"AmIc",d0
	beq.s	.SprIco
	cmp.l	#"AmBk",d0
	bne	Err_NotAMOSProgram
; Un banque normale
; ~~~~~~~~~~~~~~~~~
	bsr	GetWord
	move.w	d0,d4			Numero de la banque
	moveq	#0,d5			Type de banque
	bsr	GetWord
	move.w	d0,d1
	bsr	GetLong
	move.l	d0,d3			Longueur
	and.l	#$0FFFFFFF,d3
	tst.l	d0			Data ou work?
	bpl.s	.Skip1
	bset	#Bnk_BitData,d5
.Skip1	move.l	#Hunk_Public,d2		Type de HUNK
	tst.w	d1			Chip ou fast?
	bne.s	.Skip2
	bset	#Bnk_BitChip,d5
	move.l	#Hunk_Chip,d2
.Skip2	move.l	d6,d1			Debut du hunk
	bsr	DebHunk
	moveq	#0,d0			Sort le header
	move.w	d4,d0			Numero.l
	bsr	OutLong
	move.w	d5,d0			Flags
	bsr	OutWord
	moveq	#0,d0			Vide
	bsr	OutWord
	bsr	Copy_Source		Copie le reste
	bra	.BNext
; Une banque de sprites / Icones
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.SprIco	move.l	d0,d3			Garde le code
	move.l	d6,d1			Debut du hunk
	move.l	#Hunk_Public,d2
	bsr	DebHunk
	move.l	d3,d0			Le code
	bsr	OutLong
	bsr	GetWord			Le nombre de sprites
	bsr	OutWord
	move.w	d0,d2
	subq.w	#1,d2
	bmi.s	.BVide
	move.l	B_Work(a5),a1
.SLoop	bsr	GetWord			SX
	bsr	OutWord
	move.w	d0,d3
	bsr	GetWord			SY
	bsr	OutWord
	mulu	d0,d3
	bsr	GetWord			NPLAN
	bsr	OutWord
	mulu	d0,d3
	bsr	GetLong			HX / HY
	bsr	OutLong
	lsl.l	#1,d3			En bytes
	bsr	Copy_Source		Copie le sprite meme si ZERO!
	dbra	d2,.SLoop
.BVide	moveq	#32*2,d3		Copie la palette
	bsr	Copy_Source
; Banque suivante
; ~~~~~~~~~~~~~~~
.BNext	move.l	d6,d1			Ferme le hunk
	bsr	FinHunk
	bsr	Aff_Pour		Affichage
	addq.w	#1,d6			Hunk suivant
	subq.w	#1,d7			Encore une banque?
	bne	.BLoop
.NoBanks
	bsr	End_Pour

;	Fin de la production de code!!!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,L_Objet(a5)

;	Copie toutes les longueurs de HUNKS dans l'entete
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CopyLong
	sub.l	a4,a4
	lea	20(a4),a4
	move.w	N_Hunks(a5),d4
	subq.w	#1,d4
	move.l	B_Hunks(a5),a1
.Hunk	move.l	4(a1),d0
	bsr	OutLong
	addq.l	#8,a1
	dbra	d4,.Hunk

; 	Actualise le loader
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Header,d1
	bsr	MarkHunk
	move.l	Ad_HeaderFlags(a5),a4
	addq.l	#2,a4

	moveq	#0,d0
	move.b	Flag_Flash(a5),d0
	tst.b	Flag_WB(a5)
	beq.s	.Skip1
	bset	#16+FPrg_Wb,d0
.Skip1	tst.b	Flag_Default(a5)
	beq.s	.Skip2
	bset	#16+FPrg_Default,d0
.Skip2	bsr	OutLong

	move.l	Lib_FinInternes(a5),d0		Pivot de la librarie (a4)
	sub.l	Lib_Debut(a5),d0
	cmp.l	#$10000,d0
	bcc	Err_Syntax
	lsr.l	#1,d0				/ 2
	bclr	#0,d0				Pair!
	move.l	d0,Lib_FinInternes(a5)
	addq.l	#2,a4
	bsr	OutLong

; 	Actualise le hunk programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#NH_Prog,d1		Marque le hunk
	bsr	MarkHunk
	move.l	a4,-(sp)		Branche le jsr inits
	move.l	Ad_JsrInits(a5),a4
	move.l	Ad_Inits(a5),d0
	bsr	OutLong
	move.l	(sp)+,a4
	bsr	Reloc_Relatif
	moveq	#NH_Libraries,d1	Marque le hunk library
	bsr	MarkHunk
	bsr	Reloc_Absolu

;	Marque les longueurs des HUNKS jusqu'a la fin
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	#NH_Reloc,d2
	move.w	N_Hunks(a5),d3
.Hunk1	move.w	d2,d1
	bsr	MarkHunk
	addq.w	#1,d2
	cmp.w	d2,d3
	bne.s	.Hunk1

;	Fin de la compilation!!!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TERMINE UN PROGRAMME AMOS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Fin_AMOS

;	Libraries
; ~~~~~~~~~~~~~~~
	bsr	A4_Pair
	bsr	Linker			Va linker!
	moveq	#0,d0			Fin relocation!
	bsr	OutRel

;	Recopie la table de relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,AA_Reloc(a5)
	move.l	B_Reloc(a5),a1
.CRel1	move.b	(a1)+,d0
	bsr	OutByte
	cmp.l	a3,a1
	bcs.s	.CRel1
	sub.l	B_Reloc(a5),a1
	move.w	a1,L_Reloc(a5)
	bsr	A4_Pair

;	Copie la fin de la procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	bsr	OutWord
	move.l	a4,AA_EProc(a5)
	move.w	#$0301,d0
	bsr	OutWord
	move.w	#_TkEndP,d0
	bsr	OutWord
	clr.w	d0
	bsr	OutWord

; 	Copie des banques AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#"AmBs",d0
	bsr	OutLong
	move.w	N_Banks(a5),d0
	bsr	OutWord
	tst.w	d0
	beq.s	.Nobank
	moveq	#27,d0
	bsr	Mes_Print
	bsr	Return
	move.l	L_Source(a5),d3
	move.l	A_Banks(a5),a6
	addq.l	#6,a6
	sub.l	a6,d3
	bsr	Copy_Source
.Nobank
;	Fin de la production de code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,L_Objet(a5)

; 	Actualise les flags d'appel
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	14,a4			Flags maths dans le header
	moveq	#0,d0
	move.b	MathFlags(a5),d0
	bsr	OutWord
	move.l	AA_Long(a5),a4		Longueur du source
	move.l	AA_EProc(a5),d0
	add.l	#6-4,d0
	sub.l	a4,d0
	bsr	OutLong
	move.l	AA_SBuf(a5),a4		Instruction Set Buffer
	addq.l	#2,a4
	move.l	L_Buf(a5),d0
	bsr	OutLong
	move.l	AA_Proc(a5),a4		Debut de la procedure
	move.l	AA_EProc(a5),d0
	sub.l	a4,d0
	subq.l	#4,d0
	bsr	OutLong

	move.l	AA_Header(a5),a4	Flags maths
	moveq	#0,d0
	move.b	Flag_Accessory(a5),d0	Flag accessory
	lsl.w	#8,d0
	move.b	MathFlags(a5),d0
	bsr	OutWord
	move.l	AA_Reloc(a5),d0		Pointeur sur relocation
	sub.l	a4,d0
	bsr	OutLong
	move.l	AA_EProc(a5),d0		Pointeur sur la fin du programme
	sub.l	a4,d0
	subq.l	#2,d0			Pointe le zero de la ligne d'avant!
	bsr	OutLong

	move.l	Lib_FinInternes(a5),d0	Pivot de la librarie (a4)
	sub.l	Lib_Debut(a5),d0
	cmp.l	#$10000,d0
	bcc	Err_Syntax
	lsr.l	#1,d0			/ 2
	bclr	#0,d0			Pair!
	move.l	d0,Lib_FinInternes(a5)
	add.l	Lib_Debut(a5),d0	Plus adresse de debut!!
	move.l	AA_A4(a5),a4		Car relocation depuis 0
	bsr	OutLong

; 	Relocation
; ~~~~~~~~~~~~~~~~
	bsr	Reloc_Relatif
	bsr	Reloc_Absolu

;	Fin de la compilation!!!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	rts





; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RELOCATION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Relocation du programme (a4)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reloc_Relatif
	move.w	New_Position(a5),d0
	moveq	#PP_RelRel,d1
	move.l	A_LibRel(a5),d2
	sub.l	B_LibRel(a5),d2
	bsr	Set_Pour

	move.l	AdTokens(a5),a2
	move.l	B_LibRel(a5),a1
	move.l 	DebRel(a5),d7         	Base de toute les adresses
	move.l	d7,a4			Base de l'exploration
	move.l	Lib_FinInternes(a5),d2
.JLoop	bsr	Aff_Pour
	move.w	(a1)+,d1
	beq.s	.JEnd
	bmi.s	.Grand
	add.w	d1,a4
.GSuite	bsr	GtoWord
	subq.l	#2,a4
	move.l	-LB_Size-4(a2,d0.w),d0
	and.l	#$FFFFFF,d0
	sub.l	Lib_Debut(a5),d0	Moins debut des librairies
	sub.l	d2,d0			Calcul du deplacement relatif

	IFNE	Debug			Verification: pas de jmp de la
	btst	#0,d0			Verification: PAIR!
	beq.s	.Skip
	bsr	Err_Debug
.Skip
	ENDC
	bsr	OutWord
	subq.l	#2,a4
	bra.s	.JLoop
.JEnd	bsr	End_Pour
	rts
.Grand	move.l	-2(a1),d0		Trop grand: .LONG
	bclr	#31,d0
	add.l	d0,a4
	addq.l	#2,a1
	bra.s	.GSuite

; 	Relocation des appels absolus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reloc_Absolu
	move.w	New_Position(a5),d0
	moveq	#PP_RelAbs,d1
	move.w	L_Reloc(a5),d2
	bsr	Set_Pour

        move.l 	d7,a4            	Debut de l'exploration
        move.l 	B_Reloc(a5),a6        	Table de relocation
	moveq	#-1,d5			Flags
; Programme CLI / AMOS
	move.l 	DebRel(a5),d7         	Base de toute les adresses
	move.l	d7,d6			Pour les librairies aussi
	moveq	#0,d4			Pas de flag $80000000
	cmp.b	#3,Flag_Type(a5)	Si programme CLI,
	beq.s	.Paflag
	bset	#31,d4			Flag librairies
	move.l	Lib_Debut(a5),d6	Base des routines librairie
.Paflag
RLoop  	move.b 	(a6)+,d0
        beq.s 	RFini
        cmp.b 	#1,d0
        bne.s 	P2b
        lea	508(a4),a4
        bra.s 	RLoop
RFini	addq.l	#1,d5
	bne	RFin
	move.l	d6,a4			Repositionne le programme
	bra.s	RLoop
; Affiche la position
P2b:    and.w	#$FF,d0
	lsl.w	#1,d0
        add.w 	d0,a4
        bsr 	GtoLong
        subq.l 	#4,a4
	moveq	#0,d1
	rol.l	#8,d0
	move.b	d0,d1
	lsr.l	#8,d0
	lsl.w	#1,d1
	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.Jsr
	bra.s	.Lib
	bra.s	.Chaine
	bra.s	.Label
; Simple JSR interne au programme
.Jsr
	IFNE	Debug			Verification: pas de jmp de la
	tst	d5			librarie vers le programme...
	bne.s	.Skip
	bsr	Err_Debug
.Skip
	ENDC
	sub.l	d7,d0
	bsr	OutLong
	subq.l	#4,a4
	bra.s	RLoop
; Trouve l'adresse d'une routine librairie / Relatif au debut libraries
.Lib	move.w	d0,d1			# Fonction
	swap	d0			# Librairie
	move.l	AdTokens(a5,d0.w),a0
	move.l	-LB_Size-4(a0,d1.w),d0	Adresse routine

	IFNE	Debug
	bmi.s	.Ok			Si non charge!
	bsr	Err_Debug
.Ok
	ENDC

	and.l	#$00FFFFFF,d0
	sub.l	d6,d0			Moins base des librairies
	or.l	d4,d0			Met bit31 a 1 pour un programme CLI
        bsr 	OutLong
        subq.l 	#4,a4
        bra.s 	RLoop
; Trouve l'adresse d'une chaine
.Chaine
	IFNE	Debug			Verification: pas de jmp de la
	tst	d5			librarie vers le programme...
	bne.s	.Skip1
	bsr	Err_Debug
.Skip1
	ENDC
	move.l	B_Chaines(a5),a0
	move.l	0(a0,d0.l),d0
	sub.l	d7,d0
	bsr	OutLong
	subq.l	#4,a4
	bra	RLoop
; Adresse d'un label
.Label
	IFNE	Debug			Verification: pas de jmp de la
	tst	d5			librarie vers le programme...
	bne.s	.Skip2
	bsr	Err_Debug
.Skip2
	ENDC
	move.l	B_Labels(a5),a0
	move.l	2(a0,d0.l),d0
	bmi	Err_Label
	sub.l	d7,d0
	bsr	OutLong
	subq.l	#4,a4
	bra	RLoop

RFin	bsr	End_Pour
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Mode NUMBERS / DEBUG . Entree, D0=numero de ligne
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Db_OutNumber
	tst.b	Flag_Numbers(a5)
	beq.s	.Out
	move.w	Cur_Line(a5),d0
	cmp.w	Old_Line(a5),d0
	bne.s	.Db
.Out	rts
.Db	moveq	#0,d2			Flag
	cmp.l	Db_Next(a5),a4		On a sorti du code?
	bne.s	.New
	move.l	Db_Prev(a5),a4		NON, on reste sur le dernier
	moveq	#1,d2			Flag, pas de nouvelle reloc
.New	move.l	a4,Db_Prev(a5)
	lea	DbCode(pc),a0
	move.w	(a0)+,d0
	bsr	OutWord
	move.w	Cur_Line(a5),d0
	move.w	d0,Old_Line(a5)
	bsr	OutWord
	addq.l	#2,a0
	move.w	(a0)+,d0
	bsr	OutWord
; Sortir la compilation sur le CLI?
	tst.b	Flag_OutNumbers(a5)
	beq.s	.NoBB
	movem.l	a0-a2/d0-d2,-(sp)
	move.l	B_Work(a5),a0
	moveq	#0,d0
	move.w	Cur_Line(a5),d0
	move.b	#"(",(a0)+
	bsr	longdec
	move.b	#")",(a0)+
;	move.l	a4,d0
;	bsr	longdec
;	move.b	#10,(a0)+
	clr.b	(a0)
	move.l	B_Work(a5),a0
	bsr	Str_Print
	movem.l	(sp)+,a0-a2/d0-d2
.NoBB
; Modes debug?
	tst.b	Flag_Debug(a5)
	beq.s	.End
	move.w	#L_CmpLineCLI,d0
	tst.w	d2
	bne.s	.Deja
	bsr	Do_JsrLibrary
	bra.s	.End
.Deja	addq.l	#4,a4
; Adresse prochaine
.End	move.l	a4,Db_Next(a5)
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	LINKER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Linker	moveq	#24,d0
	bsr	Mes_Print

;	Sort le RTS
; ~~~~~~~~~~~~~~~~~
	move.l	a4,Lib_Debut(a5)	Position de debut des librairies
	move.l	a4,Ad_Rts(a5)
	move.w	Crts(pc),d0
	bsr	OutWord

; 	Fichier de debuggage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	IFNE	Debug>1
	moveq	#F_Debug,d0
	lea	Debug_LibFile(pc),a0
	move.l	a0,d1
	bsr	F_OpenNewD1
	beq	Err_DiskError
	ENDC

;	Force le chargement des routines internes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	New_Position(a5),d0
	moveq	#PP_LibInternes,d1
	move.w	Lib_NInternes(a5),d2
	add.w	#32,d2
	bsr	Set_Pour

	bclr	#F_Externes,Flag_Libraries(a5)	Librairies internes seulement
	move.l	B_Script(a5),a6			Buffer des adresses des BRA
	move.l	AdTokens(a5),a2
	moveq	#0,d2
	move.w	Lib_DExternes(a5),d3
	lea	-LB_Size(a2),a2
.Loop	subq.l	#4,a2
	move.b	(a2),d0			Le Flag
	cmp.b	#2,d0			Une routine relative...
	bne.s	.Next
	move.l	d2,d0
	moveq	#0,d1
	bsr	Load_Routine
.Next	addq.w	#1,d2
	cmp.w	d2,d3
	bne.s	.Loop
	move.l	a4,Lib_FinInternes(a5)	Fin des routines internes
	move.l	a4,d0
	sub.l	Lib_Debut(a5),d0
	move.l	d0,Info_LLibrary(a5)

; 	Charge toutes les autres routines >>> plus rien!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	New_Position(a5),d0
	moveq	#PP_LibExternes,d1
	move.w	Lib_NExternes(a5),d2
	bsr	Set_Pour

	bset	#F_Externes,Flag_Libraries(a5)	Toutes les routines maintenant
	move.l	B_Script(a5),a6			Buffer des adresses des BRA

.ZLoop	moveq	#0,d1
	moveq	#0,d5
	lea	AdTokens(a5),a2
.MLoop	tst.l	(a2)
	beq.s	.MNext
.LLoop	move.l	(a2),a1			Exploration d'une librairie
	moveq	#0,d2
	move.w	LB_NRout(a1),d3
	lea	-LB_Size(a1),a1
	moveq	#0,d4
.RLoop	subq.l	#4,a1			Toutes les routines
	move.b	(a1),d0
	cmp.b	#1,d0
	bne.s	.RNext
	move.w	d2,d0
	bsr	Load_Routine
	addq.l	#1,d4			Une routine dans cette librairie
	addq.l	#1,d5			Une routine en tout!
.RNext	addq.w	#1,d2
	cmp.w	d2,d3
	bne.s	.RLoop
	tst.w	d4			Si nouvelle: encore un tour!
	bne.s	.LLoop
.MNext	addq.l	#4,a2			Encore une librairie?
	addq.w	#1,d1
	cmp.w	#26,d1
	ble.s	.MLoop
	tst.w	d5			On a encore charge une routine!
	bne.s	.ZLoop

	move.l	a4,d0
	sub.l	Lib_FinInternes(a5),d0
	move.l	d0,Info_ELibrary(a5)

; La fin
	bsr	End_Pour
	bsr	Return
	rts

;	Routine recursive de copie d'une routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0= 	# routine
;	D1=	# librairie
Load_Routine
	movem.l	a0-a2/d1-d7,-(sp)

	move.w	d1,d7
	bclr	#31,d7			Flag charger ou pas
	move.w	d0,d6
	bpl.s	.Paflag
	neg.w	d0
	move.w	d0,d6
	bset	#31,d7
.Paflag

; 	Actions particulieres sur la librarie principale
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lsl.w	#2,d1
	move.l	AdTokens(a5,d1.w),a2
	bne	Lib_Extension
; Une routine libraries externes?
	cmp.w	Lib_DExternes(a5),d0
	bcs.s	.NoExterne
	btst	#F_Externes,Flag_Libraries(a5)
	bne	Lib_Suite
	lsl.w	#2,d0
	neg.w	d0
	cmp.b	#1,-LB_Size-4(a2,d0.w)
	beq.s	.Nol
	move.b	#1,-LB_Size-4(a2,d0.w)	Met un flag
	addq.w	#1,Lib_NExternes(a5)	Nombre de routines
.Nol	moveq	#0,d0			Pas d'adresse de retour
	bra	Lib_Fin
.NoExterne
; Une routine float?
	cmp.w	Lib_DFloat(a5),d0
	bcs.s	.NoFloat
	cmp.w	Lib_FFloat(a5),d0
	bcc.s	.NoFloat
	tst.b	MathFlags(a5)		Pas de float >>> pointe sur un RTS
	beq	Lib_Rts
	bpl	Lib_Suite
	addq.w	#1,d0			Si double: prend la deuxieme
	bra	Lib_Suite
.NoFloat
; Une routine dependant du type (AMOS / normal)
	cmp.w	Lib_DType(a5),d0
	bcs.s	.NoType
	cmp.w	Lib_FType(a5),d0
	bcc.s	.NoType
	cmp.b	#3,Flag_Type(a5)	AMOS: prend la premiere
	beq	Lib_Suite
	addq.w	#1,d0			CLI: la deuxieme
	bra	Lib_Suite
.NoType	bra.s	Lib_Suite

;	Traitements particuliers des extensions: insertion des erreurs?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lib_Extension
	move.w	LB_NRout(a2),d2
	subq.w	#2,d2
	cmp.w	d0,d2			Avant derniere routine?
	bne.s	.Skip
	tst.b	Flag_Errors(a5)		Erreurs a charger?
	bne.s	.Skip
	addq.w	#1,d0			PAS D'ERREURS> derniere routine
.Skip	bra.s	Lib_Suite

; 	Met un RTS a la place de la routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lib_Rts	move.w	d6,d2
	lsl.w	#2,d2
	neg.w	d2
	move.l	-LB_Size-4(a2,d2.w),d1	Deja marquee
	bmi.s	Lib_Fin
	move.l	Ad_Rts(a5),d0
	bset	#31,d0
	move.l	d0,-LB_Size-4(a2,d2.w)
	bra.s	Lib_Fin

;	Charge la routine
; ~~~~~~~~~~~~~~~~~~~~~~~
Lib_Suite
	move.w	d0,d5			Routine a charger
	move.w	d6,d2			Numero reel de la routine
	lsl.w	#2,d2
	neg.w	d2
	move.l	-LB_Size-4(a2,d2.w),d0	Deja chargee
	bpl.s	Lib_Load
Lib_Fin	and.l	#$00FFFFFF,d0		Retrouve l'adresse
	bra	LRouX			C'est fini!
; Preparation du chargement
Lib_Load
	moveq	#0,d0			Zero indique PAS CHARGEE!
	tst.l	d7			Flag chargement
	bmi	LRouX

; Debuggage, sort le numero de la routine
	IFNE	Debug>1
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	B_Work(a5),a0
	moveq	#0,d0
	move.w	d7,d0
	bsr	longdec
	move.b	#":",(a0)+
	moveq	#0,d0
	move.w	d5,d0
	bsr	longdec
	move.b	#10,(a0)+
	move.l	B_Work(a5),d2
	move.l	a0,d3
	sub.l	d2,d3
	moveq	#F_Debug,d1
	bsr	F_Write
	bne	Err_DiskError
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC

	move.l	a4,-(sp)		Stocke l'adresse de la routine
	move.w	#-1,(a6)+		Marque la table pour les branchements
	moveq	#F_Libs,d1		Calcule le handle de la librarie a utiliser
	add.w	d7,d1			+ Numero lib
	tst.w	d7			Est la 1ere?
	bne.s	.Poke
	cmp.w	Lib_SizeInterne(a5),d6		Une librarie interne?
	bcc.s	.Poke
	moveq	#F_LibInterne,d1
.Poke	move.w	d1,H_Clib(a5)			Le handle
	move.w	d5,d0				Numero de la routine a charger!
	lsl.w	#2,d0
	neg.w	d0
	move.l	-LB_Size-4(a2,d0.w),d1
	and.l	#$00FFFFFF,d1
	move.l	d1,P_Clib(a5)			Position de debut
	move.w	LB_NRout(a2),R_Clib(a5)		Nombre de routines
	btst	#LBF_20,LB_Flags(a2)		Librairie 2.00?
	sne	d0
	move.b	d0,V_Clib(a5)			Met le flag!
	move.l	LB_LibSizes(a2),a0
	move.w	d5,d0
	lsl.w	#1,d0
	moveq	#0,d1
	move.w	0(a0,d0.w),d1
	lsl.w	#1,d1
	move.l	d1,T_Clib(a5)			Taille de la routine
; Affichage
	moveq	#25,d0				Met le "."
	bsr	Mes_Print
	bsr	Aff_Pour
; Boucle de recopie, D3 octets
	move.l	a4,-LB_Size-4(a2,d2.w)		Poke l'adresse de la routine
	bset	#7,-LB_Size-4(a2,d2.w)		Bit 7 � 1 >>> routine chargee
	moveq	#0,d4				P_CLIB-> D4
LRou0	bsr	Ld_Clib
LRou1	move.b	(a2),d0
	cmp.b	#C_Code1,d0
	beq	LRou10
LRou2	move.w	(a2)+,d0
	bsr	OutWord
	addq.l	#2,d4
LRouR	cmp.l	d3,d4
	bcs.s	LRou1
	cmp.l	T_Clib(a5),d4
	bcs.s	LRou0
; Un "GetP" a la fin? Le supprime!!!
	subq.l	#4,a4
	bsr	GtoLong
	cmp.l	#"GetP",d0
	bne.s	.Nogetp
	subq.l	#4,a4
; Un Ret_Int/Ret_Float/Ret_String a la fin?
	subq.l	#4,a4
	bsr	GtoLong
.Nogetp	cmp.l	Cretint(pc),d0
	beq.s	.Rts
	cmp.l	Cretfloat(pc),d0
	beq.s	.Rts
	cmp.l	Cretstring(pc),d0
	bne.s	LRou4
.Rts	subq.l	#4,a4
	move.w	Crts(pc),d0
	bsr	OutWord
; Branche les routines demandees
LRou4	move.w	-(a6),d6		Numero fonction / fin
	bmi	LRou6
; Un BRA juste a la fin d'une routine est supprime!
	move.l	-4(a6),d1		Adresse du saut
	addq.l	#2,d1			Apres le BSR
	cmp.l	a4,d1			Juste a la fin?
	bne.s	.Load
	move.w	d6,d0			La routine doit-elle etre chargee?
	move.w	d7,d1
	neg.w	d0
	bsr	Load_Routine
	tst.l	d0
	bne.s	.Load
	subq.l	#4,a4			OUI! on recule de 4 pour sauter le BRA
	clr.l	-4(a6)			Pas de saut!
	IFNE	Debug
	bsr	GtoWord			Verifie que l'on est bien sur un BRA!
	subq.l	#2,a4
	cmp.w	Cbra(pc),d0
	beq.s	.Ok
	illegal
.Ok
	ENDC
.Load	move.w	d6,d0			Sauvegarde
	move.w	d7,d1			Dans la librairie courante
	bsr	Load_Routine

	IFNE	Debug
	tst.l	d0			Debug, si routine externe!!
	bne.s	.Skip
	bsr	Err_Debug
.Skip
	ENDC
	move.l	a4,d2
	move.l	-(a6),d1
	beq.s	LRou4			ZERO: saut optimise!
	move.l	d1,a4			Adresse du saut
	sub.l	a4,d0
	cmp.l	#-32760,d0
	ble.s	LRou5
	cmp.l	#+32760,d0
	bge.s	LRou5
; Saut relatif OK!
	bsr	OutWord
	move.l	d2,a4
	bra.s	LRou4
; Saut en ARRIERE trop long: BRA-> JMP
LRou5
	IFNE	Debug
	lea	Debug_Jmp(pc),a0	Un signal si JMP!
	bsr	Str_Print
	ENDC

	move.l	d2,d0			1-> BRA sur le JMP
	sub.l	a4,d0
	cmp.l	#-32760,d0		Ne doit jamais arriver
	ble	Err_Syntax
	cmp.l	#+32760,d0
	bge	Err_Syntax
	bsr	OutWord
	move.l	d2,a4			2-> JMP sur la routine
	move.w	Cjmp(pc),d0
	bsr	OutWord
	bsr	Relocation
	move.w	d7,d0
	lsl.w	#2,d0
	swap	d0
	move.w	d6,d0
	lsl.w	#2,d0
	neg.w	d0
	or.l	#Rel_Libraries,d0
	bsr	OutLong
	bra	LRou4
; Ramene l'adresse de la routine
LRou6	move.l	(sp)+,d0
LRouX	movem.l	(sp)+,a0-a2/d1-d7
	rts

;	Traitement des instructions speciales
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
LRou10	move.w	(a2),d0
	move.b	d0,d2
	and.b	#$0F,d0
	cmp.b	#C_Code2,d0
	bne	LRou2
	and.w	#$00F0,d2
	lsr.w	#1,d2
	lea	LRout(pc),a1
	jmp	0(a1,d2.w)
; Table des sauts
LRout	bra	LRouJ			; 0 - RJmp / Rjmptable
	dc.w	$4ef9,0			JMP
	bra	LRouJ			; 1 - RJsr / Rjsrtable
	dc.w	$4eb9,0			JSR
	bra	LRouB			; 2 - RBra
	bra	LRout
	bra	LRouB			; 3 - RBsr
	bsr	LRout
	bra	LRouB			; 4 - RBeq
	beq	LRout
	bra	LRouB			; 5 - RBne
	bne	LRout
	bra	LRouB			; 6 - RBcs
	bcs	LRout
	bra	LRouB			; 7 - RBcc
	bcc	LRout
	bra	LRouB			; 8 - RBlt
	blt	LRout
	bra	LRouB			; 9 - RBge
	bge	LRout
	bra	LRouB			; 10- RBls
	bls	LRout
	bra	LRouB			; 11- RBhi
	bhi	LRout
	bra	LRouB			; 12- RBle
	ble	LRout
	bra	LRouB			; 13- RBpl
	bpl	LRout
	bra	LRouB			; 14- RBmi
	bmi	LRout
	bra	LRouD			; 15- RData / Ret_Inst

;-----> RJMP / RJSR
LRouJ	cmp.b	#C_CodeJ,2(a2)
	beq.s	.Rjsr
	cmp.b	#C_CodeT,2(a2)
	bne	LRou2
; Rjsrt / Rjmpt >>> simple JSR / JMP dans la librarie principale
	move.b	3(a2),d0
	cmp.b	#8,d0
	bcc.s	.Rlea
	moveq	#0,d1
	bra.s	.Jsr
; Rlea
.Rlea	subq.b	#8,d0
	cmp.b	#8,d0
	bcc	LRou2
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	GRlea(pc),d0
	bsr	OutWord
	moveq	#0,d1
	bra.s	.Adr
; Rjsr / Rjmp normaux
.Rjsr	moveq	#0,d1
	move.b	3(a2),d1
	cmp.b	#27,d1
	bcc	LRou2
; Poke l'appel
.Jsr	move.w	4(a1,d2.w),d0
	bsr	OutWord
.Adr	bsr	Relocation
	lsl.w	#2,d1
	move.w	d1,d0
	swap	d0
	move.w	4(a2),d0
	tst.b	V_Clib(a5)		Si librairie 1.3
	bne.s	.New
	bsr	Ext_OldLabel		Converti en ancien label
.New	lsl.w	#2,d0
	neg.w	d0
	or.l	#Rel_Libraries,d0
	bsr	OutLong
	addq.l	#6,a2
	addq.l	#6,d4
; Marque la librairie pour forcer le chargement
	move.l	AdTokens(a5,d1.w),d2
	beq	Err_ExtensionNotLoaded
	move.l	d2,a0
	tst.b	-LB_Size-4(a0,d0.w)
	bne	LRouR
	move.b	#1,-LB_Size-4(a0,d0.w)
	bra	LRouR

;-----> RBRA etc..
LRouB	move.w	2(a2),d1		Numero de la routine
	cmp.w	R_Clib(a5),d1		Superieur au # de routines ?
	bcc	LRou2
	move.w	4(a1,d2.w),d0		Sort le BRA
	bsr	OutWord
	move.l	a4,(a6)+		Adresse
	move.w	d1,(a6)+		Fonction
	addq.l	#4,a2			Saute dans le source
	addq.l	#4,d4			-4
	addq.l	#2,a4			Saute dans l'objet
	bra	LRouR

;-----> Instruction RDATA
LRouD	cmp.w	#C_CodeD,2(a2)
	bne	LRou2
	addq.l	#4,a2
	addq.l	#4,d4
	move.w	Cnop(pc),d0
	bsr	OutWord
	bsr	OutWord
LRouD1	cmp.l	d3,d4
	bcc	LRouD2
	move.w	(a2)+,d0
	bsr	OutWord
	addq.l	#2,d4
	bra.s	LRouD1
LRouD2	cmp.l	T_Clib(a5),d4
	bcc	LRou4
	bsr	Ld_Clib
	bra.s	LRouD1

;	Retrouve le nouveau label a partir des anciens
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ext_OldLabel
	movem.l	a0/d1,-(sp)
	lea	Ext_Convert(pc),a0
	bra.s	.In
.Loop	cmp.w	d0,d1
	beq.s	.Ok
	addq.l	#4,a0
.In	move.w	(a0),d1
	bne.s	.Loop
	bra	Err_Syntax
.Out	movem.l	(sp)+,a0/d1
	rts
.Ok	move.w	2(a0),d0
	bra.s	.Out
;	Table de conversion des labels AMOSPro 1.0 >>> AMOSPro 2.0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ext_Convert
	dc.w	1024,L_Error
	dc.w	1025,L_ErrorExt
	dc.w	207,L_Test_PaSaut
	dc.w	956,L_WaitRout
	dc.w	287,L_GetEc
	dc.w	46,L_Demande
	dc.w	432,L_RamFast
	dc.w	433,L_RamChip
	dc.w	434,L_RamFast2
	dc.w	435,L_RamChip2
	dc.w	436,L_RamFree
	dc.w	1100,L_Bnk.GetAdr
	dc.w	1101,L_Bnk.GetBobs
	dc.w	1102,L_Bnk.GetIcons
	dc.w	1103,L_Bnk.Reserve
	dc.w	1104,L_Bnk.Eff
	dc.w	1105,L_Bnk.EffA0
	dc.w	1106,L_Bnk.EffTemp
	dc.w	1107,L_Bnk.EffAll
	dc.w	1234,L_Bnk.Change
	dc.w	1121,L_Bnk.OrAdr
	dc.w	1119,L_Dsk.PathIt
	dc.w	1120,L_Dsk.FileSelector
	dc.w	1122,L_Dev.Open
	dc.w	1123,L_Dev.Close
	dc.w	1124,L_Dev.GetIO
	dc.w	1125,L_Dev.AbortIO
	dc.w	1126,L_Dev.DoIO
	dc.w	1127,L_Dev.SendIO
	dc.w	1128,L_Dev.CheckIO
	dc.w	1129,L_Dev.Error
	dc.w	0,0

;	Charge la routine dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ld_Clib	move.w	H_Clib(a5),d1		Le handle
	move.l	d4,d2			La position
	add.l	P_Clib(a5),d2		+ le debut
	moveq	#-1,d3			Depuis le debut
	bsr	F_Seek
	move.w	H_Clib(a5),d1
	move.l	B_DiskIn(a5),d2		Dans le buffer disque
	move.l	T_Clib(a5),d3		Maximum a charger
	sub.l	d4,d3
	clr.l	-(sp)
	cmp.l	#L_DiscIn,d3
	bcs.s	Ldcl1
	move.l	#L_DiscIn,d3
	move.l	#8,(sp)
Ldcl1	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a2
	add.l	d4,d3
	sub.l	(sp)+,d3
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

; Table des sauts pour les instructions particulieres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inst_Jumps
	dc.l	0			F8-
	dc.l	0			F9-
	bra	InGlobal		FA-Global (Nouvelle maniere)
	bra	InShared		FB-Shared
	bra	InDefFn			FC-Def Fn
	bra	InData			FD-Debut data
	bra	InEndProc		FE-Fin procedure
	bra	InProcedure		FF-Debut procedure
	dc.l	0			00-Instruction normale
	bra	Err_SyntaxLGoto		01-Syntax error (debug pour LGOTO!)
	bra	InRem			02-Rem
	bra	InSetBuffer		03-Set Buffer
	bra	InSetDouble		04-Set Double Precision
	bra	InSetStack		05-Set Stack ***
	bra	InVariable		06-Variable
	bra	InLabel			07-Un label
	bra	InProcedureCall		08-Un appel de procedure
	bra	InDim			09-DIM
	bra	InPrint			0A-Print
	bra	InHPrint		0B-Print #
	bra	InInput			0C-Input
	bra	InInputD		0D-Input #
	bra	InDec			0E-Dec
	bra	InProc			0F-Proc
	dc.l	0			10-Amos Lock (debugging)
	bra	InPalettes		11-Default Palette
	bra	InPalettes		12-Palette
	bra	InRead			13-Read
	bra	InRestore		14-Restore
	bra	InChannel		15-Channel
	bra	InInc			16-Inc/Dec
	bra	InAdd2			17-Add 2 parametres
	bra	InPoly			18-Polyline/Gon
	bra	InField			19-Field
	bra	InCall			1A-Call
	bra	InMenu			1B-Menu
	bra	InMenuDel		1C-Menu Del
	bra	InSetMenu		1D-Set Menu
	bra	InMenuKey		1E-Menu Key
	bra	InMenuFlags		1F-Menu diverse
	bra	InFade			20-Fade
	bra	InSort			21-Sort
	bra	InSwap			22-Swap
	bra	InFollow		23-Follow
	bra	InSetAccessory		24-Set Accessory
	bra	InTrap			25-Trap
	bra	InStruc			26-Struc
	bra	InStrucD		27-Struc$
	bra	InExtension		28-Token d'extension
	dc.l	0			29-Instruction AMOSPro
	dc.l	0			2A-Instruction AMOSPro deja testee
	dc.l	0			2B-Variable reservee
	dc.l	0			2C-Variable reservee AMOSPro
	dc.l	0			2D-Instruction normale deja testee
	bra	Err_Syntax		2E-LIBRE
	bra	Err_Syntax		2F-Fin de ligne
	bra	InFor			30-For
	bra	InNext			31-Next
	bra	InRepeat		32-Repeat
	bra	InUntil			33-Until
	bra	InWhile			34-While
	bra	InWend			35-Wend
	bra	InDo			36-Do
	bra	InLoop			37-Loop
	bra	InExit			38-Exit
	bra	InExitIf		39-Exit If
	bra	InIf			3A-If
	bra	InElse			3B-Else
	bra	InElseIf		3C-ElseIf
	bra	InNull			3D-EndIf
	bra	InGoto			3E-Goto
	bra	InGosub			3F-Gosub
	bra	InOnError		40-OnError
	bra	InOnBreak		41-OnBreak
	bra	InOnMenu		42-OnMenu
	bra	InOn			43-On
	bra	InResume		44-Resume
	bra	InResumeLabel		45-ResLabel
	bra	InPopProc		46-PopProc
	bra	InEvery			47-Every
	bra	InLPrint		48-LPrint
	bra	InLineInput		49-Line Input
	bra	InLineInputD		4A-Line Input #
	bra	InMid3			4B-Mid3
	bra	InMid2			4C-Mid2
	bra	InLeft			4D-Left
	bra	InRight			4E-Right
	bra	InAdd4			4F-Add 4 params
	bra	InDialogs		50-Instruction dialog
	bra	InDir			51-Instruction DIR
	bra	InNull			52-Then
	bra	InReturn		53-Return
	bra	InPop			54-Pop
	bra	In_apml_		55-Procedure langage machine
	bra	InBsetRor		56-Bset/Bchg/Ror///
	bra	Err_AlreadyCompiled	57-APCmp Call
InRien	illegal
InNull	rts
; 	DEBUG pour LGOTO
; ~~~~~~~~~~~~~~~~~~~~~~
Err_SyntaxLGoto
	cmp.w	#_TkLGo,d0
	beq	InLabelGoto
	bra	Err_Syntax

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Appel d'une instruction d'extension
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InExtension
; - - - - - - - - - - - - -
	bsr	GetWord
	lsr.w	#8,d0
	move.w	d0,d1
	lsl.w	#2,d0
	move.l	AdTokens(a5,d0.w),d0
	beq	Err_ExtensionNotLoaded
	move.l	d0,a0
	bsr	GetWord
; Est-ce un instruction de controle COMPILER?
	cmp.w	#Ext_Nb,d1
	beq.s	.Comp
; Recupere les parametres + branche
.PaComp	bsr	OutLea
	move.l	a0,a1
	lea	0(a0,d0.w),a0			Pointe l'instruction
	move.w	(a0),d0				Prend la fonction
	btst	#LBF_20,LB_Flags(a1)		Si 2.0 on se branche
	bne.s	.New
; Ancienne: pousser le parametre / sauver les registres
	movem.l	a0/d0/d1,-(sp)
	addq.l	#4,a0			Saute les pointeurs
.Par	tst.b	(a0)+			Pointe les parametres
	bpl.s	.Par
	move.b	(a0)+,d0		Ne veut que des instructions!
	cmp.b	#"I",d0
	bne	Err_Syntax
	bsr	InParamsPush		Parametres dans la pile
	move.w	#L_SaveRegs,d0		Sauve les registres
	bsr	Do_JsrLibrary
	movem.l	(sp)+,a0/d0/d1		Appelle la fonction
	bsr	Do_JsrExtLibrary
	move.w	#L_LoadRegs,d0		Recharge les registres
	bra	Do_JsrLibrary
; Nouvelle: simple appel
.New	movem.l	a0/d1,-(sp)
	bsr	Get_InParams
	movem.l	(sp)+,a0/d1
	bra	Do_JsrExtLibrary

; Une instruction de controle du compiler?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Comp	cmp.w	#Ext_TkCmp,d0
	beq	Err_AlreadyCompiled
	cmp.w	#Ext_TkCOp,d0
	beq	COpt
	cmp.w	#Ext_TkTstOn,d0
	beq	CTstOn
	cmp.w	#Ext_TkTstOf,d0
	beq	CTstOf
	cmp.w	#Ext_TkTst,d0
	beq	CTst
	bra	.PaComp
;-----> CONTROLE COMPILATEUR
CTstOn	clr.b	Flag_NoTests(a5)
	rts
CTstOf	move.b	#-1,Flag_NoTests(a5)
	rts
CTst
	IFNE	Debug=2
	illegal
	move.w	Cillegal(pc),d0
	bsr	OutWord
	rts
	ENDC
	move.w	#L_Test_Normal,d0
	bra	Do_JsrLibrary
; CompOpt: saute la chaine
; ~~~~~~~~~~~~~~~~~~~~~~~~
COpt	bsr	StockOut
	bsr	New_Evalue
	bra	RestOut


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Appel d'instruction standard
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InNormal
; - - - - - - - - - - - - -
	lea	0(a0,d0.w),a0		Pointe l'instruction
	move.w	(a0),d0			D0= # de fonction
InNormal2
	bsr	OutLea
	bsr	Get_InParams
	bsr	Do_JsrLibrary
	rts

;	Recupere les parametres d'une fonction standart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_InParams
	move.w	d0,-(sp)
	addq.l	#4,a0			Saute les pointeurs
.Par	tst.b	(a0)+			Pointe les parametres
	bpl.s	.Par
	move.b	(a0)+,d0
	cmp.b	#"V",d0			Une variable reserve?
	beq.s	.VRes
	cmp.b	#"I",d0
	bne	Err_Syntax
; Une instruction
	bsr	InParams
.Out	move.w	(sp)+,d0
	rts
; Variable reservee en instruction
.VRes	move.b	(a0)+,d0
	and.w	#$00FE,d0		Ne garde que 0-Entier 2-Chaine
	sub.w	#"0",d0
	move.w	d0,-(sp)		Le type desire
	tst.b	(a0)			Des parametres?
	bmi.s	.VPar
	addq.l	#2,a6			Saute la parenthese!
	bsr	InParamsPush		Evalue les parametres
.VPar	addq.l	#2,a6			Saute le egal
	move.w	(sp)+,Type_Voulu(a5)	Le type que l'on veut!
	bsr	Evalue_Voulu		Evalue avec le bon type
	bsr	Optimise_D2
	move.w	(sp)+,d0
	rts

;	ROUTINE > recupere les parametres standards instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InParamsPush
	move.w	#1,-(sp)		Pousser le dernier
	bra.s	InP
InParams
	clr.w	-(sp)			Ne pas pousser!
InP
	move.b	(a0)+,d0		Prend le parametre
	bmi.s	.Exit
.Loop	move.l	a0,-(sp)
	and.w	#$00FF,d0
	sub.w	#"0",d0
	move.w	d0,Type_Voulu(a5)	Le type desire
	bsr	Evalue_Voulu		Va evaluer!
	bsr	Optimise_D2
	move.l	(sp)+,a0
	tst.b	(a0)+			Saute le separateur
	bmi.s	.Push
	bsr	Push_D2			Pousse le parametre
	addq.l	#2,a6			Saute le separateur en vrai
	move.b	(a0)+,d0		Parametre suivant
	bra.s	.Loop
.Push	tst.w	(sp)			Pousser le dernier?
	beq.s	.Exit
	bsr	Push_D2
; Sortie
.Exit	addq.l	#2,sp
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Appel de fonction standard
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FnNormal
; - - - - - - - - - - - - -
	lea	0(a0,d0.w),a0		Pointe la fonction
	move.w	2(a0),d0		D0= # de fonction
FnNormal2
	bsr	Get_FnParams
	bsr	Do_JsrLibrary
	bra	Set_F_Autre
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Appel de fonction extension
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FnExtension
; - - - - - - - - - - - - -
	bsr	GetWord
	lsr.w	#8,d0
	move.w	d0,d1
	lsl.w	#2,d0
	move.l	AdTokens(a5,d0.w),d0
	beq	Err_ExtensionNotLoaded
	move.l	d0,a0
	move.l	d0,a1
	bsr	GetWord
	lea	0(a0,d0.w),a0		Pointe la fonction
	move.w	2(a0),d0		Prend le #
	btst	#LBF_20,LB_Flags(a1)	Une nouvelle librarie?
	bne.s	.New
; Ancienne: pousser le parametre / sauver les registres
	movem.l	a0/d1,-(sp)
	bsr	Get_FnParamsPush	Pousser le dernier param
	movem.l	(sp)+,a0/d1
	move.w	d0,-(sp)		Sauver les registres
	move.w	#L_SaveRegs,d0
	bsr	Do_JsrLibrary
	move.w	(sp)+,d0
	bsr	Do_JsrExtLibrary	Appeler la fonction
	move.w	#L_LoadRegs,d0		Recharger les registres
	bsr	Do_JsrLibrary
	bra	Set_F_Autre
; Nouvelle: simple appel
.New	movem.l	a0/d1,-(sp)
	bsr	Get_FnParams
	movem.l	(sp)+,a0/d1
	bsr	Do_JsrExtLibrary
	bra	Set_F_Autre

;	Recupere les parametres d'une fonction standart
;	D2-D4 contient le dernier parametre / Change le # fonction eventuellement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_FnParamsPush
	move.w	#1,-(sp)		Pousser le dernier
	bra.s	InFnP
Get_FnParams
	clr.w	-(sp)			Ne pas pousser le dernier
InFnP
	move.w	d0,-(sp)
	move.w	Type_Voulu(a5),-(sp)
	move.w	Type_Eu(a5),-(sp)	Pour fonctions ABS / INT etc...
	clr.w	Type_Eu(a5)		Qui retournent le type d'entree
	addq.l	#4,a0			Saute les pointeurs
.Par	tst.b	(a0)+			Pointe les parametres
	bpl.s	.Par
	move.b	(a0)+,d2
	cmp.b	#"V",d2			Une variable reserve?
	bne.s	.NoVar
	move.b	(a0)+,d2
.NoVar	and.w	#$00FF,d2		Type retourne
	sub.b	#"0",d2
	move.b	(a0)+,d0		Encore des parametres?
	bmi.s	.NoPar
	move.w	d2,-(sp)
; Recolte des parametres
	addq.l	#2,a6			Saute la parenthese
.Loop	move.l	a0,-(sp)
	and.w	#$00FF,d0
	sub.w	#"0",d0
	move.w	d0,Type_Voulu(a5)	Le type desire
	lsl.w	#1,d0
	jmp	.Jmp(pc,d0.w)
.Jmp	bra.s	.Normal			0- Entier
	bra.s	.Normal			1- Float
	bra.s	.Normal			2- String
	bra.s	.EntChaine		3- Entier ou chaine
	bra.s	.EntFloat		4- Entier/Float >>> change la fonction
	bra.s	.Normal			5- Angle
.EntChaine
	bsr	Evalue_Voulu
	bsr	Optimise_D2
	move.w	d2,Type_Eu(a5)		Le type de l'operateur
	bra.s	.Suite
.EntFloat
	bsr	Evalue_Voulu
	bsr	Optimise_D2
	add.w	d2,4+2*3(sp)		Change le numero d'appel
	move.w	d2,Type_Eu(a5)		Le type de l'operateur
	bra.s	.Suite
.Normal
	bsr	Evalue_Voulu
	bsr	Optimise_D2
.Suite
	move.l	(sp)+,a0
	tst.b	(a0)+			Saute le separateur
	bmi.s	.Fini			Fini?
	bsr	Push_D2			Pousse le parametre
	addq.l	#2,a6			Saute le separateur en vrai
	move.b	(a0)+,d0		Parametre suivant
	bra.s	.Loop
.Fini
	tst.w	4*2(sp)			Pousser le dernier?
	beq.s	.NoPush
	bsr	Push_D2			Pousse le parametre
.NoPush
	move.w	(sp)+,d2
	cmp.w	#4,d2			Fonction speciale (ABS/INT)
	bne.s	.NoPar
	move.w	Type_Eu(a5),d2
.NoPar
	move.w	(sp)+,Type_Eu(a5)
	move.w	(sp)+,Type_Voulu(a5)
	move.w	(sp)+,d0
	addq.l	#2,sp
	rts

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

;		Script d'evaluation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
S_Cst1		rs.l	1		0
S_Cst2		rs.l	1		4
S_EvaCompteur	rs.w	1		8
S_Var		rs.w	1		10
S_Pile		rs.l	1		12
S_a3		rs.l	1		14
S_a4		rs.l	1		16
S_OldRel	rs.l	1		20
S_LibRel	rs.l	1		24
S_LibOldRel	rs.l	1		28
S_Chaines	rs.l	1		32

;		Flags des fonctions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F_Autre		equ	0		Autre
F_Locale	equ	2		Variable locale
F_Globale	equ	4		Variable globale
F_Tableau	equ	6		Variable tableau
F_MoveE		equ	8		MoveE
F_MoveF		equ	10		MoveF
F_MoveD		equ	12		MoveD
F_MoveS		equ	14		MoveS

F_Empile	equ	30		L'operateur vient d'etre empile
F_Depile	equ	29		L'operateur vient d'etre depile
F_Drapeaux	equ	28		Les drapeaux sont positionnes

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EXPENTIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Fn_Expentier
	addq.l	#2,a6
Expentier
	bsr	New_Evalue
	tst.b	d2
	beq.s	.Skip
	bsr	D2_Entier
.Skip	bsr	Optimise_D2
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EVALUATION AVEC TYPE VOULU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Fn_Evalue_Voulu
	addq.l	#2,a6
Evalue_Voulu
	bsr	New_Evalue
	move.w	Type_Voulu(a5),d0
	cmp.b	d0,d2			Le bon type?
	bne.s	.Conv
	rts
.Conv	lsl.w	#2,d0
	jmp	.Jmp(pc,d0.w)
.Jmp	bra	D2_Entier		Veut un entier
	bra	D2_Float		Veut un float
	bra	D2_Bug			Impossible, mais bug AMOSPro!
	bra	D2_Indifferent		Chaine ou Entier
	bra	D2_EntierFloat		Entier ou Float
	bra	D2_Angle		Un angle
D2_Indifferent
	cmp.b	#1,d2			Soit une chaine
	beq	D2_Entier		Soit un entier
	rts
D2_EntierFloat
	rts				Rien a faire, car teste!
D2_Bug	moveq	#2,d2			Retourne une fausse chaine !
	rts
D2_Angle
	bsr	MathFloat
	tst.b	d2
	bne.s	.Skip
	bsr	D2_Float
.Skip	move.w	#L_FFAngle,d0
	bsr	Do_JsrLibrary
	bsr	Set_F_Autre
	rts

MathSimple
	or.b	#%00000001,MathFlags(a5)
	rts
MathFloat
	or.b	#%00000011,MathFlags(a5)
	rts
MathDouble
	or.b	#%10000011,MathFlags(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EVALUATION D'EXPRESSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Fn_New_Evalue
	addq.l	#2,a6
New_Evalue
	move.w	#$7FFF,d0
	bra.s	Eva1

Eva0	bsr	Push_D2			Pousse l'operande precedent
	movem.l	d2-d4,-(sp)

Eva1	move.w	d0,-(sp)
	addq.w	#1,EvaCompteur(a5)	Un operande de plus
	bsr	S_Script_D2		Stocke tout!

	clr.w	-(sp)			Signe
EvaS	bsr	GetWord			Prend la fonction
	bmi.s	EvaM			Signe moins?
	move.l	AdTokens(a5),a0
	move.w	2(a0,d0.w),d1		Prend la fonction
	bmi.s	.Spe			Speciale???
	bsr	FnNormal		Non, routine generale
	bra.s	.Sui
.Spe	neg.w	d1			Inverse le code
	lea	Func_Jumps(pc),a1	= pointeur sur la table
	jsr	0(a1,d1.w)
.Sui	tst.w	(sp)+			Changement de signe?
	beq.s	Eva2
	bsr	Neg_D2			Passe en negatif

Eva2	bsr	GetWord			Operateur suivant
	cmp.w	(sp),d0
	bhi.s	Eva0
	subq.l	#2,a6
	move.w	(sp)+,d1		Fini?
	bpl.s	Eva3
	movem.l (sp)+,d5-d7
	lea	OP_Jmp(pc),a0		Branche!
	jsr	0(a0,d1.w)		Effectue l'operateur
	bra.s	Eva2

Eva3	move.w	d0,Last_Token(a5)	Dernier token de l'evaluation
	cmp.w	#_TkPar2,d0
	bne.s	Eva4
	addq.l	#2,a6

Eva4	rts

; Signe moins
EvaM	addq.w	#1,(sp)
	bra.s	EvaS

; 	Rend negatif l'operateur actuel D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Neg_D2	move.l	d4,a0
	jmp	.Jmp(pc,d3.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.Autre			Une variable locale
	bra.s	.Autre			Une variable globale
	bra.s	.Autre			Une variable tableau
	bra.s	.MoveE			Un move.l entier
	bra.s	.MoveF			Un move.l float
	bra.s	.MoveD			Un move.l double
	bra.s	.Autre			Un move.l string
	nop
; Pas de cas particulier: NEG.L/BCHG
.Autre	moveq	#F_Autre,d3
	tst.b	d2
	bne.s	.Flt
	move.w	Cnegd3(pc),d0
	bra	OutWord
.Flt	tst.b	MathFlags(a5)
	bmi.s	.Dble
	move.l	Cbchg7d3(pc),d0
	bra	OutLong
.Dble	move.l	Cbchg31d3(pc),d0
	bra	OutLong
; Un move.l #ENTIER,d3 >>> change la constante
.MoveE	neg.l	S_Cst1(a0)
	move.l	S_Cst1(a0),d0
	subq.l	#4,a4
	bra	OutLong
; Une constante float
.MoveF	move.l	S_Cst1(a0),d0
	bchg	#7,d0
	move.l	d0,S_Cst1(a0)
	subq.l	#4,a4
	bra	OutLong
; Une constante double
.MoveD	move.l	S_Cst1(a0),d0
	bchg	#31,d0
	move.l	d0,S_Cst1(a0)
	lea	-6+2(a4),a4
	bsr	OutLong
	rts

; 	Optimise le dernier operande, D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Optimise_D2
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	d4,a0
	jmp	.Jmp(pc,d3.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.Autre			Une variable locale
	bra.s	.Autre			Une variable globale
	bra.s	.Autre			Une variable tableau
	bra.s	.MoveE			Un move.l entier
	bra.s	.Autre			Un move.l float
	bra.s	.Autre			Un move.l double
	bra.s	.Autre			Un move.l string
.MoveE	move.l	S_Cst1(a0),d1
	cmp.l	#-127,d1
	blt.s	.Autre
	cmp.l	#127,d1
	bgt.s	.Autre
	bsr	S_ReposD2		Remet sur D2
	move.w	Cmvqd3(pc),d0
	move.b	d1,d0
	bsr	OutWord
	bsr	Set_F_Autre
.Autre	movem.l	(sp)+,a0/a1/d0/d1
	rts

; 	Pousse l'operande actuel D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Push_D2:
	movem.l	d0-d1/a0-a1,-(sp)
	btst	#F_Depile,d2
	bne	.Depile
	move.l	d4,a0
	jmp	.Jmp(pc,d3.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.VLocal			Une variable locale
	bra.s	.VGlobal		Une variable globale
	bra.s	.VTableau		Une variable tableau
	bra.s	.MoveE			Un move.l entier
	bra.s	.MoveF			Un move.l float
	bra.s	.MoveD			Un move.l double
	bra.s	.MoveS			Un move.l string
	nop
; Une fonction: on pousse simplement
.Autre	cmp.b	#1,d2			Si double
	bne.s	.Skip
	tst.b	MathFlags(a5)
	bmi.s	.MoveD
.Skip	bset	#F_Empile,d2		Le flag
	move.l	a4,S_Pile(a0)		L'adresse dans le script
	move.w	Cmvd3ma3(pc),d0
	bsr	OutWord
	bra.s	.Out
; Un move.l #,d3 >>> move.l #,-(a3)
.MoveS
.MoveF
.MoveE	subq.l	#6,a4
	move.l	a4,S_Pile(a0)
	move.w	Cmvima3(pc),d0
	bsr	OutWord
	addq.l	#4,a4
	bra.s	.Out
; Variable double: movem.l d3-d4,-(a3)
.MoveD	bset	#F_Empile,d2		Le flag
	move.l	a4,S_Pile(a0)		L'adresse dans le programme
	move.l	Cmvmd3d4ma3(pc),d0
	bsr	OutLong
	bra.s	.Out
; Une variable locale: transforme le move.l V(a6),d3 en move.l V(a6),-(a3)
.VLocal	subq.l	#4,a4
	move.l	a4,S_Pile(a0)
	move.w	Cmv2a6ma3(pc),d0
	bsr	OutWord
	addq.l	#2,a4
	bra.s	.Out
; Une variable globale: transforme le move.l V(a0),d3 en move.l V(a0),-(a3)
.VGlobal
	subq.l	#4,a4
	move.l	a4,S_Pile(a0)
	move.w	Cmv2a0ma3(pc),d0
	bsr	OutWord
	addq.l	#2,a4
	bra.s	.Out
; Une variable tableau: transforme le move.l (a0),d3 en move.l (a0),-(a3)
.VTableau
	subq.l	#2,a4
	move.l	a4,S_Pile(a0)
	move.w	Cmv0a0ma3(pc),d0
	bsr	OutWord
	bra.s	.Out
; On vient de depiler l'operande precedent: facile!
.Depile	bclr	#F_Depile,d2		Plus depile
	subq.l	#2,a4			Recule le pointeur de 2!
	cmp.b	#1,d2
	bne.s	.Out
	tst.b	MathFlags(a5)		Si double, on recule de 4!
	bpl.s	.Out
	subq.l	#2,a4
; Sortie
.Out	movem.l	(sp)+,d0-d1/a0-a1
	rts

;	Depile l'operande D5 efficacement (simple changement dans le code)
;	Positionne juste apres le code depile, ie en D2 si ca marche!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Pull_D5:
	movem.l	a0/d0,-(sp)
	btst	#F_Empile,d5		Depile, on peut si possible
	bne.s	.Try
	tst.w	d6			Une fonction >>> Non
	beq.s	.Non
.Try	bsr	S_ReposD5
	beq.s	.Non
	btst	#F_Empile,d5		Parametre empile?
	bne.s	.Depile
	jmp	.Jmp(pc,d6.w)
.Jmp	bra.s	.Non			Une fonction
	bra.s	.VLocal			Une variable locale
	bra.s	.VGlobal		Une variable globale
	bra.s	.VTableau		Une variable tableau
	bra.s	.MoveE			Un move.l entier
	bra.s	.MoveF			Un move.l float
	bra.s	.MoveD			Un move.l double
	bra.s	.MoveS			Un move.l string
.Non	moveq	#0,d0			Impossible!
	bra.s	.Out
.Oui	bsr	S_ReposD2		Met en D2
.Oui2	moveq	#1,d0
.Out	movem.l	(sp)+,a0/d0
	rts
.VLocal
	move.w	Cmv2a6d3(pc),d0
	bra.s	.VFini
.VGlobal
	move.w	Cmv2a0d3(pc),d0
	bra.s	.VFini
.VTableau
	move.w	Cmv0a0d3(pc),d0
.VFini	move.l	S_Pile(a0),a4		Adresse du move.l XX,-(a3)
	bsr	OutWord
	bra.s	.Oui
.MoveE
.MoveS
.MoveF	move.w	Cmvid3(pc),d0
	bsr	OutWord
	bra.s	.Oui
.MoveD
	move.w	Cmvid4(pc),d0
	bsr	OutWord
	addq.l	#4,a4
	move.w	Cmvid3(pc),d0
	bsr	OutWord
	bra.s	.Oui
.Depile
	bsr	S_ReposD2		Juste apres le NOP
	subq.l	#2,a4			On recule dessus!
	cmp.b	#1,d5			Un float?
	bne.s	.Oui2
	tst.b	MathFlags(a5)		Un double?
	bpl.s	.Oui2
	subq.l	#2,a4			C'est un movem!
	bra.s	.Oui2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	LES OPERATEURS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;						Table des operateurs
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bra	OP_Xor
	dc.b 	" xor"," "+$80,"O00",-1
	bra	OP_Or
	dc.b 	" or"," "+$80,"O00",-1
	bra	OP_And
	dc.b 	" and"," "+$80,"O00",-1
	bra	OP_Diff
	dc.b 	"<",">"+$80,"O20",-1
	bra	OP_Diff
	dc.b 	">","<"+$80,"O20",-1
	bra	OP_InfEg
	dc.b 	"<","="+$80,"O20",-1
	bra	OP_InfEg
	dc.b 	"=","<"+$80,"O20",-1
	bra	OP_SupEg
	dc.b 	">","="+$80,"O20",-1
	bra	OP_SupEg
	dc.b 	"=",">"+$80,"O20",-1
	bra	OP_Egal
	dc.b 	"="+$80,"O20",-1
	bra	OP_Inf
	dc.b 	"<"+$80,"O20",-1
	bra	OP_Sup
	dc.b 	">"+$80,"O20",-1
	bra	OP_Plus
	dc.b 	"+"+$80,"O22",-1
	bra	OP_Moins
	dc.b 	"-"+$80,"O22",-1
	bra	OP_Modulo
	dc.b 	" mod"," "+$80,"O00",-1
	bra	OP_Multiplie
	dc.b 	"*"+$80,"O00",-1
	bra	OP_Divise
	dc.b 	"/"+$80,"O00",-1
	bra	OP_Puissance
	dc.b 	"^"+$80,"O00",-1
	even
OP_Jmp	dc.l 	0

;	Operateur PLUS, optimise!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Plus
	bsr	OP_Compat		Meme type
	lea	.Plus(pc),a0
	bra	OP_General
; Tableau de branchement aux fonction PLUS
;    \ 	B=	A VlVgVtMeMfMdMs
; A   \	        | | | | | | | |
.Plus	dc.b	0,4,5,6,2,0,0,0		A= Autre
	dc.b	0,4,5,6,2,0,0,0		A= Variable locale
	dc.b	0,4,5,6,2,0,0,0		A= Variable globale
	dc.b	0,4,5,6,2,0,0,0		A= Variable tableau
	dc.b	3,4,5,6,1,0,0,0		A= MoveE
	dc.b	0,0,0,0,0,0,0,0		A= MoveF
	dc.b	0,0,0,0,0,0,0,0		A= MoveD
	dc.b	0,0,0,0,0,0,0,0		A= MoveS
	bra	.F0			La fonction standart
	bra	.F1			Deux constantes entieres
	bra	.F2			"B" est une constante entiere
	bra	.F0			"A" est une constante entiere
	bra	.F4			"B" est une variable locale
	bra	.F5			"B" est une variable globale
	bra	.F0			"B" est une variable tableau
; Appel de la fonction standart
.F0	move.w	d2,d0
	beq.s	.F0a
	add.w	#L_PlusF-1,d0		1ere si chaine
	bsr	Do_JsrLibrary		2eme si chaine
	bra	Set_F_Autre
.F0a	move.w	Cadda3pd3(pc),d0
	bsr	OutWord
	bra	Set_F_Autre
; Deux constantes entieres
.F1	move.l	S_Cst1(a0),d0		OK! on additionne
	add.l	S_Cst1(a1),d0
	bsr	S_ReloadD5		Retourner en arriere?
	bne	Out_MoveE		Possible, on fabrique le code
	bsr	ReOut_ConstD5		On change "A"
	bsr	S_ReposD2		Retourner avant B, toujours possible
	bset	#F_Depile,d2		On vient de depiler!
	move.l	a4,S_Pile(a1)
	move.w	Cmva3pd3(pc),d0		move.l	(a3)+,d3
	bsr	OutWord
	bra	Set_F_Autre
; B est une constante entiere
.F2	bsr	Pull_D5			Depiler efficacement
	beq.s	.F0			NON: add.l (a3)+,d3
	move.l	S_Cst1(a1),d1		OUI:
	beq.s	.F2s			Quelque chose a additionner?
	bmi.s	.F2m
	cmp.l	#8,d1			addq possible?
	bhi.s	.F2n
	move.w	Caddqd3(pc),d0		Oui!
	and.w	#%1111000111111111,d0
	bra.s	.F2x
.F2m	cmp.l	#-8,d1			subq possible?
	blt.s	.F2n
	neg.l	d1
	move.w	Csubqd3(pc),d0
	and.w	#%1111000111111111,d0
.F2x	and.w	#$07,d1
	lsl.w	#8,d1
	lsl.w	#1,d1
	or.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre
.F2n	move.w	Caddid3(pc),d0
	bsr	OutWord
	move.l	d1,d0
	bsr	OutLong
	bra	Set_F_Autre
.F2s	move.l	d7,d4			On a depile efficacement
	move.l	d6,d3
	move.l	d5,d2
	rts
; B est une variable locale
.F4	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1		Le delta de la variable
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.w	Cadd2a6d3(pc),d0	Ressort la variable
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre
; B est une variable globale
.F5	tst.w	d2			On veut des entiers
	bne	.F0
	move.w	S_Var(a1),d1		Le delta de la variable
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.w	Cmvd7a0(pc),d0		Resort la variable
	bsr	OutWord
	move.w	Cadd2a0d3(pc),d0
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre

;	Operateur MOINS, optimise!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Moins
	bsr	OP_Compat		Meme type
	lea	.Table(pc),a0
	bra	OP_General
; Tableau de branchement aux fonction MOINS
;    \ 	B=	A VlVgVtMeMfMdMs
; A   \	        | | | | | | | |
.Table	dc.b	0,4,5,6,2,0,0,0		A= Autre
	dc.b	0,4,5,6,2,0,0,0		A= Variable locale
	dc.b	0,4,5,6,2,0,0,0		A= Variable globale
	dc.b	0,4,5,6,2,0,0,0		A= Variable tableau
	dc.b	3,4,5,6,1,0,0,0		A= MoveE
	dc.b	0,0,0,0,0,0,0,0		A= MoveF
	dc.b	0,0,0,0,0,0,0,0		A= MoveD
	dc.b	0,0,0,0,0,0,0,0		A= MoveS
	bra	.F0			0 La fonction standart
	bra	.F1			1 Deux constantes entieres
	bra	.F2			2 "B" est une constante entiere
	bra	.F0			3 "A" est une constante entiere
	bra	.F4			4 "B" est une variable locale
	bra	.F5			5 "B" est une variable globale
	bra	.F0			6 "B" est une variable tableau
; Appel de la fonction standart
.F0	move.w	d2,d0
	beq.s	.F0a
	add.w	#L_MoinsF-1,d0		1ere si float
	bsr	Do_JsrLibrary		2eme si chaine
	bra	Set_F_Autre
.F0a	move.w	Csuba3pd3(pc),d0
	bsr	OutWord
	move.w	Cnegd3(pc),d0
	bsr	OutWord
	bra	Set_F_Autre
; Deux constantes entieres
.F1	move.l	S_Cst1(a0),d0		OK! on soustraie
	sub.l	S_Cst1(a1),d0
	bsr	S_ReloadD5		Retourner en arriere?
	bne	Out_MoveE		Possible, on fabrique le code
	bsr	ReOut_ConstD5		On change "A"
	bsr	S_ReposD2		Retourner avant B, toujours possible
	bset	#F_Depile,d2		On vient de depiler!
	move.l	a4,S_Pile(a1)
	move.w	Cmva3pd3(pc),d0		move.l	(a3)+,d3
	bsr	OutWord
	bra	Set_F_Autre
; B est une constante entiere
.F2	bsr	Pull_D5			Depiler efficacement
	beq.s	.F0			NON: sub.l (a3)+,d3
	move.l	S_Cst1(a1),d1		OUI:
	beq.s	.F2s			Quelque chose a additionner?
	bmi.s	.F2m
	cmp.l	#8,d1			subq possible?
	bhi.s	.F2n
	move.w	Csubqd3(pc),d0		Oui!
	and.w	#%1111000111111111,d0
	bra.s	.F2x
.F2m	cmp.l	#-8,d1			addq possible?
	blt.s	.F2n
	neg.l	d1
	move.w	Caddqd3(pc),d0
	and.w	#%1111000111111111,d0
.F2x	and.w	#$07,d1
	lsl.w	#8,d1
	lsl.w	#1,d1
	or.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre
.F2n	move.w	Csubid3(pc),d0		Normal
	bsr	OutWord
	move.l	d1,d0
	bsr	OutLong
	bra	Set_F_Autre
.F2s	move.l	d7,d4			On a depile efficacement
	move.l	d6,d3
	move.l	d5,d2
	rts
; B est une variable locale
.F4	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.w	Csub2a6d3(pc),d0	Ressort la variable
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre
; B est une variable globale
.F5	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.w	Cmvd7a0(pc),d0		On ressort la variable
	bsr	OutWord
	move.w	Csub2a0d3(pc),d0
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre

;	Operateur MULTIPLIE, optimise!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Multiplie
	bsr	OP_Compat		Meme type
	lea	.Table(pc),a0
	bra	OP_General
; Tableau de branchement aux fonction MULTIPLIE
;    \ 	B=	A VlVgVtMeMfMdMs
; A   \	        | | | | | | | |
.Table	dc.b	0,0,0,0,2,0,0,0		A= Autre
	dc.b	0,0,0,0,2,0,0,0		A= Variable locale
	dc.b	0,0,0,0,2,0,0,0		A= Variable globale
	dc.b	0,0,0,0,2,0,0,0		A= Variable tableau
	dc.b	3,3,3,3,1,0,0,0		A= MoveE
	dc.b	0,0,0,0,0,0,0,0		A= MoveF
	dc.b	0,0,0,0,0,0,0,0		A= MoveD
	dc.b	0,0,0,0,0,0,0,0		A= MoveS
	bra	.F0			La fonction standart
	bra	.F1			Deux constantes entieres
	bra	.F2			"B" est une constante entiere
	bra	.F3			"A" est une constante entiere
; Appel de la fonction standart
.F0	move.w	d2,d0
	add.w	#L_MultE,d0		1ere si entier
	bsr	Do_JsrLibrary		2eme si float
	bra	Set_F_Autre
; Deux constantes entieres
.F1	move.l	S_Cst1(a0),d0		OK! on additionne
	move.l	S_Cst1(a1),d1
	bsr	Mulu32
	bsr	S_ReloadD5		Retourner en arriere?
	bne	Out_MoveE		Possible, on fabrique le code
	bsr	ReOut_ConstD5		On change "A"
	bsr	S_ReposD2		Retourner avant B, toujours possible
	bset	#F_Depile,d2		On vient de depiler!
	move.l	a4,S_Pile(a1)
	move.w	Cmva3pd3(pc),d0		move.l	(a3)+,d3
	bsr	OutWord
	bra	Set_F_Autre
; B est une constante entiere
.F2	move.l	S_Cst1(a1),d1		B est-il un multiple de 2?
	bsr	Get_Mult2
	beq.s	.F0
	bsr	Pull_D5			Depiler efficacement
	bne.s	.F2a			depile?
	bsr	S_ReposD2
	move.w	Cmva3pd3(pc),d0
	bsr	OutWord
.F2a	move.w	Cmvqd0(pc),d0		moveq #mult,d0
	move.b	d1,d0
	bsr	OutWord
	move.w	Clsld0d3(pc),d0
	bsr	OutWord
	bra	Set_F_Autre
; A est une constante entiere
.F3	move.l	S_Cst1(a0),d1		A est-il un multiple de 2?
	bsr	Get_Mult2
	beq	.F0
	move.l	d1,d0
	bsr	ReOut_ConstD5		Repoke dans l'objet
	move.w	Cmva3pd0(pc),d0		move.l (a3)+,d0
	bsr	OutWord
	move.w	Clsld0d3(pc),d0		lsl.l d0,d3
	bsr	OutWord
	bra	Set_F_Autre

;	Operateur DIVISE, optimise!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Divise
	bsr	OP_Compat		Meme type
	lea	.Table(pc),a0
	bra	OP_General
; Tableau de branchement aux fonction MULTIPLIE
;    \ 	B=	A VlVgVtMeMfMdMs
; A   \	        | | | | | | | |
.Table	dc.b	0,0,0,0,2,0,0,0		A= Autre
	dc.b	0,0,0,0,2,0,0,0		A= Variable locale
	dc.b	0,0,0,0,2,0,0,0		A= Variable globale
	dc.b	0,0,0,0,2,0,0,0		A= Variable tableau
	dc.b	0,0,0,0,1,0,0,0		A= MoveE
	dc.b	0,0,0,0,0,0,0,0		A= MoveF
	dc.b	0,0,0,0,0,0,0,0		A= MoveD
	dc.b	0,0,0,0,0,0,0,0		A= MoveS
	bra	.F0			La fonction standart
	bra	.F1			Deux constantes entieres
	bra	.F2			"B" est une constante entiere
; Appel de la fonction standart
.F0	move.w	d2,d0
	add.w	#L_DiviseE,d0		1ere si entier
	bsr	Do_JsrLibrary		2eme si float
	bra	Set_F_Autre
; Deux constantes entieres
.F1	move.l	S_Cst1(a0),d0		On divise
	move.l	S_Cst1(a1),d1
	bsr	Divu32
	bsr	S_ReloadD5		Retourner en arriere avant A si possible?
	bne	Out_MoveE		Possible, on fabrique le code
	bsr	ReOut_ConstD5		On change "A"
	bsr	S_ReposD2		Retourner avant B, toujours possible
	bset	#F_Depile,d2		On vient de depiler!
	move.l	a4,S_Pile(a1)
	move.w	Cmva3pd3(pc),d0		move.l	(a3)+,d3
	bsr	OutWord
	bra	Set_F_Autre
; B est une constante entiere
.F2	move.l	S_Cst1(a1),d1		B est-il un multiple de 2?
	bsr	Get_Mult2
	beq.s	.F0
	bsr	Pull_D5			Depiler efficacement
	bne.s	.F2a			Depile?
	bsr	S_ReposD2
	move.w	Cmva3pd3(pc),d0
	bsr	OutWord
.F2a	move.w	Cmvqd0(pc),d0		moveq #mult,d0
	move.b	d1,d0
	bsr	OutWord
	move.w	Casrd0d3(pc),d0
	bsr	OutWord
	bra	Set_F_Autre

; 	Operateur general
; ~~~~~~~~~~~~~~~~~~~~~~~
OP_General
	move.w	d6,d0			A*8
	lsl.w	#2,d0
	move.w	d3,d1			+ B/2
	lsr.w	#1,d1
	add.w	d1,d0
	move.b	0(a0,d0.w),d0		Prend le numero de la fonction
	lsl.w	#2,d0			* 4
	pea	64(a0,d0.w)
	move.l	d7,a0			A0= A
	move.l	d4,a1			A1= B
	rts

;	Operateurs de comparaison
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Egal	bsr	OP_Compat
	bsr	Optimise_D2
	lea	COP_Egal(pc),a0
	bra.s	OP_Comp
OP_Diff	bsr	OP_Compat
	bsr	Optimise_D2
	lea	COP_Diff(pc),a0
	bra.s	OP_Comp
OP_Sup	bsr	OP_Compat
	bsr	Optimise_D2
	lea	COP_Sup(pc),a0
	bra.s	OP_Comp
OP_Inf	bsr	OP_Compat
	bsr	Optimise_D2
	lea	COP_Inf(pc),a0
	bra.s	OP_Comp
OP_SupEg
	bsr	OP_Compat
	bsr	Optimise_D2
	lea	COP_SupEg(pc),a0
	bra.s	OP_Comp
OP_InfEg
	bsr	OP_Compat
	bsr	Optimise_D2
	lea	COP_InfEg(pc),a0
OP_Comp	tst.w	d2			Si entier
	bne.s	.Lib
	move.w	(a0)+,d0
	bsr	OutWord			La comparaison
	bra.s	.Fin
.Lib	cmp.w	#1,d2			Float?
	bne.s	.Float
	move.w	#L_Float_Compare,d0	Comparaison de floats
	bra.s	.Suite
.Float	move.w	#L_Chaine_Compare,d0	Comparaison de chaines
.Suite	bsr	Do_JsrLibrary
	addq.l	#2,a0
.Fin	move.w	(a0)+,d0
	bsr	OutWord
	lea	COP_Comp(pc),a0
	bsr	OutCode
	bsr	Set_F_Autre
	bset	#F_Drapeaux,d2
	clr.w	d2
	rts

;	Codes rapide des operateurs de comparaison
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COP_Egal
	cmp.l	(a3)+,d3		Code comparaison egal
	seq	d3
COP_Diff
	cmp.l	(a3)+,d3		Code comparaison different
	sne	d3
COP_Sup
	cmp.l	(a3)+,d3		Code comparaison superieur
	slt	d3
COP_Inf
	cmp.l	(a3)+,d3		Code comparaison inferieur
	sgt	d3
COP_SupEg
	cmp.l	(a3)+,d3		Code comparaison superieur ou egal
	sle	d3
COP_InfEg
	cmp.l	(a3)+,d3		Code comparaison inferieur ou egal
	sge	d3
COP_Comp
	ext.w	d3
	ext.l	d3
	dc.w	$4321


;	Operateur MODULO
; ~~~~~~~~~~~~~~~~~~~~~~
OP_Modulo
	bsr 	OP_Quentiers
        move.w 	#L_Modulo,d0
        bsr 	Do_JsrLibrary
	bra	Set_F_Autre

;	Operateur PUISSANCE
; ~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Puissance
	bsr 	OP_Quefloats
	bsr	MathFloat
        moveq 	#L_Puissance,d0
        bsr 	Do_JsrLibrary
	bra	Set_F_Autre

; 	Operateurs logiques optimises
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_And	lea	COP_And(pc),a0
	bra	OP_Logique
OP_Or	lea	COP_Or(pc),a0
	bra	OP_Logique
COP_And	and.l	(a3)+,d3		0= normal
	and.l	#0,d3			2= B constante
	and.l	2(a6),d3		8= B variable locale
	and.l	2(a0),d3		12 B variable globale /
	and.l	d1,d0			16 Immediat
	rts
COP_Or	or.l	(a3)+,d3		0= normal
	or.l	#0,d3			2= B constante
	or.l	2(a6),d3		8= B variable locale
	or.l	2(a0),d3		12 B variable globale /
	or.l	d1,d0			16 Immediat
	rts


;	Operateurs LOGIQUES, optimises!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Logique
	move.l	a0,-(sp)
	bsr	OP_Quentiers		Meme type
	lea	.Table(pc),a0
	bra	OP_General
; Tableau de branchement aux fonction
;    \ 	B=	A VlVgVtMeMfMdMs
; A   \	        | | | | | | | |
.Table	dc.b	0,4,5,6,2,0,0,0		A= Autre
	dc.b	0,4,5,6,2,0,0,0		A= Variable locale
	dc.b	0,4,5,6,2,0,0,0		A= Variable globale
	dc.b	0,4,5,6,2,0,0,0		A= Variable tableau
	dc.b	3,4,5,6,1,0,0,0		A= MoveE
	dc.b	0,0,0,0,0,0,0,0		A= MoveF
	dc.b	0,0,0,0,0,0,0,0		A= MoveD
	dc.b	0,0,0,0,0,0,0,0		A= MoveS
	bra	.F0			La fonction standart
	bra	.F1			Deux constantes entieres
	bra	.F2			"B" est une constante entiere
	bra	.F0			"A" est une constante entiere
	bra	.F4			"B" est une variable locale
	bra	.F5			"B" est une variable globale
	bra	.F0			"B" est une variable tableau
; Appel de la fonction standart
.F0	move.l	(sp)+,a0
	move.w	(a0),d0
	bsr	OutWord
	bra	Set_F_Autre
; Deux constantes entieres
.F1	move.l	S_Cst1(a0),d0		OK! on additionne
	move.l	S_Cst1(a1),d1
	move.l	(sp)+,a0		Va effectuer la fonction
	jsr	16(a0)
	bsr	S_ReloadD5		Retourner en arriere?
	bne	Out_MoveE		Possible, on fabrique le code
	bsr	ReOut_ConstD5		On change "A"
	bsr	S_ReposD2		Retourner avant B, toujours possible
	bset	#F_Depile,d2		On vient de depiler!
	move.l	a4,S_Pile(a1)
	move.w	Cmva3pd3(pc),d0		move.l	(a3)+,d3
	bsr	OutWord
	bra	Set_F_Autre
; B est une constante entiere
.F2	bsr	Pull_D5			Depiler efficacement
	beq.s	.F0
	move.l	(sp)+,a0
	move.w	2(a0),d0
	bsr	OutWord
	move.l	S_Cst1(a1),d0
	bsr	OutLong
	bra	Set_F_Autre
; B est une variable locale
.F4	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.l	(sp)+,a0		Ressort la variable
	move.w	8(a0),d0		And.l V(a6),d3
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre
; B est une variable globale
.F5	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.w	Cmvd7a0(pc),d0		On ressort la variable
	bsr	OutWord
	move.l	(sp)+,a0
	move.w	12(a0),d0		And.l V(a0),d3
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra	Set_F_Autre


;	Operateurs XOR, optimises!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Xor
	bsr	OP_Quentiers		Meme type
	lea	.Table(pc),a0
	bra	OP_General
; Tableau de branchement aux fonction PLUS
;    \ 	B=	A VlVgVtMeMfMdMs
; A   \	        | | | | | | | |
.Table	dc.b	0,4,5,6,2,0,0,0		A= Autre
	dc.b	0,4,5,6,2,0,0,0		A= Variable locale
	dc.b	0,4,5,6,2,0,0,0		A= Variable globale
	dc.b	0,4,5,6,2,0,0,0		A= Variable tableau
	dc.b	3,4,5,6,1,0,0,0		A= MoveE
	dc.b	0,0,0,0,0,0,0,0		A= MoveF
	dc.b	0,0,0,0,0,0,0,0		A= MoveD
	dc.b	0,0,0,0,0,0,0,0		A= MoveS
	bra	.F0			La fonction standart
	bra	.F1			Deux constantes entieres
	bra	.F2			"B" est une constante entiere
	bra	.F0			"A" est une constante entiere
	bra	.F4			"B" est une variable locale
	bra	.F5			"B" est une variable globale
	bra	.F0			"B" est une variable tableau
; Appel de la fonction standart
.F0	lea	OP_Xor1(pc),a0
	bsr	OutCode
	bra	Set_F_Autre
; Deux constantes entieres
.F1	move.l	S_Cst1(a0),d0		OK! on additionne
	move.l	S_Cst1(a1),d1
	eor.l	d1,d0
	bsr	S_ReloadD5		Retourner en arriere?
	bne	Out_MoveE		Possible, on fabrique le code
	bsr	ReOut_ConstD5		On change "A"
	bsr	S_ReposD2		Retourner avant B, toujours possible
	bset	#F_Depile,d2		On vient de depiler!
	move.l	a4,S_Pile(a1)
	move.w	Cmva3pd3(pc),d0		move.l	(a3)+,d3
	bsr	OutWord
	bra	Set_F_Autre
; B est une constante entiere
.F2	bsr	Pull_D5			Depiler efficacement
	beq.s	.F0			NON
	move.w	OP_Xor2(pc),d0
	bsr	OutWord
	move.l	S_Cst1(a1),d0
	bsr	OutLong
	bra	Set_F_Autre
; B est une variable locale
.F4	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	bsr	S_ReposD2		On met sur D2
	move.w	OP_Xor3(pc),d0		Ressort la variable
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	bra.s	.XSuit
; B est une variable globale
.F5	tst.w	d2			On veut des entier
	bne	.F0
	move.w	S_Var(a1),d1
	bsr	Pull_D5			On peut depiler?
	beq	.F0
	move.w	Cmvd7a0(pc),d0		On ressort la variable
	bsr	OutWord
	move.w	OP_Xor4(pc),d0
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
.XSuit	move.w	OP_Xor5(pc),d0
	bsr	OutWord
	bra	Set_F_Autre
OP_Xor1	move.l	(a3)+,d0
	eor.l	d0,d3
	dc.w	$4321
OP_Xor2	eor.l	#0,d3
OP_Xor3	move.l	2(a6),d0
OP_Xor4	move.l	2(a0),d0
OP_Xor5	eor.l	d0,d3


;	Multiplication 32 bits D0*D1 >>> D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mulu32	movem.l	d1-d4,-(sp)
	move.l	d0,d3
	move.l	d1,d2
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
	move.l	d3,d0
	tst.w 	d4
	beq.s	mltF
	neg.l 	d0
	bra.s 	mltF
* Multiplcation lente
mlt0:   move 	d2,d1
        mulu 	d3,d1
        bmi	Err_Overflow
        swap 	d2
        move 	d2,d0
        mulu 	d3,d0
        swap 	d0
        bmi 	Err_Overflow
        tst 	d0
        bne 	Err_Overflow
        add.l 	d0,d1
        bvs 	Err_Overflow
        swap 	d3
        move 	d2,d0
        mulu 	d3,d0
        bne 	Err_Overflow
        swap 	d2
        move 	d2,d0
        mulu 	d3,d0
        swap 	d0
        bmi 	Err_Overflow
        tst 	d0
        bne 	Err_Overflow
        add.l 	d0,d1
        bvs 	Err_Overflow
        tst 	d4              ;signe du resultat
        beq.s 	mlt3
        neg.l 	d1
mlt3:   move.l 	d1,d0
mltF:	movem.l	(sp)+,d1-d4
	rts

; 	Divise entier: D0/D1 >>> D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Divu32	movem.l	d1-d5,-(sp)
	move.l	d1,d3
	move.l	d0,d2
	tst.l 	d3
        beq 	Err_DivisionByZero         ;division par zero!
        moveq	#0,d4
        tst.l 	d2
        bpl.s 	dva
        bset	#31,d4
        neg.l 	d2
dva:    cmp.l 	#$10000,d3    		;Division rapide ou non?
        bcc.s 	dv0
        tst.l 	d3
        bpl.s 	dvb
    	bchg	#31,d4
        neg.l 	d3
dvb:    move.l 	d2,d0
        divu 	d3,d0          ;division rapide: 32/16 bits
        bvs.s 	dv0
        moveq 	#0,d3
        move	d0,d3
        bra.s 	dvc
dv0:    tst.l 	d3
        bpl.s 	dv3
        bchg	#31,d4
        neg.l 	d3
dv3:    move.l	d5,-(sp)
	move.w 	#31,d4         ;division lente: 32/32 bits
        moveq 	#-1,d5
        clr.l 	d1
dv2:    lsl.l 	#1,d2
        roxl.l	#1,d1
        cmp.l 	d3,d1
        bcs.s 	dv1
        sub.l 	d3,d1
        lsr 	#1,d5           ;met X a un!
dv1:    roxl.l 	#1,d0
        dbra 	d4,dv2
        move.l 	d0,d3
	move.l	(sp)+,d5
dvc:    tst.l	d4
        bpl.s 	dvd
        neg.l 	d3
dvd:   	move.l	d3,d0
	movem.l	(sp)+,d1-d5
	rts

;	Compatibilite entre operandes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OP_Compat
	cmp.b	d2,d5			Meme type
	bne.s	.Conv
	rts
.Conv	tst.b	d5
	beq	D5_Float
	bra	D2_Float
; 	Que des entiers
; ~~~~~~~~~~~~~~~~~~~~~
OP_Quentiers
	tst.b	d2
	beq.s	.Skip1
	bsr	D2_Entier
.Skip1	tst.b	d5
	beq.s	.Skip2
	bsr	D5_Entier
.Skip2	rts
; 	Que des floats
; ~~~~~~~~~~~~~~~~~~~~
OP_Quefloats
	tst.b	d2
	bne.s	.Skip1
	bsr	D2_Float
.Skip1	tst.b	d5
	bne.s	.Skip2
	bsr	D5_Float
.Skip2	rts


;	Fabrique le code constante entiere
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Out_MoveE
	move.l	d0,d1
	move.w	Cmvid3(pc),d0		move.l	#xxx,d3
	bsr	OutWord
	move.l	d1,d0
	bsr	OutLong
	move.l	d4,a0
	move.l	d1,S_Cst1(a0)
	moveq	#F_MoveE,d3
	bclr	#F_Empile,d2
	bclr	#F_Depile,d2
	rts

; 	Ressort la constante en D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ReOut_ConstD2
	movem.l	a4/a0,-(sp)
	move.l	d4,a0
	move.l	d0,S_Cst1(a0)
	move.l	S_a4(a0),a4
	addq.l	#2,a4
	bsr	OutLong
	movem.l	(sp)+,a4/d0
	rts

; 	Ressort la constante en D5
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ReOut_ConstD5
	movem.l	a4/a0,-(sp)
	move.l	d7,a0
	move.l	d0,S_Cst1(a0)
	move.l	S_a4(a0),a4
	addq.l	#2,a4
	bsr	OutLong
	movem.l	(sp)+,a4/d0
	rts

;	Stocke la position actuelle dans le script / D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
S_Script_D2
	move.l	A_Script(a5),a0		Stocke toutes les donnees
	move.l	a0,d4			Position dans le script
	addq.l	#8,a0			S_Cst1 / S_Cst2
	move.w	EvaCompteur(a5),(a0)+	S_EvaCompteur
	clr.l	(a0)+			S_Pile
	clr.w	(a0)+			S_Var
	move.l	a3,(a0)+		S_a3
	move.l	a4,(a0)+		S_a4
	move.l	OldRel(a5),(a0)+	S_OldRel
	move.l	A_LibRel(a5),(a0)+	S_LibRel
	move.l	Lib_OldRel(a5),(a0)+	S_LibOldRel
	move.l	A_Chaines(a5),(a0)+	S_Chaines
	move.l	a0,A_Script(a5)
	rts

; 	Recharge la position dans l'objet juste au debut du dernier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
S_ReposD2
	move.l	a0,-(sp)
	move.l	d4,a0
	move.l	S_a3(a0),a3
	move.l	S_a4(a0),a4
	move.l	S_OldRel(a0),OldRel(a5)
	move.l	S_LibRel(a0),A_LibRel(a5)
	move.l	S_LibOldRel(a0),Lib_OldRel(a5)
	move.l	S_Chaines(a0),A_Chaines(a5)
	move.l	(sp)+,a0
	rts
; 	Recharge la position de D5 dans l'objet, si possible
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
S_ReposD5
	movem.l	a0/d0,-(sp)
	move.l	d7,a0
	move.w	S_EvaCompteur(a0),d0
	addq.w	#1,d0
	cmp.w	EvaCompteur(a5),d0		Juste une seule routine
	bne.s	.Non				devant celle-ci?
	move.l	S_a4(a0),a4			Juste la position A4
	moveq	#-1,d0
.Out	movem.l	(sp)+,a0/d0
	rts
.Non	moveq	#0,d0
	bra.s	.Out
; 	Recharge D5 dans l'objet, si possible
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
S_ReloadD5
	movem.l	a0/d0,-(sp)
	move.l	d7,a0
	move.w	S_EvaCompteur(a0),d0
	addq.w	#1,d0
	cmp.w	EvaCompteur(a5),d0		Juste une seule routine
	bne.s	.Non				devant celle-ci?
	move.l	S_a3(a0),a3
	move.l	S_a4(a0),a4
	move.l	S_OldRel(a0),OldRel(a5)
	move.l	S_LibRel(a0),A_LibRel(a5)
	move.l	S_LibOldRel(a0),Lib_OldRel(a5)
	move.l	S_Chaines(a0),A_Chaines(a5)
	move.l	d7,d4
	move.l	d6,d3
	move.l	d5,d2				Devient le dernier operande
	moveq	#-1,d0
.Out	movem.l	(sp)+,a0/d0
	rts
.Non	moveq	#0,d0
	bra.s	.Out

; Routines de changement de type: D2 >>> Entier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D2_Entier
	move.l	d4,a0
	clr.w	d2
	jmp	.Jmp(pc,d3.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.Autre			Une variable locale
	bra.s	.Autre			Une variable globale
	bra.s	.Autre			Une variable tableau
	bra.s	.Autre			Un move.l entier
	bra.s	.MoveF			Un move.l float
	bra.s	.MoveD			Un move.l double
	bra.s	.Autre			Un move.l string
; Une constante float > entier
.MoveF	move.l	S_Cst1(a0),d0		Float, simple
	bsr	FloatToInt
	bsr	ReOut_ConstD2
	moveq	#F_MoveE,d3
	rts
; Une constante double > entier
.MoveD	bsr	S_ReposD2		Recule dans l'objet
	move.w	Cmvid3(pc),d0
	bsr	OutWord
	move.l	S_Cst1(a0),d0
	move.l	S_Cst2(a0),d1
	bsr	DoubleToInt
	move.l	d0,S_Cst1(a0)
	bsr	OutLong
	moveq	#F_MoveE,d3		Change le type de l'operande
	rts
; Un autre operateur, appelle la librarie
.Autre	bsr	Cree_FlToInt
	bra	Set_F_Autre		Plus une constante

; Routines de changement de type: D5 >>> entier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D5_Entier
	move.l	d7,a1
	clr.w	d5
	jmp	.Jmp(pc,d6.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.Autre			Une variable locale
	bra.s	.Autre			Une variable globale
	bra.s	.Autre			Une variable tableau
	bra.s	.Autre			Un move.l entier
	bra.s	.MoveF			Un move.l float
	bra.s	.Autre			Un move.l double
	bra.s	.Autre			Un move.l string
; Une constante float > entier
.MoveF	tst.b	MathFlags(a5)
	bmi.s	.Autre
	move.l	S_Cst1(a1),d0		Float, simple
	bsr	FloatToInt
	bsr	ReOut_ConstD5
	moveq	#F_MoveE,d6
	rts
; Autre operande, appelle la librairie
.Autre	bsr	Cree_FlToInt2
	bra	Set_F_Autre		Plus une constante

; Routines de changement de type: D2 >>> float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D2_Float
	move.l	d4,a0
	move.w	#1,d2
	jmp	.Jmp(pc,d3.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.Autre			Une variable locale
	bra.s	.Autre			Une variable globale
	bra.s	.Autre			Une variable tableau
	bra.s	.MoveE			Un move.l entier
	bra.s	.Autre			Un move.l float
	bra.s	.Autre			Un move.l double
	bra.s	.Autre			Un move.l string
; Une constante entiere > float / double
.MoveE	tst.b	MathFlags(a5)
	bmi.s	.Dble
	move.l	S_Cst1(a0),d0		Float, simple
	bsr	IntToFloat
	bsr	ReOut_ConstD2
	moveq	#F_MoveF,d3
	rts
.Dble	bsr	S_ReposD2		Recule dans l'objet
	move.w	Cmvid4(pc),d0
	bsr	OutWord
	move.l	S_Cst1(a0),d0
	bsr	IntToDouble
	move.l	d0,S_Cst1(a0)
	move.l	d1,S_Cst2(a0)
	exg	d0,d1
	bsr	OutLong
	move.w	Cmvid3(pc),d0
	bsr	OutWord
	move.l	d1,d0
	bsr	OutLong
	moveq	#F_MoveD,d3		Change le type de l'operande
	rts
; Un autre operateur, appelle la librarie
.Autre	bsr	Cree_IntToFl
	bra	Set_F_Autre

; Routines de changement de type D5 >>> float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D5_Float
	move.l	d7,a1
	move.w	#1,d5
	jmp	.Jmp(pc,d6.w)
.Jmp	bra.s	.Autre			Une fonction
	bra.s	.Autre			Une variable locale
	bra.s	.Autre			Une variable globale
	bra.s	.Autre			Une variable tableau
	bra.s	.MoveE			Un move.l entier
	bra.s	.Autre			Un move.l float
	bra.s	.Autre			Un move.l double
	bra.s	.Autre			Un move.l string
; Une constante entiere > float / double
.MoveE	tst.b	MathFlags(a5)
	bmi.s	.Autre
	move.l	S_Cst1(a1),d0		Float, simple
	bsr	IntToFloat
	bsr	ReOut_ConstD5
	moveq	#F_MoveF,d6
	rts
; Autres: appelle la librarie
.Autre	bsr	Cree_IntToFl2		Appelle la librairie
	bra	Set_F_AutreD5


;	Set type= F_Autre
; ~~~~~~~~~~~~~~~~~~~~~~~
Set_F_Autre
	moveq	#F_Autre,d3
	bclr	#F_Empile,d2
	bclr	#F_Depile,d2
	bclr	#F_Drapeaux,d2
	rts
;	Parametre en D5= autre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Set_F_AutreD5
	moveq	#F_Autre,d6		Plus une constante
	bclr	#F_Empile,d5		Plus empile!
	bclr	#F_Depile,d5		Plus depile!
	bclr	#F_Drapeaux,d5		Plus de flags
	rts

;	Retourne le multiple de 2 >>> D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_Mult2
	movem.l	d0/d2,-(sp)
	moveq	#2,d0
	moveq	#1,d2
.Loop	cmp.l	d0,d1
	beq.s	.Ok
	addq.w	#1,d2
	lsl.l	#1,d0
	bcc.s	.Loop
	moveq	#0,d0
	bra.s	.Out
.Ok	move.l	d2,d1
.Out	movem.l	(sp)+,d0/d2
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	LES FONCTIONS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 				Table des sauts fonctions speciales
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Func_Jumps
	dc.l	0			00- Normal
	bra	Err_Syntax		01= Syntax error!
	bra	FnNull			02= Evaluation finie
	bra	FnNull			03= Evaluation finie par une virgule
	bra	New_Evalue		04= Ouverture de parenthese
	bra	FnVal			05= Val
	bra	FnExtension		06= Extension
	bra	FnVariable		07= Variable
	bra	FnVarptr		08= Varptr
	bra	FnFn			09= FN
	bra	FnNot			0A= Not
	bra	FnXYMenu		0B= XYmenu
	bra	FnEqu			0C= Equ
	bra	FnMatch			0D= Sort
	bra	FnArray			0E- Array
	bra	FnMin			0F= Min
	bra	FnEqu			10= LVO
	bra	FnStruc			11= Struc
	bra	FnStrucD		12= Struc$
	dc.l	0			13= Fonction math
	bra	FnConstEnt		14= Constante Entiere
	bra	FnConstFloat		15= Constante Float
	bra	FnConstDouble		16= Constante DFloat
	bra	FnConstChaine		17= Constante String
	dc.l	0			18= Instruction + Fonction
	dc.l	0			19- Deja teste!
	dc.l	0			1A- Variable reservee
	bra	FnParamE		1B- Param entier
	bra	FnParamF		1C- Param float
	bra	FnParamS		1D- Param string
	bra	FnFalse			1E- False
	bra	FnTrue			1F- True
	bra	FnMax			20- Max
	bra	FnMid3			21- Mid 2
	bra	FnMid2			22- Mid 3
	bra	FnLeft			23- Left
	bra	FnRight			24- Right
	bra	FnDialogs		25- Fonction dialogues
	bra	FnFSel			26- Fonction fsel
	bra	FnBtst			27- Btst

;	Selecteur de fichier: met les flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FnFSel	bset	#F_FSel,Flag_Libraries(a5)
;	Fonction dialogues: met les flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FnDialogs
	bset	#F_Dialogs,Flag_Libraries(a5)
	lea	0(a0,d0.w),a0		Pointe la fonction
	move.w	0(a0),d0		D0= # de fonction
	bra	FnNormal2

;	=VAL(a$)
; ~~~~~~~~~~~~~~
FnVal	bsr	Fn_New_Evalue
	move.w	Type_Voulu(a5),d0
	bmi.s	.Nondet
	move.b	.Types(pc,d0.w),d2
	bmi.s	.Nondet
.Suite	move.w	Cmvqd2(pc),d0
	move.b	d2,d0
	bsr	OutWord
	move.w	#L_FnVal,d0
	bsr	Do_JsrLibrary
	bra	Set_F_Autre
.Nondet	moveq	#0,d2
	btst	#0,MathFlags(a5)
	beq.s	.Suite
	moveq	#1,d2
	bra.s	.Suite
.Types	dc.b	0			0 Entier
	dc.b	1			1 Float
	dc.b	-1			2 Chaine
	dc.b	-1			3 Entier / Chaine
	dc.b	1			4 Float
	dc.b	1			5 Angle
	even

;	=STRUC()
; ~~~~~~~~~~~~~~
FnStruc	bsr	GStruc
	move.w	#L_FnStruc,d0
	bsr	Do_JsrLibrary
	moveq	#0,d2
	bra	Set_F_Autre
FnStrucD
	bsr	GStruc
	move.w	#L_FnStrucD,d0
	bsr	Do_JsrLibrary
	moveq	#2,d2
	bra	Set_F_Autre
; Recupere les parametres structure...
GStruc	bsr	GetLong			Equate
	move.l	d0,-(sp)
	bsr	GetWord			Type
	lsl.w	#1,d0			*2
	move.w	d0,-(sp)
	bsr	Fn_Expentier		L'adresse de base > D3
	bsr	StockOut
	bsr	Fn_New_Evalue		Saute la chaine
	bsr	RestOut
	move.w	Cmvqd0(pc),d0		Sort le type
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	Caddid3(pc),d0		Add.l #,d3
	bsr	OutWord
	move.l	(sp)+,d0
	bsr	OutLong
	rts

;	=ARRAY(a())
; ~~~~~~~~~~~~~~~~~
FnArray	addq.l	#4,a6			Saute la (
	bsr	StockOut
	bsr	VarAdr
	move.w	d0,d1			Type de pointeur sur base
	addq.l	#2,a6			Saute la )
	bsr	RestOut			Remet au debut
	bsr	ArrayBase		Met le pointeur
	move.w	#L_FnArray,d0
	bsr	Do_JsrLibrary
	moveq	#0,d2			Retourne le type
	bra	Set_F_Autre

;	=MATCH a()
; ~~~~~~~~~~~~~~~~
FnMatch	move.w	Type_Voulu(a5),-(sp)
	addq.l	#4,a6
	move.l	a6,-(sp)
	bsr	SoVar
	and.w	#$000f,d2
	move.w	d2,Type_Voulu(a5)
	bsr	Fn_Evalue_Voulu
	bsr	Push_D2
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	bsr	AdBase
	move.w	Cmvqd2(pc),d0
	and.w	#$0f,d2
	move.b	d2,d0
	bsr	OutWord
	move.w	#L_FnMatch,d0
	bsr	Do_JsrLibrary
	move.l	(sp)+,a6
	move.w	(sp)+,Type_Voulu(a5)
	moveq	#0,d2
	bra	Set_F_Autre

;	=Equ / Lvo
; ~~~~~~~~~~~~~~~~
FnEqu	bsr	GetLong
	bsr	Out_MoveE
	addq.l	#2+2+2,a6
	bsr	GetWord
	move.w	d0,d1
	and.w	#1,d1
	add.w	d1,d0
	lea	2(a6,d0.w),a6
	rts

;	=XYMenu
; ~~~~~~~~~~~~~
FnXYMenu
	move.w	0(a0,d0.w),-(sp)	Prend le token
	bsr	MnPar			Prend les params
	move.w	(sp)+,d0
	bsr	Do_JsrLibrary		Branche
	moveq	#0,d2			Retour entier
	bra	Set_F_Autre

;	Fonction NOT
; ~~~~~~~~~~~~~~~~~~
FnNot	bsr 	Expentier
	move.w	.Code(pc),d0
	bsr	OutWord
	bra	Set_F_Autre
.Code	not.l 	d3


; 	Mid / Left / Right en fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FnRight	move.w	#L_FnRight,d1
	bra.s	FnM
FnLeft	move.w	#L_FnLeft,d1
	bra.s	FnM
FnMid3	move.w	#L_FnMid3,d1
	bra.s	FnM
FnMid2	move.w	#L_FnMid2,d1
FnM	lea	0(a0,d0.w),a0
	move.w	d1,d0
	bra	FnNormal2

;	VARPTR
; ~~~~~~~~~~~~
FnVarptr
	addq.l	#4,a6
	bsr	VarAdr
	bsr	AdToA0
	addq.l	#2,a6
	bsr	Set_F_Autre
	move.w	d2,d0
	moveq	#0,d2
	cmp.b	#2,d0
	beq.s	.Str
	move.w	Cmva0d3(pc),d0
	bra	OutWord
.Str	lea	.Code(pc),a0
	bra	OutCode
.Code	move.l	(a0),d3
	addq.l	#2,d3
	dc.w	$4321

;	MIN + MAX
; ~~~~~~~~~~~~~~~
FnMin	pea	TMin(pc)
	bra.s	FnMM
FnMax	pea	TMax(pc)
FnMM	bsr	Fn_New_Evalue
	bsr	Optimise_D2
	bsr	Push_D2
	bsr	Fn_New_Evalue
	bsr	Optimise_D2
	move.l	(sp)+,a0
	move.w	d2,d0
	lsl.w	#1,d0
	move.w	0(a0,d0.w),d0
	bsr	Do_JsrLibrary
	bra	Set_F_Autre
TMin	dc.w	L_FnMin,L_FnMinF,L_FnMinS
TMax	dc.w	L_FnMax,L_FnMaxF,L_FnMaxS

;	=FALSE / TRUE
; ~~~~~~~~~~~~~~~~~~~
FnFalse	move.w	Cmvqd3(pc),d0
	bsr	OutWord
	bra	Set_F_Autre
FnTrue	move.w	Cmvqd3(pc),d0
	move.b	#-1,d0
	bsr	OutWord
	bra	Set_F_Autre

;	=PARAM
; ~~~~~~~~~~~~
FnParamE
	moveq	#0,d2
	lea	CdParE(pc),a0
	bra.s	FnParSuite
FnParamF
	moveq	#1,d2
	lea	CdParF(pc),a0
	tst.b	MathFlags(a5)
	bpl.s	FnParSuite
	lea	CdParD(pc),a0
	bra.s	FnParSuite
FnParamS
	moveq	#2,d2
	lea	CdParS(pc),a0
FnParSuite
	bsr	OutCode
	bra	Set_F_Autre
CdParE	move.l	ParamE(a5),d3
	dc.w	$4321
CdParD	move.l	ParamF2(a5),d4
CdParF	move.l	ParamF(a5),d3
	dc.w	$4321
CdParS	move.l	ParamC(a5),d3
	dc.w	$4321

;	Evaluation finie par une virgule
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FnNull	moveq	#0,d2
	move.l	#EntNul,d0
	subq.l	#2,a6			Reste sur la virgule
	bra	Out_MoveE

;	Constante entiere / hex / bin
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FnConstEnt
	moveq	#0,d2
	bsr	GetLong
	bra	Out_MoveE

;	Constante float
; ~~~~~~~~~~~~~~~~~~~~~
FnConstFloat
	moveq	#1,d2
	bsr	MathSimple
	tst.b	MathFlags(a5)
	bmi.s	.Dble
	move.w	Cmvid3(pc),d0		move.l	#xxxx,d3
	bsr	OutWord
	bsr	GetLong
	move.l	d4,a0
	move.l	d0,S_Cst1(a0)
	bsr	OutLong
	moveq	#F_MoveF,d3
	rts
.Dble	move.w	Cmvid4(pc),d0		Move.l	#xxx,d4
	bsr	OutWord
	bsr	GetLong
	bsr	Float2Double		Conversion
	move.l	d4,a0
	move.l	d0,S_Cst1(a0)
	move.l	d1,S_Cst2(a0)
	exg	d0,d1
	bsr	OutLong
	move.w	Cmvid3(pc),d0		Move.l	#xxx,d3
	bsr	OutWord
	move.l	d1,d0
	bsr	OutLong
	moveq	#F_MoveD,d3
	rts

;	Constante double float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FnConstDouble
	moveq	#1,d2
	bsr	MathSimple
	tst.b	MathFlags(a5)
	bpl.s	.Float
	move.l	d4,a0
	move.w	Cmvid4(pc),d0		move.l	#xxxx,d4
	bsr	OutWord
	bsr	GetLong
	move.l	d0,S_Cst1(a0)
	move.l	d0,d1
	bsr	GetLong
	move.l	d0,S_Cst2(a0)
	bsr	OutLong
	move.w	Cmvid3(pc),d0		move.l	#xxxx,d3
	bsr	OutWord
	move.l	d1,d0
	bsr	OutLong
	moveq	#F_MoveD,d3
	rts
.Float	move.w	Cmvid3(pc),d0		Move.l	#xxx,d3
	bsr	OutWord
	bsr	GetLong
	move.l	d0,d1
	bsr	GetLong
	exg.l	d0,d1
	bsr	Double2Float
	move.l	d4,a0
	move.l	d0,S_Cst1(a0)
	bsr	OutLong
	moveq	#F_MoveF,d3
	rts

; 	Constante Chaine
; ~~~~~~~~~~~~~~~~~~~~~~
FnConstChaine
	move.w	Cmvid3(pc),d0		move.l	#xxxx,d3
	bsr	OutWord
	bsr	Relocation		Force la relocation
	move.l	A_Chaines(a5),d0	Marque l'adresse dans les
	move.l	d0,a0			chaines dans l'objet
	move.l	a6,(a0)
	sub.l	B_Chaines(a5),d0	En relatif pour la relocation
	or.l	#Rel_Chaines,d0
	bsr	OutLong
	addq.l	#4,A_Chaines(a5)	Chaine suivante
; Saute la chaine
	bsr	GetWord
	btst	#0,d0
	beq.s	FCh1
	addq.w	#1,d0
FCh1	add.w	d0,a6
; Flags chaine
	moveq	#2,d2
	moveq	#F_MoveS,d3
	rts

;	GLOBAL / SHARED -> saute les variables
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InGlobal
InShared
	addq.l	#2,a6
	bsr	GetWord
	move.w	d0,d3
	bsr	GetWord
	moveq	#0,d2
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
; Code de VADR0
	moveq	#0,d0
	tst.w	d3			Ne doit _JAMAIS_ se produire
	bmi	Err_Syntax
	move.w	d3,d0			Va marquer le niveau zero
	move.l	B_FlagVarG(a5),a0
	bsr	VMark
; Un tableau ()
CSh1	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	InShared
	cmp.w	#_TkPar1,d0
	bne.s	CSh2
	addq.l	#2,a6
	bra.s	CSh1
CSh2	subq.l	#2,a6
	rts

;	Variable en instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InVariable
	bsr	OutLea
InVariable2
	move.l	a6,-(sp)
	bsr	SoVar
	move.w	d0,d1
	and.w	#$000F,d0
	move.w	d0,Type_Voulu(a5)	Marque le type desir�
	move.w	d1,-(sp)
	bsr	Fn_Evalue_Voulu		Evalue correctement
	bsr	Optimise_D2		Optimise le dernier
	move.w	(sp)+,d1
	btst	#6,d1			Un tableau
	beq.s	.Notab
	bsr	Push_D2			Si tableau, pousse l'operande
.Notab	move.l	(sp),d0			Reprend l'adresse de la variable
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr			Cherche l'adresse
	move.l	(sp)+,a6
	cmp.w	#1,Type_Voulu(a5)
	bne.s	.J
	tst.b	MathFlags(a5)
	bmi.s	InVDble
; Une variable simple
.J	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.Locale
	bra.s	.Globale
	bra.s	.Tableau
.Locale
	move.w	Cmvd32a6(pc),d0
	bra.s	.Fin
.Globale
	move.w	Cmvd32a0(pc),d0
.Fin	bsr	OutWord
	move.w	d3,d0
	bra	OutWord
.Tableau
	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
	move.w	Cmva3p0a0(pc),d0
	bra	OutWord
; Une variable double
InVDble
.J	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.Locale
	bra.s	.Globale
	bra.s	.Tableau
.Locale
	move.w	Cmvd32a6(pc),d0
	move.w	Cmvd42a6(pc),d1
	bra.s	.Fin
.Globale
	move.w	Cmvd32a0(pc),d0
	move.w	Cmvd42a0(pc),d1
.Fin	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	move.w	d3,d0
	addq.w	#4,d0
	bra	OutWord
.Tableau
	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
	move.w	Cmva3pa0p(pc),d0
	bsr	OutWord
	move.w	Cmva3pa0(pc),d0
	bra	OutWord

;	Met l'adresse de base d'une variable en A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ArrayBase
	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	AdA0L
	bra.s	.Ici
	rts
.Ici	move.w	Cmvd7a0(pc),d0		Met le move.l d7,a0
	bsr	OutWord
	bra.s	AdA0G
;	Met l'adresse de base d'une variable en A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AdBase	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	AdA0L
	bra.s	AdA0G
	rts
; Variable GLOBALE
AdA0G	move.w	Clea2a0a0(pc),d0
	bra.s	IVr2
; Variable LOCALE
AdA0L	move.w	Clea2a6a0(pc),d0
IVr2	bsr	OutWord
	move.w	d3,d0
	bra	OutWord

;	Met l'adresse d'une variable en A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AdToA0	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	AdA0L
	bra.s	AdA0G
	move.w	#L_GetTablo,d0
	bra	Do_JsrLibrary

;	Variable en fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
FnVariable
	bsr	VarAdr
	cmp.b	#1,d2
	bne.s	.skip
	bsr	MathSimple
	tst.b	MathFlags(a5)
	bmi.s	FnVDble
; Variable simple, sur 1 mot long
.skip	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.Locale
	bra.s	.Globale
	bra.s	.Tableau
.Globale
	move.w	Cmv2a0d3(pc),d0
	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	move.l	d4,a0
	move.w	d3,S_Var(a0)
	moveq	#F_Globale,d3
	rts
.Locale
	move.w	Cmv2a6d3(pc),d0
	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	move.l	d4,a0
	move.w	d3,S_Var(a0)
	moveq	#F_Locale,d3
	rts
.Tableau
	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
	move.w	Cmv0a0d3(pc),d0
	bsr	OutWord
	moveq	#F_Tableau,d3
	rts
; Variable double, sur 2 mots longs
FnVDble	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.Locale
	bra.s	.Globale
	bra.s	.Tableau
.Globale
	move.w	Cmv2a0d3(pc),d0
	move.w	Cmv2a0d4(pc),d1
	bra.s	.Fin
.Locale
	move.w	Cmv2a6d3(pc),d0
	move.w	Cmv2a6d4(pc),d1
.Fin	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	move.w	d1,d0
	bsr	OutWord
	move.w	d3,d0
	addq.w	#4,d0
	bsr	OutWord
	move.l	d4,a0
	move.w	d3,S_Var(a0)
	moveq	#F_Autre,d3
	rts
.Tableau
	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
	move.w	Cmva0pd3(pc),d0
	bsr	OutWord
	move.w	Cmva0d4(pc),d0
	bsr	OutWord
	moveq	#F_Autre,d3
	rts

;	Saute une variable
; ~~~~~~~~~~~~~~~~~~~~~~~~
SoVar	bsr	GetWord
	bsr	GetWord
	moveq	#0,d2
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
	btst	#6,d2
	beq.s	.SoV3
; Saute les params du tableau
	moveq	#0,d1
.Loop	bsr	GetWord
	cmp.w	#_TkPar1,d0
	beq.s	.Plus
	cmp.w	#_TkPar2,d0
	beq.s	.Moins
	bsr	SoInst
	bra.s	.Loop
.Plus	addq.w	#1,d1
	bra.s	.Loop
.Moins	subq.w	#1,d1
	bne.s	.Loop
; Met le flag float!
.SoV3	move.w	d2,d0
	rts

;	SAUTE L'INSTRUCTION D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SoInst:	tst.w	d0
	beq	T0
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
T0:	rts
T2:	addq.l	#2,a6			Diverse tailles d'instructions
	rts
T4:	addq.l	#4,a6
	rts
T8:	addq.l	#8,a6
	rts
T6:	addq.l	#6,a6
	rts
TCh:	bsr	GetWord			Une chaine
	add.w	d0,a6
	move.w	a6,d0
	btst	#6,d0
	beq.s	T0
	addq.l	#1,a6
	rts
TVar:	addq.l	#2,a6			Une variable
	bsr	GetWord
	lsr.w	#8,d0
	add.w	d0,a6
	rts

;	Trouve l'adresse d'une variable D2-D3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VarAdr	bsr	GetWord
	move.w	d0,d3
	bsr	GetWord
	moveq	#0,d2
	move.b	d0,d2
	lsr.w	#8,d0
	add.w	d0,a6
	btst	#6,d2
	bne	VAdrT
VAdr0	moveq	#0,d0
	tst.w	d3
	bmi.s	VAdrL
; >0: Variable LOCALE
	move.w	d3,d0
	move.l	A_FlagVarL(a5),a0
	bsr	VMark
	addq.w	#2,d3
	and.w	#$0F,d2			Ne garde que le flag
	moveq	#0,d1
	rts
; <0: Variable GLOBALE
VAdrL	neg.w	d3
	subq.w	#1,d3
	move.w	d3,d0
	move.l	B_FlagVarG(a5),a0
	bsr	VMark
	addq.w	#2,d3
	and.w	#$0F,d2			Ne garde que le flag
 	move.w	Cmvd7a0(pc),d0		move.l	d7,a0
	bsr	OutWord
	moveq	#2,d1
	rts
; Variable tableau
VAdrT	addq.l	#2,a6
	clr.w	-(sp)
	movem.w	d2/d3,-(sp)
.Loop	addq.w	#1,4(sp)		Evalue les parametres
	bsr	Expentier		Un entier
	bsr	Push_D2			Pousse!
	cmp.w	#_TkPar2,Last_Token(a5)	Termine?
	beq.s	.Skip
	bsr	GetWord			Une virgule!
	cmp.w	#_TkVir,d0
	beq.s	.Loop
	bra	Err_Syntax		???
.Skip	movem.w	(sp)+,d2/d3
	bsr	VAdr0
	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.Local
	bra.s	.Global
.Local	move.w	Clea2a6a0(pc),d0
	bra.s	.Out
.Global	move.w	Clea2a0a0(pc),d0
.Out	bsr	OutWord
	move.w	d3,d0
	bsr	OutWord
	move.w	(sp)+,d0		Nombre de dimensions
	swap	d0
	move.w	d1,d0			Type de la variable
	moveq	#4,d1			Type reel= tableau
	rts

;	Trouve l'adresse d'une variable D2-D3, SPECIAL FN
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
* >=0: Variable LOCALE
	move.w	d3,d0
	move.l	A_FlagVarL(a5),a0
	bsr	.VMark
	addq.w	#2,d3
	moveq	#0,d1
	rts
* <0: Variable GLOBALE
.VAdrL	neg.w	d3
	subq.w	#1,d3
	move.w	d3,d0
	move.l	B_FlagVarG(a5),a0
	bsr.s	.VMark
 	move.l	Cmvd7a0(pc),d0		move.l	d7,a0
	bsr	OutLong
	addq.w	#2,d3
	moveq	#2,d1
	rts
* PREND le flag de la variable SPECIAL Def Fn
.VMark	addq.w	#6,d0
	cmp.b	#1,d2
	bne.s	.Ent
	tst.b	MathFlags(a5)		Si double precision: +10!
	bpl.s	.Ent
	addq.w	#4,d0
.Ent	divu	#6,d0
	lea	2-1(a0,d0.w),a0
	moveq	#0,d2
	move.b	(a0),d2
	rts

; 	Marque le flag de la variable
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VMark	addq.w	#6,d0			Pour faire multiple de 6
	cmp.b	#1,d2
	bne.s	.Ent
	tst.b	MathFlags(a5)		Si double precision: +10!
	bpl.s	.Ent
	addq.w	#4,d0
.Ent	cmp.w	(a0),d0
	bcs.s	.Skip1
	move.w	d0,(a0)
.Skip1	divu	#6,d0			Pointe la table
	and.w	#%01001111,d2		Garde le flag tableau
	lea	2-1(a0,d0.w),a0
	move.b	d2,(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INSTRUCTIONS SPECIFIQUES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	DIR
; ~~~~~~~~~
InDir	bset	#F_Input,Flag_Libraries(a5)
	bra.s	InJmp
;	Dialogue
; ~~~~~~~~~~~~~~
InDialogs
	bset	#F_Dialogs,Flag_Libraries(a5)
InJmp	lea	0(a0,d0.w),a0		Pointe l'instruction
	move.w	2(a0),d0		D0= # de fonction
	bra	InNormal2

; 	Set double precision
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
InSetDouble
	bra	MathDouble

;	FOLLOW
; ~~~~~~~~~~~~
InFollow
	bsr	Finie
	subq.l	#2,a6
	beq.s	.Skip
	bsr	StockOut
.Loop	bsr	New_Evalue
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	.Loop
	subq.l	#2,a6
.Skip	rts

;	SET ACCESSORY
; ~~~~~~~~~~~~~~~~~~~
InSetAccessory
	move.b	#1,Flag_Accessory(a5)
	rts

;	SET BUFFER
; ~~~~~~~~~~~~~~~~
InSetBuffer
	addq.l	#2,a6
	bsr	GetLong
	move.l	d0,L_Buf(a5)
	rts

;	SET STACK *** A terminer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InSetStack
	addq.l	#2,a6
	bsr	GetLong
	rts

;	DIM
; ~~~~~~~~~
InDim	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr			Adresse de base
	swap	d0
	move.w	d0,d1
	move.w	Cmvqd0(pc),d0		Nombre de dimensions
	move.b	d1,d0
	bsr	OutWord
	move.w	#L_InDim,d0
	bsr	Do_JsrLibrary
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	InDim
	subq.l	#2,a6
	rts

;	=FN
; ~~~~~~~~~
FnFn	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	SoVar
	clr.w	-(sp)
	bsr	GetWord
	cmp.w	#_TkPar1,d0
	bne.s	CFn2
; Prend les parametres
CFn1	addq.w	#1,(sp)
	bsr	New_Evalue
	bsr	Optimise_D2
	bsr	Push_D2
	move.w	Cmvwima3(pc),d0
	bsr	OutWord
	and.w	#$0F,d2
	move.w	d2,d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	CFn1
; Appelle la fonction
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
	move.w	#L_FnFn,d0
	bsr	Do_JsrLibrary
	and.w	#$03,d2
	bra	Set_F_Autre

;	DEF FN
; ~~~~~~~~~~~~
InDefFn	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	move.l	a0,-(sp)		Adresse du flag!
	bsr	AdBase
	lea	CdDfn1(pc),a0
	bsr	OutCode
	move.l	a4,-(sp)
	bsr	GetWord
	cmp.w	#_TkPar1,d0
	bne.s	Cdfn2
* Prend les variables (� l'envers)
	clr.w	N_Dfn(a5)
Cdfn0	addq.l	#2,a6
	move.l	a6,-(sp)
	addq.w	#1,N_Dfn(a5)
	bsr	SoVar
	bsr	GetWord
	cmp.w	#_TkVir,d0
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
Cdfn2	bsr	New_Evalue
	bsr	Optimise_D2
	move.l	4(sp),a0
	and.b	#%00000011,d2
	bset	#3,d2
	move.b	d2,(a0)
	move.w	Crts(pc),d0
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


;	SWAP
; ~~~~~~~~~~
InSwap	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdToA0
	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
	addq.l	#4,a6
	bsr	VarAdr
	move.w	d2,-(sp)
	bsr	AdToA0
	move.w	#L_InSwap,d0
	cmp.w	#1,(sp)+
	bne	Do_JsrLibrary
	tst.b	MathFlags(a5)
	bpl	Do_JsrLibrary
	move.w	#L_InSwapD,d0
	bra	Do_JsrLibrary

;	ADD a,b
; ~~~~~~~~~~~~~
InAdd2	bsr	OutLea
	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	SoVar
	btst	#6,d2			Un tableau?
	beq.s	.Patab
	bsr	Fn_Expentier		Oui, pousse l'operande
	bsr	Push_D2
	bra.s	.Suite
.Patab	bsr	Fn_Expentier
.Suite	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	move.l	(sp)+,a6
	lea	CdAdd2(pc),a0
	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	ILocal
	bra.s	IGlobal
	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
	move.l	8(a0),d0
	bra	OutLong

;	INC
; ~~~~~~~~~
InInc	pea	CdInc(pc)
	bra.s	CIncDec
InDec	pea	CdDec(pc)
CIncDec	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	move.l	(sp)+,a0
	jmp	IJmp(pc,d1.w)
IJmp	bra.s	ILocal
	bra.s	IGlobal
; Tableau
	move.w	#L_GetTablo,d0
	bsr	Do_JsrLibrary
	move.w	8(a0),d0
	bra	OutWord
; Globale
IGlobal	move.w	4(a0),d0
	bra.s	ISuite
; Locale
ILocal	move.w	(a0),d0
ISuite	bsr	OutWord
	move.l	d3,d0
	bra	OutWord
; Codes
CdInc	addq.l	#1,2(a6)		0
	addq.l	#1,2(a0)		4
	addq.l	#1,(a0)			8
CdDec	subq.l	#1,2(a6)
	subq.l	#1,2(a0)
	subq.l	#1,(a0)
CdAdd2	add.l	d3,2(a6)		0
	add.l	d3,2(a0)		4
	move.l	(a3)+,d0		8
	add.l	d0,(a0)

;	ADD a,b,c to d
; ~~~~~~~~~~~~~~~~~~~~
InAdd4	bsr	OutLea
	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	SoVar
	bsr	Fn_Expentier
	bsr	Push_D2
	bsr	Fn_Expentier
	bsr	Push_D2
	bsr	Fn_Expentier
	bsr	Push_D2
	move.l	(sp),d0
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	VarAdr
	bsr	AdToA0
	move.l	(sp)+,a6
	move.w	#L_InAdd4,d0
	bra	Do_JsrLibrary

;	SORT a()
; ~~~~~~~~~~~~~~
InSort	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdBase
	move.w	Cmvqd2(pc),d0
	and.w	#$000F,d2
	move.b	d2,d0
	bsr	OutWord
	move.w	#L_InSort,d0
	bra	Do_JsrLibrary

;	DATA
; ~~~~~~~~~~
InData	addq.l	#2,a6
	move.l	Cbra(pc),d0
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
CDt2	move.w	Cnop(pc),d0		Signal-> DATAS!
	bsr	OutWord
	bsr	New_Evalue		Evalue le data
	bsr	Optimise_D2
	move.w	Cmvqd2(pc),d0		Marque le type >>> D2
	and.w	#$000F,d2
	move.b	d2,d0
	bsr	OutWord
	move.w	Cleaa2(pc),d0		Lea prochain data, a2
	bsr	OutWord
	bsr	Relocation
	move.l	a4,A_JDatas(a5)
	move.l	A_EDatas(a5),d0
	bsr	OutLong
	move.w	Crts(pc),d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	CDt1
	subq.l	#2,a6
; Met le BRA
	move.l	a4,d0
	move.l	(sp),a4
	move.l	d0,(sp)
	subq.l	#2,a4
	sub.l	a4,d0
	bsr	OutWord
	move.l	(sp)+,a4
	rts

;	Cree la routine NO DATA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

;	RESTORE
; ~~~~~~~~~~~~~
InRestore
	bsr	OutLea
	move.w	#L_InRestore,d1
	bsr	Finie
	subq.l	#2,a6
	beq.s	.Skip
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_InRestore1,d1
.Skip	move.w	d1,d0
	bra	Do_JsrLibrary

;	READ
; ~~~~~~~~~~
InRead	bsr	OutLea
	addq.l	#2,a6
	bsr	VarAdr
	bsr	AdToA0
	and.w	#$000F,d2
	move.w	#L_InRead,d0
	add.w	d2,d0
	bsr	Do_JsrLibrary
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	InRead
	subq.l	#2,a6
	rts

;	LPRINT
; ~~~~~~~~~~~~
InLPrint
	move.w	#1,-(sp)
	bra.s	Cp2
;	PRINT #
; ~~~~~~~~~~~~~
InHPrint
	move.w	#-1,-(sp)
	bsr	Expentier
	addq.l	#2,a6
	move.w	#L_InPrintH,d0
	bsr	Do_JsrLibrary
	bra.s	Cp2
;	PRINT
; ~~~~~~~~~~~
InPrint clr.w	-(sp)
; Prend les expressions
Cp2   	bsr	Finie
	bne.s	Cp3
	subq.l	#2,a6
	move.w	#L_CRPrint,d0
	bsr	Do_JsrLibrary
	bra	Cp13
Cp3	bsr	OutLea			Marque l'endroit dans le print
* USING: prend la chaine et marque le using
	clr.w	-(sp)
	cmp.w 	#_TkUsing,d0
	bne.s 	Cp4
	subq.w	#1,(sp)
	bsr	New_Evalue
	bsr	Push_D2			Pousse !
	addq.l	#4,a6
; Prend l'expression
Cp4     subq.l	#2,a6
	bsr 	New_Evalue		Reste en D2
	bsr	Optimise_D2
        subq.w	#1,d2
	bmi.s	Cp5
	beq.s	Cp6
; Chaine
	tst.w	(sp)+
	bne.s	Cp4a
	move.w	#L_PrintS,d0		; Pas using
	tst.w	(sp)
	beq.s	Cp7a
	move.w	#L_PrintS,d0		; ILLEGAL!!
	tst.w	(sp)
	bpl.s	Cp7a
	move.w	#L_HPrintS,d0
	bra.s	Cp7a
Cp4a	move.w	#L_UsingS,d0		; Using
	bra.s	Cp7a
; Entier
Cp5	bclr	#6,2(sp)
	move.w	#L_PrintE,d0
	bsr	Do_JsrLibrary
	move.w	#L_UsingC,d0
        bra.s 	Cp7
; Float
Cp6	bsr	MathSimple
	bclr	#6,2(sp)
	move.w	#L_PrintF,d0
	bsr	Do_JsrLibrary
	move.w	#L_UsingC,d0
Cp7:    and.w	(sp)+,d0
	beq.s	Cp7b
Cp7a	bsr 	Do_JsrLibrary
Cp7b
; Prend le separateur
Cp8:    bsr 	GetWord
	cmp.w 	#_TkPVir,d0
        beq.s 	Cp13
	bclr	#6,(sp)
        cmp.w	#_TkVir,d0
        beq.s 	Cp11
        subq.l 	#2,a6
	move.w	#L_PrtRet,d0
        bra.s 	Cp12
Cp11:   move.w 	#L_PrtVir,d0
Cp12:   bsr 	Do_JsrLibrary

; Imprime!
Cp13	move.w	#L_PrintX,d0
	tst.w	(sp)
	beq.s	Cp14
	move.w	#L_LPrintX,d0
	tst.w	(sp)
	bpl.s	Cp14
	bset	#6,(sp)
	bne.s	Cp15
	move.w	#L_HPrintX,d0
Cp14	bsr	Do_JsrLibrary
Cp15
* Encore quelque chose a imprimer?
	bsr 	Finie
        bne	Cp3
* Termine!
	subq.l	#2,a6
	tst.w	(sp)+
	rts


;----------------------------------> INPUT #
InInputD
	move.w	#-1,-(sp)
	move.w	#L_InInputH,-(sp)
	bra.s	CIn0
;----------------------------------> INPUT #
InLineInputD
	move.w	#-1,-(sp)
	move.w	#L_InLineInputH,-(sp)
CIn0	bsr	OutLea
	bsr	StockOut
	move.l	a6,-(sp)
	bsr	Expentier
	bsr	RestOut
	addq.l	#2,a6
	bra.s	CIn7
;----------------------------------> LINE INPUT
InLineInput
	clr.w	-(sp)
	move.w	#L_InLineInput,-(sp)
        bra.s 	CIn1
;----------------------------------> INPUT
InInput
	clr.w	-(sp)
	move.w	#L_InInput,-(sp)
CIn1:  	bset	#F_Input,Flag_Libraries(a5)
	bsr	OutLea
	bsr	GetWord
	subq.l	#2,a6
; Saute la chaine alphanumerique
	clr.l	-(sp)
	cmp.w	#_TkVar,d0
	beq.s	CIn7
	move.l	a6,(sp)
	bsr	StockOut
	bsr	New_Evalue
	bsr	RestOut
	addq.l	#2,a6
; Stocke la liste des variable ---> -(A3) / moveq #NB,d6
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
        cmp.w	#_TkVir,d0
        beq.s 	CIn8
CIn9:   subq.l 	#2,a6
; Input clavier...
	tst.w	8(sp)
	bne.s	CIn11
; Evalue la chaine
	move.l	2(sp),d0
	bne.s	CIn10
	move.w	Cmvqd3(pc),d0
	bsr	OutWord
	bra.s	CIn12
CIn10	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	New_Evalue
	move.l	2(sp),a6
	bra.s	CIn12
; Evalue le fichier
CIn11	move.l	2(sp),d0
	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	Expentier
	move.l	2(sp),a6
; Moveq nombre de params >>> D5
CIn12	move.w 	Cmvqd5(pc),d0
        move.w 	(sp)+,d1
        move.b 	d1,d0
        bsr 	OutWord
	addq.l	#4,sp
; Appele la fonction
	move.w	(sp)+,d0
	bsr	Do_JsrLibrary
; Un point virgule?
	tst.w	(sp)+
	bne	CInX
	bsr	GetWord
	cmp.w	#_TkPVir,d0
	beq.s	CInX
	move.w	#L_CRet,d0
	bsr	Do_JsrLibrary
	subq.l	#2,a6
CInX	rts
CdInp	move.w 	#$ffff,-(a3)
        move.l 	a0,-(a3)
        dc.w 	$4321



;	FIELD
; ~~~~~~~~~~~
InField	bsr	OutLea
	bsr	StockOut
	move.l	a6,-(sp)
	bsr	Expentier
	bsr	RestOut
	addq.l	#2,a6
	clr.w	-(sp)
Cfld1	addq.w	#1,(sp)
	bsr	Expentier
	bsr	Push_D2
	addq.l	#4,a6
	bsr	VarAdr
	bsr	AdToA0
	move.w	Cmva0ma3(pc),d0
	bsr	OutWord
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	Cfld1
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
	move.w	#L_InField,d0
	bra	Do_JsrLibrary

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Ecrans / Palettes
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	PALETTEs
; ~~~~~~~~~~~~~~
InPalettes
	move.w	2(a0,d0.w),-(sp)
 	bsr	OutLea
CPal0	clr.w	-(sp)
CPal1	addq.w	#1,(sp)
	bsr	Expentier
	bsr	Push_D2
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	CPal1
	subq.l	#2,a6
	move.w	Cmvqd0(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	(sp)+,d0
	bra	Do_JsrLibrary

;	FADE
; ~~~~~~~~~~
InFade	bsr	OutLea
	bsr	Expentier		La duree
	bsr	Push_D2			Poussee
	bsr	GetWord
	move.w	#L_InFadePal,-(sp)
	cmp.w	#_TkVir,d0		Une palette >>> routine palette!
	beq.s	CPal0
	cmp.w	#_TkTo,d0		To?
	beq.s	CFad1
	subq.l	#2,a6
	move.w	#L_InFade1,(sp)		Fade X
	bra	CFadX
CFad1	move.w	#L_InFade2,(sp)
	bsr	Expentier
	bsr	Push_D2
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkVir,d0
	bne.s	CFadX
	move.w	#L_InFade3,(sp)
	bsr	Fn_Expentier
CFadX	move.w	(sp)+,d0
	bra	Do_JsrLibrary

;	Polyline / Polygone
; ~~~~~~~~~~~~~~~~~~~~~~~~~
InPoly	move.w	2(a0,d0.w),-(sp)	Prend le token
	clr.l	-(sp)
	bsr	OutLea
	bsr	GetWord
	cmp.w	#_TkTo,d0
	beq.s	CPol1
	subq.l	#2,a6
	move.w	#-1,2(sp)
	bsr	Expentier
	bsr	Push_D2
	bsr	Fn_Expentier
	bsr	Push_D2
	addq.w	#1,(sp)
	addq.l	#2,a6
CPol1	addq.w	#1,(sp)
	bsr	Expentier
	bsr	Push_D2
	bsr	Fn_Expentier
	bsr	Push_D2
	bsr	GetWord
	cmp.w	#_TkTo,d0
	beq.s	CPol1
	subq.l	#2,a6
	move.w	Cmvqd0(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	Cmvqd1(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	(sp)+,d0
	bra	Do_JsrLibrary



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	BSET / BCLR etc..
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	BSET/ROR etc...
; ~~~~~~~~~~~~~~~~~
FnBtst	movem.l	d2-d7,-(sp)
	addq.l	#2,a6
	move.w	0(a0,d0.w),d0
	bsr	BsRout
	movem.l	(sp)+,d2-d7
	moveq	#0,d2
	bra	Set_F_Autre
InBsetRor
	bsr	OutLea
	move.w	2(a0,d0.w),d0		Prend le token

BsRout	move.w	d0,-(sp)
	move.l	A_Stock(a5),-(sp)
	bsr	Expentier
	bsr	Push_D2
	addq.l	#2,a6
	bsr	GetWord
	cmp.w	#_TkVar,d0
	bne.s	BsR3
; Une variable, vraiment?
BsR1	bsr	StockOut
	move.l	a6,-(sp)
	bsr	VarAdr
	bsr	AdToA0
	bsr	Finie
	bne.s	BsR2
	subq.l	#2,a6
BsR0	addq.l	#4,sp
	bra.s	BsR4
BsR2	cmp.w	#_TkPar2,d0
	beq.s	BsR0
	bsr	RestOut
	move.l	(sp)+,a6
; Une adresse
BsR3	addq.w	#1,4(sp)		Pointe la fonction suivante
	subq.l	#2,a6			Revient sur l'expression
	bsr	Expentier
* Fin...
BsR4	move.l	(sp)+,A_Stock(a5)
	move.w	(sp)+,d0
	bra	Do_JsrLibrary

;	CALL
; ~~~~~~~~~~
InCall	bsr	OutLea
	move.w	Cmva3msp(pc),d0
	bsr	OutWord
	move.l	a6,-(sp)
	bsr	StockOut
	bsr	Expentier
	bsr	RestOut
CCal0	bsr	GetWord
	cmp.w	#_TkVir,d0
	bne.s	CCal1
	bsr	New_Evalue
	bsr	Optimise_D2
	bsr	Push_D2
	bra.s	CCal0
CCal1	move.l	(sp)+,d0
	pea	-2(a6)
	move.l	d0,a6
	bsr	Expentier
	move.l	(sp)+,a6
	move.w	#L_InCall,d0
	bsr	Do_JsrLibrary
	move.w	Cmvpspa3(pc),d0
	bra	OutWord

;	PROCEDURE LANGAGE MACHINE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In_apml_
	lea	Proc_Start(a5),a0	Recharge la position de l'objet
	move.l	(a0)+,a3		4  S_a3
	move.l	(a0)+,a4		8  S_a4
	move.l	(a0)+,OldRel(a5)	12 S_OldRel
	move.l	(a0)+,A_LibRel(a5)	16 S_LibRel
	move.l	(a0)+,Lib_OldRel(a5)	20 S_LibOldRel
	move.l	(a0)+,A_Chaines(a5)	24 S_Chaines
	lea	.InML(pc),a0		Copie la routine d'appel
	bsr	OutCode
	addq.l	#2,a6			Saute le code
	move.l	F_Proc(a5),d3		Copie la procedure entiere
	sub.l	a6,d3
	bsr	Copy_Source
	addq.l	#4,sp			Rebranche a la boucle procedures
	bra	PChr1
; Routine d'appel de procedure langage machine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.InML	movem.l	a4-a6/d6/d7,-(sp)
	lea	CallReg(a5),a6
	move.l	a6,-(sp)
	movem.l	(a6),d0-d7/a0-a2
	bsr.s	.Routine
	move.l	(sp)+,a6
	movem.l	d0-d7/a0-a2,(a6)
	movem.l	(sp)+,a4-a6/d6-d7
	move.l	d0,ParamE(a5)
	move.l	BasA3(a5),a3
	rts
.Routine
	dc.w	$4321

;	STRUC= / STRUC$=
; ~~~~~~~~~~~~~~~~~~~~~~
InStruc	bsr	OutLea
	bsr	GStruc
	move.w	Cmvd3ma3(pc),d0
	bsr	OutWord
	bsr	Fn_Expentier
	move.w	#L_InStruc,d0
	bra	Do_JsrLibrary
InStrucD
	bsr	OutLea
	bsr	GStruc
	move.w	Cmvd3ma3(pc),d0
	bsr	OutWord
	bsr	Fn_New_Evalue
	move.w	#L_InStrucD,d0
	bra	Do_JsrLibrary

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MID LEFT RIGHT en instruction
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InMid3	move.w	#L_InMid3,-(sp)
	bra.s	CIMid
InMid2	move.w	#L_InMid2,-(sp)
	bra.s	CIMid
InLeft	move.w	#L_InLeft,-(sp)
	bra.s	CIMid
InRight	move.w	#L_InRight,-(sp)
CIMid	bsr	OutLea
	addq.l	#4,a6
	move.l	a6,-(sp)
	bsr	SoVar
	addq.l	#2,a6
	bsr	Expentier
	bsr	Push_D2
	cmp.w	#L_InMid3,4(sp)
	bne.s	CIMd
	addq.l	#2,a6
	bsr	Expentier
	bsr	Push_D2
CIMd	bsr	Fn_New_Evalue
	bsr	Push_D2
	move.l	a6,d0
	move.l	(sp)+,a6
	move.l	d0,-(sp)
	bsr	VarAdr
	bsr	AdToA0
	move.l	(sp)+,a6
	move.w	(sp)+,d0
	bra	Do_JsrLibrary

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	CHANNEL x To
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InChannel
	bsr	OutLea
	bsr	Expentier
	bsr	Push_D2
	addq.l	#2,a6
	bsr	GetWord
	move.w	#L_ChannelToSprite,d1
	cmp.w	#_TkSpr,d0
	beq.s	CChaX
	move.w	#L_ChannelToBob,d1
	cmp.w	#_TkBob,d0
	beq.s	CChaX
	move.w	#L_ChannelToSDisplay,d1
	cmp.w	#_TkScD,d0
	beq.s	CChaX
	move.w	#L_ChannelToSOffset,d1
	cmp.w	#_TkScO,d0
	beq.s	CChaX
	move.w	#L_ChannelToSSize,d1
	cmp.w	#_TkScS,d0
	beq.s	CChaX
	move.w	#L_ChannelToRainbow,d1
CChaX	move.w	d1,-(sp)
	bsr	Expentier
	move.w	(sp)+,d0
	bra	Do_JsrLibrary


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INSTRUCTIONS MENU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;-----> MENU$(,,)=
InMenu	bset	#F_Menus,Flag_Libraries(a5)
	bsr	OutLea
	move.w	#L_InMenu-1,-(sp)
	bsr	MnPar
	subq.l	#2,a4
	move.w	d1,-(sp)
	addq.l	#2,a6
CMenL	addq.w	#1,2(sp)		Recupere les parametres
	bsr	New_Evalue
	bsr	Optimise_D2
	bsr	Push_D2
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	CMenL
	subq.l	#2,a6
	move.w	Cmvqd5(pc),d0		Nombre de dimensions
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	move.w	(sp)+,d0
	bra	Do_JsrLibrary

;-----> MENU DEL
InMenuDel
	bset	#F_Menus,Flag_Libraries(a5)
	bsr	OutLea
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkPar1,d0
	beq.s	CMnD1
	move.w	#L_InMenuDel,d0
	bra	Do_JsrLibrary
CMnD1	bsr	MnPar
	move.w	#L_InMenuDel1,d0
	bra	Do_JsrLibrary

;-----> SET MENU
InSetMenu
	bset	#F_Menus,Flag_Libraries(a5)
	bsr	OutLea
	move.l	a6,-(sp)		Saute les parametres menu
	bsr	StockOut
	bsr	MnPar
	bsr	RestOut
	bsr	Fn_Expentier		Prend le 1er parametre
	bsr	Push_D2
	bsr	Fn_Expentier		Prend le 2eme parmetre
	bsr	Push_D2
	move.l	(sp),d0			Reprend les params menu
	move.l	a6,(sp)
	move.l	d0,a6
	bsr	MnPar
	move.l	(sp)+,a6
	move.w	#L_InSetMenu,d0
	bra	Do_JsrLibrary

;-----> Instruction flags
InMenuFlags
	bset	#F_Menus,Flag_Libraries(a5)
	move.w	2(a0,d0.w),-(sp)	Prend le token de l'instruction
	bsr	OutLea
	bsr	MnPar
	move.w	(sp)+,d0
	bra	Do_JsrLibrary

;-----> MENU KEY
InMenuKey
	bset	#F_Menus,Flag_Libraries(a5)
	bsr	OutLea
	move.l	a6,-(sp)
	bsr	StockOut
	bsr	MnPar
	bsr	GetWord
	cmp.w	#_TkTo,d0
	beq.s	Cmnk1
* MENU KEY (,,) seul
	bsr	SautOut
	subq.l	#2,a6
	addq.l	#4,sp
	move.w	#L_InMenuKey,d0
	bra	Do_JsrLibrary
* MENU KEY (,,) TO
Cmnk1	bsr	RestOut
	move.w	#L_InMenuKey1,-(sp)
	bsr	New_Evalue
	cmp.b	#1,d2			Entier ou chaine
	bne.s	.Skip
	bsr	D2_Entier
.Skip	bsr	Optimise_D2		Optimise
	bsr	Push_D2			Pousse
	cmp.b	#2,d2			Chaine!
	beq.s	Cmnk2
	move.w	#L_InMenuKey2,(sp)
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkVir,d0
	bne.s	Cmnk2
	move.w	#L_InMenuKey3,(sp)
	bsr	Fn_Expentier
	bsr	Push_D2
Cmnk2	move.l	2(sp),d0
	move.l	a6,2(sp)
	move.l	d0,a6
	bsr	MnPar
	move.w	(sp)+,d0
	bsr 	Do_JsrLibrary
	move.l	(sp)+,a6
	rts

;-----> ON MENU got/gosub/proc
InOnMenu
	bset	#F_Menus,Flag_Libraries(a5)
	bsr	OutLea
	bsr	GetWord
	moveq	#-1,d1
	move.w	N_Proc(a5),d7
	cmp.w	#_TkGto,d0
	beq.s	Com0
	addq.l	#1,d1
	cmp.w	#_TkGsb,d0
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
	cmp.w	#_TkVir,d0
	beq.s	Com1
	subq.l	#2,a6
	move.w	Cmvqd0(pc),d0
	move.b	3(sp),d0
	bsr	OutWord
	move.w	Cmvqd1(pc),d0
	move.b	1(sp),d0
	bsr	OutWord
	addq.l	#4,sp
	move.w	#L_InOnMenu,d0
	bra	Do_JsrLibrary


;-----> Prend les parametres menus
MnPar	bsr	GetWord
	cmp.w	#_TkPar1,d0
	beq.s	MPar1
; Une dimension
	subq.l	#2,a6
	bsr	Expentier
	move.w	Cmvqd5(pc),d0
	bra	OutWord
; Un objet de menu
MPar1	clr.w	-(sp)
MPar2	addq.w	#1,(sp)
	bsr	Expentier
	bsr	Push_D2
	bsr	GetWord
	cmp.w	#_TkVir,d0
	beq.s	MPar2
	subq.l	#2,a6
	move.w	Cmvqd5(pc),d0
	move.w	(sp)+,d1
	move.b	d1,d0
	bsr	OutWord
	rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Branchements / Boucles
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


;	REMs
; ~~~~~~~~~~
InRem	subq.w	#1,NbInstr(a5)
	bsr	GetWord
	add.w	d0,a6
	rts


;	Debut de procedure, premiere exploration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InProcedure
	subq.w	#1,NbInstr(a5)
; Decode la procedure si codee...
	move.l	a6,-(sp)
	addq.l	#6,a6
	bsr	GetWord
	btst	#6+8,d0
	beq.s	VPr0
	btst	#5+8,d0
	beq.s	VPr0
	tst.b	Flag_Source(a5)
	bne	Err_NoCode
	move.l	(sp),a6
	subq.l	#2,a6
	add.l	B_Source(a5),a6
	bsr	ProCode
VPr0	move.l	(sp)+,a6
; Stocke le label et les types
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

;	Proc
; ~~~~~~~~~~
InProc	addq.l	#2,a6
;	Appel de procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~
InProcedureCall
	bsr	OutLea
	subq.l	#2,a6
	move.l	a6,-(sp)
	bsr	StockOut
	moveq	#-1,d7
	bsr	GetLabel
	bsr	RestOut
	moveq	#-1,d7
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkBra1,d0
	bne.s	CDop3
	addq.l	#2,a6
	moveq	#0,d7
CDop1	lsl.l	#1,d7
	move.l	d7,-(sp)
	bsr	New_Evalue
	bsr	Optimise_D2
	bsr	Push_D2
	move.l	(sp)+,d7
	cmp.b	#1,d2
	bne.s	CDop2
	bset	#0,d7
CDop2	bsr	GetWord
	cmp.w	#_TkBra2,d0
	bne.s	CDop1
CDop3	move.l	a6,d0
	move.l	(sp),a6
	move.l	d0,(sp)
	move.l	d7,d2
	cmp.l	#-1,d2			Des parametres
	beq.s	.NoPar
	move.w	Cmvid5(pc),d0		Sort le MOVE / MOVEQ
	move.w	Cmvqd5(pc),d1
	bsr	OutMove
.NoPar	moveq	#-1,d7			Appel d'un label FIXE, toujours
	move.w	Cjsr(pc),d0
	bsr	CallLabelFixe
	move.l	(sp)+,a6
	rts

;	POP PROC
; ~~~~~~~~~~~~~~
InPopProc
	bsr	OutLea
	bsr	CTests
	bsr	GetWord			POP PROC[ ]???
	subq.w	#2,a6
	cmp.w	#_TkBra1,d0
	bne.s	.Out
	bsr	Fn_New_Evalue
	bsr	Optimise_D2
	addq.l	#2,a6
	and.b	#$0F,d2			Recupere les parametres
	lsl.w	#1,d2
	jmp	.jmp(pc,d2.w)
.jmp	bra.s	.Ent
	bra.s	.Float
	lea	CdEProS(pc),a0
	bra.s	.Suite
.Float	lea	CdEProF(pc),a0
	tst.b	MathFlags(a5)
	bpl.s	.Suite
	lea	CdEProD(pc),a0
	bra.s	.Suite
.Ent	lea	CdEProE(pc),a0
.Suite	bsr	OutCode
.Out	move.w	#L_FProc,d0		POP PROC= END PROC!
	bra	Do_JmpLibrary

;----------------------> FOR / TO / NEXT
InFor
	bsr	OutLea
; Prend et egalise la variable
	bsr	GetWord		; Teste?
	addq.l	#2,a6
	move.l	a6,-(sp)
	bsr	StockOut	; Saute la variable
        bsr 	InVariable2
	bsr	RestOut
	and.w	#$0F,d2
        move.w 	d2,-(sp)        ; Sauve le type
; Compile le TO
	addq.l	#2,a6
	move.w	(sp),Type_Voulu(a5)
        bsr 	Evalue_Voulu
	bsr	Push_D2
; Compile le STEP
	bsr 	GetWord
        subq.l 	#2,a6
	cmp.w	#_TkStp,d0
	bne.s	CFor3
        addq.l 	#2,a6
	move.w	(sp),Type_Voulu(a5)
        bsr 	Evalue_Voulu    ; va chercher le STEP
        bra.s 	CFor4
CFor3	bsr	S_Script_D2	; Cree une entree du script
	moveq	#1,d0		; Sort move.l #1,d3
	bsr	Out_MoveE
	tst.w	(sp)
	beq.s	CFor4
	bsr	D2_Float
CFor4	moveq	#0,d7		Par defaut, boucle lente
	moveq	#0,d0
	cmp.w	#F_MoveE,d3	Step= une constante entiere?
	bne.s	CFor5
	move.l	d4,a0
	move.l	S_Cst1(a0),d0		; Step
	moveq	#-1,d7			; Flag boucle rapide
CFor5	move.w	d7,-(sp)
	move.l	d0,-(sp)
	bsr	Push_D2
; Compile la variable
	move.l	6+2(sp),d0
	move.l	a6,6+2(sp)
	move.l	d0,a6
	bsr	InVariable2
	bsr	AdToA0
	move.l	6+2(sp),a6
; Adresse des adresses
	move.w	M_ForNext(a5),d1
	lea	forcd2(pc),a0
	bsr	RForNxt
	bsr	OutCode
; Poke les tables du compilateur
        move.l 	A_Bcles(a5),a1
	move.w	4(sp),(a1)+		; 0  Flag rapide
	move.w	6(sp),(a1)+		; 2  Type
	move.l	(sp),(a1)+		; 4  Step
	move.l	a4,(a1)+		; 8  Adresse dans le programme
	move.w	M_ForNext(a5),(a1)+	; 12 Position de la boucle
	move.w	#16,(a1)+		; 14 Taille FOR/NEXT
        move.l 	a1,A_Bcles(a5)
; Un FOR/NEXT de plus!
	add.w	#12,M_ForNext(a5)
        addq.w 	#1,N_Bcles(a5)
	lea	12(sp),sp
	rts
forcd2:	move.l	Cmp_AForNext(a5),a2
	lea	0(a2),a2
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	a0,(a2)
	dc.w	$4321

;-----------------------------------> NEXT
InNext:
	bsr	OutLea
	bsr	CTests
; Saute la variable
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkVar,d0
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
	move.w	Cbgts(pc),d7
	swap	d7
	move.w	Cble(pc),d7
	tst.l	4(a1)
	bmi.s	CNx1
	move.w	Cblts(pc),d7
	swap	d7
	move.w	Cbge(pc),d7
CNx1	moveq	#0,d5
	move.l	8(a1),d6
	bsr	DoTest
	bra.s	CNxX
* Boucle lente
CNx2	lea	CdNx(pc),a0
	bsr	RForNxt
	move.w	Cleaa1(pc),d7
	swap	d7
	move.w	Cleapca1(pc),d7
	move.l	8(a1),d6
	moveq	#0,d5
	bsr	DoLea
	move.w	#L_InNext,d0
	tst.w	2(a1)
	beq.s	CNx6
	move.w	#L_InNextF,d0
	tst.b	MathFlags(a5)
	bpl.s	CNx6
	move.w	#L_InNextD,d0
CNx6	bsr	Do_JsrLibrary
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
CdNx	move.l	Cmp_AForNext(a5),a2
	lea	0(a2),a2
	move.l	(a2)+,d0
	move.l	(a2)+,d1
	move.l	(a2),a2
	add.l	d0,(a2)
	cmp.l	(a2),d1
	dc.w	$4321

;------------------------------> REPEAT / UNTIL
InDo
InRepeat
	move.l	A_Bcles(a5),a1
	move.l	a4,(a1)+		; 0  6 Adresse boucle
	bsr	GetWord
	lea	-2(a6,d0.w),a0
	move.w	#6,(a1)+
	move.l	a1,A_Bcles(a5)
	addq.w	#1,N_Bcles(a5)
	rts
InUntil
	bsr	OutLea
	bsr	CTests
	bsr	Expentier
	bsr	Test_D2
	move.l	A_Bcles(a5),a1
	move.w	Cbne8(pc),d7
	swap	d7
	move.w	Cbeq(pc),d7
	move.l	-6(a1),d6
	moveq	#0,d5
	bsr	DoTest
	bra	UnPile

;------------------------------> LOOP
InLoop
	bsr	OutLea
	bsr	CTests
	moveq	#0,d5
	move.l	A_Bcles(a5),a1
	move.l	-6(a1),d6
	bsr	DoBra
	bra	UnPile

;------------------------------> WHILE / WEND
InWhile
	bsr	GetWord
; Retour du WEND
	move.l	A_Bcles(a5),a1
	move.l	a6,(a1)+
	move.w	Cjmp(pc),d0
	bsr	OutWord
	bsr	Relocation
	addq.l	#4,a4
	move.l	a4,(a1)+
	move.w	#10,(a1)+
	move.l	a1,A_Bcles(a5)
	addq.w	#1,N_Bcles(a5)
; Saute l'expression
	bsr	StockOut
	bsr	New_Evalue
	bsr	RestOut
	rts

InWend
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
	bsr	Test_D2
; Met le branchement
	moveq	#0,d5
	move.l	-6(a1),d6
	move.w	Cbeq8(pc),d7
	swap	d7
	move.w	Cbne(pc),d7
	bsr	DoTest
	bra	UnPile

;	Tester D2 si necessaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Test_D2	btst	#F_Drapeaux,d2
	bne.s	.Skip
	move.w	Ctstd3(pc),d0
	bsr	OutWord
.Skip	rts

;------------------------------> EXIT / EXIT IF
InExitIf
	bsr	OutLea
	bsr	GetWord
	move.w	d0,d1
	bsr	GetWord
	pea	0(a6,d1.w)
	bsr	Expentier
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkVir,d0
	bne.s	CEIf0
	addq.l	#2+6,a6
CEIf0	bsr	Test_D2
	move.l	(sp)+,d5
	moveq	#0,d6
	move.w	Cbeq8(pc),d7
	swap	d7
	move.w	Cbne(pc),d7
	bsr	DoTest
	rts
InExit
	bsr	GetWord
	move.w	d0,d1
	bsr	GetWord
	lea	0(a6,d1.w),a0
	move.l	a0,d5
	bsr	GetWord
	subq.l	#2,a6
	cmp.w	#_TkEnt,d0
	bne.s	Cexi1
	addq.l	#6,a6
Cexi1	moveq	#0,d6
	bsr	DoBra
	rts

;------------------------------> IF / THEN / ELSE
InIf	bsr	OutLea
	bsr	GetWord
	bclr	#0,d0
	bne.s	.ElseIf
; IF / ELSE / ENDIF simple
; ~~~~~~~~~~~~~~~~~~~~~~~~
	pea	0(a6,d0.w)
	bsr	Expentier
	bsr	Test_D2
	move.l	(sp)+,d5		Adresse de branchement
	moveq	#0,d6
	move.w	Cbne8(pc),d7
	swap	d7
	move.w	Cbeq(pc),d7
	bsr	DoTest
	rts
; IF / ELSE IF / ELSE / ENDIF
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ElseIf	clr.l	-(sp)			Adresse du premier BRA
	clr.l	-(sp)			Adresse de fin de l'expression
	move.w	#-1,-(sp)		Flag ELSE IF!
	pea	0(a6,d0.w)		Pousse l'adresse
	bsr	Expentier		Evalue l'expression
	move.l	a6,6(sp)
	bsr	Test_D2
	move.w	Cbne(pc),d0		Bne
	bsr	OutWord
	move.l	a4,6+4(sp)		Adresse du branchement
	moveq	#0,d0
	bsr	OutWord
.Loop	move.l	(sp)+,a6
	move.w	(sp)+,d0
	beq.s	.Fini
	subq.l	#2,a6
	bsr	GetWord
	bclr	#0,d0
	sne	d1
	ext.w	d1
	move.w	d1,-(sp)
	pea	0(a6,d0.w)
	bsr	Expentier
	bsr	Test_D2			Vrai / Faux?
	move.l	a6,d5			Adresse de branchement
	moveq	#0,d6
	move.w	Cbeq8(pc),d7
	swap	d7
	move.w	Cbne(pc),d7
	bsr	DoTest
	bra.s	.Loop
.Fini	move.l	a6,d5			ELSE / ENDIF
	moveq	#0,d6
	bsr	DoBra
	move.l	(sp)+,a6		Adresse dans le source
	move.l	a4,d1
	move.l	(sp)+,a4		Adresse du BNE
	move.l	d1,d0
	sub.l	a4,d0
	bsr	OutWord			Reloge le BNE
	move.l	d1,a4			Restore la sortie
	rts
InElseIf
	bsr	OutLea
	pea	2(a6)

.Loop	moveq	#0,d0
	bsr	GetWord
	move.w	d0,d1
	bclr	#0,d0
	add.l	d0,a6
	subq.l	#4,a6
	bsr	GetWord
	bclr	#0,d1
	bne.s	.Loop
	cmp.w	#_TkElse,d0
	beq.s	.Loop
	addq.l	#2,a6

	move.l	a6,d5
	moveq	#0,d6
	bsr	DoBra

	move.l	(sp)+,a6
	bsr	StockOut		Saute l'expression
	bsr	Expentier
	bsr	RestOut
	rts
InElse
	bsr	OutLea
	bsr	GetWord
	bclr	#0,d0
	lea	0(a6,d0.w),a0
	move.l	a0,d5
	moveq	#0,d6
	bsr	DoBra
	rts

;	ON ERROR
; ~~~~~~~~~~~~~~
InOnError
	bsr	OutLea
	bsr	GetWord
	cmp.w	#_TkPrc,d0
	beq.s	CerP
	cmp.w	#_TkGto,d0
	bne.s	Cer0
* On error GOTO
	move.l	a6,-(sp)
	bsr	GetWord
	cmp.w	#_TkEnt,d0
	bne.s	CerG
	bsr	GetLong
	tst.l	d0
	bne.s	CerG
	addq.l	#4,sp
	bra.s	Cer1
CerG	move.l	(sp)+,a6
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_InOnErrorGoto,d0
	bra	Do_JsrLibrary
* On error PROC
CerP	moveq	#-1,d7
	bsr	GetLabel
	move.w	#L_InOnErrorProc,d0
	bra	Do_JsrLibrary
* On error RIEN
Cer0	subq.l	#2,a6
Cer1	move.w	#L_InOnError,d0
	bra	Do_JsrLibrary

;	TRAP
; ~~~~~~~~~~
InTrap	bsr	OutLea
	move.w	#L_InTrap,d0
	bra	Do_JsrLibrary

;	RESUME
; ~~~~~~~~~~~~
InResume
	bsr	OutLea
	bsr	Finie
	subq.l	#2,a6
	beq.s	CRes0
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_InResume1,d0
	bra	Do_JmpLibrary
CRes0	move.w	#L_InResume,d0
	bra	Do_JmpLibrary

;	RESUME LABEL
; ~~~~~~~~~~~~~~~~~~
InResumeLabel
	bsr	OutLea
	bsr	Finie
	subq.l	#2,a6
	beq.s	Cresl0
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_InResumeLabel1,d0
	bra	Do_JsrLibrary
Cresl0	move.w	#L_InResumeLabel,d0
	bra	Do_JsrLibrary

;-----> LABEL
InLabel	move.w	N_Proc(a5),d7
	bsr	RLabel
	move.l	a4,2(a2)
	rts

;-----> GOTO
InLabelGoto
	subq.l	#2,a6
InGoto
	bsr	OutLea
	bsr	CTests
	move.w	N_Proc(a5),d7
	bsr	GetLabel
CGoto1	move.w	Cjmpa0(pc),d0
	bra	OutWord

;-----> EVERY n GOSUB / PROC
InEvery
	bsr	Expentier
	bsr	Push_D2
	bsr	GetWord
	cmp.w	#_TkPrc,d0
	beq.s	CEv1
; Every GOSUB
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	move.w	#L_InEveryGosub,d0
	bra	Do_JsrLibrary
; Every PROC
CEv1	moveq	#-1,d7
	bsr	GetLabel
	move.w	#L_InEveryProc,d0
	bra	Do_JsrLibrary

;	ON BREAK PROC
; ~~~~~~~~~~~~~~~~~~~
InOnBreak
	moveq	#-1,d7
	bsr	GetLabel
	move.w	#L_InOnBreak,d0
	bra	Do_JsrLibrary

;-----> GOSUB
InGosub	bsr	OutLea
	bsr	CTests
	move.w	N_Proc(a5),d7
	bsr	GetLabel
	lea	CdGsb(pc),a0
	bra	OutCode
CdGsb:	lea	-4(sp),a1
	move.l	a1,Cmp_LowPile(a5)
	jsr	(a0)
	dc.w	$4321

;-----> RETURN
InReturn
	bsr	OutLea
	bsr	CTests
	move.w	#L_InReturn,d0
	bra	Do_JmpLibrary
;-----> POP
InPop
	bsr	OutLea
	bsr	CTests
	move.w	#L_InPop,d0
	bra	Do_JsrLibrary


;-----> ON exp GOTO / GOSUB
InOn	bsr	OutLea
	bsr	CTests
	bsr	GetWord
	lea	2(a6,d0.w),a1
	bsr	GetWord
	move.w	d0,-(sp)
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
	cmp.w	#_TkGsb,d0
	beq.s	COn1
	cmp.w	#_TkPrc,d0
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
	move.w	Cnop(pc),d0
	bsr	OutWord
	bsr	OutWord
	bsr	OutWord
	bsr	OutWord
; Bra final
COn2	move.w	Cbra(pc),d0
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
	move.w	Crts(pc),d0
	bsr	OutWord
	addq.l	#2,a6
	subq.w	#1,8(sp)
	bne.s	COn3
; Ouf!
	subq.l	#2,a6
	lea	10(sp),sp
	rts
CdOn	moveq	#0,d1
	tst.l	d3
	beq.s	CdOn1+10
	cmp.l	d1,d3
	bhi.s	CdOn1+10
	lsl.w	#1,d3
	move.w	CdOn1+10+4-2(pc,d3.w),d0
	jsr	CdOn1+10+4(pc,d0.w)
CdOn1	dc.w	$4321




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	LABEL FIXE? VRAI si fixe
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IsLabelFixe
	bsr	GetWord
	subq.l	#2,a4
	cmp.w	#_TkLGo,d0
	beq.s	.Fixe
	cmp.w	#_TkPro,d0
	beq.s	.Fixe
	moveq	#0,d0
	rts
.Fixe	moveq	#-1,d0
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	CREE JSR / JMP / LEA pour un label fixe
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CallLabelFixe
	addq.l	#2,a6			Saute le prefixe label
	move.w	d0,-(sp)		Code de l'instruction
	bsr	RLabel
	move.w	(sp)+,d0
	bsr	OutWord
	bsr	Relocation
	move.l	a2,d0
	sub.l	B_Labels(a5),d0		En relatif / Debut du buffer
	or.l	#Rel_Label,d0
	bra	OutLong

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; ROUTINE -> adresse d'un label
; OUT >>> lea label,a0
; Retour VRAI si FIXE / FAUX si variable
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
GetLabel
	bsr	GetWord
	cmp.w	#_TkLGo,d0
	beq	Cglab1
	cmp.w	#_TkPro,d0
	beq	Cglab1
; Expression
	subq.w	#2,a6
	addq.w	#1,Cpt_Labels(a5)		Copier la table!
	move.b	#-1,Flag_Const(a5)
	bsr	StockOut
	move.w	d7,-(sp)
	bsr	New_Evalue
	move.w	(sp)+,d7
	move.w	#L_GetLabelA,d1
	cmp.b	#2,d2
	beq	Glab0a
	tst.b	d2
	beq.s	Glab0
	bsr	D2_Entier
Glab0	move.w	#L_GetLabelE,d1
	cmp.w	#F_MoveE,d3			Un numero de ligne?
	beq.s	Clab0b
; Expression variable!
Glab0a	bsr	Optimise_D2
	bsr	SautOut
	move.w	Cmvwid5(pc),d0
	bsr	OutWord
	move.w	N_Proc(a5),d0
	bsr	OutWord
	move.w	d1,d0
	bra	Do_JsrLibrary
; Numero de ligne FIXE
Clab0b	subq.w	#1,Cpt_Labels(a5)
	bsr	RestOut
	move.l	d4,a0
	move.l	S_Cst1(a0),d0		Prend la constante
	moveq	#-1,d3
	moveq	#0,d4
	move.l	B_Work(a5),a2
	move.l	a2,a0
	bsr	HexToAsc		Converti en ascii
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
Cglab0	move.w	Cleaa0(pc),d0
	bsr	OutWord
	bsr	Relocation
	move.l	a2,d0
	sub.l	B_Labels(a5),d0		En relatif / Debut du buffer
	or.l	#Rel_Label,d0
	bra	OutLong

* ROUTINE -> Trouve / Cree / Saute le label (a6)
* Entree D7=	Numero procedure
* Retour A2=	Label
RLabel	addq.l	#2,a6
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
DoBra	move.w	Cjmp(pc),d7
	swap	d7
	move.w	Cbra(pc),d7
* Entree pour LEA / LEA (pc)
DoLea	tst.l	d5
	bne.s	Dbr2
* En arriere!
	move.l	d6,d1
	sub.l	a4,d1
	subq.l	#2,d1
	cmp.l	#32764,d1
	bge.s	Dbr1
	cmp.l	#-32764,d1
	ble.s	Dbr1
; Ok, en SHORT!
Dbr0	move.w	d7,d0
	bsr	OutWord
	move.w	d1,d0
	bra	OutWord
; En LONG!
Dbr1	swap	d7
	move.w	d7,d0
	bsr	OutWord
	bsr	Relocation
	move.l	d6,d0
	bra	OutLong
* En avant!
Dbr2	move.l	a4,d4
	tst.b	Flag_Long(a5)
	bne.s	Dbr3
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
	bsr	Relocation
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
	move.w	Cjmp(pc),d0
	bsr	OutWord
	bsr	Relocation
	move.l	d6,d0
	bra	OutLong
* En Avant!
DTst2	move.l	a4,d4
	tst.b	Flag_Long(a5)
	beq.s	Dbr4
; En long!
	bset	#31,d4
	addq.l	#2,d4
	swap	d7
	move.w	d7,d0
	bsr	OutWord
	move.w	Cjmp(pc),d0
	bsr	OutWord
	bsr	Relocation
	addq.l	#4,a4

* Marque la table des branch forward
MarkAd	movem.l	a0/a1,-(sp)
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
	bgt	Err_DoLong
	cmp.l	#-32764,d0
	blt	Err_DoLong
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

;	Appel de la routine de test
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CTests	tst.b	Flag_NoTests(a5)
	bne.s	.Notest
	move.w	#L_Test_Normal,d0
	bra	Do_JsrLibrary
.Notest	move.w	Cmvqd6(pc),d0		Pas de test: remettre D6 � zero!
	move.b	#1,d0
	bra	OutWord

;	Instruction finie??
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Finie:	bsr	GetWord
FinieB:	beq.s	Finy
	cmp.w	#_TkDP,d0
	beq.s	Finy
	cmp.w	#_TkThen,d0
	beq.s	Finy
	cmp.w	#_TkElse,d0
Finy:	rts

;	Codage / Decodage procedure LOCKEE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A6---> "PROC"
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


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ROUTINES DE CONVERSION INTERNES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Cree le INTOFL
; ~~~~~~~~~~~~~~~~~~~~~
Cree_IntToFl
	move.w	#L_IntToFl1,d0
	bra	Do_JsrLibrary
Cree_IntToFl2
	move.w	#L_IntToFl2,d0
	bra	Do_JsrLibrary
Cree_FlToInt
	move.w	#L_FlToInt1,d0
	bra	Do_JsrLibrary
Cree_FlToInt2
	move.w	#L_FlToInt2,d0
	bra	Do_JsrLibrary

;	Ouvre les librairies mathematiques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Float_Open
	tst.l	FloatBase(a5)
	bne.s	.Ok
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	$4.w,a6
	moveq	#0,d0
	lea	FloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,FloatBase(a5)
	beq	Err_CantOpenMathLibraries
	movem.l	(sp)+,d0-d1/a0-a1/a6
.Ok	rts
DFloat_Open
	tst.l	DFloatBase(a5)
	bne.s	.Ok
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	$4.w,a6
	lea	DFloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DFloatBase(a5)
	beq	Err_CantOpenMathLibraries
	movem.l	(sp)+,d0-d1/a0-a1/a6
.Ok	rts

;	Entree generale FLOAT to ENTIER
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FloatOrDoubleToInt
	tst.b	MathFlags(a5)
	bmi.s	DoubleToInt
; Float >>> Entier
FloatToInt
	movem.l	a0-a1/a6,-(sp)
	bsr	Float_Open
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFix(a6)
	movem.l	(sp)+,a0-a1/a6
	rts
; Double >>> Entier
DoubleToInt
	movem.l	a0-a1/a6,-(sp)
	bsr	DFloat_Open
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFix(a6)
	movem.l	(sp)+,a0-a1/a6
	rts

;	Entree int >>> float generale
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IntToFloatOrDouble
	tst.b	MathFlags(a5)
	bne.s	IntToDouble
; Entier >>> Float
IntToFloat
	movem.l	a0-a1/a6,-(sp)
	bsr	Float_Open
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFlt(a6)
	movem.l	(sp)+,a0-a1/a6
	rts
; Entier >>> Double
IntToDouble
	movem.l	a0-a1/a6,-(sp)
	bsr	DFloat_Open
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFlt(a6)
	movem.l	(sp)+,a0-a1/a6
	rts

;	Double precision vers float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Double2Float
	movem.l	a0-a1,-(sp)
	bsr	Dp2Sp
	bsr	Ieee2FFP
	movem.l	(sp)+,a0-a1
	rts
;	Float vers double precision
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Float2Double
	movem.l	a0-a1,-(sp)
	bsr	FFP2Ieee
	bsr	Sp2Dp
	movem.l	(sp)+,a0-a1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FFP single precision to IEEE single precision
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FFP2Ieee
; - - - - - - - - - - - - -
	ADD.L	D0,D0
	BEQ.S	L21418A
	EORI.B	#$80,D0
	ASR.B	#1,D0
	SUBI.B	#$82,D0
	SWAP	D0
	ROL.L	#7,D0
L21418A	RTS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	IEEE single precision to FFP single precision
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Ieee2FFP
; - - - - - - - - - - - - -
	SWAP	D0
	ROR.L	#7,D0
	EORI.B	#$80,D0
	ADD.B	D0,D0
	BVS.S	L2141A4
	ADDQ.B	#5,D0
	BVS.S	L2141DA
	EORI.B	#$80,D0
	ROR.L	#1,D0
L2141A2	RTS
L2141A4	BCC.S	L2141CC
	CMPI.B	#$7C,D0
	BEQ.S	L2141B2
	CMPI.B	#$7E,D0
	BNE.S	L2141BE
L2141B2	ADDI.B	#$85,D0
	ROR.L	#1,D0
	TST.B	D0
	BNE.S	L2141A2
	BRA.S	L2141C8
L2141BE	ANDI.W	#$FEFF,D0
	TST.L	D0
	BEQ.S	L2141A2
	TST.B	D0
L2141C8	MOVEQ	#0,D0
	BRA.S	L2141A2
L2141CC	CMPI.B	#$FE,D0
	BNE.S	L2141DA
	LSR.L	#8,D0
	LSR.L	#1,D0
	BNE.S	L2141E6
	BRA.S	L2141DC
L2141DA	LSL.W	#8,D0
L2141DC	MOVEQ	#-1,D0
	ROXR.B	#1,D0
	ORI.B	#2,CCR
	BRA.S	L2141A2
L2141E6	MOVEQ	#0,D0
	BRA.S	L2141A2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	IEEE single precision to ieee double precision
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Sp2Dp
; - - - - - - - - - - - - -
	MOVEA.L	D0,A0
	SWAP	D0
	BEQ.S	.SKIP
	MOVE.W	D0,D1
	ANDI.W	#$7F80,D0
	ASR.W	#3,D0
	ADDI.W	#$3800,D0
	ANDI.W	#$8000,D1
	OR.W	D1,D0
	SWAP	D0
	MOVE.L	A0,D1
	ROR.L	#3,D1
	MOVEA.L	D1,A0
	ANDI.L	#$FFFFF,D1
	OR.L	D1,D0
	MOVE.L	A0,D1
	ANDI.L	#$E0000000,D1
	RTS
.SKIP	MOVEQ	#0,D1
	RTS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	IEEE Double precision to IEEE single precision
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Dp2Sp
; - - - - - - - - - - - - -
	SWAP	D0
	BEQ.S	L2ECFA4
	MOVE.W	D0,D1
	SWAP	D1
	SWAP	D0
	ASL.W	#1,D1
	ROXL.L	#1,D0
	ASL.W	#1,D1
	ROXL.L	#1,D0
	ASL.W	#1,D1
	ROXL.L	#1,D0
	SWAP	D0
	ANDI.W	#$7F,D0
	SWAP	D1
	MOVEA.W	D1,A0
	ANDI.W	#$8000,D1
	OR.W	D1,D0
	MOVE.W	A0,D1
	ANDI.W	#$7FF0,D1
	SUBI.W	#$3800,D1
	BGE.S	L2ECFA6
	CLR.L	D0
L2ECFA4	RTS
L2ECFA6	CMPI.W	#$FF0,D1
	BLE.S	L2ECFBC
	ORI.B	#2,CCR
;	TRAPV
	ORI.L	#$FFFF7FFF,D0
	SWAP	D0
	RTS
L2ECFBC	ASL.W	#3,D1
	OR.W	D1,D0
	SWAP	D0
	RTS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FABRICATION DU HEADER DU PROGRAMME
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Header:
	cmp.b	#3,Flag_Type(a5)
	beq	HeaderAMOS

;	Programme NORMAL
; ~~~~~~~~~~~~~~~~~~~~~~

; Regarde le nombre de hunks
	move.w	N_Banks(a5),d0
	add.w	#N_HunkSys,d0		Nb de banques+nb de hunks systeme
	move.w	d0,N_Hunks(a5)		= nombre total de hunks
	bsr	ResHunk

; Fabrique le HUNK entete
	move.l	#$3F3,d0		AmigaDos
	bsr	OutLong
	moveq	#0,d0			Pas de nom
	bsr	OutLong
	move.w	N_Hunks(a5),d1		Le nombre de hunks du programme
	ext.l	d1
	move.l	d1,d0
	bsr	OutLong
	moveq	#0,d0			Debut=0
	bsr	OutLong
	move.l	d1,d0
	subq.l	#1,d0
	bsr	OutLong
	lsl.w	#2,d1			Saute les tailles
	lea	0(a4,d1.w),a4
; Fabrique le hunk header
	moveq	#NH_Header,d1
	moveq	#Hunk_Public,d2
	bsr	DebHunk
	moveq	#5,d0			Header_CLI.Lib
	cmp.b	#2,Flag_Type(a5)
	bne.s	.Skip
	moveq	#6,d0			Header_Backstart.Lib
.Skip	bsr	Get_ConfigMessage
	bsr	AddPath
	moveq	#F_Courant,d0
	bsr	F_OpenOld
	beq	Err_DiskError
	moveq	#F_Courant,d1		Charge le debut
	move.l	B_Work(a5),d2
	moveq	#$20+2,d3
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a1
; Envoie le reste
	move.l	a4,Ad_HeaderFlags(a5)	Pour la fin
	moveq	#0,d3
	move.w	$20(a1),d3
	bsr	Out_F_Read
	bsr	F_Close
	moveq	#NH_Header,d1
	bsr	FinHunk
	rts

;	Programme AMOS
; ~~~~~~~~~~~~~~~~~~~~
HeaderAMOS
	moveq	#7,d0			Header_AMOS.AMOS
	bsr	Get_ConfigMessage
	bsr	AddPath
	move.l	Name1(a5),a0
	lea	B_HeadAMOS(a5),a1	Charge dans le buffer
	bsr	Load_InBuffer
	move.l	a0,a1
; Recopie le header AMOS Professional
	moveq	#3,d1
.loop0	move.l	(a1)+,d0
	bsr	OutLong
	dbra	d1,.loop0
	move.l	a4,AA_Long(a5)
; Recopie en cherchant le SET BUFFER
.loop1	move.w	(a1)+,d0
	bsr	OutWord
	cmp.w	#_TkSBu,d0
	bne.s	.loop1
	move.l	a4,AA_SBuf(a5)
; Cherche maintenant le PROCEDURE
.loop2	move.w	(a1)+,d0
	bsr	OutWord
	cmp.w	#_TkProc,d0
	bne.s	.loop2
	move.l	a4,AA_Proc(a5)
	move.l	(a1)+,d0
	bsr	OutLong
	move.l	(a1)+,d0
	or.w	#%0101000000000000,d0
	bsr	OutLong
; Cherche maintenant le CMPCALL
.loop3	move.w	(a1)+,d0
	bsr	OutWord
	cmp.w	#_TkAPCmp,d0
	bne.s	.loop3
; Sort des zeros
	move.l	a4,AA_Header(a5)
	moveq	#APrg_Program/2-1,d1
.Loop	moveq	#0,d0
	bsr	OutWord
	dbra	d1,.Loop
; Debut du programme proprement dit!
	lea	B_HeadAMOS(a5),a0
	bsr	Buffer_Free
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	APPEL DES ROUTINES D'INIT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CreeInits
	cmp.b	#3,Flag_Type(a5)
	beq.s	.AMOS
	tst.b	Flag_Numbers(a5)
	beq.s	.Skip
	move.w	#L_CmpDbMode,d0		Appel de la routine debug
	bsr	Do_JsrLibrary
.Skip	lea	.Code(pc),a0
	bsr	OutCode
	move.w	Cjsr(pc),d0		Fait un JSR aux routines
	bsr	OutWord
	move.l	a4,Ad_JsrInits(a5)	Adresse du jsr
	bsr	Relocation		...mises apres la compilation!
	addq.l	#4,a4
	moveq	#L_CmpInit2,d0		Appelle la deuxieme routine
	bsr	Do_JsrLibrary
	rts
.Code	move.l	sp,Cmp_LowPile(a5)
	move.l	sp,Cmp_LowPileP(a5)
	dc.w	$4321
; Initialisation AMOS
; ~~~~~~~~~~~~~~~~~~~
.AMOS	move.w	Cleaa4(pc),d0		Charge le pointeur sur librairies
	bsr	OutWord
	move.l	a4,AA_A4(a5)
	bsr	Relocation
	moveq	#0,d0
	bsr	OutLong
	move.w	#L_AMOSInit,d0		Jsr	AMOSInit(a4)
	bsr	Do_JsrLibrary
	lea	.Code(pc),a0		Sauve les piles
	bsr	OutCode
	rts

;	Termine les initialisations
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FiniInits
	cmp.b	#3,Flag_Type(a5)	Pas si programme AMOS
	bne.s	.CLI
	rts
; Programme CLI
; ~~~~~~~~~~~~~
.CLI	move.l	a4,Ad_Inits(a5)
	move.w	Cmvid0(pc),d0		Longueur du stack
	bsr	OutWord
	move.l	L_Stack(a5),d0
	bsr	OutLong
	move.w	Cmvid1(pc),d0		Longueur du buffer
	bsr	OutWord
	move.l	L_Buf(a5),d0
	mulu	#1024,d0
	add.l	#512,d0
	bsr	OutLong
	move.w	#L_CmpInit1,d0		Appel de la routine init 1
	bsr	Do_JsrLibrary
; Init des routines float / double
	tst.b	MathFlags(a5)
	beq.s	.Nomath
	move.w	Cmvqd0(pc),d0
	move.b	MathFlags(a5),d0
	bsr	OutWord
	move.w	#L_CmpInitFloat,d0
	bsr	Do_JsrLibrary
	lea	.CodeF(pc),a0
	bsr	OutCode
.Nomath
; Initialise les extensions
.Ext	lea	.ECode(pc),a0
	bsr	OutCode
	lea	AdTokens+4(a5),a1
	moveq	#1,d1
.Loop	move.l	(a1)+,d0
	beq.s	.Next
	move.l	d0,a0
	btst	#LBF_AlwaysInit,LB_Flags(a0)
	bne.s	.Yes
	btst	#LBF_Called,LB_Flags(a0)
	beq.s	.Next
.Yes	move.w	Cmvqd0(pc),d0		moveq	#Extension,d0
	move.b	d1,d0
	subq.b	#1,d0
	bsr	OutWord
	moveq	#0,d0			lea	Routine,a0
	bsr	Do_LeaExtLibrary
	move.w	#L_CmpLibrariesInit,d0
	bsr	Do_JsrLibrary		bsr	Init
	lea	.CodeF(pc),a0
	bsr	OutCode
.Next	addq.w	#1,d1
	cmp.w	#26,d1			Pour les 26 extensions
	bls.s	.Loop
.NoExt	lea	.CodeOk(pc),a0		moveq	#0,d0
	bsr	OutCode			rts
	rts
; Ok, pas de probleme
; ~~~~~~~~~~~~~~~~~~~
.CodeOk	moveq	#0,d0
	rts
; Verification init extension / float
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.CodeF	beq.s	.Blip
	rts
.Blip	dc.w	$4321
.ECode	moveq	#26-1,d0
.ELoop	tst.b	AdTokens(a5,d0.w)
	beq.s	.ESkip
	addq.b	#1,AdTokens(a5,d0.w)
.ESkip	dbra	d0,.ELoop
	dc.w	$4321

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Entree Programme / Procedure
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	ROUTINE: Entree programme/procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PrgIn	move.l	a4,AdAdress(a5)

	move.w	Cmvid0(pc),d0		D0= labels
	bsr	OutWord
	bsr	Relocation
	addq.l	#4,a4
	move.w	Cleaa0(pc),d0		A0= liste instructions
	bsr	OutWord
	bsr	Relocation
	addq.l	#4,a4
	move.w	Cleaa1(pc),d0		A1= flags variable
	bsr	OutWord
	bsr	Relocation
	addq.l	#4,a4
	move.w	Cleaa2(pc),d0		A2= datas
	bsr	OutWord
	bsr	Relocation
	addq.l	#4,a4

; Initialisation de la table des flags variables
	move.l	A_FlagVarL(a5),a0
	clr.w	(a0)+
	tst.b	MathFlags(a5)		Seulement si FLOAT
	bpl.s	.Flt
	move.l	-6(a0),d0		Taille de la table
	lsr.w	#1,d0
	subq.w	#3+1,d0
	moveq	#-1,d1
.Clear	move.w	d1,(a0)+		Des $FF partout!
	dbra	d0,.Clear
.Flt
	clr.l	A_Datas(a5)
	clr.w	Cpt_Labels(a5)
	clr.b	Flag_Procs(a5)
	clr.w	M_ForNext(a5)

	move.w	#L_PrgInF,d0		Jsr PrgIn
	add.w	MathType(a5),d0
	bsr	Do_JsrLibrary

	move.l	B_Instructions(a5),a0	Met l'adresse de base de la procedure
	move.l	a4,(a0)+		Decalage au debut de la procedure
	clr.w	(a0)+			Nombre d'instructions
	move.l	a0,A_Instructions(a5)
	rts

;	ROUTINE -> Sortie programme/procedures
;	A0-> flags variables a copier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PrgOut	move.l	a4,-(sp)		Adresse des labels
	move.l	a0,-(sp)		Adresse des flags

; Copie de la table des labels, s'il faut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	Cpt_Labels(a5)
	beq.s	PaClb
	move.w	N_Proc(a5),d7
	move.l	B_Labels(a5),a2
	move.w	(a2),d2
	beq.s	ClbX
Clb1	cmp.w	-2+6(a2,d2.w),d7
	beq.s	Clb0
	tst.b	Flag_Procs(a5)		* Pour le moment PROC a$, interdit!
	beq.s	Clb3
	tst.w	-2+6(a2,d2.w)
	bpl.s	Clb3
Clb0	move.w	d2,d0
	bsr	OutWord
	bsr	Relocation
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
	clr.w	Cpt_Labels(a5)

; Copie la table des flags variable
PaClb	move.l	(sp),a1
	move.l	a4,(sp)
	move.w	M_ForNext(a5),d0
	bsr	OutWord
	move.w	(a1)+,d0
	moveq	#0,d1
	move.w	d0,d1
	bsr	OutWord
	divu	#6,d1
	subq.w	#1,d1
	bmi.s	.Out
.Loop	move.b	(a1)+,d0		Si -1: non initialise (double)
	bmi.s	.Skip
	bsr	OutByte
.Skip	dbra	d1,.Loop
.Out	moveq	#-1,d0			-1 a la fin!
	bsr	OutByte
	bsr	A4Pair

; Copie la table des adresses instructions
	move.l	a4,-(sp)
	move.l	B_Instructions(a5),a0
	move.l	(a0)+,d0
	bsr	OutLong
	move.w	(a0)+,d0
	move.w	d0,d1
	bsr	OutWord
	bra.s	.Ini
.Loopi	move.l	(a0)+,d0
	bsr	OutLong
.Ini	dbra	d1,.Loopi

; Change les adresses au debut de la procedure
	move.l	a4,-(sp)
	move.l	AdAdress(a5),a4
	addq.l	#2,a4
	move.l	12(sp),d0		D0- Adresse des labels
	bsr	OutLong
	addq.l	#2,a4
	move.l	4(sp),d0		A0- Adresse des instructions
	bsr	OutLong
	addq.l	#2,a4
	move.l	8(sp),d0		A1- Adresse des flags variable
	bsr	OutLong
	addq.l	#2,a4
	move.l	A_Datas(a5),d0		A2- Adresse des datas
	bne.s	.Skip3
	move.l	A_EDatas(a5),d0
.Skip3	bsr	OutLong
	move.l	(sp)+,a4
	lea	12(sp),sp
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ENTREES:  SORTIES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Err_Debug
	illegal
	rts

; Diskerrors
; ~~~~~~~~~~
Err_DiskError
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOIoErr(a6)
	cmp.w	#36,$14(a6)		V2.0?
	bcs.s	.Pa20
; WB2.0: met l'erreur en clair
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	d0,d1
	moveq	#44,d0
	bsr	Get_ConfigMessage
	move.l	a0,d2
	move.l	B_Work(a5),a0
	lea	256(a0),a0
	move.l	a0,d3
	moveq	#70,d4
	jsr	_LVOFault(a6)
	move.l	(sp)+,a6
	move.l	d3,a0
	move.l	#20,-(sp)
	bra	CmpE3
; WB1.3: Trois messages reconnus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Pa20	move.l	(sp)+,a6
	lea	ErDisk(pc),a0
	moveq	#-1,d1
DiE1:	addq.l	#1,d1
	move.w	(a0)+,d2
	bmi.s	DiE2
	cmp.w	d0,d2
	bne.s	DiE1
	add.w	#68,d1
	move.l	d1,d0
	bra	Cmp_Error
DiE2:	moveq	#44,d0
	bra	Cmp_Error
; Table des erreurs reconnues
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
ErDisk:	dc.w 	213		Disk is not validated
	dc.w	214		Disk is write protected
	dc.w	221		Disk full
	dc.w	-1
;	Errors:
Err_DejaTokenise
	moveq 	#56,d0
	bra.s	Cmp_Error
Err_DoLong
	moveq	#55,d0
	bra.s	Cmp_Error
Err_CantLoadConfig
	moveq	#63,d0
	bra.s	Cmp_Error
Err_CantLoadIntConfig
	moveq	#62,d0
	bra.s	Cmp_Error
Err_CantLoadEditConfig
	moveq	#61,d0
	bra.s	Cmp_Error
Err_BadEditConfig
	moveq	#50,d0
	bra.s	Cmp_Error
Err_InCommand
	moveq	#40,d0
	bra.s	Cmp_Error
Err_InDefCommand
	moveq	#41,d0
	bra.s	Cmp_Error
Err_CantOpenSource
	moveq	#57,d0
	bra.s	Cmp_Error
Err_NotAMOSProgram
	moveq	#52,d0
	bra.s	Cmp_Error
Err_BadIntConfig
	moveq	#58,d0
	bra.s	Cmp_Error
Err_OOfMem
	moveq	#45,d0
	bra.s	Cmp_Error
Err_System
	moveq	#46,d0
	bra.s	Cmp_Error
Err_NoIcons
	moveq	#43,d0
	bra.s	Cmp_Error
Err_CannotFindAPSystem
	moveq	#59,d0
	bra.s	Cmp_Error
Err_LineTooLong
	moveq	#60,d0
	bra.s	Cmp_Error
Err_ExtensionNotLoaded
	moveq	#42,d0
	bra.s	Cmp_Error
Err_CantOpenMathLibraries
	moveq	#51,d0
	bra.s	Cmp_Error
Err_NothingToCompile
	moveq	#49,d0
	bra.s	Cmp_Error
Err_AlreadyCompiled
	moveq	#54,d0
	bra.s	Cmp_Error
Err_NoCode
	moveq	#47,d0
	bra.s	Cmp_Error
Err_ControlC
	moveq	#48,d0
	bra.s	Cmp_Error
Err_Label
	moveq	#53,d0
	bra.s	Cmp_Error
Err_AMOSLib
	moveq	#67,d0
	bra.s	Cmp_Error
Err_BadConfig
	moveq	#66,d0

; Impression du message d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cmp_Error
	move.l	d0,-(sp)
CmpE2	move.l	(sp),d0
	bsr	Get_ConfigMessage
CmpE3	move.l	B_Work(a5),a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
	move.l	B_Work(a5),a0
	move.l	(sp)+,d0
	moveq	#0,d1			Ne pas pointer de ligne
	moveq	#0,d2			Rien en D2!
	bra.s	Go_Error
; Message d'erreur pointant sur une ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cmp_ErrorNumber
	move.l	d0,-(sp)
	bsr	FindL
	bmi.s	CmpE2
	move.l	d0,d2
	move.l	(sp),d0
	bsr	Get_ConfigMessage
	move.l	d2,d0
	bsr	Cree_ErrorMessageNumber
	move.l	B_Work(a5),a0
	move.l	(sp)+,d0
	moveq	#-1,d1			Pointer la ligne D2
; Envoie le message d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Go_Error
	movem.l	a0/d0/d1/d2,-(sp)
	bsr	Return			Imprime
	move.l	3*4(sp),a0
	bsr	Str_Print
	bsr	Return
	bsr	Return
	movem.l	(sp)+,a0/d0/d1/d2
	tst.b	Flag_AMOS(a5)
	bne	TheEnd
	moveq	#20,d0			Si CLI, error level=20
	bra	TheEnd

;	Erreurs avec numero de ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Err_Syntax
	moveq	#48,d0
	bra	Cmp_ErrorNumber
Err_DivisionByZero
	moveq	#64,d0
	bra.s	Cmp_ErrorNumber
Err_Overflow
	moveq	#43,d0
	bra.s	Cmp_ErrorNumber


; 	Cree le message d'erreur A0 en ligne D0 dans B_Work
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cree_ErrorMessageNumber
	move.l	d0,-(sp)
	move.l	B_Work(a5),a1
.Copy1	move.b	(a0)+,(a1)+		Copie
	bne.s	.Copy1
	subq.l	#1,a1
	moveq	#34,d0			At line
	bsr	Get_ConfigMessage
.Copy2	move.b	(a0)+,(a1)+
	bne.s	.Copy2
	lea	-1(a1),a0
	move.l	(sp),d0			Numero de la ligne
	addq.l	#1,d0			+ 1!
	bsr	longdec
	clr.b	(a0)
	move.l	(sp)+,d0
	rts

;	Trouve le num�ro de la ligne pointee par A6->D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FindL	move.l	a6,d2
	lea	20,a6
	moveq	#0,d1
.Loop0	addq.l	#1,d1
	bsr	GetWord
	lsr.w	#8,d0
	beq.s	.Loop2
	lsl.w	#1,d0
	lea	-2(a6,d0.w),a6
	cmp.l	d2,a6
	bcs.s	.Loop0
.Loop1	move.l	d1,d0
	rts
.Loop2	moveq	#-1,d0
	rts

;	Imprime les messages D0 a D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mes_MPrint
	bsr	Mes_Print
	beq.s	.Skip
	bsr	Return
.Skip	addq.w	#1,d0
	cmp.w	d1,d0
	bls.s	Mes_MPrint
	rts
;	Imprime le message D0 / Niveau D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mes_Print
	tst.b	Flag_Quiet(a5)
	beq.s	.Print
	rts
.Print	movem.l	a0-a1/d0-d1,-(sp)
	bsr	Get_ConfigMessage
	tst.b	(a0)
	beq.s	.Out
	bsr	Str_Print
	moveq	#1,d0
.Out	movem.l	(sp)+,a0-a1/d0-d1
	rts

;	Imprime la chaine A0 (finie par 0) sur l'output standart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Str_Print
	tst.b	Flag_Quiet(a5)
	beq.s	.Print
	rts
.Print	movem.l	a0-a6/d0-d7,-(sp)
	tst.b	Flag_AMOS(a5)
	bne.s	.AMOSPrint
	bsr	Cpt_Chaine
	move.l	d0,d3
	move.l	a0,d2
	move.l	DosBase(a5),a6
	jsr	_LVOOutput(a6)
	move.l	d0,d1
	jsr	_LVOWrite(a6)
	bra.s	.Out
; Imprime le message dans la fenetre AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.AMOSPrint
	move.l	AMOS_Dz(a5),a5
	tst.w	Direct(a5)
	bne.s	.Dir
.Norm	tst.w	ScOn(a5)		Mode programme
	beq.s	.Out
	move.l	a0,a1
	WiCall	Print
	bra.s	.Out
.Dir	tst.b	Esc_Output(a5)		Mode direct > ESC / Normal
	beq.s	.Norm
	move.l	a0,-(sp)
	EcCalD	Active,EcEdit
        move.l	(sp)+,a1
	WiCall	Print
	move.w	ScOn(a5),d1
	beq.s	.Out
	subq.w	#1,d1
	EcCall	Active
.Out	movem.l	(sp)+,a0-a6/d0-d7
	rts

; 	Impression des messages d'info A0/D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Info_Print
	movem.l	a0-a2/d0-d2,-(sp)
	move.l	B_Work(a5),a1
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
	lea	-1(a1),a0
	bsr	longdec
	move.b	#10,(a0)+
	move.b	#13,(a0)+
	clr.b	(a0)
	move.l	B_Work(a5),a0
	bsr	Str_Print
	movem.l	(sp)+,a0-a2/d0-d2
	rts

;	Print un chiffre!
; ~~~~~~~~~~~~~~~~~~~~~~~
Digit	movem.l	d1-d7/a0-a2,-(sp)
	move.l	B_Work(a5),a0
	bsr	longdec
	clr.b	(a0)
	move.l	B_Work(a5),a0
	bsr	Str_Print
	movem.l	(sp)+,d1-d7/a0-a2
	rts

;	Retour chariot
; ~~~~~~~~~~~~~~~~~~~~
Return	lea	Mes_Return(pc),a0
	bra	Str_Print

;	Compte la longueur de la chaine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cpt_Chaine
	move.l	a1,-(sp)
	move.l	a0,a1
.Loop	tst.b	(a1)+
	bne.s	.Loop
	sub.l	a0,a1
	subq.l	#1,a1
	move.l	a1,d0
	move.l	(sp)+,a1
	rts

;	Choisit la chaine CLI ou AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOSouCLI
	tst.b	Flag_AMOS(a5)
	bne.s	.Out
.Loop	tst.b	(a0)+
	bne.s	.Loop
.Out	rts

;	Transforme les "/" en retour chariot / Copie la chaine >>> Buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Add_Return
;	move.l	a1,-(sp)
;	move.l	B_Work(a5),a1
;.Loop	move.b	(a0)+,d0
;	beq.s	.Cpt
;	cmp.b	#"\",d0
;	beq.s	.Ret
;	move.b	d0,(a1)+
;	bne.s	.Loop
;	bra.s	.Cpt
;.Ret	tst.b	Flag_AMOS(a5)
;	beq.s	.Skip
;	move.b	#13,(a1)+
;.Skip	move.b	#10,(a1)+
;.Cpt	move.l	a1,d0
;	clr.b	(a1)+
;	move.l	B_Work(a5),a0
;	sub.l	a0,d0
;	move.l	(sp)+,a1
;	rts

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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	OUVERTURE / TOKENISATION / TEST du source
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Open_Source
; - - - - - - - - - - - - -
	clr.b	MathFlags(a5)		Pas de float par defaut
; Affichage
; ~~~~~~~~~
	moveq	#28,d0			Opening source...
	bsr	Mes_Print
	move.l	Path_Source(a5),a0
	bsr	Str_Print
	bsr	Return

; Charge le debut du source
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#F_Source,d0
	move.l	Path_Source(a5),d1
	bsr	F_OpenOldD1
	beq	Err_CantOpenSource
	moveq	#F_Source,d1
	bsr	F_Lof
	move.l	d0,L_Source(a5)
	move.l	#256,d3
	cmp.l	d3,d0
	bcc.s	.Long
	move.l	d0,d3
.Long	move.l	d3,d7			D7= longueur chargee
	move.l	B_Work(a5),d2
	moveq	#F_Source,d1
	bsr	F_Read
	bne	Err_DiskError
	moveq	#0,d2
	moveq	#-1,d3
	bsr	F_Seek
	move.l	B_Work(a5),d2
; Un header AMOS?
	move.l 	d2,a0
        lea 	Head_AMOS(pc),a1
        moveq 	#10-1,d0
.Loop1 	cmpm.b 	(a0)+,(a1)+
        bne.s	.Skip1
        dbra 	d0,.Loop1
	bra.s	.Test
; Un header AMOSPro?
.Skip1	move.l	d2,a0
        lea 	Head_AMOSPro(pc),a1
        moveq 	#8-1,d0
.Loop2 	cmpm.b 	(a0)+,(a1)+
        bne.s	.NoHeader
        dbra 	d0,.Loop2
	move.l	d2,a1			Prend le flag maths...
	move.b	15(a1),MathFlags(a5)
; Un header AMOS, teste ou pas?
.Test	tst.b	Flag_Tokeniser(a5)
	bne	Err_DejaTokenise
	move.l	d2,a0
	move.l	16(a0),d0		Longueur du source
	add.l	#20,d0
	move.l	d0,End_Source(a5)
	move.l	d0,A_Banks(a5)
	cmp.b	#"V",11(a0)		Programme teste?
	bne	Source_Test
	bra	Source_OK
; Pas de header AMOS, est-ce un programme en ascii?
.NoHeader
	tst.b	Flag_Tokeniser(a5)
	bne	Source_Tokenise
	subq.w	#1,d7			Les 255 1ers caracteres
	move.l	B_Work(a5),a0
.Loop3	move.b	(a0)+,d1
	cmp.b	#32,d1
	bcc.s	.Asc
	cmp.b	#10,d1
	beq.s	.Asc
	cmp.b	#13,d1
	beq.s	.Asc
	cmp.b	#9,d1
	bne	Err_NotAMOSProgram
.Asc	dbra	d7,.Loop3
	bra	Source_Tokenise

;	Programme teste, sur disque, on peut eventuellement en direct to disc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Source_OK
	bsr	Compile_Reserve		Reserve les buffers de compilation
; Essaie d'abord en ram, charge tout d'un coup...
	clr.b	Flag_Source(a5)
	bsr	Load_AllSource
	bne.s	.Out
; On ne pas en ram, peut-on sur disque?
	tst.b	Flag_Numbers(a5)	Pas si mode number
	bne	Err_OOfMem
; Petit buffer d'entree: charge le debut
	addq.b	#1,Flag_Source(a5)
	tst.b	Flag_Infos(a5)		Des infos?
	beq.s	.Noinfo
	lea	Debug_SDisc(pc),a0	Un signal si disc!
	bsr	Str_Print
.Noinfo	move.l	MaxBso(a5),d0
	lea	B_Source(a5),a0
	bsr	Buffer_Reserve
; Charge le premier buffer
        clr.l 	DebBso(a5)
	move.l	L_Source(a5),TopSou(a5)
        move.l 	MaxBso(a5),FinBso(a5)
        bsr 	LoadBso
; Charge le nombre de banques
	move.l	End_Source(a5),d2
	moveq	#F_Source,d1
	moveq	#-1,d3			Seek a partir du debut
	bsr	F_Seek
	move.l	B_Work(a5),d2
	moveq	#6,d3
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a2
	move.w	4(a2),N_Banks(a5)
; Ok, on peut continuer...
.Out	rts

;	Ferme le source
; ~~~~~~~~~~~~~~~~~~~~~
Close_Source
	lea	B_Source(a5),a0
	bsr	Buffer_Free
	lea	Prg_FullSource(a5),a0
	bsr	Buffer_Free
	moveq	#F_Source,d1
	bsr	F_Close
	rts

;	Charge tout le source en RAM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Load_AllSource
	move.l	L_Source(a5),d3		Longueur source
	move.l	d3,d0
	lea	B_Source(a5),a0		Essaie de charger le source
	bsr	Buffer_ReserveNoError
	beq.s	.Err
	moveq	#F_Source,d1
	move.l	a0,d2
	bsr	F_Read
	bne	Err_DiskError
; Marque la fin du programme
	move.l	d2,a2
	move.l	16(a2),d0			Taille du programme
	add.l	#20,d0
	move.l	d0,A_Banks(a5)			= Adresse des banques
	move.l	d0,End_Source(a5)		= Fin du source
	clr.l	0(a2,d0.l)			Met un zero
	move.w	4(a2,d0.l),N_Banks(a5)		Nombre de banques
	moveq	#-1,d0
.Err	rts

;	CHARGEMENT + TEST DU PROGRAMME EN RAM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Source_Test
	clr.b	Flag_Source(a5)			Source en RAM!
	bsr	Load_AllSource			Charge le programme
	beq	Err_OOfMem			Toujours en RAM
;	Charge les routines de test
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#21,d0
	bsr	Mes_Print
	bsr	Return
	move.l	B_Source(a5),Prg_Source(a5)
	add.l	#20,Prg_Source(a5)		Saute le header
	bsr	Test_Load
	bsr	Test_Init
	bsr	Test_Test
	tst.l	d0
	bne	Test_Error
; Pas d'erreur!
; ~~~~~~~~~~~~~
	tst.l	Prg_FullSource(a5)		Si des includes
	beq.s	.NoIncludes
	move.b	#-1,Flag_Source(a5)		Source en INCLUDE!
	move.l	#$7fffffff,End_Source(a5)	Fin du source!
.NoIncludes
	bsr	Test_Fin			Efface tout
	bsr	Test_Free
	bsr	Compile_Reserve			Reserve les buffers de tokenisation
	rts

; Des erreurs!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Test_Error
	addq.l	#1,d1			Ligne=Ligne+1
	movem.l	d0/d1/a0,-(sp)
	bsr	Test_Fin
	tst.b	Flag_AMOS(a5)
	beq.s	.Load
	tst.l	Ed_TstMessages(a5)
	bne.s	.Cree
; Charge les messages d'erreur de la configuration editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Load	bsr	Open_EditConfig
	bsr	Skip_EditChunk		Saute les chaines systeme
	bsr	Skip_EditChunk		Saute les menus
	bsr	Skip_EditChunk		Saute les messages editeur
	lea	B_EditMessages1(a5),a0
	bsr	Load_EditChunk		Charge les messages!
	move.l	B_EditMessages1(a5),Ed_TstMessages(a5)
	moveq	#F_Courant,d1
	bsr	F_Close
; Cree le message d'erreur dans le buffer B_WORK
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Cree	move.l	(sp),d0
	move.l	Ed_TstMessages(a5),a0
	bsr	Get_Message
	move.l	4(sp),d0
	bsr	Cree_ErrorMessageNumber
	move.b	#":",(a0)+
	move.b	#" ",(a0)+
	clr.b	(a0)
; Cree la ligne avec le pointer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a0,-(sp)
	lea	B_Temporaire(a5),a0
	move.l	#512,d0
	bsr	Buffer_Reserve
	move.l	a0,a1
	move.l	VerPos(a5),d0
	move.l	12(sp),a0
	bsr	Test_Detok
	move.w	d0,d3
	move.l	(sp)+,a1
	lea	Err_Pointer0(pc),a0
	bsr	AMOSouCLI
	bsr	.Copy
	move.l	B_Temporaire(a5),a3	Fabrique la ligne
	move.w	(a3)+,d2
	clr.b	0(a3,d2.w)
	moveq	#30,d4
	add.w	d3,d4
	clr.b	0(a3,d4.w)
	sub.w	#43,d4
	bpl.s	.S1
	moveq	#0,d4
.S1	move.b	0(a3,d3.w),d2
	clr.b	0(a3,d3.w)
	lea	0(a3,d4.w),a0
	bsr	.Copy
	lea	Err_Pointer1(pc),a0
	bsr	AMOSouCLI
	bsr	.Copy
	lea	0(a3,d3.w),a0
	move.b	d2,(a0)
	bsr	.Copy
	lea	Err_Pointer2(pc),a0
	bsr	AMOSouCLI
	bsr	.Copy
; Efface les routines de test
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Test_Free
; Fini le compilateur!
; ~~~~~~~~~~~~~~~~~~~~
	move.l	B_Work(a5),a0		Message
	move.l	(sp),d0			Numero error message
	moveq	#-1,d1			Pointer la ligne
	move.l	4(sp),d2		Numero ligne
	lea	12(sp),sp
	bra	Go_Error
; Routine de copie
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
	subq.l	#1,a1
	rts


;	ROUTINES GESTION TESTING
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Test_Load
	tst.l	B_RTest(a5)		Deja charge?
	bne.s	.Skip
	lea	Routines_Test(pc),a0
	lea	B_RTest(a5),a1
	bsr	Load_Routines		Charge!
.Skip	rts
Test_Init
	move.l	B_RTest(a5),a0
	jmp	(a0)
Test_Test
	bsr	Ver_Verif
	move.l	B_RTest(a5),a0
	jsr	4(a0)
	movem.l	d0-d1/a0-a1,-(sp)
	bsr	Ver_Run
	movem.l	(sp)+,d0-d1/a0-a1
	rts
Test_Fin
	move.l	B_RTest(a5),a0
	jmp	8(a0)
Test_Detok
	move.l	B_RTest(a5),a2
	jmp	12(a2)
Test_Free
	lea	B_RTest(a5),a0		Enleve le buffer
	bsr	Buffer_Free
	moveq	#0,d0			Recalcule les offsets
	bsr	Library_Offsets
	rts

; 	Tokenisation du programme RAM >>> DISK
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Source_Tokenise
; Message
	moveq	#20,d0			Opening source...
	bsr	Mes_Print
	bsr	Return
; Ouvre le tokenisateur
	bsr	Token_Load		Charge les routines
	bsr	Token_Init		Reserve les buffers
; Charge le source dans un buffer en RAM
	move.l	L_Source(a5),d0
	move.l	d0,d3
	addq.l	#8,d0
	lea	B_Source(a5),a0
	bsr	Buffer_Reserve
	move.l	a0,d2
	moveq	#F_Source,d1
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a0
	add.l	d3,a0
	clr.b	(a0)
	moveq	#F_Source,d1
	bsr	F_Close
; Ouvre le programme objet sur disque
	move.l	Path_Source(a5),a0
	bsr	Extract_DiskName
	move.l	Name1(a5),a2		Copie en NAME1
	move.l	Path_Temporaire(a5),a1
	tst.b	(a1)			Si un path pour les fichiers TEMP
	beq.s	.Patmp
.Copy1	move.b	(a1)+,(a2)+		Copie le path
	bne.s	.Copy1
	subq.l	#1,a2
	move.l	a0,a1			Puis met le nom
	bra.s	.Copy2
.Patmp	move.l	Path_Source(a5),a1	Sinon path complet
.Copy2	cmp.l	d0,a1			Copie le nom
	beq.s	.LaFin
	move.b	(a1)+,(a2)+
	bne.s	.Copy2
	subq.l	#1,a2
.LaFin	lea	Point_AMOS(pc),a1
.Copy3	move.b	(a1)+,(a2)+
	bne.s	.Copy3
	move.l	Name1(a5),a0		A deleter au cas ou ca ne marche pas
	bsr	Add_DeleteList
; Ouvre le fichier objet
	moveq	#F_Courant,d0
	bsr	F_OpenNew
	beq	Err_DiskError
	lea	Prog_Header(pc),a0	Sort le header de programme AMOS
	move.l	a0,d2
	moveq	#20,d3
	moveq	#F_Courant,d1
	bsr	F_Write
	bne	Err_DiskError
; Boucle de tokenisation!
	clr.b	MathFlags(a5)		Pas de maths
	move.l	B_Source(a5),a0
	move.l	a0,d2
	add.l	L_Source(a5),d2
	moveq	#0,d4			Longueur du source
.TLoop	cmp.l	d2,a0
	bcc.s	.TExit
	move.l	a0,a1
.Zero	move.b	(a1)+,d0
	cmp.b	#32,d0
	bcc.s	.Zero
	cmp.b	#13,d0
	beq.s	.Z
	cmp.b	#10,d0
	beq.s	.F
	cmp.b	#9,d0
	beq.s	.Zero
	cmp.l	d2,a1
	bcc.s	.F
	bra	Err_NotAMOSProgram
.Z	move.b	#" ",-1(a1)
	bra.s	.Zero
.F	clr.b	-1(a1)
	move.l	Ed_BufT(a5),a1		Va tokeniser
	move.l	B_RToken(a5),a2
	jsr	(a2)
	bmi	Err_LineTooLong
	movem.l	a0/d2,-(sp)		Sauve la ligne tokenisee...
	moveq	#F_Courant,d1
	move.l	a1,d2
	moveq	#0,d3
	move.b	(a1),d3
	lsl.w	#1,d3
	add.l	d3,d4
	bsr	F_Write
	bne	Err_DiskError
	movem.l	(sp)+,a0/d2
	bra.s	.TLoop
; Ferme le fichier
.TExit	lea	Prog_Finish(pc),a0	Met AMBs00 a la fin
	move.l	a0,d2
	moveq	#6,d3
	moveq	#F_Courant,d1
	bsr	F_Write
	bne	Err_DiskError
	moveq	#0,d2			Pointe le debut
	moveq	#-1,d3
	bsr	F_Seek
	lea	Prog_Header(pc),a0	Sauve le header avec les
	move.l	a0,d2			bonnes valeurs
	move.l	d4,16(a0)
	move.b	MathFlags(a5),15(a0)
	moveq	#20,d3
	bsr	F_Write
	bsr	F_Close
	add.l	#20+6,d4		Poke la longueur pour la suite
	move.l	d4,L_Source(a5)
; Name1 >>> Path_Source
	move.l	Name1(a5),a0
	move.l	Path_Source(a5),a1
	bsr	CopName
; Fin de la tokenisation
	bsr	Token_End		Efface les buffers
	bsr	Token_Remove		Enleve les routines
	tst.b	Flag_Tokeniser(a5)	Garder le fichier tokenise?
	bne.s	.Garder
	moveq	#F_Source,d0		Re-ouvre le source
	move.l	Path_Source(a5),d1
	bsr	F_OpenOldD1
	bne	Source_Test		Branche au test!
	bra	Err_DiskError
; On est en mode tokenisateur: garder et quitter
.Garder	bsr	Sub_DeleteList		Enleve de la delete-list!
	bra	TheEndOk

;	Charge les routines de tokenisation + Init
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Token_Load
	tst.l	B_RToken(a5)		Deja charge?
	bne.s	.Skip
	lea	Routines_Token(pc),a0
	lea	B_RToken(a5),a1
	bsr	Load_Routines		Charge!
.Skip	rts
Token_Init
	move.l	B_RToken(a5),a0
	jsr	4(a0)			Init des tables de tokenisation
	bne	Err_OOfMem
	rts
Token_End
	move.l	B_RToken(a5),a0
	jsr	8(a0)			Init des tables de tokenisation
	bne	Err_OOfMem
	rts
Token_Remove
	lea	B_RToken(a5),a0		Enleve le buffer
	bsr	Buffer_Free
	moveq	#0,d0			Recalcule les offsets
	bsr	Library_Offsets
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION DE L'ENTREE DU PROGRAMME
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;-----> Prend un MOT du programme (A6)
GetWord:tst.b 	Flag_Source(a5)
        bne.s 	.Disk
	add.l	B_Source(a5),a6
        move.w 	(a6)+,d0
	sub.l	B_Source(a5),a6
        rts
; Sur disque
.Disk	bmi.s	.Inclu
	move.l 	a0,-(sp)
        bsr 	SoDisk
        move.w 	(a0),d0
        addq.l 	#2,a6
        move.l 	(sp)+,a0
        rts
; Dans les includes!
.Inclu	add.l	Prg_FullSource(a5),a6
        move.w 	(a6)+,d0
	sub.l	Prg_FullSource(a5),a6
        rts

;-----> Prend un MOTLONG du programme (A6)
GetLong:tst.b 	Flag_Source(a5)
        bne.s 	.Disk
	add.l	B_Source(a5),a6
	move.l	(a6)+,d0
	sub.l	B_Source(a5),a6
	rts
; Sur disque?
.Disk	bmi.s	.Inclu
	move.l 	a0,-(sp)
        bsr 	SoDisk
        move.l 	(a0),d0
        addq.l 	#4,a6
        move.l 	(sp)+,a0
        rts
; Dans les includes!
.Inclu	add.l	Prg_FullSource(a5),a6
        move.l 	(a6)+,d0
	sub.l	Prg_FullSource(a5),a6
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
        bsr 	F_Seek
; Sauve l'ancien
	moveq	#F_Source,d1
        move.l 	B_Source(a5),d2
        move.l	TopSou(a5),d3
        sub.l 	DebBso(a5),d3
        cmp.l 	MaxBso(a5),d3
        bcs.s 	SoDi2
        move.l 	FinBso(a5),d3
        sub.l 	DebBso(a5),d3
SoDi2:  bsr 	F_Read
	bne	Err_DiskError
	rts



























; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION DU PROGRAMME OBJET
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Ouverture du programme objet
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Open_Objet
; Ouvre TOUJOURS en m�moire: reserve le 1er buffer
	move.l	#L_Bob,d0
	add.l	#16,d0
	lea	BB_Objet_Base(a5),a0
	bsr	Buffer_Reserve
	move.l	a0,BB_Objet(a5)
	move.l	#L_Bob,4(a0)
	rts

;; Ancienne ouverture directe sur disque
;.Disc	move.l	Path_Objet(a5),d1	Ouvre le fichier
;	moveq	#F_Objet,d0
;	bsr	F_OpenNewD1
;	beq	Err_DiskError
;	move.l	Path_Objet(a5),a0	Additionne a la delete list
;	bsr	Add_DeleteList

Reserve_DiscObjet
	move.l	#L_Bob,d0
	lea	B_Objet(a5),a0
	bsr	Buffer_Reserve
	clr.l	DebBob(a5)
	move.l	#L_Bob,FinBob(a5)
	clr.l	TopOb(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Efface tous les buffers objets
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Free_Objet
	move.l	BB_Objet_Base(a5),d3
	beq.s	.skip
.loop	move.l	d3,a1
	move.l	8(a1),d3
	move.l	-(a1),d0
	bsr	RamFree
	tst.l	d3
	bne.s	.loop
	clr.l	BB_Objet_Base(a5)
.skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Sauve/Ferme le programme objet
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Close_Objet
	moveq	#29,d0				Closing object
	bsr	Mes_Print
	move.l	Path_Objet(a5),a0
	bsr	Str_Print
	bsr	Return
	tst.b	Flag_Objet(a5)
	bne.s	SObj1
; En memoire, sauve tous les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Save_Objet
	bra.s	SObj2
; Sur disque: sauve le dernier buffer!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SObj1	bsr	SaveBob
; Ferme le fichier
SObj2	moveq	#F_Objet,d1
	bsr	F_Close
	bsr	Sub_DeleteList		Enleve le nom de la delete list
	rts

; 	Ouvre et sauve tous les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Save_Objet
	move.l	Path_Objet(a5),d1		Ouvre le fichier
	moveq	#F_Objet,d0
	bsr	F_OpenNewD1
	beq	Err_DiskError
	move.l	Path_Objet(a5),a0		Sur la delete list
	bsr	Add_DeleteList
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
	bsr	F_Write
	bne	Err_DiskError
.loop2	tst.l	d4
	bne.s	.loop
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FABRICATION DES HUNKS PROGRAMMES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Reserve la place pour mettre les hunks
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ResHunk	cmp.b	#3,Flag_Type(a5)
	bne.s	.Hunk
	rts
.Hunk	move.w	N_Hunks(a5),d0
	ext.l	d0
	lsl.l	#3,d0
	lea	B_Hunks(a5),a0
	bsr	Buffer_Reserve
	rts

;	Debut HUNK D1, type D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DebHunk	cmp.b	#3,Flag_Type(a5)
	beq.s	A4_Pair
	movem.l	d0-d2/a0-a1,-(sp)
	move.l	#$3E9,d0
	or.l	d2,d0
	bsr	OutLong
	moveq	#0,d0
	bsr	OutLong
	lsl.w	#3,d1
	move.l	B_Hunks(a5),a1
	move.l	a4,0(a1,d1.w)
	move.l	d2,4(a1,d1.w)
	movem.l	(sp)+,d0-d2/a0-a1
	rts

;	Fin d'un hunk
; ~~~~~~~~~~~~~~~~~~~
FinHunk	cmp.b	#3,Flag_Type(a5)
	bne.s	FHu0
; Si AMOS, rend pair...
A4_Pair	move.w	a4,d0
	and.w	#$0001,d0
	add.w	d0,a4
	rts
; Fait le HUNK
FHu0	movem.l	d0-d2/a0-a1,-(sp)
	lsl.w	#3,d1
	move.l	B_Hunks(a5),a1
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

;	Marque la longueur d'un hunk
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MarkHunk
	movem.l	d0-d2/a0-a1,-(sp)
	lsl.w	#3,d1
	move.l	B_Hunks(a5),a1
	move.l	0(a1,d1.w),a4
	subq.l	#4,a4
	move.l	4(a1,d1.w),d0
	and.l	#$00FFFFFF,d0
	bsr	OutLong
	movem.l	(sp)+,d0-d2/a0-a1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION RELOCATION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;-----> Init relocation
Init_Reloc
	move.l	B_Reloc(a5),a3
	rts

;-----> Cree un appel a la routine #D0: JMP R(a4)
Do_JmpLibrary
	movem.l	d0/a0,-(sp)
        move.l 	d0,a0
        move.w 	Cjmp2a4(pc),d0
        bra.s 	CreF
;-----> Cree un appel a un sous programme #D0: JMP R(a4)
Do_JsrLibrary
	movem.l	d0/a0,-(sp)
        move.l 	d0,a0
        move.w 	Cjsr2a4(pc),d0
CreF:   bsr 	OutWord
        bsr 	Lib_Relocation		Pointe la table de relocation ici
	move.w	a0,d0
	lsl.w	#2,d0
	neg.w	d0
        bsr 	OutWord			#ROUTINE.W
; Met le flag dans buffer
	move.l	AdTokens(a5),a0
	bset	#LBF_Called,LB_Flags(a0)
	cmp.b	#2,-LB_Size-4(a0,d0.w)
	beq.s	.Skip
	move.b	#2,-LB_Size-4(a0,d0.w)
	addq.w	#1,Lib_NInternes(a5)
.Skip	movem.l	(sp)+,d0/a0
        rts


;-----> Cree un appel a un sous programme #D0, librairie #D1
Do_LeaExtLibrary
	movem.l	d0-d1/a0,-(sp)
        move.w 	d0,a0
        move.w 	Cleaa0(pc),d0
	bra.s	Do_Lib
Do_JsrExtLibrary
	movem.l	d0-d1/a0,-(sp)
        move.w 	d0,a0
        move.w 	Cjsr(pc),d0
Do_Lib	bsr 	OutWord
        bsr 	Relocation		Pointe la table de relocation ici
	lsl.w	#2,d1
	move.w	d1,d0
	swap	d0
	move.w	a0,d0
	lsl.w	#2,d0
	neg.w	d0
	or.l	#Rel_Libraries,d0	Marque une librairie externe
        bsr 	OutLong			#ROUTINE.L
; Met le flag extension
	move.l	AdTokens(a5,d1.w),d1
	beq	Err_ExtensionNotLoaded
	move.l	d1,a0
	bset	#LBF_Called,LB_Flags(a0)
	cmp.b	#1,-LB_Size-4(a0,d0.w)
	beq.s	.Skip
	move.b	#1,-LB_Size-4(a0,d0.w)
	addq.w	#1,Lib_NExternes(a5)
.Skip	movem.l	(sp)+,d0-d1/a0
        rts

;-----> Marque la table de relocation des routines JSR
Lib_Relocation
	movem.l a0/a4,-(sp)
	move.l	Lib_OldRel(a5),a0
	move.l 	a4,Lib_OldRel(a5)
	sub.l 	a0,a4
	move.l	A_LibRel(a5),a0
	cmp.l	#32766,a4
	bcc.s	.Grand
	move.w	a4,(a0)+
.Suite	move.l	a0,A_LibRel(a5)
        movem.l	(sp)+,a0/a4
        rts
.Grand	move.l	a4,(a0)
	bset	#7,(a0)
	addq.l	#4,a0
	bra.s	.Suite

;-----> Marque la table de relocation
Relocation
	move.l d0,-(sp)
        move.l 	a4,d0
        sub.l 	OldRel(a5),d0
.ReJ1:  cmp.w	#510,d0
	beq.s	.ReJ2
	cmp.w 	#508,d0
        bls.s 	.ReJ2
	bsr	OutRel1
        sub.w 	#508,d0
        bra.s 	.ReJ1
.ReJ2:  lsr.w	#1,d0
	move.b	d0,(a3)+
	move.l 	a4,OldRel(a5)
        move.l	(sp)+,d0
        rts
; Poke un octet dans la table de relocation
OutRel 	move.b 	d0,(a3)+
	rts
OutRel1 move.b 	#1,(a3)+
	rts

;-----> Copie D3 octets, fichier D1 en (a4)
Out_F_Read
	movem.l	a0-a2/d0-d7,-(sp)
	move.l	d1,d5
	move.l	B_DiskIn(a5),d2
	move.l	d3,d6
Ofr0	move.l	#L_DiscIn,d3
	cmp.l	d6,d3
	bcs.s	Ofr1
	move.l	d6,d3
Ofr1	move.l	d5,d1
	bsr	F_Read
	bne	Err_DiskError
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

;-----> Copie A0 octets D0 -> objet
Copy_Out
	move.l	d0,d1
	lsr.w	#1,d1
	bra.s	.In
.Loop	move.w	(a0)+,d0
	bsr	OutWord
.In	dbra	d1,.Loop
	rts

;-----> Copie D3 octets source->objet
Copy_Source
	tst.l	d3
	beq.s	CpyS
CpyS1	bsr	GetWord
	bsr	OutWord
	subq.l	#2,d3
	bcs.s	CpyS
	bne.s	CpyS1
CpyS	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION DES BUFFERS SORTIE/ENTREE DANS LE PROGRAMME OBJET
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;-----> Trouve le buffer objet contenant A4
GetBob	movem.l	a1/d0/d1,-(sp)
	move.l	BB_Objet_Base(a5),a0
.loop	move.l	a0,a1
	move.l	(a0),d1
	add.l	4(a0),d1
	cmp.l	d1,a4
	bcs.s	.loop2
	move.l	8(a0),d0
	move.l	d0,a0
	bne.s	.loop
; Il faut en reserver un autre...
.loop1	lea	8(a1),a0
	move.l	#L_Bob,d0
	add.l	#16,d0
	bsr	Buffer_ReserveNoError
	beq.s	.ToDisc
; En reserver ENCORE un autre?
	move.l	d1,(a0)
	move.l	#L_Bob,4(a0)
	move.l	a0,a1
	add.l	#L_Bob,d1
	cmp.l	d1,a4
	bcc.s	.loop1
; Ok, on peut continuer en memoire!
.loop2	move.l	a1,BB_Objet(a5)
	moveq	#0,d0
	movem.l	(sp)+,a1/d0/d1
	rts
; Arghhh! Il faut passer tout sur disque!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ToDisc	movem.l	a1-a3/d2-d7,-(sp)

	tst.b	Flag_Infos(a5)
	beq.s	.Noinfo
	lea	Debug_ODisc(pc),a0	Un signal si disc!
	bsr	Str_Print
.Noinfo
	move.l	a4,L_Objet(a5)		Longueur maxi=longueur actuelle
	bsr	Save_Objet		On sauve!
	bsr	Free_Objet		On efface tous les buffers
	moveq	#F_Objet,d1		Demande la longueur du fichier
	moveq	#0,d2
	moveq	#0,d3
	bsr	F_Seek
	move.l	B_Work(a5),d2		Si longueur fichier<longueur programme
	move.l	a4,d3
	sub.l	d0,d3
	beq.s	.Same
	bsr	F_Write			Va ecrire n'importe quoi!
	bne	Err_DiskError
.Same	bsr	Reserve_DiscObjet	Reserve les buffers
	move.l	a4,TopOb(a5)		Maxi actuel
	bsr	LoadBob			Charge le premier buffer
	move.b	#1,Flag_Objet(a5)	On est maintenant sur disque
	moveq	#-1,d0			Il faut changer!
	movem.l	(sp)+,a1-a3/d2-d7
	movem.l	(sp)+,a1/d0/d1
	rts

;-----> Poke un BYTE dans l'objet
OutByte:tst.b	Flag_Objet(a5)
	bne.s	OutbD
* En m�moire
	movem.l	a0/a4,-(sp)
.Reskip	move.l	BB_Objet(a5),a0
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
	beq.s	.Reskip
	movem.l	(sp)+,a0/a4
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
OutWord:tst.b	Flag_Objet(a5)
	bne.s	OutwD
* En m�moire
OutW	movem.l	a0/a4,-(sp)
.Reskip	move.l	BB_Objet(a5),a0
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
	beq.s	.Reskip
	movem.l	(sp)+,a0/a4
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
OutLong:tst.b	Flag_Objet(a5)
	bne.s	OutlD
* En m�moire
	movem.l	a0/a4,-(sp)
.Reskip	move.l	BB_Objet(a5),a0
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
.probleme
	movem.l	(sp)+,a0/a4
	swap	d0
	bsr	OutW
	swap	d0
	bra	OutW
.skip	movem.l	(sp),a0/a4
	bsr	GetBob
	beq.s	.Reskip
	movem.l	(sp)+,a0/a4
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

;-----> Sort un MOVE / MOVEQ dans l'objet
OutMove:cmp.l	#128,d2
	bcs.s	.Kwik
	bsr	OutWord
	move.l	d2,d0
	bra	OutLong
.Kwik	move.w	d1,d0
	move.b	d2,d0
	bra	OutWord

;-----> Prend un mot dans l'objet
GtoWord	tst.b	Flag_Objet(a5)
	beq	GtoW
* Sur disque
	move.l 	a0,-(sp)
        bsr 	ObDisk
        move.w 	(a0)+,d0
        addq.l 	#2,a4
        move.l 	(sp)+,a0
        rts

;-----> Prend un mot long dans l'objet
GtoLong:tst.b	Flag_Objet(a5)
	bne.s	PaGL
* En memoire
	bsr	GtoW
	swap	d0
	bsr	GtoW
	tst.l	d0
	rts
GtoW	movem.l	a0/a4,-(sp)
.Reskip	move.l	BB_Objet(a5),a0
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
	beq.s	.Reskip
	movem.l	(sp)+,a0/a4
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

;-----> REND A4 PAIR
A4Pair	move.w	a4,d0
	btst	#0,d0
	beq.s	.Skip
	addq.l	#1,a4
.Skip	rts

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
	bsr	LoadBob
; Trouve l'adresse relative
	movem.l (sp)+,d0-d7/a0-a2
        move.l 	a4,a0
        sub.l 	DebBob(a5),a0
        add.l 	B_Objet(a5),a0
        rts

;-----> Charge le buffer objet
LoadBob	moveq 	#F_Objet,d1
	move.l	DebBob(a5),d2
	moveq	#-1,d3
        bsr 	F_Seek
	move.l	B_Objet(a5),d2
        move.l 	FinBob(a5),d3
        cmp.l 	TopOb(a5),d3
        bcs.s 	.ObDi6
        move.l 	TopOb(a5),d3
.ObDi6: sub.l 	DebBob(a5),d3
        beq.s 	.ObDi7
	moveq	#F_Objet,d1
        bsr 	F_Read
	bne	Err_DiskError
; Nettoie la fin du buffer ???
;	move.l	d2,a0
;	add.l	d3,a0
;	cmp.l	FinBob(a5),a0
;	bcc.s	.NoClr
;	move.l	FinBob(a5),d0
;	sub.l	a0,d0
;	bcs.s	.NoClr
;.Clr	clr.b	(a0)+
;	dbra	d0,.Clr
;.NoClr
.ObDi7	rts

;-----> Sauve le buffer OBJET
SaveBob:moveq	#F_Objet,d1
        move.l 	DebBob(a5),d2
	moveq	#-1,d3
        bsr 	F_Seek
; Sauve l'ancien
	moveq	#F_Objet,d1
        move.l 	B_Objet(a5),d2
        move.l 	TopOb(a5),d3
        sub.l 	DebBob(a5),d3
        cmp.l 	#L_Bob,d3
        bcs.s 	ObDi2
	move.l 	FinBob(a5),d3
        sub.l 	DebBob(a5),d3
ObDi2:  bsr 	F_Write
	bne	Err_DiskError
        rts

;	Stockage position de l'objet
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StockOut
	move.l	a0,-(sp)
	move.l	A_Stock(a5),a0
	move.l	a3,(a0)+
	move.l	a4,(a0)+
	move.l	OldRel(a5),(a0)+
	move.l	A_LibRel(a5),(a0)+
	move.l	Lib_OldRel(a5),(a0)+
	move.l	A_Chaines(a5),(a0)+
	move.l	a0,A_Stock(a5)
	move.l	(sp)+,a0
	rts
RestOut
	move.l	a0,-(sp)
	move.l	A_Stock(a5),a0
	move.l	-(a0),A_Chaines(a5)
	move.l	-(a0),Lib_OldRel(a5)
	move.l	-(a0),A_LibRel(a5)
	move.l	-(a0),OldRel(a5)
	move.l	-(a0),a4
	move.l	-(a0),a3
	move.l	a0,A_Stock(a5)
	move.l	(sp)+,a0
	rts
SautOut
	sub.l	#16,A_Stock(a5)
	rts

;	Marque la prochaine instruction dans la table des debut instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OutLea	movem.l	a0/a4,-(sp)
	move.l	B_Instructions(a5),a0
	sub.l	(a0)+,a4
	addq.w	#1,(a0)
	move.l	A_Instructions(a5),a0
	move.l	a4,(a0)+
	move.l	a0,A_Instructions(a5)
	movem.l	(sp)+,a0/a4
	rts





















; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				CHARGEMENT DES LIBRAIRIES + EXTENSIONS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Load
; - - - - - - - - - - - - - - - -

; Librairie principale AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#14,d0
	bsr	Get_IntConfigMessage
	bsr	AddPathCom
	moveq	#0,d0
	bsr	Library_Load
	bne.s	.Err
; Extensions
; ~~~~~~~~~~
	moveq	#1,d2
.Loop	move.l	d2,d0
	add.w	#16-1,d0
	bsr	Get_IntConfigMessage
	tst.b	(a0)
	beq.s	.Next
	bsr	AddPathCom
	move.w	d2,d0
	bsr	Library_Load
	bne.s	.Err
	move.w	d2,d0
	bsr	Library_Offsets
.Next	addq.w	#1,d2
	cmp.w	#27,d2
	bne.s	.Loop
; Insere la librarie interne au compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Library_Interne
	moveq	#0,d0
	bsr	Library_Offsets
	moveq	#0,d0
.Err	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				CHARGEMENT D'UNE LIBRAIRIE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Name1=	Nom
;	A0=	Command line
;	D0=	Numero
; - - - - - - - - - - - - - - - -
Library_Load
; - - - - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	d0,d6
	addq.w	#F_Libs,d6		+ Handle libraries...
	move.l	a0,a4
	lea	AdTokens(a5),a6
	lsl.w	#2,d0
	add.w	d0,a6
; Ouvre le fichier
; ~~~~~~~~~~~~~~~~
	move.l	d6,d0
	bsr	F_OpenOld
	beq	Ll_Disc
; Lis l'entete dans le buffer
	move.l	d6,d1
	move.l	B_Work(a5),d2
	move.l	#$20+18,d3
	bsr	F_Read
	bne	Ll_Disc
	move.l	d2,a3
	lea	$20(a3),a3
	move.l	(a3),d5
	lsr.l	#1,d5			D5= nombre de fonctions
; Reserve la zone memoire...
	move.l	d5,d4
	lsl.l	#2,d4			Taille des jumps
	addq.l	#4,d4			+ Dernier jump (taille derniere routine)
	moveq	#LB_Size,d3		Data zone negative
	add.l	4(a3),d3		+ Tokens
	move.l	d3,d0
	add.l	d4,d0
	move.l	d0,d1
	bsr	RamFast
	beq	Ll_OMem
	move.l	d0,a0
	lea	LB_Size(a0,d4.l),a2	Saute les jumps et la datazone
	move.l	a2,(a6)			Extension chargee!!!
	move.l	d1,LB_MemSize(a2)	Taille de la zone memoire
	move.l	a0,LB_MemAd(a2)		Adresse de base
	move.l	(a3),d3			Buffer temporaire pour les tailles
	move.l	d3,d0
	addq.l	#4,d0
	bsr	RamFast
	beq	Ll_OMem
	move.l	d0,a0
	move.l	d3,(a0)+
	move.l	a0,LB_LibSizes(a2)
; Une nouvelle / ancienne librarie?
	clr.w	LB_Flags(a2)		Flags
	bset	#LBF_20,LB_Flags(a2)
	moveq	#4,d3
	move.l	B_Work(a5),d2
	move.l	d6,d1
	bsr	F_Read
	bne	Ll_Disc
	move.l	d2,a0
	cmp.l	#"AP20",(a0)
	beq.s	.Suit
	bclr	#LBF_20,LB_Flags(a2)
	move.l	d6,d1
	moveq	#-4,d2
	moveq	#0,d3
	bsr	F_Seek
; Charge les tailles des routines
.Suit	move.l	LB_LibSizes(a2),a0
	move.l	-4(a0),d3
	move.l	a0,d2
	move.l	d6,d1
	bsr	F_Read
	bne	Ll_Disc
; Charge les tokens et les tables...
	move.l	4(a3),d3		Tokens
	move.l	a2,d2
	move.l	d6,d1
	bsr	F_Read
	bne	Ll_Disc
; Rempli la datazone
	move.w	d5,LB_NRout(a2)		Nombre de routines
	move.l	a4,LB_Command(a2)

; Recupere les donnees speciales pour librairies nouvelles
	btst	#LBF_20,LB_Flags(a2)	Si 2.0
	beq.s	.NoTable
	move.l	d2,a0			Pointe la fin des tokens
	lea	-4(a0,d3.l),a0
	add.l	(a0),a0

	cmp.l	#"FSwp",(a0)		Des routines a swapper?
	bne.s	.NoFSwp
	move.w	4(a0),LB_DFloatSwap(a2)
	move.w	6(a0),LB_FFloatSwap(a2)
	addq.l	#8,a0
.NoFSwp
	cmp.l	#"ComP",(a0)		Des donnees sur les routines speciales
	bne.s	.NoComp
	addq.l	#4,a0
	move.w	(a0)+,d0
	subq.w	#1,d0
	lea	Lib_SizeInterne(a5),a1	On recopie!
.Copy	move.b	(a0)+,(a1)+
	dbra	d0,.Copy
.NoComp
	cmp.l	#"KwiK",(a0)		Verification rapide?
	bne.s	.NoKwik
	lea	4(a0),a0
	move.l	a0,LB_Verif(a2)		Poke l'adresse...
.NoKwik

; Poke les donnees dans le header librairie
.NoTable
	move.l	d6,d1			Trouve la position du fichier
	moveq	#0,d2
	moveq	#0,d3
	bsr	F_Seek
	move.l	d0,-LB_Size-4(a2)	= Position de la premiere routine
	tst.w	16(a3)			Flag always init
	beq.s	.NoInit
	bset	#LBF_AlwaysInit,LB_Flags(a2)
.NoInit
; Pas d'erreur
	moveq	#0,d0
	bra	Ll_Out

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	CHARGEMENT DE LA LIBRARIE INTERNE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Library_Interne
; - - - - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	AdTokens(a5),a2
; Calcule la position de la routine (500) de la librairie principale
	move.l	LB_LibSizes(a2),a0
	lea	-LB_Size(a2),a1
	move.w	Lib_SizeInterne(a5),d0
	addq.w	#8,d0
	moveq	#0,d1
	move.l	-LB_Size-4(a2),d2
.Size	move.l	d2,-(a1)
	move.w	(a0)+,d1
	add.l	d1,d2
	add.l	d1,d2
	dbra	d0,.Size
; Ouvre le fichier
	moveq	#3,d0
	bsr	Get_ConfigMessage
	bsr	AddPath
	moveq	#F_LibInterne,d0
	bsr	F_OpenOld
	beq	Ll_Disc
; Lis l'entete dans le buffer
	moveq	#F_LibInterne,d1
	move.l	B_Work(a5),d2
	move.l	#$20+18,d3
	bsr	F_Read
	bne	Ll_Disc
	move.l	d2,a3
	lea	$20(a3),a3
	move.l	(a3),d5
	lsr.l	#1,d5			D5= nombre de fonctions
; Charge la table des longueurs sur la table interne
	moveq	#F_LibInterne,d1
	move.l	LB_LibSizes(a2),d2
	move.w	Lib_SizeInterne(a5),d3
	ext.l	d3
	lsl.l	#1,d3
	bsr	F_Read
	bne	Ll_Disc
; Position de la premiere routine
	moveq	#F_LibInterne,d1	Trouve la position du fichier
	moveq	#0,d2
	moveq	#0,d3
	bsr	F_Seek
	move.l	d0,-LB_Size-4(a2)	= Position de la premiere routine
; Pas d'erreur
	moveq	#0,d0
; Sortie chargement librairie
Ll_Out	movem.l	(sp)+,d2-d7/a2-a6
	rts
Ll_BadExt				*** A mettre
Ll_Disc	bra	Err_DiskError
Ll_OMem	bra	Err_OOfMem

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Fabrique la table des positions des routines
;	D0=	Library
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Library_Offsets
; - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	lsl.w	#2,d0
	move.l	AdTokens(a5,d0.w),a2
	tst.w	d0
	bne.s	.Norm
; Librarie principale, 500 premieres fonctions
	lea	-LB_Size(a2),a1		Debut des adresses
	move.l	LB_LibSizes(a2),a0	Liste des fonctions
	move.w	Lib_SizeInterne(a5),d0	Compteur
	bsr	.Rout
	move.w	LB_NRout(a2),d0		500 fonctions suivantes
	sub.w	Lib_SizeInterne(a5),d0
	bsr	.Rout
	bra	Ll_Out
; Libraries normales
.Norm	lea	-LB_Size(a2),a1		Debut des adresses
	move.l	LB_LibSizes(a2),a0	Liste des fonctions
	move.w	LB_NRout(a2),d0		Compteur
	bsr	.Rout
	bra	Ll_Out
; Tchote routine
.Rout	move.l	-4(a1),d1		Position de la premiere routine
	moveq	#0,d2
	subq.w	#1,d0
.Loop	move.l	d1,-(a1)
	move.w	(a0)+,d2
	add.l	d2,d1
	add.l	d2,d1
	dbra	d0,.Loop
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				EFFACEMENT DES LIBRARIES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Free
; - - - - - - - - - - - - - - - -
	movem.l	a2-a6/d2-d7,-(sp)
	moveq	#27-1,d2
	lea	AdTokens(a5),a2
.Loop	move.l	(a2),d0
	beq.s	.Next
	move.l	d0,a0
	move.l	LB_LibSizes(a0),d0	Les tailles des libraries
	beq.s	.Skip
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	bsr	RamFree
.Skip	move.l	(a2),a0			La librarie elle meme
	clr.l	(a2)
	move.l	LB_MemAd(a0),a1
	move.l	LB_MemSize(a0),d0
	bsr	RamFree
.Next	addq.l	#4,a2			Library suivante...
	dbra	d2,.Loop
	moveq	#0,d0
	bra	Ll_Out

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	CHARGEMENT DE ROUTINES POUR LE COMPILATEUR
;	A0=	Table des routines � charger
;	A1=	Adresse du pointeur de buffer
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Load_Routines
; - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a0,a4
	move.l	a1,a6

; Calcul de la taille necessaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	AdTokens(a5),a3
	move.l	LB_LibSizes(a3),a2
	move.l	a4,a0
	moveq	#0,d1
	moveq	#0,d0
	bra.s	.SIn
.SLoop	lsl.w	#1,d2
	move.w	0(a2,d2.w),d1
	add.l	d1,d0
	add.l	d1,d0
.SIn	move.w	(a0)+,d2
	bne.s	.SLoop
; Reservation du buffer
; ~~~~~~~~~~~~~~~~~~~~~
	move.l	d0,d6
	move.l	a6,a0
	bsr	Buffer_Reserve
; Chargement des routines
; ~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a0,d5			Pointeur d'adresse
	move.l	a4,a2			Table des routines
	move.l	LB_LibSizes(a3),a1	Table des tailles
	bra.s	.LIn
.LLoop	moveq	#F_Libs,d1		Handle
	cmp.w	Lib_SizeInterne(a5),d4
	bcc.s	.LSkip
	moveq	#F_LibInterne,d1
.LSkip	move.w	d4,d0
	lsl.w	#2,d0
	neg.w	d0
	move.l	-LB_Size-4(a3,d0.w),d2	Position de la routine
	move.l	d5,-LB_Size-4(a3,d0.w) 	>>> adresse de la routine chargee!
	moveq	#-1,d3			Depuis le debut
	bsr	F_Seek			Positionne le fichier
	lsl.w	#1,d4
	moveq	#0,d3
	move.w	0(a1,d4.w),d3		Taille de la routine
	lsl.l	#1,d3
	move.l	d5,d2			Adresse de chargement
	add.l	d3,d5			Nouvelle routine
	bsr	F_Read
	bne	Err_DiskError
.LIn	move.w	(a2)+,d4		Nouvelle routine
	bne.s	.LLoop
; Branche quelques fausse routines
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Add_Routines(pc),a0
	move.l	a0,d0
	move.w	(a0)+,d1
.FLoop	move.l	(a0)+,d2
	add.l	d0,d2
	lsl.w	#2,d1
	neg.w	d1
	move.l	d2,-LB_Size-4(a3,d1.w)
	move.w	(a0)+,d1
	bne.s	.FLoop
; Relocation des routines chargees
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	(a4)+,d0
.RLoop	bsr	Ll_LoadReloc
	move.w	(a4)+,d0
	bne.s	.RLoop
	bsr	Sys_ClearCache		Nettoie les caches
; Ca y est!
; ~~~~~~~~~
	moveq	#0,d0
	bra	Ll_Out

;	Routine de relocation de la routine chargee D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ll_LoadReloc
	movem.l	d2-d7/a2-a6,-(sp)
	lsl.w	#1,d0
	move.l	LB_LibSizes(a3),a0
	moveq	#0,d4
	move.w	0(a0,d0.w),d4		Taille de la routine
	lsl.l	#1,d4
	lsl.w	#1,d0
	neg.w	d0
	move.l	-LB_Size-4(a3,d0.w),a0	Adresse de la routine
	add.l	a0,d4			Fin routine
GRou1	move.b	(a0),d0			Boucle d'exploration
	cmp.b	#C_Code1,d0
	beq	GRou10
GRou2	addq.l	#2,a0
	cmp.l	d4,a0
	bcs.s	GRou1
GRouN	bra	Ll_Out

; Instruction speciale
GRou10	move.w	(a0),d0
	move.b	d0,d2
	and.b	#$0F,d0
	cmp.b	#C_Code2,d0
	bne	GRou2
	and.w	#$00F0,d2
	lsr.w	#1,d2
	lea	GRout(pc),a1
	jmp	0(a1,d2.w)
; Table des sauts
GRout	bra	GRouJ			; 0 - RJmp / Rjmptable
	dc.w	$4ef9			JMP
	jmp	(a0)
	bra	GRouJ			; 1 - RJsr / Rjsrtable
	dc.w	$4eb9			JSR
	jsr	(a0)
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
	bra	GRouD			; 15- RData / Ret_Inst
GRouMve	move.l	0(a4),a0
GRlea	lea	$0.l,a0
CJsr	jsr	0(a4)
; RJMP / RJSR
GRouJ	cmp.b	#C_CodeJ,2(a0)
	beq.s	.Rjsr
	cmp.b	#C_CodeT,2(a0)
	bne	GRou2
; Rjsrt / Rjmpt
	move.b	3(a0),d0
	cmp.b	#8,d0
	bcc.s	.Rlea
	and.w	#$0007,d0
	move.w	d0,d1
	lsl.w	#8,d1
	lsl.w	#1,d1
	or.w	GRouMve(pc),d1		Move.l	X(a4),ax
	move.w	d1,(a0)+
	move.w	2(a0),d1
	lsl.w	#2,d1
	add.w	#LB_Size+4,d1
	neg.w	d1
	move.w	d1,(a0)+
	or.w	6(a1,d2.w),d0		Jsr/Jmp	(ax)
	move.w	d0,(a0)+
	bra	GRou1
; Rlea
.Rlea	subq.w	#8,d0
	cmp.b	#8,d0
	bcc	GRou2
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	GRlea(pc),d0
	move.w	d0,(a0)
	move.w	4(a0),d0
	moveq	#0,d1
	addq.l	#6,a0
	bra.s	.Qq
; Rjsr / Rjmp direct
.Rjsr	moveq	#0,d1			Transforme en JSR direct
	move.b	3(a0),d1
	cmp.b	#27,d1			Numero de l'extension
	bcc	GRou2
	move.w	4(a1,d2.w),(a0)
	move.w	4(a0),d0
	addq.l	#6,a0
	ext.w	d1
; Extension quelconque
.Qq	lsl.w	#2,d1
	lea	AdTokens(a5),a1
	move.l	0(a1,d1.w),d1
	beq	Ll_BadExt
	move.l	d1,a1			Adresse des tokens de l'extension
	cmp.w	LB_NRout(a1),d0		Superieur au maximum?
	bcc	Ll_BadExt
.AA	lsl.w	#2,d0
	neg.w	d0
	move.l	-LB_Size-4(a1,d0.w),-4(a0)
	bra	GRou1
; RBRA etc..
GRouB	move.w	2(a0),d0
	cmp.w	d5,d0
	bcc	GRou2
	lsl.w	#2,d0
	move.w	4(a1,d2.w),(a0)+
	neg.w	d0
	move.l	-LB_Size-4(a3,d0.w),d0
	sub.l	a0,d0
	cmp.l	#-32766,d0
	ble	Gfaux
	cmp.l	#32766,d0
	bge	Gfaux
	move.w	d0,(a0)+
	bra	GRou1
; Instruction RDATA / Ret_Inst
GRouD	cmp.w	#C_CodeD,2(a0)
	bne.s	GRouD1
	move.w	Cnop(pc),d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	bra	GRouN
; *** Instruction Ret_Inst
GRouD1	cmp.w	#C_CodeInst,2(a0)
	bne	GRou2
	move.l	Crts(pc),(a0)+
	bra	GRou1
Gfaux	illegal


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Preparation des tables de tokenisation pour la compilation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Ver_Compile
	movem.l	a0-a3/d0-d3,-(sp)
	bsr	Ver_Run			Passe en mode RUN
	move.l	AdTokens(a5),a0		Debut des tokens
	move.l	LB_Verif(a0),a1		Adresse table
	lea	Inst_Jumps(pc),a2
	lea	Func_Jumps(pc),a3
	move.w	(a1)+,d1		Longueur table
	ext.l	d1
	add.l	a1,d1			Fin table
.Loop	move.w	(a0),d2			Token instruction
	move.w	2(a0),d3		Token fonction
	move.b	(a1),d0			L'instruction
	ext.w	d0
	cmp.w	#1,d0			Simple SYNTAX ERROR?
	bne.s	.NoSynt
	cmp.b	#1,1(a1)		Un autre syntax error apres?
	beq.s	.NoSynt
	move.w	d3,d0			OUI! on met la fonction
	bra.s	.Synt
.NoSynt	addq.w	#8,d0			Pour sauter les negatifs
	lsl.w	#2,d0
	tst.l	0(a2,d0.w)		Speciale?
	beq.s	.Func
	neg.w	d0
.Synt	move.w	d0,(a0)			Change le token
.Func	move.b	1(a1),d0		La fonction
	ext.w	d0
	cmp.w	#1,d0			Simple SYNTAX Error
	bne.s	.NoSint
	cmp.b	#1,(a1)			Un syntax avant?
	beq.s	.NoSint
	move.w	d2,d0			OUI! Met l'instruction
	bra.s	.Sint
.NoSint	lsl.w	#2,d0
	tst.l	0(a3,d0.w)		Speciale?
	beq.s	.Next
	neg.w	d0
.Sint	move.w	d0,2(a0)		Change le token
.Next	lea	4(a0),a0
.Skip1	tst.b	(a0)+
	bpl.s	.Skip1
.Skip2	tst.b	(a0)+
	bpl.s	.Skip2
	move.w	a0,d0
	and.w	#$0001,d0
	add.w	d0,a0
	addq.l	#4,a1
	cmp.l	d1,a1
	bcs.s	.Loop
	movem.l	(sp)+,a0-a3/d0-d3
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				Echange des tables de tokenisation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	bsr.s	Ver_Ech				On echange
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION DE LA CONFIGURATION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Copie un nom A0>A1
; ~~~~~~~~~~~~~~~~~~~~~~~~
CopName	movem.l	a0/a1,-(sp)
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
	movem.l	(sp)+,a0/a1
	rts

;	Charge la configuration, si elle existe
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Load_Config
	moveq	#F_Courant,d0
	move.l	Path_Config(a5),d1
	bsr	F_OpenOldD1
	beq.s	.Out
; Charge!
	lea	B_Config(a5),a1
	bsr	Load_InBuffer2
	cmp.l	#"CCt1",(a0)
	bne	Err_BadConfig
	move.l	B_Config(a5),d0
	move.l	d0,A_Config(a5)
.Out	rts

;	Recupere les chaines par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cold_Config
	moveq	#9,d0
	bsr	Get_ConfigMessage
	move.l	Path_Temporaire(a5),a1
	bsr	CopName
	rts

;	Digere la configuration du compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Init_Config
	tst.b	Flag_AMOS(a5)
	bne	.AMOS
; Charge la configuration de l'interpreteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#2,d0
	bsr	Get_ConfigMessage
	moveq	#F_Courant,d0
	move.l	a0,d1
	bsr	F_OpenOldD1
	beq	Err_CantLoadIntConfig
; Charge les donn�es dc.w
	moveq	#8,d3
	move.l	B_Work(a5),d2
	moveq	#F_Courant,d1
	bsr	F_Read
	bne	Err_CantLoadIntConfig
	move.l	d2,a2
	cmp.l	#"PId1",(a2)
	bne	Err_BadIntConfig
	move.l	4(a2),d3
	lea	PI_Start(a5),a0
	move.l	a0,d2
	bsr	F_Read
	bne	Err_CantLoadIntConfig
; Charge les donn�es texte
	move.l	a2,d2
	moveq	#8,d3
	bsr	F_Read
	bne	Err_CantLoadIntConfig
	cmp.l	#"PIt1",(a2)
	bne	Err_BadIntConfig
	lea	B_IntConfig(a5),a0
	move.l	4(a2),d0
	move.l	d0,d3
	bsr	Buffer_Reserve
	move.l	a0,d2
	bsr	F_Read
	bne	Err_CantLoadIntConfig
	jsr	F_Close
	move.l	B_IntConfig(a5),Sys_Messages(a5)
; Trouve le path complet du systeme (si pas AMOS)(si pas precise dans command)
.GetDir	tst.b	Sys_Pathname(a5)
	bne.s	.Skip
	moveq	#1,d0				Acces au path
	bsr	Get_IntConfigMessage
	bsr	AskDir				Demande le directory
.Skip	rts
; Si AMOS, ne charge rien, recopie les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.AMOS	move.l	AMOS_Dz(a5),a0
	move.l	Sys_Messages(a0),Sys_Messages(a5)
	lea	PI_Start(a0),a1
	lea	PI_Start(a5),a2
	move.w	#(PI_End-PI_Start)/2-1,d0
.Copy	move.w	(a1)+,(a2)+
	dbra	d0,.Copy
; Recopie le path du systeme, si defini
	lea	Sys_Pathname(a0),a1	Pathname AMOS
	lea	Sys_Pathname(a5),a2	Pathname deja defini (LIBS=)
	tst.b	(a2)
	bne.s	.Skip
	tst.b	(a1)			Pathname AMOS pas defini: le trouve!
	beq.s	.GetDir
.Copy1	move.b	(a1)+,(a2)+		Recopie du pathname origine
	bne.s	.Copy1
	rts


; 	Ouvre la configuration editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Open_EditConfig
	moveq	#7,d0
	bsr	Get_IntConfigMessage
	bsr	AddPath
	moveq	#F_Courant,d0		Ouvre le fichier
	bsr	F_OpenOld
	beq	Err_CantLoadEditConfig
	move.l	B_Work(a5),d2
	moveq	#4,d3
	moveq	#F_Courant,d1
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a0
	cmp.l	#Ed_FConfig-Ed_DConfig,(a0)
	bne	Err_BadEditConfig
	moveq	#F_Courant,d1
	move.l	#Ed_FConfig-Ed_DConfig,d2
	moveq	#0,d3
	bsr	F_Seek
	rts
; 	Saute un chunk config editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Skip_EditChunk
	move.l	B_Work(a5),d2
	moveq	#4,d3
	moveq	#F_Courant,d1
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a0
	move.l	(a0),d2
	moveq	#0,d3
	moveq	#F_Courant,d1
	bsr	F_Seek
	rts
;	Charge un chunk config editeur >>> buffer (a0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Load_EditChunk
	move.l	a2,-(sp)
	move.l	a0,a2
	move.l	B_Work(a5),d2
	moveq	#4,d3
	moveq	#F_Courant,d1
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a0
	move.l	(a0),d3
	move.l	d3,d0
	move.l	a2,a0
	bsr	Buffer_Reserve
	move.l	a0,d2
	bsr	F_Read
	bne	Err_DiskError
	move.l	d2,a0
	move.l	(sp)+,a2
	rts

;	Charge le fichier A0 dans un buffer (a1)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Load_InBuffer2
	movem.l	a2/d2-d3,-(sp)
	move.l	a1,a2
	bra.s	Load_In
Load_InBuffer
	movem.l	a2/d2-d3,-(sp)
	move.l	a1,a2
	moveq	#F_Courant,d0
	move.l	a0,d1
	bsr	F_OpenOldD1
	beq	Err_DiskError
Load_In	moveq	#F_Courant,d1
	bsr	F_Lof
	move.l	d0,d3
	move.l	a2,a0
	bsr	Buffer_Reserve
	beq	Err_OOfMem
	move.l	a0,d2
	moveq	#F_Courant,d1
	bsr	F_Read
	bne	Err_DiskError
	moveq	#F_Courant,d1
	bsr	F_Close
	move.l	(a2),a0
	movem.l	(sp)+,a2/d2-d3
	rts
.DErr	move.l	a2,a0
	bsr	Buffer_Free
	bra	Err_DiskError

;	Retourne le message CONFIG INTERPRETER D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_IntConfigMessage
	move.l	Sys_Messages(a5),a0
	bra.s	Get_Message
;	Retourne le message CONFIG D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_ConfigMessage
	tst.l	A_Config(a5)
	beq.s	Get_Urgence
	move.l	A_Config(a5),a0
	addq.l	#8,a0
;	Retourne le message D0/A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_Message
	move.w	d1,-(sp)
	clr.w	d1
	cmp.l	#0,a0
	beq.s	.Big
	addq.l	#1,a0
	bra.s	.In
.Loop	move.b	(a0),d1
	cmp.b	#$ff,d1
	beq.s	.Big
	lea	2(a0,d1.w),a0
.In	subq.w	#1,d0
	bgt.s	.Loop
.Out	move.w	(sp)+,d1
	move.b	(a0)+,d0
	rts
.Big	lea	.Fake(pc),a0
	bra.s	.Out
.Fake	dc.b	0,0,0,0

;	Config non chargee: messages d'urgence
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Get_Urgence
	lea	Mes_Urgence(pc),a0
.Loop	cmp.b	(a0)+,d0
	beq.s	.Ok
.Loop1	tst.b	(a0)
	bne.s	.Loop1
	bra.s	.Loop
.Ok	rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION MEMOIRE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Reservation de la zone de donn�e interne du compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reserve_DZ
	movem.l	a0-a1/d0-d1,-(sp)
	IFNE	Debug=2
	bsr	WMemInit
	ENDC
	move.l	#DataLong,d0
	bsr	RamFastNoCount
	beq	Err_OOfMem
	lea	DZ(pc),a0
	move.l	d0,(a0)
	move.l	d0,a5
	move.l	#DataLong,Mem_Current(a5)
	movem.l	(sp)+,a0-a1/d0-d1
	rts
;	Liberation de la data zone
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_DZ	move.l	DZ(pc),d0
	beq.s	.Skip
	move.l	d0,a1
	move.l	#DataLong,d0
	bsr	RamFree
.Skip
	IFNE	Debug=2
	bsr	WMemEnd
	ENDC
	rts


; 	Liberation de tous les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_Work
	tst.b	Flag_AMOS(a5)		Si AMOS
	beq.s	.CLI
	clr.l	Buffer(a5)		On efface pas le BUFFER!
	clr.l	B_Work(a5)
.CLI	bsr	Buffer_FreeAll
	lea	Name1(a5),a0
	bsr	Buffer_Free
	rts

; 	Reservation des principaux buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reserve_Work
	move.l	#256,d0			Name1
	lea	Name1(a5),a0
	bsr	Buffer_Reserve
	moveq	#108,d0			Source
	lea	Path_Source(a5),a0
	bsr	Buffer_Reserve
	moveq	#108,d0			Objet
	lea	Path_Objet(a5),a0
	bsr	Buffer_Reserve
	moveq	#108,d0			Configuration
	lea	Path_Config(a5),a0
	bsr	Buffer_Reserve
	moveq	#108,d0			Temporaire
	lea	Path_Temporaire(a5),a0
	bsr	Buffer_Reserve
	move.l	#L_PathToDelete,d0	Delete list
	lea	Path_ToDelete(a5),a0
	bsr	Buffer_Reserve
; Cas special de B_WORK
	tst.b	Flag_AMOS(a5)		Si CLI
	bne.s	.AMOS
	move.l	#512,d0			Le "buffer"
	lea	B_Work(a5),a0
	bsr	Buffer_Reserve
	move.l	a0,Buffer(a5)		Aussi le BUFFER pour le test...
	rts
.AMOS	move.l	AMOS_Dz(a5),a0		So AMOS, on prend buffer origine!
	move.l	Buffer(a0),B_Work(a5)
	move.l	Buffer(a0),Buffer(a5)
	rts

;	Reservation memoire, reserve le buffer +4 avec header de taille
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Buffer_ReserveNoError
	clr.w	-(sp)
	bra.s	Buffer_R
Buffer_Reserve
	move.w	#-1,-(sp)
Buffer_R
	bsr	Buffer_Free		Par securite!
	movem.l	d0/d1/a2,-(sp)
	move.l	a0,a2
	addq.l	#4,d0
	move.l	d0,d1
	bsr	RamFast
	beq.s	.Err
	move.l	d0,a0
	move.l	d1,(a0)+
	move.l	a0,(a2)
.Err	movem.l	(sp)+,d0/d1/a2
	bne.s	.Out
	tst.w	(sp)
	bne	Err_OOfMem
.Out	addq.l	#2,sp
	rts

; 	Effacement du buffer (a0)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Buffer_Free
	movem.l	a0-a1/d0-d1/a6,-(sp)
	move.l	(a0),d0
	beq.s	.Skip
	clr.l	(a0)
	move.l	d0,a1
	move.l	-(a1),d0
	bsr	RamFree
.Skip	movem.l	(sp)+,a0-a1/d0-d1/a6
	rts
;	Effacement memoire de tous les buffers generaux
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Buffer_FreeAll
	movem.l	a0/d0,-(sp)
	lea	F_Buffers(a5),a0
	move.l	a0,d0
	lea	D_Buffers(a5),a0
.Loop	bsr	Buffer_Free
	addq.l	#4,a0
	cmp.l	d0,a0
	bcs.s	.Loop
	movem.l	(sp)+,a0/d0
	rts

;	Reservation buffer temporaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ResTempBuffer
	movem.l	d1/a1,-(sp)
	move.l	d0,d1
; Libere l'ancien buffer
	move.l	TempBuffer(a5),d0
	beq.s	.NoLib
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	bsr	RamFree
	clr.l	TempBuffer(a5)
; Reserve le nouveau
.NoLib	move.l	d1,d0
	beq.s	.Exit
	addq.l	#4,d0
	bsr	RamFast
	beq.s	.Exit
	move.l	d0,a0
	move.l	d1,(a0)+
	move.l	a0,TempBuffer(a5)
	move.l	d1,d0
.Exit	movem.l	(sp)+,d1/a1
	rts

	IFEQ	Debug=2
;	Reservation memoire, mise a zero!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
RamFast	add.l	d0,Mem_Current(a5)
	move.l	d0,-(sp)
	move.l	Mem_Current(a5),d0
	cmp.l	Mem_Maximum(a5),d0
	bcs.s	.Inf
	move.l	d0,Mem_Maximum(a5)
.Inf	move.l	(sp)+,d0
RamFastNoCount
	movem.l	d1/a0-a1/a6,-(sp)
	move.l	#Public|Clear,d1
	move.l	$4.w,a6
	jsr	_LVOAllocMem(a6)
	movem.l	(sp)+,d1/a0-a1/a6
	tst.l	d0
	rts
;	Liberation memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~
RamFree	movem.l	d0-d1/a0-a1/a6,-(sp)
	sub.l	d0,Mem_Current(a5)
	move.l	$4.w,a6
	jsr	_LVOFreeMem(a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts
	ENDC


	IFNE	Debug

PreBug 	btst	#6,$BFE001
	beq.s	BugBug
	rts
BugBug	movem.l	d0-d2/a0-a2,-(sp)
.Ll	move.w	#$FF0,$DFF180
 	btst	#6,$BFE001
	bne.s	.Ll
	move.w	#20,d0
.L0	move.w	#10000,d1
.L1	move.w	d0,$DFF180
	dbra	d1,.L1
	dbra	d0,.L0
	btst	#6,$BFE001
	beq.s	.Ill
	movem.l	(sp)+,d0-d2/a0-a2
	rts
.Ill	movem.l	(sp)+,d0-d2/a0-a2
	illegal
	rts

	ENDC


	IFNE	Debug=2

		RsReset
Mem_Length	rs.l	1
Mem_Pile	rs.l	8
Mem_Header	equ	__RS
Mem_Border	equ	128
Mem_Code	equ	$AA
MemList_Size	equ	1024*8

; Initialisation memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemInit
	movem.l	a0-a1/a5-a6/d0-d1,-(sp)
	lea	C_MemList(pc),a5
	move.l	#MemList_Size*4,d0
	move.l	#Clear|Public,d1
	move.l	$4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,(a5)
	beq	TheEnd
	movem.l	(sp)+,a0-a1/a5-a6/d0-d1
	rts

; Fin memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemEnd
	movem.l	a0-a1/a5-a6/d0-d1,-(sp)
	lea	C_MemList(pc),a5
	tst.l	(a5)
	beq.s	.Skip
	bsr	WMemCheck
	move.l	#MemList_Size*4,d0
	move.l	(a5),a1
	move.l	$4.w,a6
	jsr	FreeMem(a6)
	clr.l	(a5)
.Skip	movem.l	(sp)+,a0-a1/a5-a6/d0-d1
	rts

; Reservation memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	Longueur
;	D1=	Flags
RamFast	add.l	d0,Mem_Current(a5)
	move.l	d0,-(sp)
	move.l	Mem_Current(a5),d0
	cmp.l	Mem_Maximum(a5),d0
	bcs.s	.Inf
	move.l	d0,Mem_Maximum(a5)
.Inf	move.l	(sp)+,d0
RamFastNoCount
	movem.l	d1-d3/a0-a2/a5-a6,-(sp)
	move.l	Mem_Current(a5),d1
	cmp.l	Mem_Maximum(a5),d1
	bcs.s	.Inf
	move.l	d1,Mem_Maximum(a5)
.Inf	lea	C_MemList(pc),a5
	move.l	#Public|Clear,d1
	move.l	d1,d2
	move.l	d0,d3
	add.l	#Mem_Header+2*Mem_Border,d0
	move.l	$4.w,a6
	jsr	AllocMem(a6)
	tst.l	d0
	beq.s	.OutM
; Store the adress in the table
.Again	move.l	(a5),a0
.Free	tst.l	(a0)+
	bne.s	.Free
	move.l	d0,-4(a0)
	move.l	d0,a0
	move.l	d3,(a0)+			Save length
	lea	3*4+3*4+2*4(sp),a1
	move.l	#"Pile",(a0)+			Code reconnaissance
	moveq	#6,d1
.Save	move.l	(a1)+,(a0)+			Save Content of pile
	dbra	d1,.Save
; Put code before and after memory
	move.b	#Mem_Code,d2
	move.w	#Mem_Border-1,d1
	move.l	a0,a1
	add.l	#Mem_Border,a1
	add.l	d3,a1
.Code1	move.b	d2,(a0)+
	move.b	d2,(a1)+
	dbra	d1,.Code1
; All right, memory reserved
	add.l	#Mem_Header+Mem_Border,d0
	bra.s	.MemX
; Out of memory: flush procedure!
.OutM	bsr	WMemFlush
; Try once again
	move.l	d2,d1
	move.l	d3,d0
	add.l	#Mem_Header+2*Mem_Border,d0
	jsr	AllocMem(a6)
	tst.l	d0
	bne.s	.Again
; Get out, address in D0, Z set.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.MemX	tst.l	d0
	movem.l	(sp)+,d1-d3/a0-a2/a5-a6
	rts

; Liberation memoire centralisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A1=	Debut zone
;	D0=	Taille zone
RamFree
	movem.l	d0-d2/a0-a2/a5-a6,-(sp)
	sub.l	d0,Mem_Current(a5)
	lea	C_MemList(pc),a5
; Find in the list
	sub.l	#Mem_Header+Mem_Border,a1
	move.l	(a5),a2
	move.w	#MemList_Size-1,d2
.Find	cmp.l	(a2)+,a1
	beq.s	.Found
	dbra	d2,.Find
	bra.s	Mem_NFound
; Found, erase from the list
.Found	clr.l	-4(a2)
; Check the length
	cmp.l	Mem_Length(a1),d0
	bne.s	Mem_BLen
; Check the borders
	lea	Mem_Header(a1),a0
	move.l	a0,a2
	add.l	#Mem_Border,a2
	add.l	d0,a2
	move.w	#Mem_Border-1,d1
.Check	cmp.b	#Mem_Code,(a0)+
	bne.s	Mem_BCode
	cmp.b	#Mem_Code,(a2)+
	bne.s	Mem_BCode
	dbra	d1,.Check
; Perfect!
	add.l	#Mem_Header+2*Mem_Border,d0
	move.l	$4.w,a6
	jsr	FreeMem(a6)
Mem_Go	movem.l	(sp)+,d0-d2/a0-a2/a5-a6
	rts
; Error messages
; ~~~~~~~~~~~~~~
Mem_NFound
	bsr	BugBug
	bra.s	Mem_Go
	dc.b	"No found"
Mem_BLen
	bsr	BugBug
	bra.s	Mem_Go
	dc.b	"Bad leng"
Mem_BCode
	bsr	BugBug
	bra.s	Mem_Go
	dc.b	"Bad code"

; Flush routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemFlush
	rts

; Check the whole memory list
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WMemCheck
	movem.l	d0-d2/a0-a2/a5-a6,-(sp)
	lea	C_MemList(pc),a5
	moveq	#0,d2
	move.l	(a5),a0
	move.w	#MemList_Size-1,d0
.List	tst.l	(a0)+
	beq.s	.Next
	move.l	-4(a0),a1
	add.l	(a1),d2
; Check the borders
	move.l	(a1),d1
	lea	Mem_Header(a1),a1
	lea	0(a1,d1.l),a2
	add.l	#Mem_Border,a2
	move.w	#Mem_Border-1,d1
.Check	cmp.b	#Mem_Code,(a1)+
	bne.s	.BCode2
	cmp.b	#Mem_Code,(a2)+
	bne.s	.BCode2
	dbra	d1,.Check
; Next chunk
.Next	dbra	d0,.List
	move.l	d2,d0
.Xx	movem.l	(sp)+,d0-d2/a0-a2/a5-a6
	rts
.BCode2
	bsr	BugBug
	moveq	#0,d0
	bra.s	.Xx
	dc.b	"Bad code"
	even
C_MemList
	dc.l	0
	ENDC

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Clear CPU Caches, quel que soit le systeme
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Sys_ClearCache
; - - - - - - - - - - - - -
	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	cmp.w	#37,$14(a6)			A partir de V37
	bcc.s	.Skip
	jsr	_LVOFindTask(a6)
	bra.s	.Exit
.Skip	jsr	_LVOCacheClearU(a6)		CacheClearU
.Exit	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION DISQUE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


;	Initialisation disque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Init_Disc
	movem.l	a0-a2/d0-d7,-(sp)

; Constantes d'acces au disque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#L_DiscIn,d0			Buffer disque
	lea	B_DiskIn(a5),a0
	bsr	Buffer_Reserve
	move.l	#L_BordBso,BordBso(a5)		Bordure source
	move.l	#L_BSo,MaxBso(a5)		Longueur buffer source
	move.l	#L_BordBob,BordBob(a5)		Bordure objet
; Ouvre la librarie DOS
; ~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	move.l	$4,a6
	lea	Nom_Dos(pc),a1			Le DOS
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DosBase(a5)
	beq	Err_System
.AMOSHere
	movem.l	(sp)+,a0-a2/d0-d7
	rts

;	Fermeture disque
; ~~~~~~~~~~~~~~~~~~~~~~
End_Disc
	movem.l	a0-a2/d0-d7,-(sp)
; Ferme tous les fichiers
	bsr	F_CloseAll
; Ferme les librairies
	tst.l	DosBase(a5)
	beq.s	.Skip
	move.l	DosBase(a5),a1
	move.l	$4.w,a6
	jsr	_LVOCloseLibrary(a6)
.Skip	movem.l	(sp)+,a0-a2/d0-d7
	rts


;	Initialisation des icones
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Init_Icon
	movem.l	a6,-(sp)
	tst.b	Flag_Type(a5)
	bne.s	.Iicx
; Ouvre la libraire ICON
	moveq	#0,d0
	lea	Nom_IconLib(pc),a1
	move.l	$4,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,IconBase(a5)
	beq	Err_NoIcons
; Charge l'icone par defaut
	moveq	#8,d0
	bsr	Get_ConfigMessage
	bsr	AddPath
	move.l	Name1(a5),a0
	move.l	IconBase(a5),a6
	jsr	-78(a6)
	move.l	d0,C_Icon(a5)
	beq	Err_NoIcons
	move.l	d0,a0
	move.l	#$80000000,d0		Position par defaut
	move.l	d0,$3a(a0)
	move.l	d0,$3e(a0)
; Ok!
.Iicx	movem.l	(sp)+,a6
	rts

;	Fin des icones
; ~~~~~~~~~~~~~~~~~~~~
End_Icon
	move.l	a6,-(sp)
	move.l	C_Icon(a5),d0
	beq.s	.Skip
	move.l	d0,a0
	move.l	IconBase(a5),a6
	jsr	-90(a6)
.Skip	move.l	IconBase(a5),d0
	beq.s	.Out
	move.l	d0,a1
	move.l	$4.w,a6
	jsr	_LVOCloseLibrary(a6)
.Out	move.l	(sp)+,a6
	rts

;	Sauve l'icone du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Save_Icon
	tst.b	Flag_Type(a5)
	bne.s	.SicX
	move.l	a6,-(sp)
	move.l	Path_Objet(a5),a0
	move.l	C_Icon(a5),a1
	move.l	IconBase(a5),a6
	jsr	-84(a6)
	move.l	(sp)+,a6
	tst.l	d0
	beq	Err_DiskError
.SicX	rts

;	Delete tous les fichiers intermediaires
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DeleteList
	movem.l	a2/a6,-(sp)
	move.l	Path_ToDelete(a5),a2
	addq.l	#1,a2
	bra.s	.In
.Loop	move.l	a2,d1
	move.l	DosBase(a5),a6
	jsr	_LVODeleteFile(a6)
.Skip	tst.b	(a2)+
	bne.s	.Skip
.In	tst.b	(a2)
	bne.s	.Loop
	movem.l	(sp)+,a2/a6
	rts

;	Additionne le nom A0 au fichiers � detruire en fin de comp
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Add_DeleteList
	move.l	Path_ToDelete(a5),a1
.Loop	tst.b	(a1)+
	bne.s	.Loop
	tst.b	(a1)
	bne.s	.Loop
	move.l	a0,-(sp)
.Loop1	tst.b	(a0)+
	bne.s	.Loop1
	move.l	a0,d0
	move.l	(sp)+,a0
	sub.l	a0,d0
	move.l	a1,d1
	sub.l	Path_ToDelete(a5),d1
	add.l	d1,d0
	cmp.l	#L_PathToDelete,d0
	bhi.s	.Out
.Loop2	move.b	(a0)+,(a1)+
	bne.s	.Loop2
	clr.b	(a1)
.Out	rts

;	Enleve le dernier nom au path des fichiers a deleter
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sub_DeleteList
	move.l	Path_ToDelete(a5),a0
.Loop0	move.l	a0,a1
.Loop1	tst.b	(a0)+
	bne.s	.Loop1
	tst.b	(a0)
	bne.s	.Loop0
	clr.b	(a1)+
	clr.b	(a1)
	rts

;	Fabrique le nom du programme OBJET
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Make_ObjectName
	move.l	Path_Objet(a5),a0
	tst.b	(a0)
	bne.s	.NObX
; Cherche un point
	move.l	Path_Source(a5),a0	Localise le nom
	bsr	Extract_DiskName
	move.l	a0,d0
.Loop	tst.b	(a0)+			Cherche la fin
	bne.s	.Loop
	subq.l	#1,a0
	move.l	a0,d1
.Loop1	cmp.l	d0,a0
	beq.s	.PaPoin
	cmp.b	#".",-(a0)		Point trouve, enleve la fin!
	bne.s	.Loop1
	move.l	a0,d0
	lea	Suf_Nul(pc),a1		Rien apres le point
	cmp.b	#3,Flag_Type(a5)
	bne.s	.Copy
	lea	Suf_C.AMOS(pc),a1	Si type 3: prg_C.AMOS
	bra.s	.Copy
.PaPoin	lea	Suf_Prg(pc),a1		Suffixe ".prg"
	move.l	d1,d0
.Copy	move.l	Path_Source(a5),a0
	move.l	Path_Objet(a5),a2
	bra.s	.In1
.Copy1	move.b	(a0)+,(a2)+		Copie le nom
.In1	cmp.l	a0,d0			Jusqu'au point
	bne.s	.Copy1
.Copy2	move.b	(a1)+,(a2)+		Copie le point!
	bne.s	.Copy2
.NObX	rts

; 	Extrait le nom d'un fichier d'un pathname, repere le "."
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0= 	Pathname
;	A0=	Out: Debut du nom
;	D0=	Eventuellement point
Extract_DiskName
	move.l	a0,a1
.Loop1	tst.b	(a1)+
	bne.s	.Loop1
	subq.l	#1,a1
	moveq	#0,d0
.Loop2	cmp.l	a0,a1
	beq.s	.Out
	move.b	-(a1),d1
	cmp.b	#"/",d1
	beq.s	.Out0
	cmp.b	#":",d1
	beq.s	.Out0
	cmp.b	#".",d1
	bne.s	.Loop2
	tst.l	d0
	bne.s	.Loop2
	move.l	a1,d0
	bra.s	.Loop2
.Out0	lea	1(a1),a0
.Out	rts


; 	Recupere le path complet d'un directory
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AskDir	move.l	a0,d1				Demande le lock
	moveq	#-2,d2
	DosCall	_LVOLock
	tst.l	d0
	beq	Err_CannotFindAPSystem
	clr.l	-(sp)
ADir0	move.l	d0,-(sp)
	move.l	d0,d1
	DosCall	_LVOParentDir
	tst.l	d0
	bne.s	ADir0
; Redescend les LOCKS en demandant le NOM!
	lea	Sys_Pathname(a5),a2
	clr.b	(a2)
	moveq	#":",d2
ADir1:	move.l	(sp)+,d1
	beq.s	ADir4
	move.l	B_Work(a5),a1
	movem.l	d1/d2/a1/a2,-(sp)
	move.l	a1,d2
	DosCall	_LVOExamine
	movem.l	(sp)+,d1/d2/a1/a2
	tst.l	d0
	beq.s	ADir3
	lea	8(a1),a1
ADir2:	move.b	(a1)+,(a2)+
	bne.s	ADir2
	move.b	d2,-1(a2)
	clr.b	(a2)
	moveq	#"/",d2
ADir3	DosCall	_LVOUnLock
	bra.s	ADir1
ADir4	rts

; 	AddPath sur un nom+command line, retourne la command line en A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AddPathCom
	movem.l	a1/d1,-(sp)
	move.l	a0,a1
.Lim1	move.b	(a1)+,d1
	beq.s	.Lim2
	cmp.b	#" ",d1
	bne.	.Lim1
.Lim2	move.b	-1(a1),d1
	clr.b	-1(a1)
	bsr	AddPath
	move.b	d1,-1(a1)
	bne.s	.Lim3
	subq.l	#1,a1
.Lim3	move.l	a1,a0
	movem.l	(sp)+,a1/d1
	rts

; 	Additionne le pathname du dossier APSystem, si pas de path defini!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AddPath
	movem.l	a1/a2,-(sp)
	move.l	Name1(a5),a2
	move.l	a0,a1
.Ess	move.b	(a1)+,d0
	cmp.b	#":",d0
	beq.s	.Cop2
	tst.b	d0
	bne.s	.Ess
	lea	Sys_Pathname(a5),a1
.Cop1	move.b	(a1)+,(a2)+
	bne.s	.Cop1
	subq.l	#1,a2
.Cop2	move.b	(a0)+,(a2)+
	bne.s	.Cop2
	movem.l	(sp)+,a1/a2
	rts

;	Trouve le handle #D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
F_Handle
	lsl.w	#2,d1
	lea	T_Handles(a5),a0
	add.w	d1,a0
	move.l	(a0),d1
	rts

;	OPEN: ouvre le fichier  # Handle D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F_OpenOld
	move.l	Name1(a5),d1
F_OpenOldD1
	move.l	#1005,d2
	bra.s	F_Open
F_OpenNew
	move.l	Name1(a5),d1
F_OpenNewD1
	move.l	#1006,d2
F_Open	movem.l	d3/a6,-(sp)
	move.l	d0,d3
	move.l	DosBase(a5),a6
	jsr	_LVOOpen(a6)
	move.l	d3,d1
	bsr	F_Handle
	IFNE	Debug
	tst.l	(a0)
	beq.s	.ok
	illegal
.ok
	ENDC
	move.l	d0,(a0)
	movem.l	(sp)+,d3/a6
	rts
;	CLOSE fichier D1
; ~~~~~~~~~~~~~~~~~~~~~~
F_Close
	movem.l	d0-d1/a0-a1/a6,-(sp)
	bsr	F_Handle
	beq.s	.Skip
	clr.l	(a0)
	move.l	DosBase(a5),a6
	jsr	_LVOClose(a6)
.Skip	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

;	CLOSE TOUS les fichiers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F_CloseAll
	moveq	#M_Fichiers-1,d1
.Loop	bsr	F_Close
	dbra	d1,.Loop
	rts

;	READ fichier D1, D3 octets dans D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F_Read	movem.l	d1/a0-a1/a6,-(sp)
	bsr	F_Handle
	move.l	DosBase(a5),a6
	jsr	_LVORead(a6)
	movem.l	(sp)+,d1/a0-a1/a6
	cmp.l	d0,d3
	rts

;	WRITE fichier D1, D3 octets de D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F_Write	movem.l	d1/a0-a1/a6,-(sp)
	bsr	F_Handle
	move.l	DosBase(a5),a6
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,d1/a0-a1/a6
	cmp.l	d0,d3
	rts

;	SEEK fichier D1, D3 mode D2 deplacement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
F_Seek	movem.l	d1/a0-a1/a6,-(sp)
	bsr	F_Handle
	move.l	DosBase(a5),a6
	jsr	_LVOSeek(a6)
	movem.l	(sp)+,d1/a0-a1/a6
	rts

;	LOF fichier D1
; ~~~~~~~~~~~~~~~~~~~~
F_Lof	bsr	F_Handle
	movem.l	d1/a0-a1/a6,-(sp)
	moveq	#0,d2			* Seek --> fin
	moveq	#1,d3
	move.l	DosBase(a5),a6
	jsr	_LVOSeek(a6)
	move.l	(sp),d1
	move.l	d0,d2			* Seek --> debut!
	moveq	#-1,d3
	jsr	_LVOSeek(a6)
	movem.l	(sp)+,d1/a0-a1/a6
	rts

;---------------------------------------------------------------------
; 	SORTIE compilation
;---------------------------------------------------------------------

; 	Va a la position D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Go_Position
	move.w	d0,New_Position(a5)
;	Actualisation position compilateur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Actualise
	tst.b	Flag_AMOS(a5)
	bne.s	.Cont
; Test du control-c sous CLI
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	rts
; Test du Control-C sous AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Cont	move.l	AMOS_Dz(a5),a0
	move.w	T_Actualise(a0),d0
	clr.w	T_Actualise(a0)
	bclr	#BitControl,d0
	bne	Err_ControlC
	tst.b	Flag_AMOS(a5)
	bmi.s	.Retour
	rts
; Retour au basic ?
; ~~~~~~~~~~~~~~~~~
.Retour	move.w	New_Position(a5),d0		P (sur 100)
	mulu	Total_Position(a5),d0		* Total
	divu	#100,d0				/ 100
	cmp.w	Total_Position(a5),d0
	ble.s	.Inf
	move.w	Total_Position(a5),d0
.Inf	cmp.w	Old_Position(a5),d0
	bne.s	.Back
	rts
.Back	and.l	#$0000FFFF,d0
	move.w	d0,Old_Position(a5)
	move.l	d0,d1
	bra	AMOS_Back

;	Set pourcentage
; ~~~~~~~~~~~~~~~~~~~~~
;	D0=	Position de debut
;	D1=	Position finale
;	D2= 	Nombre de pas estimes
Set_Pour
	move.w	d1,Pour_Maximum(a5)
	movem.l	d0-d2,-(sp)
	bsr	Go_Position		Va a la position demandee
	movem.l	(sp)+,d0-d2
	sub.l	d0,d1			Nombre de pas a faire
	move.w	d1,Pour_Largeur(a5)
	move.w	d2,Pour_NPas(a5)
	cmp.w	d1,d2
	bcs.s	.Part
; Cas general: nombre de pas > largeur
	clr.w	Pour_Compteur(a5)
	clr.b	Flag_Pour(a5)
	rts
; Cas particulier: nombre de pas < largeur
.Part	tst.w	d2
	bne.s	.NoNul
	moveq	#1,d2
.NoNul	divu	d2,d1			Largeur / Nb pas
	move.w	d1,Pour_Compteur(a5)
	move.b	#1,Flag_Pour(a5)	Le flag!
	rts
;	Va a la fin du pourcentage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
End_Pour
	move.w	Pour_Maximum(a5),d0
	bra	Go_Position
; 	Un pas de pourcentage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Aff_Pour
	tst.b	Flag_AMOS(a5)
	bmi.s	.Pour
	rts
.Pour	move.l	d0,-(sp)
	tst.b	Flag_Pour(a5)
	bne.s	.Part
; Cas general
	move.w	Pour_Largeur(a5),d0
	sub.w	d0,Pour_Compteur(a5)
	bcc.s	.Out
	move.w	Pour_NPas(a5),d0
	add.w	d0,Pour_Compteur(a5)
	move.w	New_Position(a5),d0
	addq.w	#1,d0
	bra.s	.Envoi
; Cas particulier
.Part	move.w	New_Position(a5),d0
	add.w	Pour_Compteur(a5),d0
; Envoie la position D0 au basic
.Envoi	cmp.w	Pour_Maximum(a5),d0
	ble.s	.Inf
	move.w	Pour_Maximum(a5),d0
.Inf	move.w	d0,New_Position(a5)
	bsr	Actualise
.Out	move.l	(sp)+,d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EXPLORATION LIGNE DE COMMANDE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CommandLine
; - - - - - - - - - - - - -
	movem.l	a2-a3/d2-d3,-(sp)
	move.l	sp,a3
; Trouve le debut / pas de command line?
.Loop1	move.b	(a0)+,d0
	beq.s	CL_Ok
	cmp.b	#32,d0
	ble.s	.Loop1
	subq.l	#1,a0
; Nettoie les flags de token
	lea	CL_Tokens(pc),a1
.Clean	tst.b	(a1)+
	bne.s	.Clean
	clr.b	(a1)+
	move.w	a1,d0
	and.w	#$0001,d0
	lea	4(a1,d0.w),a1
	tst.b	(a1)
	bne.s	.Clean
; Premier= nom du source
	bsr	CL_GetToken		Veut un token
	bmi	CL_Syntax
	beq.s	.Srce			Pas de token=> nom source
	cmp.w	#1,d0			Veut FROM!
	bne	CL_Syntax
.Srce	bsr	CL_Source		Recupere le nom de fichier
; Prend les parametres
.Loop	bsr	CL_GetToken
	bmi.s	CL_Ok
	beq	CL_Syntax
	cmp.w	#1,d0			Ne veut plus FROM
	beq	CL_Syntax
	jsr	(a1)
	bra.s	.Loop
; Termine!
CL_Ok	moveq	#0,d0
	bra.s	CL_Out
; Erreur de syntaxe
CL_Syntax
	moveq	#1,d0
; Sortie generale
CL_Out	move.l	a3,sp
	movem.l	(sp)+,a2-a3/d2-d3
	rts

; 	Explore la liste des tokens
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CL_GetToken
	lea	-256(sp),sp
	move.l	sp,a1
; Recopie le token dans la pile
	moveq	#-1,d2
.Loop1	move.b	(a0),d0
	beq.s	.Out
	addq.l	#1,a0
	cmp.b	#32,d0
	ble.s	.Loop1
	subq.l	#1,a0
	move.l	a0,d3
.Loop2	move.b	(a0)+,d0
	bsr	D0Maj
	move.b	d0,(a1)+
	clr.b	(a1)
	cmp.b	#"=",d0
	beq.s	.Egal
	cmp.b	#" ",d0
	bhi.s	.Loop2
	subq.l	#1,a0
	clr.b	-1(a1)
; Boucle d'exploration
.Egal	lea	CL_Tokens(pc),a2
	moveq	#0,d2
.RFind	move.l	sp,a1
	addq.w	#1,d2
.Find	move.b	(a1)+,d0
	move.b	(a2)+,d1
	cmp.b	d0,d1
	bne.s	.Next
	tst.b	d1
	bne.s	.Find
; Token trouve!
	tst.b	(a2)
	bne.s	CL_Syntax
	addq.b	#1,(a2)+
	move.l	a2,d0
	btst	#0,d0
	beq.s	.Pair
	addq.l	#1,d0
.Pair	move.l	d0,a1
	bra.s	.Out
; Pointe le token suivant
.Next	tst.b	(a2)+
	bne.s	.Next
	tst.b	(a2)+
	move.w	a2,d0
	and.w	#$0001,d0
	lea	4(a2,d0.w),a2
	tst.b	(a2)
	bne.s	.RFind
	moveq	#0,d2			Pas de token
	move.l	d3,a0			Reste sur le debut du mot!
; Sortie generale
.Out	lea	256(sp),sp
	move.l	d2,d0
	rts

;	Recupere un nom
; ~~~~~~~~~~~~~~~~~~~~~
CL_Nom	cmp.b	#" ",(a0)+		Saute les espaces
	beq.s	CL_Nom
	subq.l	#1,a0			Reste sur premiere lettre
	move.l	a1,d2
	move.b	#" ",d1
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
	cmp.l	a1,d2
	beq	CL_Syntax
	rts

; 	Recupere un digit
; ~~~~~~~~~~~~~~~~~~~~~~~
CL_Digit
	moveq	#0,d0
	move.b	(a0)+,d0
	beq	CL_Syntax
	sub.b	#"0",d0
	bcs	CL_Syntax
	rts

; 	Table des tokens command line / sauts aux routines de traitement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CL_Tokens
	dc.b	"FROM",0,0
	bra	CL_Source
	dc.b	"TO",0,0
	bra	CL_Object
	dc.b	"TYPE=",0,0
	bra	CL_Type
	dc.b	"TOKEN",0,0
	bra	CL_Token
	dc.b	"ERR",0,0
	bra	CL_Errors
	dc.b	"ERRORS",0,0
	bra	CL_Errors
	dc.b	"NOERR",0,0
	bra	CL_NoErrors
	dc.b	"NOERRORS",0,0
	bra	CL_NoErrors
	dc.b	"LONG",0,0
	bra	CL_Long
	dc.b	"NOLONG",0,0
	bra	CL_NoLong
	dc.b	"DEF",0,0
	bra	CL_Default
	dc.b	"DEFAULT",0,0
	bra	CL_Default
	dc.b	"NODEF",0,0
	bra	CL_NoDefault
	dc.b	"NODEFAULT",0,0
	bra	CL_NoDefault
	dc.b	"WB",0,0
	bra	CL_Wb
	dc.b	"NOWB",0,0
	bra	CL_NoWb
	dc.b	"QUIET",0,0
	bra	CL_Quiet
	dc.b	"TEMP=",0,0
	bra	CL_Temp
	dc.b	"LIBS=",0,0
	bra	CL_Libs
	dc.b	"CONFIG=",0,0
	bra	CL_Config
	dc.b	"DEBUG=",0,0
	bra	CL_Debug
	dc.b	"NUMBERS",0,0
	bra	CL_Numbers
	dc.b	"BIG",0,0
	bra	CL_Big
	dc.b	"INCLIB",0,0
	bra	CL_IncLib
	dc.b	"NOLIB",0,0
	bra	CL_NoLib
	dc.b	"INFOS",0,0
	bra	CL_Info
	dc.b	0
	even

; Routines pour chaque flag
; ~~~~~~~~~~~~~~~~~~~~~~~~~
CL_Source
	move.l	Path_Source(a5),a1
	bra	CL_Nom
CL_Object
	move.l	Path_Objet(a5),a1
	bra	CL_Nom
CL_Token
	move.b	#1,Flag_Tokeniser(a5)
	rts
CL_Errors
	move.b	#1,Flag_Errors(a5)
	rts
CL_NoErrors
	clr.b	Flag_Errors(a5)
	rts
CL_Type
	bsr	CL_Digit
	cmp.l	#3,d0
	bhi	CL_Syntax
	move.b	d0,Flag_Type(a5)
	rts
CL_Debug
	bsr	CL_Digit
	move.b	d0,Flag_Debug(a5)
	beq.s	.Skip
	cmp.b	#2,d0
	bne.s	.Skip
	move.b	#1,Flag_OutNumbers(a5)
.Skip	rts
CL_Numbers
	move.b	#1,Flag_Numbers(a5)
	rts
CL_Long
	move.b	#1,Flag_Long(a5)
	rts
CL_NoLong
	clr.b	Flag_Long(a5)
	rts
CL_Default
	move.b	#1,Flag_Default(a5)
	rts
CL_NoDefault
	clr.b	Flag_Default(a5)
	rts
CL_Wb
	move.b	#1,Flag_WB(a5)
	rts
CL_NoWb
	clr.b	Flag_WB(a5)
	rts
CL_Quiet
	move.b	#1,Flag_Quiet(a5)
	rts
CL_Temp
	move.l	Path_Temporaire(a5),a1
	bra	CL_Nom
CL_Libs
	lea	Sys_Pathname(a5),a1
	bra	CL_Nom
CL_Config
	move.l	Path_Config(a5),a1
	bra	CL_Nom
CL_Big
	move.b	#1,Flag_Big(a5)
	rts
CL_Info	move.b	#1,Flag_Infos(a5)
	rts
CL_IncLib
	move.b	#1,Flag_AMOSLib(a5)
	rts
CL_NoLib
	clr.b	Flag_AMOSLib(a5)
	rts

;	Routine transfert en majuscule
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D0Maj	cmp.b	#"a",d0
	bcs.s	.Skip
	cmp.b	#"z",d0
	bhi.s	.Skip
	sub.b	#$20,d0
.Skip	rts


;---------------------------------------------------------------------
BugCode		btst	#6,CiaAprA
		bne.s	BugCode1
		illegal
BugCode1	dc.w	$4321
DbCode		move.w	#0,Cmp_Ligne(a5)

* Endproc / Param
CdEProE		move.l	d3,ParamE(a5)
		dc.w	$4321
CdEProF		move.l	d3,ParamF(a5)
		dc.w	$4321
CdEProS		move.l	d3,ParamC(a5)
		dc.w	$4321
CdEProD		move.l	d3,ParamF(a5)
		move.l	d4,ParamF2(a5)
		dc.w	$4321

Cnegd3		neg.l	d3
Cbchg7d3	bchg	#7,d3
Cbchg31d3	bchg	#31,d3
Cmvd3ma3	move.l	d3,-(a3)
Cmvima3		move.l	#0,-(a3)
Cmvmd3d4ma3	movem.l	d3/d4,-(a3)
Cmv2a6ma3	move.l	2(a6),-(a3)
Cmv2a0ma3	move.l	2(a0),-(a3)
Cmv0a0ma3	move.l	(a0),-(a3)
Cmv2a6d3	move.l	2(a6),d3
Cmv2a0d3	move.l	2(a0),d3
Cmv0a0d3	move.l	(a0),d3
Cmvid3		move.l	#0,d3
Cmvid4		move.l	#0,d4
Cadda3pd3	add.l	(a3)+,d3
Csuba3pd3	sub.l	(a3)+,d3
Cadd2a6d3	add.l	2(a6),d3
Cadd2a0d3	add.l	2(a0),d3
Csub2a6d3	sub.l	2(a6),d3
Csub2a0d3	sub.l	2(a0),d3
Cmva3pd3	move.l	(a3)+,d3
Caddqd3		addq.l	#1,d3
Caddid3		add.l	#0,d3
Csubid3		sub.l	#0,d3
Csubqd3		subq.l	#1,d3
Clsld0d3	lsl.l	d0,d3
Casrd0d3	asr.l	d0,d3
Cmva3pd0	move.l	(a3)+,d0
Cmvd32a6	move.l	d3,2(a6)
Cmvd32a0	move.l	d3,2(a0)
Cmva3p0a0	move.l	(a3)+,(a0)
Cmvd42a0	move.l	d4,2(a0)
Cmvd42a6	move.l	d4,2(a6)
Cmva3pa0p	move.l	(a3)+,(a0)+
Cmva3pa0	move.l	(a3)+,(a0)
Cmv2a0d4	move.l	2(a0),d4
Cmv2a6d4	move.l	2(a6),d4
Cmva0pd3	move.l	(a0)+,d3
Cmva0d4		move.l	(a0),d4
Cmvd7a0		move.l	d7,a0

Cjsr		jsr	$fffff0
Cbsr		bsr	Cbsr
Cjsr2a4		jsr	2(a4)
Cjmp2a4		jmp	2(a4)
Cjmp		jmp	$fffff0
Cjmpa0		jmp	(a0)
Cjsra0		jsr	(a0)
Cjsr2a0		jsr	2(a0)

Cbra		bra	Cbra
Cble		ble	Cble
Cbge		bge	Cbge
Cblts		blt.s	*+8
Cbgts		bgt.s	*+8
Cbeq		beq	Cbeq
Cbeq8		beq.s	*+8
Cbeq10		beq.s	*+10
Cbeq12		beq.s	*+12
Cbne		bne	Cbne
Cbne8		bne.s	*+8
Cbne10		bne.s	*+10
Cbne12		bne.s	*+12
Clea2a3a3	lea	2(a3),a3
Clea2a0a0	lea	2(a0),a0
Clea2a6a0	lea	2(a6),a0
Cleapca4	lea	Cleapca4(pc),a4
Cleapca0	lea	Cjsr(pc),a0
Cleapca1	lea	Cjsr(pc),a1
Cleapca2	lea	Cjsr(pc),a2
Cleaa0		lea	$fffff0,a0
Cleaa1		lea	$fffff0,a1
Cleaa2		lea	$fffff0,a2
Cleaa4		lea	$fffff0,a4
Cmva3msp	move.l	a3,-(sp)
Cmvpspa3	move.l	(sp)+,a3
Cmva0ma3	move.l	a0,-(a3)
Cmva0d3		move.l	a0,d3
Cmvi2a5		move.l	#-1,2(a5)
Cmvwima3	move.w	#0,-(a3)
Cmvid1		move.l	#0,d1
Cmvid2		move.l	#0,d2
Cmvid5		move.l	#0,d5
Cmvid6		move.l	#0,d6
Cmvwid0		move.w	#0,d0
Cmvwid1		move.w	#0,d1
Cmvwid5		move.w	#0,d5
Cmvid0		move.l	#0,d0
Cmvqd0		moveq	#0,d0
Cmvqd1		moveq	#0,d1
Cmvqd2		moveq	#0,d2
Cmvqd3		moveq	#0,d3
Cmvqd4		moveq	#0,d4
Cmvqd5		moveq	#0,d5
Cmvqd6		moveq	#0,d6
Cmvqd7		moveq	#0,d7
Cmva6d7		move.l	a6,d7
Ctsta3p		tst.l	(a3)+
Ctstd3		tst.l	d3
Cillegal	illegal
Crts		rts
Cclrma3		clr.l	-(a3)
Cnop		nop
Cretint		moveq	#0,d2
		rts
Cretfloat	moveq	#1,d2
		rts
Cretstring	moveq	#2,d2
		rts

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
DZ		dc.l	0
Pile_AMOS	dc.l	0
Pile_Base	dc.l	0
Pile_APCmp	dc.l	0

Nom_Dos		dc.b	"dos.library",0
Nom_Graphic	dc.b	"graphics.library",0
Nom_IconLib	dc.b	"icon.library",0
FloatName	dc.b	"mathffp.library",0
DFloatName	dc.b 	"mathieeedoubbas.library",0

Def_Config1	dc.b	"s/"
Def_Config0	dc.b	"AMOSPro_Compiler_Config",0
Def_Config2	dc.b	"s:AMOSPro_Compiler_Config",0
Nom_AMOSLib	dc.b	"Libs:AMOS.Library",0

Head_AMOS	dc.b	"AMOS Basic "
Head_AMOSPro	dc.b	"AMOS Pro101v",0,0,0,0
Suf_C.AMOS	dc.b	"_C.AMOS",0
Suf_Prg		dc.b	".Prg"
Suf_Nul		dc.b	0
Point_AMOS	dc.b	".AMOS",0

;		Header programme compile
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		even
Prog_Header	dc.b	"AMOS Pro111v",0,0,0,0
		dc.l	0
Prog_Finish	dc.b	"AmBs",0,0

;		Message d'urgence (avant chargement config)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mes_Urgence	dc.b	1,"Could not load Compiler_Configuration file.",10,0
		dc.b	2,"Out of memory (before loading Compiler Configuration file).",10,0

		even
Nom_Spr		dc.b	"Sprites "
Nom_Ico		dc.b	"Icons   "
		even
Mes_Return	dc.b	13,10,0

Err_Pointer0	dc.b	0
		dc.b	$9B,"3",$6D,0
Err_Pointer1	dc.b	">>> ",0
		dc.b	$9B,"33",$6D,">>> ",$9B,"39",$6D,0
Err_Pointer2	dc.b	0
		dc.b	$9B,"0",$6D,0

Debug_LObjet	dc.b	"* Program:          ",0
Debug_LLibrary	dc.b	"* Relative library: ",0
Debug_ELibrary	dc.b	"* External library: ",0
Mes_Buffers:	dc.b	"* Relocation:       ",0
		dc.b	"* Local flags:      ",0
		dc.b	"* Global flags:     ",0
		dc.b	"* Strings:          ",0
		dc.b 	"* Leas:             ",0
		dc.b	"* Labels:           ",0
		dc.b	"* Loops:            ",0
		dc.b	"* Script:           ",0
		dc.b	"* Instructions 1:   ",0
		dc.b	"* Instructions 2:   ",0
		dc.b	"* Relative Reloc:   ",0
		dc.b	0
Mes_Bufs1	dc.b	" not reserved",0
Mes_Bufs2	dc.b	" / ",0
Mes_Bufs3	dc.b	" - Free: ",0
Debug_LibFile	dc.b	"Ram:Linked_Numbers.Asc",0
Debug_Jmp	dc.b	"(Jump)",0
Debug_SDisc	dc.b	"(Source on disk)",0
Debug_ODisc	dc.b	"(Object on disk)",0
Debug_Float	dc.b	"* Float in the program",13,10,0
		even

;		Definition des donnees (sur la configuration de l'editeur)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RSSET	Ed_Banks

C_Pile		rs.l	1
Pour_Compteur	rs.w	1
Pour_Maximum	rs.w	1
Pour_NPas	rs.w	1
Pour_Largeur	rs.w	1
New_Position	rs.w	1
Old_Position	rs.w	1
Total_Position	rs.w	1

Flag_Source	rs.b	1
Flag_Objet	rs.b	1

Flag_AMOS	rs.b	1
Flag_Errors	rs.b	1

Flag_Default	rs.b	1
Flag_Type	rs.b	1

Flag_WB		rs.b	1
Flag_Quiet	rs.b	1

Flag_NoTests	rs.b	1
Flag_Flash	rs.b	1

Flag_Big	rs.b	1
Flag_Teste	rs.b	1

Flag_AsciiForce	rs.b	1
Flag_Tokeniser	rs.b	1

Flag_Libraries	rs.b	1
Flag_AMOSLib	rs.b	1

Flag_Pour	rs.b	1
Flag_Debug	rs.b	1

Flag_Numbers	rs.b	1
Flag_OutNumbers	rs.b	1

Flag_Accessory	rs.b	1
Flag_Infos	rs.b	1

PrintJSR	rs.l	1
C_Icon		rs.l	1
AMOS_Dz		rs.l	1
A_Config	rs.l	1

;		Position dans l'objet
Lib_OldRel	rs.l	1
A_LibRel	rs.l	1
OldRel		rs.l	1
A_Chaines	rs.l	1

DebRel		rs.l	1
A_Bcles		rs.l	1
A_Lea		rs.l	1
A_Proc		rs.l	1
N_Bcles		rs.w	1
N_Proc		rs.w	1
Flag_Const	rs.w	1
Cpt_Labels	rs.w	1
OCpt_Labels	rs.w	1
Flag_Procs	rs.w	1
OFlag_Procs	rs.w	1
Flag_Long	rs.w	1
Flag_Val	rs.w	1
AdAdress	rs.l	1
AdAdAdress	rs.l	1
F_Proc		rs.l	1
A_FlagVarL	rs.l	1
L_Buf		rs.l	1
L_Stack		rs.l	1
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
AA_Header	rs.l	1
AA_A4		rs.l	1
Mem_Maximum	rs.l	1
Mem_Current	rs.l	1
L_Reloc		rs.w	1
M_ForNext	rs.w	1
MM_ForNext	rs.w	1
NbInstr		rs.w	1
IconAMOS	rs.w	1
Type_Voulu	rs.w	1
Type_Eu		rs.w	1
A_Script	rs.l	1
EvaCompteur	rs.w	1
Last_Token	rs.w	1
A_Instructions	rs.l	1
MathType	rs.w	1
Ad_JsrInits	rs.l	1
Ad_Inits	rs.l	1
Ad_HeaderFlags	rs.l	1
Ad_Rts		rs.l	1
N_Hunks		rs.w	1
Lib_NInternes	rs.w	1
Lib_NExternes	rs.w	1
Db_Next		rs.l	1
Db_Prev		rs.l	1
B_Instructions	rs.l	1
Proc_Start	rs.l	6
Stop_Line	rs.w	1
Cur_Line	rs.w	1
Old_Line	rs.w	1
End_Source	rs.l	1
Info_LObjet	rs.l	1
Info_LLibrary	rs.l	1
Info_ELibrary	rs.l	1

* Donnees sur les routines speciales
Lib_SizeInterne	rs.w	1
Lib_DExternes	rs.w	1
Lib_FExternes	rs.w	1
Lib_DFloat	rs.w	1
Lib_FFloat	rs.w	1
Lib_DType	rs.w	1
Lib_FType	rs.w	1
Lib_Debut	rs.l	1
Lib_FinInternes	rs.l	1

* Source
L_Source	rs.l	1
DebBso		rs.l	1
FinBso		rs.l	1
MaxBso		rs.l	1
BordBso		rs.l	1
TopSou		rs.l	1

* Objet
L_Objet		rs.l	1
DebBob		rs.l	1
FinBob		rs.l	1
TopOb		rs.l	1
BordBob		rs.l	1
BB_Objet_Base	rs.l	1
BB_Objet	rs.l	1

* Banques
N_Banks		rs.w	1

* Disque
T_Handles	rs.l	M_Fichiers
P_Clib		rs.l	1
T_Clib		rs.l	1
H_Clib		rs.w	1
R_Clib		rs.w	1
V_Clib		rs.w	1

;		Buffers avec auto-liberation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D_Buffers	equ	__RS

B_Reloc		rs.l	1		0
B_FlagVarL	rs.l	1		1
B_FlagVarG	rs.l	1		2
B_Chaines	rs.l	1		3
B_Lea		rs.l	1		4
B_Labels	rs.l	1		5
B_Bcles		rs.l	1		6
B_Script	rs.l	1		7
B_Instructions1	rs.l	1		8
B_Instructions2	rs.l	1		9
B_LibRel	rs.l	1		10

B_Work		rs.l	1		0
B_Config	rs.l	1		4
B_IntConfig	rs.l	1		8
B_Noms		rs.l	1		12
B_Objet		rs.l	1		18
B_DiskIn	rs.l	1		16
B_Stock		rs.l	1		17
B_Source	rs.l	1		18
Path_Source	rs.l	1		19
Path_Objet	rs.l	1		20
Path_Config	rs.l	1		21
Path_Temporaire	rs.l	1		22
Path_ToDelete	rs.l	1		23
B_RToken	rs.l	1		24
B_RTest		rs.l	1		25
B_EditMessages1	rs.l	1		26
B_EditMessages2	rs.l	1		27
B_Temporaire	rs.l	1		29
B_Hunks		rs.l	1		30
B_HeadAMOS	rs.l	1		34
F_Buffers	equ	__RS

LDZ		equ	__RS

; Securite sur la longueur
		IFNE	LDZ>DataLong
		Fail
		ENDC

;		Routines internes en cas de chargement externe
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Add_Routines
.R		dc.w	L_RamFast
		dc.l	RamFast-.R
		dc.w	L_RamFast2
		dc.l	RamFast-.R
		dc.w	L_RamChip
		dc.l	RamFast-.R
		dc.w	L_RamChip2
		dc.l	RamFast-.R
		dc.w	L_RamFree
		dc.l	RamFree-.R
		dc.w	L_ResTempBuffer
		dc.l	ResTempBuffer-.R
		dc.w	L_Sys_GetMessage
		dc.l	Get_IntConfigMessage-.R
		dc.w	L_Sys_AddPath
		dc.l	AddPath-.R
		dc.w	0

;		Routines � charger pour la tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Routines_Token	dc.w	L_Tokenisation
		dc.w	L_CValRout
		dc.w	L_AscToFloat
		dc.w	L_FloatToAsc
		dc.w	L_AscToDouble
		dc.w	L_DoubleToAsc
		dc.w	0

;		Routines � charger pour le test
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Routines_Test	dc.w	L_Testing
		dc.w	L_CValRout
		dc.w	L_InstrFind
		dc.w	L_AscToFloat
		dc.w	L_FloatToAsc
		dc.w	L_AscToDouble
		dc.w	L_DoubleToAsc
		dc.w	L_LongToDec
		dc.w	L_LongToAsc
		dc.w	L_LongToHex
		dc.w	L_LongToBin
		dc.w	0
