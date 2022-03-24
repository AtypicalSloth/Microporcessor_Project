#include <xc.inc>

extrn	Touch_Setup, Touch_Read, Touch_Detect, Touch_Status
extrn	Timer_Setup, Timer_On, Timer_Int_Hi, Timer_Counter
extrn	GLCD_Setup, Clear_Screen, Delay_ms, LCD_delay_x4us, LCD_delay
extrn	ADC_Setup2, ADC_Read2

; Make file register for recording status regiuster a global register

psect	code, abs

main:
	org	    0x0000
	goto	    counter_setup


interrupt:
	org	    0x0008		; Interrupt vector
	goto	    Timer_Int_Hi


setup:
	clrf	    TRISG, A
;	movlw	    0x0A
;	CPFSEQ	    Counter, A		; Check if counter is less than 10
;	goto	    game_loop		; Move to main game loop if so
	
	call	    GLCD_Setup		; Setup GLCD
	call	    Clear_Screen	; Clear screen
	call	    Timer_Setup		; Setup timer
	call	    Touch_Setup		; Setup touchscreen and ADC


game_start:
	call	    Touch_Read		; Read touch position on screen
	call	    Touch_Detect	; Find touch position
	
	movlw	    0x00		; Check if touch has occured
	CPFSGT	    Touch_Status, A
	bra	    game_start
	bra	    game_run		; Begin game if touched


game_run:
	movlw	    250
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Timer_On		; Begin countdown
game_loop:
	movlw	    10
	call	    Delay_ms
	call	    Touch_Read		; Read touch position on screen
	call	    Touch_Detect	; Find touch position
	
	movlw	    0x00		; If screen not touched, keep looping
	CPFSGT	    Touch_Status, A
	bra	    game_loop
	
	;movff	    ADRESH, PORTH, A
	;movff	    ADRESL, PORTJ, A
	movlw	    0x0F
	CPFSEQ	    Touch_Status, A
	bra	    game_Ltouch
	bra	    game_Rtouch


game_Ltouch:
	bcf	    TMR0ON
	movlw	    0x00
	CPFSEQ	    Timer_Counter, A
	bra	    Rwin
	bra	    Lwin


game_Rtouch:
	bcf	    TMR0ON
	movlw	    0x00
	CPFSEQ	    Timer_Counter, A
	bra	    Lwin
	bra	    Rwin


Lwin:
	movlw	    0xF0
	movwf	    PORTG, A
	movlw	    250
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	goto	    main

Rwin:
	movlw	    0x0F
	movwf	    PORTG, A
	movlw	    250
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	call	    Delay_ms
	goto	    main


counter_setup:
	movlw	    0x0A
	movwf	    Timer_Counter, A
	goto	    setup
	
	end	    main