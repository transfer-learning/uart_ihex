module ihex(i_clk, i_reset,
i_rx_data, i_rx_stb,
o_tx_data, o_tx_stb, i_tx_busy
)

input i_clk, i_reset;

input wire [7:0] i_rx_data;
input wire i_rx_stb;

output reg [7:0] o_tx_data;
output reg o_tx_stb;
input wire i_tx_busy;

