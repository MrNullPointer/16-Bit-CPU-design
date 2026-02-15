# 16-Bit CPU Design

A complete 16-bit microprocessor designed in VHDL, featuring a multi-cycle architecture with a 32-instruction ISA, subroutine support, interrupt handling, and a Python assembler.

## Architecture Overview

```
                    +------------------+
                    |  Instruction     |
                    |  Memory (256x16) |
                    +--------+---------+
                             |
                    +--------v---------+
   +----------+    |  Instruction      |    +----------+
   | Program  |--->|  Register (IR)    |    |  Stack   |
   | Counter  |    +--------+---------+    | Pointer  |
   +----------+             |              +----------+
        ^          +--------v---------+         |
        |          |   Controller     |         |
        +----------+   (FSM)         +---------+
        |          +--------+---------+
        |                   |
        |          +--------v---------+
  +-----+----+    |    ALU           |    +-----------+
  | MUX      |<---| (Arithmetic,    |--->| Flags     |
  | (PC Src) |    |  Logic, Shift)  |    | Z,EQ,GT,  |
  +----------+    +--------+---------+    | OV,CY     |
                           |              +-----------+
                  +--------v---------+
                  | Register File    |
                  | A, B, C (16-bit) |
                  +--------+---------+
                           |
                  +--------v---------+
                  | Data Memory      |
                  | (256x16)         |
                  +------------------+
```

### Key Specifications

| Feature | Specification |
|---------|--------------|
| Word Size | 16 bits |
| Address Space | 8-bit (256 locations each for instruction & data memory) |
| Registers | A (accumulator), B (operand), C (result) |
| Special Registers | PC (program counter), IR (instruction register), SP (stack pointer) |
| ALU Operations | 8 arithmetic + 8 logic + 5 shift/rotate |
| Branch Types | JMP, JE, JGT, JZ (unconditional + 3 conditional) |
| Subroutines | CALL/RET with hardware stack |
| Interrupts | Single IRQ line with RETI |
| Clock | Multi-cycle: 3 cycles per instruction (FETCH/DECODE/EXECUTE) |

## Directory Structure

```
16-Bit-CPU-design/
├── src/                          # VHDL source files
│   ├── alu.vhd                   # Arithmetic Logic Unit
│   ├── controller.vhd            # Control Unit (FSM)
│   ├── cpu_top.vhd               # Top-level CPU entity
│   ├── data_memory.vhd           # Data RAM (256x16)
│   ├── instruction_memory.vhd    # Instruction ROM (256x16)
│   ├── instruction_register.vhd  # Instruction Register & decoder
│   ├── mux2to1.vhd               # 2-to-1 multiplexer
│   ├── program_counter.vhd       # Program Counter
│   ├── register_file.vhd         # Register File (A, B, C)
│   └── stack_pointer.vhd         # Stack Pointer
├── tb/                           # Testbenches
│   ├── alu_tb.vhd                # ALU testbench
│   ├── controller_tb.vhd         # Controller testbench
│   ├── cpu_top_tb.vhd            # Full CPU integration test
│   ├── data_memory_tb.vhd        # Memory testbench
│   ├── program_counter_tb.vhd    # PC testbench
│   ├── register_file_tb.vhd      # Register file testbench
│   └── stack_pointer_tb.vhd      # Stack pointer testbench
├── tools/                        # Development tools
│   └── assembler.py              # Python assembler
├── programs/                     # Example assembly programs
│   ├── add_two_numbers.asm       # Basic addition
│   ├── fibonacci.asm             # Fibonacci sequence
│   ├── logic_ops.asm             # Logic operations demo
│   ├── branch_test.asm           # Branch instruction test
│   └── subroutine_test.asm       # CALL/RET test
├── docs/                         # Documentation
│   └── isa_specification.md      # ISA reference
└── original/                     # Original project files
```

## Instruction Set Architecture

### Instruction Format

```
15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0
[Mode ][ Opcode ][ --------- Operand (11 bits) ------- ]
```

### Instruction Reference

| Mode | Opcode | Mnemonic | Operation | Description |
|------|--------|----------|-----------|-------------|
| 00 | 000 | `ADD` | C = A + B | Add |
| 00 | 001 | `SUB` | C = A - B | Subtract |
| 00 | 010 | `MUL` | C = A * B | Multiply (lower 16 bits) |
| 00 | 011 | `INC` | C = A + 1 | Increment A |
| 00 | 100 | `DEC` | C = A - 1 | Decrement A |
| 00 | 101 | `CMP` | flags = A - B | Compare (flags only) |
| 00 | 110 | `NOP` | — | No operation |
| 00 | 111 | `HALT` | — | Stop execution |
| 01 | 000 | `AND` | C = A & B | Bitwise AND |
| 01 | 001 | `OR` | C = A \| B | Bitwise OR |
| 01 | 010 | `NAND` | C = ~(A & B) | Bitwise NAND |
| 01 | 011 | `NOR` | C = ~(A \| B) | Bitwise NOR |
| 01 | 100 | `NOTA` | C = ~A | Bitwise NOT of A |
| 01 | 101 | `NOTB` | C = ~B | Bitwise NOT of B |
| 01 | 110 | `XOR` | C = A ^ B | Bitwise XOR |
| 01 | 111 | `XNOR` | C = ~(A ^ B) | Bitwise XNOR |
| 10 | 000 | `LDA addr` | A = Mem[addr] | Load A from memory |
| 10 | 001 | `LDB addr` | B = Mem[addr] | Load B from memory |
| 10 | 010 | `STC addr` | Mem[addr] = C | Store C to memory |
| 10 | 011 | `LIC imm` | C = imm | Load immediate to C |
| 10 | 100 | `JMP addr` | PC = addr | Unconditional jump |
| 10 | 101 | `JE addr` | if EQ: PC = addr | Jump if equal |
| 10 | 110 | `JGT addr` | if GT: PC = addr | Jump if greater than |
| 10 | 111 | `JZ addr` | if ZERO: PC = addr | Jump if zero |
| 11 | 000 | `SHR imm` | C = A >> imm | Logical shift right |
| 11 | 001 | `SHL imm` | C = A << imm | Logical shift left |
| 11 | 010 | `SRA imm` | C = A >>> imm | Arithmetic shift right |
| 11 | 011 | `ROL` | C = rotate_left(A) | Rotate left by 1 |
| 11 | 100 | `ROR` | C = rotate_right(A) | Rotate right by 1 |
| 11 | 101 | `CALL addr` | push PC+1; PC = addr | Call subroutine |
| 11 | 110 | `RET` | PC = pop() | Return from subroutine |
| 11 | 111 | `RETI` | PC = pop() | Return from interrupt |

### Status Flags

| Flag | Description |
|------|-------------|
| Z (Zero) | Set when ALU result is 0x0000 |
| EQ (Equal) | Set when A == B |
| GT (Greater) | Set when A > B (unsigned) |
| OV (Overflow) | Set on signed arithmetic overflow |
| CY (Carry) | Set on unsigned carry/borrow |

## Using the Assembler

```bash
# Assemble to hex format
python3 tools/assembler.py programs/add_two_numbers.asm

# Assemble to VHDL memory initialization
python3 tools/assembler.py programs/fibonacci.asm -f vhdl

# Assemble to output file
python3 tools/assembler.py programs/branch_test.asm -o output.hex

# Show label addresses
python3 tools/assembler.py programs/subroutine_test.asm -l
```

### Assembly Syntax

```asm
; Comments start with semicolon
label:              ; Labels end with colon
    LDA  0x40       ; Load from hex address
    LDB  64         ; Load from decimal address
    ADD             ; No operand needed
    JMP  label      ; Jump to label
    HALT            ; Stop
```

## Simulation

### Using ModelSim

```bash
# Compile all source files
vcom src/alu.vhd
vcom src/register_file.vhd
vcom src/program_counter.vhd
vcom src/instruction_register.vhd
vcom src/instruction_memory.vhd
vcom src/data_memory.vhd
vcom src/stack_pointer.vhd
vcom src/mux2to1.vhd
vcom src/controller.vhd
vcom src/cpu_top.vhd

# Compile and run testbenches
vcom tb/alu_tb.vhd
vsim -run -all alu_tb

vcom tb/cpu_top_tb.vhd
vsim -run -all cpu_top_tb
```

### Using GHDL (open-source)

```bash
# Analyze
ghdl -a src/*.vhd
ghdl -a tb/alu_tb.vhd

# Elaborate and run
ghdl -e alu_tb
ghdl -r alu_tb --stop-time=1000ns --wave=alu_tb.ghw
```

## Design Decisions

- **Multi-cycle design**: Simple 3-cycle-per-instruction FSM avoids pipeline hazard complexity while remaining clear for educational purposes.
- **Separate instruction/data memory**: Harvard-style separation simplifies the controller and avoids structural hazards.
- **Stack grows downward**: SP starts at 0xFF and decrements on PUSH, matching conventional architectures.
- **Flag latching**: ALU flags are latched in registers so they persist for branch decisions across clock cycles.
- **11-bit operand field**: Allows direct addressing of up to 2048 memory locations and immediate values up to 2047.
