
`include "misc/power_on_reset.v"
`include "misc/uart_jm.v"
`include "misc/strobe2clk.v"
`include "misc/bcd_digit.v"

/*
ss is naturally pulled high
reboot after flash
*/

module top_uart (
    // inputs
    input wire gpio_20, // 12 MHz clk
    input wire serial_rxd,
    input wire spi_cs,

    // outputs
    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire serial_txd

);
wire clk = gpio_20;

//power on reset
wire reset;
power_on_reset por(
  .clk(clk),
  .reset(reset)
);

// slow clock ~4s
reg [26:0] slowclk_cnt;
wire slowclk = slowclk_cnt[24];
always @(posedge clk)
begin
  if (reset) begin
    slowclk_cnt <= 27'b0;
  end else begin
    slowclk_cnt <= slowclk_cnt + 27'b1;
  end
end

// counter
wire [3:0] mydata;
bcd_cnt_digit bcd0(.clk(clk), .reset(reset),
                   .inc(slowclk), .val(mydata), .carry());

// uart tx
wire baud_x1, baud_x4;
wire utx_strobe, utx_ready;
assign utx_strobe = slowclk;
// strobe2clk(reset, mclk, sub_clk, in, out);
uart_clk uclk (.mclk(clk), .reset(reset), .baud_x1(baud_x1), .baud_x4(baud_x4));
uart_tx utx ( .mclk(clk), .reset(reset),
            .baud_x1(baud_x1),
            .serial(serial_txd),
            .ready(utx_ready),
            .data( {4'h3, mydata[3:0]}),
            .data_strobe(utx_strobe) );


// leds
assign led_green = slowclk;
assign led_red = serial_rxd;
assign led_blue = 1'b1;

endmodule
