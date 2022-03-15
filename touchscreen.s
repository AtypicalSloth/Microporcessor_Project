#include <xc.inc>

global	touchscreen_setup, touchscreen_detect

psect	udata_acs

touchscreen_pins:
    DRIVEA  EQU	4		    ; DRIVEA pin is port E4 (measure x)
    DRIVEB  EQU	5		    ; DRIVEB pin is port E5 (measure y)
    READX   EQU	2		    ; READX pin is port F2 (AN7)
    READY   EQU	5		    ; READY pin is port F5 (AN10)
    VREF    EQU 3		    ; Vref pin is port A3 (AN3)

readXH:	    ds	1
readXL:	    ds	1
readYH:	    ds	1
readYL:	    ds	1


psect	code, class=CODE

org	0x800
; F  :  1  2  3  4  5  6  7
; AN :  6  7  8  9 10 11  5

; Reference voltage: AN3

touchscreen_setup:
    clrf    TRISA, A		    ; Set port A to output
    clrf    TRISE, A		    ; Set port E to output
    setf    TRISF, A		    ; Set port F to input
    
    bsf	    PORTA, VREF, A	    ; Set Vref to 5V
    
    banksel ANCON0		    ; ANCON0 is not in access ram
    bcf	    ANSEL3		    ; Set reference voltage pin to digital
    bsf	    ANSEL7		    ; Set y-read pin to analog
    banksel ANCON1		    ; ANCON0 is not in access ram
    bsf	    ANSEL10		    ; Set x-read pin to analog
    
    movlw   00010000B		    ; Trigger from ECCP2, external +Vref,
    movwf   ADCON1, A		    ; 0V -Vref
    
    movlw   10110110B		    ; Right justified output, Fosc/64 clock and
    movwf   ADCON2, A		    ; acquisition times
    
    movlb   0
    
    return


touchscreen_readX:
    bsf	    PORTE, DRIVEA, A	    ; Apply voltage in x-direction
    bcf	    PORTE, DRIVEB, A
    
    movlw   00011101B		    ; Select AN7 for measurement, turn on ADC
    movwf   ADCON0, A
    
    bsf	    GO			    ; Start conversion by setting GO bit

touchscreen_readX_loop:
    btfsc   GO			    ; Check to see if finished
    bra	    touchscreen_readX_loop
    
    return


touchscreen_readY:
    bcf	    PORTE, DRIVEA, A	    ; Apply voltage in y-direction
    bsf	    PORTE, DRIVEB, A
    
    movlw   00101001B		    ; Select AN10 for measurement, turn on ADC
    movwf   ADCON0, A
    
    bsf	    GO			    ; Start conversion by setting GO bit

touchscreen_readY_loop:
    btfsc   GO			    ; Check to see if finished
    bra	    touchscreen_readY_loop
    
    return


touchscreen_read:
    call    touchscreen_readX	    ; take x-reading
    movff   ADRESH, readXH
    movff   ADRESL, readXL
    
    call    touchscreen_readY	    ; take y-reading
    movff   ADRESH, readYH
    movff   ADRESL, readYL
    
    return


touchscreen_detect:
    call    touchscreen_read
    movlw   0x00
    
detect_XH:
    CPFSGT  readXH, A
    bra	    detect_XL
    bra	    test_label

detect_XL:
    CPFSGT  readXL, A
    bra	    touchscreen_read
    bra	    test_label
 
    ;CPFSGT  readYH, A
    ;bra	    touchscreen_detect
    
    ;CPFSGT  readYL, A
    ;bra	    touchscreen_detect

test_label:
    movlw   0xFF
    movwf   PORTH, A
    
    movff    readYH, PORTJ, A
    
    ; PORTJ LEDs shows XH bit 
    return


end