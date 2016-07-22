// 2016.06.26
// File         : Shift_P_LS_Encoder.v
// Project      : SIDE MIPS
//(Single Instruction Issue Dynamic Schedule Out-of-order execution  MIPS Processor)
// Creator(s)   : Yang, Yu-Xiang (M10412034@yuntech.edu.tw)
// 
//
//
//  Description:
//  
//
module Shift_P_LS_Encoder(
input [3:0]Shift_base,
input [0:15]Load_req,
input [0:15]Store_req,
output[3:0] Select,
output valid
);

wire [3:0]En_out0,En_out1,En_out2,En_out3;
wire [3:0]En_out4,En_out5,En_out6,En_out7;
wire [3:0]En_out8,En_out9,En_out10,En_out11;
wire [3:0]En_out12,En_out13,En_out14,En_out15;
wire [15:0]En_valid;

assign valid=En_valid[Shift_base];

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
    .out(Select)
    );
	 
	 
LS_Encoder #(.fix(4'd0)) Encoder0 (
	.Load_req(Load_req),
	.Store_req(Store_req),
	.Select(En_out0),
	.valid(En_valid[0])
);


LS_Encoder #(.fix(4'd1)) Encoder1 (
	.Load_req({Load_req[1:15],Load_req[0]}),
	.Store_req({Store_req[1:15],Store_req[0]}),
	.Select(En_out1),
	.valid(En_valid[1])
);

LS_Encoder #(.fix(4'd2)) Encoder2 (
	.Load_req({Load_req[2:15],Load_req[0:1]}),
	.Store_req({Store_req[2:15],Store_req[0:1]}),
	.Select(En_out2),
	.valid(En_valid[2])
);

LS_Encoder #(.fix(4'd3)) Encoder3(
	.Load_req({Load_req[3:15],Load_req[0:2]}),
	.Store_req({Store_req[3:15],Store_req[0:2]}),
	.Select(En_out3),
	.valid(En_valid[3])
);

LS_Encoder #(.fix(4'd4)) Encoder4(
	.Load_req({Load_req[4:15],Load_req[0:3]}),
	.Store_req({Store_req[4:15],Store_req[0:3]}),
	.Select(En_out4),
	.valid(En_valid[4])
);

LS_Encoder #(.fix(4'd5)) Encoder5(
	.Load_req({Load_req[5:15],Load_req[0:4]}),
	.Store_req({Store_req[5:15],Store_req[0:4]}),
	.Select(En_out5),
	.valid(En_valid[5])
);

LS_Encoder #(.fix(4'd6)) Encoder6(
	.Load_req({Load_req[6:15],Load_req[0:5]}),
	.Store_req({Store_req[6:15],Store_req[0:5]}),
	.Select(En_out6),
	.valid(En_valid[6])
);

LS_Encoder #(.fix(4'd7)) Encoder7(
	.Load_req({Load_req[7:15],Load_req[0:6]}),
	.Store_req({Store_req[7:15],Store_req[0:6]}),
	.Select(En_out7),
	.valid(En_valid[7])
);

LS_Encoder #(.fix(4'd8)) Encoder8(
	.Load_req({Load_req[8:15],Load_req[0:7]}),
	.Store_req({Store_req[8:15],Store_req[0:7]}),
	.Select(En_out8),
	.valid(En_valid[8])
);

LS_Encoder #(.fix(4'd9)) Encoder9(
	.Load_req({Load_req[9:15],Load_req[0:8]}),
	.Store_req({Store_req[9:15],Store_req[0:8]}),
	.Select(En_out9),
	.valid(En_valid[9])
);

LS_Encoder #(.fix(4'd10)) Encoder10(
	.Load_req({Load_req[10:15],Load_req[0:9]}),
	.Store_req({Store_req[10:15],Store_req[0:9]}),
	.Select(En_out10),
	.valid(En_valid[10])
);

LS_Encoder #(.fix(4'd11)) Encoder11(
	.Load_req({Load_req[11:15],Load_req[0:10]}),
	.Store_req({Store_req[11:15],Store_req[0:10]}),
	.Select(En_out11),
	.valid(En_valid[11])
);

LS_Encoder #(.fix(4'd12)) Encoder12(
	.Load_req({Load_req[12:15],Load_req[0:11]}),
	.Store_req({Store_req[12:15],Store_req[0:11]}),
	.Select(En_out12),
	.valid(En_valid[12])
);

LS_Encoder #(.fix(4'd13)) Encoder13(
	.Load_req({Load_req[13:15],Load_req[0:12]}),
	.Store_req({Store_req[13:15],Store_req[0:12]}),
	.Select(En_out13),
	.valid(En_valid[13])
);

LS_Encoder #(.fix(4'd14)) Encoder14(
	.Load_req({Load_req[14:15],Load_req[0:13]}),
	.Store_req({Store_req[14:15],Store_req[0:13]}),
	.Select(En_out14),
	.valid(En_valid[14])
);

LS_Encoder #(.fix(4'd15)) Encoder15(
	.Load_req({Load_req[15],Load_req[0:14]}),
	.Store_req({Store_req[15],Store_req[0:14]}),
	.Select(En_out15),
	.valid(En_valid[15])
);

endmodule 

module LS_Encoder #(parameter fix = 4'd0)(
input [0:15]Load_req,
input [0:15]Store_req,
output[3:0]Select,
output valid
);

wire load_valid,store_valid;
reg[3:0] Store_Select,Load_Select;

assign load_valid=(Store_req<Load_req)&(|Load_req);
assign store_valid=(|Store_req)&Store_req[0];
assign valid=load_valid|store_valid;
assign Select=store_valid?Store_Select:Load_Select;

always@(*)
 begin
  casex(Store_req)
  16'b1xxx_xxxx_xxxx_xxxx:Store_Select<=fix;
  default:Store_Select<=4'bxxxx;
  endcase
 end
 
always@(*)
 begin
  casex(Load_req)
  16'b0000_0000_0000_0001:Load_Select=4'd15+fix;
  16'b0000_0000_0000_001x:Load_Select=4'd14+fix;
  16'b0000_0000_0000_01xx:Load_Select=4'd13+fix;
  16'b0000_0000_0000_1xxx:Load_Select=4'd12+fix;
  16'b0000_0000_0001_xxxx:Load_Select=4'd11+fix;
  16'b0000_0000_001x_xxxx:Load_Select=4'd10+fix;
  16'b0000_0000_01xx_xxxx:Load_Select=4'd09+fix;
  16'b0000_0000_1xxx_xxxx:Load_Select=4'd08+fix;
  16'b0000_0001_xxxx_xxxx:Load_Select=4'd07+fix;
  16'b0000_001x_xxxx_xxxx:Load_Select=4'd06+fix;
  16'b0000_01xx_xxxx_xxxx:Load_Select=4'd05+fix;
  16'b0000_1xxx_xxxx_xxxx:Load_Select=4'd04+fix;
  16'b0001_xxxx_xxxx_xxxx:Load_Select=4'd03+fix;  
  16'b001x_xxxx_xxxx_xxxx:Load_Select=4'd02+fix;
  16'b01xx_xxxx_xxxx_xxxx:Load_Select=4'd01+fix;
  16'b1xxx_xxxx_xxxx_xxxx:Load_Select=4'd00+fix;
  default:Load_Select=4'bxxxx;
  endcase
 end
endmodule