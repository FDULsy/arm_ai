module crdma #(parameter DW=8,
                         DW0=16,
                         DN=8,
                         IW=36,
                         IN = 3     ,
                         IFW= 4,
                         IRW = 30   ,
                         IPW = IN*IRW ,
                         AW= 14,
                         ID = 1'b0
) (
    //input [IW-1 : 0]  inst_m_data,
    //input             inst_m_valid,
    //output            inst_m_ready,

    output [IW-1 : 0]       inst_s_data       ,
    output                  inst_s_valid      ,
    input                   inst_s_ready      ,   

    output [AW-1:0]         ifm_addr0         ,
    output                  ifm_addr_first0   ,
    output                  ifm_addr_last0    ,
    output                  ifm_addr_valid0   ,
    input                   ifm_addr_ready0   ,  

    output [AW-1:0]         ifm_addr1         ,
    output                  ifm_addr_first1   ,
    output                  ifm_addr_last1    ,
    output                  ifm_addr_valid1   ,
    input                   ifm_addr_ready1   ,
    input [DN*DW-1 : 0]     crdma_m_data0     ,
    input                   crdma_m_first0    ,
    input                   crdma_m_last0     ,
    input                   crdma_m_valid0    ,
    output                  crdma_m_ready0    ,

    input [DW0-1 : 0]       crdma_m_data1     ,
    input                   crdma_m_first1    ,
    input                   crdma_m_last1     ,
    input                   crdma_m_valid1    ,
    output                  crdma_m_ready1    ,   

    output [DN*DW-1 : 0]    crdma_s_data      ,
    output                  crdma_s_first     ,
    output                  crdma_s_last      ,
    output                  crdma_s_valid     ,
    output                  crdma_s_first_pre ,
    //input                 crdma_s_ready     ,

    output [45 : 0]         info_bus          ,

    input                   clk               ,
    input                   rst_n
);

wire [IW-1:0] inst_m_data;
wire inst_m_valid;
wire inst_m_ready;

wire [IPW-1:0] m_local_inst;
wire [IPW-1:0] s_local_inst;
//wire [1:0] start_prior;
wire m_start_valid,s_start_valid;
wire m_start_ready,s_start_ready;

inst_fetch #(.IW(36),.AW(10)) i_inst_fetch(
    .instgen_s_data(inst_m_data),
    .instgen_s_valid(inst_m_valid),
    .instgen_s_ready(inst_m_ready),
    .clk(clk),
    .rst_n(rst_n)
);

inst_parse #(.IW(IW),.IN(IN),.IPW(IPW),.ID(ID)) i_inst_parse(
    .inst_m_data(inst_m_data),
    .inst_m_valid(inst_m_valid),
    .inst_m_ready(inst_m_ready),

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
wire [IFW-1:0] m_rinfo;
wire [IFW-1:0] dma_r_info;
wire [AW-1:0]  dma_base;
wire [6:0]     dma_dim0_size;
wire           dma_dim0_step;
wire [4:0]     dma_dim1_size;
wire [6:0]     dma_dim1_step;


wire [AW-1 : 0] addr;
wire            addr_first;
wire            addr_last;
wire            addr_valid;
wire            addr_ready;

wire [8:0] infop1;//11 maxen1,poolw6,reluen2,fc2
wire [9:0] infop2;//9  scale_num9
wire [28:0] infop3;//23

assign dma_r_info = s_local_inst[0*IRW+26 +: IFW];
assign dma_base = s_local_inst[0*IRW+11 +: AW];
assign infop1 = s_local_inst[0*IRW+7 +: 23];

assign {dma_dim0_size,dma_dim0_step,dma_dim1_size,dma_dim1_step} = s_local_inst[1*32+10 +: 20];
assign infop2 = s_local_inst[1*IRW+1 +: 9];
assign infop3 = s_local_inst[2*IRW+1 +: 29];
assign info_bus = {infop1,infop2,infop3,dma_r_info[2:0]};


dma_dim2 #(.AW(AW),.IFW(IFW)) i_dma0(
    .base(dma_base),
    .dim0_size(dma_dim0_size),
    .dim0_step(dma_dim0_step),
    .dim1_size(dma_dim1_size),
    .dim1_step(dma_dim1_step),
    .m_info(dma_r_info),
    .start_valid(s_start_valid),
    .start_ready(s_start_ready),

    .s_addr(addr),
    .s_info(m_rinfo),
    .s_first(addr_first),
    .s_last(addr_last),
    .s_valid(addr_valid),
    .s_ready(addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign crdma_s_first_pre = addr_first;

rmux #(.DW0(16),.DW(8),.DN(8),.IFW(IFW),.AW(AW)) i_rmux(
    .m_data0(crdma_m_data0),
    .m_data_first0(crdma_m_first0),
    .m_data_last0(crdma_m_last0),
    .m_data_valid0(crdma_m_valid0),
    .m_data_ready0(crdma_m_ready0),

    .m_data1(crdma_m_data1),
    .m_data_first1(crdma_m_first1),
    .m_data_last1(crdma_m_last1),
    .m_data_valid1(crdma_m_valid1),
    .m_data_ready1(crdma_m_ready1),

    .s_data(crdma_s_data),
    .s_data_first(crdma_s_first),
    .s_data_last(crdma_s_last),
    .s_data_valid(crdma_s_valid),
    .s_data_ready(1'b1),

    .info(m_rinfo),

    .m_addr(addr),
    .m_addr_first(addr_first),
    .m_addr_last(addr_last),
    .m_addr_valid(addr_valid),
    .m_addr_ready(addr_ready),

    .s_addr0(ifm_addr0),
    .s_addr_first0(ifm_addr_first0),
    .s_addr_last0(ifm_addr_last0),
    .s_addr_valid0(ifm_addr_valid0),
    .s_addr_ready0(ifm_addr_ready0),

    .s_addr1(ifm_addr1),
    .s_addr_first1(ifm_addr_first1),
    .s_addr_last1(ifm_addr_last1),
    .s_addr_valid1(ifm_addr_valid1),
    .s_addr_ready1(ifm_addr_ready1),

    .clk(clk),
    .rst_n(rst_n)
);



    
endmodule
