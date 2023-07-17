module acc_top(
    input   [26*7-1 : 0]    acc_m_data      ,
    input                   acc_m_first     ,
    input                   acc_m_last      ,
    input                   acc_m_valid     ,
    input                   acc_m_valid_pre ,

    input                   acc_m_start     ,
    input                   acc_m_fc        ,
    input   [8      : 0]    acc_m_base      , 
    input   [8      : 0]    acc_m_size      ,

    input   [27 : 0]        acc_m_info      ,

    output [47:0]           acc_s_data      ,
    output                  acc_s_valid     ,
    input                   acc_s_ready     ,

    //AHBlite interface
    input  wire             HCLK     ,    
    input  wire             HRESETn  , 
    input  wire             HSEL     ,    
    input  wire   [31:0]    HADDR    ,   
    input  wire   [ 1:0]    HTRANS   ,  
    input  wire   [ 2:0]    HSIZE    ,   
    input  wire   [ 3:0]    HPROT    ,   
    input  wire             HWRITE   ,  
    input  wire   [31:0]    HWDATA   ,   
    input  wire             HREADY   , 
    output wire             HREADYOUT, 
    output wire   [31:0]    HRDATA   ,
    output wire             HRESP    ,
    //M0 interrupt interface
    output wire             AI_IRQ   ,

    input clk,
    input rst_n

);

wire [26*7-1 : 0] m_data2, m_data3;
wire [8      : 0] m_addr2, m_addr3, m_w_addr;
wire [26*7-1 : 0] acc_sum, final_sum;
wire              acc_valid, final_valid;

wire [24 : 0]       m_scale_ctrl;
wire [8  : 0]       s_scale_ctrl;
wire [8*7-1 : 0]    s_scale_data;
wire                scale_data_valid;

biasram_tmp i_biasram(
    .doa(m_data2),
    .dia('h10),
    .addra(m_addr2),
    .clka(clk),
    .wea(1'b0),
    .rsta(rst_n)
);

accram_tmp i_accram(
    .dia(acc_sum),
    .addra(m_w_addr),
    .cea(acc_valid),
    .clka(clk),

    .dob(m_data3),
    .addrb(m_addr3),
    .clkb(clk),
    .rstb(rst_n)
);

conv_acc i_convacc(
    .m_data1        (acc_m_data     ),
    .m_first        (acc_m_first    ),
    .m_last         (acc_m_last     ),
    .m_valid1       (acc_m_valid    ),
    .m_valid1_pre   (acc_m_valid_pre),

    .m_data2        (m_data2        ),
    .m_data3        (m_data3        ),

    .start          (acc_m_start    ),
    .fc             (acc_m_fc       ),
    .base           (acc_m_base     ),
    .size           (acc_m_size     ),
    .m_ctrl         (acc_m_info     ),
    .s_ctrl         (m_scale_ctrl   ),
    
    .m_addr2        (m_addr2        ),
    .m_addr3        (m_addr3        ),
    .m_w_addr       (m_w_addr       ),
    .m_sum          (acc_sum        ),
    .m_valid        (acc_valid      ),
    .s_sum          (final_sum      ),
    .s_valid        (final_valid    ),

    .clk(clk),
    .rst_n(rst_n)
);

scale i_scale(
    .m_data1    (final_sum),
    .m_valid1   (final_valid),
    .m_ctrl     (m_scale_ctrl),

    .s_ctrl     (s_scale_ctrl),
    .s_data     (s_scale_data),
    .s_valid    (scale_data_valid),
    .clk        (clk),
    .rst_n      (rst_n)
);

max_pool i_maxpool(
    .m_data (s_scale_data),
    .m_valid(scale_data_valid),
    .m_ctrl (s_scale_ctrl),

    .s_data (acc_s_data),
    .s_valid(acc_s_valid),
    .s_ready(acc_s_ready),
    .HCLK       (HCLK     ),
    .HRESETn    (HRESETn  ),
    .HSEL       (HSEL     ),
    .HADDR      (HADDR    ),
    .HTRANS     (HTRANS   ),
    .HSIZE      (HSIZE    ),
    .HPROT      (HPROT    ),
    .HWRITE     (HWRITE   ),
    .HWDATA     (HWDATA   ),
    .HREADY     (HREADY   ),
    .HREADYOUT  (HREADYOUT),
    .HRDATA     (HRDATA   ),
    .HRESP      (HRESP    ),
    .AI_IRQ     (AI_IRQ   ),

    .clk(clk),
    .rst_n(rst_n)
);

endmodule