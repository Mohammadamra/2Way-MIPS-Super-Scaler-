module InstructionDecoder(
	input [5:0] Opcode,
	output reg J, Branch
	);
	
	always @(*) begin
		J = 1'b0;
		Branch = 1'b0;
	
		if ( Opcode == 6'b000011 || Opcode == 6'b000010 ) // If the inst. was JAL or J
			J = 1'b1;
		else if ( Opcode == 6'b000100 || Opcode == 6'b000101 ) // If the inst. was BEQ or BNE
			Branch = 1'b1;
		
		end
		
endmodule 