`timescale 1ns / 1ps

//suppose bitCLK = 32*2**14
//max divider = for 32 hz = 2**14
module sound_gen_sqr (reset, bit_clk, vol, tone_div, dout);
  parameter TONE_DIV_WIDTH = 14;
  parameter DATA_WIDTH = 16;
  input reset;
  input bit_clk;
  input [TONE_DIV_WIDTH-1:0] tone_div;
  input [DATA_WIDTH-1:0] vol;
  output [DATA_WIDTH-1:0] dout;//for now, same L/R
  
  reg [TONE_DIV_WIDTH-1:0] curr_div; //copy of tone_div, to reset on tone_div change
  reg [TONE_DIV_WIDTH-1:0] div_cnt;
  reg high;

  assign dout = high ? vol : 16'b0;

  always @(posedge bit_clk or posedge reset)
  begin
    if (reset)
    begin
      high <= 0;
      curr_div <= tone_div;
      div_cnt <= tone_div;
    end else begin
      if (curr_div != tone_div) //change tone
      begin
        curr_div <= tone_div;
        div_cnt <= (div_cnt < tone_div) ? div_cnt - 1 : tone_div - 1;
      end else begin
        div_cnt <= div_cnt - 1;
      end//erreur
      if (div_cnt == 0) begin
        high <= ~high; //square
        div_cnt <= tone_div - 1; //not curr_div because out of "if (curr_div != tone_div)"
      end   
    end
  end
endmodule


module sound_gen (reset, bit_clk, vol, freq, dout);
  parameter PHASE_WIDTH = 16;
  parameter DATA_WIDTH = 16;
  input reset;
  input bit_clk;
  input [PHASE_WIDTH-5:0] freq;
  input [3:0] vol;
  output [DATA_WIDTH-1:0] dout;//for now, same L/R
  
  reg [4:0] data_clk;
  reg [PHASE_WIDTH:0] phase; // 4b:vol, 12b:phase
  reg [PHASE_WIDTH:0] next_phase;

  assign dout = phase[PHASE_WIDTH-1:0];//sawtooth

  always @(posedge bit_clk or posedge reset)
  begin
    if (reset)
    begin
      data_clk <= 0;
      phase <= 0;
      next_phase <= freq;
    end else begin
      data_clk <= data_clk + 1;
      if (data_clk<vol)
      begin
        next_phase <= next_phase + freq;
      end
      if (data_clk == 15)
      begin
        if (next_phase[PHASE_WIDTH:PHASE_WIDTH-4] == vol)
        begin
          next_phase <= freq;
          phase <= 0;
        end else begin
          phase <= next_phase;
        end
      end
    end
  end
endmodule



module i2s (reset, bit_clk, din, sd, ws);
  parameter DATA_WIDTH = 16;
  input reset;
  input bit_clk;
  input [DATA_WIDTH-1:0] din;//for now, same L/R
  output reg sd;//serial data, delayed 1 clk
  output ws;//word select

  reg [DATA_WIDTH-1:0] data;
  //wire [DATA_WIDTH-1:0] data;
  //assign data = din;

  reg [4:0] data_clk;

  assign ws = data_clk[4];

  always @(negedge bit_clk or posedge reset)
  begin
    if (reset)
    begin
      data_clk <= {DATA_WIDTH,1'b0} - 1;
      sd <= 1'b0;
    end else begin
      if (data_clk == 0) begin
        data_clk <= {DATA_WIDTH,1'b0} - 1;
        data <= din;
      end else begin
        data_clk <= data_clk - 1;
        sd <= data[data_clk[3:0]];
      end
    end
  end
endmodule
