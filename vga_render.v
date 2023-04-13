`include "vga_sync.v"

/*
A simple test pattern using the hvsync_generator module.
*/

module vga_render(clk, reset, hsync, vsync, rgb, screen_read_en, screen_read_addr, screen_read_data);

  input clk, reset;
  output hsync, vsync;
  output [14:0] rgb;
  output screen_read_en;
  output [10:0] screen_read_addr;
  input [7:0] screen_read_data;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  wire hmaxxed;
  wire vmaxxed;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(1'b0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos),
    .hmaxxed(hmaxxed),
    .vmaxxed(vmaxxed)
  );

  wire r = display_on && (((hpos&7)==0) || ((vpos&7)==0));
  wire g = display_on && vpos[4];
  wire b = display_on;// && hpos[4];
  
  //pixel 32x32
  reg [4:0] pixx = 5'b0;
  reg [4:0] pixy = 5'b0;
  // sub pixel 0-14
  reg [3:0] subx = 4'b0;
  reg [3:0] suby = 4'b0;
  
  reg outpix = 0;
  always @(posedge clk)
  begin
    if (hpos==10'd80) begin
      outpix <= 0;
    end else if (hpos==10'd560) begin
      outpix <= 1;
    end
  end
  
  always @(posedge clk)
  begin
    if (hpos==10'd80) begin
      pixx <= 5'b0;
      subx <= 5'b0;
    end else if (subx==4'd14) begin
      pixx <= pixx + 5'b1;
      subx <= 5'b0;
    end else
      subx <= subx + 5'b1;
  end
  
  always @(posedge clk)
  begin
    if (hmaxxed) begin
      if (vmaxxed) begin
        pixy <= 5'b0;
        suby <= 5'b0;
      end else if (suby==4'd14) begin
        pixy <= pixy + 5'b1;
        suby <= 5'b0;
      end else
        suby <= suby + 5'b1;
    end
  end

  assign screen_read_addr = {pixy, pixx} + 10'h200;
  //assign screen_read_en = ~outpix;
  reg screen_read_en = 1'b0; // TODO: read memory from time to time...
  
  //wire [7:0] palettes_addr = {2'b0, pixy[2:0], pixx};
  wire [7:0] palettes_addr = screen_read_data;
  
  wire [23:0] rgb_out; // TODO: 15 bit palette
  generic_ram #(.DATA_WIDTH(24),.ADDR_WIDTH(8),.IN_FILENAME("palettes.mem"))
  ram_palettes_data(
      .rclk(clk),
      .wclk(clk),
      .write_en(1'b0),
      .waddr(8'b0),
      .din(24'b0),
      .raddr(palettes_addr),
      .dout(rgb_out));

  assign rgb =  outpix ? 15'b0 : { rgb_out[23:19], rgb_out[15:11], rgb_out[7:3] }; // TODO: delay outpix

  /*wire borderpixx = (pixx==0)||(pixx==31);
  wire borderpixy = (pixy==0)||(pixy==31);
  
  assign rgb = { outpix?5'b0:{borderpixx,4'b0}, outpix?5'b0:{borderpixy,4'b0}, 5'b0};*/
endmodule
