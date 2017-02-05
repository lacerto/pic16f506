#include "p16F506.inc"

; CONFIG
; __config 0xFFD4
 __CONFIG _OSC_IntRC_RB4EN & _WDT_OFF & _CP_OFF & _MCLRE_OFF & _IOSCFS_ON

    cblock  0x0d
Delay1
Delay2
Delay3
Flag
    endc

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE                      ; let linker place main program

START

    ; Wake-up occurred after sleep and pin change?
    clrw
    movwf Flag

    btfsc STATUS, NOT_PD
    goto Init
    btfsc STATUS, RBWUF
    bsf Flag, 0

Init:
    ; turn of comparator 1 & 2
    ; this is necessary for using rc0 and rc1 as digital outputs
    ; see table 5-7 in the data sheet
    bcf CM1CON0, C1ON
    bcf CM2CON0, C2ON

    ; portc all output
    clrw
    tris PORTC

    ; RB3 input
    movlw 0xff
    tris PORTB

    ; enable wake-up on pin change
    movlw b'01111111'
    option

Mainloop:
    ; set the lower 4 bits to 1
    ; in order to light up the 4 LEDs on the board
    movlw 0x00
    movwf PORTC

    call DELAY

;    movlw 0x0f
;    movwf PORTC
    bsf PORTC, RC0

    btfsc Flag, 0
    bsf PORTC, RC3

    movf PORTB, W
    sleep
    goto $

DELAY
    clrf Delay1
    clrf Delay2
    movlw 0x10
    movwf Delay3
Loop:
    decfsz Delay1, f
    goto Loop
    decfsz Delay2, f
    goto Loop
    decfsz Delay3, f
    goto Loop
    retlw 0x00

    END