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
; .200000............2002........................| AMOSPro Version 2
; .200002........................................| Loader general
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
;
		Include "+AMOS_Includes.s"
		Include "+Version.s"
; ______________________________________________________________________________


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ROUTINES DE FIN / ROUTINES INTERNES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	SECTION	"E",CODE
; - - - - - - - - - - - - -

Hunk_1	jmp	Cold_Start


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FIN DE L'INITIALISATION : ENLEVE LE HUNK INIT!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Init_Fin
; - - - - - - - - - - - - -

; Enleve le hunk init
; ~~~~~~~~~~~~~~~~~~~
	lea	Hunk_1-8(pc),a0
	lea	Hunk_2-8,a1
	move.l	4(a1),4(a0)		Deconnecte le hunk 2
	move.l	(a1),d0			Libere la memoire
	move.l	$4.w,a6
	jsr	_LVOFreeMem(a6)

; Ouvre une structure programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	PI_DefSize(a5),d0	Structure programme
	JJsr	L_Prg_NewStructure
	move.l	d0,a6
	beq	TheEnd_OOMem

; Charge AUTOEXEC.AMOS ou le programme voulu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#-2,d0			Pas d'ecran de fond
	JJsr	L_Prg_New
	moveq	#-1,d0			Toujours adapter
	JJsr	L_Prg_Load
	bne	.NoProg
	moveq	#-1,d0			Semi Init Graphique
	lea	RunErr_RunOnly,a1	En cas d'erreur
	sub.l	a2,a2
	JJsr	L_Prg_RunIt		Revient si out of memory!

; Pas de programme: on se branche � l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.NoProg	jsr	Sys_VerInstall		Verification de l'installation
	beq	TheEnd_Install
	jsr	Edit_Load		Charge l'editeur
	bne.s	TheEnd_Editor
	moveq	#-1,d0			DefRun normal
	JJsr	L_Prg_New
	moveq	#-1,d0			Titre
	JJsr	L_Ed_Cold
	bne.s	TheEnd_Editor
	jsr	WOption			Affiche ou non!
	JJsr	L_Ed_Title		Le titre
	JJmp	L_Ed_Loop		Branche � la boucle

; 	Message d'erreur panique residents
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TheEnd_Editor
	lea	Panic_Editor(pc),a0	Cannot load editor
	bra	TheEndMm
TheEnd_OOMem
	lea	Panic_OOMem(pc),a0	Out of memory
	bra	TheEndMm
TheEnd_Install
	lea	Panic_Install(pc),a0
	bra	TheEndMm

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	SORTIE GENERALE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TheEndMm
	move.l	a0,Panic
TheEnd

	tst.b	Sys_LibStarted(a5)
	beq	.Nolib

; Les librairies sont demarrees
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	Sys_EndRoutines(a5),a1	Les routines ajoutees
	SyCall	CallRoutines

	JJsr	L_CloAll		Fichiers, imprimante
	JJsr	L_PRT_Close
	JJsr	L_Equ_Free

	JJsr	L_Includes_Clear	Les includes du dernier programme

	tst.l	Edit_Segment(a5)	Arrete l'editeur
	beq.s	.NEd
	JJsr	L_Ed_End
.NEd

	move.l	Edt_List(a5),d1		Les structures EDT restantes
	beq.s	.EdtX			en cas de KILL editor
.ExtL	move.l	d1,a1
	move.l	Edt_Next(a1),d1
	move.l	#Edt_Long,d0
	SyCall	MemFree
	tst.l	d1
	bne.s	.ExtL

.EdtX	move.l	Prg_List(a5),d0		Les structure PRG restantes
	beq.s	.PrgX
.PrgL	move.l	d0,a6
	JJsr	L_Prg_DelStructure
	move.l	Prg_List(a5),d0
	bne.s	.PrgL
.PrgX
	bsr	Edit_Free		Enleve l'editeur
	bsr	Mon_Free		Enleve le moniteur + banque
	bsr	EffFSel			Enleve la resource file selector
	bsr	EffMouse		Enleve la souris
	JJsr	L_WB_Open		Ouvre le WB en fond
	bsr	Libraries_Stop		STOP les librairies
.Nolib

; Partie non dependantes des librairies
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	D_Close			Ferme le dernier fichier...

	tst.b	Sys_WStarted(a5)	Arrete W.Lib
	beq.s	.Skip0
	move.l	Sys_WAd(a5),a0
	jsr	4(a0)
.Skip0
	lea	Sys_Messages(a5),a0	Enleve config interpreteur
	jsr	A5_Free
	lea	PathAct(a5),a0		Enleve pathact
	jsr	A5_Free
	move.l	AdrIcon(a5),d0		Enleve l'icone
	beq.s	.SkipI
	move.l	d0,a0
	move.l	IconBase(a5),a6
	jsr	-90(a6)
.SkipI
	move.l	$4.w,a6			Ferme icon.library
	move.l	IconBase(a5),d0
	beq.s	.Skip1
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
.Skip1
	move.l	FloatBase(a5),d0	Ferme les librairies mathematiques
	beq.s	.SkipM1
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
.SkipM1	bsr	Math_Close

	bsr	Libraries_Free		Libere les librairies

	move.l	Sys_WAd(a5),a0		Enleve AMOS.Library
	jsr	16(a0)
	move.l	DosBase(a5),a6
	move.l	Sys_WSegment(a5),d1
	jsr	_LVOUnLoadSeg(a6)

	move.l	DosBase(a5),a3		Affiche le message d'erreur
	move.l	T_IntBase(a5),a4
	move.l	Sys_Message(a5),d7
	bsr	Panic_Message

	move.l	$4.w,a6			Ferme graphics.library
	move.l	T_GfxBase(a5),d0
	beq.s	.SkipG
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
.SkipG
	move.l	DosBase(a5),a1		dos
	jsr	_LVOCloseLibrary(a6)
	move.l	T_IntBase(a5),a1	Intuition
	jsr	_LVOCloseLibrary(a6)

	move.l	Sys_Message(a5),d7	Plus de datazone
	move.l	Sys_AData(a5),a1
	move.l	Sys_LData(a5),d0
	move.l	$4.w,a6			Liberation directe!
	jsr	_LVOFreeMem(a6)

; Sortie d'AMOSPro!
; ~~~~~~~~~~~~~~~~~
Get_Out	move.l	SaveSp(pc),a7
	tst.l	d7
	beq.s	.PaMe
	move.l	$4.w,a6
	jsr	_LVOForbid(a6)
	move.l 	d7,a1
	jsr	-378(a6)
.PaMe	moveq	#0,d0
	rts


; Fermeture des librairies mathematiques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Math_Close
	move.l	a6,-(sp)
	move.l	$4.w,a6
	move.l	MathBase(a5),d0
	beq.s	.SkipM2
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
	clr.l	MathBase(a5)
.SkipM2	move.l	DFloatBase(a5),d0
	beq.s	.SkipM3
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
	clr.l	DFloatBase(a5)
.SkipM3	move.l	DMathBase(a5),d0
	beq.s	.SkipM4
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
	clr.l	DMathBase(a5)
.SkipM4	move.l	(sp)+,a6
	rts

; Imprime le message d'erreur dans l'entree courante
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A3=	DosBase
;	A4=	IntBase
;	D7=	Message
Panic_Message
	move.l	Panic(pc),d6		Un message?
	beq.s	.Exit
	tst.l	d7			Sous WB?
	bne.s	.Wb
; Sous DOS-> Message dans la fenetre courante
	move.l	a3,a6			Handle courant
	jsr	-60(a6)
	move.l	d0,d1
	beq.s	.Exit
	lea	-128(sp),sp		Buffer de travail
	move.l	sp,d2
	move.l	d6,a0
	move.l	d2,a1
.Copy	move.b	(a0)+,(a1)+
	bne.s	.Copy
	move.b	#10,-1(a1)
	clr.b	(a1)
	move.l	a1,d3
	sub.l	d2,d3
	jsr	_LVOWrite(a6)
	lea	128(sp),sp
.Exit	rts
; Sous WB-> ouvre une tchote fenetre
.Wb	move.l	a4,a6			IntBase
	lea	H_Click(pc),a0
	lea	H_AutoBody(pc),a1
	move.l	d6,12(a1)
	lea	H_AutoClick(pc),a3
	move.l	a0,12(a3)
	sub.l	a2,a2
	sub.l	a0,a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	#560,d2
	moveq	#50,d3
	jsr	-348(a6)
	bra.s	.Exit

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


; Ne pas changer la position du nom, apres dos.library!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		even
		dc.l	UserSecu-DosName
DosName		dc.b 	"dos.library",0
UserReg		dc.w	14
		dc.b	"R"^$73		0
		dc.b	"E"^$73		1
		dc.b	"G"^$73		2
		dc.b	"I"^$73		3
		dc.b	"S"^$73		4
		dc.b	"T"^$73		5
		dc.b	"R"^$73		6
		dc.b	"A"^$73		7
		dc.b	"T"^$73		8
		dc.b	"I"^$73		9
		dc.b	"O"^$73		10
		dc.b	"N"^$73		11
		dc.b	" "^$73		12
		dc.b	"#"^$73		13
UserName	dc.w	14
		dc.b	"N"^$A5		0
		dc.b	"o"^$A5		1
		dc.b	"t"^$A5		2
		dc.b	" "^$A5		3
		dc.b	"I"^$A5		4
		dc.b	"n"^$A5		5
		dc.b	"s"^$A5		6
		dc.b	"t"^$A5		7
		dc.b	"a"^$A5		8
		dc.b	"l"^$A5		9
		dc.b	"l"^$A5		10
		dc.b	"e"^$A5		11
		dc.b	"d"^$A5		12
		dc.b	"!"^$A5		13
		ds.b	32-14+4
		even

;		Noms des Librairies
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SaveSp		dc.l 	0
Panic		dc.l	0

;		Marqueur de version
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VersionN:	dc.b	" Version "
		Version
		dc.b	0,"$VER: "
		Version

; 		Messages d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Panic_OOMem	dc.b	"Not enough free memory",0
Panic_Editor	dc.b	"Cannot load editor",0
Panic_Install	dc.b	'Program not installed, start "Install.AMOS" first',0

; Charge l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edit_Load
	lea	Edit_Segment(a5),a0
	lea	Edit_Debug(pc),a1
	moveq	#6,d0
	moveq	#L_Ed_Start,d1
	bsr	Program_Load
.Err	rts

; Efface l'editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Edit_Free
	lea	Edit_Segment(a5),a0
	bra	Program_Free

; Charge le moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mon_Load
	move.l	Cur_Banks(a5),-(sp)
; Le moniteur lui-meme
; ~~~~~~~~~~~~~~~~~~~~
	lea	Mon_Segment(a5),a0
	lea	Mon_Debug(pc),a1
	moveq	#10,d0
	moveq	#L_Mon_Start,d1
	bsr	Program_Load
; Charge la banque de resource, si necessaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Skip1	tst.l	Mon_Banks(a5)
	bne.s	.Skip2
	lea	Mon_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	moveq	#11,d0			Nom de la banque
	bsr	Sys_GetMessage
	bsr	Sys_AddPath		+ path systeme
	move.l	#1005,d2
	bsr	D_Open
	beq.s	.DErr
	moveq	#-1,d0
	JJsr	L_Bnk.Load
	bne	.Err
	bsr	D_Close
.Skip2
; Ok, pas d'erreur
; ~~~~~~~~~~~~~~~~
	move.l	(sp)+,Cur_Banks(a5)
	moveq	#0,d0
	rts
; Erreur: efface tout!
; ~~~~~~~~~~~~~~~~~~~~
.DErr	moveq	#-2,d0			File not found
.Err	move.l	(sp)+,Cur_Banks(a5)
	move.w	d0,-(sp)
	bsr	Mon_Free
	move.w	(sp)+,d0
	rts

; Efface le moniteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mon_Free
	move.l	Cur_Banks(a5),-(sp)
; Enleve le moniteur
; ~~~~~~~~~~~~~~~~~~
	lea	Mon_Segment(a5),a0
	bsr	Program_Free
; Enleve les banques
; ~~~~~~~~~~~~~~~~~~
.Skip1	tst.l	Mon_Banks(a5)
	beq.s	.Skip2
	lea	Mon_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	JJsr	L_Bnk.EffAll
.Skip2	move.l	(sp)+,Cur_Banks(a5)
	rts

; Charge le programme (a0) / Nom #D0 / Branchements D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Program_Load
	move.l	a0,a2			Adresse du segment
	move.l	d1,d2			Numero de la premiere fonction
	IFNE	Debug=2
	move.l	a1,(a2)
	ENDC
	IFEQ	Debug=2
	tst.l	(a2)
	bne.s	.Skip
	bsr	Sys_GetMessage		Nom du programme
	bsr	Sys_AddPath		+ path systeme
	move.l	Name1(a5),d1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOLoadSeg(a6)
	move.l	(sp)+,a6
	move.l	d0,(a2)
	beq.s	.Err
	ENDC
; Loke les adresses des routines dans les branchements
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Skip	move.l	(a2),d0
	IFEQ	Debug=2
	lsl.l	#2,d0
	addq.l	#4,d0
	ENDC
	move.l	d0,a0
	move.l	AdTokens(a5),a1
	lsl.w	#2,d2
	add.w	#LB_Size+4,d2
	sub.w	d2,a1
	bra.s	.In
.Loop	add.l	d0,d1
	move.l	d1,-(a1)
.In	move.l	(a0)+,d1
	bne.s	.Loop
; OK, pas d'erreur
; ~~~~~~~~~~~~~~~~
	moveq	#0,d0
	rts
.Err	moveq	#1,d0
	rts
; Efface le programme A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Program_Free
	IFEQ	Debug=2
	move.l	(a0),d1
	beq.s	.Skip
	clr.l	(a0)
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOUnLoadSeg(a6)
	move.l	(sp)+,a6
	ENDC
.Skip	rts

; Effacement du buffer mouse
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
EffMouse
	lea	PI_AdMouse(a5),a0
	jmp	A5_Free

; Efface la banque de resource file-selector
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EffFSel	lea	Sys_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	moveq	#16,d0
	JJsr	L_Bnk.Eff
	rts

; AddPath sur un nom+command line, retourne la command line en A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_AddPathCom
	movem.l	a1/d1,-(sp)
	move.l	a0,a1
.Lim1	move.b	(a1)+,d1
	beq.s	.Lim2
	cmp.b	#" ",d1
	bne.	.Lim1
.Lim2	move.b	-1(a1),d1
	clr.b	-1(a1)
	bsr	Sys_AddPath
	move.b	d1,-1(a1)
	bne.s	.Lim3
	subq.l	#1,a1
.Lim3	move.l	a1,a0
	movem.l	(sp)+,a1/d1
	rts

; Additionne le pathname du dossier AMOS_System, si pas de path defini!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_AddPath
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

; Retourne le message default_resource D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Def_GetMessage
	move.l	Sys_Resource(a5),a0
	add.l	6(a0),a0
	bra.s	GetMessage
; Routine, retourne le message systeme D0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_GetMessage
	move.l	Sys_Messages(a5),a0
GetMessage
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


; Verification de l'installation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_VerInstall
	move.w	d0,-(sp)
	move.w	UserName(pc),d0
	beq.s	.Skip
	move.w	UserReg(pc),d0
.Skip	movem.w	(sp)+,d0
	rts

; Enleve le codage: D0=XOR
; ~~~~~~~~~~~~~~~~~~~~~~~~
Sys_UnCode
	movem.l	a0/a1/d1/d2/d3,-(sp)
	moveq	#0,d2
	move.w	(a0)+,d1
	move.w	d1,(a1)+
	subq.w	#1,d1
	bmi.s	.Skip
.Loop	move.b	(a0)+,d3
	eor.b	d0,d3
	add.b	d3,d2
	move.b	d3,(a1)+
	dbra	d1,.Loop
.Skip	move.w	d2,d0
	movem.l	(sp)+,a0/a1/d1/d2/d3
	rts

******************************************************************
		dc.b	$17,$09,$19,$92
UserSecu	ds.b	34
******************************************************************

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Clear CPU Caches, quel que soit le systeme
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Sys_ClearCache
; - - - - - - - - - - - - -
	movem.l	a0-a1/a6/d0-d1,-(sp)
	move.l	$4.w,a6
	cmp.w	#37,WB2.0(a5)			A partir de V37
	bcc.s	.Skip
	jsr	FindTask(a6)
	bra.s	.Exit
.Skip	jsr	_LVOCacheClearU(a6)		CacheClearU
.Exit	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Wait vbl multi tache
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Sys_WaitMul
; - - - - - - - - - - - - -
	movem.l	a0-a1/a6/d0-d1,-(sp)
; Inhibition
	SyCall	Test_Cyclique
; Attente multitache
	move.l	T_GfxBase(a5),a6
	jsr	-270(a6)
	movem.l	(sp)+,a0-a1/a6/d0-d1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Force le recalcul des listes copper
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ReCop:	SyCall	WaitVbl
	EcCall	CopForce
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				ARRET DES LIBRAIRIES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Stop
; - - - - - - - - - - - - - - - -
	movem.l	a2-a6/d2-d7,-(sp)
	moveq	#26-1,d2
	lea	ExtAdr+26*16-16(a5),a2
.Loop	move.l	8(a2),d0
	beq.s	.Next
	move.l	d0,a0
	movem.l	a2/d2,-(sp)
	jsr	(a0)
	movem.l	(sp)+,a2/d2
.Next	lea	-16(a2),a2
	dbra	d2,.Loop
	moveq	#0,d0
	bra	Ll_Out2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				EFFACEMENT DES LIBRARIES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Free
; - - - - - - - - - - - - - - - -
	bsr	Libraries_FreeSizes
	movem.l	a2-a6/d2-d7,-(sp)
	moveq	#27-1,d2
	lea	AdTokens(a5),a2
.Loop	move.l	(a2),d0
	beq.s	.Next
	move.l	d0,a0			La library elle meme...
	clr.l	(a2)
	move.l	LB_MemAd(a0),a1
	move.l	LB_MemSize(a0),d0
	SyCall	MemFree
.Next	addq.l	#4,a2			Library suivante...
	dbra	d2,.Loop
	moveq	#0,d0
	bra	Ll_Out2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				LIBERATION DE LA TABLE DES TAILLES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_FreeSizes
; - - - - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	lea	AdTokens(a5),a2
	moveq	#27-1,d2
.Loop	move.l	(a2)+,d0
	beq.s	.Skip
	move.l	d0,a0
	move.l	LB_LibSizes(a0),d0
	beq.s	.Skip
	clr.l	LB_LibSizes(a0)
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	jsr	RamFree
.Skip	dbra	d2,.Loop
	moveq	#0,d0
Ll_Out2	movem.l	(sp)+,d2-d7/a2-a6
	rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RESERVATION / LIBERATION MEMOIRE (ancienne!)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Mise a zero!
; ~~~~~~~~~~~~~~~~~~
RamFast	move.l	a0,-(sp)
	SyCall	MemFastClear
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
RamChip	move.l	a0,-(sp)
	SyCall	MemChipClear
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
; 	NON mise a zero!
; ~~~~~~~~~~~~~~~~~~~~~~
RamFast2
	move.l	a0,-(sp)
	SyCall	MemFast
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
RamChip2
	move.l	a0,-(sp)
	SyCall	MemChip
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
; 	Liberation
; ~~~~~~~~~~~~~~~~
RamFree	move.l	a0,-(sp)
	SyCall	MemFree
	move.l	(sp)+,a0
	rts

; 	Reserve / Libere le buffer temporaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ResTempBuffer
	movem.l	d1/a1,-(sp)
	move.l	d0,d1
; Libere l'ancien buffer
	move.l	TempBuffer(a5),d0
	beq.s	.NoLib
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	bsr.s	RamFree
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
; Branche les routines de liberation automatique
	movem.l	a0-a2/d0-d1,-(sp)
	lea	.LibClr(pc),a1
	lea	Sys_ClearRoutines(a5),a2
	SyCall	AddRoutine
	lea	.LibErr(pc),a1
	lea	Sys_ErrorRoutines(a5),a2
	SyCall	AddRoutine
	movem.l	(sp)+,a0-a2/d0-d1
.Exit	movem.l	(sp)+,d1/a1
	rts
; Structures liberation
; ~~~~~~~~~~~~~~~~~~~~~
.LibClr	dc.l	0
	moveq	#0,d0
	bra.s	ResTempBuffer
.LibErr	dc.l	0
	moveq	#0,d0
	bra.s	ResTempBuffer

; 	Reserve un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
;	D0=	Longueur
;	D1=	Flags
A5_Reserve
	move.l	a1,-(sp)
	move.l	a0,a1
	addq.l	#4,d0
	SyCall	MemReserve
	beq.s	.Out
	subq.l	#4,d0
	move.l	d0,(a0)+
	move.l	a0,(a1)
.Out	move.l	(sp)+,a1
	rts
; 	Efface un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
A5_Free
	movem.l	a0/a1/d0,-(sp)
	move.l	(a0),d0
	beq.s	.Skip
	clr.l	(a0)
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	SyCall	MemFree
.Skip	movem.l	(sp)+,a0/a1/d0
	rts

;
; NOUVELLE ROUTINES DISQUE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; OPEN: ouvre le fichier systeme (diskname1) access mode D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D_Open	move.l 	Name1(a5),d1
D_OpenD1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	move.l	d0,Handle(a5)
	rts

; READ fichier systeme D3 octets dans D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D_Read	movem.l	d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVORead(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts

; WRITE fichier systeme D3 octets de D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D_Write
	movem.l	d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts

; SEEK fichier system D3 mode D2 deplacement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
D_Seek	move.l	Handle(a5),d1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
	rts

; CLOSE fichier systeme
; ~~~~~~~~~~~~~~~~~~~~~
D_Close
	movem.l	d0/d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	beq.s	.Skip
	clr.l	Handle(a5)
	move.l	DosBase(a5),a6
	jsr	_LVOClose(a6)
.Skip	movem.l	(sp)+,d0/d1/a0/a1/a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MONITOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InMonitor
; - - - - - - - - - - - - -
	bsr	Prg_FirstRun		Autorise?
	tst.l	Edit_Segment(a5)
	beq.s	.ErrE
	Ijsr	L_Ed_CloseEditor
	Ijsr	L_Prg_ReSetBanks	Remet les banques
	bsr	Mon_Load		Charge le moniteur
	bne.s	.Err
	Ijsr	L_Mon_In_Program
	bne.s	.Mem
	Ret_Inst
.ErrE	moveq	#13,d0
	Ijmp	L_Error
.Err	cmp.w	#-1,d0
	beq.s	.Mem
	Ijmp	L_DiskError
.Mem	Ijmp	L_OOfMem

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					KILL EDITOR
; KILL EDITOR: ne fonctionne que le pour le premier programme!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InKillEditor
; - - - - - - - - - - - - -
	bsr	Prg_FirstRun		Autorise?
	tst.l	Edit_Segment(a5)	Deja ferme?
	beq.s	KEExit
; Fait un close editor d'abord
	tst.b	PI_CloseEd(a5)		Autorise?
	beq.s	CloCloX
	Ijsr	L_Ed_CloseEditor
; Peut-on faire le KILL editor?
	tst.b	PI_KillEd(a5)		Autorise?
	beq.s	CloCloX
	tst.l	Mon_Base(a5)		Pas si moniteur en route!
	bne.s	CloCloX
	Ijsr	L_Ed_KillEditor
	bsr	Edit_Free		Enleve de la memoire
	bsr	Mon_Free		Tant qu'� faire...
	lea	RunErr_NoEditor(pc),a0
	move.l	a0,Prg_JError(a5)	Branchement en fin de programme
 	clr.w	T_AMOState(a5)		Mode RUN-ONLY
; Sortie commune
CloCloX	lea	Equ_Base(a5),a0		Libere les equates
	bsr	A5_Free
	Ijsr	L_Prg_ReSetBanks	Remet les banques
	move.w	ScOn(a5),d1
	beq.s	KEExit
	subq.w	#1,d1
	EcCall	Active
KEExit	Ret_Inst

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 			CLOSE EDITOR
;			ne fonctionne que pour le premier programme!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
InCloseEditor
; - - - - - - - - - - - - -
	bsr	Prg_FirstRun
	tst.b	PI_CloseEd(a5)		Autorise?
	beq.s	KEExit
	tst.l	Edit_Segment(a5)	Deja ferme?
	beq.s	KEExit
	Ijsr	L_Ed_CloseEditor
	bra.s	CloCloX

; Peut-on fermer l'editeur ?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_FirstRun
	tst.w	Direct(a5)
	bne.s	.Err
	tst.b	Prg_Accessory(a5)
	bne.s	.Non
	move.l	Prg_Runned(a5),a0	Un programme en dessous?
	tst.l	Prg_Previous(a0)
	bne.s	.Non
	rts
.Non	addq.l	#4,sp
	Ret_Inst
.Err	moveq	#17,d0			Illegal direct mode
	Ijmp	L_Error

; __________________________________________________________________________
;
;	Erreurs RUN-ONLY
; __________________________________________________________________________
;
RunErr_RunOnly
	move.w	#-1,-(sp)
	bra.s	RunErr_Reload
; __________________________________________________________________________
;
;	Erreurs editeur ferme...
; __________________________________________________________________________
;
RunErr_NoEditor
	clr.w	-(sp)
RunErr_Reload
	movem.l	a0-a1/d0-d1,-(sp)
	move.l	Cur_Banks(a5),-(sp)	Donnees courantes...
	move.l	Cur_Dialogs(a5),-(sp)
	cmp.w	#1002,d0		System?
	beq	TheEnd
	bsr	Sys_VerInstall		Si pas installe!
	beq	TheEnd
	bsr	Reset_Request		Requester back to AMOS
	bsr	Edit_Load		Charge l'editeur
	bne	.Again
	JJsr	L_Ed_Cold
	beq.s	.Ok
	cmp.b	#1,d0			Out of memory?
	bne	TheEnd_Editor		Fichiers introuvables : tant pis!
; Efface au maximum la memoire
.Again	move.l	(sp),Cur_Dialogs(a5)	Banques du programme
	move.l	4(sp),Cur_Banks(a5)
	bsr	MemMaximum		Grab as much memory as possible
	bsr	Edit_Load		Charge eventuellement
	bne.s	.AAgain
	JJsr	L_Ed_Cold
	beq.s	.Ok
; Efface les banques du programme!
.AAgain	tst.w	6*4(sp)			Un run-only?
	bne 	TheEnd			Oui: on stoppe tout...
	move.l	(sp),Cur_Dialogs(a5)	Banques du programme
	move.l	4(sp),Cur_Banks(a5)
	bsr	MemDelBanks		Peut-on effacer les banques?
	beq	TheEnd_OOMem
	JJsr	L_Bnk.EffAll		Efface les banques!
	JJsr	L_Bnk.Change
	bsr	Edit_Load		Essaye encore!
	bne	TheEnd_Editor
	JJsr	L_Ed_Cold
	bne	TheEnd_Editor			Tant pis!
; Branche � l'editeur
.Ok	tst.l	Edt_Runned(a5)			Pas de programme >>> coldcold
	bne.s	.Go
	move.l	Edt_List(a5),Edt_Runned(a5)	Donc, un seul prg!
.Go	bsr	WOption				AMOS en 1er!
	move.l	(sp)+,Cur_Dialogs(a5)		Remet les banques
	move.l	(sp)+,Cur_Banks(a5)
	movem.l	(sp)+,a0-a1/d0-d1
	tst.w	(sp)+
	JJmpR	L_Ed_ErrRun,a2			Erreurs normales
	bra	TheEnd

;	 Requester back to AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Reset_Request
	move.l	ExtAdr+2*16+4(a5),d0		Request= ext #2
	beq.s	.Skip
	move.l	d0,a0
	jsr	(a0)
.Skip	rts

;	Recupere autant de memoire que possible
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MemMaximum
	JJsr	L_ClearVar			Plus de variable
	move.w	#-2,DefFlag(a5)			Plus d'ecran
	JJsr	L_DefRun1
	move.l	PI_ParaTrap+16(a5),-(sp)	Lignes sprites, MINI!
	move.l	#20,PI_ParaTrap+16(a5)
	JJsr	L_DefRun2
	move.l	(sp)+,PI_ParaTrap+16(a5)
	move.l	#10000*1024,d0			Demande 10 megas de CHIP!
	SyCall	MemChip
	tst.l	Mon_Base(a5)			Libere le moniteur
	bne.s	.Skip
	bsr	Mon_Free
.Skip	rts

; 	Ligne de confirmation de l'effacement du programme courant...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MemDelBanks
	movem.l	a2-a6/d2-d7,-(sp)
	JJsr	L_Bnk.GetLength		Longueur des banques
	add.l	d2,d0
	add.l	d1,d0
	beq	.Tanpi			Si zero: on ne fait rien!

	bsr	.Puzzle			Ouvre l'ecran
	move.l	a1,a0
	moveq	#EcFsel,d0
	move.l	#640,d1
	moveq	#48,d2
	moveq	#0,d3
	moveq	#-1,d4
	JJsrR	L_Dia_RScOpen,a3
	bne.s	.Tanpi
	bsr	ReCop

	bsr	.Puzzle			Demarre le DBL
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.l	#512,d6			Taille du buffer
	lea	.DBL(pc),a0
	JJsrR	L_Dia_RunQuick,a3

	movem.l	d0/d1,-(sp)
	EcCalD	Del,EcFsel		Efface l'ecran
	movem.l	(sp)+,d0/d1

	tst.l	d0
	bne.s	.Tanpi
	cmp.w	#2,d1
	beq.s	.Out
	moveq	#1,d0
	bra.s	.Out
.Tanpi	moveq	#0,d0
.Out	movem.l	(sp)+,d2-d7/a2-a6
	rts
; Retourne les adresses dans la banque par defaut
.Puzzle	move.l	Sys_Resource(a5),a0
	move.l	a0,a1
	add.l	2+0(a0),a1		Base des graphiques
	move.l	a0,a2
	add.l	2+4(a0),a2		Base des messages
	add.l	2+8(a0),a0		Base des programmes
	rts
; Petit DBL de gestion de la ligne
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.DBL	dc.w	.Fin-.Debut
.Debut	dc.b	"SI	SW,SH;"
	dc.b	"BA	0,0;"
	dc.b 	"BO	0,0,1,SX,SY;"
	dc.b	"PO	21MECX,4,21ME,0,7;"
	dc.b	"PO	22MECX,14,22ME,2,3;"
	dc.b	"BU	1,16,SY22-,64,16,0,0,1;[UN 0,0,13BP+; PR 3MECXBP+,4,3ME,7;][BQ;]"
	dc.b	"KY	13,0;"
	dc.b	"BU	2,SX72-,YA,XBXA-,YBYA-,0,0,1;[UN 0,0,13BP+; PR 4MECXBP+,4,4ME,7;][BQ;]"
	dc.b	"KY	27,0;"
	dc.b	"BU	3,0,0,SX,SY,0,0,0;[][SM;]"
	dc.b	"RU	0,3;"
	dc.b	"EX;",0
.Fin	even

; Fait passer l'AMOS en 1er juste avant le lancement du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WOption	tst.b	WBench(a5)
	beq.s	.Skip
	EcCalD	AMOS_WB,1
	clr.b	WBench(a5)
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Trouve le directory courant >
;					>>> Buffer + 384
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AskDir
; - - - - - - - - - - - - -
	move.l	Buffer(a5),a0
	clr.w	(a0)
	clr.w	384(a0)
	move.l	a0,d1
	moveq	#-2,d2
	DosCall	_LVOLock
	tst.l	d0
	bne.s	AskDir2
	rts
; - - - - - - - - - - - - -
AskDir2
; - - - - - - - - - - - - -
	clr.l	-(sp)
ADir0:	move.l	d0,-(sp)
	move.l	d0,d1
	DosCall	_LVOParentDir
	tst.l	d0
	bne.s	ADir0
* Redescend les LOCKS en demandant le NOM!
	move.l	Buffer(a5),a2
	lea	384(a2),a2
	clr.b	(a2)
	moveq	#":",d2
ADir1:	move.l	(sp)+,d1
	beq.s	ADir4
	move.l	Buffer(a5),a1
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
ADir4	moveq	#0,d0
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: Memory.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;	Gestion de liste simple NEXT.l LONG.l

; Cree un element de liste en CHIP MEM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lst.ChipNew
	move.l	#Chip|Clear|Public,d1
	bra.s	Lst.Cree
; Cree une element de liste en FAST MEM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lst.New
	move.l	#Clear|Public,d1
; Cree un �l�ment en tete de liste A0 / longueur D0 / Memoire D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lst.Cree
	movem.l	a0/d0,-(sp)
	addq.l	#8,d0
	SyCall	MemReserve
	move.l	a0,a1
	movem.l	(sp)+,a0/d1
	beq.s	.Out
	move.l	(a0),(a1)
	move.l	a1,(a0)
	move.l	d1,4(a1)
	move.l	a1,d0
.Out	rts

; Efface une liste entiere A0
; ~~~~~~~~~~~~~~~~~~~~~~~~
Lst.DelAll
	bra.s	.In
.Loop	move.l	d0,a1
	bsr	Lst.Del
.In	move.l	(a0),d0
	bne.s	.Loop
	rts
; Efface un �l�ment de liste A1 / Debut liste A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lst.Del
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

; INSERE un �l�ment A1 en tete de liste A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lst.Insert
	move.l	(a0),(a1)
	move.l	a1,(a0)
	rts

; Enleve un �l�ment de liste A1 / Debut liste A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lst.Remove
	movem.l	a0/a1/d0-d2,-(sp)
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
.NFound	movem.l	(sp)+,a0/a1/d0-d2
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					BANQUES PROGRAMME PRECEDENT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Bnk.PrevProgram
; - - - - - - - - - - - - -
	movem.l	a0/a1/d0,-(sp)
	tst.l	Mon_Base(a5)			Pas si moniteur!
	bne.s	.Non
	tst.w	Direct(a5)			Pas en mode direct!
	bne.s	.Non
	move.l	Prg_Runned(a5),a0		Un programme en dessous
	move.l	Prg_Previous(a0),d0
	bne.s	.Ok
	move.l	Edt_Current(a5),d0		NON! Un programme edite?
	beq.s	.Non
	move.l	d0,a1
	move.l	Edt_Prg(a1),d0			Le meme???
	cmp.l	d0,a0
	beq.s	.Non
.Ok	move.l	d0,a0				On grabbe
	lea	Prg_Banks(a0),a0
	move.l	a0,Cur_Banks(a5)
	bra.s	.Exit
.Non	moveq	#0,d0
.Exit	movem.l	(sp)+,a0/a1/d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					BANQUE DU PROGRAMME COURANT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Bnk.CurProgram
; - - - - - - - - - - - - -
	movem.l	a0/d0,-(sp)
	move.l	Prg_Runned(a5),a0
	lea	Prg_Banks(a0),a0
	move.l	a0,Cur_Banks(a5)
	movem.l	(sp)+,a0/d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					CHANGEMENT DANS LES BANQUES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Bnk.Change
; - - - - - - - - - - - - -
	movem.l	a0-a3/d0-d7,-(sp)
; Appelle les extensions
; ~~~~~~~~~~~~~~~~~~~~~~
	lea	ExtAdr(a5),a0
	moveq	#26-1,d0
.ELoop	move.l	12(a0),d1
	beq.s	.ESkip
	move.l	d1,a1
	movem.l	a0/d0,-(sp)
	move.l	d1,a1
	move.l	Cur_Banks(a5),a0
	move.l	(a0),a0
	jsr	(a1)
	movem.l	(sp)+,a0/d0
.ESkip	lea	16(a0),a0
	dbra	d0,.ELoop
; Recherche la banque de sprites
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_Bnk.GetBobs
	SyCall	SetSpBank
; Ok!
; ~~~
	movem.l	(sp)+,a0-a3/d0-d7
	tst.w	d0
	rts

;	IFNE	Debug
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
.Ill	EcCalD	AMOS_WB,0
	movem.l	(sp)+,d0-d2/a0-a2
	illegal
	rts
;	ENDC


; Inclusion de la verification
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Include	"+Verif.s"

; Charge le moniteur et l'editeur en mode debug
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	IFNE	Debug=2
Mon_Debug	Include	"+Monitor.s"
Edit_Debug	Include "+Edit.s"
	ENDC
	IFEQ	Debug=2
Mon_Debug
Edit_Debug
	ENDC


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	CHARGEMENT / INITIALISATION - Partie amovible!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	SECTION	"I",CODE
; - - - - - - - - - - - - -

Ext_Nb		equ	5
Ext_TkCmp       equ     6
Ext_TkCOp       equ     $14
Ext_TkTston     equ     $28
Ext_TkTstof     equ     $3a
Ext_TkTst       equ     $4e

; Calcul de la taille des buffers de travail
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
LDataWork	equ	32+BbLong+12*2+(AAreaSize*5+6)+24+16+12+70*3+4+20+108+108+256+TBuffer

; Buffer dans la pile pour debuter
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
SP_Message	rs.l	1
SP_AutoLock	rs.l	1
SP_AutoName	rs.b	128
SP_Config	rs.b	128
SP_DefSize	rs.l	1
SP_DosBase	rs.l	1
SP_IntBase	rs.l	1
SP_Command	rs.l	2
SP_WSegment	rs.l	1
SP_WBench	rs.w	1
SP_CommandLine	rs.l	1
SP_Buffer	equ	__RS


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEMARRAGE A FROID
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Hunk_2
Cold_Start
; - - - - - - - - - - - - -
	move.l	sp,SaveSp

; Reserve un buffer dans la pile, pour travailler
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	-SP_Buffer(sp),sp
	movem.l	a0/d0,SP_Command(sp)

; Init dos.library
; ~~~~~~~~~~~~~~~~
	moveq	#0,d0
	lea	DosName,a1
	move.l	$4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,SP_DosBase(sp)

; Init INTUITION library / Find version!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a6
	moveq	#0,d0
	move.l	d0,d3
	lea	IntName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,SP_IntBase(sp)

; CLI ou WORKBENCH?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	clr.l	SP_WSegment(sp)
	clr.l	SP_Message(sp)
	clr.l	SP_AutoLock(sp)
	clr.l	SP_DefSize(sp)
	clr.w	SP_AutoName(sp)
	clr.w	SP_Config(sp)
	clr.l	SP_CommandLine(sp)
	move.b	#1,SP_WBench(sp)

; Workbench?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	sub.l	a1,a1
	move.l	$4.w,a6
	jsr	_LVOFindTask(a6)
	move.l	d0,a0
	tst.l	$ac(a0)
	bne.s	FromCLI
; Recupere le message
; ~~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a6
	lea	$5c(a0),a0
	move.l	a0,-(sp)
	jsr	-384(a6)		WaitPort
	move.l	(sp)+,a0
	jsr	-372(a6)		GetMsg
	move.l 	d0,SP_Message(sp)
	move.l 	d0,a2
	moveq	#-1,d2
; Change le directory >>> directory AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	$24(a2),d0
	beq.s	.PaLock
	move.l	d0,a0
	move.l	(a0),d2
	beq.s	.PaLock
	move.l	d2,d1
	move.l	SP_DosBase(sp),a6
	jsr	_LVOCurrentDir(a6)
.PaLock
; Un programme � charger?
; ~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	#2,$1c(a2)
	bne.s	.PaAuto
	move.l	$24(a2),d0
	beq.s	.PaAuto
	move.l	d0,a2
	move.l	8(a2),SP_AutoLock(sp)
	move.l	12(a2),d0
	beq.s	.PaAuto
	move.l	d0,a0
	lea	SP_AutoName(sp),a1
.Cop	move.b	(a0)+,(a1)+
	bne.s	.Cop
	tst.l	d2
	bne.s	.PaAuto
	move.l	SP_AutoLock(sp),d1
	beq.s	.PaAuto
	move.l	SP_DosBase(sp),a6
	jsr	_LVOCurrentDir(a6)
.PaAuto	bra	CommandX

; CLI!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FromCLI	movem.l	SP_Command(sp),a0/d0
	cmp.w	#1,d0
	bls	CommandX
	clr.b	-1(a0,d0.w)
; Explore la ligne de commande
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Saute le d�but
.Cli0	move.b	(a0)+,d0
	beq	CommandX
	cmp.b	#" ",d0
	beq.s	.Cli0
	cmp.b	#"-",d0
	beq.s	.CliO
; Nom du programme � charger?
	subq.l	#1,a0
	lea	SP_AutoName(sp),a1
	bsr	.CliNom
.Spc	cmp.b	#" ",(a0)+		Stocke le debut command line
	beq.s	.Spc
	subq.l	#1,a0
	move.l	a0,SP_CommandLine(sp)
	bra	CommandX
; Options
.CliO	move.b	(a0)+,d0
	beq	.CliE
	cmp.b	#"a",d0
	bcs.s	.PAm
	cmp.b	#"z",d0
	bhi.s	.PAm
	sub.b	#$20,d0
.PAm	cmp.b	#"C",d0
	beq	.ClioC
	cmp.b	#"W",d0
	beq	.ClioW
; Erreur dans la command line
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
.CliE	move.l	#Panic_Command,Panic
	bra	Boot_Fatal
; Option -C "fichier config"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
.ClioC	lea	SP_Config(sp),a1
	bsr	.CliNom
	bra.s	.Cli0
; Option -W "workbench"
; ~~~~~~~~~~~~~~~~~~~~~
.ClioW	clr.b	SP_WBench(sp)
	bra.s	.Cli0
; Prend un nom dans la command line
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
; Fin de l'exploration des commandes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CommandX
; Charge amos.library: differents essais si pas installe!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	SP_DosBase(sp),a6
	lea	LibName2(pc),a0		APSystem/amos.library
	move.l	a0,d1
	jsr	_LVOLoadSeg(a6)
	tst.l	d0
	bne.s	.Ok
	lea	LibName3(pc),a0		libs/amos.library
	move.l	a0,d1
	jsr	_LVOLoadSeg(a6)
	tst.l	d0
	bne.s	.Ok
	lea	LibName1(pc),a0		libs:amos.library
	move.l	a0,d1
	jsr	_LVOLoadSeg(a6)
	tst.l	d0
	bne.s	.Ok
	move.l	#Panic_Lib,Panic	Message d'erreur
	bra	Boot_Fatal
.Ok	move.l	d0,SP_WSegment(sp)	Segment library pour fatal!
	lsl.l	#2,d0
	addq.l	#4,d0
	move.l	d0,a4

; Reserve la zone de datas...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#LDataWork,d0		;   Longueur buffers travail
	add.l	8(a4),d0		; + Longueur datas W
	add.l	#DataLong,d0		; + Longueur datas BASIC
	move.l	d0,d2
	move.l	#Public|Clear,d1	Flags
	move.l	$4.w,a6			Using default system function!
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.Mem
	move.l	d0,a5
	lea	LDataWork(a5),a5
	move.l	a5,a0
	add.l	8(a4),a5
	move.l	d0,Sys_AData(a5)
	move.l	d2,Sys_LData(a5)
; Trouve toutes les adresses de buffers de travail
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
	move.w	a0,d0
	and.w	#$0003,d0
	beq.s	.Skipu
	illegal
.Mem	move.l	#Panic_OOMem,Panic	Message d'erreur panique
	bra	Boot_Fatal
.Skipu

; Poke les donn�es contenues dans SP
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	SP_WSegment(sp),Sys_WSegment(a5)
	move.l	SP_Message(sp),Sys_Message(a5)
	move.l	SP_DosBase(sp),DosBase(a5)
	move.l	SP_IntBase(sp),T_IntBase(a5)

; Start system function of the amos.library
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,Sys_WAd(a5)
	move.l	#"V2.0",d0		Magic!
	move.w	#$0200,d1		Version d'AMOSPro
	jsr	12(a4)
	cmp.l	#"W2.0",d0		Verifie la version de la librairie
	beq.s	.Libok
	move.l	#Panic_Version,Panic
	jmp	TheEnd
.Libok

; Stocke la version du systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a0
	cmp.w	#36,$14(a0)
	bcs.s	.Pa20
	move.w	$14(a0),WB2.0(a5)
.Pa20

; Charge la configuration de l'interpreteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1005,d2
	lea	SP_Config(sp),a0		Option -C" "
	tst.b	(a0)
	bne.s	.Conf
	lea	NDatas1(pc),a0			AMOSPro_Interpretor_Config
	move.l	a0,d1
	jsr	D_OpenD1
	bne.s	.Open
	lea	NDatas3(pc),a0			s/AMOSPro_Interpretor_Config
	move.l	a0,d1
	jsr	D_OpenD1
	bne.s	.Open
	lea	NDatas2(pc),a0			s:AMOSPro_Interpretor_Config
.Conf	move.l	a0,d1
	jsr	D_OpenD1
	bne.s	.Open
	move.l	#Panic_Config,Panic		Message d'erreur
	jmp	TheEnd
.Open	move.l	Buffer(a5),d2
	move.l	d2,a2

; Charge les donn�es dc.w
; ~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#8,d3
	jsr	D_Read
	bne	TheEnd_Cantread
	cmp.l	#"PId1",(a2)
	bne	TheEnd_Cantread
	move.l	4(a2),d3
	lea	PI_Start(a5),a0
	move.l	a0,d2
	jsr	D_Read
	bne	TheEnd_Cantread
; Charge les donn�es texte
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a2,d2
	moveq	#8,d3
	jsr	D_Read
	cmp.l	#"PIt1",(a2)
	bne	TheEnd_Cantread
	lea	Sys_Messages(a5),a0
	move.l	4(a2),d0
	move.l	d0,d3
	move.l	#Clear|Public,d1
	jsr	A5_Reserve
	beq	JTheEnd_OOMem
	move.l	a0,d2
	jsr	D_Read
	jsr	D_Close
; La taille du buffer specifiee efface la precedente
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	SP_DefSize(sp),d0
	beq.s	.Skop
	move.l	d0,PI_DefSize(a5)
.Skop
; Buffer de pathact
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#256,d0
	move.l	#Public|Clear,d1
	lea	PathAct(a5),a0
	jsr	A5_Reserve
	beq	JTheEnd_OOMem
; Trouve le path complet du systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#1,d0				Acces au path
	jsr	Sys_GetMessage
	move.l	a0,d1				Demande le lock
	moveq	#-2,d2
	DosCall	_LVOLock
	tst.l	d0
	beq	TheEnd_APSystem
	jsr	AskDir2				Demande le directory
	move.l	Buffer(a5),a0			Copie le directory
	lea	384(a0),a0
	lea	Sys_Pathname(a5),a1
.CC	move.b	(a0)+,(a1)+
	bne.s	.CC
; Init FLOAT library
; ~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a6
	moveq	#0,d0
	lea	FloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,FloatBase(a5)
; Init GRAPHICS Library
; ~~~~~~~~~~~~~~~~~~~~~
	moveq	#0,d0
	lea	GfxName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,T_GfxBase(a5)
	beq	TheEnd_Cantread
; Init ICON Library
; ~~~~~~~~~~~~~~~~~
	tst.b	PI_Icons(a5)
	beq.s	.PaIco
	moveq	#0,d0
	lea	IconName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,IconBase(a5)
	beq.s	.PaIco
	move.l	d0,a6
	moveq	#4,d0			Nom de Def_Icon
	jsr	Sys_GetMessage
	jsr	Sys_AddPath
	move.l	Name1(a5),a0
	jsr	-78(a6)			Charge!
	move.l	d0,AdrIcon(a5)
	beq.s	.PaIco
	move.l	d0,a0
	move.l	#$80000000,d0		RAZ position ecran
	move.l	d0,$3a(a0)
	move.l	d0,$3e(a0)
.PaIco

; Charge les librairies
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Libraries_Load
	bne	TheEnd_Badext
	bsr	Library_Patch		Insere les routines internes
	bsr	Libraries_Reloc
	bne	TheEnd_Badext
	move.b	#1,Sys_LibStarted(a5)	Flag: les librairies sont demarrees!

; Charge le fichier MOUSE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	LdMouse
; Charge la banque FSel_Resource
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	LdFSel
; Fait les ASSIGNS automatiques
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	AutoAssigns

; Demarrage des interruptions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#3,d0			A3= fonte / 0
	jsr	Sys_GetMessage
	move.l	a0,a3
	lea	PI_ParaTrap(a5),a0	A0= parametre demarrage
	move.l	PI_AdMouse(a5),a1	A1= mouse.bak / 0
	lea	PI_DefEPa(a5),a2	A2= Palette par defaut
	moveq	#0,d0			D0= pas afficher les ecrans
	move.l	PI_DefAmigA(a5),d1	D1= default amiga-a
	move.l	Sys_WAd(a5),a6
	jsr	(a6)
	tst.l	d0
	bne	JTheEnd
	move.b	#-1,Sys_WStarted(a5)

; Demarre les librairies
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Libraries_Init
	bne	TheEnd_Badext

; Raz du pathact!
; ~~~~~~~~~~~~~~~
	move.l	PathAct(a5),a0
	clr.b	(a0)

; Charger un programme?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Name1(a5),a0
	clr.w	(a0)
	move.l	SP_AutoLock(sp),d1
	beq.s	.PaDir
	move.l	DosBase(a5),a6
	jsr	_LVOCurrentDir(a6)
.PaDir	lea	SP_AutoName(sp),a0		Un programme en commande?
	tst.b	(a0)
	bne.s	.CoLo
	moveq	#5,d0				Non, essaie AUTOEXEC.AMOS
	jsr	Sys_GetMessage
.CoLo	move.l	Name1(a5),a1
.CoCop	move.b	(a0)+,(a1)+
	bne.s	.CoCop
	move.b	SP_WBench(sp),WBench(a5)	Flag pour test

; Poke la ligne de commande dans le buffer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	SP_CommandLine(sp),d0
	beq.s	.Paco
	move.l	d0,a0
	move.l	Buffer(a5),a1
	lea	TBuffer-256-6(a1),a1
	move.l	#"CmdL",(a1)+
	move.l	a1,a2
	clr.w	(a1)+
.Cop	move.b	(a0)+,(a1)+
	bne.s	.Cop
	subq.l	#1,a0
	sub.l	d0,a0
	move.w	a0,(a2)
.Paco

; Depile
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	SP_Buffer(sp),sp
	move.l	sp,BasSp(a5)

; Recupere la taille memoire totale au depart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	$4.w,a6
	tst.w	WB2.0(a5)
	bne.s	.M20
; En 1.3, demande simplement AVAILMEM>>> valeurs approximatives!
	move.l	#Public|Chip,d1
	jsr	_LVOAvailMem(a6)
	add.l	#38*1024,d0
	move.l	d0,d2
	move.l	#Public|Fast,d1
	jsr	_LVOAvailMem(a6)
	tst.l	d0
	beq.s	.QChp
	add.l	#256*1024,d0
	bra.s	.Mm
.QChp	add.l	#256*1024,d2
	bra.s	.Mm
; En 2.0, demande la taille totale
.M20	move.l	#Public|Chip|Total,d1
	jsr	_LVOAvailMem(a6)
	move.l	d0,d2
	move.l	#Public|Fast|Total,d1
	jsr	_LVOAvailMem(a6)
.Mm	move.l	d0,MemFastTotal(a5)
	move.l	d2,MemChipTotal(a5)

; Prend le path de depart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	JJsr	L_AskDir
	JJsr	L_CopyPath
; Fermeture automatique du WB
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	PI_AutoWB(a5)
	beq.s	.NoWB
	jsr	WOption
	JJsr	L_WB_Close
.NoWB

; Branchement � la fin de l'initialisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	jmp	Init_Fin

; Relai de saut dans l'autre Hunk
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
JTheEnd_OOMem
	jmp	TheEnd_OOMem
JTheEnd	jmp	TheEnd
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Fait les assigns automatiquement!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AutoAssigns
; - - - - - - - - - - - - -
	lea	AssInst(pc),a0		ASSIGN present?
	move.l	Name1(a5),a1
.CoCop	move.b	(a0)+,(a1)+
	bne.s	.CoCop
	JJsr	L_RExist
	beq.s	.NoAss
; Fait les assigns...
	JJsr	L_AskDir
	lea	AssCon(pc),a0		Ouvre un NIL:
	move.l	a0,d1
	move.l	#1004,d2
	DosCall	_LVOOpen
	tst.l	d0
	beq.s	.NoAss
	move.l	d0,ParamE(a5)
	moveq	#0,d2
	lea	Ass1(pc),a0		Productivity1
	bsr.s	DoAssign
	add.w	d0,d2
	lea	Ass2(pc),a0		Productivity1
	bsr.s	DoAssign
	add.w	d0,d2
	lea	Ass3(pc),a0		Tutorial
	bsr.s	DoAssign
	add.w	d0,d2
	lea	Ass4(pc),a0		Examples
	bsr.s	DoAssign
	add.w	d0,d2
	lea	Ass5(pc),a0		Accessories
	bsr.s	DoAssign
	add.w	d0,d2
	lea	Ass6(pc),a0		Compiler
	bsr.s	DoAssign
	add.w	d0,d2
	lea	Ass7(pc),a0		Extras
	bsr.s	DoAssign
	add.w	d0,d2
	beq.s	.Skip			sur les accessoires,
	lea	Ass0(pc),a0		On assigne AMOSPro_System:
	bsr.s	DoAssign
.Skip	move.l	ParamE(a5),d1
	DosCall	_LVOClose
.NoAss	rts
* Routine, fait les assigns, si possible!
DoAssign
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	a0,-(sp)
	move.l	Name1(a5),a1		* Regarde si existe deja!
.CoCop1	move.b	(a0)+,(a1)+
	bne.s	.CoCop1
	move.l	a0,-(sp)
	JJsr	L_RExist
	bne	.NoAss

;	move.l	Buffer(a5),a0		* Fabrique le path normal
;	lea	384(a0),a0
;	move.l	Name1(a5),a1
;.CoCop2	move.b	(a0)+,(a1)+
;	bne.s	.CoCop2
;	subq.l	#1,a1
;	move.l	(sp),a0
;.CoCop3	move.b	(a0)+,(a1)+
;	bne.s	.CoCop3
;	JJsr	L_RExist
;	bne.s	.DoAss

	lea	Sys_Pathname(a5),a0	* Essaie avec le directory APSystem!
	move.l	Name1(a5),a1
.CoCup2	move.b	(a0)+,(a1)+
	bne.s	.CoCup2
	move.b	#"/",-1(a1)		En arriere un directory!
	move.l	(sp),a0
.CoCup3	move.b	(a0)+,(a1)+
	bne.s	.CoCup3
	JJsr	L_RExist
	beq.s	.NoAss

.DoAss	lea	AssCall(pc),a0		* Appelle la commande
	move.l	Buffer(a5),a1
.CoCop4	move.b	(a0)+,(a1)+
	bne.s	.CoCop4
	move.l	4(sp),a0
	subq.l	#1,a1
.CoCop5	move.b	(a0)+,(a1)+
	bne.s	.CoCop5
	move.b	#32,-1(a1)
	move.b	#'"',(a1)+
	move.l	Name1(a5),a0
.CoCop6	move.b	(a0)+,(a1)+
	bne.s	.CoCop6
	move.b	#'"',-1(a1)
	clr.b	(a1)
	move.l	Buffer(a5),d1
	move.l	ParamE(a5),d2
	move.l	ParamE(a5),d3
	move.l	DosBase(a5),a6
	jsr	-222(a6)
	moveq	#1,d0
	bra.s	.Quit
.NoAss	moveq	#0,d0
.Quit	addq.l	#8,sp
	movem.l	(sp)+,d1-d7/a0-a6
	rts

; Charge / Efface la souris , fill patterns
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
LdMouse
	moveq	#2,d0			Mouse.Abk
	jsr	Sys_GetMessage
	tst.b	(a0)			Utiliser le defaut
	beq.s	.Skip
; Charge la banque
	jsr	Sys_AddPath
	move.l	#1005,d2
	jsr	D_Open
	beq	TheEnd_Cantread
	moveq	#0,d2			Demande la taille du fichier
	moveq	#1,d3
	jsr	D_Seek
	moveq	#0,d3
	jsr	D_Seek
	move.l	d0,d3
; Reserve un buffer de la taille des sprites
	move.l	#Chip|Public|Clear,d1
	lea	PI_AdMouse(a5),a0
	jsr	A5_Reserve
	beq	JTheEnd_OOMem
	move.l	a0,T_MouBank(a5)
; Lis le fichier dans le buffer
	move.l	a0,d2
	move.l	a0,a2
	jsr	D_Read
	bne	TheEnd_Cantread
	cmp.l	#"AmSp",(a2)
	bne	TheEnd_Cantread
	cmp.w	#4,(a2)+
	bcs	TheEnd_Cantread
; Ferme le fichier!
	jsr	D_Close
.Skip	rts

; Charge/Efface la banque de resource file-selector
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
LdFSel	moveq	#8,d0
	jsr	Sys_GetMessage
	jsr	Sys_AddPath
	lea	Sys_Banks(a5),a0
	move.l	a0,Cur_Banks(a5)
	move.l	#1005,d2
	jsr	D_Open
	beq	TheEnd_Cantread
	moveq	#16,d0
	JJsr	L_Bnk.Load
	bne	JTheEnd_OOMem
	jsr	D_Close
; Met l'adresse de la banque de resource
	moveq	#16,d0
	JJsr	L_Bnk.GetAdr
	cmp.l	#"Reso",-8(a0)
	bne	TheEnd_Cantread
	move.l	a0,Sys_Resource(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				CHARGEMENT DES LIBRARIES + EXTENSIONS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Load
; - - - - - - - - - - - - - - - -

; Librairie principale AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#14,d0
	jsr	Sys_GetMessage
	jsr	Sys_AddPathCom
	moveq	#0,d0
	bsr	Library_Load
	bne.s	.Err
; Extensions
; ~~~~~~~~~~
	moveq	#1,d2
.Loop	move.l	d2,d0
	add.w	#16-1,d0
	jsr	Sys_GetMessage
	tst.b	(a0)
	beq.s	.Next
	jsr	Sys_AddPathCom
	move.w	d2,d0
	bsr	Library_Load
	bne.s	.Err
.Next	addq.w	#1,d2
	cmp.w	#27,d2
	bne.s	.Loop
	moveq	#0,d0
.Err	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				RELOCATION DES LIBRAIRIES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Reloc
; - - - - - - - - - - - - - - - -
	moveq	#0,d2
.Loop1	move.l	d2,d0
	bsr	Library_Reloc
	bne.s	.Err
	addq.w	#1,d2
	cmp.w	#27,d2
	bne.s	.Loop1
	jsr	Libraries_FreeSizes
	moveq	#0,d2
.Loop2	move.l	d2,d0
	bsr	Library_GetParams
	bne.s	.Err
	addq.w	#1,d2
	cmp.w	#27,d2
	bne.s	.Loop2
	moveq	#0,d0
.Err	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				INITIALISATION DES LIBRAIRIES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Init
; - - - - - - - - - - - - - - - -
	moveq	#0,d2
.Loop	move.l	d2,d0
	bsr	Library_Init
	bne.s	.Err
	addq.w	#1,d2
	cmp.w	#27,d2
	bne.s	.Loop
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
	move.l	a0,a4
	lea	AdTokens(a5),a6
	lsl.w	#2,d0
	add.w	d0,a6
; Ouvre le fichier
; ~~~~~~~~~~~~~~~~
	move.l	#1005,d2
	jsr	D_Open
	beq	Ll_Disc
; Lis l'entete dans le buffer
	move.l	Buffer(a5),d2
	move.l	#$20+18,d3
	jsr	D_Read
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
	add.l	8(a3),d3		+ Librairie
	add.l	12(a3),d3		+ Titre
	move.l	d3,d0
	add.l	d4,d0
	move.l	d0,d1
	SyCall	MemFastClear
	beq	Ll_OMem
	lea	LB_Size(a0,d4.l),a2	Saute les jumps et la datazone
	move.l	a2,(a6)			Extension chargee!!!
	move.l	d1,LB_MemSize(a2)	Taille de la zone memoire
	move.l	a0,LB_MemAd(a2)		Adresse de base
	move.l	(a3),d3			Buffer temporaire pour les tailles
	move.l	d3,d0
	addq.l	#4,d0
	SyCall	MemFastClear
	beq	Ll_OMem
	move.l	d3,(a0)+
	move.l	a0,LB_LibSizes(a2)
; Une nouvelle / ancienne librarie?
	clr.w	LB_Flags(a2)		Flags
	bset	#LBF_20,LB_Flags(a2)
	moveq	#4,d3
	move.l	Buffer(a5),d2
	jsr	D_Read
	bne	Ll_Disc
	move.l	d2,a0
	cmp.l	#"AP20",(a0)
	beq.s	.Suit
	bclr	#LBF_20,LB_Flags(a2)
	moveq	#-4,d2
	moveq	#0,d3
	jsr	D_Seek
; Charge les tailles des routines
.Suit	move.l	LB_LibSizes(a2),a0
	move.l	-4(a0),d3
	move.l	a0,d2
	jsr	D_Read			des routines
	bne	Ll_Disc
; Fabrique la table d'adresse des routines internes
	move.w	d5,d0
	subq.w	#1,d0
	move.l	a2,d1			Base des tokens
	add.l	4(a3),d1		+ Taille des tokens = Librairie
	lea	Ll_Rts(pc),a0		RTS pour les fonctions vides
	move.l	a0,d3
	move.l	LB_LibSizes(a2),a0	Liste des fonctions
	lea	-LB_Size(a2),a1		Debut des adresses
	moveq	#0,d2
.Loop1	move.l	d1,-(a1)
	move.w	(a0)+,d2
	bne.s	.Skip1
	move.l	d3,(a1)			Si routine vide>>> RTS
.Skip1	add.l	d2,d1
	add.l	d2,d1
	dbra	d0,.Loop1
; Charge tout le reste
	move.l	4(a3),d3		Tokens
	add.l	8(a3),d3		+ Librairie
	add.l	12(a3),d3		+ Titre
	move.l	a2,d2
	jsr	D_Read
	bne	Ll_Disc
; Ferme le fichier!
	jsr	D_Close
; Rempli la datazone
	move.w	d5,LB_NRout(a2)		Nombre de routines
	move.l	4(a3),d0
	add.l	8(a3),d0
	add.l	a2,d0
	move.l	d0,LB_Title(a2)		Adresse du titre
	move.l	a4,LB_Command(a2)	Command line
; Pas d'erreur
	moveq	#0,d0
	bra	Ll_Out

Ll_Rts	illegal				RTS pour les fonctions vides...

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				INTEGRATION DES LIBRAIRIES INTERNES AMOS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
; - - - - - - - - - - - - - - - -
Library_Patch
; - - - - - - - - - - - - - - - -
	movem.l	a2-a6/d2-d7,-(sp)
	move.l	AdTokens(a5),a2
	move.l	LB_LibSizes(a2),a3
	lea	AMOSJmps,a1
	move.w	(a1)+,d0
.Loop	lsl.w	#1,d0				Plus de taille => plus de relocation
	clr.w	0(a3,d0.w)
	lsl.w	#1,d0				Pointe dans la librarie
	neg.w	d0
	lea	-LB_Size-4(a2,d0.w),a0
	move.l	(a1)+,(a0)
	move.w	(a1)+,d0
	bne.s	.Loop
	moveq	#0,d0
	bra	Ll_Out

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				RELOCATION D'UNE LIBRAIRIE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	D0=	Numero
; - - - - - - - - - - - - - - - -
Library_Reloc
; - - - - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	d0,d6
	lea	AdTokens(a5),a3
	lsl.w	#2,d0
	move.l	0(a3,d0.w),d0
	beq	Ll_Out
	move.l	d0,a3

;	Une librarie 2.0?
; ~~~~~~~~~~~~~~~~~~~~~~~
	btst	#LBF_20,LB_Flags(a3)
	bne.s	.20

; 	Ancienne extension: reloge la table de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a3,a0
	move.l	a0,d1
	lea	6(a0),a0
.Loop2	move.w	(a0),d0
	beq.s	.Loop4
	bmi.s	.Loop3
	lsl.w	#2,d0
	neg.w	d0
	move.l	-LB_Size-4(a3,d0.w),d2
	sub.l	d1,d2
	move.w	d2,(a0)
.Loop3	move.w	2(a0),d0
	beq.s	.Loop4
	bmi.s	.Loop4
	lsl.w	#2,d0
	neg.w	d0
	move.l	-LB_Size-4(a3,d0.w),d2
	sub.l	d1,d2
	move.w	d2,2(a0)
.Loop4	addq.l	#4,a0
.Loop5	tst.b	(a0)+
	bpl.s	.Loop5
.Loop6	tst.b	(a0)+
	bpl.s	.Loop6
	move.w	a0,d0
	and.w	#$0001,d0
	add.w	d0,a0
	tst.w	(a0)
	bne.s	.Loop2
	bra	.Fin20

; 	Nouvelle librarie: exploration de la table de tokens
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.20	move.l	a3,a0
.RLoop	move.w	2(a0),d1
	move.w	(a0),d0
	beq	.RExit
	bmi.s	.RFonc
	cmp.w	#1,d0
	beq.s	.RFonc
; Une Instruction / Instruction ET fonction
.RInst	addq.w	#1,d0			Instruction pointe direct
;	bmi.s	.INop			Instruction NOP
	lsl.w	#2,d0
	neg.w	d0
	move.w	d0,(a0)
	tst.w	d1			Faire un flag?
	bmi	.RNext
	moveq	#0,d0
	bset	#6,d0			Une instruction
	cmp.w	#1,d1
	ble.s	.RSuit
	bset	#7,d0			Une instruction + fonction
	bra.s	.RSuit
;.INop	move.w	#1,(a0)			Positif>>> Instruction NOP
;	moveq	#0,d0
;	bra.s	.RNext
; Une fonction / Fonction mathematique
.RFonc	cmp.w	#1,d1			1, ou 0>>> VIDE!!!
	ble.s	.RSuit
	lsl.w	#2,d1			Fonction, pointe AVANT
	neg.w	d1
	move.w	d1,(a0)
	and.w	#$FF00,d0		Fonction normale?
	beq	.RFn
	and.w	#%0111111100000000,d0	Faire un flag?
	beq	.RNext
.RFn	bset	#7,d0			Une fonction!
; Fabrication du flag parametres...
.RSuit	lea	4(a0),a1
	moveq	#0,d1
.RNom	tst.b	(a1)+			Saute le nom
	bpl.s	.RNom
	moveq	#0,d2			Type de fonction
	move.b	(a1)+,d1		Definition fonction / instruciton
	bmi.s	.RDoke
	cmp.b	#"C",d1			Une constante
	beq.s	.RCst
	cmp.b	#"V",d1			Une variable reservee?
	bne.s	.RSkip1
	move.b	(a1)+,d1
	bmi.s	.RDoke
	or.w	#L_VRes,d0		Flag variable reservee
.RSkip1	move.b	(a1)+,d1		Prend le parametre
	bmi.s	.RDoke			Fini?
	addq.w	#1,d0			Un parametre de plus
	sub.w	#"0",d1			Pointeur
	lsl.w	#1,d1
	jmp	.Jmp(pc,d1.w)
.Jmp	bra.s	.RSkip2			0 Entier,
	bra.s	.Float			1 Float: veut un parametre float
	bra.s	.RSkip2			2 String,
	bra.s	.RSkip2			3 Indifferent, accepte par le test
	bra.s	.Math			4 Math, appelle la fonction parametre
.Angle	or.w	#L_FAngle,d0		5 Angle, veut un float en radian
	bra.s	.RSkip2
.Math	or.w	#L_FMath,d0
	bra.s	.RSkip2
.Float	or.w	#L_FFloat,d0
.RSkip2	move.b	(a1)+,d1
	bpl.s	.RSkip1
.RDoke	move.w	d0,2(a0)		Doke le flag parametres
	move.l	a1,d0			On est deja a la fin
	addq.l	#1,d0
	and.w	#$FFFE,d0
	move.l	d0,a0
	bra	.RLoop			On peut donc reboucler
.RCst	tst.b	(a1)+			Une constante
	bpl.s	.RCst
	bra.s	.RDoke
.RNext	clr.w	2(a0)			Pas de flag
	bsr	Ll_TkNext		Saute le token
	bra	.RLoop
.RExit
	addq.l	#2,a0
; 	Swapper les routines floats?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	#"FSwp",(a0)
	bne.s	.NoFSwp
	move.w	4(a0),LB_DFloatSwap(a3)
	move.w	6(a0),LB_FFloatSwap(a3)
	addq.l	#8,a0
.NoFSwp
;	Des donnees pour le compilateur?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	#"ComP",(a0)		Le code?
	bne.s	.NoComp
	move.w	4(a0),d0
	lea	4+2(a0,d0.w),a0		On les saute
.NoComp
; 	Une table de verification rapide?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	#"KwiK",(a0)		Le code?
	bne.s	.NoKwik
	lea	4(a0),a0
	move.l	a0,LB_Verif(a3)		Poke l'adresse...
.NoKwik

.Fin20

; 	Relocation des routines...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	LB_NRout(a3),d3		Nombre de routines
	move.w	d3,d5			Pour comparer...
	subq.w	#1,d3
	lea	-LB_Size(a3),a2
	move.l	LB_LibSizes(a3),a4	Tailles des routines

GRou0	move.l	-(a2),a0		Debut routine
	moveq	#0,d4
	move.w	(a4)+,d4
	beq.s	GRouN
	lsl.l	#1,d4
	add.l	a0,d4			Fin routine
GRou1	move.b	(a0),d0
	cmp.b	#C_Code1,d0
	beq	GRou10
GRou2	addq.l	#2,a0
	cmp.l	d4,a0
	bcs.s	GRou1
GRouN	dbra	d3,GRou0
	bra	GRouX
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
CRts	rts
CNop	nop
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
.Rlea	subq.b	#8,d0
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
	btst	#LBF_20,LB_Flags(a3)
	bne.s	.New
	bsr	Ext_OldLabel		Converti en ancien label
	bne.s	.AA
	bra	Ll_BadExt
.New	cmp.w	LB_NRout(a1),d0		Superieur au maximum?
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
	bne	GRou2
	move.w	CNop(pc),d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	bra	GRouN
; Fini, pas d'erreur
GRouX	jsr	Sys_ClearCache		Nettoie les caches
	moveq	#0,d0
	bra	Ll_Out
Gfaux	illegal

; Sortie des chargements/relocation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ll_BadExt
	moveq	#2,d0
	bra.s	Ll_Err
Ll_Disc	moveq	#1,d0
	bra.s	Ll_Err
Ll_OMem	moveq	#2,d0
Ll_Err
Ll_Out	movem.l	(sp)+,d2-d7/a2-a6
	rts

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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Relocation des recoltes de parametres
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Library_GetParams
; - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	moveq	#0,d5
	lsl.w	#2,d0
	beq.s	.Skip
	moveq	#20,d5			Offset aux routines si ext
.Skip	move.l	AdTokens(a5,d0.w),d0
	beq	Ll_Out
	move.l	d0,a6			Base des tokens explores
	btst	#LBF_20,LB_Flags(a6)	Une librarie 2.0???
	beq	.No20			NON!

	move.l	AdTokens(a5),a4		Base des routines principales
	JLea	L_Parameters,a3		Routines de recolte
	move.l	a6,a2

; 	Exploration de la table de tokens
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	(a2),d3
.Loop
;	move.l	4(a2),d0
;	cmp.l	#"x mo",d0
;	bne.s	.Skkk
;	jsr	BugBug
.Skkk
	move.w	2(a2),d4
	beq.s	.Next
; Une instruction?
; ~~~~~~~~~~~~~~~~
	move.w	d4,d1
	and.w	#%0000000000111111,d1		Nombre de parametres
	move.w	d1,2(a2)
	btst	#6,d4
	beq.s	.NoIns
	move.w	d4,d2
	lea	-LB_Size(a6,d3.w),a1
	moveq	#0,d0
	bsr	.Rout
.NoIns
; Une fonction?
; ~~~~~~~~~~~~~
	btst	#7,d4
	beq.s	.NoFunc
	move.w	2(a2),d1
	move.w	d4,d2
	lea	-LB_Size-4(a6,d3.w),a1
	moveq	#2,d0
	bsr	.Rout
.NoFunc
; Suivante
; ~~~~~~~~
.Next	addq.l	#4,a2
.Ins	tst.b	(a2)+
	bpl.s	.Ins
.Ins2	tst.b	(a2)+
	bpl.s	.Ins2
	move.l	a2,d0
	and.w	#$0001,d0
	add.w	d0,a2
	move.w	(a2),d3
	bne.s	.Loop
.No20	moveq	#0,d0
	bra	Ll_Out

;	Branche la routine
; ~~~~~~~~~~~~~~~~~~~~~~~~
.Rout	and.w	#$7000,d2		Isole le code
	rol.w	#4,d2			Pointe la table
	lsl.w	#1,d2
	jmp	.Jmps(pc,d2.w)		Branche a la routine
.Jmps	bra.s	.Entier			0
	bra.s	.Float			1
	bra.s	.FAngle			2
	bra.s	.FMath			3
	bra.s	.Var			4
.Float	tst.w	d1			Des parametres?
	beq.s	.Exit
	addq.w	#6,d1			Float
	cmp.w	#6+6,d1
	bcs.s	.Doke
	moveq	#6+5,d1
	bra.s	.Doke
.IVar	add.w	#12,d1			Variable reservee en instruction
	cmp.w	#12+6,d1
	bcs.s	.Doke
	moveq	#12+5,d1
	bra.s	.Doke
.FAngle	moveq	#0,d0
	moveq	#18,d1			Fonction angle
	bra.s	.Doke
.FMath	moveq	#0,d0
	moveq	#19,d1			Fonction math
	bra.s	.Doke
.Var	tst.w	d0			Variable reservee en fonction
	beq.s	.IVar
.Entier	tst.w	d1			Des parametres?
	beq.s	.Exit
	cmp.w	#6,d1			Entier
	bcs.s	.Doke
	moveq	#5,d1
; Doke l'adresse de la fonction
.Doke	add.w	d5,d1			Plus offset general aux routines
	lsl.w	#1,d1			Pointe la table des adresses
	move.w	0(a3,d1.w),d1		Delta au debut
	sub.w	d0,d1			Moins ADDQ.L #2,a6 si fonction
	ext.l	d1
	add.l	a3,d1			Plus debut
	sub.l	a4,d1			Moins base
	move.l	(a1),a0			Adresse de la routine
	move.w	CJsr(pc),d0
	cmp.l	#"GetP",-(a0)		Un espace pour parametres?
	beq.s	.Ok
	cmp.w	4(a0),d0		Deja fait?
	beq.s	.Exit
	illegal
.Ok	move.w	d0,(a0)+		Met le JSR
	move.w	d1,(a0)+		Doke le delta
	subq.l	#4,(a1)			Recule la fonction
.Exit	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				INITIALISATION D'UNE LIBRAIRIE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Library_Init
; - - - - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	lea	AdTokens(a5),a3
	move.w	d0,d1
	lsl.w	#2,d0
	move.l	0(a3,d0.w),d0
	beq	Ll_Out
	move.l	d0,a3
	subq.w	#1,d1			Extension= number-1
	move.w	d1,-(sp)
	move.l	-LB_Size-4(a3),a0	Adresse routine #0
	move.l	LB_Command(a3),a1	Command Line
	move.l	#"APex",d1		Magic
	move.l	#VerNumber,d2		Numero de version
	jsr	(a0)
	move.w	(sp)+,d3
	tst.w	d0			Refuse de charger...
	bpl.s	.Nomi
	cmp.l	#"Asci",d1		Un Message?
	bne	Ll_BadExt
	move.l	a0,d0			Un message?
	bra	Ll_Mess			Oui,
.Nomi	ext.w	d0
	cmp.w	d0,d3			Bon numero d'extension?
	bne	Ll_BadExt
	moveq	#0,d0
	bra	Ll_Out
Ll_Mess	bra	Ll_BadExt		Illegal


; Passe � le prochaine instruction
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ll_TkNext
	addq.l	#4,a0
.Loop1	tst.b	(a0)+
	bpl.s	.Loop1
.Loop2	tst.b	(a0)+
	bpl.s	.Loop2
	move.w	a0,d0
	and.w	#$0001,d0
	add.w	d0,a0
	rts

; Erreurs lors du chargement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TheEnd_Badext
	lea	Panic_Badext(pc),a0
	bra.s	TheEndM
TheEnd_APSystem
	lea	Panic_APSystem(pc),a0
	bra.s	TheEndM
TheEnd_Cantread
	lea	Panic_Cantread(pc),a0
TheEndM	move.l	a0,Panic
	jmp	TheEnd

; Erreur avec datazone non r�serv�e
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Boot_Fatal
; Libere amos.library s'il faut
	move.l	SP_DosBase(sp),a6
	move.l	SP_WSegment(sp),d1
	beq.s	.Skip
	jsr	_LVOUnLoadSeg(a6)
; Affiche le message d'erreur
.Skip	move.l	SP_DosBase(sp),a3
	move.l	SP_IntBase(sp),a4
	move.l	SP_Message(sp),d7
	jsr	Panic_Message
; Ferme DOS / INTUITION
	move.l	$4.w,a6
	move.l	SP_DosBase(sp),a1
	jsr	_LVOCloseLibrary(a6)
	move.l	SP_IntBase(sp),a1
	jsr	_LVOCloseLibrary(a6)
; On peut maintenant sortir!
	move.l	SP_Message(sp),d7
; Va a la sortie generale!
	jmp	Get_Out


;		Data initialisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Nom_W		ds.b	32
NDatas2		dc.b 	"s:"
NDatas1		dc.b 	"AMOSPro_Interpreter_Config",0
NDatas3		dc.b 	"s/AMOSPro_Interpreter_Config",0
LibName1	dc.b	"libs:amos.library",0
LibName2	dc.b	"APSystem/amos.library",0
LibName3	dc.b	"libs/amos.library",0
IconName:	dc.b 	"icon.library",0
FloatName:	dc.b 	"mathffp.library",0
IntName:	dc.b 	"intuition.library",0
GfxName:	dc.b 	"graphics.library",0

AssInst		dc.b	"c:assign",0
AssCall		dc.b	"c:assign ",0
Ass0		dc.b	"AMOSPro_System:",0
		dc.b	0
Ass1		dc.b	"AMOSPro_Accessories:",0
		dc.b	"Accessories",0
Ass2		dc.b	"AMOSPro_Productivity1:",0
		dc.b	"Productivity1",0
Ass3		dc.b	"AMOSPro_Productivity2:",0
		dc.b	"Productivity2",0
Ass4		dc.b	"AMOSPro_Tutorial:",0
		dc.b	"Tutorial",0
Ass5		dc.b	"AMOSPro_Examples:",0
		dc.b	"Examples",0
Ass6		dc.b	"AMOSPro_Compiler:",0
		dc.b	"Compiler",0
Ass7		dc.b	"AMOSPro_Extras:",0
		dc.b	"Extras",0
AssCon		dc.b	"NIL:",0

;		Messages d'erreur d'alerte
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Panic_APSystem	dc.b	"Cannot find APSystem folder.",0
Panic_Lib	dc.b	"Cannot find AMOS.library.",0
Panic_Config	dc.b	"Cannot find AMOSPro_Interpreter_Config.",0
Panic_Command	dc.b	"Bad command line.",0
Panic_Cantread	dc.b	"Cannot read system files: check APSystem folder.",0
Panic_Badext	dc.b	"Cannot load extension: use default interpreter config.",0
Panic_Version	dc.b	"I need AMOS.library V2.0 or over!",0
		even

;		Adresses des routines accessibles aux extensions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AMOSJmps	Include	"+Internal_Jumps.s"
