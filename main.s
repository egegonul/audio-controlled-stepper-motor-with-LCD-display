GPIO_PORTF_DATA 	EQU 0x400253FC
GPIO_PORTA_DATA			EQU	0x400043FC
array 			EQU 	0x20003500
SSI0_DR					EQU	0x40008008
SSI0_SR					EQU	0x4000800C
NVIC_ST_CTRL EQU 0xE000E010
mask		EQU 0XFFFF
TIMER0_TAILR		EQU 0x40030028
RV 					EQU 999000
LOW_FREQ	EQU	300
HIGH_FREQ	EQU 500
DIV			EQU 0X00800000


	
				AREA	main, READONLY, CODE
				THUMB
				EXTERN OutStr
				EXTERN InitSysTick
				EXTERN INIT_GPIO_E
				EXTERN  SystickHandler
				EXTERN  INIT_GPTM
				EXTERN  arm_cfft_q15
				EXTERN  arm_cfft_sR_q15_len256
				EXTERN  INIT_GPIO_F
				EXTERN	SCR_XY
				EXTERN	SCR_CHAR
				EXTERN	INIT_SPI
				EXTERN 	labels_lcd
				EXTERN	num_lcd
				EXTERN DELAY100
				EXPORT	__main
__main			
				BL		INIT_GPIO_E
				BL		INIT_GPIO_F
				BL		INIT_SPI
				BL 		InitSysTick  ;initialize systick with 2 Khz freq		
				BL		INIT_GPTM		
				MOV     R4,#0 ;initialize sound array offset
				MOV		R6,#0 ;initialize motor direction
				BL		labels_lcd ;initialize permanent labels on lcd
;				MOV		R0,#35
;				MOV		R1,#0
;				BL		SCR_XY	
;				MOV		R5,#764
;				BL 		num_lcd		
loop			CMP 	R4,#1024  ;when the array is full 
				BNE     loop
				LDR		R1,=NVIC_ST_CTRL ;disable interrupt during fft calc
				LDR		R0,[R1]
				BIC		R0,#0X01
				STR		R0,[R1]
				STR		R0,[R1]
				LDR  	R0,=arm_cfft_sR_q15_len256
				LDR		R1,=array
				MOV		R2,#0
				MOV		R3,#1
				BL		arm_cfft_q15
				
				
				;------find the max index
				LDR		R1,=array
				MOV		R3,#4	;start from i=2
				MOV		R4,#0	;initialize the max as 0
				LDR		R5,=mask
find_max        CMP		R3,#512
				BEQ		exit
				ADD		R8,R1,R3
				LDRSH	R2,[R8]  ;the real part
				ADD		R3,R3,#2
				ADD		R8,R1,R3
				LDRSH	R0,[R8]  ;the imaginary part
				SMULBB	R2,R2,R2 ;square of the real part
				SMULBB	R0,R0,R0  ;square of the imag 
				ADD		R2,R2,R0  ;magnitude squared
				CMP		R2,R4 ;compare the magnitude to max
				MOVHI   R4,R2  ;set new max
				SUBHI	R7,R3,#2   ;index of the max
				ADD		R3,R3,#2
				B		find_max
exit			MOV		R3,#4

				UDIV	R7,R7,R3
				MOV		R2,#2000
				MUL     R7,R7,R2
				MOV		R2,#256
				UDIV	R7,R7,R2  ;frequency is calculated 
				
				;print amplitude
			
				MOV		R0,#35
				MOV		R1,#1
				BL		SCR_XY	
				LDR		R3,=DIV
				UDIV	R4,R4,R3
				ADD		R4,R4,#5
				
				MOV		R5,R4
				BL 		num_lcd
				
				LDR R1,=GPIO_PORTF_DATA
				CMP     R4,#10
				MOVLS	R0,#0
				STRLS	R0,[R1]
				BLS		done
				
				;light the led correspondingly
				MOV R2,#LOW_FREQ
				MOV	R3,#HIGH_FREQ
				LDR R1,=GPIO_PORTF_DATA
				CMP R7,R2
				MOVCC R0,#0X2
				STRCC R0,[R1]
				BCC led_set
				CMP	R7,R3
				MOVCC R0,#0X8
				MOVHI R0,#0X4
				STR R0,[R1]
led_set
				
				
				
				
				
				;adjust the speed
				
				LDR R1, =TIMER0_TAILR ; initialize match clock
				LDR R2,=RV
				UDIV R0,R2,R7
				STR R0, [R1]
				
				
				
				;print the frequency
done			MOV		R0,#35
				MOV		R1,#0
				BL		SCR_XY	
				MOV		R5,R7
				BL 		num_lcd		
				LDR		R1,=NVIC_ST_CTRL ;reenable interrupt after fft calc
				LDR		R0,[R1]
				ORR		R0,#0X01
				STR		R0,[R1]
				MOV		R4,#0
				B		loop
				
			
			
					