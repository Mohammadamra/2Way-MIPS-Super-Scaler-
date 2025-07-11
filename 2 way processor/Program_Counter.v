module Program_Counter (
    input wire clk,
    input wire Reset,
    input wire [31:0] PC_in,
    output reg [31:0] PC_out
);



always @(posedge clk or posedge Reset) begin
    if (Reset == 1) begin
        PC_out <= 32'hffffffff; 
    end else// if ( PCWrite ) begin
        PC_out <= PC_in;
    //end

end
endmodule


