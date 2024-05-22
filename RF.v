// Editor: SunAo
// LastEditTime: 2024/5/21

// clk: clock tick
// rst: reset
// RFWr: write enable
// RdAdr1, RdAdr2: read address
// WrDtAdr: write address
// WrDt: write data
// RdDt1, RdDt2: read data
module RF(
  input clk, 
  input rst, 
  input RFWr, 
  input [4:0] RdAdr1, 
  input [4:0] RdAdr2, 
  input [4:0] WrDtAdr, 
  input [31:0] WrDt, 
  output [31:0] RdDt1, 
  output [31:0] RdDt2
);
  // definite register file
  reg [31:0] rf[31:0];

  integer i;

  // write data
  always @(negedge clk or posedge rst)
    // reset 
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] <= 0;
    end 
    else if (RFWr) begin
      if (WrDtAdr != 0) begin
        rf[WrDtAdr] <= WrDt;
        $display("x%d = %h", WrDtAdr, WrDt);
      end
    end
  // read data
  assign RdDt1 = (RdAdr1 != 0) ? rf[RdAdr1] : 0;
  assign RdDt2 = (RdAdr2 != 0) ? rf[RdAdr2] : 0;
endmodule 
