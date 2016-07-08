`include "define.v"

module up_counter #(parameter WIDTH = 32)(
input clk,
input rst,
input clr,
input en,
output reg[WIDTH-1:0] count
);
parameter zero={(WIDTH){1'b0}};


always@(`clk_trigger_edge clk)
begin
	if(rst|clr)
	count<=zero;
	else if(en)
	count<=count+{{WIDTH-1{1'b0}},1'b1};
end

endmodule
