;_____________________________________________________________________________
;.............................................................................
;...................................................................2222222...
;................................................................22222222220..
;...................................................222........222222.....222.
;..............................................2202222222222..22000...........
;..................................22000.....20222222222200000200002..........
;.................................2002202...2222200222.220000000200000000022..
;....................220002......22222200..2200002.......2200000...20000000000
;....................22222202....2220000022200000..........200002........20000
;.....200000.........2222200000222200220000000002..........200002........20000
;.....00222202........2220022000000002200002000002........2000002000020000000.
;....2222200000.......220002200000002.2000000000000222222000000..2000000002...
;....220000200002......20000..200002..220000200000000000000002.......22.......
;...2220002.2200002....220002...22.....200002..0000000000002..................
;...220000..222000002...20000..........200000......2222.......................
;...000000000000000000..200000..........00002.................................
;..220000000022020000002.200002.........22......._____________________________
;..0000002........2000000220022.................|
;.200000............2002........................| MONITOR
;.200002........................................|
;220002.........................................|_____________________________
;_____________________________________________________________________________
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
;
;_____________________________________________________________________________
		Include	"+Debug.s"
		IFEQ	Debug=2
		Include "+AMOS_Includes.s"
		Include "+Version.s"
		ENDC
;_____________________________________________________________________________


; Branchements internes au moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MDebut		dc.l	In_Editor-MDebut	0- Depuis l'editeur
		dc.l	In_Program-MDebut	1- Depuis le programme
		dc.l	MonitorChr-MDebut	2- Entree du moniteur
		dc.l	0

; Equates internes au moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_MinTy	equ	8
Ttt_MaxTy	equ	16

* Num�ro des ecrans
Tt_Ecran1	equ	EcEdit
Tt_Ecran2	equ	EcFonc
E1_Sx		equ	640
E1_Sy		equ	116
E2_Sx		equ	640
E2_MinY		equ	128

; Position de base des boutons
BtX		equ	384
BtY		equ	35
RedX		equ	16
RedY		equ	9
RedTX		equ	320
RedTY		equ	100
BoutInfos	equ	12
NBoutons	equ	16

Tjsr	MACRO
	jsr	\1
	move.l	Mon_Base(a5),a4
	ENDM

;					------------------------------------
;--------------------------------------    Zone de donnees sp�cifique TUTOR
;					------------------------------------
Tt_ChannelN	equ	$BBCCDDEE
Inf_Size	equ	88*100		; 100 lignes max
		RsReset
Inf_Sly		rs.w	1
Inf_Slp1	rs.w	1
Inf_Slp2	rs.w	1
Inf_Pos		rs.l	1
Inf_YPos	rs.w	1
Inf_AlertOn	rs.w	1
Inf_NLigne	rs.w	1
Inf_Buf		rs.l	1

Tt_Dialogs	rs.l	1
Tt_CurBanks	rs.l	1
Tt_CurDialogs	rs.l	1
Tt_Channel	rs.l	1
Tt_Variables	rs.l	1
Tt_Resource	rs.l	1
Tt_Program	rs.l	1
Tt_JError	rs.l	1
Tt_PrgHelp	rs.l	1
Tt_Init		rs.w	1
Tt_View		rs.w	1
Tt_ViewTX	rs.w	1
Tt_ViewTY	rs.w	1
Tt_ViewNP	rs.w	1
Tt_ViewAd	rs.l	1
Tt_Active	rs.w	1
Tt_Accel	rs.w	1
Tt_Ecran	rs.w	1
Tt_YMark	rs.w	1
Tt_X1Mark	rs.w	1
Tt_X2Mark	rs.w	1
Tt_YInfo	rs.w	1
Tt_X1Info	rs.w	1
Tt_X2Info	rs.w	1
Tt_XNext	rs.w	1
Tt_YNext	rs.w	1
Tt_PLine	rs.l	1
Tt_ALine	rs.l	1
Tt_EvPile	rs.l	1
Tt_EvDebut	rs.l	1
Tt_InfOn	rs.w	1
Tt_DCurLine	rs.l	1
Tt_Run		rs.w	1
Tt_MapAdr	rs.l	1
Tt_MapLong	rs.l	1
Tt_MKey		rs.w	1
Tt_MFlag	rs.w	1
Tt_Adress	rs.l	1
Tt_Locked	rs.w	1
Tt_CurLigne	rs.l	1
Tt_DebProc	rs.l	1
Tt_NotHere	rs.b	1
		rs.b	1
Tt_BufT		rs.l	1
Tt_Ligne	rs.l	1

Ttt_BufE	rs.l	1
Ttt_XPos	rs.w	1
Ttt_YPos	rs.w	1
Ttt_Sy		rs.w	1
Ttt_Tlh		rs.w	1
Ttt_Mode	rs.w	1
Ttt_Tlb		rs.w	1
ttsl_hp1	rs.w	1
ttsl_hp2	rs.w	1
ttsl_vp1	rs.w	1
ttsl_vp2	rs.w	1

Step_Data	rs.l	10
Step_Break	rs.l	1
Step_Stop	rs.w	1
Step_Mess	rs.l	1
Step_Mode	rs.w	1

Hlp_Map		rs.l	1
Hlp_LMap	rs.l	1
Hlp_Texte	rs.l	1
Hlp_LTexte	rs.l	1

ViewScrols	rs.w	4*8
Tt_DzLong	equ	__RS



; ___________________________________________________________________
;
;	BOUCLE PRINCIPALE
; ___________________________________________________________________
;

;	Entree du moniteur par l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In_Editor
	move.l	Edt_Runned(a5),a3	Le programme courant
	move.l	Edt_Prg(a3),a3		Structure programme
	bsr	Tt_ColdStart
	bne	.OMem
	clr.w	Tt_Run(a4)
	bra.s	Tt_Tests
.OMem	rts

; 	Entree du moniteur par le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In_Program
	movem.l	a3-a6/d6/d7,-(sp)
	move.l	Mon_Base(a5),d0
	bne.s	.DejaLa
	move.l	Prg_Runned(a5),a3
	bsr	Tt_ColdStart
	bne.s	.Out
	move.w	#1,Tt_Init(a4)
	move.w	#1,Tt_Run(a4)
	lea	Tt_Error(pc),a0		Erreur>>> se branche au moniteur
	move.l	a0,Prg_JError(a5)
.Ok	moveq	#0,d0
.Out	movem.l	(sp)+,a3-a6/d6/d7
	rts
.DejaLa	move.l	d0,a0
	addq.w	#1,Step_Stop(a0)
	bra.s	.Ok

;	Boucle de tests du moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Tests
	move.l	Mon_Base(a5),a4
	clr.w	Tt_Active(a4)
Tt_ReLoop
	bsr	Tt_TtBanks
	move.l	Tt_Program(a4),a3
	bsr	View_Act
	clr.w	Tt_Accel(a4)
	tst.w	Tt_Active(a4)
	beq.s	Tt_Loop
.loop	bsr	Tt_Multi
	bsr	Tt_MBout
	btst	#0,d1
	beq.s	.Out
	SyCall	GetZone
	cmp.w	#Tt_Ecran1,d1
	bne.s	.Out
	swap	d1
	cmp.w	Tt_Active(a4),d1
	beq.s	.loop
.Out	move.w	Tt_Active(a4),d0
	clr.w	Tt_Active(a4)
	moveq	#0,d1
	bsr	ABouton
Tt_Loop
; Attente multitache
	bsr	Tt_Multi
; Gestion des zones actives!
	bsr	Tt_MBout
	move.w	d1,Tt_MKey(a4)
	and.w	#$03,d1			Bouton de gauche--> normal
	beq	Tt_ReLoop

	bsr	Ttt_InfAct
	bsr	Ttt_AlertDel		Enleve les alertes
	bsr	View_Act

	SyCall	GetZone
	cmp.w	#Tt_Ecran2,d1
	beq	Ttt_E2
	cmp.w	#Tt_Ecran1,d1
	bne	Tt_DBL
	swap 	d1
	tst.w	d1
	beq	Tt_DBL
	move.w	d1,d0
; Touches HELP/BREAK/EVAL?
	cmp.w	#14,d0
	bcc.s	.Skip
	cmp.w	Tt_Active(a4),d1
	beq.s	.Skip
; Active la touche
	tst.w	Tt_Active(a4)
	bne	Tt_ReLoop
	move.w	d1,Tt_Active(a4)
	moveq	#1,d1
	bsr	ABouton
; Appel des fonctions
.Skip	lsl.w	#2,d0
	lea	Tt_Bra-4(pc),a0
	jsr	0(a0,d0.w)
	bne	Tt_ReLoop
	bra	Tt_Loop

; 	Ecran de texte
; ~~~~~~~~~~~~~~~~~~~~
Ttt_E2	swap 	d1
	subq.w	#1,d1
	bmi	Tt_ReLoop
	move.w	d1,-(sp)
	bsr	Ttt_TttAct
	move.w	(sp)+,d1
	lsl.w	#2,d1
	lea	Ttt_Bra(pc),a0
	jsr	0(a0,d1.w)
	bra	Tt_ReLoop

; 	Une zone DBL?
; ~~~~~~~~~~~~~~~~~~~
Tt_DBL	moveq	#1,d0
	JJsr	L_Dia_AutoTest2
	move.l	#Tt_ChannelN,d0
	JJsr	L_Dia_GetReturn
	lsl.w	#2,d1
	beq	Tt_ReLoop
	move.w	d1,-(sp)
	bsr	Ttt_TttAct
	move.w	(sp)+,d1
	lea	J_DBL(pc),a0
	jsr	-4(a0,d1.w)
	bra	Tt_ReLoop

;	Table des sauts
; ~~~~~~~~~~~~~~~~~~~~~
Tt_Bra
	bra	Tt_Rien			1:  STOP, teste separement
	bra	Tt_Step0		2:  mode pas a pas
	bra	Tt_Step1		3:  mode semi-rapide
	bra	Tt_Step2		4:  mode rapide
	bra	Tt_Step3		5:  mode ultra-rapide
	bra	Tt_Up			6:
	bra	Tt_Down			7:
	bra	Tt_Left			8:
	bra	Tt_Right		9:
	bra	Tt_CEc			10: Change ecran
	bra	Tt_Initialise		11: Init
	bra	Tt_Quit			12: Quit
	bra	Tt_See			13: Voir l'affichage
	bra	Tt_SHelp		14: Set Help
	bra	Tt_SBreak		15: Set break
	bra	Tt_SEval		16: Set evalue
Tt_Rien	rts

Ttt_Bra	bra	Ttt_ListClic		1 : Zone de listing
	bra	Ttt_Separ		2 : Zone de separation
	bra	Inf_Clic		3 : Zone d'information
J_DBL	bra	Ttt_Slhclic		1 : Slider horizontal
	bra	Ttt_Slvclic		2 : Slider vertical
	bra	Inf_Sliclic		3 : Slider infos
	bra	Ttt_CText		4 : Bouton de centrage

; ___________________________________________________________________
;
;	INITIALISATION GENERALE
; ___________________________________________________________________
;
Tt_ColdStart
; Reservation de la zone de datas
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#Tt_DzLong,d0
	SyCall	MemFastClear
	beq	.Out
	move.l	a0,a4
	move.l	a0,Mon_Base(a5)
; Init de donnees
; ~~~~~~~~~~~~~~~
	move.l	a3,Tt_Program(a4)
	move.l	Cur_Banks(a5),Tt_CurBanks(a4)
	move.l	Cur_Dialogs(a5),Tt_CurDialogs(a4)
	move.w	#-1,Tt_Ecran(a4)
	move.w	#-1,Tt_View(a4)
	move.w	#-1,Tt_YMark(a4)
	move.w	#-1,Tt_YNext(a4)
	clr.b	Tt_NotHere(a4)
	move.w	Ed_Sy(a5),d0
	sub.w	#E1_Sy,d0
	tst.b	Ed_Inter(a5)
	beq.s	.S0
	sub.w	#E1_Sy,d0
.S0	and.w	#$FFF0,d0
	cmp.w	#E2_MinY,d0
	bcc.s	.Skip
	move.w	#E2_MinY,d0
.Skip	move.w	d0,Ttt_Sy(a4)
; Reservation des autres buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lsr.w	#3,d0			Buffer d'edition
	mulu	#256,d0
	SyCall	MemFastClear
	beq	.Out
	move.l	a0,Ttt_BufE(a4)
	move.l	#1024+512,d0		Buffer Tokenisation / Lignes
	SyCall	MemFastClear
	beq	.Out
	move.l	a0,Tt_BufT(a4)
	lea	512(a0),a0
	move.l	a0,Tt_Ligne(a4)
	move.l	#Inf_Size,d0		Buffer infos
	SyCall	MemFastClear
	beq	.Out
	move.l	a0,Inf_Buf(a4)
; Trouve l'adresse de la banque de resource
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Tt_TtBanks
	moveq	#16,d0
	JJsr	L_Bnk.GetAdr
	beq	.Out
	move.l	a0,Tt_Resource(a4)
; Ouvre l'�cran du haut
; ~~~~~~~~~~~~~~~~~~~~~
	moveq	#Tt_Ecran1,d0
	move.l	#E1_Sx,d1
	move.l	#E1_Sy,d2
	moveq	#0,d3
	moveq	#0,d4			Force non interlaced!
	move.l	Tt_Resource(a4),a0
	add.l	2(a0),a0
	JJsrR	L_Dia_RScOpen,a1
	bne	.Out
	move.l	T_EcCourant(a5),a0
	move.w	Ed_Wy(a5),EcAWY(a0)
	SyCalD	ResZone,NBoutons
	bne	.Out
; Affiche les boutons
; ~~~~~~~~~~~~~~~~~~~
	moveq	#1,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	Tt_UPack
	bsr	ABoutons
	bsr	Tt_SEval
	bsr	View_Cls
	bsr	TtReCop

; Ouvre l'ecran du bas
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#Tt_Ecran2,d0
	move.l	#E2_Sx,d1
	move.w	Ttt_Sy(a4),d2
	ext.l	d2
	moveq	#0,d3
	moveq	#0,d4			Interlaced?
	move.b	Ed_Inter(a5),d4
	move.l	Ed_Resource(a5),a0
	add.l	2(a0),a0
	JJsrR	L_Dia_RScOpen,a1
	bne	.Out
	move.l	T_EcCourant(a5),a0
	move.w	Ed_Wy(a5),EcAWY(a0)
	add.w	#E1_Sy,EcAWY(a0)
	SyCalD	ResZone,4
	bne	.Out
	WiCalA	Print,Ttt_WInit(pc)
; Ouvre le DBL
	lea	DBL(pc),a0		Programme d'essai!
	move.l	Ed_Resource(a5),a1
	add.l	2(a1),a1
	move.l	#Tt_ChannelN,d0		Numero du canal
	move.l	#512,d1			Buffer
	moveq	#12,d2			Nombre de variables
	moveq	#0,d3			Ne PAS recopier
	JJsrR	L_Dia_OpenChannel,a2
	tst.l	d0			Une erreur?
	bne	.Out
	move.l	a0,Tt_Channel(a4)
	move.l	a1,Tt_Variables(a4)
; Initialisation du fond
	move.w	Ttt_Sy(a4),d0
	lsr.w	#1,d0
	addq.w	#8,d0
	bsr	Ttt_SetSize
	bsr	Ttt_Cls
	bne	.Out
	bsr	Ttt_NewBuf
	move.l	Inf_Buf(a4),a0
	move.l	a0,Inf_Pos(a4)
	moveq	#5,d0
	bsr	Tt_Message
	move.l	a0,-(sp)
	moveq	#2,d0
	bsr	Inf_PrDeb
	bsr	Inf_Print
	bsr	Inf_PrFin
	move.l	(sp)+,a0
	moveq	#4,d0
	bsr	Inf_PrDeb
	bsr	Inf_Print
	bsr	Inf_PrFin
; Poke les patches
	lea	TstPatch(pc),a0
	move.l	a0,ExtTests+4(a5)
	lea	Tt_PScFront(pc),a0
	move.l	a0,Patch_ScFront(a5)
	lea	Tt_PScCopy(pc),a0
	move.l	a0,Patch_ScCopy(a5)
	move.w	#L_Mon_MonitorChr,d0		Branche le moniteur
	JJsr	L_SetChrPatch
	move.l	Prg_JError(a5),Tt_JError(a4)
	bsr	Set_WPatch
; Branche les interruptions couleurs...
	lea	VblRout(a5),a0
.loopI	tst.l	(a0)+
	bne.s	.loopI
	lea	View_Inter(pc),a1
	move.l	a1,-4(a0)
; Prepare les affichage des ecrans
	bsr	View_ScUpdate
	bsr	View_Act
	bsr	View_Aff
; Force la souris...
	bsr	Tt_Mouse
; Verifie, au moins 4K de chip
	move.l	a6,-(sp)
	move.l	#Public|Chip,d1
	move.l	$4.w,a6
	jsr	_LVOAvailMem(a6)
	move.l	(sp)+,a6
	cmp.l	#1024*4,d0
	bcs.s	.Out
; Fin, pas d'erreur, flag moniteur present!
	bsr	TtReCop
	moveq	#0,d0
	rts
; Out of mem!
.Out	bsr	Tt_Free
	bsr	Tt_MonFree
	moveq	#1,d0
	rts

; 	Effacement de la zone de donnee monitor
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_MonFree
	move.l	Mon_Base(a5),d0
	beq.s	.Skip
	move.l	d0,a1
	move.l	#Tt_DzLong,d0
	SyCall	MemFree
.Skip	rts

;	Effacement des donnees
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Free	move.l	Mon_Base(a5),d0
	beq	.PaInit
	move.l	d0,a4
	bsr	Del_WPatch
	moveq	#0,d0
	JJsr	L_SetChrPatch
	clr.l	ExtTests+4(a5)
	bclr	#1,T_Actualise+1(a5)
	bclr	#1,ActuMask+1(a5)
	clr.l	Patch_Menage(a5)
	clr.l	Patch_Errors(a5)
	clr.l	Patch_ScFront(a5)
	clr.l	Patch_ScCopy(a5)
	move.l	Tt_JError(a4),Prg_JError(a5)
; Enleve les interruptions
	lea	VblRout(a5),a0
	lea	View_Inter(pc),a1
	moveq	#8-1,d0
.loopI	cmp.l	(a0)+,a1
	dbeq	d0,.loopI
	tst.w	d0
	bmi.s	.Sk
	clr.l	-4(a0)
; Enleve le canal DBL
.Sk	bsr	Tt_TtBanks
	move.l	#Tt_ChannelN,d0		Numero du canal
	JJsr	L_Dia_CloseChannel
; Enleve les ecrans
	EcCalD	Del,Tt_Ecran1
	EcCalD	Del,Tt_Ecran2
; Enleve les buffers
	bsr	Hlp_FreeMap		Enleve les HELP
	move.l	Ttt_BufE(a4),d0
	beq.s	.B1
	move.l	d0,a1
	move.w	Ttt_Sy(a4),d0
	lsr.w	#3,d0			Buffer d'edition
	mulu	#256,d0
	SyCall	MemFree
.B1	move.l	Tt_BufT(a4),d0
	beq.s	.B2
	move.l	d0,a1
	move.l	#1024+512,d0		Buffer Tokenisation / Lignes
	SyCall	MemFree
.B2	move.l	Inf_Buf(a4),d0
	beq.s	.B3
	move.l	d0,a1
	move.l	#Inf_Size,d0		Buffer infos
	SyCall	MemFree
.B3
; Remet les banques du programme, et basta!
.PaInit	bsr	Tt_PrgBanks
	rts

;	TOUCHE: quit/ Retour � l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Quit
; Si Break Off >>> on peut pas!!!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	Tt_Init(a4)
	ble.s	.Quit
	move.w	ActuMask(a5),d0
	btst	#BitControl,d0
	bne.s	.Quit
	moveq	#7,d0
	bsr	Tt_Message
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bra	Inf_AffAll
.Quit
; Effacement de tous les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Tt_Free
	bsr	TtReCop
; Retour � l'editeur ou au programme???
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,a1
	move.l	#Tt_DzLong,d0
	clr.l	Mon_Base(a5)
	tst.w	Tt_Run(a4)
	bne.s	.torun
; Retour � l'�diteur
.parun	SyCall	MemFree			Plus de datazone
	clr.l	Prg_Runned(a5)		Plus de programme courant
	JJsr	L_Includes_Clear	Libere la memoire
	JJsr	L_ClearVar
	move.l	#1000,d0		Fait un EDIT
	sub.l	a0,a0
	move.l	Prg_JError(a5),a1
	jmp	(a1)
; Retour au programme
.torun	tst.w	Tt_Init(a4)
	ble.s	.parun
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	lea	Step_Data(a4),a0
	move.l	(a0)+,-(sp)
	movem.l	(a0),a3-a6/d4-d5/d6-d7
	SyCall	MemFree
	move.w	ScOn(a5),d1
	beq.s	.skip
	subq.w	#1,d1
	EcCall	Active
.skip	move.l	d4,d0
	move.l	d5,d1
	rts

;
; Actualisation des ecrans
TtReCop	SyCall	WaitVbl
	EcCall	CopForce
	rts

;	Montre les deux ecrans
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tt_Show	moveq	#0,d2
	bra.s	Tth
;	Cache les deux ecrans
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Hide	moveq	#-1,d2			Ne PAS changer!
Tth	movem.l	d0-d7/a0-a4,-(sp)
	move.l	Mon_Base(a5),a0
	cmp.b	Tt_NotHere(a0),d2	D2=0 si show, -1 si hide!
	beq.s	.Skip
	move.b	d2,Tt_NotHere(a0)
	EcCalD	EHide,Tt_Ecran1
	EcCalD	EHide,Tt_Ecran2
	bsr	TtReCop
.Skip	movem.l	(sp)+,d0-d7/a0-a4
	rts

;	Force la souris en marche
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Mouse
	movem.l	d0-d7/a0-a3,-(sp)
	SyCall	Show,-1
	moveq	#64,d1			Nouvelles limites
	moveq	#30,d2
	move.l	#510,d3
	move.l	#312,d4
	move.l	#$01234567,d5		Magic!
	SyCall	LimitM
	movem.l	(sp)+,d0-d7/a0-a3
	rts


; ___________________________________________________________________
;
;	PATCH SUR AMOS.LIBRARY
; ___________________________________________________________________
;
;	Branche le patch sur W
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Set_WPatch
	move.l	a0,-(sp)
	lea	Old_EcVect(pc),a0
	move.l	T_EcVect(a5),(a0)
	lea	Old_SyVect(pc),a0
	move.l	T_SyVect(a5),(a0)
	lea	EcIn(pc),a0
	move.l	a0,T_EcVect(a5)
	lea	SyIn(pc),a0
	move.l	a0,T_SyVect(a5)
	move.l	(sp)+,a0
	rts
;	Enleve le patch sur W
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Del_WPatch
	move.l	a0,-(sp)
	lea	Old_EcVect(pc),a0
	tst.l	(a0)
	beq.s	.Skip1
	move.l	(a0),T_EcVect(a5)
	clr.l	(a0)
.Skip1	lea	Old_SyVect(pc),a0
	tst.l	(a0)
	beq.s	.Skip2
	move.l	(a0),T_SyVect(a5)
	clr.l	(a0)
.Skip2	move.l	(sp)+,a0
	rts

;	Patch des fonctions W ecrans...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EcIn	bsr	TT_WPatch		RAZ
	bsr	TT_WPatch2		Copper
	bsr	TT_WPatch2		Libre
	bsr	TT_WPatchC		Cree
	bsr	TT_WPatch		Del
	bsr	TT_WPatch		First
	bsr	TT_WPatch		Last
	bsr	TT_WPatch		Active
	bsr	TT_WPatch2		Forcecop
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch		5 Fonctions de securite!
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch
	bsr	TT_WPatch

;	Restore les ecrans puis appelle
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_WPatch2
	bsr.s	Tt_first
;	Patch normal...
; ~~~~~~~~~~~~~~~~~~~~~
TT_WPatch
	move.l	a0,-(sp)
	move.l	4(sp),a0
	sub.l	T_EcVect(a5),a0
	subq.l	#4,a0
	add.l	Old_EcVect(pc),a0
	move.l	a0,4(sp)
	move.l	(sp)+,a0
	rts
;	Appelle puis restore les ecrans
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_WPatch1
	move.l	(sp)+,a0
	sub.l	T_EcVect(a5),a0
	subq.l	#4,a0
	add.l	Old_EcVect(pc),a0
	jsr	(a0)
; Routine: met les deux en premier...
Tt_first
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	Old_EcVect(pc),a0	* Ecran Tutor1
	moveq	#Tt_Ecran1,d1
	jsr	First*4(a0)
	move.l	Old_EcVect(pc),a0	* Ecran Tutor2
	moveq	#Tt_Ecran2,d1
	jsr	First*4(a0)
	move.l	Old_EcVect(pc),a0	* Ecran FSEL
	moveq	#EcFsel,d1
	jsr	First*4(a0)
	move.l	Old_EcVect(pc),a0	* Ecran Requester
	moveq	#EcReq,d1
	jsr	First*4(a0)
	movem.l	(sp)+,a0-a6/d0-d7
	tst.l	d0
	rts
;	Patch pour CREATION ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_WPatchC
; Appelle
	move.l	(sp)+,a0
	sub.l	T_EcVect(a5),a0
	subq.l	#4,a0
	add.l	Old_EcVect(pc),a0
	jsr	(a0)
	bne.s	.Err
; Change les tables du TUTOR
	movem.l	a0/a1/d0/d1,-(sp)
	move.w	EcNumber(a0),d1
	cmp.w	#8,d1
	bcc.s	.skuo
	lsl.w	#3,d1
	move.l	Mon_Base(a5),a1
	lea	ViewScrols(a1),a1
	add.w	d1,a1
	clr.l	(a1)
	move.w	EcTx(a0),4(a1)
	move.w	EcTy(a0),d0
	tst.w	EcCon0(a0)
	bmi.s	.skip
	lsr.w	#1,d0
.skip	move.w	d0,6(a1)
.skuo	movem.l	(sp)+,a0/a1/d0/d1
; Ok!
.Err	tst.w	d0
	rts

;	Patch des fonctions W systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SyIn:	bsr 	TT_SPatch	ClInky		;0
	bsr	TT_SPatch	ClVide		;1
	bsr 	TT_SPatch	ClSh		;2
	bsr	TT_SPatch	ClInst		;3
	bsr	TT_SPatch	ClKeyM		;4
	bsr	TT_SPatch	ClJoy		;5
	bsr	TT_SPatch	ClPutK		;6
	bsr	TT_SPatch	MHide		;7
	bsr	TT_SPatch	MShow		;8
	bsr	TT_SPatch	MChange		;9 - ChMouse
	bsr	TT_SPatch	MXy		;10- XY Mouse
	bsr	TT_SPatch	CXyHard		;11- Conversion SCREEN-> HARD
	bsr	TT_SXyScr	CXyScr		;12- Conversion HARD-> SCREEN
	bsr	TT_SPatch	MBout		;13
	bsr	TT_SPatch	MSetAb		;14
	bsr	TT_SGSIn	GetSIn		;15- Get screen IN
	bsr	TT_SPatch	CXyWi		;16- Conversion SCREEN-> WINDOW courante
	bsr	TT_SPatch	MLimA		;17- Limit mouse
	bsr	TT_SZoHd	SyZoHd		;18- Zone coordonnees HARD
	bsr	TT_SPatch	SyResZ		;19- Reserve des zones
	bsr	TT_SPatch	SyRazZ		;20- Effacement zones
	bsr	TT_SPatch	SySetZ		;21- Set zone
	bsr	TT_SPatch	SyMouZ		;22- Zone souris!
	bsr	TT_SPatch	WVbl		;23
	bsr	TT_SPatch	HsSet		;24- Affiche un hard sprite
	bsr	TT_SPatch	HsUSet		;25- Efface un hard sprite
	bsr	TT_SPatch	ClFFk		;26
	bsr	TT_SPatch	ClGFFk		;27
	bsr	TT_SPatch	HsAff		;28- Recalcule les hard sprites
	bsr	TT_SPatch	HsBank		;29- Fixe la banque de sprites
	bsr	TT_SPatch	HsNXYA		;30- Instruction sprite
	bsr	TT_SPatch	HsXOff		;31- Sprite off n
	bsr	TT_SPatch	HsOff		;32- All sprite off
	bsr	TT_SPatch	HsAct		;33- Actualisation HSprite
	bsr	TT_SPatch	HsSBuf		;34- Set nombre de lignes
	bsr	TT_SPatch	HsStAct		;35- Arrete les HS sans deasctiver!
	bsr	TT_SPatch	HsReAct		;36- Re-Active tous!
	bsr	TT_SPatch	MStore		;37- Stocke etat souris / Show on
	bsr	TT_SPatch	MRecall		;38- Remet la souris
	bsr	TT_SPatch	HsPri		;39- Priorites SPRITES/PLAYFIELD
	bsr	TT_SPatch	TokAMAL		;40- Tokenise AMAL
	bsr	TT_SPatch	CreAMAL		;41- Demarre AMAL
	bsr	TT_SPatch	MvOAMAL		;42- On/Off/Freeze AMAL
	bsr	TT_SPatch	DAllAMAL	;43- Enleve TOUT!
	bsr	TT_SPatch	Animeur		;44- Un coup d'animation
	bsr	TT_SPatch	RegAMAL		;45- Registre!
	bsr	TT_SPatch	ClrAMAL		;46- Clear
	bsr	TT_SPatch	FrzAMAL		;47- FREEZE all
	bsr	TT_SPatch	UFrzAMAL	;48- UNFREEZE all
	bsr	TT_SPatch	BobSet		;49- Entree set bob
	bsr	TT_SPatch	BobOff		;50- Arret bob
	bsr	TT_SPatch	BobSOff		;51- Arret tous bobs
	bsr 	TT_SPatch	BobAct		;52- Actualisation bobs
	bsr	TT_SPatch	BobAff		;53- Affichage bobs
	bsr	TT_SPatch	BobEff		;54- Effacement bobs
	bsr	TT_SPatch	ChipMM		;55- Reserve CHIP
	bsr	TT_SPatch	FastMM		;56- Reserve FAST
	bsr	TT_SPatch	BobLim		;57- Limite bobs!
	bsr	TT_SPatch	SyZoGr		;58- Zone coord graphiques
	bsr	TT_SPatch	GetBob		;59- Saisie graphique
	bsr	TT_SPatch	Masque		;60- Calcul du masque
	bsr	TT_SPatch	SpotH		;61- Fixe le point chaud
	bsr	TT_SPatch	BbColl		;62- Collisions bob
	bsr	TT_SPatch	GetCol		;63- Fonction collision
	bsr	TT_SPatch	SpColl		;64- Collisions sprites
	bsr	TT_SPatch	SyncO		;65- Synchro on/off
	bsr	TT_SPatch	Sync		;66- Synchro step
	bsr	TT_SPatch	SetPlay		;67- Set play direction...
	bsr	TT_SPatch	BobXY		;68- Get XY Bob
	bsr	TT_SPatch	HsXY		;69- Get XY Sprite
	bsr	TT_SPatch	BobPut		;70- Put Bob!
	bsr	TT_SPatch	TPatch		;71- Patch icon/bob!
	bsr	TT_SPatch	MRout		;72- Souris relachee
	bsr	TT_SPatch	MLimEc		;73- Limit mouse ecran
	bsr	TT_SPatch	FreeMM		;74- Libere mem
	bsr	TT_SPatch	HColSet		;75- Set HardCol
	bsr	TT_SPatch	HColGet		;76- Get HardCol
	bsr	TT_SPatch	TMovon		;77- Movon!
	bsr	TT_SPatch	TKSpeed		;78- Key speed
	bsr	TT_SPatch	TChanA		;79- =ChanAn
	bsr	TT_SPatch	TChanM		;80- =ChanMv
	bsr	TT_SPatch	TPrio		;81- Set priority
	bsr	TT_SPatch	TGetDisc	;82- State of disc drive
	bsr	TT_SPatch	Add_VBL		;83- Restart VBL
	bsr	TT_SPatch	Rem_VBL		;84- Stop VBL
	bsr	TT_SPatch	ClKwait		;85- Une touche en attente?
	bsr	TT_SPatch	WMouScrFront	;86- Coordonnees souris devant ILLEGAL
	bsr	TT_SPatch	WMemReserve	;87- (P) Reservation memoire secure
	bsr	TT_SPatch	WMemFree	;88- (P) Liberation memoire secure
	bsr	TT_SPatch	WMemCheck	;89- (P) Verification memoire
	bsr	TT_SPatch	WMemFastClear	;90- (P)
	bsr	TT_SPatch	WMemChipClear	;91-
	bsr	TT_SPatch	WMemFast	;92-
	bsr	TT_SPatch	WMemChip	;93-
	bsr	TT_SPatch			;94-
	bsr	TT_SPatch			;95-
	bsr	TT_SPatch			;96-
	bsr	TT_SPatch			;97-
	bsr	TT_SPatch			;98-
	bsr	TT_SPatch			;99-
	bsr	TT_SPatch			;100-


;	Patch systeme normal...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_SPatch
	move.l	a0,-(sp)
	move.l	4(sp),a0
	sub.l	T_SyVect(a5),a0
	subq.l	#4,a0
	add.l	Old_SyVect(pc),a0
	move.l	a0,4(sp)
	move.l	(sp)+,a0
	rts
;	Patch fonction XyScr
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_SXyScr
	bsr	TT_SHere
	bne	TT_SPatch
	move.l	a4,(sp)
	move.l	Mon_Base(a5),a4
	bsr	TT_Hard2Screen
	movem.l	(sp)+,a4
	bpl.s	.Skip
	moveq	#0,d1
	moveq	#0,d2
.Skip	moveq	#0,d0
	rts
;	Patch fonction Zone Hard
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_SZoHd
	bsr	TT_SHere
	bne	TT_SPatch
	move.l	a4,(sp)
	move.l	Mon_Base(a5),a4
	bsr	TT_Hard2Screen
	move.l	(sp)+,a4
	bmi.s	.Out
	moveq	#8,d5
	move.l	Old_SyVect(pc),a0
	jsr	ZoGr*4(a0)
.Skip	rts
.Out	moveq	#0,d1
	moveq	#0,d0
	rts
;	Patch fonction GetSCin
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_SGSIn
	bsr	TT_SHere
	bne	TT_SPatch
	move.l	a4,(sp)
	move.l	Mon_Base(a5),a4
	bsr	TT_EcIn
	bmi.s	.Out
	lsl.w	#2,d0
	lea	T_EcAdr(a5),a1
	move.l	0(a1,d0.w),d0
	beq.s	.Out
	move.l	d0,a1
	bsr	XY2Ec
	bmi.s	.Out
	cmp.w	EcTx(a1),d1
	bcc.s	.Out
	cmp.w	EcTy(a1),d2
	bcc.s	.Out
	moveq	#0,d1
	move.w	EcNumber(a1),d1
	move.l	(sp)+,a4
	moveq	#0,d0
	rts
.Out	move.l	#EntNul,d1
	move.l	(sp)+,a4
	moveq	#0,d0
	rts

;;	Boutons de la souris, uniquement dans le petit ecran
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;TT_SMBout
;	move.l	Old_SyVect(pc),a0
;	jsr	MouseKey*4(a0)
;	tst.b	d1
;	beq.s	.Skip
;	bsr	TT_SHere
;	bne.s	.Skip
;	movem.l	d2-d7/a1-a2,-(sp)
;	move.w	d1,-(sp)
;	move.l	d2,d7
;	move.l	Old_SyVect(pc),a0
;	jsr	XyMou*4(a0)
;	bsr	TT_EcIn
;	cmp.l	#$01234567,d7
;	beq.s	.Mon
;; Demande de la part du programme: uniquement DANS l'ecran
;	tst.l	d0
;	bmi.s	.Non
;	bra.s	.Oui
;; Demande de la part du moniteur: uniquement en dehors de l'ecran, si RUN
;.Mon	tst.l	d0
;	bmi.s	.Oui
;	move.l	Mon_Base(a5),a0
;	tst.w	Step_Mode(a0)
;	beq.s	.Oui
;.Non	clr.w	(sp)
;.Oui	move.w	(sp)+,d1
;	movem.l	(sp)+,d2-d7/a1-a2
;.Skip	rts

;	Conversion coordonn�es hard (d1/d2/d3) -> coordonn�es ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_Hard2Screen
	bsr	TT_EcToA1
	bmi.s	.Out
	move.l	a0,a1
	bsr	TT_EcIn
	bmi.s	.Out
	move.w	EcNumber(a1),d3
	addq.w	#1,d3
	cmp.w	EcNumber(a1),d0
	beq.s	XY2Ec
.Out	moveq	#-1,d0
	rts
;	Converti D1/D2 en coord dans l'ecran A1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XY2Ec	movem.w	d1-d3,-(sp)
	bsr	View_ScAd
	movem.w	(sp)+,d1-d3
	add.w	(a0)+,d1
	add.w	(a0)+,d2
; Si lowres, multiplie par 2 en Y
	btst	#7,EcCon0(a1)
	bne.s	.Hires
	lsl.w	#1,d2
.Hires
	moveq	#0,d0
	rts

;	Trouve l'�cran sous les coordonnees hard...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1/D2= X/Y HARD
;	D3= 1er ecran
;	D4= Ecran MAX
TT_EcIn	movem.l	a0/d3,-(sp)
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	moveq	#Tt_Ecran1+1,d3
	move.l	Old_SyVect(pc),a0
	jsr	XyScr*4(a0)
	tst.w	(sp)
	beq.s	.Skip1
	sub.w	#RedX,d1
	bmi.s	.Pas
	cmp.w	#RedTX,d1
	bcc.s	.Pas
.Skip1	tst.w	2(sp)
	beq.s	.Ok
	sub.w	#RedY,d2
	bmi.s	.Pas
	cmp.w	#RedTY,d2
	bcc.s	.Pas
; Dans le petit ecran...
.Ok	moveq	#0,d0
	move.w	Tt_View(a4),d0
	bpl.s	.In
.Pas	moveq	#-1,d0
.In	addq.l	#4,sp
	movem.l	(sp)+,a0/d3
	rts

;	Ecrans D3
; ~~~~~~~~~~~~~~~
;	<0	=> Rien du tout
;	0	=> Ecran courant
;	>0	=> Ecran+1
TT_EcToA1
	tst.w	d3
	bmi.s	EcToD4
	bne.s	EcToD2
	move.l	T_EcCourant(a5),a0
	rts
EcToD2:	lsl.w	#2,d3
	lea	T_EcAdr(a5),a0
	move.l	-4(a0,d3.w),d3
	beq.s	EcToD3
	move.l	d3,a0
	rts
EcToD3:	addq.l	#4,sp
	moveq	#3,d0
	rts
EcToD4:	moveq	#-1,d0
	rts

;	Retourne BNE si l'ecran du tuteur n'est pas la
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TT_SHere
	movem.l	a0/d0/d1,-(sp)
	moveq	#1,d1
	move.l	Mon_Base(a5),a0
	tst.b	Tt_NotHere(a0)
	bne.s	.Out
	move.l	T_EcCourant(a5),d0
	beq.s	.Out
	move.l	d0,a0
	move.w	EcNumber(a0),d0
	cmp.w	#8,d0
	bcc.s	.Out
	moveq	#0,d1
.Out	tst.w	d1
	movem.l	(sp)+,a0/d0/d1
	rts

; ___________________________________________________________________
;
;	Patch SCREEN TO FRONT
; ___________________________________________________________________
;
Tt_PScFront
	bra	ToFront
	bra	ToBack
; Passe devant
; ~~~~~~~~~~~~
ToFront	lea	Mon_Banks(a5),a0	Mode moniteur?
	cmp.l	Cur_Banks(a5),a0
	beq.s	.Skip
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	Mon_Base(a5),a4
	bsr	Tt_Hide
.Quit	movem.l	(sp)+,d1-d7/a1-a6
.Skip	rts
; Passe derriere
; ~~~~~~~~~~~~~~
ToBack	lea	Mon_Banks(a5),a0	Mode moniteur?
	cmp.l	Cur_Banks(a5),a0
	beq.s	.Skip
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	Mon_Base(a5),a4
	bsr	Tt_Show
.Quit	movem.l	(sp)+,d1-d7/a1-a6
.Skip	rts
; ___________________________________________________________________
;
;	Patch SCREEN COPY
; ___________________________________________________________________
;
Tt_PScCopy
	move.l	Mon_Base(a5),a0		Mode moniteur?
	tst.b	Tt_NotHere(a0)		Deja la?
	bne.s	.Skip
	lea	Mon_Banks(a5),a0
	cmp.l	Cur_Banks(a5),a0
	beq.s	.Skip
; Recopie l'ecran
	movem.l	d1-d7/a1-a6,-(sp)
	move.l	Mon_Base(a5),a4
	bsr	Tt_TtBanks
	move.l	T_EcCourant(a5),d0
	beq.s	.Quit
	move.l	d0,a0
	move.w	EcNumber(a0),-(sp)
	move.w	#-1,Tt_Ecran(a4)
	bsr	View_Act
	move.w	(sp),d1
	subq.w	#1,d1
	bsr	View_Ec
	bsr	View_Aff
	move.w	(sp)+,d1
	EcCall	Active
.Quit	bsr	Tt_PrgBanks
	movem.l	(sp)+,d1-d7/a1-a6
.Skip	rts

; ___________________________________________________________________
;
;	Patch branche sur tests: reaffiche l'ecran (mode 3)
; ___________________________________________________________________
;
TstPatch
	movem.l	d0-d7/a0-a6,-(sp)
; Actualise
	move.l	Mon_Base(a5),a4
	bsr	Tt_TtBanks
	move.w	#-1,Tt_Ecran(a4)
	bsr	View_Act
*	move.w	ScOn(a5),d1
*	subq.w	#2,d1
*	bsr	View_Ec
	bsr	View_Aff
; Verifie que l'on appuie pas sur la souris
;	cmp.w	#2,Step_Mode(a4)		illegal
;	bcs.s	.skip
	bsr	Tt_MBout
	btst	#0,d1
	beq.s	.skip
	SyCall	GetZone
	cmp.w	#Tt_Ecran1,d1
	bne.s	.skip
	swap	d1
	tst.w	d1
	beq.s	.skip
	cmp.w	#13,d1
	beq.s	.skip
	addq.w	#1,Step_Stop(a4)
	bsr	BoutStop
; Empeche les boucles
.skip	move.w	ScOn(a5),d1
	beq.s	.skip1
	subq.w	#1,d1
	EcCall	Active
.skip1	bclr	#7,T_Actualise(a5)
; Retour aux tests
	bsr	Tt_PrgBanks
	movem.l	(sp)+,d0-d7/a0-a6
	rts
BoutStop
	move.w	Tt_Active(a4),d0
	moveq	#0,d1
	bsr	ABouton
	moveq	#1,d0
	move.w	d0,Tt_Active(a4)
	moveq	#1,d1
	bra	ABouton


; ___________________________________________________________________
;
;	GESTION PROGRAMME
; ___________________________________________________________________


;	TOUCHE: Centre le programme sur l'instruction courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_CText
	tst.w	Tt_YNext(a4)
	bmi	NoInit
	bsr	Ttt_Centre
	bra	Ttt_AffBuf

;	TOUCHE: Slider horizontal
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Slhclic
	move.l	#Tt_ChannelN,d0		Demande la position slider
	moveq	#1,d1
	moveq	#0,d2
	JJsr	L_Dia_GetValue
	move.w	d1,Ttt_XPos(a4)
	bsr	Ttt_AffBuf
	rts

;	TOUCHE:	Slider vertical
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Slvclic
	move.l	#Tt_ChannelN,d0		Demande la position slider
	moveq	#2,d1
	moveq	#0,d2
	JJsr	L_Dia_GetValue
	move.w	Ttt_YPos(a4),d0
	move.w	d1,Ttt_YPos(a4)
	sub.w	d1,d0
	cmp.w	#1,d0
	beq.s	.Bas
	cmp.w	#-1,d0
	beq.s	.Haut
; POSITIONNE DIRECTEMENT
; ~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ttt_NewBuf
	rts
; SCROLL VERS LE BAS
; ~~~~~~~~~~~~~~~~~~
.Bas	WiCalA	Print,Ttt_Scrdown(pc)	Ecran graphique
	move.l	Ttt_BufE(a4),a1		Ecran texte
	move.w	Ttt_Tlh(a4),d0
	lsl.w	#8,d0
	add.w	d0,a1
	lea	-256(a1),a0
	move.w	Ttt_Tlh(a4),d0
	subq.w	#1,d0
	lsl.w	#4,d0
	subq.w	#1,d0
	bmi.s	.Lsk
.loop	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	dbra	d0,.loop
; Affiche la derniere ligne
.Lsk	move.w	Ttt_YPos(a4),d0
	moveq	#0,d1
	bsr	Ttt_Untok
	bsr	Ttt_ALigne
	rts
; SCROLL VERS LE HAUT
; ~~~~~~~~~~~~~~~~~~~
.Haut	lea	Ttt_Scrup(pc),a1	Ecran graphique
	move.w	Ttt_Tlh(a4),d0
	add.b	#48-1,d0
	move.b	d0,2(a1)
	WiCall	Print
	move.l	Ttt_BufE(a4),a1		Ecran texte
	lea	256(a1),a0
	move.w	Ttt_Tlh(a4),d0
	subq.w	#1,d0
	lsl.w	#4,d0
	subq.w	#1,d0
	bmi.s	.Slk
.cloop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.cloop
; Affiche la derniere ligne
.Slk	move.w	Ttt_YPos(a4),d0
	move.w	Ttt_Tlh(a4),d1
	subq.w	#1,d1
	add.w	d1,d0
	bsr	Ttt_Untok
	bsr	Ttt_ALigne
	rts

;	Centre le listing sur l'instruction courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Centre
	move.w	Ttt_YPos(a4),d2
	move.w	d2,d3
	add.w	Ttt_Tlh(a4),d3
	addq.w	#1,d2
	subq.w	#1,d3
	move.w	Tt_YNext(a4),d0
	cmp.w	d2,d0
	bcs.s	.change
	cmp.w	d3,d0
	bcc.s	.change
	rts
; Change la position de l'editeur
.change	move.w	Ttt_Tlh(a4),d2
	subq.w	#1,d0
	bpl.s	.skip1
	moveq	#0,d0
.skip1	add.w	d0,d2
	cmp.w	Prg_NLigne(a3),d2
	bcs.s	.skip2
	sub.w	Prg_NLigne(a3),d2
	sub.w	d2,d0
	bpl.s	.skip2
	moveq	#0,d0
.skip2	move.w	d0,Ttt_YPos(a4)
	bsr	Ttt_BufUntok
	rts

;	Affichage du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_AffBuf
	movem.l	d0-d7,-(sp)
	bra.s	Blu
Ttt_NewBuf
	movem.l	d0-d7,-(sp)
	bsr	Ttt_BufUntok
Blu	bsr	Ttt_TttAct
	moveq	#0,d1
.loop	bsr	Ttt_EALigne
	addq.w	#1,d1
	cmp.w	Ttt_Tlh(a4),d1
	bcs.s	.loop
	bsr	Ttt_SliV
	bsr	Ttt_SliH
	movem.l	(sp)+,d0-d7
	rts

;	Actualisation du slider programme horizontal
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_SliH
	move.l	#Tt_ChannelN,d0		Re-actualise le slider, donc la liste
	moveq	#1,d1
	move.w	Ttt_XPos(a4),d2		Position
	moveq	#78,d3			Nouvelle window
	move.w	#250,d4		Nouveau global
	JJsr	L_Dia_Update
	rts
;	Actualisation du slider programme vertical
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_SliV
	move.l	#Tt_ChannelN,d0		Re-actualise le slider, donc la liste
	moveq	#2,d1
	move.w	Ttt_YPos(a4),d2		Position
	move.w	Ttt_Tlh(a4),d3		Nouvelle window
	move.w	Prg_NLigne(a3),d4	Nouveau global
	JJsr	L_Dia_Update
	rts

; 	DETOKENISE TOUT LE BUFFER
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_BufUntok
	move.l	a2,-(sp)
	clr.w	-(sp)
	move.w	Ttt_YPos(a4),d0
	bsr	Ttt_FindL
	bra.s	.BUnt1
.BUnt0	bsr	Ttt_NextL
.BUnt1	move.w	(sp),d1
	move.l	Ttt_BufE(a4),a1
	lsl.w	#8,d1
	lea	0(a1,d1.w),a1
	clr.w	(a1)
	clr.b	255(a1)			Ligne editable
	tst.w	d0
	beq.s	.BUnt2
	JJsrR	L_Tk_EditL,a2
	bne.s	.Edit
	move.b	#-1,255(a1)		Ligne NON editable!
.Edit	moveq	#0,d0
	JJsrR	L_Detok,a2
.BUnt2	addq.w	#1,(sp)
	move.w	(sp),d0
	cmp.w	Ttt_Tlh(a4),d0
	bcs.s	.BUnt0
	addq.l	#2,sp
	move.l	(sp)+,a2
	rts

; 	DETOKENISE la LIGNE D0 dans le BUFFER ligne D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Untok
	movem.l	d0-d1/a0-a2,-(sp)
	move.l	Ttt_BufE(a4),a1
	lsl.w	#8,d1
	lea	0(a1,d1.w),a1
	clr.w	(a1)
	clr.b	255(a1)
	move.l	a1,-(sp)
	bsr	Ttt_FindL
	move.l	(sp)+,a1
	beq.s	.Fin
	JJsrR	L_Tk_EditL,a2
	bne.s	.Edit
	move.b	#-1,255(a1)
.Edit	moveq	#0,d0
	JJsrR	L_Detok,a2
.Fin	movem.l	(sp)+,d0-d1/a0-a2
	rts

; TROUVE L'ADRESSE DE LA LIGNE D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_FindL
	move.l	a1,-(sp)
	move.l	Prg_StBas(a3),a0
	JJsrR	L_Tk_FindL,a1
	move.l	a0,Tt_CurLigne(a4)
	move.l	a1,Tt_DebProc(a4)
	move.l	(sp)+,a1
	tst.w	d0
	rts
; Trouve la ligne suivante
; ~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_NextL
	move.l	a1,-(sp)
	move.l	Tt_CurLigne(a4),a0
	JJsrR	L_Tk_FindN,a1
	move.l	a0,Tt_CurLigne(a4)
	move.l	a1,Tt_DebProc(a4)
	move.l	(sp)+,a1
	tst.w	d0
	rts

;	Imprime la ligne du buffer D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_EALigne
	movem.l	d0-d4/a0-a3,-(sp)	Efface
	bset	#30,d1
	bra.s	ttaa
Ttt_ALigne
	movem.l	d0-d4/a0-a3,-(sp)	Affiche seulement
	bclr	#30,d1
ttaa
; Locate en debut de ligne
	move.l	d1,-(sp)
	move.w	d1,d2
	move.w	d1,d3
	add.w	Ttt_YPos(a4),d3
	moveq	#0,d1
	ext.l	d2
	WiCall	Locate

; Pointe la ligne dans le buffer
	move.w	2(sp),d0
	lsl.w	#8,d0
	move.l	Ttt_BufE(a4),a0
	lea	0(a0,d0.w),a0
	move.w	Ttt_XPos(a4),d1
	move.w	(a0)+,d0		Longueur de la ligne
	cmp.w	d0,d1
	bcc	.skipX
	lea	0(a0,d1.w),a1		Pointe le debut
	add.w	#78,d1
	move.w	d1,d2
	cmp.w	d0,d1
	bls.s	.skip1
	move.w	d0,d1
.skip1	cmp.w	d0,d2
	bhi.s	.skip2
	bclr	#6,(sp)
.skip2	lea	0(a0,d1.w),a2		Marque la fin de la ligne
	move.b	(a2),d2
	clr.b	(a2)

; Dessiner une marque dans la ligne???
	cmp.w	Tt_YNext(a4),d3
	beq.s	.Mark
	cmp.w	Tt_YInfo(a4),d3
	beq.s	.Mark
	cmp.w	Tt_YMark(a4),d3
	bne	.skipM

.Mark	movem.l	a2/d2,-(sp)
	move.l	Buffer(a5),a0
	move.w	Ttt_XPos(a4),d2
.LoopM	cmp.w	Tt_YNext(a4),d3
	bne.s	.skipM1
	cmp.w	Tt_XNext(a4),d2
	bne.s	.skipM1
	lea	Ttt_Mark(pc),a2		Met le >>>
.loopM1	move.b	(a2)+,(a0)+
	bne.s	.loopM1
	subq.l	#1,a0
.skipM1	cmp.w	Tt_YMark(a4),d3
	bne.s	.skipM3
	cmp.w	Tt_X1Mark(a4),d2
	bne.s	.skipM2
	lea	Ttt_IOn(pc),a2		Passe en inverse
.loopM2	move.b	(a2)+,(a0)+
	bne.s	.loopM2
	subq.l	#1,a0
	bset	#7,8(sp)
.skipM2	cmp.w	Tt_X2Mark(a4),d2
	bne.s	.skipM3
	lea	Ttt_IOff(pc),a2		Retour en normal
.loopM3	move.b	(a2)+,(a0)+
	bne.s	.loopM3
	subq.l	#1,a0
.skipM3
	cmp.w	Tt_YInfo(a4),d3
	bne.s	.skipM5
	cmp.w	Tt_X1Info(a4),d2
	bne.s	.skipM4
	lea	Ttt_InOn(pc),a2		Souligne
.loopM4	move.b	(a2)+,(a0)+
	bne.s	.loopM4
	subq.l	#1,a0
	bset	#7,8(sp)
.skipM4	cmp.w	Tt_X2Info(a4),d2
	bne.s	.skipM5
	lea	Ttt_InOff(pc),a2	Retour en normal
.loopM5	move.b	(a2)+,(a0)+
	bne.s	.loopM5
	subq.l	#1,a0
.skipM5
	addq.w	#1,d2
	move.b	(a1)+,(a0)+
	bne.s	.LoopM
	move.l	Buffer(a5),a1
	movem.l	(sp)+,a2/d2
.skipM
; Impression
	WiCall	Print			Imprime
	move.b	d2,(a2)			Restore la ligne

; Repasse en normal
.skipX	move.l	(sp)+,d2
	bpl.s	.skip8
	WiCalA	Print,Ttt_IOff(pc)
	WiCalA	Print,Ttt_InOff(pc)
; Efface ---> fin ligne
.skip8	btst	#30,d2
	beq.s	.skip9
	WiCalD	ChrOut,7
.skip9
	movem.l	(sp)+,d0-d4/a0-a3
	rts


; ___________________________________________________________________
;
;	ECRAN DU BAS
; ___________________________________________________________________


;	TOUCHE: separation Listing / Infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Separ
	bsr	XYMouEc
	move.w	Ttt_Tlh(a4),d0
	lsl.w	#3,d0
	addq.w	#8,d0
	sub.w	d0,d2
	move.w	d2,-(sp)		Decalage souris/bloc
	move.w	d0,-(sp)		Ancien bloc
	move.w	d0,-(sp)		Nouveau bloc
; Fabrique le bloc dessin
	moveq	#0,d2
	move.w	(sp),d3
	subq.w	#1,d3
	ext.l	d3
	move.l	#640,d4
	moveq	#5,d5
	moveq	#0,d6
	move.l	Buffer(a5),a1
	EcCalD	BlGet,126
.Loop0
; Fabrique le bloc effacement
	moveq	#0,d2
	move.w	(sp),d3
	subq.w	#1,d3
	ext.l	d3
	move.l	#640,d4
	moveq	#5,d5
	moveq	#0,d6
	move.l	Buffer(a5),a1
	EcCalD	BlGet,127
	move.w	(sp),2(sp)
; Dessine l'image
	moveq	#0,d2
	move.w	(sp),d3
	subq.w	#1,d3
	ext.l	d3
	move.l	#EntNul,d4
	move.l	d4,d5
	move.l	Buffer(a5),a1
	EcCalD	BlPut,126
; Prend la souris
.Loop1	bsr	Tt_Multi
	bsr	Tt_MBout
	btst	#0,d1
	beq.s	.Skip
	bsr	XYMouEc
	sub.w	4(sp),d2
	cmp.w	(sp),d2
	beq.s	.Loop1
	cmp.w	#16,d2
	bcs.s	.Loop1
	move.w	Ttt_Sy(a4),d0
	sub.w	#16-4,d0
	cmp.w	d0,d2
	bcc.s	.Loop1
	move.w	d2,(sp)
; Efface l'ancien
.Skip	moveq	#0,d2
	move.w	2(sp),d3
	subq.w	#1,d3
	ext.l	d3
	move.l	#EntNul,d4
	move.l	d4,d5
	move.l	Buffer(a5),a1
	EcCalD	BlPut,127
; Lache la souris?
	bsr	Tt_MBout
	btst	#0,d1
	bne	.Loop0
; Efface les blocs
	EcCalD	BlDel,127
	EcCalD	BlDel,126
; Change la position du milieu...
	move.w	(sp),d0
	bsr	Ttt_SetSize
	addq.l	#6,sp
; Va redessinner les textes
	bsr	Ttt_Cls
	bsr	Ttt_NewBuf
; Recentre les infos?
Inf_Centre
	bsr	Inf_CptLines
	move.w	Inf_YPos(a4),d0
	add.w	Ttt_Tlb(a4),d0
	move.w	Inf_NLigne(a4),d1
	cmp.w	d0,d1
	bcc.s	.sss
	sub.w	d1,d0
	sub.w	d0,Inf_YPos(a4)
	bpl.s	.sss
	clr.w	Inf_YPos(a4)
.sss	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider
	rts


; 	Effacement / Redessin de l'ecran de texte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Cls
; Efface les fenetres
	WiCalD	QWindow,1
	WiCall	WinDel
	WiCalD	QWindow,2
	WiCall	WinDel
; Dessin du fond avec le DBL
	move.l	Tt_Variables(a4),a0
	move.w	Ttt_Tlh(a4),2(a0)		0VA= Ty programmes
	move.w	Ttt_Tlb(a4),6(a0)		1VA= Ty infos
	move.w	Prg_NLigne(a3),10(a0)		2VA= NLignes programme
	clr.w	14(a0)				3VA= NLignes infos
	move.l	#Tt_ChannelN,d0
	moveq	#-1,d1
	moveq	#0,d2
	moveq	#0,d3
	JJsrR	L_Dia_RunProgram,a1
	tst.l	d0
	bne	.OutM
; Initialise la zone du haut
	SyCalD	RazZone,1
	moveq	#0,d2
	move.w	#8,d3
	move.w	#640-16,d4
	move.w	Ttt_Tlh(a4),d5
	lsl.w	#3,d5
	addq.w	#8,d5
	move.w	d5,d7
	SyCalD	SetZone,1
; La zone du milieu
	SyCalD	RazZone,2
	moveq	#0,d2
	move.w	d7,d3
	move.w	#640,d4
	addq.w	#4,d7
	move.w	d7,d5
	SyCalD	SetZone,2
; La zone du bas
	SyCalD	RazZone,3
	moveq	#0,d2
	move.w	d7,d3
	move.w	#640-16,d4
	move.w	Ttt_Sy(a4),d5
	subq.w	#8,d5
	SyCalD	SetZone,3
; Ouvre les fenetres
	moveq	#0,d2
	moveq	#7,d3
	moveq	#E2_Sx/8-2,d4
	move.w	Ttt_Tlh(a4),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCalD	WindOp,1
	bne.s	.OutM
	WiCalA	Print,Ttt_WInit(pc)
	moveq	#0,d2
	move.w	Ttt_Tlh(a4),d3
	lsl.w	#3,d3
	add.w	#7+5,d3
	moveq	#E2_Sx/8-2,d4
	move.w	Ttt_Tlb(a4),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCalD	WindOp,2
	bne.s	.OutM
	WiCalA	Print,Ttt_WInit(pc)
	moveq	#0,d0
	rts
.OutM	moveq	#1,d0
	rts

;	Fixe les tailles de l'ecran de listing
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_SetSize
	subq.w	#8,d0
	lsr.w	#3,d0
	move.w	d0,Ttt_Tlh(a4)
	move.w	Ttt_Sy(a4),d1
	sub.w	#16,d1
	lsr.w	#3,d1
	sub.w	d0,d1
	move.w	d1,Ttt_Tlb(a4)
	rts

;	Active l'ecran / la fenetre infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_InfAct
	bsr	Ttt_Act
	WiCalD	QWindow,2
	rts
;	Active l'ecran / la fenetre ttt
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_TttAct
	bsr	Ttt_Act
	WiCalD	QWindow,1
	rts

; ___________________________________________________________________
;
;	PAS A PAS / PATCH BASIC
; ___________________________________________________________________



;	TOUCHES: help / break / eval
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_SHelp
	clr.w	Ttt_Mode(a4)
	bra.s	Ttt_AMod
Tt_SBreak
	move.w	#1,Ttt_Mode(a4)
	bra.s	Ttt_AMod
Tt_SEval
	move.w	#2,Ttt_Mode(a4)
; Affiche les boutons
Ttt_AMod
	moveq	#14,d0
	moveq	#0,d2
.loop	moveq	#0,d1
	cmp.w	Ttt_Mode(a4),d2
	bne.s	.skip
	moveq	#-1,d1
.skip	bsr	ABouton
	addq.w	#1,d0
	addq.w	#1,d2
	cmp.w	#3,d2
	bne.s	.loop
	moveq	#-1,d0
	rts

;	TOUCHE: une instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Step0
	bsr	Wmky
	tst.w	Tt_Init(a4)
	ble.s	NoInit
	bra	Step_Out
NoInit	moveq	#11,d0
	bsr	Tt_Message
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bra	Wmky
;	TOUCHE: deroulement semi-rapide
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Step1
	bsr	Wmky
	tst.w	Tt_Init(a4)
	ble.s	NoInit
	move.w	#1,Step_Mode(a4)
	bra	Step_Out
;	TOUCHE: deroulement rapide
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Step2
	bsr	Wmky
	tst.w	Tt_Init(a4)
	ble.s	NoInit
	move.w	#2,Step_Mode(a4)
	bra	Step_Out
;	TOUCHE: deroulement ultra-rapide
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Step3
	bsr	Wmky
	tst.w	Tt_Init(a4)
	ble.s	NoInit
	bsr	Tt_Hide
	move.w	#3,Step_Mode(a4)
	bra	Step_Out2

;	TOUCHE:	Init
; ~~~~~~~~~~~~~~~~~~
Tt_Initialise
	tst.w	Tt_Init(a4)		Arrete?
	ble.s	Tt_ReInit
	move.w	ActuMask(a5),d0		En marche, Break-Off mode?
	btst	#BitControl,d0
	beq.s	Tt_Noq
; Stoppe le programme
	move.w	#1003,d0		Erreur 1003= moniteur!
	JJmp	L_Error
; Fait l'initialisation!
Tt_ReInit
	clr.l	Step_Mess(a4)
	clr.w	Tt_Init(a4)
	moveq	#1,d0			Message d'info
	bsr	Inf_Del
	moveq	#3,d0
	bsr	Inf_Del
	moveq	#12,d0			Testing program
	bsr	Tt_Message
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider
; Lance le programme
	bsr	Tt_PrgBanks
	moveq	#0,d0			Programme normal
	lea	Tt_Error(pc),a1		Adresse routine d'erreur
	lea	Tt_Testing(pc),a2	Messages
	move.l	Tt_Program(a4),a6	Structure programme
	JJsr	L_Prg_RunIt		Lance le programme!
; Out of memory, si revient
	moveq	#17,d0
	bra.s	Tt_IMes
; No break mode
Tt_Noq	moveq	#16,d0			No initialise mode!
Tt_IMes	bsr	Tt_Message
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bra	Inf_AffAll

; Branchement aux messages de testing
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Testing
	bra	Tt_Tst1
	bra	Tt_Tst2
	bra	Tt_Tst3
; Enleve le message de test
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Tst1	rts
Tt_Tst2	movem.l	a0-a6/d0-d7,-(sp)
	move.l	Mon_Base(a5),a4
	move.l	Tt_Program(a4),a3
	bsr	Tt_TtBanks
; Efface le message
	bsr	Ttt_AlertDel
; Passe aux ecrans du programme
	move.w	#-1,Tt_Ecran(a4)
	clr.w	Tt_MFlag(a4)
	move.w	#1,Tt_Init(a4)
; Revient au test
	bsr	Tt_PrgBanks
	movem.l	(sp)+,a0-a6/d0-d7
	rts
Tt_Tst3	rts

;	Entree du pas a pas...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MonitorChr
	move.l	-LB_Size(a4,d1.w),-(sp)	Adresse de l'instruction
	cmp.w	#_TkDP,-2(a6)		Pas sur un :
	beq	.Back			RTS direct
	lea	-2(a6),a1
	move.l	d0,d4			Sauve les adresses importantes
	move.l	d1,d5
; Mode RAPIDE, saute tout sauf si breakpoint...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d2			Pas STOP!
	move.l	Mon_Base(a5),a0
	cmp.w	#2,Step_Mode(a0)
	bcs.s	.skipB
	bne.s	.skip
	bset	#1,T_Actualise+1(a5)
.skip	tst.w	Step_Stop(a0)
	bne.s	.skipA
	cmp.l	Step_Break(a0),a1
	bne.s	.GoBack
.skipA	clr.w	Step_Mode(a0)
	moveq	#-1,d2
; Mode LENT, avec affichage...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.skipB	tst.w	Tt_Init(a0)
	beq	.skippy
	bmi.s	.skipB0
	bclr	#BitControl,T_Actualise(a5)	Control-C a chaque coup!
	bne.s	.skipB0
	tst.w	Step_Stop(a0)
	bne.s	.skipB0
	cmp.l	Step_Break(a0),a1
	bne.s	.skipB1
	exg	a0,a1				Break message
	moveq	#10,d0
	bsr	Tt_Message
	exg	a0,a1
	move.l	a1,Step_Mess(a0)
.skipB0	clr.l	Step_Break(a0)
	clr.w	Step_Mode(a0)
	clr.w	Step_Stop(a0)
	moveq	#-1,d2
	bra.s	.skipB2
.skipB1	cmp.w	#_TkEndP,-2(a6)			Fin de procedure?
	bne.s	.skipB2
	bsr	TstPatch			Reaffiche + sort
	bra.s	.GoBack
; Rebranche � l'instruction
.GoOut	bset	#1,T_Actualise+1(a5)		Reaffichage si long...
	bset	#1,ActuMask+1(a5)
.GoBack	move.l	d4,d0				Recharge les registres
	move.l	d5,d1
.Back	rts					Rebranche � l'instruction
; Localise l'instruction
.skipB2	move.l	Prg_Run(a5),a1
	move.l	d7,a0				Adresse de la ligne
	tst.l	d7
	beq.s	.GoBack
	JJsrR	L_Tk_FindA,a2
	tst.w	d2				Arret force?
	bne.s	.stopit
	tst.l	d1				Procedure fermee?
	bne.s	.GoOut
.stopit	tst.l	d1				Procedure fermee?
	bne.s	.lockee
	move.l	a6,d1
	subq.l	#2,d1
	moveq	#0,d2
	bra.s	.nolock
.lockee	addq.l	#2,d1
	moveq	#-1,d2
; Poke les adresses
.nolock	move.l	a0,a2
.skippy	move.l	Mon_Base(a5),a0
	lea	Step_Data(a0),a0	Stockage des donnees
	move.l	(sp),(a0)+		Adresse de retour
	movem.l	a3-a6/d4-d5/d6-d7,(a0)	Registres importants
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.l	Mon_Base(a5),a4		Sauve la pile / Flag general
	move.l	Tt_Program(a4),a3
	bsr	Tt_TtBanks
	move.w	d0,Tt_YNext(a4)
	move.l	d1,Tt_Adress(a4)
	move.w	d2,Tt_Locked(a4)
	move.l	a2,Tt_DCurLine(a4)
; Empeche les appels du test
	bclr	#1,T_Actualise+1(a5)
	bclr	#1,ActuMask+1(a5)
	clr.w	Step_Stop(a4)
; Actualise l'affichage
	move.w	#-1,Tt_Ecran(a4)
	bsr	View_Act
	bsr	View_Aff
	bsr	Tt_Show

;	Affichage complet de la prochaine instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	bsr	Inf_Del
	moveq	#5,d0
	bsr	Inf_Del
; Programme initialise?
	tst.w	Tt_Init(a4)
	beq	.nopar
; Pointe dans le programme
	move.w	Tt_YNext(a4),d0
	bsr	Tt_Decoup
	move.l	Tt_Adress(a4),a0
	sub.l	Tt_ALine(a4),a0
	move.l	Tt_Ligne(a4),a1
	subq.l	#4,a1
.loop	addq.l	#4,a1
	cmp.w	2(a1),a0
	bhi.s	.loop
	moveq	#0,d0
	move.b	1(a1),d0
	move.w	d0,Tt_XNext(a4)
	bsr	Ttt_TttAct
	bsr	Ttt_Centre
	bsr	Ttt_AffBuf
; Fin du programme?
	tst.w	Tt_Init(a4)
	bmi	.nopar
; Affiche le NOM de l'instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#5,d0
	bsr	Inf_PrDeb
; Procedure fermee
	tst.w	Tt_Locked(a4)
	beq.s	.palok
	moveq	#2,d0
	bsr	Tt_Message
	bsr	Inf_Print
	move.l	Tt_BufT(a4),a0
	move.b	1(a0),d0
	addq.l	#2,a0
	clr.b	0(a0,d0.w)
	bsr	Inf_Print
	bsr	Inf_PrFin
	bra	.nopar
; Met le nom
.palok	moveq	#1,d0
	bsr	Tt_Message
	bsr	Inf_Print
	move.l	Tt_Ligne(a4),a2
	move.l	Tt_Adress(a4),d0
	sub.l	Tt_ALine(a4),d0
.loopA2	cmp.w	2(a2),d0
	beq.s	.outA2
	addq.l	#4,a2
	tst.b	(a2)
	bne.s	.loopA2
.outA2	moveq	#0,d0
	move.b	1(a2),d0
.loopA3	addq.l	#4,a2
	tst.b	(a2)
	beq.s	.outA3
	cmp.b	#":",(a2)
	bne.s	.loopA3
.outA3	moveq	#0,d1
	move.b	1(a2),d1
	move.l	Tt_BufT(a4),a0
	addq.l	#2,a0
	clr.b	0(a0,d1.w)
	add.w	d0,a0
	bsr	Inf_Print
	bsr	Inf_PrFin
; Affiche la liste des parametres
	move.l	AdTokens(a5),a0
	move.l	Tt_Adress(a4),a6
	move.w	(a6)+,d0
	lea	4(a0,d0.w),a3
	moveq	#0,d7
	cmp.w	#_TkRem1,d0
	beq	.nopar
	cmp.w	#_TkRem2,d0
	beq	.nopar
	cmp.w	#_TkFade,d0
	beq	.fade
	cmp.w	#_TkPal,d0
	beq	.fade
	cmp.w	#_TkExt,d0
	bne.s	.noext
; Appel d'une extension
	move.b	(a6)+,d1
	move.b	(a6)+,d0
	move.w	(a6)+,d2
	ext.w	d1
	lsl.w	#2,d1
	move.l	AdTokens(a5,d1.w),a0
	lea	4(a0,d2.w),a3
.noext
	btst	#LBF_20,LB_Flags(a0)		Une nouvelle librarie?
	beq.s	.floop1
	tst.w	-2(a3)				Des parametres?
	beq.s	.nopar
.floop1	tst.b	(a3)+
	bpl.s	.floop1
	move.b	(a3)+,d0
	cmp.b	#"I",d0
	bne	.nopar
.floop2	tst.b	(a3)+
	bmi	.nopar
	bsr	Tt_ImpParam
	tst.b	(a3)+
	bpl	.floop2
	bra.s	.nopar
; FADE / PALETTE
.fade	bsr	Tt_ImpParam
	subq.l	#2,a6
	JJsr	L_Finie
	addq.l	#2,a6
	bne.s	.fade
.nopar
; Afficher un message???
	move.l	Step_Mess(a4),d0
	beq.s	.jij
	clr.l	Step_Mess(a4)
	move.l	d0,a0
	bsr	Ttt_Alert
.jij
; Va tout imprimer...
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider

;	Attente de commande
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	View_Act
	move.w	Step_Mode(a4),d0
; Pas a pas: libere le bouton, et branche aux tests
	bne.s	.skiu
	bsr	Tt_Mouse
	bra	Tt_ReLoop
; Deroulement semi-rapide: appui sur STOP?
.skiu	bsr	Tt_MBout
	btst	#0,d1
	beq.s	Step_Out
	SyCall	GetZone
	cmp.w	#Tt_Ecran1,d1
	bne.s	Step_Out
	swap	d1
	tst.w	d1
	beq.s	Step_Out
	cmp.w	#13,d1
	beq.s	Step_Out
	bsr	Tt_Mouse
	clr.w	Step_Mode(a4)
	bsr	View_Act
	bsr	BoutStop
	moveq	#10,d2
.Loap	SyCall	WaitVbl
	dbra	d2,.Loap
	bra	Tt_ReLoop

;	Sortie du mode pas a pas, reactive l'ancien ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Step_Out
	bset	#1,T_Actualise+1(a5)
	bset	#1,ActuMask+1(a5)
Step_Out2
	bsr	Tt_PrgBanks
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	move.w	ScOn(a5),d1
	beq.s	.Skip
	subq.w	#1,d1
	EcCall	Active
.Skip

	IFNE	Debug=2
	tst.w	Ttt_Mode(a4)			*** Illegal, debugging!
	bne.s	.Skip2
	JJsr	L_BugBug
.Skip2
	ENDC

	move.l	Step_Data(a4),a0
	movem.l	Step_Data+4(a4),a3-a6/d0-d1/d6-d7
	jmp	(a0)

;	Routine : Imprime "Param #1="
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_ImpParam
	moveq	#5,d0
	bsr	Inf_PrDeb
	moveq	#3,d0
	bsr	Tt_Message
	bsr	Inf_Print
	addq.l	#1,d7
	move.l	d7,d0
	move.l	Buffer(a5),a0
	JJsrR	L_LongToDec,a1
	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	Inf_Print
	lea	Inf_Par2(pc),a0
	bsr	Inf_Print
; Va evaluer...
	bsr	Tt_Evalue
	beq.s	.paer
	moveq	#4,d0
	bsr	Tt_Message
.parer	move.b	(a1)+,(a0)+
	bne.s	.parer
	subq.l	#1,a0
	bra.s	.suit
.paer	addq.l	#2,a6
	move.l	d3,d0
	move.l	Buffer(a5),a0
	subq.b	#1,d2
	bmi.s	.ent
	beq.s	.fl
; Une chaine...
	moveq	#'"',d2
	move.b	d2,(a0)+
	move.l	d0,a1
	move.w	(a1)+,d0
	beq.s	.Bla
	cmp.w	#60,d0
	bcs.s	.Ble
	moveq	#60,d0
	moveq	#">",d2
.Ble	subq.w	#1,d0
.Bli	move.b	(a1)+,d1
	cmp.b	#32,d1
	bcc.s	.Blo
	moveq	#".",d1
.Blo	move.b	d1,(a0)+
	dbra	d0,.Bli
.Bla	move.b	d2,(a0)+
	bra.s	.suit
; Chiffre FLOAT
.fl	JJsrR	L_Float2Ascii,a1
	bra.s	.suit
; Chiffre ENTIER
.ent	cmp.l	#EntNul,d3
	beq.s	.entD
	JJsrR	L_LongToDec,a1
	bra.s	.suit
.entD	exg	a0,a1
	moveq	#14,d0
	bsr	Tt_Message
	exg	a0,a1
.entE	move.b	(a1)+,(a0)+
	bne.s	.entE
 	subq.l	#1,a0
; Imprime
.suit	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	Inf_Print
	bsr	Inf_PrFin
	rts

;	Entree generale des erreurs "Patch2"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Error
	move.l	BasSp(a5),sp
	move.l	Prg_InsRet(a5),-(sp)
	bsr	Tt_GetTheMessage
	move.l	Mon_Base(a5),a1
	tst.w	Tt_Init(a1)
	beq.s	.Test
; Erreur lors de RUN
; ~~~~~~~~~~~~~~~~~~
	move.w	d2,d3
	move.l	a0,d1			Si EDIT ou DIRECT
	bne.s	.Mh
	moveq	#15,d0
	bsr	Tt_Message
.Mh	move.w	d0,d1
	move.l	a0,Step_Mess(a1)
	move.l	d7,a6
	move.l	PLoop(a5),a3
	move.w	-2(a6),d0
	move.w	0(a4,d0.w),d1		Pointe la table de tokens
	bsr	Tt_Show
	clr.w	Step_Mode(a1)
	cmp.w	#9,d3			Control-C?
	beq	MonitorChr
	cmp.w	#1003,d3		INIT
	beq	Tt_ReInit
	move.w	#-1,Tt_Init(a1)		Arret du STEP, pas des expressions
	bra	MonitorChr
; Erreurs lors du test!
; ~~~~~~~~~~~~~~~~~~~~~
.Test	move.l	a0,-(sp)
	move.l	Mon_Base(a5),a4
	move.l	Tt_Program(a4),a3
	bsr	Tt_TtBanks
	clr.w	Tt_XNext(a4)
	move.l	VerPos(a5),a0
	move.l	Prg_StBas(a3),a1
	JJsrR	L_Tk_FindA,a2
	move.w	d0,Tt_YNext(a4)

	move.w	#-1,Tt_Ecran(a4)
	bsr	Ttt_TttAct
	bsr	Ttt_Centre
 	bsr	Ttt_AffBuf

	move.l	(sp)+,a0
	bsr	Ttt_Alert
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider

	bra	Tt_ReLoop

; Trouve le message d'erreur en retour de programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_GetTheMessage
	move.l	a1,-(sp)
	move.w	d0,d2
	move.l	a0,d1
	bne.s	.Clair
	cmp.w	#256,d0			Un message?
	bge.s	.Clair
	move.l	Ed_TstMessages(a5),a0	Message testing
	neg.w	d0
	bpl.s	.MTest
	neg.w	d0
	move.l	Ed_RunMessages(a5),a0
	addq.w	#1,d0
.MTest	JJsrR	L_GetMessage,a1
.Clair	move.l	(sp)+,a1
	rts

;	Clique dans le texte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_ListClic
	bsr	Tt_MouMou
	cmp.w	Prg_NLigne(a3),d2
	bcc	.out

; Regarde le mode courant
	cmp.w	#2,Tt_MKey(a4)		Bouton droit>>> short cut
	beq.s	.Break
	move.w	Ttt_Mode(a4),d0
	subq.w	#1,d0
	bmi	Tt_RunHelp
	beq.s	.Break
	bne	.Eval

;	Fixe le breakpoint
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Break	move.w	#-1,Tt_YMark(a4)
	clr.l	Step_Break(a4)
	move.w	d2,d0
	bsr	Tt_Decoup
	move.l	Tt_Ligne(a4),a0
	move.b	(a0),d0
	beq.s	.out
	cmp.b	1(a0),d1
	bcs.s	.out
	move.l	a0,a1
.loop1	addq.l	#4,a0
	move.b	(a0),d0
	beq.s	.skip2
	cmp.b	#":",d0
	beq.s	.skip1
	cmp.b	#"W",d0
	beq.s	.skip1
	cmp.b	#"X",d0
	beq.s	.skip1
	cmp.b	#"I",d0
	bne.s	.loop1
.skip1	cmp.b	1(a0),d1
	bcs.s	.found
	move.l	a0,a1
	bra.s	.loop1
.skip2	cmp.b	1(a0),d1
	bcc.s	.out
.found	cmp.l	a0,a1
	beq.s	.out
	cmp.b	#":",(a1)
	beq.s	.out
; OK, on pointe une instruction!!!
	move.w	d2,Tt_YMark(a4)
	moveq	#0,d0
	move.b	1(a1),d0
	move.w	d0,Tt_X1Mark(a4)
	move.b	1(a0),d0
	move.w	d0,Tt_X2Mark(a4)
; Marque le breakpoint!
	move.l	Tt_ALine(a4),a2
	add.w	2(a1),a2
	move.l	a2,Step_Break(a4)
; Provoque un reaffichage de l'ecran
.out	bsr	Ttt_AffBuf
	bra	Wmky

;	On veut evaluer une expression...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Eval	bsr	Tt_Souligne
	beq	.paexp
; Test ASCII de la ligne
	move.l	a0,a1
	move.w	d0,d3
	subq.w	#1,d3
	moveq	#0,d4
	moveq	#0,d5
.chk	move.b	(a1)+,d6
	cmp.b	#"(",d6
	bne.s	.chk2
	addq.w	#1,d4
.chk2	cmp.b	#")",d6
	bne.s	.chk3
	subq.w	#1,d4
.chk3	cmp.b	#'"',d6
	bne.s	.chk4
	addq.w	#1,d5
.chk4	dbra	d3,.chk
	tst.w	d4
	bne	.paexp
	btst	#0,d4
	bne	.paexp
; Decoupe la ligne en bouts...
	move.w	d2,d0
	bsr	Tt_Decoup
	move.l	Tt_Ligne(a4),a0
	move.b	(a0),d0
	beq	.paexp
	cmp.b	1(a0),d1
	bcs	.paexp
; Trouve le debut
.eloop1	move.l	a0,a1
	cmp.b	1(a1),d1
	beq.s	.eout1
	addq.l	#4,a0
	cmp.b	1(a0),d1
	bcs.s	.eout1
	tst.b	(a0)
	bne.s	.eloop1
	bra	.paexp
; Trouve la fin
.eout1	move.w	Tt_X2Info(a4),d0
	move.l	a1,a2
.eloop2	addq.l	#4,a2
	tst.b	(a2)
	beq.s	.eout2
	cmp.b	1(a2),d0
	bhi.s	.eloop2
; Que pointe thon?
.eout2	move.b	(a1),d0
	cmp.b	#":",d0
	beq	.paexp
	cmp.b	#"W",d0
	beq	.paexp
	cmp.b	#":",-4(a1)
	beq	.paexp
	tst.w	Tt_Init(a4)
	beq	NoInit
	cmp.b	#"-",d0
	beq.s	.exp1
	cmp.b	#"V",d0
	beq.s	.exp1
	cmp.b	#"0",d0
	bcs	.paexp
	cmp.b	#"2",d0
	bhi	.paexp
; Recopie dans le buffer tokenisation
.exp1	move.l	Tt_BufT(a4),a3
	move.l	Tt_ALine(a4),a0
; Un GLOBAL ou un SHARED
	cmp.w	#_TkGlo,2(a0)
	beq	.paexp
	cmp.w	#_TkSha,2(a0)
	beq	.paexp
	add.w	2(a2),a0
	move.l	a0,a2
	move.l	Tt_ALine(a4),a0
	add.w	2(a1),a0
.lp1	move.w	(a0)+,(a3)+
	cmp.l	a2,a0
	bcs.s	.lp1
	cmp.w	#_TkPar1,(a0)
	beq	.paexp
	clr.w	(a3)+
	move.l	Tt_BufT(a4),a0
	sub.l	a0,a3
	move.l	a3,d7
; Meme niveau de procedure?
	move.l	Tt_DCurLine(a4),a2
	move.l	Tt_ALine(a4),a3
	cmp.l	a2,a3
	bcc.s	.pro1
	exg	a2,a3
.pro1	cmp.l	a3,a2
	bhi.s	.pro2
	move.w	2(a2),d0
	cmp.w	#_TkProc,d0
	beq.s	.paniv
	cmp.w	#_TkEndP,d0
	beq.s	.paniv
	moveq	#0,d0
	move.b	(a2),d0
	lsl.w	#1,d0
	add.w	d0,a2
	bra.s	.pro1
; Au debut de quelque chose de possible...
.pro2	move.l	Inf_Buf(a4),a0
	move.l	Inf_Pos(a4),d0
	sub.l	a0,d0
	cmp.l	#Inf_Size-Inf_Size/3,d0
	bcc	.2many
	move.l	Tt_BufT(a4),a6
	bsr	Tt_Evalue
	bne.s	.paexp
	move.w	d7,d0			* Insere l'expression dans la liste
	add.w	#12,d0
	bsr	Inf_Ins
	move.w	#3,(a0)+
	move.w	#-1,(a0)+
	move.l	BasA3(a5),(a0)+
	move.l	Tt_BufT(a4),a1
.pro3	move.w	(a1)+,(a0)+
	subq.w	#2,d7
	bne.s	.pro3
; Va imprimer, et revient
.expout	move.l	Tt_Program(a4),a3
	move.w	#-1,Tt_YInfo(a4)
	bsr	Ttt_AffBuf
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider
	rts
; Cannot evaluate!
.paexp	move.w	#-1,Tt_YInfo(a4)
	moveq	#8,d0
	bsr	Tt_Message
	bsr	Ttt_Alert
	bra	.expout
; Erreur: pas meme niveau
.paniv	moveq	#6,d0
	bsr	Tt_Message
	bsr	Ttt_Alert
	bra.s	.expout
; Too many expresions
.2many	moveq	#9,d0
	bsr	Tt_Message
	bsr	Ttt_Alert
	bra.s	.expout

;	Routine, ouverture d'un souligne sur la ligne courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Souligne
	mulu	#256,d4
	move.l	Ttt_BufE(a4),a0
	add.w	d4,a0
	cmp.w	(a0),d1
	bcc.s	.SNon
	move.w	d1,Tt_X1Info(a4)
	addq.w	#1,d1
	move.w	d1,Tt_X2Info(a4)
	move.w	d2,Tt_YInfo(a4)
	move.l	a0,-(sp)
	bsr	Ttt_AffBuf
.Sloop	bsr	Tt_Multi
	bsr	Tt_MBout
	btst	#0,d1
	beq.s	.Sout
	bsr	Tt_MouMou
	addq.w	#1,d1
	cmp.w	Tt_X1Info(a4),d1
	bls.s	.Sloop
	move.l	(sp),a0
	cmp.w	(a0),d1
	bhi.s	.Sloop
	move.w	d1,Tt_X2Info(a4)
	moveq	#0,d1
	move.w	Tt_YInfo(a4),d1
	sub.w	Ttt_YPos(a4),d1
	bsr	Ttt_EALigne
	bra.s	.Sloop
; Retour, A0 pointe la chaine...
.Sout	move.l	(sp)+,a0
	move.w	Tt_YInfo(a4),d2
	move.w	Tt_X1Info(a4),d1
	move.w	Tt_X2Info(a4),d0
	lea	2(a0,d1.w),a0
	sub.w	d1,d0
	bls.s	.SNon
	rts
; Rien!
.SNon	moveq	#0,d0
	rts

; Coordonnee de la souris
; ~~~~~~~~~~~~~~~~~~~~~~~
Tt_MouMou
	bsr	XYMouEc
	subq.w	#8,d2
	lsr.w	#3,d1
	lsr.w	#3,d2
	move.w	d2,d4
	add.w	Ttt_XPos(a4),d1
	add.w	Ttt_YPos(a4),d2
	cmp.w	Tt_YNext(a4),d2
	bne.s	.mou2
	move.w	Tt_XNext(a4),d0
	cmp.w	d0,d1
	bcs.s	.mou2
	addq.w	#3,d0
	sub.w	d1,d0
	bls.s	.mou1
	sub.w	d0,d1
	rts
.mou1	subq.w	#3,d1
.mou2	rts


;	Demande de HELP sur un mot...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_RunHelp
	bsr	Tt_Souligne
	beq	Wmky
	cmp.w	#2,d0
	bcs	.NFnd
; Copie la chaine dans le buffer
	move.l	Buffer(a5),a1
	move.l	a1,d0
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
	move.l	d0,a0
	sub.l	a1,d0
	neg.l	d0
; Charge les fichiers .MAP
; ~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	a0/d0,-(sp)
	moveq	#20,d0			Loading Help files
	bsr	Tt_IMes
	movem.l	(sp)+,a0/d0
	bsr	Hlp_LoadTexte		Une erreur!
	bne	.Error
	bsr	Ttt_AlertDel		Plus d'alertes
; Ouverture de l'ecran
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d7
	bsr	Hlp_GetPuzzle
	move.l	a1,a0
	moveq	#EcFsel,d0
	move.w	PI_RtSx(a5),d1
	move.w	PI_RtSy(a5),d2
	ext.l	d1
	ext.l	d2
	moveq	#0,d3
	moveq	#-1,d4
	JJsrP	L_Dia_RScOpen,a2
	bne	.OutM
; Trouve le bon numero de canal dialogue
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#65536,d7
.Find	move.l	d7,d0
	JJsr	L_Dia_GetChannel
	beq.s	.Ok
	addq.l	#1,d7
	bra.s	.Find
; Appel du DBL
; ~~~~~~~~~~~~
.Ok	bsr	Hlp_GetPuzzle
	add.l	2+0(a0),a0		Programme numero 1
	move.l	d7,d0
	move.l	#1024*8,d1		Longueur du bufer
	moveq	#8,d2			Variables internes
	moveq	#0,d3			Pas de recopie
	JJsrR	L_Dia_OpenChannel,a2
	bne	.OutM
	moveq	#23,d0
	bsr	Tt_Message
	subq.l	#2,a0
	move.l	a0,4(a1)		Message de titre
	move.l	#4,8(a1)		4 Boutons par ligne
	move.l	Hlp_Texte(a4),0(a1)	Base de l'hyper texte
; Demarre le programme
; ~~~~~~~~~~~~~~~~~~~~
	move.l	d7,d0
	moveq	#-1,d1
	moveq	#0,d2
	moveq	#0,d3
	JJsr	L_Dia_RunProgram
	tst.l	d0
	bne	.OutM
; Ouverture de l'ecran
; ~~~~~~~~~~~~~~~~~~~~
	move.l	d7,-(sp)
	move.l	T_EcAdr+EcFsel*4(a5),a2
	move.w	PI_RtSpeed(a5),d7
	moveq	#1,d6
	move.w	PI_RtWy(a5),d5
	move.w	PI_RtSy(a5),d0
	lsr.w	#1,d0
	add.w	d0,d5
	JJsr	L_AppCentre
	move.l	(sp)+,d7
; Animation de l'ecran, uniquement READ TEXT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Lop	move.l	d7,-(sp)
	JJsr	L_Sys_WaitMul
	JJsr	L_Test_PaSaut
	move.l	(sp)+,d7
	move.l	d7,d0
	JJsr	L_Dia_GetReturn
	bne.s	.OutM
	tst.l	d1
	bpl.s	.Lop
	moveq	#0,d0
	bra.s	.Quit
; Fermeture du canal
; ~~~~~~~~~~~~~~~~~~
.OutM	moveq	#17,d0
.Quit	move.l	d0,-(sp)
	move.l	d7,d0
	beq.s	.Skk
	JJsr	L_Dia_CloseChannel
; Fermeture de l'ecran
; ~~~~~~~~~~~~~~~~~~~~
.Skk	move.l	T_EcAdr+EcFsel*4(a5),a2
	tst.l	(a2)
	beq.s	.Skkk
	move.w	PI_RtSpeed(a5),d7
	neg.w	d7
	move.w	EcTy(a2),d6
	lsr.w	#1,d6
	move.w	EcAWY(a2),d5
	add.w	d6,d5
	JJsr	L_AppCentre
	EcCalD	Del,EcFsel
; La fin...
; ~~~~~~~~~
.Skkk	bsr	Hlp_FreeTexte
	move.l	(sp)+,d0
	beq.s	.Fin
.Error	bsr	Tt_Message
	bsr	Ttt_Alert
.Fin	move.l	Tt_Program(a4),a3
	move.w	#-1,Tt_Ecran(a4)
	move.w	#-1,Tt_YInfo(a4)
	bsr	Ttt_TttAct
	bsr	Ttt_AffBuf
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider
	rts
.NFnd	moveq	#21,d0
	bra.s	.Error

; 	Get default resource bank
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hlp_GetPuzzle
	move.l	Sys_Resource(a5),a0
	move.l	a0,a1
	add.l	2+0(a0),a1		Base des graphiques
	move.l	a0,a2
	add.l	2+4(a0),a2		Base des messages
	add.l	2+8(a0),a0		Base des programmes
	rts



;	Charge la partie de texte HELP dans un buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0/D0	Nom � rechercher
Hlp_LoadTexte
	movem.l	d2-d7/a2-a3,-(sp)

	movem.l	a0/d0,-(sp)
	bsr	Hlp_FreeTexte
	bsr	Hlp_GetMap
	movem.l	a1/d1,-(sp)
	bne	.Out

; Explore methodiquement les possibilites
	movem.l	8(sp),a0/d0
	moveq	#2,d7
	move.b	(a0),d0			* Si operateur >>> 1 seul car!
	bsr	Hlp_D0Maj
	cmp.b	#"A",d0
	bcs.s	.Gli0
	cmp.b	#"Z",d0
	bls.s	.Gli1
.Gli0	subq.w	#1,d7
.Gli1	moveq	#0,d6
.loop0	move.l	Buffer(a5),a2
	lea	128(a2),a2
	move.w	#$00FF,(a2)+
	moveq	#0,d2
	moveq	#0,d5
.loop1	move.w	d0,d3
.loop2	move.b	(a0)+,d0
	bsr	Hlp_D0Maj
	cmp.b	#32,d0
	beq.s	.skip
	move.b	d0,(a2)+
	addq.w	#1,d2
.skip	addq.w	#1,d5
	subq.w	#1,d3
	beq.s	.loop3
	cmp.w	d2,d7
	bne.s	.loop2
.loop3	moveq	#0,d4
	move.l	Buffer(a5),a2
	lea	128(a2),a2
	addq.w	#2,d2
	JJsr	L_InstrFind
	movem.l	(sp),a1/d1
	movem.l	8(sp),a0/d0
	tst.l	d3
	beq.s	.Nf

; Trouve, explore une lettre de plus
	move.l	d3,d6
	addq.w	#1,d7
	cmp.w	d0,d7
	bls.s	.loop0
	bra.s	.Trouve
; Pas trouve, peut-on revenir en arriere?
.Nf	move.l	d6,d3
	bne.s	.Trouve
.NFound	moveq	#21,d0
	bra	.Out

; Charge la portion demandee
.Trouve	lea	-4(a1,d3.w),a1
	moveq	#0,d5		D3>>> offset
	move.b	(a1)+,d5
	lsl.l	#8,d5
	move.b	(a1)+,d5
	lsl.l	#8,d5
	move.b	(a1)+,d5
	moveq	#0,d4		D4>>> Longueur
	addq.l	#2,a1
.Next	tst.b	(a1)+		Recherche le debut suivant
	bne.s	.Next
	move.b	(a1)+,d4
	lsl.l	#8,d4
	move.b	(a1)+,d4
	lsl.l	#8,d4
	move.b	(a1)+,d4
	sub.l	d5,d4

; Chargement du texte dans un buffer
	move.l	d4,d0
	add.l	#512,d0
	SyCall	MemFastClear
	beq	.OutM
	move.l	a0,d2
	move.l	a0,Hlp_Texte(a4)
	move.l	d0,Hlp_LTexte(a4)

	moveq	#12,d0			Nom de AMOSPro_Help.Txt
	JJsr	L_Sys_GetMessage
	lea	NomTxt(pc),a1
	bsr	AddSuffix
	move.l	#1005,d2
	bsr	Hlp_Open
	beq	.DErr1

; Cree les trois lignes de titre
	moveq	#22,d0
	bsr	Tt_Message
	move.l	Hlp_Texte(a4),a2
	moveq	#2,d0
.Lp1	move.l	a0,a1
.Lp2	move.b	(a1)+,(a2)+
	bne.s	.Lp2
	move.b	#10,-1(a2)
	dbra	d0,.Lp1
	move.b	#10,-1(a2)
	move.b	#10,(a2)+
	move.l	d5,d2			Charge le titre
	moveq	#-1,d3
	bsr	Hlp_Seek
	move.l	Buffer(a5),d2
	moveq	#64,d3
	bsr	Hlp_Read
	move.l	d2,a0
.Lp3	cmp.b	#32,(a0)+
	bcc.s	.Lp3
	move.l	a0,d0
	move.l	d2,a0
	sub.l	d2,d0
	move.l	d0,d2
	add.l	d2,d5			Position + Titre
	sub.l	d2,d4			Taille - Titre
	lsr.w	#1,d0
	move.l	Hlp_Texte(a4),a1
	lea	132(a1),a1
	sub.w	d0,a1
	subq.w	#1+1,d2
	bmi.s	.Lp5
.Lp4	move.b	(a0)+,(a1)+
	dbra	d2,.Lp4
.Lp5
; Charge le titre
	move.l	d5,d2			Charge le titre
	moveq	#-1,d3
	bsr	Hlp_Seek
	move.l	a2,d2
	move.l	d4,d3
	bsr	Hlp_Read
	bne	.DErr0
	bsr	Hlp_Close
; Pas d'erreur / A1-D1= buffer + Longueur
	move.l	Hlp_Texte(a4),a1
	move.l	Hlp_LTexte(a4),d1
	subq.l	#8,d1
	moveq	#0,d0
	bra.s	.Out
; Out of memory: libere la .MAP
.OutM	bsr	Hlp_FreeMap
	moveq	#17,d0
	bra	.Out
; Cannot load .TXT
.DErr0	bsr	Hlp_Close
.DErr1	bsr	Hlp_FreeTexte
	moveq	#19,d0
; Sortie
.Out	lea	16(sp),sp
	movem.l	(sp)+,a2-a3/d2-d7
	tst.l	d0
	rts

;	Charge le fichier .MAP en memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hlp_GetMap
	movem.l	a2-a3/d2-d7,-(sp)
	tst.l	Hlp_Map(a4)		Deja chargee?
	bne.s	.NoLoad
; Charge...
	moveq	#12,d0			Nom du .MAP
	JJsr	L_Sys_GetMessage
	lea	NomMap(pc),a1
	bsr	AddSuffix
	move.l	#1005,d2
	bsr	Hlp_Open
	beq	.Err2
	moveq	#0,d2			Trouve la longueur du fichier
	moveq	#1,d3
	bsr	Hlp_Seek
	moveq	#0,d2
	moveq	#-1,d3
	bsr	Hlp_Seek
	move.l	d0,d3
	SyCall	MemFast
	beq	.Err1
	move.l	a0,Hlp_Map(a4)
	move.l	d3,Hlp_LMap(a4)
	move.l	a0,d2
	bsr	Hlp_Read
	bne	.Err2
	bsr	Hlp_Close		Ferme le fichier
; Ramene l'adresse et la longueur...
.NoLoad	move.l	Hlp_Map(a4),a1
	move.l	Hlp_LMap(a4),d1
	moveq	#0,d0
	bra.s	.Out
; Erreurs de chargement!
.Err1	bsr	Hlp_Close		Cannot load .MAP file
	bsr	Hlp_FreeMap
	moveq	#18,d0
	bra.s	.Out
.Err2	bsr	Hlp_FreeMap		Out of memory
	moveq	#17,d0
; Sortie
.Out	movem.l	(sp)+,d2-d7/a2-a3
	tst.l	d0
	rts

;	Efface le buffer MAP
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Hlp_FreeMap
	bsr	Hlp_FreeTexte
	move.l	Hlp_Map(a4),d1
	beq.s	.skip
	move.l	d1,a1
	move.l	Hlp_LMap(a4),d0
	clr.l	Hlp_Map(a4)
	clr.l	Hlp_LMap(a4)
	SyCall	MemFree
.skip	rts
;	Efface le buffer TEXTE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hlp_FreeTexte
	move.l	Hlp_Texte(a4),d1
	beq.s	.skip
	move.l	d1,a1
	move.l	Hlp_LTexte(a4),d0
	clr.l	Hlp_Texte(a4)
	clr.l	Hlp_LTexte(a4)
	SyCall	MemFree
.skip	rts
;	Additionne le suffixe au nom de fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AddSuffix
	move.l	a1,d0
	move.l	Buffer(a5),a1
	lea	512(a1),a1
	move.l	a1,d1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
	subq.l	#1,a1
	move.l	d0,a0
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
	rts

;	Open file
; ~~~~~~~~~~~~~~~
Hlp_Open
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	move.l	d0,d1
	rts
;	Close file
; ~~~~~~~~~~~~~~~
Hlp_Close
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
	rts
;	Read file
; ~~~~~~~~~~~~~~~
Hlp_Read
	movem.l	d1/a0/a1/a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVORead(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts
;	Seek file
; ~~~~~~~~~~~~~~~
Hlp_Seek
	movem.l	d1/a0/a1/a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOSeek(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	rts
; 	D0 > majuscule
; ~~~~~~~~~~~~~~~~~~~~
Hlp_D0Maj
	cmp.b	#"a",d0
	bcs.s	.skip
	cmp.b	#"z",d0
	bhi.s	.skip
	sub.b	#$20,d0
.skip	rts




;	Decoupe la ligne en ses instructions / fonctions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0= ligne
Tt_Decoup
	movem.l	d0-d1/a0-a2,-(sp)
	bsr	Ttt_FindL
	move.l	a0,Tt_ALine(a4)		Adresse ligne
	lea	Tt_Decoupe(pc),a1	Adresse patch
	move.l	a1,d0
	neg.l	d0
	move.l	Tt_Ligne(a4),a1
	move.l	a1,Tt_PLine(a4)
	move.l	#":---",-4(a1)
	move.l	Tt_BufT(a4),a1		Adresse buffer
	JJsrR	L_Detok,a2
	movem.l	(sp)+,d0-d1/a0-a2
	rts
; Partie appelle par la detokenisation...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Decoupe
	movem.l	a0-a1/d0-d3,-(sp)
	moveq	#0,d1
	move.w	(a6),d0
	beq	.skip1
	moveq	#"-",d1
	cmp.w	#_TkM,d0
	beq	.skip1
	moveq	#":",d1
	cmp.w	#_TkDP,d0
	beq	.skip1
	cmp.w	#_TkThen,d0
	beq	.skip1
	cmp.w	#_TkElse,d0
	beq	.skip1
	moveq	#"V",d1
	cmp.w	#_TkVar,d0
	beq.s	.skip1
	moveq	#"X",d1
	cmp.w	#_TkPro,d0
	beq.s	.skip1
	moveq	#"G",d1
	cmp.w	#_TkLGo,d0
	beq.s	.skip1
	moveq	#"2",d1
	cmp.w	#_TkCh1,d0
	beq.s	.skip1
	cmp.w	#_TkCh2,d0
	beq.s	.skip1
	moveq	#"1",d1
	cmp.w	#_TkFl,d0
	beq.s	.skip1
	moveq	#"(",d1
	cmp.w	#_TkPar1,d0
	beq.s	.skip1
	moveq	#")",d1
	cmp.w	#_TkPar2,d0
	beq.s	.skip1
	moveq	#",",d1
	cmp.w	#_TkVir,d0
	beq.s	.skip1
	cmp.w	#_TkPVir,d0
	beq.s	.skip1
	cmp.w	#_TkTo,d0
	beq.s	.skip1
	cmp.w	#_TkAs,d0
	beq.s	.skip1
	moveq	#"0",d1
	cmp.w	#_TkExt,d0
	bcs.s	.skip1
	beq.s	.jmp1
; Instruction/fonction normale
	move.l	AdTokens(a5),a0
	lea	4(a0,d0.w),a0
.loop1	tst.b	(a0)+
	bpl.s	.loop1
	move.b	(a0)+,d1
	bpl.s	.skip2
.skip0	moveq	#"I",d1
.skip2	cmp.b	#"V",d1
	bne.s	.skip1
	move.b	(a0)+,d1
; Poke l'adresse dans la table
.skip1	move.l	Mon_Base(a5),a1
	move.l	Tt_PLine(a1),a0
	cmp.b	#"V",d1
	beq.s	.skup
	cmp.b	#"0",d1
	beq.s	.skup
	cmp.b	#"1",d1
	beq.s	.skup
	cmp.b	#"2",d1
	bne.s	.skip3
.skup	cmp.b	#":",-4(a0)
	bne.s	.skip3
	moveq	#"W",d1
.skip3	move.b	d1,(a0)+
	move.l	a4,d0
	sub.l	Tt_BufT(a1),d0
	subq.l	#2,d0
	move.b	d0,(a0)+
	move.l	a6,d0
	sub.l	Tt_ALine(a1),d0
	move.w	d0,(a0)+
	move.l	a0,Tt_PLine(a1)
	movem.l	(sp)+,a0-a1/d0-d3
	rts
; Detokenise une extension
.jmp1	move.w	4(a6),d1
	move.b	2(a6),d2
	ext.w	d2
	lsl.w	#2,d2
	tst.l	AdTokens(a5,d2.w)
	beq.s	.skip0
	move.l	AdTokens(a5,d2.w),a0
	lea	4(a0,d1.w),a0
	bra.s	.loop1

;	Va evaluer une expression
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Evalue
	movem.l	d1/d4-d7/a0-a5,-(sp)
	move.l	a6,Tt_EvDebut(a4)
	lea	Tt_EvError(pc),a0	Patche les erreurs
	move.l	a0,Patch_Errors(a5)
	lea	Tt_Menage(pc),a0	Patche le menage
	move.l	a0,Patch_Menage(a5)
	bsr	Tt_PrgBanks
Tt_ReEv	move.l	sp,Tt_EvPile(a4)	Position pile en cas de menage
	move.l	AdTokens(a5),a4		Recharge la table
	moveq	#0,d7
	move.l	PLoop(a5),a3
	JJsr	L_New_Evalue
	movem.l	(sp)+,d1/d4-d7/a0-a5
	bsr	Tt_TtBanks
	clr.l	Patch_Errors(a5)
	clr.l	Patch_Menage(a5)
	moveq	#0,d0
	rts
;	En cas d'erreurs d'evaluation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_EvError
	move.l	Mon_Base(a5),a4
	move.l	Tt_EvPile(a4),sp
	movem.l	(sp)+,d1/d4-d7/a0-a5
	bsr	Tt_TtBanks
	clr.l	Patch_Errors(a5)
	clr.l	Patch_Menage(a5)
	moveq	#0,d3
	moveq	#0,d2
	moveq	#-1,d0
	rts
;	En cas de menage
; ~~~~~~~~~~~~~~~~~~~~~~
Tt_Menage
	move.l	Mon_Base(a5),a4
	move.l	Tt_EvPile(a4),sp
	move.l	Tt_EvDebut(a4),d0
	beq.s	.err
	move.l	d0,a6
	clr.l	Tt_EvDebut(a4)
	movem.l	(sp),d1/d4-d7/a0-a5
	bra.s	Tt_ReEv
.err	moveq	#11,d0
	JJsr	L_Error


; ___________________________________________________________________
;
;	GESTION INFORMATIONS
; ___________________________________________________________________

;	TOUCHE: clique sur une expression dans les infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_Clic
	bsr	XYMouEc
	lsr.w	#3,d2
	sub.w	Ttt_Tlh(a4),d2
	subq.w	#2,d2
; Recherche la ligne dans le buffer
	move.l	Inf_Buf(a4),a0
	moveq	#100,d0
	moveq	#0,d1
.loop	add.w	d1,a0
	move.w	(a0),d1
	beq.s	.out
	cmp.w	4(a0),d2
	bne.s	.loop
	cmp.w	#3,2(a0)		Enleve 1 ligne PARAM
	beq.s	.skip
	cmp.w	#1,2(a0)		... et TOUTES les infos
	bne.s	.out
	moveq	#1,d0
.skip	move.w	d0,2(a0)
	bsr	Inf_Del
	bsr	Inf_Centre
.out	bsr	Wmky
	rts


;	Affichage de la ligne ecran D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_AffLine
	moveq	#0,d6
	move.w	d0,d3
	bra.s	ginf2
;	Comptage des lignes infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_CptLines
	bset	#31,d6
	bra.s	ginf1
;	Affichage du contenu du buffer dans l'ordre des lignes!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_AffAll
	moveq	#0,d6
ginf1	moveq	#-1,d3
ginf2	moveq	#0,d7
	move.w	Inf_YPos(a4),d6
	move.w	d6,d7
	add.w	Ttt_Tlb(a4),d7
	moveq	#0,d5
	moveq	#0,d4
.loop	bsr	InfAf
	addq.w	#1,d4
	cmp.w	#6,d4
	bcs.s	.loop
	move.w	d5,Inf_NLigne(a4)
; Efface jusqu'� la fin
.llop	tst.l	d6
	bmi.s	.skip2
	cmp.w	d7,d5
	bcc.s	.skip
	moveq	#0,d1
	move.w	d5,d2
	sub.w	d6,d2
	WiCall	Locate
	WiCalD	ChrOut,7
	addq.w	#1,d5
	bra.s	.llop
; Va dessiner le slider
.skip
.skip2	rts
;	Imprime toutes les lignes num�ro D4
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InfAf	move.l	Inf_Buf(a4),a2
	tst.w	(a2)
	beq.s	.out
.loop0	cmp.w	2(a2),d4
	bne.s	.next
	move.w	#-1,4(a2)
	cmp.w	#1,d4
	bne.s	.nxt1
	bset	#31,d7
.nxt1	cmp.w	#3,d4
	bne.s	.nxt2
	bset	#30,d7
.nxt2	cmp.w	d6,d5
	bcs.s	.nexta
	cmp.w	d7,d5
	bcc.s	.nexta
	move.w	d5,d2
	sub.w	d6,d2
	tst.w	d3
	bmi.s	.jd
	cmp.w	d3,d2
	bne.s	.nexta
.jd	move.w	d2,4(a2)
	bsr	InfA
.nexta	addq.w	#1,d5
.next	add.w	(a2),a2
	tst.w	(a2)
	bne.s	.loop0
.out	rts

;	Imprime la ligne info D2/A2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
InfA	moveq	#0,d1
	ext.l	d2
	WiCall	Locate
	cmp.w	#2,2(a2)		Separation INFOS / LISTING
	beq.s	.sep1
	cmp.w	#4,2(a2)
	beq.s	.sep2
	cmp.w	#3,2(a2)
	beq.s	Iparam
; Impression simple...
.simple	tst.l	d6
	bmi.s	ttnp
	lea	6(a2),a1
	WiCall	Print
.out	rts
; Separation Infos1/Infos2
.sep1	bclr	#31,d7
	bne.s	.simple
	bra.s	.nosep
; Separation Infos2/Listing
.sep2	bclr	#30,d7
	bne.s	.simple
.nosep	move.w	#-1,4(a2)
	subq.w	#1,d5
ttnp	rts
; Affiche un parametre
Iparam	tst.l	d6
	bmi.s	ttnp
	movem.l	a2/d3-d7,-(sp)
	bclr	#31,d7
	tst.w	Tt_Init(a4)
	beq.s	.noi
	move.l	BasA3(a5),d0		Invalide???
	cmp.l	6(a2),d0
	beq.s	.ok
.noi	WiCalA	Print,Inf_Shade(pc)
	bset	#31,d7
.ok	lea	10(a2),a0
	move.l	Tt_BufT(a4),a1
	moveq	#0,d0
	move.l	a2,-(sp)
	JJsrR	L_Mon_Detok,a2
	move.l	(sp)+,a2
	move.l	Tt_BufT(a4),a0
	move.w	(a0)+,d4
	cmp.w	#60,d4
	bcs.s	.skip0
	moveq	#60,d4
.skip0	add.w	d4,a0
	btst	#31,d7
	bne	.suit
	lea	10(a2),a6
	bsr	Tt_Evalue
	bne	.suit
	move.b	#":",(a0)+
	move.b	#" ",(a0)+
	move.l	d3,d0
	subq.b	#1,d2
	bmi.s	.ent
	bne.s	.str
* Chiffre FLOAT
	JJsrR	L_Float2Ascii,a1
	bra.s	.suit
* Chiffre ENTIER
.ent	cmp.l	#EntNul,d3
	beq.s	.entD
	JJsrR	L_LongToDec,a1
	bra.s	.suit
.entD	exg	a0,a1
	moveq	#13,d0
	bsr	Tt_Message
	exg	a0,a1
.entE	move.b	(a1)+,(a0)+
	bne.s	.entE
	subq.l	#1,a0
	bra.s	.suit
* Chaine
.str	moveq	#'"',d1
	move.b	d1,(a0)+
	sub.w	#78-6,d4
	neg.w	d4
	move.l	d0,a1
	move.w	(a1)+,d2
	cmp.w	d4,d2
	bcs.s	.skip1
	move.w	d4,d2
	moveq	#">",d1
.skip1	subq.w	#1,d2
	bmi.s	.skip2
.loop	move.b	(a1)+,d0
	cmp.b	#32,d0
	bcc.s	.skip3
	moveq	#".",d0
.skip3	move.b	d0,(a0)+
	dbra	d2,.loop
.skip2	move.b	d1,(a0)+
* Imprime la chaine...
.suit	btst	#31,d7
	beq.s	.suit1
	lea	Inf_ShadOff(pc),a1
.suit0	move.b	(a1)+,(a0)+
	bne.s	.suit0
	subq.l	#1,a0
.suit1	move.b	#7,(a0)+
	clr.b	(a0)
	move.l	Tt_BufT(a4),a1
	addq.l	#2,a1
	WiCall	Print
 	movem.l	(sp)+,a2/d3-d7
	rts

;	Impression dans le buffer infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_PrDeb
	movem.l	a0/d0,-(sp)
	move.l	Inf_Pos(a4),a0
	clr.w	(a0)
	move.w	d0,2(a0)
	move.w	#-1,4(a0)
	movem.l	(sp)+,a0/d0
	rts
Inf_Print
	movem.l	a0-a2/d0,-(sp)
	move.l	Inf_Pos(a4),a1
	move.l	a1,a2
	move.w	(a2),d0
	lea	6(a1,d0.w),a1
	subq.w	#1,d0
.loop	addq.w	#1,d0
	cmp.b	#76,d0
	bcc.s	.out
	move.b	(a0)+,(a1)+
	bne.s	.loop
.out	clr.b	(a1)
	move.w	d0,(a2)
	movem.l	(sp)+,a0-a2/d0
	rts
Inf_PrFin
	move.l	d0,-(sp)
	move.l	Inf_Pos(a4),a0
	move.w	(a0),d0
	cmp.w	#76,d0
	bcc.s	.skip
	move.b	#7,6(a0,d0.w)
	clr.b	7(a0,d0.w)
	addq.w	#1,d0
.skip	addq.w	#8,d0
	and.w	#$FFFE,d0
	move.w	d0,(a0)
	add.w	d0,a0
	move.l	a0,Inf_Pos(a4)
	clr.w	(a0)
	move.l	(sp)+,d0
	rts

;	Supression ligne dans buffer...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	numero des lignes a supprimer...
Inf_Del
	move.l	Inf_Buf(a4),a0
	move.l	Inf_Pos(a4),d1
	moveq	#0,d2
	moveq	#0,d3
.loop	move.l	a0,a1
	cmp.l	d1,a0
	bcc.s	.out
	cmp.w	2(a0),d0
	beq.s	.del
	add.w	(a0),a0
	bra.s	.loop
.del	add.w	(a1),d2
	lea	0(a0,d2.w),a1
	cmp.l	d1,a1
	bcc.s	.dele
	cmp.w	2(a1),d0
	beq.s	.del
.dele	sub.l	d2,d1
.loopD	move.w	(a1)+,(a0)+
	cmp.l	d1,a0
	bls.s	.loopD
	subq.l	#2,a0
	addq.w	#1,d3
	bra.s	.loop
.out	move.l	d1,Inf_Pos(a4)
	move.w	d3,d0
	rts
;	Insere D octets au debut des infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_Ins	movem.l	a1/a2,-(sp)
	move.l	Inf_Buf(a4),a0
	move.l	Inf_Pos(a4),a1
	lea	0(a1,d0.w),a2
	move.l	a2,Inf_Pos(a4)
	clr.w	(a2)
.loop	move.w	-(a1),-(a2)
	cmp.l	a0,a1
	bcc.s	.loop
; Empeche les plantages...
	move.w	d0,(a0)+
	clr.l	(a0)
	clr.w	4(a0)
	movem.l	(sp)+,a1/a2
	rts

;	TOUCHE: Slider infos
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_Sliclic
	bsr	Ttt_InfAct
	move.l	#Tt_ChannelN,d0		Demande la position slider
	moveq	#3,d1
	moveq	#0,d2
	JJsr	L_Dia_GetValue
	move.w	Inf_YPos(a4),d0
	move.w	d1,Inf_YPos(a4)
	sub.w	d1,d0
	cmp.w	#1,d0
	beq.s	.Bas
	cmp.w	#-1,d0
	beq.s	.Haut
; Positionnement direct
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Inf_AffAll
	rts
; Scroll vers le bas
; ~~~~~~~~~~~~~~~~~~
.Bas	WiCalA	Print,Ttt_Scrdown(pc)	Scroll graphique
	moveq	#0,d0			Affiche la derniere ligne
	bsr	Inf_AffLine
	rts
; Scroll vers le haut
; ~~~~~~~~~~~~~~~~~~~
.Haut	lea	Ttt_Scrup(pc),a1	Scroll graphique
	move.w	Ttt_Tlb(a4),d0
	add.b	#48-1,d0
	move.b	d0,2(a1)
	WiCall	Print
	move.w	Ttt_Tlb(a4),d0		Affiche la derniere ligne
	subq.w	#1,d0
	bsr	Inf_AffLine
	rts

;	Actualisation du slider informations
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inf_Slider
	move.l	#Tt_ChannelN,d0		Re-actualise le slider, donc la liste
	moveq	#3,d1
	move.w	Inf_YPos(a4),d2		Position
	move.w	Ttt_Tlb(a4),d3		Nouvelle window
	move.w	Inf_NLigne(a4),d4	Nouveu global
	JJsr	L_Dia_Update
	rts

;	Alertes
; ~~~~~~~~~~~~~
Ttt_Alert
	move.l	a0,-(sp)
	moveq	#0,d0
	bsr	Inf_Del
	move.l	(sp)+,a0
	moveq	#0,d0
	addq.w	#1,Inf_AlertOn(a4)
	clr.w	Inf_YPos(a4)
	bsr	Inf_PrDeb
	move.l	a0,-(sp)
	lea	Inf_Mark(pc),a0
	bsr	Inf_Print
	move.l	(sp)+,a0
	bsr	Inf_Print
	bsr	Inf_PrFin
	moveq	#5,d0
	bsr	Tt_Message
	bsr	Inf_PrDeb
	bsr	Inf_Print
	bsr	Inf_PrFin
	rts
;	Effacement des alertes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_AlertDel
	movem.l	a0-a6/d0-d7,-(sp)
	tst.w	Inf_AlertOn(a4)
	beq.s	.out
	clr.w	Inf_AlertOn(a4)
	moveq	#0,d0
	bsr	Inf_Del
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider
.out	movem.l	(sp)+,a0-a6/d0-d7
	rts
;	Supression / Affichage lignes du buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_DelAff
	bsr	Inf_Del
	beq.s	.skip
	bsr	Ttt_InfAct
	bsr	Inf_AffAll
	bsr	Inf_Slider
.skip	rts

; ___________________________________________________________________
;
;	ECRAN DU PROGRAMME
; ___________________________________________________________________



;	TOUCHE: changement d'ecran view
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_CEc	bsr	View_GEc
	bsr	View_Aff
	moveq	#-1,d0
	rts
;	TOUCHE: mouvement vers le bas dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Down	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	6(a0),d0
	move.w	d0,d2
	sub.w	2(a0),d0
	sub.w	d1,d0
	cmp.w	#RedTY,d0
	bcs.s	TtMvS
	add.w	d1,2(a0)
	bsr	View_Aff
	bra.s	TtMvX
;	TOUCHE: mouvement vers le haut dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Up	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	2(a0),d0
	sub.w	d1,d0
	bmi.s	TtMvS
	move.w	d0,2(a0)
	bsr	View_Aff
	bra.s	TtMvX
TtMvS	clr.w	Tt_Accel(a4)
TtMvX	moveq	#0,d0
	rts
;	TOUCHE: mouvement vers la gauche dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Left	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	(a0),d0
	sub.w	d1,d0
	bmi.s	TtMvS
	move.w	d0,(a0)
	bsr	View_Aff
	bra.s	TtMvX
;	TOUCHE: mouvement vers la droite dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Right
	bsr	View_ScAd
	bmi.s	TtMvX
	bsr	Accel
	move.w	4(a0),d0
	sub.w	(a0),d0
	sub.w	d1,d0
	cmp.w	#RedTX,d0
	bcs.s	TtMvS
	add.w	d1,(a0)
	bsr	View_Aff
	bra.s	TtMvX
; Acceleration
Accel	move.w	Tt_Accel(a4),d1
	cmp.w	#15,d1
	bcc.s	.skip
	addq.w	#1,d1
	move.w	d1,Tt_Accel(a4)
.skip	lsr.w	#2,d1
	lea	Tablacc(pc),a1
	move.b	0(a1,d1.w),d1
	ext.w	d1
	rts
;	TOUCHE: passe aux ecrans du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_See	bsr	Tt_Hide
	bsr	Wmky
	bsr	Tt_Show
	moveq	#-1,d0
	rts

;	Affichage de l'ecran du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_Aff
	movem.l	a0-a6/d0-d7,-(sp)

; Trouve l'ecran actuel
	move.w	Tt_View(a4),d1
	bmi	.closed

; L'ecran est-il encore ouvert?
.Again	lea	T_EcAdr(a5),a0
	lsl.w	#2,d1
	move.l	0(a0,d1.w),d0
	beq	.closed
	move.l	d0,a2
	cmp.l	Tt_ViewAd(a4),a2
	bne.s	.new
	move.w	EcTx(a2),d0
	cmp.w	Tt_ViewTX(a4),d0
	bne.s	.new
	move.w	EcTy(a2),d0
	cmp.w	Tt_ViewTY(a4),d0
	bne.s	.new
	move.w	EcNPlan(a2),d0
	cmp.w	Tt_ViewNP(a4),d0
	beq.s	.old
* Nouvel ecran!
.new	bsr	View_Cls

;	Ok, fait la copie
; ~~~~~~~~~~~~~~~~~~~~~~~
.old	move.w	EcTx(a2),Tt_ViewTX(a4)
	move.w	EcTy(a2),Tt_ViewTY(a4)
	move.w	EcNPlan(a2),Tt_ViewNP(a4)
	move.l	a2,Tt_ViewAd(a4)

; Prend la position du scrolling
	SyCall	WaitVbl
	bsr	View_ScAd
	move.w	(a0),d0
	move.w	2(a0),d1

	tst.w	EcCon0(a2)
	bmi	.OHi
; Origine LOWRES : veritable reduce, ultra rapide (he he!)
	move.l	a2,a0
	move.l	T_EcAdr+Tt_Ecran1*4(a5),a1
	move.l	a0,SccEcO(a5)
	move.l	a1,SccEcD(a5)
	move.w	#RedX,d2
	move.w	#RedY,d3
	move.w	#RedTX,d4
	add.w	d0,d4
	move.w	#RedTY,d5
	add.w	d1,d5
	move.w	#$CC,d6
	move.w	EcTy(a0),-(sp)
	move.w	EcTLigne(a0),-(sp)
	move.l	a0,-(sp)
	move.w	EcTy(a0),d7
	lsr.w	#1,d7
	move.w	d7,EcTy(a0)
	move.w	EcTLigne(a0),d7
	lsl.w	#1,d7
	move.w	d7,EcTLigne(a0)
	JJsrR	L_Sco0,a2
	move.l	(sp)+,a0
	move.w	(sp)+,EcTLigne(a0)
	move.w	(sp)+,EcTy(a0)
	bsr	TtReCop
	bra	TtRx
; Origine HIRES : simple recopie
.OHi	move.l	a2,a0
	move.l	T_EcAdr+Tt_Ecran1*4(a5),a1
	move.l	a0,SccEcO(a5)
	move.l	a1,SccEcD(a5)
	move.w	#RedX,d2
	move.w	#RedY,d3
	move.w	#RedTX,d4
	add.w	d0,d4
	move.w	#RedTY,d5
	add.w	d1,d5
	move.w	#$CC,d6
	JJsrR	L_Sco0,a2
	bsr	TtReCop
	bra.s	TtRx
; Plus d'ecran. Trouve un nouveau ou sort...
.closed	bsr	View_GEc
	move.w	Tt_View(a4),d1
	bpl	.Again
	bsr	View_Cls
	clr.l	Tt_ViewAd(a4)
; Sortie
TtRx	movem.l	(sp)+,a0-a6/d0-d7
	rts

;	Trouve le prochain ecran ouvert
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_GEc
	move.w	Tt_View(a4),d1
View_Ec
	moveq	#7,d0
.loop	addq.w	#1,d1
	cmp.w	#8,d1
	bcs.s	.skip
	moveq	#0,d1
.skip	move.w	d1,d2
	lsl.w	#2,d2
	lea	T_EcAdr(a5),a0
	tst.l	0(a0,d2.w)
	bne.s	.skip1
	dbra	d0,.loop
	moveq	#-1,d1
.skip1	move.w	d1,Tt_View(a4)
	bsr	View_Info
	rts
;	Trouve l'adresse des positions de scrolling.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1->	A0
View_ScAd
	move.w	Tt_View(a4),d0
	bmi.s	.no
	lsl.w	#3,d0
	lea	ViewScrols(a4),a0
	add.w	d0,a0
	moveq	#0,d0
	rts
.no	moveq	#-1,d0
	rts
;	Calcule la table lors d'init!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_ScUpdate
	movem.l	a0-a2/d0-d1,-(sp)
	lea	T_EcAdr(a5),a2
	lea	ViewScrols(a4),a1
	moveq	#7,d1
.loop	clr.l	(a1)
	tst.l	(a2)
	beq.s	.skip
	move.l	(a2),a0
	move.w	EcTx(a0),4(a1)
	move.w	EcTy(a0),d0
	tst.w	EcCon0(a0)
	bmi.s	.sk
	lsr.w	#1,d0
.sk	move.w	d0,6(a1)
.skip	addq.l	#8,a1
	addq.l	#4,a2			BUG dans TUTOR! ILLEGAL
	dbra	d1,.loop
	movem.l	(sp)+,a0-a2/d0-d1
	rts

;	Routine d'interruption, recopie la palette...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_Inter
	move.l	Mon_Base(a5),a0
	move.w	Tt_View(a0),d2
	bmi.s	.skip
	lsl.w	#2,d2
	lea	T_EcAdr(a5),a0
	move.l	0(a0,d2.w),d0
	beq.s	.skip
	move.l	d0,a2
	lea	EcPal(a2),a2
	move.l	Tt_Ecran1*4(a0),a1
	lea	EcPal(a1),a1
	move.l	T_CopMark+Tt_Ecran1*128(a5),d0
	beq.s	.skip
	move.l	d0,a0
	addq.l	#2,a0
	moveq	#11-1,d0
.loop	move.w	(a2),(a0)
	addq.l	#4,a0
	move.w	(a2)+,(a1)+
	dbra	d0,.loop
.skip	rts


;	Activation de l'ecran de texte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ttt_Act	moveq	#Tt_Ecran2,d1
	bra	Tt_EcAct
;	Activation de l'ecran des touches
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_Act
	moveq	#Tt_Ecran1,d1
Tt_EcAct
	cmp.w	Tt_Ecran(a4),d1
	beq.s	.skip
	move.w	d1,Tt_Ecran(a4)
	EcCall	Active
.skip	rts

;	CLS de l'�cran de zoom
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_Cls
	movem.l	d0-d5/a0-a1,-(sp)
	moveq	#0,d1
	move.w	#RedX,d2
	move.w	#RedY,d3
	move.w	d2,d4
	move.w	d3,d5
	add.w	#RedTX,d4
	add.w	#RedTY,d5
	EcCall	ClsEc
	movem.l	(sp)+,d0-d5/a0-a1
	rts

;	Affiche la position de l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
View_Info
	tst.w	Tt_View(a4)
	bpl.s	.Ok
	lea	Info_ViewOff(pc),a0
	bra.s	.Skip
.Ok	lea	Info_View(pc),a0
	bsr	Tt_Text
	move.l	Buffer(a5),a0
	lea	TBuffer-16(a0),a0
	move.l	#$20202020,(a0)
	clr.l	4(a0)
	move.w	Tt_View(a4),d0
	ext.l	d0
	move.l	a1,-(sp)
	JJsrR	L_LongToDec,a1
	move.l	(sp)+,a1
	lea	Info_Buf(pc),a0
.Skip	bsr	Tt_Text
	rts

;	PRINT TEXT A0
; ~~~~~~~~~~~~~~~~~~~
Tt_Text	movem.l	a0-a2/d0-d2,-(sp)
	move.l	T_RastPort(a5),a1
	move.w	(a0)+,d0
	bmi.s	.skip1
	move.w	d0,36(a1)
.skip1	move.w	(a0)+,d0
	bmi.s	.skip2
	move.w	d0,38(a1)
.skip2	move.b	(a0)+,d0
	bmi.s	.skip3
	ext.w	d0
	GfxCa5	SetBPen
.skip3	move.b	(a0)+,d0
	bmi.s	.skip4
	ext.w	d0
	GfxCa5	SetAPen
.skip4	move.w	(a0)+,d0
	bmi.s	.skop5
	ext.l	d0
	GfxCa5	SetDrMd
.skop5	move.l	a0,a2
	moveq	#-1,d0
.loop	addq.w	#1,d0
	tst.b	(a2)+
	bne.s	.loop
	tst.w	d0
	bne.s	.skip5
	move.l	Buffer(a5),a0
	lea	TBuffer-16(a0),a0
	bra.s	.skop5
.skip5	ext.l	d0
	movem.l	a0/d0,-(sp)
	GfxCa5	Text
	movem.l	(sp)+,a0/d0
	GfxCa5	TextLength
	subq.w	#8,d0
	add.w	d0,36(a1)
	movem.l	(sp)+,a0-a2/d0-d2
	rts

; ___________________________________________________________________
;
;	GESTION DES BOUTONS
; ___________________________________________________________________

;	Impression de tous les boutons
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ABoutons
	moveq	#NBoutons,d0
	moveq	#0,d1
.loop	bsr	ABouton
	subq.w	#1,d0
	bne.s	.loop
	rts

;	Impression du bouton D0, active: D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ABouton	movem.l	a0/d2-d3,-(sp)
	move.l	#BtX,d2
	moveq	#BtY,d3
	lea	Tt_Boutons(pc),a0
	bsr	Aff_Bouton
	movem.l	(sp)+,a0/d2-d3
	rts

;------ Bouton g�n�ral
;	A0=table
;	A1= images
;	D0= numero
;	D1= on/off
;	D2= offset x
;	D3= offset y
Aff_Bouton
	movem.l	a0-a1/d0-d5,-(sp)
	move.w	d2,d4
	move.w	d3,d5
	mulu	#18,d0
	lea	-18+4(a0,d0.w),a0
	move.w	-4(a0),d0
	tst.w	d1
	beq.s	.skip
	move.w	-2(a0),d0
.skip	move.w	(a0)+,d1
	bclr	#0,d1
	bne.s	.sku
	add.w	d2,d1
.sku	ext.l	d1
	move.w	(a0)+,d2
	bclr	#0,d2
	bne.s	.sko
	add.w	d3,d2
.sko	ext.l	d2
	moveq	#-1,d3
	tst.w	d0
	beq.s	.ski
	bsr	Tt_UPack
.ski
* Fixe la zone D0
	move.w	d2,d3
	move.w	d1,d2
	move.w	(a0)+,d1
	beq.s	.slip
	move.w	(a0)+,d0
	bclr	#0,d0
	beq.s	.sl
	move.w	d4,d2
.sl	add.w	d0,d2
	move.w	(a0)+,d0
	bclr	#0,d0
	beq.s	.sm
	move.w	d5,d3
.sm	add.w	d0,d3
	move.w	(a0)+,d0
	bclr	#0,d0
	bne.s	.sn
	move.w	d2,d4
.sn	add.w	d0,d4
	move.w	(a0)+,d0
	bclr	#0,d0
	bne.s	.so
	move.w	d3,d5
.so	add.w	d0,d5
	SyCall	SetZone
.slip
* Fini!
	movem.l	(sp)+,a0-a1/d0-d5
	rts

;	Unpack un bouton
; ~~~~~~~~~~~~~~~~~~~~~~
Tt_UPack
	movem.l	a0-a2/d0-d1,-(sp)
	move.l	Tt_Resource(a4),a0
	add.l	2(a0),a0
	lsl.w	#2,d0
	move.l	-4+2(a0,d0.w),d0
	add.l	d0,a0
	move.l	T_EcCourant(a5),a1
	JJsrR	L_UnPack_Bitmap,a2
	movem.l	(sp)+,a0-a2/d0-d1
	rts

;	Trouve le message D0 >>> A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Message
	move.l	Mon_Base(a5),a0
	move.l	Tt_Resource(a0),a0
	add.l	2+4(a0),a0
	move.l	a1,-(sp)
	JJsrR	L_GetMessage,a1
	move.l	(sp)+,a1
	rts

;	Attente souris
; ~~~~~~~~~~~~~~~~~~~~~
RWmky	bsr	Tt_Multi
Wmky	bsr	Tt_MBout
	btst	#0,d1
	bne.s	RWmky
	rts
; 	Entree souris moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_MBout
	SyCall	MouseKey
	rts

;	XY Mouse dans l'ecran courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XYMouEc	SyCall	XyMou
	moveq	#0,d3
	SyCall	XyScr
	rts

; 	Attente multitache
; ~~~~~~~~~~~~~~~~~~~~~~~~
Tt_Multi
	JJmp	L_Sys_WaitMul

; 	Banques de m�moire/dialogue du moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_TtBanks
	move.l	a0,-(sp)
	lea	Mon_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	lea	Tt_Dialogs(a4),a0
	move.l	a0,Cur_Dialogs(a5)
	move.l	(sp)+,a0
	rts
;	Banques de memoire/dialogue du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tt_PrgBanks
	move.l	a0,-(sp)
	move.l	Mon_Base(a5),a0
	move.l	Tt_CurBanks(a0),Cur_Banks(a5)
	move.l	Tt_CurDialogs(a0),Cur_Dialogs(a5)
	move.l	(sp)+,a0
	rts

;		Donnees tutor
		Even
* Ancien vecteur ECRANS
Old_EcVect	dc.l	0
Old_SyVect	dc.l	0
* Definition des bouttons
* X,Y unpack / X,Y,TX,TY zones
Tt_Boutons	dc.w	18,19,0*48,2*24,1,0,0,48,24
		dc.w	20,21,1*48,2*24,2,0,0,48,24
		dc.w	22,23,2*48,2*24,3,0,0,48,24
		dc.w	24,25,3*48,2*24,4,0,0,48,24
		dc.w	26,27,4*48,2*24,5,0,0,48,24

		dc.w	2,3,0*48,0*24,6,32,0,32,16
		dc.w	2,4,0*48,0*24,7,32,32,32,16
		dc.w	2,5,0*48,0*24,8,0,16,32,16
		dc.w	2,6,0*48,0*24,9,64,16,32,16
		dc.w	2,7,0*48,0*24,10,32,16,32,16

		dc.w	8,9,2*48,0*24,11,0,0,96,24
		dc.w	10,11,4*48,0*24,12,0,0,48,24
		dc.w	0,0,0+1,0+1,13,16,8,320,100

		dc.w	16,17,2*48,1*24,14,0,0,48,24
		dc.w	14,15,3*48,1*24,15,0,0,48,24
		dc.w	12,13,4*48,1*24,16,0,0,48,24

* Table d'acceleration des deplacements
Tablacc		dc.b	1,2,4,8

* Info ecran
Info_View	dc.w	134,6,$0D0E,%001
		dc.b	"Screen # ",0
Info_Buf	dc.w	134+8*9-3,6,$0D0E,%001
		dc.b	0
Info_ViewOff	dc.w	126,6,$0D0E,%001
		dc.b	" No screens ",0

* Textes fenetre listing
Ttt_WInit	dc.b	27,"C0",27,"B2",27,"P3",25,27,"V0",0
Ttt_Scrup	dc.b	27,"Y0",22,0
Ttt_Scrdown	dc.b	12,20,0
Ttt_IOn		dc.b	27,"I1",0
Ttt_IOff	dc.b	27,"I0",0
Ttt_InOn	dc.b	27,"U1",0
Ttt_InOff	dc.b	27,"U0",0
Ttt_Mark	dc.b	27,"B0",27,"P1>>>",27,"B2",27,"P3",0

* Textes fenetre info
Inf_Shade	dc.b	27,"S1",0
Inf_ShadOff	dc.b	27,"S0",0
Inf_Par2	dc.b	" = ",0
Inf_Mark	dc.b	">>> ",0
NomMap		dc.b	".Map",0
NomTxt		dc.b	".Txt",0
		Even
; 		Petit DBL pour dessiner le fond
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DBL		dc.w	.Fin-.Debut
.Debut		dc.b	"BA	0,0;"
		dc.b	"SI	SW,SH;"
		dc.b	"LI	0,0,94,SX16-;"
		dc.b	"LI	0,YB 0VA8* +,100,SX;"
		dc.b	"LI	0,SY4-,106,SX;"
		dc.b	"VL	SX16-,6,97,0VA8* 8+;"
		dc.b	"VL	SX16-,YB 3+,103,SY3-;"
		dc.b	"HS	1,2,1,SX21-,4,0,79,250,10;[]"
		dc.b	"VS	2,SX12-,7,10,0VA8*,0,0VA,2VA,1;[]"
		dc.b	"VS	3,SX12-,0VA8*12+,10,1VA8*,0,1VA,3VA,1;[]"
		dc.b	"BU	4,SX16-,0,16,7,0,0,1;[UN 0,0,109BP+;][BR0;]"
		dc.b	"EX;"
		dc.b	0
.Fin		even
