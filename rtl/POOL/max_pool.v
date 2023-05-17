module max_pool #(
    parameter DW=8,DN=6
) (
    input  [DN*DW-1 : 0] m_data,

    input                m_valid,
    input  [7:0] m_width,
    input        m_max_pool_en,

    output [DN*DW-1 : 0] s_data,
    output               s_valid,
    input                s_ready,
    
    input clk,
    input rst_n
);


    
endmodule