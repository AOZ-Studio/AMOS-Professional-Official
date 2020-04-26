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
; .200000............2002........................| AMOSPro Compiler
; .200002........................................| Internal library
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

		Include	"+CLib_Size.S"
		Include "+AMOS_Includes.s"
		Include "+Version.s"
; ______________________________________________________________________________

Start		dc.l	C_Lib-C_Off
		dc.l	0
		dc.l	C_End-C_Lib
		dc.l	0
		dc.w	0

;---------------------------------------------------------------------
;		Creates the pointers to functions
;---------------------------------------------------------------------
		MCInit
C_Off
		REPT	Lib_Size
		MC
		ENDR


;---------------------------------------------------------------------
	Lib_Ini	0
;---------------------------------------------------------------------

C_Lib

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Reservatioin du STACK si <>4k	***
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Stack_Reserve
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RESERVATION / LIBERATION MEMOIRE (ancienne!)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; 	Mise a zero!
; ~~~~~~~~~~~~~~~~~~
	Lib_Cmp	RamFast
	move.l	a0,-(sp)
	SyCall	MemFastClear
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
	Lib_Cmp	RamFast2
	move.l	a0,-(sp)
	SyCall	MemFast
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
	Lib_Cmp	RamChip
	move.l	a0,-(sp)
	SyCall	MemChipClear
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
	Lib_Cmp	RamChip2
	move.l	a0,-(sp)
	SyCall	MemChip
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
	Lib_Cmp	RamFree
	move.l	a0,-(sp)
	SyCall	MemFree
	move.l	(sp)+,a0
	rts
;
; 	Reserve / Libere le buffer temporaire
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Cmp	ResTempBuffer
ResTempBuffer
	movem.l	d1/a1,-(sp)
	move.l	d0,d1
; Libere l'ancien buffer
	move.l	TempBuffer(a5),d0
	beq.s	.NoLib
	move.l	d0,a1
	move.l	-(a1),d0
	addq.l	#4,d0
	SyCall	MemFree
	clr.l	TempBuffer(a5)
; Reserve le nouveau
.NoLib	move.l	d1,d0
	beq.s	.Exit
	addq.l	#4,d0
	SyCall	MemFastClear
	beq.s	.Exit
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


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Wait vbl multi tache
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Sys_WaitMul
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
; 	Retourne le message default resource D0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Def_GetMessage
; - - - - - - - - - - - - -
	move.l	Sys_Resource(a5),a0
	add.l	6(a0),a0
	Rbra	L_GetMessage
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Retourne le message system D0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Sys_GetMessage
; - - - - - - - - - - - - -
	move.l	Sys_Messages(a5),a0
	Rbra	L_GetMessage
; - - - - - - - - - - - - -
	Lib_Cmp	GetMessage
; - - - - - - - - - - - - -
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ADDITIONNE LE PATH DU SYSTEME AU NOM A0 >>> NAME1
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Sys_AddPath
; - - - - - - - - - - - - -
	Rbsr	L_Sys_GetPath		Va chercher le path du systeme
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TROUVE LE PATH DU SYSTEME
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Sys_GetPath
; - - - - - - - - - - - - -
	tst.b	Sys_Pathname(a5)
	bne.s	.Fin
; Demande le path si non defini
	movem.l	a0-a3/d0-d7,-(sp)
	moveq	#1,d0				Acces au path
	Rbsr	L_Sys_GetMessage
	move.l	a0,d1				Demande le lock
	moveq	#-2,d2
	DosCall	_LVOLock
	tst.l	d0
	Rbeq	L_DiskError
	Rbsr	L_AskDir2			Demande le directory
	move.l	Buffer(a5),a0			Copie le directory
	lea	384(a0),a0
	lea	Sys_Pathname(a5),a1
.CC	move.b	(a0)+,(a1)+
	bne.s	.CC
	movem.l	(sp)+,a0-a3/d0-d7
; Termine!
.Fin	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ROUTINES DE DEBUGGAGE!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	BugBug
; - - - - - - - - - - - - -
	movem.l	d0-d2/a0-a2,-(sp)
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
; - - - - - - - - - - - - -
	Lib_Cmp	PreBug
; - - - - - - - - - - - - -
 	btst	#6,$BFE001
	Rbeq	L_BugBug
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RECOP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	ReCop
; - - - - - - - - - - - - -
	SyCall	WaitVbl
	EcCall	CopForce
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	GESTION DES LISTES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Cree un element de liste en CHIP MEM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Cmp	Lst.ChipNew
	move.l	#Chip|Clear|Public,d1
	Rbra	L_Lst.Cree
; Cree une element de liste en FAST MEM
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Cmp	Lst.New
	move.l	#Clear|Public,d1
	Rbra	L_Lst.Cree
; Cree un �l�ment en tete de liste A0 / longueur D0 / Memoire D1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Cmp	Lst.Cree
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
	Lib_Cmp	Lst.DelAll
	bra.s	.In
.Loop	move.l	d0,a1
	Rbsr	L_Lst.Del
.In	move.l	(a0),d0
	bne.s	.Loop
	rts
; Efface un �l�ment de liste A1 / Debut liste A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Cmp	Lst.Del
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
	Lib_Cmp	Lst.Insert
	move.l	(a0),(a1)
	move.l	a1,(a0)
	rts

; Enleve un �l�ment de liste A1 / Debut liste A0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Lib_Cmp	Lst.Remove
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
; 					Trouve le directory courant >
;					>>> Buffer + 384
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	AskDir
; - - - - - - - - - - - - -
	move.l	Buffer(a5),a0
	clr.w	(a0)
	clr.w	384(a0)
	move.l	a0,d1
	moveq	#-2,d2
	DosCall	_LVOLock
	tst.l	d0
	Rbne	L_AskDir2
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	AskDir2
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
; 	TOKENISATEUR POUR LE COMPILATEUR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp Tokenisation
; - - - - - - - - - - - - -
	bra	Tokenise
	bra	Tok_Init
	bra	Tok_Del

; Initialisation des tables de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tok_Init
	tst.l	Ed_BufT(a5)
	bne	MTokX
; Reserve le buffer de tokenisation...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#EdBTT,d0
	Rjsr	L_RamFast
	beq	MTError
	move.l	d0,Ed_BufT(a5)
; Fabrique les tables de tokenisation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#1024*12,d0
	Rjsr	L_ResTempBuffer
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
	Rjsr	L_RamFast
	beq	MTError
	move.l	d0,a0
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
	Rjsr	L_ResTempBuffer
	moveq	#0,d0
	rts
; Out of memory!
; ~~~~~~~~~~~~~~
MTError	moveq	#0,d0
	Rjsr	L_ResTempBuffer
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
	Rjsr	L_RamFree
; Efface les tables de tokens rapide
	lea	AdTTokens(a5),a2
	moveq	#25,d1
DlTk1	move.l	(a2)+,d0
	beq.s	DlTk2
	clr.l	-4(a2)
	move.l	d0,a1
	move.l	(a1),d0
	Rjsr	L_RamFree
DlTk2	dbra	d1,DlTk1
DlTkX	rts


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+	TOKENISE LA LIGNE COURANTE
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Tokenise:
	movem.l	a1-a6/d2-d7,-(sp)	* Sauve le debut de la ligne
	move.l	a1,a4
	move.l	a0,a3
	pea	512(a4)
	clr.w	d5			* RAZ de tous les flags
	clr.w	(a4)+

; ----- Compte les TABS
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

; ----- Un chiffre au debut de la ligne?
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

; ----- Une apostrophe en debut de ligne?
TokT2:	cmp.b 	#"'",d0
	bne.s	TokLoop
	addq.l	#1,a3
	move.w	#_TkRem2,(a4)+
	bra	TkKt2

; -----	Prend une lettre
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
	Rbsr	L_CValRout
	bne.s	TkK
	move.l	a0,a3
	move.w	d1,(a4)+
	move.l	d3,(a4)+
	cmp.w	#_TkDFl,d1
	bne	TokLoop
	move.l	d4,(a4)+
	bra	TokLoop
TkK:

; ----- Tokenisation RAPIDE!
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
** Token trouve!
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

; ----- Rien trouve ===> debut d'une variable
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

; ----- Fin de la tokenisation
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
	move.l	a3,a0
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


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TEST DU PROGRAMME POUR COMPILATEUR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Testing
; - - - - - - - - - - - - -
	bra	Init
	bra	PTest
	bra	Fin
	bra	Detok

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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INITIALISATION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Init	bsr	ClearVar
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FIN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Fin	bsr	ClearVar
	bsr	Equ_Free
	bsr	Includes_Clear
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TEST DU PROGRAMME
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PTest:
	move.l	sp,BasSp(a5)		Sauve la pile
	movem.l	a2-a4/a6/d2-d7,-(sp)	Sauvegarde registres

; Recherche les includes / Met l'adresse du programme � runner...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	Prg_Source(a5),Prg_Run(a5)	Par defaut
	bsr	Get_Includes
	tst.l	Prg_FullSource(a5)		Faut-il changer?
	beq.s	.Skip
	move.l	Prg_FullSource(a5),Prg_Run(a5)
.Skip	move.l	Prg_Run(a5),Prg_Test(a5)	A tester

; RAZ de toutes les variables
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
	clr.b	VerNot1.3(a5)		Compatible, au depart...

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

; Libere les tables
; ~~~~~~~~~~~~~~~~~
	bsr	Free_VerTables

; Termine!!!
; ~~~~~~~~~~
	moveq	#0,d0
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
	bra	VerLoop			57-APCmp Call

	IFNE	Debug=2
V1_Debug
	bra	VerDP
	move.b	#Reloc_Debug,d0		Dans relocation
	bsr	New_Reloc
	lea	V2_Debug(pc),a0		Dans TablA
	move.w	#_TkDP,d0
	moveq	#0,d1
	moveq	#1<<VF_Debug,d2
	bsr	Init_TablA
	bra	VerDP
V2_Debug
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

; ----- MESSAGES D'ERREUR VERIFICATION
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
VerErr	move.l	BasSp(a5),sp
	move.l	d0,-(sp)
	move.l	VerPos(a5),a0
	bsr	Includes_Adr
	move.l	a0,VerPos(a5)
	bsr	VD_Close
	bsr	Free_VerTables
	clr.b	VerCheck1.3(a5)
; Trouve le numero de la ligne en question
	move.l	VerPos(a5),a0
	move.l	Prg_Source(a5),a1
	bsr	Tk_FindA		a0= debut de la ligne
	move.l	d0,d1			d1= numero
	move.l	(sp)+,d0		d0= erreur
	rts

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
	JJsr	L_InstrFind
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
	JJsrR	L_CValRout,a1
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
;	lea	Equ_Free(pc),a0
;	lea	Equ_FlushStructure(pc),a1
;	move.l	a0,(a1)
;	SyCall	AddFlushRoutine
; Charge le fichier
	moveq	#9,d0
	Rjsr	L_Sys_GetMessage
	Rjsr	L_Sys_AddPath
	move.l	#1005,d2
	bsr	VD_Open
	beq.s	.Err
; Trouve la taille du fichier!
	moveq	#0,d2
	moveq	#1,d3
	bsr	VD_Seek
	moveq	#0,d2
	moveq	#-1,d3
	bsr	VD_Seek
; Reserve la memoire
	move.l	d0,d3
	move.l	#Fast|Public,d1
	lea	Equ_Base(a5),a0
	bsr	VA5_Reserve
	beq.s	.Err
; Charge le fichier
	move.l	a0,d2
	bsr	VD_Read
	bne.s	.Err
; Ferme le fichier
	bsr	VD_Close
; Retourne l'adresse et la longueur
.Ok	move.l	Equ_Base(a5),a1
	move.l	-4(a1),d1
	movem.l	(sp)+,a0/d2/d3
	rts
; Erreur!
.Err	bsr	VD_Close
	bsr	Equ_Free
	moveq	#52,d0
	bra	VerErr
; 	Libere le fichier d'equates
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Equ_Free
	lea	Equ_Base(a5),a0
	bsr	VA5_Free
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
; Saute une procedure COMPILED
	move.l	4(sp),a0
	btst	#4,8(a0)
	beq.s	.EPLoop
	move.l	2(a0),d0
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
	Rjsr	L_RamFree
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
	Rjsr	L_RamFast
	beq	VerOut
	move.l	d0,a0
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
	bra	Ope_DejaTeste		21- Mid3
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
.jmp	rts				0-Entier
	bra.s	.Float			1-Float
	rts				2-Chaine
	rts				3-Entier/Chaine ??? Impossible
	bra.s	.Indif			4-Entier/Float
.Math	bset	#1,MathFlags(a5)	5-Angle (=math)
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
	moveq	#"0",d2			Type=0, entier!
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


; ----- ENLEVE TOUS LES FLAGS VARIABLE GLOBALE!
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
; ----- MET TOUS LES FLAGS VARIABLE GLOBALE!
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
	Rjsr	L_RamFree
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
	Rjsr	L_RamFast
	beq	VerOut
	move.l	d0,a0
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


; ----- SHARED a,b()

; ----- Routine SHARED: cree les variables
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
; ----- Verification proprement dite
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

; ----- Instruction finie??
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
; Plus de buffers!
; ~~~~~~~~~~~~~~~~
	bsr	ClearBuffers
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; 	Nettoie tous les buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ClearBuffers
	moveq	#0,d0
	JJsr	L_ResTempBuffer
	moveq	#0,d1
	bsr	ResVarBuf
	clr.w	VarBufFlg(a5)
	moveq	#0,d1
	bsr	ResVNom
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
	Rjsr	L_RamFree
Vbr1	move.l	d1,d0
	beq.s	Vbr2
	Rjsr	L_RamFast
 	beq	VerOut
	move.l	d0,a0
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
	Rjsr	L_RamFree
RVn1	move.l	d1,d0
	beq.s	RVn2
	Rjsr	L_RamFast
 	beq	VerOut
	move.l	d0,a0
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
	bsr	VA5_Reserve
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
	bsr	VD_Open
	beq	.DErr
; Verifie entete, prend la taille du source
	move.l	Buffer(a5),d2
	moveq	#16+4,d3
	bsr	VD_Read
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
	bsr	VA5_Reserve
	beq	.MErr
	lea	20(a0),a2			Saute le header
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
	bsr	VD_Read
	bne	.DErr
	add.l	d0,a2
	bsr	VD_Close
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
	bsr	VD_Close
	move.l	Prg_Includes(a5),a3
.Clo	move.l	8(a3),d0
	beq.s	.Nx
	clr.l	8(a3)
	move.l	d0,Handle(a5)
	bsr	VD_Close
.Nx	lea	20(a3),a3
	subq.w	#1,d7
	bne.s	.Clo
; Efface les zones
	bsr	Includes_Clear
; Erreur!
	move.l	(sp)+,d0
	bra	VerErr

; 	Effacement des buffers includes / Retour � la normale
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Includes_Clear
	movem.l	a0-a1/d0-d1,-(sp)
	lea	Prg_FullSource(a5),a0
	bsr	VA5_Free
	lea	Prg_Includes(a5),a0
	bsr	VA5_Free
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

; 	Reserve un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
;	D0=	Longueur
;	D1=	Flags
VA5_Reserve
	movem.l	d0-d2/a1-a2/a6,-(sp)
	move.l	a0,a2
	addq.l	#4,d0
	move.l	d0,d2
	move.l	$4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	.Out
	move.l	d0,a0
	move.l	d2,(a0)+
	move.l	a0,(a2)
.Out	movem.l	(sp)+,d0-d2/a1-a2/a6
	rts
; 	Efface un espace m�moire sur (a5)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	A0=	Adresse dans (a5)
VA5_Free
	movem.l	a0-a1/d0-d1/a6,-(sp)
	move.l	(a0),d0
	beq.s	.Skip
	clr.l	(a0)
	move.l	d0,a1
	move.l	-(a1),d0
	move.l	$4.w,a6
	jsr	_LVOFreeMem(a6)
.Skip	movem.l	(sp)+,a0-a1/d0-d1/a6
	rts

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

;
; NOUVELLE ROUTINES DISQUE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; OPEN: ouvre le fichier systeme (diskname1) access mode D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VD_Open	move.l 	Name1(a5),d1
VD_OpenD1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	move.l	d0,Handle(a5)
	rts

; CLOSE fichier systeme
; ~~~~~~~~~~~~~~~~~~~~~
VD_Close
	movem.l	d0/d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	beq.s	.Skip
	clr.l	Handle(a5)
	move.l	DosBase(a5),a6
	jsr	_LVOClose(a6)
.Skip	movem.l	(sp)+,d0/d1/a0/a1/a6
	rts

; READ fichier systeme D3 octets dans D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VD_Read	movem.l	d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVORead(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts

; WRITE fichier systeme D3 octets de D2
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VD_Write
	movem.l	d1/a0/a1/a6,-(sp)
	move.l	Handle(a5),d1
	move.l	DosBase(a5),a6
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,d1/a0/a1/a6
	cmp.l	d0,d3
	rts

; SEEK fichier system D3 mode D2 deplacement
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VD_Seek	move.l	Handle(a5),d1
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOSeek(a6)
	move.l	(sp)+,a6
	tst.l	d0
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

; ----- Met les espaces devant?
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

; ----- Boucle de detokenisation
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
DtkOpe	lea	Tst_Jumps(pc),a0
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
* Met un espace avant s'il n'y en a pas!
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

; ----- Detokenisation de VARIABLE
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

; ----- Detokenise des constantes
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

; ----- Token d'extension
DtkX:	bra	DtkLoop

; ----- REMarque
DtkRem:	addq.w	#2,a6		Saute la longueur
DtkR:	tst.b	(a6)
	beq	DtkLoop
	move.b	(a6)+,(a4)+
	bra.s	DtkR

;	Fin de la DETOKENISATION
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

;	Donnees
; ~~~~~~~~~~~~~
H_1.3	dc.b	"AMOS Basic v134 "
H_Pro	dc.b	"AMOS Pro101v",0,0,0,0
Equ_LVO	dc.b	10,"_LVO",0
Equ_Nul	dc.b	10,0
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SOUS PROGRAMME UTILISE PAR VAL ET INPUT
;	D0=	Tenir compte du signe (TRUE)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CValRout
; - - - - - - - - - - - - -
        movem.l a1-a2/d5-d7,-(sp)
	move.l	a0,d7
	moveq	#0,d4
	move.l	a0,a2
	tst.w	d0
	beq.s	Cal1c
; y-a-t'il un signe devant?
Cal1:   move.b 	(a0)+,d0
        beq 	Cal10
        cmp.b 	#32,d0
        beq.s 	Cal1
        move.l 	a0,a2
        subq.l 	#1,a2
        cmp.b 	#"-",d0
        bne.s 	Cal1a
        not 	d4
        bra.s 	Cal1c
Cal1a:  cmp.b 	#"+",d0
        beq.s 	Cal1c
Cal1b:  subq.l 	#1,a0
Cal1c
; Explore le chiffre
; ~~~~~~~~~~~~~~~~~~
	move.b 	(a0)+,d0
        beq 	Cal10
        cmp.b 	#32,d0
        beq.s 	Cal1c
        cmp.b 	#"$",d0      	;chiffre HEXA
        beq 	Cal5
        cmp.b	#"%",d0       	;chiffre BINAIRE
        beq 	Cal6
        cmp.b 	#".",d0
        beq.s 	Cal2
        cmp.b 	#"0",d0
        bcs 	Cal10
        cmp.b 	#"9",d0
        bhi 	Cal10
; c'estn chiffre DECIMAL: entier ou float?
Cal2:   subq.l	#1,a0
	move.l 	a0,a1        	;si float: trouve la fin du chiffre
        clr 	d3
Cal3:   move.b 	(a1)+,d0
        beq.s 	Cal4
        cmp.b 	#32,d0
        beq.s 	Cal3
        cmp.b 	#"0",d0
        bcs.s 	Cal3z
        cmp.b 	#"9",d0
        bls.s 	Cal3
Cal3z:  cmp.b 	#".",d0       	;cherche une "virgule"
        bne.s	Cal3a
        bset 	#0,d3          	;si deux virgules: fin du chiffre
        beq.s 	Cal3
        bne.s 	Cal4
Cal3a:  cmp.b 	#"e",d0       	;cherche un exposant
        beq.s 	Cal3b
        cmp.b 	#"E",d0       	;autre caractere: fin du chiffre
        bne.s 	Cal4
Cal3ab: move.b 	#"e",-1(a1)  	;met un E minuscule!!!
Cal3b:  move.b 	(a1)+,d0     	;apres un E, accepte -/+ et chiffres
        cmp.b 	#32,d0
        beq.s 	Cal3b
        cmp.b 	#"+",d0
        beq.s 	Cal3c
        cmp.b 	#"-",d0
        bne.s 	Cal3e
Cal3c:  bset 	#1,d3          	;+ ou -: c'est un float!
Cal3d:  move.b 	(a1)+,d0     	;puis cherche la fin de l'exposant
        cmp.b 	#32,d0
        beq.s 	Cal3d
Cal3e:  cmp.b 	#"0",d0
        bcs.s 	Cal4
        cmp.b 	#"9",d0       	;chiffre! c'est un float
        bls.s 	Cal3c
Cal4:   tst 	d3              ;si d3=0: c'est un entier
        beq 	Cal7
; conversion ASCII--->FLOAT
	move.l	a2,a0
        subq.l 	#1,a1
	movem.l	a1/a3-a6,-(sp)
	lea 	BuFloat(a5),a2
	move.l	a2,-(sp)
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
	Rjsr 	L_AscToFloat
	addq.l 	#4,sp
	move.l	d0,d3
        moveq 	#1,d2
        move.w 	#_TkFl,d1        	chiffre FLOAT
	bset	#0,MathFlags(a5)	Un peu de maths
	bra.s	.FQuit
; Double precision
.Double	Rjsr	L_AscToDouble
	addq.l	#4,sp
	move.l	d0,d3
	move.l	d1,d4
	moveq	#1,d2
	move.w	#_TkDFl,d1
.FQuit	movem.l	(sp)+,a0/a3-a6
	moveq	#0,d0
	bra.s	CalOut
; chiffre hexa
Cal5:   bsr 	Cexalong
        move.w 	#_TkHex,d2
        bra.s 	Cal8
; chiffre binaire
Cal6:   bsr 	Cinlong
        move.w 	#_TkBin,d2
        bra.s 	Cal8
; chiffre entier
Cal7:   bsr 	Ceclong
        move.w 	#_TkEnt,d2
Cal8:   exg 	d2,d1           ;type de conversion--->d1
        tst 	d2
        bne.s 	Cal10           ;si probleme: ramene zero!
        move.l 	d0,d3
; Test du signe, si entier
        tst 	d4
        beq.s 	Cal8a
        neg.l 	d3
Cal8a:	moveq	#0,d2
	bra.s	CalOut
; ramene zero
Cal10:  moveq	#0,d2           		Erreur: ramene zero!
        moveq	#0,d3
	move.l	d7,a0
	moveq	#1,d0
; Sortie
CalOut 	movem.l (sp)+,a1-a2/d5-d7
        rts

; 	MINI CHRGET POUR LES CONVERSIONS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cinichr	move.b 	(a0)+,d2
        beq.s 	.mc1
        cmp.b 	#32,d2
        beq.s 	Cinichr
        cmp.b 	#"a",d2       ;si minuscule: majuscule
        bcs.s 	.mc0
        sub.b 	#"a"-"A",d2
.mc0    sub.b 	#48,d2
        rts
.mc1    move.b 	#-1,d2
        rts
; Minichr pour hexa
; ~~~~~~~~~~~~~~~~~
Cinichr2
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
Ceclong moveq	#0,d0
 	moveq	#0,d2
        moveq	#0,d3
        move.l 	a0,-(sp)
Cdh1:   bsr 	Cinichr
Cdh1a:  cmp.b 	#10,d2
        bcc.s 	Cdh5
        move 	d0,d1
        mulu 	#10,d1
        swap 	d0
        mulu 	#10,d0
        swap 	d0
        tst 	d0
        bne.s 	Cdh2
        add.l 	d1,d0
        bcs.s 	Cdh2
        add.l	d2,d0
        bmi.s 	Cdh2
        addq 	#1,d3
        bra.s 	Cdh1
Cdh2:   move.l 	(sp)+,a0
        moveq	#1,d1          	;out of range: bpl, et recupere l'adresse
        rts
Cdh5:   subq.l 	#1,a0
	addq.l 	#4,sp
        tst	d3
        beq.s 	Cdh7
        moveq	#0,d1           ;OK: chiffre en d0, et beq
        rts
Cdh7:   moveq	#-1,d1     	;pas de chiffre: bmi
        rts

; 	CONVERSION HEXA-ASCII EN HEXA-HEXA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cexalong
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
        move.l 	a0,-(sp)
.hh1    bsr 	Cinichr2
        cmp.b 	#10,d2
        bcs.s 	.hh2
        cmp.b 	#17,d2
        bcs.s 	Cdh5
        subq.w 	#7,d2
.hh2    cmp.b 	#16,d2
        bcc.s 	Cdh5
        lsl.l 	#4,d0
        or.b 	d2,d0
        addq.w 	#1,d3
        cmp 	#9,d3
        bne.s 	.hh1
        beq.s 	Cdh2

; 	CONVERSION BINAIRE ASCII ---> HEXA SUR QUATRE OCTETS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cinlong	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
        move.l 	a0,-(sp)
.bh1    bsr 	Cinichr
        cmp.b 	#2,d2
        bcc.s 	Cdh5
        roxr 	#1,d2
        roxl.l 	#1,d0
        bcs.s 	Cdh2
        addq.w	#1,d3
        cmp.w 	#33,d3
        bne.s 	.bh1
        beq 	Cdh1



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INITIALISATION PROGRAMME COMPILE PART 1
;	D0= Longueur du stack
;	D1= Longueur buffer
;	D2= Flags initialisation
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpInit1
; - - - - - - - - - - - - -
; Branche la routine de fin, si non definie
	tst.l	Prg_JError(a5)
	bne.s	.Skip
	lea	CmpQuit(pc),a0
	move.l	a0,Prg_JError(a5)
.Skip
; Stocke les flags de demarrage. Negatif >>> abort!
	move.w	d2,DefFlag(a5)
	bmi.s	.Mem
; Longueur du stack ***
; Flag WB2.0
	move.l	$4.w,a0
	cmp.w	#36,$14(a0)
	bcs.s	.Pa20
	move.w	$14(a0),WB2.0(a5)
.Pa20
; Init VARBUF
	move.l	d1,d0
	SyCall	MemFastClear
	beq.s	.Mem
	move.l	a0,VarBuf(a5)
	move.l	d1,VarBufL(a5)
; Ok, Passe aux autres inits
	move.w	#-1,T_AMOState(a5)
	rts
; Out of memory
.Mem	moveq	#2,d0
	move.l	Prg_JError(a5),a1
	jmp	(a1)
; - - - - - - - - - - - - -
CmpQuit
; - - - - - - - - - - - - -
	movem.l	a0/d0,-(sp)		Sauve les erreurs
	move.w	#-2,DefFlag(a5)
	Rbsr	L_DefRun1
	Rjsr	L_Bnk.EffAll
	Rbsr	L_CmpClearVar
	Rbsr	L_CmpLibrariesStop
	lea	Sys_EndRoutines(a5),a1	Appelle les routines de fin
	SyCall	CallRoutines
	SyCall	MemFlush		Enleve les routines flush
	Rbsr	L_CmpLibClose
	Rbsr	L_CmpEffVarBuf
; Retourne a l'appellant!
	movem.l	(sp)+,a0/d0
	move.l	BasSp(a5),sp
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INITIALISATION PROGRAMME COMPILE PART 2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpInit2
; - - - - - - - - - - - - -
	tst.l	d0			Un probleme dans les extensions?
	bne.s	.Quit
; Initialisation ecrans
	move.w	DefFlag(a5),d5		Flags de demarrage
	moveq	#-2,d0
	btst	#FPrg_Default,d5		Ecran par defaut?
	beq.s	.Skip1
	moveq	#-1,d0
.Skip1	move.w	d0,DefFlag(a5)
	btst	#FPrg_DefRunAcc,d5	Programme en accessoire?
	bne.s	.Acc
	Rbsr	L_DefRun1
	Rbsr	L_DefRun2
	bra.s	.Skip2
.Acc	Rbsr	L_DefRunAcc
.Skip2	move.w	#-1,DefFlag(a5)		Pour le prochaine Default
; Force l'affichage
	SyCall	WaitVbl
	EcCall	CopForce
; Fin de l'init
	Rbsr	L_CmpClearVar		>>> Change A6
; Fait passer devant le workbench?
	btst	#FPrg_Wb,d5		Flag workbench?
	bne.s	.WB
	EcCalD	AMOS_WB,1
.WB	rts
.Quit	move.l	Prg_JError(a5),a1
	jmp	(a1)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	INITIALISATION / SORTIE AMOS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	AMOSInit
; - - - - - - - - - - - - -
	move.l	(sp)+,a1
; 	Sauvegarde des donnees du programme courant
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	a3-a6/d6/d7,-(sp)
	move.l	Prg_JError(a5),-(sp)
	move.l	EveLabel(a5),-(sp)
	move.l	BasSp(a5),-(sp)
	move.l	sp,BasSp(a5)
;	Preparation des variables du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	AMOSQuit(pc),a0
	move.l	a0,Prg_JError(a5)
	clr.l	EveLabel(a5)
	move.l	TabBas(a5),d7
	sub.l	a6,a6
	jmp	(a1)
; - - - - - - - - - - - - -
AMOSQuit
; - - - - - - - - - - - - -
	move.l	BasSp(a5),sp
	move.l	(sp)+,BasSp(a5)
	move.l	(sp)+,EveLabel(a5)
	move.l	(sp)+,Prg_JError(a5)
	movem.l	(sp)+,a3-a6/d6/d7
;	Si erreur dans le programme: appelle les routines DEFAULT / END
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l	a0/d0,-(sp)
	lea	Sys_ErrorRoutines(a5),a1
	SyCall	CallRoutines
	lea	Sys_ClearRoutines(a5),a1
	SyCall	CallRoutines
	lea	Sys_DefaultRoutines(a5),a1
	SyCall	CallRoutines
	lea	Sys_EndRoutines(a5),a1
	SyCall	CallRoutines
	movem.l	(sp)+,a0/d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MODE DEBUG: rajoute "At Line" au message d'erreur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpDbMode
; - - - - - - - - - - - - -
	move.l	(sp),a0		Branche la routine sur le retour
	lea	.Debug(pc),a1
	move.l	a1,(sp)
	move.l	sp,BasSp(a5)
	jmp	(a0)
.Debug	tst.w	d0		Une erreur?
	beq.s	.End
	move.l	d0,-(sp)
	lea	.Buffer(pc),a2
	move.l	a0,d1
	beq.s	.NoMess
	move.l	d1,a1
.Copy1	move.b	(a1)+,(a2)+
	bne.s	.Copy1
	subq.l	#1,a2
.NoMess	lea	.Atline(pc),a1
.Copy2	move.b	(a1)+,(a2)+
	bne.s	.Copy2
	lea	-1(a2),a0
	moveq	#0,d0
	move.w	Cmp_Ligne(a5),d0
	Rjsr	L_LongToDec
	clr.b	(a0)
	move.l	(sp)+,d0
	lea	.Buffer(pc),a0
; Retourne au header
.End	rts
.Buffer	ds.b	128
.Atline	dc.b	" at line ",0
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MODE DEBUG 1 : imprime le numero de la ligne sur le CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpLineCLI
; - - - - - - - - - - - - -
	moveq	#0,d0
	move.w	Cmp_Ligne(a5),d0
	move.l	Buffer(a5),a0
	move.b	#"(",(a0)+
	Rjsr	L_LongToDec
	move.b	#")",(a0)+
	move.l	a0,d3
	move.l	Buffer(a5),d2
	sub.l	d2,d3
	Rbra	L_CmpPrintCLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MODE DEBUG 2 : imprime le numero su run ecran AMOS en front
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpLineSER
; - - - - - - - - - - - - -
	moveq	#0,d0
	move.w	Cmp_Ligne(a5),d0
	move.l	Buffer(a5),a0
	move.b	#"(",(a0)+
	Rjsr	L_LongToDec
	move.b	#")",(a0)+
	move.l	a0,d3
	move.l	Buffer(a5),d2
	sub.l	d2,d3
	Rbra	L_CmpPrintSER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Imprime la chaine D2/D3 sur le CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpPrintCLI
; - - - - - - - - - - - - -
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-60(a6)
	move.l	d0,d1
	beq.s	.Exit
	jsr	_LVOWrite(a6)
.Exit	move.l	(sp)+,a6
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Imprime la chaine D2/D3 sur le AMOS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpPrintSER
; - - - - - - - - - - - - -
;	tst.w	Cmp_DebugScreen(a5)
;	bne.s	.Done
;	movem.l	d0-d7/a0-a3,-(sp)
;	moveq	#8,d1			Ecran editeur
;	move.w	#640,d2
;	move.w	#8*8,d3
;	moveq	#2,d4
;	move.w	#$8000,d5
;	moveq	#4,d6
;	lea	DefPal(a5),a1
;	EcCall	Cree
;	beq.s	.End
;	move.w	#8,Cmp_DebugScreen(a5)
;.Done	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Effacement du buffer de variables
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpEffVarBuf
; - - - - - - - - - - - - -
	move.l	VarBuf(a5),d0
	beq.s	.skip
	move.l	d0,a1
	move.l	VarBufL(a5),d0
	SyCall	MemFree
	clr.l	VarBuf(a5)
.skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	APPEL INITIALISATION DES EXTENSIONS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpLibrariesInit
; - - - - - - - - - - - - -
	tst.b	AdTokens(a5,d0.w)
	bne.s	.Dejala
	addq.b	#1,AdTokens(a5,d0.w)	On la met!
	move.w	d0,-(sp)		# extension
	move.l	Name1(a5),a1		Command line vide
	clr.b	(a1)
	move.l	#"APex",d1		Code AMOSPro
	move.l	#VerNumber,d2		Numero de version
	jsr	(a0)			Appel
	move.w	(sp)+,d3
	ext.w	d0			Refuse de charger...
	bpl.s	.Nomi
	move.l	a0,d0
	cmp.l	#"Err!",d1		Un Message?
	beq.s	.Mess
.Err	moveq	#-2,d0			Message header 1: cannot load ext
	bra.s	.Out
.Mess	moveq	#-1,d0			Message en A0
.Out	rts
.Nomi	cmp.w	d0,d3			Bon numero d'extension?
	bne.s	.Err
.Dejala	moveq	#0,d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	ARRET DES LIBRAIRIES Extensions
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpLibrariesStop
; - - - - - - - - - - - - - - - -
	movem.l	a2-a6/d2-d7,-(sp)
	moveq	#26-1,d2
	lea	ExtAdr+26*16-16(a5),a2
	lea	AdTokens+26-1(a5),a3
.Loop	tst.b	(a3)			Une extension?
	beq.s	.Next
	subq.b	#1,(a3)			Decremente le compteur
	bne.s	.Next
	move.l	8(a2),d0		Une routine de fin?
	beq.s	.Next
	move.l	d0,a0
	movem.l	a2/a3/d2,-(sp)		Appel de la routine de fin
	jsr	(a0)
	movem.l	(sp)+,a2/a3/d2
	move.l	a2,a0
	clr.l	(a0)+			Efface les pointeurs
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
.Next	lea	-16(a2),a2
	subq.l	#1,a3
	dbra	d2,.Loop
	movem.l	(sp)+,a2-a6/d2-d7
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Ferme les libraries mathematiques
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpLibClose
; - - - - - - - - - - - - -
	move.l	a6,-(sp)
	move.l	$4.w,a6
	move.l	FloatBase(a5),d0
	beq.s	.SkipM1
	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)
	clr.l	FloatBase(a5)
.SkipM1	move.l	MathBase(a5),d0
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	NETTOYAGES DES VARIABLES pour programme CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpClearVar
; - - - - - - - - - - - - -

	movem.l	d0-d6/a0-a5,-(sp)

; Variables du programme
; ~~~~~~~~~~~~~~~~~~~~~~
	lea	DebRaz(a5),a0
	lea	FinRaz(a5),a1
.ClV1	clr.w	(a0)+
	cmp.l	a1,a0
	bcs.s	.ClV1
	clr.b	Test_Flags(a5)
; Initialisation du disque
; ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	#$FFFFFFFF,IffMask(a5)
	moveq	#47,d0
	Rjsr	L_Sys_GetMessage
	move.l	DirFNeg(a5),a1
.ClV2	move.b	(a0)+,(a1)+
	bne.s	.ClV2
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
	Rjsr	L_Bnk.EffTemp
	Rjsr	L_Bnk.Change
	Rjsr	L_MenuReset
	Rjsr	L_Dia_WarmInit
	clr.l	EveLabel(a5)

;	Rjsr	L_FillFFree			* Fait!
;	Rjsr	L_CloAll			* Fait!
;	Rjsr	L_PRT_Close			* Fait!
;	Rjsr	L_Dev.Close			* Fait!
;	Rjsr	L_Lib.Close			* Fait!
;	Rjsr	L_Arx_Close			* Fait!
;	Rjsr	L_MnRaz				* Fait!
;	Rjsr	L_OMnEff			* Fait!
;	Rjsr	L_Dia_CloseChannels		* Fait!
;	Rjsr	L_ResTempBuffer			* Fait!

; Variables
; ~~~~~~~~~
	move.l	VarBuf(a5),d0
	beq.s	.Nul
	move.l	d0,a0
	move.l	a0,a1
	add.l	VarBufL(a5),a1
	move.l	a1,TabBas(a5)
	move.l	a1,d7			VGlobales
;	clr.l	VarLoc(a5)		Au depart
	sub.l	a6,a6
	move.l	a0,LoChaine(a5)
	move.l	a0,ChVide(a5)
	move.l	a0,ParamC(a5)
	clr.w	(a0)+
	move.l	a0,HiChaine(a5)
.Nul
; Init float
; ~~~~~~~~~~
	move.w	#-1,FixFlg(a5)
	clr.w	ExpFlg(a5)
	movem.l	(sp)+,d0-d6/a0-a5
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Operateur PLUS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PlusF
; - - - - - - - - - - - - -
	moveq	#_LVOSPAdd,d2
	Rjmpt	L_Float_Operation
; - - - - - - - - - - - - -
	Lib_Cmp	PlusC
; - - - - - - - - - - - - -
	move.l 	d3,a0
	move.l	(a3)+,a2
        moveq	#0,d3
        move.w 	(a0),d3        		;taille de la deuxieme chaine
        beq.s 	plus11        		;deuxieme chaine nulle
        moveq	#0,d0
        move.w 	(a2),d0
        beq.s 	plus10          	;premiere chaine nulle
        add.l 	d0,d3
        cmp.l 	#String_Max,d3
        Rbcc 	L_StooLong		;string too long!
	move.l	a0,-(sp)
        Rbsr 	L_Demande
        move.w 	d3,(a0)+       		;poke la taille resultante
        move.w 	(a2)+,d0
        beq.s 	plus4
        subq.w 	#1,d0
plus3:  move.b 	(a2)+,(a0)+  		;recopie de la premiere chaine
        dbra 	d0,plus3
plus4:  move.l 	(sp)+,a2
        move.w 	(a2)+,d0
        beq.s 	plus6
        subq 	#1,d0
plus5:  move.b 	(a2)+,(a0)+
        dbra 	d0,plus5
plus6:  move.w 	a0,d0          		;rend pair
        btst 	#0,d0
        beq.s 	plus7
        addq.l 	#1,a0
plus7:  move.l 	a0,HiChaine(a5)
        move.l 	a1,d3
	rts
plus10: move.l 	a0,d3     	;premiere chaine nulle: ramene la deuxieme
	rts
plus11: move.l 	a2,d3        	;deuxieme chaine nulle: ramene la premiere
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Operateur moins
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	MoinsF
; - - - - - - - - - - - - -
	moveq	#_LVOSPSub,d2
	Rjmpt	L_Float_Operation
; - - - - - - - - - - - - -
	Lib_Cmp	MoinsC
; - - - - - - - - - - - - -
	move.l	d3,d4        	;sauve pour plus tard
        move.l 	(a3)+,a2
        clr.l 	d3
        move.w 	(a2)+,d3
        move.l 	d3,d1
        Rbsr 	L_Demande       ;prend la place une fois pour toute!
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
	Rbsr	L_InstrFind
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
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Operateur MULTIPLIE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	MultE
; - - - - - - - - - - - - -
	move.l	(a3)+,d2
	clr 	d4            ;multiplication signee 32*32 bits
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
        bmi.s 	mltO
        swap 	d2
        move 	d2,d0
        mulu 	d3,d0
        swap 	d0
        bmi.s 	mltO
        tst 	d0
        bne.s 	mltO
        add.l 	d0,d1
        bvs.s 	mltO
        swap 	d3
        move 	d2,d0
        mulu 	d3,d0
        bne.s 	mltO
        swap 	d2
        move 	d2,d0
        mulu 	d3,d0
        swap 	d0
        bmi.s 	mltO
        tst 	d0
        bne.s 	mltO
        add.l 	d0,d1
        bvs.s 	mltO
        tst 	d4              ;signe du resultat
        beq.s 	mlt3
        neg.l 	d1
mlt3:   move.l 	d1,d3
mltF:	rts
mltO	Rbra	L_OverFlow
; - - - - - - - - - - - - -
	Lib_Cmp	MultF
; - - - - - - - - - - - - -
	moveq	#_LVOSPMul,d2
	Rjmpt	L_Float_Operation

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Operateur DIVISE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DiviseE
; - - - - - - - - - - - - -
 	move.l	(a3)+,d2
        moveq	#0,d4
        tst.l 	d2
        bpl.s 	dva
        bset	#31,d4
        neg.l 	d2
dva:    tst.l 	d3
        Rbeq 	L_DByZero         ;division par zero!
        bpl.s 	dvb
    	bchg	#31,d4
        neg.l 	d3
dvb:	cmp.l 	#$10000,d3    	;Division rapide ou non?
        bcc.s 	dv0
	move.l 	d2,d0
        divu 	d3,d0           ;division rapide: 32/16 bits
        bvs.s 	dv0
        moveq 	#0,d3
        move	d0,d3
        bra.s 	dvc
dv0:    move.w 	#31,d4         ;division lente: 32/32 bits
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
dvd:	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DiviseF
; - - - - - - - - - - - - -
	Rjsrt	L_Float_Test
	Rbeq	L_DByZero
	moveq	#_LVOSPDiv,d2
	Rjmpt	L_Float_Operation

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Operateur PUISSANCE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Puissance
; - - - - - - - - - - - - -
	moveq	#_LVOSPPow,d2
	Rjmpt	L_Math_Operation

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Operateur MODULO
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Modulo
; - - - - - - - - - - - - -
	move.l	d6,-(sp)
	move.l	(a3)+,d6
	tst.l 	d3
        bpl.s 	mdv3
        neg.l 	d3
mdv3:   moveq 	#31,d2         	;division lente: 32/32 bits
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
	move.l 	d1,d3        	;prend le reste!
	move.l	(sp)+,d6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Comparaison de deux chaines
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Chaine_Compare
; - - - - - - - - - - - - -
	move.l	(a3)+,a0
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
; on est arrive au bout d'une des chaines
cpch2:  moveq 	#1,d4         	A$>B$
	bra.s	cpch5
cpch3:  subq 	#1,d1         	egalite!
        beq.s 	cpch5
cpch4:  moveq 	#1,d3         	B$>A$
cpch5:  cmp.l	d4,d3		Positionne les bits
	rts
; on est arrive au bout des chaines
cpch6:  bcc.s 	cpch4
        bcs.s 	cpch2
; a$ est nulle
cpch7:  tst 	d1
        bne.s 	cpch4           ;B$>A$
	bra.s	cpch5
; b$ est nulle
cpch8:  tst 	d0
        bne.s 	cpch2           ;A$>B$
	bra.s	cpch5

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEFRUN: initialisation graphique
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DefRun1
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
; Call extensions
; ~~~~~~~~~~~~~~~
	Rbsr	L_DefRunExtensions
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
DRex0	movem.l	(sp)+,d0-d7/a0-a6
DRunX	rts

; - - - - - - - - - - - - -
	Lib_Cmp	DefRun2
; - - - - - - - - - - - - -
	tst.w	DefFlag(a5)
	beq.s	.Out
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
.Out	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEFRUNACC: semi initialisation graphique pour accessoires
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DefRunAcc
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
	Lib_Cmp	DefRunExtensions
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
; 	END
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InEnd
; - - - - - - - - - - - - -
	moveq	#NbEnd,d0
	Rbra	L_GoError

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TEST INTER SANS SAUT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Test_PaSaut
; - - - - - - - - - - - - -
	movem.l	d0-d7/a0-a2,-(sp)
	bset	#Bit_PaSaut,Test_Flags(a5)
	Rbsr	L_Test_Normal
	bclr	#Bit_PaSaut,Test_Flags(a5)
	movem.l	(sp)+,d0-d7/a0-a2
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TEST NORMAL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Test_Normal
; - - - - - - - - - - - - -
	moveq	#1,d6
	tst.b	T_Actualise(a5)
	Rbmi	L_Test_Force
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TEST FORCE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Test_Force
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
	move.l	GoTest_Dialog(a5),a0
	jsr	(a0)
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
	move.l	GoTest_MenuKey(a5),a0	Appelle la routine
	jsr	(a0)
Tst0a	btst	#10,$dff016		Afficher le menu?
	bne.s	Tst0
	move.l	GoTest_Menus(a5),a0
	jsr	(a0)
	Rbne	L_Error

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
	Rbra	L_Error
Tst01	move.w	d3,T_Actualise(a5)
	move.l	GoTest_OnBreak(a5),d0
	beq.s	Tst1a
	move.l	d0,a0
	jsr	(a0)
	bra.s	Tst1a

; Branchement automatique aux menus?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tst1	bclr	#BitJump,d3
	beq.s	Tst1a
	move.l	GoTest_GoMenu(a5),a0
	jsr	(a0)

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
	move.l	GoTest_Every(a5),a0
	jsr	(a0)

TstX2	bclr 	#BitVBL,T_Actualise(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Fait le branchement ON MENU
;	Appele par TESTS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GoMenu
; - - - - - - - - - - - - -
	tst.w	EveLabel(a5)
	bmi.s	.GoMX
	lea	MnChoix(a5),a0
	move.w	(a0),d0
	beq.s	.GoMX
	cmp.w	OMnNb(a5),d0
	bls.s	.GoMGo
.GoMX:	rts
; Fait le branchement
.GoMGo	bclr	#BitJump,d4		Restore les actualisations
	move.w	d4,ActuMask(a5)
	move.w	d3,T_Actualise(a5)
	Rbsr	L_GetInstruction	Adresse de l'instruction courante
	moveq	#1,d6			Pour les erreurs
	move.l	BasA3(a5),a3		Pile parametres
	move.l	Cmp_LowPile(a5),sp
	move.l	OMnBase(a5),a0
	lsl.w	#2,d0
	move.l	-4(a0,d0.w),a0		Adresse du saut
	tst.w	OMnType(a5)
	bmi.s	GoMG2
	beq.s	GoMG1
; 1: Procedure!
	move.l	a1,-(sp)		Adresse de retour
	jmp	(a0)
; 0: Gosub
GoMG1	move.l	a1,-(sp)		Simple JSR
	move.l	sp,Cmp_LowPile(a5)
	jmp	(a0)
; -1: Goto
GoMG2	jmp	(a0)			Simple JMP

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Fait le branchement a ON BREAK 	*** Brancher / Tester
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	OnBreakGo
; - - - - - - - - - - - - -
	btst	#Bit_PaSaut,Test_Flags(a5)
	beq.s	.Skip
	tst.l	OnBreak(a5)
	bne.s	.Jmp
.Skip	rts
.Jmp	Rbsr	L_GetInstruction	Instruction courante
	moveq	#1,d6			Pas d'erreur
	move.l	Cmp_LowPile(a5),sp
	move.l	a1,-(sp)
	move.l	OnBreak(a5),a0
	jmp	(a0)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Fait le branchement a EVERY	*** Tester
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	EveJump
; - - - - - - - - - - - - -
	tst.l	EveLabel(a5)
	bne.s	EveJ1
EveJ0	rts
; Branche!
EveJ1	bmi.s	EveJ0
	bclr	#BitEvery,d4
	move.w	d4,ActuMask(a5)
	Rbsr	L_GetInstruction	Adresse instruction courante
	moveq	#1,d6			Pas de probleme erreur
	move.l	Cmp_LowPile(a5),sp	Restore la pile
	move.l	EveLabel(a5),a0		Le label
	tst.w	EveType(a5)
	bne.s	EveJ2
; Gosub!
	move.l	a1,-(sp)
	move.l	sp,Cmp_LowPile(a5)
	jmp	(a0)
; Procedure!
EveJ2	move.l	a1,-(sp)
	jmp	(a0)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Erreurs de la premiere partie
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; - - - - - - - - - - - - -
	Lib_Cmp	RIllDir
; - - - - - - - - - - - - -
	moveq	#17,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	OOfData
; - - - - - - - - - - - - -
	moveq	#33,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	OOfBuf
; - - - - - - - - - - - - -
	moveq	#11,d0			Out of buffer space
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	InpTL
; - - - - - - - - - - - - -
	moveq	#DEBase+20,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	EProErr
; - - - - - - - - - - - - -
	moveq	#8,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	ResLNo
; - - - - - - - - - - - - -
	moveq	#6,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	NoOnErr
; - - - - - - - - - - - - -
	moveq	#5,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	ResPLab
; - - - - - - - - - - - - -
	moveq	#4,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	NoResume
; - - - - - - - - - - - - -
	moveq	#3,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	NoErr
; - - - - - - - - - - - - -
	moveq	#7,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	OofStack
; - - - - - - - - - - - - -
	moveq 	#13,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	NonDim
; - - - - - - - - - - - - -
	moveq 	#27,d0
	Rbra 	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	AlrDim
; - - - - - - - - - - - - -
	moveq 	#28,d0
	Rbra 	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	DByZero
; - - - - - - - - - - - - -
	moveq 	#20,d0
	Rbra 	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	OverFlow
; - - - - - - - - - - - - -
	moveq 	#29,d0
	Rbra 	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	RetGsb
; - - - - - - - - - - - - -
	moveq	#1,d0
	Rbra	L_Error
; - - - - - - - - - - - - -
	Lib_Cmp	PopGsb
; - - - - - - - - - - - - -
	moveq	#2,d0
	Rbra	L_Error

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TRAITEMENT DES ERREURS RunErr:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Error
; - - - - - - - - - - - - -
	moveq	#19,d1
	moveq	#-1,d2
	Rbra	L_ErrorExt
; - - - - - - - - - - - - -
	Lib_Cmp	ErrorExt
; - - - - - - - - - - - - -
; Recupere les registres?
; ~~~~~~~~~~~~~~~~~~~~~~~
	tst.b	ErrorRegs(a5)
	beq.s	.Skip
	clr.b	ErrorRegs(a5)
	movem.l	ErrorSave(a5),d6-d7
.Skip
; Ferme toutes les routines appellees
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Rjsr	L_D_Close
;	Rjsr	L_ResTempBuffer
;	Rjsr	L_MnEnd			rajouter lors de procedure menu!
	movem.l	d0-d3/a0,-(sp)
	lea	Sys_ErrorRoutines(a5),a1
	SyCall	CallRoutines
	movem.l	(sp)+,d0-d3/a0
; Peut-on detourner l'erreur?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	clr.l	PrintPos(a5)
	clr.w	InputFlg(a5)
	clr.w	ContFlg(a5)
	cmp.w	#11,d0			Variable space?
	beq.s	.skip
	cmp.w	d1,d0
	bcs	rErr1
.skip	cmp.w	#1000,d0		Edit / Direct?
	bcc	rErr1
	tst.w	Direct(a5)		Mode direct
	bne	rErr1
	tst.w	ErrorOn(a5)		Erreur en route
	bne	rErr1
	Rbsr	L_GetInstruction	Trouve l'adresse de l'instruction
	cmp.l	TrapAdr(a5),a1		TRAP?
	beq.s	.ETrap
	tst.l	OnErrLine(a5)		On error goto
	beq	rErr1
; Erreurs detournees
; ~~~~~~~~~~~~~~~~~~
	clr.l	TrapAdr(a5)		Plus de trap
	clr.w	TrapErr(a5)
	addq.w	#1,d0
	addq.w	#1,d2
	lsl.w	#8,d2
	or.w	d2,d0
	move.w	d0,ErrorOn(a5)		Numero de l'erreur
	move.l	BasA3(a5),a3		Restore les piles
	move.l	Cmp_LowPile(a5),sp
	tst.w	ErrorChr(a5)
	bmi.s	.rErr0
	move.l	a1,ErrorChr(a5)
	move.l	OnErrLine(a5),a0
	jmp	(a0)
; ON ERROR PROC
; ~~~~~~~~~~~~~
.rErr0	move.l	a1,-(sp)		Adresse de l'instruction
	move.l	OnErrLine(a5),a0	Adresse de la procedure
	jmp	2(a0)			D0= ErrorOn / Skippe le moveq #0,d0
; Nouvelle intruction TRAP
; ~~~~~~~~~~~~~~~~~~~~~~~~
.ETrap	clr.l	TrapAdr(a5)
	addq.w	#1,d2
	lsl.w	#8,d2
	or.w	d2,d0
	move.w	d0,TrapErr(a5)
	move.l	BasA3(a5),a3
	move.l	Cmp_LowPile(a5),sp
	jmp	(a2)			Continue a l'instruction suivante

; Une erreur extension?
; ~~~~~~~~~~~~~~~~~~~~~
rErr1	move.l	Prg_JError(a5),a2	Branchement de fin
	ext.l	d0
	move.l	d0,d1
	tst.w	d2
	bpl.s	.ExtErr
; Erreur normale
; ~~~~~~~~~~~~~~
	cmp.w	#NbEnd,d0		End
	beq.s	.Nul
	cmp.w	#1000,d0		Edit / Direct
	bcc.s	.Nul
	move.l	Ed_RunMessages(a5),a0	Trouve le message
	addq.w	#1,d0
	Rbsr	L_GetMessage
	move.l	d1,d0
	jmp	(a2)
; Erreur extension: trouve le message
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ExtErr	tst.l	d3
	beq.s	.Ext
	lea	.MNul(pc),a0
	bra.s	.ExtOut
.ELoop	tst.b	(a0)+
	bne.s	.ELoop
.Ext	dbra	d1,.ELoop
.ExtOut	swap	d2
	clr.w	d2
	or.l	d2,d0			D0= Message / Extension
	jmp	(a2)
.Nul	moveq	#0,d0			Pas d'erreur!
	jmp	(a2)
.MNul	dc.w	0			Message nul!

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	DEBUT DES SWAPS AMOS / CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	INSTRUCTION RUN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InRun0
; - - - - - - - - - - - - -
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRun0CLI
; - - - - - - - - - - - - -
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRun1
; - - - - - - - - - - - - -
	tst.l	Mon_Base(a5)
	bne.s	.Acc
	tst.b	Prg_Accessory(a5)
	bne.s	.Acc
; Verifie la presence du programme
	move.l	d3,a2
	move.w	(a2)+,d2
	move.l	Name1(a5),a0
	Rjsr	L_ChVerBuf2
	Rjsr	L_Dsk.PathIt
	move.l	#1005,d2		Verifie la presence du fichier!
	Rbsr	L_D_Open
	Rbeq	L_DiskError
	Rbsr	L_D_Close		Le ferme!
; Branche a la routine RUN suite!
	moveq	#-1,d0
	sub.l	a0,a0
	move.l	Prg_JError(a5),a1
	jmp	(a1)
.Acc 	moveq	#102,d0
	Rbra	L_Error

; - - - - - - - - - - - - -
	Lib_Cmp	InRun1CLI
; - - - - - - - - - - - - -
	Rbsr	L_RunName
; Short mem ou non?
; ~~~~~~~~~~~~~~~~
	move.l	Buffer(a5),a0
	lea	TBuffer-256-6(a0),a0
	cmp.l	#"CmdL",(a0)+
	bne	.Normal
	move.l	2(a0),d0
	cmp.l	#"-Mem",d0
	beq.s	.Short
	cmp.l	#"-Def",d0
	bne	.Normal

; SHORT Mem, on ferme tout!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Short	move.l	d0,-(sp)
	move.w	(a0),d0			Recopie la fin de la ligne de commande
	subq.w	#5,d0
	bpl.s	.Skyp
	moveq	#0,d0
.Skyp	move.w	d0,(a0)+
	beq.s	.Skop
	lea	5(a0),a1
	subq.w	#1,d0
.Loop	move.b	(a1)+,(a0)+
	dbra	d0,.Loop
.Skop	move.w	#-2,DefFlag(a5)
	Rbsr	L_DefRun1
	cmp.l	#"-Def",(sp)+
	beq.s	.Normal
	Rjsr	L_Bnk.EffAll
	Rbsr	L_CmpClearVar
	Rbsr	L_CmpLibrariesStop	Arret des extensions
	clr.l	Prg_JError(a5)
	clr.l	Sys_ErrorRoutines(a5)
	clr.l	Sys_DefaultRoutines(a5)
	lea	Sys_EndRoutines(a5),a1	Appelle les routines de fin
	SyCall	CallRoutines
	SyCall	MemFlush		Enleve les routines flush
	Rbsr	L_CmpLibClose		Ferme les librairies
	Rbsr	L_CmpEffVarBuf		Efface les variables
; Branche au header, short mem reload!!!
	move.l	BasSp(a5),sp
	move.l	(sp)+,a0
	jmp	8(a0)

; Assez de memoire, on reste tel quel
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Normal
; Plus de variable
	Rjsr	L_Bnk.EffAll
	Rbsr	L_CmpClearVar
	lea	Sys_DefaultRoutines(a5),a1
	SyCall	CallRoutines
	Rbsr	L_CmpLibrariesStop	Arret des extensions
	clr.l	Prg_JError(a5)
	clr.l	Sys_ErrorRoutines(a5)	Plus d'effacement
	lea	Sys_DefaultRoutines(a5),a1
	SyCall	CallRoutines
	lea	Sys_EndRoutines(a5),a1	Appelle les routines de fin
	SyCall	CallRoutines
	SyCall	MemFlush		Enleve les routines flush
	Rbsr	L_CmpLibClose		Ferme les librairies
	Rbsr	L_CmpEffVarBuf		Efface les variables
; Branche au header, normalement
	move.l	BasSp(a5),sp
	move.l	(sp)+,a0
	jmp	4(a0)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	PRUN en AMOS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InPRun
; - - - - - - - - - - - - -
	tst.l	Mon_Base(a5)
	bne	.Acc
	move.l	d3,a2
	move.w	(a2)+,d2
	move.l	Name1(a5),a0
	Rjsr	L_ChVerBuf2
; Sauve le programme courant
	movem.l	a3-a6/d6/d7,-(sp)
	move.l	BasSp(a5),-(sp)
; Le programme est-il deja charge?
	JJsr	L_Prg_AccAdr
	beq.s	.Loadit
	move.l	a0,a6
	JJsr	L_Prg_DejaRunned
	beq.s	.Runit
; Il faut charger: verifie la presence du programme
.Loadit	Rjsr	L_Dsk.PathIt
	move.l	#1005,d2		Verifie la presence du fichier!
	Rbsr	L_D_Open
	Rbeq	L_DiskError
	Rbsr	L_D_Close		Le ferme!
; Ouvre une nouvelle structure
	moveq	#0,d0			Pas de buffer
	JJsr	L_Prg_NewStructure	Ouvre la structure
	Rbeq	L_OOfMem
	move.l	d0,a6
; Charge le programme
	moveq	#-1,d0			Toujours adapter
	JJsr	L_Prg_Load
	tst.w	d0
	bne	.LErr
	move.l	a6,-(sp)		Remet les banques
	move.l	Prg_Runned(a5),a6	du premier programme
	JJsr	L_Prg_SetBanks
	move.l	(sp)+,a6
; Programme charge: on le demarre!
.Runit	moveq	#-1,d0			Semi init graphique
	lea	PRun_Errors(pc),a1	Retour en cas d'erreur
	sub.l	a2,a2			Pas de message
	move.l	sp,BasSp(a5)		Bas de la pile
	JJsr	L_Prg_RunIt
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
	JJsr	L_Prg_DelStructure
.Edited	move.l	Prg_Runned(a5),a6
	JJsr	L_Prg_SetBanks
	Rjsr	L_Bnk.Change
	move.l	(sp)+,d0
	move.l	Ed_RunMessages(a5),a0
	Rjsr	L_GetMessage
	move.l	(sp)+,BasSp(a5)
	movem.l	(sp)+,a3-a6/d6/d7
	move.l	sp,BasSp(a5)
	Rbra	L_ZapReturn
.Acc 	moveq	#102,d0
	Rbra	L_Error
;	Retour d'erreur lors de PRUN
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRun_Errors
	move.l	BasSp(a5),sp
	move.l	(sp)+,BasSp(a5)
	movem.l	(sp)+,a3-a6/d6/d7	Restore le programme
	movem.l	d6/d7,ErrorSave(a5)	Au cas zou
	movem.l	a0-a1/d0-d1,-(sp)
	JJsr	L_Open_MathLibraries	Rouvre les libraries
	movem.l	(sp)+,a0-a1/d0-d1
	cmp.w	#10,d0
	beq.s	.Nul
	cmp.w	#1000,d0
	blt.s	.Null
.Nul	moveq	#0,d0
.Null	move.l	ChVide(a5),a0
	Rbra	L_ZapReturn

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	INSTRUCTION PRUN sous CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InPRunCLI
; - - - - - - - - - - - - -
L_DSave	equ	DataLong-DosBase+8*4
	Rbsr	L_RunName
; Sauve les donnees du programme courant
	move.l	#L_DSave,d0		Reserve une zone de sauvegarde
	SyCall	MemFast
	Rbeq	L_OOfMem
	move.l	a0,Prg_Run(a5)
	movem.l	a3-a6/d6/d7,(a0)	Sauve les registres
	lea	6*4(a0),a0
	lea	DosBase(a5),a1
	move.l	#(DataLong-DosBase)/2-1,d0
.Copy	move.w	(a1)+,(a0)+		Recopie les donnees
	dbra	d0,.Copy
	move.l	DosBase(a5),-(sp)	Sauve DOSBASE
; Effacement selectif
	SyCall	MemFlush		Enleve les routines flush
	clr.l	DFloatBase(a5)
	clr.l	DMathBase(a5)
	clr.l	FloatBase(a5)
	clr.l	MathBase(a5)
	clr.l	Sys_Banks(a5)		Les messages systeme
	clr.l	Ed_RunMessages(a5)
	clr.l	Cmp_CurBanks(a5)	Dialogues / banks programme
	clr.l	Cmp_CurDialogs(a5)
	clr.l	Sys_EndRoutines(a5)	Routines flush
	clr.l	Sys_ClearRoutines(a5)
	clr.l	Sys_ErrorRoutines(a5)
	clr.l	Sys_DefaultRoutines(a5)
	clr.l	EveLabel(a5)		Every!
	clr.l	MnBase(a5)		Menus
	clr.w	OMnNb(a5)
	clr.l	OMnBase(a5)
	clr.l	Patch_Errors(a5)	Plus de patchs
	clr.l	Patch_Menage(a5)
	clr.l	Patch_ScFront(a5)
	clr.l	Patch_ScCopy(a5)
	bclr	#1,ActuMask+1(a5)
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
	lea	.NextQuit(pc),a0	Effacement du programme suivant!
	move.l	a0,Prg_JError(a5)
; Charge le programme
	move.l	Name1(a5),d1
	move.l	(sp),a6
	jsr	_LVOLoadSeg(a6)
	move.l	d0,Prg_Runned(a5)	Les segments
	beq.s	.Err
	lsl.l	#2,d0
	move.l	d0,a0
	addq.l	#4,a0
	move.l	2(a0),d2		Les flags
	move.l	2+6(a0),d3
	bset	#FHead_PRun,d2		C'est un PRUN!
	bset	#FHead_Run,d2		C'est egalement un RUN!
	bset	#FPrg_DefRunAcc+16,d2	DEFRUNACC pour le programme
	jsr	6+6(a0)			On y va!
; Retour du programme suivant!
.Back	move.l	(sp),a6
	move.l	d0,(sp)
	move.l	Prg_Runned(a5),d1	Libere le programme
	beq.s	.Nolib
	jsr	_LVOUnLoadSeg(a6)
.Nolib	move.l	Prg_Run(a5),a0		Recopie les donnees
	move.l	a0,a1
	movem.l	(a0)+,a3-a6/d6/d7
	lea	DosBase(a5),a2
	move.l	#(DataLong-DosBase)/2-1,d0
.Copy2	move.w	(a0)+,(a2)+		Recopie les donnees
	dbra	d0,.Copy2
	move.l	#L_DSave,d0		Libere le buffer
	SyCall	MemFree
; Remet les banques
	Rjsr	L_Bnk.Change
; Met le PARAM
	move.l	(sp)+,ParamE(a5)
	rts
; Out of memory
.Err	moveq	#24,d0
	bra.s	.Back
; Effacement du programme suivant
.NextQuit
	movem.l	a0/d0,-(sp)		Sauve les erreurs
	lea	Sys_DefaultRoutines(a5),a1
	SyCall	CallRoutines
	lea	Sys_EndRoutines(a5),a1	Appelle les routines de fin
	SyCall	CallRoutines
	SyCall	MemFlush		Enleve les routines flush
	Rjsr	L_Bnk.EffAll
	Rbsr	L_CmpClearVar
	Rbsr	L_CmpLibrariesStop
	Rbsr	L_CmpLibClose
	Rbsr	L_CmpEffVarBuf
; Retourne a l'appellant (le header du deuxieme)
	movem.l	(sp)+,a0/d0
	move.l	BasSp(a5),sp
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		ASK EDITOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InAskEditor1
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	move.l	d3,-(a3)
	Rbra	L_InAskEditor3
; - - - - - - - - - - - - -
	Lib_Cmp	InAskEditor1CLI
; - - - - - - - - - - - - -
	Rbra	L_FonCall

; - - - - - - - - - - - - -
	Lib_Cmp InAskEditor2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	Rbra	L_InAskEditor3
; - - - - - - - - - - - - -
	Lib_Cmp	InAskEditor2CLI
; - - - - - - - - - - - - -
	Rbra	L_FonCall

; - - - - - - - - - - - - -
	Lib_Cmp InAskEditor3
; - - - - - - - - - - - - -
	Rbsr	L_Ed_Par
	tst.l	Edit_Segment(a5)
	Rbeq	L_FonCall
	JJsr	L_Ed_ZapFonction
	move.l	d0,ParamE(a5)
	move.l	ChVide(a5),ParamC(a5)
	tst.w	d2
	beq.s	.Skip
	Rjsr	L_A0ToChaine
	move.l	a0,ParamC(a5)
.Skip	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InAskEditor3CLI
; - - - - - - - - - - - - -
	Rbra	L_FonCall

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		ZAPPEUSE D'EDITEUR!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InCallEditor1
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	move.l	d3,-(a3)
	Rbra	L_InCallEditor3
; - - - - - - - - - - - - -
	Lib_Cmp	InCallEditor1CLI
; - - - - - - - - - - - - -
	Rbra	L_FonCall

; - - - - - - - - - - - - -
	Lib_Cmp InCallEditor2
; - - - - - - - - - - - - -
	move.l	d3,-(a3)
	move.l	#EntNul,d3
	Rbra	L_InCallEditor3
; - - - - - - - - - - - - -
	Lib_Cmp	InCallEditor2CLI
; - - - - - - - - - - - - -
	Rbra	L_FonCall

; - - - - - - - - - - - - -
	Lib_Cmp InCallEditor3
; - - - - - - - - - - - - -
	Rbsr	L_Ed_Par		Recupere les parametres
	tst.l	Edit_Segment(a5)	Editeur present?
	Rbeq	L_FonCall
	move.l	BasSp(a5),-(sp)		Sauve le bas de la pile
	movem.l	a3-a6/d6/d7,-(sp)	Pousse tout
	move.l	sp,BasSp(a5)
	subq.l	#4,BasSp(a5)		Change le bas de la pile
	JJsr	L_Ed_ZapIn		Appel de l'editeur, avec ADTOKENS
	movem.l	(sp)+,a3-a6/d6/d7	Recupere tout
	move.l	(sp)+,BasSp(a5)		Remet BasSp!
	Rbra	L_ZapReturn
; - - - - - - - - - - - - -
	Lib_Cmp	InCallEditor3CLI
; - - - - - - - - - - - - -
	Rbra	L_FonCall

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MET LES BANQUES DU PROGRAMME PRECEDENT, SI DEFINI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp Bnk.PrevProgram
; - - - - - - - - - - - - -		Si programme AMOS
	move.l	a4,-(sp)
	move.l	AdTokens(a5),a4
	Ijsr	L_Bnk.PrevProgram
	move.l	(sp)+,a4
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	Bnk.PrevProgramCLI
; - - - - - - - - - - - - -		Si Programme CLI
	moveq	#0,d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MET LES BANQUES DU PROGRAMME COURANT, SI DEFINI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Bnk.CurProgram
; - - - - - - - - - - - - -		Si programme AMOS
	move.l	a4,-(sp)
	move.l	AdTokens(a5),a4
	Ijsr	L_Bnk.CurProgram
	move.l	(sp)+,a4
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	Bnk.CurProgramCLI
; - - - - - - - - - - - - -		Si programme CLI
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	=Prg Under
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FnPrgUnder
; - - - - - - - - - - - - -		Si sous AMOS
	move.l	a4,-(sp)
	move.l	AdTokens(a5),a4
	Ijsr	L_FnPrgUnder
	move.l	(sp)+,a4
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FnPrgUnderCLI
; - - - - - - - - - - - - -		Si programme CLI
	tst.l	Prg_Runned(a5)
	sne	d3
	ext.w	d3
	ext.l	d3
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	CLOSE EDITOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InCloseEditor
; - - - - - - - - - - - - -
	move.l	a4,-(sp)
	move.l	AdTokens(a5),a4
	Ijsr	L_InCloseEditor
	move.l	(sp)+,a4
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InCloseEditorCLI
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	KILL EDITOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InKillEditor
; - - - - - - - - - - - - -
	move.l	a4,-(sp)
	move.l	AdTokens(a5),a4
	Ijsr	L_InKillEditor
	move.l	(sp)+,a4
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InKillEditorCLI
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MONITOR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InMonitor
; - - - - - - - - - - - - -
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InMonitorCLI
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	FIN DES ROUTINES AMOS / CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	VERIFICATION DU FICHIER RUN / PRUN CLI
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	RunName
; - - - - - - - - - - - - -
	move.l	d3,a2
	Rbsr	L_NomDisc
	move.l	Name1(a5),a0
.Run0	tst.b	(a0)+
	bne.s	.Run0
	subq.l	#1,a0
	lea	Suffix(pc),a1
.Run1	move.b	-(a0),d0
	cmp.b	#"a",d0
	bcs.s	.Run1a
	cmp.b	#"z",d0
	bhi.s	.Run1a
	sub.b	#32,d0
.Run1a	move.b	(a1)+,d1
	beq.s	.Run2
	cmp.b	d0,d1
	bne.s	.Run3
	beq.s	.Run1
.Run2	clr.b	1(a0)
; Ouvre le fichier (si present)
.Run3	move.l	#1005,d2
	Rbsr	L_D_Open
	Rbeq	L_DiskError
; Charge l'entete
	move.l	Name2(a5),d2
	moveq	#5*4,d3
	Rbsr	L_D_Read
	Rbne	L_DiskError
; Un programme?
	move.l	d2,a2
	add.l	d3,d2
	cmp.l	#$3F3,(a2)
	Rbne	L_DiskError
; Ok, on peut fermer
	Rbsr	L_D_Close
	rts
.NoF	moveq	#81,d0			Erreur normale!
	Rbra	L_Error
Suffix	dc.b	"SOMA.",0
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Recupere les parametres
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Ed_Par
; - - - - - - - - - - - - -
	move.l	Name1(a5),a0
	move.l	Name2(a5),a1
	clr.w	(a1)
	move.l	d3,d0
	beq.s	.Skip
	move.l	d0,a2
	move.w	(a2)+,d2
	move.w	d2,(a1)
	Rjsr	L_ChVerBuf2
.Skip	move.l	(a3)+,d1
	move.l	(a3)+,d0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Retour de zappeuse
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	ZapReturn
; - - - - - - - - - - - - -
	move.l	ChVide(a5),ParamC(a5)
	ext.l	d0
	move.l	d0,ParamE(a5)
	beq.s	.Skip
	Rjsr	L_A0ToChaine
	move.l	a0,ParamC(a5)
.Skip	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	=Prg State
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnPrgState
; - - - - - - - - - - - - -
	move.w	T_AMOState(a5),d3
	ext.l	d3
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TROUVE LE DEBUT DE L'INSTRUCTION ACTUELLE >>> A1 / A2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GetInstruction
; - - - - - - - - - - - - -
	move.l	Cmp_LowPile(a5),a1
	move.l	-4(a1),a1		Adresse de retour
	subq.l	#2,a1			Au milieu du jsr
	Rbra	L_GetInstruction2
; - - - - - - - - - - - - -
	Lib_Cmp	GetInstruction2
; - - - - - - - - - - - - -
	movem.l	a0/d0-d3,-(sp)
	move.l	Cmp_ListInst(a5),a0
	move.l	(a0)+,d3
	move.w	(a0)+,d1		Nombre d'instructions
	sub.l	d3,a1			En relatif
	lsr.w	#1,d1
	move.w	d1,d2
; Boucle de recherche
.Loop	move.w	d1,d0
	lsl.w	#2,d0
	cmp.l	-4(a0,d0.w),a1
	bcs.s	.Prev
	cmp.l	0(a0,d0.w),a1
	bcs.s	.Found
	lsr.w	#1,d2
	beq.s	.Pas
	add.w	d2,d1
	bra.s	.Loop
.Prev	lsr.w	#1,d2
	beq.s	.Pas
	subx.w	d2,d1
	bra.s	.Loop
; Pas trouve, cherche au dessus
.Pas	lea	0(a0,d0.w),a2
.Find	cmp.l	(a2)+,a1
	bcc.s	.Find
	subq.l	#8,a2
	bra.s	.Return
.Found	lea	-4(a0,d0.w),a2
.Return	move.l	(a2)+,a1
	move.l	(a2),a2
	add.l	d3,a1
	add.l	d3,a2
	movem.l	(sp)+,a0/d0-d3
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					SYSTEM
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InSystem
; - - - - - - - - - - - - -
	move.w	#1002,d0
	Rbra	L_GoError
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EDIT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InEdit
; - - - - - - - - - - - - -
	move.w	#1000,d0
	Rbra	L_GoError
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					DIRECT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InDirect
; - - - - - - - - - - - - -
	move.w	#1001,d0
	Rbra	L_GoError

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					BREAK ON / OFF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InBreakOn
; - - - - - - - - - - - - -
	bset	#BitControl,ActuMask(a5)
	clr.l	OnBreak(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp InBreakOff
; - - - - - - - - - - - - -
	bclr	#BitControl,ActuMask(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ON BREAK PROC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InOnBreak
; - - - - - - - - - - - - -
	move.l	a0,OnBreak(a5)
	bclr	#BitControl,ActuMask(a5)
	Rlea	L_OnBreakGo,0		La routine de branchement
	move.l	a0,GoTest_OnBreak(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ON ERROR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InOnError
; - - - - - - - - - - - - -
	tst.w	ErrorOn(a5)
	Rbne	L_NoResume
	clr.l	OnErrLine(a5)
	clr.l	ErrorChr(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InOnErrorGoto
; - - - - - - - - - - - - -
	tst.w	ErrorOn(a5)
	Rbne	L_NoResume
	move.l	a0,OnErrLine(a5)
	clr.l	ErrorChr(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InOnErrorProc
; - - - - - - - - - - - - -
	tst.w	ErrorOn(a5)
	Rbne	L_NoResume
	move.l	a0,OnErrLine(a5)
	clr.l	ErrorChr(a5)
	bset	#7,ErrorChr(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RESUME LABEL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InResumeLabel
; - - - - - - - - - - - - -
	tst.w	ErrorOn(a5)
	Rbeq	L_NoErr
	Rbsr	L_PopP
	clr.w	ErrorOn(a5)
	move.l	ErrorChr(a5),d0
	bclr	#31,d0
	Rbeq	L_NoOnErr
	tst.l	d0
	Rbeq	L_ResLNo
	move.l	d0,a0
	jmp	(a0)
; - - - - - - - - - - - - -
	Lib_Cmp	InResumeLabel1
; - - - - - - - - - - - - -
	tst.l	OnErrLine(a5)
	Rbeq	L_NoOnErr
	tst.w	ErrorChr(a5)
	Rbpl	L_NoOnErr
	move.l	a0,d0
	bset	#31,d0
	move.l	d0,ErrorChr(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RESUME [label]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InResume
; - - - - - - - - - - - - -
	Rbsr	L_Test_PaSaut
	tst.w	ErrorOn(a5)
	Rbeq	L_NoErr
	move.l	ErrorChr(a5),d0
	bmi.s	L985a
	move.l	d0,a0
	clr.w	ErrorOn(a5)
	jmp	(a0)
L985a	Rbsr	L_PopP
	clr.w	ErrorOn(a5)
	jmp	(a0)
; - - - - - - - - - - - - -
	Lib_Cmp	InResume1
; - - - - - - - - - - - - -
	move.l	a0,-(sp)
	Rbsr	L_Test_PaSaut
	move.l	(sp)+,a0
	tst.w	ErrorOn(a5)
	Rbeq	L_NoErr
	clr.w	ErrorOn(a5)
	tst.w	ErrorChr(a5)
	Rbmi	L_ResPLab
	jmp	(a0)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RESUME NEXT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InResumeNext
; - - - - - - - - - - - - -
	Rbsr	L_Test_PaSaut
	tst.w	ErrorOn(a5)
	Rbeq	L_NoErr
	move.l	ErrorChr(a5),d0		Une procedure?
	bpl.s	.Skip
	Rbsr	L_PopP
	subq.l	#4,sp			Pour le depilage!
	move.l	a0,d0
.Skip	move.l	d0,a1			Cherche l'instruction suivante
	Rbsr	L_GetInstruction2
	clr.w	ErrorOn(a5)
	addq.l	#4,sp			Depile la fonction
	jmp	(a2)			Branche

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	TRAP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InTrap
; - - - - - - - - - - - - -
	move.l	(sp),TrapAdr(a5)	L'adresse de retour!
	clr.w	TrapErr(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	=TRAPERR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FnErrTrap
; - - - - - - - - - - - - -
	moveq	#0,d3
	move.w	TrapErr(a5),d3
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	EVERY GOSUB
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InEveryGosub
; - - - - - - - - - - - - -
	clr.w	EveType(a5)
	Rbra	L_InEvery
; - - - - - - - - - - - - -
	Lib_Cmp	InEveryProc
; - - - - - - - - - - - - -
	move.w	#-1,EveType(a5)
	Rbra	L_InEvery
; - - - - - - - - - - - - -
	Lib_Cmp	InEvery
; - - - - - - - - - - - - -
	bclr	#BitEvery,ActuMask(a5)
	move.l	a0,EveLabel(a5)
	Rlea	L_EveJump,0			Routine de branchement
	move.l	a0,GoTest_Every(a5)
	move.l	(a3)+,d0
	Rbeq	L_FonCall
	cmp.l	#32767,d0
	Rbcc	L_FonCall
	move.w	d0,EveCharge(a5)
	move.w	d0,T_EveCpt(a5)
	bset	#BitEvery,ActuMask(a5)
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EVERY OFF
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InEveryOff
; - - - - - - - - - - - - -
	bclr	#BitEvery,ActuMask(a5)
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					EVERY ON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InEveryOn
; - - - - - - - - - - - - -
	bset	#BitEvery,ActuMask(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	NEXT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InNext
; - - - - - - - - - - - - -
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.l	(a2),a2
	add.l	d4,(a2)
	tst.l	d4
	bmi.s	L51a
	cmp.l	(a2),d5
	blt.s	L51b
	addq.l	#4,sp
	jmp	(a1)
L51a	cmp.l	(a2),d5
	bgt.s	L51b
	addq.l	#4,sp
	jmp	(a1)
L51b	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InNextF
; - - - - - - - - - - - - -
	move.l	a6,-(sp)
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.l	(a2),a2
	move.l	FloatBase(a5),a6
	move.l	d4,d1
	jsr	SPTst(a6)
	move.l	d0,d6
	move.l	d4,d0
	move.l 	(a2),d1
	jsr	SPAdd(a6)
	move.l	d0,(a2)
	move.l	d5,d1
	jsr	SPCmp(a6)
	move.l	(sp)+,a6
	blt.s	NxtF1
	tst.l	d6
	bpl.s	NxtS
	bmi.s	NxtR
NxtF1	tst.l	d6
	bpl.s	NxtR
	bmi.s	NxtS
NxtR	addq.l	#4,sp
	jmp	(a1)
NxtS	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InReturn
; - - - - - - - - - - - - -
	cmp.l	Cmp_LowPileP(a5),sp
	beq.s	.err
	addq.l	#4,Cmp_LowPile(a5)
	rts
.err	moveq	#1,d0
	Rbra	L_Error


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	POP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InPop
; - - - - - - - - - - - - -
	move.l	(sp)+,a0
	cmp.l	Cmp_LowPileP(a5),sp
	beq.s	.err
	addq.l	#4,sp
	move.l	sp,Cmp_LowPile(a5)
	jmp	(a0)
.err	moveq	#2,d0
	Rbra	L_GoError

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Procedure
;	D0=	ErrorOn
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DProc1
; - - - - - - - - - - - - -
	move.l	(sp)+,a2
; Empile les params
; Adresse de retour -(sp)		RTS
	move.l	a6,-(sp)		0
	move.l	Cmp_AdLabels(a5),-(sp)	1
;	move.l	VarLoc(a5),-(sp)	2= A6!
	move.l	Cmp_AForNext(a5),-(sp)	3
	move.l	Cmp_ListInst(a5),-(sp)	!
	move.l	TabBas(a5),-(sp)	4
	move.l	OnErrLine(a5),-(sp)	5
	move.l	ErrorChr(a5),-(sp)	6
	move.w	ErrorOn(a5),-(sp)	7
	move.l	PData(a5),-(sp)		8
	move.l	AData(a5),-(sp)		9
	move.l	Cmp_LowPile(a5),-(sp)	10
	move.l	Cmp_LowPileP(a5),-(sp)	11
	move.l	sp,Cmp_LowPileP(a5)
	move.l	sp,Cmp_LowPile(a5)
	clr.l	OnErrLine(a5)
	move.w	d0,ErrorOn(a5)
	jmp	(a2)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Debut procedure 2: affect les variables / Float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DProc2F
; - - - - - - - - - - - - -
	move.w	d3,d2
	beq.s	.Nopar
	lsl.w	#2,d2
	lea	0(a3,d2.w),a2		Pointeur sur les parametres
	subq.w	#1,d3			Compteur
.Loop	move.l	(a2)+,d0
	lsr.l	#1,d4			Flags variables
	bcs.s	.Flt
; On veut un entier
	lsr.l	#1,d5			Flags parametres
	bcc.s	.Loke
	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFix(a6)
	move.l	(sp)+,a6
	bra.s	.Loke
; On veut un float
.Flt	lsr.l	#1,d5
	bcs.s	.Loke
	move.l	a6,-(sp)
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFlt(a6)
	move.l	(sp)+,a6
; Affecte la variable
.Loke	move.l	(a3)+,a0
	move.l	d0,(a0)
	dbra	d3,.Loop
	move.l	a2,a3
.Nopar	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Debut procedure 2: affect les variables / Double
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DProc2D
; - - - - - - - - - - - - -
	move.w	d3,d2
	beq.s	.Nopar
	lsl.w	#2,d2
	lea	0(a3,d2.w),a2		Pointeur sur les parametres
	subq.w	#1,d3			Compteur
.Loop	lsr.l	#1,d4
	bcs.s	.Flt
; On veut un entier
	lsr.l	#1,d5
	bcc.s	.Loke1
	movem.l	(a2)+,d0-d1
	move.l	a6,-(sp)
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFix(a6)
	move.l	(sp)+,a6
	move.l	(a3)+,a0
	move.l	d0,(a0)
	bra.s	.Next
.Loke1	move.l	(a3)+,a0
	move.l	(a2)+,(a0)
	bra.s	.Next
; On veut un double
.Flt	lsr.l	#1,d5
	bcs.s	.Loke2
	move.l	(a2)+,d0
	move.l	a6,-(sp)
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFlt(a6)
	move.l	(sp)+,a6
	move.l	(a3)+,a0
	movem.l	d0-d1,(a0)
	bra.s	.Next
.Loke2	move.l	(a3)+,a0
	movem.l	(a2)+,d0-d1
	movem.l	d0-d1,(a0)
.Next	dbra	d3,.Loop
	move.l	a2,a3
.Nopar	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FIN PROCEDURE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FProc
; - - - - - - - - - - - - -
	tst.w	ErrorOn(a5)
	Rbne	L_EProErr
	move.l	Cmp_LowPileP(a5),sp
	move.l	(sp)+,Cmp_LowPileP(a5)	11
	move.l	(sp)+,Cmp_LowPile(a5)	10
	move.l	(sp)+,AData(a5)		9
	move.l	(sp)+,PData(a5)		8
	move.w	(sp)+,ErrorOn(a5)	7
	move.l	(sp)+,ErrorChr(a5)	6
	move.l	(sp)+,OnErrLine(a5)	5
	move.l	(sp)+,TabBas(a5)	4
	move.l	(sp)+,Cmp_ListInst(a5)	!
	move.l	(sp)+,Cmp_AForNext(a5)	3
;	move.l	(sp)+,VarLoc(a5)	2= A6!
	move.l	(sp)+,Cmp_AdLabels(a5)	1
	move.l	(sp)+,a6		0
	rts				RTS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ENTREE PROGRAMME : RESERVE / INIT L'ESPACE VARIABLES / FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrgInF
; - - - - - - - - - - - - -
	move.l	d0,Cmp_AdLabels(a5)
	move.l	a0,Cmp_ListInst(a5)
	move.l	(sp),(a0)
	move.l	a2,AData(a5)
	move.l	a2,PData(a5)
	move.l	TabBas(a5),a0
; Verifie la taille
	move.l	a6,-(a0)		Debut des prochaines vlocales
	move.w	#$FFFF,-(a0)
	moveq	#0,d0
	move.w	(a1)+,d1		Taille du buffer FOR-NEXT
	move.w	(a1)+,d0		Taille des VARLOC
	add.w	d1,d0
	sub.l	d0,a0
	lea	-8(a0),a2		Adresse minimale, avec securite
	cmp.l	HiChaine(a5),a2
	bls.s	.Outb
	move.l	a0,Cmp_AForNext(a5)	Buffer for/next
	move.l	a0,TabBas(a5)		Haut des tableaux
	lea	0(a0,d1.w),a6		A6= Varloc= Debut Variables locales
	moveq	#1,d6			Pour les erreurs
; Cree la table
	moveq	#0,d0
	move.b	(a1)+,d0		Une table?
	bpl.s	.Table
	rts
.Table	or.w	#$0400,d0
	move.l	ChVide(a5),d1
	move.l	a6,a0
.Loop	move.w	d0,(a0)+		Met le flag
	cmp.b	#2,d0
	bne.s	.Ent
	move.l	d1,(a0)+		Chaine
	bra.s	.Next
.Ent	clr.l	(a0)+			Entier / Float / Tableau
.Next	move.b	(a1)+,d0
	bpl.s	.Loop
	rts
; Erreur, pas assez de place dans le buffer!
.Outb	move.l	d0,d3			Demande TROP
	add.w	#32,d3
	Rbsr	L_PopP
	move.l	a0,-(sp)		Adresse d'appel de la procedure
 	Rbra	L_Demande		Pour forcer le menage

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ENTREE PROGRAMME : RESERVE / INIT L'ESPACE VARIABLES / DOUBLE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrgInD
; - - - - - - - - - - - - -
	move.l	d0,Cmp_AdLabels(a5)
	move.l	a0,Cmp_ListInst(a5)
	move.l	(sp),(a0)
	move.l	a2,AData(a5)
	move.l	a2,PData(a5)
	move.l	TabBas(a5),a0
; Verifie la taille
	move.l	a6,-(a0)		Debut des prochaines vlocales
	move.w	#$FFFF,-(a0)
	moveq	#0,d0
	move.w	(a1)+,d1		Taille du buffer FOR-NEXT
	move.w	(a1)+,d0		Taille des VARLOC
	add.w	d1,d0
	sub.l	d0,a0
	lea	-8(a0),a2		Adresse minimale, avec securite
	cmp.l	HiChaine(a5),a2
	bls.s	.Outb
	move.l	a0,Cmp_AForNext(a5)	Buffer for/next
	move.l	a0,TabBas(a5)		Haut des tableaux
	lea	0(a0,d1.w),a6		A6= Varloc= Debut Variables locales
	moveq	#1,d6			Pour les erreurs
; Cree la table
	moveq	#0,d0
	move.b	(a1)+,d0		Une table?
	bpl.s	.Table
	rts
.Table	or.w	#$0400,d0
	move.l	ChVide(a5),d1
	move.l	a6,a0
.Loop	cmp.b	#1,d0
	beq.s	.Dbl
	cmp.b	#2,d0
	bne.s	.Ent
	move.w	d0,(a0)+
	move.l	d1,(a0)+		Chaine
	bra.s	.Next
.Dbl	move.w	#$0801,(a0)+		Flag Double
	clr.l	(a0)+			Double
	clr.l	(a0)+
	bra.s	.Next
.Ent	move.w	d0,(a0)+		Entier
	clr.l	(a0)+
.Next	move.b	(a1)+,d0
	beq.s	.Ent
	bpl.s	.Loop
	rts
; Erreur, pas assez de place dans le buffer!
.Outb	move.l	d0,d3			Demande TROP
	add.w	#32,d3
	Rbsr	L_PopP
	move.l	a0,-(sp)		Adresse d'appel de la procedure
 	Rbra	L_Demande		Pour forcer le menage

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ROUTINE POP PROC
;	A0-->	Adresse de retour
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PopP
; - - - - - - - - - - - - -
	move.l	(sp)+,a1
	move.l	Cmp_LowPileP(a5),sp
	move.l	(sp)+,Cmp_LowPileP(a5)	11
	move.l	(sp)+,Cmp_LowPile(a5)	10
	move.l	(sp)+,AData(a5)		9
	move.l	(sp)+,PData(a5)		8
	move.w	(sp)+,ErrorOn(a5)	7
	move.l	(sp)+,ErrorChr(a5)	6
	move.l	(sp)+,OnErrLine(a5)	5
	move.l	(sp)+,TabBas(a5)	4
	move.l	(sp)+,Cmp_ListInst(a5)	!
	move.l	(sp)+,Cmp_AForNext(a5)	3
;	move.l	(sp)+,VarLoc(a5)	2= A6
	move.l	(sp)+,Cmp_AdLabels(a5)	1
	move.l	(sp)+,a6		0
	move.l	(sp)+,a0		RTS
	jmp	(a1)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	GET LABEL expression
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GetLabelE
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	BufLabel(a5),a0
	move.l	a0,a2
	Rjsr	L_LongToDec
	move.l	a0,d2
	sub.l	a2,d2
	Rbra	L_GetLabel

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	GET LABEL alphanumerique
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GetLabelA
; - - - - - - - - - - - - -
	move.l	d3,a1
	move.w	(a1)+,d2
	Rbeq	L_FonCall
	cmp.w	#32,d2
	Rbcc	L_FonCall
	move.w	d2,d1
	subq.w	#1,d1
	move.l	BufLabel(a5),a0
	move.l	a0,a2
L58a	move.b	(a1)+,d0
	cmp.b	#"A",d0
	bcs.s	L58b
	cmp.b	#"Z",d0
	bhi.s	L58b
	add.b	#32,d0
L58b	move.b	d0,(a0)+
	dbra	d1,L58a
	Rbra	L_GetLabel

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	GET LABEL
;	D5=	Numero de procedure
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GetLabel
; - - - - - - - - - - - - -
	btst	#0,d2
	beq.s	L59a
	clr.b	(a0)+
	addq.w	#1,d2
* Trouve le label
L59a	move.w	d5,(a0)+
	move.w	d2,d3
	lsr.w	#1,d3
	addq.w	#2,d2
	move.l	Cmp_AdLabels(a5),a1
	move.l	a2,d4
L59b	move.w	(a1),d1
	Rbeq	L_FonCall
	cmp.w	d2,d1
	bne.s	L59n
	move.l	d4,a2
	lea	6(a1),a0
	move.w	d3,d0
L59c	cmp.w	(a0)+,(a2)+
	bne.s	L59n
	dbra	d0,L59c
* Trouve!
	move.l	2(a1),a0
	rts
* Label suivant
L59n	lea	6(a1,d1.w),a1
	bra.s	L59b


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		DIM
;		A0=	Adresse variable
;		D0=	Nombre params
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InDim
; - - - - - - - - - - - - -
	tst.l	(a0)			Already dimensionned
	bne	EAlrDim
; Recupere et compte les params
	moveq	#0,d5
	moveq	#2,d4			Taille des variables
	move.b	-1(a0),d5		Le flag
	and.w	#$000F,d5
	cmp.b	#1,d5			Float?
	bne.s	.Skip
	tst.b	MathFlags(a5)		Double?
	bpl.s	.Skip
	moveq	#3,d4			Variables sur 8 octets!
.Skip	moveq	#1,d3
	move.w	d0,d2
	move.l	Buffer(a5),a2
	move.b	d0,(a2)+		Nombre de dimensions
	move.b	d4,(a2)+		Taille des variables
Dim1:	move.l	(a3)+,d1		Fabrique l'entete
	cmp.l	#$FFFF,d1
	Rbcc	L_FonCall
	move.w	d1,(a2)+
	move.w	d3,(a2)+
	addq.w	#1,d1
	mulu	d1,d3
	cmp.l	#$10000,d3
	Rbcc	L_FonCall
	subq.w	#1,d0
	bne.s	Dim1
	lsl.l	d4,d3			Taille du tableau
	move.l	d3,d4
	Rbeq	L_FonCall
	lsr.l	#2,d4			Nombre de mots long a nettoyer
	add.l	a2,d3
	sub.l	Buffer(a5),d3		Plus taille du header
	move.l	TabBas(a5),a2		Descend le bas tableaux
	sub.l	d3,a2
	cmp.l	HiChaine(a5),a2
	bcc.s	DimM1
	movem.l	a0-a1/d0-d1,-(sp)
	Rbsr	L_Menage
	movem.l	(sp)+,a0-a1/d0-d1
	cmp.l	HiChaine(a5),a2
	Rbcs	L_OOfBuf
DimM1	move.l	a2,(a0)			Stocke l'adresse du tableau
	move.l	a2,TabBas(a5)
	move.l	Buffer(a5),a0		Copie l'entete
	move.w	(a0)+,(a2)+
DimM2	move.l	(a0)+,(a2)+
	subq.w	#1,d2
	bne.s	DimM2
* Nettoie le tableau
	moveq	#0,d0
	cmp.w	#2,d5
	bne.s	Dim5
	move.l	ChVide(a5),d0
Dim5:	move.l	d0,(a2)+
	subq.l	#1,d4
	bne.s	Dim5
	rts
EAlrDim	moveq	#28,d0
	Rbra	L_GoError

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Trouve un element de tableau
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GetTablo
; - - - - - - - - - - - - -
	move.l	(a0),d0		Base du tableau
	Rbeq	L_NonDim
	move.l	d0,a0
	move.b	(a0)+,d3	Nombre de dims
	move.b	(a0)+,d4	Taille des variables
	moveq	#0,d0
	moveq	#0,d2
GetT1	move.w	(a0)+,d0
	move.l	(a3)+,d1
	cmp.l	d0,d1
	Rbhi	L_FonCall
	mulu	(a0)+,d1
	add.l	d1,d2
	subq.b	#1,d3
	bne.s	GetT1
	lsl.l	d4,d2
	add.l	d2,a0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;					=ARRAY$(a$(0))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnArray
; - - - - - - - - - - - - -
	move.l	(a0),d3
	Rbeq	L_NonDim
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	=FN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FnFn
; - - - - - - - - - - - - -
	move.l	(a0),d1		Adresse de la routine
	beq	EFnNDef
	move.l	d1,a2
	move.w	d0,-(sp)	Nombre de parametres
	beq.s	L955e
L955a	jsr	(a2)		Appel du parametres
	cmp.w	(a3)+,d2	Compare avec le type demande
	beq.s	L955d
	move.l	a0,-(sp)
	tst.b	d2
	bne.s	L955b
	Rjsrt	L_FlToInt2
	bra.s	L955c
L955b	Rjsrt	L_IntToFl2
L955c	move.l	(sp)+,a0
L955d	cmp.b	#1,d2
	bne.s	.Ent
	tst.b	MathFlags(a5)	Double
	bpl.s	.Ent
	movem.l	(a3)+,d3/d4
	move.l	d3,(a0)+	Egalisation
	move.l	d4,(a0)
	bra.s	.Next
.Ent	move.l	(a3)+,(a0)
.Next	subq.w	#1,(sp)		Encore un parametre
	bne.s	L955a
L955e	addq.l	#2,sp
	jmp	(a2)		Branche a la routine
EFnNDef	moveq	#15,d0
	Rbra	L_GoError


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SWAP
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InSwap
; - - - - - - - - - - - - -
	move.l	(a3)+,a1		En entier/float/chaine
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InSwapD
; - - - - - - - - - - - - -
	move.l	(a3)+,a1
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	MAX / MIN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnMax
; - - - - - - - - - - - - - - - -
	cmp.l	(a3),d3
	bge.s	.Skip
	move.l	(a3),d3
.Skip	addq.l	#4,a3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FnMaxS
; - - - - - - - - - - - - -
	move.l	(a3),-(a3)
	Rbsr	L_Chaine_Compare
	ble.s	.Skip
	move.l	(a3),d3
.Skip	addq.l	#4,a3
	rts
; - - - - - - - - - - - - - - - -
	Lib_Cmp FnMin
; - - - - - - - - - - - - - - - -
	cmp.l	(a3),d3
	ble.s	.Skip
	move.l	(a3),d3
.Skip	addq.l	#4,a3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FnMinS
; - - - - - - - - - - - - -
	move.l	(a3),-(a3)
	Rbsr	L_Chaine_Compare
	ble.s	.Skip
	move.l	(a3),d3
.Skip	addq.l	#4,a3
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;						INC + DEC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InAdd4
; - - - - - - - - - - - - - - - -
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
	Lib_Cmp InSort
; - - - - - - - - - - - - - - - -
	Rbsr 	L_GTablo       	;va chercher les caracteristiques du tableau
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
	Rbsr	L_AdSort
	movem.l	a0/a1/d2,-(sp)
	movem.l	(a0),d0-d1
	movem.l	(a1),d3-d4
	Rbsr	L_CpBis
	movem.l	(sp)+,a0/a1/d2
  	bge.s	or8
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
	Lib_Cmp FnMatch
; - - - - - - - - - - - - - - - -
	Rbsr	L_GTablo
	cmp.b	#3,d7
	beq.s	.Dble
	move.l	(a3)+,d3
	bra.s	di3
.Dble	movem.l	(a3)+,d3/d4
; recherche!
di3:    moveq	#0,d5
        move.l 	d6,d1
        lsr.l	#1,d6
di4:    movem.l a1/d1-d7,-(sp)
        add.l 	d6,d5
	move.l	d5,d1
	move.l	a1,a0
	moveq	#0,d0
	Rbsr	L_AdSort
	movem.l	(a1),d0-d1
	Rbsr	L_CpBis
	movem.l	(sp)+,a1/d1-d7
        beq.s 	di11
        blt.s	di5
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
	Rbsr	L_AdSort
	movem.l	(a1),d0-d1
	Rbsr	L_CpBis
        movem.l (sp)+,a1/d1-d7
        beq.s 	di11
        blt.s 	di8
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
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Trouve les parametres tableau pour SORT et FIND
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	GTablo
; - - - - - - - - - - - - -
GTablo	Rjsr	L_SaveRegs
	move.l	(a0),d0
	Rbeq	L_NonDim
	move.l	d0,a0
	move.b	(a0)+,d0		Nombre de dims
	move.b	(a0)+,d7		Taille des variables
	moveq	#0,d1
	moveq	#1,d6
L957a	addq.l	#4,a3
	move.w	(a0)+,d1
	addq.w	#1,d1
	mulu	d1,d6
	addq.l	#2,a0
	subq.b	#1,d0
	bne.s	L957a
	move.l	a0,a1
	rts
* Trouve l'adresse D0/D1 >>> A0/A1
; - - - - - - - - - - - - -
	Lib_Cmp	AdSort
; - - - - - - - - - - - - -
	lsl.l	d7,d0
	add.l	d0,a0
	move.l	a0,a1
	lsl.l	d7,d1
	add.l	d1,a1
	rts
* Comparaison pour SORT/FIND
; - - - - - - - - - - - - -
	Lib_Cmp	CpBis
; - - - - - - - - - - - - -
	cmp.b	#1,d2
	beq.s	.Flt
	bcs.s	.Ent
	move.l	d0,-(a3)			Chaine
	Rbra 	L_Chaine_Compare
.Ent	cmp.l 	d0,d3				Entier
	rts
.Flt	cmp.b	#3,d7
	beq.s	.Dble
	move.l	d0,-(a3)
	Rjmp	L_Float_Compare
.Dble	movem.l	d0-d1,-(a3)
	Rjmp	L_Float_Compare

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	READ
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InRead
; - - - - - - - - - - - - -
	move.l	a0,-(sp)		Read ENTIERS
	move.l	PData(a5),a2
	jsr	(a2)
	Rbmi	L_OOfData
	cmp.l	#EntNul,d3
	beq.s	L975a
	subq.b	#1,d2
	bmi.s	L975b
	Rbne	L_TypeMis
	Rjsrt	L_FlToInt1
	bra.s	L975b
L975a	moveq	#0,d3
L975b	move.l	(sp)+,a0
	move.l	d3,(a0)
	move.l	a2,PData(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InReadF
; - - - - - - - - - - - - -
	move.l	a0,-(sp)		Pour les float
	move.l	PData(a5),a2
	jsr	(a2)
	Rbmi	L_OOfData
	cmp.l	#EntNul,d3
	beq.s	L976a
	subq.b	#1,d2
	beq.s	L976b
	Rbpl	L_TypeMis
	Rjsrt	L_IntToFl1
	bra.s	L976b
L976a	moveq	#0,d3
	moveq	#0,d4
L976b	move.l	(sp)+,a0
	move.l	d3,(a0)+
	tst.b	MathFlags(a5)
	bpl.s	.Skip
	move.l	d4,(a0)
.Skip	move.l	a2,PData(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InReadS
; - - - - - - - - - - - - -
	move.l	a0,-(sp)		Pour les chaines
	move.l	PData(a5),a2
	jsr	(a2)
	Rbmi	L_OOfData
	cmp.l	#EntNul,d3
	beq.s	L977a
	cmp.b	#2,d2
	beq.s	L977b
	Rbra	L_TypeMis
L977a	move.l	ChVide(a5),d3
L977b	move.l	(sp)+,a0
	move.l	d3,(a0)
	move.l	a2,PData(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	RESTORE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InRestore
; - - - - - - - - - - - - -
	move.l	AData(a5),PData(a5)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRestore1
; - - - - - - - - - - - - -
	lea	4(a0),a0
	cmp.w	#$4E71,(a0)		* (NOP)
	bne.s	.Err
	move.l	a0,PData(a5)
	rts
.Err	moveq	#41,d0			No data
	Rbra	L_GoError


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source:	Diskio.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FIELD
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InField
; - - - - - - - - - - - - -
	exg	d0,d3
	Rbsr	L_GetFile
	Rbeq	L_FilNO
; Reserve la memoire necessaire
	move.w	d3,d0
	mulu	#6,d0
	addq.l	#8,d0
	SyCall	MemFastClear
	Rbeq	L_OOfMem
	move.l	a0,FhF(a2)
	move.l	a0,a1
	move.w	d3,d0
	lsl.w	#3,d0
	add.w	d0,a3
	move.l	a3,-(sp)
	lea	8(a1),a0
	move.w	d3,(a1)
	subq.w	#1,d3
	moveq	#0,d2
Fld2	move.l	-(a3),d0
	beq	FldFonc
	add.l	d0,d2
	cmp.l	#String_Max,d2
	bcc	FldFonc
	move.w	d0,(a0)+
	move.l	-(a3),(a0)+
	dbra	d3,Fld2
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
; FonCall field!
FldFonc	Rjsr	L_Cloa1
	Rbra	L_FonCall

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;			LINE INPUT FICHIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InLineInputH
; - - - - - - - - - - - - -
	clr.w	-(sp)
	move.l	d3,d0
	Rbsr	L_GetFile
	Rbeq	L_FilNO
	move.l	a2,PrintFile(a5)
	moveq	#0,d3
	Rbra	L_Input

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;			INPUT FICHIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InInputH
; - - - - - - - - - - - - -
	move.w	#",",-(sp)
	move.l	d3,d0
	Rbsr	L_GetFile
	Rbeq	L_FilNO
	move.l	a2,PrintFile(a5)
	moveq	#0,d3
	Rbra	L_Input

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	INPUT CLAVIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InInput
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	Rbeq	L_ScNOp
	move.w	#",",-(sp)
	clr.l	PrintFile(a5)
	Rbra	L_Input
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	LINE INPUT CLAVIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InLineInput
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	Rbeq	L_ScNOp
	clr.w	-(sp)
	clr.l	PrintFile(a5)
	Rbra	L_Input

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	INPUT!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Input
; - - - - - - - - - - - - -
	move.l	d3,-(sp)		Chaine a imprimer
	move.w	d5,d0			Nombre de variables
	mulu	#6,d0
	add.w	d0,a3
	clr.l	DeFloat(a5)
IInp0	movem.l	a3/d5,-(sp)
	move.l	Buffer(a5),a0
	clr.b	(a0)
	tst.l	PrintFile(a5)
	bne.s	ReDInp
; Imprimer la chaine
	move.l 	8(sp),d0
	beq.s	L111a
	move.l	d0,a2
        move.w 	(a2)+,d2
        beq.s 	ReInp
	move.b	0(a2,d2.w),d3
	clr.b	0(a2,d2.w)
	move.l	a2,a1
	WiCall	Print
	move.b	d3,0(a2,d2.w)
	bra.s	ReInp
; Imprime le ?
L111a   moveq	#"?",d1
	WiCall	ChrOut
	moveq	#" ",d1
	WiCall	ChrOut
; Rempli le buffer!
ReInp:
* Clavier
	lea	Es_LEd(a5),a0
	move.l	Buffer(a5),a1
	clr.b	(a1)
	move.l	a1,a2
	move.w	#(1<<LEd_FCursor)|(1<<LEd_FTests)|(1<<LEd_FMulti),d0
	moveq	#0,d1			Curseur � zero
	move.w	#256,d2			256 caracteres maxi
	moveq	#-1,d3			Largeur maxi
	Rjsr	L_LEd_Init
	Rbne	L_FonCall		Trop � droite...
	Rjsr	L_LEd_Loop
	move.l	d0,d3
	tst.w	d2
	bpl.s	InnPut
	Rbra	L_InStop
* Fichier!
ReDInp:
	move.l	PrintFile(a5),a2
	move.l	Buffer(a5),a1
	clr.b	(a1)
	moveq	#0,d1
	move.w	12(sp),d2
	move.b	ChrInp+1(a5),d3
	move.b	ChrInp(a5),d4
	bra.s	InpD1
InpD0	move.b	d0,(a1)+
	addq.w	#1,d1
	cmp.w	#1000,d1
	Rbcc	L_InpTL
InpD1	Rbsr	L_GetByte
	cmp.b	d0,d2			* Stop aux virgules
	beq.s	InpD2
	cmp.b	d0,d3			* Premier caractere?
	bne.s	InpD0
 	tst.b	d4			* Sauter le deuxieme?
	bmi.s	InpD2
	Rbsr	L_GetByte
InpD2	clr.b	(a1)
	move.l	a1,d3
	sub.l	Buffer(a5),d3		* Nombre de caracteres -> D3

;	INPUT/LINE INPUT: interprete le buffer!
InnPut:	move.l	Buffer(a5),a2
Inn1:	move.w	-2(a3),d2
	cmp.b	#2,d2
	bne.s	Inn5
* Variable alphanumerique
	move.l	-6(a3),a0
	move.l	ChVide(a5),(a0)		* Libere la memoire!
	tst.l	d3
	beq	Inn10
	Rbsr	L_DDemande
	addq.l	#2,a0
	move.b	12+1(sp),d1
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
	move.l	-6(a3),a0
	move.l	a1,(a0)
	bra.s	Inn10
* Variable numerique
Inn5:	move.l	a2,a0
	moveq	#1,d0			Tenir compte du signe
	move.w	-2(a3),d2		Le type desire
	Rjsr	L_ValRout
	move.l	a0,a2
	move.b	(a2),d0			Caractere de fin
	beq.s	Inn6			Zero=> ok
	cmp.b	12+1(sp),d0		Ou stop
	bne	InnRedo
Inn6	move.l	-6(a3),a0		Adresse de la variable
	move.l	d3,(a0)			Poke!
	move.w	-2(a3),d0		Type= float?
	beq.s	Inn10
	tst.b	MathFlags(a5)		Double?
	bpl.s	Inn10
	move.l	d4,4(a0)		Oui, poke double!
; Encore une variable a prendre???
Inn10:	subq.l	#6,a3
	subq.w	#1,d5
	beq.s	Inn11
	cmp.b	#",",(a2)+
	beq	Inn1
* ??
	tst.l	PrintFile(a5)
	bne	ReDInp
	WiCalA	Print,InnEnc(pc)
	move.l	Buffer(a5),a0
	clr.b	(a0)
	bra	ReInp
* Fini!
Inn11:	movem.l	(sp)+,a3/d5
	addq.l	#6,sp
	Rbsr	L_EndByte
	rts
* Redo from start
InnRedo
	Rbsr	L_EndByte
	tst.l	PrintFile(a5)
	Rbne	L_TypeMis
	Rbsr	L_CRet
	moveq	#15,d0
	Rjsr	L_Def_GetMessage
	move.l	a0,a1
	WiCall	Print
	Rbsr	L_CRet
	movem.l	(sp)+,a3/d5
	bra	IInp0
InnEnc:	dc.b	13,10,"?? ",0
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;			Retour chariot
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CRet
; - - - - - - - - - - - - -
	WiCalA	Print,InnRet(pc)
	rts
InnRet:	dc.b 	13,10,0,0


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;      	DEBUT PRINT H
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InPrintH
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rbsr	L_GetFile
	tst.l	FhA(a2)
	Rbeq	L_FilNO
	btst	#0,FhT(a2)
	Rbeq	L_FilTM
	cmp.w	#1,d0
	Rbeq	L_FilTM
	move.l	a2,PrintFile(a5)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	IMPRESSION d'un chiffre ENTIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrintE
; - - - - - - - - - - - - -
	move.l 	d3,d0
	moveq	#-1,d3         		;proportionnel
        moveq 	#1,d4         		;avec signe
        move.l 	Buffer(a5),a0
        Rjsr 	L_LongToAsc
        clr.b 	(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	      	IMPRESSION d'un chiffre FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrintF
; - - - - - - - - - - - - -
	move.l 	Buffer(a5),a0
	Rjsr	L_Float2Ascii
	clr.b	(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	      	IMPRESSION d'une chaine
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrintS
; - - - - - - - - - - - - -
	move.l 	d3,a2
        move.w 	(a2)+,d2
L35r:   move.l	Buffer(a5),a0
	beq.s	L35c
	move.w	#255,d0
L35a:   move.b 	(a2)+,(a0)+
        subq.w 	#1,d2
        beq.s 	L35c
        dbra 	d0,L35a
L35b	movem.l	a2/d2,-(sp)
	Rbsr 	L_PrintX
	movem.l	(sp)+,a2/d2
	tst.w	d2
	bra.s	L35r
L35c	clr.b	(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	FIN IMPRESSION NORMALE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrintX
; - - - - - - - - - - - - -
	move.l	Buffer(a5),a1
	WiCall	Print
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	FIN IMPRESSION NORMALE IMPRIMANTE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	LPrintX
; - - - - - - - - - - - - -
	move.l	Buffer(a5),a0
	Rbra	L_PRT_Print

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;      	PRINT seul
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CRPrint
; - - - - - - - - - - - - -
	move.l	Buffer(a5),a0
	move.l	#$0D0A0000,(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	      	IMPRESSION d'une chaine dans un fichier
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	HPrintS
; - - - - - - - - - - - - -
	move.l 	d3,a0
	moveq	#0,d3
	move.w	(a0)+,d3
	beq.s	L825x
	move.l	a0,d2
	move.l	PrintFile(a5),a0
	move.l	FhA(a0),d1
	DosCall	_LVOWrite
	cmp.l	d0,d3
	Rbne	L_DiskError
L825x	move.l	Buffer(a5),a0
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	      	PRINT RETOUR CHARIOT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrtRet
; - - - - - - - - - - - - -
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	clr.b	(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	      	PRINT VIRGULE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	PrtVir
; - - - - - - - - - - - - -
	move.b	#9,(a0)+
	clr.b	(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;			FIN IMPRESSION NORMALE dans un fichier
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	HPrintX
; - - - - - - - - - - - - -
	move.l	PrintFile(a5),a1
	move.l	FhA(a1),d1
	move.l	Buffer(a5),d2
	move.l	a0,d3
	sub.l	d2,d3
	DosCall DosWrite
	cmp.l	d0,d3
	Rbne	L_DiskError
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	USING CHIFFRES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	UsingC
; - - - - - - - - - - - - -
	move.l 	(a3)+,a0		Chaine de formattage
	movem.l	a3/d6/d7,-(sp)
        move.l 	Buffer(a5),a1
        lea 	256(a1),a1
        move.w 	(a0)+,d0
        beq.s 	l41a3
        cmp.w 	#127,d0
        bcs.s 	l41a1
        moveq 	#127,d0
l41a1:  subq.w 	#1,d0
l41a2:  move.b 	(a0)+,(a1)+
        dbra 	d0,l41a2
l41a3:  clr.b 	(a1)
; USING pour les CHIFFRES
        move.l 	Buffer(a5),a1
        lea 	128(a1),a2
        moveq 	#127,d0
us2:    move.b 	(a1),(a2)+   ;recopie la chaine, et fait le menage!!!
        move.b 	#32,(a1)+
        dbra 	d0,us2
        move.l 	Buffer(a5),a0
        lea 	128(a0),a1      ;a1 pointe la chaine
        move.l 	a1,d6        ;debut chaine a formatter
        move.l 	Buffer(a5),a2
        lea 	256(a2),a2    ;a2 pointe la chaine de definition
        move.l 	a2,d7        ;debut chaine de format
us3:    move.b 	(a2),d0
        beq.s 	us5
        cmp.b 	#".",d0       ;cherche la fin du format de chiffre
        beq.s 	us5
        cmp.b 	#";",d0
        beq.s 	us5
        cmp.b 	#"^",d0
        beq.s 	us5
        addq.l 	#1,a0
        addq.l 	#1,a2
        bra.s 	us3
us5:    move.b (a1),d0
        beq.s 	us6
        cmp.b 	#".",d0       ;trouve le point de la chaine a formatter
        beq.s 	us6             ;ou la fin
        cmp.b 	#"E",d0
        beq.s 	us6
        addq.l	#1,a1
        bra.s 	us5
us6:    movem.l a0-a2,-(sp)
; ecris la gauche du chiffre
us7:    cmp.l 	d7,a2         ;fini a gauche???
        beq 	us15
        move.b 	-(a2),d0
        cmp.b 	#"#",d0
        beq.s 	us8
        cmp.b 	#"-",d0
        beq.s 	us11
        cmp.b 	#"+",d0
        beq.s 	us12
        move.b 	d0,-(a0)     ;aucun signe reserve: le met simplement!
        bra.s 	us7
us8:    cmp.l 	d6,a1         ;-----> "#"
        bne.s 	us10
us9:    move.b 	#" ",-(a0)   ;arrive au debut du chiffre!
        bra.s 	us7
us10:   move.b 	-(a1),d0
        cmp.b 	#"0",d0       ;pas un chiffre (signe)
        bcs.s 	us9
        cmp.b 	#"9",d0
        bhi.s 	us9
        move.b 	d0,-(a0)     ;OK, chiffre: poke!
        bra.s 	us7
us11:   move.l 	d6,a3        ;-----> "-"
        move.b 	(a3),-(a0)   ;met le "signe": 32 ou "-"
        bra.s 	us7
us12:   move.l 	d6,a3
        move.b 	(a3),d0
        cmp.b 	#"-",d0
        beq.s 	us13
        move.b 	#"+",d0
us13:   move.b 	d0,-(a0)     ;-----> "+"
        bra 	us7
; ecrit la droite du chiffre
us15:   movem.l (sp)+,a0-a2 ;recupere les adresses pivot
        clr.l 	d2            ;flag puissance
        cmp.b 	#".",(a1)     ;saute le point dans le chiffre a afficher
        bne.s 	us16
        addq.l 	#1,a1
us16:   move.b 	(a2)+,d0
        beq 	finus         ;fini OUF!
        cmp.b 	#";",d0       ;";" marque la virgule sans l'ecrire!
        beq.s 	us18z
        cmp.b 	#"#",d0
        beq.s 	us17
        cmp.b 	#"^",d0
        beq.s 	us20
        move.b 	d0,(a0)+     ;ne correspond a rien: POKE!
        bra.s 	us16
us17:   move.b 	(a1),d0      ;-----> "#"
        bne.s	us19
us18:   tst 	d2
        beq.s 	us18a
us18z:  move.b 	#" ",(a0)+   ;si puissance passee: met des espaces
        bra.s 	us16
us18a:  move.b 	#"0",(a0)+   ;fin du chiffre: met un zero apres la virgule
        bra.s 	us16
us19:   cmp.b 	#"0",d0
        bcs.s 	us18
        cmp.b 	#"9",d0
        bhi.s 	us18
        addq.l 	#1,a1
        move.b 	d0,(a0)+
        bra 	us16
us20:   tst 	d2              ;-----> "^"
        bmi.s 	us24
        bne.s 	us25
us21:   move.b 	(a1),d0
        beq.s 	us22
        cmp.b 	#"E",d0
        beq.s 	us23
        addq.l	#1,a1
        bra.s 	us21
us22:   moveq	#1,d2          ;pas de puissance: en fabrique une!
        bra.s 	us25
us23:   moveq 	#-1,d2
us24:   move.b 	(a1),d0      ;si fin du chiffre: met des espaces
        beq 	us18
        addq.l 	#1,a1
        cmp.b 	#32,d0        ;saute l'espace entre E et +/-
        beq.s 	us24
        move.b 	d0,(a0)+
        bra 	us16
us25:   lea 	usip(pc),a3
        move.b 	-1(a3,d2.w),(a0)+ ;met une fausse puissance!
        cmp.b	#6,d2
        beq	us16
        addq 	#1,d2
        bra 	us16
finus:  movem.l	(sp)+,a3/d6/d7
	clr.b 	(a0)
        rts
usip:   dc.b 	"E+000  "
	even

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	      	USING CHAINES
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	UsingS
; - - - - - - - - - - - - -
	move.l 	d3,a0			Chaine � formater
        move.l 	Buffer(a5),a1
	lea	128(a1),a1
        move.w 	(a0)+,d0
        beq.s 	l42c
        cmp.w 	#127,d0
        bcs.s 	l42a
        moveq 	#127,d0
l42a	subq.w 	#1,d0
l42b	move.b 	(a0)+,(a1)+
        dbra 	d0,l42b
l42c	clr.b 	(a1)

	move.l 	(a3)+,a0		* Chaine de formatage
        move.l 	Buffer(a5),a1
        lea 	256(a1),a1
        move.w 	(a0)+,d0
        beq.s 	l42a3
        cmp.w 	#127,d0
        bcs.s 	l42a1
        moveq 	#127,d0
l42a1:  subq.w 	#1,d0
l42a2:  move.b 	(a0)+,(a1)+
        dbra 	d0,l42a2
l42a3:  clr.b 	(a1)

        move.l 	Buffer(a5),a0
        lea 	128(a0),a1
        lea 	128(a1),a2
; ecris la chaine dans le buffer
us52:   move.b 	(a2)+,d0
        beq.s 	fnusc
        cmp.b 	#"~",d0
        beq.s 	us53
        move.b 	d0,(a0)+
        bra.s 	us52
us53:   move.b 	(a1),d0      ;----> "~"
        bne.s 	us54
        move.b 	#32,(a0)+
        bra.s 	us52
us54:   addq.l 	#1,a1
        move.b 	d0,(a0)+
        bra.s 	us52
fnusc:  clr.b 	(a0)
        rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: Ecrans.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					DEFAULT PALETTE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InDefaultPalette
; - - - - - - - - - - - - -
	lea	DefPal(a5),a0
	Rbra	L_Plt
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PALETTE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InPalette
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	Rbeq	L_ScNOp
	moveq	#15,d1
	move.l	Buffer(a5),a0
	move.l	a0,a1
Pal1:	move.l	#-1,(a1)+
	dbra	d1,Pal1
	Rbsr	L_Plt
	EcCall	SPal
	Rbne	L_EcWiErr
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	Plt
; - - - - - - - - - - - - -
	move.w	d0,d1
	lsl.w	#2,d1
	add.w	d1,a3
	move.l	a3,a2
	subq.w	#1,d0
Plt1:	move.l	-(a2),d2
	bmi.s	Plt2
	and.w	#$FFF,d2
	move.w	d2,(a0)
Plt2:	addq.l	#2,a0
	dbra	d0,Plt1
	move.l	Buffer(a5),a1
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FADE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InFade1
; - - - - - - - - - - - - -
	move.l	Buffer(a5),a0
	move.l	a0,a1
	moveq	#31,d0
.Loop	clr.w	(a0)+
	dbra	d0,.Loop
	Rbra	L_InFade
; - - - - - - - - - - - - -
	Lib_Cmp	InFade2
; - - - - - - - - - - - - -
	moveq	#-1,d3
	Rbra	L_InFade3
; - - - - - - - - - - - - -
	Lib_Cmp	InFade3
; - - - - - - - - - - - - -
	move.l	(a3)+,d1
	bpl.s	IFat1
	Rjsr	L_Bnk.GetBobs		<0 -->> sprite palette
	Rbeq	L_BkNoRes
	move.w	(a0)+,d0
	lsl.w	#3,d0
	lea	0(a0,d0.w),a0
	bra.s	IFat2
IFat1	Rjsr	L_GetEc
	lea	EcPal(a0),a0
IFat2	Rbsr	L_PalRout
	Rbra	L_InFade
; - - - - - - - - - - - - -		Fade a,b,c,d
	Lib_Cmp	InFadePal
; - - - - - - - - - - - - -
	moveq	#15,d1
	move.l	Buffer(a5),a0
	move.l	a0,a1
IFap	move.l	#-1,(a1)+
	dbra	d1,IFap
	Rbsr	L_Plt
	Rbra	L_InFade
; - - - - - - - - - - - - -
	Lib_Cmp	InFade
; - - - - - - - - - - - - -		Lance le fade
	tst.w	ScOn(a5)
	Rbeq	L_ScNOp
	move.l	(a3)+,d1
	Rbls	L_FonCall
	EcCall	FadeOn
	Rbne	L_FonCall
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	POLYLINE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InPolyline
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	Rbeq	L_ScNOp
	move.w	d0,d3
	lsl.w	#3,d0
	add.w	d0,a3
	move.l	a3,a2
	move.l	T_RastPort(a5),a1
	move.l	Buffer(a5),a0
	moveq	#0,d0
	tst.w	d1
	bne.s	L315a
	move.w	36(a1),d1
	move.w	38(a1),d2
	addq.w	#1,d3
	bra.s	L315b
L315a	move.l	-(a2),d1
	move.l	-(a2),d2
L315b	move.w	d1,(a0)+
	move.w	d2,(a0)+
	addq.w	#1,d0
	subq.w	#1,d3
	bne.s	L315a
	move.l	Buffer(a5),a0
	move.w	(a0),36(a1)
	move.w	2(a0),38(a1)
	move.w	#PolyDraw,d5
	Rjmp	L_GfxFunc

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	POLYGON
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InPolygon
; - - - - - - - - - - - - -
	tst.w	ScOn(a5)
	Rbeq	L_ScNOp
	move.w	d0,d5
	move.w	d1,d4

; Initialise le buffer AREADRAW
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea	AAreaInfo(a5),a0
	lea	AAreaBuf(a5),a1
	moveq	#AAreaSize,d0
	move.l	T_RastPort(a5),a2
	move.l	a0,16(a2)
	GfxCa5	InitArea

	move.w	d5,d0
	lsl.w	#3,d0
	add.w	d0,a3
	move.l	a3,a0
	move.l	T_RastPort(a5),a1
	move.l	Buffer(a5),a2
	tst.w	d4
	beq.s	L341a
	move.l	-(a0),d0
	move.l	-(a0),d1
	subq.w	#1,d5
	bra.s	L341b
L341a	move.w	36(a1),d0
	move.w	38(a1),d1
L341b	GfxCa5	AreaMove
L341c	move.l	-(a0),d0
	move.l	-(a0),d1
	GfxCa5	AreaDraw
	subq.w	#1,d5
	bne.s	L341c
	Rjsr	L_GetRas
	GfxCa5	AreaEnd
	Rjmp	L_FreeRas


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	CHANNEL x TO SPRITE x
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	ChannelToSprite
; - - - - - - - - - - - - -
	moveq	#0,d0
	moveq	#64,d1
	Rbra	L_InChannel
; - - - - - - - - - - - - -
	Lib_Cmp	ChannelToBob
; - - - - - - - - - - - - -
	moveq	#1,d0
	moveq	#64,d1
	Rbra	L_InChannel
; - - - - - - - - - - - - -
	Lib_Cmp	ChannelToSDisplay
; - - - - - - - - - - - - -
	moveq	#2,d0
	moveq	#8,d1
	Rbra	L_InChannel
; - - - - - - - - - - - - -
	Lib_Cmp	ChannelToSSize
; - - - - - - - - - - - - -
	moveq	#3,d0
	moveq	#8,d1
	Rbra	L_InChannel
; - - - - - - - - - - - - -
	Lib_Cmp	ChannelToSOffset
; - - - - - - - - - - - - -
	moveq	#4,d0
	moveq	#8,d1
	Rbra	L_InChannel
; - - - - - - - - - - - - -
	Lib_Cmp	ChannelToRainbow
; - - - - - - - - - - - - -
	moveq	#6,d0
	moveq	#4,d1
	Rbra	L_InChannel
; - - - - - - - - - - - - -
	Lib_Cmp	InChannel
; - - - - - - - - - - - - -
	move.l	(a3)+,d4
	cmp.l	#64,d4
	Rbcc	L_FonCall
	cmp.l	d1,d3
	Rbcc	L_FonCall
	lsl.w	#1,d4
	lea	AnCanaux(a5),a0
	move.b	d0,0(a0,d4.w)		* 1 => TYPE
	move.b	d3,1(a0,d4.w)		* 2 => NUMERO
	rts


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	BSETBCLRBCHGBTSTROLROR
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InBset
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	(a0),d1
	bset	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InBset1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	bset	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InBclr
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	(a0),d1
	bclr	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InBclr1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	bclr	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InBchg
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	(a0),d1
	bchg	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InBchg1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	bchg	d0,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FnBtst
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	(a0),d1
	btst	d0,d1
	Rbne	L_FnTrue
	Rbra	L_FnFalse
; - - - - - - - - - - - - -
	Lib_Cmp	FnBtst1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	btst	d0,(a0)
	Rbne	L_FnTrue
	Rbra	L_FnFalse


; - - - - - - - - - - - - -
	Lib_Cmp	InRorB
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.b	3(a0),d1
	ror.b	d0,d1
	move.b	d1,3(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRorB1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	move.b	(a0),d1
	ror.b	d0,d1
	move.b	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRorW
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.w	2(a0),d1
	ror.w	d0,d1
	move.w	d1,2(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRorW1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	move.w	(a0),d1
	ror.w	d0,d1
	move.w	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRorL
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	(a0),d1
	ror.l	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRorL1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	move.l	(a0),d1
	ror.l	d0,d1
	move.l	d1,(a0)
	rts

; - - - - - - - - - - - - -
	Lib_Cmp	InRolB
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.b	3(a0),d1
	rol.b	d0,d1
	move.b	d1,3(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRolB1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	move.b	(a0),d1
	rol.b	d0,d1
	move.b	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRolW
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.w	2(a0),d1
	rol.w	d0,d1
	move.w	d1,2(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRolW1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	move.w	(a0),d1
	rol.w	d0,d1
	move.w	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRolL
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	(a0),d1
	rol.l	d0,d1
	move.l	d1,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InRolL1
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	(a3)+,d0
	move.l	(a0),d1
	rol.l	d0,d1
	move.l	d1,(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	CALL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InCall
; - - - - - - - - - - - - -
	move.l	d3,d0
	Rjsr	L_Bnk.OrAdr
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
; 					=STRUC=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InStruc
; - - - - - - - - - - - - -
	move.l	(a3)+,a0
	move.l	a0,d1
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
	Rbne	L_AdrErr
	move.w	d3,(a0)
	rts
.Long	btst	#0,d1
	Rbne	L_AdrErr
	move.l	d3,(a0)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp FnStruc
; - - - - - - - - - - - - -
	move.l	d3,a0
	move.l	d3,d1
	moveq	#0,d3
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
	rts
.Word	btst	#0,d1
	Rbne	L_AdrErr
	move.w	(a0),d3
	ext.l	d3
	rts
.Long	btst	#0,d1
	Rbne	L_AdrErr
	move.l	(a0),d3
	rts
.UByte	move.b	(a0),d3
	rts
.UWord	btst	#0,d1
	Rbne	L_AdrErr
	move.w	(a0),d3
	rts
.ULong	btst	#0,d1
	Rbne	L_AdrErr
	move.l	(a0),d3
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=STRUC$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InStrucD
; - - - - - - - - - - - - -
	move.l	(a3)+,a0
	move.l	a0,d1
	btst	#0,d1
	Rbne	L_AdrErr
	clr.l	(a0)
	move.l	d3,a2
	move.w	(a2)+,d2
	cmp.l	#"|00|",(a2)
	beq.s	.Skp
	moveq	#2,d3
	add.w	d2,d3
	Rjsr	L_Demande
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
	Lib_Cmp FnStrucD
; - - - - - - - - - - - - -
	move.l	d3,a0
	btst	#0,d3
	Rbne	L_AdrErr
	move.l	(a0),d0
	Rbeq	L_Ret_ChVide
	move.l	d0,a0
	Rjsr	L_A0ToChaine
	move.l	a0,d3
	rts



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: String.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Demande de l'espace pour les chaines
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Demande
; - - - - - - - - - - - - -
dem0	move.l 	HiChaine(a5),a0
        move.l 	a0,a1
	add.l	d3,a1
	addq.l	#4,a1
	cmp.l	TabBas(a5),a1
	bcc.s	dem1
	move.l	a0,a1
        rts
; Va faire le menage, si revient: OK!
dem1:	tst.b	ErrorRegs(a5)		Recharger les registres?
	beq.s	.NoReg
	movem.l	ErrorSave(a5),d6-d7
.NoReg	Rbsr 	L_Menage 		Va faire le menage
; Ca marche maintenant?
	move.l	HiChaine(a5),a1		Ca marche maintenant?
	add.l	d3,a1
	addq.l	#4,a1
	cmp.l	TabBas(a5),a1
	bcc	FinMenE
; Ca a marche, un patch?
	tst.l	Patch_Menage(a5)
	bne.s	dem3
; Que faire?
	tst.l	d6
	beq.s	FinMenE			Plus de memoire
	cmp.l	#-1,d6			Menage simple: revient a l'appelant
	beq.s	dem0
; On vient de le faire?
	Rbsr	L_GetInstruction	Pointe l'instruction
	cmp.l	d6,a1			La meme que la derniere fois?
	beq	FinMenE
	move.l	a1,d6			On stocke
	move.l	Cmp_LowPile(a5),sp
	move.l	BasA3(a5),a3
	jmp	(a1)			On rebranche a l'instruction!
; Branche au patch
dem3	move.l	Patch_Menage(a5),a0
	jmp	(a0)
; Erreur!
FinMenE	moveq	#11,d0			Out of buffer space
	Rbra	L_Error

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Demande chaine sans erreur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	DDemande
; - - - - - - - - - - - - -
	move.l	#-1,d6			Flag pour le menage
	Rbsr	L_Demande		Va demander
	moveq	#1,d6			Empeche les erreurs
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MENAGE ALPHANUMERIQUE
;	Taille maximum chaine: 65472 ($FFC0)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Menage
; - - - - - - - - - - - - -
	movem.l d1-d7/a2-a6,-(sp)

;	IFNE	Debug>1
;	movem.l	d0-d7/a0-a6,-(sp)
;	moveq	#70,d3
;	JJsrIns	L_InBell1,1
;	movem.l	(sp)+,d0-d7/a0-a6
;	ENDC
;	IFNE	Debug>2
;	Rjsr	L_PreBug
;	ENDC

	move.l	a6,VarLoc(a5)

;	Essaie de proceder � un FAST-MENAGE!
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	HiChaine(a5),d7
	move.l	LoChaine(a5),d6
	move.l	d7,d0
	sub.l	d6,d0
	cmp.l	#$3FFFFE*2,d0			8 Megas maximum!
	bcc	SLOW_MENAGE
	move.l	d0,d5
	SyCall	MemFast
	beq	SLOW_MENAGE

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

; ------------------------------------------------------------------------
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

;-----> FIN DES DEUX MENAGES : ca marche maintenant?
FinMenS movem.l (sp)+,d1-d7/a2-a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					LEFT$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InLeft
; - - - - - - - - - - - - -
	Rbsr 	L_RInMid
	move.l	(a3)+,d4
	moveq	#0,d5
	Rbra 	L_RInMid2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Fonction LEFT$
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnLeft
; - - - - - - - - - - - - -
        move.l 	d3,d4
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
        moveq 	#0,d5
	Rbra 	L_RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=RIGHT$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InRight
; - - - - - - - - - - - - -
	Rbsr 	L_RInMid
        move.l 	(a3)+,d4
        Rbmi	L_FonCall
        moveq 	#0,d5
        cmp.l 	d3,d4
        Rbcc	L_RInMid2
        move.l 	d3,d5
	sub.l 	d4,d5
        addq.l 	#1,d5
	Rbra 	L_RInMid2
; - - - - - - - - - - - - -
	Lib_Cmp FnRight
; - - - - - - - - - - - - -
        move.l 	d3,d5
        Rbmi 	L_FonCall
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
	Rbra 	L_RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					MID$=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InMid2
; - - - - - - - - - - - - -
	Rbsr 	L_RInMid
	move.l	(a3)+,d5
	move.l	#$FFFF,d4
	Rbra 	L_RInMid2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnMid2
; - - - - - - - - - - - - -
        move.l 	d3,d5
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
        move.l 	#$FFFF,d4
	Rbra 	L_RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					=MID$() 3 params
; - - - - - - - - - - - - -
	Lib_Cmp InMid3
; - - - - - - - - - - - - -
	Rbsr 	L_RInMid
	move.l	(a3)+,d4
	move.l	(a3)+,d5
	Rbra	L_RInMid2
; - - - - - - - - - - - - -
	Lib_Cmp FnMid3
; - - - - - - - - - - - - -
        move.l 	d3,d4
        move.l 	(a3)+,d5
        move.l 	(a3)+,a2
        moveq 	#0,d2
        move.w 	(a2)+,d2
	Rbra	L_RFnMid

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Commun LEFT MID RIGHT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	RFnMid
; - - - - - - - - - - - - -
        tst.l 	d5                        ;pointe au milieu de la chaine
        Rbmi 	L_FonCall
        beq.s 	mi2
        subq.l 	#1,d5
mi2:    add.l 	d5,a2
        cmp.l 	d2,d5                     ;pas pointe trop loin??
        bcc.s 	RVide                     ;si! chaine vide
mi3:    tst.l 	d4
        beq.s 	RVide
        Rbmi 	L_FonCall
mi4:    add.l 	d5,d4
        cmp.l 	d2,d4
        bls.s 	mi5
        move.l 	d2,d4
mi5:    sub.l 	d5,d4
mi6:    move.l 	d4,d3
	Rjsr 	L_Demande
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
	rts
RVide:  move.l 	ChVide(a5),d3          	;ramene la chaine vide
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Commun MID LEFT RIGHT = /  A0= adresse variable
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	RInMid
; - - - - - - - - - - - - -
   	moveq 	#0,d3
	move.l	a0,a2
	move.l	(a2),a1
        move.w 	(a1)+,d3
        Rbsr 	L_Demande
	move.l	(a2),d0
        move.l 	a0,(a2)          ;Change la variable
	move.l	d0,a2
        move.w 	d3,d2
        move.w 	d2,(a0)+         ;Longueur
        subq.w 	#1,d2
        lsr.w 	#2,d2
	addq.l	#2,a2
L77b:   move.l 	(a2)+,(a0)+
        dbra 	d2,L77b
        move.l 	a0,HiChaine(a5)
        addq.l	#2,a1
	moveq 	#0,d2		 ;A1/D3= destination
        move.l 	(a3)+,a2 	 ;A2/D2= source
        move.w 	(a2)+,d2
        rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Commun LEFT MID RIGHT II
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	RInMid2
; - - - - - - - - - - - - -
	tst.l 	d5
        Rbmi	L_FonCall
        beq.s 	mdst2
        subq.l 	#1,d5
mdst2:  add.l 	d5,a1             ;situe dans la chaine a changer
        cmp.l 	d3,d5
        bcc.s 	mdst10            ;trop loin: ne change rien
        tst.l 	d4
        Rbmi	L_FonCall
        beq.s 	mdst10
        add.l 	d5,d4
        cmp.l 	d3,d4
        bls.s 	mdst3
        move.l 	d3,d4
mdst3:  sub.l 	d5,d4
        cmp.l 	d2,d4             ;limite par la taille de la chaine source
        bls.s 	mdst4
        move.l 	d2,d4
mdst4:  subq.l 	#1,d4            ;la chaine source est nulle!
        bmi.s 	mdst10
mdst5:  move.b 	(a2)+,(a1)+
        dbra 	d4,mdst5
mdst10: rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	=VAL  /  D2= type desire
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnVal
; - - - - - - - - - - - - -
	move.w	d2,d4
	move.l	d3,a2
	move.w	(a2)+,d2
	beq.s	.Vide
        Rjsr 	L_ChVerBuf        	Recopie la chaine dans le buffer
        move.l	Buffer(a5),a0
	moveq	#1,d0			Tenir compte du signe
	move.w	d4,d2			Type desire
        Rjmp 	L_ValRout
.Vide	moveq	#0,d3			Retourne un 0 entier / float / double
	moveq	#0,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 		=RESOURCE$(n)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp FnResource
; - - - - - - - - - - - - -
; Un message normal?
	move.l	d3,d0
	ble.s	.Skip1
	Rbsr	L_Dia_GetPuzzle
	move.l	a2,a0
	move.l	d3,d0
	Rjsr	L_GetMessage
	bra	.Fin
; Le path du systeme? (0)
.Skip1	neg.l	d0
	bne.s	.Skip2
	Rbsr	L_Sys_GetPath		Va chercher le pathname
	lea	Sys_Pathname(a5),a0	Additionne!
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
	Rbcc	L_FonCall
	move.l	Ed_RunMessages(a5),a0
; Retourne la chaine
.Fin0	Rjsr	L_GetMessage
.Fin	move.l	a0,a2
	Rbra	L_Str2Chaine


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Source: Menus.s
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MENU KEY
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InMenuKey
; - - - - - - - - - - - - -
	Rbsr	L_MnDim
	tst.l	MnLat(a2)
	Rbne	L_FonCall
	clr.b	MnKFlag(a2)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InMenuKey1
; - - - - - - - - - - - - -
	Rbsr	L_MnDim
	tst.l	MnLat(a2)
	Rbne	L_FonCall
	move.l	(a3)+,a0
	tst.w	(a0)+
	Rbeq	L_FonCall
	move.b	(a0),MnKAsc(a2)
	move.b	#1,MnKFlag(a2)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	InMenuKey2
; - - - - - - - - - - - - -
	Rbsr	L_MnDim
	tst.l	MnLat(a2)
	Rbne	L_FonCall
	move.l	(a3)+,d2
	moveq	#0,d3
	Rbra	L_MnKy
; - - - - - - - - - - - - -
	Lib_Cmp	InMenuKey3
; - - - - - - - - - - - - -
	Rbsr	L_MnDim
	tst.l	MnLat(a2)
	Rbne	L_FonCall
	move.l	(a3)+,d3
	move.l	(a3)+,d2
	Rbra	L_MnKy
; - - - - - - - - - - - - -
	Lib_Cmp	MnKy
; - - - - - - - - - - - - -
L966	cmp.l	#256,d3
	Rbcc	L_FonCall
	move.b	d3,MnKSh(a2)
	cmp.l	#128,d2
	Rbcc	L_FonCall
	move.b	d2,MnKSc(a2)
	move.b	#-1,MnKFlag(a2)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	INSTRUCTION ON MENU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InOnMenu
; - - - - - - - - - - - - -
	Rjsr	L_OMnEff
	Rlea	L_GoMenu,0		Branche la routine au test
	move.l	a0,GoTest_GoMenu(a5)
	move.w	d0,OMnType(a5)
	ext.l	d1
	move.w	d1,OMnNb(a5)
	move.w	d1,d2			* Nb de labesl*4
	lsl.w	#2,d1
	move.l	d1,d0
	SyCall	MemFast
	Rbeq	L_OOfMem
	move.l	a0,OMnBase(a5)
	add.l	d1,a0
* Poke les jumps
	subq.w	#1,d2
OnMn2	move.l	(a3)+,-(a0)
	dbra	d2,OnMn2
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
	Rbra	L_OMnEff

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MENU$(,,,)=
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InMenu
; - - - - - - - - - - - - -
	move.l	#EntNul,d3
	move.l	d3,-(a3)
	move.l	d3,-(a3)
	move.l	d3,-(a3)
	Rbra	L_InMenu4
; - - - - - - - - - - - - -
	Lib_Cmp	InMenu2
; - - - - - - - - - - - - -
	move.l	#EntNul,d3
	move.l	d3,-(a3)
	move.l	d3,-(a3)
	Rbra	L_InMenu4
; - - - - - - - - - - - - -
	Lib_Cmp	InMenu3
; - - - - - - - - - - - - -
	move.l	#EntNul,-(a3)
	Rbra	L_InMenu4
; - - - - - - - - - - - - -
	Lib_Cmp	InMenu4
; - - - - - - - - - - - - -
	Rjsr	L_MnClearVar		Routine pour ClearVar

	move.l	a3,-(sp)
	lea	4*4(a3),a3		Pointe les dimensions
	move.w	d5,d0
	lsl.w	#2,d0
	pea	0(a3,d0.w)		Position par defaut de la pile
	Rjsr	L_MnFind
	bne.s	IMenA
	Rjsr	L_MnIns
IMenA	move.l	4(sp),a3		Repointe les chaines

* Parametres par defaut
	move.l	ScOnAd(a5),a0
	cmp.l	MnAdEc(a5),a0
	beq.s	IMen6
	tst.l	MnAdEc(a5)
	Rbne	L_ScNOp
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
* Prend la chaine OBF
	lea	MnObF(a2),a0
	bsr	MnOob
* Prend la chaine OBOFF
	lea	MnOb3(a2),a0
	bsr	MnOob
* Prend la chaine OB2
	lea	MnOb2(a2),a0
	bsr	MnOob
* Prend la chaine OB1
	lea	MnOb1(a2),a0
	bsr	MnOob
* Ca y est!!!
IMenX:	addq.w	#1,MnChange(a5)
	move.l	(sp)+,a3
	addq.l	#4,sp
	rts

;	Petite routine de creation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MnOob	move.l	(a3)+,d3
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
	Rbeq	L_OOfMem
	Rbmi	L_FonCall
	move.l	d0,(a0)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MENU DEL
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	InMenuDel
; - - - - - - - - - - - - -
	Rjmp	L_MnRaz
; - - - - - - - - - - - - -
	Lib_Cmp	InMenuDel1
; - - - - - - - - - - - - -
	Rbsr	L_MnDim
	move.l	a2,d0
	moveq	#0,d5
	addq.w	#1,MnChange(a5)
	Rjsr	L_MnEff
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SET MENU
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp InSetMenu
; - - - - - - - - - - - - -
	Rbsr	L_MnDim
	move.l	(a3)+,d3
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
; 	Trouve l'adresse d'un objet de menu
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	MnDim
; - - - - - - - - - - - - -
	tst.w	d5
	bne.s	MnDim1
	tst.l	d3
	Rbeq	L_FonCall
	cmp.l	#MnNDim,d3
	Rbhi	L_FonCall
	lea	MnDFlags(a5),a0
	lea	-1(a0,d3.w),a0
	rts
* Cherche l'adresse D'UN objet
MnDim1	Rjsr	L_MnFind
	lsl.w	#2,d5
	add.w	d5,a3			Saute les parametres
	tst.w	d0
	beq.s	.Nd
	lea	MnFlag(a2),a0
	rts
.Nd	moveq	#39,d0			Menu item not defined
	Rbra	L_GoError

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Entree procedure menu 		*** illegal
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	MenuProcedure
; - - - - - - - - - - - - -
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	SOUS PROGRAMME UTILISE PAR VAL ET INPUT
;	D0=	Tenir compte du signe (TRUE)
;	D2=	Type voulu: 0= Entier / 1= Float / -1= le mieux
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	ValRout
; - - - - - - - - - - - - -
        movem.l a1-a2/d5-d7,-(sp)
	move.w	d2,-(sp)
	move.l	a0,d7
	moveq	#0,d4
	move.l	a0,a2
	tst.w	d0
	beq.s	val1c

; 	y-a-t'il un signe devant?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
; 	Explore le debut du chiffre
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.b 	(a0)+,d0
        beq 	val10
        cmp.b 	#32,d0
        beq.s 	val1c
        cmp.b 	#"$",d0      	;chiffre HEXA
        beq	CHexa
        cmp.b	#"%",d0       	;chiffre BINAIRE
        beq 	CBin
        cmp.b 	#".",d0
        beq.s 	val2
        cmp.b 	#"0",d0
        bcs 	val10
        cmp.b 	#"9",d0
        bhi 	val10

; 	Copie le chiffre dans BuFloat
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
val2:   subq.l	#1,a0
	move.l 	a0,a1        	Si float: trouve la fin du chiffre
        clr.w 	d3		Les flags
	lea	BuFloat(a5),a2
	moveq	#60,d2		Taille maxi du buffer
val3:	move.b 	(a1)+,d0
        cmp.b 	#32,d0
        beq.s 	val3
	move.b	d0,(a2)+
        beq.s 	val4
	subq.w	#1,d2		Au bout du buffer?
	beq.s	val4
        cmp.b 	#"0",d0
        bcs.s 	val3z
        cmp.b 	#"9",d0
        bls.s 	val3
val3z:	cmp.b 	#".",d0       	Cherche une "virgule"
        bne.s	val3a
        bset 	#0,d3          	Si deux virgules: fin du chiffre
        beq.s 	val3
        bne.s 	val4
val3a:  cmp.b 	#"e",d0       	Cherche un exposant
        beq.s 	val3b
        cmp.b 	#"E",d0       	Autre caractere: fin du chiffre
        bne.s 	val4
val3ab: move.b 	#"e",-1(a2)  	Met un E minuscule!!!
val3b:  move.b 	(a1)+,d0     	Apres un E, accepte -/+ et chiffres
        cmp.b 	#32,d0
        beq.s 	val3b
        cmp.b 	#"+",d0
        beq.s 	val3c
        cmp.b 	#"-",d0
        bne.s 	val3e
val3c:  bset 	#1,d3          	+ ou -: c'est un float!
	move.b	d0,(a2)+
val3d:  subq.w	#1,d2		Au bout du buffer?
	beq.s	val4
	move.b 	(a1)+,d0     	Puis cherche la fin de l'exposant
        cmp.b 	#32,d0
        beq.s 	val3d
val3e:  move.b	d0,(a2)+
	subq.w	#1,d2		Au bout du buffer?
	beq.s	val4
	cmp.b 	#"0",d0
        bcs.s 	val4
        cmp.b 	#"9",d0       	Chiffre! c'est un float
        bls.s 	val3c
val4:  	clr.b	(a2)
	clr.b	-(a2)		Recule d'un > fin du float
	subq.l	#1,a1		Reste sur la fin du chiffre
	lea	BuFloat(a5),a0	Le buffer de conversion

	tst.w	(sp)			Un entier quoi qu'il arrive
	beq.s	CEntier
	bpl.s	.Float
	btst	#0,MathFlags(a5)	Si indifferent,
	beq.s	CEntier			Entier, si pas de math

; 	Conversion ASCII ---> FLOAT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.Float	move.l	a1,-(sp)
	Rjsr 	L_Ascii2Float
	move.l	d0,d3
	move.l	d1,d4
	move.l	(sp)+,a0		Pointe la fin du chiffre
	moveq	#1,d2			Un float
	moveq	#0,d0			Pas d'erreur
	bra.s	ValOut			La sortie

; 	Converti vers un chiffre entier
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; chiffre entier
CEntier	move.l	a1,-(sp)
	bsr 	declong			Conversion a partir de BuFloat
	move.l	(sp)+,a0		Pointe la fin du chiffre
	bra.s	CFin
; chiffre hexa
CHexa:  bsr 	hexalong
        bra.s 	CFin
; chiffre binaire
CBin	bsr 	binlong
; Test du signe
CFin	move.l	d0,d3			Retourne en D3
	tst.w 	d1			Conversion valide?
        beq.s 	.Ok
        moveq	#0,d3			Si probleme: ramene zero!
.Ok	tst.w 	d4
        beq.s 	ECheck
        neg.l 	d3

;	Verification du type
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
ECheck	moveq	#0,d0			Pas d'erreur
	moveq	#0,d2			Entier
	tst.w	(sp)			Que veut-on?
	beq.s	.Ent			Un entier
	bpl.s	.Flt			Un float!
	btst	#0,MathFlags(a5)	On sait pas, si float present...
	beq.s	.Ent			...retourne un float
.Flt	movem.l	d0-d1/a0,-(sp)
	Rjsrt	L_IntToFl1
	movem.l	(sp)+,d0-d1/a0
	moveq	#1,d2
.Ent	bra.s	ValOut

; 	Erreur, ramene zero
; ~~~~~~~~~~~~~~~~~~~~~~~~~
val10:  moveq	#0,d3
	moveq	#1,d0
	move.l	d7,a0			Repointe le debut
	bra.s	ECheck
; Sortie
ValOut	addq.l	#2,sp
 	movem.l (sp)+,a1-a2/d5-d7
	tst.l	d0
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Ouverture des libraries mathematiques
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	CmpInitFloat
; - - - - - - - - - - - - -
	move.b	d0,MathFlags(a5)		Stocke les flags
	move.l	a6,-(sp)
	move.l	$4.w,a6
	move.l	#$c90fd942,ValPi(a5)		Simple precision
	move.l	#$b4000048,Val180(a5)
; Init float.library
	moveq	#0,d0
	lea	FloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,FloatBase(a5)
	beq.s	.Err
; Init mathffp.library
	btst	#1,MathFlags(a5)		Des maths?
	beq.s	.Ok
	moveq	#0,d0
	lea	MathName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,MathBase(a5)
	beq.s	.Err
.Ok	moveq	#0,d0
	bra.s	.Out
.Err	moveq	#1,d0
.Out	move.l	(sp)+,a6
	rts
FloatName
	dc.b 	"mathffp.library",0
MathName
	dc.b 	"mathtrans.library",0
	even

; - - - - - - - - - - - - -
	Lib_Cmp	CmpInitDouble
; - - - - - - - - - - - - -
	move.l	a6,-(sp)
	move.b	d0,MathFlags(a5)		Stocke les flags
	move.l	$4.w,a6
; Init float.library
	moveq	#0,d0
	lea	.FloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,FloatBase(a5)
	beq.s	.Err
; Init mathffp.library
	moveq	#0,d0
	lea	.MathName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,MathBase(a5)
	beq.s	.Err
; Pi / 180
	move.l	#$40668000,Val180(a5)
	move.l	#$00000000,Val180+4(a5)
	move.l	#$400921fb,ValPi(a5)
	move.l	#$54442eea,ValPi+4(a5)
; Init Dfloat
	moveq	#0,d0
	lea	.DFloatName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DFloatBase(a5)
	beq.s	.Err
; Init DMath
	moveq	#0,d0
	lea	.DMathName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DMathBase(a5)
	beq.s	.Err
; OK!
.Ok	moveq	#0,d0
	bra.s	.Out
.Err	moveq	#1,d0
.Out	move.l	(sp)+,a6
	rts
.FloatName
	dc.b 	"mathffp.library",0
.MathName
	dc.b 	"mathtrans.library",0
.DFloatName
	dc.b 	"mathieeedoubbas.library",0
.DMathName
	dc.b 	"mathieeedoubtrans.library",0
	even


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ENTIER >>> FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion entier >>> float dans le dernier operateur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	IntToFl1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFlt(a6)
	move.l	d3,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DIntToFl1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFlt(a6)
	move.l	d3,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					ENTIER >>> FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion entier >>> float dans la pile
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	IntToFl2
; - - - - - - - - - - - - -
	move.l	(a3),d0
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFlt(a6)
	move.l	d4,a6
	move.l	d0,(a3)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DIntToFl2
; - - - - - - - - - - - - -
	movem.l	(a3),d0-d1
	move.l	a6,d2
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFlt(a6)
	move.l	d2,a6
	movem.l	d0-d1,(a3)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FLOAT >>> ENTIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion float >>> entier dans le dernier operateur
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FlToInt1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFix(a6)
	move.l	d3,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DFlToInt1
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d3
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFix(a6)
	move.l	d3,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FLOAT >>> ENTIER
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Conversion float >>> entier dans la pile
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FlToInt2
; - - - - - - - - - - - - -
	move.l	(a3),d0
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	_LVOSPFix(a6)
	move.l	d4,a6
	move.l	d0,(a3)
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DFlToInt2
; - - - - - - - - - - - - -
	movem.l	(a3),d0-d1
	move.l	a6,d2
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPFix(a6)
	move.l	d2,a6
	movem.l	d0-d1,(a3)
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FONCTION MATHEMATIQUE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une fonction mathematique
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Math_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	MathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DMath_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d3
	move.l	DMathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					COMPARAISONS FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une comparaison float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Float_Compare
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	(a3)+,d1
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	_LVOSPCmp(a6)
	move.l	d3,a6
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DFloat_Compare
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	movem.l	(a3)+,d2-d3
	move.l	a6,d5
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPCmp(a6)
	move.l	d5,a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Operation FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une operation float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Float_Operation
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	d3,d1
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d4,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DFloat_Operation
; - - - - - - - - - - - - -
	movem.l	(a3)+,d0-d1
	exg	d3,d2
	exg	d4,d3
	move.l	a6,d5
	move.l	DFloatBase(a5),a6
	jsr	0(a6,d4.w)
	move.l	d5,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	FLOAT= ZERO?
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait un TST sur le float D3
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Float_Test
; - - - - - - - - - - - - -
	move.l	d3,d1
	move.l	a6,d4
	move.l	FloatBase(a5),a6
	jsr	_LVOSPTst(a6)
	move.l	d4,a6
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	Float_TestF
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d2
	move.l	DFloatBase(a5),a6
	jsr	_LVOIEEEDPTst(a6)
	move.l	d2,a6
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Operation MATH
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une operation Math
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Math_Operation
; - - - - - - - - - - - - -
	move.l	(a3)+,d0
	move.l	d3,d1
	move.l	a6,d4
	move.l	MathBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d4,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DMath_Operation
; - - - - - - - - - - - - -
	movem.l	(a3)+,d0-d1
	exg	d3,d2
	exg	d4,d3
	move.l	a6,d5
	move.l	DMathBase(a5),a6
	jsr	0(a6,d4.w)
	move.l	d5,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					FONCTION FLOAT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;       Fait une fonction float
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Float_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	a6,d3
	move.l	FloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d3,a6
	move.l	d0,d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	DFloat_Fonction
; - - - - - - - - - - - - -
	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d5
	move.l	DFloatBase(a5),a6
	jsr	0(a6,d2.w)
	move.l	d5,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Verifie que le float est positif
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FlPos			Simple precision
; - - - - - - - - - - - - -
	btst	#7,d3
	Rbne	L_FonCall
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FlPosD			Double precision
; - - - - - - - - - - - - -
	btst	#31,d3
	Rbne	L_FonCall
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					RETOURNE UN ANGLE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	AAngle			SFloat
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
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	AAngleD			DFloat
; - - - - - - - - - - - - -
	move.l	d3,d0			Appel de la fonction
	move.l	d4,d1
	move.l	a6,d5
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
.AAnY	move.l	d5,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					TRANSFORME EN ANGLE
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FFAngle			SFloat
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
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FAngleD			DFloat
; - - - - - - - - - - - - -
	tst.w	Angle(a5)
	bne.s	.Conv
	rts
; Conversion--> radian
.Conv	move.l	d3,d0
	move.l	d4,d1
	move.l	a6,d5
	move.l	DFloatBase(a5),a6
	move.l	Val180(a5),d2
	move.l	Val180+4(a5),d3
	jsr	_LVOSPDiv(a6)
	move.l	ValPi(a5),d2
	move.l	ValPi+4(a5),d3
	jsr	_LVOSPMul(a6)
	move.l	d5,a6
	move.l	d0,d3
	move.l	d1,d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					PARAM FLOAT (!)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FnParamF		SFloat
; - - - - - - - - - - - - -
	move.l	ParamF(a5),d3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp FnParamD		DFloat
; - - - - - - - - - - - - -
	move.l	ParamF(a5),d3
	move.l	ParamF2(a5),d4
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	ASCII Vers Float
;	A0	Buffer
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	Ascii2Float
; - - - - - - - - - - - - -
	move.l	a0,-(sp)
	Rjsr	L_AscToFloat
	addq.l	#4,sp
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	Ascii2FloatD
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
	Lib_Cmp	Float2Ascii
; - - - - - - - - - - - - -
	move.l 	d3,d0			Simple precision
	move.w	FixFlg(a5),d4
        move.w 	ExpFlg(a5),d5
	bclr	#31,d4
	Rjmp	L_FloatToAsc
; - - - - - - - - - - - - -
	Lib_Cmp	Float2AsciiD
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
.Lop	tst.b	(a0)+			Pointe la fin
	bne.s	.Lop
	subq.l	#1,a0
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MAX en simple/double precision
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FnMaxF
; - - - - - - - - - - - - -
	move.l	(a3),-(a3)
	Rjsrt	L_Float_Compare
	ble.s	.Skip
	move.l	(a3),d3
.Skip	addq.l	#4,a3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FnMaxD
; - - - - - - - - - - - - -
	movem.l	(a3),d0-d1
	movem.l	d0-d1,-(sp)
	movem.l	d3-d4,-(sp)
	Rjsrt	L_Float_Compare
	ble.s	.Skip
	movem.l	(sp),d3-d4
	bra.s	.Out
.Skip	movem.l	8(sp),d3-d4
.Out	lea	16(sp),sp
	rts
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	MIN en simple/double precision
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Cmp	FnMinF
; - - - - - - - - - - - - -
	move.l	(a3),-(a3)
	Rjsrt	L_Float_Compare
	bge.s	.Skip
	move.l	(a3),d3
.Skip	addq.l	#4,a3
	rts
; - - - - - - - - - - - - -
	Lib_Cmp	FnMinD
; - - - - - - - - - - - - -
	movem.l	(a3),d0-d1
	movem.l	d0-d1,-(sp)
	movem.l	d3-d4,-(sp)
	Rjsrt	L_Float_Compare
	bge.s	.Skip
	movem.l	(sp),d3-d4
	bra.s	.Out
.Skip	movem.l	8(sp),d3-d4
.Out	lea	16(sp),sp
	rts

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 					Espace pour le compilateur!
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_Pos 500
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 	Finish the library
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Lib_End
; - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;		END OF THE EXTENSION
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C_End		dc.w	0
		even
