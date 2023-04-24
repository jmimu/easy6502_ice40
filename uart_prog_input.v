`include "misc/uart_jm.v"

/*
Stop CPU when recieving data, update prog bytes and restart CPU after end of data
*/

module uart_prog_input(clk_ram, reset, serial_rxd, waddr, wdata, write_en, ask_for_ram, end_of_data);

input clk_ram;
input reset;
input serial_rxd;
output reg [15:0] waddr;
output reg [7:0] wdata;
output reg write_en;
output reg ask_for_ram; //will suspend cpu
output reg end_of_data; //will reboot cpu (7 cycles, ask_for_ram will be low)

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

reg [15:0] wait_for_next_byte; // when 8, stop ask_for_ram, reset cpu

always @(posedge clk_ram)
  begin
    if (reset) begin
      wait_for_next_byte <= 0;
      waddr <= 16'h05ff;
      wdata <= 8'b0;
      write_en  <= 1'b0;
      ask_for_ram <= 1'b0;
      end_of_data <= 1'b0;
    end else begin
      if (serial_rxd == 1'b0) begin
        ask_for_ram <= 1'b1; //ask ram on start bit
      end else  if (rx_data_strobe) begin
        ask_for_ram <= 1'b1;
        end_of_data <= 1'b0;
        wait_for_next_byte <= -1;
        waddr <= waddr + 1; 
        wdata <= rx_data; //write this byte in ram
        write_en  <= 1'b1;
      end else begin
        if (wait_for_next_byte != 0) begin
          wait_for_next_byte <= wait_for_next_byte - 1;
          write_en  <= 1'b0;
          if (wait_for_next_byte == 15'd160) begin //transmission is stopped, reset cpu => has to reset when cpu is not halted by screen, and should stop reset when not halted by screen too. TODO: improve
            ask_for_ram <= 1'b0;
            end_of_data <= 1'b1;
          end else if (wait_for_next_byte == 15'd1) begin //end of reset cpu
            end_of_data <= 1'b0;
            waddr <= 16'h05ff; //restart writing address
          end
        end
        
      end
    end
  end


endmodule
