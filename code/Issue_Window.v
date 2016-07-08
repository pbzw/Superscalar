// 2016.06.15
// File         : Issue_Window.v
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
module Issue_Window #(parameter DEPTH = 16)(
input clk,rst,flush, 

/*Inst1 in*/
input Inst1_Src1_Wake,Inst1_Src2_Wake,Inst1_Valid,
input[3:0]Inst1_Function,
input[4:0]Inst1_Operation,
input[31:0]Inst1_imm,Inst1_PC,
input[5:0]Inst1_Phydst,Inst1_Src1,Inst1_Src2,
input[4:0]Inst1_Rdst,

/*Inst2 in*/
input Inst2_Src1_Wake,Inst2_Src2_Wake,Inst2_Valid,
input[3:0]Inst2_Function,
input[4:0]Inst2_Operation,
input[31:0]Inst2_imm,Inst2_PC,
input[5:0]Inst2_Phydst,Inst2_Src1,Inst2_Src2,
input[4:0]Inst2_Rdst,

/*Inst3 in*/
input Inst3_Src1_Wake,Inst3_Src2_Wake,Inst3_Valid,
input[3:0]Inst3_Function,
input[4:0]Inst3_Operation,
input[31:0]Inst3_imm,Inst3_PC,
input[5:0]Inst3_Phydst,Inst3_Src1,Inst3_Src2,
input[4:0]Inst3_Rdst,

/*Inst4 in*/
input Inst4_Src1_Wake,Inst4_Src2_Wake,Inst4_Valid,
input[3:0]Inst4_Function,
input[4:0]Inst4_Operation,
input[31:0]Inst4_imm,Inst4_PC,
input[5:0]Inst4_Phydst,Inst4_Src1,Inst4_Src2,
input[4:0]Inst4_Rdst,

/*Issue Window*/

output Issue_window_full,

/*Commit Unit*/
output Commit,
output [4:0]Com_Rdst,//Use Oringin Rdst
output [5:0]Com_Phy, //Use Rename Rdst
output Com_Branch,
output [31:0]Com_Branch_PC,Com_PC,

/* From Function Unit Wake*/
input ALU0_Commit,
input [5:0]ALU0_Phydst,//TAG For wake
input [3:0]ALU0_Commit_Window,

input ALU1_Commit,
input [5:0]ALU1_Phydst,//TAG For wake
input [3:0]ALU1_Commit_Window,


input DU_Commit,
input [5:0]DU_Phydst,//TAG For wake
input [$clog2(DEPTH)-1:0]DU_Commit_Window,
input DU_busy,

input BU_Commit,BU_branch,
input [5:0]BU_Phydst,//TAG For wake
input [$clog2(DEPTH)-1:0]BU_Commit_Window,
input [31:0]BU_branch_PC,

/*Select For ALU0 Unit*/
output reg[3:0]SL_ALU0_Commit_Window,
output reg SL_ALU0_en,
output reg[5:0]SL_ALU0_Rdst,SL_ALU0_Src1,SL_ALU0_Src2,
output reg[5:0]SL_ALU0_operation,
output reg[31:0]SL_ALU0_imm,

/*Select For ALU1 Unit*/
output reg[3:0]SL_ALU1_Commit_Window,
output reg SL_ALU1_en,
output reg[5:0]SL_ALU1_Rdst,SL_ALU1_Src1,SL_ALU1_Src2,
output reg[5:0]SL_ALU1_operation,
output reg[31:0]SL_ALU1_imm,

/*Select For Branch Unit*/
output reg[$clog2(DEPTH)-1:0]SL_BU_Commit_Window,
output reg SL_BU_en,
output reg[5:0]SL_BU_Rdst,SL_BU_Src1,SL_BU_Src2,
output reg[5:0]SL_BU_operation,
output reg[31:0]SL_BU_imm,SL_BU_PC,

/*Select For Data Unit*/
output reg[$clog2(DEPTH)-1:0]SL_DU_Commit_Window,
output reg SL_DU_en,
output reg[5:0]SL_DU_Rdst,SL_DU_Src1,SL_DU_Src2,
output reg[5:0]SL_DU_operation,
output reg[31:0]SL_DU_imm
);

integer i,j;
/*Inst Count*/
reg [4:0]Inst_Counter;
wire[1:0]write_address;
/*Issue Windown*/
reg [3:0]IW_Function[0:15];
reg [5:0]IW_Operation[0:15];
reg [4:0]IW_Rdst[0:15];
reg [31:0]IW_imm[0:15];
reg [31:0]IW_PC[0:15],IW_Jump_PC[0:15];
reg [5:0]IW_PhyRdst[0:15],IW_Src1[0:15],IW_Src2[0:15];
reg IW_Src1_Wake[0:15],IW_Src2_Wake[0:15],IW_Branch[0:15];
reg IW_Selected[0:15];
reg IW_Can_Commited[0:15];
reg IW_Inst_Valid[0:15];
/**/

assign Issue_window_full=Inst_Counter>4'd12;
assign Commit=1'b0;
up_counter #(.WIDTH (2) ) write_address_count(
.clk(clk),
.rst(rst),
.clr(flush),
.en(Inst1_Valid&(!Issue_window_full)),
.count(write_address)
);

up_counter #(.WIDTH (4)) read_address_count(
.clk(clk),
.rst(rst),
.clr(flush),
.en(Commit),
.count(read_address)
);

always@(posedge clk) begin
	if(rst|flush)
		Inst_Counter<=4'd0;
	else begin
		case({Inst1_Valid,Commit})
		2'b00:Inst_Counter<=Inst_Counter;
		2'b01:Inst_Counter<=Inst_Counter-4'd1;
		2'b10:Inst_Counter<=Inst_Counter+4'd4;
		2'b11:Inst_Counter<=Inst_Counter+4'd3;
		endcase
		end
		
	end
always@(posedge clk) begin
	if(rst|flush)begin
		for(i=0;i<16;i=i+1)begin
			IW_imm[i]         <=32'd0;
			IW_PC[i]          <=32'd0;
			IW_Jump_PC[i]     <=32'd0;
			IW_Operation[i]   <=5'd0;
			IW_PhyRdst[i]     <=6'd0;
			IW_Function[i]    <=4'd0;
			IW_Src1_Wake[i]   <=1'b0;
			IW_Src2_Wake[i]   <=1'b0;
			IW_Selected[i]    <=1'b0;
			IW_Can_Commited[i]<=1'b0;
			IW_Src1[i]        <=6'd0;
			IW_Src2[i]        <=6'd0;
			IW_Rdst[i]			<=5'd0;
			IW_Branch[i]      <=1'b0;
			IW_Inst_Valid[i]  <=1'b0;
			end
		end
	else begin
		if(ALU0_Commit|ALU1_Commit|BU_Commit|DU_Commit)begin
			for(i=0;i<DEPTH;i=i+1)begin
				IW_Src1_Wake[i]<=IW_Src1_Wake[i]|(IW_Src1[i]===ALU0_Phydst)|(IW_Src1[i]===ALU0_Phydst)|(IW_Src1[i]===BU_Phydst)|(IW_Src1[i]===DU_Phydst);
				IW_Src2_Wake[i]<=IW_Src2_Wake[i]|(IW_Src2[i]===ALU0_Phydst)|(IW_Src2[i]===ALU1_Phydst)|(IW_Src2[i]===BU_Phydst)|(IW_Src2[i]===DU_Phydst);
				end
			end
		if(Inst1_Valid&(!Issue_window_full))begin
				//Inst1
				IW_imm[{write_address,2'b00}]         <=Inst1_imm;
				IW_PC[{write_address,2'b00}]          <=Inst1_PC;
				//IW_Jump_PC[{write_address,2'b00}]     <=32'd0;
				IW_Operation[{write_address,2'b00}]   <=Inst1_Operation;
				IW_PhyRdst[{write_address,2'b00}]     <=Inst1_Phydst;
				IW_Function[{write_address,2'b00}]    <=Inst1_Function;
				IW_Src1_Wake[{write_address,2'b00}]   <=Inst1_Src1_Wake;
				IW_Src2_Wake[{write_address,2'b00}]   <=Inst1_Src2_Wake;
				IW_Selected[{write_address,2'b00}]    <=1'b0;
				IW_Can_Commited[{write_address,2'b00}]<=1'b0;
				IW_Src1[{write_address,2'b00}]        <=Inst1_Src1;
				IW_Src2[{write_address,2'b00}]        <=Inst1_Src2;
				IW_Rdst[{write_address,2'b00}]        <=Inst1_Rdst;
				IW_Branch[{write_address,2'b00}]      <=1'b0;
				IW_Inst_Valid[{write_address,2'b00}]  <=Inst1_Valid;
				
				//Inst2
				IW_imm[{write_address,2'b01}]         <=Inst2_imm;
				IW_PC[{write_address,2'b01}]          <=Inst2_PC;
				//IW_Jump_PC[{write_address,2'b01}]     <=32'd0;
				IW_Operation[{write_address,2'b01}]   <=Inst2_Operation;
				IW_PhyRdst[{write_address,2'b01}]     <=Inst2_Phydst;
				IW_Function[{write_address,2'b01}]    <=Inst2_Function;
				IW_Src1_Wake[{write_address,2'b01}]   <=Inst2_Src1_Wake;
				IW_Src2_Wake[{write_address,2'b01}]   <=Inst2_Src2_Wake;
				IW_Selected[{write_address,2'b01}]    <=1'b0;
				IW_Can_Commited[{write_address,2'b01}]<=1'b0;
				IW_Src1[{write_address,2'b01}]        <=Inst2_Src1;
				IW_Src2[{write_address,2'b01}]        <=Inst2_Src2;
				IW_Rdst[{write_address,2'b01}]        <=Inst2_Rdst;
				IW_Branch[{write_address,2'b01}]      <=1'b0;
				IW_Inst_Valid[{write_address,2'b01}]  <=Inst2_Valid;
				
				//Inst3
				IW_imm[{write_address,2'b10}]         <=Inst3_imm;
				IW_PC[{write_address,2'b10}]          <=Inst3_PC;
				//IW_Jump_PC[{write_address,2'b10}]     <=32'd0;
				IW_Operation[{write_address,2'b10}]   <=Inst3_Operation;
				IW_PhyRdst[{write_address,2'b10}]     <=Inst3_Phydst;
				IW_Function[{write_address,2'b10}]    <=Inst3_Function;
				IW_Src1_Wake[{write_address,2'b10}]   <=Inst3_Src1_Wake;
				IW_Src2_Wake[{write_address,2'b10}]   <=Inst3_Src2_Wake;
				IW_Selected[{write_address,2'b10}]    <=1'b0;
				IW_Can_Commited[{write_address,2'b10}]<=1'b0;
				IW_Src1[{write_address,2'b10}]        <=Inst3_Src1;
				IW_Src2[{write_address,2'b10}]        <=Inst3_Src2;
				IW_Rdst[{write_address,2'b10}]        <=Inst3_Rdst;
				IW_Branch[{write_address,2'b10}]      <=1'b0;
				IW_Inst_Valid[{write_address,2'b10}]  <=Inst3_Valid;
				
				//Inst1
				IW_imm[{write_address,2'b11}]         <=Inst4_imm;
				IW_PC[{write_address,2'b11}]          <=Inst4_PC;
				//IW_Jump_PC[{write_address,2'b11}]     <=32'd0;
				IW_Operation[{write_address,2'b11}]   <=Inst4_Operation;
				IW_PhyRdst[{write_address,2'b11}]     <=Inst4_Phydst;
				IW_Function[{write_address,2'b11}]    <=Inst4_Function;
				IW_Src1_Wake[{write_address,2'b11}]   <=Inst4_Src1_Wake;
				IW_Src2_Wake[{write_address,2'b11}]   <=Inst4_Src2_Wake;
				IW_Selected[{write_address,2'b11}]    <=1'b0;
				IW_Can_Commited[{write_address,2'b11}]<=1'b0;
				IW_Src1[{write_address,2'b11}]        <=Inst4_Src1;
				IW_Src2[{write_address,2'b11}]        <=Inst4_Src2;
				IW_Rdst[{write_address,2'b11}]        <=Inst4_Rdst;
				IW_Branch[{write_address,2'b11}]      <=1'b0;
				IW_Inst_Valid[{write_address,2'b11}]  <=Inst4_Valid;
			end
			
			
		end
end




endmodule
