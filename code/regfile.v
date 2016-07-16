// 2016.06.21
// File         : regfile.v
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

module regfile #(parameter WIDTH = 32,parameter DEPTH = 64)(
input clk,
input we_1,we_2,we_3,we_4,
input [$clog2(DEPTH)-1:0]read_reg1,read_reg2,read_reg3,read_reg4,
input [$clog2(DEPTH)-1:0]read_reg5,read_reg6,read_reg7,read_reg8,


input [$clog2(DEPTH)-1:0]write_reg1,write_reg2,write_reg3,write_reg4,
input [WIDTH-1:0]write_reg1_data,write_reg2_data,write_reg3_data,write_reg4_data,

output [WIDTH-1:0] read_out_1,read_out_2,read_out_3,read_out_4,read_out_5,read_out_6,
output [WIDTH-1:0] read_out_7,read_out_8
);
integer i;

parameter zero={(WIDTH){1'b0}};

reg [WIDTH-1:0]file[0:DEPTH-1];

assign read_out_1=(read_reg1==6'b0)?zero:file[read_reg1];
assign read_out_2=(read_reg2==6'b0)?zero:file[read_reg2];
assign read_out_3=(read_reg3==6'b0)?zero:file[read_reg3];
assign read_out_4=(read_reg4==6'b0)?zero:file[read_reg4];
assign read_out_5=(read_reg5==6'b0)?zero:file[read_reg5];
assign read_out_6=(read_reg6==6'b0)?zero:file[read_reg6];
assign read_out_7=(read_reg7==6'b0)?zero:file[read_reg7];
assign read_out_8=(read_reg8==6'b0)?zero:file[read_reg8];

initial begin //test use
	for(i=0;i<64;i=i+1)
		file[i]=32'd0;
	end

always @(`clk_trigger_edge clk)
begin
	if(we_1&(write_reg1!=6'd0))
		file[write_reg1]<=write_reg1_data;
	if(we_2&(write_reg2!=6'd0))
		file[write_reg2]<=write_reg2_data;
	if(we_3&(write_reg3!=6'd0))
		file[write_reg3]<=write_reg3_data;
	if(we_4&(write_reg4!=6'd0))
		file[write_reg4]<=write_reg4_data;
end

endmodule