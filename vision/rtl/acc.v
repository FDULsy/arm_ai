module acc (
    input   [3:0]   data    ,
    input   [13:0]  p_sum    ,
    output  [13:0]  sum     
);

wire [13:0] add1;

assign add1={10'b0,data};
assign sum=add1 + p_sum;


endmodule