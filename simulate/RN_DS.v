module RN_DS(
input clk,
input flush,
input rst,
input Stall,
input [31:0]RN_Inst_PC,
output reg[31:0]DS_Inst_PC,
//Inst1
input [8:0]RN_Inst1_ALUop,
input [4:0]RN_Inst1_Src1,RN_Inst1_Src2,RN_Inst1_Rdst,
input [5:0]RE_Inst1_RSrc1,RE_Inst1_RSrc2,RE_Inst1_Phydst,
input [31:0]RN_Inst1_imm,

output reg[8:0]DS_Inst1_ALUop,
output reg[4:0]DS_Inst1_Src1,DS_Inst1_Src2,DS_Inst1_Rdst,
output reg[5:0]DS_Inst1_RSrc1,DS_Inst1_RSrc2,DS_Inst1_Phydst,
output reg[31:0]DS_Inst1_imm,
//Inst2
input [8:0]RN_Inst2_ALUop,
input [4:0]RN_Inst2_Src1,RN_Inst2_Src2,RN_Inst2_Rdst,
input [5:0]RE_Inst2_RSrc1,RE_Inst2_RSrc2,RE_Inst2_Phydst,
input [31:0]RN_Inst2_imm,

output reg[8:0]DS_Inst2_ALUop,
output reg[4:0]DS_Inst2_Src1,DS_Inst2_Src2,DS_Inst2_Rdst,
output reg[5:0]DS_Inst2_RSrc1,DS_Inst2_RSrc2,DS_Inst2_Phydst,
output reg[31:0]DS_Inst2_imm,

//Inst3
input [8:0]RN_Inst3_ALUop,
input [4:0]RN_Inst3_Src1,RN_Inst3_Src2,RN_Inst3_Rdst,
input [5:0]RE_Inst3_RSrc1,RE_Inst3_RSrc2,RE_Inst3_Phydst,
input [31:0]RN_Inst3_imm,

output reg[8:0]DS_Inst3_ALUop,
output reg[4:0]DS_Inst3_Src1,DS_Inst3_Src2,DS_Inst3_Rdst,
output reg[5:0]DS_Inst3_RSrc1,DS_Inst3_RSrc2,DS_Inst3_Phydst,
output reg[31:0]DS_Inst3_imm,

//Inst4
input [8:0]RN_Inst4_ALUop,
input [4:0]RN_Inst4_Src1,RN_Inst4_Src2,RN_Inst4_Rdst,
input [5:0]RE_Inst4_RSrc1,RE_Inst4_RSrc2,RE_Inst4_Phydst,
input [31:0]RN_Inst4_imm,

output reg[8:0]DS_Inst4_ALUop,
output reg[4:0]DS_Inst4_Src1,DS_Inst4_Src2,DS_Inst4_Rdst,
output reg[5:0]DS_Inst4_RSrc1,DS_Inst4_RSrc2,DS_Inst4_Phydst,
output reg[31:0]DS_Inst4_imm

);
always@(posedge clk)begin
	if(rst|flush)
		DS_Inst_PC<=32'd0;
	else
		DS_Inst_PC<=RN_Inst_PC;
end



always@(posedge clk) begin
	if(rst|flush)begin
		DS_Inst1_ALUop <= 9'd0;
		DS_Inst1_Src1  <= 5'd0;
		DS_Inst1_Src2  <= 5'd0;
		DS_Inst1_Rdst  <= 5'd0;
		DS_Inst1_RSrc1 <= 6'd0;
		DS_Inst1_RSrc2 <= 6'd0;
		DS_Inst1_Phydst<= 6'd0;
		DS_Inst1_imm   <=32'd0;
		end
	else if(!Stall) begin
		DS_Inst1_ALUop <= RN_Inst1_ALUop;
		DS_Inst1_Src1  <= RN_Inst1_Src1;
		DS_Inst1_Src2  <= RN_Inst1_Src2;
		DS_Inst1_Rdst  <= RN_Inst1_Rdst;
		DS_Inst1_RSrc1 <= RE_Inst1_RSrc1;
		DS_Inst1_RSrc2 <= RE_Inst1_RSrc2;
		DS_Inst1_Phydst<= RE_Inst1_Phydst;
		DS_Inst1_imm   <= RN_Inst1_imm;
		end
end


always@(posedge clk) begin
	if(rst|flush)begin
		DS_Inst2_ALUop <= 9'd0;
		DS_Inst2_Src1  <= 5'd0;
		DS_Inst2_Src2  <= 5'd0;
		DS_Inst2_Rdst  <= 5'd0;
		DS_Inst2_RSrc1 <= 6'd0;
		DS_Inst2_RSrc2 <= 6'd0;
		DS_Inst2_Phydst<= 6'd0;
		DS_Inst2_imm   <=32'd0;
		end
	else if(!Stall) begin
		DS_Inst2_ALUop <= RN_Inst2_ALUop;
		DS_Inst2_Src1  <= RN_Inst2_Src1;
		DS_Inst2_Src2  <= RN_Inst2_Src2;
		DS_Inst2_Rdst  <= RN_Inst2_Rdst;
		DS_Inst2_RSrc1 <= RE_Inst2_RSrc1;
		DS_Inst2_RSrc2 <= RE_Inst2_RSrc2;
		DS_Inst2_Phydst<= RE_Inst2_Phydst;
		DS_Inst2_imm   <= RN_Inst2_imm;
		end
end

endmodule
