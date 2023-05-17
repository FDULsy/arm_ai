module cmp2 #(
    parameter DW=8
) (
    input      [DW-1 : 0] m_data,
    input                 m_valid,
    output     [DW-1 : 0] s_data,
    output reg            s_valid,


    input clk,
    input rst_n      
);


reg state;
reg [7:0] data_tmp;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= 0;
    else if(m_valid)
        state <= ~state;
    else 
        state <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_tmp <= 0;
    else if(m_valid)
        data_tmp <= m_data;
    else
        data_tmp <= data_tmp;
end

always @(posedge clk or negedge) begin
    if(!rst_n)
        s_valid <= 0;
    else if(state == 1'b1)
        s_valid <= m_valid;
end

cmp #(.DW(DW)) i_cmp(
    .data1(m_data),
    .data2(data_tmp),
    .data_out(s_data)
);
    
endmodule