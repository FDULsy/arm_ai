//last_for_weight_ctrl 没完成
module inter_face #(parameter AW=11,DW=64
) (
    input  [AW-1 : 0]  m_addr,
    input              m_addr_first,
    input              m_addr_last,
    input              m_addr_valid,
    output             m_addr_ready,

    output [AW-1 : 0]  s_addr,
    output             s_addr_first,
    output             s_addr_last,
    output             s_addr_valid,
    input              s_addr_ready,

    input [DW-1 : 0]   m_data,
    input              m_data_first,
    input              m_data_last,
    input              m_data_valid,
    output             m_data_ready,

    output [DW-1 : 0]  s_data,
    output             s_data_first,
    output             s_data_last,
    output             s_data_valid,
    input              s_data_ready,

    output             last_for_weight_ctrl,

    input clk,
    input rst_n
); 

localparam ADDR = (AW-1)+2;
localparam DATA = (DW-1)+2;
wire [ADDR : 0] m_addr_bus;
wire [ADDR : 0] s_addr_bus;
wire [DATA : 0] m_data_bus;
wire [DATA : 0] s_data_bus;
 
assign m_addr_bus = {m_addr,m_addr_first,m_addr_last};
assign m_data_bus = {m_data,m_data_first,m_data_last};

axi_frs #(.DW(ADDR)) i_addr_frs(
    .m_data(m_addr_bus),
    .m_valid(m_addr_valid),
    .m_ready(m_addr_ready),

    .s_data(s_addr_bus),
    .s_valid(s_addr_valid),
    .s_ready(s_addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);

axi_rs #(.DW(DATA)) i_data_rs(
    .m_data(m_data_bus),
    .m_valid(m_data_valid),
    .m_ready(m_data_ready),

    .s_data(s_data_bus),
    .s_valid(s_data_valid),
    .s_ready(s_data_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign {s_addr,s_addr_first,s_addr_last} = s_addr_bus;
assign {s_data,s_data_first,s_data_last} = s_data_bus;

//last_for_weight_ctrl


    
endmodule