#include <xc.inc>

extrn	touchscreen_setup, touchscreen_detect

psect	code, abs

org	    100h

setup:
    call    touchscreen_setup
    clrf    PORTC, A
    clrf    TRISC, A
    movlw   0x00


main:
    call    touchscreen_detect

    end