// 2016.06.15
// File         : BU.v
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

module BU(
input signed[31:0] Src1,Src2,
input [31:0]ime,PC,PC_plus_4,PC_plus_8,//this PC plused 4
input[5:0]  Operation,
output reg  [31:0] Reserve_PC,Branch_PC,
output reg Branch,Reserve
);

always@(*)begin
	case (Operation)
		`BUOp_J         :begin
			Branch      <=1'b1;
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4[31:28],ime[25:0],2'b0};
			end
		`BUOp_Jal       :begin
			Branch      <=1'b1; 
			Reserve     <=1'b1;
			Reserve_PC  <=PC_plus_8;
			Branch_PC   <={PC_plus_4[31:28],ime[25:0],2'b0};
			end
		`BUOp_Beq       :begin
			Branch      <=(Src1==Src2);
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Bgtz      :begin
			Branch      <=(Src1>32'd0);
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Blez      :begin
			Branch      <=(Src1<=32'd0);
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Bne       :begin
			Branch      <=(Src1!=Src2);
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Bltz      :begin
			Branch      <=(Src1<32'd0);
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Bltzal    :begin
			Branch      <=(Src1<32'd0);
			Reserve     <=1'b1;
			Reserve_PC  <=(Src1<32'd0)?PC_plus_8:Src2;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Bgez      :begin
			Branch      <=(Src1>=32'd0);
			Reserve     <=1'b0;
			Reserve_PC  <=32'd0;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Bgezal    :begin
			Branch      <=(Src1>=32'd0);
			Reserve     <=1'b1;
			Reserve_PC  <=(Src1>=32'd0)?PC_plus_8:Src2;
			Branch_PC   <={PC_plus_4+{ime[29:0],2'b0}};
			end
		`BUOp_Jr        :begin
			Branch      <=1'b1;
			Reserve     <=1'b0;
			Reserve_PC  <=PC_plus_8;
			Branch_PC   <=Src1;
			end
		`BUOp_Jalr      :begin
			Branch      <=1'b1;
			Reserve     <=1'b1;
			Reserve_PC  <=PC_plus_8;
			Branch_PC   <=Src1;
			end
		default         :begin
			Branch      <=1'b0;
			Reserve     <=1'b0;
			Reserve_PC  <=32'hxxxxxxxx;
			Branch_PC   <=32'hxxxxxxxx;
			end
	endcase
	
	end


endmodule
