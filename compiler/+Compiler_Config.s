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

		dc.l 	"CCt1"		Code de securite!
		dc.l	Txt2-Txt1
Txt1
;		Messages systeme
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		EdT	1,<>
		EdT	2,<S:AMOSPro_Interpreter_Config>
		EdT	3,<Compiler.Lib>
		EdT	4,<AMOS.library>
		EdT	5,<Header_Cli.Lib>
		EdT	6,<Header_Backstart.Lib>
		EdT	7,<Header_AMOS.AMOS>
		EdT	8,<Def_Compiled>
		EdT	9,<Ram:>
		EdT	10,<Ram:Temp_Program.AMOS>
		EdT	11,<Ram:Compiled_Program.AMOS>
		EdT	12,<>
		EdT	13,<>
		EdT	14,<>
		EdT	15,<>

		EdT	16,<- - - - - - - - - - - - - - - >
		EdT	17,<AMOSPro Compiler by F. Lionet >
		EdT	18,<� 1993 Europress Software Ltd.>
		EdT	19,<- - - - - - - - - - - - - - - >
		EdT	20,<Tokenising program...>
		EdT	21,<Testing program...>
		EdT	22,<Opening libraries...>
		EdT	23,<Compiling program...>
		EdT	24,<Copying library routines...>
		EdT	25,<>
		EdT	26,<Copying system data...>
		EdT	27,<Copying memory banks...>
		EdT	28,<Opening source: >
		EdT	29,<Closing object: >
		EdT	30,<Total memory used: >
		EdT	31,<Object length: >
		EdT	32,< bytes.>
		EdT	33,<>
		EdT	34,< at line >
		EdT	35,<>
		EdT	36,<>
		EdT	37,<>
		EdT	38,<>
		EdT	39,<>

;		Messages d'erreur
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		EdT	40,<Error in command line>
		EdT	41,<Error in compiler configuration's command line>
		EdT	42,<Extension not loaded>
		EdT	43,<Cannot get icon informations>
		EdT	44,<Disk error>
		EdT	45,<Out of memory>
		EdT	46,<Cannot open system libraries>
		EdT	47,<Cannot uncode procedure>
		EdT	48,<Compilation aborted>
		EdT	49,<Nothing to compile>
		EdT	50,<Bad editor configuration file>
		EdT	51,<Cannot open math libraries>
		EdT	52,<Not an AMOS program>
		EdT	53,<Label not defined at the same level of procedure>
		EdT	54,<Program already compiled>
		EdT	55,<Program structures too long: compile with the -l option>
		EdT	56,<Program already tokenised>
		EdT	57,<Cannot open source program>
		EdT	58,<Bad interpreter config>
		EdT	59,<Cannot find APSystem folder>
		EdT	60,<Line too long>
		EdT	61,<Cannot load editor configuration>
		EdT	62,<Cannot load interpreter configuration>
		EdT	63,<Cannot load compiler configuration>
		EdT	64,<Division by zero>
		EdT	65,<Overflow at line>
		EdT	66,<Bad compiler configuration file>
		EdT	67,<Cannot load AMOS.Library>
		EdT	68,<Disk is not validated>
		EdT	69,<Disk is write protected>
		EdT	70,<Disk full>
		EdT	71,<>

;		Message pour COMPILER.AMOS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		EdT	72,<>
		EdT	72,<1121100000000000000000000000000000000000000>

;                           0  0     1   1     2        3   3     4
;                           1234567890123456789012345678901234567890123
;                          / |||         |         |         |
;                         / / | \Compiled \         \Compiler \
;                        S  D T  \program  \         \Setup    \
;                        o  e y   \setup 1  \   2     \      1  \      2
;                        u  s p
;                        r  t e
;                        c  i
;                        e  n
;
; Compiled program setup:
; ~~~~~~~~~~~~~~~~~~~~~~~
; 4- Include errors
; 5- Create default screen
; 6- Send amos to back
; 7- CLI program back
; ...
; 14- Long jump
; 15- Include AMOS.library
; ...
; 24- Copy all into ram
; 25- Leave libs upon exit
; 26- Keep APCMP
; 27- Squash
; ...
; 34- Iff anim?
; 35- Track module
; 36- Bell
; 37- Animated buttons

; Iff anim
		EdT	73,<>
; Track module
		EdT	74,<>
; Repertoire par defaut
		EdT	75,<>
		EdT	76,<>
		EdT	77,<>
		EdT	78,<>
		EdT	79,<>
		EdT	80,<>
		EdT	81,<>
		EdT	82,<>
		EdT	83,<>
		EdT	84,<>
		EdT	85,<>
		EdT	86,<>
		EdT	87,<>

		dc.b	0,$FF

Txt2
