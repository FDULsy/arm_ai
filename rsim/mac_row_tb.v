`timescale 1ps/1ps
module mac_row_tb #(
    parameter DW=8,WW=8,CW=16,COLUMN=6
) ;
reg clk,rst_n;
reg [DW-1 : 0] xi;
reg [COLUMN*WW-1 : 0] wi;
reg [COLUMN*CW-1 : 0] ci;
reg [COLUMN-1 : 0] w_en;
wire [COLUMN*(CW+1)-1 : 0] co;

//=====例化=====


mac_row #(.DW(DW),.WW(WW),.CW(CW),.COLUMN(COLUMN)) i_mac_row(
    .xi(xi),
    .wi(wi),
    .ci(ci),
    .w_en(w_en),

    .co(co),
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
    xi=0;wi=0;ci=0;w_en=0;
    //
    #16;
    w_en=6'b111111;
    wi=48'h060504030201;
    #10 w_en=0;xi=1;
    #10 xi=2;
    #10 xi=3;
    #10 xi=4;
    #10 xi=10;ci=1;
    #10 xi=15;ci=2;

    //

end

endmodule