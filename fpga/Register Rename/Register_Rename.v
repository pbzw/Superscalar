module Register_Rename(
input clk,
input rst,
input Branch_flush,

//Commit Unit

input Commit,
input [5:0]Commit_Phy,
input [4:0]Commit_Rdst,

//flush phy wake
output [63:0] flush_wake_Phy,

//
input [31:0]Inst1_PC,Inst1_Imm,
input Inst1_Valid,Inst1_RegW,
input [4:0] Inst1_Src1,Inst1_Src2,Inst1_Rdst,
input [8:0] Inst1_ALUop,
	
output reg[5:0]Inst1_RSrc1,Inst1_Rrc2,
output reg[5:0]Inst1_RPhydst,
//
input [31:0]Inst2_PC,Inst2_Imm,
input Inst2_Valid,Inst2_RegW,
input [4:0] Inst2_Src1,Inst2_Src2,Inst2_Rdst,
input [8:0] Inst2_ALUop,
	
output reg[5:0]Inst2_RSrc1,Inst2_Rrc2,
output reg[5:0]Inst2_RPhydst,
//
input [31:0]Inst3_PC,Inst3_Imm,
input Inst3_Valid,Inst3_RegW,
input [4:0] Inst3_Src1,Inst3_Src2,Inst3_Rdst,
input [8:0] Inst3_ALUop,
	
output reg[5:0]Inst3_RSrc1,Inst3_Rrc2,
output reg[5:0]Inst3_RPhydst,
//
input [31:0]Inst4_PC,Inst4_Imm,
input Inst4_Valid,Inst4_RegW,
input [4:0] Inst4_Src1,Inst4_Src2,Inst4_Rdst,
input [8:0] Inst4_ALUop,
	
output reg[5:0]Inst4_RSrc1,Inst4_Rrc2,
output reg[5:0]Inst4_RPhydst,

output RU_Stall
 
);
integer i;

wire [63:0]can_use=Phy_Using_Committed&(~Commit_Mapping_used);//SET avaliable Phy Commit Temp table used is not avaliable
assign Phy_can_Used=~((~Phy_Using_Used)|can_use);
assign flush_wake_Phy=Phy_Using_Used&(~Phy_Using_Committed);

/*Temp_Mappling_Log*/
reg [5:0]Temp_Mappling_Phy[0:31];

/*Phy_Using_Log*/
reg [0:63]Phy_Using_Used;
reg [0:63]Phy_Using_Committed;

/*Commit_Mapping_Log*/
reg [5:0]Commit_Mapping[0:31];
reg [0:63]Commit_Mapping_used;

wire [5:0]Can_Use_Phy;

assign RU_Stall= Can_Use_Phy<6'd4;

Acc Acc(
.in(Phy_can_Used),
.out(Can_Use_Phy)
);


//Update Commit Map 
always@(posedge clk)begin
	if(rst)
		for(i=0;i<32;i=i+1)
			Commit_Mapping[i]<=5'b0;
	else if(Commit&(Commit_Rdst!=5'd0))
		Commit_Mapping[Commit_Rdst]<=Commit_Phy;
end





endmodule


module Acc(
input [0:63]in,
output[5:0] out
);

wire[15:0]comb1= in[0:15];
wire[15:0]comb2= in[16:31];
wire[15:0]comb3= in[32:47];
wire[15:0]comb4= in[48:63];

wire[3:0] temp1,temp2,temp3,temp4;
assign temp1 = (((comb1[0]+comb1[1])+(comb1[2]+comb1[3]))+((comb1[4]+comb1[5])+(comb1[6]+comb1[7])))+(((comb1[8]+comb1[9])+(comb1[10]+comb1[11]))+((comb1[12]+comb1[13])+(in[14]+in[15])));
assign temp2 = (((comb2[0]+comb2[1])+(comb2[2]+comb2[3]))+((comb2[4]+comb2[5])+(comb2[6]+comb2[7])))+(((comb2[8]+comb2[9])+(comb2[10]+comb2[11]))+((comb2[12]+comb2[13])+(in[14]+in[15])));
assign temp3 = (((comb3[0]+comb3[1])+(comb3[2]+comb3[3]))+((comb3[4]+comb3[5])+(comb3[6]+comb3[7])))+(((comb3[8]+comb3[9])+(comb3[10]+comb3[11]))+((comb3[12]+comb3[13])+(in[14]+in[15])));
assign temp4 = (((comb4[0]+comb4[1])+(comb4[2]+comb4[3]))+((comb4[4]+comb4[5])+(comb4[6]+comb4[7])))+(((comb4[8]+comb4[9])+(comb4[10]+comb4[11]))+((comb4[12]+comb4[13])+(in[14]+in[15])));

assign out=(temp1+temp2)+(temp3+temp4);

endmodule
