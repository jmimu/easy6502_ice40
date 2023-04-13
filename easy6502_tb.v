`timescale 1ns/1ps

`include "top_easy6502.v"

module tb ();

	localparam DURATION = 100000000;

	reg clk25, clk12;
	wire gpio_23; //VGA colors
	wire gpio_25;
	wire gpio_26;
	wire gpio_27;
	wire gpio_32;
	wire gpio_35;
	wire gpio_31;
	wire gpio_37;
	wire gpio_34;
	wire gpio_43;
	wire gpio_36;
	wire gpio_42;
	wire gpio_38;
	wire gpio_28;
	wire gpio_47;
	wire gpio_46; //vga sync
	wire gpio_2; //vga sync

	initial begin
		clk25 = 1'b0;
		clk12 = 1'b0;
	end

	always begin
		#40 clk25 = !clk25;
	end
	always begin
		#83 clk12 = !clk12;
	end

	top_easy6502 uut(
		.gpio_20(clk12),
		
		.gpio_23(gpio_23), //segments
		.gpio_25(gpio_25),
		.gpio_26(gpio_26),
		.gpio_27(gpio_27),
		.gpio_32(gpio_32),
		.gpio_35(gpio_35),
		.gpio_31(gpio_31),
		.gpio_37(gpio_37),
		.gpio_34(gpio_34),
		.gpio_43(gpio_43),
		.gpio_36(gpio_36),
		.gpio_42(gpio_42),
		.gpio_38(gpio_38),
		.gpio_28(gpio_28),
		.gpio_47(gpio_47),
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
