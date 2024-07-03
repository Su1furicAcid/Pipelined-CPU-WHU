module StateReg #(parameter WIDTH = 256) (
  input Clk, Rst, write_enable, flush,
  input [0:WIDTH-1] in,
  output reg[0:WIDTH-1] out
);
  always @(negedge Clk) begin
    if (write_enable) begin
      if (flush) begin
        out <= 0;
      end else begin
        out <= in;
      end
    end
  end
  always @(posedge Rst) begin
    out <= 0;
  end
endmodule