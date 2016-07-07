
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

wire [4:0]DS_Inst1_Rdst,DS_Inst1_Src1,DS_Inst1_Src2;
wire [5:0]DS_Inst1_Phy,DS_Inst1_RSrc1,DS_Inst1_RSrc2;

wire [5:0]IS_Inst1_Rdst,IS_Inst1_Phy,IS_Inst1_Src1,IS_Inst1_Src2;

//Inst2
wire [4:0]DS_Inst2_Rdst,DS_Inst2_Src1,DS_Inst2_Src2;
wire [5:0]DS_Inst2_Phy,DS_Inst2_RSrc1,DS_Inst2_RSrc2;

wire [5:0]IS_Inst2_Rdst,IS_Inst2_Phy,IS_Inst2_Src1,IS_Inst2_Src2;

//Inst3
wire [4:0]DS_Inst3_Rdst,DS_Inst3_Src1,DS_Inst3_Src2;
wire [5:0]DS_Inst3_Phy,DS_Inst3_RSrc1,DS_Inst3_RSrc2;

wire [5:0]IS_Inst3_Rdst,IS_Inst3_Phy,IS_Inst3_Src1,IS_Inst3_Src2;

//Inst4
wire [4:0]DS_Inst4_Rdst,DS_Inst4_Src1,DS_Inst4_Src2;
wire [5:0]DS_Inst4_Phy,DS_Inst4_RSrc1,DS_Inst4_RSrc2;

wire [5:0]IS_Inst4_Rdst,IS_Inst4_Phy,IS_Inst4_Src1,IS_Inst4_Src2;

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
.Stall(1'b0),

//Commit Unit

.Commit(),
.Commit_Phy(),
.Commit_Rdst(),

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

RN_DS RN_DS(
.clk(clk),
.rst(rst),
.flush(1'b0),
.Stall(1'b0),
.RN_Inst_PC(RN_PC),
.DS_Inst_PC(DS_PC),
//Inst1
.RN_Inst1_ALUop(RN_Inst1_ALUop),
.RN_Inst1_Src1(RN_Inst1_Src1),
.RN_Inst1_Src2(RN_Inst1_Src2),
.RN_Inst1_Rdst(RN_Inst1_Rdst),
.RE_Inst1_RSrc1(RE_Inst1_RSrc1),
.RE_Inst1_RSrc2(RE_Inst1_RSrc2),
.RE_Inst1_Phydst(RE_Inst1_Phydst),
.RN_Inst1_imm(RN_Inst1_Extend_imm),

.DS_Inst1_ALUop(),
.DS_Inst1_Src1(DS_Inst1_Src1),
.DS_Inst1_Src2(DS_Inst1_Src2),
.DS_Inst1_Rdst(DS_Inst1_Rdst),
.DS_Inst1_RSrc1(DS_Inst1_RSrc1),
.DS_Inst1_RSrc2(DS_Inst1_RSrc2),
.DS_Inst1_Phydst(DS_Inst1_Phy),
.DS_Inst1_imm(),

//Inst2
.RN_Inst2_ALUop(RN_Inst2_ALUop),
.RN_Inst2_Src1(RN_Inst2_Src1),
.RN_Inst2_Src2(RN_Inst2_Src2),
.RN_Inst2_Rdst(RN_Inst2_Rdst),
.RE_Inst2_RSrc1(RE_Inst2_RSrc1),
.RE_Inst2_RSrc2(RE_Inst2_RSrc2),
.RE_Inst2_Phydst(RE_Inst2_Phydst),
.RN_Inst2_imm(RN_Inst2_Extend_imm),

.DS_Inst2_ALUop(),
.DS_Inst2_Src1(DS_Inst2_Src1),
.DS_Inst2_Src2(DS_Inst2_Src2),
.DS_Inst2_Rdst(DS_Inst2_Rdst),
.DS_Inst2_RSrc1(DS_Inst2_RSrc1),
.DS_Inst2_RSrc2(DS_Inst2_RSrc2),
.DS_Inst2_Phydst(DS_Inst2_Phy),
.DS_Inst2_imm(),

//Inst3
.RN_Inst3_ALUop(RN_Inst3_ALUop),
.RN_Inst3_Src1(RN_Inst3_Src1),
.RN_Inst3_Src2(RN_Inst3_Src2),
.RN_Inst3_Rdst(RN_Inst3_Rdst),
.RE_Inst3_RSrc1(RE_Inst3_RSrc1),
.RE_Inst3_RSrc2(RE_Inst3_RSrc2),
.RE_Inst3_Phydst(RE_Inst3_Phydst),
.RN_Inst3_imm(RN_Inst3_Extend_imm),

.DS_Inst3_ALUop(),
.DS_Inst3_Src1(DS_Inst3_Src1),
.DS_Inst3_Src2(DS_Inst3_Src2),
.DS_Inst3_Rdst(DS_Inst3_Rdst),
.DS_Inst3_RSrc1(DS_Inst3_RSrc1),
.DS_Inst3_RSrc2(DS_Inst3_RSrc2),
.DS_Inst3_Phydst(DS_Inst3_Phy),
.DS_Inst3_imm(),

//Inst4
.RN_Inst4_ALUop(RN_Inst4_ALUop),
.RN_Inst4_Src1(RN_Inst4_Src1),
.RN_Inst4_Src2(RN_Inst4_Src2),
.RN_Inst4_Rdst(RN_Inst4_Rdst),
.RE_Inst4_RSrc1(RE_Inst4_RSrc1),
.RE_Inst4_RSrc2(RE_Inst4_RSrc2),
.RE_Inst4_Phydst(RE_Inst4_Phydst),
.RN_Inst4_imm(RN_Inst4_Extend_imm),

.DS_Inst4_ALUop(),
.DS_Inst4_Src1(DS_Inst4_Src1),
.DS_Inst4_Src2(DS_Inst4_Src2),
.DS_Inst4_Rdst(DS_Inst4_Rdst),
.DS_Inst4_RSrc1(DS_Inst4_RSrc1),
.DS_Inst4_RSrc2(DS_Inst4_RSrc2),
.DS_Inst4_Phydst(DS_Inst4_Phy),
.DS_Inst4_imm()
);

Dispatch Dispatch(
//Inst1
.DS_Inst1_Rdst(DS_Inst1_Rdst),
.DS_Inst1_Src1(DS_Inst1_Src1),
.DS_Inst1_Src2(DS_Inst1_Src2),
.DS_Inst1_Phy(DS_Inst1_Phy),
.DS_Inst1_RSrc1(DS_Inst1_RSrc1),
.DS_Inst1_RSrc2(DS_Inst1_RSrc2),

.IS_Inst1_Src1(),
.IS_Inst1_Src2(),

//Inst2
.DS_Inst2_Rdst(DS_Inst2_Rdst),
.DS_Inst2_Src1(DS_Inst2_Src1),
.DS_Inst2_Src2(DS_Inst2_Src2),
.DS_Inst2_Phy(DS_Inst2_Phy),
.DS_Inst2_RSrc1(DS_Inst2_RSrc1),
.DS_Inst2_RSrc2(DS_Inst2_RSrc2),


.IS_Inst2_Src1(),
.IS_Inst2_Src2(),

//Inst3
.DS_Inst3_Rdst(DS_Inst3_Rdst),
.DS_Inst3_Src1(DS_Inst3_Src1),
.DS_Inst3_Src2(DS_Inst3_Src2),
.DS_Inst3_Phy(DS_Inst3_Phy),
.DS_Inst3_RSrc1(DS_Inst3_RSrc1),
.DS_Inst3_RSrc2(DS_Inst3_RSrc2),

.IS_Inst3_Src1(),
.IS_Inst3_Src2(DataMem_Address),

//Inst4
.DS_Inst4_Rdst(DS_Inst4_Rdst),
.DS_Inst4_Src1(DS_Inst4_Src1),
.DS_Inst4_Src2(DS_Inst4_Src2),
.DS_Inst4_Phy(DS_Inst4_Phy),
.DS_Inst4_RSrc1(DS_Inst4_RSrc1),
.DS_Inst4_RSrc2(DS_Inst4_RSrc2),

.IS_Inst4_Src1(),
.IS_Inst4_Src2()
);

Stall_Unit Stall_Unit(
.Issue_Window_Full(/*Issue_window_full*/1'b0),
.Rename_fales(RU_Stall),
.Inst_Ready(InstMem_Ready),

.IF_Stall(IF_Stall),
.ID_Stall(ID_Stall),
.RN_Stall(RN_Stall),
.RT_Stall(RT_Stall),

.Branch((Branch_out&Commit)),


.IF_ID_flush(IF_ID_flush),
.ID_RN_flush(ID_RN_flush),
.RT_flush(RT_flush),
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

output IF_Stall,ID_Stall,RT_Stall,RN_Stall,
output IF_ID_flush,ID_RN_flush,RT_flush,Rename_flush,
output Issue_Window_flush,Function_Unit_flush
);

assign IF_Stall=Issue_Window_Full|Rename_fales;
assign ID_Stall=Issue_Window_Full|Rename_fales;
assign RN_Stall=Issue_Window_Full|Rename_fales;
assign RT_Stall=Issue_Window_Full;
assign Rename_Stall=Issue_Window_Full;

assign IF_ID_flush=Branch;
assign ID_RN_flush=Branch;
assign RT_flush=Branch;
assign Rename_flush=Branch;
assign Issue_Window_flush=Branch;
assign Function_Unit_flush=Branch;
endmodule
