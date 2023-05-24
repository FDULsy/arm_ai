`timescale 1ps/1ps
module rmux_tb #(
    parameter AW=14 , DW=8 , DN=8, DW0=16,IFW=4  
);

reg clk,rst_n;
//d
reg [DN*DW-1 : 0] m_data0;
reg [DW0-1 : 0] m_data1;
reg m_data_first0,m_data_last0,m_data_valid0,m_data_first1,m_data_last1,m_data_valid1;
wire m_data_ready0,m_data_ready1;
wire [DW*DN-1 : 0] s_data;
wire s_data_first,s_data_last,s_data_valid;
reg s_data_ready;

//info
reg [IFW-1 : 0] info;

//addr
reg [AW-1:0] m_addr;
reg m_addr_first,m_addr_last,m_addr_valid;
wire m_addr_ready;
wire [AW-1:0] s_addr0,s_addr1;
wire s_addr_first0,s_addr_first1,s_addr_last0,s_addr_last1,s_addr_valid0,s_addr_valid1;
reg s_addr_ready0,s_addr_ready1;


//=====例化=====

rmux #(.DW0(DW0),.DW(DW),.DN(DN),.IFW(IFW),.AW(AW)) i_rmux (
    .m_data0(m_data0),
    .m_data_first0(m_data_first0),
    .m_data_last0(m_data_last0),
    .m_data_valid0(m_data_valid0),
    .m_data_ready0(m_data_ready0),

    .m_data1(m_data1),
    .m_data_first1(m_data_first1),
    .m_data_last1(m_data_last1),
    .m_data_valid1(m_data_valid1),
    .m_data_ready1(m_data_ready1),

    .s_data(s_data),
    .s_data_first(s_data_first),
    .s_data_last(s_data_last),
    .s_data_valid(s_data_valid),
    .s_data_ready(s_data_ready),

    .info(info),

    .m_addr(m_addr),
    .m_addr_first(m_addr_first),
    .m_addr_last(m_addr_last),
    .m_addr_valid(m_addr_valid),
    .m_addr_ready(m_addr_ready),

    .s_addr0(s_addr0),
    .s_addr_first0(s_addr_first0),
    .s_addr_last0(s_addr_last0),
    .s_addr_valid0(s_addr_valid0),
    .s_addr_ready0(s_addr_ready0),

    .s_addr1(s_addr1),
    .s_addr_first1(s_addr_first1),
    .s_addr_last1(s_addr_last1),
    .s_addr_valid1(s_addr_valid1),
    .s_addr_ready1(s_addr_ready1),

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
    s_data_ready=1;
    m_data0=0;m_data_first0=0;m_data_last0=0;m_data_valid0=0;
    m_data1=0;m_data_first1=0;m_data_last1=0;m_data_valid1=0;
    info=0;
    m_addr=0;m_addr_first=0;m_addr_last=0;m_addr_valid=0;
    s_addr_ready0=1;s_addr_ready1=0;
    //
    #16     
    info=4'b1011;
    m_addr=100;m_addr_first=1;m_addr_last=0;m_addr_valid=1;
    m_data1=88;m_data_first1=0;m_data_last1=0;m_data_valid1=0;
    m_data0=77;m_data_first0=0;m_data_last0=0;m_data_valid0=0;
    
    #20 
    #10 s_addr_ready1=1;
    #10 m_addr=102;m_addr_first=0;m_data1=1;m_data_first1=1;m_data_last1=0;m_data_valid1=1;
    #10 m_addr=103;m_data1=3;m_data_first1=0;m_data_last1=0;
    #10 m_addr=104;m_data1=5;
    #10 m_addr=105;m_addr_last=1;m_data1=7;
    #10 m_addr_valid=0;m_addr_last=0;m_data1=9;m_data_last1=1;
    #10 m_data_last1=0;m_data_valid1=0;
    //

end

endmodule
