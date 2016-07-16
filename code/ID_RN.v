// 2016.06.21
// File         : ID_RN.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//

module ID_RN(
input clk,rst,stall,flush,
//Inst1
input[8:0]ID_Inst1_ALUop,
input ID_Inst1_RegW,ID_Inst1_Instvalid,
input[4:0]ID_Inst1_Src1,ID_Inst1_Src2,ID_Inst1_Rdst,
input[31:0]ID_Inst1_Extend_imm,ID_Inst1_PC,
 
output reg[8:0] RN_Inst1_ALUop,
output reg RN_Inst1_RegW,RN_Inst1_Instvalid,
output reg[4:0]RN_Inst1_Src1,RN_Inst1_Src2,RN_Inst1_Rdst,
output reg[31:0]RN_Inst1_Extend_imm,RN_Inst1_PC,
//Inst2
input[8:0]ID_Inst2_ALUop,
input ID_Inst2_RegW,ID_Inst2_Instvalid,
input[4:0]ID_Inst2_Src1,ID_Inst2_Src2,ID_Inst2_Rdst,
input[31:0]ID_Inst2_Extend_imm,
 
output reg[8:0] RN_Inst2_ALUop,
output reg RN_Inst2_RegW,RN_Inst2_Instvalid,
output reg[4:0]RN_Inst2_Src1,RN_Inst2_Src2,RN_Inst2_Rdst,
output reg[31:0]RN_Inst2_Extend_imm
);

always@(posedge clk)begin
	if(rst|flush)begin
		RN_Inst1_ALUop       <= 9'd0;
		RN_Inst1_RegW        <= 1'd0;
		RN_Inst1_Instvalid   <= 1'd0;
		RN_Inst1_Src1        <= 5'd0;
		RN_Inst1_Src2        <= 5'd0;
		RN_Inst1_Rdst        <= 5'd0;
		RN_Inst1_Extend_imm  <=32'd0;
		RN_Inst1_PC          <=32'd0;
		end
	else if(!stall)begin  
		RN_Inst1_ALUop       <=ID_Inst1_ALUop;
		RN_Inst1_RegW        <=ID_Inst1_RegW;
		RN_Inst1_Instvalid   <=ID_Inst1_Instvalid;
		RN_Inst1_Src1        <=ID_Inst1_Src1;
		RN_Inst1_Src2        <=ID_Inst1_Src2;
		RN_Inst1_Rdst        <=ID_Inst1_Rdst;
		RN_Inst1_Extend_imm  <=ID_Inst1_Extend_imm; 
		RN_Inst1_PC          <=ID_Inst1_PC;
		end
	end

always@(posedge clk)begin
	if(rst|flush)begin
		RN_Inst2_ALUop       <= 9'd0;
		RN_Inst2_RegW        <= 1'd0;
		RN_Inst2_Instvalid   <= 1'd0;
		RN_Inst2_Src1        <= 5'd0;
		RN_Inst2_Src2        <= 5'd0;
		RN_Inst2_Rdst        <= 5'd0;
		RN_Inst2_Extend_imm  <=32'd0;
		end
	else if(!stall)begin  
		RN_Inst2_ALUop       <=ID_Inst2_ALUop;
		RN_Inst2_RegW        <=ID_Inst2_RegW;
		RN_Inst2_Instvalid   <=ID_Inst2_Instvalid;
		RN_Inst2_Src1        <=ID_Inst2_Src1;
		RN_Inst2_Src2        <=ID_Inst2_Src2;
		RN_Inst2_Rdst        <=ID_Inst2_Rdst;
		RN_Inst2_Extend_imm  <=ID_Inst2_Extend_imm; 
		end
	end	

endmodule
