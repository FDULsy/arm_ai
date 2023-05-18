module max_pool #(
    parameter DW=8,DN=6
) (
    input  [DN*DW-1 : 0] m_data,

    input                m_valid,
    input  [5:0] m_width,
    input        m_max_pool_en,

    output [DN*DW-1 : 0] s_data,
    output               s_valid,
    input                s_ready,
    
    input clk,
    input rst_n
);

reg  [5:0] cnt;
reg        state;//0:缓存第一行部分比较结果  1：比较1，2行

reg cmp_valid;
wire [DN*DW-1 : 0] cmp_tmp;
reg                cmp_tmp_valid;
reg  [DN*DW-1 : 0] cmp_tmp_a [63:0];
wire [DN*DW-1 : 0] s_cmp_data;
reg  s_pass_valid;
reg  s_cmp_valid;    
wire s_valid_w;
wire [DN*DW-1 : 0] s_data_w;


assign cmp_valid = m_valid && m_max_pool_en;
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

cmp2 #(.DW(DW)) i_cmp2(
    .m_data(m_data),
    .m_valid(cmp_valid),
    .s_data(cmp_tmp),
    .s_valid(cmp_tmp_valid),

    .clk(clk),
   .rst_n(rst_n)
);

genvar j ;
generate
    for (j=0 ;j<64 ;j=j+1 ) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                cmp_tmp_a[i] <= 0;
            else if(!state && cnt==i)
                cmp_tmp_a[i] <= cmp_tmp;
            else if(state && cmp_tmp_valid)
                cmp_tmp_a[i] <= cmp_tmp_a[i+1];
        end
    end
endgenerate

genvar i;
generate
    for (i =0 ;i<DN ;i=i+1 ) begin
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

endmodule
