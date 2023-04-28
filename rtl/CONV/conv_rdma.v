module crdma #(parameter DW=64,
                         IW=32,
                         IN = 6     ,
                         IPW = IN*(IW-16) ,
                         ID = 4'h0 
) (
    //input [IW-1 : 0]  inst_m_data,
    //input             inst_m_valid,
    //output            inst_m_ready,

    output [IW-1 : 0] inst_s_data,
    output            inst_s_valid,
    input             inst_s_ready,

    output [AW-1:0]   clm_addr,
    
    input [DW-1 : 0]  clm_m_data,
    input             clm_m_first,
    input             clm_m_last,
    input             clm_m_valid,
    output            clm_m_ready,
    output [DW-1 : 0] clm_s_data,
    output            clm_s_valid,
    input             clm_s_ready,

    input clk,
    input rst_n
);

wire inst_m_data;
wire inst_m_valid;
wire inst_m_ready;

wire [IPW-1:0] m_local_inst;
wire [IPW-1:0] s_local_inst;
wire [1:0] start_prior;
wire m_start_valid,s_start_valid;
wire m_start_ready,s_start_ready;

inst_fetch i_inst_fetch(
    .instgen_s_data(inst_m_data),
    .instgen_s_valid(inst_m_valid),
    .instgen_s_ready(inst_m_ready),
    .clk(clk),
    .rst_n(rst_n)
);

inst_parse #(IW(IW),IN(IN),IPW(IPW),ID(ID)) i_inst_parse(
    .inst_m_data(inst_m_data),
    .inst_m_valid(inst_m_valid),
    .inst_m_ready(inst_m_ready),

    .inst_s_data(),
    .inst_s_valid(),
    .inst_s_ready()

    .local_inst(m_local_inst),
    .start_prior(start_prior),
    .start_valid(m_start_valid),
    .start_ready(m_start_ready),

    .clk(clk),
    .rst_n(rst_n)
);

axi_frs #(.DW(IPW)) i_axi_frs_local_inst(
    .m_data(m_local_inst),
    .m_valid(m_start_valid),
    .m_ready(m_start_ready),

    .s_data(s_local_inst),
    .s_valid(s_start_valid),
    .s_ready(s_start_ready),

    .clk(clk),
    .rst_n(rst_n)
);

//local_inst unpack
wire [AW-1:0] dma_base;
wire [3:0]    dma_dim0_size;
wire [3:0]    dma_dim0_step;
wire [3:0]    dma_dim1_size;
wire [3:0]    dma_dim1_step;
wire [15:0]   dma_c;
assign dma_base = s_local_inst[0*16 +: AW];
assign {dma_dim0_size,dma_dim0_step,dma_dim1_size,dma_dim1_step} = s_local_inst[1*16 +: 16];
assign dmac = s_local_inst[2*16 +: 16];

dma_dim2 #(AW(AW),IFW(0)) i_dma0(
    .base(dma_base),
    .dim0_size(dma_dim0_size),
    .dim0_step(dma_dim0_step),
    .dim1_size(dma_dim1_size),
    .dim1_step(dma_dim1_step),
    .start_valid(s_start_valid),
    .start_ready(s_start_ready),

    .s_addr()
)


axi_frs #(.DW(IW)) i_axi_frs_inst(
    .m_data(inst_m_data),
    .m_valid(inst_m_valid),
    .m_ready(inst_m_ready),

    .s_data()
)




    
endmodule
