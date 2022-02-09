
RELOAD_VALUE 		EQU 0XFFFF; reload value
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control
; 16/32 Timer Registers
TIMER1_CFG			EQU 0x40031000;;for A and B 16bit/32bit selection,0x04 =16bit
TIMER1_TAMR			EQU 0x40031004;SET FUNC OF TIMER,;[1:0] 1=oneshot,2=periodic,3=capture
;[2]=0 edge count,1=edge time , [4]=0 count down,1=up
TIMER1_CTL			EQU 0x4003100C;TIMER3   (en/dis,fall/ris/both)
TIMER1_IMR			EQU 0x40031018

TIMER1_TAILR		EQU 0x40031028 ; Timer interval;
;in 16bit,value for count up or down .(if down, up to this number)
TIMER1_TAPR			EQU 0x40031038 ;presecalar
FULL 				EQU 0xFFFFFF
	


					AREA init_timer , CODE, READONLY
					THUMB
					EXPORT INIT_TIMER


INIT_TIMER PROC

					LDR R1,=SYSCTL_RCGCTIMER ;clock for timer
					LDR R0,[R1]
					ORR R0,#0x02
					STR R0,[R1]
					
					LDR R1,=TIMER1_CTL;disable timer first
					LDR R0,[R1]
					BIC R0,#0xFF
					STR R0,[R1]
					
					LDR R1,=TIMER1_CFG;
					LDR R0,[R1]
					ORR R0,#0x4 ;select 16-bit MODE
					STR R0,[R1]
					
					LDR R1,=TIMER1_TAMR;
					LDR R0,[R1]
					ORR R0,#0x7 ;capture mode
					STR R0,[R1]
					
					
					LDR R1, =TIMER1_TAILR
					LDR R2, =FULL
					STR R2, [R1]

					LDR R1, =TIMER1_TAPR
					LDR R2, =FULL ; set the max timer extension
					STR R2, [R1]

					
					; Enable timer
					LDR R1, =TIMER1_CTL
					LDR R2, [R1]
					ORR R2, R2, #0x07 ; set bit0 to enable
					STR R2, [R1] ; and bit 1 to stall on debug


					BX LR
					ENDP
	
