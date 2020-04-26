
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;             	Donn�es de Configuration Interpr�teur
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EdT	Macro
	dc.b	0
	dc.b	.\@E-.\@D
.\@D	dc.b	"\2"
.\@E
	EndM
EdD	Macro
	dc.b	0
	dc.b	.\@E-.\@D
.\@D	\2
.\@E
	EndM


; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;		Zone de donn�es DC
		dc.l 	"PId1"		Code de securite!
		dc.l	Dat2-Dat1
Dat1
; Initialisation de la trappe
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
PI_ParaTrap	dc.l 0			* 0 - Adresse actualisation
PI_AdMouse	dc.l 0			* 4 - Adresse souris
		dc.w 68			* 8 - Nombre de bobs
		dc.w 50			* 10- Position par defaut ecran!!
		dc.l 12*1024		* 12- Taille liste copper
		dc.l 128		* 16- Nombre lignes sprites
; Taille des buffers
; ~~~~~~~~~~~~~~~~~~
PI_VNmMax	dc.l 1024*4		* 20- Buffer des noms de variable
PI_TVDirect	dc.w 42*6		* 24- Variables mode direct
PI_DefSize	dc.l 1024*32		* 26- Taille buffer par defaut
; Directory
; ~~~~~~~~~
PI_DirSize	dc.w 30			* 30-
PI_DirMax	dc.w 128		* 32-
; Faire carriage return lors de PRINT?
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PI_PrtRet	dc.b 	1		34-
; Faire des icones?
; ~~~~~~~~~~~~~~~~~
PI_Icons	dc.b	0		35-
; Autoclose workbench?
; ~~~~~~~~~~~~~~~~~~~~
PI_AutoWB	dc.b	0		36- Fermer automatiquement
PI_AllowWB	dc.b	1		37- Close Workbench effective?
; Close editor?
; ~~~~~~~~~~~~~~~~~~~~
PI_CloseEd	dc.b	1		38- Close editor effective
PI_KillEd	dc.b	1		39- Kill editor effective
PI_FsSort	dc.b	1		40- Sort files
PI_FsSize	dc.b	1		41- Size of files
PI_FsStore	dc.b	1		42- Store directories
; Securite flags
; ~~~~~~~~~~~~~~
		dc.b	0		43- Flag libre
		ds.b 	4		44- 4 libres
; Text reader
; ~~~~~~~~~~~
PI_RtSx		dc.w	640		48- Taille X ecran Readtext
PI_RtSy		dc.w	200		50- Taille Y ecran Readtext
PI_RtWx		dc.w	129		52- Position X
PI_RtWy		dc.w	50		54- Position Y
PI_RtSpeed	dc.w	8		56- Vitesse apparition
; File selector
; ~~~~~~~~~~~~
PI_FsDSx	dc.w	448		58- Taille X fsel
PI_FsDSy	dc.w	158		60- Taille Y fsel
PI_FsDWx	dc.w	129+48		62- Position X
PI_FsDWy	dc.w	50+20		64- Position Y
PI_FsDVApp	dc.w	8		66- Vitesse app
; Ecran par defaut
; ~~~~~~~~~~~~~~~~
PI_DefETx	dc.w 320		68- Tx default
PI_DefETy	dc.w 200		70- Ty default
PI_DefECo	dc.w 4			72- Nplan default
PI_DefECoN	dc.w 16			74- NColor default
PI_DefEMo	dc.w 0			76- Mode default
PI_DefEBa	dc.w 0			78- Default colour back
PI_DefEPa	dc.w $000,$A40,$FFF,$000,$F00,$0F0,$00F,$666
		dc.w $555,$333,$733,$373,$773,$337,$737,$377
		dc.w 0,0,0,0,0,0,0,0
		dc.w 0,0,0,0,0,0,0,0
PI_DefEWx	dc.w 0			144- Position par defaut
PI_DefEWy	dc.w 0			146-
PI_DefAmigA	dc.l $00404161		148- Touche AMIGA-A par defaut

; Zone de securite!
; ~~~~~~~~~~~~~~~~~
		ds.l	6
Dat2

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;		Zone de donn�es TEXTE

		dc.l 	"PIt1"		Code de securite!
		dc.l	Txt2-Txt1

; Liste des fichiers syst�me
; ~~~~~~~~~~~~~~~~~~~~~~~~~~
Txt1		EdT	1,<APSystem/>
		EdT	2,<>
		EdT	3,<>
		EdT	4,<Def_Icon>
		EdT	5,<AutoExec.AMOS>
		EdT	6,<AMOSPro_Editor>
		EdT	7,<AMOSPro_Editor_Config>
		EdT	8,<AMOSPro_Default_Resource.Abk>
		EdT	9,<AMOSPro_Productivity1:Equates/AMOSPro_System_Equates>
		EdT	10,<AMOSPro_Monitor>
		EdT	11,<AMOSPro_Monitor_Resource.Abk>
		EdT	12,<AMOSPro_Accessories:AMOSPro_Help/AMOSPro_Help>
		EdT	13,<AMOSPro_Accessories:AMOSPro_Help/LatestNews>
		EdT	14,<AMOSPro.Lib>
		EdT	15,<>
; Liste des 26 extensions
; ~~~~~~~~~~~~~~~~~~~~~~~
		EdT	16,<AMOSPro_Music.Lib>
		EdT	17,<AMOSPro_Compact.Lib>
		EdT	18,<AMOSPro_Request.Lib>
		EdT	19,<>
		EdT	20,<AMOSPro_Compiler.Lib>
		EdT	21,<AMOSPro_IOPorts.Lib>
		EdT	22,<>
		EdT	23,<>
		EdT	24,<>
		EdT	25,<>
		EdT	26,<>
		EdT	27,<>
		EdT	28,<>
		EdT	29,<>
		EdT	30,<>
		EdT	31,<>
		EdT	32,<>
		EdT	33,<>
		EdT	34,<>
		EdT	35,<>
		EdT	36,<>
		EdT	37,<>
		EdT	38,<>
		EdT	39,<>
		EdT	40,<>
		EdT	41,<>
		EdT	42,<>
; Ports de communication
; ~~~~~~~~~~~~~~~~~~~~~~
		EdT	43,<Par:>
		EdT	44,<Aux:>
		EdT	45,<>
; Flash curseur
; ~~~~~~~~~~~~~
		EdT	46,<(000,2)(440,2)(880,2)(bb0,2)(dd0,2)(ee0,2)(ff2,2)(ff8,2)(ffc,2)(fff,2)(aaf,2)(88c,2)(66a,2)(226,2)(004,2)(001,2)>
; Filtre negatif directory
; ~~~~~~~~~~~~~~~~~~~~~~~~
		EdT	47,<>

		dc.b	0,$FF
		even
Txt2
