#include <xc.inc>

extrn	Touch_Setup, Touch_Read, Touch_Detect, Touch_Status
extrn	Timer_Setup, Timer_On, Timer_Int_Hi, Timer_Counter
extrn	GLCD_Setup, Clear_Screen, Delay_ms, LCD_delay_x4us, LCD_delay
extrn	ADC_Setup2, ADC_Read2


; ######################### TOUCHSCREEN TEST CODE ##############################
;psect	code, abs
;
;setup:
;    org	    0x0000
;    clrf    TRISH, A
;    clrf    TRISJ, A
;    clrf    PORTH, A
;    clrf    PORTJ, A
;    
;    call    touchscreen_setup
;
;main:
;    call    touchscreen_read
;    movff   ADRESH, PORTH, A
;    movff   ADRESL, PORTJ, A
;    movlw   1		    ; delay 250ms
;    call    LCD_delay_ms
;    bra	    main
;    
;    end	    setup


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


    
; ################# ADC TEST CODE ##############################################
;psect	code, abs
;
;setup:
;    org	    0x0000
;    clrf    TRISH, A
;    clrf    TRISJ, A
;    clrf    PORTH, A
;    clrf    PORTJ, A
;    
;    call    ADC_Setup2
;
;main:
;    call    ADC_Read2
;    movff   ADRESH, PORTH, A
;    movff   ADRESL, PORTJ, A
;    bra	    main
;    
;    end	    setup

    
;######################## touchscreen test code ################################
;psect	code, abs
;
;setup:
;    org	    0x0000
;    clrf    TRISH, A
;    clrf    TRISJ, A
;    clrf    PORTH, A
;    clrf    PORTJ, A
;    
;    call    Touch_Setup
;
;main:
;    call    Touch_Read
;    movff   ADRESH, PORTH, A
;    movff   ADRESL, PORTJ, A
;    movlw   1		    ; delay 250ms
;    call    LCD_Delay_ms
;    bra	    main
;    
;    end	    setup


;######################## touchscreen detect code ##############################
;psect	code, abs
;
;setup:
;    org	    0x0000
;    clrf    TRISH, A
;    clrf    TRISJ, A
;    clrf    PORTH, A
;    clrf    PORTJ, A
;    
;    call    Touch_Setup
;
;main:
;    call    Touch_Read
;    call    Touch_Detect
;    movff   ADRESH, PORTH, A
;    movff   Touch_Status, PORTJ, A
;    ;movlw   1		    ; delay 250ms
;    ;call    LCD_Delay_ms
;    bra	    main
;    
;    end	    setup

    
    
    
    
    
    
    
    

;psect	code, abs
;
;rst:
;    org	    0x0000
;    goto    counter_setup
;
;interrupt:
;    org	    0x0008
;    goto    Timer_Int_Hi
;    
;setup:
;;    movlw   0x0A
;;    CPFSEQ  Timer_Counter, A
;;    goto    loop
;    call    GLCD_Setup
;    call    Clear_Screen
;    clrf    TRISH, A
;    clrf    PORTH, A
;    
;    call    Timer_Setup
;    call    Timer_On
;    
;    call    Touch_Setup
;
;loop:
;    movff   Timer_Counter, PORTH
;    movlw   250
;    call    Delay_ms
;    
;    ;call    Touch_Read
;    bra	    loop
;
;counter_setup:
;    movlw   0x0A
;    movwf   Timer_Counter, A
;    goto    setup
;    
;
;    end	    rst