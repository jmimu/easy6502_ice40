
`include "misc/power_on_reset.v"
//`include "misc/uart_jm.v"
`include "misc/uart_buffer.v"
`include "misc/strobe2clk.v"
`include "misc/bcd_digit.v"
`include "misc/debounce.v"

/*
ss is naturally pulled high
reboot after flash
*/

module top_uart (
    // inputs
    input wire gpio_20, // 12 MHz clk
    input wire gpio_21, // pps
    input wire serial_rxd,
    input wire spi_cs,

    // outputs
    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire serial_txd

);
wire clk = gpio_20;
wire pps = gpio_21;

wire pps_posedge;
reg pps_posedge_; // 1 clock slower to send data before resetting
debounce debouce_pps( .clk(clk),
                      .in(pps),
                      .out(),
                      .rising(pps_posedge),
                      .falling()
);
always @(posedge clk) begin
    pps_posedge_ <= pps_posedge;
end


//power on reset
wire reset;
power_on_reset por(
  .clk(clk),
  .reset(reset)
);

/*// slow clock ~2s
reg [26:0] slowclk_cnt;
`ifdef SIM
    wire slowclk = slowclk_cnt[15];
`else
    wire slowclk = slowclk_cnt[23];
`endif
always @(posedge clk)
begin
  if (reset) begin
    slowclk_cnt <= 27'b0;
  end else begin
    slowclk_cnt <= slowclk_cnt + 27'b1;
  end
end
*/
// counter
wire [31:0] mydata;

wire [7:0] carry;
bcd_clk_cnt_digit bcd0(.clk(clk), .reset(reset | pps_posedge_),
                       .val(mydata[ 0 +:4]), .carry(carry[0])
);
genvar i;
generate
    for (i=1; i<8; i=i+1) begin : gen_bcd
      bcd_cnt_digit bcd (.clk(clk), .reset(reset | pps_posedge_),
                        .inc(carry[i-1]), .val(mydata[ (i*4) +:4]), .carry(carry[i])
      );
    end 
endgenerate

wire baud_x1;
wire [7:0] curr_char;
wire utx_strobe;
send_uint32_bcd_tx_buf send_bcd ( .mclk(clk), .reset(reset),
            .baud_x1(baud_x1),
            .data( mydata),
            .data_strobe(pps_posedge),
            .curr_char(curr_char),
            .send_strobe(utx_strobe)
);

// uart tx
//wire utx_strobe;
//assign utx_strobe = slowclk_cnt[14] & slowclk_cnt[17] & slowclk_cnt[24];
uart_buffer utx_buf(.clk(clk), .reset(reset),
                .serial_tx(serial_txd), .baud_x1(baud_x1),
                .data( curr_char ), .data_strobe(utx_strobe)
);

/*wire baud_x1, baud_x4;
wire utx_strobe, utx_ready;
assign utx_strobe = slowclk;
uart_clk uclk (.mclk(clk), .reset(reset), .baud_x1(baud_x1), .baud_x4(baud_x4));

uart_tx_uint32_bcd utx ( .mclk(clk), .reset(reset),
            .baud_x1(baud_x1),
            .serial(serial_txd),
            .ready(utx_ready),
            .data( mydata),
            .data_strobe(utx_strobe) );
*/

// leds
assign led_green = pps;
assign led_red = serial_rxd;
assign led_blue = 1'b1;

endmodule
