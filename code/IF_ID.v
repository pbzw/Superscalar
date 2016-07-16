// 2016.06.15
// File         : IF_ID.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//

module IF_ID(
input clk,rst,
input inst_en,
input stall,
input flush,
input [31:0]IF_inst1_in,
input [31:0]IF_inst2_in,

input [31:0]IF_PC_in,
output reg ID_inst_en,
output reg[31:0]ID_PC,
output reg[31:0]ID_inst1,
output reg[31:0]ID_inst2
);

always@(posedge clk)begin
	if(rst|flush)begin
		ID_PC      <=32'd0;
		ID_inst1   <=32'd0;
		ID_inst2   <=32'd0;
		ID_inst_en <=1'b0;
		end
	else if(!stall)begin
		ID_PC      <=IF_PC_in;
		ID_inst1   <=IF_inst1_in;
		ID_inst2   <=IF_inst2_in;
		ID_inst_en <=inst_en;
		end
	end

endmodule
