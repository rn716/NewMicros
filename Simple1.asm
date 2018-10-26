	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message, LCD_Clear_Display;, LCD_line2	    ; external LCD subroutines
	extern	LCD_Move_Display
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
keypadval   res 1   ; ...

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello World!\n"	; message, plus carriage return
	constant    myTable_l=.13	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	goto	start
	
	; ******* Main programme ****************************************
start 	nop
	
Character_Setup	    ; save all the characters at address which is coordinate
	movlw	b'00110001'	; 1 
	movwf	0x77
	movlw	b'00110010'	; 2
	movwf	0xB7
	movlw	b'00110011'	; 3
	movwf	0xD7
	movlw	b'00110100'	; 4
	movwf	0x7B
	movlw	b'00110101'	; 5
	movwf	0xBB
	movlw	b'00110110'	; 6
	movwf	0xDB
	movlw	b'00110111'	; 7
	movwf	0x7D
	movlw	b'00111000'	; 8
	movwf	0xBD
	movlw	b'00111001'	; 9
	movwf	0xDD
	movlw	b'00110000'	; 0
	movwf	0xBE
	movlw	b'01000001'	; A
	movwf	0x7E
	movlw	b'01000010'	; B
	movwf	0xDE
	movlw	b'01000011'	; C
	movwf	0xEE
	movlw	b'01000100'	; D
	movwf	0xED
	movlw	b'01000101'	; E
	movwf	0xEB
	movlw	b'01000110'	; F
	movwf	0xE7
	
	
	
;	movlw   0xff
;	movwf	TRISD, ACCESS	; PORTD all inputs
;	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
;	movlw	upper(myTable)	; address of data in PM
;	movwf	TBLPTRU		; load upper bits to TBLPTRU
;	movlw	high(myTable)	; address of data in PM
;	movwf	TBLPTRH		; load high byte to TBLPTRH
;	movlw	low(myTable)	; address of data in PM
;	movwf	TBLPTRL		; load low byte to TBLPTRL
;	movlw	myTable_l	; bytes to read
;	movwf 	counter		; our counter register

keypad_read_loop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; PortE pull-ups on 
	movlb	0x00		; set BSR back to Bank 0
	clrf	LATE
	movlw   0x0F
	movwf	TRISE, ACCESS	; PORTE all inputs
	movlw	0xFF		; 256 loop delay 
	movwf	delay_count
	call	delay
	movff	PORTE, keypadval; read in rows
	movlw	0x0f		
	cpfslt	keypadval
	goto	keypad_read_loop; go to top of loop as no button is pressed
	
	movlw   0xF0
	movwf	TRISE, ACCESS	; PORTE all inputs
	movlw	0xFF
	movwf	delay_count
	call	delay
	movf	PORTE, W	; read in columns	
	addwf	keypadval, F	; add to get full coordinates of button
	movlw	0xEF		
	cpfslt	keypadval	; go to top of loop as button has been released
	goto	keypad_read_loop
	movff	keypadval, FSR2L
	clrf	FSR2H

	movlw   0x01
	
	call	LCD_Write_Message
	movlw	0xff
	movwf	0x30
	movwf	0x20
	call	delayy
	call	delayy
	call	delayy
	call	delayy
	call	delayy
	call	delayy
	call	delayy
	call	delayy
	
	
	bra	keypad_read_loop
	
	
	
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	nop
	call	LCD_Write_Message

	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	nop
	call	UART_Transmit_Message

operations_loop
	movlw	0x00
	cpfsgt	PORTD, ACCESS
	goto    operations_loop	;wait for the input on PORTD
	movlw	0x01
	cpfsgt	PORTD, ACCESS
	goto	Clear_Display
	movlw	0x02
	cpfsgt	PORTD, ACCESS 
	goto	Move_Display
	goto	operations_loop
	
Clear_Display
	call	LCD_Clear_Display
	goto	operations_loop

Move_Display
	call	LCD_Clear_Display
	call	LCD_Move_Display
	goto	start
	
	
	goto	$		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return
	
	
; a delay subroutine

delayy  decfsz  0x30, F, ACCESS
        bra     delay1
        return  
	
delay1  movlw	0xff
	movwf	0x20
	call    delay2, 0
	nop

delay2  movwf   0x30, ACCESS
	call    delay3, 0
	nop
	decfsz  0x20, F, ACCESS
        bra     delay2
        return  
	
delay3  decfsz  0x30, F, ACCESS
        bra     delay3
        return  


	end