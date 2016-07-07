// 2016.06.26
// File         : define.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description:
//  
//

`define data_lentgh 32

`define clk_trigger_edge posedge

`define ALU  4'd1
`define BU   4'd2
`define DUL  4'd4
`define DUS  4'd8

/* Op Code Categories */
`define Op_Type_R       6'b00_0000  // Standard R-Type instructions
`define Op_Type_R2      6'b01_1100  // Extended R-Like instructions
`define Op_Type_Regimm  6'b00_0001  // Branch extended instructions
`define Op_Type_CP0     6'b01_0000  // Coprocessor 0 instructions
// --------------------------------------
`define Op_Add      `Op_Type_R
`define Op_Addi     6'b00_1000
`define Op_Addiu    6'b00_1001
`define Op_Addu     `Op_Type_R
`define Op_And      `Op_Type_R
`define Op_Andi     6'b00_1100
`define Op_Beq      6'b00_0100
`define Op_Bgez     `Op_Type_BI
`define Op_Bgezal   `Op_Type_BI
`define Op_Bgtz     6'b00_0111
`define Op_Blez     6'b00_0110
`define Op_Bltz     `Op_Type_BI
`define Op_Bltzal   `Op_Type_BI
`define Op_Bne      6'b00_0101
`define Op_Break    `Op_Type_R
`define Op_Clo      `Op_Type_R2
`define Op_Clz      `Op_Type_R2
`define Op_Div      `Op_Type_R
`define Op_Divu     `Op_Type_R
`define Op_Eret     `Op_Type_CP0
`define Op_J        6'b00_0010
`define Op_Jal      6'b00_0011
`define Op_Jalr     `Op_Type_R
`define Op_Jr       `Op_Type_R
`define Op_Lb       6'b10_0000
`define Op_Lbu      6'b10_0100
`define Op_Lh       6'b10_0001
`define Op_Lhu      6'b10_0101
`define Op_Ll       6'b11_0000
`define Op_Lui      6'b00_1111
`define Op_Lw       6'b10_0011
`define Op_Lwl      6'b10_0010
`define Op_Lwr      6'b10_0110
`define Op_Madd     `Op_Type_R2
`define Op_Maddu    `Op_Type_R2
`define Op_Mfc0     `Op_Type_CP0
`define Op_Mfhi     `Op_Type_R
`define Op_Mflo     `Op_Type_R
`define Op_Movn     `Op_Type_R
`define Op_Movz     `Op_Type_R
`define Op_Msub     `Op_Type_R2
`define Op_Msubu    `Op_Type_R2
`define Op_Mtc0     `Op_Type_CP0
`define Op_Mthi     `Op_Type_R
`define Op_Mtlo     `Op_Type_R
`define Op_Mul      `Op_Type_R2
`define Op_Mult     `Op_Type_R
`define Op_Multu    `Op_Type_R
`define Op_Nor      `Op_Type_R
`define Op_Or       `Op_Type_R
`define Op_Ori      6'b00_1101
`define Op_Pref     6'b11_0011  // Prefetch does nothing in this implementation.
`define Op_Sb       6'b10_1000
`define Op_Sc       6'b11_1000
`define Op_Sh       6'b10_1001
`define Op_Sll      `Op_Type_R
`define Op_Sllv     `Op_Type_R
`define Op_Slt      `Op_Type_R
`define Op_Slti     6'b00_1010
`define Op_Sltiu    6'b00_1011
`define Op_Sltu     `Op_Type_R
`define Op_Sra      `Op_Type_R
`define Op_Srav     `Op_Type_R
`define Op_Srl      `Op_Type_R
`define Op_Srlv     `Op_Type_R
`define Op_Sub      `Op_Type_R
`define Op_Subu     `Op_Type_R
`define Op_Sw       6'b10_1011
`define Op_Swl      6'b10_1010
`define Op_Swr      6'b10_1110
`define Op_Syscall  `Op_Type_R
`define Op_Teq      `Op_Type_R
`define Op_Teqi     `Op_Type_BI
`define Op_Tge      `Op_Type_R
`define Op_Tgei     `Op_Type_BI
`define Op_Tgeiu    `Op_Type_BI
`define Op_Tgeu     `Op_Type_R
`define Op_Tlt      `Op_Type_R
`define Op_Tlti     `Op_Type_BI
`define Op_Tltiu    `Op_Type_BI
`define Op_Tltu     `Op_Type_R
`define Op_Tne      `Op_Type_R
`define Op_Tnei     `Op_Type_BI
`define Op_Xor      `Op_Type_R
`define Op_Xori     6'b00_1110

/* Function Codes for R-Type Op Codes */
`define Funct_Add     6'b10_0000
`define Funct_Addu    6'b10_0001
`define Funct_And     6'b10_0100
`define Funct_Break   6'b00_1101
`define Funct_Div     6'b01_1010
`define Funct_Divu    6'b01_1011
`define Funct_Jr      6'b00_1000
`define Funct_Jalr    6'b00_1001
`define Funct_Madd    6'b00_0000
`define Funct_Maddu   6'b00_0001
`define Funct_Mfhi    6'b01_0000
`define Funct_Mflo    6'b01_0010
`define Funct_Movn    6'b00_1011
`define Funct_Movz    6'b00_1010
`define Funct_Msub    6'b00_0100    // same as Sllv
`define Funct_Msubu   6'b00_0101
`define Funct_Mthi    6'b01_0001
`define Funct_Mtlo    6'b01_0011
`define Funct_Mul     6'b00_0010    // same as Srl
`define Funct_Mult    6'b01_1000
`define Funct_Multu   6'b01_1001
`define Funct_Nor     6'b10_0111
`define Funct_Or      6'b10_0101
`define Funct_Sll     6'b00_0000
`define Funct_Sllv    6'b00_0100
`define Funct_Slt     6'b10_1010
`define Funct_Sltu    6'b10_1011
`define Funct_Sra     6'b00_0011
`define Funct_Srav    6'b00_0111
`define Funct_Srl     6'b00_0010
`define Funct_Srlv    6'b00_0110
`define Funct_Sub     6'b10_0010
`define Funct_Subu    6'b10_0011
`define Funct_Syscall 6'b00_1100
`define Funct_Teq     6'b11_0100
`define Funct_Tge     6'b11_0000
`define Funct_Tgeu    6'b11_0001
`define Funct_Tlt     6'b11_0010
`define Funct_Tltu    6'b11_0011
`define Funct_Tne     6'b11_0110
`define Funct_Xor     6'b10_0110


/* Op Code Rt fields for Branches */
`define OpRt_Bgez   5'b00001
`define OpRt_Bgezal 5'b10001
`define OpRt_Bltz   5'b00000
`define OpRt_Bltzal 5'b10000

/* Data path */
//Jalr     =DataPath[7];
//B_inst   =DataPath[6];
//J_Extend =Datapath[5];
//Link     =Datapath[4];
//Instvalid=DataPath[3];
//Itype    =DataPath[2];
//Dstselect=DataPath[1];
//RegW     =DataPath[0];

`define Dp_Ori   8'b00001101
`define Dp_Andi  8'b00001101
`define Dp_Addi  8'b00001101
`define Dp_Xori  8'b00001101
`define Dp_Lui   8'b00001101
`define Dp_Add   8'b00001011
`define Dp_Sub   8'b00001011
`define Dp_Nor   8'b00001011
`define Dp_Or    8'b00001011
`define Dp_And   8'b00001011
`define Dp_Xor   8'b00001011
`define Dp_Sll   8'b00001011
`define Dp_Srl   8'b00001011


`define Dp_J      8'b01101000
`define Dp_Jr     8'b01101000
`define Dp_Jal    8'b00111001
`define Dp_Jalr   8'b10101011
`define Dp_Beq    8'b01001000
`define Dp_Bgtz   8'b01001000
`define Dp_Blez   8'b01001000
`define Dp_Bne    8'b01001000
`define Dp_Bltz   8'b01001000
`define Dp_Bltzal 8'b00011001
`define Dp_Bgez   8'b01001000
`define Dp_Bgezal 8'b00011001

`define Dp_Lb     8'b00001101
`define Dp_Lbu    8'b00001101
`define Dp_Lh     8'b00001101
`define Dp_Lhu    8'b00001101
`define Dp_Lw     8'b00001101
`define Dp_Sb     8'b01001000
`define Dp_Sh     8'b01001000
`define Dp_Sw     8'b01001000

/* ALU Operations */
`define AluOp_Ori  5'd0
`define AluOp_Andi 5'd1
`define AluOp_Add  5'd2
`define AluOp_Xori 5'd3
`define AluOp_Addi 5'd4
`define AluOp_Sub  5'd5
`define AluOp_Lui  5'd6
`define AluOp_Nor  5'd7
`define AluOp_Or   5'd8
`define AluOp_Xor  5'd9
`define AluOp_And  5'd10
`define AluOp_Sll  5'd11
`define AluOp_Srl  5'd12
`define ALUOp_Clo  5'd11
`define ALUOp_Clz  5'd12

/* BU Operations */

`define BUOp_J         5'd01
`define BUOp_Jal       5'd02
`define BUOp_Beq       5'd03
`define BUOp_Bgtz      5'd04
`define BUOp_Blez      5'd05
`define BUOp_Bne       5'd06
`define BUOp_Bltz      5'd07
`define BUOp_Bltzal    5'd08
`define BUOp_Bgez      5'd09
`define BUOp_Bgezal    5'd10
`define BUOp_Jr        5'd11
`define BUOp_Jalr      5'd12


/* DU Operations */

`define DUOp_Lb        5'd01
`define DUOp_Lbu       5'd02
`define DUOp_Lh        5'd03
`define DUOp_Lhu       5'd04
`define DUOp_Lw        5'd05
`define DUOp_Sb        5'd06
`define DUOp_Sh        5'd07
`define DUOp_Sw        5'd08