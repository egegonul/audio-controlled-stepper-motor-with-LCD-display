


GPIO_PORTE_DIR 		EQU 0x40024400 ; Port Direction
GPIO_PORTE_AFSEL	EQU 0x40024420 ; Alt Function enable
GPIO_PORTE_DEN 		EQU 0x4002451C ; Digital Enable
GPIO_PORTE_AMSEL 	EQU 0x40024528 ; Analog enable
GPIO_PORTE_PCTL 	EQU 0x4002452C ; Alternate Functions
	
;___________________________ADC REGISTERS___________________________
ADC0_ADCACTSS		EQU	0x40038000 ;enable/disable reg for sequencer
ADC0_ADCEMUX		EQU 0x40038014 ; 15:12 bits need to be cleared for ;trigger
ADC0_ADCSSCTL3		EQU	0x400380A4 ; IE0 and END0 bit to tell ;sequencer stop or start etc.
ADC0_ADCPC			EQU	0x40038FC4 ; sample rate  3:0 BIT  set 0x01	
ADC0_ADCPSSI		EQU 0x40038028 ;  start sampling.
ADC0_RIS			EQU	0x40038004 ;RIS REG FOR FLAG
ADC0_ADCSSFIFO3 	EQU	0x400380A8 ; FIFO REG for sequ.3
ADC0_ISC			EQU	0x4003800C ;CLEAR REG FOR FLAG
ADC0_SSMUX3			EQU 0x400380A0	
RCGCADC				EQU 0x400FE638 ; Run Clock Gate Control ADC
;base addr for ADC0 0x40038000
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control						
					
					AREA	messages, DATA, READONLY
					THUMB

print				DCB "Measured Voltage is : "
					DCB	0x4

new_line	    	DCB "\n "
					DCB	0x4
floating_point		DCB "."
					DCB	0x4
voltage 			DCB " V\n"
					DCB	0x4

					
					AREA	main, READONLY, CODE
					THUMB
					EXTERN OutStr
					EXTERN OutChar
					EXTERN convrt
					EXTERN DELAY100
					EXPORT	__main
__main				
					
					LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
					LDR R0, [R1]
					ORR R0, R0, #0x10 ; set bit 6 for port E
					STR R0, [R1]
					NOP ; allow clock to settle
					NOP
					NOP
					NOP
					NOP
					LDR R0,=GPIO_PORTE_DIR
					MOV R1,#0x00 ;set as input
					STR R1,[R0]
					LDR R0,=GPIO_PORTE_AFSEL
					MOV	R1,#0x08 ;enable alternate func for ;pin3
					STR R1,[R0]
					LDR R0,=GPIO_PORTE_AMSEL
					MOV R1,#0x08 ; Enable analog for pin 3
					STR R1,[R0]
					
					LDR R0,=RCGCADC
					MOV R1,#0x01 ; start adc clock
					STR R1,[R0]
					NOP
					NOP
					NOP
					NOP
					NOP
					NOP
					
					LDR R1, = ADC0_ADCACTSS ;disable adc ;sequencer during configuration
					MOV R0,#0x00
					STR R0,[R1]
					
					LDR R1,=ADC0_ADCEMUX ;Sample triggered by ;software
					MOV R0,#0x00
					STR R0,[R1]
					
					LDR R1,=ADC0_SSMUX3
					MOV R0,#0x00 ; AIN0 is the input channel ;(this is default)
					STR R0,[R1]
					
					LDR R1,=ADC0_ADCSSCTL3
					MOV R0,#0x06 ;IE0 and END0 set, first sample ;is last
					STR R0,[R1]
					
					LDR R1,=ADC0_ADCPC  ;125ksps sampling rate
					MOV R0,#0X01
					STR R0,[R1]
					
					LDR R1,=ADC0_ADCACTSS ;
					MOV R0,#0X08
					STR R0,[R1]
					
					
loop				LDR R1,=ADC0_ADCPSSI
					MOV R0,#0x08;sampling started for ss3
					STR R0,[R1]
					
					LDR R1,=ADC0_RIS ;check flag
					LDR R0,[R1]
					
					CMP R0,#0X08 ;if it is set go on
					BNE loop
					
					LDR R1,=ADC0_ADCSSFIFO3
					LDR R0,[R1] ; fifo val in the R0
					
					MOV R6,#330 ; this is for boundary voltage
					MOV R7,#4095 ;max val that can be for 3.3v in ;decimal
					
					MUL R0,R6
					UDIV R0,R7 ;R0 is the result between 0 and ;330 now 					
					SUB  R0,R0, #165
					;MOV	R3,R0
					MOV R8,#100 ;will be used for calculations
					
					
					;lets assume  R0 val is= 241(for  better ;understanding)
					UDIV R10,R0,R8 ;241/100 =2 will be stored in ;R10, FIRST DIGIT
					;ADD R5,R10,#0X30 ; to print first digit, add ;0x30 for ASCII conversion
					LSL	R7,R10,#8
					
					MUL R3,R10,R8 ; multiply first digit with ;100, 2*100=200 IN R3
					SUB R2,R0,R3 ;241-200 =41 stored in R2, this ;step for second digit
					
					MOV R9,#10; will be used for division
					UDIV R11,R2,R9; 41/10 =4 in R11 , SECOND ;DIGIT FOUND
					;ADD R5,R11,#0X30 ;CONVERT TO ASCII 
					LSL	R8,R11,#4
					
					ORR R8,R8,R7
					
					MUL R12,R11,R9;4X10 =40 R12 ,Find last digit ;by multiply r11 with 10
					SUB R2,R12 ;41-40 =1 R11 , take difference to ;find last digit
					;ADD R12,R2,#0X30 ;add 0x30 for ascii ;conversion
					MOV R5,R2 
					
					ORR R5,R8,R5

					;LDR R5,=voltage
					;BL OutStr		


					LDR R5,=print
					BL OutStr
					;lets assume  R0 val is= 241(for  better ;understanding)
					UDIV R10,R0,R8 ;241/100 =2 will be stored in ;R10, FIRST DIGIT
					ADD R5,R10,#0X30 ; to print first digit, add ;0x30 for ASCII conversion
					BL OutChar ; print the ascii char for first ;digit.
					
					LDR R5,=floating_point 
					BL OutStr ;PRINT dot on terminal
					
					MUL R3,R10,R8 ; multiply first digit with ;100, 2*100=200 IN R3
					SUB R2,R0,R3 ;241-200 =41 stored in R2, this ;step for second digit
					
					MOV R9,#10; will be used for division
					UDIV R11,R2,R9; 41/10 =4 in R11 , SECOND ;DIGIT FOUND
					ADD R5,R11,#0X30 ;CONVERT TO ASCII 
					BL OutChar
					
					MUL R12,R11,R9;4X10 =40 R12 ,Find last digit ;by multiply r11 with 10
					SUB R2,R12 ;41-40 =1 R11 , take difference to ;find last digit
					ADD R12,R2,#0X30 ;add 0x30 for ascii ;conversion
					MOV R5,R12 
					BL OutChar

					LDR R5,=voltage
					BL OutStr		
					LDR R1,=ADC0_ISC ;clr flag
					MOV R0,#0x08
					STR R0,[R1]
					BL DELAY100
					B loop
					END