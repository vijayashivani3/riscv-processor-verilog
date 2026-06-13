// ============================================================
// Module      : instr_mem
// Description : Instruction Memory (ROM) - 256 x 8-bit
//               Stores the program. Read-only during execution.
//               Pre-loaded with 8 test instructions.
// Inputs      : addr (8-bit) - address from Program Counter
// Outputs     : instr (8-bit) - instruction at that address
// ============================================================

module instr_mem (
    input  wire [7:0] addr,   // Address from PC
    output wire [7:0] instr   // Instruction fetched
);

    // Memory array: 256 locations, each 8 bits
    reg [7:0] mem [0:255];

    // Pre-load instructions at startup (simulation only)
    // This represents a program already loaded into ROM
   initial begin
            // CLEAN TEST PROGRAM - designed for our actual ISA encoding
            // R-type: [op:3][rd:3][rs1:2] where rs2_addr = rd_addr (instr[4:2])
            // So for result to be non-trivial, we need rd to already have a value
            //
            // Strategy: LW loads values, then test operations where rd=rs1
            // so both operands come from the same non-zero register
    
            // Instr 0: LW R1, addr0 ? R1 = mem[0] = 25
            // 101_001_00 = 8'b10100100
            mem[0] = 8'b10100100;
            mem[1] = 8'h00; // NOP
            mem[2] = 8'h00; // NOP
    
            // Instr 3: LW R2, addr1 ? R2 = mem[1] = 50
            // 101_010_01 = 8'b10101001
            mem[3] = 8'b10101001;
            mem[4] = 8'h00; // NOP
            mem[5] = 8'h00; // NOP
    
            // Instr 6: LW R3, addr2 ? R3 = mem[2] = 75
            // 101_011_10 = 8'b10101110
            mem[6] = 8'b10101110;
            mem[7] = 8'h00; // NOP
            mem[8] = 8'h00; // NOP
    
            // Instr 9: OR R1, R1 ? R1 = R1|R1 = 25 (rd=001, rs1=01, rs2=rd=R1=25)
            // 011_001_01 = 8'b01100101
            mem[9]  = 8'b01100101;
            mem[10] = 8'h00; // NOP
    
            // Instr 11: AND R2, R2 ? R2 = R2&R2 = 50 (rd=010, rs1=10, rs2=rd=R2=50)
            // 010_010_10 = 8'b01001010
            mem[11] = 8'b01001010;
            mem[12] = 8'h00; // NOP
    
            // Instr 13: XOR R3, R3 ? R3 = R3^R3 = 0 (rd=011, rs1=11, rs2=rd=R3=75)
            // 100_011_11 = 8'b10001111
            mem[13] = 8'b10001111;
            mem[14] = 8'h00; // NOP
    
            // Instr 15: SUB R2, R2 ? R2 = R2-R2 = 0 (rd=010, rs1=10, rs2=rd=R2=50)
            // 001_010_10 = 8'b00101010
            mem[15] = 8'b00101010;
    
            // Fill rest with NOP
            begin : fill_nop
                integer j;
                for (j = 16; j < 256; j = j + 1)
                    mem[j] = 8'h00;
            end
        end
    // Combinational read - output instruction at given address instantly
    assign instr = mem[addr];

endmodule