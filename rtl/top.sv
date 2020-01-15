`include "wishbone.sv"

module top(i_clk, i_reset, i_rx, o_tx, o_sseg);

input i_clk, i_rx;
input i_reset;
output wire [6:0] o_sseg[0:2];
output wire o_tx;

wire reset = !i_reset;

wire rx_rdy, tx_stb;
wire [7:0] rx_data;
wire [7:0] tx_data;
reg [7:0] buffer;
reg [3:0] internal;

initial begin
    buffer = 0;
    internal = 0;
end

wishbone wb(.i_clk(i_clk), .i_reset(reset));

wire busy;
uart_rx rx(i_clk, i_rx, rx_rdy, rx_data);
uart_tx tx(i_clk, tx_data, tx_stb, o_tx, busy);

ihex hex(i_clk, reset, rx_data, rx_rdy, tx_data, tx_stb, busy, wb.master);

// always @(posedge i_clk) begin
//     if (rdy) begin
//         buffer <= data;
//         internal <= internal + 1;
//     end
// end

sevenSegmentDisp seg2(o_sseg[2], internal);

endmodule
