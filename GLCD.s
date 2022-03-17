#include <xc.inc>

global GLCD_setup, screen_setup, screen_write, screen_clear, LCD_Write_Message, display_table, load_table

psect udata_acs ; reserve data space in access ram
counter: ds 1 ; reserve one byte for a counter variable
delay_count:ds 1 ; reserve one byte for counter in the delay routine

psect udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray: ds 64 ; reserve 128 bytes for message data
psect data

myTable: ; 16 entries
db 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
db 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
db 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF
db 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF

myTable_l EQU 64



table_7TL:
db 00000000B, 00000000B, 00000000B, 00000011B, 00000011B, 00000011B, 00000011B, 00000011B
table_7TR:
db 00000011B, 11000011B, 11110011B, 00111111B, 00001111B, 00000000B, 00000000B, 00000000B
table_7BL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 11000000B, 11110000B, 00111100B
table_7BR:
db 00001111B, 00000011B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B



table_8TL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 01111110B, 11000111B, 10000011B
table_8TR:
db 10000011B, 11000111B, 01111110B, 00111100B, 00000000B, 00000000B, 00000000B, 00000000B
table_8BL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 01111110B, 11100011B, 11000001B
table_8BR:
db 11000001B, 11100011B, 01111110B, 00111100B, 00000000B, 00000000B, 00000000B, 00000000B



table_9TL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 01111110B, 11100111B, 11000011B
table_9TR:
db 11000011B, 11100111B, 11111110B, 11111100B, 00000000B, 00000000B, 00000000B, 00000000B
table_9BL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00110000B, 01110000B, 11100000B, 11000000B
table_9BR:
db 11000000B, 11100000B, 01111111B, 00111111B, 00000000B, 00000000B, 00000000B, 00000000B



table_10TL:
db 00000100B, 00000110B, 00000111B, 11111111B, 11111111B, 00000000B, 00000000B, 00000000B
table_10TR:
db 11111100B, 11111110B, 00000111B, 00000011B, 00000011B, 00000111B, 11111110B, 11111100B
table_10BL:
db 00000000B, 10000000B, 11000000B, 11111111B, 11111111B, 11000000B, 10000000B, 00000000B
table_10BR:
db 00111111B, 01111111B, 11100000B, 11000000B, 11000000B, 11100000B, 01111111B, 00111111B



table_QTL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00111100B, 00111110B, 00000111B, 10000011B
table_QTR:
db 11000011B, 11100111B, 01111110B, 00111100B, 00000000B, 00000000B, 00000000B, 00000000B
table_QBL:
db 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 11000111B
table_QBR:
db 11000111B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B, 00000000B

psect udata_acs ; named variables in access ram
LCD_cnt_l: ds 1 ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h: ds 1 ; reserve9 1 byte for variable LCD_cnt_h
LCD_cnt_ms: ds 1 ; reserve 1 byte for ms counter
LCD_tmp: ds 1 ; reserve 1 byte for temporary use
LCD_counter: ds 1 ; reserve 1 byte for counting through nessage
LCD_clear_counter: ds 1 ; reserve 2 byte for clearing screen counter
LCD_x_address: ds 1
LCD_y_address: ds 1



LCD_E EQU 4 ; LCD enable bit
LCD_RS EQU 2 ; LCD register select bit
LCD_RW EQU 3
LCD_CS1 EQU 0
LCD_CS2 EQU 1
LCD_RST EQU 5

psect glcd_code, class=CODE



GLCD_setup:



movlw 0x00
movwf TRISB, A ; Set port B to output
movwf TRISD, A ; Set port D to output
return
; every command we send now on requires a delay of 500ns
screen_setup: ; Turn the screen on

clrf LATB, A
clrf LATD, A

bcf LATB, LCD_CS1, A
bcf LATB, LCD_CS2, A
bcf LATB, LCD_RS, A
bcf LATB, LCD_RW, A
bcf LATB, LCD_E, A
bsf LATB, LCD_RST, A

movlw 40
call LCD_delay_ms ; wait 40ms for LCD to start up properly

movlw 00111110B ; display off
call LCD_Send_Byte_I

movlw 10111001B ; set x address to 1
call LCD_Send_Byte_I



movlw 01000000B ; Set Y-address to 0
call LCD_Send_Byte_I



movlw 00111111B ; display on
call LCD_Send_Byte_I



return

screen_write:

; x address 1, y address 0
movlw 11111101B ;All pixels on
call LCD_Send_Byte_D

; xaddress 1, y address 1
movlw 00000010B ; All pixels 0
call LCD_Send_Byte_D



; xaddress 1, y address 2
movlw 11110001B
call LCD_Send_Byte_D

movlw 10110111B
call LCD_Send_Byte_D

movlw 00000010B
call LCD_Send_Byte_D

movlw 10111010B ; set x address to 2
call LCD_Send_Byte_I



movlw 01011110B ; Set Y-address to 30
call LCD_Send_Byte_I



; xaddress 2, y address 30
movlw 00000010B ; All pixels 0
call LCD_Send_Byte_D

return



load_table:
; * Main programme ******
lfsr 0, myArray ; Load FSR0 with address in RAM
movlw low highword(myTable) ; address of data in PM
movwf TBLPTRU, A ; load upper bits to TBLPTRU
movlw high(myTable) ; address of data in PM
movwf TBLPTRH, A ; load high byte to TBLPTRH
movlw low(myTable) ; address of data in PM
movwf TBLPTRL, A ; load low byte to TBLPTRL
movlw myTable_l ; bytes to read
movwf counter, A ; our counter register
loop: tblrd*+ ; one byte from PM to TABLAT, increment TBLPRT
movff TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0
decfsz counter, A ; count down to zero
bra loop ; keep going until finished



return

display_table:
movlw myTable_l ; output message to LCD
addlw 0xff ; don't send the final carriage return to LCD
lfsr 2, myArray
call LCD_Write_Message
return

screen_clear:
movlw 8
movwf LCD_x_address, A

set_address:
; set x address
movlw 183
addwf LCD_x_address, W, A
call LCD_Send_Byte_I
; set y address to 0
movlw 01000000B
call LCD_Send_Byte_I
movlw 64
movwf LCD_y_address, A
call set_byte_0

;loops through x addresses
decfsz LCD_x_address, A
goto set_address
return

set_byte_0: ; loops 64 times through y address
movlw 0x00
call LCD_Send_Byte_D
decfsz LCD_y_address, A
bra set_byte_0
return

LCD_Write_Message: ; Message stored at FSR2, length stored in W
movwf LCD_counter, A
LCD_Loop_message:
movf POSTINC2, W, A
call LCD_Send_Byte_D
decfsz LCD_counter, A
bra LCD_Loop_message
return



LCD_Send_Byte_I: ; Transmits byte stored in W to instruction reg and delays by 40us
movwf LATD, A
bcf LATB, LCD_RS, A
;bcf LATB, LCD_RW, A
call LCD_Enable
movlw 10 ; delay 40us
call LCD_delay_x4us

return



LCD_Send_Byte_D: ; write data to GLCD data ram
movwf LATD, A ; data bus loaded on LATD
bsf LATB, LCD_RS, A ; set to write data mode
;bcf LATB, LCD_RW, A
call LCD_Enable
movlw 10 ; stop 40us
call LCD_delay_x4us

return



LCD_Enable: ; pulse enable bit LCD_E for 500ns
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
bsf LATB, LCD_E, A ; Take enable high
nop
nop
nop
nop
nop
nop
nop
nop
bcf LATB, LCD_E, A ; Writes data to LCD
return

; * a few delay routines below here as LCD timing can be quite critical *
LCD_delay_ms: ; delay given in ms in W
movwf LCD_cnt_ms, A
lcdlp2: movlw 250 ; 1 ms delay
call LCD_delay_x4us
decfsz LCD_cnt_ms, A
bra lcdlp2
return

LCD_delay_x4us: ; delay given in chunks of 4 microsecond in W
movwf LCD_cnt_l, A ; now need to multiply by 16
swapf LCD_cnt_l, F, A ; swap nibbles
movlw 0x0f
andwf LCD_cnt_l, W, A ; move low nibble to W
movwf LCD_cnt_h, A ; then to LCD_cnt_h
movlw 0xf0
andwf LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
call LCD_delay
return



LCD_delay: ; delay routine 4 instruction loop == 250ns
movlw 0x00 ; W=0
lcdlp1: decf LCD_cnt_l, F, A ; no carry when 0x00 -> 0xff
subwfb LCD_cnt_h, F, A ; no carry when 0x00 -> 0xff
bc lcdlp1 ; carry, then loop again
return ; carry reset so return




end