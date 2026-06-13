// ============================================================
// Module      : tb_alu_regfile
// Description : Self-checking testbench for ALU and Register File
//               Automatically prints PASS or FAIL for each test
// ============================================================

`timescale 1ns / 1ps   // 1ns time unit, 1ps resolution

module tb_alu_regfile;

    // ---- ALU signals ----
    reg  [7:0] A, B;
    reg  [2:0] alu_op;
    wire [7:0] result;
    wire       zero_flag, carry_flag;

    // ---- Register file signals ----
    reg        clk, rst, we;
    reg  [2:0] rd_addr, rs1_addr, rs2_addr;
    reg  [7:0] write_data;
    wire [7:0] rs1_data, rs2_data;

    // ---- Instantiate ALU ----
    alu uut_alu (
        .A(A), .B(B), .alu_op(alu_op),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag)
    );

    // ---- Instantiate Register File ----
    register_file uut_rf (
        .clk(clk), .rst(rst), .we(we),
        .rd_addr(rd_addr),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr),
        .write_data(write_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    // ---- Clock generation: toggles every 5ns ? 100MHz clock ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Test task: checks result and prints PASS/FAIL ----
    task check_alu;
        input [7:0] expected;
        input [7:0] a_in, b_in;
        input [2:0] op;
        input [63:0] test_num;
        begin
            A = a_in; B = b_in; alu_op = op;
            #10; // wait for combinational logic to settle
            if (result == expected)
                $display("ALU Test %0d: PASS | A=%0d B=%0d op=%b result=%0d",
                          test_num, a_in, b_in, op, result);
            else
                $display("ALU Test %0d: FAIL | A=%0d B=%0d op=%b result=%0d expected=%0d",
                          test_num, a_in, b_in, op, result, expected);
        end
    endtask

    // ---- Main test sequence ----
    initial begin
        $display("===== ALU TESTS =====");

        // Test 1: ADD 10 + 20 = 30
        check_alu(8'd30,  8'd10,  8'd20,  3'b000, 1);

        // Test 2: SUB 50 - 30 = 20
        check_alu(8'd20,  8'd50,  8'd30,  3'b001, 2);

        // Test 3: AND 0xFF & 0x0F = 0x0F
        check_alu(8'h0F,  8'hFF,  8'h0F,  3'b010, 3);

        // Test 4: OR 0xF0 | 0x0F = 0xFF
        check_alu(8'hFF,  8'hF0,  8'h0F,  3'b011, 4);

        // Test 5: XOR 0xFF ^ 0xFF = 0x00 (also checks zero_flag)
        check_alu(8'h00,  8'hFF,  8'hFF,  3'b100, 5);
        #10;
        if (zero_flag == 1'b1)
            $display("ALU Test 6: PASS | zero_flag correct for result=0");
        else
            $display("ALU Test 6: FAIL | zero_flag should be 1 when result=0");

        // Test 6: ADD 200 + 100 = 300 ? 8-bit result = 44, carry = 1
        check_alu(8'd44, 8'd200, 8'd100, 3'b000, 7);
        #10;
        if (carry_flag == 1'b1)
            $display("ALU Test 8: PASS | carry_flag correct for overflow");
        else
            $display("ALU Test 8: FAIL | carry_flag should be 1 for 200+100");

        $display(" ");
        $display("===== REGISTER FILE TESTS =====");

        // Reset register file
        rst = 1; we = 0;
        rd_addr = 0; rs1_addr = 0; rs2_addr = 0; write_data = 0;
        @(posedge clk); #1;
        rst = 0;

        // Write 42 into R1
        we = 1; rd_addr = 3'd1; write_data = 8'd42;
        @(posedge clk); #1;

        // Write 99 into R2
        rd_addr = 3'd2; write_data = 8'd99;
        @(posedge clk); #1;
        we = 0;

        // Read R1 and R2 simultaneously
        rs1_addr = 3'd1; rs2_addr = 3'd2;
        #5;
        if (rs1_data == 8'd42)
            $display("RF Test 1: PASS | R1 = %0d (expected 42)", rs1_data);
        else
            $display("RF Test 1: FAIL | R1 = %0d (expected 42)", rs1_data);

        if (rs2_data == 8'd99)
            $display("RF Test 2: PASS | R2 = %0d (expected 99)", rs2_data);
        else
            $display("RF Test 2: FAIL | R2 = %0d (expected 99)", rs2_data);

        // Try to write to R0 - should stay 0
        we = 1; rd_addr = 3'd0; write_data = 8'd55;
        @(posedge clk); #1;
        we = 0;
        rs1_addr = 3'd0;
        #5;
        if (rs1_data == 8'd0)
            $display("RF Test 3: PASS | R0 = 0 (write to R0 correctly ignored)");
        else
            $display("RF Test 3: FAIL | R0 = %0d (should always be 0)", rs1_data);

        $display(" ");
        $display("===== ALL TESTS COMPLETE =====");
        $finish;
    end

endmodule