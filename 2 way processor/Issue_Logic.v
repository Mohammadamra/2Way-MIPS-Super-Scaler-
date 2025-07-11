module Issue_Logic (
		input clk,
		input [31:0] inst_0, PC_0,       // Instruction 0
		input [31:0] inst_1, PC_1,      // Instruction 1
		output reg [31:0] Way_0_inst, W0_PC,  // Instruction for Way 0
		output reg [31:0] Way_1_inst, W1_PC,
		output reg Way_0_busy,
		output reg Way_0_oldest
);

    // Extract opcodes from instructions
    wire [5:0] OpCode_0 = inst_0[31:26];  // Opcode for inst_0
    wire [5:0] OpCode_1 = inst_1[31:26];  // Opcode for inst_1
	 wire [5:0] Func_0	= inst_0 [5:0];
	 wire [5:0] Func_1	= inst_1 [5:0];
		reg Way_0;

    // Define opcodes for specific instruction types		
    localparam JR_OpCode 	 =	6'b000000,
					JR_Func      = 6'b001000,  // Jump Register Function
               BEQ_OpCode   = 6'b000100,  // OpCode for Branch on Equal instruction
               BNE_OpCode   = 6'b000101,  // OpCode for BNE instruction
               JAL_OpCode   = 6'b000011,  // OpCode for Jump and Link instruction
               LW_OpCode    = 6'b100011,  // OpCode for Load Word instruction
               SW_OpCode    = 6'b101011,  // OpCode for Store Word instruction
               J_OpCode     = 6'b000010;  // OpCode for Jump instruction

    // Combinational logic to steer instructions to the correct way
    always @(*) begin
        // Default assignments (if no match, instructions are not assigned to any way)
      Way_0_inst = 32'b0;
      Way_1_inst = 32'b0;
		Way_0	= 1'b0;
		Way_0_busy = 1'b0;
		Way_0_oldest = 1'b0;
		W0_PC = 32'b0;
		W1_PC = 32'b0;

		if ((OpCode_0 == JR_OpCode && Func_0 == JR_Func )      || 
            (OpCode_0 == BEQ_OpCode)   || 
            (OpCode_0 == BNE_OpCode)   || 
            (OpCode_0 == JAL_OpCode)   || 
            (OpCode_0 == LW_OpCode)    || 
            (OpCode_0 == SW_OpCode)    || 
            (OpCode_0 == J_OpCode)) begin
			
			Way_0_inst = inst_0;
			Way_0	= 1'b1;
			Way_0_oldest = 1'b1;
			W0_PC = PC_0;
			end
			
		else begin
			Way_1_inst = inst_0;
			W1_PC = PC_0;
			end
			
		if (!Way_0) begin
			Way_0_inst = inst_1;
			Way_0	= 1'b1;
			W0_PC = PC_1;
			end
		else if ((OpCode_1 == JR_OpCode && Func_1 == JR_Func) || 
            (OpCode_1 == BEQ_OpCode)   || 
            (OpCode_1 == BNE_OpCode)   || 
            (OpCode_1 == JAL_OpCode)   || 
            (OpCode_1 == LW_OpCode)    || 
            (OpCode_1 == SW_OpCode)    || 
            (OpCode_1 == J_OpCode)) begin
			Way_0_busy = 1'b1;
			Way_1_inst = inst_1;
			W1_PC = PC_1;
		end
		else begin
			Way_1_inst = inst_1;
			W1_PC = PC_1;
		end
		
    end

endmodule 