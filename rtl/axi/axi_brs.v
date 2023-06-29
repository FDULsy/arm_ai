module axi_brs #(parameter DW='d64) (
    input  [DW-1 : 0] m_data,
    input             m_valid,
    output            m_ready,

    output  [DW-1 : 0] s_data,
    output             s_valid,
    input                 s_ready,

    input                 clk,
    input                 rst_n
);

reg valid_tmp;
reg [DW-1 : 0] data_tmp;
reg ready_tmp;

assign s_valid = valid_tmp | m_valid;
assign m_ready = ~valid_tmp | ready_tmp;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_tmp <= 1'b0;
    else if(m_valid ==1'b1 && s_ready==1'b0 && valid_tmp==1'b0)
        valid_tmp <= 1'b1;
    else if(s_ready == 1'b1)
        valid_tmp <= 1'b0;
end        

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ready_tmp <= 0;
    else 
        ready_tmp <= s_ready;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_tmp <= 'd0;
    else if(m_valid == 1'b1 && valid_tmp==1'b0)
        data_tmp <= m_data; 
end
assign s_data = (valid_tmp==1'b1) ? data_tmp:m_data;

    
endmodule
