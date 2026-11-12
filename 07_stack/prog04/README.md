# 04.asm – stack frame in 32-bit code: crash as built, then rebuilt correctly

The source begins with `BITS 32` and uses `push ebp`, `mov ebp, esp`, `sub esp, 8`, locals at
`[ebp-4]` and `[ebp-8]`, then `mov esp, ebp` / `pop ebp` / `ret`.

## Part A – the shipped executable (64-bit): Segmentation fault, exit code 139

`BITS 32` only changes how NASM encodes the instructions. The file was linked as a 64-bit
program (`file` says ELF 64-bit), so the CPU executed it in 64-bit mode.

Start: `RSP = 0x7fffffffd630`.

| Instruction | RSP | RBP | Note |
|---|---|---|---|
| `call work` | `0x7fffffffd628` | 0 | pushes an 8-byte return address, `[rsp] = 0x401005` |
| `push ebp` (GDB shows `push %rbp`) | `0x7fffffffd620` | 0 | 8 bytes pushed |
| `mov ebp, esp` (`mov %esp,%ebp`) | `0x7fffffffd620` | `0xffffd620` | 32-bit write zeroes the upper half of RBP |
| `sub esp, 8` (`sub $0x8,%esp`) | `0xffffd618` | `0xffffd620` | RSP is truncated the same way |
| `mov dword [ebp-4], 100` | | | write to `0xffffd61c`: **SIGSEGV** at `work+6` |

GDB's memory map shows the real stack at `0x7ffffffdd000-0x7ffffffff000`. Nothing is mapped
near `0xffffd6xx`, so the first write through the truncated pointer faults. `x/4xw $esp`
reports "Cannot access memory at address 0xffffd618". The `ret` is never reached.

## Part B – rebuilt as 32-bit: exit code 0

    nasm -f elf32 -g -F dwarf 04.asm -o 04_32.o
    ld -m elf_i386 04_32.o -o 04_32

Start: `ESP = S = 0xffffc7b0`, `[S] = 1` (argc).

| Instruction | ESP after | EBP after | Stack evidence |
|---|---|---|---|
| `call work` | `0xffffc7ac` (S-4) | 0 | `[esp] = 0x08049005` (return address) |
| `push ebp` | `0xffffc7a8` (S-8) | 0 | `[esp] = 0` (saved EBP) |
| `mov ebp, esp` | `0xffffc7a8` | `0xffffc7a8` | frame base |
| `sub esp, 8` | `0xffffc7a0` (S-16) | `0xffffc7a8` | 8 bytes reserved, nothing written |
| `mov dword [ebp-4], 100` | `0xffffc7a0` | | `0x64` at `0xffffc7a4` |
| `mov dword [ebp-8], 200` | `0xffffc7a0` | | `0xc8` at `0xffffc7a0` |
| `mov eax, [ebp-4]` / `mov ebx, [ebp-8]` | `0xffffc7a0` | | EAX = 100, EBX = 200 |
| `mov esp, ebp` | `0xffffc7a8` | | locals released |
| `pop ebp` | `0xffffc7ac` (S-4) | 0 | saved EBP restored |
| `ret` | `0xffffc7b0` (S) | 0 | EIP = `0x08049005`, stack balanced |

## Explanation and observations
- In 32-bit code `call`, `push` and `pop` move ESP by 4. In the 64-bit executable the same source moved RSP by 8, so the same instructions behave differently depending on the mode.
- The crash came from `mov ebp, esp` and `sub esp, 8`. They only handle 32 bits, which is fine for a 32-bit stack address (`0xffffc7b0`) but destroys a 64-bit one (`0x7fffffffd620`).
- `sub esp, 8` reserves space without writing anything. The locals are written later through EBP.
- The return address `0x08049005` pushed by `call` is the EIP restored by `ret`.
- After `ret`, memory at `0xffffc7a0` still holds `0xc8` and `0x64` (`x/4xw` shows `0xc8 0x64 0x0 0x08049005`). Popping and returning do not erase data below ESP.