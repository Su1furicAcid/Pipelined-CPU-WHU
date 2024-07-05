module JudgeBranch(
  input [31:0] inst,
  input [31:0] rd1,
  input [31:0] rd2,
  output reg Zero
);

  wire [6:0] opcode; assign opcode = inst[6:0];
  wire [6:0] funct7; assign funct7 = inst[31:25];
  wire [2:0] funct3; assign funct3 = inst[14:12];

  always @(*) begin
    if (opcode == 7'b1100011) begin
      case (funct3)
        3'b000: if (rd1 == rd2) Zero <= 1'b1; else Zero <= 1'b0;
        3'b001: if (rd1 != rd2) Zero <= 1'b1; else Zero <= 1'b0;
        3'b100: if (rd1 < rd2) Zero <= 1'b1; else Zero <= 1'b0;
        3'b101: if (rd1 >= rd2) Zero <= 1'b1; else Zero <= 1'b0;
        3'b110: if ($unsigned(rd1) < $unsigned(rd2)) Zero <= 1'b1; else Zero <= 1'b0;
        3'b111: if ($unsigned(rd1) >= $unsigned(rd2)) Zero <= 1'b1; else Zero <= 1'b0;
        default: Zero <= 1'b0;
      endcase
    end
  end

endmodule