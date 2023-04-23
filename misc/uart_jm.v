//generates 57600 from 16MHz or 12MHz master clock
// 16e6/(8192/59) =  115234.37500
// 12e6/(8192/79) =  115722.65625
module uart_clk(mclk, reset, baud_x1, baud_x4);

   input        mclk, reset;
   output       baud_x1, baud_x4;

   reg [13:0]    cnt;//up to 8192*2 + 1 bit overflow
   
   reg prev_x1, prev_x4;
   assign baud_x1 = cnt[13] != prev_x1;
   assign baud_x4 = cnt[11] != prev_x4;
   
   always @(posedge mclk or posedge reset)
   begin
     if (reset) begin
        cnt <= 0;
        prev_x1 <= 0;
        prev_x4 <= 0;
     end
     else begin
        cnt <= cnt + 79;
        prev_x1 <= cnt[13];
        prev_x4 <= cnt[11];
     end
   end
endmodule

/*
 * Byte transmitter, RS-232 8-N-1
 *
 * Transmits on 'serial'. When 'ready' goes high, we can accept another byte.
 * It should be supplied on 'data' with a pulse on 'data_strobe'.
 */

module uart_tx(
	input mclk,
	input reset,
	input baud_x1_pulse,
	output serial,
	output reg ready,
	input [7:0] data,
	input data_strobe
);

   /*
    * Left-to-right shift register.
    * Loaded with data, start bit, and stop bit.
    *
    * The stop bit doubles as a flag to tell us whether data has been
    * loaded; we initialize the whole shift register to zero on reset,
    * and when the register goes zero again, it's ready for more data.
    */
   reg [7+1+1:0]   shiftreg;

   /*
    * Serial output register. This is like an extension of the
    * shift register, but we never load it separately. This gives
    * us one bit period of latency to prepare the next byte.
    *
    * This register is inverted, so we can give it a reset value
    * of zero and still keep the 'serial' output high when idle.
    */
   reg         serial_r;
   assign      serial = !serial_r;

   //assign      ready = (shiftreg == 0);

   /*
    * State machine
    */

   always @(posedge mclk)
     if (reset) begin
        shiftreg <= 0;
        serial_r <= 0;
     end
     else if (data_strobe) begin
        shiftreg <= {
		1'b1, // stop bit
		data,
		1'b0  // start bit (inverted)
	};
	ready <= 0;
     end
     else if (baud_x1) begin
        if (shiftreg == 0)
	begin
          /* Idle state is idle high, serial_r is inverted */
          serial_r <= 0;
	  ready <= 1;
	end else
          serial_r <= !shiftreg[0];
  	// shift the output register down
        shiftreg <= {1'b0, shiftreg[7+1+1:1]};
    end else
    	ready <= (shiftreg == 0);

endmodule


/*
 * Byte receiver, RS-232 8-N-1
 *
 * Receives on 'serial'. When a properly framed byte is
 * received, 'data_strobe' pulses while the byte is on 'data'.
 *
 * Error bytes are ignored.
 */

module uart_rx(mclk, reset, baud_x4,
                      serial, data, data_strobe);

   input        mclk, reset, baud_x4, serial;
   output [7:0] data;
   output       data_strobe;

   /*
    * Synchronize the serial input to this clock domain
    */
   wire         serial_sync;
   d_flipflop_pair input_dff(mclk, reset, serial, serial_sync);

   /*
    * State machine: Four clocks per bit, 10 total bits.
    */
   reg [8:0]    shiftreg;
   reg [5:0]    state;
   reg          data_strobe;
   wire [3:0]   bit_count = state[5:2];
   wire [1:0]   bit_phase = state[1:0];

   wire         sampling_phase = (bit_phase == 1);
   wire         start_bit = (bit_count == 0 && sampling_phase);
   wire         stop_bit = (bit_count == 9 && sampling_phase);

   wire         waiting_for_start = (state == 0 && serial_sync == 1);

   wire         error = ( (start_bit && serial_sync == 1) ||
                          (stop_bit && serial_sync == 0) );

   assign       data = shiftreg[7:0];

   always @(posedge mclk or posedge reset)
     if (reset) begin
        state <= 0;
        data_strobe <= 0;
     end
     else if (baud_x4) begin

        if (waiting_for_start || error || stop_bit)
          state <= 0;
        else
          state <= state + 1;

        if (bit_phase == 1)
          shiftreg <= { serial_sync, shiftreg[8:1] };

        data_strobe <= stop_bit && !error;

     end
     else begin
        data_strobe <= 0;
     end

endmodule


/*
 * Output UART with a block RAM FIFO queue.
 *
 * Add bytes to the queue and they will be printed when the line is idle.
 */
module uart_tx_fifo(
	input clk,
	input reset,
	input baud_x1,
	input [7:0] data,
	input data_strobe,
	output serial
);
	parameter NUM = 32;

	wire uart_txd_ready; // high the UART is ready to take a new byte
	reg uart_txd_strobe; // pulse when we have a new byte to transmit
	reg [7:0] uart_txd;

	uart_tx txd(
		.mclk(clk),
		.reset(reset),
		.baud_x1(baud_x1),
		.serial(serial),
		.ready(uart_txd_ready),
		.data(uart_txd),
		.data_strobe(uart_txd_strobe)
	);

	wire fifo_available;
	wire fifo_read_strobe;

	fifo #(.NUM(NUM), .WIDTH(8)) buffer(
		.clk(clk),
		.reset(reset),
		.write_data(data),
		.write_strobe(data_strobe),
		.data_available(fifo_available),
		.read_data(uart_txd),
		.read_strobe(fifo_read_strobe)
	);

	// drain the fifo into the serial port
	always @(posedge clk)
	begin
		uart_txd_strobe <= 0;
		fifo_read_strobe <= 0;

		if (fifo_available
		&&  uart_txd_ready
		&& !data_strobe // avoid dual port RAM if possible
		&& !uart_txd_strobe // don't TX twice on one byte
		) begin
			fifo_read_strobe <= 1;
			uart_txd_strobe <= 1;
		end
	end
endmodule


/************************************************************************
 *
 * Random utility modules.
 *
 * Micah Dowty <micah@navi.cx>
 *
 ************************************************************************/


module d_flipflop(clk, reset, d_in, d_out);
   input clk, reset, d_in;
   output d_out;

   reg    d_out;

   always @(posedge clk or posedge reset)
     if (reset) begin
         d_out   <= 0;
     end
     else begin
         d_out   <= d_in;
     end
endmodule


module d_flipflop_pair(clk, reset, d_in, d_out);
   input  clk, reset, d_in;
   output d_out;
   wire   intermediate;

   d_flipflop dff1(clk, reset, d_in, intermediate);
   d_flipflop dff2(clk, reset, intermediate, d_out);
endmodule

