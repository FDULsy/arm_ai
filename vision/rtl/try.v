module xor_cnt( 
input [127:0] a,
input [127:0] b,
output   [6:0] num
 );
 
wire [127:0] c;  
wire [32*2-1 : 0] out;
assign c=a^b;

genvar i;
generate
	for (i=0;i<32;i=i+1) begin:igen
	i i_I(
		.a(c[i*4 +: 4]),
		.cnt(out[i*2 +: 2])		
	);		
	end
endgenerate
assign num = out[1:0] + out[3:2] +out[5:4] +out[7:6] +out[9:8] +out[11:10] +out[13:12]+out[15:14]+out[17:16]+out[19:18]+out[21:20]+out[23:22]+out[25:24]+out[27:26]+out[29:28]+out[31:30]+
out[33:32] + out[35:34] +out[37:36] +out[39:38] +out[41:40] +out[43:42] +out[45:44]+out[47:46]+out[49:48]+out[51:50]+out[53:52]+out[55:54]+out[57:56]+out[59:58]+out[61:60]+out[63:62];


endmodule


module i(
input [3:0] a,
output reg [1:0] cnt
);

always@(*) begin
	case(a)
		0:cnt=0;	
		1,2,4,8:cnt=1;		
		3,5,6,9,10,12:cnt=2;		
		7,11,13,14:cnt=3;		
		15:cnt=4;		
	endcase		
end	

endmodule