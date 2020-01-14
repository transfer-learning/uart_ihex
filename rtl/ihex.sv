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

function [3:0] hex_to_val;
input [7:0] ascii;
begin
    case(ascii)
        "0": hex_to_val = 4'h0;
        "1": hex_to_val = 4'h1;
        "2": hex_to_val = 4'h2;
        "3": hex_to_val = 4'h3;
        "4": hex_to_val = 4'h4;
        "5": hex_to_val = 4'h5;
        "6": hex_to_val = 4'h6;
        "7": hex_to_val = 4'h7;
        "8": hex_to_val = 4'h8;
        "9": hex_to_val = 4'h9;
        "0": hex_to_val = 4'h0;
        "a", "A": hex_to_val = 4'ha;
        "b", "B": hex_to_val = 4'hb;
        "c", "C": hex_to_val = 4'hc;
        "d", "D": hex_to_val = 4'hd;
        "e", "E": hex_to_val = 4'he;
        "F", "F": hex_to_val = 4'hf;
        default: hex_to_val = 4'h0;
    endcase
end
endfunction

localparam  IDLE=0,
            CMD1=1, CMD2=2
;

integer state;
initial begin
    state = IDLE;
end

reg [7:0] buffer [256];
reg [7:0] computed_sum;
reg [7:0] cmd;

always @(posedge i_clk) begin
    if (i_rx_stb) begin
        if (state == IDLE) begin
            if (i_rx_data == ":") begin
                computed_sum <= 0;
                cmd <= 0;
                state <= CMD1;
            end
        end else if (state == CMD1) begin
            cmd <= {hex_to_val(i_rx_data), 4'h0};
            state <= CMD1;
        end else if (state == CMD2) begin
            cmd <= {cmd[7:4], hex_to_val(i_rx_data)};
            if ({cmd[7:4], hex_to_val(i_rx_data)} == 0) begin
                
            end else // COMMAND TYPE SUPPORT
                state <= IDLE;
        end
    end
end

endmodule
