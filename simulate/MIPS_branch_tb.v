`timescale 1ns/100ps
`include "define.v"
`define TestPattern 262143
`define test_num  20000
`define commit_signal Processor.Issue_Window.Commit_1
`define commit_temp Processor.Register_Rename.Commit_Mapping
`define RM_PC Processor.Commit_1_Branch_PC

module MIPS_branch_tb;

	reg clk;
	reg rst;
	reg InstMem_Ready;
	wire InstMem_Read;
	wire[`data_lentgh-1:0] InstMem_Address;
	reg [`data_lentgh-1:0] inst_mem[0:1023];
	reg [`data_lentgh-1:0] inst1_in,inst2_in;
	reg [`data_lentgh-1:0] Register[0:31];
	reg [`data_lentgh-1:0] rand_inst_mem[0:`TestPattern-1];

	reg [31:0] ran;
	integer i,j,seed1=851,erro=0;
	
	//Rand Inst produce
	reg [5:0]inst_type[0:15];//ADDi,Ori,Andi,Xori
	reg [5:0]inst_Funct[0:15];
	reg [4:0]Br_Funct[0:7];

/*randinst initial*/
initial begin
	inst_type[00]=`Op_Ori;
	inst_type[01]=`Op_Andi;
	inst_type[02]=`Op_Addi;
	inst_type[03]=`Op_Xori;
	inst_type[04]=`Op_Lui;
	inst_type[05]=`Op_Type_R;
	inst_type[06]=`Op_J;
	inst_type[07]=`Op_Jal;
	inst_type[08]=`Op_Beq;
	inst_type[09]=`Op_Bgtz;
	inst_type[10]=`Op_Blez;
	inst_type[11]=`Op_Bne;
	inst_type[12]=`Op_Type_Regimm;
	
	inst_type[13]=`Op_Ori;
	inst_type[14]=`Op_Andi;
	inst_type[15]=`Op_Addi;
	end
	
initial begin
	inst_Funct[00]=`Funct_Sub;
	inst_Funct[01]=`Funct_Add;
	inst_Funct[02]=`Funct_Nor;
	inst_Funct[03]=`Funct_Or;
	inst_Funct[04]=`Funct_Xor;
	inst_Funct[05]=`Funct_And;
	inst_Funct[06]=`Funct_And;
	inst_Funct[07]=`Funct_And;
	inst_Funct[08]=`Funct_Sub;
	inst_Funct[09]=`Funct_Sll;
	inst_Funct[10]=`Funct_Srl;
	inst_Funct[11]=`Funct_Or;
	inst_Funct[12]=`Funct_Xor;
	inst_Funct[13]=`Funct_And;
	inst_Funct[14]=`Funct_Jalr;
	inst_Funct[15]=`Funct_Jr;
	end
	
initial begin
	Br_Funct[00]=`OpRt_Bgez;
	Br_Funct[01]=`OpRt_Bgezal;
	Br_Funct[02]=`OpRt_Bltz;
	Br_Funct[03]=`OpRt_Bltzal;
	end

initial begin
		for(i=0;i<`TestPattern;i=i+1)begin
		ran =$random(seed1);
			case (inst_type[ran[31:28]])
				`Op_Type_R:rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:11],5'b0,inst_Funct[ran[3:0]]};
				`Op_Type_Regimm:begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:21],Br_Funct[ran[17:16]],ran[15:0]};
					rand_inst_mem[i+1]=32'd0 ;
					i=i+1;end
				`Op_J     :begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:11],5'b0,inst_Funct[ran[3:0]]};
					rand_inst_mem[i+1]=32'd0 ;
					i=i+1;end
				`Op_Jal   :begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:11],5'b0,inst_Funct[ran[3:0]]}; 
					rand_inst_mem[i+1]=32'd0 ; 
					i=i+1;end
				`Op_Beq   :begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:0]};
					rand_inst_mem[i+1]=32'd0 ;
					i=i+1; end
				`Op_Bgtz  :begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:21],5'b0,ran[15:0]}; 
					rand_inst_mem[i+1]=32'd0 ;
					i=i+1; end
				`Op_Blez  :begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:21],5'b0,ran[15:0]}; 
					rand_inst_mem[i+1]=32'd0 ; 
					i=i+1; end
				`Op_Bne   :begin 
					rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:0]};
					rand_inst_mem[i+1]=32'd0 ;
					i=i+1; end
				default:begin rand_inst_mem[i]={inst_type[ran[31:28]],ran[25:0]};
						case (rand_inst_mem[i][5:0])
						`Funct_Jalr:begin rand_inst_mem[i+1]=32'd0 ;i=i+1;end
						`Funct_Jr:begin rand_inst_mem[i+1]=32'd0 ; i=i+1;end
						endcase
					end
			endcase
		end
	end
	
/* link to real machine*/
Processor Processor(
	.clk(clk),
	.rst(rst),
	.inst_address(InstMem_Address),
	.inst1_in(inst1_in),
	.inst2_in(inst2_in),
	.InstMem_Ready(InstMem_Ready),
    .InstMem_Read(InstMem_Read)
);

always@(*)begin
		for(i=0;i<32;i=i+1)begin
			Register[i]<=Processor.regfile.file[`commit_temp[i]];
			//$display ($time, " Register File R%2d = %32x " ,i,Processor.regfile.file[`commit_temp[i]]);
			end
end

//Sent inst to real machine

always@(*)
	begin
	if(InstMem_Read)
		begin	
			inst1_in=rand_inst_mem[InstMem_Address[19:2]];
			inst2_in=rand_inst_mem[InstMem_Address[19:2]+1];
			InstMem_Ready=1;
		end
	else 
		InstMem_Ready=0;
	end
/*
////////Issue Window display
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
end
*/





//virtual machine 
integer commit_num=0;
reg  [31:0]VM_Reg[0:31];
reg  [31:0]VM_PC =32'd0;
wire [31:0]VM_inst_in;
wire signed[31:0]data1,data2;
wire [4:0]VM_Rd,VM_Rs,VM_Rt;
wire [5:0]Funct;
wire [31:0]VM_PC_plus_8=VM_PC+32'd8;
wire [31:0]VM_PC_plus_4=VM_PC+32'd4;
reg Branch_flag=0;
reg [31:0]New_PC=32'b0;	
	
	assign VM_inst_in=rand_inst_mem[VM_PC[19:2]];
	assign data1=(VM_Rs==5'd0)? 32'd0:VM_Reg[VM_Rs];
	assign data2=(VM_Rt==5'd0)? 32'd0:VM_Reg[VM_Rt];
	assign VM_Rs=VM_inst_in[25:21];
	assign VM_Rt=VM_inst_in[20:16];
	assign VM_Rd=VM_inst_in[15:11];
	assign Funct=VM_inst_in[5:0];
	
initial begin
	for(i=0;i<32;i=i+1)
		VM_Reg[i]<=32'd0;
end

always@(posedge clk)
	begin
		if(`commit_signal)begin
		commit_num=commit_num+1;
		$display ($time, " VM_PC    =%32x commit_num=%32d", VM_PC,commit_num);``
			if(Branch_flag)begin
				Branch_flag <=1'b0;
				VM_PC<=New_PC;
				$display ($time, " Branch to %32x ", New_PC);
				end
			else
				VM_PC<=VM_PC+32'd4;
			
			case(VM_inst_in[31:26])
				`Op_Ori :begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1|{16'd0,VM_inst_in[15:0]};
					end 
				`Op_Andi:begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1&{16'd0,VM_inst_in[15:0]};
					end
				`Op_Addi:begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1+{{16{VM_inst_in[15]}},VM_inst_in[15:0]};
					end
				`Op_Xori:begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1^{16'd0,VM_inst_in[15:0]};
					end
				`Op_Lui :begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<={VM_inst_in[15:0],16'd0};
					end
				`Op_J   :begin 
				 $display ($time, " Occur J ");
					Branch_flag <=1'b1;
					New_PC<={VM_PC_plus_4[31:28],VM_inst_in[25:0],2'b0};
					end
				`Op_Jal :begin 
					$display ($time, " Occur Jal ");
					Branch_flag <=1'b1;
					New_PC<={VM_PC_plus_4[31:28],VM_inst_in[25:0],2'b0} ;
					VM_Reg[31]<={VM_PC_plus_8};
					end
				`Op_Beq   :begin 
					$display ($time, " Occur Beq %b ",(data1==data2));
					Branch_flag <=(data1==data2);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0});
					end
				`Op_Bgtz   :begin 
					$display ($time, " Occur Bgtz %b",(data1>32'd0));
					Branch_flag <=(data1>32'd0);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
					end
				`Op_Blez   :begin 
					$display ($time, " Occur Blez %b",(data1<=32'd0));
					Branch_flag <=(data1<=32'd0);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
					end
				`Op_Bne   :begin 
					$display ($time, " Occur Bne %b",(data1!=data2));
					Branch_flag <=(data1!=data2);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
					end
				`Op_Type_Regimm:begin
					case(VM_Rt)
					`OpRt_Bltz:begin
						$display ($time, " Occur Bltz %b",(data1<32'd0));
						Branch_flag <=(data1<32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						end
					`OpRt_Bltzal:begin
						$display ($time, " Occur Bltzal %b",(data1<32'd0));
						Branch_flag <=(data1<32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						VM_Reg[31]<=(data1<32'd0)?VM_PC+32'd8:VM_Reg[31];
						end
					`OpRt_Bgez:begin
						$display ($time, " Occur Bgez %b",(data1>=32'd0));
						Branch_flag <=(data1>=32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						end
					`OpRt_Bgezal:begin
						$display ($time, " Occur Bgezal %b",(data1>=32'd0));
						Branch_flag <=(data1>=32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						VM_Reg[31]<=(data1>=32'd0)?VM_PC+32'd8:VM_Reg[31];
						end
					endcase
					end
				`Op_Type_R:begin
					case (Funct)
						`Funct_Add     :begin 
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1+data2 ; 
							end
						`Funct_Sub     :begin
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1-data2 ;
							end
						`Funct_Or      :begin
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1|data2 ;
							end
						`Funct_Xor     :begin 
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1^data2 ;
							end
						`Funct_And     :begin 
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1&data2 ;
							end
						`Funct_Nor     :begin
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=~ (data1|data2);
							end
						`Funct_Jr      :begin 
							$display ($time, " Occur Jr ");
							Branch_flag <=1'b1;
							New_PC<=data1;
							end
						`Funct_Jalr    :begin 
							$display ($time, " Occur Jalr ");
							Branch_flag <=1'b1; 
							New_PC<=data1; 
								if(VM_Rd!=5'd0)
									VM_Reg[VM_Rd]<=VM_PC+32'd8;
							end
						`Funct_Sll   :begin
								if(VM_Rd!=5'd0)
									VM_Reg[VM_Rd]<=data1<<VM_inst_in[10:6];
							end
						`Funct_Srl   :begin
								if(VM_Rd!=5'd0)
									VM_Reg[VM_Rd]<=data1>>VM_inst_in[10:6];
							end
						default        : ;
					endcase 
					end
				default:;
			endcase
		end
	end
always@(negedge clk)
	begin
		if(Processor.Issue_Window.Commit_2)begin
		commit_num=commit_num+1;
		$display ($time, " VM_PC    =%32x commit_num=%32d", VM_PC,commit_num);``
			if(Branch_flag)begin
				Branch_flag <=1'b0;
				VM_PC<=New_PC;
				$display ($time, " Branch to %32x ", New_PC);
				end
			else
				VM_PC<=VM_PC+32'd4;
			
			case(VM_inst_in[31:26])
				`Op_Ori :begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1|{16'd0,VM_inst_in[15:0]};
					end 
				`Op_Andi:begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1&{16'd0,VM_inst_in[15:0]};
					end
				`Op_Addi:begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1+{{16{VM_inst_in[15]}},VM_inst_in[15:0]};
					end
				`Op_Xori:begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<=data1^{16'd0,VM_inst_in[15:0]};
					end
				`Op_Lui :begin 
					if(VM_Rt!=5'd0)
						VM_Reg[VM_Rt]<={VM_inst_in[15:0],16'd0};
					end
				`Op_J   :begin 
				 $display ($time, " Occur J ");
					Branch_flag <=1'b1;
					New_PC<={VM_PC_plus_4[31:28],VM_inst_in[25:0],2'b0};
					end
				`Op_Jal :begin 
					$display ($time, " Occur Jal ");
					Branch_flag <=1'b1;
					New_PC<={VM_PC_plus_4[31:28],VM_inst_in[25:0],2'b0} ;
					VM_Reg[31]<={VM_PC_plus_8};
					end
				`Op_Beq   :begin 
					$display ($time, " Occur Beq %b ",(data1==data2));
					Branch_flag <=(data1==data2);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0});
					end
				`Op_Bgtz   :begin 
					$display ($time, " Occur Bgtz %b",(data1>32'd0));
					Branch_flag <=(data1>32'd0);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
					end
				`Op_Blez   :begin 
					$display ($time, " Occur Blez %b",(data1<=32'd0));
					Branch_flag <=(data1<=32'd0);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
					end
				`Op_Bne   :begin 
					$display ($time, " Occur Bne %b",(data1!=data2));
					Branch_flag <=(data1!=data2);
					New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
					end
				`Op_Type_Regimm:begin
					case(VM_Rt)
					`OpRt_Bltz:begin
						$display ($time, " Occur Bltz %b",(data1<32'd0));
						Branch_flag <=(data1<32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						end
					`OpRt_Bltzal:begin
						$display ($time, " Occur Bltzal %b",(data1<32'd0));
						Branch_flag <=(data1<32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						VM_Reg[31]<=(data1<32'd0)?VM_PC+32'd8:VM_Reg[31];
						end
					`OpRt_Bgez:begin
						$display ($time, " Occur Bgez %b",(data1>=32'd0));
						Branch_flag <=(data1>=32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						end
					`OpRt_Bgezal:begin
						$display ($time, " Occur Bgezal %b",(data1>=32'd0));
						Branch_flag <=(data1>=32'd0);
						New_PC<=(VM_PC+32'd4+{{14{VM_inst_in[15]}},VM_inst_in[15:0],2'b0}) ;
						VM_Reg[31]<=(data1>=32'd0)?VM_PC+32'd8:VM_Reg[31];
						end
					endcase
					end
				`Op_Type_R:begin
					case (Funct)
						`Funct_Add     :begin 
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1+data2 ; 
							end
						`Funct_Sub     :begin
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1-data2 ;
							end
						`Funct_Or      :begin
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1|data2 ;
							end
						`Funct_Xor     :begin 
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1^data2 ;
							end
						`Funct_And     :begin 
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=   data1&data2 ;
							end
						`Funct_Nor     :begin
							if(VM_Rd!=5'd0)
								VM_Reg[VM_Rd]<=~ (data1|data2);
							end
						`Funct_Jr      :begin 
							$display ($time, " Occur Jr ");
							Branch_flag <=1'b1;
							New_PC<=data1;
							end
						`Funct_Jalr    :begin 
							$display ($time, " Occur Jalr ");
							Branch_flag <=1'b1; 
							New_PC<=data1; 
								if(VM_Rd!=5'd0)
									VM_Reg[VM_Rd]<=VM_PC+32'd8;
							end
						`Funct_Sll   :begin
								if(VM_Rd!=5'd0)
									VM_Reg[VM_Rd]<=data1<<VM_inst_in[10:6];
							end
						`Funct_Srl   :begin
								if(VM_Rd!=5'd0)
									VM_Reg[VM_Rd]<=data1>>VM_inst_in[10:6];
							end
						default        : ;
					endcase 
					end
				default:;
			endcase
		end
	end
always #5 clk=~clk;




always@(negedge clk)
begin
if(`commit_signal)
 begin
     $display ($time, "--------------------------" );
     $display ($time, " NOW inst Address  %x Instruction=%x Commit Inst Count %d ERRO Count = %d",VM_PC,VM_inst_in,commit_num,erro);
	 $display ($time, "--------------------------" );
     for(i=0;i<32;i=i+1)
	 begin
	 //$display ($time, "  Virtual Reg [%2d] = %32x  Real Reg [%2d] = %32x",i,VM_Reg[i],i,Register[i]);
	 if(VM_Reg[i]!==Register[i])
	  begin
      erro=erro+1;
	  
	  $display ($time, " ERRO! Register File R%2d != VM_Reg %2d " ,i,i);
	  $display ($time, "  Virtual Reg [%2d] = %32x  Real Reg [%2d] = %32x",i,VM_Reg[i],i,Register[i]);
	  $stop;
      end
	 end
	

 end
end

always@(posedge clk)begin
	if(Branch_flag)begin
		if(New_PC!==`RM_PC)begin
			erro=erro+1;
			$display ($time, " ERRO! at PC %x: VM_Branch_PC %x != RM_Branch_PC %x " ,VM_PC,New_PC,`RM_PC);
			$stop;
			end
		else begin
		$display ($time, " Branch succes PC %x: VM_Branch_PC %x == RM_Branch_PC %x " ,VM_PC,New_PC,`RM_PC );
		end
		$display ($time, "--------------------------\n" );
		wait(`commit_signal);
	end
end

initial begin
	clk =0;
	rst=1;
	#10 rst =0;
	wait(commit_num>`test_num)
	if(!erro)begin
		$display("============================================================================");
		$display("\n \\(^o^)/  The simulation  finish\n");
		$display("============================================================================");
		$stop;
	end
	
	else begin
		$display("============================================================================");
		$display("\n The simulation ERRO\n");
		$display("============================================================================");
		$stop;
		end
	
	
	end

endmodule
