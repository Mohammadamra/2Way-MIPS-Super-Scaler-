

module MUX3x1 #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire [1:0] select,
    output [WIDTH-1:0] out
);
/*
always @(*) begin
    case (select)
        2'b00: out = in0;    // Select input 0
        2'b01: out = in1;    // Select input 1
        2'b10: out = in2;    // Select input 2
        default: out = 32'b0;  // Default case
    endcase
end*/

//assign out = (in0 & {WIDTH{~select[1] & ~select[0]}}) | 
 //            (in1 & {WIDTH{~select[1] & select[0]}}) | 
//             (in2 & {WIDTH{select[1] & ~select[0]}}); 
endmodule
