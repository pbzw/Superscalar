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
module EX_BU(
 input clk,rst,flush,
 input [5:0]EX_Operation,
 input [31:0]EX_imm,EX_Src1,EX_Src2,EX_PC,
 input [5:0]EX_Phydst,
 input [3:0]EX_Commit_Window,
 input EX_en,
 
 output reg [3:0]WB_Commit_Window,
 output reg [5:0]WB_Phydst,
 output reg [31:0]WB_Reserve_PC,WB_Branch_PC,
 output reg WB_valid,WB_Branch,WB_Reserve
);

reg [31:0]imm,Src1,Src2,PC;
reg [31:0]PC_plus4,PC_plus8;
reg [5:0]Phydst,Operation;
reg en;
reg [3:0]Commit_Window;

always@(posedge clk)begin
	if(rst|flush)begin
		imm              <=32'd0;
		PC               <=32'd0;
		PC_plus4         <=32'd0;
		PC_plus8         <=32'd0;
		Src1             <=32'd0;
		Src2             <=32'd0;
		Commit_Window    <= 4'd0;
		Operation        <= 5'd0;
		Phydst           <= 5'd0;
		en               <= 1'b0;
		end
	else begin
		imm              <=EX_imm;
 		PC               <=EX_PC;
		PC_plus4         <=EX_PC+32'd4;
		PC_plus8         <=EX_PC+32'd8;
		Src1             <=EX_Src1;
		Src2             <=EX_Src2;
		Commit_Window    <=EX_Commit_Window;
		Operation        <=EX_Operation;
		Phydst           <=EX_Phydst ;
		en               <=EX_en;
		end
end

wire [31:0]BU_Reserve_PC,BU_Branch_PC;
wire BU_Branch,BU_Reserve;

BU BU(
	.Src1(Src1),
	.Src2(Src2),
	.ime(imm),
	.PC(PC),
	.PC_plus_4(PC_plus4),
	.PC_plus_8(PC_plus8),
	.Operation(Operation),

	.Reserve_PC(BU_Reserve_PC),
	.Branch_PC(BU_Branch_PC),
	.Branch(BU_Branch),
	.Reserve(BU_Reserve)
);

always@(posedge clk)begin
	if(rst|flush)begin
		WB_Reserve_PC           <=32'd0;
		WB_Branch_PC            <=32'd0;
		WB_Commit_Window        <= 4'd0;
		WB_valid                <= 1'd0;
		WB_Phydst              <= 6'd0;
		WB_Branch               <= 1'd0;
		WB_Reserve              <= 1'd0;
		end
	else begin
		WB_Reserve_PC           <=BU_Reserve_PC;
		WB_Branch_PC            <=BU_Branch_PC;
		WB_Commit_Window        <=Commit_Window;
		WB_valid                <=en;
		WB_Phydst               <=Phydst;
		WB_Branch               <=BU_Branch;
		WB_Reserve              <=BU_Reserve;
		end
end

endmodule