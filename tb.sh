#!/bin/sh
set -e

iverilog -DSIMUL -I verilog-65C02-fsm easy6502_tb.v
./a.out
#gtkwave tb.vcd
