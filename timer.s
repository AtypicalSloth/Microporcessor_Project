#include <xc.inc>

extrn	GLCD_Setup, Clear_Screen, Display_Digit7, Display_Digit8, Display_Digit9, Display_Digit10, Display_DigitQ
global	Timer_Setup, Timer_On, Timer_Int_Hi, Timer_Counter, Delay_ms


psect	udata_acs

Timer_Counter:    ds	1
Stat:	    ds	1

cnt_ms:	    ds	1
cnt_l:	    ds	1
cnt_h:	    ds	1


psect	timer_code, class=CODE

Timer_Setup:
	bsf	    TMR0IE		; Interrupts to be triggered by timer 0
	bsf	    GIE			; Enable all interrupts
	
	movlw	    00000111B		; Set timer 0 to 16-bit, Fosc/4/256
	movwf	    T0CON, A		; = 62.5 kHz clock rate, ~ 1 s rollover
	
	return


Timer_On:
;	movlw	    0x0A		; Set counter to 10
;	movwf	    Timer_Counter, A
;	call	    Display_Digit10

start_at_10:
	movlw	    0x0A		; Compare counter to 9
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 9
	bra	    start_at_9		; Go to test if counter is 8
	call	    Display_Digit10	; Show 9 on display
	goto	    timer_on_end	; Go to function return

start_at_9:
	movlw	    0x09		; Compare counter to 9
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 9
	bra	    start_at_8		; Go to test if counter is 8
	call	    Display_Digit9	; Show 9 on display
	goto	    timer_on_end	; Go to function return
	
start_at_8:
	movlw	    0x08		; Compare counter to 8
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 8
	bra	    start_at_7		; Go to test if counter is 7
	call	    Display_Digit8	; Show 8 on display
	goto	    timer_on_end	; Go to function return
	
start_at_7:
	call	    Display_Digit7	; Show 7 on display	

timer_on_end:
	bsf	    TMR0ON		; Turn on timer 0
	return



Timer_Int_Hi:
    ; NEED TO KEEP RECORD OF OLD STATUS REGISTER!!!!!   - STATUS
	
	movff	    STATUS, Stat, A
	
	btfss	    TMR0IF		; Check this is timer 0 interrupt
	retfie	    f			; Return if not
	
	decf	    Timer_Counter, A	; decrement counter

test_for_9:
	movlw	    0x09		; Compare counter to 9
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 9
	bra	    test_for_8		; Go to test if counter is 8
	call	    Display_Digit9	; Show 9 on display
	goto	    timer_int_hi_end	; Go to function return
	
test_for_8:
	movlw	    0x08		; Compare counter to 8
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 8
	bra	    test_for_7		; Go to test if counter is 7
	call	    Display_Digit8	; Show 8 on display
	goto	    timer_int_hi_end	; Go to function return
	
test_for_7:
	movlw	    0x07		; Compare counter to 7
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 7
	bra	    test_for_6		; Go to test if counter is 0
	call	    Display_Digit7	; Show 7 on display
	goto	    timer_int_hi_end	; Go to function return

test_for_6:
	movlw	    0x06		; Compare counter to 7
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 7
	bra	    test_for_5		; Go to test if counter is 0
	call	    Display_DigitQ	; Show 7 on display
	goto	    timer_int_hi_end	; Go to function return

test_for_5:
	movlw	    0x05		; Compare counter to 7
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 7
	bra	    test_for_4		; Go to test if counter is 0
	call	    Display_DigitQ	; Show 7 on display
	goto	    timer_int_hi_end	; Go to function return

test_for_4:
	movlw	    0x04		; Compare counter to 7
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 7
	bra	    test_for_3		; Go to test if counter is 0
	call	    Display_DigitQ	; Show 7 on display
	goto	    timer_int_hi_end	; Go to function return

test_for_3:
	movlw	    0x03		; Compare counter to 7
	CPFSEQ	    Timer_Counter, A	; Skip if equal to 7
	bra	    test_for_0		; Go to test if counter is 0
	call	    Display_DigitQ	; Show 7 on display
	goto	    timer_int_hi_end	; Go to function return


	
test_for_0:
	movlw	    0x00		; Compare counter to 0
	CPFSEQ	    Timer_Counter, A		; Skip if equal to 0
	bra	    question_mark	; Go to show ? if counter is 6-1
	call	    Display_DigitQ	; Show ? on display
	bcf	    TMR0ON		; Turn off timer 0
	goto	    timer_int_hi_end	; Go to function return
	
question_mark:
	call	    Display_DigitQ	; Show ? on display
	goto	    timer_int_hi_end	; Go to function return
	
timer_int_hi_end:
	bcf	    TMR0IF		; Clear interrupt flag
	movff	    Stat, STATUS, A
	retfie	    f





; * a few delay routines below here as LCD timing can be quite critical *
Delay_ms:		    ; delay given in ms in W
	movwf	cnt_ms, A
lp2:	movlw	250	    ; 1 ms delay
	call	delay_x4us	
	decfsz	cnt_ms, A
	bra	lp2
	return
    
delay_x4us:			; delay given in chunks of 4 microsecond in W
	movwf	cnt_l, A	; now need to multiply by 16
	swapf   cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	cnt_l, W, A	; move low nibble to W
	movwf	cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	cnt_l, F, A	; keep high nibble in LCD_cnt_l
	call	delay
	return

delay:				; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1:	decf 	cnt_l, F, A	; no carry when 0x00 -> 0xff	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return			; carry reset so return