module bcd_cnt_digit(clk, reset, inc, val, carry);
    input        clk, reset, inc;
    output reg [3:0] val;
    output reg carry;
    reg inc_, inc__;
    always @(posedge clk) begin
        if (reset) begin
            val <= 4'd0;
            carry = 1'b0;
        end else begin
            if (inc_>inc__) begin // on inc posedge
                if (val == 4'd9) begin
                    val <=  4'd0;
                    carry = 1'b1;
                end else begin
                    val <= val + 4'd1;
                    carry = 1'b0;
                end
            end else begin
                carry = 1'b0;
            end
        end
        inc_ <= inc;
        inc__ <= inc_;
    end
endmodule
