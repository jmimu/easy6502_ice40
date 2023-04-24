`include "vga_render.v"
`include "i2s.v"
`include "uart_prog_input.v"
`include "misc/rams.v"
`include "misc/power_on_reset.v"
`include "verilog-6502/cpu.v"
`include "verilog-6502/ALU.v"


module top_easy6502 (
    // inputs
    input wire gpio_20, // 12 MHz clk
    input wire serial_rxd,

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

    output wire led_green,
    output wire led_red,
    output wire led_blue,

`ifdef SIM
	input wire CLK_25M
`endif

);

wire CLK_12M = gpio_20;

`ifndef SIM
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
`endif

//power on reset
wire reset;
power_on_reset por(
  .clk(CLK_25M),
  .reset(reset)
);


// memory
wire [10:0] ram_waddr = cpu_ready?cpu_address[10:0]:uart_waddr[10:0];
wire [10:0] ram_raddr = cpu_ready?cpu_address[10:0]:screen_read_addr;
wire [7:0] ram_wdata = cpu_ready?cpu_wdata:uart_wdata;
wire ram_write_en = (cpu_write_en && cpu_ready) || uart_write_en;
wire [7:0] ram_rdata;// = screen_read_data;
//assign cpu_rdata = screen_read_data;

generic_ram #(.DATA_WIDTH(8),.ADDR_WIDTH(11),.IN_FILENAME("easy6502.mem"))
ram_system(
    .rclk(CLK_25M),
    .wclk(CLK_25M),
    .write_en(ram_write_en),
    .waddr(ram_waddr),
    .din(ram_wdata),
    .raddr(ram_raddr),
    .dout(ram_rdata));


// display
wire screen_read_en;
wire [10:0] screen_read_addr;
//wire [7:0] screen_read_data;
vga_render vga(
    .clk(CLK_25M),
    .reset(reset),
    .hsync(gpio_2),
    .vsync(gpio_46),
    .rgb( { gpio_32, gpio_27, gpio_26, gpio_25, gpio_23,
            gpio_43, gpio_34, gpio_37, gpio_31, gpio_35,
            gpio_47, gpio_28, gpio_38, gpio_42, gpio_36 } ),
    .screen_read_en(screen_read_en),
    .screen_read_addr(screen_read_addr),
    .screen_read_data(ram_rdata)
);


reg cpu_ready = 1'b0;
always @(posedge CLK_25M)
begin
    if (screen_read_en || uart_ask_for_ram)
    begin
        if (cpu_sync) // wait for new instruction start to stop cpu and let mem to other
            cpu_ready <= 1'b0;
    end else begin
        if ((!reset) && (!cpu_ready))
            cpu_ready <= 1'b1;
    end
end

wire cpu_sync;
wire [15:0] cpu_address;
wire cpu_write_en;
wire [7:0] cpu_wdata;
//wire [7:0] cpu_rdata;
wire cpu_reset = reset | uart_end_of_data;
cpu cpu1( 
    .clk(CLK_25M),                          // CPU clock
    .reset(cpu_reset),                          // RST signal
    .AB(cpu_address),                   // address bus (combinatorial) 
    .DI(ram_rdata),                     // data bus input
    .DO(cpu_wdata),                // data bus output 
    .WE(cpu_write_en),                          // write enable
    .IRQ(1'b0),                          // interrupt request
    .NMI(1'b0),                          // non-maskable interrupt request
    .RDY( cpu_ready ),      // Ready signal. Pauses CPU when RDY=0
    .SYNC(cpu_sync)            // is starting a new instruction
 );

// uart 57600
wire [15:0] uart_waddr;
wire [7:0] uart_wdata;
wire uart_ask_for_ram;
wire uart_end_of_data;
wire uart_write_en;

uart_prog_input uart_prog_input1(
    .clk_ram(CLK_25M),
    .reset(reset),
    .serial_rxd(serial_rxd),
    .waddr(uart_waddr),
    .wdata(uart_wdata),
    .write_en(uart_write_en),
    .ask_for_ram(uart_ask_for_ram),
    .end_of_data(uart_end_of_data)
);

assign led_green = ~uart_ask_for_ram;
assign led_red = ~uart_end_of_data;
assign led_blue = 1'b1;

endmodule
