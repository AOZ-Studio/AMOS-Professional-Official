;Token table

	dc.w -1,L_HAM
	dc.b "ha",$80+'m',"0",-1
	dc.w -1,L_EHB
	dc.b "eh",$80+'b',"0",-1
	dc.w -1,L_SuperHires
	dc.b "superhire",$80+'s',"0",-1
	dc.w -1,L_AGA
	dc.b "ag",$80+'a',"0",-1
	dc.w -1,L_ECS
	dc.b "ec",$80+'s',"0",-1
      ifd CREATOR
	dc.w -1,L_XHardMin
	dc.b "xhard mi",$80+'n',"0",-1
	dc.w -1,L_YHardMin
	dc.b "yhard mi",$80+'n',"0",-1
      else
	dc.w -1,L_XHardMin
	dc.b "x hard mi",$80+'n',"0",-1
	dc.w -1,L_YHardMin
	dc.b "y hard mi",$80+'n',"0",-1
      endif

	dc.w L_IscrOpenPub0,-1
	dc.b "!iscreen open publi",$80+'c',"I0,0,0,0,0",-2
;	dc.w L_IscrOpenPubNT,-1
;	dc.b $80,"I0,0,0,0,0,0",-2
	dc.w L_IscrOpenPubNM,-1
	dc.b $80,"I0,0,0,0,0,2",-2
	dc.w L_IscrOpenPublic,-1
	dc.b $80,"I0,0,0,0,0,2,0",-1
	dc.w L_IscreenOpen0,-1			;Obsolete - see v1.3b
	dc.b "!iscreen_ope",$80+'n',"I0,0,0,0,0",-2
;	dc.w L_IscreenOpenNT,-1			;Obsolete
;	dc.b $80,"I0,0,0,0,0,0",-2
	dc.w L_IscreenOpenNM,-1			;Obsolete
	dc.b $80,"I0,0,0,0,0,2",-2
	dc.w L_IscreenOpen,-1			;Obsolete
	dc.b $80,"I0,0,0,0,0,2,0",-1
	dc.w L_IscreenClose,-1
	dc.b "iscreen clos",$80+'e',"I0",-1
	dc.w L_CurIscrFront,-1
	dc.b "!iscreen to fron",$80+'t',"I",-2
	dc.w L_IscrFront,-1
	dc.b $80,"I0",-1
	dc.w L_CurIscrBack,-1
	dc.b "!iscreen to bac",$80+'k',"I",-2
	dc.w L_IscrBack,-1
	dc.b $80,"I0",-1
	dc.w -1,L_IscreenBase
	dc.b "iscreen bas",$80+'e',"0",-1
	dc.w -1,L_GetCISWidth
	dc.b "!iscreen widt",$80+'h',"0",-2
	dc.w -1,L_GetIscrWidth
	dc.b $80,"00",-1
	dc.w -1,L_GetCISHeight
	dc.b "!iscreen heigh",$80+'t',"0",-2
	dc.w -1,L_GetIscrHeight
	dc.b $80,"00",-1
	dc.w -1,L_GetCISCols
	dc.b "!iscreen colou",$80+'r',"0",-2
	dc.w -1,L_GetIscrCols
	dc.b $80,"00",-1
	dc.w -1,L_GetCISMode
	dc.b "!iscreen mod",$80+'e',"0",-2
	dc.w -1,L_GetIscrMode
	dc.b $80,"00",-1
	dc.w L_IscreenDisp,-1
	dc.b "iscreen displa",$80+'y',"I0,0,0,0,0",-1
	dc.w L_IscreenOfs,-1
	dc.b "iscreen offse",$80+'t',"I0,0,0",-1
	dc.w L_IscreenCopy2,-1
	dc.b "!iscreen cop",$80+'y',"I0t0",-2
	dc.w L_IscreenCopy,-1
	dc.b $80,"I0,0,0,0,0t0,0,0",-1
	dc.w -1,L_XIhard
	dc.b "x ihar",$80+'d',"00",-1
	dc.w -1,L_XIscreen
	dc.b "x iscree",$80+'n',"00",-1
	dc.w -1,L_YIhard
	dc.b "y ihar",$80+'d',"00",-1
	dc.w -1,L_YIscreen
	dc.b "y iscree",$80+'n',"00",-1
	dc.w L_IscreenSet,-1	;Obsolete - see v1.3
	dc.b "set_iscree",$80+'n',"I0",-1
	dc.w -1,L_IscreenGet	;Obsolete
	dc.b "i_cree",$80+'n',"0",-1

	dc.w L_IwindowOpenWB_NT,-1	;Obsolete - see v1.3
	dc.b "!iwindow_open w",$80+'b',"I0,0,0,0,0",-2
	dc.w L_IwindowOpenWB_NF,-1	;Obsolete
	dc.b $80,"I0,0,0,0,0,2",-1
	dc.w L_IwindowCloseWB,-1
	dc.b "iwindow close w",$80+'b',"I0",-1
	dc.w L_IwindowSetWB,-1
	dc.b "set iwindow w",$80+'b',"I0",-1
	dc.w -1,L_IwindowOnWB
	dc.b "iwindow on w",$80+'b',"0",-1
	dc.w L_IwindowOpenNT,-1		;Obsolete - see v1.3
	dc.b "!iwindow_ope",$80+'n',"I0,0,0,0,0",-2
	dc.w L_IwindowOpenNF,-1		;Obsolete
	dc.b $80,"I0,0,0,0,0,2",-1
	dc.w L_IwindowClose,-1
	dc.b "iwindow clos",$80+'e',"I0",-1
	dc.w L_CurIwinToFront,-1	;Obsolete - see v1.3b
	dc.b "!iwindow_to fron",$80+'t',"I",-2
	dc.w L_IwindowToFront,-1	;Obsolete
	dc.b $80,"I0",-1
	dc.w L_CurIwinToBack,-1		;Obsolete
	dc.b "!iwindow_to bac",$80+'k',"I",-2
	dc.w L_IwindowToBack,-1		;Obsolete
	dc.b $80,"I0",-1
	dc.w L_IwindowMove,-1		;Obsolete
	dc.b "iwindow_mov",$80+'e',"I0,0,0",-1
	dc.w L_IwindowSize,-1		;Obsolete
	dc.b "iwindow_siz",$80+'e',"I0,0,0",-1
	dc.w -1,L_CurIwindowX		;Obsolete
	dc.b "!iwindow_",$80+'x',"0",-2
	dc.w -1,L_IwindowX		;Obsolete
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowY		;Obsolete
	dc.b "!iwindow_",$80+'y',"0",-2
	dc.w -1,L_IwindowY		;Obsolete
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowWidth	;Obsolete
	dc.b "!iwindow_widt",$80+'h',"0",-2
	dc.w -1,L_IwindowWidth		;Obsolete
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowHeight	;Obsolete
	dc.b "!iwindow_heigh",$80+'t',"0",-2
	dc.w -1,L_IwindowHeight		;Obsolete
	dc.b $80,"00",-1
	dc.w -1,L_IwindowBase
	dc.b "iwindow bas",$80+'e',"0",-1
	dc.w -1,L_IwindowActiveNum
	dc.b "iwindow active nu",$80+'m',"0",-1
	dc.w -1,L_IwindowActiveBase
	dc.b "iwindow active bas",$80+'e',"0",-1
	dc.w -1,L_IwindowActive
	dc.b "iwindow activ",$80+'e',"0",-1
	dc.w L_IwindowActivate,-1
	dc.b "iwindow activat",$80+'e',"I0",-1
	dc.w L_IwindowSet,-1		;Obsolete
	dc.b "set_iwindo",$80+'w',"I0",-1
	dc.w -1,L_IwindowGet		;Obsolete
	dc.b "i_indo",$80+'w',"0",-1

	dc.w L_IwaitKey,-1
	dc.b "iwait ke",$80+'y',"I",-1
	dc.w L_IwaitMouse,-1
	dc.b "iwait mous",$80+'e',"I",-1
	dc.w L_IwaitVbl,-1
	dc.b "iwait vb",$80+'l',"I",-1
	dc.w L_Iwait,-1
	dc.b "iwai",$80+'t',"I0",-1
	dc.w -1,L_Iscan
	dc.b "isca",$80+'n',"0",-1
	dc.w -1,L_Ishift
	dc.b "ishif",$80+'t',"0",-1
	dc.w -1,L_ImouseKey
	dc.b "imouse ke",$80+'y',"0",-1
	dc.w -1,L_ImouseX
	dc.b "imouse ",$80+'x',"0",-1
	dc.w -1,L_ImouseY
	dc.b "imouse ",$80+'y',"0",-1
	dc.w -1,L_GetChar
	dc.b "iget",$80+'$',"2",-1
	dc.w -1,L_ReadChar
	dc.b "iread char",$80+'$',"2",-1
	dc.w -1,L_ReadStr
	dc.b "iread str",$80+'$',"2",-1
	dc.w -1,L_ReadInt
	dc.b "iread in",$80+'t',"0",-1

	dc.w -1,L_ItextBase
	dc.b "itext bas",$80+'e',"0",-1
	dc.w -1,L_ItextLength
	dc.b "itext lengt",$80+'h',"02",-1
	dc.w L_SetIfont1,-1
	dc.b "!set ifon",$80+'t',"I2",-2
	dc.w L_SetIfont,-1
	dc.b $80,"I2,0",-1
      ifd CREATOR
	dc.w -1,L_IfontName
	dc.b "fonti",$80+'$',"2",-1
	dc.w -1,L_IfontBase
	dc.b "fonti bas",$80+'e',"0",-1
	dc.w -1,L_IfontHeight
	dc.b "fonti heigh",$80+'t',"0",-1
      else
	dc.w -1,L_IfontName
	dc.b "ifont",$80+'$',"2",-1
	dc.w -1,L_IfontBase
	dc.b "ifont bas",$80+'e',"0",-1
	dc.w -1,L_IfontHeight
	dc.b "ifont heigh",$80+'t',"0",-1
      endc

	dc.w L_IlocateGr,-1
	dc.b "ilocate g",$80+'r',"I0,0",-1
	dc.w L_Ilocate,-1
	dc.b "ilocat",$80+'e',"I0,0",-1
	dc.w -1,L_Ixgr
	dc.b "ixg",$80+'r',"0",-1
	dc.w -1,L_Iygr
	dc.b "iyg",$80+'r',"0",-1
	dc.w L_IgrWriting,-1
	dc.b "igr writin",$80+'g',"I0",-1
	dc.w L_Itext,-1
	dc.b "itex",$80+'t',"I0,0,2",-1
	dc.w L_Iwrite0,-1
	dc.b "!iwrit",$80+'e',"I",-2
	dc.w L_Iwrite,-1
	dc.b $80,"I2",-1
	dc.w L_Icls,-1
	dc.b "!icl",$80+'s',"I",-2
	dc.w L_IclsCol,-1
	dc.b $80,"I0",-2
	dc.w L_IclsXY,-1		;v1.1 (14/6/94)
	dc.b $80,"I0,0,0t0,0",-1
	dc.w L_SetInk1,-1
	dc.b "!iin",$80+'k',"I0",-2
	dc.w L_SetInk2,-1
	dc.b $80,"I0,0",-2
	dc.w L_SetInk,-1
	dc.b $80,"I0,0,0",-1
	dc.w L_Iplot,-1
	dc.b "!iplo",$80+'t',"I0,0",-2
	dc.w L_IplotInk,-1
	dc.b $80,"I0,0,0",-1
	dc.w L_IdrawTo,-1
	dc.b "idraw t",$80+'o',"I0,0",-1
	dc.w L_Idraw,-1
	dc.b "idra",$80+'w',"I0,0t0,0",-1
	dc.w L_Ibox,-1
	dc.b "ibo",$80+'x',"I0,0t0,0",-1
	dc.w L_Ibar,-1
	dc.b "iba",$80+'r',"I0,0t0,0",-1
	dc.w L_Iellipse,-1
	dc.b "iellips",$80+'e',"I0,0,0,0",-1
	dc.w L_Icircle,-1
	dc.b "icircl",$80+'e',"I0,0,0",-1
;	dc.w L_Iflood,-1
;	dc.b 1,"floo",$80+'d',"I0,0,0",-1

	dc.w -1,L_IreqFileMulti0
	dc.b "!irequest file multi",$80+'$',"2",-2
	dc.w -1,L_IreqFileMulti1
	dc.b $80,"22",-2
	dc.w -1,L_IreqFileMulti
	dc.b $80,"22,2",-1
	dc.w -1,L_IreqFileNext
	dc.b "irequest file next",$80+'$',"2",-2
	dc.w -1,L_IrequestFile0
	dc.b "!irequest file",$80+'$',"2",-2
	dc.w -1,L_IrequestFile1
	dc.b $80,"22",-2
	dc.w -1,L_IrequestFile2
	dc.b $80,"22,2",-2
	dc.w -1,L_IrequestFile
	dc.b $80,"22,2,2",-1
	dc.w -1,L_IrequestFont0
	dc.b "!irequest font",$80+'$',"2",-2
	dc.w -1,L_IrequestFont
	dc.b $80,"22",-1
	dc.w -1,L_IreqScrWidth
	dc.b "ireq scr widt",$80+'h',"0",-1
	dc.w -1,L_IreqScrHeight
	dc.b "ireq scr heigh",$80+'t',"0",-1
	dc.w -1,L_IreqScrCols
	dc.b "ireq scr colou",$80+'r',"0",-1
	dc.w -1,L_IreqScrMode
	dc.b "ireq scr mod",$80+'e',"00",-1
	dc.w -1,L_IrequestScreen0
	dc.b "!irequest scree",$80+'n',"0",-2
	dc.w -1,L_IrequestScreen
	dc.b $80,"02",-1

	dc.w L_IcolourSet,-1
	dc.b "set icolou",$80+'r',"I0,0",-1
	dc.w -1,L_IcolourGet
	dc.b "icolou",$80+'r',"00",-1

;Palette statements.  Since Palette doesn't work reliably, it just goes to
;an RTS now.

    ifne 0

	dc.w L_Ipalette1,-1
	dc.b "!ipalett",$80+'e',"I0",-2
	dc.w L_Ipalette2,-1
	dc.b $80,"I0,0",-2
	dc.w L_Ipalette3,-1
	dc.b $80,"I0,0,0",-2
	dc.w L_Ipalette4,-1
	dc.b $80,"I0,0,0,0",-2
	dc.w L_Ipalette5,-1
	dc.b $80,"I0,0,0,0,0",-2
	dc.w L_Ipalette6,-1
	dc.b $80,"I0,0,0,0,0,0",-2
	dc.w L_Ipalette7,-1
	dc.b $80,"I0,0,0,0,0,0,0",-2
	dc.w L_Ipalette8,-1
	dc.b $80,"I0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette9,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0",-2
      ifd CREATOR
	dc.w L_Ipalette11,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette12,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette13,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette14,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette15,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette16,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette17,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette18,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette19,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette20,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette21,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette22,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette23,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette24,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette25,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette26,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette27,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette28,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette29,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette30,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette31,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette32,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-1
      else
;Ipalette Pro with 10 parameters seems to work for all parameter counts > 9.
;We need these entries so that adding functions later doesn't cause programs
;written with earlier versions of the extension to become corrupted.
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette10,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-1
      endc

    else	;ifne 0

	dc.w L_Ipalette0,-1
	dc.b "!ipalett",$80+'e',"I0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
	dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-2
	dc.w L_Ipalette0,-1
 dc.b $80,"I0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",-1

    endc
;;;;;;;;
;v0.6 (94/04/30)
	dc.w -1,L_IrequestWarning1
	dc.b "!irequest warnin",$80+'g',"02",-2
	dc.w -1,L_IrequestWarning3
	dc.b $80,"02,2,2",-2
	dc.w -1,L_IrequestWarning
	dc.b $80,"02,2,2,2",-2
	dc.w L_IrequestError1,-1
	dc.b "!irequest erro",$80+'r',"I2",-2
	dc.w L_IrequestError2,-1
	dc.b $80,"I2,2",-2
	dc.w L_IrequestError,-1
	dc.b $80,"I2,2,2",-1
	dc.w -1,L_IrequestMessage2
	dc.b "!irequest messag",$80+'e',"02,2",-2
	dc.w -1,L_IrequestMessage
	dc.b $80,"02,2,2",-1
	dc.w L_IreqSetDefTitle,-1
	dc.b "irequest def titl",$80+'e',"I2",-1

;;;;;;;;
;v0.7 (94/05/04)
	dc.w -1,L_CurIwindowStatus	;Obsolete - see v1.3b
	dc.b "!iwindow_statu",$80+'s',"0",-2
	dc.w -1,L_IwindowStatus
	dc.b $80,"00",-1

	dc.w L_Iclw,-1
	dc.b "!icl",$80+'w',"I",-2
	dc.w L_IclwCol,-1
	dc.b $80,"I0",-2
	dc.w L_IclwXY,-1		;v1.1 (14/6/94)
	dc.b $80,"I0,0,0t0,0",-1

;;;;;;;;
;v1.0 (94/05/15)
	dc.w L_Ierror,-1
	dc.b "ierro",$80+'r',"I0",-1
	dc.w -1,L_IerrStr
	dc.b "ierr",$80+'$',"2",-1
	dc.w -1,L_Ierr
	dc.b "ier",$80+'r',"0",-1
	dc.w L_ItrapOn,-1
	dc.b "itrap o",$80+'n',"I",-1
	dc.w L_ItrapOff,-1
	dc.b "itrap of",$80+'f',"I",-1
	dc.w -1,L_Ierrtrap
	dc.b "ierrtra",$80+'p',"0",-1

;;;;;;;;
;v1.1 (94/06/23)

;Menu instructions
;	dc.w L_SetImenu1,L_GetImenu1
;	dc.b "!imenu",$80+'$',"V20",-2
;	dc.w L_SetImenu2,L_GetImenu2
;	dc.b $80,"V20,0",-2
;	dc.w L_SetImenu,L_GetImenu
;	dc.b $80,"V20,0,0",-1
	dc.w L_SetImenu1,-1
	dc.b "!set imen",$80+'u',"I2,0",-2
	dc.w L_SetImenu2,-1
	dc.b $80,"I2,0,0",-2
	dc.w L_SetImenu,-1
	dc.b $80,"I2,0,0,0",-1
	dc.w -1,L_Ichoice
	dc.b "ichoic",$80+'e',"00",-1
	dc.w L_ImenuOn,-1
	dc.b "imenu o",$80+'n',"I",-1
	dc.w L_ImenuOff,-1
	dc.b "imenu of",$80+'f',"I",-1

;Miscellaneous
	dc.w L_IpasteIcon,-1
	dc.b "ipaste ico",$80+'n',"I0,0,0",-1
	dc.w L_IgetSprPal0,-1
	dc.b "!iget sprite palett",$80+'e',"I",-2
	dc.w L_IgetSprPal,-1
	dc.b $80,"I0",-1
	dc.w L_IgetIconPal0,-1
	dc.b "!iget icon palett",$80+'e',"I",-2
	dc.w L_IgetIconPal,-1
	dc.b $80,"I0",-1

;;;;;;;;
;v1.1b (94/07/23)
	dc.w -1,L_RTHere
	dc.b "reqtools her",$80+'e',"0",-1


;;;;;;;;
;v1.2 (94/08/14)

;Gadgets
	dc.w L_ReserveIgadget0,-1
	dc.b "!reserve igadge",$80+'t',"I",-2
	dc.w L_ReserveIgadget,-1
	dc.b $80,"I0",-1
	dc.w L_SetIgadToggle0,-1
	dc.b "!set igadget toggl",$80+'e',"I0,0,0,0,0",-2
	dc.w L_SetIgadToggle,-1
	dc.b $80,"I0,0,0,0,0,0",-1
	dc.w L_SetIgadHslider,-1
	dc.b "set igadget hslide",$80+'r',"I0,0,0,0,0,0,0,0,0",-1
	dc.w L_SetIgadVslider,-1
	dc.b "set igadget vslide",$80+'r',"I0,0,0,0,0,0,0,0,0",-1
	dc.w L_SetIgadString0,-1
	dc.b "!set igadget strin",$80+'g',"I0,0,0,0,0,0",-2
	dc.w L_SetIgadString1,-1
	dc.b $80,"I0,0,0,0,0,0,2",-2
	dc.w L_SetIgadString,-1
	dc.b $80,"I0,0,0,0,0,0,2,0",-1
	dc.w L_SetIgadInt0,-1
	dc.b "!set igadget in",$80+'t',"I0,0,0,0,0",-2
	dc.w L_SetIgadInt1,-1
	dc.b $80,"I0,0,0,0,0,0",-2
	dc.w L_SetIgadInt,-1
	dc.b $80,"I0,0,0,0,0,0,0",-1
	dc.w L_IgadgetOnAll,-1
	dc.b "!igadget o",$80+'n',"I",-2
	dc.w L_IgadgetOn,-1
	dc.b $80,"I0",-1
	dc.w L_IgadgetOffAll,-1
	dc.b "!igadget of",$80+'f',"I",-2
	dc.w L_IgadgetOff,-1
	dc.b $80,"I0",-1
	dc.w L_IgadgetActiveAll,-1
	dc.b "!igadget activ",$80+'e',"I",-2
	dc.w L_IgadgetActive,-1
	dc.b $80,"I0",-1
	dc.w L_IgadgetInactiveAll,-1
	dc.b "!igadget inactiv",$80+'e',"I",-2
	dc.w L_IgadgetInactive,-1
	dc.b $80,"I0",-1
	dc.w -1,L_IgadgetReadStr
	dc.b "igadget read",$80+'$',"20",-1
	dc.w -1,L_IgadgetRead
	dc.b "igadget rea",$80+'d',"00",-1

;Other
	dc.w L_Icentre,-1
	dc.b "icentr",$80+'e',"I2",-1
	dc.w L_AmosIscrCopy2,-1
	dc.b "!amos iscreen cop",$80+'y',"I0t0",-2
	dc.w L_AmosIscrCopy,-1
	dc.b $80,"I0,0,0,0,0t0,0,0",-1

;;;;;;;;
;v1.2b (94/09/23)

	dc.w L_SetIgadHit,-1
	dc.b "set igadget hi",$80+'t',"I0,0,0,0,0",-1
	dc.w L_SetIpens,-1
	dc.b "set ipen",$80+'s',"I0,0",-1
	dc.w -1,L_IgadgetDown
	dc.b "igadget dow",$80+'n',"00",-1

      ifd FOR_LATER
	dc.w L_IgadToBank,-1
	dc.b "igadget to ban",$80+'k',"I0",-1
	dc.w L_BankToIgad,-1
	dc.b "bank to igadge",$80+'t',"I0",-1
      endc

	dc.w L_IwindowActivateWB,-1
	dc.b "iwindow activate w",$80+'b',"I0",-1
	dc.w L_IgetIcon5,-1
	dc.b "!iget ico",$80+'n',"I0,0,0t0,0",-2
	dc.w L_IgetIcon6,-1
	dc.b $80,"I0,0,0,0t0,0",-2
	dc.w L_IgetIcon7,-1
	dc.b $80,"I0,0,0,0,0t0,0",-1
	dc.w -1,L_IwindowActWidth
	dc.b "iwindow actual widt",$80+'h',"0",-1
	dc.w -1,L_IwindowActHeight
	dc.b "iwindow actual heigh",$80+'t',"0",-1
	dc.w L_SetIgadValueStr,-1
	dc.b "set igadget value",$80+'$',"I0,2",-1
	dc.w L_SetIgadValue,-1
	dc.b "set igadget valu",$80+'e',"I0,0",-1

;;;;;;;;
;v1.3 (95/03/23)
	dc.w L_IwindowOpenWB_NT,-1
	dc.b "!iwindow open w",$80+'b',"I0,0,0,0,0",-2
	dc.w L_IwindowOpenWB_NF,-1
	dc.b $80,"I0,0,0,0,0,2",-2
	dc.w L_IwindowOpenWB,-1
	dc.b $80,"I0,0,0,0,0,2,0",-1
	dc.w L_IwindowOpenNT,-1
	dc.b "!iwindow ope",$80+'n',"I0,0,0,0,0",-2
	dc.w L_IwindowOpenNF,-1
	dc.b $80,"I0,0,0,0,0,2",-2
	dc.w L_IwindowOpen,-1
	dc.b $80,"I0,0,0,0,0,2,0",-1

	dc.w -1,L_IwaitEventVbl
	dc.b "iwait event vb",$80+'l',"0",-1
	dc.w -1,L_IwaitEvent
	dc.b "iwait even",$80+'t',"0",-1
	dc.w -1,L_IeventData
	dc.b "ievent dat",$80+'a',"0",-1
	dc.w -1,L_IeventVbl
	dc.b "ievent vb",$80+'l',"0",-1
	dc.w -1,L_IeventMouse			;MOUSEBUTTONS
	dc.b "ievent mous",$80+'e',"0",-1
	dc.w -1,L_IeventGadget			;GADGETUP
	dc.b "ievent gadge",$80+'t',"0",-1
	dc.w -1,L_IeventMenu			;MENUPICK
	dc.b "ievent men",$80+'u',"0",-1
	dc.w -1,L_IeventClose			;CLOSEWINDOW
	dc.b "ievent clos",$80+'e',"0",-1
	dc.w -1,L_IeventKey			;RAWKEY
	dc.b "ievent ke",$80+'y',"0",-1

	dc.w L_IbufReset,-1
	dc.b "iclear al",$80+'l',"I",-1
	dc.w L_IbufResetKey,-1
	dc.b "iclear ke",$80+'y',"I",-1
	dc.w L_IbufResetMouse,-1		;Now a no-op
	dc.b "iclear mous",$80+'e',"I",-1
	dc.w L_IbufResetMenu,-1
	dc.b "iclear men",$80+'u',"I",-1

	dc.w L_SetIwindowTitle,-1
	dc.b "set iwindow titl",$80+'e',"I0,2,2",-1


;;;;;;;;
;v1.3a (95/04/03)
	dc.w -1,L_Ipoint
	dc.b "!ipoin",$80+'t',"00,0",-1

;;;;;;;;
;v1.3b (95/06/17 ... long time no work! <sigh> )
	dc.w L_SetIscrTitle,-1
	dc.b "!set iscreen titl",$80+'e',"I2",-2
	dc.w L_SetCurIscrTitle,-1
	dc.b $80,"I2,0",-1
	dc.w -1,L_CurIscrTitleHeight
	dc.b "!iscreen title heigh",$80+'t',"0",-2
	dc.w -1,L_IscrTitleHeight
	dc.b $80,"00",-1
	dc.w L_IscrOpenFront,-1
	dc.b "iscreen open fron",$80+'t',"I",-1
	dc.w L_IscrOpenBack,-1
	dc.b "iscreen open bac",$80+'k',"I",-1
	dc.w L_IscrAmosCopy2,-1
	dc.b "!iscreen amos cop",$80+'y',"I0t0",-1
	dc.w L_IscrAmosCopy,-1
	dc.b $80,"I0,0,0,0,0t0,0,0",-1

	dc.w L_IwindowToFrontWB,-1
	dc.b "iwindow to front w",$80+'b',"I0",-1
	dc.w L_IwindowToBackWB,-1
	dc.b "iwindow to back w",$80+'b',"I0",-1
	dc.w L_IwindowMoveWB,-1
	dc.b "iwindow move w",$80+'b',"I0,0,0",-1
	dc.w L_IwindowSizeWB,-1
	dc.b "iwindow size w",$80+'b',"I0,0,0",-1
	dc.w -1,L_IwindowXWB
	dc.b "iwindow x w",$80+'b',"00",-1
	dc.w -1,L_IwindowYWB
	dc.b "iwindow y w",$80+'b',"00",-1
	dc.w -1,L_IwindowWidthWB
	dc.b "iwindow width w",$80+'b',"00",-1
	dc.w -1,L_IwindowHeightWB
	dc.b "iwindow height w",$80+'b',"00",-1
	dc.w -1,L_IwindowStatusWB
	dc.b "iwindow status w",$80+'b',"00",-1

	dc.w L_IFlush, -1
	dc.b "i flus",$80+'h',"I0",-1

;Command replacements.  These are commands which need to be redefined so
;that the Creator tokeniser doesn't see the old definition before a new one
;which begins with the same character sequence.

	dc.w L_IscreenOpen0,-1
	dc.b "!iscreen ope",$80+'n',"I0,0,0,0,0",-2
;	dc.w L_IscreenOpenNT,-1
;	dc.b $80,"I0,0,0,0,0,0",-2
	dc.w L_IscreenOpenNM,-1
	dc.b $80,"I0,0,0,0,0,2",-2
	dc.w L_IscreenOpen,-1
	dc.b $80,"I0,0,0,0,0,2,0",-1
	dc.w L_IscreenSet,-1	;Doing this as same-named inst/func works not!
	dc.b "set iscree",$80+'n',"I0",-1
	dc.w -1,L_IscreenGet
	dc.b "iscree",$80+'n',"0",-1

	dc.w L_CurIwinToFront,-1
	dc.b "!iwindow to fron",$80+'t',"I",-2
	dc.w L_IwindowToFront,-1
	dc.b $80,"I0",-1
	dc.w L_CurIwinToBack,-1
	dc.b "!iwindow to bac",$80+'k',"I",-2
	dc.w L_IwindowToBack,-1
	dc.b $80,"I0",-1
	dc.w L_IwindowMove,-1
	dc.b "iwindow mov",$80+'e',"I0,0,0",-1
	dc.w L_IwindowSize,-1
	dc.b "iwindow siz",$80+'e',"I0,0,0",-1
	dc.w -1,L_CurIwindowX
	dc.b "!iwindow ",$80+'x',"0",-2
	dc.w -1,L_IwindowX
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowY
	dc.b "!iwindow ",$80+'y',"0",-2
	dc.w -1,L_IwindowY
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowWidth
	dc.b "!iwindow widt",$80+'h',"0",-2
	dc.w -1,L_IwindowWidth
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowHeight
	dc.b "!iwindow heigh",$80+'t',"0",-2
	dc.w -1,L_IwindowHeight
	dc.b $80,"00",-1
	dc.w -1,L_CurIwindowStatus
	dc.b "!iwindow statu",$80+'s',"0",-2
	dc.w -1,L_IwindowStatus
	dc.b $80,"00",-1
	dc.w L_IwindowSet,-1
	dc.b "set iwindo",$80+'w',"I0",-1
	dc.w -1,L_IwindowGet
	dc.b "iwindo",$80+'w',"0",-1

;;;;;;;; End of token table
	dc.w 0
