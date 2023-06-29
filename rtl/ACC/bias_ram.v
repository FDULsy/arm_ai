module bias_ram(
    input  [8:0] addr,
    output [18*6-1 : 0] do,
    input clk,
    input rst_n
);

biasram i_biasram0(
    .addra(addr),
    .dia(18'b0),
    //.ocea(1'b1),
    .wea(1'b0),
    .doa(do[18*0 +: 18]),
    .clka(clk)
    //.rsta(rst_n)
);

biasram i_biasram1(
    .addra(addr),
    .dia(18'b0),
    //.ocea(1'b1),
    .wea(1'b0),
    .doa(do[18*1 +: 18]),
    .clka(clk)
    //.rsta(rst_n)
);

biasram i_biasram2(
    .addra(addr),
    .dia(18'b0),
    //.ocea(1'b1),
    .wea(1'b0),
    .doa(do[18*2 +: 18]),
    .clka(clk)
    //.rsta(rst_n)
);

biasram i_biasram3(
    .addra(addr),
    .dia(18'b0),
    //.ocea(1'b1),
    .wea(1'b0),
    .doa(do[18*3 +: 18]),
    .clka(clk)
    //.rsta(rst_n)
);

biasram i_biasram4(
    .addra(addr),
    .dia(18'b0),
    //.ocea(1'b1),
    .wea(1'b0),
    .doa(do[18*4 +: 18]),
    .clka(clk)
    //.rsta(rst_n)
);

biasram i_biasram5(
    .addra(addr),
    .dia(18'b0),
    //.ocea(1'b1),
    .wea(1'b0),
    .doa(do[18*5 +: 18]),
    .clka(clk)
    //.rsta(rst_n)
);

endmodule