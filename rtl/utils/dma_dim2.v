module dma_dim2 #(parameter AW=14 ,IFW=4, SZW0=7, STW0=1, SZW1=5, STW1=7   //IFW:INFO wedth
) (
    input [AW-1:0]    base,
    input [SZW0-1 : 0]  dim0_size,
    input [STW0-1 : 0]  dim0_step,
    input [SZW1-1 : 0]  dim1_size,
    input [STW1-1 : 0]  dim1_step,
    input [IFW-1 : 0]   m_info,
    input        start_valid,
    output       start_ready,

    output [AW-1:0]    s_addr,
    output [IFW-1 : 0] s_info,
    output             s_first,
    output             s_last,
    output             s_valid,
    input              s_ready,
    
    input  clk,
    input rst_n
);

localparam IFW1 = IFW+SZW0+STW0 ;
localparam IFW0 = IFW+2 ;

wire [AW-1:0] lp1_addr;
wire lp1_first;
wire lp1_last;
wire lp1_valid;
wire lp1_ready;
wire [IFW1-1:0] info1;
wire [IFW1-1:0] lp1_info;

wire [AW-1:0] lp0_base;
wire [SZW0-1 : 0] lp0_size;
wire [STW0-1 : 0] lp0_step;
wire lp0_first;
wire lp0_last;
wire lp0_valid;
wire lp0_ready;
wire [IFW0-1:0] info0;
wire [IFW0-1:0] lp0_info;

wire [IFW-1 : 0] info_pass0;


assign info1 = {m_info, dim0_size, dim0_step};
assign lp1_ready=lp0_ready;


dma #(.AW(AW),.IFW(IFW1),.SZW(SZW1),.STW(STW1)) i_dma_lp1(
    .base(base),
    .size(dim1_size),
    .step(dim1_step),
    .info(info1),
    .start_valid(start_valid),
    .start_ready(start_ready),

    .s_addr(lp1_addr),
    .s_info(lp1_info),
    .s_first(lp1_first),
    .s_last(lp1_last),
    .s_valid(lp1_valid),
    .s_ready(lp1_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign lp0_base  = lp1_addr;
assign lp0_valid = lp1_valid;
assign {info_pass0, lp0_size,lp0_step} = lp1_info;
assign info0 = {info_pass0, lp1_first,lp1_last};

dma #(.AW(AW),.IFW(IFW0),.SZW(SZW0),.STW(STW0)) i_dma_lp0(
    .base(lp0_base),
    .size(lp0_size),
    .step(lp0_step),
    .info(info0),
    .start_valid(lp0_valid),
    .start_ready(lp0_ready),

    .s_addr(s_addr),
    .s_info(lp0_info),
    .s_first(lp0_first),
    .s_last(lp0_last),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
);


assign s_info=lp0_info[2 +: IFW];
assign s_first=lp0_info[1] & lp0_first;
assign s_last=lp0_info[0] & lp0_last;


endmodule
