;---------------------------------------------------------------------
;
;  Published under the MIT Licence
;
;  Copyright (c) 1992 Europress Software
;  Copyright (c) 2020 Francois Lionet
;
;  Permission is hereby granted, free of charge, to any person
;  obtaining a copy of this software and associated documentation
;  files (the "Software"), to deal in the Software without
;  restriction, including without limitation the rights to use,
;  copy, modify, merge, publish, distribute, sublicense, and/or
;  sell copies of the Software, and to permit persons to whom the
;  Software is furnished to do so, subject to the following
;  conditions:
;
;  The above copyright notice and this permission notice shall be
;  included in all copies or substantial portions of the Software.
;
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
;  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
;  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
;---------------------------------------------------------------------

*      Incdir   "i:"

; AMOS Professional stuff

Version MACRO
      	dc.b   "Issue 1.02(AP200)"
      	ENDM

      Include  "+AMOS_Includes.s"


ExtNb          equ   3                 * Number of extension - 1

CStackSize     equ   3000-1            * Must be odd
FirstCode      equ   4                 * Offset of code from start of Segment
C_COLD_START   equ   2                 * Offset from start of code to cold
                                       * start routine (=sizeof(bra.s))

LEN_CPRG_NAME  equ   8                 * length of "c3d.prg\0"
MX_SMOS_PATH   equ   50                * A reasonable path length
MX_CPRG_PATH   equ   MX_SMOS_PATH+LEN_CPRG_NAME


BEARING_A      equ   0
BEARING_B      equ   1
BEARING_R      equ   2
BEARING_CALC   equ   8
BEARING_OB_OB  equ   0
BEARING_OB_PT  equ   4

TX_XCOORD      equ   0
TX_YCOORD      equ   1
TX_ZCOORD      equ   2
TX_CALCULATE   equ   4

ANIM_ABS       equ   0
ANIM_REL       equ   1

ERR_CANT_LOAD_CODE equ 28  * Must be consistant with error messages below

******************************************************************************
*                     Imports from C 3d functions
*   Each equate corresponds to a C function whose address is given in the
*   corresponding position in the look-up table at the start of 'c3d.s'.
*   Any changes to these equates must be mirrored in the look-up table.

TD_DEBUG            equ     0
TD_SCREEN_HEIGHT    equ     1
TD_BACKGROUND       equ     2
TD_CLS              equ     3
TD_OBJECT           equ     4
TD_LOAD             equ     5
TD_SET_DIR          equ     6
TD_CLEAR_ALL        equ     7
TD_KILL             equ     8
TD_MOVE_XYZ         equ     9
TD_MOVE_ABS         equ     10
TD_MOVE_REL         equ     11
TD_POSITION_XYZ     equ     12
TD_ANGLE_ABC        equ     13
TD_ANGLE_ABS        equ     14
TD_ANGLE_REL        equ     15
TD_ATTITUDE_ABC     equ     16
TD_VISIBLE          equ     17
TD_RANGE            equ     18
TD_ANIM             equ     19
TD_ANIM_POINT       equ     20
TD_REDRAW           equ     21
TD_SET_ZONE         equ     22
TD_COLLIDE          equ     23
TD_ZONE_XYZR        equ     24
TD_WORLD_XYZ        equ     25
TD_VIEW_XYZ         equ     26
TD_SCREEN_XY        equ     27
TD_INIT             equ     28      * Not used in AMOS
TD_FORWARD          equ     29
TD_FACE             equ     30
TD_BEARING_ABR      equ     31

TD_SURFACE          equ     32
TD_SURFACE_POINTS   equ     33
TD_KEEP             equ     34
TD_ADVANCED         equ     35
TD_PRIORITY         equ     (TD_ADVANCED+1)
TD_PRAGMA_STATUS    equ     (TD_PRIORITY+1)
TD_PRAGMA           equ     (TD_PRAGMA_STATUS+1)
TD_DELETE_ZONE      equ     (TD_PRAGMA+1)
TD_SETCOL           equ     (TD_DELETE_ZONE+1)

TD_ROTATE           equ     (TD_SETCOL+1)  ; Test 3/92

N_SPARES            equ     9    ; 10

* RESET_3D            equ     (TD_SETCOL+N_SPARES+1)
RESET_3D            equ     (TD_ROTATE+N_SPARES+1)

QUIT_3D             equ     (RESET_3D+1)
NUM_LIB_ROUTINES    equ     (QUIT_3D+1)

******************************************************************************
*   CallC and CallCP are macros intended to simplify entry to C from
*   library routines. The macros calculate the start of the compiler
*   library 'data' area label (NOT the 68000 data section) and then jumps
*   to one of the set up routines:
*       Macro       Set up routine                  Notes
*       -----       --------------                  -----
*       CallC       SetUpC          Normal parameters expected.
*       CallCP      SetUpCP         Passes an extra parameter to the C function
*                                   as its first parameter.
*       CallCPM                     Not used in AMOS (see STOS version)

CallC:      MACRO
            move.l  ExtAdr+ExtNb*16(a5),a2      * Get address of Data zone
            jmp     SetUpC-Data(a2)
            ENDM

CallCP:     MACRO
            move.l  ExtAdr+ExtNb*16(a5),a2      * Get address of Data zone
            jmp     SetUpCP-Data(a2)
            ENDM

******************************************************************************
*                           Compiler Header
*                           ===============

*           Offsets to the three main sections of the Library

Start       dc.l     TokenTable-Catalogue    * Offset to Token Table
            dc.l     Library-TokenTable      * Offset to Library
            dc.l     Title-Library           * Offset to Welcome message
            dc.l     End-Title               * Offset to end of extension

*  This flag forces the compiler to include Library function 0 in all
*  compiled programs. I think it should be off for 3D.
            dc.w     0


*       Catalogue of the lengths of all compiler library functions, in 3D
*       these are all just entry points to the C environment code.


Catalogue:
   dc.w    (IDummy-Library)>>1          * 1  Dummy - for expansion
   dc.w    (IDebug-IDummy)>>1           * 2  Td Debug
   dc.w    (ILoad-IDebug)>>1            * 3  Td Load
   dc.w    (IClearAll-ILoad)>>1         * 4  Td Clear All
   dc.w    (IObject-IClearAll)>>1       * 5  Td Object
   dc.w    (IScrHeight-IObject)>>1      * 6  Td Screen height
   dc.w    (FVisible-IScrHeight)>>1     * 7
   dc.w    (FRange-FVisible)>>1         * 8
   dc.w    (IKill-FRange)>>1            * 9
   dc.w    (IMove_x-IKill)>>1           * 10
   dc.w    (IMove_y-IMove_x)>>1         * 11
   dc.w    (IMove_z-IMove_y)>>1         * 12
   dc.w    (IMove_rel-IMove_z)>>1       * 13
   dc.w    (IMove_abs-IMove_rel)>>1     * 14
   dc.w    (IForward-IMove_abs)>>1      * 15
   dc.w    (FPosition_x-IForward)>>1    * 16
   dc.w    (FPosition_y-FPosition_x)>>1 * 17
   dc.w    (FPosition_z-FPosition_y)>>1 * 18
   dc.w    (IAngle_A-FPosition_z)>>1    * 19
   dc.w    (IAngle_B-IAngle_A)>>1       * 20
   dc.w    (IAngle_C-IAngle_B)>>1       * 21
   dc.w    (IAngle_rel-IAngle_C)>>1     * 22
   dc.w    (IAngle_abs-IAngle_rel)>>1   * 23
   dc.w    (FAttitudeA-IAngle_abs)>>1   * 24
   dc.w    (FAttitudeB-FAttitudeA)>>1   * 25
   dc.w    (FAttitudeC-FAttitudeB)>>1   * 26
   dc.w    (IFaceObs-FAttitudeC)>>1     * 27
   dc.w    (IFaceObPt-IFaceObs)>>1      * 28
   dc.w    (FBearA-IFaceObPt)>>1        * 29
   dc.w    (FBearAObOb-FBearA)>>1       * 30
   dc.w    (FBearAObPt-FBearAObOb)>>1   * 31
   dc.w    (FBearB-FBearAObPt)>>1       * 32
   dc.w    (FBearBObOb-FBearB)>>1       * 33
   dc.w    (FBearBObPt-FBearBObOb)>>1   * 34
   dc.w    (FBearR-FBearBObPt)>>1       * 35
   dc.w    (FBearRObOb-FBearR)>>1       * 36
   dc.w    (FBearRObPt-FBearRObOb)>>1   * 37
   dc.w    (IAnimRel-FBearRObPt)>>1     * 38
   dc.w    (FAnimPtX-IAnimRel)>>1       * 39
   dc.w    (FAnimPtY-FAnimPtX)>>1       * 40
   dc.w    (FAnimPtZ-FAnimPtY)>>1       * 41
   dc.w    (IAnim-FAnimPtZ)>>1          * 42
   dc.w    (IRedraw-IAnim)>>1           * 43
   dc.w    (ISetZone-IRedraw)>>1        * 44
   dc.w    (FCollide1-ISetZone)>>1      * 45
   dc.w    (FCollide2-FCollide1)>>1     * 46
   dc.w    (FZoneX-FCollide2)>>1        * 47
   dc.w    (FZoneY-FZoneX)>>1           * 48
   dc.w    (FZoneZ-FZoneY)>>1           * 49
   dc.w    (FZoneR-FZoneZ)>>1           * 50
   dc.w    (FWorldX-FZoneR)>>1          * 51
   dc.w    (FWorldXxyz-FWorldX)>>1      * 52
   dc.w    (FWorldY-FWorldXxyz)>>1      * 53
   dc.w    (FWorldYxyz-FWorldY)>>1      * 54
   dc.w    (FWorldZ-FWorldYxyz)>>1      * 55
   dc.w    (FWorldZxyz-FWorldZ)>>1      * 56
   dc.w    (FViewX-FWorldZxyz)>>1       * 57
   dc.w    (FViewXxyz-FViewX)>>1        * 58
   dc.w    (FViewY-FViewXxyz)>>1        * 59
   dc.w    (FViewYxyz-FViewY)>>1        * 60
   dc.w    (FViewZ-FViewYxyz)>>1        * 61
   dc.w    (FViewZxyz-FViewZ)>>1        * 62
   dc.w    (FScreenX-FViewZxyz)>>1      * 63
   dc.w    (FScreenXxyz-FScreenX)>>1    * 64
   dc.w    (FScreenY-FScreenXxyz)>>1    * 65
   dc.w    (FScreenYxyz-FScreenY)>>1    * 66
   dc.w    (IBackGnd-FScreenYxyz)>>1    * 67 Plane=0
   dc.w    (IBackGndPl-IBackGnd)>>1     * 68 Plane is a parameter
   dc.w    (ISetDir-IBackGndPl)>>1      * 69
   dc.w    (ISurfPtsOff-ISetDir)>>1     * 70
   dc.w    (ISurfacePts-ISurfPtsOff)>>1 *
   dc.w    (ISurface-ISurfacePts)>>1    *
   dc.w    (ICls-ISurface)>>1           *
   dc.w    (IKeepOn-ICls)>>1            * 73
   dc.w    (IKeepOff-IKeepOn)>>1        * 4
   dc.w    (FAdvanced-IKeepOff)>>1      * 75
   dc.w    (IQuit-FAdvanced)>>1         *

   * New in Issue 1.30 28/6/91 for Tony
   dc.w    (IPriority-IQuit)>>1         * Td Priority n,pri
   dc.w    (FPragmaStat-IPriority)>>1   * = Td Pragma Status(param0,param1)
   dc.w    (IPragma-FPragmaStat)>>1     * Td Pragma(param0,param1)

   * New in Issue 1.50
   dc.w    (IDelZone-IPragma)>>1          * 9

   * New in issue 1.90
   dc.w    (ISetCol-IDelZone)>>1           * 80

*   dc.w    (Spare0-ISetCol)>>1           * 81 Spare - for expansion
   dc.w    (IRotate-ISetCol)>>1           * New 3/92
   dc.w    (Spare0-IRotate)>>1           *

   dc.w    (Spare1-Spare0)>>1           * 2
   dc.w    (Spare2-Spare1)>>1           * 83
   dc.w    (Spare3-Spare2)>>1           * 4
   dc.w    (Spare4-Spare3)>>1           * 5
   dc.w    (Spare5-Spare4)>>1           * 6
   dc.w    (Spare6-Spare5)>>1           *
   dc.w    (Spare7-Spare6)>>1           * 8
   dc.w    (Spare8-Spare7)>>1           * 89

*   dc.w    (Spare9-Spare8)>>1           * 0
*   dc.w    (ErrScrNotOpen-Spare9)>>1    * 91 Screen not opened error message

   dc.w    (ErrScrNotOpen-Spare8)>>1    * 91 Screen not opened error message


   dc.w    (ErrCustomMsg-ErrScrNotOpen)>>1 * 22.0 Custom errors with messages
   dc.w    (ErrCustom-ErrCustomMsg)>>1  * 92.1 Custom errors no messages
   dc.w    (LibraryEnd-ErrCustom)>>1    * End Of Library !!

*       Parameter check tables for use during compilation

TokenTable:
ExTk:       dc.w     1,0               * Fake instruction
            dc.b     $80,-1

            dc.w     L_IDebug,1        * Debug
            dc.b     "td debu","g"+$80,"I0",-1

            dc.w     L_ILoad,1
            dc.b     "td loa","d"+$80,"I2",-1

            dc.w     L_IClearAll,1
            dc.b     "td clear al","l"+$80,"I",-1

            dc.w     L_IObject,1       * Td Object
            dc.b     "td objec","t"+$80,"I0,2,0,0,0,0,0,0",-1

            dc.w     L_IScrHeight,1    * Screen height
            dc.b     "td screen heigh","t"+$80,"I0",-1

            dc.w     1,L_FVisible        * Object visible function
            dc.b     "td visibl","e"+$80,"00",-1

            dc.w     1,L_FRange          * Object range function
            dc.b     "td rang","e"+$80,"00,0",-1

            dc.w     L_IKill,1         * Kill Object n instruction
            dc.b     "td kil","l"+$80,"I0",-1   * 1 param

            dc.w     L_IMove_x,1       * Move x instruction
            dc.b     "td move ","x"+$80,"I0,2",-1

            dc.w     L_IMove_y,1       * Move y instruction
            dc.b     "td move ","y"+$80,"I0,2",-1

            dc.w     L_IMove_z,1       * Move z instruction
            dc.b     "td move ","z"+$80,"I0,2",-1

            dc.w     L_IMove_rel,1     * Move relative instructon
            dc.b     "td move re","l"+$80,"I0,0,0,0",-1

            dc.w     L_IMove_abs,1     * Move absolute instructon
            dc.b     "td mov","e"+$80,"I0,0,0,0",-1

            dc.w     L_IForward,1      * Move forward instructon
            dc.b     "td forwar","d"+$80,"I0,0",-1

            dc.w     1,L_FPosition_x     * Td Position X function
            dc.b     "td position ","x"+$80,"00",-1

            dc.w     1,L_FPosition_y     * Td Position Y function
            dc.b     "td position ","y"+$80,"00",-1

            dc.w     1,L_FPosition_z     * Td Position Z function
            dc.b     "td position ","z"+$80,"00",-1

            dc.w     L_IAngle_A,1      * Td Angle A instruction
            dc.b     "td angle ","a"+$80,"I0,2",-1

            dc.w     L_IAngle_B,1      * Td Angle B instruction
            dc.b     "td angle ","b"+$80,"I0,2",-1

            dc.w     L_IAngle_C,1      * Td Angle C instruction
            dc.b     "td angle ","c"+$80,"I0,2",-1

            dc.w     L_IAngle_rel,1    * Td Angle rel n A,B,C
            dc.b     "td angle re","l"+$80,"I0,0,0,0",-1

            dc.w     L_IAngle_abs,1    * Td Angle n A,B,C
            dc.b     "td angl","e"+$80,"I0,0,0,0",-1

            dc.w     1,L_FAttitudeA      * Td Attitude A instruction
            dc.b     "td attitude ","a"+$80,"00",-1

            dc.w     1,L_FAttitudeB      * Td Attitude B instruction
            dc.b     "td attitude ","b"+$80,"00",-1

            dc.w     1,L_FAttitudeC      * Td Attitude C instruction
            dc.b     "td attitude ","c"+$80,"00",-1

            dc.w     L_IFaceObs,1      * Td Face n1,n2 function
            dc.b     "!td fac","e"+$80,"I0,0",-2

            dc.w     L_IFaceObPt,1     * Td Face n,x,y,z function
            dc.b     $80,"I0,0,0,0",-1

            dc.w     1,L_FBearA        * =Td Bearing A
            dc.b     "!td bearing ","a"+$80,"0",-2

            dc.w     1,L_FBearAObOb    * =Td Bearing A(n1,n2)
            dc.b     $80,"00,0",-2

            dc.w     1,L_FBearAObPt    * =Td Bearing A(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FBearB        * =Td Bearing B
            dc.b     "!td bearing ","b"+$80,"0",-2

            dc.w     1,L_FBearBObOb    * =Td Bearing B(n1,n2)
            dc.b     $80,"00,0",-2

            dc.w     1,L_FBearBObPt    * =Td Bearing B(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FBearR        * =Td Bearing R
            dc.b     "!td bearing ","r"+$80,"0",-2

            dc.w     1,L_FBearRObOb    * =Td Bearing R(n1,n2)
            dc.b     $80,"00,0",-2

            dc.w     1,L_FBearRObPt    * =Td Bearing R(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     L_IAnimRel,1     * Td anim rel instruction
            dc.b     "td anim re","l"+$80,"I0,0,0,0,0,0",-1

            dc.w     1,L_FAnimPtX   * =Td Anim Point X/Y/Z(n,pn)
            dc.b     "td anim point ","x"+$80,"00,0",-1

            dc.w     1,L_FAnimPtY
            dc.b     "td anim point ","y"+$80,"00,0",-1

            dc.w     1,L_FAnimPtZ
            dc.b     "td anim point ","z"+$80,"00,0",-1

            dc.w     L_IAnim,1         * Td anim instruction
            dc.b     "td ani","m"+$80,"I0,0,0,0,0,0",-1

            dc.w     L_IRedraw,1      * Td Redraw instruction
            dc.b     "td redra","w"+$80,"I",-1

            dc.w     L_ISetZone,1     * Set zone instruction
            dc.b     "td set zon","e"+$80,"I0,0,0,0,0,0",-1

            dc.w     1,L_FCollide1     * =Td Collide(n)
            dc.b     "!td collid","e"+$80,"00",-2

            dc.w     1,L_FCollide2     * =Td Collide(n1,n2)
            dc.b     $80,"00,0",-1

            dc.w     1,L_FZoneX        * Td Zone X function
            dc.b     "td zone ","x"+$80,"00,0",-1

            dc.w     1,L_FZoneY        * Td Zone X function
            dc.b     "td zone ","y"+$80,"00,0",-1

            dc.w     1,L_FZoneZ        * Td Zone X function
            dc.b     "td zone ","z"+$80,"00,0",-1

            dc.w     1,L_FZoneR        * Td Zone X function
            dc.b     "td zone ","r"+$80,"00,0",-1

            dc.w     1,L_FWorldX       * =Td World X
            dc.b     "!td world ","x"+$80,"0",-2

            dc.w     1,L_FWorldXxyz    * =Td World X(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FWorldY       * =Td World Y
            dc.b     "!td world ","y"+$80,"0",-2

            dc.w     1,L_FWorldYxyz    * =Td World Y(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FWorldZ       * =Td World Z
            dc.b     "!td world ","z"+$80,"0",-2

            dc.w     1,L_FWorldZxyz    * =Td World Z(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FViewX        * =Td View X
            dc.b     "!td view ","x"+$80,"0",-2

            dc.w     1,L_FViewXxyz     * =Td View X(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FViewY        * =Td View Y
            dc.b     "!td view ","y"+$80,"0",-2

            dc.w     1,L_FViewYxyz     * =Td View Y(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FViewZ        * =Td View Z
            dc.b     "!td view ","z"+$80,"0",-2

            dc.w     1,L_FViewZxyz     * =Td View Z(n,x,y,z)
            dc.b     $80,"00,0,0,0",-1

            dc.w     1,L_FScreenX      * =Td Screen X
            dc.b     "!td screen ","x"+$80,"0",-2

            dc.w     1,L_FScreenXxyz   * =Td Screen X(x,y,z)
            dc.b     $80,"00,0,0",-1

            dc.w     1,L_FScreenY      * =Td Screen Y
            dc.b     "!td screen ","y"+$80,"0",-2

            dc.w     1,L_FScreenYxyz   * =Td Screen Y(x,y,z)
            dc.b     $80,"00,0,0",-1

            dc.w     L_IBackGnd,1      * Background, plane=0
            dc.b     "!td backgroun","d"+$80,"I0,0,0,0,0t0,0",-2

            dc.w     L_IBackGndPl,1    * Background, plane is last parameter
            dc.b     $80,"I0,0,0,0,0t0,0,0",-1

            dc.w     L_ISetDir,1       * Object directory function
            dc.b     "td di","r"+$80,"I2",-1

            dc.w     L_ISurfPtsOff,1
            dc.b     "td surface points of","f"+$80,"I",-1

            dc.w     L_ISurfacePts,1   * Td Surface Points p0,p1,p2,p3
            dc.b     "td surface point","s"+$80,"I0,0,0,0",-1

            dc.w     L_ISurface,1      * Td Surface S$,sb,sf to t,tb,ts,r
            dc.b     "td surfac","e"+$80,"I2,0,0t0,0,0,0",-1

            dc.w     L_ICls,1          * Td Cls
            dc.b     "td cl","s"+$80,"I",-1

            dc.w     L_IKeepOn,1       * Keep objects loaded
            dc.b     "td keep o","n"+$80,"I",-1

            dc.w     L_IKeepOff,1      * Dont keep objects loaded
            dc.b     "td keep of","f"+$80,"I",-1

            dc.w     1,L_FAdvanced     * Td Advanced n
            dc.b     "td advance","d"+$80,"00",-1

            dc.w     L_IQuit,1         * Td Quit
            dc.b     "td qui","t"+$80,"I",-1

            dc.w     L_IPriority,1     * Td Priority n,pri
            dc.b     "td priorit","y"+$80,"I0,0",-1

            dc.w     1,L_FPragmaStat   * =Td Pragma Status(param0,param1)
            dc.b     "td pragma statu","s"+$80,"00,0",-1

            dc.w     L_IPragma,1       * Td Pragma param0,param1
            dc.b     "td pragm","a"+$80,"I0,0",-1

            dc.w     L_IDelZone,1      * Td Delete Zone n,zn
            dc.b     "td delete zon","e"+$80,"I0,0",-1

            dc.w     L_ISetCol,1       * Td Set Colour n,b,c
            dc.b     "td set colou","r"+$80,"I0,0,0",-1

            dc.w     L_IRotate,1       * Td Rotate n,A,B,C
            dc.b     "td rotat","e"+$80,"I0,0,0,0",-1

            dc.w     0                 * End of token table


******************************************************************************
*                               LIBRARY
******************************************************************************

*** Cold Start
* The first library function (L0) is the extension cold start routine.
* Various addresses are saved in the AMOS extension area and memory
* is allocated for the C stack.
* The 3d reset routine reset_3d is now called after the 3d code segment
* has been loaded.

Library:
	cmp.l	#"APex",d1
	bne	BadVer

* Save extension addresses in AMOS extension table
            lea      Data(pc),a2        * Stash data zone
            move.l   a2,ExtAdr+ExtNb*16(a5)
            lea      ExDef(pc),a0       * Stash 'default' routine
            move.l   a0,ExtAdr+ExtNb*16+4(a5)
            lea      ExEnd(pc),a0       * Stash 'end' routine
            move.l   a0,ExtAdr+ExtNb*16+8(a5)
            move.l   a5,AmosA5(a2)      * Stash Amos a5 for ___aprintf

* Prend la ligne de commande (le path)
	lea	CmdPath(pc),a0
	clr.b	(a0)
.Space	cmp.b	#" ",(a1)+
	beq.s	.Space
	subq.l	#1,a1
	cmp.b	#"-",(a1)+
	bne.s	.NoCom
	move.b	(a1)+,d0
	cmp.b	#"f",d0
	beq.s	.Copy
	cmp.b	#"F",d0
	bne.s	.NoCom
.Copy	move.b	(a1)+,(a0)+
	bne.s	.Copy
.NoCom
* Allocate some stack space for C
            move.l   #CStackSize,d0
            move.l   #Clear,d1
            Execall  AllocMem
            tst.l    d0
            bne.s    StackMemOk
            moveq    #-1,d0              * Error condition
	    sub.l    a0,a0
            bra.s    StackErr
StackMemOk: move.l   d0,CStackEnd(a2)    * Stack end = low address
            add.l    #CStackSize-1,d0
            move.l   d0,CStackStart(a2)  * Stack start = high address
            moveq    #ExtNb,d0           * Returns NUMBER OF EXTENSION
	    move.w   #$0110,d1		 * Current version of AMOSPro
StackErr:   rts
* Bad version
BadVer	lea	.BadMes(pc),a0		Error message
	moveq	#-1,d0			Stop loading
	rts
.BadMes	dc.b	"3d extension only works with AMOSPro 1.10 and over.",0
	even

*** Default/Run reset
* Everytime AMOS is reset or run it will call this code. If the C code
* segment is loaded reset_3d() is called.

ExDef:
	    lea      Data(pc),a2
            tst.l    CPrgSeg(a2)
            beq.s    NoCProgram           * C isn't loaded - Do nothing

*         illegal
            move.l   a4,-(sp)             * Stash a4 for AMOS
            move.l   sp,AmosStack(a2)     * Set up 'C' stack
            move.l   CStackStart(a2),sp
            move.l   CLinkerDB(a2),a4     * C V5.10 base relative addressing
            move.l   CTable(a2),a0
            move.l   RESET_3D*4(a0),a0
            jsr      (a0)                 * Jump to 'C' function
            move.l   AmosStack(a2),sp     * Restore AMOS stack
            move.l   (sp)+,a4             * ...and a4
NoCProgram: rts

*** AMOS quit routine
*
* This function is called when AMOS quits. If present the C code segment
* is unloaded via UnLoadCPrg. In all cases the memory allocated as C stack
* space is freed.

ExEnd:      lea      Data(pc),a2
            bsr      UnLoadCPrg
            move.l   CStackEnd(a2),a1
            move.l   #CStackSize,d0
            ExeCall  FreeMem
            rts

*** C set up routines.
*
* Either SetUpC or SetUpCP is by called its corresponding CallXX macro.
* The functions install the C stack and environment, place the Amos
* parameters onto the C stack and then jsr to the relevant C function.
* On return from C the Amos stack and environment is restored and,
* if required, the function return value passed back to Amos.

SetUpC:     moveq    #-1,d2              * Flag no extra parameters
SetUpCP:    tst.l    CPrgSeg(a2)
            bne.s    CPrgOk
            bsr      LoadCPrg
CPrgOk:     move.l   CStackStart(a2),a1   * a1=C C stack base
            jmp      0(a2,d0.w)

CSurface:   move.l   (a3)+,-(a1)          * Td Surface s$,n,n to n,n,n,n
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,a0
            move.w   (a0)+,d3
            ext.l    d3
            move.l   a0,-(a1)
            move.l   d3,-(a1)
            bra.s    CNoneNoRet

CObject:    move.l   (a3)+,-(a1)          * Td Object n,"s$",n,n,n,n,n,n
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,-(a1)
            move.l   (a3)+,a0
            move.w   (a0)+,d3
            ext.l    d3
            move.l   a0,-(a1)
            move.l   d3,-(a1)
            move.l   (a3)+,-(a1)
            bra.s    CNoneNoRet

CIntStrNoR: move.l  (a3)+,a0
            move.w  (a0)+,d3
            ext.l   d3
            move.l  a0,-(a1)
            move.l  d3,-(a1)
            bra.s   CIntNoRet

CStrNoRet:  move.l  (a3)+,a0
            move.w  (a0)+,d3
            ext.l   d3
            move.l  a0,-(a1)
            move.l  d3,-(a1)
            bra.s   CNoneNoRet

C8IntNoRet: move.l  (a3)+,-(a1)
            move.l  (a3)+,-(a1)
C6IntNoRet: move.l  (a3)+,-(a1)
            move.l  (a3)+,-(a1)
C4IntNoRet: move.l  (a3)+,-(a1)
C3IntNoRet: move.l  (a3)+,-(a1)
C2IntNoRet: move.l  (a3)+,-(a1)
CIntNoRet:  move.l  (a3)+,-(a1)
CNoneNoRet: tst.l    d2
            bmi.s    NoExtraPar1
            move.l   d2,-(a1)
NoExtraPar1:movem.l  a3-a6,-(sp)           * Stash registers on AMOS stack
            move.l   sp,AmosStack(a2)
            move.l   a1,sp
            move.l   CLinkerDB(a2),a4      * C V5.10 base relative addressing
            move.l   CTable(a2),a0
            move.l   0(a0,d1.w),a0
            jsr      (a0)
            move.l   AmosStack(a2),sp
            movem.l  (sp)+,a3-a6
            rts

C4IntRInt:  move.l  (a3)+,-(a1)
C3IntRInt:  move.l  (a3)+,-(a1)
C2IntRInt:  move.l  (a3)+,-(a1)
CIntRInt:   move.l  (a3)+,-(a1)
CNoneRInt:  tst.w   d2
            bmi.s   NoExtraPar2
            move.l  d2,-(a1)
NoExtraPar2:movem.l  a3-a6,-(sp)           * Stash registers on AMOS stack
            move.l   sp,AmosStack(a2)
            move.l   a1,sp
            move.l  CTable(a2),a0
            move.l   CLinkerDB(a2),a4      * C V5.10 base relative addressing
            move.l  0(a0,d1.w),a0
            jsr     (a0)
            move.l  AmosStack(a2),sp
            movem.l (sp)+,a3-a6
            move.l   d0,d3
            moveq    #0,d2
            rts

*** Load C code segment
*
* On entry a2 must contain the address of the extension data area.
*
* The main 3D C code is loaded here. At the start of the newly loaded code
* segment is a small machine code module, this contains a jump table to all
* the C td_ functions. In order to find the address of the jump table, the
* procedure below jsrs to the start of the new segment, on return a0
* contains the jump table start address. In order for C to call various
*
* AMOS functions two addresses are passed to the new segment:
*     a0.l - __smos_error, invokes an AMOS error message
*     a1.l - ___aprintf, prints a string to the current AMOS window.
*
*     d0.l - DosBase
*     d1.l - GfxBase
*
* On Exit
*     a0   - C Jump table address
*     a1   - C LinkerDB for C V5.10 compatibility
*
* N.B. LoadSeg returns a BCPL pointer (!)

LoadCPrg:   movem.l  d0-d2/a3-a6,-(sp)       * d0-d2 for 3d, a3-a6 for AMOS

	bsr	GetAMOSPath1		Essai avec la command line
	beq.s	.Skip
	bsr.s	TryToLoadC
	bne.s	CLoadedOK
.Skip	bsr	GetAMOSPath2		Essai dans APSystem
	beq.s	.Skip2
	bsr.s	TryToLoadC
	bne.s	CLoadedOK

* Try to find c3d.lib using the default paths
.Skip2      lea      DefPaths(pc),a3
            moveq.w  #2,d2                   * 3 Names, -1 for dbeq
NextDefPath:move.w   (a3)+,a1                * New path string in a1
            lea      0(a2,a1.w),a1
            lea      CPrgPath(pc),a0
CopyPath:   move.b   (a1)+,(a0)+
            bne.s    CopyPath                * NUL ("\0") terminated strings
            bsr.s    TryToLoadC
            dbne     d2,NextDefPath
	    beq.s    CantLoadPrg

* Code loaded. BCPL code pointer in d0
CLoadedOk:  move.l   d0,CPrgSeg(a2)
            asl.l    #2,d0                   * d0=3d Code=(d0<<2)+4
            addq.l   #FirstCode,d0
            move.l   d0,a4
            move.l   sp,AmosStack(a2)
            move.l   CStackStart(a2),sp
            lea      ___aprintf(pc),a0
            lea      __smos_error(pc),a1
            move.l   DosBase(a5),d0
            move.l   T_GfxBase(a5),d1
            jsr      C_COLD_START(a4)        * 3d initialisation
            move.l   a0,CTable(a2)
            move.l   a1,CLinkerDB(a2)        * Stash C V5.10 base address
            move.l   AmosStack(a2),sp
            movem.l  (sp)+,d0-d2/a3-a6
            rts

* Cant find C run time library, all we can do is quit
CantLoadPrg:moveq    #ERR_CANT_LOAD_CODE,d0  * Error number
            moveq    #0,d1                   * Error not trappable
            moveq    #ExtNb,d2
            RBra     L_Custom

* Try to load the code using LoadSeg
TryToLoadC: lea      CPrgPath(pc),a0
            move.l   a0,d1
            move.l   ExecBase,a6
            move.l   DosBase(a5),a0
            jsr      DosLoadSeg(a0)          * d0=BCPL Code Segment Pointer
            tst.l    d0                      * ...or NULL
            rts

; Path found in command line...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetAMOSPath1
	lea     CmdPath(pc),a0
	tst.b	(a0)
	beq	BadAMOSPath
	move.l  a0,a1
.Loop	tst.b   (a0)+
	bne.s 	.Loop
	move.l  a0,d0                   * Is the path too long ?
	sub.l   a1,d0
	cmp.l   #MX_CPRG_PATH,d0
	bcc.s   BadAMOSPath
	bra.s	PathCopy

; Path found in normal system path
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetAMOSPath2
	lea     Sys_Pathname(a5),a0
	move.l  a0,a1
.Loop	tst.b   (a0)+
        bne.s 	.Loop
	move.l  a0,d0                   * Is the path too long ?
        sub.l   a1,d0
        cmp.l   #MX_CPRG_PATH,d0
        bcc.s   BadAMOSPath             * ...yes,fail !

; Copy the path +/ name
; ~~~~~~~~~~~~~~~~~~~~~
PathCopy
	subq     #2,a0
	lea      CPrgPath(pc),a3         * Copy Sys_Pathname -> CPrgPath
.Loop	move.b   (a1)+,(a3)+
	cmpa.l   a1,a0
	bcc.s    .Loop
CopyName
 	lea      CPrgName(pc),a0
.Loop	move.b   (a0)+,(a3)+             * Copy name (and "\0")
        bne.s    .Loop
        moveq    #-1,d0                  * Ok, return(TRUE);
        rts
BadAMOSPath
	moveq    #0,d0                   * Fail, return(FALSE);
        rts

**** Unload C code segment
*
* This function is called when AMOS quits or when a Td Quit instruction is
* issued. If the 3d C code segment is loaded quit_3d() is called and the
* C code segment is unloaded.
*
* On entry a2 must contain the address of the extension data area.

UnLoadCPrg: tst.l    CPrgSeg(a2)
            beq.s    CNotLoaded
            movem.l  a3-a6,-(sp)           * a3-a6 for AMOS
            move.l   sp,AmosStack(a2)
            move.l   CStackStart(a2),sp
            move.l   CLinkerDB(a2),a4      * C V5.10 base relative addressing
            move.l   CTable(a2),a0
            move.l   QUIT_3D*4(a0),a0
            jsr      (a0)
            move.l   AmosStack(a2),sp
            move.l   CPrgSeg(a2),d1        * d1=segment address
            move.l   DosBase(a5),a0
            move.l   ExecBase,a6           * Just in case !
            jsr      DosULoadSeg(a0)
            clr.l    CPrgSeg(a2)           * For Td Quit
            movem.l  (sp)+,a3-a6
CNotLoaded: rts

**** Print a string routine, for debugging

___aprintf: move.l   sp,a0
            movem.l  d2-d7/a2-a6,-(sp)
            lea      Data(pc),a2
            move.l   AmosA5(a2),a5
            move.l   4(a0),a1
            WiCall   Print
            movem.l  (sp)+,d2-d7/a2-a6
            rts

**** C error handler
*
*  C invokes an AMOS error message using the call 'smos_error'. This
*  routine restores the AMOS environment before passing the parameters
*  from C to Francois' error handlers. The parameters are :
*
*               smos_error(type, number [ ,trappable ]);
*
*   type      :    : Normal(0) or Custom(1) error message
*   number    : d0 : Number of message in either list
*   trappable : d2 : Only applies to Custom errors - can the error be trapped
*             : d1 : ExtNb - Extension number


__smos_error:
            move.l   sp,a0             * Stash C stack
            lea      Data(pc),a2
            move.l   AmosStack(a2),sp  * Recover AMOS stack
            movem.l  (sp)+,a3-a6       * Recover AMOS registers
            move.l   8(a0),d0          * d0=error number
            move.l   12(a0),d1         * d1=trappable
            moveq    #ExtNb,d2         * d2=extension number
            tst.l    4(a0)             * type of error...
            beq.s    AmosError
            RBra     L_Custom          * Does this zap the compiler bug ?
AmosError:  RJmp     L_Error           * ...compiler error routine

**** 3D Library data zone
*
            rsreset
AmosStack:  rs.l    1
AmosA5:     rs.l    1
CTable:     rs.l    1
CPrgSeg     rs.l    1
CStackEnd:  rs.l    1
CStackStart:rs.l    1
CLinkerDB   rs.l    1

Data:       ds.b     __RS
DefPaths:   dc.w     CPrgName-Data     * (1) Look in current dir
            dc.w     Default2-Data     * (2) amos_system/  APSystem/
            dc.w     Default3-Data     * (3) command line
Default3:   dc.b     ":"
Default2:   dc.b     "APSystem/"       * AMOS Pro
CPrgName:   dc.b     "c3d.lib",0
CmdPath     ds.b     64
CPrgPath:   ds.b     MX_CPRG_PATH
            even

****************************************************************************
*                       Library functions

L_IDummy     equ     1
IDummy:

L_IDebug    equ     2
IDebug:
            IFD     DEBUG
            cmp.l   #-1,(a3)
            bne.s NoTrap
            illegal
            ENDC
NoTrap:
            EcCall   Current                    * Get screen base (in a0)
            tst.w    d0
            RBmi     L_ErrScrNotOpen
            move.l   a0,d2                      * Pass to C as extra parameter
            move.w  #CIntNoRet-Data,d0
            move.w  #4*TD_DEBUG,d1
            CallCP

L_ILoad     equ     3
ILoad:      move.w  #CStrNoRet-Data,d0  * 130 Load an object instruction
            move.w  #4*TD_LOAD,d1
            CallC

L_IClearAll equ     4
IClearAll:  move.w  #CNoneNoRet-Data,d0
            move.w  #4*TD_CLEAR_ALL,d1
            CallC

L_IObject   equ     5
IObject:    move.w  #CObject-Data,d0
            move.w  #4*TD_OBJECT,d1
            CallC

L_IScrHeight equ    6
IScrHeight: move.w  #CIntNoRet-Data,d0
            move.w  #4*TD_SCREEN_HEIGHT,d1
            CallC

L_FVisible  equ     7
FVisible:   move.w  #CIntRInt-Data,d0    * 129 Object visible function
            move.w  #4*TD_VISIBLE,d1
            CallC

L_FRange    equ     8
FRange:     move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_RANGE,d1
            CallC

L_IKill     equ     9
IKill:      move.w  #CIntNoRet-Data,d0
            move.w  #4*TD_KILL,d1
            CallC

L_IMove_x   equ      10
IMove_x:    move.w   #CIntStrNoR-Data,d0
            move.w   #4*TD_MOVE_XYZ,d1
            moveq    #0,d2
            CallCP

L_IMove_y    equ      11
IMove_y:    move.w   #CIntStrNoR-Data,d0
            move.w   #4*TD_MOVE_XYZ,d1
            moveq    #1,d2
            CallCP

L_IMove_z    equ      12
IMove_z:    move.w   #CIntStrNoR-Data,d0
            move.w   #4*TD_MOVE_XYZ,d1
            moveq    #2,d2
            CallCP

L_IMove_rel equ      13
IMove_rel:  move.w   #C4IntNoRet-Data,d0     * 146 Move relative instructon
            move.w   #4*TD_MOVE_REL,d1
            CallC

L_IMove_abs equ      14
IMove_abs:  move.w   #C4IntNoRet-Data,d0 * 148 Move absolute instructon
            move.w   #4*TD_MOVE_ABS,d1
            CallC

L_IForward  equ      15
IForward:   move.w   #C2IntNoRet-Data,d0
            move.w   #4*TD_FORWARD,d1
            CallC

L_FPosition_x equ    16
FPosition_x:move.w   #CIntRInt-Data,d0
            move.w   #4*TD_POSITION_XYZ,d1
            moveq    #0,d2
            CallCP

L_FPosition_y equ    17
FPosition_y:move.w  #CIntRInt-Data,d0
            move.w  #4*TD_POSITION_XYZ,d1
            moveq   #1,d2
            CallCP

L_FPosition_z equ    18
FPosition_z:moveq   #2,d2
            move.w  #CIntRInt-Data,d0
            move.w  #4*TD_POSITION_XYZ,d1
            CallCP

L_IAngle_A  equ      19
IAngle_A:   move.w  #CIntStrNoR-Data,d0
            move.w  #4*TD_ANGLE_ABC,d1
            moveq   #0,d2
            CallCP

L_IAngle_B  equ      20
IAngle_B:   move.w   #CIntStrNoR-Data,d0
            move.w   #4*TD_ANGLE_ABC,d1
            moveq    #1,d2
            CallCP

L_IAngle_C  equ      21
IAngle_C:   move.w   #CIntStrNoR-Data,d0
            move.w   #4*TD_ANGLE_ABC,d1
            moveq    #2,d2               * 154 Td Angle C instruction
            CallCP

L_IAngle_rel equ     22
IAngle_rel: move.w   #C4IntNoRet-Data,d0
            move.w   #4*TD_ANGLE_REL,d1          * 156 Oangle rel n A,B,C
            CallC

L_IAngle_abs equ     23
IAngle_abs: move.w  #C4IntNoRet-Data,d0         * 158 Oangle n A,B,C
            move.w  #4*TD_ANGLE_ABS,d1
            CallC

L_FAttitudeA equ     24
FAttitudeA: move.w   #CIntRInt-Data,d0
            move.w   #4*TD_ATTITUDE_ABC,d1
            moveq    #0,d2
            CallCP

L_FAttitudeB equ     25
FAttitudeB: move.w   #CIntRInt-Data,d0
            move.w   #4*TD_ATTITUDE_ABC,d1
            moveq    #1,d2
            CallCP

L_FAttitudeC equ     26
FAttitudeC: moveq    #2,d2
            move.w   #CIntRInt-Data,d0
            move.w   #4*TD_ATTITUDE_ABC,d1
            CallCP

L_IFaceobs  equ      27
IFaceObs:   move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_FACE,d1
            moveq    #BEARING_CALC+BEARING_OB_OB,d2
            CallCP

L_IFaceObPt equ      28
IFaceObPt:  move.w  #C4IntRInt-Data,d0
            move.w  #4*TD_FACE,d1
            moveq   #BEARING_CALC+BEARING_OB_PT,d2
            CallCP

L_FBearA    equ      29
FBearA      move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_A,d2
            CallCP

L_FBearAObOb equ    30
FBearAObOb  move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_A+BEARING_CALC+BEARING_OB_OB,d2
            CallCP

L_FBearAObPt equ      31
FBearAObPt  move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_A+BEARING_CALC+BEARING_OB_PT,d2
            CallCP

L_FBearB    equ      32
FBearB      move.w   #CNoneRInt-Data,d0       * This should be CNONE... !
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_B,d2
            CallCP

L_FBearBObOb equ    33
FBearBObOb  move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_B+BEARING_CALC+BEARING_OB_OB,d2
            CallCP

L_FBearBObPt equ      34
FBearBObPt  move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_B+BEARING_CALC+BEARING_OB_PT,d2
            CallCP

L_FBearR    equ      35
FBearR      move.w   #CNoneRInt-Data,d0       * This should be CNONE... !
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_R,d2
            CallCP

L_FBearRObOb equ     36
FBearRObOb  move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_R+BEARING_CALC+BEARING_OB_OB,d2
            CallCP

L_FBearRObPt equ     37
FBearRObPt  move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_BEARING_ABR,d1
            moveq.w  #BEARING_R+BEARING_CALC+BEARING_OB_PT,d2
            CallCP

L_IAnimRel  equ      38
IAnimRel:   move.w   #C6IntNoRet-Data,d0
            move.w   #4*TD_ANIM,d1
            moveq    #ANIM_REL,d2
            CallCP

L_FAnimPtX  equ      39
FAnimPtX:   move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_ANIM_POINT,d1
            moveq   #TX_XCOORD,d2
            CallCP

L_FAnimPtY  equ      40
FAnimPtY:   move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_ANIM_POINT,d1
            moveq   #TX_YCOORD,d2
            CallCP

L_FAnimPtZ  equ      41
FAnimPtZ:   move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_ANIM_POINT,d1
            moveq   #TX_ZCOORD,d2
            CallCP

L_IAnim     equ      42
IAnim:      move.w   #C6IntNoRet-Data,d0
            move.w   #4*TD_ANIM,d1
            moveq    #ANIM_ABS,d2
            CallCP

L_IRedraw   equ      43
IRedraw:    EcCall   Current                    * Get screen base (in a0)
            tst.w    d0
            RBmi     L_ErrScrNotOpen
            move.l   a0,d2                      * Pass to C as extra parameter
            move.w   #CNoneNoRet-Data,d0        * Call C as normal
            move.w   #4*TD_REDRAW,d1
            CallCP

L_ISetZone  equ      44
ISetZone:   move.w   #C6IntNoRet-Data,d0         * 166 Set zone instruction
            move.w   #4*TD_SET_ZONE,d1
            CallC

L_FCollide1 equ      45                 * =Td Collide(n)
FCollide1:  move.w   #CIntRInt-Data,d0
            move.w   #4*TD_COLLIDE,d1
            moveq    #1,d2
            CallCP

L_FCollide2 equ      46                 * =Td Collide(n1,n2)
FCollide2:  move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_COLLIDE,d1
            moveq    #0,d2
            CallCP

L_FZoneX    equ      47
FZoneX:     move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_ZONE_XYZR,d1
            moveq    #0,d2               * 147 Td Zone X function
            CallCP

L_FZoneY    equ      48
FZoneY:     move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_ZONE_XYZR,d1
            moveq   #1,d2
            CallCP

L_FZoneZ    equ      49
FZoneZ:     move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_ZONE_XYZR,d1
            moveq   #2,d2
            CallCP

L_FZoneR    equ      50
FZoneR:     move.w  #C2IntRInt-Data,d0
            move.w  #4*TD_ZONE_XYZR,d1
            moveq   #3,d2
            CallCP

L_FWorldX   equ      51
FWorldX:    move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_WORLD_XYZ,d1
            moveq    #TX_XCOORD,d2
            CallCP

L_FWorldXxyz equ     52
FWorldXxyz: move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_WORLD_XYZ,d1
            moveq    #TX_XCOORD+TX_CALCULATE,d2
            CallCP

L_FWorldY   equ      53
FWorldY:    move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_WORLD_XYZ,d1
            moveq    #TX_YCOORD,d2
            CallCP

L_FWorldYxyz equ     54
FWorldYxyz: move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_WORLD_XYZ,d1
            moveq    #TX_YCOORD+TX_CALCULATE,d2
            CallCP

L_FWorldZ   equ      55
FWorldZ:    move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_WORLD_XYZ,d1
            moveq    #TX_ZCOORD,d2
            CallCP

L_FWorldZxyz equ     56
FWorldZxyz: move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_WORLD_XYZ,d1
            moveq    #TX_ZCOORD+TX_CALCULATE,d2
            CallCP

L_FViewX    equ      57
FViewX:     move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_VIEW_XYZ,d1
            moveq    #TX_XCOORD,d2
            CallCP

L_FViewXxyz equ      58
FViewXxyz:  move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_VIEW_XYZ,d1
            moveq    #TX_XCOORD+TX_CALCULATE,d2
            CallCP

L_FViewY    equ      59
FViewY:     move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_VIEW_XYZ,d1
            moveq    #TX_YCOORD,d2
            CallCP

L_FViewYxyz equ      60
FViewYxyz:  move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_VIEW_XYZ,d1
            moveq    #TX_YCOORD+TX_CALCULATE,d2
            CallCP

L_FViewZ    equ      61
FViewZ:     move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_VIEW_XYZ,d1
            moveq    #TX_ZCOORD,d2
            CallCP

L_FViewZxyz equ      62
FViewZxyz:  move.w   #C4IntRInt-Data,d0
            move.w   #4*TD_VIEW_XYZ,d1
            moveq    #TX_ZCOORD+TX_CALCULATE,d2
            CallCP

L_FScreenX  equ      63
FScreenX:   move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_SCREEN_XY,d1
            moveq    #TX_XCOORD,d2
            CallCP

L_FScreenXxyz equ    64
FScreenXxyz:move.w   #C3IntRInt-Data,d0
            move.w   #4*TD_SCREEN_XY,d1
            moveq    #TX_XCOORD+TX_CALCULATE,d2
            CallCP

L_FScreenY  equ      65
FScreenY:   move.w   #CNoneRInt-Data,d0
            move.w   #4*TD_SCREEN_XY,d1
            moveq    #TX_YCOORD,d2
            CallCP

L_FScreenYxyz equ    66
FScreenYxyz:move.w   #C3IntRInt-Data,d0
            move.w   #4*TD_SCREEN_XY,d1
            moveq    #TX_YCOORD+TX_CALCULATE,d2
            CallCP

* The Td Background instruction needs two addresses, the destination screen
* where the background is to be drawn and the source screen where the
* background image data is kept.
* The source screen number is the first AMOS parameter at 28(a6), the screen
* number at this address is swapped with the its corresponding screen
* address. The destination screen address is passed as an extra parameter.

* td background src_scr,src X,src Y,width,height to dest X,dest Y [,plane]

L_IBackGnd  equ    67
IBackGnd:   clr.l  -(a3)             * Dummy AMOS parameter, plane=0
            RBra   L_IBackGndPl

L_IBackGndPl equ    68
IBackGndPl:
IBackground:move.l   28(a3),d1             * Get source screen no
            cmp.l    #8,d1
            bcc.s    BadScreenN
            EcCall   AdrEc
            move.l   d0,28(a3)             * Save as valid screen address
            RBeq     L_ErrScrNotOpen
            EcCall   Current               * Current screen as extra parameter
            tst.w    d0
            RBmi     L_ErrScrNotOpen
            move.l   a0,d2
*            beq.s    ScrNotOpen
*            move.w   #C6IntNoRet-Data,d0   * Call C as normal
            move.w   #C8IntNoRet-Data,d0   * Call C as normal
            move.w   #4*TD_BACKGROUND,d1
            CallCP

BadScreenN: move.l   #50,d0               * AMOS bad screen error no
            RJmp     L_Error              * AMOS error routine

L_ISetDir   equ      69
ISetDir:    move.w  #CStrNoRet-Data,d0
            move.w  #4*TD_SET_DIR,d1
            CallC

L_ISurfPtsOff equ    (L_ISetDir+1)
ISurfPtsOff:move.w   #CNoneNoRet-Data,d0
            move.w   #4*TD_SURFACE_POINTS,d1
            moveq    #0,d2
            CallCP

L_ISurfacePts equ    (L_ISurfPtsOff+1)
ISurfacePts:move.w   #C4IntNoRet-Data,d0
            move.w   #4*TD_SURFACE_POINTS,d1
            moveq    #1,d2
            CallCP

L_ISurface  equ      (L_ISurfacePts+1)
ISurface:   move.w   #CSurface-Data,d0
            move.w   #4*TD_SURFACE,d1
            CallC

L_ICls      equ      (L_ISurface+1)
ICls:       EcCall   Current                    * Get screen base (in a0)
            tst.w    d0
            RBmi     L_ErrScrNotOpen
            move.l   a0,d2                      * Pass to C as extra parameter
            move.w   #CNoneNoRet-Data,d0
            move.w   #4*TD_CLS,d1
            CallCP

L_IKeepOn   equ      (L_ICls+1)
IKeepOn:    moveq.l #1,d2
            move.w  #CNoneNoRet-Data,d0
            move.w  #4*TD_KEEP,d1
            CallCP

L_IKeepOff  equ      (L_IKeepOn+1)
IKeepOff:   moveq.l #0,d2
            move.w  #CNoneNoRet-Data,d0
            move.w  #4*TD_KEEP,d1
            CallCP

L_FAdvanced equ      (L_IKeepOff+1)
FAdvanced:  move.w  #CIntRInt-Data,d0
            move.w  #4*TD_ADVANCED,d1
            CallC

L_IQuit     equ     (L_FAdvanced+1)             * Td Quit - doesn't call C
IQuit:      move.l  ExtAdr+ExtNb*16(a5),a2      * Get address of Data zone
            jmp     UnLoadCPrg-Data(a2)         * Clear C code if present.

L_IPriority equ      (L_IQuit+1)
IPriority:  move.w   #C2IntNoRet-Data,d0
            move.w   #4*TD_PRIORITY,d1
            CallC

L_FPragmaStat equ    (L_IPriority+1)
FPragmaStat:move.w   #C2IntRInt-Data,d0
            move.w   #4*TD_PRAGMA_STATUS,d1
            CallC

L_IPragma   equ      (L_FPragmaStat+1)
IPragma:     move.w   #C2IntNoRet-Data,d0
            move.w   #4*TD_PRAGMA,d1
            CallC

L_IDelZone  equ      (L_IPragma+1)
IDelZone:   move.w   #C2IntNoRet-Data,d0
            move.w   #4*TD_DELETE_ZONE,d1
            CallC

L_ISetCol   equ      (L_IDelZone+1)
ISetCol:    move.w   #C3IntNoRet-Data,d0
            move.w   #4*TD_SETCOL,d1
            CallC

L_IRotate   equ      (L_ISetCol+1)
IRotate:    move.w   #C4IntNoRet-Data,d0
            move.w   #4*TD_ROTATE,d1
            CallC

*L_Spare0    equ      (L_ISetCol+1)
L_Spare0    equ      (L_IRotate+1)

Spare0:
L_Spare1    equ      (L_Spare0+1)
Spare1:
L_Spare2    equ      (L_Spare1+1)
Spare2:
L_Spare3    equ      (L_Spare2+1)
Spare3:
L_Spare4    equ      (L_Spare3+1)
Spare4:
L_Spare5    equ      (L_Spare4+1)
Spare5:
L_Spare6    equ      (L_Spare5+1)
Spare6:
L_Spare7    equ      (L_Spare6+1)
Spare7:
L_Spare8    equ      (L_Spare7+1)
Spare8:

*L_Spare9    equ      (L_Spare8+1)
*Spare9:

*L_ErrScrNotOpen equ  (L_Spare9+1)

L_ErrScrNotOpen equ  (L_Spare8+1)
ErrScrNotOpen:
            move.l   #47,d0               * Screen not open error number
            RJmp     L_Error              * Error routine

******* Custom error routines
*  Custom errors come in two flavors the first prints an error message,
*  it is always used by the interpreter and by a compiled program when the
*  -E1 option is specified. The second library routine does not print
*  anything and so does not require 3D custom error messages, it is
*  used in programs compiled under the -E0 option.
*
*  Both routines expect the following registers to be set up:
*        d0=error number
*        d1=trappable
*        d2=extension number

*  Custom errors with messages (compiler option -E1).
*   THIS MUST BE THE PENULTIMATE ROUTINE IN THE LIBRARY!!!!
L_Custom:   equ   (L_ErrScrNotOpen+1)

ErrCustomMsg:lea     ErrorMsgs(pc),a0  * a0=error messages
            moveq   #0,d3              * d3=Print messages
            RJmp   L_ErrorExt          * AMOS error handler

* Error messages...

ErrorMsgs:  dc.b     "Invalid object number",0
            dc.b     "Object already exists",0
            dc.b     "Not enough memory for 3D",0
            dc.b     "Object does not exist",0
            dc.b     "Syntax error in string",0
            dc.b     "Object not loaded",0
            dc.b     "Object file not found",0
            dc.b     "Template file not found",0
            dc.b     "Surface file not found",0
            dc.b     "Invalid 3d screen size",0
            dc.b     "Can't change screen size while objects exist",0
            dc.b     "Amos screen not compatible with 3d",0
            dc.b     "Zone parameter(s) out of range",0
            dc.b     "Object already loaded",0
            dc.b     "Too many objects",0
            dc.b     "Directory string too long",0
            dc.b     "Image offset must be an even number",0
            dc.b     "Image too large",0
            dc.b     "Image width must be a multiple of 16",0
            dc.b     "Image data exceeds screen bank",0
            dc.b     "Point does not exist",0
            dc.b     "Bad Object file",0
            dc.b     "Bad Template file",0
            dc.b     "Bad Surface file",0
            dc.b     "Block does not exist",0
            dc.b     "Face does not exist",0
            dc.b     "3d background source screen is current screen",0
            dc.b     "Too many planes for 3d background",0
            dc.b     "Can't load 3d code",0
            even                                * Important !

*  Custom errors without messages (compiler option -E0).
ErrCustom:   moveq   #0,d1               * I Think this has been done already
             moveq   #ExtNb,d2

            moveq   #-1,d3                      * d3=No messages
            RJmp    L_ErrorExt                  * AMOS error handler
LibraryEnd:

Title:
ExWel:      dc.b     "Voodoo 3D extension "
            Version
            dc.b     0,"$VER: "
            Version
            dc.b     0
            even

******* Make sure to length of file is even!
End:        dc.w     0
            even
