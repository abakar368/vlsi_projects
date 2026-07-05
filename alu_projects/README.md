# Parameterized N-bit ALU in Verilog HDL

A parameterized Arithmetic Logic Unit (ALU) implemented in Verilog HDL supporting arithmetic, logical, and shift operations with status flag generation. The project includes a fully self-checking testbench using both directed and random verification, making it suitable for learning RTL design and verification.

---

## Features

### Arithmetic Operations
- Addition (ADD)
- Subtraction (SUB)

### Logical Operations
- AND
- OR
- XOR

### Shift Operations
- Logical Left Shift
- Logical Right Shift

### Data Transfer
- PASS (Pass input A directly to the output)

---

## Status Flags

The ALU generates the following status flags:

| Flag | Description |
|------|-------------|
| Carry | Carry-out for addition and subtraction |
| Overflow | Signed arithmetic overflow detection |
| Negative | Indicates the result is negative (MSB = 1) |
| Zero | Indicates the result equals zero |

---

## Parameterization

The ALU is parameterized using

```verilog
parameter N = 4;
```

allowing the same design to be synthesized for different datapath widths such as:

- 4-bit
- 8-bit
- 16-bit
- 32-bit
- 64-bit

without modifying the RTL.

---

## Supported Operations

| Opcode | Operation |
|---------|-----------|
|000|ADD|
|001|SUB|
|010|OR|
|011|AND|
|100|XOR|
|101|LEFT SHIFT|
|110|RIGHT SHIFT|
|111|PASS|

---

## Project Structure

```
alu_projects/
│
├── rtl/
│   └── n_bit_alu.v
│
├── tb/
│   └── n_bit_alu_tb.v
│
├── build/
│
├── wave/
│
├── README.md
└── run.bat
```

---

## Verification Methodology

The project uses a professional self-checking verification flow.

### Golden Reference Model

A software model computes the expected outputs independently of the DUT.

### Tasks Used

- `compute_expected()`
- `run_test()`
- `check_results()`

### Directed Testing

Each ALU operation is tested with carefully selected test vectors.

Examples include:

- Addition
- Subtraction
- Logical operations
- Shift operations
- PASS operation

### Random Testing

1000 randomized test cases are executed to improve functional coverage and validate the ALU over a broad range of input combinations.

Any mismatch between the DUT and the golden model is automatically reported.

---

## Simulation

### Icarus Verilog

```bash
iverilog -o build/alu rtl/n_bit_alu.v tb/n_bit_alu_tb.v
vvp build/alu
```

### Generate Waveform

```bash
gtkwave wave/n_bit_alu_wave.vcd
```

### QuestaSim

```tcl
vlog rtl/n_bit_alu.v
vlog tb/n_bit_alu_tb.v
vsim n_bit_alu_tb
run -all
```

---

## Example Output

```
-------------------------------------
Starting ALU Directed Tests
-------------------------------------

-------------------------------------
Starting Random Tests
-------------------------------------

TEST PASSED ✔
```

---

## Learning Objectives

This project demonstrates:

- Combinational RTL Design
- Parameterized Hardware Design
- Multiplexer-Based ALU Architecture
- Status Flag Generation
- Overflow Detection
- Self-Checking Testbench Design
- Directed Verification
- Random Verification
- Professional RTL Project Organization

---

## Future Improvements

Potential extensions include:

- Multiplication
- Division
- Modulo
- Arithmetic Shift
- Rotate Left/Right
- Comparison Operations
- MIN/MAX Operations
- Absolute Value
- Signed/Unsigned Operation Modes
- Saturation Arithmetic