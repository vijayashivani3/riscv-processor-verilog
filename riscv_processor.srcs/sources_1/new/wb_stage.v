// ============================================================
// Module      : wb_stage
// Description : Write-Back stage
//               Selects what data goes back to register file
//               For ALU instructions: write ALU result
//               For LW: write data from memory
//               For SW/BEQ: no register write
// Inputs      : alu_result, mem_data, mem_to_reg
// Outputs     : write_data (goes to register file via ID stage)
// ============================================================

module wb_stage (
    input  wire [7:0] alu_result,  // Result from EX stage ALU
    input  wire [7:0] mem_data,    // Data read from data memory (for LW)
    input  wire       mem_to_reg,  // 1 = write mem data, 0 = write ALU result

    output wire [7:0] write_data   // Final data to write to register file
);

    // Multiplexer: select between ALU result and memory data
    assign write_data = mem_to_reg ? mem_data : alu_result;

endmodule