
;Nested Vector Interrupt Controller registers
NVIC_EN0_INT19		EQU 0x00080000 ; Interrupt 19 enable
NVIC_EN0			EQU 0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4			EQU 0xE000E410 ; IRQ 16 to 19 Priority Register
	

SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control
	
; 16/32 Timer Registers
TIMER0_CFG			EQU 0x40030000
TIMER0_TAMR			EQU 0x40030004
TIMER0_CTL			EQU 0x4003000C
TIMER0_IMR			EQU 0x40030018
TIMER0_RIS			EQU 0x4003001C ; Timer Interrupt Status
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR		EQU 0x40030028 ; Timer interval
TIMER0_TAPR			EQU 0x40030038
TIMER0_TAR			EQU	0x40030048 ; Timer register
RV 					EQU 999000
DIV					EQU 16000
	
;SYMB
;OL				DIRECTIVE	VALUE			COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC ; data a d d r e s s t o a l l pi n s
GPIO_PORTB_DIR 		EQU 		0x40005400
GPIO_PORTB_AFSEL 	EQU 		0x40005420
GPIO_PORTB_DEN 		EQU 		0x4000551C
GPIO_PORTB_PCTL		EQU 		0x4000552C
GPIO_PORTB_AMSEL	EQU 		0x40005528 ; Analog e n a bl e
SYSCTL_RCGCGPIO 	EQU 		0x400FE608
GPIO_PORTB_PUR 		EQU 		0x40005510 ;PUR a c t u al a d d r e s s
PUB 				EQU 		0x04 ; o r #2 1 1 1 1 0 0 0 0
IOB 				EQU			0x00
	
	
					AREA 	init_timer, CODE, READONLY
					THUMB
					EXPORT	INIT_GPTM
INIT_GPTM	PROC
			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x02 ; set bit 5 for port B
			STR R0, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =GPIO_PORTB_DIR ; set direction of PF2
			LDR R0, [R1]
			ORR R0, R0, #0x0F ; set bit for output
			STR R0, [R1]
			LDR R1, =GPIO_PORTB_AFSEL ; regular port function
			LDR R0, [R1]
			BIC R0, R0, #0xFF
			STR R0, [R1]
			LDR R1, =GPIO_PORTB_PCTL ; no alternate function
			LDR R0, [R1]
			BIC R0, R0, #0xFF
			STR R0, [R1]
			LDR R1, =GPIO_PORTB_AMSEL ; disable analog
			MOV R0, #0
			STR R0, [R1]
			LDR R1, =GPIO_PORTB_DEN ; enable port digital
			LDR R0, [R1]
			ORR R0, R0, #0x0F
			STR R0, [R1]
			LDR R0 ,=GPIO_PORTB_PUR
			MOV R1 ,#PUB
			STR R1 ,[R0]
			LDR	R1,=GPIO_PORTB_DATA
			MOV	R2, #0X08 
			STR	R2,[R1]  ;initialize output pins
			MOV	R3,#0	;initialize motor direction
		
			LDR R1, =SYSCTL_RCGCTIMER ; Start Timer0
			LDR R2, [R1]
			ORR R2, R2, #0x01
			STR R2, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =TIMER0_CTL ; disable timer during setup 
			LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
			LDR R1, =TIMER0_CFG ; set 16 bit mode
			MOV R2, #0x04
			STR R2, [R1]
			LDR R1, =TIMER0_TAMR
			MOV R2, #0x02 ; set to periodic, count down
			STR R2, [R1]
			LDR R1, =TIMER0_TAILR ; initialize match clocks
			LDR R2, =RV
			STR R2, [R1]
			LDR R1, =TIMER0_TAPR
			LDR	R2,=DIV
			MOV R2, #9600 ; divide clock by 16 to
			STR R2, [R1] ; get 1us clocks
			LDR R1, =TIMER0_IMR ; enable timeout interrupt
			MOV R2, #0x01
			STR R2, [R1]
			LDR R1, =NVIC_PRI4
			LDR R2, [R1]
			AND R2, R2, #0x00FFFFFF ; clear interrupt 19 priority
			ORR R2, R2, #0x40000000 ; set interrupt 19 priority to 2
			STR R2, [R1]
; NVIC has to be enabled
; Interrupts 0-31 are handled by NVIC register EN0
; Interrupt 19 is controlled by bit 19
; enable interrupt 19 in NVIC
			LDR R1, =NVIC_EN0
			MOVT R2, #0x08 ; set bit 19 to enable interrupt 19
			STR R2, [R1]
; Enable timer
			LDR R1, =TIMER0_CTL
			LDR R2, [R1]
			ORR R2, R2, #0x03 ; set bit0 to enable
			STR R2, [R1] ; and bit 1 to stall on debug
			BX	LR
			ENDP