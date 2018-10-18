	#include p18f87k22.inc
	
	code
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	goto	start
	; ******* My data and where to put it in RAM *
myTable db	0x0f,0x03
	constant myArray=0x400	; Address in RAM for data
	constant counter=0x10	; Address of counter variable
	; ******* Main programme *********************
start 	nop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; Port E pull-ups on
	movlb	0x00		; set BSR back to Bank 0
	movlw   0x0
	movwf	TRISD, ACCESS	; Port D all outputs
	movwf	TRISC, ACCESS	; Port C all outputs
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.2		; 8 bytes to read
	movwf 	counter		; our counter register
loop 	movlw 	0xA
	movwf	PORTD		; OE disables memory outputs; keeps 2nd OE high
	movlw 	0x0		
	movwf	TRISE, ACCESS	; Port E all outputs enabled
	nop
	tblrd*+			; move one byte, PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTE   ; move read data from TABLAT to PORTE
	nop
	movlw	0xB		; so OE is still high to disable memory output of byte 1
	movwf 	PORTD		; CP lo to hi - clock rising slope for writing
	nop
	
				; write to Memory 2
				
	movlw 	0xff		
	movwf	TRISE, ACCESS	; Port E all outputs disabled/enable input
	nop			
	movlw	0x09		; OE low to enable memory output of byte 1 - CP stays hi
	movwf 	PORTD		; CP hi to lo - clock falling slope - no action
	nop
	movff	PORTE, PORTC	; move the byte in PORTE onto PORTC
	movlw 	0xA
	movwf	PORTD		; OE disables memory outputs of byte 1

	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	
	goto	0

	end
