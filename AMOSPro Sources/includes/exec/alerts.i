	IFND	EXEC_ALERTS_I
EXEC_ALERTS_I	SET	1
**
**	$Filename: exec/alerts.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

    BITDEF  S,ALERTWACK,1	* in ExecBase.SysFlags


**********************************************************************
*
*  Format of the alert error number:
*
*    +---------------+----------------+--------------------------------+  
*    |D|  SubSysId   |	General Error |	   SubSystem Specific Error    |
*    +---------------+----------------+--------------------------------+
*
*		     D:	 DeadEnd alert
*	      SubSysId:	 indicates ROM subsystem number.
*	 General Error:	 roughly indicates what the error was
*	Specific Error:	 indicates more detail
***********************************************************************

*
*  Use this macro for causing an alert.	 THIS MACRO MAY CHANGE!
*  It is very sensitive to memory corruption.... like stepping on
*  location 4!	But it should work for now.
*
ALERT		macro	(alertNumber, paramArray, scratch)
		movem.l d7/a5/a6,-(sp)
		move.l	#\1,d7
		IFNC	'\2',''
		lea	\2,a5
		ENDC
		move.l	4,a6		; (use proper name!!!)
		jsr	_LVOAlert(a6)
		movem.l (sp)+,d7/a5/a6
		endm


**********************************************************************
*
*  General Dead-End Alerts
*
*  For example:	 timer.device cannot open math.library:
*
*	ALERT  (AN_TimerDev!AG_OpenLib!AO_MathLib),(A0),A1
*
**********************************************************************

;------ alert types
AT_DeadEnd	equ $80000000
AT_Recovery	equ $00000000

;------ general purpose alert codes
AG_NoMemory	equ $00010000
AG_MakeLib	equ $00020000
AG_OpenLib	equ $00030000
AG_OpenDev	equ $00040000
AG_OpenRes	equ $00050000
AG_IOError	equ $00060000
AG_NoSignal	equ $00070000

;------ alert objects:
AO_ExecLib	equ $00008001
AO_GraphicsLib	equ $00008002
AO_LayersLib	equ $00008003
AO_Intuition	equ $00008004
AO_MathLib	equ $00008005
AO_CListLib	equ $00008006
AO_DOSLib	equ $00008007
AO_RAMLib	equ $00008008
AO_IconLib	equ $00008009
AO_ExpansionLib equ $0000800A
AO_AudioDev	equ $00008010
AO_ConsoleDev	equ $00008011
AO_GamePortDev	equ $00008012
AO_KeyboardDev	equ $00008013
AO_TrackDiskDev equ $00008014
AO_TimerDev	equ $00008015
AO_CIARsrc	equ $00008020
AO_DiskRsrc	equ $00008021
AO_MiscRsrc	equ $00008022
AO_BootStrap	equ $00008030
AO_Workbench	equ $00008031


**********************************************************************
*
*   Specific Dead-End Alerts:
*
*   For example:   exec.library -- corrupted memory list
*
*	    ALERT  AN_MemCorrupt,(A0),A1
*
**********************************************************************

;------ exec.library
AN_ExecLib	equ $01000000
AN_ExcptVect	equ $81000001	; 68000 exception vector checksum
AN_BaseChkSum	equ $81000002	; execbase checksum
AN_LibChkSum	equ $81000003	; library checksum failure
AN_LibMem	equ $81000004	; no memory to make library
AN_MemCorrupt	equ $81000005	; corrupted memory list
AN_IntrMem	equ $81000006	; no memory for interrupt servers
AN_InitAPtr	equ $81000007	; InitStruct() of an APTR source
AN_SemCorrupt	equ $81000008	; a semaphore is in illegal state
AN_FreeTwice	equ $81000009	; freeing memory that is already free
AN_BogusExcpt	equ $8100000A	; illegal 68k exception taken

;------ graphics.library
AN_GraphicsLib	equ $02000000
AN_GfxNoMem	equ $82010000	; graphics out of memory
AN_LongFrame	equ $82010006	; long frame, no memory
AN_ShortFrame	equ $82010007	; short frame, no memory
AN_TextTmpRas	equ $02010009	; text, no memory for TmpRas
AN_BltBitMap	equ $8201000A	; BltBitMap, no memory
AN_RegionMemory equ $8201000B	; regions, memory not available
AN_MakeVPort	equ $82010030	; MakeVPort, no memory
AN_GfxNoLCM	equ $82011234	; emergency memory not available

;------ layers.library
AN_LayersLib	equ $03000000
AN_LayersNoMem	equ $83010000	; layers out of memory

;------ intuition.library
AN_Intuition	equ $04000000
AN_GadgetType	equ $84000001	; unknown gadet type
AN_BadGadget	equ $04000001	; Recovery form of AN_GadgetType
AN_CreatePort	equ $84010002	; create port, no memory
AN_ItemAlloc	equ $04010003	; item plane alloc, no memory
AN_SubAlloc	equ $04010004	; sub alloc, no memory
AN_PlaneAlloc	equ $84010005	; plane alloc, no memory
AN_ItemBoxTop	equ $84000006	; item box top < RelZero
AN_OpenScreen	equ $84010007	; open screen, no memory
AN_OpenScrnRast equ $84010008	; open screen, raster alloc, no memory
AN_SysScrnType	equ $84000009	; open sys screen, unknown type
AN_AddSWGadget	equ $8401000A	; add SW gadgets, no memory
AN_OpenWindow	equ $8401000B	; open window, no memory
AN_BadState	equ $8400000C	; Bad State Return entering Intuition
AN_BadMessage	equ $8400000D	; Bad Message received by IDCMP
AN_WeirdEcho	equ $8400000E	; Weird echo causing incomprehension
AN_NoConsole	equ $8400000F	; couldn't open the Console Device

;------ math.library
AN_MathLib	equ $05000000

;------ clist.library
AN_CListLib	equ $06000000

;------ dos.library
AN_DOSLib	equ $07000000
AN_StartMem	equ $07010001	; no memory at startup 
AN_EndTask	equ $07000002	; EndTask didn't 
AN_QPktFail	equ $07000003	; Qpkt failure 
AN_AsyncPkt	equ $07000004	; Unexpected packet received 
AN_FreeVec	equ $07000005	; Freevec failed 
AN_DiskBlkSeq	equ $07000006	; Disk block sequence error 
AN_BitMap	equ $07000007	; Bitmap corrupt 
AN_KeyFree	equ $07000008	; Key already free 
AN_BadChkSum	equ $07000009	; Invalid checksum 
AN_DiskError	equ $0700000A	; Disk Error 
AN_KeyRange	equ $0700000B	; Key out of range 
AN_BadOverlay	equ $0700000C	; Bad overlay

;------ ramlib.library
AN_RAMLib	equ $08000000
AN_BadSegList	equ $08000001	; overlays are illegal for library segments

;------ icon.library
AN_IconLib	equ $09000000

;------ expansion.library
AN_ExpansionLib equ $0A000000
AN_BadExpansionFree	equ $0A000001

;------ audio.device
AN_AudioDev	equ $10000000

;------ console.device
AN_ConsoleDev	equ $11000000

;------ gameport.device
AN_GamePortDev	equ $12000000

;------ keyboard.device
AN_KeyboardDev	equ $13000000

;------ trackdisk.device
AN_TrackDiskDev equ $14000000
AN_TDCalibSeek	equ $14000001	; calibrate: seek error
AN_TDDelay	equ $14000002	; delay: error on timer wait

;------ timer.device
AN_TimerDev	equ $15000000
AN_TMBadReq	equ $15000001	; bad request
AN_TMBadSupply	equ $15000002	; power supply does not supply ticks

;------ cia.resource
AN_CIARsrc	equ $20000000

;------ disk.resource
AN_DiskRsrc	equ $21000000
AN_DRHasDisk	equ $21000001	: get unit: already has disk
AN_DRIntNoAct	equ $21000002	; interrupt: no active unit

;------ misc.resource
AN_MiscRsrc	equ $22000000

;------ bootstrap
AN_BootStrap	equ $30000000
AN_BootError	equ $30000001	; boot code returned an error

;------ workbench
AN_Workbench	equ $31000000

;------ DiskCopy
AN_DiskCopy	equ $32000000

	ENDC	; EXEC_ALERTS_I
