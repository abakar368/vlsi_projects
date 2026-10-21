module uart_rx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD     = 115200
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);
    localparam BAUD_DIV = CLK_FREQ / BAUD;
    localparam IDLE=0, START=1, DATA=2, STOP=3;

    reg [1:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;
    reg        rx_sync0, rx_sync1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) {rx_sync0, rx_sync1} <= 2'b11;
        else        {rx_sync0, rx_sync1} <= {rx, rx_sync0};
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            rx_done  <= 0;
            clk_cnt  <= 0;
            bit_idx  <= 0;
            data_reg <= 0;
            rx_data  <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx_sync1 == 1'b0)
                        state <= START;
                end
                START: begin
                    if (clk_cnt == (BAUD_DIV/2) - 1) begin
                        clk_cnt <= 0;
                        if (rx_sync1 == 1'b0) state <= DATA;
                        else                  state <= IDLE;
                    end else clk_cnt <= clk_cnt + 1;
                end
                DATA: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        data_reg[bit_idx] <= rx_sync1;
                        if (bit_idx == 7) state   <= STOP;
                        else              bit_idx <= bit_idx + 1;
                    end else clk_cnt <= clk_cnt + 1;
                end
                STOP: begin
                    if (clk_cnt == BAUD_DIV - 1) begin
                        clk_cnt <= 0;
                        rx_data  <= data_reg;
                        rx_done  <= 1;
                        state    <= IDLE;
                    end else clk_cnt <= clk_cnt + 1;
                end
            endcase
        end
    end
endmodule