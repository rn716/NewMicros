#include p18f87k22.inc
    

highbyte    res 1   ; reserve one byte for a high byte variable
lowbyte	    res 1   ; reserve one byte for a low byte variable
    
_8_16_multiply	; multiply 0x04D2 by 0x8A
    movlw   0x04
    movwf   highbyte
    movlw   0xD2
    movwf   lowbyte
    
    movlw   0x8A
    mulwf   lowbyte
    
