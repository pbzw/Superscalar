// 2016.06.26
// File         : MIPS_tb.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description: ALU Instructionuc Test
//  
//
`timescale 1ns/100ps
`include "define.v"
`define commit_temp Processor.Rename_Unit.Commit_Mapping

`define TestPattern 65535
`include "define.v"
`define terminate_cycle 100000000

module MIPS_tb;
	reg clk;
	reg rst;
	reg InstMem_Ready;
	wire InstMem_Read;
	wire[`data_lentgh-1:0] InstMem_Address;
	reg [`data_lentgh-1:0] inst_mem[0:1023];
	reg [`data_lentgh-1:0] inst1_in,inst2_in,inst3_in,inst4_in;
	reg [`data_lentgh-1:0] Register[0:31];
	reg [`data_lentgh-1:0] rand_inst_mem[0:65535];
	

    reg [31:0] ran;
	integer i,j,seed1=1512,erro=0;
//	initial	$readmemh (`INST_ROM, inst_mem);
	
	//Rand Inst produce
	reg [5:0]inst_type[0:7];//ADDi,Ori,Andi,Xori
	reg [5:0]inst_Funct[0:7];
	initial
	 begin
	  inst_type[0]=`Op_Ori;
	  inst_type[1]=`Op_Andi;
	  inst_type[2]=`Op_Addi;
	  inst_type[3]=`Op_Xori;
	  inst_type[4]=`Op_Lui;
	  inst_type[5]=`Op_Type_R;
	  inst_type[6]=`Op_Type_R;
	  inst_type[7]=`Op_Type_R;
	 end
	
	initial
	 begin
	  inst_Funct[0]=`Funct_Sub;
	  inst_Funct[1]=`Funct_Add;
	  inst_Funct[2]=`Funct_Nor;
	  inst_Funct[3]=`Funct_Or;
	  inst_Funct[4]=`Funct_Xor;
	  inst_Funct[5]=`Funct_And;
	  inst_Funct[6]=`Funct_Nor;
	  inst_Funct[7]=`Funct_Or;
	 end
	
	initial
	begin
	 for(i=0;i<`TestPattern;i=i+1)
	  begin

	  ran =$random(seed1);
	  case (inst_type[ran[31:29]])
	  `Op_Type_R:rand_inst_mem[i]={inst_type[ran[31:29]],ran[25:11],5'b0,inst_Funct[ran[2:0]]};
	  default:
	   rand_inst_mem[i]={inst_type[ran[31:29]],ran[25:0]};
	  endcase
      end
	end
	
Processor Processor(
	.clk(clk),
	.rst(rst),
	.inst_address(InstMem_Address),
	.inst1_in(inst1_in),
	.inst2_in(inst2_in),
	.inst3_in(inst3_in),
	.inst4_in(inst4_in),
	.InstMem_Ready(InstMem_Ready),
    .InstMem_Read(InstMem_Read)
);
/*
/////////Register Temp
always@(*)
begin
if(Processor.Issue_Window.Commit)
for(i=0;i<32;i=i+1)
 begin
 Register[i]=Processor.regfile.file[`commit_temp[i]];
 //$display ($time, " Register File R%2d = %32x " ,i,Processor.regfile.file[`commit_temp[i]]);
 end
end*/

////////Issue Window 
always@(posedge clk)
begin
$display ($time, "-------Issue Window-------" );
 for(i=0;i<16;i=i+1)
 begin

  $display ($time," Issue Window%2d PC= %x Function=%4b Operation=%5b Oringin_Rdst=%d PhyRdst=%2d Src1=%2d Src2=%2d Src1_Wake=%d Src2_Wake=%d imm =%x Selected=%d IW_Can_Commited=%b" ,
	i
	,Processor.Issue_Window.IW_PC[i]
	,Processor.Issue_Window.IW_Function[i]
	,Processor.Issue_Window.IW_Operation[i]
	,Processor.Issue_Window.IW_Rdst[i]
	,Processor.Issue_Window.IW_PhyRdst[i]
	,Processor.Issue_Window.IW_Src1[i]
	,Processor.Issue_Window.IW_Src2[i]
	,Processor.Issue_Window.IW_Src1_Wake[i]
	,Processor.Issue_Window.IW_Src2_Wake[i]
	,Processor.Issue_Window.IW_imm[i]
	,Processor.Issue_Window.IW_Selected[i]
	,Processor.Issue_Window.IW_Can_Commited[i]
	);

 end
end



//Virtual Machine
reg [31:0]VM_Reg[0:31];
reg  [31:0]VM_PC =32'd0;
wire [31:0]VM_inst_in,data1,data2;
wire [4:0]VM_Rd,VM_Rt,VM_Rs;
wire [5:0]Funct;

initial begin
for(i=0;i<32;i=i+1)
VM_Reg[i]<=32'd0;
end


assign VM_inst_in=rand_inst_mem[VM_PC[18:2]];
assign data1=(VM_Rs==5'd0)? 32'd0:VM_Reg[VM_Rs];
assign data2=(VM_Rt==5'd0)? 32'd0:VM_Reg[VM_Rt];
assign VM_Rs=VM_inst_in[25:21];
assign VM_Rt=VM_inst_in[20:16];
assign VM_Rd=VM_inst_in[15:11];
assign Funct=VM_inst_in[5:0];
/*
always@(posedge clk)
begin
if(Processor.Issue_Window.Commit)
 begin
 VM_PC<=VM_PC+32'd4;

 case(VM_inst_in[31:26])
    `Op_Ori :begin if(VM_Rt!=5'd0)VM_Reg[VM_Rt]<=data1|{16'd0,VM_inst_in[15:0]};end 
	`Op_Andi:begin if(VM_Rt!=5'd0)VM_Reg[VM_Rt]<=data1&{16'd0,VM_inst_in[15:0]};end
	`Op_Addi:begin if(VM_Rt!=5'd0)VM_Reg[VM_Rt]<=data1+{{16{VM_inst_in[15]}},VM_inst_in[15:0]};end
	`Op_Xori:begin if(VM_Rt!=5'd0)VM_Reg[VM_Rt]<=data1^{16'd0,VM_inst_in[15:0]};end
	`Op_Lui :begin if(VM_Rt!=5'd0)VM_Reg[VM_Rt]<={VM_inst_in[15:0],16'd0};end
	`Op_Type_R  :begin
                        case (Funct)
							`Funct_Add     :begin if(VM_Rd!=5'd0)VM_Reg[VM_Rd]<=   data1+data2 ; end
							`Funct_Sub     :begin if(VM_Rd!=5'd0)VM_Reg[VM_Rd]<=   data1-data2 ; end
							`Funct_Or      :begin if(VM_Rd!=5'd0)VM_Reg[VM_Rd]<=   data1|data2 ; end
							`Funct_Xor     :begin if(VM_Rd!=5'd0)VM_Reg[VM_Rd]<=   data1^data2 ; end
							`Funct_And     :begin if(VM_Rd!=5'd0)VM_Reg[VM_Rd]<=   data1&data2 ; end
							`Funct_Nor     :begin if(VM_Rd!=5'd0)VM_Reg[VM_Rd]<=~ (data1|data2); end
							default        : ;
                        endcase
				 end
	default:;
 endcase
 end

end

always@(negedge clk)
begin
if(Processor.Issue_Window.Commit)
 begin
     //$display ($time, "--------------------------" );
     $display ($time, " NOW at pattern %32d Instruction=%32x ERRO Count = %2d",VM_PC/4,VM_inst_in,erro);
	 //$display ($time, "--------------------------" );
     for(i=1;i<32;i=i+1)
	 begin
	 //$display ($time, "  Virtual Reg [%2d] = %32x  Real Reg [%2d] = %32x",i,VM_Reg[i],i,Register[i]);
	 if(VM_Reg[i]!==Register[i])
	  begin
      erro=erro+1;
	  
	  $display ($time, " ERRO! Register File R%2d != VM_Reg %2d " ,i,i);
	  $stop;
      end
	 end
	 
	 $display ($time, "--------------------------\n" );

 end
end

*/
//Sent inst to real machine

always@(*)
	begin
	if(InstMem_Read)
		begin	
			inst1_in=rand_inst_mem[InstMem_Address[17:2]];
			inst2_in=rand_inst_mem[InstMem_Address[17:2]+1];
			inst3_in=rand_inst_mem[InstMem_Address[17:2]+2];
			inst4_in=rand_inst_mem[InstMem_Address[17:2]+3];
			InstMem_Ready=1;
		end
	else 
		InstMem_Ready=0;
	end

//	simulation Final display

initial 
	begin
		clk =0;
		rst=1;
		#10 rst =0;
		
		wait(VM_PC>(20000*4))
		begin
		if(!erro)
		begin
			$display("============================================================================");
			$display("\n \\(^o^)/  The simulation  finish\n");
			$display("============================================================================");
		$stop;
		end
		else
		begin
			$display("============================================================================");
			$display("\n The simulation ERRO\n");
			$display("============================================================================");
		$stop;
		end
		end
	end
	
initial begin 
	#`terminate_cycle;
	$display("================================================================================================================");
	$display("--------------------------- (/`n`)/ ~#  There was something wrong with your code !! ---------------------------"); 
	$display("--------------------------- The simulation can't finished!!, Please check it !!! ---------------------------"); 
	$display("================================================================================================================");
	$stop;
end

always #5 clk=~clk;


endmodule
