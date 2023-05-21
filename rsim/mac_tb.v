`timescale 1ps/1ps
module mac_tb #(
    parameter DW=8,WW=8,CW=19,ROW=8,COLUMN=6,OW=2*DW+6
);

reg clk,rst_n;
reg [ROW*DW-1:0] mac_m_data;
reg mac_m_first,mac_m_last,mac_m_valid,mac_s_ready;
reg [COLUMN*WW-1:0] w;
reg [COLUMN-1:0] w_en;
reg [COLUMN*CW-1:0] ci;
wire [COLUMN*OW-1:0] mac_s_data;
wire mac_s_first,mac_s_last,mac_s_valid,mac_m_ready;


//=====例化=====

mac #(.DW(DW),.WW(WW),.CW(CW),.ROW(ROW),.COLUMN(COLUMN),.OW(OW)) i_mac(
    .mac_m_data(mac_m_data),
    .mac_m_first(mac_m_first),
    .mac_m_last(mac_m_last),
    .mac_m_valid(mac_m_valid),
    .mac_m_ready(mac_m_ready),
    .w(w),
    .w_en(w_en),
    .ci(ci),
    .mac_s_data(mac_s_data),
    .mac_s_first(mac_s_first),
    .mac_s_last(mac_s_last),
    .mac_s_valid(mac_s_valid),
    .mac_s_ready(mac_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);


//==============
initial begin
    clk=0;
    forever begin
       #5 clk=~clk; 
    end 
end

initial begin
    rst_n=0;
    #10 rst_n=1;
    #1000 ;
    $stop;
end

initial begin
    //input inital
    mac_s_ready=1;mac_m_data=0;mac_m_first=0;mac_m_last=0;mac_m_valid=0;w=0;w_en=0;ci=0;
    //
    #16 w=48'h060504030201;w_en=6'b111111;
    #10 w=48'h0c0b0a090807;w_en=0;mac_m_first=1;mac_m_valid=1;mac_m_data=64'h0000000000000001;
    #10 w=48'h060504030201;mac_m_data=64'h0000000000000102;mac_m_first=0;
    #10 mac_m_data=64'h0000000000010201;mac_m_last=1;
    #10 mac_m_data=64'h0000000001020200;mac_m_valid=0;mac_m_last=0;
    #10 mac_m_data=64'h0000000102030000;
    #10 mac_m_data=64'h0000010204000000;
    #10 mac_m_data=64'h0001020500000000;
    #10 mac_m_data=64'h0102060000000000;
    #10 mac_m_data=64'h0207000000000000;
    #10 mac_m_data=64'h0700000000000000;
    #10 mac_m_data=0;


    //

end

endmodule
