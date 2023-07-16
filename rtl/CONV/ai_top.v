module ai_top #(parameter AW=14,DW=8,DN=7,DW0=16,IW=36,OW=22,ROW=7,COLUMN=7)
 (
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
    output  reg             AI_IRQ   ,

    input clk,
    input rst_n
);


wire [AW-1 : 0] ifm_addr;
wire ifm_addr_first, ifm_addr_last;
wire ifm_addr_valid0, ifm_addr_ready0, ifm_addr_valid1, ifm_addr_ready1, ifm_addr_valid2, ifm_addr_ready2;         

wire [DW0-1 : 0] crdma_m_data0;
wire [DN*DW-1 : 0] crdma_m_data1, crdma_m_data2;
wire crdma_m_first0, crdma_m_last0, crdma_m_valid0, crdma_m_ready0;
wire crdma_m_first1, crdma_m_last1, crdma_m_valid1, crdma_m_ready1;
wire crdma_m_first2, crdma_m_last2, crdma_m_valid2, crdma_m_ready2;

wire [DN*DW-1 : 0] crdma_s_data;
wire crdma_s_first, crdma_s_last, crdma_s_valid, crdma_s_first_pre;

wire [54 : 0] s_info;

wire [IW-1 : 0]  inst_s_data;
wire inst_s_valid, inst_s_ready;




crdma i_crdma(
    .inst_s_data        (inst_s_data        ),
    .inst_s_valid       (inst_s_valid       ),
    .inst_s_ready       (inst_s_ready       ),
    .ifm_addr           (ifm_addr           ),
    .ifm_addr_first     (ifm_addr_first     ),
    .ifm_addr_last      (ifm_addr_last      ),

    .ifm_addr_valid0    (ifm_addr_valid0    ),
    .ifm_addr_ready0    (ifm_addr_ready0    ),
    .ifm_addr_valid1    (ifm_addr_valid1    ),
    .ifm_addr_ready1    (ifm_addr_ready1    ),
    .ifm_addr_valid1    (ifm_addr_valid2    ),
    .ifm_addr_ready1    (ifm_addr_ready2    ),

    .crdma_m_data0      (crdma_m_data0      ),
    .crdma_m_first0     (crdma_m_first0     ),
    .crdma_m_last0      (crdma_m_last0      ),
    .crdma_m_valid0     (crdma_m_valid0     ),
    .crdma_m_ready0     (crdma_m_ready0     ),
    .crdma_m_data1      (crdma_m_data1      ),
    .crdma_m_first1     (crdma_m_first1     ),
    .crdma_m_last1      (crdma_m_last1      ),
    .crdma_m_valid1     (crdma_m_valid1     ),
    .crdma_m_ready1     (crdma_m_ready1     ),
    .crdma_m_data2      (crdma_m_data2      ),
    .crdma_m_first2     (crdma_m_first2     ),
    .crdma_m_last2      (crdma_m_last2      ),
    .crdma_m_valid2     (crdma_m_valid2     ),
    .crdma_m_ready2     (crdma_m_ready2     ),


    .crdma_s_data       (crdma_s_data       ),
    .crdma_s_first      (crdma_s_first      ),
    .crdma_s_last       (crdma_s_last       ),
    .crdma_s_valid      (crdma_s_valid      ),
    .crdma_s_first_pre  (crdma_s_first_pre  ),
  
    .s_info             (s_info             ),     
    .clk                (clk                ),        
    .rst_n              (rst_n              )
);

wire        weight_start, weight_clear, weight_valid;
wire [6:0]  weight_size;
wire [8*49-1 : 0] weight_data; 


wire [55 : 0] mac_m_data    ;
wire x_first, x_last, x_valid;
wire [19*7-1 : 0] mac_s_data;

wire [26*7-1 : 0] acc_m_data1;
wire acc_m_valid, acc_m_valid_pre, acc_m_first ,acc_m_last;
wire acc_m_start,acc_m_fc;
wire [8:0] acc_m_base, acc_m_size ;
wire [27:0] acc_m_info;

distributer i_distributer(
    .m1_data        (crdma_s_data           ),
    .m1_first       (crdma_s_first          ),
    .m1_last        (crdma_s_last           ),
    .m1_valid       (crdma_s_valid          ),
    .m1_first_pre   (crdma_s_first_pre      ),
    .m1_info        (s_info                 ),

    .s1_data        (x_data                 ),
    .s1_start       (w_start                ),
    .s1_size        (w_size                 ),
    .s1_clear       (w_clear                ),

    .m2_data        (mac_s_data             ),

    .s2_data        (acc_m_data1            ),
    .s2_info        (acc_m_info             ),
    .s2_valid       (acc_m_valid            ),
    .s2_valid_pre   (acc_m_valid_pre        ),
    .s2_first       (acc_m_first            ),
    .s2_last        (acc_m_last             ),
    .s2_start       (acc_m_start            ),
    .s2_fc          (acc_m_fc               ),
    .s2_base        (acc_m_base             ),
    .s2_size        (acc_m_size             ),
    .clk            (clk                    ),
    .rst_n          (rst_n                  )
);

weightrom i_weightrom(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .fc_start       (weight_start   ),
    .fc_clear       (weight_clear   ),
    .fc_accu_num    (weight_size    ),
    .data_valid     (weight_valid   ),
    .weight_data    (weight_data    )
);

mac i_mac(
    .mac_m_data     (mac_m_data     ),
    .w              (weight_data    ),
    .w_en           (weight_valid   ),
    .ci             ('h0            ),
    .mac_s_data     (mac_s_data     ),
    .clk            (clk            ),
    .rst_n          (rst_n          )
);

wire [DW*DN-1 : 0] acc_s_data;
wire acc_s_valid, acc_s_ready;


acc_top i_acc_top(
    .acc_m_data     (acc_m_data1        ),
    .acc_m_first    (acc_m_first        ),
    .acc_m_last     (acc_m_last         ),
    .acc_m_valid    (acc_m_valid        ),
    .acc_m_valid_pre(acc_m_valid_pre    ),
    .acc_m_start    (acc_m_start        ),
    .acc_m_fc       (acc_m_fc           ),
    .acc_m_base     (acc_m_base         ),
    .acc_m_size     (acc_m_size         ),
    .acc_m_info     (acc_m_info         ),
    .acc_s_data     (acc_s_data         ),
    .acc_s_valid    (acc_s_valid        ),
    .acc_s_ready    (acc_s_ready        ),
    .HCLK           (HCLK               ),
    .HRESETn        (HRESETn            ),
    .HSEL           (HSEL               ),
    .HADDR          (HADDR              ),
    .HTRANS         (HTRANS             ),
    .HSIZE          (HSIZE              ),
    .HPROT          (HPROT              ),
    .HWRITE         (HWRITE             ),
    .HWDATA         (HWDATA             ),
    .HREADY         (HREADY             ),
    .HREADYOUT      (HREADYOUT          ),
    .HRDATA         (HRDATA             ),
    .HRESP          (HRESP              ),
    .AI_IRQ         (AI_IRQ             ),

    .clk            (clk),
    .rst_n          (rst_n)
);


wire [DW*DN-1 : 0] cwdma_s_data;
wire cwdma_s_valid,cwdma_s_ready;
wire [AW-1 : 0] ofm_addr;
wire ofm_addr_first,ofm_addr_last;
wire ofm_addr_valid1, ofm_addr_valid2, ofm_addr_ready1, ofm_addr_ready2;
cwdma i_cwdma(
    .inst_m_data        (inst_s_data    ),
    .inst_m_valid       (inst_s_valid   ),
    .inst_m_ready       (inst_s_ready   ),
    .cwdma_m_data       (acc_s_data     ),
    .cwdma_m_valid      (acc_s_valid    ),
    .cwdma_m_ready      (acc_s_ready    ),
    .cwdma_s_data       (cwdma_s_data   ),
    .ofm_addr           (ofm_addr       ),
    .ofm_addr_first     (ofm_addr_first ),
    .ofm_addr_last      (ofm_addr_last  ),
    .ofm_addr_valid1    (ofm_addr_valid1),
    .ofm_addr_ready1    (ofm_addr_ready1),
    .ofm_addr_valid2    (ofm_addr_valid2),
    .ofm_addr_ready2    (ofm_addr_ready2),
    .clk                (clk            ),
    .rst_n              (rst_n          )
);

ram1 i_ram1(
    //r口
    .r_addr             (ifm_addr       ),
    .r_addr_first       (ifm_addr_first ),
    .r_addr_last        (ifm_addr_last  ),
    .r_addr_valid       (ifm_addr_valid1),
    .r_addr_ready       (ifm_addr_ready1),
    .r_data             (crdma_m_data1  ),
    .r_data_first       (crdma_m_first1 ),
    .r_data_last        (crdma_m_last1  ),
    .r_data_valid       (crdma_m_valid1 ),
    .r_data_ready       (crdma_m_ready1 ),

    .w_addr             (ofm_addr       ),
    .w_addr_first       (ofm_addr_first ),
    .w_addr_last        (ofm_addr_last  ),
    .w_addr_valid       (ofm_addr_valid1),
    .w_addr_ready       (ofm_addr_ready1),
    .w_data             (cwdma_s_data   ),


    .clk                (clk            ),
    .rst_n              (rst_n          )
);

ram1 i_ram2(
    //r口
    .r_addr             (ifm_addr       ),
    .r_addr_first       (ifm_addr_first ),
    .r_addr_last        (ifm_addr_last  ),
    .r_addr_valid       (ifm_addr_valid2),
    .r_addr_ready       (ifm_addr_ready2),
    .r_data             (crdma_m_data2  ),
    .r_data_first       (crdma_m_first2 ),
    .r_data_last        (crdma_m_last2  ),
    .r_data_valid       (crdma_m_valid2 ),
    .r_data_ready       (crdma_m_ready2 ),

    .w_addr             (ofm_addr       ),
    .w_addr_first       (ofm_addr_first ),
    .w_addr_last        (ofm_addr_last  ),
    .w_addr_valid       (ofm_addr_valid2),
    .w_addr_ready       (ofm_addr_ready2),
    .w_data             (cwdma_s_data   ),

    .clk                (clk            ),
    .rst_n              (rst_n          )
);


    
endmodule