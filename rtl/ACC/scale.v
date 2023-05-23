//根据M的数据大小，可能直接给定固定的n作为localparam
module scale #(
    parameter DW=22,DN=6,MULW=9,OW=8
) (
    input [DN*DW-1 : 0]   m_data1,
    input                 m_valid1,
    input [DN*MULW-1 : 0] m_data2,
    //input                 m_valid2,
    input [4 : 0]         n,
    input [1 : 0]         relu_en,//0x:不relu  10:relu  11:leaky_relu 

    output [DN*OW-1 : 0] s_data,
    output               s_valid,

    input clk,
    input rst_n
);

localparam SFTW = 5;
localparam SP=2;
localparam PW =2*MULW;
reg data_valid1;
reg data_valid2;
reg data_valid3;
reg data_valid4;
reg  [DN*SFTW-1 : 0] shift_cnt;
reg  [DN*SFTW-1 : 0] shift_cnt1;
reg  [DN*SFTW-1 : 0] shift_cnt2;
reg  [DN*MULW-1 : 0] mul_1;
wire [DN*MULW-1 : 0] mul_2;
wire [DN*3-1 : 0] sel;

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
reg  [1 : 0] relu_en_r3;
wire [DN*OW-1 : 0] s_data_w1;
reg  [DN*OW-1 : 0] s_data_w2;
reg  [DN*OW-1 : 0] s_data_r;

//sel:0x:取[22:14]  10：高9位前几为0，后几位不为0，取[13+SP -：9]  11：高9位全为0，取[13 -: 9]([13:5])
assign mul_2 = m_data2;

genvar i;
generate
    for ( i=0 ;i<DN ;i=i+1 ) begin
        //位宽在模型定下来后需要修改
        assign sel[i*3+2] = (m_data1[i*DW+16 +: 6] == {6{m_data1[i*DW+DW-1]}}) ;
        assign sel[i*3+1] = (m_data1[i*DW+13 +: 2] == {2{m_data1[i*DW+DW-1]}}) ;
        assign sel[i*3  ] = (m_data1[i*DW+11 +: 2] == {2{m_data1[i*DW+DW-1]}}) ;
        always @(*) begin
            case(sel[i*2 +: 3])

                3'b100: begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+8 +: 9] ;
                            shift_cnt[i*SFTW +: SFTW] = n-8;
                        end 
                3'b101: begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+8 +: 9] ;
                            shift_cnt[i*SFTW +: SFTW] = n-8;
                        end 
                3'b110: begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+5 +: 9] ;
                            shift_cnt[i*SFTW +: SFTW] = n-5;
                        end
                3'b111: begin 
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+3 +: 9] ;
                            shift_cnt[i*SFTW +: SFTW] = n-3;

                        end
                default:begin
                            mul_1[i*MULW +: MULW] = m_data1[i*DW+13 +: 9];
                            shift_cnt[i*SFTW +: SFTW] = n-13;
                        end
            endcase
        end

        // mul #(.DW(MULW),.OW(18)) i_mul(
        //     .d1(mul_1[i*MULW +: MULW]),
        //     .d2(mul_2[i*MULW +: MULW]),
        //     .do(p[i*PW +: PW]),
        //     .clk (clk ),
        //     .rst_n(rst_n)
        // );

        mul9 i_mul (
        .a ( mul_1[i*MULW +: MULW] ),
        .b ( mul_2[i*MULW +: MULW] ),
        .p ( p[i*PW +: PW] ),
        .cea (m_valid1 ),
        .ceb (m_valid1 ),
        .cepd (1'b1 ),
        .clk (clk ),
        .rstan (rst_n ),
        .rstbn (rst_n ),
        .rstdn (rst_n )
        );


        //shift
        assign sign[i] = p[i*PW + PW -1];
        assign p_e  [i] = {p[i*PW +: PW],1'b0};
        assign p_sft[i] = p_e[i]  >>> shift_cnt2[i*SFTW +: SFTW];
        //clip
        assign carry[i] = p_sft[i][0];
        assign overflow[i] = sign[i] ? (p_sft[i][9 +: 10] != 10'b1111111111) : (p_sft[i][9 +: 10] != 0);
        assign s_data_w1[i*OW +: OW] = overflow[i]? {sign[i],{7{~sign[i]}}} : {sign[i],p_sft[i][1 +: 7]};
        //relu
        assign relu[i*2+1] = ~(relu_en_r3[1] && sign[i]);
        assign relu[i*2]   = relu_en_r3[1] && relu_en_r3[0] && sign[i];
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
        data_valid4 <= 0;
        relu_en_r1     <= 0;
        relu_en_r2     <= 0;
        relu_en_r3     <= 0;
        shift_cnt1  <= 0;
        shift_cnt2  <= 0;//另一个写法是把sel打2拍，用case sel得到小数点的位置

    end
    else begin
        data_valid1 <= m_valid1;
        data_valid2 <= data_valid1;
        data_valid3 <= data_valid2;
        data_valid4 <= data_valid3;
        relu_en_r1     <= relu_en;
        relu_en_r2     <= relu_en_r1;
        relu_en_r3     <= relu_en_r2;
        shift_cnt1  <= shift_cnt;
        shift_cnt2  <= shift_cnt1;
    end
end

assign s_data  = s_data_r;
assign s_valid = data_valid4;

endmodule
