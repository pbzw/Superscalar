`timescale 1ns/100ps
`include "define.v"

`define commit_signal Processor.Issue_Window.Commit_1
`define commit_temp Processor.Register_Rename.Commit_Mapping
`define RM_PC Processor.Commit_1_Branch_PC
`define INST_ROM "./sobel.txt"
module MIPS_RUN_tb;

	reg clk;
	reg rst;
	reg InstMem_Ready;
	wire InstMem_Read;
	wire[`data_lentgh-1:0] InstMem_Address;
	reg [`data_lentgh-1:0] inst_mem[0:1023];
	reg [`data_lentgh-1:0] inst1_in,inst2_in;
	reg [`data_lentgh-1:0] Register[0:31];
	reg [7:0]RM_DataMemory[0:2047];
	initial	$readmemh (`INST_ROM, inst_mem);
	wire[`data_lentgh-1:0]DataMem_Address;
	reg [`data_lentgh-1:0]ReadDataMem;
	wire[`data_lentgh-1:0]WriteDataMem;
	reg DataMem_Ready;
	wire DataMem_access,DataMem_RW;
	wire[3:0] DataMem_Select;
	reg [31:0] ran;
	integer i,j,seed1=13543,erro=0;
	integer commit_number=0;
	//Rand Inst produce
	reg [5:0]inst_type[0:15];//ADDi,Ori,Andi,Xori
	reg [5:0]inst_Funct[0:15];
	reg [4:0]Br_Funct[0:7];
	wire pre_Take;

	wire Inst1_maybe_Branch,Inst2_maybe_Branch;
	wire [31:0]pre_PC;
	
	initial begin
	for(i=0;i<1024;i=i+1)begin
		RM_DataMemory[i]=i;
		end
	end

/* link to real machine*/
Processor Processor(
	.clk(clk),
	.rst(rst),
	.Branch_pre(pre_Take),
	.inst_address(InstMem_Address),
	.Pre_PC(pre_PC),
	.Inst1_maybe_Branch(Inst1_maybe_Branch),
	.Inst2_maybe_Branch(Inst2_maybe_Branch),
	.inst1_in(inst1_in),
	.inst2_in(inst2_in),
	.InstMem_Ready(InstMem_Ready),
	.InstMem_Read(InstMem_Read),
	.DataMem_Select(DataMem_Select),
	.DataMem_Address(DataMem_Address),
	.ReadDataMem(ReadDataMem),
	.WriteDataMem(WriteDataMem),
	.DataMem_Ready(DataMem_Ready),
	.DataMem_access(DataMem_access),
	.DataMem_RW(DataMem_RW)
);

Branch_predictor Branch_predictor(
	.clk(clk),
	.rst(rst),
	.pre_Take(pre_Take),
	.Fetch_PC(InstMem_Address),
	.Commit(Processor.Issue_Window.Commit_1),
	.Branch_taken(Processor.Issue_Window.Commit_1_Branch),
	.Branch_PC(Processor.Issue_Window.Commit_1_Branch_PC),
	.Com_PC(Processor.Issue_Window.Commit_1_PC),
	.Pre_Inst1_Branch(Inst1_maybe_Branch),
	.Pre_Inst2_Branch(Inst2_maybe_Branch),
	.pre_PC(pre_PC)
);


always@(*)begin
		for(i=0;i<32;i=i+1)begin
			Register[i]<=Processor.regfile.file[`commit_temp[i]];
			//$display ($time, " Register File R%2d = %32x " ,i,Processor.regfile.file[`commit_temp[i]]);
			end
end
always @(*)begin
	if(DataMem_access)begin
	DataMem_Ready=1'b1;
	ReadDataMem<={RM_DataMemory[DataMem_Address[17:0]+2'b11],RM_DataMemory[DataMem_Address[17:0]+2'b10],RM_DataMemory[DataMem_Address[17:0]+2'b01],RM_DataMemory[DataMem_Address[17:0]+2'b00]};
	end
	else
	DataMem_Ready=1'b0;
end

always@(posedge clk)begin
		if(DataMem_RW)begin
			if(DataMem_Select[0])RM_DataMemory[DataMem_Address[17:0]+2'b00]<=WriteDataMem[7:0];
			if(DataMem_Select[1])RM_DataMemory[DataMem_Address[17:0]+2'b01]<=WriteDataMem[15:8];
			if(DataMem_Select[2])RM_DataMemory[DataMem_Address[17:0]+2'b10]<=WriteDataMem[23:16];
			if(DataMem_Select[3])RM_DataMemory[DataMem_Address[17:0]+2'b11]<=WriteDataMem[31:24];
			DataMem_Ready<=1'b1;
			end

end

//Sent inst to real machine

always@(*)
	begin
	if(InstMem_Read)
		begin	
			inst1_in=inst_mem[InstMem_Address[19:2]];
			inst2_in=inst_mem[InstMem_Address[19:2]+1];
			InstMem_Ready=1;
		end
	else 
		InstMem_Ready=0;
	end

////////Issue Window display
/*
always@(posedge clk)
begin
$display ($time, "-------Issue Window-------" );
$display (" Issue Window Read  Address %2d",Processor.Issue_Window.read_address);
$display (" Issue Window write Address %2d",Processor.Issue_Window.write_address);
$display ("--------------------------" );
 for(i=0;i<16;i=i+1)
 begin
   $display ("Issue_Window %2d PC= %x Function=%5b Operation=%2d PhyRdst=%2d Src1=%2d Src2=%2d imm =%x",i
   ,Processor.Issue_Window.IW_PC[i]
	,Processor.Issue_Window.IW_Function[i]
	,Processor.Issue_Window.IW_Operation[i]
	,Processor.Issue_Window.IW_PhyRdst[i]
	,Processor.Issue_Window.IW_Src1[i]
	,Processor.Issue_Window.IW_Src2[i]
	,Processor.Issue_Window.IW_imm[i]
	);
	
  $display (" IW_Src1_Wake=%b IW_Src2_Wake=%b  Selected=%b Branch=%b Branch_PC=%x \n " 
	,Processor.Issue_Window.IW_Src1_Wake[i]
	,Processor.Issue_Window.IW_Src2_Wake[i]
	,Processor.Issue_Window.IW_Selected[i]
	,Processor.Issue_Window.IW_Branch[i]
	,Processor.Issue_Window.IW_Branch_PC[i]
	);

 end
end*/


always@(posedge clk)begin
	if(Processor.Issue_Window.Commit_1&Processor.Issue_Window.Commit_2)
	commit_number=commit_number+2;
	else if(Processor.Issue_Window.Commit_1)
	commit_number=commit_number+1;
	$display ("Ex Cycle %d EX inst %d ",$time/10,commit_number);
end
initial begin
	clk =0;
	rst=1;
	#10 rst =0;
	end

always #5 clk=~clk;




endmodule