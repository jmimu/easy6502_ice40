`timescale 1ns/10ps

`include "top_uart.v"

module tb ();

    localparam DURATION = 30000000;

    reg clk12;
    reg pps;
    wire led_green;
    wire led_red;
    wire led_blue;
    wire serial_txd;

    initial begin
        clk12 = 1'b0;
        pps = 1'b0;
    end

    always begin
        #41 clk12 = !clk12;
    end
    
    always begin
        #1000000 pps = !pps;
    end

    top_uart uut(
        .gpio_20(clk12),
        .gpio_21(pps),
        .serial_txd(serial_txd),
        
        .led_green(led_green),
        .led_red(led_red),
        .led_blue(led_blue)
    );

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb); //0: all levels deep in current module
        #(DURATION)
        $display("Finished!");
        $finish;
    end
endmodule
