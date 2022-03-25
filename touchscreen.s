#include <xc.inc>

global	Touch_Setup, Touch_Read, Touch_Status, Touch_Detect



psect	udata_acs

touch_pins:
	DRIVEA	    EQU 4		; DRIVEA pin is port E4 (measure x)
	DRIVEB	    EQU 5		; DRIVEB pin is port E5 (measure y)

Touch_Status:	    ds  1



psect	touch_code, class=CODE

; F  :  1  2  3  4  5  6  7
; AN :  6  7  8  9 10 11  5

Touch_Setup:
	clrf	    TRISE, A		; Set port E to output
	setf	    TRISF, A		; Set port F to input
	
	banksel	    ANCON1		; ANCON1 is not in access RAM
	bsf	    ANSEL10		; Set x-read pin to analog (RF5)
	
	;banksel ANCON0			; Option to set y-read pin to analog (RF2)
	;bsf	    ANSEL7
	
	movlw	    00101001B		; Select ANSEL10 to read from, turn on ADC
	movwf	    ADCON0, A
	
	;movlw   0x03
	movlw	    00110000B		; Trigger from ECCP2, +Vref 4.096 V,
	movwf	    ADCON1, A		; -Vref 0V
	
	movlw	    0xF6		; Right justified result, 16 TAD aquisition
	movwf	    ADCON2, A		; time, Fosc/64 conversion clock
	
	movlb	    0			; Return to data bank 0
	
	bsf	    PORTE, DRIVEA, A	; Apply voltage in x-direction
	NOP
	bcf	    PORTE, DRIVEB, A
	NOP
	
	return


Touch_Read:
	bsf	    GO			; Start conversion by setting GO bit
	
touch_loop:
	btfsc	    GO			; Check if conversion has finished
	bra	    touch_loop
	
	return


Touch_Detect:
	movlw	    0x00		; Check if screen is touched
	CPFSGT	    ADRESH, A		; Skip if ADRESH > 0
	bra	    touch_0	        ; Detect no touch if = 0
	BTFSS	    ADRESH, 3, A        ; Test if bit 3 of ADRESH is 1
	bra	    touch_L	        ; Detect LHS if = 0
	bra	    touch_R	        ; Detect RHS if = 1

touch_0:
	movwf	    Touch_Status, A     ; Set status to 0x00
	return

touch_R:
	movlw	    0x0F
	movwf	    Touch_Status, A	; Set status to 0x0F
	return

touch_L:
	movlw	    0xF0
	movwf	    Touch_Status, A	; Set status to 0xF0
	return