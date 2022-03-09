	#include <xc.inc>

global	GLCD_setup, GLCD_enable, GLCD_on, GLCD_off

psect	udata_acs	

PORTB_pins:
    GLCD_CS1	EQU 0
    GLCD_CS2	EQU 1
    GLCD_RS	EQU 2
    GLCD_RW	EQU 3
    GLCD_E	EQU 4
    GLCD_RST	EQU 5


psect	code, class=CODE

org	0x500

GLCD_setup:
    clrf	LATB, A
    clrf	LATD, A
    clrf	TRISB, A
    clrf	TRISD, A
    return


GLCD_enable:
    NOP					; Wait 500 ns
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    bsf		LATB, GLCD_E, A	; Pull E high
    NOP					; Wait 500 ns
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    bcf		LATB, GLCD_E, A	; Pull E low
    NOP					; Wait 62.5 ns
    return


GLCD_on:
    bcf		LATB, GLCD_RS, A	; Set port B pins
    bcf		LATB, GLCD_RW, A
    
    movlw	00111111B		; Set port D pins
    movwf	LATD, A
    
    call	GLCD_enable		; Pulse enable pin
    return


GLCD_off:
    bcf		LATB, GLCD_RS, A	; Set port B pins
    bcf		LATB, GLCD_RW, A
    
    movlw	00111110B		; Set port D pins
    movwf	LATD, A
    
    call	GLCD_enable		; Pulse enable pin
    return

end