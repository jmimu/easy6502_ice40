`include "VGA/vga_pattern.v"
`include "i2s.v"
`include "misc/rams.v"

module rgb_blink (
    // inputs
    input wire gpio_20, // 12 MHz clk
    // outputs
    output wire gpio_23, //VGA colors
    output wire gpio_25,
    output wire gpio_26,
    output wire gpio_27,
    output wire gpio_32,
    output wire gpio_35,
    output wire gpio_31,
    output wire gpio_37,
    output wire gpio_34,
    output wire gpio_43,
    output wire gpio_36,
    output wire gpio_42,
    output wire gpio_38,
    output wire gpio_28,
    output wire gpio_47,
    output wire gpio_46, //vga sync
    output wire gpio_2, //vga sync


);

wire CLK_12M = gpio_20;
wire CLK_25M;
// 25 MHz
SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),
    .DIVR(4'b0000),
    .DIVF(7'b1000010),
    .DIVQ(3'b101),
    .FILTER_RANGE(3'b001)
) pll (
    .REFERENCECLK(CLK_12M),
    .PLLOUTCORE(CLK_25M),
    .RESETB(1'b1),
    .BYPASS(1'b0)
);

// display
vga_pattern vga_pat1(
    .clk(CLK_25M),
    .reset(1'b0),
    .hsync(gpio_2),
    .vsync(gpio_46),
    .rgb( { gpio_32, gpio_27, gpio_26, gpio_25, gpio_23,
            gpio_43, gpio_34, gpio_37, gpio_31, gpio_35,
            gpio_47, gpio_28, gpio_38, gpio_42, gpio_36 } ));


endmodule
