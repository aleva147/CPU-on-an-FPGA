module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);


reg [2:0] alu_oc;
reg [15:0] alu_a, alu_b;
wire [15:0] alu_f;

alu #(.DATA_WIDTH(16)) alu_inst (
    .oc(alu_oc),
    .a(alu_a),
    .b(alu_b),
    .f(alu_f)
);


reg pc_cl, pc_ld, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il;
reg [5:0] pc_in;
wire [5:0] pc_out;

register #(.DATA_WIDTH(6)) pc_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(pc_cl),
    .ld(pc_ld),
    .in(pc_in),
    .inc(pc_inc),
    .dec(pc_dec),
    .sr(pc_sr),
    .ir(pc_ir),
    .sl(pc_sl),
    .il(pc_il),
    .out(pc_out)
);

reg sp_cl, sp_ld, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il;
reg [5:0] sp_in;
wire [5:0] sp_out;

register #(.DATA_WIDTH(6)) sp_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(sp_cl),
    .ld(sp_ld),
    .in(sp_in),
    .inc(sp_inc),
    .dec(sp_dec),
    .sr(sp_sr),
    .ir(sp_ir),
    .sl(sp_sl),
    .il(sp_il),
    .out(sp_out)
);

reg ir_high_cl, ir_high_ld, ir_high_inc, ir_high_dec, ir_high_sr, ir_high_ir, ir_high_sl, ir_high_il;
reg [15:0] ir_high_in;
wire [15:0] ir_high_out;

register #(.DATA_WIDTH(16)) ir_high_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(ir_high_cl),
    .ld(ir_high_ld),
    .in(mem_in),
    .inc(ir_high_inc),
    .dec(ir_high_dec),
    .sr(ir_high_sr),
    .ir(ir_high_ir),
    .sl(ir_high_sl),
    .il(ir_high_il),
    .out(ir_high_out)
);

reg ir_low_cl, ir_low_ld, ir_low_inc, ir_low_dec, ir_low_sr, ir_low_ir, ir_low_sl, ir_low_il;
reg [15:0] ir_low_in;
wire [15:0] ir_low_out;

register #(.DATA_WIDTH(16)) ir_low_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(ir_low_cl),
    .ld(ir_low_ld),
    .in(mem_in),
    .inc(ir_low_inc),
    .dec(ir_low_dec),
    .sr(ir_low_sr),
    .ir(ir_low_ir),
    .sl(ir_low_sl),
    .il(ir_low_il),
    .out(ir_low_out)
);

reg acc_cl, acc_ld, acc_inc, acc_dec, acc_sr, acc_ir, acc_sl, acc_il;
reg [15:0] acc_in;
wire [15:0] acc_out;

register #(.DATA_WIDTH(16)) acc_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(acc_cl),
    .ld(acc_ld),
    .in(acc_in),
    .inc(acc_inc),
    .dec(acc_dec),
    .sr(acc_sr),
    .ir(acc_ir),
    .sl(acc_sl),
    .il(acc_il),
    .out(acc_out)
);




reg [DATA_WIDTH-1:0] out_next, out_reg;
assign out = out_reg;
assign pc = pc_out;
assign sp = sp_out;

localparam state_initialize_regs = 4'd0;     // Todo: stavi odgovarajucu sirinu kad budes znao konacan br stanja
localparam state_fetch_firstW = 4'd1;
localparam state_fetch_firstW_2 = 4'd2;
localparam state_recognize_code = 4'd3;
localparam state_fetch_first_op_indirect = 4'd4;
localparam state_fetch_second_op_indirect = 4'd5;
localparam state_fetch_third_op_indirect = 4'd6;
localparam state_first_op_fetched = 4'd7;
localparam state_second_op_fetched = 4'd8;
localparam state_third_op_fetched = 4'd9;
localparam state_fetch_secondW = 4'd10;
localparam state_secondW_fetched = 4'd11;
localparam state_stopped = 4'd12;
reg [3:0] state_next, state_reg;            // Todo: stavi odgovarajucu sirinu kad budes znao konacan br stanja



always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        out_reg <= {DATA_WIDTH{1'b0}};
        state_reg <= state_initialize_regs;
    end
    else begin
        out_reg <= out_next;
        state_reg <= state_next;
    end
end


always @(*) begin
    out_next = out_reg;
    state_next = state_reg;

    pc_cl = 1'b0; pc_ld = 1'b0; pc_inc = 1'b0; pc_dec = 1'b0; pc_sr = 1'b0; pc_ir = 1'b0; pc_sl = 1'b0; pc_il = 1'b0; pc_in = 6'd0;
    sp_cl = 1'b0; sp_ld = 1'b0; sp_inc = 1'b0; sp_dec = 1'b0; sp_sr = 1'b0; sp_ir = 1'b0; sp_sl = 1'b0; sp_il = 1'b0; sp_in = 6'd0;
    ir_high_cl = 1'b0; ir_high_ld = 1'b0; ir_high_inc = 1'b0; ir_high_dec = 1'b0; ir_high_sr = 1'b0; ir_high_ir = 1'b0; ir_high_sl = 1'b0; ir_high_il = 1'b0; ir_high_in = 16'd0;
    ir_low_cl = 1'b0; ir_low_ld = 1'b0; ir_low_inc = 1'b0; ir_low_dec = 1'b0; ir_low_sr = 1'b0; ir_low_ir = 1'b0; ir_low_sl = 1'b0; ir_low_il = 1'b0; ir_low_in = 16'd0;
    acc_cl = 1'b0; acc_ld = 1'b0; acc_inc = 1'b0; acc_dec = 1'b0; acc_sr = 1'b0; acc_ir = 1'b0; acc_sl = 1'b0; acc_il = 1'b0; acc_in = 16'd0;
    
    alu_oc = 3'd0; alu_a = 16'd0; alu_b = 16'd0;

    mem_we = 1'b0; mem_addr = 6'd0; mem_data = 16'd0;   // PROVERI: Trebalo mi je ovo da ne bih imao latch, ali nisam siguran da li moze praviti problem.


    case (state_reg)
        // Moglo unutar always za !rst_n pa da prvo stanje bude odmah state_fetch_firstW
        state_initialize_regs: begin
            pc_in = 6'd8;
            pc_ld = 1'b1;
            sp_in = 6'd63;
            sp_ld = 1'b1;

            state_next = state_fetch_firstW;
        end



        // Zadaj memoriji da procita 16b sa adr = PC
        state_fetch_firstW: begin
            mem_addr = pc_out;  
            mem_we = 1'b0;   
            pc_inc = 1'b1;        

            state_next = state_fetch_firstW_2;
        end

        // Memorija je procitala sa adr = PC i procitan rezultat se nalazi na mem_in  (ir_high_in je direktno vezan na mem_in)
        state_fetch_firstW_2: begin
            ir_high_ld = 1'b1;

            state_next = state_recognize_code;
        end
        


        state_recognize_code: begin
            case (ir_high_out[15:12])
                // MOV
                4'b0000: begin
                    // Podatak sa adr 2. op -> adr 1. op
                    if (ir_high_out[3:0] == 4'b0000) begin
                        // Zadaj memoriji da procita sa adrese drugog operanda
                        mem_addr = ir_high_out[6:4];
                        mem_we = 1'b0;

                        if (ir_high_out[7] == 1'b1) begin
                            state_next = state_fetch_second_op_indirect;
                        end
                        else begin
                            state_next = state_second_op_fetched;
                        end
                    end
                    // Konst (2. rec instr) -> adr 1. op
                    else if (ir_high_out[3:0] == 4'b1000) begin
                        // Zadaj memoriji da procita drugi bajt instrukcije
                        mem_addr = pc_out;
                        mem_we = 1'b0;
                        pc_inc = 1'b1;

                        state_next = state_fetch_secondW;
                    end
                end

                // IN
                4'b0111: begin
                    // Ako je 1. op indirektno adresiran, treba procitati adresu sa njegove adrese pa na nju staviti podatak sa standardnog ulaza
                    if (ir_high_out[11] == 1'b1) begin
                        // Zadaj memoriji da procita sa adrese prvog operanda
                        mem_addr = ir_high_out[10:8];
                        mem_we = 1'b0;

                        state_next = state_first_op_fetched;
                    end
                    // U suprotnom, ucitava podatak sa standardnog ulaza na adresu 1. op
                    else begin
                        mem_addr = ir_high_out[10:8];
                        mem_data = in;
                        mem_we = 1'b1;

                        state_next = state_fetch_firstW;
                    end
                end

                // OUT
                4'b1000: begin
                    // Zadaj memoriji da procita sa adrese prvog operanda
                    mem_addr = ir_high_out[10:8];
                    mem_we = 1'b0;

                    if (ir_high_out[11] == 1'b1) begin
                        state_next = state_fetch_first_op_indirect;
                    end
                    else begin
                        state_next = state_first_op_fetched;
                    end
                end

                // ADD, SUB, MUL
                4'b0001, 4'b0010, 4'b0011: begin
                    // Zadaj memoriji da procita sa adrese drugog operanda
                    mem_addr = ir_high_out[6:4];
                    mem_we = 1'b0;

                    if (ir_high_out[7] == 1'b1) begin
                        state_next = state_fetch_second_op_indirect;
                    end
                    else begin
                        state_next = state_second_op_fetched;
                    end
                end

                
                // DIV
                4'b0100: begin
                    state_next = state_fetch_firstW;
                end

                // STOP
                4'b1111: begin
                    // Zadaj memoriji da procita sa adrese prvog operanda ako je prvi operand != 0
                    if (ir_high_out[11:8] != 4'b0000) begin
                        mem_addr = ir_high_out[10:8];
                        mem_we = 1'b0;

                        if (ir_high_out[11] == 1'b1) begin
                            state_next = state_fetch_first_op_indirect;
                        end
                        else begin
                            state_next = state_first_op_fetched;    // Odande cemo nakon upisa u out prvog podatka imati isti kod kao iz ostatka ovog case (da li je drugi operand != 0...) 
                        end
                    end
                    // U suprotnom zadaj odmah memoriji da procita sa adrese drugog operanda ako je drugi != 0
                    else if (ir_high_out[7:4] != 4'b0000) begin
                        mem_addr = ir_high_out[6:4];
                        mem_we = 1'b0;

                        if (ir_high_out[7] == 1'b1) begin
                            state_next = state_fetch_second_op_indirect;
                        end
                        else begin
                            state_next = state_second_op_fetched;    // Odande cemo nakon upisa u out drugog podatka imati isti kod kao iz ostatka ovog case (da li je treci operand != 0...) 
                        end
                    end
                    // U suprotnom zadaj odmah memoriji da procita sa adrese treceg operanda ako je treci != 0
                    else if (ir_high_out[3:0] != 4'b0000) begin
                        mem_addr = ir_high_out[2:0];
                        mem_we = 1'b0;

                        if (ir_high_out[3] == 1'b1) begin
                            state_next = state_fetch_third_op_indirect;
                        end
                        else begin
                            state_next = state_third_op_fetched;
                        end
                    end
                    // Idi u finalno stanje (stanje beskonacne petlje)
                    else begin
                        state_next = state_stopped;
                    end
                end

                // default: begin
                //     sp_dec = 1'b1;      // Todo: OBRISI
                // end
            endcase

            // state_next = ..;
        end



        // Zadaj memoriji da procita sa adrese koja se nalazila na adresi prvog operanda (mora posebno stanje za 1. 2. ili 3. operand da bismo nakon toga presli u odgovarajuce stanje)
        state_fetch_first_op_indirect: begin
            mem_addr = mem_in;
            mem_we = 1'b0;

            state_next = state_first_op_fetched;
        end

        state_fetch_second_op_indirect: begin
            mem_addr = mem_in;
            mem_we = 1'b0;

            state_next = state_second_op_fetched;
        end

        state_fetch_third_op_indirect: begin
            mem_addr = mem_in;
            mem_we = 1'b0;

            state_next = state_third_op_fetched;
        end



        // Ucitaj drugih 16b instrukcije u ir_low
        state_fetch_secondW: begin
            ir_low_ld = 1'b1;

            state_next = state_secondW_fetched;
        end
        
        // Samo MOV instr ima 2 reci
        state_secondW_fetched: begin
            case (ir_high_out[15:12])
                // MOV
                4'b0000: begin
                    // Upis druge reci na adresu 1. op
                    mem_addr = ir_high_out[10:8];
                    mem_data = ir_low_out;
                    mem_we = 1'b1;

                    state_next = state_fetch_firstW;
                end
            endcase

            // state_next = ..;
        end



        // Procitani podatak se nalazi na mem_in zici
        state_first_op_fetched: begin
            case (ir_high_out[15:12])
                // IN
                4'b0111: begin
                    // Na mem_in se nalazi procitan sadrzaj sa adrese operanda koji predstavlja adresu na koju treba staviti standardni ulaz (jer je bila rec o indirektnom adresiranju)
                    mem_addr = mem_in;
                    mem_data = in;
                    mem_we = 1'b1;

                    state_next = state_fetch_firstW;
                end

                // OUT
                4'b1000: begin
                    // Procitan podatak ce se staviti na standardni izlaz
                    out_next = mem_in;

                    state_next = state_fetch_firstW;
                end

                // ADD, SUB, MUL (ovde smo ako je bio slucaj indirektnog adresiranja, mem_in je procitana adresa sa adrese 1. operanda, rezultat ALU imamo spreman u akumulatoru)
                4'b0001, 4'b0010, 4'b0011: begin
                    mem_addr = mem_in;
                    mem_data = acc_out;
                    mem_we = 1'b1;

                    state_next = state_fetch_firstW;
                end

                // DIV (nece se doci do ovde)
                
                // STOP
                4'b1111: begin
                    // Procitan podatak ce se staviti na standardni izlaz
                    out_next = mem_in;

                    // Zadaj memoriji da procita sa adrese drugog operanda ako je drugi operand != 0
                    if (ir_high_out[7:4] != 4'b0000) begin
                        mem_addr = ir_high_out[6:4];
                        mem_we = 1'b0;

                        if (ir_high_out[7] == 1'b1) begin
                            state_next = state_fetch_second_op_indirect;
                        end
                        else begin
                            state_next = state_second_op_fetched;    // Odande cemo nakon upisa u out drugog podatka imati isti kod kao iz ostatka ovog case (da li je treci operand != 0...) 
                        end
                    end
                    // U suprotnom zadaj odmah memoriji da procita sa adrese treceg operanda ako je treci != 0
                    else if (ir_high_out[3:0] != 4'b0000) begin
                        mem_addr = ir_high_out[2:0];
                        mem_we = 1'b0;

                        if (ir_high_out[3] == 1'b1) begin
                            state_next = state_fetch_third_op_indirect;
                        end
                        else begin
                            state_next = state_third_op_fetched;
                        end
                    end
                    // Idi u finalno stanje (stanje beskonacne petlje)
                    else begin
                        state_next = state_stopped;
                    end
                end
            endcase

            // state_next = ..;
        end

        // Procitani podatak se nalazi na mem_in zici
        state_second_op_fetched: begin
            case (ir_high_out[15:12])
                // MOV
                4'b0000: begin
                    // Upis procitanog podatka 2. operanda na adresu 1. op
                    mem_addr = ir_high_out[10:8];
                    mem_data = mem_in;
                    mem_we = 1'b1;
                    
                    state_next = state_fetch_firstW;
                end

                // ADD
                4'b0001, 4'b0010, 4'b0011: begin
                    // Upis procitanog podatka 2. operanda u akumulator
                    acc_in = mem_in;
                    acc_ld = 1'b1;

                    // Zadaj memoriji da procita sa adrese treceg operanda
                    mem_addr = ir_high_out[2:0];
                    mem_we = 1'b0;

                    if (ir_high_out[3] == 1'b1) begin
                        state_next = state_fetch_third_op_indirect;
                    end
                    else begin
                        state_next = state_third_op_fetched;
                    end
                end

                // DIV
                // - nikad nece stici ovde
                
                // STOP
                4'b1111: begin
                    // Procitan podatak ce se staviti na standardni izlaz
                    out_next = mem_in;

                    // Zadaj memoriji da procita sa adrese treceg operanda ako je treci operand != 0
                    if (ir_high_out[3:0] != 4'b0000) begin
                        mem_addr = ir_high_out[2:0];
                        mem_we = 1'b0;

                        if (ir_high_out[3] == 1'b1) begin
                            state_next = state_fetch_third_op_indirect;
                        end
                        else begin
                            state_next = state_third_op_fetched;
                        end
                    end
                    // Idi u finalno stanje (stanje beskonacne petlje)
                    else begin
                        state_next = state_stopped;
                    end
                end
            endcase

            // state_next = ..;
        end
        
        // Procitani podatak se nalazi na mem_in zici
        state_third_op_fetched: begin
            case (ir_high_out[15:12])
                // ADD (mem_in je procitan podatak 3. operanda, acc_out je podatak 2. operanda)
                4'b0001: begin
                    alu_a = acc_out;
                    alu_b = mem_in;
                    alu_oc = 3'b000;

                    // ALU mi odmah vraca rezultat, ne treba cekati naredni takt, tad ce biti nesto drugo na njoj.
                    // Ako je prvi operand indirektno adresiran, pamtimo rezultat ALU u akumulatoru i zadajemo memoriji da procita sa adrese 1. operand adresu na koju cemo posle upisati
                    if (ir_high_out[11] == 1'b1) begin
                        // Upamti rez ALU u acc
                        acc_in = alu_f;
                        acc_ld = 1'b1;

                        // Zadaj memoriji da procita sa adrese prvog operanda
                        mem_addr = ir_high_out[10:8];
                        mem_we = 1'b0;

                        state_next = state_first_op_fetched;
                    end
                    // U suprotnom, rezultat ALU odmah mozemo da pisemo na adresu prvog operanda
                    else begin
                        mem_addr = ir_high_out[10:8];
                        mem_data = alu_f;
                        mem_we = 1'b1;

                        state_next = state_fetch_firstW;
                    end
                end

                // SUB
                4'b0010: begin
                    alu_a = acc_out;
                    alu_b = mem_in;
                    alu_oc = 3'b001;

                    // ALU mi odmah vraca rezultat, ne treba cekati naredni takt, tad ce biti nesto drugo na njoj.
                    // Ako je prvi operand indirektno adresiran, pamtimo rezultat ALU u akumulatoru i zadajemo memoriji da procita sa adrese 1. operand adresu na koju cemo posle upisati
                    if (ir_high_out[11] == 1'b1) begin
                        // Upamti rez ALU u acc
                        acc_in = alu_f;
                        acc_ld = 1'b1;

                        // Zadaj memoriji da procita sa adrese prvog operanda
                        mem_addr = ir_high_out[10:8];
                        mem_we = 1'b0;

                        state_next = state_first_op_fetched;
                    end
                    // U suprotnom, rezultat ALU odmah mozemo da pisemo na adresu prvog operanda
                    else begin
                        mem_addr = ir_high_out[10:8];
                        mem_data = alu_f;
                        mem_we = 1'b1;

                        state_next = state_fetch_firstW;
                    end
                end

                // MUL
                4'b0011: begin
                    alu_a = acc_out;
                    alu_b = mem_in;
                    alu_oc = 3'b010;

                    // ALU mi odmah vraca rezultat, ne treba cekati naredni takt, tad ce biti nesto drugo na njoj.
                    // Ako je prvi operand indirektno adresiran, pamtimo rezultat ALU u akumulatoru i zadajemo memoriji da procita sa adrese 1. operand adresu na koju cemo posle upisati
                    if (ir_high_out[11] == 1'b1) begin
                        // Upamti rez ALU u acc
                        acc_in = alu_f;
                        acc_ld = 1'b1;

                        // Zadaj memoriji da procita sa adrese prvog operanda
                        mem_addr = ir_high_out[10:8];
                        mem_we = 1'b0;

                        state_next = state_first_op_fetched;
                    end
                    // U suprotnom, rezultat ALU odmah mozemo da pisemo na adresu prvog operanda
                    else begin
                        mem_addr = ir_high_out[10:8];
                        mem_data = alu_f;
                        mem_we = 1'b1;

                        state_next = state_fetch_firstW;
                    end
                end

                // DIV
                // - nikad nece stici ovde


                // STOP
                4'b1111: begin
                    // Procitan podatak ce se staviti na standardni izlaz
                    out_next = mem_in;

                    state_next = state_stopped;
                end
            endcase

            // state_next = ..;
        end



        state_stopped: begin
            // Infinite loop
        end
    endcase
end


endmodule