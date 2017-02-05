#include "p16F506.inc"

; CONFIG
; __config 0xFFD4
 __CONFIG _OSC_IntRC_RB4EN & _WDT_OFF & _CP_OFF & _MCLRE_OFF & _IOSCFS_ON

    extern GetCount, PortCTable, PortBTable

UNINITIALIZED_DATA  UDATA
Index               res 1           ; Look-up table index
PortBVal            res 1           ; Value to write to PORTB
PortCVal            res 1           ; Value to write to PORTC
Count               res 1           ; Count of look-up table entries
PortBBeforeSleep    res 1           ; Value of PORTB read before going to sleep

RES_VECT  CODE    0x0000            ; processor reset vector
    pagesel START
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE

START
    pagesel GetCount
    call GetCount                   ; get the number of look-up table entries
    movwf Count                     ; save it to Count
    pagesel START

    ; NOT_PD == 1 normal reset / power up
    ; NOT_PD == 0 reset after sleep
    btfsc STATUS, NOT_PD
    goto Clear               ; not coming from sleep -> Clear table pointer
    ; RBWUF == 1 reset due to wake-up from sleep on pin change
    ; RBWUF == 0 after power up or other reset
    btfsc STATUS, RBWUF
    goto Increase            ; Increase table pointer
    goto Clear

Increase:
    btfss PortBBeforeSleep, RB3     ; RB3 == 0? don't increase Index
    goto Init
    incf Index, F                   ; Index++
    movf Index, W
    xorwf Count, W                  ; Index == Count?
    btfss STATUS, Z                 ; yes -> skip next (goto Clear)
    goto Init                       ; no -> Init

Clear:
    clrf PortBBeforeSleep
    clrf Index

Init:
    ; Turn off comparators, all IO is digital.
    bcf CM1CON0, C1ON
    bcf CM2CON0, C2ON

    ; No pins configured for analog input
    ; (AN0 [RB0], AN1 [RB1], AN2 [RB2] are digital).
    bcf ADCON0, ANS0
    bcf ADCON0, ANS1

    ; Enable wake-up on pin change, clear T0CS (Timer0 clock source
    ; is internal, so we can use the T0CKI (RC5) pin as digital IO).
    movlw 0x5f
    option

    ; RB3 & RB5 on PORTB are inputs.
    movlw b'00101000'
    tris PORTB

    ; All PORTC pins are output.
    clrw
    tris PORTC

    ; Check RB5.
    btfss PORTB, RB5    ; Button pressed? (RB5 == 0)
    clrf Index          ; Yes -> clear Index

    ; Get data from the look-up table and write it to the ports.
    pagesel PortBTable
    movf Index, W
    call PortBTable
    movwf PORTB

    movf Index, W
    call PortCTable
    movwf PORTC
    pagesel GoToSleep

GoToSleep:
    ; Read the input pins to avoid instant wake-up (DS41268D chapter 10.9.1).
    movf PORTB, W
    movwf PortBBeforeSleep
    sleep

    END