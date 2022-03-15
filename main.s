#include <xc.inc>

extrn	touchscreen_setup, touchscreen_detect

psect	code, abs

org	    100h

setup:
    call    touchscreen_setup
    clrf    PORTH, A
    clrf    TRISH, A
    clrf    PORTJ, A 
    clrf    TRISJ, A
    
    movlw   0x00


main:
    call    touchscreen_detect
    bra	    main

    end