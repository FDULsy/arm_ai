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
    output            clm_addr_first,
    output            clm_addr_last,
    output            clm_addr_valid,
    input             clm_addr_ready,
    
    input [DW-1 : 0]  crdma_m_data,
    input             crdma_m_first,
    input             crdma_m_last,
    input             crdma_m_valid,
    output            crdma_m_ready,

    output [DW-1 : 0] crdma_s_data,
    output            crdma_s_first,
    output            crdma_s_last,
    output            crdma_s_valid,
    input             crdma_s_ready,

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

wire [AW-1 : 0] addr;
wire            addr_first;
wire            addr_last;
wire            addr_valid;
wire            addr_ready;

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

    .s_addr(addr),
    .s_first(addr_first),
    .s_last(addr_last),
    .s_valid(addr_valid),
    .s_ready(addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);

inter_face #(.AW(AW),.DW(DW)) i_if(
    .m_addr(addr),
    .m_addr_first(addr_first),
    .m_addr_last(addr_last),
    .m_addr_valid(addr_valid),
    .m_addr_ready(addr_ready),

    .s_addr(clm_addr),
    .s_addr_first(clm_addr_first),
    .s_addr_last(clm_addr_last),
    .s_addr_valid(clm_addr_valid),
    .s_addr_ready(clm_addr_ready),

    .m_data(crdma_m_data),
    .m_data_first(crdma_m_first),
    .m_data_last(crdma_m_last),
    .m_data_valid(crdma_m_valid),
    .m_data_ready(crdma_m_ready),

    .s_data(crdma_s_data),
    .s_data_first(crdma_s_first),
    .s_data_last(crdma_s_last),
    .s_data_valid(crdma_s_valid),
    .s_data_ready(crdma_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);


axi_frs #(.DW(IW)) i_axi_frs_inst(
    .m_data(inst_m_data),
    .m_valid(inst_m_valid),
    .m_ready(inst_m_ready),

    .s_data(inst_s_data),
    .s_valid(inst_s_valid),
    .s_ready(inst_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);


    
endmodule
