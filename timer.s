#include <xc.inc>

global	timer_setup, timer_on, timer_int_hi, counter


psect	udata_acs

counter:    ds	1


psect	timercode
org	    900h

timer_setup:
    bsf		TMR0IE			; Interrupts to be triggered by timer 0
    bsf		GIE			; Enable all interrupts
    
    movlw	00000111B		; Set timer 0 to 16-bit, Fosc/4/256
    movwf	T0CON, A		; = 62.5 kHz clock rate, ~ 1 s rollover
    
    return


timer_on:
    movlw	0x0A			; Set counter to 10
    movwf	counter, A
    
    ;call	show 10 on counter
    movlw	0x0A
    movwf	PORTD, A
    
    bsf		TMR0ON		; Turn on timer 0
    
    return


timer_int_hi:
    btfss	TMR0IF			; Check this is timer 0 interrupt
    retfie	f			; Return if not
    
    decf	counter, A		; decrement counter
    
test_for_9:
    movlw	0x09			; Compare counter to 9
    CPFSEQ	counter, A		; Skip if equal to 9
    bra		test_for_8		; Go to test if counter is 8
    ;call	show 9 on display	; Show 9 on display
    movlw	0x09
    movwf	PORTD, A
    goto	timer_int_hi_end	; Go to function return
    
test_for_8:
    movlw	0x08			; Compare counter to 8
    CPFSEQ	counter, A		; Skip if equal to 8
    bra		test_for_7		; Go to test if counter is 7
    ;call	show 8 on display	; Show 8 on display
    movlw	0x08
    movwf	PORTD, A
    goto	timer_int_hi_end	; Go to function return

test_for_7:
    movlw	0x07			; Compare counter to 7
    CPFSEQ	counter, A		; Skip if equal to 7
    bra		test_for_0		; Go to test if counter is 0
    ;call	show 7 on display	; Show 7 on display
    movlw	0x07
    movwf	PORTD, A
    goto	timer_int_hi_end			; Go to function return

test_for_0:
    movlw	0x00			; Compare counter to 0
    CPFSEQ	counter, A		; Skip if equal to 0
    bra		question_mark		; Go to show ? if counter is 6-1
    ;call	show ? on display	; Show ? on display
    movlw	0x00
    movwf	PORTD, A
    bcf		TMR0ON			; Turn off timer 0
    goto	timer_int_hi_end	; Go to function return

question_mark:
    ;call	show ? on display	; Show ? on display
    movlw	0xFF
    movwf	PORTD, A
    goto	timer_int_hi_end	; Go to function return

timer_int_hi_end:
    bcf		TMR0IF			; Clear interrupt flag
    retfie	f

end