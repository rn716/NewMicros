#include p18f87k22.inc

	global  multiply816

acs0	udata_acs   ; reserve data space in access ram
highbyte    res 1   ; reserve one byte for a high byte variable
lowbyte	    res 1   ; reserve one byte for a low byte variable

highprod    res 1 	    
middleprod  res 1
lowprod	    res 1

	    
main	code
	
	
	    
multiply816 ; 0x04D2 times 0x8A	
    movlw   0x04
    movwf   highbyte    ;high
    movlw   0xD2
    movwf   lowbyte    ;low
    
    movlw   0x8A
    mulwf   lowbyte	    ;multiply W(0x8A) by lowbyte
    movff   PRODL, lowprod
    nop
    movff   PRODH, middleprod
    nop
    
    movlw   0x8A
    mulwf   highbyte	    ;multiply W(0x8A) by highbyte
    movf    PRODL, 0, 0	    ;move the lower byte of the multiplication to W
    addwfc  middleprod	    ;add W to middleprod
    nop
    movff   PRODH, highprod
    nop

    return
    
    end
    
