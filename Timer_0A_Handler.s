GPIO_PORTF_DATA		EQU	0x40025038; DATA REGISTER WITH MASK PF1 PF2 FP3	
COMPARE_VALUE		EQU 0x04  ;used for the gpio state comparison
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR		EQU 0x40030028 ; Timer interval
LOW					EQU	0x00000400
HIGH				EQU	0x00000100 ;%20 duty cycle
					
					AREA 	my_handler_for_timer, CODE, READONLY
					THUMB
					EXTERN  StepCtrl
					EXPORT 	Timer_0A_Handler
;done in also previous video
					
Timer_0A_Handler 	PROC
					PUSH {R0-R5}
					LDR R1,=TIMER0_ICR ;clear interrupt flag
					MOV R0,#0x01
					STR R0,[R1]
					
					PUSH {LR}
					BL	StepCtrl
					POP {LR}
					
					POP {R0-R5}
					BX 	LR
					ENDP