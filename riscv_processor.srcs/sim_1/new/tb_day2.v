// ============================================================
// Module      : tb_day2
// Description : Testbench for instr_mem, data_mem, control_unit
// ============================================================

`timescale 1ns / 1ps

module tb_day2;

    // ---- Clock ----
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;

    // =====================
    // TEST 1: INSTRUCTION MEMORY
    // =====================
    reg  [7:0] addr_im;
    wire [7:0] instr_out;

    instr_mem uut_im (
        .addr(addr_im),
        .instr(instr_out)
    );

    // =====================
    // TEST 2: DATA MEMORY
    // =====================
    reg        we_dm;
    reg  [7:0] addr_dm, wdata_dm;
    wire [7:0] rdata_dm;

    data_mem uut_dm (
        .clk(clk),
        .we(we_dm),
        .addr(addr_dm),
        .write_data(wdata_dm),
        .read_data(rdata_dm)
    );

    // =====================
    // TEST 3: CONTROL UNIT
    // =====================
    reg  [2:0] opcode_cu;
    reg        zero_flag_cu;
    wire       pc_en, reg_wr, mem_rd, mem_wr, mem2reg, branch;
    wire [2:0] alu_op_cu;
    wire [1:0] cu_state;

    control_unit uut_cu (
        .clk(clk), .rst(rst),
        .opcode(opcode_cu),
        .zero_flag(zero_flag_cu),
        .pc_enable(pc_en),
        .reg_write(reg_wr),
        .mem_read(mem_rd),
        .mem_write(mem_wr),
        .mem_to_reg(mem2reg),
        .alu_op(alu_op_cu),
        .branch_taken(branch),
        .current_state(cu_state)
    );

    initial begin

        $display("===== INSTRUCTION MEMORY TESTS =====");
        // Read instruction at address 0 - should be 8'b00000100
        addr_im = 8'd0; #10;
        if (instr_out == 8'b00000100)
            $display("IM Test 1: PASS | addr=0 instr=%b (expected 00000100)", instr_out);
        else
            $display("IM Test 1: FAIL | addr=0 instr=%b (expected 00000100)", instr_out);

        // Read instruction at address 1 - should be 8'b00001000
        addr_im = 8'd1; #10;
        if (instr_out == 8'b00001000)
            $display("IM Test 2: PASS | addr=1 instr=%b (expected 00001000)", instr_out);
        else
            $display("IM Test 2: FAIL | addr=1 instr=%b (expected 00001000)", instr_out);

        // Read instruction at address 6 - LW instruction
        addr_im = 8'd6; #10;
        $display("IM Test 3: INFO | addr=6 instr=%b (LW instruction)", instr_out);

        $display(" ");
        $display("===== DATA MEMORY TESTS =====");

        // Read pre-loaded value at address 0 (should be 25)
        we_dm = 0; addr_dm = 8'd0; wdata_dm = 8'd0; #10;
        if (rdata_dm == 8'd25)
            $display("DM Test 1: PASS | Read addr=0 got %0d (expected 25)", rdata_dm);
        else
            $display("DM Test 1: FAIL | Read addr=0 got %0d (expected 25)", rdata_dm);

        // Write 123 to address 5
        we_dm = 1; addr_dm = 8'd5; wdata_dm = 8'd123;
        @(posedge clk); #1;
        we_dm = 0;

        // Read back from address 5
        addr_dm = 8'd5; #10;
        if (rdata_dm == 8'd123)
            $display("DM Test 2: PASS | Write then read addr=5 got %0d (expected 123)", rdata_dm);
        else
            $display("DM Test 2: FAIL | Write then read addr=5 got %0d (expected 123)", rdata_dm);

        $display(" ");
        $display("===== CONTROL UNIT FSM TESTS =====");

        // Reset FSM
        rst = 1; opcode_cu = 3'b000; zero_flag_cu = 0;
        @(posedge clk); #1;
        rst = 0;
        $display("CU State after reset: %0d (expected 0=FETCH)", cu_state);

        // Give ADD opcode - cycle through all 4 states
        opcode_cu = 3'b000; // ADD
        @(posedge clk); #1; $display("CU State: %0d (expected 1=DECODE)", cu_state);
        @(posedge clk); #1; $display("CU State: %0d (expected 2=EXECUTE) | alu_op=%b (expected 000)", cu_state, alu_op_cu);
        @(posedge clk); #1; $display("CU State: %0d (expected 3=WRITEBACK) | reg_write=%b (expected 1)", cu_state, reg_wr);
        @(posedge clk); #1; $display("CU State: %0d (expected 0=FETCH again)", cu_state);

        // Test LW opcode - should set mem_read in EXECUTE
        opcode_cu = 3'b101; // LW
        @(posedge clk); #1; // DECODE
        @(posedge clk); #1; // EXECUTE
        $display("CU LW Test: mem_read=%b (expected 1 in EXECUTE state)", mem_rd);

        // Test BEQ with zero_flag=1 - should set branch_taken
        opcode_cu = 3'b111; // BEQ
        zero_flag_cu = 1;
        @(posedge clk); #1; // WRITEBACK
        $display("CU BEQ Test: branch_taken=%b (expected 1 when zero_flag=1)", branch);

        $display(" ");
        $display("===== DAY 2 ALL TESTS COMPLETE =====");
        $finish;
    end

endmodule