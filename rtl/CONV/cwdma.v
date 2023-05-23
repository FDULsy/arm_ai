module cwdma #(parameter DW=144,AW=11,
                         IW=32,IN=4,IPW=IN*(IW-16),
                         ID=4'h1
) (
    input [IW-1:0]  inst_m_data,
    input           inst_m_valdi,
    output          inst_m_ready,

    output [IW-1 : 0] inst_s_data,
    output            inst_s_valid,
    input             inst_s_ready,

    input [DW-1:0]    cwdma_m_data,
    input             cwdma_m_first,
    input             cwdma_m_last,
    input             cwdma_m_valid,
    output            cwdma_m_ready,

    output [DW-1:0]   cwdma_s_data,
    output            cwdma_s_first,
    output            cwdma_s_last,
    output            cwdma_s_valid,
    input             cwdma_s_ready,

    output [AW-1:0]   ofm_addr,
    output            ofm_addr_first,
    output            ofm_addr_last,
    output            ofm_addr_valid,
    input             ofm_addr_ready,

    input clk,
    input rst_n
);

wire [IW-1:0] inst_s0_data;
wire          inst_s0_valid;
wire          inst_s0_ready;

wire [IPW-1:0] m_local_inst;
wire [IPW-1:0] s_local_inst;
//wire [1:0] start_prior;
wire m_start_valid,s_start_valid;
wire m_start_ready,s_start_ready;

axi_brs #(.DW(IW)) (
    .m_data(inst_m_data),
    .m_valid(inst_m_valid),
    .m_ready(inst_m_ready),

    .s_data(inst_s0_data),
    .s_valid(inst_s0_valid),
    .s_ready(inst_s0_ready),

    .clk(clk),
    .rst_n(rst_n)
);

inst_parse #(.IW(IW),.IN(IN),.IPW(IPW),.ID(ID)) i_inst_parse(
    .inst_m_data(inst_s0_data),
    .inst_m_valid(inst_s0_valid),
    .inst_m_ready(inst_s0_ready),

    .inst_s_data(inst_s_data),
    .inst_s_valid(inst_s_valid),
    .inst_s_ready(inst_s_ready),

    .local_inst(m_local_inst),
    //.start_prior(start_prior),
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

dma_dim2 #(.AW(AW),.IFW(0)) i_dma0(
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

    .s_addr(ofm_addr),
    .s_addr_first(ofm_addr_first),
    .s_addr_last(ofm_addr_last),
    .s_addr_valid(ofm_addr_valid),
    .s_addr_ready(ofm_addr_ready),

    .m_data(cwdma_m_data),
    .m_data_first(cwdma_m_first),
    .m_data_last(cwdma_m_last),
    .m_data_valid(cwdma_m_valid),
    .m_data_ready(cwdma_m_ready),

    .s_data(cwdma_s_data),
    .s_data_first(cwdma_s_first),
    .s_data_last(cwdma_s_last),
    .s_data_valid(cwdma_s_valid),
    .s_data_ready(cwdma_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);



    
endmodule