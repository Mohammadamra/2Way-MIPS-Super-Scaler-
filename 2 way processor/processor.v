module processor (
    input  Reset, clk,
    output [31:0] instruction
	 ,output  Branch_EX, falseTaken, falseNotTaken, Flush, hazard_detected
);

// Wires Declaration 

// IF
wire [31:0] IF_inst;
wire [31:0] PC_in ;
wire [31:0] PC_out;
wire [31:0] nextPC; // falseNotTaken, falseTaken,
//wire  Branch_EX, falseTaken, falseNotTaken, Flush, hazard_detected;
//---------------------------------------------------------------------------
// ID
wire [31:0] ID_inst, ID_PC, PC_outD;
wire [3:0] AluOp;
wire RegDst, MemtoReg, AluSrc, RegWrite, Memread, Memwrite, Branch, Jmp, JR, JAL, Branch_taken;
wire [31:0] readData1_ID, readData2_ID;
wire [31:0] imm_ext_ID;
wire [13:0] control_signals_in1 = 14'b0;
wire [13:0] control_signals_in2 = {AluOp, RegDst, MemtoReg, AluSrc, RegWrite, Memread, Memwrite, Branch, Jmp, JR, JAL};
wire [3:0] AluOp_ID_out;
wire RegDst_ID_out, MemtoReg_ID_out, AluSrc_ID_out, RegWrite_ID_out, Memread_ID_out, Memwrite_ID_out, Branch_ID_out, Jmp_ID_out, JR_ID_out, JAL_ID_out;
//wire hazard_detected, IF_IDWrite;
//---------------------------------------------------------------------------
// Ex
wire [31:0] EX_inst;
reg [31:0]  ALU_A;
reg [31:0] ALU_B ;
wire [1:0] ForwardA, ForwardB;
wire [31:0] EX_PC, readData1_EX, readData2_EX, imm_ext_EX;
wire [3:0] AluOp_EX;													// EXECUTION  Branch_EX,
wire RegDst_EX, MemtoReg_EX, AluSrc_EX, RegWrite_EX, Memread_EX, Memwrite_EX, Jmp_EX, JAL_EX;
wire [31:0] branch_target_EX;
wire Zero;
wire [31:0] aluResult_EX;
wire JR_EX;
wire [4:0] WriteReg_EX, WriteReg_ID;
wire [31:0] jump_target_EX, jump_target, branch_target_H;
//---------------------------------------------------------------------------
// MEM
wire [31:0] MEM_inst, MEM_PC, aluResult_MEM;
wire [31:0] ALU_A_MEM, ALU_B_MEM;
wire [31:0] jump_target_MEM;
wire [31:0] branch_target_MEM;											
wire [31:0] DM_readData;
wire Branch_MEM, Memread_MEM, Memwrite_MEM, MemtoReg_MEM, RegWrite_MEM, Jmp_MEM, JAL_MEM;
wire [4:0] WriteReg_MEM;
wire Zero_MEM, JR_MEM;
wire [31:0] JRMUX_out;
wire [31:0] JumpMux_out, BranchMux_out;
wire RegDst_MEM, PCWrite;//,Flush;
//---------------------------------------------------------------------------
// WB
wire [31:0] WB_inst, DM_readData_WB, aluResult_WB;
wire MemtoReg_WB, RegWrite_WB, JAL_WB;
wire [31:0] WB_PC;
wire [4:0] WriteReg_WB, THEWriteReg;
wire [31:0] WriteData, imm_ext_IF;
wire [31:0] MUX_WB_out, final_address, branch_target_ID, updated_pc_IF, updated_pc_ID, updated_pc_EX, FalseTakenMux_out, Awire;


wire [4:0] index_IS, index_ID, index_out, index_EX;
wire choose_G_EX, LW_H, LW_H_EX;
wire [3:0] LHR_index_EX, LHR_index_IS, LHR_index_ID, LHR_index_IF, LHPT_index_EX, LHPT_index_IS, LHPT_index_ID, LHPT_index_IF;
wire [3:0] Local_BTB_index_EX, Local_BTB_index_IS, Local_BTB_index_ID, Local_BTB_index_IF;
wire [4:0] GHPT_index_EX, GHPT_index_IS, GHPT_index_ID, GHPT_index_IF, GHR_EX, GHR_IS, GHR_ID, GHR_IF;
wire [4:0] G_BTB_index_EX, G_BTB_index_IS, G_BTB_index_ID, G_BTB_index_IF;

wire prediction, ID_prediction, EX_prediction, branchTaken, choose_G_IF, choose_G_ID;
wire [1:0] ForwardA_EX, ForwardB_EX;
//---------------------------------------------------------------------------
/*
MUX2x1 #(32) BranchMux(								// This MUX Controls Branch Instructions
.inL_1(branch_target_MEM), .inL_0(nextPC),
.sel(Branch_taken), .out(BranchMux_out) 
);

MUX2x1 #(32) JRMux(								// This MUX Controls JR Instructions
.inL_1(ALU_A_MEM), .inL_0(jump_target_MEM),
.sel(JR_MEM), .out(JRMUX_out) 
);

MUX2x1 #(32) JumpMux(								// This MUX Controls Jump Instructions
.inL_1(JRMUX_out), .inL_0(BranchMux_out),
.sel(Jmp_MEM), .out(JumpMux_out) 
);
*/
//assign Branch_taken = Zero_MEM && Branch_MEM;
/*
wire [31:0] updated_pc;


MUX2x1 #(32) PCSource_MUX (			// To handel PCWrite = 0 (Stall)
.inL_1(JumpMux_out), .inL_0(ID_PC),
.sel(PCWrite), .out(updated_pc) 
);
*/
sign_extend_unit sign_extender (.imm(IF_inst[15:0]), .imm_ext(imm_ext_IF));

assign instruction = WB_inst; // IF_inst

MUX2x1 #(32) FalseTakenMux(
.inL_0(final_address), .inL_1(EX_PC), .sel(falseTaken), .out(FalseTakenMux_out)	// final_address WAS JumpMux_out ,,, .inL_1(EX_PC)
);

MUX2x1 #(32) FalseNotTakenMux(
.inL_0(FalseTakenMux_out), .inL_1(branch_target_EX), .sel(falseNotTaken), .out(Awire)
);

MUX2x1 #(32) JRMux(								// This MUX Controls JR Instructions
.inL_1(ALU_A), .inL_0(Awire),
.sel(JR_EX), .out(JRMUX_out) 
);


MUX2x1 #(32) PCSource_MUX (			// To handel PCWrite = 0 (Stall)
.inL_1(JRMUX_out), .inL_0(updated_pc_ID),
.sel(PCWrite), .out(updated_pc_IF) //PCWrite
);



Program_Counter PC (.clk(clk), .Reset(Reset), .PC_out(PC_out), .PC_in(updated_pc_IF), .PCWrite(PCWrite));	

instructionMemory IM (.clock(clk), .address(updated_pc_IF[5:0]), .q(IF_inst));

Adder #(32) PCAdder (.PC(PC_out), .a(32'd1), .f(nextPC));

Adder #(32) BranchAdder (.PC(nextPC), .a(imm_ext_IF), .f(branch_target_H));

Adder #(26) JumpAdder (.PC(nextPC), .a(IF_inst[25:0]), .f(jump_target));


BranchPreddictionUnitt BPU (.clk(clk), .Reset(Reset), .PC(PC_out), .nextPC(nextPC), .branch_target(branch_target_H), .jump_target(jump_target), .hazard_detected(hazard_detected_EX),
 .branchTaken(branchTaken), .Opcode(IF_inst[31:26]), .prediction(prediction), .final_address(final_address),
 .Branch_EX(Branch_EX), .branch_target_EX(branch_target_EX), .index_in(index_EX), 
  .GHR(GHR_IF) ,.GHPT_index_in(GHPT_index_EX), .GHR_in(GHR_EX),  .GHPT_index(GHPT_index_IF),
 .G_BTB_index_in(G_BTB_index_EX),  .G_BTB_index(G_BTB_index_IF)
 ); 
//-------------------------------------------------------------------------------------------------FETCH
/*IF_ID_Pipe IF_ID (
/*.Flush(Flush), .IF_IDWrite(IF_IDWrite), .nextPC(nextPC), .clk(clk), .PC_out(PC_out), 	// No use for PC_out or PC_outD
.Reset(Reset), .IF_inst(IF_inst), .ID_inst(ID_inst), .ID_PC(ID_PC), .PC_outD(PC_outD)

.Flush(Flush), .IF_ID_write(!hazard_detected), .nextPC(nextPC), .clk(clk), .choose_G_IF(choose_G_IF), .choose_G_ID(choose_G_ID),	// Flush is done to IF_ID & ID_IS !!((, .PC_out(PC_out)))!!
.Reset(Reset), .IF_inst(IF_inst), .ID_inst(ID_inst), .ID_PC(ID_PC), .prediction(prediction),.ID_prediction(ID_prediction), .branch_target(branch_target_H), .branch_target_ID(branch_target_ID), 
 .Local_BTB_index_IF(Local_BTB_index_IF),  .G_BTB_index_IF(G_BTB_index_IF), .index_out(index_out), .index_ID(index_ID), .LHR_index_IF(LHR_index_IF),
 .LHPT_index_IF(LHPT_index_IF), .GHPT_index_IF(GHPT_index_IF), .GHR_IF(GHR_IF), 
   .LHR_index_ID(LHR_index_ID), .LHPT_index_ID(LHPT_index_ID), .GHPT_index_ID(GHPT_index_ID), .GHR_ID(GHR_ID),
 .Local_BTB_index_ID(Local_BTB_index_ID),  .G_BTB_index_ID(G_BTB_index_ID),  .updated_pc_IF(updated_pc_IF), .updated_pc_ID(updated_pc_ID), .imm_ext_IF(imm_ext_IF), .imm_ext_ID(imm_ext_ID)
);*/
IF_ID_Pipe IF_ID (
/*.Flush(Flush), .IF_IDWrite(IF_IDWrite), .nextPC(nextPC), .clk(clk), .PC_out(PC_out), 	// No use for PC_out or PC_outD
.Reset(Reset), .IF_inst(IF_inst), .ID_inst(ID_inst), .ID_PC(ID_PC), .PC_outD(PC_outD)
*/
.Flush(Flush), .IF_ID_write(!hazard_detected), .nextPC(nextPC), .clk(clk), 	// Flush is done to IF_ID & ID_IS !!((, .PC_out(PC_out)))!!
.Reset(Reset), .IF_inst(IF_inst), .ID_inst(ID_inst), .ID_PC(ID_PC), .prediction(prediction),.ID_prediction(ID_prediction), .branch_target(branch_target_H), .branch_target_ID(branch_target_ID), 
  .G_BTB_index_IF(G_BTB_index_IF), .index_out(index_out), .index_ID(index_ID), 
  .GHPT_index_IF(GHPT_index_IF), .GHR_IF(GHR_IF), 
     .GHPT_index_ID(GHPT_index_ID), .GHR_ID(GHR_ID),
   .G_BTB_index_ID(G_BTB_index_ID),  .updated_pc_IF(updated_pc_IF), .updated_pc_ID(updated_pc_ID), .imm_ext_IF(imm_ext_IF), .imm_ext_ID(imm_ext_ID)
);
//-------------------------------------------------------------------------------------------------
Control_Unit CU ( 
.OpCode(ID_inst[31:26]), .Func(ID_inst[5:0]), .AluOp(AluOp),
.RegDst(RegDst), .MemtoReg(MemtoReg), .AluSrc(AluSrc),
.RegWrite(RegWrite), .Memread(Memread), .Memwrite(Memwrite),
.Branch(Branch), .Jmp(Jmp), .JR(JR), .JAL(JAL)
);

Registers_File RegFile (
.clk(clk), .Reset(Reset), .RegWrite(RegWrite_WB), .readData1(readData1_ID),	// .RegWrite(RegWrite_WB) was RegWrite(ID) X 
.readData2(readData2_ID), .WriteData(WriteData), .WriteReg_WB(THEWriteReg), .rs(ID_inst[25:21]), .rt(ID_inst[20:16])	// We need the WB signal of the inst. 
);


MUX2x1 #(14) ctrl_MUX (//&& !JR_EX 
.sel(hazard_detected), .inL_1(14'b0), .inL_0(control_signals_in2),
.out({AluOp_ID_out, RegDst_ID_out, MemtoReg_ID_out, AluSrc_ID_out, RegWrite_ID_out, Memread_ID_out, Memwrite_ID_out, Branch_ID_out, Jmp_ID_out, JR_ID_out, JAL_ID_out})
);

/*hazard_detection_unit HDU ( 
.Branch(Branch_MEM), .Branch_taken(Branch_taken), .Jmp(Jmp_MEM),
.hazard_detected(hazard_detected), .PCWrite(PCWrite), .Flush(Flush),
.IF_IDWrite(IF_IDWrite), .Memread_EX(Memread_EX) ,.ID_inst(ID_inst), .EX_inst(EX_inst)
);*/

hazard_detection_unit HDU ( 
.FalseNotTaken(falseNotTaken), .FalseTaken(falseTaken), .Memread_EX(Memread_EX), .ID_inst(ID_inst), .EX_inst(EX_inst), //.JR_IS(JR_ID), .JR_EX(JR_EX), 
.Flush(Flush), .hazard_detected(hazard_detected), .PCWrite(PCWrite), .JR_EX(JR_EX) //,, .LW_H(LW_H), .LW_H_EX(LW_H_EX)
);		
/*
forwarding_unit FU (
.EX_MEM_Rd(WriteReg_MEM), .MEM_WB_Rd(WriteReg_WB), .ID_EX_Rs(EX_inst[25:21]), .RegWrite_MEM(RegWrite_MEM),
 .ID_EX_Rt(EX_inst[20:16]) , .ForwardA(ForwardA), .ForwardB(ForwardB), .RegWrite_WB(RegWrite_WB)
);*/
forwarding_unit FU (
.ID_IS_Rd(WriteReg_ID), .IS_EX_Rd(WriteReg_EX), .EX_MEM_Rd(WriteReg_MEM), .ID_IS_Rs(ID_inst[25:21]), .RegWrite_EX(RegWrite_EX), .MEM_WB_Rd(WriteReg_WB), .RegWrite_WB(RegWrite_WB),
 .ID_IS_Rt(ID_inst[20:16]) , .ForwardA(ForwardA), .ForwardB(ForwardB), .RegWrite_MEM(RegWrite_MEM), .JAL_EX(JAL_EX), .JAL_MEM(JAL_MEM), .JAL_WB(JAL_WB) //
);


MUX2x1 #(5) MUX32 (
.inL_1(ID_inst[15:11]), .inL_0(ID_inst[20:16]),
.sel(RegDst_ID_out), .out(WriteReg_ID) // Inputs were reversed
);

//-------------------------------------------------------------------------------------------------DECODE
ID_EX_Pipe ID_EX (
.ID_PC(ID_PC), .EX_PC(EX_PC),	.Flush(Flush),							//After erasing the comparator, we make the ADDing of branch address in EX stage.
.clk(clk), .Reset(Reset), .readData1(readData1_ID), .readData2(readData2_ID),
.imm_ext(imm_ext_ID), .ID_inst(ID_inst), .readData1_out(readData1_EX), .JR(JR_ID_out),
.readData2_out(readData2_EX), .imm_ext_out(imm_ext_EX), .EX_inst(EX_inst),		
.AluOp_out(AluOp_ID_out), .RegDst_out(RegDst_ID_out), .MemtoReg_out(MemtoReg_ID_out),
.AluSrc_out(AluSrc_ID_out), .RegWrite_out(RegWrite_ID_out), .Memread_out(Memread_ID_out),
.Memwrite_out(Memwrite_ID_out), .Branch_out(Branch_ID_out), .Jmp_out(Jmp_ID_out), 
.JAL_out(JAL_ID_out), .Memwrite_EX(Memwrite_EX), .JR_EX(JR_EX), .WriteReg_ID(WriteReg_ID), .WriteReg_EX(WriteReg_EX),
.AluSrc_EX(AluSrc_EX), .RegWrite_EX(RegWrite_EX), .RegDst_EX(RegDst_EX), 
.Branch_EX(Branch_EX), .Memread_EX(Memread_EX), .MemtoReg_EX(MemtoReg_EX), .ForwardA(ForwardA), .ForwardB(ForwardB), .ForwardA_EX(ForwardA_EX), .ForwardB_EX(ForwardB_EX),
.Jmp_EX(Jmp_EX), .JAL_EX(JAL_EX), .AluOp_EX(AluOp_EX), .ID_prediction(ID_prediction), .branch_target_ID(branch_target_ID),  
.LHR_index_ID(LHR_index_ID), .LHPT_index_ID(LHPT_index_ID), .GHPT_index_ID(GHPT_index_ID), .GHR_ID(GHR_ID), .updated_pc_ID(updated_pc_ID),
 .Local_BTB_index_ID(Local_BTB_index_ID),  .G_BTB_index_ID(G_BTB_index_ID), .hazard_detected(hazard_detected), .hazard_detected_EX(hazard_detected_EX)
 , .EX_prediction(EX_prediction), .branch_target_EX(branch_target_EX),  //.falseNotTaken(falseNotTaken), .falseTaken(falseTaken),
.LHR_index_EX(LHR_index_EX), .LHPT_index_EX(LHPT_index_EX), .GHPT_index_EX(GHPT_index_EX), .GHR_EX(GHR_EX), .updated_pc_EX(updated_pc_EX),
 .Local_BTB_index_EX(Local_BTB_index_EX),  .G_BTB_index_EX(G_BTB_index_EX), .index_ID(index_ID), .index_EX(index_EX), .choose_G_ID(choose_G_ID), .choose_G_EX(choose_G_EX)
);
//-------------------------------------------------------------------------------------------------
wire [31:0] ALU_FinalB;
wire [3:0] AluOp_MEM;
/*
MUX3x1 #(32) ALU_AM (
.in0(readData1_EX), .in2(WriteData),
.in1(aluResult_MEM), .select(ForwardA_EX), .out(ALU_A)
);


MUX2x1 #(32) ALU_NoFwdB (
    .inL_1(imm_ext_EX),        
    .inL_0(ALU_B),// BUG:: Was imm_ext
    .sel(AluSrc_EX),	//ALU src
    .out(ALU_FinalB)     
);

MUX3x1 #(32) ALU_BM (
.in0(readData2_EX), .in2(WriteData),
.in1(aluResult_MEM), .select(ForwardB_EX), .out(ALU_B) 
);

*/

// ALU Operand A Forwarding
always @(*) begin
    case (ForwardA_EX)
        2'b10: ALU_A = WriteData;  // Forward from WB stage
		  2'b01:	begin 
				if(JAL_MEM) ALU_A = MEM_PC;     // Forward from WB stage
				else ALU_A = aluResult_MEM;
					end
        default: ALU_A = readData1_EX; // Use register value
    endcase
end
/*
       2'b01:	begin 
				if(JAL_MEM) ALU_A_EX = MEM_PC;     // Forward from WB stage
				else ALU_A_EX = aluResult_MEM;
					end
 */
// ALU Operand B Forwarding
always @(*) begin
    case (ForwardB_EX)
        2'b10: ALU_B = WriteData; 
          2'b01:   ALU_B = aluResult_MEM;		
        default: ALU_B = readData2_EX;
    endcase
     //assign ALU_B_EX = (ForwardB_EX == 2'b11) ? WB_data_IS_EX_out :
           //  (ForwardB_EX == 2'b10) ? MUX_WB_out :
            // (ForwardB_EX == 2'b10) ? aluResult_MEM :
                              //readData2_EX;/
end/*
MUX3x1 #(32) ALU_BM (
.in0(readData2_EX), .in2(WriteData),
.in1(aluResult_MEM), .select(ForwardB_EX), .out(ALU_B) 
);
*/
// Immediate Value Selection (Bypass Forwarding MUX)
assign ALU_FinalB = AluSrc_EX ? imm_ext_EX : ALU_B;

Branch_compare BC (
.prediction(EX_prediction), .readData1_IS(ALU_A), .readData2_IS(ALU_B), .op(AluOp_EX), .falseTaken(falseTaken), .falseNotTaken(falseNotTaken), .branchTaken(branchTaken)
);
 
ALU Alu (
.clk(clk), .Reset(Reset), .AluOp_EX(AluOp_EX),
.ALU_A(ALU_A), .ALU_B(ALU_FinalB), .aluResult(aluResult_EX)//, .Shamt(EX_inst[10:6]), .Zero(Zero) // New input : ".Shamt(EX_inst[10:6])"
);

wire [31:0] shifter_result;
Shifter shift(
.Shamt(EX_inst[10:6]), .ALU_B(ALU_FinalB), .op(AluOp_EX), .out(shifter_result)
);

//-------------------------------------------------------------------------------------------------EXECUTION
EX_MEM_Pipe EX_MEM ( 
.clk(clk), .Reset(Reset), .EX_inst(EX_inst), .aluResult(aluResult_EX), .Branch_EX(Branch_EX), .jump_target_EX(jump_target_EX), .ALU_A(ALU_A),
.Memread_EX(Memread_EX), .Memwrite_EX(Memwrite_EX), .MemtoReg_EX(MemtoReg_EX), .RegWrite_EX(RegWrite_EX), .branch_target_EX(branch_target_EX),
.Jmp_EX(Jmp_EX), .JAL_EX(JAL_EX), .ALU_B(ALU_B), .WriteReg(WriteReg_EX), .ALU_B_out(ALU_B_MEM), .Flush(Flush) , .EX_PC(EX_PC), .RegDst_EX(RegDst_EX),
.Branch_MEM(Branch_MEM), .Memread_MEM(Memread_MEM), .Memwrite_MEM(Memwrite_MEM), .MemtoReg_MEM(MemtoReg_MEM), .MEM_PC(MEM_PC), .JR_EX(JR_EX), .AluOp_EX(AluOp_EX),
.RegWrite_MEM(RegWrite_MEM), .Jmp_MEM(Jmp_MEM), .JAL_MEM(JAL_MEM), .MEM_inst(MEM_inst), .branch_target_MEM(branch_target_MEM), .JR_MEM(JR_MEM),
.aluResult_out(aluResult_MEM), .WriteReg_out(WriteReg_MEM), .jump_target_MEM(jump_target_MEM), .RegDst_MEM(RegDst_MEM), .shifter_result(shifter_result)
);
//------------------------------------------------------------------------------------------------- 
dataMemory DM (
.address(aluResult_MEM[7:0]), .clock(~clk), .rden(Memread_MEM),
.data(ALU_B_MEM), .wren(Memwrite_MEM), .q(DM_readData)
);

//-------------------------------------------------------------------------------------------------MEM
MEM_WB_Pipe MEM_WB ( 
.clk(clk), .Reset(Reset), .MEM_inst(MEM_inst), .MemtoReg_MEM(MemtoReg_MEM),  .AluOp_MEM(AluOp_MEM),
.RegWrite_MEM(RegWrite_MEM), .MEM_PC(MEM_PC),
.JAL_MEM(JAL_MEM), .readData(DM_readData), .WriteReg_out(WriteReg_MEM),
.aluResult_out(aluResult_MEM), .WB_inst(WB_inst), .readData_out(DM_readData_WB),
.MemtoReg_WB(MemtoReg_WB), .JAL_WB(JAL_WB), .WB_PC(WB_PC),
.RegWrite_WB(RegWrite_WB), .WriteReg_WB(WriteReg_WB), .aluResult_WB(aluResult_WB)
);
//-------------------------------------------------------------------------------------------------
MUX2x1 #(32) MUX_WB (
.inL_1(DM_readData_WB), .inL_0(aluResult_WB),
.sel(MemtoReg_WB), .out(MUX_WB_out)
);	// Inputs were reversed 

MUX2x1 #(5) MUX_JAL1 (
.inL_1(5'b11111), .inL_0(WriteReg_WB),
.sel(JAL_WB), .out(THEWriteReg) 
);

MUX2x1 #(32) MUX_JAL2 (
.inL_1(WB_PC), .inL_0(MUX_WB_out),
.sel(JAL_WB), .out(WriteData) 
);

//-------------------------------------------------------------------------------------------------WB
endmodule