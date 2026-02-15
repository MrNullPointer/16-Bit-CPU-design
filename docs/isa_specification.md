# 16-Bit CPU - Instruction Set Architecture Specification

## 1. Overview

This document specifies the instruction set architecture (ISA) for the 16-bit CPU. The CPU uses a fixed-width 16-bit instruction format with a multi-cycle execution model.

## 2. Programmer's Model

### 2.1 Registers

| Register | Width | Description |
|----------|-------|-------------|
| A | 16-bit | Primary accumulator / first ALU operand |
| B | 16-bit | Secondary operand / second ALU operand |
| C | 16-bit | Result register / ALU output |
| PC | 16-bit | Program Counter (only lower 8 bits used for addressing) |
| SP | 8-bit | Stack Pointer (initialized to 0xFF, grows downward) |
| IR | 16-bit | Instruction Register (not programmer-visible) |

### 2.2 Status Flags

| Flag | Bit | Set When |
|------|-----|----------|
| ZERO (Z) | 4 | ALU result equals 0x0000 |
| EQUAL (EQ) | 3 | Register A equals Register B |
| GREATER THAN (GT) | 2 | Register A > Register B (unsigned comparison) |
| OVERFLOW (OV) | 1 | Signed arithmetic overflow occurred |
| CARRY (CY) | 0 | Unsigned carry out (ADD) or borrow (SUB) |

Flags are updated by arithmetic and logic operations and latched for use by subsequent branch instructions.

## 3. Instruction Format

All instructions are 16 bits wide with a fixed format:

```
Bit:  15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
     [  Mode  ][ Opcode  ][------------- Operand (11 bits) ----------]
```

| Field | Bits | Range | Description |
|-------|------|-------|-------------|
| Mode | 15:14 | 0-3 | Selects operation category |
| Opcode | 13:11 | 0-7 | Selects operation within category |
| Operand | 10:0 | 0-2047 | Immediate value or memory address |

## 4. Instruction Set

### 4.1 Mode 00: Arithmetic Operations

All arithmetic operations take their operands from registers A and B and write results to register C.

| Opcode | Mnemonic | Operation | Flags Affected |
|--------|----------|-----------|----------------|
| 000 | ADD | C = A + B | Z, EQ, GT, OV, CY |
| 001 | SUB | C = A - B | Z, EQ, GT, OV, CY |
| 010 | MUL | C = (A * B)[15:0] | Z, EQ, GT, OV |
| 011 | INC | C = A + 1 | Z, OV, CY |
| 100 | DEC | C = A - 1 | Z, OV, CY |
| 101 | CMP | flags = A - B | Z, EQ, GT, OV, CY |
| 110 | NOP | No operation | None |
| 111 | HALT | Stop execution | None |

**Notes:**
- `MUL` produces a 32-bit result; only the lower 16 bits are stored in C. The overflow flag indicates if the upper 16 bits are non-zero.
- `CMP` performs subtraction but does NOT store the result. Only flags are updated.
- `INC` and `DEC` operate on register A only.

### 4.2 Mode 01: Logic Operations

All logic operations take operands from A and B and write to C.

| Opcode | Mnemonic | Operation | Flags Affected |
|--------|----------|-----------|----------------|
| 000 | AND | C = A AND B | Z, EQ, GT |
| 001 | OR | C = A OR B | Z, EQ, GT |
| 010 | NAND | C = NOT(A AND B) | Z, EQ, GT |
| 011 | NOR | C = NOT(A OR B) | Z, EQ, GT |
| 100 | NOTA | C = NOT A | Z, EQ, GT |
| 101 | NOTB | C = NOT B | Z, EQ, GT |
| 110 | XOR | C = A XOR B | Z, EQ, GT |
| 111 | XNOR | C = NOT(A XOR B) | Z, EQ, GT |

### 4.3 Mode 10: Memory, Immediate, and Branch Operations

These operations use the 11-bit operand field as a memory address or branch target.

| Opcode | Mnemonic | Operation | Description |
|--------|----------|-----------|-------------|
| 000 | LDA addr | A = Mem[addr] | Load register A from data memory |
| 001 | LDB addr | B = Mem[addr] | Load register B from data memory |
| 010 | STC addr | Mem[addr] = C | Store register C to data memory |
| 011 | LIC imm | C = zero_extend(imm) | Load 11-bit immediate into C |
| 100 | JMP addr | PC = addr | Unconditional jump |
| 101 | JE addr | if EQ: PC = addr | Jump if A == B |
| 110 | JGT addr | if GT: PC = addr | Jump if A > B (unsigned) |
| 111 | JZ addr | if Z: PC = addr | Jump if last result was zero |

**Notes:**
- For `LDA` and `LDB`, the operand specifies the data memory address (8-bit effective).
- For `LIC`, the 11-bit operand is zero-extended to 16 bits.
- Branch conditions are evaluated using latched flags from the most recent flag-modifying instruction.
- If a conditional branch is not taken, PC simply increments.

### 4.4 Mode 11: Shift, Rotate, and Subroutine Operations

| Opcode | Mnemonic | Operation | Description |
|--------|----------|-----------|-------------|
| 000 | SHR | C = A >> B[3:0] | Logical shift right by B[3:0] positions |
| 001 | SHL | C = A << B[3:0] | Logical shift left by B[3:0] positions |
| 010 | SRA | C = A >>> B[3:0] | Arithmetic shift right (sign-preserving) |
| 011 | ROL | C = {A[14:0], A[15]} | Rotate left by 1 position |
| 100 | ROR | C = {A[0], A[15:1]} | Rotate right by 1 position |
| 101 | CALL addr | push(PC+1); PC = addr | Call subroutine |
| 110 | RET | PC = pop() | Return from subroutine |
| 111 | RETI | PC = pop() | Return from interrupt |

**Notes:**
- Shift amount for SHR/SHL/SRA is taken from the lower 4 bits of register B (allowing shifts of 0-15).
- `CALL` pushes the return address (PC+1) onto the stack and jumps to the target.
- `RET` pops the return address from the stack and loads it into PC.
- The stack resides in data memory, with SP providing the address.

## 5. Execution Model

### 5.1 State Machine

The CPU executes each instruction in 3 clock cycles:

```
         +-------+       +--------+       +---------+
  Reset->| FETCH |------>| DECODE |------>| EXECUTE |--+
         +-------+       +--------+       +---------+  |
              ^                                |        |
              +--------------------------------+        |
              |                                         |
              |    +--------+                           |
              +----|  HALT  |<----- (if HALT instr) ----+
                   +--------+
```

| State | Actions |
|-------|---------|
| FETCH | Read instruction at Mem[PC] into IR |
| DECODE | Decode mode/opcode/operand; configure ALU |
| EXECUTE | Perform operation; update registers/memory/PC |
| HALT | CPU stopped; only reset or IRQ can resume |

### 5.2 Interrupt Handling

1. When `IRQ` is asserted and CPU is not already servicing an interrupt:
   - Current PC is pushed onto the stack
   - PC is loaded with the interrupt vector address
   - CPU continues execution at the handler
2. The handler ends with `RETI` to pop the saved PC and resume

## 6. Memory Map

```
Instruction Memory (256 x 16-bit):
  0x00 - 0xFF : Program instructions

Data Memory (256 x 16-bit):
  0x00 - 0x3F : General-purpose data storage
  0x40 - 0xBF : User data area
  0xC0 - 0xFE : Stack area (grows downward from 0xFF)
  0xFF        : Stack pointer initial value (top of stack)
```

## 7. Encoding Examples

### Example 1: ADD
```
Mode=00, Opcode=000, Operand=00000000000
Binary: 00 000 00000000000
Hex:    0x0000
```

### Example 2: LDA 0x40
```
Mode=10, Opcode=000, Operand=00001000000
Binary: 10 000 00001000000
Hex:    0x8040
```

### Example 3: JMP 0x10
```
Mode=10, Opcode=100, Operand=00000010000
Binary: 10 100 00000010000
Hex:    0xA010
```

### Example 4: CALL 0x20
```
Mode=11, Opcode=101, Operand=00000100000
Binary: 11 101 00000100000
Hex:    0xEA20  -> 11 101 00000100000
Hex:    0xDA20
```

## 8. Assembler Directives

The assembler (`tools/assembler.py`) supports:

| Feature | Syntax | Example |
|---------|--------|---------|
| Labels | `name:` | `loop:` |
| Decimal operands | number | `LIC 42` |
| Hex operands | 0xNN | `LDA 0x40` |
| Binary operands | 0bNNN | `LIC 0b1010` |
| Comments | `; text` | `; this is a comment` |
| Label references | label_name | `JMP loop` |
