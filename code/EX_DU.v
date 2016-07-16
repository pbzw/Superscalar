// 2016.06.15
// File         : EX_DU.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: 
//  
//
module EX_DU(

 input clk,rst,flush,
 input [5:0]EX_Operation,
 input [31:0]EX_imm,EX_Src1,EX_Src2,
 input [5:0]EX_PhyRdst,
 input [3:0]EX_Commit_window,
 input EX_en,
 
 /*to memory*/
 output reg[3:0]Memory_sel,
 output reg[31:0]Memory_Address,
 output reg[31:0]Memory_Write_Data,
 output reg Memory_RW,
 output Memory_access,
 /*from memory*/
 input [31:0]Memory_Read_Data,
 input Memory_Ready,
 /**/
 output Unit_busy,
 output reg[31:0]WB_data,
 output reg [3:0]WB_Commit_window,
 output reg [5:0]WB_PhyRdst,
 output WB_Write_Phy,
 output WB_valid
 );
wire[31:0]Address;
wire RW,Signed_Extend;
wire[3:0]Sel;

reg [31:0]imm,Src1,Src2;
reg [31:0]PC_plus4,PC_plus8;
reg [5:0]PhyRdst,Operation;
reg en;
reg [3:0]Commit_window;

reg Memory_Signed_Extend;
reg [31:0]Address_p1,Data_p1;
reg [5:0]PhyRdst_p1;
reg [3:0]Commit_window_p1,Sel_p1;
reg en_p1,RW_p1,Signed_Extend_p1;
reg state,nstate;
parameter idle=1'b0,busy=1'b1;
wire Unit_stall=Unit_busy;

assign Unit_busy=(state==busy);

always@(posedge clk)begin
	if(rst|flush)begin
		imm              <=32'd0;
		Src1             <=32'd0;
		Src2             <=32'd0;
		Commit_window    <= 4'd0;
		Operation        <= 5'd0;
		PhyRdst          <= 5'd0;
		en               <= 1'b0;
		end
	else if((!Unit_stall)) begin
		imm              <=EX_imm;
		Src1             <=EX_Src1;
		Src2             <=EX_Src2;
		Commit_window    <=EX_Commit_window;
		Operation        <=EX_Operation;
		PhyRdst          <=EX_PhyRdst ;
		en               <=EX_en;
		end
end

DU DU(
	.Src1(Src1),
	.Src2(Src2),
	.ime(imm),
	.Operation(Operation),
	
   .Address(Address),
   .RW(RW),
	.Signed_Extend(Signed_Extend),
   .Sel(Sel)
);


always@(posedge clk ) begin
	if(rst|flush)
		state<=idle;
	else
		state<=nstate;
end

always@(*)begin
	case(state)
		idle:begin
			if(en)
			nstate=busy;
			else
			nstate=idle;
			end
		busy:begin
			if(Memory_Ready)
			nstate=idle;
			else
			nstate=busy;
			end
	endcase
end

 assign Memory_access=(state==busy);

 always@(posedge clk)begin
	if(rst|flush) begin
		Memory_Address<=32'd0;
		Memory_sel<=4'd0;
		Memory_Write_Data=32'd0;
		Memory_RW<=1'd0;
		Memory_Signed_Extend<=1'b0;
		end
	else if(!Unit_busy)begin
		Memory_Address<=Address;
		Memory_sel<=Sel;
		Memory_Write_Data=Src2;
		Memory_RW<=RW;
		Memory_Signed_Extend<=Signed_Extend;
		end
 end
 

assign WB_valid=(state==busy)&Memory_Ready;
assign WB_Write_Phy=(state==busy)&Memory_Ready&(!Memory_RW);
always@(posedge clk)begin
	if(rst|flush)begin
		WB_Commit_window <=4'd0;
		WB_PhyRdst       <=5'd0;
		end
	else if(!Unit_busy) begin
		WB_Commit_window <=Commit_window;
		WB_PhyRdst       <=PhyRdst;
		end
end



always@(*)begin
	case(Memory_sel)
		4'b0001:WB_data<=Memory_Signed_Extend?{{24{Memory_Read_Data[7]}},Memory_Read_Data[7:0]}:{24'b0,Memory_Read_Data[7:0]};
		4'b0011:WB_data<=Memory_Signed_Extend?{{16{Memory_Read_Data[15]}},Memory_Read_Data[15:0]}:{16'b0,Memory_Read_Data[15:0]};
		default:WB_data<=Memory_Read_Data;
	endcase
end

endmodule