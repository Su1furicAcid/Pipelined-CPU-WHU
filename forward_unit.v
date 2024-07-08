module ForwardUnit(
  input [4:0] ID_EX_Rs1,
  input [4:0] ID_EX_Rs2,
  input [4:0] EX_MEM_Rd,
  input [4:0] MEM_WB_Rd,
  input EX_MEM_WB,
  input MEM_WB_WB,
  output reg [1:0] forwardA,
  output reg [1:0] forwardB
);
always @(*) begin
  forwardA <= 2'b00;
  forwardB <= 2'b00;
  if (MEM_WB_WB && (MEM_WB_Rd != 0)) begin
    if (MEM_WB_Rd == ID_EX_Rs1) forwardA <= 2'b01;
    if (MEM_WB_Rd == ID_EX_Rs2) forwardB <= 2'b01;
  end
  if (EX_MEM_WB && (EX_MEM_Rd != 0)) begin
    if (EX_MEM_Rd == ID_EX_Rs1) forwardA <= 2'b10;
    if (EX_MEM_Rd == ID_EX_Rs2) forwardB <= 2'b10;
  end
end
endmodule