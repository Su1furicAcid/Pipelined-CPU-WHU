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
    wire NPCOp;
    wire [31:0] NPC;
    wire [31:0] RD1;
    wire [31:0] immout;
    NPC U_NPC(
        .PC(PC_out), 
        .NPCOp(NPCOp), 
        .IMM(immout), 
        .NPC(NPC), 
        .RD1(RD1)
    );

    // store PC and Instruction in IF/ID register
    wire IF_ID_write_enable;
    wire IF_ID_flush;
    StageReg #(.WIDTH(200)) U_IF_ID(clk, reset, IF_ID_write_enable, IF_ID_flush, , );
    assign U_IF_ID.in[31:0] = PC_out;
    assign U_IF_ID.in[63:32] = inst_in;

    /*
    <<<<<<< ID Stage >>>>>>>
    */

    // get PC and instruction from IF/ID register
    wire [31:0] ID_PC_out; assign ID_PC_out = U_IF_ID.out[31:0];
    wire [31:0] ID_inst; assign ID_inst = U_IF_ID.out[63:32];

    // generate control signals
    wire [6:0] opcode; assign opcode = ID_inst[6:0];
    wire [6:0] funct7; assign funct7 = ID_inst[31:25];
    wire [2:0] funct3; assign funct3 = ID_inst[14:12];
    wire zero;
    wire [31:0] ctrl_signals; // dont know the width, maybe 31 is enough
    ctrl U_ctrl(
        .Op(opcode),
        .Funct7(funct7),
        .Funct3(funct3),
        .Zero(zero),
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
    assign NPCOp = ctrl_signals[13:15];
    
    // read register file
    // RD1 was defined front of the module
    wire [31:0] RD2;
    wire [4:0] rs1; assign rs1 = ID_inst[19:15];
    wire [4:0] rs2; assign rs2 = ID_inst[24:20];
    wire [4:0] rd; assign rd = ID_inst[11:7];
    wire [4:0] wrdtadr; // from WB stage
    wire RegWrite;
    reg [31:0] wrdt;
    RF U_RF(
        .clk(clk),
        .rst(reset),
        .RFWr(RegWrite),
        .RdAdr1(rs1),
        .RdAdr2(rs2),
        .WrDtAdr(wrdtadr),
        .WrDt(wrdt),
        .RdDt1(RD1),
        .RdDt2(RD2)
    );

    // immediate generation
    wire iimm_shamt; assign iimm_shamt = ID_inst[24:20];
    wire iimm; assign iimm = ID_inst[31:20];
    wire simm; assign simm = { ID_inst[31:25], ID_inst[11:7] };
    wire sbimm; assign sbimm = { ID_inst[31], ID_inst[7], ID_inst[30:25], ID_inst[11:8] };
    wire uimm; assign uimm = ID_inst[31:12];
    wire uijmm; assign ujimm = { ID_inst[31], ID_inst[19:12], ID_inst[20], ID_inst[30:21] };
    wire EXTOp; assign EXTOp = ctrl_signals[7:2];
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

    // judge branch in ID stage
    JudgeBranch U_JudgeBranch(
        .inst(ID_inst),
        .rd1(RD1),
        .rd2(RD2),
        .zero(zero)
    );

    wire ID_EX_write_enable;
    wire ID_EX_flush;
    StageReg #(.WIDTH(200)) U_ID_EX(clk, reset, ID_EX_write_enable, ID_EX_flush, , );
    assign U_ID_EX.in[31:0] = PC_out;
    assign U_ID_EX.in[36:32] = rs1;
    assign U_ID_EX.in[41:37] = rs2;
    assign U_ID_EX.in[46:42] = rd;
    assign U_ID_EX.in[95:64] = ctrl_signals;
    assign U_ID_EX.in[127:96] = RD1;
    assign U_ID_EX.in[159:128] = RD2;
    assign U_ID_EX.in[191:160] = immout;

    /*
    <<<<<<< EX Stage >>>>>>>
    */

    // get PC, registers, control signals and immediate from ID/EX register
    wire [31:0] EX_RD1; assign EX_RD1 = U_ID_EX.out[127:96];
    wire [31:0] EX_RD2; assign EX_RD2 = U_ID_EX.out[159:128];
    wire [31:0] EX_signals; assign EX_signals = U_ID_EX.out[95:64];
    wire [31:0] EX_immout; assign EX_immout = U_ID_EX.out[191:160];
    wire [31:0] EX_PC_out; assign EX_PC_out = U_ID_EX.out[31:0];
    wire [31:0] EX_inst; assign EX_inst = U_ID_EX.out[63:32];
    wire [4:0] EX_rs1; assign EX_rs1 = U_ID_EX.out[36:32];
    wire [4:0] EX_rs2; assign EX_rs2 = U_ID_EX.out[41:37];
    wire [4:0] EX_rd; assign EX_rd = U_ID_EX.out[46:42];
    wire [4:0] EX_MEM_rd;
    wire [4:0] MEM_WB_rd;
    wire EX_MEM_WB;
    wire MEM_WB_WB;

    // ALU
    wire [31:0] ALUout;

    wire forwardA, forwardB;

    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] MEM_ALUout; 
    wire [31:0] WB_ALUout;

    mux3 Amux(
        .sel(forwardA),
        .in0(EX_RD1),
        .in1(WB_ALUout),
        .in2(MEM_ALUout),
        .out(A)
    );

    wire Bin0temp = (EX_signals[16]) ? EX_immout : EX_RD2;

    mux3 Bmux(
        .sel(forwardB),
        .in0(Bin0temp),
        .in1(WB_ALUout),
        .in2(MEM_ALUout),
        .out(B)
    );

    alu U_alu(
        .A(A),
        .B(B),
        .ALUOp(EX_signals[12:8]),
        .C(ALUout),
        .PC(EX_PC_out)
    );

    // forward
    
    ForwardUnit U_ForwardUnit(
        .ID_EX_Rs1(EX_rs1),
        .ID_EX_Rs2(EX_rs2),
        .EX_MEM_Rd(EX_MEM_rd),
        .MEM_WB_Rd(MEM_WB_rd),
        .EX_MEM_WB(EX_MEM_WB),
        .MEM_WB_WB(MEM_WB_WB),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    wire EX_MEM_write_enable;
    wire EX_MEM_flush;
    StageReg #(.WIDTH(200)) U_EX_MEM(clk, reset, EX_MEM_write_enable, EX_MEM_flush, , );
    assign U_EX_MEM.in[31:0] = EX_PC_out;
    assign U_EX_MEM.in[46:42] = EX_rd;
    assign U_EX_MEM.in[95:64] = EX_signals;
    assign U_EX_MEM.in[127:96] = EX_RD1;
    assign U_EX_MEM.in[159:128] = EX_RD2;
    assign U_EX_MEM.in[191:160] = ALUout;

    /*
    <<<<<<< MEM Stage >>>>>>>
    */

    // get PC, registers, control signals and immediate from EX/MEM register
    wire [31:0] MEM_PC_out; assign MEM_PC_out = U_EX_MEM.out[31:0];
    wire [4:0] MEM_rd; assign MEM_rd = U_EX_MEM.out[46:42];
    wire [31:0] MEM_signals; assign MEM_signals = U_EX_MEM.out[95:64];
    wire [31:0] MEM_RD1; assign MEM_RD1 = U_EX_MEM.out[127:96];
    wire [31:0] MEM_RD2; assign MEM_RD2 = U_EX_MEM.out[159:128];
    assign MEM_ALUout = U_EX_MEM.out[191:160];

    // data memory
    assign Addr_out = MEM_ALUout;
    assign Data_out = MEM_RD2;
    assign dm_ctrl = MEM_signals[19:17];
    wire [31:0] rd_data; assign rd_data = Data_in;
    assign mem_w = MEM_signals[1];

    // forward
    assign EX_MEM_WB = MEM_signals[0];
    assign EX_MEM_rd = MEM_rd;

    wire MEM_WB_write_enable;
    wire MEM_WB_flush;
    StageReg #(.WIDTH(200)) U_MEM_WB(clk, reset, MEM_WB_write_enable, MEM_WB_flush, , );
    assign U_MEM_WB.in[31:0] = MEM_PC_out;
    assign U_MEM_WB.in[46:42] = MEM_rd;
    assign U_MEM_WB.in[63:32] = MEM_ALUout;
    assign U_MEM_WB.in[95:64] = MEM_signals;
    assign U_MEM_WB.in[127:96] = MEM_RD1;
    assign U_MEM_WB.in[159:128] = MEM_RD2;
    assign U_MEM_WB.in[191:160] = rd_data;

    /*
    <<<<<<< WB Stage >>>>>>>
    */

    // get PC, registers, control signals and immediate from MEM/WB register
    wire [31:0] WB_PC_out; assign WB_PC_out = U_MEM_WB.out[31:0];
    wire [4:0] WB_rd; assign WB_rd = U_MEM_WB.out[46:42];
    assign WB_inst = U_MEM_WB.out[63:32];
    wire [31:0] WB_signals; assign WB_signals = U_MEM_WB.out[95:64];
    wire [31:0] WB_RD1; assign WB_RD1 = U_MEM_WB.out[127:96];
    wire [31:0] WB_RD2; assign WB_RD2 = U_MEM_WB.out[159:128];
    wire [31:0] WB_rd_data; assign WB_rd_data = U_MEM_WB.out[191:160];
    
    // write back
    assign RegWrite = WB_signals[0];
    assign wrdtadr = WB_RD2;
    wire WB_WD_Sel; assign WB_WD_Sel = WB_signals[23:22];
    always @(*) begin
        case (WB_WD_Sel)
            `WDSel_FromALU: wrdt <= WB_ALUout;
            `WDSel_FromMEM: wrdt <= WB_rd_data;
            `WDSel_FromPC: wrdt <= WB_PC_out;
        endcase
    end

    // forward
    assign MEM_WB_WB = WB_signals[0];
    assign MEM_WB_rd = WB_rd;

endmodule