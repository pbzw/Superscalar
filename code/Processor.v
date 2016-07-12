
`include "define.v"

module Processor(
input clk,
input rst,
// Instruction Memory
output[`data_lentgh-1:0]inst_address,
input [`data_lentgh-1:0]inst1_in,
input [`data_lentgh-1:0]inst2_in,
input [`data_lentgh-1:0]inst3_in,
input [`data_lentgh-1:0]inst4_in,
input InstMem_Ready,
output InstMem_Read,
//Data Memory 
output [3:0]  DataMem_Select,
output [`data_lentgh-1:0] DataMem_Address,
input  [`data_lentgh-1:0] ReadDataMem ,
output [`data_lentgh-1:0] WriteDataMem,
input DataMem_Ready,
output DataMem_access,DataMem_RW

);
/*IF Stage*/
wire IF_Stall;
wire [31:0]PC_add_4,PCsrc_o;

/*ID Stage*/
wire [31:0]ID_PC;
wire ID_Stall,ID_flush;
wire [31:0]ID_inst1,ID_inst2,ID_inst3,ID_inst4;
//Inst1
wire[8:0]ID_Inst1_ALUop;
wire ID_Inst1_RegW,ID_Inst1_Instvalid;
wire [4:0]ID_Inst1_Src1,ID_Inst1_Src2,ID_Inst1_Rdst;
wire [31:0]ID_Inst1_Extend_imm,ID_Inst1_PC;
//Inst2
wire[8:0]ID_Inst2_ALUop;
wire ID_Inst2_RegW,ID_Inst2_Instvalid;
wire [4:0]ID_Inst2_Src1,ID_Inst2_Src2,ID_Inst2_Rdst;
wire [31:0]ID_Inst2_Extend_imm,ID_Inst2_PC;
//Inst3
wire[8:0]ID_Inst3_ALUop;
wire ID_Inst3_RegW,ID_Inst3_Instvalid;
wire [4:0]ID_Inst3_Src1,ID_Inst3_Src2,ID_Inst3_Rdst;
wire [31:0]ID_Inst3_Extend_imm,ID_Inst3_PC;

//Inst4
wire[8:0]ID_Inst4_ALUop;
wire ID_Inst4_RegW,ID_Inst4_Instvalid;
wire [4:0]ID_Inst4_Src1,ID_Inst4_Src2,ID_Inst4_Rdst;
wire [31:0]ID_Inst4_Extend_imm,ID_Inst4_PC;
wire [31:0]RN_PC;
/*RN Stage*/
wire RN_Stall;
wire RN_Flush;
//Inst1
wire[8:0] RN_Inst1_ALUop;
wire RN_Inst1_RegW,RN_Inst1_Instvalid;
wire [4:0]RN_Inst1_Src1,RN_Inst1_Src2,RN_Inst1_Rdst;
wire [31:0]RN_Inst1_Extend_imm,RN_Inst1_PC;

//Inst2
wire[8:0] RN_Inst2_ALUop;
wire RN_Inst2_RegW,RN_Inst2_Instvalid;
wire [4:0]RN_Inst2_Src1,RN_Inst2_Src2,RN_Inst2_Rdst;
wire [31:0]RN_Inst2_Extend_imm,RN_Inst2_PC;

//Inst3
wire[8:0] RN_Inst3_ALUop;
wire RN_Inst3_RegW,RN_Inst3_Instvalid;
wire [4:0]RN_Inst3_Src1,RN_Inst3_Src2,RN_Inst3_Rdst;
wire [31:0]RN_Inst3_Extend_imm,RN_Inst3_PC;

//Inst4
wire[8:0] RN_Inst4_ALUop;
wire RN_Inst4_RegW,RN_Inst4_Instvalid;
wire [4:0]RN_Inst4_Src1,RN_Inst4_Src2,RN_Inst4_Rdst;
wire [31:0]RN_Inst4_Extend_imm,RN_Inst4_PC;

//RE
wire [5:0]RE_Inst1_RSrc1,RE_Inst1_RSrc2,RE_Inst1_Phydst;
wire [5:0]RE_Inst2_RSrc1,RE_Inst2_RSrc2,RE_Inst2_Phydst;
wire [5:0]RE_Inst3_RSrc1,RE_Inst3_RSrc2,RE_Inst3_Phydst;
wire [5:0]RE_Inst4_RSrc1,RE_Inst4_RSrc2,RE_Inst4_Phydst;

assign InstMem_Read=(!IF_Stall);


//DS
wire [31:0]DS_Inst_PC;
wire [8:0]DS_Inst1_ALUop;
wire [4:0]DS_Inst1_Rdst,DS_Inst1_Src1,DS_Inst1_Src2;
wire [5:0]DS_Inst1_Phy,DS_Inst1_RSrc1,DS_Inst1_RSrc2;

wire [4:0]IS_Inst1_Rdst;
wire [5:0]IS_Inst1_Phy,IS_Inst1_Src1,IS_Inst1_Src2;

//Inst2
wire [8:0]DS_Inst2_ALUop;
wire [4:0]DS_Inst2_Rdst,DS_Inst2_Src1,DS_Inst2_Src2;
wire [5:0]DS_Inst2_Phy,DS_Inst2_RSrc1,DS_Inst2_RSrc2;

wire [4:0]IS_Inst2_Rdst;
wire [5:0]IS_Inst2_Phy,IS_Inst2_Src1,IS_Inst2_Src2;

//Inst3
wire [8:0]DS_Inst3_ALUop;
wire [4:0]DS_Inst3_Rdst,DS_Inst3_Src1,DS_Inst3_Src2;
wire [5:0]DS_Inst3_Phy,DS_Inst3_RSrc1,DS_Inst3_RSrc2;

wire [4:0]IS_Inst3_Rdst;
wire [5:0]IS_Inst3_Phy,IS_Inst3_Src1,IS_Inst3_Src2;

//Inst4
wire [8:0]DS_Inst4_ALUop;
wire [4:0]DS_Inst4_Rdst,DS_Inst4_Src1,DS_Inst4_Src2;
wire [5:0]DS_Inst4_Phy,DS_Inst4_RSrc1,DS_Inst4_RSrc2;

wire [4:0]IS_Inst4_Rdst;
wire [5:0]IS_Inst4_Phy,IS_Inst4_Src1,IS_Inst4_Src2;

//////////////*IS Stage*/
wire IS_Stall;
wire Issue_window_full;

wire [5:0]IS_Inst1_RSrc1,IS_Inst1_RSrc2,IS_Inst1_Phydst;
wire [31:0]IS_Inst1_imm,IS_Inst1_PC;
wire [8:0]IS_Inst1_ALUop;
wire IS_Inst1_Valid;


wire [5:0]IS_Inst2_RSrc1,IS_Inst2_RSrc2,IS_Inst2_Phydst;
wire [31:0]IS_Inst2_imm,IS_Inst2_PC;
wire [8:0]IS_Inst2_ALUop;
wire IS_Inst2_Valid;

wire [5:0]IS_Inst3_RSrc1,IS_Inst3_RSrc2,IS_Inst3_Phydst;
wire [31:0]IS_Inst3_imm,IS_Inst3_PC;
wire [8:0]IS_Inst3_ALUop;
wire IS_Inst3_Valid;

wire [5:0]IS_Inst4_RSrc1,IS_Inst4_RSrc2,IS_Inst4_Phydst;
wire [31:0]IS_Inst4_imm,IS_Inst4_PC;
wire [8:0]IS_Inst4_ALUop;
wire IS_Inst4_Valid;

/*Function Unit Write Back*/
wire WB_ALU0_Valid,WB_ALU1_Valid,WB_ALU2_Valid,WB_ALU3_Valid;
wire [5:0]WB_ALU0_Phydst,WB_ALU1_Phydst,WB_ALU2_Phydst,WB_ALU3_Phydst;
wire [4:0]WB_ALU0_Rdst,WB_ALU1_Rdst,WB_ALU2_Rdst,WB_ALU3_Rdst;
wire [3:0]WB_ALU0_Commit_Window,WB_ALU1_Commit_Window,WB_ALU2_Commit_Window,WB_ALU3_Commit_Window;
wire [31:0]WB_ALU0_Result,WB_ALU1_Result,WB_ALU2_Result,WB_ALU3_Result;
/*Commit Unit */
wire Commit_1;
wire [4:0]Commit_Rdst_1;
wire [5:0]Commit_Phy_1;

Add Add_pc(
.A(inst_address),
.B(32'd16),
.C(PC_add_4)
);

Register #(.WIDTH(32),.reset(32'h0000))PC(
.clk(clk),
.rst(rst),
.en((!IF_Stall)),
.data_in(PCsrc_o),
.data_out(inst_address)
);

Mux2 #(.WIDTH(32))PCsrcMux(
.sel(1'b0/*(Branch_out&Commit)*/),
.in0(PC_add_4),
.in1(Branch_PC_out),
.out(PCsrc_o)
);

IF_ID IF_ID(
.clk(clk),
.rst(rst),
.stall(ID_Stall),
.flush(ID_flush),
.IF_inst1_in(inst1_in),
.IF_inst2_in(inst2_in),
.IF_inst3_in(inst3_in),
.IF_inst4_in(inst4_in),
.IF_PC_in(inst_address),
.inst_en(InstMem_Ready),

.ID_inst_en(ID_inst_en),
.ID_PC(ID_PC),
.ID_inst1(ID_inst1),
.ID_inst2(ID_inst2),
.ID_inst3(ID_inst3),
.ID_inst4(ID_inst4)
);

Decoder Decoder(
.inst_en(ID_inst_en),
.Inst1(ID_inst1),
.Inst2(ID_inst2),
.Inst3(ID_inst3),
.Inst4(ID_inst4),
.Inst1_ALUop(ID_Inst1_ALUop),
.Inst1_RegW(ID_Inst1_RegW),
.Inst1_Instvalid(ID_Inst1_Instvalid),
.Inst1_Src1(ID_Inst1_Src1),
.Inst1_Src2(ID_Inst1_Src2),
.Inst1_Rdst(ID_Inst1_Rdst),
.Inst1_Extend_imm(ID_Inst1_Extend_imm),
.Inst2_ALUop(ID_Inst2_ALUop),
.Inst2_RegW(ID_Inst2_RegW),
.Inst2_Instvalid(ID_Inst2_Instvalid),
.Inst2_Src1(ID_Inst2_Src1),
.Inst2_Src2(ID_Inst2_Src2),
.Inst2_Rdst(ID_Inst2_Rdst),
.Inst2_Extend_imm(ID_Inst2_Extend_imm),
.Inst3_ALUop(ID_Inst3_ALUop),
.Inst3_RegW(ID_Inst3_RegW),
.Inst3_Instvalid(ID_Inst3_Instvalid),
.Inst3_Src1(ID_Inst3_Src1),
.Inst3_Src2(ID_Inst3_Src2),
.Inst3_Rdst(ID_Inst3_Rdst),
.Inst3_Extend_imm(ID_Inst3_Extend_imm),
.Inst4_ALUop(ID_Inst4_ALUop),
.Inst4_RegW(ID_Inst4_RegW),
.Inst4_Instvalid(ID_Inst4_Instvalid),
.Inst4_Src1(ID_Inst4_Src1),
.Inst4_Src2(ID_Inst4_Src2),
.Inst4_Rdst(ID_Inst4_Rdst),
.Inst4_Extend_imm(ID_Inst4_Extend_imm)
);

ID_RN ID_RN( 
.clk(clk),
.rst(rst),
.stall(RN_Stall),
.flush(RN_flush),
//Inst1
.ID_Inst1_ALUop(ID_Inst1_ALUop),
.ID_Inst1_RegW(ID_Inst1_RegW),
.ID_Inst1_Instvalid(ID_Inst1_Instvalid),
.ID_Inst1_Src1(ID_Inst1_Src1),
.ID_Inst1_Src2(ID_Inst1_Src2),
.ID_Inst1_Rdst(ID_Inst1_Rdst),
.ID_Inst1_Extend_imm(ID_Inst1_Extend_imm),
.ID_Inst1_PC(ID_PC),

.RN_Inst1_ALUop(RN_Inst1_ALUop),
.RN_Inst1_RegW(RN_Inst1_RegW),
.RN_Inst1_Instvalid(RN_Inst1_Instvalid),
.RN_Inst1_Src1(RN_Inst1_Src1),
.RN_Inst1_Src2(RN_Inst1_Src2),
.RN_Inst1_Rdst(RN_Inst1_Rdst),
.RN_Inst1_Extend_imm(RN_Inst1_Extend_imm),
.RN_Inst1_PC(RN_PC),
//Inst2
.ID_Inst2_ALUop(ID_Inst2_ALUop),
.ID_Inst2_RegW(ID_Inst2_RegW),
.ID_Inst2_Instvalid(ID_Inst2_Instvalid),
.ID_Inst2_Src1(ID_Inst2_Src1),
.ID_Inst2_Src2(ID_Inst2_Src2),
.ID_Inst2_Rdst(ID_Inst2_Rdst),
.ID_Inst2_Extend_imm(ID_Inst2_Extend_imm),

.RN_Inst2_ALUop(RN_Inst2_ALUop),
.RN_Inst2_RegW(RN_Inst2_RegW),
.RN_Inst2_Instvalid(RN_Inst2_Instvalid),
.RN_Inst2_Src1(RN_Inst2_Src1),
.RN_Inst2_Src2(RN_Inst2_Src2),
.RN_Inst2_Rdst(RN_Inst2_Rdst),
.RN_Inst2_Extend_imm(RN_Inst2_Extend_imm),
//Inst3
.ID_Inst3_ALUop(ID_Inst3_ALUop),
.ID_Inst3_RegW(ID_Inst3_RegW),
.ID_Inst3_Instvalid(ID_Inst3_Instvalid),
.ID_Inst3_Src1(ID_Inst3_Src1),
.ID_Inst3_Src2(ID_Inst3_Src2),
.ID_Inst3_Rdst(ID_Inst3_Rdst),
.ID_Inst3_Extend_imm(ID_Inst3_Extend_imm),

.RN_Inst3_ALUop(RN_Inst3_ALUop),
.RN_Inst3_RegW(RN_Inst3_RegW),
.RN_Inst3_Instvalid(RN_Inst3_Instvalid),
.RN_Inst3_Src1(RN_Inst3_Src1),
.RN_Inst3_Src2(RN_Inst3_Src2),
.RN_Inst3_Rdst(RN_Inst3_Rdst),
.RN_Inst3_Extend_imm(RN_Inst3_Extend_imm),
//Inst4
.ID_Inst4_ALUop(ID_Inst4_ALUop),
.ID_Inst4_RegW(ID_Inst4_RegW),
.ID_Inst4_Instvalid(ID_Inst4_Instvalid),
.ID_Inst4_Src1(ID_Inst4_Src1),
.ID_Inst4_Src2(ID_Inst4_Src2),
.ID_Inst4_Rdst(ID_Inst4_Rdst),
.ID_Inst4_Extend_imm(ID_Inst4_Extend_imm),

.RN_Inst4_ALUop(RN_Inst4_ALUop),
.RN_Inst4_RegW(RN_Inst4_RegW),
.RN_Inst4_Instvalid(RN_Inst4_Instvalid),
.RN_Inst4_Src1(RN_Inst4_Src1),
.RN_Inst4_Src2(RN_Inst4_Src2),
.RN_Inst4_Rdst(RN_Inst4_Rdst),
.RN_Inst4_Extend_imm(RN_Inst4_Extend_imm)
);

Register_Rename Register_Rename(
.clk(clk),
.rst(rst),
.Branch_flush(1'b0),
.Stall(RN_Stall),

//Commit Unit

.Commit(Commit_1),
.Commit_Phy(Commit_Phy_1),
.Commit_Rdst(Commit_Rdst_1),

//flush phy wake

.flush_wake_Phy(),

//Inst1 in

.Inst1_RegW(RN_Inst1_RegW),
.Inst1_Valid(RN_Inst1_Instvalid),
.Inst1_Src1(RN_Inst1_Src1),
.Inst1_Src2(RN_Inst1_Src2),
.Inst1_Rdst(RN_Inst1_Rdst),

//Inst2 in

.Inst2_RegW(RN_Inst2_RegW),
.Inst2_Valid(RN_Inst2_Instvalid),
.Inst2_Src1(RN_Inst2_Src1),
.Inst2_Src2(RN_Inst2_Src2),
.Inst2_Rdst(RN_Inst2_Rdst),

//Inst3 in
.Inst3_RegW(RN_Inst3_RegW),
.Inst3_Valid(RN_Inst3_Instvalid),
.Inst3_Src1(RN_Inst3_Src1),
.Inst3_Src2(RN_Inst3_Src2),
.Inst3_Rdst(RN_Inst3_Rdst),

//Inst4 in
.Inst4_RegW(RN_Inst4_RegW),
.Inst4_Valid(RN_Inst4_Instvalid),
.Inst4_Src1(RN_Inst4_Src1),
.Inst4_Src2(RN_Inst4_Src2),
.Inst4_Rdst(RN_Inst4_Rdst),

//Inst1 out
.RE_Inst1_RSrc1(RE_Inst1_RSrc1),
.RE_Inst1_RSrc2(RE_Inst1_RSrc2),
.RE_Inst1_RPhydst(RE_Inst1_Phydst),

//Inst1 out
.RE_Inst2_RSrc1(RE_Inst2_RSrc1),
.RE_Inst2_RSrc2(RE_Inst2_RSrc2),
.RE_Inst2_RPhydst(RE_Inst2_Phydst),

//Inst1 out
.RE_Inst3_RSrc1(RE_Inst3_RSrc1),
.RE_Inst3_RSrc2(RE_Inst3_RSrc2),
.RE_Inst3_RPhydst(RE_Inst3_Phydst),

//Inst1 out
.RE_Inst4_RSrc1(RE_Inst4_RSrc1),
.RE_Inst4_RSrc2(RE_Inst4_RSrc2),
.RE_Inst4_RPhydst(RE_Inst4_Phydst),

.RU_Stall(RU_Stall)

);

wire [31:0]DS_Inst1_imm;
wire [31:0]DS_Inst2_imm;
wire [31:0]DS_Inst3_imm;
wire [31:0]DS_Inst4_imm;
wire DS_Inst1_Valid,DS_Inst2_Valid,DS_Inst3_Valid,DS_Inst4_Valid;
RN_DS RN_DS(
.clk(clk),
.rst(rst),
.flush(RN_DS_flush),
.Stall(DS_Stall),
.RN_Inst_PC(RN_PC),
.DS_Inst_PC(DS_Inst_PC),
//Inst1
.RN_Inst1_Valid(RN_Inst1_Instvalid),
.RN_Inst1_ALUop(RN_Inst1_ALUop),
.RN_Inst1_Src1(RN_Inst1_Src1),
.RN_Inst1_Src2(RN_Inst1_Src2),
.RN_Inst1_Rdst(RN_Inst1_Rdst),
.RE_Inst1_RSrc1(RE_Inst1_RSrc1),
.RE_Inst1_RSrc2(RE_Inst1_RSrc2),
.RE_Inst1_Phydst(RE_Inst1_Phydst),
.RN_Inst1_imm(RN_Inst1_Extend_imm),

.DS_Inst1_Valid(DS_Inst1_Valid),
.DS_Inst1_ALUop(DS_Inst1_ALUop),
.DS_Inst1_Src1(DS_Inst1_Src1),
.DS_Inst1_Src2(DS_Inst1_Src2),
.DS_Inst1_Rdst(DS_Inst1_Rdst),
.DS_Inst1_RSrc1(DS_Inst1_RSrc1),
.DS_Inst1_RSrc2(DS_Inst1_RSrc2),
.DS_Inst1_Phydst(DS_Inst1_Phy),
.DS_Inst1_imm(DS_Inst1_imm),

//Inst2
.RN_Inst2_Valid(RN_Inst2_Instvalid),
.RN_Inst2_ALUop(RN_Inst2_ALUop),
.RN_Inst2_Src1(RN_Inst2_Src1),
.RN_Inst2_Src2(RN_Inst2_Src2),
.RN_Inst2_Rdst(RN_Inst2_Rdst),
.RE_Inst2_RSrc1(RE_Inst2_RSrc1),
.RE_Inst2_RSrc2(RE_Inst2_RSrc2),
.RE_Inst2_Phydst(RE_Inst2_Phydst),
.RN_Inst2_imm(RN_Inst2_Extend_imm),

.DS_Inst2_Valid(DS_Inst2_Valid),
.DS_Inst2_ALUop(DS_Inst2_ALUop),
.DS_Inst2_Src1(DS_Inst2_Src1),
.DS_Inst2_Src2(DS_Inst2_Src2),
.DS_Inst2_Rdst(DS_Inst2_Rdst),
.DS_Inst2_RSrc1(DS_Inst2_RSrc1),
.DS_Inst2_RSrc2(DS_Inst2_RSrc2),
.DS_Inst2_Phydst(DS_Inst2_Phy),
.DS_Inst2_imm(DS_Inst2_imm),

//Inst3
.RN_Inst3_Valid(RN_Inst3_Instvalid),
.RN_Inst3_ALUop(RN_Inst3_ALUop),
.RN_Inst3_Src1(RN_Inst3_Src1),
.RN_Inst3_Src2(RN_Inst3_Src2),
.RN_Inst3_Rdst(RN_Inst3_Rdst),
.RE_Inst3_RSrc1(RE_Inst3_RSrc1),
.RE_Inst3_RSrc2(RE_Inst3_RSrc2),
.RE_Inst3_Phydst(RE_Inst3_Phydst),
.RN_Inst3_imm(RN_Inst3_Extend_imm),

.DS_Inst3_Valid(DS_Inst3_Valid),
.DS_Inst3_ALUop(DS_Inst3_ALUop),
.DS_Inst3_Src1(DS_Inst3_Src1),
.DS_Inst3_Src2(DS_Inst3_Src2),
.DS_Inst3_Rdst(DS_Inst3_Rdst),
.DS_Inst3_RSrc1(DS_Inst3_RSrc1),
.DS_Inst3_RSrc2(DS_Inst3_RSrc2),
.DS_Inst3_Phydst(DS_Inst3_Phy),
.DS_Inst3_imm(DS_Inst3_imm),

//Inst4
.RN_Inst4_Valid(RN_Inst4_Instvalid),
.RN_Inst4_ALUop(RN_Inst4_ALUop),
.RN_Inst4_Src1(RN_Inst4_Src1),
.RN_Inst4_Src2(RN_Inst4_Src2),
.RN_Inst4_Rdst(RN_Inst4_Rdst),
.RE_Inst4_RSrc1(RE_Inst4_RSrc1),
.RE_Inst4_RSrc2(RE_Inst4_RSrc2),
.RE_Inst4_Phydst(RE_Inst4_Phydst),
.RN_Inst4_imm(RN_Inst4_Extend_imm),

.DS_Inst4_Valid(DS_Inst4_Valid),
.DS_Inst4_ALUop(DS_Inst4_ALUop),
.DS_Inst4_Src1(DS_Inst4_Src1),
.DS_Inst4_Src2(DS_Inst4_Src2),
.DS_Inst4_Rdst(DS_Inst4_Rdst),
.DS_Inst4_RSrc1(DS_Inst4_RSrc1),
.DS_Inst4_RSrc2(DS_Inst4_RSrc2),
.DS_Inst4_Phydst(DS_Inst4_Phy),
.DS_Inst4_imm(DS_Inst4_imm)
);

wire [5:0]Dispatched_Inst1_Src1,Dispatched_Inst1_Src2;
wire [5:0]Dispatched_Inst2_Src1,Dispatched_Inst2_Src2;
wire [5:0]Dispatched_Inst3_Src1,Dispatched_Inst3_Src2;
wire [5:0]Dispatched_Inst4_Src1,Dispatched_Inst4_Src2;



Dispatch Dispatch(

//Inst1
.DS_Inst1_Rdst(DS_Inst1_Rdst),
.DS_Inst1_Src1(DS_Inst1_Src1),
.DS_Inst1_Src2(DS_Inst1_Src2),
.DS_Inst1_Phy(DS_Inst1_Phy),
.DS_Inst1_RSrc1(DS_Inst1_RSrc1),
.DS_Inst1_RSrc2(DS_Inst1_RSrc2),

.IS_Inst1_Src1(Dispatched_Inst1_Src1),
.IS_Inst1_Src2(Dispatched_Inst1_Src2),

//Inst2
.DS_Inst2_Rdst(DS_Inst2_Rdst),
.DS_Inst2_Src1(DS_Inst2_Src1),
.DS_Inst2_Src2(DS_Inst2_Src2),
.DS_Inst2_Phy(DS_Inst2_Phy),
.DS_Inst2_RSrc1(DS_Inst2_RSrc1),
.DS_Inst2_RSrc2(DS_Inst2_RSrc2),


.IS_Inst2_Src1(Dispatched_Inst2_Src1),
.IS_Inst2_Src2(Dispatched_Inst2_Src2),

//Inst3
.DS_Inst3_Rdst(DS_Inst3_Rdst),
.DS_Inst3_Src1(DS_Inst3_Src1),
.DS_Inst3_Src2(DS_Inst3_Src2),
.DS_Inst3_Phy(DS_Inst3_Phy),
.DS_Inst3_RSrc1(DS_Inst3_RSrc1),
.DS_Inst3_RSrc2(DS_Inst3_RSrc2),

.IS_Inst3_Src1(Dispatched_Inst3_Src1),
.IS_Inst3_Src2(Dispatched_Inst3_Src2),

//Inst4
.DS_Inst4_Rdst(DS_Inst4_Rdst),
.DS_Inst4_Src1(DS_Inst4_Src1),
.DS_Inst4_Src2(DS_Inst4_Src2),
.DS_Inst4_Phy(DS_Inst4_Phy),
.DS_Inst4_RSrc1(DS_Inst4_RSrc1),
.DS_Inst4_RSrc2(DS_Inst4_RSrc2),

.IS_Inst4_Src1(Dispatched_Inst4_Src1),
.IS_Inst4_Src2(Dispatched_Inst4_Src2)
);


DS_IS DS_IS(
.clk(clk),
.rst(rst),
.flush(1'b0),
.Stall(IS_Stall),

.DS_Inst_PC(DS_Inst_PC),

//Inst1
.DS_Inst1_Valid(DS_Inst1_Valid),
.DS_Inst1_ALUop(DS_Inst1_ALUop),
.DS_Inst1_Rdst(DS_Inst1_Rdst),
.DS_Inst1_RSrc1(Dispatched_Inst1_Src1),//Need Dispatched Rsrc
.DS_Inst1_RSrc2(Dispatched_Inst1_Src2),
.DS_Inst1_Phydst(DS_Inst1_Phy),
.DS_Inst1_imm(DS_Inst1_imm),

.IS_Inst1_Valid(IS_Inst1_Valid),
.IS_Inst1_ALUop(IS_Inst1_ALUop),
.IS_Inst1_Rdst(IS_Inst1_Rdst),
.IS_Inst1_RSrc1(IS_Inst1_RSrc1),
.IS_Inst1_RSrc2(IS_Inst1_RSrc2),
.IS_Inst1_Phydst(IS_Inst1_Phydst),
.IS_Inst1_imm(IS_Inst1_imm),
.IS_Inst1_PC(IS_Inst1_PC),

//Inst2
.DS_Inst2_Valid(DS_Inst2_Valid),
.DS_Inst2_ALUop(DS_Inst2_ALUop),
.DS_Inst2_Rdst(DS_Inst2_Rdst),
.DS_Inst2_RSrc1(Dispatched_Inst2_Src1),//Need Dispatched Rsrc
.DS_Inst2_RSrc2(Dispatched_Inst2_Src2),
.DS_Inst2_Phydst(DS_Inst2_Phy),
.DS_Inst2_imm(DS_Inst2_imm),

.IS_Inst2_Valid(IS_Inst2_Valid),
.IS_Inst2_ALUop(IS_Inst2_ALUop),
.IS_Inst2_Rdst(IS_Inst2_Rdst),
.IS_Inst2_RSrc1(IS_Inst2_RSrc1),
.IS_Inst2_RSrc2(IS_Inst2_RSrc2),
.IS_Inst2_Phydst(IS_Inst2_Phydst),
.IS_Inst2_imm(IS_Inst2_imm),
.IS_Inst2_PC(IS_Inst2_PC),

//Inst3
.DS_Inst3_Valid(DS_Inst3_Valid),
.DS_Inst3_ALUop(DS_Inst3_ALUop),
.DS_Inst3_Rdst(DS_Inst3_Rdst),
.DS_Inst3_RSrc1(Dispatched_Inst3_Src1),//Need Dispatched Rsrc
.DS_Inst3_RSrc2(Dispatched_Inst3_Src2),
.DS_Inst3_Phydst(DS_Inst3_Phy),
.DS_Inst3_imm(DS_Inst3_imm),

.IS_Inst3_Valid(IS_Inst3_Valid),
.IS_Inst3_ALUop(IS_Inst3_ALUop),
.IS_Inst3_Rdst(IS_Inst3_Rdst),
.IS_Inst3_RSrc1(IS_Inst3_RSrc1),
.IS_Inst3_RSrc2(IS_Inst3_RSrc2),
.IS_Inst3_Phydst(IS_Inst3_Phydst),
.IS_Inst3_imm(IS_Inst3_imm),
.IS_Inst3_PC(IS_Inst3_PC),

//Inst4
.DS_Inst4_Valid(DS_Inst4_Valid),
.DS_Inst4_ALUop(DS_Inst4_ALUop),
.DS_Inst4_Rdst(DS_Inst4_Rdst),
.DS_Inst4_RSrc1(Dispatched_Inst4_Src1),//Need Dispatched Rsrc
.DS_Inst4_RSrc2(Dispatched_Inst4_Src2),
.DS_Inst4_Phydst(DS_Inst4_Phy),
.DS_Inst4_imm(DS_Inst4_imm),

.IS_Inst4_Valid(IS_Inst4_Valid),
.IS_Inst4_ALUop(IS_Inst4_ALUop),
.IS_Inst4_Rdst(IS_Inst4_Rdst),
.IS_Inst4_RSrc1(IS_Inst4_RSrc1),
.IS_Inst4_RSrc2(IS_Inst4_RSrc2),
.IS_Inst4_Phydst(IS_Inst4_Phydst),
.IS_Inst4_imm(IS_Inst4_imm),
.IS_Inst4_PC(IS_Inst4_PC)
);

wire Inst1_Src1_Wake,Inst1_Src2_Wake;
wire Inst2_Src1_Wake,Inst2_Src2_Wake;
wire Inst3_Src1_Wake,Inst3_Src2_Wake;
wire Inst4_Src1_Wake,Inst4_Src2_Wake;

Wake_Unit Wake_Unit(
.clk(clk),
.rst(rst),
.flush(1'b0),
.Stall(IS_Stall),

//Inst1
.Inst1_Src1(IS_Inst1_RSrc1),
.Inst1_Src2(IS_Inst1_RSrc2),
.Inst1_Phydst(IS_Inst1_Phydst),

.Inst1_Src1_Wake(Inst1_Src1_Wake),
.Inst1_Src2_Wake(Inst1_Src2_Wake),
//Inst2
.Inst2_Src1(IS_Inst2_RSrc1),
.Inst2_Src2(IS_Inst2_RSrc2),
.Inst2_Phydst(IS_Inst2_Phydst),

.Inst2_Src1_Wake(Inst2_Src1_Wake),
.Inst2_Src2_Wake(Inst2_Src2_Wake),
//Inst3
.Inst3_Src1(IS_Inst3_RSrc1),
.Inst3_Src2(IS_Inst3_RSrc2),
.Inst3_Phydst(IS_Inst3_Phydst),

.Inst3_Src1_Wake(Inst3_Src1_Wake),
.Inst3_Src2_Wake(Inst3_Src2_Wake),

//Inst4
.Inst4_Src1(IS_Inst4_RSrc1),
.Inst4_Src2(IS_Inst4_RSrc2),
.Inst4_Phydst(IS_Inst4_Phydst),

.Inst4_Src1_Wake(Inst4_Src1_Wake),
.Inst4_Src2_Wake(Inst4_Src2_Wake),

.ALU0_wake(WB_ALU0_Valid),
.ALU0_Phydst(WB_ALU0_Phydst),
.ALU1_wake(WB_ALU1_Valid),
.ALU1_Phydst(WB_ALU1_Phydst),
.ALU2_wake(WB_ALU2_Valid),
.ALU2_Phydst(WB_ALU2_Phydst),
.ALU3_wake(WB_ALU3_Valid),
.ALU3_Phydst(WB_ALU3_Phydst)
/*,
//BU_wake
input [5:0]BU_Phydst,
input BU_wake,
//BU_wake
input [5:0]DU_Phydst,
input DU_wake,
*/
);




wire[4:0]SL_ALU0_Commit_Window,SL_ALU0_Rdst;
wire SL_ALU0_en;
wire[5:0]SL_ALU0_Phydst,SL_ALU0_Src1,SL_ALU0_Src2;
wire[5:0]SL_ALU0_operation;
wire[31:0]SL_ALU0_imm;

wire[4:0]SL_ALU1_Commit_Window,SL_ALU1_Rdst;
wire SL_ALU1_en;
wire[5:0]SL_ALU1_Phydst,SL_ALU1_Src1,SL_ALU1_Src2;
wire[5:0]SL_ALU1_operation;
wire[31:0]SL_ALU1_imm;

wire[4:0]SL_ALU2_Commit_Window,SL_ALU2_Rdst;
wire SL_ALU2_en;
wire[5:0]SL_ALU2_Phydst,SL_ALU2_Src1,SL_ALU2_Src2;
wire[5:0]SL_ALU2_operation;
wire[31:0]SL_ALU2_imm;

wire[4:0]SL_ALU3_Commit_Window,SL_ALU3_Rdst;
wire SL_ALU3_en;
wire[5:0]SL_ALU3_Phydst,SL_ALU3_Src1,SL_ALU3_Src2;
wire[5:0]SL_ALU3_operation;
wire[31:0]SL_ALU3_imm;
Issue_Window #(.DEPTH (16)) Issue_Window(
.clk(clk),
.rst(rst),
.Stall(IS_Stall),
.flush(1'b0),

/*Inst1 in*/
.Inst1_Src1_Wake(Inst1_Src1_Wake),
.Inst1_Src2_Wake(Inst1_Src2_Wake),
.Inst1_Valid(IS_Inst1_Valid),
.Inst1_Function(IS_Inst1_ALUop[8:5]),
.Inst1_Operation(IS_Inst1_ALUop[4:0]),
.Inst1_imm(IS_Inst1_imm),
.Inst1_PC(IS_Inst1_PC),
.Inst1_Phydst(IS_Inst1_Phydst),
.Inst1_Src1(IS_Inst1_RSrc1),
.Inst1_Src2(IS_Inst1_RSrc2),
.Inst1_Rdst(IS_Inst1_Rdst),

/*Inst2 in*/
.Inst2_Src1_Wake(Inst2_Src1_Wake),
.Inst2_Src2_Wake(Inst2_Src2_Wake),
.Inst2_Valid(IS_Inst2_Valid),
.Inst2_Function(IS_Inst2_ALUop[8:5]),
.Inst2_Operation(IS_Inst2_ALUop[4:0]),
.Inst2_imm(IS_Inst2_imm),
.Inst2_PC(IS_Inst2_PC),
.Inst2_Phydst(IS_Inst2_Phydst),
.Inst2_Src1(IS_Inst2_RSrc1),
.Inst2_Src2(IS_Inst2_RSrc2),
.Inst2_Rdst(IS_Inst2_Rdst),

/*Inst3 in*/
.Inst3_Src1_Wake(Inst3_Src1_Wake),
.Inst3_Src2_Wake(Inst3_Src2_Wake),
.Inst3_Valid(IS_Inst3_Valid),
.Inst3_Function(IS_Inst3_ALUop[8:5]),
.Inst3_Operation(IS_Inst3_ALUop[4:0]),
.Inst3_imm(IS_Inst3_imm),
.Inst3_PC(IS_Inst3_PC),
.Inst3_Phydst(IS_Inst3_Phydst),
.Inst3_Src1(IS_Inst3_RSrc1),
.Inst3_Src2(IS_Inst3_RSrc2),
.Inst3_Rdst(IS_Inst3_Rdst),

/*Inst4 in*/
.Inst4_Src1_Wake(Inst4_Src1_Wake),
.Inst4_Src2_Wake(Inst4_Src2_Wake),
.Inst4_Valid(IS_Inst4_Valid),
.Inst4_Function(IS_Inst4_ALUop[8:5]),
.Inst4_Operation(IS_Inst4_ALUop[4:0]),
.Inst4_imm(IS_Inst4_imm),
.Inst4_PC(IS_Inst4_PC),
.Inst4_Phydst(IS_Inst4_Phydst),
.Inst4_Src1(IS_Inst4_RSrc1),
.Inst4_Src2(IS_Inst4_RSrc2),
.Inst4_Rdst(IS_Inst4_Rdst),

/*Commit Unit*/
.Commit_1(Commit_1),
.Commit_Phy_1(Commit_Phy_1),
.Commit_Rdst_1(Commit_Rdst_1),

/*Wake Src*/
.ALU0_Commit(WB_ALU0_Valid),
.ALU0_Phydst(WB_ALU0_Phydst),//TAG For wake
.ALU1_Commit(WB_ALU1_Valid),
.ALU1_Phydst(WB_ALU1_Phydst),//TAG For wake
.ALU2_Commit(WB_ALU2_Valid),
.ALU2_Phydst(WB_ALU2_Phydst),//TAG For wake
.ALU3_Commit(WB_ALU3_Valid),
.ALU3_Phydst(WB_ALU3_Phydst),//TAG For wake
/*WB*/
.WB_ALU0_Commit_Window(WB_ALU0_Commit_Window),
.WB_ALU1_Commit_Window(WB_ALU1_Commit_Window),
.WB_ALU2_Commit_Window(WB_ALU2_Commit_Window),
.WB_ALU3_Commit_Window(WB_ALU3_Commit_Window),
/*Issue Window*/
.Issue_window_full(Issue_window_full),
/*ALU Select*/

/*Select For ALU0 Unit*/
.SL_ALU0_Commit_Window(SL_ALU0_Commit_Window),
.SL_ALU0_Rdst(SL_ALU0_Rdst),
.SL_ALU0_en(SL_ALU0_en),
.SL_ALU0_Phydst(SL_ALU0_Phydst),
.SL_ALU0_Src1(SL_ALU0_Src1),
.SL_ALU0_Src2(SL_ALU0_Src2),
.SL_ALU0_operation(SL_ALU0_operation),
.SL_ALU0_imm(SL_ALU0_imm),

/*Select For ALU1 Unit*/
.SL_ALU1_Commit_Window(SL_ALU1_Commit_Window),
.SL_ALU1_Rdst(SL_ALU1_Rdst),
.SL_ALU1_en(SL_ALU1_en),
.SL_ALU1_Phydst(SL_ALU1_Phydst),
.SL_ALU1_Src1(SL_ALU1_Src1),
.SL_ALU1_Src2(SL_ALU1_Src2),
.SL_ALU1_operation(SL_ALU1_operation),
.SL_ALU1_imm(SL_ALU1_imm),

/*Select For ALU2 Unit*/
.SL_ALU2_Commit_Window(SL_ALU2_Commit_Window),
.SL_ALU2_Rdst(SL_ALU2_Rdst),
.SL_ALU2_en(SL_ALU2_en),
.SL_ALU2_Phydst(SL_ALU2_Phydst),
.SL_ALU2_Src1(SL_ALU2_Src1),
.SL_ALU2_Src2(SL_ALU2_Src2),
.SL_ALU2_operation(SL_ALU2_operation),
.SL_ALU2_imm(SL_ALU2_imm),

/*Select For ALU3 Unit*/
.SL_ALU3_Commit_Window(SL_ALU3_Commit_Window),
.SL_ALU3_Rdst(SL_ALU3_Rdst),
.SL_ALU3_en(SL_ALU3_en),
.SL_ALU3_Phydst(SL_ALU3_Phydst),
.SL_ALU3_Src1(SL_ALU3_Src1),
.SL_ALU3_Src2(SL_ALU3_Src2),
.SL_ALU3_operation(SL_ALU3_operation),
.SL_ALU3_imm(SL_ALU3_imm)

);

wire [31:0]EX_ALU0_Src1,EX_ALU0_Src2;
wire [31:0]EX_ALU1_Src1,EX_ALU1_Src2;
wire [31:0]EX_ALU2_Src1,EX_ALU2_Src2;
wire [31:0]EX_ALU3_Src1,EX_ALU3_Src2;

regfile #(.WIDTH(32),.DEPTH(64) )regfile(
.clk(clk),
.we_1(WB_ALU0_Valid),
.we_2(WB_ALU1_Valid),
.we_3(WB_ALU2_Valid),
.we_4(WB_ALU3_Valid),
.read_reg1(SL_ALU0_Src1),
.read_reg2(SL_ALU0_Src2),
.read_reg3(SL_ALU1_Src1),
.read_reg4(SL_ALU1_Src2),
.read_reg5(SL_ALU2_Src1),
.read_reg6(SL_ALU2_Src2),
.read_reg7(SL_ALU3_Src1),
.read_reg8(SL_ALU3_Src2),
.read_reg9(),
.read_reg10(),
.read_reg11(),
.read_reg12(),
.read_reg13(),
.read_reg14(),
.read_reg15(),
.read_reg16(),
.read_reg17(),
.read_reg18(),
.read_reg19(),
.read_reg20(),

.write_reg1(WB_ALU0_Phydst),
.write_reg2(WB_ALU1_Phydst),
.write_reg3(WB_ALU2_Phydst),
.write_reg4(WB_ALU3_Phydst),
.write_reg1_data(WB_ALU0_Result),
.write_reg2_data(WB_ALU1_Result),
.write_reg3_data(WB_ALU2_Result),
.write_reg4_data(WB_ALU3_Result),

.read_out_1(EX_ALU0_Src1),
.read_out_2(EX_ALU0_Src2),
.read_out_3(EX_ALU1_Src1),
.read_out_4(EX_ALU1_Src2),
.read_out_5(EX_ALU2_Src1),
.read_out_6(EX_ALU2_Src2),
.read_out_7(EX_ALU3_Src1),
.read_out_8(EX_ALU3_Src2)/*,read_out_9,read_out_a0,read_out_11,read_out_12,
output [WIDTH-1:0] read_out_13,read_out_14,read_out_15,read_out_16,read_out_17,read_out_18,
output [WIDTH-1:0] read_out_19,read_out_20*/
);


EX_ALU EX_ALU0(
.clk(clk),
.rst(rst),
.flush(1'b0),

.EX_Rdst(SL_ALU0_Rdst),
.EX_Operation(SL_ALU0_operation),
.EX_imm(SL_ALU0_imm),
.EX_Src1(EX_ALU0_Src1),
.EX_Src2(EX_ALU0_Src2),
.EX_Phydst(SL_ALU0_Phydst),
.EX_Commit_Window(SL_ALU0_Commit_Window),
.EX_en(SL_ALU0_en),
 
.WB_Rdst(WB_ALU0_Rdst),
.WB_Commit_Window(WB_ALU0_Commit_Window),
.WB_Phydst(WB_ALU0_Phydst),
.WB_Result(WB_ALU0_Result),
.WB_valid(WB_ALU0_Valid)
);

EX_ALU EX_ALU1(
.clk(clk),
.rst(rst),
.flush(1'b0),

.EX_Rdst(SL_ALU1_Rdst),
.EX_Operation(SL_ALU1_operation),
.EX_imm(SL_ALU1_imm),
.EX_Src1(EX_ALU1_Src1),
.EX_Src2(EX_ALU1_Src2),
.EX_Phydst(SL_ALU1_Phydst),
.EX_Commit_Window(SL_ALU1_Commit_Window),
.EX_en(SL_ALU1_en),
 
.WB_Rdst(WB_ALU1_Rdst),
.WB_Commit_Window(WB_ALU1_Commit_Window),
.WB_Phydst(WB_ALU1_Phydst),
.WB_Result(WB_ALU1_Result),
.WB_valid(WB_ALU1_Valid)
);




assign DataMem_Address=WB_ALU1_Result;

Stall_Unit Stall_Unit(
.Issue_Window_Full(Issue_window_full),
.Rename_fales(RU_Stall),
.Inst_Ready(InstMem_Ready),

.IF_Stall(IF_Stall),
.ID_Stall(ID_Stall),
.RN_Stall(RN_Stall),
.DS_Stall(DS_Stall),
.IS_Stall(IS_Stall),

.Branch((Branch_out&Commit)),


.IF_ID_flush(IF_ID_flush),
.ID_RN_flush(ID_RN_flush),
.RN_DS_flush(RN_DS_flush),
.Rename_flush(Rename_flush),
.Issue_Window_flush(Issue_Window_flush),
.Function_Unit_flush(Function_Unit_flush)
);
endmodule


module Stall_Unit(
input Issue_Window_Full,
input Rename_fales,
input Inst_Ready,
input Branch,

output IF_Stall,ID_Stall,RN_Stall,DS_Stall,IS_Stall,
output IF_ID_flush,ID_RN_flush,RN_DS_flush,Rename_flush,
output Issue_Window_flush,Function_Unit_flush
);

assign IF_Stall=Issue_Window_Full|Rename_fales;
assign ID_Stall=Issue_Window_Full|Rename_fales;
assign RN_Stall=Issue_Window_Full|Rename_fales;
assign DS_Stall=Issue_Window_Full;
assign IS_Stall=Issue_Window_Full;


assign IF_ID_flush=Branch;
assign ID_RN_flush=Branch;
assign RN_DS_flush=Rename_fales&(!Issue_Window_Full);
assign Rename_flush=Branch;
assign Issue_Window_flush=Branch;
assign Function_Unit_flush=Branch;
endmodule
