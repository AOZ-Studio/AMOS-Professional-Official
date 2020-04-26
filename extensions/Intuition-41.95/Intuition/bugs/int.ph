From ph@doc.ic.ac.uk Mon Nov 28 14:55:30 1994
To: achurch@goober.mbhs.edu
Subject: Intuition Extension
Date: Mon, 28 Nov 1994 19:54:10 +0000
From: Paul Hickman <ph@doc.ic.ac.uk>


Somehow I seem to have ended up with the documentation for version 1.2b,
but the .lib file for version 1.1! However, the 1.2b documentation does
not say that any of these bugs have been fixed...


2-Colour Screen Bug
===================


I have finally found out why MUI, Reqtools and other programs think that
all AMOS Intuition screens only have 2 colours, after fixing the Cygnus
Editor 2.12 screen using the promotor. The reason is because you do not
setup the dri_pens array by specifying an SA_PENS tag when opening the 
screen( Or you are not using OpenScreenTags or OpenScreenTaglist or the 
ExtNewScreen structure at all). The procedure given below sets up the dripens
after the screen is open, so that reqtools requesters, gadtool library,
and MUI windows open with the correct colours, and the screen title bar
looks like a normal KS2.x/3.x screen title bar (Almost - The screen depth
gadget still looks like a KS1.x screen gadget, but I think this is because 
I am modifying the dri_pens after the screen is open instead of specifing 
them before).

The parameters are:

_DETAIL   = Colour No. to use for normal detail. (Detail pen in Screen struct)
_BLOCK    = Colour No. to use for normal block. (Detail pen in Screen struct)
_TEXT     =          "            normal text.
_SHINE    =          "            bright 3D edges.
_SHADOW   =          "            dark 3D edges.
_FILL     =          "            Selected window/gadget background
_FILLTEXT =          "            Selected window/gadget foreground
_BACK     =          "            normal background. (Should be 0)
_HIGH     =          "            highlighted text foreground (On normal back)
_BARDETAIL=          "            menubar text & other foreground
_BARBLOCK =          "            menubar background
_BARTRIM  =          "            the thin line under the menubar.

The last three only have any affect under KS3.x. The default settings should
be the ones given in this example call, which shows the difference made to 
the ASL/Reqtools file requester:

Iscreen Open 0,640,256,8,Hires,"Hello World"+Chr$(0)
Amos To Back 
F$=Irequest File$
ISET_PENS[1,0,1,2,1,3,1,0,2,1,2,1]
F$=Irequest File$

If the 2 requesters appear identical to you, it may be that under 2.x, the
ASL library does not use dri_pens. But under 3.x, the first requester 
appears in a black & grey window - No blue or white. 


Procedure ISET_PENS[_DETAIL,_BLOCK,_TEXT,_SHINE,_SHADOW,_FILL,_FILLTEXT,
                    _BACK,_HIGH,_BARDETAIL,_BARBLOCK,_BARTRIM]
'
'^^^ Parameters split onto 2 lines for readability.
'
'
'Obtain the draw info structure for the screen, and  
'the number of pens (9=V36-38, 12=V39-40)
'
Areg(0)=Iscreen Base
_DRAW_INFO=Intcall(-690) : Rem _LVOGetScreenDrawInfo
_NUM_PENS=Deek(_DRAW_INFO+2)
_PENARRAY=Leek(_DRAW_INFO+4)


'
'Set the pens to the colours specified.
'
Doke _PENARRAY,_DETAIL
Doke _PENARRAY+2,_BLOCK
Doke _PENARRAY+4,_TEXT
Doke _PENARRAY+6,_SHINE
Doke _PENARRAY+8,_SHADOW
Doke _PENARRAY+10,_FILL
Doke _PENARRAY+12,_FILLTEXT
Doke _PENARRAY+14,_BACK
Doke _PENARRAY+16,_HIGH
If _NUM_PENS>=12
   '
   'Additional pens for V39-40 only 
   '
   Doke _PENARRAY+18,_BARDETAIL
   Doke _PENARRAY+20,_BARBLOCK
   Doke _PENARRAY+22,_BARTRIM
End If 


'
'Inform intuiton that this is now a new-look screen, so it uses these
'pens whenever possible, and uses the KS2.x/3.x style window border
'gadgets. 
'
'Without this, the window border gadgets in the requesters use the wrong
'colours. You probably won't need to do this, if the screen is opened
'with a taglist. 
'
Loke _DRAW_INFO+18,1


'
'Now determine if the screen title is visible, and redraw it if it is, 
'which makes it use the BARDETAIL,BARBLOCK & BARTRIM pens. 
'
If Btst(4,Iscreen Base+21)
   Areg(0)=Iscreen Base
   Dreg(0)=1
   A=Intcall(-282) : Rem _LVOShowTitle
End If 

'
'This only leaves the screen depth gadgetusing the old KS1.x style gadget.
'I can't seem to change this, but I believe it would be correct if the
'dri_pens were setup before the screen was opened, and the screen opened
'using OpenScreenTags or Taglist.
'
'
End Proc

I suggest you provide to new intuition commands:

1) Iscreen Open Nl ...

Opens a newlook screen, using OpenScreenTag[s/List], and sets up the
default dri_pens by providing an SA_PENS tag in the list.


2) Iscreen pens DETAIL,BLOCK,TEXT, etc.

A machine code version of the above procedure.







Irequest ... bug
=================

If you call these functions when the AMOS screen is "in front" the
machine locks up, and you have to reboot the machine. Fix this by
checking the status of the AMOS screen before calling the requester
functions e.g.

	;Assumes standard AMOS A5

	move.w	T_NoFlip(a5),d7 	;Store "Amos (Un)Lock" status
	move.w	#$FFFF,T_NoFlip(a5) 	;Turn "Amos Lock" on
	tst.w	T_AMOSHere(a5)		;Test if AMOS screen is in front
	bne.s	.amosinfronterr

	;Insert your requester here ...
	;You'll have to preserve D7 somehow.
					    
	move.w	d7,T_NoFlip(a5)		;Restore AMOS Lock Status
	rts			

.amosinfronterr
	move.w	d7,T_NoFlip(a5)		;Restore AMOS Lock Status
	moveQ	#AMOS_SCREEN_IN_FRONT_ERR,d0
	Rbra	L_Custom		;Cause an AMOS error


NOTE: You can't move the AMOS screen from front to back just by changing
      T_AMOSHere(A5) - An automatic Amos To Back when the command is called
      would be moe complicated.




Iset Screen Title 
=================

Add an instruction to change the screen title after the screen is opened.


Palettes
=======

How about an instruction to set palettes using colour values from 0 to 255 
instead of 0-15


+-------------------------+------------------------------------+
|                         |    _____                           |
| PAUL HICKMAN            |   /     \   ON A HOT SUMMER NIGHT  |
| (ph@doc.ic.ac.uk)       |  /  O O  \  WOULD YOU  OFFER YOUR  |
| DEPARTMENT OF COMPUTING | |    _    | THROAT  TO  THE  WOLF  |
| IMPERIAL COLLEGE LONDON |  \  / \  /  WITH THE RED  ROSES ?  |
|                         |   \_____/                          |
+-------------------------+------------------------------------+
Machines: Amiga 500  WB1.3 - 1mb Memory - External Disk Drive.
          Amiga 1200 WB3.0 - 6mb Memory - 200Mb Hard Disk.

