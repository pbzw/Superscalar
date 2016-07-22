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
input clk,rst,flush,Stall,

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

/*Issue Window*/

output Issue_window_full,

/*Commit Unit*/
output Commit_1,
output [5:0]Commit_Phy_1,
output [4:0]Commit_Rdst_1,
output Commit_1_Branch,
output [31:0]Commit_1_Branch_PC,Commit_1_PC,

/*Commit Unit */
output Commit_2,
output [5:0]Commit_Phy_2,
output [4:0]Commit_Rdst_2,
output [31:0]Commit_2_PC,

/* From Function Unit Wake*/
input ALU0_Commit,ALU1_Commit,
input [3:0]WB_ALU0_Commit_Window,WB_ALU1_Commit_Window,
input [5:0]ALU0_Phydst,ALU1_Phydst,//TAG For wake

input DU_Commit,
input [5:0]DU_Phydst,//TAG For wake
input [$clog2(DEPTH)-1:0]WB_DU_Commit_Window,
input DU_busy,

input BU_Commit,WB_BU_branch,
input [5:0]BU_Phydst,//TAG For wake
input [$clog2(DEPTH)-1:0]WB_BU_Commit_Window,
input [31:0]WB_BU_branch_PC,

/*Select For ALU0 Unit*/
output reg[3:0]SL_ALU0_Commit_Window,
output reg SL_ALU0_en,
output reg[5:0]SL_ALU0_Phydst,SL_ALU0_Src1,SL_ALU0_Src2,
output reg[5:0]SL_ALU0_operation,
output reg[31:0]SL_ALU0_imm,

/*Select For ALU1 Unit*/
output reg[3:0]SL_ALU1_Commit_Window,
output reg SL_ALU1_en,
output reg[5:0]SL_ALU1_Phydst,SL_ALU1_Src1,SL_ALU1_Src2,
output reg[5:0]SL_ALU1_operation,
output reg[31:0]SL_ALU1_imm,



/*Select For Branch Unit*/
output reg[$clog2(DEPTH)-1:0]SL_BU_Commit_Window,
output reg SL_BU_en,
output reg[5:0]SL_BU_Phydst,SL_BU_Src1,SL_BU_Src2,
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
wire[2:0]write_address;
reg[3:0]read_address,read_address2;
wire [0:15]Head;
/*Issue Windown*/
reg [3:0]IW_Function[0:15];
reg [5:0]IW_Operation[0:15];
reg [4:0]IW_Rdst[0:15];
reg [31:0]IW_imm[0:15];
reg [31:0]IW_PC[0:15];
reg [5:0]IW_PhyRdst[0:15],IW_Src1[0:15],IW_Src2[0:15];
reg IW_Src1_Wake[0:15],IW_Src2_Wake[0:15],IW_Branch[0:15];
reg IW_Selected[0:15];
reg IW_Inst_Valid[0:15];
reg [31:0]IW_Branch_PC[0:15];
reg IW_Can_Commit[0:15];
/**/

assign Issue_window_full=Inst_Counter>5'd14;
wire [2:0]ALU0_P_E_out,ALU1_P_E_out;
wire [3:0]BU_P_E_out,DU_P_E_out;
wire ALU0_P_E_valid,ALU1_P_E_valid,BU_P_E_valid,DU_P_E_valid;
wire [3:0]ALU0_Take_Window={ALU0_P_E_out,1'b0};
wire [3:0]ALU1_Take_Window={ALU1_P_E_out,1'b1};

up_counter #(.WIDTH (3) ) write_address_count(
.clk(clk),
.rst(rst),
.clr(flush),
.en(Inst1_Valid&(!Issue_window_full)&(!Stall)),
.count(write_address)
);


always@(posedge clk)begin
	if(rst|flush)
		read_address<=4'd0;
	else begin
		case({Commit_1,Commit_2})
		2'b00:read_address<=read_address;
		2'b01:read_address<=read_address;
		2'b10:read_address<=read_address+4'b1;
		2'b11:read_address<=read_address+4'd2;
		endcase
		end
	
end

always@(posedge clk)begin
	if(rst|flush)
		read_address2<=4'd1;
	else begin
		case({Commit_1,Commit_2})
		2'b00:read_address2<=read_address2;
		2'b01:read_address2<=read_address2;
		2'b10:read_address2<=read_address2+4'b1;
		2'b11:read_address2<=read_address2+4'd2;
		endcase
		end
	
end
always@(posedge clk) begin
	if(rst|flush)
		Inst_Counter<=5'd0;
	else begin
		case({(!Stall)&Inst1_Valid,Commit_1,Commit_2})
		3'b000:Inst_Counter<=Inst_Counter;
		3'b010:Inst_Counter<=Inst_Counter-5'd1;
		3'b011:Inst_Counter<=Inst_Counter-5'd2;
		3'b100:Inst_Counter<=Inst_Counter+5'd2;
		3'b110:Inst_Counter<=Inst_Counter+5'd1;
		3'b111:Inst_Counter<=Inst_Counter;
		endcase
		end

	end
always@(posedge clk) begin
	if(rst|flush)begin
		for(i=0;i<16;i=i+1)begin
			IW_imm[i]         <=32'd0;
			IW_PC[i]          <=32'd0;
			IW_Operation[i]   <=5'd0;
			IW_PhyRdst[i]     <=6'd0;
			IW_Function[i]    <=4'd0;
			IW_Src1_Wake[i]   <=1'b0;
			IW_Src2_Wake[i]   <=1'b0;
			IW_Selected[i]    <=1'b0;
			IW_Src1[i]        <=6'd0;
			IW_Src2[i]        <=6'd0;
			IW_Rdst[i]			<=5'd0;
			IW_Inst_Valid[i]  <=1'b0;
			end
		end
	else begin
		if(ALU0_Commit|ALU1_Commit|BU_Commit|DU_Commit) begin
			for(i=0;i<16;i=i+1)begin
				IW_Src1_Wake[i]<=IW_Src1_Wake[i]|(IW_Src1[i]==ALU0_Phydst)|(IW_Src1[i]==ALU1_Phydst)|(IW_Src1[i]==BU_Phydst)|(IW_Src1[i]==DU_Phydst);
				IW_Src2_Wake[i]<=IW_Src2_Wake[i]|(IW_Src2[i]==ALU0_Phydst)|(IW_Src2[i]==ALU1_Phydst)|(IW_Src2[i]==BU_Phydst)|(IW_Src2[i]==DU_Phydst);
				end
			end
		if(Inst1_Valid&(!Issue_window_full)&(!Stall))begin
			//Inst1
			IW_imm[{write_address,1'b0}]        <=Inst1_imm;
			IW_PC[{write_address,1'b0}]          <=Inst1_PC;
			IW_Operation[{write_address,1'b0}]   <=Inst1_Operation;
			IW_PhyRdst[{write_address,1'b0}]     <=Inst1_Phydst;
			IW_Function[{write_address,1'b0}]    <=Inst1_Function;
			IW_Src1_Wake[{write_address,1'b0}]   <=Inst1_Src1_Wake;
			IW_Src2_Wake[{write_address,1'b0}]   <=Inst1_Src2_Wake;
			IW_Selected[{write_address,1'b0}]    <=1'b0;
			IW_Src1[{write_address,1'b0}]        <=Inst1_Src1;
			IW_Src2[{write_address,1'b0}]        <=Inst1_Src2;
			IW_Rdst[{write_address,1'b0}]        <=Inst1_Rdst;
			IW_Inst_Valid[{write_address,1'b0}]  <=Inst1_Valid;
				
			//Inst2
			IW_imm[{write_address,1'b1}]         <=Inst2_imm;
			IW_PC[{write_address,1'b1}]          <=Inst2_PC;
			IW_Operation[{write_address,1'b1}]   <=Inst2_Operation;
			IW_PhyRdst[{write_address,1'b1}]     <=Inst2_Phydst;
			IW_Function[{write_address,1'b1}]    <=Inst2_Function;
			IW_Src1_Wake[{write_address,1'b1}]   <=Inst2_Src1_Wake;
			IW_Src2_Wake[{write_address,1'b1}]   <=Inst2_Src2_Wake;
			IW_Selected[{write_address,1'b1}]    <=1'b0;
			IW_Src1[{write_address,1'b1}]        <=Inst2_Src1;
			IW_Src2[{write_address,1'b1}]        <=Inst2_Src2;
			IW_Rdst[{write_address,1'b1}]        <=Inst2_Rdst;
			IW_Inst_Valid[{write_address,1'b1}]  <=Inst2_Valid;
				
			
			end
		if(ALU0_P_E_valid)begin
			IW_Selected[ALU0_Take_Window]    <=1'b1;
			end
		if(ALU1_P_E_valid)begin
			IW_Selected[ALU1_Take_Window]    <=1'b1;
			end
		if(BU_P_E_valid)begin
			IW_Selected[BU_P_E_out]    <=1'b1;
			end
		if(DU_P_E_valid)begin
			IW_Selected[DU_P_E_out]    <=1'b1;
			end
			
			
		end
end

assign Commit_1=IW_Can_Commit[read_address]&((!IW_Function[read_address][1])|IW_Can_Commit[read_address2]);
assign Commit_Phy_1=IW_PhyRdst[read_address];
assign Commit_Rdst_1=IW_Rdst[read_address];
assign Commit_1_Branch=IW_Branch[read_address]&Commit_1;
assign Commit_1_Branch_PC=IW_Branch_PC[read_address];
assign Commit_1_PC=IW_PC[read_address];
wire   Commit_1_valid=IW_Inst_Valid[read_address];

assign Commit_2=IW_Can_Commit[read_address2]&Commit_1&(!IW_Function[read_address2][1]);
assign Commit_Phy_2=IW_PhyRdst[read_address2];
assign Commit_Rdst_2=IW_Rdst[read_address2];
assign Commit_2_PC=IW_PC[read_address2];
wire   Commit_2_valid=IW_Inst_Valid[read_address2];

always@(posedge clk) begin
	if(rst|flush)begin
		for(i=0;i<16;i=i+1)begin
			IW_Can_Commit[i]<=1'b0;
			IW_Branch[i]    <=1'b0;
			IW_Branch_PC[i] <=32'd0;
			end
		end
	else begin
			case({Commit_1,Commit_2})
				2'b10:begin IW_Can_Commit[read_address]<=1'b0; IW_Branch[read_address]<=1'b0;end
				2'b11:begin IW_Can_Commit[read_address]<=1'b0;IW_Can_Commit[read_address2]<=1'b0;IW_Branch[read_address]<=1'b0; end
				endcase
				//IW_Can_Commit[read_address]<=1'b0;
			if(ALU0_Commit)begin
				IW_Can_Commit[WB_ALU0_Commit_Window]<=1'b1;
				end
			if(ALU1_Commit)begin
				IW_Can_Commit[WB_ALU1_Commit_Window]<=1'b1;
				end
			if(BU_Commit)begin
				IW_Branch[WB_BU_Commit_Window]    <=WB_BU_branch;
				IW_Branch_PC[WB_BU_Commit_Window] <=WB_BU_branch_PC;
				IW_Can_Commit[WB_BU_Commit_Window]<=1'b1;
				end
			if(DU_Commit)begin
				IW_Can_Commit[WB_DU_Commit_Window]<=1'b1;
				end
		end
end



reg [0:15]ALU_Can_Issue;
reg [0:15]BU_Can_Issue;
reg [0:15]Load_Can_Issue;
reg [0:15]Store_Can_Issue;
wire[0:7]Slot_ALU0,Slot_ALU1;

always@(*)begin
	for (j=0;j<16;j=j+1)begin
		ALU_Can_Issue[j]  <=(IW_Src1_Wake[j]&IW_Src2_Wake[j]&(IW_Function[j][0])&(!IW_Selected[j]));
		BU_Can_Issue[j]   <=(IW_Src1_Wake[j]&IW_Src2_Wake[j]&(IW_Function[j][1])&(!IW_Selected[j]));
		Load_Can_Issue[j] <=(IW_Src1_Wake[j]&IW_Src2_Wake[j]&(IW_Function[j][2])&(!IW_Selected[j]));
		Store_Can_Issue[j]<=(IW_Src1_Wake[j]&IW_Src2_Wake[j]&(IW_Function[j][3])&(!IW_Selected[j]));
		end
	end
	
assign Slot_ALU0={ALU_Can_Issue[0],ALU_Can_Issue[2],ALU_Can_Issue[4],ALU_Can_Issue[6],ALU_Can_Issue[8],ALU_Can_Issue[10],ALU_Can_Issue[12],ALU_Can_Issue[14]};
assign Slot_ALU1={ALU_Can_Issue[1],ALU_Can_Issue[3],ALU_Can_Issue[5],ALU_Can_Issue[7],ALU_Can_Issue[9],ALU_Can_Issue[11],ALU_Can_Issue[13],ALU_Can_Issue[15]};


Shift_P_Encoder8 ALU0_P_E(
.Shift_base(read_address[3:1]),
.in(Slot_ALU0),
.out(ALU0_P_E_out),
.valid(ALU0_P_E_valid)
);

Shift_P_Encoder8 ALU1_P_E(
.Shift_base(read_address[3:1]),
.in(Slot_ALU1),
.out(ALU1_P_E_out),
.valid(ALU1_P_E_valid)
);

Shift_P_Encoder16 BU_P_E(
.Shift_base(read_address),
.in(BU_Can_Issue),
.out(BU_P_E_out),
.valid(BU_P_E_valid)
);

Shift_P_LS_Encoder DU_Select_Shift_P_Encoder(
.Shift_base(read_address),
.Load_req(Load_Can_Issue),
.Store_req(Store_Can_Issue),
.Select(DU_P_E_out),
.valid(DU_P_E_valid)
);
reg [3:0]ALU0_select;
reg ALU0_Issue_req;
reg [3:0]ALU1_select;
reg ALU1_Issue_req;
reg [3:0]BU_select;
reg BU_Issue_req;
reg [3:0]DU_select;
reg DU_Issue_req;
always@(posedge clk)begin
	if(rst|flush)begin
		ALU0_select   <=4'd0;
		ALU0_Issue_req<=1'd0;
		ALU1_select   <=4'd0;
		ALU1_Issue_req<=1'd0;
		BU_select     <=4'd0;
		BU_Issue_req  <=1'd0;
		DU_select     <=4'd0;
		DU_Issue_req  <=1'd0;
		end
	else begin
		ALU0_select   <=ALU0_Take_Window;
		ALU0_Issue_req<=ALU0_P_E_valid;
		ALU1_select   <=ALU1_Take_Window;
		ALU1_Issue_req<=ALU1_P_E_valid;
		BU_select     <=BU_P_E_out;
		BU_Issue_req  <=BU_P_E_valid;
		DU_select     <=DU_P_E_out;
		DU_Issue_req  <=DU_P_E_valid;

		end
end

always@(posedge clk)begin
	if(rst|flush|(!ALU0_Issue_req))begin
		SL_ALU0_Commit_Window    <= 4'd0;
		SL_ALU0_operation        <= 5'd0;
		SL_ALU0_imm              <=32'd0;
		SL_ALU0_Phydst           <= 6'd0;
		SL_ALU0_Src1             <= 6'd0;
		SL_ALU0_Src2             <= 6'd0;
		SL_ALU0_en               <= 1'd0;
		end
	else begin
		SL_ALU0_Commit_Window    <=ALU0_select;
		SL_ALU0_operation        <=IW_Operation[ALU0_select];
		SL_ALU0_imm              <=IW_imm[ALU0_select];
		SL_ALU0_Phydst           <=IW_PhyRdst[ALU0_select];
		SL_ALU0_Src1             <=IW_Src1[ALU0_select];
		SL_ALU0_Src2             <=IW_Src2[ALU0_select];
		SL_ALU0_en               <=1'b1;
		end
	end

always@(posedge clk)begin
	if(rst|flush|(!ALU1_Issue_req))begin
		SL_ALU1_Commit_Window    <= 4'd0;
		SL_ALU1_operation        <= 5'd0;
		SL_ALU1_imm              <=32'd0;
		SL_ALU1_Phydst           <= 6'd0;
		SL_ALU1_Src1             <= 6'd0;
		SL_ALU1_Src2             <= 6'd0;
		SL_ALU1_en               <= 1'd0;
		end
	else begin
		SL_ALU1_Commit_Window    <=ALU1_select;
		SL_ALU1_operation        <=IW_Operation[ALU1_select];
		SL_ALU1_imm              <=IW_imm[ALU1_select];
		SL_ALU1_Phydst           <=IW_PhyRdst[ALU1_select];
		SL_ALU1_Src1             <=IW_Src1[ALU1_select];
		SL_ALU1_Src2             <=IW_Src2[ALU1_select];
		SL_ALU1_en               <=1'b1;
		end
	end

always@(posedge clk)begin
	if(rst|flush|(!BU_Issue_req))begin
		SL_BU_Commit_Window    <= 4'd0;
		SL_BU_operation        <= 5'd0;
		SL_BU_imm              <=32'd0;
		SL_BU_Phydst           <= 6'd0;
		SL_BU_Src1             <= 6'd0;
		SL_BU_Src2             <= 6'd0;
		SL_BU_en               <= 1'd0;
		SL_BU_PC               <=32'd0;
		end
	else begin
		SL_BU_Commit_Window    <=BU_select;
		SL_BU_operation        <=IW_Operation[BU_select];
		SL_BU_imm              <=IW_imm[BU_select];
		SL_BU_Phydst           <=IW_PhyRdst[BU_select];
		SL_BU_Src1             <=IW_Src1[BU_select];
		SL_BU_Src2             <=IW_Src2[BU_select];
		SL_BU_en               <=1'b1;
		SL_BU_PC               <=IW_PC[BU_select];
		end
	end	
always@(posedge clk)begin
	if((rst|flush)|(!DU_Issue_req))begin
		SL_DU_Commit_Window    <= 4'd0;
		SL_DU_operation        <= 5'd0;
		SL_DU_imm              <=32'd0;
		SL_DU_Rdst             <= 6'd0;
		SL_DU_Src1             <= 6'd0;
		SL_DU_Src2             <= 6'd0;
		SL_DU_en               <= 1'd0;
		end
	else if(!(SL_DU_en&DU_busy))begin
		SL_DU_Commit_Window    <=DU_select;
		SL_DU_operation        <=IW_Operation[DU_select];
		SL_DU_imm              <=IW_imm[DU_select];
		SL_DU_Rdst             <=IW_PhyRdst[DU_select];
		SL_DU_Src1             <=IW_Src1[DU_select];
		SL_DU_Src2             <=IW_Src2[DU_select];
		SL_DU_en               <=1'b1;
		end
	end
endmodule
