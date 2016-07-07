module Encoder_64bit_4_out (
input en,
input[63:0]in,
output reg [5:0]out_1,out_2,out_3,out_4
);
reg [5:0]encode;

integer i,j,count1;

always@(*)begin
	for(i=1;(i<63)&(!in[i]);i=i+1)
	out_1=i;
end



endmodule
