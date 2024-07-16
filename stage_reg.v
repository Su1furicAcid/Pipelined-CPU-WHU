module StageReg (
  input wire Clk, 
  input wire Rst, 
  input wire flush,
  input wire [31:0] in0, in1, in2, in3, in4, in5, in6, in7,
  output reg [31:0] out0, out1, out2, out3, out4, out5, out6, out7,
  input INT_Detect, INT_Return
);

  reg [31:0] INT_0, INT_1, INT_2, INT_3, INT_4, INT_5, INT_6, INT_7;

  always @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      out0 <= 32'h0000_0000;
      out1 <= 32'h0000_0000;
      out2 <= 32'h0000_0000;
      out3 <= 32'h0000_0000;
      out4 <= 32'h0000_0000;
      out5 <= 32'h0000_0000;
      out6 <= 32'h0000_0000;
      out7 <= 32'h0000_0000;
    end else if (flush) begin
      out0 <= 32'h0000_0000;
      out1 <= 32'h0000_0000;
      out2 <= 32'h0000_0000;
      out3 <= 32'h0000_0000;
      out4 <= 32'h0000_0000;
      out5 <= 32'h0000_0000;
      out6 <= 32'h0000_0000;
      out7 <= 32'h0000_0000;
    end else if (INT_Detect) begin
      INT_0 <= out0; out0 <= 32'h0000_0000;
      INT_1 <= out1; out1 <= 32'h0000_0000;
      INT_2 <= out2; out2 <= 32'h0000_0000;
      INT_3 <= out3; out3 <= 32'h0000_0000;
      INT_4 <= out4; out4 <= 32'h0000_0000;
      INT_5 <= out5; out5 <= 32'h0000_0000;
      INT_6 <= out6; out6 <= 32'h0000_0000;
      INT_7 <= out7; out7 <= 32'h0000_0000;
    end else if (INT_Return) begin
      out0 <= INT_0;
      out1 <= INT_1;
      out2 <= INT_2;
      out3 <= INT_3;
      out4 <= INT_4;
      out5 <= INT_5;
      out6 <= INT_6;
      out7 <= INT_7;
    end else begin
      out0 <= in0;
      out1 <= in1;
      out2 <= in2;
      out3 <= in3;
      out4 <= in4;
      out5 <= in5;
      out6 <= in6;
      out7 <= in7;
    end
  end

endmodule
