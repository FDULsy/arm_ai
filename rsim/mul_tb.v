module mul_tb #(
    parameter DW=9,OW=18
);

reg clk,rst_n;
reg [DW-1:0] d1,d2;
wire [OW-1:0] do;

//=====例化=====

mul #(.DW(DW),.OW(OW)) I_MUL(
    .d1(d1),
    .d2(d2),
    .do(do),

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
    d1=0;d2=0;
    //
    #16
    d1=2;d2=6;
    #10 d1=100;d2=100;
    #10 d1=-10;d2=10;
    #10 d1=-100;d2=-100;



    //

end

endmodule
