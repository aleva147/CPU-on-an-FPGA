module top #(
    parameter DIVISOR = 50_000_000,
	parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
); 

wire clk_div_out;
wire mem_we;
wire [ADDR_WIDTH-1:0] mem_addr;
wire [DATA_WIDTH-1:0] mem_data;     // Podatak koji upisujemo u memoriju
wire [DATA_WIDTH-1:0] mem_in;       // Procitan podatak iz memorije
wire [ADDR_WIDTH-1:0] cpu_pc_out;
wire [ADDR_WIDTH-1:0] cpu_sp_out;
wire [3:0] bcd_pc_ones; wire [3:0] bcd_pc_tens;
wire [3:0] bcd_sp_ones; wire [3:0] bcd_sp_tens;



clk_div dut_clk_div(
    .clk(clk),
    .rst_n(rst_n),
    .out(clk_div_out)
);


memory dut_memory(
    .clk(clk_div_out),
    .we(mem_we),
    .addr(mem_addr),
    .data(mem_data),
    .out(mem_in)
);


cpu dut_cpu(
    .clk(clk_div_out),
    .rst_n(rst_n),
    .mem_in(mem_in),
    .in({12'b0, sw[3:0]}),      // Opstiji nacin:  .in({{(DATA_WIDTH-4) {1'b0}}, sw[3:0]})
    .mem_we(mem_we),
    .mem_addr(mem_addr),
    .mem_data(mem_data),
    .out(led[4:0]),             // Mozda drugacije
    .sp(cpu_sp_out),
    .pc(cpu_pc_out)
);


bcd dut_bcd_pc(
    .in(cpu_pc_out),
    .ones(bcd_pc_ones),
    .tens(bcd_pc_tens)
);

bcd dut_bcd_sp(
    .in(cpu_sp_out),
    .ones(bcd_sp_ones),
    .tens(bcd_sp_tens)
);


ssd dut_digit0(
    .in(bcd_pc_ones),
    .out(hex[6:0])
);

ssd dut_digit1(
    .in(bcd_pc_tens),
    .out(hex[13:7])
);

ssd dut_digit2(
    .in(bcd_sp_ones),
    .out(hex[20:14])
);

ssd dut_digit3(
    .in(bcd_sp_tens),
    .out(hex[27:21])
);


endmodule