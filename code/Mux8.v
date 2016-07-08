module Mux8 #(parameter WIDTH = 32)(
input[2:0]sel,
input[(WIDTH-1):0] in0,in1,in2,in3,in4,in5,in6,in7,
output reg [(WIDTH-1):0] out
);

always@(*)
	begin
		case(sel)
		3'b0000:out=in0;
		3'b0001:out=in1;
		3'b0010:out=in2;
		3'b0011:out=in3;
		3'b0100:out=in4;
		3'b0101:out=in5;
		3'b0110:out=in6;
		3'b0111:out=in7;
		endcase
end

endmodule