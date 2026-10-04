# MUL – Program 1 (mul_byte.asm)

    mov al, [num1]      ; AL = 25
    mul byte [num2]     ; AX = AL * 10 = 250 (0x00FA)

GDB output:

    Before: eflags 0x202 [ IF ]
    After:  eflags 0x202 [ IF ]     AX = 0x00fa, AH = 0x00

| Flag | Status | Reason |
|------|--------|--------|
| CF | Cleared | The upper half of the product (AH) is 0, so the result fits in AL. |
| OF | Cleared | Same rule as CF for MUL. |
| SF, ZF, AF, PF | Cleared (shown) | Undefined after MUL. Not a meaningful result. |

Note: AL = 0xFA has bit 7 set, yet SF is 0. That confirms MUL does not
update SF from the result.


# MUL – Program 2 (mul_word.asm)

    mov ax, [num1]      ; AX = 3000
    mul word [num2]     ; DX:AX = 3000 * 200 = 600000 (0x0009_27C0)

GDB output:

    Before: eflags 0x202 [ IF ]
    After:  eflags 0xa03 [ CF IF OF ]     DX = 0x0009, AX = 0x27c0

| Flag | Status | Reason |
|------|--------|--------|
| CF | Set | The upper half (DX = 9) is non-zero, so the product needs more than 16 bits. |
| OF | Set | Same rule as CF for MUL. |
| SF, ZF, AF, PF | Cleared (shown) | Undefined after MUL. Not a meaningful result. |

Comparison: in program 1 the upper half was 0 (CF = OF = 0). Here it is
non-zero (CF = OF = 1). That is the only information MUL reports via flags.