`timescale 1ps/1ps
module dma_dim2_tb #(
    parameter AW=14 
);

reg clk,rst_n;
reg [13:0] base;
reg [6:0] dim0_size;
reg dim0_step;
reg [4:0] dim1_size;
reg [6:0] dim1_step;
reg start_valid,s_ready;
wire start_ready,s_first,s_last,s_valid;
wire [13:0] s_addr;


//=====例化=====

dma_dim2 I_DMA_DIM2 (
    .base(base),
    .dim0_size(dim0_size),
    .dim0_step(dim0_step),
    .dim1_size(dim1_size),
    .dim1_step(dim1_step),
    .start_valid(start_valid),
    .start_ready(start_ready),

    .s_addr(s_addr),
    .s_first(s_first),
    .s_last(s_last),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
);

always @(posedge clk ) begin
        if(start_valid && start_ready)
            start_valid <= 0;
end
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
    start_valid=0;base=0;dim0_size=0;dim0_step=0;dim1_size=0;dim1_step=0;
    s_ready=1;
    //
    #16 
    start_valid=1;dim0_size=9;dim0_step=1;dim1_size=5;dim1_step=10;
    #10 start_valid=0;
    #20 start_valid=1;base=100;dim0_size=5;dim1_step=2;dim1_size=2;dim1_step=20;
    //

end

endmodule
