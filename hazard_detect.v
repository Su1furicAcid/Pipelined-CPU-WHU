module HazardDetect(
  input ID_EX_MR,
  input ID_EX_Rd,
  input ID_EX_RW,
  input IF_ID_Rs1,
  input IF_ID_Rs2,
  output reg PCWr,
  output reg IF_ID_Wr,
  output reg [1:0] stall
);

always @(*) begin
  if (ID_EX_MR && (ID_EX_Rd == IF_ID_Rs1 || ID_EX_Rd == IF_ID_Rs2) && (ID_EX_Rd != 0) && ID_EX_RW) begin
    // stall the pipeline
    PCWr <= 0;
    IF_ID_Wr <= 0;
    stall <= 2'b01;
  end else begin
    PCWr <= 1;
    IF_ID_Wr <= 1;
    stall <= 2'b00;
  end
end

endmodule