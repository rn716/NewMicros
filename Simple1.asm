	#include p18f87k22.inc
	
	code
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	movlw 	0x0
	movwf	TRISC, ACCESS	    ; Port C all outputs
	goto	start
	; ******* My data and where to put it in RAM *
myTable db	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07
	constant myArray=0x400	; Address in RAM for data
	constant counter=0x10	; Address of counter variable
	; ******* Main programme *********************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.8		; 8 bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move read data from TABLAT to (FSR0), increment FSR0
	movff 	PORTC
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	
	goto	0

	end
