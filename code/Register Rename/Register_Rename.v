module Register_Rename(
input clk,
input rst,
input Branch_flush,
input Stall,
//Commit Unit

input Commit,
input [5:0]Commit_Phy,
input [4:0]Commit_Rdst,

//flush phy wake
output [63:0] flush_wake_Phy,

//
input Inst1_Valid,Inst1_RegW,
input [4:0] Inst1_Src1,Inst1_Src2,Inst1_Rdst,
output [5:0]RE_Inst1_RSrc1,RE_Inst1_RSrc2,
output [5:0]RE_Inst1_RPhydst,


//

input Inst2_Valid,Inst2_RegW,
input [4:0] Inst2_Src1,Inst2_Src2,Inst2_Rdst,
output[5:0]RE_Inst2_RSrc1,RE_Inst2_RSrc2,
output [5:0]RE_Inst2_RPhydst,

//
input Inst3_Valid,Inst3_RegW,
input [4:0] Inst3_Src1,Inst3_Src2,Inst3_Rdst,
output[5:0]RE_Inst3_RSrc1,RE_Inst3_RSrc2,
output[5:0]RE_Inst3_RPhydst,

//
input Inst4_Valid,Inst4_RegW,
input [4:0] Inst4_Src1,Inst4_Src2,Inst4_Rdst,
output[5:0]RE_Inst4_RSrc1,RE_Inst4_RSrc2,
output[5:0]RE_Inst4_RPhydst,

output RU_Stall
 
);
integer i;




/*Temp_Mappling_Log*/
reg [5:0]Temp_Mappling_Phy[0:31];

/*Phy_Using_Log*/
reg [0:63]Phy_Using_Used;
reg [0:63]Phy_Using_Committed;

/*Commit_Mapping_Log*/
reg [5:0]Commit_Mapping[0:31];
reg [0:63]Commit_Mapping_used;

reg  [0:63]use_Rename;
wire [0:63]can_use=Phy_Using_Committed&(~Commit_Mapping_used);//SET avaliable Phy Commit Temp table used is not avaliable
wire [0:63]Phy_can_Used;



assign Phy_can_Used=((~Phy_Using_Used)|can_use);
assign flush_wake_Phy=Phy_Using_Used&(~Phy_Using_Committed);

/*
always@(*) begin
		for(i=0;i<64;i=i+1)
			Commit_Mapping_used[i]<=1'd0;
		for(i=0;i<32;i=i+1)
			Commit_Mapping_used[Commit_Mapping[i]]<=1'd1;
			Commit_Mapping_used[Commit_Phy]<=1'd1;
end*/
wire [4:0]out_1,out_2;

//Update Commit Map 
always@(posedge clk)begin
	if(rst)
		for(i=0;i<32;i=i+1)
			Commit_Mapping[i]<=5'b0;
	else if(Commit&(Commit_Rdst!=5'd0))
		Commit_Mapping[Commit_Rdst]<=Commit_Phy;
end

always@(posedge clk)begin
	if(rst)
		for(i=0;i<32;i=i+1)
			{Temp_Mappling_Phy[i]}<=5'b0;
	else if(Branch_flush)begin
		for(i=1;i<32;i=i+1)
			Temp_Mappling_Phy[i]<=Commit_Mapping[i];
		if(Commit&(Commit_Rdst!=5'd0))
			Temp_Mappling_Phy[Commit_Rdst]<= Commit_Phy;
		end
	else begin
		if(Inst1_RegW&(!RU_Stall)&(Inst1_Rdst!=6'd0))
			{Temp_Mappling_Phy[Inst1_Rdst]}<={RE_Inst1_RPhydst};
		if(Inst2_RegW&(!RU_Stall)&(Inst2_Rdst!=6'd0))
			{Temp_Mappling_Phy[Inst2_Rdst]}<={RE_Inst2_RPhydst};
		if(Inst3_RegW&(!RU_Stall)&(Inst3_Rdst!=6'd0))
			{Temp_Mappling_Phy[Inst3_Rdst]}<={RE_Inst3_RPhydst};
		if(Inst4_RegW&(!RU_Stall)&(Inst4_Rdst!=6'd0))
			{Temp_Mappling_Phy[Inst4_Rdst]}<={RE_Inst4_RPhydst};
		end
end
reg  [5:0]j;
always@(posedge clk)begin
	if(rst) begin
		{Phy_Using_Used[0],Phy_Using_Committed[0]}<=2'b11;
		for(i=0;i<64;i=i+1)
			{Phy_Using_Used[i],Phy_Using_Committed[i]}<=2'b00;
		end
	else begin
		if(Branch_flush) begin
			for(i=0;i<64;i=i+1)
				if(Phy_Using_Used[i]&(!Phy_Using_Committed[i]))
					{Phy_Using_Used[i],Phy_Using_Committed[i]}<=2'b00;
			if(Commit)
				{Phy_Using_Used[Commit_Phy],Phy_Using_Committed[Commit_Phy]}<=2'b11;
			end
		if(Commit)begin
			{Phy_Using_Committed[Commit_Phy]}<=1'b1;
			end
			
		if(Inst1_RegW&(!RU_Stall)) 
			{Phy_Using_Used[RE_Inst1_RPhydst],Phy_Using_Committed[RE_Inst1_RPhydst]}<=2'b10;
		if(Inst2_RegW&(!RU_Stall)) 
			{Phy_Using_Used[RE_Inst2_RPhydst],Phy_Using_Committed[RE_Inst2_RPhydst]}<=2'b10;
		if(Inst3_RegW&(!RU_Stall)) 
			{Phy_Using_Used[RE_Inst3_RPhydst],Phy_Using_Committed[RE_Inst3_RPhydst]}<=2'b10;
		if(Inst4_RegW&(!RU_Stall)) 
			{Phy_Using_Used[RE_Inst4_RPhydst],Phy_Using_Committed[RE_Inst4_RPhydst]}<=2'b10;

		end
end

assign RE_Inst1_RSrc1=Temp_Mappling_Phy[Inst1_Src1];
assign RE_Inst1_RSrc2=Temp_Mappling_Phy[Inst1_Src2];

assign RE_Inst2_RSrc1=Temp_Mappling_Phy[Inst2_Src1];
assign RE_Inst2_RSrc2=Temp_Mappling_Phy[Inst2_Src2];

assign RE_Inst3_RSrc1=Temp_Mappling_Phy[Inst3_Src1];
assign RE_Inst3_RSrc2=Temp_Mappling_Phy[Inst3_Src2];

assign RE_Inst4_RSrc1=Temp_Mappling_Phy[Inst4_Src1];
assign RE_Inst4_RSrc2=Temp_Mappling_Phy[Inst4_Src2];
wire No_Phy;

Physical_Register_Free_List  Physical_Register_Free_Buffer_List(

.in(Phy_can_Used),//can_Use_Phy
.Take1(Inst1_RegW),
.Take2(Inst2_RegW),
.Take3(Inst3_RegW),
.Take4(Inst4_RegW),

.Take_Phy1(RE_Inst1_RPhydst),
.Take_Phy2(RE_Inst2_RPhydst),
.Take_Phy3(RE_Inst3_RPhydst),
.Take_Phy4(RE_Inst4_RPhydst),
.Stall(No_Phy)
);

assign RU_Stall=Stall|No_Phy;

endmodule




module Physical_Register_Free_List (
input [0:63]in,//can_Use_Phy
input Take1,Take2,Take3,Take4,
output [5:0]Take_Phy1,Take_Phy2,Take_Phy3,Take_Phy4,
output Stall
);
wire [5:0]LPE_out_1,LPE_out_2,LPE_out_3,LPE_out_4;
wire [0:15]List1,List2,List3,List4;
wire List1OK=|List1;
wire List2OK=|List2;
wire List3OK=|List3;
wire List4OK=|List4;

assign Stall=!(List1OK&List2OK&List3OK&List4OK);


assign List1={1'b0,in[04],in[08],in[12],in[16],in[20],in[24],in[28],in[32],in[36],in[40],in[44],in[48],in[52],in[56],in[60]};
assign List2={in[01],in[05],in[09],in[13],in[17],in[21],in[25],in[29],in[33],in[37],in[41],in[45],in[49],in[53],in[57],in[61]};
assign List3={in[02],in[06],in[10],in[14],in[18],in[22],in[26],in[30],in[34],in[38],in[42],in[46],in[50],in[54],in[58],in[62]};
assign List4={in[03],in[07],in[11],in[15],in[19],in[23],in[27],in[31],in[35],in[39],in[43],in[47],in[51],in[55],in[59],in[63]};

assign Take_Phy1=Take1?LPE_out_1:6'd0;
assign Take_Phy2=Take2?LPE_out_2:6'd0;
assign Take_Phy3=Take3?LPE_out_3:6'd0;
assign Take_Phy4=Take4?LPE_out_4:6'd0;

LPE #(.FIX(2'd0))List1_LPE(
.in(List1),
.out(LPE_out_1)
);

LPE #(.FIX(2'd1))List2_LPE(
.in(List2),
.out(LPE_out_2)
);

LPE #(.FIX(2'd2))List3_LPE(
.in(List3),
.out(LPE_out_3)
);


LPE #(.FIX(2'd3))List4_LPE(
.in(List4),
.out(LPE_out_4)
);

endmodule

module LPE #(parameter FIX=2'd0)(
input [15:0]in,
output reg[5:0]out
);
always@(*)begin
	casex(in)
	16'b1xxx_xxxx_xxxx_xxxx:out={4'd00,FIX};
	16'b01xx_xxxx_xxxx_xxxx:out={4'd01,FIX};
	16'b001x_xxxx_xxxx_xxxx:out={4'd02,FIX};
	16'b0001_xxxx_xxxx_xxxx:out={4'd03,FIX};
	16'b0000_1xxx_xxxx_xxxx:out={4'd04,FIX};
	16'b0000_01xx_xxxx_xxxx:out={4'd05,FIX};
	16'b0000_001x_xxxx_xxxx:out={4'd06,FIX};
	16'b0000_0001_xxxx_xxxx:out={4'd07,FIX};
	16'b0000_0000_1xxx_xxxx:out={4'd08,FIX};
	16'b0000_0000_01xx_xxxx:out={4'd09,FIX};
	16'b0000_0000_001x_xxxx:out={4'd10,FIX};
	16'b0000_0000_0001_xxxx:out={4'd11,FIX};
	16'b0000_0000_0000_1xxx:out={4'd12,FIX};
	16'b0000_0000_0000_01xx:out={4'd13,FIX};
	16'b0000_0000_0000_001x:out={4'd14,FIX};
	16'b0000_0000_0000_0001:out={4'd15,FIX};
	default:out={4'd00,FIX};
	endcase
end

endmodule
