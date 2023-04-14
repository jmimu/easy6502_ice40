sudo cp upduinov3.rules /etc/udev/rules.d/


upduino to pico pi demo
=======================

VGA base from 8bitworkshop.com
https://upduino.readthedocs.io


Easy 6502
=========
https://skilldrick.github.io/easy6502/

6502 CPU from https://github.com/Arlet/verilog-6502.git

Easy 6502 memory :
$0000 - $00ff  Zero page
$0100 - $01ff  Stack
$0200 - $05ff  Display (32x32px with 8 bit palette)
$0600 - $06ff  Program ROM

VGA 13h default palette:
https://commons.wikimedia.org/wiki/User:Psychonaut/ipalette.sh



Program
=======

LDA #$01
STA $0200
LDA #$05
STA $0201
LDA #$08
STA $0202
JMP $0600

a9 01 8d 00 02 a9 05 8d 01 02 a9 08 8d 02 02 4c 00 06

draws 3 pixels 1, 5, 8 and loops
