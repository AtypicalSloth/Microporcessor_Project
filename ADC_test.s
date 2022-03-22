#include <xc.inc>

global	ADC_Setup2, ADC_Read2

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


psect	ADC_code, class=CODE

; F  :  1  2  3  4  5  6  7
; AN :  6  7  8  9 10 11  5

; Reference voltage: AN3

ADC_Setup2:
    bsf	    TRISF, 1, A
    banksel ANCON0
    bsf	    ANSEL6
    movlw   00011001B
    movwf   ADCON0, A
    movlw   0x03
    movwf   ADCON1, A
    movlw   0xF6
    movwf   ADCON2, A
    movlb   0
    return

ADC_Read2:
    bsf	    GO
adc_loop:
    btfsc   GO
    bra	    adc_loop
    return