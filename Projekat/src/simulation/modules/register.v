module register (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [3:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [3:0] out
);

reg [3:0] out_next, out_reg;
assign out = out_reg;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        out_reg <= 4'h0;
    end
    else begin
        out_reg <= out_next;
    end
end

always @(*) begin
    out_next = out_reg;

    if (cl) begin
        out_next = 4'h0;
    end
    else if (ld) begin
        out_next = in;
    end
    else if (inc) begin
        out_next = out_reg + 1'b1;
    end
    else if (dec) begin
        out_next = out_reg - 1'b1;
    end
    else if (sr) begin
        out_next = out_reg >> 1'b1;
        out_next[3] = ir;
    end
    else if (sl) begin
        out_next = out_reg << 1'b1;
        out_next[0] = il;
    end
end

endmodule
