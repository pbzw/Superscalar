// 2016.06.21
// File         : DU.v
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

module DU(
input [31:0] Src1,Src2,
input [31:0]ime,//this PC plused 4
input[5:0]  Operation,
output reg [31:0] Address,
output reg RW,Signed_Extend,
output reg [3:0]Sel
);

always@(*)begin
	case (Operation)
		`DUOp_Lb  :begin Address<=Src1+ime; RW<=1'b0; Sel<=4'b0001;Signed_Extend<=1'b1;end 
		`DUOp_Lbu :begin Address<=Src1+ime; RW<=1'b0; Sel<=4'b0001;Signed_Extend<=1'b0;end    
		`DUOp_Lh  :begin Address<=Src1+ime; RW<=1'b0; Sel<=4'b0011;Signed_Extend<=1'b1;end 
		`DUOp_Lhu :begin Address<=Src1+ime; RW<=1'b0; Sel<=4'b0011;Signed_Extend<=1'b0;end 
		`DUOp_Lw  :begin Address<=Src1+ime; RW<=1'b0; Sel<=4'b1111;Signed_Extend<=1'b0;end 
		`DUOp_Sb  :begin Address<=Src1+ime; RW<=1'b1; Sel<=4'b0001;Signed_Extend<=1'b0;end 
		`DUOp_Sh  :begin Address<=Src1+ime; RW<=1'b1; Sel<=4'b0011;Signed_Extend<=1'b0;end 
		`DUOp_Sw  :begin Address<=Src1+ime; RW<=1'b1; Sel<=4'b1111;Signed_Extend<=1'b0;end 
	default      :begin Address<=32'h0 ; RW<=1'b0; Sel<=4'b0000;Signed_Extend<=1'b0;end 
	endcase
	
	end


endmodule
