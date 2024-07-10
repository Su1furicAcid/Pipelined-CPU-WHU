`include "ctrl_encode_def.v"
module Flush(
  input [2:0] mem_npc_op,
  input Zero,
  output IFflush,
  output IDflush,
  output EXflush
);

  always @(*) begin
    assign IFflush = ((mem_npc_op == `NPC_BRANCH) && Zero) ? 1 : 0;
  end

endmodule