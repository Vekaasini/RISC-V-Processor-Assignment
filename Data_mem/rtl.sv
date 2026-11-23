module data_memory #(
    parameter int DEPTH = 256            // number of 32-bit words
) (
    input  logic        clk,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [2:0]  funct3,         // 000: lb/sb, 001: lh/sh, 010: lw/sw, 100: lbu, 101: lhu
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    localparam int ADDR_BITS = $clog2(DEPTH);
    logic [31:0] mem [0:DEPTH-1];

    logic [ADDR_BITS-1:0] word_idx;
    logic [1:0]           byte_offset;
    logic [31:0]          word_val;

    assign word_idx    = addr[ADDR_BITS+1:2];
    assign byte_offset = addr[1:0];
    assign word_val    = mem[word_idx];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            unique case (funct3[1:0])
                2'b00: begin // SB (byte)
                    unique case (byte_offset)
                        2'd0: mem[word_idx][7:0]   <= write_data[7:0];
                        2'd1: mem[word_idx][15:8]  <= write_data[7:0];
                        2'd2: mem[word_idx][23:16] <= write_data[7:0];
                        2'd3: mem[word_idx][31:24] <= write_data[7:0];
                    endcase
                end
                2'b01: begin // SH (half-word)
                    if (byte_offset[1] == 1'b0)
                        mem[word_idx][15:0]  <= write_data[15:0];
                    else
                        mem[word_idx][31:16] <= write_data[15:0];
                end
                2'b10: begin // SW (word)
                    mem[word_idx] <= write_data;
                end
                default: mem[word_idx] <= write_data;
            endcase
        end
    end

    // Combinational read
    always_comb begin
        read_data = 32'b0;
        if (mem_read) begin
            unique case (funct3)
                3'b000: begin // LB (signed byte)
                    logic [7:0] b;
                    unique case (byte_offset)
                        2'd0: b = word_val[7:0];
                        2'd1: b = word_val[15:8];
                        2'd2: b = word_val[23:16];
                        2'd3: b = word_val[31:24];
                    endcase
                    read_data = {{24{b[7]}}, b};
                end
                3'b001: begin // LH (signed half-word)
                    logic [15:0] h;
                    h = (byte_offset[1] == 1'b0) ? word_val[15:0] : word_val[31:16];
                    read_data = {{16{h[15]}}, h};
                end
                3'b010: begin // LW (word)
                    read_data = word_val;
                end
                3'b100: begin // LBU (unsigned byte)
                    logic [7:0] b;
                    unique case (byte_offset)
                        2'd0: b = word_val[7:0];
                        2'd1: b = word_val[15:8];
                        2'd2: b = word_val[23:16];
                        2'd3: b = word_val[31:24];
                    endcase
                    read_data = {24'b0, b};
                end
                3'b101: begin // LHU (unsigned half-word)
                    logic [15:0] h;
                    h = (byte_offset[1] == 1'b0) ? word_val[15:0] : word_val[31:16];
                    read_data = {16'b0, h};
                end
                default: read_data = word_val;
            endcase
        end
    end

endmodule
