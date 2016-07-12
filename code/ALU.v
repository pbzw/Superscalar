// 2016.06.15
// File         : ALU.v
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

module ALU(
input[31:0] Src1,Src2,ime,
input[5:0]  Operation,
output reg signed [31:0] Result
);


always@(*)begin
	case (Operation)
		`AluOp_Ori  : Result <= Src1|ime;
		`AluOp_Or   : Result <= Src1|Src2;
		`AluOp_Nor  : Result <= ~(Src1|Src2);
		`AluOp_Andi : Result <= Src1&ime;
		`AluOp_And  : Result <= Src1&Src2;
		`AluOp_Addi : Result <= Src1+ime;
		`AluOp_Xori : Result <= Src1^ime;
		`AluOp_Xor  : Result <= Src1^Src2;
		`AluOp_Add  : Result <= Src1+Src2;
		`AluOp_Sub  : Result <= Src1-Src2;
		`AluOp_Lui  : Result <= {ime[15:0],16'b0};
		`AluOp_Sll  : Result <= Src1<<ime[10:6];
		`AluOp_Srl  : Result <= Src1>>ime[10:6];
		default     : Result <= 32'd0;
	endcase
	
	end


endmodule
