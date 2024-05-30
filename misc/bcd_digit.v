// inc must be < half clk
module bcd_cnt_digit(clk, reset, inc, val, carry, reset_out);
    input        clk, reset, inc;
    output reg [3:0] val;
    output carry;
    output reg reset_out; // temporize reset for next digit (to be able to get it before it is resetted)
    reg inc_, inc__;
    assign carry = (val == 4'd9) && (inc_>inc__) && !reset;
    always @(posedge clk) begin
        if (reset) begin
            val <= 4'd0;
        end else begin
            if (inc_>inc__) begin // on inc posedge
                if (val == 4'd9) begin
                    val <=  4'd0;
                end else begin
                    val <= val + 4'd1;
                end
            end
        end
        inc_ <= inc;
        inc__ <= inc_;
        reset_out <= reset;
    end
endmodule

// increase each clk
module bcd_clk_cnt_digit(clk, reset, val, carry, reset_out);
    input        clk, reset;
    output reg [3:0] val;
    output carry;
    output reg reset_out; // temporize reset for next digit (to be able to get it before it is resetted)
    assign carry = (val == 4'd9) && !reset;
    always @(posedge clk) begin
        if (reset) begin
            val <= 4'd0;
        end else begin
            if (val == 4'd9) begin
                val <=  4'd0;
            end else begin
                val <= val + 4'd1;
            end
        end
        reset_out <= reset;
    end
endmodule
