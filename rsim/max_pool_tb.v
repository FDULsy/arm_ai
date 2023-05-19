`timescale 1ps/1ps
module max_pool_tb #(
    parameter AW=0 , DW=8 , DN=1  
);

reg clk,rst_n;
reg [DN*DW-1 : 0] m_data;
reg m_valid,m_max_pool_en,s_ready;
reg [5:0] m_width;

wire [DN*DW-1 : 0] s_data;
wire s_valid;

//=====例化=====


max_pool #(.DW(DW),.DN(DN)) i_max_pool(
    .m_data(m_data),
    .m_valid(m_valid),
    .m_width(m_width),
    .m_max_pool_en(m_max_pool_en),

    .s_data(s_data),
    .s_valid(s_valid),
    .s_ready(s_ready),

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

    //
    #16 m_valid=1;
    m_data=0;
    m_width=2;m_max_pool_en=1;
    s_ready=1;
    #10 m_data=48'h010101010101;//01
    #10 m_data=48'h020202020202;
    #10 m_data=48'h030303030303;//03

    #10 m_data=48'h040404040404;
    #10 m_data=48'h010101010101;//04 04
    #10 m_data=48'h050505050505;
    #10 m_data=48'h0a0a0a0a0a0a;//0a 0a


    #10 m_data=48'h010101010101;
    #10 m_data=48'h020202020202;//02
    #10 m_data=48'h030303030303;
    #10 m_data=48'h090909090909;//09

    #10 m_data=48'h010101010101;
    #10 m_data=48'h030303030303;//03 03
    #10 m_data=48'h060606060606;
    #10 m_data=48'h070707070707;//07 09

    #10 m_valid=0;
    #40 m_width=3;m_valid=1;
    m_data =48'h060606060606;
    #10 m_data=48'h040404040404;//06
    #10 m_data=48'h010101010101;
    #10 m_data=48'h050505050505;//05
    #10 m_data=48'h040404040404;
    #10 m_data=48'h010101010101;//04

    #10 m_data=48'h010101010101;
    #10 m_data=48'h020202020202;//02 06
    #10 m_data=48'h030303030303;
    #10 m_data=48'h040404040404;//04 05
    #10 m_data=48'h101010101010;
    #10 m_data=48'h111111111111;//11 11
    #10 m_valid=0;m_max_pool_en=0;
    #100 m_valid=1;m_data=0;//00
    #10 m_data=48'h010101010101;//01
    #10 m_data=48'h020202020202;//02
    #10 m_data=48'h030303030303;//03
    #10 m_valid=0;m_data=48'h040404040404;//03
    #10 m_data=48'h050505050505;//03
    #10 m_valid=1;m_data=48'h060606060606;//06
    #10 s_ready=0;m_data=48'h070707070707;//06


    //

end

endmodule
