// ============================================================
// Module      : alu
// Description : 8-bit ALU for custom RISC-V processor
// Inputs      : A (8-bit), B (8-bit), alu_op (3-bit)
// Outputs     : result (8-bit), zero_flag (1-bit), carry_flag (1-bit)
// Operations  : ADD=000, SUB=001, AND=010, OR=011, XOR=100
// ============================================================

module alu (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [2:0] alu_op,
    output reg  [7:0] result,
    output wire       zero_flag,
    output wire       carry_flag
);

    reg [8:0] temp;

    always @(*) begin
        temp = 9'b0;
        case (alu_op)
            3'b000: temp = {1'b0, A} + {1'b0, B};  // ADD
            3'b001: temp = {1'b0, A} - {1'b0, B};  // SUB
            3'b010: temp = {1'b0, A  & B};          // AND
            3'b011: temp = {1'b0, A  | B};          // OR
            3'b100: temp = {1'b0, A  ^ B};          // XOR
            default: temp = 9'b0;
        endcase
        result = temp[7:0];
    end

    assign zero_flag  = (result == 8'b0) ? 1'b1 : 1'b0;
    assign carry_flag = temp[8];

endmodule