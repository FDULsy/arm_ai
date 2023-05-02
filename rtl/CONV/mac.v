//first last valid信号没写
module mac #(parameter DW=8,WW=8,CW=16,ROW=8,COLUMN=6,OW=2*DW+ROW
) (
    input [ROW*DW-1:0]         mac_m_data,
    input                      mac_m_first,
    input                      mac_m_last,
    input                      mac_m_valid,
    output                     mac_m_ready,
    input [COLUMN*WW-1 : 0]    w,
    input [   COLUMN-1 : 0]    w_en,
    input [COLUMN*CW-1 : 0]    ci,

    output [COLUMN*OW-1 : 0] mac_s_data,
    output                   mac_s_first,
    output                   mac_s_last,
    output                   mac_s_valid,
    input                    mac_s_ready,

    input clk,
    input rst_n
);

wire [COLUMN*WW-1 : 0] w_pass [ROW-1 : 0];
wire [   COLUMN-1 : 0] w_en_pass [ROW-1 : 0];
reg  [COLUMN*WW-1 : 0] w_pass_r [ROW-2 : 0];
reg  [   COLUMN-1 : 0] w_en_pass_r [ROW-2 : 0];

wire [COLUMN*(CW+1)-1 : 0] co0;
wire [COLUMN*(CW+2)-1 : 0] co1;
wire [COLUMN*(CW+3)-1 : 0] co2;
wire [COLUMN*(CW+4)-1 : 0] co3;
wire [COLUMN*(CW+5)-1 : 0] co4;
wire [COLUMN*(CW+6)-1 : 0] co5;
wire [COLUMN*(CW+7)-1 : 0] co6;
wire [COLUMN*(CW+8)-1 : 0] co7;

assign w_pass[0] = w;
assign w_en_pass[0] = w_en; 
assign c[0] ={48'h0,ci};
assign mac_s_data = co7;

assign w_pass[ROW-1 : 1] = w_pass_r;
assign w_en_pass[ROW-1 : 1] =w_en_pass_r;

genvar i;
generate
    for (i=0;i<ROW;i=i+1) begin: weight_pass
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                w_pass_r[i] <= 0;
                w_en_pass_r[i] <= 0;
            end
            else
                w_pass_r[i] <= w_pass[i];
                w_en_pass_r[i] <= w_en_pass[i];
        end
endgenerate

//row0
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row0(
    .xi(mac_m_data[0*DW +: DW]),
    .wi(w_pass[0]),
    .ci(ci),
    .w_en(w_en_pass[0]),

    .co(co0),
    .clk(clk),
    .rst_n(rst_n)
);

//row1
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row1(
    .xi(mac_m_data[1*DW +: DW]),
    .wi(w_pass[1]),
    .ci(co0),
    .w_en(w_en_pass[1]),

    .co(co1),
    .clk(clk),
    .rst_n(rst_n)
);

//row2
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row2(
    .xi(mac_m_data[2*DW +: DW]),
    .wi(w_pass[2]),
    .ci(co1),
    .w_en(w_en_pass[2]),

    .co(co2),
    .clk(clk),
    .rst_n(rst_n)
);

//row3
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row3(
    .xi(mac_m_data[3*DW +: DW]),
    .wi(w_pass[3]),
    .ci(co2),
    .w_en(w_en_pass[3]),

    .co(co3),
    .clk(clk),
    .rst_n(rst_n)
);

//row4
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row4(
    .xi(mac_m_data[4*DW +: DW]),
    .wi(w_pass[4]),
    .ci(co3),
    .w_en(w_en_pass[4]),

    .co(co4),
    .clk(clk),
    .rst_n(rst_n)
);

//row5
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row5(
    .xi(mac_m_data[5*DW +: DW]),
    .wi(w_pass[5]),
    .ci(co4),
    .w_en(w_en_pass[5]),

    .co(co5),
    .clk(clk),
    .rst_n(rst_n)
);

//row6
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row6(
    .xi(mac_m_data[6*DW +: DW]),
    .wi(w_pass[6]),
    .ci(co5),
    .w_en(w_en_pass[6]),

    .co(co6),
    .clk(clk),
    .rst_n(rst_n)
);

//row7
mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN))) i_mac_row7(
    .xi(mac_m_data[7*DW +: DW]),
    .wi(w_pass[7]),
    .ci(co6),
    .w_en(w_en_pass[7]),

    .co(co7),
    .clk(clk),
    .rst_n(rst_n)
);

endmodule