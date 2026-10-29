
# SUB – EFLAGS Analysis

## Program 1: sub8.asm

    mov al, [num1]     ; AL = 50
    sub al, [num2]     ; AL = 50 - 80 = 0xE2

GDB output:

    Before: eflags 0x202 [ IF ]
    After:  eflags 0x287 [ CF PF SF IF ]    AL = 0xe2

| Flag | Status | Reason |
|------|--------|--------|
| CF | Set | 50 < 80 unsigned, so a borrow occurred. |
| SF | Set | Bit 7 of 0xE2 is 1. |
| PF | Set | 11100010 has four 1s (even). |
| OF | Cleared | -30 fits in a signed byte. |
| ZF | Cleared | Result is not zero. |
| AF | Cleared | Low nibble 0x2 - 0x0 needs no borrow. |

## Program 2: sub16.asm

    mov ax, [num1]     ; AX = 1000 (0x03E8)
    sub ax, [num2]     ; AX = 1000 - 2000 = 0xFC18

GDB output:

    Before: eflags 0x202 [ IF ]
    After:  eflags 0x287 [ CF PF SF IF ]    AX = 0xfc18

| Flag | Status | Reason |
|------|--------|--------|
| CF | Set | 1000 < 2000 unsigned, so a borrow out of bit 15. |
| SF | Set | Bit 15 of 0xFC18 is 1. |
| PF | Set | Low byte 0x18 = 00011000 has two 1s (even). |
| OF | Cleared | -1000 fits in a signed 16-bit value. |
| ZF | Cleared | Result is not zero. |
| AF | Cleared | Low nibble 0x8 - 0x0 needs no borrow. |

## Observations

Both programs show CF = 1 with OF = 0: the unsigned result underflowed,
but the signed result (-30, -1000) is correct. Operand size only changes
which bit is the sign bit (7 vs 15) and which bit carries out.