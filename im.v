// Editor: SunAo
// LastEditTime: 2024/5/21

// instruction memory
module im(input [8:2] addr, output [31:0] dout);
  reg  [31:0] RAM[127:0];
  // read
  assign dout = RAM[addr]; 
endmodule  
