module inmod_cmp #(
    parameter MODI=6,ADDW=14
) (
    input       [MODI*ADDW-1 : 0]   cnt_bus     ,
    //input       [2:0]               id_in       ,
    output      [ADDW-1 : 0]        small_inmod 
    //output      [2:0]               id          ,
);

wire [ADDW-1 : 0] small1,small2,small3,small4;

cmp #(.ADDW(ADDW)) i_cmp_11(
    .data1(cnt_bus[0*ADDW +: ADDW]),
    .data2(cnt_bus[1*ADDW +: ADDW]),
    .small_data(small1)
);

cmp #(.ADDW(ADDW)) i_cmp_12(
    .data1(cnt_bus[2*ADDW +: ADDW]),
    .data2(cnt_bus[3*ADDW +: ADDW]),
    .small_data(small2)
);

cmp #(.ADDW(ADDW)) i_cmp_13(
    .data1(cnt_bus[4*ADDW +: ADDW]),
    .data2(cnt_bus[5*ADDW +: ADDW]),
    .small_data(small3)
);

cmp #(.ADDW(ADDW)) i_cmp_21(
    .data1(small1),
    .data2(small2),
    .small_data(small4)
);

cmp #(.ADDW(ADDW)) i_cmp_31(
    .data1(small3),
    .data2(small4),
    .small_data(small_inmod)
);
//assign id = id_in;
endmodule