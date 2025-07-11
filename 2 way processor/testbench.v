`timescale 1ns/1ps
module testbench;

    reg clk, Reset;
    wire [31:0] instruction_0, instruction_1 ;
	 wire falseNotTaken, falseTaken, hazard_detected, Flush;
	 wire Branch_EX;
	 reg [63:0] branch_counter, false_counter, clkCounter, Flush_counter, Stall_counter, Inst_counter;
	 
	 /*always@(posedge clk) begin
	 clkCounter = clkCounter +1;
		if(Branch_EX) begin //(instruction[31:26] == 3'h4) || (instruction[31:26] == 3'h5)) begin
			branch_counter = branch_counter + 1;
		end
		
		if((falseTaken || falseNotTaken) && Branch_EX) begin//((instruction[31:26] == 3'h4) || (instruction[31:26] == 3'h5))) begin
			false_counter = false_counter + 1;
		end
		if (Flush)
		Flush_counter = Flush_counter + 1;
		if (hazard_detected)
		Stall_counter = Stall_counter + 1;
		if(instruction != 32'h0)
			Inst_counter = Inst_counter + 1;
	 end
		*/
    initial begin
        clk = 1;
        Reset = 1;
		  /*false_counter = 1'b0;
		  branch_counter = 1'b0;
		  clkCounter = 0;
		  Stall_counter =0;
		  Flush_counter =0;
		 Inst_counter =0 ;*/
		          
					 
        #7 Reset = 0;
		
  #10000 $stop;
    end

    always #8 clk = ~clk; 

    TwoWaysTopModule uut (
        .clk(clk),
        .Reset(Reset),
        .instruction_0(instruction_0), .instruction_1 (instruction_1)
		 /* .Branch_EX(Branch_EX),
		  .falseNotTaken(falseNotTaken),
		  .falseTaken(falseTaken), .Flush(Flush), .hazard_detected(hazard_detected)*/
    );


endmodule