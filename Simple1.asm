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
myTable db	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07
	constant myArray=0x400	; Address in RAM for data
	constant counter=0x10	; Address of counter variable
	; ******* Main programme *********************
start 	nop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; PortE pull-ups on
	movlb	0x00		; set BSR back to Bank 0
	movlw   0x0
	movwf	TRISD, ACCESS	; Port D all outputs
	movwf	TRISC, ACCESS	; Port C all outputs
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.8		; 8 bytes to read
	movwf 	counter		; our counter register
loop 	movlw 	0x02
	movwf	PORTD		; OE disables memory outputs
	movlw 	0x0		
	movwf	TRISE, ACCESS	; Port E all outputs enabled
	tblrd*+			; move one byte, PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTE   ; move read data from TABLAT to PORTE
	;movlw	0x00
	;movwf 	PORTD		; CP already set to low on line 30
	movlw	0x03		; so OE is still high to disable PORTE output
	movwf 	PORTD		; CP lo to hi - clock rising slope for writing
	
				;write to Memory 2
	
	clrf    TRISE	; Port E all outputs disabled/enable input
	movlw	0x01		; OE low to enable memory output - CP stays hi
	movwf 	PORTD		; CP hi to lo - clock falling slope - no action
	
	movff	PORTE, PORTC
	movlw 	0x02
	movwf	PORTD		; OE disables memory outputs
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	
	goto	0

	end
