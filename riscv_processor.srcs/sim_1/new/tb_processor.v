// ============================================================
// Module      : tb_processor
// Description : Full system testbench for 8-bit RISC-V processor
//               Runs complete processor for 100 clock cycles
//               Monitors PC, instruction, ALU result, FSM state
// ============================================================

`timescale 1ns / 1ps

module tb_processor;

    // Inputs to processor
    reg clk, rst;

    // Outputs from processor
    wire [7:0] pc_out;
    wire [7:0] result_out;

    // Instantiate the complete processor
    processor_top DUT (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .result_out(result_out)
    );

    // Clock: 10ns period = 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Integer for loop
    integer i;

    initial begin
        $display("============================================");
        $display("  8-bit RISC-V Processor Simulation Start");
        $display("============================================");

        // Apply reset for 2 clock cycles
        rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        $display("Reset released. Processor starting...");
        $display(" ");
        $display("Cycle | PC  | Instr    | ALU_Result | State");
        $display("------|-----|----------|------------|------");

        // Run for 80 clock cycles and monitor each cycle
        for (i = 0; i < 80; i = i + 1) begin
            @(posedge clk); #1;
            $display("  %3d  | %3d | %b | %8d   |  %0d",
                i,
                pc_out,
                DUT.instr,
                result_out,
                DUT.cu_state
            );
        end

        $display(" ");
        $display("============================================");
        $display("  Simulation Complete");
        $display("============================================");
        $finish;
    end

endmodule