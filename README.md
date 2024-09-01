upduino to pico pi demo
=======================


Initial setup
=============
```
sudo cp upduinov3.rules /etc/udev/rules.d/
```

Dependancies
------------

Get the 6502 CPU:

    git clone https://github.com/Arlet/verilog-6502.git

Get Ophis 6502 assembler:

    pip3 install ophis-asm
    
Get pyserial:

    pip3 install pyserial


VGA base from 8bitworkshop.com
https://upduino.readthedocs.io


Easy 6502 arch
==============

https://skilldrick.github.io/easy6502/

Easy 6502 memory :
```
$0000 - $00ff  Zero page
$0100 - $01ff  Stack
$0200 - $05ff  Display (32x32px with 8 bit palette)
$0600 - $06ff  Program ROM
```

VGA 13h default palette:
https://commons.wikimedia.org/wiki/User:Psychonaut/ipalette.sh

Internals of BRK/IRQ/NMI/RESET on a MOS 6502 https://www.pagetable.com/?p=410


Startup
-------

```
SEI ;disable interrupts (set interrupt disable flag)
CLD ;turn decimal mode off
LDX #$FF
TXS ;transfer X to stack pointer
CLI ;clear interrupt disable
JMP $0600
```

```
78 d8 a2 ff 9a 58 4c 00 06
```

V-sync interrupt
----------------

```
.alias frame $fd

PHP ; push flags
PHA ; push A
LDA frame
INC frame
LDA frame
PLA ; pull A
PLP ; pull flags
RTI ; return from interrupt
```

```
08 48 a5 fd e6 fd a5 fd 68 28 40
```


Automatic Assemble & Upload
===========================

    python asm2uart.py examples/inx.asm /dev/ttyUSB0


Upload a program
================

Send binary dump on serial at 115200 bauds.
Upduino has to be unplugged/replugged after bitstream update for serial port to be accessible.
Blue led blinks with a frequency corresponding to the last byte received.


Assemble
========

Using Ophis 6502 assembler (https://michaelcmartin.github.io/Ophis/).

Source example:

    .org  $0600
    .outfile "out.prg"

	    ldx #0
    loop:
	    inx
	    jmp loop


