// 2016.06.26
// File         : Wake_Unit.v
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
module Wake_Unit(
input clk,rst,flush,
input Stall,
//Inst1
input [5:0]Inst1_Src1,Inst1_Src2,
input [5:0]Inst1_Phydst,

output Inst1_Src1_Wake,Inst1_Src2_Wake,
//Inst2
input [5:0]Inst2_Src1,Inst2_Src2,
input [5:0]Inst2_Phydst,

output Inst2_Src1_Wake,Inst2_Src2_Wake,


//ALU0_wake
input [5:0]ALU0_Phydst,
input ALU0_wake,
//ALU1_wake
input [5:0]ALU1_Phydst,
input ALU1_wake,

//BU_wake
input [5:0]BU_Phydst,
input BU_wake,
//BU_wake
input [5:0]DU_Phydst,
input DU_wake

);

wire Inst1_Src1_WB;
wire Inst1_Src2_WB;
wire Inst2_Src1_WB;
wire Inst2_Src2_WB;


wire Inst2_Src1_Match;
wire Inst2_Src2_Match;


reg [63:0]Phy_Wake;

assign Inst1_Src1_WB=(Inst1_Src1===ALU0_Phydst)|(Inst1_Src1===ALU1_Phydst)|(Inst1_Src1===BU_Phydst)|(Inst1_Src1===DU_Phydst);
assign Inst1_Src2_WB=(Inst1_Src2===ALU0_Phydst)|(Inst1_Src2===ALU1_Phydst)|(Inst1_Src2===BU_Phydst)|(Inst1_Src2===DU_Phydst);

assign Inst1_Src1_Wake=Phy_Wake[Inst1_Src1]|Inst1_Src1_WB;
assign Inst1_Src2_Wake=Phy_Wake[Inst1_Src2]|Inst1_Src2_WB;
assign Inst2_Src1_Match =(Inst2_Src1===Inst1_Phydst);
assign Inst2_Src2_Match =(Inst2_Src2===Inst1_Phydst);
assign Inst2_Src1_WB=(Inst2_Src1===ALU0_Phydst)|(Inst2_Src1===ALU1_Phydst)|(Inst2_Src1===BU_Phydst)|(Inst2_Src1===DU_Phydst);
assign Inst2_Src2_WB=(Inst2_Src2===ALU0_Phydst)|(Inst2_Src2===ALU1_Phydst)|(Inst2_Src2===BU_Phydst)|(Inst2_Src2===DU_Phydst);

assign Inst2_Src1_Wake=(Phy_Wake[Inst2_Src1]|Inst2_Src1_WB)&(!Inst2_Src1_Match);
assign Inst2_Src2_Wake=(Phy_Wake[Inst2_Src2]|Inst2_Src2_WB)&(!Inst2_Src2_Match);

always@(posedge clk)begin
	if(rst|flush)begin
		Phy_Wake<=64'hffffffffffffffff;
		end
	else if(!Stall)begin
		if((Inst1_Phydst!=6'd0))Phy_Wake[Inst1_Phydst]<=1'b0;
		if((Inst2_Phydst!=6'd0))Phy_Wake[Inst2_Phydst]<=1'b0;

		end
		
	if(ALU0_wake)
			Phy_Wake[ALU0_Phydst]<=1'b1;
	if(ALU1_wake)
			Phy_Wake[ALU1_Phydst]<=1'b1;
	if(BU_wake)
			Phy_Wake[BU_Phydst]<=1'b1;
	if(DU_wake)
			Phy_Wake[DU_Phydst]<=1'b1;
	end
endmodule
