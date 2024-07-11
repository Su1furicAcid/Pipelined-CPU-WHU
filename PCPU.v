// Author: SunAo
`include "ctrl_encode_def.v"
module PCPU(
    input clk,            // clock
    input reset,          // reset
    input [31:0] inst_in,     // instruction
    input [31:0] Data_in,     // data from data memory
   
    output mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address
    // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    output [2:0] dm_ctrl
);
    /*
    <<<<<<< IF Stage >>>>>>>
    */

    // calculate next PC
    wire [2:0] MEM_NPCOp;
    wire [31:0] NPC;
    wire [31:0] MEM_immout;
    wire stop;
    wire [31:0] MEM_ALUout;
    wire MEM_zero;
    wire flush_signal;
    wire j_fetch; assign j_fetch = ((inst_in[6:0] == 7'b1101111) || (inst_in[6:0] == 7'b1100111)) ? 1 : 0;

    wire [31:0] MEM_PC_out;

    wire [31:0] sel_pc;

    mux2 NextPCSel(
        .sel({1'b0, stop}),
        .in0(NPC),
        .in1(PC_out),
        .out(sel_pc)
    );

    NPC U_NPC(
        .PC(PC_out), 
        .NPCOp(MEM_NPCOp), 
        .IMM(MEM_immout), 
        .NPC(NPC), 
        .Aluout(MEM_ALUout),
        .mem_pc_out(MEM_PC_out),
        .j_fetch(j_fetch)
    );
    PC U_PC(
        .clk(clk),
        .rst(reset),
        .NPC(sel_pc),
        .PC(PC_out)
    );

    wire [31:0] IF_inst;
    wire [31:0] ID_inst;

    mux2 InstNop(
        .sel({1'b0, stop}),
        .in0(inst_in),
        .in1(ID_inst),
        .out(IF_inst)
    );

    // IF/ID register
    wire [31:0] ID_PC_out; 
    StageReg U_IF_ID(
        .Clk(clk),
        .Rst(reset),
        .flush(flush_signal),
        .in0(PC_out), .out0(ID_PC_out),
        .in1(IF_inst), .out1(ID_inst)
    );

    /*
    <<<<<<< ID Stage >>>>>>>
    */

    // generate control signals
    wire [6:0] opcode; assign opcode = ID_inst[6:0];
    wire [6:0] funct7; assign funct7 = ID_inst[31:25];
    wire [2:0] funct3; assign funct3 = ID_inst[14:12];
    wire [31:0] ctrl_signals; // dont know the width, maybe 32 is enough
    ctrl U_ctrl(
        .Op(opcode),
        .Funct7(funct7),
        .Funct3(funct3),
        .RegWrite(ctrl_signals[0]),
        .MemWrite(ctrl_signals[1]),
        .EXTOp(ctrl_signals[7:2]),
        .ALUOp(ctrl_signals[12:8]),
        .NPCOp(ctrl_signals[15:13]),
        .ALUSrc(ctrl_signals[16]),
        .dm_ctrl(ctrl_signals[19:17]),
        .GPRSel(ctrl_signals[21:20]),
        .WDSel(ctrl_signals[23:22])
    );
    
    // read register file
    // RD1 was defined front of the module
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [4:0] rs1; assign rs1 = ID_inst[19:15];
    wire [4:0] rs2; assign rs2 = ID_inst[24:20];
    wire [4:0] rd; assign rd = ID_inst[11:7];
    wire [4:0] wrdtadr; // from WB stage
    wire regwrite;
    wire [31:0] wrdt;
    RF U_RF(
        .clk(clk),
        .rst(reset),
        .RFWr(regwrite),
        .RdAdr1(rs1),
        .RdAdr2(rs2),
        .WrDtAdr(wrdtadr),
        .WrDt(wrdt),
        .RdDt1(RD1),
        .RdDt2(RD2)
    );

    // immediate generation
    wire [4:0] iimm_shamt; assign iimm_shamt = ID_inst[24:20];
    wire [11:0] iimm; assign iimm = ID_inst[31:20];
    wire [11:0] simm; assign simm = { ID_inst[31:25], ID_inst[11:7] };
    wire [11:0] sbimm; assign sbimm = { ID_inst[31], ID_inst[7], ID_inst[30:25], ID_inst[11:8] };
    wire [19:0] uimm; assign uimm = ID_inst[31:12];
    wire [19:0] ujimm; assign ujimm = { ID_inst[31], ID_inst[19:12], ID_inst[20], ID_inst[30:21] };
    wire [31:0] immout;
    wire [5:0] EXTOp; assign EXTOp = ctrl_signals[7:2];
    // immout was defined front of the module
    EXT U_EXT(
        .iimm_shamt(iimm_shamt),
        .iimm(iimm),
        .simm(simm),
        .sbimm(sbimm),
        .uimm(uimm),
        .ujimm(ujimm),
        .EXTOp(EXTOp),
        .immout(immout)
    );

    wire [4:0] EX_rd; 

    // Hazard Detection Unit
    // TODO: ... check it again
    HazardDetect U_HazardDetect(
        .ID_EX_MR(EX_signals[22]),
        .ID_EX_Rd(EX_rd),
        .ID_EX_RW(EX_signals[0]),
        .IF_ID_Rs1(rs1),
        .IF_ID_Rs2(rs2),
        .stop(stop)
    );

    wire [31:0] ctrl_signals_out;

    // generate a nop
    mux2 CtrlSingalsNop(
        .sel({1'b0, stop}),
        .in0(ctrl_signals),
        .in1(0),
        .out(ctrl_signals_out)
    );

    // ID/EX register
    wire [31:0] EX_RD1;
    wire [31:0] EX_RD2;
    wire [31:0] EX_signals;
    wire [31:0] EX_immout;
    wire [31:0] EX_PC_out;
    wire [4:0] EX_rs1;
    wire [4:0] EX_rs2;

    StageReg U_ID_EX(
        .Clk(clk),
        .Rst(reset),
        .flush(flush_signal),
        .in0(ID_PC_out), .out0(EX_PC_out),
        .in1(rs1), .out1(EX_rs1),
        .in2(rs2), .out2(EX_rs2),
        .in3(rd), .out3(EX_rd),
        .in4(ctrl_signals_out), .out4(EX_signals),
        .in5(RD1), .out5(EX_RD1),
        .in6(RD2), .out6(EX_RD2),
        .in7(immout), .out7(EX_immout)
    );

    /*
    <<<<<<< EX Stage >>>>>>>
    */
    wire [4:0] MEM_rd;
    wire [4:0] WB_rd;
    wire [31:0] WB_signals; 
    wire [31:0] MEM_signals; 

    // ALU
    wire [31:0] ALUout;

    wire [1:0] forwardA, forwardB;

    wire [31:0] A;
    wire [31:0] B; 

    mux3 Amux(
        .sel(forwardA),
        .in0(EX_RD1),
        .in1(wrdt),
        .in2(MEM_ALUout),
        .out(A)
    );

    wire [31:0] Bin0temp;
    assign Bin0temp = (EX_signals[16]) ? EX_immout : EX_RD2;

    mux3 Bmux(
        .sel(forwardB),
        .in0(Bin0temp),
        .in1(wrdt),
        .in2(MEM_ALUout),
        .out(B)
    );

    wire EX_zero;

    alu U_alu(
        .A(A),
        .B(B),
        .ALUOp(EX_signals[12:8]),
        .C(ALUout),
        .PC(EX_PC_out),
        .Zero(EX_zero)
    );

    // forward
    // TODO: ... check it again
    ForwardUnit U_ForwardUnit(
        .ID_EX_Rs1(EX_rs1),
        .ID_EX_Rs2(EX_rs2),
        .EX_MEM_Rd(MEM_rd),
        .MEM_WB_Rd(WB_rd),
        .EX_MEM_WB(MEM_signals[0]),
        .MEM_WB_WB(WB_signals[0]),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    // EX/MEM register
    wire [31:0] MEM_RD1;
    wire [31:0] MEM_B;
    StageReg U_EX_MEM(
        .Clk(clk),
        .Rst(reset),
        .flush(flush_signal),
        .in0(EX_PC_out), .out0(MEM_PC_out),
        .in1(EX_rd), .out1(MEM_rd),
        .in2(EX_signals), .out2(MEM_signals),
        .in3(EX_RD1), .out3(MEM_RD1),
        .in4(B), .out4(MEM_B),
        .in5(ALUout), .out5(MEM_ALUout),
        .in6(EX_zero), .out6(MEM_zero),
        .in7(EX_immout), .out7(MEM_immout)
    );

    assign branch = MEM_zero & MEM_signals[13];
    assign MEM_NPCOp = {MEM_signals[15:14], branch};
    assign flush_signal = ((MEM_NPCOp == `NPC_BRANCH) || (MEM_NPCOp == `NPC_JUMP) || (MEM_NPCOp == `NPC_JALR)) ? 1 : 0;
    /*
    <<<<<<< MEM Stage >>>>>>>
    */

    // data memory
    assign Addr_out = MEM_ALUout;
    assign Data_out = MEM_B;
    assign dm_ctrl = MEM_signals[19:17];
    wire [31:0] rd_data; assign rd_data = Data_in;
    assign mem_w = MEM_signals[1];

    wire [31:0] WB_PC_out;
    wire [31:0] WB_RD1;
    wire [31:0] WB_B;
    wire [31:0] WB_rd_data;
    wire [31:0] WB_ALUout;
    StageReg U_MEM_WB(
        .Clk(clk),
        .Rst(reset),
        .flush(0),
        .in0(MEM_PC_out), .out0(WB_PC_out),
        .in1(MEM_ALUout), .out1(WB_ALUout),
        .in2(MEM_signals), .out2(WB_signals),
        .in3(MEM_RD1), .out3(WB_RD1),
        .in4(MEM_B), .out4(WB_B),
        .in5(rd_data), .out5(WB_rd_data),
        .in6(MEM_rd), .out6(WB_rd)
    );

    /*
    <<<<<<< WB Stage >>>>>>>
    */

    // write back
    assign regwrite = WB_signals[0];
    assign wrdtadr = WB_rd;
    wire [1:0] WB_WDSel; assign WB_WDSel = WB_signals[23:22];

    mux3 wrdtSel(
        .sel(WB_WDSel),
        .in0(WB_ALUout),
        .in1(WB_rd_data),
        .in2(WB_PC_out + 4),
        .out(wrdt)
    );

endmodule