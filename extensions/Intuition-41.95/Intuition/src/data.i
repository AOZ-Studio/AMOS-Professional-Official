;Data area

	RsReset

IntuitionID	rs.l 1		;Extension ID and data structure version
BranchTable	rs.l 4		;Routines for other extensions; see extutils.a

IntJumpTable	rs.l 1		;Internal jump table

String1		rs.w 1
		rs.b 1

;Lots of byte-size variables.  (Pun intended. :-) )  No particular order.
;Booleans are always either 0 or $FF (-1).

VBLSignal	rs.b 1		;VBL signal bit

Quitting	rs.b 1		;Are we quitting?
TrapErrors	rs.b 1
ErrorTrapped	rs.b 1
Initialised	rs.b 1		;Ugly kludge - get DataBase by calling L_0
IsAGA		rs.b 1
IsECS		rs.b 1
WB20		rs.b 1		;This is a misnomer, since it really tells
				;  about the Kickstart version.
IsNTSC		rs.b 1
LastChar	rs.b 1
NextPublic	rs.b 1		;Open next screen as a public screen?
ScrOpenBehind	rs.b 1		;Open next screen behind all others?
InReset		rs.b 1		;Are we in Default/System routine?
CurIwindowIsWB	rs.b 1		;Is current window on the Workbench?
MouseState	rs.b 1		;Current state of mouse buttons

data_strings	equ __RS
DiskfontName	rs.l 1
DOSName		rs.l 1
GfxName		rs.l 1
IntuitionName	rs.l 1
ReqToolsName	rs.l 1
ConsoleName	rs.l 1
DefReqTitleStr	rs.l 1
PortName	rs.l 1

DiskfontBase	rs.l 1
DOSBase		rs.l 1
GfxBase		rs.l 1
IntuitionBase	rs.l 1
ReqToolsBase	rs.l 1
ViewLord	rs.l 1
ConsoleRequest	rs.b io_size
ConsoleDevice	rs.l 1

SavedA5		rs.l 1
FirstIscreen	rs.l 1
FirstWBIwindow	rs.l 1
CurIscreen	rs.l 1
CurIwindow	rs.l 1
LastActiveWB	rs.l 1		;Last active WB window
LastCode	rs.w 1
LastQual	rs.w 1
NullStr		rs.w 1		;Null string - length 0
FirstString	rs.l 1		;Linked list for L_StrAlloc
LastError	rs.l 1
LastErrorStr	rs.l 1		;null terminated

;Event buffers
KeyBufSize	equ 256*ke_sizeof
KeyBuffer	rs.l 1
KeyBufEnd	rs.l 1
KeyBufPtr	rs.l 1
KeyBufNext	rs.l 1
MenuBufSize	equ 256*ue_sizeof
MenuBuffer	rs.l 1
MenuBufEnd	rs.l 1
MenuBufPtr	rs.l 1
MenuBufNext	rs.l 1
A7Stack		rs.l 8		;Stack for holding value of A7 after PSTART.
;A7StackEnd	equ __RS	;  Used in error trapping.
A7StackEnd	rs.b 0
A7StackPtr	rs.l 1

FileReq		rs.l 1
Filename108	rs.b 108	;Name of file for file requester
FRFileList	rs.l 1		;Current position in file list
FRFileList0	rs.l 1		;Start of file list
FRDir		rs.l 1		;Directory name (for multi-file requesters)
FRDirLen	rs.l 1		;strlen(FRDir)
FontReq		rs.l 1
ScreenModeReq	rs.l 1
ScreenData	rs.b sd_sizeof
DefReqTitle	rs.l 1		;Default requester title

NewScreen	rs.b ens_sizeof
NewWindow	rs.b nw_sizeof
TextAttr	rs.b ta_sizeof
MyUserPort	rs.l 1		;Global UserPort for input
MaxDispWidth	rs.w 1		;Maximum (visible) size of lowres screen.  Not
MaxDispHeight	rs.w 1		;  currently used.
WBPens		rs.w NUMDRIPENS	;Workbench dripens

flStack		rs.l 1		;Flood stack base address
flStackWarn	rs.l 1		;=flStack+1024 - low-stack warning
flStackSize	rs.l 1		;Flood stack "chunk" size.  This is how much
				;  stack we allocate initially, and also how
				;  much extra we allocate when we need more.

LastMenu	rs.w 1		;Last menu, item, subitem selections (-1 means
LastMenuItem	rs.w 1		;  none since last check)
LastMenuSub	rs.w 1

GadgetUndo	rs.l 1		;Common gadget undo buffer
GadgetUndoLen	rs.l 1		;Length of undo buffer

TempBitMap	rs.b bm_sizeof	;Temporary BitMap for AMOS screens

EventData	rs.l 1		;Data for Ievent Wait (e.g. gadget that was
				;  clicked on, key pressed...)

MyTask		rs.l 1		;Address of AMOS's TCB

;datalength	equ __RS
datalength	rs.b 0
