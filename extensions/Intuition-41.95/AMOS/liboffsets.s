***********************************************************
*
*		Amiga library offsets
*
***********************************************************

FUNCSTART	Macro
LibPointer	set 	-$1e
		EndM

FUNCDEF		Macro
_LVO\1		equ	LibPointer
LibPointer	set	LibPointer-6
		EndM
*
* Exec

	IFND	_LVOSupervisor
		FUNCSTART
		FUNCDEF	Supervisor
		FUNCDEF	ExitIntr
		FUNCDEF	Schedule
		FUNCDEF	Reschedule
		FUNCDEF	Switch
		FUNCDEF	Dispatch
		FUNCDEF	Exception
		FUNCDEF	InitCode
		FUNCDEF	InitStruct
		FUNCDEF	MakeLibrary
		FUNCDEF	MakeFunctions
		FUNCDEF	FindResident
		FUNCDEF	InitResident
		FUNCDEF	Alert
		FUNCDEF	Debug
		FUNCDEF	Disable
		FUNCDEF	Enable
		FUNCDEF	Forbid
		FUNCDEF	Permit
		FUNCDEF	SetSR
		FUNCDEF	SuperState
		FUNCDEF	UserState
		FUNCDEF	SetIntVector
		FUNCDEF	AddIntServer
		FUNCDEF	RemIntServer
		FUNCDEF	Cause
		FUNCDEF	Allocate
		FUNCDEF	Deallocate
		FUNCDEF	AllocMem
		FUNCDEF	AllocAbs
		FUNCDEF	FreeMem
		FUNCDEF	AvailMem
		FUNCDEF	AllocEntry
		FUNCDEF	FreeEntry
		FUNCDEF	Insert
		FUNCDEF	AddHead
		FUNCDEF	AddTail
		FUNCDEF	Remove
		FUNCDEF	RemHead
		FUNCDEF	RemTail
		FUNCDEF	Enqueue
		FUNCDEF	FindName
		FUNCDEF	AddTask
		FUNCDEF	RemTask
		FUNCDEF	FindTask
		FUNCDEF	SetTaskPri
		FUNCDEF	SetSignal
		FUNCDEF	SetExcept
		FUNCDEF	Wait
		FUNCDEF	Signal
		FUNCDEF	AllocSignal
		FUNCDEF	FreeSignal
		FUNCDEF	AllocTrap
		FUNCDEF	FreeTrap
		FUNCDEF	AddPort
		FUNCDEF	RemPort
		FUNCDEF	PutMsg
		FUNCDEF	GetMsg
		FUNCDEF	ReplyMsg
		FUNCDEF	WaitPort
		FUNCDEF	FindPort
		FUNCDEF	AddLibrary
		FUNCDEF	RemLibrary
		FUNCDEF	OldOpenLibrary
		FUNCDEF	CloseLibrary
		FUNCDEF	SetFunction
		FUNCDEF	SumLibrary
		FUNCDEF	AddDevice
		FUNCDEF	RemDevice
		FUNCDEF	OpenDevice
		FUNCDEF	CloseDevice
		FUNCDEF	DoIO
		FUNCDEF	SendIO
		FUNCDEF	CheckIO
		FUNCDEF	WaitIO
		FUNCDEF	AbortIO
		FUNCDEF	AddResource
		FUNCDEF	RemResource
		FUNCDEF	OpenResource
		FUNCDEF	RawIOInit
		FUNCDEF	RawMayGetChar
		FUNCDEF	RawPutChar
		FUNCDEF	RawDoFmt
		FUNCDEF	GetCC
		FUNCDEF	TypeOfMem
		FUNCDEF	Procure
		FUNCDEF	Vacate
		FUNCDEF	OpenLibrary
		FUNCDEF	InitSemaphore
		FUNCDEF	ObtainSemaphore
		FUNCDEF	ReleaseSemaphore
		FUNCDEF	AttemptSemaphore
		FUNCDEF	ObtainSemaphoreList
		FUNCDEF	ReleaseSemaphoreList
		FUNCDEF	FindSemaphore
		FUNCDEF	AddSemaphore
		FUNCDEF	RemSemaphore
		FUNCDEF	SumKickData
		FUNCDEF	AddMemList
		FUNCDEF	CopyMem
		FUNCDEF	CopyMemQuick
		FUNCDEF	CacheClearU
		FUNCDEF	CacheClearE
		FUNCDEF	CacheControl
		FUNCDEF	CreateIORequest
		FUNCDEF	DeleteIORequest
		FUNCDEF	CreateMsgPort
		FUNCDEF	DeleteMsgPort
		FUNCDEF	ObtainSemaphoreShared
		FUNCDEF	AllocVec
		FUNCDEF	FreeVec
		FUNCDEF	CreatePrivatePool
		FUNCDEF	DeletePrivatePool
		FUNCDEF	AllocPooled
		FUNCDEF	FreePooled
		FUNCDEF	SetFunction8
		FUNCDEF	ColdReboot
		FUNCDEF	StackSwap
		FUNCDEF	ChildFree
		FUNCDEF	ChildOrphan
		FUNCDEF	ChildStatus
		FUNCDEF	ChildWait
		FUNCDEF	ExecReserved00
		FUNCDEF	ExecReserved01
		FUNCDEF	ExecReserved02
		FUNCDEF	ExecReserved03
	ENDC
*
* Dos
	IFND	_LVOOpen
		FUNCSTART
		FUNCDEF	Open
		FUNCDEF	Close
		FUNCDEF	Read
		FUNCDEF	Write
		FUNCDEF	Input
		FUNCDEF	Output
		FUNCDEF	Seek
		FUNCDEF	DeleteFile
		FUNCDEF	Rename
		FUNCDEF	Lock
		FUNCDEF	UnLock
		FUNCDEF	DupLock
		FUNCDEF	Examine
		FUNCDEF	ExNext
		FUNCDEF	Info
		FUNCDEF	CreateDir
		FUNCDEF	CurrentDir
		FUNCDEF	IoErr
		FUNCDEF	CreateProc
		FUNCDEF	Exit
		FUNCDEF	LoadSeg
		FUNCDEF	UnLoadSeg
		FUNCDEF	ClearVec
		FUNCDEF	NoReqLoadSeg
		FUNCDEF	DeviceProc
		FUNCDEF	SetComment
		FUNCDEF	SetProtection
		FUNCDEF	DateStamp
		FUNCDEF	Delay
		FUNCDEF	WaitForChar
		FUNCDEF	ParentDir
		FUNCDEF	IsInteractive
		FUNCDEF	Execute
		FUNCDEF	AllocDosObject
		FUNCDEF	FreeDosObject
		FUNCDEF	DoPkt
		FUNCDEF	SendPkt
		FUNCDEF	WaitPkt
		FUNCDEF	ReplyPkt
		FUNCDEF	AbortPkt
		FUNCDEF	LockRecord
		FUNCDEF	LockRecords
		FUNCDEF	UnLockRecord
		FUNCDEF	UnLockRecords
		FUNCDEF	SelectInput
		FUNCDEF	SelectOutput
		FUNCDEF	FGetC
		FUNCDEF	FPutC
		FUNCDEF	UnGetC
		FUNCDEF	FRead
		FUNCDEF	FWrite
		FUNCDEF	FGets
		FUNCDEF	FPuts
		FUNCDEF	VFWritef
		FUNCDEF	VFPrintf
		FUNCDEF	Flush
		FUNCDEF	SetVBuf
		FUNCDEF	DupLockFromFH
		FUNCDEF	OpenFromLock
		FUNCDEF	ParentOfFH
		FUNCDEF	ExamineFH
		FUNCDEF	SetFileDate
		FUNCDEF	NameFromLock
		FUNCDEF	NameFromFH
		FUNCDEF	SplitName
		FUNCDEF	SameLock
		FUNCDEF	SetMode
		FUNCDEF	ExAll
		FUNCDEF	ReadLink
		FUNCDEF	MakeLink
		FUNCDEF	ChangeMode
		FUNCDEF	SetFileSize
		FUNCDEF	SetIoErr
		FUNCDEF	Fault
		FUNCDEF	PrintFault
		FUNCDEF	ErrorReport
		FUNCDEF	Requester
		FUNCDEF	Cli
		FUNCDEF	CreateNewProc
		FUNCDEF	RunCommand
		FUNCDEF	GetConsoleTask
		FUNCDEF	SetConsoleTask
		FUNCDEF	GetFileSysTask
		FUNCDEF	SetFileSysTask
		FUNCDEF	GetArgStr
		FUNCDEF	SetArgStr
		FUNCDEF	FindCliProc
		FUNCDEF	MaxCli
		FUNCDEF	SetCurrentDirName
		FUNCDEF	GetCurrentDirName
		FUNCDEF	SetProgramName
		FUNCDEF	GetProgramName
		FUNCDEF	SetPrompt
		FUNCDEF	GetPrompt
		FUNCDEF	SetProgramDir
		FUNCDEF	GetProgramDir
		FUNCDEF	System
		FUNCDEF	AssignLock
		FUNCDEF	AssignLate
		FUNCDEF	AssignPath
		FUNCDEF	AssignAdd
		FUNCDEF	RemAssignList
		FUNCDEF	GetDeviceProc
		FUNCDEF	FreeDeviceProc
		FUNCDEF	LockDosList
		FUNCDEF	UnlockDosList
		FUNCDEF	AttemptLockDosList
		FUNCDEF	RemDosEntry
		FUNCDEF	AddDosEntry
		FUNCDEF	FindDosEntry
		FUNCDEF	NextDosEntry
		FUNCDEF	MakeDosEntry
		FUNCDEF	FreeDosEntry
		FUNCDEF	IsFileSystem
		FUNCDEF	Format
		FUNCDEF	Relabel
		FUNCDEF	Inhibit
		FUNCDEF	AddBuffers
		FUNCDEF	CompareDates
		FUNCDEF	DateToStr
		FUNCDEF	StrToDate
		FUNCDEF	InternalLoadSeg
		FUNCDEF	InternalUnLoadSeg
		FUNCDEF	NewLoadSeg
		FUNCDEF	AddSegment
		FUNCDEF	FindSegment
		FUNCDEF	RemSegment
		FUNCDEF	CheckSignal
		FUNCDEF	ReadArgs
		FUNCDEF	FindArg
		FUNCDEF	ReadItem
		FUNCDEF	StrToLong
		FUNCDEF	MatchFirst
		FUNCDEF	MatchNext
		FUNCDEF	MatchEnd
		FUNCDEF	ParsePattern
		FUNCDEF	MatchPattern
		FUNCDEF	DosPrivateFunc4
		FUNCDEF	FreeArgs
		FUNCDEF	DosPrivateFunc5
		FUNCDEF	FilePart
		FUNCDEF	PathPart
		FUNCDEF	AddPart
		FUNCDEF	StartNotify
		FUNCDEF	EndNotify
		FUNCDEF	SetVar
		FUNCDEF	GetVar
		FUNCDEF	DeleteVar
		FUNCDEF	FindVar
		FUNCDEF	PrivateEntry1
		FUNCDEF	PrivateEntry2
		FUNCDEF	PrivateEntry3
		FUNCDEF	WriteChars
		FUNCDEF	PutStr
		FUNCDEF	VPrintf
		FUNCDEF	MatchReplace
	ENDC
*
* Mathieeedoubas
	IFND	_LVOIEEEDPFix
		FUNCSTART
		FUNCDEF	IEEEDPFix
		FUNCDEF	IEEEDPFlt
		FUNCDEF	IEEEDPCmp
		FUNCDEF	IEEEDPTst
		FUNCDEF	IEEEDPAbs
		FUNCDEF	IEEEDPNeg
		FUNCDEF	IEEEDPAdd
		FUNCDEF	IEEEDPSub
		FUNCDEF	IEEEDPMul
		FUNCDEF	IEEEDPDiv
		FUNCDEF	IEEEDPFloor
		FUNCDEF	IEEEDPCeil
	ENDC
*
* Mathieeedoubtrans
	IFND	_LVOIEEEDPAtan
		FUNCSTART
		FUNCDEF	IEEEDPAtan
		FUNCDEF	IEEEDPSin
		FUNCDEF	IEEEDPCos
		FUNCDEF	IEEEDPTan
		FUNCDEF	IEEEDPSincas
		FUNCDEF	IEEEDPSinh
		FUNCDEF	IEEEDPCosh
		FUNCDEF	IEEEDPTanh
		FUNCDEF	IEEEDPExp
		FUNCDEF	IEEEDPLog
		FUNCDEF	IEEEDPPow
		FUNCDEF	IEEEDPSqrt
		FUNCDEF	IEEEDPTieee
		FUNCDEF	IEEEDPFieee
		FUNCDEF	IEEEDPAsin
		FUNCDEF	IEEEDPAcos
		FUNCDEF IEEEDPLog10
	ENDC
*
* Mathtrans.library
	IFND	_LVOSPAtan
		FUNCSTART
		FUNCDEF	SPAtan
		FUNCDEF	SPSin
		FUNCDEF	SPCos
		FUNCDEF	SPTan
		FUNCDEF	SPSincos
		FUNCDEF	SPSinh
		FUNCDEF	SPCosh
		FUNCDEF	SPTanh
		FUNCDEF	SPExp
		FUNCDEF	SPLog
		FUNCDEF	SPPow
		FUNCDEF	SPSqrt
		FUNCDEF	SPTieee
		FUNCDEF	SPFieee
		FUNCDEF	SPAsin
		FUNCDEF	SPAcos
		FUNCDEF	SPLog10
	ENDC
*
* Mathffp.library
	IFND	_LVOSPFix
		FUNCSTART
		FUNCDEF	SPFix
		FUNCDEF	SPFlt
		FUNCDEF	SPCmp
		FUNCDEF	SPTst
		FUNCDEF	SPAbs
		FUNCDEF	SPNeg
		FUNCDEF	SPAdd
		FUNCDEF	SPSub
		FUNCDEF	SPMul
		FUNCDEF	SPDiv
		FUNCDEF SPFloor
		FUNCDEF SPCeil
	ENDC
* AREXX
	IFND	_LVORexx
		FUNCSTART
		FUNCDEF Rexx             ; Main entry point
		FUNCDEF rxParse          ; (private)
		FUNCDEF rxInstruct       ; (private)
		FUNCDEF rxSuspend        ; (private)
		FUNCDEF EvalOp           ; (private)
		FUNCDEF OAssignValue      ; (private)
		FUNCDEF EnterSymbol      ; (private)
		FUNCDEF FetchValue       ; (private)
		FUNCDEF LookUpValue      ; (private)
		FUNCDEF SetValue         ; (private)
		FUNCDEF SymExpand        ; (private)

		FUNCDEF ErrorMsg
		FUNCDEF IsSymbol
		FUNCDEF CurrentEnv
		FUNCDEF GetSpace
		FUNCDEF FreeSpace

		FUNCDEF CreateArgstring
		FUNCDEF DeleteArgstring
		FUNCDEF LengthArgstring
		FUNCDEF CreateRexxMsg
		FUNCDEF DeleteRexxMsg
		FUNCDEF ClearRexxMsg
		FUNCDEF FillRexxMsg
		FUNCDEF IsRexxMsg

		FUNCDEF AddRsrcNode
		FUNCDEF FindRsrcNode
		FUNCDEF RemRsrcList
		FUNCDEF RemRsrcNode
		FUNCDEF OpenPublicPort
		FUNCDEF ClosePublicPort
		FUNCDEF ListNames

		FUNCDEF ClearMem
		FUNCDEF InitList
		FUNCDEF InitPort
		FUNCDEF FreePort

		FUNCDEF CmpString
		FUNCDEF StcToken
		FUNCDEF StrcmpN
		FUNCDEF StrcmpU
		FUNCDEF StrcpyA          ; obsolete
		FUNCDEF StrcpyN
		FUNCDEF StrcpyU
		FUNCDEF StrflipN
		FUNCDEF Strlen
		FUNCDEF ToUpper

		FUNCDEF CVa2i
		FUNCDEF CVi2a
		FUNCDEF CVi2arg
		FUNCDEF CVi2az
		FUNCDEF CVc2x
		FUNCDEF CVx2c

		FUNCDEF OpenF
		FUNCDEF CloseF
		FUNCDEF ReadStr
		FUNCDEF ReadF
		FUNCDEF WriteF
		FUNCDEF SeekF
		FUNCDEF QueueF
		FUNCDEF StackF
		FUNCDEF ExistF

		FUNCDEF DOSCommand
		FUNCDEF DOSRead
		FUNCDEF DOSWrite
		FUNCDEF CreateDOSPkt     ; obsolete
		FUNCDEF DeleteDOSPkt     ; obsolete
		FUNCDEF SendDOSPkt       ; private
		FUNCDEF WaitDOSPkt       ; private
		FUNCDEF FindDevice

		FUNCDEF AddClipNode
		FUNCDEF RemClipNode
		FUNCDEF LockRexxBase
		FUNCDEF UnlockRexxBase
		FUNCDEF CreateCLI
		FUNCDEF DeleteCLI
		FUNCDEF CVs2i
	ENDC
