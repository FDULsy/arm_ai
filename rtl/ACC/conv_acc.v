module conv_acc #(
    parameter AW=11,DW=22,DN=6
) (
    //data可能需要打拍
    input [DW*DN-1 : 0] m_data1,
    input               m_valid1,
    input [DW*DN-1 : 0] m_data2,//bias
    input [DW*DN-1 : 0] m_data3,//acc
    output              m_ready,

    //wdma产生，还没写
    input [AW-1 : 0] base2,
    input [10:0] size,
    input        start,
    input        first_k,//3*3卷积的第一个，  为1输入选择bias 通道，为0输入选择acc通道
    input        last_k ,//3*3卷积的最后一个，为1输出选择scale通道，为0输出选择acc通道
   //============

    output   [AW-1 : 0]   m_addr2,//bias
    output   [AW-1 : 0]   m_addr3,//累加结果

    //2路输出结果相同，由valid控制写使能
    output      [DW*DN-1 : 0] m_sum,
    output  reg              m_valid,
    output      [DW*DN-1 : 0] s_sum,
    output  reg              s_valid,

    input clk,
    input rst_n
);



//缓存一组信息，避免数据冲突
reg [AW-1 : 0] base2_r;
reg [10:0]      size_r;
reg            start_r;
reg            first_k_r;
reg            last_k_r;


//first打1拍，与输入data到来时刻对齐
reg            first_k_r1;
reg            first_k_r2;

//last打2拍，与sum对齐
reg            last_k_r1;
reg            last_k_r2;
reg            last_k_r3;

reg [AW-1 : 0] addr1_r;
reg [AW-1 : 0] addr2_r;

//reg [3:0] cnt;
reg [10:0] residue;

wire [2*DW*DN-1 :0] m_data_bus;
wire [2*DW*DN-1 :0] s_data_bus;
wire       m_data_valid;
//wire       s_data_valid;
wire m_valid_w;
wire s_valid_w;
wire data_valid;

reg m_valid2;
reg m_valid2_r;

wire [DW*DN-1 : 0] m_data_2;
wire [DW*DN-1 : 0] data1;
wire [DW*DN-1 : 0] data2;
wire [DW*DN-1 : 0] sum;
reg  [DW*DN-1 : 0] sum_r;

assign m_data_2 = first_k_r2? m_data2 : m_data3;
assign m_data_valid = m_valid1 && m_valid2_r ;

assign m_data_bus={m_data1,m_data_2};

axi_frs #(.DW(2*DW*DN)) i_axi_frs_data(
    .m_data(m_data_bus),
    .m_valid(m_data_valid),
    .m_ready(m_ready),

    .s_data(s_data_bus),
    .s_valid(data_valid),
    .s_ready(1'b1),

    .clk(clk),
    .rst_n(rst_n)
);

assign {data1,data2} = s_data_bus;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        base2_r    <= 0;
        size_r     <= 0;
        start_r    <= 0;
        first_k_r  <= 0;
        last_k_r   <= 0;
    end
    else if(start && residue!=0) begin
        base2_r    <= base2;
        size_r     <= size;
        start_r    <= start;
        first_k_r  <= first_k;
        last_k_r   <= last_k;
    end
    else if(residue==0) begin
        base2_r    <= 0;
        size_r     <= 0;
        start_r    <= 0;
        first_k_r  <= 0;
        last_k_r   <= 0;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        residue <= 0;
    else if(residue==0 && start_r)
        residue <= size_r;
    else if(residue==0 && start)
        residue <= size;
    else if(residue==0) 
        residue <= residue;
    else if(m_data_valid) 
        residue <= residue-1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        m_valid2 <= 0;
    else if(residue==0 || residue==1) 
        m_valid2 <= 0;
    else 
        m_valid2 <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        m_valid2_r <= 0;
    else
        m_valid2_r <= m_valid2;
end

//cnt=0:ideal  cnt=1:data2=bias   cnt=其他：data2=partial_sum(m_sum)
//cnt<9:结果输出m_sum  cnt=9:结果输出s_sum
/*
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 0;
    else if(cnt==4'd9 && residue==0)
        cnt <= 0;
    else if((start_r && residue==0)||(start && residue==0))
        cnt <= cnt+1'b1;
end
*/

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//         data_valid <= 0;
//     else if(residue != 0)
//         data_valid <= m_valid1&&(m_valid2 || m_valid3);
//     else
//         data_valid <= 0;
// end

//addr&&first or last
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        first_k_r1 <= 0;
        last_k_r1  <= 0;
        addr1_r    <= 0;
        addr2_r    <= 0;
    end
    else if(start_r && residue==0) begin
        first_k_r1 <= first_k_r;
        last_k_r1  <= last_k_r ;
        addr1_r    <= 0  ;
        addr2_r    <= base2_r  ;
    end
    else if(start && residue==0) begin
        first_k_r1 <= first_k;
        last_k_r1  <= last_k;
        addr1_r    <= 0  ;
        addr2_r    <= base2;
    end
    else if(residue!=0 && m_data_valid) begin
        first_k_r1 <= first_k_r1;
        last_k_r1  <= last_k_r1 ;
        addr1_r    <= addr1_r+1 ;
        addr2_r    <= addr2_r+1 ;
    end
end
assign m_addr1 = addr1_r;
assign m_addr2 = addr2_r;
assign m_addr3 = addr2_r;

//first&last打拍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        first_k_r2 <= 0;
        last_k_r2  <= 0;
        last_k_r3  <= 0;
    end
    else begin
        first_k_r2 <= first_k_r1;
        last_k_r2  <= last_k_r1 ;
        last_k_r3  <= last_k_r2 ;
    end
end

genvar i;
generate
    for(i=0;i<DN;i=i+1) begin: add_gen
        assign sum[i*DW +: DW] = data1[i*DW +: DW] + data2[i*DW +: DW];
    end
endgenerate

assign m_valid_w = (last_k_r3) ? 0 : data_valid;
assign s_valid_w = (last_k_r3) ? data_valid : 0;


//输出打拍
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_r   <= 0;
        m_valid <= 0;
        s_valid <= 0;
    end
    else begin
        sum_r   <= sum;
        m_valid <= m_valid_w;
        s_valid <= s_valid_w;
    end
end
assign m_sum = sum_r;
assign s_sum = sum_r;

 
endmodule
