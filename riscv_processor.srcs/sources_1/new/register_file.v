// ============================================================
// Module      : register_file
// Description : 8x8 register file - 8 registers each 8 bits wide
//               R0 is hardwired to 0 (RISC-V convention)
// Inputs      : clk, rst, we, rd_addr, rs1_addr, rs2_addr, write_data
// Outputs     : rs1_data, rs2_data
// ============================================================

module register_file (
    input  wire       clk,
    input  wire       rst,
    input  wire       we,
    input  wire [2:0] rd_addr,
    input  wire [2:0] rs1_addr,
    input  wire [2:0] rs2_addr,
    input  wire [7:0] write_data,
    output wire [7:0] rs1_data,
    output wire [7:0] rs2_data
);

    reg [7:0] regs [0:7];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 8'b0;
        end
        else if (we && rd_addr != 3'b000) begin
            regs[rd_addr] <= write_data;
        end
    end

    assign rs1_data = (rs1_addr == 3'b000) ? 8'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 3'b000) ? 8'b0 : regs[rs2_addr];

endmodule