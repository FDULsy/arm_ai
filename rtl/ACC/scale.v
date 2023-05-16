//根据M的数据大小，可能直接给定固定的n作为localparam
module scale #(
    parameter DW=22,DN=6,MULW=9,OW=8
) (
    input [DN*DW-1 : 0]   m_data1,
    input                 m_valid1,
    input [DN*MULW-1 : 0] m_data2,
    //input                 m_valid2,
    input [4 : 0]         n,

    output [DN*OW-1 : 0] s_data;
    output               s_valid;

    input clk,
    input rst_n
);

localparam SFTW = 4;
localparam SP=2;
localparam PW =2*MULW;
reg data_valid1;
reg data_valid2;
reg  [DN*SFTW-1 : 0] shift_cnt;
reg  [DN*SFTW-1 : 0] shift_cnt1;
reg  [DN*SFTW-1 : 0] shift_cnt2;
reg  [DN*MULW-1 : 0] mul_1;
wire [DN*MULW-1 : 0] mul_2;
wire [DN-1 : 0] sel;

wire [DN*PW-1 : 0] p;
wire [DN*(PW+1)-1 : 0] p_e;
wire [DN*(PW+1)-1 : 0] p_sft;
wire [DN-1 : 0] carry;
wire [DN-1 : 0] sign;
wire [DN-1 : 0] overflow;
wire [DN*OW-1 : 0] s_data_w;
reg  [DN*OW-1 : 0] s_data_r;

//sel:0x:取[22:14]  10：高9位前几为0，后几位不为0，取[13+SP -：9]  11：高9位全为0，取[13 -: 9]([13:5])
assign mul_2 = m_data2;

genvar i;
generate
    for ( i=0 ;i<DN ;i=i+1 ) begin
        //位宽在模型定下来后需要修改
        assign sel[i] = (m_data1[i*DW+14 +: MULW-SP] == 7'b0) || (m_data1[i*DW+14 +: MULW-SP] == 7'b1111111 )
        case(sel[i])
            1'b0:   begin
                        mul_1[i*MULW +: MULW] = m_data1[i*DW+14 +: 9];
                        shift_cnt[i*SFTW +: SFTW] = n-14;
                    end
            1'b1:   begin
                        mul_1[i*MULW +: MULW] = m_data1[i*DW+8 +: 9] ;
                        shift_cnt[i*SFTW +: SFTW] = n-8;
            end 
        endcase

        EG4_LOGIC_MULT #(
        .INPUT_WIDTH_A (9 ),
        . INPUT_WIDTH_B (9 ),
        .OUTPUT_WIDTH (18 ),
        . INPUTFORMAT ("SIGNED" ),
        . INPUTREGA ("ENABLE" ),
        . INPUTREGB ("ENABLE" ),
        . OUTPUTREG ("ENABLE" ),
        . IMPLEMENT ("DSP" ),
        . SRMODE ("ASYNC" )
        ) i_mul (
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
        assign p_e  [i*(PW+1) +: (PW+1)] = {p[i*PW +: PW],1'b0};
        assign p_sft[i*(PW+1) +: (PW+1)] = p_e[i*(PW+1) +: (PW+1)]  >>> shift_cnt2[i*SFTW +: SFTW];
        //clip
        assign carry[i] = p_sft[i*(PW+1)];
        assign overflow[i] = sign[i] ? (p_sft[i*PW+8 +: 11] != 11'b11111111111) : (p_sft[i*PW+8 +: 11] != 0);
        assign s_data_w[i*OW +: OW] = overflow[i]? {sign[i],7{~sign[i]}}:{sign[i],p_sft[i*PW +: 7]};
        //round
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                s_data_r[i*OW +: OW] <= 0;
            else if(carry)
                s_data_r[i*OW +: OW] <= s_data_w[i*OW +: OW] + 1'b1;
            else 
                s_data_r[i*OW +: OW] <= s_data_w[i*OW +: OW];
        end
    end

endgenerate

//另一个写法是把sel打2拍，用case sel得到小数点的位置
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_valid1 <= 0;
        data_valid2 <= 0;
        shift_cnt1  <= 0;
        shift_cnt2  <= 0;
    end
    else begin
        data_valid1 <= m_valid1;
        data_valid2 <= data_valid1;
        shift_cnt1  <= shift_cnt;
        shift_cnt2  <= shift_cnt1;
    end
end

assign s_data  = s_data_r;
assign s_valid = data_valid2;

endmodule
