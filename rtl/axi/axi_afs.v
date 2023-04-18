module axi_frs #(parameter DW ='d64) (
    input  [DW-1 : 0] m_data,
    input             m_valid,
    output            m_ready,

    output reg [DW-1 : 0] s_data,
    output reg            s_valid,
    input                 s_ready,

    input                 clk,
    input                 rst_n
);

assign m_ready = (~s_valid) | s_ready;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_valid <= 1'b0;
    else if(m_valid == 1'b1)
        s_valid <= 1'b1;
    else if(s_ready == 1'b1)
        s_valid <= 1'b0; 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_data <= 'd0;
    else if(m_valid==1'b1 && m_ready==1'b1)
        s_data <=m_data;
end

endmodule
