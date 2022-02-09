NVIC_ST_CTRL EQU 0xE000E010
NVIC_ST_RELOAD EQU 0xE000E014
NVIC_ST_CURRENT EQU 0xE000E018
SHP_SYSPRI3 EQU 0xE000ED20

RV1 EQU 0x000117D0
RV2 EQU 0x000217D0
RV3 EQU 0x000317D0
RV4 EQU 0x000417D0
RV5 EQU 0x000517D0
RV6 EQU 0x000617D0
RV7 EQU 0x000717D0
RV8 EQU 0x000817D0
RELOAD_VALUE EQU 0x7D0

;*********************************************************
; I n i t i a l i z a t i o n a r e a
;*********************************************************
;LABEL 		DIRECTIVE VALUE COMMENT
			AREA initisr , CODE, READONLY, ALIGN=2
			THUMB
			EXPORT InitSysTick
InitSysTick PROC
; f i r s t d i s a b l e system tim e r and the r e l a t e d i n t e r r u p t
; then c o n f i g u r e i t t o u se i s t e r n a l o s c i l l a t o r PIOSC/4
			PUSH {R0,R1}
			LDR R1 , =NVIC_ST_CTRL
			MOV R0 , #0
			STR R0 , [ R1 ]
			; now s e t the time out p e ri o d
			LDR R1 , =NVIC_ST_RELOAD
			LDR R0 , =RELOAD_VALUE
			STR R0 , [ R1 ]
			; time out p e ri o d i s s e t
			; now s e t the c u r r e n t time r v al u e t o the time out v al u e
			LDR R1 , =NVIC_ST_CURRENT
			STR R0 , [ R1 ]
			; c u r r e n t tim e r = time out p e ri o d
			; now s e t the p r i o r i t y l e v e l
			LDR R1 , =SHP_SYSPRI3
			MOV R0 , #0x60000000
			STR R0 , [ R1 ]
			; p r i o r i t y i s s e t t o 2
			; now e n a bl e system tim e r and the r e l a t e d i n t e r r u p t
			LDR R1 , =NVIC_ST_CTRL
			MOV R0 , #0x03
			STR R0 , [ R1 ]
			; s e t up f o r system time i s now c omple te
			POP  {R0,R1}
			BX LR
			ENDP