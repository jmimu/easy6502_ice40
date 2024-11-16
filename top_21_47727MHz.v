
`include "misc/power_on_reset.v"

module top_21_47727MHz (
    // inputs
    input wire gpio_20, // 12 MHz clk
   

    // outputs
    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire gpio_18, // i2s lrclk // output at 27.47727MHz

`ifdef SIM
	input wire clk_hi
`endif
);
wire clk_12 = gpio_20;
wire out = gpio_18;


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


reg [22:0] clockdivide_counter = 23'd0;


always @(posedge clk_hi)
begin
    clockdivide_counter <= clockdivide_counter + 23'd57745;
end

/*
d=21.47727
for i in range(25):
   print(2**i/(96/d))
*/
//97.5/ (2**18/57745) = 21.477270126

//power on reset
wire reset;
power_on_reset por(
  .clk(clk_hi),
  .reset(reset)
);

assign out = clockdivide_counter[17];

// leds
assign led_green = out;
assign led_red = 1'b1;
assign led_blue = 1'b1;

endmodule
