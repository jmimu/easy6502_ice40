module debounce
#(	
`ifdef SIM
	parameter DEBOUNCE_W          =   6
`else
	parameter DEBOUNCE_W          =   14
`endif
)
	(	input wire clk,
		input wire in,
		output reg out,
		output wire rising,
		output wire falling);


	reg [DEBOUNCE_W:0] stab_cnt = 0;
	
	//"in" into clock domain
	reg in_1, in_0;
	always @(posedge clk) begin
		in_1 <= in;
		in_0 <= in_1;
	end

	initial begin
		out <= 1'b1;
	end
	
	always @(posedge clk) begin
		if (in_0 != out) begin
			stab_cnt <= stab_cnt + 1;
			if (&stab_cnt)
				out <= in_0;
		end
		else
			stab_cnt <= 0;
	end
	assign rising   = (in_0 != out) && (&stab_cnt) && in_0;
	assign falling = (in_0 != out) && (&stab_cnt) && ~in_0;
endmodule
