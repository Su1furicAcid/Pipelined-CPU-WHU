// a lot of muxes

module mux2(
  input [1:0] sel,
  input [31:0] in0,
  input [31:0] in1,
  output reg [31:0] out
);
  always @(*) begin
    case (sel)
      2'b00: out = in0;
      2'b01: out = in1;
      default: out = 0;
    endcase
  end
endmodule

module mux3(
  input [1:0] sel,
  input [31:0] in0,
  input [31:0] in1,
  input [31:0] in2,
  output reg [31:0] out
);
  always @(*) begin
    case (sel)
      2'b00: out = in0;
      2'b01: out = in1;
      2'b10: out = in2;
      default: out = 0;
    endcase
  end
endmodule