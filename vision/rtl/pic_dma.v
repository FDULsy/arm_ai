module pic_dma(
    input  [1:0]        state       ,
    output [10:0]       addr        ,

    input               clk         ,
    input               rst_n             
);

reg [9:0] addr_r;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n || (state == 2'b11) || (state == 2'b00))
        addr_r <= 0;
    else 
        addr_r <= addr_r+1'b1;
end

assign addr = {addr_r,1'b0};

endmodule