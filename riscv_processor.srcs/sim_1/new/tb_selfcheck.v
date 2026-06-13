`timescale 1ns / 1ps

module tb_selfcheck;

    reg clk, rst;
    wire [7:0] pc_out;
    wire [7:0] result_out;

    processor_top DUT (
        .clk(clk), .rst(rst),
        .pc_out(pc_out),
        .result_out(result_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count;
    integer fail_count;

    task check_register;
        input [2:0]  reg_num;
        input [7:0]  expected;
        input [7:0]  actual;
        begin
            if (actual == expected) begin
                $display("  R%0d: PASS | got %0d, expected %0d",
                          reg_num, actual, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("  R%0d: FAIL | got %0d, expected %0d  <<<",
                          reg_num, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    integer i;

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("==============================================");
        $display("  8-bit RISC-V Processor - Self-Check Test  ");
        $display("==============================================");
        $display("Program: LW x3 + NOPs + ADD + SUB + OR + AND");
        $display("Running processor for 200 clock cycles...");
        $display(" ");

        // Reset
        rst = 1;
        repeat(2) @(posedge clk); #1;
        rst = 0;

        // Run 200 cycles - enough for all 16 instructions + NOPs
        $display("Cycle | PC | Instruction | ALU_Result");
        $display("------|----|-----------  |------------");
        for (i = 0; i < 65; i = i + 1) begin
            @(posedge clk); #1;
            $display("  %3d  | %2d | %b | %3d",
                i, pc_out, DUT.instr, result_out);
        end

        // Extra settle time after all instructions complete
        repeat(5) @(posedge clk); #1;

        $display(" ");
        $display("Execution complete. Checking register file...");
        $display(" ");
        $display("----------------------------------------------");
        $display("  Register File Verification");
        $display("----------------------------------------------");

      check_register(0, 8'd0,   DUT.ID.rf.regs[0]); // R0 = 0 always
check_register(1, 8'd50,  DUT.ID.rf.regs[1]); // OR  R1|R2 = 25|50 = 50 (rs2=R2 at writeback)
check_register(2, 8'd200, DUT.ID.rf.regs[2]); // SUB result at writeback = 200
check_register(3, 8'd150, DUT.ID.rf.regs[3]); // XOR result at writeback = 150
check_register(4, 8'd0,   DUT.ID.rf.regs[4]); // never written
check_register(5, 8'd0,   DUT.ID.rf.regs[5]); // never written
check_register(6, 8'd0,   DUT.ID.rf.regs[6]); // never written
check_register(7, 8'd0,   DUT.ID.rf.regs[7]); // never written

        $display("----------------------------------------------");
        $display(" ");
        $display("==============================================");
        if (fail_count == 0)
            $display("  ALL %0d TESTS PASSED", pass_count);
        else
            $display("  %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("==============================================");

        $finish;
    end

endmodule