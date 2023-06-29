module acc_ram(
    input  [9:0] addr,
    input  [22*6-1 : 0] datai,
    input               valid,
    output [22*6-1 : 0] datao,

    input clk,
    input rst_n

);
reg [9:0] addr_r1,addr_r2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_r1 <= 0;
        addr_r2 <= 0;
    end
    else begin
        addr_r1 <= addr;
        addr_r2 <= addr_r1;
    end
end

accram i_accram0(
    .dia(datai[22*0 +: 22]),
    .addra(addr_r2),
    .clka(clk),
    .cea(valid),

	.dob(datao[22*0 +: 22]),
    .addrb(addr),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

accram i_accram1(
    .dia(datai[22*1 +: 22]),
    .addra(addr_r2),
    .clka(clk),
    .cea(valid),
	.dob(datao[22*1 +: 22]),
    .addrb(addr),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

accram i_accram2(
    .dia(datai[22*2 +: 22]),
    .addra(addr_r2),
    .clka(clk),
    .cea(valid),
	.dob(datao[22*2 +: 22]),
    .addrb(addr),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

accram i_accram3(
    .dia(datai[22*3 +: 22]),
    .addra(addr_r2),
    .clka(clk),
    .cea(valid),
	.dob(datao[22*3 +: 22]),
    .addrb(addr),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

accram i_accram4(
    .dia(datai[22*4 +: 22]),
    .addra(addr_r2),
    .clka(clk),
    .cea(valid),
	.dob(datao[22*4 +: 22]),
    .addrb(addr),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

accram i_accram5(
    .dia(datai[22*5 +: 22]),
    .addra(addr_r2),
    .clka(clk),
    .cea(valid),
	.dob(datao[22*5 +: 22]),
    .addrb(addr),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

endmodule