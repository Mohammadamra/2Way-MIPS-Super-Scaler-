module MUX2x1 #(parameter size = 32) (
  
    input wire sel,
    input wire [size - 1 : 0] inL_1, inL_0,
    output wire [size - 1 : 0] out
    );

//assign out =(sel ? inL_1 : inL_0);
	
//	assign out = inL_0 ^ (sel * (inL_1 ^ inL_0));
assign out = (inL_1 & {size{sel}}) | (inL_0 & {size{~sel}});
endmodule
