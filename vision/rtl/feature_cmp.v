module feature_cmp(
    input   [15:0]      d1      ,
    input   [15:0]      d2      ,
    output  [3 :0]      diff    ,

    input               clk     ,
    input               rst_n
);

wire [15:0] c;
wire  [7:0]  out;
reg  [3:0]   sum;

assign c=d1^d2;
genvar i;
generate
	for (i=0;i<4;i=i+1) begin:igen
	i i_I(
		.a(c[i*4 +: 4]),
		.cnt(out[i*2 +: 2])		
	);		
	end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        sum <= 4'b0;
    else   
        sum <= out[1:0] +out[3:2] +out[5:4] +out[7:6];
end
assign diff = sum;

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