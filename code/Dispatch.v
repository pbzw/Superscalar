module Dispatch(
//Inst1
input [4:0]DS_Inst1_Rdst,DS_Inst1_Src1,DS_Inst1_Src2,
input [5:0]DS_Inst1_Phy,DS_Inst1_RSrc1,DS_Inst1_RSrc2,

output [5:0]IS_Inst1_Src1,IS_Inst1_Src2,

//Inst2
input [4:0]DS_Inst2_Rdst,DS_Inst2_Src1,DS_Inst2_Src2,
input [5:0]DS_Inst2_Phy,DS_Inst2_RSrc1,DS_Inst2_RSrc2,

output [5:0]IS_Inst2_Src1,IS_Inst2_Src2

);

wire [5:0]Inst2_Src1,Inst2_Src2;

wire Inst2_Src1_Match=(DS_Inst1_Rdst==DS_Inst2_Src1)&(|DS_Inst1_Rdst);
wire Inst2_Src2_Match=(DS_Inst1_Rdst==DS_Inst2_Src2)&(|DS_Inst1_Rdst);





wire [1:0]PE1_out,PE2_out;

wire [5:0]Inst4_Src1,Inst4_Src2;

assign IS_Inst1_Src1=DS_Inst1_RSrc1;
assign IS_Inst1_Src2=DS_Inst1_RSrc2;


Mux2 #(.WIDTH (6))Inst2_Src1_Mux(
.sel(Inst2_Src1_Match),
.in0(DS_Inst2_RSrc1),
.in1(DS_Inst1_Phy),
.out(IS_Inst2_Src1)
);

Mux2 #(.WIDTH (6))Inst2_Src2_Mux(
.sel(Inst2_Src2_Match),
.in0(DS_Inst2_RSrc2),
.in1(DS_Inst1_Phy),
.out(IS_Inst2_Src2)
);


endmodule
