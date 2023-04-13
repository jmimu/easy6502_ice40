module power_on_reset(clk, reset);

    input        clk;
    output       reset;
    //see https://discourse.tinyfpga.com/t/power-on-reset-does-anyone-have-experience/880/2
	reg [11:0] reset_cnt = 0;
	wire resetn = &reset_cnt;
	always @(posedge clk) begin
		reset_cnt <= reset_cnt + !resetn;
	end
	assign reset = !resetn;
endmodule
