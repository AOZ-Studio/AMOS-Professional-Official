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
; .200000............2002........................| Editor
; .200002........................................| Modif
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
		Include	"+Debug.s"
		IFEQ	Debug=2
		Include "+AMOS_Includes.s"
		Include "+Version.s"
		ENDC
;_____________________________________________________________________________


; Branchements internes � l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EDebut		dc.l	Ed_Cold-EDebut
		dc.l	Ed_Title-EDebut
		dc.l	Ed_End-EDebut
		dc.l	Ed_Loop-EDebut
		dc.l	Ed_ErrRun-EDebut
		dc.l	Ed_CloseEditor-EDebut
		dc.l	Ed_KillEditor-EDebut
		dc.l	Ed_ZapFonction-EDebut
		dc.l	Ed_ZapIn-EDebut
		dc.l	Ed_RunDirect-EDebut
		dc.l	Tokenise-EDebut
		dc.l	Detok-EDebut
		dc.l	Mon_Detok-EDebut
		dc.l	TInst-EDebut
		dc.l	0

; ______________________________________________________________________________

Ed_AutoMarksNb	equ	4
;______________________________________________________________________________
;
Ed_SlHDeltaG	equ	-2
Ed_SlHDeltaD	equ	1
Ed_SlHDeltaH	equ	2
Ed_SlHSy	equ	2
Ed_SlVDeltaG	equ	6
Ed_SlVDeltaH	equ	11
Ed_SlVSx	equ	4
Ed_SlVDeltaB	equ	-1
Ed_SlHDy	equ	2
Ed_SlVDx	equ	4

Ed_ZBoutons	equ	1000
Ed_XScrollG	equ	20
Ed_XScrollD	equ	10
Ed_YScrollH	equ	4
Ed_YScrollB	equ	4

Ed_YTop		equ	0
Ed_TitreSy	equ	16
Edt_EtatSy	equ	11
Edt_BasSy	equ	5
Edt_BtSx	equ	24

; Images dans la banque
; ~~~~~~~~~~~~~~~~~~~~~
Ed_Pics		equ	1
Ed_BtPics	equ	Ed_Pics+4
Ed_BoutonsPics	equ	Ed_BtPics+2*3
Ed_MemoryPics	equ	Ed_BoutonsPics+2*12
Es_Pics		equ	Ed_MemoryPics+3
Es_BoutonsPics	equ	Es_Pics+3

Ed_LogoSx	equ	32*5
Ed_MemorySy	equ	2
Ed_MemoryY1	equ	Ed_YTop+3
Ed_MemoryY2	equ	Ed_YTop+10
; Gros boutons
; ~~~~~~~~~~~~
Ed_BoutonsSx	equ	32
Ed_BoutonsSy	equ	16
Ed_TitleSx	equ	Ed_BoutonsSx*5
Ed_BoutonsX	equ	Ed_BoutonsSx+Ed_TitleSx
Ed_BoutonsY	equ	Ed_YTop
Ed_BoutonsZones	equ	128

; Boutons Escape
; ~~~~~~~~~~~~~~
Es_BoutonsSx	equ	32
Es_BoutonsSy	equ	16
Es_BoutonsZones	equ	1
Es_TitleSx	equ	Es_BoutonsSx*4
Es_TitleSy	equ	16
Es_BoutonsX	equ	Es_BoutonsSx+Es_TitleSx
Es_BoutonsY	equ	0
Es_MiniSy	equ	Es_TitleSy+8

; Nombre maximum de programme hidden dans le menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_HiddenMax	equ	12

; Numero du bouton ESCAPE
; ~~~~~~~~~~~~~~~~~~~~~~~
Bt_Insert	equ	10

; Messages
; ~~~~~~~~
Ed_Mes		equ	0		Debut des messages editeur

Ed_DiaImages	equ	66		Debut des images dialogue dans la banque
;	IfEQ	ROnly

;______________________________________________________________________________
;
;					Initialisation de l'editeur
;______________________________________________________________________________
;
Ed_Cold
	clr.b	Ed_Ok(a5)		Pas en etat de marche!
	bsr	Ed_Available
	cmp.l	#50*1024,d1		Au moins 50k de CHIP
	bcs.s	.Mem
	cmp.l	#110*1024,d0		Au moins 110k de memoire en tout!
	bcs.s	.Mem

; Warm ou Cold?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	Ed_Warm(a5)
	bne.s	.UnKill
; Chargement vraiment � froid
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_LoadAllConfig	Charge les fichiers
	bne.s	.Err
	bsr	Ed_Computee		Des fenetres vides
	bne.s	.Err
	bsr	Ed_OpenEditor		Ouvre l'editeur
	bne.s	.Err
	move.b	#1,Ed_Warm(a5)		Flag change!
	move.w	#-1,EsFlag(a5)		Force appear
	clr.w	Direct(a5)		Pas mode direct
	moveq	#0,d0			Pas d'erreur
	rts
; Chargement apres un KILL EDITOR
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.UnKill	bsr	Ed_LoadAllConfig	Recharge les configs
	bne.s	.Err
	moveq	#0,d0
	rts
; Une erreur
; ~~~~~~~~~~
.Mem	moveq	#1,d0
.Err	move.l	d0,-(sp)
	bsr	Ed_CloseEditor
	bsr	Ed_FreeAllConfig
	move.l	(sp)+,d0
	rts

; Apparition du titre de l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Title
	bsr	Ed_Appear
	bsr	Ed_WarmStart		Un Warmstart?
	moveq	#"A",d0
	bsr	Ed_SamPlay		Bonjour!
	bsr	Ed_About		Titre
	bsr	Ed_Loca			Curseur
	rts

; Fenetres d'origines d�ja comput�es?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Computee
	move.l	Prg_List(a5),d0
	move.l	Edt_List(a5),a4
	move.w	#2,Ed_WMax(a5)		Par default, au moins
.Loop	move.l	d0,a6
	tst.b	Prg_Edited(a6)
	bne.s	.Deja
	moveq	#-1,d0			Visible
	moveq	#-1,d1			Pas de structure PRG
	bsr	Edt_OpWindow		Va ouvrir >>> fenetre courante
	bne.s	.Err
	move.l	a6,Edt_Prg(a4)
	addq.b	#1,Prg_Edited(a6)
.Deja	move.l	Prg_Next(a6),d0
	bne.s	.Loop
	moveq	#0,d0
	rts
.Err	moveq	#1,d0			Out of memory!
	rts

; Effacement de tous les fichiers de config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_FreeAllConfig
	bsr	Ed_SamEnd		Les sons
	bsr	EdMa_End		Les macros
	bsr	EdC_Free		Les configs
	bsr	Ed_ResourceFree		La resource
	rts
; Chargement de tous les fichiers de config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_LoadAllConfig
; Charge la configuration de l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#7,d0
	JJsr	L_Sys_GetMessage
	JJsrR	L_Sys_AddPath,a1
	bsr	EdC_Load
	bne.s	.Err
; Charge la banque de resource
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#45,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	bsr	Ed_ResourceLoad
	bne.s	.Err
; Charge les macros par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#46,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	bsr	EdMa_Load
	bne.s	.Err
; Charge les sons par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_SamChanged
	moveq	#0,d0
.Err	rts


;______________________________________________________________________________
;
;							Fin
;______________________________________________________________________________
;
Ed_System
	JJmp	L_TheEnd
Ed_End	tst.b	Ed_Ok(a5)			Systeme installe?
	beq.s	.Skip
	bsr	Edt_DelWindows			Enleve les fenetres
.Skip	lea	Ed_Prg2ReLoad(a5),a0		Programme a recharger
	bsr	Ed_MemFree
	bsr	Ed_CloseEditor			Ferme l'editeur
	bsr	Ed_FreeAllConfig		Delete les configs
	rts

;______________________________________________________________________________
;
;							CLOSE/OPEN EDITOR
;______________________________________________________________________________
;

Ed_OpenEditor
	movem.l	d1-d7/a0-a6,-(sp)
	tst.b	Ed_Opened(a5)
	bne.s	.Ok

	bsr	Ed_OpenIt		Premier essai
	beq.s	.Ok

	bsr	Ed_CloseIt		Out of mem, on efface
	bsr	EdM_Program		Menus du programme
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_SetBanks		Change les banques
	JJsr	L_MemMaximum		Nettoie au maximum!

	bsr	Ed_OpenIt		Deuxieme essai!
	beq.s	.Ok
	bsr	Ed_CloseIt
	bsr	EdM_Program
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_SetBanks		Change les banques
	JJsr	L_MemDelBanks		Ligne: effacer les banques?
	beq	Ed_System		NON: on sort!
	JJsr	L_Bnk.EffAll		Efface toutes les banques
	JJsr	L_Bnk.Change		Changement de banques

	bsr	Ed_OpenIt
	beq.s	.Ok
	bsr	Ed_CloseIt
	moveq	#1,d0			Out of mem
	bra.s	.Out
.Ok	move.b	#1,Ed_Opened(a5)	Flag!
	moveq	#0,d0			C'est bon!
.Out	movem.l	(sp)+,d1-d7/a0-a6
	rts

; Routine d'ouverture de l'editeur...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_OpenIt
	bsr	Ed_SetBanks
	bsr	EdM_Editor
; Verification de la taille des fenetres / Config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	EdC_Modified(a5)
	beq	.ModX
	clr.b	EdC_Modified(a5)
	move.l	Edt_Current(a5),d0	Des fenetres?
	beq	.ModX
; Verification de la taille en Y
	move.l	d0,a4			Fenetre courante
	moveq	#-1,d0			Sans toucher les autres
	bsr	Edt_WMaxSize
	cmp.w	Edt_WindTy(a4),d0	Pareil?
	beq.s	.Mod5
	moveq	#0,d0			Reduit les autres
	bsr	Edt_WSchrinkAll
	moveq	#-1,d0
	bsr	Edt_WMaxSize		Taille maxi acceptable
	move.w	d0,Edt_WindTy(a4)
	bgt	.Mod5			Ok!
.Mod2	move.w	#1,Edt_WindTy(a4)	Taille mini!
	moveq	#Ed_TitreSy,d1		Compte la taille necessaire!
	move.l	Edt_List(a5),d0		Toute la liste
.Mod3	move.l	d0,a0
	tst.b	Edt_Hidden(a0)		Deja cachee
	bne.s	.Mod4
	add.w	#Edt_EtatSy+Edt_BasSy,d1
	move.w	Edt_WindTy(a0),d0
	lsl.w	#3,d0
	add.w	d0,d1
.Mod4	move.l	Edt_Next(a0),d0
	bne.s	.Mod3
	move.w	d1,Ed_Sy(a5)		Change la config!!!!
; Verification de la position du curseur en X
.Mod5	move.w	Ed_Sx(a5),d1		Derniere limite curseur
	lsr.w	#3,d1
	subq.w	#3,d1
	move.l	Edt_List(a5),d0		Toute la liste
.Mod6	move.l	d0,a0
	tst.b	Edt_Hidden(a0)		Deja cachee
	bne.s	.Mod7
	move.w	Edt_XCu(a0),d0
	cmp.w	d1,d0
	bcs.s	.Mod7
	move.w	d1,Edt_XCu(a0)
	sub.w	d1,d0
	add.w	d0,Edt_XPos(a0)
.Mod7	move.l	Edt_Next(a0),d0
	bne.s	.Mod6
.ModX
	bsr	EdC_SetPalette		Update de la palette

	moveq	#EcFonc,d0		Ouverture de l'ecran de fonctions
	move.w	Ed_Sx(a5),d1
	ext.l	d1
	moveq	#Es_TitleSy,d2
	moveq	#0,d3
	move.l	Ed_Resource(a5),a0
	add.l	2(a0),a0
	moveq	#0,d4
	JJsrR	L_Dia_RScOpen,a1
	bne	.Error
	bset	#BitHide,EcFlags(a0)
	move.w	Ed_Wx(a5),EcAWX(a0)
	moveq	#20,d1
	SyCall	ResZone
	bne	.Error

	moveq	#EcEdit,d0		Ouverture de l'ecran principal
	move.w	Ed_Sx(a5),d1
	ext.l	d1
	move.w	Ed_Sy(a5),d2
	addq.w	#7,d2
	and.w	#$FFF8,d2
	move.w	d2,d3
	sub.w	#16,d3
	sub.w	#Ed_YTop,d3
	lsr.w	#3,d3
	move.w	d3,Ed_Ty(a5)
	ext.l	d2
	moveq	#1,d3
	moveq	#0,d4			Interlaced?
	move.b	Ed_Inter(a5),d4
	move.l	Ed_Resource(a5),a0
	add.l	2(a0),a0
	JJsrR	L_Dia_RScOpen,a1
	bne.s	.Error
	bset	#BitHide,EcFlags(a0)
	move.w	Ed_Wx(a5),EcAWX(a0)
	move.w	Ed_Wy(a5),EcAWY(a0)
	moveq	#10,d0
	bsr	Et_Print

	move.w	Ed_Ty(a5),d0		Buffer d'edition
	mulu	#256,d0
	SyCall	MemFast
	move.l	a0,Ed_BufE(a5)
	beq	.Error

	moveq	#0,d0			Nombre maximum de programmes
	move.w	Ed_Ty(a5),d0
	subq.w	#6,d0
	divu	#3,d0
	move.w	d0,Ed_WMax(a5)

	jsr	Tok_Init		Les tables de tokenisation
	bne.s	.Error
	bsr	Ed_InitDialogues	Les dialogues
	bne.s	.Error
	bsr	EdM_Init		Cree les menus
	bne.s	.Error
	bsr	Prg_CreateUndos		Les buffers UNDOS de programmes

; Pas d'erreur
	clr.b	EdC_Modified(a5)	Config adaptee...
	moveq	#0,d0			Pas d'erreur!
	rts
; Out of memory
.Error	moveq	#1,d0			Out of memory
	rts


; 	Fermeture generale de l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_KillEditor
	bsr	Ed_CloseEditor		Plus rien
	bsr	Ed_FreeAllConfig	Plus aucune configuration
	clr.b	Ed_Ok(a5)		Plus en etat de marche...
	rts

;	Fermeture de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_CloseEditor
	tst.b	Ed_Opened(a5)
	beq.s	.Skip
	clr.b	Ed_Opened(a5)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	Ed_CloseIt
	movem.l	(sp)+,d0-d7/a0-a6
.Skip	rts

; Routine de fermeture..
; ~~~~~~~~~~~~~~~~~~~~~~
Ed_CloseIt
	bsr	Ed_SetBanks		Banques de l'editeur
	bsr	Prg_FreeUndos		Plus de buffer UNDOS
	bsr	Esc_KMemEnd		Plus de touches de mode direct
	bsr	Ed_AllAverFin		Plus d'avertissement
	bsr	Ed_BlocFree		Plus de bloc
	bsr	EdM_End			Plus de menus
	bsr	Ed_EndDialogues		Plus de dialogues
	bsr	Edt_DelAllZones		Plus de zones de fenetres
	EcCalD	Del,EcEdit		Plus d'ecrans
	EcCalD	Del,EcFonc
	jsr	Tok_Del			Plus de tokenisation
	move.l	Ed_BufE(a5),d0		Plus de buffer d'edition
	beq.s	.Skip
	clr.l	Ed_BufE(a5)
	move.l	d0,a1
	move.w	Ed_Ty(a5),d0
	mulu	#256,d0
	SyCall	MemFree
.Skip	rts

; Retourne la memoire libre dans la machine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Available
	movem.l	a0/a1/a6,-(sp)
	move.l	$4.w,a6
	move.l	#Public|Fast,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,d2
	move.l	#Public|Chip,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,d1
	add.l	d2,d0
	movem.l	(sp)+,a0/a1/a6
	rts

;______________________________________________________________________________
;
; 			WARM START Charge le fichier / Prepare l'editeur
;______________________________________________________________________________
;
Ed_WarmStart
; Fichier "Last Cession" present?
	moveq	#47,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	JJsr	L_RExist
	beq	.Out
; Message
	move.w	#159,d0
	bsr	Ed_AverMess
; Efface la premiere fenetre systeme
	move.l	Edt_List(a5),d0
	beq.s	.No1
	move.l	d0,a4
	bsr	Edt_DelWindow
.No1
; PHASE 1: re-creation des listes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1005,d2		Ouvre le fichier
	bsr	Ed_Open
	beq	.Err1
; Verifie l'entete
	move.l	Buffer(a5),a3
	move.l	a3,d2
	moveq	#8,d3
	bsr	Ed_Read
	bne	.Err0
	cmp.l	#Ed_QuitHead,(a3)
	bne	.Err0
; Charge dans un buffer
	move.l	4(a3),d0		Taille necessaire
	JJsr	L_ResTempBuffer
	beq	.Err0
	move.l	a0,d2
	move.l	4(a3),d3
	bsr	Ed_Read
	bne	.Err0
	bsr	Ed_Close
; Trouve les structures
	move.l	TempBuffer(a5),a6	A6= Structures programmes
	move.l	a6,a4			A4= Structures edition
	moveq	#-8,d0
.GLoop	lea	8(a4,d0.l),a4
	move.l	4(a4),d0
	tst.l	(a4)+
	bne.s	.GLoop
; Recree la liste PRG
	lea	Prg_List(a5),a2
	move.l	a6,a3
.PCree	move.l	#Prg_Long,d0		Reserve la memoire
	SyCall	MemFastClear
	beq	.Err
	move.l	a0,Prg_Next(a2)		Branche dans la liste
	move.l	a0,a2
	move.l	a0,8(a3)		Stocke l'adresse
	moveq	#Prg_Long/2-1,d0
	lea	12(a3),a1
.PCop	move.w	(a1)+,(a0)+		Copie les datas
	dbra	d0,.PCop
	move.l	Prg_StTTexte(a2),Prg_StBas(a2)
	clr.l	Prg_StTTexte(a2)
	clr.l	Prg_Dialogs(a2)		Erase donnees importantes!
	clr.l	Prg_Banks(a2)
	clr.l	Prg_Undo(a2)
	clr.l	Prg_AdEProc(a2)
	clr.l	Prg_ZapData(a2)
	clr.l	Prg_RunData(a2)
	clr.l	Prg_Previous(a2)
	move.l	4(a3),d0		Encore un?
	lea	12(a3,d0.l),a3
	tst.l	(a3)
	bne.s	.PCree
; Recree la liste EDT
	lea	Edt_List(a5),a2
	move.l	a4,a3
.ECree	move.l	#Edt_Long,d0		Reserve la memoire
	SyCall	MemFastClear
	beq	.Err
	move.l	a0,Edt_Next(a2)		Branche dans la liste
	move.l	a0,a2
	move.l	a0,8(a3)		Change le pointeur
	moveq	#Edt_Long/2-1,d0
	lea	12(a3),a1
.ECop	move.w	(a1)+,(a0)+		Copie les datas
	dbra	d0,.ECop
	move.l	4(a3),d0		Encore un?
	lea	12(a3,d0.l),a3
	tst.l	(a3)
	bne.s	.ECree
; Relinke les fenetres
	move.l	Edt_List(a5),a3
.LLoop	lea	Edt_Prg(a3),a0		Structure programme
	move.l	a6,a1			Explorer les programmes
	bsr	.Linke
	lea	Edt_LinkPrev(a3),a0	Link previous
	move.l	a4,a1
	bsr	.Linke
	lea	Edt_LinkNext(a3),a0	Link next
	move.l	a4,a1
	bsr	.Linke
	lea	Edt_LinkScroll(a3),a0	Link de scroll
	move.l	a4,a1
	bsr	.Linke
	tst.w	Edt_Order(a3)		Programme courant?
	beq.s	.Pac
	move.l	a3,Edt_Current(a5)
.Pac	move.l	Edt_Next(a3),d0
	move.l	d0,a3
	bne.s	.LLoop
; On peut effacer le buffer!
	moveq	#0,d0
	JJsr	L_ResTempBuffer

; PHASE 2 : recharge tous les programmes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_List(a5),a6
.CLoop	lea	Prg_NamePrg(a6),a0	Recopie le nom
	move.l	Name1(a5),a1
	bsr	EdCocop
	move.l	Prg_StBas(a6),d0	Change la taille du buffer
	JJsr	L_Prg_ChgTTexte
	beq	.Err
	moveq	#1,d0			Charge sans adapter
	JJsr	L_Prg_Load
	bne	.Err
	tst.b	Prg_NoNamed(a6)		Enleve le nom si necessaire
	beq.s	.Name
	clr.b	Prg_NamePrg(a6)
	clr.b	Prg_NoNamed(a6)
	move.b	#1,Prg_Change(a6)	Force une sauvegarde si close...
	move.l	a6,-(sp)
	move.l	Name1(a5),d1		Efface, si possible
	move.l	DosBase(a5),a6		Sans verification...
	jsr	_LVODeleteFile(a6)
	move.l	(sp)+,a6
.Name	move.l	Prg_Next(a6),d0
	move.l	d0,a6
	bne.s	.CLoop

; TERMINE: efface le fichier, puis raffiche les fenetres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	.DelFichier
	bsr	Prg_CreateUndos
	bsr	EdM_BranchAMOS
	bsr	Ed_DrawWindows
.Out	rts


; Destruction du fichier d'informations
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.DelFichier
	bsr	Ed_Close
	moveq	#47,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	move.l	Name1(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVODeleteFile(a6)
	tst.l	d0
	beq.s	.DelPa
	rts
.DelPa	moveq	#EdD_WarmDel,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	beq.s	.DelFichier
; Efface tout, puis FATAL!
	bsr	.Err
	bra	Ed_System

; Change les pointeurs de fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Linke	move.l	(a0),d0
	beq.s	.PoX
.PoL	cmp.l	(a1),d0
	beq.s	.PoF
	move.l	4(a1),d1
	lea	12(a1,d1.w),a1
	tst.l	(a1)
	bne.s	.PoL
.PoF	move.l	8(a1),(a0)
.PoX	rts

; Erreur pendant le rechargement: efface tout!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Err
; Les programmes
	move.l	Prg_List(a5),d6
	bra.s	.EPrg1
.EPrg0	move.l	d6,a6
	move.l	Prg_Next(a6),d6		Stocke le suivant
	moveq	#0,d0			Buffer eventuellement reserve
	JJsr	L_Prg_ChgTTexte
	move.l	Prg_Banks(a6),Cur_Banks(a5)
	JJsr	L_Bnk.EffAll		Banques eventuellement reservees
	move.l	a6,a1			Libere la memoire
	move.l	#Prg_Long,d0
	SyCall	SyFree
.EPrg1	tst.l	d6			Encore un?
	bne.s	.EPrg0
	clr.l	Prg_List(a5)
; Les fenetres
	move.l	Edt_List(a5),d4
	bra.s	.EEdt1
.EEdt0	move.l	d4,a4
	move.l	Edt_Next(a4),d4		Stocke le suivant
	move.l	a4,a1			Libere la memoire
	move.l	#Edt_Long,d0
	SyCall	SyFree
.EEdt1	tst.l	d4			Encore un?
	bne.s	.EEdt0
	clr.l	Edt_List(a5)
; Va effacer le fichier
.Err1	bsr	.DelFichier
; Ferme le fichier courant
.Err0	bsr	Ed_Close		Ferme le fichier
	moveq	#0,d0			Efface le buffer
	JJsr	L_ResTempBuffer
; ROuvre la premiere fenetre
	clr.l	Edt_Current(a5)
	moveq	#-1,d0			Visible
	move.l	PI_DefSize(a5),d1	Taille
	sub.l	a4,a4			Pas de fenetre courante
	bsr	Edt_OpWindow
	bsr	EdM_BranchAMOS
	bsr	Ed_DrawWindows
; Boite de dialogue
	moveq	#EdD_WarmErr,d0
	bsr	Ed_Dialogue
	rts

;______________________________________________________________________________
;
;						Dessin du titre
;______________________________________________________________________________
;
Ed_DrawTop

	movem.l	a2/d2-d7,-(sp)

;
; Reserve les zones
; ~~~~~~~~~~~~~~~~~
	move.l	#Ed_BoutonsZones+15,d1
	SyCall	ResZone
	move.w	Ed_Sx(a5),d7

; Unpack le logo AMOS
; ~~~~~~~~~~~~~~~~~~~
	moveq	#Ed_Pics,d0
	moveq	#Ed_BoutonsSx,d1
	moveq	#Ed_YTop,d2
	bsr	Ed_Unpack
	sub.w	#Ed_TitleSx,d7
;
; Cree les 12 boutons
; ~~~~~~~~~~~~~~~~~~~
	lea	Ed_Boutons(a5),a2
	move.w	#Ed_BoutonsX,d2
	moveq	#Ed_BoutonsY,d3
	moveq	#Ed_BoutonsPics,d4
	move.w	#Ed_BoutonsZones,d5
	moveq	#1,d6
.Loop	move.w	d6,Bt_Number(a2)
	cmp.w	#1,d6
	bne.s	.Pa1
	clr.w	Bt_X(a2)			Bouton DIRECT
	bra.s	.PaB
.Pa1	cmp.w	#2,d6
	bne.s	.Pa2
	move.w	Ed_Sx(a5),Bt_X(a2)		Bouton WB
	sub.w	#Ed_BoutonsSx,Bt_X(a2)
	bra.s	.PaB
.Pa2	move.w	d2,Bt_X(a2)
	add.w	#Ed_BoutonsSx,d2
.PaB	move.w	d3,Bt_Y(a2)
	move.w	d4,Bt_Image(a2)
	move.w	d5,Bt_Zone(a2)
	lea	Bt_RoutIn(pc),a0
	move.l	a0,Bt_Routines(a2)
	move.b	#6,Bt_RDraw(a2)
	clr.b	Bt_RPos(a2)
	clr.b	Bt_RChange(a2)
	clr.b	Bt_Flags(a2)
	clr.w	Bt_Pos(a2)
	cmp.w	#Bt_Insert,d6			Bouton INSERT?
	bne.s	.PaI
	bset	#Bt_FlagOnOf,Bt_Flags(a2)
	tst.b	Ed_Insert(a5)
	bne.s	.PaI
	move.w	#1,Bt_Pos(a2)
.PaI	move.b	#Ed_BoutonsSx,Bt_Sx(a2)
	move.b	#Ed_BoutonsSy,Bt_Sy(a2)
	addq.w	#2,d4
	addq.w	#1,d5
	move.l	a2,a0
	moveq	#1,d0
	JJsrR	L_Bt_Init,a1
	sub.w	#Ed_BoutonsSx,d7
	lea	Bt_Long(a2),a2
	addq.w	#1,d6
	cmp.w	#12,d6
	bls	.Loop
	clr.w	(a2)

; Dessine les sliders de memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	d2,d1
	moveq	#Ed_YTop,d2
	move.w	d7,d3
	lea	Ed_Unpack(pc),a2
	bsr	Ed_MemoryDraw
	bsr	Ed_MemoryAff

; Fini!
; ~~~~~
	movem.l	(sp)+,a2/d2-d7
	rts

; Dessine les sliders de memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1=	X
;	D2=	Y
;	D3=	Largeur
;	A2= 	Adresse UNPACK
Ed_MemoryDraw
	move.w	d3,d0
	sub.w	#Ed_BoutonsSx+7,d0
	move.w	d0,Ed_MemorySx(a5)

	moveq	#Ed_MemoryPics,d0	La gauche
	jsr	(a2)
	add.w	#Ed_BoutonsSx,d1
 	move.w	d1,Ed_MemoryX(a5)

	divu	#Ed_BoutonsSx,d3
	subq.w	#2+1,d3
.Loop	moveq	#Ed_MemoryPics+1,d0
	jsr	(a2)
	add.w	#Ed_BoutonsSx,d1
	dbra	d3,.Loop
	moveq	#Ed_MemoryPics+2,d0
	jmp	(a2)

; Dessine le contenu des sliders de memoire.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_MemoryAff
	move.l	a6,-(sp)
	move.l	$4.w,a6
; Dessin du slider de CHIP MEM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#Chip|Public,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,-(sp)
	move.l	MemChipTotal(a5),d4
	move.l	d4,d3
	sub.l	d0,d3
	move.w	Ed_MemoryX(a5),d1
	move.w	#Ed_MemoryY1,d2
	bsr	.Memory
; Dessin du slider de FAST MEM
	move.l	#Public|Fast,d1
	jsr	_LVOAvailMem(a6)
	add.l	d0,(sp)
	move.l	MemFastTotal(a5),d4
	move.l	d4,d3
	sub.l	d0,d3
	move.w	Ed_MemoryX(a5),d1
	move.w	#Ed_MemoryY2,d2
	bsr	.Memory
; Stocke le resultat memoire globale
	move.l	(sp)+,Ed_MemCurrent(a5)
	move.l	(sp)+,a6
	rts

; Routine de dessin
; ~~~~~~~~~~~~~~~~~
.Memory
; Une place dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),a2
	move.l	a2,a0
	moveq	#Sl_Long-1,d0
.Loop	clr.b	(a0)+
	dbra	d0,.Loop
; Longueur du slider
	lsr.l	#8,d4
	lsr.l	#8,d3
	move.w	d4,Sl_Global(a2)
	move.w	d3,Sl_Window(a2)
; Position
	move.w	d1,Sl_X(a2)
	move.w	d2,Sl_Y(a2)
	move.w	Ed_MemorySx(a5),Sl_Sx(a2)
	move.w	#Ed_MemorySy,Sl_Sy(a2)
; Couleurs
	moveq	#23,d0
	bsr	Ed_GetSysteme
	lea	Sl_Inactive(a2),a1
	moveq	#16-1,d0
.Co	moveq	#0,d1
	move.b	(a0)+,d1
	move.w	d1,(a1)+
	dbra	d0,.Co
; Appelle le dessin
	move.l	a2,a0
	JJsrR	L_Sl_Init,a1
	rts

;______________________________________________________________________________
;
;						Boucle principale de l'�diteur
;______________________________________________________________________________
;
Ed_Loop

	move.l	BasSp(a5),sp
	EcCalD	Active,EcEdit

; Flag: editeur en etat de marche!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.b	#1,Ed_Ok(a5)
 	move.w	#1,T_AMOState(a5)	Editeur present!

; Efface une fenetre en rab
; __________________________
;
	move.l	Ed_WindowToDel(a5),d0
	beq.s	.PaDel
	move.l	d0,a4
	clr.l	Ed_WindowToDel(a5)
	tst.b	Edt_Hidden(a4)
	bne.s	.Visi
	bsr	Ed_CloseWindow
	bra	Ed_Loop
.Visi	bsr	Edt_DelWindow
	bsr	EdM_BranchAMOS
	bra	Ed_Loop
.PaDel
;
; Eventuellement, efface tous les avertissements
; ______________________________________________
;
	bsr	Ed_AllAverFin
;
; Recharge un programme apres PRG COMMAND
; _______________________________________
;
	move.l	Ed_Prg2ReLoad(a5),d0
	bne	Ed_PrgReLoad

	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	move.b	Prg_MathFlags(a6),MathFlags(a5)
;
; Securites
; __________________________
;
	clr.b	Ed_FUndo(a5)		Undo
	clr.b	Ed_RunnedHidden(a5)

;
; Gestion des multi windows
; ___________________________
;
	moveq	#0,d0
	move.l	a4,a0
	or.b	Ed_SCallFlags(a5),d0
	bsr	Ed_Splitted
	clr.b	Ed_SCallFlags(a5)
;
; Gestion des scrollings lies
; _____________________________
;
	bsr	Ed_LinkeScroll
;
; Gestion du curseur avec un bloc
; _______________________________
;
	bsr	Ed_BlocAff
;
; Gestion de la fenetre d'informations pour toutes les fenetres
; _____________________________________________________________
;
; Exploration de la liste
	move.l	Edt_List(a5),d0
.Liip	move.l	d0,a4
	tst.b	Edt_Hidden(a4)
	bne.s	.Naxt
	move.l	Edt_Prg(a4),a6
; Affichage general
; ~~~~~~~~~~~~~~~~
	move.b	Ed_EtatAff(a5),d0
	or.b	d0,Edt_EtatAff(a4)
; Efface le message d'alerte?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	Edt_EtMess(a4)
	beq.s	.PaMess
	subq.w	#1,Edt_EtMess(a4)
	bne.s	.PaMess
	move.b	#EtA_BAll,Edt_EtatAff(a4)
.PaMess
; Va reafficher la fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_EtPrintD0
; Affiche le slider
; ~~~~~~~~~~~~~~~~~
	tst.b	Edt_ASlY(a4)
	beq.s	.PaSlY
	subq.b	#1,Edt_ASlY(a4)
	bne.s	.PaSlY
	bsr	Ed_AffSlV
.PaSlY
; Suivant
; ~~~~~~~
.Naxt	move.l	Edt_Next(a4),d0
	bne.s	.Liip
	clr.b	Ed_EtatAff(a5)

;
; Demarre les menus si pas definis
; ________________________________
;
	tst.b	Ed_Zappeuse(a5)			Pas en zappeuse
	bne.s	.Menula
	cmp.l	#1024*72,Ed_MemCurrent(a5)	Si moins de 72k
	bcc.s	.Domenu
	tst.b	Ed_NewAppear(a5)		Peut-on essayer un clearvar?
	beq.s	.Menula
	subq.b	#1,Ed_NewAppear(a5)
	bne.s	.Deuse
; Fait un peu de place
	JJsr	L_Mon_Free			Plus de moniteur
	JJsr	L_Math_Close			Plus de librairie math
	bsr	Prg_RazUndos			Plus d'UNDO
	SyCall	MemFlush			Flush la memoire...
; Essaie d'ouvrir les menus...
.Deuse	move.w	#186,d0				Low memory!
	bsr	Ed_GetMessage
	moveq	#125,d0
	bsr	Ed_AlertRts
	clr.b	Ed_Sounds(a5)			Plus de sons
	bsr	Ed_SamChanged
	bsr	EdM_Program
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_SetBanks
	JJsr	L_MemMaximum
.Domenu	tst.l	EdM_Table(a5)			Les menus sont la?
	bne.s	.Menula
	bsr	EdM_Init
	bra	Ed_Loop
.Menula

;
; Gestion du programme courant
; ____________________________________
;
	move.l	Edt_Current(a5),a4		Fenetre
	move.l	Edt_Prg(a4),a6
	move.w	Edt_Window(a4),d1
	WiCall	QWindow
	tst.b	Ed_CuFlag(a5)			Curseur
	bne.s	.PaCu
	move.b	#1,Ed_CuFlag(a5)
	bsr	Ed_CuOn
.PaCu

;
; Scrolling pour recentrer le curseur?
; ____________________________________
;
; 1. A gauche
; ~~~~~~~~~~~
	move.w	Edt_XPos(a4),d0
	move.w	Edt_XCu(a4),d1
	sub.w	d0,d1
	cmp.w	#Ed_XScrollG,d1
	bcc.s	.SkipL
	tst.w	d0
	beq.s	.SkipL
	bsr	Ed_CuOff
	bsr	Ed_CGo
	bra	Ed_Loop
.SkipL
; 2. A droite
; ~~~~~~~~~~~
	move.w	Edt_WindTx(a4),d1
	sub.w	Edt_XCu(a4),d1
	add.w	d0,d1
	cmp.w	#Ed_XScrollD,d1
	bcc.s	.SkipD
	cmp.w	#200,d0
	bcc.s	.SkipD
	bsr	Ed_CuOff
	bsr	Ed_CDr
	bra	Ed_Loop
.SkipD
; Haut / Bas, calcule les tailles
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	Edt_WindTy(a4),d1
	cmp.w	#2,d1
	bls.s	.SEnd
	moveq	#1,d2
	moveq	#1,d3
	cmp.w	#7,d1
	bcs.s	.SkipT
	moveq	#Ed_YScrollH/2,d2
	moveq	#Ed_YScrollB/2,d3
	cmp.w	#(Ed_YScrollH+Ed_YScrollB)*2,d1
	bcs.s	.SkipT
	move.w	d1,d2
	mulu	#Ed_YScrollH,d2
	divu	#25,d2
	move.w	d1,d3
	mulu	#Ed_YScrollB,d3
	divu	#25,d3
.SkipT
; 3. En haut.
; ~~~~~~~~~~~
	cmp.w	Edt_YCu(a4),d2
	bls.s	.SkipH
	tst.w	Edt_YPos(a4)
	beq.s	.SkipH
	bsr	Ed_CuOff
	bsr	Ed_SHaut2
	addq.w	#1,Edt_YCu(a4)
	bsr	Ed_Loca
	bra	Ed_Loop
.SkipH
; 4. En bas
; ~~~~~~~~~
	move.w	Edt_WindTy(a4),d0
	sub.w	Edt_YCu(a4),d0
	cmp.w	d0,d3
	bcs.s	.SEnd
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	cmp.w	Prg_NLigne(a6),d0
	bcc	.SEnd
	bsr	Ed_CuOff
	bsr	Ed_SBas2
	subq.w	#1,Edt_YCu(a4)
	bsr	Ed_Loca
	bra	Ed_Loop
.SEnd

;
; Un programme en t�l�commande?
; _____________________________
;
	tst.b	Ed_Zappeuse(a5)
	beq.s	.PaProg
	addq.w	#1,Ed_ZapCounter(a5)	Attend que l'editeur soit stabilis�
	cmp.w	#5,Ed_ZapCounter(a5)
	bcs	Ed_Loop
	clr.w	Ed_ZapCounter(a5)
	bra	Ed_ZapOut
.PaProg
;
; Gestion du clavier
; __________________
;
	bsr	Ed_Key
	bne	Ed_Loop

;
; Gestion de la souris
; ____________________
;
	bsr	Ed_Mouse
	bne	Ed_Loop

;
; Reafficher le slider de memoire?
; ________________________________
;
	move.w	T_VblCount+2(a5),d0
	and.w	#63,d0
	bne.s	.Skip
	bsr	Ed_MemoryAff
	bra	Ed_Loop
.Skip
;
; Autosave?
;____________
;
	move.l	Ed_AutoSave(a5),d0
	beq.s	.PaAS
	tst.l	Ed_AutoSaveRef(a5)
	bpl.s	.Pan
	move.l	T_VblCount(a5),Ed_AutoSaveRef(a5)
.Pan	move.l	T_VblCount(a5),d1
	sub.l	Ed_AutoSaveRef(a5),d1
	cmp.l	d0,d1
	bcs.s	.PaAS
	move.l	Edt_Current(a5),a4
	tst.w	Edt_LEdited(a4)		Seulement si ligne non editee
	bne.s	.PaAS
	move.l	#-1,Ed_AutoSaveRef(a5)
	bsr	Ed_SaveAuto
	bra	Ed_Loop
.PaAS
;
; Multitache!
; ___________
;
	JJsr	L_Sys_WaitMul
	bra	Ed_Loop


; __________________________________________________________________________
;
; 	Teste la souris
; __________________________
;
Ed_Mouse


; Une touche?
; ~~~~~~~~~~~
	SyCall	MouseKey
	move.b	d1,Ed_MkIns(a5)
	cmp.b	Ed_OMKey(a5),d1
	bne.s	.MkC
	addq.w	#1,Ed_MkCpt(a5)
	bra.s	.MkS
.MkC	clr.w	Ed_MkCpt(a5)
	move.b	d1,Ed_OMKey(a5)
.MkS	moveq	#1,d2
.EdMk0	btst	d2,Ed_MkFl(a5)
	bne.s	.EdMk1
; Appuie sur la touche
	btst	d2,d1
	beq.s	.EdMk2
	bset	d2,Ed_MkFl(a5)
	bset	d2,Ed_MKey(a5)
	bra.s	.EdMk2
; Doit relacher la touche
.EdMk1	bclr	d2,Ed_MKey(a5)
	btst	d2,d1
	bne.s	.EdMk2
	bclr	d2,Ed_MkFl(a5)
.EdMk2	dbra	d2,.EdMk0
	move.b	Ed_MkIns(a5),d7
	and.w	#3,d7
	beq	Ed_MQuit

; Une macro en route?
; ~~~~~~~~~~~~~~~~~~~
	tst.w	EdMa_Tape(a5)
	bne	EdMa_Stop
	tst.l	EdMa_Play(a5)
	beq.s	.PaMacro
	clr.l	EdMa_Play(a5)
.PaMacro

; Le menu?
; ~~~~~~~~
	btst	#1,d7
	beq.s	.NoMenu
	bsr	Ed_MnGere
	beq	Ed_MEnd
	bmi.s	.Err
	moveq	#0,d1
	bsr	Ed_FCall
	bra	Ed_MEnd
.Err	bsr	EdM_Error
	bra	Ed_MEnd
.NoMenu

; Une Zone?
; ~~~~~~~~~
	SyCall	GetZone
	cmp.w	#EcEdit,d1
	bne	Ed_MQuit
	swap	d1
	move.w	d1,d6
; Un bouton du haut?
	cmp.w	#Ed_BoutonsZones,d1
	bcc	Ed_MBouton
; ___________________________
;
; Bouge une separation?
; ___________________________
;
	move.w	d6,d0
	and.w	#$FFF8,d0
	move.w	d6,d1
	and.w	#$07,d1
	cmp.b	#1,d1
	bne.s	.NoZoHo
	bsr	Ed_TokCur
	bsr	Edt_GetAd
	bsr	Ed_MSepHaut
	bra	Ed_MEnd
.NoZoHo
	cmp.w	#2,d1
	bne.s	.NoZoBa
	bsr	Ed_TokCur
	bsr	Edt_GetAd
	bsr	Ed_MSepBas
	bra	Ed_MEnd
.NoZoBa
; _____________________
;
; Un bouton de fenetre
; _____________________
;
	tst.w	d1
	beq.s	.NoBt
	bsr	Edt_GetAd
	beq.s	.NoBt
	lea	Edt_Bt1(a0),a0
	JJsrR	L_Bt_Gere,a1
	bne	Ed_MEnd
.NoBt
; _____________________
;
; Changement de fenetre
; _____________________
;
	move.w	d6,d0
	and.w	#$FFF8,d0
	cmp.w	Edt_Window(a4),d0
	beq.s	.Same
; Doit changer l'�cran actuel
	bsr	Ed_TokCur
	bsr	Edt_GetAd
	beq.s	.Same
	bsr	Edt_Active
	bra	Ed_MEnd
.Same

; ___________________
;
; Click dans le texte
; ___________________
;
	SyCall	XyMou
	moveq	#0,d3
	SyCall	XyScr
	SyCall	XyWin
	move.l	d1,d3
	or.l	d2,d1
	bmi	.NoText

; Positionne le curseur
; ~~~~~~~~~~~~~~~~~~~~~
	btst	#0,d7
	beq.s	.NoText
	move.w	Ed_MkCpt(a5),d0
	beq.s	.Pos
	cmp.w	#20,d0
	bcs	Ed_MQuit
.Pos
	add.w	Edt_XPos(a4),d3
	cmp.w	#250,d3
	bcc	Ed_MQuit
	add.w	Edt_YPos(a4),d2
	cmp.w	Prg_NLigne(a6),d2
	bhi	Ed_MQuit
	sub.w	Edt_YPos(a4),d2
	bsr	Ed_CuOff

	cmp.w	Edt_YCu(a4),d2
	beq.s	.Notok
	bsr	Ed_TokCur
.Notok	move.w	Edt_YCu(a4),d0
	add.w	Edt_YPos(a4),d0
	move.w	d0,Edt_YOldBloc(a4)

; Mode bloc / normal
	cmp.w	Edt_YCu(a4),d2
	bne.s	.Noe
	cmp.w	Edt_XCu(a4),d3
	bne.s	.Noe
	tst.w	Ed_MkCpt(a5)
	bne	Ed_MEnd
	bsr	Ed_BlocOn
	bra	Ed_MEnd
; Positionne le curseur
.Noe	move.w	d2,Edt_YCu(a4)
	move.w	d3,Edt_XCu(a4)
	or.b	#EtA_BXY,Edt_EtatAff(a4)
	bsr	Ed_Loca
	bra	Ed_MEnd
.NoText
; ______________________
;
; Click dans les sliders
; ______________________
;
	lea	Edt_SlV(a4),a0
	cmp.w	Sl_Zone(a0),d6
	bne.s	.NoSlV
	bsr	Ed_CuOff
	bsr	Ed_TokCur
	JJsrR	L_Sl_Clic,a1
	bra	Ed_MQuit
.NoSlV	bra	Ed_MQuit

; ____________________________
;
; Click dans un bouton general
; ____________________________
;
Ed_MBouton
	lea	Ed_Boutons(a5),a0
	JJsrR	L_Bt_Gere,a1
	beq.s	Ed_MEnd
; Appelle la fonction
	move.l	d0,a0
	move.w	Bt_Number(a0),d2
	moveq	#13,d0
	bsr	Ed_GetSysteme
	move.b	-1(a0,d2.w),d2
	subq.w	#1,d2
	bsr	Ed_FCall
Ed_MEnd
	clr.b	Ed_CuFlag(a5)
	moveq	#-1,d0
	rts
Ed_MQuit
	moveq	#0,d0
	rts
; ____________________________
;
; CHANGEMENT DE LA SEPARATION du haut, fenetre A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_MSepHaut
	movem.l	a2-a6/d2-d7,-(sp)
	move.l	a0,a4
	tst.b	Edt_First(a4)
	bne.s	.NoMve
	bsr	Ed_RShLimits
	bsr	Ed_MSep
; Calcule les changements
	bsr	Edt_WChangeHaut
	beq.s	.NoMve
	bsr	Edt_WVideNext
; Modifie l'affichage
	bsr	Ed_DrawWindows
	moveq	#-1,d0
	bra.s	.EMve
.NoMve	moveq	#0,d0
.EMve	movem.l	(sp)+,a2-a6/d2-d7
	rts
; Routine
Ed_RShLimits
	moveq	#0,d0
	bsr	Edt_WMaxSize			; Positions max et min
	tst.b	Edt_Last(a4)
	bne.s	.Last
; Une fenetre au milieu, bouge tout!
	move.w	Edt_WindTy(a4),d0
	lsl.w	#3,d0
	add.w	#Edt_EtatSy+Edt_BasSy,d0	; Taille � bouger
	sub.w	d0,d2				; D2 max
	move.w	Edt_Y(a4),d3			; Position initiale
	rts
; La derniere, bouge juste le haut
.Last	moveq	#Edt_EtatSy,d0			; Taille � bouger
	sub.w	#Edt_EtatSy+Edt_BasSy,d2	; D2 max
	move.w	Edt_Y(a4),d3			; Position initiale
	rts

;
; CHANGEMENT DE LA SEPARATION du bas, fenetre A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_MSepBas
	movem.l	a2-a6/d2-d7,-(sp)
	move.l	a0,a4
	tst.b	Edt_Last(a4)
	bne.s	.NoMve
	bsr	Ed_RSbLimits
	bsr	Ed_MSep
; Va calculer les changements
	bsr	Edt_WChangeBas
	beq.s	.NoMve
	bsr	Edt_WVideNext
; Modifie l'affichage
	bsr	Ed_DrawWindows
	moveq	#-1,d0
	bra.s	.EMve
.NoMve	moveq	#0,d0
.EMve	movem.l	(sp)+,a2-a6/d2-d7
	rts
; Routine
Ed_RSbLimits
	moveq	#0,d0
	bsr	Edt_WMaxSize			; Positions max et min
	moveq	#Edt_BasSy,d0			; Taille � bouger
	add.w	#Edt_EtatSy,d1
	move.w	Edt_BasY(a4),d3			; Position initiale
	rts
; Separation du haut vers le haut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EtatUp
	moveq	#-8,d0
	bra.s	Ed_EtatMove
;
; Separation du haut vers le bas
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EtatDown
	moveq	#8,d0
	bra.s	Ed_EtatMove
;
; Separation du bas vers le haut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BasUp
	moveq	#-8,d0
	bra.s	Ed_BasMove
;
; Separation du bas vers le bas
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BasDown
	moveq	#8,d0
	bra.s	Ed_BasMove
;
; Mouvement relatif de la separation du haut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EtatMove
	bsr	Ed_TokCur
	tst.b	Edt_First(a4)
	bne.s	.NoMve
	move.w	d0,d4
	bsr	Ed_RShLimits
	add.w	d4,d3
	cmp.w	d1,d3
	bls.s	.NoMve
	cmp.w	d2,d3
	bge.s	.NoMve
; Calcule les changements
	move.w	d3,d0
	bsr	Edt_WChangeHaut
	beq.s	.NoMve
	bsr	Edt_WVideNext
	bsr	Ed_DrawWindows
.NoMve	rts
;
; CHANGEMENT relatif de la DE LA SEPARATION du bas
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BasMove
	bsr	Ed_TokCur
	tst.b	Edt_Last(a4)
	bne.s	.NoMve
	move.w	d0,d4
	bsr	Ed_RSbLimits
	add.w	d4,d3
	cmp.w	d1,d3
	bls.s	.NoMve
	cmp.w	d2,d3
	bge.s	.NoMve
; Va calculer les changements
	move.w	d3,d0
	bsr	Edt_WChangeBas
	beq.s	.NoMve
	bsr	Edt_WVideNext
	bsr	Ed_DrawWindows
.NoMve	rts


; __________________________________________________________________________
;
; 	Teste le clavier
; __________________________
;
Ed_Key

; Une macro en lecture?
; ~~~~~~~~~~~~~~~~~~~~~
	move.l	EdMa_Play(a5),d0
	beq.s	.PaMacro
	addq.l	#3,d0
	move.l	d0,a0
	move.l	d0,EdMa_Play(a5)
	move.b	-(a0),d1
	lsl.w	#8,d1
	move.b	-(a0),d1
	swap	d1
	clr.w	d1
	move.b	-(a0),d1			La fin est marquee par -1
	cmp.b	#-1,d1
	bne.s	.EndMac
	clr.l	EdMa_Play(a5)
.PaMacro
; Simule le CONTROL-C
; ~~~~~~~~~~~~~~~~~~~~
	bclr	#BitControl-8,T_Actualise(a5)	* Simule CONTROL-C
	beq.s	.EdPaCc
	move.l	#$08330043,d1
	bra.s	.MacIn
.EdPaCc

; Prend les touches
; ~~~~~~~~~~~~~~~~~
	SyCall	Inkey
.MacIn	tst.l	d1
	beq	Ed_KEnd

; Une macro en enregistrement?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	EdMa_Tape(a5),d0
	beq.s	.UneMac
	move.l	EdMa_List(a5),a0
	lea	8+4-1(a0,d0.w),a0
	cmp.b	#-1,(a0)
	beq.s	.2Big
	move.l	d1,d0
	move.b	d0,(a0)+
	swap	d0
	move.b	d0,(a0)+
	lsr.w	#8,d0
	move.b	d0,(a0)+
	addq.w	#3,EdMa_Tape(a5)
.2Big	bra.s	.EndMac
; La touche en question est-elle une macro?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.UneMac	bsr	EdMa_Adr
	beq.s	.EndMac
	lea	12(a1),a1
	move.l	a1,EdMa_Play(a5)
	bra	Ed_Key
.EndMac

; Une fonction?
; ~~~~~~~~~~~~~
	bsr	Ed_Ky2Fonc
	beq.s	.Char
	bsr	Ed_FCall
	moveq	#-1,d0
	bra	Ed_KEnd
; Stocke la lettre dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Char	move.l	d1,d7
	move.b	Ed_Insert(a5),d6
	bsr	Ed_PKey
	moveq	#"C",d0
	bsr	Ed_SamPlay
	moveq	#-1,d0
;
; Fini pour les touches
; ~~~~~~~~~~~~~~~~~~~~~
Ed_KEnd	rts


; Appelle le menu editeur et retourne le choix, si choix
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_MnGere
	bsr	EdM_Editor
	tst.l	MnBase(a5)		Menus definis?
	beq.s	.Err
	move.l	a6,-(sp)
	move.l	$4.w,a6
	move.l	#Public,d1
	jsr	_LVOAvailMem(a6)	Au moins 40k de libre!
	move.l	(sp)+,a6
	cmp.l	#40*1024,d0
	bcs.s	.Err
	moveq	#"H",d0			Va faire du bruit!
	bsr	Ed_SamPlay
	JJsr	L_MnGere
	bne.s	.Err
	moveq	#"H",d0			Va faire du bruit!
	bsr	Ed_SamPlay
	tst.w	MnChoice(a5)
	beq	.NoChoix
	clr.w	MnChoice(a5)
	lea	MnChoix(a5),a0
	moveq	#3,d1
.MnL	lsl.l	#8,d0
	addq.l	#1,a0
	move.b	(a0)+,d0
	dbra	d1,.MnL
	move.l	EdM_Table(a5),a0
	bra.s	.MnM1
.MnM0	addq.l	#8,a0
.MnM1	move.l	(a0),d1
	beq.s	.NoChoix
	cmp.l	d0,d1
	bne.s	.MnM0
	moveq	#0,d2
	move.b	6(a0),d2
	subq.w	#1,d2
	bmi	.NoChoix
	moveq	#1,d0
	rts
; Pas de choix finalement....
.NoChoix
	moveq	#0,d0
	rts
; Erreur out of memory
.Err	moveq	#-1,d0
	rts

; Explore la table des touches de fonctions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1=	Touche
Ed_Ky2Fonc
	movem.l	d1/d3-d7,-(sp)
	move.b	d1,d7
	cmp.b	#"a",d7		* D7= lettre majuscule
	bcs.s	.EdL5
	cmp.b	#"z",d7
	bhi.s	.EdL5
	sub.b	#"a"-"A",d7
.EdL5	swap 	d1
	move.b	d1,d6		* D6= scancode
	lsr.w	#8,d1
	and.b	#%11111011,d1
	move.b	d1,d5		* D5= shifts
	swap	d1
* Recherche dans la table
.EdL5a	clr.w	d2
	lea	Ed_KFonc(a5),a0
.EdL6	move.b	d5,d4
	move.b	(a0),d0		* Boucle de comparaison
	bpl.s	.EdL7
	cmp.b	#$FF,d0
	beq	.EdL10
	and.b	#$7f,d0		* Compare au scancode
	cmp.b	d0,d6
	bne.s	.EdL9
	bra.s	.EdL8
.EdL7	beq.s	.EdLN		* Rien, passe au suivant
	cmp.b	d0,d7		* Compare au code ASCII
	bne.s	.EdL9
.EdL8	move.b	1(a0),d3	* Compare le SHIFTS...
	bne.s	.EdL8a
	tst.b	d4
	bne.s	.EdL9
	bra.s	.EdLG
.EdL8a	move.b	d4,d0
	and.b	#Shf,d0		* Teste les shifts
	beq.s	.EdL8b
	and.b	d3,d0
	beq.s	.EdL9
	and.b	#255^Shf,d3
	and.b	#255^Shf,d4
	beq.s	.EdLG
.EdL8b	move.b	d4,d0
	and.b	#Ctr,d0		* Teste CONTROL
	beq.s	.EdL8c
	and.b	d3,d0
	beq.s	.EdL9
	and.b	#255^Ctr,d3
	and.b	#255^Ctr,d4
	beq.s	.EdLG
.EdL8c	move.b	d4,d0
	and.b	#Alt,d0		* Teste ALTERNATE
	beq.s	.EdL8d
	and.b	d3,d0
	beq.s	.EdL9
	and.b	#255^Alt,d3
	and.b	#255^Alt,d4
	beq.s	.EdLG
.EdL8d	move.b	d4,d0
	and.b	#Ami,d0		* Teste AMIGA
	beq.s	.EdL9
	and.b	d3,d0
	beq.s	.EdL9
	and.b	#255^Ami,d3
	and.b	#255^Ami,d4
	beq.s	.EdLG
.EdL9	lea	2(a0),a0
	bra	.EdL6
.EdLN	addq.w	#1,d2
	addq.l	#1,a0
	bra	.EdL6
.EdLG:	or.b	d4,d3
	bne.s	.EdL9
	moveq	#-1,d0
	bra.s	.Out
.EdL10	moveq	#0,d0
.Out	movem.l	(sp)+,d1/d3-d7
	rts

; Pointe la touche affectee � une fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	Fonction
;
Ed_Fonc2Ky
	lea	Ed_KFonc(a5),a0
	bra.s	.Skip4
.Loop4	addq.l	#2,a0
	tst.b	(a0)
	bne.s	.Loop4
	addq.l	#1,a0
	cmp.b	#$FF,(a0)
	beq.s	.NoKey
.Skip4	subq.b	#1,d0
	bne.s	.Loop4
	move.l	a0,d0
	rts
.NoKey	moveq	#0,d0
	rts

;
; Stocke la lettre dans le buffer
; 	D6= Insert mode?
;	D7= caractere
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PKey
	cmp.b	#32,d7
	bcs	.EdL15
* Positionne a la fin de la ligne
	bsr	Ed_LCourant
	bne	Ed_NotEdit		Line not editable
	cmp.w	d0,d1
	bls.s	.EdL10a
	move.w	d0,d1
	lea	0(a0,d1.w),a1
	move.w	d1,Edt_XCu(a4)
	movem.l	a0/a1/d0/d1,-(sp)
	bsr	Ed_Cent
	movem.l	(sp)+,a0/a1/d0/d1
* Recupere le code Ascii
.EdL10a
* Gestion UNDO
	bsr	Un_Debut
	bne.s	.Skip
	move.b	#$01,(a2)		Flag Lettre
	move.b	#-1,4(a2)		Move insert
	move.b	d7,5(a2)		Caractere
.Skip
* Recupere le code ASCII
	tst.b	d6
	bne.s	.EdL11
* Mode OVERWRITE
	cmp.w	d0,d1
	beq.s	.EdL13
	move.b	(a1),4(a2)		Ancien caractere
	bra.s	.EdL14
* Mode INSERT
.EdL11	cmp.w	#250,d0
	bcc	Ed_LToLong
	cmp.w	d0,d1
	beq.s	.EdL13
	lea	1(a0,d0.w),a2
.EdL12	move.b	-(a2),1(a2)
	cmp.l	a1,a2
	bhi.s	.EdL12
.EdL13	addq.w	#1,d0
.EdL14	move.b	d7,(a1)
	move.w	d0,-2(a0)
	addq.w	#1,Edt_LEdited(a4)		* Flag ligne editee
; Bouge le curseur
	bsr	Ed_CDroite
	move.w	Edt_YCu(a4),d1
	bsr	Ed_ALigne
; Reaffiche la ligne
.EdL15	bsr	Ed_Loca
; Si la fenetre est splitee
	move.b	#%01,Ed_SCallFlags(a5)
	rts

;
; Insere le mot A0/long D0 dans la ligne courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
R_InsChar
	movem.l	a0-a3/d0-d2,-(sp)
	move.l	a0,a2
	move.w	d0,d2
	bsr	Ed_LCourant
	add.w	d2,d0
	cmp.w	#250,d0
	bls.s	.Ok
	sub.w	#250,d0
	sub.w	d0,d2
	move.w	#250,d0
.Ok	tst.w	d2
	beq.s	.Out
	add.w	d2,-2(a0)
	lea	0(a0,d0.w),a0
	move.l	a0,a3
	sub.w	d2,a3
	bra.s	.Test
.Copy	move.b	-(a3),-(a0)
.Test	cmp.l	a1,a3
	bhi.s	.Copy
	subq.w	#1,d2
.Loop	move.b	(a2)+,(a1)+
	dbra	d2,.Loop
	addq.w	#1,Edt_LEdited(a4)
.Out	movem.l	(sp)+,a0-a3/d0-d2
	rts
;
; Enleve D0 caracteres en position courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
R_DelChar
	move.w	d0,d2
	bsr	Ed_LCourant
	cmp.w	d0,d2
	bhi.s	.Skip
	sub.w	d2,-2(a0)
	lea	0(a1,d2.w),a0
	sub.w	d1,d0
	sub.w	d2,d0
	subq.w	#1,d0
	bmi.s	.Del2
.Del1	move.b	(a0)+,(a1)+
	dbra	d0,.Del1
.Del2	addq.w	#1,Edt_LEdited(a4)
.Skip	rts

; _________________________________________________________________________
;
; 	GESTION UNDO MULTIPLE
; _________________________________________________________________________
;


; 	UNDO
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Undo	move.l	Prg_PUndo(a6),a2
	bsr	Un_Prev
	move.b	(a2),d0
	beq	Ed_NoUndo
	move.l	a2,Prg_PUndo(a6)
; Appele la fonction
	and.w	#$7f,d0
	lsl.w	#2,d0
	lea	JUndo(pc),a0
	addq.b	#1,Ed_FUndo(a5)
	jsr	-4(a0,d0.w)
	subq.b	#1,Ed_FUndo(a5)
	rts

;	REDO
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Redo	move.l	Prg_PUndo(a6),a2
	move.b	(a2),d0
	beq	Ed_NoRedo
; Appelle la fonction
	and.w	#$7f,d0
	lsl.w	#2,d0
	lea	JRedo(pc),a0
	addq.b	#1,Ed_FUndo(a5)
	jsr	-4(a0,d0.w)
	subq.b	#1,Ed_FUndo(a5)
; Passe au suivant
	move.l	Prg_PUndo(a6),a2
	bsr	Un_Next
	move.l	a2,Prg_PUndo(a6)
.Out	rts


; 	Cree les buffer UNDO de toutes les fenetres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_CreateUndos
	movem.l	d0/a6,-(sp)
	move.l	Prg_List(a5),d0
	beq.s	.Out
.Loop	move.l	d0,a6
	bsr	Prg_UndoCreate
	move.l	Prg_Next(a6),d0
	bne.s	.Loop
.Out	movem.l	(sp)+,d0/a6
	rts
; 	Efface les buffer UNDO de toutes les fenetres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_FreeUndos
	movem.l	d0/a6,-(sp)
	move.l	Prg_List(a5),d0
	beq.s	.Out
.Loop	move.l	d0,a6
	bsr	Prg_UndoFree
	move.l	Prg_Next(a6),d0
	bne.s	.Loop
.Out	movem.l	(sp)+,d0/a6
	rts
; 	Mise � zero de tous les buffers UNDO
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_RazUndos
	movem.l	d0/a6,-(sp)
	move.l	Prg_List(a5),d0
	beq.s	.Out
.Loop	move.l	d0,a6
	bsr	Prg_UndoRaz
	move.l	Prg_Next(a6),d0
	bne.s	.Loop
.Out	movem.l	(sp)+,d0/a6
	rts
;
; Cree le buffer UNDO
; ~~~~~~~~~~~~~~~~~~~
Prg_UndoCreate
	bsr	Prg_UndoFree
	movem.l	d0/d1/a0/a1,-(sp)
	move.l	Ed_NUndo(a5),d0
	beq.s	.Skip
	addq.l	#3,d0
	mulu	#6,d0
	move.l	d0,d1
	SyCall	MemFastClear
	beq.s	.Skip
	move.l	d1,Prg_LUndo(a6)
	move.l	a0,Prg_Undo(a6)
	move.l	a0,a1
	move.b	#$FF,(a1)
	addq.l	#6,a1
	move.l	a1,Prg_PUndo(a6)
	lea	-12(a1,d1.l),a1
	move.b	#$FF,(a1)
	clr.l	Prg_TUndo(a6)
.Skip	movem.l	(sp)+,d0/d1/a0/a1
	rts
;
; Efface tous les mouvements UNDO
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_UndoRaz
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	Prg_Undo(a6),d0
	beq.s	.Skip
	move.l	d0,a2
	lea	6(a2),a2
	move.l	a2,Prg_PUndo(a6)
.Loop	bsr	Un_Del
	addq.l	#6,a2
	cmp.b	#$FF,(a2)
	bne.s	.Loop
.Skip	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
; Efface le buffer UNDO
; ~~~~~~~~~~~~~~~~~~~~~
Prg_UndoFree
	bsr	Prg_UndoRaz
	movem.l	a0/a1/d0,-(sp)
	move.l	Prg_Undo(a6),d0
	beq.s	.Skip
	clr.l	Prg_Undo(a6)
	move.l	d0,a1
	move.l	Prg_LUndo(a6),d0
	SyCall	MemFree
.Skip	movem.l	(sp)+,a0/a1/d0
	rts


JUndo	bra	Un_Char		1- Simple caractere
	bra	Un_Delete	2- Delete
	bra	Un_Clear	3- Effacement ligne / Fin de ligne
	bra	Un_DLine	4- Delete ligne du programme
	bra	Un_Token	5- Tokenisation
	bra	Un_ILine	6- Insertion ligne
	bra	Un_Split	7- Split Line
	bra	Un_Join		8- Join Line
JRedo	bra	Re_Char		1- Simple caractere
	bra	Re_Delete	2- Delete
	bra	Re_Clear	3- Effacement ligne / Fin de ligne
	bra	Re_DLine	4- Delete ligne du programme
	bra	Re_Token	5- Tokenisation
	bra	Re_ILine	6- Insertion ligne
	bra	Re_Split	7- Split Line
	bra	Re_Join		8- Join Line
;
; UNDO: un caractere
; ~~~~~~~~~~~~~~~~~~
Un_Char
	bsr	Un_XY
	move.b	4(a2),d0
	bpl.s	.Over
; En INSERT
	bsr	Ed_Delete
	rts
; En OVERWRITE
.Over	bsr	Ed_LCourant
	move.b	4(a2),(a1)
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_EALiCu
	rts
;
; REDO: un caractere
; ~~~~~~~~~~~~~~~~~~
Re_Char	bsr	Un_XY
	moveq	#0,d6
	tst.b	4(a2)
	bpl.s	.Skip
	moveq	#1,d6
.Skip	move.b	5(a2),d7
	bsr	Ed_PKey
	rts
;
; UNDO: Delete
; ~~~~~~~~~~~~
Un_Delete
	bsr	Un_XY
	move.b	5(a2),d7
	moveq	#1,d6
	bsr	Ed_PKey
	rts
;
; REDO: Delete
; ~~~~~~~~~~~~
Re_Delete
	bsr	Un_XY
	bsr	Ed_Delete
	rts
;
; UNDO: Effacement dans la ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Un_Clear
	bsr	Un_XYSto
Un_C2
	move.w	(a2),d0
	subq.w	#4,d0
	bls.s	.Skip
	lea	4(a2),a0
	bsr	R_InsChar
	bsr	Ed_EALiCu
.Skip	rts
;
; REDO: Effacement dans la ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Re_Clear
	bsr	Un_XYSto
	move.w	(a2),d0
	subq.w	#4,d0
	bls.s	.Skip
	bsr	R_DelChar
.Skip	bsr	Ed_EALiCu
	rts
;
; UNDO: Ligne effacee du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Un_DLine
	bsr	Un_XYSto
	move.l	a2,-(sp)
	bsr	Ed_InsLine
	move.l	(sp)+,a2
	bra.s	Un_C2
;
; REDO: Ligne effacee du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Re_DLine
	bsr	Un_XYSto
	bsr	Ed_DelLiCu
	rts
;
; UNDO: Tokenisation
; ~~~~~~~~~~~~~~~~~~
Un_Token
	bsr	Un_XYSto
	bsr	Ed_LCourant
; Recopie l'ancienne ligne
	lea	6(a2),a1
	moveq	#0,d0
	move.b	(a1)+,d0
	move.w	d0,-2(a0)
	subq.w	#1,d0
	bmi.s	.Skip
.Loop	move.b	(a1)+,(a0)+
	dbra	d0,.Loop
; Une ligne de moins?
.Skip	move.w	4(a2),d0
	sub.w	d0,Prg_NLigne(a6)
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_EALiCu
	rts
;
; REDO: Tokenisation
; ~~~~~~~~~~~~~~~~~~
Re_Token
	bsr	Un_XYSto
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_TokCur
	rts
;
; UNDO: Un-Split line
; ~~~~~~~~~~~~~~~~~~~
Re_Join
Un_Split
	move.l	a2,-(sp)
	bsr	Un_XYSto
	bsr	Ed_DelLiCu
	move.l	(sp)+,a2
	bsr	Un_XYSto
	bsr	Un_RepLine
	rts
;
; UNDO: Un-Join line
; ~~~~~~~~~~~~~~~~~~
Re_Split
Un_Join
	bsr	Un_XYSto
	bsr	Un_RepLine
	bsr	Ed_ReturnQuiet
	rts
;
; Recopie integrale de la ligne
Un_RepLine
	bsr	Ed_LCourant
	move.w	(a2),d0
	subq.w	#4,d0
	lea	4(a2),a1
	move.w	d0,-2(a0)
	subq.w	#1,d0
	bmi.s	.Skip
.Loop	move.b	(a1)+,(a0)+
	dbra	d0,.Loop
.Skip	bsr	Ed_EALiCu
	addq.w	#1,Edt_LEdited(a4)
	rts
;
; UNDO: Ligne inseree dans le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Un_ILine
	bsr	Un_XY
	bsr	Ed_DelLiCu
	rts
;
; REDO: Ligne inseree dans le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Re_ILine
	bsr	Un_XY
	bsr	Ed_InsLine
	rts
;
; Pointe la ligne stockee
; ~~~~~~~~~~~~~~~~~~~~~~~
Un_XYSto
	bsr	Un_X
	move.l	2(a2),a2
	move.w	2(a2),d0
	bsr	Ed_GotoY
	rts
;
; Positionne le curseur sur la ligne UNDO
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Un_XY	move.w	2(a2),d0
	bsr	Ed_GotoY
Un_X	moveq	#0,d0
	move.b	1(a2),d0
	bsr	Ed_GotoX
	rts

;
; STOCKE en UNDO (A0) D0 caracteres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Un_CLine
	move.l	a2,-(sp)
	bsr	Un_Debut
	bne.s	.Skip
	movem.l	a0-a1/d0-d2,-(sp)
	move.l	a0,a1
	ext.l	d0
	move.w	d0,d1
	addq.w	#4,d0
	SyCall	MemFast
	beq.s	.No
	move.w	d0,(a0)
	add.l	d0,Prg_TUndo(a6)
	move.w	2(a2),2(a0)
	move.b	#$83,(a2)
	move.l	a0,2(a2)
	subq.l	#1,d1
	bmi.s	.No
	addq.l	#4,a0
.Loop	move.b	(a1)+,(a0)+
	dbra	d1,.Loop
.No	moveq	#0,d0
	movem.l	(sp)+,a0-a1/d0-d2
.Skip	move.l	(sp)+,a2
	rts

;
; Stocke les coordonnees du curseur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Un_Debut
	tst.b	Ed_FUndo(a5)		Autorise?
	bne.s	.OutNo
	tst.l	Prg_Undo(a6)		Buffer defini?
	beq.s	.OutNo
	move.l	d2,-(sp)
	move.l	Prg_PUndo(a6),a2
	bsr	Un_Del
	move.b	Edt_XCu+1(a4),1(a2)
	move.w	Edt_YPos(a4),d2
	add.w	Edt_YCu(a4),d2
	move.w	d2,2(a2)
	bsr	Un_Avance
	movem.l	(sp)+,d2
	move.w	#%00100,CCR		BEQ: undo en route
	rts
.OutNo	move.w	#%00000,CCR		BNE: pas d'undo!
	rts

;
; Avance UNDO d'un cran
; ~~~~~~~~~~~~~~~~~~~~~
Un_Avance
	move.l	a2,-(sp)
	move.l	Prg_PUndo(a6),a2
	bsr	Un_Next
	bsr	Un_Del
	move.l	a2,Prg_PUndo(a6)
	move.l	(sp)+,a2
	rts
;
; Efface le cran UNDO (a2)
; ~~~~~~~~~~~~~~~~~~~~~~~~
Un_Del
	movem.l	a0/a1/d0,-(sp)
	move.b	(a2),d0
	bpl.s	.Out
	move.l	2(a2),d0
	beq.s	.Out
	move.l	d0,a1
	moveq	#0,d0
	move.w	(a1),d0
	sub.l	d0,Prg_TUndo(a6)
	SyCall	MemFree
.Out	clr.b	(a2)
	movem.l	(sp)+,a0/a1/d0
	rts


; Va un cran en arriere
; ~~~~~~~~~~~~~~~~~~~~~~
Un_Prev
	subq.l	#6,a2
	cmp.b	#$FF,(a2)
	bne.s	.Skip
	move.l	Prg_Undo(a6),a2
	add.l	Prg_LUndo(a6),a2
	lea	-12(a2),a2
.Skip	rts
;
; Va un cran en avant
; ~~~~~~~~~~~~~~~~~~~
Un_Next
	addq.l	#6,a2
	cmp.b	#$FF,(a2)
	bne.s	.Skip
	move.l	Prg_Undo(a6),a2
	addq.l	#6,a2
.Skip	rts
; __________________________________________________________________________
;



; __________________________________________________________________________
;
;	GESTION DES FENETRES LIEES EN SCROLLING
; __________________________________________________________________________
;

;
; Link cursor's movements
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_LinkCursor
	bsr	Ed_TokCur
	moveq	#1,d0
	bsr	Ed_AverMess
	clr.l	Edt_LinkScroll(a4)
; Attend le choix
; ~~~~~~~~~~~~~~~
.Loop	JJsr	L_Sys_WaitMul
	SyCall	MouseKey
	btst	#0,d1
	beq.s	.Loop
	SyCall	GetZone
	cmp.w	#EcEdit,d1
	bne	Ed_NotDone
	swap	d1
	cmp.w	Edt_Window(a4),d1
	beq	Ed_NotDone
	move.w	d1,d0
	bsr	Edt_GetAd
	beq	Ed_NotDone
	bsr	Edt_DelLinkScroll
	move.l	a0,Edt_LinkScroll(a4)
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	move.w	d0,Edt_LinkYOld(a4)
	bsr	Ed_AverFin
	JJsr	L_Dia_NoMKey
	rts
;
; Enleve les links de scrolling sur la fenetre A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_DelLinkScroll
	move.l	Edt_List(a5),d1
.Loop	move.l	d1,a1
	cmp.l	Edt_LinkScroll(a1),a0
	bne.s	.Skip
	clr.l	Edt_LinkScroll(a1)
.Skip	move.l	Edt_Next(a1),d1
	bne.s	.Loop
	rts

; Gestion proprement dite
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_LinkeScroll
	tst.l	Edt_LinkScroll(a4)
	beq.s	.Nolink
	bsr	.Recurse		Fait le changement
	move.w	Edt_Window(a4),d1	Reactive la fenetre
	WiCall	QWindow
.Nolink	rts
; Routine recursive
; ~~~~~~~~~~~~~~~~~
.Recurse
	move.l	Edt_LinkScroll(a4),d0
	beq.s	.Out
	move.w	Edt_YCu(a4),d1
	add.w	Edt_YPos(a4),d1
	cmp.w	Edt_LinkYOld(a4),d1
	beq.s	.Out
; Fait les changements
	move.w	d1,d2
	sub.w	Edt_LinkYOld(a4),d1
	move.w	d2,Edt_LinkYOld(a4)
	move.b	#1,Edt_LinkFlag(a4)
	movem.l	a4/a6,-(sp)
	move.l	d0,a4
	move.l	Edt_Prg(a4),a6
	tst.b	Edt_LinkFlag(a4)
	bne.s	.PaBoucle
	move.w	Edt_YPos(a4),d0
	add.w	d1,d0
	bpl.s	.Plus
	moveq	#0,d0
.Plus	move.w	d0,d1
	add.w	Edt_YCu(a4),d1
	cmp.w	Prg_NLigne(a6),d1
	bcs.s	.2Dan
	move.w	Prg_NLigne(a6),d0
	sub.w	Edt_YCu(a4),d0
	bpl.s	.2Dan
	move.w	Prg_NLigne(a6),Edt_YCu(a4)
	moveq	#0,d0
.2Dan	move.w	d0,Edt_YPos(a4)
	tst.w	Edt_WindTy(a4)
	beq.s	.Skip
	bsr	Ed_NewBuf
.Skip	bset	#EtA_Y,Edt_EtatAff(a4)
; Appelle la fenetre suivante - RECURSIF : youpi youpla
	bsr	.Recurse
; Revient � la precedente fenetre
.PaBoucle
	movem.l	(sp)+,a4/a6
	clr.b	Edt_LinkFlag(a4)
; Revient � le precedente
.Out	rts


; __________________________________________________________________________
;
;	GESTION DES FENETRES SPLITTEES
; __________________________________________________________________________
;

;
; Split program's view
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SplitWindow
	bsr	Ed_TokCur
; Ouvre la fenetre
	move.l	a4,-(sp)
	moveq	#-1,d0			Vue
	moveq	#-1,d1			Pas de structure programme
	bsr	Edt_OpWindow		Va ouvrir
	blt	Ed_OMm
	bgt	Ed_2ManyWindow
; Insere la fenetre dans la liste LINK
	move.l	(sp),a0
	move.l	a0,Edt_LinkPrev(a4)
	move.l	Edt_LinkNext(a0),d0
	move.l	a4,Edt_LinkNext(a0)
	move.l	d0,Edt_LinkNext(a4)
	beq.s	.Skip
	move.l	d0,a1
	move.l	a4,Edt_LinkPrev(a1)
.Skip
; Copie la zone de donnees
	move.l	a6,Edt_Prg(a4)		Met le programme
	addq.b	#1,Prg_Edited(a6)	Une fenetre de plus sur le prog.
	lea	Edt_SSplit(a0),a0	Copie positions curseur / texte
	lea	Edt_SSplit(a4),a1
	move.w	#(Edt_ESplit-Edt_SSplit)/2-1,d0
.Loop	move.w	(a0)+,(a1)+
	dbra	d0,.Loop
; Affiche
	bsr	Ed_DrawWindows
.Out	addq.l	#4,sp
.Out2	rts

;
; 	Gestion proprement dite
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 	D0=	Flags
;	A0= 	Fenetre origine
Ed_Splitted
	move.l	Edt_LinkPrev(a0),d1
	or.l	Edt_LinkNext(a0),d1
	beq	.SplitX
	movem.l	a2-a6/d2-d7,-(sp)
	move.w	d0,-(sp)
	move.l	a0,a3
; Trouve la premiere
	move.l	a3,a4
	bra.s	.Deuse
.Preums	move.l	d0,a4
.Deuse	move.l	Edt_LinkPrev(a4),d0
	bne.s	.Preums
; Actualise les fenetres une a une
.Autre	cmp.l	a3,a4
	beq	.Next
	tst.w	Edt_WindTy(a4)
	beq	.Next
	move.l	Edt_Prg(a4),a6
; Changer les flags comme l'autre fenetre
	move.b	Edt_EtatAff(a3),Edt_EtatAff(a4)
; Redessiner tout le buffer, en verifiant la position
	move.w	(sp),d0
	btst	#1,d0
	beq.s	.PaAll
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	cmp.w	Prg_NLigne(a6),d0
	bcs.s	.2dan
	move.w	Prg_NLigne(a6),d0
	sub.w	Edt_YCu(a4),d0
	bpl.s	.Sz
	move.w	Prg_NLigne(a6),Edt_YCu(a4)
	moveq	#0,d0
.Sz	move.w	d0,Edt_YPos(a4)
.2dan	bsr	Ed_NewBuf
.PaAll
; Update simple de la ligne courante
	move.w	(sp),d0
	btst	#0,d0
	beq.s	.PaLicu
	move.w	Edt_YPos(a3),d1
	add.w	Edt_YCu(a3),d1
	sub.w	Edt_YPos(a4),d1
	bmi.s	.Next
	cmp.w	Edt_WindTy(a4),d1
	bcc.s	.Next
	move.w	d1,-(sp)
	move.w	Edt_YCu(a3),d0
	lsl.w	#8,d0
	lsl.w	#8,d1
	move.l	Edt_BufE(a3),a0
	move.l	Edt_BufE(a4),a1
	add.w	d0,a0
	add.w	d1,a1
	moveq	#256/4-1,d0
.Copy	move.l	(a0)+,(a1)+
	dbra	d0,.Copy
	move.w	Edt_Window(a4),d1
	WiCall	QWindow
	move.w	(sp)+,d1
	bsr	Ed_EALigne
.PaLicu
; Encore une fenetre?
.Next	move.l	Edt_LinkNext(a4),d0
	move.l	d0,a4
	bne	.Autre
; Reactive la fenetre originelle
	move.w	Edt_Window(a3),d1
	WiCall	QWindow
	addq.l	#2,sp
	movem.l	(sp)+,a2-a6/d2-d7
; Fini
.SplitX	rts



; ___________________________________________________________________
;
; 	APPEL D'UNE FONCTION DE L'EDITEUR
;
;	D2	Numero de la fonction
; ___________________________________________________________________
;
Ed_FCall
; Nettoyage
; ~~~~~~~~~
	bsr	Ed_ClEProc
	bsr	EdM_Program
	bsr	Ed_CuOff
; Stocke les flags pour le splitter
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	FlagFonc(pc),a0
	move.b	0(a0,d2.w),d0
	tst.w	EdMa_Tape(a5)
	beq.s	.PaM
	btst	#5,d0
	beq.s	.NoMacro
.PaM	move.b	d0,Ed_SCallFlags(a5)
	btst	#2,d0
	beq.s	.Notst
	bsr	Ed_LCourant
	bne	Ed_NotEdit
.Notst	move.w	Edt_YCu(a4),d0
	add.w	Edt_YPos(a4),d0
	move.w	d0,Edt_YOldBloc(a4)
; Fonction ou programme?
; ~~~~~~~~~~~~~~~~~~~~~~
	move.w	d2,d1
	ext.l	d1
	cmp.w	#HiddenCommands-1,d2
	bcs.s	.Fonc
; Hidden programs
	sub.w	#HiddenCommands-1,d1
	divu	#3,d1
	swap	d1
	moveq	#HiddenCall-1,d2		RUN / EDIT ou NEW?
	add.w	d1,d2
	clr.w	d1
	swap	d1
	add.w	EdM_PosHidden(a5),d1		Plus position courante!
	bra.s	.Call
; Autoload?
.Fonc	move.w	d2,d0
	mulu	#3,d0
	lea	Ed_AutoLoad(a5),a0
	tst.b	0(a0,d0.w)
	bne.s	.Prg
; Appelle la fonction!
.Call	lsl.w	#2,d2
	clr.w	T_Actualise(a5)
	lea	JFonc(pc),a0
	moveq	#0,d0
	jmp	0(a0,d2.w)
; Appel d'un programme externe, si pas zappeuse!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Prg	tst.b	Ed_Zappeuse(a5)
	bne.s	.Call
	lea	0(a0,d0.w),a0
	tst.w	EdMa_Tape(a5)	Pas si macro record
	beq	Ed_PrgCommand
; On ne peut utiliser cette commande dans une macro!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.NoMacro
	subq.w	#3,EdMa_Tape(a5)	Recule le pointeur
	moveq	#EdD_Macro3,d0
	bsr	Ed_Dialogue
	bra	Ed_Loop

; Branchement � HELP par F5
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_GoHelp
	moveq	#26,d2
	bra	Ed_FCall

; ___________________________________________________________________
;
;	ENTREE DE LA TELECOMMANDE
;
;	D0	Fonction
;	D1	Parametre
;	Name1	Chaine de commande
; ___________________________________________________________________
;
Ed_ZapIn
; Pas le meme programme!
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_Runned(a5),a2
	cmp.l	Edt_Current(a5),a2
	beq	.NoAcc
	tst.b	Prg_Accessory(a5)
	beq	.NoAcc
; Sauve les donnees du programme appelant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	d0,d2
	move.l	d1,Ed_ZapParam(a5)
	move.l	Edt_Prg(a2),a0
	lea	Prg_ZapData(a0),a0
	JJsrR	L_Prg_DataSave,a1
	JJsrR	L_Prg_DataNew,a1
; Prepare le terrain
; ~~~~~~~~~~~~~~~~~~
	clr.w	Ed_ZapError(a5)
	subq.w	#1,d2
	cmp.w	#HiddenCommands,d2
	bcc.s	.PaCom
	lea	FlagFonc(pc),a0
	move.b	0(a0,d2.w),d1		Commande Zappable?
	bpl.s	.PaCom
	btst	#6,d1			Une ligne de commande?
	beq.s	.Branch
	move.l	Name2(a5),a0		Oui, est-elle fournie?
	tst.w	(a0)			Longueur en NAME2,
	beq.s	.BadCh			String en NAME1...
; Branche � la fonction!
; ~~~~~~~~~~~~~~~~~~~~~~
.Branch	and.b	#$F0,d1			Mode zappeuse!
	move.b	d1,Ed_Zappeuse(a5)
	EcCalD	Active,EcEdit		Active l'ecran editeur
	move.l	BasSp(a5),sp
	move.l	Edt_Current(a5),a4	Programme courant branche!
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_SetBanks
	clr.b	Ed_YaUTest(a4)		Flags utiles
	move.b	Prg_MathFlags(a6),MathFlags(a5)
	clr.w	Ed_ZapCounter(a5)
	bsr	Ed_FCall		Appel de la fonction
	bra	Ed_Loop
; Erreur, commande non Zappable
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PaCom	move.w	#-4,Ed_ZapError(a5)
	moveq	#13,d0
	bra.s	.Err
; Erreur, pas de chaine de commande
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BadCh	move.w	#-5,Ed_ZapError(a5)
	moveq	#14,d0
.Err	bsr	Ed_GetMessage
	move.l	a0,Ed_ZapMessage(a5)
	bra.s	Ed_ZapOut
; Erreur immediate, pas un accessoire / Deja runne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.NoAcc	move.w	#-6,Ed_ZapError(a5)
	moveq	#15,d0
	bsr	Ed_GetMessage
	move.l	a0,Ed_ZapMessage(a5)
	bra.s	Ed_ZapX
; _________________________________________________
;
;	SORTIE DE LA TELECOMMANDE
; _________________________________________________
;
Ed_ZapOut
; Rebranche le programme
; ~~~~~~~~~~~~~~~~~~~~~~
	bsr	EdM_Program
	tst.b	Ed_YaUTest(a5)		Nettoyer les variables
	beq.s	.NoNew
	illegal				Ne doit JAMAIS se produire!
;	bsr	Edt_ClearVar
.NoNew	move.l	Edt_Runned(a5),a4	Remet les variables du programme
	move.l	Edt_Prg(a4),a6
	lea	Prg_ZapData(a6),a0
	JJsrR	L_Prg_DataLoad,a1
; Reactive l'�cran courant, si ouvert
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EcCalD	Last,EcEdit		En dernier!
	bsr	EdReCop
	move.w	ScOn(a5),d1
	beq.s	Ed_ZapX
	subq.w	#1,d1
	EcCall	Active
Ed_ZapX	move.w	Ed_ZapError(a5),d0
	ext.l	d0
	move.l	Ed_ZapMessage(a5),a0
	clr.w	Ed_ZapError(a5)
; Retour au programme appelant!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	BasSp(a5),sp
	rts

; ZAP: remplacement d'une chaine dans la config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdZ_NewConfig
	lea	Sys_Messages(a5),a2	Trouve la bonne config
	move.l	Ed_ZapParam(a5),d0
	beq.s	.Skp
	cmp.l	#5,d0			Met le flag seulement
	bhi.s	.Skip
	lea	Ed_Systeme-4(a5),a2
	lsl.w	#2,d0
	add.l	d0,a2
.Skp	move.l	(a2),a0			Trouve le nombre de messages
	bsr	Ed_GetNbMessage
	move.l	d0,d1
	move.l	Name1(a5),a1		Pas trop loin?
	move.l	(a1)+,d0		Numero
	cmp.l	d1,d0
	bhi.s	.Skip
	move.l	a2,a0
	bsr	EdC_ChangeTexte		Va changer!
	bne	Ed_OMm
.Skip	move.b	#1,EdC_Modified(a5)	On a change le menu
	move.b	#1,EdC_Changed(a5)	On a change la config!
	rts
; ZAP: remplacement d'une ligne dans le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdZ_NewLineTok
	bsr.s	EdZ_NewLine
	bsr	Ed_TokCur
	rts
EdZ_NewLine
; Remplace la ligne par la nouvelle
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_LCourant
	move.l	a0,a1
	move.l	Name1(a5),a2
.Loop	move.b	(a2)+,(a1)+
	bne.s	.Loop
	subq.l	#1,a1
	sub.l	a0,a1
	move.w	a1,-2(a0)
; Reaffiche la ligne courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_EALiCu
	rts
; _________________________________________________
;
;	FONCTIONS TELECOMMANDE
; _________________________________________________
;
Ed_ZapFonction
	tst.b	Prg_Accessory(a5)
	beq.s	.PaAcc
	subq.l	#1,d0
	cmp.l	#EdZ_NFonc,d0
	bcc	.IlFonc
	move.l	Edt_Current(a5),a2
	lsl.w	#2,d0
	lea	EdZ_Jump(pc),a0
	moveq	#0,d2
	jsr	0(a0,d0.w)
	rts
; Pas un accessoire
; ~~~~~~~~~~~~~~~~~
.PaAcc	moveq	#15,d0
	moveq	#-6,d1
	bra.s	.Err
; Illegal function call
; ~~~~~~~~~~~~~~~~~~~~~
.IlFonc	moveq	#16,d0
	moveq	#-7,d1
; Retour avec le message
; ~~~~~~~~~~~~~~~~~~~~~~
.Err	bsr	Ed_GetMessage
	move.l	d1,d0
	moveq	#2,d2
	rts

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdZ_Jump
	bra	EdZ_GetLine		1 La ligne courante
	bra	EdZ_GetName		2 Nom du programme courant
	bra	EdZ_GetX		3 Position en X
	bra	EdZ_GetY		4 Position en Y
	bra	EdZ_GetNLigne		5 Nombre de lignes
	bra	EdZ_X1Bloc		6 Debut X du bloc ombre
	bra	EdZ_Y1Bloc		7 Debut Y du bloc ombre
	bra	EdZ_X2Bloc		8 Fin X du bloc ombre
	bra	EdZ_Y2Bloc		9 Fin Y du bloc ombre
	bra	EdZ_GetFree		10 Espace libre
	bra	EdZ_GetStruc		11 Adresse de la structure
	bra	EdZ_Token		12 Tokenise la ligne
	bra	EdZ_GetConfig		13 Adresse de la config
EdZ_NFonc	equ	11
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdZ_GetConfig
	lea	Ed_Config(a5),a0
	move.l	a0,d0
	bra.s	EdZ_Coo
EdZ_X1Bloc
	bsr	EdZ_Bloc
	move.w	d4,d0
	bra.s	EdZ_Coo
EdZ_Y1Bloc
	bsr	EdZ_Bloc
	bra.s	EdZ_Coo
EdZ_X2Bloc
	bsr	EdZ_Bloc
	move.w	d5,d0
	bra.s	EdZ_Coo
EdZ_Y2Bloc
	bsr	EdZ_Bloc
	move.w	d1,d0
	bra.s	EdZ_Coo
EdZ_GetX
	move.w	Edt_XCu(a2),d0
	bra.s	EdZ_Coo
EdZ_GetY
	move.w	Edt_YPos(a2),d0
	add.w	Edt_YCu(a2),d0
EdZ_Coo	addq.w	#1,d0
	ext.l	d0
	rts
EdZ_GetNLigne
	move.l	Edt_Prg(a2),a0
	move.w	Prg_NLigne(a0),d0
	ext.l	d0
	rts
EdZ_GetFree
	move.l	Edt_Prg(a2),a0
	move.l	Prg_StBas(a0),d0
	sub.l	Prg_StMini(a0),d0
	rts
EdZ_GetStruc
	move.l	a2,d0
	rts
EdZ_GetName
	move.l	Edt_Prg(a2),a0
	lea	Prg_NamePrg(a0),a0
	moveq	#0,d0
	moveq	#2,d2
	rts
EdZ_GetLine
	movem.l	a4/a6,-(sp)
	move.l	a2,a4
	move.l	Edt_Prg(a4),a6
	move.l	Ed_BufT(a5),a1
	clr.w	(a1)
	move.l	d1,d0
	ble.s	.LiCu
; Ligne quelconque
	subq.w	#1,d0
	cmp.w	Prg_NLigne(a6),d1
	bhi.s	.Out
	bra.s	.Li
; Ligne sous le curseur
.LiCu	move.w	Edt_YCu(a4),d0
	add.w	Edt_YPos(a4),d0
.Li	bsr	Ed_FindL
	beq.s	.Out
	moveq	#0,d0
	bsr	Detok
.Out	move.l	Ed_BufT(a5),a0
	move.w	(a0)+,d0
	clr.b	0(a0,d0.w)
	moveq	#0,d0
	moveq	#2,d2
	movem.l	(sp)+,a4/a6
	rts
EdZ_Bloc
	move.w	Edt_YBloc(a2),d0
	bmi.s	.No
	move.w	Edt_YCu(a2),d1
	add.w	Edt_YPos(a2),d1
	move.w	Edt_XBloc(a2),d4
	move.w	Edt_XCu(a2),d5
	cmp.w	d0,d1
	bhi.s	.Ok
	bne.s	.Sw
	cmp.w	d4,d5
	bcc.s	.Ok
.Sw	exg	d0,d1
	exg	d4,d5
.Ok	rts
.No	addq.l	#4,sp
	moveq	#-1,d0
	rts
; Tokenise la ligne du buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdZ_Token
	move.l	a2,-(sp)
	move.l	Buffer(a5),a0
	move.l	Ed_BufT(a5),a1
	bsr	Tokenise
	move.l	Ed_BufT(a5),d0
	moveq	#0,d2
	move.l	(sp)+,a2
	rts


; ______________________________________________________________________
;
;						LISTES / MEMOIRE
; ______________________________________________________________________

; Reserve un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
;	D0=	Longueur
Ed_MemReserve
	movem.l	d1/a1,-(sp)
	move.l	a0,a1
	move.l	d0,d1
	addq.l	#4,d0
	SyCall	MemFastClear
	beq.s	.Out
	move.l	d1,(a0)+
	move.l	a0,(a1)
.Out	movem.l	(sp)+,d1/a1
	rts
; Efface un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
Ed_MemFree
	movem.l	a0/a1,-(sp)
	move.l	(a0),d0
	beq.s	.Skip
	clr.l	(a0)
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	SyCall	SyFree
.Skip	movem.l	(sp)+,a0/a1
	rts

;
; Cree un �l�ment en tete de liste A0 / longueur D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ListeNew
	movem.l	a0/d0/d1,-(sp)
	addq.l	#8,d0
	exg	a0,a1
	SyCall	MemFastClear
	exg	a0,a1
	beq.s	.Err
	move.l	(a0),(a1)
	move.l	a1,(a0)
	subq.l	#8,d0
	move.l	d0,4(a1)
.Err	movem.l	(sp)+,a0/d0/d1
	rts

; Efface une liste entiere A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ListeDelAll
	bra.s	.In
.Loop	move.l	d0,a1
	bsr	Ed_ListeDel
.In	move.l	(a0),d0
	bne.s	.Loop
	rts
; Efface un �l�ment de liste A1 / Debut liste A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ListeDel
	movem.l	a0/d0-d2,-(sp)
	move.l	a1,d0
	move.l	a0,a1
	move.l	(a1),d2
	beq.s	.NFound
.Loop	move.l	a1,d1
	move.l	d2,a1
	cmp.l	d0,a1
	beq.s	.Found
	move.l	(a1),d2
	bne.s	.Loop
	bra.s	.NFound
; Enleve de la liste
.Found	move.l	d1,a0
	move.l	(a1),(a0)
	move.l	4(a1),d0
	addq.l	#8,d0
	SyCall	MemFree
.NFound	movem.l	(sp)+,a0/d0-d2
	rts

; Clearvar du programme courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_ClearVar
	bsr	EdM_Program
	JJsr	L_Prg_SetBanks
	JJsr	L_ClearVar
	rts
;
; Actualisation des ecrans
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdReCop	SyCall	WaitVbl
	EcCall	CopForce
	rts

; ______________________________________________________________________
;
;						BOITES DE DIALOGUE
; ______________________________________________________________________

; Initialisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_InitDialogues
	bsr	Ed_SetBanks
	moveq	#1,d0			Canal #1
	move.l	#1024,d1		1024 octets
	moveq	#16,d2			16 variables
	moveq	#0,d3			Ne pas recopier la chaine
	move.l	Ed_Resource(a5),a0
	move.l	a0,a1
	add.l	2+8(a0),a0		Base des programmes
	add.l	2+0(a0),a0		Programme numero 1
	add.l	2(a1),a1		Base des graphiques
	move.l	Ed_Messages(a5),a2	Base des messages
	JJsrP	L_Dia_OpenChannel,a3
	bne.s	.Err
	move.l	a0,Ed_ADialogues(a5)
	move.l	a1,Ed_VDialogues(a5)
	move.l	#Ed_DiaImages,Dia_PuzzleI(a0)
	bsr	Ed_IChaine
	moveq	#0,d0
.Err	rts

; Fin des dialogues
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EndDialogues
	bsr	Ed_SetBanks
	moveq	#1,d0
	JJsr	L_Dia_CloseChannel
	rts

; Copie une chaine dans le buffer de dialogue
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_IChaine
	move.l	Ed_BufT(a5),Ed_DiaCopyC(a5)
	rts
Ed_DChaine
	move.l	Ed_DiaCopyC(a5),Ed_DiaCopyD(a5)
	addq.l	#2,Ed_DiaCopyC(a5)
Ed_AChaine
	move.l	Ed_DiaCopyC(a5),a1
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
	subq.l	#1,a1
	move.l	a1,Ed_DiaCopyC(a5)
	move.l	a1,d0
	move.l	Ed_DiaCopyD(a5),a1
	sub.l	a1,d0
	subq.b	#2,d0
	clr.b	(a1)
	move.b	d0,1(a1)
	rts

; Appel general des dialogues, avec protection memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Dialogue:
	tst.b	Ed_Zappeuse(a5)
	beq.s	.NoZap
	move.l	Ed_ZapParam(a5),d0		Zappeuse: retourne parametre
	rts
; Au moins 48k de CHIP pour un effacement...
.NoZap	clr.l	Dia_Magic(a5)
	movem.l	d0/a6,-(sp)
	move.l	$4.w,a6
	move.l	#Public|Chip,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,d1
	movem.l	(sp)+,d0/a6
	cmp.l	#48*1024,d1
	bcc.s	Ed_DoDialog
; Sans effacement!
	move.l	#"NobL",Dia_Magic(a5)
	bsr	Ed_DoDialog
	movem.l	d0-d1/a0-a1,-(sp)
	bsr	Ed_DrawWindows
	movem.l	(sp)+,d0-d1/a0-a1
	rts
; Appel des dialogues
; ~~~~~~~~~~~~~~~~~~~
Ed_DoDialog
	bsr	Ed_SetBanks
	movem.l	d2-d3,-(sp)
	move.l	d0,d1
	moveq	#1,d0
	move.l	#EntNul,d2
	move.l	d2,d3
	JJsr	L_Dia_RunProgram
	movem.l	(sp)+,d2-d3
	clr.l	Dia_Magic(a5)
	move.l	d1,d0
	bsr	Ed_IChaine
	rts


; _________________________________________________________________________
;
; Jumps aux touches de fonction
; _________________________________________________________________________
;
JFonc:	bra	Ed_CHaut		* 1  Cur Haut
	bra	Ed_CBas			* 2  Cur Bas
	bra	Ed_CGauche		* 3  Cur Gauche
	bra	Ed_CDroite		* 4  Cur Droite
	bra	Ed_HPage		* 5  Haut Page
	bra	Ed_BPage		* 6  Bas Page
	bra	Ed_MGauche		* 7  Mot gauche
	bra	Ed_MDroite		* 8  Mot Droite
	bra	Ed_PHaut		* 9  Page Haut
	bra	Ed_PBas			* 10 Page Bas
	bra	Ed_DLigne		* 11 Debut Ligne
	bra	Ed_FLigne		* 12 Fin Ligne
	bra	Ed_EtatUp		* 13 Bar Haut Haut
	bra	Ed_EtatDown		* 14 Bar haut Bas
	bra	Ed_BasUp		* 15 Bar Bas Haut
	bra	Ed_BasDown		* 16 Bar Bas Bas
	bra	Ed_HTexte		* 17 Haut Texte
	bra	Ed_BTexte		* 18 Bas Texte
	bra	Ed_Return		* 19 Return
	bra	Ed_Back			* 20 Backspace
	bra	Ed_Delete		* 21 Delete
	bra	Ed_EffLigne		* 22 Effacement Ligne
	bra	Ed_DelLiCu		* 23 Delete Ligne
	bra	Ed_Tab			* 24 Plus Tab
	bra	Ed_ShTab		* 25 Moins Tab
	bra	Ed_STab			* 26 Set Tab
	bra	Ed_UserMenu		* 27 Help
	bra	Ed_Escape		* 28 Escape
	bra	Ed_InsLine		* 29 Insert Ligne
	bra	Ed_DelFin		* 30 Delete Fin Ligne
	bra	Ed_PLabel		* 31 Previous Label
	bra	Ed_NLabel		* 32 Next Label
	bra	Ed_Load			* 33 Load
	bra	Ed_SaveAs		* 34 SaveAs
	bra	Ed_Save			* 35 Save
	bra	Ed_DelMot		* 36 Del Mot
	bra	Ed_BackMot		* 37 Back Mot
	bra	Ed_WindowHide		* 38 Hide Project
	bra	Ed_SMark0		* 39 Set Marks
	bra	Ed_SMark1
	bra	Ed_SMark2
	bra	Ed_SMark3
	bra	Ed_SMark4
	bra	Ed_SMark5
	bra	Ed_SMark6
	bra	Ed_SMark7
	bra	Ed_SMark8
	bra	Ed_SMark9
	bra	Ed_GMark0		* 49 Goto Mark
	bra	Ed_GMark1
	bra	Ed_GMark2
	bra	Ed_GMark3
	bra	Ed_GMark4
	bra	Ed_GMark5
	bra	Ed_GMark6
	bra	Ed_GMark7
	bra	Ed_GMark8
	bra	Ed_GMark9
	bra	Ed_BlocOn		* 59 Marche / Arret Bloc
	bra	Ed_BlocForget		* 60 Forget Bloc
	bra	Ed_OpenLoad		* 61 Open + Load
	bra	Ed_BlocCut		* 62 Cut Bloc
	bra	Ed_BlocPaste		* 63 Paste Bloc
	bra	Ed_DelDebut		* 64 Delete to S.O.L
	bra	Ed_Undo			* 65 Undo
	bra	Ed_Search		* 66 Search
	bra	Ed_SearchNext		* 67 Search Next
	bra	Ed_SearchPrev		* 68 Search Previous
	bra	EdZ_NewLine		* 69 ZAPPEUSE: replace line
	bra	Ed_RAlert		* 70 Recall last alert
	bra	EdZ_NewLineTok		* 71 ZAPPEUSE: replace+tokenise
	bra	Ed_BlocStore		* 72 Store bloc

	bra	Ed_Key2Menu		* 73 Set Key Shortcut
	bra	Ed_Prg2Menu		* 74 Affect Program to menu
	bra	Ed_Ins			* 75 Flip Insert Mode
	bra	Ed_GotoL		* 76 Goto Line Number
	bra	Ed_Run			* 77 Run
	bra	Ed_Test			* 78 Test
	bra	Ed_Indent		* 79 Indent
	bra	Ed_New			* 80 Clear
	bra	Ed_CloseWindowQuit	* 81 Close
	bra	Ed_Quit			* 82 Quit
	bra	Ed_Infos		* 83 Editor Informations
	bra	Ed_Merge		* 84 Merge
	bra	Ed_LoadA		* 85 Merge Ascii
	bra	Ed_BlocPrint		* 86 Print Bloc
	bra	Ed_ProcOpen		* 87 Open / Close
	bra	Ed_LoadHidden		* 88 Load Hidden program
	bra	Ed_ProcsOpen		* 89 Open All
	bra	Ed_ProcsClose		* 90 Close All
	bra	Ed_PrevWindow		* 91 Previous Window
	bra	Ed_NextWindow		* 92 Next Window
	bra	Ed_FlipSizeWindow	* 93 Enlarge Window
	bra	Ed_Redo			* 94 Redo
	bra	Ed_SplitWindow		* 95 Split View
	bra	Ed_LinkCursor		* 96 Link Cursor
	bra	Ed_BlocSaveAscii	* 97 Save Block as Ascii
	bra	Ed_BlocSave		* 98 Save Block
	bra	Ed_Replace		* 99 Replace New
	bra	Ed_ReplaceNext		* 100 Replace Next
	bra	Ed_ReplacePrev		* 101 Replace Previous
	bra	Ed_NewAllHidden		* 102 New All Hidden Programs
	bra	Ed_OpenWindow		* 103 Open New
	bra	Ed_ShowKey		* 104 Show Key shortcuts
	bra	Ed_Wb			* 105 Workbench
	bra	EdMa_New		* 106 Set new Macro
	bra	EdMa_Del		* 107 Clear One Macro
	bra	EdMa_DelAll		* 108 Clear All Macros
	bra	EdMa_LoadAs		* 109 Load Macros
	bra	EdMa_SaveAs		* 110 Save Macros
HiddenCommands	equ	184
HiddenCall	equ	111
	bra	Ed_RunHidden		* 111 Run
	bra	Ed_EditHidden		* 112 Edit
	bra	Ed_NewHidden		* 113 New
	bra	Ed_SetBuffer		* 114 Set Buffer
EdM_UserCommands	equ	115
EdM_UserLong		equ	16
EdM_UserMax		equ	20
	bra	Ed_UserMenu		* 0
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 5
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 10
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 15
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu

	bra	Ed_AddUser		* 135 Add user option
	bra	Ed_DelUser		* 136 Del user option
	bra	EdC_SaveDefault		* 137 Save default config
	bra	EdC_SaveAs		* 138 Save As
	bra	EdC_LoadDefault		* 139 Load default config
	bra	EdC_LoadAs		* 140 Load As
	bra	Ed_QuitOptions		* 141 Quit Options
	bra	Ed_SetAutoSave		* 142 Autosave
	bra	EdMa_LoadDefault	* 143 Load Default Macros
	bra	EdMa_SaveDefault	* 144 Save Default Macros
	bra	Ed_GoMonitor		* 145 Monitor
	bra	Ed_PrgPrint		* 146 Program Print
	bra	Ed_Check1.3		* 147 Check 1.3
	bra	Ed_SamOn		* 148 Sound On / Off
 	bra	Ed_AboutExt		* 149 About extensions
	bra	Ed_About		* 150 About AMOS
	bra	Ed_ProcML		* 151 Insert machine langage

; HELP: Insersion des commandes ZAP additionnelles
	bra	Ed_SaveAsName		* 152 Sauve sans changer nom
	bra	Ed_CloseName		* 153 Ferme une fenetre nom
	bra	Ed_Rename		* 154 Rename le programme courant
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 157
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 162
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 167
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu
	bra	Ed_UserMenu		* 172 Interpretor Setup
	bra	Ed_UserMenu		* 173 Editor Setup
	bra	Ed_UserMenu		* 174 Editor Menus
	bra	Ed_UserMenu		* 175 Editor Dialogs
	bra	Ed_UserMenu		* 176 Test-Time
	bra	Ed_UserMenu		* 177 Run-Time
	bra	Ed_UserMenu		* 178 Colour Palette
	bra	EdM_PrevHidden		* 179 Previous programs
	bra	EdM_NextHidden		* 180 Next programs
	bra	Ed_BlocAll		* 181 All text as block
	bra	EdZ_NewConfig		* 182 ZAP: remplace chaine dans config
	bra	Ed_GoHelp		* 183 Branche au HELP
	bra	Ed_UserMenu		* 184

; Flags pour chaque fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
FlagFonc
; Bit 0: redessiner le buffer
; Bit 1: redessiner la ligne
; Bit 2: Interdit si procedure fermee
; Bit 5: autorise en macro!
; Bit 6: transmettre une ligne de commande
; Bit 7: commande t�l�commandable
	dc.b	%10100000		* 1  Cur Haut
	dc.b	%10100000 		* 2  Cur Bas
	dc.b	%10100000		* 3  Cur Gauche
	dc.b	%10100000		* 4  Cur Droite
	dc.b	%10100000		* 5  Haut Page
	dc.b	%10100000		* 6  Bas Page
	dc.b	%10100000		* 7  Mot gauche
	dc.b	%10100000		* 8  Mot Droite
	dc.b	%10100000		* 9  Page Haut
	dc.b	%10100000		* 10 Page Bas
	dc.b	%10100000		* 11 Debut Ligne
	dc.b	%10100000		* 12 Fin Ligne
	dc.b	%10100000		* 13 Bar Haut Haut
	dc.b	%10100000		* 14 Bar haut Bas
	dc.b	%10100000		* 15 Bar Bas Haut
	dc.b	%10100000		* 16 Bar Bas Bas
	dc.b	%10100000  		* 17 Haut Texte
	dc.b	%10100000		* 18 Bas Texte
	dc.b	%10100011 		* 19 Return
	dc.b	%10100101		* 20 Backspace
	dc.b	%10100101		* 21 Delete
	dc.b	%10100110		* 22 Effacement Ligne
	dc.b	%10100110		* 23 Delete Ligne
	dc.b	%10100101		* 24 Plus Tab
	dc.b	%10100101		* 25 Moins Tab
	dc.b	%00000000		* 26 Set Tab
	dc.b	%00000000		* 27 Help
	dc.b	%00000000		* 28 Escape
	dc.b	%10100010		* 29 Insert Ligne
	dc.b	%10100101		* 30 Delete Fin Ligne
	dc.b	%10100000		* 31 Previous Label
	dc.b	%10100000		* 32 Next Label
	dc.b	%10000010		* 33 Load
	dc.b	%10000010		* 34 SaveAs
	dc.b	%10000000		* 35 Save
	dc.b	%10100100		* 36 Del Mot
	dc.b	%10100100		* 37 Back Mot
	dc.b	%00000000		* 38 Hide Project
	dc.b	%10100000		* 39 Set Marks
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000		* 49 Goto Mark
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000
	dc.b	%10100000	 	* 59 Marche / Arret Bloc
	dc.b	%10100010		* 60 Forget Bloc
	dc.b	%10000010		* 61 Open + Load
	dc.b	%10100010		* 62 Cut Bloc
	dc.b	%10100010		* 63 Paste Bloc
	dc.b	%10100110		* 64 Delete to S.O.L
	dc.b	%10000001		* 65 Undo
	dc.b	%10000000		* 66 Search
	dc.b	%10100000		* 67 Search Next
	dc.b	%10100001		* 68 Search Previous
	dc.b	%10000100		* 69 ZAPPEUSE: Newline
	dc.b	%00000000		* 70 Recall last alert
	dc.b	%10000110		* 71 ZAPPEUSE: Newline+Tokenise
	dc.b	%10100000		* 72 Store bloc

	dc.b	%00000010		* 73 Set Key Shortcut
	dc.b	%00000010		* 74 Affect Program to menu
	dc.b	%00100000		* 75 Flip Insert Mode
	dc.b	%10000000		* 76 Goto Line Number
	dc.b	%00000000		* 77 Run
	dc.b	%00000000		* 78 Test
	dc.b	%00000010		* 79 Indent
	dc.b	%10000010		* 80 Clear
	dc.b	%10000000		* 81 Close
	dc.b	%00000000		* 82 Quit
	dc.b	%00000000		* 83 Informations
	dc.b	%10100110		* 84 Merge
	dc.b	%10100110  		* 85 Merge Ascii
	dc.b	%10000000		* 86 Print Bloc
	dc.b	%00000010		* 87 Open / Close
	dc.b	%00000010		* 88 Load Hidden program
	dc.b	%10000010		* 89 Open All
	dc.b	%00000010		* 90 Close All
	dc.b	%10000000		* 91 Previous Window
	dc.b	%10000000		* 92 Next Window
	dc.b	%10000000		* 93 Enlarge Window
	dc.b	%10000000		* 94 Redo
	dc.b	%00000000		* 95 Split View
	dc.b	%00000000		* 96 Link Cursor
	dc.b	%10100000		* 97 Save Block as Ascii
	dc.b	%10100000		* 98 Save Block
	dc.b	%10100010		* 99 Replace
	dc.b	%10000010		* 100 Replace Next
	dc.b	%10000000		* 101 Replace Previous
	dc.b	%00000000		* 102 New All Hidden Programs
	dc.b	%10000000		* 103 Open New
	dc.b	%00000000		* 104 Show Key shortcuts
	dc.b	%00000000		* 105 Workbench
	dc.b	%00000000		* 106 Set New Macro
	dc.b	%00000000		* 107 Clear Macro
	dc.b	%00000000		* 108 Clear All Macros
	dc.b	%00000000		* 109 Load Macros
	dc.b	%00000000		* 110 Save Macros
	dc.b	%00000000		* 111 Run
	dc.b	%00000000		* 112 Edit
	dc.b	%00000000		* 113 New
	dc.b	%00000000		* 114 Set TextBuffer

	dc.b	%00000000		* 0  User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		* 5  User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		* 10 User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		* 15 User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu
	dc.b	%00000000		*    User Menu

	dc.b	%00000000		* 135 Add user option
	dc.b	%00000000		* 136 Del user option
	dc.b	%00000000		* 137 Save default config
	dc.b	%00000000		* 138 Save As
	dc.b	%00000000		* 139 Load default config
	dc.b	%00000000		* 140 Load As
	dc.b	%00000000		* 141 Quit Options
	dc.b	%00000000		* 142 Autosave
	dc.b	%00000000		* 143 Load Default Macros
	dc.b	%00000000		* 144 Save Default Macros
	dc.b	%00000000		* 145 Monitor
	dc.b	%10000000		* 146 Program Print
	dc.b	%00000000		* 147 Check 1.3
	dc.b	%00000000		* 148 Sound On / Off
	dc.b	%00000000		* 149 About extensions
	dc.b	%00000000		* 150 About AMOS
	dc.b 	%00000000		* 151 Insert machine langage
; HELP: Insersion des commandes ZAP additionnelles
	dc.b	%11000000		* 152 Save As Name
	dc.b	%11000000
	dc.b	%11000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000		* 157
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000		* 162
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000		* 167
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000		* 172 Interpretor Setup
	dc.b	%00000000		* 173 Editor Setup
	dc.b	%00000000		* 174 Editor Menus
	dc.b	%00000000		* 175 Editor Dialogs
	dc.b	%00000000		* 176 Test-Time
	dc.b	%00000000		* 177 Run-Time
	dc.b	%00000000		* 178 Colour Palette
	dc.b	%00000000		* 179 Previous programs
	dc.b	%00000000		* 180 Next programs
	dc.b	%10000000		* 181 All text as block
	dc.b	%11000000		* 182 Change config string
	dc.b	%00000000		* 183
	dc.b	%00000000		* 184
	even

;
; BACKSPACE
; ~~~~~~~~~
Ed_Back
	tst.w	Edt_XCu(a4)
	beq	Ed_Join
	bsr	Ed_CGauche
	bsr	Ed_Delete
.Skip	rts

;
; DELETE
; ~~~~~~
Ed_Delete
	moveq	#"F",d0			Va faire du bruit!
	bsr	Ed_SamPlay
	bsr	Ed_LCourant
	sub.w	Edt_XCu(a4),d0
	subq.w	#1,d0
	bmi	CFin
; Gestion de l'UNDO
	bsr	Un_Debut
	bne.s	.Skip
	move.b	#$02,(a2)
	move.b	(a1),5(a2)
.Skip
; Enleve la lettre
	moveq	#1,d0
	bsr	R_DelChar
	bra	Ed_EALiCu

;
; EFFACEMENT LIGNE
; ~~~~~~~~~~~~~~~~
Ed_EffLigne
	addq.w	#1,Edt_LEdited(a4)
	clr.w	Edt_XCu(a4)
	bsr	Ed_LCourant
	moveq	#0,d0
	move.w	-2(a0),d0
	clr.w	-2(a0)
	bsr	Un_CLine
	bsr	Ed_EALiCu
	bra	Ed_Cent

;
; DELETE JUSQUA LA FIN DE LA LIGNE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DelFin
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_LCourant
	cmp.w	d0,d1
	bcc.s	.EdFin
	move.w	-2(a0),d0
	move.w	d1,-2(a0)
	sub.w	d1,d0
	ext.l	d0
	move.l	a1,a0
	bsr	Un_CLine
	bra	Ed_EALiCu
.EdFin	rts
;
; DELETE JUSQU'AU DEBUT DE LA LIGNE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DelDebut
	bsr	Ed_LCourant
	tst.w	d1
	beq.s	.Out
	cmp.w	d0,d1
	bcc.s	.Skip
	move.w	d1,d0
.Skip	clr.w	Edt_XCu(a4)
	ext.l	d0
	bsr	Un_CLine
	bsr	R_DelChar
	bsr	Ed_EALiCu
.Out	rts
;
; SHIFT-DELETE MOT A DROITE
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DelMot
	bsr	R_MotDroi
	move.w	Edt_XCu(a4),d0
	cmp.w	d0,d1
	bls.s	.Skip
	sub.w	d0,d1
	move.w	d1,d2
	bsr	Ed_LCourant
	cmp.w	d0,d1
	bcc.s	.Skip
	move.w	d2,d0
	move.l	a1,a0
	ext.l	d0
	bsr	Un_CLine
	move.w	d2,d0
	bsr	R_DelChar
	bsr	Ed_EALiCu
.Skip	rts

;
; SHIFT-BACKSPACE MOT A GAUCHE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BackMot
	bsr	R_MotGoch
	move.w	Edt_XCu(a4),d0
	cmp.w	d0,d1
	bcc.s	.Skip
	move.w	d1,Edt_XCu(a4)
	bsr	Ed_Cent
	bra.s	Ed_DelMot
.Skip	rts

;
; TAB
; ~~~
Ed_Tab
	bsr	Ed_LCourant
	lea	0(a0,d0.w),a1		* Fin actuelle
	move.w	Ed_Tabs(a5),d2
	add.w	d2,d0
	cmp.w	#250,d0
	bcc	Ed_LToLong
	add.w	d2,-2(a0)
	lea	0(a0,d0.w),a2		* Nouvelle fin
	bra.s	.ETab2
.ETab1	move.b	-(a1),-(a2)
.ETab2	cmp.l	a0,a1
	bhi.s	.ETab1
	add.w	d2,Edt_XCu(a4)
	subq.w	#1,d2
	bmi.s	ETab4
.ETab3	move.b	#" ",(a1)+
	dbra	d2,.ETab3
ETab4	addq.w	#1,Edt_LEdited(a4)
	move.w	Edt_YCu(a4),d1
	bsr	Ed_EALigne
	bsr	Ed_Cent
ETabX	rts

;
; SHIFT TAB (enleve les tabs)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ShTab
	bsr	Ed_LCourant
	lea	0(a0,d0.w),a2
	move.l	a0,a1
	moveq	#0,d0
	move.w	Ed_Tabs(a5),d1
	subq.w	#1,d1
	bmi.s	ETabX
.ShT1	cmp.b	#" ",(a0)
	bne.s	.ShT2
	addq.l	#1,a0
	cmp.l	a2,a0
	bcc.s	.ShT2
	addq.w	#1,d0
	dbra	d1,.ShT1
.ShT2	tst.w	d0
	beq.s	ETabX
	sub.w	d0,-2(a1)
	sub.w	d0,Edt_XCu(a4)
	bpl.s	.ShT4
	clr.w	Edt_XCu(a4)
	bra.s	.ShT4
.ShT3	move.b	(a0)+,(a1)+
.ShT4	cmp.l	a2,a0
	bls.s	.ShT3
	bra.s	ETab4

;
; SET TAB VALUE
; ~~~~~~~~~~~~~
Ed_STab	bsr	Ed_TokCur
	move.l	Ed_VDialogues(a5),a2
	moveq	#0,d0
	move.w	Ed_Tabs(a5),d0
	move.l	d0,2*4(a2)
	moveq	#EdD_SetTab,d0
	bsr	Ed_Dialogue
	moveq	#1,d0
	moveq	#3,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.w	d1,Ed_Tabs(a5)
; Flag pour QUIT
	move.b	#1,EdC_Changed(a5)
	bra	Ed_Loca

;
; Curseur vers le haut
; ~~~~~~~~~~~~~~~~~~~~
Ed_CHaut
	bsr	Ed_TokCur
	moveq	#"F",d0			Va faire du bruit!
	bsr	Ed_SamPlay
Ed_ChtT
	bset	#EtA_Y,Edt_EtatAff(a4)
	tst.w	Edt_YCu(a4)
	beq.s	CHt1
	subq.w	#1,Edt_YCu(a4)
	bra	Ed_Loca
CHt1	tst.w	Edt_YPos(a4)
	beq	Ed_CHtE
	subq.w	#1,Edt_YPos(a4)
; Scrolle l'ecran graphique
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_CHt
	move.b	#SlDelai,Edt_ASlY(a4)
	cmp.w	#1,Edt_WindTy(a4)
	beq.s	.Skip
	WiCalD	ChrOut,20
; Scrolle l'ecran texte
; ~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_BufE(a4),a1
	move.w	Edt_WindTy(a4),d0
	lsl.w	#8,d0
	add.w	d0,a1
	lea	-256(a1),a0
	move.w	Edt_WindTy(a4),d0
	subq.w	#1,d0
	lsl.w	#4,d0
	subq.w	#1,d0
.CBs2	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	dbra	d0,.CBs2
; Affiche la derniere ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~
.Skip	move.w	Edt_YPos(a4),d0
	moveq	#0,d1
	bsr	Ed_Untok
	bsr	Ed_EALigne
	bra	Ed_Loca
;
; Pitit retour.
; ~~~~~~~~~~~~~
CFin:	rts

;
; Curseur vers le bas
; ~~~~~~~~~~~~~~~~~~~
Ed_CBas
	bsr	Ed_TokCur
	moveq	#"F",d0			Va faire du bruit!
	bsr	Ed_SamPlay

; Entree pour la tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_CBasT
	bset	#EtA_Y,Edt_EtatAff(a4)
	move.w	Edt_YPos(a4),d0		* Deja la derniere ligne
	add.w	Edt_YCu(a4),d0
	cmp.w	Prg_NLigne(a6),d0
	bcc	Ed_CBasE

	move.w	Edt_YCu(a4),d0
	move.w	Edt_WindTy(a4),d1
	subq.w	#1,d1
	cmp.w	d1,d0
	bcc.s	.CBs1
	addq.w	#1,Edt_YCu(a4)
	bra	Ed_Loca

.CBs1:	addq.w	#1,Edt_YPos(a4)
; Scrolle l'ecran graphique
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_CBs
	move.b	#SlDelai,Edt_ASlY(a4)
	cmp.w	#1,Edt_WindTy(a4)
	beq.s	.Skip
	WiCalD	ChrOut,22
; Scrolle l'ecran texte
; ~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_BufE(a4),a1
	lea	256(a1),a0
	move.w	Edt_WindTy(a4),d0
	subq.w	#1,d0
	lsl.w	#4,d0
	subq.w	#1,d0
.CHt2	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.CHt2
; Affiche la derniere ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~
.Skip	move.w	Edt_YPos(a4),d0
	move.w	Edt_WindTy(a4),d1
	subq.w	#1,d1
	add.w	d1,d0
	bsr	Ed_Untok
	bsr	Ed_EALigne
	bra	Ed_Loca

;
; Curseur vers la gauche
; ~~~~~~~~~~~~~~~~~~~~~~
Ed_CGauche
	moveq	#"F",d0			Va faire du bruit!
	bsr	Ed_SamPlay

	bset	#EtA_X,Edt_EtatAff(a4)
	move.w	Edt_XCu(a4),d0
	beq	CFin
	subq.w	#1,d0
	move.w	d0,Edt_XCu(a4)
	sub.w	Edt_XPos(a4),d0
	cmp.w	#15,d0
	bcc.s	CGo1
	tst.w	Edt_XPos(a4)
	beq.s	CGo1
Ed_CGo
	subq.w	#1,Edt_XPos(a4)
	WiCalD	ChrOut,19
	moveq	#0,d1
	bsr	Ed_AffBufCar
CGo1	bra	Ed_Loca

;
; Curseur vers la droite
; ~~~~~~~~~~~~~~~~~~~~~~
Ed_CDroite
	moveq	#"F",d0			Va faire du bruit!
	bsr	Ed_SamPlay

	bset	#EtA_X,Edt_EtatAff(a4)
	move.w	Edt_XCu(a4),d0
	cmp.w	#250,d0
	bcc	CFin
	addq.w	#1,d0
	move.w	d0,Edt_XCu(a4)
	sub.w	Edt_XPos(a4),d0
	cmp.w	#WiTx-10,d0
	bcs.s	CDr0
Ed_CDr
	addq.w	#1,Edt_XPos(a4)
	WiCalD	ChrOut,17
	move.w	Edt_WindTx(a4),d1
	subq.w	#1,d1
	bsr	Ed_AffBufCar
CDr0	bra	Ed_Loca

;
; Haut page
; ~~~~~~~~~
Ed_HPage
	bsr	Ed_TokCur
	clr.w	Edt_YCu(a4)
Ed_LXY
	or.b	#EtA_BXY,Edt_EtatAff(a4)
	bra	Ed_Loca

;
; Bas page
; ~~~~~~~~
Ed_BPage
	bsr	Ed_TokCur
	move.w	Edt_WindTy(a4),d0
	subq.w	#1,d0
	move.w	Edt_YPos(a4),d1
	add.w	d0,d1
	cmp.w	Prg_NLigne(a6),d1
	bcs.s	.BPag
	sub.w	Prg_NLigne(a6),d1
	sub.w	d1,d0
.BPag	move.w	d0,Edt_YCu(a4)
	bra	Ed_LXY

;
; Mot gauche
; ~~~~~~~~~~
Ed_MGauche
	bsr	R_MotGoch
	move.w	d1,Edt_XCu(a4)
	bra	Ed_Cent
;
; Mot droit
; ~~~~~~~~~
Ed_MDroite
	bsr	R_MotDroi
	move.w	d1,Edt_XCu(a4)
	bra	Ed_Cent
;
; Pointe le mot PRECEDENT
; ~~~~~~~~~~~~~~~~~~~~~~~
R_MotGoch
	bsr	Ed_LCourant
	cmp.w	d0,d1
	bls.s	.MGo0
	move.w	d0,d1
	bra.s	.MGo4
.MGo0	subq.w	#1,d1
	bmi.s	.MGo3
	cmp.b	#32,-(a1)
	bne.s	.MGo2
.MGo1	subq.w	#1,d1
	bmi.s	.MGo3
	cmp.b	#32,-(a1)
	beq.s	.MGo1
.MGo2	subq.w	#1,d1
	bmi.s	.MGo3
	move.b	-(a1),d2
	bsr	Une_Lettre
	bne.s	.MGo2
.MGo3	addq.w	#1,d1
.MGo4	rts

; Pointe le mot DROIT
; ~~~~~~~~~~~~~~~~~~~
R_MotDroi
	bsr	Ed_LCourant
.MDr1	addq.w	#1,d1
	cmp.w	d0,d1
	bcc.s	.MDr2
	move.b	(a1)+,d2
	bsr	Une_Lettre
	bne.s	.MDr1
	cmp.b	#32,(a1)
	beq.s	.MDr1
.MDr2	rts


;
; Debut ligne
; ~~~~~~~~~~~
Ed_DLigne
Ed_DLigneT
	clr.w	Edt_XCu(a4)
	bra	Ed_Cent

;
; Fin ligne
; ~~~~~~~~~
Ed_FLigne
	bsr	Ed_LCourant
	move.w	d0,Edt_XCu(a4)
	bra	Ed_Cent

;
; Page up
; ~~~~~~~
Ed_PHaut
	bsr	Ed_TokCur
	bset	#EtA_Y,Edt_EtatAff(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	tst.w	Edt_YPos(a4)
	beq	Ed_HTex
	move.w	Edt_WindTy(a4),d0
	subq.w	#2,d0
	bpl.s	.Skip
	moveq	#1,d0
.Skip	sub.w	d0,Edt_YPos(a4)
	bcc	Ed_NewBuf
	clr.w	Edt_YPos(a4)
	bra	Ed_NewBuf
;
; Page down
; ~~~~~~~~~
Ed_PBas
	bsr	Ed_TokCur
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	move.w	Edt_WindTy(a4),d1
	subq.w	#2,d1
	bpl.s	.Skip
	moveq	#1,d1
.Skip	add.w	d1,d0
	cmp.w	Prg_NLigne(a6),d0
	bcc	Ed_BTex
	add.w	d1,Edt_YPos(a4)
	bset	#EtA_Y,Edt_EtatAff(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	bra	Ed_NewBuf

;
; Scrolling sous le curseur HAUT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SHaut
	bsr	Ed_TokCur
	tst.w	Edt_YPos(a4)
	beq	CFin
Ed_SHaut2
	subq.w	#1,Edt_YPos(a4)
	moveq	#0,d1
	moveq	#0,d2
	WiCall	Locate
	bra	Ed_CHt

;
; Scrolling sous le curseur BAS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SBas
	bsr	Ed_TokCur
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	cmp.w	Prg_NLigne(a6),d0
	bcc	CFin
Ed_SBas2
	addq.w	#1,Edt_YPos(a4)
	moveq	#0,d1
	move.w	Edt_WindTy(a4),d2
	subq.w	#1,d2
	WiCall	Locate
	bra	Ed_CBs

;
; Scrolling sous le curseur GAUCHE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SGauche
	bsr	Ed_TokCur
	tst.w	Edt_XPos(a4)
	beq	CFin
	subq.w	#1,Edt_XCu(a4)
	bra	Ed_CGo

;
; Scrolling sous le curseur DROITE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SDroite
	bsr	Ed_TokCur
	move.w	Edt_XCu(a4),d0
	cmp.w	#250,d0
	bcc	CFin
	addq.w	#1,Edt_XCu(a4)
	bra	Ed_CDr

;
; Haut du texte
; ~~~~~~~~~~~~~
Ed_HTexte
	bsr	Ed_TokCur
	bsr	Ed_AutoMarks
Ed_HTex
	clr.w	Edt_YPos(a4)
	clr.w	Edt_XPos(a4)
	clr.w	Edt_YCu(a4)
	clr.w	Edt_XCu(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	bsr	Ed_NewBuf
	bra	Ed_CHtE

;
; Bas du texte
; ~~~~~~~~~~~~
Ed_BTexte
	bsr	Ed_TokCur
	bsr	Ed_AutoMarks
Ed_BTex
	move.w	Prg_NLigne(a6),d0
	move.w	Edt_WindTy(a4),d1
	lsr.w	#1,d1				*XXX EdTy-EdTY/3
	sub.w	d1,d0
	bcc.s	.BTx1
	moveq	#0,d0
.BTx1	move.w	d0,Edt_YPos(a4)
	neg.w	d0
	add.w	Prg_NLigne(a6),d0
	move.w	d0,Edt_YCu(a4)
	clr.w	Edt_XPos(a4)
	clr.w	Edt_XCu(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	bsr	Ed_NewBuf
	bra	Ed_CBasE

;
; NEXT / PREVIOUS label
; ~~~~~~~~~~~~~~~~~~~~~
Ed_PLabel
	bsr	Ed_TokCur
	bsr	Ed_NLab
	move.w	d1,d0
	beq	Ed_HTexte
	bra.s	NLb1
Ed_NLabel
	bsr	Ed_TokCur
	bsr	Ed_NLab
	move.w	d2,d0
	beq	Ed_HTexte
NLb1	cmp.w	Prg_NLigne(a6),d0
	bcc	Ed_BTexte
	bsr	Ed_AutoMarks
	or.b	#EtA_BXY,Edt_EtatAff(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	move.w	d0,d1
	sub.w	Edt_YCu(a4),d0
	bpl.s	NLb2
	clr.w	d0
	move.w	d1,Edt_YCu(a4)
NLb2:	move.w	d0,Edt_YPos(a4)
	clr.w	Edt_XCu(a4)
	bra	Ed_NewBuf

;
; Copie chaine
; ~~~~~~~~~~~~
EdCocop	move.b	(a0)+,(a1)+
	bne.s	EdCocop
	rts
;
; D0 > majuscule
; ~~~~~~~~~~~~~~
MajD0ed	cmp.b	#"a",d0
	bcs.s	.skip
	cmp.b	#"z",d0
	bhi.s	.skip
	sub.b	#$20,d0
.skip	rts
;
; Ramene VRAI si D2 est une lettre ou un chiffre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Une_Lettre
	cmp.b	#"0",d2
	bcs.s	LFaux
	cmp.b	#"9",d2
	bls.s	LVrai
	cmp.b	#"A",d2
	bcs.s	LFaux
	cmp.b	#"Z",d2
	bls.s	LVrai
	cmp.b	#"a",d2
	bcs.s	LFaux
	cmp.b	#"z",d2
	bls.s	LVrai
	cmp.b	#128,d2
	bcc.s	LVrai
LFaux:	moveq	#0,d2
	rts
LVrai:	moveq	#-1,d2
	rts


; ___________________________________________________________________
;
;								MARKS
; ___________________________________________________________________

; Effacement des marques programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_MarkRaz
	lea	Prg_Marks(a6),a0
	moveq	#10-1,d0
.Cl	clr.l	(a0)+
	dbra	d0,.Cl
	rts

; Positionne la premiere system-mark
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AutoMarks
	movem.l	a0-a1/d0-d1,-(sp)
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	swap	d0
	move.b	#$FF,d0
	lsl.w	#8,d0
	move.b	Edt_XCu+1(a4),d0
	lea	Prg_Marks(a6),a0
	cmp.l	(a0),d0
	beq.s	.Rien
; Remonte toutes les marques
	lea	Ed_AutoMarksNb*4-4(a0),a1
	moveq	#Ed_AutoMarksNb-2,d1
.Loop	move.l	-(a1),4(a1)
	dbra	d1,.Loop
; Met la nouvelle
	move.l	d0,(a0)
.Rien	movem.l	(sp)+,a0-a1/d0-d1
	rts

; Set MARK
; ~~~~~~~~
Ed_SMark9
	addq.w	#1,d0
Ed_SMark8
	addq.w	#1,d0
Ed_SMark7
	addq.w	#1,d0
Ed_SMark6
	addq.w	#1,d0
Ed_SMark5
	addq.w	#1,d0
Ed_SMark4
	addq.w	#1,d0
Ed_SMark3
	addq.w	#1,d0
Ed_SMark2
	addq.w	#1,d0
Ed_SMark1
	addq.w	#1,d0
Ed_SMark0
	bsr	Ed_TokCur
	lea	Prg_Marks(a6),a2
	lsl.w	#2,d0
	add.w	d0,a2
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	move.w	d0,(a2)+
	move.b	#$FF,(a2)+
	move.b	Edt_XCu+1(a4),(a2)
	moveq	#64,d0
	bra	Ed_Al100
;
; Va a une marque
; ~~~~~~~~~~~~~~~
Ed_GMark9
	addq.w	#1,d0
Ed_GMark8
	addq.w	#1,d0
Ed_GMark7
	addq.w	#1,d0
Ed_GMark6
	addq.w	#1,d0
Ed_GMark5
	addq.w	#1,d0
Ed_GMark4
	addq.w	#1,d0
Ed_GMark3
	addq.w	#1,d0
Ed_GMark2
	addq.w	#1,d0
Ed_GMark1
	addq.w	#1,d0
Ed_GMark0
	bsr	Ed_TokCur
	lea	Prg_Marks(a6),a2
	lsl.w	#2,d0
	add.w	d0,a2
	tst.l	(a2)
	beq	Ed_NoMark
	bsr	Ed_AutoMarks
	move.w	(a2),d0
	move.l	a2,-(sp)
	bsr	Ed_GotoY
	move.l	(sp)+,a2
	moveq	#0,d0
	move.b	3(a2),d0
	bra	Ed_GotoX

; Passe les marks en adresses dans le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Marks2Adress
	movem.l	a0-a2/d0-d2,-(sp)
	moveq	#9,d2
	lea	Prg_Marks(a6),a2
.Loop	tst.l	(a2)
	beq.s	.Nx
	move.w	(a2),d0
	bsr	Ed_FindL
	beq.s	.Clr
	sub.l	Prg_StBas(a6),a0
	move.l	a0,d0
	lsl.l	#8,d0
	move.b	3(a2),d0
	move.l	d0,(a2)
	bra.s	.Nx
.Clr	clr.l	(a2)
.Nx	addq.l	#4,a2
	dbra	d2,.Loop
	movem.l	(sp)+,a0-a2/d0-d2
	rts
; Repasse en numero de lignes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Marks2Number
	movem.l a0-a2/d0-d2,-(sp)
	moveq	#9,d2
	lea	Prg_Marks(a6),a2
.Loop	move.l	(a2),d0
	beq.s	.Nx
	lsr.l	#8,d0
	add.l	Prg_StBas(a6),d0
	move.l	d0,a0
	bsr	Ed_FindA
	move.w	d0,(a2)
	move.b	#$FF,2(a2)
	bra.s	.Nx
.Clr	clr.l	(a2)
.Nx	addq.l	#4,a2
	dbra	d2,.Loop
	movem.l	(sp)+,a0-a2/d0-d2
	rts
;
;  Change les marks
;  ~~~~~~~~~~~~~~~~
;	D0= Numero ligne
;	D1= Nombre de lignes
Ed_MarksChange
	movem.l	d1/d2/d3/d4/a0,-(sp)
	moveq	#9,d2
	move.w	d0,d3
	lea	Prg_Marks(a6),a0
	tst.w	d1
	bmi.s	.DLi
; Insertion d'une ligne
.ILi1	tst.l	(a0)
	beq.s	.ILi2
	cmp.w	(a0),d0
	bgt.s	.ILi2
	add.w	d1,(a0)
.ILi2	addq.l	#4,a0
	dbra	d2,.ILi1
	bra.s	.Out
; Suppression d'une ligne
.DLi	sub.w	d1,d3
.DLi1	tst.l	(a0)
	beq.s	.DLi2
	cmp.w	(a0),d3
	ble.s	.DLiA
	cmp.w	(a0),d0
	bgt.s	.DLi2
	clr.l	(a0)
	bra.s	.DLi2
.DLiA	add.w	d1,(a0)
.DLi2	addq.l	#4,a0
	dbra	d2,.DLi1
; Sortie!
.Out	movem.l	(sp)+,d1/d2/d3/d4/a0
	rts

; ____________________________________________________________________________
;
;								QUIT
; ____________________________________________________________________________
;


; QUIT ALL!
; ~~~~~~~~~
Ed_Quit	bsr	Ed_TokCur

; Demander confirmation?
; ~~~~~~~~~~~~~~~~~~~~~~
	btst	#0,Ed_QuitFlags(a5)
	beq.s	.NoDia
	moveq	#EdD_Quit,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_Loop
.NoDia

Ed_DoQuit
	bsr	Ed_TokCur
	bsr	Edt_ClearVar
; Au revoir!
; ~~~~~~~~~~
	moveq	#"B",d0
	bsr	Ed_SamPlay
; Sauver la config?
; ~~~~~~~~~~~~~~~~~
	btst	#1,Ed_QuitFlags(a5)		Sauver?
	beq.s	.NoConf
	tst.b	EdC_Changed(a5)			Modification?
	beq.s	.NoConf
	bsr	EdC_SaveDef			Va sauver
.NoConf
; Sauver les macros?
; ~~~~~~~~~~~~~~~~~~
	btst	#2,Ed_QuitFlags(a5)
	beq.s	.NoMac
	tst.b	EdMa_Changed(a5)
	beq.s	.NoMac
	bsr	EdMa_SaveDef			Va sauver
.NoMac
; Sauver les d�finitions des programmes?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#3,Ed_QuitFlags(a5)
	bne.s	.SavAll
;
; Sauvegarde des programmes non sauves, et QUIT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_List(a5),a4
.SLoop	move.l	Edt_Prg(a4),a6
	bsr	Ed_Saved
	move.l	Edt_Next(a4),d0
	move.l	d0,a4
	bne.s	.SLoop
	bra	Ed_System
;
; Sauvegarde de la configuration de l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.SavAll
	move.w	#149,d0
	bsr	Ed_AverMess
; Sauve toutes structures programmes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#1,d7
	move.l	Edt_List(a5),a4
.QLp	move.l	Edt_Prg(a4),a6		Structure programme...
	tst.l	Edt_LinkPrev(a4)	Sauve une seule fois!
	bne.s	.PNext
	tst.b	Prg_NamePrg(a6)		Un nom?
	beq.s	.NoName
	tst.b	Prg_Change(a6)		Deja sauve!
	beq.s	.PNext
; Programme avec un nom.
	clr.b	Prg_NoNamed(a6)
	lea	Prg_NamePrg(a6),a0
	move.l	Name1(a5),a1
	bsr	EdCocop
	bra.s	.Save
; Programme sans nom: NEW_PROJECT_XX.AMOS
.NoName	addq.b	#1,Prg_NoNamed(a6)	Flag pour reload!
	moveq	#49,d0
	bsr	Ed_GetSysteme		New_Project_
	move.l	Name1(a5),a1
	bsr	EdCocop
	lea	-1(a1),a0
	move.l	d7,d0			##
	JJsrR	L_LongToDec,a2
	move.l	a0,a1
	moveq	#22,d0			.AMOS
	bsr	Ed_GetSysteme
	bsr	EdCocop
.Save	JJsr	L_Dsk.PathIt
	JJsr	L_Prg_Save
	bne	.Err
.PNext	addq.w	#1,d7
	move.l	Prg_Next(a4),d0
	move.l	d0,a4
	bne.s	.QLp
; Ouvre le fichier last cession
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#47,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	move.l	#1006,d2
	bsr	Ed_Open
	beq	.Err
; Place pour l'entete + longueur
	move.l	Buffer(a5),a3
	clr.l	(a3)
	clr.l	4(a3)
	move.l	a3,d2
	moveq	#8,d3
	bsr	Ed_Write
	bne	.Err
; Sauve toutes les structures PRG
	move.l	Prg_List(a5),a6
.PLoop	move.l	a6,a0
	move.l	#Prg_Long,d0
	bsr	.StructureSave
	bne	.Err
	move.l	Prg_Next(a6),d0
	move.l	d0,a6
	bne.s	.PLoop
	sub.l	a0,a0
	bsr	.StructureSave
	bne	.Err
; Sauve toutes les structures EDT
	move.l	Edt_List(a5),a4
.ELoop	clr.w	Edt_Order(a4)		Programme courant
	cmp.l	Edt_Current(a5),a4
	bne.s	.ESkip
	move.w	#1,Edt_Order(a4)	Edt_Order<>0
.ESkip	move.l	a4,a0
	move.l	#Edt_Long,d0
	bsr	.StructureSave
	bne	.Err
	move.l	Edt_Next(a4),d0
	move.l	d0,a4
	bne.s	.ELoop
	sub.l	a0,a0
	bsr	.StructureSave
	bne	.Err
; Met la reconnaissance en tete de fichier
	moveq	#0,d2
	moveq	#-1,d3
	bsr	Ed_Seek
	move.l	#Ed_QuitHead,(a3)
	subq.l	#8,d0
	move.l	d0,4(a3)
	move.l	a3,d2
	moveq	#8,d3
	bsr	Ed_Write
	bne.s	.Err
; On s'en va!
	bsr	Ed_Close
	bsr	Ed_AllAverFin
	bra	Ed_System
; Erreur: message et retour!
.Err	bsr	Ed_Close
	bsr	Ed_AllAverFin
	moveq	#EdD_NoWarm,d0
	bsr	Ed_Dialogue
	bsr	Ed_DrawWindows
	rts
; Sauve une structure avec son adresse en premier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.StructureSave
	movem.l	a0/d0,-(sp)
	move.l	a0,(a3)
	beq.s	.Vide
	move.l	d0,4(a3)
	clr.l	8(a3)
	move.l	a3,d2
	moveq	#12,d3
	bsr	Ed_Write
	bne.s	.SErr
	movem.l	(sp)+,a0/d0
	move.l	a0,d2
	move.l	d0,d3
	bsr	Ed_Write
	rts
.Vide	move.l	a3,d2
	moveq	#4,d3
	bsr	Ed_Write
.SErr	addq.l	#8,sp
	rts

;
; Set QUIT OPTIONS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_QuitOptions
	bsr	Ed_TokCur
	move.l	Ed_VDialogues(a5),a0
	move.b	Ed_QuitFlags(a5),d0
	moveq	#4,d1
	JJsrR	L_Dia_SetVFlags,a1
	moveq	#EdD_OQuit,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_Loca
	move.l	Ed_VDialogues(a5),a0
	moveq	#4,d1
	JJsrR	L_Dia_GetVFlags,a1
	move.b	d0,Ed_QuitFlags(a5)
	move.b	#1,EdC_Changed(a5)
	rts

; ______________________________________________________________________________
;
;							EDITOR INFORMATIONS
; ______________________________________________________________________________
;

; About
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_About
	JLea	L_VersionN,a0
	bsr	Ed_DChaine
	move.l	Ed_VDialogues(a5),a2
	move.l	a1,0*4(a2)
	lea	AdTokens+4(a5),a0	Compte les extensions
	moveq	#26-1,d0
	moveq	#0,d2
.Cpt	tst.l	(a0)+
	beq.s	.PaE
	addq.w	#1,d2
.PaE	dbra	d0,.Cpt
	move.l	d2,1*4(a2)
	JLea	L_UserReg,a0		Registration #
	move.l	Name2(a5),a1
	moveq	#$73,d0
	JJsrP	L_Sys_UnCode,a2
	move.l	a1,3*4(a2)
	lea	16(a0),a0		Registred user
	lea	16(a1),a1
	move.b	#$A5,d0
	JJsrP	L_Sys_UnCode,a2
	move.l	a1,2*4(a2)
	moveq	#EdD_Title,d0
	bsr	Ed_Dialogue
	rts

; About extensions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AboutExt
	move.l	Ed_VDialogues(a5),a2
; Trouve la premiere extension
	lea	AdTokens(a5),a3
	moveq	#0,d3
	bsr	.Next
	tst.w	d3
	beq.s	.Out
; Appelle le dialogue
.Loop	move.l	d3,0*4(a2)
	lea	.Empty(pc),a1
	move.l	(a3),a0
	move.l	LB_Title(a0),d0
	beq.s	.Sk
	move.l	d0,a1
.Sk	move.l	a1,1*4(a2)
	moveq	#EdD_AboutE,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	beq.s	.Prv
	cmp.w	#2,d0
	beq.s	.Nxt
.Out	rts
; Suivant
.Nxt	bsr	.Next
	bra.s	.Loop
; Precedent
.Prv	bsr	.Prev
	bra.s	.Loop
; Previous extension
.Prev	move.l	d3,d0
	move.l	a3,a0
.Pr1	cmp.w	#1,d0
	bls.s	.POut
	subq.w	#1,d0
	tst.l	-(a0)
	beq.s	.Pr1
	move.l	d0,d3
	move.l	a0,a3
.POut	rts
; Next extension
.Next	move.l	d3,d0
	move.l	a3,a0
.Ne1	cmp.w	#26,d0
	bcc.s	.NOut
	addq.w	#1,d0
	addq.l	#4,a0
	tst.l	(a0)
	beq.s	.Ne1
	move.l	d0,d3
	move.l	a0,a3
.NOut	rts
.Empty	dc.w	0

; Informations
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Infos
	bsr	Ed_TokCur
	bsr	Ed_VaTester
	move.l	Ed_VDialogues(a5),a2
	move.l	a6,-(sp)
	move.l	$4.w,a6
; Chip Free
	move.l	#Chip,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,0*4(a2)
; Fast Free
	move.l	#Fast,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,1*4(a2)
	move.l	(sp)+,a6
; Text length
	move.l	Prg_StHaut(a6),d0
	sub.l	Prg_StBas(a6),d0
	move.l	d0,2*4(a2)
; Bank length
	JJsr	L_Bnk.GetLength
	add.l	d2,d0
	add.l	d1,d0
	move.l	d0,3*4(a2)		Banques totales
	move.l	d1,5*4(a2)		Bobs
	move.l	d2,6*4(a2)		Icones
; Number of lines
	moveq	#0,d0
	move.w	Prg_NLigne(a6),d0
	move.l	d0,4*4(a2)
; Number of instructions
	move.l	BMenage(a5),5*4(a2)
	move.l	VerNInst(a5),5*4(a2)
; Appelle les dialogues
	moveq	#EdD_Infos,d0
	bsr	Ed_Dialogue
	rts

; __________________________________________________________________________
;
;						BANQUES / CONFIG EDITEUR
; __________________________________________________________________________
;
;
; Chargement/Effacement de la banque de resource (pas de gestion d'erreurs)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ResourceLoad
; Charge la banque
	bsr	Ed_SetBanks
	move.l	#1005,d2
	bsr	Ed_Open
	beq.s	.DErr
	moveq	#6,d0
	JJsr	L_Bnk.Load
	bne.s	.MErr
	bsr	Ed_Close
; Change les adresses
	moveq	#6,d0
	JJsr	L_Bnk.GetAdr
	beq.s	.2Err
	cmp.l	#"Reso",-8(a0)
	bne.s	.2Err
	move.l	a0,Ed_Resource(a5)
	bsr	EdC_SetPalette
	moveq	#0,d0
	rts
.DErr	moveq	#2,d0
	rts
.MErr	moveq	#1,d0
	rts
.2Err	moveq	#3,d0
	rts
; Effacement de la banque de configuration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ResourceFree
	bsr	Ed_SetBanks
	moveq	#6,d0
	JJsr	L_Bnk.Eff
	rts
; Change la palette de couleur en fonction des prefs de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_SetPalette
	move.l	Ed_Resource(a5),d0
	beq.s	.Skip
	move.l	d0,a0
	add.l	2(a0),a0
	move.w	(a0),d0
	lsl.w	#2,d0
	lea	2+2+2(a0,d0.w),a0
	lea	Ed_Palette(a5),a1
	moveq	#7,d0
.Copy	move.w	(a1)+,(a0)+
	dbra	d0,.Copy
.Skip	rts

; Chargement/Effacement de la banque de samples (pas de gestion d'erreurs)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SamChanged
	bsr	Ed_SetBanks
	tst.b	Ed_Sounds(a5)
	bne.s	.Sons
; Pas de sons, effacer la banque?
	moveq	#5,d0
	JJsr	L_Bnk.GetAdr
	bne.s	Ed_SamEnd
	bra.s	.Out
; Il faut faire des sons, charger la banque?
.Sons	moveq	#5,d0
	JJsr	L_Bnk.GetAdr
	bne.s	.Out
	moveq	#48,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
; Charge la banque
	move.l	#1005,d2
	bsr	Ed_Open
	beq.s	.Out
	bsr	Ed_SetBanks
	moveq	#5,d0
	JJsr	L_Bnk.Load
	bsr	Ed_Close
; Ok
.Out	rts

; Effacement de la banque de samples
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SamEnd
	bsr	Ed_SetBanks
	moveq	#5,d0
	JJsr	L_Bnk.Eff
	rts
;
; Joue le sample D0 (lettre de A � Z)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SamPlay
	movem.l	d0-d3/a0-a2,-(sp)
	tst.b	Ed_Sounds(a5)
	beq.s	.Out
	tst.b	Ed_Zappeuse(a5)
	bne.s	.Out
	move.w	d0,d2
	bsr	Ed_SetBanks
	moveq	#5,d0
	JJsr	L_Bnk.GetAdr
	beq.s	.Out
	cmp.l	#"Samp",-8(a0)
	bne.s	.Out
; Trouve le sample
	move.w	(a0),d1
	subq.w	#1,d1
	bmi.s	.Out
	lea	2(a0),a1
.Loop	move.l	(a1)+,d0
	lea	0(a0,d0.l),a2
	cmp.b	(a2),d2
	beq.s	.Found
	dbra	d1,.Loop
	bra.s	.Out
; Appelle la trappe
.Found	moveq	#0,d3
	move.w	8(a2),d3
	move.l	10(a2),d2
	lea	14(a2),a1
	moveq	#%1111,d1
	move.l	ExtAdr(a5),d0
	beq.s	.Out
	move.l	d0,a0
	jsr	-4(a0)
; Fini!
.Out	movem.l	(sp)+,d0-d3/a0-a2
	rts


; ___________________________________________________________________
;
;							CONFIG!
; ___________________________________________________________________
;

; Met les banques de m�moire/dialogue de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SetBanks
	move.l	a0,-(sp)
	lea	Ed_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	lea	Ed_Dialogs(a5),a0
	move.l	a0,Cur_Dialogs(a5)
	move.l	(sp)+,a0
	rts

; Sauvegarde configuration par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_SaveDefault
	bsr	Ed_TokCur
	moveq	#EdD_SvConf,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
EdC_SaveDef
	moveq	#7,d0
	JJsr	L_Sys_GetMessage
	JJsrR	L_Sys_AddPath,a1
	bsr	EdC_SaveIt
	rts
; Sauvegarde de la configuration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_SaveAs
	bsr	Ed_TokCur
	move.w	#130,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	bsr	Ed_SaveOver
EdC_SaveIt
	move.w	#152,d0
	bsr	Ed_GetMessage
	bsr	Ed_Avertir
	bsr	EdC_Save
	bne.s	.Err
	bsr	Ed_AverFin
	clr.b	EdC_Changed(a5)
	rts
; Erreur disque
.Err	move.w	#139,d0
	bra	Ed_Al100

; Chargement de la configuration par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_LoadDefault
	bsr	Ed_TokCur
	bsr	EdC_Saved
EdC_LoadDef
	moveq	#7,d0
	JJsr	L_Sys_GetMessage
	JJsrR	L_Sys_AddPath,a1
	bsr	EdC_LoadIt
	move.b	#2,EdC_Changed(a5)
	rts
; Chargement de la configuration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_LoadAs
	bsr	Ed_TokCur
	bsr	EdC_Saved
	move.w	#134,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	bsr	EdC_LoadIt
	move.b	#2,EdC_Changed(a5)
	rts
EdC_LoadIt
	move.w	#153,d0
	bsr	Ed_AverMess
	bsr	EdC_Load
	bne	.Err
	bsr	Ed_AverFin
	move.w	#218,d0			Message
	bsr	Ed_AverMess
	moveq	#75,d0			Attente
	bsr	Ed_TiWait
	bsr	EdC_Redraw
	rts
; Erreur
.Err	move.w	#139,d0
	bra	Ed_Al100

; Redessin de TOUT l'editeur en cas de changement de config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_Redraw
	bsr	Ed_SamChanged
	bsr	Ed_Hide
	bsr	Ed_CloseEditor
	move.b	#1,EdC_Modified(a5)
	bsr	Ed_OpenEditor
	bsr	Ed_Appear
	rts
;
; Sauvegarde de la configuration si modifiee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_Saved
	cmp.b	#1,EdC_Changed(a5)
	bne.s	.Skip
	moveq	#EdD_CSaved,d0
	bsr	Ed_Dialogue
	cmp.w	#2,d0
	beq.s	.Skip
	cmp.w	#1,d0
	bne	Ed_NotDone
	bsr	EdC_SaveAs
.Skip	rts

;
; Chargement de la configuration A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_Load
	move.l	#1005,d2
	bsr	Ed_Open
	beq	.DErr
; Charge la config elle meme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),a0
	move.l	a0,d2
	moveq	#4,d3
	bsr	Ed_Read
	bne	.DErr
	move.l	d2,a0
	move.l	#Ed_FConfig-Ed_DConfig,d3
	cmp.l	(a0),d3
	bne	.Err2
	lea	Ed_DConfig(a5),a0
	move.l	a0,d2
	bsr	Ed_Read
	bne	.DErr
	move.l	d2,Ed_Config(a5)
; Charge les chaines systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_Systeme(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les chaines menus
; ~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EdM_Messages(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les messages dialog
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_Messages(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les messages erreur TEST TIME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_TstMessages(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les messages erreur RUN TIME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_RunMessages(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les programmes � lancer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_MnPrograms(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les user menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EdM_User(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Charge les definitions menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EdM_Definition(a5),a0
	bsr	EdC_LoadTextes
	bne	EdC_Out
; Calcule les positions dans la ligne de config
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#1,d0
	bsr	Ed_GetSysteme
	moveq	#-1,d1
	lea	Ed_EtXX(a5),a1
.Loop1	addq.l	#1,d1
	move.b	(a0)+,d0
	beq.s	.Out1
	cmp.b	#" ",d0
	beq.s	.Loop1
	sub.b	#"0",d0
	cmp.b	#8,d0
	bcc.s	.Loop1
	ext.w	d0
	move.b	d1,0(a1,d0.w)
	bra.s	.Loop1
.Out1
; Ok!
	moveq	#0,d0
	bra	EdC_Out
; File not found
.DErr	moveq	#1,d0
	bra	EdC_Out
; Bad config
.Err2	moveq	#2,d0
	bra	EdC_Out

; Effacement de la configuration courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_Free
	lea	Ed_Systeme(a5),a0		1
	bsr	Ed_MemFree
	lea	EdM_Messages(a5),a0		2
	bsr	Ed_MemFree
	lea	Ed_Messages(a5),a0		3
	bsr	Ed_MemFree
	lea	Ed_TstMessages(a5),a0		4
	bsr	Ed_MemFree
	lea	Ed_RunMessages(a5),a0		5
	bsr	Ed_MemFree
	lea	Ed_MnPrograms(a5),a0		6
	bsr	Ed_MemFree
	lea	EdM_User(a5),a0			7
	bsr	Ed_MemFree
	lea	EdM_Definition(a5),a0		8
	bsr	Ed_MemFree
	rts

;
; Sauvegarde de la configuration courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Nom
EdC_Save
	move.l	#1006,d2
	bsr	Ed_Open
	beq	.DErr
; Sauve la config elle meme
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),a0
	move.l	#Ed_FConfig-Ed_DConfig,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	Ed_Write
	bne.s	.DErr
	lea	Ed_DConfig(a5),a0
	move.l	a0,d2
	move.l	#Ed_FConfig-Ed_DConfig,d3
	bsr	Ed_Write
	bne.s	.DErr
; Sauve les chaines systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_Systeme(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les chaines menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EdM_Messages(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les messages dialogues
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_Messages(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les messages d'erreur TEST TIME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_TstMessages(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les messages d'erreur RUN TIME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_RunMessages(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les programmes � lancer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Ed_MnPrograms(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les user menus
; ~~~~~~~~~~~~~~~~~~~~
	lea	EdM_User(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Sauve les definitions menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EdM_Definition(a5),a0
	bsr	EdC_SaveTextes
	bne.s	EdC_Out
; Ok!
; ~~~
	moveq	#0,d0
	bra	EdC_Out
.DErr	moveq	#1,d0
; Sortie chargement/sauvegarde fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdC_Out	move.l	d0,-(sp)
	bsr	Ed_Close
	move.l	(sp)+,d0
EdC_Out2
	tst.l	d0
	rts

;
; Charge un fichier de textes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse du pointeur dans (a5)
;	D7=	Lock
EdC_LoadTextes
	movem.l	a0-a2/d2-d3,-(sp)
	move.l	a0,a2
	bsr	Ed_MemFree
	move.l	Buffer(a5),d2
	moveq	#4,d3
	bsr	Ed_Read
	bne.s	.Err
	move.l	d2,a0
	move.l	(a0),d3
	beq.s	.Skip
	move.l	d3,d0
	move.l	a2,a0
	bsr	Ed_MemReserve
	beq.s	.Err
	move.l	a0,d2
	bsr	Ed_Read
	bne.s	.Err
.Skip	moveq	#0,d0
	bra.s	.Out
.Err	move.l	a2,a0
	bsr	Ed_MemFree
	moveq	#-1,d0
.Out	movem.l	(sp)+,a0-a2/d2-d3
	rts
;
; Sauve un fichier de textes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse du pointeur dans (a5)
;	D7=	Lock
EdC_SaveTextes
	movem.l	a0-a2/d2-d3,-(sp)
	move.l	a0,a2
	move.l	(a2),d0
	bne.s	.Plin
	move.l	a2,d2
	moveq	#0,d3
	bra.s	.Wri
.Plin	move.l	d0,a0
	move.l	-(a0),d3
	move.l	a0,d2
.Wri	addq.l	#4,d3
	bsr	Ed_Write
	bne.s	.Err
	moveq	#0,d0
	bra.s	.Out
.Err	moveq	#-1,d0
.Out	movem.l	(sp)+,a0-a2/d2-d3
	rts

; Change / Ajoute un message dans un fichier de textes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0= 	Base des textes
;	A1=	Nouveau message
;	D0=	Numero du message
EdC_ChangeTexte
	movem.l	a2-a4/d2-d5,-(sp)
	move.l	a0,a2
	move.l	a1,a3
	move.w	d0,d2
; Taille du nouveau message
.Lg	tst.b	(a1)+
	bne.s	.Lg
	sub.l	a3,a1
	subq.l	#1,a1
	move.l	a1,d3
; Nombre de messages
	move.l	(a2),a0
	bsr	Ed_GetNbMessage
	cmp.w	d0,d2
	bhi.s	.New
; Un ancien message, calcul de la taille
	move.w	d2,d0
	move.l	(a2),a0
	bsr	Ed_GetMessageA0
	neg.w	d0
	add.w	d3,d0
	ext.l	d0
	bra.s	.Res
; Un nouveau message
.New	moveq	#2,d0
	add.l	d3,d0
; Reserve la nouvelle memoire
.Res	move.l	(a2),a0
	add.l	-(a0),d0
	move.l	d0,d1
	addq.l	#4,d0
	SyCall	MemFastClear
	beq.s	.Err
	move.l	d1,(a0)+
	move.l	a0,d5
; Recopie les anciens messages
	move.l	(a2),a1
	addq.l	#1,a1
	clr.b	(a0)+
	moveq	#0,d1
	moveq	#0,d4
.Cp0	addq.w	#1,d1
	moveq	#0,d4
	move.b	(a1),d4
	bmi.s	.CpX
	lea	1(a1),a4
	lea	2(a1,d4.w),a1
	cmp.b	d1,d2
	bne.s	.Cp1
	move.l	a3,a4
	move.b	d3,d4
	moveq	#-1,d2
.Cp1	move.b	d4,(a0)+
	beq.s	.Cp3
	subq.w	#1,d4
.Cp2	move.b	(a4)+,(a0)+
	dbra	d4,.Cp2
.Cp3	clr.b	(a0)+
	bra.s	.Cp0
; Le dernier message?
.CpX	tst.w	d2
	bmi.s	.CpY
	move.b	d3,(a0)+
	beq.s	.Cp5
.Cp4	move.b	(a3)+,(a0)+
	subq.b	#1,d3
	bne.s	.Cp4
.Cp5	clr.b	(a0)+
.CpY
; Marque la fin
	move.b	#-1,(a0)+
; Efface l'ancien texte
	move.l	a2,a0
	bsr	Ed_MemFree
; Branche le nouveau, et fini!
	move.l	d5,(a2)
	moveq	#0,d0
	bra.s	.Out
; Erreur, out of mem!
.Err	moveq	#-1,d0
.Out	movem.l	(sp)+,a2-a4/d2-d5
	rts
;
; Get FIRST message free
; ~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Base des messages
Ed_GetFsMessage
	moveq	#0,d0
	moveq	#0,d1
	move.l	a0,a1
.Loop	addq.l	#1,d0
	move.b	1(a0),d1
	beq.s	.Out
	lea	2(a0,d1.w),a0
	bpl.s	.Loop
.New	move.l	a1,a0
	bsr	Ed_GetNbMessage
	addq.w	#1,d0
.Out	rts

;
; Get number of messages
; ~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Base des messages
Ed_GetNbMessage
	moveq	#0,d0
	moveq	#0,d1
	bra.s	.In
.Loop	addq.w	#1,d0
	lea	2(a0,d1.w),a0
.In	move.b	1(a0),d1
	bpl.s	.Loop
	rts
;
; Get new editor message
; ~~~~~~~~~~~~~~~~~~~~~~
Ed_GetSysteme
	move.l	Ed_Systeme(a5),a0
	bra.s	Ed_GetMessageA0
Ed_GetMessage
	move.l	Ed_Messages(a5),a0
Ed_GetMessageA0
	move.w	d1,-(sp)
	clr.w	d1
	addq.l	#1,a0
	bra.s	.In
.Loop	move.b	(a0),d1
	lea	2(a0,d1.w),a0
.In	subq.w	#1,d0
	bgt.s	.Loop
	move.w	(sp)+,d1
	move.b	(a0)+,d0
	rts
; Get NEXT message
; ~~~~~~~~~~~~~~~~
Ed_GetNMessage
	moveq	#0,d0
	move.b	-(a0),d0
	lea	2(a0,d0.w),a0
	move.b	(a0)+,d0
	rts


; ___________________________________________________________________
;
;							AUTOSAVE
; ___________________________________________________________________

;
; Set AUTOSAVE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SetAutoSave
	bsr	Ed_TokCur
	move.l	Ed_VDialogues(a5),a2
	move.l	Ed_AutoSaveMn(a5),2*4(a2)
	moveq	#EdD_ASave,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	moveq	#1,d0
	moveq	#3,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,d2
	cmp.l	Ed_AutoSaveMn(a5),d2
	beq	Ed_Loca
	move.l	d2,Ed_AutoSaveMn(a5)
; PAL ou NTSC
	moveq	#50,d3
	EcCall	NTSC
	tst.w	d1
	beq.s	.PAL
	moveq	#60,d3
; Calcule le temps en 1/50
.PAL	mulu	d3,d2
	mulu	#60,d2
	move.l	d2,Ed_AutoSave(a5)
	move.l	#-1,Ed_AutoSaveRef(a5)
	move.b	#1,EdC_Changed(a5)
	bra	Ed_Loca
;
; AUTOSAVE de tous les programmes modifies
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SaveAuto
	move.w	#-1,-(sp)
	move.l	Edt_List(a5),a4
.Loop	tst.b	Edt_Hidden(a4)
	bne.s	.Skip
	tst.l	Edt_LinkPrev(a4)
	bne.s	.Skip
	addq.w	#1,(sp)
	bne.s	.Snd
	moveq	#"I",d0			Va faire du bruit!
	bsr	Ed_SamPlay
.Snd	move.l	Edt_Prg(a4),a6
	bsr	Ed_Saved
.Skip	move.l	Edt_Next(a4),d0
	move.l	d0,a4
	bne.s	.Loop
	addq.l	#2,sp
	rts

; ___________________________________________________________________
;
;					USER MENU / FONCTION TO MENU
; ___________________________________________________________________

;
; Appel d'une fonction USER MENU>>> il faut affecter un programme!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_UserMenu
	bsr	Ed_TokCur
	moveq	#EdD_MnUs,d0
	bsr	Ed_Dialogue
	bra	Ed_Loca
;
; Add user option to menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AddUser
	bsr	Ed_TokCur
; Nombre d'options
; ~~~~~~~~~~~~~~~~
	move.l	EdM_User(a5),a0
	bsr	Ed_GetFsMessage
	cmp.w	#EdM_UserMax,d0
	bcc.s	.2Many
; Flag pour QUIT
	move.b	#1,EdC_Changed(a5)
	move.w	d0,d3
; Boite de dialogue
; ~~~~~~~~~~~~~~~~~
	move.l	Ed_VDialogues(a5),a0
	clr.l	2*4(a0)
	move.l	#EdM_UserLong,3*4(a0)
	moveq	#EdD_MnUsA,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	moveq	#1,d0
	moveq	#3,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,a1
	tst.b	(a1)
	beq	Ed_NotDone
; Ajoute la fonction
; ~~~~~~~~~~~~~~~~~~
	lea	EdM_User(a5),a0
	move.w	d3,d0
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
; Recalcule le menu et branche � PRG TO MENU
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	EdM_Init
	bsr	Ed_Prg2Menu
	bsr	Ed_Key2Menu
	bra	Ed_Loca
; Too many options
; ~~~~~~~~~~~~~~~~
.2Many	moveq	#EdD_MnUs2,d0
	bsr	Ed_Dialogue
	bra	Ed_Loca

; Delete User Option
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DelUser
	bsr	Ed_TokCur
; Boite de dialogue
; ~~~~~~~~~~~~~~~~~
	moveq	#EdD_MnUsD,d0
	bsr	Mn_GetOption
	beq	Ed_NotDone
	cmp.w	#EdM_UserCommands-1,d2
	bcs.s	.PaOpt
	cmp.w	#EdM_UserCommands-1+EdM_UserMax,d2
	bcc.s	.PaOpt
; Flag pour QUIT
	move.b	#1,EdC_Changed(a5)
; Change dans le texte
; ~~~~~~~~~~~~~~~~~~~~
	move.w	d2,d0
	sub.w	#EdM_UserCommands-1-1,d0
	lea	EdM_User(a5),a0
	move.l	Buffer(a5),a1
	clr.w	(a1)
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
; Enleve les programmes affectes dans la liste
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	d2,d0
	mulu	#3,d0
	lea	Ed_AutoLoad(a5),a2
	add.w	d0,a2
	tst.b	(a2)
	beq.s	.np2
	clr.b	(a2)+
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.np1
	lea	Ed_MnPrograms(a5),a0
	move.l	Buffer(a5),a1
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
.np1	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.np2
	lea	Ed_MnPrograms(a5),a0
	move.l	Buffer(a5),a1
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
; Change dans les touches
; ~~~~~~~~~~~~~~~~~~~~~~~
.np2	move.w	d2,d0
	bsr	Ed_Fonc2Ky
	beq.s	.Skip
	move.b	#1,(a0)+
	move.b	#0,(a0)
; Recalcule le menu
; ~~~~~~~~~~~~~~~~~
.Skip	bsr	EdM_Init
	bra	Ed_Loca
; Pas une option USER
; ~~~~~~~~~~~~~~~~~~~
.PaOpt	moveq	#EdD_MnUsE,d0
	bsr	Ed_Dialogue
	bra	Ed_Loop
;
; Set Program to Menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Prg2Menu
	bsr	Ed_TokCur
; Va chercher l'option de menu
	moveq	#EdD_PrgMn1,d0
	bsr	Mn_GetOption
	beq	Ed_NotDone
	cmp.w	#HiddenCommands-1,d2
	bcc	.PaAff
	cmp.w	#152,d2			Pas un menu HELP
	bcs.s	.Ok
	cmp.w	#181,d2			Ou CONFIG
	bcs	.PaAff
; Flag pour QUIT
.Ok	move.b	#1,EdC_Changed(a5)
	move.w	d2,d3
	move.l	a1,a3			Libelle de l'option
	moveq	#0,d3			Pour EXIT plus loin
; Un programme d�ja affecte?
	mulu	#3,d2
	lea	Ed_AutoLoad(a5),a2
	add.w	d2,a2
	tst.b	(a2)
	beq.s	.NoP
; Boite de dialogue
	moveq	#0,d0
	move.b	1(a2),d0
	beq.s	.NoP
	move.l	Ed_MnPrograms(a5),a0
	bsr	Ed_GetMessageA0
	move.l	Ed_VDialogues(a5),a1
	move.l	a3,0*4(a1)
	move.l	a0,1*4(a1)
	moveq	#EdD_PrgMn2,d0
	bsr	Ed_Dialogue
	move.w	d0,d3
	cmp.w	#3,d3
	beq	Ed_NotDone
; Effacement
	move.b	1(a2),d0			Efface le programme
	move.l	Buffer(a5),a1
	clr.b	(a1)
	lea	Ed_MnPrograms(a5),a0
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
	move.b	2(a2),d0			Efface la command line
	beq.s	.NoP
	move.l	Buffer(a5),a1
	lea	Ed_MnPrograms(a5),a0
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
.NoP	clr.b	(a2)
	clr.b	1(a2)
	clr.b	2(a2)
	cmp.w	#2,d3
	beq	.Exit
; Selecteur de fichiers
	moveq	#100,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	move.l	Ed_VDialogues(a5),a0
	move.l	a3,(a0)+			0= Option
	move.l	Name1(a5),(a0)+			1= Program
	clr.l	(a0)+				2= Pas de chaine en entree
	move.l	#48,(a0)+			3= Longueur
	moveq	#%001,d0
	moveq	#3,d1
	JJsrP	L_Dia_SetVFlags,a2
	moveq	#EdD_PrgMn3,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	move.l	Ed_VDialogues(a5),a0
	lea	4*4(a0),a0
	moveq	#3,d1
	JJsrP	L_Dia_GetVFlags,a2
	or.b	#$80,d0				Met les flags
	move.b	d0,(a2)
	move.l	Ed_MnPrograms(a5),a0
	bsr	Ed_GetFsMessage
	move.b	d0,1(a2)			Pointe le message
	lea	Ed_MnPrograms(a5),a0
	move.l	Name1(a5),a1			Change le message
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
; Une command line?
	moveq	#1,d0
	moveq	#7,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,a1
	tst.b	(a1)
	beq.s	.Exit
	move.l	a1,-(sp)
	move.l	Ed_MnPrograms(a5),a0
	bsr	Ed_GetFsMessage
	move.b	d0,2(a2)			Met la command line
	lea	Ed_MnPrograms(a5),a0
	move.l	(sp)+,a1
	bsr	EdC_ChangeTexte
	bne	Ed_OMm
; Fini
.Exit	bra	Ed_Loca
; This menu option cannot be affected!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PaAff	moveq	#EdD_PrgMnE,d0
	bsr	Ed_Dialogue
	bra	Ed_Loca

;
; Set Key to menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Key2Menu
	bsr	Ed_TokCur
; Va chercher l'option de menu
	moveq	#EdD_KyMn1,d0
	bsr	Mn_GetOption
	beq	Ed_NotDone
	cmp.w	#HiddenCommands-1,d2
	bcc	.PaAff
	move.w	d2,d3
; Trouve la position dans les definitions
	move.w	d3,d0
	lea	Ed_KFonc(a5),a0
	bra.s	.Skip4
.Loop4	addq.l	#2,a0
	tst.b	(a0)
	bne.s	.Loop4
	addq.l	#1,a0
	cmp.b	#$FF,(a0)
	beq	.PaAff
.Skip4	dbra	d0,.Loop4
	move.b	#1,(a0)			Efface l'ancienne definition
	move.b	#0,1(a0)
	move.l	a0,-(sp)
	bsr	EdM_Init
; Va chercher la touche
	moveq	#EdD_KyMn2,d0
	bsr	Ed_Dialogue
	tst.w	d0
	bne	Ed_NotDone
	move.l	Ed_ADialogues(a5),a0
	move.l	Dia_LastKey(a0),d1
	move.l	d1,d4
        beq     Ed_NotDone
	bsr	Ed_Ky2Fonc
	beq.s	.NoAff
; Flag pour QUIT
	move.b	#1,EdC_Changed(a5)
; Key already affected
	moveq	#EdD_KyMn3,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
.NoAff
; Change dans la table
	move.b	d4,d0
        swap    d4
	bsr	MajD0ed
; Met le code ASCII quand on peut!
	move.l	(sp)+,a0
        cmp.b   #"A",d0
        bcs.s   .Scan
        cmp.b   #"Z",d0
        bhi.s   .Scan
        move.b  d0,(a0)
        bra.s   .Shift
; Met le scan code
.Scan   or.b    #$80,d4
        move.b  d4,(a0)
; Met les shifts
.Shift  lsr.w   #8,d4
	moveq	#0,d0
	lea	.Table(pc),a1
.Lp	move.b	(a1)+,d1
	beq.s	.Ot
	move.b	d4,d2
	and.b	d1,d2
	beq.s	.Lp
	or.b	d1,d0
	bra.s	.Lp
.Ot     move.b  d0,1(a0)
; Reactualiser le menu?
.Out    tst.b   EdM_Keys(a5)
        beq.s   .NoMn
        bsr     EdM_Init
; Retour � l'�diteur
.NoMn   bra     Ed_Loca
; This menu option cannot be affected!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PaAff	moveq	#EdD_KyMnE,d0
	bsr	Ed_Dialogue
	bra	Ed_Loca
.Table	dc.b	Shf,Ami,Ctr,Alt,0
	even

; Routine: attend le choix d'une option de menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;       D0=     Boite de dialogue
;
Mn_GetOption
	movem.l	d3-d7/a2-a3,-(sp)
; Boite de dialog
	bsr	Ed_Dialogue		Affiche le dialogue
	moveq	#1,d0			Efface le canal!
	JJsr	L_Dia_EffChannel
; Boucle d'attente
.Loop	JJsr     L_Sys_WaitMul
        SyCall	Inkey
	moveq	#0,d0
	tst.l	d1
	bne	.Out
	SyCall	MouseKey
	btst	#1,d1
	beq.s	.Loop
	bsr	Ed_MnGere
	beq.s	.Loop
; Trouve le libelle de l'option
.Out	movem.l	a0/d0/d2,-(sp)
	bsr	Ed_DrawWindows
	movem.l	(sp)+,a0/d0/d2
	tst.w	d0
	beq.s	.Exit
	bpl.s	.Tab
	bsr	EdM_Error
	moveq	#0,d0
	bra.s	.Exit
.Tab	move.l	EdM_Messages(a5),a1
	move.w	4(a0),d1
	bpl.s	.Mn
	move.l	EdM_User(a5),a1
	neg.w	d1
.Mn	add.w	d1,a1
.Exit	movem.l	(sp)+,d3-d7/a2-a3
	tst.w	d0
	rts


;_____________________________________________________________________________
;
;					MARQUEURS MENU CONFIG
;_____________________________________________________________________________
;
;
; Insert / Overwrite
; ~~~~~~~~~~~~~~~~~~
Ed_Ins	not.b	Ed_Insert(a5)
	bset	#EtA_Ins,Ed_EtatAff(a5)
	bsr	EdM_MarkAll
	bsr	EdK_MarkAll
	rts
; Sound On / Off
; ~~~~~~~~~~~~~~
Ed_SamOn
	not.b	Ed_Sounds(a5)
	bsr	EdM_MarkAll
	move.b	#1,EdC_Changed(a5)
	bsr	Ed_SamChanged
	rts

;_____________________________________________________________________________
;
;							BLOCS
;_____________________________________________________________________________
;

;
; Bloc en route, reaffiche les lignes concernees par le mouvement du curseur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocAff
	tst.w	Edt_YBloc(a4)
	bmi.s	.Out
	move.w	Edt_YOldBloc(a4),d2
	bmi.s	.Out
	move.w	#-1,Edt_YOldBloc(a4)
	move.w	Edt_YPos(a4),d3
	add.w	Edt_YCu(a4),d3
	cmp.w	d2,d3
	bcc.s	.Skip
	exg	d2,d3
.Skip	move.w	d2,d1
	sub.w	Edt_YPos(a4),d1
	bmi.s	.Hors
	cmp.w	Edt_WindTy(a4),d1
	bcc.s	.Hors
	movem.w	d2/d3,-(sp)
	bsr	Ed_ALigne
	bsr	Ed_Loca
	movem.w	(sp)+,d2/d3
.Hors	addq.w	#1,d2
	cmp.w	d3,d2
	bls.s	.Skip
.Out	rts

;
; Start / Stop block
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocOn
	tst.w	Edt_YBloc(a4)
	bpl.s	Ed_BlocHide
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	move.w	d0,Edt_YBloc(a4)
	move.w	Edt_XCu(a4),Edt_XBloc(a4)
	clr.w	Edt_YOldBloc(a4)
Ed_BlocCu
	lea	CurBloc(pc),a1
	WiCall	SCurWi
	rts
Ed_BlocHide
	move.w	#-1,Edt_YBloc(a4)
	bsr	Ed_AffBuf
; Remet le curseur normal
; ~~~~~~~~~~~~~~~~~~~~~~~
Ed_CuNor
	lea	CurNor(pc),a1
	WiCall	SCurWi
	rts
;
; All text as block
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocAll
	bsr	Ed_BlocCu
	clr.w	Edt_XCu(a4)
	clr.w	Edt_YCu(a4)
	clr.w	Edt_XPos(a4)
	clr.w	Edt_YPos(a4)
	clr.w	Edt_XBloc(a4)
	move.w	Prg_NLigne(a6),Edt_YBloc(a4)
	bsr	Ed_NewBufAff
	rts
;
; Block STORE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocStore
	bsr	Ed_BlockLimits
	lea	Ed_Block(a5),a0
	bsr	Ed_BlockCopyA0
	bmi	Ed_OMm
	bne	Ed_BlocWhat
	bsr	Ed_BlocHide
	moveq	#7,d0
	bra	Ed_ProAlert
;
; Block Forget
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocForget
	tst.l	Ed_Block(a5)
	beq	Ed_BlocWhat
	bsr	Ed_BlocFree
	moveq	#8,d0
	bra	Ed_ProAlert
;
; Block CUT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocCut
	bsr	Ed_BlockLimits
	lea	Ed_Block(a5),a0
	bsr	Ed_BlockCopyA0
	bmi	Ed_OMm
	bne	Ed_BlocWhat
	bsr	Ed_BlocHide
	lea	Ed_Block(a5),a0
	bsr	Ed_BlockDeleteA0
	bsr	Prg_UndoRaz		Illegal: remettre plus tard!
	moveq	#7,d0
	bra	Ed_ProAlert
;
; Block PASTE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocPaste
	tst.l	Ed_Block(a5)
	beq	Ed_BlocWhat
	lea	Ed_Block(a5),a0
	bsr	Ed_BlockInsertA0
	bsr	Prg_UndoRaz		Illegal: remettre plus tard!
	rts
;
; Libere le bloc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocFree
	lea	Ed_Block(a5),a0
Ed_BlockFreeA0
	bra	Ed_MemFree
;
; Trouve les limites du bloc dans d4-d7
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlockLimits
	tst.w	Edt_YBloc(a4)
	bmi	Ed_BlocWhat
	moveq	#0,d4
	move.w	Edt_YBloc(a4),d4
	move.w	Edt_YPos(a4),d5
	add.w	Edt_YCu(a4),d5
	move.w	Edt_XBloc(a4),d6
	move.w	Edt_XCu(a4),d7
	cmp.w	d4,d5
	bhi.s	.L0
	bne.s	.Sw
	cmp.w	d6,d7
	bcc.s	.L0
.Sw	exg	d4,d5
	exg	d6,d7
.L0	cmp.w	Prg_NLigne(a6),d5
	bcs.s	.Blu
	move.w	Prg_NLigne(a6),d5
	moveq	#0,d7
.Blu	rts

;
; Insert le bloc du texte en position courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlockInsertA0
	movem.l	d2-d7/a2,-(sp)
	addq.b	#1,Ed_FUndo(a5)
	move.l	(a0),d0
	beq	.Vide
	move.l	d0,a2
; Met le curseur � la bonne position
	movem.w	(a2)+,d4-d6
	move.l	(a2)+,d7
	bsr	Ed_LCourant
	beq.s	.Edit
	tst.w	(a2)			Si ligne non editable,
	bne	Ed_NotEdit		il faut un bloc sans 1ere ligne!
.Edit	cmp.w	d0,d1
	bls.s	.Pl
	move.w	d0,Edt_XCu(a4)
.Pl	move.w	Edt_YPos(a4),d3		Position courante
	add.w	Edt_YCu(a4),d3
; Premiere ligne
	move.w	(a2),d0
	beq.s	.Pa1
	lea	2(a2),a0		Insere la ligne
	bsr	R_InsChar
	bsr	Ed_EALiCu
	move.w	(a2),d0
	add.w	Edt_XCu(a4),d0		Positionne le curseur
	bsr	Ed_GotoX
.Pa1	btst	#30,d7			Une seule ligne?
	bne.s	.Ok
	btst	#31,d7			Un procedure sur la ligne?
	bne.s	.Proc
; Si pas une seule ligne, on fait un RETURN
	movem.l	a2/d2-d7,-(sp)
	bsr	Ed_ReturnQuiet		Return
	bsr	Ed_TokCur		Ligne suivante
	movem.l	(sp)+,a2/d2-d7
	addq.w	#1,d3
.Proc	add.w	(a2)+,a2		Saute la 1ere ligne
	move.l	a2,d0			Rend pair
	Pair	d0
	move.l	d0,a2
; Corps du bloc
	tst.w	(a2)
	beq.s	.NoCor
	lea	6(a2),a0		Insere le bloc en 1 coup
	move.l	2(a2),d0
	move.w	d3,d1
	bsr	Ed_StoBlock
	bne	Ed_OofBuf
	move.w	d3,d0			Change les marques
	move.w	(a2),d1
	bsr	Ed_MarksChange
	add.w	(a2),d3			Plus nombre de lignes
.NoCor	move.l	2(a2),d0
	lea	6(a2,d0.l),a2
; Derniere ligne
	JJsr	L_Prg_CptLines
	move.w	d3,d0
	bsr	Ed_GotoY
	bsr	Ed_NewBufAff
	move.w	(a2),d0
	beq.s	.PaD
	lea	2(a2),a0
	bsr	R_InsChar
	bsr	Ed_EALiCu
	bsr	Ed_TokCur
.PaD	move.w	d7,d0
	bsr	Ed_GotoX
; Termine!
.Ok	moveq	#-1,d0
.Vide	subq.b	#1,Ed_FUndo(a5)
	movem.l	(sp)+,d2-d7/a2
	tst.l	d0
	rts

;
; Delete le bloc du texte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlockDeleteA0
	movem.l	d2-d7/a2-a3,-(sp)
	addq.b	#1,Ed_FUndo(a5)
	move.l	(a0),d0
	beq	.Vide
	move.l	d0,a2
	movem.w	(a2)+,d4-d6		Positions
	move.l	(a2)+,d7		Flags
	move.w	d6,d0			Locate en ligne 1
	bsr	Ed_GotoX
	move.w	d4,d0
	bsr	Ed_GotoY
	move.l	a2,a3			Milieu>>> A3
	add.w	(a3)+,a3
	move.l	a3,d0
	Pair	d0
	move.l	d0,a3
	btst	#31,d7			Une procedure en premier?
	bne	.Proc1
	btst	#30,d7			Juste le milieu?
	bne.s	.NoMi
; Enleve le milieu s'il faut
	tst.w	(a3)
	beq.s	.NoMi
	move.l	2(a3),d0		Enleve le programme
	move.w	d4,d1
	addq.w	#1,d1
	bsr	Ed_DelChunk
	move.w	d4,d1			Change les marques
	addq.w	#1,d1
	move.w	(a3),d1
	neg.w	d1
	bsr	Ed_MarksChange
	JJsr	L_Prg_CptLines		Compte
	bsr	Ed_NewBufAff		Afiche
; Enleve la premiere ligne
.NoMi	move.w	(a2),d0
	beq.s	.Pa1
	bsr	R_DelChar
	bsr	Ed_EALiCu
.Pa1	btst	#30,d7			Pas de tokenisation si juste milieu
	bne.s	.Ok
	bsr	Ed_TokCur
; Derniere ligne
.Der	move.l	2(a3),d0		Pointe la derniere ligne
	lea	6(a3,d0.l),a3
	moveq	#0,d0			Locate debut ligne suivante
	bsr	Ed_GotoX
	move.w	d4,d0
	addq.w	#1,d0
	bsr	Ed_GotoY
	move.w	(a3),d0
	beq.s	.Join
	bsr	R_DelChar		Enleve les caracteres
	bsr	Ed_TokCur
.Join	bsr	Ed_Join			Join la ligne du dessus
	bsr	Ed_TokCur
	bra.s	.Ok
; Une procedure sur la premiere ligne
.Proc1	move.l	2(a3),d0		Enleve le programme
	move.w	d4,d1
	bsr	Ed_DelChunk
	move.w	d4,d0			Change les marques
	move.w	(a3),d1
	neg.w	d1
	bsr	Ed_MarksChange
	JJsr	L_Prg_CptLines
	bsr	Ed_NewBufAff
	move.l	2(a3),d0
	lea	6(a3,d0.l),a3
	moveq	#0,d0			Locate debut ligne
	bsr	Ed_GotoX
	move.w	(a3),d0
	beq.s	.Ok
	bsr	R_DelChar		Enleve les caracteres
	bsr	Ed_TokCur
; Termine!
.Ok	moveq	#-1,d0
.Vide	subq.b	#1,Ed_FUndo(a5)
	movem.l	(sp)+,d2-d7/a2-a3
	tst.l	d0
	rts


;
; Fabrique le bloc. (a0) adresse ou poker la structure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0	adresse du pointeur
;	D4-D7	limites du bloc
Ed_BlockCopyA0
	movem.l	a2-a3/d2-d7,-(sp)
	move.l	a0,-(sp)
; Calcule la taille
; ~~~~~~~~~~~~~~~~~
	move.l	Ed_BufT(a5),a3
	lea	256(a3),a3
	move.l	a3,d3
	neg.l	d3
	and.l	#$0000FFFF,d7		Libere les flags
; Copie la premiere ligne
	move.w	Edt_YPos(a4),d0		La ligne courante?
	add.w	Edt_YCu(a4),d0
	cmp.w	d0,d4
	bne.s	.NoCur
	bsr	Ed_LCourant		Ligne sous le curseur
	bne	.NoCur
	tst.w	d0
	beq	.NoBloc
	lea	-2(a0),a1
	bra.s	.Copy1
.NoCur	move.w	d4,d0			Trouve la ligne
	bsr	Ed_FindL
	beq	.NoBloc
	JJsrR	L_Tk_EditL,a1		Peut on couper la ligne?
	beq.s	.Proc1
	move.l	Ed_BufT(a5),a1		Detokenise la ligne...
	moveq	#0,d0
	bsr	Detok
	move.l	Ed_BufT(a5),a1
.Copy1	move.w	(a1)+,d0
	cmp.w	d0,d6
	bcs.s	.Sk1
	move.w	d0,d6
.Sk1	cmp.w	d4,d5
	beq	.Seul
	sub.w	d6,d0
	move.b	d0,(a3)+
	beq.s	.Der
	subq.w	#1,d0
	add.w	d6,a1
.Cp1	move.b	(a1)+,(a3)+
	dbra	d0,.Cp1
	bra.s	.Der
; Une procedure sur la premiere ligne
.Proc1	tst.w	d6			X=0?
	bne	Ed_NotEdit
	cmp.w	d4,d5			Au moins une ligne?
	ble	Ed_NotEdit
	bset	#31,d7			X1= Flag
	clr.b	(a3)+			1ere ligne vide
; Copie la derniere ligne
.Der	clr.b	(a3)+
	move.w	Edt_YPos(a4),d0		La ligne courante?
	add.w	Edt_YCu(a4),d0
	cmp.w	d0,d5
	bne.s	.NoCur2
	bsr	Ed_LCourant		Ligne sous le curseur
	bne.s	.NoCur2
	tst.w	d0
	beq.s	.Nc2
	lea	-2(a0),a1
	bra.s	.Copy2
.NoCur2	move.w	d5,d0
	bsr	Ed_FindL
	beq	.Nc2
	bsr	Ed_EditL
	beq.s	.Proc2
	move.l	Ed_BufT(a5),a1
	moveq	#0,d0
	bsr	Detok
	move.l	Ed_BufT(a5),a1
.Copy2	move.w	(a1)+,d0
	cmp.w	d0,d7
	bcs.s	.Sk2
	move.w	d0,d7
.Sk2	move.w	d7,d0
	move.b	d0,-1(a3)
	beq.s	.Nc2
	subq.w	#1,d0
.Cp2	move.b	(a1)+,(a3)+
	dbra	d0,.Cp2
.Nc2	bra.s	.Mil
; Une procedure sur la derniere ligne: le curseur doit etre � gauche
.Proc2	tst.w	d7			Curseur � gauche donc
	bne	Ed_NotEdit		rien � copier!
; Evalue la taille du milieu
.Mil	move.w	d4,d2
	btst	#31,d7			Si closed procedure
	bne.s	.Ccp
	addq.w	#1,d2
.Ccp	cmp.w	d2,d5
	beq.s	.NoM
	move.w	d2,d0
	bsr	Ed_FindL
	beq.s	.NoM
.Ct3	bsr	Ed_SizeL
	add.l	d0,d3
	bsr	Ed_NextL
	beq.s	.NoM
	addq.w	#1,d2
	cmp.w	d5,d2
	bcs.s	.Ct3
.NoM	addq.l	#4+2,d3
	bra.s	.Reserve
; Une seule ligne: copie le bout
.Seul	cmp.w	d0,d7
	bcs.s	.SkS
	move.w	d0,d7
.SkS	move.w	d7,d0
	sub.w	d6,d0
	beq	.NoBloc
	move.b	d0,(a3)+
	beq.s	.Sl2
	subq.w	#1,d0
	add.w	d6,a1
.Sl1	move.b	(a1)+,(a3)+
	dbra	d0,.Sl1
.Sl2	bset	#30,d7
; Reserve la m�moire
; ~~~~~~~~~~~~~~~~~~
.Reserve
	add.l	a3,d3
	tst.l	d3
	beq	.NoBloc
	move.l	(sp),a0
	bsr	Ed_BlockFreeA0
	add.l	#24,d3
	move.l	d3,d0
	move.l	(sp),a0
	bsr	Ed_MemReserve
	beq	.OOm
	move.l	a0,a1
	movem.w	d4-d6,(a1)	Stocke les positions
	lea	6(a1),a1
	move.l	d7,(a1)+	Flags
; Copie la premiere ligne
; ~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Ed_BufT(a5),a2
	lea	256(a2),a2
	moveq	#0,d0
	move.b	(a2)+,d0
	move.w	d0,(a1)+
	beq.s	.Pc1
	subq.w	#1,d0
.Co1	move.b	(a2)+,(a1)+
	dbra	d0,.Co1
	move.l	a1,d0
	Pair	d0
	move.l	d0,a1
.Pc1	btst	#30,d7			Seul?
	bne.s	.Ok
; Copie le milieu
; ~~~~~~~~~~~~~~~
.CMil	move.l	a1,a3
	clr.w	(a1)+			Nombre de lignes
	clr.l	(a1)+			Taille
	clr.w	(a1)
	move.w	d4,d3
	btst	#31,d7			Si closed
	bne.s	.Cpr
	addq.w	#1,d3
.Cpr	cmp.w	d5,d3
	bcc.s	.Sc2
	move.w	d3,d0
	bsr	Ed_FindL
	beq.s	.Sc2
.Lo2	addq.w	#1,(a3)			Une ligne de plus
	bsr	Ed_SizeL
	add.l	d0,2(a3)		Taille en plus
	lsr.l	#1,d0
.Mc2	move.w	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.Mc2
	bsr	Ed_NextL
	beq.s	.Sc2
	addq.w	#1,d3
	cmp.w	d5,d3
	bcs.s	.Lo2
.Sc2
; Copie la derniere ligne
; ~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	move.b	(a2)+,d0
	move.w	d0,(a1)+
	beq.s	.Ok
	subq.w	#1,d0
.Co2	move.b	(a2)+,(a1)+
	dbra	d0,.Co2
	bra.s	.Ok
; Finito!
; ~~~~~~~
.OOm	moveq	#-1,d0
	bra.s	.End
.NoBloc	moveq	#1,d0
	bra.s	.End
.Ok	moveq	#0,d0
.End	move.l	(sp)+,a0
	movem.l	(sp)+,d2-d7/a2-a3
	rts

; ________________________________________
;
;	SAVE BLOCK
; ________________________________________
;
Ed_BlocSave
	bsr	Ed_TokCur
	tst.l	Ed_Block(a5)
	beq	Ed_BlocWhat
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#90,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	bsr	Ed_SaveOver
; Message saving block
; ~~~~~~~~~~~~~~~~~~~~
	move.w	#154,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
; Ouvre le fichier
; ~~~~~~~~~~~~~~~~
	move.l	#1006,d2
	bsr	Ed_Open
	beq	Ed_DError
; Sauve l'entete AMOS BASIC V1.00 illegal
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	EnHead(pc),a0
	move.b	#"v",11(a0)
	move.l	a0,d2
	moveq	#16,d3
	bsr	Ed_Write
	bne	Ed_DError
; Place pour la taille
; ~~~~~~~~~~~~~~~~~~~~
	move.l	Ed_BufT(a5),d2
	moveq	#4,d3
	bsr	Ed_Write
	bne	Ed_DError
; Premiere ligne du bloc
; ~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d4
	move.l	Ed_Block(a5),a2
	movem.w	(a2)+,d4-d6
	move.l	(a2)+,d7
	moveq	#0,d4
	move.w	(a2),d3
	beq.s	.Pa1
	lea	2(a2),a0		Tokenise la premiere ligne
	move.l	Ed_BufT(a5),a1
	bsr	Tokenise
	move.l	d1,d3
	beq.s	.Pa1
	add.l	d3,d4			Plus taille
	move.l	Ed_BufT(a5),d2		Sauve
	bsr	Ed_Write
	bne	Ed_DError
.Pa1	add.w	(a2)+,a2
	move.l	a2,d0
	Pair	d0
	move.l	d0,a2
; Milieu du bloc!
; ~~~~~~~~~~~~~~~
	move.l	2(a2),d3		Taille du milieu
	beq.s	.NoMi
	add.l	d3,d4			Plus Taille
	lea	6(a2),a0		Va ecrire le chunk
	move.l	a0,d2
	bsr	Ed_Write
	bne	Ed_DError
.NoMi	move.l	2(a2),d0
	lea	6(a2,d0.l),a2
; Fin du bloc
; ~~~~~~~~~~~
	move.w	(a2)+,d3
	beq.s	.PaF
	move.l	a2,a0			Tokenise la fin
	move.l	Ed_BufT(a5),a1
	bsr	Tokenise
	move.l	d1,d3			Quelquechose � sauver?
	beq.s	.PaF
	add.l	d3,d4			Plus taille
	move.l	Ed_BufT(a5),d2
	bsr	Ed_Write		Sauve
	bne	Ed_DError
.PaF
; Banques vides
; ~~~~~~~~~~~~~
.Seul	JJsr	L_Bnk.SaveVide
; Va changer la taille du fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#16,d2			Locate au debut
	moveq	#-1,d3
	bsr	Ed_Seek
	move.l	Ed_BufT(a5),a0		Poke et sauve la taille
	move.l	d4,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	Ed_Write
	bne	Ed_DError
; Finito!
; ~~~~~~~
	bsr	Ed_Close
	bsr	Ed_AverFin
	rts

; ___________________________________________________
;
;	SAUVEGARDE BLOC EN ASCII
; ___________________________________________________
;
Ed_BlocSaveAscii
	bsr	Ed_TokCur
	tst.l	Ed_Block(a5)
	beq	Ed_BlocWhat
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#82,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	bsr	Ed_SaveOver
; Ouvre le fichier MODE_NEW
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1006,d2
	bsr	Ed_Open
	beq	Ed_DError
	move.w	#156,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
; Detokenise tout le bloc
; ~~~~~~~~~~~~~~~~~~~~~~~
	bsr	BlToA0
	beq.s	.Vide
.Loop	move.b	#10,(a0)
	addq.l	#1,d3
	bsr	Ed_Write
	bne	Ed_DError
	bsr	BlToA1
	bne.s	.Loop
; Ca y est!
; ~~~~~~~~~
.Vide	bsr	Ed_Close
	bsr	Ed_AverFin
	rts

;
; PRINT PROGRAM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PrgPrint
	bsr	Ed_TokCur
; Boite de dialogue
; ~~~~~~~~~~~~~~~~~
	moveq	#EdD_PProg,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
; Avertissement
; ~~~~~~~~~~~~~
	move.w	#217,d0
	bsr	Ed_AverMess
	bsr	Ed_PRTOpen
; Boucle d'impression
; ~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	bsr	Ed_FindL
	beq.s	.Exit
.Loop	bclr	#BitControl-8,T_Actualise(a5)
	bne.s	.Exit
	move.l	Ed_BufT(a5),a1
	moveq	#0,d0
	bsr	Detok
	move.l	Ed_BufT(a5),a0
	move.w	(a0)+,d0
	lea	0(a0,d0.w),a1
	move.b	#13,(a1)+
	move.b	#10,(a1)+
	clr.b	(a1)
	bsr	Ed_PRTPrint
.In	bsr	Ed_NextL
	bne.s	.Loop
; Ca y est!
; ~~~~~~~~~
.Exit	bsr	Ed_Close
	bsr	Ed_AverFin
	SyCall	ClearKey
	rts
;
; PRINT BLOC
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocPrint
	bsr	Ed_TokCur
	tst.l	Ed_Block(a5)
	beq	Ed_BlocWhat
; Boite de dialogue
; ~~~~~~~~~~~~~~~~~
	moveq	#EdD_PBloc,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
; Avertissement
; ~~~~~~~~~~~~~
	move.w	#157,d0
	bsr	Ed_AverMess
	bsr	Ed_PRTOpen
; Boucle d'impression
; ~~~~~~~~~~~~~~~~~~~
	bsr	BlToA0
	beq.s	.Exit
.Loop	bclr	#BitControl-8,T_Actualise(a5)
	bne.s	.Exit
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	clr.b	(a0)
	move.l	d2,a0
	bsr	Ed_PRTPrint
.In	bsr	BlToA1
	bne.s	.Loop
; Ca y est!
; ~~~~~~~~~
.Exit	bsr	Ed_Close
	bsr	Ed_AverFin
	SyCall	ClearKey
	rts

; Routines de transformation du bloc en ASCII
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BlToA0	move.l	Ed_Block(a5),a2
	movem.w	(a2)+,d4-d6
	move.l	(a2)+,d7
	moveq	#1,d4
; Ramene la ligne en D2/D3
; ~~~~~~~~~~~~~~~~~~~~~~~~
BlToA1	moveq	#0,d3
	tst.w	d4
	beq.s	.Rien
	cmp.w	#2,d4
	bge.s	.Deuse
; Premiere / Derniere ligne
	move.w	(a2),d0
	beq.s	.1Vide
	lea	2(a2),a1
	move.l	Ed_BufT(a5),a0
	move.l	a0,d2
	subq.w	#1,d0
	bmi.s	.Cp
.Co	move.b	(a1)+,(a0)+
	dbra	d0,.Co
.Cp	move.l	a0,d3
	sub.l	d2,d3
	add.w	(a2)+,a2
	move.l	a2,d0
	Pair	d0
	move.l	d0,a2
.Rien	move.w	d4,d0
	addq.w	#1,d4
	tst.w	d0
	rts
.1Vide	addq.w	#1,d4
	addq.l	#2,a2			Saute la longueur
	bra.s	BlToA1
; Milieu du bloc
.Deuse	cmp.w	#2,d4			Le premier?
	bne.s	.Corps
	move.w	(a2),d5			Oui, prend la taille
	addq.l	#6,a2			Pointe la 1ere ligne
.Corps	subq.w	#1,d5			Encore a faire?
	bmi.s	.2Vide
	move.l	a2,a0			Detokenise
	move.l	Ed_BufT(a5),a1
	moveq	#0,d0
	bsr	Detok
	move.l	a2,a0			Pointe la ligne suivante
	JJsrP	L_Tk_FindN,a2
	move.l	a0,a2
	move.l	Ed_BufT(a5),a0		Retourne la ligne
	moveq	#0,d3
	move.w	(a0)+,d3
	move.l	a0,d2
	add.w	d3,a0
	bra.s	.Rien
.2Vide	moveq	#-1,d4			Derniere ligne
	bra	BlToA1			Recommence

; Retourne les limites du bloc en d0/d1/d2/d3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BlocLimits
	move.w	Edt_YBloc(a4),d1
	bmi	Ed_BlocWhat
	move.w	Edt_YPos(a4),d3
	add.w	Edt_YCu(a4),d3
	move.w	Edt_XBloc(a4),d0
	move.w	Edt_XCu(a4),d2
	cmp.w	d1,d3
	bhi.s	.PaSw
	bne.s	.Sw
	cmp.w	d0,d2
	bcc.s	.PaSw
.Sw	exg	d0,d2
	exg	d1,d3
.PaSw	rts

;____________________________________________________________________
;
;						MACROS
;____________________________________________________________________
;
; Chargement des macros par defaut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_LoadDefault
	moveq	#46,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	bsr	EdMa_LoadIt
	clr.b	EdMa_Changed(a5)
	rts
; Chargement des macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_LoadAs
	moveq	#55,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	bsr	EdMa_LoadIt
	move.b	#1,EdMa_Changed(a5)
	rts

; Charge le fichier macros
; ~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_LoadIt
	tst.l	EdMa_List(a5)		Erase old macros?
	beq.s	.Skip
	moveq	#EdD_MacroEra,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
; Averti et charge
.Skip	moveq	#62,d0
	bsr	Ed_AverMess
	bsr	EdMa_Load
	bsr	Ed_AverFin
	beq	.Ok
	bmi	Ed_OMm
	subq.w	#1,d0
	beq	Ed_DError
; Pas un fichier MACRO
	moveq	#EdD_MacroPas,d0
	bsr	Ed_Dialogue
	bsr	Ed_Loca
; Fini
.Ok	rts

; Sauvegarde des macros par default
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_SaveDefault
EdMa_SaveDef
	moveq	#46,d0
	bsr	Ed_GetSysteme
	JJsrR	L_Sys_AddPath,a1
	bsr	EdMa_SaveIt
	rts
; Sauvegarde des macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_SaveAs
	moveq	#51,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
	bsr	Ed_SaveOver
	bsr	EdMa_SaveIt
	rts
; Averti et sauve
EdMa_SaveIt
	moveq	#61,d0
	bsr	Ed_AverMess
	bsr	EdMa_Save
	bsr	Ed_AverFin
	bne	Ed_DError
	clr.b	EdMa_Changed(a5)
	rts

; Chargement du fichier de macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Out	D0=0	Pas d'erreur
;		D0=-1	Erreur disque
;		D0=1	Pas macros
EdMa_Load
; Effacer les precedentes
	bsr	EdMa_End
	clr.b	EdMa_Change(a5)
; Ouvre le fichier
	move.l	#1005,d2
	bsr	Ed_Open
	beq	.Err
; Charge l'entete AMOSPro MACROS
	move.l	Buffer(a5),a2
	move.l	a2,d2
	moveq	#4,d3
	bsr	Ed_Read
	bne	.Err
	cmp.l	#EdMa_Head,(a2)
	bne.s	.Noma
; Charge les macros une par une
.Loop	move.l	a2,d2
	moveq	#8,d3
	bsr	Ed_Read
	bne.s	.Err
	move.l	4(a2),d3
	beq.s	.End
	move.l	d3,d0
	lea	EdMa_List(a5),a0
	bsr	Ed_ListeNew
	beq.s	.Out
	addq.l	#8,a1
	move.l	a1,d2
	bsr	Ed_Read
	bne.s	.Err
	bra.s	.Loop
; Ferme le fichier
.End	bsr	Ed_Close
	moveq	#0,d0
	rts
; Erreur de chargement
.Err	bsr	Ed_Close
	moveq	#1,d0
	rts
; Pas un fichier macro
.Noma	bsr	Ed_Close
	moveq	#2,d0
	rts
; Out of memory
.Out	bsr	Ed_Close
	moveq	#-1,d0
	rts

; Sauvegarde du fichier de macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	OUT	D0=0 	Pas d'erreur
;		D0=-1	Erreur disque
EdMa_Save
	move.l	#1006,d2
	bsr	Ed_Open
	beq	Ed_DError
; Sauve l'entete AMOSPro MACROS
	move.l	Buffer(a5),a0
	move.l	#EdMa_Head,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	Ed_Write
	bne.s	.Err
; Sauve les macros une par une
	move.l	EdMa_List(a5),d2
	beq.s	.Fin
.Loop	move.l	d2,a2
	move.l	4(a2),d3
	addq.l	#8,d3
	bsr	Ed_Write
	bne.s	.Err
	move.l	(a2),d2
	bne.s	.Loop
; Fin : 0/0
.Fin	move.l	Buffer(a5),d2
	move.l	d2,a0
	clr.l	(a0)+
	clr.l	(a0)+
	moveq	#8,d3
	bsr	Ed_Write
	bne.s	.Err
; Ferme le fichier
	bsr	Ed_Close
	moveq	#0,d0
	rts
; Erreur disque
.Err	bsr	Ed_Close
	moveq	#1,d0
	rts

; Effacement d'une macro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_Del
	bsr	Ed_TokCur
	tst.l	EdMa_List(a5)
	beq	EdMa_No
	moveq	#EdD_MacroD,d0
	bsr	Ed_Dialogue
	tst.w	d0
	bne	Ed_NotDone
	move.l	Ed_ADialogues(a5),a0
	move.l	Dia_LastKey(a0),d2
	beq	Ed_NotDone
	move.l	d2,d1
	bsr	EdMa_Adr
	beq.s	.NotA
	bsr	Ed_ListeDel
; Marque pour QUIT
	move.b	#1,EdMa_Change(a5)
	bra	Ed_Loca
; Key not assigned to a macro
.NotA	moveq	#EdD_MacroNA,d0
	bsr	Ed_Dialogue
	bra	Ed_Loca
; Effacement de toutes les macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_DelAll
	bsr	Ed_TokCur
	tst.l	EdMa_List(a5)
	beq	EdMa_No
	moveq	#EdD_MacroAll,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	bsr	EdMa_End
; Marque pour QUIT
	move.b	#1,EdMa_Change(a5)
	bra	Ed_Loca
; D�marre l'enregistrement d'une nouvelle macro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_New
	bsr	Ed_TokCur
; Boite de dialogue 1
	moveq	#EdD_Macro1,d0
	bsr	Ed_Dialogue
	tst.w	d0
	bne	Ed_NotDone
	move.l	Ed_ADialogues(a5),a0
	move.l	Dia_LastKey(a0),d2
	beq	Ed_NotDone
	move.l	d2,d1
	bsr	EdMa_Adr
	beq.s	.Skip
; Key already assigned to a macro
	move.l	a1,-(sp)
	moveq	#EdD_Macro2,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	move.l	(sp)+,a1
	lea	EdMa_List(a5),a0
	bsr	Ed_ListeDel
; R�serve le buffer temporaire
.Skip	move.l	#1024,d0
	move.l	d0,d1
	lea	EdMa_List(a5),a0
	bsr	Ed_ListeNew
	move.w	#1,EdMa_Tape(a5)
	move.l	d2,8(a1)
	move.l	#-1,8-4(a1,d1.w)
; Provoque l'affichage de la ligne infos
	bsr	Ed_AverFin
	bsr	Ed_Loca
	rts

; Termine l'enregistrement de la macro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_Stop
; Plus de souris
	JJsr	L_Dia_NoMKey
	move.b	#1,EdMa_Change(a5)
; Reserve le buffer d�finitif
	lea	EdMa_List(a5),a0
	move.l	(a0),a2
	move.l	a2,d3
	lea	8(a2),a2
	move.w	EdMa_Tape(a5),d2
	clr.w	EdMa_Tape(a5)
	subq.w	#1,d2
	beq	.Vide
	moveq	#8,d0
	add.w	d2,d0
	bsr	Ed_ListeNew
; Copie le buffer
	lea	8(a1),a1
	move.l	(a2)+,(a1)+
	subq.w	#1,d2
.Loop	move.b	(a2)+,(a1)+
	dbra	d2,.Loop
	move.b	#-1,(a1)+
; Enleve le buffer temporaire
	move.l	d3,a1
	bsr	Ed_ListeDel
; Avertissement
	moveq	#45,d0
	bra	Ed_Al100
; Pas de touches!
.Vide	move.l	d3,a1
	bsr	Ed_ListeDel
	bra	Ed_NotDone

; Trouve une macro de code D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_Adr
	lea	EdMa_List(a5),a0
	move.l	(a0),d0
	beq.s	.NFound
.Loop	move.l	d0,a1
	cmp.l	8(a1),d1
	beq.s	.Found
.In	move.l	(a1),d0
	bne.s	.Loop
.NFound	rts
; Trouve
.Found	move.l	a1,d0
	rts
; Efface l'arbre des macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdMa_End
	lea	EdMa_List(a5),a0
	bra	Ed_ListeDelAll
; Pas une macro
; ~~~~~~~~~~~~~
EdMa_No
	moveq	#EdD_MacroNo,d0
	bsr	Ed_Dialogue
	bra	Ed_Loca

;_____________________________________________________________________________
;
;						Search / Replace / Goto
;_____________________________________________________________________________
;

; Goto line number
; ~~~~~~~~~~~~~~~~
Ed_GotoL
	bsr	Ed_TokCur
	tst.b	Ed_Zappeuse(a5)
	beq.s	.PaZap
	move.l	Ed_ZapParam(a5),d0
	bra.s	.Zap
.PaZap	moveq	#EdD_GotoL,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	moveq	#1,d0
	moveq	#3,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,d0
.Zap	subq.l	#1,d0
	bmi	Ed_NotDone
	cmp.w	Prg_NLigne(a6),d0
	bcs.s	.Skip
	move.w	Prg_NLigne(a6),d0
.Skip	bsr	Ed_AutoMarks
	bsr	Ed_GotoY
	rts


; Appel le dialogue pour SEARCH, d0DIALOG A APPELER
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DiaS	move.w	d0,d2
	lea	Ed_SchBuf(a5),a0		Chaine d'origine
	bsr	Ed_DChaine
	move.l	Ed_VDialogues(a5),a2
	move.l	a1,(a2)+
	move.l	#32,(a2)+			Taille de la ligne
	move.w	Ed_SchMode(a5),d0		Met les flags
	and.w	#%0001,d0			Garde LOWUP / Bloc limits
	moveq	#4,d1
	move.l	a2,a0
	JJsrP	L_Dia_SetVFlags,a2
; Appelle les dialogues
	move.w	d2,d0
	bsr	Ed_Dialogue
	move.w	d0,-(sp)
; Reprend les variables
	move.l	Ed_VDialogues(a5),a0
	lea	2*4(a0),a0
	moveq	#4,d1
	JJsrP	L_Dia_GetVFlags,a2
	move.w	d0,Ed_SchMode(a5)
; Reprend la chaine
	moveq	#1,d0
	moveq	#3,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,a0
	lea	Ed_SchBuf(a5),a1
.Loop	move.b	(a0)+,(a1)+
	bne.s	.Loop
; Ramene le retour
	move.w	(sp)+,d0
	rts

; SEARCH
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Search
	bsr	Ed_TokCur
	moveq	#EdD_Search,d0
	bsr	Ed_DiaS
	cmp.w	#1,d0
	bne	Ed_NotDone
	move.w	Ed_SchMode(a5),d5	Garde Low/UP, et direction!
	and.w	#%0011,d5
	bra	Ed_SR
; SEARCH PREVIOUS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SearchPrev
	bsr	Ed_TokCur
	tst.b	Ed_SchBuf(a5)			Quelque chose � trouver?
	beq.s	Ed_Search
	move.w	Ed_SchMode(a5),d5
	and.w	#%0001,d5			Garde LowUp
	bset	#1,d5				En arriere!
	bra.s	Ed_SR
; SEARCH NEXT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SearchNext
	bsr	Ed_TokCur
	tst.b	Ed_SchBuf(a5)			Quelque chose � trouver?
	beq.s	Ed_Search
	move.w	Ed_SchMode(a5),d5
	and.w	#%0001,d5			Garde LowUp, en avant!
; Fait la recherche / Remplacement, D5flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SR
	bsr	Ed_SRCompte
; Fait le remplacement
	move.w	Edt_YPos(a4),d7
	add.w	Edt_YCu(a4),d7
	move.w	Edt_XCu(a4),d6
	move.w	#32000,d4			Limites en bas
	move.w	#32000,d3
; Va chercher
	moveq	#36,d0
	bsr	Ed_AverMess
	bsr	Ed_SchBoth
	beq	Ed_NoFound
; Positionne le curseur
	bsr	Ed_AutoMarks
	movem.w	d2-d7,-(sp)
	move.w	d7,d0
	bsr	Ed_GotoY
	movem.w	(sp),d2-d7
	move.w	d6,d0
	bsr	Ed_GotoX
	movem.w	(sp)+,d2-d7
; Trouve, faire une remplacement?
	btst	#15,d5
	beq.s	.NoRep
	bsr	Ed_LCourant
	move.w	d6,d0
	bsr	RepBuffer
	bne	Ed_LToLong
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_TokCur
	move.w	d6,d0
	bsr	Ed_GotoX
.NoRep
; Fini!
	bsr	Ed_AverFin
	bsr	Ed_Loca
	rts


; Compte les buffers SEARCH/REPLACE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SRCompte
	lea	Ed_SchBuf(a5),a0
	moveq	#-1,d0
.LoopS	addq.w	#1,d0
	tst.b	(a0)+
	bne.s	.LoopS
	move.b	d0,Ed_SchLong(a5)
	lea	Ed_RepBuf(a5),a0
	moveq	#-1,d0
.LoopR	addq.w	#1,d0
	tst.b	(a0)+
	bne.s	.LoopR
	move.b	d0,Ed_RepLong(a5)
	rts

; Routines de recherche en AVANT / ARRIERE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SchBoth
	btst	#1,d5
	bne	Ed_SchBack
;
; Recherche en avant
; ~~~~~~~~~~~~~~~~~~
;	D7=	Y
;	D6=	X
;	D5=	Flags
;	D4=	YMax
;	D3=	XMax
Ed_SchFront
	addq.w	#1,d6
.Fst	move.w	d7,d0
	bsr	Ed_FindL
	beq	.SrchN
; Sort des limites?
.SrchL	cmp.w	d4,d7
	bgt.s	.SrchN
	bne.s	.Srch1
	cmp.w	d3,d6
	bgt.s	.SrchN
; Detokenise, et recherche
.Srch1	moveq	#0,d0
	move.l	Ed_BufT(a5),a1
	bsr	Detok
	move.l	Ed_BufT(a5),a0
	move.w	(a0),d0
	clr.b	2(a0,d0.w)
	cmp.w	d0,d6
	bcc.s	.Srch2
	lea	2(a0,d6.w),a0
	lea	Ed_SchBuf(a5),a1
	bsr	SchBuffer
	bpl.s	.Srch3
; Ligne suivante
.Srch2	moveq	#0,d6
	bclr	#BitControl-8,T_Actualise(a5)
	bne.s	.SrchN
	bsr	Ed_NextL
	beq.s	.SrchN
	addq.w	#1,d7
	bra.s	.SrchL
; Vraiment trouve?
.Srch3	add.w	d0,d6
	cmp.w	d4,d7
	bne.s	.SrchT
	cmp.w	d3,d6
	bls.s	.SrchT
; Pas trouve, FAUX
.SrchN	moveq	#0,d0
	rts
; Trouve, VRAI
.SrchT	moveq	#-1,d0
	rts
; Recherche en arriere
; ~~~~~~~~~~~~~~~~~~~~
;	D7=	Y
;	D6=	X
;	D5=	Flags
;	D4=	YMax
;	D3=	XMax
Ed_SchBack
	movem.w	d6-d7,-(sp)
	move.w	d7,d4		Jusqu'� la position actuelle -1
	move.w	d6,d3
	subq.w	#1,d3
	bpl.s	.Mm
	move.w	#255,d3
	subq.w	#1,d4
	bmi.s	.NFound
.Mm	clr.w	d6		A partir du d�but
	clr.w	d7
	move.l	#-1,-(sp)
.Loop	bsr	Ed_SchFront	Tant que l'on trouve
	beq.s	.PaT
	move.w	d6,2(sp)
	move.w	d7,(sp)
	addq.w	#1,d6
	bra.s	.Loop
.PaT	move.w	(sp)+,d7
	move.w	(sp)+,d6
	bmi.s	.NFound
; Trouve! Retourne VRAI
	addq.l	#4,sp
	moveq	#-1,d0
	rts
; Pas trouve: FAUX
.NFound	movem.w	(sp)+,d6-d7
	moveq	#0,d0
	rts
;
; Routine SEARCH
; ~~~~~~~~~~~~~~
;	A1=	Chaine � chercher
;	A0=	Chaine dans laquelle cherche
;	D5-> 	Flags
;	D6->	X Debut
SchBuffer
	movem.l	a1/d1-d4,-(sp)
	move.l	a0,d4
	move.b	(a1)+,d0
	bsr.s	.MajS
	move.b	d0,d1
	move.l	a1,d3
.RSe1	move.b	(a0)+,d0		* Cherche la 1ere lettre
	beq.s	.RSeN
	bsr.s	.MajS
	cmp.b	d0,d1
	bne.s	.RSe1
	move.l	a0,d2
	swap	d1
.RSe2	move.b	(a1)+,d0
	beq.s	.RSeT
	bsr.s	.MajS
	move.b	d0,d1
	move.b	(a0)+,d0
	bsr.s	.MajS
	cmp.b	d0,d1
	beq.s	.RSe2
	move.l	d2,a0
	move.l	d3,a1
	swap	d1
	bra.s	.RSe1
.RSeN	movem.l	(sp)+,a1/d1-d4
	moveq	#-1,d0
	rts
.RSeT	move.l	d2,d0
	sub.l	d4,d0
	subq.l	#1,d0
	movem.l	(sp)+,a1/d1-d4
	rts
.MajS	btst	#0,d5
	beq.s	.Skip
	cmp.b	#"a",d0
	bcs.s	.Skip
	cmp.b	#"z",d0
	bhi.s	.Skip
	sub.b	#$20,d0
.Skip	rts


; REPLACE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Replace
	bsr	Ed_TokCur
	lea	Ed_RepBuf(a5),a0		Buffer d'edition
	bsr	Ed_DChaine
	move.l	Ed_VDialogues(a5),a2
	move.l	a1,8*4(a2)
	moveq	#EdD_Replace,d0
	bsr	Ed_DiaS
	move.w	d0,-(sp)
; Reprend la chaine Replace
	moveq	#1,d0
	moveq	#4,d1
	moveq	#1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,a0
	lea	Ed_RepBuf(a5),a1
.Bli	move.b	(a0)+,(a1)+
	bne.s	.Bli
; Ou se brancher?
	cmp.w	#1,(sp)+
	bne	Ed_Loop
	move.w	Ed_SchMode(a5),d5		Mode TURBO?
	move.w	d5,d0
	and.w	#%1100,d0
	bne.s	.Turbo
; Mode normal, quelle dir?
; ~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#1,d5
	beq	Ed_ReplaceNext
	bne	Ed_ReplacePrev
; En mode turbo
; ~~~~~~~~~~~~~
.Turbo
; Boite de dialogue, pour confirmer...
	move.l	Ed_VDialogues(a5),a0
	moveq	#EdD_WBlock,d0
	btst	#2,d5
	bne.s	.Skip
	moveq	#EdD_WText,d0
.Skip	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
; Quelque chose � chercher?
	tst.b	Ed_SchBuf(a5)
	beq.s	Ed_Replace
	tst.b	Ed_RepBuf(a5)
	beq.s	Ed_Replace
	bsr	Ed_SRCompte
; Fait le remplacement
	moveq	#0,d7				Limites en haut
	moveq	#0,d6
	move.w	#32000,d4			Limites en bas
	move.w	#32000,d3
; Dans le bloc?
	btst	#2,d5				Si bloc
	beq.s	.Pab
	bsr	Ed_BlocLimits
	move.w	d1,d7
	move.w	d0,d6
	move.w	d3,d4
	move.w	d2,d3
	beq.s	.Pab
	subq.b	#1,d3
.Pab
; Averti
	moveq	#37,d0
	bsr	Ed_AverMess
; Boucle de recherche / remplacement
	clr.w	-(sp)
.Loop	subq.w	#1,d6			Reste sur la derniere lettre
	bpl.s	.Pos
	moveq	#0,d6
.Pos	bsr	Ed_SchFront
	beq	.Finish
	move.l	Ed_BufT(a5),a0
	addq.l	#2,a0
	move.w	d6,d0
	bsr	RepBuffer
	bne	Ed_LToLong
	move.l	Ed_BufT(a5),a0
	addq.l	#2,a0
	move.l	Buffer(a5),a1
	bsr	Tokenise
	beq.s	.Llong
	move.l	Buffer(a5),a1
	move.w	d7,d1
	moveq	#0,d0
	bsr	Ed_Stocke
	bne	.Outb
	addq.w	#1,(sp)
	bra.s	.Loop
; Fini, et une boite de dialogue!
.Finish	bsr	Ed_NewBuf
	bsr	Ed_AverFin
	move.b	#EtA_BAll,Edt_EtatAff(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	move.w	(sp)+,d0
	beq	Ed_NoFound
	ext.l	d0
	move.l	Ed_VDialogues(a5),a0
	move.l	d0,(a0)
	moveq	#EdD_Changes,d0
	bsr	Ed_Dialogue
	rts
; Line too long
.Llong	bsr	Ed_NewBufAff
	bra	Ed_LToLong
; Out of buffer space
.Outb	bsr	Ed_NewBufAff
	bra	Ed_OofBuf
; REPLACE NEXT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ReplaceNext
	move.w	Ed_SchMode(a5),d5
	and.w	#$0001,d5		Vers le bas,
	or.w	#$8000,d5		Flag remplacer
Ed_RSR	bsr	Ed_TokCur
	tst.b	Ed_SchBuf(a5)
	beq	Ed_Replace
	tst.b	Ed_RepBuf(a5)
	beq	Ed_Replace
	bra	Ed_SR
; REPLACE PREVIOUS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ReplacePrev
	move.w	Ed_SchMode(a5),d5
	and.w	#$0001,d5		Vers le haut
	or.w	#$8002,d5		Flag remplacer
	bra.s	Ed_RSR

;
; Routine REPLACE
; ~~~~~~~~~~~~~~~
;	A0= 	Ligne � changer
; 	D0=	Position du changement
RepBuffer
	movem.l	a0-a2/d2-d3,-(sp)
	lea	0(a0,d0.w),a1		Position du changement
	move.w	-2(a0),d0		Marque la fin de la ligne
	move.l	a0,d1
	clr.b	0(a0,d0.w)
	moveq	#0,d2			Longueur des buffers
	moveq	#0,d3
	move.b	Ed_SchLong(a5),d2
	move.b	Ed_RepLong(a5),d3
	move.l	a1,a2
	move.l	a1,a0
	add.w	d2,a0
.RChg1	move.b	(a0)+,(a1)+
	bne.s	.RChg1
; Place pour le nouveau
	move.l	a1,a0
	add.w	d3,a1
	sub.l	a1,d1
	neg.l	d1
	cmp.w	#252,d1
	bcc	.Tool
.RChg2	move.b	-(a0),-(a1)
	cmp.l	a2,a0
	bcc.s	.RChg2
; Poke le nouveau
	lea	Ed_RepBuf(a5),a0
	move.w	d3,d0
	subq.w	#1,d0
.RChg3	move.b	(a0)+,(a2)+
	dbra	d0,.RChg3
* Change la longueur de la ligne / pointe la fin du mot
	add.w	d3,d6
	subq.w	#1,d1
	movem.l	(sp)+,a0-a2/d2-d3
	move.w	d1,-2(a0)
	moveq	#0,d0
	rts
* Line too long
.Tool	movem.l	(sp)+,a0-a2/d2-d3
	moveq	#-1,d0
	rts

;_____________________________________________________________________________
;
;					Procedures actualisations sliders
;_____________________________________________________________________________
;
Edt_SliderY
	bra	Edt_SlUpdateY
	bra	Edt_SlMinusY
	bra	Edt_SlPlusY
	bra	Edt_SlDrawY
Edt_SlUpdateY
	move.w	Edt_WindTy(a4),Edt_SlV+Sl_Window(a4)
	move.w	Edt_YPos(a4),Edt_SlV+Sl_Position(a4)
	move.w	Prg_NLigne(a6),Edt_SlV+Sl_Global(a4)
	rts
Edt_SlMinusY
Edt_SlPlusY
Edt_SlDrawY
	movem.l	a2-a6/d2-d7,-(sp)
	move.w	Edt_SlV+Sl_Position(a4),Edt_YPos(a4)
	bsr	Ed_NewBuf
	movem.l	(sp)+,a2-a6/d2-d7
	rts

;_____________________________________________________________________________
;
;							Ligne d'�tat
;_____________________________________________________________________________
;

;
; Imprime la ligne
; ~~~~~~~~~~~~~~~~
Ed_EtLine
	move.w	Edt_YPos(a4),d0		Ligne #
	add.w	Edt_YCu(a4),d0
	addq.w	#1,d0
	ext.l	d0
	move.b	Ed_EtXX+3(a5),d1	Position ligne etat
	moveq	#5,d2			Longueur ligne
	bra	Et_Chiffre
;
; Imprime la colonne
; ~~~~~~~~~~~~~~~~~~
Ed_EtCol
	move.w	Edt_XCu(a4),d0
	addq.w	#1,d0
	move.b	Ed_EtXX+4(a5),d1
	moveq	#3,d2
	bra	Et_Chiffre
;
; Imprime la ligne
; ~~~~~~~~~~~~~~~~
Ed_EtFree
	move.l	Prg_StBas(a6),d0	Place libre
	sub.l	Prg_StMini(a6),d0
	move.b	Ed_EtXX+5(a5),d1	Position ligne etat
	moveq	#7,d2			Longueur
	bra	Et_Chiffre
;
; Imprime le numero d'ordre
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EtOrder
	move.w	Edt_Order(a4),d0
	ext.l	d0
	move.b	Ed_EtXX+1(a5),d1
	moveq	#2,d2
	bra	Et_Chiffre


; Impression d'un chiffre dans la ligne d'etat
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1.b=	X
;	D0=	Chiffre
;	D3=	Nombre de decimales
Et_Chiffre
	movem.l	d0/d2,-(sp)
	ext.w	d1
	moveq	#0,d2
	WiCall	Locate
	move.l	Buffer(a5),a0
	move.l	a0,a1
	move.l	#"    ",(a1)
	move.l	(a1)+,(a1)
	move.l	(a1)+,(a1)
	movem.l	(sp)+,d0/d7
	JJsrP	L_LongToDec,a2
	move.l	Buffer(a5),a1
	clr.b	0(a1,d7.w)
	WiCall	Print
	rts
;
; Insert / Overwrite
; ~~~~~~~~~~~~~~~~~~
Ed_EtIns
	move.b	Ed_EtXX+2(a5),d1
	ext.w	d1
	moveq	#0,d2
	WiCall	Locate
	moveq	#5,d0
	tst.b	Ed_Insert(a5)
	beq.s	.Skip
	moveq	#6,d0
.Skip	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	rts
;
; Imprime le NOM DU PROGRAMME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EtNom
	move.b	Ed_EtXX+6(a5),d1
	ext.w	d1
	moveq	#0,d2
	WiCall	Locate
	moveq	#3,d0
	move.l	Edt_LinkPrev(a4),d1
	or.l	Edt_LinkNext(a4),d1
	beq.s	.Skip
	moveq	#4,d0
.Skip	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	move.b	Ed_EtXX+7(a5),d1
	ext.w	d1
	move.w	d1,d7
	moveq	#0,d2
	WiCall	Locate
	move.w	Edt_WindESx(a4),d0
	lsr.w	#3,d0
	sub.w	d7,d0
	subq.w	#2,d0
	move.l	Buffer(a5),a0
.Clr	move.b	#" ",(a0)+
	dbra	d0,.Clr
	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	Ed_NPrgToBuf
	move.l	Buffer(a5),a1
	WiCall	Print
	rts

; Copie le nom du programme dans le buffer A0
; Termine par <32
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NPrgToBuf
	move.l	a0,a1
	lea	Prg_NamePrg(a6),a0
	tst.b	(a0)
	beq.s	.Vide
	move.l	a1,-(sp)
	bsr	Ed_DNom
	move.l	(sp)+,a1
	bra.s	.Suit
.Vide	moveq	#7,d0			VIDE: "New Project"
	bsr	Ed_GetSysteme
.Suit	tst.b	(a0)
	beq.s	.Glo
	move.b	(a0)+,(a1)+
	cmp.b	#32,(a1)
	bcc.s	.Suit
.Glo	move.l	a1,a0
.Fin	cmp.b	#32,(a1)
	bcs.s	.Out
	move.b	#" ",(a1)+
	bra.s	.Fin
.Out	rts
;
; Recall MESSAGE D'ALERTE
; ~~~~~~~~~~~~~~~~~~~~~~~
Ed_RAlert
	moveq	#127,d0
	move.l	Ed_BufT(a5),a0
	lea	256(a0),a0
	cmp.l	#$FFFE0102,(a0)+
	bne.s	.Skip
	move.l	a0,Edt_EtAlert(a4)
	move.w	#150,Edt_EtMess(a4)
	bset	#EtA_Alert,Edt_EtatAff(a4)
	bsr	Ed_EtPrintD0
.Skip	rts

;
; MESSAGE D'ALERTE
; ~~~~~~~~~~~~~~~~
Ed_Alert
	tst.b	Ed_Zappeuse(a5)
	bne.s	Ed_ZapAlert
	moveq	#"G",d0			Va faire du bruit!
	bsr	Ed_SamPlay
; Pas de programme en t�l�commande!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	d0,Edt_EtMess(a4)
	move.l	a0,Edt_EtAlert(a4)
	bset	#EtA_Alert,Edt_EtatAff(a4)
	move.l	Ed_BufT(a5),a1
	lea	256(a1),a1
	move.l	#$FFFE0102,(a1)+
.Alrt	move.b	(a0)+,(a1)+
	bne.s	.Alrt
	bsr	Ed_RazAlert
	bra	Ed_Loop
; Un programme en t�l�commande!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ZapAlert
	move.w	d0,Edt_EtMess(a4)
	move.l	a0,Edt_EtAlert(a4)
	bset	#EtA_Alert,Edt_EtatAff(a4)
	move.l	a0,Ed_ZapMessage(a5)
	move.w	#-1,Ed_ZapError(a5)
	moveq	#0,d0
	JJsr	L_ResTempBuffer
	bsr	Ed_Close
	bra	Ed_Loop
; En Cas d'alerte, un peu de menage...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_RazAlert
	moveq	#0,d0
	JJsr	L_ResTempBuffer
	bsr	Ed_Close
	rts

; MESSAGE D'ALERTE en routine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AlertRts
	tst.b	Ed_Zappeuse(a5)
	bne.s	Ed_ZapAlert
	movem.l	a2-a3/d2-d4,-(sp)
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	move.w	d0,Edt_EtMess(a4)
	move.l	a0,Edt_EtAlert(a4)
	bset	#EtA_Alert,Edt_EtatAff(a4)
	bsr	Ed_EtPrintD0
	movem.l	(sp)+,a2-a3/d2-d4
	rts

; Affiche un avertissement avec nom A0=nom / D0=Mess
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AvName
	movem.l	a0-a1/d0-d1,-(sp)
	move.l	a0,-(sp)
	bsr	Ed_GetMessage
	move.l	Ed_BufT(a5),a1
	bsr	EdCocop
	subq.l	#1,a1
	move.l	(sp)+,a0
	bsr	EdCocop
	move.l	Ed_BufT(a5),a0
	clr.b	72(a0)
	bsr	Ed_Avertir
	movem.l	(sp)+,a0-a1/d0-d1
	rts
; Avertissement message editeur D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AverMess
	move.l	a0,-(sp)
	bsr	Ed_GetMessage
	bsr	Ed_Avertir
	move.l	(sp)+,a0
	rts
;
; Affiche un AVERTISSEMENT, boite de dialogue DEVANT le texte
; ~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Avertir
	movem.l	d0-d6/a0-a2,-(sp)
	bsr	Ed_SetBanks
	move.l	#EntNul,d0
	move.l	d0,d1
	move.l	a0,d2
	addq.w	#1,Ed_Avert(a5)
	move.w	Ed_Avert(a5),d3
	add.w	#10,d3
	ext.l	d3
	moveq	#0,d4
	moveq	#0,d5				Ne pas copier le programme
	move.l	#1024,d6
	move.l	Ed_Resource(a5),a0
	move.l	a0,a1
	add.l	2+8(a0),a0		Base des programmes
	add.l	6(a0),a0		Programme numero deux
	add.l	2(a1),a1		= Graphiques
	move.l	Ed_Messages(a5),a2	Base des messages
	JJsrP	L_Dia_RunQuick,a3
	movem.l	(sp)+,d0-d6/a0-a2
	rts
;
; Efface le dernier avertissement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AverFin
	movem.l	d0-d7/a0-a4,-(sp)
	move.w	Ed_Avert(a5),d1
	beq.s	.Out
	subq.w	#1,Ed_Avert(a5)
	add.w	#10,d1
	ext.l	d1
	move.l	d1,-(sp)
	move.l	#EntNul,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	Buffer(a5),a1
	EcCall	BlPut
	move.l	(sp)+,d1
	EcCall	BlDel
.Out	movem.l	(sp)+,d0-d7/a0-a4
	tst.w	d0
	rts
;
; Effacement de tous les avertissements
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AllAverFin
	tst.w	Ed_Avert(a5)
	bne.s	.Skip
	rts
.Skip	bsr	Ed_AverFin
	bra.s	Ed_AllAverFin
;
; Reaffichage de la ligne d'etat complete
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EtPrint
	move.b	#EtA_BAll,Edt_EtatAff(a4)
Ed_EtPrintD0
	tst.b	Edt_EtatAff(a4)
	beq	.EndX
	tst.b	Edt_Hidden(a4)
	bne	.EndX
	movem.l	d2-d7/a2,-(sp)
; Message d'alerte
; ~~~~~~~~~~~~~~~~
	bclr	#EtA_Alert,Edt_EtatAff(a4)
	beq.s	.Skip0
	clr.b	Edt_EtatAff(a4)
	tst.l	Edt_EtAlert(a4)
	beq	.End2
	move.w	Edt_WindEtat(a4),d1
	WiCall	QWindow
	moveq	#8,d0
	bsr	Et_Print
	move.l	Edt_EtAlert(a4),a1
	WiCall	Centre
	clr.l	Edt_EtAlert(a4)
	move.w	Edt_Window(a4),d1
	WiCall	QWindow
	bra	.End
.Skip0	tst.w	Edt_EtMess(a4)
	bne	.End2
	move.w	Edt_WindEtat(a4),d1
	WiCall	QWindow
; Une macro en route: message dans la fenetre courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	EdMa_Tape(a5)
	beq.s	.PaMacro
	cmp.l	Edt_Current(a5),a4
	bne.s	.PaMacro
	moveq	#8,d0
	bsr	Et_Print
	moveq	#30,d0
	bsr	Ed_GetMessage
	move.l	a0,a1
	WiCall	Centre
	clr.b	Edt_EtatAff(a4)
	bra.s	.End
.PaMacro
; Effacement Active/Inactive
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	bclr	#EtA_Clw,Edt_EtatAff(a4)
	beq.s	.Skip1
	moveq	#10,d0
	cmp.l	Edt_Current(a5),a4
	beq.s	.Okd
	moveq	#11,d0
.Okd	bsr	Et_Print		Efface,
	moveq	#2,d0
	bsr	Et_Print		Imprime le fond
	moveq	#12,d0
	bsr	Et_Print		Met les couleurs des informations
; Num�ro d'ordre de la fenetre
	bsr	Ed_EtOrder
.Skip1
; Ins
	bclr	#EtA_Ins,Edt_EtatAff(a4)
	beq.s	.Skip3
	bsr	Ed_EtIns
.Skip3
; Line, bit 2
	bclr	#EtA_Y,Edt_EtatAff(a4)
	beq.s	.Skip4
	bsr	Ed_EtLine
.Skip4
; Col, bit 3
	bclr	#EtA_X,Edt_EtatAff(a4)
	beq.s	.Skip5
	bsr	Ed_EtCol
.Skip5
; Free,
	bclr	#EtA_Free,Edt_EtatAff(a4)
	beq.s	.Skip6
	bsr	Ed_EtFree
.Skip6
; Nom du programme
	bclr	#EtA_Nom,Edt_EtatAff(a4)
	beq.s	.Skip7
	bsr	Ed_EtNom
.Skip7
; Fini! Que de labels....
.End
.End2	movem.l	(sp)+,a2/d2-d7
.EndX	rts

; Routine, imprime le message systeme D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Et_Print
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	rts


;____________________________________________________________________
;
;				RUN / MULTIRUN / TEST / INDENT
;____________________________________________________________________
;
;
; 	APPEL DU MONITEUR PAR LE MENU
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_GoMonitor
	bsr	Ed_TokCur
	bsr	Edt_ClearVar		Plus aucune variable, si HELP!
	bsr	Ed_Hide			Plein de memoire
	bsr	Ed_CloseEditor
	JJsr	L_Prg_SetBanks
	JJsr	L_Mon_Load		Va charger le moniteur
	bne.s	.Load
	move.l	a4,Edt_Runned(a5)	Programme >> runn�
	lea	Ed_ErrRun(pc),a0	Retour du moniteur
	move.l	a0,Prg_JError(a5)
	JJsr	L_Mon_In_Editor
	clr.l	Edt_Runned(a5)		Revient >>> Out of memory!
.Mem	move.w	#204,d0
.Err	move.l	d0,-(sp)
	bsr	Ed_OpenEditor		Rouvre l'editeur
	bsr	Ed_Appear
	move.l	(sp)+,d0
	bra	Ed_Al100
.Load	cmp.w	#-1,d0
	beq.s	.Mem
	move.w	#222,d0
	bra.s	.Err

; ___________________________________________________________________
;
; 	LANCE/CHARGE UN PROGRAMME COMME OPTION EDITEUR
; ___________________________________________________________________
;
;	A0=	Definition du programme
;
Ed_PrgCommand
	move.l	a0,a2
; Gestion ligne de commande
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	move.b	2(a2),d0
	beq.s	.NoCom
; Copie la ligne de commande
	move.l	Ed_MnPrograms(a5),a0
	bsr	Ed_GetMessageA0
	moveq	#0,d0
	move.b	-1(a0),d0
	bra.s	.Cop
; Copie la ligne courante � partir du curseur
.NoCom	bsr	Ed_LCourant
	move.l	a0,d0
	sub.l	a1,d0
	add.w	-2(a0),d0
	move.l	a1,a0
; Copie
.Cop	move.l	Buffer(a5),a1
	lea	TBuffer-256-6(a1),a1
	move.l	#"CmdL",(a1)+
	move.w	d0,(a1)+
	subq.w	#1,d0
	bmi.s	.Sko
.Loop	move.b	(a0)+,(a1)+
	dbra	d0,.Loop
.Sko
; On peut tokeniser maintenant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_TokCur
	btst	#0,(a2)
	bne	.Hidden
; Charger le programme dans la fenetre courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a2,-(sp)
	bsr	Ed_Saved		Va sauver le programme
	move.l	(sp)+,a2
; Recharger le programme?
	btst	#2,(a2)
	beq.s	.Sauv
	lea	Ed_ErrRun(pc),a0	Un message de fin...
	bra.s	.NLRun
; Sauve le programme
.Sauv	move.l	#Edt_EReload-Edt_SReload+4+4*10+128,d0
	lea	Ed_Prg2ReLoad(a5),a0
	bsr	Ed_MemReserve
	beq	Ed_OMm
	move.l	Prg_StTTexte(a6),(a0)+
	lea	Prg_Marks(a6),a1
	moveq	#9,d0
.Cm	move.l	(a1)+,(a0)+
	dbra	d0,.Cm
	lea	Edt_SReload(a4),a1
	move.w	#Edt_EReload-Edt_SReload-1,d0
.Cc	move.b	(a1)+,(a0)+
	dbra	d0,.Cc
	lea	Prg_NamePrg(a6),a1
.Cn	move.b	(a1)+,(a0)+
	bne.s	.Cn
	lea	Ed_ErrRunHidden(pc),a0		Pas de message
	move.b	#1,Ed_RunnedHidden(a5)		Flag, si Kill Editor
; NEW + LOAD + RUN!
; ~~~~~~~~~~~~~~~~~
.NLRun	move.l	a0,-(sp)
; Copie le nom
	moveq	#0,d0
	move.b	1(a2),d0
	move.l	Ed_MnPrograms(a5),a0	Prend le nom
	bsr	Ed_GetMessageA0
	move.l	Name1(a5),a1
.Bli	move.b	(a0)+,(a1)+
	bne.s	.Bli
	bsr	Ed_New2			New!
; Charge le programme
	move.w	#155,d0			Message, je charge!
	move.l	Name1(a5),a0
	bsr	Ed_AvName
	moveq	#-1,d0			Adapter la taille
	JJsr	L_Prg_Load
	bne	Ed_PrgLoadErr
	bsr	Ed_AverFin
; Run special
	move.l	Ed_BufT(a5),a0		Plus de Ed_RAlert
	clr.l	256(a0)
	bsr	Ed_BlocFree		Un peu de place
	bsr	Prg_RazUndos
	bsr	EdM_End
	bsr	EdM_Program
	move.l	a4,Edt_Runned(a5)	Programme runn�
	move.l	(sp)+,a1		Retour de fin variable!
	lea	Ed_TestMessage(pc),a2	Affichage tests
	moveq	#0,d0			Programme normal
	JJsr	L_Prg_RunIt
	clr.l	Edt_Runned(a5)		Si revient!
	bra	Ed_OMm			Out of mem si revient

; Charger le programme en HIDDEN
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Hidden	moveq	#0,d0
	move.b	1(a2),d0
	move.l	Ed_MnPrograms(a5),a0
	bsr	Ed_GetMessageA0
	move.l	Name1(a5),a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
; Recherche un accessoire deja charge
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Edt_AccAdr
	bne.s	.Deja
; Charge dans une fenetre cachee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_Dsk.PathIt
	bsr	Ed_RLoadHidden
	clr.l	Ed_WindowToDel(a5)
	btst	#2,(a2)
	bne.s	.Garde
	move.b	#-1,Edt_PrgDelete(a4)
	bra.s	.Skip
.Garde	bsr	EdM_BranchAMOS
	bsr	EdM_Program
.Skip	move.l	a4,a0
; Branche au RUN HIDDEN normal!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Deja	bra	Ed_RunHide
;
; Recharge le programme pr�c�dent
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PrgReLoad
; New du programme pr�c�dent
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_New2
; Taille du buffer
; ~~~~~~~~~~~~~~~~
	move.l	Ed_Prg2ReLoad(a5),a2
	move.l	(a2)+,d0
	JJsr	L_Prg_ChgTTexte
	beq.s	.Out
; Marks
; ~~~~~
	lea	Prg_Marks(a6),a0
	moveq	#9,d0
.Cm	move.l	(a2)+,(a0)+
	dbra	d0,.Cm
; Donnee d'edition
; ~~~~~~~~~~~~~~~~
	lea	Edt_SReload(a4),a0
	move.w	#Edt_EReload-Edt_SReload-1,d0
.Cc	move.b	(a2)+,(a0)+
	dbra	d0,.Cc
; Recharge le programme
; ~~~~~~~~~~~~~~~~~~~~~~
	tst.b	(a2)
	beq.s	.Nol
	move.l	Name1(a5),a0
.Cn	move.b	(a2)+,(a0)+
	bne.s	.Cn
; Chargement!
; ~~~~~~~~~~~
	move.w	#155,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
	moveq	#1,d0			Revenir si pas assez grand
	JJsr	L_Prg_Load
	bne.s	.Nol
	move.b	#1,Prg_StModif(a6)	Force le test
	bsr	Ed_AverFin
	bsr	Ed_NewBufAff
.Nol	bsr	Ed_AverFin
	bsr.s	.Free			Liberation de la structure
	bsr	Ed_RAlert		Si erreur dans le programme precedent
	bra	Ed_Loop
; Out of mem
; ~~~~~~~~~~
.Out	move.l	#1024,d0
	JJsr	L_Prg_ChgTTexte
	bsr	Edt_New
	bsr	.Free
	bra	Ed_OMm
; Libere la structure + reaffiche le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Free	lea	Ed_Prg2ReLoad(a5),a0
	bsr	Ed_MemFree
	move.l	a4,a0
	moveq	#%10,d0
	bsr	Ed_Splitted
	rts

;
; TROUVE L'ADRESSE DU PROGRAMME NAME1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	In	Name1	Nom � cherche
;	Out	Trouve	BNE, A0=adresse
;		Non	BEQ
;
Edt_AccAdr
	movem.l	a2/d2,-(sp)
	move.l	Name1(a5),a0
	bsr	Ed_DNom
	move.l	a0,d2
	move.l	Edt_List(a5),d0
	beq.s	.Out
.Loop0	move.l	d0,a2
	move.l	Edt_Prg(a2),a0
	lea	Prg_NamePrg(a0),a0
	bsr	Ed_DNom
	move.l	d2,a1
.Loop1	move.b	(a0)+,d0
	bsr	MajD0ed
	move.b	d0,d1
	move.b	(a1)+,d0
	bsr	MajD0ed
	cmp.b	d0,d1
	bne.s	.Next
	or.b	d1,d0
	bne.s	.Loop1
	move.l	a2,d0
	bra.s	.Ok
.Next	move.l	Edt_Next(a2),d0
	bne.s	.Loop0
.Out	moveq	#0,d0
.Ok	move.l	d0,a0
	movem.l	(sp)+,a2/d2
	rts


; ___________________________________________________________________
;
; 						RUN / TEST / INDENT
; ___________________________________________________________________
;

;
; RUN HIDDEN PROGRAM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_RunHidden
	bsr	Ed_TokCur		Ligne courante
	bsr	Ed_GetHidden		Cherche le programme
	beq	Ed_NotDone
	move.l	Buffer(a5),a1		Pas de command line!
	lea	TBuffer-256-6(a1),a1
	clr.l	(a1)
; Entree 2: run le programme A0
Ed_RunHide
	move.l	a0,Edt_Runned(a5)	Programme editeur runne
	move.l	Edt_Prg(a0),a6		Structure programme
	bsr	Ed_BlocFree		Un peu de place
	bsr	Prg_RazUndos
	bsr	EdM_End
	bsr	EdM_Program
	move.b	#1,Ed_RunnedHidden(a5)	Flag en cas de KILL EDITOR
	lea	Ed_ErrRunHidden(pc),a1	Retour de fin, sans ligne
	lea	Ed_TestMessage(pc),a2	Affichage tests
	moveq	#1,d0			Accessoire!
	JJsr	L_Prg_RunIt
	clr.l	Edt_Runned(a5)		Si revient
	beq	Ed_OMm			Out of memory
	bra	Ed_AlRunned		Already runned

;
; RUN EN MODE DIRECT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_RunDirect
	move.l	Edt_Current(a5),a4	Prend le programme courant
	move.l	Edt_Prg(a4),a6
	bsr	Ed_BlocFree		Un peu de place
	bsr	Prg_RazUndos
	bsr	EdM_End
	bsr	EdM_Program
	move.l	Buffer(a5),a1		Pas de command line!
	lea	TBuffer-256-6(a1),a1
	clr.l	(a1)
	move.l	a4,Edt_Runned(a5)	Programme runn�
	lea	Ed_DErrRun(pc),a1	Retour de fin normal
	lea	Ed_DTestMessage(pc),a2	Affichage tests
	moveq	#0,d0			Programme normal
	JJsr	L_Prg_RunIt
	clr.l	Edt_Runned(a5)		Si revient!
	bsr	Esc_Hide
	bsr	Ed_Appear
	bra	Ed_OMm			Out of mem si revient
Ed_DErrRun
	tst.w	Direct(a5)		Si ESC plus la >>> Erreurs normales
	beq	Ed_ErrRun
	bne	Ed_ErrDirect
Ed_DTestMessage
	rts				0 -> Rien
	nop
	rts				1 -> Rien
	nop
	bra	Esc_Hide		2 -> Fermeture de l'ecran

;
; RUN PROGRAMME COURANT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Run	bsr	Ed_TokCur		Ligne courante
	bsr	Ed_BlocFree		Un peu de place
	bsr	Prg_RazUndos
	bsr	EdM_End
	bsr	EdM_Program
	move.l	Buffer(a5),a1		Pas de command line!
	lea	TBuffer-256-6(a1),a1
	clr.l	(a1)
	move.l	a4,Edt_Runned(a5)	Programme runn�
	lea	Ed_ErrRun(pc),a1	Retour de fin normal
	lea	Ed_TestMessage(pc),a2	Affichage tests
	moveq	#0,d0			Programme normal
	JJsr	L_Prg_RunIt
	clr.l	Edt_Runned(a5)		Si revient!
	bra	Ed_OMm			Out of mem si revient

; RETOUR DE PROGRAMME HIDDEN SOUS EDITEUR
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ErrRunHidden
	move.l	Edt_Runned(a5),a4	Prend le programme courant
	move.l	Edt_Prg(a4),a6
	clr.l	Edt_Runned(a5)
	clr.b	Ed_RunnedHidden(a5)	Enleve le flag
; Prend le message
	bsr	Ed_GetError
	move.l	a0,-(sp)
	move.l	d0,-(sp)
; Configuration modifiee?
	tst.b	EdC_Modified(a5)	Tout modifie?
	beq.s	.Normal
	bsr	EdC_Redraw		Ferme et ouvre!
	bra.s	.Suite
; Configuration non modifiee
.Normal	tst.b	Prg_Accessory(a5)	Si accessoire
	beq.s	.Paac
	bsr	Ed_Redraw		Redessin de l'editeur
	bra.s	.Suite
.Paac	bsr	Ed_OpenEditor		ROuvre l'editeur
	bsr	Esc_Hide		Inutile, mais bon
	bsr	Ed_Appear
; Efface le programme si necessaire
.Suite	bsr	Edt_ClearVar
	tst.b	Edt_PrgDelete(a4)
	beq.s	.No
	bsr	Edt_DelWindow
	bsr	EdM_BranchAMOS
; Affiche le message dans le programme courant
.No	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_SetBanks		Change les banques
	JJsr	L_Bnk.Change		Envoie aux trappes / Musiques
	bsr	Ed_SetBanks		Retour aux banques editeur
	move.l	(sp)+,d0
	bmi.s	.Aue
	cmp.w	#10,d0			END / EDIT
	beq	Ed_Loop
	cmp.w	#1000,d0		Retour simple � l'editeur
	beq	Ed_Loop
	cmp.w	#1002,d0		Retour au workbench
	beq	Ed_System
.Aue	move.l	(sp)+,a0
; Fabrique le message Error in hidden
	move.l	a0,-(sp)
	moveq	#9,d0
	bsr	Ed_GetMessage
	move.l	Ed_BufT(a5),a1
.CopM1	move.b	(a0)+,(a1)+
	bne.s	.CopM1
	subq.l	#1,a1
	move.l	(sp)+,a0
.CopM2	move.b	(a0)+,(a1)+
	bne.s	.CopM2
	move.b	#".",-1(a1)
	clr.b	(a1)
; Imprime
	move.l	Ed_BufT(a5),a0
	move.w	#200,d0
	bra	Ed_Alert

; RETOUR DE TEST SOUS EDITEUR
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ErrTest
	move.l	Edt_Current(a5),a4	Pas d'effacement Edt_Runned!
	move.l	Edt_Prg(a4),a6
	bra.s	Ed_Errr
; RETOUR DE PROGRAMME NORMAL SOUS EDITEUR
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ErrRun
	tst.b	Ed_RunnedHidden(a5)
	bne	Ed_ErrRunHidden
	move.l	Edt_Runned(a5),a4	Prend le programme courant
	move.l	Edt_Prg(a4),a6
	clr.l	Edt_Runned(a5)
	tst.b	Prg_Reloaded(a6)	On a change le programme???
	beq.s	Ed_Errr
	clr.b	Prg_Reloaded(a6)
	move.w	#-1,Edt_YBloc(a4)
Ed_Errr	tst.l	d0			Error TESTING
	bmi	Ed_ErrEdit
	cmp.w	#1000,d0		Edit
	beq	Ed_ErrEdit
	cmp.w	#1001,d0		Direct
	beq	Ed_ErrDirect
	cmp.w	#1002,d0		System
	beq	Ed_System
	bsr	Ed_Ligne		Ligne de choix direct / edit
	cmp.w	#1,d1
	beq	Ed_ErrDirect
; Retour � l'�diteur
; ~~~~~~~~~~~~~~~~~~
Ed_ErrEdit
	bsr	Ed_GetError
	move.l	a0,-(sp)
	move.l	d0,-(sp)
; Apparition de l'�diteur
	bsr	Ed_OpenEditor		ROuvre l'editeur
	bsr	Esc_Hide
	bsr	Ed_Appear
; Retour � l'editeur si END ou EDIT
	move.l	(sp)+,d0		Message de test?
	bmi.s	.Skip
	cmp.w	#10,d0
	beq	Ed_Loop
	cmp.w	#1000,d0
	beq	Ed_Loop
; Positionne le curseur sur l'erreur
.Skip	move.l	VerPos(a5),a0
	bsr	Ed_FindA		Cherche le numero / adresse
	clr.l	Prg_AdEProc(a6)
	tst.l	d1
	beq.s	.Ski
	move.l	a0,Prg_AdEProc(a6)	Si procedure fermee--> Stocke!
	move.w	d0,-(sp)
	move.l	d1,-(sp)
	move.l	Buffer(a5),a1
	move.l	VerPos(a5),d0
	bsr	Detok
	move.w	d0,Prg_XEProc(a6)
	clr.l	VerPos(a5)
	move.l	(sp)+,a0
	move.w	(sp)+,d0
.Ski	bsr	Ed_SetY			Localise en Y
	move.l	Buffer(a5),a1		Offset de l'erreur
	move.l	VerPos(a5),d0
	bsr	Detok
	bsr	Ed_SetX
	bsr	Ed_NewBufAff
	move.l	(sp)+,a0		Affiche le message
	move.l	Ed_BufT(a5),a1		Avec un "." a la fin
	bsr	EdCocop
	move.b	#".",-1(a1)
	clr.b	(a1)
	move.l	Ed_BufT(a5),a0
	move.w	#200,d0
	bra	Ed_Alert

; Trouve le libelle de l'erreur en retour de programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_GetError
	ext.l	d0
	move.l	d0,d2
	move.l	a0,d1
	bne.s	.Clair
	cmp.w	#256,d0			Un message?
	bge.s	.Clair
	move.l	Ed_TstMessages(a5),a0	Message testing
	neg.w	d0
	move.w	d0,d2
	bpl.s	.MTest
	neg.w	d0
	move.w	d0,d2
	move.l	Ed_RunMessages(a5),a0
	addq.w	#1,d0
.MTest	bsr	Ed_GetMessageA0
	move.l	d2,d0
.Clair	rts

; Ligne EDITOR <-> DIRECT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Ligne
	movem.l	a0/d0,-(sp)
	bsr	Ed_GetError
	movem.l	a0/d0,-(sp)
; Ouvre l'editeur
	bsr	Ed_OpenEditor
; Fabrique les chaines de caractere
	move.l	Ed_VDialogues(a5),a2
	move.l	4(sp),a0		Message d'erreur
	bsr	Ed_DChaine
	move.l	a1,(a2)

	move.l	VerPos(a5),a0
	bsr	Ed_FindA
	addq.l	#1,d0
	move.l	d0,1*4(a2)		Numero de la ligne

	move.l	Buffer(a5),a1
	move.l	VerPos(a5),d0
	bsr	Detok
	move.w	d0,d3

	move.l	Buffer(a5),a3
	move.w	(a3)+,d2
	clr.b	0(a3,d2.w)
	moveq	#60,d4
	add.w	d3,d4
	clr.b	0(a3,d4.w)
	sub.w	#73,d4
	bpl.s	.S1
	moveq	#0,d4
.S1	lea	0(a3,d3.w),a0
	bsr	Ed_DChaine
	move.l	a1,3*4(a2)
	clr.b	0(a3,d3.w)
	lea	0(a3,d4.w),a0
	bsr	Ed_DChaine
	move.l	a1,2*4(a2)
	lea	EdReCop(pc),a0
	move.l	a0,4*4(a2)

; Fait apparaitre l'ecran
	moveq	#0,d2
	EcCalD	EHide,EcEdit
	EcCalD	First,EcEdit
	move.w	Ed_Wx(a5),d2
	move.w	Es_Y1(a5),d3
	move.l	#EntNul,d4
	moveq	#56,d5
	EcCalD	AView,EcEdit
	moveq	#0,d2
	moveq	#0,d3
	EcCalD	OffSet,EcEdit
; Fait apparaitre la souris
	SyCalD	Show,-1
	bsr	Esc_MaxMouse
; Positionne la souris sur l'ecran
	move.w	Ed_Wx(a5),d1
	move.w	Es_Y1(a5),d2
	addq.w	#1,d1
	addq.w	#1,d2
	SyCall	SetM
; Va demarrer le dialogue
	moveq	#EdD_Ligne,d0
	bsr	Ed_DoDialog
	move.w	d0,-(sp)
; Efface l'ecran
	moveq	#-1,d2
	EcCalD	EHide,EcEdit
	bsr	EdReCop
	move.w	(sp)+,d1
; Retourne a l'appelant
	addq.l	#8,sp
	movem.l	(sp)+,a0/d0
	rts

;
; TEST
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_Test	bsr	Ed_TokCur
	moveq	#-1,d0
	bsr	Ed_VaTester
; Message de warning si mix de constantes float
	move.w	#197,d0			***-No Errors
	move.b	Ver_SPConst(a5),d1
	tst.b	MathFlags(a5)
	bmi.s	.Test
	move.b	Ver_DPConst(a5),d1
.Test	tst.b	d1
	beq	Ed_Al100
	move.w	#221,d0			***-Precision mismatch
	bra	Ed_Al100

;
; CHECK 1.3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Check1.3
	bsr	Ed_TokCur
	move.b	#1,VerCheck1.3(a5)	Force l'arret
	move.b	#1,Prg_StModif(a6)	Force le test
	bsr	Ed_VaTester
	moveq	#49,d0			Compatible
	tst.b	VerNot1.3(a5)
	beq.s	.Go
	moveq	#48,d0			Too many banks
.Go	move.l	Ed_TstMessages(a5),a0
	bsr	Ed_GetMessageA0
	moveq	#127,d0
	bra	Ed_Alert

;
; INDENTATION AUTOMATIQUE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Indent
	bsr	Ed_TokCur
	bsr	Ed_VaTester
	move.w	Ed_Tabs(a5),d0
	move.l	Prg_StBas(a6),a0
	bsr	Indent
	bsr	Ed_NewBuf
	rts

;	Indentation du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0:	Debut programme
;	D0:	Valeur du Tab
Indent	movem.l	d2-d7,-(sp)
	move.w	d0,d3
	moveq	#0,d6
IndLine	move.l	a0,a1		* Adresse de debut de ligne
	moveq	#0,d4
	moveq	#0,d7
	move.w	d6,d5
	tst.w	(a0)+
	beq	IndX
IndLoop	move.w	(a0)+,d0
	beq	IndFL
	bsr	TInst
	cmp.w	#_TkProc,d0
	beq.s	IndPro
	cmp.w	#_TkEndP,d0
	beq.s	IndProF
	cmp.w	#_TkFor,d0
	beq.s	IndPls
	cmp.w	#_TkRpt,d0
	beq.s	IndPls
	cmp.w	#_TkWhl,d0
	beq.s	IndPls
	cmp.w	#_TkDo,d0
	beq.s	IndPls
	cmp.w	#_TkIf,d0
	beq.s	IndPls
	cmp.w	#_TkThen,d0
	beq.s	IndThen
	cmp.w	#_TkElse,d0
	beq.s	IndElse
	cmp.w	#_TkElsI,d0
	beq.s	IndElse
	cmp.w	#_TkEndI,d0
	beq.s	IndMns
	cmp.w	#_TkNxt,d0
	beq.s	IndMns
	cmp.w	#_TkUnt,d0
	beq.s	IndMns
	cmp.w	#_TkWnd,d0
	beq.s	IndMns
	cmp.w	#_TkLoo,d0
	beq.s	IndMns
	bra.s	IndLoop
* Debut d'une procedure: RAZ
IndPro:	moveq	#0,d5
	move.w	d3,d6
	tst.b	10(a1)
	bpl.s	IndLoop
	moveq	#0,d6
	move.l	4(a1),d0
	lea	12+2(a1,d0.l),a0
	bra	IndFL
* Fin d'une procedure
IndProF	moveq	#0,d5
	moveq	#0,d6
	bra	IndLoop
* Debut d'une boucle: + pour la ligne suivante
IndPls:	addq.w	#1,d7
	add.w	d3,d6
	bra	IndLoop
* Fin d'une boucle: - pour cette ligne et la suivante
IndMns:	subq.w	#1,d7
	bpl.s	IndM
	clr.w	d7
	sub.w	d3,d5
	sub.w	d3,d6
	bra	IndLoop
IndM:	sub.w	d3,d6
	bra	IndLoop
* THEN: met le flag pour ELSE
IndThen:moveq	#1,d4
	bra.s	IndMns
* ELSE: si FLAG, ne fait RIEN
IndElse tst.w	d4
	bne	IndLoop
	sub.w	d3,d5
	bra	IndLoop
* Fin d'une ligne: poke D5!
IndFL:	tst.w	d5
	bpl.s	IndFl1
	clr.w	d5
IndFl1:	cmp.w	#127,d5
	bcs.s	IndFl2
	moveq	#127,d5
IndFl2:	addq.w	#1,d5
	move.b	d5,1(a1)
	bra	IndLine
* Fin de l'indentation automatique
IndX:	movem.l	(sp)+,d2-d7
	rts

;
; Teste le programme s'il faut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0	Flag affichage ou non
;
Ed_VaTester
	tst.b	Prg_StModif(a6)		Vraiment tester?
	beq.s	.Ok
	move.b	#1,Ed_YaUTest(a5)	Un test!
	lea	Ed_ErrTest(pc),a1	En cas d'erreur
	lea	Ed_TestMessage(pc),a2	Affichage
	JJsr	L_Prg_TestIt		Va tester
	bne	Ed_AlRunned		Seule erreur possible
.Ok	rts


Ed_TestMessage
	bra	Ed_Test1
	bra	Ed_Test2
	bra	Ed_Test3
; Affiche le test si programme > 8K
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Test1
	movem.l	a0-a6/d0-d7,-(sp)
	clr.b	Ed_TstMesOn(a5)		Plus de flag
	move.l	Prg_StHaut(a6),d0
	sub.l	Prg_StBas(a6),d0
	cmp.l	#1024*4,d0
	bcs.s	.Non
	addq.b	#1,Ed_TstMesOn(a5)
	move.w	#198,d0
	bsr	Ed_GetMessage
	bsr	Ed_Avertir
	JJsr	L_Prg_SetBanks
.Non	movem.l	(sp)+,a0-a6/d0-d7
Ed_Rts	rts
; Effacement du message
; ~~~~~~~~~~~~~~~~~~~~~
Ed_Test2
	movem.l	a0-a6/d0-d7,-(sp)
	tst.b	Ed_TstMesOn(a5)
	beq.s	.Non
	clr.b	Ed_TstMesOn(a5)
	bsr	Ed_AverFin
	JJsr	L_Prg_SetBanks
.Non	movem.l	(sp)+,a0-a6/d0-d7
	rts
; Effacement de l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~
Ed_Test3
	bsr	EdM_End
	bra	Ed_Hide


; ___________________________________________________________________
;
;					PROCEDURES
; ___________________________________________________________________

;
; OPEN / CLOSE ALL PROCEDURES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ProcsOpen
	moveq	#0,d2
	bra.s	Ed_Procs
Ed_ProcsClose
	moveq	#-1,d2
Ed_Procs
	bsr	Ed_TokCur
	tst.w	d2
	beq.s	.Skip
	moveq	#-1,d0
	bsr	Ed_VaTester
.Skip
; Sauve les marques
; ~~~~~~~~~~~~~~~~~
	bsr	Ed_Marks2Adress
; Trouve la position actuelle du curseur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	bsr	Ed_FindL
	move.l	a0,d3
; Boucle d'exploration du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	clr.w	d0
	bsr	Ed_FindL
	beq.s	.EdFa3
.EdFa1	cmp.w	#_TkProc,2(a0)
	bne.s	.EdFa2
	btst	#6,10(a0)
	bne.s	.EdFa2
	bclr	#7,10(a0)
	tst.w	d2
	beq.s	.EdFa2
	bset	#7,10(a0)
.EdFa2	bsr	Ed_NextL
	bne.s	.EdFa1
; Reaffiche le programme
; ~~~~~~~~~~~~~~~~~~~~~~
.EdFa3	JJsr	L_Prg_CptLines
; Recalcule les marques
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_Marks2Number
; Recentre le curseur
; ~~~~~~~~~~~~~~~~~~~
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	tst.l	d3
	beq.s	.EdFa4
	move.l	d3,a0
	bsr	Ed_FindA
.EdFa4	bsr	Ed_SetY
	bsr	Ed_NewBuf
	rts

;
; INSERT MACHINE LANGAGE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ProcML
	bsr	Ed_TokCur
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	move.w	#178,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
; Trouve la ligne
; ~~~~~~~~~~~~~~~
.Reloop	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	bsr	Ed_FindL
	move.l	Edt_DebProc(a4),d0
	beq	Ed_FoE
	move.l	d0,a2
; Va fermer la procedure, s'il faut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#7,10(a2)
	bne.s	.PaOu
	bsr	Ed_ProcOpen
	bra.s	.Reloop
.PaOu
; Trouve la longueur du fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1005,d2
	bsr	Ed_Open
	beq	Ed_DError
; Saute les premiers HUNKS!
	bsr	.GetH
	cmp.l	#$3F3,d0
	bne	.NoGood
.Plo0	bsr	.GetH
	cmp.l	#$3E9,d0
	bne.s	.Plo0
	bsr	.GetH
	lsl.l	#2,d0
	move.l	d0,d3
	add.l	#512,d0
	JJsr	L_ResTempBuffer
	move.l	a0,a3
	move.l	a0,a1
; Cree le faux programme
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	a2,a0
	moveq	#0,d0				Copie PROCEDURE
	move.b	(a0),d0
	lsl.w	#1,d0
	subq.w	#1,d0
.Cp1	move.b	(a0)+,(a1)+
	dbra	d0,.Cp1
	or.w	#%0101000000000000,10(a3)	Procedure machine langage
	move.w	#$0301,(a1)+
	move.w	#_TkML,(a1)+
	lea	10+6(a3),a0			Pointe les parametres
	moveq	#0,d0
	move.b	(a0),d0
	lea	2+2(a0,d0.w),a0
	move.l	a0,d0
	sub.l	a1,d0
	cmp.w	#_TkBra1,-2(a0)
	beq.s	.Par
	moveq	#0,d0
.Par	move.w	d0,(a1)+
; Charge le langage machine dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a1,d2
	bsr	Ed_Read
	bne	Ed_DError
	bsr	Ed_Close
; Met le ENDPROC
; ~~~~~~~~~~~~~~
	move.l	d2,a1
	add.l	d3,a1
	move.w	#$0301,(a1)+
	move.w	#_TkEndP,(a1)+
	clr.w	(a1)+
	move.l	a1,d0
	sub.l	a3,d0
	sub.l	#14,d0
	move.l	d0,4(a3)
	move.l	a1,d3
	sub.l	a3,d3				D3= Longueur totale
; Efface l'ancienne proc�dure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	Edt_YCu(a4),d0
	add.w	Edt_YPos(a4),d0
	bsr	Ed_FindL
	move.l	a0,-(sp)
	bsr	Ed_NextL
	move.l	a0,a1
	move.l	(sp)+,a0
	bsr	Ed_StDelChunk
; Insere la nouvelle procedure
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a3,a0
	move.l	d3,d0
	move.w	Edt_YCu(a4),d1
	add.w	Edt_YPos(a4),d1
	bsr	Ed_StoBlock
; Voili Voila
; ~~~~~~~~~~~
	moveq	#0,d0
	JJsr	L_ResTempBuffer
	JJsr	L_Prg_CptLines
	bsr	Ed_AverFin
	rts
; Routinette
; ~~~~~~~~~~
.GetH	move.l	Buffer(a5),d2
	moveq	#4,d3
	bsr	Ed_Read
	bne	Ed_DError
	move.l	Buffer(a5),a0
	move.l	(a0),d0
	rts
; Pas un bon programme!
; ~~~~~~~~~~~~~~~~~~~~~
.NoGood	move.w	#182,d0
	bsr	Ed_GetMessage
	move.w	#250,d0
	bra	Ed_Alert

;
; OPEN / CLOSE PROCEDURE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ProcOpen
	bsr	Ed_TokCur
; Trouve la ligne
; ~~~~~~~~~~~~~~~
	move.w	Edt_YPos(a4),d0
	add.w	Edt_YCu(a4),d0
	bsr	Ed_FindL
	move.l	Edt_DebProc(a4),d0
	beq	Ed_FoE
; Peut-on ouvrir?
; ~~~~~~~~~~~~~~~
	move.l	d0,a2
	btst	#6,10(a2)
	bne.s	.Out
; Ouverture ou fermeture?
; ~~~~~~~~~~~~~~~~~~~~~~~
	btst	#7,10(a2)
	bne.s	.PaOu
	move.l	a2,-(sp)		Si fermeture, on teste
	moveq	#-1,d0
	bsr	Ed_VaTester
	move.l	(sp)+,a2
.PaOu
; Sauve les marques
; ~~~~~~~~~~~~~~~~~
	bsr	Ed_Marks2Adress
; Change la procedure
; ~~~~~~~~~~~~~~~~~~~
	bchg	#7,10(a2)
; Recalcule les marques
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_Marks2Number
; Recentre (autour de l'erreur s'il faut)!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_Prg_CptLines
	move.l	a2,a0
	tst.w	10(a0)
	bmi.s	.Skip
	tst.l	Prg_AdEProc(a6)
	beq.s	.Out
	bsr	Ed_RAlert
	move.w	Prg_XEProc(a6),d0
	bsr	Ed_SetX
	move.l	Prg_AdEProc(a6),d0
	bclr	#31,d0
	move.l	d0,a0
.Skip	bsr	Ed_FindA
	bsr	Ed_SetY
.Out	bsr	Ed_NewBuf
	rts

;
; Arret de l'auto-centrage en cas d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ClEProc
	tst.l	Prg_AdEProc(a6)
	beq.s	.Out
	bmi.s	.Skip
	bset	#7,Prg_AdEProc(a6)
	rts
.Skip	clr.l	Prg_AdEProc(a6)
.Out	rts

;_____________________________________________________________________________
;
;							Mode Escape
;_____________________________________________________________________________
;

Ed_Escape
	moveq	#"E",d0			Va faire du bruit!
	bsr	Ed_SamPlay
	bsr	Ed_TokCur
	bsr	Ed_Hide
	bsr	Esc_Appear

; _________________________________________
;
; Boucle du mode escape
; _________________________________________
;
Esc_Loop
	move.l	BasSp(a5),sp
	move.w	#1,T_AMOState(a5)	Editor present!
	lea	Ed_ErrDirect(pc),a0	Jump si error
	move.l	a0,Prg_JError(a5)
;	move.l	Edt_Current(a5),a4	Change les banques >>> programme!
;	move.l	Edt_Prg(a4),a6
;	JJsr	L_Prg_SetBanks

; Affiche les sliders de m�moire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EcCalD	Active,EcFonc
	bsr	Ed_MemoryAff

	EcCalD	Active,EcEdit

; Met le curseur
	moveq	#14,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
; Initialise l'editeur ligne
	lea	Es_LEd(a5),a0
	move.l	Buffer(a5),a1
	move.l	a1,a2
	clr.b	(a1)
	move.w	#(1<<LEd_FMulti)|(1<<LEd_FTests)|(1<<LEd_FKeys)|(1<<LEd_FMouse)|(1<<LEd_FCursor)|(1<<LEd_FMouCur),d0
	moveq	#0,d1			Curseur=0
	move.w	#160,d2			Longueur
	moveq	#-1,d3			Largeur maximum
	moveq	#"*",d4			Curseur
	JJsrP	L_LEd_Init,a3
	bra	Esc_Aff

Esc_L1	JJsr	L_Sys_WaitMul	Multitache + Inhibition
	lea	Es_LEd(a5),a0
	JJsrR	L_LEd_Loop,a1
	bmi.s	Esc_L1		Control-C
	cmp.w	#1,d2		Return?
	beq	Esc_R
	cmp.w	#2,d2		La souris?
	beq	Esc_MKey
	swap	d1
	move.w	d1,d0		Isole les SHIFTS
	lsr.w	#8,d0
	cmp.b	#$45,d1		ESC?
	beq	Esc_Esc
	cmp.b	#$4C,d1		Fleche vers le HAUT
	beq	Esc_H
	cmp.b	#$4D,d1		Fleche vers le BAS
	beq	Esc_B
	cmp.b	#$5F,d1		HELP
	beq	Esc_Help
	cmp.b	#$50,d1		Touches de fonction
	bcs	Esc_F
	cmp.b	#$59,d1
	bls	Esc_Fonc
Esc_F	EcCalD	Active,EcEdit
	bra.s	Esc_L1
Esc_Aff	bsr	Es_Display
	bset	#4,T_Actualise(a5)
	bset	#4,ActuMask(a5)
	SyCall	WaitVbl
	bra.s	Esc_F
;
; Bouton escape
; ~~~~~~~~~~~~~
Esc_Bouton
	move.l	d0,a0
	move.w	d1,d0
	move.w	Bt_Number(a0),d1
	subq.w	#1,d1				0 > retour editeur
	beq	Esc_Esc
	subq.w	#1,d1				1 > Workbench
	bne.s	.Pa2
	bsr	Ed_Wb
	bra	Esc_F
.Pa2	subq.w	#1,d1				2 > Out
	bne.s	.Pa3
	move.b	Bt_Pos+1(a0),Esc_Output(a5)
	bra	Esc_F
.Pa3	subq.w	#1,d1				3 > Fonctions
	btst	#1,d0				  > Bouton droit, fonction 10-20
	beq	Esc_BtFonc
	add.w	#10,d1
	bra	Esc_BtFonc
;
; Click souris
; ~~~~~~~~~~~~
Esc_MKey
	SyCall	GetZone
	cmp.w	#EcFonc,d1
	beq.s	Esc_MBoutons
	cmp.w	#EcEdit,d1
	beq.s	Esc_MEcran
	bra	Esc_F
; Dans l'�cran du haut
; ~~~~~~~~~~~~~~~~~~~~
Esc_MBoutons
	lea	Ed_Boutons(a5),a0
	JJsrR	L_Bt_Gere,a1
	bne	Esc_Bouton
	bra.s	Esc_MMove
; Dans l'�cran
; ~~~~~~~~~~~~
Esc_MEcran
	swap	d1
	cmp.w	#1,d1
	beq.s	Esc_MMove
; Change la taille
	SyCall	XyMou
	sub.w	Es_Y2(a5),d2
	move.w	d2,-(sp)
.SLoop	SyCall	XyMou
	sub.w	(sp),d2
	move.w	Es_Y1(a5),d0
	move.w	d0,d1
	add.w	#Es_MiniSy,d0
	add.w	Ed_Sy(a5),d1
	cmp.w	d0,d2
	bge.s	.SOk1
	move.w	d0,d2
.SOk1	cmp.w	d1,d2
	ble.s	.SOk2
	move.w	d1,d2
.SOk2	cmp.w	Es_Y2(a5),d2
	beq.s	.SSkip
	move.w	d2,Es_Y2(a5)
	bsr	Es_Display
	bsr	EdReCop
.SSkip	SyCall	MouseKey
	btst	#0,d1
	bne.s	.SLoop
	tst.w	(sp)+
	bra	Esc_F
; Change la position
Esc_MMove
	SyCall	XyMou
	sub.w	Es_Y1(a5),d2
	move.w	d2,-(sp)
.MLoop	SyCall	XyMou
	sub.w	(sp),d2
	cmp.w	Es_Y1(a5),d2
	beq.s	.MSkip
	move.w	Es_Y2(a5),d0
	sub.w	Es_Y1(a5),d0
	move.w	d2,Es_Y1(a5)
	add.w	d0,d2
	move.w	d2,Es_Y2(a5)
	bsr	Es_Display
	bsr	EdReCop
.MSkip	SyCall	MouseKey
	btst	#0,d1
	bne.s	.MLoop
	tst.w	(sp)+
	bra	Esc_F
;
; Fleche vers le HAUT
; ~~~~~~~~~~~~~~~~~~~
Esc_H	move.b	d0,d1
	and.b	#Ctr,d1
	bne.s	Esc_HH
	and.b	#Shf,d0
	bne.s	Esc_BH
; Recupere une touche AVANT
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Esc_KMem(a5),a0
	move.l	Esc_KMemPos(a5),d0
	beq.s	.Sk1
	move.l	d0,a0
.Sk1	move.l	(a0),d0
	beq	Esc_F
	move.l	d0,a0
	bra	Esc_Recall
; Monte toute la fenetre
; ~~~~~~~~~~~~~~~~~~~~~~
Esc_HH	tst.w	Es_Y2(a5)
	bmi	Esc_F
	subq.w	#8,Es_Y1(a5)
	subq.w	#8,Es_Y2(a5)
	bra	Esc_Aff
; Monte la ligne du bas
; ~~~~~~~~~~~~~~~~~~~~~
Esc_BH	move.w	Es_Y1(a5),d0
	add.w	#Es_MiniSy,d0
	subq.w	#8,Es_Y2(a5)
	cmp.w	Es_Y2(a5),d0
	ble	Esc_Aff
	move.w	d0,Es_Y2(a5)
	bra	Esc_Aff
;
; Fleche vers le BAS
; ~~~~~~~~~~~~~~~~~~
Esc_B	move.b	d0,d1
	and.b	#Ctr,d1
	bne.s	Esc_HB
	and.b	#Shf,d0
	bne.s	Esc_BB
; Recupere une touche APRES
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Esc_KMemPos(a5),d0
	beq	Esc_F
	move.l	Esc_KMem(a5),d1
	beq	Esc_F
	cmp.l	d0,d1
	beq.s	.Spec
.Loop	move.l	d1,a0
	move.l	(a0),d1
	beq	Esc_F
	cmp.l	d1,d0
	bne.s	.Loop
	bra	Esc_Recall
.Spec	clr.l	Esc_KMemPos(a5)
	move.l	Buffer(a5),a1
	clr.w	(a1)
	bra	Esc_Recall2

; Descend toute la fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~
Esc_HB	move.w	Es_Y1(a5),d0
	cmp.w	#312,d0
	bge	Esc_F
	addq.w	#8,Es_Y1(a5)
	addq.w	#8,Es_Y2(a5)
	bra	Esc_Aff
; Descend la ligne du bas
; ~~~~~~~~~~~~~~~~~~~~~~~
Esc_BB	move.w	Es_Y1(a5),d0
	add.w	Ed_Sy(a5),d0
	addq.w	#8,Es_Y2(a5)
	cmp.w	Es_Y2(a5),d0
	bge	Esc_Aff
	move.w	d0,Es_Y2(a5)
	bra	Esc_Aff
;
; ESCAPE ---> Retour a l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_Esc
	moveq	#"E",d0			Va faire du bruit!
	bsr	Ed_SamPlay
	bsr	Esc_Hide
	clr.w	Edt_EtMess(a4)
	bsr	Ed_Appear
	bra	Ed_Loop
;
; HELP ---> recentre la souris dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_Help
	SyCalD	Show,-1
	bsr	Esc_MaxMouse
	move.w	Ed_Wx(a5),d1
	move.w	Es_Y1(a5),d2
	add.w	#16,d2
	SyCall	SetM
	bra	Esc_Aff
;
; Touches de fonction 1-10
; ~~~~~~~~~~~~~~~~~~~~~~~~
Esc_Fonc
	and.b	#Shf,d0
	beq.s	.NoShf
	add.w	#10,d1
.NoShf	and.w	#$00FF,d1
	sub.w	#$0050,d1
Esc_BtFonc
	moveq	#24,d0
	add.w	d1,d0
	bsr	Ed_GetSysteme
	move.l	Buffer(a5),a1
.Test	move.b	(a0)+,d2
	move.b	d2,(a1)+
	beq.s	.NoRet
	cmp.b	#"`",d2
	bne.s	.Test
	clr.b	-(a1)
.NoRet	lea	Es_LEd(a5),a0
	move.l	Buffer(a5),a1
	moveq	#-1,d0
	JJsrP	L_LEd_New,a2
	tst.b	d2
	beq	Esc_F
	bra	Esc_R
;
; Rappel d'une sequence memorisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_Recall
	move.l	a0,Esc_KMemPos(a5)
	lea	6(a0),a1
Esc_Recall2
	lea	Es_LEd(a5),a0
	moveq	#-1,d0
	JJsrP	L_LEd_New,a2
	bra	Esc_F
;
; Return en mode ESCAPE
; ~~~~~~~~~~~~~~~~~~~~~
Esc_R	move.l	Buffer(a5),a2
	tst.b	(a2)
	beq	Esc_Loop
	move.w	Esc_KMemMax(a5),d0
	bsr	Esc_KMemEffD0
	move.l	a2,a0
.Count	tst.b	(a0)+
	bne.s	.Count
	sub.l	a2,a0
	move.l	a0,d2
	addq.l	#6,d2
; Met dans la liste
	lea	Esc_KMem(a5),a0
	move.l	d2,d0
	SyCall	MemFastClear
	beq	.Egal
	move.l	Esc_KMem(a5),(a0)
	move.l 	a0,Esc_KMem(a5)
	clr.l	Esc_KMemPos(a5)
	addq.l	#4,a0
	move.w	d2,(a0)+
.Copy	move.b	(a2)+,(a0)+
	bne.s	.Copy
; Retour chariot
.Egal	lea	CRet(pc),a1
	WiCall	Print
	move.w	Ed_Sx(a5),d0
	lsr.w	#3,d0
	sub.w	#9,d0
	cmp.w	d0,d2
	bls.s	.SkipR
	lea	CRet(pc),a1
	WiCall	Print
.SkipR
; Tokenise la ligne
; ~~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),a0
	move.l	Ed_BufT(a5),a1
	bsr	Tokenise
	beq	Esc_Loop
; Appelle l'interpreteur
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_Current(a5),a4		Change les banques
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_SetBanks
	clr.l	Edt_Runned(a5)			Securites!
	clr.l	Prg_Runned(a5)
	lea	Ed_ErrDirect(pc),a0		Jump si error
	move.l	a0,Prg_JError(a5)
	JJsr	L_VerDirect
;	move.w	VarLong(a5),d0			Verification longueur vars.
;	cmp.w	TVMax(a5),d0
;	bcc	VerVTo
	move.w	ScOn(a5),d1			Branche l'ecran
	beq.s	.Pa
	subq.w	#1,d1
	EcCall	Active
.Pa	JJmp	L_New_ChrGet			Branche au chrget

;
; Efface le dernier si >D0
; ~~~~~~~~~~~~~~~~~~~~~~~~
Esc_KMemEffD0
	movem.l	d2/d3,-(sp)
	moveq	#0,d2
	sub.l	a1,a1
	move.l	Esc_KMem(a5),d1
	beq.s	.Out
.Loop	move.l	a1,d3
	move.l	d1,a1
	addq.w	#1,d2
	move.l	(a1),d1
	bne.s	.Loop
.Exit	cmp.w	d0,d2
	bcs.s	.Out
	tst.l	d3
	beq.s	.Skip
	move.l	d3,a0
	clr.l	(a0)
	bra.s	.Eff
.Skip	clr.l	Esc_KMem(a5)
.Eff	move.l	a0,-(sp)
	moveq	#0,d0
	move.w	4(a1),d0
	SyCall	MemFree
	move.l	(sp)+,a0
.Out	movem.l	(sp)+,d2/d3
	rts
;
; Efface tous les KMEM
; ~~~~~~~~~~~~~~~~~~~~
Esc_KMemEnd
	bra.s	.In
.Loop	moveq	#0,d0
	bsr	Esc_KMemEffD0
.In	tst.l	Esc_KMem(a5)
	bne.s	.Loop
	rts
;
; Retourne la position du bouton OUTPUT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_BtGetOutput
	move.b	Esc_Output(a5),Bt_Pos+1(a2)
	rts

;
;
; Entree des erreurs en mode direct
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ErrDirect
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_GetError			Va chercher le message
	movem.l	a0/d0,-(sp)
	bsr	Ed_OpenEditor
	clr.l	Edt_Runned(a5)			Plus de programme!
	or.b	#%00010001,ActuMask(a5)
	EcCalD	CopOnOff,-1
	EcCalD	First,EcEdit
	EcCalD	First,EcFonc
	EcCalD	Active,EcEdit
	bsr	EdReCop
	bsr	Ed_Hide
	bsr	Esc_Appear
	movem.l	(sp)+,a1/d1
	cmp.w	#1002,d1
	beq	Ed_System
	cmp.w	#1000,d1
	beq	Esc_Esc
	cmp.w	#1000,d1
	bcc	Esc_Loop
	cmp.w	#10,d1
	beq	Esc_Loop
	WiCall	Print
	bra	Esc_Loop


; ___________________________________________________________________
;
; 	ECRAN ESCAPE
; ___________________________________________________________________
;

; Apparition de l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_Appear
	movem.l	a2-a4/a6/d2-d7,-(sp)
; Flag!
; ~~~~~
	tst.w	Direct(a5)
	bne	.Out
	move.w	#1,Direct(a5)
	move.w	Ed_Sx(a5),d7

; Active l'�cran de titre
; ~~~~~~~~~~~~~~~~~~~~~~~
	EcCalD	Active,EcFonc
	EcCalD	First,EcEdit
; Unpack le logo AMOS
; ~~~~~~~~~~~~~~~~~~~
	moveq	#Es_Pics,d0
	moveq	#Es_BoutonsSx,d1
	moveq	#Es_BoutonsY,d2
	bsr	Es_Unpack
	sub.w	#Es_TitleSx,d7
;
; Cree les 13 boutons
; ~~~~~~~~~~~~~~~~~~~
	lea	Ed_Boutons(a5),a2
	move.w	#Es_BoutonsX,d2
	moveq	#Es_BoutonsY,d3
	moveq	#Es_BoutonsPics,d4
	move.w	#Es_BoutonsZones,d5
	moveq	#1,d6
.Loop	move.w	d6,Bt_Number(a2)
	cmp.w	#1,d6
	bne.s	.Pa1
	clr.w	Bt_X(a2)			Bouton DIRECT
	bra.s	.PaB
.Pa1	cmp.w	#2,d6
	bne.s	.Pa2
	move.w	Ed_Sx(a5),Bt_X(a2)		Bouton WB
	sub.w	#Ed_BoutonsSx,Bt_X(a2)
	bra.s	.PaB
.Pa2	move.w	d2,Bt_X(a2)
	add.w	#Ed_BoutonsSx,d2
.PaB	move.w	d3,Bt_Y(a2)
	move.w	d4,Bt_Image(a2)
	move.w	d5,Bt_Zone(a2)
	lea	Bt_RoutIn(pc),a0
	move.l	a0,Bt_Routines(a2)
	move.b	#4,Bt_RDraw(a2)
	clr.b	Bt_RPos(a2)
	clr.b	Bt_RChange(a2)
	clr.b	Bt_Flags(a2)
	clr.w	Bt_Pos(a2)
	move.b	#Es_BoutonsSx,Bt_Sx(a2)
	move.b	#Es_BoutonsSy,Bt_Sy(a2)
	addq.w	#2,d4
	addq.w	#1,d5
	sub.w	#Es_BoutonsSx,d7
	lea	Bt_Long(a2),a2
	addq.w	#1,d6
	cmp.w	#13,d6
	bls.s	.Loop
	clr.w	(a2)

; Dessine les sliders de memoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	d2,d1
	moveq	#Es_BoutonsY,d2
	move.w	d7,d3
	lea	Es_Unpack(pc),a2
	bsr	Ed_MemoryDraw
	bsr	Ed_MemoryAff

; Position  du bouton "OUT"
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.b	#5,Ed_Boutons+Bt_Long*2+Bt_RPos(a5)
	bset	#Bt_FlagOnOf,Ed_Boutons+Bt_Long*2+Bt_Flags(a5)
; Init des boutons
; ~~~~~~~~~~~~~~~~
	lea	Ed_Boutons(a5),a0
	moveq	#1,d0
	JJsrR	L_Bt_InitList,a1
; Reserve la zone de fond
; ~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d2
	moveq	#0,d3
	move.w	Ed_Sx(a5),d4
	moveq	#Es_TitleSy,d5
	SyCalD	SetZone,14

; Active l'�cran de texte
; ~~~~~~~~~~~~~~~~~~~~~~~
	EcCalD	Active,EcEdit
; Dessine le bord droit
; ~~~~~~~~~~~~~~~~~~~~~
	move.w	Ed_Ty(a5),d6
	addq.w	#1,d6
	moveq	#0,d7
.Loopa	moveq	#Es_Pics+1,d0
	move.w	Ed_Sx(a5),d1
	sub.w	#16,d1
	ext.l	d1
	move.w	d7,d2
	moveq	#-1,d3
	bsr	Ed_Unpack
	addq.w	#8,d7
	subq.w	#1,d6
	bne.s	.Loopa
; Dessine le bas
; ~~~~~~~~~~~~~~
	moveq	#Es_Pics+2,d0
	moveq	#0,d1
	move.w	d7,d2
	moveq	#-1,d3
	bsr	Ed_Unpack
	move.w	d7,d0
	addq.w	#8,d7
	move.w	d7,d1
	bsr	Ed_Enlarge
; Ouvre la fenetre
; ~~~~~~~~~~~~~~~~
	moveq	#1,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	Ed_Sx(a5),d4
	lsr.w	#3,d4
	subq.w	#2,d4
	move.w	Ed_Ty(a5),d5
	addq.w	#1,d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCall	WindOp
	moveq	#16,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
; Defini les zones
; ~~~~~~~~~~~~~~~~
	SyCalD	RazZone,0
	moveq	#0,d2
	moveq	#0,d3
	move.w	Ed_Sx(a5),d4
	move.w	Ed_Sy(a5),d5
	SyCalD	SetZone,2
	sub.w	#16,d4
	subq.w	#8,d5
	SyCalD	SetZone,1
; Descend l'�cran du bas
; ~~~~~~~~~~~~~~~~~~~~~~
	move.w	Es_Y1(a5),d0
	move.w	d0,d1
	add.w	#Es_MiniSy,d1
.Loop1	move.w	d1,d2
	add.w	Ed_VScrol(a5),d1
	cmp.w	Es_Y2(a5),d1
	ble.s	.Skip1
	move.w	Es_Y2(a5),d1
.Skip1	movem.w	d0-d2,-(sp)
	bsr	Es_DisplayD0
	bsr	EdReCop
	movem.w	(sp)+,d0-d2
	cmp.w	d1,d2
	bne.s	.Loop1
	bsr	Esc_MaxMouse
.Out	movem.l	(sp)+,a2-a4/a6/d2-d7
	rts
; Elargi les limites de la souris
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_MaxMouse
	moveq	#128-16,d1
	moveq	#35,d2
	move.l	#500,d3
	move.l	#312,d4
	SyCall	LimitM
	rts

;
; Disparition de l'�cran de mode direct
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Esc_Hide
	movem.l	a0-a4/a6/d0-d7,-(sp)
	tst.w	Direct(a5)
	beq	.Out
	clr.w	Direct(a5)
; Remonte l'�cran du bas
; ~~~~~~~~~~~~~~~~~~~~~~
	move.w	Es_Y1(a5),d0
	move.w	Es_Y2(a5),d1
.Loop1	move.w	d1,d2
	sub.w	Ed_VScrol(a5),d1
	move.w	d0,d3
	add.w	#Es_MiniSy,d3
	cmp.w	d3,d1
	bge.s	.Skip1
	move.w	d3,d1
.Skip1	movem.w	d0-d2,-(sp)
	bsr	Es_DisplayD0
	bsr	EdReCop
	movem.w	(sp)+,d0-d2
	cmp.w	d1,d2
	bne.s	.Loop1
	move.l	T_EcAdr+EcEdit*4(a5),a0
	bset	#BitHide,EcFlags(a0)
; Efface l'�cran du haut
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_EcAdr+EcFonc*4(a5),a0
	bset	#BitHide,EcFlags(a0)
	bsr	EdReCop
; Efface la fenetre de fond
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	EcCalD	Active,EcEdit
	WiCall	WinDel
; Efface les zones
; ~~~~~~~~~~~~~~~~
	SyCalD	RazZone,0
.Out 	movem.l	(sp)+,a0-a4/a6/d0-d7
	rts

;
; Positionne les ecrans du mode escape
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Es_Display
	move.w	Es_Y1(a5),d0
	move.w	Es_Y2(a5),d1
Es_DisplayD0
	move.l	T_EcAdr+EcFonc*4(a5),a0
	move.l	T_EcAdr+EcEdit*4(a5),a1
; Ecran du haut
	move.w	d0,EcAWY(a0)
	bset	#2,EcAW(a0)
	add.w	#Es_TitleSy,d0
; Ecran du bas
	move.w	d0,EcAWY(a1)		Position
	bset	#2,EcAW(a1)
	sub.w	d0,d1			Hauteur
	move.w	d1,EcAWTY(a1)
	bset	#2,EcAWT(a1)
	move.w	Ed_Sy(a5),d0		D�but de la fenetre
	sub.w	d1,d0
	move.w	d0,EcAVY(a1)
	bset	#2,EcAV(a1)
; Fait apparaitre les �crans
	bclr	#BitHide,EcFlags(a0)
	bclr	#BitHide,EcFlags(a1)
; Ecran de l'�diteur en premier
	EcCalD	First,EcFonc
	EcCalD	First,EcEdit
	rts
;
; Cache l'�cran de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Hide
	movem.l	a0-a4/a6/d0-d7,-(sp)
	tst.w	EsFlag(a5)
	bne	.Out
	move.w	#-1,EsFlag(a5)
; Plus d'avertissements
; ~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_AllAverFin
; Fait disparaitre lentement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_EcAdr+EcEdit*4(a5),a2
	move.w	Ed_VScrol(a5),d7
	neg.w	d7
	move.w	EcTy(a2),d6
	lsr.w	#1,d6
	move.w	Ed_Wy(a5),d5
	add.w	d6,d5
	JJsr	L_AppCentre
	bset	#BitHide,EcFlags(a2)
	bsr	EdReCop
; Efface les d�finitions de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EcCalD	Active,EcEdit
	bsr	Edt_EffWindows
; Met la couleur du fond
; ~~~~~~~~~~~~~~~~~~~~~~
	move.w	ColBack(a5),d1
	EcCall	SColB
; Remet les rainbows
; ~~~~~~~~~~~~~~~~~~
	EcCalD	RainHide,0
; Remet les limites souris
; ~~~~~~~~~~~~~~~~~~~~~~~~
	lea	LimSave(a5),a0
	lea	T_MouXMin(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
; Remet tous les sprites
; ~~~~~~~~~~~~~~~~~~~~~~
	SyCall	RecallM
	SyCall	ReActHs
	SyCall	AMALUFrz
	SyCall	WaitVbl
	SyCall	ActHs
	SyCall	AffHs
; Initialise les touches de fonction AMIGA illegal--> en verif!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	moveq	#0,d1
;	Alea	AmiDef,a1
;.Ami	SyCall	SetFunk
;	move.l	a0,a1
;	addq.w	#1,d1
;	cmp.w	#20,d1
;	bcs.s	.Ami
; Nettoie les touches / Demarre AMAL
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Out	SyCall	ClearKey
	SyCall	AMALUFrz
; Menus >>> Program
; ~~~~~~~~~~~~~~~~~
	bsr	EdM_Program
	movem.l	(sp)+,a0-a4/a6/d0-d7
	rts

;
; Apparition de l'�cran l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Appear
	movem.l	a2-a4/a6/d2-d7,-(sp)
	tst.w	EsFlag(a5)
	beq	.Out
	clr.w	EsFlag(a5)
; Enleve les touches de fonction AMIGA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d1
.Ami	move.l	Buffer(a5),a1
	clr.b	(a1)
	SyCall	SetFunk
	addq.w	#1,d1
	cmp.w	#20,d1
	bcs.s	.Ami
; Enleve tous les sprites
; ~~~~~~~~~~~~~~~~~~~~~~~
	SyCall	AMALFrz
	SyCall	StActHs
	SyCall	StoreM
; Enleve les rainbows
; ~~~~~~~~~~~~~~~~~~~
	EcCalD	RainHide,-1
; Remet le fond!
; ~~~~~~~~~~~~~~
	move.w	Ed_ColB(a5),d1
	EcCall	SColB
; Dessine le fond
; ~~~~~~~~~~~~~~~
	EcCalD	Active,EcEdit
	bsr	Ed_DrawTop
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_DrawWindows
; Apparition de l'�cran
; ~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d2
	EcCalD	EHide,EcEdit
	EcCalD	First,EcEdit
	move.l	T_EcAdr+EcEdit*4(a5),a0
	move.w	Ed_Wy(a5),EcAWY(a0)
	bset	#2,EcAW(a0)
; Fait apparaitre lentement
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	T_EcAdr+EcEdit*4(a5),a2
	move.w	Ed_VScrol(a5),d7
	move.w	#1,d6
	move.w	Ed_Wy(a5),d5
	move.w	Ed_Sy(a5),d0
	lsr.w	#1,d0
	add.w	d0,d5
	JJsr	L_AppCentre
; Limite de la souris
; ~~~~~~~~~~~~~~~~~~~
	lea	T_MouXMin(a5),a0
	lea	LimSave(a5),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	bsr	Ed_LimM
; Affiche le tout!
; ~~~~~~~~~~~~~~~~
	bclr	#BitControl-8,T_Actualise(a5)
	bsr	EdM_Editor
; Flag si peu de memoire...
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.b	#2,Ed_NewAppear(a5)
; Plus de touches
; ~~~~~~~~~~~~~~~
.Out	SyCall	ClearKey
	movem.l	(sp)+,a2-a4/a6/d2-d7
	rts
; Redessine le fond, lors de retour d'accessoire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Redraw
	movem.l	a2-a6/d2-d7,-(sp)
	EcCalD	Active,EcEdit
;	bsr	Ed_DrawTop			Voir si redessin!
;	move.l	Edt_Current(a5),a4
;	move.l	Edt_Prg(a4),a6
;	bsr	Ed_DrawWindows
	EcCalD	First,EcEdit
	bsr	EdReCop
	bsr	Ed_LimM
	movem.l	(sp)+,a2-a6/d2-d7
	rts
; Routine, limite la souris
Ed_LimM	moveq	#EcEdit+1,d3
	move.w	Ed_Sx(a5),d1
	subq.w	#4,d1
	move.w	Ed_Sy(a5),d2
	subq.w	#1,d2
	SyCall	XyHard
	movem.w	d1/d2,-(sp)
	moveq	#EcEdit+1,d3
	moveq	#2,d1
	moveq	#2,d2
	SyCall	XyHard
	movem.w	(sp)+,d3/d4
	SyCall	LimitM
	SyCalD	Show,-1
	rts

;_____________________________________________________________________________
;
;							Messages editeur
;_____________________________________________________________________________
;
; Line not editable
; ~~~~~~~~~~~~~~~~~
Ed_NotEdit
	move.w	#183,d0
	bsr	Ed_GetMessage
	moveq	#100,d0
	bra	Ed_Alert
;
; Line too long
; ~~~~~~~~~~~~~
Ed_LToLong
	move.w	#199,d0			***- Line too long
	bsr	Ed_GetMessage
	moveq	#50,d0
	bra	Ed_Alert
;
; Top of text
; ~~~~~~~~~~~
Ed_CHtE
	move.w	#200,d0			***- Top of text
	bsr	Ed_GetMessage
	moveq	#25,d0
	bra	Ed_Alert
;
; Bottom of text
; ~~~~~~~~~~~~~~
Ed_CBasE
	move.w	#201,d0			***- Bottom of text
	bsr	Ed_GetMessage
	moveq	#25,d0
	bra	Ed_Alert
;
; Mark not set
; ~~~~~~~~~~~~
Ed_NoMark
	moveq	#65,d0
	bra	Ed_Al100
;
; Out of mem tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~
Ed_OofBuf
	bsr	Ed_NewBuf		Reaffiche la ligne!
	move.w	#202,d0			***- Out of buffer space
	bsr	Ed_GetMessage
	move.w	#200,d0
	bra	Ed_Alert
;
; Can't fold procedure
; ~~~~~~~~~~~~~~~~~~~~
Ed_FoE	move.w	#203,d0			***- Not a procedure
Ed_Al100
	bsr	Ed_GetMessage
	moveq	#100,d0
	bra	Ed_Alert

; Out of memory / alert
; ~~~~~~~~~~~~~~~~~~~~~
Ed_OMm	move.w	#204,d0			***- Out of memory
	bsr	Ed_GetMessage
	moveq	#120,d0
	bra	Ed_Alert
;
; Not found
; ~~~~~~~~~
Ed_NoFound
	bsr	Ed_NewBuf
	move.w	#205,d0			***- Not found
	bsr	Ed_GetMessage
	moveq	#100,d0
	bra	Ed_Alert
;
; NOT DONE
; ~~~~~~~~
Ed_NotDone
	bsr	Ed_NewBuf
Ed_NotDone2
	move.w	#206,d0			***- Not done
	bsr	Ed_GetMessage
	moveq	#100,d0
	bra	Ed_Alert

;
; Not an AMOS Program
; ~~~~~~~~~~~~~~~~~~~
Ed_PaAMOS
	bsr	Ed_Close
	move.w	#207,d0			***- Not an amos program
	bsr	Ed_GetMessage
	moveq	#100,d0
	bra	Ed_Alert
;
; Pas de place pour le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PaPlace
	bsr	Ed_Close
	move.w	#208,d0			***- Buffer too small
	bsr	Ed_GetMessage
	moveq	#100,d0
	bra	Ed_Alert

; What bloc?
; ~~~~~~~~~~
Ed_BlocWhat
	moveq	#6,d0
	bra.s	Ed_ProAlert
; Too many windows
; ~~~~~~~~~~~~~~~~
Ed_2ManyWindow
	moveq	#3,d0
	bsr	Ed_GetMessage
	bra.s	Ed_AlertDialog

; Hide window, last window
;~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NoHide
	moveq	#2,d0
	bra	Ed_Al100

; Program already runned
;~~~~~~~~~~~~~~~~~~~~~~~
Ed_AlRunned
	moveq	#12,d0
	bra	Ed_Al100

; No more UNDO
; ~~~~~~~~~~~~
Ed_NoUndo
	moveq	#4,d0
	bra	Ed_Al100
; No more REDO
; ~~~~~~~~~~~~
Ed_NoRedo
	moveq	#5,d0
	bra	Ed_Al100
;
; Appel alerte message indexe
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ProAlert
	bsr	Ed_GetMessage
	moveq	#127,d0
	bra	Ed_Alert
; Branche un message en dialog box
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AlertDialog
	moveq	#127,d0
	bra	Ed_Alert

;_____________________________________________________________________________
;
;						Routines diverses
;_____________________________________________________________________________
;


;____________________________________________________________________
;
;	LOAD / SAVE PROGRAMME
; ___________________________________________________________________
;

;
; LOADING: Demande plus de place / D0= Taille voulue
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_GetPlace
	move.l	d0,d2
; Dialogues
	moveq	#EdD_TooSmall,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne.s	.GtPl2
; Change la taille
	move.l	Prg_StTTexte(a6),d3
	move.l	d2,d0
	JJsr	L_Prg_ChgTTexte
	beq.s	.GtPl1
	rts
; Out of mem, remet l'ancien buffer
.GtPl1	move.l	d3,d0
	JJsr	L_Prg_ChgTTexte
	bne	.GtPl0
; Vraiment out of mem: TOUT petit buffer!
	move.l	#1024,d0
	JJsr	L_Prg_ChgTTexte
; Totalement Out of Mem!
.GtPl0	bsr	Ed_NewBufAff
	bra	Ed_OMm
; Appelle SETBUFFER, et revient!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.GtPl2	clr.b	Prg_Change(a6)
	move.l	d2,d0
	bra.s	Ed_SB
;
; Option SET BUFFER SIZE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SetBuffer
	bsr	Ed_TokCur
	bsr	Edt_ClearVar
	move.l	Prg_StTTexte(a6),d0
Ed_SB
; Boite de dialogue
	move.l	Ed_VDialogues(a5),a2
	move.l	d0,2*4(a2)
	moveq	#EdD_SetBuf,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
	moveq	#1,d0
	moveq	#3,d1
	moveq	#-1,d2
	JJsr	L_Dia_GetValue
	move.l	d1,d0
	and.l	#$FFFFFFFE,d0
	cmp.l	#1024,d0
	bcs	Ed_NotDone
	move.l	d0,d2
	move.l	Prg_StTTexte(a6),d3
	cmp.l	d3,d2
	beq	Ed_NotDone
; Peut-on recopier le buffer?
	bcs.s	.PaCop
; Essaie de changer sans effacer le programme courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_StTTexte(a6),-(sp)
	move.l	Prg_StMini(a6),-(sp)
	move.l	Prg_StHaut(a6),-(sp)
	move.l	Prg_StBas(a6),-(sp)
	clr.l	Prg_StTTexte(a6)	Plus rien
	move.l	d2,d0			Reserve la nouvelle
	JJsr	L_Prg_ChgTTexte
	beq.s	.PaCop
	move.l	(sp)+,a0		Recopie le programme dans le buffer
	move.l	(sp)+,d0
	sub.l	a0,d0
	moveq	#0,d1
	bsr	Ed_StoBlock
	move.l	(sp)+,a1		Libere le precedent
	move.l	(sp)+,d0
	SyCall	SyFree
	bra.s	.Out
; Change le buffer en effacant le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PaCop	movem.l	d2/d3,-(sp)
	bsr	Ed_Saved
	bsr	Ed_New2
	movem.l	(sp)+,d2/d3
	move.l	d2,d0
	JJsr	L_Prg_ChgTTexte
	beq.s	.OMm
; Fini!
.Out	JJsr	L_Prg_SetBanks
	bsr	Ed_NewBufAff
	rts
; Out of mem!
; ~~~~~~~~~~~
.OMm	move.l	d3,d0
	JJsr	L_Prg_ChgTTexte
	bne.s	.OMmX
	move.l	#1024,d0
	JJsr	L_Prg_ChgTTexte
.OMmX	bsr	Ed_NewBufAff
	bra	Ed_OMm


; ___________________________________________________________________
;
;	ROUTINES AFFICHAGE / POSITIONNEMENT FENETRES
; ___________________________________________________________________
;
; Affiche les sliders
; ~~~~~~~~~~~~~~~~~~~
Ed_AffSlV
	tst.w	Edt_WindTy(a4)
	beq.s	.Skip
	bsr	Edt_SlUpdateY
	lea	Edt_SlV(a4),a0
	moveq	#0,d0
	JJsrR	L_Sl_Draw,a1
.Skip	rts

;
; Curseur ON/OFF
; ~~~~~~~~~~~~~~
Ed_CuOn
	movem.l	d0/a0/a1,-(sp)
	lea	ChCuOn(pc),a1
	WiCall	Print
	movem.l	(sp)+,d0/a0/a1
	rts
Ed_CuOff
	movem.l	d0/a0/a1,-(sp)
	lea	ChCuOff(pc),a1
	WiCall	Print
	clr.b	Ed_CuFlag(a5)
	movem.l	(sp)+,d0/a0/a1
	rts

;
; Reaffichage de la ligne courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EALiCu
	move.w	Edt_YCu(a4),d1
	bsr	Ed_EALigne
	bra	Ed_Loca

;
; Routine: centre la fenetre editeur sur la position du curseur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Cent
	bset	#EtA_X,Edt_EtatAff(a4)
	moveq	#15,d1
	move.w	Edt_XCu(a4),d0
	sub.w	Edt_XPos(a4),d0
	bcs.s	.AGoch
	cmp.w	Edt_WindTx(a4),d0
	bcc.s	.ADroi
	bra	Ed_Loca
; Curseur trop � droite
.ADroi	sub.w	Edt_WindTx(a4),d0
	addq.w	#1,d0
	add.w	d0,Edt_XPos(a4)
	bra	Ed_AffBuf
; Curseur trop � gauche
.AGoch	add.w	d0,Edt_XPos(a4)
	bra	Ed_AffBuf

;
; Positionne l'�cran en X
; ~~~~~~~~~~~~~~~~~~~~~~~
Ed_GotoX
	cmp.w	Edt_XCu(a4),d0
	beq.s	.Skip
	move.w	Edt_XPos(a4),d1
	bsr	Ed_SetX
	cmp.w	Edt_XPos(a4),d1
	beq	Ed_EALiCu
	bne	Ed_AffBuf
.Skip	rts
;
; Positionne l'ecran en Y
; ~~~~~~~~~~~~~~~~~~~~~~~
Ed_GotoY
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	cmp.w	d0,d1
	beq.s	.Skip
	bsr	Ed_TokCur
	move.w	Edt_YPos(a4),d1
	bsr	Ed_SetY
	cmp.w	Edt_YPos(a4),d1
	beq	Ed_Loca
	bne	Ed_NewBuf
.Skip	rts
;
; Centre l'ecran en X, sans affichage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SetX
	movem.w	d0-d1,-(sp)
	bset	#EtA_X,Edt_EtatAff(a4)
	move.w	d0,Edt_XCu(a4)
	clr.w	d1
	cmp.w	#70,d0
	bcs.s	EdSx2
EdSx1	add.w	#20,d1
	sub.w	#20,d0
	cmp.w	#60,d0
	bcc.s	EdSx1
EdSx2	move.w	d1,Edt_XPos(a4)
	movem.w	(sp)+,d0-d1
	rts
;
; Centre l'ecran en Y, sans affichage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SetY
	movem.w	d0/d1,-(sp)
	bset	#EtA_Y,Edt_EtatAff(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
; Limite en bas
	cmp.w	Prg_NLigne(a6),d0
	bls.s	.Sk1
	move.w	Prg_NLigne(a6),d0
.Sk1	move.w	d0,d1
	sub.w	Edt_YPos(a4),d1
	bcs.s	.Remonte
	cmp.w	Edt_WindTy(a4),d1
	bcc.s	.Descend
	bra.s	.Out
; Remonte la fenetre
.Remonte
	add.w	d1,Edt_YPos(a4)
	bra.s	.Out
; Descend la fenetre
.Descend
	sub.w	Edt_WindTy(a4),d1
	addq.w	#1,d1
	add.w	d1,Edt_YPos(a4)
; Position du curseur
.Out	sub.w	Edt_YPos(a4),d0
	move.w	d0,Edt_YCu(a4)
	movem.w	(sp)+,d0/d1
	rts

;
; Centre l'ecran en X et Y, gere les procedures....
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0= adresse dans programme
;	D0= X curseur
;
Ed_SetXY
	clr.l	Prg_AdEProc(a6)
	move.w	d0,Prg_XEProc(a6)
	move.w	d0,-(sp)
	bsr	Ed_FindA
	tst.l	d1
	beq.s	EdSxy1
	move.l	a0,Prg_AdEProc(a6)
	clr.w	(sp)
EdSxy1	bsr	Ed_SetY
	move.w	(sp)+,d0
	bsr	Ed_SetX
	bsr	Ed_AverFin
	bra	Ed_NewBuf

;
; Routine situe le label AVANT et APRES LCour: D1= avant / D2= apres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NLab
	move.w	Edt_YPos(a4),d3
	add.w	Edt_YCu(a4),d3
	moveq	#0,d1
	moveq	#-1,d2
	bsr	Ed_FindL
	bra.s	.NLab1
.NLab0	bsr	Ed_NextL
.NLab1	beq.s	.NLab3
	addq.l	#1,d2
	move.w	2(a0),d0
	cmp.w	#_TkProc,d0
	beq.s	.NLab2
	cmp.w	#_TkLab,d0
	bne.s	.NLab0
.NLab2	cmp.w	d3,d2
	beq.s	.NLab0
	bhi.s	.NLab3
	move.w	d2,d1
	bra.s	.NLab0
.NLab3	rts

;
; Locate le curseur dans l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Loca
	move.l	d2,-(sp)
	move.w	Edt_YCu(a4),d2
	move.w	Edt_XCu(a4),d1
	sub.w	Edt_XPos(a4),d1
	ext.l	d1
	ext.l	d2
	WiCall	Locate
	move.l	(sp)+,d2
	rts

;
; Affiche le caractere ECRAN D1 de tout le buffer d'edition
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AffBufCar
	moveq	#0,d2
.ABufC	bsr	Ed_ACar
	addq.w	#1,d2
	cmp.w	Edt_WindTy(a4),d2
	bcs.s	.ABufC
	bra	Ed_Loca

;
; Imprime le caractere ECRAN D1 de la ligne D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ACar
	movem.l	d0-d7/a0-a1,-(sp)
; Locate en debut de ligne
	move.w	d1,d4
	move.w	d2,d5
	WiCall	Locate
; Pointe la ligne dans le buffer
	move.w	d5,d0
	lsl.w	#8,d0
	move.l	Edt_BufE(a4),a0
	lea	0(a0,d0.w),a0
	add.w	Edt_XPos(a4),d4
	moveq	#" ",d6
	cmp.w	(a0)+,d4
	bcc.s	.NoBloc
	move.b	0(a0,d4.w),d6
; Machine le bloc
	move.w	Edt_YBloc(a4),d0
	bmi	.NoBloc
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	move.w	Edt_XBloc(a4),d2
	move.w	Edt_XCu(a4),d3
	cmp.w	d0,d1
	bcs.s	.Sw
	bhi.s	.Sk2
	cmp.w	d2,d3
	beq.s	.NoBloc
	bcc.s	.Sk2
.Sw	exg	d0,d1
	exg	d2,d3
.Sk2	cmp.w	d0,d5
	bcs.s	.NoBloc
	beq.s	.DBloc
	cmp.w	d1,d5
	bcs.s	.InBloc
	bhi.s	.NoBloc
	cmp.w	d3,d4
	bcc.s	.NoBloc
	bra.s	.InBloc
.DBloc	cmp.w	d1,d5
	beq.s	.LBloc
	cmp.w	d2,d4
	bcs.s	.InBloc
	bra.s	.NoBloc
.LBloc	cmp.w	d2,d4
	bcs.s	.NoBloc
	cmp.w	d3,d4
	bcc.s	.NoBloc
; Dessin en inverse
.InBloc	moveq	#17,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	move.w	d6,d1
	WiCall	ChrOut
	moveq	#18,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	bra.s	.Out
; Dessin normal
.NoBloc	move.w	d6,d1
	WiCall	ChrOut
; Ouf!
.Out	movem.l	(sp)+,d0-d7/a0-a1
	rts

; Detokenise le buffer et raffiche les infos.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NewBufAff
	move.b	#EtA_BAll,Edt_EtatAff(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
; Detokenise et affiche le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NewBuf
	move.w	Edt_Window(a4),d1
	WiCall	QWindow
	bsr	Ed_BufUntok
; Affiche tout le buffer d'edition
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_AffBuf
; Enleve tous les avertissements
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_AllAverFin
; Reaffiche les lignes
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d1
.Loop	bsr	Ed_EALigne
	addq.w	#1,d1
	cmp.w	Edt_WindTy(a4),d1
	bcs.s	.Loop
;	move.b	#2,Edt_ASlY(a4)			Affichage du slider
;	move.b	#EtA_BAll,Edt_EtatAff(a4)	Affichage de l'etat
	bra	Ed_Loca
;
; Imprime la ligne du buffer D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EALigne
	movem.l	d0-d6/a0-a2,-(sp)	* Efface
	moveq	#-1,d6
	bra.s	EALi
Ed_ALigne
	movem.l	d0-d6/a0-a2,-(sp)	* Affiche seulement
	moveq	#0,d6
EALi
; Locate en debut de ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	d1,d6
	move.w	d1,d2
	moveq	#0,d1
	ext.l	d2
	WiCall	Locate
; Pointe la ligne dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	d6,d0
	lsl.w	#8,d0
	move.l	Edt_BufE(a4),a2
	lea	0(a2,d0.w),a2
	move.w	Edt_XPos(a4),d4
	move.w	(a2)+,d0		* Longueur de la ligne
	cmp.w	d0,d4
	bcc	.End
	lea	0(a2,d4.w),a2		* Pointe le debut
	move.w	d4,d5
	add.w	Edt_WindTx(a4),d5	* Pointe la fin
	cmp.w	d0,d5
	bls.s	.Sk1
	move.w	d0,d5
.Sk1	move.w	d5,d0
	sub.w	d4,d0
	cmp.w	Edt_WindTx(a4),d0
	bcs.s	.Sz
	bclr	#31,d6
.Sz
; Un bloc en route?
; ~~~~~~~~~~~~~~~~~
	add.w	Edt_YPos(a4),d6
	move.w	Edt_YBloc(a4),d0
	bmi	.NoBloc
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	move.w	Edt_XBloc(a4),d2
	move.w	Edt_XCu(a4),d3
	cmp.w	d0,d1
	bcs.s	.Sw
	bhi.s	.Sk2
	cmp.w	d2,d3
	beq	.NoBloc
	bcc.s	.Sk2
.Sw	exg	d0,d1
	exg	d2,d3
.Sk2	cmp.w	d5,d3
	bls.s	.SkQ
	move.w	d5,d3
.SkQ	cmp.w	d0,d6
	bcs	.NoBloc
	beq.s	.DBloc
	cmp.w	d1,d6
	bhi	.NoBloc
	beq.s	.EBloc
; Au milieu du bloc, TOUT en inverse
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	.Inverse
	move.l	a2,a1
	move.w	d5,d1
	sub.w	d4,d1
	bsr	.Print
	bsr	.Normal
	bra	.End
; Bloc sur une seule ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~
.DEBloc	cmp.w	d5,d2
	bcc	.NoBloc
	move.w	d2,d1
	sub.w	d4,d1
	bls.s	.S1
	move.l	a2,a1
	add.w	d1,a2
	add.w	d1,d4
	bsr	.Print
.S1	bsr	.Inverse
	move.w	d3,d1
	sub.w	d4,d1
	bls.s	.S2
	move.l	a2,a1
	add.w	d1,d4
	add.w	d1,a2
	bsr	.Print
.S2	bsr	.Normal
	bra.s	.NoBloc
; Au debut du bloc, passe en inverse
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.DBloc	cmp.w	d1,d6
	beq.s	.DEBloc
	cmp.w	d5,d2
	bcc.s	.NoBloc
	move.w	d2,d1
	sub.w	d4,d1
	bls.s	.Sk3
	move.l	a2,a1
	add.w	d1,a2
	add.w	d1,d4
	bsr	.Print
.Sk3	bsr	.Inverse
	move.w	d5,d1
	sub.w	d4,d1
	bls.s	.Sk4
	move.l	a2,a1
	bsr	.Print
.Sk4	bsr	.Normal
	bra	.End
; A la fin du bloc, passe en normal
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.EBloc	cmp.w	d0,d6
	beq.s	.DEBloc
	bsr	.Inverse
	move.w	d3,d1
	sub.w	d4,d1
	bls.s	.Sk5
	move.l	a2,a1
	add.w	d1,a2
	add.w	d1,d4
	bsr	.Print
.Sk5	bsr	.Normal
; Pas de bloc, NORMAL!
; ~~~~~~~~~~~~~~~~~~~~
.NoBloc	move.w	d5,d1
	sub.w	d4,d1
	bls.s	.End
	move.l	a2,a1
	bsr	.Print
; Efface jusqu'� la fin de la ligne?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.End	tst.l	d6
	bpl.s	.Sk7
	WiCalD	ChrOut,7
.Sk7
; Fini!
; ~~~~~
	movem.l	(sp)+,d0-d6/a0-a2
	rts
.Inverse
	moveq	#17,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	rts
.Normal
	moveq	#18,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	rts
.Print
	move.b	0(a1,d1.w),d0
	clr.b	0(a1,d1.w)
	move.w	d0,-(sp)
	WiCall	Print
	move.w	(sp)+,d0
	move.b	d0,0(a1,d1.w)
	rts




;_____________________________________________________________________________
;
;						STOCKAGE DU PROGRAMME
;_____________________________________________________________________________
;

;
; DELETION LIGNE DANS PROGRAMME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Retourne 	0: si ligne deletee
;			1: si ligne non deletee
Ed_DelLiCu
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	move.w	d1,-(sp)
; Stocke dans UNDO
	bsr	Ed_LCourant
	bne	Ed_NotEdit
	move.w	Edt_XCu(a4),-(sp)
	clr.w	Edt_XCu(a4)
	move.l	Prg_PUndo(a6),a2
	ext.l	d0
	bsr	Un_CLine
	bne.s	.SkipU
	move.b	#$84,(a2)
.SkipU	move.w	(sp)+,Edt_XCu(a4)
	move.w	(sp)+,d1
; Enleve dans le programme
	bsr	Ed_DeLigne
	move.w	d0,-(sp)
	bne.s	.RetV3
; Enleve dans l'affichage
	WiCalD	ChrOut,23
	bsr	Ed_LCourant
	lea	-2(a0),a0
	lea	256(a0),a1
	move.w	Edt_WindTy(a4),d0
	mulu	#256,d0
	add.l	Edt_BufE(a4),d0
	move.l	d0,a2
	sub.l	a1,d0
	bls.s	.RetV2
	lsr.w	#2,d0
	subq.w	#1,d0
.RetV1:	move.l	(a1)+,(a0)+
	dbra	d0,.RetV1
.RetV2:	clr.w	-256(a2)
.RetV3	move.w	Edt_YPos(a4),d0
	move.w	Edt_WindTy(a4),d1
	subq.w	#1,d1
	add.w	d1,d0
	bsr	Ed_Untok
	bsr	Ed_EALigne
	move.b	#SlDelai,Edt_ASlY(a4)
	bsr	Ed_Loca
	move.w	(sp)+,d0
	rts

;
; Joint la ligne et celle du dessus!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_Join	tst.w	Edt_YCu(a4)
	beq	.Out
	tst.w	Edt_XCu(a4)
	bne	.Out
	addq.b	#1,Ed_FUndo(a5)

	bsr	Ed_LCourant
	lea	-256(a0),a1
; Peut-on joindre les lignes?
	tst.w	-2(a0)
	beq.s	.Vide
	tst.b	255-2(a1)		Previous ligne editable?
	bne	Ed_NotEdit
; Ok!
.Vide	move.w	-2(a1),d1
	move.w	d0,d2
	add.w	d1,d2
	cmp.w	#250,d2			Line too long!
	bcc	Ed_LToLong
	clr.w	-2(a0)
	move.w	d2,-2(a1)
	lea	0(a1,d1.w),a1
	subq.w	#1,d0
	bmi.s	.Bac1
.Bac0:	move.b	(a0)+,(a1)+
	dbra	d0,.Bac0
.Bac1:	move.w	d1,-(sp)
; Efface la ligne actuelle
	bsr	Ed_DelLiCu
; Ligne non effacee: c'est la derniere
	tst.w	d0
	beq.s	.Skk
	move.w	Prg_NLigne(a6),d1
	beq.s	.Skk
	subq.w	#1,d1
	move.w	d1,d0
	bsr	Ed_FindL		Est-ce une derniere ligne
	beq.s	.Skk
	cmp.l	#$02000000,(a0)		Instruction vide?
	bne.s	.Skk
	bsr	Ed_DeLigne		On l'enleve!
; Affiche la pr�c�dente
.Skk	bsr	Ed_ChtT
	addq.w	#1,Edt_LEdited(a4)
	move.b	#SlDelai,Edt_ASlY(a4)
	move.w	(sp)+,Edt_XCu(a4)
	bsr	Ed_EALiCu
	bsr	Ed_Cent
; UNDO
	or.b	#%11,Ed_SCallFlags(a5)
	subq.b	#1,Ed_FUndo(a5)
	bsr	Ed_LCourant
	move.l	Prg_PUndo(a6),a2
	ext.l	d0
	bsr	Un_CLine
	bne.s	.Out
	move.b	#$88,(a2)
.Out	rts

;
; RETURN >>> recupere la droite de la ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Return
; Fait du bruit
	moveq	#"D",d0
	bsr	Ed_SamPlay
Ed_ReturnQuiet
; A gauche de la ligne
	tst.w	Edt_XCu(a4)
	beq	.Goch
; Bas du buffer= stockage temporaire
	move.l	Prg_StMini(a6),a2	* Adresse dans STMINI
	clr.w	(a2)+			* CHAINE VIDE!
	clr.w	(a2)
	move.l	Prg_StBas(a6),a0
	lea	-256(a0),a0
	cmp.l	a0,a2
	bcc	Ed_OofBuf
; Gestion UNDO
	bsr	Ed_LCourant
	bne	.PaEd
	move.l	Prg_PUndo(a6),a1
	ext.l	d0
	bsr	Un_CLine
	bne.s	.Skip
	move.b	#$87,(a1)
.Skip	addq.b	#1,Ed_FUndo(a5)
; Copie la droite de la ligne
	bsr	Ed_LCourant
	move.w	d1,d2
	cmp.w	d0,d2
	bcs.s	.RtI1
	move.w	d0,d2
.RtI1:	move.w	d2,-2(a0)		* Change la taille ligne origine
.RtI2:	cmp.w	d0,d1
	bcc.s	.RtI3
	move.b	(a1)+,(a2)+
	addq.w	#1,d1
	bra.s	.RtI2
.RtI3:	clr.b	(a2)
; Tokenise
	move.w	Prg_NLigne(a6),-(sp)
	moveq	#1,d0			Une ligne de plus si a la fin!
	bsr	Ed_TokStok2
; D�but de la ligne suivante
	bsr	Ed_CBasT
	bsr	Ed_DLigneT
; Insere la ligne, si pas � la fin du texte
	move.w	(sp)+,d2
	cmp.w	Prg_NLigne(a6),d2
	bne.s	.Sk
	bsr	Ed_InsLine
; Recopie la nouvelle
.Sk	bsr	Ed_LCourant
	move.l	a0,a2
	clr.b	255-2(a2)		La ligne est editable!
	clr.w	d0
	move.l	Prg_StMini(a6),a1
	lea	2(a1),a1
.RtI4:	move.b	(a1)+,d1
	beq.s	.RtI5
	move.b	d1,(a2)+
	addq.w	#1,d0
	bra.s	.RtI4
.RtI5:	move.w	d0,-2(a0)
; Affiche la nouvelle ligne/revient a l'editeur
	addq.w	#1,Edt_LEdited(a4)
	bsr	Ed_EALiCu
	subq.b	#1,Ed_FUndo(a5)
	rts
; A gauche de la ligne: INS puis bas
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Goch	bsr	Ed_InsLine
	bsr	Ed_CBasT
	bra	Ed_DLigneT
; Ligne non editable
; ~~~~~~~~~~~~~~~~~~
.PaEd	bsr	Ed_CBasT
	bsr	Ed_DLigneT
	bra	Ed_InsLine

;
; Insere une ligne � la position du curseur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_InsLine
; Ligne courante
	bsr	Ed_TokCur
; Tokenise une ligne vide
	move.l	Ed_BufT(a5),a1
	lea	128(a1),a0
	clr.b	(a0)
	bsr	Tokenise
; Va l'inserer dans le texte
	move.l	Ed_BufT(a5),a1
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	moveq	#-1,d0
	bsr	Ed_Stocke
	bne	Ed_OofBuf
; Gestion UNDO
	bsr	Un_Debut
	bne.s	.Skip
	move.b	#$06,(a2)
; Une ligne de plus
.Skip	addq.w	#1,Prg_NLigne(a6)
	move.b	#SlDelai,Edt_ASlY(a4)
	bsr	Ed_NewBuf
	rts

;
; TOKENISE / STOCKE la ligne courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_TokCur
	tst.w	Edt_LEdited(a4)
	beq.s	.Skip
	movem.l	a0-a1/d0-d1,-(sp)
	moveq	#0,d0
	bsr.s	Ed_TokStok2
	bsr	Ed_Loca
	move.l	a4,a0
	moveq	#%01,d0
	bsr	Ed_Splitted
	movem.l	(sp)+,a0-a1/d0-d1
.Skip	rts

Ed_TokStok
	tst.w	Edt_LEdited(a4)
	beq	TokX
Ed_TokStok2
	movem.l	d2-d7/a2,-(sp)
	move.w	d0,d2
; Va tokeniser la ligne
; ~~~~~~~~~~~~~~~~~~~~~
	clr.w	Edt_LEdited(a4)
	bsr	Ed_LCourant	* Adresse de la ligne courante
	clr.b	0(a0,d0.w)	* Marque la fin
	moveq	#0,d0
	move.l	Ed_BufT(a5),a1	* Buffer de tokenisation
	bsr	Tokenise
	bmi	Ed_LToLong
	add.w	d0,d2
; Stocke la ligne
; ~~~~~~~~~~~~~~~
	move.l	Ed_BufT(a5),a1
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	moveq	#0,d0
	bsr	Ed_Stocke
	bne	Ed_OofBuf
	move.l	a0,a2		Adresse ligne dans le programme
	add.w	d1,d2		Une ligne de plus???
; Copie l'ancienne ligne dans le buffer de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_LCourant
	move.l	Ed_BufT(a5),a1
	move.w	d0,d5
	subq.w	#1,d0
	bmi.s	.NC
.C1	move.b	(a0)+,(a1)+
	dbra	d0,.C1
.NC
; Une ligne de plus, si � la fin, et non vide
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d6
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	cmp.w	Prg_NLigne(a6),d1
	bne.s	.Rien
	tst.w	d2
	beq.s	.Rien
	moveq	#1,d6
	addq.w	#1,Prg_NLigne(a6)
.Rien
; Reaffiche la ligne tokenisee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_LCourant
	lea	-2(a0),a1
	move.l	a2,a0
	moveq	#0,d0
	bsr	Detok
	move.w	Edt_YCu(a4),d1
	bsr	Ed_EALigne
; Gestion du UNDO
; ~~~~~~~~~~~~~~~
	bsr	Un_Debut
	bne.s	.NoUndo
	move.b	#$85,(a2)
	bsr	Ed_LCourant
	move.l	a0,a1
	move.w	d0,d7
	add.w	d5,d0
	moveq	#8,d1
	add.w	d0,d1
	move.l	d1,d0
	SyCall	MemFastClear
	move.w	d1,(a0)
	add.l	d1,Prg_TUndo(a6)
	move.w	2(a2),2(a0)
	move.l	a0,2(a2)
	move.w	d6,4(a0)
; Copie l'ancienne ligne
	move.l	Ed_BufT(a5),a2
	lea	6(a0),a0
	move.b	d5,(a0)+
	subq.w	#1,d5
	bmi.s	.Sk1
.Co1	move.b	(a2)+,(a0)+
	dbra	d5,.Co1
.Sk1
; Copie la nouvelle
	move.b	d7,(a0)+
	subq.w	#1,d7
	bmi.s	.Sk2
.Co2	move.b	(a1)+,(a0)+
	dbra	d7,.Co2
.Sk2
.NoUndo
; Copie du flag double precision
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.b	MathFlags(a5),Prg_MathFlags(a6)
; Ok!
; ~~~
	movem.l	(sp)+,d2-d7/a2
TokX	rts


; DETOKENISE TOUT LE BUFFER
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BufUntok
	clr.w	-(sp)
	move.w	Edt_YPos(a4),d0
	bsr	Ed_FindL
	bra.s	.BUnt1
.BUnt0	bsr	Ed_NextL
.BUnt1	move.w	(sp),d1
	move.l	Edt_BufE(a4),a1
	lsl.w	#8,d1
	lea	0(a1,d1.w),a1
	clr.w	(a1)
	clr.b	255(a1)			Ligne editable
	tst.w	d0
	beq.s	.BUnt2
	JJsrP	L_Tk_EditL,a2
	bne.s	.Edit
	move.b	#-1,255(a1)		Ligne NON editable!
.Edit	moveq	#0,d0
	bsr	Detok
.BUnt2	addq.w	#1,(sp)
	move.w	(sp),d0
	cmp.w	Edt_WindTy(a4),d0
	bcs.s	.BUnt0
	addq.l	#2,sp
	rts

;
; DETOKENISE la LIGNE D0 dans le BUFFER ligne D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Untok
	movem.l	d0-d1/a0-a2,-(sp)
	move.l	Edt_BufE(a4),a1
	lsl.w	#8,d1
	lea	0(a1,d1.w),a1
	clr.w	(a1)
	clr.b	255(a1)
	move.l	a1,-(sp)
	bsr	Ed_FindL
	move.l	(sp)+,a1
	beq.s	.Fin
	JJsrR	L_Tk_EditL,a2
	bne.s	.Edit
	move.b	#-1,255(a1)
.Edit	moveq	#0,d0
	bsr	Detok
.Fin	movem.l	(sp)+,d0-d1/a0-a2
	rts

;
; NEW
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_New
	bsr	Ed_TokCur
	bsr	Ed_Saved
Ed_New2
	bsr	EdM_Program
	moveq	#1,d0
	tst.b	Ed_Zappeuse(a5)
	beq.s	.No
	moveq	#0,d0
.No	JJsr	L_Prg_New
	bsr	Edt_New
	bsr	Ed_NewBufAff
	rts
;
; New du contenu d'une fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_New
; Editeur par devant
	tst.b	Ed_Zappeuse(a5)
	bne.s	.Skp
	EcCalD	Last,0
	bsr	EdReCop
.Skp	EcCalD	Active,EcEdit
; Init des donn�es editeur
	lea	Edt_SInit(a4),a0
	moveq	#(Edt_EInit-Edt_SInit)/2-1,d0
.Loop	clr.w	(a0)+
	dbra	d0,.Loop
	move.w	#-1,Edt_YBloc(a4)
	move.w	#-1,Edt_YOldBloc(a4)
; Init des donnees programme
	bsr	Prg_UndoCreate		Effacement / Creation du buffer undo
	bsr	Prg_MarkRaz
	clr.b	MathFlags(a5)		Simple precision par defaut
	rts

;
; INSERE LE BLOC A0 LONGUEUR D0 EN POSITION D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_StoBlock
	movem.l	a2-a3/d2-d7,-(sp)
	move.l	a0,a1
	move.l	d0,d2
	move.w	d1,d0
	moveq	#0,d7			Ne pas changer les marques
	bsr	Ed_FindL
	bra	StoI
;
; STOCKE LA LIGNE (A1) EN POSITION D1, INSERT D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Retour:	A0=	Ligne tokenisee
;		A1=
;		D0=	Erreur?
;		D1=	Flag un ligne de plus!
Ed_Stocke
	movem.l	a2-a3/d2-d7,-(sp)

	move.w	d0,d7
	move.w	d1,d6
	moveq	#0,d5

; Longueur de la nouvelle ligne
	moveq	#0,d2
	move.b	(a1),d2
	lsl.w	#1,d2
; Pointe la ligne courante
	move.w	d1,d0
	bsr	Ed_FindL		Cherche l'adresse ---> A0
	moveq	#0,d1
	move.b	(a0),d1
	lsl.l	#1,d1			Derniere ligne?
	beq.s	StoD
	tst.w	d7			Insertion
	bne.s	StoI

; Remplacement d'une ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w	#_TkProc,2(a0)		On est sur une procedure fermee???
	bne.s	.Stck1
	tst.w	10(a0)
	bmi	StoClo
.Stck1	cmp.l	d1,d2
	beq	StoCop
	bhi.s	StoR5
* Nouvelle plus petite
	move.l	a0,a2
	sub.l	d2,d1
	add.l	d1,a0
	move.l	a0,a3
	move.l	Prg_StBas(a6),d0
	bra.s	StoR2
StoR1	move.w	-(a2),-(a3)
StoR2	cmp.l	d0,a2
	bhi.s	StoR1
	move.l	a3,Prg_StBas(a6)
	move.l	d1,d0
	bra.s	StoCop
* Nouvelle plus grande
StoR5	move.l	d2,d0
	sub.l	d1,d0
	bra.s	StoI0

; Derniere ligne: pas une ligne vide, si non insert!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StoD	cmp.w	#4,d2			Ligne vide= 4 octets
	bne.s	StoI
	move.l	a0,d4
	tst.w	d7
	beq.s	StoV
; Insersion ligne / Block
; ~~~~~~~~~~~~~~~~~~~~~~~
StoI	move.l	d2,d0
	moveq	#1,d5
StoI0	move.l	Prg_StBas(a6),a2
	move.l	a2,a3
	sub.l	d0,a3
	cmp.l	Prg_StMini(a6),a3
	bls.s	StoMem
	move.l	a3,Prg_StBas(a6)
	bra.s	StoI2
StoI1	move.w	(a2)+,(a3)+		* Fait de la place
StoI2	cmp.l	a0,a2
	bcs.s	StoI1
	sub.l	d0,a0
; Copie de la ligne
; ~~~~~~~~~~~~~~~~~
StoCop	move.l	a0,a2
	move.l	a0,d4
	lsr.l	#1,d2
StoC	move.w	(a1)+,(a2)+		* Copie la ligne
	subq.l	#1,d2
	bne.s	StoC
; Change les marks
; ~~~~~~~~~~~~~~~~
	tst.w	d7
	beq.s	.Skip
	move.w	d6,d0
	moveq	#1,d1
	bsr	Ed_MarksChange
.Skip
; Nettoie les variables (si pas MERGE!)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bset	#EtA_Free,Edt_EtatAff(a4)
	move.b	#1,Prg_Change(a6)
	move.b	#1,Prg_StModif(a6)
StoV	move.l	d5,d1
	move.l	d4,a0
	moveq	#0,d0
	bra.s	StX
; Procedure fermee
StoClo	moveq	#-1,d0
	bra.s	StX
; Out of mem
StoMem:	moveq	#1,d0
StX	movem.l	(sp)+,a2-a3/d2-d7
	rts
;
; ENLEVE UN CHUNK DE PROGRAMME
;	D1=	Ligne debut
;	D0=	Longueur chunk
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DelChunk
	move.l	d0,-(sp)
	move.w	d1,d0
	bsr	Ed_FindL
	beq.s	.Out
	move.l	a0,a1
	add.l	(sp),a1
	bsr	Ed_StDelChunk
.Out	addq.l	#4,sp
	rts

; ENLEVE LA LIGNE D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Retourne	0: si ligne deletee (NLIGNE=NLIGNE-1)
;			1: si ligne non deletee
;			-1 si ligne non editable
Ed_DeLigne
	move.w	d1,-(sp)
	move.w	d1,d0
	bsr	Ed_FindL
	beq.s	.DelLL
; Dans procedure. Ferm�e?
	cmp.w	#_TkProc,2(a0)		* Pas si procedure fermee!
	bne.s	.DelL0
	tst.w	10(a0)
	bmi.s	.DelLN
; Enleve la ligne
.DelL0	moveq	#0,d0
	move.b	(a0),d0
	lsl.w	#1,d0
	lea	0(a0,d0.w),a1
	bsr	Ed_StDelChunk
; Marks
	move.w	(sp),d0
	moveq	#-1,d1
	bsr	Ed_MarksChange
; Nombre de lignes
	subq.w	#1,Prg_NLigne(a6)
.DelLX	moveq	#0,d0
	bra.s	.Out
.DelLN	moveq	#-1,d0
	bra.s	.Out
.DelLL	moveq	#1,d0
.Out	addq.l	#2,sp
	rts
; Enleve le chunk de programme A0-A1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_StDelChunk
	move.l	a2,-(sp)
	move.l	Prg_StBas(a6),a2
	move.l	a0,d1
	bra.s	DelL2
DelL1:	move.w	-(a0),-(a1)
DelL2:	cmp.l	a2,a0
	bhi.s	DelL1
	move.l	a1,Prg_StBas(a6)
; Flags
	move.b	#1,Prg_Change(a6)
	move.b	#1,Prg_StModif(a6)
	bset	#EtA_Free,Edt_EtatAff(a4)
	move.l	(sp)+,a2
	rts

;
; TROUVE L'ADRESSE DE LA LIGNE D0 (coord editeur)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Si au milieu d'une procedure, AD ---> ADPROC
;
Ed_FindL
	move.l	a1,-(sp)
	move.l	Prg_StBas(a6),a0
	JJsrR	L_Tk_FindL,a1
	move.l	a0,Edt_CurLigne(a4)
	move.l	a1,Edt_DebProc(a4)
	move.l	(sp)+,a1
	tst.w	d0
	rts
; Trouve la ligne suivante
; ~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NextL
	move.l	a1,-(sp)
	move.l	Edt_CurLigne(a4),a0
	JJsrR	L_Tk_FindN,a1
	move.l	a0,Edt_CurLigne(a4)
	move.l	a1,Edt_DebProc(a4)
	move.l	(sp)+,a1
	tst.w	d0
	rts

; Trouve la taille de la CURLIGNE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SizeL
	move.l	Edt_CurLigne(a4),a0
	JJsrP	L_Tk_SizeL,a1
	rts

; La ligne courante est-elle editable?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EditL
	move.l	Edt_CurLigne(a4),a0
	JJsrP	L_Tk_EditL,a1
	rts

;
; TROUVE LE NUMERO ET LE DEBUT DE LA LIGNE A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; D0-> Numero
; D1-> Adresse debut proc
;
Ed_FindA
	movem.l	a1/a2,-(sp)
	move.l	Prg_StBas(a6),a1
	JJsrR	L_Tk_FindA,a2
	movem.l	(sp)+,a1/a2
	rts
;
; Ramene l'adresse de la ligne sous le curseur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; A0= adresse
; A1= lettre sous le curseur
; D0= longueur
; D1= position curseur
;
Ed_LCourant:
	move.w	Edt_YCu(a4),d0
	lsl.w	#8,d0
	move.l	Edt_BufE(a4),a0
	lea	0(a0,d0.w),a0
	move.w	(a0)+,d0
	move.w	Edt_XCu(a4),d1
	lea	0(a0,d1.w),a1
	tst.b	255-2(a0)
	rts


;____________________________________________________________________
;
;						GESTION WINDOWS
;____________________________________________________________________
;
;
; Back to Workbench
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Wb	EcCalD	AMOS_WB,0
	rts


; ZAP: Ferme un fenetre contenant un programme donne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_CloseName
	bsr	Edt_AccAdr		Deja en memoire?
	beq.s	.Fini
	move.l	a0,a4			Active la fenetre
	move.l	Edt_Prg(a4),a6
	JJsr	L_Prg_DejaRunned	En train de tourner?
	bne.s	.Fini
	bsr	Ed_CloseWindow		Ferme la fenetre
	bra.s	Ed_CloseName		Encore une fenetre a fermer?
.Fini	rts

; Ouvre une nouvelle fenetre+Charge prg
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_OpenLoad
	bsr	Ed_OpenWindow
	bra	Ed_Load

;
; Ouvre une nouvelle fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_OpenWindow
	bsr	Ed_TokCur
	moveq	#-1,d0				Visible
	move.l	PI_DefSize(a5),d1		Taille par defaut
	bsr	Edt_OpWindow
	blt	Ed_OMm
	bgt	Ed_2ManyWindow
	bsr	Ed_DrawWindows
	rts

;
; Routine d'ouverture de fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	Hidden(0) / Vue(-1)
;	D1=	Taille buffer voulue
;	A4=	Edt Courant
Edt_OpWindow
	movem.l	d2-d7/a2-a3,-(sp)
	move.l	d1,d3
	move.w	d0,d2
	beq.s	.Res
; Si fenetre visible, peut-on l'ouvrir?
	sub.l	a0,a0
	bsr	Edt_WCount		Nombre de fenetres ouvertes
	cmp.w	Ed_WMax(a5),d0
	bcc	.Rate
; Ouvre la structure EDT
; ~~~~~~~~~~~~~~~~~~~~~~
.Res	move.l	#Edt_Long,d0
	SyCall	MemFastClear
	beq	.Omm2
; Insere dans la liste
	move.l	a4,d0
	beq.s	.First
	move.l	Edt_Next(a4),d0		Branche dans la liste
	move.l	d0,Edt_Next(a0)
	move.l	a0,Edt_Next(a4)
	bra.s	.Prg
.First	move.l	Edt_List(a5),Edt_Next(a0)
	move.l	a0,Edt_List(a5)
; Ouvre la structure Prg
; ~~~~~~~~~~~~~~~~~~~~~~
.Prg	move.l	a0,a4
	move.l	d3,d0			Taille
	bmi.s	.NoStru
	JJsr	L_Prg_NewStructure	Fabrique une structure fenetre
	beq.s	.Omm1
	move.l	d0,Edt_Prg(a4)		Branche dans la structure!
	move.l	d0,a6
	addq.b	#1,Prg_Edited(a6)	Flag: edite!
; Active la fenetre si visible
.NoStru	move.b	#2,Edt_Hidden(a4)	2 car aucune zone cr��e
	tst.w	d2
	beq.s	.Skip2
	clr.b	Edt_Hidden(a4)
	move.l	a4,Edt_Current(a5)
	moveq	#1,d0
	bsr	Edt_WSchrinkAll		Reduit toutes les fenetres
	moveq	#-1,d0
	bsr	Edt_WMaxSize
	move.w	d0,Edt_WindTy(a4)
; New des donnees
.Skip2	bsr	Edt_New
	moveq	#0,d0			Pas d'erreur
.Out	movem.l	(sp)+,d2-d7/a2-a3
	rts
; Trop de fenetres
.Rate	moveq	#1,d0
	bra.s	.Out
; Out of memory
.Omm1	bsr	Edt_DelWindow
.Omm2	moveq	#-1,d0
	bra.s	.Out

;
; Cache la fenetre editeur courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_WindowHide
	bsr	Ed_TokCur
; Si fenetre link�e, on ferme d'abord!
	move.l	Edt_LinkPrev(a4),d0
	or.l	Edt_LinkNext(a4),d0
	beq.s	.PaLink
; Ferme toutes les fenetres linkees
.Loop	move.l	Edt_LinkPrev(a4),d0
	bne.s	.Skip
	move.l	Edt_LinkNext(a4),d0
	beq.s	.PaLink
.Skip	move.l	a4,-(sp)
	move.l	d0,a4
	bsr	Ed_CloseWindow
	move.l	(sp)+,a4
	move.l	a4,Edt_Current(a5)
	bra.s	.Loop
.PaLink
; Une fenetre seule?
	bsr	Edt_WAlone
	bne	Ed_NoHide
; Enleve les links de scrolling, et cache
	move.l	a4,a0
	bsr	Edt_DelLinkScroll
	move.b	#1,Edt_Hidden(a4)
; Active une autre fenetre, quelle que soit sa taille!
	bsr	Edt_WAutre		D'abord une fenetre OUVERTE!
	bne.s	.Ok
	moveq	#0,d1
	move.l	a4,a0
	bsr	Edt_WAutre3		Sinon meme une fermee!
.Ok	moveq	#-1,d0
	bsr	Edt_WMaxSize
	move.w	d0,Edt_WindTy(a4)
	bsr	Ed_DrawWindows
	bsr	EdM_BranchAMOS
	rts

;
; Bouton de fermeture d'un fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_BtWindowClose
	move.w	Bt_Number(a2),d0
	bsr	Edt_GetAd
	beq.s	.Skip
	move.l	a0,a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_CloseWindowQuit
.Skip	rts

;
; Bouton Hide fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_BtWindowHide
	bsr	Ed_TokCur
	move.w	Bt_Number(a2),d0
	bsr	Edt_GetAd
	beq.s	.Skip
	move.l	a0,a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_WindowHide
.Skip	rts

;
; Bouton Scrhink / Expand fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
Ed_BtWindowSize
	bsr	Ed_TokCur
	move.w	Bt_Number(a2),d0
	bsr	Edt_GetAd
	beq.s	.Skip
	move.l	a0,a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_FlipSizeWindow
.Skip	rts

;
; Ferme la fenetre editeur courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_CloseWindowQuit			* Avec option QUIT
	tst.b	Ed_Zappeuse(a5)		Pas si zappeuse!
	bne.s	Ed_CloseWindow
	move.w	#-1,-(sp)
	bra.s	EdClo
Ed_CloseWindow				* Sans option QUIT
	clr.w	-(sp)
EdClo	bsr	Ed_TokCur
; Fenetre linkee?
	move.l	Edt_LinkPrev(a4),d0
	or.l	Edt_LinkNext(a4),d0
	bne.s	.Linked
; Pas linkee, fait un new
	bsr	Ed_New
; Derniere fenetre
.Linked	tst.b	Edt_First(a4)			Derniere fenetre?
	beq.s	.Closit
	tst.b	Edt_Last(a4)
	beq.s	.Closit
	tst.w	(sp)				Quitter?
	beq.s	.Fini
	tst.b	Ed_Zappeuse(a5)			Pas si zappeuse
	bne.s	.Fini
; Derniere fenetre: Quit AMOSPRO?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	btst	#0,Ed_QuitFlags(a5)
	beq	Ed_DoQuit
	moveq	#EdD_WQuit,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	beq	Ed_DoQuit
	bra.s	.Fini
; Ferme la fenetre
; ~~~~~~~~~~~~~~~~
.Closit	bsr	Edt_EffWindows
	bsr	Edt_DelWindow
	moveq	#-1,d0
	bsr	Edt_WMaxSize
	move.w	d0,Edt_WindTy(a4)
	bsr	Ed_DrawWindows
.Fini	addq.l	#2,sp
	rts

;
; Ferme un programme cach�
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NewHidden
	bsr	Ed_TokCur
	bsr	Ed_GetHidden
	beq	Ed_NotDone
	move.l	a0,a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_Saved
	bsr	Edt_DelWindow
	bsr	EdM_BranchAMOS
	rts

;
; Ferme TOUS les programmes cach�s
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NewAllHidden
	bsr	Ed_TokCur
	moveq	#EdD_NAll,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_Loop
	bra.s	.In
.Loop	move.l	a0,a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_Saved
	bsr	Edt_DelWindow
.In	moveq	#0,d1
	bsr	Ed_GetHidden
	bne.s	.Loop
	bsr	EdM_BranchAMOS
	rts

;
; Montre un programme cach�
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_EditHidden
	bsr	Ed_TokCur
	bsr	Ed_GetHidden
	beq	Ed_NotDone
	move.l	a0,-(sp)
	sub.l	a0,a0
	bsr	Edt_WCount		Nombre de fenetres ouvertes
	cmp.w	Ed_WMax(a5),d0
	bcc	Ed_2ManyWindow
	move.l	(sp)+,a4
	move.l	a4,Edt_Current(a5)
	move.l	Edt_Prg(a4),a6
	clr.b	Edt_Hidden(a4)
	moveq	#1,d0
	bsr	Edt_WSchrinkAll		Reduit toutes les fenetres
	moveq	#-1,d0
	bsr	Edt_WMaxSize
	move.w	d0,Edt_WindTy(a4)
	bsr	Prg_UndoCreate		Cree le buffer UNDO
	bsr	Ed_DrawWindows
	bsr	EdM_BranchAMOS
	rts

;
; Trouve le programme cach� en venant de l'appel des fonctions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D1=	Numero du programme
Ed_GetHidden
	move.l	Edt_List(a5),d0
.Loop	move.l	d0,a0
	tst.b	Edt_Hidden(a0)
	beq.s	.Next
	subq.w	#1,d1
	bmi.s	.Ok
.Next	move.l	Edt_Next(a0),d0
	bne.s	.Loop
	rts
.Ok	move.l	a0,d0
	rts

;
; Efface une structure fenetre quelconque (A4)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_DelWindow

; Ferme la structure programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_Prg(a4),d0
	beq.s	.NoProg
	move.l	d0,a6
; Si derniere fenetre sur le programme, enleve la structure
	subq.b	#1,Prg_Edited(a6)
	bne.s	.NoProg
	bsr	EdM_Program
	JJsr	L_Prg_DelStructure
	bsr	Prg_UndoFree
.NoProg

; Ferme la fenetre Editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	Edt_Current(a5),a4
	bne.s	.Split
	move.l	a4,a0				Qui suit
	bsr	Edt_WNext
	bne.s	.Link
	move.l	a4,a0				Qui precede
	bsr	Edt_WPrev
.Link	move.l	Edt_LinkPrev(a4),d1		Linke?
	bne.s	.Skp
	move.l	Edt_LinkNext(a4),d1
	beq.s	.Act
.Skp	move.l	d1,d0
.Act	move.l	d0,Edt_Current(a5)
; Enleve les SPLITS
.Split	move.l	Edt_LinkNext(a4),d0
	move.l	d0,a0
	beq.s	.Skip1
	move.l	Edt_LinkPrev(a4),Edt_LinkPrev(a0)
.Skip1	move.l	Edt_LinkPrev(a4),d0
	beq.s	.Scrol
	move.l	d0,a0
	move.l	Edt_LinkNext(a4),Edt_LinkNext(a0)
; Enleve les links de scroll sur cette fenetre
.Scrol	move.l	a4,a0
	bsr	Edt_DelLinkScroll
; Enleve les zones de cette fenetre
	bsr	Edt_DelZones
; Enleve de la liste
	move.l	Edt_List(a5),d0
	cmp.l	d0,a4
	beq.s	.First
.Loop	move.l	d0,a0
	move.l	Edt_Next(a0),d0
	cmp.l	d0,a4
	bne.s	.Loop
	move.l	Edt_Next(a4),Edt_Next(a0)
	bra.s	.End
.First	move.l	Edt_Next(a4),Edt_List(a5)
.End	move.l	#Edt_Long,d0		Efface la structure
	move.l	a4,a1
	SyCall	SyFree
; Prend la fenetre active maintenant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	sub.l	a4,a4
	sub.l	a6,a6
	move.l	Edt_Current(a5),d0
	beq.s	.Ss
	move.l	d0,a4
	move.l	Edt_Prg(a4),a6
.Ss	rts

; Efface toutes les fenetres editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_DelWindows
	movem.l	a4/a6,-(sp)
.Loop	move.l	Edt_List(a5),d0
	beq.s	.End
	move.l	d0,a4
	bsr	Edt_DelWindow
	bra.s	.Loop
.End	movem.l	(sp)+,a4/a6
	rts

;
; Dessine les fenetres editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DrawWindows

	movem.l	a2-a4/d2-d7,-(sp)

	bsr	Ed_CuOff
	bsr	Ed_AllAverFin
	bsr	Edt_EffWindows
	bsr	Edt_OrderWindows
	bsr	Edt_WFirstLast

;
; Boucle de dessin des programmes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Ed_BufE(a5),-(sp)
	move.w	#16+Ed_YTop,-(sp)
	move.l	Edt_List(a5),a4

.PLoop
	move.l	Edt_Prg(a4),a6
; Programme visible?
; ~~~~~~~~~~~~~~~~~~
	tst.b	Edt_Hidden(a4)
	bne	.NextP
; Pas plus loin que la longueur du programme
	move.w	Edt_YCu(a4),d0
	add.w	Edt_YPos(a4),d0
	cmp.w	Prg_NLigne(a6),d0
	ble.s	.Sl
	clr.w	Edt_YCu(a4)
	clr.w	Edt_YPos(a4)
; Centre le curseur dans la fenetre
.Sl	move.w	Edt_YCu(a4),d0
	move.w	Edt_WindTy(a4),d1
	subq.w	#1,d1
	bmi.s	.Dedans
	cmp.w	d1,d0
	bls.s	.Dedans
	move.w	d1,Edt_YCu(a4)
	sub.w	d1,d0
	add.w	d0,Edt_YPos(a4)
.Dedans
;
; Numero fenetre >>> numero zones
	move.w	Edt_Order(a4),d0
	lsl.w	#3,d0
	move.w	d0,Edt_Zones(a4)
	move.w	d0,Edt_Window(a4)
	addq.w	#1,d0
	move.w	d0,Edt_WindEtat(a4)
;
; Tailles / Positions de la fenetre
	move.w	(sp),d7
	move.w	d7,Edt_Y(a4)
	move.w	#0,Edt_WindX(a4)
	move.w	d7,Edt_WindY(a4)
	add.w	#Edt_EtatSy,Edt_WindY(a4)
	moveq	#32,d1
	move.w	d1,Edt_WindEX(a4)
	move.w	Ed_Sx(a5),d0
	sub.w	d1,d0
	sub.w	#64,d0
	move.w	d0,Edt_WindESx(a4)
	move.w	d7,Edt_WindEY(a4)
	addq.w	#1,Edt_WindEY(a4)
	move.w	Ed_Sx(a5),d0
	sub.w	#16,d0
	move.w	d0,Edt_WindSx(a4)
	lsr.w	#3,d0
	move.w	d0,Edt_WindTx(a4)
	move.w	Edt_WindTy(a4),d0
	lsl.w	#3,d0
	move.w	d0,Edt_WindSy(a4)
	add.w	#Edt_EtatSy+Edt_BasSy,d0
	move.w	d0,Edt_Sy(a4)
	move.w	Edt_WindTy(a4),d6

	move.w	Edt_WindY(a4),d0
	add.w	Edt_WindSy(a4),d0
	move.w	d0,Edt_BasY(a4)

	move.w	Edt_Zones(a4),Edt_ZEtat(a4)
	addq.w	#1,Edt_ZEtat(a4)
	move.w	Edt_Zones(a4),Edt_ZBas(a4)
	addq.w	#2,Edt_ZBas(a4)

; Initialisation du slider vertical
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Position / Taille
	move.w	Edt_WindX(a4),d0
	add.w	Edt_WindSx(a4),d0
	add.w	#Ed_SlVDeltaG,d0
	move.w	d0,Edt_SlV+Sl_X(a4)
	move.w	d7,Edt_SlV+Sl_Y(a4)
	add.w	#Ed_SlVDeltaH,Edt_SlV+Sl_Y(a4)
	move.w	#Ed_SlVSx,Edt_SlV+Sl_Sx(a4)
	move.w	Edt_WindSy(a4),d0
	add.w	#Ed_SlVDeltaB,d0
	move.w	d0,Edt_SlV+Sl_Sy(a4)
	move.w	Edt_WindTy(a4),Edt_SlV+Sl_Scroll(a4)
	sub.w	#2,Edt_SlV+Sl_Scroll(a4)
	move.w	#Ed_SlVDx,Edt_SlV+Sl_ZDx(a4)
; Zone
	move.w	Edt_Zones(a4),Edt_SlV+Sl_Zone(a4)
	addq.w	#3,Edt_SlV+Sl_Zone(a4)
; Adresses des routines
	lea	Edt_SliderY(pc),a1
	move.l	a1,Edt_SlV+Sl_Routines(a4)
	bset	#Sl_FlagVertical,Edt_SlV+Sl_Flags(a4)
; Couleurs active / inactive
	moveq	#19,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	lea	Edt_SlV+Sl_Inactive(a4),a0
	moveq	#16-1,d0
.Co	moveq	#0,d1
	move.b	(a1)+,d1
	move.w	d1,(a0)+
	dbra	d0,.Co

; Initialisation des boutons
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	Ed_Sx(a5),d0
	sub.w	#Edt_BtSx,d0
	move.w	d0,Edt_Bt3+Bt_X(a4)
	sub.w	#Edt_BtSx,d0
	move.w	d0,Edt_Bt2+Bt_X(a4)
	clr.w	Edt_Bt1+Bt_X(a4)
	move.w	Edt_Y(a4),d1
	move.w	d1,Edt_Bt1+Bt_Y(a4)
	move.w	d1,Edt_Bt2+Bt_Y(a4)
	move.w	d1,Edt_Bt3+Bt_Y(a4)
; Prepare les boutons
	moveq	#Ed_BtPics,d0
	move.w	Edt_Zones(a4),d1
	addq.w	#4,d1
	moveq	#2,d2
	lea	Edt_Bt1(a4),a1
.BLoop	move.w	Edt_Window(a4),Bt_Number(a1)
	addq.w	#1,d1
	move.w	d1,Bt_Zone(a1)
	move.w	d0,Bt_Image(a1)
	move.b	#24,Bt_Sx(a1)
	move.b	#Edt_EtatSy,Bt_Sy(a1)
	lea	Bt_RoutIn(pc),a0
	move.l	a0,Bt_Routines(a1)
	move.b	#6,Bt_RDraw(a1)
	addq.w	#2,d0
	lea	Bt_Long(a1),a1
	dbra	d2,.BLoop
; Routines de branchement boutons
	move.b	#1,Edt_Bt1+Bt_RChange(a4)
	move.b	#2,Edt_Bt2+Bt_RChange(a4)
	move.b	#3,Edt_Bt3+Bt_RChange(a4)
;
; Fond de l'image
; ~~~~~~~~~~~~~~~
; Unpack le haut
	moveq	#Ed_Pics+1,d0
	moveq	#0,d1
	move.w	d7,d2
	moveq	#-1,d3
	bsr	Ed_Unpack
	move.w	d7,d0
	add.w	#11,d7
	move.w	d7,d1
	bsr	Ed_Enlarge
	tst.w	d6
	beq.s	.Skip0
.Loop1	moveq	#Ed_Pics+2,d0
	move.w	Ed_Sx(a5),d1
	sub.w	#16,d1
	ext.l	d1
	move.w	d7,d2
	moveq	#-1,d3
	bsr	Ed_Unpack
	addq.w	#8,d7
	subq.w	#1,d6
	bne.s	.Loop1
; Met le bas
.Skip0	moveq	#Ed_Pics+3,d0
	moveq	#0,d1
	move.w	d7,d2
	moveq	#-1,d3
	bsr	Ed_Unpack
	move.w	d7,d0
	addq.w	#5,d7
	move.w	d7,d1
	bsr	Ed_Enlarge
	move.w	d7,(sp)
; Initialise la fenetre d'etat
	move.w	Edt_WindEtat(a4),d1
	move.w	Edt_WindEX(a4),d2
	move.w	Edt_WindEY(a4),d3
	move.w	Edt_WindESx(a4),d4
	lsr.w	#3,d4
	moveq	#1,d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCall	WindOp
	bsr	Ed_EtPrint
	move.w	Edt_ZEtat(a4),d1
	move.w	Edt_WindEX(a4),d2
	move.w	Edt_WindEY(a4),d3
	move.w	d2,d4
	move.w	d3,d5
	add.w	Edt_WindESx(a4),d4
	add.w	#Edt_EtatSy,d5
	SyCall	SetZone
; Initialise la zone du bas
	move.w	Edt_ZBas(a4),d1
	moveq	#0,d2
	move.w	Edt_BasY(a4),d3
	move.w	d2,d4
	move.w	d3,d5
	add.w	Ed_Sx(a5),d4
	add.w	#Edt_BasSy,d5
	SyCall	SetZone
; Initialise la fenetre de fond, si pas vide
	tst.w	Edt_WindTy(a4)
	beq	.Vide
	move.w	Edt_Window(a4),d1
	move.w	Edt_WindX(a4),d2
	move.w	Edt_WindY(a4),d3
	move.w	Edt_WindTx(a4),d4
	move.w	Edt_WindTy(a4),d5
	moveq	#0,d6
	moveq	#0,d7
	sub.l	a1,a1
	WiCall	WindOp
	moveq	#20,d0
	bsr	Ed_GetSysteme
	move.l	a0,a1
	WiCall	Print
	bsr	Ed_CuNor
	move.w	Edt_Zones(a4),d1
	move.w	Edt_WindX(a4),d2
	move.w	Edt_WindY(a4),d3
	move.w	d2,d4
	move.w	d3,d5
	add.w	Edt_WindSx(a4),d4
	add.w	Edt_WindSy(a4),d5
	SyCall	SetZone
	bsr	Edt_SlUpdateY
	lea	Edt_SlV(a4),a0
	JJsrR	L_Sl_Init,a1
	clr.b	Edt_ASlY(a4)
;
; Affiche le texte
; ~~~~~~~~~~~~~~~~
	move.l	2(sp),d0
	move.l	d0,Edt_BufE(a4)
	move.w	Edt_WindTy(a4),d0
	mulu	#256,d0
	add.l	d0,2(sp)
	bsr	Ed_NewBuf
.Vide
;
; Active les boutons
; ~~~~~~~~~~~~~~~~~~
	lea	Edt_Bt1(a4),a0
	moveq	#0,d0
	JJsrR	L_Bt_InitList,a1
;
; Programme suivant?
; ~~~~~~~~~~~~~~~~~~
.NextP	move.l	Edt_Next(a4),d0
	move.l	d0,a4
	bne	.PLoop
;
; Active le premier programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	move.w	Edt_Window(a4),d1
	WiCall	QWindow
	bsr	Ed_Loca
; Fini!
; ~~~~~
	addq.l	#6,sp
	movem.l	(sp)+,a2-a4/d2-d7
	rts

;
; Boucle d'effacement des fenetres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_EffWindows
	move.l	a4,-(sp)
	move.l	Edt_List(a5),d0
	beq.s	.Out
.ELoop	move.l	d0,a4
	tst.w	Edt_Window(a4)			Initialisee?
	beq.s	.ENext
	cmp.b	#2,Edt_Hidden(a4)		Deja fermee?
	beq.s	.ENext
	cmp.b	#1,Edt_Hidden(a4)
	bne.s	.Cl
	move.b	#2,Edt_Hidden(a4)		On ferme!
; Ferme les anciennes fenetres
.Cl	move.w	Edt_Window(a4),d1
	WiCall	QWindow
	WiCall	WinDel
	move.w	Edt_WindEtat(a4),d1
	WiCall	QWindow
	WiCall	WinDel
; Efface les zones
	bsr	Edt_DelZones
; Fenetre non initialisee
	clr.w	Edt_Window(a4)
; Fenetre suivante
.ENext	move.l	Edt_Next(a4),d0
	bne.s	.ELoop
.Out	move.l	(sp)+,a4
	rts
;
; Numerote les fenetres affichees
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_OrderWindows
	moveq	#1,d1
	move.l	Edt_List(a5),d0
	beq.s	.Out
.Loop	move.l	d0,a0
	tst.b	Edt_Hidden(a0)
	bne.s	.Hid
	move.w	d1,Edt_Order(a0)
	addq.w	#1,d1
.Hid	move.l	Edt_Next(a0),d0
	bne.s	.Loop
.Out	rts

;
; Enleve toutes les zones de toutes les fenetres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_DelAllZones
	move.l	Edt_List(a5),d0
	beq.s	.Skip
.Loop	move.l	d0,a0
	clr.w	Edt_Zones(a0)
	move.l	Edt_Next(a0),d0
	bne.s	.Loop
.Skip	rts

;
; Enleve les zones de la fenetre A4
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_DelZones
	move.w	Edt_Zones(a4),d2
	beq.s	.NIni
	moveq	#7,d3
.Zraz	move.w	d2,d1
	SyCall	RazZone
	addq.w	#1,d2
	dbra	d3,.Zraz
	clr.w	Edt_Zones(a4)
.NIni	rts

;
; Si la fenetre courante est vide, active la suivante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WVideNext
	move.l	Edt_Current(a5),a0
	tst.w	Edt_WindTy(a0)
	beq.s	Edt_WAutre2
	rts
; Active une autre fenetre que la courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WAutre
	move.l	a4,a0
Edt_WAutre2
	moveq	#1,d1
Edt_WAutre3
; Prend la fenetre suivante
.Loop1	bsr	Edt_WNext
	beq.s	.Loop2
	move.l	d0,a0
	cmp.w	Edt_WindTy(a0),d1
	bgt.s	.Loop1
	bra.s	.Exit
; Prend la fenetre pr�cedente
.Loop2	bsr	Edt_WPrev
	beq.s	.Skip
	move.l	d0,a0
	cmp.w	Edt_WindTy(a0),d1
	bgt.s	.Loop2
.Exit	move.l	a0,Edt_Current(a5)
	move.l	a0,a4
	move.l	Edt_Prg(a4),a6
.Skip	rts

;
; Routine de bougeation de la s�paration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_MSep
	move.w	d0,-(sp)
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	move.w	d3,-(sp)
	bsr	XYMouEced
	move.w	(sp)+,d0
	sub.w	d0,d2
	move.w	d2,-(sp)		Decalage souris/bloc
	move.w	d0,-(sp)		Ancien bloc
	move.w	d0,-(sp)		Nouveau bloc
; Fabrique le bloc de dessin
	moveq	#0,d2
	move.w	(sp),d3
	ext.l	d3
	move.w	Ed_Sx(a5),d4
	move.w	10(sp),d5
	ext.l	d5
	moveq	#0,d6
	move.l	Ed_BufT(a5),a1
	move.w	#128,d1
	EcCall	BlGet
.Loop0
; Fabrique le bloc de sauvegarde
	moveq	#0,d2
	move.w	(sp),d3
	ext.l	d3
	move.w	Ed_Sx(a5),d4
	move.w	10(sp),d5
	ext.l	d5
	moveq	#0,d6
	move.l	Ed_BufT(a5),a1
	move.l	#129,d1
	EcCall	BlGet
	move.w	(sp),2(sp)
; Dessine l'image
	moveq	#0,d2
	move.w	(sp),d3
	ext.l	d3
	move.l	#EntNul,d4
	move.l	d4,d5
	move.l	Ed_BufT(a5),a1
	move.w	#128,d1
	EcCall	BlPut
; Prend la souris
.Loop1	SyCall	MouseKey
	btst	#0,d1
	beq.s	.Skip
	bsr	XYMouEced
	sub.w	4(sp),d2
	cmp.w	8(sp),d2
	bge.s	.In1
	move.w	8(sp),d2
.In1	cmp.w	6(sp),d2
	ble.s	.In2
	move.w	6(sp),d2
.In2	cmp.w	(sp),d2
	beq.s	.Loop1
	move.w	d2,(sp)
; Efface l'ancien
.Skip	moveq	#0,d2
	move.w	2(sp),d3
	ext.l	d3
	move.l	#EntNul,d4
	move.l	d4,d5
	move.l	Buffer(a5),a1
	move.w	#129,d1
	EcCall	BlPut
; Lache la souris?
	SyCall	MouseKey
	btst	#0,d1
	bne	.Loop0
; Efface les bloc
	move.w	#128,d1
	EcCall	BlDel
	move.w	#129,d1
	EcCall	BlDel
; Fini
	move.w	(sp)+,d0
	lea	10(sp),sp
	rts

;
; XY Mouse dans l'ecran courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
XYMouEced
	SyCall	XyMou
	moveq	#0,d3
	SyCall	XyScr
	rts
;
; Active la fenetre A0, si on peut
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_Active
	bsr	Ed_TokCur
	tst.w	Edt_WindTy(a0)
	beq.s	.Out
; Inactive la fenetre courante
	move.l	a0,Edt_Current(a5)
	clr.b	Edt_ASlY(a4)
	bsr	Ed_AffSlV
	bsr	Ed_EtPrint
; Active la nouvelle
	move.l	Edt_Current(a5),a4
	move.l	Edt_Prg(a4),a6
	bsr	Ed_NewBufAff
	moveq	#-1,d0
.Out	rts

;
; Passage � la fenetre suivante (ouverte)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_NextWindow
	bsr	Ed_TokCur
	move.l	a4,a0
.Loop	bsr	Edt_WNext
	bne.s	.Skip
	move.l	Edt_List(a5),a0
.Skip	cmp.l	a4,a0
	beq.s	.Out
	move.l	a0,-(sp)
	bsr	Edt_Active
	move.l	(sp)+,a0
	beq.s	.Loop
.Out	rts
;
; Passage � la fenetre precedente (ouverte)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PrevWindow
	bsr	Ed_TokCur
	move.l	a4,a0
.Loop	bsr	Edt_WPrev
	bne.s	.Skip
	tst.b	Edt_Last(a4)
	bne.s	.Out
	move.l	a4,d0
.Loop2	move.l	d0,a0
	bsr	Edt_WNext
	bne.s	.Loop2
	move.l	a0,d0
.Skip	cmp.l	a4,d0
	beq.s	.Out
	move.l	d0,a0
	move.l	d0,-(sp)
	bsr	Edt_Active
	move.l	(sp)+,a0
	beq.s	.Loop
.Out	rts

;
; Ferme/Ouvre la fenetre courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_FlipSizeWindow
	bsr	Ed_TokCur
	move.w	Edt_WindTy(a4),d1
	beq.s	.Big
	move.w	d1,Edt_WindOldTy(a4)
	moveq	#0,d0
	bsr	Ed_SchrinkWindow
	rts
; Agrandi?
.Big	move.w	Edt_WindOldTy(a4),d0
	bne.s	.Skip
	moveq	#1,d0
	bsr	Edt_WMaxSize
.Skip	move.w	d0,Edt_WindTy(a4)
	moveq	#1,d1
	bsr	Edt_WPlaceBas
	beq.s	.Out
	moveq	#1,d1
	bsr	Edt_WPlaceHaut
	beq.s	.Out
	sub.w	d0,Edt_WindTy(a4)
.Out	bsr	Ed_DrawWindows
	rts

; Fenetre courante aussi grande que possible
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_BiggerWindow
	bsr	Ed_TokCur
	bsr	Edt_WAlone
	bne.s	.Out
	moveq	#0,d0
	bsr	Edt_WSchrinkAll
	add.w	d0,Edt_WindTy(a4)
	bsr	Ed_DrawWindows
.Out	rts
;
; Agrandi la fenetre courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ExpandWindow
	bsr	Ed_TokCur
	bsr	Edt_WAlone
	bne.s	.Out
	moveq	#1,d0
	bsr	Edt_WSchrinkAll
	add.w	d0,Edt_WindTy(a4)
	bsr	Ed_DrawWindows
.Out	rts
;
; Reduit la fenetre courante, D0=valeur mini
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SchrinkWindow
	bsr	Ed_TokCur
	bsr	Edt_WAlone
	bne.s	.Out
	move.w	Edt_WindTy(a4),d2
	cmp.w	d2,d0
	bcc.s	.Out
	move.w	d0,Edt_WindTy(a4)
	sub.w	d0,d2
; Retreci en haut
	move.l	a4,a0
	bsr	Edt_WNext
	beq.s	.Bas
	move.l	d0,a0
	add.w	d2,Edt_WindTy(a0)
	bra.s	.Aff
; Retreci en bas
.Bas	move.l	a4,a0
	bsr	Edt_WPrev
	move.l	d0,a0
	add.w	d2,Edt_WindTy(a0)
; Affiche
.Aff	bsr	Edt_WVideNext
	bsr	Ed_DrawWindows
.Out	rts

;
; Ramene VRAI si la fenetre est la seule sur l'ecran
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WAlone
	tst.b	Edt_First(a4)
	beq.s	.Out
	tst.b	Edt_Last(a4)
.Out	rts

;
; Changement en haut de la fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WChangeHaut
	and.w	#$FFF8,d0
	move.w	d0,d2
	cmp.w	Edt_Y(a4),d0
	beq.s	.Rien
	tst.b	Edt_Last(a4)
	bne.s	.Last
; Une fenetre au milieu, bouge tout
	sub.w	Edt_Y(a4),d0
	beq.s	.Rien
	move.w	Edt_BasY(a4),d3
	add.w	d0,d3
	bra	Edt_WChange
; La derniere, juste le haut
.Last	move.w	Edt_BasY(a4),d3
	add.w	#Edt_EtatSy,d0
	cmp.w	d0,d3
	bcc	Edt_WChange
	move.w	d0,d3
	bra	Edt_WChange
.Rien	rts

; Changement en bas de la fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WChangeBas
	addq.w	#Edt_BasSy,d0
	and.w	#$FFF8,d0
	subq.w	#Edt_BasSy,d0
	cmp.w	Edt_BasY(a4),d0
	beq.s	.Rien
	move.w	d0,d3
	move.w	Edt_Y(a4),d2
	sub.w	#Edt_EtatSy,d0
.Skip	cmp.w	d2,d0
	bcc.s	Edt_WChange
	move.w	d0,d2
	bra.s	Edt_WChange
.Rien 	rts
; Calcule la nouvelle taille de la fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WChange
	move.w	d3,d0
	sub.w	d2,d0
	sub.w	#Edt_EtatSy,d0
	lsr.w	#3,d0
	move.w	d0,Edt_WindTy(a4)
; Modifications en haut
; ~~~~~~~~~~~~~~~~~~~~~
	move.w	Edt_Y(a4),d0
	move.w	d2,Edt_Y(a4)
	cmp.w	d0,d2
	beq.s	.Bas
	bcc.s	.HBas
; On remonte le haut
	sub.w	d2,d0
	lsr.w	#3,d0
	moveq	#1,d1
	bsr	Edt_WPlaceHaut
	beq.s	.Bas
	moveq	#0,d1
	bsr	Edt_WPlaceHaut
	bra.s	.Bas
; On descend le haut
.HBas	sub.w	d0,d2
	lsr.w	#3,d2
	move.l	a4,a0
	bsr	Edt_WPrev
	move.l	d0,a0
	add.w	d2,Edt_WindTy(a0)
; Modifications en bas?
; ~~~~~~~~~~~~~~~~~~~~~
.Bas	move.w	Edt_BasY(a4),d0
	move.w	d3,Edt_BasY(a4)
	cmp.w	d0,d3
	beq.s	.Fini
	bcc.s	.BBas
; On remonte le bas
	sub.w	d3,d0
	lsr.w	#3,d0
	move.w	d0,d3
	move.l	a4,a0
	bsr	Edt_WNext
	move.l	d0,a0
	add.w	d3,Edt_WindTy(a0)
	bra.s	.Fini
; On descend le bas
.BBas	sub.w	d0,d3
	lsr.w	#3,d3
	move.w	d3,d0
	moveq	#1,d1
	bsr	Edt_WPlaceBas
	beq.s	.Fini
	moveq	#0,d1
	bsr	Edt_WPlaceBas
; Ouf
; ~~~
.Fini	moveq	#-1,d0
	rts

;
; Fait D0 lignes de place en haut de A4, minimum D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WPlaceHaut
	move.w	d2,-(sp)
	move.w	d1,d2
	move.w	d0,d1
	move.l	a4,a0
.Loop	bsr	Edt_WPrev
	beq.s	.Out
	move.l	d0,a0
	cmp.w	Edt_WindTy(a0),d2
	bge.s	.Loop
	sub.w	Edt_WindTy(a0),d1
	bcs.s	.Ok
	add.w	d2,d1
	move.w	d2,Edt_WindTy(a0)
	bra.s	.Loop
.Ok	neg.w	d1
	move.w	d1,Edt_WindTy(a0)
	moveq	#0,d1
.Out	move.w	(sp)+,d2
	move.w	d1,d0
	rts
;
; Fait D0 lignes de place en bas de A4
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WPlaceBas
	move.w	d2,-(sp)
	move.w	d1,d2
	move.l	d0,d1
	move.l	a4,a0
.Loop	bsr	Edt_WNext
	beq.s	.Out
	move.l	d0,a0
	cmp.w	Edt_WindTy(a0),d2
	bge.s	.Loop
	sub.w	Edt_WindTy(a0),d1
	bcs.s	.Ok
	add.w	d2,d1
	move.w	d2,Edt_WindTy(a0)
	bra.s	.Loop
.Ok	neg.w	d1
	move.w	d1,Edt_WindTy(a0)
	moveq	#0,d1
.Out	move.w	(sp)+,d2
	move.w	d1,d0
	rts

;
; Verifie la validite des WindTy
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Edt_WOk
;	move.l	Prg_List(a5),a0
;	moveq	#Ed_TitreSy,d0
;.Loop	tst.b	Edt_Hidden(a0)
;	bne.s	.Skip
;	add.w	#Edt_EtatSy+Edt_BasSy,d0
;	move.w	Edt_WindTy(a0),d1
;	lsl.w	#3,d1
;	add.w	d1,d0
;.Skip	move.l	Edt_Next(a0),d1
;	move.l	d1,a0
;	bne.s	.Loop
;; Verification
;	cmp.w	Ed_Sy(a5),d0
;	rts

;
; Trouve l'adresse d'une fenetre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_GetAd
	move.l	Edt_List(a5),d1
	beq.s	.Out
.Loop	move.l	d1,a0
	cmp.w	Edt_Window(a0),d0
	beq.s	.Out
	move.l	Edt_Next(a0),d1
	move.l	d1,a0
	bne.s	.Loop
	moveq	#0,d0
	rts
.Out	moveq	#-1,d1
	rts
;
; Calcule les flags first et last
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WFirstLast
	move.l	Edt_List(a5),d0
	beq.s	.Out
	moveq	#0,d1
.Loop	move.l	d0,a0
	clr.b	Edt_First(a0)
	clr.b	Edt_Last(a0)
	tst.b	Edt_Hidden(a0)
	bne.s	.Next
	tst.l	d1
	bne.s	.Skip
	addq.b	#1,Edt_First(a0)
.Skip	move.l	a0,d1
.Next	move.l	Edt_Next(a0),d0
	bne.s	.Loop
	move.l	d1,a0
	addq.b	#1,Edt_Last(a0)
.Out	rts
;
; Compte le nombre de fenetres affichees >>> A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WCount
	moveq	#0,d0
	move.l	Edt_List(a5),d1
	beq.s	.Out
.Loop	move.l	d1,a1
	tst.b	Edt_Hidden(a1)
	bne.s	.Skip
	addq.w	#1,d0
.Skip	cmp.l	d1,a0
	beq.s	.Out
	move.l	Edt_Next(a1),d1
	bne.s	.Loop
.Out	rts
;
;
; Reduit toutes les fenetres � la taille D0
; Retourne le gain en taille
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WSchrinkAll
	move.l	d2,-(sp)
	move.w	d0,d1
	moveq	#0,d0
	move.l	Edt_List(a5),d2
	beq.s	.Out
.Loop	move.l	d2,a0
	tst.b	Edt_Hidden(a0)
	bne.s	.Skip
	cmp.w	Edt_WindTy(a0),d1
	bcc.s	.Skip
	add.w	Edt_WindTy(a0),d0
	sub.w	d1,d0
	move.w	d1,Edt_WindTy(a0)
.Skip	move.l	Edt_Next(a0),d2
	bne.s	.Loop
.Out	move.l	(sp)+,d2
	rts
;
; Ramene la fenetre affich�e precedent A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WPrev
	movem.l	d1/a1,-(sp)
	moveq	#0,d0
	move.l	Edt_List(a5),d1
	beq.s	.Out
.Loop	cmp.l	a0,d1
	beq.s	.Out
	move.l	d1,a1
	tst.b	Edt_Hidden(a1)
	bne.s	.Next
	move.l	a1,d0
.Next	move.l	Edt_Next(a1),d1
	bne.s	.Loop
.Out	movem.l	(sp)+,d1/a1
	tst.l	d0
	rts
;
; Ramene la fenetre affiche suivant A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_WNext
	movem.l	d1/a1,-(sp)
	moveq	#0,d0
.Next	move.l	Edt_Next(a0),d1
	beq.s	.Out
	move.l	d1,a0
	tst.b	Edt_Hidden(a0)
	bne.s	.Next
	move.l	a0,d0
.Out	movem.l	(sp)+,d1/a1
	tst.l	d0
	rts
;
; Ramene la taille maximum admissible pour la fenetre courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 	Entree, D0>=0 si taille reduite � D0
;		D0<1 si taille sans reduire les autres
;	D0=	WindTy
;	D1=	WindY
;	D2=	WindSy
Edt_WMaxSize
	move.w	d0,-(sp)
	moveq	#0,d1
	moveq	#Ed_TitreSy,d2
; Exploration de la liste
	move.l	Edt_List(a5),d0
	beq.s	.Exit
.Loop	move.l	d0,a0
	cmp.l	a0,a4			Stocke position fenetre courante
 	bne.s	.Skip0
	move.w	d2,d1
	add.w	#Edt_EtatSy+Edt_BasSy,d2
	bra.s	.Skip2
.Skip0	tst.b	Edt_Hidden(a0)
	bne.s	.Skip2
	add.w	#Edt_EtatSy+Edt_BasSy,d2
	move.w	Edt_WindTy(a0),d0
	tst.w	(sp)
	bmi.s	.Skip1
	cmp.w	(sp),d0
	bls.s	.Skip1
	move.w	(sp),d0
.Skip1	lsl.w	#3,d0
	add.w	d0,d2
.Skip2	move.l	Edt_Next(a0),d0
	bne.s	.Loop
; Calcule la taille
.Exit	addq.l	#2,sp
	move.w	Ed_Sy(a5),d0
	sub.w	d2,d0
	move.w	d1,d2
	add.w	d0,d2
	add.w	#Edt_EtatSy+Edt_BasSy,d2
	asr.w	#3,d0
	rts

; __________________________________________________________________________
;
; 	Creation du menu
; __________________________________________________________________________
;

; Effacement de tous les menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_End
	bsr	EdM_Editor
	JJsr	L_MnRaz
	move.l	EdM_Table(a5),d0
	beq.s	.Skip
	clr.l	EdM_Table(a5)
	move.l	d0,a1
	move.l	EdM_TableSize(a5),d0
	SyCall	MemFree
.Skip	rts

;
; Erreur, on ne peut pas ouvrir les menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_Error
	move.w	#185,d0			Out of memory: cannot open menu
	bsr	Ed_GetMessage
	move.w	#1,d0			Relache tout de suite!
	bsr	Ed_AlertRts
	JJsr	L_Dia_NoMKey		Plus de touche souris
	rts

; Initialisation generale des menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_Init
	movem.l	d2-d7/a2-a6,-(sp)

; Enleve les anciens menus
; ~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	EdM_End

; Assez de memoire?
; ~~~~~~~~~~~~~~~~~
	bsr	Ed_Available			40k minimum!
	cmp.l	#40*1024,d0
	bcs	.Error

; Reserve la table
; ~~~~~~~~~~~~~~~~
	move.l	#EdM_HiddenMax*8*5+16,d0	Menus hiddens
	add.l	#EdM_UserMax*8+8,d0
	move.l	EdM_Definition(a5),a0		Definitions normals
	add.l	-4(a0),d0
	add.l	#16,d0				Un chouuya de securite
	move.l	d0,EdM_TableSize(a5)
	SyCall	MemFastClear
	move.l	a0,EdM_Table(a5)
	beq	.Error

; Reset des definitions
; ~~~~~~~~~~~~~~~~~~~~~
	clr.w	MnMouse(a5)
	lea	MnDFlags(a5),a0
	moveq	#0,d0			* Barre de menu
*	bset	#MnBar,d0
	bset	#MnTotal,d0
*	bset	#MnBouge,d0
*	bset	#MnTBouge,d0
	move.b	d0,(a0)+
	moveq	#0,d0
	bset	#MnBar,d0
*	bset	#MnBouge,d0
*	bset	#MnTBouge,d0
	moveq	#MnNDim-1-1,d1		* Autres dimensions
.DRex3	move.b	d0,(a0)+
	dbra	d1,.DRex3
	moveq	#MnNDim-1,d0
	lea	MnChoix(a5),a0
.DRex4	clr.w	(a0)+
	dbra	d0,.DRex4
	move.l	T_EcAdr+EcEdit*4(a5),MnAdEc(a5)
*	move.w	#1,MnMouse(a5)

; Creation de l'arbre de menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	EdM_Definition(a5),a2
	move.l	EdM_Table(a5),a3
	move.l	EdM_Messages(a5),a4
	addq.l	#2,a4
.MnCr	bsr	EdM_CreObjet
	addq.l	#8,a2
	add.w	d4,a4
	cmp.b	#"*",(a2)
	bne.s	.MnCr
	addq.l	#8,a2
	move.l	a2,EdM_MenuAMOS(a5)
	move.l	a4,EdM_MessAMOS(a5)

; Cree la branche de menu USER
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	EdM_User(a5),d0
	beq	.PaUser
	move.l	d0,a4
	addq.l	#2,a4
; Cree les objets user
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#1,d7			Premier programme
.Loop	move.l	Ed_BufT(a5),a2
	move.l	a2,a1
	move.b	d7,(a1)			Met les donnees
	add.b	#"0"+EdM_UserCommands-1,(a1)+
	move.b	#"3",(a1)+
	move.b	#"0",(a1)+
	move.b	#"1",(a1)+
	move.b	#"7",(a1)+
	move.b	d7,(a1)
	add.b	#"0",(a1)+
	move.b	#"0",(a1)+
	move.b	#"0",(a1)+
	clr.b	(a1)
	move.l	a4,-(sp)
; Met la chaine au propre
; ~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	(a4)
	beq.s	.Cree
	lea	8(a2),a0
	moveq	#EdM_UserLong-1,d0
.Lp1	move.b	#" ",(a0)+
	dbra	d0,.Lp1
	clr.b	(a0)
	lea	9(a2),a0
	moveq	#EdM_UserLong-2-1,d0
.Lp2	move.b	(a4)+,d1
	beq.s	.Cree
	move.b	d1,(a0)+
	dbeq	d0,.Lp2
; Va fabriquer l'objet
; ~~~~~~~~~~~~~~~~~~~~
.Cree	lea	8(a2),a4
	bsr	EdM_CreObjet
	move.l	(sp)+,a4
	moveq	#2,d4
	add.b	-1(a4),d4
	tst.b	(a4)
	beq.s	.PaOb
	move.l	a4,d0
	sub.l	EdM_User(a5),d0
	neg.w	d0
	move.w	d0,-4(a3)
; Encore un objet?
; ~~~~~~~~~~~~~~~~
.PaOb	add.w	d4,a4
	addq.w	#1,d7
	cmp.w	#EdM_UserMax,d7
	ble.s	.Loop
.PaUser

; Va creer la branche AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a3,EdM_TableAMOS(a5)
	bsr	EdM_BranchAMOS

; Yo, marque les marques
; ~~~~~~~~~~~~~~~~~~~~~~
	bsr	EdM_MarkAll

; Demarrage du menu
; ~~~~~~~~~~~~~~~~~
.Bug	clr.w	MnChoice(a5)
; Pas d'erreur...
	moveq	#0,d0
	bra.s	.Out
; Out of memory
.Error	bsr	EdM_End
	moveq	#1,d0
.Out	movem.l	(sp)+,d2-d7/a2-a6
	rts

; Compte les programmes caches
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edt_CountHidden
	moveq	#0,d0
	move.l	Edt_List(a5),d1
	beq.s	.Out
.Loop	move.l	d1,a0
	tst.b	Edt_Hidden(a0)
	beq.s	.Skip
	addq.w	#1,d0
.Skip	move.l	Edt_Next(a0),d1
	bne.s	.Loop
.Out	rts

; Previous programs in AMOS menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_PrevHidden
	bsr	Ed_TokCur
	move.w	EdM_PosHidden(a5),d0
	beq	Ed_NotDone
	sub.w	#EdM_HiddenMax-1,d0
	bpl.s	.Skip
	clr.w	d0
.Skip	move.w	d0,EdM_PosHidden(a5)
	bsr	EdM_BranchAMOS
	rts
; Next programs in AMOS Menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_NextHidden
	bsr	Ed_TokCur
	add.w	#EdM_HiddenMax-1,EdM_PosHidden(a5)
	bsr	EdM_BranchAMOS
	rts

; _____________________________________
;
; Efface / Cree la branche de menu AMOS
; _____________________________________
;
EdM_BranchAMOS
	movem.l	a2-a4/d2-d7,-(sp)
	bsr	EdM_Editor
	tst.l	MnBase(a5)		Menus definis?
	beq	.Pamenu
; Efface la branche AMOS
; ~~~~~~~~~~~~~~~~~~~~~~
	move.l	Ed_BufT(a5),a3
	addq.l	#8,a3
	move.l	#1,-(a3)
	moveq	#1,d5
	JJsr	L_MnFind
	beq.s	.ExistPa
	move.l	a2,d0
	moveq	#0,d5
	JJsr	L_MnEff
.ExistPa
; Cree les objets normaux
; ~~~~~~~~~~~~~~~~~~~~~~~
	move.l	EdM_MenuAMOS(a5),a2
	move.l	EdM_TableAMOS(a5),a3
	movem.l	EdM_MessAMOS(a5),a4
.MnCr	move.b	#"1",4(a2)
	bsr	EdM_CreObjet
	addq.l	#8,a2
	add.l	d4,a4
	cmp.b	#"*",(a2)
	bne.s	.MnCr
	addq.l	#8,a2

; Des programmes cach�s?
; ~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d7			Flags � zero
	move.b	4+1(a2),d7		Prend le numero du premier programme
	bsr	Edt_CountHidden
	move.w	d0,d1			Pas de programme
	beq	.EHidden
; Centre au mieux
	sub.w	#EdM_HiddenMax,d0
	bpl.s	.Plus
	clr.w	EdM_PosHidden(a5)
	bra.s	.Hidden
.Plus	cmp.w	EdM_PosHidden(a5),d0
	bcc.s	.Hidden
	move.w	d0,EdM_PosHidden(a5)
; Flags pour les lignes haut / bas
.Hidden	move.w	EdM_PosHidden(a5),d0
	beq.s	.S1
	bset	#31,d7
.S1	add.w	#EdM_HiddenMax,d0
	cmp.w	d0,d1
	ble.s	.S2
	bset	#30,d7
.S2

; Cree les objets de programmes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Met le titre
	move.b	#"1",4(a2)
	move.b	d7,4+1(a2)
	bsr	EdM_CreObjet
	addq.l	#8,a2
	add.l	d4,a4
	addq.b	#1,d7
; Met ... previous programs ...
	bclr	#31,d7
	beq.s	.PHo
	movem.l	a2/a4,-(sp)
	move.b	#"1",4(a2)
	move.b	d7,4+1(a2)
	bsr	EdM_CreObjet
	addq.b	#1,d7
	movem.l	(sp)+,a2/a4
; Saute le ... previous ...
.PHo	addq.l	#8,a2
	move.b	-(a4),d4
	lea	3(a4,d4.w),a4
; Boucle d'exploration
; ~~~~~~~~~~~~~~~~~~~~
	movem.l	a2/a4,-(sp)
	move.b	#"0"+HiddenCommands,d6
	moveq	#EdM_HiddenMax,d3
; Recherche le premier programme cache a afficher
	move.w	EdM_PosHidden(a5),d1
	bsr	Ed_GetHidden		Programme >>> D0
	bra	.PIn
; Boucle !
.PLoop	move.b	#"1",4(a2)
	move.b	d7,4+1(a2)		Numero de la branche
; Nom du programme
	move.l	a6,-(sp)
	move.l	Edt_Prg(a6),a6
	move.l	a4,a0
	move.b	#" ",(a0)+
	bsr	Ed_NPrgToBuf
	move.l	(sp)+,a6
	move.b	#" ",-1(a1)
; Va fabriquer l'objet
	bsr	EdM_CreObjet
	addq.l	#8,a2
	add.l	d4,a4
; Sous menu sp�cifique
.Loop2	move.b	#"1",4(a2)
	move.b	d7,4+1(a2)
	cmp.b	#"0",(a2)
	beq.s	.Skip
	move.b	d6,(a2)
	addq.b	#1,d6
.Skip	bsr	EdM_CreObjet
	addq.l	#8,a2
	add.l	d4,a4
	cmp.b	#"*",(a2)
	bne.s	.Loop2
	addq.l	#8,a2
	addq.b	#1,d7			Un menu de plus
	movem.l	(sp),a2/a4		Restaure les chaines
; Passe au programme suivant
.PNext	move.l	Edt_Next(a6),d0		Programme suivant
.PIn	beq.s	.EHid
	move.l	d0,a6
	tst.b	Edt_Hidden(a6)
	beq.s	.PNext
	dbra	d3,.PLoop		Encore un?
.EHid	addq.l	#8,sp
.EHidden
; Trouve la fin des menus sp�ciaux
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d4
.FLoop	addq.l	#8,a2
	move.b	-(a4),d4
	lea	3(a4,d4.w),a4
	cmp.b	#"*",(a2)
	bne.s	.FLoop
	addq.l	#8,a2
; Met ... next programs ...
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	bclr	#30,d7
	beq.s	.PBa
	movem.l	a2/a4,-(sp)
	move.b	#"1",4(a2)
	move.b	d7,4+1(a2)
	bsr	EdM_CreObjet
	addq.b	#1,d7
	movem.l	(sp)+,a2/a4
; Saute le ... next ...
.PBa	addq.l	#8,a2
	move.b	-(a4),d4
	lea	3(a4,d4.w),a4

; Termine le menu
; ~~~~~~~~~~~~~~~
.MnC	move.b	#"1",4(a2)
	move.b	d7,4+1(a2)
	bsr	EdM_CreObjet
	addq.l	#8,a2
	add.l	d4,a4
	addq.b	#1,d7
	cmp.b	#32,(a2)
	bcc.s	.MnC

; Fini!
	clr.l	(a3)
	move.w	#1,MnChange(a5)
.Pamenu	movem.l	(sp)+,a2-a4/d2-d7
	rts


; _____________________________________
;
; Marque tous les objets markables
; _____________________________________
;
EdM_MarkAll
	bsr	EdM_Editor
; Les touches dans le menu
; ~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#104,d0
	move.b	EdM_Keys(a5),d1
	bsr	EdM_SetMark
; Mode insert / Replace
; ~~~~~~~~~~~~~~~~~~~~~
	moveq	#75,d0
	move.b	Ed_Insert(a5),d1
	bsr	EdM_SetMark
; Sound On / Off
; ~~~~~~~~~~~~~~
	move.w	#148,d0
	move.b	Ed_Sounds(a5),d1
	bsr	EdM_SetMark
	rts

; _____________________________________
;
; Marque Active ou non un objet de menu
;
;	D0= 	numero de la fonction
;	D1=	Active ou non
; _____________________________________
;
EdM_SetMark
	movem.l	a2/a4,-(sp)
	tst.l	MnBase(a5)			Menus definis?
	beq.s	.Pamenu
	move.l	EdM_Definition(a5),a2
	move.l	EdM_Table(a5),a0
	move.l	EdM_Messages(a5),a4
.FLoop	cmp.b	6(a0),d0
	addq.l	#8,a0
	bne.s	.FLoop
	subq.l	#8,a0
	add.w	4(a0),a4
	moveq	#0,d0
	move.b	7(a0),d0
	lsl.w	#3,d0
	add.w	d0,a2
	move.l	a4,a1
	lea	MenuMark0(pc),a0
	tst.b	d1
	beq.s	.Skip
	lea	MenuMark1(pc),a0
.Skip	move.b	(a0)+,d0
	beq.s	.Out
	move.b	d0,(a1)+
	bra.s	.Skip
.Out	moveq	#1,d0
	bsr	EdM_ObCree
	move.w	#1,MnChange(a5)
.Pamenu	movem.l	(sp)+,a2/a4
	rts


; ____________________________________________
;
; Montre / Efface les touches dans les menus
; ____________________________________________
;
Ed_ShowKey
	bsr	Ed_TokCur
	not.b	EdM_Keys(a5)
	bsr	EdM_Init
	rts

;
; Routine de cr�ation du menu A2 / Table A3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdM_CreObjet
	tst.b	(a4)			Un objet?
	beq.s	.Skip
	moveq	#3,d0
	lea	4(a2),a0		.B Definition de l'arbre
.MnCrL	move.b	(a0)+,(a3)
	sub.b	#"0",(a3)+
	dbra	d0,.MnCrL
	move.l	a4,d0			.W Adresse dans les messages
	sub.l	EdM_Messages(a5),d0
	move.w	d0,(a3)+
	move.b	(a2),d0			.B Touche
	sub.b	#"0",d0
	move.b	d0,(a3)+
	move.l	a2,d1			.B Definition
	sub.l	EdM_Definition(a5),d1
	lsr.l	#3,d1
	move.b	d1,(a3)+
	ext.w	d0
	bsr	EdM_ObCree
.Skip	moveq	#2,d4
	add.b	-1(a4),d4
; ILLEGAL verification table
	move.l	EdM_Table(a5),a0
	add.l	EdM_TableSize(a5),a0
	cmp.l	a0,a3
	bcs.s	.Ok
	illegal
.Ok	rts


; ____________________________________
;
; Initialisation de l'objet de menu A2/A4
; D0=	Actif / Inactif (0/1)
; ____________________________________
;
EdM_ObCree
	movem.l	a2-a6/d2-d7,-(sp)
	move.l	Ed_BufT(a5),a3
	lea	256(a3),a3
	move.l	a2,a6
	move.w	d0,-(sp)

; Recupere la position de l'objet
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d5
	lea	4(a6),a0
	moveq	#0,d0
	moveq	#3,d1
.Loop0	move.b	(a0)+,d0
	sub.b	#"0",d0
	beq.s	.Exit0
	move.l	d0,-(a3)
	addq.w	#1,d5
	dbra	d1,.Loop0
.Exit0	move.w	d5,-(sp)

; Fabrique la structure de l'objet
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_MnFind
	bne.s	.Exist
	JJsr	L_MnIns
.Exist

; Inactive?
; ~~~~~~~~~
	move.w	(sp)+,d7
	bclr	#MnOff,MnFlag(a2)
	tst.w	(sp)+
	bne.s	.Act
	bset	#MnOff,MnFlag(a2)
.Act

; Couleurs de l'objet
; ~~~~~~~~~~~~~~~~~~~
	move.b	1(a6),d1
	sub.b	#"0",d1
	move.b	2(a6),d0
	sub.b	#"0",d0
	move.b	d0,MnInkA1(a2)
	move.b	d1,MnInkB1(a2)
	move.b	d0,MnInkC1(a2)
	move.b	d1,MnInkA2(a2)
	move.b	d0,MnInkB2(a2)
	move.b	d0,MnInkC2(a2)
; Fabrique la chaine
; ~~~~~~~~~~~~~~~~~~
	move.l	a4,a0
	move.l	Ed_BufT(a5),a1
	lea	2(a3),a1
.Loop2	move.b	(a0)+,d0
	move.b	d0,(a1)+
	cmp.b	#32,d0
	bcc.s	.Loop2
	subq.l	#1,a1
	move.l	a1,d1
	sub.l	a3,d1
	subq.l	#2,d1
	move.w	d1,(a3)
	clr.w	-2(a3)

; Met les codes de touche si necessaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	EdM_Keys(a5)
	beq	.NoKey2
L_KDef	equ	11
	cmp.w	#1,d7
	beq	.NoKey2
	move.l	a2,-(sp)
	cmp.b	#"0",(a6)		Rien si SubMenu
	bcs	.NoKey
	moveq	#L_KDef+1,d0
	add.w	d0,(a3)
	move.b	(a4),d1
	move.l	a1,a0
.Loop3	move.b	d1,(a0)+
	subq.w	#1,d0
	bne.s	.Loop3
; Trouve la touche
	move.b	(a6),d0
	sub.b	#"0",d0
	beq	.NoKey
	bsr	Ed_Fonc2Ky
	beq	.NoKey
	move.l	a0,a2
; Fabrique le texte
	move.b	1(a2),d1
	move.b	(a2),d2
	cmp.b	#1,d2
	bls	.NoKey
	lea	Menus_Touches1(pc),a2
	move.l	a2,a0
.Lp1	cmp.b	(a0)+,d1
	addq.l	#1,a0
	bne.s	.Lp1
	moveq	#0,d0
	move.b	-1(a0),d0
	add.w	d0,a2
.Lp2	move.b	(a2)+,(a1)+
	bne.s	.Lp2
	subq.l	#1,a1
; Touche ASCII
	tst.b	d2
	bmi.s	.SkipSc
	move.b	#'"',(a1)+
	move.b	d2,(a1)+
	move.b	#'"',(a1)+
	bra.s	.EndKey
; Scancode
.SkipSc	lea	Menus_Touches2(pc),a0
	addq.l	#1,a0
	bra.s	.SkipS1
.LoopS1	tst.b	(a0)+
	bpl.s	.LoopS1
	tst.b	(a0)
	beq.s	.ExitS1
.SkipS1	cmp.b	-1(a0),d2
	bne.s	.LoopS1
.LoopS2	move.b	(a0)+,(a1)+
	bpl.s	.LoopS2
	subq.l	#1,a1
	bra.s	.EndKey
.ExitS1	moveq	#2,d3
	move.l	a1,a0
	move.b	d2,d0
	and.b	#$7f,d0
	JJsrP	L_LongToHex,a2
	move.l	a0,a1
; Termine la touche
.EndKey	move.b	(a2)+,(a1)+
	bne.s	.EndKey
	bra.s	.FinKey
; Vers un autre niveau de menu
.NLevel	lea	Menus_Touches3(pc),a2
.LoopL	move.b	(a2)+,(a1)+
	bne.s	.LoopL
; Termine la chaine
.FinKey	move.b	#" ",-1(a1)
.NoKey	move.l	(sp)+,a2
.NoKey2

; Chaine normale
; ~~~~~~~~~~~~~~
	lea	MnOb1(a2),a0
	move.l	a3,a1
	bsr	Ed_MnOb
; Chaine activee
; ~~~~~~~~~~~~~~
	lea	MnOb2(a2),a0
	lea	-2(a3),a1
	bsr	Ed_MnOb
; Chaine inactive?
; ~~~~~~~~~~~~~~~~
	lea	MnOb3(a2),a0
	lea	-2(a3),a1
	bsr	Ed_MnOb
; Chaine du fond
; ~~~~~~~~~~~~~~
	lea	MnObF(a2),a0
	lea	-2(a3),a1
	bsr	Ed_MnOb
; Finito
; ~~~~~~
	move.l	a2,a0
	move.w	#1,MnChange(a5)
	moveq	#0,d0
	movem.l	(sp)+,a2-a6/d2-d7
	rts


; Routine de creation de la chaine
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0= 	chaine dans l'objet
;	A1= 	chaine � affecter � l'objet A2
;
Ed_MnOb
	tst.w	(a1)
	beq	.MnObE
; Cree une chaine!
; ~~~~~~~~~~~~~~~~
	movem.l	a0/a1,-(sp)		* Efface l'ancienne
	bsr.s	.MnObE
	movem.l	(sp)+,a0/a1
	JJsrP	L_MnObjet,a2		* Cree la nouvelle
	beq.s	.Err			* Illegal: tester low mem!
	bmi.s	.Err
	move.l	d0,(a0)
	rts
; Efface la chaine
; ~~~~~~~~~~~~~~~~
.MnObE	move.l	(a0),d0
	beq.s	.Out
	clr.l	(a0)
	move.l	d0,a1
	moveq	#0,d0
	move.w	(a1),d0
	SyCall	MemFree
.Out	rts
.Err	illegal
	rts


; _______________________________________________
;
; Copie la zone de menus editeur
; _______________________________________________
;
EdM_Editor
	tst.b	EdM_Flag(a5)
	bne.s	.Done
	move.b	#1,EdM_Flag(a5)
	movem.l	a0/a1/d0/d1,-(sp)
	lea	EdM_Copie(a5),a0
	lea	Mn_SSave(a5),a1
	moveq	#(Mn_ESave-Mn_SSave)/2-1,d0
.Swap	move.w	(a0),d1
	move.w	(a1),(a0)+
	move.w	d1,(a1)+
	dbra	d0,.Swap
	movem.l	(sp)+,a0/a1/d0/d1
.Done	rts
; _______________________________________________
;
; Copie la zone de menus programme
; _______________________________________________
;
EdM_Program
	tst.b	EdM_Flag(a5)
	beq.s	.Done
	clr.b	EdM_Flag(a5)
	movem.l	a0/a1/d0/d1,-(sp)
	lea	EdM_Copie(a5),a1
	lea	Mn_SSave(a5),a0
	moveq	#(Mn_ESave-Mn_SSave)/2-1,d0
.Swap	move.w	(a0),d1
	move.w	(a1),(a0)+
	move.w	d1,(a1)+
	dbra	d0,.Swap
	movem.l	(sp)+,a0/a1/d0/d1
.Done	rts

;_____________________________________________________________________________
;
;					Access Disque sous editeur
;_____________________________________________________________________________
;
; Entete AMOS Basic
; ~~~~~~~~~~~~~~~~~
EnHead	dc.b	"AMOS ProEd.v    "
	even

;
; NAME1 already exist. Overwrite?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SaveOver
	JJsr	L_RExist
	beq.s	.Skip
	move.l	Ed_VDialogues(a5),a0
	move.l	Name1(a5),(a0)
	moveq	#EdD_AExist,d0
	bsr	Ed_Dialogue
	cmp.w	#1,d0
	bne	Ed_NotDone
.Skip	rts
;
; Sauve le programme si on l'a change!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Saved
	tst.b	Prg_Change(a6)
	beq.s	.Skip
; Cree la chaine avec le nom, en 0VA
	move.l	Buffer(a5),a0
	move.l	a0,a1
	moveq	#31,d0
.Clr	move.b	#" ",(a1)+
	dbra	d0,.Clr
	clr.b	(a1)
	bsr	Ed_NPrgToBuf
	clr.b	(a0)
	move.l	Buffer(a5),a0
	bsr	Ed_DChaine
	move.l	Ed_VDialogues(a5),a0
	move.l	a1,0*4(a0)
; Appelle la boite de dialogue
	moveq	#EdD_Saved,d0
	bsr	Ed_Dialogue
	cmp.w	#2,d0
	beq.s	.Skip
	cmp.w	#1,d0
	bne	Ed_NotDone2
	bsr	Ed_SaveIt
.Skip	rts


;
; Routine LOAD HIDDEN PROGRAM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_RLoadHidden
	move.w	#155,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
; Ouvre la structure fenetre cachee
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0				Hidden
	moveq	#0,d1				Structure vide
	bsr	Edt_OpWindow
	bne	Ed_OMm
	move.l	a4,Ed_WindowToDel(a5)
; Va charger le programme
; ~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#-1,d0				Adapter la taille du buffer
	JJsr	L_Prg_Load
	bne	Ed_PrgLoadErr
	move.b	#1,Prg_StModif(a6)		Force le test
; C'est bon!
; ~~~~~~~~~~
	bsr	Ed_AverFin
	rts

;
; LOAD HIDDEN PROGRAM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_LoadHidden
	bsr	Ed_TokCur
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#66,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
; Appelle la routine
; ~~~~~~~~~~~~~~~~~~
	bsr	Ed_RLoadHidden
	clr.l	Ed_WindowToDel(a5)
; Recalcule le menu
; ~~~~~~~~~~~~~~~~~
	bsr	EdM_BranchAMOS
	rts

;
; LOAD PROGRAMME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Load
	bsr	Ed_TokCur
	bsr	Ed_Saved
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#70,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
; NEW
; ~~~
	bsr	Ed_New2
; Message LOADING
; ~~~~~~~~~~~~~~~
Ed_ReLoad
	move.w	#155,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
; Charge
; ~~~~~~
	moveq	#1,d0			Revenir si pas assez grand
	JJsr	L_Prg_Load
	beq.s	EdLok
	bmi	Ed_PrgLoadErr
	move.l	d1,d0
	bsr	Ed_GetPlace
	bsr	Ed_AverFin
	bra.s	Ed_ReLoad
; Chargement correct
; ~~~~~~~~~~~~~~~~~~
EdLok	move.b	#1,Prg_StModif(a6)		Force le test
	bsr	Ed_AverFin
	bsr	Ed_NewBufAff
	rts

;
; Pointe le debut du nom reel du fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DNom
	move.l	a0,a1
.FaL1	tst.b	(a0)+
	bne.s	.FaL1
	subq.l	#1,a0
.FaL2	move.b	-(a0),d0
	cmp.b	#"/",d0
	beq.s	.FaL3
	cmp.b	#":",d0
	beq.s	.FaL3
	cmp.l	a1,a0
	bcc.s	.FaL2
.FaL3	addq.l	#1,a0
	rts

;
; MERGE PROGRAMME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Merge
	bsr	Ed_TokCur
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#78,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
; Libere de la memoire
; ~~~~~~~~~~~~~~~~~~~~
	bsr	Edt_ClearVar
	bsr	Ed_BlocFree
	bsr	Prg_UndoRaz
; Charge le programme dans une fenetre cach�e
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Ed_RLoadHidden
; Copie le bout dans le programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_StBas(a6),a0		Bas du source
	move.l	Prg_StHaut(a6),d0		Longueur du source
	sub.l	a0,d0
	subq.l	#2,d0
	ble.s	.Skip
	move.w	Prg_NLigne(a6),d7		Nombre de lignes
	move.l	Edt_Current(a5),a4		Program courant
	move.l	Edt_Prg(a4),a6
	move.w	Edt_YPos(a4),d1
	add.w	Edt_YCu(a4),d1
	move.w	d1,d6				Insere le programme
	bsr	Ed_StoBlock
	bne	Ed_OofBuf
	move.w	d6,d0				Change les marques
	move.w	d7,d1
	bsr	Ed_MarksChange
; La fenetre sera lib�r�e au retour
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Skip	JJsr	L_Prg_CptLines
	bsr	Ed_NewBufAff
	rts

;
; CHARGEMENT FICHIER ASCII
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_LoadA:
	bsr	Ed_TokCur
	bsr	Prg_UndoRaz
; Selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~
	moveq	#86,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
; Message
; ~~~~~~~
	move.w	#158,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
; Charge tout le fichier dans un buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1005,d2		Mode OLD
	bsr	Ed_Open
	beq	Ed_DError
	moveq	#0,d2			Seek --> fin
	moveq	#1,d3
	bsr	Ed_Seek
	move.l	d0,d2			Seek --> debut!
	moveq	#-1,d3
	bsr	Ed_Seek
	move.l	d0,d3			Reserve le buffer
	addq.l	#4,d0			Plus zero � la fin
	JJsr	L_ResTempBuffer
	beq	Ed_OMm
	move.l	a0,d2			Charge tout d'un bloc
	bsr	Ed_Read
	bne	Ed_DError		Ferme le fichier
	bsr	Ed_Close
; Boucle de tokenisation dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	Edt_YPos(a4),d7
	add.w	Edt_YCu(a4),d7
	move.l	TempBuffer(a5),a3	Cherche la fin
; Control-C?
.MergL	bclr	#BitControl-8,T_Actualise(a5)
	bne	.MergX
; Trouve la longueur de la ligne
	lea	-1(a3),a2
.Fin1	addq.l	#1,a2
	move.b	(a2),d0
	beq.s	.Fin4
	cmp.b	#32,d0
	bcc.s	.Fin1
	cmp.b	#10,d0
	beq.s	.Fin2
	cmp.b	#13,d0
	beq.s	.Fin2
	cmp.b	#9,d0			Tabs >>> Espace
	bne	.Bad
	move.b	#" ",(a2)
	bra.s	.Fin1
.Fin2	clr.b	(a2)
	cmp.b	#32,1(a2)
	bcc.s	.Fin4
	addq.l	#1,a2
.Fin4	move.l	a2,d0			Verifie la longueur
	sub.l	a3,d0
	cmp.l	#250,d0
	bcc.s	.Long
; Va tokeniser
	move.l	a3,a0
	lea	1(a2),a3
	move.l	Ed_BufT(a5),a1
	bsr	Tokenise
	bmi.s	.Long
; Stocke!
	moveq	#-1,d0			Insert
	move.w	d7,d1			Ligne courante
	move.l	Ed_BufT(a5),a1
	bsr	Ed_Stocke
	bne	.OBuf
	addq.w	#1,d7
	addq.w	#1,Prg_NLigne(a6)
; Reaffiche le slider
	movem.l	a2/a3/d7,-(sp)
	bsr	Ed_AffSlV
	movem.l	(sp)+,a2/a3/d7
; Encore une ligne?
	tst.b	(a3)
	bne	.MergL
; Termine
.MergX	moveq	#0,d0
	JJsr	L_ResTempBuffer
	bsr	Ed_AverFin
	JJsr	L_Prg_CptLines
	bsr	Ed_NewBufAff
	SyCall	ClearKey
	rts
; Out of buffer space
.OBuf	bsr	.MergX
	bra	Ed_OofBuf
; Line too long / Bad file
.Bad
.Long	bsr	.MergX
	bra	Ed_LToLong

;
; SAUVEGARDE PROGRAMME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Rename le programme cournant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Rename
	move.l	Name1(a5),a0
	lea	Prg_NamePrg(a6),a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
	move.b	#1,Prg_Change(a6)
	bset	#EtA_Nom,Edt_EtatAff(a4)
	rts

; Sauvegarde speciale COMPILER_SHELL.AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SaveAsName
; Sauvegarde le non dans la pile
	lea	Prg_NamePrg(a6),a0
	lea	-128(sp),sp
	move.l	sp,a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
; Sauve le programme, sans .BAK
	bsr	Ed_SavePrg2
; Remet le nom
	move.l	sp,a0
	lea	Prg_NamePrg(a6),a1
.Copy1	move.b	(a0)+,(a1)+
	bne.s	.Copy1
	lea	128(sp),sp
; Erreur?
	tst.w	d0
	bne	Ed_DError
	rts

Ed_SaveAs
	bsr	Ed_TokCur
	bra.s	Ed_SvAs
Ed_Save
	bsr	Ed_TokCur
Ed_SaveIt
; Demander le nom?
; ~~~~~~~~~~~~~~~~
	lea	Prg_NamePrg(a6),a0
	tst.b	(a0)
	beq.s	Ed_SvAs
	move.l	Name1(a5),a1
	bsr	EdCocop
	JJsr	L_Dsk.PathIt
	bra.s	Ed_Sv
; Ouvre le selecteur de fichiers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SvAs	moveq	#74,d0
	bsr	Ed_File_Selector
	beq	Ed_NotDone
	JJsr	L_Dsk.PathIt
; Sauve le programme!
; ~~~~~~~~~~~~~~~~~~~
Ed_Sv	move.w	#154,d0
	move.l	Name1(a5),a0
	bsr	Ed_AvName
	bsr	Ed_SavePrg
	bne	Ed_DError
	bsr	Ed_AverFin
	bset	#EtA_Nom,Edt_EtatAff(a4)
	rts
; Sauve le programme (a4), nom NAME1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SavePrg
; Fabrique NOM.BAK
; ~~~~~~~~~~~~~~~~
	tst.b	Ed_SvBak(a5)
	beq	.PaBak
	bsr	Ed_MakeBak
	bne.s	SError
.PaBak
Ed_SavePrg2
; Fait le m�nage!
; ~~~~~~~~~~~~~~~
	bsr	Edt_ClearVar
	JJsr	L_Prg_CptLines
; Va sauver
; ~~~~~~~~~
	JJsr	L_Prg_Save
	bne.s	SError
	move.b	#1,Prg_StModif(a6)	Force le menage
; Sauve l'icone
; ~~~~~~~~~~~~~
	bsr	Ed_SaveIcon
; Pas d'erreur
; ~~~~~~~~~~~~
	moveq	#0,d0
SOut	rts
; Erreur dans la sauvegarde
; ~~~~~~~~~~~~~~~~~~~~~~~~~
SError	moveq	#-1,d0
	bra.s	SOut


;
; FABRIQUE UN .BAK de NAME1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_MakeBak
	movem.l	a0-a2/a6/d0-d2,-(sp)
	move.l	Name1(a5),a0
	move.l	Name2(a5),a1
.Bak1	move.b	(a0)+,(a1)+
	bne.s	.Bak1
; Trouve le DERNIER "."
	move.l	a1,a0
	subq.l	#1,a1
.Bak2	cmp.l	Name2(a5),a0
	ble.s	.Bak3
	cmp.b	#".",-(a0)
	bne.s	.Bak2
	move.l	a0,a1
; Recopie le .BAK
; ~~~~~~~~~~~~~~~
.Bak3	moveq	#21,d0
	bsr	Ed_GetSysteme
.Bak4	move.b	(a0)+,(a1)+
	bne.s	.Bak4
; Renomme NOM.AMOS si present
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Bak5	move.l	DosBase(a5),a6
	move.l	Name1(a5),d1
	move.l	Name2(a5),d2
	jsr	_LVORename(a6)
	tst.l	d0
	bne.s	.Ok
	jsr	_LVOIoErr(a6)
	cmp.w	#215,d0			D'un periph � l'autre?
	beq.s	.Ok
	cmp.w	#205,d0			Existe pas
	beq.s	.Ok
	cmp.w	#203,d0			Existe DEJA
	bne	.Err
; Efface NOM.BAK et recommence!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Name2(a5),d1
	jsr	_LVODeleteFile(a6)
	tst.l	d0
	bne	.Bak5
; Une erreur!
; ~~~~~~~~~~~
.Err	moveq	#-1,d0
	bra.s	.Out
; Ok!
; ~~~
.Ok	moveq	#0,d0
.Out	movem.l	(sp)+,a0-a2/a6/d0-d2
	rts

;
; SAUVEGARDE ICONE PROGRAMME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_SaveIcon
	movem.l	d0-d1/a0-a1/a6,-(sp)
	tst.b	PI_Icons(a5)
	beq.s	.Ok
	move.l	IconBase(a5),d0
	beq.s	.Ok
	move.l	d0,a6
	move.l	AdrIcon(a5),d0
	beq.s	.Ok
	move.l	d0,a1
	move.l	Name1(a5),a0
	jsr	-84(a6)
.Ok	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

;
; ERREUR DISQUE SOUS EDITEUR
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Ed_DiskError
; Arret du flag
; ~~~~~~~~~~~~~
;	clr.w	Ed_Disk(a5)
; Trouve l'erreur
; ~~~~~~~~~~~~~~~
;	move.l	Ed_RunMessages(a5),a0
;	addq.w	#1,d0
;	bsr	Ed_GetMessageA0
;	movem.l	a0/d0,-(sp)
;	bsr	Ed_BufUntok
;	movem.l	(sp)+,a0/d0
; ALERTE!
; ~~~~~~~
;	moveq	#125,d0
;	bra	Ed_Alert

; ___________________________________________________________________
;
; 					DIVERS
; ___________________________________________________________________
;
; Agrandi une image aux dimensions de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 	D0=	Y1
;	D1= 	Y2
;
Ed_Enlarge
	movem.l	a0-a2/d0-d5,-(sp)
	move.l	T_EcAdr+EcEdit*4(a5),a0
	move.l	a0,a1
	ext.l	d0
	ext.l	d1
	move.l	d1,d5
	move.l	d0,d1
	move.l	d0,d3
	move.l	#160,d0
	move.l	#480,d4
	move.w	Ed_Sx(a5),d2
	sub.w	#480-160,d2
	ext.l	d2
	JJsrR	L_ScCopy,a2
	movem.l	(sp)+,a0-a2/d0-d5
	rts

;
; Copie la palette de la souris dans l'�cran A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Ecran Destination
;
Ed_CopyPal
	lea	EcPal+32(a0),a0
	lea	PI_DefEPa+32(a5),a1
	moveq	#16-1,d0
.loop	move.w	(a1)+,(a0)+
	dbra	d0,.loop
	rts
; _____________________________________________________
;
;	Attente souris dans le titre
; _____________________________________________________
;
Ed_TiWait
	move.w	d0,-(sp)
.loop	JJsr	L_Sys_WaitMul
	SyCall	Inkey
	tst.l	d1
	bne.s	.end
	SyCall	MouseKey
	and.w	#%111,d1
	bne.s	.end
	subq.w	#1,(sp)
	bne.s	.loop
.end	addq.l	#2,sp
	rts

;
; Unpack Image de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	D0=	Numero
;	D1=	X
;	D2=	Y
;
Es_Unpack
	move.l	T_EcAdr+EcFonc*4(a5),a1
	bra.s	EdU
Ed_Unpack
	move.l	T_EcAdr+EcEdit*4(a5),a1
EdU	move.l	Ed_Resource(a5),a0
	add.l	2(a0),a0
	lsl.w	#2,d0
	add.l	-4+2(a0,d0.w),a0
	ext.l	d1
	ext.l	d2
	JJsrP	L_UnPack_Bitmap,a2
	rts

; ___________________________________________________________________
;
; 						ROUTINES BOUTONS
; ___________________________________________________________________
;
Bt_RoutIn
	bra	Ed_BtWindowClose		1- Close window
	bra	Ed_BtWindowHide			2- Hide window
	bra	Ed_BtWindowSize			3- Shrink window
	bra	Bt_EsCDraw			4- Dessin bouton escape
	bra	Esc_BtGetOutput			5- Position actuelle OUTPUT
	bra	Bt_EdDraw			6- Dessin d'un bouton
; Dessin d'un bouton ESCAPE!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Bt_EsCDraw
	move.l	d2,-(sp)
	move.w	Bt_Image(a2),d0
	add.w	Bt_Pos(a2),d0
	move.w	Bt_X(a2),d1
	move.w	Bt_Y(a2),d2
	bsr	Es_Unpack
	move.l	(sp)+,d2
	rts
; Dessin d'un bouton EDITOR!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Bt_EdDraw
	move.l	d2,-(sp)
	move.w	Bt_Image(a2),d0
	add.w	Bt_Pos(a2),d0
	move.w	Bt_X(a2),d1
	move.w	Bt_Y(a2),d2
	bsr	Ed_Unpack
	move.l	(sp)+,d2
	rts

;
; Gestion des boutons speciaux
; ____________________________________
;
EdK_MarkAll
	move.b	Ed_Insert(a5),d0
	and.w	#$0001,d0
	bchg	#0,d0
	lea	Ed_Boutons+(Bt_Insert-1)*Bt_Long(a5),a2
	move.w	d0,Bt_Pos(a2)
	bsr	Bt_EdDraw
.Skip	rts

; ___________________________________________________________________
;
;						ACCES DISQUE EDITEUR
; ___________________________________________________________________
;


; OPEN: ouvre le fichier systeme (diskname1) access mode D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Open	move.l 	Name1(a5),d1
Ed_OpenD1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	move.l	d0,Handle(a5)
	rts

; CLOSE fichier systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Close
	move.l	Handle(a5),d1
	beq.s	.Skip
	clr.l	Handle(a5)
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
.Skip	rts

; READ fichier systeme D3 octets dans D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Read	movem.l	d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVORead(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts

; WRITE fichier systeme D3 octets de D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Write
	movem.l	d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts

; SEEK fichier system D3 mode D2 deplacement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Seek	move.l	Handle(a5),d1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	rts
;
; Ouverture de l'imprimante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PRTOpen
	moveq	#43,d0
	JJsr	L_Sys_GetMessage
	move.l	a0,d1
	move.l	#1005,d2
	bsr	Ed_OpenD1
	beq.s	Ed_PErr
	rts
Ed_PErr	move.w	#216,d0
	bra.s	Ed_DBis
;
; Imprime la chaine A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PRTPrint
	move.l	a0,d2
	move.l	a0,a1
.Ip1	move.b	(a0)+,d0
	move.b	d0,(a1)+
	beq.s	.Ip2
	cmp.b	#13,d0
	bne.s	.Ip1
	tst.b	PI_PrtRet(a5)
	bne.s	.Ip1
	cmp.b	#10,(a0)
	bne.s	.Ip1
	move.b	(a0)+,-1(a1)
	bra.s	.Ip1
; Nouvelle longueur
.Ip2	sub.l	d2,a0
	subq.l	#1,a0
	move.l	a0,d3
	bsr	Ed_Write
	bne	Ed_PErr
	rts
;
; Erreurs dans le chargement programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_PrgLoadErr
	cmp.w	#-2,d0
	beq	Ed_OMm
	cmp.w	#-3,d0
	beq	Ed_PaAMOS
;
; Gestion des erreurs disque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DError
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOIoErr(a6)
	move.l	(sp)+,a6
	lea	ErDisked(pc),a0
	moveq	#DEBase-1,d1
.Explo	addq.l	#1,d1
	move.b	(a0)+,d2
	beq.s	Paerr
	cmp.b	d0,d2
	bne.s	.Explo
	move.w	d1,d0
	addq.w	#1,d0
; Imprime le message
Ed_DBis	move.l	Ed_RunMessages(a5),a0
	bsr	Ed_GetMessageA0
; En cas de ZAPPEUSE, branche � ALERT normal
	tst.b	Ed_Zappeuse(a5)
	bne	Ed_ZapAlert
; Boite de dialogue
	move.l	Ed_VDialogues(a5),a1
	move.l	a0,0*4(a1)
	bsr	Ed_RazAlert
	moveq	#"G",d0			Va faire du bruit!
	bsr	Ed_SamPlay
	moveq	#EdD_DiskErr,d0
	bsr	Ed_Dialogue
	bra	Ed_Loop
Paerr	moveq	#DEBase+22+1,d0
	bra.s	Ed_DBis
; Table des erreurs reconnues
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
ErDisked
	dc.b 203,204,205,210,213,214,216,218
	dc.b 220,221,222,223,224,225,226,0
	even

; Appel du selecteur de fichier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_File_Selector
	tst.b	Ed_Zappeuse(a5)		Zappeuse>>> on revient !
	bne.s	.Zap
	movem.l	a2-a3/d2-d7,-(sp)
	bsr	Ed_GetMessage
	pea	-2(a0)
	bsr	Ed_GetNMessage
	pea	-2(a0)
	bsr	Ed_GetNMessage
	pea	-2(a0)
	bsr	Ed_GetNMessage
	pea	-2(a0)
	move.l	sp,a3
	move.w	#1,Ed_FSel(a5)
	bsr	Ed_SetBanks
	JJsr	L_Dsk.FileSelector
	clr.w	Ed_FSel(a5)
	lea	16(sp),sp
	movem.l	(sp)+,a2-a3/d2-d7
	tst.w	d0
	rts
.Zap	moveq	#1,d0
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TOKENISATION / DETOKENISATION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Initialisation des tables de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tok_Init
	tst.l	Ed_BufT(a5)
	bne	MTokX
; Reserve le buffer de tokenisation...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#EdBTT,d0
	SyCall	MemFastClear
	beq	MTError
	move.l	a0,Ed_BufT(a5)
; Fabrique les tables de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1024*12,d0
	JJsr	L_ResTempBuffer
	beq	MTError
	lea	AdTokens(a5),a3
	lea	AdTTokens(a5),a4
	moveq	#-4,d7
MTok1	addq.w	#4,d7
	cmp.w	#26*4,d7
	bcc	MTokX
	move.l	0(a3,d7.w),d6
	beq.s	MTok1
	move.l	d6,a1
	addq.l	#6,a1
; Premiere table
	move.l	TempBuffer(a5),a6
	move.l	a6,a0
	lea	2048(a0),a2
	moveq	#0,d0
MTok2	move.l	a1,d1
	lea	4(a1),a1
MTok0	move.b	(a1)+,d0
	bpl.s	MTok3
	and.w	#$7f,d0
	subq.l	#1,a1
MTok3	cmp.b	#"!",d0
	beq.s	MTok0
	cmp.b	#" ",d0
	beq.s	MTok0
	bsr	MnD0
	cmp.b	#"a",d0
	bcs.s	MTok4
	cmp.b	#"z",d0
	bhi.s	MTok4
	move.w	d0,(a0)+
	sub.l	d6,d1
	move.w	d1,(a2)+
MTok4	bsr	EdlNext
	bne.s	MTok2
	move.w	#-1,(a0)+
; Deuxieme table
	move.l	a0,d0
	sub.l	a6,d0
	add.l	#26*4+2+4,d0
	move.l	d0,d1
	SyCall	MemFastClear
	beq	MTError
	move.l	a0,0(a4,d7.w)
	move.l	a0,a1
	move.l	a0,d3
	move.l	d1,(a1)+
	lea	26*2+2(a1),a2
	moveq	#"a",d5
	move.w	#2048,d4
MTok5	move.l	a2,d0
	sub.l	d3,d0
	move.w	d0,(a1)+
	move.l	a6,a0
MTok6	move.w	(a0)+,d0
	bmi.s	MTok7
	cmp.w	d0,d5
	bne.s	MTok6
	move.w	-2(a0,d4.w),(a2)+
	bra.s	MTok6
MTok7	clr.w	(a2)+
	addq.w	#1,d5
	cmp.w	#"z",d5
	bls.s	MTok5
	clr.w	(a1)+
	bra	MTok1
MTokX	moveq	#0,d0
	JJsr	L_ResTempBuffer
	moveq	#0,d0
	rts
; Out of memory!
; ~~~~~~~~~~~~~~
MTError	moveq	#0,d0
	JJsr	L_ResTempBuffer
	moveq	#1,d0
	rts
; Routine: token suivant
; ~~~~~~~~~~~~~~~~~~~~~~
EdlNext	tst.b	(a1)+			; Saute le nom
	bpl.s	EdlNext
.Tkln1	tst.b	(a1)+			; Saute les params
	bpl.s	.Tkln1
	move.w	a1,d1
	btst	#0,d1			; Rend pair
	beq.s	.Tkln2
	addq.l	#1,a1
.Tkln2	tst.w	(a1)
	rts
; Routine: D0 minuscule
MnD0	cmp.b	#"A",d0
	bcs.s	.Mnd0a
	cmp.b	#"Z",d0
	bhi.s	.Mnd0a
	add.b	#32,d0
.Mnd0a	rts

; Effacement de la tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tok_Del
; Efface le buffer de tokenisation
	move.l	Ed_BufT(a5),d0
	beq.s	DlTkX
	clr.l	Ed_BufT(a5)
	move.l	d0,a1
	move.l	#EdBTT,d0
	SyCall	MemFree
; Efface les tables de tokens rapide
	lea	AdTTokens(a5),a2
	moveq	#25,d1
DlTk1	move.l	(a2)+,d0
	beq.s	DlTk2
	clr.l	-4(a2)
	move.l	d0,a1
	move.l	(a1),d0
	SyCall	MemFree
DlTk2	dbra	d1,DlTk1
DlTkX	rts


***********************************************************
*	TOKENISE LA LIGNE COURANTE
***********************************************************
Tokenise:
	movem.l	a1-a6/d2-d7,-(sp)	* Sauve le debut de la ligne
	move.l	a1,a4
	move.l	a0,a3
	pea	512(a4)
	clr.w	d5			* RAZ de tous les flags
	clr.w	(a4)+

******* Compte les TABS
	moveq	#0,d1
TokT:	addq.w	#1,d1
	move.b	(a3)+,d0
	beq	TokVide
	cmp.b	#32,d0
	beq.s	TokT
	subq.l	#1,a3
	cmp.w	#127,d1
	bcs.s	TokT1
	moveq	#127,d1
TokT1:	move.b	d1,-1(a4)

******* Un chiffre au debut de la ligne?
	move.b	(a3),d0
	cmp.b	#"0",d0
	bcs.s	TokT2
	cmp.b	#"9",d0
	bhi.s	TokT2
	bset	#1,d5		* Flag VARIABLE
	bset 	#4,d5		* Flag LABEL
	move.l	a4,TkAd(a5)
	move.w	#_TkVar,(a4)+
	clr.l	(a4)+
	move.b	(a3)+,(a4)+

******* Une apostrophe en debut de ligne?
TokT2:	cmp.b 	#"'",d0
	bne.s	TokLoop
	addq.l	#1,a3
	move.w	#_TkRem2,(a4)+
	bra	TkKt2

*******	Prend une lettre
TokLoop:
	cmp.l	(sp),a4
	bhi	TokFin
	move.b	(a3)+,d0
	beq	TokFin

* Rem en route?
	btst	#5,d5
	beq.s	TkROn
	move.b	d0,(a4)+
	bra.s	TokLoop
TkROn:

* Variable en route?
	btst	#1,d5
	bne	TkVD

* Chaine en route?
	btst	#0,d5
	beq.s	TkC2
	cmp.b	TkChCar(a5),d0
	beq.s	TkC1
	move.b	d0,(a4)+
	bra.s	TokLoop
* Fin d'une chaine alphanumerique
TkChf:	subq.l	#1,a3
TkC1:	bclr	#0,d5
	move.l	a4,d0
	btst	#0,d0
	beq.s	TkC0
	clr.b	(a4)+
TkC0:	move.l	TkAd(a5),a0
	sub.l	a0,d0
	subq.w	#4,d0
	move.w	d0,2(a0)
	bra.s	TokLoop
* Debut d'une chaine alphanumerique?
TkC2:	cmp.b	#'"',d0
	beq 	TkC2a
	cmp.b	#"'",d0
	bne	TkOtre
TkC2a:	move.b	d0,TkChCar(a5)
	move.l	a4,TkAd(a5)
	cmp.b	#"'",d0
	beq.s	TkC2b
	move.w	#_TkCh1,(a4)+
	bra.s	TkC2c
TkC2b:	move.w	#_TkCh2,(a4)+
TkC2c:	clr.w	(a4)+
	bset	#0,d5
	bra.s	TokLoop

* Variable en route
TkVD:	bsr	Minus
* Numero de ligne en route
TkFV:	moveq	#0,d1
	move.l	TkAd(a5),a0
	btst	#4,d5
	beq.s	TkV2
	cmp.b	#"0",d0
	bcs.s	TkV0
	cmp.b	#"9",d0
	bls.s	TkV3
TkV0:	bset	#3,d5		Fin du debut de ligne!
	bclr	#4,d5		Fin du numero de ligne
	cmp.b	#":",d0
	beq.s	TkV1
	subq.l	#1,a3
	bra.s	TkV1
* Variable normale / label
TkV2:	cmp.b	#"_",d0
	beq.s	TkV3
	cmp.b	#"0",d0
	bcs.s	TkV4
	cmp.b	#"9",d0
	bls.s	TkV3
	cmp.b	#"a",d0
	bcs.s	TkV4
	cmp.b	#"z",d0
	bls.s	TkV3
	cmp.b	#128,d0
	bls.s	TkV4
TkV3:	move.b	d0,(a4)+
	bra	TokLoop
* Fin de la variable/label/label goto
TkV4:	bset	#3,d5		* Si pas debut de ligne
	bne.s	TkV5
	cmp.b	#":",d0		* Si :
	bne.s	TkV5
TkV1:	move.w	#_TkLab,(a0)
	bra.s	TkV7

TkV5:	subq.l	#1,a3
	moveq	#2,d1
	cmp.b	#"$",d0
	beq.s	TkV6
	moveq	#1,d1
	cmp.b	#"#",d0
	beq.s	TkV6
	moveq	#0,d1
	bra.s	TkV7
TkV6:	addq.w	#1,a3
TkV7:	move.w	a4,d2		* Rend pair
	btst	#0,d2
	beq.s	TkV8
	clr.b	(a4)+
TkV8:	move.l	a4,d0
	sub.l	a0,d0
	subq.l	#6,d0
	move.b	d0,4(a0)	* Poke la longueur
	move.b	d1,5(a0)	* Poke le flag
	bclr	#1,d5
	bra	TokLoop

* Saute les 32
TkOtre:	cmp.b	#" ",d0
	beq	TokLoop

* Est-ce un chiffre?
	lea	-1(a3),a0	Pointe le debut du chiffre
	moveq	#0,d0		Ne pas tenir compte du signe (valtok)
	move.l	a4,-(sp)
	move.l	AdTokens(a5),a4	Prend la base des jumps
	JJsrR	L_ValRout,a1
	move.l	(sp)+,a4
	bne.s	TkK
	move.l	a0,a3
	move.w	d1,(a4)+
	move.l	d3,(a4)+
	cmp.w	#_TkDFl,d1
	bne	TokLoop
	move.l	d4,(a4)+
	bra	TokLoop
TkK:

******* Tokenisation RAPIDE!
	moveq	#-4,d7			* D7--> Numero de l'extension
	lea	AdTokens(a5),a6
	moveq	#0,d3
	lea	-10(sp),sp
* Prend le premiere caractere...
	moveq	#0,d0
	move.b	-1(a3),d0
	bsr	MinD0
	move.l	d0,d2
	lea	Dtk_Operateurs(pc),a1	Operateur, LENTS en 1er...
	bra	TkLIn
* Lent ou rapide?
TkUn	cmp.b	#"a",d2
	bcs.s	Tkl1
	cmp.b	#"z",d2
	bhi.s	Tkl1
	bset	#31,d2
	move.w	d2,d6
	sub.w	#"a",d6
	lsl.w	#1,d6
* Mode rapide: init!
Tkr1	lea	AdTTokens(a5),a2
	move.l	0(a2,d7.w),d0
	beq.s	Tkl1
	move.l	d0,a2
	move.w	4(a2,d6.w),d0
	add.w	d0,a2			* A2-> Adresse des adresses
	bset	#31,d6
	bra	TkRNext
* Tokens lents
Tkl1	move.l	0(a6,d7.w),d0
	beq	TkNext
	move.l	d0,a1
	addq.l	#6,a1
TkLIn	bclr	#31,d6
	cmp.b	#"!",d2			Entree pour les operateurs...
	beq	TkKF
	cmp.b	#"?",d2
	bne.s	Tkl2
	move.l	a3,a0
Tkl1a	move.b	(a0)+,d0		* ? PRINT / ? PRINT #
	beq.s	Tkl1b
	cmp.b	#"#",d0
	beq.s	Tkl1c
	cmp.s	#" ",d0
	beq.s	Tkl1a
Tkl1b	move.w	#_TkPr,d4
	bra	TkKt0
Tkl1c	move.l	a0,a3
	move.w	#_TkHPr,d4
	bra	TkKt0
Tkl2	move.l	a1,d4			* Recherche la 1ere lettre
	lea	4(a1),a1
	move.w	d2,d0
Tkl0	move.b	(a1)+,d1
	bmi	Tkl4
	cmp.b	#" ",d1
	beq.s	Tkl0
	cmp.b	#"!",d1
	beq.s	Tkl0
	cmp.b	d0,d1
	beq.s	TkRe0
Tkl3	bsr	TklNext
	bne.s	Tkl2
* Tableau de token suivant!
TkNext	addq.l	#4,d7
	beq	TkUn
	cmp.l	#4*26,d7
	bcc.s	.TrouV
	tst.l	d2
	bpl.s	Tkl1
	bra	Tkr1
.TrouV	tst.w	d3
	beq	TkKF
	move.l	(sp),d4
	move.l	4(sp),a3
	move.w	8(sp),d7
	bra	TklT
* Trouve 1 lettre lent?
Tkl4	subq.l	#1,a1
	and.b	#$7f,d1
	cmp.b	#" ",d1
	beq	TklT
	cmp.b	d0,d1
	bne.s	Tkl3
	bra	TklT
* Token rapide suivant
TkRNext	move.w	(a2)+,d0
	beq	TkNext
	move.l	0(a6,d7.w),a1
	add.w	d0,a1
	move.l	a1,d4
	lea	5(a1),a1
	move.b	-1(a1),d0
	cmp.b	#"!",d0
	beq.s	TkRe0a
	cmp.b	#" ",d0
	bne.s	TkRe0
TkRe0a	addq.l	#1,a1
* Explore les autres lettres du token
TkRe0	move.l	a3,a0
TkRe1	move.b	(a0)+,d0
	bsr	MinD0
TkRe2	move.b	(a1)+,d1
	bmi.s	TkKt
	cmp.b	#" ",d1
	bne.s	TkRe3
	cmp.b	d1,d0
	bne.s	TkRe2
	beq.s	TkRe1
TkRe3	cmp.b	d0,d1
	beq.s	TkRe1
* Mot cle suivant
TkRe4	tst.l	d6
	bpl	Tkl3
	bmi.s	TkRNext
* Mot trouve?
TkKt:	subq.l	#1,a0
	subq.l	#1,a1
	and.b	#$7f,d1
	cmp.b	#" ",d1
	beq.s	TkKt1
	cmp.b	d0,d1
	bne.s	TkRe4
	addq.l	#1,a0
TkKt1:
	tst.l	d6
	bpl.s	TklTl
	move.l	a1,d0
	sub.l	d4,d0
	cmp.w	d3,d0
	bls.s	TkRe4
	move.w	d0,d3
	move.l	d4,(sp)
	move.l	a0,4(sp)
	move.w	d7,8(sp)
	bra.s	TkRe4
TklTl	move.l	a0,a3
*** Token trouve!
TklT	tst.w	d7			Une extension
	bgt	TkKtE
	beq.s	.Norm			Un operateur?
	lea	Dtk_OpFin(pc),a0
	sub.l	a0,d4
	bra.s	TkKt0
.Norm	sub.l	AdTokens(a5),d4		Un token librairie principale
TkKt0:	lea	10(sp),sp
	move.w	d4,(a4)+
	bclr	#4,d5			Plus de numero de ligne
	bset	#3,d5			Plus debut de ligne
	cmp.w	#_TkEqu,d4		Tokens de structure?
	bcs.s	.SkS
	cmp.w	#_TkStruS,d4
	bls	TkKt5
.SkS	cmp.w	#_TkOn,d4
	beq.s	TkKt7
	cmp.w	#_TkData,d4
	beq	TkKt3
	cmp.w	#_TkRem1,d4
	beq.s	TkKt2
	cmp.w	#_TkFor,d4
	beq.s	TkKt3
	cmp.w	#_TkRpt,d4
	beq.s	TkKt3
	cmp.w	#_TkWhl,d4
	beq.s	TkKt3
	cmp.w	#_TkDo,d4
	beq.s	TkKt3
	cmp.w	#_TkExit,d4
	beq.s	TkKt4
	cmp.w	#_TkExIf,d4
	beq.s	TkKt4
	cmp.w	#_TkIf,d4
	beq.s	TkKt3
	cmp.w	#_TkElse,d4
	beq.s	TkKta
	cmp.w	#_TkElsI,d4
	beq.s	TkKt3
	cmp.w	#_TkThen,d4
	beq.s	TkKtb
	cmp.w	#_TkProc,d4
	beq.s	TkKt6
	cmp.w	#_TkDPre,d4
	beq.s	TkKDPre
	bra	TokLoop
* ON
TkKt7:	clr.l	(a4)+
	bra	TokLoop
* Debut d'une REM
TkKt2:	clr.w	(a4)+
	move.l	a4,TkAd(a5)
	bset	#5,d5
	bra	TokLoop
* Poke les blancss
TkKt6	clr.w	(a4)+		8 octets
TkKt5	clr.w	(a4)+		6 octets
TkKt4	clr.w	(a4)+		4 octets
TkKt3	clr.w	(a4)+		2 octets
	bra	TokLoop
* Token double precision: flags � 1
TkKDPre	or.b	#%10000011,MathFlags(a5)
	bra	TokLoop
* Token d'extension! .w EXT/.b #Ext/.b Nb Par/.w TOKEN
TkKtE:	lea	10(sp),sp
	move.w	#_TkExt,(a4)+
	move.w	d7,d0
	lsr.w	#2,d0
	move.b	d0,(a4)+
	clr.b	(a4)+
	lea	AdTokens(a5),a6
	sub.l	0(a6,d7.w),d4
	move.w	d4,(a4)+
	bclr	#4,d5
	bset	#3,d5
	bra	TokLoop
* ELSE/THEN: regarde si numero de ligne apres!
TkKta:	clr.w	(a4)+
TkKtb:	move.l	a3,a0
TkKtc:	move.b	(a0)+,d0
	beq	TokLoop
	cmp.b	#" ",d0
	beq	TkKtc
	cmp.b	#"0",d0
	bcs	TokLoop
	cmp.b	#"9",d0
	bhi	TokLoop
	move.l	a0,a3
	move.w	#_TkLGo,d1
	bra.s	TkKf2

******* Rien trouve ===> debut d'une variable
TkKF:	lea	10(sp),sp
	move.w	#_TkVar,d1
	move.b	-1(a3),d0
TkKf0:	cmp.b	#"A",d0
	bcs.s	TkKf1
	cmp.b	#"Z",d0
	bhi.s	TkKf1
	add.b	#"a"-"A",d0
TkKf1:	cmp.b	#"_",d0
	beq.s	TkKf2
	cmp.b	#128,d0
	bcc.s	TkKf2
	cmp.b	#"a",d0
	bcs	TokLoop
	cmp.b	#"z",d0
	bhi	TokLoop
TkKf2:	move.l	a4,TkAd(a5)
	move.w	d1,(a4)+
	clr.l	(a4)+
	move.b	d0,(a4)+
	bset 	#1,d5
	bra	TokLoop
* Appel d'un label?
TkKf3:	move.w	#_TkLGo,d1
	cmp.b	#"0",d0
	bcs.s	TkKf0
	cmp.b	#"9",d0
	bls.s	TkKf2
	bra.s	TkKf0

******* Fin de la tokenisation
TokFin:	btst	#1,d5		Fin de variable
	bne	TkFV
	btst	#0,d5		Fin de chaine alphanumerique
	bne	TkChf

	moveq	#1,d0		* Quelquechose dans la ligne!

	btst	#5,d5		REM
	beq.s	TokPaR
	move.w	a4,d1
	btst	#0,d1		Rend pair la REM!
	beq.s	FRem
	move.b	#" ",(a4)+
FRem:	move.l	a4,d1		Calcule et stocke la longueur
	move.l	TkAd(a5),a0
	sub.l	a0,d1
	move.w	d1,-2(a0)
* Marque la fin
TokPaR:	clr.w	(a4)+
	clr.w	(a4)
* Poke la longueur de la ligne / 2
	move.l	a4,d1
	addq.l	#4,sp
	movem.l	(sp)+,a1-a6/d2-d7
	sub.l	a1,d1
	cmp.w	#510,d1
	bcc.s	.Long
	lsr.w	#1,d1
	move.b	d1,(a1)
	lsl.w	#1,d1
	ext.l	d1
* Fini!
	tst.w	d0
	rts
* Trop longue!
.Long	clr.w	(a1)		* <0= Trop longue
	moveq	#0,d1
	moveq	#-1,d0
	rts
* Ligne vide!
TokVide	moveq	#0,d0		* = 0 Vide
	moveq	#0,d1
	bra.s	TokPaR

* Routine: D0 minuscule
MinD0	cmp.b	#"A",d0
	bcs.s	Mnd0a
	cmp.b	#"Z",d0
	bhi.s	Mnd0a
	add.b	#32,d0
Mnd0a	rts
* Routine: token suivant
TklNext	tst.b	(a1)+			* Saute le nom
	bpl.s	TklNext
Tkln1	tst.b	(a1)+			* Saute les params
	bpl.s	Tkln1
	move.w	a1,d1
	btst	#0,d1			* Rend pair
	beq.s	Tkln2
	addq.l	#1,a1
Tkln2	tst.w	(a1)
	rts


; ___________________________________________________________________________
;
;							DETOKENISATION
; ___________________________________________________________________________
;
;	A0:	Ligne � detokeniser
; 	A1:	Buffer
;	D0:	Adresse � d�tecter
; ___________________________________________________________________________
;
Mon_Detok
	moveq	#-1,d1
	bra.s	Dtk
Detok:
	moveq	#0,d1
Dtk
	movem.l	d2-d7/a2-a6,-(sp)
	lea	2(a1),a4		* Place pour la taille
	move.l	a0,a6
	move.l	d0,a3
	move.l	a4,a2
	clr.w	-(sp)			* Position du curseur

******* Met les espaces devant?
	tst.w	d1			Mode monitor
	bne.s	DtkMon
	tst.b	(a6)			Mode normal
	beq	DtkFin
	clr.w	d0
	move.b	1(a6),d0
	subq.w	#2,d0
	bmi.s	Dtk2
Dtk1:	move.b	#" ",(a4)+
	dbra	d0,Dtk1
Dtk2:	addq.l	#2,a6
DtkMon	clr.w	d5

******* Boucle de detokenisation
DtkLoop:cmp.l	a3,a6			Trouve la P en X?
	bne.s	Dtk0
	move.l	a4,d0
	sub.l	a2,d0
	move.w	d0,(sp)
Dtk0:	move.l	a3,d0			Detournement?
	bpl.s	.Skip
	neg.l	d0
	move.l	d0,a0
	jsr	(a0)
.Skip	move.w	(a6)+,d0
	beq	DtkFin
	cmp.w	#_TkLGo,d0
	bls	DtkVar
	cmp.w	#_TkExt,d0
	bcs	DtkCst
	bclr	#0,d5
	tst.w	d0
	bmi	DtkOpe				Un operateur?
	lea	AdTokens(a5),a0
	cmp.w	#_TkPar1,d0
	beq	DtkP
	cmp.w	#_TkDFl,d0
	beq	DtkCst
	cmp.w	#_TkExt,d0
	bne.s	Dtk0a

* Detokenise une extension
	move.w	2(a6),d1
	move.b	(a6),d2
	ext.w	d2
	move.w	d2,d3
	lsl.w	#2,d2
	tst.l	0(a0,d2.w)
	beq.s	DtkEe
	move.l	0(a0,d2.w),a0
	lea	4(a0,d1.w),a0
	move.l	a0,a1
	bra.s	Dtk3
* Extension not present
DtkEe:	lea	ExtNot(pc),a0
	add.b	#"A",d3
	add.b	#$80,d3
	move.l	a0,a1
DtkEee	tst.b	(a1)+
	bpl.s	DtkEee
	move.b	d3,-1(a1)
	move.w	#"I",d3
	bra.s	Dtk3a

* Un operateur
DtkOpe	lea	Dtk_OpFin(pc),a0
	bra.s	Dtk0b
* Instruction normale
Dtk0a	move.l	AdTokens(a5),a0
Dtk0b	lea	4(a0,d0.w),a0
	move.l	a0,a1
Dtk3:	tst.b	(a1)+
	bpl.s	Dtk3
	move.b	(a1),d3
	cmp.b	#"O",d3
	beq.s	Dtk4
	cmp.b	#"V",d3
	beq.s	Dtk4
	cmp.b	#"0",d3		0->8 des fonctions
	bcs.s	Dtk3a
	cmp.b	#"9",d3
	bcs.s	Dtk4
* Instruction : met un espace avant s'il n'y en a pas!
Dtk3a:	cmp.l	a4,a2		* Debut de la ligne?
	beq.s	Dtk4
	cmp.b	#" ",-1(a4)
	beq.s	Dtk4
	move.b	#" ",(a4)+
* Doit prendre le token prececent?
Dtk4:	move.b	(a0),d1
	cmp.b	#$80,d1
	bcs.s	Dtk4x
	cmp.b	#$9f,d1
	bhi.s	Dtk4x
	subq.l	#4,a0
	sub.b	#$80,d1
	beq.s	Dtk4a
	ext.w	d1
	sub.w	d1,a0
	bra.s	Dtk4x
Dtk4a:	move.b	-(a0),d1
	cmp.b	#"!",d1
	beq.s	Dtk4x
	cmp.b	#$80,d1
	bne.s	Dtk4a
	bra.s	Dtk4
* Ecrit le mot
Dtk4x:	cmp.b	#"!",d1
	bne.s	Dtk4y
	addq.l	#1,a0
Dtk4y:	move.b	DtkMaj1(a5),d1
	beq.s	Dtk5
	cmp.b	#1,d1
	beq.s	Dtk6
	bne.s	Dtk8
* 0- Ecrit en MINUSCULES
Dtk5:	move.b	(a0)+,(a4)+
	bpl.s	Dtk5
	and.b	#$7f,-1(a4)
	bra.s	DtkE
* 1- Ecrit en MAJUSCULES
Dtk6:	move.b	(a0)+,d1
	move.b	d1,d2
	and.b	#$7f,d1
	cmp.b	#"a",d1
	bcs.s	Dtk7
	cmp.b	#"z",d1
	bhi.s	Dtk7
	sub.b	#"a"-"A",d1
Dtk7:	move.b	d1,(a4)+
	tst.b	d2
	bpl.s	Dtk6
	bra	DtkE
* 2- Ecrit AVEC UNE MAJUSCULE
Dtk8:	move.b	(a0)+,d1
	move.b	d1,d2
	and.b	#$7f,d1
	cmp.b	#"a",d1
	bcs.s	Dtk9
	cmp.b	#"z",d1
	bhi.s	Dtk9
	sub.b	#"a"-"A",d1
Dtk9:	move.b	d1,(a4)+
	tst.b	d2
	bmi.s	DtkE
Dtk9a:	move.b	(a0)+,d1
	move.b	d1,(a4)+
	bmi.s	Dtk9b
	cmp.b	#" ",d1
	bne.s	Dtk9a
	bra.s	Dtk8
Dtk9b:	and.b	#$7f,-1(a4)
* Met une espace si c'est une INSTRUCTION
DtkE:	cmp.w	#_TkRem1,d0
	beq	DtkRem
	cmp.w	#_TkRem2,d0
	beq	DtkRem
	cmp.b	#"I",d3
	bne.s	DtkE1
	move.b	#" ",(a4)+
* Saute le token...
DtkE1:	move.l	a6,a0
	bsr	TInst
	move.l	a0,a6
	bra	DtkLoop
* Ouverture de parenthese, jamais d'espace!
DtkP:	cmp.l	a4,a2
	beq.s	DtkP1
	cmp.b 	#" ",-1(a4)
	bne.s	DtkP1
	subq.l	#1,a4
DtkP1:	move.b	#"(",(a4)+
	bra.s	DtkE1

******* Detokenisation de VARIABLE
DtkVar:	btst	#0,d5		* Si variable juste avant, met 32
	beq.s	DtkV0
	cmp.b	#" ",-1(a4)
	beq.s	DtkV0
	move.b	#" ",(a4)+
DtkV0:	moveq	#0,d2
	move.b	2(a6),d2	* Longueur
	move.w	d2,d1
	subq.w	#1,d1
	move.b	3(a6),d3	FLAG
	lea	4(a6),a0
	moveq	#0,d4
	cmp.w	#_TkLab,d0
	bne.s	DtkV1
	moveq	#1,d4		D4: 0=> Variable
	cmp.b	#"0",(a0)	    1=> Label
	bcs.s	DtkV1		   -1=> Numero ligne
	cmp.b	#"9",(a0)
	bhi.s	DtkV1
	moveq	#-1,d4
DtkV1:	move.b	DtkMaj2(a5),d0
	beq.s	DtkV2
	cmp.b	#1,d0
	beq.s	DtkV3
	bne.s	DtkV5
* 0- En MINUSCULES
DtkV2:	move.b	(a0)+,d0
	beq	DtkVF
	move.b	d0,(a4)+
	dbra	d1,DtkV2
	bra	DtkVF
* 1- En MAJUSCULES
DtkV3:	move.b	(a0)+,d0
	beq	DtkVF
	cmp.b	#"a",d0
	bcs.s	DtkV4
	cmp.b	#"z",d0
	bhi.s	DtkV4
	sub.b	#"a"-"A",d0
DtkV4:	move.b	d0,(a4)+
	dbra	d1,DtkV3
	bra	DtkVF
* 2- Avec UNE MAJUSCULE
DtkV5:	move.b	(a6)+,d0
	cmp.b	#"a",d0
	bcs.s	DtkV6
	cmp.b	#"z",d0
	bhi.s	DtkV6
	sub.b	#"a"-"A",d0
DtkV6:	move.b	d0,(a4)+
	dbra	d1,DtkV2
* Saute la variable / met le flag de la variable
DtkVF:	bset	#0,d5
	lea	4(a6,d2.w),a6
	moveq	#":",d0
	tst.w	d4
	bmi	DtkLoop
	bne.s	DtkV7
	moveq	#"#",d0
	and.b	#3,d3
	cmp.b	#1,d3
	beq.s	DtkV7
	moveq	#"$",d0
	cmp.b	#2,d3
	bne	DtkLoop
DtkV7:	move.b	d0,(a4)+
	bra	DtkLoop

******* Detokenise des constantes
DtkCst:	bclr	#0,d5		Si variable avant, met un espace!
	beq.s	DtkC0
	cmp.b	#" ",-1(a4)
	beq.s	DtkC0
	move.b	#" ",(a4)+
DtkC0:	cmp.w	#_TkEnt,d0
	beq.s	DtkC3
	cmp.w	#_TkHex,d0
	beq.s	DtkC4
	cmp.w	#_TkBin,d0
	beq.s	DtkC5
	cmp.w	#_TkFl,d0
	beq.s	DtkC6
	cmp.w	#_TkDFl,d0
	beq.s	DtkC7
* Detokenise une chaine alphanumerique
	cmp.w	#_TkCh1,d0
	bne.s	DtkC0a
	moveq	#'"',d0
	bra.s	DtkC0b
DtkC0a:	moveq	#"'",d0
DtkC0b:	move.b	d0,(a4)+
	move.w	(a6)+,d1
	subq.w	#1,d1
	bmi.s	DtkC2
DtkC1:	move.b	(a6)+,(a4)+
	dbra	d1,DtkC1
	move.w	a6,d1
	btst	#0,d1
	beq.s	DtkC2
	addq.l	#1,a6
DtkC2:	move.b	d0,(a4)+
	bra	DtkLoop
* Detokenise un chiffre entier
DtkC3:	move.l	(a6)+,d0
	move.l	a4,a0
	JJsrR	L_LongToDec,a1
	move.l	a0,a4
	bra	DtkLoop
* Detokenise un chiffre HEXA
DtkC4:	move.l	(a6)+,d0
	move.l	a4,a0
	JJsrR	L_LongToHex,a1
	move.l	a0,a4
	bra	DtkLoop
* Detokenise un chiffre BINAIRE
DtkC5:	move.l	(a6)+,d0
	move.l	a4,a0
	JJsrR	L_LongToBin,a1
	move.l	a0,a4
	bra	DtkLoop
* Detokenise un chiffre FLOAT simple precision
DtkC6:	move.l	(a6)+,d0
	move.l	a4,a0
	moveq	#-1,d4
	moveq	#0,d5
 	JJsrR	L_FloatToAsc,a1
	exg	a0,a4
	bra.s	DtkC8
* Detokenise un chiffre FLOAT double precision
DtkC7	move.l	(a6)+,d0
	move.l	(a6)+,d1
	pea	2.w			Automatique
	pea	15.w			15 maxi
	move.l	a4,-(sp)		Buffer
	move.l	d1,-(sp)		Le chiffre
	move.l	d0,-(sp)
	JJsrR	L_DoubleToAsc,a1
	lea	20(sp),sp
	move.l	a4,a0
.Fin	tst.b	(a4)+
	bne.s	.Fin
	subq.l	#1,a4
; Si pas 0.0, le met!
DtkC8	move.b	(a0)+,d0		* Si pas de .0, le met!
	beq.s	DtkC9
	cmp.b	#".",d0
	beq	DtkLoop
	cmp.b	#"E",d0
	beq	DtkLoop
	bra.s	DtkC8
DtkC9	move.b	#".",(a4)+
	move.b	#"0",(a4)+
	bra	DtkLoop

******* Token d'extension
DtkX:	bra	DtkLoop

******* REMarque
DtkRem:	addq.w	#2,a6		Saute la longueur
DtkR:	tst.b	(a6)
	beq	DtkLoop
	move.b	(a6)+,(a4)+
	bra.s	DtkR

******* Fin de la DETOKENISATION
DtkFin:	sub.l	a2,a4		* Ramene PX
	move.w	a4,-2(a2)
	move.l	a4,a0
	move.w	(sp)+,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts

;	RAMENE LA TAILLE DE L'INSTRUCTION D0 en D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TInst:	tst.w	d0
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

;	Passe en minuscules
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Minus:	cmp.b 	#"A",d0
	bcs.s	.Skip
	cmp.b	#"Z",d0
	bhi.s	.Skip
	add.b	#"a"-"A",d0
.Skip	rts


;						Table des operateurs
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Dtk_Operateurs
	dc.w	1,1
	dc.b 	" xor"," "+$80,"O00",-1
	dc.w	1,1
	dc.b 	" or"," "+$80,"O00",-1
	dc.w	1,1
	dc.b 	" and"," "+$80,"O00",-1
	dc.w	1,1
	dc.b 	"<",">"+$80,"O20",-1
	dc.w	1,1
	dc.b 	">","<"+$80,"O20",-1
	dc.w	1,1
	dc.b 	"<","="+$80,"O20",-1
	dc.w	1,1
	dc.b 	"=","<"+$80,"O20",-1
	dc.w	1,1
	dc.b 	">","="+$80,"O20",-1
	dc.w	1,1
	dc.b 	"=",">"+$80,"O20",-1
	dc.w	1,1
	dc.b 	"="+$80,"O20",-1
	dc.w	1,1
	dc.b 	"<"+$80,"O20",-1
	dc.w	1,1
	dc.b 	">"+$80,"O20",-1
	dc.w	1,1
	dc.b 	"+"+$80,"O22",-1
	dc.w	1,1
	dc.b 	"-"+$80,"O22",-1
	dc.w	1,1
	dc.b 	" mod"," "+$80,"O00",-1
	dc.w	1,1
	dc.b 	"*"+$80,"O00",-1
	dc.w	1,1
	dc.b 	"/"+$80,"O00",-1
	dc.w	1,1
	dc.b 	"^"+$80,"O00",-1
	even
Dtk_OpFin
	dc.l 	0
ExtNot	dc.b	"Extension ",$80

	Even


; _____________________________________________________________________________

Ed_Vide		dc.w 0
CurNor		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000
		dc.b	%11111111
		dc.b	%11111111
		dc.b	%00000000
CurBloc		dc.b	%10101010
		dc.b	%01010101
		dc.b	%10101010
		dc.b	%01010101
		dc.b	%10101010
		dc.b	%01010101
		dc.b	%10101010
		dc.b	%01010101

; Controle curseur
; ~~~~~~~~~~~~~~~~
CRet		dc.b	13,10,0,0
ChCuOn		dc.b	27,"C1",0
ChCuOff		dc.b	27,"C0",0

; Marque des menus actives
; ~~~~~~~~~~~~~~~~~~~~~~~~
MenuMark0	dc.b	"   ",0
MenuMark1	dc.b	" ->",0
; Nom des touches de fonction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mt1
Menus_Touches1	dc.b	0,K0-Mt1			0
		dc.b	Shf,K1-Mt1			1
		dc.b	Ctr,K2-Mt1			2
		dc.b	Ami,K3-Mt1			3
		dc.b	Alt,K4-Mt1			4
		dc.b	Ctr+Shf,K5-Mt1
		dc.b	Ctr+Ami,K6-Mt1
		dc.b	Ctr+Alt,K7-Mt1
		dc.b	Ami+Shf,K8-Mt1
		dc.b	Ami+Alt,K9-Mt1
		dc.b	Alt+Shf,K10-Mt1			0
		dc.b	Shf+Alt+Ami,K11-Mt1		11
		dc.b	Ctr+Alt+Ami,K12-Mt1		12
		dc.b	Ctr+Shf+Ami,K13-Mt1		13
		dc.b	Ctr+Shf+Alt,K14-Mt1		14
		dc.b	Ctr+Shf+Alt+Ami,K15-Mt1		5
K0		dc.b	"[   ",0,"   ]",0		0
K1		dc.b	"[Shift+",0,"]",0		1
K2		dc.b	"[Contr+",0,"]",0		2
K3		dc.b	"[Amiga+",0,"]",0		3
K4		dc.b	"[Alter+",0,"]",0		4
K5		dc.b 	"[Ct+Sh+",0,"]",0		5
K6		dc.b	"[Ct+Am+",0,"]",0		6
K7		dc.b	"[Ct+Al+",0,"]",0		7
K8		dc.b	"[Am+Sh+",0,"]",0		8
K9		dc.b	"[Am+Al+",0,"]",0		9
K10		dc.b	"[Al+Sh+",0,"]",0		10
K11		dc.b	"[SAlAm+",0,"]",0		11
K12		dc.b	"[CAlAm+",0,"]",0		12
K13		dc.b 	"[CShAm+",0,"]",0		13
K14		dc.b	"[CShAl+",0,"]",0		14
K15		dc.b	"[CSAAm+",0,"]",0		15
Menus_Touches3	dc.b	"[ SubMenu ]",0
Menus_Touches2	dc.b	$80+$45,"Esc"
		dc.b	$80+$42,"Tab"
		dc.b	$80+$46,"Del"
		dc.b	$80+$41,"Bck"
		dc.b	$80+$5f,"Hlp"
		dc.b	$80+$44,"Ret"
		dc.b	$80+$4c,"Up "
		dc.b	$80+$4f,"Lft"
		dc.b	$80+$4e,"Rgt"
		dc.b	$80+$4d,"Dwn"
		dc.b	$80+$0f,"N0"
		dc.b	$80+$1d,"N1"
		dc.b	$80+$1e,"N2"
		dc.b	$80+$1f,"N3"
		dc.b	$80+$2d,"N4"
		dc.b	$80+$2e,"N5"
		dc.b	$80+$2f,"N6"
		dc.b	$80+$3d,"N7"
		dc.b	$80+$3e,"N8"
		dc.b	$80+$3f,"N9"
		dc.b	$80+$3c,"N."
		dc.b	$80+$43,"Ent"
		dc.b	$80+$50,"F1 "
		dc.b	$80+$51,"F2 "
		dc.b	$80+$52,"F3 "
		dc.b	$80+$53,"F4 "
		dc.b	$80+$54,"F5 "
		dc.b	$80+$55,"F6 "
		dc.b	$80+$56,"F7 "
		dc.b	$80+$57,"F8 "
		dc.b	$80+$58,"F9 "
		dc.b	$80+$59,"F10"
		dc.b	$80,$00
		Even

; Numero des messages dialogue
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EdD_Title	equ	0
EdD_Quit	equ	2
EdD_NAll	equ	3
EdD_Search	equ	4
EdD_Replace	equ	6
EdD_WBlock	equ	8
EdD_WText	equ	9
EdD_Changes	equ	10
EdD_Saved	equ	11
EdD_Macro1	equ	13
EdD_Macro2	equ	14
EdD_Macro3	equ	15
EdD_MacroD	equ	18
EdD_MacroNA	equ	19
EdD_MacroAll	equ	20
EdD_MacroEra	equ	21
EdD_MacroNo	equ	22
EdD_MacroPas	equ	23
EdD_KyMn1       equ     24
EdD_KyMn2       equ     27
EdD_KyMn3       equ     28
EdD_KyMnE       equ     26
EdD_PrgMn1	equ	30
EdD_PrgMn2	equ	31
EdD_PrgMn3	equ	32
EdD_PrgMnE	equ	33
EdD_GotoL	equ	35
EdD_SetBuf	equ	36
EdD_TooSmall	equ	37
EdD_SetTab	equ	38
EdD_MnUsA	equ	40
EdD_MnUsD	equ	41
EdD_MnUs2	equ	42
EdD_MnUsE	equ	43
EdD_MnUs	equ	44
EdD_SvConf	equ	45
EdD_CSaved	equ	46
EdD_AExist	equ	47
EdD_ASave	equ	48
EdD_OQuit	equ	49
EdD_Avert	equ	50
EdD_NoWarm	equ	51
EdD_WarmErr	equ	52
EdD_WarmDel	equ	53
EdD_Infos	equ	54
EdD_AboutE	equ	55
EdD_DiskErr	equ	58
EdD_Ligne	equ	59
EdD_PBloc	equ	60
EdD_PProg	equ	61
EdD_WQuit	equ	62
;	ENDC
