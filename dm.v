// Editor: SunAo
// LastEditTime: 2024/5/21

// clk: clock tick
// DMWr: write enable
// addr: address
// din: write data
// dout: read data
module dm(clk, DMWr, addr, din, dout, pc);
   input clk;
   input DMWr;
   input [31:0] addr;
   input [31:0] din;
   input [31:0] pc;
   output [31:0] dout;
     
   reg [31:0] dmem[127:0];
   
   always @(negedge clk)
      if (DMWr) begin
         dmem[addr[11:2]] <= din;
         // for test
         $display("pc = %h: dataaddr = %h, memdata = %h", pc, { addr [31:2], 2'b00 }, din);
      end
   
   assign dout = dmem[addr[11:2]];
    
endmodule    
