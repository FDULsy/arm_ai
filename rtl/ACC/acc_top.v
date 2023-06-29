module acc_top(
    input [22*6-1 : 0] acc_m_data,
    input              acc_m_first,
    input              acc_m_last,
    input              acc_m_valid,
    output             acc_m_ready,

    input [45:0]       info_bus,


    output [47:0]      acc_s_data,
    output             acc_s_valid,
    input              acc_s_ready,

    input clk,
    input rst_n

);


wire [22*6-1 : 0] m_data2,m_data3;
wire m_ready;
wire [9:0] base2,size;
wire start,first_k,last_k;
wire [9:0] m_addr2,m_addr3;

wire [22*6-1 : 0] acc_sum;
wire              acc_valid;
wire [22*6-1 : 0] final_sum;
wire              final_valid;

wire [4:0] n;
wire [8:0] scale_data;
wire [53:0] m_scale_data;
wire [1:0] relu_en;
wire [47:0] s_scale_data;
wire scale_data_valid;

wire [5:0] pool_width;
wire pool_en;

//info unpack
assign base2=info_bus[25:17];
assign size=info_bus[16:8];
assign n=info_bus[7:3];
assign scale_data=info_bus[34:26];
assign relu_en=info_bus[38:37];
assign pool_width=info_bus[44:39];
assign pool_en=info_bus[45];



bias_ram i_biasram_top(
    .addr(m_addr2[8:0]),
    .do(m_data2),
    .clk(clk),
    .rst_n(rst_n)
);

conv_acc i_convacc(
    .m_data1(acc_m_data),
    .m_valid1(acc_m_valid),
    .m_data2(m_data2),
    .m_data3(m_data3),
    .m_ready(m_ready),
    .base2(base2),
    .size(size),
    .start(start),
    .first_k(first_k),
    .last_k (last_k ),
    .m_addr2(m_addr2),
    .m_addr3(m_addr3),
    .m_sum(acc_sum),
    .m_valid(acc_valid),
    .s_sum(final_sum),
    .s_valid(final_valid),

    .clk(clk),
    .rst_n(rst_n)
);

acc_ram i_accramtop(
    .addr(m_addr3),
    .datai(acc_sum),
    .valid(acc_valid),
    .datao(m_data3),
    .clk(clk),
    .rst_n(rst_n)
);

assign scale_data_bus={6{scale_data}};

scale i_scale(
    .m_data1(final_sum),
    .m_valid1(final_valid),
    .m_data2(m_scale_data),
    .n(n),
    .relu_en(relu_en),
    .s_data(s_scale_data),
    .s_valid(scale_data_valid),
    .clk(clk),
    .rst_n(rst_n)
);



max_pool i_maxpool(
    .m_data(s_scale_data),
    .m_valid(scale_data_valid),
    .m_width(pool_width),
    .m_max_pool_en(pool_en),
    .s_data(acc_s_data),
    .s_valid(acc_s_valid),
    .s_ready(acc_s_ready),
    .clk(clk),
    .rst_n(rst_n)
);

endmodule