#include <xc.inc>

; Subroutines from touchscreen file
extrn	touchscreen_setup, touchscreen_detect, touchscreen_detect2
    
; Subroutines from timer/interrupt file
extrn	timer_setup, timer_on, timer_int_hi, counter

; Subroutines from GLCD file
extrn	GLCD_Setup, Clear_Screen, Display_Digit7, Display_Digit8, Display_Digit9, Display_Digit10, Display_DigitQ

; Make file register for recording status regiuster a global register
global	stat


psect	udata_acs
stat:	ds  1


; ######################### TOUCHSCREEN TEST CODE ##############################
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


; ######################### TIMER TEST CODE ####################################
;psect	code, abs
;
;rst:
;    org	    0x0000
;    goto    counter_setup
;
;interrupt:
;    org	    0x0008
;    call    timer_int_hi
;
;setup:
;    movlw   0x0A
;    CPFSEQ  counter, A
;    goto    loop
;    call    GLCD_Setup
;    call    Clear_Screen
;    ;clrf    TRISD, A
;    ;clrf    LATD, A
;    
;    call    timer_setup
;    call    timer_on
;
;loop:
;    goto    $
;
;counter_setup:
;    movlw   0x0A
;    movwf   counter, A
;    goto    setup
;
;    end	    rst


; ######################### GLCD TEST CODE #####################################
;psect	code, abs
;	
;main:
;	org	0x0
;	goto	start
;	
;start:
;	call	GLCD_Setup
;	call	Clear_Screen
;
;maincode: 
;	
;	call	Display_Digit7
;	call	Display_Digit8
;	call	Display_Digit9
;	call	Display_Digit10
;	call	Display_DigitQ
;	goto	$
;
;	end	main


; ######################### MAIN CODE ##########################################
;psect	code, abs
;
;main:
;	org	0x0000
;	goto    counter_setup
;
;interrupt:
;	org	0x0008
;	call    timer_int_hi
;
;setup:
;	movlw   0x0A
;	CPFSEQ  counter, A		; Check if counter is less than 10
;	goto    loop			; Move to loop if so
;	
;	call    GLCD_Setup		; Setup GLCD
;	call    Clear_Screen		; Clear GLCD screen
;	
;	call    timer_setup		; Setup timer
;	call	timer_on
;
;
;loop:
;	goto    $
;
;counter_setup:
;	movlw   0x0A
;	movwf   counter, A
;	goto    setup
;
;	end	main



psect	code, abs

setup:
    org	    0x0000
    call    touchscreen_setup
    clrf    PORTH, A
    clrf    TRISH, A
    clrf    PORTJ, A 
    clrf    TRISJ, A


main:
    call    touchscreen_detect
    
    end	    setup
