`timescale 1ps/1ps
module scale_tb #(
    parameter AW=0 , DW=22 , DN=1  
);

reg [8:0] data2;
reg [DW-1 : 0] data1;
reg clk,rst_n;
reg [DN*DW-1 :0] m_data1;
reg [ DN*9-1 : 0] m_data2;
reg m_valid1,relu;
reg [4:0] n;

wire [DN*8-1 : 0] s_data;
wire s_valid;

//=====例化=====

scale #(.DW(DW),.DN(DN)) i_scale(
    .m_data1(m_data1),
    .m_valid1(m_valid1),
    .m_data2(m_data2),
    .n(n),
    .relu_en(relu),
    .s_data(s_data),
    .s_valid(s_valid),
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

always @(posedge clk ) begin
    m_data1 <=#2 {DN{data1}};
    m_data2 <=#2 {DN{data2}}; 
end

initial begin
    rst_n=0;
    #10 rst_n=1;
    #1000 ;
    $stop;
end

initial begin
    //input inital
    m_data1=0;m_valid1=0;m_data2=0;n=0;relu=0;
    //
    #16
    data2=9'b011011110;//m=0.0017
    data1=22'd100;
    #10 m_valid1=1;n=17;
    #10 data1=22'd600;//1.02
    #10 data1=22'd1000;//1.7
    #10 data1=22'd3000;//5.1
    #10 data1=22'd4500;//7.65
    #10 data1=22'd8000;//13.6
    #10 data1=22'd58824;//100.0008
    #10 data1=22'd600;//-1.02
    #10 data1=-22'd1000;//-1.7
    #10 data1=-22'd3000;//-5.1
    #10 data1=-22'd4500;//-7.65
    #10 data1=-22'd58824;//-100.0008
    #10 relu=1;data1=-22'd1500;//0
    #10 data1=-22'd10000;//0
    #10 data1=22'd58824;//100
    #10 data1=-22'd58824;//0






    //

end

endmodule
