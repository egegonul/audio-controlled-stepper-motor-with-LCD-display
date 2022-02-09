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
GPIO_PORTB_DATA 	EQU 0x400053FC
array 				EQU 0x20003500

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

;SYMBOL				DIRECTIVE	VALUE			COMMENT
					AREA  systic_handler , CODE, READONLY
					THUMB
					EXTERN OutStr
					EXTERN OutChar
					EXPORT		SystickHandler
SystickHandler		PROC
					PUSH {R0-R3}
					PUSH {R7-R12}
loop				LDR R1,=ADC0_ADCPSSI
					MOV R0,#0x08;sampling started for ss3
					STR R0,[R1]
					
					LDR R1,=ADC0_RIS ;check flag
					LDR R0,[R1]
					
					CMP R0,#0X08 ;if it is set go on
					BNE loop
					
					LDR R1,=ADC0_ADCSSFIFO3
					LDR R0,[R1] ; fifo val in the R0
					LSL	R0,R0,#4
					MOV R8,#330 ; this is for boundary voltage
					MOV R7,#4095 ;max val that can be for 3.3v in ;decimal
					
;					MUL R0,R8
;					UDIV R0,R7 ;R0 is the result between 0 and ;330 now 					
;					SUB  R0,R0, #160
;					
					LDR R1,=array
					ADD R1,R1,R4
					STRH R0,[R1],#2
					MOV	R2,#0
					STRH R2,[R1]
					ADD	R4,R4,#4
					
					
;----------------------------------------------------------------------------------------------------					
					
					
;					MOV R8,#100 ;will be used for calculations
;					
;					LDR R5,=print
;					PUSH  {LR}
;					;BL OutStr
;					POP  {LR}
;					;lets assume  R0 val is= 241(for  better ;understanding)
;					UDIV R10,R0,R8 ;241/100 =2 will be stored in ;R10, FIRST DIGIT
;					ADD R5,R10,#0X30 ; to print first digit, add ;0x30 for ASCII conversion
;					PUSH  {LR}
;					BL OutChar ; print the ascii char for first ;digit.
;					POP  {LR}
;					
;					LDR R5,=floating_point 
;					PUSH  {LR}
;					BL OutStr ;PRINT dot on terminal
;					POP  {LR}
;					
;					MUL R3,R10,R8 ; multiply first digit with ;100, 2*100=200 IN R3
;					SUB R2,R0,R3 ;241-200 =41 stored in R2, this ;step for second digit
;					
;					MOV R9,#10; will be used for division
;					UDIV R11,R2,R9; 41/10 =4 in R11 , SECOND ;DIGIT FOUND
;					ADD R5,R11,#0X30 ;CONVERT TO ASCII 
;					PUSH  {LR}
;					BL OutChar
;					POP  {LR}
;					
;					MUL R12,R11,R9;4X10 =40 R12 ,Find last digit ;by multiply r11 with 10
;					SUB R2,R12 ;41-40 =1 R11 , take difference to ;find last digit
;					ADD R12,R2,#0X30 ;add 0x30 for ascii ;conversion
;					MOV R5,R12 
;					PUSH  {LR}
;					BL OutChar
;					POP  {LR}

;					LDR R5,=new_line
;					PUSH  {LR}
;					BL OutStr
;					POP  {LR}
					LDR R1,=ADC0_ISC ;clr flag
					MOV R0,#0x08
					STR R0,[R1]
					POP {R0-R3}
					POP {R7-R12}
					BX	LR
					ENDP
						
	