// Editor: SunAo
// LastEditTime: 2024/5/21

`include "ctrl_encode_def.v"

// iimm_shamt: immediate for shift operations
// funct7[4:0] imm[4:0] rs1[4:0] funct3[2:0] rd[4:0] opcode[6:0]

// iimm: immediate for I-type instructions, expect shift operations
// imm[11:0] rs1[4:0] funct3[2:0] rd[4:0] opcode[6:0]

// simm: immediate for S-type instructions
// imm[11:5] rs2[4:0] rs1[4:0] funct3[2:0] opcode[6:0]

// sbimm: immediate for SB-type instructions
// imm[12] imm[10:5] rs2[4:0] rs1[4:0] funct3[2:0] opcode[6:0]

// uimm: immediate for U-type instructions
// imm[31:12] rd[4:0] opcode[6:0]

// ujimm: immediate for UJ-type instructions
// imm[20] imm[10:1] imm[11] imm[19:12] rd[4:0] opcode[6:0]

// EXTOp: control signal for extension, identify the type of immediate
// immout: output 32-bit immediate
module EXT( 
	input [4:0] iimm_shamt,
  input	[11:0] iimm,
	input	[11:0] simm,
	input	[11:0] sbimm,
	input	[19:0] uimm,
	input	[19:0] ujimm,
	input	[5:0]	EXTOp,
	output reg [31:0] immout
);
   
always @(*)
	 case (EXTOp)
		`EXT_CTRL_ITYPE_SHAMT: immout <= { 27'b0, iimm_shamt[4:0] };
		`EXT_CTRL_ITYPE: immout <= { { { 32 - 12 }{ iimm[11] } }, iimm[11:0] };
		`EXT_CTRL_STYPE: immout <= { { { 32 - 12 }{ simm[11] } }, simm[11:0] };
		`EXT_CTRL_BTYPE: immout <= { { { 32 - 13 }{ sbimm[11] } }, sbimm[11:0], 1'b0};
		`EXT_CTRL_UTYPE: immout <= { uimm[19:0], 12'b0 }; 
		`EXT_CTRL_JTYPE: immout <= { { { 32 - 21 }{ ujimm[19] }}, ujimm[19:0], 1'b0};
		default: immout <= 32'b0;
	 endcase
endmodule
