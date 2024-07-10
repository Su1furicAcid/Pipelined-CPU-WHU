module HazardDetect(
  input ID_EX_MR,
  input [4:0] ID_EX_Rd,
  input ID_EX_RW,
  input [4:0] IF_ID_Rs1,
  input [4:0] IF_ID_Rs2,
  output reg stop
);

always @(*) begin
  if (ID_EX_MR && (ID_EX_Rd == IF_ID_Rs1 || ID_EX_Rd == IF_ID_Rs2) && (ID_EX_Rd != 0) && ID_EX_RW) begin
    // stall the pipeline
    stop = 1;
  end else begin
    stop = 0;
  end
end

endmodule