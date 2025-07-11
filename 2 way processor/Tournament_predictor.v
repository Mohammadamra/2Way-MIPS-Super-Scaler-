module Tournament_predictor(
input clk,
input Reset,
input [31:0] PC,
input [31:0] nextPC,
input [31:0] branch_target, branch_target_EX,
input Branch, Branch_EX,
input branchTaken,
output reg prediction,
output reg [31:0]predicted_address,
input [4:0] GHPT_index_in, GHR_in,
input [4:0] G_BTB_index_in,
output [4:0] GHPT_index,
output [4:0] G_BTB_index,
output [4:0] GHR
);



reg [3:0] warm_up; // warm-up counter that counts to 10 to switch from dynamic prediction to (Gshare and Local)
reg warmed_up;  // equals 0 if warm-up > 9


wire Gshare_prediction, Dynamic_prediction;
wire [31:0] Gshare_predicted_address, Dynamic_predicted_address;
//wire [6:0] GHR;


always@(posedge clk, posedge Reset) begin 
	if(Reset) begin
		warm_up <= 0;
		warmed_up <= 0;
	end
	
	else begin
		if(Branch && !warmed_up) begin // if the counter is less than the threshold and it is a Branch
			if(warm_up == 4'd0) begin
				warmed_up <= 1; // after reaching the threshold, the predictor is warmed up
			end
			
			else begin
				warm_up = warm_up + 1'b1;
			end
		end
	end
end


always@(*) begin
	if(!warmed_up)begin
		prediction = Dynamic_prediction;
		predicted_address = Dynamic_predicted_address;
	end
	
	else begin
		if(Branch) begin
			prediction = Gshare_prediction;
			predicted_address = Gshare_predicted_address;
		end
		else begin
			prediction = 1'b0;
			predicted_address = nextPC;
		end
	end
end







Dynamic_predictor D (.clk(clk), .Reset(Reset), .PC(PC), .nextPC(nextPC), .branch_target(branch_target), .Branch(Branch), .branchTaken(branchTaken), 
.prediction(Dynamic_prediction), .predicted_address(Dynamic_predicted_address)
);



Gshare G (.clk(clk), .Reset(Reset), .PC(PC), .nextPC(nextPC), .branch_target(branch_target), .Branch(Branch), .branchTaken(branchTaken), 
 .predicted_address(Gshare_predicted_address), .GHR(GHR), .Branch_EX(Branch_EX), .GHPT_index(GHPT_index), .BTB_index(G_BTB_index),
  .prediction(Gshare_prediction),.GHPT_index_in(GHPT_index_in), .GHR_in(GHR_in),
  .branch_target_EX(branch_target_EX), .BTB_index_in(G_BTB_index_in)
);



endmodule





