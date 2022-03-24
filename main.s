#include <xc.inc>

extrn	Touch_Setup, Touch_Read, Touch_Detect, Touch_Status
extrn	Timer_Setup, Timer_On, Timer_Int_Hi, Timer_Counter, LCD_Delay_ms, Delay_ms, LCD_delay_025s
extrn	GLCD_Setup, Clear_Screen, Display_Border, Display_TAPTOSTART, Display_PLAYER1WINS, Display_PLAYER2WINS
extrn	Random_Number



psect	code, abs

main:
	org	    0x0000
	goto	    counter_setup


interrupt:
	org	    0x0008		; Interrupt vector
	goto	    Timer_Int_Hi


setup:
	clrf	    TRISG, A
	
	call	    GLCD_Setup		; Setup GLCD
	call	    Clear_Screen	; Clear screen
	call	    Timer_Setup		; Setup timer
	call	    Display_Border
	call	    Display_TAPTOSTART


game_start:
	call	    Touch_Read		; Read touch position on screen
	call	    Touch_Detect	; Find touch position
	
	movlw	    0x00		; Check if touch has occured
	CPFSGT	    Touch_Status, A
	bra	    game_start
	bra	    game_run		; Begin game if touched


game_run:
	call	    very_long_delay
	
	call	    Clear_Screen
	call	    Display_Border
	
	call	    Timer_On		; Begin countdown
game_loop:
	movlw	    20
	call	    LCD_delay_025s
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
	call	    Display_PLAYER1WINS
	call	    very_long_delay
	call	    very_long_delay
	goto	    main

Rwin:
	movlw	    0x0F
	call	    Display_PLAYER2WINS
	movlw	    250
	call	    very_long_delay
	call	    very_long_delay
	goto	    main


counter_setup:
	call	    Touch_Setup		    ; Setup touchscreen and ADC
	call	    Random_Number
	movwf	    Timer_Counter, A
	goto	    setup


very_long_delay:
	movlw	    100 
	call	    LCD_delay_025s
	
	return
	
	end	    main