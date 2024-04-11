`include "misc/uart_jm.v"
`include "misc/rams.v"

// ram buffer for uart tx
module uart_buffer(clk, reset, serial_tx, data, data_strobe);

    input        clk;
    input        reset;
    output       serial_tx;
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
        .write_en(data_strobe),
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
            w_char_num <= 8'h10;
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
            r_char_num <= 8'hFF;
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
