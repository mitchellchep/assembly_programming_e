# ADD – Program 1 (add1.asm)

```nasm
mov al, [num1]     ; al = 120 (0x78)
add al, [num2]     ; al = 120 + 10 = 130 (0x82)
```

**GDB output after the `add`:**

    eflags  0xa96  [ PF AF SF IF OF ]
    AL = 0x82

# ADD – Program 2 (add16.asm)

mov ax, [num1]     ; ax = 32000 (0x7D00)
add ax, [num2]     ; ax = 32500 (0x7EF4)

GDB output after the add:

    eflags  0x202  [ IF ]
    AX = 0x7EF4

All arithmetic flags are cleared because the result fits both as an
unsigned and as a signed 16-bit number, is non-zero, is positive,
has an odd number of 1s in its low byte, and no nibble carry occurred.

