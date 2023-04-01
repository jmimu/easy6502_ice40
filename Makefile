# Makefile to build UPduino v3.0 top.v  with icestorm toolchain
# Original Makefile is taken from: 
# https://github.com/tomverbeure/upduino/tree/master/blink
# On Linux, copy the included upduinov3.rules to /etc/udev/rules.d/ so that we don't have
# to use sudo to flash the bit file.
# Thanks to thanhtranhd for making changes to thsi makefile.

top.bin: top.asc
	icepack top.asc top.bin

top.asc: top.json upduino.pcf
	nextpnr-ice40 --up5k --package sg48 --json top.json --pcf upduino.pcf --asc top.asc   # run place and route

top.json: top.v
	yosys -q -p "synth_ice40 -json top.json" top.v

.PHONY: flash
flash:
	iceprog -d i:0x0403:0x6014 top.bin

.PHONY: clean
clean:
	$(RM) -f top.json top.asc top.bin
