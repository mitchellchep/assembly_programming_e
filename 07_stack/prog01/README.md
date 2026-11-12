# 01.asm – push and pop of two registers (64-bit)

64-bit static ELF (`file`: ELF 64-bit). Runs with no output, exit code 0.

Start of program: `RSP = S = 0x7fffffffd630`. The top of the stack holds `argc` (1),
followed by the `argv` pointers.

## Source summary
    mov rax, 100 / mov rbx, 200
    push rax / push rbx / nop
    pop rcx / pop rdx / nop
    exit syscall

## Stack trace (GDB, stepi)
| Instruction | RSP after | Top of stack | Registers |
|---|---|---|---|
| `mov rax, 100` | `0x7fffffffd630` (S) | argc | RAX = 100 |
| `mov rbx, 200` | `0x7fffffffd630` (S) | argc | RBX = 200 |
| `push rax` | `0x7fffffffd628` (S-8) | `0x64` | |
| `push rbx` | `0x7fffffffd620` (S-16) | `0xc8`, then `0x64` | |
| `nop` | `0x7fffffffd620` | unchanged | |
| `pop rcx` | `0x7fffffffd628` (S-8) | `0x64` | RCX = 200 |
| `pop rdx` | `0x7fffffffd630` (S) | argc | RDX = 100 |

## Explanation
`push` first subtracts 8 from RSP and then writes the 64-bit value at `[RSP]`. After two
pushes RSP is 16 bytes below S, with 200 on top of 100. `pop` reads `[RSP]` into the
register and then adds 8 to RSP. The stack is LIFO: 200 was pushed last, so it is popped
first and lands in RCX, while RDX receives 100. RSP finishes at S, so the stack is
balanced. No `call` is used, so no return address is involved.

## Observations
- RSP moved by exactly 8 on every push and pop, even though the values (100, 200) are tiny. A 64-bit push always uses a full 8-byte slot.
- RCX got 200 and RDX got 100, the reverse of the order they were pushed in. That is LIFO behavior.
- At the `nop` the stack dump shows `0xc8` at `...d620` and `0x64` at `...d628`, sitting directly below argc at S.
- RAX and RBX kept their values throughout. Pushing copies a value, it does not clear the register.
