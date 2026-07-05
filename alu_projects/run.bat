@echo off

if not exist build mkdir build
if not exist wave mkdir wave

iverilog -o build\n_bit_alu_sim.vvp ^
rt1\n_bit_alu.v ^
tb\n_bit_alu_tb.v

if %errorlevel% neq 0 exit /b %errorlevel%

vvp build\n_bit_alu_sim.vvp

gtkwave wave\n_bit_alu_wave.vcd