`timescale 1ps/1ps
module conv_acc_tn #(
    parameter AW=8 , DW=22 ,DN=1  
);

reg clk,rst_n;
reg [AW-1:0] base2;
reg [10:0] size;
reg start,first_k,last_k;
wire [AW-1:0] m_addr2,m_addr3;
wire m_ready;

reg [DW*DN-1:0] m_data1,m_data2,m_data3;
reg m_valid1;

wire [DW*DN-1:0] m_sum,s_sum;
wire m_valid,s_valid;
//=====例化=====
conv_acc #(.AW(AW),.DW(DW),.DN(DN)) i_conv_acc(
    .m_data1(m_data1),
    .m_valid1(m_valid1),
    .m_data2(m_data2),
    .m_data3(m_data3),
    .m_ready(m_ready),

    .base2(base2),
    .size(size),
    .start(start),
    .first_k(first_k),
    .last_k(last_k),

    .m_addr2(m_addr2),
    .m_addr3(m_addr3),
    .m_sum(m_sum),
    .m_valid(m_valid),
    .s_sum(s_sum),
    .s_valid(s_valid),
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
end

initial begin
    rst_n=0;
    #10 rst_n=1;
    #1000 ;
    $stop;
end

initial begin
    //input inital
    base2=0;m_data1=0;m_data2=0;m_data3=0;m_valid1=0;
    size=0;start=0;first_k=0;last_k=0;
    //
    #16 size=8;start=1;first_k=1;base2=10;
    #10 start=0;
    #80 m_valid1=1;
    m_data1=15;m_data2=8;//23
    #10 m_data1=20;m_data2=11;//31
    #10 m_data1=-30;m_data2=-9;//-39
    #10 m_data1=-50;m_data2=11;//-39
    #10 m_data1=7;m_data2=1;//8
    #10 m_data1=5;m_data2=-17;//-12
    #10 m_data1=99;m_data2=50;//149
    #10 m_data1=125;m_data2=111;//236
    #10 m_data1=11;m_data2=22;

    #10 m_data1=11;
    #10 m_data1=12;
    #10 m_data1=13;
    #10 m_valid1=0;first_k=0;
    #20 size=4;start=1;last_k=1;base2=100;m_data1=500;m_data2=200;m_valid1=1;
    #10 start=0;m_data1=20;m_data2=11;
    #10 m_data1=21;m_data2=12;
    #10 m_data1=22;m_data2=13;
    #10 m_data1=23;m_data2=14;
    #10 m_valid1=0;

    //
    
end

endmodule
