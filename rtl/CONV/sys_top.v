module sys_top #(parameter AW=14,DW=8,DN=8,DW0=16,IW=36,OW=22,ROW=8,COLUMN=6)
 (
    input clk,
    input rst_n,

    output macd_s_first,
    output [COLUMN*OW-1 : 0] macd_s_data
);

    wire [AW-1:0]   ifm_addr0;
    wire            ifm_addr_first0;
    wire            ifm_addr_last0;
    wire            ifm_addr_valid0;
    wire            ifm_addr_ready0;
    wire [DN*DW-1 : 0]  ifm_data0 ;
    wire                ifm_first0;
    wire                ifm_last0;
    wire                ifm_valid0;
    wire                ifm_ready0;
    wire [AW-1:0]   ifm_addr1;
    wire            ifm_addr_first1;
    wire            ifm_addr_last1;
    wire            ifm_addr_valid1;
    wire            ifm_addr_ready1;
    wire[DW0-1 : 0] ifm_data1;
    wire            ifm_first1;
    wire            ifm_last1;
    wire            ifm_valid1;
    wire            ifm_ready1;
    wire[IW-1 : 0] inst_s_data;
    wire           inst_s_valid;
    wire           inst_s_ready;
    wire [50 : 0]   info_bus;
    //wire [COLUMN*OW-1 : 0]   macd_s_data;
    //wire                     macd_s_first;
    wire                     macd_s_last;
    wire                     macd_s_valid;
    wire                     macd_s_ready;


conv_top #(.AW(14),.DW(8),.DN(8),.DW0(16),.IW(36),.OW(22),.ROW(8),.COLUMN(6)) I_C(
    .ifm_addr0(ifm_addr0),
    .ifm_addr_first0(ifm_addr_first0),
    .ifm_addr_last0(ifm_addr_last0),
    .ifm_addr_valid0(ifm_addr_valid0),
    .ifm_addr_ready0(ifm_addr_ready0),
    .ifm_data0 (ifm_data0 ),
    .ifm_first0(ifm_first0),
    .ifm_last0(ifm_last0),
    .ifm_valid0(ifm_valid0),
    .ifm_ready0(ifm_ready0),
    .ifm_addr1(ifm_addr1),
    .ifm_addr_first1(ifm_addr_first1),
    .ifm_addr_last1(ifm_addr_last1),
    .ifm_addr_valid1(ifm_addr_valid1),
    .ifm_addr_ready1(ifm_addr_ready1),
    .ifm_data1(ifm_data1),
    .ifm_first1(ifm_first1),
    .ifm_last1(ifm_last1),
    .ifm_valid1(ifm_valid1),
    .ifm_ready1(ifm_ready1),
    .inst_s_data(inst_s_data),
    .inst_s_valid(inst_s_valid),
    .inst_s_ready(inst_s_ready),
    .info_bus(info_bus),
    .macd_s_data(macd_s_data),
    .macd_s_first(macd_s_first),
    .macd_s_last(macd_s_last),
    .macd_s_valid(macd_s_valid),
    .macd_s_ready(macd_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);

    
endmodule