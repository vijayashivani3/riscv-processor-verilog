// ============================================================
// Module      : data_mem
// Description : Data Memory (RAM) - 256 x 8-bit
//               Supports synchronous write (SW instruction)
//               and combinational read (LW instruction)
// Inputs      : clk, we (write enable), addr, write_data
// Outputs     : read_data
// ============================================================

module data_mem (
    input  wire       clk,
    input  wire       we,          // Write enable: 1=write, 0=read
    input  wire [7:0] addr,        // Memory address
    input  wire [7:0] write_data,  // Data to write (for SW)
    output wire [7:0] read_data    // Data read out (for LW)
);

    // Memory array: 256 locations, each 8 bits
    reg [7:0] mem [0:255];

    integer i;

    // Initialize all memory to 0 at start
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 8'b0;
        // Pre-load some values for LW testing
        mem[0] = 8'd25;   // address 0 holds value 25
        mem[1] = 8'd50;   // address 1 holds value 50
        mem[2] = 8'd75;   // address 2 holds value 75
    end

    // Synchronous write - happens on rising clock edge when we=1
    always @(posedge clk) begin
        if (we)
            mem[addr] <= write_data;
    end

    // Combinational read - output is available immediately
    assign read_data = mem[addr];

endmodule