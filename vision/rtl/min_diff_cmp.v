module min_diff_cmp #(parameter MODN = 30,CLAS=5,MODI=6,ADDW=14)(
    input       [1:0]               state       ,
    input       [MODN*ADDW-1 : 0]   cnt_bus     ,
    output      [2:0]               res         ,

    input                           clk         ,
    input                           rst_n
);

//localparam TH = 14'd2000;//注意ADDW不等于14时要对应修改！！！

wire [CLAS*ADDW-1 : 0] small_inmod_bus;
wire [ADDW-1 : 0] small1,small2,small3,small4,small5;
wire [2:0] smallid1,smallid2,smallid3,smallid4,smallid5;
reg               smallest_id;

genvar i;
generate
    for (i =0 ;i<CLAS ; i=i+1) begin : CLASS_LOOP
        inmod_cmp #(.MODI(MODI),.ADDW(ADDW)) i_inmod_cmp(
            .cnt_bus(cnt_bus[i*(MODI*ADDW) +: (MODI*ADDW)]),
            .small_inmod(small_inmod_bus[i*ADDW +: ADDW])
        );
    end
endgenerate

cmp_with_id #(.ADDW(ADDW)) i_cmp_with_id1(
    .data1(small_inmod_bus[0*ADDW +: ADDW]),
    .data2(small_inmod_bus[1*ADDW +: ADDW]),
    .id1(3'b001),
    .id2(3'b010),
    .small_data(small1),
    .small_id(smallid1)
);

cmp_with_id #(.ADDW(ADDW)) i_cmp_with_id2(
    .data1(small_inmod_bus[2*ADDW +: ADDW]),
    .data2(small_inmod_bus[3*ADDW +: ADDW]),
    .id1(3'b011),
    .id2(3'b100),
    .small_data(small2),
    .small_id(smallid2)
);

cmp_with_id #(.ADDW(ADDW)) i_cmp_with_id3(
    .data1(small1),
    .data2(small2),
    .id1(smallid1),
    .id2(smallid2),
    .small_data(small3),
    .small_id(smallid3)
);

cmp_with_id #(.ADDW(ADDW)) i_cmp_with_id4(
    .data1(small3),
    .data2(small_inmod_bus[4*ADDW +: ADDW]),
    .id1(smallid3),
    .id2(3'b101),
    .small_data(small4),
    .small_id(smallid4)
);

cmp_with_id #(.ADDW(ADDW)) i_cmp_with_id5(
    .data1(small4),
    .data2(14'd2000),
    .id1(smallid4),
    .id2(3'b111),
    .small_data(small5),
    .small_id(smallid5)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n || !state[1]) begin
        smallest_id <= 0;
    end
    else begin
        smallest_id <= smallid5;
    end
end
assign res = smallest_id;


endmodule