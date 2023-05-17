module cmp #(
    parameter DW=8
) (
    input  [DW-1 : 0] data1,
    input  [DW-1 : 0] data2,
    output [DW-1 : 0] data_out
);
    
assign data_out = (data1>data2)? data1 : data2;

endmodule