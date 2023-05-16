module conv_acc #(
    parameter AW=11,DW=22,DN=6
) (
    input [DW*DN-1 : 0] m_data1,
    input [DW*DN-1 : 0] m_data2,

    //wdma产生，还没写
    input [AW-1 : 0] base1,
    input [AW-1 : 0] base2,
    input [7:0] size,
    input       wover,
    input [3:0] kernel_n,
   //============

    output  reg [AW-1 : 0]   m_addr1,
    output  reg [AW-1 : 0]   m_addr2,
    output      [DW*6-1 : 0] m_sum,
    output                   m_valid,
    output      [DW*6-1 : 0] s_sum,
    output  reg              s_valid,

    input clk,
    input rst_n
);

reg [AW-1 : 0] base1_r;
reg [AW-1 : 0] base2_r;
reg [7:0]      size_r;
reg            wover_r;
reg [3:0]      kernel_n_r;

reg [3:0] cnt;
reg [7:0] residue;
reg       data_valid;
wire m_valid_w;
wire s_valid_w;
wire [DW*DN-1 : 0] sum;
reg  [DW*DN-1 : 0] sum_r;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        base1_r    <= 0;
        base2_r    <= 0;
        size_r     <= 0;
        wover_r    <= 0;
        kernel_n_r <= 0;
    end
    else if(wover && residue!=0) begin
        base1_r    <= base1;
        base2_r    <= base2;
        size_r     <= size;
        wover_r    <= wover;
        kernel_n_r <= kernel_n;
    end
    else if(residue==0) begin
        base1_r    <= 0;
        base2_r    <= 0;
        size_r     <= 0;
        wover_r    <= 0;
        kernel_n_r <= 0;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(rst_n)
        residue <= 0;
    else if(residue==0 && wover_r)
        residue <= size_r;
    else if(residue==0 && wover)
        residue <= size;
    else
        residue <= residue-1;
end


//cnt=0:ideal  cnt=1:data2=bias   cnt=其他：data2=partial_sum(m_sum)
//cnt<9:结果输出m_sum  cnt=9:结果输出s_sum
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 0;
    else if(cnt==4'd9 && residue==0)
        cnt <= 0;
    else if((wover_r && residue==0)||(wover && residue==0))
        cnt <= cnt+1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_valid <= 0;
    else if(residue != 0)
        data_valid <= 1'b1;
    else
        data_valid <= 0;
end

//addr
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        m_addr1 <= 0;
        m_addr2 <= 0;
    end
    else if(wover_r && residue==0) begin
        m_addr1 <= base1_r;
        m_addr2 <= base2_r;
    end
    else if(wover && residue==0) begin
        m_addr1 <= base1;
        m_addr2 <= base2;
    end
    else if(residue!=0) begin
        m_addr1 <= m_addr1+1;
        m_addr2 <= m_addr2+1;
    end
end

genvar i;
generate
    for(i=0;i<DN;i=i+1) begin: add_gen
        assign sum[i*DW +: DW] = m_data1[i*DW +: DW] + m_data2[i*DW +: DW];
    end
endgenerate

assign m_valid_w = (cnt==9) ? 0 : data_valid;
assign s_valid_w = (cnt==9) ? data_valid : 0;


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
