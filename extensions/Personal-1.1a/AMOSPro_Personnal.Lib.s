;
; *************************************************************
; *							      *
; * FireWorks(c)1995 AmosProfessionnal Personnal Library V1.0 *
; *							      *
; *************************************************************
;

Version		MACRO
		Dc.b	"1.0b"
		ENDM

ExtNb		Equ	13-1

		Include "Includes:amos_includes.s"
;		Include	"Includes:_Chips.s"
;
; DLea et Dload INCOMPILABLES pour la version de demonstration 1.0b
;DLea		MACRO
;		Lea	\1(pc),\2
;		ENDM
;Dload		MACRO
;		Lea	FWC(pc),\1
;		ENDM


; DLea et Dload COMPILABLES pour la version COMPLETE 1.1
DLea		MACRO
		Move.l	ExtAdr+ExtNb*16(a5),\2
		Add.w	#\1-FWC,\2
		ENDM
Dload		MACRO
		Move.l	ExtAdr+ExtNb*16(a5),\1
		ENDM
;
SaveRegisters	MACRO
		DLea	Registers,a0
		Move.l	a3,(a0)
		ENDM

LoadRegisters	MACRO
		DLea	Registers,a0
		Move.l	(a0),a3
		ENDM

Start		Dc.l	C_TK-C_OFF
		Dc.l	C_LIB-C_TK
		Dc.l	C_TITLE-C_LIB
		Dc.l	C_END-C_TITLE
		Dc.w	0

C_OFF		Dc.w	(L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2,(L5-L4)/2
		Dc.w	(L6-L5)/2,(L7-L6)/2,(L8-L7)/2,(L9-L8)/2
		Dc.w	(L10-L9)/2,(L11-L10)/2,(L12-L11)/2,(L13-L12)/2
		Dc.w	(L14-L13)/2,(L15-L14)/2,(L16-L15)/2,(L17-L16)/2
		Dc.w	(L18-L17)/2,(L19-L18)/2,(L20-L19)/2,(L21-L20)/2
		Dc.w	(L22-L21)/2,(L23-L22)/2,(L24-L23)/2,(L25-L24)/2
		Dc.w	(L26-L25)/2,(L27-L26)/2,(L28-L27)/2,(L29-L28)/2
		Dc.w	(L30-L29)/2,(L31-L30)/2,(L32-L31)/2,(L33-L32)/2
		Dc.w	(L34-L33)/2,(L35-L34)/2,(L36-L35)/2,(L37-L36)/2
		Dc.w	(L38-L37)/2,(L39-L38)/2,(L40-L39)/2,(L41-L40)/2
		Dc.w	(L42-L41)/2,(L43-L42)/2,(L44-L43)/2,(L45-L44)/2
		Dc.w	(L46-L45)/2,(L47-L46)/2,(L48-L47)/2,(L49-L48)/2
		Dc.w	(L50-L49)/2,(L51-L50)/2,(L52-L51)/2,(L53-L52)/2
		Dc.w	(L54-L53)/2,(L55-L54)/2,(L56-L55)/2,(L57-L56)/2
		Dc.w	(L58-L57)/2,(L59-L58)/2,(L60-L59)/2,(L61-L60)/2
		Dc.w	(L62-L61)/2,(L63-L62)/2,(L64-L63)/2,(L65-L64)/2
		Dc.w	(L66-L65)/2,(L67-L66)/2,(L68-L67)/2,(L69-L68)/2
		Dc.w	(L70-L69)/2,(L71-L70)/2,(L72-L71)/2,(L73-L72)/2
		Dc.w	(L74-L73)/2,(L75-L74)/2,(L76-L75)/2,(L77-L76)/2
		Dc.w	(L78-L77)/2,(L79-L78)/2,(L80-L79)/2,(L81-L80)/2
		Dc.w	(L82-L81)/2,(L83-L82)/2,(L84-L83)/2,(L85-L84)/2
		Dc.w	(L86-L85)/2,(L87-L86)/2,(L88-L87)/2,(L89-L88)/2
		Dc.w	(L90-L89)/2,(L91-L90)/2,(L92-L91)/2,(L93-L92)/2
		Dc.w	(L94-L93)/2,(L95-L94)/2,(L96-L95)/2,(L97-L96)/2
		Dc.w	(L98-L97)/2,(L99-L98)/2,(L100-L99)/2
		Dc.w	(L101-L100)/2,(L102-L101)/2,(L103-L102)/2
		Dc.w	(L104-L103)/2,(L105-L104)/2,(L106-L105)/2
		Dc.w	(L107-L106)/2,(L108-L107)/2,(L109-L108)/2
		Dc.w	(L110-L109)/2,(L111-L110)/2,(L112-L111)/2
		Dc.w	(L113-L112)/2,(L114-L113)/2,(L115-L114)/2
		Dc.w	(L116-L115)/2,(L117-L116)/2,(L118-L117)/2
		Dc.w	(L119-L118)/2,(L120-L119)/2,(L121-L120)/2
		Dc.w	(L122-L121)/2,(L123-L122)/2,(L124-L123)/2



;		Dc.w	...

C_TK		Dc.w	1,0
		Dc.b	$80,-1
		Dc.w	L_SNTSC,-1
		Dc.b	"set nts","c"+$80,"I",-1
		Dc.w	L_SPAL,-1
		Dc.b	"set pa","l"+$80,"I",-1
		Dc.w	-1,L_RCLICK
		Dc.b	"right clic","k"+$80,"0",-1
		Dc.w	-1,L_FIRE2
		Dc.b	"fire(1,2",")"+$80,"0",-1
		Dc.w	-1,L_FIRE3
		Dc.b	"fire(1,3",")"+$80,"0",-1
		Dc.w	-1,L_HAM
		Dc.b	"ha","m"+$80,"0",-1
		Dc.w	-1,L_EHB
		Dc.b	"eh","b"+$80,"0",-1
		Dc.w	L_CREATECOPPER,-1
		Dc.b	"create ag","a"+$80,"I0",-1
		Dc.w	-1,L_TESTA3
		Dc.b	"tes","t"+$80,"0",-1
		Dc.w	L_SETCOLOR,-1
		Dc.b	"set colo","r"+$80,"I0,0,0,0",-1
		Dc.w	L_XFADE,-1
		Dc.b	"x fad","e"+$80,"I",-1
		Dc.w	-1,L_COPPERBASE
		Dc.b	"copper bas","e"+$80,"0",-1
		Dc.w	L_CHANGECOPPER,-1
		Dc.b	"copper bas","e"+$80,"I0",-1
		Dc.w	L_SETPLANE,-1
		Dc.b	"set plan","e"+$80,"I0,0",-1
		Dc.w	-1,L_PLANEBASE
		Dc.b	"plane bas","e"+$80,"00",-1
		Dc.w	-1,L_COLORREAD
		Dc.b	"set colo","r"+$80,"00",-1
		Dc.w	L_LINEWAIT,-1
		Dc.b	"copper next lin","e"+$80,"I",-1
		Dc.w	-1,L_LINESEE
		Dc.b	"copper lin","e"+$80,"0",-1
		Dc.w	L_VIEW2,-1
		Dc.b	"set view plane","s"+$80,"I0",-1
		Dc.w	L_COLORWAIT,-1
		Dc.b	"new color valu","e"+$80,"I0,0,0,0",-1
		Dc.w	L_SCREENSIZE,-1
		Dc.b	"set screen size","s"+$80,"I0,0",-1
		Dc.w	-1,L_XSIZE
		Dc.b	"screen x siz","e"+$80,"0",-1
		Dc.w	-1,L_YSIZE
		Dc.b	"screen y siz","e"+$80,"0",-1
		Dc.w	L_CREATECOPPER2,-1
		Dc.b	"create standar","d"+$80,"I0",-1
		Dc.w	L_SCREENOFFSET,-1
		Dc.b	"screen positio","n"+$80,"I0,0,0",-1
		Dc.w	L_DUALPLAYFIELD,-1
		Dc.b	"set dual mod","e"+$80,"I0",-1
		Dc.w	L_RESOLUTION,-1
		Dc.b	"set resolutio","n"+$80,"I0",-1
		Dc.w	L_SETLACE,-1
		Dc.b	"set lac","e"+$80,"I0",-1
		Dc.w	L_COPPERLINE2,-1
		Dc.b	"copper wait lin","e"+$80,"I0",-1
		Dc.w	L_MOSAICx2,-1
		Dc.b	"mosaic x","2"+$80,"I0",-1
		Dc.w	L_MOSAICx4,-1
		Dc.b	"mosaic x","4"+$80,"I0",-1
		Dc.w	L_Mosaicx8,-1
		Dc.b	"mosaic x","8"+$80,"I0",-1
		Dc.w	L_Mosaicx16,-1
		Dc.b	"mosaic x1","6"+$80,"I0",-1
		Dc.w	L_MOSAICx32,-1
		Dc.b	"mosaic x3","2"+$80,"I0",-1
		Dc.w	L_ACTIVECOP,-1
		Dc.b	"active coppe","r"+$80,"I",-1
		Dc.w	L_SETHAMMODE,-1
		Dc.b	"ham mod","e"+$80,"I0",-1
		Dc.w	L_IFFTOSCREEN,-1
		Dc.b	"iff conver","t"+$80,"I0",-1
		Dc.w	L_ALLOWPLANES,-1
		Dc.b	"allow plane co","l"+$80,"I0",-1
		Dc.w	L_FORBIDPLANES,-1
		Dc.b	"forbid plane co","l"+$80,"I0",-1
		Dc.w	L_RESERVEDPF,-1
		Dc.b	"inverse playfield","s"+$80,"I",-1
		Dc.w	L_NORMALDPF,-1
		Dc.b	"normal playfield","s"+$80,"I",-1
		Dc.w	-1,L_CHECKCOL
		Dc.b	"sprite co","l"+$80,"00,0",-1
		Dc.w	-1,L_CHECKCOL2
		Dc.b	"playfields co","l"+$80,"0",-1
		Dc.w	-1,L_CHECKCOL3
		Dc.b	"pf sprites co","l"+$80,"00,0",-1
		Dc.w	-1,L_COS1000
		Dc.b	"fc co","s"+$80,"00",-1
		Dc.w	-1,L_SIN1000
		Dc.b	"fc si","n"+$80,"00",-1
		Dc.w	-1,L_TAN1000
		Dc.b	"fc ta","n"+$80,"00",-1
		Dc.w	-1,L_IFFXSize
		Dc.b	"iff x siz","e"+$80,"00",-1
		Dc.w	-1,L_IFFYSize
		Dc.b	"iff y siz","e"+$80,"00",-1
		Dc.w	-1,L_IFFDepth
		Dc.b	"iff plane","s"+$80,"00",-1
		Dc.w	L_DoubleMASK,-1
		Dc.b	"double mas","k"+$80,"I0t0,0",-1
		Dc.w	L_DoubleMASK2,-1
		Dc.b	"l double mas","k"+$80,"I0,0,0t0,0",-1
		Dc.w	L_RESERVESPRITE,-1
		Dc.b	"f set sprite buffe","r"+$80,"I0,0",-1
		Dc.w	L_GETEVENSPRITE,-1
		Dc.b	"get even sprit","e"+$80,"I0,0,0,0t0",-1
		Dc.w	L_GETODDSPRITE,-1
		Dc.b	"get odd sprit","e"+$80,"I0,0,0,0t0",-1
		Dc.w	L_ACTIVESPRITE,-1
		Dc.b	"f sprit","e"+$80,"I0t0,0,0,0",-1
		Dc.w	L_DOUBLEMASKB,-1			; Src1,Msk,Src2,Cible.
		Dc.b	"blit mas","k"+$80,"I0,0,0t0",-1
		Dc.w	L_DOUBLEMASKB2,-1	; Src1,Msk,Src2 To Cible,Ys,Ye.
		Dc.b	"l blit mas","k"+$80,"I0,0,0t0,0,0",-1
		Dc.w	L_PATCH13,-1
		Dc.b	"aga of","f"+$80,"I",-1
		Dc.w	L_LFILTER1,-1
		Dc.b	"low filter.","b"+$80,"I0t0,0",-1
		Dc.w	L_LFILTER2,-1
		Dc.b	"low filter.","w"+$80,"I0t0,0",-1
		Dc.w	L_LFILTER3,-1
		Dc.b	"low filter.","l"+$80,"I0t0,0",-1
		Dc.w	L_2NDPAL,-1
		Dc.b	"set dual palett","e"+$80,"I0",-1
		Dc.w	-1,L_READIFFCOLOR
		Dc.b	"iff colo","r"+$80,"00,0",-1
		Dc.w	L_ADD2SCREEN,-1
		Dc.b	"active second scree","n"+$80,"I",-1
		Dc.w	L_SET2PLANES,-1
		Dc.b	"set second plane","s"+$80,"I0,0",-1
		Dc.w	L_SET2VIEW,-1
		Dc.b	"set second vie","w"+$80,"I0",-1
		Dc.w	L_SET2PAL,-1
		Dc.b	"set second colo","r"+$80,"I0,0,0,0",-1
		Dc.w	-1,L_CMAP
		Dc.b	"cmap bas","e"+$80,"00",-1
		Dc.w	L_BPALETTE,-1
		Dc.b	"change palett","e"+$80,"I0,0",-1
		Dc.w	L_IPALETTE,-1
		Dc.b	"iff8bits palette to coppe","r"+$80,"I0,0",-1
		Dc.w	L_VBLWAIT,-1
		Dc.b	"vb line wai","t"+$80,"I0",-1
		Dc.w	L_JPALETTE,-1
		Dc.b	"iff4bits palette to coppe","r"+$80,"I0,0",-1
		Dc.w	L_FPALETTE,-1
		Dc.b	"fade palett","e"+$80,"I0,0,0",-1
		Dc.w	L_CPALETTE,-1
		Dc.b	"attribute palett","e"+$80,"I0,0,0,0,0t0",-1
		Dc.w	L_2VIEW,-1
		Dc.b	"second y siz","e"+$80,"I0",-1
		Dc.w	L_IFF8TO4,-1
		Dc.b	"iff8bits to iff4bit","s"+$80,"I0,0t0",-1
		Dc.w	L_SETCOLORCOMP,-1
		Dc.b	"set aga colo","r"+$80,"I0,0,0,0",-1
		Dc.w	L_MFILL,-1
		Dc.b	"octets fil","l"+$80,"I0,0t0",-1
		Dc.w	L_BLITCOPY,-1
		Dc.b	"blitter cop","y"+$80,"I0t0",-1
		Dc.w	L_CONFORM32,-1
		Dc.b	"s32 block to scree","n"+$80,"I0",-1
		Dc.w	L_CONFORM32B,-1
		Dc.b	"s32 vertice to scree","n"+$80,"I0",-1
		Dc.w	L_SETDPLANE,-1
		Dc.b	"set d plan","e"+$80,"I0,0",-1
		Dc.w	L_SWAPPLANES,-1
		Dc.b	"swap plane","s"+$80,"I",-1
		Dc.w	L_RESICON,-1
		Dc.b	"aga reserve ico","n"+$80,"I0",-1
		Dc.w	L_ERAICON,-1
		Dc.b	"aga erase ico","n"+$80,"I",-1
		Dc.w	L_GETICON,-1
		Dc.b	"aga get ico","n"+$80,"I0,0,0",-1
		Dc.w	L_PASICON,-1
		Dc.b	"aga paste ico","n"+$80,"I0,0,0",-1
		Dc.w	-1,L_ICONBASE
		Dc.b	"aga icon bas","e"+$80,"0",-1
		Dc.w	L_SAVEICON,-1
		Dc.b	"aga icon sav","e"+$80,"I2",-1
		Dc.w	L_LOADICON,-1
		Dc.b	"aga icon loa","d"+$80,"I2",-1
		Dc.w	L_MPRESERVE,-1
		Dc.b	"mplot reserv","e"+$80,"I0",-1
		Dc.w	L_MPERASE,-1
		Dc.b	"mplot eras","e"+$80,"I",-1
		Dc.w	L_MPLOAD,-1
		Dc.b	"mplot loa","d"+$80,"I2",-1
		Dc.w	L_MPSAVE,-1
		Dc.b	"mplot sav","e"+$80,"I2",-1
		Dc.w	L_MPDEFINE,-1
		Dc.b	"mplot defin","e"+$80,"I0,0,0,0",-1
		Dc.w	-1,L_MPBASE
		Dc.b	"mplot bas","e"+$80,"0",-1
		Dc.w	L_MPDRAW,-1
		Dc.b	"mplot dra","w"+$80,"I0t0",-1
		Dc.w	-1,L_MPX
		Dc.b	"x mplo","t"+$80,"00",-1
		Dc.w	-1,L_MPY
		Dc.b	"y mplo","t"+$80,"00",-1
		Dc.w	-1,L_MPC
		Dc.b	"c mplo","t"+$80,"00",-1
		Dc.w	L_MPMODIFY,-1
		Dc.b	"mplot modif","y"+$80,"I0t0,0,0",-1
		Dc.w	L_MPMODIFY2,-1
		Dc.b	"mplot x defin","e"+$80,"I0,0",-1
		Dc.w	L_MPMODIFY3,-1
		Dc.b	"mplot y defin","e"+$80,"I0,0",-1
		Dc.w	L_MPMODIFY4,-1
		Dc.b	"mplot c defin","e"+$80,"I0,0",-1
		Dc.w	L_MPORIGIN,-1
		Dc.b	"mplot origi","n"+$80,"I0,0",-1
		Dc.w	L_MPPLANES,-1
		Dc.b	"mplot plane","s"+$80,"I0",-1
		Dc.w	L_LSRL,-1
		Dc.b	"lsr zon","e"+$80,"I0t0",-1
		Dc.w	L_MPDRAWDPF1,-1
		Dc.b	"mplot dpf1 dra","w"+$80,"I0t0",-1
		Dc.w	L_MPDRAWDPF2,-1
		Dc.b	"mplot dpf2 dra","w"+$80,"I0t0",-1
;		Dc.w	...
;		Dc.b	...	
		Dc.w	0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_LIB
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L0	movem.l	a3-a6,-(sp)
	Lea	FWC(pc),a2
	Move.l	a2,ExtAdr+ExtNb*16(a5)
	Lea	RouDef(pc),a0
	Move.l	a0,ExtAdr+ExtNb*16+4(a5)
	Lea	RouEnd(pc),a0
	Move.l	a0,ExtAdr+ExtNb*16+8(a5)
;	Bra	_nofucktime
; OUVERTURE ET ECRITURE DU REQUEST POUR LA VERSION UNREGISTERED!!!
	Move.l	$4,a6
	DLea	_DName,a1
	Move.l	#0,d0
	Jsr	-552(a6)	; Open Library
	DLea	_DBase,a0
	Move.l	d0,(a0)
	Move.l	d0,a1
	Jsr	-414(a6)
	DLea	WIN,a0
	Move.l	a0,d1
	DLea	_DBase,a0
	Move.l	(a0),a6
	Move.l	#1005,d2
	Jsr	-30(a6)		; Open Window
	DLea	WINH,a0
	Move.l	d0,(a0)
	Move.l	d0,d1
	DLea	WINT,a0
	Move.l	a0,d2
	DLea	WINT2,a3
	DLea	WINT,a4
	Sub.l	a4,a3
	Move.l	a3,d3
	Jsr	-48(a6)
	Move.l	#$300000,d0
_xxc	Sub.l	#1,d0
	Bpl	_xxc
	DLea	WINH,a0
	Move.l	(a0),d1
	Jsr	-36(a6)
_nofucktime
	Movem.l	(sp)+,a3-a6
	Moveq	#ExtNb,D0				; OK
	Rts
******** Initialise.
; Remise a zero de tous les compteurs.
RouDef	Move.w	#$0,$dff1fc		; Disable DOUBLE SCANNING.
	Move.w	#$c00,$dff106		; GRAPHICS PALETTE=0 to 31
	Rts
******** Quit.
RouEnd	DLea	_Mplots,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq	_re1
	Rbra	L_MPERASE
_re1	DLea	_Icons,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq	_re2
	Rbra	L_ERAICON
_re2	Rts
;
;
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DATA ZONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
FWC
; BANQUE DE DONNEES ACCESSIBLES A L'UTILISATEUR.
_BitsPlanes	Dc.l	0,0,0,0,0,0,0,0,0	; All 8 planes adresses.
_CopperBase	Dc.l	0	; Copper base adress.
_XYOff		Dc.l	0,0,0,0	; 2 Ecrans Maxi (Dual Playfield)
_Aga		Dc.l	0	; AGA=1 NONAGA=0 SCREENS COPPER MODE.
_XY		Dc.l	$140,$C0	; X.l,Y.l Screen Sizes(320,192).
_Line		Dc.l	$32	; Line pour la Wait
_CurrentLine	Dc.l	0	; Copper position to add Color change.
; Icons Data List...
_Icons	Dc.l	0	; Nombre d'icones au maximum.
_IcBase	Dc.l	0	; adresse de la banque d'icones.
; Mplot data list...
_Mplots	Dc.l	0
_MpBase	Dc.l	0
_Origin	Dc.l	0,0	; Mplot x,y origin for origin axes.
_MpP	Dc.l	8	; Mplot Max Planes.
; En premier obligatoirement.
_PlanesMask	Dc.l	$0,$1000,$2000,$3000,$4000,$5000,$6000,$7000,$10
_Debuto		Dc.b	"FrWk"
_2nd		Dc.l	0
; Pour la version UNREGISTERED
WIN	Dc.b	"CON:0/16/640/128/"
	Dc.b	"                     »»»»»»»» Amos Request Window ««««««««"
;	Dc.b	"/CLOSE",0
WINH	Dc.l	0
WINT	Dc.b	$9b,"1m"
	Dc.b	" Amos 1.3 ET Amos Professionnal Personnal library",10
	Dc.b	$9b,"3;32m"
	Dc.b	" Version SHAREWARE de demonstration : 1.0b",10
	Dc.b	$9b,"33m"
	Dc.b	" Date d'edition : July 1996",10
	Dc.b	" Auteur : Frederic Cordier",10
	Dc.b	" ",10
	Dc.b	$9b,"0;32m"
	Dc.b	" Cette version est la version de demonstration 1.0b",10
	Dc.b	" ",10
	Dc.b	" Elle a pour protection le fait d'etre INCOMPILABLE.",10
	Dc.b	"Pour obtenir la version Compilable , se referer aux",10
	Dc.b	"documentations fournies avec la librairie.",10,10
	Dc.b	"                                       "
	Dc.b	$9b,"4;33m"
	Dc.b	"Good Work with AMOS...",10
	Dc.b	$9b,"0m"
	Dc.b	" ",10
WINT2	Dc.l	0
;
; Pour les sprites.
_SpriteBase	Dc.l	0
_SpriteLength	Dc.l	0
_SprXPos	Dc.l	0,0,0,0,0,0,0,0		; 08 Sprites au
_SprYPos	Dc.l	0,0,0,0,0,0,0,0		; Maximum (2C.L-)
_SprBase	Dc.l	0,0,0,0,0,0,0,0
_SprLen		Dc.l	0,0,0,0,0,0,0,0
_SprVis		Dc.l	0,0,0,0,0,0,0,0
_Temp		Dc.l	0
;
; Registres
Registers	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_DoubleCopper	Dc.l	0	; Mode Double COPPER-LIST Actif/Inactif.
_BPlanesMask	Dc.l	0	; Mask pour ALLOW PLANES instruction.
_SprPtBase	Dc.l	0	; Adresse de base des sprites.
_ColorBase	Dc.l	0	; In Copper Color00 Position.
_ColorBase2	Dc.l	0	; In Copper Color00 Complement Position.
_BplConBase	Dc.l	0	; In Copper BplCon0 Position.
_BplPtBase	Dc.l	0	; In Copper BplPth0 Position.
_BitsPlanesD	Dc.l	0,0,0,0,0,0,0,0,0
_BitsPlanes2	Dc.l	0,0,0,0,0,0,0,0,0	; during SCREEN OFFSETs.
_CurrentPal	Dc.l	0
_Others		Dc.l	0	; DIWSTRT,DIWSTOP,DDFSTRT,DDFSTOP,BPLMODS
_AgaPalette	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; Autres Registres.
_MosaicBase	Dc.l	0,0
_MosaicPlanes	Dc.l	0,0,0,0,0,0,0,0,0
; Iff CONVERT.
_IffBase	Dc.l	0	; Ilbm Base.
_Bmhd		Dc.l	0	; Ilbm 'BMHD' Base.
_Cmap		Dc.l	0	; Ilbm 'CMAP' Base.
_Body		Dc.l	0	; Ilbm 'BODY' Base.
_LbmXs		Dc.l	0	; Ilbm X Size.
_LbmYs		Dc.l	0	; Ilbm Y Size.
_LbmDp		Dc.l	0	; Ilbm Depth.
_BitsPlanes3	Dc.l	0,0,0,0,0,0,0,0,0	; during IFF Convertion.
; DOUBLE MASK
_MaskBase	Dc.l	0
_MScrn1		Dc.l	0
_MScrn2		Dc.l	0
_MLen		Dc.l	0
_DMY		Dc.l	0,0
_MScroll	Dc.l	0,0
_dx1	Dc.l	0	; FrontGround.
_dx2	Dc.l	0	; Mask.
_dx3	Dc.l	0	; Background.
_dx4	Dc.l	0	; Cible.
_a3	Dc.l	0
_D4	Dc.l	0
; 2eme ecran
_2pal		Dc.l	0
_2bpl		Dc.l	0
_2act		Dc.l	0
_2bplcon	Dc.l	0
; En Dernier Obligatoirement !!!
	Dc.l	0,0,0,0,0,0,0,0	; 8 registres pour les valeurs
; Conform Data list...
_c1	Dc.l	0

_Finito		Dc.b	"ENDL"
; Icon Bank.
_IcN	Dc.b	"                                                "
	Dc.b	"                                               ",0
	EVEN
_DName	Dc.b	"dos.library",0
	EVEN
_DBase	Dc.l	0	; Dos.Library Base.
_IHnd	Dc.l	0	; Icon File Handle.
_IcLoad	Dc.l	0,0,0,0	; Chargement des 8 octets des fichiers Icons.
; Multi plots.
; Tables pour les COSINUS SINUS et TANGENTES.
_Cosinus	IncBin	"_TABLES/_CosTable.Bin"
_Sinus		IncBin	"_TABLES/_SinTable.Bin"
_Tangente	IncBin	"_TABLES/_TanTable.Bin"
;
;
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L1
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L2
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SNTSC			Equ	3				; OK
L3	Move.w	#$0000,$DFF1DC
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SPAL			Equ	4				; OK
L4	Move.w	#$0020,$DFF1DC
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_RCLICK		Equ	5				; OK
L5	Move.l	#0,d2
	Move.l	#0,d3
	Btst	#2,$Dff016
	Bne.b	F1
	Move.l	#$ffffffff,d3
F1	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_FIRE2			Equ	6				; OK
L6	Move.l	#0,d2
	Move.l	#0,d3
	Btst	#6,$dff016
	Bne.b	F2
	Move.l	#$ffffffff,d3
F2	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_FIRE3			Equ	7				; OK
L7	Move.l	#0,d2
	Move.l	#0,d3
	Btst	#4,$dff016
	Bne.b	F3
	Move.l	#$ffffffff,d3
F3	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_HAM:			Equ	8
L8	Move.l	#4096,d3
	Move.l	#0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_EHB			Equ	9
L9	Move.l	#64,d3
	Move.l	#0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CREATECOPPER		Equ	10
L10	Move.l	(a3)+,a0
	Cmp.l	#0,a0
	Beq	_NoCopper
; SAUVEGARDE DE L'ADRESSE DE BASE DU COPPER-LIST A CREER.
	DLea	_CopperBase,a1
	Move.l	a0,(a1)
; COP WAIT ...
	Move.l	#$1003FFFE,(a0)+
	Move.l	#$01fc0000,(a0)+	; Anti Double scanning !!!.
; CREATION DES SPRITES POUR LE COPPER-LIST.
	DLea	_SprPtBase,a1
	Move.l	a0,(a1)
	Move.l	#$01200000,d0
_cc1	Move.l	d0,(a0)+
	Add.l	#$20000,d0
	Cmp.l	#$01400000,d0
	Bne	_cc1
; CREATION DE LA PALETTE DE 256 COULEURS AGA SEULEMENT !!!
	Move.l	#$1803FFFE,(a0)+
;	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	DLea	_ColorBase,a1
	Move.l	a0,(a1)
	Move.l	#$01060000,d0
; SELECTION DU BLOC MEMOIRE.
_cc2	Move.l	d0,(a0)+
	Move.l	#$01800000,d1
; BLOCS DE 32 COULEURS A CODER SEPAREMENT.
_cc3	Move.l	d1,(a0)+
	Add.l	#$00020000,d1
	Cmp.l	#$01C00000,d1
	Bne	_cc3	
	Add.l	#$00002000,d0
	Cmp.l	#$01070000,d0
	Bne	_cc2
; COULEURS COMPLEMENTAIRES (AGA)
	DLea	_ColorBase2,a1
	Move.l	a0,(a1)
	Move.l	#$01060200,d0
; SELECTION DU BLOC MEMOIRE.
_cd2	Move.l	d0,(a0)+
	Move.l	#$01800000,d1
; BLOCS DE 32 COULEURS A CODER SEPAREMENT.
_cd3	Move.l	d1,(a0)+
	Add.l	#$00020000,d1
	Cmp.l	#$01C00000,d1
	Bne	_cd3	
	Add.l	#$00002000,d0
	Cmp.l	#$01070200,d0
	Bne	_cd2
; CREATION DE L'ECRAN.
	Move.l	#$3103FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	DLea	_BplPtBase,a1
	Move.l	a0,(a1)
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
_cc4	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	_cc4
;		OTHERS REGISTERS.
	DLea	_Others,a1
	Move.l	a0,(a1)
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
	DLea	_BplConBase,a1
	Move.l	a0,(a1)
;		BPLCON REGISTERS.
	Move.l	#$01000010,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040224,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
;
	Move.l	#$3203FFFE,(a0)+
	Move.l	#$00968300,(a0)+
	Move.l	#$3103FFFE,(a0)+
	DLea	_CurrentLine,a1
	Move.l	a0,(a1)
	Move.l	#$F203FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$F303FFFE,(a0)+
	Move.l	#$FFFFFFFE,(a0)+
	DLea	_Line,a1
	Move.l	#$32,(a1)
	DLea	_2nd,a1
	Move.l	#0,(a1)
	DLea	_Aga,a1
	Move.l	#$1,(a1)	;AGA SCREEN.
	Rts
_NoCopper
	Moveq	#0,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_TESTA3		Equ	11
L11	DLea	_MpP,a1
	Move.l	(a1),d3
	Move.l	#0,d2
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SETCOLOR		Equ	12
L12	Move.l	(a3)+,d3	; D3=Blue.
	Move.l	(a3)+,d2	; D2=Green.
	Move.l	(a3)+,d1	; D1=Red.
	Move.l	(a3)+,d0	; D0=Register
_sc1b	Lsl.l	#8,d1
	Lsl.l	#4,d2
	Or.l	d1,d2
	Or.l	d2,d3
	DLea	_ColorBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	bne	_sc2b
	Moveq	#1,d0
	Rbra	L_CUSTOM
_sc2b	Move.l	#0,d6
	Add.l	#1,d0
_sc2	Move.w	(a0),d7
	Cmp.w	#$0106,d7
	Bne	_sc3
	Add.l	#4,a0
_sc3	Add.l	#1,d6
	Cmp.l	d6,d0
	Beq	_sc4
	Add.l	#4,a0
	Bra	_sc2
_sc4	Add.l	#2,a0
	Move.w	d3,(a0)
_lsend	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_XFADE			Equ	13
L13	DLea	_CopperBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	bne	_lx1
	Moveq	#1,d0
	Rbra	L_CUSTOM
_lx1	Clr.l	d0
	Clr.l	d1
	Move.w	(a0)+,d0	; D0=register
	Move.w	(a0),d1		; D1=Value
	Cmp.l	#$0180,d0
	blt	_lx2		; D0<COLOR00
	Cmp.l	#$1BE,d0
	Bgt	_lx2		; D0>COLOR31
	Move.l	d1,d2
	Lsr.l	#8,d2
	Lsl.l	#8,d2		; D2=Red.
	Move.l	d1,d3
	Lsr.l	#4,d3
	Lsl.l	#4,d3		; D3=Green.
	Move.l	d1,d4
	Sub.l	d2,d3
	Sub.l	d2,d4
	Sub.l	d3,d4		; D4=Blue.
	Cmp.l	#0,d2
	Beq	_lx3
	Sub.l	#$100,d2
_lx3	Cmp.l	#0,d3
	Beq	_lx4
	Sub.l	#$10,d3
_lx4	Cmp.l	#0,d4
	Beq	_lx5
	Sub.l	#1,d4
_lx5	Add.l	d3,d2
	Add.l	d4,d2
	Move.w	d2,(a0)		; NEW COLOR VALUE.
_lx2	Add.l	#2,a0
	Move.l	(a0),d0
	Cmp.l	#$FFFFFFFE,d0
	Bne	_lx1
_lxend	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_COPPERBASE		Equ	14
L14
	DLea	_CopperBase,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CHANGECOPPER		Equ	15
L15
	Move.l	(a3)+,d0
	DLea	_CopperBase,a1
	Move.l	d0,(a1)
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SETPLANE		Equ	16
L16
	Move.l	(a3)+,d1		; D1=Plane Adresse.
	Move.l	(a3)+,d0		; D0=Bit Plane.
	DLea	_CopperBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Bne	_spx
	Moveq	#1,d0
	Rbra	L_CUSTOM
_spx	DLea	_BitsPlanes,a0
	Cmp.l	#1,d0
	Blt	_spend
	Cmp.l	#8,d0
	Bgt	_spend
	Sub.l	#1,d0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	d1,(a0)
	DLea	_BplPtBase,a0
	Move.l	(a0),a1
	Add.l	#2,a1
	DLea	_BitsPlanes,a0
	DLea	_Aga,a2
	Cmp.l	#0,(a2)
	Bne	_sp1
	Move.l	#11,d0		; NON AGA SCREEN.
	Bra	_spb
_sp1	Move.l	#15,d0		; AGA SCREEN.
; MISE EN PLACE DES 8 BITS PLANS DANS LE COPPER LIST AGA.
_spb	Move.w	(a0)+,(a1)
	Add.l	#4,a1
	Sub.l	#1,d0
	Bpl	_spb
_spend	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_PLANEBASE		Equ	17
L17	Move.l	#0,d3
	Move.l	(a3)+,d0
	Cmp.l	#1,d0
	Blt	_pbend
	Cmp.l	#8,d0
	Bgt	_pbend
	Sub.l	#1,d0
	Lsl.l	#2,d0
	DLea	_BitsPlanes,a0
	Add.l	d0,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	Move.l	#0,a0
_pbend  Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_COLORREAD		Equ	1
L18	Move.l	#$FFFFFFFF,d3
	Move.l	(a3)+,d0
	Cmp.l	#0,d0
	Blt	_crend
	Cmp.l	#255,d0
	Bgt	_crend
	DLea	_Aga,a0
	Cmp.l	#0,(a0)
	Bne	_cr1
	Cmp.l	#31,d0
	Bgt	_crend
_cr1	DLea	_AgaPalette,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	Move.l	#0,a0
_crend	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LINEWAIT		Equ	19
L19	DLea	_CopperBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Bne	_lwx
	Moveq	#1,d0
	Rbra	L_CUSTOM
_lwx	DLea	_CurrentLine,a2
	Move.l	(a2),a0
	DLea	_Line,a1
	Move.l	(a1),d0
	Add.l	#1,d0
	Cmp.l	#$100,d0
	Blt	_lw
	Sub.l	#$100,d0
_lw	Move.b	d0,(a0)+
	Move.b	#$01,(a0)+
	Move.w	#$FFFE,(a0)+
	Move.l	a0,(a2)
	Move.l	d0,(a1)
	DLea	_2nd,a2
	Move.l	(a2),d0
	Cmp.l	#1,d0
	Beq	_ll2
	Move.l	#$F201FFFE,(a0)+
	Move.l	#$01000000,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$F301FFFE,(a0)+
	Move.l	#$FFFFFFFE,(a0)+
_lwend	RTS
_ll2	Move.l	#$1403fffe,(a0)+
	Move.l	#$01000000,(a0)+
	Move.l	#$00960100,(a0)+
	Move.l	#$fffffffe,(a0)

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LINESEE		Equ	20
L20	DLea	_Line,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_VIEW2			Equ	21
L21	Move.l	(a3)+,d0
	DLea	_Aga,a0
	Move.l	(a0),d1
	Cmp.l	#0,d1
	Bne	_vw1
	Cmp.l	#6,d0
	Bgt	_lvend
_vw1	DLea	_CopperBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Bne	_lvx
	Moveq	#1,d0
	Rbra	L_CUSTOM
_lvx	DLea	_PlanesMask,a0
	Cmp.l	#0,d0
	Blt	_lvend
	Cmp.l	#8,d0
	Bgt	_lvend
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d0		; D0=Planes MASK
	DLea	_BplConBase,a0
	Move.l	(a0),a1
	Add.l	#2,a1
	Move.w	(a1),d1
	Bclr	#12,d1		; BPU0
	Bclr	#13,d1		; BPU1
	Bclr	#14,d1		; BPU2
	Bclr	#04,d1		; BPU3
	Or.l	d1,d0
	Move.w	d0,(a1)
_lvend	RTS	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_COLORWAIT		Equ	22
L22	DLea	_DoubleCopper,a0
	Move.l	(a3)+,d4		; D4=Bleu.
	Move.l	(a3)+,d3		; D3=Vert.
	Move.l	(a3)+,d2		; D2=Rouge.
	Move.l	(a3)+,d1		; D1=REGISTRE COULEUR.
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Bne	_cwend
	DLea	_CopperBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Bne	_cwx
	Moveq	#1,d0
	Rbra	L_CUSTOM
_cwx	Cmp.l	#0,d1
	Blt	_cwx2
	Cmp.l	#255,d1
	Bgt	_cwx2
	Lsl.l	#8,d2
	Lsl.l	#4,d3
	Add.l	d2,d4
	Add.l	d3,d4			; D4=Valeur RGB Couleur.
	Move.l	d1,d0			; D0=REGISTRE COULEUR.
	Lsr.l	#5,d1			; D1=PALETTE 0,1,2,3,4,5,6,7 ???
	DLea	_CurrentPal,a2
	Move.l	(a2),d5
	DLea	_CurrentLine,a1	; A0=Adresse COPPER LIST.
	Move.l	(a1),a0
	Cmp.l	d1,d5
	Beq	_cw2
	Move.l	d1,d5
	Move.l	d1,(a2)
	Mulu	#$2000,d1
	Add.l	#$01060000,d1
	Move.l	d1,(a0)+
_cw2	Move.l	d0,d1
	Lsr.l	#5,d1
	Lsl.l	#5,d1
	Sub.l	d1,d0
	Lsl.l	#1,d0
	Add.l	#$0180,d0
	Move.w	d0,(a0)+
	Move.w	d4,(a0)+
	DLea	_CurrentLine,a1
	Move.l	a0,(a1)
	Move.l	#$F201FFFE,(a0)+
	Move.l	#$01000000,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$F301FFFE,(a0)+
	Move.l	#$FFFFFFFE,(a0)+
_cwend	RTS
_cwx2	Moveq	#2,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SCREENSIZE		Equ	23
L23	Move.l	(a3)+,d1		; D1=Y SCREEN SIZE.
	Move.l	(a3)+,d0		; D0=X SCREEN SIZE.
	Cmp.l	#320,d0
	Bgt	_lss2
	Move.l	#320,d0
_lss2	Cmp.l	#192,d1
	Bgt	_lss3
	Move.l	#192,d1
; SAUVEGARDE DES TAILLES DANS LES REGISTRES MEMOIRE.
_lss3	DLea	_XY,a0
	Move.l	d0,(a0)+
	Move.l	d1,(a0)
; INSCRIPTION DE LA TAILLE EN X SUR LA COPPER LIST.
	DLea	_Others,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq	Llss4
	Add.l	#18,a0
	Sub.l	#320,d0
	Lsr.l	#3,d0
	Move.w	d0,(a0)
	Add.l	#4,a0
	Move.w	d0,(a0)
	Rts
Llss4	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_XSIZE			Equ	24
L24	DLea	_XY,a1
	Move.l	(a1),d3
	cmp.l	#320,d3
	Bgt	_l1
	Move.l	#320,d3
_l1	Move.l	#0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_YSIZE			Equ	25
L25	DLea	_XY,a1
	Add.l	#4,a1
	Move.l	(a1),d3
	cmp.l	#192,d3
	Bgt	_ly1
	Move.l	#192,d3
_ly1	Move.l	#0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CREATECOPPER2		Equ	26
L26	SaveRegisters
	Move.l	(a3),a0
	Cmp.l	#0,a0
	Bne	_ccz
	Moveq	#0,d0
	Rbra	L_CUSTOM
; SAUVEGARDE DE L'ADRESSE DE BASE DU COPPER-LIST A CREER.
_ccz	DLea	_CopperBase,a1
	Move.l	a0,(a1)
; COP WAIT ...
	Move.l	#$1003FFFE,(a0)+
	Move.l	#$01fc0000,(a0)+	; Anti Double Scanning.
; CREATION DES SPRITES POUR LE COPPER-LIST.
	DLea	_SprPtBase,a1
	Move.l	a0,(a1)
	Move.l	#$01200000,d0
_cd1	Move.l	d0,(a0)+
	Add.l	#$20000,d0
	Cmp.l	#$01400000,d0
	Bne	_cd1
; CREATION DE LA PALETTE DE 256 COULEURS AGA SEULEMENT !!!
	Move.l	#$1803FFFE,(a0)+
;	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	DLea	_ColorBase,a1
	Move.l	a0,(a1)
; SELECTION DU BLOC MEMOIRE.
	Move.l	#$01800000,d1
; BLOCS DE 32 COULEURS A CODER SEPAREMENT.
_cf3	Move.l	d1,(a0)+
	Add.l	#$00020000,d1
	Cmp.l	#$01C00000,d1
	Bne	_cf3	
; CREATION DE L'ECRAN.
	Move.l	#$3103FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	DLea	_BplPtBase,a1
	Move.l	a0,(a1)
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
_cd4	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	_cd4
;		OTHERS REGISTERS.
	DLea	_Others,a1
	Move.l	a0,(a1)
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
	DLea	_BplConBase,a1
	Move.l	a0,(a1)
;		BPLCON REGISTERS.
	Move.l	#$01001000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040024,(a0)+	; BPLCON2
	Move.l	#$01060c00,(a0)+	; BPLCON3=$c00 For 2nd field PAL.
;
	Move.l	#$3203FFFE,(a0)+
	Move.l	#$00968300,(a0)+
	DLea	_CurrentLine,a1
	Move.l	a0,(a1)
	Move.l	#$F203FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$F303FFFE,(a0)+
	Move.l	#$01060000,(a0)+	; BPLCON3 Default For AMOS BACK.
	Move.l	#$FFFFFFFE,(a0)+
	DLea	_Line,a1
	Move.l	#$32,(a1)
	DLea	_Aga,a1
	Move.l	#$0,(a1)	; NONAGA SCREEN.
	DLea	_2nd,a1
	Move.l	#0,(a1)
	LoadRegisters
	Add.l	#4,a3		; 1 donnee lue !!!
	Move.l	#0,d3		; Copper cree normalement .
	Rts
_NoCopper2
	DLea	_Line,a1
	Move.l	#$32,(a1)
	LoadRegisters
	Move.l	#$ffffffff,d3	; Copper non cree !!!
	Add.l	#4,a3		; 1 donnee lue !!!
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SCREENOFFSET		Equ	27
L27	Move.l	(a3)+,d1	; D1=Y Offset.
	Move.l	(a3)+,d0	; D0=X Offset.
	Move.l	(a3)+,d4	; D4=Offset Type 1=Sc1 2=Sc2 0=No dual pf
	DLea	_D4,a0
	Move.l	d4,(a0)
	DLea	_XYOff,a0
	Cmp.l	#1,d4
	Beq	_Scrn1
	Cmp.l	#2,d4
	Beq	_Scrn2
_Scrn0	Move.l	d0,(a0)+
	Move.l	d1,(a0)+
	Move.l	d0,(a0)+
	Move.l	d1,(a0)
	Bra	_S3
_Scrn1	Move.l	d0,(a0)+
	Move.l	d1,(a0)
	Bra	_S3
_Scrn2	Add.l	#8,a0
	Move.l	d0,(a0)+
	Move.l	d1,(a0)
_S3	DLea	_XYOff,a0
	Move.l	(a0)+,d0	; D0=X Offset #1.=D4
	Move.l	(a0)+,d2	; D1=X Offset #2.=D5
	Move.l	(a0)+,d1	; D2=Y Offset #1.
	Move.l	(a0),d3		; D3=Y Offset #2.
	DLea	_XY,a0
	Move.l	(a0),d7		; D7=X Screen Size.
	Lsr.l	#3,d7		; D7=X Bytes Screen Size.
	Mulu	d7,d2
	Mulu	d7,d3
	Move.l	d0,d4
	Move.l	d1,d5
	Lsr.l	#4,d4
	Lsr.l	#4,d5
	Lsl.l	#1,d4
	Lsl.l	#1,d5
	Add.l	d4,d2		; D2=Bytes to add #1.
	Add.l	d5,d3		; D3=Bytes to add #2.
	Lsl.l	#3,d4
	Lsl.l	#3,d5
	Sub.l	d4,d0
	Sub.l	d5,d1
	Move.l	#16,d4
	Move.l	#16,d5
	Sub.l	d0,d4
	Sub.l	d1,d5
	Cmp.l	#16,d4
	Bne	_S3a
	Move.l	#0,d4
_S3a	Cmp.l	#16,d5
	Bne	_S3b
	Move.l	#0,d5
_S3b	Lsl.l	#4,d5
	Move.l	d5,d6
	Add.l	d4,d5		; D5=BPLCON1 NEW VALUE.
; calcul desnouveaux bits plans.
	DLea	_BitsPlanes,a0
	DLea	_BitsPlanes2,a1
	Cmp.l	#0,(a0)
	Beq	xxw
	Move.l	#3,d7
_S3c	Move.l	(a0)+,d0
	Move.l	(a0)+,d1
	Add.l	d2,d0
; Added in case of no DUAL PLAYFIELD.
	DLea	_D4,a2
	Cmp.b	#0,d4
	Bne	_s3cc
	Cmp.l	#0,(a2)
	Beq	_s3cc
	Sub.l	#2,d0
_s3cc	Add.l	d3,d1
	Cmp.b	#0,d6
	Bne	_s3cd
	Cmp.l	#0,(a2)
	Beq	_s3cd
	Sub.l	#2,d1
_s3cd	Move.l	d0,(a1)+
	Move.l	d1,(a1)+
	Sub.l	#1,d7
	Bpl	_S3c
; Placement des bits plans dans la copper liste.
	DLea	_BitsPlanes2,a0
	DLea	_BplPtBase,a2
	Move.l	(a2),a1
	Add.l	#2,a1
	Move.l	#15,d0
_S3d	Move.w	(a0)+,(a1)
	Add.l	#4,a1
	Sub.l	#1,d0
	Bpl	_S3d
; calcul si valeur scrolling=0 ou<>0
	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Add.l	#6,a0
	Move.w	d5,(a0)
	Cmp.w	#0,d5
	Bne	_Unequ
_Equ	DLea	_Others,a2
	Move.l	(a2),a0
	Add.l	#10,a0
	Move.w	#$38,(a0)
	Add.l	#8,a0
	DLea	_XY,a1
	Move.l	(a1),d0
	Sub.l	#320,d0
	Lsr.l	#3,d0
	Move.w	d0,(a0)
	Add.l	#4,a0
	Move.w	d0,(a0)
	Bra	_eend
;
_Unequ	DLea	_Others,a2
	Move.l	(a2),a0
	Add.l	#10,a0
	Move.w	#$30,(a0)
	Add.l	#8,a0
	DLea	_XY,a1
	Move.l	(a1),d0
	Sub.l	#320,d0
	Lsr.l	#3,d0
	Sub.l	#2,d0
	Move.w	d0,(a0)
	Add.l	#4,a0
	Move.w	d0,(a0)
_eend	RTS
xxw	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_DUALPLAYFIELD		Equ	28
L28	Move.l	(a3)+,d2
	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_dpx
	Add.l	#2,a0
	Move.w	(a0),d0
	Cmp.l	#0,d2
	Bne	_Dual
	BClr	#10,d0
	Bra	_Dpend
_Dual	Bset	#10,d0
_Dpend	Move.w	d0,(a0)
	Rts
_dpx	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_RESOLUTION		Equ	29
L29	Move.l	(a3)+,d2
	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_rx
	Add.l	#2,a0
	Move.w	(a0),d0
	Cmp.l	#0,d2
	Beq	_Low
_High	Bset	#15,d0
	Bra	_Rend
_Low	Bclr	#15,d0
_Rend	Move.w	d0,(a0)
	RTS
_rx	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SETLACE		Equ	30
L30	Move.l	(a3)+,d2
	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_lsq
	Add.l	#2,a0
	Move.w	(a0),d0
	Cmp.l	#0,d2
	Beq	_Nolace
_Lace	Bset	#2,d0
	Bra	_lend
_Nolace	Bclr	#2,d0
_lend	Move.w	d0,(a0)
	Rts
_lsq	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_COPPERLINE2		Equ	31
L31	DLea	_Line,a0
	Move.l	(a3)+,d0
	DLea	_DoubleCopper,a1
	Move.l	(a1),d1
	Cmp.l	#0,d1
	Bne	_clend
	Move.l	d0,(a0)
	DLea	_CurrentLine,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	_clw
	Move.b	d0,(a1)+
	Move.b	#$03,(a1)+
	Move.w	#$FFFE,(a1)+
	Move.l	a1,(a0)
	DLea	_2nd,a2
	Move.l	(a2),d0
	Cmp.l	#1,d0
	Beq	_ll3
	Move.l	#$F201FFFE,(a1)+
	Move.l	#$01000000,(a1)+
	Move.l	#$00960100,(a1)+	; DMACON Pour l'amos ?!?
	Move.l	#$F301FFFE,(a1)+
	Move.l	#$FFFFFFFE,(a1)+
_clend	RTS
_ll3	Move.l	#$1403fffe,(a1)+
	Move.l	#$01000000,(a1)+
	Move.l	#$00960100,(a1)+
	Move.l	#$fffffffe,(a1)
	Rts
_clw	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx2		Equ	32
L32	SaveRegisters
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d0		; D0=Screen Base.
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_m1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_m1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#1,d7
	Lsl.l	#1,d7	; D7 Paire
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_m2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_m3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$AAAAAAAA,d2		; D2=Masque 
	And.l	d0,d2
	Move.l	d2,d0
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Move.l	d0,(a1)+
	Move.l	d0,(a2)+
	Cmp.l	a1,a3
	Bne	_m3
; UNE LIGNE TERMINEE.
	Add.l	d3,a1		; A1 = A1 + 1 Ligne.
	Add.l	d3,a2		; A2 = A2 + 1 Ligne.
	Add.l	d3,a3
	Add.l	d3,a3		; A3 = A3 + 2 Lignes. !!!
	Add.l	#2,d1
	Cmp.l	d1,d7
	Bne	_m3
	Bra	_m2
_mend	LoadRegisters
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx4		Equ	33
L33	SaveRegisters
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d0		; D0=Screen Base.
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_mb1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_mb1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#2,d7
	Lsl.l	#2,d7	; D7 Multiple de 4
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_mb2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mbend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_mb3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$88888888,d2		; D2=Masque 
	And.l	d0,d2
	Move.l	d2,d0
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Move.l	d0,(a1)+
	Move.l	d0,(a2)
	Add.l	d3,a2
	Move.l	d0,(a2)
	Add.l	d3,a2
	Move.l	d0,(a2)+
	Sub.l	d3,a2
	Sub.l	d3,a2
	Cmp.l	a1,a3
	Bne	_mb3
; UNE LIGNE TERMINEE.
	add.l	d3,a1
	Add.l	d3,a2
	Lsl.l	#1,d3
	Add.l	d3,a1		; A1 = A1 + 3 Ligne.
	Add.l	d3,a2		; A2 = A2 + 3 Ligne.
	Add.l	d3,a3
	Add.l	d3,a3		; A3 = A3 + 4 Lignes. !!!
	Lsr.l	#1,d3
	Add.l	#4,d1
	Cmp.l	d1,d7
	Bne	_mb3
	Bra	_mb2
_mbend	LoadRegisters
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_Mosaicx8		Equ	34
L34	SaveRegisters
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d0		; D0=Screen Base.
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_mc1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_mc1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#3,d7
	Lsl.l	#3,d7	; D7 Multiple de 4
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_mc2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mcend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_mc3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$80808080,d2		; D2=Masque.
	And.l	d0,d2
	Move.l	d2,d0
	Move.l	#7,d4
_mcw	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mcw
	Move.l	d0,(a1)+
	Move.l	#6,d4
_mcx	Move.l	d0,(a2)
	Add.l	d3,a2
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mcx
	Move.l	d0,(a2)+
	Mulu	#6,d3
	Sub.l	d3,a2
	Divu	#6,d3
	Cmp.l	a1,a3
	Bne	_mc3
; UNE LIGNE TERMINEE.
	Mulu	#7,d3
	Add.l	d3,a1
	Add.l	d3,a2
	Add.l	d3,a3
	Divu	#7,d3
	Add.l	d3,a3	; A3=1 ligne de plus que les autres (a1,a2)
	Add.l	#8,d1
	Cmp.l	d1,d7
	Bne	_mc3
	Bra	_mc2
_mcend	LoadRegisters
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_Mosaicx16		Equ	35
L35	SaveRegisters
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d0		; D0=Screen Base.
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_md1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_md1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#4,d7
	Lsl.l	#4,d7	; D7 Multiple de 4
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_md2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mdend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_md3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$80008000,d2		; D2=Masque.
	And.l	d0,d2
	Move.l	d2,d0
	Move.l	#15,d4
_mdw	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mdw
	Move.l	d0,(a1)+
	Move.l	#14,d4
_mdx	Move.l	d0,(a2)
	Add.l	d3,a2
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mdx
	Move.l	d0,(a2)+
	Mulu	#14,d3
	Sub.l	d3,a2
	Divu	#14,d3
	Cmp.l	a1,a3
	Bne	_md3
; UNE LIGNE TERMINEE.
	Mulu	#15,d3
	Add.l	d3,a1
	Add.l	d3,a2
	Add.l	d3,a3
	Divu	#15,d3
	Add.l	d3,a3	; A3=1 ligne de plus que les autres (a1,a2)
	Add.l	#16,d1
	Cmp.l	d1,d7
	Bne	_md3
	Bra	_md2
_mdend	LoadRegisters
	Add.l	#4,a3
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx32		Equ	36
L36	SaveRegisters
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d0		; D0=Screen Base.
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_me1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_me1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#5,d7
	Lsl.l	#5,d7	; D7 Multiple de 32
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_me2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_meend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_me3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$80000000,d2		; D2=Masque.
	And.l	d0,d2
	Move.l	d2,d0
	Move.l	#31,d4
_mew	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mew
	Move.l	d0,(a1)+
	Move.l	#30,d4
_mex	Move.l	d0,(a2)
	Add.l	d3,a2
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mex
	Move.l	d0,(a2)+
	Mulu	#30,d3
	Sub.l	d3,a2
	Divu	#30,d3
	Cmp.l	a1,a3
	Bne	_me3
; UNE LIGNE TERMINEE.
	Mulu	#31,d3
	Add.l	d3,a1
	Add.l	d3,a2
	Add.l	d3,a3
	Divu	#31,d3
	Add.l	d3,a3	; A3=1 ligne de plus que les autres (a1,a2)
	Add.l	#32,d1
	Cmp.l	d1,d7
	Bne	_me3
	Bra	_me2
_meend	LoadRegisters
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ACTIVECOP		Equ	37
L37	DLea	_CopperBase,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq	_acx
	Move.l	d0,$dff080
	Rts
_acx	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SETHAMMODE		Equ	38
L38	Move.l	(a3)+,d0
	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_shm
	Add.l	#2,a0
	Move.w	(a0),d1
	Cmp.l	#0,d0
	Bne	_Set
_Unset	Bclr	#11,d1
	Bra	_rp
_Set	Bset	#11,d1
_rp	Move.w	d1,(a0)
	RTS
_shm	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_IFFTOSCREEN		Equ	39
L39	DLea	_IffBase,a0
	Move.l	(a3)+,(a0)
; Find BMHD Header
	DLea	_IffBase,a0
	Move.l	(a0),a2
;	Bclr	#0,a2
	Move.l	#16384,d0
	Move.l	a2,a0
_bm	Move.l	(a0),d1
	Cmp.l	#"BMHD",d1
	Beq	_bm2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne	_bm
	Bra	_its		; BMHD Non trouve !!!
_bm2	Add.l	#4,a0
	DLea	_Bmhd,a1
	Move.l	a0,(a1)
; Find CMAP Header
	Move.l	#16384,d0
	Move.l	a2,a0
_cm	Move.l	(a0),d1
	Cmp.l	#"CMAP",d1
	Beq	_cm2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne	_cm
	Bra	_its		; CMAP Non trouve !!!
_cm2	Add.l	#4,a0
	DLea	_Cmap,a1
	Move.l	a0,(a1)
; Find BODY Header
	Move.l	#16384,d0
	Move.l	a2,a0
_bo	Move.l	(a0),d1
	Cmp.l	#"BODY",d1
	Beq	_bo2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne	_bo
	Bra	_its		; CMAP Non trouve !!!
_bo2	Add.l	#4,a0
	DLea	_Body,a1
	Move.l	a0,(a1)
	DLea	_Bmhd,a2
	Move.l	(a2),a0
	Add.l	#4,a0
	Clr.l	d0
	Move.w	(a0)+,d0
	Clr.l	d1
	Move.w	(a0),d1
	DLea	_Bmhd,a2
	Move.l	(a2),a0
	Add.l	#12,a0
	Clr.l	d7
	Move.b	(a0),d7
	DLea	_LbmXs,a0
	Move.l	d0,(a0)
	DLea	_LbmYs,a0
	Move.l	d1,(a0)
	DLea	_LbmDp,a0
	Move.l	d7,(a0)
	DLea	_BitsPlanes,a0
	Sub.l	#1,d7
	Lsl.l	#2,d7
	Add.l	d7,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq	_its
; Copier les _bitsPlanes: dans _BitsPlanes3:
	DLea	_BitsPlanes,a0
	DLea	_BitsPlanes3,a1
	Move.l	#7,d0
_bp	Move.l	(a0)+,(a1)+
	Sub.l	#1,d0
	Bpl	_bp
;
; CONVERTION ILBM TO AMOS COPPER DEFINED SCREEN V1.0
;
_TRACE
; A3 Replaced by A2. Two lines.
	DLea	_Body,a2
	Move.l	(a2),a0
	Add.l	#4,a0
;   For D0=1 To _YSIZE
	Move.l	#1,d0
_01
;      For d1=0 To _NBPL-1
	Move.l	#0,d1
_02
;         For d2=1 To(_XSIZE/8)
	Move.l	#1,d2
_03
;            D3=Peek(A0)
	Clr.l	d3
	Move.b	(a0),d3
;            Add a0,1
	Add.l	#1,a0
;            D4=Peek(A0)
	Move.b	(a0),d4
;            Add A0,1
	Add.l	#1,a0
;            If D3>$80 Then Goto _COMPRESSED
	Cmp.l	#$80,d3
	Bgt	_COMPRESSED
_NOCOMPRESSION
;            Dec A0
	Sub.l	#1,a0
;            For D5=0 To D3
	Move.l	#0,d5
_04
;               Poke _BPL(d1),Peek(A0)
	Move.l	d1,d7
	Lsl.l	#2,d7
	DLea	_BitsPlanes3,a1
	Add.l	d7,a1
	Move.l	(a1),a2
	Move.b	(a0),(a2)
;               Inc _BPL(d1)
	Add.l	#1,a2
	Move.l	a2,(a1)
;               Inc A0
	Add.l	#1,a0
;              Next D5
	Add.l	#1,d5
	Move.l	d3,d7
	Add.l	#1,d7
	Cmp.l	d7,d5
	Bne	_04
;            D2=D2+D3
	Add.l	d3,d2
;            Goto _CONTINUE
	Bra	_CONTINUE

_COMPRESSED:
;               D5=(257-D3)
	Move.l	#257,d5
	Sub.l	d3,d5
;               If D5>(_XSIZE/8) Then Bell : Goto _END
; A3 Replaced by A1. Two lines.
	DLea	_LbmXs,a1
	Move.l	(a1),d7
	Lsr.l	#3,d7
	Cmp.l	d7,d5
	Bgt	_END
;               For D6=1 To D5
	Move.l	#1,d6
_05
;                  Poke _BPL(d1),D4
	DLea	_BitsPlanes3,a1
	Move.l	d1,d7
	Lsl.l	#2,d7
	Add.l	d7,a1
	Move.l	(a1),a2
	Move.b	d4,(a2)
;                  Inc _BPL(d1)
	Add.l	#1,a2
	Move.l	a2,(a1)
;                 Next D6
	Add.l	#1,d6
	Move.l	d5,d7
	Add.l	#1,d7
	Cmp.l	d7,d6
	Bne	_05
;               D2=D2+(D5-1)
	Add.l	d5,d2
	Sub.l	#1,d2
_CONTINUE
;           Next D2
	Add.l	#1,d2
; A3 Replaced by A1. Two lines.
	DLea	_LbmXs,a1
	Move.l	(a1),d7
	Lsr.l	#3,d7
	Add.l	#1,d7
	Cmp.l	d7,d2
	Bne	_03
;        Next D1
	Add.l	#1,d1
; A3 Replaced by A1. Two lines.
	DLea	_LbmDp,a1
	Move.l	(a1),d7
	Cmp.l	d7,d1
	Bne	_02
;     Next D0
	Add.l	#1,d0
; A3 Replaced by A1. Two lines.
	DLea	_LbmYs,a1
	Move.l	(a1),d7
	Add.l	#1,d7
	Cmp.l	d7,d0
	Bne	_01
_END
; FIN DE LA CONVERTION.
_its	Move.l	#0,a0
	Move.l	#0,d2
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ALLOWPLANES		Equ	40
L40	Move.l	(a3)+,d0
	DLea	_Others,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	Apx
	Add.l	#26,a0
	DLea	_BPlanesMask,a1
	Cmp.l	#1,d0
	Blt	_ap
	Cmp.l	#6,d0
	Bgt	_ap
	Bset	d0,(a1)
	Lsl.l	#6,d0
	Move.w	(a0),d1
	Bset	d0,d1
	Move.w	d1,(a0)
_ap	RTS
Apx	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_FORBIDPLANES		Equ	41
L41	Move.l	(a3)+,d0
	DLea	_Others,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	fb
	Add.l	#26,a0
	DLea	_BPlanesMask,a1
	Cmp.l	#1,d0
	Blt	_fp
	Cmp.l	#6,d0
	Bgt	_fp
	Bclr	d0,(a1)
	Lsl.l	#6,d0
	Move.w	(a0),d1
	Bclr	d0,d1
	Move.w	d1,(a0)
_fp	RTS
fb	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_RESERVEDPF		Equ	42
L42	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	Apy
	Add.l	#10,a0
	Move.w	(a0),d0
	Bset	#6,d0
	Move.w	d0,(a0)
	RTS
Apy	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_NORMALDPF		Equ	43
L43	DLea	_BplConBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	Apz
	Add.l	#10,a0
	Move.w	(a0),d0
	Bclr	#6,d0
	Move.w	d0,(a0)
	RTS
Apz	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CHECKCOL		Equ	44
L44	Move.l	(a3)+,d1
	Move.l	(a3)+,d0
	Bclr	#0,d0		; SPRITE #1 Pair
	Bclr	#0,d1		; SPRITE #2 Pair
	Cmp.l	d0,d1
	Beq	_cc	; NO COLLISION FOR COMPLEMENTED SPRITES.
	Lsl.l	#4,d0
	Or.l	d1,d0
	Cmp.l	#$02,d0
	Bne	_cz1
	Move.l	#9,d2
_cz1	Cmp.l	#$04,d0
	Bne	_c2
	Move.l	#10,d2
_c2	Cmp.l	#$06,d0
	Bne	_c3
	Move.l	#11,d2
_c3	Cmp.l	#$24,d0
	Bne	_c4
	Move.l	#12,d2
_c4	Cmp.l	#$26,d0
	Bne	_c5
	Move.l	#13,d2
_c5	Cmp.l	#$46,d0
	Bne	_c6
	Move.l	#14,d2
_c6	Move.w	$DFF00E,d4
	Move.l	#0,d3
	Btst	d2,d4
	Bne	_cc
	Move.l	#$ffffffff,d3
_cc	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CHECKCOL2		Equ	45
L45	Move.w	$DFF00E,d0
	Move.l	#0,d3
	Btst	#0,d0
	Bne	_c21
	Move.l	#$FFFFFFFF,d3
_c21	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CHECKCOL3		Equ	46
L46	Move.l	(a3)+,d1		; SPR1
	Move.l	(a3)+,d0		; PF
	Lsl.l	#4,d0
	Or.l	d1,d0
	Cmp.l	#$10,d0
	Bne	_c31
	Move.l	#1,d2
_c31	Cmp.l	#$12,d0
	Bne	_c32
	Move.l	#2,d2
_c32	Cmp.l	#$14,d0
	Bne	_c33
	Move.l	#3,d2
_c33	Cmp.l	#$16,d0
	Bne	_c34
	Move.l	#4,d2
_c34	Cmp.l	#$20,d0
	Bne	_c35
	Move.l	#5,d2
_c35	Cmp.l	#$22,d0
	Bne	_c36
	Move.l	#6,d2
_c36	Cmp.l	#$24,d0
	Bne	_c37
	Move.l	#7,d2
_c37	Cmp.l	#$26,d0
	Bne	_c38
	Move.l	#8,d2
_c38	Move.w	$DFF00E,d4
	Move.l	#0,d3
	Btst	d2,d4
	Bne	_ce
	Move.l	#$FFFFFFFF,d3
_ce	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_COS1000		Equ	47
L47	Move.l	(a3)+,d0
	Cmp.l	#0,d0
	Blt	_CInfA0
	Cmp.l	#359,d0
	Bgt	_CSupA359
	Bra	_CCcl
_CInfA0	Move.l	d0,d1
	Divu	#360,d1
	Mulu	#360,d1
	Sub.l	d1,d0
	Not	D0
	Add.l	#1,d0
	Bra	_CCcl
_CSupA359
	Move.l	d0,d1
	Divu	#360,d1
	Mulu	#360,d1
	Sub.l	d1,d0
_CCcl	DLea	_Cosinus,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SIN1000		Equ	48
L48	Move.l	(a3)+,d0
	Cmp.l	#0,d0
	Blt	_SInfA0
	Cmp.l	#359,d0
	Bgt	_SSupA359
	Bra	_SCcl
_SInfA0	Move.l	d0,d1
	Divu	#360,d1
	Mulu	#360,d1
	Sub.l	d1,d0
	Not	D0
	Add.l	#1,d0
	Bra	_SCcl
_SSupA359
	Move.l	d0,d1
	Divu	#360,d1
	Mulu	#360,d1
	Sub.l	d1,d0
_SCcl	DLea	_Sinus,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_TAN1000		Equ	49
L49	Move.l	(a3)+,d0
	Cmp.l	#0,d0
	Blt	_TInfA0
	Cmp.l	#359,d0
	Bgt	_TSupA359
	Bra	_TCcl
_TInfA0	Move.l	d0,d1
	Divu	#360,d1
	Mulu	#360,d1
	Sub.l	d1,d0
	Not	D0
	Add.l	#1,d0
	Bra	_TCcl
_TSupA359
	Move.l	d0,d1
	Divu	#360,d1
	Mulu	#360,d1
	Sub.l	d1,d0
_TCcl	DLea	_Tangente,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d3
	Move.l	#0,d2
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_IFFXSize		Equ	50
L50	Move.l	(a3)+,a0
	Move.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_xs0	Move.l	(a0),d6
	Cmp.l	#"BMHD",d6
	Beq	_xs1
	Add.l	#2,a0
	Sub.l	#1,d7
	Cmp.l	#0,d7
	Beq	_Xsend
	Bra	_xs0
_xs1	Add.l	#4,a0
	Add.l	#4,a0
	Clr.l	d3
	Move.w	(a0),d3
	RTS
_Xsend	Moveq	#3,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_IFFYSize		Equ	51
L51	Move.l	(a3)+,a0
	Move.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_ys0	Move.l	(a0),d6
	Cmp.l	#"BMHD",d6
	Beq	_ys1
	Add.l	#2,a0
	Sub.l	#1,d7
	Cmp.l	#0,d7
	Beq	_Ysend
	Bra	_ys0
_ys1	Add.l	#4,a0
	Add.l	#6,a0
	Clr.l	d3
	Move.w	(a0),d3
	RTS
_Ysend	Moveq	#3,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_IFFDepth		Equ	52
L52	Move.l	(a3)+,a0
	Move.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_ds0	Move.l	(a0),d6
	Cmp.l	#"BMHD",d6
	Beq	_ds1
	Add.l	#2,a0
	Sub.l	#1,d7
	Cmp.l	#0,d7
	Beq	_Dsend
	Bra	_ds0
_ds1	Add.l	#4,a0
	Add.l	#12,a0
	Clr.l	d3
	Move.b	(a0),d3
	RTS
_Dsend	Moveq	#3,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_DoubleMASK		Equ	53
L53	Move.l	(a3)+,d7	; D7=Screen 2 Base.
	Move.l	(a3)+,d6	; D6=Screen 1 Base.
	Move.l	(a3)+,d5	; D5=Mask Base 1 Bit plan.
	Cmp.l	#0,d5
	Beq	Ldp
	Cmp.l	#0,d6
	Beq	Ldp
	Cmp.l	#0,d7
	Beq	Ldp
; SAUVEGARDE DE D3.
	DLea	Registers,a0
	Move.l	a3,(a0)
; LECTURE DE LA LONGUEUR D'UN BIT PLAN.
	Move.l	d5,a0
	Add.l	#76,a0
	Clr.l	d0
	Move.w	(a0),d0
	Clr.l	d1
	Add.l	#2,a0
	Move.w	(a0),d1
	Lsr.l	#3,d0
	Mulu	d0,d1
	DLea	_MLen,a0
	Move.l	d1,(a0)
; SAUVEGARDE DE L'ADRESSE DU BIT PLAN MASK.
	DLea	_MaskBase,a0
	Move.l	d5,a1
	Move.l	(a1),(a0)
; MISE A ZERO DES 8 BITS PLANS.
	Move.l	#7,d0
	DLea	_BitsPlanes2,a0
	DLea	_BitsPlanes3,a1
_dm1	Move.l	#0,(a0)+
	Move.l	#0,(a1)+
	Sub.l	#1,d0
	Bpl	_dm1
; LECTURE DES 6 BITS PLANS MAXIMUM.
	DLea	_BitsPlanes2,a2
	DLea	_BitsPlanes3,a3
	Move.l	d6,a0
	Move.l	d7,a1
	Move.l	#5,d0
_dm2	Move.l	(a0)+,(a2)+
	Move.l	(a1)+,(a3)+
	Sub.l	#1,d0
	Bpl	_dm2
; INITIALISATIONS DE LA ROUTINE DE CALCUL.
	Move.l	#0,d0			; D0=CURRENT BIT PLANE.
_Dm4	DLea	_MLen,a0
	Move.l	(a0),d1			; D1=BIT PLANES LENGTH.
	Lsr.l	#2,d1			; '' '' '' en #.L   .
	Sub.l	#1,d1
	DLea	_BitsPlanes2,a2
	DLea	_BitsPlanes3,a3
	Add.l	d0,a2
	Add.l	d0,a3
	Move.l	(a2),a0			; A0=Cur BIT PLANE BASE SCREEN 1.
	Move.l	(a3),a1			; A1=Cur BIT PLANE BASE SCREEN 2.
	Cmp.l	#0,a0
	Beq	_Dm5
	Cmp.l	#0,a1
	Beq	_Dm5
	DLea	_MaskBase,a3
	Move.l	(a3),a2			; A2=BITS PLANE BASE MASK.
; ROUTINE DE CALCUL.
_dm3	Move.l	(a2)+,d4	; D4=DONNEE MASQUE.
	Move.l	d4,d5
	Not.l	d5		; D5=MASQUE INVERSE.
	And.l	(a0)+,d4	; (a0)=Donnee Ecran 1 BACKGround.
	And.l	(a1),d5		; (a1)=Donnee Ecran 2 FOREGround.
	Or.l	d4,d5
	Move.l	d5,(a1)+
	Sub.l	#1,d1
	Bpl	_dm3
	Add.l	#4,d0
	Bra	_Dm4
; RAPPEL DE A3.
_Dm5	DLea	Registers,a0
	Move.l	(a0),a3
	Rts
Ldp	Moveq	#4,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_DoubleMASK2		Equ	54
L54	Move.l	(a3)+,d7	; D7=Screen 2 Base.
	Move.l	(a3)+,d6	; D6=Screen 1 Base.
	Move.l	(a3)+,d4	; D4=YEnd.
	Move.l	(a3)+,d3	; D3=YStart.
	Move.l	(a3)+,d5	; D5=Mask Base 1 Bit plan.
	Cmp.l	#0,d5
	Beq	Dmw
	Cmp.l	#0,d6
	Beq	Dmw
	Cmp.l	#0,d7
	Beq	Dmw
; SAUVEGARDE DE D3.
	DLea	Registers,a0
	Move.l	a3,(a0)
; LECTURE DE LA LONGUEUR D'UN BIT PLAN.
	Move.l	d5,a0
	Add.l	#76,a0
	Clr.l	d0
	Move.w	(a0),d0		; D0=XSize
	Clr.l	d1
	Sub.l	d3,d4
	Add.l	#2,a0
	Move.w	d4,d1
	Lsr.l	#3,d0
	Mulu	d0,d1
	DLea	_MLen,a0
	Move.l	d1,(a0)
	Mulu	d0,d3
; SAUVEGARDE DE L'ADRESSE DU BIT PLAN MASK.
	DLea	_MaskBase,a0
	Move.l	d5,a1
	Move.l	(a1),d4
	Add.l	d3,d4
	Move.l	d4,(a0)
; MISE A ZERO DES 8 BITS PLANS.
	Move.l	#7,d0
	DLea	_BitsPlanes2,a0
	DLea	_BitsPlanes3,a1
_dn1	Move.l	#0,(a0)+
	Move.l	#0,(a1)+
	Sub.l	#1,d0
	Bpl	_dn1
; LECTURE DES 6 BITS PLANS MAXIMUM.
	DLea	_BitsPlanes2,a2
	DLea	_BitsPlanes3,a3
	Move.l	d6,a0
	Move.l	d7,a1
	Move.l	#5,d0
_dn2	Move.l	(a0)+,d4
	Cmp.l	#0,d4
	Beq	_dn6
	Add.l	d3,d4
_dn6	Move.l	d4,(a2)+
	Move.l	(a1)+,d4
	Cmp.l	#0,d4
	Beq	_dn7
	Add.l	d3,d4
_dn7	Move.l	d4,(a3)+
	Sub.l	#1,d0
	Bpl	_dn2
; INITIALISATIONS DE LA ROUTINE DE CALCUL.
	Move.l	#0,d0			; D0=CURRENT BIT PLANE.
_Dn4	DLea	_MLen,a0
	Move.l	(a0),d1			; D1=BIT PLANES LENGTH.
	Lsr.l	#2,d1			; '' '' '' en #.L   .
	Sub.l	#1,d1
	DLea	_BitsPlanes2,a2
	DLea	_BitsPlanes3,a3
	Add.l	d0,a2
	Add.l	d0,a3
	Move.l	(a2),a0			; A0=Cur BIT PLANE BASE SCREEN 1.
	Move.l	(a3),a1			; A1=Cur BIT PLANE BASE SCREEN 2.
	Cmp.l	#0,a0
	Beq	_Dn5
	Cmp.l	#0,a1
	Beq	_Dn5
	DLea	_MaskBase,a3
	Move.l	(a3),a2			; A2=BITS PLANE BASE MASK.
; ROUTINE DE CALCUL.
_dn3	Move.l	(a2)+,d4	; D4=DONNEE MASQUE.
	Move.l	d4,d5
	Not.l	d5		; D5=MASQUE INVERSE.
	And.l	(a0)+,d4	; (a0)=Donnee Ecran 1 BACKGround.
	And.l	(a1),d5		; (a1)=Donnee Ecran 2 FOREGround.
	Or.l	d4,d5
	Move.l	d5,(a1)+
	Sub.l	#1,d1
	Bpl	_dn3
	Add.l	#4,d0
	Bra	_Dn4
; RAPPEL DE A3.
_Dn5	DLea	Registers,a0
	Move.l	(a0),a3
	Rts
Dmw	Moveq	#4,d0
	Rbsr	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_RESERVESPRITE		Equ	55
L55	Move.l	(a3)+,d7	; D7=Length.
	Move.l	(a3)+,d6	; D6=Base.
	Cmp.l	#8192,d7	; 8K Minimum to reserve.
	Blt	_Rsend
	DLea	_SpriteBase,a0
	Move.l	d6,(a0)
	DLea	_SpriteLength,a1
	Move.l	d7,(a1)
	Rts
_Rsend	Moveq	#5,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_GETEVENSPRITE		Equ	56
L56	Move.l	(a3)+,d7	; D7=LONGUEUR EN LIGNES DU SPRITE !!!
	Move.l	(a3)+,d6	; D6=Y position.
	Move.l	(a3)+,d5	; D5=X Pos.
	Lsr.l	#3,d5		; D5=X Position en octets.
	Move.l	(a3)+,d4	; D4=NUMERO DU SPRITE !!!.
	Move.l	(a3)+,a0	; A0=SCREEN BASE.
	Move.l	(a0)+,a1	; A1=Bit Plane 1 Pointer.
	Move.l	(a0)+,a2	; A2=Bit Plane 2 Pointer.
	Add.l	#$6e,a0			; #$00000076-#$00000008 .
	Clr.l	d0
	Move.w	(a0)+,d0	; D0=X Screen Size.
	Lsr.l	#3,d0		; D0=LONGUEUR D'UNE LIGNE A L'AUTRE !!!
	Move.w	(a0)+,d1	; D1=Y Screen Size.
	Mulu	d0,d6
	Add.l	d5,d6		; D6=1er mot du sprite !!!
	Add.l	d6,a1		; A1=ADRESSE DU 1ER  PLAN.
	Add.l	d6,a2		; A2=ADRESSE DU 2EME PLAN.
	DLea	_SpriteBase,a0
	Move.l	a0,d1
	Move.l	d1,a0		; A0=Adresse de base des sprites.
	Mulu	#520,d4		; 516=Longueur 1 Sprite de 16*128*2bp.
	Add.l	d4,a0
; CREATION DU SPRITE !!!
	Move.l	d7,d6		; D6=Longueur.
; Header du sprite
	Move.w	#$0000,(a0)+
	Move.b	d7,(a0)+
	Move.b	#$00,(a0)+
; Sprite datas.
_gsbcl	Move.l	(a1),(a0)+
	Move.l	(a2),(a0)+
	Add.l	d0,a1
	Add.l	d0,a2
	Sub.l	#1,d6
	Bpl	_gsbcl
_gsend	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_GETODDSPRITE		Equ	57
L57	Move.l	(a3)+,d7	; D7=LONGUEUR EN LIGNES DU SPRITE !!!
	Move.l	(a3)+,d6	; D6=Y position.
	Move.l	(a3)+,d5	; D5=X Pos.
	Lsr.l	#3,d5		; D5=X Position en octets.
	Move.l	(a3)+,d4	; D4=NUMERO DU SPRITE !!!.
	Move.l	(a3)+,a0	; A0=SCREEN BASE.
	Add.l	#8,a0
	Move.l	(a0)+,a1	; A1=Bit Plane 3 Pointer.
	Move.l	(a0)+,a2	; A2=Bit Plane 4 Pointer.
	Add.l	#$6e,a0			; #$00000076-#$00000008 .
	Clr.l	d0
	Move.w	(a0)+,d0	; D0=X Screen Size.
	Lsr.l	#3,d0		; D0=LONGUEUR D'UNE LIGNE A L'AUTRE !!!
	Move.w	(a0)+,d1	; D1=Y Screen Size.
	Mulu	d0,d6
	Add.l	d5,d6		; D6=1er mot du sprite !!!
	Add.l	d6,a1		; A1=ADRESSE DU 1ER  PLAN.
	Add.l	d6,a2		; A2=ADRESSE DU 2EME PLAN.
	DLea	_SpriteBase,a0
	Move.l	a0,d1
	Move.l	d1,a0		; A0=Adresse de base des sprites.
	Mulu	#520,d4		; 516=Longueur 1 Sprite de 16*128*2bp.
	Add.l	d4,a0
; CREATION DU SPRITE !!!
	Move.l	d7,d6		; D6=Longueur.
; Header du sprite
	Move.w	#$0000,(a0)+
	Move.b	d7,(a0)+
	Move.b	#$00,(a0)+
; Sprite datas.
_gobcl	Move.l	(a1),(a0)+
	Move.l	(a2),(a0)+
	Add.l	d0,a1
	Add.l	d0,a2
	Sub.l	#1,d6
	Bpl	_gobcl
_goend	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ACTIVESPRITE		Equ	58
L58	Move.l	(a3)+,d3	; D3=Sprite In Bank.
	Move.l	(a3)+,d4	; D4=Y View Size.
	Move.l	(a3)+,d1	; D1=Y Position.
	Move.l	(a3)+,d0	; D0=X Position.
	Move.l	(a3)+,d2	; D2=# Sprite.
	Lsl.l	#2,d2
	DLea	_SprPtBase,a1
	Move.l	(a1),a0
	Add.l	d2,a0
	Add.l	#2,a0		; A0=Adresse dans le copperlist.
	Mulu	#520,d3
	DLea	_SpriteBase,a2
	Move.l	(a2),a1
	Add.l	d3,a1
	DLea	_Temp,a2
	Move.l	a1,(a2)
	Move.w	(a2)+,(a0)
	Add.l	#4,a0
	Move.w	(a2),(a0)
	Move.b	d1,(a1)+
	Lsr.l	#1,d0
	Move.b	d0,(a1)+
	Add.l	d1,d4
	Move.b	d4,(a1)+
	Move.b	#0,(a1)
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_DOUBLEMASKB		Equ	59
L59	Move.l	(a3)+,d3	; D3=ECRAN CIBLE.
	Move.l	(a3)+,d0	; D0=Second Plan.
	Move.l	(a3)+,d1	; D1=Mask.
	Move.l	(a3)+,d2	; D2=Premier Plan.
	Cmp.l	#0,d2
	Beq	dmz
	Cmp.l	#0,d0
	Beq	dmz
	Cmp.l	#0,d1
	Beq	dmz
	Cmp.l	#0,d3
	Beq	dmz
	DLea	_a3,a0
	Move.l	a3,(a0)
	DLea	_dx1,a0
	Move.l	d2,(a0)+
	Move.l	d1,(a0)+
	Move.l	d0,(a0)+
	Move.l	d3,(a0)
	Move.l	d0,a0
	Add.l	#76,a0
	Clr.l	d5
	Clr.l	d6
	Clr.l	d7
	Move.w	(a0)+,d5	; D5=X Screen size.
	Move.w	(a0)+,d6	; D6=Y Screen Size.
	Lsr.l	#4,d5
	Lsl.l	#6,d6		; d6*64.
	Add.w	d5,d6		; D6*64 + d5 , Y Size * 64 + X size.
	Move.w	(a0),d7	; D7=nombre de bits plans present dans la cible.
;	Move.w	#5,d7
; Blitter Occupe ???
_pp2	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_pp2
_boucle:
	DLea	_dx1,a0
	Move.l	(a0),a1
	Move.l	(a1),d0		; D0=ForeGround.
	Add.l	#4,(a0)
	DLea	_dx2,a0
	Move.l	(a0),a1
	Move.l	(a1),d3		; D3=Mask.
	DLea	_dx3,a0
	Move.l	(a0),a2
	Move.l	(a2),a1		; A1=Background.
	Add.l	#4,(a0)
	DLea	_dx4,a0
	Move.l	(a0),a2
	Move.l	(a2),d4		; d4=Cible.
	Add.l	#4,(a0)
; Mise de BLITTER en mode FILL CARRY IN.
_pi2	Move.w	#$0,BLTCON1		; Origin=#$4
; Mise en place de la source a lire.
	Move.l	D0,BLTAPTH		; D0=ADRESSE SOURCE !!!
; Modulo de la source=0.
	Move.w	#$0,BLTAMOD
; Mise en place de la source MASQUE joueur (8eme plan) a lire.
	Move.l	D3,BLTBPTH		; D3=ADRESSE MASQUE !!!
; Modulo de la source masque=0.
	Move.w	#$0,BLTBMOD
; Selection de la zone source/cible.
	Move.l	a1,BLTCPTH		; A1=Adresse second plan
	Move.w	#$0,BLTCMOD
; Selection de la zone cible.
	Move.l	D4,BLTDPTH		; d4=ADRESSE CIBLE !!!
; Selection du modulo de la cible
	Move.w	#$0,BLTDMOD
; Mise a 0 des masques de debut et fin du blitter.
	Move.w	#$ffff,BLTAFWM
	Move.w	#$ffff,BLTALWM
; Selection du type d'operation logique pour obtenir le resultat graphique.
; Et positionnement par rapport au decalage D6 de la source B.
	Move.w	#%0000111110011000,BLTCON0	; Calcul mathematique.
	Move.w	#%0000111110011000,BLTCON0+$1A	; Equ BltCon0L
; Mise en place de la zone a copier.
	Move.w	D6,BLTSIZE
; Blitter occupe ?
_ppp	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_ppp
	sub.l	#1,d7
	Cmp.l	#0,d7
	Bne	_boucle
	DLea	_a3,a0
	Move.l	(a0),a3
	Rts
dmz	Moveq	#4,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_DOUBLEMASKB2		Equ	60
L60	Move.l	(a3)+,d4	; D4=Yend position.
	Move.l	(a3)+,d5	; D5=Ystart position.
	Move.l	(a3)+,d3	; D3=ECRAN CIBLE.
	Move.l	(a3)+,d0	; D0=Second Plan.
	Move.l	(a3)+,d1	; D1=Mask.
	Move.l	(a3)+,d2	; D2=Premier Plan.
	Cmp.l	#0,d0
	Beq	dme
	Cmp.l	#0,d1
	Beq	dme
	Cmp.l	#0,d2
	Beq	dme
	Cmp.l	#0,d3
	Beq	dme
	DLea	_a3,a0
	Move.l	a3,(a0)
	DLea	_dx1,a0
	Move.l	d2,(a0)+
	Move.l	d1,(a0)+
	Move.l	d0,(a0)+
	Move.l	d3,(a0)
	Move.l	d0,a0
	Add.l	#76,a0
	Move.l	d5,d0		; D0=Y Start position D4=Y End Position.
	Clr.l	d5
	Clr.l	d6
	Clr.l	d7
	Move.w	(a0)+,d5	; D5=X Screen size.
	Move.l	d4,d6
	Lsr.l	#3,d5
	Mulu	d5,d0		; D0=Rajout aux bits plans.
	Lsr.l	#1,d5
	Lsl.l	#6,d6		; d6*64.
	Add.l	d5,d6		; D6=d6*64+d5 D6=Ysize*64 + Xsize.
	Add.l	#2,a0
	Move.w	(a0),d7	; D7=nombre de bits plans present dans la cible.
	Move.l	d0,d2
_bcl2:
	DLea	_dx1,a0
	Move.l	(a0),a1
	Move.l	(a1),d0		; D0=ForeGround.
	Add.l	d2,d0				; RAJOUT.
	Add.l	#4,(a0)
	DLea	_dx2,a0
	Move.l	(a0),a1
	Move.l	(a1),d3		; D3=Mask.
	Add.l	d2,d3				; RAJOUT.
	DLea	_dx3,a0
	Move.l	(a0),a2
	Move.l	(a2),a1		; A1=Background.
	Add.l	d2,a1				; RAJOUT.
	Add.l	#4,(a0)
	DLea	_dx4,a0
	Move.l	(a0),a2
	Move.l	(a2),d4		; d4=Cible.
	Add.l	d2,d4				; RAJOUT.
	Add.l	#4,(a0)
; Blitter Occupe ???
_pq2	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_pq2
; Mise de BLITTER en mode FILL CARRY IN.
_pj2	Move.w	#$0,BLTCON1		; Origin=#$4
; Mise en place de la source a lire.
	Move.l	D0,BLTAPTH		; D0=ADRESSE SOURCE !!!
; Modulo de la source=0.
	Move.w	#$0,BLTAMOD
; Mise en place de la source MASQUE joueur (8eme plan) a lire.
	Move.l	D3,BLTBPTH		; D3=ADRESSE MASQUE !!!
; Modulo de la source masque=0.
	Move.w	#$0,BLTBMOD
; Selection de la zone source/cible.
	Move.l	a1,BLTCPTH		; A1=Adresse second plan
	Move.w	#$0,BLTCMOD
; Selection de la zone cible.
	Move.l	D4,BLTDPTH		; d4=ADRESSE CIBLE !!!
; Selection du modulo de la cible
	Move.w	#$0,BLTDMOD
; Mise a 0 des masques de debut et fin du blitter.
	Move.w	#$ffff,BLTAFWM
	Move.w	#$ffff,BLTALWM
; Selection du type d'operation logique pour obtenir le resultat graphique.
; Et positionnement par rapport au decalage D6 de la source B.
	Move.w	#%0000111110011000,BLTCON0	; Calcul mathematique.
	Move.w	#%0000111110011000,BLTCON0+$1A	; Equ BltCon0L
; Mise en place de la zone a copier.
	Move.w	D6,BLTSIZE
; Blitter occupe ?
_ppq	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_ppq
	sub.l	#1,d7
	Cmp.l	#0,d7
	Bne	_bcl2
	DLea	_a3,a0
	Move.l	(a0),a3
	Rts
dme	Moveq	#4,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_PATCH13	Equ	61
L61	Move.w	#$0,$dff1fc		; Disable DOUBLE SCANNING.
	Move.w	#$0,$dff106		; GRAPHICS PALETTE=0 to 31
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LFILTER1	Equ	62
L62	Move.l	(a3)+,a1	; Fin
	Move.l	(a3)+,a0	; Debut
	Move.l	(a3)+,d0	; Filtre
_lf0	Move.b	(a0),d1
	Cmp.b	d0,d1
	Blt	_lf1
	Move.b	d0,(a0)
_lf1	Add.l	#1,a0
	Cmp.l	a0,a1
	Bne	_lf0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LFILTER2	Equ	63
L63	Move.l	(a3)+,a1	; Fin
	Move.l	(a3)+,a0	; Debut
	Move.l	(a3)+,d0	; Filtre
_lf2	Move.w	(a0),d1
	Cmp.w	d0,d1
	Blt	_lf3
	Move.w	d0,(a0)
_lf3	Add.l	#2,a0
	Cmp.l	a0,a1
	Blt	_lf2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LFILTER3	Equ	64
L64	Move.l	(a3)+,a1	; Fin
	Move.l	(a3)+,a0	; Debut
	Move.l	(a3)+,d0	; Filtre
_lf4	Move.l	(a0),d1
	Cmp.l	d0,d1
	Blt	_lf5
	Move.l	d0,(a0)
_lf5	Add.l	#4,a0
	Cmp.l	a0,a1
	Blt	_lf4
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_2NDPAL	Equ	65
L65	Move.l	(a3)+,d0
	DLea	_BplConBase,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	_l2end
	Add.l	#14,a1
	Mulu	#$400,d0
	Move.w	d0,(a1)
	Rts
_l2end	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_READIFFCOLOR	Equ	66
L66	Move.l	(a3)+,d0	; Color
	Move.l	(a3)+,a1	; Iff Base.
	Move.l	#65536,d7
_ric	Move.l	(a1),d1
	Cmp.l	#"CMAP",d1
	Beq	_ric2
	Sub.l	#1,d7
	Cmp.l	#0,d7
	Beq	ric
	Add.l	#2,a1
	Bra	_ric
_ric2	Add.l	#8,a1
	Mulu	#3,d0
	Add.l	d0,a1
	Clr.l	d0
	Clr.l	d1
	Clr.l	d2
	Move.b	(a1)+,d0	; D0=R
	Move.b	(a1)+,d1	; D1=V
	Move.b	(a1),d2		; D2=B
	Lsr.l	#4,d0
	Lsr.l	#4,d1
	Lsr.l	#4,d2
	Lsl.l	#8,d0
	Lsl.l	#4,d1
	Add.l	d1,d0
	Add.l	d2,d0
	Move.l	d0,d3
	Moveq	#0,d2
	Rts
ric	Moveq	#6,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ADD2SCREEN	Equ	67
L67	DLea	_CurrentLine,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	a2s
	Move.l	#$f203fffe,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos.
; Installation de la palette de couleur du second ecran.
	DLea	_2pal,a1
	Move.l	a0,(a1)
;	Move.l	#$01060000,d1
;cc1	Move.l	d1,(a0)+
	Move.l	#$01800000,d0
ccc	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01C00000,d0
	Bne	ccc
;	Add.l	#$00002000,d1
;	Cmp.l	#$01070000,d1
;	Bne	cc1
; Installation des bits plans.
	DLea	_2bpl,a1
	Move.l	a0,(a1)
	Move.l	#$00e00000,d0
ccd	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	ccd
; installation de la suite.
	Move.l	#$008e0181,(a0)+
	Move.l	#$009037c1,(a0)+
	Move.l	#$00920038,(a0)+	; Old=$30
	Move.l	#$009400d0,(a0)+
	Move.l	#$01020000,(a0)+
	Move.l	#$01040000,(a0)+
	Move.l	#$01060000,(a0)+
	Move.l	#$01080000,(a0)+	; Bpl1Mod
	Move.l	#$010A0000,(a0)+	; Bpl2Mod
	DLea	_2bplcon,a1
	move.l	a0,(a1)
	Move.l	#$01000000,(a0)+	; BplCon0
	Move.l	#$f303fffe,(a0)+
	Move.l	#$00968300,(a0)+
	Move.l	#$ffd9fffe,(a0)+
	Move.l	#$0103fffe,(a0)+
	DLea	_CurrentLine,a1
	Move.l	a0,(a1)
	Move.l	#$1403fffe,(a0)+
	Move.l	#$01000000,(a0)+
	Move.l	#$00960100,(a0)+
	Move.l	#$fffffffe,(a0)
	DLea	_2act,a2
	Move.l	#1,(a2)
	DLea	_Line,a1
	Move.l	#$14,(a1)
	DLea	_CurrentLine,a1
	Sub.l	#12,a0
	Move.l	a0,(a1)		; Sauvegarde adresse copper pour line.
	DLea	_2nd,a1
	Move.l	#1,(a1)		; 2nd ecran actif.
	Rts
a2s	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SET2PLANES	Equ	68
L68	Move.l	(a3)+,d1
	Move.l	(a3)+,d0
	Sub.l	#1,d0
	Cmp.l	#0,d0
	Bmi	_s2p
	Cmp.l	#4,d0
	Bgt	_s2p
	Lsl.l	#3,d0
	DLea	_2bpl,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq	s2p
	Add.l	#2,a0
	Add.l	d0,a0
	Move.l	d1,d0
	lsr.l	#8,d0
	Lsr.l	#8,d0
	Move.w	d0,(a0)
	Add.l	#4,a0
	Move.w	d1,(a0)
_s2p	Rts
s2p	Moveq	#7,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SET2VIEW	Equ	69
L69	Move.l	(a3)+,d0
	DLea	_PlanesMask,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d0
	DLea	_2bplcon,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq	s2v
	Add.l	#2,a0
	Move.w	d0,(a0)
	Rts
s2v	Moveq	#7,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SET2PAL	Equ	70
L70	Move.l	(a3)+,d3
	Move.l	(a3)+,d2
	Move.l	(a3)+,d1
	Move.l	(a3)+,d0
	Add.l	#1,d0
	DLea	_2pal,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq	_s2pp
	Lsl.l	#8,d1
	Lsl.l	#4,d2
	Add.l	d1,d3
	Add.l	d2,d3
_s2o	Move.w	(a0),d4
	Cmp.w	#$0106,d4
	Bne	_s2r
	Add.l	#4,a0
_s2r	Sub.l	#1,d0
	Cmp.l	#$0,d0
	Beq	_s2q
	Add.l	#4,a0
	Bra	_s2o
_s2q	Add.l	#2,a0
	Move.w	d3,(a0)
	Rts
_s2pp	Moveq	#7,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CMAP		Equ	71
L71	Move.l	(a3)+,a0
; Find CMAP Header
	Move.l	#16384,d0
_cmx	Move.l	(a0),d1
	Cmp.l	#"CMAP",d1
	Beq	_cmx2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne	_cmx
	Bra	_itsx
_cmx2	Add.l	#4,a0		; CMAP !!!
	Move.l	a0,d3
	Moveq	#0,d2
	Rts
_itsx	Move.l	#6,d0		; NO CMAP.
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_BPALETTE		Equ	72
L72	Move.l	(a3)+,a0
	Move.l	(a3)+,d0
	Sub.l	#1,d0
	DLea	_ColorBase,a2
	Move.l	(a2),a1
;	Add.l	#4,a1
_bp1	Move.w	(a1)+,d1
	Cmp.w	#$106,d1
	Bne	_bp2
	Add.l	#4,a1
_bp2	Move.w	(a0)+,(a1)+
	Sub.l	#1,d0
	Bpl	_bp1
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_IPALETTE		Equ	73
L73	Move.l	(a3)+,a0
	Move.l	(a3)+,d0
	Sub.l	#1,d0
	DLea	_ColorBase,a2
	Move.l	(a2),a1
;	Add.l	#4,a1
_bi1	Move.w	(a1)+,d1
	Cmp.w	#$106,d1
	Bne	_bi2
	Add.l	#4,a1
_bi2	Clr.l	d2
	Clr.l	d3
	Clr.l	d4
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Lsr.l	#4,d2
	Lsr.l	#4,d3
	Lsr.l	#4,d4
	Lsl.l	#8,d2
	Lsl.l	#4,d3
	Add.l	d4,d3
	Add.l	d3,d2
	Move.w	d2,(a1)+
	Sub.l	#1,d0
	Bpl	_bi1
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_VBLWAIT		Equ	74
L74	Move.l	(a3)+,d1
	Cmp.l	#381,d1
	Blt	_dd1
	Move.l	#383,d1
_dd1	Lsl.l	#8,d1
_ddd	Move.l	VPOSR,d0
	And.l	#$1ff00,d0
	Cmp.l	d1,d0
	Bne	_ddd
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_JPALETTE		Equ	75
L75	Move.l	(a3)+,a0
	Move.l	(a3)+,d0
	Sub.l	#1,d0
	DLea	_ColorBase,a2
	Move.l	(a2),a1
;	Add.l	#4,a1
_bj1	Move.w	(a1)+,d1
	Cmp.w	#$106,d1
	Bne	_bj2
	Add.l	#4,a1
_bj2	Clr.l	d2
	Clr.l	d3
	Clr.l	d4
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Lsl.l	#8,d2
	Lsl.l	#4,d3
	Add.l	d4,d3
	Add.l	d3,d2
	Move.w	d2,(a1)+
	Sub.l	#1,d0
	Bpl	_bj1
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_FPALETTE		Equ	76
L76
	Move.l	(a3)+,a1	; A1=Adr1
	Move.l	(a3)+,a0	; A0=Adr0
	Move.l	(a3)+,d0
	Sub.l	#1,d0
_fp1	Move.l	a0,a2
	Clr.l	d1
	Clr.l	d2
	Clr.l	d3
	Move.b	(a2)+,d1	; D1=R
	Move.b	(a2)+,d2	; D2=V
	Move.b	(a2)+,d3	; D3=B
	Clr.l	d4
	Clr.l	d5
	Clr.l	d6
	Move.b	(a1)+,d4	; D4=R2
	Move.b	(a1)+,d5	; D5=V2
	Move.b	(a1)+,d6	; D6=B2
	Cmp.b	d4,d1
	Blt	_incd1
	Cmp.b	d4,d1
	Beq	_nopd1
_decd1	Sub.b	#1,d1
	Bra	_nopd1
_incd1	Add.b	#1,d1
_nopd1
	Cmp.b	d5,d2
	Blt	_incd2
	Cmp.b	d5,d2
	Beq	_nopd2
_decd2	Sub.b	#1,d2
	Bra	_nopd2
_incd2	Add.b	#1,d2
_nopd2
	Cmp.b	d6,d3
	Blt	_incd3
	Cmp.b	d6,d3
	Beq	_nopd3
_decd3	Sub.b	#1,d3
	Bra	_nopd3
_incd3	Add.b	#1,d3
_nopd3
	Move.b	d1,(a0)+
	Move.b	d2,(a0)+
	Move.b	d3,(a0)+
	Sub.l	#1,d0
	Bpl	_fp1
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CPALETTE		Equ	77
L77	Move.l	(a3)+,a0	; A0=Adresse de calcul
	Move.l	(a3)+,a2	; A2=Adresse source
	Move.l	(a3)+,d7	; D7=rajout en bleu.
	Move.l	(a3)+,d6	; D6=Rajout en vert.
	Move.l	(a3)+,d5	; D5=Rajout en Rouge.
	Move.l	(a3)+,d0	; D0=NUM.
	Sub.l	#1,d0
_cp1	Clr.l	d2
	Clr.l	d3
	Clr.l	d4
	Move.b	(a2)+,d2
	Move.b	(a2)+,d3
	Move.b	(a2)+,d4
	Add.l	d5,d2
	Bpl	_rnop
	Move.l	#0,d2
_rnop	Cmp.l	#16,d2
	Blt	_rnoq
	Move.l	#15,d2
_rnoq
	Add.l	d6,d3
	Bpl	_vnop
	Move.l	#0,d3
_vnop	Cmp.l	#16,d3
	Blt	_vnoq
	Move.l	#15,d3
_vnoq
	Add.l	d7,d4
	Bpl	_bnop
	Move.l	#0,d4
_bnop	Cmp.l	#16,d4
	Blt	_bnoq
	Move.l	#15,d4
_bnoq
	Move.b	d2,(a0)+
	Move.b	d3,(a0)+
	Move.b	d4,(a0)+
	Sub.l	#1,d0
	Bpl	_cp1
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_2VIEW			Equ	78
L78	Move.l	(a3)+,d0
	DLea	_CurrentLine,a1
	Move.l	(a1),a0
	Move.b	(a0),d1
	Cmp.b	#$14,d1
	Bne	_l2e
	Sub.l	#$d,d0
	Bmi	_l2e
	Move.b	d0,(a0)
_l2e	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_IFF8TO4		Equ	79
L79	Move.l	(a3)+,a1	; A1=Cible
	Move.l	(a3)+,a0	; A0=Source
	Move.l	(a3)+,d0
	Sub.l	#1,d0
_i8t4	Clr.l	d1
	Clr.l	d2
	Clr.l	d3
	Move.b	(a0)+,d1
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Lsr.l	#4,d1
	Lsr.l	#4,d2
	Lsr.l	#4,d3
	Move.b	d1,(a1)+
	Move.b	d2,(a1)+
	Move.b	d3,(a1)+
	Sub.l	#1,d0
	Bpl	_i8t4
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SETCOLORCOMP		Equ	80
L80	Move.l	(a3)+,d3	; D3=Blue.
	Move.l	(a3)+,d2	; D2=Green.
	Move.l	(a3)+,d1	; D1=Red.
	Move.l	(a3)+,d0	; D0=Register
	Move.l	d1,d4
	Move.l	d2,d5
	Move.l	d3,d6
	Lsr.l	#4,d1
	Lsr.l	#4,d2
	Lsr.l	#4,d3
	Move.l	d1,d7
	Lsl.l	#4,d7
	Or.l	d2,d7
	Lsl.l	#4,d7
	Or.l	d3,d7		; D7=Couleur Finale.
	Lsl.l	#4,d1
	Lsl.l	#4,d2
	Lsl.l	#4,d3
	Sub.l	d1,d4
	Sub.l	d2,d5
	Sub.l	d3,d6
	Lsl.l	#4,d4
	Or.l	d5,d4
	Lsl.l	#4,d4
	Or.l	d6,d4		; D4=Couleur Complement Final.
	DLea	_ColorBase,a1
	Move.l	(a1),a0
_80b	Move.w	(a0)+,d1
	Cmp.w	#$0106,d1
	Bne	_80a
	Add.l	#4,a0
_80a	Sub.l	#1,d0
	Cmp.l	#0,d0
	Beq	_80c
	Add.l	#2,a0
	Bra	_80b
_80c	Move.w	d7,(a0)
	DLea	_ColorBase,a1
	Move.l	(a1),a2
	Sub.l	a2,a0		; A1=Decalage de palette.
	DLea	_ColorBase2,a2
	Move.l	(a2),a1
	Add.l	a0,a1
	Move.w	d4,(a1)		; Sauvegarde COLOR COMPLEMENT.
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MFILL			Equ	81
L81	Move.l	(a3)+,a1
	Move.l	(a3)+,a0
	Move.l	(a3)+,d0
	Move.l	a1,a2
	Sub.l	a0,a2
	Bmi	_endx
_mf	Move.b	d0,(a0)+
	Cmp.l	a0,a1
	Bne	_mf
_endx	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_BLITCOPY		Equ	82
L82	Move.l	(a3)+,a2	; A2=cible.
	Move.l	(a3)+,a1	; A1=Source.
	Cmp.l	#0,a1
	Beq	bc
	Cmp.l	#0,a2
	Beq	bc
	Move.l	a1,a0
	Add.l	#76,a0
	Clr.l	d6
	Clr.l	d7
	Move.w	(a0)+,d6	; D6=X Screen Size.
	Move.w	(a0)+,d7	; D7=Y Screen Size.
	Lsr.l	#4,d6
	Lsl.l	#6,d7	; D7*64
	Add.l	d6,d7	; D7+XSize.
	Move.l	#5,d6		; D6=6 bits plans maximum.
; Blitter Occupe ???
_qq2	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_qq2
; Mise de BLITTER en mode FILL CARRY IN.
_qqq	Move.w	#$0,BLTCON1		; Origin=#$4
; Mise en place de la source a lire.
	Move.l	(a1)+,BLTAPTH		; A1=ADRESSE SOURCE !!!
; Modulo de la source=0.
	Move.w	#$0,BLTAMOD
; Adresse cible
	Move.l	(a2)+,BLTDPTH		; A2=ADRESSE CIBLE !!!
; Selection du modulo de la cible
	Move.w	#$0,BLTDMOD
; Mise a 0 des masques de debut et fin du blitter.
	Move.w	#$ffff,BLTAFWM
	Move.w	#$ffff,BLTALWM
; Selection du type d'operation logique pour obtenir le resultat graphique.
; Et positionnement par rapport au decalage D6 de la source B.
	Move.w	#%0000100111110000,BLTCON0	; Calcul mathematique.
	Move.w	#%0000100111110000,BLTCON0+$1A	; Equ BltCon0L
; Mise en place de la zone a copier.
	Move.w	D7,BLTSIZE
; Blitter occupe ?
_qpq	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_qpq
	Cmp.l	#$0,(a1)
	Beq	_endd
	Cmp.l	#$0,(a2)
	Beq	_endd
	Sub.l	#1,d6
	Bpl	_qqq
_endd	Rts
bc	Moveq	#4,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CONFORM32		Equ	83
L83	DLea	_c1,a0
	Move.l	(a3),(a0)
	Move.l	(a3)+,a0
	Move.l	a0,d7		; D7=Bit Plane Adress
	Add.l	#76,a0
	Clr.l	d0
	Clr.l	d1
	Move.w	(a0)+,d0	; D0=X Screen Size.
	Move.w	(a0)+,d1	; D1=Y Screen Size.
	Lsr.l	#5,d0		; D0=.l X Screen length.
	Lsr.l	#5,d1		; D1=Block 32 Y Size Length.
	Move.l	#7,d5	; D5=6 Bits plans maximum.
; Copier sur une ligne de 1 bit plan.
_z3	Move.l	d7,a0
	Sub.l	#1,d5
	Cmp.l	#0,d5
	Beq	_fini	; Ecran Termine.
	Move.l	(a0),a2		; A2=Adresse cible.
	Cmp.l	#0,a2
	Beq	_fini	; Ecran Termine.
	Add.l	#4,d7		; D7=Adresse prochain bit plan a cibler.
;
; Faire la routine sur 1 bit plan.
	Move.l	d1,d4		; D4=Nbre de blocks a copier en Y.
_z2	Move.l	(a0),a1	; A1=Adresse source.
	Move.l	#32,d3		; D3=32 lignes a modifier.
_z0	Move.l	d0,d2	; D0 Blocks a copier en X.
_z1	Move.l	(a1),(a2)+	; Copie source / destination .
	Sub.l	#1,d2
	Cmp.l	#0,d2
	Bne	_z1
	Move.l	d0,d6
	Lsl.l	#2,d6
	Add.l	d6,a1
	Sub.l	#1,d3
	Cmp.l	#0,d3
	Bne	_z0
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_z2
	Bra	_z3
_fini	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CONFORM32B		Equ	84
L84	DLea	_c1,a0
	Move.l	(a3),(a0)
	Move.l	(a3)+,a0
	Move.l	a0,d7		; D7=Bit Plane Adress
	Add.l	#76,a0
	Clr.l	d0
	Clr.l	d1
	Move.w	(a0)+,d0	; D0=X Screen Size.
	Move.w	(a0)+,d1	; D1=Y Screen Size.
	Lsr.l	#5,d0		; D0=.l X Screen length.
	Lsr.l	#5,d1		; D1=Block 32 Y Size Length.
	Move.l	#7,d5	; D5=6 Bits plans maximum.
; Copier sur une ligne de 1 bit plan.
_z3b	Move.l	d7,a0
	Sub.l	#1,d5
	Cmp.l	#0,d5
	Beq	_finib	; Ecran Termine.
	Move.l	(a0),a2		; A2=Adresse cible.
	Cmp.l	#0,a2
	Beq	_finib	; Ecran Termine.
	Add.l	#4,d7		; D7=Adresse prochain bit plan a cibler.
	Move.l	(a0),a1
;
; Faire la routine sur 1 bit plan.
	Move.l	d1,d4		; D4=Nbre de blocks a copier en Y.
_z2b	Move.l	#32,d3		; D3=32 lignes a modifier.
_z0b	Move.l	d0,d2	; D0 Blocks a copier en X.
_z1b	Move.l	(a1),(a2)+	; Copie source / destination .
	Sub.l	#1,d2
	Cmp.l	#0,d2
	Bne	_z1b
	Move.l	d0,d6
	Lsl.l	#2,d6
	Add.l	d6,a1
	Sub.l	#1,d3
	Cmp.l	#0,d3
	Bne	_z0b
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_z2b
	Bra	_z3b
_finib	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SETDPLANE		Equ	85
L85	Move.l	(a3)+,d1	; D1=Adress
	Move.l	(a3)+,d0	; D0=BitPlane.
	Cmp.l	#1,d0
	Blt	_sdp
	Cmp.l	#8,d0
	Bgt	_sdp
	Sub.l	#1,d0
	Lsl.l	#2,d0
	DLea	_BitsPlanesD,a0
	Add.l	d0,a0
	Move.l	d1,(a0)
_sdp	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SWAPPLANES		Equ	86
L86	DLea	_BitsPlanes,a0
	DLea	_BitsPlanesD,a1
	Move.l	#8,d0
	Cmp.l	#$0,(a0)
	Beq	sppx
_spp	Move.l	(a0),d1
	Move.l	(a1),(a0)+
	Move.l	d1,(a1)+
	Sub.l	#1,d0
	Cmp.l	#0,d0
	Bne	_spp
	DLea	_Aga,a0
	Cmp.l	#$0,(a0)
	Beq	_naga
	Move.l	#15,d0
	Bra	_na
_naga	Move.l	#11,d0
_na	DLea	_BitsPlanes,a0
	DLea	_BplPtBase,a2
	Move.l	(a2),a1
	Add.l	#2,a1
_nbb	Move.w	(a0)+,(a1)
	Add.l	#4,a1
	Sub.l	#1,d0
	Bpl	_nbb
	Rts
sppx	Moveq	#1,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_RESICON		Equ	87
L87	Movem.l	a3-a6,-(sp)
	Move.l	(a3),d7		; D7=nombre d'icones.
	DLea	_Icons,a0
	Cmp.l	#$0,(a0)
	Bne	_rie		; Si banque deja reservee.
	Move.l	d7,(a0)		; Save icon max.
	Mulu	#260,d7
	Add.l	#8,d7
	Move.l	d7,d0		; D0=Byte Size.
	Move.l	#Chip+Clear,d1	; D1=Memory Type
	Move.l	$4,a6
	Jsr	AllocMem(a6)
	DLea	_IcBase,a0
	Move.l	d0,(a0)
	Cmp.l	#0,d0
	Beq	NOFREE
; Preparation de la banque d'icones.
	Move.l	d0,a0
	DLea	_Icons,a1
	Move.l	#"F.C1",(a0)+	; Offset #0 Equ "F.C1"
	Move.l	(a1),(a0)	; Offset #4 Equ IconMax.
	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Rts
NOFREE	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#8,d0
	Rbra	L_CUSTOM
_rie	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#15,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ERAICON		Equ	88
L88	Movem.l	a3-a6,-(sp)
	DLea	_Icons,a2
	Move.l	(a2),d0
	Cmp.l	#$0,d0
	Beq	_eie
	Move.l	#$0,(a2)	; Clear _ICONS Register.
	Mulu	#260,d0
	Add.l	#8,d0
	DLea	_IcBase,a2
	Move.l	(a2),a1
	Cmp.l	#0,a1
	Beq	ei
	Move.l	#$0,(a2)	; Clear _ICBASE Register.
	Move.l	$4,a6
	Jsr	FreeMem(a6)
_eie	Movem.l	(sp)+,a3-a6
	Rts
ei	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#9,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_GETICON		Equ	89
L89	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d7	; D7=Ypos.
	Move.l	(a3)+,d6	; D6=Xpos.
	Move.l	(a3)+,d5	; Icon.
; Verifications...
	Cmp.l	#1,d5
	Blt	_gie		; Icon<1.
	DLea	_Icons,a2
	Cmp.l	(a2),d5
	Bgt	_gie		; Icon>IconMax.
	Sub.l	#1,d5
;
	DLea	_IcBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	gi
	Add.l	#8,a0
	Mulu	#260,d5
	Add.l	d5,a0		; A0=Adresse cible pout TAKE ICON.	
;
	DLea	_XY,a2
	Move.l	(a2),d4		; D4=X Scren Size.
	Lsr.l	#3,d4		; D4=RAJOUT PAR LIGNES.
	Mulu	d4,d7
	Lsr.l	#3,d6
	Add.l	d6,d7		; D7=RAJOUT AUX BITS PLANS.
;
	DLea	_BitsPlanes,a2
	Move.l	#8,d6		; D6=8 bits plans.
_gi0	Move.l	(a2)+,a1	; A1=Adresse cible
	Cmp.l	#$0,a1
	Beq	_gie		; Plus de bits plans a saisir ???
	Add.l	d7,a1
	Move.l	#16,d5		; D5=16 lignes par bobs.
;
_gi1	Move.w	(a1),(a0)+	; A0 -> Next Data.
	Add.l	d4,a1		; A1 -> Next Line.
	Sub.l	#1,d5
	Cmp.l	#0,d5
	Bne	_gi1
	Sub.l	#1,d6
	Cmp.l	#0,d6
	Bne	_gi0
;
_gie	Movem.l	(sp)+,a3-a6
	Add.l	#12,a3
	Rts
gi	Movem.l	(sp)+,a3-a6
	Add.l	#12,a3
	Moveq	#9,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_PASICON		Equ	90
L90	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d7	; D7=Ypos.
	Move.l	(a3)+,d6	; D6=Xpos.
	Move.l	(a3)+,d5	; Icon.
; Verifications...
	Cmp.l	#1,d5
	Blt	_pie		; Icon<1.
	DLea	_Icons,a2
	Cmp.l	(a2),d5
	Bgt	_pie		; Icon>IconMax.
	Sub.l	#1,d5
;
	DLea	_IcBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	pii
	Add.l	#8,a0
	Mulu	#260,d5
	Add.l	d5,a0		; A0=Adresse icone a PASTER.
;
	DLea	_XY,a2
	Move.l	(a2),d4		; D4=X Screen Size.
;
	DLea	_XY,a2
	Move.l	(a2),d4		; D4=X Scren Size.
	Lsr.l	#3,d4
	Mulu	d4,d7
	Lsr.l	#3,d6
	Add.l	d6,d7		; D7=RAJOUT AUX BITS PLANS.
;
	DLea	_BitsPlanes,a2
	Move.l	#8,d6		; D6=8 bits plans.
_pi0	Move.l	(a2)+,a1	; A1=Adresse cible
	Cmp.l	#$0,a1
	Beq	_pie		; Plus de bits plans a saisir ???
	Add.l	d7,a1
	Move.l	#16,d5		; D5=16 lignes par bobs.
;
_pi1	Move.w	(a0)+,(a1)	; A0 -> Next Data.
	Add.l	d4,a1		; A1 -> Next Line.
	Sub.l	#1,d5
	Cmp.l	#0,d5
	Bne	_pi1
	Sub.l	#1,d6
	Cmp.l	#0,d6
	Bne	_pi0
;
_pie	Movem.l	(sp)+,a3-a6
	Add.l	#12,a3
	Rts
pii	Movem.l	(sp)+,a3-a6
	Add.l	#12,a3
	Moveq	#9,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ICONBASE		Equ	91
L91	DLea	_IcBase,a0
	Move.l	(a0),d3
	Moveq	#0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_SAVEICON		Equ	92
L92	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,a0	; A0=Name Base
	DLea	_IcBase,a2
	Cmp.l	#$0,(a2)
	Beq	NOTRESERVED
	Clr.l	d0
	Move.w	(a0)+,d0	; D0=Name Length.
	Cmp.l	#1,d0
	Blt	_sie
	Cmp.l	#95,d0
	Bgt	_sie
	DLea	_IcN,a1
; Mise en place du nom du fichier termine par '0' dans la zone reservee.
_si1	Move.b	(a0)+,(a1)+
	Sub.l	#1,d0
	Cmp.l	#0,d0
	Bne	_si1
	Move.b	#$0,(a1)
;
	Move.l	$4,a6
	DLea	_DName,a1
	Move.l	#0,d0
	Jsr	OpenLib(a6)
	DLea	_DBase,a1
	Move.l	d0,(a1)
	Move.l	d0,a1
	Jsr	CloseLib(a6)
; Creation du fichier.
	DLea	_DBase,a0
	Move.l	(a0),a6		; A6=Dos Base.
	DLea	_IcN,a1		; D1=File Name.
	Move.l	a1,d1
	Move.l	#1006,d2	; D2=Write File.
	Jsr	DosOpen(a6)
	DLea	_IHnd,a0
	Move.l	d0,(a0)		; D0=Icon File Handle.
	Move.l	d0,d1		; D1=Handle.
	DLea	_Icons,a0
	Move.l	(a0),d3
	Mulu	#260,d3
	Add.l	#8,d3		; D3=File Length to be written.
	DLea	_IcBase,a0
	Move.l	(a0),d2		; D2=Icon Bank Base.
	Jsr	DosWrite(a6)
	DLea	_IHnd,a0
	Move.l	(a0),d1
	Jsr	DosClose(a6)
_sie	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Rts
NOTRESERVED
	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#9,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LOADICON		Equ	93
L93	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,a0	; A0=Name Base
	Clr.l	d0
	Move.w	(a0)+,d0	; D0=Name Length.
; Verifications.
	Cmp.l	#1,d0
	Blt	_sie
	Cmp.l	#95,d0
	Bgt	_sie
	DLea	_IcN,a1
; Mise en place du nom du fichier termine par '0' dans la zone reservee.
_sii1	Move.b	(a0)+,(a1)+
	Sub.l	#1,d0
	Cmp.l	#0,d0
	Bne	_sii1
	Move.b	#$0,(a1)
; Ouverture de la Dos.Library .
	Move.l	$4,a6
	DLea	_DName,a1
	Move.l	#0,d0
	Jsr	OpenLib(a6)
	DLea	_DBase,a1
	Move.l	d0,(a1)
	Move.l	d0,a1
	Jsr	CloseLib(a6)
; Lecture des 8 premier octets du fichier.
	DLea	_DBase,a0
	Move.l	(a0),a6		; A6=Dos Base.
	DLea	_IcN,a1		; D1=File Name.
	Move.l	a1,d1
	Move.l	#1005,d2	; D2=Read File.
	Jsr	DosOpen(a6)
	DLea	_IHnd,a0
	Move.l	d0,(a0)		; Sauvegarde du File Handle.
	Move.l	#8,d3		; D3=Length = 8 octets .
	Move.l	d0,d1		; D1=File Handle.
	DLea	_IcLoad,a0
	Move.l	a0,d2		; d2=Adress
	Jsr	DosRead(a6)
	DLea	_IcLoad,a0
	Cmp.l	#"F.C1",(a0)
	Bne	_NotIconFile	; Mauvais format.
; Fichier au format Icones.
	Add.l	#4,a0
	Move.l	(a0),d0
	DLea	_Icons,a0
	Move.l	d0,(a0)		; Sauvegarde du nombre d'icones du fichier.
	Mulu	#260,d0
	Add.l	#8,d0		; D0=Byte size needed.
	Move.l	#Chip+Clear,d1	; D1=Requirements.
	Move.l	$4,a6
	Jsr	AllocMem(a6)
	Cmp.l	#0,d0		; Not enough memory available ???
	Beq	_NotIconFile	; Pas assez de memoire pour le fichier.
	DLea	_IcBase,a0
	Move.l	d0,(a0)		; Save ICON BASE Adress.
	Move.l	d0,d7
	DLea	_DBase,a0
	Move.l	(a0),a6		; A6=DosBase.
	DLea	_IHnd,a0
	Move.l	(a0),d1		; D1=File Handle.
	DLea	_Icons,a0
	Move.l	(a0),d3
	Mulu	#260,d3		; D3=Longueur de chargement du reste.
	Move.l	d7,a1		; A1=Icon Adress.
	Move.l	#"F.C1",(a1)+	; Remise en place du header.
	Move.l	(a0),(a1)+	; Remise en place du nombre d'icones.
	Move.l	a1,d2		; D2=Adresse de chargement.
	Jsr	DosRead(a6)
	DLea	_IHnd,a0
	Move.l	(a0),d1
	Jsr	DosClose(a6)
	Bra	_lie		
;
_NotIconFile
; Fermeture du fichier.
	DLea	_IHnd,a0
	Move.l	(a0),d1
	DLea	_DBase,a0
	Move.l	(a0),a6
	Jsr	DosClose(a6)
;
	DLea	_Icons,a0
	Move.l	#$0,(a0)
	DLea	_IcBase,a0
	Move.l	#$0,(a0)
	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#10,d0
	Rbra	L_CUSTOM
;
_lie	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPRESERVE		Equ	94
L94	Movem.l	a3-a6,-(sp)
	DLea	_Mplots,a0
	Move.l	(a0),d7
	Cmp.l	#$0,d7
	Bne	_rmp		; Si banque deja reservee.
	Move.l	(a3),d7		; D7=nombre de points
	Move.l	d7,(a0)		; Save Points Max.
	Mulu	#6,d7
	Add.l	#8,d7
	Move.l	d7,d0		; D0=Byte Size.
	Move.l	#Chip+Clear,d1	; D1=Memory Type
	Move.l	$4,a6
	Jsr	AllocMem(a6)
	DLea	_MpBase,a0
	Move.l	d0,(a0)
	Cmp.l	#0,d0
	Beq	NOFREE2
; Preparation de la banque d'icones.
	Move.l	d0,a0
	DLea	_Mplots,a1
	Move.l	#"F.C2",(a0)+	; Offset #0 Equ "F.C2"
	Move.l	(a1),(a0)	; Offset #4 Equ MPlots Max.
	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Rts
NOFREE2	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#8,d0
	Rbra	L_CUSTOM
_rmp	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#12,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPERASE		Equ	95
L95	Movem.l	a3-a6,-(sp)
	DLea	_Mplots,a2
	Move.l	(a2),d0
	Cmp.l	#$0,d0
	Beq	_emp
	Move.l	#$0,(a2)	; Clear _ICONS Register.
	Mulu	#6,d0
	Add.l	#8,d0
	DLea	_MpBase,a2
	Move.l	(a2),a1
	Cmp.l	#0,a1
	Beq	MPE
	Move.l	#$0,(a2)	; Clear _ICBASE Register.
	Move.l	$4,a6
	Jsr	FreeMem(a6)
_emp	Movem.l	(sp)+,a3-a6
	Rts
MPE	Movem.l	(sp)+,a3-a6
	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPLOAD		Equ	96
L96	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,a0	; A0=Name Base
	Clr.l	d0
	Move.w	(a0)+,d0	; D0=Name Length.
; Verifications.
	Cmp.l	#1,d0
	Blt	_mie
	Cmp.l	#95,d0
	Bgt	_mie
	DLea	_IcN,a1
; Mise en place du nom du fichier termine par '0' dans la zone reservee.
_mii1	Move.b	(a0)+,(a1)+
	Sub.l	#1,d0
	Cmp.l	#0,d0
	Bne	_mii1
	Move.b	#$0,(a1)
; Ouverture de la Dos.Library .
	Move.l	$4,a6
	DLea	_DName,a1
	Move.l	#0,d0
	Jsr	OpenLib(a6)
	DLea	_DBase,a1
	Move.l	d0,(a1)
	Move.l	d0,a1
	Jsr	CloseLib(a6)
; Lecture des 8 premier octets du fichier.
	DLea	_DBase,a0
	Move.l	(a0),a6		; A6=Dos Base.
	DLea	_IcN,a1		; D1=File Name.
	Move.l	a1,d1
	Move.l	#1005,d2	; D2=Read File.
	Jsr	DosOpen(a6)
	DLea	_IHnd,a0
	Move.l	d0,(a0)		; Sauvegarde du File Handle.
	Move.l	#8,d3		; D3=Length = 8 octets .
	Move.l	d0,d1		; D1=File Handle.
	DLea	_IcLoad,a0
	Move.l	a0,d2		; d2=Adress
	Jsr	DosRead(a6)
	DLea	_IcLoad,a0
	Cmp.l	#"F.C2",(a0)
	Bne	_NotMplotFile	; Mauvais format.
; Fichier au format Icones.
	Add.l	#4,a0
	Move.l	(a0),d0
	DLea	_Mplots,a0
	Move.l	d0,(a0)		; Sauvegarde du nombre d'icones du fichier.
	Mulu	#6,d0
	Add.l	#8,d0		; D0=Byte size needed.
	Move.l	#Chip+Clear,d1	; D1=Requirements.
	Move.l	$4,a6
	Jsr	AllocMem(a6)
	Cmp.l	#0,d0		; Not enough memory available ???
	Beq	_NotMplotFile	; Pas assez de memoire pour le fichier.
	DLea	_MpBase,a0
	Move.l	d0,(a0)		; Save ICON BASE Adress.
	Move.l	d0,d7
	DLea	_DBase,a0
	Move.l	(a0),a6		; A6=DosBase.
	DLea	_IHnd,a0
	Move.l	(a0),d1		; D1=File Handle.
	DLea	_Mplots,a0
	Move.l	(a0),d3
	Mulu	#260,d3		; D3=Longueur de chargement du reste.
	Move.l	d7,a1		; A1=Icon Adress.
	Move.l	#"F.C2",(a1)+	; Remise en place du header.
	Move.l	(a0),(a1)+	; Remise en place du nombre d'icones.
	Move.l	a1,d2		; D2=Adresse de chargement.
	Jsr	DosRead(a6)
	DLea	_IHnd,a0
	Move.l	(a0),d1
	Jsr	DosClose(a6)
	Bra	_mie		
;
_NotMplotFile
; Fermeture du fichier.
	DLea	_IHnd,a0
	Move.l	(a0),d1
	DLea	_DBase,a0
	Move.l	(a0),a6
	Jsr	DosClose(a6)
;
	DLea	_Mplots,a0
	Move.l	#$0,(a0)
	DLea	_MpBase,a0
	Move.l	#$0,(a0)
	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#10,d0
	Rbra	L_CUSTOM
;
_mie	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPSAVE		Equ	97
L97	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,a0	; A0=Name Base
	DLea	_MpBase,a0
	Move.l	(a0),d0
	Cmp.l	#$0,d0
	Beq	NOMP
	Clr.l	d0
	Move.w	(a0)+,d0	; D0=Name Length.
	Cmp.l	#1,d0
	Blt	_sme
	Cmp.l	#95,d0
	Bgt	_sme
	DLea	_IcN,a1
; Mise en place du nom du fichier termine par '0' dans la zone reservee.
_sm1	Move.b	(a0)+,(a1)+
	Sub.l	#1,d0
	Cmp.l	#0,d0
	Bne	_sm1
	Move.b	#$0,(a1)
;
	Move.l	$4,a6
	DLea	_DName,a1
	Move.l	#0,d0
	Jsr	OpenLib(a6)
	DLea	_DBase,a1
	Move.l	d0,(a1)
	Move.l	d0,a1
	Jsr	CloseLib(a6)
; Creation du fichier.
	DLea	_DBase,a0
	Move.l	(a0),a6		; A6=Dos Base.
	DLea	_IcN,a1		; D1=File Name.
	Move.l	a1,d1
	Move.l	#1006,d2	; D2=Write File.
	Jsr	DosOpen(a6)
	DLea	_IHnd,a0
	Move.l	d0,(a0)		; D0=Icon File Handle.
	Move.l	d0,d1		; D1=Handle.
	DLea	_Mplots,a0
	Move.l	(a0),d3
	Mulu	#6,d3
	Add.l	#8,d3		; D3=File Length to be written.
	DLea	_MpBase,a0
	Move.l	(a0),d2		; D2=Icon Bank Base.
	Jsr	DosWrite(a6)
	DLea	_IHnd,a0
	Move.l	(a0),d1
	Jsr	DosClose(a6)
_sme	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Rts
NOMP	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPDEFINE		Equ	98
L98	Move.l	(a3)+,d4	; D4=Couleur.
	Move.l	(a3)+,d3	; D3=Y Pos.
	Move.l	(a3)+,d2	; D2=X Pos.
	Move.l	(a3)+,d1	; D1=Point.
	DLea	_MpBase,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq	_mpi1
	Cmp.l	#1,d1
	Blt	_mpi2
	Add.l	#4,a0
	Move.l	(a0)+,d0	; D0=Point Maxi.
	Cmp.l	d0,d1
	Bgt	_mpi2
	Sub.l	#1,d1
	Mulu	#6,d1
	Add.l	d1,a0
	Move.w	d2,(a0)+	; Save X Pos.
	Move.w	d3,(a0)+	; Save Y Pos.
	Move.w	d4,(a0)+	; Save Ink.
_mpi	Rts
_mpi1	Moveq	#11,d0
	Rbra	L_CUSTOM
_mpi2	Moveq	#13,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPBASE		Equ	99
L99	DLea	_MpBase,a0
	Move.l	(a0),d3
	Moveq	#$0,d2
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPDRAW		Equ	100
L100	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d1	; D1=Last Adress.
	Move.l	(a3)+,d0	; D2=First Adress.
	Sub.l	#1,d1
	Sub.l	#1,d0
	Mulu	#6,d0
	Mulu	#6,d1
	DLea	_MpBase,a4
	Move.l	(a4),a0
	Cmp.l	#0,a0
	Beq	mpd
	Add.l	#8,a0
	Move.l	a0,a1
	Add.l	d0,a0		; A0=First Real Adress.
	Add.l	d1,a1		; A1=Last Real Adress.
;
	DLea	_XY,a3
	Move.l	(a3)+,d7	; D7=X Screen Size.
	Move.l	(a3),d6		; D6=Y Screen Size.
	Sub.l	#1,d6
	Move.l	d7,d5
	Sub.l	#1,d5
	Lsr.l	#3,d7		; D7      en octets.
; Lecture du point
_Mpp0	Clr.l	d0
	Clr.l	d1
	Clr.l	d2
	Move.w	(a0)+,d0	; D0=X pos.
	Move.w	(a0)+,d1	; D1=Y pos.
; Si coordonnees NEGATIVES.
	Btst	#15,d0
	Beq	_Mp0
	Or.l	#$ffff0000,d0
_Mp0	Btst	#15,d1
	Beq	_Mp1
	Or.l	#$ffff0000,d1
; Decalage d'origine !!!
_Mp1	DLea	_Origin,a2
	Add.l	(a2)+,d0
	Add.l	(a2)+,d1
;
	Move.w	(a0)+,d2	; D2=Couleur du point.
; Verifications !!!
	Cmp.l	#0,d0
	Blt	_xxl
	Cmp.l	d5,d0
	Bgt	_xxl
	Cmp.l	#0,d1
	Blt	_xxl
	Cmp.l	d6,d1
	Bgt	_xxl
; Calcul du rajout aux bits plans.
	Mulu	d7,d1		; D1=Rajout pour se trouver a la bonne ligne.
	Move.l	d0,d3
	And.l	#$fffffff8,d3
	Sub.l	d3,d0		; D0=15-Bit to set/clear.
	Lsr.l	#3,d3
	Add.l	d3,d1		; D1=Rajout Aux BITS PLANS.   !!!
	Move.l	#$7,d4
	Sub.l	d0,d4
	Move.l	d4,d0		; D0=Bit to SET/CLEAR.        !!!
;
; Mise en place sur les bits plans
	Clr.l	d4
	DLea	_BitsPlanes,a4
_Mpp1	Move.l	(a4)+,a2
	Cmp.l	#$0,a2
	Beq	_xxl
	Add.l	d1,a2
	Clr.l	d3
	Move.b	(a2),d3
	Btst	d4,d2
	Beq	_MpClear
_MpSet
	Bset	d0,d3
	Bra	_MpSuite
_MpClear
	Bclr	d0,d3
_MpSuite
	Move.b	d3,(a2)
	Add.l	#1,d4
	DLea	_MpP,a3
	Move.l	(a3),d3
	Cmp.l	d3,d4
	Blt	_Mpp1
_xxl	Cmp.l	a0,a1
	Bgt	_Mpp0
_xxl2	Movem.l	(sp)+,a3-a6
	Add.l	#8,a3
	Rts
mpd	Movem.l	(sp)+,a3-a6
	Add.l	#8,a3
	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPX			Equ	101
L101	Move.l	(a3)+,d0
	Sub.l	#1,d0
	Mulu	#6,d0
	DLea	_MpBase,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	mpx2
	Add.l	#8,a1
	Add.l	d0,a1
	Clr.l	d3
	Move.w	(a1),d3
	Moveq	#0,d2
	Btst	#15,d3
	Beq	_mpx
	Or.l	#$ffff0000,d3
_mpx	Rts
mpx2	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPY			Equ	102
L102	Move.l	(a3)+,d0
	Sub.l	#1,d0
	Mulu	#6,d0
	DLea	_MpBase,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	mpy2
	Add.l	#10,a1
	Add.l	d0,a1
	Clr.l	d3
	Move.w	(a1),d3
	Moveq	#0,d2
	Btst	#15,d3
	Beq	_mpy
	Or.l	#$ffff0000,d3
_mpy	Rts
mpy2	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPC			Equ	103
L103	Move.l	(a3)+,d0
	Sub.l	#1,d0
	Mulu	#6,d0
	DLea	_MpBase,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	mpc2
	Add.l	#12,a1
	Add.l	d0,a1
	Clr.l	d3
	Move.w	(a1),d3
	Moveq	#0,d2
	Rts
mpc2	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPMODIFY		Equ	104
L104	Move.l	(a3)+,d7	; D7=Y add value.
	Move.l	(a3)+,d6	; D6=X add value.
	Move.l	(a3)+,d5	; D5=Last point.
	Move.l	(a3)+,d4	; D4=First point.
	Sub.l	#1,d4
	Sub.l	#1,d5
	Mulu	#6,d4
	Mulu	#6,d5
	DLea	_XY,a2
	Move.l	(a2)+,d2	; D2=X screen size.
	Move.l	(a2),d3		; D3=Y screen size.
	DLea	_MpBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_mpmx
	Add.l	#8,a0
	Move.l	a0,a1
	Add.l	d4,a0		; A0=Fisrt adress.
	Add.l	d5,a1		; A1=Last adress.
_xx	Clr.l	d0
	Clr.l	d1
	Move.w	(a0)+,d0	; D0=X pos.
	Move.w	(a0),d1		; D1=Y pos.
	Sub.l	#2,a0
	Add.l	d6,d0
	Cmp.l	d2,d0
	Blt	_mpm1
	Move.l	#0,d0
_mpm1	Cmp.l	#0,d0
	Bgt	_mpm2
	Beq	_mpm2
	Move.l	d2,d0
	Sub.l	#1,d0
_mpm2	Add.l	d7,d1
	Cmp.l	d3,d1
	Blt	_mpm3
	Move.l	#0,d1
_mpm3	Cmp.l	#0,d1
	Bgt	_mpm4
	Beq	_mpm4
	Move.l	d3,d1
	Sub.l	#1,d1
_mpm4	Move.w	d0,(a0)+
	Move.w	d1,(a0)+
	Add.l	#2,a0
	Cmp.l	a1,a0
	Blt	_xx
	Rts
_mpmx	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPMODIFY2		Equ	105
L105	Move.l	(a3)+,d7	; D7=X add value.
	Move.l	(a3)+,d6	; D6=Point to modify.
	DLea	_MpBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_mp21
	Sub.l	#1,d6
	Mulu	#6,d6
	Add.l	#8,a0
	Add.l	d6,a0
	Clr.l	d5
	Move.w	(a0),d5
	Add.l	d7,d5
	DLea	_XY,a2
	Move.l	(a2),d0
	Cmp.l	d0,d5
	Blt	_mp21a
	Move.l	#0,d5
_mp21a	Cmp.l	#0,d5
	Bgt	_mp21b
	Beq	_mp21b
	Move.l	d0,d5
	Sub.l	#1,d5
_mp21b	Move.w	d5,(a0)
	Rts
_mp21	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPMODIFY3		Equ	106
L106	Move.l	(a3)+,d7	; D7=y add value.
	Move.l	(a3)+,d6	; D6=Point to modify.
	DLea	_MpBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_mp22
	Sub.l	#1,d6
	Mulu	#6,d6
	Add.l	#10,a0
	Add.l	d6,a0
	Clr.l	d5
	Move.w	(a0),d5
	Add.l	d7,d5
	DLea	_XY,a2
	Add.l	#4,a2
	Move.l	(a2),d0
	Cmp.l	d0,d5
	Blt	_mp22a
	Move.l	#0,d5
_mp22a	Cmp.l	#0,d5
	Bgt	_mp22b
	Beq	_mp22b
	Move.l	d0,d5
	Sub.l	#1,d5
_mp22b	Move.w	d5,(a0)
	Rts
_mp22	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPMODIFY4		Equ	107
L107	Move.l	(a3)+,d7	; D7=X add value.
	Move.l	(a3)+,d6	; D6=Point to modify.
	DLea	_MpBase,a2
	Move.l	(a2),a0
	Cmp.l	#0,a0
	Beq	_mp23
	Sub.l	#1,d6
	Mulu	#6,d6
	Add.l	#12,a0
	Add.l	d6,a0
	Clr.l	d5
	Move.w	(a0),d5
	Add.l	d7,d5
	Move.l	#256,d0
	Cmp.l	d0,d5
	Blt	_mp23a
	Move.l	#0,d5
_mp23a	Cmp.l	#0,d5
	Bgt	_mp23b
	Beq	_mp23b
	Move.l	d0,d5
	Sub.l	#1,d5
_mp23b	Move.w	d5,(a0)
	Rts
_mp23	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPORIGIN		Equ	108
L108	DLea	_Origin,a0
	Move.l	(a3)+,d1
	Move.l	(a3)+,(a0)+
	Move.l	d1,(a0)+
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPPLANES		Equ	109
L109	Move.l	(a3)+,d0
	DLea	_MpP,a0
	Cmp.l	#1,d0
	Blt	_mppe
	Cmp.l	#8,d0
	Bgt	_mppe
	Move.l	d0,(a0)
	Rts
_mppe	Moveq	#14,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_LSRL			Equ	110
L110	Move.l	(a3)+,d1	; A1=Cible.
	Move.l	(a3)+,d0	; A0=Source.
	And.l	#$fffffffe,d1	; \ Mise a zero du bit 0 des deux sources
	And.l	#$fffffffe,d0	; / pour eviter les adresses impaires.
	Move.l	d0,a0
	Move.l	d1,a1
	Move.l	a1,a2
	Sub.l	#4,a1
_Lsr1	Move.l	(a1),(a2)
	Sub.l	#4,a1
	Sub.l	#4,a2
	Cmp.l	a0,a1
	Bgt	_Lsr1
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPDRAWDPF1	Equ	111
L111	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d1	; D1=Last Adress.
	Move.l	(a3)+,d0	; D2=First Adress.
	Sub.l	#1,d1
	Sub.l	#1,d0
	Mulu	#6,d0
	Mulu	#6,d1
	DLea	_MpBase,a4
	Move.l	(a4),a0
	Cmp.l	#0,a0
	Beq	ampd
	Add.l	#8,a0
	Move.l	a0,a1
	Add.l	d0,a0		; A0=First Real Adress.
	Add.l	d1,a1		; A1=Last Real Adress.
;
	DLea	_XY,a3
	Move.l	(a3)+,d7	; D7=X Screen Size.
	Move.l	(a3),d6		; D6=Y Screen Size.
	Sub.l	#1,d6
	Move.l	d7,d5
	Sub.l	#1,d5
	Lsr.l	#3,d7		; D7      en octets.
; Lecture du point
a_Mpp0	Clr.l	d0
	Clr.l	d1
	Clr.l	d2
	Move.w	(a0)+,d0	; D0=X pos.
	Move.w	(a0)+,d1	; D1=Y pos.
; Si coordonnees NEGATIVES.
	Btst	#15,d0
	Beq	a_Mp0
	Or.l	#$ffff0000,d0
a_Mp0	Btst	#15,d1
	Beq	a_Mp1
	Or.l	#$ffff0000,d1
; Decalage d'origine !!!
a_Mp1	DLea	_Origin,a2
	Add.l	(a2)+,d0
	Add.l	(a2)+,d1
;
	Move.w	(a0)+,d2	; D2=Couleur du point.
; Verifications !!!
	Cmp.l	#0,d0
	Blt	a_xxl
	Cmp.l	d5,d0
	Bgt	a_xxl
	Cmp.l	#0,d1
	Blt	a_xxl
	Cmp.l	d6,d1
	Bgt	a_xxl
; Calcul du rajout aux bits plans.
	Mulu	d7,d1		; D1=Rajout pour se trouver a la bonne ligne.
	Move.l	d0,d3
	And.l	#$fffffff8,d3
	Sub.l	d3,d0		; D0=15-Bit to set/clear.
	Lsr.l	#3,d3
	Add.l	d3,d1		; D1=Rajout Aux BITS PLANS.   !!!
	Move.l	#$7,d4
	Sub.l	d0,d4
	Move.l	d4,d0		; D0=Bit to SET/CLEAR.        !!!
;
; Mise en place sur les bits plans
	Move.l	#$0,d4
	DLea	_BitsPlanes,a4
a_Mpp	Move.l	(a4)+,a2
	Add.l	#4,a4
	Cmp.l	#$0,a2
	Beq	a_xxl
	Add.l	d1,a2
	Move.b	(a2),d3
	Btst	d4,d2
	Beq	a_MpClear
a_MpSet
	Bset	d0,d3
	Bra	a_MpSuite
a_MpClear
	Bclr	d0,d3
a_MpSuite
	Move.b	d3,(a2)
	Add.l	#1,d4
	DLea	_MpP,a3
	Move.l	(a3),d3
	Cmp.l	d3,d4
	Bne	a_Mpp
a_xxl	Cmp.l	a0,a1
	Bgt	a_Mpp0
a_xxl2	Movem.l	(sp)+,a3-a6
	Add.l	#8,a3
	Rts
ampd	Movem.l	(sp)+,a3-a6
	Add.l	#8,a3
	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MPDRAWDPF2		Equ	112
L112	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d1	; D1=Last Adress.
	Move.l	(a3)+,d0	; D2=First Adress.
	Sub.l	#1,d1
	Sub.l	#1,d0
	Mulu	#6,d0
	Mulu	#6,d1
	DLea	_MpBase,a4
	Move.l	(a4),a0
	Cmp.l	#0,a0
	Beq	bmpd
	Add.l	#8,a0
	Move.l	a0,a1
	Add.l	d0,a0		; A0=First Real Adress.
	Add.l	d1,a1		; A1=Last Real Adress.
;
	DLea	_XY,a3
	Move.l	(a3)+,d7	; D7=X Screen Size.
	Move.l	(a3),d6		; D6=Y Screen Size.
	Sub.l	#1,d6
	Move.l	d7,d5
	Sub.l	#1,d5
	Lsr.l	#3,d7		; D7      en octets.
; Lecture du point
b_Mpp0	Clr.l	d0
	Clr.l	d1
	Clr.l	d2
	Move.w	(a0)+,d0	; D0=X pos.
	Move.w	(a0)+,d1	; D1=Y pos.
; Si coordonnees NEGATIVES.
	Btst	#15,d0
	Beq	b_Mp0
	Or.l	#$ffff0000,d0
b_Mp0	Btst	#15,d1
	Beq	b_Mp1
	Or.l	#$ffff0000,d1
; Decalage d'origine !!!
b_Mp1	DLea	_Origin,a2
	Add.l	(a2)+,d0
	Add.l	(a2)+,d1
;
	Move.w	(a0)+,d2	; D2=Couleur du point.
; Verifications !!!
	Cmp.l	#0,d0
	Blt	b_xxl
	Cmp.l	d5,d0
	Bgt	b_xxl
	Cmp.l	#0,d1
	Blt	b_xxl
	Cmp.l	d6,d1
	Bgt	b_xxl
; Calcul du rajout aux bits plans.
	Mulu	d7,d1		; D1=Rajout pour se trouver a la bonne ligne.
	Move.l	d0,d3
	And.l	#$fffffff8,d3
	Sub.l	d3,d0		; D0=15-Bit to set/clear.
	Lsr.l	#3,d3
	Add.l	d3,d1		; D1=Rajout Aux BITS PLANS.   !!!
	Move.l	#$7,d4
	Sub.l	d0,d4
	Move.l	d4,d0		; D0=Bit to SET/CLEAR.        !!!
;
; Mise en place sur les bits plans
	Move.l	#$0,d4
	DLea	_BitsPlanes,a4
	Add.l	#4,a4
b_Mpp	Move.l	(a4)+,a2
	Add.l	#4,a4
	Cmp.l	#$0,a2
	Beq	b_xxl
	Add.l	d1,a2
	Move.b	(a2),d3
	Btst	d4,d2
	Beq	b_MpClear
b_MpSet
	Bset	d0,d3
	Bra	b_MpSuite
b_MpClear
	Bclr	d0,d3
b_MpSuite
	Move.b	d3,(a2)
	Add.l	#1,d4
	DLea	_MpP,a3
	Move.l	(a3),d3
	Cmp.l	d3,d4
	Bne	b_Mpp
b_xxl	Cmp.l	a0,a1
	Bgt	b_Mpp0
b_xxl2	Movem.l	(sp)+,a3-a6
	Add.l	#8,a3
	Rts
bmpd	Movem.l	(sp)+,a3-a6
	Add.l	#8,a3
	Moveq	#11,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L113
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L114
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L115
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L116
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L117
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L118
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L119
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L120
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L121
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CUSTOM		Equ	122
L122	Lea	ErrMess(pc),a0
	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#0,d3
	Rjmp	L_ErrorExt
; Error Selection Messages
_NoCopperList
	Moveq	#1,d0
	Rbra	L_CUSTOM
; Error List.
ErrMess	Dc.b	"Adresse pour copper list INVALIDE.",0		;  0
	Dc.b	"Copper list non reservee.",0			;  1
	Dc.b	"Registre de couleur invalide.",0		;  2
	Dc.b	"BMHD non trouve.",0				;  3
	Dc.b	"Une ou plusieurs bases ecran INVALIDE(S).",0	;  4
	Dc.b	"Banque memoire trop petite.",0			;  5
	Dc.b	"CMAP non trouve.Fichier IFF/ILBM corrompu.",0	;  6
	Dc.b	"2e Ecran copper non cree.",0			;  7
	Dc.b	"Pas assez de memoire pour l'allocation!!!",0	;  8
	Dc.b	"Aga Icon bank non reservee.",0			;  9
	Dc.b	"Fichier d'un format inconnu.",0		; 10
	Dc.b	"Multi Plot bank non reservee.",0		; 11
	Dc.b	"Multi Plot bank deja reservee.",0		; 12
	Dc.b	"Point demande HORS limite de reservation.",0	; 13
	Dc.b	"Valeur permise de 1 a 8 seulement.",0		; 14
	Dc.b	"Aga Icon bank deja reservee.",0		; 15
	EVEN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L123	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#-1,d3
	Rjmp	L_ErrorExt
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L124
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_TITLE
		Dc.b	"Amos1.3/AmosPro Personnal Extension V1.1"
		Dc.b	0
		Dc.b	"Version Enregistrée COMPILABLE."
;		Dc.b	0
		Even
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_END		Dc.w	0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Ne Jamais Oublier :
;
;	A > Lire Des Donnees De L'Amos
;		1 > A3(.l)=Adresse des valeurs
;		 ( Toujours remettre A3 a sa valeur initiale avant un RTS )
;		    A0(.w)=Longueur des textes (Strings)
;		2 > A4,A5,A6 ne doivent aucunement etre modifies
;		3 > D0,D1,D2,D3,D4,D5,D6,
;	B > Si l'utilisation des registres a3,a4,a5,a6 est obligatoire,
;		1 > Au debut de la routine faire : MOVEM.L A3-A6,-(SP)
;		2 > Utiliser a3,a4,a5,a6 a sa guise,
;		3 > A la fin de la routine : MOVEM.L (SP)+,A3-A6
;		4 > Ne pas oublier de remettre A3 a sa valeur initiale !!!
;
