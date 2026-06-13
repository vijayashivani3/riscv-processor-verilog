// ============================================================
// Module      : control_unit
// Description : FSM-based control unit for 8-bit RISC-V processor
//               Generates all control signals based on opcode
//               4 states: FETCH, DECODE, EXECUTE, WRITEBACK
// Inputs      : clk, rst, opcode (3-bit), zero_flag
// Outputs     : all control signals for every module
// ============================================================

module control_unit (
    input  wire       clk,
    input  wire       rst,
    input  wire [2:0] opcode,      // Top 3 bits of instruction
    input  wire       zero_flag,   // From ALU - used for BEQ

    // Control signals output to other modules
    output reg        pc_enable,   // 1 = increment PC (move to next instruction)
    output reg        reg_write,   // 1 = write result to register file
    output reg        mem_read,    // 1 = read from data memory (LW)
    output reg        mem_write,   // 1 = write to data memory (SW)
    output reg        mem_to_reg,  // 1 = data comes from memory (LW), 0 = from ALU
    output reg  [2:0] alu_op,      // ALU operation select
    output reg        branch_taken,// 1 = BEQ condition is true, take the branch
    output reg  [1:0] current_state// For debugging - shows which state FSM is in
);

    // ---- FSM State Encoding ----
    localparam FETCH     = 2'b00;
    localparam DECODE    = 2'b01;
    localparam EXECUTE   = 2'b10;
    localparam WRITEBACK = 2'b11;

    // ---- Opcode Encoding (matches ISA table) ----
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_LW  = 3'b101;
    localparam OP_SW  = 3'b110;
    localparam OP_BEQ = 3'b111;

    // ---- State register ----
    reg [1:0] state;

    // ---- State transition (sequential) ----
    always @(posedge clk) begin
        if (rst)
            state <= FETCH;       // On reset, always go back to FETCH
        else begin
            case (state)
                FETCH:     state <= DECODE;
                DECODE:    state <= EXECUTE;
                EXECUTE:   state <= WRITEBACK;
                WRITEBACK: state <= FETCH;    // After writeback, fetch next instruction
                default:   state <= FETCH;
            endcase
        end
    end

    // ---- Output logic (combinational - based on current state + opcode) ----
    always @(*) begin
        // Default values - all signals inactive
        // This prevents accidental latches
        pc_enable    = 1'b0;
        reg_write    = 1'b0;
        mem_read     = 1'b0;
        mem_write    = 1'b0;
        mem_to_reg   = 1'b0;
        alu_op       = 3'b000;
        branch_taken = 1'b0;
        current_state = state;

        case (state)

            FETCH: begin
                // Nothing to control here - just waiting for instruction
                // PC will be enabled in WRITEBACK after execution
                pc_enable = 1'b0;
            end

            DECODE: begin
                // Nothing to assert yet - just let the instruction bits
                // propagate to the ALU and register file inputs
                // The opcode is being examined this cycle
            end

            EXECUTE: begin
                // Set ALU operation based on opcode
                case (opcode)
                    OP_ADD: alu_op = 3'b000;  // ALU does ADD
                    OP_SUB: alu_op = 3'b001;  // ALU does SUB
                    OP_AND: alu_op = 3'b010;  // ALU does AND
                    OP_OR:  alu_op = 3'b011;  // ALU does OR
                    OP_XOR: alu_op = 3'b100;  // ALU does XOR
                    OP_LW:  begin
                        mem_read = 1'b1;       // Tell data memory to read
                        alu_op   = 3'b000;     // ALU passes address (ADD with 0)
                    end
                    OP_SW:  begin
                        mem_write = 1'b1;      // Tell data memory to write
                        alu_op    = 3'b000;
                    end
                    OP_BEQ: begin
                        alu_op = 3'b001;       // SUB to check equality (result=0 means equal)
                    end
                    default: alu_op = 3'b000;
                endcase
            end

            WRITEBACK: begin
                pc_enable = 1'b1;   // Move PC to next instruction by default

                case (opcode)
                    OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR: begin
                        reg_write  = 1'b1;    // Write ALU result to register
                        mem_to_reg = 1'b0;    // Data comes from ALU, not memory
                    end
                    OP_LW: begin
                        reg_write  = 1'b1;    // Write memory data to register
                        mem_to_reg = 1'b1;    // Data comes from memory
                    end
                    OP_SW: begin
                        reg_write  = 1'b0;    // Don't write to register
                        mem_write  = 1'b1;    // Write register to memory
                    end
                    OP_BEQ: begin
                        reg_write = 1'b0;     // BEQ never writes to register
                        if (zero_flag) begin
                            branch_taken = 1'b1;  // Branch! (rs1 == rs2)
                            pc_enable    = 1'b0;  // PC will jump, not increment
                        end
                    end
                    default: begin
                        reg_write = 1'b0;
                    end
                endcase
            end

        endcase
    end

endmodule