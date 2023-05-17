`timescale 1ps/1ps
module conv_acc_tn #(
    parameter AW=8 , DW=22 ,DN=1  
);

reg clk,rst_n;
reg [AW-1:0] base1,base2;
reg [7:0] size;
reg start,first_k,last_k;
wire [AW-1:0] m_addr1,m_addr2,m_addr3;

reg w_en1,w_en2,w_en3;
reg [DW-1:0] w_data1,w_data2,w_data3;
wire [DW*DN-1:0] m_data1,m_data2,m_data3;
reg [AW-1:0] w_addr1,w_addr2,w_addr3;
wire [DW*DN-1:0] m_sum,s_sum;
wire m_valid,s_valid;
//=====例化=====
conv_acc #(.AW(AW),.DW(DW),.DN(DN)) i_conv_acc(
    .m_data1(m_data1),
    .m_data2(m_data2),
    .m_data3(m_data3),

    .base1(base1),
    .base2(base2),
    .size(size),
    .start(start),
    .first_k(first_k),
    .last_k(last_k),

    .m_addr1(m_addr1),
    .m_addr2(m_addr2),
    .m_addr3(m_addr3),
    .m_sum(m_sum),
    .m_valid(m_valid),
    .s_sum(s_sum),
    .s_valid(s_valid),
    .clk(clk),
    .rst_n(rst_n)
);

ram_behavior #(.AW(AW),.DW(DW)) i_ram_in(
    .r_addr(m_addr1),
    .r_en(1'b1),
    .r_data(m_data1),

    .w_addr(w_addr1),
    .w_en(w_en1),
    .w_data(w_data1),

    .clk(clk),
    .rst_n(rst_n)
);

ram_behavior#(.AW(AW),.DW(DW)) i_ram_bias(
    .r_addr(m_addr2),
    .r_en(1'b1),
    .r_data(m_data2),

    .w_addr(w_addr2),
    .w_en(w_en2),
    .w_data(w_data2),

    .clk(clk),
    .rst_n(rst_n)
);

ram_behavior#(.AW(AW),.DW(DW)) i_ram_partial_sum(
    .r_addr(m_addr3),
    .r_en(1'b1),
    .r_data(m_data3),

    .w_addr(w_addr3),
    .w_en(w_en3),
    .w_data(w_data3),

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
    w_en1=0;w_en2=0;w_en3=0;w_addr1=0;w_addr2=0;w_addr3=0;w_data1=0;w_data2=0;w_data3=0;
    base1=0;base2=0;
    size=0;start=0;first_k=0;last_k=0;
    //
    #16 size=10;start=1;first_k=1;
    #10 start=0;
    #180 base1=10;base2=0;size=10;start=1;first_k=0;
    #10 start=0;
    #180 base1=20;base2=0;size=10;start=1;first_k=0;
    #10 start=0;
    #80 base1=30;base2=0;size=10;start=1;first_k=0;
    #10 start=0;
    #80 base1=40;base2=0;size=10;start=1;first_k=0;last_k=1;
    #10 start=0;




    //
    
end

endmodule
