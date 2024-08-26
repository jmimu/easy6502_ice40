#!/usr/bin/env python
"""
This script calls Ophis 6502 assembler and send machine code to uart
"""

import sys
import subprocess
import serial

if len(sys.argv)!=3:
    print('Usage: python3 asm2uart.py src.asm /dev/ttyUSB0')

name = sys.argv[1]
tty = sys.argv[2]
outname = 'ophis.bin'

print("Assemble "+name+"...")

subprocess.run(["ophis", name], check=True)

print(f"upload binary file {outname} to {tty}...")

ser = serial.Serial(tty, 115200, timeout=0.5)

with open(outname, mode='rb') as file:
    fileContent = file.read()
    ser.write(fileContent)

print("...done!")

