
module Registers_File (

	input wire clk, Reset, RegWrite, 
	output reg[31:0] readData1, readData2 ,
	input wire [4:0] WriteReg_WB,
		input wire [31:0]  WriteData,
	input wire [4:0]  rs, rt
	);
	
	reg [31:0] registers [0:31];
	
	always @(*) begin
    readData1 <= registers[rs];
    readData2 <= registers[rt];
end

	always@(negedge clk,  posedge Reset) begin : writing_on_registers	
																							
		integer i;																		
		
		if(Reset) begin	
			for(i=0; i<32; i = i + 1) 
			registers[i] <= 0;
		end
		
		else if ( RegWrite && (WriteReg_WB != 5'b00000))
		
		begin
			registers[WriteReg_WB] <= WriteData;
		end
		
	end

endmodule



