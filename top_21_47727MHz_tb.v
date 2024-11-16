`timescale 1ns/10ps

`include "top_21_47727MHz.v"

module tb ();

    localparam DURATION = 3000000;

    reg clk12;
    reg clk_100;
    reg pps;
    wire led_green;
    wire led_red;
    wire led_blue;
    wire out;

    initial begin
        clk12 = 1'b0;
        clk_100 = 1'b0;
        pps = 1'b0;
    end

    always begin
        #41 clk12 = !clk12;
    end

    always begin
        #5 clk_100 = !clk_100;
    end
    
    always begin
        #41048 pps = !pps;
    end

    top_21_47727MHz uut(
        .gpio_20(clk12),
        .gpio_18(out),

        .led_green(led_green),
        .led_red(led_red),
        .led_blue(led_blue),
        .clk_hi(clk_100)
    );

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb); //0: all levels deep in current module
        #(DURATION)
        $display("Finished!");
        $finish;
    end
endmodule
