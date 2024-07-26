// U list-src-files-simul.lst obrisi sve sto je stajalo za verifikaciju i stavi ovo:
// src/simulation/modules/alu.v
// src/simulation/modules/register.v
// src/simulation/top.v

module top; 
    // ZA ALU
    reg [2:0] dut_oc; 
    reg [3:0] dut_a; 
    reg [3:0] dut_b; 
    wire [3:0] dut_f; 

    alu dut_alu(
		.oc(dut_oc),
		.a(dut_a),
		.b(dut_b),
		.f(dut_f)
	);

    // ZA REGISTER
    reg dut_clk;
    reg dut_rst_n;
    reg dut_cl;
    reg dut_ld;
    reg [3:0] dut_in;
    reg dut_inc;
    reg dut_dec;
    reg dut_sr;
    reg dut_ir;
    reg dut_sl;
    reg dut_il;
    wire [3:0] dut_out;

    register dut_register(
        .clk(dut_clk),
        .rst_n(dut_rst_n),
        .cl(dut_cl),
        .ld(dut_ld),
        .in(dut_in),
        .inc(dut_inc),
        .dec(dut_dec),
        .sr(dut_sr),
        .ir(dut_ir),
        .sl(dut_sl),
        .il(dut_il),
        .out(dut_out)
    );

    
    integer i;
    
    initial begin
        // ZA ALU
        for (i = 0; i < 2**11; i = i + 1) begin
            {dut_oc, dut_a, dut_b} = i;
            #5;
        end
        $stop;

        // ZA REGISTER
        dut_cl = 1'b0;
        dut_ld = 1'b0;
        dut_in = 4'h0;
        dut_inc = 1'b0;
        dut_dec = 1'b0;
        dut_sr = 1'b0;
        dut_ir = 1'b0;
        dut_sl = 1'b0;
        dut_il = 1'b0;
        #7 dut_rst_n = 1'b1;
        repeat (1000) begin
            dut_cl = $urandom_range(1);
            dut_ld = $urandom_range(1);
            dut_in = $urandom_range(15);
            dut_inc = $urandom_range(1);
            dut_dec = $urandom_range(1);
            dut_sr = $urandom_range(1);
            dut_ir = $urandom_range(1);
            dut_sl = $urandom_range(1);
            dut_il = $urandom_range(1);
            #10;
        end
        $finish;
    end
    
    // ZA ALU
    initial begin
        $monitor(
			"oc = %b, a = %d, b = %d, f = %d",
			dut_oc, dut_a, dut_b, dut_f
        );
    end
    
    // ZA REGISTER
    initial begin
        dut_rst_n = 1'b0;
        dut_clk = 1'b0;
        forever 
            #5 dut_clk = ~dut_clk;
    end

    always @(dut_out)
        $strobe(
            "time = %4d, cl = %b, ld = %b, in = %d, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, out = %d",
            $time, dut_cl, dut_ld, dut_in, dut_inc, dut_dec, dut_sr, dut_ir, dut_sl, dut_il, dut_out
        );
endmodule
