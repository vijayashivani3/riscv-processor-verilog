// ============================================================
// Module      : id_stage
// Description : Instruction Decode stage
//               Splits 8-bit instruction into fields
//               Reads source register values from register file
// Inputs      : instr (8-bit), clk, rst, reg_write, rd_addr_wb,
//               write_data_wb (these 3 are the writeback path)
// Outputs     : opcode, rd_addr, rs1_data, rs2_data, imm
// ============================================================

module id_stage (
    input  wire [7:0] instr,         // Raw instruction from IF stage
    input  wire       clk,
    input  wire       rst,

    // Writeback inputs (from WB stage - closes the pipeline loop)
    input  wire       reg_write,     // Write enable from WB stage
    input  wire [2:0] rd_addr_wb,    // Destination register from WB
    input  wire [7:0] write_data_wb, // Data to write from WB

    // Decoded outputs
    output wire [2:0] opcode,        // Instruction type
    output wire [2:0] rd_addr,       // Destination register (rd)
    output wire [1:0] imm,           // Immediate value (for LW/SW/BEQ)
    output wire [7:0] rs1_data,      // Value of source register 1
    output wire [7:0] rs2_data       // Value of source register 2
);

    // ---- Instruction field extraction ----
    // Our 8-bit instruction format:
    // R-type: [7:5]=opcode [4:2]=rd  [1:0]=rs1 (rs2 = rd for simplicity)
    // I-type: [7:5]=opcode [4:2]=rd  [1:0]=imm
    // B-type: [7:5]=opcode [4:2]=rs1 [1:0]=offset

    assign opcode  = instr[7:5];   // Top 3 bits
    assign rd_addr = instr[4:2];   // Middle 3 bits
    assign imm     = instr[1:0];   // Bottom 2 bits

    // rs1 address: for R-type = bottom 2 bits zero-extended to 3
    // For simplicity: rs1_addr = {1'b0, instr[1:0]}
    wire [2:0] rs1_addr = {1'b0, instr[1:0]};
    // rs2 address: use rd_addr as second source for R-type operations
    wire [2:0] rs2_addr = instr[4:2];

    // ---- Register file instance ----
    register_file rf (
        .clk(clk),
        .rst(rst),
        .we(reg_write),
        .rd_addr(rd_addr_wb),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .write_data(write_data_wb),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

endmodule