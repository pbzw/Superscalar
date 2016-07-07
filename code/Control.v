// 2016.06.21
// File         : Control.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//

`include "define.v"

module Control(
input inst_en,
input [`data_lentgh-1:0]inst_in,
output reg[8:0] ALUop,
output RegW,Instvalid,
output [4:0]Rsrc1,Rsrc2,Rdst,
output [31:0]Extend_imm
);
wire [31:0]Sign_imm;
wire [5:0] OpCode = inst_in[31:26];

wire [5:0] Funct = inst_in[5:0];
wire [15:0]Immediate = inst_in[15:0];
wire [4:0] Rs =inst_in[25:21];
wire [4:0] Rt =inst_in[20:16];
wire SignExtend = (OpCode[5:2] != 4'b0011);
wire Dstselect,Itype;
wire Link;
wire J_Extend;
wire B_inst;
wire Jalr;
wire [4:0] Rd = inst_in[15:11];

reg [7:0]DataPath;

	assign Extend_imm=J_Extend? {6'd0,inst_in[25:0]}:Sign_imm;
	assign Sign_imm=SignExtend?{{16{Immediate[15]}},Immediate}:{16'h0000,Immediate};
	assign Rsrc1=Rs;
	assign Rsrc2=Link?5'd31:Itype?5'd0:Rt;
	assign Rdst=Link?5'd31:B_inst?5'd0:Dstselect?Rd:Rt;

always@(*)begin
	case(OpCode)
		`Op_Ori :ALUop<={`ALU,`AluOp_Ori };
		`Op_Andi:ALUop<={`ALU,`AluOp_Andi};
		`Op_Addi:ALUop<={`ALU,`AluOp_Addi};
		`Op_Xori:ALUop<={`ALU,`AluOp_Xori};
		`Op_Lui :ALUop<={`ALU,`AluOp_Lui };
		`Op_J   :ALUop<={`BU,`BUOp_J };
		`Op_Jal :ALUop<={`BU,`BUOp_Jal };
		`Op_Beq :ALUop<={`BU,`BUOp_Beq };
		`Op_Bgtz:ALUop<={`BU,`BUOp_Bgtz };
		`Op_Blez:ALUop<={`BU,`BUOp_Blez };
		`Op_Bne :ALUop<={`BU,`BUOp_Bne };
		`Op_Lb  :ALUop<={`DUL,`DUOp_Lb };
		`Op_Lbu :ALUop<={`DUL,`DUOp_Lbu};
		`Op_Lh  :ALUop<={`DUL,`DUOp_Lh };
		`Op_Lhu :ALUop<={`DUL,`DUOp_Lhu };
		`Op_Lw  :ALUop<={`DUL,`DUOp_Lw };
		`Op_Sb  :ALUop<={`DUS,`DUOp_Sb };
		`Op_Sh  :ALUop<={`DUS,`DUOp_Sh };
		`Op_Sw  :ALUop<={`DUS,`DUOp_Sw };
		`Op_Type_Regimm:begin
			case(Rt)
				`OpRt_Bltz  :ALUop<={`BU,`BUOp_Bltz  };
				`OpRt_Bltzal:ALUop<={`BU,`BUOp_Bltzal};
				`OpRt_Bgez  :ALUop<={`BU,`BUOp_Bgez  };
				`OpRt_Bgezal:ALUop<={`BU,`BUOp_Bgezal};
				default        : ALUop<=9'd0;
			endcase
			end
		`Op_Type_R:begin
			case (Funct)
				`Funct_Add     : ALUop<={`ALU,`AluOp_Add};
				`Funct_Sub     : ALUop<={`ALU,`AluOp_Sub};
				`Funct_Nor     : ALUop<={`ALU,`AluOp_Nor};
				`Funct_Or      : ALUop<={`ALU,`AluOp_Or};
				`Funct_And     : ALUop<={`ALU,`AluOp_And};
				`Funct_Xor     : ALUop<={`ALU,`AluOp_Xor};
				`Funct_Jr      : ALUop<={`BU,`BUOp_Jr };
				`Funct_Jalr    : ALUop<={`BU,`BUOp_Jalr };
				`Funct_Sll     : ALUop<={`ALU,`AluOp_Sll};
				`Funct_Srl     : ALUop<={`ALU,`AluOp_Srl};
				default        : ALUop<=9'd0;
			endcase
			end
		default:ALUop=9'd0;
	endcase
end

/*Dstselect_RegW*/
	assign Jalr     =DataPath[7];
	assign B_inst   =DataPath[6];
	assign J_Extend =DataPath[5];
	assign Link     =DataPath[4];
	assign Instvalid=DataPath[3]&inst_en;
	assign Itype    =DataPath[2];
	assign Dstselect=DataPath[1];
	assign RegW     =DataPath[0];

always@(*)begin
	case(OpCode)
		`Op_Ori :DataPath<=`Dp_Ori;
		`Op_Andi:DataPath<=`Dp_Andi;
		`Op_Addi:DataPath<=`Dp_Addi;
		`Op_Xori:DataPath<=`Dp_Xori;
		`Op_Lui :DataPath<=`Dp_Lui;
		`Op_J   :DataPath<=`Dp_J;
		`Op_Jal :DataPath<=`Dp_Jal;
		`Op_Beq :DataPath<=`Dp_Beq;
		`Op_Bgtz:DataPath<=`Dp_Bgtz;
		`Op_Blez:DataPath<=`Dp_Blez;
		`Op_Bne :DataPath<=`Dp_Bne;
		`Op_Lb  :DataPath<=`Dp_Lb ;
		`Op_Lbu :DataPath<=`Dp_Lbu;
		`Op_Lh  :DataPath<=`Dp_Lh ;
		`Op_Lhu :DataPath<=`Dp_Lhu ;
		`Op_Lw  :DataPath<=`Dp_Lw ;
		`Op_Sb  :DataPath<=`Dp_Sb ;
		`Op_Sh  :DataPath<=`Dp_Sh ;
		`Op_Sw  :DataPath<=`Dp_Sw ;
		`Op_Type_Regimm:begin
			case(Rt)
				`OpRt_Bltz  :DataPath<=`Dp_Bltz;
				`OpRt_Bltzal:DataPath<=`Dp_Bltzal;
				`OpRt_Bgez  :DataPath<=`Dp_Bgez;
				`OpRt_Bgezal:DataPath<=`Dp_Bgezal;
				default     : DataPath<=6'd0;
			endcase
			end
		`Op_Type_R  :begin
			case (Funct)
				`Funct_Add     : DataPath<=`Dp_Add;
				`Funct_Sub     : DataPath<=`Dp_Sub;
				`Funct_Nor     : DataPath<=`Dp_Nor;
				`Funct_Or      : DataPath<=`Dp_Or;
				`Funct_And     : DataPath<=`Dp_And;
				`Funct_Xor     : DataPath<=`Dp_Xor;
				`Funct_Jr      : DataPath<=`Dp_Jr;
				`Funct_Jalr    : DataPath<=`Dp_Jalr;
				`Funct_Sll     : DataPath<=`Dp_Sll ;
				`Funct_Srl     : DataPath<=`Dp_Srl;
				default : DataPath<=6'd0;
			endcase
			end
		default:DataPath=6'b000000;
	endcase
end

endmodule
