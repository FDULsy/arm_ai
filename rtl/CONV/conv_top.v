module conv_top #(
    parameter AW=14,DW=8,DN=8,DW0=16,IW=36,OW=22,ROW=8,COLUMN=6
) (
    //ifm0
    output [AW-1:0]      ifm_addr0,
    output               ifm_addr_first0,
    output               ifm_addr_last0,
    output               ifm_addr_valid0,
    input                ifm_addr_ready0,

    input [DN*DW-1 : 0]  ifm_data0,
    input                ifm_first0,
    input                ifm_last0,
    input                ifm_valid0,
    output               ifm_ready0,
    //===========

    //imf1
    output [AW-1:0]      ifm_addr1,
    output               ifm_addr_first1,
    output               ifm_addr_last1,
    output               ifm_addr_valid1,
    input                ifm_addr_ready1,

    input [DW0-1 : 0]    ifm_data1,
    input                ifm_first1,
    input                ifm_last1,
    input                ifm_valid1,
    output               ifm_ready1,
    //===========

    //inst
    output [IW-1 : 0]    inst_s_data,
    output               inst_s_valid,
    input                inst_s_ready,
    //===========

    //info
    output [45 : 0]      info_bus,
    //===========

    //macout
    output [COLUMN*OW-1 : 0]   macd_s_data,
    output                     macd_s_first,
    output                     macd_s_last,
    output                     macd_s_valid,
    input                      macd_s_ready,
    //===========



    input clk,
    input rst_n
);
//============================================================================



wire [DN*DW-1 : 0] crdma_data;
wire               crdma_first;
wire               crdma_last;
wire               crdma_valid;
wire               crdma_ready;

wire [DN*DW-1 : 0] mac_m_data;

wire [COLUMN*19-1 : 0] mac_s_data;
wire [COLUMN*19-1 : 0] delay_data;
wire mac_s_first;
wire mac_s_last;
wire mac_s_valid;
wire mac_s_ready;
wire [2:0] w_data_n;
wire [1:0] w_fc;

wire [2:0] mac_m_info;
wire [2:0] mac_s_info;


wire w_en;
wire [7:0] w0,w1,w2,w3,w4,w5;
wire [47:0] w;


// ifm1 i_ifm1(
//     .addra(ifm_addr1),
//     .dia(16'h0),
//     .ocea(1'b0),
//     .clka(clk),
//     .wea(1'b1),
//     .rsta(rst_n),
//     .doa(ifm_data1)
// );

// ifmram i_ifmram(
//     .addra(ifm_addr0),
//     .dia(16'h0),
//     .ocea(1'b0),
//     .clka(clk),
//     .wea(1'b1),
//     .rsta(rst_n),
//     .doa(ifm_data0)
// );

crdma #(.DW(8),.DW0(16),.DN(8),.IW(36),.IN(3),.IFW(4),.IRW(30),.IPW(120),.AW(14),.ID(1'b0)) i_crdma(
    .inst_s_data(inst_s_data),
    .inst_s_valid(inst_s_valid),
    .inst_s_ready(inst_s_ready),

    .ifm_addr0(ifm_addr0),
    .ifm_addr_first0(ifm_addr_first0),
    .ifm_addr_last0(ifm_addr_last0),
    .ifm_addr_valid0(ifm_addr_valid0),
    .ifm_addr_ready0(ifm_addr_ready0),

    .ifm_addr1(ifm_addr1),
    .ifm_addr_first1(ifm_addr_first1),
    .ifm_addr_last1(ifm_addr_last1),
    .ifm_addr_valid1(ifm_addr_valid1),
    .ifm_addr_ready1(ifm_addr_ready1),

    .crdma_m_data0(ifm_data0),
    .crdma_m_first0(ifm_first0),
    .crdma_m_last0(ifm_last0),
    .crdma_m_valid0(ifm_valid0),
    .crdma_m_ready0(ifm_ready0),

    .crdma_m_data1(ifm_data1),
    .crdma_m_first1(ifm_first1),
    .crdma_m_last1(ifm_last1),
    .crdma_m_valid1(ifm_valid1),
    .crdma_m_ready1(ifm_ready1),

    .crdma_s_data(crdma_data),
    .crdma_s_first(crdma_first),
    .crdma_s_last(crdma_last),
    .crdma_s_valid(crdma_valid),
    .crdma_s_ready(crdma_ready),

    .info_bus(info_bus),

    .clk(clk),
    .rst_n(rst_n)
);

assign w_data_n = info_bus[2:0];
assign w_fc     = info_bus[36:35];

delay_chain #(.DW(64),.DN(8)) i_datain_delay(
    .xi(crdma_data),
    .xo(mac_m_data),

    .clk(clk),
    .rst_n(rst_n)
);




weightrom i_weightrom(
    .i_last(crdma_last),
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_data_n(w_data_n),
    .i_fc(w_fc),

    .o_data_en(w_en),
    .o_data0(w0),
    .o_data1(w1),
    .o_data2(w2),
    .o_data3(w3),
    .o_data4(w4),
    .o_data5(w5)
);

assign w={w5,w4,w3,w2,w1,w0};

mac #(.DW(8),.WW(8),.CW(19),.ROW(8),.COLUMN(6),.OW(22)) i_mac(
    .mac_m_data(mac_m_data),
    .mac_m_first(crdma_first),
    .mac_m_last(crdma_last),
    .mac_m_valid(crdma_valid),
    .mac_m_ready(crdma_ready),

    .w(w),
    .w_en(w_en),
    .ci(114'h0),

    .mac_s_data(mac_s_data),
    .mac_s_first(mac_s_first),
    .mac_s_last(mac_s_last),
    .mac_s_valid(mac_s_valid),
    .mac_s_ready(mac_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign mac_m_info = {mac_s_first,mac_s_last,mac_s_valid};
delay #(.DW(3),.DLT(7)) i_info_delay(
    .xi(mac_m_info),
    .xo(mac_s_info),
    .clk(clk),
    .rst_n(rst_n)
);

assign {macd_s_first,macd_s_last,macd_s_valid} = mac_s_info;

delay #(.DW(1),.DLT(7)) i_rdy_delay(
    .xi(macd_s_ready),
    .xo(mac_s_ready),
    .clk(clk),
    .rst_n(rst_n)
);

delay_chain #(.DW(19*6),.DN(6)) i_dataout_delay(
    .xi(mac_s_data),
    .xo(delay_data),

    .clk(clk),
    .rst_n(rst_n)
);


genvar i;
generate
    for (i =0 ;i<6 ;i=i+1 ) begin:x
        assign macd_s_data[i*OW +: OW] ={{3{delay_data[i*19+18]}},delay_data[i*19 +: 19]};
    end
endgenerate
    
endmodule