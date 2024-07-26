// Usporava clk 50_000_000 puta. Zamisli lakse da treba da duplo usporis clk umesto 50 miliona puta:
//  __    __              ____
// |  |__|  |__    -->   |    |_____
//
// Dakle kad detektujes n/2 rising-edge originalnog clk, onda negiras izlaznu vrednost da bi ona predstavljala n puta usporen clk.

module clk_div #(
    parameter DIVISOR = 50_000_000
)(
    input clk,
    input rst_n,
    output out
);

reg out_next, out_reg;
integer timer_next, timer_reg;
assign out = out_reg;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        out_reg <= 1'b0;
        timer_reg <= 0;
    end
    else begin
        out_reg <= out_next;
        timer_reg <= timer_next;
    end
end

always @(*) begin
    out_next = out_reg;
    timer_next = timer_reg;
    
    if (timer_reg == (DIVISOR / 2)) begin
        out_next = ~out_reg;
        timer_next = 0;
    end
    else begin
        // out_next = out_reg;          // Nije neophodno, uradio si na pocetku always bloka.
        timer_next = timer_reg + 1;
    end
end

endmodule