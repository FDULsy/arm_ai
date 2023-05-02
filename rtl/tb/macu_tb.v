`timescale 1ps/1ps
module macu_tb #(
    parameter DW=8,CW=16   
);

reg [DW-1:0] xi;
reg [DW-1:0] wi;
reg [CW-1:0] ci;
reg clk;
reg rst_n;
wire [CW:0]co;

macu #(.DW(DW),.CW(CW)) i_macu(
    .xi(xi),
    .wi(wi),
    .ci(ci),

    .co(co),

    .clk(clk),
    .rst_n(rst_n)
);
    
initial begin
    clk=0;
    forever begin
       #5 clk=~clk; 
    end 
end

initial begin
    rst_n=0;
    xi=$random %100;
    wi=0;
    ci=0;
    #16 rst_n=1;
    #10 xi=1;wi=1;ci=0 ;
    #10 xi=2 ;
    #10 xi=3 ;
    #10 xi=$random;wi=1;ci=0 ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random;wi=2 ;
    #10 xi=$random;ci=1 ;
    #10 xi=$random ;
    #10 xi=$random;wi=16;ci=0 ;
    #10 xi=$random ;
    #10 xi=$random;ci=10 ;
    #10 xi=$random ;
    #10 xi=$random;wi=100;
    #10 xi=$random ;
    #10 xi=$random;ci=11 ;
    #10 xi=$random;ci=13 ;
    #10 xi=$random;ci=12 ;
    #10 xi=$random ;
    #10 xi=$random ;

    #800 ;
    $stop;
end

endmodule