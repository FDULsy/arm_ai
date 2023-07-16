//===============验证说明=====================
//max_pool      ：计算2x2矩阵的最大值

//ctrl          : 共7位，低6位m_width，最高位m_max_pool_en，
//m_max_pool_en : 池化使能，如果为0，输入直接输出；如果为一，进行池化。 
//m_width       ：池化后数据个数，在池化使能的情况下，输入数据的个数必须=4m_width

//输出会比延时一段时间，之后每2拍出一个结果
//============================================
module max_pool #(
    parameter DW=8,DN=7
) (
    input  [DN*DW-1 : 0]   m_data   ,
    input                  m_valid  ,
    input  [       7:0]    m_ctrl   ,
    input                  m_last   ,

    output [DN*DW-1 : 0]   s_data   ,
    output                 s_valid  ,
    input                  s_ready  ,
    //AHBlite interface
    input  wire            HCLK     ,    
    input  wire            HRESETn  , 
    input  wire            HSEL     ,    
    input  wire   [31:0]   HADDR    ,   
    input  wire   [ 1:0]   HTRANS   ,  
    input  wire   [ 2:0]   HSIZE    ,   
    input  wire   [ 3:0]   HPROT    ,   
    input  wire            HWRITE   ,  
    input  wire   [31:0]   HWDATA   ,   
    input  wire            HREADY   , 
    output wire            HREADYOUT, 
    output wire   [31:0]   HRDATA   ,
    output wire            HRESP    ,
    //M0 interrupt interface
    output  reg            AI_IRQ   ,

    input  wire            clk      ,
    input  wire            rst_n
);
//=============================================
//M0 Interrupt response flag bit. 
//1 indicates that the interrupt has responded
//=============================================
reg          M0_IRQ_FLAG     ;
reg          M0_IRQ_FLAG_dly ;
reg          M0_IRQ_FLAG_dly2;
reg   [31:0] AI_RESULT       ;
reg          ahb_data_valid  ;
reg          m_last_dly      ;
wire         m_last_pos      ;      
wire         ahb_write_en    ;
//=============================================
//=============================================
//=============================================

wire [5 : 0] m_width;
wire         m_max_pool_en;

reg  [5:0] cnt;
reg        state;//0:缓存第一行部分比较结果  1：比较1，2行

wire cmp_valid;
wire [DN*DW-1 : 0] cmp_tmp;
wire               cmp_tmp_valid;
reg  [DN*DW-1 : 0] cmp_tmp_a [63:0];
wire [DN*DW-1 : 0] s_cmp_data;
wire  s_pass_valid;
wire  s_cmp_valid;    
wire  s_valid_w;
wire [DN*DW-1 : 0] s_data_w;

// assign m_width = m_ctrl[5 : 0];
// assign m_max_pool_en = m_ctrl[6];
// assign m_ack  = m_ctrl[7];
//上面3行改成下面这4行，用finish和last控制AHB输出
assign ram_sel = m_ctrl[0];
assign m_width = m_ctrl[6 : 1];
assign m_max_pool_en = m_ctrl[7];
assign finish = m_ctrl[8];

assign cmp_valid = m_valid && m_max_pool_en;

cmp2 #(.DW(DW),.DN(DN)) i_cmp2(
    .m_data(m_data),
    .m_valid(cmp_valid),
    .s_data(cmp_tmp),
    .s_valid(cmp_tmp_valid),

    .clk(clk),
    .rst_n(rst_n)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 0;
    else if(cmp_tmp_valid && (cnt==(m_width-1)))
        cnt <= 0;
    else if(cmp_tmp_valid)
        cnt <= cnt + 1'b1;
    else 
        cnt <= cnt;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= 0;
    else if(cmp_tmp_valid && (cnt == (m_width-1)))
        state <= ~state;
    else 
        state <= state;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cmp_tmp_a[63] <= 0;
    else
        cmp_tmp_a[63] <= cmp_tmp_a[63];
    
end

genvar j ;
generate
    for (j=0 ;j<63 ;j=j+1 ) begin :U2
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                cmp_tmp_a[j] <= 0;
            else if(!state && cnt==j)
                cmp_tmp_a[j] <= cmp_tmp;
            else if(state && cmp_tmp_valid)
                cmp_tmp_a[j] <= cmp_tmp_a[j+1];
        end
    end
endgenerate

genvar i;
generate
    for (i =0 ;i<DN ;i=i+1 ) begin :U3
        cmp #(.DW(DW)) i_cmp(
            .data1(cmp_tmp[i*DW +: DW]),
            .data2(cmp_tmp_a[i][i*DW +: DW]),
            .data_out(s_cmp_data[i*DW +: DW])
        );
    end
endgenerate
    
assign s_cmp_valid  =  cmp_tmp_valid && state;
assign s_pass_valid = !m_max_pool_en && m_valid;
assign s_valid_w = s_cmp_valid || s_pass_valid;
assign s_data_w = s_pass_valid? m_data : s_cmp_data;
//*============================================
axi_frs #(.DW(DN*DW)) i_aix_frs_pool(
    .m_data(s_data_w),
    .m_valid(s_valid_w),
    .m_ready(),

    .s_data(s_data),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
);

//================================================*/
//===========================
//  AHBlite data
//===========================
assign HRDATA       = AI_RESULT;
assign HRESP        = 1'b0;
assign HREADYOUT    = 1'b1;
assign ahb_write_en = HSEL & HTRANS[1] & HWRITE;

always@(posedge HCLK or HRESETn)begin
  if(HRESETn == 1'b0)
    M0_IRQ_FLAG <= 1'b0;
  else if(ahb_data_valid == 1'b1)
    M0_IRQ_FLAG <= HWDATA[0];
end

always@(posedge HCLK or HRESETn)begin
  if(HRESETn == 1'b0)
    ahb_data_valid <= 1'b0;
  else if(ahb_write_en == 1'b1)
    ahb_data_valid <= 1'b1;
  else
    ahb_data_valid <= 1'b0;
end

always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)begin
    M0_IRQ_FLAG_dly  <= 1'b0;
    M0_IRQ_FLAG_dly2 <= 1'b0;
    m_last_dly       <= 1'b0;
  end
  else begin
    M0_IRQ_FLAG_dly  <= M0_IRQ_FLAG    ;
    M0_IRQ_FLAG_dly2 <= M0_IRQ_FLAG_dly;
    m_last_dly       <= m_last         ;
  end
end

assign m_last_pos = (~m_last_dly) & m_last;
always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)
    AI_RESULT <= 32'h0;
  else if(m_last_pos == 1'b1 && finish)
    AI_RESULT <= m_data[31:0];
end

always @(posedge clk or negedge rst_n) begin
  if(rst_n == 1'b0)
    AI_IRQ <= 1'b0;
  else if(M0_IRQ_FLAG_dly2 == 1'b1)
    AI_IRQ <= 1'b0;
  else if(m_last_pos == 1'b1 && finish)
    AI_IRQ <= 1'b1;
end

//=====================

endmodule
