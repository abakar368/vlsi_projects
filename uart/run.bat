@echo off
REM run.bat — compile, run, and open waveforms

if not exist sim mkdir sim

echo === Compiling ===
iverilog -g2012 -Wall -o sim\uart_sim rtl\uart_tx.sv rtl\uart_rx.sv tb\uart_tb.sv

echo === Running ===
vvp sim\uart_sim

echo === Opening waveforms ===
start gtkwave uart.vcd