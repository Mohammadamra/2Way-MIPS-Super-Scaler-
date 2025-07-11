module Registers_File (

    input  clk,
    input Reset,
    input RegWrite1, // Write enable for port 1
    input RegWrite2, // Write enable for port 2
    output reg[31:0] readData1_1, // Read data for instruction 1, read 1
    output reg[31:0] readData1_2, // Read data for instruction 1, read 2
    output reg[31:0] readData2_1, // Read data for instruction 2, read 1
    output reg[31:0] readData2_2, // Read data for instruction 2, read 2
    input  [4:0] WriteReg_WB1,  // Write register for port 1
    input  [4:0] WriteReg_WB2,  // Write register for port 2
    input  [31:0]  WriteData1,  // Write data for port 1
    input  [31:0]  WriteData2,  // Write data for port 2
    input  [4:0]  rs1,       // Read register 1 for instruction 1
    input  [4:0]  rt1,       // Read register 2 for instruction 1
    input  [4:0]  rs2,       // Read register 1 for instruction 2
    input  [4:0]  rt2,        // Read register 2 for instruction 2
	 input Way_0_oldest_WB
);

    reg [31:0] registers [0:31];

    // Read Ports (Combinational)
    always @(*) begin
        readData1_1 <= registers[rs1];
        readData1_2 <= registers[rs2];
        readData2_1 <= registers[rt1];
        readData2_2 <= registers[rt2];
		
    end

    // Write Ports (Sequential)
    always@(negedge clk,  posedge Reset) begin : writing_on_registers

        integer i;

        if(Reset) begin
            for(i=0; i<32; i = i + 1) 
            registers[i] <= 0;
        end
        else if ( RegWrite1 && RegWrite2 && WriteReg_WB1 != 4'b0 && WriteReg_WB1 == WriteReg_WB2)
					if (Way_0_oldest_WB)
						registers[WriteReg_WB2] <= WriteData2;
					else
						registers[WriteReg_WB1] <= WriteData1;					
		 
		  else begin
            // Port 1 Write
            if ( RegWrite1 && (WriteReg_WB1 != 5'b00000)) begin
                registers[WriteReg_WB1] <= WriteData1;
            end

            // Port 2 Write
            if ( RegWrite2 && (WriteReg_WB2 != 5'b00000)) begin
                registers[WriteReg_WB2] <= WriteData2;
            end
        end
    end

endmodule