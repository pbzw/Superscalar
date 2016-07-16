module Register_Rename(
input clk,
input rst,
input Branch_flush,
input Stall,
//Commit Unit

input Commit_1,
input [5:0]Commit_Phy_1,
input [4:0]Commit_Rdst_1,
input Commit_2,
input [5:0]Commit_Phy_2,
input [4:0]Commit_Rdst_2,


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


always@(posedge clk) begin
		for(i=0;i<64;i=i+1)
			Commit_Mapping_used[i]<=1'd0;
		for(i=0;i<32;i=i+1)
			Commit_Mapping_used[Commit_Mapping[i]]<=1'd1;
			Commit_Mapping_used[Commit_Phy_1]<=1'd1;
			Commit_Mapping_used[Commit_Phy_2]<=1'd1;
end
wire No_Phy;

//Update Commit Map 
always@(posedge clk)begin
	if(rst)
		for(i=0;i<32;i=i+1)
			Commit_Mapping[i]<=6'b0;
	else begin
		if(Commit_1&(Commit_Rdst_1!=5'd0))
			Commit_Mapping[Commit_Rdst_1]<=Commit_Phy_1;
		if(Commit_2&(Commit_Rdst_2!=5'd0))
			Commit_Mapping[Commit_Rdst_2]<=Commit_Phy_2;
		end
end

always@(posedge clk)begin
	if(rst)
		for(i=0;i<32;i=i+1)
			{Temp_Mappling_Phy[i]}<=5'b0;
	else if(Branch_flush)begin
		for(i=1;i<32;i=i+1)
			Temp_Mappling_Phy[i]<=Commit_Mapping[i];
		if(Commit_1&(Commit_Rdst_1!=5'd0))
			Temp_Mappling_Phy[Commit_Rdst_1]<= Commit_Phy_1;
		if(Commit_2&(Commit_Rdst_2!=5'd0))
			Temp_Mappling_Phy[Commit_Rdst_2]<= Commit_Phy_2;
		end
	else begin
		if(Inst1_RegW&(!Stall)&(Inst1_Rdst!=6'd0))
			{Temp_Mappling_Phy[Inst1_Rdst]}<={RE_Inst1_RPhydst};
		if(Inst2_RegW&(!Stall)&(Inst2_Rdst!=6'd0))
			{Temp_Mappling_Phy[Inst2_Rdst]}<={RE_Inst2_RPhydst};
		end
end
reg  [5:0]j;
always@(posedge clk)begin
	if(rst) begin
		for(i=0;i<64;i=i+1)
			{Phy_Using_Used[i],Phy_Using_Committed[i]}<=2'b00;
		end
	else begin
		if(Branch_flush) begin
			for(i=0;i<64;i=i+1)
				if(Phy_Using_Used[i]&(!Phy_Using_Committed[i]))
					{Phy_Using_Used[i],Phy_Using_Committed[i]}<=2'b00;
			if(Commit_1)
				{Phy_Using_Used[Commit_Phy_1],Phy_Using_Committed[Commit_Phy_1]}<=2'b11;
			if(Commit_2)
				{Phy_Using_Used[Commit_Phy_2],Phy_Using_Committed[Commit_Phy_2]}<=2'b11;
			end
		
		if(Commit_1)begin
			{Phy_Using_Committed[Commit_Phy_1]}<=1'b1;
			end
		if(Commit_2)begin
			{Phy_Using_Committed[Commit_Phy_2]}<=1'b1;
			end	
		if(Inst1_RegW&(!Stall)) 
			{Phy_Using_Used[RE_Inst1_RPhydst],Phy_Using_Committed[RE_Inst1_RPhydst]}<=2'b10;
		if(Inst2_RegW&(!Stall)) 
			{Phy_Using_Used[RE_Inst2_RPhydst],Phy_Using_Committed[RE_Inst2_RPhydst]}<=2'b10;

		end
end

assign RE_Inst1_RSrc1=Temp_Mappling_Phy[Inst1_Src1];
assign RE_Inst1_RSrc2=Temp_Mappling_Phy[Inst1_Src2];

assign RE_Inst2_RSrc1=Temp_Mappling_Phy[Inst2_Src1];
assign RE_Inst2_RSrc2=Temp_Mappling_Phy[Inst2_Src2];



Physical_Register_Free_List  Physical_Register_Free_Buffer_List(

.in(Phy_can_Used),//can_Use_Phy
.Take1(Inst1_RegW&Inst1_Valid),
.Take2(Inst2_RegW&Inst2_Valid),

.Take_Phy1(RE_Inst1_RPhydst),
.Take_Phy2(RE_Inst2_RPhydst),

.Stall(No_Phy)
);

assign RU_Stall=No_Phy;

endmodule




module Physical_Register_Free_List (
input [0:63]in,//can_Use_Phy
input Take1,Take2,
output [5:0]Take_Phy1,Take_Phy2,
output Stall
);
wire [5:0]LPE_out_1,LPE_out_2;
wire [0:31]List1,List2,List3,List4;
wire List1OK=|List1;
wire List2OK=|List2;


assign Stall=!(List1OK&List2OK);


assign List1={1'b0,in[02],in[04],in[06],in[08],
            in[10],in[12],in[14],in[16],in[18],
				in[20],in[22],in[24],in[26],in[28],
				in[30],in[32],in[34],in[36],in[38],
				in[40],in[42],in[44],in[46],in[48],
				in[50],in[52],in[54],in[56],in[58],
				in[60],in[62]};
assign List2={
				in[01],in[03],in[05],in[07],in[09],
            in[11],in[13],in[15],in[17],in[19],
				in[21],in[23],in[25],in[27],in[29],
				in[31],in[33],in[35],in[37],in[39],
				in[41],in[43],in[45],in[47],in[49],
				in[51],in[53],in[55],in[57],in[59],
				in[61],in[63]};
				
assign Take_Phy1=Take1?LPE_out_1:6'd0;
assign Take_Phy2=Take2?LPE_out_2:6'd0;


LPE #(.FIX(1'd0))List1_LPE(
.in(List1),
.out(LPE_out_1)
);

LPE #(.FIX(1'd1))List2_LPE(
.in(List2),
.out(LPE_out_2)
);



endmodule

module LPE #(parameter FIX=1'd0)(
input [31:0]in,
output reg[5:0]out
);
always@(*)begin
	casex(in)
	32'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd00,FIX};
	32'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd01,FIX};
	32'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd02,FIX};
	32'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd03,FIX};
	32'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd04,FIX};
	32'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd05,FIX};
	32'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd06,FIX};
	32'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd07,FIX};
	32'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd08,FIX};
	32'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd09,FIX};
	32'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd10,FIX};
	32'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx:out={5'd11,FIX};
	32'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx:out={5'd12,FIX};
	32'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx:out={5'd13,FIX};
	32'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx:out={5'd14,FIX};
	32'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx:out={5'd15,FIX};
	32'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx:out={5'd16,FIX};
	32'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx:out={5'd17,FIX};
	32'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx:out={5'd18,FIX};
	32'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx:out={5'd19,FIX};
	32'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx:out={5'd20,FIX};
	32'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx:out={5'd21,FIX};
	32'b0000_0000_0000_0000_0000_001x_xxxx_xxxx:out={5'd22,FIX};
	32'b0000_0000_0000_0000_0000_0001_xxxx_xxxx:out={5'd23,FIX};
	32'b0000_0000_0000_0000_0000_0000_1xxx_xxxx:out={5'd24,FIX};
	32'b0000_0000_0000_0000_0000_0000_01xx_xxxx:out={5'd25,FIX};
	32'b0000_0000_0000_0000_0000_0000_001x_xxxx:out={5'd26,FIX};
	32'b0000_0000_0000_0000_0000_0000_0001_xxxx:out={5'd27,FIX};
	32'b0000_0000_0000_0000_0000_0000_0000_1xxx:out={5'd28,FIX};
	32'b0000_0000_0000_0000_0000_0000_0000_01xx:out={5'd29,FIX};
	32'b0000_0000_0000_0000_0000_0000_0000_001x:out={5'd30,FIX};
	32'b0000_0000_0000_0000_0000_0000_0000_0001:out={5'd31,FIX};
	default:out={5'd00,FIX};
	endcase
end

endmodule
