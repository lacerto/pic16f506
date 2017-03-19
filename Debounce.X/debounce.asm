#include "p16F506.inc"

; CONFIG
; Internal RC oscillator, RB4 enabled
; Watchdog off
; Code protection off
; MCLR off, RB3 input
; Internal oscillator @ 4 MHz
; __config 0xFF94
 __CONFIG _OSC_IntRC_RB4EN & _WDT_OFF & _CP_OFF & _MCLRE_OFF & _IOSCFS_OFF

MaxCount equ 0x0a

DATA_REGS UDATA
DelayCounter res 1
SwitchState res 1
SwitchCounter res 1

RES_VECT  CODE    0x0000
    GOTO    START

MAIN_PROG CODE

START
    ; Turn off comparators, all IO is digital.
    bcf CM1CON0, C1ON
    bcf CM2CON0, C2ON

    ; No pins configured for analog input
    ; (AN0 [RB0], AN1 [RB1], AN2 [RB2] are digital).
    bcf ADCON0, ANS0
    bcf ADCON0, ANS1

    ; Clear T0CS (Timer0 clock source is internal,
    ; so we can use the T0CKI (RC5) pin as digital IO).
    movlw 0xdf
    option

    ; RC0 & RC1 are outputs, all other pins are inputs (also on PORTB).
    movlw b'00111100'
    tris PORTC

    ; Switch on alive LED @ RC1
    movlw 0x02
    movwf PORTC

    ; Clear the debounce counter.
    clrw
    movwf SwitchCounter

    ; Assume that switch pin is high.
    movlw 0x01
    movwf SwitchState

MainLoop:
    btfsc SwitchState, 0
    goto WaitForLow

; WaitForHigh
    ; Increase counter if the switch input is high, clear it otherwise.
    clrw
    btfsc PORTB, RB0
    incf SwitchCounter, W
    movwf SwitchCounter
    goto CompareCounter

WaitForLow:
    ; Increase counter if the switch input pin is low, clear it otherwise.
    clrw
    btfss PORTB, RB0
    incf SwitchCounter, W
    movwf SwitchCounter

CompareCounter:
    movf SwitchCounter, W
    xorlw MaxCount
    btfss STATUS, Z
    goto Delay

    ; Complement the state if counter has reached MaxCount. Clear counter.
    comf SwitchState, F
    clrf SwitchCounter

    ; Invert the LED state only if the switch state changed
    ; from high to low.
    btfss SwitchState, 0
    goto InvertLED
    goto Delay

InvertLED:
    btfss PORTC, RC0
    goto SetLED
    bcf PORTC, RC0
    goto Delay
SetLED:
    bsf PORTC, RC0

Delay:
    ; Delay approx. 1 ms @ 4MHz.
    movlw 0x48
    movwf DelayCounter
    decfsz DelayCounter, F
    goto $-1
    decfsz DelayCounter, F
    goto $-1
    goto MainLoop

    END