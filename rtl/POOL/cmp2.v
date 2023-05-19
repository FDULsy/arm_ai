module cmp2 #(
    parameter DW=8,DN=6
) (
    input      [DN*DW-1 : 0] m_data,
    input                    m_valid,
    output reg  [DN*DW-1 : 0] s_data,
    output reg               s_valid,


    input clk,
    input rst_n      
);


reg  state;
reg  [DN*DW-1 : 0] data_tmp;
wire [DN*DW-1 : 0] s_data_w;

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
    else if(m_valid && !state)
        data_tmp <= m_data;
    else
        data_tmp <= data_tmp;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_valid <= 0;
    else if(state)
        s_valid <= m_valid;
    else
        s_valid <= 0;
end

genvar i;
generate
    for (i =0 ;i<DN ;i=i+1 ) begin
        cmp #(.DW(DW)) i_cmp(
            .data1(   m_data[i*DW +: DW]),
            .data2( data_tmp[i*DW +: DW]),
            .data_out(s_data_w[i*DW +: DW])
        );
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_data <= 0;
    else 
        s_data <= s_data_w;
end
    
endmodule
