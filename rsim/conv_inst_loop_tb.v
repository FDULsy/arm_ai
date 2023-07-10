`timescale 1ps/1ps
module conv_inst_loop_tb #(
    parameter IRW=20 , IN=2 , AW=14  
);

reg clk,rst_n;
reg [39:0] m_inst;
reg m_valid,s_ready;

wire [39:0] s_inst;
wire s_valid,m_ready;


//=====例化=====

 conv_inst_loop #(.IRW(IRW),.IN(IN),.AW(AW)) i_instance(
    .m_inst(m_inst),
    .m_valid(m_valid),
    .m_ready(m_ready),
    .s_inst (s_inst),
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
    m_inst=0;m_valid=0;s_ready=0;
    //
    #16 
 
    //

end

endmodule
