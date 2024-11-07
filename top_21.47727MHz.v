
`include "misc/power_on_reset.v"

module top_21_47727MHz (
    // inputs
    input wire gpio_20, // 12 MHz clk
   

    // outputs
    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire gpio_26, // output at 27.47727MHz

`ifdef SIM
	input wire clk_96
`endif
);
wire clk_12 = gpio_20;
wire out = gpio_26;

`ifndef SIM
wire clk_96;
// 96 MHz
SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),
    .DIVR(4'b0000),
    .DIVF(7'b0101111),
    .DIVQ(3'b011),
    .FILTER_RANGE(3'b001)
) pll (
    .REFERENCECLK(clk_12),
    .PLLOUTCORE(clk_96),
    .RESETB(1'b1),
    .BYPASS(1'b0)
);
`endif

reg [19:0] clockdivide_counter = 20'd0;
always @(posedge clk_96)
begin
    clockdivide_counter <= clockdivide_counter + 20'd234589;
end

// 96*(234589/2^20) = 21.47726440429688

//power on reset
wire reset;
power_on_reset por(
  .clk(clk_96),
  .reset(reset)
);

assign out = clockdivide_counter[19];

// leds
assign led_green = out;
assign led_red = 1'b1;
assign led_blue = 1'b1;

endmodule
