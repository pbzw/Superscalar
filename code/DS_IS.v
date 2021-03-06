module DS_IS(
input clk,
input flush,
input rst,
input Stall,

input[31:0]DS_Inst_PC,

//Inst1
input DS_Inst1_Valid,
input[8:0]DS_Inst1_ALUop,
input[4:0]DS_Inst1_Rdst,
input[5:0]DS_Inst1_RSrc1,DS_Inst1_RSrc2,DS_Inst1_Phydst,
input[31:0]DS_Inst1_imm,

output reg IS_Inst1_Valid,
output reg[8:0]IS_Inst1_ALUop,
output reg[4:0]IS_Inst1_Rdst,
output reg[5:0]IS_Inst1_RSrc1,IS_Inst1_RSrc2,IS_Inst1_Phydst,
output reg[31:0]IS_Inst1_imm,IS_Inst1_PC,

//Inst2
input DS_Inst2_Valid,
input[8:0]DS_Inst2_ALUop,
input[4:0]DS_Inst2_Rdst,
input[5:0]DS_Inst2_RSrc1,DS_Inst2_RSrc2,DS_Inst2_Phydst,
input[31:0]DS_Inst2_imm,

output reg IS_Inst2_Valid,
output reg[8:0]IS_Inst2_ALUop,
output reg[4:0]IS_Inst2_Rdst,
output reg[5:0]IS_Inst2_RSrc1,IS_Inst2_RSrc2,IS_Inst2_Phydst,
output reg[31:0]IS_Inst2_imm,IS_Inst2_PC
);

always@(posedge clk) begin
	if(rst|flush)begin
		IS_Inst1_ALUop <=8'd0;
		IS_Inst1_Rdst  <=5'd0;
		IS_Inst1_RSrc1 <=6'd0;
		IS_Inst1_RSrc2 <=6'd0;
		IS_Inst1_Phydst<=6'd0;
		IS_Inst1_imm   <=32'd0;
		IS_Inst1_PC    <=32'd0;
		IS_Inst1_Valid <=1'b0;
		end
	else if(!Stall)begin
		IS_Inst1_ALUop <=DS_Inst1_ALUop;
		IS_Inst1_Rdst  <=DS_Inst1_Rdst;
		IS_Inst1_RSrc1 <=DS_Inst1_RSrc1;
		IS_Inst1_RSrc2 <=DS_Inst1_RSrc2;
		IS_Inst1_Phydst<=DS_Inst1_Phydst;
		IS_Inst1_imm   <=DS_Inst1_imm;
		IS_Inst1_PC    <=DS_Inst_PC;
		IS_Inst1_Valid <=DS_Inst1_Valid;
		end
	end

always@(posedge clk) begin
	if(rst|flush)begin
		IS_Inst2_ALUop <=8'd0;
		IS_Inst2_Rdst  <=5'd0;
		IS_Inst2_RSrc1 <=6'd0;
		IS_Inst2_RSrc2 <=6'd0;
		IS_Inst2_Phydst<=6'd0;
		IS_Inst2_imm   <=32'd0;
		IS_Inst2_PC    <=32'd0;
		IS_Inst2_Valid <=1'b0;
		end
	else if(!Stall)begin
		IS_Inst2_ALUop <=DS_Inst2_ALUop;
		IS_Inst2_Rdst  <=DS_Inst2_Rdst;
		IS_Inst2_RSrc1 <=DS_Inst2_RSrc1;
		IS_Inst2_RSrc2 <=DS_Inst2_RSrc2;
		IS_Inst2_Phydst<=DS_Inst2_Phydst;
		IS_Inst2_imm   <=DS_Inst2_imm;
		IS_Inst2_PC    <=DS_Inst_PC+32'd4;
		IS_Inst2_Valid <=DS_Inst2_Valid;
		end
	end
	


endmodule
