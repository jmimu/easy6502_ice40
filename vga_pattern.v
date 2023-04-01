`include "vga_sync.v"

/*
A simple test pattern using the hvsync_generator module.
*/

module vga_pattern(clk, reset, hsync, vsync, rgb);

  input clk, reset;
  output hsync, vsync;
  output [14:0] rgb;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(1'b0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  wire r = display_on && (((hpos&7)==0) || ((vpos&7)==0));
  wire g = display_on && vpos[4];
  wire b = display_on && hpos[4];
  assign rgb = { {b,b,b,b,b}, {g,g,g,g,g}, {r,r,r,r,r}};

endmodule