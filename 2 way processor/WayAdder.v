module WayAdder (
input [31:0] operand_1,
input [31:0] operand_2,
input [1:0] Operation, 
output reg [31:0] Result
);

always @ (*) begin 
	if(Operation == 2'b11) begin 
		Result <= operand_1 + operand_2;
		end 
	else
		Result <= 32'b0;
			end 
				endmodule 
				
				
