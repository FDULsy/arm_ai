`timescale 1ps/1ps
module model_tb #(
    parameter DW=64,DN=8   
);

reg [DW-1:0] xi;
reg clk;
reg rst_n;
wire [DW-1:0]xo;

delay_chain #(.DW(DW),.DN(DN))i_delay(
    .xi(xi),
    .xo(xo),
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
    #16 rst_n=1;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;
    #10 xi=$random ;

    #800 ;
    $stop;
end

endmodule