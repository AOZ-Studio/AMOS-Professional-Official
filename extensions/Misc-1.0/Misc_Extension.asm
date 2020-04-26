* AMOS Professional Misc Extension
* This file is fully public domain.

* Feel free to make a new version!
* Read the manual for more infos.

* Written with DevPac 2 by

* Frank Otto
* Grelckstr. 27
* 22529 Hamburg
* Germany

* E-Mail: FRANK@ZINOCAVE.wind.dbn.sub.org




; half english, half german, that's europe!

ExecBase=4
supervisor = -30
Version         MACRO
                dc.b    "1.0"
                ENDM
ExtNb           equ     23-1
                Include "|AMOS_Includes.s"
DLea            MACRO
                Move.l  Extadr+Extnb*16(a5),\2
                add.w   #\1-MB,\2
                ENDM
DLoad           MACRO
                move.l  Extadr+Extnb*16(a5),\1
                ENDM
Start           dc.l    C_Tk-C_Off
                dc.l    C_Lib-C_Tk
                dc.l    C_Title-C_Lib
                dc.l    C_End-C_Title
                dc.w    0
*               Offsets der Befehle
C_Off           dc.w (L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2
                dc.w (L5-L4)/2,(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
                dc.w (L9-L8)/2,(L10-L9)/2,(L11-L10)/2,(L12-L11)/2
                dc.w (L13-L12)/2,(L14-L13)/2,(L15-L14)/2
*               Befehlsnamen
C_Tk            dc.w    1,0
                dc.b    $80,-1
                
                dc.w    L_DLedOn,-1
                dc.b    "dled o",$80+"n","I",-1         ;Fertig
                
                dc.w    L_DLedOff,-1
                dc.b    "dled of",$80+"f","I",-1        ;Fertig
                
                dc.w    L_DisplayOn,-1
                dc.b    "display o",$80+"n","I",-1      ;Fertig
                
                dc.w    L_DisplayOff,-1
                dc.b    "display of",$80+"f","I",-1     ;Fertig
                
                dc.w    L_MultiOff,-1
                dc.b    "multi of",$80+"f","I",-1       ;Fertig
                
                dc.w    L_MultiOn,-1
                dc.b    "multi o",$80+"n","I",-1        ;Fertig
                
                dc.w    L_MouseOff,-1
                dc.b    "mouse of",$80+"f","I",-1       ;Fertig
                
                dc.w    L_Reset,-1
                dc.b    "rese",$80+"t","I",-1           ;Fertig
                
                dc.w    L_ClearRam,-1
                dc.b    "clear ra",$80+"m","I",-1       ;Fertig
                
                dc.w    L_DiskWait,-1
                dc.b    "disk wai",$80+"t","I",-1       ;Fertig
                
                dc.w    L_PalOn,-1
                dc.b    "pal o",$80+"n","I",-1

                dc.w    L_Fire,-1
                dc.b    "firewai",$80+"t","I",-1

                dc.w    0

******************************************************************
*               Start of library
C_Lib

******************************************************************
*               COLD START
L0      moveq   #ExtNb,d0
        rts

******************************************************************
*
L1

******************************************************************
*       
L2

******************************************************************
L_DisplayOff    equ     3
L3      move.w  #$01a0,$dff096          * Monitor aus
        move.w  #0,$dff180
        rts
******************************************************************
L_DisplayOn     equ     4
L4      move.w  #$81a0,$dff096          * Monitor an
        rts
******************************************************************
L_MultiOff      equ     5
L5      movem.l a3-a6,-(sp)             * Multitasking aus
        move.l  4,a6
        jsr     -132(a6)
        movem.l (sp)+,a3-a6
        rts
******************************************************************
L_MultiOn       equ     6
L6      movem.l a3-a6,-(sp)             * Multitasking an
        move.l  4,a6
        jsr     -138(a6)
        movem.l (sp)+,a3-a6
        rts
******************************************************************
L_DLedOn        equ     7
L7      move.b  #127,$bfd100            ; Laufwerk-LED an
        move.b  #119,$bfd100
        move.b  #0,$bfd100+512
        rts                             
******************************************************************
L_DLedOff       equ     8
L8      move.b  #127,$bfd100            ; Laufwerk-LED aus
        move.b  #119,$bfd100
        move.b  #255,$bfd100+512
        rts
******************************************************************
L_MouseOff      equ     9
L9      move.w  #$20,$dff096            ; Mouse aus
        rts
******************************************************************
CuCuOff dc.b    27,"C0",0
        even
******************************************************************
L_Reset         equ     10
L10     MOVEA.L 4.W,A6
        JSR     -$0096(A6)
        JSR     -$0078(A6)              ; Reset
        CLR.L   4.W
        LEA     $00FC0000.L,A0
        RESET   
        JMP     (A0)
        DC.B    'Nq'
        rts
******************************************************************      
L_ClearRam     equ      11
L11     movem.l         a6,-(sp)        ; No Drivers
        move.l          4,a6
        moveq           #0,d1
        move.l          #99999999,d0
        jsr             -198(a6)
        move.l          d0,a0
        beq.s           glbl
        jsr             -210(a6)
glbl    movem.l         (sp)+,a6
        rts
******************************************************************
L_Fire          equ     12
L12     btst    #07,$bfe001
        bne     L12
        rts
*****************************************************************
L_DiskWait      equ     13
L13
dc:     move.b  $bfe001,d0              ; Diskchange
        and.b   #16,d0
        bne     dc
        movem.l a6,-(sp)
        movea.l 4,a6
Wait    move.l  #500,d1
Wait2   bsr     tests
        sub.l   #1,d1
        bne     Wait2
        jsr     -120(a6)
        lea     $196(a6),a0
        lea     Validate,a1
        jsr     -276(a6)
        move.l  d0,d2
        bne     Check
        lea     $1a4(a6),a0
        lea     Validate,a1
        jsr     -276(a6)
        move.l  d0,d2
Check   jsr     -126(a6)
        tst.l   d2
        bne     Wait
        movem.l (sp)+,a6
        rts
tests   movem.l a0-a6/d0-d7,-(sp)
        movem.l (sp)+,a0-a6/d0-d7
        rts
Validate:
        dc.b    'Validator',0
        even
**********************************************************************
L_PalOn equ     14
L14

Flag_60Hz               RS.B    1
Flag_Color              RS.B    1
Flag_OverScan           RS.B    1
Flag_Enable             RS.B    1
Flag_FatAgnus           RS.B    1
Flag_Resident           RS.B    1
gb_DisplayFlags         EQU     206     ;graphics
gb_DisplayRows          EQU     212
gb_NormalDisplayRows    EQU     216
VBlankFrequency         EQU     530
_LVOCloseLibraryP       EQU     -414
_LVOSumLibraryP         EQU     -426
_LVOOpenLibraryP        EQU     -552
Exebas                  EQU     $4
LIBF_CHANGED            EQU     2
LIB_FLAGS               EQU     14
BEAMCON0                EQU     $1DC
CUSTOM                  EQU     $DFF000
CALL            MACRO
                IFC     'EXEC','\1'
                MOVEA.L (Exebas).W,A6
                ENDC
                IFNC    'EXEC','\1'
                MOVEA.L \1Base,A6
                ENDC
                JSR     _LVO\2(A6)
                ENDM

OPENLIB         MACRO
                LEA     \1Name(PC),A1
                CLR.L   D0
                CALL    EXEC,OpenLibraryP
                MOVE.L  D0,\1Base
                BEQ     \2
                ENDM
CLOSELIB        MACRO
                MOVEA.L \1Base,A1
                CALL    EXEC,CloseLibraryP
                ENDM
Go60            tst.b   Flag_FatAgnus(a0)       ;put system in NTSC mode
                beq.s   .NoFatty
                move.w  #$0000,BEAMCON0!CUSTOM  ;to NTSC please
                bra.s   .Go60
.NoFatty        move.w  #$0000,BEAMCON0!CUSTOM
                bne.s   .Error                  ;not available
.Go60           lea     GFXName(PC),a1          ;modify graphics.library
                clr.l   d0
                CALL    EXEC,OpenLibraryP
                move.l  d0,a1
                move.w  gb_DisplayFlags(a1),d0
                and.b   #%11111011,d0
                or.b    #%00000001,d0
                move.w  d0,gb_DisplayFlags(a1)
                move.w  #200,gb_NormalDisplayRows(a1)
                move.w  #262,gb_DisplayRows(a1)
                or.b    #LIBF_CHANGED,LIB_FLAGS(a1)
                movea.l a1,a2
                CALL    EXEC,SumLibraryP
                movea.l a2,a1
                CALL    EXEC,CloseLibraryP
                move.b  #60,VBlankFrequency(a6)
                or.b    #LIBF_CHANGED,LIB_FLAGS(a6)
                CALL    EXEC,SumLibraryP
                lea     Flags(pc),a0
                st      Flag_Enable(a0)         ;start it
                moveq   #0,d0
                rts
.Error          lea     Flags(pc),a0
                st      Flag_60Hz(a0)
                sf      Flag_Enable(a0)         ;stop it
                moveq   #-1,d0
                rts
GFXName         DC.B    "graphics.library",$0
                EVEN
Flags           DCB.B   8
                rts
************************************************
L15


*               Welcome message                     ;"  
C_Title:        
        dc.b    "AMOSPro Misc Extension V"
        Version
        dc.b    " by Frank Otto (1995)"
        dc.b    0,"$VER: "
        Version
        dc.b    0
        Even

***********************************************************
C_End:  dc.w    0
        even
