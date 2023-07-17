module ai_camera(
    input  wire        PCLK          ,
    input  wire        RSTn          ,
    input  wire        VSYNC         ,
    input  wire        HREF          ,
    input  wire [ 7:0] PIC_DATA      ,

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
    output                  AI_IRQ   ,

    input                   clk      ,
    input                   rst_n    
);


camera2sdram i_camera(
    .PCLK       (PCLK      ),
    .RSTn       (RSTn      ),
    .VSYNC      (VSYNC     ),
    .HREF       (HREF      ),
    .PIC_DATA   (PIC_DATA  ),

    .first      (ifm_addr_first     ),
    .last       (ifm_addr_last      ),
    .data_first (pic_first          ),
    .data_last  (pic_last           ),
    .data_ready (ifm_addr_ready0    ),
    .data_valid (pic_valid          ),
    .data_out   (pic_data           ),
    .r_clk      (clk                ),
    .rd_ready   (s_read_pic_ready   ),
    .rd_en      (ifm_addr_valid0    )
);


wire s_read_pic_ready;
wire ifm_addr_valid0, ifm_addr_ready0, ifm_addr_first,ifm_addr_last;
wire pic_valid, pic_first, pic_last, pic_ready, rd_ready;
wire [15:0] pic_data;
ai_top i_ai(            
    .HCLK               (HCLK               ),
    .HRESETn            (HRESETn            ),
    .HSEL               (HSEL               ),
    .HADDR              (HADDR              ),
    .HTRANS             (HTRANS             ),
    .HSIZE              (HSIZE              ),
    .HPROT              (HPROT              ),
    .HWRITE             (HWRITE             ),
    .HWDATA             (HWDATA             ),
    .HREADY             (HREADY             ),
    .HREADYOUT          (HREADYOUT          ),
    .HRDATA             (HRDATA             ),
    .HRESP              (HRESP              ),
    .AI_IRQ             (AI_IRQ             ),

    .s_read_pic_ready   (s_read_pic_ready   ),
    .ifm_addr_first     (ifm_addr_first     ),
    .ifm_addr_last      (ifm_addr_last      ),
    .ifm_addr_valid0    (ifm_addr_valid0    ),
    .ifm_addr_ready0    (ifm_addr_ready0    ),
    .pic_data           (pic_data           ),
    .pic_first          (pic_first          ),
    .pic_last           (pic_last           ),
    .pic_valid          (pic_valid          ),
    .pic_ready          (pic_ready          ),
    .rd_ready           (rd_ready           ),

    .clk(clk),
    .rst_n(rst_n)
);










endmodule