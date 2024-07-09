`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC, Aluout, PCWrite, Zero, mem_pc_out);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input [31:0] Aluout;
   output reg [31:0] NPC;   // next pc
   input  PCWrite;
   input  Zero;
   input [31:0] mem_pc_out;
   
   // definite the adder

   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      if (!PCWrite) begin
         case (NPCOp)
            `NPC_PLUS4: NPC <= PCPLUS4;
            `NPC_BRANCH: if (Zero) NPC <= mem_pc_out + IMM; else NPC <= PCPLUS4;
            `NPC_JUMP: NPC <= mem_pc_out + IMM;
            `NPC_JALR: NPC <= Aluout + IMM;
            default: NPC <= PCPLUS4;
         endcase
      end else begin
         NPC <= PC;
      end
   end
   
endmodule
