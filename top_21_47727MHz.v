
`include "misc/power_on_reset.v"

module top_21_47727MHz (
    // inputs
    input wire gpio_20, // 12 MHz clk
   

    // outputs
    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire gpio_18, // i2s lrclk // output ntsc at 21.47727MHz
    output wire gpio_11, // output pal at 26.601712MHz

`ifdef SIM
	input wire clk_hi
`endif
);
wire clk_12 = gpio_20;
wire out_ntsc = gpio_18;
wire out_pal = gpio_11;


`ifndef SIM
wire clk_hi;
// 97.5 MHz
SB_PLL40_CORE #(
.FEEDBACK_PATH("SIMPLE"),
.DIVR(4'b0000),		// DIVR =  0
.DIVF(7'b1000000),	// DIVF = 64
.DIVQ(3'b011),		// DIVQ =  3
.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
) pll (
    .REFERENCECLK(clk_12),
    .PLLOUTCORE(clk_hi),
    .RESETB(1'b1),
    .BYPASS(1'b0)
);
`endif


reg [22:0] clockdivide_counter_ntsc = 23'd0;
reg [22:0] clockdivide_counter_pal = 23'd0;


always @(posedge clk_hi)
begin
    clockdivide_counter_ntsc <= clockdivide_counter_ntsc + 23'd57745;
    clockdivide_counter_pal <= clockdivide_counter_pal + 23'd2235;
end

/*
d=21.47727
for i in range(25):
   print(i, 2**i/(97.5/d))

d=26.601712
for i in range(25):
   print(i, 2**i/(97.5/d))


*/
//97.5/ (2**18/57745) = 21.477270126

//power on reset
wire reset;
power_on_reset por(
  .clk(clk_hi),
  .reset(reset)
);

assign out_ntsc = clockdivide_counter_ntsc[17];
assign out_pal = clockdivide_counter_pal[12];

// leds
assign led_green = out_ntsc;
assign led_red = 1'b1;
assign led_blue = 1'b1;

endmodule
