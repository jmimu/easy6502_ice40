`include "misc/uart_jm.v"
`include "misc/val2freq.v"

/*
Stop CPU when recieving data, update prog bytes and restart CPU after end of data
*/

module uart_prog_input(clk_ram, reset, serial_rxd, waddr, wdata, write_en, ask_for_ram, end_of_data, debug_pin);

input clk_ram;
input reset;
input serial_rxd;
output [15:0] waddr;
output reg [7:0] wdata;
output reg write_en;
output reg ask_for_ram; //will suspend cpu
output reg end_of_data; //will reboot cpu (7 cycles, ask_for_ram will be low)
output debug_pin;

wire baud_x1;
wire baud_x4;

uart_clk uart_clk1( 
    .mclk(clk_ram),
    .reset(reset),
    .baud_x1(baud_x1),
    .baud_x4(baud_x4)
);

wire [7:0] rx_data;
wire rx_data_strobe;

uart_rx uart_rx1(
  .mclk(clk_ram),
  .reset(reset),
  .baud_x4(baud_x4),
  .serial(serial_rxd),
  .data(rx_data),
  .data_strobe(rx_data_strobe)
);

val2freq val2freq1(
  .clk25M(clk_ram),
  .reset(reset),
  .val(rx_data),
  .freq_out(debug_pin)
);

reg [15:0] wait_for_next_byte; // when 8, stop ask_for_ram, reset cpu

reg [10:0] clear_byte_addr; // clear ram 600 to 0 when waiting

reg [15:0] prog_byte_addr; // where to write the new byte of program
assign waddr = rx_data_strobe_1 ? prog_byte_addr : clear_byte_addr;

reg rx_data_strobe_1;

always @(posedge clk_ram)
  begin
    if (reset) begin
      wait_for_next_byte <= 0;
      prog_byte_addr <= 16'h05ff;
      wdata <= 8'b0;
      write_en  <= 1'b0;
      ask_for_ram <= 1'b0;
      end_of_data <= 1'b0;
      clear_byte_addr <= 11'h000; // nothing to clear
      rx_data_strobe_1 <= 1'b0;
    end else begin
      rx_data_strobe_1 <= rx_data_strobe;
      if (serial_rxd == 1'b0) begin
        write_en  <= 1'b1;
        wdata <= 8'b0;
        ask_for_ram <= 1'b1; //ask ram on start bit
        if (ask_for_ram == 1'b0)
            clear_byte_addr <= 11'h600-5; // ready to clear screen and pages 1-2
      end else  if (rx_data_strobe) begin
        ask_for_ram <= 1'b1;
        end_of_data <= 1'b0;
        wait_for_next_byte <= -1;
        prog_byte_addr <= prog_byte_addr + 1;
        wdata <= rx_data; //write this byte in ram
        write_en  <= 1'b1;
      end else begin
        if (clear_byte_addr != 11'h000) begin
            clear_byte_addr <= clear_byte_addr - 1;
            wdata <= 8'b0;
        end
        if (wait_for_next_byte != 0) begin
          wait_for_next_byte <= wait_for_next_byte - 1;
          if (wait_for_next_byte == 15'd160) begin //transmission is stopped, reset cpu => has to reset when cpu is not halted by screen, and should stop reset when not halted by screen too. TODO: improve
            ask_for_ram <= 1'b0;
            end_of_data <= 1'b1;
          end else if (wait_for_next_byte == 15'd1) begin //end of reset cpu
            end_of_data <= 1'b0;
            prog_byte_addr <= 16'h05ff; //restart writing address
            write_en  <= 1'b0;
          end
        end
        
      end
    end
  end


endmodule
