module StageReg (
  input Clk, Rst, write_enable, flush,
  input [31:0] in0, in1, in2, in3, in4, in5, in6, in7,
  output reg [31:0] out0, out1, out2, out3, out4, out5, out6, out7
);

  always @(posedge Clk, posedge Rst) begin
    if (Rst | flush) begin
      out0 <= 0;
      out1 <= 0;
      out2 <= 0;
      out3 <= 0;
      out4 <= 0;
      out5 <= 0;
      out6 <= 0;
      out7 <= 0;
    end else if (write_enable) begin
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