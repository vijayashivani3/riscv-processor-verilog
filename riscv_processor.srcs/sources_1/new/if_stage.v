// ============================================================
// Module      : if_stage
// Description : Instruction Fetch stage
//               Holds Program Counter (PC)
//               Fetches instruction from instruction memory
//               Updates PC on each clock cycle
// Inputs      : clk, rst, pc_enable, branch_taken, branch_offset
// Outputs     : pc (current address), instr (fetched instruction)
// ============================================================

module if_stage (
    input  wire       clk,
    input  wire       rst,
    input  wire       pc_enable,      // From control unit - 1 = advance PC
    input  wire       branch_taken,   // From control unit - 1 = take branch
    input  wire [1:0] branch_offset,  // From instruction - branch jump distance
    output reg  [7:0] pc,             // Current program counter value
    output wire [7:0] instr           // Fetched instruction
);

    // Instantiate instruction memory inside IF stage
    instr_mem imem (
        .addr(pc),
        .instr(instr)
    );

    // PC update logic - sequential
    always @(posedge clk) begin
        if (rst) begin
            pc <= 8'b0;   // Reset PC to address 0
        end
        else if (branch_taken) begin
            // Branch: jump PC by the signed offset
            // offset is 2-bit, sign-extend to 8-bit
            pc <= pc + {{6{branch_offset[1]}}, branch_offset};
        end
        else if (pc_enable) begin
            pc <= pc + 8'd1;   // Normal: advance to next instruction
        end
        // If neither branch nor enable: PC holds its value (stall)
    end

endmodule