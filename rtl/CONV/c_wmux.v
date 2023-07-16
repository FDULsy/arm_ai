module c_wmux #(
    parameter DW=8,DN=7,AW=14
) (
    input               m_data          ,
    input               m_data_valid    ,
    output              m_data_ready    ,

    input               m_addr          ,
    input               m_addr_first    ,
    input               m_addr_last     ,
    input               m_addr_valid    ,
    output              m_addr_ready    , 

    input               ram_sel         ,  
        
    output              s_data          ,
    output              s_addr          ,
    output              s_first         ,
    output              s_last          ,

    output              s_valid1        ,
    input               s_ready1        ,
    output              s_valid2        ,
    input               s_ready2        ,
        
    input               clk             ,
    input               rst_n
);

wire [AW+DW*DN+2 : 0]   m_bus;
wire [AW+DW*DN+2 : 0]   s_bus;
wire m_valid, m_ready , s_valid, s_ready;
wire ram_sel_dly;

assign m_addr_bus={ram_sel, m_addr_first, m_addr_last, m_addr, m_data};

assign m_valid = m_data_valid && m_addr_valid;
assign m_data_ready = m_ready;
assign m_addr_ready = m_ready;

assign s_ready = ram_sel ? s_ready2 : s_ready1;

axi_frs #(.DW(AW+DW*DN+3)) i_frs_addr0(
    .m_data(m_bus),
    .m_valid(m_valid),
    .m_ready(m_ready),

    .s_data(s_bus),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
);
assign ram_sel_dly = s_bus [AW+DW*DN+2];
assign s_valid1 = ram_sel_dly ? s_valid : 0;
assign s_valid2 = ram_sel_dly ? 0:s_valid;

assign {s_first, s_last, s_addr, s_data} = s_bus[AW+DW*DN+1 :0];


endmodule