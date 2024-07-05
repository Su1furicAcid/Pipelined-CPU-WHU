`include "ctrl_encode_def.v"
module Flush(
  input [2:0] mem_npc_op,
  input Zero,
  output reg IFflush,
  output reg IDflush
);

  always @(*) begin
    case (mem_npc_op)
      `NPC_BRANCH: if (Zero) begin IFflush <= 1; IDflush <= 1; end else begin IFflush <= 0; IDflush <= 0; end
      `NPC_JUMP: begin IFflush <= 1; IDflush <= 1; end
      `NPC_JALR: begin IFflush <= 1; IDflush <= 1; end
      default: begin IFflush <= 0; IDflush <= 0; end
    endcase
  end

endmodule