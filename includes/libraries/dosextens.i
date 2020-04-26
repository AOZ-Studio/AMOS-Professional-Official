	IFND	LIBRARIES_DOSEXTENS_I
LIBRARIES_DOSEXTENS_I	SET	1
**
**	$Filename: libraries/dosextens.i $
**	$Release: 1.3 $
**
**	DOS structures not needed for the casual AmigaDOS user 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

     IFND  EXEC_TYPES_I
     INCLUDE "exec/types.i"
     ENDC
     IFND  EXEC_TASKS_I
     INCLUDE "exec/tasks.i"
     ENDC
     IFND  EXEC_PORTS_I
     INCLUDE "exec/ports.i"
     ENDC
     IFND  EXEC_LIBRARIES_I
     INCLUDE "exec/libraries.i"
     ENDC

     IFND  LIBRARIES_DOS_I
     INCLUDE "libraries/dos.i"
     ENDC


* All DOS processes have this STRUCTure
* Create and DeviceProc returns pointer to the MsgPort in this STRUCTure
* Process_addr = DeviceProc(..) - TC_SIZE

 STRUCTURE Process,0
    STRUCT  pr_Task,TC_SIZE
    STRUCT  pr_MsgPort,MP_SIZE	* This is BPTR address from DOS functions
    WORD    pr_Pad		* Remaining variables on 4 byte boundaries
    BPTR    pr_SegList		* Array of seg lists used by this process
    LONG    pr_StackSize	* Size of process stack in bytes
    APTR    pr_GlobVec		* Global vector for this process (BCPL)
    LONG    pr_TaskNum		* CLI task number of zero if not a CLI
    BPTR    pr_StackBase	* Ptr to high memory end of process stack
    LONG    pr_Result2		* Value of secondary result from last call
    BPTR    pr_CurrentDir	* Lock associated with current directory
    BPTR    pr_CIS		* Current CLI Input Stream
    BPTR    pr_COS		* Current CLI Output Stream
    APTR    pr_ConsoleTask	* Console handler process for current window
    APTR    pr_FileSystemTask	* File handler process for current drive
    BPTR    pr_CLI		* pointer to ConsoleLineInterpreter
    APTR    pr_ReturnAddr	* pointer to previous stack frame
    APTR    pr_PktWait		* Function to be called when awaiting msg
    APTR    pr_WindowPtr	* Window pointer for errors
    LABEL   pr_SIZEOF		* Process

* The long word address (BPTR) of this STRUCTure is returned by
* Open() and other routines that return a file.	 You need only worry
* about this STRUCT to do async io's via PutMsg() instead of
* standard file system calls

 STRUCTURE FileHandle,0
   APTR	  fh_Link		* pointer to EXEC message
   APTR	  fh_Interactive	* Boolean; TRUE if interactive handle
   APTR	  fh_Type		* Port to do PutMsg() to
   LONG	  fh_Buf
   LONG	  fh_Pos
   LONG	  fh_End
   LONG	  fh_Funcs
fh_Func1 EQU fh_Funcs
   LONG	  fh_Func2
   LONG	  fh_Func3
   LONG	  fh_Args
fh_Arg1 EQU fh_Args
   LONG	  fh_Arg2
   LABEL  fh_SIZEOF * FileHandle

* This is the extension to EXEC Messages used by DOS
 STRUCTURE DosPacket,0
   APTR	  dp_Link	  * pointer to EXEC message
   APTR	  dp_Port	  * pointer to Reply port for the packet
*			  * Must be filled in each send.
   LONG	  dp_Type	  * See ACTION_... below and
*			  * 'R' means Read, 'W' means Write to the file system
   LONG	  dp_Res1	  * For file system calls this is the result
*			  * that would have been returned by the
*			  * function, e.g. Write ('W') returns actual
*			  * length written
   LONG	  dp_Res2	  * For file system calls this is what would
*			  * have been returned by IoErr()
   LONG	  dp_Arg1
*  Device packets common equivalents
dp_Action  EQU	dp_Type
dp_Status  EQU	dp_Res1
dp_Status2 EQU	dp_Res2
dp_BufAddr EQU	dp_Arg1
   LONG	  dp_Arg2
   LONG	  dp_Arg3
   LONG	  dp_Arg4
   LONG	  dp_Arg5
   LONG	  dp_Arg6
   LONG	  dp_Arg7
   LABEL  dp_SIZEOF * DosPacket

* A Packet does not require the Message to before it in memory, but
* for convenience it is useful to associate the two.
* Also see the function init_std_pkt for initializing this STRUCTure

 STRUCTURE StandardPacket,0
   STRUCT sp_Msg,MN_SIZE
   STRUCT sp_Pkt,dp_SIZEOF
   LABEL  sp_SIZEOF * StandardPacket


* Packet types
ACTION_NIL		EQU	0
ACTION_GET_BLOCK	EQU	2	;OBSOLETE
ACTION_SET_MAP		EQU	4
ACTION_DIE		EQU	5
ACTION_EVENT		EQU	6
ACTION_CURRENT_VOLUME	EQU	7
ACTION_LOCATE_OBJECT	EQU	8
ACTION_RENAME_DISK	EQU	9
ACTION_WRITE		EQU	'W'
ACTION_READ		EQU	'R'
ACTION_FREE_LOCK	EQU	15
ACTION_DELETE_OBJECT	EQU	16
ACTION_RENAME_OBJECT	EQU	17
ACTION_MORE_CACHE	EQU	18
ACTION_COPY_DIR		EQU	19
ACTION_WAIT_CHAR	EQU	20
ACTION_SET_PROTECT	EQU	21
ACTION_CREATE_DIR	EQU	22
ACTION_EXAMINE_OBJECT	EQU	23
ACTION_EXAMINE_NEXT	EQU	24
ACTION_DISK_INFO	EQU	25
ACTION_INFO		EQU	26
ACTION_FLUSH		EQU	27
ACTION_SET_COMMENT	EQU	28
ACTION_PARENT		EQU	29
ACTION_TIMER		EQU	30
ACTION_INHIBIT		EQU	31
ACTION_DISK_TYPE	EQU	32
ACTION_DISK_CHANGE	EQU	33
ACTION_SET_DATE		EQU	34

ACTION_SCREEN_MODE	EQU	994

ACTION_READ_RETURN	EQU	1001
ACTION_WRITE_RETURN	EQU	1002
ACTION_SEEK		EQU	1008
ACTION_FINDUPDATE	EQU	1004
ACTION_FINDINPUT	EQU	1005
ACTION_FINDOUTPUT	EQU	1006
ACTION_END		EQU	1007
ACTION_TRUNCATE		EQU	1022	/* fast file system only */
ACTION_WRITE_PROTECT	EQU	1023	/* fast file system only */

* DOS library node structure.
* This is the data at positive offsets from the library node.
* Negative offsets from the node is the jump table to DOS functions
* node = (STRUCT DosLibrary *) OpenLibrary( "dos.library" .. )

 STRUCTURE DosLibrary,0
    STRUCT  dl_lib,LIB_SIZE
    APTR    dl_Root	     * Pointer to RootNode, described below
    APTR    dl_GV	     * Pointer to BCPL global vector
    LONG    dl_A2	     * Private register dump of DOS
    LONG    dl_A5
    LONG    dl_A6
    LABEL   dl_SIZEOF *	 DosLibrary

*

 STRUCTURE RootNode,0
    BPTR    rn_TaskArray       * [0] is max number of CLI's
*			       * [1] is APTR to process id of CLI 1
*			       * [n] is APTR to process id of CLI n
    BPTR    rn_ConsoleSegment  * SegList for the CLI
    STRUCT  rn_Time,ds_SIZEOF  * Current time
    LONG    rn_RestartSeg      * SegList for the disk validator process
    BPTR    rn_Info	       * Pointer ot the Info structure
    BPTR    rn_FileHandlerSegment * code for file handler 
    LABEL   rn_SIZEOF * RootNode

 STRUCTURE DosInfo,0
    BPTR    di_McName	       * Network name of this machine currently 0
    BPTR    di_DevInfo	       * Device List
    BPTR    di_Devices	       * Currently zero
    BPTR    di_Handlers	       * Currently zero
    APTR    di_NetHand	       * Network handler processid currently zero
    LABEL   di_SIZEOF * DosInfo

* DOS Processes started from the CLI via RUN or NEWCLI have this additional
* set to data associated with them

 STRUCTURE CommandLineInterface,0
    LONG   cli_Result2	       * Value of IoErr from last command
    BSTR   cli_SetName	       * Name of current directory
    BPTR   cli_CommandDir      * Lock associated with command directory
    LONG   cli_ReturnCode      * Return code from last command
    BSTR   cli_CommandName     * Name of current command
    LONG   cli_FailLevel       * Fail level (set by FAILAT)
    BSTR   cli_Prompt	       * Current prompt (set by PROMPT)
    BPTR   cli_StandardInput   * Default (terminal) CLI input
    BPTR   cli_CurrentInput    * Current CLI input
    BSTR   cli_CommandFile     * Name of EXECUTE command file
    LONG   cli_Interactive     * Boolean True if prompts required
    LONG   cli_Background      * Boolean True if CLI created by RUN
    BPTR   cli_CurrentOutput   * Current CLI output
    LONG   cli_DefaultStack    * Stack size to be obtained in long words
    BPTR   cli_StandardOutput  * Default (terminal) CLI output
    BPTR   cli_Module	       * SegList of currently loaded command
    LABEL  cli_SIZEOF	       * CommandLineInterface

* This structure can take on different values depending on whether it is
* a device, an assigned directory, or a volume.	 Below is the structure
* reflecting volumes only.  Following that is the structure representing
* only devices. Following that is the unioned structure representing all
* the values
  
* structure representing a volume 

 STRUCTURE DevList,0
    BPTR	dl_Next			; bptr to next device list
    LONG	dl_Type			; see DLT below
    APTR	dl_Task			; ptr to handler task
    BPTR	dl_Lock			; not for volumes
    STRUCT	dl_VolumeDate,ds_SIZEOF ; creation date
    BPTR	dl_LockList		; outstanding locks
    LONG	dl_DiskType		; 'DOS', etc
    LONG	dl_unused
    BSTR	dl_Name			; bptr to bcpl name
    LABEL	DevList_SIZEOF

* device structure (same as the DeviceNode structure in filehandler.i

 STRUCTURE	 DevInfo,0
    BPTR    dvi_Next
    LONG    dvi_Type
    APTR    dvi_Task
    BPTR    dvi_Lock
    BSTR    dvi_Handler
    LONG    dvi_Stacksize
    LONG    dvi_Priority
    LONG    dvi_Startup
    BPTR    dvi_SegList
    BPTR    dvi_GlobVec
    BSTR    dvi_Name
    LABEL   dvi_SIZEOF

* combined structure for devices, assigned directories, volumes 

 STRUCTURE DosList,0
    BPTR     dol_Next	     ; bptr to next device on lis
    LONG     dol_Type	     ; see DLT below
    APTR     dol_Task	     ; ptr to handler task
    BPTR     dol_Lock

    STRUCT	dol_VolumeDate,0	; creation date (UNION)
    BSTR	dol_Handler		; file name to load if seglist is null
    LONG	dol_StackSize		; stacksize to use when starting process
    LONG	dol_Priority		; task priority when starting process

    STRUCT	dol_LockList,0		; outstanding locks (UNION)
    ULONG	dol_Startup		; startup msg: FileSysStartupMsg
					; for disks

    STRUCT	dol_DiskType,0		; 'DOS', etc (UNION)
    BPTR	dol_SegList		; already loaded code for new task

    BPTR	dol_GlobVec		; BCPL global vector

    BSTR	dol_Name		; bptr to bcpl name
    LABEL	DosList_SIZEOF



* definitions for dl_Type
DLT_DEVICE	EQU	0
DLT_DIRECTORY	EQU	1
DLT_VOLUME	EQU	2


* a lock structure, as returned by Lock() or DupLock()
 STRUCTURE FileLock,0
    BPTR	fl_Link			; bcpl pointer to next lock
    LONG	fl_Key			; disk block number
    LONG	fl_Access		; exclusive or shared
    APTR	fl_Task			; handler task's port
    BPTR	fl_Volume		; bptr to a DeviceList
    LABEL	fl_SIZEOF

	ENDC	; LIBRARIES_DOSEXTENS_I
