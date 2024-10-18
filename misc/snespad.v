module snespad (
	input clk,
	input new_frame,
	output reg pad_clock_pin, //pad clock def high
	output reg pad_latch_pin, //pad latch def low
	input pad_data_pin, //pad data
	
	output reg btn_left,
	output reg btn_right,
	output reg btn_up,
	output reg btn_down,
	output reg btn_a,
	output reg btn_b,
	output reg btn_x,
	output reg btn_y,
	output reg btn_l,
	output reg btn_r,
	output reg btn_st,
	output reg btn_sl
);

	localparam  // pad reading states
		pad_none = 0,
		pad_latch =  1,
		pad_before_read = 2,
		pad_read =  3,
		pad_after_read =  4;
	reg [15:0] pad_slow_clk;
	reg [3:0] pad_state;
	reg [3:0] pad_state_wait;//in slow clocks
	reg [5:0] pad_btn_cnt;
	initial begin
		btn_left <= 0;
		btn_right <= 0;
		btn_up <= 0;
		btn_down <= 0;
		btn_sl <= 0;
		btn_st <= 0;
		btn_r <= 0;
		btn_l <= 0;
		btn_a <= 0;
		btn_b <= 0;
		btn_x <= 0;
		btn_y <= 0;
		pad_slow_clk <= 0;
		pad_state <= pad_none;
		pad_btn_cnt <= 0;
		pad_state_wait <= 0;
		pad_latch_pin <= 0;
		pad_clock_pin <= 1;
	end

	//read snes pad
	always @(posedge clk)
	begin
		if (new_frame)
		begin
			pad_btn_cnt <= 0;
			pad_slow_clk <= 0;
			pad_state_wait <= 1;
			pad_state <= pad_latch;
			pad_latch_pin <= 0;
			pad_clock_pin <= 1;
		end else begin
			if (pad_slow_clk==1000) //just to be slow
			begin
				pad_slow_clk <= 0;
				if (pad_state_wait>0)
				begin
					pad_state_wait <= pad_state_wait - 1;
				end else begin
					case (pad_state)
					pad_none:
					begin
						//do nothing, wait for new_frame
					end
					pad_latch:
					begin
						pad_state <= pad_before_read;
						pad_latch_pin <= 1;
						pad_state_wait <= 2;
					end
					pad_before_read:
					begin
						pad_state <= pad_read;
						pad_latch_pin <= 0;
						pad_state_wait <= 1;
						pad_btn_cnt <= 0;
					end
					pad_read:
					begin
						pad_state <= pad_after_read;
						case (pad_btn_cnt) //byetUDLRaxlr0000
							0:
								btn_b <= !pad_data_pin;
							1:
								btn_y <= !pad_data_pin;
							2:
								btn_sl <= !pad_data_pin;
							3:
								btn_st <= !pad_data_pin;
							4:
								btn_up <= !pad_data_pin;
							5:
								btn_down <= !pad_data_pin;
							6:
								btn_left <= !pad_data_pin;
							7:
								btn_right <= !pad_data_pin;
							8:
								btn_a <= !pad_data_pin;
							9:
								btn_x <= !pad_data_pin;
							10:
								btn_l <= !pad_data_pin;
							11:
								btn_r <= !pad_data_pin;
						endcase
						pad_btn_cnt <= pad_btn_cnt + 1;
						pad_clock_pin <= 0;
						pad_state_wait <= 1;
					end
					pad_after_read:
					begin
						if (pad_btn_cnt>12)
						begin
							pad_state <= pad_none;
							pad_clock_pin <= 1;
						end else begin
							pad_state <= pad_read;
							pad_clock_pin <= 1;
							pad_state_wait <= 10;
						end
					end
					endcase
				end
			end else begin
				pad_slow_clk <= pad_slow_clk+1;
			end
		end
	end
	
endmodule
