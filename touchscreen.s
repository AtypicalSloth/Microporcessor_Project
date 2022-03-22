#include <xc.inc>

global	touchscreen_setup, touchscreen_read
extrn	LCD_delay_x4us

psect	udata_acs

touchscreen_pins:
    DRIVEA	EQU 4		    ; DRIVEA pin is port E4 (measure x)
    DRIVEB	EQU 5		    ; DRIVEB pin is port E5 (measure y)
    READX	EQU 2		    ; READX pin is port F2 (AN7)
    READY	EQU 5		    ; READY pin is port F5 (AN10)
    VREF	EQU 3		    ; Vref pin is port A3 (AN3)

readXH:	    ds	1
readXL:	    ds	1
readYH:	    ds	1
readYL:	    ds	1


psect	touchscreen_code, class=CODE

; F  :  1  2  3  4  5  6  7
; AN :  6  7  8  9 10 11  5


touchscreen_setup:
    clrf    TRISE, A		    ; Set port E to output
    setf    TRISF, A		    ; Set port F to input
    
    banksel ANCON1		    ; ANCON1 is not in access RAM
    bsf	    ANSEL10		    ; Set x-read pin to analog (RF5)
    
;    banksel ANCON0
;    bsf	    ANSEL7
    
    movlw   00101001B		    ; Select ANSEL10 to read from, turn on ADC
    movwf   ADCON0, A
    
    movlw   0x03
    movwf   ADCON1, A
    
    movlw   0xF6
    movwf   ADCON2, A
    
    movlb   0			    ; Return to data bank 0
    
    bsf	    PORTE, DRIVEA, A	    ; Apply voltage in x-direction
    NOP
    bcf	    PORTE, DRIVEB, A
    NOP
    
    return


touchscreen_read:
    bsf	    GO			    ; Start conversion by setting GO bit
    
touchscreen_loop:
    btfsc   GO			    ; Check if conversion has finished
    bra	    touchscreen_loop
    
    return