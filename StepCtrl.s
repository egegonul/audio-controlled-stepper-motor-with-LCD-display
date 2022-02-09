
;SYMBOL				DIRECTIVE	VALUE			COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC ; data a d d r e s s t o a l l pi n s

	
	
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		StepCtr, READONLY, CODE
            THUMB
            EXPORT 		StepCtrl
StepCtrl 	PROC
			PUSH		{R0-R5}	
			LDR			R1,=GPIO_PORTB_DATA
			LDR			R2,[R1]
			AND			R2,R2,#0X0F
			CMP			R6,#0 ; direction of the motor
			BEQ         done
			CMP			R6,#2
			BEQ			left
right		CMP			R2,#0X08
			MOVEQ		R2,#0X01
			BEQ			skip
			LSL			R2,R2,#1
skip		STR			R2,[R1]
			B			done
left		CMP			R2,#0X01
			MOVEQ		R2,#0X08
			BEQ			skip2
			LSR			R2,R2,#1
skip2		STR			R2,[R1]
done		POP			{R0-R5}
			BX			LR
			ENDP
		
			
			
			