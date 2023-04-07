`include "vga_pattern.v"
`include "i2s.v"

module rgb_blink (
    // inputs
    input wire gpio_20, // 12 MHz clk
    // outputs
    output wire gpio_23,
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
    output wire gpio_46,
    output wire gpio_2,

    // i2s
    output wire gpio_9,
    output wire gpio_11,
    output wire gpio_18
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
    .rgb( { gpio_36, gpio_42, gpio_38, gpio_28, gpio_47, 
            gpio_35, gpio_31, gpio_37, gpio_34, gpio_43,
            gpio_23, gpio_25, gpio_26, gpio_27, gpio_32 } ));

// sound
reg [5:0] subClkI2S = 6'b0;
always @(posedge CLK_25M)
begin
    subClkI2S <= subClkI2S + 1'b1;
end
wire i2s_clk = subClkI2S[5];
assign gpio_11 = i2s_clk;
wire [15:0] snd_data;
//sound_gen_sqr snd(1'b0, PIN_22, 16'h0200, 14'h0200, snd_data);
sound_gen snd(1'b0, i2s_clk, 4'b1110, 12'h0060, snd_data);
i2s i2s1(1'b0, i2s_clk, snd_data, gpio_9, gpio_18);

endmodule