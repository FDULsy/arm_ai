`timescale 1ps/1ps
module conv_acc_tn #(
    parameter AW=8 , DW=22 ,DN=1  
);

reg clk,rst_n;
reg [AW-1:0] base;
reg [10:0] size;
reg start,m_first,s_first;
wire [AW-1:0] m_addr2,m_addr3,m_w_addr;
wire m_ready;

reg [DW*DN-1:0] m_data1,m_data2,m_data3;
reg m_valid1,m_valid1_pre;
reg fc;
reg [CW1-1 : 0] m_ctrl;
wire [CW2-1 : 0] s_ctrl;
wire s_first,s_last;

wire [DW*DN-1:0] m_sum,s_sum;
wire m_valid,s_valid;
//=====例化=====
conv_acc #(.AW(AW),.DW(DW),.DN(DN),.CW1(28),.CW2(24)) i_conv_acc(
    .m_data1(m_data1),
    .m_first(m_first),
    .m_last(m_last),
    .m_valid1(m_valid1),
    .m_valid1_pre(m_valid1_pre),

    .m_data2(m_data2),
    .m_data3(m_data3),
    .m_ready(m_ready),

    .start(start),
    .fc(fc),
    .base(base),
    .size(size),
    
    .m_ctrl(m_ctrl),
    .s_ctrl(s_ctrl),

    .m_addr2(m_addr2),
    .m_addr3(m_addr3),
    .m_w_addr(m_w_addr),
    .m_sum(m_sum),
    .m_valid(m_valid),
    .s_sum(s_sum),
    .s_valid(s_valid),
    .s_first(s_first),
    .s_last(s_last),
    .clk(clk),
    .rst_n(rst_n)
);

// ram_behavior #(.AW(AW),.DW(DW)) i_ram_in(
//     .r_addr(m_addr1),
//     .r_en(1'b1),
//     .r_data(m_data1),

//     .w_addr(w_addr1),
//     .w_en(w_en1),
//     .w_data(w_data1),

//     .clk(clk),
//     .rst_n(rst_n)
// );

// ram_behavior#(.AW(AW),.DW(DW)) i_ram_bias(
//     .r_addr(m_addr2),
//     .r_en(1'b1),
//     .r_data(m_data2),

//     .w_addr(w_addr2),
//     .w_en(w_en2),
//     .w_data(w_data2),

//     .clk(clk),
//     .rst_n(rst_n)
// );

// ram_behavior#(.AW(AW),.DW(DW)) i_ram_partial_sum(
//     .r_addr(m_addr3),
//     .r_en(1'b1),
//     .r_data(m_data3),

//     .w_addr(w_addr3),
//     .w_en(w_en3),
//     .w_data(w_data3),

//     .clk(clk),
//     .rst_n(rst_n)
// );

//==============


initial begin
    clk=0;
    forever begin
       #5 clk=~clk; 
    end 

    forever begin
        #20 m1_vlaid = m_valid1_pre;
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
    base=0;m_data1=0;m_data2=0;m_data3=0;m_valid1_pre=0;
    size=0;start=0;
    //

    //
    
end

endmodule
