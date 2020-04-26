
 
*
CDebug		set	0
Switcher_Signal	equ	24
*
***********************************************************
*
*		AMOSPro EQUATES DEFINITION
*
*		By Francois Lionet
*		AMOS (c) 1990-1992 Europress Software Ltd.
*
*		Last change 23/09/1992
*
***********************************************************
*	This file contains all the equates of the AMOSPro
* programs and extension.
* Be patient, we will soon (I hope) publish informations
* about the functions of the amos.library.
***********************************************************
* 	Only for multi-lingual readers: half english
* half french. That's Europe!
***********************************************************

BFORM_ILBM	equ	%00000001
BFORM_ACBM	equ	%00000010
BFORM_ANIM	equ	%00000100
BCHUNK_BMHD	equ	0
BCHUNK_CAMG	equ	1
BCHUNK_CMAP	equ	2
BCHUNK_CCRT	equ	3
BCHUNK_BODY	equ	4
BCHUNK_AMSC	equ	5
BCHUNK_ABIT	equ	6

EntNul:		equ $80000000

Circuits:	equ $dff000

IntReq:		equ $9c
IntEna:		equ $9a
DmaCon:		equ $96
DmaConR:	equ $02

Color00:	equ $180
VhPosR:		equ $6

; Copper
Cop1lc:		equ $80
Cop2lc:		equ $84
CopJmp1:	equ $88
CopJmp2:	equ $8a

; Souris
CiaAprA:	equ $bfe001
Joy0Dat:	equ $a
Joy1Dat:	equ $c
JoyTest:	equ $36
PotGo:		equ $34
PotGoR:		equ $16
Pot0Dat:	equ $12
Pot1Dat:	equ $14

; Bitplanes
BplCon0:	equ $100
BplCon1:	equ $102
BplCon2:	equ $104
Bpl1PtH:	equ $0e0
Bpl1PtL:	equ $0e2
Bpl1Mod:	equ $108
Bpl2Mod:	equ $10a
DiwStrt:	equ $08e
DiwStop:	equ $090
DdfStrt:	equ $092
DdfStop:	equ $094

; Blitter
BltSize:	equ $058
BltAdA:		equ $050
BltAdB:		equ $04c
BltAdC:		equ $048
BltAdD:		equ $054
BltModA:	equ $064
BltModB:	equ $062
BltModC:	equ $060
BltModD:	equ $066
BltCon0:	equ $040
BltCon1:	equ $042
BltDatA:	equ $074
BltDatB:	equ $072
BltDatC:	equ $070
BltDatD:	equ $000
BltMaskG:	equ $044
BltMaskD:	equ $046

;-------------> Systeme
		IFND	ExecBase
ExecBase:	equ 4
		ENDC
StartList:	equ 38
Forbid:		equ -132
Permit:		equ -138
OwnBlitter:	equ -30-426
DisOwnBlitter:	equ -30-432
WaitBlit:	equ -228
OpenLib:	equ -552
CloseLib:	equ -414
AllocMem:	equ -198
AvailMem:	equ -216
FreeMem:	equ -210
Chip:		equ $02
Fast:		equ $04
Clear:		equ $10000
Public:		equ $01
Total		equ $80000
SetFunction:	equ -420
CloseWB:	equ -78
FindTask:	equ -294
AddPort:	equ -354
RemPort:	equ -360
OpenDev:	equ -444
CloseDev:	equ -450
DoIO:		equ -456
SendIO:		equ -462

;-------------> Intuition
OpenScreen:	equ -198
CloseScreen:	equ -66
ScreenToBack:	equ -$F6
OpenWindow:	equ -204
CloseWindow:	equ -72
LoadView:	equ -$DE
CUFLayer:	equ -36
DelLayer:	equ -90

;-------------> Graphic library
InitRastPort:	equ -198
InitTmpRas:	equ -$1d4
TextLength:	equ -54
Text:		equ -60
SetFont:	equ -66
OpenFont:	equ -72
CloseFont:	equ -78
AskSoftStyle:	equ -84
SetSoftStyle:	equ -90
RMove:		equ -240
RDraw:		equ -246
DrawEllipse:	equ -$b4
AreaEllipse:	equ -$ba
AreaMove:	equ -252
AreaDraw:	equ -258
AreaEnd:	equ -264
InitArea:	equ -282
RectFill:	equ -306
ReadPixel:	equ -318
WritePixel:	equ -324
Flood:		equ -330
PolyDraw:	equ -336
ScrollRaster:	equ -396
AskFont:	equ -474
AddFont:	equ -480
RemFont:	equ -486
ClipBlit:	equ -552
BltBitMap:	equ -30
SetAPen:	equ -342
SetBPen:	equ -348
SetDrMd:	equ -354
AvailFonts:	equ -$24
OpenDiskFont	equ -$1e

;-------------> Dos
Input:		equ -54
WaitChar:	equ -204
Read:		equ -42

Execall:	MACRO
		move.l	$4.w,a6
		jsr	\1(a6)
		ENDM
GfxCa5		MACRO
		movem.l	d0/d1/a0/a1/a6,-(sp)
		move.l	T_GfxBase(a5),a6
		jsr	\1(a6)
		movem.l	(sp)+,d0/d1/a0/a1/a6
		ENDM

*************** DOS
DosCall		MACRO
		move.l	a6,-(sp)
		move.l	DosBase(a5),a6
		jsr	\1(a6)
		move.l	(sp)+,a6
		ENDM
DosOpen:	equ -30
DosClose:	equ -36
DosRead:	equ -42
DosWrite:	equ -48
DosSeek:	equ -66
DosDel:		equ -72
DosRen:		equ -78
DosLock:	equ -84
DosUnLock:	equ -90
DosDupLock:	equ -96
DosExam:	equ -102
DosExNext:	equ -108
Dosinfo:	equ -114
DosMkDir:	equ -120
DosCuDir:	equ -126
DosIOErr:	equ -132
DosDProc:	equ -174
DosParent:	equ -210
DosLoadSeg:	equ -150
DosULoadSeg:	equ -156
DosWChar:	equ -204

*************** FLOAT
SPFix:		equ -30
SPFlt:		equ -36
SPCmp:		equ -42
SPTst:		equ -48
SPAbs:		equ -54
SPNeg:		equ -60
SPAdd:		equ -66
SPSub:		equ -72
SPMul:		equ -78
SPDiv:		equ -84
SPFloor:	equ -90
SPCeil:		equ -96

SPATan:		equ -30
SPSin:		equ -36
SPCos:		equ -42
SPTan:		equ -48
SPSinCos:	equ -54
SPSinH:		equ -60
SPCosH:		equ -66
SPTanH:		equ -72
SPExp:		equ -78
SPLog:		equ -84
SPPow:		equ -90
SPSqrt:		equ -96
SPTIeee:	equ -102
SPFIeee:	equ -108
SPASin:		equ -114
SPACos:		equ -120
SPLog10:	equ -126

*************** AMOS system library
Inkey:		equ 0
ClearKey:	equ 1
Shifts:		equ 2
Instant:	equ 3
KeyMap:		equ 4
Joy:		equ 5
PutKey:		equ 6
Hide:		equ 7
Show:		equ 8
ChangeM:	equ 9
XyMou:		equ 10
XyHard:		equ 11
XyScr:		equ 12
MouseKey:	equ 13
SetM:		equ 14
ScIn:		equ 15
XyWin:		equ 16
LimitM:		equ 17
ZoHd:		equ 18
ResZone:	equ 19
RazZone:	equ 20
SetZone:	equ 21
GetZone:	equ 22
WaitVbl:	equ 23
SetHs:		equ 24
USetHs:		equ 25
SetFunk:	equ 26
GetFunk:	equ 27
AffHs:		equ 28
SetSpBank:	equ 29
NXYAHs:		equ 30
XOffHs:		equ 31
OffHs:		equ 32
ActHs:		equ 33
SBufHs:		equ 34
StActHs:	equ 35
ReActHs:	equ 36
StoreM:		equ 37
RecallM:	equ 38
PriHs:		equ 39
AMALTok:	equ 40
AMALCre:	equ 41
AMALMvO:	equ 42
AMALDAll:	equ 43
AMAL:		equ 44
AMALReg:	equ 45
AMALClr:	equ 46
AMALFrz:	equ 47
AMALUFrz:	equ 48
SetBob:		equ 49
OffBob:		equ 50
OffBobS:	equ 51
ActBob:		equ 52
AffBob:		equ 53
EffBob:		equ 54
SyChip:		equ 55
SyFast:		equ 56
LimBob:		equ 57
ZoGr:		equ 58
SprGet:		equ 59
MaskMk:		equ 60
SpotHot:	equ 61
ColBob:		equ 62
ColGet:		equ 63
ColSpr:		equ 64
SetSync:	equ 65
Synchro:	equ 66
PlaySet:	equ 67
XYBob:		equ 68
XYSp:		equ 69
PutBob:		equ 70
Patch:		equ 71
MouRel:		equ 72
LimitMEc:	equ 73
SyFree:		equ 74
SetHCol:	equ 75
GetHCol:	equ 76
MovOn:		equ 77
KeySpeed:	equ 78
ChanA:		equ 79
ChanM:		equ 80
SPrio:		equ 81
GetDisc:	equ 82
RestartVBL	equ 83
StopVBL		equ 84
KeyWaiting	equ 85		(P) Une touche en attente?
MouScrFront	equ 86		(P) Souris dans ecran de front

SyCall:		MACRO
		move.l	T_SyVect(a5),a0
		jsr	\1*4(a0)
		ENDM
SyCalA:		MACRO
		lea	\2,a1
		move.l	T_SyVect(a5),a0
		jsr	\1*4(a0)
		ENDM
SyCalD:		MACRO
		moveq	#\2,d1
		move.l	T_SyVect(a5),a0
		jsr	\1*4(a0)
		ENDM
SyCal2:		MACRO
		moveq	#\2,d1
		move.l	#\3,a1
		move.l	T_SyVect(a5),a0
		jsr	\1*4(a0)
		ENDM

***********************************************************
*		EQUATES BOBS
		RsReset
BbPrev:		rs.l 1
BbNext:		rs.l 1
BbNb:		rs.w 1
BbAct:		rs.w 1
BbX:		rs.w 1
BbY:		rs.w 1
BbI:		rs.w 1
BbEc:		rs.l 1
BbAAEc:		rs.l 1
BbAData:	rs.l 1
BbAMask:	rs.l 1
BbNPlan:	rs.w 1
BbAPlan:	rs.w 1
BbASize:	rs.w 1
BbAMaskG:	rs.w 1
BbAMaskD:	rs.w 1
BbTPlan:	rs.w 1
BbTLigne:	rs.w 1
BbAModO:	rs.w 1
BbAModD:	rs.w 1
BbACon:		rs.w 1
BbACon0:	rs.w 1
BbACon1:	rs.w 1
BbADraw:	rs.l 1
BbLimG:		rs.w 1
BbLimD:		rs.w 1
BbLimH:		rs.w 1
BbLimB:		rs.w 1
* Datas retournement des bobs
BbARetour	rs.l 1
BbRetour	rs.w 1
* Datas decor
BbDecor:	rs.w 1
BbEff:		rs.w 1
BbDCur1:	rs.w 1
BbDCur2:	rs.w 1
BbDCpt:		rs.w 1
BbEMod:		rs.w 1
BbECpt:		rs.w 1
BbEAEc:		rs.w 1
BbESize:	rs.w 1
BbETPlan:	rs.w 1
* Datas pour une sauvegarde de decor
BbDABuf:	rs.l 1		* 0  Adresse buffer
BbDLBuf:	rs.w 1		* 4  Longueur buffer
BbDAEc:		rs.w 1		* 6  Decalage ecran
BbDAPlan:	rs.l 1		* 8  Plans sauves
BbDNPlan:	rs.l 1		* 12 Max plans
BbDMod:		rs.w 1		* 16 Modulo ecran
BbDASize:	rs.w 1		* 18 Taille blitter
Decor:		equ 20		* 20 Taille totale
* Datas pour seconde sauvegarde!
		rs.l Decor
BbLong:		equ __RS


*************** AMOS Screen library

BitHide:	equ 7
BitClone:	equ 6
BitDble:	equ 5
EcMaxPlans	equ		6		;6 Plans pour le moment!

		RsReset
* Bitmap address
EcLogic:	rs.l 6		* 
EcPhysic	rs.l 6		* 
EcCurrent:	rs.l 6		* 

* Datas!
EcCon0:		rs.w 1		* 
EcCon2:		rs.w 1		* 
EcTx:		rs.w 1		* 
EcTy:		rs.w 1		* 
EcNPlan:	rs.w 1		* 
EcWX:		rs.w 1		* 
EcWY:		rs.w 1		* 
EcWTx:		rs.w 1		* 
EcWTy:		rs.w 1		* 
EcVX:		rs.w 1		* 
EcVY:		rs.w 1		* 

EcDEcran:	rs.l 1		* 
EcColorMap	rs.w 1
EcNbCol		rs.w 1
EcPal		rs.w 32

EcTPlan:	rs.l 1		* 
EcWindow:	rs.l 1		* 
EcTxM:		rs.w 1		* 
EcTyM:		rs.w 1		* 
EcTLigne:	rs.w 1		* 
EcFlags:	rs.w 1		* 
EcDual:		rs.w 1		* 
EcWXr:		rs.w 1		* 
EcWTxr:		rs.w 1		* 
EcNumber:	rs.w 1		* 
EcAuto:		rs.w 1		* 

* Link with AMAL
EcAW:		rs.w 1
EcAWX:		rs.w 1
EcAWY:		rs.w 1
EcAWT:		rs.w 1
EcAWTX:		rs.w 1
EcAWTY:		rs.w 1
EcAV:		rs.w 1
EcAVX:		rs.w 1
EcAVY:		rs.w 1
* Zone table
EcAZones:	rs.l 1
EcNZones:	rs.w 1
* Save the backgrountd for window
EcWiDec:	rs.w 1
* Graphic functions
EcInkA:		rs.b 1
EcInkB:		rs.b 1
EcMode:		rs.b 1
EcOutL:		rs.b 1
EcLine:		rs.w 1
EcCont:		rs.w 1
EcX:		rs.w 1
EcY:		rs.w 1
EcPat:		rs.l 1
EcPatL:		rs.w 1
EcPatY:		rs.w 1
EcClipX0:	rs.w 1
EcClipY0:	rs.w 1
EcClipX1:	rs.w 1
EcClipY1:	rs.w 1
EcFontFlag:	rs.w 1
EcText:		rs.b 14 
EcFInkA:	rs.b 1
EcFInkB:	rs.b 1
EcFInkC:	rs.b 1
EcIInkA:	rs.b 1
EcIInkB:	rs.b 1
EcIInkC:	rs.b 1
EcFPat:		rs.w 1
EcIPat:		rs.w 1
* Cursor saving
EcCurS:		rs.b 8*6
; Length of a screen
EcLong:		equ __RS

; Y Screen base
EcYBase:	equ $1000
EcYStrt:	equ EcYBase+26
PalMax:		equ 16

***********************************************************
*		FUNCTIONS
***********************************************************

Raz:		equ 0
CopMake:	equ 1
*		equ 2
Cree:		equ 3
Del:		equ 4
First:		equ 5
Last:		equ 6
Active:		equ 7
CopForce:	equ 8
AView:		equ 9
OffSet:		equ 10
Visible:	equ 11
DelAll:		equ 12
GCol:		equ 13
SCol:		equ 14
SPal:		equ 15
SColB:		equ 16
FlRaz:		equ 17
Flash:		equ 18
ShRaz:		equ 19
Shift:		equ 20
EHide:		equ 21
CBlGet:		equ 22
CBlPut:		equ 23
CBlDel:		equ 24
CBlRaz:		equ 25
Libre:		equ 26
CCloEc:		equ 27
Current:	equ 28
Double:		equ 29
SwapSc:		equ 30
SwapScS:	equ 31
AdrEc:		equ 32
SetDual:	equ 33
PriDual:	equ 34
ClsEc:		equ 35
Pattern:	equ 36
GFonts:		equ 37
FFonts:		equ 38
GFont:		equ 39
SFont:		equ 40
SetClip:	equ 41
BlGet:		equ 42
BlDel:		equ 43
BlRaz:		equ 44
BlPut:		equ 45
VerSli:		equ 46
HorSli:		equ 47
SetSli:		equ 48
MnStart:	equ 49
MnStop:		equ 50
RainDel:	equ 51
RainSet:	equ 52
RainDo:		equ 53
RainHide:	equ 54
RainVar:	equ 55
FadeOn:		equ 56
FadeOf:		equ 57
CopOnOff:	equ 58
CopReset:	equ 59
CopSwap:	equ 60
CopWait:	equ 61
CopMove:	equ 62
CopMoveL:	equ 63
CopBase:	equ 64
AutoBack1:	equ 65
AutoBack2:	equ 66
AutoBack3:	equ 67
AutoBack4:	equ 68
SuPaint:	equ 69
BlRev:		equ 70
DoRev:		equ 71
AMOS_WB		equ 72
ScCpyW		equ 73
MaxRaw		equ 74
AMOS_NTSC	equ 75

EcCall:		MACRO
		move.l	T_EcVect(a5),a0
		jsr	\1*4(a0)
		ENDM
EcCalA:		MACRO
		lea	\2,a1
		move.l	T_EcVect(a5),a0
		jsr	\1*4(a0)
		ENDM
EcCalD:		MACRO
		moveq	#\2,d1
		move.l	T_EcVect(a5),a0
		jsr	\1*4(a0)
		ENDM
EcCal2:		MACRO
		moveq	#\2,d1
		move.l	#\3,a1
		move.l	T_EcVect(a5),a0
		jsr	\1*4(a0)
		ENDM

*************** AMOS Window library

* Window structure
WiPrev:		equ 0		
WiNext:		equ WiPrev+4	
WiFont:		equ WiNext+4	
WiAdhg:		equ WiFont+4
WiAdhgR:	equ WiAdhg+4
WiAdhgI:	equ WiAdhgR+4
WiAdCur:	equ WiAdhgI+4
WiColor:	equ WiAdCur+4
WiColFl:	equ WiColor+4*6

WiX:		equ WiColFl+4*6
WiY:		equ WiX+2
WiTx:		equ WiY+2
WiTy:		equ WiTx+2
WiTyCar:	equ WiTy+2
WiTLigne:	equ WiTyCar+2
WiTxR:		equ WiTLigne+2
WiTyR:		equ WiTxR+2
WiDxI:		equ WiTyR+2
WiDyI:		equ WiDxI+2
WiTxI:		equ WiDyI+2
WiTyI:		equ WiTxI+2
WiDxR:		equ WiTyI+2
WiDyR:		equ WiDxR+2
WiFxR:		equ WiDyR+2
WiFyR:		equ WiFxR+2
WiTyP:		equ WiFyR+2
WiDBuf:		equ WiTyP+2
WiTBuf:		equ WiDBuf+4
WiTxBuf:	equ WiTBuf+4

WiPaper:	equ WiTxBuf+2
WiPen:		equ WiPaper+2
WiBorder:	equ WiPen+2
WiFlags:	equ WiBorder+2
WiGraph:	equ WiFlags+2
WiNPlan:	equ WiGraph+2
WiNumber:	equ WiNPlan+2
WiSys:		equ WiNumber+2
WiEsc:		equ WiSys+2
WiEscPar:	equ WiEsc+2
WiTab:		equ WiEscPar+2

WiBord:		equ WiTab+2
WiBorPap:	equ WiBord+2
WiBorPen:	equ WiBorPap+2

WiMx:		equ WiBorPen+2
WiMy:		equ WiMx+2
WiZoDx:		equ WiMy+2
WiZoDy:		equ WiZoDx+2

WiCuDraw:	equ WiZoDy+2
WiCuCol:	equ WiCuDraw+8

WiTitH:		equ WiCuCol+2
WiTitB:		equ WiTitH+80
WiLong:		equ WiTitB+80
WiSAuto:	equ WiTitH

***********************************************************
*		WINDOW INSTRUCTIONS 
***********************************************************
ChrOut:		equ 0
Print:		equ 1
Centre:		equ 2
WindOp:		equ 3
Locate:		equ 4
QWindow:	equ 5
WinDel:		equ 6
SBord:		equ 7
STitle:		equ 8
GAdr:		equ 9
MoveWi:		equ 10
ClsWi:		equ 11
SizeWi:		equ 12
SCurWi:		equ 13
XYCuWi:		equ 14
XGrWi:		equ 15
YGrWi:		equ 16
Print2		equ 17
Print3		equ 18
SXSYCuWi	equ 19
	
WiCall:		MACRO
		move.l	T_WiVect(a5),a0
		jsr	\1*4(a0)
		ENDM
WiCalA:		MACRO
		lea	\2,a1
		move.l	T_WiVect(a5),a0
		jsr	\1*4(a0)
		ENDM
WiCalD:		MACRO
		moveq	#\2,d1
		move.l	T_WiVect(a5),a0
		jsr	\1*4(a0)
		ENDM
WiCal2:		MACRO
		moveq	#\2,d1
		move.l	#\3,a1
		move.l	T_WiVect(a5),a0
		jsr	\1*4(a0)
		ENDM

**************	Equates basic
EcFonc:		equ 8
EcEdit:		equ 9
EcFsel:		equ 10
EcReq:		equ 11

EdTx:		equ 78

EdBTT:		equ 512+256
NbEnd:		equ 10
EcEBase		equ 45
DEBase		equ EcEBase+35-1
SpEBase 	equ DEBase+25
FkLong:		equ 26
Shf:		equ %00000011
Ctr:		equ %00001000
Alt:		equ %00110000
Ami:		equ %11000000

***************	Menu definition
		RsReset
MnPrev:		rs.l 	1
MnNext:		rs.l 	1
MnLat:		rs.l	1
MnNb:		rs.w	1
MnFlag:		rs.w	1
MnX:		rs.w	1
MnY:		rs.w	1
MnTx:		rs.w	1
MnTy:		rs.w	1
MnMX:		rs.w	1
MnMY:		rs.w	1
MnXX:		rs.w	1
MnYY:		rs.w	1
MnZone:		rs.w	1
MnKFlag:	rs.b	1
MnKAsc:		rs.b	1
MnKSc:		rs.b 	1
MnKSh:		rs.b	1
* Menu objects
MnObF:		rs.l	1
MnOb1:		rs.l	1
MnOb2:		rs.l	1
MnOb3:		rs.l	1
MnAdSave:	rs.l	1
MnDatas:	rs.l	1
MnLData:	rs.w 	1
MnInkA1:	rs.b	1
MnInkB1:	rs.b	1
MnInkC1:	rs.b	1
MnInkA2:	rs.b	1
MnInkB2:	rs.b	1
MnInkC2:	rs.b	1
MnLong:		equ __RS

* Flags
MnFlat:		equ 	0
MnFixed:	equ 	1
MnSep:		equ 	2
MnBar:		equ 	3
MnOff:		equ 	4
MnTotal:	equ 	5
MnTBouge:	equ 	6
MnBouge:	equ 	7

*************** Test control bits 
BitControl:	equ 	8
BitMenu:	equ 	9
BitJump:	equ 	10
BitEvery:	equ 	11
BitEcrans:	equ 	12
BitBobs:	equ 	13
BitSprites:	equ 	14
BitVBL:		equ 	15

; __________________________________
;
; 	Definition d'un slider
; __________________________________
;
Sl_FlagVertical	equ 	0
		RsReset
; Variables positionnement
Sl_Sx		rs.w	1
Sl_Sy		rs.w	1
Sl_Global	rs.w	1
Sl_Position	rs.w	1
Sl_Window	rs.w	1
Sl_X		rs.w	1
Sl_Y		rs.w	1
Sl_ZDx		rs.w	1
Sl_ZDy		rs.w	1
; Variables fonctionnement
Sl_Flags	rs.w	1
Sl_Start	rs.w	1
Sl_Size		rs.w	1
Sl_Scroll	rs.w	1
Sl_Mouse1	rs.w	1
Sl_Mouse2	rs.w	1
Sl_Zone		rs.w	1
Sl_Routines	rs.l	1
; Encres
Sl_Inactive	rs.w	3+3+2
Sl_Active	rs.w	3+3+2
Sl_Long		equ	__RS
; __________________________________
;
; 	Definition d'un bouton
; __________________________________
;
Bt_FlagNew	equ	0
Bt_FlagNoWait	equ	1
Bt_FlagOnOf	equ	2
		RsReset
Bt_Number	rs.w	1
Bt_X		rs.w	1
Bt_Y		rs.w	1
Bt_Image	rs.w	1
Bt_Zone		rs.w	1
Bt_Pos		rs.w	1
Bt_Routines	rs.l	1
Bt_Dx		rs.b	1
Bt_Dy		rs.b	1
Bt_Sx		rs.b	1
Bt_Sy		rs.b	1
Bt_RDraw	rs.b	1
Bt_RChange	rs.b	1
Bt_RPos		rs.b	1
Bt_Flags	rs.b	1
Bt_Long		equ	__RS

; ___________________________________
;
; 	BITMAP PACKER/UNPACKER
; ___________________________________

; Packed screen header
		RsReset
PsCode		rs.l 1
PsTx		rs.w 1
PsTy		rs.w 1
PsAWx		rs.w 1
PsAWy		rs.w 1
PsAWTx		rs.w 1
PsAWTy		rs.w 1
PsAVx		rs.w 1
PsAVy		rs.w 1
PsCon0		rs.w 1
PsNbCol		rs.w 1
PsNPlan		rs.w 1
PsPal		rs.w 32
PsLong		equ __RS
SCCode		equ $12031990
; Packed bitmap header
; ~~~~~~~~~~~~~~~~~~~~
		RsReset
Pkcode   	rs.l 1
Pkdx     	rs.w 1
Pkdy     	rs.w 1
Pktx     	rs.w 1
Pkty     	rs.w 1
Pktcar   	rs.w 1
Pknplan		rs.w 1
PkDatas2 	rs.l 1
PkPoint2 	rs.l 1
PkLong  	equ __RS
PkDatas1	equ __RS
BMCode		equ $06071963

; ______________________________________________________________________________
;
;		EDITEUR LIGNE
;
		RsReset
LEd_Buffer	rs.l	1
LEd_Start	rs.w	1
LEd_Large	rs.w	1
LEd_Max		rs.w	1
LEd_Long	rs.w	1
LEd_Cur		rs.w	1
LEd_X		rs.w	1
LEd_Y		rs.w	1
LEd_Screen	rs.w	1
LEd_Flags	rs.w	1
LEd_Mask	rs.l	3
LEd_Size	equ	__RS
LEd_FKeys	equ	0
LEd_FOnce	equ	1
LEd_FCursor	equ	2
LEd_FFilter	equ	3
LEd_FMouse	equ	4
LEd_FTests	equ	5
LEd_FMulti	equ	6
LEd_FMouCur	equ	7

; _____________________________________________________________________________
; 
; 	GESTION DES DIALOGUES
; 

; __________________________________________
;
;	Base de la zone de dialogue
;
		RsReset
Dia_Channel	rs.l	1
Dia_NVar	rs.l	1
Dia_Sp		rs.l	1
Dia_Screen	rs.l	1
Dia_ScreenNb	rs.w	1
Dia_ScreenOld	rs.w	1
Dia_WindOld	rs.w	1
Dia_WindOn	rs.w	1
Dia_Programs	rs.l	1
Dia_ProgLong	rs.l	1
Dia_Labels	rs.l	1
Dia_Messages	rs.l	1
Dia_ABuffer	rs.l	1
Dia_PBuffer	rs.l	1
Dia_Buffer	rs.l	1
Dia_Pile	rs.l	1
Dia_PUsers	rs.l	1
Dia_NPUsers	rs.w	1
Dia_Users	rs.w	1
Dia_Edited	rs.l	1
Dia_Timer	rs.l	1
Dia_TimerPos	rs.l	1
Dia_LastZone	rs.l	1
Dia_NextZone	rs.l	1
Dia_Release	rs.l	1
Dia_BaseX	rs.l	1
Dia_BaseY	rs.l	1
Dia_Sx		rs.l	1
Dia_Sy		rs.l	1
Dia_XA		rs.w	1
Dia_YA		rs.w	1
Dia_XB		rs.w	1
Dia_YB		rs.w	1
Dia_Puzzle	rs.l	1
Dia_PuzzleSx	rs.l	1
Dia_PuzzleSy	rs.l	1
Dia_PuzzleI	rs.l	1
Dia_LastKey	rs.l	1
Dia_Error	rs.w	1
Dia_ErrorPos	rs.w	1
Dia_Return	rs.w	1
Dia_Exit	rs.w	1
Dia_Writing	rs.w	1
Dia_RFlags	rs.b	1
Dia_Flags	rs.b	1
Dia_SlDefault	rs.b	16
		rs.l	4
Dia_Vars	equ	__RS
Dia_Source	equ	Dia_LastKey
Dia_FSource	equ	Dia_Edited

; Entete d'une zone active
; ~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
Dia_Ln		rs.w	1		;0 Long
Dia_Id		rs.w	1		;2 Id
Dia_ZoId	rs.w	1		;4 ZoId
Dia_ZoX		rs.w	1		;6 ZoX
Dia_ZoY		rs.w	1		;8 ZoY
Dia_ZoSx	rs.w	1		;10 ZoSx
Dia_ZoSy	rs.w	1		;12 ZoSy
Dia_ZoNumber	rs.w	1		;14 ZoNumber
Dia_ZoRChange	rs.w	1		;16 Routine change
Dia_ZoPos	rs.l	1		;18 Position
Dia_ZoVar	rs.l	1		;22 Variable interne
Dia_ZoFlags	rs.b	1		;26
		rs.b	1
Dia_ZoLong	equ	__RS
; Entete d'un bouton dialogue
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
		rs.b	Dia_ZoLong	;Entete zone active
Dia_BtRDraw	rs.w	1
Dia_BtRChange	rs.w	1
Dia_BtMin	rs.w	1
Dia_BtMax	rs.w	1
Dia_BtLong	equ	__RS
; Entete d'une ligne d'edition
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
		rs.b	Dia_ZoLong	;Entete zone active
Dia_LEd		rs.b	LEd_Size
Dia_EdLong	equ	__RS
Dia_DiValue	rs.l	1
Dia_DiBuffer	rs.b	16
Dia_DiLong	equ	__RS
; Entete d'une liste active
; ~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
		rs.b	Dia_ZoLong	;Entete zone active
Dia_LiTx	rs.w	1
Dia_LiTy	rs.w	1
Dia_LiPos	rs.w	1
Dia_LiMaxAct	rs.w	1
Dia_LiArray	rs.l	1
Dia_LiLArray	rs.w	1
Dia_LiActNumber	rs.w	1
Dia_LiLong	equ	__RS
; Entete d'un texte actif
; ~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
		rs.b	Dia_ZoLong	;Entete zone active
Dia_TxTx	rs.w	1
Dia_TxTy	rs.w	1
Dia_TxPos	rs.w	1
Dia_TxNLine	rs.w	1
Dia_TxText	rs.l	1
Dia_TxDisplay	rs.l	1
Dia_TxDispSize	rs.w	1
Dia_TxDispMax	rs.w	1
Dia_TxAdress	rs.l	1
Dia_TxAct	rs.l	1
Dia_TxYAct	rs.w	1
Dia_TxPen	rs.b	1
Dia_TxPaper	rs.b	1
Dia_TxPp	rs.b	8
Dia_TxBuffer	rs.b	64
Dia_TxBufferEnd	equ	__RS
Dia_TxLong	equ	__RS
; Definition des zones actives
Dia_TxDispZone	equ	8

; Entete d'un slider
; ~~~~~~~~~~~~~~~~~~
		RsReset
		rs.b	Dia_ZoLong	;Entete zone active
Dia_Sl		rs.b	Sl_Long		;Données gestion slider
Dia_SlLong	equ	__RS
; Entete d'une definition de touche
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
		rs.w	2
Dia_KyCode	rs.b	1
Dia_KyShift	rs.b	1
Dia_KyZone	rs.l	1
Dia_KyLong	equ	__RS
; Entete d'une sauvegarde de block
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RsReset
		rs.w	2
Dia_BlNumber	rs.w	1
Dia_BlLong	equ	__RS
; Marques de reconnaissance
; ~~~~~~~~~~~~~~~~~~~~~~~~~
Dia_BtMark	equ	"Bt"
Dia_StMark	equ	"St"
Dia_EdMark	equ	"Ed"
Dia_KyMark	equ	"Ky"
Dia_BlMark	equ	"Bl"
Dia_ZoMark	equ	"Zo"
Dia_SlMark	equ	"Sl"
Dia_LiMark	equ	"Li"
Dia_TxMark	equ	"Tx"
Dia_TaMark	equ	"Ta"
Dia_TdMark	equ	"Td"
; Numero des messages d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EDia_Syntax	equ	1
EDia_OMem	equ	2
EDia_LabAD	equ	3
EDia_LabND	equ	4
EDia_ChanAD	equ	5
EDia_ChanND	equ	6
EDia_Screen	equ	7
EDia_VarND	equ	8
EDia_FCall	equ	9
EDia_Type	equ	10
EDia_OBuffer	equ	11
EDia_NPar	equ	12

***************************************************************
*		Interpretor datas zone
*		Pointed to by A5
***************************************************************

		RsReset

;		VBL Routines
; ~~~~~~~~~~~~~~~~~~~~~~~~~~ 
VblRout:	rs.l 	8

;		Extensions
; ~~~~~~~~~~~~~~~~~~~~~~~~
AdTokens:	rs.l 	27		
AdTTokens:	rs.l 	27
ExtAdr:		rs.l 	26*4
ExtTests:	rs.l 	8

; 		Adresses Kickstart
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DosBase:	rs.l 	1
DFloatBase	rs.l	1
DMathBase	rs.l	1
FloatBase:	rs.l	1
MathBase:	rs.l 	1
IconBase:	rs.l 	1

; 		Données systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sys_AData	rs.l	1
Sys_LData	rs.l	1
Sys_Message	rs.l	1
Sys_WAd		rs.l	1
Sys_WSegment	rs.l	1
Sys_Messages	rs.l	1
Sys_Banks	rs.l	1
Sys_Stopped	rs.l	1
Sys_MyTask	rs.l	1
Sys_OldName	rs.l	1
Sys_Editor	rs.l	1
Sys_Monitor	rs.l	1
Sys_Resource	rs.l	1
Sys_WStarted	rs.b	1
		rs.b	1
Sys_Pathname	rs.b	80

Mon_Base	rs.l	1
Prg_List	rs.l	1
Prg_Runned	rs.l	1

;		Graphics
; ~~~~~~~~~~~~~~~~~~~~~~
AAreaSize:	equ 	16
AAreaInfo:	rs.b 	24
AAreaBuf:	rs.b 	AAreaSize*5+10
		rs.b 	16
ATmpRas:	rs.l 	2
AppNPlan	rs.w 	1
SccEcO:		rs.l 	1
SccEcD:		rs.l 	1

;		File selector
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
FsAdEc:		rs.l 1
FsOldEc		rs.w 1
FsFlag:		rs.w 1
FsActive:	rs.w 1
FsPosF:		rs.w 1
FsIFlag:	rs.w 1
FsLPath:	rs.w 1
FsLPath1:	rs.w 1
FsCPath:	rs.w 1
FsLNom:		rs.w 1
FsCNom:		rs.w 1
FsWiAct:	rs.w 1
FsSp:		rs.l 1
WB2.0:		rs.w 1
Fs_Base		rs.l	1
Fs_Saved	rs.l	1
Fs_SaveList	rs.l	1
		rs.b	1
FillFSorted	rs.b	1

;		Editor
; ~~~~~~~~~~~~~~~~~~~~
BasSp:		rs.l 	1	
		rs.w 	1		
ColBack:	rs.w 	1
DefFlag:	rs.w 	1	

;		Float
; ~~~~~~~~~~~~~~~~~~~
BuFloat:	rs.b 	64
DeFloat:	rs.b 	32
TempFl:		rs.l 	1
TempBuf:	rs.l 	1
ValPi:		rs.l 	1
Val180:		rs.l 	1

;		Disque I/O
; ~~~~~~~~~~~~~~~~~~~~~~~~
IffParam:	rs.l 	1
IffFlag:	rs.l 	1
IffReturn	rs.l 	1
BufFillF:	rs.l 	1
FillFLong:	rs.w 	1
FillFSize:	rs.w 	1
FillFNb:	rs.w 	1
FillF32:	rs.w 	1
DirLong:	rs.l 	1
DirComp:	rs.w 	1
DirLNom:	rs.w 	1	
PathAct:	rs.l 	1
DirFNeg:	rs.l 	1	
BufBMHD:	rs.l 	1
BufCMAP:	rs.l 	1
BufCAMG:	rs.l 	1
BufCCRT:	rs.l 	1
BufAMSC:	rs.l 	1

; 		Tokenisation / Stockage
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TkAd:		rs.l 	1	
TkChCar:	rs.w 	1	
VerPos:		rs.l 	1	
VerBase:	rs.l 	1	
VerNInst	rs.l	1
VerNot1.3	rs.b	1
VerCheck1.3	rs.b	1
Parenth:	rs.w 	1	
WBench		rs.b	1
WB_Closed	rs.b	1

TBuffer:	equ 	1024	
TMenage:	equ 	160*10-64
Buffer:		rs.l 	1	
BMenage:	rs.l 	1

LimSave:	rs.w 	4
FsLimSave:	rs.w 	4
Name1:		rs.l 	1	
Name2:		rs.l 	1

Access:		rs.l 	1		
AcLdTemp:	rs.l 	1
AccFlag:	rs.w 	1

RasAd:		rs.l 	1		
RasLong:	rs.l 	1
RasSize:	rs.w 	1
RasLock:	rs.l 	1
ScOn:		rs.w 	1
ScOnAd:		rs.l 	1
BufBob:		rs.l 	1
BufLabel:	rs.l 	1
LMouse:		rs.l 	1
VBLOCount:	rs.w 	1
VBLDelai:	rs.w 	1
SScan:		rs.w 	1
Seed:		rs.l 	1
OldRnd:		rs.l 	1
PAmalE:		rs.w 	1
ReqSave:	rs.l 	1
ReqSSave:	rs.l 	1
SNoFlip:	rs.w 	1
LockSave:	rs.l 	1
Handle:		rs.l 	1
PrtHandle:	rs.l 	1
PosFillF:	rs.w 	1
TempBuffer	rs.l 	1

;		Canaux d'animation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AnCanaux:	rs.w 64
InterOff:	rs.w 1

; ____________________________________________________________________________
;
;							VARIABLES RUN-TIME
; ____________________________________________________________________________
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;					Debut de la zone poussee par PRUN
;
DebSave:	equ __RS

;		Adresse de la liste de Banques/Dialogues
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cur_Banks	rs.l 	1
Cur_Dialogs	rs.l	1
Cur_ChrJump	rs.l	1

; 		Donnnes du programme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Stack_ProcSize	equ	42
Stack_Size	rs.w 	1
Stack_CSize	rs.w 	1
Prg_Source	rs.l 	1
Prg_FullSource	rs.l	1
Prg_Includes	rs.l	1
Prg_Run		rs.l	1
Prg_Test	rs.l	1
Prg_JError	rs.l	1
Prg_ChrGet	rs.l	1

; 		Verification / Buffers
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Passe:		rs.w 1
VarBuf:		rs.l 1		
VarBufL:	rs.l 1		
VarBufFlg:	rs.w 1		
LabHaut:	rs.l 1		
LabBas:		rs.l 1
LabMini:	rs.l 1
DVNmBas:	rs.l 1		
DVNmHaut:	rs.l 1
VNmLong:	rs.l 1
VNmHaut:	rs.l 1
VNmBas:		rs.l 1
VNmMini:	rs.l 1
VDLigne:	rs.l 1
BaTablA:	rs.l 1		
HoTablA:	rs.l 1
VarLong:	rs.w 1
GloLong:	rs.w 1
VarGlo:		rs.l 1
VarLoc:		rs.l 1
TabBas:		rs.l 1
ChVide:		rs.l 1
LoChaine:	rs.l 1		
HiChaine:	rs.l 1		
HoLoop:		rs.l 1
BaLoop:		rs.l 1

;		Donnees RUN
; ~~~~~~~~~~~~~~~~~~~~~~~~~
PLoop:		rs.l 1
MinLoop:	rs.l 1
BasA3:		rs.l 1
ErrRet:		rs.l 1		
ErrRAd:		rs.l 1
Phase:		rs.w 1
DTablA:		rs.l 1
CurTablA:	rs.l 1
PDebug:		rs.l 1
		rs.b 1
		rs.b 1
ActuMask:	rs.w 1		
IffMask:	rs.l 1
ExpFlg:		rs.w 1
FixFlg:		rs.w 1

; 		DEVICES / LIBRARIES
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Dev_Max		equ	7
Dev_List	rs.b	12*Dev_Max
Lib_Max		equ	7
Lib_List	rs.l	4*Lib_Max

; 		MENUS
; ~~~~~~~~~~~~~~~~~~~
MnNDim:		equ 8
Mn_SSave	equ	__RS		;Debut du flip de l'editeur
MnBase:		rs.l 	1		;~~~~~~~~~~~~~~~~~~~~~~~~~~
MnBaseX:	rs.w 	1
MnBaseY:	rs.w 	1
MnChange:	rs.w 	1
MnMouse:	rs.w 	1
MnError:	rs.w 	1
MnAdEc:		rs.l 	1
MnScOn:		rs.w 	1
MgFlags:	rs.w 	1
MnNZone:	rs.w 	1
MnZoAct:	rs.w	1
MnAct:		rs.l	1
MnTDraw:	rs.l	1
MnTable:	rs.l 	MnNDim+1
MnChoix:	rs.w 	MnNDim
MnDFlags:	rs.b 	MnNDim
MnDAd:		rs.l 	1
MnProc:		rs.w 	1
Mn_ESave	equ	__RS		;Fin du flip editeur
MnRA3:		rs.l 	1		;~~~~~~~~~~~~~~~~~~~
MnRA4:		rs.l 	1
MnPile:		rs.l 	1
OMnBase:	rs.l 	1
OMnNb:		rs.w 	1
OMnType:	rs.w	1

;		Def Scroll
; ~~~~~~~~~~~~~~~~~~~~~~~~
DScrolls:	rs.w 6*16

; 		Dialogues
; ~~~~~~~~~~~~~~~~~~~~~~~
IDia_BankPuzzle	rs.l	1
IDia_Error	rs.l	1

;		Patch monitor
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Patch_ScCopy	rs.l	1
Patch_ScFront	rs.l	1
Patch_Errors	rs.l	1
Patch_Menage	rs.l	1
Mon_Here	rs.b	1
		rs.b	1

; 		Fichiers
; ~~~~~~~~~~~~~~~~~~~~~~
FhA:		equ 0
FhT:		equ 4
FhF:		equ 6
TFiche:		equ 10
NFiche:		equ 10
ChrInp:		rs.w 1
Fichiers:	rs.b TFiche*NFiche

; 		AREXX
; ~~~~~~~~~~~~~~~~~~~
Arx_Port	rs.l	1
Arx_Base	rs.l	1
Arx_Answer	rs.l	1
Arx_PortName	rs.b	32

;		Every
; ~~~~~~~~~~~~~~~~~~~
EveType:	rs.w 	1
EveLabel:	rs.l 	1
EveCharge:	rs.w 	1

;		Miscellenous
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
BuffSize:	rs.l 	1
AdrIcon:	rs.l 	1
DefPal:		rs.w 	32
DBugge		rs.l 	1
CallAd:		rs.l 	1

; 		Données télécommande
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Prg_Accessory	rs.b	1 
Ed_Zappeuse	rs.b	1

;		Variables mises à zero par un RUN 
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DebRaz:		equ 	__RS
PrintFlg:	rs.w 	1
PrintPos:	rs.l 	1
PrinType:	rs.w 	1
PrintFile:	rs.l 	1
UsingFlg:	rs.w 	1
ImpFlg:		rs.w 	1
ParamE:		rs.l 	1
ParamF:		rs.l 	1
ParamC:		rs.l 	1
InputFlg:	rs.w 	1
ContFlg:	rs.w 	1
ContChr:	rs.l 	1
ErrorOn:	rs.w 	1
ErrorChr:	rs.l 	1
OnErrLine:	rs.l 	1
TrapAdr		rs.l	1
TrapErr		rs.w	1
TVMax:		rs.w 	1
DProc:		rs.l 	1
AData:		rs.l 	1
PData:		rs.l 	1
MenA4:		rs.l 	1
LockOld:	rs.l 	1
MnChoice:	rs.w 	1
Angle:		rs.w 	1
DMathFlag:	rs.b	1
Ed_YaUTest	rs.b	1
CallReg:	rs.l 	8+7
FinRaz:		equ 	__RS
FinSave:	equ 	__RS
;		Fin de la zone pousse par PRUN
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;             	Données de Configuration Interpréteur
;
PI_Start	equ	__RS
; Initialisation de la trappe
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
PI_ParaTrap	rs.l	1		;0 - Adresse actualisation
PI_AdMouse	rs.l	1		;4 - Adresse souris
		rs.w	1		;8 - Nombre de bobs
		rs.w	1		;10- Position par defaut ecran!!
		rs.l	1		;12- Taille liste copper
		rs.l	1		;16- Nombre lignes sprites
; Taille des buffers 
; ~~~~~~~~~~~~~~~~~~
PI_VNmMax	rs.l	1		;20- Buffer des noms de variable
PI_TVDirect	rs.w	1		;24- Variables mode direct
PI_DefSize	rs.l	1		;26- Taille buffer par defaut
; Directory
; ~~~~~~~~~
PI_DirSize	rs.w	1		;30- Taille nom directory
PI_DirMax	rs.w	1		;32- Nombre max de noms
; Faire carriage return lors de PRINT?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PI_PrtRet	rs.b	1		;34- Return lors de 10
; Faire des icones?
; ~~~~~~~~~~~~~~~~~
PI_Icons	rs.b	1		;35- Faire de icones
; Autoclose workbench?
; ~~~~~~~~~~~~~~~~~~~~
PI_AutoWB	rs.b	1		;36- Fermer automatiquement
PI_AllowWB	rs.b	1		;37- Close Workbench effective?
; Close editor?
; ~~~~~~~~~~~~~~~~~~~~
PI_CloseEd	rs.b	1		;38- Autoriser fermeture
PI_KillEd	rs.b	1		;39- Autoriser fermeture
PI_FsSort	rs.b	1		;40- Sort files
PI_FsSize	rs.b	1		;41- Size of files
PI_FsStore	rs.b	1		;42- Store directories
; Securite flags
; ~~~~~~~~~~~~~~
		rs.b	1		;43- Flag libre
		rs.b	4		;44- 4 flags libres!
; Text reader
; ~~~~~~~~~~~
PI_RtSx		rs.w	1		;48- Taille X ecran Readtext
PI_RtSy		rs.w	1		;50- Taille Y ecran Readtext
PI_RtWx		rs.w	1		;52- Position X
PI_RtWy		rs.w	1		;54- Position Y
PI_RtSpeed	rs.w	1		;56- Vitesse apparition
; File selector
; ~~~~~~~~~~~~
PI_FsDSx	rs.w	1		;58- Taille X fsel
PI_FsDSy	rs.w	1		;60- Taille Y fsel
PI_FsDWx	rs.w	1		;62- Position X
PI_FsDWy	rs.w	1		;64- Position Y
PI_FsDVApp	rs.w	1		;66- Vitesse app
; Ecran par defaut
; ~~~~~~~~~~~~~~~~
PI_DefETx	rs.w	1
PI_DefETy	rs.w	1
PI_DefECo	rs.w	1
PI_DefECoN	rs.w	1
PI_DefEMo	rs.w	1
PI_DefEBa	rs.w	1
PI_DefEPa	rs.w	32
		rs.l	8		;Pour extension!
;
;		Fin de la zone configuration interpreteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; __________________________
;
; 		Mode Escape
; __________________________
;
Esc_TFonc	rs.l 	1
Esc_Buf		rs.l 	1		
Esc_KMem	rs.l	1
Esc_KMemPos	rs.l	1
Direct		rs.w 	1
DirFlag		rs.w 	1
EsFlag		rs.w 	1
Es_LEd		rs.b	LEd_Size
; _______________________
;
; 		Editeur
; _______________________
;

; Pointeurs sur zones de chaines
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_ConfigHead	equ	"ApCf"
Ed_QuitHead	equ	"ApLC"

; Adresse des elements de configuration
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_Config	rs.l	1
Ed_Systeme	rs.l	1		;Ne pas changer l'ordre
EdM_Messages	rs.l	1
Ed_Messages	rs.l	1
Ed_TstMessages	rs.l	1
Ed_RunMessages	rs.l	1
Ed_MnPrograms	rs.l	1
EdM_User	rs.l	1
EdM_Definition	rs.l	1


; Données normales
; ~~~~~~~~~~~~~~~~
Ed_Banks	rs.l	1
Ed_Dialogs	rs.l	1

Edt_List	rs.l	1
Edt_Current	rs.l	1
Edt_Runned	rs.l	1

Ed_Prg2ReLoad	rs.l	1
Ed_BankGrab	rs.w 	1
Ed_BankFlag	rs.w 	1
Ed_ZapCounter	rs.w	1
Ed_ZapError	rs.w	1
Ed_ZapMessage	rs.l	1
Ed_ZapParam	rs.l	1
Ed_ADialogues	rs.l	1
Ed_VDialogues	rs.l	1
Ed_DiaCopyD	rs.l	1
Ed_DiaCopyC	rs.l	1

EdMa_Changed	rs.b	1
Ed_FUndo	rs.b	1
Ed_SCallFlags	rs.b	1
EdC_Changed	rs.b	1

EdMa_Head	equ	"ApMa"
EdMa_List	rs.l	1
EdMa_Play	rs.l	1
EdMa_Tape	rs.w	1
EdMa_Change	rs.b	1
Ed_CuFlag	rs.b	1

Ed_AutoSaveRef	rs.l	1
Ed_Avert	rs.w	1

Ed_Ty		rs.w	1
Ed_Block	rs.l	1
Ed_BufE:	rs.l 	1	
Ed_BufT:	rs.l 	1		
Ed_WindowToDel	rs.l	1
Ed_EtCps	rs.b 	1
Ed_EtatAff	rs.b	1
Ed_EtXX		rs.b	8	
Ed_EtOCps	rs.b 	1
EdC_Modified	rs.b	1
Ed_MemoryX	rs.w	1
Ed_MemorySx	rs.w	1

Ed_Resource	rs.l	1

Ed_ExtTitles	rs.l	26

Ed_MKey		rs.b	1
Ed_MkFl		rs.b	1
Ed_MkIns	rs.b	1
Ed_OMKey	rs.b	1
Ed_BigView	rs.b	1
Ed_LinkTokCur	rs.b	1

Ed_MkCpt	rs.w	1
Ed_WMax		rs.w	1
Ed_SchLong	rs.b	1
Ed_RepLong	rs.b 	1
Ed_Opened	rs.b	1
Ed_TstMesOn	rs.b	1

Ed_NoAff	rs.b	1	
Ed_Warm		rs.b	1
Ed_Disk		rs.w	1
Ed_FSel		rs.w	1

Ed_SchBuf	rs.b 	34
Ed_RepBuf	rs.b 	34

EdM_Table	rs.l	1
EdM_TableSize	rs.l	1
EdM_TableAMOS	rs.l	1
EdM_MenuAMOS	rs.l	1
EdM_MessAMOS	rs.l	1
EdM_PosHidden	rs.w	1
EdM_Flag	rs.b	1
		rs.b	1

EdM_Copie	rs.b	Mn_ESave-Mn_SSave
Ed_Boutons	rs.b	Bt_Long*14

SlDelai		equ 	10		

* ILLEGAL à enlever
EdMarks:	equ 	__RS

; Zone de sauvegarde de la config Editeur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ed_DConfig	equ	__RS
; Screen definition
Ed_Sx		rs.w	1		
Ed_Sy		rs.w	1
Ed_Wx		rs.w	1
Ed_Wy		rs.w	1
Ed_VScrol	rs.w	1
Ed_Inter	rs.b	1
		rs.b	1
; Colour back
Ed_ColB		rs.w	1
; Length UNDO
Ed_LUndo	rs.l	1	
Ed_NUndo	rs.l	1
; Untok case
DtkMaj1		rs.b	1	
DtkMaj2		rs.b	1
; Flags
Ed_SvBak	rs.b	1
EdM_Keys	rs.b	1
Esc_KMemMax	rs.w	1
; Colour palette
Ed_Palette	rs.w	8
; Escape mode positions
Es_Y1		rs.w	1
Es_Y2		rs.w	1
; Security!
		rs.l	7
; Flags change within the editor
Ed_AutoSave	rs.l	1	
Ed_AutoSaveMn	rs.l	1	
Ed_SchMode	rs.w 	1	
Ed_Tabs		rs.w	1
Esc_Output	rs.b	1
Ed_QuitFlags	rs.b	1
Ed_Insert	rs.b	1
Ed_Sounds	rs.b	1

; Programmes autoload
; ~~~~~~~~~~~~~~~~~~~
Ed_AutoLoad	rs.b	3*184
; Touches par defaut
; ~~~~~~~~~~~~~~~~~~
Ed_KFonc	rs.b	3*184
		rs.b	2
Ed_FConfig	equ	__RS

; Find de la config editeur		
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

********************************* Total data length
DataLong:	equ __RS

;	Flags banques
; ~~~~~~~~~~~~~~~~~~~
Bnk_BitData	equ	0		;Banque de data
Bnk_BitChip	equ	1		;Banque en chip
Bnk_BitBob	equ	2		;Banque de Bobs
Bnk_BitIcon	equ	3		;Banque d'icons

; _____________________________________________________________________________
;
;				 	Définition d'un programme
; _____________________________________________________________________________
;

		RsReset

Prg_Next	rs.l	1		;Prochain dans la liste

Prg_NLigne:	rs.w 	1		;Nombre de lignes

Prg_StMini	rs.l	1		;Buffer de stockage
Prg_StTTexte	rs.l 	1	
Prg_StHaut	rs.l 	1	
Prg_StBas	rs.l 	1
Prg_Banks	rs.l	1
Prg_Dialogs	rs.l	1
Prg_StModif	rs.b 	1		;Listing modifie
Prg_Change	rs.b	1		;Sauver le programme
Prg_Edited	rs.b	1		;Une fenetre?
Prg_NoNamed	rs.b	1		;Numero de la structure
Prg_Not1.3	rs.b	1		;Compatible 1.3?
		rs.b	1

Prg_Previous	rs.l	1		;Programme precedent
Prg_RunData	rs.l	1		;Donnée si PRUN
Prg_ZapData	rs.l	1
Prg_AdEProc	rs.l 	1		;Procedure d'erreur
Prg_XEProc	rs.w 	1

Prg_Undo	rs.l	1		;Buffer undo
Prg_PUndo	rs.l	1		;Position dans buffer
Prg_Marks	rs.l 	10		

Prg_NamePrg	rs.b	128		;Nom du programme
Prg_Long	equ	__RS
		

; _____________________________________________________________________________
;
;				 	Définition d'une edition
; _____________________________________________________________________________
;

		RsReset
Edt_Next	rs.l	1		;Edition suivante
Edt_Prg		rs.l	1		;Adresse structure programme
Edt_BufE	rs.l	1		;Adresse buffer edition

; Données affichage
Edt_Order	rs.w	1		;Numero d'ordre dans l'affichage
Edt_Window	rs.w	1		;Numero des diverse zones / fenetres
Edt_WindEtat	rs.w	1
Edt_Zones	rs.w	1
Edt_ZEtat	rs.w	1
Edt_ZBas	rs.w	1

Edt_X		rs.w	1		;Coordonnees de la fenetre
Edt_Y		rs.w	1
Edt_Sy		rs.w	1
Edt_WindX	rs.w	1
Edt_WindY	rs.w	1
Edt_WindSx	rs.w	1
Edt_WindSy	rs.w	1
Edt_WindTx	rs.w	1
Edt_WindTy	rs.w	1
Edt_WindOldTy	rs.w	1
Edt_WindEX	rs.w	1
Edt_WindEY	rs.w	1
Edt_WindESx	rs.w	1
Edt_BasY	rs.w	1
Edt_EtMess	rs.w 	1		
Edt_EtAlert	rs.l 	1		

Edt_SInit	equ	__RS		;Zone à remettre à zero
Edt_SReload	equ	__RS
Edt_SSplit	equ	__RS
Edt_XPos	rs.w 	1		;Positions texte dans fenetre
Edt_YPos	rs.w 	1
Edt_XCu		rs.w 	1		;Positions curseur
Edt_YCu		rs.w 	1
Edt_DebProc	rs.l 	1
Edt_CurLigne	rs.l 	1		;Recherche
Edt_LEdited	rs.w	1		;Flag ligne editee
Edt_EInit	equ	__RS
Edt_EReload	equ	__RS
Edt_ESplit	equ	__RS

Edt_XBloc	rs.w	1		;Position bloc
Edt_YBloc	rs.w	1
Edt_YOldBloc	rs.w	1

Edt_LinkPrev	rs.l	1		;Links de fenetre
Edt_LinkNext	rs.l	1
Edt_LinkScroll	rs.l	1
Edt_LinkYOld	rs.w	1

Edt_Hidden	rs.b	1		;Fenetre cachee
Edt_LinkFlag	rs.b	1		;Fenetre linkee
Edt_First	rs.b	1		;Premiere fenetre affichee?
Edt_Last	rs.b	1		;Derniere fenetre affichee?
Edt_EtatAff	rs.b	1		;Flags ligne d'etat
Edt_PrgDelete	rs.b	1		;Programme à effacer en retour
Edt_ASlY	rs.b	1		;Compteur affichage slider
		rs.b	1

Edt_SlV		rs.b	Sl_Long		;Structure slider
Edt_Bt1		rs.b	Bt_Long		;Structures bouton
Edt_Bt2		rs.b	Bt_Long
Edt_Bt3		rs.b	Bt_Long
		rs.w	1
Edt_Long	equ	__RS		;Longueur de la structure

;						Flags de la ligne d'etat
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EtA_Caps	equ	0
EtA_Ins		equ	1
EtA_X		equ	2
EtA_Y		equ	3
EtA_Nom		equ	4
EtA_Free	equ	5
EtA_Clw		equ	6
EtA_Alert	equ	7
EtA_BXY		equ	%00001100
EtA_BAll	equ	%01111111

;			AREXX
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
RC_OK			equ	0
RC_WARN			equ	5
RC_ERROR		equ	10
RC_FATAL		equ	20
RXCODEMASK		equ 	$FF000000
RXCOMM			equ	$01000000
RXFUNC			equ	$02000000
RXFF_RESULT		equ	$00020000
ra_Length		equ	4
ra_Buff			equ	8
rm_Result1		equ	$20
rm_Result2		equ	$24
rm_Sdtin		equ	$74
rm_Sdout		equ	$78
rm_Args			equ	$28
rm_Action		equ	$1c

