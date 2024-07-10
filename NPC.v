`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC, Aluout, Zero, mem_pc_out, j_fetch);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input [31:0] Aluout;
   output reg [31:0] NPC;   // next pc
   input  Zero;
   input [31:0] mem_pc_out;
   input j_fetch;
   
   // definite the adder

   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = (j_fetch) ? PC : PC + 4;
   
   always @(*) begin
      case (NPCOp)
         `NPC_PLUS4: NPC <= PCPLUS4;
         `NPC_BRANCH: if (Zero) NPC <= mem_pc_out + IMM; else NPC <= PCPLUS4;
         `NPC_JUMP: NPC <= mem_pc_out + IMM;
         `NPC_JALR: NPC <= Aluout + IMM;
         default: NPC <= PCPLUS4;
      endcase
   end
   
endmodule
