#include <xc.inc>

extrn	GLCD_Setup, Clear_Screen, Display_Digit7, Display_Digit8, Display_Digit9, Display_Digit10, Display_DigitQ
global	Timer_Setup, Timer_On, Timer_Int_Hi, Counter


psect	udata_acs

Counter:    ds	1
Stat:	    ds	1


psect	timer_code, class=CODE

Timer_Setup:
	bsf	    TMR0IE		; Interrupts to be triggered by timer 0
	bsf	    GIE			; Enable all interrupts
	
	movlw	    00000111B		; Set timer 0 to 16-bit, Fosc/4/256
	movwf	    T0CON, A		; = 62.5 kHz clock rate, ~ 1 s rollover
	
	return


Timer_On:
	movlw	    0x0A		; Set counter to 10
	movwf	    Counter, A
	call	    Display_Digit10
	
	bsf	    TMR0ON		; Turn on timer 0
	
	return


Timer_Int_Hi:
    ; NEED TO KEEP RECORD OF OLD STATUS REGISTER!!!!!   - STATUS
	
	movff	    STATUS, Stat, A
	
	btfss	    TMR0IF		; Check this is timer 0 interrupt
	retfie	    f			; Return if not
	
	decf	    Counter, A		; decrement counter
    
test_for_9:
	movlw	    0x09		; Compare counter to 9
	CPFSEQ	    Counter, A		; Skip if equal to 9
	bra	    test_for_8		; Go to test if counter is 8
	call	    Display_Digit9	; Show 9 on display
	;movlw	    0x09
	;movwf	    PORTD, A
	goto	    timer_int_hi_end	; Go to function return
    
test_for_8:
	movlw	    0x08		; Compare counter to 8
	CPFSEQ	    Counter, A		; Skip if equal to 8
	bra	    test_for_7		; Go to test if counter is 7
	call	    Display_Digit8	; Show 8 on display
	;movlw	    0x08
	;movwf	    PORTD, A
	goto	    timer_int_hi_end	; Go to function return

test_for_7:
    movlw	0x07			; Compare counter to 7
    CPFSEQ	Counter, A		; Skip if equal to 7
    bra		test_for_0		; Go to test if counter is 0
    call	Display_Digit7		; Show 7 on display
    ;movlw	0x07
    ;movwf	PORTD, A
    goto	timer_int_hi_end			; Go to function return

test_for_0:
    movlw	0x00			; Compare counter to 0
    CPFSEQ	Counter, A		; Skip if equal to 0
    bra		question_mark		; Go to show ? if counter is 6-1
    call	Display_Digit10		; Show ? on display
    ;movlw	0x00
    ;movwf	PORTD, A
    bcf		TMR0ON			; Turn off timer 0
    goto	timer_int_hi_end	; Go to function return

question_mark:
    call	Display_DigitQ		; Show ? on display
    ;movlw	0xFF
    ;movwf	PORTD, A
    goto	timer_int_hi_end	; Go to function return

timer_int_hi_end:
    bcf		TMR0IF			; Clear interrupt flag
    movff	Stat, STATUS, A
    retfie	f