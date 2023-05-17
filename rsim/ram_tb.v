`timescale 1ps/1ps
module ram_tb #(parameter AW=5 , DW=8 , DN=1  )();

reg clk,rst_n;
reg [AW-1:0] r_addr,w_addr;
reg r_en,w_en;
reg [DW-1:0] w_data;

wire [DW-1:0] r_data;

//=====例化=====
ram_behavior #(.AW(AW),.DW(DW)) i_ram(
    .r_addr(r_addr),
    .r_en(r_en),
    .r_data(r_data),

    .w_addr(w_addr),
    .w_en(w_en),
    .w_data(w_data),

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
    r_addr=0;w_addr=0;r_en=0;w_en=0;w_data=0;
    //
    #16 w_en=1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=-3;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 w_en=0;w_addr=w_addr+1;w_data=w_data+1;
    #10 w_addr=w_addr+1;w_data=w_data+1;
    #10 r_en=1;
    #10 r_addr=r_addr+1;
    #10 r_addr=r_addr+1;
    #10 r_addr=r_addr+1;
    #10 r_addr=r_addr+1;
    #10 r_addr=r_addr+1;
    #10 r_addr=r_addr+5'b11;
    #10 r_addr=r_addr+1;
    #10 r_addr=r_addr+5'b10;
    #10 r_en = 0;r_addr=r_addr+1;
    #10 r_addr=r_addr+1;
    //

end

endmodule
