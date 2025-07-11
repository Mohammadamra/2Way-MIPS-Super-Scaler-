module MEM_WB_Pipe (
    input wire clk,
    input wire Reset,
    input wire [31:0] MEM_inst,
    input wire RegWrite_MEM,
    input wire [31:0] readData,
    input wire [4:0] WriteReg_out,
    input wire [31:0] aluResult_out,
	 input wire [31:0] MEM_PC,
    input wire JAL_MEM, MemtoReg_MEM,

    output reg [31:0] WB_inst,
    output reg [31:0] readData_out,
    output reg RegWrite_WB,
	 output reg JAL_WB, MemtoReg_WB,
    output reg [4:0] WriteReg_WB,
    output reg [31:0] aluResult_WB,
	 output reg [31:0] WB_PC
    
 );

always @(posedge clk or posedge Reset) begin
    if (Reset) begin
	 
        WB_inst <= 32'b0;
        readData_out <= 32'b0;
        RegWrite_WB <= 1'b0;
        WriteReg_WB <= 5'b0;
        aluResult_WB <= 32'b0;
		  JAL_WB <= 1'b0;
		  WB_PC <= 32'b0;
		  MemtoReg_WB <= 1'b0;
		  
    end else begin
	 
        WB_inst <= MEM_inst;
        readData_out <= readData;
        RegWrite_WB <= RegWrite_MEM;
        WriteReg_WB <= WriteReg_out;
		  JAL_WB <= JAL_MEM;
		  WB_PC <= MEM_PC;
		  aluResult_WB <= aluResult_out;
		  MemtoReg_WB <= MemtoReg_MEM;

    end
end

endmodule 