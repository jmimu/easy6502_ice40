module power_on_reset(clk, reset);

    input        clk;
    output       reset;
    //see https://discourse.tinyfpga.com/t/power-on-reset-does-anyone-have-experience/880/2
	
`ifdef SIM
    reg [7:0] reset_cnt = 0;
`else
    reg [23:0] reset_cnt = 0; // 1.4s
`endif
	wire resetn = &reset_cnt;
	always @(posedge clk) begin
		reset_cnt <= reset_cnt + !resetn;
	end
	assign reset = !resetn;
endmodule
