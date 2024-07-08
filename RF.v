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
  output reg [31:0] RdDt1, 
  output reg [31:0] RdDt2
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
    else if (RFWr && WrDtAdr != 0) begin
      rf[WrDtAdr] <= WrDt;
    end

  // read data
  always @(posedge clk) begin
    if (RdAdr1 != 0) RdDt1 <= (RdAdr1 == WrDtAdr) ? WrDt : rf[RdAdr1]; else RdDt1 <= 0;
    if (RdAdr2 != 0) RdDt2 <= (RdAdr2 == WrDtAdr) ? WrDt : rf[RdAdr2]; else RdDt2 <= 0;
  end

endmodule 
