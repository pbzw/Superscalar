// 2016.06.15
// File         : Register.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//
`include "define.v"

module Register #(parameter WIDTH = 32,reset=16'h3000)(
input clk,
input rst,
input en,
input[WIDTH-1:0] data_in,
output reg[WIDTH-1:0] data_out
);



always@(`clk_trigger_edge clk)
begin
	if(rst)
	data_out<=reset;
	else if(en)
	data_out<=data_in;
end

endmodule