// 2016.06.21
// File         : Add.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//

module Add(
	input [31:0]A,
	input [31:0]B,
	output [31:0]C
);

assign C = (A + B);

endmodule

