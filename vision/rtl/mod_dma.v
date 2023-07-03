module mod_dma(
    input   [1:0]       state       ,
    output  [9:0]       addr0       ,
    output  [9:0]       addr1       ,

    input               clk         ,
    input               rst_n
);

reg [9:0] addr0_r,addr1_r;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n || (state == 2'b11) || (state == 2'b00))
        addr0_r <= 0;
    else 
        addr0_r <= addr0_r + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n || (state != 2'b10) )
        addr1_r <= 0;
    else 
        addr1_r <= addr1_r + 1'b1;
end

assign addr0 = addr0_r;
assign addr1 = addr1_r;
endmodule