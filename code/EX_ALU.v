// 2016.06.21
// File         : EX_ALU.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//

module EX_ALU(
 input clk,rst,flush,
 

 input [5:0]EX_Operation,
 input [31:0]EX_imm,EX_Src1,EX_Src2,
 input [5:0]EX_Phydst,
 input [3:0]EX_Commit_Window,
 input EX_en,
 

 output reg [3:0]WB_Commit_Window,
 output reg [5:0]WB_Phydst,
 output reg [31:0]WB_Result,
 output reg WB_valid
);

reg [31:0]imm,Src1,Src2;
reg [5:0]Phydst,Operation;
reg en;
reg [3:0]Commit_Window;
reg [4:0]Rdst;
wire [31:0]ALU_Result;

always@(posedge clk)begin
	if(rst|flush)begin
		imm              <=32'd0;
		Src1             <=32'd0;
		Src2             <=32'd0;
		Commit_Window    <= 4'd0;
		Operation        <= 5'd0;
		Phydst           <= 6'd0;
		en               <= 1'b0;
		end
	else begin
		imm              <=EX_imm;
		Src1             <=EX_Src1;
		Src2             <=EX_Src2;
		Commit_Window    <=EX_Commit_Window;
		Operation        <=EX_Operation;
		Phydst           <=EX_Phydst ;
		en               <=EX_en;
		end
end

ALU ALU(
	.Src1(Src1),
	.Src2(Src2),
	.ime(imm),
	.Operation(Operation),
	.Result(ALU_Result)
);
 
always@(/*posedge clk*/*)begin
	/*if(rst|flush)begin
		WB_Commit_Window      <= 4'd0;
		WB_Result             <=32'd0;
		WB_Phydst             <= 6'd0;
		WB_valid              <= 1'd0;
		end
	else begin*/
		WB_Commit_Window      <=Commit_Window;
		WB_Result             <=ALU_Result;
		WB_Phydst             <=Phydst;
		WB_valid              <=en;
		//end
end

endmodule