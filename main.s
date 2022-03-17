#include <xc.inc>

extrn	touchscreen_setup, touchscreen_detect, timer_setup, timer_on, timer_int_hi

;psect	code, abs

;org	    100h

;setup:
;    call    touchscreen_setup
;    clrf    PORTH, A
;    clrf    TRISH, A
;    clrf    PORTJ, A 
;    clrf    TRISJ, A
    
;    movlw   0x00


;main:
;    call    touchscreen_detect
;    bra	    main

;    end

interrupt:
    org	    0x0008
    call    timer_int_hi

main:
    org	    100h
    clrf    TRISD, A
    clrf    LATD, A
    
    call    timer_setup
    call    timer_on
    
    end