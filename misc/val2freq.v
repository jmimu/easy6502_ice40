module val2freq(clk25M, reset, val, freq_out);

   input        clk25M, reset;
   input  [7:0] val;
   output       freq_out;

   reg [24:0]    cnt;
   assign freq_out = cnt[24];
   
   always @(posedge clk25M or posedge reset)
   begin
     if (reset) begin
        cnt <= 0;
     end
     else begin
        if (cnt>25000000) cnt <=0;
        else cnt <= cnt + val;
     end
   end
endmodule