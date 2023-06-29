module cwdma #(parameter DW=8,DN=6,
                         AW=14,
                         IW=36,IN=1,IRW=32, IPW=IN*IRW,
                         ID=1'b1
) (
    input [IW-1:0]       inst_m_data,
    input                inst_m_valid,
    output               inst_m_ready,

    output [IW-1 : 0]    inst_s_data,
    output               inst_s_valid,
    input                inst_s_ready,

    input [DN*DW-1:0]    cwdma_m_data,
    input                cwdma_m_first,
    input                cwdma_m_last,
    input                cwdma_m_valid,
    output               cwdma_m_ready,

    output [DN*DW-1:0]   cwdma_s_data,
    output               cwdma_s_first,
    output               cwdma_s_last,
    output               cwdma_s_valid,
    input                cwdma_s_ready,

    output [AW-1:0]      ofm_addr,
    output               ofm_addr_first,
    output               ofm_addr_last,
    output               ofm_addr_valid,
    input                ofm_addr_ready,

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

wire [DN*DW+1 : 0] m_bus;
wire [DN*DW+1 : 0] s_bus;

assign m_bus = {cwdma_m_data,cwdma_m_first,cwdma_m_last};
axi_frs #(.DW(DN*DW+2)) i_frs_wdata(
    .m_data(m_bus),
    .m_valid(cwdma_m_valid),
    .m_ready(cwdma_m_ready),

    .s_data(s_bus),
    .s_valid(cwdma_s_valid),
    .s_ready(cwdma_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);
assign {cwdma_s_data, cwdma_s_first, cwdma_s_last} = s_bus;

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
wire [8:0]    dma_size;
wire [8:0]    info;

wire [AW-1 : 0] addr;
wire            addr_first;
wire            addr_last;
wire            addr_valid;
wire            addr_ready;

assign dma_base = s_local_inst[31 : 18];
assign dma_size = s_local_inst[17 : 9];
assign info = s_local_inst[8 : 0];

dma #(.AW(AW),.IFW(0),.SZW(1))i_dma(
    .base(dma_base),
    .size(dma_size),
    .step(1'b1),
    .start_valid(s_start_valid),
    .start_ready(s_start_ready),

    .s_addr(ofm_addr),
    .s_first(ofm_addr_first),
    .s_last(ofm_addr_last),
    .s_valid(ofm_addr_valid),
    .s_ready(ofm_addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);


    
endmodule