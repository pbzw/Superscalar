`include "define.v"

module shift_counter #(parameter WIDTH = 16,parameter Reset = 16'b100000000)(
input clk,
input rst,
input clr,
input en,
output reg[WIDTH-1:0] count
);


always@(`clk_trigger_edge clk)
begin
	if(rst|clr)
	count<=Reset;
	else if(en)
	count<={count[0],count[WIDTH-1:1]};
end

endmodule
