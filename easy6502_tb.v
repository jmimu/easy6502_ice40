`timescale 1ns/10ps

`include "top_easy6502.v"

module tb ();

	localparam DURATION = 20000000;

	reg clk25, clk12;
	reg serial_rxd;
	wire gpio_32; //VGA colors
	wire gpio_27;
	wire gpio_26;
	wire gpio_25;
	wire gpio_23;

	wire gpio_36;
	wire gpio_43;
	wire gpio_34;
	wire gpio_37;
	wire gpio_31;

	wire gpio_21;
	wire gpio_12;
	wire gpio_28;
	wire gpio_38;
	wire gpio_42;

	wire gpio_46; //vga sync
	wire gpio_2; //vga sync

	initial begin
		clk25 = 1'b0;
		clk12 = 1'b0;
		serial_rxd = 1'b1;

		//uart message: a0 00 c8 4c 02 06 (115200 bauds = 8681 ns)
		// a0
		#100000 serial_rxd = 1'b0; //start bit
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		
		#868 serial_rxd = 1'b1;  //stop
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		// 00
		#868 serial_rxd = 1'b0; //start bit
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;  //stop
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		// c8
		#868 serial_rxd = 1'b0; //start bit
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;  //stop
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		// 4c
		#868 serial_rxd = 1'b0; //start bit
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;  //stop
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		// 02
		#868 serial_rxd = 1'b0; //start bit
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;  //stop
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		// 06
		#868 serial_rxd = 1'b0; //start bit
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b0;
		#868 serial_rxd = 1'b1;  //stop
		#868 serial_rxd = 1'b1;
		#868 serial_rxd = 1'b1;
	end

	always begin
		#20 clk25 = !clk25;
	end
	always begin
		#41 clk12 = !clk12;
	end

	top_easy6502 uut(
		.gpio_20(clk12),
		.serial_rxd(serial_rxd),
		
		.gpio_32(gpio_32), //VGA
		.gpio_27(gpio_27),
		.gpio_26(gpio_26),
		.gpio_25(gpio_25),
		.gpio_23(gpio_23),

		.gpio_36(gpio_36),
		.gpio_43(gpio_43),
		.gpio_34(gpio_34),
		.gpio_37(gpio_37),
		.gpio_31(gpio_31),

		.gpio_21(gpio_21),
		.gpio_12(gpio_12),
		.gpio_28(gpio_28),
		.gpio_38(gpio_38),
		.gpio_42(gpio_42),

		.gpio_46(gpio_46),
		.gpio_2(gpio_2),

		.CLK_25M(clk25)

	);

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb); //0: all levels deep in current module
		#(DURATION)
		$display("Finished!");
		$finish;
	end
endmodule
