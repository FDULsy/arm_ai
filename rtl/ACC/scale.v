//===============验证说明=====================
//m_data1       ： 累加结果A，每个通道为22位

//m_ctrl        :  共23位，该模块只使用低16位，最低9位m_data2，之后的5位n，再之后的2位relu_en。高7位输出到s_ctrl
//m_data2       ： 缩放因子乘数B，9位
//n             ： 乘积结果会右移n位
//relu_en       :  0x:不relu  10:relu  11:leaky_relu

//A和B都是int,该模块输出的结果=A*B*2^(-n)，A通常是个大数，B和n都是统计值，正常情况下会使结果在-128至127之间，超出范围的数据会饱和为-128或127
//============================================



//根据M的数据大小，可能直接给定固定的n作为localparam
module scale #(
    parameter DW=26,DN=7,MULW=13,OW=8,CW1=24,CW2=8
) (
    input  [DN*DW-1 : 0]    m_data1,
    input                   m_valid1,
    //input [DN*MULW-1 : 0] m_data2,
    //input                 m_valid2,
    input  [CW1-1 : 0]      m_ctrl,
    output [CW2-1 : 0]      s_ctrl,
    //input [4 : 0]         n,
    //input [1 : 0]         relu_en,//0x:不relu  10:relu  11:leaky_relu 

    output [DN*OW-1 : 0]  s_data,
    output                s_valid,

    input clk,
    input rst_n
);

localparam SFTW = 5;
localparam SP=2;
localparam PW =2*MULW;

//ctrl unpack and pass
wire [MULW-1 : 0]       m_data2;
wire [4 : 0]            n;
wire [1 : 0]            relu_en;
wire [CW2-1 : 0]        ctrl2;
reg  [CW2-1 : 0]        ctrl2_r1;
reg  [CW2-1 : 0]        ctrl2_r2;
reg  [CW2-1 : 0]        ctrl2_r3;

//local signal

reg  [DN*SFTW-1 : 0] shift_cnt;
reg  [DN*SFTW-1 : 0] shift_cnt1;
reg  [DN*SFTW-1 : 0] shift_cnt2;

wire [DN*3-1 : 0] sel;

reg data_valid1;
reg data_valid2;
reg data_valid3;

reg  [DN*MULW-1 : 0] mul_1;
wire [DN*MULW-1 : 0] mul_2;
wire [DN*PW-1 : 0] p;
//wire signed [DN*(PW+1)-1 : 0] p_e;

wire signed [PW : 0] p_e [DN-1 : 0];
wire signed [PW : 0] p_sft [DN-1 : 0];
wire [DN-1 : 0] carry;
wire [DN-1 : 0] sign;
wire [DN-1 : 0] overflow;
wire [DN*2-1 : 0] relu;
reg  [1 : 0] relu_en_r1;
reg  [1 : 0] relu_en_r2;
wire [DN*OW-1 : 0] s_data_w1;
reg  [DN*OW-1 : 0] s_data_w2;
reg  [DN*OW-1 : 0] s_data_r;


assign m_data2 = m_ctrl[0 +: MULW]  ;
assign n       = m_ctrl[MULW +: 5]  ;
assign relu_en = m_ctrl[MULW+5 +: 2];
assign ctrl2   = m_ctrl[MULW+7 +: 8];

//sel:0x:取[22:14]  10：高9位前几为0，后几位不为0，取[13+SP -：9]  11：高9位全为0，取[13 -: 9]([13:5])
assign mul_2 = {DN{m_data2}};

genvar i;
generate
    for ( i=0 ;i<DN ;i=i+1 ) begin
        //位宽在模型定下来后需要修改
        assign sel[i*3+2] = (m_data1[i*DW+20 +: 6] == {6{m_data1[i*DW+DW-1]}}) ;
        assign sel[i*3+1] = (m_data1[i*DW+18 +: 2] == {2{m_data1[i*DW+DW-1]}}) ;
        assign sel[i*3  ] = (m_data1[i*DW+16 +: 2] == {2{m_data1[i*DW+DW-1]}}) ;
        always @(*) begin
            case(sel[i*2 +: 3])

                3'b100: begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+9 +: 12] ;
                            shift_cnt[i*SFTW +: SFTW] = n-9;
                        end 
                3'b101: begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+9 +: 12] ;
                            shift_cnt[i*SFTW +: SFTW] = n-9;
                        end 
                3'b110: begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+7 +: 12] ;
                            shift_cnt[i*SFTW +: SFTW] = n-7;
                        end
                3'b111: begin 
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+5 +: 12] ;
                            shift_cnt[i*SFTW +: SFTW] = n-5;

                        end
                default:begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+13 +: 13];
                            shift_cnt[i*SFTW +: SFTW] = n-13;
                        end
            endcase
        end

        mul #(.DW(MULW),.OW(18)) i_mul(
            .d1(mul_1[i*MULW +: MULW]),
            .d2(mul_2[i*MULW +: MULW]),
            .do(p[i*PW +: PW]),
            .clk (clk ),
            .rst_n(rst_n)
        );

        // mul9 i_mul (
        // .a ( mul_1[i*MULW +: MULW] ),
        // .b ( mul_2[i*MULW +: MULW] ),
        // .p ( p[i*PW +: PW] ),
        // .cea (m_valid1 ),
        // .ceb (m_valid1 ),
        // .cepd (1'b1 ),
        // .clk (clk ),
        // .rstan (rst_n ),
        // .rstbn (rst_n ),
        // .rstpdn (rst_n )
        // );


        //shift
        assign sign[i] = p[i*PW + PW -1];
        assign p_e  [i] = {p[i*PW +: PW],1'b0};
        assign p_sft[i] = p_e[i]  >>> shift_cnt2[i*SFTW +: SFTW];
        //clip
        assign carry[i] = p_sft[i][0];
        assign overflow[i] = sign[i] ? (p_sft[i][9 +: 10] != 10'b1111111111) : (p_sft[i][9 +: 10] != 0);
        assign s_data_w1[i*OW +: OW] = overflow[i]? {sign[i],{7{~sign[i]}}} : {sign[i],p_sft[i][1 +: 7]};
        //relu
        assign relu[i*2+1] = ~(relu_en_r2[1] && sign[i]);
        assign relu[i*2]   = relu_en_r2[1] && relu_en_r2[0] && sign[i];
        always @(*) begin
            case(relu[i*2 +: 2])
                2'b00: begin
                    s_data_w2[i*OW +: OW] = 0;
                end
                2'b01: begin
                    s_data_w2[i*OW +: OW] = {{6{s_data_w1[i*OW+OW-1]}},s_data_w1[i*OW+6 +: (OW-6)]};
                end
                2'b10: begin
                    s_data_w2[i*OW +: OW] = s_data_w1[i*OW +: OW];
                end
                default:begin
                    s_data_w2[i*OW +: OW] = 0;
                end
            endcase
        end
        
        //round
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                s_data_r[i*OW +: OW] <= 0;
            else if(carry && !relu)
                s_data_r[i*OW +: OW] <= s_data_w2[i*OW +: OW] + 1'b1;
            else 
                s_data_r[i*OW +: OW] <= s_data_w2[i*OW +: OW];
        end
    end

endgenerate


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_valid1 <= 0;
        data_valid2 <= 0;
        data_valid3 <= 0;
        relu_en_r1     <= 0;
        relu_en_r2     <= 0;
        shift_cnt1  <= 0;
        shift_cnt2  <= 0;//另一个写法是把sel打2拍，用case sel得到小数点的位置
        ctrl2_r1    <= 0;
        ctrl2_r2    <= 0;
        ctrl2_r3    <= 0;
    end
    else begin
        data_valid1 <= m_valid1;
        data_valid2 <= data_valid1;
        data_valid3 <= data_valid2;
        relu_en_r1     <= relu_en;
        relu_en_r2     <= relu_en_r1;
        shift_cnt1  <= shift_cnt;
        shift_cnt2  <= shift_cnt1;
        ctrl2_r1    <= ctrl2;
        ctrl2_r2    <= ctrl2_r1;
        ctrl2_r3    <= ctrl2_r2;
    end
end

assign s_data  = s_data_r;
assign s_valid = data_valid3;
assign s_ctrl  = ctrl2_r2;

endmodule
