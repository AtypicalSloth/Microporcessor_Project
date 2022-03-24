#include <xc.inc>
    
extrn	    Touch_Read
global	    Random_Number

psect	udata_acs

Random:	    ds	1
Random2:    ds	1

psect	randomizer_code, class=CODE

Random_Number: 
	; Generates random number between 7 - 10 using ADC noise
	call    Touch_Read
	movlw   00000001B
	andwf   ADRESL, W, A
	movwf   Random, A
	
	call    Touch_Read
	call    Touch_Read
	call    Touch_Read
	
	call    Touch_Read
	movlw   00000001B
	andwf   ADRESL, W, A
	movwf   Random2, A
	rlncf   Random2, W, A
	
	addwf   Random, W, A
	addlw   7
	
	return