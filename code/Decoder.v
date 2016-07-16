module Decoder(
input inst_en,
input [31:0]Inst1,
input [31:0]Inst2,

output [8:0]Inst1_ALUop,Inst2_ALUop,
output Inst1_RegW,Inst2_RegW,
output Inst1_Instvalid,Inst2_Instvalid,
output [4:0]Inst1_Src1,Inst2_Src1,
output [4:0]Inst1_Src2,Inst2_Src2,
output [4:0]Inst1_Rdst,Inst2_Rdst,
output [31:0]Inst1_Extend_imm,Inst2_Extend_imm
);

Control Control1(
.inst_en(inst_en),
.inst_in(Inst1),
.ALUop(Inst1_ALUop),
.RegW(Inst1_RegW),
.Instvalid(Inst1_Instvalid),
.Rsrc1(Inst1_Src1),
.Rsrc2(Inst1_Src2),
.Rdst(Inst1_Rdst),
.Extend_imm(Inst1_Extend_imm)
);

Control Control2(
.inst_en(inst_en),
.inst_in(Inst2),
.ALUop(Inst2_ALUop),
.RegW(Inst2_RegW),
.Instvalid(Inst2_Instvalid),
.Rsrc1(Inst2_Src1),
.Rsrc2(Inst2_Src2),
.Rdst(Inst2_Rdst),
.Extend_imm(Inst2_Extend_imm)
);



endmodule
