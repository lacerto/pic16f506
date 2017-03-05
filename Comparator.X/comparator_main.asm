#include "p16F506.inc"

; CONFIG
; __config 0xF94
 __CONFIG _OSC_IntRC_RB4EN & _WDT_OFF & _CP_OFF & _MCLRE_OFF & _IOSCFS_OFF

UNINIT_DATA UDATA
Delay1 res 1
Delay2 res 1

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE

START
    ; Turn off comparator 1.
    bcf CM1CON0, C1ON

    ; No analog input for ADC. Precondition for using RB2 as digital output.
    bcf ADCON0, ANS0
    bcf ADCON0, ANS1

    ; Setup comparator 2:
    ;   bit 7: 1 C2OUT - this is the output
    ;   bit 6: 0 NOT_C2OUTEN - output is placed on RC4/C2OUT
    ;   bit 5: 1 C2POL - output is not inverted
    ;   bit 4: 1 C2PREF2 - not used
    ;   bit 3: 1 C2ON - comparator is on
    ;   bit 2: 0 C2NREF - negative reference is CVref
    ;   bit 1: 1 C2PREF1 - positive reference is RC0/C2IN+
    ;   bit 0: 1 NOT_C2WU - wake-up on comparator change disabled
    movlw b'10111011'
    movwf CM2CON0

    ; RC4/C2OUT output
    movlw b'11101111'
    tris PORTC

    ; RB2 output
    movlw b'11111011'
    tris PORTB

    ; Setup the comparator voltage reference module.
    ;   bit 7: 1 VREN - CVref is enabled
    ;   bit 6: 0 VROE - CVref output disabled
    ;   bit 5: 1 VRR - low range
    ;   bit 4: unimplemented
    ;   bit 3-0: 1111 VR<3:0> in the low range CVref = (VR<3:0>/24)*Vdd
    movlw b'10111111'
    movwf VRCON

    ; Blink alive LED.
Mainloop:
    call DELAY
    bsf PORTB, RB2
    call DELAY
    bcf PORTB, RB2
    goto Mainloop

    ; Subroutine for a short delay.
DELAY
    ; Blink faster if C2OUT == 1.
    btfsc CM2CON0, C2OUT
    goto Faster
    clrf Delay2
    goto StartDelayLoop
Faster:
    movlw 0x80
    movwf Delay2
StartDelayLoop:
    clrf Delay1
Loop:
    decfsz Delay1, f
    goto Loop
    decfsz Delay2, f
    goto Loop
    retlw 0x00

    END