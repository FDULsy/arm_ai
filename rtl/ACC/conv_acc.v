
module conv_acc #(
    parameter AW=10,DW=22,DN=6,CW1=28,CW2=23
) (
    //data可能需要打拍
    input [DW*DN-1 : 0]       m_data1,
    input                     m_valid1,
    input                     m_valid1_pre,//m_valid提前一拍
    input [DW*DN-1 : 0]       m_data2,//bias
    //input                     m_valid2,
    input [DW*DN-1 : 0]       m_data3,//acc
    //input                     m_valid3,
    output                    m_ready,

    input                     start,//first提前2拍

    input   [CW1-1 : 0]       m_ctrl,
    input   [AW-1 : 0]        base,
    input   [9:0]             size,//size=3表示累加4个数
    
    output  [CW2-1 : 0]       s_ctrl,
    // input                     first_k,//3*3卷积的第一个，  为1输入选择bias 通道，为0输入选择acc通道
    // input                     last_k ,//3*3卷积的最后一个，为1输出选择scale通道，为0输出选择acc通道
   //============

    output   [AW-1 : 0]       m_addr2,//bias
    output   [AW-1 : 0]       m_addr3,//累加结果

    //2路输出结果相同，
    //由valid控制写使能
    output      [DW*DN-1 : 0] m_sum,
    output  reg               m_valid,
    output      [DW*DN-1 : 0] s_sum,
    output  reg               s_valid,

    input clk,
    input rst_n
);



//缓存一组信息，避免数据冲突
wire           first_k_r;
wire           last_k_r;


wire                    first_k;
wire                    last_k ;
wire [2:0]              shift_n;

wire [CW2-1 : 0] ctrl2;
wire [CW2-1 : 0] ctrl2_r;
reg  [CW2-1 : 0] s_ctrl_r;

assign first_k = m_ctrl[0];
assign last_k  = m_ctrl[1];
assign shift_n = m_ctrl[4:2];
assign ctrl2=m_ctrl[5 +: 14];


reg [AW-1 : 0] addr_r;

//reg [3:0] cnt;
reg [10:0] residue;

wire [2*DW*DN+24 :0] m_data_bus;
wire [2*DW*DN+24 :0] s_data_bus;
wire       m_data_valid;
//wire       s_data_valid;
wire m_valid_w;
wire s_valid_w;
wire data_valid;

reg m_valid2;

//wire m_valid_sel;
wire [DW*DN-1 : 0] m_data_2;
wire [DW*DN-1 : 0] data1;
wire [DW*DN-1 : 0] data2;
wire [DW*DN-1 : 0] sum;
reg  [DW*DN-1 : 0] sum_r;

wire [DW*DN-1 : 0] m_data1_sft;
wire [DW*DN-1 : 0] m_data2_sft;


//assign m_valid_sel =  first_k_r2? m_valid2 && m_valid3 ;
//assign m_valid_sel = m_valid1 && m_valid_sel;
assign m_data_valid = m_valid1_pre;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_r    <= 0;
        residue    <= 0;
    end
    else if(residue!=0 && m_data_valid) begin
        addr_r    <= addr_r+1 ;
        residue <= residue-1;
    end
    else if(start && residue==0) begin
        addr_r    <= base;
        residue    <= size;
    end
    else begin
        addr_r    <= addr_r;
        residue    <= 0;
    end    
end

assign m_addr2 = addr_r;
assign m_addr3 = addr_r;

assign m_data_2 = first_k? m_data2 : m_data3;

genvar j;
generate
    for(j=0;j<DN;j=j+1) begin: shift
        acc_shift #(.DW(DW)) i_SHIFT(
            .m_data1  (m_data1[DW*j +: DW]),
            .m_data2  (m_data_2[DW*j +: DW]),
            .m_shift_n(shift_n),
            .s_data1  (m_data1_sft[DW*j +: DW]),
            .s_data2  (m_data2_sft[DW*j +: DW])
        );
    end
endgenerate


assign m_data_bus={m_data1_sft,m_data2_sft,ctrl2,first_k,last_k};

axi_frs #(.DW(2*DW*DN+25)) i_axi_frs_data(
    .m_data(m_data_bus),
    .m_valid(m_valid1),
    .m_ready(m_ready),

    .s_data(s_data_bus),
    .s_valid(data_valid),
    .s_ready(1'b1),

    .clk(clk),
    .rst_n(rst_n)
);

assign {data1,data2,ctrl2_r,first_k_r,last_k_r} = s_data_bus;

genvar i;
generate
    for(i=0;i<DN;i=i+1) begin: add_gen
        assign sum[i*DW +: DW] = data1[i*DW +: DW] + data2[i*DW +: DW];
    end
endgenerate

assign m_valid_w = (last_k_r) ? 0 : data_valid;
assign s_valid_w = (last_k_r) ? data_valid : 0;

//输出打拍
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_r    <= 0;
        m_valid  <= 0;
        s_valid  <= 0;
        s_ctrl_r <= 0;
    end
    else begin
        sum_r    <= sum;
        m_valid  <= m_valid_w;
        s_valid  <= s_valid_w;
        s_ctrl_r <= ctrl2_r;
    end
end
assign m_sum  = sum_r;
assign s_sum  = sum_r;
assign s_ctrl = s_ctrl_r;
 
endmodule
