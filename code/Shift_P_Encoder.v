
module Shift_P_Encoder16(
input [3:0]Shift_base,
input [0:15]in,
output[3:0] out,
output valid
);
wire [3:0]En_out0,En_out1,En_out2,En_out3;
wire [3:0]En_out4,En_out5,En_out6,En_out7;
wire [3:0]En_out8,En_out9,En_out10,En_out11;
wire [3:0]En_out12,En_out13,En_out14,En_out15;

assign valid=|in;
Mux16 #(.WIDTH (4)) Mux16(

    .sel(Shift_base),
    .in0(En_out0),
	 .in1(En_out1),
	 .in2(En_out2),
	 .in3(En_out3),
	 .in4(En_out4),
	 .in5(En_out5),
	 .in6(En_out6),
	 .in7(En_out7),
	 .in8(En_out8),
	 .in9(En_out9),
	 .in10(En_out10),
	 .in11(En_out11),
	 .in12(En_out12),
	 .in13(En_out13),
	 .in14(En_out14),
	 .in15(En_out15),
    .out(out)
    );
	
PEncoder16#(.fix(4'd0)) Encoder0 (
	.in(in),
	.Select(En_out0)
);


PEncoder16#(.fix(4'd1)) Encoder1 (
	.in({in[1:15],in[0]}),
	.Select(En_out1)
);

PEncoder16#(.fix(4'd2)) Encoder2 (
	.in({in[2:15],in[0:1]}),
	.Select(En_out2)
);

PEncoder16#(.fix(4'd3)) Encoder3(
	.in({in[3:15],in[0:2]}),
	.Select(En_out3)
);

PEncoder16#(.fix(4'd4)) Encoder4(
	.in({in[4:15],in[0:3]}),
	.Select(En_out4)
);

PEncoder16#(.fix(4'd5)) Encoder5(
	.in({in[5:15],in[0:4]}),
	.Select(En_out5)
);

PEncoder16#(.fix(4'd6)) Encoder6(
	.in({in[6:15],in[0:5]}),
	.Select(En_out6)
);

PEncoder16#(.fix(4'd7)) Encoder7(
	.in({in[7:15],in[0:6]}),
	.Select(En_out7)
);

PEncoder16#(.fix(4'd8)) Encoder8(
	.in({in[8:15],in[0:7]}),
	.Select(En_out8)
);

PEncoder16#(.fix(4'd9)) Encoder9(
	.in({in[9:15],in[0:8]}),
	.Select(En_out9)
);

PEncoder16#(.fix(4'd10)) Encoder10(
	.in({in[10:15],in[0:9]}),
	.Select(En_out10)
);

PEncoder16#(.fix(4'd11)) Encoder11(
	.in({in[11:15],in[0:10]}),
	.Select(En_out11)
);

PEncoder16#(.fix(4'd12)) Encoder12(
	.in({in[12:15],in[0:11]}),
	.Select(En_out12)
);

PEncoder16#(.fix(4'd13)) Encoder13(
	.in({in[13:15],in[0:12]}),
	.Select(En_out13)
);

PEncoder16#(.fix(4'd14)) Encoder14(
	.in({in[14:15],in[0:13]}),
	.Select(En_out14)
);

PEncoder16#(.fix(4'd15)) Encoder15(
	.in({in[15],in[0:14]}),
	.Select(En_out15)
);

endmodule 

module PEncoder16 #(parameter fix = 4'd0)(
input [0:15]in,
output reg  [3:0]Select
);



always@(*)
 begin
  casex(in)
  16'b0000_0000_0000_0001:Select=4'd15+fix;
  16'b0000_0000_0000_001x:Select=4'd14+fix;
  16'b0000_0000_0000_01xx:Select=4'd13+fix;
  16'b0000_0000_0000_1xxx:Select=4'd12+fix;
  16'b0000_0000_0001_xxxx:Select=4'd11+fix;
  16'b0000_0000_001x_xxxx:Select=4'd10+fix;
  16'b0000_0000_01xx_xxxx:Select=4'd09+fix;
  16'b0000_0000_1xxx_xxxx:Select=4'd08+fix;
  16'b0000_0001_xxxx_xxxx:Select=4'd07+fix;
  16'b0000_001x_xxxx_xxxx:Select=4'd06+fix;
  16'b0000_01xx_xxxx_xxxx:Select=4'd05+fix;
  16'b0000_1xxx_xxxx_xxxx:Select=4'd04+fix;
  16'b0001_xxxx_xxxx_xxxx:Select=4'd03+fix;  
  16'b001x_xxxx_xxxx_xxxx:Select=4'd02+fix;
  16'b01xx_xxxx_xxxx_xxxx:Select=4'd01+fix;
  16'b1xxx_xxxx_xxxx_xxxx:Select=4'd00+fix;
  default:Select=4'bxxxx;
  endcase
 end
 
endmodule

module Shift_P_Encoder8(
input [2:0]Shift_base,
input [0:7]in,
output[2:0] out,
output valid
);
wire [2:0]En_out0,En_out1,En_out2,En_out3;
wire [2:0]En_out4,En_out5,En_out6,En_out7;


assign valid=|in;

Mux8 #(.WIDTH (3)) Mux8(

    .sel(Shift_base),
    .in0(En_out0),
	 .in1(En_out1),
	 .in2(En_out2),
	 .in3(En_out3),
	 .in4(En_out4),
	 .in5(En_out5),
	 .in6(En_out6),
	 .in7(En_out7),
    .out(out)
    );
	
PEncoder8 #(.fix(3'd0)) Encoder0 (
	.in(in),
	.Select(En_out0)
);


PEncoder8 #(.fix(3'd1)) Encoder1 (
	.in({in[1:7],in[0]}),
	.Select(En_out1)
);

PEncoder8 #(.fix(3'd2)) Encoder2 (
	.in({in[2:7],in[0:1]}),
	.Select(En_out2)
);

PEncoder8 #(.fix(3'd3)) Encoder3(
	.in({in[3:7],in[0:2]}),
	.Select(En_out3)
);

PEncoder8 #(.fix(3'd4)) Encoder4(
	.in({in[4:7],in[0:3]}),
	.Select(En_out4)
);

PEncoder8 #(.fix(3'd5)) Encoder5(
	.in({in[5:7],in[0:4]}),
	.Select(En_out5)
);

PEncoder8 #(.fix(3'd6)) Encoder6(
	.in({in[6:7],in[0:5]}),
	.Select(En_out6)
);

PEncoder8 #(.fix(3'd7)) Encoder7(
	.in({in[7],in[0:6]}),
	.Select(En_out7)
);

endmodule 

module PEncoder8 #(parameter fix = 3'd0)(
input [0:7]in,
output reg  [2:0]Select
);



always@(*)
 begin
  casex(in)
  8'b0000_0001:Select=3'd07+fix;
  8'b0000_001x:Select=3'd06+fix;
  8'b0000_01xx:Select=3'd05+fix;
  8'b0000_1xxx:Select=3'd04+fix;
  8'b0001_xxxx:Select=3'd03+fix;  
  8'b001x_xxxx:Select=3'd02+fix;
  8'b01xx_xxxx:Select=3'd01+fix;
  8'b1xxx_xxxx:Select=3'd00+fix;
  default:Select=3'bxxx;
  endcase
 end
 
endmodule
