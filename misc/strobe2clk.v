//from a strobe as small as mclk, make a pulse as wide as 2 sub_clk
module strobe2clk(reset, mclk, sub_clk, in, out);
    input reset, mclk, sub_clk, in;
    output reg out;

    reg in_r, in_f;
    reg prev_sub, prev_sub_;

    wire sub_r = prev_sub_<prev_sub;
    wire sub_f = prev_sub_>prev_sub;
    always @(posedge mclk)
    begin
        if (reset)
        begin
            in_r <= 1'b0;
            in_f <= 1'b0;
            prev_sub <= 1'b0;
        end else begin
            prev_sub <= sub_clk;
            prev_sub_ <= prev_sub;
            if (!in_r && in) in_r <= 1'b1;
            else if (!in_f && !in) in_f <= 1'b1;
            else if (prev_sub_<prev_sub) begin//rising edge
                if (in_r) begin
                    out <= 1'b1;
                    in_r <= 1'b0;
                end else if (in_f) begin
                    out <= 1'b0;
                    in_f <= 1'b0;
                end
            end
        end
    end

endmodule
    