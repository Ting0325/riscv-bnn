module acc_tb;

parameter cyc = 10; //use "cyc" to represent the period

///// declare input(reg) and output(wire) /////

reg clk;
reg rst_n;


///// declare  module /////


wire                                 enable;
reg [31:0]                           dmem_addr;
reg [31:0]                           dmem_writedata;
reg [31:0]                           dmem_rdata;
wire[31:0]                           data_out;
wire                                 acc_wenb;
wire                                 acc_renb; 
wire  [15:2]                         addr_mem;
wire [3:0]                          acc_webb;
ACC ACC(
    .clk(clk),
    .rst_n(rst_n),  
    .enable(enable),
    .addr_in(dmem_addr),
    .data_in(dmem_writedata),
    .data_mem(dmem_rdata),
    .data_out(data_out),
    .wenb(acc_wenb),
    .renb(acc_renb), 
    .addr_mem(addr_mem),
    .webb_out(acc_webb)
);


initial begin
  $fsdbDumpfile("acc_test.fsdb");
  $fsdbDumpvars;
end



////// clock //////
always #(cyc/2) clk = ~clk;

initial begin
clk = 0;
rst_n = 0;
#(cyc)
rst_n = 1;
dmem_addr = 32'h0008_0000 ;
dmem_writedata = 32'h0000_0010;
dmem_rdata = 0;
#(cyc)

dmem_addr = 32'h000c_0000;
dmem_writedata = 32'h0000_0040 ;
dmem_rdata = 32'h0000_0007;
#(cyc)

dmem_addr = 32'h0010_0000;
dmem_writedata = 32'h0000_0001;
dmem_rdata = 0;
#(cyc)


$finish;
end

endmodule


