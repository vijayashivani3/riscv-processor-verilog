// ============================================================
// Module      : processor_top
// Description : Top-level 8-bit RISC-V processor
//               Connects all pipeline stages and support modules
//               Pipeline: IF ? ID ? EX ? WB
//               ISA: ADD, SUB, AND, OR, XOR, LW, SW, BEQ
// Inputs      : clk, rst
// Outputs     : pc (for observation), result_out (for testbench)
// ============================================================

module processor_top (
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] pc_out,       // Current PC - for waveform viewing
    output wire [7:0] result_out    // ALU result - for testbench checking
);

    // ============================================================
    // INTERNAL WIRES - connecting all modules together
    // ============================================================

    // IF stage outputs
    wire [7:0] pc;            // Current program counter
    wire [7:0] instr;         // Fetched instruction

    // ID stage outputs
    wire [2:0] opcode;        // Instruction opcode
    wire [2:0] rd_addr;       // Destination register address
    wire [1:0] imm;           // Immediate value
    wire [7:0] rs1_data;      // Source register 1 value
    wire [7:0] rs2_data;      // Source register 2 value

    // Control unit outputs
    wire        pc_enable;    // 1 = increment PC
    wire        reg_write;    // 1 = write to register file
    wire        mem_read;     // 1 = read from data memory
    wire        mem_write;    // 1 = write to data memory
    wire        mem_to_reg;   // 1 = writeback from memory
    wire [2:0]  alu_op;       // ALU operation select
    wire        branch_taken; // 1 = BEQ branch condition met
    wire [1:0]  cu_state;     // FSM state (for debugging)

    // EX stage outputs
    wire [7:0] alu_result;    // ALU computation result
    wire       zero_flag;     // ALU zero flag
    wire       carry_flag;    // ALU carry flag
    wire [7:0] mem_addr;      // Data memory address

    // Data memory output
    wire [7:0] mem_read_data; // Data read from memory (for LW)

    // WB stage output
    wire [7:0] write_data;    // Data to write back to register file

    // ============================================================
    // MODULE INSTANTIATIONS
    // ============================================================

    // 1. IF Stage - Instruction Fetch (contains instr_mem inside)
    if_stage IF (
        .clk(clk),
        .rst(rst),
        .pc_enable(pc_enable),
        .branch_taken(branch_taken),
        .branch_offset(imm),
        .pc(pc),
        .instr(instr)
    );

    // 2. ID Stage - Instruction Decode (contains register_file inside)
    id_stage ID (
        .instr(instr),
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rd_addr_wb(rd_addr),
        .write_data_wb(write_data),
        .opcode(opcode),
        .rd_addr(rd_addr),
        .imm(imm),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 3. Control Unit - FSM generating all control signals
    control_unit CU (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .zero_flag(zero_flag),
        .pc_enable(pc_enable),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .branch_taken(branch_taken),
        .current_state(cu_state)
    );

    // 4. EX Stage - Execute (contains ALU inside)
    ex_stage EX (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .opcode(opcode),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .mem_addr(mem_addr)
    );

    // 5. Data Memory - separate from instruction memory
    data_mem DMEM (
        .clk(clk),
        .we(mem_write),
        .addr(mem_addr),
        .write_data(rs1_data),
        .read_data(mem_read_data)
    );

    // 6. WB Stage - Write Back
    wb_stage WB (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .mem_to_reg(mem_to_reg),
        .write_data(write_data)
    );

    // ============================================================
    // OUTPUT ASSIGNMENTS
    // ============================================================
    assign pc_out     = pc;
    assign result_out = alu_result;

endmodule