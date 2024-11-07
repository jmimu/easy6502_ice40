#!/bin/sh
set -e

iverilog -DSIM -I verilog-65C02-fsm top_21.47727MHz_tb.v
./a.out
#gtkwave tb.vcd
