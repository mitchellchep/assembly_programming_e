; ax = quotient, dx = remainder

section .data
    dividend dw 50000   ; Low word
    highpart dw 0       ; High word (DX=0)
    divisor  dw 300

section .text
    global _start

_start:
    mov ax, [dividend]  ; AX = 50000
    mov dx, [highpart]  ; DX = 0
    mov bx, [divisor]   ; BX = 300
    div bx              ; AX = quotient, 166 
                        ; DX = remainder, 200

    ; Exit call
    mov eax, 1     ;sys call number to exit
    xor ebx, ebx   ; 0 for successful exit
    int 0x80       ; invoke call

# DIV – Program 2 (div16.asm)

    mov ax, [dividend]   ; AX = 50000 (0xC350)
    mov dx, [highpart]   ; DX = 0
    mov bx, [divisor]    ; BX = 300 (0x12C)
    div bx               ; DX:AX / BX -> AX = quotient, DX = remainder

GDB output:

    Before div:  eflags 0x202  [ IF ]
    After div:   eflags 0x212  [ AF IF ]
    AX = 0x00a6 (166), DX = 0x00c8 (200)

Check: 166 × 300 + 200 = 50000.

## How 16-bit DIV differs from 8-bit DIV

| | `div bl` | `div bx` |
|---|---|---|
| Dividend | AX | DX:AX (32-bit) |
| Quotient | AL | AX |
| Remainder | AH | DX |

Here DX = 0, so the 32-bit dividend is just 50000. The quotient fits in
16 bits and the divisor is non-zero, so no #DE exception occurs.

## Flags

CF, OF, SF, ZF, AF and PF are **undefined** after DIV (Intel SDM).

| Flag | Status shown | Explanation |
|------|--------------|-------------|
| CF, OF, SF, ZF, PF | Cleared | Undefined after DIV, so not a meaningful result. |
| AF | Set | Undefined after DIV. It changed from 0 to 1 here, as in the 8-bit program, though the quotient and remainder give no arithmetic reason for it. |
| IF | Set | Not affected by arithmetic. |

DIV does not report results through flags. It signals errors with the
divide error exception (#DE, SIGFPE) when the divisor is 0 or the
quotient does not fit in the destination register.