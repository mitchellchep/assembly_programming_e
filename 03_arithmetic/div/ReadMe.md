# DIV – Program 1 (div8.asm)

    mov ax, [dividend]   ; ax = 100
    mov bl, [divisor]    ; bl = 7
    div bl               ; al = 100 / 7 = 14, ah = 100 % 7 = 2

GDB output:

    Before div:  eflags 0x202  [ IF ]        AL = 0x64
    After div:   eflags 0x212  [ AF IF ]     AL = 0x0e, AH = 0x02

Result: quotient 14 (0x0e) in AL, remainder 2 (0x02) in AH, since 100 = 14 × 7 + 2.

## Flags

CF, OF, SF, ZF, AF and PF are all **undefined** after DIV (Intel SDM).

| Flag | Status shown | Explanation |
|------|--------------|-------------|
| CF, OF, SF, ZF, PF | Cleared | Undefined after DIV. Not a meaningful result of the division. |
| AF | Set | Undefined after DIV. It changed from 0 to 1 even though the result gives no reason for it, which shows that DIV may modify undefined flags arbitrarily on this CPU. |
| IF | Set | Not affected by arithmetic. |

Unlike ADD/SUB, DIV does not report its result through flags. A program must not
test these flags after DIV. Errors are signaled by the divide error exception (#DE, SIGFPE).



