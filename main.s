#include <xc.inc>

extrn	touchscreen_setup, touchscreen_detect
extrn	timer_setup, timer_on, timer_int_hi, counter
extrn	GLCD_setup, screen_setup, screen_write
global	stat

psect	udata_acs
stat:	ds  1

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



psect	code, abs

rst:
    org	    0x0000
    goto    counter_setup

interrupt:
    org	    0x0008
    call    timer_int_hi

setup:
    movlw   0x0A
    CPFSEQ  counter, A
    goto    loop
    clrf    TRISD, A
    clrf    LATD, A
    
    call    timer_setup
    call    timer_on

loop:
    goto    $

counter_setup:
    movlw   0x0A
    movwf   counter, A
    goto    setup

    end	    rst