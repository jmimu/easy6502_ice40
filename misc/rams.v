`timescale 1ns / 1ps

/*module generic_ram
#(
//--------------------------------------------------------------------------
    parameter DATA_WIDTH = 8, //records size
    parameter ADDR_WIDTH = 10, //nb records <= 2**ADDR_WIDTH
    parameter IN_FILENAME = "?"
//----------------------------------------------------------------------
)*/
module generic_ram (din, write_en, waddr, wclk, raddr, rclk, dout);
  parameter ADDR_WIDTH = 9;
  parameter DATA_WIDTH = 8;
  parameter IN_FILENAME = "?";
  input [ADDR_WIDTH-1:0] waddr;
  input [ADDR_WIDTH-1:0] raddr;
  input [DATA_WIDTH-1:0] din;
  input write_en, wclk, rclk;
  output reg [DATA_WIDTH-1:0] dout;
`ifdef SIMUL
  reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
`else
  reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];
`endif
  if (IN_FILENAME!="?")
        initial $readmemh (IN_FILENAME, mem);
  always @(posedge wclk) // Write memory.
    begin
    if (write_en)
      mem[waddr] <= din; // Using write address bus.
  end
  always @(posedge rclk) // Read memory.
  begin
    dout <= mem[raddr]; // Using read address bus.
  end
endmodule
