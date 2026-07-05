module n_bit_alu #(parameter N = 4)
(
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  [2:0]   sel,

    output [N-1:0] y,
    output          carry,
    output          overflow,
    output          negative,
    output          zero
);

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
    // Internal Result Wires
    //==================================================
    wire [N:0]   add_result;
    wire [N:0]   sub_result;
    wire [N-1:0] and_result;
    wire [N-1:0] or_result;
    wire [N-1:0] xor_result;
    wire [N-1:0] left_shift;
    wire [N-1:0] right_shift;
    wire [N-1:0] pass_result;

    //==================================================
    // ALU Operations
    //==================================================
    assign add_result   = {1'b0, a} + {1'b0, b};
    assign sub_result   = {1'b0, a} - {1'b0, b};

    assign and_result   = a & b;
    assign or_result    = a | b;
    assign xor_result   = a ^ b;

    assign left_shift   = a << 1;
    assign right_shift  = a >> 1;

    assign pass_result  = a;

    //==================================================
    // Output Multiplexer
    //==================================================
    assign y =
        (sel == ALU_ADD)         ? add_result[N-1:0] :
        (sel == ALU_SUB)         ? sub_result[N-1:0] :
        (sel == ALU_OR)          ? or_result :
        (sel == ALU_AND)         ? and_result :
        (sel == ALU_XOR)         ? xor_result :
        (sel == ALU_LEFT_SHIFT)  ? left_shift :
        (sel == ALU_RIGHT_SHIFT) ? right_shift :
        (sel == ALU_PASS)        ? pass_result :
                                   {N{1'b0}};

    //==================================================
    // Status Flags
    //==================================================
    assign carry =
        (sel == ALU_ADD) ? add_result[N] :
        (sel == ALU_SUB) ? sub_result[N] :
                           1'b0;

    assign zero     = (y == 0);
    assign negative = y[N-1];

    assign overflow =
        (sel == ALU_ADD) ?
            (~(a[N-1] ^ b[N-1])) & (a[N-1] ^ y[N-1]) :

        (sel == ALU_SUB) ?
            ((a[N-1] ^ b[N-1])) & (a[N-1] ^ y[N-1]) :

        1'b0;

endmodule