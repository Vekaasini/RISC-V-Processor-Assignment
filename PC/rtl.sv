module pc #(
    parameter int WIDTH = 32,
    parameter logic [WIDTH-1:0] RESET_ADDR = '0
) (
    input  logic             clk,
    input  logic             rst_n,      // active-low synchronous/asynchronous reset
    input  logic             pc_en,      // tie to 1'b1 for single-cycle if unused
    input  logic [WIDTH-1:0] next_pc,
    output logic [WIDTH-1:0] pc
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= RESET_ADDR;
        end else if (pc_en) begin
            pc <= next_pc;
        end
    end

endmodule
