module TwoWaysTopModule (
    input  Reset, clk,
    output [31:0] instruction_0, instruction_1 // Modified: Two instruction outputs for superscalar
	 //,output  Branch_EX, falseTaken, falseNotTaken, Flush, hazard_detected
);

// Wires Declaration

// IF
wire [31:0] IF_inst_0, IF_inst_1, inst_1, inst_0, W0_PC, W1_PC, W0_PC_EX, W0_PC_ID; // Modified: Two instructions fetched in parallel
wire [31:0] PC_in ;
wire [31:0] PC_out;
wire [31:0] nextPC, nextPC__, MUX_WB_out; // falseNotTaken, falseTaken,
wire  Branch_EX, falseTaken, falseNotTaken, Flush_0, Flush_1, hazard_detected_0, hazard_detected_1, hazard_detected_EX_0, hazard_detected_EX_1;
wire Way_0_busy;
wire [31:0] ALU_FinalB_0, ALU_FinalB_1;
//---------------------------------------------------------------------------
// ID
wire [31:0] ID_inst_0, ID_inst_1, ID_PC; // Modified: Two ID instructions
wire [3:0]  AluOp_0, AluOp_1; // Modified: ALU operations for two instructions
wire RegDst_0, RegDst_1, AluSrc_0, AluSrc_1, RegWrite_0, RegWrite_1, Memread, Memwrite, Branch, Jmp, JR, JAL, Branch_taken, MemtoReg, MemtoReg_ID_out, MemtoReg_EX, MemtoReg_MEM, MemtoReg_WB; // Modified: Control signals for two instructions
wire [31:0] readData1_ID_0, readData2_ID_0, readData1_ID_1, readData2_ID_1; // Modified: Read data for two instructions
wire [31:0] imm_ext_ID_0, imm_ext_ID_1; // Modified: Immediate extensions for two instructions
wire [13:0] control_signals_in2_0 = {AluOp_0, RegDst_0, AluSrc_0, RegWrite_0, Memread, Memwrite, Branch, Jmp, JR, JAL, MemtoReg}; // Modified: Control signals for instruction 0
wire [6:0] control_signals_in2_1 = {AluOp_1, RegDst_1, AluSrc_1, RegWrite_1}; // Modified: Control signals for instruction 1
wire [3:0] AluOp_ID_out_0, AluOp_ID_out_1; // Modified: ALU operation outputs
wire RegDst_ID_out_0, RegDst_ID_out_1, AluSrc_ID_out_0, AluSrc_ID_out_1, RegWrite_ID_out_0, RegWrite_ID_out_1, Memread_ID_out, Memwrite_ID_out, Branch_ID_out, Jmp_ID_out, JR_ID_out, JAL_ID_out; // Modified: Control signal outputs
//wire hazard_detected, IF_IDWrite;
//---------------------------------------------------------------------------
// Ex
wire [31:0] EX_inst_0, EX_inst_1; // Modified: Two EX instructions
reg [31:0]  ALU_A_0, ALU_B_0, ALU_A_1, ALU_B_1; // Modified: ALU inputs for two instructions
wire [2:0] ForwardA_0, ForwardB_0, ForwardA_1, ForwardB_1, ForwardA_EX_0, ForwardB_EX_0, ForwardA_EX_1, ForwardB_EX_1; // Modified: Forwarding signals for two instructions
wire [31:0] EX_PC, readData1_EX_0, readData2_EX_0, imm_ext_EX_0, readData1_EX_1, readData2_EX_1, imm_ext_EX_1; // Modified: Data from ID for two instructions
wire [3:0] AluOp_EX_1, AluOp_EX_0;													// EXECUTION  Branch_EX, // Modified: ALU operations for two instructions
wire RegDst_EX_0, RegDst_EX_1, AluSrc_EX_0, AluSrc_EX_1, RegWrite_EX_0, RegWrite_EX_1, Memread_EX, Memwrite_EX, Jmp_EX, JAL_EX, JR_EX; // Modified: Control signals for two instructions
wire [31:0] branch_target_EX;
wire [31:0] aluResult_EX_0, aluResult_EX_1; // Modified: ALU results for two instructions
wire [4:0] WriteReg_EX_0, WriteReg_EX_1, WriteReg_ID_0, WriteReg_ID_1; // Modified: Write registers for two instructions
wire [31:0] jump_target_EX, jump_target, branch_target_H;
reg [31:0] aluResult_out_0, aluResult_out_1;
//---------------------------------------------------------------------------
// MEM
wire [31:0] MEM_inst_0, MEM_inst_1, MEM_PC, aluResult_MEM_0, aluResult_MEM_1;
wire [31:0] ALU_B_MEM_0;
wire [31:0] DM_readData;
wire Memread_MEM, Memwrite_MEM, RegWrite_MEM_0, RegWrite_MEM_1, AL_MEM, JAL_MEM;
wire [4:0] WriteReg_MEM_0, WriteReg_MEM_1;
wire [31:0] JRMUX_out;
wire RegDst_MEM_0, RegDst_MEM_1, PCWrite;
//---------------------------------------------------------------------------
// WB
wire [31:0] WB_inst_0, WB_inst_1, DM_readData_WB, aluResult_WB_1, aluResult_WB_0, WAY_CORR_Wire;
wire RegWrite_WB_0, RegWrite_WB_1, JAL_WB;
wire [31:0] WB_PC;
wire [4:0] WriteReg_WB_0, WriteReg_WB_1, THEWriteReg;
wire [31:0] WriteData, imm_ext_IF_0, imm_ext_IF_1;
wire [31:0] final_address, branch_target_ID, updated_pc_IF, updated_pc_IF_, updated_pc_ID, updated_pc_EX, FalseTakenMux_out, Awire;

wire [4:0] GHPT_index_EX, GHPT_index_ID, GHPT_index_IF, GHR_EX, GHR_ID, GHR_IF;
wire [4:0] G_BTB_index_EX, G_BTB_index_ID, G_BTB_index_IF;

wire prediction, ID_prediction, EX_prediction, branchTaken;
wire [31:0] shifter_result_0, shifter_result_1;
wire Way_0_oldest, Way_0_oldest_ID, Way_0_oldest_EX, Way_0_oldest_MEM, WAW_stall_W1, WAW_stall_W0;
//---------------------------------------------------------------------------

assign instruction_0 = WB_inst_0; // IF_inst
assign instruction_1 = WB_inst_1;


MUX2x1 #(32) WAY_CORR (			
.inL_1(W1_PC), .inL_0(final_address),	// updated_pc_EX is not needed
.sel(Way_0_busy), .out(WAY_CORR_Wire)
);

MUX2x1 #(32) FalseTakenMux(
.inL_0(WAY_CORR_Wire), .inL_1(W0_PC_EX + 1'b1), .sel(falseTaken), .out(FalseTakenMux_out)
);

MUX2x1 #(32) FalseNotTakenMux(
.inL_0(FalseTakenMux_out), .inL_1(branch_target_EX), .sel(falseNotTaken), .out(Awire)
);

MUX2x1 #(32) JRMux(
.inL_1(ALU_A_0), .inL_0(Awire),
.sel(JR_EX), .out(JRMUX_out)
);


MUX2x1 #(32) PCSource_MUX (			
.inL_1(JRMUX_out), .inL_0(updated_pc_ID),	// updated_pc_EX is not needed
.sel(PCWrite), .out(updated_pc_IF)
);


Program_Counter PC (.clk(clk), .Reset(Reset), .PC_out(PC_out), .PC_in(updated_pc_IF));


TwoWayInstMem IM (.clock(clk), .address_a(updated_pc_IF[6:0]), .address_b(nextPC__[6:0]), .q_a(inst_1), .q_b(inst_0));

Adder #(32) PCAdder__ (.PC(PC_out), .a(32'd1), .f(nextPC__));
Adder #(32) PCAdder (.Reset(Reset), .PC(nextPC__), .a(32'd1), .f(nextPC));

Adder #(32) BranchAdder (.PC(nextPC), .a(imm_ext_IF_0), .f(branch_target_H));

Adder #(26) JumpAdder (.PC(nextPC), .a(IF_inst_0[25:0]), .f(jump_target)); //instruction 0

sign_extend_unit sign_extender0 (.imm(IF_inst_0[15:0]), .imm_ext(imm_ext_IF_0)); //Modified inst 0
sign_extend_unit sign_extender1 (.imm(IF_inst_1[15:0]), .imm_ext(imm_ext_IF_1)); //Modified inst 0

Issue_Logic IL( .clk(clk), .PC_0(updated_pc_IF), .PC_1(nextPC__), .inst_0(inst_0), .inst_1(inst_1), .Way_0_inst(IF_inst_0), .Way_1_inst(IF_inst_1), .Way_0_oldest(Way_0_oldest),
 .Way_0_busy(Way_0_busy), .W0_PC(W0_PC), .W1_PC(W1_PC));

BranchPreddictionUnitt BPU (.clk(clk), .Reset(Reset), .PC(PC_out), .nextPC(nextPC), .branch_target(branch_target_H), .jump_target(jump_target),
 .branchTaken(branchTaken), .Opcode(IF_inst_0[31:26]), .prediction(prediction), .final_address(final_address),
 .Branch_EX(Branch_EX), .branch_target_EX(branch_target_EX),  .GHR(GHR_IF) ,.GHPT_index_in(GHPT_index_EX), .GHR_in(GHR_EX), .GHPT_index(GHPT_index_IF), .G_BTB_index_in(G_BTB_index_EX),
 .G_BTB_index(G_BTB_index_IF)
 );
//-------------------------------------------------------------------------------------------------FETCH
IF_ID_Pipe IF_ID_0 (
.Flush(Flush_0), .IF_ID_write(!hazard_detected_0), .nextPC(nextPC), .clk(clk), .W0_PC(W0_PC), .W0_PC_ID(W0_PC_ID),
.Reset(Reset), .IF_inst(IF_inst_0), .ID_inst(ID_inst_0), .ID_PC(ID_PC), .prediction(prediction),.ID_prediction(ID_prediction), .branch_target(branch_target_H), .branch_target_ID(branch_target_ID),
 .G_BTB_index_IF(G_BTB_index_IF),  .GHPT_index_IF(GHPT_index_IF), .GHR_IF(GHR_IF), .GHPT_index_ID(GHPT_index_ID), .GHR_ID(GHR_ID), .oldest(Way_0_oldest), .oldest_ID(Way_0_oldest_ID), 
 .G_BTB_index_ID(G_BTB_index_ID),  .updated_pc_IF(updated_pc_IF), .updated_pc_ID(updated_pc_ID), .imm_ext_IF(imm_ext_IF_0), .imm_ext_ID(imm_ext_ID_0)
);

IF_ID_Pipe IF_ID_1 (
.Flush(Flush_1), .IF_ID_write(!hazard_detected_1), .clk(clk),
.Reset(Reset), .IF_inst(IF_inst_1), .ID_inst(ID_inst_1),
.imm_ext_IF(imm_ext_IF_1), .imm_ext_ID(imm_ext_ID_1)
);

//-------------------------------------------------------------------------------------------------
Controller_0 CU_0 ( // Modified: Control unit for instruction 0
.OpCode_0(ID_inst_0[31:26]), .Func_0(ID_inst_0[5:0]), .AluOp_0(AluOp_0),
.RegDst_0(RegDst_0), .AluSrc_0(AluSrc_0), .MemtoReg_0(MemtoReg),
.RegWrite_0(RegWrite_0), .Memread_0(Memread), .Memwrite_0(Memwrite),
.Branch(Branch), .Jmp(Jmp), .JR(JR), .JAL(JAL)
);

Controller_1 CU_1 ( // Modified: Control unit for instruction 1
.OpCode_1(ID_inst_1[31:26]), .Func_1(ID_inst_1[5:0]), .AluOp(AluOp_1),
.RegDst_1(RegDst_1), .AluSrc_1(AluSrc_1),
.RegWrite_1(RegWrite_1)//, .Memread(Memread_1), .Memwrite(Memwrite_1),
					 // .Branch(Branch_1), .Jmp(Jmp_1), .JR(JR_1), .JAL(JAL_1)
);

Registers_File RegFile (
.clk(clk), .Reset(Reset), .RegWrite1(RegWrite_WB_0), .RegWrite2(RegWrite_WB_1), .readData1_1(readData1_ID_0),
.readData2_1(readData2_ID_0), .readData1_2(readData1_ID_1), .readData2_2(readData2_ID_1), .WriteData1(WriteData),
 .WriteData2(aluResult_WB_1), .WriteReg_WB1(THEWriteReg), .WriteReg_WB2(WriteReg_WB_1), .rs1(ID_inst_0[25:21]),
 .rt1(ID_inst_0[20:16]), .rs2(ID_inst_1[25:21]), .rt2(ID_inst_1[20:16])
);

MUX2x1 #(14) ctrl_MUX_0 (//&& !JR_EX //Modified For Instruction 0
.sel(hazard_detected_0), .inL_1(14'b0), .inL_0(control_signals_in2_0),
.out({AluOp_ID_out_0, RegDst_ID_out_0, AluSrc_ID_out_0, RegWrite_ID_out_0, Memread_ID_out, Memwrite_ID_out, Branch_ID_out, Jmp_ID_out, JR_ID_out, JAL_ID_out, MemtoReg_ID_out})
);

MUX2x1 #(7) ctrl_MUX_1 (//&& !JR_EX //Modified For Instruction 1
.sel(hazard_detected_1), .inL_1(7'b0), .inL_0(control_signals_in2_1),
.out({AluOp_ID_out_1, RegDst_ID_out_1, AluSrc_ID_out_1, RegWrite_ID_out_1})
);

hazard_detection_unit HDU (
.FalseNotTaken(falseNotTaken), .JR_EX(JR_EX), .FalseTaken(falseTaken), .Flush_0(Flush_0), .Flush_1(Flush_1), // These solve JR, FalseTaken & FalseNotTaken
.WriteReg_ID_0(WriteReg_ID_0), .WriteReg_ID_1(WriteReg_ID_1), .Way_0_oldest_ID(Way_0_oldest_ID), .hazard_detected_0(hazard_detected_0), .hazard_detected_1(hazard_detected_1),			 // These solve WAW
 .Memread_EX(Memread_EX), .Memread_ID(Memread), .ID_inst_0(ID_inst_0), .ID_inst_1(ID_inst_1), .EX_inst_0(EX_inst_0), .EX_inst_1(EX_inst_1), .Way_0_busy(Way_0_busy), //.JR_IS(JR_ID), .JR_EX(JR_EX),
 .PCWrite(PCWrite) //,, .LW_H(LW_H), .LW_H_EX(LW_H_EX)
);

/*
forwarding_unit FU (
.ID_IS_Rd(WriteReg_ID_0), .IS_EX_Rd(WriteReg_EX_0), .EX_MEM_Rd(WriteReg_MEM_0), .ID_IS_Rs_0(ID_inst_0[25:21]), .ID_IS_Rs_1(ID_inst_1[25:21]), .RegWrite_EX_0(RegWrite_EX_0), .RegWrite_EX_1(RegWrite_EX_1), .MEM_WB_Rd(WriteReg_WB_0), .RegWrite_WB(RegWrite_WB_0),
 .ID_IS_Rt_0(ID_inst_0[20:16]), .ID_IS_Rt_1(ID_inst_1[20:16]) , .ForwardA_0(ForwardA_0), .ForwardB_0(ForwardB_0),.ForwardA_1(ForwardA_1), .ForwardB_1(ForwardB_1), .RegWrite_MEM(RegWrite_MEM), .JAL_EX_0(
 _0), .JAL_EX_1(JAL_EX_1), .JAL_MEM(JAL_MEM), .JAL_WB(JAL_WB) //
);*/

Forwarding_Logic u_Forwarding_Logic (
    .Way_0_rs(ID_inst_0[25:21]),
    .Way_0_rt(ID_inst_0[20:16]),
    .Way_1_rs(ID_inst_1[25:21]),
    .Way_1_rt(ID_inst_1[20:16]),
	 .Way_0_oldest_ID(Way_0_oldest_ID),
	 .Way_0_oldest_EX(Way_0_oldest_EX),
	 .Way_0_oldest_MEM(Way_0_oldest_MEM),
    .Way_0_rd_D(WriteReg_ID_0),
    .Way_1_rd_D(WriteReg_ID_1),
    .Way_0_rd_E(WriteReg_EX_0),
    .Way_1_rd_E(WriteReg_EX_1),
    .Way_0_rd_M(WriteReg_MEM_0),
    .Way_1_rd_M(WriteReg_MEM_1),
	 .JAL_EX(JAL_EX), .JAL_MEM(JAL_MEM),
    .Way_0_reg_write_D(RegWrite_ID_out_0),
    .Way_1_reg_write_D(RegWrite_ID_out_1),
    .Way_0_reg_write_E(RegWrite_EX_0),
    .Way_1_reg_write_E(RegWrite_EX_1),
    .Way_0_reg_write_M(RegWrite_MEM_0),
    .Way_1_reg_write_M(RegWrite_MEM_1),
    .Way_0_forward_A(ForwardA_0),
    .Way_0_forward_B(ForwardB_0),
    .Way_1_forward_A(ForwardA_1),
    .Way_1_forward_B(ForwardB_1)
  );

MUX2x1 #(5) MUX32_0 (
.inL_1(ID_inst_0[15:11]), .inL_0(ID_inst_0[20:16]),
.sel(RegDst_ID_out_0), .out(WriteReg_ID_0)
);

MUX2x1 #(5) MUX32_1 (
.inL_1(ID_inst_1[15:11]), .inL_0(ID_inst_1[20:16]),
.sel(RegDst_ID_out_1), .out(WriteReg_ID_1)
);


//-------------------------------------------------------------------------------------------------DECODE
ID_EX_Pipe ID_EX_0(
 .ID_PC(ID_PC), .EX_PC(EX_PC), .Flush(Flush_0), .clk(clk), .Reset(Reset), .readData1(readData1_ID_0), .readData2(readData2_ID_0),
 .imm_ext(imm_ext_ID_0), .ID_inst(ID_inst_0), .readData1_out(readData1_EX_0), .JR(JR_ID_out), .readData2_out(readData2_EX_0),
 .imm_ext_out(imm_ext_EX_0), .EX_inst(EX_inst_0), .ForwardA(ForwardA_0), .ForwardB(ForwardB_0), .ForwardA_EX(ForwardA_EX_0),
 .ForwardB_EX(ForwardB_EX_0), .ID_prediction(ID_prediction), .branch_target_ID(branch_target_ID),  .GHPT_index_ID(GHPT_index_ID),
 .GHR_ID(GHR_ID), .updated_pc_ID(updated_pc_ID), .G_BTB_index_ID(G_BTB_index_ID), .hazard_detected(hazard_detected_0),
 .hazard_detected_EX(hazard_detected_EX_0), .EX_prediction(EX_prediction), .branch_target_EX(branch_target_EX),
 .GHPT_index_EX(GHPT_index_EX), .GHR_EX(GHR_EX), .updated_pc_EX(updated_pc_EX), .G_BTB_index_EX(G_BTB_index_EX), .W0_PC_ID(W0_PC_ID), .W0_PC_EX(W0_PC_EX),
 .AluOp_out(AluOp_ID_out_0), .RegDst_out(RegDst_ID_out_0), .WriteReg_ID(WriteReg_ID_0),  .AluSrc_out(AluSrc_ID_out_0),
 .RegWrite_out(RegWrite_ID_out_0), .Memread_out(Memread_ID_out), .Memwrite_out(Memwrite_ID_out), .Branch_out(Branch_ID_out),
 .Jmp_out(Jmp_ID_out), .JAL_out(JAL_ID_out), .Memwrite_EX(Memwrite_EX), .JR_EX(JR_EX), .WriteReg_EX(WriteReg_EX_0),
 .RegWrite_EX(RegWrite_EX_0), .RegDst_EX(RegDst_EX_0), .Branch_EX(Branch_EX), .Memread_EX(Memread_EX), .oldest_ID(Way_0_oldest_ID), .oldest_EX(Way_0_oldest_EX),
 .Jmp_EX(Jmp_EX), .JAL_EX(JAL_EX), .AluSrc_EX(AluSrc_EX_0), .AluOp_EX(AluOp_EX_0), .MemtoReg_ID_out(MemtoReg_ID_out), .MemtoReg_EX(MemtoReg_EX)
);

ID_EX_Pipe ID_EX_1(
 .Flush(Flush_1), .clk(clk), .Reset(Reset), .readData1(readData1_ID_1), .readData2(readData2_ID_1), .imm_ext(imm_ext_ID_1),
 .ID_inst(ID_inst_1), .readData1_out(readData1_EX_1), .readData2_out(readData2_EX_1), .imm_ext_out(imm_ext_EX_1),
 .EX_inst(EX_inst_1), .ForwardA(ForwardA_1), .ForwardB(ForwardB_1), .ForwardA_EX(ForwardA_EX_1), .ForwardB_EX(ForwardB_EX_1),
 .AluOp_out(AluOp_ID_out_1), .hazard_detected(hazard_detected_1), .hazard_detected_EX(hazard_detected_EX_1), .RegDst_out(RegDst_ID_out_1),
 .WriteReg_ID(WriteReg_ID_1),  .AluSrc_out(AluSrc_ID_out_1), .RegWrite_out(RegWrite_ID_out_1), .WriteReg_EX(WriteReg_EX_1),
 .RegWrite_EX(RegWrite_EX_1), .RegDst_EX(RegDst_EX_1), .AluSrc_EX(AluSrc_EX_1), .AluOp_EX(AluOp_EX_1)
);

//-------------------------------------------------------------------------------------------------

    localparam NO_FORWARD = 3'b000,  // No forwarding (use register file)
               FORWARD_E_0  = 3'b001,  // Forward from Execute stage Way 0
					FORWARD_E_1  = 3'b010,  // Forward from Execute stage Way 1
               FORWARD_M_0  = 3'b011,  // Forward from Memory stage Way 0
					FORWARD_M_1  = 3'b100,  // Forward from Memory stage Way 1
               FORWARD_W_0  = 3'b101,  // Forward from Writeback stage Way 0
					FORWARD_W_1  = 3'b110;  // Forward from Writeback stage Way 1

// ALU Operand A Forwarding
always @(*) begin //MOdified instruction 0
    case (ForwardA_EX_0)
		FORWARD_E_1: ALU_A_0 = aluResult_out_1;
		FORWARD_E_0: ALU_A_0 = aluResult_out_0;
		FORWARD_M_0: ALU_A_0 = aluResult_MEM_0;
		FORWARD_M_1:begin
							if(JAL_MEM) ALU_A_0 = MEM_PC;    
							else ALU_A_0 = aluResult_MEM_1;
						end
		FORWARD_W_0: ALU_A_0 = WriteData;
		FORWARD_W_1: ALU_A_0 = aluResult_WB_1;
		/*
        2'b10: ALU_A_0 = WriteData;  // Forward from WB stage
		  2'b11: ALU_A_0 = aluResult_out_1;
		  2'b01:	begin
				if(JAL_MEM) ALU_A_0 = MEM_PC;     // Forward from MEM stage
				else ALU_A_0 = aluResult_MEM_0;
					end*/
        default: ALU_A_0 = readData1_EX_0; // Use register value
    endcase
end

always @(*) begin //MOdified instruction 1
    case (ForwardA_EX_1)
		FORWARD_E_0: ALU_A_1 = aluResult_out_0;
		FORWARD_M_0: ALU_A_1 = aluResult_MEM_0;
		FORWARD_M_1:begin
							if(JAL_MEM) ALU_A_1 = MEM_PC;     
							else ALU_A_1 = aluResult_MEM_1;
						end
		FORWARD_W_0: ALU_A_1 = WriteData;
		FORWARD_W_1: ALU_A_1 = aluResult_WB_1;
		/*
        2'b10: ALU_A_1 = aluResult_WB_1;  // Forward from WB stage
		  2'b11: ALU_A_1 = aluResult_out_0;
		  2'b01:	begin
				if(JAL_MEM) ALU_A_1 = MEM_PC;     // Forward from WB stage
				else ALU_A_1 = aluResult_MEM_1;
					end*/
        default: ALU_A_1 = readData1_EX_1; // Use register value
    endcase
end

// ALU Operand B Forwarding
always @(*) begin //MOdified instruction 0
    case (ForwardB_EX_0)
		FORWARD_E_1: ALU_B_0 = aluResult_out_1;
		FORWARD_M_0: ALU_B_0 = aluResult_MEM_0;
		FORWARD_M_1: ALU_B_0 = aluResult_MEM_1;
		FORWARD_W_0: ALU_B_0 = WriteData;
		FORWARD_W_1: ALU_B_0 = aluResult_WB_1;
	 /*
        2'b10: ALU_B_0 = WriteData;
		  2'b11: ALU_B_0 = aluResult_out_1;
          2'b01:   ALU_B_0 = aluResult_MEM_0;*/
        default: ALU_B_0 = readData2_EX_0;
    endcase
     //assign ALU_B_EX = (ForwardB_EX == 2'b11) ? WB_data_IS_EX_out :
           //  (ForwardB_EX == 2'b10) ? MUX_WB_out :
            // (ForwardB_EX == 2'b10) ? aluResult_MEM :
                              //readData2_EX;/
end
always @(*) begin //MOdified instruction 1
    case (ForwardB_EX_1)
		FORWARD_E_0: ALU_B_1 = aluResult_out_0;
		FORWARD_M_0: ALU_B_1 = aluResult_MEM_0;
		FORWARD_M_1: ALU_B_1 = aluResult_MEM_1;
		FORWARD_W_0: ALU_B_1 = WriteData;
		FORWARD_W_1: ALU_B_1 = aluResult_WB_1;
		/*
        2'b10: ALU_B_1 = aluResult_WB_1;
		  2'b11: ALU_B_1 = aluResult_out_0;
          2'b01:   ALU_B_1 = aluResult_MEM_1;*/
        default: ALU_B_1 = readData2_EX_1;
    endcase

end

// Immediate Value Selection (Bypass Forwarding MUX)
assign ALU_FinalB_0 = AluSrc_EX_0 ? imm_ext_EX_0 : ALU_B_0; // Modified: Instruction 0
assign ALU_FinalB_1 = AluSrc_EX_1 ? imm_ext_EX_1 : ALU_B_1; // Modified: Instruction 1

Branch_compare BC (
.prediction(EX_prediction), .readData1_IS(ALU_A_0), .readData2_IS(ALU_B_0), .op(AluOp_EX_0), .falseTaken(falseTaken), .falseNotTaken(falseNotTaken), .branchTaken(branchTaken)
);

/*
WayAdder Adder_0 ( // Modified: ALU for instruction 0
.Operation(LW_SW_J_B_EX), .operand_1(ALU_A_0), .operand_2(imm_ext_EX_0), .Result(aluResult_EX_0)
);*/

ALU Alu_0 ( // Modified: ALU for instruction 0
.Reset(Reset), .AluOp_EX(AluOp_EX_0),
.ALU_A(ALU_A_0), .ALU_B(ALU_FinalB_0), .aluResult(aluResult_EX_0)
);

ALU Alu_1 ( // Modified: ALU for instruction 1
.Reset(Reset), .AluOp_EX(AluOp_EX_1),
.ALU_A(ALU_A_1), .ALU_B(ALU_FinalB_1), .aluResult(aluResult_EX_1)
);

Shifter shift_0(
.Shamt(EX_inst_0[10:6]), .ALU_B(ALU_FinalB_0), .op(AluOp_EX_0), .out(shifter_result_0)
);

Shifter shift_1(
.Shamt(EX_inst_1[10:6]), .ALU_B(ALU_FinalB_1), .op(AluOp_EX_1), .out(shifter_result_1)
);

always @(negedge clk) begin
		  if (AluOp_EX_0 == 4'b1000 || AluOp_EX_0 == 4'b1001)  // If the operation is Shift --> take the shifter output; else take the aluResult
		  aluResult_out_0 <= shifter_result_0;
		  else
		  aluResult_out_0 <= aluResult_EX_0;
		  
		  if (AluOp_EX_1 == 4'b1000 || AluOp_EX_1 == 4'b1001)  // If the operation is Shift --> take the shifter output; else take the aluResult
		  aluResult_out_1 <= shifter_result_1;
		  else
		  aluResult_out_1 <= aluResult_EX_1;
end

//-------------------------------------------------------------------------------------------------EXECUTION
EX_MEM_Pipe EX_MEM_0 ( 
.clk(clk), .Reset(Reset), .EX_inst(EX_inst_0), .aluResult(aluResult_out_0),
.Memread_EX(Memread_EX), .Memwrite_EX(Memwrite_EX), .RegWrite_EX(RegWrite_EX_0), .AluOp_EX(AluOp_EX_0), .ALU_B_MEM(ALU_B_MEM_0), .ALU_B(ALU_B_0),
.WriteReg(WriteReg_EX_0), .EX_PC(EX_PC), .RegDst_EX(RegDst_EX_0), .Memread_MEM(Memread_MEM), .JAL_EX(JAL_EX), .JAL_MEM(JAL_MEM),
.Memwrite_MEM(Memwrite_MEM), .MEM_PC(MEM_PC), .RegWrite_MEM(RegWrite_MEM_0), .MEM_inst(MEM_inst_0), .aluResult_out(aluResult_MEM_0), .Way_0_oldest_EX(Way_0_oldest_EX),
.WriteReg_out(WriteReg_MEM_0), .RegDst_MEM(RegDst_MEM_0),  .MemtoReg_EX(MemtoReg_EX), .MemtoReg_MEM(MemtoReg_MEM), .Way_0_oldest_MEM(Way_0_oldest_MEM)// .shifter_result(shifter_result_0),
);

EX_MEM_Pipe EX_MEM_1 ( 
.clk(clk), .Reset(Reset), .EX_inst(EX_inst_1), .aluResult(aluResult_out_1), .RegWrite_EX(RegWrite_EX_1), .AluOp_EX(AluOp_EX_1),
 .WriteReg(WriteReg_EX_1), .RegDst_EX(RegDst_EX_1), .RegWrite_MEM(RegWrite_MEM_1),
.MEM_inst(MEM_inst_1), .aluResult_out(aluResult_MEM_1), .WriteReg_out(WriteReg_MEM_1), .RegDst_MEM(RegDst_MEM_1)// ,.shifter_result(shifter_result_1)
);
//------------------------------------------------------------------------------------------------- 
dataMemory DM (
.address(aluResult_MEM_0[7:0]), .clock(~clk), .rden(Memread_MEM),
.data(ALU_B_MEM_0), .wren(Memwrite_MEM), .q(DM_readData)
);

//-------------------------------------------------------------------------------------------------MEM
MEM_WB_Pipe MEM_WB_0 ( 
.clk(clk), .Reset(Reset), .MEM_inst(MEM_inst_0), .RegWrite_MEM(RegWrite_MEM_0), .MEM_PC(MEM_PC),
.JAL_MEM(JAL_MEM), .readData(DM_readData), .WriteReg_out(WriteReg_MEM_0),.WB_inst(WB_inst_0),
.readData_out(DM_readData_WB), .JAL_WB(JAL_WB), .WB_PC(WB_PC),.RegWrite_WB(RegWrite_WB_0),
 .WriteReg_WB(WriteReg_WB_0), .MemtoReg_MEM(MemtoReg_MEM), .MemtoReg_WB(MemtoReg_WB), .aluResult_out(aluResult_MEM_0), .aluResult_WB(aluResult_WB_0)
);

MEM_WB_Pipe MEM_WB_1 ( 
.clk(clk), .Reset(Reset), .MEM_inst(MEM_inst_1), .RegWrite_MEM(RegWrite_MEM_1), .WriteReg_out(WriteReg_MEM_1),
.aluResult_out(aluResult_MEM_1), .WB_inst(WB_inst_1), .RegWrite_WB(RegWrite_WB_1), .WriteReg_WB(WriteReg_WB_1), .aluResult_WB(aluResult_WB_1)
);
//-------------------------------------------------------------------------------------------------

MUX2x1 #(32) MUX_WB (
.inL_1(DM_readData_WB), .inL_0(aluResult_WB_0),
.sel(MemtoReg_WB), .out(MUX_WB_out)
);	// Inputs were reversed 

MUX2x1 #(5) MUX_JAL1_1 (
.inL_1(5'b11111), .inL_0(WriteReg_WB_0),
.sel(JAL_WB), .out(THEWriteReg) 
);

MUX2x1 #(32) MUX_JAL2_1 (
.inL_1(WB_PC), .inL_0(MUX_WB_out),
.sel(JAL_WB), .out(WriteData) 
);
// These two muxs are just for way 0
//-------------------------------------------------------------------------------------------------WB

endmodule