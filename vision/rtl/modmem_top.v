module modmem_top #(
    parameter CLAS = 5,MODI = 6, MODN = CLAS*MODI
) (
    input       [9:0]               addr0   ,
    input       [9:0]               addr1   ,
    output      [MODN*16-1 : 0]     mod_bus ,

    input                           clk     ,
    input                           rst_n
);
    
wire [15:0] d11,d12,d13,d14,d15,d16;
wire [15:0] d21,d22,d23,d24,d25,d26;
wire [15:0] d31,d32,d33,d34,d35,d36;
wire [15:0] d41,d42,d43,d44,d45,d46;
wire [15:0] d51,d52,d53,d54,d55,d56;

assign mod_bus={d56,d55,d54,d53,d52,d51,d46,d45,d44,d43,d42,d41,d36,d35,d34,d33,d32,d31,d26,d25,d24,d23,d22,d21,d16,d15,d14,d13,d12,d11};

modmem1 i_modmem_1_1(
    .doa(d11),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d12),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem2 i_modmem_1_2(
    .doa(d13),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d14),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem3 i_modmem_1_3(
    .doa(d15),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d16),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

///2
modmem4 i_modmem_2_1(
    .doa(d21),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d22),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem5 i_modmem_2_2(
    .doa(d23),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d24),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem6 i_modmem_2_3(
    .doa(d25),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d26),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

///3
modmem7 i_modmem_3_1(
    .doa(d31),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d32),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem8 i_modmem_3_2(
    .doa(d33),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d34),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem9 i_modmem_3_3(
    .doa(d35),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d36),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

///4
modmem10 i_modmem_4_1(
    .doa(d41),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d42),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem11 i_modmem_4_2(
    .doa(d43),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d44),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem12 i_modmem_4_3(
    .doa(d45),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d46),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

///5
modmem13 i_modmem_5_1(
    .doa(d51),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d52),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem14 i_modmem_5_2(
    .doa(d53),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d54),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);

modmem15 i_modmem_5_3(
    .doa(d55),
    .dia(16'h0),
    .addra(addr0),
    .clka(clk),
    .wea(1'b0),
    //.rsta(rst_n),
    //.ocea(1'b1),

    .dob(d56),
    .dib(16'h0),
    .addrb(addr1),
    .clkb(clk),
    .web(1'b0)
    //.rstb(rst_n)
    //.oceb(1'b1)
);


endmodule