`timescale 1ps/1ps
module crdma_tb #(
    parameter AW=11 , DW=64 ,   
);

reg clk,rst_n;


//=====例化=====

 (

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
    #16 

    //

end

endmodule
