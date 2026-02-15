#!/usr/bin/env python3
"""
Assembler for the 16-Bit CPU ISA.

Translates assembly mnemonics into 16-bit machine code (binary/hex).

Instruction Format (16 bits):
    [15:14] Mode    - 2-bit operation category
    [13:11] Opcode  - 3-bit operation code within mode
    [10:0]  Operand - 11-bit immediate/address (0-2047)

Usage:
    python3 assembler.py input.asm              # Output hex to stdout
    python3 assembler.py input.asm -o out.hex   # Output to file
    python3 assembler.py input.asm -f vhdl      # Output as VHDL memory init
    python3 assembler.py input.asm -f bin       # Output binary
"""

import sys
import argparse
import re

# ============================================================================
# Instruction Set Definition
# ============================================================================
# Format: MNEMONIC -> (mode, opcode)
INSTRUCTIONS = {
    # Mode 00: Arithmetic
    "ADD":  (0b00, 0b000),
    "SUB":  (0b00, 0b001),
    "MUL":  (0b00, 0b010),
    "INC":  (0b00, 0b011),
    "DEC":  (0b00, 0b100),
    "CMP":  (0b00, 0b101),
    "NOP":  (0b00, 0b110),
    "HALT": (0b00, 0b111),

    # Mode 01: Logic
    "AND":  (0b01, 0b000),
    "OR":   (0b01, 0b001),
    "NAND": (0b01, 0b010),
    "NOR":  (0b01, 0b011),
    "NOTA": (0b01, 0b100),
    "NOTB": (0b01, 0b101),
    "XOR":  (0b01, 0b110),
    "XNOR": (0b01, 0b111),

    # Mode 10: Memory / Immediate / Branch
    "LDA":  (0b10, 0b000),
    "LDB":  (0b10, 0b001),
    "STC":  (0b10, 0b010),
    "LIC":  (0b10, 0b011),
    "JMP":  (0b10, 0b100),
    "JE":   (0b10, 0b101),
    "JGT":  (0b10, 0b110),
    "JZ":   (0b10, 0b111),

    # Mode 11: Shift / Subroutine
    "SHR":  (0b11, 0b000),
    "SHL":  (0b11, 0b001),
    "SRA":  (0b11, 0b010),
    "ROL":  (0b11, 0b011),
    "ROR":  (0b11, 0b100),
    "CALL": (0b11, 0b101),
    "RET":  (0b11, 0b110),
    "RETI": (0b11, 0b111),
}

# Instructions that don't take an operand
NO_OPERAND = {"ADD", "SUB", "MUL", "INC", "DEC", "CMP", "NOP", "HALT",
              "AND", "OR", "NAND", "NOR", "NOTA", "NOTB", "XOR", "XNOR",
              "ROL", "ROR", "RET", "RETI"}


class AssemblerError(Exception):
    def __init__(self, line_num, message):
        super().__init__(f"Line {line_num}: {message}")
        self.line_num = line_num


def parse_operand(operand_str, labels, line_num):
    """Parse an operand string into an integer value."""
    operand_str = operand_str.strip()

    # Check if it's a label reference
    if operand_str in labels:
        return labels[operand_str]

    # Try parsing as a number
    try:
        if operand_str.startswith("0x") or operand_str.startswith("0X"):
            return int(operand_str, 16)
        elif operand_str.startswith("0b") or operand_str.startswith("0B"):
            return int(operand_str, 2)
        else:
            return int(operand_str)
    except ValueError:
        raise AssemblerError(line_num, f"Unknown operand: '{operand_str}'")


def assemble(source_lines):
    """
    Two-pass assembler.
    Pass 1: Collect labels and their addresses.
    Pass 2: Generate machine code.
    """
    # ============================
    # Pass 1: Collect labels
    # ============================
    labels = {}
    address = 0
    cleaned_lines = []

    for line_num, raw_line in enumerate(source_lines, 1):
        # Strip comments (everything after ';')
        line = raw_line.split(';')[0].strip()
        if not line:
            continue

        # Check for label (ends with ':')
        if ':' in line:
            parts = line.split(':', 1)
            label = parts[0].strip()
            if label in labels:
                raise AssemblerError(line_num, f"Duplicate label: '{label}'")
            labels[label] = address
            # Rest of line after label
            rest = parts[1].strip()
            if rest:
                cleaned_lines.append((line_num, rest))
                address += 1
            continue

        cleaned_lines.append((line_num, line))
        address += 1

    # ============================
    # Pass 2: Generate machine code
    # ============================
    machine_code = []

    for line_num, line in cleaned_lines:
        parts = line.split(None, 1)
        mnemonic = parts[0].upper()

        if mnemonic not in INSTRUCTIONS:
            raise AssemblerError(line_num, f"Unknown instruction: '{mnemonic}'")

        mode, opcode = INSTRUCTIONS[mnemonic]
        operand = 0

        if mnemonic in NO_OPERAND:
            if len(parts) > 1 and parts[1].strip():
                raise AssemblerError(line_num,
                    f"'{mnemonic}' does not take an operand")
        else:
            if len(parts) < 2:
                raise AssemblerError(line_num,
                    f"'{mnemonic}' requires an operand")
            operand = parse_operand(parts[1], labels, line_num)

        # Validate operand range (11 bits: 0 to 2047)
        if operand < 0 or operand > 2047:
            raise AssemblerError(line_num,
                f"Operand {operand} out of range (0-2047)")

        # Encode instruction
        instruction = (mode << 14) | (opcode << 11) | operand
        machine_code.append((line_num, line, instruction))

    return machine_code, labels


def format_hex(machine_code):
    """Format as hex listing."""
    lines = []
    lines.append("-- Address | Hex    | Binary             | Source")
    lines.append("-- " + "-" * 60)
    for addr, (line_num, source, instr) in enumerate(machine_code):
        hex_str = f"{instr:04X}"
        bin_str = f"{instr:016b}"
        lines.append(f"-- 0x{addr:04X} | 0x{hex_str} | {bin_str} | {source}")
    lines.append("")
    for addr, (_, _, instr) in enumerate(machine_code):
        lines.append(f"{instr:04X}")
    return "\n".join(lines)


def format_vhdl(machine_code):
    """Format as VHDL memory initialization."""
    lines = []
    lines.append("-- VHDL Memory Initialization")
    lines.append("-- Copy this into instruction_memory.vhd reset block")
    lines.append("")
    for addr, (line_num, source, instr) in enumerate(machine_code):
        lines.append(f'mem({addr}) <= x"{instr:04X}";  -- {source}')
    return "\n".join(lines)


def format_binary(machine_code):
    """Format as raw binary strings."""
    lines = []
    for _, (_, _, instr) in enumerate(machine_code):
        lines.append(f"{instr:016b}")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Assembler for the 16-Bit CPU ISA")
    parser.add_argument("input", help="Input assembly file (.asm)")
    parser.add_argument("-o", "--output", help="Output file (default: stdout)")
    parser.add_argument("-f", "--format", choices=["hex", "vhdl", "bin"],
                        default="hex", help="Output format (default: hex)")
    parser.add_argument("-l", "--labels", action="store_true",
                        help="Print label table")
    args = parser.parse_args()

    # Read input
    try:
        with open(args.input, 'r') as f:
            source_lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    # Assemble
    try:
        machine_code, labels = assemble(source_lines)
    except AssemblerError as e:
        print(f"Assembly error: {e}", file=sys.stderr)
        sys.exit(1)

    # Format output
    if args.format == "hex":
        output = format_hex(machine_code)
    elif args.format == "vhdl":
        output = format_vhdl(machine_code)
    elif args.format == "bin":
        output = format_binary(machine_code)

    # Print labels if requested
    if args.labels:
        print("\nLabel Table:", file=sys.stderr)
        for label, addr in sorted(labels.items(), key=lambda x: x[1]):
            print(f"  {label:20s} = 0x{addr:04X} ({addr})", file=sys.stderr)

    # Output
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output + "\n")
        print(f"Assembled {len(machine_code)} instructions to {args.output}",
              file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
