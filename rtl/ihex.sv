module ihex(i_clk, i_reset,
i_rx_data, i_rx_stb,
o_tx_data, o_tx_stb, i_tx_busy
);

input wire i_clk, i_reset;

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
            CMD1=1, CMD2=2,
            LEN1=3, LEN2=4,
            ADDR1=5, ADDR2=6, ADDR3=7, ADDR4=8,
            EXEC=9, EXEC2=10,
            CHKSUM=11, CHKSUM2=12,
            EXEC_ACK=13
;

integer state;
initial begin
    state = IDLE;
end

reg [7:0] buffer [256];
reg [7:0] computed_sum;
reg [7:0] cmd;
reg [7:0] len;
reg [15:0] addr;
reg [7:0] buffer_fill;
reg filled_high;
reg [7:0] cmp_sum;

always @(posedge i_clk) begin
    if (i_rx_stb) begin
        if (state == IDLE) begin
            if (i_rx_data == ":") begin
                computed_sum <= 0;
                cmd <= 0;
                state <= LEN1;
            end
        end else if (state == CMD1) begin
            cmd <= {hex_to_val(i_rx_data), 4'h0};
            state <= CMD2;
        end else if (state == CMD2) begin
            cmd <= {cmd[7:4], hex_to_val(i_rx_data)};
            computed_sum <= computed_sum + {cmd[7:4], hex_to_val(i_rx_data)};
            buffer_fill <= 0;
            filled_high <= 0;
            if (len > 0)
                state <= EXEC;
            else
                state <= CHKSUM;
        end else if (state == LEN1) begin
            len <= {hex_to_val(i_rx_data), 4'h0};
            state <= LEN2;
        end else if (state == LEN2) begin
            len <= {len[7:4], hex_to_val(i_rx_data)};
            computed_sum <= computed_sum + {len[7:4], hex_to_val(i_rx_data)};
            state <= ADDR1;
        end else if (state == ADDR1) begin
            addr <= {hex_to_val(i_rx_data), 12'h0};
            state <= ADDR2;
        end else if (state == ADDR2) begin
            addr <= {addr[15:12], hex_to_val(i_rx_data), 4'h0};
            computed_sum <= computed_sum + {addr[15:12], hex_to_val(i_rx_data)};
            state <= ADDR3;
        end else if (state == ADDR3) begin
            addr <= {addr[15:8], hex_to_val(i_rx_data), 4'h0};
            state <= ADDR4;
        end else if (state == ADDR4) begin
            addr <= {addr[15:4], hex_to_val(i_rx_data)};
            computed_sum <= computed_sum + {addr[7:4], hex_to_val(i_rx_data)};
            state <= CMD1;
        end else if (state == EXEC) begin
            if (filled_high) begin
                buffer[buffer_fill] <= {buffer[buffer_fill][7:4], hex_to_val(i_rx_data)};
                computed_sum <= computed_sum + {buffer[buffer_fill][7:4], hex_to_val(i_rx_data)};
                filled_high <= 0;
                if (buffer_fill + 1 < len)
                    buffer_fill <= buffer_fill + 1;
                else
                    state <= CHKSUM;
            end else begin
                buffer[buffer_fill] <= {hex_to_val(i_rx_data), 4'h0};
                filled_high <= 1;
            end
        end else if (state == CHKSUM) begin
            cmp_sum <= {hex_to_val(i_rx_data), 4'h0};
            state <= CHKSUM2;
        end else if (state == CHKSUM2) begin
            cmp_sum <= {cmp_sum[7:4], hex_to_val(i_rx_data)};
            state <= EXEC2;
        end
    end
    if (state == EXEC2) begin
        if (!i_tx_busy) begin
            o_tx_data <= computed_sum;
            state <= EXEC_ACK;
        end
    end
    if (state == EXEC_ACK) begin
        state <= IDLE; // Operation Complete
    end
end

endmodule
