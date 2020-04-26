	
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
; .200000............2002........................| Tokenisation 
; .200002........................................|
; 220002.........................................|______________________________
; ______________________________________________________________________________
;
		Include	"+Debug.s"
		IFEQ	Debug=2
		Include "+AMOS_Includes.s"	
		Include "+Version.s"
		ENDC
; ______________________________________________________________________________

; Branchements internes
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TDebut		dc.l	Tokenise-TDebut
		dc.l	Detok-TDebut
		dc.l	Mon_Detok-TDebut
		dc.l	TInst-TDebut
		dc.l	0

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
	JJsrR	L_ValRout,a1
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
* Token double precision: flags à 1
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
;	A0:	Ligne à detokeniser
; 	A1:	Buffer
;	D0:	Adresse à détecter
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
	cmp.b	#"0",d3
	beq.s	Dtk4
	cmp.b	#"1",d3
	beq.s	Dtk4
	cmp.b	#"2",d3
	beq.s	Dtk4
	cmp.b	#"V",d3
	beq.s	Dtk4
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


