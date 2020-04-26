
*		Version 1.2

***********************************************************
*
*		AMOS EQUATES DEFINITION
*
*		By Francois Lionet
*		AMOS (c) 1990 Mandarin / Jawx
*
*		Last change 14/10/1990
*
***********************************************************
*		This file is public domain!
***********************************************************
*	Here is all AMOS internal data offsets and macro 
* definitions. More on all AMOS jumps tables in the AMOS 
* club newsletter!
***********************************************************

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
ExecBase:	equ 4
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
		move.l	$4,a6
		jsr	\1(a6)
		ENDM
;GfxCall:	MACRO
;		movem.l	d0-d7/a0-a6,-(sp)
;		move.l	GfxBase,a6
;		jsr	\1(a6)
;		movem.l	(sp)+,d0-d7/a0-a6
;		ENDM

*************** DOS
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
DosInfo:	equ -114
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
SyVect:		equ $100

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
NXyaHs:		equ 30
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

SyCall:		MACRO
		move.l	SyVect,a0
		jsr	\1*4(a0)
		ENDM
SyCalA:		MACRO
		lea	\2,a1
		move.l	SyVect,a0
		jsr	\1*4(a0)
		ENDM
SyCalD:		MACRO
		moveq	#\2,d1
		move.l	SyVect,a0
		jsr	\1*4(a0)
		ENDM
SyCal2:		MACRO
		moveq	#\2,d1
		move.l	#\3,a1
		move.l	SyVect,a0
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
EcLogic:	rs.l 6
EcPhysic	rs.l 6
EcCurrent:	rs.l 6

* Datas!
EcCon0:		rs.w 1
EcCon2:		rs.w 1
EcTx:		rs.w 1
EcTy:		rs.w 1
EcNPlan:	rs.w 1
EcWX:		rs.w 1
EcWY:		rs.w 1
EcWTx:		rs.w 1
EcWTy:		rs.w 1
EcVX:		rs.w 1
EcVY:		rs.w 1
EcColorMap:	rs.w 1
EcNbCol:	rs.w 1
EcPal:		rs.w 32
EcDEcran:	rs.l 1

EcTPlan:	rs.l 1
EcWindow:	rs.l 1
EcTxM:		rs.w 1
EcTyM:		rs.w 1
EcTLigne:	rs.w 1
EcFlags:	rs.w 1
EcDual:		rs.w 1
EcWXr:		rs.w 1
EcWTxr:		rs.w 1
EcNumber:	rs.w 1
EcAuto:		rs.w 1

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

EcVect:		equ $104

Raz:		equ 0
CopMake:	equ 1
*		equ 2
Cree:		equ 3
Del:		equ 4
First:		equ 5
Last:		equ 6
Active:		equ 7
CopForce:	equ 8
View:		equ 9
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

EcCall:		MACRO
		move.l	EcVect,a0
		jsr	\1*4(a0)
		ENDM
EcCalA:		MACRO
		lea	\2,a1
		move.l	EcVect,a0
		jsr	\1*4(a0)
		ENDM
EcCalD:		MACRO
		moveq	#\2,d1
		move.l	EcVect,a0
		jsr	\1*4(a0)
		ENDM
EcCal2:		MACRO
		moveq	#\2,d1
		move.l	#\3,a1
		move.l	EcVect,a0
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

WiVect:		equ $108
AMOSLoaded	equ $10C

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
	
WiCall:		MACRO
		move.l	WiVect,a0
		jsr	\1*4(a0)
		ENDM
WiCalA:		MACRO
		lea	\2,a1
		move.l	WiVect,a0
		jsr	\1*4(a0)
		ENDM
WiCalD:		MACRO
		moveq	#\2,d1
		move.l	WiVect,a0
		jsr	\1*4(a0)
		ENDM
WiCal2:		MACRO
		moveq	#\2,d1
		move.l	#\3,a1
		move.l	WiVect,a0
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

***************************************************************
*		Interpretor datas zone
*		Pointed to by A5
***************************************************************

		RsReset

*************** VBL ROUTINES 
VblRout:	rs.l 8

*************** EXTENSIONS
AdTokens:	rs.l 27		
AdTTokens:	rs.l 27
ExtAdr:		rs.l 26*4
ExtTests:	rs.l 8

*************** GRAPHICS
AreaSize:	equ 16
AreaInfo:	rs.b 24
AreaBuf:	rs.b AreaSize*5+10
		rs.b 16
TmpRas:		rs.l 2
AppNPlan	rs.w 1
SccEcO:		rs.l 1
SccEcD:		rs.l 1

*************** File selector
EdFSel:		rs.w 1		
FsAdEc:		rs.l 1
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
FsWy:		rs.w 1
FsWx:		rs.w 1
FsVApp:		rs.w 1

********************************* Editor
BasSp:		rs.l 1	
FkEcran:	rs.l 1	
FkOn:		rs.w 1	
FkJeu:		rs.w 1	
FkOJeu:		rs.w 1	
FkMFlag:	rs.w 1
AmiAff:		rs.w 1
AmiOAff:	rs.w 1

EdEcran:	rs.l 1	
EdBufE:		rs.l 1	
EdBufT:		rs.l 1	

EdXPos:		rs.w 1	
EdYPos:		rs.w 1
EdXCu:		rs.w 1	
EdYCu:		rs.w 1
EdTabs:		rs.w 1	
EdFlag:		rs.w 1	
EdNLigne:	rs.w 1	
EdIns:		rs.w 1	
EdEdit:		rs.w 1	
EdChange:	rs.w 1	
StModif:	rs.w 1
EdFkCpt:	rs.w 1	
EdAfFk:		rs.w 1
EdMKey:		rs.w 1	
EdMkFl:		rs.w 1	
EdMkIns:	rs.w 1	
EdILigne:	rs.w 1	

EtMess:		rs.w 1		
EtAlert:	rs.l 1		
EtCps:		rs.w 1		
EtOCps:		rs.w 1
EtAX:		rs.w 1		
EtAY:		rs.w 1		
EtFr:		rs.w 1		

SlDelai:	equ 10		
EtASlX:		rs.w 1
EtASlY:		rs.w 1
WbClose:	rs.w 1		

********************************* Escape
EsFlag:		rs.w 1
EscTFonc:	rs.l 1
LEdXCu:		rs.w 1
LEdYCu:		rs.w 1
ColBack:	rs.w 1
EFkFlag:	rs.w 1
DefFlag:	rs.w 1	

********************************* Float
FloatBase:	rs.l 1
MathBase:	rs.l 1
BuFloat:	rs.b 64
DeFloat:	rs.b 32
TempFl:		rs.l 1
TempBuf:	rs.l 1
ValPi:		rs.l 1
Val180:		rs.l 1
CallAd:		rs.l 1

********************************* Disque I/O
IffParam:	rs.l 1
IffFlag:	rs.l 1
BufFillF:	rs.l 1
FillFLong:	rs.w 1
FillFSize:	rs.w 1
FillFNb:	rs.w 1
FillF32:	rs.w 1
DirLong:	rs.l 1
DirComp:	rs.w 1
DirLNom:	rs.w 1	
PathAct:	rs.l 1
DirFNeg:	rs.l 1	
BufBMHD:	rs.l 1
BufCMAP:	rs.l 1
BufCAMG:	rs.l 1
BufCCRT:	rs.l 1
BufAMSC:	rs.l 1

********************************* Tokenisation / Stockage
TkAd:		rs.l 1	
TkChCar:	rs.w 1	
VerPos:		rs.l 1	
VerBase:	rs.l 1	
Parenth:	rs.w 1	
DtkMaj1:	rs.w 1	
DtkMaj2:	rs.w 1
StTTexte:	rs.l 1	
StHaut:		rs.l 1	
StBas:		rs.l 1	
StMini:		rs.l 1	
StDLigne:	rs.w 1	
StFLigne:	rs.w 1	
StNLigne:	rs.w 1	
LimSave:	rs.w 4
FsLimSave:	rs.w 4
Buffer:		rs.l 1	
BMenage:	rs.l 1
Name1:		rs.l 1	
Name2:		rs.l 1
BufEsc:		rs.l 1	
TBuffer:	equ 1024	
TMenage:	equ TBuffer-64
Access:		rs.l 1		
AcLdTemp:	rs.l 1
AccFlag:	rs.w 1
BBanks:		rs.l 2*16
BankGrab:	rs.w 1
BankFlag:	rs.w 1
RunAct:		rs.l 1
NamePrg:	rs.b 128	
RasAd:		rs.l 1		
RasLong:	rs.l 1
RasSize:	rs.w 1
RasLock:	rs.l 1
ScOn:		rs.w 1
ScOnAd:		rs.l 1
BufBob:		rs.l 1
BufLabel:	rs.l 1
Logo:		rs.l 1
LMouse:		rs.l 1
VBLOCount:	rs.w 1
VBLDelai:	rs.w 1
SScan:		rs.w 1
Seed:		rs.l 1
OldRnd:		rs.l 1
PAmalE:		rs.w 1
DosBase:	rs.l 1
ReqSave:	rs.l 1
ReqSSave:	rs.l 1
SNoFlip:	rs.w 1
LockSave:	rs.l 1
EdDisk:		rs.w 1
Handle:		rs.l 1
PrtHandle:	rs.l 1
PosFillF:	rs.w 1

********************************* Variables / Run
DebSave:	equ __RS
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

Direct:		rs.w 1
DirFlag:	rs.w 1
PLoop:		rs.l 1
MinLoop:	rs.l 1
BasA3:		rs.l 1
ErrRet:		rs.l 1		
ErrRAd:		rs.l 1
Phase:		rs.w 1
DRun:		rs.l 1
DTablA:		rs.l 1
CurTablA:	rs.l 1
PDebug:		rs.l 1
Actual:		rs.w 1
ActuMask:	rs.w 1		
IffMask:	rs.l 1
ExpFlg:		rs.w 1
FixFlg:		rs.w 1

*************** ANIMATIONS
AnCanaux:	rs.w 64
InterOff:	rs.w 1

*************** DEF SCROLLS
DScrolls:	rs.w 6*16

*************** BANKS
ABanks:		rs.l 1

*************** Disc / Printer
FhA:		equ 0
FhT:		equ 4
FhF:		equ 6
TFiche:		equ 10
NFiche:		equ 10
ChrInp:		rs.w 1
Fichiers:	rs.b TFiche*NFiche

*************** MENUS
MnNDim:		equ 8
MnBase:		rs.l 1
MnBaseX:	rs.w 1
MnBaseY:	rs.w 1
MnChange:	rs.w 1
MnMouse:	rs.w 1
MnError:	rs.w 1
MnAdEc:		rs.l 1
MnScOn:		rs.w 1
MgFlags:	rs.w 1
MnNZone:	rs.w 1
MnZoAct:	rs.w 1
MnAct:		rs.l 1
MnTDraw:	rs.l 1
MnTable:	rs.l MnNDim+1
MnChoix:	rs.w MnNDim
MnDFlags:	rs.b MnNDim
MnDAd:		rs.l 1
MnProc:		rs.w 1
MnRA3:		rs.l 1
MnRA4:		rs.l 1
MnPile:		rs.l 1
OMnBase:	rs.l 1
OMnNb:		rs.w 1
OMnType:	rs.w 1

*************** Every
EveType:	rs.w 1
EveLabel:	rs.l 1
EveCharge:	rs.w 1
LogoFlag:	rs.w 1

*************** Miscellenous
BuffSize:	rs.l 1
AdrIcon:	rs.l 1
IconBase:	rs.l 1
FolFlg:		rs.w 1
FolPos:		rs.l 1
FolPPos:	rs.l 1
FoLine:		rs.l 1
CurLigne:	rs.l 1
DebProc:	rs.l 1
AdEProc:	rs.l 1
XEProc:		rs.w 1
EdBloc:		rs.w 1
YOBloc:		rs.w 1
Y1Bloc:		rs.w 1
Y2Bloc:		rs.w 1
EdBlocAd:	rs.l 1
SchFlag:	rs.w 1
SchMode:	rs.w 1
DefPal:		rs.w 32
SchBuf:		rs.b 34
RepBuf:		rs.b 34
EdMarks:	rs.l 10

********************************* RUN init variables 
DBugge		rs.l 1
DebRaz:		equ __RS
PrintFlg:	rs.w 1
PrintPos:	rs.l 1
PrinType:	rs.w 1
PrintFile:	rs.l 1
UsingFlg:	rs.w 1
ImpFlg:		rs.w 1
ParamE:		rs.l 1
ParamF:		rs.l 1
ParamC:		rs.l 1
InputFlg:	rs.w 1
ContFlg:	rs.w 1
ContChr:	rs.l 1
ErrorOn:	rs.w 1
ErrorChr:	rs.l 1
OnErrLine:	rs.l 1
TVMax:		rs.w 1
DProc:		rs.l 1
AData:		rs.l 1
PData:		rs.l 1
MenA4:		rs.l 1
LockOld:	rs.l 1
CallReg:	rs.l 8+7
MnChoice:	rs.w 1
Angle:		rs.w 1
FinRaz:		equ __RS
FinSave:	equ __RS

********************************* Total data length
DataLong:	equ __RS




;Added by Andy Church, 23/06/94:

Bnk_BitData	equ 0
Bnk_BitChip	equ 1
Bnk_BitBob	equ 2
Bnk_BitIcon	equ 3

L_Error		equ 1024
L_ErrorExt	equ 1025
