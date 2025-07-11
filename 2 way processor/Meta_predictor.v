module Meta_predictor(
input clk,
input Reset,
input [31:0] PC,
input [31:0] nextPC,
input branchTaken,
input [31:0] branch_target, branch_target_EX,
input Branch, Branch_EX,
input Gshare_prediction, 
input Local_prediction,
input choose_G_IN,
input [4:0] index_in,
output choose_G, // 1: use Gshare, 0: use Local
output [31:0] Gshare_predicted_address, Local_predicted_address,
output [4:0] index,
input [3:0] LHR_index_in, LHPT_index_in, 
input [3:0] Local_BTB_index_in,
input [4:0] GHPT_index_in, GHR_in,
input [4:0] G_BTB_index_in,
output [3:0]	LHR_index, LHPT_index,
output [3:0]	Local_BTB_index,
output [4:0] GHPT_index,
output [4:0] G_BTB_index,
output [4:0] GHR
);


parameter table_size = 32; // size of the choice table, = 2 ^ (GHR or LHR) depending on which is bigger.
reg [1:0] choice_table [table_size-1:0]; // contains states (00, 01, 10, 11) which indicate whether to choose the Gshare or the Local prediction. 

//wire [6:0] GHR;
wire Gshare_hit, Local_hit, Local_correct, Gshare_correct;
// wire [31:0] Gshare_predicted_address, Local_predicted_address;

assign index = PC[4:0] ^ GHR; // the index for the table is the same as the Gshare index because it is bigger than the local.
always @(posedge clk, posedge Reset) begin: block
	integer i;
	if(Reset) begin
		for(i = 0; i < table_size; i = i + 1)
			choice_table[i] <= 2'b01;
	end
	
	else begin
		if(Gshare_correct && !Local_correct) begin
			if(choice_table[index_in] != 2'b11) begin // if the counter is full, do not incerement
				choice_table[index_in] <= choice_table[index_in] + 2'b1; // works as a saturating counter, increment until it reaches the max value and keep it as it is.
			end													// in this case since 11 and 10 prefer Gshare, and 01 and 00 prefer Local, we increment or decrement accordingly
		end
		
		else if(Local_correct && !Gshare_correct) begin
			if(choice_table[index_in] != 2'b0) begin
				choice_table[index_in] <= choice_table[index_in] - 2'b1;
			end
		end // when both predictors are either correct or incorrect, there will be no update since no predictor has worked better than the other.
	end
end


assign choose_G = choice_table[index][1]; // 11 and 10 for Gshare
//assign Meta_prediction = choose_G ? Gshare_prediction : Local_prediction;

assign Gshare_correct = (choose_G_IN && branchTaken) ? 1'b1 : 1'b0;
assign Local_correct = (!choose_G_IN && branchTaken) ? 1'b1 : 1'b0;


Gshare G (.clk(clk), .Reset(Reset), .PC(PC), .nextPC(nextPC), .branch_target(branch_target), .Branch(Branch), .branchTaken(branchTaken), 
 .predicted_address(Gshare_predicted_address), .GHR(GHR), .Branch_EX(Branch_EX), .GHPT_index(GHPT_index), .BTB_index(G_BTB_index),
 .hit(Gshare_hit), .prediction(Gshare_prediction),
 .GHPT_index_in(GHPT_index_in), .GHR_in(GHR_in), .branch_target_EX(branch_target_EX), .BTB_index_in(G_BTB_index_in)
);
 // 

Local L (.clk(clk), .Reset(Reset), .PC(PC), .nextPC(nextPC), .branch_target(branch_target), .Branch(Branch), .branchTaken(branchTaken), 
 .predicted_address(Local_predicted_address), .LHR_index(LHR_index), .LHPT_index(LHPT_index), .BTB_index(Local_BTB_index), .Branch_EX(Branch_EX), .LHR_index_in(LHR_index_in),
.LHPT_index_in(LHPT_index_in), .branch_target_EX(branch_target_EX), .BTB_index_in(Local_BTB_index_in), .hit(Local_hit), .prediction(Local_prediction)
);
 // 

endmodule

