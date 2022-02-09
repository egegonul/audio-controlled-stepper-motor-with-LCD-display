GPIO_PORTB_DATA 	EQU 		0x400053FC
	
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN      INIT_GPIO
			EXTERN		InitSysTick
			EXTERN		SystickHandler
			EXTERN		DELAY100
			EXTERN		StepCtrl
            EXPORT 		__main
__main 		PROC
			MOV			R4,#1	;initialize motor speed
			BL			InitSysTick ;initialize systick
			BL 			INIT_GPIO  ;initialize gpio port
			LDR			R1,=GPIO_PORTB_DATA
			MOV			R2, #0X08 
			STR			R2,[R1]  ;initialize output pins
			MOV			R3,#0	;initialize motor direction
			;check if a button is pressed
loop		LDR			R0,[R1]
			LSR			R0,R0,#4
			BL			DELAY100
			LDR			R2,[R1]
			LSR			R2,R2,#4
			CMP			R2,R0
			BNE			loop ;return to loop if button is not confirmed
unpress		LDR			R0,[R1]
			LSR			R0,R0,#4
			CMP			R0,R2
			BEQ			unpress
			CMP 		R2,#0XF
			BEQ			loop
			CMP			R2,#0xe
			MOVEQ		R3,#1
			CMP			R2,#0Xd
			MOVEQ		R3,#2
			CMP			R2,#0xb
			ADDEQ		R4,R4,#1 ;increase speed
			BEQ			speed
			CMP			R2,#0X7
			SUBEQ		R4,R4,#1 ;decrease speed
			BEQ			speed
			B			loop
speed		BL			InitSysTick ;speed is modified by changin the systick interval
			B			loop
			END
				
			