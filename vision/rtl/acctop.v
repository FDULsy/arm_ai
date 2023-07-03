module acc_top #(parameter MODN = 30,ADDW=14)(
    input       [1:0]           state       ,
    input       [1:0]           state_r3    ,
    input       [MODN*4-1  : 0] diff_bus    ,
    output      [MODN*ADDW-1 : 0] cnt_bus   ,

    input                       clk         ,
    input                       rst_n       
);

//localparam EW = 14-ADDW;

wire [MODN*14-1 : 0] sum_w1;
reg [MODN*ADDW-1 : 0] sum_r;

genvar i;
generate
    for (i =0 ;i<MODN ;i=i+1 ) begin
        acc i_acc(
            .data(diff_bus[i*4 +: 4]),
            .p_sum(sum_r[i*14 +: 14]),
            .sum(sum_w1[i*14 +: 14])
        );

        //assign sum_w2[i*ADDW +: ADDW] = sum_w1[14 : EW];
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n || (state==2'b00) || (state == 2'b01 && state_r3 == 2'b11))
        sum_r <= 0 ;
    else 
        sum_r <= sum_w1;
end
assign cnt_bus = sum_r;

endmodule