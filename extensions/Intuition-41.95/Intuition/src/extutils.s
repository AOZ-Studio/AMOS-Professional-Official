;Routines for other extensions.  These are listed in a branch table and can
;be called by any other extension which needs access to Intuition data
;structures.  All registers (except for return values) are preserved.
;
;NOTE: this *must* be included as part of L_0!
;
;Branch table definition (also in IntRoutines.i):
;
;   0 - IscreenAdr: get the address of a screen
;		Input:	D0 = screen number
;		Output:	D0 = screen address or NULL
;
;   4 - IwindowAdr: get the address of a window
;		Input:	D0 = window number
;			A0 = screen address, NULL for current screen, or
;			     -1 for Workbench
;		Output:	D0 = window address or NULL
;
;   8 - CurIscreenAdr: get the current screen's address
;		Input:	none
;		Output: D0 = screen address or NULL
;
;  12 - CurIwindowAdr: get the current window's address.
;		Input:	none
;		Output:	D0 = window address or NULL

_IscreenAdr:
	movem.l	d1/a0-a1,-(a7)
	jtcall	FindIscr
	movem.l	(a7)+,d1/a0-a1
	rts

_IwindowAdr:
	movem.l	d1/a0-a2/a4,-(a7)
	dinit	a4
	move.l	d0,d1
	move.l	a0,d0
	bmi	.wbscr
	bne	.gotscr
	dmove.l	CurIscreen,a0
	move.l	a0,d0
	beq	L_NoScr
.gotscr	move.l	sc_UserData(a0),a0
	tst.l	d1
	bne	.find
	move.l	se_BaseWin(a0),d0
	bra	.exit
.find	move.l	se_FirstIwindow(a0),a0
	sub.l	a1,a1
.lp	move.l	a0,d0
	beq	.done
	move.l	wd_UserData(a0),a2
	cmp.l	we_WinNum(a2),d1
	beq	.done
	move.l	a0,a1
	move.l	we_NextIwin(a2),a0
	bra	.lp
.done	move.l	a0,d0
	bra	.exit
.wbscr	move.l	d1,d0
	jtcall	FindWBIwin
.exit	movem.l	(a7)+,d1/a0-a2/a4
	rts

_CurIscreenAdr:
	dmove.l	CurIscreen,d0
	rts

_CurIwindowAdr:
	move.l	a0,-(a7)
	dmove.l	CurIwindow,d0
	bne	.exit
	dtst.l	CurIscreen
	beq	.exit
	dmove.l	CurIscreen,a0
	move.l	sc_UserData(a0),a0
	move.l	se_BaseWin(a0),d0
.exit	move.l	(a7)+,a0
	rts
