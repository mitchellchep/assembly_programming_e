# 03.asm – call and ret without a stack frame (64-bit)

64-bit static ELF. Runs with no output, exit code 0.

Start of program: `RSP = S = 0x7fffffffd630`.

## Source summary
    mov rax, 10
    call calculate      ; calculate: add rax, 5 / ret
    after_call: nop
    exit syscall

## Stack trace (GDB, stepi)
| Instruction | RSP after | Stack evidence | Registers |
|---|---|---|---|
| `mov rax, 10` | `0x7fffffffd630` (S) | argc | RAX = 10 |
| `call calculate` | `0x7fffffffd628` (S-8) | `[rsp] = 0x40100a` | RIP = `0x401015` (`calculate`) |
| `add rax, 5` | `0x7fffffffd628` | unchanged | RAX = 15 |
| `ret` | `0x7fffffffd630` (S) | argc | RIP = `0x40100a` (`after_call`) |

## Explanation
The only stack use in this program is the return address. The `call` instruction sits at
`0x401005` and is 5 bytes long, so it pushes `0x40100a` (the next instruction) and jumps to
`calculate`. RSP drops by 8. `calculate` pushes and pops nothing, so when `ret` runs the
return address is still on top of the stack. `ret` pops it into RIP and RSP goes back to S.
The result travels back in RAX (15), not on the stack.

## Observations
- The value stored by `call` (`0x40100a`) is the same address GDB reports for the label `after_call` and the RIP right after `ret`.
- There is no `push rbp` / `mov rbp, rsp`, so RBP stays 0 the whole time. A frame is optional when a function needs no local variables.
- If `calculate` had pushed a value and not popped it, `ret` would have jumped to that value instead of `after_call`.