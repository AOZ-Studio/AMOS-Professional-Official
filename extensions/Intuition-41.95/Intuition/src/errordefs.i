;Custom error numbers
E_16C	equ 0	;Only 16 colours allowed on non-AGA hires screen
E_UOS	equ 1	;Unable to open screen
E_KS2	equ 2	;Need Kickstart 2.0 or higher
E_UOW	equ 3	;Unable to open window
E_CW0	equ 4	;Window 0 can't be closed
E_MW0	equ 5	;Window 0 can't be modified
E_WNO	equ 6	;Window not opened
E_WTS	equ 7	;Window too small
E_WTL	equ 8	;Window too large
E_IWP	equ 9	;Illegal window parameter
E_WNC	equ 10	;Window not closed
E_NWB	equ 11	;Unable to open Workbench
;These are standard errors, but we duplicate them here so our error trapper
;can catch them.
E_PI	equ 12	;Program interrupted
E_IFC	equ 13	;Illegal function call
E_OOM	equ 14	;Out of memory
E_FNA	equ 15	;Font not available
E_SNO	equ 16	;Screen not opened
E_ISP	equ 17	;Illegal screen parameter
E_INC	equ 18	;Illegal number of colours
;More of our errors.
E_SNC	equ 19	;Screen not closed
E_IND	equ 20	;Icon not defined
E_NIB	equ 21	;Icon bank not defined
E_NES	equ 22	;Error text not available  [if prog compiled w/o error text]
E_OND	equ 23	;Object not defined
E_NOB	equ 24	;Object bank not defined
E_BWC	equ 25  ;Backward coordinates
E_MAA	equ 26	;Menu already active
E_INT	equ 27	;Internal error, code xxxxxxxx
E_IN2	equ 28	;Internal error, code xxxxxxxx, subcode yyyyyyyy
E_NRT	equ 29	;ReqTools.library version 2 or higher required
E_TMG	equ 30	;Only 65535 gadgets allowed
E_GAA	equ 31	;Gadget already active
E_WGT	equ 32	;Wrong gadget type
E_GND	equ 33	;Gadget not defined
E_GNR	equ 34	;Gadget not reserved
E_ASN	equ 35	;Valid AMOS screen numbers range from 0 to 7
E_BND	equ 36	;Bank not defined
E_FNU	equ 37	;Bank format not understood
E_IDT	equ 38	;Inconsistent data
