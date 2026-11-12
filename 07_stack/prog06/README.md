# 06.asm – `BITS 32` source built as a 64-bit program, compared with a real 32-bit build

Source: `mov eax, 0x11223344`, `mov ebx, 0x1234`, `push eax`, `push ebx`, `nop`, `pop ebx`,
`pop eax`, then exit with `mov eax, 1` / `xor ebx, ebx` / `int 0x80`.

## Part A – 64-bit executable (exit code 0)

GDB disassembles the same opcode bytes as `push %rax` / `push %rbx` / `pop %rbx` / `pop %rax`:
the CPU runs them as 64-bit instructions. Start: `RSP = S = 0x7fffffffd630`.

| Instruction | RSP after | Stack evidence | Registers |
|---|---|---|---|
| `mov eax, 0x11223344` | S | argc | RAX = `0x11223344` (upper half zeroed) |
| `mov ebx, 0x1234` | S | argc | RBX = `0x1234` |
| `push eax` | `0x7fffffffd628` (S-8) | `0x0000000011223344` | |
| `push ebx` | `0x7fffffffd620` (S-16) | `0x0000000000001234`, then `0x0000000011223344` | |
| `nop` | `0x7fffffffd620` | unchanged | |
| `pop ebx` | `0x7fffffffd628` (S-8) | `0x0000000011223344`, then argc | RBX = `0x1234` |
| `pop eax` | `0x7fffffffd630` (S) | argc | RAX = `0x11223344` |

## Part B – rebuilt as real 32-bit (traced in GDB)

    nasm -f elf32 -g -F dwarf 06.asm -o 06_32.o
    ld -m elf_i386 06_32.o -o 06_32

Start: `ESP = S = 0xffffc7b0`.

| Instruction | ESP after | Stack evidence |
|---|---|---|
| `push eax` | `0xffffc7ac` (S-4) | `0x11223344` |
| `push ebx` | `0xffffc7a8` (S-8) | `0x00001234`, then `0x11223344` |
| `pop ebx` | `0xffffc7ac` (S-4) | `0x11223344` on top |
| `pop eax` | `0xffffc7b0` (S) | argc, stack balanced |

## Explanation and observations
- The same source with the same push/pop order uses 8 bytes per operation in 64-bit mode and 4 bytes in 32-bit mode.
- LIFO order is identical in both: `ebx` was pushed last and popped first.
- The mismatch was harmless here because the program only pushes and pops, and never copies ESP into another register. In `04` the same mismatch crashed, because `mov ebp, esp` truncated the stack pointer.
- The exit uses the 32-bit `int 0x80` interface, which Linux still accepts from a 64-bit process, so the exit code is 0.