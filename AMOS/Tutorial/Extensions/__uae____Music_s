
;---------------------------------------------------------------------
;    **   **   **  ***   ***   ****     **    ***  **  ****
;   ****  *** *** ** ** **     ** **   ****  **    ** **  **
;  **  ** ** * ** ** **  ***   *****  **  **  ***  ** **
;  ****** **   ** ** **    **  **  ** ******    ** ** **
;  **  ** **   ** ** ** *  **  **  ** **  ** *  ** ** **  **
;  **  ** **   **  ***   ***   *****  **  **  ***  **  ****
;---------------------------------------------------------------------
; Music extension source code for AMOSPro, Last change 29/09/1992
; By Francois Lionet
; AMOS, AMOSPro AMOS Compiler (c) Europress Software 1990-1992
; To be used with AMOSPro 1.0 and over
;--------------------------------------------------------------------- 
; This file is public domain
;---------------------------------------------------------------------
;
Version		MACRO
		dc.b	"1.0"
		ENDM
;
;
; This listing explains how to create an extension for AMOSPro.
; The AMOSPro compiler will be compatible with these extension.
;
;	If you have made an extension for AMOS 1.3, just read the
; file called New_In_Pro.Asc to know the difference between the
; extension format. Not many changes, only new equates, and some
; new functions.
;
; >>> What's an extension?
;
; An extension to AMOS is a machine language program that adds new 
; instructions to the already huge AMOS instruction set. This system is
; designed to be as powerfull as AMOS itself: the extension includes its 
; own token list, its own routines. It can even access some main AMOS
; routines via special macros. It has a total access to the internal AMOS 
; data zone, and to the graphic library functions.
;
; To produce your own extension, I suggest you copy and rename this
; file, and remove the used code. This way you will not forgive one line.
; Also keep in mind that you can perfectly call AMOS from within MONAM2,
; and set some ILLEGAL instructions where you want to debug. To flip back to
; MONAM2 display, just press AMIGA-A.
;
; I have designed the extension system so that one only file works with 
; both AMOS interpretor and compiler. 
; 	- The extension is more a compiler library than a one chunk program:
;	it is done so that the compiler can pick one routine here and there
;	to cope with the program it is compiling.
;	- AMOSPro extension loader works a little like the compiler, exept
;	that all instructions are loaded and relocated.
;
; This code was assembled with GENIM2 on a A3000 25 Mhz machine, but a
; A500 can do it very well!
; The assembled program must be ONE CHUNK only, you must not link the 
; the symbol table with it. Also be sure that you program is totally 
; relocatable (see later) : if not it will add a relocation chunk to 
; the output code, and your extension will simply crash AMOS on loading
; (and the compiler too!).

;
; Here we go now!
;
; Here comes the number of the extension in the list of extensions in
; AMOSPro_Interpretor_Config program (minus one).
; This number is used later to reference the extension in internal AMOS 
; tables...
;
ExtNb		equ	1-1

; You must include this file, it will decalre everything for you.
		Include	"|AMOS_Includes.s"
; A usefull macro to find the address of data in the extension's own 
; datazone (see later)...
DLea		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\2
		add.w	#\1-MB,\2
		ENDM

; Another macro to load the base address of the datazone...
DLoad		MACRO
		move.l	ExtAdr+ExtNb*16(a5),\1
		ENDM

; Now some equates used by the music extension itself. Ignore this in your
; code!

Translate	equ -30

*************** Enveloppes definitions
		RsReset
EnvNb:		rs.w	1
EnvDVol:	rs.w	1
EnvVol:		rs.l	1
EnvDelta:	rs.l 	1
EnvAd:		rs.l	1
EnvDeb:		rs.l	1
EnvLong:	equ 	__Rs

*************** Wave definition
LWave:		equ 	256+128+64+32+16+8+4+2
LNoise:		equ 	LWave
		RsReset
WaveNext:	rs.l	1
WaveNb:		rs.w	1
WaveEnv:	rs.w	16*2
WaveDeb:	rs.b	LWave
WaveLong:	equ 	__Rs

*************** Music voice data
		RsReset
VoiAdr		rs.l	1
VoiDeb		rs.l	1
VoiInst		rs.l	1
VoiDPat		rs.l	1
VoiPat		rs.l	1
VoiCpt		rs.w	1
VoiRep		rs.w	1
VoiNote		rs.w	1
VoiDVol		rs.w	1
VoiVol		rs.w	1
VoiEffect	rs.l	1
VoiValue	rs.w	1
VoiPToTo	rs.w	1
VoiPTone	rs.b	1
VoiVib		rs.b	1
VoiLong		equ 	__Rs

*************** MUBASE table
		RsReset
* Voix 0
MuVoix0		equ	__Rs
VoiAdr0		rs.l	1
VoiDeb0		rs.l	1
VoiInst0	rs.l	1
VoiDPat0	rs.l	1
VoiPat0		rs.l	1
VoiCpt0		rs.w	1
VoiRep0		rs.w	1
VoiNote0	rs.w	1
VoiDVol0	rs.w	1
VoiVol0		rs.w	1
VoiEffect0	rs.l	1
VoiValue0	rs.w	1
VoiPToTo0	rs.w	1
VoiPTone0	rs.b	1
VoiVib0		rs.b	1
* Voix 1
MuVoix1		equ	__Rs
VoiAdr1		rs.l	1
VoiDeb1		rs.l	1
VoiInst1	rs.l	1
VoiDPat1	rs.l	1
VoiPat1		rs.l	1
VoiCpt1		rs.w	1
VoiRep1		rs.w	1
VoiNote1	rs.w	1
VoiDVol1	rs.w	1
VoiVol1		rs.w	1
VoiEffect1	rs.l	1
VoiValue1	rs.w	1
VoiPToTo1	rs.w	1
VoiPTone1	rs.b	1
VoiVib1		rs.b	1
* Voix 2
MuVoix2		equ	__Rs
VoiAdr2		rs.l	1
VoiDeb2		rs.l	1
VoiInst2	rs.l	1
VoiDPat2	rs.l	1
VoiPat2		rs.l	1
VoiCpt2		rs.w	1
VoiRep2		rs.w	1
VoiNote2	rs.w	1
VoiDVol2	rs.w	1
VoiVol2		rs.w	1
VoiEffect2	rs.l	1
VoiValue2	rs.w	1
VoiPToTo2	rs.w	1
VoiPTone2	rs.b	1
VoiVib2		rs.b	1
* Voix 3
MuVoix3		equ	__Rs
VoiAdr3		rs.l	1
VoiDeb3		rs.l	1
VoiInst3	rs.l	1
VoiDPat3	rs.l	1
VoiPat3		rs.l	1
VoiCpt3		rs.w	1
VoiRep3		rs.w	1
VoiNote3	rs.w	1
VoiDVol3	rs.w	1
VoiVol3		rs.w	1
VoiEffect3	rs.l	1
VoiValue3	rs.w	1
VoiPToTo3	rs.w	1
VoiPTone3	rs.b	1
VoiVib3		rs.b	1

* Other data
MuCpt		rs.w	1
MuTempo		rs.w	1
MuStart		rs.w	1
MuStop		rs.w	1
* Total length
MuLong		equ 	__Rs

IntEnaR		equ	$1c
IntReqR		equ	$1e
is_data		equ	$0e
is_code		equ	$12
ln_pri		equ	$09
ln_type		equ	$08

; All the above did not produce any byte of code. Here is the real beginning
; of the program. It MUST begin by a small table of pointers so that both
; AMOS and the compiler know where to get their data...
; Please remark that everything is relocatable...

******************************************************************
*	AMOSPro MUSIC EXTENSION
;
; First, a pointer to the token list
Start	dc.l	C_Tk-C_Off
;
; Then, a pointer to the first library function
	dc.l	C_Lib-C_Tk
;
; Then to the title
	dc.l	C_Title-C_Lib
;
; From title to the end of the program
	dc.l	C_End-C_Title
;
; An important flag. Imagine a program does not call your extension, the 
; compiler will NOT copy any routine from it in the object program. For 
; certain extensions, like MUSIC, COMPACT, it is perfect.
; But for the REQUEST extension, even if it is not called, the first routine 
; MUST be called, otherwise AMOS requester will not work!
; So, a value of 0 indicates to copy if needed only,
; A value of -1 forces the copy of the first library routine...
	dc.w	0	

******************************************************************
*	Offset to library
;
; This list contains all informations for the compiler 
; and AMOS to locate your routines, in a relocatable way.
; You can produce such tables using the MAKE_LABEL.AMOS utility, found 
; on this very disc.
; All labels MUST be in order. The size of each routine MUST BE EVEN,
; as the size is divided by two. So be carefull to put an EVEN instruction
; after some text...
; You easily understand that the size of each routine can reach 128K, 
; which is largely enough. You can have up to 2000 routines in the list.
; The main AMOS.Lib library has 1100 labels...

C_Off   dc.w (L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2
        dc.w (L5-L4)/2,(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
        dc.w (L9-L8)/2,(L10-L9)/2,(L11-L10)/2,(L12-L11)/2
        dc.w (L13-L12)/2,(L14-L13)/2,(L15-L14)/2,(L16-L15)/2
        dc.w (L17-L16)/2,(L18-L17)/2,(L19-L18)/2,(L20-L19)/2
        dc.w (L21-L20)/2,(L22-L21)/2,(L23-L22)/2,(L24-L23)/2
        dc.w (L25-L24)/2,(L26-L25)/2,(L27-L26)/2,(L28-L27)/2
        dc.w (L29-L28)/2,(L30-L29)/2,(L31-L30)/2,(L32-L31)/2
        dc.w (L33-L32)/2,(L34-L33)/2,(L35-L34)/2,(L36-L35)/2
        dc.w (L37-L36)/2,(L38-L37)/2,(L39-L38)/2,(L40-L39)/2
        dc.w (L41-L40)/2,(L42-L41)/2,(L43-L42)/2,(L44-L43)/2
        dc.w (L45-L44)/2,(L46-L45)/2,(L47-L46)/2,(L48-L47)/2
        dc.w (L49-L48)/2,(L50-L49)/2,(L51-L50)/2,(L52-L51)/2
        dc.w (L53-L52)/2,(L54-L53)/2,(L55-L54)/2,(L56-L55)/2
        dc.w (L57-L56)/2,(L58-L57)/2,(L59-L58)/2,(L60-L59)/2
        dc.w (L61-L60)/2,(L62-L61)/2,(L63-L62)/2,(L64-L63)/2
        dc.w (L65-L64)/2,(L66-L65)/2,(L67-L66)/2,(L68-L67)/2
        dc.w (L69-L68)/2,(L70-L69)/2,(L71-L70)/2,(L72-L71)/2
        dc.w (L73-L72)/2,(L74-L73)/2,(L75-L74)/2,(L76-L75)/2
        dc.w (L77-L76)/2,(L78-L77)/2,(L79-L78)/2,(L80-L79)/2
        dc.w (L81-L80)/2,(L82-L81)/2,(L83-L82)/2,(L84-L83)/2
        dc.w (L85-L84)/2,(L86-L85)/2,(L87-L86)/2,(L88-L87)/2
	dc.w (L89-L88)/2,(L90-L89)/2,(L91-L90)/2,(L92-L91)/2
        dc.w (L93-L92)/2,(L94-L93)/2,(L95-L94)/2,(L96-L95)/2
        dc.w (L97-L96)/2,(L98-L97)/2,(L99-L98)/2,(L100-L99)/2
        dc.w (L101-L100)/2,(L102-L101)/2,(L103-L102)/2,(L104-L103)/2
        dc.w (L105-L104)/2,(L106-L105)/2,(L107-L106)/2,(L108-L107)/2
        dc.w (L109-L108)/2,(L110-L109)/2,(L111-L110)/2,(L112-L111)/2
	dc.w (L113-L112)/2,(L114-L113)/2

; Do not forget the LAST label!!!

******************************************************************
*	TOKEN TABLE
;
;
;	
; This table is the crucial point of the extension! It tells
; everything the tokenisation process needs to know. You have to 
; be carefull when writing it!
;
; The format is simple:
;	dc.w	Number of instruction,Number of function
;	dc.b	"instruction nam","e"+$80,"Param list",-1[or -2]
;
;	(1) Number of instruction / function
;		You must state the one that is needed for this token.
;               I suggest you keep the same method of referencing the
;		routines than mine: L_name, this label being defined
;		in the main program. (If you come from a 1.23 extension,
;		changing your program is easy: just add L_ before the 
;		name of each routine.
;		A -1 means take no routine is called (example a 
;		instruction only will have a -1 in the function space...)
;
;	(2) Instruction name
;		It must be finished by the letter plus $80. Be carefull
;		ARGASM assembler produces bad code if you do "a"+$80, 
;		he wants $80+"a"!!!
;		- You can SET A MARK in the token table with a "!" before
;		the name. See later
;		-Using a $80 ALONE as a name definition, will force AMOS
;		to point to the previous "!" mark...
;	
;	(3) Param list
;		This list tells AMOS everything about the instruction.
;
;	- First character:
;		The first character defines the TYPE on instruction:
;			I--> instruction
;			0--> function that returns a integer
;			1--> function that returns a float
;			2--> function that returns a string
;			V--> reserved variable. In that case, you must
;				state the type int-float-string
;	- If your instruction does not need parameters, then you stop
;	- Your instruction needs parameters, now comes the param list
;			Type,TypetType,Type...
;		Type of the parameter (0 1 2)
;		Comma or "t" for TO
;
;	(4) End of instruction
;			"-1" states the end of the instruction
;			"-2" tells AMOS that another parameter list
;			     can be accepted. if so, MUST follow the
;			     complete instruction definition as explained
;			     but with another param list.
;	If so, you can use the "!" and $80 facility not to rewrite the
;	full name of the instruction...See SAM LOOP ON instruction for an
;	example...
;
;	Remember that AMOS token list comes first, so names like:
;	PRINTHELLO will never work: AMOS will tokenise PRINT first!
;	Extension token list are explored in order of number...

; The next two lines needs to be unchanged...
C_Tk:	dc.w 	1,0
	dc.b 	$80,-1

; Now the real tokens...
	dc.w	-1,L_FMB
	dc.b	"mubas","e"+$80,"0",-1
	dc.w	-1,L_FVu
	dc.b	"vumete","r"+$80,"00",-1
	dc.w	L_IVoice,-1
	dc.b	"voic","e"+$80,"I0",-1
	dc.w	L_IMusOff,-1
	dc.b	"music of","f"+$80,"I",-1
	dc.w	L_IMuStop,-1
	dc.b	"music sto","p"+$80,"I",-1
	dc.w	L_ITempo,-1
	dc.b	"temp","o"+$80,"I0",-1
	dc.w	L_IMusic,-1
	dc.b	"musi","c"+$80,"I0",-1

	dc.w	L_INoTo,-1
	dc.b	"noise t","o"+$80,"I0",-1
	dc.w	L_Boom,-1
	dc.b 	"boo","m"+$80,"I",-1
	dc.w	L_Shoot,-1
	dc.b	"shoo","t"+$80,"I",-1
	dc.w	L_ISBank,-1
	dc.b	"sam ban","k"+$80,"I0",-1
	dc.w	L_ISLOn0,-1
	dc.b	"!sam loop o","n"+$80,"I",-2
	dc.w	L_ISLOn1,-1
	dc.b	$80,"I",-1
	dc.w	L_ISLOf0,-1
	dc.b	"sam loop of","f"+$80,"I",-2
	dc.w	L_ISLOf1,-1
	dc.b	$80,"I0",-1
	dc.w	L_ISamTo,-1
	dc.b	"sampl","e"+$80,"I0t0",-1
	dc.w 	L_ISam1,-1
	dc.b 	"!sam pla","y"+$80,"I0",-2
	dc.w	L_ISam2,-1
	dc.b	$80,"I0,0",-2
	dc.w 	L_ISam3,-1
	dc.b	$80,"I0,0,0",-1 
	dc.w 	L_ISamR,-1
	dc.b 	"sam ra","w"+$80,"I0,0,0,0",-1	
	dc.w	L_Bell0,-1
	dc.b 	"!bel","l"+$80,"I",-2
	dc.w 	L_Bell1,-1
	dc.b	$80,"I0",-1
	dc.w	L_IPlOf0,-1
	dc.b	"!play of","f"+$80,"I",-2
	dc.w	L_IPlOf1,-1
	dc.b	$80,"I0",-1
	dc.w 	L_IPlay2,-1
	dc.b	"!pla","y"+$80,"I0,0",-2
	dc.w	L_IPlay3,-1
	dc.b	$80,"I0,0,0",-1
	dc.w 	L_ISWave,-1
	dc.b 	"set wav","e"+$80,"I0,2",-1
	dc.w	L_IDWave1,-1
	dc.b	"del wav","e"+$80,"I0",-1
	dc.w	L_ISEnv,-1
	dc.b	"set enve","l"+$80,"I0,0t0,0",-1
	dc.w	L_IMVol,-1
	dc.b	"mvolum","e"+$80,"I0",-1
	dc.w 	L_IVol1,-1
	dc.b	"!volum","e"+$80,"I0",-2
	dc.w 	L_IVol2,-1
	dc.b	$80,"I0,0",-1
	dc.w	L_IWave,-1
	dc.b 	"wav","e"+$80,"I0t0",-1
	dc.w	L_LedOn,-1
	dc.b	"led o","n"+$80,"I",-1
	dc.w	L_LedOf,-1
	dc.b	"led of","f"+$80,"I",-1
	dc.w	L_ISay1,-1
	dc.b	"!sa","y"+$80,"I2",-2
	dc.w	L_ISay2,-1
	dc.b	$80,"I2,0",-1
	dc.w	L_ITalk,-1
	dc.b	"set tal","k"+$80,"I0,0,0,0",-1
	dc.w	L_SLoad,-1
	dc.b	"sloa","d"+$80,"I0t0,0",-1
	dc.w	-1,L_Samswapped
	dc.b	"sam swappe","d"+$80,"00",-1
	dc.w	L_SamSwap,-1
	dc.b	"sam swa","p"+$80,"I0t0,0",-1
	dc.w 	L_SamStop0,-1
	dc.b	"!sam sto","p"+$80,"I",-2
	dc.w	L_SamStop1,-1
	dc.b	$80,"I0",-1

	dc.w	L_TrackStop,-1
	dc.b	"track sto","p"+$80,"I",-1
	dc.w	L_TrackLoopon,-1
	dc.b	"track loop o","n"+$80,"I",-1
	dc.w	L_TrackLoopof,-1
	dc.b	"track loop o","f"+$80,"I",-1
	dc.w	L_TrackPlay0,-1
	dc.b	"!track pla","y"+$80,"I",-2
	dc.w	L_TrackPlay1,-1
	dc.b	$80,"I0",-2
	dc.w	L_TrackPlay2,-1
	dc.b	$80,"I0,0",-1
	dc.w	L_TrackLoad,-1
	dc.b	"track loa","d"+$80,"I2,0",-1
	
	dc.w	-1,L_LipsX
	dc.b	"mouth widt","h"+$80,"0",-1
	dc.w	-1,L_LipsY
	dc.b	"mouth heigh","t"+$80,"0",-1
	dc.w	L_Lips,-1
	dc.b	"mouth rea","d"+$80,"I",-1
	dc.w	L_NarStop,-1
	dc.b	"talk sto","p"+$80,"I",-1
	dc.w	L_TalkMisc,-1
	dc.b	"talk mis","c"+$80,"I0,0",-1

	dc.w	L_SSave,-1
	dc.b	"ssav","e"+$80,"I0,0t0",-1

	dc.w	L_MedLoad,-1
	dc.b	"med loa","d"+$80,"I2,0",-1
	dc.w	L_MedPlay0,-1
	dc.b	"!med pla","y"+$80,"I",-2
	dc.w	L_MedPlay1,-1
	dc.b	$80,"I0",-2
	dc.w	L_MedPlay2,-1
	dc.b	$80,"I0,0",-1
	dc.w	L_MedStop,-1
	dc.b	"med sto","p"+$80,"I",-1
	dc.w	L_MedCont,-1
	dc.b	"med con","t"+$80,"I",-1
	dc.w	L_MedMidiOn,-1
	dc.b	"med midi o","n"+$80,"I",-1
	dc.w 	0

;
; Now come the big part, the library. Every routine is delimited by the
; two labels: L(N) and L(N+1).
; AMOS loads the whole extension, but the compiler works differently:
; The compiler picks each routine in the library and copy it into the
; program, INDIVIDUALLY. It means that you MUST NEVER perform a JMP, a
; BSR or get an address from one library routine to another: the distance
; between them may change!!! Use the special macros instead...
;
; Importants points to follow: 
;
;	- Your code must be (pc), TOTALLY relocatable, check carefully your
;  	code!
;	- You cannot directly call other library routines from one routine
;	by doing a BSR, but I have defined special macros (in S_CEQU file) 
;	to allow you to easily do so. Here is the list of available macros:
;
;	RBsr	L_Routine	does a simple BSR to the routine
;	RBra	L_Routine	as a normal BRA
;	RBeq	L_Routine	as a normal Beq
;	RBne	L_Routine	...
;	RBcc	L_Routine
;	RBcs	L_Routine
;	RBlt	L_Routine
;	RBge	L_Routine
;	RBls	L_Routine
;	RBhi	L_Routine
;	RBle	L_Routine
;	RBpl	L_Routine
;	RBmi	L_Routine
;
; I remind you that you can only use this to call an library routine
; from ANOTHER routine. You cannot do a call WITHIN a routine, or call
; the number of the routine your caling from...
; The compiler (and AMOSPro extension loading part) will manage to find
; the good addresses in your program from the offset table.
;
; You can also call some main AMOS.Lib routines, to do so, use the 
; following macros:
;
;	RJsr	L_Routine	
;	RJmp	L_Routine	
; 
; 
; As you do not have access any more to the small table with jumps to the
; routines within AMOS, here is the concordance of the routines (the numbers
; are just refecrences to the old AMOS 1.23 calling table, and is not of
; any use in AMOS1.3):
;
;
;	RJsr	L_Error
; ~~~~~~~~~~~~~~~~~~~~~
;	Jump to normal error routine. See end of listing
;
;	RJsr	L_ErrorExt
; ~~~~~~~~~~~~~~~~~~~~~~~~
;	Jump to specific error routine. See end of listing.
;
; 	RJsr	L_Tests
; ~~~~~~~~~~~~~~~~~~~~~
;	Perform one AMOSPro updating procedure, update screens, sprites,
;	bobs etc. You should use it for wait loops.
;
;	RJsr	L_WaitRout
; ~~~~~~~~~~~~~~~~~~~~~~~~
;	See play instruction.
;
;	RJsr	L_GetEc
; ~~~~~~~~~~~~~~~~~~~~~
;	Get screen address: In: D0.l= number, Out: A0=address
;
;	RJsr	L_Demande
; ~~~~~~~~~~~~~~~~~~~~~~~
;	Ask for string space.
;	D3.l is the length to ask for. Return A0/A1 point to free space.
;	Poke your string there, add the length of it to A0, EVEN the 
;	address to the highest multiple of two, and move it into
;	HICHAINE(a5) location...
;
;	RJsr	L_RamChip
; ~~~~~~~~~~~~~~~~~~~~~
;	Ask for PUBLIC|CLEAR|CHIP ram, size D0, return address in D0, nothing
;	changed, Z set according to the success.
;
;	RJsr	L_RamChip2
; ~~~~~~~~~~~~~~~~~~~~~~
;	Same for PUBLIC|CHIP
;
;	RJsr	L_RamFast
; ~~~~~~~~~~~~~~~~~~~~~
;	Same for PUBLIC|CLEAR
;
;	RJsr	L_RamFast2
; ~~~~~~~~~~~~~~~~~~~~~~~~
;	Same for PUBLIC
;
;	RJsr	L_RamFree
; ~~~~~~~~~~~~~~~~~~~~~~~
;	Free memory A1/D0
;
;	RJsr	L_Bnk.OrAdr
; ~~~~~~~~~~~~~~~~~~~~~~~~~
;	Find whether a number is a address or a	memory bank number
;	IN: 	D0.l= number 
;	OUT: 	D0/A0= number or start(number)
;
;	RJsr	L_Bnk.GetAdr
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Find the start of a memory bank.
;	IN:	D0.l=	Bank number
;	OUT:	A0=	Bank address
;		D0.w=	Bank flags
;		Z set if bank not defined.
;
;	RJsr	L_Bnk.GetBobs
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Returns the address of the bob's bank
;	IN:
;	OUT:	Z 	Set if not defined
;		A0=	address of bank
;
;	RJsr	L_Bnk.GetIcons
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Returns the address of the icons bank
;	IN:
;	OUT:	Z 	Set if not defined
;		A0=	address of bank
;
;	RJsr	L_Bnk.Reserve
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Reserve a memory bank.
;	IN:	D0.l	Number
;		D1	Flags
;		D2	Length
;		A0	Name of the bank (8 bytes)
;	OUT:	Z 	Set inf not successfull
;		A0	Address of bank
;	FLAGS:	
;		Bnk_BitData		Data bank
;		Bnk_BitChip		Chip bank
;		Example:	Bset	#Bnk_BitData|Bnk_BitChip,d1
;	NOTE: 	you should call L_Bnk.Change after reserving/erasing a bank.
;
;	RJsr	L_Bnk.Eff
; ~~~~~~~~~~~~~~~~~~~~~~~
;	Erase one memory bank.
;	IN:	D0.l	Number
;	OUT:	
;
;	RJsr	L_Bnk.EffA0
; ~~~~~~~~~~~~~~~~~~~~~~~~~
;	Erase a bank from its address.
;	IN:	A0	Start(bank)
;	OUT:	
;
;	RJsr	L_Bnk.EffTemp
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Erase all temporary banks
;	IN:
;	OUT:
;
;	RJsr	L_Bnk.EffAll
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Erase all banks
;	IN:
;	OUT:
;
;	RJsr	L_Bnk.Change
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Inform the extension, the bob handler that something has changed
;	in the banks. You should use this function after every bank
;	reserve / erase.
;	IN:
;	OUT:
;
; 	RJsr	L_Dsk.PathIt
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Add the current AMOS path to a file name.
;	IN:	(Name1(a5)) contains the name, finished by zero
;	OUT:	(Name1(a5)) contains the name with new path
;	Example:
;		move.l	Name1(a5),a0
;		move.l	#"Kiki",(a0)+
;		clr.b	(a0)
;		RJsr	L_Dsk.PathIt
;		... now I load in the current directory
;
;	RJsr	 L_Dsk.FileSelector
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Call the file selector.
;	IN:	12(a3)	Path+filter
;		8(a3)	Default name
;		4(a3)	Title 2
;		0(a3)	Title 1
;		All strings must be in AMOS string format:
;			dc.w	Length
;			dc.b 	"String"
;	OUT:	D0.w	Length of the result. 0 if no selection
;		A0	Address of first character of the result.

;
;	HOW DOES IT WORK?
;
; Having a look at the |CEQU file, you see that I use special codes
; to show the compiler that it has to copy the asked routine and relocate
; the branch. Some remarks:
;	- The size of a Rbsr is 4 bytes, like the normal branch, it does
; not change the program (you can make some jumps over it)
;	- Although I have coded the signal, and put a lot a security, 
; a mischance may lead to the compiler thinking there is a RBsr where
; there is nothing than normal data. The result may be disastrous! So if
; you have BIG parts of datas in which you do not make any special calls,
; you can put before it the macro: RDATA. It tells the compiler that 
; the following code, up to the end of the library routine (up to the next
; L(N) label) is normal data: the compiler will not check for RBranches...
; Up to now, I have not been forced to do so, but if something goes wrong,
; try that!
;
;

C_Lib
******************************************************************
*		COLD START
*
; The first routine of the library will perform all initialisations in the
; booting of AMOS.
;
; I have put here all the music datazone, and all the interrupt routines.
; I suggest you put all you C-Code here too if you have some...

; ALL the following code, from L0 to L1 will be copied into the compiled 
; program (if any music is used in the program) at once. All RBSR, RBRA etc
; will be detected and relocated. AMOSPro extension loader does the same.

L0	movem.l	a3-a6,-(sp)
;
; Here I store the address of the extension data zone in the special area
	lea	MB(pc),a3
	move.l	a3,ExtAdr+ExtNb*16(a5)
;
; Here, I store the address of the routine called by DEFAULT, or RUN
	lea	MusDef(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+4(a5)
;
; Here, the address of the END routine,
	lea	MusEnd(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+8(a5)
;
; And now the Bank check routine..
	lea	BkCheck(pc),a0
	move.l	a0,ExtAdr+ExtNb*16+12(a5)

; You are not obliged to store something in the above areas, you can leave
; them to zero if no routine is to be called...
;
; In AMOS data zone, stands 8 long words allowing you to simply
; put a patch in the VBL interrupt. The first on is at VBLRout.
; At each VBL, AMOS explores this list, and call all address <> 0
; It stops at the FIRST zero. The music patch is the first routine
; called.

	lea	MusInt(pc),a0		* Interrupt routine
	move.l	a0,VBLRout(a5)
; 50/60 herz?
	move.l	#3546895,MusClock-MB(a3)
	move.w	#100,TempoBase-MB(a3)
	EcCall	NTSC			* Is system NTSC?
	tst.w	d1
	beq.s	ItsPAL
	move.w	#120,TempoBase-MB(a3)
	move.l	#3579545,MusClock-MB(a3)
ItsPAL	
; Install sample interrupts
	lea	Sami_handler(pc),a0
	move.l	a0,Sami_handad-MB(a3)

; As you can see, you MUST preserve A3-A6, and return in D0 the 
; Number of the extension if everything went allright. If an error has
; occured (no more memory, no file found etc...), return -1 in D0 and
; AMOS will refuse to start.
	movem.l	(sp)+,a3-a6
	moveq	#ExtNb,d0		* NO ERRORS
 	rts

******* SCREEN RESET
; This routine is called each time a DEFAULT occurs...
;
; The next instruction loads the internal datazone address. I could have
; of course done a load MB(pc),a3 as the datazone is in the same
; library chunk. 

MusDef	DLoad	a3	
* Stop/Init narrator
	Rbsr	L_NarStop
	Rbsr	L_NarInit
* Reset TRACKER music
	Rbsr	L_TrackStop
* Reset MED music
	Rbsr	L_MedClose
	clr.b	Med_Midi-MB(a3)
* Reset Sam_interrupts
	move.w	#$000F,Circuits+DmaCon
	Rbsr	L_Sami_install
* Init musique
	Rbsr	L_RazWave		* Reset waves
	move.l	Buffer(a5),a0		* Draw square wave
	move.l	a0,a1
	moveq	#127,d0
MuDf1	move.b	#-127,128(a0)
	move.b	#127,(a0)+
	dbra	d0,MuDf1
	moveq	#0,d1			* 0-> Noise
	Rbsr	L_NeWave
	moveq	#1,d1			* 1-> Square wave
	Rbsr	L_NeWave
	move.w	#LNoise/2-1,d2		* Draw first noise
	move.w	BSeed-MB(a3),d1
	move.l	WaveBase-MB(a3),a0
	lea	WaveDeb(a0),a0
MuDf2	add.w	Circuits+6,d1
	mulu	#$3171,d1
	lsr.l	#8,d1
	move.w	d1,(a0)+
	dbra	d2,MuDf2
	move.w	d1,BSeed-MB(a3)
	moveq	#56,d0			* Default settings
	moveq	#%1111,d1
	Rbsr	L_Vol
	Rbsr	L_MVol
	move.w	#5,SamBank-MB(a3)	* Sample bank=5	
	moveq	#-1,d0			* Sam loop off
	moveq	#-1,d1
	Rbsr	L_SL0
	Rbra	L_MuInit

******* QUIT
; This routine is called when you quit AMOS or when the compiled program
; ends. If you have opend devices, reserved memory you MUST close and
; restore everything to normal.

MusEnd:	DLoad	a3

; Ferme le narrator
	Rbsr	L_NarStop
	move.l	$4.w,a6
	move.l	WriteIo-MB(a3),d0
	beq.s	.Skip1
	move.l	d0,a1
	move.l	WriteIo-MB(a3),a1
	jsr	_LVOCloseDevice(a6)
; Enleve la structure
	move.l	WriteIo-MB(a3),-(sp)
	moveq	#3,d0
	Rbsr	L_Amiga.Lib
	addq.l	#4,sp
; Enleve les ports
	move.l	WritePort-MB(a3),-(sp)
	moveq	#1,d0
	Rbsr	L_Amiga.Lib
	addq.l	#4,sp
	move.l	ReadPort-MB(a3),-(sp)
	moveq	#1,d0
	Rbsr	L_Amiga.Lib
	addq.l	#4,sp
; Enleve le translator
.Skip1	move.l	TranBase-MB(a3),d0
	beq.s	NarEnd
	move.l	d0,a1
	jsr	CloseLib(a6)
NarEnd	
* No more TRACKER music
	Rbsr	L_TrackStop
* No more MED music
	Rbsr	L_MedClose
* No more VBL
	clr.l	VBLRout(a5)
* No more Sami
	RBsr	L_Sami_remove
* End music
	Rbsr	L_MOff
	moveq	#%1111,d0
	Rbsr	L_EnvOff
	Rbsr	L_RazWave
	lea	Circuits,a0
	move.w	#$000F,DmaCon(a0)
	clr.w	$a8(a0)
	clr.w	$b8(a0)
	clr.w	$c8(a0)
	clr.w	$d8(a0)
* Finished!
	rts

******* LOOK FOR MUSIC BANK
; This routine is called after any bank has been loaded, reserved or erased.
; Here, if a music is being played and if the music bank is erased, I MUST
; stop the music, otherwise it might crash the computer. That's why I
; do a checksum on the first bytes of the bank to see if they have changed...
BkCheck	
	Rbsr	L_TrackCheck		* Check Tracker
	Rbsr	L_MedCheck		* Check Med
* Check normal music.
	DLoad	a3
	move.l	MusBank-MB(a3),d2	Old music bank address
	moveq	#3,d0			Ask for music bank address
	Rjsr	L_Bnk.GetAdr
	beq.s	BkNo
	move.l	-8(a0),d0		Looks for "Musi"
	cmp.l	BkMus-MB(a3),d0
	bne.s	BkNo
	moveq	#0,d0			Performs a check sum
	add.l	(a0),d0
	add.l	4(a0),d0
	add.l	8(a0),d0
	add.l	12(a0),d0
	cmp.l	d2,a0
	bne.s	BkNew
	cmp.l	MusCheck-MB(a3),d0
	bne.s	BkNew
* Same bank! Do nothing!
	rts
* No more bank!
BkNo	tst.l	d2
	beq.s	BkNo1
	Rbsr	L_MuInit
	clr.l	MusBank-MB(a3)
BkNo1	rts
* A NEW bank
BkNew	move.l	a0,MusBank-MB(a3)
	move.l	d0,MusCheck-MB(a3)
	Rbsr	L_MuInit
	move.l	MusBank-MB(a3),a0
	move.l	a0,a1
	add.l	(a0),a1
	move.l	a1,BankInst-MB(a3)
	move.l	a0,a1
	add.l	4(a0),a1
	move.l	a1,BankSong-MB(a3)
	add.l	8(a0),a0
	move.l	a0,BankPat-MB(a3)
	rts

***********************************************************
*
*	INTERRUPT ROUTINES
*
***********************************************************	

******* Sami interrupt handlers
Sami_handler
	add.w	Sami_reg(a1),a0
	move.l	Sami_pos(a1),d0
	cmp.l	Sami_long(a1),d0
	bcc.s	.whatnow
* Poursuit la lecture du sample
.samloop
	move.l	d0,d1
	add.l	#Sami_lplay,d1
	cmp.l	Sami_long(a1),d1
	bls.s	.skip
	move.l	Sami_long(a1),d1
.skip	move.l	d1,Sami_pos(a1)
	sub.l	d0,d1
	lsr.l	#1,d1
	add.l	Sami_adr(a1),d0
	move.l	d0,(a0)				* AUDxLOC
	move.w	d1,4(a0)			* AUDxLEN
	move.w	Sami_dvol(a1),d0
	bmi.s	.skip1
	move.w	d0,8(a0)			* AUDxVOL
.skip1	move.w	Sami_bit(a1),Circuits+IntReq
	rts
* Sample termine. Que faire?
.whatnow
	move.l	d0,d1
	move.l	Sami_radr(a1),d0		* Double buffer?
	bne.s	.swap
	move.l	Sami_rpos(a1),d0		* Boucler?
	bpl.s	.samloop
	bset	#7,Sami_pos(a1)			* Attend?
	tst.l	d1
	bpl.s	.skip1
* Fin du sample-> met du blanc!
	move.w	#0,$a(a0)
	move.w	Sami_dma(a1),d0
	moveq	#0,d1
	bset	d0,d1
	move.w	d1,Circuits+DmaCon
	tst.w	Sami_dvol(a1)
	bmi.s	.skip2
	lea	MB(pc),a0			* Restart music
	bset	d0,MuReStart+1-MB(a0)
.skip2	move.w	Sami_bit(a1),Circuits+IntEna	* No more interrupts
	move.w	Sami_bit(a1),Circuits+IntReq
	rts
* Change de buffer
.swap	clr.l	Sami_radr(a1)
	move.l	d0,Sami_adr(a1)
	move.l	Sami_rlong(a1),Sami_long(a1)
	moveq	#0,d0
	bra	.samloop

******* VBL Entry
MusInt	lea	MB(pc),a3	
	move.w	EnvOn-MB(a3),d0
	beq	Music
	lea	EnvBase-MB(a3),a0
	lea	$a0(a6),a2
	moveq	#0,d1
	moveq	#3,d2
	moveq	#0,d5
MuInt1	btst	d1,d0
	beq.s	MuIntN
	move.l	EnvDelta(a0),d3
	add.l	EnvVol(a0),d3
	move.l	d3,EnvVol(a0)
	swap	d3
	move.w	d3,8(a2)
MuInt2	subq.w	#1,EnvNb(a0)
	bne.s	MuIntN
	Rbsr	L_MuIntE
MuIntN	lea	EnvLong(a0),a0
	lea	$10(a2),a2
	addq.w	#1,d1
	dbra	d2,MuInt1
	move.w	d0,EnvOn-MB(a3)
	move.w	d5,DmaCon(a6)
	lsl.w	#7,d5
	move.w	d5,IntEna(a6)
******* Make noise?
	tst.w	Noise-MB(a3)
	beq.s	Music
	move.w	PNoise-MB(a3),d0
	moveq	#7,d2
	move.w	BSeed-MB(a3),d1
	move.l	WaveBase-MB(a3),a0
INoi1	add.w	6(a6),d1
	mulu	#$3171,d1
	lsr.l	#8,d1
	move.w	d1,WaveDeb(a0,d0.w)
	subq.w	#2,d0
	bpl.s	INoi2
	move.w	#LNoise-2,d0
INoi2	dbra	d2,INoi1
	move.w	d0,PNoise-MB(a3)
	move.w	d1,BSeed-MB(a3)

*******	Music routine
Music:	move.l	MuBase-MB(a3),d0
	beq	Tracker
	movem.l	a4-a6,-(sp)
	move.l	d0,a5
	bsr	MuEvery
* Here is a smart counter, which gives progressive results
* from zero to 100(PAL), 120(NTSC)...
	move.w	MuCpt(a5),d0
	add.w	MuTempo(a5),d0
	move.w	d0,MuCpt(a5)
	move.w	TempoBase-MB(a3),d1
	cmp.w	d1,d0
	bcs	MuEff
	sub.w	d1,MuCpt(a5)
* Lets go for one step of music!
	moveq	#0,d5
	moveq	#0,d7
	move.l	a5,a4

	tst.b	VoiCpt+1(a4)
	beq.s	Mus0
	addq.w	#1,d5
	subq.b	#1,VoiCpt+1(a4)
	bne.s	Mus0
	moveq	#0,d6
	move.l	MuChip0-MB(a3),a6
	bsr	MuStep
Mus0	
	lea	MuVoix1(a5),a4
	tst.b	VoiCpt+1(a4)
	beq.s	Mus1
	addq.w	#1,d5
	subq.b	#1,VoiCpt+1(a4)
	bne.s	Mus1
	moveq	#1,d6
	move.l	MuChip1-MB(a3),a6
	bsr	MuStep
Mus1
	lea	MuVoix2(a5),a4
	tst.b	VoiCpt+1(a4)
	beq.s	Mus2
	addq.w	#1,d5
	subq.b	#1,VoiCpt+1(a4)
	bne.s	Mus2
	moveq	#2,d6
	move.l	MuChip2-MB(a3),a6
	bsr	MuStep
Mus2	
	lea	MuVoix3(a5),a4
	tst.b	VoiCpt+1(a4)
	beq.s	Mus3
	addq.w	#1,d5
	subq.b	#1,VoiCpt+1(a4)
	bne.s	Mus3
	moveq	#3,d6
	move.l	MuChip3-MB(a3),a6
	bsr	MuStep
Mus3	
	and.w	MuDMAsk-MB(a3),d7
	move.w	d7,$DFF096
	tst.w	d5
	beq.s	MuFin
	bne.s	MuEnd
MuEff	bsr	DoEffects
MuEnd	movem.l	(sp)+,a4-a6
MuEnd1	rts
* Finished?
MuFin	subq.w	#1,MuNumber-MB(a3)
	beq	MuFini
* Restarts previous music
	move.w	MuNumber-MB(a3),d0
	subq.w	#1,d0
	mulu	#MuLong,d0
	lea	MuBuffer-MB(a3),a0
	add.w	d0,a0
	move.l	a0,MuBase-MB(a3)
	move.w	MuDMAsk-MB(a3),MuReStart-MB(a3)
	clr.w	MuStart(a0)
	clr.w	MuStop(a0)
	bra.s	MuEnd
* Really finished!
MuFini	clr.l	MuBase-MB(a3)
	Rbsr	L_MOff
	bra.s	MuEnd

******* One step of music for one voice
MuStep	lea	MuJumps(pc),a1
	move.l	VoiAdr(a4),a2
MuSt0	move.w	(a2)+,d0
	bpl.s	DoNote
	move.w	d0,d1
	and.w	#$7F00,d0
	lsr.w	#6,d0
	jmp	0(a1,d0.w)

******* Play a note
DoNote	btst	#14,d0
	bne.s	OldNote
* Play normal note
	and.w	#$0FFF,d0
	move.l	BankInst-MB(a3),d1
	move.l	VoiInst(a4),a0
	add.l	(a0),d1
	move.l	d1,(a6)
	move.w	8(a0),$04(a6)
	bset	d6,d7
	bclr	d6,MuStop+1(a5)
	bset	d6,MuStart+1(a5)
	move.b	VoiVol+1(a4),0(a3,d6.w)
	tst.b	VoiPTone(a4)
	bne.s	MuSt1
* No portamento
	move.w	d0,VoiNote(a4)
	move.w	d0,$06(a6)
	bra.s	MuSt0
* Start portamento
MuSt1	clr.b	VoiPTone(a4)
	move.w	d0,VoiPToTo(a4)
	lea	MuPTone(pc),a0
	move.l	a0,VoiEffect(a4)
	bra.s	MuSt0
* Play note compatible with first version
OldNote	move.w	d0,VoiCpt(a4)
	move.w	(a2)+,d0
	beq.s	ONoteE
	and.w	#$0FFF,d0
	move.w	d0,VoiNote(a4)
	move.w	d0,$06(a6)
	move.l	BankInst-MB(a3),d0
	move.l	VoiInst(a4),a0
	add.l	(a0),d0
	move.l	d0,(a6)
	move.w	8(a0),$04(a6)
	bset	d6,d7
	bclr	d6,MuStop+1(a5)
	bset	d6,MuStart+1(a5)
	move.b	VoiVol+1(a4),0(a3,d6.w)
ONoteE	move.l	a2,VoiAdr(a4)
	rts

******* Jump table to labels
MuJumps	bra	EtEnd			* 00-> Fin pattern
	bra	MuSt0			* 01-> Old Slide up
	bra	MuSt0			* 02-> Old Slide down
	bra	EtSVol			* 03-> Set volume
	bra	EtStop			* 04-> Stop effet
	bra	EtRep			* 05-> Repeat
	bra	EtLOn			* 06-> Led On
	bra	EtLOff			* 07-> Led Off
	bra	EtTemp			* 08-> Set Tempo
	bra	EtInst			* 09-> Set Instrument
	bra	EtArp			* 10-> Arpeggiato
	bra	EtPort			* 11-> Portamento
	bra	EtVib			* 12-> Vibrato
	bra	EtVSl			* 13-> Volume slide
	bra	EtSlU			* 14-> Slide up
	bra	EtSlD			* 15-> Slide down
 	bra	EtDel			* 16-> Delay
	bra	EtJmp			* 17-> Position jump
	bra	MuSt0			* 18-> Free space
	bra	MuSt0			* 19-> Free space
	bra	MuSt0			* 20-> Free space
	bra	MuSt0			* 21-> Free space
	bra	MuSt0			* 22-> Free space
	bra	MuSt0			* 23-> Free space
	bra	MuSt0			* 24-> Free space
	bra	MuSt0			* 25-> Free space
	bra	MuSt0			* 26-> Free space
	bra	MuSt0			* 27-> Free space
	bra	MuSt0			* 28-> Free space
	bra	MuSt0			* 29-> Free space
	bra	MuSt0			* 30-> Free space
	bra	MuSt0			* 31-> Free space

******* End of a pattern
EtEnd	clr.w	VoiCpt(a4)
	clr.w	VoiRep(a4)
	clr.l	VoiDeb(a4)
	lea	NoEffect(pc),a0
	move.l	a0,VoiEffect(a4)
	move.l	VoiPat(a4),a0
RePat	moveq	#0,d0
	move.w	(a0)+,d0
	bmi.s	EtEnd1
	move.l	a0,VoiPat(a4)
	move.l	BankPat-MB(a3),a0
	cmp.w	(a0),d0
	bhi.s	EtEndX
	lsl.w	#2,d0
	add.w	d6,d0
	lsl.w	#1,d0
	move.w	2(a0,d0.w),d0
	beq.s	EtEndX
	lea	0(a0,d0.l),a2
	bra	MuSt0
EtEndX	rts
EtEnd1	cmp.w	#-1,d0
	beq.s	EtEndX
 	move.l	VoiDPat(a4),a0
	bra.s	RePat
******* Change instrument
EtInst	and.w	#$00FF,d1
	move.l	BankInst-MB(a3),a0
	lsl.w	#5,d1
	lea	2(a0,d1.w),a0
	move.l	a0,VoiInst(a4)
	move.w	12(a0),d0
	cmp.w	#64,d0
	bcs.s	EtInst1
	moveq	#63,d0
EtInst1	move.w	d0,VoiDVol(a4)
	mulu	MuVolume-MB(a3),d0
	lsr.w	#6,d0
	move.w	d0,VoiVol(a4)
	bra	MuSt0
******* Set Volume
EtSVol	and.w	#$00FF,d1
	cmp.w	#64,d1
	bcs.s	EtSVol1
	moveq	#63,d1
EtSVol1	move.w	d1,VoiDVol(a4)
	mulu	MuVolume-MB(a3),d1
	lsr.w	#6,d1
	move.w	d1,VoiVol(a4)
	bra	MuSt0
******* Set Tempo
EtTemp	and.w	#$00FF,d1
	move.w	d1,MuTempo(a5)
	bra	MuSt0
******* Led On
EtLOn	bclr	#1,$bfe001
	bra	MuSt0
******* Led Off
EtLOff	bset	#1,$bfe001
	bra	MuSt0
******* Repeat
EtRep	and.w	#$00FF,d1
	bne.s	EtRep1
	move.l	a2,VoiDeb(a4)
	bra	MuSt0
EtRep1	tst.w	VoiRep(a4)
	bne.s	EtRep2
	move.w	d1,VoiRep(a4)
	bra	MuSt0
EtRep2	subq.w	#1,VoiRep(a4)
	beq	MuSt0
	move.l	VoiDeb(a4),d0
	beq	MuSt0
	move.l	d0,a2
	bra	MuSt0
******* Arpeggio
EtArp	move.b	d1,VoiValue+1(a4)
	lea	MuArp(pc),a0
	move.l	a0,VoiEffect(a4)
	bra	MuSt0
******* Portamento
EtPort	move.b	#1,VoiPTone(a4)
	lea	MuPTone(pc),a0
	bra.s	EtSetE
******* Vibrato
EtVib	lea	MuVib(pc),a0
	bra.s	EtSetE
******* Volume slide
EtVSl	and.w	#$00FF,d1
	move.w	d1,d0
	lsr.w	#4,d0
	tst.w	d0
	bne.s	VsEnd
	and.w	#$000F,d1
	neg.w	d1
	move.w	d1,d0
VsEnd	move.w	d0,VoiValue(a4)
	lea	MuVSl(pc),a0
	move.l	a0,VoiEffect(a4)
	bra	MuSt0
******* Slide up
EtSlU	and.w	#$00FF,d1
	neg.w	d1
	lea	MuSlide(pc),a0
	bra.s	EtSte
******* Slide Down
EtSlD	lea	MuSlide(pc),a0
EtSetE	and.w	#$00FF,d1
EtSte	move.w	d1,VoiValue(a4)
	move.l	a0,VoiEffect(a4)
	bra	MuSt0
******* Stop effect
EtStop	lea	NoEffect(pc),a0
	move.l	a0,VoiEffect(a4)
	bra	MuSt0
******* Jump to pattern
EtJmp	and.w	#$00FF,d1
	lsl.w	#1,d1
	move.l	VoiDPat(a4),a0
	add.w	d1,a0
	move.l	a0,VoiPat(a4)
	bra	EtEnd
******* Delay
EtDel	move.w	d1,VoiCpt(a4)
	move.l	a2,VoiAdr(a4)
	rts

******* Effect routines

* Performs all effects
DoEffects
	move.l	a5,a4
	move.l	MuChip0-MB(a3),a6
	move.l	VoiEffect(a4),a0
	jsr	(a0)
	move.w	VoiVol(a4),$08(a6)
	lea	MuVoix1(a5),a4
	move.l	MuChip1-MB(a3),a6
	move.l	VoiEffect(a4),a0
	jsr	(a0)
	move.w	VoiVol(a4),$08(a6)
	lea	MuVoix2(a5),a4
	move.l	MuChip2-MB(a3),a6
	move.l	VoiEffect(a4),a0
	jsr	(a0)
	move.w	VoiVol(a4),$08(a6)
	lea	MuVoix3(a5),a4
	move.l	MuChip3-MB(a3),a6
	move.l	VoiEffect(a4),a0
	jsr	(a0)
	move.w	VoiVol(a4),$08(a6)
	rts

* TONE SLIDE
MuSlide	move.w	VoiValue(a4),d0
	beq.s	NoMoreE
	add.w	VoiNote(a4),d0
	cmp.w	#$71,d0
	bcc.s	MuSl1
	moveq	#$71,d0
	bsr	NoMoreE
MuSl1	cmp.w	#$358,d0
	bls.s	MuSl2
	move.w	#$358,d0
	bsr	NoMoreE
MuSl2	move.w	d0,VoiNote(a4)
	move.w	d0,$06(a6)
	rts
NoMoreE	lea	NoEffect(pc),a0
	move.l	a0,VoiEffect(a4)
	rts
NoEffect
	move.w	VoiNote(a4),$06(a6)
	rts

* ARPEGGIO
MuArp	moveq	#0,d0
	move.b	VoiValue+1(a4),d0
	move.b	VoiValue(a4),d1
	cmp.b	#3,d1
	bcs.s	MuArp0
	moveq	#2,d1
MuArp0	subq.b	#1,d1
	move.b	d1,VoiValue(a4)
	beq.s	MuArp2
	bpl.s	MuArp1
	lsr.b	#4,d0
	bra.s	MuArp3
MuArp1	and.b	#$0f,d0
	bra.s	MuArp3
MuArp2	move.w	VoiNote(a4),d2
	bra.s	MuArp4
MuArp3	add.w	d0,d0
	moveq	#0,d1
	move.w	VoiNote(a4),d1
	lea	Periods(pc),a0
	moveq	#$24,d3
MuArpL	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	MuArp4
	addq.l	#2,a0
	dbra	d3,MuArpL
	rts
MuArp4	move.w	d2,$06(a6)
	rts

* PORTAMENTO
MuPTone	move.w	VoiValue(a4),d0
	move.w	VoiNote(a4),d1
	cmp.w	VoiPToTo(a4),d1
	beq.s	MuPTo3
	bcs.s	MuPTo1
	sub.w	d0,d1
	cmp.w	VoiPToTo(a4),d1
	bhi.s	MuPto4
	bra.s	MuPTo2
MuPTo1	add.w	d0,d1
	cmp.w	VoiPToTo(a4),d1
	bcs.s	MuPTo4
MuPTo2	move.w	VoiPToTo(a4),d1
MuPTo3	bsr	NoMoreE
MuPTo4	move.w	d1,VoiNote(a4)
	move.w	d1,$06(a6)
	rts

* VIBRATO
MuVib	move.b	VoiVib(a4),d0
	lea	Sinus(pc),a0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	0(a0,d0.w),d2
	move.b	VoiValue+1(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	VoiNote(a4),d0
	tst.b	VoiVib(a4)
	bmi.s	MuVib1
	add.w	d2,d0
	bra.s	MuVib2
MuVib1	sub.w	d2,d0
MuVib2	move.w	d0,$06(a6)
	move.b	VoiValue+1(a4),d0
	lsr.w	#2,d0
	and.w	#$3C,d0
	add.b	d0,VoiVib(a4)
	rts

* VOLUME SLIDE
MuVSl	move.w	VoiDVol(a4),d0
	add.w	VoiValue(a4),d0
	bpl.s	MuVSl1
	clr.w	d0
MuVSl1	cmp.w	#$40,d0
	bcs.s	MuVSl2
	moveq	#$3F,d0
MuVSl2	move.w	d0,VoiDVol(a4)
	mulu	MuVolume-MB(a3),d0
	lsr.w	#6,d0
	move.w	d0,VoiVol(a4)
	rts

*******	Routine called every VBL
MuEvery	

* Second step of sample?
	move.w	MuStop(a5),d0
	beq	MuEvX
	move.l	BankInst-MB(a3),d1
	btst	#0,d0				* Voix 0
	beq.s	MuEv0
	move.l	MuChip0-MB(a3),a6
	move.l	VoiInst0(a5),a0
	move.l	d1,d2
	add.l	4(a0),d2
	move.l	d2,(a6)
	move.w	10(a0),$04(a6)
MuEv0	btst	#1,d0				* Voix 1
	beq.s	MuEv1
	move.l	MuChip1-MB(a3),a6
	move.l	VoiInst1(a5),a0
	move.l	d1,d2
	add.l	4(a0),d2
	move.l	d2,(a6)
	move.w	10(a0),$04(a6)
MuEv1	btst	#2,d0				* Voix 2
	beq.s	MuEv2
	move.l	MuChip2-MB(a3),a6
	move.l	VoiInst2(a5),a0
	move.l	d1,d2
	add.l	4(a0),d2
	move.l	d2,(a6)
	move.w	10(a0),$04(a6)
MuEv2	btst	#3,d0				* Voix 3
	beq.s	MuEv3
	move.l	MuChip3-MB(a3),a6
	move.l	VoiInst3(a5),a0
	move.l	d1,d2
	add.l	4(a0),d2
	move.l	d2,(a6)
	move.w	10(a0),$04(a6)
MuEv3	

* Start a voice
MuEvX	move.w	MuStart(a5),d1
	move.w	d1,MuStop(a5)
	clr.w	MuStart(a5)
	or.w	d1,d0
	and.w	MuDMAsk-MB(a3),d0
	bset	#15,d0
	move.w	d0,$DFF096

* Restart voices?
	move.w	MuReStart-MB(a3),d0
	beq	MuRsX
	moveq	#0,d3
	btst	#0,d0				* Voix 0
	beq.s	MuRs0
	lea	$DFF0A0,a6
	move.l	a6,MuChip0-MB(a3)
	move.w	#2,$04(a6)
	tst.l	VoiInst0(a5)
	beq.s	MuRs0
	bset	#0,d3
MuRs0	btst	#1,d0				* Voix 1
	beq.s	MuRs1
	lea	$DFF0B0,a6
	move.l	a6,MuChip1-MB(a3)
	move.w	#2,$04(a6)
	tst.l	VoiInst1(a5)
	beq.s	MuRs1
	bset	#1,d3
MuRs1	btst	#2,d0				* Voix 2
	beq.s	MuRs2
	lea	$DFF0C0,a6
	move.l	a6,MuChip2-MB(a3)
	move.w	#2,$04(a6)
	tst.l	VoiInst2(a5)
	beq.s	MuRs2
	bset	#2,d3
MuRs2	btst	#3,d0				* Voix 3
	beq.s	MuRs3
	lea	$DFF0D0,a6
	move.l	a6,MuChip3-MB(a3)
	move.w	#2,$04(a6)
	tst.l	VoiInst3(a5)
	beq.s	MuRs3
	bset	#3,d3
MuRs3	clr.w	MuReStart-MB(a3)
	or.w	d0,MuDMAsk-MB(a3)
	or.w	d3,MuStop(a5)
MuRsX	
	rts


***********************************************************
*
*	TRACKER INTERRUPT ROUTINES
*
***********************************************************	
Tracker	move.b	mt_on(pc),d0
	beq.s	.Skip
	movem.l	a4-a6,-(sp)
; Poke les deuxiemes parties des samples
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.w	mt_dmacon-MB(a3)
	beq.s	.SkipD
	lea	mt_voice1(pc),a1
	lea	$dff000,a0
	move.l	$a(a1),$a0(a0)
	move.w	$e(a1),$a4(a0)
	move.l	$a+$1c(a1),$b0(a0)
	move.w	$e+$1c(a1),$b4(a0)
	move.l	$a+$38(a1),$c0(a0)
	move.w	$e+$38(a1),$c4(a0)
	move.l	$a+$54(a1),$d0(a0)
	move.w	$e+$54(a1),$d4(a0)
; Appelle la musique
; ~~~~~~~~~~~~~~~~~~
.SkipD	bsr	mt_music
	movem.l	(sp)+,a4-a6
.Skip	rts

mt_music:
	move.l	mt_data(pc),a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	move.l	mt_data(pc),a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1

	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	lea	mt_playvoice(pc),a6
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	jsr	(a6)

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma
	or.w	#$8000,mt_dmacon-mt_voice4(a4)

mt_nodma:
	add.w	#$10,mt_pattpos-mt_voice4(a4)
	cmp.w	#$400,mt_pattpos-mt_voice4(a4)
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos-mt_voice4(a4)
	clr.b	mt_break-mt_voice4(a4)
	addq.b	#1,mt_songpos-mt_voice4(a4)
	and.b	#$7f,mt_songpos-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos-mt_voice4(a4)
mt_exit:tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
; Provoque l'actualisation du DMA
	move.w	mt_dmacon(pc),d0
	beq.s	.Skip
	moveq	#4,d3		
.wai2	move.b	$dff006,d2	
.wai3	cmp.b	$dff006,d2	
	beq.s	.wai3
	dbf	d3,.wai2	
	move.w	d0,$dff096
.Skip	rts

mt_nonew:
	lea	$dff0a0,a5
	lea	mt_com(pc),a6
	jsr	(a6)
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	jsr	(a6)
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	jsr	(a6)
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	jsr	(a6)
	tst.b	mt_break-mt_voice4(a4)
	bne	mt_next
	rts

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_oldinstr

	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	move.l	mt_mulu(pc,d2.w),a3
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	moveq	#0,d3
	move.w	(a3)+,d3
	beq	mt_noloop
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:dcb.l	$20,0

mt_noloop:
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)
	move.w	$12(a4),8(a5)

mt_oldinstr:
	move.w	(a4),d3
	and.w	#$fff,d3
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	d3,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0
	or.w	d0,mt_dmacon-mt_playvoice(a6)
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:moveq	#0,d0
	move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	move.b	d0,3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts

mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_normper
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
mt_arp3:cmp.w	(a0)+,d1
	blt.s	mt_arp3
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	beq.s	mt_arp
	cmp.b	#6,d0
	beq.s	mt_volvib
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:move.w	$12(a4),8(a5)
	rts

mt_com2:move.b	2(a4),d0
	and.b	#$f,d0
	beq	mt_rts
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break-mt_playvoice(a6)
	rts

mt_songjmp:
	move.b	#1,mt_break-mt_playvoice(a6)
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_playvoice(a6)
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed-mt_playvoice(a6)
	rts


*********************************************************************
*		MUSIC extension data zone

; Branches for AMOSPro Editor (-4)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Rbra	L_GoSam
MB:
MuVu		dc.l	0		* Vu Meters
MuBase		dc.l	0		* Curretn music address
MusAdr		dc.l	0		* Branch table address
MusClock	dc.l 	3546895		* Clock speed
WaveBase	dc.l	0		* Wave tree
Waves		dc.w 	0,0,0,0
EnvOn:		dc.w 	0		* ADSR running?
EnvBase:	ds.b	EnvLong*4	* ADSR table
SamBank:	dc.w 	0		* Sample bank
BSeed:		dc.w 	0		* Random seed
Noise:		dc.w	0		* Noise on?
PNoise:		dc.w	0		* Pointer to noise buffer
TempoBase:	dc.w	0		* 100 (PAL) - 120 (NTSC)
* 		Musique
MusBank		dc.l 	0		* Music bank
MusCheck	dc.l	0		* Check sum
BankInst	dc.l	0		* Instruments
BankSong	dc.l	0		* Songs
BankPat		dc.l 	0		* Patterns
MuNumber	dc.w	0		* Music priority
MuVolume	dc.w	0		* Music volume
MuDMAsk		dc.w	0		* Voice mask
MuReStart	dc.w	0		* Restart the voice
MuChip0		dc.l	0		* Circuits 0
MuChip1		dc.l 	0		*	   1
MuChip2		dc.l 	0		*          2
MuChip3		dc.l 	0		*          3
FoEnd		dc.w	$8000		* Fake empty pattern
MuBuffer	ds.b	MuLong*3	* Music tables

		RDATA

*************** Tables for effects
Sinus	
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

Periods	
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

*************** Default enveloppes
EnvDef:		dc.w 1,64,4,55,5,50,25,0,0,0
EnvShoot	dc.w 1,64,10,0,0,0
EnvBoom		dc.w 1,64,10,50,50,0,0,0
EnvBell		dc.w 1,64,4,40,25,0,0,0

*************** Bank headers
BkMus:		dc.b "Music   "

*************** Frequency / notes
TFreq:	dc.w 000,256/2
	dc.w 000,256/2
	dc.w 256,128/2
	dc.w 384,64/2
	dc.w 448,32/2
	dc.w 480,16/2
	dc.w 496,8/2
	dc.w 504,4/2
	dc.w 504,4/2
TNotes:	dc.w 00,00,00,33,35,37,39,41,44,46,49,52
	dc.w 55,58,62,65,69,73,78,82,87,92,98,104
	dc.w 110,117,123,131,139,147,156,165,175,185,196,208
	dc.w 220,233,247,262,277,294,311,330,349,370,392,415
	dc.w 440,466,494,523,554,587,622,659,698,740,784,830
	dc.w 880,932,988,1046,1109,1175,1245,1319,1397,1480,1568,1661
	dc.w 1760,1865,1986,2093,2217,2349,2489,2637,2794,2960,3136,3322
	dc.w 3520,3729,3952,4186,4435,4699,4978,5274,5588,5920,6272,6645
	dc.w 7040,7459,7902,8372

*************** SAMPLE PLAYER INTERRUPT STRUCTURES
Sami_lplay	equ	1024*4
Sami_bit	equ	22
Sami_dma	equ	24
Sami_reg	equ	26
Sami_adr	equ	28
Sami_long	equ	32
Sami_pos	equ	36
Sami_rpos	equ	40
Sami_radr	equ	44
Sami_rlong	equ	48
Sami_dvol	equ	52
Sami_old	equ	54
Sami_intl	equ	58

Sami_int	ds.b	22				* Channel 0
		dc.w	%0000000010000000	bit
		dc.w	0			dma
		dc.w	$a0			reg
		dc.l	0			adr
		dc.l	0			long
		dc.l	0			pos
		dc.l	0			rpos
		dc.l	0			radr
		dc.l	0			rlong
		dc.w	0			dvol
		dc.l	0			old			

		ds.b	22				* Channel 1
		dc.w	%0000000100000000	bit
		dc.w	1			dma
		dc.w	$b0			reg
		dc.l	0			adr
		dc.l	0			long
		dc.l	0			pos
		dc.l	0			rpos
		dc.l	0			radr
		dc.l	0			rlong
		dc.w	0			dvol
		dc.l	0			old			

		ds.b	22				* Channel 2
		dc.w	%0000001000000000	bit
		dc.w	2			dma
		dc.w	$c0			reg
		dc.l	0			adr
		dc.l	0			long
		dc.l	0			pos
		dc.l	0			rpos
		dc.l	0			radr
		dc.l	0			rlong
		dc.w	0			dvol
		dc.l	0			old			

		ds.b	22				* Channel 3
		dc.w	%0000010000000000	bit
		dc.w	3			dma
		dc.w	$d0			reg
		dc.l	0			adr
		dc.l	0			long
		dc.l	0			pos
		dc.l	0			rpos
		dc.l	0			radr
		dc.l	0			rlong
		dc.w	0			dvol
		dc.l	0			old			

Sami_OldEna	dc.w	0
Sami_empty	dc.l	0
Sami_bits	dc.w	0
Sami_handad	dc.l	0
Sami_flag	dc.w	0
SamLoops	dc.w	0
*************** NARRATOR
Amaps:		dc.b	3,5,10,12
TranBase	dc.l	0
		even
L_WriteIo	equ	88
WriteIo		dc.l	0
WritePort:	dc.l	0
L_ReadIo	equ	92
ReadIo		ds.b	L_ReadIo
ReadPort	dc.l	0
TranName	dc.b	"translator.library",0
NarDevice	dc.b	"narrator.device",0
		even

; 	MED data zone
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Med_Bank	dc.w	7		Bank number 6= tracker
Med_Base	dc.l	0
Med_Adr		dc.l	0
Med_On		dc.b	0
Med_Midi	dc.b	0
Med_Name	dc.b	"medplayer.library",0	
		even
_MEDGetPlayer		equ	-30
_MEDFreePlayer		equ	-36
_MEDPlayModule		equ	-42
_MEDContModule		equ	-48
_MEDStopPlayer		equ	-54
_MEDDimOffPlayer	equ	-60
_MEDSetTempo		equ	-66
_MEDLoadModule		equ	-72
_MEDUnLoadModule	equ	-78
_MEDGetCurrentModule	equ	-84
_MEDResetMIDI		equ	-90
_MEDSetModnum		equ	-96
_MEDRelocModule		equ	-102

*********************************************************************
*	mt TRACKER data zone

Track_Bank	dc.w	6		Bank number 6= tracker
mt_on		dc.b	0
colour		dc.w	0

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8
mt_data:	dc.l	0
		dc.l	0


**********************************************************************
; Please leave 1 or two labels free for future extension. You never
; know!
L1

; Now follow all the music routines. Some are just routines called by others,
; some are instructions. 
; See how a adress the internal music datazone, by using a base register
; (usually A3) and adding the offset of the data in the datazone...

; >>> How to get the parameters for the instruction?
;
; When an instruction or function is called, you get the parameters
; pushed in A3. Remember that you unpile them in REVERSE order than
; the instruction syntax.
; As you have a entry point for each set of parameters, you know
; how many are pushed...
;	- INTEGER:	move.l	(a3)+,d0
;	- STRING:	move.l	(a3)+,a0
;			move.w	(a0)+,d0
;		A0---> start of the string.
;		D0---> length of the string
;	- FLOAT:	move.l	(a3)+,d0
;			fast floatting point format.
;
; IMPORTANT POINT: you MUST unpile the EXACT number of parameters,
; to restore A3 to its original level. If you do not, you will not
; have a immediate error, and AMOS will certainely crash on next
; UNTIL / WEND / ENDIF / NEXT etc... 
;
; So, your instruction must:
;	- Unpile the EXACT number of parameters from A3, and exit with
;	A3 at the original level it was before collecting your parameters)
;	- Preserve A4, A5 and A6
; You can use D0-D7/A0-A2 freely...
;
; You can jump to the error routine without thinking about A3 if an error
; occurs in your routine (via a RBra of course). BUT A4, A5 and A6 registers
; MUST be preserved!
;
; You end must end by a RTS.
;
; >>> Functions, how to return the parameter?
;
; To send a function`s parameter back to AMOS, you load it in D3,
; and put its type in D2:
;	moveq	#0,d2	for an integer
;	moveq	#1,d2	for a float
;	moveq	#2,d2	for a string
;

******* Stop sound routine
L_MOff		equ	2
L2	lea	Circuits,a0
	move.w	#%0000011110000000,IntEna(a0) 	* No more interrupts
	move.w	MuDMAsk-MB(a3),d0
	beq.s	MOf3
	move.w	d0,DmaCon(a0)
	moveq	#3,d1
MOf1	btst	d1,d0
	beq.s	MOf2
	move.w	#2,$a4(a0)
	clr.w	$a8(a0)
MOf2	lea	$10(a0),a0
	dbra	d1,MOf1
MOf3	rts

***********************************************************
*	NARRATOR!

******* Open narrator
L_OpNar		equ	3
L3	movem.l	a3-a6,-(sp)
	Dload	a3
	move.l	$4.w,a6
	move.l	TranBase-MB(a3),d0
	bne	OpNarCheck

; Opens communication port
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#0,d0
	Rbsr	L_Amiga.Lib
	addq.l	#8,sp
	move.l	d0,WritePort-MB(a3)
; Opens IO structure
	move.l	#L_WriteIo,-(sp)
	move.l	d0,-(sp)
	moveq	#2,d0
	Rbsr	L_Amiga.Lib
	addq.l	#8,sp
	move.l	d0,WriteIo-Mb(a3)
	move.l	d0,a1
	moveq	#0,d0
	moveq	#0,d1
	lea	NarDevice-MB(a3),a0
	jsr	OpenDev(a6)
	tst.l	d0
	bne	OpNarE

; Open READ structure
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#0,d0
	Rbsr	L_Amiga.Lib
	addq.l	#8,sp
	move.l	d0,ReadPort-MB(a3)
	move.l	WriteIo-MB(a3),a0
	lea	ReadIo-MB(a3),a1
	moveq	#L_WriteIo/2-1,d0
.Loop	move.w	(a0)+,(a1)+
	dbra	d0,.Loop
	lea	ReadIo-MB(a3),a1
	move.l	ReadPort-MB(a3),14(a1)

; Open translator
	Rbsr	L_NarInit
	lea	TranName-MB(a3),a1
	moveq	#0,d0
	jsr	OpenLib(a6)
	move.l	d0,TranBase-MB(a3)
	beq	OpNarE
* Restore Sami interrupts
	move.l	DosBase(a5),a6
	moveq	#50,d1
	jsr	-198(a6)
	clr.w	Sami_Flag-MB(a3)
	RBsr	L_Sami_Install
* Ok!
	movem.l	(sp)+,a3-a6
	rts

;-----> Annule un speech précédent
OpNarCheck
	RBsr	L_NarStop
	movem.l	(sp)+,a3-a6
	rts
;-----> Can't open narrator
OpNarE	movem.l	(sp)+,a3-a6
NoNar	moveq	#7,d0
	Rbra	L_Custom

******* Init narrator (if here)!
L_NarInit	equ	4
L4	move.l	WriteIO-MB(a3),d0
	beq.s	.Skip
	move.l	d0,a1
	move.w	#150,48(a1)
	move.w	#110,50(a1)
	clr.w	52(a1)
	clr.w	54(a1)
	lea	Amaps-MB(a3),a0
	move.l	a0,56(a1)
	move.w	#4,60(a1)
	move.w	#63,62(a1)
	move.w	#22200,64(a1)
.Skip	rts

******* SAY a$[,multi]
L_ISay2:	equ	5
L5	Rbsr	L_OpNar
	move.l	(a3)+,d7
	RBra	L_ISay
L_ISay1:	equ	6
L6	Rbsr	L_OpNar
	moveq	#0,d7	
	Rbra	L_ISay
L_ISay:		equ	7
L7	moveq	#%0000,d0
	Rbsr	L_StopDma
	Rbsr	L_VOnOf
	DLoad	a0
	clr.w	EnvOn-MB(a0)
	clr.w	Noise-MB(a0)
	move.l	(a3)+,a0
	moveq	#0,d0
	move.w	(a0)+,d0
* Phoneme?
	cmp.b	#"~",(a0)
	bne.s	ISayN
	addq.l	#1,a0
	move.l	Buffer(a5),a1
	move.w	d0,d1
	cmp.w	#1024,d1
	bcc	ISayN
	subq.w	#2,d1
	bmi.s	ISayN
ISayP	move.b	(a0)+,(a1)+
	dbra	d1,ISayP
	move.b	#"Q",(a1)+
	move.b	#"#",(a1)+
	move.b	#"U",(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	addq.w	#4,d0
	movem.l	a3/a6,-(sp)
	DLoad	a3
	bra.s	ISayNn
* Call TRANSLATOR
ISayN	move.l	Buffer(a5),a1
	move.l	a1,a2
	move.l	#1024,d1
	move.l	d1,d2
	lsr.w	#2,d2
	subq.w	#2,d2
ISayN1	clr.l	(a2)+
	dbra	d2,ISayN1
	movem.l	a3/a6,-(sp)
	DLoad	a3
	move.l	TranBase-MB(a3),a6
	jsr	Translate(a6)
	tst.w	d0
	bne.s	SayX
	move.l	#1024,d0
ISayNn
	Rbsr	L_Sami_remove
	move.l	WriteIO-MB(a3),a1
	move.w	#3,28(a1)
	move.l	d0,36(a1)
	move.l	Buffer(a5),40(a1)
	move.l	ExecBase,a6
	tst.w	d7
	bne.s	ISayA
; Mode non multitache
	clr.b	66(a1)
	jsr	DoIO(a6)
	RBsr	L_Sami_install
SayX	movem.l	(sp)+,a3/a6
	moveq	#%1111,d0
	Rbsr	L_VOnOf
	rts
; Mode multitache
ISayA	move.b	#1,66(a1)		Generer des mouths!
	jsr	SendIO(a6)
	movem.l	(sp)+,a3/a6
	rts
******* SET TALK sex,mode,pitch,rate
L_ITalk		equ	8
L8	Rbsr	L_OpNar
	move.l	#EntNul,d0
	Dload	a1
	move.l	WriteIo-MB(a1),a1
	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	IRd1
	cmp.w	#40,d1
	Rbcs	L_IFonc
	cmp.w	#400,d1
	Rbhi	L_IFonc
	move.w	d1,48(a1)
IRd1	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	IRd2
	cmp.w	#65,d1
	Rbcs	L_IFonc
	cmp.w	#320,d1
	Rbhi	L_IFonc
	move.w	d1,50(a1)
IRd2	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	IRd3
	and.w	#$0001,d1
	move.w	d1,52(a1)
IRd3	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	IRd4
	and.w	#$0001,d1
	move.w	d1,54(a1)
IRd4	rts

******* Narrator READ lips
L_LipsX		equ	9
L9	Dlea	ReadIo,a0
	moveq	#0,d2
	move.b	88(a0),d3
	ext.w	d3
	ext.l	d3
	rts
L_LipsY		equ	10
L10	Dlea	ReadIo,a0
	moveq	#0,d2
	move.b	89(a0),d3
	ext.w	d3
	ext.l	d3
	rts

***********************************************************
*	MUSIC INSTRUCTION

*******	BELL
L_Bell0		equ	11
L11	moveq	#0,d3
	moveq	#70,d2
	moveq	#%1111,d1
	moveq	#1,d5
	Dlea	EnvBell,a0
	move.l	a0,d6
	Rbra	L_GoBel
L_Bell1		equ	12
L12	moveq	#0,d3
	move.l	(a3)+,d2
	moveq	#%1111,d1
	moveq	#1,d5
	Dlea	EnvBell,a0
	move.l	a0,d6
	Rbra	L_GoBel
******* BOOM
L_Boom		equ	13
L13	moveq	#0,d3
	moveq	#36,d2
	moveq	#0,d5
	Dlea	EnvBoom,a0
	move.l	a0,d6
	Rbra	L_Shout
******* SHOOT
L_Shoot		equ	14
L14	moveq	#0,d3
	moveq	#60,d2
	moveq	#0,d5
	Dlea	EnvShoot,a0
	move.l	a0,d6
	Rbra	L_Shout
* Gives a stereo effect
L_Shout:	equ	15
L15	moveq	#%0000,d0
	Rbsr	L_StopDma
	Rbsr	L_VOnOf
	moveq	#%1000,d1
Shot	movem.l	d0-d7,-(sp)
	Rbsr	L_GoShot
	movem.l	(sp)+,d0-d7
	addq.w	#1,d2
	lsr.w	#1,d1
	bcc.s	Shot
	rts

*******	VOLUME n
L_IVol1		equ	16
L16	move.l	(a3)+,d0
	moveq	#%1111,d1
	Rbsr	L_Vol
	Rbsr	L_MVol
	rts
******* VOLUME voice,n
L_IVol2		equ	17
L17	move.l	(a3)+,d0
	move.l	(a3)+,d1
	Rbra	L_Vol
* Set voices volume level
L_Vol		equ	18
L18	cmp.l	#64,d0
	Rbcc	L_IFonc
	moveq	#0,d2
	Dlea	EnvBase,a0
	Dlea	Sami_int,a1
Vol1	btst	d2,d1
	beq.s	Vol2
	move.w	d0,EnvDVol(a0)
	tst.w	Sami_dvol(a1)
	bmi.s	Vol2
	move.w	d0,Sami_dvol(a1)
Vol2	lea	EnvLong(a0),a0
	lea	Sami_intl(a1),a1
	addq.w	#1,d2
	cmp.w	#4,d2
	bcs.s	Vol1
	rts

******* Stops Narrator if it was playing in multitask mode!
L_NarStop	equ	19
L19	movem.l	a3/a6,-(sp)
	Dload	a3
	move.l	$4.w,a6
	move.l	WriteIo-MB(a3),d0
	beq.s	.Skip2
	move.l	d0,a1
	tst.b	66(a1)
	beq.s	.Skip2
	clr.b	66(a1)
	jsr	_LVOCheckIO(a6)
	tst.l	d0
	bne.s	.Skip1
	move.l	WriteIo-MB(a3),a1
	jsr	_LVOAbortIO(a6)
.Skip1	move.l	WriteIo-MB(a3),a1
	jsr	_LVOWaitIO(a6)
	Rbsr	L_Sami_Install
.Skip2	movem.l	(sp)+,a3/a6
	rts

*******	PLAY note,length
L_IPlay2	equ	20
L20	move.l	(a3)+,d3
	Rbmi	L_IFonc
	move.l	(a3)+,d2
	moveq	#%1111,d1
	moveq	#-1,d5
	moveq	#0,d6
	Rbra	L_GoBel
******* Play voice,note,length
L_IPlay3	equ	21
L21	move.l	(a3)+,d3
	Rbmi	L_IFonc
	move.l	(a3)+,d2
	move.l	(a3)+,d1
	moveq	#-1,d5
	moveq	#0,d6
	Rbra	L_GoBel
L_GoBel		equ	22
L22	cmp.l	#96,d2			* <96?
	Rbhi	L_IFonc
	move.w	d1,d0			* Stop voices
	eor.w	#$000F,d0
	Rbsr	L_StopDma
	Rbsr	L_VOnOf
	Rbra	L_GoShot
L_GoShot	equ	23
L23	move.l	a3,-(sp)
	lea	Circuits,a2
	Dload	a3
	move.w	EnvOn-MB(a3),d7
	clr.w	EnvOn-MB(a3)
	move.w	#$8000,Sami_Bits-MB(a3)
* Explores all 4 voices
	moveq	#0,d0
	move.w	d1,d4
	moveq	#3,d1
IPl1	btst	d1,d4
	beq.s	IPl2
	Rbsr	L_VPlay
IPl2	dbra	d1,IPl1
******* Start!
IPlX	Rbsr	L_DmaWait
	bset	#15,d0
	move.w	d0,DmaCon(a2)
	move.w	Sami_bits-MB(a3),IntEna(a2)
	move.w	d7,EnvOn-MB(a3)
	move.l	(sp)+,a3
* Wait?
	tst.l	d3
	beq.s	IPlX1
	Rjsr	L_WaitRout
IPlX1	rts

******* Play voice D1: WAVE orSAMPLE
L_VPlay		equ	24
L24	movem.l	d0-d6/a0-a2,-(sp)

	moveq	#0,d3
	bset	d1,d3
	move.w	d3,DmaCon(a2)		* Stop voice
	lsl.w	#7,d3
	move.w	d3,IntEna(a2)		* Stop interrupts
	bclr	d1,Noise-MB(a3)		* No more random
	
	tst.w	d2
	beq	VSil
	addq.w	#3,d2
	move.w	d5,d0			* Forced wave? (bell)
	bpl.s	VPl0
	move.w	d1,d0			* Wave or Sample?
	lsl.w	#1,d0
	lea	Waves-MB(a3),a0
	move.w	0(a0,d0.w),d0
	bmi	VPl2

* Play WAVE!
VPl0	beq	VPl4
	lea	$a0(a2),a2
	move.w	d1,d3
	lsl.w	#4,d3
	add.w	d3,a2			* a2-> I/O
	movem.l	d1-d3/a2,-(sp)
	move.w	d0,d1
	Rbsr	L_WaveAd
	Rbeq	L_WNDef
	move.l	a2,a1
	movem.l	(sp)+,d1-d3/a2
	pea	WaveEnv(a1)
	lea	WaveDeb(a1),a1
	subq.w	#1,d2
	move.w	d2,d3
	ext.l	d3
	divu	#12,d3
	lsl.w	#2,d3
	lea	TFreq-MB(a3),a0
	add.w	d3,a0
	add.w	(a0)+,a1
	move.l	a1,(a2)			* AudAd
	move.w	(a0)+,d3
	move.w	d3,4(a2)		* AudLen
	lsl.w	#1,d3
	lea	TNotes-MB(a3),a1
	lsl.w	#1,d2
	mulu	0(a1,d2.w),d3
	move.l	MusClock-MB(a3),d2
	divu	d3,d2
	cmp.w	#124,d2
	bcc.s	VPl1
	moveq	#124,d2
VPl1:	move.w	d2,6(a2)		* AudPer
* Start enveloppe 
	move.l	(sp)+,d5
	tst.l	d6			* Fixed enveloppe? (bell / shoot)
	bne.s	VPl1a
	move.l	d5,d6
VPl1a	lea	EnvBase-MB(a3),a0	
	move.w	d1,d0
	mulu	#EnvLong,d0
	add.w	d0,a0
	move.l	d6,EnvAd(a0)
	move.l	d6,EnvDeb(a0)
	clr.w	EnvVol(a0)
	Rbsr	L_MuIntE
	movem.l	(sp)+,a0-a2/d0-d6
	bset	d1,d0
	bset	d1,d7
	rts
******* Silence!
VSil	moveq	#0,d0
	bset	d1,d0
	move.w	d0,DmaCon(a2)
	movem.l	(sp)+,a0-a2/d0-d6
	bclr	d1,d7
	rts	
******* Play SAMPLE
VPl2	move.l	a2,-(sp)
	move.w	d2,-(sp)
	neg.w	d0
	Rbsr	L_GetSam
	move.w	(sp)+,d0
	move.l	(sp)+,a2
	moveq	#0,d6
VPl3	lea	TNotes-MB(a3),a0
	lsl.w	#1,d0
	mulu	-2(a0,d0.w),d3
	divu	#440,d3
	and.l	#$0000FFFF,d3
	Rbra	L_SPl0
******* Play NOISE
VPl4	bset	d1,Noise-MB(a3)
	move.w	d2,d0
	move.l	WaveBase-MB(a3),a1
	lea	WaveEnv(a1),a0
	lea	WaveDeb(a1),a1
	move.l	#LNoise,d2
	move.l	#2000,d3
	tst.l	d6
	bne.s	VPl3
	move.l	a0,d6
	bset	#0,d6
	bra.s	VPl3

******* PLAY OFF (voice)
L_IPlOf0	equ	25
L25	moveq	#%1111,d0
	Rbra	L_PlOf
L_IPlOf1	equ	26
L26	move.l	(a3)+,d0
	Rbra	L_Plof
L_PlOf		equ	27
L27	move.l	a3,-(sp)
	Dload	a3
	Rbsr	L_EnvOff
	move.l	(sp)+,a3
	rts

******* Attente DMA
L_DmaWait	equ	28
L28	movem.l	d2-d3,-(sp)

; A modifier!!! Demander les caracteristiques du DMA!!!
;	move.w	#$200,d0
;.loop	nop
;	dbra	d0,.loop

.wait	moveq	#4,d3		
.wai2	move.b	$dff006,d2	
.wai3	cmp.b	$dff006,d2	
	beq.s	.wai3
	dbf	d3,.wai2	
	moveq	#8,d2
.wai4	dbf	d2,.wai4

	movem.l	(sp)+,d2-d3
	rts

***********************************************************
*	SAMPLE INSTRUCTIONS

*******	SAM BANK n
L_ISBank	equ	29
L29	move.l	(a3)+,d0
	Rbls	L_IFonc
	cmp.l	#16,d0
	Rbhi	L_IFonc
	Dlea	SamBank,a0
	move.w	d0,(a0)
	rts
******* SAMLOOP ON
L_ISLOn1	equ	30
L30	moveq	#0,d0
	move.l	(a3)+,d1
	Rbra	L_Sl0

******* STOP DMA / INTERUPTS
*	D0= value
L_StopDma	equ	31
L31	move.w	d0,-(sp)
	eor.w	#%1111,d0
	move.w	d0,Circuits+DmaCon
	lsl.w	#7,d0
	move.w	d0,Circuits+IntEna
	move.w	(sp)+,d0
	RBra	L_DmaWait

L_ISLOn0	equ	32
L32	moveq	#0,d0
	moveq	#%1111,d1
	Rbra	L_Sl0

******* SAMLOOP OFF
L_ISLOf1	equ	33
L33	moveq	#-1,d0
	move.l	(a3)+,d1
	Rbra	L_Sl0
L_ISLOf0	equ	34
L34	moveq	#-1,d0
	moveq	#%1111,d1
	Rbra	L_SL0
L_SL0		equ	35
L35	moveq	#0,d2
	Dlea	Sami_int,a0
	Dlea	SamLoops+1,a1
Sl1	btst	d2,d1
	beq.s	Sl2
	bclr	d2,(a1)
	move.l	d0,Sami_rpos(a0)
	bne.s	Sl2
	bset	d2,(a1)
Sl2	lea	Sami_intl(a0),a0
	addq.w	#1,d2
	cmp.w	#4,d2
	bcs.s	Sl1
	rts

******* NOISE TO voice
L_INoTo		equ	36
L36	move.l	(a3)+,d1
	moveq	#0,d0
	Rbra	L_ISmt
******* SAMPLE n TO voice
L_ISamTo	equ	37
L37	move.l	4(a3),d0
	Rbsr	L_GetSam
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	neg.w	d0
	Rbra	L_Ismt
* Poke D1-> waves
L_ISmt		equ	38
L38	Dlea	Waves,a0
	moveq	#0,d2
ISmt1	btst	d2,d1
	beq.s	ISmt2
	move.w	d0,(a0)
ISmt2	addq.l	#2,a0
	addq.w	#1,d2
	cmp.w	#4,d2
	bcs.s	ISmt1
	rts

******* SAM PLAY number
L_ISam1		equ	39
L39	move.l	(a3)+,d0
	Rbsr	L_GetSam
	moveq	#%1111,d1
	Rbra	L_GoSam
******* SAM PLAY voix,number
L_ISam2		equ	40
L40	move.l	(a3)+,d0
	Rbsr	L_GetSam
	move.l	(a3)+,d1
	Rbra	L_GoSam
******* SAM PLAY voix,number,frequence
L_ISam3		equ	41
L41	move.l	4(a3),d0
	Rbsr	L_GetSam
	move.l	(a3)+,d3
	cmp.l	#500,d3
	Rble	L_IFonc
	addq.l	#4,a3
	move.l	(a3)+,d1	
	Rbra	L_GoSam
******* SAM RAW voice,ad,length,freq
L_ISamR		equ	42
L42	move.l	(a3)+,d3
	cmp.l	#500,d3
	Rble	L_IFonc
	move.l	(a3)+,d2
	cmp.l	#256,d2
	Rble	L_IFonc
	move.l	(a3)+,a1
	move.l	(a3)+,d1
	Rbra	L_GoSam
L_GoSam:	equ	43
L43	move.l	a3,-(sp)
	Dload	a3

	move.w	d1,d0
	eor.w	#$000F,d0
	Rbsr	L_StopDma
	Rbsr	L_VOnOf	

	lea	Circuits,a2
	move.w	EnvOn-MB(a3),d7
	clr.w	EnvOn-MB(a3)
	move.w	#$8000,Sami_bits-MB(a3)
* Do all voices
	moveq	#0,d0
	move.w	d1,d4
	moveq	#3,d1
ISp2b	btst	d1,d4
	beq.s	ISp2c
	Rbsr	L_SPlay
ISp2c	dbra	d1,ISp2b
* Start!
ISpX	
	Rbsr	L_DmaWait
	bset	#15,d0
	move.w	d0,DmaCon(a2)
	move.w	Sami_bits-MB(a3),IntEna(a2)
	move.w	d7,EnvOn-MB(a3)
	move.l	(sp)+,a3
	rts
	
******* Find a sample -> A0
L_GetSam	equ	44
L44	move.l	d0,-(sp)
	Dload	a0
	move.w	SamBank-MB(a0),d0
	ext.l	d0
	Rbeq	L_IFonc
	move.l	d1,-(sp)
	Rjsr	L_Bnk.GetAdr
	Rbeq	L_BNSam
	move.l	(sp)+,d1
	move.l	-8(a0),d0
	cmp.l	#"Samp",d0
	Rbne	L_BNSam
* Get sample characteristics1
	move.l	(sp)+,d0
	Rbls	L_IFonc
	cmp.w	(a0),d0
	Rbhi	L_SNDef
	lsl.w	#2,d0
	move.l	2-4(a0,d0.w),d0
	Rbeq	L_SNDef
	add.l	d0,a0
	moveq	#0,d3
	move.w	8(a0),d3
	move.l	10(a0),d2
	lea	14(a0),a1
	rts

*********************************************************************
*	SLOAD fichier,adresse,longueur
L_Sload		equ	45
L45	move.l	(a3)+,d3		Length
	RBmi	L_IFonc	
	move.l	(a3)+,d0		Adress (or bank)
	RJsr	L_Bnk.OrAdr
	move.l	d0,d2
	move.l	(a3)+,d0		File
	cmp.l	#10,d0
	Rbcc	L_IFonc
	subq.l	#1,d0
	Rbmi	L_IFonc
	mulu	#TFiche,d0
	lea	Fichiers(a5),a2
	add.w	d0,a2
	move.l	Fha(a2),d1
	RBeq	L_IFonc
	btst	#2,FhT(a2)
	Rbne	L_IFonc
* Load the data
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-42(a6)			DosRead
	move.l	(sp)+,a6
	tst.l	d0
	RBmi	L_IDError
	rts

******* SAMPLAY routine
*	A1= Sample
*	D3= Freq
*	D2= Long
*	D1= Voice
L_SPlay:	equ	46
L46	movem.l	d0-d6/a0-a2,-(sp)
	bclr	d1,Noise-MB(a3)
	moveq	#0,d6
	Rbra	L_SPl0

L_SPl0		equ	47
L47
	movem.l	a4,-(sp)

	moveq	#0,d0
	bset	d1,d0			* Stop voice
	move.w	d0,DmaCon(a2)

	lea	Sami_int-MB(a3),a4
	move.w	#Sami_intl,d0
	mulu	d1,d0
	add.w	d0,a4			* a4-> Sami interrupts
	move.w	Sami_bit(a4),IntEna(a2)	* No more interrupts

	lea	EnvBase-MB(a3),a0	* Enveloppe
	move.w	d1,d0
	mulu	#EnvLong,d0
	add.w	d0,a0

	lea	$a0(a2),a2
	move.w	d1,d4
	lsl.w	#4,d4
	add.w	d4,a2			* a2-> I/O

	move.w	#1,$4(a2)
	move.l	a1,Sami_adr(a4)			* Adresse
	move.l	d2,Sami_long(a4)		* Longueur
	clr.l	Sami_pos(a4)			* Position
	clr.l	Sami_rpos(a4)			* Sam loop on?
	btst	d1,SamLoops+1-MB(a3)
	bne.s	.skipa
	subq.l	#1,Sami_rpos(a4)
.skipa	clr.l	Sami_radr(a4)			* Pas de double buffer
	
	move.l	d6,d5
	move.l	MusClock-MB(a3),d6
	bsr	Div32
	cmp.l	#124,d0
	bcc.s	.skip0
	moveq	#124,d0
.skip0	move.w	d0,6(a2)			* AudPer

	bclr	d1,d7
	move.w	EnvDVol(a0),Sami_dvol(a4)	* Volume, sauf si 
	tst.l	d5				  une enveloppe est
	beq.s	.skip1				  definie
	clr.l	Sami_rpos(a4)
	bclr	#0,d5
	bne.s	.skipb
	subq.l	#1,Sami_rpos(a4)
.skipb	bset	d1,d7
	move.w	#-1,Sami_dvol(a4)
	move.l	d5,EnvAd(a0)
	move.l	d5,EnvDeb(a0)
	clr.w	EnvVol(a0)
	Rbsr	L_MuIntE

.skip1	move.w	Sami_bit(a4),d0
	or.w	d0,Sami_bits-MB(a3)

* Va demarrer le son...
	lea	Circuits,a0
	move.l	a4,a1
	move.l	Sami_Handad-MB(a3),a2
	jsr	(a2)
* Fini!
	move.l	(sp)+,a4
	movem.l	(sp)+,d0-d6/a0-a2
	bset	d1,d0
	rts

* Division 32 bits
* D6/D3 -> D0
Div32	movem.l	d1/d3/d4/d5/d6,-(sp)
	moveq 	#31,d5
        moveq 	#-1,d4
        clr.l 	d1
dv2:    lsl.l 	#1,d6
        roxl.l 	#1,d1
        cmp.l 	d3,d1
        bcs.s 	dv1
        sub.l 	d3,d1
        lsr 	#1,d4
dv1:    roxl.l 	#1,d0
        dbra 	d5,dv2
	movem.l	(sp)+,d1/d3/d4/d5/d6
	rts

***********************************************************
*	WAVE INSTRUCTION SET

*******	WAVE n TO n
L_IWave:	equ	48
L48	move.l	4(a3),d1
	Rbmi	L_IFonc
	Rbsr	L_WaveAd
	Rbeq	L_WNDef
	move.l	(a3)+,d1
	move.l	(a3)+,d0
	Rbra	L_ISmt
*******	SET WAVE n,a$
L_ISWave:	equ	49
L49	move.l	(a3)+,a1
	move.w	(a1)+,d1
	cmp.w	#256,d1
	Rbcs	L_STSho
	move.l	(a3)+,d1
	Rbls	L_IFonc
	move.l	a3,-(sp)
	Dload	a3
	Rbsr	L_NeWave
	Rbne	L_IOOMem
	move.l	(sp)+,a3
	rts
*******	DEL WAVE 
L_IDWave1	equ	50
L50	move.l	(a3)+,d1
	Rbmi	L_IFonc
	Rbeq	L_W0Res
	cmp.l	#1,d1
	Rbeq	L_W0Res
	move.l	a3,-(sp)
	DLoad	a3
	moveq	#%1111,d0
	Rbsr	L_EnvOff
	Rbsr	L_WaveAd
	Rbeq	L_WNDef
	Rbsr	L_WaveDel
	Rbsr	L_NoWave
	move.l	(sp)+,a3
	rts
*******	SET ENVEL n,n TO n,v
L_ISEnv		equ	51
L51	move.l	(a3)+,d4
	cmp.l	#64,d4
	Rbcc	L_IFonc
	move.l	(a3)+,d3
	move.l	(a3)+,d5
	Rbmi	L_IFonc
	cmp.l	#7,d5
	Rbcc	L_IFonc
	move.l	(a3)+,d1
	Rbmi	L_IFonc
	tst.w	d5
	bne.s	ISe1
	tst.w	d3
	Rbls	L_IFonc
ISe1	move.l	a3,-(sp)
	Dload	a3
	Rbsr	L_WaveAd
	Rbeq	L_WNDef
	lsl.w	#2,d5
	lea	WaveEnv(a2,d5.w),a2
	move.w	d3,(a2)+
	move.w	d4,(a2)+
	clr.w	(a2)
	move.l	(sp)+,a3
	rts
******* RAZ WAVES
L_RazWave	equ	52
L52	movem.l	a2/d0-d2,-(sp)
	moveq	#%1111,d0
	Rbsr	L_EnvOff		* Stop all voices
	lea	WaveBase-MB(a3),a2	* Erase all instruments
	move.l	a2,d2
RzW1	move.l	d2,a2
	move.l	(a2),d0
	beq.s	RzW2
	move.l	d0,a2
	Rbsr	L_WaveDel
	bra.s	RzW1
RzW2	Rbsr	L_NoWave
	movem.l	(sp)+,a2/d0-d2
	rts
* Plus de Waves speciales
L_NoWave	equ	53
L53	Dlea	Waves,a0		* Default waves
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	rts

******* NEW WAVES
*	A1= Array address
*	D1= # to create
L_NeWave:	equ	54
L54	movem.l	d1-d7/a1-a2,-(sp)
NeW0	Rbsr	L_WaveAd
	beq.s	NeW1
	moveq	#%1111,d0
	Rbsr	L_EnvOff
	Rbsr	L_WaveDel
	bra.s	NeW0
NeW1	move.l	#WaveLong,d0
	RJsr	L_RamChip
	beq.s	NeWE
	move.l	d0,(a2)
	move.l	d0,a2
	move.w	d1,WaveNb(a2)
* Copy default ADSR
	move.l	a1,-(sp)
	lea	EnvDef-MB(a3),a0
	lea	WaveEnv(a2),a1
NeW3	move.l	(a0)+,(a1)+
	bne.s	NeW3
	move.l	(sp)+,a1
* Full wave: 256 bytes
	lea	WaveDeb(a2),a2
	move.l	a2,a0
	moveq	#256/4-1,d0
NeW2	move.l	(a1)+,(a0)+
	dbra	d0,NeW2
* 1/2
	move.l	a2,a1
	move.l	a0,a2
	moveq	#127,d0
	bsr	NewRout
* 1/4
	move.l	a2,a1
	move.l	a0,a2
	moveq	#63,d0
	bsr	NewRout
* 1/8
	move.l	a2,a1	
	move.l	a0,a2
	moveq	#31,d0
	bsr	NewRout
* 1/16
	move.l	a2,a1
	move.l	a0,a2
	moveq	#15,d0
	bsr	NewRout
* 1/32
	move.l	a2,a1
	move.l	a0,a2
	moveq	#7,d0
	bsr	NewRout
* 1/64
	move.l	a2,a1
	move.l	a0,a2
	moveq	#3,d0
	bsr	NewRout
******* No error
	moveq	#0,d0
NeWx	movem.l	(sp)+,d1-d7/a1-a2
	rts
******* Out of mem
NeWE	moveq	#-1,d0
	bra.s	NeWx
******* Divide a sample by 2
NewRout	move.b	(a1)+,d1
	ext.w	d1
	move.b	(a1)+,d2
	ext.w	d2
	add.w	d2,d1
	asr.w	#1,d1
	move.b	d1,(a0)+
	dbra	d0,NewRout
	rts

******* Get a wave address
L_WaveAd:	equ	55
L55	moveq	#0,d2
	Dlea	WaveBase,a2
	move.l	(a2),d0
	beq.s	WAd2
WAd1	move.l	a2,d2
	move.l	d0,a2
	cmp.w	WaveNb(a2),d1
	beq.s	WAd3
	move.l	(a2),d0
	bne.s	WAd1
WAd2	moveq	#0,d0
	rts
WAd3	moveq	#-1,d0
	rts

******* Deletion of a WAVE (A2)-D2
L_WaveDel	equ	56
L56	movem.l	a0-a2/d0-d2,-(sp)
	move.w	WaveNb(a2),d1
	move.l	d2,a0
	move.l	(a2),(a0)
	move.l	#WaveLong,d0
	move.l	a2,a1
	Rjsr	L_RamFree
	movem.l	(sp)+,a0-a2/d0-d2
	rts

***********************************************************
*	STOP SAMPLES INTERRUPTS
L_Sami_stop	equ	57
L57	move.w	#%0000011110000000,d0
	move.w	d0,Circuits+IntEna
	move.w	d0,Circuits+IntReq
	rts

***********************************************************
*	ENVELOPPES 

***********************************************************
*	STOP ENVELOPPE D0
L_EnvOff	equ	58
L58	movem.l	d0-d3/a0,-(sp)
	move.w	EnvOn-MB(a3),d1
	clr.w	EnvOn-MB(a3)
	moveq	#0,d3
	lea	Circuits,a0
	moveq	#0,d2
EOf1	btst	d2,d0
	beq.s	EOf2
	bclr	d2,d1
	beq.s	EOf2
	bset	d2,d3
	move.w	#2,$a4(a0)
	clr.w	$a8(a0)
EOf2	lea	$10(a0),a0
	addq.w	#1,d2
	cmp.w	#4,d2
	bcs.s	EOf1
	move.w	d1,EnvOn-MB(a3)
	move.w	d3,MuReStart-MB(a3)
	movem.l	(sp)+,d0-d3/a0
	rts
	
******* Next enveloppe
L_MuIntE	equ	59
L59	move.l	EnvAd(a0),a1
MuIe0	move.w	(a1)+,d3
	beq.s	MuIntS
	bmi.s	MuIe1
	move.w	d3,EnvNb(a0)
	move.w	EnvDVol(a0),d4
	mulu	(a1)+,d4
	lsr.w	#6,d4
	sub.w	EnvVol(a0),d4
	ext.l	d4
	lsl.w	#8,d4
	divs	d3,d4
	ext.l	d4
	lsl.l	#8,d4
	move.l	d4,EnvDelta(a0)
	clr.w	EnvVol+2(a0)
	move.l	a1,EnvAd(a0)
	rts
* Loop
MuIe1	move.l	EnvDeb(a0),a1
	bra.s	MuIe0
* End of a voice
MuIntS	bset	d1,d5
	bclr	d1,d0
	bclr	d1,Noise-MB(a3)
* Restarts the music
	bset	d1,MuReStart+1-MB(a3)
	rts

******************************************************************
*	MUSIC

******* Music initialisation
L_MuInit:	equ	60
L60	clr.l	MuBase-MB(a3)
	clr.w	MuNumber-MB(a3)
	move.l	#$DFF0A0,MuChip0-MB(a3)
	move.l	#$DFF0B0,MuChip1-MB(a3)
	move.l	#$DFF0C0,MuChip2-MB(a3)
	move.l	#$DFF0D0,MuChip3-MB(a3)
	move.w	#$000F,MuDMAsk-MB(a3)
	clr.w	MuReStart-MB(a3)
	Rbra	L_MOff

******* MUSIC OFF-> Stops all musics
L_IMuSOff	equ	61
L61	movem.l	a0-a3/d0-d1,-(sp)
	Dload	a3
	clr.l	MuBase-MB(a3)
	clr.w	MuNumber-MB(a3)
	Rbsr	L_MOff
	movem.l	(sp)+,a0-a3/d0-d1
	rts

******* MUSIC STOP-> Stops current music
L_IMuStop	equ	62
L62	movem.l	a0-a3/d0-d1,-(sp)
	Dload	a3
	move.l	MuBase-MB(a3),d0
	beq.s	IStp
	clr.w	MuBase-MB(a3)
	move.l	d0,a0
	clr.w	VoiCpt0(a0)
	clr.w	VoiCpt1(a0)
	clr.w	VoiCpt2(a0)
	clr.w	VoiCpt3(a0)
	move.l	d0,MuBase-MB(a3)
IStp	movem.l	(sp)+,a0-a3/d0-d1
	rts

******* MUSIC VOLUME
L_IMVol		equ	63
L63	move.l	(a3)+,d0
	cmp.l	#64,d0
	Rbcs	L_MVol
	Rbcc	L_IFonc
* Set volume
L_MVol		equ	64
L64	and.w	#63,d0
	Dload	a0
	move.w	d0,MuVolume-MB(a0)
	move.l	MuBase-MB(a0),d4
	beq.s	MVol3
	clr.l	MuBase-MB(a0)
	lea	MuBuffer-MB(a0),a1
	move.w	MuNumber-MB(a0),d1
MVol0	move.l	a1,a2
	moveq	#3,d2
MVol1	move.w	VoiDVol(a2),d3
	mulu	d0,d3
	lsr.w	#6,d3
	move.w	d3,VoiVol(a2)
	lea	VoiLong(a2),a2
	dbra	d2,MVol1
MVol2	lea	MuLong(a1),a1
	subq.w	#1,d1
	bne.s	MVol0
	move.l	d4,MuBase-MB(a0)
MVol3	rts

******* VOICE ON/OFF Voices
L_IVoice	equ	65
L65	move.l	(a3)+,d0
	and.w	#$000F,d0
	move.l	a3,-(sp)
	Dload	a3
	Rbsr	L_VOnOf
	movem.l	(sp)+,a3
	rts

******* Start / Stop voices D0
L_VOnOf		equ	66
L66	movem.l	d0-d5/a0-a3,-(sp)
	move.w	d0,d4
	Dload	a3
	move.l	MuBase-MB(a3),d1
	beq.s	VooX
	clr.l	MuBase-MB(a3)
	move.l	d1,a1
	move.l	d1,a2
	move.w	MuDMAsk-MB(a3),d1
	move.w	d0,MuDMAsk-MB(a3)
	move.l	WaveBase-MB(a3),a0
	lea	WaveDeb(a0),a0
	move.l	a0,d3
	lea	MuChip0-MB(a3),a0
	moveq	#0,d2
	moveq	#0,d4
* Exploration loop
Voo1	btst	d2,d0
	bne.s	Voo2
* Stop a voice!
	btst	d2,d1			* Already stopped?
	beq.s	VooN
	bset	d2,d4
	move.l	d3,(a0)
	bclr	d2,MuStart+1(a2)
	bclr	d2,MuStop+1(a2)
	bra.s	VooN
* Re start a voice
Voo2	btst	d2,d1			* Already on?
	bne.s	VooN
	bset	d2,MuReStart+1-MB(a3)
* Next
VooN	addq.l	#4,a0
	lea	VoiLong(a1),a1
	addq.w	#1,d2
	cmp.w	#4,d2
	bcs.s	Voo1
* Stop them!
	move.l	a2,MuBase-MB(a3)
	move.w	d4,Circuits+DmaCon
VooX	movem.l	(sp)+,d0-d5/a0-a3
	rts

******* MUSIC n
L_IMusic	equ	67
L67	move.l	(a3)+,d3
	Rbls	L_IFonc
* Points to the SONG
	move.l	a3,-(sp)
	Dload	a3
	tst.l	MusBank-MB(a3)
	Rbeq	L_MnRes
	move.l	BankSong-MB(a3),a1
	cmp.w	(a1),d3
	Rbhi	L_MNDef
	lsl.w	#2,d3
	add.l	2-4(a1,d3.w),a1
* Still room?
	cmp.w	#3,MuNumber-MB(a3)
	bcc	IMusX
	clr.l	MuBase-MB(a3)
* Buffer address
	move.w	MuNumber-MB(a3),d0
	move.w	d0,d1
	addq.w	#1,MuNumber-MB(a3)
	mulu	#MuLong,d0
	lea	MuBuffer-MB(a3),a2
	add.w	d0,a2
* Init datas
	moveq	#(VoiLong*4)/2-1,d0
	move.l	a2,a0
IMus1	clr.w	(a0)+
	dbra	d0,IMus1
	clr.w	MuStop(a2)
	clr.w	MuStart(a2)
* Init parameters
	move.l	a2,d2
	move.w	TempoBase-MB(a3),MuCpt(a2)
	move.w	#17,MuTempo(a2)			*XXX
	moveq	#0,d0
IMus2	move.w	#1,VoiCpt(a2)
	lea	FoEnd-MB(a3),a0
	move.l	a0,VoiAdr(a2)
	move.l	a1,a0
	add.w	0(a0,d0.w),a0
	move.l	a0,VoiPat(a2)
	move.l	a0,VoiDPat(a2)
	lea	NoEffect2(pc),a0
	move.l	a0,VoiEffect(a2)
	lea	VoiLong(a2),a2
	addq.w	#2,d0
	cmp.w	#8,d0
	bne.s	IMus2
* No more samples
	move.w	#%0000011110000000,Circuits+IntEna
* Starts music
	move.l	d2,MuBase-MB(a3)
IMusX	move.l	(sp)+,a3
	rts
NoEffect2
	move.w	VoiNote(a4),$06(a6)
	rts

******* Tempo T
L_ITempo	equ	68
L68	move.l	(a3)+,d0
	cmp.l	#100,d0
	Rbhi	L_IFonc
	Dload	a0
	move.l	MuBase-MB(a0),d1
	beq.s	ITemp
	move.l	d1,a0
	move.w	d0,MuTempo(a0)
ITemp	rts

***********************************************************
*	=VU METRE(v)
L_FVu		equ	69
L69	move.l	(a3)+,d0
	cmp.l	#4,d0
	Rbcc	L_IFonc
	Dload	a0
	moveq	#0,d3
	move.b	0(a0,d0.w),d3
	clr.b	0(a0,d0.w)
	moveq	#0,d2
	rts

***********************************************************
*	=MU BASE
L_FMB		equ	70
L70	Dload	a0
	move.l	a0,d3
	moveq	#0,d2
	rts

***********************************************************
*	LED INSTRUCTION
L_LedOn		equ	71
L71	bclr	#1,$BFE001
	rts
L_LedOf		equ	72
L72	bset	#1,$BFE001
	rts

***********************************************************
*	INSTALL THE SAMPLE HANDLER
L_Sami_install	equ	73
L73	tst.w	Sami_flag-MB(a3)
	bne.s	.skip
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	$4.w,a6
; Save state of interrupts
	move.w	Circuits+IntEnaR,d0
	and.w	#%0000011110000000,d0
	move.w	d0,Sami_OldEna-MB(a3)
	Rbsr	L_Sami_stop
; Install 4 voices
	lea	Sami_int-MB(a3),a1
	moveq	#7,d0
.loop	bsr.s	Sami_start
	lea	Sami_intl(a1),a1
	addq.w	#1,d0
	cmp.w	#11,d0
	bne.s	.loop
	subq.w	#1,Sami_flag-MB(a3)
	movem.l	(sp)+,d0-d2/a0-a2/a6
.skip	rts
Sami_start
	move.l	a1,is_data(a1)
	move.l	Sami_handad-MB(a3),is_code(a1)
	move.b	#2,ln_type(a1)
	move.b	#0,ln_pri(a1)
	move.l	$4.w,a6	
	movem.l	d0/a1,-(sp)
	jsr	-162(a6)		SetIntVector
	move.l	d0,d1
	movem.l	(sp)+,d0/a1
	move.l	d1,Sami_old(a1)
	rts

***********************************************************
*	REMOVE THE SAMPLE HANDLER
L_Sami_remove	equ	74
L74	tst.w	Sami_flag-MB(a3)
	beq.s	.skip
	movem.l	a0-a2/a6/d0-d2,-(sp)
	Rbsr	L_Sami_Stop
	move.l	$4.w,a6
	moveq	#7,d2
	lea	Sami_Int-MB(a3),a2
.loop	move.l	Sami_old(a2),a1
	move.l	d2,d0
	jsr	-162(a6)		SetIntVector
	lea	Sami_intl(a2),a2
	addq.w	#1,d2	
	cmp.w	#11,d2
	bne.s	.loop
	lea	Circuits,a0
	move.w	#$000F,DmaCon(a0)
	move.w	Sami_oldena-MB(a3),IntEna(a0)
	clr.w	Sami_flag-MB(a3)
	movem.l	(sp)+,a0-a2/a6/d0-d2
.skip	rts

***********************************************************
*	Normal error messages
; This routines performs jump to the normal AMOS error messages:
; Load in D0 the number of the error, and do a RJmp to L_Error.
L_IOOMem	equ	75
L75	
	moveq	#24,d0
	Rjmp	L_Error
L_IFonc		equ	76
L76	moveq	#23,d0
	Rjmp	L_Error

***********************************************************
* 	Customized error messages
; This list of routines just load in D0 the number of the error message in
; the extension error-list, and call the error handling routine.

L_WNDef		equ	77
L77	moveq	#0,d0	
	Rbra	L_Custom
L_SNDef		equ	78
L78	moveq	#1,d0
	Rbra	L_Custom
L_BNSam		equ	79
L79	moveq	#2,d0
	Rbra	L_Custom
L_STSho		equ	80
L80	moveq	#3,d0
	Rbra	L_Custom
L_W0Res		equ	81
L81	moveq	#4,d0
	Rbra	L_Custom
L_MnRes		equ	82
L82	moveq	#5,d0
	Rbra	L_Custom
L_MNDef		equ	83
L83	moveq	#6,d0
	Rbra	L_Custom


********************************************************************
*	=SAM SWAPPED(V)
L_Samswapped	equ	84
L84	move.l	(a3)+,d0
	moveq	#0,d2
	moveq	#0,d3
	cmp.l	#3,d0
	Rbhi	L_IFonc
	move.w	Circuits+IntEnaR,d1
	lsr.w	#7,d1
	btst	d0,d1
	beq.s	.stop
	Dlea	Sami_int,a0
	mulu	#Sami_intl,d0
	tst.l	Sami_radr(a0,d0.l)
	bne.s	.skip
	move.l	Sami_pos(a0,d0.l),d1
	cmp.l	#Sami_lplay,d1
	beq.s	.skip
	moveq	#-1,d3
.skip	rts
.stop	moveq	#1,d3
	rts
*********************************************************************
*	SAM SWAP
L_SamSwap	equ	85
L85	move.l	(a3)+,d4
	Rbmi	L_IFonc
	move.l	(a3)+,d0
	Rjsr	L_Bnk.OrAdr
	move.l	d0,d3
	move.l	(a3)+,d2
	moveq	#0,d1
	Dlea	Sami_int,a0
.loop	btst	d1,d2
	beq.s	.skip
	move.l	d3,Sami_radr(a0)
	move.l	d4,Sami_rlong(a0)
.skip	lea	Sami_intl(a0),a0
	addq.w	#1,d1
	cmp.w	#4,d1
	bne.s	.loop
	rts
*********************************************************************
*	SAM STOP
L_SamStop0	equ	86
L86	move.l	#$f,-(a3)
	RBra	L_SamStop1
L_SamStop1	equ	87
L87	move.l	(a3)+,d1
	and.l	#$F,d1
	move.w	d1,Circuits+DmaCon
	lsl.w	#7,d1	
	move.w	d1,Circuits+IntEna
	rts

*********************************************************************
*	TRACKER instructions

*******	TRACK LOAD "nom",banque
L_Trackload	equ	88
L88	
	move.l	(a3)+,d3
	cmp.l	#$10000,d3
	Rbge	L_IFonc
	Dload	a0
	cmp.w	Track_Bank-MB(a0),d3
	bne.s	.kkk
	tst.b	mt_on-MB(a0)
	beq.s	.kkk
	RBsr	L_TrackStop
.kkk	move.w	d3,Track_Bank-MB(a0)	* Numero de la banque
	move.l	d3,-(sp)
; Get name to load
; ~~~~~~~~~~~~~~~~
	move.l	(a3)+,a0
	move.w	(a0)+,d0
	subq.w	#1,d0	
	cmp.w	#128,d0
	Rbcc	L_IFonc
	move.l	Name1(a5),a1
.loop	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	clr.b	(a1)
	Rjsr	L_Dsk.PathIt
; Open the file
; ~~~~~~~~~~~~~
	move.l	Name1(a5),d1
	move.l	#1005,d2
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-30(a6)			DosOpen, fichier sons
	move.l	(sp)+,a6
	move.l	d0,d7
	Rbeq	L_IDError
	move.l	d7,d1			Trouve la taille
	bsr	.taille
	move.l	d0,d6
; Reserve the bank
; ~~~~~~~~~~~~~~~~
	move.l	(sp)+,d0				Numero
	moveq	#(1<<Bnk_BitData+1<<Bnk_BitChip),d1	Flag
	move.l	d6,d2					Taille
	lea	BkTrack(pc),a0				Nom
	Rjsr	L_Bnk.Reserve
	beq	.mem
; Load the music
; ~~~~~~~~~~~~~~
	move.l	d7,d1
	move.l	a0,d2
	move.l	d6,d3
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-42(a6)			Read
	move.l	(sp)+,a6
	move.l	d0,d2
	move.l	d7,d1
	bsr	.clo
	cmp.l	d2,d3
	Rbne	L_IFonc
	rts
* Close the file
.clo	movem.l	a6/a0/a1,-(sp)
	move.l	DosBase(a5),a6
	jsr	-36(a6)			Close
	movem.l	(sp)+,a6/a0/a1
	rts
* Out of memory
.mem	move.l	d7,d1
	bsr.s	.clo
	RBra	L_IOOMem
* Find the size of the file
.taille	move.l	a6,-(sp)
	move.l	d1,-(sp)
	moveq	#0,d2
	moveq	#1,d3
	move.l	DosBase(a5),a6
	jsr	-66(a6)			DosSeek
	move.l	(sp)+,d1
	move.l	d0,d2
	moveq	#-1,d3
	move.l	DosBase(a5),a6
	jsr	-66(a6)			DosSeek
	move.l	(sp)+,a6
	rts
BkTrack	dc.b	"Tracker "
	even

******* TRACK CHECK, arrete la musique si pas banque...
L_TrackCheck	equ	89
L89	movem.l	a0-a1,-(sp)
	DLoad	a1
	tst.b	mt_on-MB(a1)
	beq.s	.skip
	move.l	mt_data-MB(a1),a0
	cmp.l	#"ker ",-(a0)
	bne.s	.stop
	cmp.l	#"Trac",-(a0)
	beq.s	.skip
.stop	RBsr	L_TrackStop
.skip	movem.l	(sp)+,a0-a1
	rts

******* TRACK STOP
L_TrackStop	equ	90
L90	move.l	a0,-(sp)
	Dload	a0
	tst.b	mt_on-MB(a0)
	beq.s	.Skip
	clr.b	mt_on-MB(a0)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
.Skip	move.l	(sp)+,a0
	rts

******* TRACK LOOP ON/OFF
L_TrackLoopon	equ	91
L91	rts
L_TrackLoopof	equ	92
L92	rts

******* TRACK PLAY [Bank],[Pattern]

L_TrackPlay0	equ	93
L93
	move.l	#Entnul,-(a3)
	Rbra	94

L_TrackPlay1	equ	94
L94	
	move.l	#Entnul,-(a3)
	Rbra	95

L_TrackPlay2	equ	95
L95	
	move.l	(a3)+,d7
	cmp.l	#Entnul,(a3)
	bne.s	.skip
	Dload	a0
	moveq	#0,d0
	move.w	Track_Bank-MB(a0),d0
	move.l	d0,(a3)
.skip	
	move.l	(a3)+,d0
	Rjsr	L_Bnk.OrAdr
	move.l	d0,a2
	cmp.l	#"Trac",-8(a2)	
	bne	.nobank
	cmp.l	#"ker ",-4(a2)
	bne	.nobank
	
	Rbsr	L_SamStop0
	Rbsr	L_TrackStop
	
; Init music...
; ~~~~~~~~~~~~~
	move.l	a3,-(sp)
	Dload	a3
	move.l	a2,a0
	move.l	a0,mt_data-MB(a3)
	lea	mt_mulu-MB(a3),a1
	moveq	#$0c,d0
	add.l	a0,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
.lop4	move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,.lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
.lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	.lop
	move.l	d1,d2
.lop	dbf	d0,.lop2
	addq.w	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts-MB(a3),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
.lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,.lop3

	move.b	#6,mt_speed-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_samplestarts-$7c(a1)
	move.b	d0,mt_counter-mt_samplestarts-$7c(a1)
	move.w	d0,mt_pattpos-mt_samplestarts-$7c(a1)

; Demarage de la musique!
; ~~~~~~~~~~~~~~~~~~~~~~~
	move.b	#1,mt_on-MB(a3)
	move.l	(sp)+,a3	
	rts
* Pas un module tracker
.nobank	moveq	#8,d0
	Rbra	L_Custom

******* Erreur disque
L_IDError	equ	96
L96	move.w	#DEBase+15,d0
	Rjmp	L_Error

******* Routine, demande la bouche du narrator
L_Lips		equ	97
L97	Dload	a2
	tst.l	TranBase-MB(a2)
	beq.s	.Err
	move.l	WriteIo-MB(a2),d0
	beq.s	.Err
	move.l	d0,a0
	tst.b	66(a0)
	beq.s	.Err
	lea	ReadIo-MB(a2),a1
	move.w	#2,28(a1)			CMD_READ
	move.l	a6,-(sp)
	move.l	$4.w,a6
	jsr	DoIO(a6)
	move.l	(sp)+,a6
	lea	ReadIo-MB(a2),a1
	cmp.b	#-8,$1f(a1)			ND_NOWRITE
	beq.s	.Err
	rts
.Err	lea	ReadIo-MB(a2),a0
	move.w	#-1,88(a0)
	rts

*********************************************************************
*	AMIGA.LIB linked code. 
*	In order to make it relocatable, I have been
*	obliged to disassemble the code and include it in this 
*	routine.
L_Amiga.Lib	equ	98
L98	lsl.w	#2,d0
	lea	JJJmp(pc),a0
	jmp	0(a0,d0.w)
JJJmp	bra	_CreatePort
	bra	_DeletePort
	bra	_CreateExtIO
	bra	_DeleteExtIO

_CreatePort
	MOVEM.L	D2-7/A2,-(A7)
	MOVE.L	$20(A7),D4
	MOVE.B	$27(A7),D3
	MOVE.L	#$FFFFFFFF,-(A7)
	BSR	L7C7DB14
	MOVE.L	D0,D5
	MOVE.L	D5,D6
	MOVEQ	#-1,D2
	CMP.L	D5,D2
	ADDQ.L	#4,A7
	BNE.S	L7C7D97A
	MOVEQ	#0,D0
	BRA	L7C7D9E6
L7C7D97A	MOVE.L	#$10001,-(A7)
	PEA	$22.W
	BSR	L7C7DAD0
	MOVEA.L	D0,A2
	EXG	D7,A2
	TST.L	D7
	EXG	D7,A2
	ADDQ.L	#8,A7
	BNE.S	L7C7D9A4
	MOVE.L	D6,-(A7)
	BSR	L7C7DB28
	MOVEQ	#0,D0
	ADDQ.L	#4,A7
	BRA.S	L7C7D9E6
L7C7D9A4	MOVE.L	D4,$A(A2)
	MOVE.B	D3,9(A2)
	MOVE.B	#4,8(A2)
	CLR.B	$E(A2)
	MOVE.B	D6,$F(A2)
	CLR.L	-(A7)
	BSR	L7C7DB00
	MOVE.L	D0,$10(A2)
	TST.L	D4
	ADDQ.L	#4,A7
	BEQ.S	L7C7D9D8
	MOVE.L	A2,-(A7)
	BSR	L7C7DB3C
	ADDQ.L	#4,A7
	BRA.S	L7C7D9E4
L7C7D9D8	PEA	$14(A2)
	BSR	_NewList
	ADDQ.L	#4,A7
L7C7D9E4	MOVE.L	A2,D0
L7C7D9E6	MOVEM.L	(A7)+,D2-7/A2
	RTS

_DeletePort
	MOVEM.L	D2/A2,-(A7)
	MOVEA.L	$C(A7),A2
	TST.L	$A(A2)
	BEQ.S	L7C7DA04
	MOVE.L	A2,-(A7)
	BSR	L7C7DB50
	ADDQ.L	#4,A7
L7C7DA04	MOVE.B	#$FF,8(A2)
	MOVEQ	#-1,D2
	MOVE.L	D2,$14(A2)
	MOVEQ	#0,D2
	MOVE.B	$F(A2),D2
	MOVE.L	D2,-(A7)
	BSR	L7C7DB28
	PEA	$22.W
	MOVE.L	A2,-(A7)
	BSR	L7C7DAE8
	LEA	$C(A7),A7
	MOVEM.L	(A7)+,D2/A2
	RTS
_CreateExtIO
	MOVEM.L	D2-4,-(A7)
	MOVE.L	$10(A7),D2
	MOVE.L	$14(A7),D3
	TST.L	D2
	BNE.S	L7C7DA54
	MOVEQ	#0,D0
	BRA.S	L7C7DA82
L7C7DA54	MOVE.L	#$10001,-(A7)
	MOVE.L	D3,-(A7)
	BSR	L7C7DAD0
	MOVEA.L	D0,A0
	EXG	D4,A0
	TST.L	D4
	EXG	D4,A0
	ADDQ.L	#8,A7
	BNE.S	L7C7DA72
	MOVEQ	#0,D0
	BRA.S	L7C7DA82
L7C7DA72	MOVE.B	#5,8(A0)
	MOVE.W	D3,$12(A0)
	MOVE.L	D2,$E(A0)
	MOVE.L	A0,D0
L7C7DA82	MOVEM.L	(A7)+,D2-4
	RTS

_DeleteExtIO
	MOVEM.L	D2-3,-(A7)
	MOVEA.L	$C(A7),A0
	EXG	D3,A0
	TST.L	D3
	EXG	D3,A0
	BEQ	L7C7DABE
	MOVE.B	#$FF,8(A0)
	MOVEQ	#-1,D2
	MOVE.L	D2,$14(A0)
	MOVEQ	#-1,D2
	MOVE.L	D2,$18(A0)
	MOVEQ	#0,D2
	MOVE.W	$12(A0),D2
	MOVE.L	D2,-(A7)
	MOVE.L	A0,-(A7)
	BSR	L7C7DAE8
	ADDQ.L	#8,A7
L7C7DABE	MOVEM.L	(A7)+,D2-3
	RTS
L7C7DAD0
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVEM.L	8(A7),D0-1
	JSR	-$C6(A6)
	MOVEA.L	(A7)+,A6
	RTS
L7C7DAE8
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVEA.L	8(A7),A1
	MOVE.L	$C(A7),D0
	JSR	-$D2(A6)
	MOVEA.L	(A7)+,A6
	RTS
L7C7DB00
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVEA.L	8(A7),A1
	JSR	-$126(A6)
	MOVEA.L	(A7)+,A6
	RTS
L7C7DB14
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVE.L	8(A7),D0
	JSR	-$14A(A6)
	MOVEA.L	(A7)+,A6
	RTS
L7C7DB28
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVE.L	8(A7),D0
	JSR	-$150(A6)
	MOVEA.L	(A7)+,A6
	RTS
L7C7DB3C
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVEA.L	8(A7),A1
	JSR	-$162(A6)
	MOVEA.L	(A7)+,A6
	RTS
L7C7DB50
	MOVE.L	A6,-(A7)
	MOVEA.L	$4.w,A6
	MOVEA.L	8(A7),A1
	JSR	-$168(A6)
	MOVEA.L	(A7)+,A6
	RTS
_NewList
	move.l	4(a7),a0
	move.l	a0,(a0)
	addq.l	#4,(a0)
	clr.l	4(a0)
	move.l	a0,8(a0)
	rts

******* TALK MISC volume,freq
L_TalkMisc		equ	99
L99	Rbsr	L_OpNar
	move.l	#EntNul,d0
	Dload	a1
	move.l	WriteIo-MB(a1),a1
	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	.IRd0
	cmp.w	#5000,d1
	Rbcs	L_IFonc
	cmp.w	#25000,d1
	Rbhi	L_IFonc
	move.w	d1,64(a1)
.IRd0
	move.l	(a3)+,d1
	cmp.l	d0,d1
	beq.s	.IRd1
	tst.l	d1
	RBmi	L_IFonc
	cmp.w	#64,d1
	Rbhi	L_IFonc
	move.w	d1,62(a1)
.IRd1
	rts

*********************************************************************
*	SSAVE fichier,adresse To fin
L_SSave		equ	100
L100	move.l	(a3)+,d3		End adress
	move.l	(a3)+,d2		Start Adress
	sub.l	d2,d3
	RBle	L_IFonc
	move.l	(a3)+,d0		File
	cmp.l	#10,d0
	Rbcc	L_IFonc
	subq.l	#1,d0
	Rbmi	L_IFonc
	mulu	#TFiche,d0
	lea	Fichiers(a5),a2
	add.w	d0,a2
	move.l	Fha(a2),d1
	Rbeq	L_IFonc
	btst	#2,FhT(a2)
	Rbne	L_IFonc
* Save the data
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	_LVOWrite(a6)
	move.l	(sp)+,a6
	tst.l	d0
	RBmi	L_IDError
	rts


; ___________________________________________________________________
;
;	MED instructions
; ___________________________________________________________________

;	MED LOAD "nom",banque
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedLoad	equ	101
L101	Rbsr	L_MedOpen
	move.l	(a3)+,d3
	cmp.l	#$10000,d3
	Rbge	L_IFonc
	Dload	a2
	cmp.w	Med_Bank-MB(a2),d3
	bne.s	.k
	Rbsr	L_MedStop
.k	move.w	d3,Med_Bank-MB(a2)	* Numero de la banque
; Get name to load
; ~~~~~~~~~~~~~~~~
	move.l	(a3)+,a0
	move.w	(a0)+,d0
	subq.w	#1,d0	
	cmp.w	#128,d0
	Rbcc	L_IFonc
	move.l	Name1(a5),a1
.loop	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	clr.b	(a1)
	Rjsr	L_Dsk.PathIt
; Trouve la taille
; ~~~~~~~~~~~~~~~~
	move.l	Name1(a5),d1
	move.l	#1005,d2
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-30(a6)			DosOpen,
	move.l	(sp)+,a6
	move.l	d0,d7
	Rbeq	L_IDError
	move.l	d7,d1			Trouve la taille
	bsr	.taille
	move.l	d0,d6
; Reserve la banque
; ~~~~~~~~~~~~~~~~~
	move.w	Med_Bank-MB(a2),d0			Numero de la banque
	ext.l	d0
	moveq	#(1<<Bnk_BitChip),d1			Flag CHIP
	move.l	d6,d2
	addq.l	#8,d2					Taille
	lea	.BkMed(pc),a0				Nom
	Rjsr	L_Bnk.Reserve
	beq	.mem
	move.l	a0,a2
; Charge la musique
; ~~~~~~~~~~~~~~~~~
	move.l	d7,d1
	move.l	a2,d2
	move.l	d6,d3
	move.l	a6,-(sp)
	move.l	DosBase(a5),a6
	jsr	-42(a6)			Read
	move.l	(sp)+,a6
	move.l	d0,d2
	move.l	d7,d1
	bsr	.clo
	cmp.l	d2,d3
	Rbne	L_IFonc
	cmp.l	#"MMD0",(a2)
	beq.s	.ok
	cmp.l	#"MMD1",(a2)
	bne.s	.med
; Relocation du module
; ~~~~~~~~~~~~~~~~~~~~
.ok	move.l	a6,-(sp)
	Dload	a0
	move.l	Med_Base-MB(a0),a6
	move.l	a2,a0
	jsr	_MEDRelocModule(a6)
	move.l	(sp)+,a6
	rts
* Ferme le fichier
.clo	movem.l	a6/a0/a1,-(sp)
	move.l	DosBase(a5),a6
	jsr	-36(a6)			Close
	movem.l	(sp)+,a6/a0/a1
	rts
* Out of memory
.mem	move.l	d7,d1
	beq.s	.xx
	bsr.s	.clo
.xx	Rbra	L_IOOMem
* Not a MED file
.med	Dlea	Med_Bank,a0
	move.w	(a0),d0
	ext.l	d0
	Rjsr	L_Bnk.Eff
	move.w	#189,d0
	Rjmp	L_Error
* Routine, trouve la taille d'un fichier
.taille	move.l	a6,-(sp)
	move.l	d1,-(sp)
	moveq	#0,d2
	moveq	#1,d3
	move.l	DosBase(a5),a6
	jsr	-66(a6)			DosSeek
	move.l	(sp)+,d1
	move.l	d0,d2
	moveq	#-1,d3
	move.l	DosBase(a5),a6
	jsr	-66(a6)			DosSeek
	move.l	(sp)+,a6
	rts
.BkMed	dc.b	"Med     "
	even

;	MED CHECK, arrete la musique si pas banque...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedCheck	equ	102
L102	movem.l	d0/a0-a1,-(sp)
	DLoad	a1
	tst.b	Med_On-MB(a1)
	beq.s	.skip
	move.l	Med_Adr-MB(a1),d0
	beq.s	.skip
	move.l	d0,a0
	cmp.l	#"Med ",-(a0)
	bne.s	.stop
	cmp.l	#"    ",-(a0)
	beq.s	.skip
.stop	Rbsr	L_MedStop
	clr.l	Med_Adr-MB(a1)
.skip	movem.l	(sp)+,d0/a0-a1
	rts

;	MED STOP
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedStop	equ	103
L103	movem.l	a0-a2/a6/d0-d2,-(sp)
	Dload	a0
	tst.b	Med_On-MB(a0)
	beq.s	.NoMed
	clr.b	Med_On-MB(a0)
	move.l	Med_Base-MB(a0),a6
	jsr	_MEDStopPlayer(a6)
.NoMed	movem.l	(sp)+,a0-a2/a6/d0-d2
	rts

;	MED PLAY [Bank],[Song]
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedPlay0	equ	104
L104	move.l	#EntNul,-(a3)
	Rbra	L_MedPlay1
L_MedPlay1	equ	105
L105	move.l	#EntNul,-(a3)
	Rbra	L_MedPlay2
L_MedPlay2	equ	106
L106	Dload	a2			Arret d'une eventuelle musique
	Rbsr	L_MedOpen		Ouvre la librairie, s'il faut
	Rbsr	L_MedStop
	clr.l	Med_Adr-MB(a2)
; Verification de la banque
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l	(a3)+,d7
	cmp.l	#Entnul,(a3)
	bne.s	.skip
	moveq	#0,d0
	move.w	Med_Bank-MB(a2),d0
	move.l	d0,(a3)
.skip	move.l	(a3)+,d0
	Rjsr	L_Bnk.OrAdr
	move.l	d0,a2
	cmp.l	#"Med ",-8(a2)	
	bne	.nobank
	cmp.l	#"    ",-4(a2)
	bne	.nobank
	
; Arret de tous les sons...
; ~~~~~~~~~~~~~~~~~~~~~~~~~
	Rbsr	L_SamStop0
	Rbsr	L_TrackStop
	Rbsr	L_MedStop
; Pointe la chanson
; ~~~~~~~~~~~~~~~~~
	movem.l	a3/a6,-(sp)
	Dload	a3
	moveq	#0,d0
	cmp.l	#Entnul,d7
	beq.s	.skp
	move.l	d7,d0
.skp	move.l	Med_Base-MB(a3),a6
	jsr	_MEDSetModnum(a6)
; Demarre la chanson
; ~~~~~~~~~~~~~~~~~~
	move.l	a2,a0
	jsr	_MEDPlayModule(a6)
	move.l	a2,Med_Adr-MB(a3)
	move.b	#1,Med_On-MB(a3)
; Terminé
; ~~~~~~~
	movem.l	(sp)+,a3/a6
	rts
; Pas une banque MED
; ~~~~~~~~~~~~~~~~~~
.nobank	moveq	#8,d0
	Rbra	L_Custom

; 	Ouvre la librairie MED
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedOpen	equ	107
L107	movem.l	a0-a2/d0-d2,-(sp)
	Dload	a2
	tst.l	Med_Base-MB(a2)
	bne.s	.Open
	lea	Med_Name-MB(a2),a1
	moveq	#2,d0			2 et pas 3!!!!!!!!!!!!!!!!!!!!
	move.l	a6,-(sp)
	move.l	$4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	(sp)+,a6
	move.l	d0,Med_Base-MB(a2)
	beq.s	.Err1
	moveq	#0,d0
	move.b	Med_Midi-MB(a2),d0
	move.l	a6,-(sp)
	move.l	Med_Base-MB(a2),a6
	jsr	_MEDGetPlayer(a6)
	move.l	(sp)+,a6
	tst.l	d0
	bne	.Err2
.Open	movem.l	(sp)+,a0-a2/d0-d2
	rts
.Err1	move.w	#187,d0			Cannot load med.lib
	Rjmp	L_Error
.Err2	Rbsr	L_MedClose		Cannot initialise med.lib
	move.w	#188,d0
	Rjmp	L_Error	

;	MED MIDI ON / OFF
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedMidiOn	equ	108	
L108	Dlea	Med_Midi,a0
	move.b	#1,(a0)
	rts
L109

;	MED CLOSE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedClose	equ	110
L110	movem.l	a0-a2/a6/d0-d2,-(sp)
	Rbsr	L_MedStop
	Dload	a2
	clr.b	Med_Midi-MB(a2)
	clr.l	Med_Adr-MB(a2)
	move.l	Med_Base-MB(a2),d0
	beq.s	.Skip
	move.l	d0,a6
	jsr	_MEDFreePlayer(a6)
	move.l	Med_Base-MB(a2),a1
	clr.l	Med_Base-MB(a2)
	move.l	$4.w,a6
	jsr	_LVOCloseLibrary(a6)
.Skip	movem.l	(sp)+,a0-a2/a6/d0-d2
	rts

;	MED CONT
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L_MedCont	equ	111
L111	movem.l	a0-a2/a6/d0-d2,-(sp)
	Dload	a0
	move.l	Med_Adr-MB(a0),d0
	beq.s	.Skip
	tst.b	Med_On-MB(a0)
	bne.s	.Skip
	move.b	#1,Med_On-MB(a0)
	move.l	Med_Base-MB(a0),a6
	move.l	d0,a0
	jsr	_MEDContModule(a6)
.Skip	movem.l	(sp)+,a0-a2/a6/d0-d2
	rts
	

*********************************************************************
*	ERROR MESSAGES...
;
; You know that the compiler have a -E1 option (with errors) and a 
; a -E0 (without errors). To achieve that, the compiler copies one of
; the two next routines, depending on the -E flag. If errors are to be
; copied along with the program, then the next next routine is used. If not,
; then the next one is copied.
; The compiler assumes that the two last routines in the library handles
; the errors: the previous last is WITH errors, the last is WITHOUT. So,
; remember:
;
; THESE ROUTINES MUST BE THE LAST ONES IN THE LIBRARY
;
; The AMOS interpretor always needs errors. So make all your custom errors
; calls point to the L_Custom routine, and everything will work fine...
;
******* "With messages" routine.
; The following routine is the one your program must call to output
; a extension error message. It will be used under interpretor and under
; compiled program with -E1

L_Custom	equ	112
L112	lea	ErrMess(pc),a0
	moveq	#0,d1			* Can be trapped
	moveq	#ExtNb,d2		* Number of extension
	moveq	#0,d3			* IMPORTANT!!!
	RJmp	L_ErrorExt		* Jump to routine...
* Messages...
ErrMess	dc.b	"Wave not defined",0			*0
	dc.b 	"Sample not defined",0			*1
	dc.b 	"Sample bank not found",0		*2
	dc.b	"256 characters for a wave",0		*3
	dc.b	"Wave 0 and 1 are reserved",0		*4
	dc.b	"Music bank not found",0		*5
	dc.b 	"Music not defined",0			*6
	dc.b	"Can't open narrator",0			*7
	dc.b	"Not a tracker module",0		*8
* IMPORTANT! Always EVEN!
	even

******* "No errors" routine
; If you compile with -E0, the compiler will replace the previous
; routine by this one. This one just sets D3 to -1, and does not
; load messages in A0. Anyway, values in D1 and D2 must be valid.
;	
; THIS ROUTINE MUST BE THE LAST ONE IN THE LIBRARY!
;

L113	moveq	#0,d1
	moveq	#ExtNb,d2
	moveq	#-1,d3
	RJmp	L_ErrorExt

; Do not forget the last label to delimit the last library routine!
L114

; ---------------------------------------------------------------------
; Now the title of the extension, just the string.
;
; TITLE MESSAGE
C_Title	dc.b	"AMOSPro Music extension V "
	Version
	dc.b	0,"$VER: "
	Version
	dc.b	0
	Even
; 
; Note : magic title!
; ~~~~~~~~~~~~~~~~~~~
; If your extension begins with "MAGIC***", AMOSPro will call the 
; address located after the string (even of course!). You can do whatever
; you want to the editor screen (the current at the moment), but
; restore it.
; You also handle the user key press, and the PREVIOUS/NEXT/CANCEL
; selection, buy returning a number in D0:
;	D0=-1	Cancel
;	D0=0	Previous extension
;	D0=1	Next extension
; Example of magic title:
;	C_Title		dc.b	"MAGIC***"
;			bra	Magic_Title


; END OF THE EXTENSION
C_End	dc.w	0
	even


