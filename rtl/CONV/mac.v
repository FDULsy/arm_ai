//first last valid信号没写
module mac #(parameter DW=8,CW=19,ROW=7,COLUMN=7,OW=26
) (
    input [ROW*DW-1     : 0]        mac_m_data  ,
    input [COLUMN*DW-1  : 0]        w           ,
    input [ROW-1        : 0]        w_en        ,
    input [COLUMN*CW-1  : 0]        ci          ,

    output [COLUMN*OW-1 : 0]        mac_s_data  ,     

    input clk,
    input rst_n
);

localparam EW = OW-CW;

wire [COLUMN*(CW)-1 : 0] co0;
wire [COLUMN*(CW)-1 : 0] co1;
wire [COLUMN*(CW)-1 : 0] co2;
wire [COLUMN*(CW)-1 : 0] co3;
wire [COLUMN*(CW)-1 : 0] co4;
wire [COLUMN*(CW)-1 : 0] co5;
wire [COLUMN*(CW)-1 : 0] co6;
//wire [COLUMN*(CW)-1 : 0] co7;

//row0
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row0(
    .xi(mac_m_data[0*DW +: DW]),
    .wi(w),
    .ci(ci),
    .w_en(w_en[0]),

    .co(co0),
    .clk(clk),
    .rst_n(rst_n)
);

//row1
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row1(
    .xi(mac_m_data[1*DW +: DW]),
    .wi(w),
    .ci(co0),
    .w_en(w_en[1]),

    .co(co1),
    .clk(clk),
    .rst_n(rst_n)
);

//row2
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row2(
    .xi(mac_m_data[2*DW +: DW]),
    .wi(w),
    .ci(co1),
    .w_en(w_en[2]),

    .co(co2),
    .clk(clk),
    .rst_n(rst_n)
);

//row3
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row3(
    .xi(mac_m_data[3*DW +: DW]),
    .wi(w),
    .ci(co2),
    .w_en(w_en[3]),

    .co(co3),
    .clk(clk),
    .rst_n(rst_n)
);

//row4
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row4(
    .xi(mac_m_data[4*DW +: DW]),
    .wi(w),
    .ci(co3),
    .w_en(w_en[4]),

    .co(co4),
    .clk(clk),
    .rst_n(rst_n)
);

//row5
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row5(
    .xi(mac_m_data[5*DW +: DW]),
    .wi(w),
    .ci(co4),
    .w_en(w_en[5]),

    .co(co5),
    .clk(clk),
    .rst_n(rst_n)
);

//row6
mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row6(
    .xi(mac_m_data[6*DW +: DW]),
    .wi(w),
    .ci(co5),
    .w_en(w_en[6]),

    .co(co6),
    .clk(clk),
    .rst_n(rst_n)
);

//row7
// mac_row #(.DW(DW),.OW(CW),.COLUMN(COLUMN)) i_mac_row7(
//     .xi(mac_m_data[7*DW +: DW]),
//     .wi(w),
//     .ci(co6),
//     .w_en(w_en[7]),

//     .co(co7),
//     .clk(clk),
//     .rst_n(rst_n)
// );
genvar i;
generate
    for (i = 0;i<COLUMN ;i=i+1 ) begin
        assign mac_s_data[i*OW +: OW] = {{EW{co6[(i+1)*CW-1]}},co6[i*CW +: CW]};
    end
endgenerate


endmodule
