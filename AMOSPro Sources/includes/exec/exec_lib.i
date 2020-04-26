	IFND	EXEC_EXEC_LIB_I
EXEC_EXEC_LIB_I SET	1
**
**	$Filename: exec/exec_lib.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	FUNCDEF Supervisor
	FUNCDEF ExitIntr
	FUNCDEF Schedule
	FUNCDEF Reschedule
	FUNCDEF Switch
	FUNCDEF Dispatch
	FUNCDEF Exception
	FUNCDEF InitCode
	FUNCDEF InitStruct
	FUNCDEF MakeLibrary
	FUNCDEF MakeFunctions
	FUNCDEF FindResident
	FUNCDEF InitResident
	FUNCDEF Alert
	FUNCDEF Debug
	FUNCDEF Disable
	FUNCDEF Enable
	FUNCDEF Forbid
	FUNCDEF Permit
	FUNCDEF SetSR
	FUNCDEF SuperState
	FUNCDEF UserState
	FUNCDEF SetIntVector
	FUNCDEF AddIntServer
	FUNCDEF RemIntServer
	FUNCDEF Cause
	FUNCDEF Allocate
	FUNCDEF Deallocate
	FUNCDEF AllocMem
	FUNCDEF AllocAbs
	FUNCDEF FreeMem
	FUNCDEF AvailMem
	FUNCDEF AllocEntry
	FUNCDEF FreeEntry
	FUNCDEF Insert
	FUNCDEF AddHead
	FUNCDEF AddTail
	FUNCDEF Remove
	FUNCDEF RemHead
	FUNCDEF RemTail
	FUNCDEF Enqueue
	FUNCDEF FindName
	FUNCDEF AddTask
	FUNCDEF RemTask
	FUNCDEF FindTask
	FUNCDEF SetTaskPri
	FUNCDEF SetSignal
	FUNCDEF SetExcept
	FUNCDEF Wait
	FUNCDEF Signal
	FUNCDEF AllocSignal
	FUNCDEF FreeSignal
	FUNCDEF AllocTrap
	FUNCDEF FreeTrap
	FUNCDEF AddPort
	FUNCDEF RemPort
	FUNCDEF PutMsg
	FUNCDEF GetMsg
	FUNCDEF ReplyMsg
	FUNCDEF WaitPort
	FUNCDEF FindPort
	FUNCDEF AddLibrary
	FUNCDEF RemLibrary
	FUNCDEF OldOpenLibrary
	FUNCDEF CloseLibrary
	FUNCDEF SetFunction
	FUNCDEF SumLibrary
	FUNCDEF AddDevice
	FUNCDEF RemDevice
	FUNCDEF OpenDevice
	FUNCDEF CloseDevice
	FUNCDEF DoIO
	FUNCDEF SendIO
	FUNCDEF CheckIO
	FUNCDEF WaitIO
	FUNCDEF AbortIO
	FUNCDEF AddResource
	FUNCDEF RemResource
	FUNCDEF OpenResource
	FUNCDEF RawIOInit
	FUNCDEF RawMayGetChar
	FUNCDEF RawPutChar
	FUNCDEF RawDoFmt
	FUNCDEF GetCC
	FUNCDEF TypeOfMem
	FUNCDEF Procure
	FUNCDEF Vacate
	FUNCDEF OpenLibrary
	FUNCDEF InitSemaphore
	FUNCDEF ObtainSemaphore
	FUNCDEF ReleaseSemaphore
	FUNCDEF AttemptSemaphore
	FUNCDEF ObtainSemaphoreList
	FUNCDEF ReleaseSemaphoreList
	FUNCDEF FindSemaphore
	FUNCDEF AddSemaphore
	FUNCDEF RemSemaphore
	FUNCDEF SumKickData
	FUNCDEF AddMemList
	FUNCDEF CopyMem
	FUNCDEF CopyMemQuick

	ENDC	; EXEC_EXEC_LIB_I
