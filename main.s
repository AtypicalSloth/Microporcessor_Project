#include <xc.inc>

extrn	Touch_Setup, Touch_Read, Touch_Detect, Touch_Status
extrn	Timer_Setup, Timer_On, Timer_Int_Hi, Timer_Counter, LCD_Delay_ms, Delay_ms, LCD_delay_025s, Timer_Speed
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
	call	    Display_Border	; Display game border
	call	    Display_TAPTOSTART	; Display "tap to start" message
	clrf	    PORTH, A
	clrf	    TRISH, A


game_start:
	call	    Touch_Read		; Read touch position on screen
	call	    Touch_Detect	; Find touch position
	
	movlw	    0x00		; Check if touch has occured
	CPFSGT	    Touch_Status, A
	bra	    game_start
	bra	    game_run		; Begin game if touched


game_run:
	call	    very_long_delay	; Delay before game begins
	
	call	    Clear_Screen	; Remove "tap to start" message
	call	    Display_Border	; Re-display border
	
	call	    Timer_On		; Begin countdown


game_loop:
	movlw	    20
	call	    LCD_delay_025s
	call	    Touch_Read		; Read touch position on screen
	call	    Touch_Detect	; Find touch position
	
	movlw	    0x00		; If screen not touched, keep looping
	CPFSGT	    Touch_Status, A
	bra	    game_loop
	
	movlw	    0x0F		; If screen is touched, detect side
	CPFSEQ	    Touch_Status, A
	bra	    game_Ltouch
	bra	    game_Rtouch


game_Ltouch:				; Left side pressed
	bcf	    TMR0ON		; Turn off Timer 0
	movlw	    0x00		; Check if countdown has finished
	CPFSEQ	    Timer_Counter, A
	bra	    Rwin		; Right wins if not
	bra	    Lwin		; Left wins if yes


game_Rtouch:				; Right side pressed
	bcf	    TMR0ON		; Turn off Timer 0
	movlw	    0x00		; Check if countdown has finished
	CPFSEQ	    Timer_Counter, A
	bra	    Lwin		; Left wins if not
	bra	    Rwin		; Right wins if yes


Lwin:
	movlw	    0xF0		; Display player 1 victory message
	call	    Display_PLAYER1WINS
	movlw	    250
	call	    very_long_delay	; Delay before reset
	call	    very_long_delay
	goto	    main

Rwin:
	movlw	    0x0F		; Display player 2 victory message
	call	    Display_PLAYER2WINS
	movlw	    250
	call	    very_long_delay	; Delay before reset
	call	    very_long_delay
	goto	    main


counter_setup:
	call	    Touch_Setup		; Setup touchscreen and ADC
	call	    Random_Number	; Generate random number in [7, 10]
	movwf	    Timer_Counter, A	; Start counter at generated value
	call	    Random_Number	; Generate random number in [7, 10]
	movwf	    Timer_Speed, A	; Set timer speed according to number
	goto	    setup


very_long_delay:			; Lond delay to use in game
	movlw	    100 
	call	    LCD_delay_025s
	
	return
	
	end	    main