module sign_extend_unit (

    input wire [15:0] imm,
    output wire [31:0] imm_ext
);

 assign imm_ext = { {16{imm[15]}}, imm}; 
 
endmodule