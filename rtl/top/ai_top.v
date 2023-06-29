module aitop (
    input [13:0] pic_addr,
    input [15:0] pic_data,
    input        pic_ready,
    output       pic_get_finish,
    input clk,
    input rst_n,
    output [9:0] class
);
    
wire [13 : 0] ofm_addr;
wire          ofm_addr_first,ofm_addr_last;
wire          ofm_addr_valid;
wire [47 : 0] cwdma_s_data;
wire          cwdma_s_valid;

wire [22*6-1 : 0] acc_m_data;
wire acc_m_valid,acc_m_ready;
wire [45:0] info_bus;


wire [48+14-1 : 0] m_write_bus, s_write_bus;
wire [47:0]        s_write_data;
wire [13:0]        s_write_addr;
wire               m_write_valid, m_write_ready, s_wirte_valid, s_write_ready;


reg ifm_first1,ifm_last1,ifm_valid1;
wire ifm_ready1;


wire [13:0] ifm_addr0,ifm_addr1;
wire [63:0] ifm_data0,ifm_data1;
wire ifm_addr_first0,ifm_addr_last0,ifm_addr_valid0,ifm_addr_ready0;
wire ifm_addr_first1,ifm_addr_last1,ifm_addr_valid1;
wire ifm_first0,ifm_last0,ifm_valid0,ifm_ready0;
wire [35:0] inst;
wire inst_valid,inst_ready;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ifm_first1 <= 0;
        ifm_last1  <= 0;
        ifm_valid1 <= 0;
    end
    else begin
        ifm_first1 <= ifm_addr_first1;
        ifm_last1  <= ifm_addr_last1;
        ifm_valid1 <= ifm_addr_valid1;
    end
end

assign m_write_bus   = {cwdma_s_data,ofm_addr};
assign m_write_valid = ofm_addr_valid && ofm_addr_valid;
axi_frs #(.DW(48+14)) i_frs_write(
    .m_data(m_write_bus),
    .m_valid(m_write_valid),
    .m_ready(m_write_ready),

    .s_data(s_write_bus),
    .s_valid(s_wirte_valid),
    .s_ready(s_write_ready),

    .clk(clk),
    .rst_n(rst_n)
);
assign {s_write_data,s_write_addr} = s_write_bus;

picram i_picram(
    .addra(pic_addr),
    .dia(pic_data),
    .clka(clk),
    
    .addrb(ifm_addr1),
    .ceb(ifm_addr_valid1),
    .oceb(1'b1),
    .dob(ifm_data1),
    .clkb(clk),
    .rstb(rst_n)
);

fm_top i_fm(
    .w_data(s_write_data),
    .w_addr(s_write_addr),
    .w_valid(s_wirte_valid),
    .w_ready(s_write_ready),

    .r_addr(ifm_addr0),
    .r_valid(ifm_addr_valid0),
    .r_first(ifm_addr_first0),
    .r_last(ifm_addr_last0),
    .r_ready(ifm_addr_ready0),
    .r_data(ifm_data0),
    .r_data_valid(ifm_valid0),
    .r_data_first(ifm_first0),
    .r_data_last(ifm_last0),
    .r_data_ready(ifm_ready0),

    .clk(clk),
    .rst_n(rst_n)
);

assign pic_get_finish = ifm_last1;
conv_top i_convtop(
    .ifm_addr0(ifm_addr0),
    .ifm_addr_first0(ifm_addr_first0),
    .ifm_addr_last0(ifm_addr_last0),
    .ifm_addr_valid0(ifm_addr_valid0),
    .ifm_addr_ready0(ifm_addr_ready0),
    .ifm_data0(ifm_data0),
    .ifm_first0(ifm_first0),
    .ifm_last0(ifm_last0),
    .ifm_valid0(ifm_valid0),
    .ifm_ready0(ifm_ready0),

    .ifm_addr1(ifm_addr1),
    .ifm_addr_first1(ifm_addr_first1),
    .ifm_addr_last1(ifm_addr_last1),
    .ifm_addr_valid1(ifm_addr_valid1),
    .ifm_addr_ready1(pic_ready),
    .ifm_data1(ifm_data1),
    .ifm_first1(ifm_first1),
    .ifm_last1(ifm_last1),
    .ifm_valid1(ifm_valid1),
    .ifm_ready1(ifm_ready1),

    .inst_s_data(inst),
    .inst_s_valid(inst_valid),
    .inst_s_ready(inst_ready),

    .info_bus(info_bus),

    .macd_s_data(acc_m_data),
    .macd_s_first(),
    .macd_s_last(),
    .macd_s_valid(acc_m_valid),
    .macd_s_ready(acc_m_ready),
    .clk(clk),
    .rst_n(rst_n)
);






acc_top i_acctop(
.acc_m_data(acc_m_data),
.acc_m_first(),
.acc_m_last(),
.acc_m_valid(acc_m_valid),
.acc_m_ready(acc_m_ready),

.info_bus(info_bus),
.acc_s_data(acc_s_data),
.acc_s_valid(acc_s_valid),
.acc_s_ready(acc_s_ready),
.clk(clk),
.rst_n(rst_n)
);

cwdma i_cwdma(
.inst_m_data(inst),
.inst_m_valid(inst_valid),
.inst_m_ready(inst_ready),
.inst_s_data(),
.inst_s_valid(),
.inst_s_ready(),

.cwdma_m_data(acc_s_data),
.cwdma_m_first(),
.cwdma_m_last(),
.cwdma_m_valid(acc_s_valid),
.cwdma_m_ready(acc_s_ready),

.cwdma_s_data(cwdma_s_data),
.cwdma_s_first(),
.cwdma_s_last(),
.cwdma_s_valid(cwdma_s_valid),
.cwdma_s_ready(m_write_ready),

.ofm_addr(ofm_addr),
.ofm_addr_first(ofm_addr_first),
.ofm_addr_last(ofm_addr_last),
.ofm_addr_valid(ofm_addr_valid),
.ofm_addr_ready(m_write_ready),

.clk(clk),
.rst_n(rst_n)
);





endmodule