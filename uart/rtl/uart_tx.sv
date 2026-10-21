module uart_tx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD     = 115200
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] tx_data,
    input  logic       tx_start,
    output logic       tx,
    output logic       tx_busy
);
    localparam BAUD_DIV = CLK_FREQ / BAUD;
    localparam IDLE=0, START=1, DATA=2, STOP=3;

    reg [1:0]  state;
    reg [15:0] clk_cnt;
    reg [7:0]  data_reg;
    reg [2:0]  bit_idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            clk_cnt  <= 0;
            data_reg <= 0;
            bit_idx  <= 0;
            tx_busy  <= 0;
            tx       <= 1;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1;
                    tx_busy <= 0;
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        state    <= START;
                        tx_busy  <= 1;
                    end
                end
                START: begin
                    tx <= 0;
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        state   <= DATA;
                    end else clk_cnt <= clk_cnt + 1;
                end
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 7) state   <= STOP;
                        else              bit_idx <= bit_idx + 1;
                    end else clk_cnt <= clk_cnt + 1;
                end
                STOP: begin
                    tx <= 1;
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        state   <= IDLE;
                    end else clk_cnt <= clk_cnt + 1;
                end
            endcase
        end
    end
endmodule