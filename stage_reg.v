module StageReg #(parameter WIDTH = 200) (
  input Clk, Rst, write_enable, flush,
  input [WIDTH-1:0] in,
  output reg [WIDTH-1:0] out
);
  always @(negedge Clk or posedge Rst) begin
    if (Rst) begin
      out <= 0;
    end else begin
      if (write_enable) begin
        if (flush) begin
          out <= 0;
        end else begin
          out <= in;
        end
      end
    end
  end
endmodule