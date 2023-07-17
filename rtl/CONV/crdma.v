module crdma #(parameter DW=8,
                         DW0=16,
                         DN=7,
                         IW=36,
                         IN = 3     ,
                         IFW= 7,
                         IRW = 32   ,
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

    output [AW-1:0]         ifm_addr          ,
    output                  ifm_addr_first    ,
    output                  ifm_addr_last     ,

    output                  s_read_pic_ready  ,

    output                  ifm_addr_valid0   ,
    input                   ifm_addr_ready0   ,  
    output                  ifm_addr_valid1   ,
    input                   ifm_addr_ready1   ,
    output                  ifm_addr_valid2   ,
    input                   ifm_addr_ready2   ,


    input [DW0-1 : 0]       crdma_m_data0     ,
    input                   crdma_m_first0    ,
    input                   crdma_m_last0     ,
    input                   crdma_m_valid0    ,
    output                  crdma_m_ready0    ,

    input [DN*DW-1 : 0]     crdma_m_data1     ,
    input                   crdma_m_first1    ,
    input                   crdma_m_last1     ,
    input                   crdma_m_valid1    ,
    output                  crdma_m_ready1    ,  

    input [DN*DW-1 : 0]     crdma_m_data2     ,
    input                   crdma_m_first2    ,
    input                   crdma_m_last2     ,
    input                   crdma_m_valid2    ,
    output                  crdma_m_ready2    ,  

    output [DN*DW-1 : 0]    crdma_s_data      ,
    output                  crdma_s_first     ,
    output                  crdma_s_last      ,
    output                  crdma_s_valid     ,
    output                  crdma_s_first_pre ,
    //input                 crdma_s_ready     ,

    output [54 : 0]         s_info          ,

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

inst_fetch #(.IW(36),.AW(11)) i_inst_fetch(
    .instgen_s_data(inst_m_data),
    .instgen_s_valid(inst_m_valid),
    .instgen_s_ready(inst_m_ready),
    .finish(finish),
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

conv_inst_loop #(.IRW(IRW),.IN(IN),.AW(AW)) i_inst_loop(
    .m_inst(m_local_inst),
    .m_valid(m_start_valid),
    .m_ready(m_start_ready),

    .s_inst(s_local_inst),
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
wire [1:0]     dma_dim0_step;
wire [4:0]     dma_dim1_size;
wire [6:0]     dma_dim1_step;


wire [AW-1 : 0] addr;
wire            addr_first;
wire            addr_last;
wire            addr_valid;
wire            addr_ready;

wire [54 : 0] info;

wire finish;

assign finish = s_local_inst[91] && addr_last;

assign dma_r_info = {s_local_inst[63:58],s_local_inst[0]};

assign {dma_dim1_step,dma_dim1_size,dma_dim0_step,dma_dim0_size,dma_base} = s_local_inst[43 : 9];

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

assign info = {s_local_inst[95:64],  s_local_inst[59], s_local_inst[57:44],s_local_inst[8 : 1]};


assign crdma_s_first_pre = addr_first;//3 clk period before s_data

c_rmux #(.DW0(16),.DW(DW),.DN(DN),.IFW(IFW),.AW(AW)) i_rmux(
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

    .m_data2(crdma_m_data2),
    .m_data_first2(crdma_m_first2),
    .m_data_last2(crdma_m_last2),
    .m_data_valid2(crdma_m_valid2),
    .m_data_ready2(crdma_m_ready2),

    .s_data(crdma_s_data),
    .s_data_first(crdma_s_first),
    .s_data_last(crdma_s_last),
    .s_data_valid(crdma_s_valid),
    .s_data_ready(1'b1),

    .rinfo(m_rinfo),

    .m_info(info),
    .s_info(s_info),

    .m_addr(addr),
    .m_addr_first(addr_first),
    .m_addr_last(addr_last),
    .m_addr_valid(addr_valid),
    .m_addr_ready(addr_ready),

    .s_read_pic_ready(s_read_pic_ready),

    .s_addr(ifm_addr),
    .s_addr_first(ifm_addr_first),
    .s_addr_last(ifm_addr_last),

    .s_addr_valid0(ifm_addr_valid0),
    .s_addr_ready0(ifm_addr_ready0),
    .s_addr_valid1(ifm_addr_valid1),
    .s_addr_ready1(ifm_addr_ready1),
    .s_addr_valid2(ifm_addr_valid2),
    .s_addr_ready2(ifm_addr_ready2),

    .clk(clk),
    .rst_n(rst_n)
);



    
endmodule
