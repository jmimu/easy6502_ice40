`include "misc/uart_jm.v"
`include "misc/rams.v"

// ram buffer for uart tx
module uart_buffer(clk, reset, serial_tx, baud_x1, data, data_strobe);

    input        clk;
    input        reset;
    output       serial_tx;
    output       baud_x1;
    input  [7:0] data;
    input        data_strobe;

    // we tx until r_char_num == w_char_num
    reg [7:0] w_char_num; // where we are in buffer
    reg [7:0] r_char_num;
    wire [7:0] curr_char;
    reg data_strobe_;
    reg strobe_tx;
    
    generic_ram #(.DATA_WIDTH(8),.ADDR_WIDTH(8),.IN_FILENAME("bonjour.mem"))
    ram_uart_tx(
        .rclk(clk),
        .wclk(clk),
        .write_en(data_strobe_), // write one clock later to write at next address
        .waddr(w_char_num),
        .din(data),
        .raddr(r_char_num),
        .dout(curr_char));

    wire baud_x1, baud_x4;
    wire utx_ready;

    uart_clk uclk (.mclk(clk), .reset(reset), .baud_x1(baud_x1), .baud_x4(baud_x4));
    uart_tx utx ( .mclk(clk), .reset(reset),
                .baud_x1(baud_x1),
                .serial(serial_tx),
                .ready(utx_ready),
                .data(curr_char),
                .data_strobe(strobe_tx)
    );

    // recieve
    always @(posedge clk) begin
        if (reset) begin
            w_char_num <= 8'h00;
        end else begin
            if (baud_x1) begin
                data_strobe_ <= data_strobe;
                if (data_strobe && !data_strobe_) begin
                    // something to save
                    w_char_num <= w_char_num + 8'b1;
                end
            end
        end
    end

    // send
    always @(posedge clk) begin
        if (reset) begin
            r_char_num <= 8'h00;
            strobe_tx  <= 1'b0;
        end else begin
            if (baud_x1) begin
                if (r_char_num!=w_char_num) begin
                    // something to send
                    if (utx_ready) begin
                        strobe_tx  <= 1'b1;
                        r_char_num <= r_char_num + 8'b1;
                    end else begin
                        strobe_tx  <= 1'b0;
                    end
                end else begin
                    strobe_tx  <= 1'b0;
                end
            end
        end
    end
    
endmodule



module send_uint32_bcd_tx_buf(
        input mclk,
        input reset,
        input baud_x1,
        input [31:0] data,
        input data_strobe,
        output [7:0] curr_char,
        output send_strobe
);

   reg [4:0] digit_num;
   reg [7:0] curr_char;
   reg [79:0] reg_data;
   reg send_strobe;
   reg data_strobe_;

   // state machine
   localparam st_ready =  2'b00;
   localparam st_send =   2'b01;
   localparam st_wait =   2'b10; // wait for next digit
   localparam st_finish = 2'b11;
   reg [1:0] state;
   
   always @(posedge mclk) begin
      if (reset) begin
         digit_num <= 3'b111;
         send_strobe <= 0;
         state <= st_ready;
      end else begin
         
            case (state)
                st_ready:
                    if (data_strobe && !data_strobe_) begin
                       state <= st_wait;
                       digit_num <= 4'b1001;
                       reg_data[15:0] <= { 8'h0A, 8'h0D };
                       reg_data[(0*8+16) +:8] <= {4'h0, data[(0*4) +:4]};
                       reg_data[(1*8+16) +:8] <= {4'h0, data[(1*4) +:4]};
                       reg_data[(2*8+16) +:8] <= {4'h0, data[(2*4) +:4]};
                       reg_data[(3*8+16) +:8] <= {4'h0, data[(3*4) +:4]};
                       reg_data[(4*8+16) +:8] <= {4'h0, data[(3*4) +:4]};
                       reg_data[(5*8+16) +:8] <= {4'h0, data[(5*4) +:4]};
                       reg_data[(6*8+16) +:8] <= {4'h0, data[(6*4) +:4]};
                       reg_data[(7*8+16) +:8] <= {4'h0, data[(7*4) +:4]};
                       send_strobe <= 1; // send digit
                    end
                st_wait: if (baud_x1) begin
                    send_strobe <= 0;
                    state <= st_send;
                end
                st_send:
                    if (baud_x1) begin
                        if (digit_num==4'b0000) begin
                          digit_num <= 4'b1001;
                          send_strobe <= 0;
                          state <= st_finish;  // seq finished
                        end else begin
                          digit_num <= digit_num - 1;
                          send_strobe <= 1; // send digit
                          state <= st_wait;
                        end
                    end
                st_finish: if (baud_x1) begin
                    send_strobe <= 0;
                    state <= st_ready;
                end
            endcase
         
         curr_char <= reg_data[(digit_num * 8) +:8];
      end
      data_strobe_ <= data_strobe;
   end

endmodule