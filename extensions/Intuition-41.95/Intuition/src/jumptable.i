;Jump table constants

offset	set	0
nextlab	macro
jt_\1	equ	offset
offset	set	offset+4
	endm

	nextlab	Startup
	nextlab	CloseAll
	nextlab	Quit
	nextlab	GetBankAdr
	nextlab	CreateBank
	nextlab	FindAscr
	nextlab	ClearGadget
	nextlab	FindSprite
	nextlab	FindIcon
	nextlab	FreeImenu
	nextlab	FreeImenuItem
	nextlab	FindImenu
	nextlab	FindImenuItem
	nextlab	FindImenuSub
	nextlab	GetCurWin
	nextlab	SetCoordsRel
	nextlab	AllocMemClear
	nextlab	AllocTmpRas
	nextlab	FreeTmpRas
	nextlab	StrAlloc
	nextlab	StrFree
	nextlab	FindIscr
	nextlab	GetCurIscr
	nextlab	FindIwin
	nextlab	FindIwin2
	nextlab	FindWBIwin
	nextlab	GetCurIwin
	nextlab	GetCurIwin2
	nextlab	GetCurRP
	nextlab	CheckCloseIscr
	nextlab	CloseWin
	nextlab	CloseIscr
	nextlab	CloseIwin
	nextlab	CloseWBIwin
	nextlab	GetCurInput
	nextlab	ConvRawKey
	nextlab	DoEvent
	nextlab	GetKey
	nextlab	GetMouse
	nextlab	GetMenu
	nextlab	LongMul
	nextlab	LongDiv
	nextlab	SetCoords
	nextlab	GetWinFlags
	nextlab	GetSomeWinFlags
	nextlab	SetWinFlags
	nextlab	SetSomeWinFlags
	nextlab	GetActiveWin
	nextlab	StrLen
	nextlab	ReturnString
	nextlab	GetRetStr
	nextlab	FlushRetStr
	nextlab	RTS
	nextlab	AllocRequest
	nextlab	EZRequest
	nextlab	CreatePort
	nextlab	DeletePort
	nextlab	ReadPixel
	nextlab	WritePixel
	nextlab	OpenIwin
	nextlab	OpenIscr
