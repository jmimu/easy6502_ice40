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
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos),
    .hmaxxed(hmaxxed),
    .vmaxxed(vmaxxed)
  );

  //pixel 32x32
  reg [4:0] pixx = 5'b0;
  reg [4:0] pixy = 5'b0;
  // sub pixel 0-10
  reg [3:0] subx = 4'b0;
  reg [3:0] suby = 4'b0;
  
  reg in_border_h = 0;
  reg ask_for_ram = 0;
  always @(posedge clk)
  begin
    if (reset) begin
      in_border_h <= 1'b1;
      ask_for_ram <= 1'b0;
    end else begin
      if (hpos==10'd130) begin
        ask_for_ram <= !in_border_v; //ask for ram one pixel before drawing to let CPU finish current instruction
      end else if (hpos==10'd144) begin
        in_border_h <= 1'b0;
      end else if (hpos==10'd496) begin
        in_border_h <= 1'b1;
        ask_for_ram <= 1'b0;
      end
    end
  end

  reg in_border_v = 0;
  always @(posedge clk)
  begin
    if (reset) begin
      in_border_v <= 1'b1;
    end else begin
      if (vpos==10'd16) begin
        in_border_v <= 1'b0;
      end else if (vpos==10'd464) begin
        in_border_v <= 1'b1;
      end
    end
  end
  
  always @(posedge clk)
  begin
    if (reset) begin
      pixx <= 5'b0;
      subx <= 5'b0;
    end else begin
      if (hpos==10'd142) begin
        pixx <= 5'b0;
        subx <= 5'b0;
      end else if (subx==4'd10) begin
        pixx <= pixx + 5'b1;
        subx <= 5'b0;
      end else
        subx <= subx + 5'b1;
    end
  end
  
  always @(posedge clk)
  begin
    if (reset) begin
      pixy <= 5'b0;
      suby <= 5'b0;
    end else begin
      if (hmaxxed) begin
        if (vpos==10'd15) begin
          pixy <= 5'b0;
          suby <= 5'b0;
        end else if (suby==4'd13) begin
          pixy <= pixy + 5'b1;
          suby <= 5'b0;
        end else
          suby <= suby + 5'b1;
      end
    end
  end

  assign screen_read_addr = {pixy, pixx} + 10'h200;

  assign screen_read_en = ask_for_ram; // TODO: read all line once?
  
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

  assign rgb =  (!display_on) ? 15'b0 :
                  (in_border_h | in_border_v) ? { hpos[9:5], vpos[9:5], 5'b0 } :
                    { rgb_out[23:19], rgb_out[15:11], rgb_out[7:3] }; // TODO: delay outpix

endmodule
