# 05.asm – 64-bit values on the stack and little-endian layout

64-bit static ELF. Runs with no output, exit code 0.

Start of program: `RSP = S = 0x7fffffffd630`.

## Source summary
    mov rax, 0x1122334455667788 / mov rbx, 0x1234
    push rax / push rbx / nop
    pop rbx / pop rax
    exit syscall

## Stack trace (GDB, stepi)
| Instruction | RSP after | Stack top (`x/2xg $rsp`) | Registers |
|---|---|---|---|
| `mov` x2 | `0x7fffffffd630` (S) | argc | RAX = `0x1122334455667788`, RBX = `0x1234` |
| `push rax` | `0x7fffffffd628` (S-8) | `0x1122334455667788` | |
| `push rbx` | `0x7fffffffd620` (S-16) | `0x1234`, then `0x1122334455667788` | |
| `nop` | `0x7fffffffd620` | unchanged | |
| `pop rbx` | `0x7fffffffd628` (S-8) | `0x1122334455667788`, then argc | RBX = `0x1234` |
| `pop rax` | `0x7fffffffd630` (S) | `0x1` (argc) | RAX = `0x1122334455667788` |

Raw dump at the `nop`:

    0x7fffffffd620: 0x0000000000001234      0x1122334455667788
    0x7fffffffd620: 34 12 00 00 00 00 00 00
    0x7fffffffd628: 88 77 66 55 44 33 22 11

## Explanation
Each push stores a full 8 bytes, so the small value `0x1234` is padded with zeros up to a
qword. x86 is little-endian, so the least significant byte goes at the lowest address:
`0x1234` appears as `34 12 ...` and `0x1122334455667788` as `88 77 66 ... 11`. The pops run in
the reverse order of the pushes (RBX first, then RAX), so each value returns to its own
register. RSP ends at S, so the stack is balanced.

## Observations
- RAX and RBX show the same values before and after the pops, because they were restored to exactly what they held when pushed. The proof that the pops ran is that RSP moved `...d620` → `...d628` → `...d630` and the top of the stack changed from `0x1234` to `0x1122334455667788` to argc.
- Popping in the same order as the pushes would have swapped the two registers.
- Memory holds the bytes in little-endian order, which differs from how GDB prints a register.
- The 8-byte slot for `0x1234` is `34 12` followed by six zero bytes.