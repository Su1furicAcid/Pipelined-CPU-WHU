module StageReg (
  input Clk, Rst, write_enable, flush,
  input [31:0] in0, in1, in2, in3, in4, in5, in6, in7,
  output reg [31:0] out0, out1, out2, out3, out4, out5, out6, out7
);

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
    end else begin
      if (flush) begin
        out0 <= 32'h0000_0000;
        out1 <= 32'h0000_0000;
        out2 <= 32'h0000_0000;
        out3 <= 32'h0000_0000;
        out4 <= 32'h0000_0000;
        out5 <= 32'h0000_0000;
        out6 <= 32'h0000_0000;
        out7 <= 32'h0000_0000;
      end else begin
        if (write_enable) begin
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
    end
  end

endmodule