module cwdma #(parameter DW=8,DN=7,
                         AW=14,
                         IW=36,IN=1,IRW=32, IPW=IN*IRW,
                         ID=1'b1
) (
    input [IW-1:0]       inst_m_data    ,
    input                inst_m_valid   ,
    output               inst_m_ready   ,

    input [DN*DW-1:0]    cwdma_m_data   ,
    input                cwdma_m_valid  ,
    output               cwdma_m_ready  ,

    output [DN*DW-1:0]   cwdma_s_data   ,

    output [AW-1:0]      ofm_addr       ,
    output               ofm_addr_first ,
    output               ofm_addr_last  ,

    output               ofm_addr_valid1,
    input                ofm_addr_ready1,
    output               ofm_addr_valid2,
    input                ofm_addr_ready2,

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



//local_inst unpack
wire [AW-1:0] dma_base;
wire [8:0]    dma_size;
wire [8:0]    info;

wire [AW-1 : 0] addr;
wire            addr_first;
wire            addr_last;
wire            addr_valid;
wire            addr_ready;

assign ram_sel = s_local_inst[23];
assign dma_size = s_local_inst[22 : 14];
assign info     = s_local_inst[8 : 0];

dma #(.AW(AW),.IFW(0),.SZW(9),.STW(1))i_dma(
    .base(dma_base),
    .size(dma_size),
    .step(1'b1),
    .start_valid(s_start_valid),
    .start_ready(s_start_ready),

    .s_addr(s_addr),
    .s_first(s_addr_first),
    .s_last(s_addr_last),
    .s_valid(s_addr_valid),
    .s_ready(s_addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);

c_wmux i_cwmux(
    .m_data         (cwdma_m_data   ),  
    .m_data_valid   (cwdma_m_valid  ),  
    .m_data_ready   (cwdma_m_ready  ),  
    .m_addr         (s_addr         ),  
    .m_addr_first   (s_addr_first   ),  
    .m_addr_last    (s_addr_last    ),  
    .m_addr_valid   (s_addr_valid   ),  
    .m_addr_ready   (s_addr_ready   ),  
    .ram_sel        (ram_sel        ),  
    .s_data         (cwdma_s_data   ),  
    .s_addr         (ofm_addr       ),  
    .s_first        (ofm_addr_first ),  
    .s_last         (ofm_addr_last  ),  
    .s_valid1       (ofm_addr_valid1),  
    .s_ready1       (ofm_addr_ready1),  
    .s_valid2       (ofm_addr_valid2),  
    .s_ready2       (ofm_addr_ready2),  
    .clk            (clk),  
    .rst_n          (rst_n)
);



endmodule