#include <xc.inc>
    
extrn	    Touch_Read
global	    Random_Number

psect	udata_acs

Random:	    ds	1
Random2:    ds	1

psect	randomizer_code, class=CODE

Random_Number: 
	; Generates random number between 7 - 10 using ADC noise
	call    Touch_Read		; Read touchscreen
	movlw   00000001B		; Mask for lowest bit
	andwf   ADRESL, W, A
	movwf   Random, A
	
	call    Touch_Read		; Read touchscreen more times to give
	call    Touch_Read		; random result on next read
	call    Touch_Read
	
	call    Touch_Read		; Read touchscreen
	movlw   00000001B		; Mask for lowest bit
	andwf   ADRESL, W, A
	movwf   Random2, A
	rlncf   Random2, W, A		; Rotate bit into next mos significant position
	
	addwf   Random, W, A		; Combine two generated bits to give
	addlw   7			; random number in [0, 3], then add 7
	
	return