//first last valid信号没写
module mac #(parameter DW=8,WW=8,CW=19,ROW=8,COLUMN=6,OW=2*DW+6
) (
    input [ROW*DW-1:0]         mac_m_data,
    input                      mac_m_first,
    input                      mac_m_last,
    input                      mac_m_valid,
    output                     mac_m_ready,
    input [COLUMN*WW-1 : 0]    w,
    input [   COLUMN-1 : 0]    w_en,
    input [COLUMN*CW-1 : 0]    ci,

    output [COLUMN*OW-1 : 0]   mac_s_data,
    output                     mac_s_first,
    output                     mac_s_last,
    output                     mac_s_valid,
    input                      mac_s_ready,

    input clk,
    input rst_n
);

localparam EW = OW-CW;

//wire [COLUMN*WW-1 : 0] w_pass [ROW-1 : 0];
wire [   COLUMN-1 : 0] w_en_pass [ROW-1 : 0];
//reg  [COLUMN*WW-1 : 0] w_pass_r [ROW-2 : 0];
reg  [   COLUMN-1 : 0] w_en_pass_r [ROW-2 : 0];

wire [COLUMN*(CW)-1 : 0] co0;
wire [COLUMN*(CW)-1 : 0] co1;
wire [COLUMN*(CW)-1 : 0] co2;
wire [COLUMN*(CW)-1 : 0] co3;
wire [COLUMN*(CW)-1 : 0] co4;
wire [COLUMN*(CW)-1 : 0] co5;
wire [COLUMN*(CW)-1 : 0] co6;
wire [COLUMN*(CW)-1 : 0] co7;

//wire [CW-1:0] co7_a [COLUMN-1 : 0];

wire [2:0] m_info;
wire [2:0] s_info;

//assign w_pass[0] = w;
assign w_en_pass[0] = w_en; 
// assign c[0] ={48'h0,ci};
//assign mac_s_data = co7;

//assign w_pass[1] = w_pass_r[0];
// assign w_pass[2] = w_pass_r[1];
// assign w_pass[3] = w_pass_r[2];
// assign w_pass[4] = w_pass_r[3];
// assign w_pass[5] = w_pass_r[4];
// assign w_pass[6] = w_pass_r[5];
// assign w_pass[7] = w_pass_r[6];

assign w_en_pass[1]=w_en_pass_r[0];
assign w_en_pass[2]=w_en_pass_r[1];
assign w_en_pass[3]=w_en_pass_r[2];
assign w_en_pass[4]=w_en_pass_r[3];
assign w_en_pass[5]=w_en_pass_r[4];
assign w_en_pass[6]=w_en_pass_r[5];
assign w_en_pass[7]=w_en_pass_r[6];




genvar i;
generate
    for (i=0;i<ROW-1;i=i+1) begin: weight_pass
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                // w_pass_r[i] <= 0;
                w_en_pass_r[i] <= 0;
            end
            else
                // w_pass_r[i] <= w_pass[i];
                w_en_pass_r[i] <= w_en_pass[i];
        end
    end
endgenerate


assign m_info={mac_m_first,mac_m_last,mac_m_valid};

delay #(.DW(3),.DLT(10)) i_info_delay(
    .xi(m_info),
    .xo(s_info),

    .clk(clk),
    .rst_n(rst_n)
);
assign {mac_s_first,mac_s_last,mac_s_valid} = s_info;

delay #(.DW(1),.DLT(10)) i_rdy_delay(
    .xi(mac_s_ready),
    .xo(mac_m_ready),

    .clk(clk),
    .rst_n(rst_n)
);

//row0
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row0(
    .xi(mac_m_data[0*DW +: DW]),
    .wi(w),
    .ci(ci),
    .w_en(w_en_pass[0]),

    .co(co0),
    .clk(clk),
    .rst_n(rst_n)
);

//row1
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row1(
    .xi(mac_m_data[1*DW +: DW]),
    .wi(w),
    .ci(co0),
    .w_en(w_en_pass[1]),

    .co(co1),
    .clk(clk),
    .rst_n(rst_n)
);

//row2
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row2(
    .xi(mac_m_data[2*DW +: DW]),
    .wi(w),
    .ci(co1),
    .w_en(w_en_pass[2]),

    .co(co2),
    .clk(clk),
    .rst_n(rst_n)
);

//row3
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row3(
    .xi(mac_m_data[3*DW +: DW]),
    .wi(w),
    .ci(co2),
    .w_en(w_en_pass[3]),

    .co(co3),
    .clk(clk),
    .rst_n(rst_n)
);

//row4
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row4(
    .xi(mac_m_data[4*DW +: DW]),
    .wi(w),
    .ci(co3),
    .w_en(w_en_pass[4]),

    .co(co4),
    .clk(clk),
    .rst_n(rst_n)
);

//row5
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row5(
    .xi(mac_m_data[5*DW +: DW]),
    .wi(w),
    .ci(co4),
    .w_en(w_en_pass[5]),

    .co(co5),
    .clk(clk),
    .rst_n(rst_n)
);

//row6
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row6(
    .xi(mac_m_data[6*DW +: DW]),
    .wi(w),
    .ci(co5),
    .w_en(w_en_pass[6]),

    .co(co6),
    .clk(clk),
    .rst_n(rst_n)
);

//row7
mac_row #(.DW(DW),.WW(WW),.CW(CW),.OW(CW),.COLUMN(COLUMN)) i_mac_row7(
    .xi(mac_m_data[7*DW +: DW]),
    .wi(w),
    .ci(co6),
    .w_en(w_en_pass[7]),

    .co(co7),
    .clk(clk),
    .rst_n(rst_n)
);

genvar j;
generate
    for (j =0 ;j<COLUMN ;j=j+1 ) begin
        //assign mac_s_data[j*OW +: OW] = {3'b1,co7[j*CW +: CW]};
        assign mac_s_data[j*OW +: OW] = {{3{co7[j*CW+CW-1]}},co7[j*CW +: CW]};
    end
endgenerate

endmodule
