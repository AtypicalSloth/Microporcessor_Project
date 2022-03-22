#include <xc.inc>

global  GLCD_Setup, Clear_Screen, Display_Digit7, Display_Digit8, Display_Digit9, Display_Digit10, Display_DigitQ, LCD_delay_x4us, LCD_Delay_ms



psect	udata_acs			; named variables in access ram
	
LCD_cnt_l:	ds 1			; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1			; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1			; reserve 1 byte for ms counter
LCD_tmp:	ds 1			; reserve 1 byte for temporary use
    
LCD_counter:	ds 1			; reserve 1 byte for counting through nessage
counter:	ds 1

table_7:	ds 3
table_8:	ds 3
table_9:	ds 3
table_10:	ds 3
table_Q:	ds 3
    
LCD_x_address:	ds 1			; reserve 1 byte for iterating through x page [0, 63]
LCD_y_address:	ds 1			; reserve 1 byte for iterating through y [1,8]

	
	; LCD control bits
	LCD_E	EQU 4			; LCD enable bit
    	LCD_RS	EQU 2			; LCD register select bit
	LCD_RW	EQU 3 
	LCD_CS1	EQU 0
	LCD_CS2 EQU 1
	LCD_RST	EQU 5
	
	; Display address positions
	TX	EQU 3
	BX	EQU 4 
	LY	EQU 56
	RY	EQU 0
	table_l EQU 8
	
psect udata_bank4			; reserve data anywhere in RAM (here at 0x400)
myArray: ds 64				; reserve 128 bytes for message data
	
psect data

table_7TL:
    db 00000000B, 00000000B, 00000000B, 00000011B, 00000011B, 00000011B, 00000011B, 00000011B
    db 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 11000000B, 11110000B, 00111100B
    db 00000011B, 11000011B, 11110011B, 00111111B, 00001111B, 00000000B, 00000000B, 00000000B
    db 00001111B, 00000011B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B
    
table_8TL:
    db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 01111110B, 11000111B, 10000011B
    db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 01111110B, 11100011B, 11000001B
    db 10000011B, 11000111B, 01111110B, 00111100B, 00000000B, 00000000B, 00000000B, 00000000B
    db 11000001B, 11100011B, 01111110B, 00111100B, 00000000B, 00000000B, 00000000B, 00000000B
    
table_9TL:
    db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 01111110B, 11100111B, 11000011B   
    db 00000000B, 00000000B, 00000000B, 00000000B, 00110000B, 01110000B, 11100000B, 11000000B
    db 11000011B, 11100111B, 11111110B, 11111100B, 00000000B, 00000000B, 00000000B, 00000000B
    db 11000000B, 11100000B, 01111111B, 00111111B, 00000000B, 00000000B, 00000000B, 00000000B

table_10TL:
    db 00000100B, 00000110B, 00000111B, 11111111B, 11111111B, 00000000B, 00000000B, 00000000B
    db 00000000B, 10000000B, 11000000B, 11111111B, 11111111B, 11000000B, 10000000B, 00000000B
    db 11111100B, 11111110B, 00000111B, 00000011B, 00000011B, 00000111B, 11111110B, 11111100B
    db 00111111B, 01111111B, 11100000B, 11000000B, 11000000B, 11100000B, 01111111B, 00111111B

table_QTL:
    db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 00111110B, 00000111B, 10000011B
    db 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 11000111B
    db 11000011B, 11100111B, 01111110B, 00111100B, 00000000B, 00000000B, 00000000B, 00000000B
    db 11000111B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B
    
psect	    glcd_code, class=CODE

GLCD_Setup: 

	movlw   0x00
	movwf   TRISB, A		; Set port B to output
	movwf   TRISD, A		; Set port D to output
	
	; every command we send from now on requires a delay of 500ns
	
	clrf    LATB, A			; clear latches
	clrf    LATD, A

	bcf	LATB, LCD_CS1, A	; select screen 1
	bcf	LATB, LCD_CS2, A	; select screen 2
	bcf	LATB, LCD_RS, A	
	bcf	LATB, LCD_RW, A 
	bcf	LATB, LCD_E, A  
	bsf	LATB, LCD_RST, A

	movlw   40
	call    LCD_Delay_ms		; wait 40ms for LCD to start up properly
	movlw   00111110B		; display off
	call    LCD_Send_Byte_I
	movlw   10111001B		; set x address to 1
	call    LCD_Send_Byte_I
	movlw   01000000B		; Set Y-address to 0
	call    LCD_Send_Byte_I
	movlw   00111111B		; display on
	call    LCD_Send_Byte_I
	
	; load table 7 address
	movlw	low highword(table_7TL)	; address of data in PM
	movwf	table_7, A		; load upper bits to TBLPTRU
	movlw	high(table_7TL)		; address of data in PM
	movwf	table_7+1, A		; load high byte to TBLPTRH
	movlw	low(table_7TL)		; address of data in PM
	movwf	table_7+2, A		; load low byte to TBLPTRL
	
	; load table 8 address
	movlw	low highword(table_8TL)	; address of data in PM
	movwf	table_8, A		; load upper bits to TBLPTRU
	movlw	high(table_8TL)		; address of data in PM
	movwf	table_8+1, A		; load high byte to TBLPTRH
	movlw	low(table_8TL)		; address of data in PM
	movwf	table_8+2, A		; load low byte to TBLPTRL
	
	; load table 9 address
	movlw	low highword(table_9TL)	; address of data in PM
	movwf	table_9, A		; load upper bits to TBLPTRU
	movlw	high(table_9TL)		; address of data in PM
	movwf	table_9+1, A		; load high byte to TBLPTRH
	movlw	low(table_9TL)		; address of data in PM
	movwf	table_9+2, A		; load low byte to TBLPTRL
	
	; load table 10 address
	movlw	low highword(table_10TL)	; address of data in PM
	movwf	table_10, A		; load upper bits to TBLPTRU
	movlw	high(table_10TL)		; address of data in PM
	movwf	table_10+1, A		; load high byte to TBLPTRH
	movlw	low(table_10TL)		; address of data in PM
	movwf	table_10+2, A		; load low byte to TBLPTRL
	
	; load table Q address
	movlw	low highword(table_QTL)	; address of data in PM
	movwf	table_Q, A		; load upper bits to TBLPTRU
	movlw	high(table_QTL)		; address of data in PM
	movwf	table_Q+1, A		; load high byte to TBLPTRH
	movlw	low(table_QTL)		; address of data in PM
	movwf	table_Q+2, A		; load low byte to TBLPTRL
	
	return 

Display_Digit7: 
	lfsr	0, table_7
	call	Display_char
	return
    
Display_Digit8: 
	lfsr	0, table_8
	call	Display_char
	return
	
Display_Digit9: 
	lfsr	0, table_9
	call	Display_char
	return
    
Display_Digit10: 
	lfsr	0, table_10
	call	Display_char
	return
	
Display_DigitQ: 
	lfsr	0, table_Q
	call	Display_char
	return
    
Display_char:
	; left half of the screen
	bcf	LATB, LCD_CS1, A	; select screen 1
	bsf	LATB, LCD_CS2, A	; deselect screen 2
	
	call	load_table    
	
	; send table to top left screen 
	movlw	TX	
	movwf	LCD_x_address, A 
	movlw	LY
	movwf	LCD_y_address, A
	call	table_to_GLCD

	; send table to bottom left screen
	movlw	BX
	movwf	LCD_x_address, A 
	movlw	LY
	movwf	LCD_y_address, A
	call	table_to_GLCD
	
	; right half of the screen
	bsf	LATB, LCD_CS1, A	; deselect screen 1
	bcf	LATB, LCD_CS2, A	; select screen 2
;	
	; send table to top right screen 
	movlw	TX
	movwf	LCD_x_address, A 
	movlw	RY
	movwf	LCD_y_address, A
	call	table_to_GLCD
	
	; send table to top right screen 
	movlw	BX
	movwf	LCD_x_address, A 
	movlw	RY
	movwf	LCD_y_address, A
	call	table_to_GLCD
	
	; default back to having both screen selected
	bcf	LATB, LCD_CS1, A	; select screen 1
	bcf	LATB, LCD_CS2, A	; select screen 2

	return

load_table: 
    ; load table to TABLAT
	movf	POSTINC0, W, A	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movf	POSTINC0, W, A	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movf	POSTINC0, W, A	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	return
	
	
table_to_GLCD: 	
	; sets x and y address to LCD_x_address and LCD_y_address respectively
	
	movlw   183			; set x address to LCD_x_address value [1, 8], 183 instruction
	addwf   LCD_x_address, W, A 
	call    LCD_Send_Byte_I
	movlw	64			; set y address to LCD_y_address value [0, 63]. 64 instruction
	addwf   LCD_y_address, W, A 
	call    LCD_Send_Byte_I
	
	movlw	table_l			; 8 bytes to read per table
	movwf 	counter, A		; our counter register
table_loop:
	tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
	movf	TABLAT, W, A		; move data from TABLAT to W
	call	LCD_Send_Byte_D		; send data off from W to GLCD
	decfsz	counter, A		; count down to zero
	bra	table_loop		; keep going until finished
	return
	
LCD_Write_message:
    ;send bytes data, message stored in FSR2, length stored in W
	movwf   LCD_counter, A
LCD_Loop_message: 
	movf    POSTINC2, W, A
	call    LCD_Send_Byte_D
	decfsz  LCD_counter, A
	bra	LCD_Loop_message
	return
	
Clear_Screen:
	; clears entire screen 
	bcf	LATB, LCD_CS1, A     ; select screen 1
	bcf	LATB, LCD_CS2, A     ; select screen 2
	movlw   8
	movwf   LCD_x_address, A

address_to_clear:
	movlw   183		     ; set x address to LCD_x_address value [1, 8]
	addwf   LCD_x_address, W, A 
	call    LCD_Send_Byte_I
        movlw   01000000B	     ; set y address to 0 
	call    LCD_Send_Byte_I
        movlw   64	             ; loop 64 times 
	movwf   LCD_y_address, A
	call    clear_byte
	decfsz  LCD_x_address, A     ; loops through x addresses
	bra	address_to_clear
	return 
   
clear_byte: ; sends 0x00 byte to data ram
	movlw   0x00 
	call    LCD_Send_Byte_D
	decfsz  LCD_y_address, A 
	bra	clear_byte
	return	
	
LCD_Send_Byte_I:	    
    ; Transmits INSTRUCTION byte stored in W and delays by 40us
	movwf   LATD, A		    
	bcf	LATB, LCD_RS, A	    
	call	LCD_Enable	    ; pulse the enable bit according to 'write' timing
	movlw	10		    ; delay 40us
	call    LCD_delay_x4us
	return

LCD_Send_Byte_D:	    
    ; write DATA to GLCD data ram
	movwf	LATD, A		    ; load databus on LATD
	bsf	LATB, LCD_RS, A	    ; set to write data mode
	call	LCD_Enable     	    ; pulse the enable bit according to 'write' timing
	movlw	10	            ; stop 40us
	call	LCD_delay_x4us
	return

LCD_Enable:	    ; pulse enable bit LCD_E for 500ns, each nop = 62.5ns
	;default E bit low 
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATB, LCD_E, A	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATB, LCD_E, A	    ; Writes data to LCD
	return
    
; * a few delay routines below here as LCD timing can be quite critical *
LCD_Delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return