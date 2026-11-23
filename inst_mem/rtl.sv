module instruction_memory #(
    parameter int DEPTH = 256,           // number of 32-bit words
    parameter string MEM_FILE = ""       // optional hex file path
) (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    localparam int ADDR_BITS = $clog2(DEPTH);
    logic [31:0] mem [0:DEPTH-1];

    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            mem[i] = 32'h0000_0013; // NOP (addi x0, x0, 0)
        end
        if (MEM_FILE != "") begin
            $readmemh(MEM_FILE, mem);
        end
    end

    // Word-aligned addressing (ignore lower 2 bits)
    always_comb begin
        logic [ADDR_BITS-1:0] word_idx;
        word_idx = addr[ADDR_BITS+1:2];
        instr = mem[word_idx];
    end

endmodule
