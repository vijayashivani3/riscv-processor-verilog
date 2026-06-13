// ============================================================
// Module      : ex_stage
// Description : Execute stage
//               Selects ALU operands based on instruction type
//               Instantiates ALU and passes results forward
// Inputs      : rs1_data, rs2_data, imm, opcode, alu_op,
//               mem_read, mem_write
// Outputs     : alu_result, zero_flag, carry_flag, mem_addr
// ============================================================

module ex_stage (
    input  wire [7:0] rs1_data,    // Source register 1 value
    input  wire [7:0] rs2_data,    // Source register 2 value
    input  wire [1:0] imm,         // Immediate from instruction
    input  wire [2:0] opcode,      // Instruction opcode
    input  wire [2:0] alu_op,      // ALU operation from control unit
    input  wire       mem_read,    // 1 if LW instruction
    input  wire       mem_write,   // 1 if SW instruction

    output wire [7:0] alu_result,  // ALU computation result
    output wire       zero_flag,   // ALU zero flag
    output wire       carry_flag,  // ALU carry flag
    output wire [7:0] mem_addr     // Address for data memory access
);

    // Operand B selection:
    // For R-type (ADD/SUB/AND/OR/XOR): B = rs2_data
    // For I-type (LW/SW): B = zero-extended immediate
    // For B-type (BEQ): B = rs2_data (subtract to check equality)

    wire [7:0] operand_b;

    // If mem_read or mem_write: use immediate as address ? B = imm zero-extended
    assign operand_b = (mem_read || mem_write) ? {6'b0, imm} : rs2_data;

    // Instantiate ALU
    alu alu_inst (
        .A(rs1_data),
        .B(operand_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag)
    );

    // Memory address for LW/SW = zero-extended immediate
    assign mem_addr = {6'b0, imm};

endmodule