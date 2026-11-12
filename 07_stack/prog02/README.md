# 02.asm – call and a stack frame with local variables (64-bit)

64-bit static ELF. Runs with no output, exit code 0.

Start of program: `RSP = S = 0x7fffffffd630`.

## Source summary
`_start` calls `work`. `work` builds a frame (`push rbp`, `mov rbp, rsp`, `sub rsp, 16`),
stores 100 at `[rbp-8]` and 200 at `[rbp-16]`, loads them into RAX and RBX, then tears the
frame down (`mov rsp, rbp`, `pop rbp`, `ret`).

## Stack trace (GDB, stepi)
| Instruction | RSP after | RBP after | Stack evidence |
|---|---|---|---|
| `call work` | `...d628` (S-8) | 0 | `[rsp] = 0x401005` (return address) |
| `push rbp` | `...d620` (S-16) | 0 | `[rsp] = 0` (saved caller RBP) |
| `mov rbp, rsp` | `...d620` | `...d620` | frame base set |
| `sub rsp, 16` | `...d610` (S-32) | `...d620` | 16 bytes reserved, nothing written |
| `mov qword [rbp-8], 100` | `...d610` | `...d620` | `0x64` stored at `...d618` |
| `mov qword [rbp-16], 200` | `...d610` | `...d620` | `0xc8` stored at `...d610` |
| `mov rax, [rbp-8]` | `...d610` | `...d620` | RAX = 100 |
| `mov rbx, [rbp-16]` | `...d610` | `...d620` | RBX = 200 |
| `nop` | `...d610` | `...d620` | |
| `mov rsp, rbp` | `...d620` (S-16) | `...d620` | locals released |
| `pop rbp` | `...d628` (S-8) | 0 | caller RBP restored |
| `ret` | `...d630` (S) | 0 | RIP = `0x401005` |

(All addresses are `0x7fffffffd...`; the prefix is shortened for the table.)

## Explanation
`call` pushes the address of the next instruction (`0x401005`) and jumps to `work`, so RSP
drops by 8. `work` saves the caller's RBP with `push rbp` and then sets `RBP = RSP`, giving
the function a fixed reference point. `sub rsp, 16` reserves space for two 8-byte locals by
moving RSP down; it writes nothing. The locals are written afterwards with `mov` relative to
RBP, which does not change RSP. To leave, `mov rsp, rbp` discards the locals, `pop rbp`
restores the caller's RBP, and `ret` pops the return address into RIP. RSP ends at S, so
the stack is balanced.

## Observations
- The return address pushed by `call` (`0x401005`) is exactly the RIP after `ret`.
- Layout from high to low addresses: return address, saved RBP (at the RBP address), local 1 at RBP-8, local 2 at RBP-16.
- RSP did not change while the locals were written, because they were stored with RBP-relative `mov`, not `push`.
- RAX and RBX end as 100 and 200, and keep those values after the function returns.