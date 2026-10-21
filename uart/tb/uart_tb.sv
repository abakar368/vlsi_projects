module tb_uart;
    parameter CLK_FREQ  = 100;
    parameter BAUD      = 10;
    localparam BAUD_DIV = CLK_FREQ / BAUD;

    logic       clk;
    logic       rst_n;
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx;
    logic       tx_busy;
    logic [7:0] rx_data;
    logic       rx_done;

    // ---------- TX ----------
    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // ---------- RX (loopback: tx wire feeds rx) ----------
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // ---------- Clock ----------
    initial clk = 0;
    always #5 clk = ~clk;

    // ---------- VCD ----------
    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, tb_uart);
    end

    // ---------- Scoreboard ----------
    reg [7:0] sent_q [0:31];
    integer   q_wr = 0, q_rd = 0;
    integer   pass_count = 0, fail_count = 0;

    always @(posedge clk) begin
        if (rx_done) begin
            if (rx_data === sent_q[q_rd]) begin
                $display("  [%0t] PASS: expected=0x%02h  got=0x%02h",
                         $time, sent_q[q_rd], rx_data);
                pass_count = pass_count + 1;
            end else begin
                $display("  [%0t] FAIL: expected=0x%02h  got=0x%02h",
                         $time, sent_q[q_rd], rx_data);
                fail_count = fail_count + 1;
            end
            q_rd = q_rd + 1;
        end
    end

    // ---------- Send task ----------
    task send_byte(input [7:0] data);
        begin
            @(negedge clk);
            tx_data  = data;
            tx_start = 1;
            @(negedge clk);
            tx_start = 0;
            sent_q[q_wr] = data;
            q_wr = q_wr + 1;
            $display("[%0t] SENT: 0x%02h", $time, data);
            wait(tx_busy == 1'b1);
            wait(tx_busy == 1'b0);
        end
    endtask

    // ---------- Main ----------
    initial begin
        $display("============================================");
        $display(" UART Loopback Test");
        $display(" CLK_FREQ=%0d  BAUD=%0d  BAUD_DIV=%0d", CLK_FREQ, BAUD, BAUD_DIV);
        $display("============================================");

        rst_n    = 0;
        tx_start = 0;
        tx_data  = 0;
        #100;
        rst_n = 1;
        #50;

        send_byte(8'hA5);
        send_byte(8'h00);
        send_byte(8'hFF);
        send_byte(8'h55);
        send_byte(8'hAA);
        send_byte(8'h3C);

        #3000;

        $display("============================================");
        $display(" DONE: %0d passed, %0d failed", pass_count, fail_count);
        $display("============================================");
        $finish;
    end

    // ---------- Watchdog ----------
    initial begin
        #100000;
        $display("TIMEOUT - simulation hung!");
        $finish;
    end

endmodule