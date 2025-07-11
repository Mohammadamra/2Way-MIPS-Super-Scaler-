module Shifter(
input [4:0] Shamt,
input [31:0]ALU_B,
input [3:0] op,
output reg [31:0] out
);

always @(*)

if (op == 4'b1000)
	out = (ALU_B << Shamt);
else if (op == 4'b1001)
	out = (ALU_B >> Shamt);
else 
	out = 32'b0;


endmodule 