// Editor: SunAo 
// LastEditTime: 2024/5/21
module ctrl(Op, Funct7, Funct3, Zero, RegWrite, MemWrite, EXTOp, ALUOp, NPCOp, ALUSrc, WDSel, GPRSel, DMType);
            
  input  [6:0] Op;       // opcode
  input  [6:0] Funct7;    // funct7
  input  [2:0] Funct3;    // funct3
  input        Zero;
   
  output       RegWrite; // control signal for register write
  output       MemWrite; // control signal for memory write
  output [5:0] EXTOp;    // control signal to signed extension
  output [4:0] ALUOp;    // ALU opertion
  output [2:0] NPCOp;    // next pc operation
  output       ALUSrc;   // ALU source for A
	output [2:0] DMType;
  output [1:0] GPRSel;   // general purpose register selection
  output [1:0] WDSel;    // (register) write data selection

  // The following lists all the instructions and their corresponding opcodes with funct3/funct7
  // However, we only need to consider the instructions that are instinctly influence the control signals
   
  // r format: add, sub, or, and, xor, sll, slt, sltu, srl, sra
  wire rtype = ~Op[6] & Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // opcode 0110011
  wire i_add = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // add 0000000 000
  wire i_sub = rtype & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sub 0100000 000
  wire i_or = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & Funct3[1] & ~Funct3[0]; // or 0000000 110
  wire i_and = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & Funct3[1] & Funct3[0]; // and 0000000 111
  wire i_xor = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xor 0000000 100
  wire i_sll = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // sll 0000000 001
  wire i_slt = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slt 0000000 010
  wire i_sltu = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltu 0000000 011
  wire i_srl = rtype & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // srl 0000000 101
  wire i_sra = rtype & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // sra 0100000 101

  // i format: lb, lh, lw, lbu, lhu
  wire itype_l = ~Op[6] & ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // opcode 0000011
  wire i_lb = itype_l & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // lb 000
  wire i_lh = itype_l & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // lh 001
  wire i_lw = itype_l & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // lw 010
  wire i_lbu = itype_l & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // lbu 100
  wire i_lhu = itype_l & Funct3[2] & ~Funct3[1] & Funct3[0]; // lhu 101

  // i format: addi, ori, xori, andi. slli, slti, sltiu, srli, srai
  wire itype_r = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // opcode 0010011
  wire i_addi = itype_r & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // addi 000
  wire i_ori = itype_r & Funct3[2] & Funct3[1] & ~Funct3[0]; // ori 110
  wire i_xori = itype_r & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xori 100
  wire i_andi = itype_r & Funct3[2] & Funct3[1] & Funct3[0]; // andi 111
  wire i_slli = itype_r & ~Funct3[2] & ~Funct3[1] & Funct3[0] & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0]; // slli 001 0000000
  wire i_slti = itype_r & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slti 010
  wire i_sltiu = itype_r & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltiu 011
  wire i_srli = itype_r & Funct3[2] & ~Funct3[1] & Funct3[0] & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0]; // srli 101 0000000
  wire i_srai = itype_r & Funct3[2] & Funct3[1] & Funct3[0] & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0]; // srai 101 0100000

  // jalr
	wire i_jalr = Op[6] & Op[5] & ~Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; //jalr opcode 1100111

  // j format: jal
  wire i_jal = Op[6] & Op[5] & ~Op[4] & Op[3] & Op[2] & Op[1] & Op[0];  // jal opcode 1101111

  // s format: sw, sh, sb
  wire stype = ~Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // opcode 0100011
  wire i_sw = stype & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // sw 010
  wire i_sh = stype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // sh 001
  wire i_sb = stype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sb 000

  // sb format
  wire sbtype = Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // opcode 1100011
  wire i_beq = sbtype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // beq 000
	wire i_bne = sbtype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // bne 001
  wire i_blt = sbtype & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // blt 100
  wire i_bltu = sbtype & Funct3[2] & Funct3[1] & ~Funct3[0]; // bltu 110
  wire i_bge = sbtype & Funct3[2] & ~Funct3[1] & Funct3[0]; // bge 101
  wire i_bgeu = sbtype & Funct3[2] & Funct3[1] & Funct3[0]; // bgeu 111

  // U format: lui, auipc
  wire i_lui = ~Op[6] & Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; // lui opcode 0110111
  wire i_auipc = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; // auipc opcode 0010111

  // The following lists all the control signals

  // generate control signals, write this according to ctrl_encode_def.v, which lists the truth table
  
  assign RegWrite = rtype | itype_r | i_jalr | i_jal | i_lui | i_auipc; // write sth to register
  assign MemWrite = stype; // write sth to memory
  assign ALUSrc = itype_r | stype | i_jal | i_jalr | i_lui | i_auipc; // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5] = i_slli | i_srli | i_srai;
  assign EXTOp[4] = (itype_r | itype_l) & ~(i_slli | i_srli | i_srai);
  assign EXTOp[3] = stype; 
  assign EXTOp[2] = sbtype; 
  assign EXTOp[1] = i_lui | i_auipc;
  assign EXTOp[0] = i_jal;         

  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_l;
  assign WDSel[1] = i_jal | i_jalr;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	   3'b100
  assign NPCOp[0] = sbtype & Zero;
  assign NPCOp[1] = i_jal;
	assign NPCOp[2] = i_jalr;
  
  // ALUOp

  // list the instructions and their corresponding ALU operations

  // 1. rformat: add, sub, or, and, xor
  // they are base for the rest of the instructions

  // 2. itype_l: lb, lh, lw, lbu, lhu
  // alu need to add the immediate to the base address, so they belong to add

  // 3. itype_r: addi, ori, xori, andi, slli, slti, sltiu, srli, srai
  // to alu, they are similar to rformat

  // 4. jalr
  // in our datapath, alu need to do give special register, C equals to A, so it belongs nop

  // 5. jal
  // in our datapath, alu need to do nothing, so it also belongs to nop

  // 6. sformat: sw, sh, sb
  // alu need to add the immediate to the base address, so they belong to add

  // 7. sbformat: beq, bne, blt, bltu, bge, bgeu
  // they are special

  // 8. Uformat: lui, auipc
  // they are special

  // so, we can divide the instructions into some groups, these in one group appear at the same time
  wire ALUOp_nop = i_jalr | i_jal;
  wire ALUOp_lui = i_lui;
  wire ALUOp_auipc = i_auipc;
  wire ALUOp_add = i_add | itype_l | stype;
  wire ALUOp_sub = i_sub;
  wire ALUOp_bne = i_bne;
  wire ALUOp_blt = i_blt;
  wire ALUOp_bge = i_bge;
  wire ALUOp_bltu = i_bltu;
  wire ALUOp_bgeu = i_bgeu;
  wire ALUOp_slt = i_slt | i_slti;
  wire ALUOp_sltu = i_sltu | i_sltiu;
  wire ALUOp_xor = i_xor | i_xori;
  wire ALUOp_or = i_or | i_ori;
  wire ALUOp_and = i_and | i_andi;
  wire ALUOp_sll = i_sll | i_slli;
  wire ALUOp_srl = i_srl | i_srli;
  wire ALUOp_sra = i_sra | i_srai;

	assign ALUOp[0] = ALUOp_lui | ALUOp_add | ALUOp_bne | ALUOp_bne | ALUOp_bge | ALUOp_bgeu | ALUOp_sltu | ALUOp_or | ALUOp_sll | ALUOp_srl | ALUOp_sra;
	assign ALUOp[1] = ALUOp_auipc | ALUOp_add | ALUOp_blt | ALUOp_bge | ALUOp_slt | ALUOp_sltu | ALUOp_and | ALUOp_xor | ALUOp_sll;
	assign ALUOp[2] = ALUOp_sub | ALUOp_bne | ALUOp_blt | ALUOp_bge | ALUOp_xor | ALUOp_or | ALUOp_and | ALUOp_sll;
	assign ALUOp[3] = ALUOp_bltu | ALUOp_bgeu | ALUOp_slt | ALUOp_sltu | ALUOp_xor | ALUOp_or | ALUOp_and | ALUOp_sll;
	assign ALUOp[4] = ALUOp_srl | ALUOp_sra;

endmodule
