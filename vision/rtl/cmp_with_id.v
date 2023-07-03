module cmp_with_id #(parameter ADDW=14)(
    input       [ADDW-1 : 0]    data1       ,
    input       [ADDW-1 : 0]    data2       ,   
    input       [2:0]           id1         , 
    input       [2:0]           id2         , 
    
    output      [ADDW-1 : 0]    small_data  ,
    output      [2:0]           small_id    
);

wire d1_is_smaller;
assign d1_is_smaller = (data1 < data2)  ?  1'b1  : 1'b0 ;
assign small_data    = (d1_is_smaller)  ?  data1 : data2;
assign small_id      = (d1_is_smaller)  ?  id1   : id2  ;
 


endmodule
