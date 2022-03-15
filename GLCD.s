#include <xc.inc>


psect	udata_acs		    ; named variables in access ram

LCD_Counter:	ds 1 
LCD_XY_Counter:	ds 1
	
LCD_pins:
	LCD_E	EQU 4		    ; LCD enable bit
    	LCD_RS	EQU 2		    ; LCD register select bit
	LCD_RW	EQU 3 
	LCD_CS1	EQU 0
	LCD_CS2 EQU 1
	LCD_RST	EQU 5


psect	udata_bank4

myArrayxy:	ds  64		    ; reserve 64 bytes for data
myArraybytes:   ds  64		    ; reserve 64 bytes for data


psect	data 

table_xy:			    ; x page between [1, 8], y address between [0, 63] alternating 
    db	3, 0, 4, 0, 5, 0, 6, 0 
    table_xy_l	EQU 8
	
table_bytes:			    ; 64 entries
    db	0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
    db	0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
    db	0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
    db	0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
    
    table_bytes_l   EQU 64


psect	lcd_code,class=CODE
    
load_table_xy: 
    ; * Main programme **
 	lfsr	1, myArrayxy		; Load FSR0 with address in RAM	
	movlw	low highword(table_xy)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(table_xy)		; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(table_xy)		; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	table_xy_l		; bytes to read
	movwf 	counter, A		; our counter register
loop:
	tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop			; keep going until finished
	
	return


load_table_bytes: 
    ; * Main programme **
 	lfsr	2, myArraybytes		; Load FSR0 with address in RAM	
	movlw	low highword(table_bytes)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(table_bytes)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(table_bytes)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	table_bytes_l		; bytes to read
	movwf 	counter, A		; our counter register
loop:
	tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop			; keep going until finished

	return


LCD_Write_message:
	movlw   8			; 8 y addresses across
	movwf   LCD_counter, A
LCD_Loop_message:			;send bytes data, message stored in FSR2, length stored in W
	movf    POSTINC2, W, A
	call    LCD_Send_Byte_D
	decfsz  LCD_counter, A
	bra	LCD_Loop_message
	
	return


display_digit: 
    
	; select screen 1
	bcf	LATB, LCD_CS1, A 
	bsf	LATB, LCD_CS2, A
    
	; load table xy into FSR1
	call    load_table_xy
	; read table xy 
	movlw   table_xy_l 
	movwf   LCD_XY_Counter, A 
	; return?
	
set_address:
	; set x page 
	movf    POSTINC1, W, A
	addwf   183 
	call    LCD_Send_Byte_I 
	decf    LCD_XY_Counter, 1, A
	; set y address 
	movf    POSTINC1, W, A
	addwf   01000000B 
	call    LCD_Send_Byte_I 
	decf    LCD_XY_Counter, 1, A
    
	;send in data from table
	call    LCD_Write_Message
    
	;check for end of xy table
	tstfsz  LCD_XY_Counter, A
	bra	    set_address

	return
    
    
    ; select screen 2 
    bsf	LATB, LCD_CS1, A 
    bcf	LATB, LCD_CS2, A 
   
    return