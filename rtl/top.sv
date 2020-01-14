module top(i_clk, i_rx, o_tx, o_sseg);

input i_clk, i_rx;
output wire [6:0] o_sseg[0:2];
output wire o_tx;

wire rdy;
wire [7:0] data;
reg [7:0] buffer;
reg [3:0] internal;

initial begin
    buffer = 0;
    internal = 0;
end

wire busy;
uart_rx rx(i_clk, i_rx, rdy, data);
uart_tx tx(i_clk, data, rdy, o_tx, busy);

always @(posedge i_clk) begin
    if (rdy) begin
        buffer <= data;
        internal <= internal + 1;
    end
end

sevenSegmentDisp seg0(o_sseg[0], data[3:0]);
sevenSegmentDisp seg1(o_sseg[1], data[7:4]);
// sevenSegmentDisp seg2(o_sseg[2], state);

endmodule
