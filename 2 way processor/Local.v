module Local(
	input clk,
	input Reset,
	input [31:0] PC,
	input [31:0] nextPC,
	input [31:0] branch_target, branch_target_EX,
	input Branch,
	input branchTaken,
	output reg prediction,
	output hit,
	output reg [31:0] predicted_address,
	output  [3:0]LHR_index, LHPT_index,
output [3:0]	BTB_index,
input Branch_EX,
	input [3:0]LHR_index_in, LHPT_index_in,
	input [3:0]	BTB_index_in
);

parameter PC_LSB = 4; 
parameter LHR_size = 16;
parameter LHPT_size = 16;
parameter BTB_size = 16;
parameter [1:0]
	strongly_not_taken = 2'b00, 
	weakly_not_taken = 2'b01,
	weakly_taken = 2'b10,
	strongly_taken = 2'b11;
	
reg [PC_LSB-1:0] LHR [LHR_size-1:0]; // local history register
reg [1:0] LHPT [LHPT_size-1:0]; // local history pattern table
reg [60:0] BTB [BTB_size-1:0]; // branch target buffer // 1 valid bit + 28 tag bits + 32 target bits 

//wire [PC_LSB-1:0] LHR_index;
//wire [PC_LSB-1:0] LHPT_index;
//wire [3:0] BTB_index; // 4 bits wide; 2 ^ 4 = 16, i.e. BTB_size 

wire [27:0] tag; // 32 - 4 = 28
wire [27:0] stored_tag;

wire valid;

//reg temp_prediction;

assign LHR_index = PC[PC_LSB-1:0];			// indexing goes as follows: PC==>LHR==>LHPT 
assign LHPT_index = LHR[LHR_index];
assign BTB_index = PC[3:0];

assign tag = PC[31:4];
assign stored_tag = BTB[BTB_index][59:32]; // generally the tag = pc - index, to avoid collision, but for a small table the tag size can be choosen. 
											// the tag size is choosen to be 20 bits
assign valid = BTB[BTB_index][60];
assign hit = (valid && (tag == stored_tag));

always@(negedge clk, posedge Reset)begin: main_logic
	integer i;
	
	if(Reset) begin
		for(i = 0; i < LHPT_size; i = i + 1)begin
			LHPT[i] <= weakly_not_taken;
		end
		
		for(i = 0; i < BTB_size; i = i + 1) begin
			BTB[i] <= 0;
		end
		
		prediction <= 0;
		predicted_address <= 0;
		//temp_prediction <= 0;
	end
	
	else begin 
		if (Branch_EX) begin					// This block updates the entries
			case (LHPT[LHPT_index_in])
				strongly_not_taken: begin
					//temp_prediction <= 0;
					
					if (branchTaken) begin
						LHPT[LHPT_index_in] <= weakly_not_taken;
					end
					
					else begin
						LHPT[LHPT_index_in] <= strongly_not_taken;
					end
				end
				
				weakly_not_taken: begin
					//temp_prediction <= 0;
					
					if (branchTaken) begin
						LHPT[LHPT_index_in] <= weakly_taken;
					end
					
					else begin
						LHPT[LHPT_index_in] <= strongly_not_taken;
					end
				end
				
				weakly_taken: begin
					//temp_prediction <= 1;
					
					if (branchTaken) begin
						LHPT[LHPT_index_in] <= strongly_taken;
					end
					
					else begin
						LHPT[LHPT_index_in] <= weakly_not_taken;
					end
				end
				
				strongly_taken: begin
					//temp_prediction <= 1;
					
					if (branchTaken) begin
						LHPT[LHPT_index_in] <= strongly_taken;
					end
					
					else begin
						LHPT[LHPT_index_in] <= weakly_taken;
					end
				end
				
				default: begin
					//temp_prediction <= 0;
					LHPT[LHPT_index_in] <= strongly_not_taken;
				end
			endcase
			
			if (branchTaken) begin
				BTB[BTB_index_in] <= {1'b1, tag, branch_target_EX};
			end 
			
			else begin
				BTB[BTB_index_in] <= {1'b1, tag, nextPC};
			end
		end
		
//-----------------------------------------------------------		
		if (Branch) begin						// This block makes the prediction
				prediction = (LHPT[LHPT_index][1] == 1);
			 
				if(prediction) begin
					if( hit)
						predicted_address <= BTB[BTB_index][31:0];
					else 
						predicted_address <= branch_target;
				end
				else
					predicted_address <= nextPC;
		end	
	end	
end // end of the always block
	



always @(posedge clk, posedge Reset) begin: second_block
integer i;
integer j;
	if (Reset) begin
		for (i = 0; i < LHR_size; i = i + 1)begin
			LHR[i] <= 0;	
		end
		
	end
	
	else begin
	
		if (Branch_EX) begin
			if (branchTaken) begin
				LHR[LHR_index_in] <= {LHR[LHR_index_in][PC_LSB-2:0], 1'b1};
			end
		
			else begin
				LHR[LHR_index_in] <= LHR[LHR_index_in] << 1;
			end
		end	
	end
end
endmodule


