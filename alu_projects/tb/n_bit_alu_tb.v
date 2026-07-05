`timescale 1ns/1ps

module n_bit_alu_tb;

    //==================================================
    // Parameters
    //==================================================
    localparam N = 4;

    //==================================================
    // ALU Operation Codes
    //==================================================
    localparam ALU_ADD         = 3'b000;
    localparam ALU_SUB         = 3'b001;
    localparam ALU_OR          = 3'b010;
    localparam ALU_AND         = 3'b011;
    localparam ALU_XOR         = 3'b100;
    localparam ALU_LEFT_SHIFT  = 3'b101;
    localparam ALU_RIGHT_SHIFT = 3'b110;
    localparam ALU_PASS        = 3'b111;

    //==================================================
    // Testbench Signals
    //==================================================
    reg  [N-1:0] a;
    reg  [N-1:0] b;
    reg  [2:0]   sel;

    wire [N-1:0] y;
    wire carry;
    wire zero;
    wire negative;
    wire overflow;

    //==================================================
    // DUT
    //==================================================
    n_bit_alu #(N) dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y),
        .carry(carry),
        .zero(zero),
        .negative(negative),
        .overflow(overflow)
    );

    //==================================================
    // Golden Model Outputs
    //==================================================
    reg [N-1:0] exp_y;
    reg         exp_carry;
    reg         exp_zero;
    reg         exp_negative;
    reg         exp_overflow;

    integer errors = 0;

    //==================================================
    // Golden Reference Model
    //==================================================
    task compute_expected;
    begin

        exp_y         = 0;
        exp_carry     = 0;
        exp_zero      = 0;
        exp_negative  = 0;
        exp_overflow  = 0;

        case(sel)

            ALU_ADD: begin
                {exp_carry, exp_y} = a + b;
                exp_overflow =
                    (~(a[N-1] ^ b[N-1])) &
                    (a[N-1] ^ exp_y[N-1]);
            end

            ALU_SUB: begin
                {exp_carry, exp_y} = a - b;
                exp_overflow =
                    (a[N-1] ^ b[N-1]) &
                    (a[N-1] ^ exp_y[N-1]);
            end

            ALU_OR:
                exp_y = a | b;

            ALU_AND:
                exp_y = a & b;

            ALU_XOR:
                exp_y = a ^ b;

            ALU_LEFT_SHIFT:
                exp_y = a << 1;

            ALU_RIGHT_SHIFT:
                exp_y = a >> 1;

            ALU_PASS:
                exp_y = a;

            default:
                exp_y = {N{1'bx}};

        endcase

        exp_zero     = (exp_y == 0);
        exp_negative = exp_y[N-1];

    end
    endtask

    //==================================================
    // Checker
    //==================================================
    task check_results;
    begin

        if (y !== exp_y) begin
            $display(
                "Y ERROR: sel=%b a=%b b=%b Expected=%b Got=%b",
                sel, a, b, exp_y, y
            );
            errors = errors + 1;
        end

        if (carry !== exp_carry) begin
            $display(
                "CARRY ERROR: sel=%b a=%b b=%b Expected=%b Got=%b",
                sel, a, b, exp_carry, carry
            );
            errors = errors + 1;
        end

        if (zero !== exp_zero) begin
            $display(
                "ZERO ERROR: sel=%b a=%b b=%b Expected=%b Got=%b",
                sel, a, b, exp_zero, zero
            );
            errors = errors + 1;
        end

        if (negative !== exp_negative) begin
            $display(
                "NEGATIVE ERROR: sel=%b a=%b b=%b Expected=%b Got=%b",
                sel, a, b, exp_negative, negative
            );
            errors = errors + 1;
        end

        if (overflow !== exp_overflow) begin
            $display(
                "OVERFLOW ERROR: sel=%b a=%b b=%b Expected=%b Got=%b",
                sel, a, b, exp_overflow, overflow
            );
            errors = errors + 1;
        end

    end
    endtask

    //==================================================
    // Run One Test
    //==================================================
    task run_test;

        input [N-1:0] test_a;
        input [N-1:0] test_b;
        input [2:0]   test_sel;

    begin

        a   = test_a;
        b   = test_b;
        sel = test_sel;

        compute_expected();

        #1;

        check_results();

    end
    endtask

    //==================================================
    // Test Sequence
    //==================================================
    initial begin

        $display("-------------------------------------");
        $display(" Starting ALU Directed Tests");
        $display("-------------------------------------");

        // ADD
        run_test(4'd3, 4'd2, ALU_ADD);

        // SUB
        run_test(4'd7, 4'd2, ALU_SUB);

        // OR
        run_test(4'b1010, 4'b0101, ALU_OR);

        // AND
        run_test(4'b1010, 4'b1100, ALU_AND);

        // XOR
        run_test(4'b1010, 4'b1100, ALU_XOR);

        // LEFT SHIFT
        run_test(4'b0011, 4'b0000, ALU_LEFT_SHIFT);

        // RIGHT SHIFT
        run_test(4'b1000, 4'b0000, ALU_RIGHT_SHIFT);

        // PASS
        run_test(4'b1110, 4'b0000, ALU_PASS);

        $display("-------------------------------------");
        $display(" Starting Random Tests");
        $display("-------------------------------------");

        repeat(1000) begin
            run_test(
                $random,
                $random,
                $random % 8
            );
        end

        if(errors == 0)
            $display("\nTEST PASSED ✔");

        else
            $display("\nTEST FAILED ❌ Errors = %0d", errors);

        $finish;

    end

    //==================================================
    // Waveform Dump
    //==================================================
    initial begin
        $dumpfile("wave/n_bit_alu_wave.vcd");
        $dumpvars(0, n_bit_alu_tb);
    end

endmodule