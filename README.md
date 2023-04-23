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

simplest :
a9 01 8d 00 02



LDA #$03
STA $0221
LDA #$05
STA $0222
LDA #$07
STA $0223
JMP $0600
00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11
a9 03 8d 21 02 a9 05 8d 22 02 a9 07 8d 23 02 4c 00 06
draws 3 pixels 3, 5, 8 and loops

-------------------

LDA #$00
LDX #$00
LDY #$00

loop:
ADC #$01
STA $0222
slow1:
slow2:
INY
CPY #$00
BNE slow2
INY ; dephase
INY
INY
INX
CPX #$00
BNE slow1
INX  ; dephase
INX
JMP loop

0600: a9 00 a2 00 a0 00 69 01 8d 22 02 c8 c0 00 d0 fb 
0610: c8 c8 c8 e8 e0 00 d0 f3 e8 e8 4c 06 06

Address  Hexdump   Dissassembly
-------------------------------
$0600    a9 00     LDA #$00
$0602    a2 00     LDX #$00
$0604    a0 00     LDY #$00
$0606    69 01     ADC #$01
$0608    8d 22 02  STA $0222
$060b    c8        INY 
$060c    c0 00     CPY #$00
$060e    d0 fb     BNE $060b
$0610    c8        INY 
$0611    c8        INY 
$0612    c8        INY 
$0613    e8        INX 
$0614    e0 00     CPX #$00
$0616    d0 f3     BNE $060b
$0618    e8        INX 
$0619    e8        INX 
$061a    4c 06 06  JMP $0606
