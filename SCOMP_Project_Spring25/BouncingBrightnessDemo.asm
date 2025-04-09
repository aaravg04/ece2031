; IODemo.asm
; Produces a "bouncing" animation on the LEDs.
; The LED pattern is initialized with the switch state.
; Before sending the pattern to the LEDs the program checks which single
; bit is set, then uses the corresponding brightness map (B0..B9) for output.

ORG 0

        ; Get and store the switch values
        IN     Switches
;       OUT    LEDs           ; (Don't output raw pattern)
        STORE  Pattern

Left:
        ; Slow down the loop so humans can watch it.
;       CALL   Delay

        ; Check if the leftmost bit (bit9) is set; if so, switch direction.
        LOAD   Pattern
        AND    Bit9
        JPOS   Right         ; if bit9 is 1; go right

        ; Shift the pattern left by one bit.
        LOAD   Pattern
        SHIFT  1
        STORE  Pattern
        CALL   SetLED        ; Use brightness map corresponding to pattern
        JUMP   Left

Right:
        ; Slow down the loop so humans can watch it.
;       CALL   Delay

        ; Check if the rightmost bit (bit0) is set; if so, switch direction.
        LOAD   Pattern
        AND    Bit0
        JPOS   Left          ; if bit0 is 1; go left

        ; Shift the pattern right by one bit.
        LOAD   Pattern
        SHIFT  -1
        STORE  Pattern
        CALL   SetLED
        JUMP   Right

; -------- Delay Subroutine (optional) -----------
Delay:
        OUT    Timer
WaitDelay:
        IN     Timer
        ADDI   -5
        JNEG   WaitDelay
        RETURN

; -------- SetLED Subroutine --------
; This subroutine determines which bit is set in Pattern and then
; sends the corresponding brightness constant B0..B9 to the LEDs.
SetLED:
        LOAD   Pattern
        AND    Bit0
        JPOS   sendB0
        LOAD   Pattern
        AND    Bit1
        JPOS   sendB1
        LOAD   Pattern
        AND    Bit2
        JPOS   sendB2
        LOAD   Pattern
        AND    Bit3
        JPOS   sendB3
        LOAD   Pattern
        AND    Bit4
        JPOS   sendB4
        LOAD   Pattern
        AND    Bit5
        JPOS   sendB5
        LOAD   Pattern
        AND    Bit6
        JPOS   sendB6
        LOAD   Pattern
        AND    Bit7
        JPOS   sendB7
        LOAD   Pattern
        AND    Bit8
        JPOS   sendB8
        LOAD   Pattern
        AND    Bit9
        JPOS   sendB9
        JUMP   EndSetLED

sendB0:
        LOAD   B0
        OUT    LEDs
        JUMP   EndSetLED

sendB1:
        LOAD   B1
        OUT    LEDs
        JUMP   EndSetLED

sendB2:
        LOAD   B2
        OUT    LEDs
        JUMP   EndSetLED

sendB3:
        LOAD   B3
        OUT    LEDs
        JUMP   EndSetLED

sendB4:
        LOAD   B4
        OUT    LEDs
        JUMP   EndSetLED

sendB5:
        LOAD   B5
        OUT    LEDs
        JUMP   EndSetLED

sendB6:
        LOAD   B6
        OUT    LEDs
        JUMP   EndSetLED

sendB7:
        LOAD   B7
        OUT    LEDs
        JUMP   EndSetLED

sendB8:
        LOAD   B8
        OUT    LEDs
        JUMP   EndSetLED

sendB9:
        LOAD   B9
        OUT    LEDs
        JUMP   EndSetLED

EndSetLED:
        RETURN

; -------- Data Definitions --------
Pattern:   DW 0

; -------- Useful Bit Mask Constants --------
; (Define full 10-bit masks for bit positions 0 through 9.)
Bit0:      DW &B0000000001
Bit1:      DW &B0000000010
Bit2:      DW &B0000000100
Bit3:      DW &B0000001000
Bit4:      DW &B0000010000
Bit5:      DW &B0000100000
Bit6:      DW &B0001000000
Bit7:      DW &B0010000000
Bit8:      DW &B0100000000
Bit9:      DW &B1000000000

; -------- I/O Address Constants --------
Switches:  EQU 000
; LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
LEDs: 	   EQU &H021

; -------- Brightness Maps --------
B0: DW &B0000010000000001
B1: DW &B0000110000000010
B2: DW &B0000100000010110 
B3: DW &B0000100000101000
B4: DW &B0001000000011000
B5: DW &B0001000001101000 
B6: DW &B0010000001100000
B7: DW &B0010000110000000 
B8: DW &B0100000101000000
B9: DW &B0100001010000000
