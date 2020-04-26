
	OPT	D-
	Include	"+Equ.s"
; _____________________________________________________________________________
;
;						DEFINITION DES MESSAGES AMOS
; _____________________________________________________________________________
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
; ______________________________________________________________________________

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

Debut


; Config par default
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		dc.l	.Ed_FConfig-.Ed_DConfig
.Ed_DConfig
; Screen definition
.Ed_Sx		dc.w	640		0
.Ed_Sy		dc.w	256		2 >>> Change par install
.Ed_Wx		dc.w	129		4
.Ed_Wy		dc.w	50		6
.Ed_VScrol	dc.w	300		8
.Ed_Inter	dc.b	0		10
		dc.b	0		11
; Colour back
.Ed_ColB	dc.w	$000		12
; Length UNDO
.Ed_LUndo	dc.l	4096		14 >>> Change par install
.Ed_NUndo	dc.l	1000		18 >>> Change par install
; Untok case
.DtkMaj1	dc.b	2		22
.DtkMaj2	dc.b	1		23
; Flags
.Ed_SvBak	dc.b	-1		24
.EdM_Keys	dc.b	-1		25
.Esc_KMemMax	dc.w	20		26
; Editor palette
.Ed_Palette	dc.w	$000,$06f,$077,$eee,$f00,$0dd,$0aa,$FF3		28
; Escape mode position
		dc.w	200		44
		dc.w	256		46
		ds.l	7		48 Securite
; Flags
.Ed_AutoSave	dc.l	0		76
.Ed_AutoSaveMn	dc.l	0		80
.Ed_SchMode	dc.w 	0		84
.Ed_Tabs	dc.w	3		86
.Esc_Output	dc.b	1		88
.Ed_QuitFlags	dc.b	1		89 Par default: confirm quit
.Ed_Insert	dc.b	-1		90
.Ed_Sounds	dc.b	0		91

; Programmes autoload
; ~~~~~~~~~~~~~~~~~~~
.Ed_AutoLoad
		dc.b 	0,0,0		92	1 Curseur HAUT
		dc.b 	0,0,0			2 Curseur BAS
		dc.b 	0,0,0			3 Curseur GAUCHE
		dc.b 	0,0,0			4 Curseur DROITE
		dc.b 	0,0,0			5 Haut page
		dc.b 	0,0,0			6 Bas page
		dc.b 	0,0,0			7 Mot gauche
		dc.b 	0,0,0			8 Mot droite
		dc.b 	0,0,0			9 Page UP
		dc.b 	0,0,0			10 Page down
		dc.b 	0,0,0			11 Debut ligne
		dc.b 	0,0,0			12 Fin ligne
		dc.b 	0,0,0			13 Etat Haut
		dc.b 	0,0,0			14 Etat Bas
		dc.b 	0,0,0			15 Bas Haut
		dc.b 	0,0,0			16 Bas Bas
		dc.b 	0,0,0			17 Haut texte
		dc.b 	0,0,0			18 Bas texte
		dc.b 	0,0,0			19 Return
		dc.b 	0,0,0			20 Backspace
		dc.b 	0,0,0			21 Delete
		dc.b 	0,0,0			22 Efface ligne
		dc.b 	0,0,0			23 Delete ligne
		dc.b 	0,0,0			24 Tab
		dc.b 	0,0,0			25 Del tab
		dc.b 	0,0,0			26 Fix tab
		dc.b 	1,1,0			27 Help
		dc.b 	0,0,0			28 ESC
		dc.b 	0,0,0			29 Insert ligne
		dc.b 	0,0,0			30 Delete-FIN ligne
		dc.b 	0,0,0			31 Previous label
		dc.b 	0,0,0			32 Next label
		dc.b 	0,0,0			33 Load
		dc.b 	0,0,0			34 Save As
		dc.b 	0,0,0			35 Save
		dc.b 	0,0,0			36 Delete Mot
		dc.b 	0,0,0			37 Backspace Mot
		dc.b 	0,0,0			38 Hide Current Window
		dc.b 	0,0,0			39 Set Marks
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0			49 Goto Marks
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0
		dc.b 	0,0,0			59 Switch Bloc
		dc.b 	0,0,0			60 Forget Bloc
		dc.b 	0,0,0			61 Open + Load
		dc.b 	0,0,0			62 Cut
		dc.b 	0,0,0			63 Paste
		dc.b 	0,0,0			64 Delete to SOL
		dc.b 	0,0,0			65 Undo
		dc.b 	0,0,0			66 Search
		dc.b 	0,0,0			67 Search Next
		dc.b 	0,0,0			68 Search Previous
		dc.b 	0,0,0			69 Set All block
		dc.b 	0,0,0			70 Recall alert
		dc.b 	0,0,0			71
		dc.b 	0,0,0			72 Store bloc
		dc.b 	0,0,0			73 Set Key Shortcut
		dc.b 	0,0,0			74 Set Program Menu
		dc.b 	0,0,0			75 Flip Insert Mode
		dc.b 	0,0,0			76 Goto Line Number
		dc.b 	0,0,0			77 Run
		dc.b 	0,0,0			78 Test
		dc.b 	0,0,0			79 Indent
		dc.b 	0,0,0			80 New (Clear Project)
		dc.b 	0,0,0			81 Close
		dc.b 	0,0,0			82 Quit
		dc.b 	0,0,0			83 Informations
		dc.b 	0,0,0			84 Merge
		dc.b 	0,0,0			85 Merge Ascii
		dc.b 	0,0,0			86 Print Bloc
		dc.b 	0,0,0			87 Open/Close Proc
		dc.b 	0,0,0			88 Load Hidden Program
		dc.b 	0,0,0			89 Open All
		dc.b 	0,0,0			90 Close All
		dc.b 	0,0,0			91 Previous Window
		dc.b 	0,0,0			92 Next Window
		dc.b 	0,0,0			93 Enlarge/Schrink Window
		dc.b 	0,0,0			94 Redo
		dc.b 	0,0,0			95 Split View
		dc.b 	0,0,0			96 Link cursor
		dc.b 	0,0,0			97 Save Block as Ascii
		dc.b 	0,0,0			98 Save Block
		dc.b 	0,0,0			99 Replace
		dc.b 	0,0,0			100 Replace Next
		dc.b 	0,0,0			101 Replace Previous
		dc.b 	0,0,0			102 New All Hidden Programs
		dc.b 	0,0,0			103 Open New
		dc.b 	0,0,0			104 Show/Hide key shortcuts
		dc.b 	0,0,0			105 Goto WB
		dc.b 	0,0,0			106 Set New Macro
		dc.b 	0,0,0			107 Clear One Macro
		dc.b 	0,0,0			108 Clear All Macros
		dc.b 	0,0,0			109 Save Macros
		dc.b 	0,0,0			110 Load Macros
		dc.b 	0,0,0			111 Run Hidden
		dc.b 	0,0,0			112 Edit Hidden
		dc.b 	0,0,0			113 New Hidden
		dc.b 	0,0,0			114 Text Buffer
		dc.b 	1,32,33			0   Edit Objects
		dc.b 	1,34,35			    Edit Icons
		dc.b 	1,36,37			    Edit Samples
		dc.b 	1,38,39			    Edit Resource
		dc.b 	0,0,0			    -------------
		dc.b 	1,40,0			5   Disc Manager
		dc.b 	1,41,0			    Object Editor
		dc.b 	1,42,0			    Sample Maker
		dc.b 	1,43,0			    Resource Maker
		dc.b 	0,0,0			    -------------
		dc.b 	1,44,0			10  Re-tokeniser
		dc.b 	1,45,0			    Compiler Shell
		dc.b 	1,46,0			    Compile
		dc.b 	0,0,0			    User Menu
		dc.b 	0,0,0			    User Menu
		dc.b 	0,0,0			15  User Menu
		dc.b 	0,0,0			    User Menu
		dc.b 	0,0,0			    User Menu
		dc.b 	0,0,0			    User Menu
		dc.b 	0,0,0			    User Menu
		dc.b 	0,0,0			135 Add User menu
		dc.b 	0,0,0			136 Del User menu
		dc.b 	0,0,0			137 Save Default config
		dc.b 	0,0,0			138 Save as
		dc.b 	0,0,0			139 Load default config
		dc.b 	0,0,0			140 Load as
		dc.b 	0,0,0			141
		dc.b 	0,0,0			142
		dc.b 	0,0,0			143
		dc.b 	0,0,0			144
		dc.b 	0,0,0			145
		dc.b 	0,0,0			146
		dc.b 	0,0,0			147
		dc.b 	0,0,0			148
		dc.b 	0,0,0			149
		dc.b 	0,0,0			150
		dc.b 	0,0,0			151
		dc.b 	1,1,2			152 Help Menu
		dc.b 	1,1,3			153 Using Help
		dc.b 	1,1,4			154 Editor
		dc.b 	1,1,5			155 Direct mode
		dc.b 	1,1,6			156 Syntax
		dc.b 	1,1,7			157 Basics
		dc.b 	1,1,8			158 Screen
		dc.b 	1,1,9			159 Object
		dc.b 	1,1,10			160 Audio
		dc.b 	1,1,11			161 Interface
		dc.b 	1,1,12			162 Input
		dc.b 	1,1,13			163 AmigaDos
		dc.b 	1,1,14			164 Debugging
		dc.b 	1,1,15			165 Machine
		dc.b 	1,1,16			166 Tables
		dc.b 	1,1,17			167 News
		dc.b 	1,1,2			168 Vide
		dc.b 	1,1,2			169 Vide
		dc.b 	0,0,0			170
		dc.b 	0,0,0			171
		dc.b 	1,25,0			172 Interpreter Setup
		dc.b 	1,26,27			173 Editor Setup
		dc.b 	1,26,28			174 Editor Menus
		dc.b 	1,26,29			175 Editor Dialogs
		dc.b 	1,26,30			176 Editor Test-Time
		dc.b 	1,26,31			177 Editor Run-Time
		dc.b 	1,26,24			178 Editor Colour Palette
		dc.b 	0,0,0			179 Previous programs
		dc.b 	0,0,0			180 Next programs
		dc.b 	0,0,0			181 Previous programs
		dc.b 	0,0,0			182 All text as block
		dc.b 	0,0,0			183
		dc.b 	0,0,0			184

; Touches de fonction
; ~~~~~~~~~~~~~~~~~~~
.Ed_KFonc:	dc.b 	$80+$4C,$00,0		1 Curseur HAUT
		dc.b 	$80+$4D,$00,0		2 Curseur BAS
		dc.b 	$80+$4F,$00,0		3 Curseur GAUCHE
		dc.b 	$80+$4E,$00,0		4 Curseur DROITE
		dc.b 	$80+$4C,Shf,0		5 Haut page
		dc.b 	$80+$4D,Shf,0		6 Bas page
		dc.b 	$80+$4F,Shf,0		7 Mot gauche
		dc.b 	$80+$4E,Shf,0		8 Mot droite
		dc.b 	$80+$4C,Ctr,0		9 Page UP
		dc.b 	$80+$4D,Ctr,0		10 Page down
		dc.b 	$80+$4F,Ctr,0		11 Debut ligne
		dc.b 	$80+$4E,Ctr,0		12 Fin ligne
		dc.b 	$80+$3e,Ami+Shf,0	13 Etat Haut
		dc.b 	$80+$1e,Shf+Ami,0	14 Etat Bas
		dc.b 	$80+$3e,Ami,0		15 Bas Haut
		dc.b 	$80+$1e,Ami,0		16 Bas Bas
		dc.b 	$80+$4C,Ctr+Shf,0	17 Haut texte
		dc.b 	$80+$4D,Ctr+Shf,0	18 Bas texte
		dc.b 	13,$00,0		19 Return
		dc.b 	$80+$41,0,0		20 Backspace
		dc.b 	$80+$46,0,0		21 Delete
		dc.b 	"Q",Ctr,0		22 Efface ligne
		dc.b 	"Y",Ctr,0		23 Delete ligne
		dc.b 	$80+$42,0,0		24 Tab
		dc.b 	$80+$42,Shf,0		25 Del tab
		dc.b 	$80+$42,Ctr,0		26 Fix tab
		dc.b 	$80+$5F,0,0		27 Help
		dc.b 	$80+$45,0,0		28 ESC
		dc.b 	$80+$59,0,0		29 Insert ligne
		dc.b 	$80+$46,Ctr,0		30 Delete-FIN ligne
		dc.b 	$80+$4C,Alt,0		31 Previous label
		dc.b 	$80+$4D,Alt,0		32 Next label
		dc.b 	"L",Ami,0		33 Load
		dc.b 	"S",Ami+Shf,0		34 Save As
		dc.b 	"S",Ami,0		35 Save
		dc.b 	$80+$46,Shf,0		36 Delete Mot
		dc.b 	$80+$41,Shf,0		37 Backspace Mot
		dc.b 	"H",Ami,0		38 Hide Current Window
		dc.b 	1,0,0			39 Set Marks
		dc.b 	1,0,0
		dc.b 	1,0,0
		dc.b 	1,0,0
		dc.b 	$80+$2d,Ctr+Shf,0
		dc.b 	$80+$2e,Ctr+Shf,0
		dc.b 	$80+$2f,Ctr+Shf,0
		dc.b 	$80+$3d,Ctr+Shf,0
		dc.b 	$80+$3e,Ctr+Shf,0
		dc.b 	$80+$3f,Ctr+Shf,0
		dc.b 	$80+$0f,Ctr,0		49 Goto Marks
		dc.b 	$80+$1d,Ctr,0
		dc.b 	$80+$1e,Ctr,0
		dc.b 	$80+$1f,Ctr,0
		dc.b 	$80+$2d,Ctr,0
		dc.b 	$80+$2e,Ctr,0
		dc.b 	$80+$2f,Ctr,0
		dc.b 	$80+$3d,Ctr,0
		dc.b 	$80+$3e,Ctr,0
		dc.b 	$80+$3f,Ctr,0
		dc.b 	"B",Ctr,0		59 Switch Bloc
		dc.b 	"F",Ctr,0		60 Forget Bloc
		dc.b 	"L",Ami+Shf,0		61 Open + Load
		dc.b 	"C",Ctr,0		62 Cut
		dc.b 	"P",Ctr,0		63 Paste
		dc.b 	$80+$41,Ctr,0		64 Delete to SOL
		dc.b 	"U",Ctr,0		65 Undo
		dc.b 	"F",Ami,0		66 Search
		dc.b 	"N",Ami,0		67 Search Next
		dc.b 	"B",Ami,0		68 Search Previous
		dc.b 	1,0,0			69 Set All block
		dc.b 	"K",Ctr,0		70 Recall alert
		dc.b 	1,0,0			71
		dc.b 	"S",Ctr,0		72 Store bloc
		dc.b 	1,0,0			73 Set Key Shortcut
		dc.b 	1,0,0			74 Set Program Menu
		dc.b 	$80+$57,0,0		75 Flip Insert Mode
		dc.b 	"G",Ami,0		76 Goto Line Number
		dc.b 	$80+$50,0,0		77 Run
		dc.b 	$80+$51,0,0		78 Test
		dc.b 	$80+$52,0,0		79 Indent
		dc.b 	"Q",Ami,0		80 New
		dc.b 	"Q",Ami+Shf,0		81 Close
		dc.b 	1,0,0  			82 Quit
		dc.b 	"I",Ami,0		83 Informations
		dc.b 	"M",Ami,0		84 Merge
		dc.b 	"M",Ami+Shf,0		85 Merge Ascii
		dc.b 	"P",Ctr+Shf,0		86 Print Bloc
		dc.b 	$80+$58,0,0		87 Open/Close Proc
		dc.b 	1,0,0			88 Load Hidden Program
		dc.b 	"O",Ami+Shf,0		89 Open All
		dc.b 	"C",Ami+Shf,0		90 Close All
		dc.b 	$80+$55,0,0		91 Previous Window
		dc.b 	$80+$56,0,0		92 Next Window
		dc.b 	$80+$2e,Ami,0		93 Enlarge/Schrink Window
		dc.b 	"U",Ctr+Shf,0		94 Redo
		dc.b 	"V",Shf+Ami,0		95 Split View
		dc.b 	"C",Ami,0		96 Link cursor
		dc.b 	"A",Ctr+Shf,0		97 Save Block as Ascii
		dc.b 	"S",Ctr+Shf,0		98 Save Block
		dc.b 	"F",Ami+Shf,0		99 Replace
		dc.b 	"N",Ami+Shf,0		100 Replace Next
		dc.b 	"B",Ami+Shf,0		101 Replace Previous
		dc.b 	1,0,0			102 New All Hidden Programs
		dc.b 	"W",Shf+Ami,0		103 Open New
		dc.b 	"K",Ami,0		104 Show/Hide key shortcuts
		dc.b 	1,0,0			105 Goto WB
		dc.b 	"M",Ctr,0		106 Set New Macro
		dc.b 	1,0,0			107 Clear One Macro
		dc.b 	1,0,0			108 Clear All Macros
		dc.b 	1,0,0			109 Save Macros
		dc.b 	1,0,0			110 Load Macros
		dc.b 	1,0,0			111 Run Hidden
		dc.b 	1,0,0			112 Edit Hidden
		dc.b 	1,0,0			113 New Hidden
		dc.b 	"T",Ami+Shf,0		114 Text Buffer
		dc.b 	1,0,0			0   User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			5   User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			10  User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			15  User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	1,0,0			    User Menu
		dc.b 	"U",Ami,0		135 Add User menu
		dc.b 	"U",Ami+Shf,0		136 Del User menu
		dc.b 	1,0,0			137 Save Default config
		dc.b 	1,0,0			138 Save as
		dc.b 	1,0,0			139 Load default config
		dc.b 	1,0,0			140 Load as
		dc.b 	1,0,0			141 Quit options
		dc.b 	1,0,0			142 Autosave
		dc.b 	1,0,0			143 Load Defalt macros
		dc.b 	1,0,0			144 Save default macros
		dc.b 	$80+$53,0,0		145 Monitor
		dc.b 	"P",Ami,0		146 Print text
		dc.b 	"I",Ami+Shf,0		147 Check 1.3
		dc.b 	1,0,0			148 Sound On.Off
		dc.b 	1,0,0			149 About
		dc.b 	1,0,0			150 About
		dc.b 	1,0,0			151 Insert ML
		dc.b 	1,0,0			152
		dc.b 	1,0,0			153
		dc.b 	1,0,0			154
		dc.b 	1,0,0			155
		dc.b 	1,0,0			156
		dc.b 	1,0,0			157
		dc.b 	1,0,0			158
		dc.b 	1,0,0			159
		dc.b 	1,0,0			160
		dc.b 	1,0,0			161
		dc.b 	1,0,0			162
		dc.b 	1,0,0			163
		dc.b 	1,0,0			164
		dc.b 	1,0,0			165
		dc.b 	1,0,0			166
		dc.b 	1,0,0			167
		dc.b 	1,0,0			168
		dc.b 	1,0,0			169
		dc.b 	1,0,0			170
		dc.b 	1,0,0			171
		dc.b 	1,0,0			172Interpreter Setup
		dc.b 	1,0,0			173Editor Setup
		dc.b 	1,0,0			174Editor Menus
		dc.b 	1,0,0			175Editor Dialogs
		dc.b 	1,0,0			176Test-Time
		dc.b 	1,0,0			177Run-Time
		dc.b 	1,0,0			178Colour Palette
		dc.b 	1,0,0			179Previous programs
		dc.b 	1,0,0			180Next programs
		dc.b 	"A",Ctr,0		181All text as block
		dc.b 	1,0,0			182
		dc.b 	$80+$54,0,0		183Go Help
		dc.b 	1,0,0			184
		dc.b 	$FF,0

.Ed_Code	dc.l	"1.10"

.Ed_FConfig

; Chaines systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	.Sys2-.Sys1
.Sys1
; D�finitions ligne d'etat
	EdT	1,<       1  2   3       4        5       6     7>
	EdT	2,<Window-     L-      C-    Free-         Edit- >
	EdT	3,< Edit>
	EdT	4,<Split>
	EdT	5,<O>
	EdT	6,<I>
	EdT	7,<New project>
; Alert, Couleurs messages
	EdD	8,<dc.b 27,"B4",27,"P3",25>
; Etat, Init ligne
	EdD	9,<dc.b 27,"J7",27,"B6",27,"P7",27,"D1",27,"V0",25,27,"C0">
; Etat, CLW ligne activee
	EdD	10,<dc.b 27,"B6",27,"P7",27,"S0",25,27,"C0">
; Etat, CLW ligne inactivee
	EdD	11,<dc.b 27,"B6",27,"P7",25,27,"C0",27,"S1">
; Etat, definition des couleurs des zones active
	EdD	12,<dc.b 27,"B6",27,"P7">
; Touches de fonction de la barre de menu
	EdD	13,<dc.b 28,105,77,78,79,145,27,91,92,75,87,29>
; ESC, Attente caractere
	EdD	14,<dc.b 13,10,31,30,27,"I1","AMOS Pro",62,27,"I0",27,"C1",0>
; Vide!
	EdT	15,<>
; ESC, Initialisation
	EdD	16,<dc.b 27,"C0",27,"J7",27,"B2",27,"P3",27,"D1",25,27,"V0",30,30,27,"V1",27,"B2",27,"P3",27,"J1",0>
; Inverse, debut bloc
	EdD	17,<dc.b 27,"B3",27,"P2",27,"J1",0>
; Fin bloc, retour normale
	EdD	18,<dc.b 27,"B2",27,"P3",27,"J1",0>
; Definition des sliders editeur
	EdD	19,<dc.b 0,0,0,1,4,4,4,1,0,0,0,1,3,3,3,1>
; Effacement de l'ecran
	EdD	20,<dc.b 27,"J7",27,"B2",27,"P3",27,"D1",27,"V0",25,27,"C0",27,"J1",0>
; Suffixes
	EdT	21,<.Bak>
	EdT	22,<.AMOS>
; Sliders editeur II
	EdD	23,<dc.b 0,0,0,1,4,4,4,1,0,0,0,1,3,3,3,1>
; Boutons du mode direct
	EdT	24,<ListBank`>
	EdT	25,<Default`>
	EdT	26,<Dir`>
	EdT	27,<Dir$='>
	EdT	28,<Parent`>
	EdT	29,<Load Fsel$('*.Abk')>
	EdT	30,<Save Fsel$('*.Abk')>
	EdT	31,<Load Iff '>
	EdT	32,<Save Iff '>
	EdT	33,<? Fsel$('**')`>
	EdT	34,<Screen Close >
	EdT	35,<Screen Open >
	EdT	36,<Wind Open >
	EdT	37,<Wind Close`>
	EdT	38,<Bob Off : Sprite Off`>
	EdT	39,<Freeze`>
	EdT	40,<UnFreeze`>
	EdT	41,<Amal Off`>
	EdT	42,<Edit`>
	EdT	43,<System>
	EdT	44,<>
; Fichiers systeme
	EdT	45,<AMOSPro_Editor_Resource.Abk>
	EdT	46,<AMOSPro_Editor_Macros>
	EdT	47,<AMOSPro_Editor_LastSession>
	EdT	48,<AMOSPro_Editor_Samples.Abk>
	EdT	49,<New_Project_>
	dc.b	0,$FF
	even
.Sys2

; Chaines Menus
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	.Mn2-.Mn1
.Mn1	IncBin	"bin/Editor_Menus.asc"
	Even
.Mn2

; Messages de l'�diteur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	Ed2-Ed1
Ed1	EdT	1,<Link cursor movement: please click on the window to link...>
	EdT	2,<Cannot hide the last window.>
	EdT	3,<Too many windows.>
	EdT	4,<No more Undo.>
	EdT	5,<No mode Redo.>
	EdT	6,<What block?>
	EdT	7,<Block stored in memory.>
	EdT	8,<Block deleted from memory.>
	EdT	9,<Error in previous program: >
	EdT	10,<Out of memory! Cannot load program.>
	EdT	11,< already exists. Overwrite?>
	EdT	12,<Program already run.>
	EdT	13,<Editor command not runnable.>
	EdT	14,<This editor command needs a string.>
	EdT	15,<Program is not an accessory.>
	EdT	16,<Editor function not found.>
	EdT	17,<Yes>
	EdT	18,<No>
	EdT	19,<Cancel>
	EdT	20,<Quit AMOS Professional. Are you sure?>
	EdT	21,<AMOS Professional>
	EdT	22,<By Fran�ois Lionet>
	EdT	23,<� 1992 Europress Software Ltd.>
	EdT	24,< extensions loaded.>
	EdT	25,<New all hidden programs. Are you sure?>
	EdT	26,<Search>
	EdT	27,<Enter string to look for:>
	EdT	28,<[F2] Upper Case = Lower Case>
	EdT	29,<Ok>
	EdT	30,<Recording your macro. Click mouse button to end.>
	EdT	31,<Enter replace string:>
	EdT	32,<All in Marked Block>
	EdT	33,<Search and Replace>
	EdT	34,<All Occurences>
	EdT	35,<[F1] Backward>
	EdT	36,<...Searching [Control]+[C] to abort...>
	EdT	37,<...Searching & Replacing [Control]+[C] to abort...>
	EdT	38,<Replace in whole block. Are you sure?>
	EdT	39,<Replace in whole text. Are you sure?>
	EdT	40,< change(s) done.>
	EdT	41,< not saved. Save?>
	EdT	42,<Macro Definition>
	EdT	43,<Please press a key to assign the macro to.>
	EdT	44,<This key is already assigned to a macro. Erase the current macro?>
	EdT	45,<Macro successfully recorded.>
	EdT	46,<This function cannot be used in a macro!>
	EdT	47,<Erase a macro>
	EdT	48,<Please press the key assigned to the macro you want to erase.>
	EdT	49,<This key is not assigned to a macro!>
	EdT	50,<Erase all the macro definitions. Are you sure?>
	EdT	51,<AMOSPro.*>
	EdT	52,<AMOSPro.Macros>
	EdT	53,<Save Macro Definitions>
	EdT	54,<Ensure the filename begins with 'AMOSPro.'>
	EdT	55,<AMOSPro.*>
	EdT	56,<AMOSPro.Macros>
	EdT	57,<Load Macro Definitions>
	EdT	58,<Please choose a macro file.>
	EdT	59,<Erase old macro definition. Are you sure?>
	EdT	60,<No macros defined.>
	EdT	61,<Saving macro definitions.>
	EdT	62,<Loading macro definitions.>
	EdT	63,<This file is not an AMOSPro Macro file!>
	EdT	64,<Mark set.>
	EdT	65,<Mark not defined.>
	EdT	66,<*.AMOS>
	EdT	67,<>
	EdT	68,<Load a hidden program>
	EdT	69,<Please choose program to load.>
	EdT	70,<*.AMOS>
	EdT	71,<>
	EdT	72,<Load an AMOS program>
	EdT	73,<>
	EdT	74,<*.AMOS>
	EdT	75,<>
	EdT	76,<Save an AMOS program>
	EdT	77,<Ensure filename ends with '.AMOS'>
	EdT	78,<*.AMOS>
	EdT	79,<>
	EdT	80,<Merge an AMOS Program>
	EdT	81,<>
	EdT	82,<*.Asc>
	EdT	83,<>
	EdT	84,<Save the block as an ASCII file>
	EdT	85,<>
	EdT	86,<*.Asc>
	EdT	87,<>
	EdT	88,<Merge an ASCII file>
	EdT	89,<>
	EdT	90,<*.AMOS>
	EdT	91,<>
	EdT	92,<Save the block as an AMOS program>
	EdT	93,<Ensure filename ends in '.AMOS'>
	EdT	94,<Keyboard shortcuts>
	EdT	95,<Please choose the option to assign in the menu.>
	EdT	96,<Press any key to abort>
	EdT	97,<Now, press the desired keyboard combination.>
	EdT	98,<This key is already used. Proceed anyway?>
	EdT	99,<This menu option cannot be assigned to a key.>
	EdT	100,<*.AMOS>
	EdT	101,<>
	EdT	102,<Program to Menu>
	EdT	103,<Please choose the program to run>
	EdT	104,<Program to Menu>
	EdT	105,<This menu option cannot be assigned to a program!>
	EdT	106,<This menu option is already assigned to a program!>
	EdT	107,<Option: >
	EdT	108,<Program: >
	EdT	109,<Replace>
	EdT	110,<Erase>
	EdT	111,<[F1] Load as hidden program>
	EdT	112,<Goto Line>
	EdT	113,<Please enter line number:>
	EdT	114,<Set Buffer Size>
	EdT	115,<Please enter new buffer size:>
	EdT	116,<Text buffer too small. Adapt size?>
	EdT	117,<Set Tab Value>
	EdT	118,<Please enter new tab value:>
	EdT	119,<Command line:>
	EdT	120,<[F2] Load in current program window>
	EdT	121,<[F3] Keep after run>
	EdT	122,<New current program. Are you sure?>
	EdT	123,<Delete User Option>
	EdT	124,<Please choose the option in the 'User' menu.>
	EdT	125,<This is not a 'User' menu option!>
	EdT	126,<Add User Option>
	EdT	127,<Please enter option name:>
	EdT	128,<User Menu Call>
	EdT	129,<You should assign a program to this option!>
	EdT	130,<**>
	EdT	131,<>
	EdT	132,<Save the current configuration>
	EdT	133,<>
	EdT	134,<**>
	EdT	135,<>
	EdT	136,<Load an AMOS Professional configuration>
	EdT	137,<>
	EdT	138,<Cannot save configuration>
	EdT	139,<Cannot load configuration>
	EdT	140,<Save default configuration. Are you sure?>
	EdT	141,<Current configuration not saved. Save it?>
	EdT	142,<Autosave>
	EdT	143,<Number of minutes between warnings, (0 to prevent autosave):>
	EdT	144,<Quit Options>
	EdT	145,<[F1] Confirm quit>
	EdT	146,<[F2] Save configuration>
	EdT	147,<[F3] Save macros>
	EdT	148,<[F4] Enable Auto-resume>
	EdT	149,<Saving auto-resume information>
	EdT	150,<WARNING!>
	EdT	151,<Cannot save editor setup: warm-start not enabled.>
	EdT	152,<Saving current configuration>
	EdT	153,<Loading configuration>
	EdT	154,<Saving >
	EdT	155,<Loading >
	EdT	156,<Saving as ASCII >
	EdT	157,<Printing block>
	EdT	158,<Merging >
	EdT	159,<Loading auto-resume information.>
	EdT	160,<Warm start Error>
	EdT	161,<Sorry, Editor configuration not recoverable!>
	EdT	162,<Cannot delete warm-start information!>
	EdT	163,<Make sure your AMOSPro disc is not protected, and click on 'OK'>
	EdT	164,<Retry>
	EdT	165,<Cancel>
	EdT	166,<AMOS Professional Editor Information>
	EdT	167,<Free chip-ram: >
	EdT	168,<Free fast-ram: >
	EdT	169,<About current program>
	EdT	170,<Text length: >
	EdT	171,<Bank length: >
	EdT	172,<Number of visible lines: >
	EdT	173,<Number of instructions: >
	EdT	174,< byte(s)>
	EdT	175,<Next>
	EdT	176,<Prev>
	EdT	177,<Extension number >
	EdT	178,<**>
	EdT	179,<>
	EdT	180,<Insert machine language into procedure>
	EdT	181,<Please choose a RELOCATABLE program!>
	EdT	182,<This is not a relocatable executable routine!>
	EdT	183,<This line can't be modified>
	EdT	184,<Disc error>
	EdT	185,<Out of memory: cannot open menus.>
	EdT	186,<Low memory: clearing program display.>
	EdT	187,<This was the last window. Quit AMOS Professional?>		v1.1
	EdT	188,<See Latest News in the Help menu>				v1.1
	EdT	189,<for information about this version.>			v1.1
	EdT	190,<>
	EdT	191,<>
	EdT	192,<>
	EdT	193,<>
	EdT	194,<>
	EdT	195,<AMOS Professional Text Reader>
	EdT	196,<Line # >
	EdT	197,<No errors>
	EdT	198,<...Testing...>
	EdT	199,<Line too long.>
	EdT	200,<Top of text.>
	EdT	201,<Bottom of text.>
	EdT	202,<Out of buffer space.>
	EdT	203,<Not a procedure.>
	EdT	204,<Out of memory.>
	EdT	205,<Not found.>
	EdT	206,<Not done.>
	EdT	207,<Not an AMOS program.>
	EdT	208,<Text buffer too small.>
	EdT	209,<Check printer then select OK.>
	EdT	210,>>>
	EdT	211,< at line >
	EdT	212,<Direct mode [ESC]>
	EdT	213,<Editor [RETURN]>
	EdT	214,<Print block>
	EdT	215,<Print program>
	EdT	216,<Printer not ready.>
	EdT	217,<Printing program>
	EdT	218,<Editor display being reset!>
	EdT	219,<         Registered User: >
	EdT	220,<     Registration Number: >
	EdT	221,<Warning: precision mismatch. Please read help file.>
	EdT	222,<Monitor not found.>
	dc.b	0,$ff
	even
Ed2

;
; Messages d'erreur TEST-TIME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	.Test2-.Test1
.Test1
	EdT	1,<Bad structure>
	EdT	2,<User function not defined>
	EdT	3,<Variable buffer can't be changed in the middle of a program!>
	EdT	4,<This instruction must be alone on a line>
	EdT	5,<Extension not loaded>
	EdT	6,<Too many direct mode variables>
	EdT	7,<Illegal direct mode>
	EdT	8,<Variable buffer too small>
	EdT	9,<No jumps allowed into the middle of a loop!>
	EdT	10,<Structure too long>
	EdT	11,<This instruction must be used within a procedure>
	EdT	12,<This variable is already defined as SHARED>
	EdT	13,<This array is not defined in the main program>
	EdT	14,<Use empty brakets when defining a shared array>
	EdT	15,<Shared must be alone on a line>
	EdT	16,<Procedure's limits must be alone on a line>
	EdT	17,<Procedure not closed>
	EdT	18,<Procedure not opened>
	EdT	19,<Illegal number of parameters>
	EdT	20,<Undefined procedure>
	EdT	21,<ELSE without IF>
	EdT	22,<IF without ENDIF>
	EdT	23,<ENDIF without IF>
	EdT	24,<ELSE without ENDIF>
	EdT	25,<No THEN in a structured test>
	EdT	26,<Not enough loops to exit>
	EdT	27,<DO without LOOP>
	EdT	28,<LOOP without DO>
	EdT	29,<WHILE without matching WEND>
	EdT	30,<WEND without WHILE>
	EdT	31,<REPEAT without matching UNTIL>
	EdT	32,<UNTIL without REPEAT>
	EdT	33,<FOR without matching NEXT>
	EdT	34,<NEXT without FOR>
	EdT	35,<Syntax error>
	EdT	36,<Out of memory>
	EdT	37,<Variable name's buffer too small>
	EdT	38,<Array not dimensioned>
	EdT	39,<Array already dimensioned>
	EdT	40,<Type mismatch error>
	EdT	41,<Undefined label>
	EdT	42,<Label defined twice>
	EdT	43,<Trap must be immediately followed by an instruction>
	EdT	44,<No ELSE IF after an ELSE>
	EdT	45,<Cannot load included file>
	EdT	46,<Included file is not an AMOS program>
	EdT	47,<Instruction not compatible with AMOS 1.3>
	EdT	48,<This program holds too many banks for AMOS 1.3>
	EdT	49,<This program is compatible with AMOS 1.3>
	EdT	50,<This command must begin your program (but AFTER 'Set Buffer')>
	EdT	51,<Equate not defined>
	EdT	52,<Cannot load equate file>
	EdT	53,<Bad format in equate file>
	EdT	54,<Equate not of the right type>
	dc.b	0,$FF
	Even
.Test2
;
; Messages d'erreur RUN TIME
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l .Error2-.Error1

; 0-19 FATALS
; ~~~~~~~~~~~
.Error1	EdT	0,<>
	EdT	1,<RETURN without GOSUB>
	EdT	2,<POP without GOSUB>
	EdT	3,<Error not resumed>
	EdT	4,<Can't resume to a label>
	EdT	5,<No ON ERROR PROC before this instruction>
	EdT	6,<Resume label not defined>
	EdT	7,<Resume without error>
	EdT	8,<Error procedure must RESUME to end>
	EdT	9,<Program interrupted>
	EdT	10,<End of program>
	EdT	11,<Out of variable space>
	EdT	12,<Cannot open math libraries>
	EdT	13,<Out of stack space>
	EdT	14,<>
	EdT	15,<User function not defined>
	EdT	16,<Illegal user function call>
	EdT	17,<Illegal direct mode>
	EdT	18,<>
	EdT	19,<>
; 20- Messages normaux
; ~~~~~~~~~~~~~~~~~~~~
	EdT	20,<Division by zero>
	EdT	21,<String too long>
	EdT	22,<Syntax error>
	EdT	23,<Illegal function call>
	EdT	24,<Out of memory>
	EdT	25,<Address error>
	EdT	26,<>
	EdT	27,<Non dimensioned array>
	EdT	28,<Array already dimensioned>
	EdT	29,<Overflow>
	EdT	30,<Bad IFF format>
	EdT	31,<IFF compression not recognised>
	EdT	32,<Can't fit picture in current screen>
	EdT	33,<Out of data>
	EdT	34,<Type mismatch>
	EdT	35,<Bank already reserved>
	EdT	36,<Bank not reserved>
	EdT	37,<Fonts not examined>
	EdT	38,<Menu not opened>
	EdT	39,<Menu item not defined>
	EdT	40,<Label not defined>
	EdT	41,<No data after this label>
	EdT	42,<>
	EdT	43,<>
	EdT	44,<Font not available>
; Messages d'erreur ecrans/fenetres
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EdT	45,<>
	EdT	46,<Block not defined>
	EdT	47,<Screen not opened>
	EdT	48,<Illegal screen parameter>
	EdT	49,<Illegal number of colours>
	EdT	50,<Valid screen numbers range 0 to 7>
	EdT	51,<Too many colours in flash>
	EdT	52,<Flash declaration error>
	EdT	53,<Shift declaration error>
	EdT	54,<Text window not opened>
	EdT	55,<Text window already opened>
	EdT	56,<Text window too small>
	EdT	57,<Text window too large>
	EdT	58,<>
	EdT	59,<Bordered text windows not on edge of screen>
	EdT	60,<Illegal text window parameter>
	EdT	61,<>
	EdT	62,<Text window 0 can't be closed>
	EdT	63,<This text window has no border>
	EdT	64,<>
	EdT	65,<Block not found>
	EdT	66,<Illegal block parameters>
	EdT	67,<Screens can't be animated>
	EdT	68,<Bob not defined>
	EdT	69,<Screen already in double buffering>
	EdT	70,<Can't set dual playfield>
	EdT	71,<Screen not in dual playfield mode>
	EdT	72,<Scrolling zone not defined>
	EdT	73,<No zones defined>
	EdT	74,<Icon not defined>
	EdT	75,<Rainbow not defined>
	EdT	76,<Copper not disabled>
	EdT	77,<Copper list too long>
	EdT	78,<Illegal copper parameter>
; Messages d'erreur disque
; ~~~~~~~~~~~~~~~~~~~~~~~~
	EdT	79,<File already exists>
	EdT	80,<Directory not found>			204
	EdT	81,<File not found>				205
	EdT	82,<Illegal file name>				210
	EdT	83,<Disc is not validated>			213
	EdT	84,<Disc is write protected>			214
	EdT	85,<Directory not empty>			216
	EdT	86,<Device not available>			218
	EdT	87,<>						220
	EdT	88,<Disc full>					221
	EdT	89,<File is protected against deletion>		222
	EdT	90,<File is write protected>			223
	EdT	91,<File is protected against reading>		224
	EdT	92,<Not an AmigaDOS disc>			225
	EdT	93,<No disc in drive>				226
	EdT	94,<I/O error>
	EdT	95,<File format not recognised>
	EdT	96,<File already opened>
	EdT	97,<File not opened>
	EdT	98,<File type mismatch>
	EdT	99,<Input too long>
	EdT	100,<End of file>
	EdT	101,<Disc error>
	EdT	102,<Instruction not allowed here>
	EdT	103,<>
; Message d'erreur sprites/souris
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EdT	104,<>
	EdT	105,<Sprite error>
	EdT	106,<>
	EdT	107,<Syntax error in animation string>
	EdT	108,<Next without For in animation string>
	EdT	109,<Label not defined in animation string>
	EdT	110,<Jump To/Within autotest in animation string>
	EdT	111,<Autotest already opened>
	EdT	112,<Instruction only valid in autotest>
	EdT	113,<Animation string too long>
	EdT	114,<Label already defined in animation string>
	EdT	115,<Illegal instruction during autotest>
	EdT	116,<Amal bank not reserved>
	EdT	117,<>
	EdT	118,<>
	EdT	119,<>
; Messages d'erreur dialogues
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EdT	120,<Interface error: bad syntax>
	EdT	121,<Interface error: out of memory>
	EdT	122,<Interface error: label defined twice>
	EdT	123,<Interface error: label not defined>
	EdT	124,<Interface error: channel already defined>
	EdT	125,<Interface error: channel not defined>
	EdT	126,<Interface error: screen modified>
	EdT	127,<Interface error: variable not defined>
	EdT 	128,<Interface error: illegal function call>
	EdT	129,<Interface error: type mismatch>
	EdT	130,<Interface error: buffer to small>
	EdT	131,<Interface error: illegal number of parameters>
	EdT	132,<>
	EdT	133,<>
	EdT	134,<>
	EdT	135,<>
	EdT	136,<>
	EdT	137,<>
	EdT	138,<>
	EdT	139,<>
; Messages d'erreur DEVICE / PRINTER / SERIAL
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EdT	140,<Device already opened>
	EdT	141,<Device not opened>
	EdT	142,<Device cannot be opened>
	EdT	143,<Command not supported by device>
	EdT	144,<Device error>
; Messages Serie
	EdT	145,<Serial device already in use>
	EdT	146,<>
	EdT	147,<Invalid baud rate>
	EdT	148,<Out of memory (serial device)>
	EdT	149,<Bad parameter>
	EdT	150,<Hardware data overrun>
	EdT	151,<>
	EdT	152,<>
	EdT	153,<>
	EdT	154,<>
	EdT	155,<Timeout error>
	EdT	156,<Buffer overflow>
	EdT	157,<No data set ready>
	EdT	158,<>
	EdT	159,<Break detected>
	EdT	160,<Selected unit already in use>
; Message Printer
	EdT	161,<User canceled request>
	EdT	162,<Printer cannot output graphics>
	EdT	163,<>
	EdT	164,<Illegal print dimensions>
	EdT	165,<>
	EdT	166,<Out of memory (printer device)>
	EdT	167,<Out of internal memory (printer device)>
; Messages libraries
	EdT	168,<Library already opened>
	EdT	169,<Library not opened>
	EdT	170,<Cannot open library>
; Messages parallel
	EdT	171,<Parallel device already used>
	EdT	172,<Out of memory (parallel device)>
	EdT	173,<Invalid parallel parameter>
	EdT	174,<Parallel line error>
	EdT	175,<>
	EdT	176,<Parallel port reset>
	EdT	177,<Parallel initialisation error>
; Music errors
	EdT	178,<Wave not defined>				0
	EdT	179,<Sample not defined>			1
	EdT	180,<Sample bank not found>			2
	EdT	181,<256 characters for a wave>			3
	EdT	182,<Wave 0 and 1 are reserved>			4
	EdT	183,<Music bank not found>			5
	EdT	184,<Music not defined>				6
	EdT	185,<Can't open narrator>			7
	EdT	186,<Not a tracker module>			8
	EdT	187,<Cannot load med.library>			9
	EdT	188,<Cannot start med.library>			10
	EdT	189,<Not a med module>				11
	EdT	190,<>
	EdT	191,<>
	EdT	192,<>
; AREXX
; ~~~~~
	EdT	193,<Arexx port already opened>
	EdT	194,<Arexx library not found>
	EdT	195,<Cannot open Arexx port>
	EdT	196,<Arexx port not opened>
	EdT	197,<No Arexx message waiting>
	EdT	198,<Arexx message not answered to>
	EdT	199,<Arexx Device not interactive>
; Misc
; ~~~~
	EdT	200,<Cannot open powerpacker.library (v35)>
	dc.b	0,$ff
	even
.Error2

; Programmes AUTOLOAD
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	Auto2-Auto1
Auto1	EdT	1,<AMOSPro_Accessories:AMOSPro_Help/AMOSPro_Help.AMOS>
	EdT	2,<HelpMenu>
	EdT	3,<HelpHelp>
	EdT	4,<HelpKeyHelp>
	EdT	5,<HelpDirect>
	EdT	6,<HelpSyntax>
	EdT	7,<HelpBasics>
	EdT	8,<HelpScreenCon>
	EdT	9,<HelpObjects>
	EdT	10,<HelpAudio>
	EdT	11,<HelpInterface>
	EdT	12,<HelpIO>
	EdT	13,<HelpAmigaDos>
	EdT	14,<HelpDebug>
	EdT	15,<HelpMC>
	EdT	16,<HelpTables>
	EdT	17,<HelpInfo>
	EdT	18,<A>
	EdT	19,<A>
	EdT	20,<A>
	EdT	21,<B>
	EdT	22,<C>
	EdT	23,<D>
	EdT	24,<EDIT6>
	EdT	25,<AMOSPro_System:Interpreter_Config.AMOS>
	EdT	26,<AMOSPro_System:Editor_Config.AMOS>
	EdT	27,<EDIT1>
	EdT	28,<EDIT2>
	EdT	29,<EDIT3>
	EdT	30,<EDIT4>
	EdT	31,<EDIT5>
	EdT	32,<AMOSPro_Accessories:Object_Editor.AMOS>
	EdT	33,<GRABO>
	EdT	34,<AMOSPro_Accessories:Object_Editor.AMOS>
	EdT	35,<GRABI>
	EdT	36,<AMOSPro_Accessories:Sample_Bank_Maker.AMOS>
	EdT	37,<GRAB>
	EdT	38,<AMOSPro_Accessories:Resource_Bank_Maker.AMOS>
	EdT	39,<GRAB>
	EdT	40,<AMOSPro_Accessories:Disc_Manager.AMOS>
	EdT	41,<AMOSPro_Accessories:Object_Editor.AMOS>
	EdT	42,<AMOSPro_Accessories:Sample_Bank_Maker.AMOS>
	EdT	43,<AMOSPro_Accessories:Resource_Bank_Maker.AMOS>
	EdT	44,<AMOSPro_Tutorial:ReTokenise.AMOS>
	EdT	45,<AMOSPro_Compiler:Compiler_Shell.AMOS>
	EdT	46,<AMOSPro_Compiler:Tiny_Shell.AMOS>
	dc.b	0,$ff
	even
Auto2

; USER Menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	Menu2-Menu1
Menu1	EdT	1,<Edit Objects>
	EdT	2,<Edit Icons>
	EdT	3,<Edit Samples>
	EdT	4,<Edit Resource>
	EdT	5,<>
	EdT	6,<Disc Manager>
	EdT	7,<Object Ed.>
	EdT	8,<Sample Maker>
	EdT	9,<Resource Ed.>
	EdT	10,<>
	EdT	11,<Re-tokeniser>
	EdT	12,<Compiler Shell>
	EdT	13,<Compile>
	EdT	14,<>
	EdT	15,<>
	EdT	16,<>
	EdT	17,<>
	EdT	18,<>
	EdT	19,<>
	EdT	20,<>
	dc.b	0,$ff
	even
Menu2

; Definitions Menu
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dc.l	DMenu2-DMenu1
DMenu1	Incbin	"bin/Editor_Menus.bin"
	Even
DMenu2

Fin
		END
