module IF_ID_Pipe (
    input wire clk,
    input wire Reset,
    input wire Flush, 
    input wire IF_ID_write,
    input wire [31:0] nextPC, imm_ext_IF,
    input wire [31:0] IF_inst, branch_target, updated_pc_IF, W0_PC,
	 input wire  prediction, oldest,

	 input [4:0] GHPT_index_IF, GHR_IF,
	 input [4:0] G_BTB_index_IF,
    output reg [31:0] ID_inst,  
    output reg [31:0] ID_PC,
	 output reg ID_prediction, oldest_ID,
	 output reg [31:0] branch_target_ID, updated_pc_ID, imm_ext_ID, W0_PC_ID,
	 output reg [4:0] GHPT_index_ID, GHR_ID,
	 output reg [4:0] G_BTB_index_ID	 
);

    always @(posedge clk or posedge Reset) begin
        if (Reset) begin
            ID_inst <= 32'b0;
            ID_PC <= 32'b0;
				ID_prediction <= 1'b0;
				branch_target_ID <= 31'b0;
				GHPT_index_ID <= 1'b0;
				GHR_ID <= 1'b0;
				G_BTB_index_ID <= 1'b0;
				updated_pc_ID <= 32'b0;
				imm_ext_ID <= 32'b0;
				oldest_ID <= 1'b0;
				W0_PC_ID  <= 32'b0;
				
        end else if (Flush) begin 
            ID_inst <= 32'b0;
            ID_PC <= 32'b0;
				ID_prediction <= 1'b0;
				branch_target_ID <= 1'b0;
				GHPT_index_ID <= 1'b0;
				GHR_ID <= 1'b0;
				G_BTB_index_ID <= 1'b0;
				updated_pc_ID <= 32'b0;
				imm_ext_ID <= 32'b0;
				oldest_ID <= 1'b0;
				W0_PC_ID  <= 32'b0;
				
        end else if (IF_ID_write) begin // && !Flush 
            ID_inst <= IF_inst;
            ID_PC <= nextPC;
				ID_prediction <= prediction;
				branch_target_ID <= branch_target;
				GHPT_index_ID <= GHPT_index_IF;
				GHR_ID <= GHR_IF;
				G_BTB_index_ID <= G_BTB_index_IF;
				updated_pc_ID <= updated_pc_IF;
				imm_ext_ID <= imm_ext_IF;
				oldest_ID <= oldest;
				W0_PC_ID  <= W0_PC;
        end
    end
endmodule 