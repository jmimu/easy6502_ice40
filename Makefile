TOP = top_easy6502
#TOP = top_uart

top.bin: top.asc
	icepack top.asc top.bin

top.asc: top.json upduino.pcf
	nextpnr-ice40 --up5k --package sg48 --json top.json --pcf upduino.pcf --asc top.asc   # run place and route

.PHONY: top.json
top.json:
	yosys -e ".*" -q -p "synth_ice40 -json top.json" ${TOP}.v -r ${TOP}

.PHONY: flash
flash: top.bin
	iceprog -d i:0x0403:0x6014 top.bin

.PHONY: clean
clean:
	$(RM) -f top.json top.asc top.bin
