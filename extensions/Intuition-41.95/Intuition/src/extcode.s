;Include external code

;BSR here to get the address of the error routine to D0.
L_GetErrorAdr:
	moveq	#-1,d0
	bra	L_CustomError

;Error routines can call this instead of L_0 to avoid out-of-range branches.
L_errGoto0:
	bra	L_0

;BSR here to get the address of the start of the external code to A0.
L_GetExtCode:
	lea	.code+32(pc),a0
	rts

.code:
  ifd CREATOR
    ifd UNREGISTERED
	incbin	"obju/creator/extcode"
    else
	incbin	"obj/creator/extcode"
    endc
  else
    ifd UNREGISTERED
	incbin	"obju/extcode"
    else
	incbin	"obj/extcode"
    endc
  endc
