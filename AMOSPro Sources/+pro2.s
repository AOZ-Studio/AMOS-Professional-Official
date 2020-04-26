
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;				CHARGEMENT DES LIBRARIES + EXTENSIONS
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Libraries_Load
; - - - - - - - - - - - - - - - -

; Librairie principale AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#14,d0
	bsr	Sys_GetMessage
	bsr	Sys_AddPathCom
	moveq	#0,d0
	bsr	Library_Load
	bne.s	.Err
; Charge la librairie complementaire AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq	#15,d0
	bsr	Sys_GetMessage
	bsr	Sys_AddPathCom
	moveq	#0,d0
; Integre les fonctions internes AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	bsr	Library_Patch
; Extensions
; ~~~~~~~~~~
	moveq	#1,d2
.Loop	move.l	d2,d0
	add.w	#16-1,d0
	bsr	Sys_GetMessage
	tst.b	(a0)
	beq.s	.Next
	bsr	Sys_AddPathCom
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
.Loop	move.l	d2,d0
	bsr	Library_Reloc
	bne.s	.Err
	addq.w	#1,d2
	cmp.w	#27,d2
	bne.s	.Loop
	bsr	Libraries_FreeSizes
	bsr	Library_GetParams
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
	bsr	D_Open
	beq	Ll_Disc
; Lis l'entete dans le buffer
	move.l	Buffer(a5),d2
	move.l	#$20+18,d3
	bsr	D_Read
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
	jsr	RamFast
	beq	Ll_OMem
	move.l	d0,a0
	lea	LB_Size(a0,d4.l),a2	Saute les jumps et la datazone
	move.l	a2,(a6)			Extension chargee!!!
	move.l	d1,LB_MemSize(a2)	Taille de la zone memoire
	move.l	a0,LB_MemAd(a2)		Adresse de base
	move.l	(a3),d3			Buffer temporaire pour les tailles
	move.l	d3,d0
	addq.l	#4,d0
	jsr	RamFast
	beq	Ll_OMem
	move.l	d0,a0
	move.l	d3,(a0)+
	move.l	a0,LB_LibSizes(a2)
	move.l	a0,d2	
	bsr	D_Read			des routines
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
	bsr	D_Read
	bne	Ll_Disc
; Ferme le fichier!
	bsr	D_Close
; Rempli la datazone
	move.w	d5,LB_NRout(a2)		Nombre de routines
	clr.w	LB_Flags(a2)		Flags
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

; 	Exploration de la table de tokens
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a3,a0
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
.RNom	tst.b	(a1)+			Saute le nom
	bpl.s	.RNom
	moveq	#0,d2			Type de fonction
	move.b	(a1)+,d1		Definition fonction / instruciton
	bmi.s	.RDoke
	cmp.b	#"C",d1			Si constante
	beq.s	.RCst	
	cmp.b	#"V",d1			Si variable reservee
	bne.s	.RSkip1	
	move.b	(a1)+,d1
	bmi.s	.RDoke
	or.w	#L_VRes,d0
.RSkip1	move.b	(a1)+,d1
	bmi.s	.RDoke
	addq.w	#1,d0
	cmp.b	#"1",d1			Un float?
	bne.s	.RSkip2
	or.w	#L_FFloat,d0
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
; 	Une table de verification rapide?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.l	#"KwiK",(a0)		Le code?
	bne.s	.NoKwik
	lea	4(a0),a0
	move.l	a0,LB_Verif(a3)		Poke l'adresse...
.NoKwik
; 	Relocation des routines...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w	LB_NRout(a3),d3		Nombre de routines
	move.w	d3,d5			Pour comparer...
	subq.w	#1,d3
	lea	-LB_Size(a3),a2
	move.l	LB_LibSizes(a3),a4	Tailles des routines
	JLea	L_Pos_IRet,a0		Position du delta _IRet
	move.w	(a0),d0
	JLea	L_New_ChrGet,a0		Plus adresse
	add.w	d0,a0			=Adresse retour
	sub.l	AdTokens(a5),a0		Moins A4
	move.w	a0,d6			=Delta du JSR(a4)
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
CJmp	move.l	(sp),a0
	jmp	(a0)
	jmp	0(a4)
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
GRouB	move.w	2(a0),d1
	cmp.w	d5,d1
	bcc	GRou2
	lsl.w	#2,d1
	move.w	4(a1,d2.w),(a0)+
	neg.w	d1
	move.l	-LB_Size-4(a3,d1.w),d0
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
	move.w	CNop(pc),d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	bra	GRouN
; Instruction Ret_Inst
GRouD1	cmp.w	#C_CodeInst,2(a0)
	bne	GRou2
	move.l	CJmp(pc),(a0)+
;	move.w	d6,(a0)+
	bra	GRou1
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

L_NoFlag	equ	%1000000000000000
L_Entier	equ	%0000000000000000	0
L_FFloat	equ	%1001000000000000	1
L_FAngle	equ	%1010000000000000	2
L_FMath		equ	%1011000000000000	3
L_VRes		equ	%1100000000000000	4

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	Relocation des recoltes de parametres
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Library_GetParams
; - - - - - - - - - - - - -
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	AdTokens(a5),a4
	JLea	L_Parameters,a3

; 	Exploration de la table de tokens
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	a4,a2
	move.w	(a2),d3
.Loop	move.w	2(a2),d2
	beq.s	.Next
; Une instruction?
; ~~~~~~~~~~~~~~~~
	move.w	d2,d1
	and.w	#%0000000000111111,d1		Nombre de parametres
	move.w	d1,2(a2)
	btst	#6,d2
	beq.s	.NoIns
	lea	-LB_Size(a4,d3.w),a1
	moveq	#0,d0
	bsr	.Rout
.NoIns
; Une fonction?
; ~~~~~~~~~~~~~
	btst	#7,d2
	beq.s	.NoFunc
	lea	-LB_Size-4(a4,d3.w),a1
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
	moveq	#0,d0
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
.Doke	lsl.w	#1,d1			Pointe la table des adresses
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
	move.l	a0,d0			Un message?
	bne	Ll_Mess			Oui,
	beq	Ll_BadExt		Non
.Nomi	ext.w	d0
	cmp.w	d0,d3			Bon numero d'extension?
	bne	Ll_BadExt
	cmp.w	#VerNumber,d1		Bon numero de version?
	bcs	Ll_BadExt
	moveq	#0,d0
	bra	Ll_Out
Ll_Mess	bra	Ll_BadExt		Illegal

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
	bra	Ll_Out
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
	bra	Ll_Out
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
	bra	Ll_Out

; Passe à le prochaine instruction
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

