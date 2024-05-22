module xgriscv_sc(clk, rst, pcW);

    input         clk, rst;
    output [31:0] pcW;
   
    wire [31:0] instruction;
    wire [31:0] PC;
    wire        MemWrite;
    wire [31:0] dm_addr, dm_din, dm_dout;

    SCPU CPU_UNIT(
        .clk(clk), .reset(rst), .inst_in(instruction), .Data_in(dm_dout), .mem_w(MemWrite),
        .PC_out(PC), .Addr_out(dm_addr), .Data_out(dm_din), .pcW(pcW)
    );

    im U_imem(.RA(PC), .RD(instruction));
    dm U_dmem(.clk(clk), .MemWrite(MemWrite), .Addr(dm_addr), .WD(dm_din), .RD(dm_dout), .PC(PC));

endmodule
