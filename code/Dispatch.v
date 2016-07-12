module Dispatch(
//Inst1
input [4:0]DS_Inst1_Rdst,DS_Inst1_Src1,DS_Inst1_Src2,
input [5:0]DS_Inst1_Phy,DS_Inst1_RSrc1,DS_Inst1_RSrc2,

output [5:0]IS_Inst1_Src1,IS_Inst1_Src2,

//Inst2
input [4:0]DS_Inst2_Rdst,DS_Inst2_Src1,DS_Inst2_Src2,
input [5:0]DS_Inst2_Phy,DS_Inst2_RSrc1,DS_Inst2_RSrc2,

output [5:0]IS_Inst2_Src1,IS_Inst2_Src2,

//Inst3
input [4:0]DS_Inst3_Rdst,DS_Inst3_Src1,DS_Inst3_Src2,
input [5:0]DS_Inst3_Phy,DS_Inst3_RSrc1,DS_Inst3_RSrc2,

output [5:0]IS_Inst3_Src1,IS_Inst3_Src2,

//Inst4
input [4:0]DS_Inst4_Rdst,DS_Inst4_Src1,DS_Inst4_Src2,
input [5:0]DS_Inst4_Phy,DS_Inst4_RSrc1,DS_Inst4_RSrc2,

output [5:0]IS_Inst4_Src1,IS_Inst4_Src2
);

wire [5:0]Inst2_Src1,Inst2_Src2;

wire Inst2_Src1_Match=(DS_Inst1_Rdst==DS_Inst2_Src1)&(|DS_Inst1_Rdst);
wire Inst2_Src2_Match=(DS_Inst1_Rdst==DS_Inst2_Src2)&(|DS_Inst1_Rdst);

wire Inst3_Inst1_Src1_Match=(DS_Inst1_Rdst==DS_Inst3_Src1)&(|DS_Inst1_Rdst);
wire Inst3_Inst1_Src2_Match=(DS_Inst1_Rdst==DS_Inst3_Src2)&(|DS_Inst1_Rdst);
wire Inst3_Inst2_Src1_Match=(DS_Inst2_Rdst==DS_Inst3_Src1)&(|DS_Inst2_Rdst);
wire Inst3_Inst2_Src2_Match=(DS_Inst2_Rdst==DS_Inst3_Src2)&(|DS_Inst2_Rdst);

wire [5:0]Inst3_Src1,Inst3_Src2;

wire Inst4_Inst1_Src1_Match=(DS_Inst1_Rdst==DS_Inst4_Src1)&(|DS_Inst1_Rdst);
wire Inst4_Inst1_Src2_Match=(DS_Inst1_Rdst==DS_Inst4_Src2)&(|DS_Inst1_Rdst);
wire Inst4_Inst2_Src1_Match=(DS_Inst2_Rdst==DS_Inst4_Src1)&(|DS_Inst2_Rdst);
wire Inst4_Inst2_Src2_Match=(DS_Inst2_Rdst==DS_Inst4_Src2)&(|DS_Inst2_Rdst);
wire Inst4_Inst3_Src1_Match=(DS_Inst3_Rdst==DS_Inst4_Src1)&(|DS_Inst3_Rdst);
wire Inst4_Inst3_Src2_Match=(DS_Inst3_Rdst==DS_Inst4_Src2)&(|DS_Inst3_Rdst);

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

Mux4 #(.WIDTH (6))Inst3_Src1_Mux(
.sel({Inst3_Inst2_Src1_Match,Inst3_Inst1_Src1_Match}),
.in0(DS_Inst3_RSrc1),
.in1(DS_Inst1_Phy),
.in2(DS_Inst2_Phy),
.in3(DS_Inst2_Phy),
.out(IS_Inst3_Src1)
);

Mux4 #(.WIDTH (6))Inst3_Src2_Mux(
.sel({Inst3_Inst2_Src2_Match,Inst3_Inst1_Src2_Match}),
.in0(DS_Inst3_RSrc2),
.in1(DS_Inst1_Phy),
.in2(DS_Inst2_Phy),
.in3(DS_Inst2_Phy),//two match use the last one
.out(IS_Inst3_Src2)
);

PE PE1(
.a(Inst4_Inst1_Src1_Match),
.b(Inst4_Inst2_Src1_Match),
.c(Inst4_Inst3_Src1_Match),
.out(PE1_out)
);

PE PE2(
.a(Inst4_Inst1_Src2_Match),
.b(Inst4_Inst2_Src2_Match),
.c(Inst4_Inst3_Src2_Match),
.out(PE2_out)
);



Mux4 #(.WIDTH (6))Inst4_Src1_Mux(
.sel(PE1_out),
.in0(DS_Inst4_RSrc1),
.in1(DS_Inst1_Phy),
.in2(DS_Inst2_Phy),
.in3(DS_Inst3_Phy),
.out(IS_Inst4_Src1)
);

Mux4 #(.WIDTH (6))Inst4_Src2_Mux(
.sel(PE2_out),
.in0(DS_Inst4_RSrc2),
.in1(DS_Inst1_Phy),
.in2(DS_Inst2_Phy),
.in3(DS_Inst3_Phy),
.out(IS_Inst4_Src2)
);

endmodule

module PE(
input a,b,c,
output reg  [1:0]out
);

always@(*) begin
	casex({a,b,c})
	3'b000:out=2'b00;
	3'b100:out=2'b01;
	3'bx10:out=2'b10;
	3'bxx1:out=2'b11;
	default:out=2'b00;
	endcase
end
endmodule
