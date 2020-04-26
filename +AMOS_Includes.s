;---------------------------------------------------------------------
;    **   **   **  ***   ***
;   ****  *** *** ** ** **
;  **  ** ** * ** ** **  ***
;  ****** **   ** ** **    **
;  **  ** **   ** ** ** *  **
;  **  ** **   **  ***   ***
;---------------------------------------------------------------------
;  Includes all includes - Francois Lionet / Europress 1992
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
;----------------------------------------------------------------------

; These ones are for me!
		IFND	Finale
Finale:		equ 	1
		ENDC
		IFND	VDemo
VDemo:		equ 	0
		ENDC
		IFND	ROnly
ROnly:		equ 	0
		ENDC
;
		Incdir  "includes/"
		Include "lvo/exec_lib.i"
		Include "lvo/dos_lib.i"
		Include "lvo/layers_lib.i"
		Include "lvo/graphics_lib.i"
		Include "lvo/mathtrans_lib.i"
		Include "lvo/rexxsyslib_lib.i"
		Include "lvo/mathffp_lib.i"
		Include "lvo/mathieeedoubbas_lib.i"
		Include "lvo/intuition_lib.i"
		Include "lvo/diskfont_lib.i"
		Include "lvo/icon_lib.i"
		Include "lvo/console_lib.i"

		Include	"+Debug.s"		Just one flag
		Include "+Equ.s"
		RsSet	DataLong
		Include	"+CEqu.s"
		Include	"+WEqu.s"
		Include "+LEqu.s"

		IFNE	Debug
		Include	"+Music_Labels.s"
		ENDC
